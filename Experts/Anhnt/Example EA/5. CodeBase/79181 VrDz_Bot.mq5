//+------------------------------------------------------------------+
//|                                                    VrDz_Bot.mq5  |
//|                 Version: 1.23 - SCALP / SWING + SECURE Always ON |
//|                                                                  |
//|  DESCRIPTION                                                     |
//|  -----------                                                     |
//|  Lightweight Expert Advisor combining Scalp & Swing logic with   |
//|  an "Always-ON" position-securing layer. Includes a fully        |
//|  interactive on-chart panel with manual trade buttons, risk-     |
//|  based lot sizing, partial close, break-even, trailing stop,     |
//|  swing SL/TP switching, and a one-click "Secure All" tool.       |
//|                                                                  |
//|  FEATURES                                                        |
//|  --------                                                        |
//|   • Fixed or risk-% based lot sizing                             |
//|   • ATR-based or fixed-point SL / TP                             |
//|   • SCALP ⇄ SWING mode with auto SL/TP conversion                |
//|   • Partial close + auto move-SL-to-entry                        |
//|   • Break-even & trailing stop (SCALP only)                      |
//|   • "Secure All" – locks profits into SL in both modes           |
//|   • Remove-All-SL toggle                                         |
//|   • Live RSI / ATR / spread / PnL / countdown display            |
//|   • Manual BUY / SELL from panel                                 |
//|                                                                  |
//|  CHANGELOG                                                       |
//|  ---------                                                       |
//|   v1.23 – SECURE works in every mode (SWING protection removed). |
//|           Unified dark-navy palette + enlarged countdown.        |
//|   v1.22 – SWING mode auto-converts open positions SL/TP.         |
//|   v1.21 – Secure layer ignores losing positions only.            |
//|   v1.20 – Added countdown timer & risk-based lot sizing.         |
//|                                                                  |
//|  DISCLAIMER                                                      |
//|  ----------                                                      |
//|  Test thoroughly on DEMO first. No guarantee of profit.          |
//|  Use appropriate lot sizing for your account.                    |
//| https://www.mql5.com/en/code/79181                               |
//+------------------------------------------------------------------+
#property copyright "VrDz Bot"
#property version   "1.23"
#property strict

#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>

CTrade         Trade;
CPositionInfo  PosInfo;

//====================================================================
//  INPUT PARAMETERS
//====================================================================
input group "═══ 💰 Lot & Risk Management ═══"
input double InpLots           = 0.01;   // Fixed lot size
input double InpMaxLots        = 0.10;   // Maximum allowed lot
input double InpRiskPercent    = 5.0;    // Risk per trade (% of balance)
input bool   InpUseRiskBased   = true;   // Enable risk-based lot sizing

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "═══ 🎯 SL / TP (SCALP) ═══"
input int    InpStopLoss      = 800;     // Stop Loss (points)
input int    InpTakeProfit    = 2000;    // Take Profit (points)
input bool   InpUseATRStop    = true;    // Use ATR-based SL / TP
input int    InpATRPeriod     = 14;      // ATR period
input double InpATRMultSL     = 1.5;     // ATR multiplier for SL
input double InpATRMultTP     = 3.0;     // ATR multiplier for TP

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "═══ 📏 SL / TP (SWING mode) ═══"
input int    InpSwingSL       = 3000;    // SWING Stop Loss (points)
input int    InpSwingTP       = 6000;    // SWING Take Profit (points)

input group "═══ ✂️ Partial Close ═══"
input bool   InpUsePartialClose      = true;   // Enable partial close
input double InpPartialClosePercent  = 70.0;   // % of position to close
input int    InpPartialCloseTrigger  = 60;     // Trigger level (points)
input bool   InpMoveSLAfterPartial   = true;   // Move SL to entry after partial

input group "═══ 📈 Trailing Stop ═══"
input bool InpUseTrailing  = true;       // Enable trailing stop
input int  InpTrailStart   = 100;        // Trail start (points)
input int  InpTrailStep    = 20;         // Trail step (points)

input group "═══ 🛡️ Break Even ═══"
input bool InpUseBreakEven = true;       // Enable break-even
input int  InpBETrigger    = 90;         // BE trigger (points)
input int  InpBELock       = 5;          // Locked profit (points)

input group "═══ 🔒 Position Securing ═══"
input int InpSecureBuffer = 20;          // Min profit to trigger securing
input int InpSecureLock   = 5;           // Locked profit after securing

input group "═══ 🎛️ Trade Management ═══"
input int InpMagicNumber       = 0;      // Magic number
input int InpDeviationInPoints = 30;     // Max slippage (points)
input int InpMaxSpread         = 30;     // Max allowed spread (points)

input group "═══ 📊 Indicators ═══"
input int InpRSIPeriod = 14;             // RSI period
input int InpRSIB      = 30;             // RSI oversold level
input int InpRSIS      = 70;             // RSI overbought level

input group "═══ ⏰ Countdown Timer ═══"
input bool  InpShowCountdown    = true;         // Show new-bar countdown
input color InpCountdownColor   = clrLime;      // Countdown colour
input int   InpCountdownFont    = 13;           // Countdown font size

input group "═══ 🖥️ Panel ═══"
input bool InpShowPanel = true;          // Show on-chart panel

//====================================================================
//  UI PALETTE — Cohesive dark theme
//====================================================================
#define UI_BG           C'20,24,36'     // Panel background
#define UI_TITLE_BG     C'34,42,62'     // Title bar background
#define UI_TITLE_TXT    C'232,196,92'   // Title gold text
#define UI_TITLE_BORDER C'70,85,115'    // Title bar border
#define UI_BORDER       C'55,68,95'     // Main panel border
#define UI_DIVIDER      C'50,64,90'     // Section dividers
#define UI_SECTION      C'95,155,225'   // Section headers (all same blue)

#define UI_TXT          clrWhiteSmoke   // Primary text
#define UI_TXT_DIM      C'160,175,195'  // Secondary text

#define UI_ACTIVE_BG    C'28,72,46'     // Feature ON  background
#define UI_ACTIVE_TXT   C'130,225,155'  // Feature ON  text
#define UI_INACTIVE_BG  C'74,30,30'     // Feature OFF background
#define UI_INACTIVE_TXT C'228,148,148'  // Feature OFF text

#define UI_CLOSE_PRF    C'40,88,140'    // Close profitable (deep blue)
#define UI_CLOSE_BUY    C'30,110,52'    // Close buys (green)
#define UI_CLOSE_SELL   C'170,58,58'    // Close sells (red)
#define UI_DELETE_BG    C'48,52,70'     // Delete pending (neutral)
#define UI_DELETE_TXT   C'200,208,220'  // Delete pending text

#define UI_BUY          C'28,110,50'    // BUY button
#define UI_SELL         C'170,55,55'    // SELL button

