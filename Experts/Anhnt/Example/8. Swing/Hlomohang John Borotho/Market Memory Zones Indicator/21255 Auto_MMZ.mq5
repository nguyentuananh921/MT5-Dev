//+------------------------------------------------------------------+
//|                                                     Auto MMZ.mq5 |
//|                        GIT under Copyright 2025, MetaQuotes Ltd. |
//|                            https://www.mql5.com/en/articles/21255|
//|                     https://www.mql5.com/en/users/johnhlomohang/ |
//+------------------------------------------------------------------+
#property copyright "GIT under Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/johnhlomohang/"
#property version   "1.00"

#include <Trade/Trade.mqh>
#include <Math/Stat/Math.mqh>
CTrade trade;

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input ENUM_TIMEFRAMES HTF = PERIOD_H1;          // Higher Timeframe
input ENUM_TIMEFRAMES LTF = PERIOD_M5;          // Lower Timeframe
input ENUM_TIMEFRAMES ATF = PERIOD_M15;         // Analysis Timeframe (for zones)
input int             SwingBars = 3;            // Bars for swing detection

// Displacement Zone Parameters
input double          Displacement_ATR_Multiplier = 1.8;    // ATR multiplier for displacement
input double          Displacement_Body_Percent = 60.0;     // Minimum body percentage
input double          Displacement_Overlap_Max = 30.0;      // Maximum overlap with previous candle
input double          Displacement_Close_Extreme = 20.0;    // Close near extreme percentage

// Risk Management
input double          RiskPercent = 1.0;        // Risk per trade (%)
input int             StopLoss_Pips = 150;      // Stop Loss in pips
input double          RiskRewardRatio = 2.0;    // Risk/Reward ratio
input bool            UseDynamicSL = true;      // Use zone-based SL
input bool            UseStructureTP = true;    // Use structure for TP

// Trade Management
input int             MaxTradesPerDay = 10;     // Maximum trades per day
input bool            AllowConsecutiveTrades = true;  // Allow multiple trades in same direction
input double          TrailingStop_ATR = 1.5;   // ATR multiple for trailing stop

// Visualization
input bool            ShowZones = true;         // Show zone rectangles
input bool            ShowArrows = true;        // Show entry arrows
input bool            ShowLabels = true;        // Show trade labels
input bool            DebugMode = true;         // Show debug information

//+------------------------------------------------------------------+
//| Zone Structure                                                   |
//+------------------------------------------------------------------+
enum ZONE_TYPE
{
   ZONE_DISPLACEMENT,
   ZONE_STRUCTURE_TRANSITION,
   ZONE_LIQUIDITY_SWEEP
};

struct TradeZone
{
   datetime          time;
   double            high;
   double            low;
   double            mid;
   ZONE_TYPE         type;
   int               direction;      // 1 for bullish, -1 for bearish
   double            atr;            // ATR at time of zone formation
   datetime          expiry;         // Zone expiry time
   bool              active;
   bool              triggered;
   string            symbol;
   ENUM_TIMEFRAMES   tf;
   
   // Constructor to initialize with default values
   TradeZone()
   {
      Reset();
   }
   
   // Reset method
   void Reset()
   {
      time = 0;
      high = 0;
      low = 0;
      mid = 0;
      type = ZONE_DISPLACEMENT;
      direction = 0;
      atr = 0;
      expiry = 0;
      active = false;
      triggered = false;
      symbol = _Symbol;
      tf = PERIOD_CURRENT;
   }
};

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
//| Trade Information Structure                                       |
//+------------------------------------------------------------------+
struct TradeInfo
{
   datetime          entryTime;
   double            entryPrice;
   double            stopLoss;
   double            takeProfit;
   int               direction;
   TradeZone         zone;
   ulong             ticket;
   
   // Constructor
   TradeInfo()
   {
      Reset();
   }
   
   // Reset method
   void Reset()
   {
      entryTime = 0;
      entryPrice = 0;
      stopLoss = 0;
      takeProfit = 0;
      direction = 0;
      ticket = 0;
      zone.Reset();
   }
};

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
#define MAX_ZONES 100

TradeZone zones[MAX_ZONES];
int zoneWriteIndex = 0;     // Points to next slot to overwrite

SwingPoint htf_lastHigh, htf_prevHigh;
SwingPoint htf_lastLow, htf_prevLow;
SwingPoint atf_lastHigh, atf_prevHigh;
SwingPoint atf_lastLow, atf_prevLow;

TradeInfo activeTrades[10];
int activeTradeCount = 0;

datetime lastTradeDay = 0;
int tradesToday = 0;

double currentATR = 0;
int atrHandle = -1;

MqlDateTime today;

