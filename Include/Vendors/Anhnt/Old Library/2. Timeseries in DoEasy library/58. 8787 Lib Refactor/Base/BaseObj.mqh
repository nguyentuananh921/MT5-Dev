//+------------------------------------------------------------------+
//|                                                    BaseObj.mqh   |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//| Timeseries in DoEasy library                                     |
//| Lib link            https://www.mql5.com/en/articles/8787        |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Base object class for all library objects                        |
//+------------------------------------------------------------------+
#ifndef __BASEOBJ_MQH__
#define __BASEOBJ_MQH__
#include <Arrays\ArrayObj.mqh>
#include "..\Services\DELib.mqh"    
 class CBaseObj : public CObject
  {
    protected:
    ENUM_LOG_LEVEL    m_log_level;                              // Logging level
    ENUM_PROGRAM_TYPE m_program;                                // Program type
    bool              m_first_start;                            // First launch flag
    bool              m_use_sound;                              // Flag of playing the sound set for an object
    bool              m_available;                              // Flag of using a descendant object in the program
    int               m_global_error;                           // Global error code
    long              m_chart_id_main;                          // Control program chart ID
    long              m_chart_id;                               // Chart ID
    string            m_name;                                   // Object name
    string            m_folder_name;                            // Name of the folder storing CBaseObj descendant objects
    string            m_sound_name;                             // Object sound file name
    int               m_type;                                   // Object type (corresponds to the collection IDs)

    public:
    //--- (1) Set, (2) return the error logging level
    void              SetLogLevel(const ENUM_LOG_LEVEL level)         { this.m_log_level=level;                 }
    ENUM_LOG_LEVEL    GetLogLevel(void)                         const { return this.m_log_level;                }
    //--- (1) Set and (2) return the chart ID of the control program
    void              SetMainChartID(const long id)                   { this.m_chart_id_main=id;                }
    long              GetMainChartID(void)                      const { return this.m_chart_id_main;            }
    //--- (1) Set and (2) return chart ID
    void              SetChartID(const long id)                       { this.m_chart_id=id;                     }
    long              GetChartID(void)                          const { return this.m_chart_id;                 }
    //--- (1) Set the sub-folder name, (2) return the folder name for storing descendant object files
    void              SetSubFolderName(const string name)             { this.m_folder_name=DIRECTORY+name;      }
    string            GetFolderName(void)                       const { return this.m_folder_name;              }
    //--- (1) Set and (2) return the name of the descendant object sound file
    void              SetSoundName(const string name)                 { this.m_sound_name=name;                 }
    string            GetSoundName(void)                        const { return this.m_sound_name;               }
    //--- (1) Set and (2) return the flag of playing descendant object sounds
    void              SetUseSound(const bool flag)                    { this.m_use_sound=flag;                  }
    bool              IsUseSound(void)                          const { return this.m_use_sound;                }
    //--- (1) Set and (2) return the flag of using the descendant object in the program
    void              SetAvailable(const bool flag)                   { this.m_available=flag;                  }
    bool              IsAvailable(void)                         const { return this.m_available;                }
    //--- Return the global error code
    int               GetError(void)                            const { return this.m_global_error;             }
    //--- Return the object name
    string            GetName(void)                             const { return this.m_name;                     }
    //--- Return an object type
    virtual int       Type(void)                                const { return this.m_type;                     }
    //--- Constructor
                        CBaseObj() : m_program((ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)),
                                        m_global_error(ERR_SUCCESS),
                                        m_log_level(LOG_LEVEL_ERROR_MSG),
                                        m_chart_id_main(::ChartID()),
                                        m_chart_id(::ChartID()),
                                        m_folder_name(DIRECTORY),
                                        m_sound_name(""),
                                        m_name(__FUNCTION__),
                                        m_type(0),
                                        m_use_sound(false),
                                        m_available(true),
                                        m_first_start(true) {}
  };
  //+------------------------------------------------------------------+
#endif // __BASEOBJ_MQH__


