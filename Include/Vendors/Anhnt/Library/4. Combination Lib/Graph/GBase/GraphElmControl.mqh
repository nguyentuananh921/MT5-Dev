//+------------------------------------------------------------------+
//|                                              GraphElmControl.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                             https://mql5.com/en/users/artmedia70 |
//|Link                        https://www.mql5.com/en/articles/9751 |
//| Lib https://www.mql5.com/en/articles/14710                       |

//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef __GRAPHELMCONTROL_MQH__
#define __GRAPHELMCONTROL_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include <Arrays\ArrayObj.mqh>
 //#include "..\..\Services\DELib.mqh"
 #include "..\Form.mqh"
#ifndef CGRAPHELMCONTROL_MQH_DECLARATION
#define CGRAPHELMCONTROL_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Class for managing graphical elements                            |
  //+------------------------------------------------------------------+
  class CGraphElmControl : public CObject
   {
    private:
      int               m_type;                          // Object type
      int               m_type_node;                     // Type of the object the graphics is constructed for
    //--- Set general parameters for standard graphical objects
      void              SetCommonParamsStdGraphObj(const long chart_id,const string name);
    public:
    //--- Return itself
      CGraphElmControl *GetObject(void)                  { return &this;               }
    //--- Set a type of the object the graphics is constructed for
      void              SetTypeNode(const int type_node) { this.m_type_node=type_node; }
      
    //--- Create a form object
      CForm            *CreateForm(const int form_id,const long chart_id,const int wnd,const string name,const int x,const int y,const int w,const int h);
      CForm            *CreateForm(const int form_id,const int wnd,const string name,const int x,const int y,const int w,const int h);
      CForm            *CreateForm(const int form_id,const string name,const int x,const int y,const int w,const int h);

    //--- Create Bitmap object
      CGCnvBitmap      *CreateBitmap(const int obj_id,const long chart_id,const int wnd,const string name,const datetime time,const double price,const int w,const int h,const color clr);
      
    //--- Creates the trend line standard graphical object
      bool              CreateTrendLine(const long chart_id,const string name,const int subwindow,
                                        const datetime time1,const double price1,
                                        const datetime time2,const double price2,
                                        color clr,int width=1,ENUM_LINE_STYLE style=STYLE_SOLID);
      bool              CreateTrendLine(const string name,const int subwindow,
                                        const datetime time1,const double price1,
                                        const datetime time2,const double price2,
                                        color clr,int width=1,ENUM_LINE_STYLE style=STYLE_SOLID);
      bool              CreateTrendLine(const string name,
                                        const datetime time1,const double price1,
                                        const datetime time2,const double price2,
                                        color clr,int width=1,ENUM_LINE_STYLE style=STYLE_SOLID);

    //--- Create the arrow standard graphical object
      bool              CreateArrow(const long chart_id,const string name,const int subwindow,
                                    const datetime time1,const double price1,
                                    color clr,uchar arrow_code,int width=1);
      bool              CreateArrow(const string name,const int subwindow,
                                    const datetime time1,const double price1,
                                    color clr,uchar arrow_code,int width=1);
      bool              CreateArrow(const string name,
                                    const datetime time1,const double price1,
                                    color clr,uchar arrow_code,int width=1);

    //--- Constructors
                        CGraphElmControl(){ this.m_type=OBJECT_DE_TYPE_GELEMENT_CONTROL; }
                        CGraphElmControl(int type_node);
   };
 #endif // CGRAPHELMCONTROL_MQH_DECLARATION
 #ifndef CGRAPHELMCONTROL_MQH_IMPLEMENTATION
 #define CGRAPHELMCONTROL_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CGraphElmControl::CGraphElmControl(int type_node)
   {
      this.m_type=OBJECT_DE_TYPE_GELEMENT_CONTROL; 
      this.m_type_node=m_type_node;
   }
  //+-----------------------------------------------------------------------+
  //| Create the form object on a specified chart in a specified subwindow  |
  //+-----------------------------------------------------------------------+
  CForm *CGraphElmControl::CreateForm(const int form_id,const long chart_id,const int wnd,const string name,const int x,const int y,const int w,const int h)
   {
      CForm *form=new CForm(NULL,NULL,chart_id,wnd,name,x,y,w,h);
      if(form==NULL)
         return NULL;
      form.SetID(form_id);
      form.SetNumber(0);
      return form;
   }
  //+-----------------------------------------------------------------------+
  //| Create the form object on the current chart in a specified subwindow  |
  //+-----------------------------------------------------------------------+
  CForm *CGraphElmControl::CreateForm(const int form_id,const int wnd,const string name,const int x,const int y,const int w,const int h)
   {
   return this.CreateForm(form_id,::ChartID(),wnd,name,x,y,w,h);
   }
  //+-----------------------------------------------------------------------+
  //| Create the form object on the current chart in the chart main window  |
  //+-----------------------------------------------------------------------+
  CForm *CGraphElmControl::CreateForm(const int form_id,const string name,const int x,const int y,const int w,const int h)
   {
      return this.CreateForm(form_id,::ChartID(),0,name,x,y,w,h);
   }
  //+------------------------------------------------------------------+
  //| Create Bitmap object                                             |
  //+------------------------------------------------------------------+
  CGCnvBitmap *CGraphElmControl::CreateBitmap(const int obj_id,const long chart_id,const int wnd,const string name,const datetime time,const double price,const int w,const int h,const color clr)
   {
      CGCnvBitmap *obj=new CGCnvBitmap(GRAPH_ELEMENT_TYPE_BITMAP,NULL,NULL,obj_id,0,chart_id,wnd,name,time,price,w,h,clr,200);
      return obj;
   }
  //+------------------------------------------------------------------+
  //|Set general parameters for standard graphical objects             |
  //+------------------------------------------------------------------+
  void CGraphElmControl::SetCommonParamsStdGraphObj(const long chart_id,const string name)
   {
      ::ObjectSetInteger(chart_id,name,OBJPROP_HIDDEN,true);
      ::ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,false);
      ::ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);
      ::ObjectSetInteger(chart_id,name,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   }
  //+------------------------------------------------------------------+
  //| Create the trend line standard graphical object                  |
  //| on a specified chart in a specified subwindow                    |
  //+------------------------------------------------------------------+
  bool CGraphElmControl::CreateTrendLine(const long chart_id,const string name,const int subwindow,
                                         const datetime time1,const double price1,
                                         const datetime time2,const double price2,
                                         color clr,int width=1,ENUM_LINE_STYLE style=STYLE_SOLID)
   {
      if(!CreateNewStdGraphObject(chart_id,name,OBJ_TREND,subwindow,time1,price1,time2,price2))
      {
         ::Print(DFUN,CMessage::Text(MSG_GRAPH_STD_OBJ_ERR_FAILED_CREATE_STD_GRAPH_OBJ),": ",StdGraphObjectTypeDescription(OBJ_TREND));
         return false;
      }
      this.SetCommonParamsStdGraphObj(chart_id,name);
      ::ObjectSetInteger(chart_id,name,OBJPROP_COLOR,clr);
      ::ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
      ::ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
      return true;
   }
  //+------------------------------------------------------------------+
  //| Create the trend line standard graphical object                  |
  //| on the current chart in a specified subwindow                    |
  //+------------------------------------------------------------------+
  bool CGraphElmControl::CreateTrendLine(const string name,const int subwindow,
                                       const datetime time1,const double price1,
                                       const datetime time2,const double price2,
                                       color clr,int width=1,ENUM_LINE_STYLE style=STYLE_SOLID)
   {
      return this.CreateTrendLine(::ChartID(),name,subwindow,time1,price1,time2,price2,clr,width,style);
   }
  //+------------------------------------------------------------------+
  //| Create the trend line standard graphical object                  |
  //| on the current chart in the main window                          |
  //+------------------------------------------------------------------+
  bool CGraphElmControl::CreateTrendLine(const string name,
                                         const datetime time1,const double price1,
                                         const datetime time2,const double price2,
                                         color clr,int width=1,ENUM_LINE_STYLE style=STYLE_SOLID)
   {
      return this.CreateTrendLine(::ChartID(),name,0,time1,price1,time2,price2,clr,width,style);
   }
  //+------------------------------------------------------------------+
  //| Create the arrow standard graphical object                       |
  //| on a specified chart in a specified subwindow                    |
  //+------------------------------------------------------------------+
  bool CGraphElmControl::CreateArrow(const long chart_id,const string name,const int subwindow,
                                   const datetime time1,const double price1,
                                   color clr,uchar arrow_code,int width=1)
   {
      if(!CreateNewStdGraphObject(chart_id,name,OBJ_ARROW,subwindow,time1,price1))
      {
         ::Print(DFUN,CMessage::Text(MSG_GRAPH_STD_OBJ_ERR_FAILED_CREATE_STD_GRAPH_OBJ),": ",StdGraphObjectTypeDescription(OBJ_ARROW));
         return false;
      }
      this.SetCommonParamsStdGraphObj(chart_id,name);
      ::ObjectSetInteger(chart_id,name,OBJPROP_COLOR,clr);
      ::ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
      ::ObjectSetInteger(chart_id,name,OBJPROP_ARROWCODE,arrow_code);
      return true;
   }
  //+------------------------------------------------------------------+
  //| Create the arrow standard graphical object                       |
  //| on the current chart in a specified subwindow                    |
  //+------------------------------------------------------------------+
  bool CGraphElmControl::CreateArrow(const string name,const int subwindow,
                                   const datetime time1,const double price1,
                                   color clr,uchar arrow_code,int width=1)
   {
      return this.CreateArrow(::ChartID(),name,subwindow,time1,price1,clr,arrow_code,width);
   }
  //+------------------------------------------------------------------+
  //| Create the arrow standard graphical object                       |
  //| on the current chart in the main window                          |
  //+------------------------------------------------------------------+
  bool CGraphElmControl::CreateArrow(const string name,
                                   const datetime time1,const double price1,
                                   color clr,uchar arrow_code,int width=1)
   {
      return this.CreateArrow(::ChartID(),name,0,time1,price1,clr,arrow_code,width);
   }
  //+------------------------------------------------------------------+
  
 #endif // CGRAPHELMCONTROL_MQH_IMPLEMENTATION
#endif // __GRAPHELMCONTROL_MQH__