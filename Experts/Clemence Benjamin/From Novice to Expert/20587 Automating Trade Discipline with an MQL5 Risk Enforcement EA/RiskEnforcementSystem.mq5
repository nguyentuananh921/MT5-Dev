//+------------------------------------------------------------------+
//|                                         RiskEnforcementSystem.mq5|
//|                                 Copyright 2025, Clemence Benjamin|
//+------------------------------------------------------------------+
#property copyright "2025 Clemence Benjamin"
#property description "A system that helps trading despline by controlling risk based on set measures"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#include <ChartObjects/ChartObjectsTxtControls.mqh>

CTrade trade;
CPositionInfo positionInfo;

//----------------- Inputs --------------------------------------------
input double InpDailyProfitLimit   = 100.0;   // Set your limit to 100
input double InpDailyLossLimit     = -300.0;
input double InpWeeklyProfitLimit  = 1000.0;
input double InpWeeklyLossLimit    = -1000.0;
input double InpMonthlyProfitLimit = 5000.0;
input double InpMonthlyLossLimit   = -5000.0;
input bool   InpCountFloatingPL    = true;    // Count floating P/L toward limits
input bool   InpAutoCloseOnStop    = true;
input int    InpConsecLossLimit    = 3;
input double InpMaxDrawdown        = 1000.0;
input double InpMaxPositionSize    = 1.0;     // Maximum lot size per position
input double InpMaxRiskPerTrade    = 0.02;    // 2% risk per trade
input double InpDefaultStopPoints  = 100.0;   // default SL (points) for risk calc
input string InpLogFileName        = "RiskEnforcer_Log.csv";
input bool   InpRequirePassword    = false;
input string InpAdminPassword      = "";
input bool   InpEnableAlerts       = true;    // Enable audible/visual alerts
input bool   InpResetDaily         = true;    // Auto-reset daily counters
input bool   InpResetWeekly        = true;    // Auto-reset weekly counters
input bool   InpResetMonthly       = true;    // Auto-reset monthly counters
input bool   InpAutoEngageOnStart  = true;    // Auto-engage on startup
input int    InpEmergencyRetryCount = 5;      // Retry attempts for emergency close
input bool   InpBlockAllSymbols    = true;    // Block trades on ALL symbols
input bool   InpForceCloseAllOnStop = true;   // Force close ALL positions immediately

//----------------- Globals & Names ----------------------------------
string GV_ENGAGED           = "RE_Engaged";
string GV_ALLOW             = "RE_AllowTrading";
string GV_DAILY_PL          = "RE_DailyPL";
string GV_DAILY_PROF        = "RE_DailyProfitLimit";
string GV_DAILY_LOSS        = "RE_DailyLossLimit";
string GV_WEEK_PROF         = "RE_WeekProfitLimit";
string GV_WEEK_LOSS         = "RE_WeekLossLimit";
string GV_MONTH_PROF        = "RE_MonthProfitLimit";
string GV_MONTH_LOSS        = "RE_MonthLossLimit";
string GV_SYMBOL_PROF       = "RE_SymbolProfitLimit";
string GV_SYMBOL_LOSS       = "RE_SymbolLossLimit";
string GV_CONSEC_LOSS       = "RE_ConsecLossCount";
string GV_CONSEC_WIN        = "RE_ConsecWinCount";
string GV_MAX_EQ            = "RE_MaxEquity";
string GV_HASHED_PASS       = "RE_HashedPassword";
string GV_LAST_RESET_DAY    = "RE_LastResetDay";
string GV_LAST_RESET_WEEK   = "RE_LastResetWeek";
string GV_LAST_RESET_MONTH  = "RE_LastResetMonth";
string GV_TOTAL_TRADES      = "RE_TotalTrades";
string GV_BLOCK_REASON      = "RE_BlockReason";
string GV_LAST_BLOCK_CHECK  = "RE_LastBlockCheck";
string GV_EMERGENCY_ACTIVE  = "RE_EmergencyActive";
string GV_BLOCK_EXPIRY      = "RE_BlockExpiry";

// UI object names
string OBJ_PANEL            = "RE_PANEL";
string OBJ_BTN_ENGAGE       = "RE_BTN_ENGAGE";
string OBJ_BTN_DISENG       = "RE_BTN_DISENG";
string OBJ_BTN_EMERGENCY    = "RE_BTN_EMERGENCY";
string OBJ_BTN_RESET        = "RE_BTN_RESET";
string OBJ_BTN_SAVE         = "RE_BTN_SAVE";

string OBJ_EDIT_DPROF = "RE_EDIT_DPROF";
string OBJ_EDIT_DLOSS = "RE_EDIT_DLOSS";
string OBJ_EDIT_WPROF = "RE_EDIT_WPROF";
string OBJ_EDIT_WLOSS = "RE_EDIT_WLOSS";
string OBJ_EDIT_MPROF = "RE_EDIT_MPROF";
string OBJ_EDIT_MLOSS = "RE_EDIT_MLOSS";
string OBJ_EDIT_SPROF = "RE_EDIT_SPROF";
string OBJ_EDIT_SLOSS = "RE_EDIT_SLOSS";
string OBJ_EDIT_PASS  = "RE_EDIT_PASS";

// Info label names
string OBJ_LABEL_INFO1 = "RE_LABEL_INFO1";
string OBJ_LABEL_INFO2 = "RE_LABEL_INFO2";
string OBJ_LABEL_INFO3 = "RE_LABEL_INFO3";
string OBJ_LABEL_INFO4 = "RE_LABEL_INFO4";
string OBJ_LABEL_INFO5 = "RE_LABEL_INFO5";
string OBJ_LABEL_INFO6 = "RE_LABEL_INFO6";
string OBJ_LABEL_INFO7 = "RE_LABEL_INFO7";
string OBJ_LABEL_INFO8 = "RE_LABEL_INFO8";
string OBJ_LABEL_INFO9 = "RE_LABEL_INFO9";
string OBJ_LABEL_INFO10 = "RE_LABEL_INFO10";
string OBJ_LABEL_INFO11 = "RE_LABEL_INFO11";
string OBJ_LABEL_INFO12 = "RE_LABEL_INFO12";
string OBJ_LABEL_INFO13 = "RE_LABEL_INFO13";
string OBJ_LABEL_INFO14 = "RE_LABEL_INFO14";
string OBJ_LABEL_INFO15 = "RE_LABEL_INFO15";

string OBJ_LABEL_INFO_BG = "RE_LABEL_INFO_BG";
string OBJ_LABEL_DPROF = "RE_LABEL_DPROF";
string OBJ_LABEL_DLOSS = "RE_LABEL_DLOSS";
string OBJ_LABEL_WPROF = "RE_LABEL_WPROF";
string OBJ_LABEL_WLOSS = "RE_LABEL_WLOSS";
string OBJ_LABEL_MPROF = "RE_LABEL_MPROF";
string OBJ_LABEL_MLOSS = "RE_LABEL_MLOSS";
string OBJ_LABEL_SPROF = "RE_LABEL_SPROF";
string OBJ_LABEL_SLOSS = "RE_LABEL_SLOSS";
string OBJ_LABEL_PASS  = "RE_LABEL_PASS";

int    logHandle = INVALID_HANDLE;
int    lastDay = -1;
int    lastWeek = -1;
int    lastMonth = -1;
bool   blockAlertShown = false;
bool   emergencyClosing = true;
int    emergencyRetryCounter = 0;
datetime lastTradeCheck = 0;

