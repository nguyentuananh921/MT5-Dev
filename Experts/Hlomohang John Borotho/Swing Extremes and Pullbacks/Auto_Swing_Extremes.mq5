//+------------------------------------------------------------------+
//|                                          Auto Swing Extremes.mq5 |
//|                       https://www.mql5.com/en/users/johnhlomohang|
//+------------------------------------------------------------------+
//|                         Swing Extremes and Pullbacks             |
//|                    Part 1 Developing a Multi-Timeframe Indicator |
//|                           https://www.mql5.com/en/articles/21330 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Trade/Trade.mqh>
CTrade trade;

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input ENUM_TIMEFRAMES HTF = PERIOD_H1;      // Higher Timeframe
input ENUM_TIMEFRAMES LTF = PERIOD_M5;      // Lower Timeframe
input int             SwingBars = 3;        // Bars for swing detection
input double          RiskPercent = 1.0;    // Risk per trade (%)
input int             Stop_Loss = 2000;     // StopLoss
input bool            Visualize = true;     // Show swing points & structure

//+------------------------------------------------------------------+
//| Swing Point Structure                                            |
//+------------------------------------------------------------------+
struct SwingPoint
{
   datetime          time;
   double            price;
   int               type;     // 1 = High, -1 = Low
   int               barIndex;
   
   void Reset()
   {
      time = 0;
      price = 0.0;
      type = 0;
      barIndex = 0;
   }
};

//+------------------------------------------------------------------+
//| Market Structure States                                          |
//+------------------------------------------------------------------+
enum STRUCTURE_STATE
{
   STRUCT_NEUTRAL,
   STRUCT_BULLISH,
   STRUCT_BEARISH
};

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
SwingPoint htf_lastHigh, htf_prevHigh;
SwingPoint htf_lastLow, htf_prevLow;
SwingPoint ltf_lastHigh, ltf_prevHigh;
SwingPoint ltf_lastLow, ltf_prevLow;

STRUCTURE_STATE htfBias = STRUCT_NEUTRAL;
STRUCTURE_STATE ltfStructure = STRUCT_NEUTRAL;

datetime lastHtfUpdate = 0;
datetime lastLtfUpdate = 0;

// Track last traded swing to avoid multiple entries on same swing
datetime lastBuySwingTime = 0;
datetime lastSellSwingTime = 0;
double lastBuySwingPrice = 0;
double lastSellSwingPrice = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Validate timeframe combination
   if(PeriodSeconds(HTF) <= PeriodSeconds(LTF))
   {
      Alert("HTF must be higher than LTF!");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   // Initialize swing points
   htf_lastHigh.Reset(); htf_prevHigh.Reset();
   htf_lastLow.Reset(); htf_prevLow.Reset();
   ltf_lastHigh.Reset(); ltf_prevHigh.Reset();
   ltf_lastLow.Reset(); ltf_prevLow.Reset();
   
   // Initialize trade tracking
   lastBuySwingTime = 0;
   lastSellSwingTime = 0;
   lastBuySwingPrice = 0;
   lastSellSwingPrice = 0;
   
   // Initial structure detection
   UpdateHTFStructure();
   UpdateLTFStructure();
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Clean up objects
   ObjectsDeleteAll(0, "MS_");
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   static datetime lastLtfBar = 0;
   datetime currentLtfBar = iTime(_Symbol, LTF, 0);
   
   // Process on new LTF bar
   if(currentLtfBar != lastLtfBar)
   {
      lastLtfBar = currentLtfBar;
      
      // Update HTF bias if needed (on new HTF bar)
      if(TimeCurrent() - lastHtfUpdate >= PeriodSeconds(HTF))
      {
         UpdateHTFStructure();
         lastHtfUpdate = TimeCurrent();
      }
      
      // Store previous LTF structure for comparison
      STRUCTURE_STATE prevLtfStructure = ltfStructure;
      
      // Update LTF structure
      UpdateLTFStructure();
      
      // Check for structure breaks
      CheckStructureBreak();
      
      // Try to execute trades if structure changed or conditions met
      if(ltfStructure != prevLtfStructure || 
         (ltf_lastHigh.price > 0 && ltf_lastLow.price > 0))
      {
         TryExecuteTrade();
      }
            
      // Update visualization
      if(Visualize) UpdateVisualization();
   }
}

