//+------------------------------------------------------------------+
//|                                             EA Configuration.mqh |
//| EA decides: Everything here                                      |
//+------------------------------------------------------------------+
#ifndef __EACONFIGURATION_MQH__
#define __EACONFIGURATION_MQH__
 //Setting folder and file
  #define EA_LAYOUT_FOLDER       (::MQLInfoString(MQL_PROGRAM_NAME)+"\\Layout")   // the columns the user chose for each table of the panel (a file for each)
  #define EA_DEBUG_FOLDER        "EA V4 SQLLite\\Debug"   // MY DEBUG: where the EA writes the step it is in (Breadcrumb)
 //Seting for timer
  #define EA_TIMER_MS            (16)
  #define EA_SERIES_REFRESH_MS   (250)   // OnTimer: the series of the symbols other than the chart's are read again at this pace (the chart's follow its ticks)
  #define EA_TRADE_REFRESH_MS    (250)   // the history, the orders and the events are looked at and written at this pace: a write that is refused (Python writes) waits for the next beat, the EA never waits for it
 // Setting for calculation  
  #define EA_HISTORY_WATCH_MS    (5000)  // after a trade the history of the terminal is looked at for this long (it lists the new order and deal a moment later) 
  #define EA_PYTHON_WRITE_ROWS   (5000) 
 // Color 
  #define BAR_MARKER_BUY_COLOR   (clrDodgerBlue)   // CBarMarker: the badge of a Buy
  #define BAR_MARKER_SELL_COLOR  (clrRed)          // and of a Sell
 //+------------------------------------------------------------------+
 //| MY DEBUG: the step the EA is in is written to a file, over the     |
 //| one before: after an abnormal termination it is the last one done  |
 //+------------------------------------------------------------------+
  void Breadcrumb(const string step)
   {
    static string debug_step="";   // MY DEBUG: a step that held the thread of the EA for half a second or more is told
    static ulong  debug_ms=0;
    ulong debug_now=::GetTickCount64();
    if(debug_step!="" && debug_step!="OnTimer: done" && debug_now-debug_ms>=500)
       ::Print("MY DEBUG    Breadcrumb: from \"",debug_step,"\" to \"",step,"\" took ",debug_now-debug_ms," ms");
    debug_step=step;
    debug_ms=debug_now;
    ::FolderCreate(EA_DEBUG_FOLDER);
    int handle=::FileOpen(EA_DEBUG_FOLDER+"\\Breadcrumb.txt",FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ);
    if(handle==INVALID_HANDLE)
       return;
    ::FileWriteString(handle,::TimeToString(::TimeLocal(),TIME_SECONDS)+" "+step);
    ::FileClose(handle);
   }
#endif // __EACONFIGURATION_MQH__
