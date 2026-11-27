//+------------------------------------------------------------------+
//|                                                   BaseObj.mqh    |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//| https://www.mql5.com/en/articles/7124                            |
//| Lib https://www.mql5.com/en/articles/14710                       |
//| Pure data — CGraphElmControl removed                             |
//| Extracted from: BaseObj.mqh                                      |
//| Update from V4 Working with Event Event Rule                     |
//+------------------------------------------------------------------+
#ifndef __CBASEOBJ_MQH__
#define __CBASEOBJ_MQH__
  #include <Object.mqh>
  #include "..\Defines\CommonDefines.mqh"
  #include "..\..\Services\Message\Message.mqh"
  #ifndef CBASEOBJ_MQH_DECLARATION
  #define CBASEOBJ_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Base object class for all library objects                        |
  //+------------------------------------------------------------------+
  class CBaseObj : public CObject
   {
    protected:     
      ENUM_LOG_LEVELS         m_log_level;      //Standard Library MetaTrader 5 Enum
      ENUM_PROGRAM_TYPE       m_program;        //Standard Library MetaTrader 5 Enum
      bool                    m_first_start;
      bool                    m_use_sound;
      bool                    m_available;
      int                     m_global_error;
      string                  m_name_program;
      string                  m_name;
      string                  m_folder_name;
      string                  m_sound_name;
      int                     m_object_type;           // enum ENUM_OBJECT_DE_TYPE in CommonDefines.mqh
    public:
      void               SetLogLevel(const ENUM_LOG_LEVELS level)  { m_log_level=level;            }
      ENUM_LOG_LEVELS    GetLogLevel(void)              const     { return m_log_level;           }
      void               SetSubFolderName(const string name)      { m_folder_name=::MQLInfoString(MQL_PROGRAM_NAME)+"\\"+name; }
      string             GetFolderName(void)            const     { return m_folder_name;         }
      void               SetSoundName(const string name)          { m_sound_name=name;            }
      string             GetSoundName(void)             const     { return m_sound_name;          }
      void               SetUseSound(const bool flag)             { m_use_sound=flag;             }
      bool               IsUseSound(void)               const     { return m_use_sound;           }
      void               SetAvailable(const bool flag)            { m_available=flag;             }
      bool               IsAvailable(void)              const     { return m_available;           }
      int                GetError(void)                 const     { return m_global_error;        }
      string             GetName(void)                  const     { return m_name;                }
      virtual int        Type(void)                     const     { return m_object_type;                }
     //New added in https://www.mql5.com/en/articles/9751
      virtual void       Print(const bool full_prop=false,const bool dash=false)      { return; }
      virtual void       PrintShort(const bool dash=false,const bool symbol=false)    { return; }
     //New since V4 for woring with Event 
     //The event of a row. 
     // lparam: bits 0-31 the open time of the bar, 
     // 32-47 the key, 48-49 the side, 50 the row is new (judged at one new closed bar), 
     // 51-62 for a class. sparam: the symbol;what a class adds
      virtual long       EventPack(const datetime time,const long key,const ENUM_SIGNAL_DIRECTION side,const bool is_new) const;
      virtual string     EventPackText(const string symbol) const                     { return symbol; }
     //What the key and the text after the symbol mean is told by the id of the event (EventDefines.mqh)
      void               EventUnpack(const long lparam,datetime &time,long &key,ENUM_SIGNAL_DIRECTION &side,bool &is_new) const;
      void               EventUnpackText(const string sparam,string &symbol,string &extra) const;
     //Change in V5: an event goes on the bus of the EA (a queue in the program, not the chart of MT5: EventChartCustom lost the events sent in OnTrade, error 4104).
     //The EA (the parent) takes them in order at the end of each of its handlers (EventNext) and gives each to every child, as OnChartEvent did
      bool               EventSend(const ushort id,const long lparam,const double dparam,const string sparam) const;
      static bool        EventNext(ushort &id,long &lparam,double &dparam,string &sparam);   // the oldest event waiting; false: none
    private:
      static ushort      s_event_id[];
      static long        s_event_lparam[];
      static double      s_event_dparam[];
      static string      s_event_sparam[];
      static int         s_event_next;   // the index of the oldest event not taken yet
    public:
     CBaseObj() : m_program((ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)),
                  m_name_program(::MQLInfoString(MQL_PROGRAM_NAME)),
                                  m_global_error(ERR_SUCCESS),
                                  m_log_level(LOG_LEVEL_ERRORS),
                                  m_folder_name(::MQLInfoString(MQL_PROGRAM_NAME)),
                                  m_sound_name(""),
                                  m_name(__FUNCTION__),
                                  m_object_type(OBJECT_DE_TYPE_BASE),
                                  m_use_sound(false),
                                  m_available(true),
                                  m_first_start(true) {}
  };