//----------------- Function Declarations -------------------------------
void   CreatePanel(void);
void   DeletePanel(void);
void   CreateLabel(string name, string text, int x, int y);
void   CreateButton(string name, string text, int x, int y, int w, int h, color bg);
void   CreateEditField(string name, string text, int x, int y, int w, int h);
double CalculateDailyPL(bool includeFloating);
double CalculateWeeklyPL(bool includeFloating);
double CalculateMonthlyPL(bool includeFloating);
double CalculateSymbolPL(string symbol, bool includeFloating);
void   UpdateAllowFlag(void);
void   LogLastDealToCSV(void);
void   AppendCSVLine(string line);
void   AutoCloseAllPositions(void);
void   CloseAllPositionsForSymbol(string symbol);
void   UpdateUIColors(void);
bool   IsNumericString(string s);
string HashPassword(string password);
bool   VerifyPassword(string provided);
void   CheckAndAlertLimits(void);
bool   CheckPositionSize(string symbol, double volume);
void   ResetDailyCounters(void);
void   ResetWeeklyCounters(void);
void   ResetMonthlyCounters(void);
void   CheckForAutoReset(void);
void   PlayAlertSound(void);
string CustomTrim(string text);
void   UpdateInfoDisplay(void);
bool   IsTradingAllowed(void);
void   EmergencyStop(void);
void   CloseAllPositionsWithRetry(void);
void   CloseNewTrades(void);
void   ForceCloseAllPositionsNow(void);
void   BlockNewTradesImmediately(void);