//+------------------------------------------------------------------+
//| Safe Zone Insert - Circular Buffer                               |
//+------------------------------------------------------------------+
void AddZone(TradeZone &zone)
{
   zones[zoneWriteIndex] = zone;
   
   if(DebugMode)
      Print("Zone added at index: ", zoneWriteIndex, " Type: ", ZoneTypeToString(zone.type), 
            " Dir: ", zone.direction, " Time: ", TimeToString(zone.time));
   
   zoneWriteIndex++;
   if(zoneWriteIndex >= MAX_ZONES)
   {
      zoneWriteIndex = 0;
      if(DebugMode) Print("Zone buffer wrapped around to index 0");
   }
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize ATR indicator
   atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
   if(atrHandle == INVALID_HANDLE)
   {
      Print("Failed to create ATR indicator");
      return INIT_FAILED;
   }
   
   // Initialize swing points
   htf_lastHigh.Reset();
   htf_prevHigh.Reset();
   htf_lastLow.Reset();
   htf_prevLow.Reset();
   atf_lastHigh.Reset();
   atf_prevHigh.Reset();
   atf_lastLow.Reset();
   atf_prevLow.Reset();
   
   // Initialize zones array
   for(int i = 0; i < MAX_ZONES; i++)
      zones[i].Reset();
   zoneWriteIndex = 0;
   
   // Initialize active trades array
   for(int i = 0; i < ArraySize(activeTrades); i++)
      activeTrades[i].Reset();
   activeTradeCount = 0;
   
   // Initialize trade tracking
   lastTradeDay = 0;
   tradesToday = 0;
   
   // Set magic number for trades
   trade.SetExpertMagicNumber(12345);
   
   Print("EA Initialized. MAX_ZONES: ", MAX_ZONES, " Circular buffer mode active");
   Print("Zone Types: Displacement, Structure Transition, Liquidity Sweep");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(atrHandle != INVALID_HANDLE)
      IndicatorRelease(atrHandle);
   
   ObjectsDeleteAll(0, "ZONE_");
   ObjectsDeleteAll(0, "TRADE_");
   ChartRedraw();
   
   Print("EA Deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Update current ATR
   UpdateATR();
   
   // Check for new bars on analysis timeframe
   static datetime lastAtfBar = 0;
   datetime currentAtfBar = iTime(_Symbol, ATF, 0);
   
   if(currentAtfBar != lastAtfBar)
   {
      lastAtfBar = currentAtfBar;
      
      if(DebugMode) Print("New ATF bar: ", TimeToString(currentAtfBar));
      
      // Update market structure
      UpdateMarketStructure();
      
      // Detect new zones
      DetectDisplacementZones();
      DetectStructureTransitionZones();
      DetectLiquiditySweepZones();
      
      // Clean up expired zones
      CleanupZones();
   }
   
   // Check zone entries on every tick
   CheckZoneEntries();
   
   // Manage open positions
   ManageOpenTrades();
   
   // Update visualization
   if(ShowZones) UpdateVisualization();
}

//+------------------------------------------------------------------+
//| Update Market Structure                                          |
//+------------------------------------------------------------------+
void UpdateMarketStructure()
{
   // Update HTF structure
   UpdateSwingPoints(HTF, htf_lastHigh, htf_prevHigh, htf_lastLow, htf_prevLow);
   
   // Update Analysis TF structure
   UpdateSwingPoints(ATF, atf_lastHigh, atf_prevHigh, atf_lastLow, atf_prevLow);
   
   if(DebugMode && atf_lastHigh.price > 0 && atf_lastLow.price > 0)
   {
      Print("Market Structure - ATF High: ", atf_lastHigh.price, 
            " Low: ", atf_lastLow.price,
            " ATR: ", currentATR);
   }
}

//+------------------------------------------------------------------+
//| Update Swing Points                                              |
//+------------------------------------------------------------------+
void UpdateSwingPoints(ENUM_TIMEFRAMES tf, SwingPoint &lastHigh, SwingPoint &prevHigh,
                       SwingPoint &lastLow, SwingPoint &prevLow)
{
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, tf, 0, SwingBars * 3 + 10, rates);
   
   if(copied < SwingBars * 2 + 1) return;
   
   // Reset previous points
   prevHigh.Reset();
   prevLow.Reset();
   
   // Detect swing highs and lows
   for(int i = SwingBars; i < copied - SwingBars; i++)
   {
      bool isHigh = true;
      bool isLow = true;
      
      // Check if current bar is higher than SwingBars on each side
      for(int j = 1; j <= SwingBars; j++)
      {
         if(rates[i].high <= rates[i-j].high || rates[i].high <= rates[i+j].high)
            isHigh = false;
         
         if(rates[i].low >= rates[i-j].low || rates[i].low >= rates[i+j].low)
            isLow = false;
      }
      
      if(isHigh)
      {
         prevHigh = lastHigh;
         lastHigh.time = rates[i].time;
         lastHigh.price = rates[i].high;
         lastHigh.type = 1;
         lastHigh.barIndex = i;
         
         if(DebugMode) Print("Swing High detected on ", EnumToString(tf), 
                           " at ", TimeToString(lastHigh.time), 
                           " Price: ", lastHigh.price);
      }
      
      if(isLow)
      {
         prevLow = lastLow;
         lastLow.time = rates[i].time;
         lastLow.price = rates[i].low;
         lastLow.type = -1;
         lastLow.barIndex = i;
         
         if(DebugMode) Print("Swing Low detected on ", EnumToString(tf), 
                           " at ", TimeToString(lastLow.time), 
                           " Price: ", lastLow.price);
      }
   }
}

