//+------------------------------------------------------------------+
//|                                           AdaptiveLiquidityLifecycleTrader.mq5 |
//|                                                      Copyright 2026, Clemence Benjamin |
//|                                         https://www.mql5.com     |
//+------------------------------------------------------------------+
#property copyright "Clemence Benjamin"
#property version   "1.21"
#property strict

#include <Trade/Trade.mqh>

CTrade trade;

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
//--- Zone detection (higher timeframe)
input ENUM_TIMEFRAMES ZoneTimeframe   = PERIOD_H1;      // Timeframe for zone detection
input int             LookbackBars    = 500;            // Number of HTF bars to scan
input double          RatioMultiplier = 3.0;            // Impulse-to-base ratio
input int             ExtendBars      = 50;             // How many HTF bars to extend zone to the right

//--- Visual (optional)
input color           DemandZoneColor = clrLimeGreen;
input color           SupplyZoneColor = clrTomato;
input uchar           ZoneOpacity     = 40;             // 0-255 transparency
input bool            FillRectangles  = true;

//--- Risk management
input double          RiskPercent         = 1.0;        // % of account balance per trade
input double          StopBufferFactor    = 0.2;        // Stop buffer = zoneHeight * StopBufferFactor
input double          MinZoneHeightPoints = 10;         // Minimum zone height in points
input double          MaxZoneHeightPoints = 100;        // Maximum zone height in points
input bool            UseATRNormalization = true;       // Filter weak zones (zoneHeight < 0.5*ATR)
input int             ATRPeriod           = 14;

//--- Entry settings
input bool            AllowBuy            = true;
input bool            AllowSell           = true;
input int             MaxSpreadPoints     = 30;         // Max allowed spread
input double          RiskReward          = 2.0;        // TP = SL * RiskReward
input int             PendingExpiryHours  = 48;         // Pending order lifetime (hours)

//--- Reversal patterns (for flipped zones)
input bool            UseEngulfing        = true;
input bool            UsePinBar           = true;
input bool            UseInsideBreak      = true;

//--- Zone flipping
input bool            EnableZoneFlipping  = true;
input double          ViolationMultiplier = 1.5;        // Impulsive bar must be >= zoneHeight * ViolationMultiplier

//--- Position sizing for flipped zones
input double          FlipRiskPercent     = 0.5;        // Reduced risk for flipped entries

//--- EA behaviour
input ulong           MagicNumber         = 777333;

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
struct LiquidityZone
  {
   double            high;            // zone top
   double            low;             // zone bottom
   datetime          start_time;      // bar time when formed
   datetime          expiry_time;     // start + ExtendBars * HTF period
   bool              demand;          // true = demand, false = supply
   bool              triggered;       // true if pending order placed
   bool              flipped;         // has been flipped
   ulong             orderTicket;     // ticket of pending order (0 if none)
  };

LiquidityZone zones[];       // dynamic array of active zones
datetime lastHtfUpdateTime = 0;
datetime lastBarTime = 0;

double point;                // point value (adjusted for 5/3 digits)

int atrHandle = INVALID_HANDLE;   // handle for ATR indicator

//+------------------------------------------------------------------+
//| Returns period in seconds                                        |
//+------------------------------------------------------------------+
int GetPeriodSeconds(ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1:
         return(60);
      case PERIOD_M5:
         return(300);
      case PERIOD_M15:
         return(900);
      case PERIOD_M30:
         return(1800);
      case PERIOD_H1:
         return(3600);
      case PERIOD_H4:
         return(14400);
      case PERIOD_D1:
         return(86400);
      case PERIOD_W1:
         return(604800);
      case PERIOD_MN1:
         return(2592000);
      default:
         return(3600);
     }
  }

