

//+------------------------------------------------------------------+
//|                                                       WndInd.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|Topic link:  https://www.mql5.com/en/articles/9260                |
//|Lib          https://www.mql5.com/en/articles/14710               |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"

#ifndef CWNDIND_MQH
#define CWNDIND_MQH
 #include <Object.mqh>
 //+------------------------------------------------------------------+
 //| Include Custom files                                             |
 //+------------------------------------------------------------------+ 
 #include "..\Defines\ChartDefines.mqh"
 #include "..\Notify\Message\Message.mqh"
#ifndef CWNDIND_MQH_DECLARATION
#define CWNDIND_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Chart window indicator object class                              |
 //+------------------------------------------------------------------+
 class CWndInd : public CObject
  {
   private:
      long              m_chart_id;                         // Chart ID
      string            m_name;                             // Indicator short name
      int               m_index;                            // Indicator index in the list
      int               m_window_num;                       // Indicator subwindow index
      int               m_handle;                           // Indicator handle
   
   public:
     //--- Return itself
      CWndInd          *GetObject(void)                     { return &this;               }
     //--- Return (1) indicator name, (2) index in the list, (3) indicator handle and (4) subwindow index
      string            Name(void)                    const { return this.m_name;         }
      int               Index(void)                   const { return this.m_index;        }
      int               Handle(void)                  const { return this.m_handle;       }
      int               WindowNum(void)               const { return this.m_window_num;   }
     //--- Resolve this line's real (type,params) identity - thin wrap over the built-in
     //--- IndicatorParameters(), symmetric to Handle()/Name() above.
      bool              GetIdentity(ENUM_INDICATOR &type, MqlParam &params[]) const
                          { return ::IndicatorParameters(this.m_handle, type, params) >= 0; }
     //--- Set (1) subwindow name, (2) window index on the chart, (3) handle, (4) index
      void              SetName(const string name)          { this.m_name=name;           }
      void              SetIndex(const int index)           { this.m_index=index;         }
      void              SetHandle(const int handle)         { this.m_handle=handle;       }
      void              SetWindowNum(const int win_num)     { this.m_window_num=win_num;  }
   
     //--- Display the description of object properties in the journal (dash=true - hyphen before the description, false - description only)
      void              Print(const bool dash=false)        { ::Print((dash ? "- " : "")+this.Header());                      }
     //--- Return the object short name
      string            Header(void)                  const { return CMessage::Text(MSG_CHART_OBJ_INDICATOR)+" "+this.Name(); }
   
     //--- Compare CWndInd objects with each other by the specified property
      virtual int       Compare(const CObject *node,const int mode=0) const;
     //--- Return an object type
      virtual int       Type(void)                    const { return OBJECT_DE_TYPE_CHART_WND_IND;                            }
     //--- Constructors
                     CWndInd(void){;}
                     CWndInd(const int handle,const string name,const int index,const int win_num) : m_handle(handle),
                                                                                                     m_name(name),
                                                                                                     m_index(index),
                                                                                                     m_window_num(win_num) {}
  };
#endif // CWNDIND_MQH_DECLARATION
#ifndef CWNDIND_MQH_IMPLEMENTATION
#define CWNDIND_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Compare CWndInd objects with each other by the specified property|
 //+------------------------------------------------------------------+
 int CWndInd::Compare(const CObject *node,const int mode=0) const
  {
   const CWndInd *obj_compared=node;
   if(mode==CHART_WINDOW_PROP_WINDOW_IND_HANDLE) return(this.Handle()>obj_compared.Handle() ? 1 : this.Handle()<obj_compared.Handle() ? -1 : 0);
   else if(mode==CHART_WINDOW_PROP_WINDOW_IND_INDEX) return(this.Index()>obj_compared.Index() ? 1 : this.Index()<obj_compared.Index() ? -1 : 0);
   return(this.Name()==obj_compared.Name() ? 0 : this.Name()<obj_compared.Name() ? -1 : 1);
  }
 //+------------------------------------------------------------------+
#endif // CWNDIND_MQH_IMPLEMENTATION
#endif // CWNDIND_MQH



