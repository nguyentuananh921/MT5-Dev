//+------------------------------------------------------------------+
//|                                                GStdTriangleObj.mqh |
//+------------------------------------------------------------------+
#ifndef __GSTDTRIANGLEOBJ_MQH__
#define __GSTDTRIANGLEOBJ_MQH__
 #include "..\..\GBases\GStdBaseObj.mqh"
#ifndef CGSTDTRIANGLEOBJ_MQH_DECLARATION
#define CGSTDTRIANGLEOBJ_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Triangle graphical object: three time/price points               |
 //+------------------------------------------------------------------+
 class CGStdTriangleObj : public CGStdBaseObj
  {
   public:
     bool              Create(const long chart_id,const int subwin,const string name);
                       CGStdTriangleObj(void) {}
  };
#endif // CGSTDTRIANGLEOBJ_MQH_DECLARATION
#ifndef CGSTDTRIANGLEOBJ_MQH_IMPLEMENTATION
#define CGSTDTRIANGLEOBJ_MQH_IMPLEMENTATION
 bool CGStdTriangleObj::Create(const long chart_id,const int subwin,const string name)
  {
   if(!this.CreateObject(OBJECT_DE_TYPE_GSTD_TRIANGLE,chart_id,subwin,name,3))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_FILL,0,::ObjectGetInteger(chart_id,name,OBJPROP_FILL));
   return true;
  }
#endif // CGSTDTRIANGLEOBJ_MQH_IMPLEMENTATION
#endif // __GSTDTRIANGLEOBJ_MQH__
