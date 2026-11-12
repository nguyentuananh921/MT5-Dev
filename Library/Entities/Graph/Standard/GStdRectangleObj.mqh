//+------------------------------------------------------------------+
//|                                             GStdRectangleObj.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                             https://mql5.com/en/users/artmedia70 |
//|Link                      https://www.mql5.com/en/articles/9964   |
//|Lib                       https://www.mql5.com/en/articles/14710  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __GSTDRECTANGLEOBJ_MQH__
#define __GSTDRECTANGLEOBJ_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\..\GBases\GStdBaseObj.mqh"
#ifndef CGSTDRECTANGLEOBJ_MQH_DECLARATION
#define CGSTDRECTANGLEOBJ_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Rectangle graphical object                                       |
 //+------------------------------------------------------------------+
 class CGStdRectangleObj : public CGStdBaseObj
  {
   private:
   public:
    //--- Constructor, then Create
      CGStdRectangleObj(void) {}
      bool              Create(const long chart_id,const int subwin,const string name)
        {
         if(!this.CreateObject(OBJECT_DE_TYPE_GSTD_RECTANGLE,chart_id,subwin,name,2))
            return false;
         this.SetProperty(GRAPH_OBJ_PROP_FILL,0,::ObjectGetInteger(chart_id,name,OBJPROP_FILL));
         return true;
        }
    //--- Supported object properties (1) real, (2) integer
     virtual bool      SupportProperty(ENUM_GRAPH_OBJ_PROP_DOUBLE property);
     virtual bool      SupportProperty(ENUM_GRAPH_OBJ_PROP_INTEGER property);
     virtual bool      SupportProperty(ENUM_GRAPH_OBJ_PROP_STRING property);
    //--- Return the (ENUM_OBJECT) type description
     virtual string    TypeDescription(void)   const { return StdGraphObjectTypeDescription(OBJ_RECTANGLE); }
  };
#endif // CGSTDRECTANGLEOBJ_MQH_DECLARATION
#ifndef CGSTDRECTANGLEOBJ_MQH_IMPLEMENTATION
#define CGSTDRECTANGLEOBJ_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Return 'true' if an object supports a passed                     |
 //| integer property, otherwise return 'false'                       |
 //+------------------------------------------------------------------+
 bool CGStdRectangleObj::SupportProperty(ENUM_GRAPH_OBJ_PROP_INTEGER property)
  {
   switch((int)property)
     {
      //--- Supported properties
      case GRAPH_OBJ_PROP_ID           :
      case GRAPH_OBJ_PROP_BASE_ID      :
      case GRAPH_OBJ_PROP_TYPE         :
      case GRAPH_OBJ_PROP_ELEMENT_TYPE : 
      case GRAPH_OBJ_PROP_GROUP        : 
      case GRAPH_OBJ_PROP_BELONG       :
      case GRAPH_OBJ_PROP_CHART_ID     :
      case GRAPH_OBJ_PROP_WND_NUM      :
      case GRAPH_OBJ_PROP_NUM          :
      case GRAPH_OBJ_PROP_CREATETIME   :
      case GRAPH_OBJ_PROP_CHANGE_HISTORY:
      case GRAPH_OBJ_PROP_TIMEFRAMES   :
      case GRAPH_OBJ_PROP_BACK         :
      case GRAPH_OBJ_PROP_ZORDER       :
      case GRAPH_OBJ_PROP_HIDDEN       :
      case GRAPH_OBJ_PROP_SELECTED     :
      case GRAPH_OBJ_PROP_SELECTABLE   :
      case GRAPH_OBJ_PROP_TIME         :
      case GRAPH_OBJ_PROP_COLOR        :
      case GRAPH_OBJ_PROP_STYLE        :
      case GRAPH_OBJ_PROP_WIDTH        :
      case GRAPH_OBJ_PROP_FILL         : return true;
      //--- Other properties are not supported
      //--- Default is 'false'
      default: break;
     }
   return false;
  }
 //+------------------------------------------------------------------+
 //| Return 'true' if an object supports a passed                     |
 //| real property, otherwise return 'false'                          |
 //+------------------------------------------------------------------+
 bool CGStdRectangleObj::SupportProperty(ENUM_GRAPH_OBJ_PROP_DOUBLE property)
  {
   switch((int)property)
     {
      //--- Supported properties
      case GRAPH_OBJ_PROP_PRICE        : return true;
      //--- Other properties are not supported
      //--- Default is 'false'
      default: break;
     }
   return false;
  }
 //+------------------------------------------------------------------+
 //| Return 'true' if an object supports a passed                     |
 //| string property, otherwise return 'false'                        |
 //+------------------------------------------------------------------+
 bool CGStdRectangleObj::SupportProperty(ENUM_GRAPH_OBJ_PROP_STRING property)
  {
   switch((int)property)
     {
      //--- Supported properties
      case GRAPH_OBJ_PROP_NAME            :
      case GRAPH_OBJ_PROP_BASE_NAME       :
      case GRAPH_OBJ_PROP_TEXT            :
      case GRAPH_OBJ_PROP_TOOLTIP         :  return true;
      //--- Other properties are not supported
      //--- Default is 'false'
      default: break;
     }
   return false;
  }
 //+------------------------------------------------------------------+

#endif // CGSTDRECTANGLEOBJ_MQH_IMPLEMENTATION
#endif // __GSTDRECTANGLEOBJ_MQH__
