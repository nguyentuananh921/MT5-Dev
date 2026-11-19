//+------------------------------------------------------------------+
//|                                                     SyncMark.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = 1 row of Setting_Sync of this account (read from    |
//| the table), or a mark of the library (RAM only, never written)   |
//| New in V5: was struct SSyncMark kept as a member of CSyncManager |
//+------------------------------------------------------------------+
#ifndef __SYNCMARK_MQH__
#define __SYNCMARK_MQH__
 #include <Object.mqh>
#ifndef CSYNCMARK_MQH_DECLARATION
#define CSYNCMARK_MQH_DECLARATION
 class CSyncMark : public CObject
  {
   private:
    long              m_sync_object;   // the m_type of the collection that finds (key of the row, with the next four)
    long              m_key;           // type_infor, or the type of an indicator
    string            m_params;        // the params of an indicator ('' for a type_infor)
    string            m_symbol;
    ENUM_TIMEFRAMES   m_timeframe;
    datetime          m_last_update;   // the newest bar synced
    long              m_sync_by;       // the object that did it (its m_type)
   public:
                      CSyncMark(const long sync_object,const long key,const string params,const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime last_update,const long sync_by) :
                         m_sync_object(sync_object),m_key(key),m_params(params),m_symbol(symbol),m_timeframe(timeframe),m_last_update(last_update),m_sync_by(sync_by) {}
    long              SyncObject(void)  const { return m_sync_object; }
    long              Key(void)         const { return m_key;         }
    string            Params(void)      const { return m_params;      }
    datetime          LastUpdate(void)  const { return m_last_update; }
   //--- The mark of the object on the pair (any key, IsOf) / of the key too (IsKey)
    bool              IsOf(const long sync_object,const string symbol,const ENUM_TIMEFRAMES timeframe) const { return (m_sync_object==sync_object && m_symbol==symbol && m_timeframe==timeframe); }
    bool              IsKey(const long sync_object,const long key,const string params,const string symbol,const ENUM_TIMEFRAMES timeframe) const { return (this.IsOf(sync_object,symbol,timeframe) && m_key==key && m_params==params); }
   //--- The newest bar synced moves forward only (false: it is not newer)
    bool              MoveTo(const datetime last_update,const long sync_by);
  };
#endif // CSYNCMARK_MQH_DECLARATION
#ifndef CSYNCMARK_MQH_IMPLEMENTATION
#define CSYNCMARK_MQH_IMPLEMENTATION
 bool CSyncMark::MoveTo(const datetime last_update,const long sync_by)
  {
   if(m_last_update>=last_update)
      return false;
   m_last_update=last_update;
   m_sync_by=sync_by;
   return true;
  }
#endif // CSYNCMARK_MQH_IMPLEMENTATION
#endif // __SYNCMARK_MQH__