//+------------------------------------------------------------------+
//| Update Higher Timeframe Structure                                |
//+------------------------------------------------------------------+
void UpdateHTFStructure()
{
   // Get HTF data
   MqlRates htfRates[];
   ArraySetAsSeries(htfRates, true);
   CopyRates(_Symbol, HTF, 0, 100, htfRates);
   
   if(ArraySize(htfRates) < SwingBars * 2 + 1) return;
   
   // Detect swing points on HTF
   for(int i = SwingBars; i < ArraySize(htfRates) - SwingBars; i++)
   {
      bool isHigh = true;
      bool isLow = true;
      
      // Check if current bar is swing high
      for(int j = 1; j <= SwingBars; j++)
      {
         if(htfRates[i].high <= htfRates[i-j].high || 
            htfRates[i].high <= htfRates[i+j].high)
         {
            isHigh = false;
         }
         
         if(htfRates[i].low >= htfRates[i-j].low || 
            htfRates[i].low >= htfRates[i+j].low)
         {
            isLow = false;
         }
      }
      
      // Update swing highs
      if(isHigh)
      {
         htf_prevHigh = htf_lastHigh;
         htf_lastHigh.time = htfRates[i].time;
         htf_lastHigh.price = htfRates[i].high;
         htf_lastHigh.type = 1;
         htf_lastHigh.barIndex = i;
      }
      
      // Update swing lows
      if(isLow)
      {
         htf_prevLow = htf_lastLow;
         htf_lastLow.time = htfRates[i].time;
         htf_lastLow.price = htfRates[i].low;
         htf_lastLow.type = -1;
         htf_lastLow.barIndex = i;
      }
   }
   
   // Update HTF bias
   htfBias = DetectStructure(htf_lastHigh, htf_prevHigh, htf_lastLow, htf_prevLow);
}

//+------------------------------------------------------------------+
//| Update Lower Timeframe Structure                                 |
//+------------------------------------------------------------------+
void UpdateLTFStructure()
{
   // Get LTF data
   MqlRates ltfRates[];
   ArraySetAsSeries(ltfRates, true);
   CopyRates(_Symbol, LTF, 0, 100, ltfRates);
   
   if(ArraySize(ltfRates) < SwingBars * 2 + 1) return;
   
   // Detect swing points on LTF
   for(int i = SwingBars; i < ArraySize(ltfRates) - SwingBars; i++)
   {
      bool isHigh = true;
      bool isLow = true;
      
      // Check if current bar is swing high
      for(int j = 1; j <= SwingBars; j++)
      {
         if(ltfRates[i].high <= ltfRates[i-j].high || 
            ltfRates[i].high <= ltfRates[i+j].high)
         {
            isHigh = false;
         }
         
         if(ltfRates[i].low >= ltfRates[i-j].low || 
            ltfRates[i].low >= ltfRates[i+j].low)
         {
            isLow = false;
         }
      }
      
      // Update swing highs
      if(isHigh)
      {
         ltf_prevHigh = ltf_lastHigh;
         ltf_lastHigh.time = ltfRates[i].time;
         ltf_lastHigh.price = ltfRates[i].high;
         ltf_lastHigh.type = 1;
         ltf_lastHigh.barIndex = i;
      }
      
      // Update swing lows
      if(isLow)
      {
         ltf_prevLow = ltf_lastLow;
         ltf_lastLow.time = ltfRates[i].time;
         ltf_lastLow.price = ltfRates[i].low;
         ltf_lastLow.type = -1;
         ltf_lastLow.barIndex = i;
      }
   }
   
   // Update LTF structure
   ltfStructure = DetectStructure(ltf_lastHigh, ltf_prevHigh, ltf_lastLow, ltf_prevLow);
}

