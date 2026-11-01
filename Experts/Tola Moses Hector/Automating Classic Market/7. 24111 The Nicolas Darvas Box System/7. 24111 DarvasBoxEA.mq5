//+------------------------------------------------------------------+
//|                                                   DarvasBoxEA.mq5|
//|                                Copyright 2026, Tola Moses Hector |
//|                                          https://t.me/tolahector |
//+------------------------------------------------------------------+
//|Automating Classic Market                                         |
//|1. Wyckoff Accumulation and Distribution                          |
//|                           https://www.mql5.com/en/articles/22628 |
//|2. Wyckoff Cause and Effect—Point and Figure Price Targets        |
//|                           https://www.mql5.com/en/articles/22472 |
//|3.Stan Weinstein Stage Analysis                                   |
//|                           https://www.mql5.com/en/articles/22746 |
//|4.Mark Minervini's Trend Template                                |
//|                           https://www.mql5.com/en/articles/22790 |
//|5.The Original Turtle Trading Rules                               |
//|                           https://www.mql5.com/en/articles/23448 |
//|6.Jesse Livermore's Pivotal Point System                          |
//|                           https://www.mql5.com/en/articles/24075 |
//|7.The Nicolas Darvas Box System                                   |
//|                           https://www.mql5.com/en/articles/24111 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Tola Moses Hector"
#property link      "https://t.me/tolahector"
#property version   "1.00"
#property description "Automating Classic Market Methods in MQL5 Part 7"
#property description "Nicolas Darvas Box System — Box Detection and Staircase Pyramid"
#property description "Daily timeframe recommended"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| EA State Machine                                                 |
//+------------------------------------------------------------------+
enum ENUM_DARVAS_STATE
  {
   STATE_IDLE,                              // No extreme identified—scanning
   STATE_BOX_FORMING,                       // Extreme set—counting confirmation sessions
   STATE_WAITING_BREAKOUT,                  // Box confirmed—watching for breakout
   STATE_IN_TRADE,                          // At least one staircase unit open
   STATE_WATCHING_NEW_BOX                   // In trade and watching for next box simultaneously
  };

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Box Detection ==="
input int    InpLookbackBars      = 50;     // Bars to look back for new extreme
input int    InpConfirmSessions   = 3;      // Sessions the extreme must hold to confirm box
input double InpMinBoxATR         = 0.5;    // Minimum box height in ATR units
input double InpBoxVolMult        = 1.0;    // Max box volume as multiple of average (quiet = below 1)
input double InpBreakVolMult      = 1.3;    // Minimum breakout volume vs box average

input group "=== Staircase Settings ==="
input int    InpMaxUnits          = 4;      // Maximum staircase units
input int    InpMaxBarsBetweenBoxes = 20;   // Max bars to wait for next box before exiting
input double InpStopBuffer        = 0.3;    // Stop buffer below box bottom in ATR

input group "=== Risk ==="
input double InpRiskPercent       = 1.0;    // Risk per unit as percent of balance
input int    InpATRPeriod         = 14;     // ATR period

input group "=== General ==="
input int    InpMagicNumber       = 100701; // Magic number
input int    InpSlippage          = 10;     // Slippage in points
input bool   InpShowLabels        = true;   // Draw box and label objects on chart

//+------------------------------------------------------------------+
//| Current box data                                                 |
//+------------------------------------------------------------------+
struct SDarvasBox
  {
   double            top;                   // Box top price (confirmed extreme)
   double            bottom;                // Box bottom price (lowest low during box period)
   int               confirm_count;         // Sessions the top has held without being exceeded
   double            avg_box_vol;           // Average tick volume during box period
   int               box_bars;              // Number of bars in the current box period
   bool              is_bull;               // true = bull box, false = bear box
   datetime          top_time;              // Time of the bar that set the box top
  };

//+------------------------------------------------------------------+
//| Staircase unit data                                              |
//+------------------------------------------------------------------+
struct SStaircaseUnit
  {
   double            entry_price;           // Entry price of this unit
   double            lots;                  // Lot size of this unit
   ulong             ticket;                // Position ticket
   double            box_top;               // Box top that triggered this unit's entry
   double            box_bottom;            // Box bottom at time of this unit's entry
  };

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
ENUM_DARVAS_STATE g_state    = STATE_IDLE;  // Current state machine state
SDarvasBox        g_box;                    // Current box being formed
SStaircaseUnit    g_units[4];               // Open staircase units
int               g_unit_count  = 0;        // Number of open units
double            g_shared_stop = 0;        // Shared stop level for all units
int               g_bars_since_break = 0;   // Bars since last breakout (stall detection)
CTrade            g_trade;                  // Trade execution
int               g_atr_handle = INVALID_HANDLE; // ATR handle
datetime          g_last_bar   = 0;         // Last processed bar time

