//+------------------------------------------------------------------+
//|                                                  LivermoreEA.mq5 |
//|                                Copyright 2026, Tola Moses Hector |
//|                                       https://www.mql5.com       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Tola Moses Hector"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Automating Classic Market Methods in MQL5 Part 6"
#property description "Jesse Livermore Pivotal Point System"
#property description "Market Key states, pyramid entry, abnormal behavior exit"
#property description "Daily timeframe — hedging account required"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Market Key State Machine                                         |
//+------------------------------------------------------------------+
enum ENUM_LV_STATE
  {
   STATE_IDLE,             // No structure active — scanning for consolidation
   STATE_CONSOLIDATING,    // Consolidation zone locked — watching for pivot break
   STATE_UPTREND,          // Pivot broken upward — campaign active long
   STATE_NATURAL_REACTION, // Low-volume pullback within uptrend
   STATE_DOWNTREND,        // Pivot broken downward — campaign active short
   STATE_NATURAL_RALLY     // Low-volume bounce within downtrend
  };

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Pivot Detection ==="
input int    InpConsolBars      = 10;   //--- Minimum bars to form a consolidation zone
input double InpConsolATR       = 2.5;  //--- Maximum consolidation range in ATR units
input double InpVolExpansion    = 1.2;  //--- Volume multiplier required on breakout bar
input double InpPivotClearATR   = 0.3;  //--- Minimum pivot clearance in ATR units

input group "=== Trend and Reaction ==="
input double InpReactionATR     = 1.0;  //--- Minimum reaction depth in ATR to confirm Natural Reaction
input double InpReactionVolRatio= 0.8;  //--- Reaction volume must be below this ratio of campaign avg
input double InpAbnormalVolMult = 1.5;  //--- Volume multiplier that defines abnormal behavior
input double InpAbnormalMoveATR = 1.0;  //--- Move size in ATR that defines abnormal behavior

input group "=== Pyramid Entry ==="
input double InpTranche1Pct     = 20.0; //--- Tranche 1 size as percent of full position
input double InpTranche2Pct     = 20.0; //--- Tranche 2 size as percent of full position
input double InpTranche3Pct     = 20.0; //--- Tranche 3 size as percent of full position
input double InpTranche4Pct     = 40.0; //--- Tranche 4 size as percent of full position (must sum to 100)
input double InpTranche2ATR     = 1.0;  //--- ATR advance from T1 to trigger T2 entry
input double InpTranche4ATR     = 1.0;  //--- ATR advance from T3 to trigger T4 entry

input group "=== Risk ==="
input double InpRiskPercent     = 1.0;  //--- Total position risk as percent of balance
input int    InpATRPeriod       = 14;   //--- ATR period

input group "=== General ==="
input int    InpMagicNumber     = 100601; //--- Magic number
input int    InpSlippage        = 10;    //--- Slippage in points
input bool   InpShowLabels      = true;  //--- Draw labels on chart

//+------------------------------------------------------------------+
//| Active campaign state                                            |
//+------------------------------------------------------------------+
struct SLivermoreCampaign
  {
   bool              is_long;
   double            pivot_price;
   double            consol_high;        // Frozen consolidation zone high
   double            consol_low;         // Frozen consolidation zone low
   double            avg_consol_vol;     // Frozen average volume of the consolidation period
   double            avg_campaign_vol;   // Running average volume during campaign
   int               campaign_bars;      // Bars since campaign started
   int               units_open;         // Number of tranches currently open
   double            full_lots;          // Full position size computed once at T1
   double            entry_prices[4];    // Entry price of each tranche
   double            lots[4];            // Lot size of each tranche
   ulong             tickets[4];         // Position ticket of each tranche (indexed by slot 0-3)
   double            t1_entry;           // T1 entry price (reference for T2 trigger)
   double            t3_entry;           // T3 entry price (reference for T4 trigger)
   datetime          t3_open_time;       // Bar time when T3 opened (prevent T4 same bar)
   bool              t2_open;
   bool              t3_open;
   bool              t4_open;
   double            reaction_high;      // Highest high during uptrend before reaction (swing reference)
   double            reaction_low_bar;   // Lowest close reached during Natural Reaction
   double            reaction_avg_vol;   // Average volume during the reaction bars
   int               reaction_bars;      // Number of bars spent in reaction
  };

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
ENUM_LV_STATE      g_state        = STATE_IDLE;
SLivermoreCampaign g_campaign;
CTrade             g_trade;
int                g_atr_handle   = INVALID_HANDLE;
datetime           g_last_bar     = 0;
int                g_consol_watch = 0;

