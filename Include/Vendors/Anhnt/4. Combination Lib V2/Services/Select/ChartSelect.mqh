//+------------------------------------------------------------------+
//|                                              ChartSelect.mqh     |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|  Extracted from Artyom Trishkin's DoEasy Select.mqh              |
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Methods of working with chart data                               |
//+------------------------------------------------------------------+
#ifndef CCHARTSELECT_MQH
#define CCHARTSELECT_MQH
 #include "CommonSelect.mqh"
 #include "..\..\Chart\ChartObj.mqh"
#ifndef CCHARTSELECT_MQH_DECLARATION
#define CCHARTSELECT_MQH_DECLARATION
class CChartSelect : public CCommonSelect
  {
    public:
    //--- Return the list of charts with one of (1) integer, (2) real and (3) string properties meeting a specified criterion
      static CArrayObj *ByChartProperty(CArrayObj *list_source,ENUM_CHART_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode);
      static CArrayObj *ByChartProperty(CArrayObj *list_source,ENUM_CHART_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode);
      static CArrayObj *ByChartProperty(CArrayObj *list_source,ENUM_CHART_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode);
    //--- Return the chart index with the maximum value of the (1) integer, (2) real and (3) string properties
      static int        FindChartMax(CArrayObj *list_source,ENUM_CHART_PROP_INTEGER property);
      static int        FindChartMax(CArrayObj *list_source,ENUM_CHART_PROP_DOUBLE property);
      static int        FindChartMax(CArrayObj *list_source,ENUM_CHART_PROP_STRING property);
    //--- Return the chart index with the minimum value of the (1) integer, (2) real and (3) string properties
      static int        FindChartMin(CArrayObj *list_source,ENUM_CHART_PROP_INTEGER property);
      static int        FindChartMin(CArrayObj *list_source,ENUM_CHART_PROP_DOUBLE property);
      static int        FindChartMin(CArrayObj *list_source,ENUM_CHART_PROP_STRING property);
  };
#endif // CCHARTSELECT_MQH_DECLARATION
#ifndef CCHARTSELECT_MQH_IMPLEMENTATION
#define CCHARTSELECT_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Return the list of charts with one integer                       |
//| property meeting the specified criterion                         |
//+------------------------------------------------------------------+
CArrayObj *CChartSelect::ByChartProperty(CArrayObj *list_source,ENUM_CHART_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   CommonListStorage.Add(list);
   int total=list_source.Total();
   for(int i=0; i<total; i++)
     {
      CChartObj *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      long obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Return the list of charts with one real                          |
//| property meeting the specified criterion                         |
//+------------------------------------------------------------------+
CArrayObj *CChartSelect::ByChartProperty(CArrayObj *list_source,ENUM_CHART_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   CommonListStorage.Add(list);
   for(int i=0; i<list_source.Total(); i++)
     {
      CChartObj *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      double obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Return the list of charts with one string                        |
//| property meeting the specified criterion                         |
//+------------------------------------------------------------------+
CArrayObj *CChartSelect::ByChartProperty(CArrayObj *list_source,ENUM_CHART_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   CommonListStorage.Add(list);
   for(int i=0; i<list_source.Total(); i++)
     {
      CChartObj *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      string obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Return the chart index in the list                               |
//| with the maximum integer property value                          |
//+------------------------------------------------------------------+
int CChartSelect::FindChartMax(CArrayObj *list_source,ENUM_CHART_PROP_INTEGER property)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int index=0;
   CChartObj *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CChartObj *obj=list_source.At(i);
      long obj1_prop=obj.GetProperty(property);
      max_obj=list_source.At(index);
      long obj2_prop=max_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Return the chart index in the list                               |
//| with the maximum real property value                             |
//+------------------------------------------------------------------+
int CChartSelect::FindChartMax(CArrayObj *list_source,ENUM_CHART_PROP_DOUBLE property)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int index=0;
   CChartObj *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CChartObj *obj=list_source.At(i);
      double obj1_prop=obj.GetProperty(property);
      max_obj=list_source.At(index);
      double obj2_prop=max_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Return the chart index in the list                               |
//| with the maximum string property value                           |
//+------------------------------------------------------------------+
int CChartSelect::FindChartMax(CArrayObj *list_source,ENUM_CHART_PROP_STRING property)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int index=0;
   CChartObj *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CChartObj *obj=list_source.At(i);
      string obj1_prop=obj.GetProperty(property);
      max_obj=list_source.At(index);
      string obj2_prop=max_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Return the chart index in the list                               |
//| with the minimum integer property value                          |
//+------------------------------------------------------------------+
int CChartSelect::FindChartMin(CArrayObj* list_source,ENUM_CHART_PROP_INTEGER property)
  {
   int index=0;
   CChartObj *min_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CChartObj *obj=list_source.At(i);
      long obj1_prop=obj.GetProperty(property);
      min_obj=list_source.At(index);
      long obj2_prop=min_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Return the chart index in the list                               |
//| with the minimum real property value                             |
//+------------------------------------------------------------------+
int CChartSelect::FindChartMin(CArrayObj* list_source,ENUM_CHART_PROP_DOUBLE property)
  {
   int index=0;
   CChartObj *min_obj=NULL;
   int total=list_source.Total();
   if(total== 0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CChartObj *obj=list_source.At(i);
      double obj1_prop=obj.GetProperty(property);
      min_obj=list_source.At(index);
      double obj2_prop=min_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Return the chart index in the list                               |
//| with the minimum string property value                           |
//+------------------------------------------------------------------+
int CChartSelect::FindChartMin(CArrayObj* list_source,ENUM_CHART_PROP_STRING property)
  {
   int index=0;
   CChartObj *min_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CChartObj *obj=list_source.At(i);
      string obj1_prop=obj.GetProperty(property);
      min_obj=list_source.At(index);
      string obj2_prop=min_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
     }
   return index;
  }
#endif // CCHARTSELECT_MQH_IMPLEMENTATION
#endif // CCHARTSELECT_MQH

