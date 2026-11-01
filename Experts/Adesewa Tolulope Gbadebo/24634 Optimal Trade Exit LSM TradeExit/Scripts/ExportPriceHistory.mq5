//+------------------------------------------------------------------+
//| ExportPriceHistory.mq5                                           |
//+------------------------------------------------------------------+
#property copyright "Adesewa"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "One-off export of historical close prices to CSV"
#property script_show_inputs

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string InpSymbol       = "XAUUSD";  // Symbol to export (blank = current chart symbol)
input ENUM_TIMEFRAMES InpTF  = PERIOD_M5; // Timeframe to export
input int InpBarCount        = 500;       // Number of most recent CLOSED bars to export

//+------------------------------------------------------------------+
//| OnStart                                                          |
//+------------------------------------------------------------------+
// Exports InpBarCount closed bars of InpSymbol/InpTF as (time, close)
// rows to a CSV in the shared Common\Files folder. This is a one-off
// analysis tool, not part of the EA/indicator/include trio - it exists
// only to feed real calibration data into an offline Python
// reproduction of CLSMExitEngine, and is not itself attached to a
// chart or run repeatedly.
void OnStart(void)
  {
   string symbol = (InpSymbol == "") ? _Symbol : InpSymbol;

//--- shift the copy start index by 1 so the export begins at the last
//--- fully CLOSED bar, never the still-forming current bar - starting
//--- at index 0 would make the export's last row silently change
//--- every time the script is re-run intraday
   datetime times[];
   double   closes[];
   int copied_t = CopyTime(symbol, InpTF, 1, InpBarCount, times);
   int copied_c = CopyClose(symbol, InpTF, 1, InpBarCount, closes);
   int n = MathMin(copied_t, copied_c);

   if(n < InpBarCount)
      Print("OnStart: only ", n, " of ", InpBarCount,
            " requested bars are available in history - exporting what is there");
   if(n <= 0)
     {
      Print("OnStart: no history available for ", symbol, " on the requested timeframe");
      return;
     }

//--- neither times[] nor closes[] is switched into series mode here,
//--- so CopyTime/CopyClose fill them the plain way: index 0 is the
//--- OLDEST bar in the requested range, and the last index is the
//--- most recent closed bar. The file is written out in that same
//--- oldest-first order, which is what a CSV meant to be read top to
//--- bottom in chronological order should look like - note that this
//--- is the opposite convention from CalibrateFromHistory() in
//--- LSMEngine.mqh, which explicitly series-indexes its own copy so
//--- index 0 means "most recent" there instead
   string filename = "LSMTradeExit_PriceExport_" + symbol + ".csv";
   int handle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_COMMON | FILE_ANSI, ',');
   if(handle == INVALID_HANDLE)
     {
      Print("OnStart: failed to open ", filename, ", error ", GetLastError());
      return;
     }

   FileWrite(handle, "time", "close");
   for(int i = 0; i < n; i++)
      FileWrite(handle, TimeToString(times[i], TIME_DATE | TIME_MINUTES | TIME_SECONDS),
                DoubleToString(closes[i], _Digits));

   FileClose(handle);
   Print("OnStart: exported ", n, " bars of ", symbol, " to Common\\Files\\", filename);
  }
//+------------------------------------------------------------------+
//| End of file                                                      |
//+------------------------------------------------------------------+