//+------------------------------------------------------------------+
//| Detect Displacement Zones                                        |
//+------------------------------------------------------------------+
void DetectDisplacementZones()
{
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, ATF, 0, 5, rates);
   
   if(copied < 2) return;
   
   // Check latest candle for displacement
   MqlRates candle = rates[0];
   MqlRates prevCandle = rates[1];
   
   // Calculate candle metrics
   double range = candle.high - candle.low;
   if(range <= 0) return;
   
   double body = MathAbs(candle.close - candle.open);
   double bodyPercent = (body / range) * 100;
   
   // Calculate overlap with previous candle
   double overlapHigh = MathMin(candle.high, prevCandle.high);
   double overlapLow = MathMax(candle.low, prevCandle.low);
   double overlap = (overlapHigh > overlapLow) ? overlapHigh - overlapLow : 0;
   double overlapPercent = (overlap / range) * 100;
   
   // Check close near extreme (for bullish or bearish)
   double closeToHigh = candle.high - candle.close;
   double closeToLow = candle.close - candle.low;
   double closePercent;
   
   if(candle.close > candle.open) // Bullish candle
      closePercent = (closeToHigh / range) * 100;
   else // Bearish candle
      closePercent = (closeToLow / range) * 100;
   
   // Debug information
   if(DebugMode)
   {
      Print("Checking displacement - Range: ", range, 
            " ATR*Mult: ", currentATR * Displacement_ATR_Multiplier,
            " Body%: ", bodyPercent, " Req: ", Displacement_Body_Percent,
            " Overlap%: ", overlapPercent, " Max: ", Displacement_Overlap_Max,
            " Close%: ", closePercent, " Max: ", Displacement_Close_Extreme);
   }
   
   // Check displacement conditions
   bool isDisplacement = 
      (range >= currentATR * Displacement_ATR_Multiplier) &&
      (bodyPercent >= Displacement_Body_Percent) &&
      (overlapPercent <= Displacement_Overlap_Max) &&
      (closePercent <= Displacement_Close_Extreme);
   
   if(isDisplacement)
   {
      // Check if similar zone already exists (within last 5 bars)
      bool zoneExists = false;
      for(int i = 0; i < MAX_ZONES; i++)
      {
         if(zones[i].active && zones[i].type == ZONE_DISPLACEMENT &&
            MathAbs(zones[i].time - candle.time) < PeriodSeconds(ATF) * 5)
         {
            zoneExists = true;
            break;
         }
      }
      
      if(!zoneExists)
      {
         // Create displacement zone
         TradeZone zone;
         zone.time = candle.time;
         zone.high = candle.high;
         zone.low = candle.low;
         zone.mid = (zone.high + zone.low) / 2.0;
         zone.type = ZONE_DISPLACEMENT;
         zone.direction = (candle.close > candle.open) ? 1 : -1;
         zone.atr = currentATR;
         zone.expiry = zone.time + (24 * 60 * 60);  // 24 hour expiry
         zone.active = true;
         zone.triggered = false;
         zone.symbol = _Symbol;
         zone.tf = ATF;
         
         // Add to zones array using circular buffer
         AddZone(zone);
         
         Print("Displacement Zone Detected: ", 
               (zone.direction == 1) ? "BULLISH" : "BEARISH",
               " | High: ", zone.high, " Low: ", zone.low,
               " | Time: ", TimeToString(zone.time));
      }
   }
}