//+------------------------------------------------------------------+
//| Returns pip size for the current symbol                          |
//+------------------------------------------------------------------+
double PipSize()
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   return (digits == 3 || digits == 5) ? _Point * 10.0 : _Point;
  }

//+------------------------------------------------------------------+
//| Computes lot size from risk percent and stop distance in pips    |
//+------------------------------------------------------------------+
double CalcLots(double sl_pips)
  {
   double balance   = AccountInfoDouble(ACCOUNT_BALANCE);
   double risk_amt  = balance * InpRiskPercent / 100.0;
   double tick_val  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double pip_size  = PipSize();
   if(tick_size <= 0 || tick_val <= 0 || sl_pips <= 0)
      return 0;
   double pip_value = (pip_size / tick_size) * tick_val;
   double lots      = risk_amt / (sl_pips * pip_value);
   double step      = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double min_lot   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   lots = MathFloor(lots / step) * step;
   return MathMax(min_lot, MathMin(max_lot, lots));
  }

//+------------------------------------------------------------------+
//| Draws a rectangle representing the current box                   |
//+------------------------------------------------------------------+
void DrawBox(string name, datetime t1, datetime t2,
             double top, double bottom, color clr)
  {
   if(!InpShowLabels)
      return;
   string obj = "DVS_BOX_" + name;
   ObjectDelete(0, obj);
   ObjectCreate(0, obj, OBJ_RECTANGLE, 0, t1, top, t2, bottom);
   ObjectSetInteger(0, obj, OBJPROP_COLOR,   clr);
   ObjectSetInteger(0, obj, OBJPROP_STYLE,   STYLE_SOLID);
   ObjectSetInteger(0, obj, OBJPROP_WIDTH,   1);
   ObjectSetInteger(0, obj, OBJPROP_FILL,    true);
   ObjectSetInteger(0, obj, OBJPROP_BACK,    true);
   ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Places a text label at the specified time and price              |
//+------------------------------------------------------------------+
void DrawLabel(string name, datetime time, double price, string text, color clr)
  {
   if(!InpShowLabels)
      return;
   string obj = "DVS_" + name;
   ObjectDelete(0, obj);
   ObjectCreate(0, obj, OBJ_TEXT, 0, time, price);
   ObjectSetString(0,  obj, OBJPROP_TEXT, text);
   ObjectSetInteger(0, obj, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 9);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Removes all chart objects created by this EA                     |
//+------------------------------------------------------------------+
void ClearLabels()
  {
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, "DVS_") == 0)
         ObjectDelete(0, name);
     }
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Resets the current box structure to empty                        |
//+------------------------------------------------------------------+
void ResetBox()
  {
   g_box.top           = 0;
   g_box.bottom        = DBL_MAX;
   g_box.confirm_count = 0;
   g_box.avg_box_vol   = 0;
   g_box.box_bars      = 0;
   g_box.is_bull       = true;
   g_box.top_time      = 0;
  }