#define UI_SECURE_BG    C'16,20,30'     // Secure button background
#define UI_SECURE_TXT   C'245,205,90'   // Secure button gold text

#define UI_ATR_TXT      C'185,160,235'  // ATR soft purple
#define UI_SPREAD_TXT   C'190,200,215'  // Spread light gray-blue

#define UI_CD_BOX_BG    C'28,34,50'     // Countdown highlight box

#define UI_NOSL_WARN_BG C'78,22,22'     // NO-SL warning background
#define UI_NOSL_WARN_TX C'255,110,110'  // NO-SL warning text

#define UI_SWING_ON_BG  C'110,32,38'    // SWING ON background
#define UI_SWING_ON_TX  C'255,200,200'  // SWING ON text
#define UI_SWING_OFF_BG C'60,22,22'     // SWING OFF (SCALP) background
#define UI_SWING_OFF_TX C'230,150,150'  // SWING OFF (SCALP) text

//====================================================================
//  GLOBALS
//====================================================================
int    rsiHandle   = INVALID_HANDLE;
int    atrHandle   = INVALID_HANDLE;

string PREFIX         = "VrDz_";
bool   panelCreated   = false;

bool   g_usePartialClose    = true;
bool   g_moveSLAfterPartial = true;
bool   g_useTrailing        = true;
bool   g_useBreakEven       = true;
bool   g_noSL               = false;

// ═══ SWING mode state ═══
bool   g_scalpMode         = false;   // false = SCALP, true = SWING
bool   g_savedPartialClose = true;
bool   g_savedSLMove       = true;
bool   g_savedTrailing     = true;
bool   g_savedBreakEven    = true;
bool   g_hasSavedState     = false;

ulong  partialClosedTickets[];
int    partialClosedCount = 0;

datetime lastTradeTime  = 0;
double   dayStartBalance = 0;

string g_lastNewBar = "";

