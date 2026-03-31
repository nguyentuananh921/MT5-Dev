//+------------------------------------------------------------------+
//|                                          Multi-Signal Expert.mq5 |
//|                               Copyright 2025, Clemence Benjamin. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Clemence Benjamin."
#property link      "https://www.mql5.com"
#property version   "1.01"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
#include <Trade\Trade.mqh>
//--- available signals
#include <Expert\Signal\SignalFibonacci.mqh>
#include <Expert\Signal\SignalAC.mqh>
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalRSI.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingParabolicSAR.mqh>
//--- available money management
#include <Expert\Money\MoneySizeOptimized.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                      ="Multi-Signal Expert"; // Document name
ulong                    Expert_MagicNumber                =-108721665;            //
bool                     Expert_EveryTick                  =false;                 //

//--- Trading Session Parameters (using BROKER time)
input bool               EnableSessionFilter              =true;                  // Enable Session Filter
input string             Session_StartTime                ="09:00";               // Session Start (Broker time, HH:MM)
input string             Session_EndTime                  ="17:00";               // Session End (Broker time, HH:MM)
input bool               Close_Outside_Session            =false;                 // Close trades outside session?

//--- Trade Limit Parameters
input bool               EnableTradeLimit                 =true;                  // Enable Maximum Trade Limit
input int                MaxTradesPerSession              =2;                     // Maximum trades per session (1-2)
input bool               CountAllPositions               =true;                  // Count all positions (true) or only open ones (false)

//--- inputs for main signal
input int                Signal_ThresholdOpen              =30;    // Increased: require stronger consensus to open
input int                Signal_ThresholdClose             =12;    // Slightly responsive exits, but not noisy
input double             Signal_PriceLevel                 =0.0;   // Leave neutral
input double             Signal_StopLevel                  =60.0;  // Slightly wider to avoid noise stops
input double             Signal_TakeLevel                  =80.0;  // Allow trades room to mature
input int                Signal_Expiration                 =2;     // Reduced: prevent stale signals voting

//--- signal weights (no longer equal)
input double             Signal_Fib_Weight                 =0.4;   // Structural context, not trigger
input double             Signal_AC_Weight                  =0.3;   // Momentum confirmation only

input int                Signal_MA_PeriodMA                =20;    // Slower MA for regime awareness
input int                Signal_MA_Shift                   =0;
input ENUM_MA_METHOD     Signal_MA_Method                  =MODE_SMA;
input ENUM_APPLIED_PRICE Signal_MA_Applied                 =PRICE_CLOSE;
input double             Signal_MA_Weight                  =1.0;   // Primary directional authority

input int                Signal_RSI_PeriodRSI              =14;    // Less reactive RSI
input ENUM_APPLIED_PRICE Signal_RSI_Applied                =PRICE_CLOSE;
input double             Signal_RSI_Weight                 =0.6;   // Timing, not decision driver

//--- inputs for trailing
input double             Trailing_ParabolicSAR_Step        =0.02;
input double             Trailing_ParabolicSAR_Maximum     =0.2;

//--- inputs for money
input double             Money_SizeOptimized_DecreaseFactor=3.0;
input double             Money_SizeOptimized_Percent       =10.0;

