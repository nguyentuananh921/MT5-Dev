//+------------------------------------------------------------------+
//|                                                     GBaseObj.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4

#ifndef CGBASEEVENT_MQH
#define CGBASEEVENT_MQH
 #include <Graphics\Graphic.mqh>
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 //#include "..\..\Services\DELib.mqh"
 #include "..\..\Services\DELib\GraphicDELib.mqh"
 #include "..\..\Defines\Defines.mqh"
 #include "CGBaseEvent.mqh"
 #include "..\..\Notify\Message\Message.mqh"
#ifndef CGBASEEVENT_MQH_DECLARATION
#define CGBASEEVENT_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Class of the base object of the library graphical objects        |
//+------------------------------------------------------------------+
class CGBaseObj : public CObject
 {
  private:

  protected:
    CArrayObj         m_list_events;                      // Object event list
    ENUM_OBJECT       m_type_graph_obj;                   // Graphical object type
    ENUM_GRAPH_ELEMENT_TYPE m_type_element;               // Graphical element type
    ENUM_GRAPH_OBJ_BELONG m_belong;                       // Program affiliation
    ENUM_GRAPH_OBJ_SPECIES m_species;                     // Graphical object species
    string            m_name_prefix;                      // Object name prefix
    string            m_name;                             // Object name
    long              m_chart_id;                         // Object chart ID
    long              m_object_id;                        // Object ID
    long              m_zorder;                           // Priority of a graphical object for receiving the mouse click event
    int               m_subwindow;                        // Subwindow index
    int               m_shift_y;                          // Y coordinate shift for the subwindow
    int               m_type;                             // Object type
    int               m_timeframes_visible;               // Visibility of an object on timeframes (a set of flags)
    int               m_digits;                           // Number of decimal places in a quote
    int               m_group;                            // Graphical object group
    bool              m_visible;                          // Object visibility
    bool              m_back;                             // "Background object" flag
    bool              m_selected;                         // "Object selection" flag
    bool              m_selectable;                       // "Object availability" flag
    bool              m_hidden;                           // "Disable displaying the name of a graphical object in the terminal object list" flag
    datetime          m_create_time;                      // Object creation time
    
   //--- Create (1) the object structure and (2) the object from the structure
    virtual bool      ObjectToStruct(void)                      { return true; }
    virtual void      StructToObject(void)                      {;}

   //--- Return the list of object events
    CArrayObj        *GetListEvents(void)                       { return &this.m_list_events;          }
   //--- Create a new object event
    CGBaseEvent      *CreateNewEvent(const ushort event_id,const long lparam,const double dparam,const string sparam) { return new CGBaseEvent(event_id,lparam,dparam,sparam); }
   //--- Create a new object event and add it to the event list
    bool              CreateAndAddNewEvent(const ushort event_id,const long lparam,const double dparam,const string sparam) { return this.AddEvent(new CGBaseEvent(event_id,lparam,dparam,sparam)); }
   //--- Add an event object to the event list
    bool              AddEvent(CGBaseEvent *event)              { return this.m_list_events.Add(event);}
   //--- Clear the event list
    void              ClearEventsList(void)                     { this.m_list_events.Clear();          }
   //--- Return the number of events in the list
    int               EventsTotal(void)                         { return this.m_list_events.Total();   }

  public:
   //--- Constructor/destructor
                      CGBaseObj();
                      ~CGBaseObj(){;}

   //--- Return the prefix name
    string            NamePrefix(void)                    const { return this.m_name_prefix;           }
   //--- Set the values of the class variables
    void              SetObjectID(const long value)             { this.m_object_id=value;              }
    void              SetBelong(const ENUM_GRAPH_OBJ_BELONG belong){ this.m_belong=belong;             }
    void              SetTypeGraphObject(const ENUM_OBJECT obj) { this.m_type_graph_obj=obj;           }
    void              SetTypeElement(const ENUM_GRAPH_ELEMENT_TYPE type) { this.m_type_element=type;   }
    void              SetSpecies(const ENUM_GRAPH_OBJ_SPECIES species){ this.m_species=species;        }
    virtual void      SetGroup(const int value)                 { this.m_group=value;                  }
    void              SetName(const string name)                { this.m_name=name;                    }
    void              SetDigits(const int value)                { this.m_digits=value;                 }
    void              SetChartID(const long chart_id)           { this.m_chart_id=(chart_id==NULL || chart_id==0 ? ::ChartID() : chart_id); }
    
   //--- Set the properties
    bool              SetFlagBack(const bool flag,const bool only_prop);
    bool              SetFlagSelected(const bool flag,const bool only_prop);
    bool              SetFlagSelectable(const bool flag,const bool only_prop);
    bool              SetFlagHidden(const bool flag,const bool only_prop);
    virtual bool      SetZorder(const long value,const bool only_prop);
    virtual bool      SetXOffset(const long value);
    virtual bool      SetYOffset(const long value);
    virtual bool      SetXSize(const long value);
    virtual bool      SetYSize(const long value);
    bool              SetVisibleFlag(const bool flag,const bool only_prop);
    bool              SetVisibleOnTimeframes(const int flags,const bool only_prop);
    bool              SetVisibleOnTimeframe(const ENUM_TIMEFRAMES timeframe,const bool only_prop);
    bool              SetSubwindow(const long chart_id,const string name);
    bool              SetSubwindow(void);

   //--- Return the values of class variables
    virtual int       XOffset(void)                       const { return (int)::ObjectGetInteger(this.m_chart_id,this.m_name,OBJPROP_XOFFSET); }
    virtual int       YOffset(void)                       const { return (int)::ObjectGetInteger(this.m_chart_id,this.m_name,OBJPROP_YOFFSET); }
    virtual int       XSize(void)                         const { return (int)::ObjectGetInteger(this.m_chart_id,this.m_name,OBJPROP_XSIZE);   }
    virtual int       YSize(void)                         const { return (int)::ObjectGetInteger(this.m_chart_id,this.m_name,OBJPROP_YSIZE);   }
    ENUM_GRAPH_ELEMENT_TYPE TypeGraphElement(void)        const { return this.m_type_element;       }
    ENUM_GRAPH_OBJ_BELONG   Belong(void)                  const { return this.m_belong;             }
    ENUM_GRAPH_OBJ_SPECIES  Species(void)                 const { return this.m_species;            }
    ENUM_OBJECT       TypeGraphObject(void)               const { return this.m_type_graph_obj;     }
    datetime          TimeCreate(void)                    const { return this.m_create_time;        }
    string            Name(void)                          const { return this.m_name;               }
    long              ChartID(void)                       const { return this.m_chart_id;           }
    long              ObjectID(void)                      const { return this.m_object_id;          }
    virtual long      Zorder(void)                        const { return this.m_zorder;             }
    int               SubWindow(void)                     const { return this.m_subwindow;          }
    int               ShiftY(void)                        const { return this.m_shift_y;            }
    int               VisibleOnTimeframes(void)           const { return this.m_timeframes_visible; }
    int               Digits(void)                        const { return this.m_digits;             }
    virtual int       Group(void)                         const { return this.m_group;              }
    bool              IsBack(void)                        const { return this.m_back;               }
    bool              IsSelected(void)                    const { return this.m_selected;           }
    bool              IsSelectable(void)                  const { return this.m_selectable;         }
    bool              IsHidden(void)                      const { return this.m_hidden;             }
    bool              IsVisible(void)                     const { return this.m_visible;            }

   //--- Return the graphical object type (ENUM_OBJECT) calculated from the object type (ENUM_OBJECT_DE_TYPE) passed to the method
    ENUM_OBJECT       GraphObjectType(const ENUM_OBJECT_DE_TYPE obj_type) const { return ENUM_OBJECT(obj_type-OBJECT_DE_TYPE_GSTD_OBJ-1); }
    
   //--- Return the description of the type of the graphical object (1) type, (2, 3) element, (4) affiliation and (5) species
    string            TypeGraphObjectDescription(void);
    string            TypeElementDescription(const ENUM_GRAPH_ELEMENT_TYPE type);
    string            TypeElementDescription(void);
    string            BelongDescription(void);
    string            SpeciesDescription(void);

   //--- The virtual method returning the object type
    virtual int       Type(void)                          const { return this.m_type;               }
  };
