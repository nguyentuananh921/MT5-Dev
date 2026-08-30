//+------------------------------------------------------------------+
//|                                              SignalBridgeRow.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = 1 already-gated signal row (time, TF, direction,    |
//| source) waiting to be written to SignalBridge_<SYMBOL>.dat.      |
//| Held LIVE in a CArrayObj inside CSignalBridgeWriter::            |
//| BuildAndWriteSignalBridge() - replaces the old 4 parallel raw    |
//| arrays (row_time[]/row_tf[]/row_dir[]/row_source[]) that needed  |
//| a hand-rolled O(n^2) bubble sort to keep in time order. Compare()|
//| lets CArrayObj::Sort() do it in O(n log n) instead (Anhnt,       |
//| 2026-08-29).                                                     |
//+------------------------------------------------------------------+
#ifndef __SIGNALBRIDGEROW_MQH__
#define __SIGNALBRIDGEROW_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib\Base\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Signal\SignalBase.mqh>

 #ifndef CSIGNALBRIDGEROW_MQH_DECLARATION
 #define CSIGNALBRIDGEROW_MQH_DECLARATION
 //+------------------------------------------------------------------------------------+
 //| CSignalBridgeRow - 1 output row for the Signal Bridge file. Write-once snapshot,   |
 //| no setters - built fully-known at construction, never mutated after.               |
 //+------------------------------------------------------------------------------------+
 class CSignalBridgeRow : public CBaseObj
   {
     private:
       datetime          m_time;
       int               m_tf;      // ENUM_TIMEFRAMES, stored raw same as the .dat file format
       ENUM_SIGNAL_DIR   m_dir;     // SIGNAL_BUY/SIGNAL_SELL - reuse the existing Library enum,
                                    // not a new +1/-1 convention
       int               m_source;  // 0 = Indicator, 1 = Pattern - matches SIGNAL_BRIDGE_MAGIC v2 file format

     public:
                         CSignalBridgeRow(const datetime t, const int tf, const ENUM_SIGNAL_DIR dir, const int source);
                        ~CSignalBridgeRow(void) {}

       datetime          Time(void)   const { return m_time;   }
       int               TF(void)     const { return m_tf;     }
       ENUM_SIGNAL_DIR   Dir(void)    const { return m_dir;    }
       int               Source(void) const { return m_source; }

      //--- CArrayObj::Sort() calls this on each pair - sort key is Time only.
       virtual int       Compare(const CObject *node, const int mode=0) const;
       virtual void      Print(const bool full_prop=false, const bool dash=false);
   };
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CSignalBridgeRow::CSignalBridgeRow(const datetime t, const int tf, const ENUM_SIGNAL_DIR dir, const int source)
   : m_time(t), m_tf(tf), m_dir(dir), m_source(source)
   {
     this.m_type = OBJECT_DE_TYPE_SIGNAL_BRIDGE_ROW;
   }
 //+------------------------------------------------------------------+
 //| Compare - ascending by Time                                      |
 //+------------------------------------------------------------------+
 int CSignalBridgeRow::Compare(const CObject *node, const int mode=0) const
   {
     const CSignalBridgeRow *other = (const CSignalBridgeRow*)node;
     if(m_time < other.Time()) return -1;
     if(m_time > other.Time()) return  1;
     return 0;
   }
 //+------------------------------------------------------------------+
 //| Debug dump                                                        |
 //+------------------------------------------------------------------+
 void CSignalBridgeRow::Print(const bool full_prop=false, const bool dash=false)
   {
     ::Print((dash ? " - " : ""), "CSignalBridgeRow::Print time=", ::TimeToString(m_time, TIME_DATE|TIME_SECONDS),
             " tf=", m_tf, " dir=", EnumToString(m_dir), " source=", m_source);
   }
 #endif // CSIGNALBRIDGEROW_MQH_DECLARATION
#endif // __SIGNALBRIDGEROW_MQH__
