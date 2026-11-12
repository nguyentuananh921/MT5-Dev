//+------------------------------------------------------------------+
//|                                                  GStdBaseObj.mqh |
//| Trimmed from DoEasy CGStdGraphObj (Lib V1): one standard chart   |
//| object, created like CGElement (default ctor, then Create);      |
//| more is pulled in when a class needs it                          |
//+------------------------------------------------------------------+
#ifndef __GSTDBASEOBJ_MQH__
#define __GSTDBASEOBJ_MQH__
 #include "GBaseObj.mqh"
 #include "GElement.mqh"
 #include "..\Graph\Properties\Properties.mqh"
#ifndef CGSTDBASEOBJ_MQH_DECLARATION
#define CGSTDBASEOBJ_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Base of the standard (native) chart objects                      |
 //+------------------------------------------------------------------+
 class CGStdBaseObj : public CGBaseObj
  {
   private:
     CProperties      *Prop;                // Pointer to the properties object
     int               m_pivots;            // Number of object reference points
     bool              m_owns_object;       // Create made the chart object, the destructor deletes it
   protected:
     //--- Creates the chart object (1 to 3 reference points) and fills the base properties
     bool              CreateObject(const ENUM_OBJECT_DE_TYPE obj_type,const long chart_id,const int subwin,const string name,const int pivots);
   public:
     //--- Current property values
     void              SetProperty(ENUM_GRAPH_OBJ_PROP_INTEGER property,int index,long value)   { this.Prop.Curr.SetLong(property,index,value);    }
     void              SetProperty(ENUM_GRAPH_OBJ_PROP_DOUBLE property,int index,double value)  { this.Prop.Curr.SetDouble(property,index,value);  }
     void              SetProperty(ENUM_GRAPH_OBJ_PROP_STRING property,int index,string value)  { this.Prop.Curr.SetString(property,index,value);  }
     long              GetProperty(ENUM_GRAPH_OBJ_PROP_INTEGER property,int index)        const { return this.Prop.Curr.GetLong(property,index);   }
     double            GetProperty(ENUM_GRAPH_OBJ_PROP_DOUBLE property,int index)         const { return this.Prop.Curr.GetDouble(property,index); }
     string            GetProperty(ENUM_GRAPH_OBJ_PROP_STRING property,int index)         const { return this.Prop.Curr.GetString(property,index); }
     CProperties      *Properties(void)                                                         { return this.Prop;                                }
     //--- Each setter writes the chart object, then the property
     bool              SetFlagBack(const bool flag,const bool only_prop);
     bool              SetFlagSelectable(const bool flag,const bool only_prop);
     bool              SetTime(const datetime time,const int modifier);
     bool              SetPrice(const double price,const int modifier);
     bool              SetColor(const color colour);
     bool              SetWidth(const int width);
     bool              SetFlagFill(const bool flag);
     bool              SetFlagRayRight(const bool flag);
     bool              SetText(const string text);
     bool              SetTooltip(const string tooltip);
     //--- Life cycle: passed down to the children (CGElement or CGStdBaseObj)
     virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     virtual void      OnTimerEvent(void);
                       CGStdBaseObj(void);
                      ~CGStdBaseObj(void);
  };