//+------------------------------------------------------------------+
//| Detect Market Structure                                          |
//+------------------------------------------------------------------+
STRUCTURE_STATE DetectStructure(SwingPoint &lastHigh, SwingPoint &prevHigh,
                                SwingPoint &lastLow, SwingPoint &prevLow)
{
   // Need at least two highs and two lows
   if(lastHigh.price == 0 || prevHigh.price == 0 || 
      lastLow.price == 0 || prevLow.price == 0)
      return STRUCT_NEUTRAL;
   
   bool isHigherHigh = lastHigh.price > prevHigh.price;
   bool isHigherLow = lastLow.price > prevLow.price;
   bool isLowerLow = lastLow.price < prevLow.price;
   bool isLowerHigh = lastHigh.price < prevHigh.price;
   
   if(isHigherHigh && isHigherLow)
      return STRUCT_BULLISH;
   
   if(isLowerLow && isLowerHigh)
      return STRUCT_BEARISH;
   
   return STRUCT_NEUTRAL;
}

//+------------------------------------------------------------------+
//| New Sell Condition                                               |
//+------------------------------------------------------------------+
bool CheckSellCondition()
{
   // Need valid LTF swing points
   if(ltf_lastHigh.price == 0 || ltf_lastLow.price == 0)
      return false;
   
   // Get current price
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Check if price is above both last high and last low
   bool priceAboveHigh = currentPrice > ltf_lastHigh.price;
   bool priceAboveLow = currentPrice > ltf_lastLow.price;
   
   // Check if this is a new swing (not already traded)
   bool isNewSwing = (ltf_lastHigh.time != lastSellSwingTime) || 
                     (ltf_lastHigh.price != lastSellSwingPrice);
   
   return (priceAboveHigh && priceAboveLow && isNewSwing);
}

//+------------------------------------------------------------------+
//| New Buy Condition                                                |
//+------------------------------------------------------------------+
bool CheckBuyCondition()
{
   // Need valid LTF swing points
   if(ltf_lastLow.price == 0)
      return false;
   
   // Get current price
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   // Check if price is below last low
   bool priceBelowLow = currentPrice < ltf_lastLow.price;
   
   // Check if this is a new swing (not already traded)
   bool isNewSwing = (ltf_lastLow.time != lastBuySwingTime) || 
                     (ltf_lastLow.price != lastBuySwingPrice);
   
   return (priceBelowLow && isNewSwing);
}

