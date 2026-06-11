//+------------------------------------------------------------------+
//|                                          ChartObjectsControl.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef CCHARTOBJECTSCONTROL_MQH
#define CCHARTOBJECTSCONTROL_MQH
#ifndef CCHARTOBJECTSCONTROL_MQH_DECLARATION
#define CCHARTOBJECTSCONTROL_MQH_DECLARATION
#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
 //+------------------------------------------------------------------+
 //| Chart object management class                                    |
 //+------------------------------------------------------------------+
 class CChartObjectsControl : public CObject
  {
   private:
    CArrayObj         m_list_new_graph_obj;      // List of added graphical objects
    ENUM_TIMEFRAMES   m_chart_timeframe;         // Chart timeframe
    long              m_chart_id;                // Chart ID
    long              m_chart_id_main;           // Control program chart ID
    string            m_chart_symbol;            // Chart symbol
    bool              m_is_graph_obj_event;      // Event flag in the list of graphical objects
    int               m_total_objects;           // Number of graphical objects
    int               m_last_objects;            // Number of graphical objects during the previous check
    int               m_delta_graph_obj;         // Difference in the number of graphical objects compared to the previous check
    int               m_handle_ind;              // Event controller indicator handle
    string            m_name_ind;                // Short name of the event controller indicator
    string            m_name_program;            // Program name    
    //--- Return the name of the last graphical object added to the chart
     string            LastAddedGraphObjName(void);
    //--- Set the permission to track mouse events and graphical objects
     void              SetMouseEvent(void);
   public:
    //--- Return the variable values
      ENUM_TIMEFRAMES   Timeframe(void)                           const { return this.m_chart_timeframe;    }
      long              ChartID(void)                             const { return this.m_chart_id;           }
      string            Symbol(void)                              const { return this.m_chart_symbol;       }
      bool              IsEvent(void)                             const { return this.m_is_graph_obj_event; }
      int               TotalObjects(void)                        const { return this.m_total_objects;      }
      int               Delta(void)                               const { return this.m_delta_graph_obj;    }
    //--- Set the flags of scrolling the chart with the mouse, context menu and crosshairs tool for the chart
      void              SetChartTools(const bool flag);
      void              SetChartTools(const bool mouse_scroll,const bool context_menu,const bool crosshair_tool);
    //--- Create a new standard (or extended) graphical object
      CGStdGraphObj    *CreateNewGraphObj(const ENUM_OBJECT obj_type,const string name,const bool extended);
    //--- Return the list of newly added objects
      CArrayObj        *GetListNewAddedObj(void)                        { return &this.m_list_new_graph_obj;}
    //--- Create the event control indicator
      bool              CreateEventControlInd(const long chart_id_main);
    //--- Add the event control indicator to the chart
      bool              AddEventControlInd(void);
    //--- Check the chart objects
      void              Refresh(void);
    //--- Constructors
      CChartObjectsControl(void)
                       { 
                        this.m_name_program=::MQLInfoString(MQL_PROGRAM_NAME);
                        this.m_chart_id=::ChartID();
                        this.m_chart_timeframe=(ENUM_TIMEFRAMES)::ChartPeriod(this.m_chart_id);
                        this.m_chart_symbol=::ChartSymbol(this.m_chart_id);
                        this.m_chart_id_main=::ChartID();
                        this.m_list_new_graph_obj.Clear();
                        this.m_list_new_graph_obj.Sort();
                        this.m_is_graph_obj_event=false;
                        this.m_total_objects=0;
                        this.m_last_objects=0;
                        this.m_delta_graph_obj=0;
                        this.m_name_ind="";
                        this.m_handle_ind=INVALID_HANDLE;
                        this.SetMouseEvent();
                       }
                     CChartObjectsControl(const long chart_id)
                       { 
                        this.m_name_program=::MQLInfoString(MQL_PROGRAM_NAME);
                        this.m_chart_timeframe=(ENUM_TIMEFRAMES)::ChartPeriod(chart_id);
                        this.m_chart_symbol=::ChartSymbol(chart_id);
                        this.m_chart_id_main=::ChartID();
                        this.m_list_new_graph_obj.Clear();
                        this.m_list_new_graph_obj.Sort();
                        this.m_chart_id=chart_id;
                        this.m_is_graph_obj_event=false;
                        this.m_total_objects=0;
                        this.m_last_objects=0;
                        this.m_delta_graph_obj=0;
                        this.m_name_ind="";
                        this.m_handle_ind=INVALID_HANDLE;
                        this.SetMouseEvent();
                       }
    //--- Destructor
                     ~CChartObjectsControl()
                       {
                        ::ChartIndicatorDelete(this.ChartID(),0,this.m_name_ind);
                        ::IndicatorRelease(this.m_handle_ind);
                       }
                     
    //--- Compare CChartObjectsControl objects by a chart ID (for sorting the list by an object property)
      virtual int       Compare(const CObject *node,const int mode=0) const
                       {
                        const CChartObjectsControl *obj_compared=node;
                        return(this.ChartID()>obj_compared.ChartID() ? 1 : this.ChartID()<obj_compared.ChartID() ? -1 : 0);
                       }

     //--- Event handler
      void              OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);

  };
