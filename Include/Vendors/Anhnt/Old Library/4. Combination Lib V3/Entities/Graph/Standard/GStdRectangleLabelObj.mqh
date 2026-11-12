//+------------------------------------------------------------------+
//|                                        GStdRectangleLabelObj.mqh |
//+------------------------------------------------------------------+
#ifndef __GSTDRECTANGLELABELOBJ_MQH__
#define __GSTDRECTANGLELABELOBJ_MQH__
 #include "..\..\GBases\GStdBaseObj.mqh"
#ifndef CGSTDRECTANGLELABELOBJ_MQH_DECLARATION
#define CGSTDRECTANGLELABELOBJ_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Rectangular label graphical object: placed in pixels from the    |
 //| chart corner, so its edges are not bound to candle centers       |
 //+------------------------------------------------------------------+
 class CGStdRectangleLabelObj : public CGStdBaseObj
  {
   public:
     bool              Create(const long chart_id,const int subwin,const string name);
     bool              SetXDistance(const long value);
     bool              SetYDistance(const long value);
     virtual bool      SetXSize(const long value);
     virtual bool      SetYSize(const long value);
     bool              SetBGColor(const color colour);
     bool              SetBorderType(const ENUM_BORDER_TYPE type);
                       CGStdRectangleLabelObj(void) {}
  };
#endif // CGSTDRECTANGLELABELOBJ_MQH_DECLARATION
#ifndef CGSTDRECTANGLELABELOBJ_MQH_IMPLEMENTATION
#define CGSTDRECTANGLELABELOBJ_MQH_IMPLEMENTATION
 bool CGStdRectangleLabelObj::Create(const long chart_id,const int subwin,const string name)
  {
   if(!this.CreateObject(OBJECT_DE_TYPE_GSTD_RECTANGLE_LABEL,chart_id,subwin,name,1))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_XDISTANCE,0,::ObjectGetInteger(chart_id,name,OBJPROP_XDISTANCE));
   this.SetProperty(GRAPH_OBJ_PROP_YDISTANCE,0,::ObjectGetInteger(chart_id,name,OBJPROP_YDISTANCE));
   this.SetProperty(GRAPH_OBJ_PROP_XSIZE,0,::ObjectGetInteger(chart_id,name,OBJPROP_XSIZE));
   this.SetProperty(GRAPH_OBJ_PROP_YSIZE,0,::ObjectGetInteger(chart_id,name,OBJPROP_YSIZE));
   this.SetProperty(GRAPH_OBJ_PROP_CORNER,0,::ObjectGetInteger(chart_id,name,OBJPROP_CORNER));
   this.SetProperty(GRAPH_OBJ_PROP_BORDER_TYPE,0,::ObjectGetInteger(chart_id,name,OBJPROP_BORDER_TYPE));
   this.SetProperty(GRAPH_OBJ_PROP_BGCOLOR,0,::ObjectGetInteger(chart_id,name,OBJPROP_BGCOLOR));
   return true;
  }
 bool CGStdRectangleLabelObj::SetXDistance(const long value)
  {
   if(!::ObjectSetInteger(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_XDISTANCE,value))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_XDISTANCE,0,value);
   return true;
  }
 bool CGStdRectangleLabelObj::SetYDistance(const long value)
  {
   if(!::ObjectSetInteger(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_YDISTANCE,value))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_YDISTANCE,0,value);
   return true;
  }
 bool CGStdRectangleLabelObj::SetXSize(const long value)
  {
   if(!CGBaseObj::SetXSize(value))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_XSIZE,0,value);
   return true;
  }
 bool CGStdRectangleLabelObj::SetYSize(const long value)
  {
   if(!CGBaseObj::SetYSize(value))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_YSIZE,0,value);
   return true;
  }
 bool CGStdRectangleLabelObj::SetBGColor(const color colour)
  {
   if(!::ObjectSetInteger(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_BGCOLOR,colour))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_BGCOLOR,0,colour);
   return true;
  }
 bool CGStdRectangleLabelObj::SetBorderType(const ENUM_BORDER_TYPE type)
  {
   if(!::ObjectSetInteger(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_BORDER_TYPE,type))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_BORDER_TYPE,0,type);
   return true;
  }
#endif // CGSTDRECTANGLELABELOBJ_MQH_IMPLEMENTATION
#endif // __GSTDRECTANGLELABELOBJ_MQH__
