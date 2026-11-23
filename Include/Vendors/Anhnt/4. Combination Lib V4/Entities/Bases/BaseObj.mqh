//+------------------------------------------------------------------+
//|                                                   BaseObj.mqh    |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//| https://www.mql5.com/en/articles/7124                            |
//|Lib https://www.mql5.com/en/articles/14710                        |
//|              Pure data — CGraphElmControl removed                |
//|              Extracted from: BaseObj.mqh                         |
//| Update in V4 Working with Event Event Rule                       |
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
     //New in V4 for woring with Event 
     //The event of a row. lparam: bits 0-31 the open time of the bar, 32-47 the key, 48-49 the side, 50 the row is new (judged at one new closed bar), 51-62 for a class. sparam: the symbol;what a class adds
      virtual long       EventPack(const datetime time,const long key,const ENUM_SIGNAL_DIRECTION side,const bool is_new) const;
      virtual string     EventPackText(const string symbol) const                     { return symbol; }
     //What the key and the text after the symbol mean is told by the id of the event (EventDefines.mqh)
      void               EventUnpack(const long lparam,datetime &time,long &key,ENUM_SIGNAL_DIRECTION &side,bool &is_new) const;
      void               EventUnpackText(const string sparam,string &symbol,string &extra) const;
     //An event goes on the bus of the chart (its queue): OnChartEvent of the EA gives it to every hand
      bool               EventSend(const ushort id,const long lparam,const double dparam,const string sparam) const;
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
  bool CBaseObj::EventSend(const ushort id,const long lparam,const double dparam,const string sparam) const
   {
    return ::EventChartCustom(::ChartID(),id,lparam,dparam,sparam);
   }
#endif // CBASEOBJ_MQH_IMPLEMENTATION
#endif // __CBASEOBJ_MQH__