#endif // CCHARTOBJECTSCONTROL_MQH_DECLARATION
#ifndef CCHARTOBJECTSCONTROL_MQH_IMPLEMENTATION
#define CCHARTOBJECTSCONTROL_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| CChartObjectsControl: Set the permission for a chart             |
 //| to track mouse and graphical object events for the chart         |
 //+------------------------------------------------------------------+
 void CChartObjectsControl::SetMouseEvent(void)
  {
   ::ChartSetInteger(this.ChartID(),CHART_EVENT_MOUSE_MOVE,true);
   ::ChartSetInteger(this.ChartID(),CHART_EVENT_MOUSE_WHEEL,true);
   ::ChartSetInteger(this.ChartID(),CHART_EVENT_OBJECT_CREATE,true);
   ::ChartSetInteger(this.ChartID(),CHART_EVENT_OBJECT_DELETE,true);
  }
 //+----------------------------------------------------------------------+
 //| CChartObjectsControl: Set the flags of                               |
 //| mouse wheel scrolling, context menu and crosshair tool for the chart |
 //+----------------------------------------------------------------------+
 void CChartObjectsControl::SetChartTools(const bool flag)
  {
   ::ChartSetInteger(this.ChartID(),CHART_MOUSE_SCROLL,flag);
   ::ChartSetInteger(this.ChartID(),CHART_CONTEXT_MENU,flag);
   ::ChartSetInteger(this.ChartID(),CHART_CROSSHAIR_TOOL,flag);
  }
 //+----------------------------------------------------------------------+
 //| CChartObjectsControl: Set the flags of                               |
 //| mouse wheel scrolling, context menu and crosshair tool for the chart |
 //+----------------------------------------------------------------------+
 void CChartObjectsControl::SetChartTools(const bool mouse_scroll,const bool context_menu,const bool crosshair_tool)
  {
   ::ChartSetInteger(this.ChartID(),CHART_MOUSE_SCROLL,mouse_scroll);
   ::ChartSetInteger(this.ChartID(),CHART_CONTEXT_MENU,context_menu);
   ::ChartSetInteger(this.ChartID(),CHART_CROSSHAIR_TOOL,crosshair_tool);
  }
 //+------------------------------------------------------------------+
 //| CChartObjectsControl: Check objects on a chart                   |
 //+------------------------------------------------------------------+
 void CChartObjectsControl::Refresh(void)
  {
    //--- Clear the list of newly added objects
      this.m_list_new_graph_obj.Clear();
    //--- Calculate the number of new objects on the chart
      this.m_total_objects=::ObjectsTotal(this.ChartID());
      this.m_delta_graph_obj=this.m_total_objects-this.m_last_objects;
      //--- If an object is added to the chart
      if(this.m_delta_graph_obj>0)
        {
          //--- Create the list of added graphical objects
          for(int i=0;i<this.m_delta_graph_obj;i++)
            {
            //--- Get the name of the last added object (if a single new object is added),
            //--- or a name from the terminal object list by index (if several objects have been added)
            string name=(this.m_delta_graph_obj==1 ? this.LastAddedGraphObjName() : ::ObjectName(this.m_chart_id,i));
            //--- Handle only non-programmatically created objects
            if(name==NULL || ::StringFind(name,this.m_name_program)>WRONG_VALUE)
                continue;
            //--- Create the object of the graphical object class corresponding to the added graphical object type
            ENUM_OBJECT type=(ENUM_OBJECT)::ObjectGetInteger(this.ChartID(),name,OBJPROP_TYPE);
            ENUM_OBJECT_DE_TYPE obj_type=ENUM_OBJECT_DE_TYPE(type+OBJECT_DE_TYPE_GSTD_OBJ+1);
            CGStdGraphObj *obj=this.CreateNewGraphObj(type,name,false);
            //--- If failed to create an object, inform of that and move on to the new iteration
            if(obj==NULL)
              {
                CMessage::ToLog(DFUN,MSG_GRAPH_STD_OBJ_ERR_FAILED_CREATE_CLASS_OBJ);
                continue;
              }
            //--- Set the object affiliation and add the created object to the list of new objects
            obj.SetBelong(GRAPH_OBJ_BELONG_NO_PROGRAM); 
            //--- If failed to add the object to the list, inform of that, remove the object and move on to the next iteration
            if(!this.m_list_new_graph_obj.Add(obj))
              {
                CMessage::ToLog(DFUN_ERR_LINE,MSG_LIB_SYS_FAILED_OBJ_ADD_TO_LIST);
                delete obj;
                continue;
              }
            }
          //--- Send events to the control program chart from the created list
          for(int i=0;i<this.m_list_new_graph_obj.Total();i++)
            {
            CGStdGraphObj *obj=this.m_list_new_graph_obj.At(i);
            if(obj==NULL)
                continue;
            //--- Send an event to the control program chart
            ::EventChartCustom(this.m_chart_id_main,GRAPH_OBJ_EVENT_CREATE,this.ChartID(),obj.TimeCreate(),obj.Name());
            }
        }
    //--- save the index of the last added graphical object and the difference with the last check
      this.m_last_objects=this.m_total_objects;
      this.m_is_graph_obj_event=(bool)this.m_delta_graph_obj;
  }
 //+------------------------------------------------------------------+
 //| CChartObjectsControl:                                            |
 //| Create a new standard graphical object                           |
 //+------------------------------------------------------------------+
 CGStdGraphObj *CChartObjectsControl::CreateNewGraphObj(const ENUM_OBJECT obj_type,const string name,const bool extended)
  {
   switch((int)obj_type)
     {
      //--- Lines
      case OBJ_VLINE             : return new CGStdVLineObj(this.ChartID(),name,extended);
      case OBJ_HLINE             : return new CGStdHLineObj(this.ChartID(),name,extended);
      case OBJ_TREND             : return new CGStdTrendObj(this.ChartID(),name,extended);
      case OBJ_TRENDBYANGLE      : return new CGStdTrendByAngleObj(this.ChartID(),name,extended);
      case OBJ_CYCLES            : return new CGStdCyclesObj(this.ChartID(),name,extended);
      case OBJ_ARROWED_LINE      : return new CGStdArrowedLineObj(this.ChartID(),name,extended);
      //--- Channels
      case OBJ_CHANNEL           : return new CGStdChannelObj(this.ChartID(),name,extended);
      case OBJ_STDDEVCHANNEL     : return new CGStdStdDevChannelObj(this.ChartID(),name,extended);
      case OBJ_REGRESSION        : return new CGStdRegressionObj(this.ChartID(),name,extended);
      case OBJ_PITCHFORK         : return new CGStdPitchforkObj(this.ChartID(),name,extended);
      //--- Gann
      case OBJ_GANNLINE          : return new CGStdGannLineObj(this.ChartID(),name,extended);
      case OBJ_GANNFAN           : return new CGStdGannFanObj(this.ChartID(),name,extended);
      case OBJ_GANNGRID          : return new CGStdGannGridObj(this.ChartID(),name,extended);
      //--- Fibo
      case OBJ_FIBO              : return new CGStdFiboObj(this.ChartID(),name,extended);
      case OBJ_FIBOTIMES         : return new CGStdFiboTimesObj(this.ChartID(),name,extended);
      case OBJ_FIBOFAN           : return new CGStdFiboFanObj(this.ChartID(),name,extended);
      case OBJ_FIBOARC           : return new CGStdFiboArcObj(this.ChartID(),name,extended);
      case OBJ_FIBOCHANNEL       : return new CGStdFiboChannelObj(this.ChartID(),name,extended);
      case OBJ_EXPANSION         : return new CGStdExpansionObj(this.ChartID(),name,extended);
      //--- Elliott
      case OBJ_ELLIOTWAVE5       : return new CGStdElliotWave5Obj(this.ChartID(),name,extended);
      case OBJ_ELLIOTWAVE3       : return new CGStdElliotWave3Obj(this.ChartID(),name,extended);
      //--- Shapes
      case OBJ_RECTANGLE         : return new CGStdRectangleObj(this.ChartID(),name,extended);
      case OBJ_TRIANGLE          : return new CGStdTriangleObj(this.ChartID(),name,extended);
      case OBJ_ELLIPSE           : return new CGStdEllipseObj(this.ChartID(),name,extended);
      //--- Arrows
      case OBJ_ARROW_THUMB_UP    : return new CGStdArrowThumbUpObj(this.ChartID(),name,extended);
      case OBJ_ARROW_THUMB_DOWN  : return new CGStdArrowThumbDownObj(this.ChartID(),name,extended);
      case OBJ_ARROW_UP          : return new CGStdArrowUpObj(this.ChartID(),name,extended);
      case OBJ_ARROW_DOWN        : return new CGStdArrowDownObj(this.ChartID(),name,extended);
      case OBJ_ARROW_STOP        : return new CGStdArrowStopObj(this.ChartID(),name,extended);
      case OBJ_ARROW_CHECK       : return new CGStdArrowCheckObj(this.ChartID(),name,extended);
      case OBJ_ARROW_LEFT_PRICE  : return new CGStdArrowLeftPriceObj(this.ChartID(),name,extended);
      case OBJ_ARROW_RIGHT_PRICE : return new CGStdArrowRightPriceObj(this.ChartID(),name,extended);
      case OBJ_ARROW_BUY         : return new CGStdArrowBuyObj(this.ChartID(),name,extended);
      case OBJ_ARROW_SELL        : return new CGStdArrowSellObj(this.ChartID(),name,extended);
      case OBJ_ARROW             : return new CGStdArrowObj(this.ChartID(),name,extended);
      //--- Graphical objects
      case OBJ_TEXT              : return new CGStdTextObj(this.ChartID(),name,extended);
      case OBJ_LABEL             : return new CGStdLabelObj(this.ChartID(),name,extended);
      case OBJ_BUTTON            : return new CGStdButtonObj(this.ChartID(),name,extended);
      case OBJ_CHART             : return new CGStdChartObj(this.ChartID(),name,extended);
      case OBJ_BITMAP            : return new CGStdBitmapObj(this.ChartID(),name,extended);
      case OBJ_BITMAP_LABEL      : return new CGStdBitmapLabelObj(this.ChartID(),name,extended);
      case OBJ_EDIT              : return new CGStdEditObj(this.ChartID(),name,extended);
      case OBJ_EVENT             : return new CGStdEventObj(this.ChartID(),name,extended);
      case OBJ_RECTANGLE_LABEL   : return new CGStdRectangleLabelObj(this.ChartID(),name,extended);
      default                    : return NULL;
     }
  }
 //+------------------------------------------------------------------+
 //| CChartObjectsControl:                                            |
 //| Return the name of the last graphical object                     |
 //| added to the chart (the object becomes selected)                  |
 //+------------------------------------------------------------------+
 string CChartObjectsControl::LastAddedGraphObjName(void)
  {
   int index=0;
   datetime time=0;
   for(int i=0;i<this.m_total_objects;i++)
     {
      string name=::ObjectName(this.ChartID(),i);
      datetime tm=(datetime)::ObjectGetInteger(this.ChartID(),name,OBJPROP_CREATETIME);
      if(tm>time)
        {
         time=tm;
         index=i;
        }
     }
   return ::ObjectName(this.ChartID(),index);
  }
 //+------------------------------------------------------------------+
 //| CChartObjectsControl: Create the event control indicator         |
 //+------------------------------------------------------------------+
 bool CChartObjectsControl::CreateEventControlInd(const long chart_id_main)
  {
    //--- If the symbol is not on the server, return 'false'
      bool is_custom=false;
      if(!::SymbolExist(this.Symbol(), is_custom))
        {
          CMessage::ToLog(DFUN+" "+this.Symbol()+": ",MSG_LIB_SYS_NOT_SYMBOL_ON_SERVER);
          return false;
        }
    //--- Create the indicator
      this.m_chart_id_main=chart_id_main;
      string name="::"+PATH_TO_EVENT_CTRL_IND;
      ::ResetLastError();
      this.m_handle_ind=::iCustom(this.Symbol(),this.Timeframe(),name,this.ChartID(),this.m_chart_id_main);
      if(this.m_handle_ind==INVALID_HANDLE)
        {
          CMessage::ToLog(DFUN,MSG_GRAPH_OBJ_FAILED_CREATE_EVN_CTRL_INDICATOR);
          CMessage::ToLog(DFUN,::GetLastError(),true);
          return false;
        }
      
      this.m_name_ind="EventSend_From#"+(string)this.ChartID()+"_To#"+(string)this.m_chart_id_main;
      ::Print
        (
          DFUN,this.Symbol()," ",TimeframeDescription(this.Timeframe()),": ",
          CMessage::Text(MSG_GRAPH_OBJ_CREATE_EVN_CTRL_INDICATOR)," \"",this.m_name_ind,"\""
        );
      return true;
  }
 //+------------------------------------------------------------------+
 //|CChartObjectsControl: Add the event control indicator to the chart|
 //+------------------------------------------------------------------+
 bool CChartObjectsControl::AddEventControlInd(void)
  {
    if(this.m_handle_ind==INVALID_HANDLE)
      return false;
    ::ResetLastError();
    string shortname="EventSend_From#"+(string)this.ChartID()+"_To#"+(string)this.m_chart_id_main;
    int total=::ChartIndicatorsTotal(this.ChartID(),0);
    for(int i=0;i<total;i++)
      if(::ChartIndicatorName(this.ChartID(),0,i)==shortname)
        {
         CMessage::ToLog(DFUN,MSG_GRAPH_OBJ_ALREADY_EXIST_EVN_CTRL_INDICATOR);
         return true;
        }
   return ::ChartIndicatorAdd(this.ChartID(),0,this.m_handle_ind);
  }
 //+------------------------------------------------------------------+
#endif // CCHARTOBJECTSCONTROL_MQH_IMPLEMENTATION
#endif // CCHARTOBJECTSCONTROL_MQH