//====================================================================
//  HELPERS
//====================================================================
double GetPoint()
  {
   double p = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   return (p > 0) ? p : 0.00001;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetATR()
  {
   if(atrHandle == INVALID_HANDLE)
      return 0;
   double b[1];
   if(CopyBuffer(atrHandle, 0, 0, 1, b) != 1)
      return 0;
   if(b[0] <= 0 || !MathIsValidNumber(b[0]))
      return 0;
   return b[0];
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetRSI()
  {
   if(rsiHandle == INVALID_HANDLE)
      return 50;
   double b[1];
   if(CopyBuffer(rsiHandle, 0, 0, 1, b) != 1)
      return 50;
   return b[0];
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ClampGlobalLot(double lot)
  {
   double mx = 1.0;
   if(mx > 0 && lot > mx)
      lot = mx;
   double mn = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double st = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(st <= 0)
      st = 0.01;
   lot = MathMax(lot, mn);
   lot = MathFloor(lot / st) * st;
   return NormalizeDouble(lot, 2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HasEnoughMargin(ENUM_ORDER_TYPE type, double lot, double price)
  {
   double mr = 0;
   if(!OrderCalcMargin(type, _Symbol, lot, price, mr))
      return true;
   double fm = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(mr > fm * 0.9)
      return false;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FormatCountdown(int totalSeconds)
  {
   if(totalSeconds < 0)
      totalSeconds = 0;
   int h = totalSeconds / 3600;
   int m = (totalSeconds % 3600) / 60;
   int s = totalSeconds % 60;
   if(h > 0)
      return StringFormat("%02d:%02d:%02d", h, m, s);
   return StringFormat("%02d:%02d", m, s);
  }

//====================================================================
//  COUNTDOWN
//====================================================================
void UpdateCountdown(bool force)
  {
   if(!InpShowCountdown || !panelCreated)
      return;
   datetime brokerTime = TimeCurrent();
   datetime barTime    = iTime(_Symbol, _Period, 0);
   int      periodSec  = PeriodSeconds(_Period);
   int      remaining  = (int)(barTime + periodSec - brokerTime);
   if(remaining < 0)
      remaining = 0;
   string strNewBar = FormatCountdown(remaining);
   if(force || strNewBar != g_lastNewBar)
     {
      ObjectSetString(0, PREFIX + "TimeNB", OBJPROP_TEXT, "⏱ T-" + strNewBar);
      g_lastNewBar = strNewBar;
      ChartRedraw();
     }
  }

//====================================================================
//  INPUT VALIDATION
//====================================================================
bool ValidateInputs()
  {
   if(InpLots <= 0 && InpRiskPercent <= 0)
      return false;
   if(InpStopLoss <= 0 || InpTakeProfit <= 0)
      return false;
   if(InpUseATRStop && (InpATRMultSL <= 0 || InpATRMultTP <= 0))
      return false;
   if(InpSwingSL <= 0 || InpSwingTP <= 0)
      return false;
   return true;
  }

//====================================================================
//  LOT SIZE CALCULATION
//====================================================================
double CalculateLot()
  {
   double lot = InpLots;
   if(InpUseRiskBased && InpRiskPercent > 0 && InpStopLoss > 0)
     {
      double bal = AccountInfoDouble(ACCOUNT_BALANCE);
      double risk = bal * InpRiskPercent / 100.0;
      double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      if(tv > 0 && ts > 0)
        {
         double slDist;
         if(g_scalpMode)
           {
            slDist = InpSwingSL * GetPoint();
           }
         else
           {
            slDist = InpStopLoss * GetPoint();
            if(InpUseATRStop)
              {
               double atr = GetATR();
               if(atr > 0)
                  slDist = atr * InpATRMultSL;
              }
           }
         double lossPerLot = (slDist / ts) * tv;
         if(lossPerLot > 0)
            lot = risk / lossPerLot;
        }
     }
   double mn = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double mx = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double st = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(st <= 0)
      st = 0.01;
   double safeMax = (InpMaxLots > 0) ? MathMin(InpMaxLots, mx) : mx;
   lot = MathMax(mn, MathMin(safeMax, lot));
   lot = MathRound(lot / st) * st;
   lot = NormalizeDouble(lot, 2);
   if(lot < mn)
      lot = mn;
   if(lot > safeMax)
      lot = safeMax;
   return ClampGlobalLot(lot);
  }

//====================================================================
//  SL / TP CALCULATION
//====================================================================
void GetSLTP(ENUM_ORDER_TYPE type, double price, double &sl, double &tp)
  {
   double pt = GetPoint();
   double minD = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * pt;
   if(minD <= 0)
      minD = 10 * pt;
   bool isBuy = (type == ORDER_TYPE_BUY);

   double slDist, tpDist;
   if(g_scalpMode)
     {
      slDist = InpSwingSL * pt;
      tpDist = InpSwingTP * pt;
     }
   else
     {
      slDist = InpStopLoss * pt;
      tpDist = InpTakeProfit * pt;
      if(InpUseATRStop)
        {
         double atr = GetATR();
         if(atr > 0)
           {
            slDist = atr * InpATRMultSL;
            tpDist = atr * InpATRMultTP;
           }
        }
     }
   if(slDist < minD * 1.2)
      slDist = minD * 1.2;
   if(tpDist < minD * 1.2)
      tpDist = minD * 1.2;

   sl = isBuy ? price - slDist : price + slDist;
   tp = isBuy ? price + tpDist : price - tpDist;
   if(isBuy)
     {
      if(sl >= price - minD || sl == 0)
         sl = price - MathMax(slDist, minD * 1.2);
      if(tp <= price + minD || tp == 0)
         tp = price + MathMax(tpDist, minD * 1.2);
     }
   else
     {
      if(sl <= price + minD || sl == 0)
         sl = price + MathMax(slDist, minD * 1.2);
      if(tp >= price - minD || tp == 0)
         tp = price - MathMax(tpDist, minD * 1.2);
     }
   sl = NormalizeDouble(sl, _Digits);
   tp = NormalizeDouble(tp, _Digits);
  }

//====================================================================
//  APPLY SWING SL/TP TO OPEN POSITIONS
//====================================================================
void ApplySwingToOpenPositions()
  {
   double pt = GetPoint();
   if(pt <= 0)
      return;
   double minStop = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * pt;
   if(minStop <= 0)
      minStop = 10 * pt;

   int modified = 0, skipped = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0)
         continue;
      if(!PositionSelectByTicket(t))
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;

      double op   = PositionGetDouble(POSITION_PRICE_OPEN);
      double cur  = PositionGetDouble(POSITION_PRICE_CURRENT);
      long   type = PositionGetInteger(POSITION_TYPE);
      double oldSL= PositionGetDouble(POSITION_SL);
      double oldTP= PositionGetDouble(POSITION_TP);

      double newSL, newTP;
      bool isBuy = (type == POSITION_TYPE_BUY);

      double slDist = InpSwingSL * pt;
      double tpDist = InpSwingTP * pt;
      if(slDist < minStop * 1.2)
         slDist = minStop * 1.2;
      if(tpDist < minStop * 1.2)
         tpDist = minStop * 1.2;

      if(isBuy)
        {
         newSL = NormalizeDouble(op - slDist, _Digits);
         newTP = NormalizeDouble(op + tpDist, _Digits);
        }
      else
        {
         newSL = NormalizeDouble(op + slDist, _Digits);
         newTP = NormalizeDouble(op - tpDist, _Digits);
        }

      if(MathAbs(cur - newSL) < minStop)
        {
         skipped++;
         continue;
        }
      if(MathAbs(newSL - oldSL) < pt * 0.5 &&
         MathAbs(newTP - oldTP) < pt * 0.5)
        {
         skipped++;
         continue;
        }

      if(Trade.PositionModify(t, newSL, newTP))
        {
         modified++;
         Print("[SWING] ✅ #", t, " | SL: ", oldSL, " → ", newSL,
               " | TP: ", oldTP, " → ", newTP);
        }
      else
        {
         Print("[SWING] ❌ #", t, " rc=", Trade.ResultRetcode());
        }
     }
   Print("[SWING] 📊 modified=", modified, " | skipped=", skipped);
  }

//====================================================================
//  MANUAL ORDER
//====================================================================
void OpenManualOrder(ENUM_ORDER_TYPE type)
  {
   if(type != ORDER_TYPE_BUY && type != ORDER_TYPE_SELL)
      return;
   double lot = CalculateLot();
   double price = (type == ORDER_TYPE_BUY)
                  ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                  : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(!HasEnoughMargin(type, lot, price))
     {
      Print("[MANUAL] Rejected: insufficient margin");
      return;
     }
   double sl, tp;
   GetSLTP(type, price, sl, tp);
   if(g_noSL)
      sl = 0;
   bool ok = (type == ORDER_TYPE_BUY)
             ? Trade.Buy(lot, _Symbol, price, sl, tp, "Manual-BUY")
             : Trade.Sell(lot, _Symbol, price, sl, tp, "Manual-SELL");
   if(ok && Trade.ResultRetcode() == TRADE_RETCODE_DONE)
     {
      lastTradeTime = TimeCurrent();
      Print("[MANUAL] ✅ ", EnumToString(type), " | Lot=", lot,
            " Entry=", price, " SL=", sl, " TP=", tp,
            g_scalpMode ? " [SWING]" : " [SCALP]");
     }
   else
     {
      Print("[MANUAL] ❌ rc=", Trade.ResultRetcode());
     }
  }

//====================================================================
//  CLOSE FUNCTIONS
//====================================================================
void CloseAllPositions()
  {
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0)
         continue;
      if(PositionSelectByTicket(t) &&
         PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
        {
         if(Trade.PositionClose(t))
            n++;
        }
     }
   Print("[CLOSE] Closed ", n, " position(s)");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseProfitablePositions()
  {
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0)
         continue;
      if(PositionSelectByTicket(t) &&
         PositionGetInteger(POSITION_MAGIC) == InpMagicNumber &&
         PositionGetDouble(POSITION_PROFIT) > 0)
        {
         if(Trade.PositionClose(t))
            n++;
        }
     }
   Print("[CLOSE-PRF] Closed ", n, " profitable position(s)");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositionsByType(ENUM_POSITION_TYPE type)
  {
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0)
         continue;
      if(PositionSelectByTicket(t) &&
         PositionGetInteger(POSITION_MAGIC) == InpMagicNumber &&
         PositionGetInteger(POSITION_TYPE) == type)
        {
         if(Trade.PositionClose(t))
            n++;
        }
     }
   Print("[CLOSE] Closed ", n, " position(s) of type ", EnumToString(type));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders()
  {
   int n = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong t = OrderGetTicket(i);
      if(t == 0)
         continue;
      if(OrderSelect(t) &&
         OrderGetInteger(ORDER_MAGIC) == InpMagicNumber)
        {
         if(Trade.OrderDelete(t))
            n++;
        }
     }
   Print("[DELETE] Deleted ", n, " pending order(s)");
  }

//====================================================================
//  SECURE ALL — Works in every mode (SCALP & SWING)
//====================================================================
void SecureAllPositions()
  {
   double pt = GetPoint();
   if(pt <= 0)
      return;
   double minStop = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * pt;
   if(minStop <= 0)
      minStop = 10 * pt;
   int secured = 0, skipped = 0, lost = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0)
         continue;
      if(!PositionSelectByTicket(t))
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      double op   = PositionGetDouble(POSITION_PRICE_OPEN);
      double cur  = PositionGetDouble(POSITION_PRICE_CURRENT);
      double sl   = PositionGetDouble(POSITION_SL);
      double tp   = PositionGetDouble(POSITION_TP);
      long   type = PositionGetInteger(POSITION_TYPE);
      double points = (type == POSITION_TYPE_BUY) ? (cur - op)/pt : (op - cur)/pt;
      if(points <= 0)
        {
         lost++;
         continue;
        }
      if(points < InpSecureBuffer)
        {
         skipped++;
         continue;
        }
      double ns;
      if(type == POSITION_TYPE_BUY)
        {
         ns = NormalizeDouble(op + InpSecureLock * pt, _Digits);
         if(ns <= sl)
           {
            skipped++;
            continue;
           }
        }
      else
        {
         ns = NormalizeDouble(op - InpSecureLock * pt, _Digits);
         if(sl != 0 && ns >= sl)
           {
            skipped++;
            continue;
           }
        }
      if(MathAbs(cur - ns) < minStop)
        {
         skipped++;
         continue;
        }
      if(Trade.PositionModify(t, ns, tp))
        {
         secured++;
         Print("[SECURE] ✅ #", t, " SL=", ns);
        }
     }
   Print("[SECURE] secured=", secured, " | skipped=", skipped, " | losing=", lost);
  }