//+------------------------------------------------------------------+
//| Checks if the last bar set a new N-bar extreme                   |
//| Returns 1 for new high, -1 for new low, 0 for neither            |
//+------------------------------------------------------------------+
int CheckForExtreme(double atr)
  {
   double high1 = iHigh(_Symbol, PERIOD_CURRENT, 1);                      // Last bar high
   double low1  = iLow(_Symbol,  PERIOD_CURRENT, 1);                      // Last bar low
//--- New N-bar high
   double lookback_high = 0;
   for(int i = 2; i <= InpLookbackBars; i++)                              // From bar 2 to exclude current extreme bar
      if(iHigh(_Symbol, PERIOD_CURRENT, i) > lookback_high)
         lookback_high = iHigh(_Symbol, PERIOD_CURRENT, i);
   if(high1 > lookback_high)
     {
      g_box.top           = high1;                                        // Set box top
      g_box.bottom        = iLow(_Symbol, PERIOD_CURRENT, 1);             // Initial bottom
      g_box.confirm_count = 0;                                            // Reset counter
      g_box.avg_box_vol   = (double)iTickVolume(_Symbol, PERIOD_CURRENT, 1);
      g_box.box_bars      = 1;
      g_box.is_bull       = true;
      g_box.top_time      = iTime(_Symbol, PERIOD_CURRENT, 1);
      return 1;                                                           // Bull extreme found
     }
//--- New N-bar low
   double lookback_low = DBL_MAX;
   for(int i = 2; i <= InpLookbackBars; i++)
      if(iLow(_Symbol, PERIOD_CURRENT, i) < lookback_low)
         lookback_low = iLow(_Symbol, PERIOD_CURRENT, i);
   if(low1 < lookback_low)
     {
      g_box.top           = iHigh(_Symbol, PERIOD_CURRENT, 1);            // Initial top
      g_box.bottom        = low1;                                         // Set box bottom
      g_box.confirm_count = 0;
      g_box.avg_box_vol   = (double)iTickVolume(_Symbol, PERIOD_CURRENT, 1);
      g_box.box_bars      = 1;
      g_box.is_bull       = false;
      g_box.top_time      = iTime(_Symbol, PERIOD_CURRENT, 1);
      return -1;                                                          // Bear extreme found
     }
   return 0;                                                              // No new extreme
  }

//+------------------------------------------------------------------+
//| Updates the box being formed — returns true when box confirmed   |
//+------------------------------------------------------------------+
bool UpdateBoxFormation(double atr)
  {
   double high1 = iHigh(_Symbol, PERIOD_CURRENT, 1);
   double low1  = iLow(_Symbol,  PERIOD_CURRENT, 1);
   long   vol1  = iTickVolume(_Symbol, PERIOD_CURRENT, 1);
   g_box.box_bars++;                                                      // Increment box bar count
//--- Update running average volume during box period
   g_box.avg_box_vol = (g_box.avg_box_vol * (g_box.box_bars - 1) +
                        (double)vol1) / g_box.box_bars;                   // Running average
   if(g_box.is_bull)
     {
      //--- Update box bottom to track the low during formation
      if(low1 < g_box.bottom)
         g_box.bottom = low1;                                             // Expand bottom
      //--- If the high exceeded the box top, the top resets
      if(high1 > g_box.top)
        {
         g_box.top           = high1;                                     // New top
         g_box.confirm_count = 0;                                         // Reset counter
         g_box.top_time      = iTime(_Symbol, PERIOD_CURRENT, 1);         // Update time
         Print(StringFormat("DarvasBoxEA: Box top reset | New top:%.5f", g_box.top));
         return false;                                                    // Not yet confirmed
        }
      //--- Bar did not exceed top — increment confirmation counter
      g_box.confirm_count++;
      Print(StringFormat("DarvasBoxEA: Box confirm %d/%d | Top:%.5f | Bottom:%.5f",
                         g_box.confirm_count, InpConfirmSessions, g_box.top, g_box.bottom));
     }
   else
     {
      if(high1 > g_box.top)
         g_box.top = high1;                                               // Expand top
      if(low1 < g_box.bottom)
        {
         g_box.bottom        = low1;                                      // New bottom
         g_box.confirm_count = 0;
         Print(StringFormat("DarvasBoxEA: Box bottom reset | New bottom:%.5f", g_box.bottom));
         return false;
        }
      g_box.confirm_count++;
     }
//--- Box confirmed when confirmation counter reaches target
   if(g_box.confirm_count >= InpConfirmSessions)
     {
      //--- Validate box height
      double box_height = g_box.top - g_box.bottom;
      if(box_height < atr * InpMinBoxATR)
        {
         Print("DarvasBoxEA: Box too narrow — resetting.");
         return false;                                                    // Height check failed
        }
      //--- Draw the confirmed box on chart
      DrawBox(TimeToString(g_box.top_time, TIME_DATE),
              g_box.top_time,
              iTime(_Symbol, PERIOD_CURRENT, 1),
              g_box.top, g_box.bottom,
              g_box.is_bull ? C'200,230,200' : C'230,200,200');           // Green for bull, red for bear
      Print(StringFormat("DarvasBoxEA: Box confirmed | Top:%.5f | Bottom:%.5f | AvgVol:%.0f",
                         g_box.top, g_box.bottom, g_box.avg_box_vol));
      return true;                                                        // Box confirmed
     }
   return false;                                                          // Not yet confirmed
  }