//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(123456);
   trade.SetDeviationInPoints(10);

   if(!GlobalVariableCheck(GV_ENGAGED))    GlobalVariableSet(GV_ENGAGED, InpAutoEngageOnStart ? 1.0 : 0.0);
   if(!GlobalVariableCheck(GV_ALLOW))      GlobalVariableSet(GV_ALLOW,1.0);
   if(!GlobalVariableCheck(GV_DAILY_PL))   GlobalVariableSet(GV_DAILY_PL,0.0);
   if(!GlobalVariableCheck(GV_TOTAL_TRADES)) GlobalVariableSet(GV_TOTAL_TRADES,0.0);

   if(!GlobalVariableCheck(GV_DAILY_PROF)) GlobalVariableSet(GV_DAILY_PROF,InpDailyProfitLimit);
   if(!GlobalVariableCheck(GV_DAILY_LOSS)) GlobalVariableSet(GV_DAILY_LOSS,InpDailyLossLimit);
   if(!GlobalVariableCheck(GV_WEEK_PROF))  GlobalVariableSet(GV_WEEK_PROF,InpWeeklyProfitLimit);
   if(!GlobalVariableCheck(GV_WEEK_LOSS))  GlobalVariableSet(GV_WEEK_LOSS,InpWeeklyLossLimit);
   if(!GlobalVariableCheck(GV_MONTH_PROF)) GlobalVariableSet(GV_MONTH_PROF,InpMonthlyProfitLimit);
   if(!GlobalVariableCheck(GV_MONTH_LOSS)) GlobalVariableSet(GV_MONTH_LOSS,InpMonthlyLossLimit);
   if(!GlobalVariableCheck(GV_SYMBOL_PROF)) GlobalVariableSet(GV_SYMBOL_PROF,InpDailyProfitLimit);
   if(!GlobalVariableCheck(GV_SYMBOL_LOSS)) GlobalVariableSet(GV_SYMBOL_LOSS,InpDailyLossLimit);

   if(!GlobalVariableCheck(GV_CONSEC_LOSS)) GlobalVariableSet(GV_CONSEC_LOSS,0.0);
   if(!GlobalVariableCheck(GV_CONSEC_WIN))  GlobalVariableSet(GV_CONSEC_WIN,0.0);
   
   if(!GlobalVariableCheck(GV_BLOCK_REASON)) GlobalVariableSet(GV_BLOCK_REASON, 0.0);
   if(!GlobalVariableCheck(GV_LAST_BLOCK_CHECK)) GlobalVariableSet(GV_LAST_BLOCK_CHECK, 0.0);
   if(!GlobalVariableCheck(GV_EMERGENCY_ACTIVE)) GlobalVariableSet(GV_EMERGENCY_ACTIVE, 0.0);
   if(!GlobalVariableCheck(GV_BLOCK_EXPIRY)) GlobalVariableSet(GV_BLOCK_EXPIRY, 0.0);

   MqlDateTime dtNow;
   TimeToStruct(TimeCurrent(), dtNow);

   if(!GlobalVariableCheck(GV_LAST_RESET_DAY))
      GlobalVariableSet(GV_LAST_RESET_DAY, (double)dtNow.day);
   if(!GlobalVariableCheck(GV_LAST_RESET_WEEK))
      GlobalVariableSet(GV_LAST_RESET_WEEK, (double)dtNow.day_of_week);
   if(!GlobalVariableCheck(GV_LAST_RESET_MONTH))
      GlobalVariableSet(GV_LAST_RESET_MONTH, (double)dtNow.mon);

   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   if(!GlobalVariableCheck(GV_MAX_EQ)) GlobalVariableSet(GV_MAX_EQ, eq);

   if(InpRequirePassword)
   {
      string hashed = HashPassword(InpAdminPassword);
      int file_handle = FileOpen("RiskEnforcer_Pass.txt", FILE_WRITE|FILE_TXT|FILE_ANSI);
      if(file_handle != INVALID_HANDLE)
      {
         FileWriteString(file_handle, hashed);
         FileClose(file_handle);
      }
      else
      {
         Print("[RiskEnforcer] Warning: Could not save password hash to file.");
      }
   }

   logHandle = FileOpen(InpLogFileName, FILE_WRITE|FILE_CSV|FILE_ANSI);
   if(logHandle == INVALID_HANDLE)
   {
      Print("[RiskEnforcer] Could not open or create log file: ", InpLogFileName);
   }
   else
   {
      if(FileTell(logHandle) == 0)
      {
         FileWrite(logHandle,"Timestamp","Event","Symbol","Type","Ticket","Volume","Price","Profit","DailyPL","AccountEquity");
         FileFlush(logHandle);
      }
      FileSeek(logHandle, 0, SEEK_END);
   }

   CreatePanel();
   UpdateAllowFlag();
   UpdateUIColors();
   UpdateInfoDisplay();

   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   lastDay = dt.day;
   lastWeek = (int)GlobalVariableGet(GV_LAST_RESET_WEEK);
   lastMonth = dt.mon;

   Print("[RiskEnforcer] Initialized successfully.");
   Print("[RiskEnforcer] Trading Allowed: ", (int)GlobalVariableGet(GV_ALLOW));
   Print("[RiskEnforcer] Engaged: ", (int)GlobalVariableGet(GV_ENGAGED));
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(logHandle != INVALID_HANDLE)
   {
      FileFlush(logHandle);
      FileClose(logHandle);
      logHandle = INVALID_HANDLE;
   }
   DeletePanel();
   Print("[RiskEnforcer] Deinitialized.");
}
//+------------------------------------------------------------------+
void OnTick()
{
   CheckForAutoReset();

   double dailyPL = CalculateDailyPL(InpCountFloatingPL);
   GlobalVariableSet(GV_DAILY_PL,dailyPL);

   UpdateAllowFlag();
   UpdateUIColors();
   UpdateInfoDisplay();

   if((int)GlobalVariableGet(GV_ALLOW) == 0)
   {
      if(TimeCurrent() - lastTradeCheck >= 3)
      {
         lastTradeCheck = TimeCurrent();
         
         int positions = PositionsTotal();
         if(positions > 0)
         {
            Print("[RiskEnforcer] Trading blocked - closing ", positions, " open position(s)");
            ForceCloseAllPositionsNow();
         }
         else
         {
            Print("[RiskEnforcer] Trading blocked - monitoring for new positions");
         }
      }
   }

   if((int)GlobalVariableGet(GV_ALLOW) == 0)
   {
      BlockNewTradesImmediately();
   }

   if(InpEnableAlerts)
      CheckAndAlertLimits();
      
   if((int)GlobalVariableGet(GV_ALLOW) == 0 && !blockAlertShown)
   {
      string reason = "Unknown";
      switch((int)GlobalVariableGet(GV_BLOCK_REASON))
      {
         case 1: reason = "Daily Profit Limit"; break;
         case 2: reason = "Daily Loss Limit"; break;
         case 3: reason = "Weekly Profit Limit"; break;
         case 4: reason = "Weekly Loss Limit"; break;
         case 5: reason = "Monthly Profit Limit"; break;
         case 6: reason = "Monthly Loss Limit"; break;
         case 7: reason = "Symbol Profit Limit"; break;
         case 8: reason = "Symbol Loss Limit"; break;
         case 9: reason = "Consecutive Losses"; break;
         case 10: reason = "Max Drawdown"; break;
         case 99: reason = "Emergency Stop"; break;
      }
      Alert("[RiskEnforcer] TRADING BLOCKED: ", reason);
      blockAlertShown = true;
   }
   else if((int)GlobalVariableGet(GV_ALLOW) == 1)
   {
      blockAlertShown = false;
   }
}
//+------------------------------------------------------------------+
void ForceCloseAllPositionsNow()
{
   int total = PositionsTotal();
   if(total <= 0) return;
   
   Print("[RiskEnforcer] FORCE CLOSING ALL POSITIONS NOW!");
   
   for(int i = total-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         string symbol = PositionGetString(POSITION_SYMBOL);
         double volume = PositionGetDouble(POSITION_VOLUME);
         
         if(trade.PositionClose(ticket))
         {
            PrintFormat("[RiskEnforcer] Closed position #%d for %s", ticket, symbol);
         }
      }
   }
   
   int remaining = PositionsTotal();
   if(remaining > 0)
   {
      Print("[RiskEnforcer] Normal close failed, using opposite orders...");
      
      for(int i = remaining-1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket > 0 && PositionSelectByTicket(ticket))
         {
            string symbol = PositionGetString(POSITION_SYMBOL);
            double volume = PositionGetDouble(POSITION_VOLUME);
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            
            if(type == POSITION_TYPE_BUY)
            {
               trade.Sell(volume, symbol, 0, 0, 0, "FORCE CLOSE");
               PrintFormat("[RiskEnforcer] Sent SELL order to close buy position on %s", symbol);
            }
            else if(type == POSITION_TYPE_SELL)
            {
               trade.Buy(volume, symbol, 0, 0, 0, "FORCE CLOSE");
               PrintFormat("[RiskEnforcer] Sent BUY order to close sell position on %s", symbol);
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
void BlockNewTradesImmediately()
{
   int total = PositionsTotal();
   
   for(int i = total-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         string symbol = PositionGetString(POSITION_SYMBOL);
         double volume = PositionGetDouble(POSITION_VOLUME);
         
         datetime posTime = (datetime)PositionGetInteger(POSITION_TIME);
         datetime lastCheck = (datetime)GlobalVariableGet(GV_LAST_BLOCK_CHECK);
         
         if(posTime > lastCheck)
         {
            PrintFormat("[RiskEnforcer] BLOCKED TRADE DETECTED: Closing position #%d opened at %s", 
                       ticket, TimeToString(posTime));
            
            if(trade.PositionClose(ticket))
            {
               PrintFormat("[RiskEnforcer] Successfully closed blocked position #%d", ticket);
            }
            else
            {
               ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               if(type == POSITION_TYPE_BUY)
               {
                  trade.Sell(volume, symbol, 0, 0, 0, "BLOCKED TRADE");
               }
               else if(type == POSITION_TYPE_SELL)
               {
                  trade.Buy(volume, symbol, 0, 0, 0, "BLOCKED TRADE");
               }
               PrintFormat("[RiskEnforcer] Sent opposite order to close blocked position #%d", ticket);
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
void EmergencyStop()
{
   Print("[RiskEnforcer] ===== EMERGENCY STOP ACTIVATED =====");
   Print("[RiskEnforcer] This will close ALL positions and block ALL trading!");
   
   GlobalVariableSet(GV_EMERGENCY_ACTIVE, 1.0);
   GlobalVariableSet(GV_BLOCK_REASON, 99.0);
   GlobalVariableSet(GV_ALLOW, 0.0);
   GlobalVariableSet(GV_ENGAGED, 1.0);
   
   GlobalVariableSet(GV_LAST_BLOCK_CHECK, (double)TimeCurrent());
   GlobalVariableSet(GV_BLOCK_EXPIRY, (double)(TimeCurrent() + 86400 * 365));
   
   ForceCloseAllPositionsNow();
   
   for(int i = 0; i < 3; i++)
   {
      Alert("[RiskEnforcer] EMERGENCY STOP ACTIVATED! ALL positions closed, trading blocked.");
      Sleep(100);
   }
   
   Print("[RiskEnforcer] ===== EMERGENCY STOP COMPLETE =====");
   Print("[RiskEnforcer] Trading is now BLOCKED. Click 'Reset Counters' to resume.");
}
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      ulong dealTicket = trans.deal;
      double profit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
      string symbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
      ENUM_DEAL_ENTRY entryType = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
      
      LogLastDealToCSV();
      
      if((int)GlobalVariableGet(GV_ALLOW) == 0)
      {
         if(entryType == DEAL_ENTRY_IN)
         {
            Print("[RiskEnforcer] WARNING: Trade executed while blocked! Closing immediately...");
            
            int total = PositionsTotal();
            for(int i = 0; i < total; i++)
            {
               ulong posTicket = PositionGetTicket(i);
               if(posTicket > 0 && PositionSelectByTicket(posTicket))
               {
                  string posSymbol = PositionGetString(POSITION_SYMBOL);
                  if(posSymbol == symbol)
                  {
                     if(!trade.PositionClose(posTicket))
                     {
                        double volume = PositionGetDouble(POSITION_VOLUME);
                        ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
                        
                        if(type == POSITION_TYPE_BUY)
                        {
                           trade.Sell(volume, symbol, 0, 0, 0, "BLOCKED");
                        }
                        else if(type == POSITION_TYPE_SELL)
                        {
                           trade.Buy(volume, symbol, 0, 0, 0, "BLOCKED");
                        }
                     }
                     PrintFormat("[RiskEnforcer] Blocked trade #%d closed", posTicket);
                     break;
                  }
               }
            }
         }
      }
      
      if(profit > 0)
      {
         int wins = (int)GlobalVariableGet(GV_CONSEC_WIN);
         wins++;
         GlobalVariableSet(GV_CONSEC_WIN, (double)wins);
         GlobalVariableSet(GV_CONSEC_LOSS, 0.0);
      }
      else if(profit < 0)
      {
         int losses = (int)GlobalVariableGet(GV_CONSEC_LOSS);
         losses++;
         GlobalVariableSet(GV_CONSEC_LOSS, (double)losses);
         GlobalVariableSet(GV_CONSEC_WIN, 0.0);
      }

      double eq = AccountInfoDouble(ACCOUNT_EQUITY);
      double maxEq = GlobalVariableGet(GV_MAX_EQ);
      if(eq > maxEq) GlobalVariableSet(GV_MAX_EQ, eq);

      int totalTrades = (int)GlobalVariableGet(GV_TOTAL_TRADES);
      totalTrades++;
      GlobalVariableSet(GV_TOTAL_TRADES, (double)totalTrades);

      double dailyPL = CalculateDailyPL(InpCountFloatingPL);
      GlobalVariableSet(GV_DAILY_PL, dailyPL);

      UpdateInfoDisplay();

      if(GlobalVariableGet(GV_ALLOW) == 0)
      {
         if(InpAutoCloseOnStop) 
         {
            Print("[RiskEnforcer] Trading blocked - closing any open positions...");
            ForceCloseAllPositionsNow();
         }
      }
   }
}
//+------------------------------------------------------------------+
void CreateButton(string name, string text, int x, int y, int w, int h, color bg)
{
   if(ObjectFind(0,name) < 0)
   {
      ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrWhite);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,9);
   }
}
//+------------------------------------------------------------------+
void CreateEditField(string name, string text, int x, int y, int w, int h)
{
   if(ObjectFind(0,name) < 0)
   {
      ObjectCreate(0,name,OBJ_EDIT,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,9);
      ObjectSetInteger(0,name,OBJPROP_ALIGN,ALIGN_RIGHT);
   }
}
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y)
{
   if(ObjectFind(0,name) < 0)
   {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,9);
      ObjectSetInteger(0,name,OBJPROP_ALIGN,ALIGN_LEFT);
   }
}
//+------------------------------------------------------------------+
void UpdateInfoDisplay()
{
   double dailyPL = GlobalVariableGet(GV_DAILY_PL);
   double weeklyPL = CalculateWeeklyPL(InpCountFloatingPL);
   double monthlyPL = CalculateMonthlyPL(InpCountFloatingPL);
   
   string statusAllow = (int)GlobalVariableGet(GV_ALLOW) == 1 ? "ALLOWED" : "BLOCKED";
   string statusEngaged = (int)GlobalVariableGet(GV_ENGAGED) == 1 ? "ENGAGED" : "DISENGAGED";
   
   string blockReason = "";
   switch((int)GlobalVariableGet(GV_BLOCK_REASON))
   {
      case 1: blockReason = "Daily Profit"; break;
      case 2: blockReason = "Daily Loss"; break;
      case 3: blockReason = "Weekly Profit"; break;
      case 4: blockReason = "Weekly Loss"; break;
      case 5: blockReason = "Monthly Profit"; break;
      case 6: blockReason = "Monthly Loss"; break;
      case 7: blockReason = "Symbol Profit"; break;
      case 8: blockReason = "Symbol Loss"; break;
      case 9: blockReason = "Consec Losses"; break;
      case 10: blockReason = "Max Drawdown"; break;
      case 99: blockReason = "EMERG STOP"; break;
      default: blockReason = "None"; break;
   }
   
   if(ObjectFind(0, OBJ_LABEL_INFO1) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO1, OBJPROP_TEXT, "RISK ENFORCEMENT SYSTEM");
   
   if(ObjectFind(0, OBJ_LABEL_INFO2) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO2, OBJPROP_TEXT, "");
   
   if(ObjectFind(0, OBJ_LABEL_INFO3) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO3, OBJPROP_TEXT, StringFormat("DAILY P/L:           $%.2f", dailyPL));
   
   if(ObjectFind(0, OBJ_LABEL_INFO4) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO4, OBJPROP_TEXT, StringFormat("Daily Profit Limit:  $%.2f", GlobalVariableGet(GV_DAILY_PROF)));
   
   if(ObjectFind(0, OBJ_LABEL_INFO5) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO5, OBJPROP_TEXT, StringFormat("Daily Loss Limit:    $%.2f", GlobalVariableGet(GV_DAILY_LOSS)));
   
   if(ObjectFind(0, OBJ_LABEL_INFO6) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO6, OBJPROP_TEXT, "");
   
   if(ObjectFind(0, OBJ_LABEL_INFO7) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO7, OBJPROP_TEXT, StringFormat("WEEKLY P/L:          $%.2f", weeklyPL));
   
   if(ObjectFind(0, OBJ_LABEL_INFO8) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO8, OBJPROP_TEXT, StringFormat("MONTHLY P/L:         $%.2f", monthlyPL));
   
   if(ObjectFind(0, OBJ_LABEL_INFO9) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO9, OBJPROP_TEXT, "");
   
   if(ObjectFind(0, OBJ_LABEL_INFO10) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO10, OBJPROP_TEXT, StringFormat("STATUS:              %s", statusAllow));
   
   if(ObjectFind(0, OBJ_LABEL_INFO11) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO11, OBJPROP_TEXT, StringFormat("ENFORCEMENT:         %s", statusEngaged));
   
   if(ObjectFind(0, OBJ_LABEL_INFO12) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO12, OBJPROP_TEXT, "");
   
   if(ObjectFind(0, OBJ_LABEL_INFO13) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO13, OBJPROP_TEXT, StringFormat("Consecutive Losses:  %d", (int)GlobalVariableGet(GV_CONSEC_LOSS)));
   
   if(ObjectFind(0, OBJ_LABEL_INFO14) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO14, OBJPROP_TEXT, StringFormat("Consecutive Wins:    %d", (int)GlobalVariableGet(GV_CONSEC_WIN)));
   
   if(ObjectFind(0, OBJ_LABEL_INFO15) >= 0)
      ObjectSetString(0, OBJ_LABEL_INFO15, OBJPROP_TEXT, StringFormat("BLOCK REASON:        %s", blockReason));
}
//+------------------------------------------------------------------+
void CreatePanel()
{
   int panelX = 10;
   int panelY = 30;
   int panelW = 500;
   int panelH = 500;

   if(ObjectFind(0,OBJ_PANEL) < 0)
   {
      ObjectCreate(0,OBJ_PANEL,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,OBJ_PANEL,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,OBJ_PANEL,OBJPROP_XDISTANCE,panelX);
      ObjectSetInteger(0,OBJ_PANEL,OBJPROP_YDISTANCE,panelY);
      ObjectSetInteger(0,OBJ_PANEL,OBJPROP_XSIZE,panelW);
      ObjectSetInteger(0,OBJ_PANEL,OBJPROP_YSIZE,panelH);
      ObjectSetInteger(0,OBJ_PANEL,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,OBJ_PANEL,OBJPROP_BORDER_COLOR,clrGray);
      ObjectSetInteger(0,OBJ_PANEL,OBJPROP_BGCOLOR,clrWhite);
      ObjectSetInteger(0,OBJ_PANEL,OBJPROP_COLOR,clrWhite);
      ObjectSetInteger(0,OBJ_PANEL,OBJPROP_ZORDER,0);
   }

   int innerPad = 12;
   int localX = panelX + innerPad;
   int localY = panelY + innerPad + 6;
   int colGap = 150;
   int secondColX = panelX + panelW/2 + 20;
   int rowHeight = 22;
   int editW = 90;
   int editH = 18;
   int btnH = 22;

   CreateLabel(OBJ_LABEL_DPROF, "Daily Profit:", localX, localY + 0*rowHeight);
   CreateEditField(OBJ_EDIT_DPROF, DoubleToString(GlobalVariableGet(GV_DAILY_PROF),2), localX + colGap, localY + 0*rowHeight, editW, editH);
   CreateLabel(OBJ_LABEL_DLOSS, "Daily Loss:", secondColX, localY + 0*rowHeight);
   CreateEditField(OBJ_EDIT_DLOSS, DoubleToString(GlobalVariableGet(GV_DAILY_LOSS),2), secondColX + colGap - 60, localY + 0*rowHeight, editW, editH);

   CreateLabel(OBJ_LABEL_WPROF, "Weekly Profit:", localX, localY + 1*rowHeight);
   CreateEditField(OBJ_EDIT_WPROF, DoubleToString(GlobalVariableGet(GV_WEEK_PROF),2), localX + colGap, localY + 1*rowHeight, editW, editH);
   CreateLabel(OBJ_LABEL_WLOSS, "Weekly Loss:", secondColX, localY + 1*rowHeight);
   CreateEditField(OBJ_EDIT_WLOSS, DoubleToString(GlobalVariableGet(GV_WEEK_LOSS),2), secondColX + colGap - 60, localY + 1*rowHeight, editW, editH);

   CreateLabel(OBJ_LABEL_MPROF, "Monthly Profit:", localX, localY + 2*rowHeight);
   CreateEditField(OBJ_EDIT_MPROF, DoubleToString(GlobalVariableGet(GV_MONTH_PROF),2), localX + colGap, localY + 2*rowHeight, editW, editH);
   CreateLabel(OBJ_LABEL_MLOSS, "Monthly Loss:", secondColX, localY + 2*rowHeight);
   CreateEditField(OBJ_EDIT_MLOSS, DoubleToString(GlobalVariableGet(GV_MONTH_LOSS),2), secondColX + colGap - 60, localY + 2*rowHeight, editW, editH);

   CreateLabel(OBJ_LABEL_SPROF, "Symbol Profit:", localX, localY + 3*rowHeight);
   CreateEditField(OBJ_EDIT_SPROF, DoubleToString(GlobalVariableGet(GV_SYMBOL_PROF),2), localX + colGap, localY + 3*rowHeight, editW, editH);
   CreateLabel(OBJ_LABEL_SLOSS, "Symbol Loss:", secondColX, localY + 3*rowHeight);
   CreateEditField(OBJ_EDIT_SLOSS, DoubleToString(GlobalVariableGet(GV_SYMBOL_LOSS),2), secondColX + colGap - 60, localY + 3*rowHeight, editW, editH);

   if(InpRequirePassword)
   {
      CreateLabel(OBJ_LABEL_PASS, "Password:", panelX + panelW - innerPad - 180, localY + 0*rowHeight);
      CreateEditField(OBJ_EDIT_PASS, "", panelX + panelW - innerPad - 80, localY + 0*rowHeight, 100, editH);
      if(ObjectFind(0,OBJ_EDIT_PASS) >= 0) ObjectSetInteger(0,OBJ_EDIT_PASS,OBJPROP_ALIGN,ALIGN_CENTER);
   }

   int buttonsY = localY + 4*rowHeight + 8;
   CreateButton(OBJ_BTN_ENGAGE, "Engage", panelX + innerPad, buttonsY, 100, btnH, clrGreen);
   CreateButton(OBJ_BTN_DISENG, "Disengage", panelX + innerPad + 110, buttonsY, 100, btnH, C'80,80,80');
   CreateButton(OBJ_BTN_EMERGENCY, "EMERG STOP", panelX + innerPad + 220, buttonsY, 130, btnH, C'255,191,0');

   int actionY = buttonsY + btnH + 8;
   CreateButton(OBJ_BTN_SAVE, "Save Limits", panelX + innerPad, actionY, 120, btnH, clrBlue);
   CreateButton(OBJ_BTN_RESET, "Reset Counters", panelX + innerPad + 130, actionY, 130, btnH, C'204,102,0');

   int infoX = panelX + innerPad;
   int infoY = actionY + btnH + 12;
   int infoW = panelW - innerPad*2;
   int infoH = 280;
   
   if(ObjectFind(0,OBJ_LABEL_INFO_BG) < 0)
   {
      ObjectCreate(0, OBJ_LABEL_INFO_BG, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, OBJ_LABEL_INFO_BG, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, OBJ_LABEL_INFO_BG, OBJPROP_XDISTANCE, infoX);
      ObjectSetInteger(0, OBJ_LABEL_INFO_BG, OBJPROP_YDISTANCE, infoY);
      ObjectSetInteger(0, OBJ_LABEL_INFO_BG, OBJPROP_XSIZE, infoW);
      ObjectSetInteger(0, OBJ_LABEL_INFO_BG, OBJPROP_YSIZE, infoH);
      ObjectSetInteger(0, OBJ_LABEL_INFO_BG, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, OBJ_LABEL_INFO_BG, OBJPROP_BORDER_COLOR, clrSilver);
      ObjectSetInteger(0, OBJ_LABEL_INFO_BG, OBJPROP_BGCOLOR, clrWhite);
      ObjectSetInteger(0, OBJ_LABEL_INFO_BG, OBJPROP_ZORDER, 1);
   }

   int lineHeight = 18;
   int startY = infoY + 8;
   
   for(int i = 1; i <= 15; i++)
   {
      string labelName = "RE_LABEL_INFO" + IntegerToString(i);
      if(ObjectFind(0, labelName) < 0)
      {
         CreateLabel(labelName, "", infoX + 8, startY + (i-1)*lineHeight);
         ObjectSetInteger(0, labelName, OBJPROP_ZORDER, 2);
         if(i == 1)
         {
            ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 10);
            ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrDarkBlue);
         }
         else
         {
            ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
         }
      }
   }
}
//+------------------------------------------------------------------+
void DeletePanel()
{
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, "RE_") == 0)
      {
         ObjectDelete(0, name);
      }
   }
}
//+------------------------------------------------------------------+
double CalculateDailyPL(bool includeFloating)
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   datetime start = StructToTime(dt);

   double total = 0.0;
   HistorySelect(start,TimeCurrent());
   int deals = HistoryDealsTotal();
   for(int i=0;i<deals;i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket==0) continue;
      datetime t = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      if(t < start) continue;
      total += HistoryDealGetDouble(ticket,DEAL_PROFIT);
   }

   if(includeFloating)
   {
      int pcount = PositionsTotal();
      for(int k=0; k<pcount; k++)
      {
         ulong ticket = PositionGetTicket(k);
         if(ticket > 0 && PositionSelectByTicket(ticket))
         {
            total += PositionGetDouble(POSITION_PROFIT);
         }
      }
   }
   return(total);
}
//+------------------------------------------------------------------+
double CalculateWeeklyPL(bool includeFloating)
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   int daysSinceMonday = dt.day_of_week - 1;
   if(daysSinceMonday < 0) daysSinceMonday = 6;

   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   datetime weekStart = StructToTime(dt) - daysSinceMonday * 86400;

   double total = 0.0;
   HistorySelect(weekStart,TimeCurrent());
   int deals = HistoryDealsTotal();
   for(int i=0;i<deals;i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket==0) continue;
      datetime t = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      if(t < weekStart) continue;
      total += HistoryDealGetDouble(ticket,DEAL_PROFIT);
   }

   if(includeFloating)
   {
      int pcount = PositionsTotal();
      for(int k=0; k<pcount; k++)
      {
         ulong ticket = PositionGetTicket(k);
         if(ticket > 0 && PositionSelectByTicket(ticket))
         {
            total += PositionGetDouble(POSITION_PROFIT);
         }
      }
   }
   return(total);
}
//+------------------------------------------------------------------+
double CalculateMonthlyPL(bool includeFloating)
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   dt.day = 1; dt.hour = 0; dt.min = 0; dt.sec = 0;
   datetime monthStart = StructToTime(dt);

   double total = 0.0;
   HistorySelect(monthStart,TimeCurrent());
   int deals = HistoryDealsTotal();
   for(int i=0;i<deals;i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket==0) continue;
      datetime t = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      if(t < monthStart) continue;
      total += HistoryDealGetDouble(ticket,DEAL_PROFIT);
   }

   if(includeFloating)
   {
      int pcount = PositionsTotal();
      for(int k=0; k<pcount; k++)
      {
         ulong ticket = PositionGetTicket(k);
         if(ticket > 0 && PositionSelectByTicket(ticket))
         {
            total += PositionGetDouble(POSITION_PROFIT);
         }
      }
   }
   return(total);
}
//+------------------------------------------------------------------+
double CalculateSymbolPL(string symbol, bool includeFloating)
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   dt.hour=0; dt.min=0; dt.sec=0;
   datetime start = StructToTime(dt);

   double total = 0.0;
   HistorySelect(start,TimeCurrent());
   int deals = HistoryDealsTotal();
   for(int i=0;i<deals;i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket==0) continue;
      string s = HistoryDealGetString(ticket,DEAL_SYMBOL);
      if(s != symbol) continue;
      total += HistoryDealGetDouble(ticket,DEAL_PROFIT);
   }

   if(includeFloating)
   {
      int pcount = PositionsTotal();
      for(int k=0; k<pcount; k++)
      {
         ulong ticket = PositionGetTicket(k);
         if(ticket > 0 && PositionSelectByTicket(ticket))
         {
            string ps = PositionGetString(POSITION_SYMBOL);
            if(ps == symbol) total += PositionGetDouble(POSITION_PROFIT);
         }
      }
   }
   return(total);
}
//+------------------------------------------------------------------+
void UpdateAllowFlag()
{
   double dailyPL = GlobalVariableGet(GV_DAILY_PL);
   double prof = GlobalVariableGet(GV_DAILY_PROF);
   double loss = GlobalVariableGet(GV_DAILY_LOSS);

   double weekPL = CalculateWeeklyPL(InpCountFloatingPL);
   double wkProf = GlobalVariableGet(GV_WEEK_PROF);
   double wkLoss = GlobalVariableGet(GV_WEEK_LOSS);

   double monthPL = CalculateMonthlyPL(InpCountFloatingPL);
   double moProf = GlobalVariableGet(GV_MONTH_PROF);
   double moLoss = GlobalVariableGet(GV_MONTH_LOSS);

   double symPL = CalculateSymbolPL(Symbol(),InpCountFloatingPL);
   double sProf = GlobalVariableGet(GV_SYMBOL_PROF);
   double sLoss = GlobalVariableGet(GV_SYMBOL_LOSS);

   int allow = 1;
   int blockReason = 0;

   if((int)GlobalVariableGet(GV_ENGAGED) == 1)
   {
      if((int)GlobalVariableGet(GV_EMERGENCY_ACTIVE) == 1)
      {
         allow = 0;
         blockReason = 99;
      }
      else if(dailyPL >= prof) 
      { 
         allow = 0; 
         blockReason = 1; 
         PrintFormat("[RiskEnforcer] DAILY PROFIT LIMIT HIT! Current: $%.2f, Limit: $%.2f", dailyPL, prof);
      }
      else if(dailyPL <= loss) 
      { 
         allow = 0; 
         blockReason = 2; 
         PrintFormat("[RiskEnforcer] DAILY LOSS LIMIT HIT! Current: $%.2f, Limit: $%.2f", dailyPL, loss);
      }
      else if(weekPL >= wkProf) { allow = 0; blockReason = 3; }
      else if(weekPL <= wkLoss) { allow = 0; blockReason = 4; }
      else if(monthPL >= moProf) { allow = 0; blockReason = 5; }
      else if(monthPL <= moLoss) { allow = 0; blockReason = 6; }
      else if(symPL >= sProf) { allow = 0; blockReason = 7; }
      else if(symPL <= sLoss) { allow = 0; blockReason = 8; }
      
      int consecLoss = (int)GlobalVariableGet(GV_CONSEC_LOSS);
      if(consecLoss >= InpConsecLossLimit) 
      { 
         allow = 0; 
         blockReason = 9; 
         PrintFormat("[RiskEnforcer] CONSECUTIVE LOSS LIMIT HIT! Losses: %d, Limit: %d", consecLoss, InpConsecLossLimit);
      }
      
      double eq = AccountInfoDouble(ACCOUNT_EQUITY);
      double maxEq = GlobalVariableGet(GV_MAX_EQ);
      double drawdown = maxEq - eq;
      if(drawdown >= InpMaxDrawdown) { allow = 0; blockReason = 10; }
   }
   else
   {
      allow = 1;
      blockReason = 0;
   }

   if(allow == 0 && (int)GlobalVariableGet(GV_ALLOW) == 1)
   {
      GlobalVariableSet(GV_LAST_BLOCK_CHECK, (double)TimeCurrent());
      GlobalVariableSet(GV_BLOCK_EXPIRY, (double)(TimeCurrent() + 86400));
   }

   GlobalVariableSet(GV_ALLOW, (double)allow);
   GlobalVariableSet(GV_BLOCK_REASON, (double)blockReason);

   if(allow==0 && blockReason > 0)
   {
      string reasonText = "";
      switch(blockReason)
      {
         case 1: reasonText = "Daily Profit Limit"; break;
         case 2: reasonText = "Daily Loss Limit"; break;
         case 3: reasonText = "Weekly Profit Limit"; break;
         case 4: reasonText = "Weekly Loss Limit"; break;
         case 5: reasonText = "Monthly Profit Limit"; break;
         case 6: reasonText = "Monthly Loss Limit"; break;
         case 7: reasonText = "Symbol Profit Limit"; break;
         case 8: reasonText = "Symbol Loss Limit"; break;
         case 9: reasonText = "Consecutive Losses"; break;
         case 10: reasonText = "Max Drawdown"; break;
         case 99: reasonText = "Emergency Stop"; break;
      }
      Print("[RiskEnforcer] TRADING BLOCKED. Reason: ", reasonText);
   }
}
//+------------------------------------------------------------------+
void LogLastDealToCSV()
{
   int deals = HistoryDealsTotal();
   if(deals <= 0) return;

   ulong ticket = HistoryDealGetTicket(deals-1);
   if(ticket==0) return;

   string ts = TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS);
   string sym = HistoryDealGetString(ticket,DEAL_SYMBOL);
   double vol = HistoryDealGetDouble(ticket,DEAL_VOLUME);
   double price = HistoryDealGetDouble(ticket,DEAL_PRICE);
   double profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
   double dailyPL = CalculateDailyPL(InpCountFloatingPL);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);

   string line = StringFormat("%s,Deal,%s,DEAL,%d,%.2f,%.5f,%.2f,%.2f,%.2f",
                              ts,sym,(int)ticket,vol,price,profit,dailyPL,equity);
   AppendCSVLine(line);
}
//+------------------------------------------------------------------+
void AppendCSVLine(string line)
{
   if(logHandle == INVALID_HANDLE)
   {
      logHandle = FileOpen(InpLogFileName, FILE_WRITE|FILE_CSV|FILE_ANSI);
      if(logHandle == INVALID_HANDLE)
      {
         Print("[RiskEnforcer] Cannot open log file for append.");
         return;
      }
   }
   FileSeek(logHandle, 0, SEEK_END);
   FileWriteString(logHandle, line + "\n");
   FileFlush(logHandle);
}
//+------------------------------------------------------------------+
void AutoCloseAllPositions()
{
   int total = PositionsTotal();
   PrintFormat("[RiskEnforcer] Closing %d positions...", total);

   for(int i=total-1; i>=0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         string symbol = PositionGetString(POSITION_SYMBOL);
         double volume = PositionGetDouble(POSITION_VOLUME);
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

         if(trade.PositionClose(ticket))
         {
            PrintFormat("[RiskEnforcer] Successfully closed position #%d for %s (%.2f lots)", ticket, symbol, volume);
         }
         else
         {
            PrintFormat("[RiskEnforcer] Failed to close position #%d for %s. Error: %d", ticket, symbol, GetLastError());
            
            if(type == POSITION_TYPE_BUY)
            {
               trade.Sell(volume, symbol);
            }
            else if(type == POSITION_TYPE_SELL)
            {
               trade.Buy(volume, symbol);
            }
         }
      }
   }

   Print("[RiskEnforcer] All positions closed.");
}
//+------------------------------------------------------------------+
void CloseAllPositionsForSymbol(string symbol)
{
   int total = PositionsTotal();
   for(int i=total-1; i>=0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         string posSymbol = PositionGetString(POSITION_SYMBOL);
         if(posSymbol == symbol)
         {
            trade.PositionClose(ticket);
         }
      }
   }
}
//+------------------------------------------------------------------+
void UpdateUIColors()
{
   int allow = (int)GlobalVariableGet(GV_ALLOW);
   int engaged = (int)GlobalVariableGet(GV_ENGAGED);
   double dailyPL = GlobalVariableGet(GV_DAILY_PL);
   double prof = GlobalVariableGet(GV_DAILY_PROF);
   double loss = GlobalVariableGet(GV_DAILY_LOSS);

   color bg = clrWhite;
   if(allow==0)
   {
      bg = clrRed;
   }
   else if(engaged==0)
   {
      bg = clrLightGray;
   }
   else
   {
      double range = prof - loss;
      if(range <= 0) range = 1000;
      double warningZone = 0.15 * range;

      if(dailyPL >= (prof - warningZone) || dailyPL <= (loss + warningZone))
      {
         bg = clrYellow;
      }
      else if(dailyPL > prof || dailyPL < loss)
      {
         bg = clrRed;
      }
      else
      {
         bg = clrGray;
      }
   }

   if(ObjectFind(0,OBJ_PANEL) >= 0)
   {
      ObjectSetInteger(0,OBJ_PANEL,OBJPROP_COLOR,bg);
      ObjectSetInteger(0,OBJ_PANEL,OBJPROP_BGCOLOR,bg);
   }
}
//+------------------------------------------------------------------+
string CustomTrim(string text)
{
   int start = 0;
   int len = StringLen(text);
   while(start < len && StringGetCharacter(text, start) == ' ')
      start++;

   int end = len - 1;
   while(end >= 0 && StringGetCharacter(text, end) == ' ')
      end--;

   if(start > end) return "";
   return StringSubstr(text, start, end - start + 1);
}
//+------------------------------------------------------------------+
bool IsNumericString(string s)
{
   string str = CustomTrim(s);
   if(StringLen(str) == 0) return(false);
   int len = StringLen(str);
   int start = 0;
   int c = StringGetCharacter(str,0);
   if(c == '+' || c == '-') start = 1;
   bool dot = false;
   for(int i=start;i<len;i++)
   {
      int ch = StringGetCharacter(str,i);
      if(ch == 46)
      {
         if(dot) return(false);
         dot = true;
         continue;
      }
      if(ch < 48 || ch > 57) return(false);
   }
   return(true);
}
//+------------------------------------------------------------------+
string HashPassword(string password)
{
   uchar data[];
   int len = StringToCharArray(password, data, 0, WHOLE_ARRAY);
   string result = "";

   for(int i=0; i<len-1; i++)
   {
      data[i] = data[i] ^ 0x55;
      result += StringFormat("%02X", data[i]);
   }

   return result;
}
//+------------------------------------------------------------------+
bool VerifyPassword(string provided)
{
   if(!InpRequirePassword) return true;

   string hashedProvided = HashPassword(provided);
   string storedHash = "";

   int file_handle = FileOpen("RiskEnforcer_Pass.txt", FILE_READ|FILE_TXT|FILE_ANSI);
   if(file_handle != INVALID_HANDLE)
   {
      storedHash = FileReadString(file_handle);
      FileClose(file_handle);
   }
   else
   {
      storedHash = HashPassword(InpAdminPassword);
   }

   return (hashedProvided == storedHash);
}
//+------------------------------------------------------------------+
void CheckAndAlertLimits()
{
   if((int)GlobalVariableGet(GV_ENGAGED) == 0) return;

   double dailyPL = GlobalVariableGet(GV_DAILY_PL);
   double prof = GlobalVariableGet(GV_DAILY_PROF);
   double loss = GlobalVariableGet(GV_DAILY_LOSS);

   double range = prof - loss;
   if(range <= 0) range = 1000;

   double warningThreshold = 0.15 * range;

   if(dailyPL >= (prof - warningThreshold) && dailyPL < prof)
   {
      string msg = StringFormat("Approaching daily profit limit! Current: %.2f, Limit: %.2f", dailyPL, prof);
      Alert(msg);
      PlayAlertSound();
   }
   else if(dailyPL <= (loss + warningThreshold) && dailyPL > loss)
   {
      string msg = StringFormat("Approaching daily loss limit! Current: %.2f, Limit: %.2f", dailyPL, loss);
      Alert(msg);
      PlayAlertSound();
   }

   int consecLoss = (int)GlobalVariableGet(GV_CONSEC_LOSS);
   if(consecLoss >= (InpConsecLossLimit - 1) && consecLoss < InpConsecLossLimit)
   {
      string msg = StringFormat("Warning: %d consecutive losses. Limit is %d", consecLoss, InpConsecLossLimit);
      Alert(msg);
      PlayAlertSound();
   }
}
//+------------------------------------------------------------------+
bool CheckPositionSize(string symbol, double volume)
{
   if(volume > InpMaxPositionSize)
   {
      PrintFormat("[RiskEnforcer] Position size %.2f exceeds maximum allowed %.2f", volume, InpMaxPositionSize);
      return false;
   }

   if(InpMaxRiskPerTrade > 0)
   {
      double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      double stopLossPoints = InpDefaultStopPoints;

      double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);

      if(tick_size <= 0 || tick_value <= 0)
      {
         PrintFormat("[RiskEnforcer] Warning: tick size/value unavailable for %s; skipping risk-based volume check.", symbol);
         return true;
      }

      double ticks = stopLossPoints / tick_size;
      double riskAmount = accountBalance * InpMaxRiskPerTrade;
      double maxVolumeByRisk = 0.0;
      if(tick_value != 0.0)
         maxVolumeByRisk = riskAmount / (tick_value * ticks);

      if(maxVolumeByRisk <= 0.0)
      {
         Print("[RiskEnforcer] Computed zero/negative maxVolumeByRisk, skipping risk check.");
         return true;
      }

      if(volume > maxVolumeByRisk)
      {
         PrintFormat("[RiskEnforcer] Position size %.2f exceeds risk-based limit %.2f", volume, maxVolumeByRisk);
         return false;
      }
   }

   return true;
}
//+------------------------------------------------------------------+
void ResetDailyCounters()
{
   GlobalVariableSet(GV_DAILY_PL, 0.0);
   GlobalVariableSet(GV_CONSEC_LOSS, 0.0);
   GlobalVariableSet(GV_CONSEC_WIN, 0.0);
   GlobalVariableSet(GV_MAX_EQ, AccountInfoDouble(ACCOUNT_EQUITY));
   GlobalVariableSet(GV_ALLOW, 1.0);
   GlobalVariableSet(GV_BLOCK_REASON, 0.0);
   GlobalVariableSet(GV_LAST_BLOCK_CHECK, 0.0);
   GlobalVariableSet(GV_EMERGENCY_ACTIVE, 0.0);
   GlobalVariableSet(GV_BLOCK_EXPIRY, 0.0);
   Print("[RiskEnforcer] Daily counters reset.");
}
//+------------------------------------------------------------------+
void ResetWeeklyCounters()
{
   Print("[RiskEnforcer] Weekly check performed.");
}
//+------------------------------------------------------------------+
void ResetMonthlyCounters()
{
   Print("[RiskEnforcer] Monthly check performed.");
}
//+------------------------------------------------------------------+
void CheckForAutoReset()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   if(InpResetDaily && dt.day != lastDay)
   {
      lastDay = dt.day;
      GlobalVariableSet(GV_LAST_RESET_DAY, (double)dt.day);
      ResetDailyCounters();
   }

   if(InpResetWeekly && dt.day_of_week == 1 && dt.day_of_week != lastWeek)
   {
      lastWeek = dt.day_of_week;
      GlobalVariableSet(GV_LAST_RESET_WEEK, (double)dt.day_of_week);
      ResetWeeklyCounters();
   }

   if(InpResetMonthly && dt.day == 1 && dt.mon != lastMonth)
   {
      lastMonth = dt.mon;
      GlobalVariableSet(GV_LAST_RESET_MONTH, (double)dt.mon);
      ResetMonthlyCounters();
   }
}
//+------------------------------------------------------------------+
void PlayAlertSound()
{
   if(!InpEnableAlerts) return;

   string soundFile = "alert.wav";
   PlaySound(soundFile);
   Alert("[RiskEnforcer] Alert triggered.");
}
//+------------------------------------------------------------------+
bool IsTradingAllowed(void)
{
   return ((int)GlobalVariableGet(GV_ALLOW) == 1);
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      string name = sparam;
      
      if(name == OBJ_BTN_ENGAGE)
      {
         GlobalVariableSet(GV_ENGAGED, 1.0);
         UpdateAllowFlag();
         UpdateInfoDisplay();
         Print("[RiskEnforcer] Engaged by user.");
         Alert("[RiskEnforcer] Enforcement ENGAGED");
      }
      else if(name == OBJ_BTN_DISENG)
      {
         GlobalVariableSet(GV_ENGAGED, 0.0);
         GlobalVariableSet(GV_ALLOW, 1.0);
         GlobalVariableSet(GV_BLOCK_REASON, 0.0);
         GlobalVariableSet(GV_EMERGENCY_ACTIVE, 0.0);
         UpdateInfoDisplay();
         Print("[RiskEnforcer] Disengaged by user.");
         Alert("[RiskEnforcer] Enforcement DISENGAGED - Trading allowed");
      }
      else if(name == OBJ_BTN_EMERGENCY)
      {
         EmergencyStop();
         UpdateInfoDisplay();
      }
      else if(name == OBJ_BTN_RESET)
      {
         ResetDailyCounters();
         UpdateInfoDisplay();
         Print("[RiskEnforcer] Manual reset requested.");
         Alert("[RiskEnforcer] Counters RESET - Trading allowed");
      }
      else if(name == OBJ_BTN_SAVE)
      {
         string v;
         if(ObjectFind(0,OBJ_EDIT_DPROF) >= 0)
         {
            v = ObjectGetString(0,OBJ_EDIT_DPROF,OBJPROP_TEXT);
            if(IsNumericString(v)) GlobalVariableSet(GV_DAILY_PROF, StringToDouble(v));
         }
         if(ObjectFind(0,OBJ_EDIT_DLOSS) >= 0)
         {
            v = ObjectGetString(0,OBJ_EDIT_DLOSS,OBJPROP_TEXT);
            if(IsNumericString(v)) GlobalVariableSet(GV_DAILY_LOSS, StringToDouble(v));
         }
         if(ObjectFind(0,OBJ_EDIT_WPROF) >= 0)
         {
            v = ObjectGetString(0,OBJ_EDIT_WPROF,OBJPROP_TEXT);
            if(IsNumericString(v)) GlobalVariableSet(GV_WEEK_PROF, StringToDouble(v));
         }
         if(ObjectFind(0,OBJ_EDIT_WLOSS) >= 0)
         {
            v = ObjectGetString(0,OBJ_EDIT_WLOSS,OBJPROP_TEXT);
            if(IsNumericString(v)) GlobalVariableSet(GV_WEEK_LOSS, StringToDouble(v));
         }
         if(ObjectFind(0,OBJ_EDIT_MPROF) >= 0)
         {
            v = ObjectGetString(0,OBJ_EDIT_MPROF,OBJPROP_TEXT);
            if(IsNumericString(v)) GlobalVariableSet(GV_MONTH_PROF, StringToDouble(v));
         }
         if(ObjectFind(0,OBJ_EDIT_MLOSS) >= 0)
         {
            v = ObjectGetString(0,OBJ_EDIT_MLOSS,OBJPROP_TEXT);
            if(IsNumericString(v)) GlobalVariableSet(GV_MONTH_LOSS, StringToDouble(v));
         }
         if(ObjectFind(0,OBJ_EDIT_SPROF) >= 0)
         {
            v = ObjectGetString(0,OBJ_EDIT_SPROF,OBJPROP_TEXT);
            if(IsNumericString(v)) GlobalVariableSet(GV_SYMBOL_PROF, StringToDouble(v));
         }
         if(ObjectFind(0,OBJ_EDIT_SLOSS) >= 0)
         {
            v = ObjectGetString(0,OBJ_EDIT_SLOSS,OBJPROP_TEXT);
            if(IsNumericString(v)) GlobalVariableSet(GV_SYMBOL_LOSS, StringToDouble(v));
         }
         UpdateAllowFlag();
         UpdateInfoDisplay();
         Print("[RiskEnforcer] Limits saved from UI.");
      }
   }
}
//+------------------------------------------------------------------+