//+------------------------------------------------------------------+
//| Deletes all drawn zone rectangles                                |
//+------------------------------------------------------------------+
void DeleteAllZones()
  {
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, "LiqZone_") == 0)
         ObjectDelete(0, name);
     }
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Draws a liquidity zone rectangle on chart                        |
//+------------------------------------------------------------------+
void DrawZone(datetime start_time, datetime expiry_time, double price_top, double price_bottom, bool isDemand)
  {
   string obj_name = "LiqZone_" + IntegerToString(start_time) + "_" + IntegerToString(expiry_time);
   if(ObjectFind(0, obj_name) >= 0)
      ObjectDelete(0, obj_name);

   color zone_color = isDemand ? DemandZoneColor : SupplyZoneColor;

   if(ObjectCreate(0, obj_name, OBJ_RECTANGLE, 0,
                   start_time, price_top, expiry_time, price_bottom))
     {
      ObjectSetInteger(0, obj_name, OBJPROP_COLOR, zone_color);
      ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, obj_name, OBJPROP_FILL, FillRectangles);
      ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
      ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);

      if(FillRectangles)
        {
         color fill_clr = (color)ColorToARGB(zone_color, ZoneOpacity);
         ObjectSetInteger(0, obj_name, OBJPROP_BGCOLOR, fill_clr);
        }
     }
  }

//+------------------------------------------------------------------+
//| Cancels pending order associated with a zone                     |
//+------------------------------------------------------------------+
void CancelZoneOrder(int idx)
  {
   if(idx < 0 || idx >= ArraySize(zones))
      return;
   if(zones[idx].orderTicket != 0)
     {
      trade.OrderDelete(zones[idx].orderTicket);
      zones[idx].orderTicket = 0;
     }
  }

//+------------------------------------------------------------------+
//| Places pending order at zone boundary                            |
//+------------------------------------------------------------------+
void PlaceZonePendingOrders(int idx)
  {
   if(idx < 0 || idx >= ArraySize(zones))
      return;
   if(zones[idx].triggered)
      return;

   double zoneHeight = zones[idx].high - zones[idx].low;

//--- Filter by min/max zone height
   double minHeight = MinZoneHeightPoints * point;
   double maxHeight = MaxZoneHeightPoints * point;
   if(zoneHeight < minHeight || zoneHeight > maxHeight)
      return;

//--- ATR filter
   if(UseATRNormalization)
     {
      double atr = GetATR(1);
      if(atr > 0 && zoneHeight < 0.5 * atr)
         return;
     }

   bool isBuy = zones[idx].demand;

   if(isBuy && !AllowBuy)
      return;
   if(!isBuy && !AllowSell)
      return;

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double entryPrice = isBuy ? zones[idx].low : zones[idx].high;
   entryPrice = NormalizeDouble(entryPrice, _Digits);
   double stopLoss = NormalizeDouble(GetStopDistance(zones[idx], isBuy), _Digits);
   double stopDist = MathAbs(entryPrice - stopLoss);
   double tp = isBuy ? entryPrice + stopDist * RiskReward : entryPrice - stopDist * RiskReward;
   tp = NormalizeDouble(tp, _Digits);
   datetime expiry = TimeCurrent() + PendingExpiryHours * 3600;  // Order expires after specified hours

//--- Ensure limit order is on correct side of current price
   if(isBuy && entryPrice >= ask)
      return;
   if(!isBuy && entryPrice <= bid)
      return;

   double lot = ComputeLotSize(stopDist, zones[idx].flipped ? FlipRiskPercent : RiskPercent);
   if(lot <= 0)
      return;

   trade.SetExpertMagicNumber(MagicNumber);
   bool success = false;
   if(isBuy)
      success = trade.BuyLimit(lot, entryPrice, _Symbol, stopLoss, tp, ORDER_TIME_SPECIFIED, expiry, "LiqZone_Pending");
   else
      success = trade.SellLimit(lot, entryPrice, _Symbol, stopLoss, tp, ORDER_TIME_SPECIFIED, expiry, "LiqZone_Pending");

   if(success)
     {
      zones[idx].triggered = true;
      // Store the ticket of the placed order
      ulong ticket = trade.ResultOrder();
      if(ticket != 0)
         zones[idx].orderTicket = ticket;
      else
         zones[idx].orderTicket = 1; // fallback
     }
  }