//+------------------------------------------------------------------+
//| Detect Structure Transition Zones (CHoCH)                       |
//+------------------------------------------------------------------+
void DetectStructureTransitionZones()
{
   // Check for bullish CHoCH (downtrend to uptrend)
   if(atf_prevHigh.price > 0 && atf_lastHigh.price > atf_prevHigh.price &&
      atf_prevLow.price > 0 && atf_lastLow.price > atf_prevLow.price)
   {
      // Bullish transition - look for last bearish candle before break
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      int startBar = MathMax(0, atf_lastHigh.barIndex - 10);
      int copied = CopyRates(_Symbol, ATF, startBar, 20, rates);
      
      if(DebugMode) Print("Checking Bullish CHoCH - PrevHigh: ", atf_prevHigh.price, 
                        " LastHigh: ", atf_lastHigh.price);
      
      for(int i = 0; i < copied; i++)
      {
         if(rates[i].close < rates[i].open)  // Bearish candle
         {
            CreateStructureTransitionZone(rates[i], 1);
            break;
         }
      }
   }
   
   // Check for bearish CHoCH (uptrend to downtrend)
   if(atf_prevLow.price > 0 && atf_lastLow.price < atf_prevLow.price &&
      atf_prevHigh.price > 0 && atf_lastHigh.price < atf_prevHigh.price)
   {
      // Bearish transition - look for last bullish candle before break
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      int startBar = MathMax(0, atf_lastLow.barIndex - 10);
      int copied = CopyRates(_Symbol, ATF, startBar, 20, rates);
      
      if(DebugMode) Print("Checking Bearish CHoCH - PrevLow: ", atf_prevLow.price, 
                        " LastLow: ", atf_lastLow.price);
      
      for(int i = 0; i < copied; i++)
      {
         if(rates[i].close > rates[i].open)  // Bullish candle
         {
            CreateStructureTransitionZone(rates[i], -1);
            break;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Create Structure Transition Zone                                 |
//+------------------------------------------------------------------+
void CreateStructureTransitionZone(MqlRates &candle, int direction)
{
   // Check if similar zone already exists (within last 5 bars)
   bool zoneExists = false;
   for(int i = 0; i < MAX_ZONES; i++)
   {
      if(zones[i].active && zones[i].type == ZONE_STRUCTURE_TRANSITION &&
         MathAbs(zones[i].time - candle.time) < PeriodSeconds(ATF) * 5)
      {
         zoneExists = true;
         break;
      }
   }
   
   if(!zoneExists)
   {
      TradeZone zone;
      zone.time = candle.time;
      zone.high = candle.high;
      zone.low = candle.low;
      zone.mid = (zone.high + zone.low) / 2.0;
      zone.type = ZONE_STRUCTURE_TRANSITION;
      zone.direction = direction;
      zone.atr = currentATR;
      zone.expiry = zone.time + (12 * 60 * 60);  // 12 hour expiry
      zone.active = true;
      zone.triggered = false;
      zone.symbol = _Symbol;
      zone.tf = ATF;
      
      // Add to zones array using circular buffer
      AddZone(zone);
      
      Print("Structure Transition Zone Detected: ",
            (zone.direction == 1) ? "BULLISH (CHoCH)" : "BEARISH (CHoCH)",
            " | High: ", zone.high, " Low: ", zone.low,
            " | Time: ", TimeToString(zone.time));
   }
}

//+------------------------------------------------------------------+
//| Detect Liquidity Sweep Zones                                     |
//+------------------------------------------------------------------+
void DetectLiquiditySweepZones()
{
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, ATF, 0, 5, rates);
   
   if(copied < 3) return;
   
   // Check for buy-side liquidity sweep (sweep of lows)
   if(atf_lastLow.price > 0 && rates[1].low < atf_lastLow.price)
   {
      // Check if there's a bullish reversal after the sweep
      bool bullishReversal = rates[1].close > rates[1].open || 
                            (rates[0].close > rates[0].open && rates[0].close > rates[1].high);
      
      if(bullishReversal)
      {
         if(DebugMode) Print("Buy-side Liquidity Sweep detected - Swept Low: ", atf_lastLow.price,
                           " Sweep Candle Low: ", rates[1].low);
         
         CreateLiquiditySweepZone(rates[1], 1);  // Bullish reversal
      }
   }
   
   // Check for sell-side liquidity sweep (sweep of highs)
   if(atf_lastHigh.price > 0 && rates[1].high > atf_lastHigh.price)
   {
      // Check if there's a bearish reversal after the sweep
      bool bearishReversal = rates[1].close < rates[1].open || 
                            (rates[0].close < rates[0].open && rates[0].close < rates[1].low);
      
      if(bearishReversal)
      {
         if(DebugMode) Print("Sell-side Liquidity Sweep detected - Swept High: ", atf_lastHigh.price,
                           " Sweep Candle High: ", rates[1].high);
         
         CreateLiquiditySweepZone(rates[1], -1);  // Bearish reversal
      }
   }
}

//+------------------------------------------------------------------+
//| Create Liquidity Sweep Zone                                      |
//+------------------------------------------------------------------+
void CreateLiquiditySweepZone(MqlRates &candle, int direction)
{
   // Check if similar zone already exists (within last 5 bars)
   bool zoneExists = false;
   for(int i = 0; i < MAX_ZONES; i++)
   {
      if(zones[i].active && zones[i].type == ZONE_LIQUIDITY_SWEEP &&
         MathAbs(zones[i].time - candle.time) < PeriodSeconds(ATF) * 5)
      {
         zoneExists = true;
         break;
      }
   }
   
   if(!zoneExists)
   {
      TradeZone zone;
      zone.time = candle.time;
      zone.high = candle.high;
      zone.low = candle.low;
      zone.mid = (zone.high + zone.low) / 2.0;
      zone.type = ZONE_LIQUIDITY_SWEEP;
      zone.direction = direction;
      zone.atr = currentATR;
      zone.expiry = zone.time + (8 * 60 * 60);  // 8 hour expiry
      zone.active = true;
      zone.triggered = false;
      zone.symbol = _Symbol;
      zone.tf = ATF;
      
      // Add to zones array using circular buffer
      AddZone(zone);
      
      Print("Liquidity Sweep Zone Detected: ",
            (zone.direction == 1) ? "BULLISH (Buy-side Sweep)" : "BEARISH (Sell-side Sweep)",
            " | High: ", zone.high, " Low: ", zone.low,
            " | Time: ", TimeToString(zone.time));
   }
}

//+------------------------------------------------------------------+
//| Check Zone Entries                                               |
//+------------------------------------------------------------------+
void CheckZoneEntries()
{
   // Reset daily trade count if new day
   TimeToStruct(TimeCurrent(), today);
   if(lastTradeDay != today.day)
   {
      tradesToday = 0;
      lastTradeDay = today.day;
      if(DebugMode) Print("New day started. Trade counter reset.");
   }
   
   // Check if we can take more trades today
   if(MaxTradesPerDay > 0 && tradesToday >= MaxTradesPerDay)
   {
      if(tradesToday == MaxTradesPerDay)
         Print("Maximum daily trades (", MaxTradesPerDay, ") reached for today.");
      return;
   }
   
   double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   for(int i = 0; i < MAX_ZONES; i++)
   {
      if(!zones[i].active || zones[i].triggered) continue;
      
      // Check if zone is expired
      if(TimeCurrent() > zones[i].expiry)
      {
         zones[i].active = false;
         continue;
      }
      
      // Check BUY entries (bullish zones)
      if(zones[i].direction == 1)
      {
         // Check if price is returning to zone (using Ask for buys)
         if(currentAsk >= zones[i].low && currentAsk <= zones[i].high)
         {
            // Get LTF confirmation
            if(CheckLTFConfirmation(true))
            {
               Print("BUY Signal: Price in ", ZoneTypeToString(zones[i].type), 
                     " zone | Entry: ", currentAsk, " Zone: [", zones[i].low, "-", zones[i].high, "]");
               ExecuteZoneTrade(true, zones[i], currentAsk);
               zones[i].triggered = true;
               tradesToday++;
               break;  // Take only one trade per tick
            }
         }
      }
      // Check SELL entries (bearish zones)
      else if(zones[i].direction == -1)
      {
         // Check if price is returning to zone (using Bid for sells)
         if(currentBid >= zones[i].low && currentBid <= zones[i].high)
         {
            // Get LTF confirmation
            if(CheckLTFConfirmation(false))
            {
               Print("SELL Signal: Price in ", ZoneTypeToString(zones[i].type), 
                     " zone | Entry: ", currentBid, " Zone: [", zones[i].low, "-", zones[i].high, "]");
               ExecuteZoneTrade(false, zones[i], currentBid);
               zones[i].triggered = true;
               tradesToday++;
               break;  // Take only one trade per tick
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check LTF Confirmation                                           |
//+------------------------------------------------------------------+
bool CheckLTFConfirmation(bool forBuy)
{
   MqlRates ltfRates[];
   ArraySetAsSeries(ltfRates, true);
   int copied = CopyRates(_Symbol, LTF, 0, 5, ltfRates);
   
   if(copied < 3) return false;
   
   // For BUY confirmation
   if(forBuy)
   {
      // Simple confirmation: bullish candle closing above midpoint
      if(ltfRates[0].close > ltfRates[0].open && 
         ltfRates[0].close > ((ltfRates[0].high + ltfRates[0].low) / 2))
      {
         return true;
      }
      
      // Alternative: bullish engulfing
      if(ltfRates[0].close > ltfRates[0].open && 
         ltfRates[0].close > ltfRates[1].high && 
         ltfRates[0].open < ltfRates[1].low)
      {
         return true;
      }
   }
   // For SELL confirmation
   else
   {
      // Simple confirmation: bearish candle closing below midpoint
      if(ltfRates[0].close < ltfRates[0].open && 
         ltfRates[0].close < ((ltfRates[0].high + ltfRates[0].low) / 2))
      {
         return true;
      }
      
      // Alternative: bearish engulfing
      if(ltfRates[0].close < ltfRates[0].open && 
         ltfRates[0].close < ltfRates[1].low && 
         ltfRates[0].open > ltfRates[1].high)
      {
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Execute Zone Trade                                               |
//+------------------------------------------------------------------+
void ExecuteZoneTrade(bool isBuy, TradeZone &zone, double entryPrice)
{
   // Check if position already exists for this symbol
   if(PositionSelect(_Symbol))
   {
      if(!AllowConsecutiveTrades)
      {
         Print("Position already exists and AllowConsecutiveTrades is false, skipping trade");
         return;
      }
   }
   
   ENUM_ORDER_TYPE orderType = isBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   
   // Calculate stop loss
   double stopLoss = CalculateZoneStopLoss(isBuy, zone, entryPrice);
   
   // Calculate take profit
   double takeProfit = CalculateZoneTakeProfit(isBuy, zone, entryPrice, stopLoss);
   
   // Calculate lot size
   double volume = CalculateLotSize(entryPrice, stopLoss);
   
   if(volume <= 0)
   {
      Print("Invalid lot size calculated: ", volume, ". Trade cancelled.");
      return;
   }
   
   // Execute trade
   string comment = StringFormat("%s_%s_%s",
      (isBuy ? "BUY" : "SELL"),
      ZoneTypeToString(zone.type),
      TimeToString(TimeCurrent(), TIME_MINUTES));
   
   bool success = trade.PositionOpen(_Symbol, orderType, volume, 
                                     entryPrice, stopLoss, takeProfit, comment);
   
   if(success)
   {
      ulong ticket = trade.ResultOrder();
      Print("Trade Executed Successfully: ", comment,
            " | Ticket: ", ticket,
            " | Entry: ", entryPrice,
            " | SL: ", stopLoss,
            " | TP: ", takeProfit,
            " | Lots: ", volume);
      
      // Store trade info
      if(activeTradeCount < ArraySize(activeTrades))
      {
         activeTrades[activeTradeCount].entryTime = TimeCurrent();
         activeTrades[activeTradeCount].entryPrice = entryPrice;
         activeTrades[activeTradeCount].stopLoss = stopLoss;
         activeTrades[activeTradeCount].takeProfit = takeProfit;
         activeTrades[activeTradeCount].direction = isBuy ? 1 : -1;
         activeTrades[activeTradeCount].zone = zone;
         activeTrades[activeTradeCount].ticket = ticket;
         activeTradeCount++;
      }
   }
   else
   {
      Print("Trade failed: Error Code=", trade.ResultRetcode(),
            " Description=", trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| Calculate Zone Stop Loss                                         |
//+------------------------------------------------------------------+
double CalculateZoneStopLoss(bool isBuy, TradeZone &zone, double entryPrice)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   if(UseDynamicSL)
   {
      // Zone-based stop loss with buffer
      double buffer = 50 * point;  // 50 pip buffer
      if(isBuy)
      {
         double sl = zone.low - buffer;
         // Ensure SL is below entry
         if(sl >= entryPrice)
            sl = entryPrice - (100 * point);
         return NormalizeDouble(sl, _Digits);
      }
      else
      {
         double sl = zone.high + buffer;
         // Ensure SL is above entry
         if(sl <= entryPrice)
            sl = entryPrice + (100 * point);
         return NormalizeDouble(sl, _Digits);
      }
   }
   else
   {
      // Fixed pip stop loss
      double slDistance = StopLoss_Pips * 10 * point;
      if(isBuy)
         return NormalizeDouble(entryPrice - slDistance, _Digits);
      else
         return NormalizeDouble(entryPrice + slDistance, _Digits);
   }
}

//+------------------------------------------------------------------+
//| Calculate Zone Take Profit                                       |
//+------------------------------------------------------------------+
double CalculateZoneTakeProfit(bool isBuy, TradeZone &zone, double entry, double sl)
{
   double risk = MathAbs(entry - sl);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   if(UseStructureTP)
   {
      if(isBuy)
      {
         // Take profit at next structure high
         double target = entry + (risk * RiskRewardRatio);
         
         if(atf_lastHigh.price > entry)
            target = atf_lastHigh.price;
         else if(htf_lastHigh.price > entry)
            target = htf_lastHigh.price;
         
         // Ensure minimum distance
         double minDistance = 50 * point;
         if(target - entry < minDistance)
            target = entry + (risk * RiskRewardRatio);
         
         return NormalizeDouble(target, _Digits);
      }
      else
      {
         // Take profit at next structure low
         double target = entry - (risk * RiskRewardRatio);
         
         if(atf_lastLow.price < entry)
            target = atf_lastLow.price;
         else if(htf_lastLow.price < entry)
            target = htf_lastLow.price;
         
         // Ensure minimum distance
         double minDistance = 50 * point;
         if(entry - target < minDistance)
            target = entry - (risk * RiskRewardRatio);
         
         return NormalizeDouble(target, _Digits);
      }
   }
   else
   {
      // Fixed risk/reward ratio
      if(isBuy)
         return NormalizeDouble(entry + (risk * RiskRewardRatio), _Digits);
      else
         return NormalizeDouble(entry - (risk * RiskRewardRatio), _Digits);
   }
}

//+------------------------------------------------------------------+
//| Calculate Lot Size                                               |
//+------------------------------------------------------------------+
double CalculateLotSize(double entry, double sl)
{
   double riskAmount = AccountInfoDouble(ACCOUNT_BALANCE) * (RiskPercent / 100.0);
   double riskPoints = MathAbs(entry - sl) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   
   if(tickValue == 0 || tickSize == 0 || riskPoints == 0)
   {
      Print("Warning: Invalid parameters for lot calculation. Using default lot size 0.01");
      return 0.01;
   }
   
   double lotSize = riskAmount / (riskPoints * tickValue * (SymbolInfoDouble(_Symbol, SYMBOL_POINT) / tickSize));
   
   // Normalize to step size
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step > 0)
      lotSize = MathFloor(lotSize / step) * step;
   
   // Ensure within min/max limits
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   
   lotSize = MathMax(lotSize, minLot);
   lotSize = MathMin(lotSize, maxLot);
   
   return lotSize;
}

//+------------------------------------------------------------------+
//| Manage Open Trades                                               |
//+------------------------------------------------------------------+
void ManageOpenTrades()
{
   for(int i = 0; i < activeTradeCount; i++)
   {
      if(PositionSelectByTicket(activeTrades[i].ticket))
      {
         double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double sl = PositionGetDouble(POSITION_SL);
         double tp = PositionGetDouble(POSITION_TP);
         double profit = PositionGetDouble(POSITION_PROFIT);
         
         // Check for trailing stop
         if(TrailingStop_ATR > 0 && currentATR > 0)
         {
            if(activeTrades[i].direction == 1)  // Buy position
            {
               double newSL = currentPrice - (currentATR * TrailingStop_ATR);
               if(newSL > sl && newSL > openPrice)
               {
                  if(trade.PositionModify(activeTrades[i].ticket, newSL, tp))
                  {
                     activeTrades[i].stopLoss = newSL;
                     if(DebugMode) Print("Trailing SL updated for BUY: New SL=", newSL);
                  }
               }
            }
            else  // Sell position
            {
               double newSL = currentPrice + (currentATR * TrailingStop_ATR);
               if(newSL < sl && newSL < openPrice)
               {
                  if(trade.PositionModify(activeTrades[i].ticket, newSL, tp))
                  {
                     activeTrades[i].stopLoss = newSL;
                     if(DebugMode) Print("Trailing SL updated for SELL: New SL=", newSL);
                  }
               }
            }
         }
         
         // Check if trade is closed
         if(!PositionSelectByTicket(activeTrades[i].ticket))
         {
            Print("Position closed: Ticket ", activeTrades[i].ticket, 
                  " Profit: ", profit);
            
            // Remove from active trades
            for(int j = i; j < activeTradeCount - 1; j++)
               activeTrades[j] = activeTrades[j + 1];
            activeTradeCount--;
            i--;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Cleanup Expired Zones                                            |
//+------------------------------------------------------------------+
void CleanupZones()
{
   int expiredCount = 0;
   for(int i = 0; i < MAX_ZONES; i++)
   {
      if(zones[i].active && TimeCurrent() > zones[i].expiry)
      {
         zones[i].active = false;
         expiredCount++;
         if(DebugMode) Print("Zone expired: ", ZoneTypeToString(zones[i].type), 
                           " Time: ", TimeToString(zones[i].time));
      }
   }
   if(expiredCount > 0 && DebugMode) 
      Print("Cleaned up ", expiredCount, " expired zones");
}

//+------------------------------------------------------------------+
//| Update ATR                                                       |
//+------------------------------------------------------------------+
void UpdateATR()
{
   double atrArray[];
   ArraySetAsSeries(atrArray, true);
   
   if(CopyBuffer(atrHandle, 0, 0, 1, atrArray) > 0)
      currentATR = atrArray[0];
}

//+------------------------------------------------------------------+
//| Update Visualization                                             |
//+------------------------------------------------------------------+
void UpdateVisualization()
{
   ObjectsDeleteAll(0, "ZONE_");
   ObjectsDeleteAll(0, "TRADE_");
   
   // Draw zones - scan all MAX_ZONES slots
   int activeZoneCount = 0;
   for(int i = 0; i < MAX_ZONES; i++)
   {
      if(zones[i].active)
      {
         DrawZone(zones[i], i);
         activeZoneCount++;
      }
   }
   
   // Draw structure levels
   if(ShowLabels)
   {
      if(atf_lastHigh.price > 0)
         CreateHorizontalLine("ATF_High", atf_lastHigh.price, clrRed, STYLE_DASH);
      
      if(atf_lastLow.price > 0)
         CreateHorizontalLine("ATF_Low", atf_lastLow.price, clrBlue, STYLE_DASH);
      
      if(htf_lastHigh.price > 0)
         CreateHorizontalLine("HTF_High", htf_lastHigh.price, clrDarkRed, STYLE_DOT);
      
      if(htf_lastLow.price > 0)
         CreateHorizontalLine("HTF_Low", htf_lastLow.price, clrDarkBlue, STYLE_DOT);
   }
   
   // Show zone count and buffer info in corner
   if(ShowLabels)
   {
      string labelText = "Active Zones: " + IntegerToString(activeZoneCount) + 
                        " | Buffer: " + IntegerToString(zoneWriteIndex) + "/" + IntegerToString(MAX_ZONES);
      CreateLabel("ZoneCount", labelText, 10, 180, clrWhite);
      
      // Show buffer utilization
      string bufferText = "Zone Buffer: " + IntegerToString(zoneWriteIndex) + 
                         " | Wraps: " + (zoneWriteIndex >= MAX_ZONES ? "Yes" : "No");
      CreateLabel("BufferInfo", bufferText, 10, 200, clrLightGray);
   }
}

//+------------------------------------------------------------------+
//| Draw Zone                                                        |
//+------------------------------------------------------------------+
void DrawZone(TradeZone &zone, int index)
{
   string name = "ZONE_" + IntegerToString(index);
   
   // Calculate zone width (4 bars forward)
   datetime endTime = zone.time + (PeriodSeconds(zone.tf) * 4);
   
   // Draw rectangle
   if(ObjectCreate(0, name, OBJ_RECTANGLE, 0, zone.time, zone.high, endTime, zone.low))
   {
      // Set color based on zone type and direction
      color zoneColor;
      int zoneStyle = STYLE_SOLID;
      
      switch(zone.type)
      {
         case ZONE_DISPLACEMENT:
            zoneColor = (zone.direction == 1) ? clrLimeGreen : clrIndianRed;
            zoneStyle = STYLE_SOLID;
            break;
         case ZONE_STRUCTURE_TRANSITION:
            zoneColor = (zone.direction == 1) ? clrDodgerBlue : clrOrangeRed;
            zoneStyle = STYLE_DASH;
            break;
         case ZONE_LIQUIDITY_SWEEP:
            zoneColor = (zone.direction == 1) ? clrGold : clrMagenta;
            zoneStyle = STYLE_DOT;
            break;
         default:
            zoneColor = clrGray;
      }
      
      ObjectSetInteger(0, name, OBJPROP_COLOR, zoneColor);
      ObjectSetInteger(0, name, OBJPROP_STYLE, zoneStyle);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
      
      // Add label
      if(ShowLabels)
      {
         string labelName = name + "_LABEL";
         if(ObjectCreate(0, labelName, OBJ_TEXT, 0, zone.time, zone.high))
         {
            string typeText;
            switch(zone.type)
            {
               case ZONE_DISPLACEMENT: typeText = "DISP"; break;
               case ZONE_STRUCTURE_TRANSITION: typeText = "CHoCH"; break;
               case ZONE_LIQUIDITY_SWEEP: typeText = "LIQ"; break;
               default: typeText = "UNK";
            }
            
            string directionText = (zone.direction == 1) ? "BULL" : "BEAR";
            ObjectSetString(0, labelName, OBJPROP_TEXT, typeText + " " + directionText);
            ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrWhite);
            ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
            ObjectSetInteger(0, labelName, OBJPROP_BACK, true);
         }
      }
      
      if(DebugMode && ShowZones)
         Print("Drawing zone: ", name, " Type: ", ZoneTypeToString(zone.type), 
               " Dir: ", zone.direction, " High: ", zone.high, " Low: ", zone.low);
   }
}

//+------------------------------------------------------------------+
//| Helper Functions                                                 |
//+------------------------------------------------------------------+
string ZoneTypeToString(ZONE_TYPE type)
{
   switch(type)
   {
      case ZONE_DISPLACEMENT: return "Displacement";
      case ZONE_STRUCTURE_TRANSITION: return "Structure Transition";
      case ZONE_LIQUIDITY_SWEEP: return "Liquidity Sweep";
      default: return "Unknown";
   }
}

void CreateHorizontalLine(string name, double price, color clr, ENUM_LINE_STYLE style)
{
   if(ObjectCreate(0, name, OBJ_HLINE, 0, 0, price))
   {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE, style);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
   }
}

void CreateLabel(string name, string text, int x, int y, color clr)
{
   if(ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
   {
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   }
}