//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
CTrade Trade;
bool SessionEnabled = false;
int CurrentTradeCount = 0;
datetime SessionStartTime = 0;
datetime LastResetCheck = 0;
//+------------------------------------------------------------------+
//| Simple Time Check Function                                       |
//+------------------------------------------------------------------+
bool IsTradingTime()
{
   if(!SessionEnabled) return true;
   
   datetime current_time = TimeCurrent();
   MqlDateTime time_struct;
   TimeToStruct(current_time, time_struct);
   
   // Get current hour and minute
   int current_hour = time_struct.hour;
   int current_minute = time_struct.min;
   int current_total_minutes = current_hour * 60 + current_minute;
   
   // Parse start time
   string start_parts[];
   int start_hour = 9, start_minute = 0;
   if(StringSplit(Session_StartTime, ':', start_parts) >= 2)
   {
      start_hour = (int)StringToInteger(start_parts[0]);
      start_minute = (int)StringToInteger(start_parts[1]);
   }
   
   // Parse end time
   string end_parts[];
   int end_hour = 17, end_minute = 0;
   if(StringSplit(Session_EndTime, ':', end_parts) >= 2)
   {
      end_hour = (int)StringToInteger(end_parts[0]);
      end_minute = (int)StringToInteger(end_parts[1]);
   }
   
   // Calculate session boundaries in minutes
   int session_start_minutes = start_hour * 60 + start_minute;
   int session_end_minutes = end_hour * 60 + end_minute;
   
   // Check if current time is within session
   if(session_end_minutes > session_start_minutes)
   {
      // Normal session within same day
      return (current_total_minutes >= session_start_minutes && 
              current_total_minutes < session_end_minutes);
   }
   else
   {
      // Session crosses midnight
      return (current_total_minutes >= session_start_minutes || 
              current_total_minutes < session_end_minutes);
   }
}

//+------------------------------------------------------------------+
//| Get session start datetime for today                             |
//+------------------------------------------------------------------+
datetime GetSessionStartDatetime()
{
   datetime current = TimeCurrent();
   MqlDateTime dt_current, dt_session;
   TimeToStruct(current, dt_current);
   
   // Parse start time
   string start_parts[];
   int start_hour = 9, start_minute = 0;
   if(StringSplit(Session_StartTime, ':', start_parts) >= 2)
   {
      start_hour = (int)StringToInteger(start_parts[0]);
      start_minute = (int)StringToInteger(start_parts[1]);
   }
   
   // Set session start time for today
   dt_session.year = dt_current.year;
   dt_session.mon = dt_current.mon;
   dt_session.day = dt_current.day;
   dt_session.hour = start_hour;
   dt_session.min = start_minute;
   dt_session.sec = 0;
   
   datetime session_start = StructToTime(dt_session);
   
   // If session has already passed today, it's for today
   if(session_start < current)
   {
      return session_start;
   }
   else
   {
      // Session is in the future (e.g., we're before session start)
      return session_start;
   }
}

