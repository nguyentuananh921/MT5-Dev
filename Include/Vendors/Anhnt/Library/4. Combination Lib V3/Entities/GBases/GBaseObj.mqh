//+------------------------------------------------------------------+
//|                                                     GBaseObj.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                             https://mql5.com/en/users/artmedia70 |
//|Link                        https://www.mql5.com/en/articles/9493 |
//|Link                        https://www.mql5.com/en/articles/9553 |
//|Link                        https://www.mql5.com/en/articles/9902 |
//|Link                      https://www.mql5.com/en/articles/10237  |
//|Link                      https://www.mql5.com/en/articles/10331  |
//|Link                      https://www.mql5.com/en/articles/10663  |
//|Link                      https://www.mql5.com/en/articles/11121  |
//|Link                      https://www.mql5.com/en/articles/11194  |
//|Link                      https://www.mql5.com/en/articles/11260  |
//|Link                      https://www.mql5.com/en/articles/11228  |
//|Link TabcontrolUpdate     https://www.mql5.com/en/articles/11316  |
//|Lib https://www.mql5.com/en/articles/14710                        |
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
 #include "..\Defines\GraphDefines.mqh"
 #include "..\..\Services\DELib\GraphicDELib.mqh"
 #include "..\Bases\EventBaseObj.mqh"
 #include "..\..\Services\Message\Message.mqh"
 #include "..\Bases\BaseObj.mqh"
#ifndef CGBASEEVENT_MQH_DECLARATION
#define CGBASEEVENT_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Class of the base object of the library graphical objects        |
//+------------------------------------------------------------------+
class CGBaseObj : public CBaseObj
 {
  private:
  protected:
    CArrayObj                         m_list_events;                      // Object event list
    ENUM_OBJECT                       m_type_graph_obj;                   // Graphical object type
    ENUM_GRAPH_ELEMENT_TYPE           m_type_element;                   // Graphical element type
    string                            m_name_prefix;                      // Object name prefix
    long                              m_chart_id;                         // Object chart ID
    long                              m_object_id;                        // Object ID
    long                              m_zorder;                           // Priority of a graphical object for receiving the mouse click event
    int                               m_subwindow;                        // Subwindow index
    int                               m_shift_y;                          // Y coordinate shift for the subwindow
    int                               m_timeframes_visible;               // Visibility of an object on timeframes (a set of flags)
    int                               m_digits;                           // Number of decimal places in a quote
   //|Link                      https://www.mql5.com/en/articles/11194  |
    int                               m_group;                            // Graphical object group    
    bool                              m_visible;                          // Object visibility
    bool                              m_back;                             // "Background object" flag
    bool                              m_selected;                         // "Object selection" flag
    bool                              m_selectable;                       // "Object availability" flag
    bool                              m_hidden;                           // "Disable displaying the name of a graphical object in the terminal object list" flag
    datetime                          m_create_time;                      // Object creation time
    CGBaseObj                        *m_parent;
    CArrayObj                         m_list_children;
   //--- Create (1) the object structure and (2) the object from the structure
    virtual bool                      ObjectToStruct(void)                      { return true; }
    virtual void                      StructToObject(void)                      {;}

   //--- Return the list of object events
    CArrayObj                        *GetListEvents(void)                       { return &this.m_list_events;          }
   //--- Create a new object event
    CEventBaseObj                    *CreateNewEvent(const ushort event_id,const long lparam,const double dparam,const string sparam) { return new CEventBaseObj(event_id,lparam,dparam,sparam); }
   //--- Create a new object event and add it to the event list
    bool                              CreateAndAddNewEvent(const ushort event_id,const long lparam,const double dparam,const string sparam) { return this.AddEvent(new CEventBaseObj(event_id,lparam,dparam,sparam)); }
   //--- Add an event object to the event list
    bool                              AddEvent(CEventBaseObj *event)            { return this.m_list_events.Add(event);}
   //--- Clear the event list
    void                              ClearEventsList(void)                     { this.m_list_events.Clear();          }
   //--- Return the number of events in the list
    int                               EventsTotal(void)                         { return this.m_list_events.Total();   }

  public:
   //--- Constructor/destructor
                      CGBaseObj();
                      ~CGBaseObj(){;}

   //--- Containment: the object this one lives in, and the objects living in it
    CGBaseObj                        *Parent(void)                        const { return this.m_parent;                }
    int                               ChildrenTotal(void)                 const { return this.m_list_children.Total(); }
    CGBaseObj                        *Child(const int index);
    virtual bool                      AddChild(CGBaseObj *child);
    bool                              DeleteChild(CGBaseObj *child);

   //--- Life cycle hooks, empty here: CGElement and CGStdBaseObj override them, a collection calls them through CGBaseObj
    virtual void                      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam) { }
    virtual void                      OnTimerEvent(void)                                                                     { }
    virtual void                      SetCovered(const bool covered)                                                         { }   // a window covers the cursor, set by the collection

   //--- Return the prefix name
    string                            NamePrefix(void)                    const { return this.m_name_prefix;           }
   //--- Set the values of the class variables
    void                              SetObjectID(const long value)             { this.m_object_id=value;              }
    void                              SetTypeGraphObject(const ENUM_OBJECT obj) { this.m_type_graph_obj=obj;           }
    void                              SetTypeElement(const ENUM_GRAPH_ELEMENT_TYPE type) { this.m_type_element=type;   }
   //|Link                      https://www.mql5.com/en/articles/11194  |
    virtual void                      SetGroup(const int value)                 { this.m_group=value;                  }
    
    void                              SetName(const string name)                { this.m_name=name;                    }
    void                              SetDigits(const int value)                { this.m_digits=value;                 }
    void                              SetChartID(const long chart_id)           { this.m_chart_id=(chart_id==NULL || chart_id==0 ? ::ChartID() : chart_id); }
    
   //--- Set the properties
    bool                              SetFlagBack(const bool flag,const bool only_prop);
    bool                              SetFlagSelected(const bool flag,const bool only_prop);
    bool                              SetFlagSelectable(const bool flag,const bool only_prop);
    bool                              SetFlagHidden(const bool flag,const bool only_prop);
    virtual bool                      SetZorder(const long value,const bool only_prop);
    virtual bool                      SetXOffset(const long value);
    virtual bool                      SetYOffset(const long value);
    virtual bool                      SetXSize(const long value);
    virtual bool                      SetYSize(const long value);
    bool                              SetVisibleFlag(const bool flag,const bool only_prop);
    bool                              SetVisibleOnTimeframes(const int flags,const bool only_prop);
    bool                              SetVisibleOnTimeframe(const ENUM_TIMEFRAMES timeframe,const bool only_prop);
    bool                              SetSubwindow(const long chart_id,const string name);
    bool                              SetSubwindow(void);

   //--- Return the values of class variables
    virtual int                       XOffset(void)                       const { return (int)::ObjectGetInteger(this.m_chart_id,this.m_name,OBJPROP_XOFFSET); }
    virtual int                       YOffset(void)                       const { return (int)::ObjectGetInteger(this.m_chart_id,this.m_name,OBJPROP_YOFFSET); }
    virtual int                       XSize(void)                         const { return (int)::ObjectGetInteger(this.m_chart_id,this.m_name,OBJPROP_XSIZE);   }
    virtual int                       YSize(void)                         const { return (int)::ObjectGetInteger(this.m_chart_id,this.m_name,OBJPROP_YSIZE);   }
    ENUM_GRAPH_ELEMENT_TYPE           TypeGraphElement(void)              const { return this.m_type_element;       }
    ENUM_OBJECT                       TypeGraphObject(void)               const { return this.m_type_graph_obj;     }
    datetime                          TimeCreate(void)                    const { return this.m_create_time;        }
    string                            Name(void)                          const { return this.m_name;               }
    long                              ChartID(void)                       const { return this.m_chart_id;           }
    long                              ObjectID(void)                      const { return this.m_object_id;          }
    virtual long                      Zorder(void)                        const { return this.m_zorder;             }
    int                               SubWindow(void)                     const { return this.m_subwindow;          }
    int                               ShiftY(void)                        const { return this.m_shift_y;            }
    int                               VisibleOnTimeframes(void)           const { return this.m_timeframes_visible; }
    int                               Digits(void)                        const { return this.m_digits;             }
    virtual int                       Group(void)                         const { return this.m_group;              }
    bool                              IsBack(void)                        const { return this.m_back;               }
    bool                              IsSelected(void)                    const { return this.m_selected;           }
    bool                              IsSelectable(void)                  const { return this.m_selectable;         }
    bool                              IsHidden(void)                      const { return this.m_hidden;             }
    bool                              IsVisible(void)                     const { return this.m_visible;            }

   //--- Return the graphical object type (ENUM_OBJECT) calculated from the object type (ENUM_OBJECT_DE_TYPE) passed to the method
    ENUM_OBJECT                       GraphObjectType(const ENUM_OBJECT_DE_TYPE obj_type) const { return ENUM_OBJECT(obj_type-OBJECT_DE_TYPE_GSTD_OBJ-1); }
    
  };
