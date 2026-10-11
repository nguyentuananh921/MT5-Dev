//+------------------------------------------------------------------+
//|                                  Persistence.mqh                 |
//|                                  Copyright 2026, MetaQuotes      |
//|                                  https://www.mql5.com            |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict
#include "MarketStructureTypes.mqh"

//+------------------------------------------------------------------+
//| CPersistence – logs structural events to a tab-separated CSV file|
//+------------------------------------------------------------------+
class CPersistence
  {
private:
   bool                 m_enabled;                                                  // true if persistence is active
   string               m_filename;                                                 // full path and name of the output CSV file
   int                  m_fileHandle;                                               // handle to the open file (INVALID_HANDLE when closed)
   string               m_symbol;                                                   // symbol for which events are being logged
   ENUM_TIMEFRAMES      m_tfInternal;                                               // internal timeframe (chart period)
   ENUM_TIMEFRAMES      m_tfExternal;                                               // external higher timeframe
   int                  m_flushInterval;                                            // number of writes between forced flushes to disk
   int                  m_flushCounter;                                             // current count of writes since last flush
   string               m_sessionUUID;                                              // unique identifier for this logging session

   void                WriteHeader();                                               // write version, UUID, and column names to the file

public:
                     CPersistence();
   void                Init(bool enable, string symbol,
                            ENUM_TIMEFRAMES internalTF, ENUM_TIMEFRAMES externalTF,
                            int flushInterval=10);                                  // initialise the logger and open the file
   void                WriteEvent(const SStructureEvent &event);                    // log a single event row
   void                Close();                                                     // flush and close the file
  };

//+------------------------------------------------------------------+
//| Constructor – initializes fields, disables persistence, sets     |
//| invalid file handle                                              |
//+------------------------------------------------------------------+
CPersistence::CPersistence()
  {
   m_enabled=false;
   m_fileHandle=INVALID_HANDLE;
   m_flushCounter=0;
   m_sessionUUID="";
  }

//+------------------------------------------------------------------+
//| Initialize persistence – generate session UUID, open CSV file,   |
//| write header if successful                                       |
//+------------------------------------------------------------------+
void CPersistence::Init(bool enable, string symbol,
                        ENUM_TIMEFRAMES internalTF, ENUM_TIMEFRAMES externalTF,
                        int flushInterval=10)
  {
   m_enabled=enable;
   if(!m_enabled)
      return;
   m_symbol = symbol;
   m_tfInternal = internalTF;
   m_tfExternal = externalTF;
   m_flushInterval = MathMax(1, flushInterval);                                 // at least 1 event before flushing
   m_flushCounter = 0;

   //--- generate a session UUID (pseudo-random, 8-4-4-4-12 hex digits)
   MathSrand(GetTickCount());
   string uuid = "";
   for(int i=0; i<8; i++)
      uuid += StringFormat("%02X", MathRand() % 256);
   uuid += "-";
   for(int i=0; i<4; i++)
      uuid += StringFormat("%02X", MathRand() % 256);
   uuid += "-";
   for(int i=0; i<4; i++)
      uuid += StringFormat("%02X", MathRand() % 256);
   uuid += "-";
   for(int i=0; i<4; i++)
      uuid += StringFormat("%02X", MathRand() % 256);
   uuid += "-";
   for(int i=0; i<12; i++)
      uuid += StringFormat("%02X", MathRand() % 256);
   m_sessionUUID = uuid;

   string tfStr = EnumToString(m_tfInternal);
   m_filename = "MarketStructure_"+m_symbol+"_"+tfStr+".csv";                    // file stored in common terminal folder
   m_fileHandle = FileOpen(m_filename, FILE_WRITE|FILE_CSV|FILE_COMMON, "\t");
   if(m_fileHandle!=INVALID_HANDLE)
      WriteHeader();                                                             // write metadata and column headers
  }

//+------------------------------------------------------------------+
//| Write the CSV header row with version, UUID, and column names    |
//+------------------------------------------------------------------+
void CPersistence::WriteHeader()
  {
   if(m_fileHandle==INVALID_HANDLE)
      return;
   FileWrite(m_fileHandle, "## version: 1.0");
   FileWrite(m_fileHandle, "# UUID: " + m_sessionUUID);
   FileWrite(m_fileHandle,
             "# event_id", "symbol", "tf", "external_tf", "time", "bar_index",
             "event_type", "price", "confidence", "direction", "level", "state");
  }

//+------------------------------------------------------------------+
//| WriteEvent – log a single structural event to the CSV file       |
//+------------------------------------------------------------------+
void CPersistence::WriteEvent(const SStructureEvent &event)
  {
   if(!m_enabled || m_fileHandle==INVALID_HANDLE)
      return;

   //--- choose the timeframe that matches the event's level
   ENUM_TIMEFRAMES tf = (event.level == LEVEL_INTERNAL) ? m_tfInternal : m_tfExternal;
   int barIdx = iBarShift(m_symbol, tf, event.time);                                   // bar index on that timeframe

   FileWrite(m_fileHandle,
             IntegerToString(event.eventId),
             m_symbol,
             EnumToString(m_tfInternal),
             EnumToString(m_tfExternal),
             TimeToString(event.time),
             IntegerToString(barIdx),
             EnumToString(event.type),
             DoubleToString(event.price, _Digits),
             DoubleToString(event.confidence,2),
             IntegerToString(event.direction),
             EnumToString(event.level),
             EnumToString(event.state));

   m_flushCounter++;
   if(m_flushCounter >= m_flushInterval)                                               // flush periodically to reduce I/O overhead
     {
      FileFlush(m_fileHandle);
      m_flushCounter = 0;
     }
  }

//+------------------------------------------------------------------+
//| Close – flush and close the persistence file                     |
//+------------------------------------------------------------------+
void CPersistence::Close(void)
  {
   if(m_fileHandle!=INVALID_HANDLE)
     {
      FileFlush(m_fileHandle);
      FileClose(m_fileHandle);
      m_fileHandle=INVALID_HANDLE;                                                     // mark as closed
     }
  }
//+------------------------------------------------------------------+