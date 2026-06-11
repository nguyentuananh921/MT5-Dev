//+------------------------------------------------------------------+
//|                                               GraphSelect.mqh    |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#ifndef __GRAPH_SELECT_MQH__
#define __GRAPH_SELECT_MQH__

#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"

#include "CommonSelect.mqh"
#include "..\..\Graph\GCnvElement.mqh"

#ifndef CSELECT_MQH_DECLARATION
#define CSELECT_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Class for selecting canvas graphic elements from a list          |
//+------------------------------------------------------------------+
class CSelect : public CCommonSelect
  {
   public:
     static CArrayObj *ByGraphCanvElementProperty(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode);
     static CArrayObj *ByGraphCanvElementProperty(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode);
     static CArrayObj *ByGraphCanvElementProperty(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode);
  };
#endif // CSELECT_MQH_DECLARATION

#ifndef CSELECT_MQH_IMPLEMENTATION
#define CSELECT_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
CArrayObj *CSelect::ByGraphCanvElementProperty(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   CommonListStorage.Add(list);
   int total=list_source.Total();
   for(int i=0; i<total; i++)
     {
      CGCnvElement *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      long obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
CArrayObj *CSelect::ByGraphCanvElementProperty(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   CommonListStorage.Add(list);
   for(int i=0; i<list_source.Total(); i++)
     {
      CGCnvElement *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      double obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
CArrayObj *CSelect::ByGraphCanvElementProperty(CArrayObj *list_source,ENUM_CANV_ELEMENT_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   CommonListStorage.Add(list);
   for(int i=0; i<list_source.Total(); i++)
     {
      CGCnvElement *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      string obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
#endif // CSELECT_MQH_IMPLEMENTATION

#endif // __GRAPH_SELECT_MQH__