//+------------------------------------------------------------------+
//| Validates all input parameters before EA start                   |
//+------------------------------------------------------------------+
bool ValidateInputs()
  {
   double tranche_sum = InpTranche1Pct + InpTranche2Pct + InpTranche3Pct + InpTranche4Pct;
   if(MathAbs(tranche_sum - 100.0) > 0.01)
     {
      Print("LivermoreEA: Tranche percentages must sum to 100. Current sum: ", tranche_sum);
      return false;
     }
   if(InpConsolBars < 3)
     { Print("LivermoreEA: InpConsolBars must be >= 3."); return false; }
   if(InpATRPeriod < 2)
     { Print("LivermoreEA: InpATRPeriod must be >= 2."); return false; }
   if(InpRiskPercent <= 0)
     { Print("LivermoreEA: InpRiskPercent must be > 0."); return false; }
   if(InpVolExpansion < 1.0)
     { Print("LivermoreEA: InpVolExpansion must be >= 1.0."); return false; }
   if(InpTranche1Pct <= 0 || InpTranche2Pct <= 0 || InpTranche3Pct <= 0 || InpTranche4Pct <= 0)
     { Print("LivermoreEA: All tranche percentages must be > 0."); return false; }
//--- Require hedging account mode
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Print("LivermoreEA: Hedging account required. This EA uses individual position tickets per tranche.");
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Returns pip size for the current symbol                          |
//+------------------------------------------------------------------+
double PipSize()
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   return (digits == 3 || digits == 5) ? _Point * 10.0 : _Point;
  }

//+------------------------------------------------------------------+
//| Computes full-position lot size from risk and stop distance      |
//+------------------------------------------------------------------+
double CalcFullLots(double sl_pips)
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
   if(step <= 0 || min_lot <= 0 || max_lot <= 0)
      return 0;
   lots = MathFloor(lots / step) * step;
   return MathMax(min_lot, MathMin(max_lot, lots));
  }

//+------------------------------------------------------------------+
//| Returns lot size for a specific tranche from the stored full_lots|
//| Returns 0 — not min_lot — if calculated size is below minimum    |
//+------------------------------------------------------------------+
double TrancheLots(double full_lots, double pct)
  {
   double step    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(step <= 0 || min_lot <= 0 || max_lot <= 0 || full_lots <= 0 || pct <= 0)
      return 0;
   double lots = MathFloor((full_lots * pct / 100.0) / step) * step;
   lots = NormalizeDouble(lots, 2);
   if(lots < min_lot)
      return 0;   // Do not open if below minimum — never substitute min_lot
   if(lots > max_lot)
      lots = max_lot;
   return lots;
  }