//+------------------------------------------------------------------+
//| Check and close positions outside session                        |
//+------------------------------------------------------------------+
void CheckSessionClose()
{
   if(!SessionEnabled || !Close_Outside_Session) return;
   
   if(!IsTradingTime())
   {
      int total_positions = PositionsTotal();
      for(int i = total_positions - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetString(POSITION_SYMBOL) == Symbol() && 
               PositionGetInteger(POSITION_MAGIC) == Expert_MagicNumber)
            {
               Trade.PositionClose(ticket);
               Print("Closing position ", ticket, " - Outside trading session");
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Reset trade count at session start                               |
//+------------------------------------------------------------------+
void ResetTradeCount()
{
   if(!SessionEnabled || !EnableTradeLimit) return;
   
   datetime current = TimeCurrent();
   
   // Check if we need to reset (once per minute max)
   if(current - LastResetCheck < 60) return;
   
   LastResetCheck = current;
   
   // Get today's session start
   datetime today_session_start = GetSessionStartDatetime();
   
   // If it's a new session, reset count
   if(SessionStartTime != today_session_start)
   {
      SessionStartTime = today_session_start;
      CurrentTradeCount = 0;
      Print("New session started. Trade count reset to 0.");
   }
}

//+------------------------------------------------------------------+
//| Count current trades in this session                             |
//+------------------------------------------------------------------+
int CountSessionTrades()
{
   int count = 0;
   
   if(CountAllPositions)
   {
      // Count all positions (open and history)
      datetime session_start = GetSessionStartDatetime();
      datetime now = TimeCurrent();
      
      // Select history for today's session
      HistorySelect(session_start, now);
      
      int total_deals = HistoryDealsTotal();
      for(int i = 0; i < total_deals; i++)
      {
         ulong deal_ticket = HistoryDealGetTicket(i);
         if(deal_ticket > 0)
         {
            long deal_magic = HistoryDealGetInteger(deal_ticket, DEAL_MAGIC);
            string deal_symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
            long deal_type = HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
            long deal_entry = HistoryDealGetInteger(deal_ticket, DEAL_ENTRY);
            
            // Count only opening deals (ENTRY_IN) for this EA on this symbol
            if(deal_magic == Expert_MagicNumber && 
               deal_symbol == Symbol() && 
               deal_entry == DEAL_ENTRY_IN)
            {
               count++;
            }
         }
      }
   }
   else
   {
      // Count only currently open positions
      int total_positions = PositionsTotal();
      for(int i = 0; i < total_positions; i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetString(POSITION_SYMBOL) == Symbol() && 
               PositionGetInteger(POSITION_MAGIC) == Expert_MagicNumber)
            {
               count++;
            }
         }
      }
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| Check if we can open a new trade                                 |
//+------------------------------------------------------------------+
bool CanOpenNewTrade()
{
   if(!SessionEnabled) return true;
   
   // Check if we're in trading session
   if(!IsTradingTime()) return false;
   
   // Check trade limit
   if(EnableTradeLimit)
   {
      // Update trade count
      CurrentTradeCount = CountSessionTrades();
      
      if(CurrentTradeCount >= MaxTradesPerSession)
      {
         Print("Trade limit reached: ", CurrentTradeCount, "/", MaxTradesPerSession, " trades this session");
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Display current status on chart                                  |
//+------------------------------------------------------------------+
void ShowStatusInfo()
{
   static datetime last_print = 0;
   if(TimeCurrent() - last_print >= 1)  // Update every second
   {
      string current_time = TimeToString(TimeCurrent(), TIME_MINUTES);
      bool in_session = IsTradingTime();
      bool can_trade = CanOpenNewTrade();
      
      string status_text = "";
      
      if(SessionEnabled)
      {
         if(in_session)
         {
            if(EnableTradeLimit)
            {
               status_text = StringFormat("TRADING: %s-%s | Trades: %d/%d | Time: %s",
                                          Session_StartTime, Session_EndTime,
                                          CurrentTradeCount, MaxTradesPerSession,
                                          current_time);
            }
            else
            {
               status_text = StringFormat("TRADING: %s-%s | Time: %s",
                                          Session_StartTime, Session_EndTime,
                                          current_time);
            }
         }
         else
         {
            status_text = StringFormat("BLOCKED: Outside session %s-%s | Time: %s",
                                       Session_StartTime, Session_EndTime,
                                       current_time);
         }
         
         // Add trade limit warning if applicable
         if(in_session && EnableTradeLimit && CurrentTradeCount >= MaxTradesPerSession)
         {
            status_text += "\nTRADE LIMIT REACHED!";
         }
      }
      else
      {
         status_text = "TRADING 24/7: Session filter OFF | Time: " + current_time;
      }
      
      Comment(status_text);
      last_print = TimeCurrent();
   }
}

//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
{
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(), Period(), Expert_EveryTick, Expert_MagicNumber))
   {
      //--- failed
      Print(__FUNCTION__ + ": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }
   
//--- Creating signal
   CExpertSignal *signal = new CExpertSignal;
   if(signal == NULL)
   {
      //--- failed
      Print(__FUNCTION__ + ": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }
   
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
   
//--- Creating filter CSignalFibonacci
   CSignalFibonacci *filter0 = new CSignalFibonacci;
   if(filter0 == NULL)
   {
      //--- failed
      Print(__FUNCTION__ + ": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.Weight(Signal_Fib_Weight);
   
//--- Creating filter CSignalAC
   CSignalAC *filter1 = new CSignalAC;
   if(filter1 == NULL)
   {
      //--- failed
      Print(__FUNCTION__ + ": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.Weight(Signal_AC_Weight);
   
//--- Creating filter CSignalMA
   CSignalMA *filter2 = new CSignalMA;
   if(filter2 == NULL)
   {
      //--- failed
      Print(__FUNCTION__ + ": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodMA(Signal_MA_PeriodMA);
   filter2.Shift(Signal_MA_Shift);
   filter2.Method(Signal_MA_Method);
   filter2.Applied(Signal_MA_Applied);
   filter2.Weight(Signal_MA_Weight);
   
//--- Creating filter CSignalRSI
   CSignalRSI *filter3 = new CSignalRSI;
   if(filter3 == NULL)
   {
      //--- failed
      Print(__FUNCTION__ + ": error creating filter3");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }
   signal.AddFilter(filter3);
//--- Set filter parameters
   filter3.PeriodRSI(Signal_RSI_PeriodRSI);
   filter3.Applied(Signal_RSI_Applied);
   filter3.Weight(Signal_RSI_Weight);
   
//--- Creation of trailing object
   CTrailingPSAR *trailing = new CTrailingPSAR;
   if(trailing == NULL)
   {
      //--- failed
      Print(__FUNCTION__ + ": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }
   
//--- Add trailing to expert (will be deleted automatically)
   if(!ExtExpert.InitTrailing(trailing))
   {
      //--- failed
      Print(__FUNCTION__ + ": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }
   
//--- Set trailing parameters
   trailing.Step(Trailing_ParabolicSAR_Step);
   trailing.Maximum(Trailing_ParabolicSAR_Maximum);
   
//--- Creation of money object
   CMoneySizeOptimized *money = new CMoneySizeOptimized;
   if(money == NULL)
   {
      //--- failed
      Print(__FUNCTION__ + ": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }
   
//--- Add money to expert (will be deleted automatically)
   if(!ExtExpert.InitMoney(money))
   {
      //--- failed
      Print(__FUNCTION__ + ": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }
   
//--- Set money parameters
   money.DecreaseFactor(Money_SizeOptimized_DecreaseFactor);
   money.Percent(Money_SizeOptimized_Percent);
   
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
   {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }
   
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
   {
      //--- failed
      Print(__FUNCTION__ + ": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }
   
//--- Set trade object properties
   Trade.SetExpertMagicNumber(Expert_MagicNumber);
   Trade.SetMarginMode();
   Trade.SetTypeFillingBySymbol(Symbol());
   
//--- Initialize session parameters
   SessionEnabled = EnableSessionFilter;
   
   // Get initial trade count
   if(EnableTradeLimit)
   {
      CurrentTradeCount = CountSessionTrades();
      SessionStartTime = GetSessionStartDatetime();
      LastResetCheck = TimeCurrent();
   }
   
//--- Display session info
   if(SessionEnabled)
   {
      Print("=== TRADING SESSION FILTER ENABLED ===");
      Print("Session Time: ", Session_StartTime, " to ", Session_EndTime, " (Broker Time)");
      Print("Close Outside Session: ", Close_Outside_Session ? "Yes" : "No");
      
      if(EnableTradeLimit)
      {
         Print("Maximum Trades Per Session: ", MaxTradesPerSession);
         Print("Count Method: ", CountAllPositions ? "All positions (including history)" : "Only open positions");
         Print("Current Trade Count: ", CurrentTradeCount);
      }
      
      Print("Current Broker Time: ", TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES));
      Print("=====================================");
   }
   else
   {
      Print("Session Filter Disabled - Trading 24/7");
   }
   
//--- ok
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ExtExpert.Deinit();
}

//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
{
   // Display current status on chart
   ShowStatusInfo();
   
   // Reset trade count if new session
   if(SessionEnabled)
   {
      ResetTradeCount();
   }
   
   // Check if we can open new trades
   bool can_open_trades = true;
   
   if(SessionEnabled)
   {
      can_open_trades = CanOpenNewTrade();
   }
   
   // Process trades based on conditions
   if(can_open_trades)
   {
      // Conditions met - allow normal trading
      ExtExpert.OnTick();
   }
   else
   {
      // Conditions not met - check if we need to close positions
      if(Close_Outside_Session && !IsTradingTime())
      {
         CheckSessionClose();
      }
      
      // Do NOT process any new trades when conditions are not met
      // This blocks ALL new trading activity
      return;
   }
}

//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
{
   ExtExpert.OnTrade();
}

//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   ExtExpert.OnTimer();
}
//+------------------------------------------------------------------+