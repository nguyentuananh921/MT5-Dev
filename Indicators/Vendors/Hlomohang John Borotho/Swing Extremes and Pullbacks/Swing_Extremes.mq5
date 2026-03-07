//+------------------------------------------------------------------+
//|                                               Swing Extremes.mq5 |
//|                       https://www.mql5.com/en/users/johnhlomohang|
//+------------------------------------------------------------------+
//|                         Swing Extremes and Pullbacks             |
//|           Part 2: Automating the Strategy with an Expert Advisor |
//|                           https://www.mql5.com/en/articles/21135 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/johnhlomohang/"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "Buy Signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_width1  2

#property indicator_label2  "Sell Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_width2  2

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input ENUM_TIMEFRAMES HTF = PERIOD_H1;
input ENUM_TIMEFRAMES LTF = PERIOD_M5;
input int             SwingBars = 3;
input int             ATR_Period      = 14;      // ATR calculation period
input double          ATR_Multiplier  = 1.0;     // How extreme price must move beyond swing
input bool            Visualize = true;

//+------------------------------------------------------------------+
//| Indicator Buffers                                                |
//+------------------------------------------------------------------+
double BuyBuffer[];
double SellBuffer[];

//+------------------------------------------------------------------+
//| Swing Point Structure                                            |
//+------------------------------------------------------------------+
struct SwingPoint
{
   datetime time;
   double   price;
   int      type;   // 1 = High, -1 = Low
   int               barIndex;

   void Reset()
   {
      time = 0;
      price = 0;
      type = 0;
      barIndex =0;
   }
};

//+------------------------------------------------------------------+
//| Market Structure State                                           |
//+------------------------------------------------------------------+
enum STRUCTURE_STATE
{
   STRUCT_NEUTRAL,
   STRUCT_BULLISH,
   STRUCT_BEARISH
};

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
SwingPoint htf_lastHigh, htf_prevHigh;
SwingPoint htf_lastLow,  htf_prevLow;
SwingPoint ltf_lastHigh, ltf_prevHigh;
SwingPoint ltf_lastLow,  ltf_prevLow;

STRUCTURE_STATE htfBias = STRUCT_NEUTRAL;
STRUCTURE_STATE ltfStructure = STRUCT_NEUTRAL;
int atrHandle;
datetime lastBuySwingTime  = 0;
datetime lastSellSwingTime = 0;
double lastBuySwingPrice = 0;
double lastSellSwingPrice = 0;

//+------------------------------------------------------------------+
//| Indicator Init                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   atrHandle = iATR(_Symbol, LTF, ATR_Period);

   SetIndexBuffer(0, BuyBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SellBuffer, INDICATOR_DATA);

   PlotIndexSetInteger(0, PLOT_ARROW, 233); // arrow up
   PlotIndexSetInteger(1, PLOT_ARROW, 234); // arrow down

   ArrayInitialize(BuyBuffer, EMPTY_VALUE);
   ArrayInitialize(SellBuffer, EMPTY_VALUE);

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Indicator Calculation                                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   static datetime lastLtfBar = 0;
   datetime currentLtfBar = iTime(_Symbol, LTF, 0);

   if(currentLtfBar == lastLtfBar)
      return rates_total;

   lastLtfBar = currentLtfBar;

   UpdateHTFStructure();
   UpdateLTFStructure();
   CheckStructureBreak();

   int bar = rates_total - 1;

   BuyBuffer[bar]  = EMPTY_VALUE;
   SellBuffer[bar] = EMPTY_VALUE;

   if(CheckBuyCondition())
      BuyBuffer[bar] = low[bar] - (10 * _Point);

   if(CheckSellCondition())
      SellBuffer[bar] = high[bar] + (10 * _Point);

   if(Visualize)
      UpdateVisualization();

   return rates_total;
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
   // Only allow sells if HTF bias is BEARISH
   if(htfBias != STRUCT_BEARISH)
      return false;

   // Need valid LTF swing points
   if(ltf_lastHigh.price == 0 || ltf_lastLow.price == 0)
      return false;
   
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   double atr = GetCurrentATR();
   if(atr == 0) return false;
   
   bool priceAboveHigh = currentPrice > (ltf_lastHigh.price + atr * ATR_Multiplier);
   bool priceAboveLow  = currentPrice > ltf_lastLow.price;
   
   bool isNewSwing = (ltf_lastHigh.time != lastSellSwingTime) || 
                     (ltf_lastHigh.price != lastSellSwingPrice);
   
   return (priceAboveHigh && priceAboveLow && isNewSwing);
}

//+------------------------------------------------------------------+
//| New Buy Condition                                                |
//+------------------------------------------------------------------+
bool CheckBuyCondition()
{
   // Only allow buys if HTF bias is BULLISH
   if(htfBias != STRUCT_BULLISH)
      return false;

   // Need valid LTF swing point
   if(ltf_lastLow.price == 0)
      return false;
   
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   double atr = GetCurrentATR();
   if(atr == 0) return false;
   
   bool priceBelowLow = currentPrice < (ltf_lastLow.price - atr * ATR_Multiplier);
   
   bool isNewSwing = (ltf_lastLow.time != lastBuySwingTime) || 
                     (ltf_lastLow.price != lastBuySwingPrice);
   
   return (priceBelowLow && isNewSwing);
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
      conditionText = "Potential BUY Condition: ACTIVE (Price < LTF Low)";
   else if(CheckSellCondition())
      conditionText = "Potential SELL Condition: ACTIVE (Price > LTF High & Low)";
   else
      conditionText = "No Anticipated Trade Condition Met";
   
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

//+------------------------------------------------------------------+
//|  Get Current ATR                                                 |
//+------------------------------------------------------------------+
double GetCurrentATR()
{
   double atr[];
   ArraySetAsSeries(atr, true);
   
   if(CopyBuffer(atrHandle, 0, 0, 1, atr) <= 0)
      return 0;
      
   return atr[0];
}