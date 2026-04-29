//+------------------------------------------------------------------+
//|                                                   BaseObj.mqh    |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//|              Pure data — CGraphElmControl removed                |
//|              Extracted from: BaseObj.mqh                         |
//+------------------------------------------------------------------+
#ifndef __CBASEOBJ_MQH__
#define __CBASEOBJ_MQH__
 // TODO: review includes
  #include <Object.mqh>
  #include "..\Defines\Defines.mqh"
  #include "..\Notify\Message\Message.mqh"
  //#include "..\..\Services\DELib.mqh"
  #ifndef CBASEOBJ_MQH_DECLARATION
  #define CBASEOBJ_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Base object class for all library objects                         |
  //+------------------------------------------------------------------+
  class CBaseObj : public CObject
   {
    protected:
     // CGraphElmControl m_graph_elm; ← REMOVED
      ENUM_LOG_LEVEL         m_log_level;
      ENUM_PROGRAM_TYPE      m_program;
      bool                   m_first_start;
      bool                   m_use_sound;
      bool                   m_available;
      int                    m_global_error;
      long                   m_chart_id_main;
      long                   m_chart_id;
      string                 m_name_program;
      string                 m_name;
      string                 m_folder_name;
      string                 m_sound_name;
      int                    m_type;
    public:
      void              SetLogLevel(const ENUM_LOG_LEVEL level)  { m_log_level=level;            }
      ENUM_LOG_LEVEL    GetLogLevel(void)              const     { return m_log_level;           }
      void              SetMainChartID(const long id)            { m_chart_id_main=id;           }
      long              GetMainChartID(void)           const     { return m_chart_id_main;       }
      void              SetChartID(const long id)                { m_chart_id=id;                }
      long              GetChartID(void)               const     { return m_chart_id;            }
      void              SetSubFolderName(const string name)      { m_folder_name=DIRECTORY+name; }
      string            GetFolderName(void)            const     { return m_folder_name;         }
      void              SetSoundName(const string name)          { m_sound_name=name;            }
      string            GetSoundName(void)             const     { return m_sound_name;          }
      void              SetUseSound(const bool flag)             { m_use_sound=flag;             }
      bool              IsUseSound(void)               const     { return m_use_sound;           }
      void              SetAvailable(const bool flag)            { m_available=flag;             }
      bool              IsAvailable(void)              const     { return m_available;           }
      int               GetError(void)                 const     { return m_global_error;        }
      string            GetName(void)                  const     { return m_name;                }
      virtual int       Type(void)                     const     { return m_type;                }
      virtual void      Print(const bool full_prop=false,const bool dash=false)      { return; }
      virtual void      PrintShort(const bool dash=false,const bool symbol=false)    { return; }
    CBaseObj() : m_program((ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)),
                  m_name_program(::MQLInfoString(MQL_PROGRAM_NAME)),
                                  m_global_error(ERR_SUCCESS),
                                  m_log_level(LOG_LEVEL_ERROR_MSG),
                                  m_chart_id_main(::ChartID()),
                                  m_chart_id(::ChartID()),
                                  m_folder_name(DIRECTORY),
                                  m_sound_name(""),
                                  m_name(__FUNCTION__),
                                  m_type(OBJECT_DE_TYPE_BASE),
                                  m_use_sound(false),
                                  m_available(true),
                                  m_first_start(true) {}
  };
#endif // CBASEOBJ_MQH_DECLARATION
#endif // __CBASEOBJ_MQH__