#endif // CBASEOBJ_MQH_DECLARATION
  #ifndef CBASEOBJ_MQH_IMPLEMENTATION
  #define CBASEOBJ_MQH_IMPLEMENTATION
  long CBaseObj::EventPack(const datetime time,const long key,const ENUM_SIGNAL_DIRECTION side,const bool is_new) const
   {
    return((long)time|((long)(ushort)key<<32)|(((long)side&3)<<48)|((long)is_new<<50));
   }
  void CBaseObj::EventUnpack(const long lparam,datetime &time,long &key,ENUM_SIGNAL_DIRECTION &side,bool &is_new) const
   {
    time=(datetime)(uint)lparam;
    key=(long)(ushort)(lparam>>32);
    side=(ENUM_SIGNAL_DIRECTION)((lparam>>48)&3);
    is_new=(((lparam>>50)&1)!=0);
   }
  void CBaseObj::EventUnpackText(const string sparam,string &symbol,string &extra) const
   {
    int split=::StringFind(sparam,";");
    symbol=(split<0 ? sparam : ::StringSubstr(sparam,0,split));
    extra=(split<0 ? "" : ::StringSubstr(sparam,split+1));
   }
  ushort CBaseObj::s_event_id[];
  long   CBaseObj::s_event_lparam[];
  double CBaseObj::s_event_dparam[];
  string CBaseObj::s_event_sparam[];
  int    CBaseObj::s_event_next=0;
  bool CBaseObj::EventSend(const ushort id,const long lparam,const double dparam,const string sparam) const
   {
    const int n=::ArraySize(s_event_id);
    if(::ArrayResize(s_event_id,n+1,64)!=n+1 || ::ArrayResize(s_event_lparam,n+1,64)!=n+1 || ::ArrayResize(s_event_dparam,n+1,64)!=n+1 || ::ArrayResize(s_event_sparam,n+1,64)!=n+1)
       return false;
    s_event_id[n]=id;
    s_event_lparam[n]=lparam;
    s_event_dparam[n]=dparam;
    s_event_sparam[n]=sparam;
    return true;
   }
  bool CBaseObj::EventNext(ushort &id,long &lparam,double &dparam,string &sparam)
   {
    if(s_event_next>=::ArraySize(s_event_id))
      {
       //--- every event taken: the queue starts again empty
       ::ArrayResize(s_event_id,0,64);
       ::ArrayResize(s_event_lparam,0,64);
       ::ArrayResize(s_event_dparam,0,64);
       ::ArrayResize(s_event_sparam,0,64);
       s_event_next=0;
       return false;
      }
    id=s_event_id[s_event_next];
    lparam=s_event_lparam[s_event_next];
    dparam=s_event_dparam[s_event_next];
    sparam=s_event_sparam[s_event_next];
    s_event_next++;
    return true;
   }
#endif // CBASEOBJ_MQH_IMPLEMENTATION
#endif // __CBASEOBJ_MQH__