//+------------------------------------------------------------------+
//| Checks whether the last bar broke out of the confirmed box       |
//| Returns 1 for bull breakout, -1 for bear, 0 for none             |
//+------------------------------------------------------------------+
int CheckBreakout(double atr)
  {
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);                    // Last bar close
   long   vol1   = iTickVolume(_Symbol, PERIOD_CURRENT, 1);               // Last bar volume
//--- Volume check: breakout volume must exceed box average by InpBreakVolMult
   if((double)vol1 < g_box.avg_box_vol * InpBreakVolMult)
      return 0;                                                           // Volume insufficient
//--- Bull breakout: close above box top
   if(g_box.is_bull && close1 > g_box.top)
     {
      Print(StringFormat("DarvasBoxEA: BULL breakout | Close:%.5f > Top:%.5f | Vol:%I64d | AvgVol:%.0f",
                         close1, g_box.top, vol1, g_box.avg_box_vol));
      return 1;
     }
//--- Bear breakout: close below box bottom
   if(!g_box.is_bull && close1 < g_box.bottom)
     {
      Print(StringFormat("DarvasBoxEA: BEAR breakout | Close:%.5f < Bottom:%.5f | Vol:%I64d | AvgVol:%.0f",
                         close1, g_box.bottom, vol1, g_box.avg_box_vol));
      return -1;
     }
   return 0;                                                              // No breakout
  }

//+------------------------------------------------------------------+
//| Opens one staircase unit and stores it in the units array        |
//+------------------------------------------------------------------+
bool OpenUnit(bool is_long, double stop_level, double atr)
  {
   if(g_unit_count >= InpMaxUnits)
      return false;                                                       // Unit cap reached
   double sl_buffer = atr * InpStopBuffer;                                // ATR buffer below/above box bottom
   double sl        = is_long
                      ? NormalizeDouble(stop_level - sl_buffer, _Digits)  // Stop below box bottom
                      : NormalizeDouble(stop_level + sl_buffer, _Digits); // Stop above box top
   double sl_pips   = MathAbs((is_long
                               ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                               : SymbolInfoDouble(_Symbol, SYMBOL_BID)) - sl) / PipSize();
   double lots      = CalcLots(sl_pips);
   if(lots <= 0)
      return false;
   long   stop_lv   = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double min_dist  = stop_lv * _Point;
   bool   ok        = false;
   if(is_long)
     {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if(ask - sl < min_dist)
         sl = NormalizeDouble(ask - min_dist - _Point, _Digits);
      ok = g_trade.Buy(lots, _Symbol, ask, sl, 0,
                       "Darvas U" + IntegerToString(g_unit_count + 1));
      if(ok)
        {
         g_units[g_unit_count].entry_price = ask;
         g_units[g_unit_count].lots        = lots;
         ulong deal = g_trade.ResultDeal();
         if(deal > 0 && HistoryDealSelect(deal))
            g_units[g_unit_count].ticket = (ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID);
         else
            g_units[g_unit_count].ticket = g_trade.ResultOrder();
         g_units[g_unit_count].box_top    = g_box.top;
         g_units[g_unit_count].box_bottom = g_box.bottom;
         g_shared_stop = sl;                                              // Update shared stop
         g_unit_count++;
         datetime t = iTime(_Symbol, PERIOD_CURRENT, 1);
         DrawLabel("U" + IntegerToString(g_unit_count), t,
                   iLow(_Symbol, PERIOD_CURRENT, 1) - PipSize() * 5,
                   "U" + IntegerToString(g_unit_count), clrDodgerBlue);   // Draw unit label
         Print(StringFormat("DarvasBoxEA: LONG U%d | Lots:%.2f | Entry:%.5f | SL:%.5f",
                            g_unit_count, lots, ask, sl));
        }
     }
   else
     {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(sl - bid < min_dist)
         sl = NormalizeDouble(bid + min_dist + _Point, _Digits);
      ok = g_trade.Sell(lots, _Symbol, bid, sl, 0,
                        "Darvas U" + IntegerToString(g_unit_count + 1));
      if(ok)
        {
         g_units[g_unit_count].entry_price = bid;
         g_units[g_unit_count].lots        = lots;
         ulong deal = g_trade.ResultDeal();
         if(deal > 0 && HistoryDealSelect(deal))
            g_units[g_unit_count].ticket = (ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID);
         else
            g_units[g_unit_count].ticket = g_trade.ResultOrder();
         g_units[g_unit_count].box_top    = g_box.top;
         g_units[g_unit_count].box_bottom = g_box.bottom;
         g_shared_stop = sl;
         g_unit_count++;
         datetime t = iTime(_Symbol, PERIOD_CURRENT, 1);
         DrawLabel("U" + IntegerToString(g_unit_count), t,
                   iHigh(_Symbol, PERIOD_CURRENT, 1) + PipSize() * 5,
                   "U" + IntegerToString(g_unit_count), clrOrangeRed);
         Print(StringFormat("DarvasBoxEA: SHORT U%d | Lots:%.2f | Entry:%.5f | SL:%.5f",
                            g_unit_count, lots, bid, sl));
        }
     }
   return ok;
  }

