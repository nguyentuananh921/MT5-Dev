//+------------------------------------------------------------------+
//|                                                  GStdTextObj.mqh |
//+------------------------------------------------------------------+
#ifndef __GSTDTEXTOBJ_MQH__
#define __GSTDTEXTOBJ_MQH__
 #include "..\..\GBases\GStdBaseObj.mqh"
#ifndef CGSTDTEXTOBJ_MQH_DECLARATION
#define CGSTDTEXTOBJ_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Text graphical object: one time/price point, font, size, anchor  |
 //+------------------------------------------------------------------+
 class CGStdTextObj : public CGStdBaseObj
  {
   public:
     bool              Create(const long chart_id,const int subwin,const string name);
     bool              SetFont(const string font);
     bool              SetFontSize(const int size);
     bool              SetAnchor(const ENUM_ANCHOR_POINT anchor);
                       CGStdTextObj(void) {}
  };
#endif // CGSTDTEXTOBJ_MQH_DECLARATION
#ifndef CGSTDTEXTOBJ_MQH_IMPLEMENTATION
#define CGSTDTEXTOBJ_MQH_IMPLEMENTATION
 bool CGStdTextObj::Create(const long chart_id,const int subwin,const string name)
  {
   return this.CreateObject(OBJECT_DE_TYPE_GSTD_TEXT,chart_id,subwin,name,1);
  }
 bool CGStdTextObj::SetFont(const string font)
  {
   if(!::ObjectSetString(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_FONT,font))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_FONT,0,font);
   return true;
  }
 bool CGStdTextObj::SetFontSize(const int size)
  {
   if(!::ObjectSetInteger(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_FONTSIZE,size))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_FONTSIZE,0,size);
   return true;
  }
 bool CGStdTextObj::SetAnchor(const ENUM_ANCHOR_POINT anchor)
  {
   if(!::ObjectSetInteger(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_ANCHOR,anchor))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_ANCHOR,0,anchor);
   return true;
  }
#endif // CGSTDTEXTOBJ_MQH_IMPLEMENTATION
#endif // __GSTDTEXTOBJ_MQH__