//+------------------------------------------------------------------+
//| Scans higher timeframe for new supply/demand zones               |
//+------------------------------------------------------------------+
void UpdateZones()
  {
//--- Copy HTF data
   double htf_open[], htf_close[], htf_high[], htf_low[];
   datetime htf_time[];
   int htf_bars = CopyOpen(Symbol(), ZoneTimeframe, 0, LookbackBars, htf_open);
   if(htf_bars <= 0)
      return;
   CopyClose(Symbol(), ZoneTimeframe, 0, LookbackBars, htf_close);
   CopyHigh(Symbol(), ZoneTimeframe, 0, LookbackBars, htf_high);
   CopyLow(Symbol(), ZoneTimeframe, 0, LookbackBars, htf_low);
   CopyTime(Symbol(), ZoneTimeframe, 0, LookbackBars, htf_time);

//--- Series order (index 0 = most recent)
   ArraySetAsSeries(htf_open, true);
   ArraySetAsSeries(htf_close, true);
   ArraySetAsSeries(htf_high, true);
   ArraySetAsSeries(htf_low, true);
   ArraySetAsSeries(htf_time, true);

   int htfPeriodSec = GetPeriodSeconds(ZoneTimeframe);

//--- Scan for patterns
   for(int i = 2; i < htf_bars - 2; i++)
     {
      int base_idx = i + 2;
      int impulse_idx = i + 1;

      if(base_idx >= htf_bars)
         continue;

      double base_range = htf_high[base_idx] - htf_low[base_idx];
      double impulse_range = htf_high[impulse_idx] - htf_low[impulse_idx];

      if(base_range <= 0)
         continue;

      // Demand zone
      if(htf_open[base_idx] < htf_close[base_idx] &&
         htf_open[impulse_idx] < htf_close[impulse_idx] &&
         impulse_range >= base_range * RatioMultiplier)
        {
         // Check duplicate
         bool exists = false;
         for(int j = 0; j < ArraySize(zones); j++)
            if(zones[j].start_time == htf_time[base_idx])
              { exists = true; break; }

         if(!exists)
           {
            LiquidityZone z;
            z.high = htf_high[base_idx];
            z.low  = htf_low[base_idx];
            z.start_time = htf_time[base_idx];
            z.expiry_time = z.start_time + ExtendBars * htfPeriodSec;
            z.demand = true;
            z.triggered = false;
            z.flipped = false;
            z.orderTicket = 0;

            int size = ArraySize(zones);
            ArrayResize(zones, size + 1);
            zones[size] = z;

            DrawZone(z.start_time, z.expiry_time, z.high, z.low, true);
            PlaceZonePendingOrders(size);   // Immediately place order
           }
        }

      // Supply zone
      if(htf_open[base_idx] > htf_close[base_idx] &&
         htf_open[impulse_idx] > htf_close[impulse_idx] &&
         impulse_range >= base_range * RatioMultiplier)
        {
         bool exists = false;
         for(int j = 0; j < ArraySize(zones); j++)
            if(zones[j].start_time == htf_time[base_idx])
              { exists = true; break; }

         if(!exists)
           {
            LiquidityZone z;
            z.high = htf_high[base_idx];
            z.low  = htf_low[base_idx];
            z.start_time = htf_time[base_idx];
            z.expiry_time = z.start_time + ExtendBars * htfPeriodSec;
            z.demand = false;
            z.triggered = false;
            z.flipped = false;
            z.orderTicket = 0;

            int size = ArraySize(zones);
            ArrayResize(zones, size + 1);
            zones[size] = z;

            DrawZone(z.start_time, z.expiry_time, z.high, z.low, false);
            PlaceZonePendingOrders(size);   // Immediately place order
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Removes zones that have expired and their pending orders         |
//+------------------------------------------------------------------+
void RemoveExpiredZones()
  {
   datetime current_time = TimeCurrent();
   for(int i = ArraySize(zones) - 1; i >= 0; i--)
     {
      if(current_time > zones[i].expiry_time)
        {
         // Delete pending order
         CancelZoneOrder(i);
         // Delete rectangle
         string obj_name = "LiqZone_" + IntegerToString(zones[i].start_time) + "_" + IntegerToString(zones[i].expiry_time);
         ObjectDelete(0, obj_name);
         // Remove from array
         for(int j = i; j < ArraySize(zones) - 1; j++)
            zones[j] = zones[j+1];
         ArrayResize(zones, ArraySize(zones) - 1);
        }
     }
  }

//+------------------------------------------------------------------+
//| Flips a zone's role (demand<->supply) after violation            |
//+------------------------------------------------------------------+
void FlipZone(int idx, bool newDemand, datetime violation_time)
  {
   if(idx < 0 || idx >= ArraySize(zones))
      return;

//--- Cancel existing order
   CancelZoneOrder(idx);

//--- Delete old rectangle
   string obj_name = "LiqZone_" + IntegerToString(zones[idx].start_time) + "_" + IntegerToString(zones[idx].expiry_time);
   ObjectDelete(0, obj_name);

//--- Update properties
   zones[idx].demand = newDemand;
   zones[idx].expiry_time = violation_time + ExtendBars * GetPeriodSeconds(ZoneTimeframe);
   zones[idx].triggered = false;   // allow new signal
   zones[idx].flipped = true;
   zones[idx].orderTicket = 0;

//--- Redraw
   DrawZone(zones[idx].start_time, zones[idx].expiry_time, zones[idx].high, zones[idx].low, newDemand);

//--- Place new pending order for flipped zone
   PlaceZonePendingOrders(idx);
  }

//+------------------------------------------------------------------+
//| Checks for impulsive price action that violates a zone           |
//+------------------------------------------------------------------+
void CheckFlipConditions()
  {
   if(!EnableZoneFlipping)
      return;

//--- Get latest closed bar data
   double high1 = iHigh(Symbol(), PERIOD_CURRENT, 1);
   double low1  = iLow(Symbol(), PERIOD_CURRENT, 1);
   double close1 = iClose(Symbol(), PERIOD_CURRENT, 1);
   double open1 = iOpen(Symbol(), PERIOD_CURRENT, 1);
   double range1 = high1 - low1;

   for(int i = 0; i < ArraySize(zones); i++)
     {
      if(TimeCurrent() > zones[i].expiry_time)
         continue;

      double zoneHeight = zones[i].high - zones[i].low;
      if(zoneHeight <= 0)
         continue;

      // Supply violated to upside -> flip to demand
      if(!zones[i].demand && close1 > zones[i].high &&
         close1 > open1 && range1 >= zoneHeight * ViolationMultiplier)
        {
         FlipZone(i, true, TimeCurrent());
         break;
        }
      // Demand violated to downside -> flip to supply
      else
         if(zones[i].demand && close1 < zones[i].low &&
            close1 < open1 && range1 >= zoneHeight * ViolationMultiplier)
           {
            FlipZone(i, false, TimeCurrent());
            break;
           }
     }
  }

//+------------------------------------------------------------------+
//| Checks for Bullish Engulfing pattern                             |
//+------------------------------------------------------------------+
bool BullishEngulfing(int bar)
  {
   if(!UseEngulfing)
      return(false);
   double open1  = iOpen(Symbol(), PERIOD_CURRENT, bar);
   double close1 = iClose(Symbol(), PERIOD_CURRENT, bar);
   double open2  = iOpen(Symbol(), PERIOD_CURRENT, bar+1);
   double close2 = iClose(Symbol(), PERIOD_CURRENT, bar+1);
   return(close1 > open1 && close2 < open2 &&
          close1 > open2 && open1 < close2);
  }

//+------------------------------------------------------------------+
//| Checks for Bearish Engulfing pattern                             |
//+------------------------------------------------------------------+
bool BearishEngulfing(int bar)
  {
   if(!UseEngulfing)
      return(false);
   double open1  = iOpen(Symbol(), PERIOD_CURRENT, bar);
   double close1 = iClose(Symbol(), PERIOD_CURRENT, bar);
   double open2  = iOpen(Symbol(), PERIOD_CURRENT, bar+1);
   double close2 = iClose(Symbol(), PERIOD_CURRENT, bar+1);
   return(close1 < open1 && close2 > open2 &&
          open1 > close2 && close1 < open2);
  }

//+------------------------------------------------------------------+
//| Checks for Bullish Pin Bar pattern                               |
//+------------------------------------------------------------------+
bool BullishPinBar(int bar)
  {
   if(!UsePinBar)
      return(false);
   double open1  = iOpen(Symbol(), PERIOD_CURRENT, bar);
   double close1 = iClose(Symbol(), PERIOD_CURRENT, bar);
   double low1   = iLow(Symbol(), PERIOD_CURRENT, bar);
   double body = MathAbs(close1 - open1);
   double lower_wick = MathMin(open1, close1) - low1;
   return(lower_wick > body * 2);
  }

//+------------------------------------------------------------------+
//| Checks for Bearish Pin Bar pattern                               |
//+------------------------------------------------------------------+
bool BearishPinBar(int bar)
  {
   if(!UsePinBar)
      return(false);
   double open1  = iOpen(Symbol(), PERIOD_CURRENT, bar);
   double close1 = iClose(Symbol(), PERIOD_CURRENT, bar);
   double high1  = iHigh(Symbol(), PERIOD_CURRENT, bar);
   double body = MathAbs(close1 - open1);
   double upper_wick = high1 - MathMax(open1, close1);
   return(upper_wick > body * 2);
  }

//+------------------------------------------------------------------+
//| Checks for Bullish Inside Break pattern                          |
//+------------------------------------------------------------------+
bool BullishInsideBreak(int bar)
  {
   if(!UseInsideBreak)
      return(false);
   double high1 = iHigh(Symbol(), PERIOD_CURRENT, bar);
   double low1  = iLow(Symbol(), PERIOD_CURRENT, bar);
   double high2 = iHigh(Symbol(), PERIOD_CURRENT, bar+1);
   double low2  = iLow(Symbol(), PERIOD_CURRENT, bar+1);
   double close1 = iClose(Symbol(), PERIOD_CURRENT, bar);
   return(high1 < high2 && low1 > low2 && close1 > high2);
  }

//+------------------------------------------------------------------+
//| Checks for Bearish Inside Break pattern                          |
//+------------------------------------------------------------------+
bool BearishInsideBreak(int bar)
  {
   if(!UseInsideBreak)
      return(false);
   double high1 = iHigh(Symbol(), PERIOD_CURRENT, bar);
   double low1  = iLow(Symbol(), PERIOD_CURRENT, bar);
   double high2 = iHigh(Symbol(), PERIOD_CURRENT, bar+1);
   double low2  = iLow(Symbol(), PERIOD_CURRENT, bar+1);
   double close1 = iClose(Symbol(), PERIOD_CURRENT, bar);
   return(high1 < high2 && low1 > low2 && close1 < low2);
  }

//+------------------------------------------------------------------+
//| Combines reversal patterns for demand zone entries               |
//+------------------------------------------------------------------+
bool DemandReversal(int bar)
  {
   return(BullishEngulfing(bar) || BullishPinBar(bar) || BullishInsideBreak(bar));
  }

//+------------------------------------------------------------------+
//| Combines reversal patterns for supply zone entries               |
//+------------------------------------------------------------------+
bool SupplyReversal(int bar)
  {
   return(BearishEngulfing(bar) || BearishPinBar(bar) || BearishInsideBreak(bar));
  }

//+------------------------------------------------------------------+
//| Checks if a bar's price range is inside a zone                   |
//+------------------------------------------------------------------+
bool PriceInsideZone(int bar, const LiquidityZone &z)
  {
   double highBar = iHigh(Symbol(), PERIOD_CURRENT, bar);
   double lowBar  = iLow(Symbol(), PERIOD_CURRENT, bar);
   return(highBar >= z.low && lowBar <= z.high);
  }

//+------------------------------------------------------------------+
//| Computes stop loss distance for zone-based trade                 |
//+------------------------------------------------------------------+
double GetStopDistance(const LiquidityZone &z, bool isBuy)
  {
   double zoneHeight = z.high - z.low;
   double buffer = zoneHeight * StopBufferFactor;
   if(isBuy)
      return(z.low - buffer);   // stop below zone
   else
      return(z.high + buffer);  // stop above zone
  }

//+------------------------------------------------------------------+
//| Calculates lot size based on risk percent and stop distance      |
//+------------------------------------------------------------------+
double ComputeLotSize(double stopDistance, double riskPercent)
  {
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = accountBalance * (riskPercent / 100.0);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double pointsPerStop = stopDistance / tickSize;
   double riskPerLot = pointsPerStop * tickValue;
   if(riskPerLot <= 0)
      return(0);
   double lot = riskAmount / riskPerLot;
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   lot = MathMax(minLot, MathMin(maxLot, lot));
   return(NormalizeDouble(lot, 2));
  }

//+------------------------------------------------------------------+
//| Returns ATR value for given shift                                |
//+------------------------------------------------------------------+
double GetATR(int shift)
  {
   if(atrHandle == INVALID_HANDLE)
      return(0);
   double atrVal[1];
   if(CopyBuffer(atrHandle, 0, shift, 1, atrVal) != 1)
      return(0);
   return(atrVal[0]);
  }

//+------------------------------------------------------------------+
//| Places market entry for flipped zone on pullback confirmation    |
//+------------------------------------------------------------------+
void PlaceFlippedZoneEntry(int idx)
  {
   if(idx < 0 || idx >= ArraySize(zones))
      return;
   if(!zones[idx].flipped)
      return;
   if(zones[idx].triggered)
      return;

   bool isBuy = zones[idx].demand;
   double currentClose = iClose(_Symbol, PERIOD_CURRENT, 1);

//--- Price must be inside the zone (pullback)
   if(isBuy && currentClose >= zones[idx].low && currentClose <= zones[idx].high)
     {
      if(DemandReversal(1))
        {
         double stopLoss = zones[idx].low - (zones[idx].high - zones[idx].low) * StopBufferFactor;
         double takeProfit = currentClose + (currentClose - stopLoss) * RiskReward;
         double stopDistance = MathAbs(currentClose - stopLoss);
         double lot = ComputeLotSize(stopDistance, FlipRiskPercent);
         if(lot > 0)
           {
            trade.SetExpertMagicNumber(MagicNumber);
            trade.Buy(lot, _Symbol, 0, stopLoss, takeProfit, "LiqZone_Flipped");
            zones[idx].triggered = true;
           }
        }
     }
   else
      if(!isBuy && currentClose >= zones[idx].low && currentClose <= zones[idx].high)
        {
         if(SupplyReversal(1))
           {
            double stopLoss = zones[idx].high + (zones[idx].high - zones[idx].low) * StopBufferFactor;
            double takeProfit = currentClose - (stopLoss - currentClose) * RiskReward;
            double stopDistance = MathAbs(stopLoss - currentClose);
            double lot = ComputeLotSize(stopDistance, FlipRiskPercent);
            if(lot > 0)
              {
               trade.Sell(lot, _Symbol, 0, stopLoss, takeProfit, "LiqZone_Flipped");
               zones[idx].triggered = true;
              }
           }
        }
  }

//+------------------------------------------------------------------+
//| Detects a new bar on current timeframe                           |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(currentBar != lastBarTime)
     {
      lastBarTime = currentBar;
      return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   point = Point();
   if(_Digits == 5 || _Digits == 3)
      point *= 10;

   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(10);

//--- Initialize ATR handle
   if(UseATRNormalization)
      atrHandle = iATR(_Symbol, PERIOD_CURRENT, ATRPeriod);
   else
      atrHandle = INVALID_HANDLE;

   DeleteAllZones();
   lastHtfUpdateTime = 0;
   lastBarTime = 0;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(atrHandle != INVALID_HANDLE)
      IndicatorRelease(atrHandle);
   DeleteAllZones();
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Only act on new bar
   if(!IsNewBar())
      return;

//--- Spread check
   if(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > MaxSpreadPoints)
      return;

//--- Update zones when a new higher timeframe bar appears
   datetime latestHtfTime = iTime(Symbol(), ZoneTimeframe, 0);
   if(latestHtfTime != lastHtfUpdateTime)
     {
      UpdateZones();
      lastHtfUpdateTime = latestHtfTime;
     }

//--- Remove expired zones (and their pending orders)
   RemoveExpiredZones();

//--- Check flip conditions (may modify zones array)
   CheckFlipConditions();

//--- Process flipped zones for market entries (no pending orders)
   for(int i = 0; i < ArraySize(zones); i++)
     {
      if(zones[i].flipped && !zones[i].triggered)
         PlaceFlippedZoneEntry(i);
     }
  }
//+------------------------------------------------------------------+