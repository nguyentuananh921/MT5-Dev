//+------------------------------------------------------------------+
//|                                             ExampleTradingEA.mq5 |
//|                              Copyright 2026, Christian Benjamin. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Christian Benjamin."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "2.00"
#property strict

#include "Trade Authorization\DisciplineLayer.mqh"
#include "Trade Authorization\DisciplineGuardian.mqh"
#include "Trade Authorization\DisciplinePanel.mqh"

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input string   inp_Section1 = "Discipline Settings";
input int      inp_signalFreshnessMinutes = 15;
input bool     inp_useSessionFilter       = true;
input int      inp_sessionStartHour       = 8;
input int      inp_sessionStartMin        = 0;
input int      inp_sessionEndHour         = 17;
input int      inp_sessionEndMin          = 0;
input int      inp_setupExpirySeconds     = 1800;

input string   inp_Section2 = "Guardian Settings";
input ENUM_VIOLATION_MODE inp_violationMode = MODE_AUTO_CLOSE;

input string   inp_Section3 = "Strategy Settings";
input int      inp_fastMAPeriod          = 20;
input int      inp_slowMAPeriod          = 50;
input double   inp_lotSize               = 0.1;
input int      inp_magicNumber           = 123456;
input int      inp_formingDistancePoints  = 100;   // distance used to mark a setup as forming

input string   inp_Section4 = "Dashboard Settings";
input bool     inp_showDashboard = true;
input int      inp_dashboardX     = 10;
input int      inp_dashboardY     = 30;

//+------------------------------------------------------------------+
//| Global objects and variables                                     |
//+------------------------------------------------------------------+
CDisciplineLayer     g_Discipline;
CDisciplineGuardian  g_Guardian;
CDisciplinePanel     g_Panel;

int                  g_fastMAHandle   = INVALID_HANDLE;
int                  g_slowMAHandle   = INVALID_HANDLE;
bool                 g_setupConfirmed = false;
int                  g_setupDirection  = 0;   // 1 = BUY, -1 = SELL
datetime             g_lastBarTime    = 0;

//+------------------------------------------------------------------+
//| Helper: detect whether there is an open position on this symbol  |
//+------------------------------------------------------------------+
bool HasOpenPosition()
  {
   return PositionSelect(_Symbol);
  }

//+------------------------------------------------------------------+
//| Helper: choose a filling mode allowed by the symbol              |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING GetSymbolFillingType(const string symbol)
  {
   long filling = SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);

   if((filling & SYMBOL_FILLING_FOK) != 0)
      return ORDER_FILLING_FOK;

   if((filling & SYMBOL_FILLING_IOC) != 0)
      return ORDER_FILLING_IOC;

   return ORDER_FILLING_RETURN;
  }

//+------------------------------------------------------------------+
//| Helper: close an open position on the current symbol             |
//+------------------------------------------------------------------+
bool CloseCurrentPosition()
  {
   if(!PositionSelect(_Symbol))
      return true;

   long   posType = PositionGetInteger(POSITION_TYPE);
   double volume  = PositionGetDouble(POSITION_VOLUME);

   MqlTradeRequest req = {};
   MqlTradeResult  res = {};

   req.action       = TRADE_ACTION_DEAL;
   req.symbol       = _Symbol;
   req.volume       = volume;
   req.deviation    = 10;
   req.magic        = (ulong)inp_magicNumber;
   req.position     = (ulong)PositionGetInteger(POSITION_TICKET);
   req.type_filling = GetSymbolFillingType(_Symbol);

   if(posType == POSITION_TYPE_BUY)
     {
      req.type  = ORDER_TYPE_SELL;
      req.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
     }
   else
     {
      req.type  = ORDER_TYPE_BUY;
      req.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
     }

   if(OrderSend(req, res) && (res.retcode == TRADE_RETCODE_DONE || res.retcode == TRADE_RETCODE_PLACED))
     {
      Print("[TRADE] Existing position closed. Ticket=", res.order);
      return true;
     }

   Print("[TRADE] Failed to close position. Error=", GetLastError(),
         " retcode=", res.retcode,
         " comment=", res.comment);
   return false;
  }