//====================================================================
//  REMOVE ALL SL
//====================================================================
void RemoveAllStopLosses()
  {
   int removed = 0, skipped = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0)
         continue;
      if(!PositionSelectByTicket(t))
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      double sl = PositionGetDouble(POSITION_SL);
      if(sl == 0)
        {
         skipped++;
         continue;
        }
      double tp = PositionGetDouble(POSITION_TP);
      if(Trade.PositionModify(t, 0, tp))
        {
         removed++;
         Print("[REMOVE-SL] ✅ #", t, " SL removed (was ", sl, ")");
        }
     }
   Print("[REMOVE-SL] 📊 removed=", removed, " | skipped=", skipped);
  }

//====================================================================
//  PARTIAL CLOSE — disabled in SWING
//====================================================================
bool IsPartialClosed(ulong ticket)
  {
   for(int i = 0; i < partialClosedCount; i++)
      if(partialClosedTickets[i] == ticket)
         return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MarkPartialClosed(ulong ticket)
  {
   if(IsPartialClosed(ticket))
      return;
   int sz = ArraySize(partialClosedTickets);
   if(partialClosedCount >= sz)
     {
      int ns = (sz == 0) ? 50 : sz * 2;
      ArrayResize(partialClosedTickets, ns);
     }
   partialClosedTickets[partialClosedCount++] = ticket;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanPartialList()
  {
   for(int i = partialClosedCount - 1; i >= 0; i--)
     {
      if(!PositionSelectByTicket(partialClosedTickets[i]))
         partialClosedTickets[i] = partialClosedTickets[--partialClosedCount];
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyPartialClose(ulong ticket)
  {
   if(g_scalpMode)
      return;
   if(!g_usePartialClose)
      return;
   if(!PositionSelectByTicket(ticket))
      return;
   if(IsPartialClosed(ticket))
      return;
   double pt = GetPoint();
   if(pt <= 0)
      return;
   double op   = PositionGetDouble(POSITION_PRICE_OPEN);
   double cur  = PositionGetDouble(POSITION_PRICE_CURRENT);
   long   type = PositionGetInteger(POSITION_TYPE);
   double vol  = PositionGetDouble(POSITION_VOLUME);
   double profitPoints = (type == POSITION_TYPE_BUY) ? (cur-op)/pt : (op-cur)/pt;
   if(profitPoints < InpPartialCloseTrigger)
      return;
   if(vol <= 0)
      return;
   double mn = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double st = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(st <= 0)
      st = 0.01;
   if(mn <= 0)
      mn = st;
   double closeVol = NormalizeDouble(vol * InpPartialClosePercent / 100.0, 2);
   closeVol = MathRound(closeVol / st) * st;
   closeVol = NormalizeDouble(closeVol, 2);
   if(closeVol < mn)
      closeVol = mn;
   if(closeVol >= vol)
      closeVol = NormalizeDouble(vol - mn, 2);
   if(closeVol > 0 && closeVol < vol)
     {
      if(Trade.PositionClosePartial(ticket, closeVol))
        {
         MarkPartialClosed(ticket);
         Print("[PARTIAL] Partially closed ", closeVol, " of ", vol);
         if(g_moveSLAfterPartial && !g_noSL)
           {
            double tp = PositionGetDouble(POSITION_TP);
            if(Trade.PositionModify(ticket, op, tp))
               Print("[PARTIAL] SL moved to entry ", op);
           }
        }
     }
  }

//====================================================================
//  BREAK EVEN — disabled in SWING
//====================================================================
void ApplyBreakEven(ulong ticket)
  {
   if(g_scalpMode)
      return;
   if(!g_useBreakEven)
      return;
   if(g_noSL)
      return;
   if(!PositionSelectByTicket(ticket))
      return;
   double pt = GetPoint();
   if(pt <= 0)
      return;
   double op   = PositionGetDouble(POSITION_PRICE_OPEN);
   double cur  = PositionGetDouble(POSITION_PRICE_CURRENT);
   double sl   = PositionGetDouble(POSITION_SL);
   long   type = PositionGetInteger(POSITION_TYPE);
   double tp   = PositionGetDouble(POSITION_TP);

   if(type == POSITION_TYPE_BUY)
     {
      if((cur - op) / pt >= InpBETrigger)
        {
         double ns = NormalizeDouble(op + InpBELock * pt, _Digits);
         if(ns > sl)
           {
            if(Trade.PositionModify(ticket, ns, tp))
               Print("[BE] BUY: SL moved to ", ns);
           }
        }
     }
   else
      if(type == POSITION_TYPE_SELL)
        {
         if((op - cur) / pt >= InpBETrigger)
           {
            double ns = NormalizeDouble(op - InpBELock * pt, _Digits);
            if(sl == 0 || ns < sl)
              {
               if(Trade.PositionModify(ticket, ns, tp))
                  Print("[BE] SELL: SL moved to ", ns);
              }
           }
        }
  }

//====================================================================
//  TRAILING STOP — disabled in SWING
//====================================================================
void ApplyTrailingStop(ulong ticket)
  {
   if(g_scalpMode)
      return;
   if(!g_useTrailing)
      return;
   if(g_noSL)
      return;
   if(!PositionSelectByTicket(ticket))
      return;
   double pt = GetPoint();
   if(pt <= 0)
      return;

   double op   = PositionGetDouble(POSITION_PRICE_OPEN);
   double cur  = PositionGetDouble(POSITION_PRICE_CURRENT);
   double sl   = PositionGetDouble(POSITION_SL);
   long   type = PositionGetInteger(POSITION_TYPE);
   double tp   = PositionGetDouble(POSITION_TP);

   if(type == POSITION_TYPE_BUY)
     {
      if((cur - op) / pt >= InpTrailStart)
        {
         double ns = NormalizeDouble(cur - InpTrailStep * pt, _Digits);
         if(ns > sl)
           {
            if(Trade.PositionModify(ticket, ns, tp))
               Print("[TRAIL] BUY: SL=", ns);
           }
        }
     }
   else
      if(type == POSITION_TYPE_SELL)
        {
         if((op - cur) / pt >= InpTrailStart)
           {
            double ns = NormalizeDouble(cur + InpTrailStep * pt, _Digits);
            if(sl == 0 || ns < sl)
              {
               if(Trade.PositionModify(ticket, ns, tp))
                  Print("[TRAIL] SELL: SL=", ns);
              }
           }
        }
  }

//====================================================================
//  MANAGE POSITIONS
//====================================================================
void ManagePositions()
  {
   CleanPartialList();
   if(g_scalpMode)
      return;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0)
         continue;
      if(!PositionSelectByTicket(t))
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      ApplyPartialClose(t);
      ApplyBreakEven(t);
      ApplyTrailingStop(t);
     }
  }

//====================================================================
//  PANEL HELPERS
//====================================================================
void P_CreateLabel(string n, int x, int y, string t,
                   color c, int s, string f)
  {
   string o = PREFIX + n;
   ObjectDelete(0, o);
   ObjectCreate(0, o, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, o, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, o, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, o, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, o, OBJPROP_TEXT, t);
   ObjectSetInteger(0, o, OBJPROP_COLOR, c);
   ObjectSetInteger(0, o, OBJPROP_FONTSIZE, s);
   ObjectSetString(0, o, OBJPROP_FONT, f);
   ObjectSetInteger(0, o, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, o, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void P_CreateButton(string n, int x, int y, int w, int h,
                    string t, color b, int fs = 8, color tc = clrWhite)
  {
   string o = PREFIX + n;
   ObjectDelete(0, o);
   ObjectCreate(0, o, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, o, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, o, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, o, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, o, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, o, OBJPROP_YSIZE, h);
   ObjectSetString(0, o, OBJPROP_TEXT, t);
   ObjectSetInteger(0, o, OBJPROP_BGCOLOR, b);
   ObjectSetInteger(0, o, OBJPROP_COLOR, tc);
   ObjectSetInteger(0, o, OBJPROP_FONTSIZE, fs);
   ObjectSetString(0, o, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, o, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, o, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, o, OBJPROP_BORDER_TYPE, BORDER_FLAT);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void P_CreateDivider(int y, int px, int pw, int pad, string name)
  {
   string n = PREFIX + name;
   ObjectDelete(0, n);
   ObjectCreate(0, n, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, px + pad);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, pw - 2 * pad);
   ObjectSetInteger(0, n, OBJPROP_YSIZE, 1);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, UI_DIVIDER);
   ObjectSetInteger(0, n, OBJPROP_COLOR, UI_DIVIDER);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateFeatureButton(string name, string label, bool active)
  {
   string o = PREFIX + name;
   ObjectSetString(0, o, OBJPROP_TEXT, (active ? "● " : "○ ") + label);
   ObjectSetInteger(0, o, OBJPROP_BGCOLOR, active ? UI_ACTIVE_BG  : UI_INACTIVE_BG);
   ObjectSetInteger(0, o, OBJPROP_COLOR,   active ? UI_ACTIVE_TXT : UI_INACTIVE_TXT);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RefreshFeatureButtons()
  {
   UpdateFeatureButton("TogglePartial", "✂ PART",   g_usePartialClose);
   UpdateFeatureButton("ToggleSLMove",  "➡ SL-MV",  g_moveSLAfterPartial);
   UpdateFeatureButton("ToggleTrail",   "📈 TRAIL", g_useTrailing);
   UpdateFeatureButton("ToggleBE",      "🛡 BE",    g_useBreakEven);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateSecureButton()
  {
   string o = PREFIX + "SecureAll";
   ObjectSetString(0, o, OBJPROP_TEXT,    "🛡️ SECURE ALL");
   ObjectSetInteger(0, o, OBJPROP_BGCOLOR, UI_SECURE_BG);
   ObjectSetInteger(0, o, OBJPROP_COLOR,   UI_SECURE_TXT);
  }

//====================================================================
//  CREATE PANEL
//====================================================================
void CreatePanel()
  {
   if(panelCreated || !InpShowPanel)
      return;

   int px = 10;
   int py = 20;
   int pw = 210;

   int pad      = 6;
   int titleH   = 22;
   int secH     = 13;
   int btnH     = 20;
   int btnGap   = 3;

   int totalH = pad + titleH + 3
                + 24 + 16 + 3              // info rows (row1 = 24 for big timer)
                + 1 + 4
                + secH + 2
                + 2 * (btnH + btnGap)
                + 1 + 4
                + secH + 2
                + 3 * (btnH + btnGap)
                + 1 + 4
                + secH + 2
                + 1 * (btnH + btnGap)
                + 1 + 4
                + secH + 2
                + 2 * (btnH + btnGap)
                + 1 + 4
                + secH + 2
                + (btnH * 2) + btnGap
                + pad;

// ── Main background ──────────────────────────────────────────
   string bgName = PREFIX + "BG";
   ObjectCreate(0, bgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bgName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bgName, OBJPROP_XDISTANCE, px);
   ObjectSetInteger(0, bgName, OBJPROP_YDISTANCE, py);
   ObjectSetInteger(0, bgName, OBJPROP_XSIZE, pw);
   ObjectSetInteger(0, bgName, OBJPROP_YSIZE, totalH);
   ObjectSetInteger(0, bgName, OBJPROP_BGCOLOR, UI_BG);
   ObjectSetInteger(0, bgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bgName, OBJPROP_COLOR, UI_BORDER);
   ObjectSetInteger(0, bgName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bgName, OBJPROP_HIDDEN, true);

// ── Title bar ────────────────────────────────────────────────
   string tbg = PREFIX + "TBG";
   ObjectCreate(0, tbg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tbg, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, tbg, OBJPROP_XDISTANCE, px);
   ObjectSetInteger(0, tbg, OBJPROP_YDISTANCE, py);
   ObjectSetInteger(0, tbg, OBJPROP_XSIZE, pw);
   ObjectSetInteger(0, tbg, OBJPROP_YSIZE, titleH);
   ObjectSetInteger(0, tbg, OBJPROP_BGCOLOR, UI_TITLE_BG);
   ObjectSetInteger(0, tbg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, tbg, OBJPROP_COLOR, UI_TITLE_BORDER);
   ObjectSetInteger(0, tbg, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, tbg, OBJPROP_HIDDEN, true);

   P_CreateLabel("Title", px + 8, py + 4, "⚙  VrDz BOT PRO",
                 UI_TITLE_TXT, 9, "Arial Bold");
   P_CreateLabel("Ver", px + pw - 40, py + 6, "v1.23",
                 UI_TXT_DIM, 7, "Consolas");

   int yPos = py + pad + titleH + 3;

// ── Countdown row (enlarged + highlighted) ───────────────────
   string cdBg = PREFIX + "CDBG";
   ObjectCreate(0, cdBg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, cdBg, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, cdBg, OBJPROP_XDISTANCE, px + pad - 1);
   ObjectSetInteger(0, cdBg, OBJPROP_YDISTANCE, yPos - 1);
   ObjectSetInteger(0, cdBg, OBJPROP_XSIZE, pw - 2 * pad + 2);
   ObjectSetInteger(0, cdBg, OBJPROP_YSIZE, 22);
   ObjectSetInteger(0, cdBg, OBJPROP_BGCOLOR, UI_CD_BOX_BG);
   ObjectSetInteger(0, cdBg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, cdBg, OBJPROP_COLOR, UI_DIVIDER);
   ObjectSetInteger(0, cdBg, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, cdBg, OBJPROP_HIDDEN, true);

   P_CreateLabel("TimeNB", px + pad + 4, yPos + 2, "⏱ T- --:--",
                 InpCountdownColor, InpCountdownFont, "Consolas Bold");
   P_CreateLabel("Status", px + pad + 128, yPos + 6, "🟢 READY",
                 clrLime, 8, "Arial Bold");
   yPos += 24;

// ── Stats row ────────────────────────────────────────────────
   P_CreateLabel("Positions", px + pad, yPos, "P:0 $0.00",
                 UI_TXT, 7, "Consolas");
   P_CreateLabel("RSI", px + pad + 80, yPos, "R:--",
                 clrCyan, 7, "Consolas");
   P_CreateLabel("ATR", px + pad + 118, yPos, "A:--",
                 UI_ATR_TXT, 7, "Consolas");
   P_CreateLabel("Spread", px + pad + 152, yPos, "S:--",
                 UI_SPREAD_TXT, 7, "Consolas");
   yPos += 16;

   yPos += 3;
   P_CreateDivider(yPos, px, pw, pad, "SEP0");
   yPos += 4;

   int btnW = (pw - 3 * pad) / 2;

// ═══ FEATURES ═══
   P_CreateLabel("SecFeat", px + pad, yPos, "🎨 FEATURES",
                 UI_SECTION, 7, "Arial Bold");
   yPos += secH + 2;

   P_CreateButton("TogglePartial", px + pad, yPos, btnW, btnH,
                  g_usePartialClose ? "● ✂ PART" : "○ ✂ PART",
                  g_usePartialClose ? UI_ACTIVE_BG : UI_INACTIVE_BG, 7,
                  g_usePartialClose ? UI_ACTIVE_TXT : UI_INACTIVE_TXT);
   P_CreateButton("ToggleSLMove", px + pad + btnW + pad, yPos, btnW, btnH,
                  g_moveSLAfterPartial ? "● ➡ SL-MV" : "○ ➡ SL-MV",
                  g_moveSLAfterPartial ? UI_ACTIVE_BG : UI_INACTIVE_BG, 7,
                  g_moveSLAfterPartial ? UI_ACTIVE_TXT : UI_INACTIVE_TXT);
   yPos += btnH + btnGap;

   P_CreateButton("ToggleTrail", px + pad, yPos, btnW, btnH,
                  g_useTrailing ? "● 📈 TRAIL" : "○ 📈 TRAIL",
                  g_useTrailing ? UI_ACTIVE_BG : UI_INACTIVE_BG, 7,
                  g_useTrailing ? UI_ACTIVE_TXT : UI_INACTIVE_TXT);
   P_CreateButton("ToggleBE", px + pad + btnW + pad, yPos, btnW, btnH,
                  g_useBreakEven ? "● 🛡 BE" : "○ 🛡 BE",
                  g_useBreakEven ? UI_ACTIVE_BG : UI_INACTIVE_BG, 7,
                  g_useBreakEven ? UI_ACTIVE_TXT : UI_INACTIVE_TXT);
   yPos += btnH + btnGap;

   yPos += 3;
   P_CreateDivider(yPos, px, pw, pad, "SEP1");
   yPos += 4;

// ═══ POSITIONS ═══
   P_CreateLabel("SecPos", px + pad, yPos, "🎛️ POSITIONS",
                 UI_SECTION, 7, "Arial Bold");
   yPos += secH + 2;

   P_CreateButton("CloseAll",  px + pad, yPos, btnW, btnH,
                  "CLOSE ALL", UI_CLOSE_SELL, 7);
   P_CreateButton("CloseProf", px + pad + btnW + pad, yPos, btnW, btnH,
                  "CLOSE PRF", UI_CLOSE_PRF, 7);
   yPos += btnH + btnGap;

   P_CreateButton("CloseBuy",  px + pad, yPos, btnW, btnH,
                  "CLOSE BUY", UI_CLOSE_BUY, 7);
   P_CreateButton("CloseSell", px + pad + btnW + pad, yPos, btnW, btnH,
                  "CLOSE SELL", UI_CLOSE_SELL, 7);
   yPos += btnH + btnGap;

   P_CreateButton("DeleteOrders", px + pad, yPos, pw - 2 * pad, btnH,
                  "DELETE PENDING", UI_DELETE_BG, 7, UI_DELETE_TXT);
   yPos += btnH + btnGap;

   yPos += 3;
   P_CreateDivider(yPos, px, pw, pad, "SEP2");
   yPos += 4;

// ═══ MANUAL ═══
   P_CreateLabel("SecMan", px + pad, yPos, "💼 MANUAL",
                 UI_SECTION, 7, "Arial Bold");
   yPos += secH + 2;

   P_CreateButton("ManualBuy",  px + pad, yPos, btnW, btnH,
                  "BUY",  UI_BUY, 10);
   P_CreateButton("ManualSell", px + pad + btnW + pad, yPos, btnW, btnH,
                  "SELL", UI_SELL, 10);
   yPos += btnH + btnGap;

   yPos += 3;
   P_CreateDivider(yPos, px, pw, pad, "SEP3");
   yPos += 4;

// ═══ SAFETY ═══
   P_CreateLabel("SecSafe", px + pad, yPos, "🔒 SAFETY",
                 UI_SECTION, 7, "Arial Bold");
   yPos += secH + 2;

   P_CreateButton("SecureAll", px + pad, yPos, pw - 2 * pad, btnH,
                  "🛡️ SECURE ALL", UI_SECURE_BG, 7, UI_SECURE_TXT);
   yPos += btnH + btnGap;

   P_CreateButton("ToggleNoSL", px + pad, yPos, pw - 2 * pad, btnH,
                  g_noSL ? "✅ ENABLE SL" : "❌ REMOVE SL",
                  g_noSL ? UI_ACTIVE_BG : UI_NOSL_WARN_BG, 7,
                  g_noSL ? UI_ACTIVE_TXT : UI_NOSL_WARN_TX);
   yPos += btnH + btnGap;

   yPos += 3;
   P_CreateDivider(yPos, px, pw, pad, "SEP4");
   yPos += 4;

// ═══ SCALP / SWING ═══
   P_CreateLabel("SecScalp", px + pad, yPos, "⚡ SCALP / SWING",
                 UI_SECTION, 7, "Arial Bold");
   yPos += secH + 2;

   P_CreateButton("ToggleScalp", px + pad, yPos, pw - 2 * pad, btnH * 2,
                  g_scalpMode ? "⚡ SWING: ON" : "⚡ SCALP: OFF",
                  g_scalpMode ? UI_SWING_ON_BG : UI_SWING_OFF_BG,
                  12,
                  g_scalpMode ? UI_SWING_ON_TX : UI_SWING_OFF_TX);

   panelCreated = true;
   UpdateSecureButton();
   RefreshFeatureButtons();

   ChartRedraw();
   Print("[PANEL] ✅ Panel v1.23 - SCALP / SWING + SECURE Always ON ready");
  }

//====================================================================
//  UPDATE PANEL
//====================================================================
void UpdatePanel()
  {
   if(!panelCreated)
      return;

   int    pos = 0;
   double pnl = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0)
         continue;
      if(PositionSelectByTicket(t) &&
         PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
        {
         pos++;
         pnl += PositionGetDouble(POSITION_PROFIT);
        }
     }

   ObjectSetString(0, PREFIX + "Positions", OBJPROP_TEXT,
                   StringFormat("P:%d $%.2f", pos, pnl));
   ObjectSetInteger(0, PREFIX + "Positions", OBJPROP_COLOR,
                    pnl >= 0 ? clrLime : clrRed);

   double rsi = GetRSI();
   color  rsiColor = clrCyan;
   if(rsi >= InpRSIS)
      rsiColor = clrRed;
   else
      if(rsi <= InpRSIB)
         rsiColor = clrLime;
   ObjectSetString(0, PREFIX + "RSI", OBJPROP_TEXT,
                   StringFormat("R:%.0f", rsi));
   ObjectSetInteger(0, PREFIX + "RSI", OBJPROP_COLOR, rsiColor);

   double atr = GetATR();
   ObjectSetString(0, PREFIX + "ATR", OBJPROP_TEXT,
                   StringFormat("A:%.2f", atr));

   double pt = GetPoint();
   double sp = (pt > 0)
               ? (SymbolInfoDouble(_Symbol, SYMBOL_ASK) -
                  SymbolInfoDouble(_Symbol, SYMBOL_BID)) / pt
               : 0;
   ObjectSetString(0, PREFIX + "Spread", OBJPROP_TEXT,
                   "S:" + IntegerToString((int)sp));

   string st = "READY";
   color  stc = clrLime;
   string stIcon = "🟢";
   if(g_scalpMode)
     {
      st = "SWING";
      stc = clrOrange;
      stIcon = "⚡";
     }
   else
      if(g_noSL)
        {
         st = "NO-SL";
         stc = clrOrangeRed;
         stIcon = "🟠";
        }
      else
         if(sp > InpMaxSpread)
           {
            st = "SPREAD";
            stc = clrRed;
            stIcon = "🔴";
           }

   ObjectSetString(0, PREFIX + "Status", OBJPROP_TEXT, stIcon + " " + st);
   ObjectSetInteger(0, PREFIX + "Status", OBJPROP_COLOR, stc);

   ChartRedraw();
  }

//====================================================================
//  DELETE PANEL
//====================================================================
void DeletePanel()
  {
   ObjectsDeleteAll(0, PREFIX);
   panelCreated = false;
  }

//====================================================================
//  INIT
//====================================================================
int OnInit()
  {
   Print("═══════════════════════════════════════");
   Print("  VrDz Bot 1 Standalone v1.23");
   Print("  SCALP / SWING + SECURE Always ON");
   Print("═══════════════════════════════════════");

   if(!ValidateInputs())
      return INIT_PARAMETERS_INCORRECT;

   g_usePartialClose    = InpUsePartialClose;
   g_moveSLAfterPartial = InpMoveSLAfterPartial;
   g_useTrailing        = InpUseTrailing;
   g_useBreakEven       = InpUseBreakEven;
   g_noSL               = false;

   g_scalpMode         = false;
   g_hasSavedState     = false;
   g_savedPartialClose = g_usePartialClose;
   g_savedSLMove       = g_moveSLAfterPartial;
   g_savedTrailing     = g_useTrailing;
   g_savedBreakEven    = g_useBreakEven;

   Trade.SetExpertMagicNumber(InpMagicNumber);
   Trade.SetDeviationInPoints(InpDeviationInPoints);
   Trade.SetTypeFillingBySymbol(_Symbol);
   Trade.SetAsyncMode(false);

   rsiHandle = iRSI(_Symbol, _Period, InpRSIPeriod, PRICE_CLOSE);
   atrHandle = iATR(_Symbol, _Period, InpATRPeriod);

   if(rsiHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE)
     {
      Print("[ERROR] Failed to create indicators");
      return INIT_FAILED;
     }

   ArrayResize(partialClosedTickets, 50, 50);
   partialClosedCount = 0;

   dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(dayStartBalance <= 0)
      dayStartBalance = 1.0;

   CreatePanel();
   EventSetTimer(1);
   UpdateCountdown(true);

   return INIT_SUCCEEDED;
  }

//====================================================================
//  DEINIT
//====================================================================
void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeletePanel();
   if(rsiHandle != INVALID_HANDLE)
      IndicatorRelease(rsiHandle);
   if(atrHandle != INVALID_HANDLE)
      IndicatorRelease(atrHandle);
   Print("[DEINIT] reason=", reason);
  }

//====================================================================
//  TICK
//====================================================================
void OnTick()
  {
   ManagePositions();

   static datetime lastUI = 0;
   if(TimeCurrent() - lastUI >= 1)
     {
      UpdatePanel();
      lastUI = TimeCurrent();
     }
  }

//====================================================================
//  TIMER
//====================================================================
void OnTimer()
  {
   UpdateCountdown(false);
  }

//====================================================================
//  CHART EVENT
//====================================================================
void OnChartEvent(const int id, const long &lp,
                  const double &dp, const string &sp)
  {
   if(id != CHARTEVENT_OBJECT_CLICK)
      return;
   if(StringFind(sp, PREFIX) != 0)
      return;

   string btn = StringSubstr(sp, StringLen(PREFIX));
   Print("[PANEL] Button pressed: ", btn);

// ═══ Prevent feature edits while in SWING mode ═══
   if(g_scalpMode && (btn == "TogglePartial" || btn == "ToggleSLMove" ||
                      btn == "ToggleTrail"   || btn == "ToggleBE"))
     {
      Print("[PANEL] ⚡ SWING: FEATURES buttons are locked");
      ObjectSetInteger(0, sp, OBJPROP_STATE, false);
      ChartRedraw();
      return;
     }

// ═══ POSITIONS ═══
   if(btn == "CloseAll")
     {
      CloseAllPositions();
      ObjectSetInteger(0,sp,OBJPROP_STATE,false);
      ChartRedraw();
      return;
     }
   if(btn == "CloseProf")
     {
      CloseProfitablePositions();
      ObjectSetInteger(0,sp,OBJPROP_STATE,false);
      ChartRedraw();
      return;
     }
   if(btn == "CloseBuy")
     {
      ClosePositionsByType(POSITION_TYPE_BUY);
      ObjectSetInteger(0,sp,OBJPROP_STATE,false);
      ChartRedraw();
      return;
     }
   if(btn == "CloseSell")
     {
      ClosePositionsByType(POSITION_TYPE_SELL);
      ObjectSetInteger(0,sp,OBJPROP_STATE,false);
      ChartRedraw();
      return;
     }
   if(btn == "DeleteOrders")
     {
      DeleteAllPendingOrders();
      ObjectSetInteger(0,sp,OBJPROP_STATE,false);
      ChartRedraw();
      return;
     }

// ═══ SAFETY ═══
   if(btn == "SecureAll")
     {
      SecureAllPositions();
      ObjectSetInteger(0,sp,OBJPROP_STATE,false);
      ChartRedraw();
      return;
     }

   if(btn == "ToggleNoSL")
     {
      g_noSL = !g_noSL;
      if(g_noSL)
        {
         RemoveAllStopLosses();
         ObjectSetString(0, sp, OBJPROP_TEXT, "✅ ENABLE SL");
         ObjectSetInteger(0, sp, OBJPROP_BGCOLOR, UI_ACTIVE_BG);
         ObjectSetInteger(0, sp, OBJPROP_COLOR,   UI_ACTIVE_TXT);
        }
      else
        {
         ObjectSetString(0, sp, OBJPROP_TEXT, "❌ REMOVE SL");
         ObjectSetInteger(0, sp, OBJPROP_BGCOLOR, UI_NOSL_WARN_BG);
         ObjectSetInteger(0, sp, OBJPROP_COLOR,   UI_NOSL_WARN_TX);
        }
      ObjectSetInteger(0, sp, OBJPROP_STATE, false);
      UpdatePanel();
      ChartRedraw();
      return;
     }

// ═══ SCALP ↔ SWING ═══
   if(btn == "ToggleScalp")
     {
      g_scalpMode = !g_scalpMode;

      if(g_scalpMode)
        {
         // ─── Entering SWING ───
         g_savedPartialClose = g_usePartialClose;
         g_savedSLMove       = g_moveSLAfterPartial;
         g_savedTrailing     = g_useTrailing;
         g_savedBreakEven    = g_useBreakEven;
         g_hasSavedState     = true;

         g_usePartialClose    = false;
         g_moveSLAfterPartial = false;
         g_useTrailing        = false;
         g_useBreakEven       = false;

         Print("[PANEL] ⚡ SCALP→SWING: Converting open positions...");
         ApplySwingToOpenPositions();

         Print("[PANEL] ⚡ SWING ON: all features disabled + SWING SL/TP applied");
        }
      else
        {
         // ─── Returning to SCALP ───
         if(g_hasSavedState)
           {
            g_usePartialClose    = g_savedPartialClose;
            g_moveSLAfterPartial = g_savedSLMove;
            g_useTrailing        = g_savedTrailing;
            g_useBreakEven       = g_savedBreakEven;
            Print("[PANEL] ✅ SWING OFF: SCALP features restored");
           }
         Print("[PANEL] ℹ️ Open positions keep their SWING SL/TP");
        }

      RefreshFeatureButtons();
      UpdateSecureButton();

      ObjectSetString(0, sp, OBJPROP_TEXT,
                      g_scalpMode ? "⚡ SWING: ON" : "⚡ SCALP: OFF");
      ObjectSetInteger(0, sp, OBJPROP_BGCOLOR,
                       g_scalpMode ? UI_SWING_ON_BG : UI_SWING_OFF_BG);
      ObjectSetInteger(0, sp, OBJPROP_COLOR,
                       g_scalpMode ? UI_SWING_ON_TX : UI_SWING_OFF_TX);
      ObjectSetInteger(0, sp, OBJPROP_STATE, false);
      UpdatePanel();
      ChartRedraw();
      return;
     }

// ═══ FEATURES ═══
   if(btn == "TogglePartial")
     {
      g_usePartialClose = !g_usePartialClose;
      UpdateFeatureButton("TogglePartial", "✂ PART", g_usePartialClose);
      ObjectSetInteger(0, sp, OBJPROP_STATE, false);
      UpdatePanel();
      ChartRedraw();
      return;
     }

   if(btn == "ToggleSLMove")
     {
      g_moveSLAfterPartial = !g_moveSLAfterPartial;
      UpdateFeatureButton("ToggleSLMove", "➡ SL-MV", g_moveSLAfterPartial);
      ObjectSetInteger(0, sp, OBJPROP_STATE, false);
      UpdatePanel();
      ChartRedraw();
      return;
     }

   if(btn == "ToggleTrail")
     {
      g_useTrailing = !g_useTrailing;
      UpdateFeatureButton("ToggleTrail", "📈 TRAIL", g_useTrailing);
      ObjectSetInteger(0, sp, OBJPROP_STATE, false);
      UpdatePanel();
      ChartRedraw();
      return;
     }

   if(btn == "ToggleBE")
     {
      g_useBreakEven = !g_useBreakEven;
      UpdateFeatureButton("ToggleBE", "🛡 BE", g_useBreakEven);
      ObjectSetInteger(0, sp, OBJPROP_STATE, false);
      UpdatePanel();
      ChartRedraw();
      return;
     }

// ═══ MANUAL ═══
   if(btn == "ManualBuy")
     {
      OpenManualOrder(ORDER_TYPE_BUY);
      ObjectSetInteger(0,sp,OBJPROP_STATE,false);
      ChartRedraw();
      return;
     }
   if(btn == "ManualSell")
     {
      OpenManualOrder(ORDER_TYPE_SELL);
      ObjectSetInteger(0,sp,OBJPROP_STATE,false);
      ChartRedraw();
      return;
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