//+------------------------------------------------------------------+
//| Execute trade with CTrade class                                  |
//+------------------------------------------------------------------+
void ExecuteTrade(ENUM_ORDER_TYPE tradeType, string symbol)
{
   // Get current price
   double price = (tradeType == ORDER_TYPE_BUY)
                  ? SymbolInfoDouble(symbol, SYMBOL_ASK)
                  : SymbolInfoDouble(symbol, SYMBOL_BID);
   price = NormalizeDouble(price, _Digits);
   
   // Calculate stop loss
   double sl = CalculateSL(tradeType == ORDER_TYPE_BUY);
   sl = NormalizeDouble(sl, _Digits);
   
   // Calculate take profit based on your requirements
   double tp = 0;
   if(tradeType == ORDER_TYPE_BUY)
   {
      // For Buy: TP at next structure level (last high)
      tp = (ltf_lastHigh.price > 0) ? ltf_lastHigh.price : price + (MathAbs(price - sl) * 2);
   }
   else if(tradeType == ORDER_TYPE_SELL) // ORDER_TYPE_SELL
   {
      // For Sell: TP at last low (as requested)
      tp = (ltf_lastLow.price > 0) ? ltf_lastLow.price : price - (MathAbs(price - sl) * 2);
   }
   tp = NormalizeDouble(tp, _Digits);
   
   // Ensure TP is valid (not too close to entry)
   double minDistance = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE) * 10;
   if(MathAbs(price - tp) < minDistance)
   {
      Print("TP too close to entry, adjusting...");
      if(tradeType == ORDER_TYPE_BUY)
         tp = price + (MathAbs(price - sl) * 2);
      else
         tp = price - (MathAbs(price - sl) * 2);
   }
   
   // Calculate lot size based on risk
   double volume = CalculateLotSize(price, sl);
   
   // Ensure volume is within valid range
   double volume_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double volume_min = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double volume_max = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   
   // Normalize volume to step size
   volume = floor(volume / volume_step) * volume_step;
   volume = MathMax(volume, volume_min);
   volume = MathMin(volume, volume_max);
   
   // Prepare trade comment
   string comment = StringFormat("MS_%s_%s",
      (tradeType == ORDER_TYPE_BUY) ? "BUY" : "SELL",
      TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES));
   
   // Execute trade using CTrade
   bool success = trade.PositionOpen(symbol, tradeType, volume, price, sl, tp, comment);
   
   if(success)
   {
      // Update swing tracking to avoid multiple entries
      if(tradeType == ORDER_TYPE_BUY)
      {
         lastBuySwingTime = ltf_lastLow.time;
         lastBuySwingPrice = ltf_lastLow.price;
      }
      else
      {
         lastSellSwingTime = ltf_lastHigh.time;
         lastSellSwingPrice = ltf_lastHigh.price;
      }
      
      Print(StringFormat("Trade Opened: %s | Price: %.5f | SL: %.5f | TP: %.5f | Lots: %.2f",
         (tradeType == ORDER_TYPE_BUY) ? "BUY" : "SELL",
         price, sl, tp, volume));
   }
   else
   {
      Print("Trade failed: ", trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| Try Execute Trade                                                |
//+------------------------------------------------------------------+
void TryExecuteTrade()
{
   // Check if position already exists
   if(PositionSelect(_Symbol)) 
   {
      Print("Position already exists, waiting for closure...");
      return;
   }
   
   // For Sell positions: Price above both last high and last low
   if(CheckSellCondition())
   {
      // Optional: Check HTF bias filter
      if(htfBias == STRUCT_BEARISH || htfBias == STRUCT_NEUTRAL)
      {
         Print("SELL condition met: Price above LTF high and low");
         OpenSell();
         return;
      }
   }
   
   // For Buy positions: Price below last low
   if(CheckBuyCondition())
   {
      // Optional: Check HTF bias filter
      if(htfBias == STRUCT_BULLISH || htfBias == STRUCT_NEUTRAL)
      {
         Print("BUY condition met: Price below LTF low");
         OpenBuy();
         return;
      }
   }
}

//+------------------------------------------------------------------+
//| Open Buy Position                                                |
//+------------------------------------------------------------------+
void OpenBuy()
{
   ExecuteTrade(ORDER_TYPE_BUY, _Symbol);
}

//+------------------------------------------------------------------+
//| Open Sell Position                                               |
//+------------------------------------------------------------------+
void OpenSell()
{
   ExecuteTrade(ORDER_TYPE_SELL, _Symbol);
}

//+------------------------------------------------------------------+
//| Calculate Stop Loss                                              |
//+------------------------------------------------------------------+
double CalculateSL(bool buy)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(buy)
   {
      // For Buy: SL below the last low with a small buffer
      double curr_prc = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
      double sl_dist = Stop_Loss * point;
      double sl = curr_prc - sl_dist;

      double buffer = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE) * 5;
      return NormalizeDouble(sl - buffer, _Digits);
   }
   else
   {
      // For Sell: SL above the last high with a small buffer
      double curr_prc = SymbolInfoDouble(_Symbol, SYMBOL_BID);

      double sl_dist = Stop_Loss * point;
      double sl = curr_prc + sl_dist;
            
      double buffer = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE) * 5;
      return NormalizeDouble(sl + buffer, _Digits);
   }
}