#endif // CGBASEEVENT_MQH_DECLARATION
#ifndef CGBASEEVENT_MQH_IMPLEMENTATION
#define CGBASEEVENT_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CGBaseObj::CGBaseObj() : m_name_prefix(::MQLInfoString(MQL_PROGRAM_NAME)+"_"),m_parent(NULL)
  {
   this.m_list_children.FreeMode(true);          // Deletes only children created with new
   this.m_list_events.Clear();                  // Clear the event list
   this.m_list_events.Sort();                   // Sorted list flag
   this.m_type=OBJECT_DE_TYPE_GBASE;            // Object type
   this.m_type_graph_obj=WRONG_VALUE;           // Graphical object type
   this.m_type_element=WRONG_VALUE;             // Graphical object type
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
//| Return the child at the index                                    |
//+------------------------------------------------------------------+
CGBaseObj *CGBaseObj::Child(const int index)
  {
   return dynamic_cast<CGBaseObj *>(this.m_list_children.At(index));
  }
//+------------------------------------------------------------------+
//| Put a child into this object and make this its parent            |
//+------------------------------------------------------------------+
bool CGBaseObj::AddChild(CGBaseObj *child)
  {
   if(::CheckPointer(child)==POINTER_INVALID || child==::GetPointer(this))
      return false;
   for(int i=0; i<this.m_list_children.Total(); i++)
      if(this.m_list_children.At(i)==child)
         return true;
   if(!this.m_list_children.Add(child))
      return false;
   child.m_parent=::GetPointer(this);
   return true;
  }
//+------------------------------------------------------------------+
//| Take a child out of this object without destroying it            |
//+------------------------------------------------------------------+
bool CGBaseObj::DeleteChild(CGBaseObj *child)
  {
   for(int i=0; i<this.m_list_children.Total(); i++)
     {
      if(this.m_list_children.At(i)!=child)
         continue;
      this.m_list_children.Detach(i);
      child.m_parent=NULL;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
#endif // CGBASEEVENT_MQH_IMPLEMENTATION
#endif // CGBASEEVENT_MQH