//+------------------------------------------------------------------+
//| Draws a horizontal line                                          |
//+------------------------------------------------------------------+
void DrawHLine(string name, double price, color clr, ENUM_LINE_STYLE style)
  {
   if(!InpShowLabels)
      return;
   string obj = "LV_" + name;
   ObjectDelete(0, obj);
   ObjectCreate(0, obj, OBJ_HLINE, 0, 0, price);
   ObjectSetInteger(0, obj, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, obj, OBJPROP_STYLE, style);
   ObjectSetInteger(0, obj, OBJPROP_WIDTH, 1);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Places a text label                                              |
//+------------------------------------------------------------------+
void DrawLabel(string name, datetime time, double price, string text, color clr)
  {
   if(!InpShowLabels)
      return;
   string obj = "LV_" + name;
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
      if(StringFind(name, "LV_") == 0)
         ObjectDelete(0, name);
     }
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Resets the campaign structure                                    |
//+------------------------------------------------------------------+
void ResetCampaign()
  {
   g_campaign.is_long          = true;
   g_campaign.pivot_price      = 0;
   g_campaign.consol_high      = 0;
   g_campaign.consol_low       = 0;
   g_campaign.avg_consol_vol   = 0;
   g_campaign.avg_campaign_vol = 0;
   g_campaign.campaign_bars    = 0;
   g_campaign.units_open       = 0;
   g_campaign.full_lots        = 0;
   g_campaign.t1_entry         = 0;
   g_campaign.t3_entry         = 0;
   g_campaign.t3_open_time     = 0;
   g_campaign.t2_open          = false;
   g_campaign.t3_open          = false;
   g_campaign.t4_open          = false;
   g_campaign.reaction_high    = 0;
   g_campaign.reaction_low_bar = 0;
   g_campaign.reaction_avg_vol = 0;
   g_campaign.reaction_bars    = 0;
   g_consol_watch              = 0;
   for(int i = 0; i < 4; i++)
     {
      g_campaign.entry_prices[i] = 0;
      g_campaign.lots[i]         = 0;
      g_campaign.tickets[i]      = 0;
     }
  }

//+------------------------------------------------------------------+
//| Locks consolidation zone — called only from STATE_IDLE           |
//+------------------------------------------------------------------+
bool LockConsolidation(double atr)
  {
   double high[], low[];
   long   vol[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low,  true);
   ArraySetAsSeries(vol,  true);
   if(CopyHigh(_Symbol,       PERIOD_CURRENT, 1, InpConsolBars, high) < InpConsolBars)
      return false;
   if(CopyLow(_Symbol,        PERIOD_CURRENT, 1, InpConsolBars, low)  < InpConsolBars)
      return false;
   if(CopyTickVolume(_Symbol, PERIOD_CURRENT, 1, InpConsolBars, vol)  < InpConsolBars)
      return false;
   double rh = 0, rl = DBL_MAX, avg_vol = 0;
   for(int i = 0; i < InpConsolBars; i++)
     {
      if(high[i] > rh)
         rh = high[i];
      if(low[i]  < rl)
         rl = low[i];
      avg_vol += (double)vol[i];
     }
   avg_vol /= InpConsolBars;
   double range = rh - rl;
   if(range > atr * InpConsolATR || range <= 0)
      return false;
   g_campaign.consol_high    = rh;
   g_campaign.consol_low     = rl;
   g_campaign.avg_consol_vol = avg_vol;
   Print(StringFormat("LivermoreEA: Zone LOCKED | High:%.5f | Low:%.5f | Range:%.5f | AvgVol:%.0f",
                      rh, rl, range, avg_vol));
   DrawHLine("CONSOL_HIGH", rh, clrSilver, STYLE_DOT);
   DrawHLine("CONSOL_LOW",  rl, clrSilver, STYLE_DOT);
   return true;
  }

//+------------------------------------------------------------------+
//| Checks for pivot breakout against frozen consolidation zone      |
//| Returns 1 bull, -1 bear, 0 none                                  |
//| One-day reversal: high exceeded pivot but bar closed below it    |
//+------------------------------------------------------------------+
int CheckPivotBreak(double atr)
  {
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double high1  = iHigh(_Symbol,  PERIOD_CURRENT, 1);
   double low1   = iLow(_Symbol,   PERIOD_CURRENT, 1);
   long   vol1   = iTickVolume(_Symbol, PERIOD_CURRENT, 1);
   double clearance = atr * InpPivotClearATR;
   if((double)vol1 < g_campaign.avg_consol_vol * InpVolExpansion)
      return 0;
//--- Bull breakout: close above consol high plus clearance
   if(close1 > g_campaign.consol_high + clearance)
     {
      //--- One-day reversal: high exceeded pivot but bar closed back below pivot
      //--- This is the correct formulation: high > pivot AND close < pivot
      if(high1 > g_campaign.consol_high && close1 < g_campaign.consol_high)
        {
         Print("LivermoreEA: One-day reversal — high exceeded pivot but closed below it. Rejected.");
         return 0;
        }
      g_campaign.pivot_price = g_campaign.consol_high;
      Print(StringFormat("LivermoreEA: BULL BREAK | Close:%.5f | Pivot:%.5f | Vol:%I64d",
                         close1, g_campaign.pivot_price, vol1));
      return 1;
     }
//--- Bear breakout: close below consol low minus clearance
   if(close1 < g_campaign.consol_low - clearance)
     {
      //--- One-day reversal: low exceeded pivot but closed above it
      if(low1 < g_campaign.consol_low && close1 > g_campaign.consol_low)
        {
         Print("LivermoreEA: One-day reversal (bear) — rejected.");
         return 0;
        }
      g_campaign.pivot_price = g_campaign.consol_low;
      Print(StringFormat("LivermoreEA: BEAR BREAK | Close:%.5f | Pivot:%.5f | Vol:%I64d",
                         close1, g_campaign.pivot_price, vol1));
      return -1;
     }
   return 0;
  }

//+------------------------------------------------------------------+
//| Opens one pyramid tranche using stored full_lots                 |
//+------------------------------------------------------------------+
bool OpenTranche(int slot, double lots, bool is_long, double sl_price, string label)
  {
   if(lots <= 0)
     {
      Print(StringFormat("LivermoreEA: %s skipped — calculated lots below minimum.", label));
      return false;
     }
   long   stop_lv  = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double min_dist = stop_lv * _Point;
   bool   ok       = false;
   if(is_long)
     {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if(ask - sl_price < min_dist)
         sl_price = NormalizeDouble(ask - min_dist - _Point, _Digits);
      ok = g_trade.Buy(lots, _Symbol, ask, sl_price, 0,
                       "Livermore T" + IntegerToString(slot + 1));
      if(ok)
        {
         g_campaign.entry_prices[slot] = ask;
         g_campaign.lots[slot]         = lots;
         ulong deal = g_trade.ResultDeal();
         if(deal > 0 && HistoryDealSelect(deal))
            g_campaign.tickets[slot] = (ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID);
         else
            g_campaign.tickets[slot] = g_trade.ResultOrder();
         g_campaign.units_open++;
         datetime t = iTime(_Symbol, PERIOD_CURRENT, 1);
         DrawLabel(label, t,
                   iLow(_Symbol, PERIOD_CURRENT, 1) - PipSize() * 5,
                   label, clrDodgerBlue);
         Print(StringFormat("LivermoreEA: %s | Lots:%.2f | Entry:%.5f | SL:%.5f",
                            label, lots, ask, sl_price));
        }
     }
   else
     {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(sl_price - bid < min_dist)
         sl_price = NormalizeDouble(bid + min_dist + _Point, _Digits);
      ok = g_trade.Sell(lots, _Symbol, bid, sl_price, 0,
                        "Livermore T" + IntegerToString(slot + 1));
      if(ok)
        {
         g_campaign.entry_prices[slot] = bid;
         g_campaign.lots[slot]         = lots;
         ulong deal = g_trade.ResultDeal();
         if(deal > 0 && HistoryDealSelect(deal))
            g_campaign.tickets[slot] = (ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID);
         else
            g_campaign.tickets[slot] = g_trade.ResultOrder();
         g_campaign.units_open++;
         datetime t = iTime(_Symbol, PERIOD_CURRENT, 1);
         DrawLabel(label, t,
                   iHigh(_Symbol, PERIOD_CURRENT, 1) + PipSize() * 5,
                   label, clrOrangeRed);
         Print(StringFormat("LivermoreEA: %s | Lots:%.2f | Entry:%.5f | SL:%.5f",
                            label, lots, bid, sl_price));
        }
     }
   return ok;
  }

//+------------------------------------------------------------------+
//| Closes all open campaign units — iterates all 4 slots            |
//+------------------------------------------------------------------+
void CloseAllUnits(string reason)
  {
   double total_profit = 0;
   for(int i = 3; i >= 0; i--)                    // Always iterate all 4 slots, not units_open
     {
      ulong ticket = g_campaign.tickets[i];
      if(ticket == 0)
         continue;                    // Slot was never filled
      if(!PositionSelectByTicket(ticket))
         continue; // Already closed
      total_profit += PositionGetDouble(POSITION_PROFIT);
      if(!g_trade.PositionClose(ticket))
         Print("LivermoreEA: Close failed | Ticket:", ticket);
     }
   Print(StringFormat("LivermoreEA: Campaign closed | Reason:%s | P&L:%.2f | Units:%d",
                      reason, total_profit, g_campaign.units_open));
   g_state = STATE_IDLE;
   ResetCampaign();
   ClearLabels();
  }

//+------------------------------------------------------------------+
//| Returns true if last bar showed abnormal behavior                |
//+------------------------------------------------------------------+
bool CheckAbnormalBehavior(double atr)
  {
   double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double open1  = iOpen(_Symbol,  PERIOD_CURRENT, 1);
   long   vol1   = iTickVolume(_Symbol, PERIOD_CURRENT, 1);
   double move   = MathAbs(close1 - open1);
   if(move < atr * InpAbnormalMoveATR)
      return false;
   if(g_campaign.avg_campaign_vol <= 0)
      return false;
   if((double)vol1 < g_campaign.avg_campaign_vol * InpAbnormalVolMult)
      return false;
   bool against_trend = (g_campaign.is_long  && close1 < open1) ||
                        (!g_campaign.is_long && close1 > open1);
   if(!against_trend)
      return false;
   Print(StringFormat("LivermoreEA: ABNORMAL BEHAVIOR | Move:%.5f | Vol:%I64d | AvgVol:%.0f",
                      move, vol1, g_campaign.avg_campaign_vol));
   return true;
  }

//+------------------------------------------------------------------+
//| Processes the Livermore Market Key state machine for one bar     |
//+------------------------------------------------------------------+
void ProcessStateMachine(double atr)
  {
//--- Update campaign running average volume
   if(g_state == STATE_UPTREND || g_state == STATE_NATURAL_REACTION ||
      g_state == STATE_DOWNTREND || g_state == STATE_NATURAL_RALLY)
     {
      g_campaign.campaign_bars++;
      long vol1 = iTickVolume(_Symbol, PERIOD_CURRENT, 1);
      g_campaign.avg_campaign_vol =
         (g_campaign.avg_campaign_vol * (g_campaign.campaign_bars - 1) + (double)vol1)
         / g_campaign.campaign_bars;
     }

   switch(g_state)
     {
      //--------------------------------------------------------------
      case STATE_IDLE:
         if(LockConsolidation(atr))
           { g_state = STATE_CONSOLIDATING; g_consol_watch = 0; }
         break;

      //--------------------------------------------------------------
      case STATE_CONSOLIDATING:
        {
         g_consol_watch++;
         if(g_consol_watch > InpConsolBars * 3)
           {
            Print("LivermoreEA: Consolidation watch expired — resetting.");
            g_state = STATE_IDLE;
            ResetCampaign();
            ClearLabels();
            break;
           }
         int breakout = CheckPivotBreak(atr);
         if(breakout == 0)
            break;
         bool   is_long  = (breakout == 1);
         //--- Stop placed at the pivot level (opposite side of consolidation)
         //--- This matches the article: stop at pivot = consol_low for longs, consol_high for shorts
         double sl_price = is_long ? g_campaign.consol_low : g_campaign.consol_high;
         double entry_px = is_long ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                           : SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double sl_pips  = MathAbs(entry_px - sl_price) / PipSize();
         //--- Compute full_lots ONCE and store in campaign — used by all tranches
         g_campaign.full_lots = CalcFullLots(sl_pips);
         double t1_lots = TrancheLots(g_campaign.full_lots, InpTranche1Pct);
         g_campaign.is_long = is_long;
         if(OpenTranche(0, t1_lots, is_long, sl_price, "T1"))
           {
            g_campaign.t1_entry = g_campaign.entry_prices[0];
            g_campaign.reaction_high = iHigh(_Symbol, PERIOD_CURRENT, 1); // Track swing reference
            DrawHLine("PIVOT", g_campaign.pivot_price, clrOrange, STYLE_DASH);
            DrawHLine("STOP",  sl_price,               clrCrimson, STYLE_DOT);
            g_state = is_long ? STATE_UPTREND : STATE_DOWNTREND;
           }
         else
           { g_state = STATE_IDLE; ResetCampaign(); }
        }
      break;

      //--------------------------------------------------------------
      case STATE_UPTREND:
        {
         if(CheckAbnormalBehavior(atr))
           { CloseAllUnits("Abnormal Behavior"); break; }
         if(iClose(_Symbol, PERIOD_CURRENT, 1) < g_campaign.pivot_price)
           { CloseAllUnits("Pivot Failure"); break; }
         double high1  = iHigh(_Symbol, PERIOD_CURRENT, 1);
         double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
         //--- Track the running swing high for reaction detection
         if(high1 > g_campaign.reaction_high)
            g_campaign.reaction_high = high1;
         //--- T2: use stored full_lots, not a new CalcFullLots call
         if(!g_campaign.t2_open && close1 >= g_campaign.t1_entry + atr * InpTranche2ATR)
           {
            double lots = TrancheLots(g_campaign.full_lots, InpTranche2Pct);
            if(OpenTranche(1, lots, true, g_campaign.pivot_price, "T2"))
               g_campaign.t2_open = true;
           }
         //--- Natural Reaction: price pulls back InpReactionATR from tracked swing high
         if(g_campaign.reaction_high - close1 > atr * InpReactionATR)
           {
            g_campaign.reaction_low_bar = close1;
            g_campaign.reaction_avg_vol = (double)iTickVolume(_Symbol, PERIOD_CURRENT, 1);
            g_campaign.reaction_bars    = 1;
            g_state = STATE_NATURAL_REACTION;
            Print(StringFormat("LivermoreEA: Natural Reaction started | SwingHigh:%.5f | Close:%.5f",
                               g_campaign.reaction_high, close1));
           }
        }
      break;

      //--------------------------------------------------------------
      case STATE_NATURAL_REACTION:
        {
         if(CheckAbnormalBehavior(atr))
           { CloseAllUnits("Abnormal Behavior During Reaction"); break; }
         if(iClose(_Symbol, PERIOD_CURRENT, 1) < g_campaign.pivot_price)
           { CloseAllUnits("Pivot Failure in Reaction"); break; }
         long   vol1   = iTickVolume(_Symbol, PERIOD_CURRENT, 1);
         double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
         double high1  = iHigh(_Symbol, PERIOD_CURRENT, 1);
         //--- Track reaction stats
         g_campaign.reaction_bars++;
         g_campaign.reaction_avg_vol =
            (g_campaign.reaction_avg_vol * (g_campaign.reaction_bars - 1) + (double)vol1)
            / g_campaign.reaction_bars;
         if(close1 < g_campaign.reaction_low_bar)
            g_campaign.reaction_low_bar = close1;
         //--- Volume must be contracting (below campaign average) for a genuine reaction
         bool vol_contracting = (g_campaign.avg_campaign_vol <= 0 ||
                                 (double)vol1 < g_campaign.avg_campaign_vol * InpReactionVolRatio);
         if(!vol_contracting)
           {
            //--- High volume during reaction = not a Natural Reaction = abnormal
            Print("LivermoreEA: High volume during reaction — treating as abnormal.");
            CloseAllUnits("High Volume Reaction");
            break;
           }
         //--- Resumption: price breaks above the reaction swing high on expanding volume
         //--- Use the reaction high (highest high during reaction period)
         double reaction_swing_high = g_campaign.reaction_high;
         bool   expanding_vol       = (g_campaign.avg_campaign_vol > 0 &&
                                       (double)vol1 > g_campaign.avg_campaign_vol);
         bool   broke_reaction_high = (high1 > reaction_swing_high);
         if(expanding_vol && broke_reaction_high)
           {
            if(!g_campaign.t3_open)
              {
               double lots = TrancheLots(g_campaign.full_lots, InpTranche3Pct);
               if(OpenTranche(2, lots, true, g_campaign.pivot_price, "T3"))
                 {
                  g_campaign.t3_entry     = g_campaign.entry_prices[2];
                  g_campaign.t3_open_time = iTime(_Symbol, PERIOD_CURRENT, 1);
                  g_campaign.t3_open      = true;
                 }
              }
            //--- Reset reaction high to new high for next reaction detection
            g_campaign.reaction_high = high1;
            g_state = STATE_UPTREND;
            Print("LivermoreEA: Natural Reaction ended — resuming uptrend.");
           }
        }
      break;

      //--------------------------------------------------------------
      case STATE_DOWNTREND:
        {
         if(CheckAbnormalBehavior(atr))
           { CloseAllUnits("Abnormal Behavior"); break; }
         if(iClose(_Symbol, PERIOD_CURRENT, 1) > g_campaign.pivot_price)
           { CloseAllUnits("Pivot Failure"); break; }
         double low1   = iLow(_Symbol,  PERIOD_CURRENT, 1);
         double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
         if(low1 < g_campaign.reaction_high || g_campaign.reaction_high == 0)
            g_campaign.reaction_high = low1; // Track swing low reference for downtrend
         if(!g_campaign.t2_open && close1 <= g_campaign.t1_entry - atr * InpTranche2ATR)
           {
            double lots = TrancheLots(g_campaign.full_lots, InpTranche2Pct);
            if(OpenTranche(1, lots, false, g_campaign.pivot_price, "T2"))
               g_campaign.t2_open = true;
           }
         //--- Natural Rally: price bounces InpReactionATR from tracked swing low
         double swing_low = g_campaign.reaction_high; // reused field for short campaigns
         if(close1 - swing_low > atr * InpReactionATR)
           {
            g_campaign.reaction_low_bar = close1;
            g_campaign.reaction_avg_vol = (double)iTickVolume(_Symbol, PERIOD_CURRENT, 1);
            g_campaign.reaction_bars    = 1;
            g_state = STATE_NATURAL_RALLY;
            Print("LivermoreEA: Natural Rally started.");
           }
        }
      break;

      //--------------------------------------------------------------
      case STATE_NATURAL_RALLY:
        {
         if(CheckAbnormalBehavior(atr))
           { CloseAllUnits("Abnormal Behavior During Rally"); break; }
         if(iClose(_Symbol, PERIOD_CURRENT, 1) > g_campaign.pivot_price)
           { CloseAllUnits("Pivot Failure in Rally"); break; }
         long   vol1   = iTickVolume(_Symbol, PERIOD_CURRENT, 1);
         double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
         double low1   = iLow(_Symbol, PERIOD_CURRENT, 1);
         g_campaign.reaction_bars++;
         g_campaign.reaction_avg_vol =
            (g_campaign.reaction_avg_vol * (g_campaign.reaction_bars - 1) + (double)vol1)
            / g_campaign.reaction_bars;
         bool vol_contracting = (g_campaign.avg_campaign_vol <= 0 ||
                                 (double)vol1 < g_campaign.avg_campaign_vol * InpReactionVolRatio);
         if(!vol_contracting)
           { Print("LivermoreEA: High volume during rally — abnormal."); CloseAllUnits("High Volume Rally"); break; }
         double reaction_swing_low = g_campaign.reaction_high; // swing low reference
         bool   expanding_vol      = (g_campaign.avg_campaign_vol > 0 && (double)vol1 > g_campaign.avg_campaign_vol);
         bool   broke_reaction_low = (low1 < reaction_swing_low);
         if(expanding_vol && broke_reaction_low)
           {
            if(!g_campaign.t3_open)
              {
               double lots = TrancheLots(g_campaign.full_lots, InpTranche3Pct);
               if(OpenTranche(2, lots, false, g_campaign.pivot_price, "T3"))
                 {
                  g_campaign.t3_entry     = g_campaign.entry_prices[2];
                  g_campaign.t3_open_time = iTime(_Symbol, PERIOD_CURRENT, 1);
                  g_campaign.t3_open      = true;
                 }
              }
            g_campaign.reaction_high = low1;
            g_state = STATE_DOWNTREND;
            Print("LivermoreEA: Natural Rally ended — resuming downtrend.");
           }
        }
      break;
     }

//--- T4: after T3, further InpTranche4ATR advance — NOT on same bar as T3
   if((g_state == STATE_UPTREND || g_state == STATE_DOWNTREND) &&
      g_campaign.t3_open && !g_campaign.t4_open && g_campaign.t3_entry > 0)
     {
      datetime current_bar_time = iTime(_Symbol, PERIOD_CURRENT, 1);
      if(current_bar_time == g_campaign.t3_open_time)
         return; // Block T4 on same bar as T3
      double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
      bool t4_ok    = g_campaign.is_long
                      ? close1 >= g_campaign.t3_entry + atr * InpTranche4ATR
                      : close1 <= g_campaign.t3_entry - atr * InpTranche4ATR;
      if(t4_ok)
        {
         double lots = TrancheLots(g_campaign.full_lots, InpTranche4Pct);
         if(OpenTranche(3, lots, g_campaign.is_long, g_campaign.pivot_price, "T4"))
            g_campaign.t4_open = true;
        }
     }
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!ValidateInputs())
      return INIT_FAILED;
   g_atr_handle = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
   if(g_atr_handle == INVALID_HANDLE)
     { Print("LivermoreEA: ATR handle creation failed."); return INIT_FAILED; }
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(InpSlippage);
   g_state = STATE_IDLE;
   g_last_bar = 0;
   ResetCampaign();
   Print(StringFormat("LivermoreEA v2 initialized | Symbol:%s | TF:%s | Magic:%d",
                      _Symbol, EnumToString(Period()), InpMagicNumber));
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(g_atr_handle);
   ClearLabels();
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime current_bar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(current_bar == g_last_bar)
      return;
   g_last_bar = current_bar;
   double atr_buf[];
   ArraySetAsSeries(atr_buf, true);
   if(CopyBuffer(g_atr_handle, 0, 1, 1, atr_buf) < 1)
      return;
   double atr = atr_buf[0];
   ProcessStateMachine(atr);
  }
//+------------------------------------------------------------------+
