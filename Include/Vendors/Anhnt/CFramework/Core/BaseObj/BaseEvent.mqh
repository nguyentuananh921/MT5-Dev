//+------------------------------------------------------------------+
//|                                                    BaseEvent.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Library object's base event class                                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Software Corp."
#property link      "nguyentuananh921@gmail.com"
#property version   "1.00"
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>
/*

#include "..\Services\DELib.mqh"
#include "..\Objects\Graph\GraphElmControl.mqh"
*/
#include <Vendors/Anhnt/CFramework/Old/Services/DELib.mqh>
#include <Vendors/Anhnt/CFramework/Core/BaseGraph/GraphElmControl.mqh>

class CBaseEvent : public CObject
  {
   private:
      ENUM_BASE_EVENT_REASON  m_reason;
      int                     m_event_id;
      double                  m_value;
   public:
      ENUM_BASE_EVENT_REASON  Reason(void)   const { return this.m_reason;    }
      int                     ID(void)       const { return this.m_event_id;  }
      double                  Value(void)    const { return this.m_value;     }
   //--- Constructor
                              CBaseEvent(const int event_id,const ENUM_BASE_EVENT_REASON reason,const double value) : m_reason(reason),
                                                                                                                     m_event_id(event_id),
                                                                                                                     m_value(value){}
   //--- Comparison method to search for identical event objects
      virtual int             Compare(const CObject *node,const int mode=0) const 
                              {   
                                 const CBaseEvent *compared=node;
                                 return
                                 (
                                    this.Reason()>compared.Reason()  ?  1  :
                                    this.Reason()<compared.Reason()  ? -1  :
                                    this.ID()>compared.ID()          ?  1  :
                                    this.ID()<compared.ID()          ? -1  : 0
                                 );
                              } 
  };
//Implementaion
   //+------------------------------------------------------------------+
   //| Base object class for all library objects                        |
   //+------------------------------------------------------------------+
   class CBaseObj : public CObject
   {
   protected:
      CGraphElmControl  m_graph_elm;                              // Instance of the class for managing graphical elements
      ENUM_LOG_LEVEL    m_log_level;                              // Logging level
      ENUM_PROGRAM_TYPE m_program;                                // Program type
      bool              m_first_start;                            // First launch flag
      bool              m_use_sound;                              // Flag of playing the sound set for an object
      bool              m_available;                              // Flag of using a descendant object in the program
      int               m_global_error;                           // Global error code
      long              m_chart_id_main;                          // Control program chart ID
      long              m_chart_id;                               // Chart ID
      string            m_name_program;                           // Program name
      string            m_name;                                   // Object name
      string            m_folder_name;                            // Name of the folder storing CBaseObj descendant objects
      string            m_sound_name;                             // Object sound file name
      int               m_type;                                   // Object type (corresponds to the object type from the ENUM_OBJECT_DE_TYPE enumeration)

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
   //--- Display the description of the object properties in the journal (full_prop=true - all properties, false - supported ones only - implemented in descendant classes)
      virtual void      Print(const bool full_prop=false,const bool dash=false)  { return;                        }
   //--- Display a short description of the object in the journal
      virtual void      PrintShort(const bool dash=false,const bool symbol=false){ return;                        }

   //+------------------------------------------------------------------+
   //| Methods for handling graphical elements                          |
   //+------------------------------------------------------------------+
   //--- Create a form object on a specified chart in a specified subwindow
      CForm            *CreateForm(const int form_id,const long chart_id,const int wnd,const string name,const int x,const int y,const int w,const int h)
                        { return this.m_graph_elm.CreateForm(form_id,chart_id,wnd,name,x,y,w,h);                }
   //--- Create a form object on the current chart in a specified subwindow
      CForm            *CreateForm(const int form_id,const int wnd,const string name,const int x,const int y,const int w,const int h)
                        { return this.m_graph_elm.CreateForm(form_id,wnd,name,x,y,w,h);                         }
   //--- Create the form object on the current chart in the main window
      CForm            *CreateForm(const int form_id,const string name,const int x,const int y,const int w,const int h)
                        { return this.m_graph_elm.CreateForm(form_id,name,x,y,w,h);                             }
      
   //--- Create a standard graphical trend line object in the specified subwindow of the specified chart
      bool              CreateTrendLine(const long chart_id,const string name,const int subwindow,
                                       const datetime time1,const double price1,
                                       const datetime time2,const double price2,
                                       color clr,int width=1,ENUM_LINE_STYLE style=STYLE_SOLID)
                        { return this.m_graph_elm.CreateTrendLine(chart_id,name,subwindow,time1,price1,time2,price2,clr,width,style);   }
   //--- Create a standard graphical trend line object in the specified subwindow of the current chart
      bool              CreateTrendLine(const string name,const int subwindow,
                                       const datetime time1,const double price1,
                                       const datetime time2,const double price2,
                                       color clr,int width=1,ENUM_LINE_STYLE style=STYLE_SOLID)
                        { return this.m_graph_elm.CreateTrendLine(::ChartID(),name,subwindow,time1,price1,time2,price2,clr,width,style);}
   //--- Create a standard graphical trend line object in the main window of the current chart
      bool              CreateTrendLine(const string name,
                                       const datetime time1,const double price1,
                                       const datetime time2,const double price2,
                                       color clr,int width=1,ENUM_LINE_STYLE style=STYLE_SOLID)
                        { return this.m_graph_elm.CreateTrendLine(::ChartID(),name,0,time1,price1,time2,price2,clr,width,style);        }
      
   //--- Create a standard arrow graphical object in the specified subwindow of the specified chart
      bool              CreateArrow(const long chart_id,const string name,const int subwindow,
                                    const datetime time1,const double price1,
                                    color clr,uchar arrow_code,int width=1)
                        { return this.m_graph_elm.CreateArrow(chart_id,name,subwindow,time1,price1,clr,arrow_code,width);               }
   //--- Create a standard arrow graphical object in the specified subwindow of the current chart
      bool              CreateArrow(const string name,const int subwindow,
                                    const datetime time1,const double price1,
                                    color clr,uchar arrow_code,int width=1)
                        { return this.m_graph_elm.CreateArrow(::ChartID(),name,subwindow,time1,price1,clr,arrow_code,width);            }
   //---  Create a standard arrow graphical object in the main window of the current chart
      bool              CreateArrow(const string name,
                                    const datetime time1,const double price1,
                                    color clr,uchar arrow_code,int width=1)
                        { return this.m_graph_elm.CreateArrow(::ChartID(),name,0,time1,price1,clr,arrow_code,width);                    }
      
   //--- Constructor
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
   //+------------------------------------------------------------------+
   //+------------------------------------------------------------------+
   //| Extended base object class for all library objects               |
   //+------------------------------------------------------------------+
   #define  CONTROLS_TOTAL    (10)