#endif // CGBASEEVENT_MQH_DECLARATION
#ifndef CGBASEEVENT_MQH_IMPLEMENTATION
#define CGBASEEVENT_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CGBaseObj::CGBaseObj() : m_name_prefix(::MQLInfoString(MQL_PROGRAM_NAME)+"_"),m_belong(GRAPH_OBJ_BELONG_PROGRAM)
  {
   this.m_list_events.Clear();                  // Clear the event list
   this.m_list_events.Sort();                   // Sorted list flag
   this.m_type=OBJECT_DE_TYPE_GBASE;            // Object type
   this.m_type_graph_obj=WRONG_VALUE;           // Graphical object type
   this.m_type_element=WRONG_VALUE;             // Graphical object type
   this.m_belong=WRONG_VALUE;                   // Program/terminal affiliation
   this.m_group=0;                              // Group of graphical objects
   this.m_name="";                              // Object name
   this.m_chart_id=0;                           // Object chart ID
   this.m_object_id=0;                          // Object ID
   this.m_zorder=0;                             // Priority of a graphical object for receiving the mouse click event
   this.m_subwindow=0;                          // Subwindow index
   this.m_shift_y=0;                            // Y coordinate shift for the subwindow
   this.m_timeframes_visible=OBJ_ALL_PERIODS;   // Visibility of an object on timeframes (a set of flags)
   this.m_visible=true;                         // Object visibility
   this.m_back=false;                           // "Background object" flag
   this.m_selected=false;                       // "Object selection" flag
   this.m_selectable=false;                     // "Object availability" flag
   this.m_hidden=true;                          // "Disable displaying the name of a graphical object in the terminal object list" flag
   this.m_create_time=0;                        // Object creation time
  }
 //+------------------------------------------------------------------+
 //| Set the "Background object" flag                                 |
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetFlagBack(const bool flag,const bool only_prop)
  {
   ::ResetLastError();
   if((!only_prop && ::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_BACK,flag)) || only_prop)
     {
      this.m_back=flag;
      return true;
     }
   else
      CMessage::ToLog(DFUN,::GetLastError(),true);
   return false;
  }
 //+------------------------------------------------------------------+
 //| Set the "Object selection" flag                                  |
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetFlagSelected(const bool flag,const bool only_prop)
  {
   ::ResetLastError();
   if((!only_prop && ::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_SELECTED,flag)) || only_prop)
     {
      this.m_selected=flag;
      return true;
     }
   else
      CMessage::ToLog(DFUN,::GetLastError(),true);
   return false;
  }
 //+------------------------------------------------------------------+
 //| Set the "Object availability" flag                               |
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetFlagSelectable(const bool flag,const bool only_prop)
  {
   ::ResetLastError();
   if((!only_prop && ::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_SELECTABLE,flag)) || only_prop)
     {
      this.m_selectable=flag;
      return true;
     }
   else
      CMessage::ToLog(DFUN,::GetLastError(),true);
   return false;
  }
 //+------------------------------------------------------------------+
 //| Set the "Disable displaying the name of a graphical object..."   |
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetFlagHidden(const bool flag,const bool only_prop)
  {
   ::ResetLastError();
   if((!only_prop && ::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_SELECTABLE,flag)) || only_prop)
     {
      this.m_hidden=flag;
      return true;
     }
   else
      CMessage::ToLog(DFUN,::GetLastError(),true);
   return false;
  }
 //+------------------------------------------------------------------+
 //| Set the priority of a graphical object for receiving the event...|
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetZorder(const long value,const bool only_prop)
  {
   ::ResetLastError();
   if((!only_prop && ::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_ZORDER,value)) || only_prop)
     {
      this.m_zorder=value;
      return true;
     }
   else
      CMessage::ToLog(DFUN,::GetLastError(),true);
   return false;
  }
 //+------------------------------------------------------------------+
 //| Set the X coordinate of the upper left corner of the rectangle...|
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetXOffset(const long value)
  {
   ::ResetLastError();
   if(!::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_XOFFSET,value))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the Y coordinate of the upper left corner of the rectangle...|
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetYOffset(const long value)
  {
   ::ResetLastError();
   if(!::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_YOFFSET,value))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the width of OBJ_LABEL (read only), OBJ_BUTTON...            |
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetXSize(const long value)
  {
   ::ResetLastError();
   if(!::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_XSIZE,value))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the height of OBJ_LABEL (read only), OBJ_BUTTON...           |
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetYSize(const long value)
  {
   ::ResetLastError();
   if(!::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_YSIZE,value))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set object visibility on all timeframes                          |
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetVisibleFlag(const bool flag,const bool only_prop)   
  {
   long value=(flag ? OBJ_ALL_PERIODS : OBJ_NO_PERIODS);
   ::ResetLastError();
   if((!only_prop && ::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_TIMEFRAMES,value)) || only_prop)
     {
      this.m_visible=flag;
      return true;
     }
   else
      CMessage::ToLog(DFUN,::GetLastError(),true);
   return false;
  }
 //+------------------------------------------------------------------+
 //| Set visibility flags on timeframes specified as flags            |
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetVisibleOnTimeframes(const int flags,const bool only_prop)
  {
   ::ResetLastError();
   if((!only_prop && ::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_TIMEFRAMES,flags)) || only_prop)
     {
      this.m_timeframes_visible=flags;
      return true;
     }
   else
      CMessage::ToLog(DFUN,::GetLastError(),true);
   return false;
  }
 //+------------------------------------------------------------------+
 //| Add the visibility flag on a specified timeframe                 |
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetVisibleOnTimeframe(const ENUM_TIMEFRAMES timeframe,const bool only_prop)
  {
   int flags=this.m_timeframes_visible;
   switch(timeframe)
     {
      case PERIOD_M1    : flags |= OBJ_PERIOD_M1;  break;
      case PERIOD_M2    : flags |= OBJ_PERIOD_M2;  break;
      case PERIOD_M3    : flags |= OBJ_PERIOD_M3;  break;
      case PERIOD_M4    : flags |= OBJ_PERIOD_M4;  break;
      case PERIOD_M5    : flags |= OBJ_PERIOD_M5;  break;
      case PERIOD_M6    : flags |= OBJ_PERIOD_M6;  break;
      case PERIOD_M10   : flags |= OBJ_PERIOD_M10; break;
      case PERIOD_M12   : flags |= OBJ_PERIOD_M12; break;
      case PERIOD_M15   : flags |= OBJ_PERIOD_M15; break;
      case PERIOD_M20   : flags |= OBJ_PERIOD_M20; break;
      case PERIOD_M30   : flags |= OBJ_PERIOD_M30; break;
      case PERIOD_H1    : flags |= OBJ_PERIOD_H1;  break;
      case PERIOD_H2    : flags |= OBJ_PERIOD_H2;  break;
      case PERIOD_H3    : flags |= OBJ_PERIOD_H3;  break;
      case PERIOD_H4    : flags |= OBJ_PERIOD_H4;  break;
      case PERIOD_H6    : flags |= OBJ_PERIOD_H6;  break;
      case PERIOD_H8    : flags |= OBJ_PERIOD_H8;  break;
      case PERIOD_H12   : flags |= OBJ_PERIOD_H12; break;
      case PERIOD_D1    : flags |= OBJ_PERIOD_D1;  break;
      case PERIOD_W1    : flags |= OBJ_PERIOD_W1;  break;
      case PERIOD_MN1   : flags |= OBJ_PERIOD_MN1; break;
      default           : return true;
     }
   ::ResetLastError();
   if((!only_prop && ::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_TIMEFRAMES,flags)) || only_prop)
     {
      this.m_timeframes_visible=flags;
      return true;
     }
   else
      CMessage::ToLog(DFUN,::GetLastError(),true);
   return false;
  }
 //+------------------------------------------------------------------+
 //| Set a subwindow index                                            |
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetSubwindow(const long chart_id,const string name)
  {
   ::ResetLastError();
   this.m_subwindow=::ObjectFind(chart_id,name);
   if(this.m_subwindow<0)
      CMessage::ToLog(DFUN,MSG_GRAPH_STD_OBJ_ERR_NOT_FIND_SUBWINDOW);
   return(this.m_subwindow>WRONG_VALUE);
  }
 //+------------------------------------------------------------------+
 //| Set a subwindow index                                            |
 //+------------------------------------------------------------------+
 bool CGBaseObj::SetSubwindow(void)
  {
   return this.SetSubwindow(this.m_chart_id,this.m_name);
  }
 //+------------------------------------------------------------------+
 //| Return the description of the graphical object type              |
 //+------------------------------------------------------------------+
 string CGBaseObj::TypeGraphObjectDescription(void)
  {
   if(this.TypeGraphElement()==GRAPH_ELEMENT_TYPE_STANDARD)
      return StdGraphObjectTypeDescription(this.m_type_graph_obj);
   else
      return this.TypeElementDescription();
  }
 //+------------------------------------------------------------------+
 //| Return the description of the graphical element type             |
 //+------------------------------------------------------------------+
 string CGBaseObj::TypeElementDescription(const ENUM_GRAPH_ELEMENT_TYPE type)
  {
   return
     (
      type==GRAPH_ELEMENT_TYPE_STANDARD                  ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_STANDARD)                 :
      type==GRAPH_ELEMENT_TYPE_STANDARD_EXTENDED         ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_STANDARD_EXTENDED)        :
      type==GRAPH_ELEMENT_TYPE_ELEMENT                   ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_ELEMENT)                  :
      type==GRAPH_ELEMENT_TYPE_BITMAP                    ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_BITMAP)                   :
      type==GRAPH_ELEMENT_TYPE_SHADOW_OBJ                ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_SHADOW_OBJ)               :
      type==GRAPH_ELEMENT_TYPE_FORM                      ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_FORM)                     :
      type==GRAPH_ELEMENT_TYPE_WINDOW                    ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WINDOW)                   :
      //--- WinForms
      type==GRAPH_ELEMENT_TYPE_WF_UNDERLAY               ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_UNDERLAY)              :
      type==GRAPH_ELEMENT_TYPE_WF_BASE                   ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_BASE)                  :
      //--- Containers
      type==GRAPH_ELEMENT_TYPE_WF_CONTAINER              ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_CONTAINER)             :
      type==GRAPH_ELEMENT_TYPE_WF_GROUPBOX               ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_GROUPBOX)              :
      type==GRAPH_ELEMENT_TYPE_WF_PANEL                  ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_PANEL)                 :
      type==GRAPH_ELEMENT_TYPE_WF_TAB_CONTROL            ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_TAB_CONTROL)           :
      type==GRAPH_ELEMENT_TYPE_WF_SPLIT_CONTAINER        ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_SPLIT_CONTAINER)       :
      //--- Standard controls
      type==GRAPH_ELEMENT_TYPE_WF_COMMON_BASE            ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_COMMON_BASE)           :
      type==GRAPH_ELEMENT_TYPE_WF_LABEL                  ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_LABEL)                 :
      type==GRAPH_ELEMENT_TYPE_WF_CHECKBOX               ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_CHECKBOX)              :
      type==GRAPH_ELEMENT_TYPE_WF_RADIOBUTTON            ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_RADIOBUTTON)           :
      type==GRAPH_ELEMENT_TYPE_WF_BUTTON                 ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_BUTTON)                :
      type==GRAPH_ELEMENT_TYPE_WF_ELEMENTS_LIST_BOX      ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_ELEMENTS_LIST_BOX)     :
      type==GRAPH_ELEMENT_TYPE_WF_LIST_BOX               ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_LIST_BOX)              :
      type==GRAPH_ELEMENT_TYPE_WF_LIST_BOX_ITEM          ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_LIST_BOX_ITEM)         :
      type==GRAPH_ELEMENT_TYPE_WF_CHECKED_LIST_BOX       ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_CHECKED_LIST_BOX)      :
      type==GRAPH_ELEMENT_TYPE_WF_BUTTON_LIST_BOX        ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_BUTTON_LIST_BOX)       :
      type==GRAPH_ELEMENT_TYPE_WF_TOOLTIP                ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_TOOLTIP)               :
      type==GRAPH_ELEMENT_TYPE_WF_PROGRESS_BAR           ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_PROGRESS_BAR)          :
      //--- Auxiliary control objects
      type==GRAPH_ELEMENT_TYPE_WF_TAB_HEADER             ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_TAB_HEADER)            :
      type==GRAPH_ELEMENT_TYPE_WF_TAB_FIELD              ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_TAB_FIELD)             :
      type==GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON           ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON)          :
      type==GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_UP        ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_UP)       :
      type==GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_DOWN      ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_DOWN)     :
      type==GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_LEFT      ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_LEFT)     :
      type==GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_RIGHT     ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTON_RIGHT)    :
      type==GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTONS_UD_BOX   ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTONS_UD_BOX)  :
      type==GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTONS_LR_BOX   ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_ARROW_BUTTONS_LR_BOX)  :
      type==GRAPH_ELEMENT_TYPE_WF_SPLIT_CONTAINER_PANEL  ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_SPLIT_CONTAINER_PANEL) :
      type==GRAPH_ELEMENT_TYPE_WF_SPLITTER               ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_SPLITTER)              :
      type==GRAPH_ELEMENT_TYPE_WF_HINT_BASE              ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_HINT_BASE)             :
      type==GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_LEFT         ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_LEFT)        :
      type==GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_RIGHT        ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_RIGHT)       :
      type==GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_UP           ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_UP)          :
      type==GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_DOWN         ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_HINT_MOVE_DOWN)        :
      type==GRAPH_ELEMENT_TYPE_WF_BAR_PROGRESS_BAR       ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_BAR_PROGRESS_BAR)      :
      type==GRAPH_ELEMENT_TYPE_WF_GLARE_OBJ              ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_GLARE_OBJ)             :
      type==GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR             ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR)            :
      type==GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR_VERTICAL    ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR_VERTICAL)   :
      type==GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR_HORISONTAL  ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR_HORISONTAL) :
      type==GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR_THUMB       ? CMessage::Text(MSG_GRAPH_ELEMENT_TYPE_WF_SCROLL_BAR_THUMB)      :
      "Unknown"
     );
  }  
 //+------------------------------------------------------------------+
 //| Return the description of the graphical element type             |
 //+------------------------------------------------------------------+
 string CGBaseObj::TypeElementDescription(void)
  {
   return this.TypeElementDescription(this.TypeGraphElement());
  }
 //+------------------------------------------------------------------+
 //| Return the description of the graphical object affiliation       |
 //+------------------------------------------------------------------+
 string CGBaseObj::BelongDescription(void)
  {
   return
     (
      this.Belong()==GRAPH_OBJ_BELONG_PROGRAM      ? CMessage::Text(MSG_GRAPH_OBJ_BELONG_PROGRAM)     :
      this.Belong()==GRAPH_OBJ_BELONG_NO_PROGRAM   ? CMessage::Text(MSG_GRAPH_OBJ_BELONG_NO_PROGRAM)  :
      "Unknown"
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of the graphical object group             |
 //+------------------------------------------------------------------+
 string CGBaseObj::SpeciesDescription(void)
  {
   return
     (
      this.Species()==GRAPH_OBJ_SPECIES_LINES      ?  CMessage::Text(MSG_GRAPH_OBJ_PROP_SPECIES_LINES)      :
      this.Species()==GRAPH_OBJ_SPECIES_CHANNELS   ?  CMessage::Text(MSG_GRAPH_OBJ_PROP_SPECIES_CHANNELS)   :
      this.Species()==GRAPH_OBJ_SPECIES_GANN       ?  CMessage::Text(MSG_GRAPH_OBJ_PROP_SPECIES_GANN)       :
      this.Species()==GRAPH_OBJ_SPECIES_FIBO       ?  CMessage::Text(MSG_GRAPH_OBJ_PROP_SPECIES_FIBO)       :
      this.Species()==GRAPH_OBJ_SPECIES_ELLIOTT    ?  CMessage::Text(MSG_GRAPH_OBJ_PROP_SPECIES_ELLIOTT)    :
      this.Species()==GRAPH_OBJ_SPECIES_SHAPES     ?  CMessage::Text(MSG_GRAPH_OBJ_PROP_SPECIES_SHAPES)     :
      this.Species()==GRAPH_OBJ_SPECIES_ARROWS     ?  CMessage::Text(MSG_GRAPH_OBJ_PROP_SPECIES_ARROWS)     :
      this.Species()==GRAPH_OBJ_SPECIES_GRAPHICAL  ?  CMessage::Text(MSG_GRAPH_OBJ_PROP_SPECIES_GRAPHICAL)  :
      "Unknown"
     );
  }
//+------------------------------------------------------------------+
#endif // CGBASEEVENT_MQH_IMPLEMENTATION
#endif // CGBASEEVENT_MQH