//+------------------------------------------------------------------+
//| Moves the stop for all open units to the new shared stop level   |
//+------------------------------------------------------------------+
void MoveSharedStop(double new_stop, bool is_long)
  {
//--- Only advance the stop, never retreat
   if(is_long  && new_stop <= g_shared_stop)
      return;
   if(!is_long && g_shared_stop > 0 && new_stop >= g_shared_stop)
      return;
   bool all_ok = true;
   for(int i = 0; i < g_unit_count; i++)                                  // Modify each unit
     {
      if(!PositionSelectByTicket(g_units[i].ticket))
         continue;
      if(!g_trade.PositionModify(g_units[i].ticket, new_stop, 0))
        {
         Print("DarvasBoxEA: Stop modify failed | Ticket:", g_units[i].ticket);
         all_ok = false;
        }
     }
   if(all_ok)
     {
      g_shared_stop = new_stop;                                           // Update shared stop
      Print(StringFormat("DarvasBoxEA: Shared stop moved to %.5f", new_stop));
     }
  }

//+------------------------------------------------------------------+
//| Closes all open staircase units and resets the EA state          |
//+------------------------------------------------------------------+
void CloseAllUnits(string reason)
  {
   double total_profit = 0;
   for(int i = g_unit_count - 1; i >= 0; i--)                             // Close in reverse order
     {
      if(!PositionSelectByTicket(g_units[i].ticket))
         continue;
      total_profit += PositionGetDouble(POSITION_PROFIT);
      if(!g_trade.PositionClose(g_units[i].ticket))
         Print("DarvasBoxEA: Close failed | Ticket:", g_units[i].ticket);
     }
   Print(StringFormat("DarvasBoxEA: Staircase closed | Reason:%s | P&L:%.2f | Units:%d",
                      reason, total_profit, g_unit_count));
   g_unit_count       = 0;
   g_shared_stop      = 0;
   g_bars_since_break = 0;
   g_state            = STATE_IDLE;
   ResetBox();
   ClearLabels();
  }

//+------------------------------------------------------------------+
//| Returns true if the shared stop has been violated                |
//+------------------------------------------------------------------+
bool CheckStop(bool is_long)
  {
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   if(is_long  && close1 < g_shared_stop)
      return true;                                                        // Close below bull stop
   if(!is_long && close1 > g_shared_stop)
      return true;                                                        // Close above bear stop
   return false;
  }