#endif // CGSTDBASEOBJ_MQH_DECLARATION
#ifndef CGSTDBASEOBJ_MQH_IMPLEMENTATION
#define CGSTDBASEOBJ_MQH_IMPLEMENTATION
 CGStdBaseObj::CGStdBaseObj(void) : m_pivots(0),m_owns_object(false)
  {
   this.Prop=new CProperties(GRAPH_OBJ_PROP_INTEGER_TOTAL,GRAPH_OBJ_PROP_DOUBLE_TOTAL,GRAPH_OBJ_PROP_STRING_TOTAL);
  }
 CGStdBaseObj::~CGStdBaseObj(void)
  {
   if(this.m_owns_object)
      ::ObjectDelete(this.ChartID(),this.Name());
   if(this.Prop!=NULL)
      delete this.Prop;
  }
 bool CGStdBaseObj::CreateObject(const ENUM_OBJECT_DE_TYPE obj_type,const long chart_id,const int subwin,const string name,const int pivots)
  {
   if(this.m_owns_object)
      return false;
   long cid=(chart_id==0 ? ::ChartID() : chart_id);
   ENUM_OBJECT type=CGBaseObj::GraphObjectType(obj_type);
   bool ok=false;
   switch(pivots)
     {
      case 1  : ok=::ObjectCreate(cid,name,type,subwin,0,0);                 break;
      case 2  : ok=::ObjectCreate(cid,name,type,subwin,0,0,0,0);             break;
      case 3  : ok=::ObjectCreate(cid,name,type,subwin,0,0,0,0,0,0);         break;
      default : break;
     }
   if(!ok)
      return false;
   this.m_owns_object=true;
   this.m_pivots=pivots;
   this.Prop.SetSizeRange(GRAPH_OBJ_PROP_TIME,this.m_pivots);
   this.Prop.SetSizeRange(GRAPH_OBJ_PROP_PRICE,this.m_pivots);
   this.m_type=obj_type;
   this.SetName(name);
   CGBaseObj::SetChartID(cid);
   CGBaseObj::SetTypeGraphObject(type);
   CGBaseObj::SetSubwindow(cid,name);
   CGBaseObj::SetDigits((int)::SymbolInfoInteger(::ChartSymbol(cid),SYMBOL_DIGITS));
   this.SetProperty(GRAPH_OBJ_PROP_CHART_ID,0,CGBaseObj::ChartID());
   this.SetProperty(GRAPH_OBJ_PROP_WND_NUM,0,CGBaseObj::SubWindow());
   this.SetProperty(GRAPH_OBJ_PROP_TYPE,0,CGBaseObj::TypeGraphObject());
   this.SetProperty(GRAPH_OBJ_PROP_NAME,0,name);
   return true;
  }
 void CGStdBaseObj::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   for(int i=0; i<this.ChildrenTotal(); i++)
     {
      CGBaseObj *child=this.Child(i);
      CGElement *element=dynamic_cast<CGElement *>(child);
      if(element!=NULL)
        {
         element.OnChartEvent(id,lparam,dparam,sparam);
         continue;
        }
      CGStdBaseObj *std_obj=dynamic_cast<CGStdBaseObj *>(child);
      if(std_obj!=NULL)
         std_obj.OnChartEvent(id,lparam,dparam,sparam);
     }
  }
 void CGStdBaseObj::OnTimerEvent(void)
  {
   for(int i=0; i<this.ChildrenTotal(); i++)
     {
      CGBaseObj *child=this.Child(i);
      CGElement *element=dynamic_cast<CGElement *>(child);
      if(element!=NULL)
        {
         element.OnTimerEvent();
         continue;
        }
      CGStdBaseObj *std_obj=dynamic_cast<CGStdBaseObj *>(child);
      if(std_obj!=NULL)
         std_obj.OnTimerEvent();
     }
  }
 bool CGStdBaseObj::SetFlagBack(const bool flag,const bool only_prop)
  {
   if(!CGBaseObj::SetFlagBack(flag,only_prop))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_BACK,0,flag);
   return true;
  }
 bool CGStdBaseObj::SetFlagSelectable(const bool flag,const bool only_prop)
  {
   if(!CGBaseObj::SetFlagSelectable(flag,only_prop))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_SELECTABLE,0,flag);
   return true;
  }
 bool CGStdBaseObj::SetTime(const datetime time,const int modifier)
  {
   if(!::ObjectSetInteger(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_TIME,modifier,time))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_TIME,modifier,time);
   return true;
  }
 bool CGStdBaseObj::SetPrice(const double price,const int modifier)
  {
   if(!::ObjectSetDouble(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_PRICE,modifier,price))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_PRICE,modifier,price);
   return true;
  }
 bool CGStdBaseObj::SetColor(const color colour)
  {
   if(!::ObjectSetInteger(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_COLOR,colour))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_COLOR,0,colour);
   return true;
  }
 bool CGStdBaseObj::SetWidth(const int width)
  {
   if(!::ObjectSetInteger(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_WIDTH,width))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_WIDTH,0,width);
   return true;
  }
 bool CGStdBaseObj::SetFlagFill(const bool flag)
  {
   if(!::ObjectSetInteger(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_FILL,flag))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_FILL,0,flag);
   return true;
  }
 bool CGStdBaseObj::SetFlagRayRight(const bool flag)
  {
   if(!::ObjectSetInteger(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_RAY_RIGHT,flag))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_RAY_RIGHT,0,flag);
   return true;
  }
 bool CGStdBaseObj::SetText(const string text)
  {
   if(!::ObjectSetString(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_TEXT,text))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_TEXT,0,text);
   return true;
  }
 bool CGStdBaseObj::SetTooltip(const string tooltip)
  {
   if(!::ObjectSetString(CGBaseObj::ChartID(),CGBaseObj::Name(),OBJPROP_TOOLTIP,tooltip))
      return false;
   this.SetProperty(GRAPH_OBJ_PROP_TOOLTIP,0,tooltip);
   return true;
  }
#endif // CGSTDBASEOBJ_MQH_IMPLEMENTATION
#endif // __GSTDBASEOBJ_MQH__
