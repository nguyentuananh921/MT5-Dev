//+------------------------------------------------------------------+
//|                                          MA_Crossover_TTS_EA.mq5 |
//|                                Copyright 2025, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Clemence Benjamin"
#property link      "https://www.mql5.com"
#property version   "1.10"
#property description "Voice‑enabled MA Crossover EA with Test Mode"

// --- Input Parameters ---
input int      FastMAPeriod      = 9;           // Fast MA Period
input int      SlowMAPeriod      = 21;          // Slow MA Period
input int      ATRPeriod         = 14;          // ATR Period
input ENUM_MA_METHOD  MaMethod   = MODE_EMA;    // MA Method
input ENUM_APPLIED_PRICE PriceType = PRICE_CLOSE; // Price type

input bool     EnableVoiceAlerts = true;        // Enable spoken alerts
input bool     EnableTrading     = false;       // Set true to actually place trades
input double   LotSize           = 0.01;        // Only used if trading enabled
input int      MagicNumber       = 20250225;    // Unique EA identifier

input bool     TestMode          = false;        // If true, speak test info on every new bar

// --- Global Variables ---
int fastMA_handle, slowMA_handle, atr_handle;
datetime lastBarTime = 0;          // For new bar detection
ulong    lastSignalBar = 0;         // Prevent repeated signals on same bar

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Create indicator handles
   fastMA_handle = iMA(_Symbol, _Period, FastMAPeriod, 0, MaMethod, PriceType);
   slowMA_handle = iMA(_Symbol, _Period, SlowMAPeriod, 0, MaMethod, PriceType);
   atr_handle    = iATR(_Symbol, _Period, ATRPeriod);

   if(fastMA_handle == INVALID_HANDLE || slowMA_handle == INVALID_HANDLE || atr_handle == INVALID_HANDLE)
   {
      Print("Failed to create indicator handles");
      return INIT_FAILED;
   }

   // Welcome message (optional)
   if(EnableVoiceAlerts)
      Speak("Moving average crossover expert advisor started on " + _Symbol);

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Release handles
   if(fastMA_handle != INVALID_HANDLE) IndicatorRelease(fastMA_handle);
   if(slowMA_handle != INVALID_HANDLE) IndicatorRelease(slowMA_handle);
   if(atr_handle    != INVALID_HANDLE) IndicatorRelease(atr_handle);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // --- New bar detection ---
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   if(currentBarTime == lastBarTime)
      return; // Same bar, nothing to do
   lastBarTime = currentBarTime;

   // --- Test Mode: speak current info on every new bar ---
   if(TestMode && EnableVoiceAlerts)
      SpeakTestInfo();

   // --- Fetch indicator values for the previous (just closed) bar and the bar before that ---
   double fast[], slow[], atr[];
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);
   ArraySetAsSeries(atr, true);

   if(CopyBuffer(fastMA_handle, 0, 1, 2, fast) < 2) return;
   if(CopyBuffer(slowMA_handle, 0, 1, 2, slow) < 2) return;
   if(CopyBuffer(atr_handle,    0, 1, 1, atr) < 1) return;

   double currentClose = iClose(_Symbol, _Period, 0); // price of the newly opened bar

   // --- Crossover detection ---
   string signal = "";
   if(fast[1] < slow[1] && fast[0] > slow[0])
      signal = "BUY";
   else if(fast[1] > slow[1] && fast[0] < slow[0])
      signal = "SELL";

   if(signal != "")
   {
      // Avoid duplicate signals on same bar
      if(lastSignalBar == currentBarTime) return;
      lastSignalBar = currentBarTime;

      // --- Voice Alert ---
      if(EnableVoiceAlerts)
      {
         string message = StringFormat(
            "%s signal on %s at price %.*f. ATR is %.*f.",
            signal,
            _Symbol,
            _Digits,
            currentClose,
            _Digits,
            atr[0]
         );
         Speak(message);
      }

      // --- Trading (optional) ---
      if(EnableTrading)
      {
         PlaceTrade(signal);
      }
   }
}

//+------------------------------------------------------------------+
//| Speak test information (symbol, price, time)                     |
//+------------------------------------------------------------------+
void SpeakTestInfo()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   datetime now = TimeCurrent();
   string timeStr = TimeToString(now, TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   string message = StringFormat(
      "Test on %s: Bid %.*f, Ask %.*f at %s",
      _Symbol,
      _Digits,
      bid,
      _Digits,
      ask,
      timeStr
   );
   Speak(message);
}

//+------------------------------------------------------------------+
//| Send text to TTS server via WebRequest                           |
//+------------------------------------------------------------------+
bool Speak(string message)
{
   // The TTS server must be running: python tts_server.py
   string url = "http://127.0.0.1:5000/speak";
   string headers = "Content-Type: application/json\r\n";

   // Escape double quotes in message (if any)
   StringReplace(message, "\"", "\\\"");

   // Build JSON payload
   string data = "{\"text\":\"" + message + "\"}";

   char post_data[];
   char result_data[];
   string result_headers;

   ArrayResize(post_data, StringToCharArray(data, post_data, 0, WHOLE_ARRAY) - 1);

   int timeout = 3000; // 3 seconds
   int res = WebRequest("POST", url, headers, timeout, post_data, result_data, result_headers);

   if(res == -1)
   {
      int err = GetLastError();
      Print("WebRequest error: ", err, " - Message: ", message);
      // Common errors:
      // 4060 - URL not allowed in MT5 options
      // 4062 - Connection refused (server not running)
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Place a market order (optional)                                  |
//+------------------------------------------------------------------+
void PlaceTrade(string signal)
{
   MqlTradeRequest request = {};
   MqlTradeResult  result = {};

   request.action   = TRADE_ACTION_DEAL;
   request.symbol   = _Symbol;
   request.volume   = LotSize;
   request.magic    = MagicNumber;
   request.deviation = 10;

   if(signal == "BUY")
   {
      request.type   = ORDER_TYPE_BUY;
      request.price  = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   }
   else if(signal == "SELL")
   {
      request.type   = ORDER_TYPE_SELL;
      request.price  = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   }
   else return;

   if(!OrderSend(request, result))
   {
      Print("OrderSend failed: ", result.retcode);
      if(EnableVoiceAlerts)
         Speak("Trade failed, check terminal.");
   }
   else
   {
      if(EnableVoiceAlerts)
      {
         string msg = StringFormat(
            "%s order placed at %.*f",
            signal,
            _Digits,
            request.price
         );
         Speak(msg);
      }
   }
}
//+------------------------------------------------------------------+