//+------------------------------------------------------------------+
//| Executes a market order                                          |
//+------------------------------------------------------------------+
bool ExecuteTrade(int direction)
  {
   if(direction != 1 && direction != -1)
      return false;

//--- If there is already a position, handle it cleanly
   if(PositionSelect(_Symbol))
     {
      long currentType = PositionGetInteger(POSITION_TYPE);

      if((direction == 1 && currentType == POSITION_TYPE_BUY) ||
         (direction == -1 && currentType == POSITION_TYPE_SELL))
        {
         Print("[TRADE] Position already aligned with signal. No new entry.");
         return false;
        }

      if(!CloseCurrentPosition())
         return false;
     }

   MqlTradeRequest req = {};
   MqlTradeResult  res = {};

   req.action       = TRADE_ACTION_DEAL;
   req.symbol       = _Symbol;
   req.volume       = inp_lotSize;
   req.deviation    = 10;
   req.magic        = (ulong)inp_magicNumber;
   req.comment      = "Discipline SMA Crossover";
   req.type_time    = ORDER_TIME_GTC;
   req.type_filling = GetSymbolFillingType(_Symbol);

   if(direction > 0)
     {
      req.type  = ORDER_TYPE_BUY;
      req.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
     }
   else
     {
      req.type  = ORDER_TYPE_SELL;
      req.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
     }

   bool sent = OrderSend(req, res);

   if(sent && (res.retcode == TRADE_RETCODE_DONE || res.retcode == TRADE_RETCODE_PLACED))
     {
      Print("[TRADE] ", (direction > 0 ? "Buy" : "Sell"),
            " executed. Ticket=", res.order);
      return true;
     }

   Print("[TRADE] ", (direction > 0 ? "Buy" : "Sell"),
         " failed. Error=", GetLastError(),
         " retcode=", res.retcode,
         " comment=", res.comment);

   return false;
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_Discipline.SetSignalFreshnessMinutes(inp_signalFreshnessMinutes);

   if(inp_useSessionFilter)
      g_Discipline.EnableSessionFilter(inp_sessionStartHour, inp_sessionStartMin,
                                       inp_sessionEndHour, inp_sessionEndMin);
   else
      g_Discipline.DisableSessionFilter();

   g_Discipline.SetGlobalLockName("DISC_GLOBAL_LOCK");
   g_Discipline.Initialize();

   g_Guardian.SetGlobalLockPrefix("DISC_");
   g_Guardian.SetViolationMode(inp_violationMode);
   g_Guardian.Enable();

   if(inp_showDashboard)
     {
      g_Panel.Init("Disp", inp_dashboardX, inp_dashboardY, 380, clrDarkSlateGray, clrWhite);
      g_Panel.Show();
     }

   g_fastMAHandle = iMA(_Symbol, PERIOD_CURRENT, inp_fastMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
   g_slowMAHandle = iMA(_Symbol, PERIOD_CURRENT, inp_slowMAPeriod, 0, MODE_SMA, PRICE_CLOSE);

   if(g_fastMAHandle == INVALID_HANDLE || g_slowMAHandle == INVALID_HANDLE)
      return INIT_FAILED;

   EventSetTimer(2);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_fastMAHandle != INVALID_HANDLE)
      IndicatorRelease(g_fastMAHandle);

   if(g_slowMAHandle != INVALID_HANDLE)
      IndicatorRelease(g_slowMAHandle);

   EventKillTimer();
   g_Panel.Hide();
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   bool canTrade = g_Discipline.CanTrade();

   if(!canTrade)
      Print("[DISCIPLINE] Trade denied: ", g_Discipline.GetLastReasonText());

   g_Guardian.Enforce(canTrade);

   if(inp_showDashboard)
      g_Panel.Update(g_Discipline, inp_violationMode);
  }

//+------------------------------------------------------------------+
//| Tick function                                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(currentBarTime == g_lastBarTime)
      return;

   g_lastBarTime = currentBarTime;

   double fastMA[3];
   double slowMA[3];

   if(CopyBuffer(g_fastMAHandle, 0, 1, 3, fastMA) < 3 ||
      CopyBuffer(g_slowMAHandle, 0, 1, 3, slowMA) < 3)
      return;

//--- fastMA[0] = last closed candle
//--- fastMA[1] = candle before that

   bool bullishCross =
      (fastMA[0] > slowMA[0] &&
       fastMA[1] <= slowMA[1]);

   bool bearishCross =
      (fastMA[0] < slowMA[0] &&
       fastMA[1] >= slowMA[1]);

   bool setupForming =
      (MathAbs(fastMA[0] - slowMA[0]) / _Point <= inp_formingDistancePoints);

   if(setupForming && !bullishCross && !bearishCross)
      g_Discipline.SetSetupState(SETUP_FORMING);

   if(bullishCross)
     {
      datetime expiry = TimeCurrent() + inp_setupExpirySeconds;

      g_Discipline.ConfirmSetup(expiry);
      g_Discipline.SetSetupState(SETUP_CONFIRMED);

      g_setupConfirmed = true;
      g_setupDirection = 1;

      Print("[SETUP] Bullish SMA crossover confirmed. Valid until ",
            TimeToString(expiry, TIME_DATE | TIME_MINUTES));
     }
   else
      if(bearishCross)
        {
         datetime expiry = TimeCurrent() + inp_setupExpirySeconds;

         g_Discipline.ConfirmSetup(expiry);
         g_Discipline.SetSetupState(SETUP_CONFIRMED);

         g_setupConfirmed = true;
         g_setupDirection = -1;

         Print("[SETUP] Bearish SMA crossover confirmed. Valid until ",
               TimeToString(expiry, TIME_DATE | TIME_MINUTES));
        }
      else
         if(!setupForming && !g_setupConfirmed)
           {
            g_Discipline.SetSetupState(NO_SETUP);
           }

   if(g_setupConfirmed && g_Discipline.CanTrade())
     {
      if(ExecuteTrade(g_setupDirection))
        {
         g_setupConfirmed = false;
         g_Discipline.SetSetupState(SETUP_ACTIVE);
        }
     }

   if(g_setupConfirmed && g_Discipline.GetExpiryTime() > 0 && TimeCurrent() > g_Discipline.GetExpiryTime())
     {
      g_Discipline.ExpireSetup();
      g_setupConfirmed = false;
      g_setupDirection = 0;
     }
  }
//+------------------------------------------------------------------+