//+------------------------------------------------------------------+
//| Processes the Darvas Box state machine for one bar               |
//+------------------------------------------------------------------+
void ProcessStateMachine(double atr)
  {
   switch(g_state)
     {
      //--------------------------------------------------------------
      case STATE_IDLE:
        {
         int extreme = CheckForExtreme(atr);
         if(extreme != 0)
           {
            g_state = STATE_BOX_FORMING;                                  // Extreme found—begin box formation
            Print(StringFormat("DarvasBoxEA: Extreme set | %s | Price:%.5f",
                               extreme > 0 ? "BULL" : "BEAR",
                               extreme > 0 ? g_box.top : g_box.bottom));
           }
        }
      break;
      //--------------------------------------------------------------
      case STATE_BOX_FORMING:
        {
         if(UpdateBoxFormation(atr))
            g_state = STATE_WAITING_BREAKOUT;                             // Box confirmed
        }
      break;
      //--------------------------------------------------------------
      case STATE_WAITING_BREAKOUT:
        {
         int breakout = CheckBreakout(atr);
         if(breakout == 0)
            break;                                                        // No breakout yet
         bool   is_long   = (breakout == 1);
         double stop_level = is_long ? g_box.bottom : g_box.top;          // Stop at opposite boundary
         if(OpenUnit(is_long, stop_level, atr))                           // Open first unit
           {
            g_bars_since_break = 0;
            g_state = STATE_IN_TRADE;
            ResetBox();                                                   // Reset box — watch for next
           }
         else
           {
            g_state = STATE_IDLE;
            ResetBox();
           }
        }
      break;
      //--------------------------------------------------------------
      case STATE_IN_TRADE:
        {
         bool is_long = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
         if(!PositionSelectByTicket(g_units[0].ticket))
           {
            //--- All positions were closed externally (stop hit by broker)
            CloseAllUnits("External Close");
            break;
           }
         //--- Stop check
         if(CheckStop(is_long))
           { CloseAllUnits("Stop Hit"); break; }
         //--- Stall detection: too many bars without a new box
         g_bars_since_break++;
         if(g_bars_since_break > InpMaxBarsBetweenBoxes)
           { CloseAllUnits("Stall—No New Box"); break; }
         //--- Begin watching for next box
         g_state = STATE_WATCHING_NEW_BOX;
         ResetBox();                                                      // Fresh box scan
        }
      break;
      //--------------------------------------------------------------
      case STATE_WATCHING_NEW_BOX:
        {
         bool is_long = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
         if(!PositionSelectByTicket(g_units[0].ticket))
           { CloseAllUnits("External Close"); break; }
         //--- Stop check always runs first
         if(CheckStop(is_long))
           { CloseAllUnits("Stop Hit"); break; }
         g_bars_since_break++;
         if(g_bars_since_break > InpMaxBarsBetweenBoxes)
           { CloseAllUnits("Stall—No New Box"); break; }
         //--- Run box detection in parallel with open trade
         if(g_box.top == 0 && g_box.bottom == DBL_MAX)                    // No box yet started
           {
            int extreme = CheckForExtreme(atr);
            if(extreme != 0)
               Print(StringFormat("DarvasBoxEA: Next extreme set | %s | Price:%.5f",
                                  extreme > 0 ? "BULL" : "BEAR",
                                  extreme > 0 ? g_box.top : g_box.bottom));
           }
         else
            if(g_box.confirm_count < InpConfirmSessions)
              {
               UpdateBoxFormation(atr);                                   // Continue building new box
              }
            else
              {
               //--- New box confirmed — check for breakout and add unit
               int breakout = CheckBreakout(atr);
               if(breakout != 0 && g_unit_count < InpMaxUnits)
                 {
                  double stop_level = is_long ? g_box.bottom : g_box.top;
                  double sl_with_buf = is_long
                                       ? NormalizeDouble(stop_level - atr * InpStopBuffer, _Digits)
                                       : NormalizeDouble(stop_level + atr * InpStopBuffer, _Digits);
                  if(OpenUnit(is_long, stop_level, atr))
                    {
                     MoveSharedStop(sl_with_buf, is_long);                // Raise stop for all units
                     g_bars_since_break = 0;                              // Reset stall counter
                     ResetBox();                                          // Watch for next box
                     Print(StringFormat("DarvasBoxEA: Staircase now %d units | SharedStop:%.5f",
                                        g_unit_count, g_shared_stop));
                    }
                 }
              }
        }
      break;
     }
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_atr_handle = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);            // Create ATR handle
   if(g_atr_handle == INVALID_HANDLE)
     {
      Print("DarvasBoxEA: ATR handle creation failed.");
      return INIT_FAILED;
     }
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(InpSlippage);
   g_state            = STATE_IDLE;
   g_unit_count       = 0;
   g_shared_stop      = 0;
   g_bars_since_break = 0;
   g_last_bar         = 0;
   ResetBox();
   Print(StringFormat("DarvasBoxEA initialized | Symbol:%s | TF:%s | Magic:%d",
                      _Symbol, EnumToString(Period()), InpMagicNumber));
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(g_atr_handle);                                         // Release ATR handle
   ClearLabels();                                                          // Remove chart objects
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime current_bar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(current_bar == g_last_bar)
      return;                                                             // One execution per bar
   g_last_bar = current_bar;
   double atr_buf[];
   ArraySetAsSeries(atr_buf, true);
   if(CopyBuffer(g_atr_handle, 0, 1, 1, atr_buf) < 1)
      return;
   double atr = atr_buf[0];                                               // ATR from last completed bar
   ProcessStateMachine(atr);                                              // Run state machine
  }
//+------------------------------------------------------------------+
