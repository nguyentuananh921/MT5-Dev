//+------------------------------------------------------------------+
//|                                                 GStdTrendObj.mqh |
//+------------------------------------------------------------------+
#ifndef __GSTDTRENDOBJ_MQH__
#define __GSTDTRENDOBJ_MQH__
 #include "..\..\GBases\GStdBaseObj.mqh"
#ifndef CGSTDTRENDOBJ_MQH_DECLARATION
#define CGSTDTRENDOBJ_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Trend line graphical object: two time/price points, optional rays |
 //+------------------------------------------------------------------+
 class CGStdTrendObj : public CGStdBaseObj
  {
   public:
     bool              Create(const long chart_id,const int subwin,const string name);
     bool              SetFlagRayLeft(const bool flag);
     bool              SetStyle(const ENUM_LINE_STYLE style);
                       CGStdTrendObj(void) {}
  };
#endif // CGSTDTRENDOBJ_MQH_DECLARATION
#ifndef CGSTDTRENDOBJ_MQH_IMPLEMENTATION
#define CGSTDTRENDOBJ_MQH_IMPLEMENTATION
 bool CGStdTrendObj::Create(const long chart_id,const int subwin,const string name)
  {
   if(!this.CreateObject(OBJECT_DE_TYPE_GSTD_TREND,chart_id,subwin,name,2))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_RAY_LEFT,0,::ObjectGetInteger(chart_id,name,OBJPROP_RAY_LEFT));
   this.SetProperty(GRAPH_OBJ_PROP_RAY_RIGHT,0,::ObjectGetInteger(chart_id,name,OBJPROP_RAY_RIGHT));
   this.SetWidth(DEF_LINE_WIDTH);   // the default, SetWidth() overrides it
   return true;
  }
 bool CGStdTrendObj::SetFlagRayLeft(const bool flag)
  {
   if(!::ObjectSetInteger(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_RAY_LEFT,flag))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_RAY_LEFT,0,flag);
   return true;
  }
 bool CGStdTrendObj::SetStyle(const ENUM_LINE_STYLE style)
  {
   if(!::ObjectSetInteger(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_STYLE,style))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_STYLE,0,style);
   return true;
  }
#endif // CGSTDTRENDOBJ_MQH_IMPLEMENTATION
#endif // __GSTDTRENDOBJ_MQH__