//+------------------------------------------------------------------+
//| Calculate Lot Size Based on Risk                                 |
//+------------------------------------------------------------------+
double CalculateLotSize(double entry, double sl)
{
   double riskAmount = AccountInfoDouble(ACCOUNT_BALANCE) * (RiskPercent / 100.0);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   if(tickValue == 0 || pointValue == 0) return 0.01;
   
   double riskPoints = MathAbs(entry - sl) / pointValue;
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   double lots = riskAmount / (riskPoints * tickValue * pointValue / tickSize);
   lots = MathFloor(lots / lotStep) * lotStep;
   
   return MathMax(lots, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
}

//+------------------------------------------------------------------+
//| Check Structure Break                                            |
//+------------------------------------------------------------------+
void CheckStructureBreak()
{
   MqlRates current[];
   ArraySetAsSeries(current, true);
   CopyRates(_Symbol, LTF, 0, 1, current);
   
   if(ArraySize(current) < 1) return;
   
   // Bullish structure break
   if(ltfStructure == STRUCT_BULLISH && current[0].close < ltf_lastLow.price)
   {
      ResetLTFStructure();
   }
   
   // Bearish structure break
   if(ltfStructure == STRUCT_BEARISH && current[0].close > ltf_lastHigh.price)
   {
      ResetLTFStructure();
   }
}

//+------------------------------------------------------------------+
//| Reset LTF Structure                                              |
//+------------------------------------------------------------------+
void ResetLTFStructure()
{
   ltf_lastHigh.Reset();
   ltf_prevHigh.Reset();
   ltf_lastLow.Reset();
   ltf_prevLow.Reset();
   ltfStructure = STRUCT_NEUTRAL;
   
   // Also reset trade tracking
   lastBuySwingTime = 0;
   lastSellSwingTime = 0;
   lastBuySwingPrice = 0;
   lastSellSwingPrice = 0;
}

//+------------------------------------------------------------------+
//| Update Visualization                                             |
//+------------------------------------------------------------------+
void UpdateVisualization()
{
   ObjectsDeleteAll(0, "MS_");
   
   // Draw HTF swing points
   if(htf_lastHigh.price > 0)
      DrawSwingPoint(htf_lastHigh, "HTF_High", clrRed, HTF);
   
   if(htf_prevHigh.price > 0)
      DrawSwingPoint(htf_prevHigh, "HTF_PrevHigh", clrRed, HTF);
   
   if(htf_lastLow.price > 0)
      DrawSwingPoint(htf_lastLow, "HTF_Low", clrBlue, HTF);
   
   if(htf_prevLow.price > 0)
      DrawSwingPoint(htf_prevLow, "HTF_PrevLow", clrBlue, HTF);
   
   // Draw LTF swing points
   if(ltf_lastHigh.price > 0)
      DrawSwingPoint(ltf_lastHigh, "LTF_High", clrOrange, LTF);
   
   if(ltf_prevHigh.price > 0)
      DrawSwingPoint(ltf_prevHigh, "LTF_PrevHigh", clrOrange, LTF);
   
   if(ltf_lastLow.price > 0)
      DrawSwingPoint(ltf_lastLow, "LTF_Low", clrGreen, LTF);
   
   if(ltf_prevLow.price > 0)
      DrawSwingPoint(ltf_prevLow, "LTF_PrevLow", clrGreen, LTF);
   
   // Draw current price lines for reference
   double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   CreateHorizontalLine("Current_Bid", currentBid, clrYellow, STYLE_DASH);
   CreateHorizontalLine("Current_Ask", currentAsk, clrYellow, STYLE_DASH);
   
   // Draw trade condition zones
   if(ltf_lastHigh.price > 0)
      CreateHorizontalLine("Sell_Zone_Min", ltf_lastHigh.price, clrRed, STYLE_SOLID);
   
   if(ltf_lastLow.price > 0)
   {
      CreateHorizontalLine("Buy_Zone_Max", ltf_lastLow.price, clrBlue, STYLE_SOLID);
      CreateHorizontalLine("Sell_TP_Level", ltf_lastLow.price, clrGreen, STYLE_DOT);
   }
   
   // Draw structure labels
   DrawStructureLabels();
}

//+------------------------------------------------------------------+
//| Draw Swing Point                                                 |
//+------------------------------------------------------------------+
void DrawSwingPoint(SwingPoint &sp, string name, color clr, ENUM_TIMEFRAMES tf)
{
   ObjectCreate(0, "MS_" + name, OBJ_ARROW, 0, sp.time, sp.price);
   ObjectSetInteger(0, "MS_" + name, OBJPROP_ARROWCODE, sp.type == 1 ? 218 : 217);
   ObjectSetInteger(0, "MS_" + name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, "MS_" + name, OBJPROP_WIDTH, 3);
   ObjectSetString(0, "MS_" + name, OBJPROP_TOOLTIP, 
                  StringFormat("%s: %.5f", sp.type == 1 ? "High" : "Low", sp.price));
}

//+------------------------------------------------------------------+
//| Draw Structure Labels                                            |
//+------------------------------------------------------------------+
void DrawStructureLabels()
{
   string biasText = "HTF Bias: ";
   switch(htfBias)
   {
      case STRUCT_BULLISH: biasText += "BULLISH"; break;
      case STRUCT_BEARISH: biasText += "BEARISH"; break;
      default: biasText += "NEUTRAL"; break;
   }
   
   string ltfText = "LTF Structure: ";
   switch(ltfStructure)
   {
      case STRUCT_BULLISH: ltfText += "HH+HL"; break;
      case STRUCT_BEARISH: ltfText += "LL+LH"; break;
      default: ltfText += "NEUTRAL"; break;
   }
   
   // Current trade conditions
   string conditionText = "";
   if(CheckBuyCondition())
      conditionText = "BUY Condition: ACTIVE (Price < LTF Low)";
   else if(CheckSellCondition())
      conditionText = "SELL Condition: ACTIVE (Price > LTF High & Low)";
   else
      conditionText = "No Trade Condition Met";
   
   // Create label objects
   CreateLabel("MS_BiasLabel", biasText, 10, 20, clrDarkOrange);
   CreateLabel("MS_LTFLabel", ltfText, 10, 40, clrDarkOrange);
   CreateLabel("MS_ConditionLabel", conditionText, 10, 60, 
               (CheckBuyCondition() || CheckSellCondition()) ? clrLime : clrGray);
   
   // Display LTF swing prices
   if(ltf_lastHigh.price > 0)
      CreateLabel("MS_LTFHighLabel", StringFormat("LTF High: %.5f", ltf_lastHigh.price), 10, 80, clrOrange);
   
   if(ltf_lastLow.price > 0)
      CreateLabel("MS_LTFLowLabel", StringFormat("LTF Low: %.5f", ltf_lastLow.price), 10, 100, clrGreen);
}

//+------------------------------------------------------------------+
//| Create Text Label                                                |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color clr)
{
   ObjectCreate(0, "MS_" + name, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, "MS_" + name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, "MS_" + name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, "MS_" + name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, "MS_" + name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, "MS_" + name, OBJPROP_FONTSIZE, 10);
}

//+------------------------------------------------------------------+
//| Create Horizontal Line                                           |
//+------------------------------------------------------------------+
void CreateHorizontalLine(string name, double price, color clr, ENUM_LINE_STYLE style)
{
   ObjectCreate(0, "MS_" + name, OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, "MS_" + name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, "MS_" + name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, "MS_" + name, OBJPROP_WIDTH, 1);
}

