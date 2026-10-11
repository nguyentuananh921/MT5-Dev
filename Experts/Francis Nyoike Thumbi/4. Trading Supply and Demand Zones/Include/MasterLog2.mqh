//+------------------------------------------------------------------+
//|                                                   MasterLog1.mqh |
//|                                  Copyright 2026, Francis Nyoike. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Francis Nyoike."
#property link      "https://www.mql5.com"

//--- Global Enum Flags Exposed For Core Engine Compilation
enum ENUM_ZONE_EVENT
  {
   ZE_CREATED,       // Level established in memory or drawn by user
   ZE_MODIFIED,      // Boundaries or internal attributes adjusted
   ZE_UPDATED,       // Real-time touch/rejection tracking event [MUST HAVE]
   ZE_DELETED,       // Level explicitly purged from chart
   ZE_GHOSTED,       // Level breached but monitored
   ZE_RESURRECTED    // Level reactivated after price return
  };

//+------------------------------------------------------------------+
//| CLogger Class Architecture                                       |
//+------------------------------------------------------------------+
class CLogger
  {
private:
   int                m_file_handle;

   //--- Safe, Sequential CSV Line Injection Matrix
   void              WriteCSV(string &cols[])
     {
      if(m_file_handle == INVALID_HANDLE)
         return;

      //--- Always force file pointer to the end of the file to ensure strict appending
      FileSeek(m_file_handle, 0, SEEK_END);

      //--- Dynamically aggregate columns to prevent array out-of-bounds safety risks
      string line = "";
      int size = ArraySize(cols);
      for(int i = 0; i < size; i++)
        {
         line += cols[i];
         if(i < size - 1)
            line += ";";
        }

      FileWrite(m_file_handle, line);
      FileFlush(m_file_handle);
     }

   //--- Compact Local Time Capture String
   string            Now()
     {
      return TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
     }

public:
                     CLogger()
     {
      m_file_handle = INVALID_HANDLE;
     }

                    ~CLogger()
     {
      if(m_file_handle != INVALID_HANDLE)
        {
         FileClose(m_file_handle);
         m_file_handle = INVALID_HANDLE;
        }
     }

   //--- Isolated Multi-Asset & Timeframe File Allocation Engine
   void              Initialize()
     {
      //--- Verify sandbox folder path exists
      if(!FolderCreate("DynamicSR3"))
         Print(">>> Storage folder verified or initialized.");

      //--- Establish individual identity per Symbol and per Timeframe
      string path = "DynamicSR3\\SR_Prototype_" + _Symbol + "_" + EnumToString((ENUM_TIMEFRAMES)_Period) + ".csv";

      //--- Open with combined READ and WRITE access to facilitate appending without erasing data
      m_file_handle = FileOpen(path, FILE_WRITE|FILE_READ|FILE_CSV|FILE_ANSI|FILE_SHARE_READ|FILE_COMMON, ';');

      if(m_file_handle == INVALID_HANDLE)
        {
         Print("!!! PROTOTYPE LOGGER ERROR: FileOpen failed. Code: ", GetLastError());
         return;
        }

      //--- Write column matrix headers only if this is a brand new file allocation
      if(FileSize(m_file_handle) == 0)
        {
         string header[9] = {"Time", "Source", "Event", "Zone_ID", "Type", "Top", "Bottom", "Context", "Message"};
         WriteCSV(header);
        }

      //--- Skip straight to the historical end of the file to protect old data rows
      FileSeek(m_file_handle, 0, SEEK_END);

      string startup_msg = "Startup: " + _Symbol + " (" + EnumToString((ENUM_TIMEFRAMES)_Period) + ")";

      string startup_cols[9];
      startup_cols[0] = Now();
      startup_cols[1] = "SYSTEM";
      startup_cols[2] = "STARTUP";
      startup_cols[3] = "CORE";
      startup_cols[4] = "NONE";
      startup_cols[5] = "0.0";
      startup_cols[6] = "0.0";
      startup_cols[7] = "INIT";
      startup_cols[8] = startup_msg;

      //--- Simultaneous Execution: Commit row data and output directly to chart log
      WriteCSV(startup_cols);
      Print(startup_cols[8]);
     }

   //--- Clean Simultaneous Logging Engine
   void              LogZone(string src, ENUM_ZONE_EVENT event_type, string zone_name, string zone_type, double top, double bottom, string context_data, string compact_msg)
     {
      string cols[9];
      cols[0] = Now();
      cols[1] = src;                               // "USER", "AUTO", or "SYSTEM"
      cols[2] = EnumToString(event_type);          // Action state tracking enum
      cols[3] = zone_name;                         // Target chart handle object reference
      cols[4] = zone_type;                         // ZONE_SUPPORT / ZONE_RESISTANCE / NONE
      cols[5] = DoubleToString(top, _Digits);      // High boundary price
      cols[6] = DoubleToString(bottom, _Digits);   // Low boundary price
      cols[7] = context_data;                      // Internal metric tracking indicators (e.g. Score Matrix | Evolution Targets)
      cols[8] = compact_msg;                       // Clean, streamlined message copy

      //--- 1. Commit the full row to the persistent asset file matrix
      WriteCSV(cols);

      //--- 2. Direct unified mirror print to Terminal incorporating the Part III metrics pipeline
      Print(StringFormat("%s | Matrix Data: %s", cols[8], cols[7]));
     }
  };
//+------------------------------------------------------------------+

