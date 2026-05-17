//+------------------------------------------------------------------+
//|                                         TimeseriesSelect.mqh     |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#ifndef __TIMESERIES_SELECT_MQH__
#define __TIMESERIES_SELECT_MQH__
#include "CommonSelect.mqh"
#include "..\..\Timeseries\Bars\Bar.mqh"
#include "..\..\Timeseries\Bars\BarSeriesPatterns\Pattern.mqh"
#include "..\..\Timeseries\Indicators\DataInd.mqh"
#ifndef CTIMESERIES_SELECT_MQH_DECLARATION
#define CTIMESERIES_SELECT_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Select class for Timeseries objects (Bar, Pattern, DataInd)      |
//+------------------------------------------------------------------+
class CTimeseriesSelect : public CCommonSelect
  {
   public:
    //+------------------------------------------------------------------+
    //| Methods of working with timeseries bars                          |
    //+------------------------------------------------------------------+
      static CArrayObj *ByBarProperty(CArrayObj *list_source, ENUM_BAR_PROP_INTEGER property, long   value, ENUM_COMPARER_TYPE mode);
      static CArrayObj *ByBarProperty(CArrayObj *list_source, ENUM_BAR_PROP_DOUBLE  property, double value, ENUM_COMPARER_TYPE mode);
      static CArrayObj *ByBarProperty(CArrayObj *list_source, ENUM_BAR_PROP_STRING  property, string value, ENUM_COMPARER_TYPE mode);
      static int        FindBarMax   (CArrayObj *list_source, ENUM_BAR_PROP_INTEGER property);
      static int        FindBarMax   (CArrayObj *list_source, ENUM_BAR_PROP_DOUBLE  property);
      static int        FindBarMax   (CArrayObj *list_source, ENUM_BAR_PROP_STRING  property);
      static int        FindBarMin   (CArrayObj *list_source, ENUM_BAR_PROP_INTEGER property);
      static int        FindBarMin   (CArrayObj *list_source, ENUM_BAR_PROP_DOUBLE  property);
      static int        FindBarMin   (CArrayObj *list_source, ENUM_BAR_PROP_STRING  property);
    //+------------------------------------------------------------------+
    //| Methods of working with tick data                                |
    //+------------------------------------------------------------------+
    //--- Return the list of tick data with one out of (1) integer, (2) real and (3) string properties meeting a specified criterion
      static CArrayObj *ByTickDataProperty(CArrayObj *list_source,ENUM_TICK_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode);
      static CArrayObj *ByTickDataProperty(CArrayObj *list_source,ENUM_TICK_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode);
      static CArrayObj *ByTickDataProperty(CArrayObj *list_source,ENUM_TICK_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode);
    //--- Return the tick data index in the list with the maximum value of (1) integer, (2) real and (3) string property of data
      static int        FindTickDataMax(CArrayObj *list_source,ENUM_TICK_PROP_INTEGER property);
      static int        FindTickDataMax(CArrayObj *list_source,ENUM_TICK_PROP_DOUBLE property);
      static int        FindTickDataMax(CArrayObj *list_source,ENUM_TICK_PROP_STRING property);
    //--- Return the tick data index in the list with the minimum value of (1) integer, (2) real and (3) string property of data
      static int        FindTickDataMin(CArrayObj *list_source,ENUM_TICK_PROP_INTEGER property);
      static int        FindTickDataMin(CArrayObj *list_source,ENUM_TICK_PROP_DOUBLE property);
      static int        FindTickDataMin(CArrayObj *list_source,ENUM_TICK_PROP_STRING property);
    //+------------------------------------------------------------------+
    //| Methods for working with timeseries patterns                     |
    //+------------------------------------------------------------------+
     //--- Return the list of patterns with one out of (1) integer, (2) real and (3) string properties meeting a specified criterion
      static CArrayObj *ByPatternProperty(CArrayObj *list_source,ENUM_PATTERN_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode);
      static CArrayObj *ByPatternProperty(CArrayObj *list_source,ENUM_PATTERN_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode);
      static CArrayObj *ByPatternProperty(CArrayObj *list_source,ENUM_PATTERN_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode);
     //--- Return the pattern index in the list with the maximum value of the pattern (1) integer, (2) real and (3) string properties
      static int        FindPatternMax(CArrayObj *list_source,ENUM_PATTERN_PROP_INTEGER property);
      static int        FindPatternMax(CArrayObj *list_source,ENUM_PATTERN_PROP_DOUBLE property);
      static int        FindPatternMax(CArrayObj *list_source,ENUM_PATTERN_PROP_STRING property);
     //--- Return the pattern index in the list with the minimum value of the pattern (1) integer, (2) real and (3) string properties
      static int        FindPatternMin(CArrayObj *list_source,ENUM_PATTERN_PROP_INTEGER property);
      static int        FindPatternMin(CArrayObj *list_source,ENUM_PATTERN_PROP_DOUBLE property);
      static int        FindPatternMin(CArrayObj *list_source,ENUM_PATTERN_PROP_STRING property);    
    //+------------------------------------------------------------------+
    //| Methods of working with indicator buffers                        |
    //+------------------------------------------------------------------+
    //--- Return the list of buffers with one out of (1) integer, (2) real and (3) string properties meeting a specified criterion
   static CArrayObj *ByBufferProperty(CArrayObj *list_source,ENUM_BUFFER_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode);
   static CArrayObj *ByBufferProperty(CArrayObj *list_source,ENUM_BUFFER_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode);
   static CArrayObj *ByBufferProperty(CArrayObj *list_source,ENUM_BUFFER_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode);
   //--- Return the buffer index in the list with the maximum value of the buffer's (1) integer, (2) real and (3) string properties
   static int        FindBufferMax(CArrayObj *list_source,ENUM_BUFFER_PROP_INTEGER property);
   static int        FindBufferMax(CArrayObj *list_source,ENUM_BUFFER_PROP_DOUBLE property);
   static int        FindBufferMax(CArrayObj *list_source,ENUM_BUFFER_PROP_STRING property);
   //--- Return the buffer index in the list with the minimum value of the buffer's (1) integer, (2) real and (3) string properties
   static int        FindBufferMin(CArrayObj *list_source,ENUM_BUFFER_PROP_INTEGER property);
   static int        FindBufferMin(CArrayObj *list_source,ENUM_BUFFER_PROP_DOUBLE property);
   static int        FindBufferMin(CArrayObj *list_source,ENUM_BUFFER_PROP_STRING property);
//+------------------------------------------------------------------+
//| Methods of working with indicators                               |
//+------------------------------------------------------------------+
   //--- Return the list of indicators with one out of (1) integer, (2) real and (3) string properties meeting a specified criterion
   static CArrayObj *ByIndicatorProperty(CArrayObj *list_source,ENUM_INDICATOR_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode);
   static CArrayObj *ByIndicatorProperty(CArrayObj *list_source,ENUM_INDICATOR_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode);
   static CArrayObj *ByIndicatorProperty(CArrayObj *list_source,ENUM_INDICATOR_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode);
   //--- Return the indicator index in the list with the maximum value of the indicator's (1) integer, (2) real and (3) string property
   static int        FindIndicatorMax(CArrayObj *list_source,ENUM_INDICATOR_PROP_INTEGER property);
   static int        FindIndicatorMax(CArrayObj *list_source,ENUM_INDICATOR_PROP_DOUBLE property);
   static int        FindIndicatorMax(CArrayObj *list_source,ENUM_INDICATOR_PROP_STRING property);
   //--- Return the indicator index in the list with the minimum value of the indicator's (1) integer, (2) real and (3) string property
   static int        FindIndicatorMin(CArrayObj *list_source,ENUM_INDICATOR_PROP_INTEGER property);
   static int        FindIndicatorMin(CArrayObj *list_source,ENUM_INDICATOR_PROP_DOUBLE property);
   static int        FindIndicatorMin(CArrayObj *list_source,ENUM_INDICATOR_PROP_STRING property);
//+------------------------------------------------------------------+
//| Methods of work with indicator data                              |
//+------------------------------------------------------------------+
   //--- Return the list of indicator data with one out of (1) integer, (2) real and (3) string properties meeting a specified criterion
   static CArrayObj *ByIndicatorDataProperty(CArrayObj *list_source,ENUM_IND_DATA_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode);
   static CArrayObj *ByIndicatorDataProperty(CArrayObj *list_source,ENUM_IND_DATA_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode);
   static CArrayObj *ByIndicatorDataProperty(CArrayObj *list_source,ENUM_IND_DATA_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode);
   //--- Return the indicator data index in the list with the maximum value of (1) integer, (2) real and (3) string property of data
   static int        FindIndDataMax(CArrayObj *list_source,ENUM_IND_DATA_PROP_INTEGER property);
   static int        FindIndDataMax(CArrayObj *list_source,ENUM_IND_DATA_PROP_DOUBLE property);
   static int        FindIndDataMax(CArrayObj *list_source,ENUM_IND_DATA_PROP_STRING property);
   //--- Return the indicator data index in the list with the minimum value of (1) integer, (2) real and (3) string property of data
   static int        FindIndDataMin(CArrayObj *list_source,ENUM_IND_DATA_PROP_INTEGER property);
   static int        FindIndDataMin(CArrayObj *list_source,ENUM_IND_DATA_PROP_DOUBLE property);
   static int        FindIndDataMin(CArrayObj *list_source,ENUM_IND_DATA_PROP_STRING property);
  };
#endif // CTIMESERIES_SELECT_MQH_DECLARATION
#ifndef CTIMESERIES_SELECT_MQH_IMPLEMENTATION
#define CTIMESERIES_SELECT_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| ByBarProperty - Integer                                          |
//+------------------------------------------------------------------+
CArrayObj *CTimeseriesSelect::ByBarProperty(CArrayObj *list_source, ENUM_BAR_PROP_INTEGER property, long value, ENUM_COMPARER_TYPE mode)
  {
    if(list_source == NULL) return NULL;
    CArrayObj *list = new CArrayObj();
    if(list == NULL) return NULL;
    list.FreeMode(false);
    CommonListStorage.Add(list);
    int total = list_source.Total();
    for(int i = 0; i < total; i++)
      {
        CBar *obj = list_source.At(i);
        if(!obj.SupportProperty(property)) continue;
        if(CompareValues(obj.GetProperty(property), value, mode)) list.Add(obj);
      }
    return list;
  }
//+------------------------------------------------------------------+
//| ByBarProperty - Double                                           |
//+------------------------------------------------------------------+
CArrayObj *CTimeseriesSelect::ByBarProperty(CArrayObj *list_source, ENUM_BAR_PROP_DOUBLE property, double value, ENUM_COMPARER_TYPE mode)
  {
    if(list_source == NULL) return NULL;
    CArrayObj *list = new CArrayObj();
    if(list == NULL) return NULL;
    list.FreeMode(false);
    CommonListStorage.Add(list);
    for(int i = 0; i < list_source.Total(); i++)
      {
        CBar *obj = list_source.At(i);
        if(!obj.SupportProperty(property)) continue;
        if(CompareValues(obj.GetProperty(property), value, mode)) list.Add(obj);
      }
    return list;
  }
//+------------------------------------------------------------------+
//| ByBarProperty - String                                           |
//+------------------------------------------------------------------+
CArrayObj *CTimeseriesSelect::ByBarProperty(CArrayObj *list_source, ENUM_BAR_PROP_STRING property, string value, ENUM_COMPARER_TYPE mode)
  {
    if(list_source == NULL) return NULL;
    CArrayObj *list = new CArrayObj();
    if(list == NULL) return NULL;
    list.FreeMode(false);
    CommonListStorage.Add(list);
    for(int i = 0; i < list_source.Total(); i++)
      {
        CBar *obj = list_source.At(i);
        if(!obj.SupportProperty(property)) continue;
        if(CompareValues(obj.GetProperty(property), value, mode)) list.Add(obj);
      }
    return list;
  }
//+------------------------------------------------------------------+
//| FindBarMax - Integer                                             |
//+------------------------------------------------------------------+
int CTimeseriesSelect::FindBarMax(CArrayObj *list_source, ENUM_BAR_PROP_INTEGER property)
  {
    if(list_source == NULL || list_source.Total() == 0) return WRONG_VALUE;
    int index = 0;
    for(int i = 1; i < list_source.Total(); i++)
      {
        CBar *obj = list_source.At(i);
        CBar *max = list_source.At(index);
        if(CompareValues(obj.GetProperty(property), max.GetProperty(property), MORE)) index = i;
      }
    return index;
  }
//+------------------------------------------------------------------+
//| FindBarMax - Double                                              |
//+------------------------------------------------------------------+
int CTimeseriesSelect::FindBarMax(CArrayObj *list_source, ENUM_BAR_PROP_DOUBLE property)
  {
    if(list_source == NULL || list_source.Total() == 0) return WRONG_VALUE;
    int index = 0;
    for(int i = 1; i < list_source.Total(); i++)
      {
        CBar *obj = list_source.At(i);
        CBar *max = list_source.At(index);
        if(CompareValues(obj.GetProperty(property), max.GetProperty(property), MORE)) index = i;
      }
    return index;
  }
//+------------------------------------------------------------------+
//| FindBarMax - String                                              |
//+------------------------------------------------------------------+
int CTimeseriesSelect::FindBarMax(CArrayObj *list_source, ENUM_BAR_PROP_STRING property)
  {
    if(list_source == NULL || list_source.Total() == 0) return WRONG_VALUE;
    int index = 0;
    for(int i = 1; i < list_source.Total(); i++)
      {
        CBar *obj = list_source.At(i);
        CBar *max = list_source.At(index);
        if(CompareValues(obj.GetProperty(property), max.GetProperty(property), MORE)) index = i;
      }
    return index;
  }
//+------------------------------------------------------------------+
//| FindBarMin - Integer                                             |
//+------------------------------------------------------------------+
int CTimeseriesSelect::FindBarMin(CArrayObj *list_source, ENUM_BAR_PROP_INTEGER property)
  {
    if(list_source == NULL || list_source.Total() == 0) return WRONG_VALUE;
    int index = 0;
    for(int i = 1; i < list_source.Total(); i++)
      {
        CBar *obj = list_source.At(i);
        CBar *min = list_source.At(index);
        if(CompareValues(obj.GetProperty(property), min.GetProperty(property), LESS)) index = i;
      }
    return index;
  }
//+------------------------------------------------------------------+
//| FindBarMin - Double                                              |
//+------------------------------------------------------------------+
int CTimeseriesSelect::FindBarMin(CArrayObj *list_source, ENUM_BAR_PROP_DOUBLE property)
  {
    if(list_source == NULL || list_source.Total() == 0) return WRONG_VALUE;
    int index = 0;
    for(int i = 1; i < list_source.Total(); i++)
      {
        CBar *obj = list_source.At(i);
        CBar *min = list_source.At(index);
        if(CompareValues(obj.GetProperty(property), min.GetProperty(property), LESS)) index = i;
      }
    return index;
  }
//+------------------------------------------------------------------+
//| FindBarMin - String                                              |
//+------------------------------------------------------------------+
int CTimeseriesSelect::FindBarMin(CArrayObj *list_source, ENUM_BAR_PROP_STRING property)
  {
    if(list_source == NULL || list_source.Total() == 0) return WRONG_VALUE;
    int index = 0;
    for(int i = 1; i < list_source.Total(); i++)
      {
        CBar *obj = list_source.At(i);
        CBar *min = list_source.At(index);
        if(CompareValues(obj.GetProperty(property), min.GetProperty(property), LESS)) index = i;
      }
    return index;
  }
//+------------------------------------------------------------------+
//| ByPatternProperty - Integer                                      |
//+------------------------------------------------------------------+
CArrayObj *CTimeseriesSelect::ByPatternProperty(CArrayObj *list_source, ENUM_PATTERN_PROP_INTEGER property, long value, ENUM_COMPARER_TYPE mode)
  {
    if(list_source == NULL) return NULL;
    CArrayObj *list = new CArrayObj();
    if(list == NULL) return NULL;
    list.FreeMode(false);
    CommonListStorage.Add(list);
    int total = list_source.Total();
    for(int i = 0; i < total; i++)
      {
        CBarPattern *obj = list_source.At(i);
        if(!obj.SupportProperty(property)) continue;
        if(CompareValues(obj.GetProperty(property), value, mode)) list.Add(obj);
      }
    return list;
  }
//+------------------------------------------------------------------+
//| ByPatternProperty - Double                                       |
//+------------------------------------------------------------------+
CArrayObj *CTimeseriesSelect::ByPatternProperty(CArrayObj *list_source, ENUM_PATTERN_PROP_DOUBLE property, double value, ENUM_COMPARER_TYPE mode)
  {
    if(list_source == NULL) return NULL;
    CArrayObj *list = new CArrayObj();
    if(list == NULL) return NULL;
    list.FreeMode(false);
    CommonListStorage.Add(list);
    for(int i = 0; i < list_source.Total(); i++)
      {
        CBarPattern *obj = list_source.At(i);
        if(!obj.SupportProperty(property)) continue;
        if(CompareValues(obj.GetProperty(property), value, mode)) list.Add(obj);
      }
    return list;
  }
//+------------------------------------------------------------------+
//| ByPatternProperty - String                                       |
//+------------------------------------------------------------------+
CArrayObj *CTimeseriesSelect::ByPatternProperty(CArrayObj *list_source, ENUM_PATTERN_PROP_STRING property, string value, ENUM_COMPARER_TYPE mode)
  {
    if(list_source == NULL) return NULL;
    CArrayObj *list = new CArrayObj();
    if(list == NULL) return NULL;
    list.FreeMode(false);
    CommonListStorage.Add(list);
    for(int i = 0; i < list_source.Total(); i++)
      {
        CBarPattern *obj = list_source.At(i);
        if(!obj.SupportProperty(property)) continue;
        if(CompareValues(obj.GetProperty(property), value, mode)) list.Add(obj);
      }
    return list;
  }
//+------------------------------------------------------------------+
//| FindPatternMax - Integer                                         |
//+------------------------------------------------------------------+
int CTimeseriesSelect::FindPatternMax(CArrayObj *list_source, ENUM_PATTERN_PROP_INTEGER property)
  {
    if(list_source == NULL || list_source.Total() == 0) return WRONG_VALUE;
    int index = 0;
    for(int i = 1; i < list_source.Total(); i++)
      {
        CBarPattern *obj = list_source.At(i);
        CBarPattern *max = list_source.At(index);
        if(CompareValues(obj.GetProperty(property), max.GetProperty(property), MORE)) index = i;
      }
    return index;
  }
//+------------------------------------------------------------------+
//| FindPatternMax - Double                                          |
//+------------------------------------------------------------------+
int CTimeseriesSelect::FindPatternMax(CArrayObj *list_source, ENUM_PATTERN_PROP_DOUBLE property)
  {
    if(list_source == NULL || list_source.Total() == 0) return WRONG_VALUE;
    int index = 0;
    for(int i = 1; i < list_source.Total(); i++)
      {
        CBarPattern *obj = list_source.At(i);
        CBarPattern *max = list_source.At(index);
        if(CompareValues(obj.GetProperty(property), max.GetProperty(property), MORE)) index = i;
      }
    return index;
  }
//+------------------------------------------------------------------+
//| FindPatternMax - String                                          |
//+------------------------------------------------------------------+
int CTimeseriesSelect::FindPatternMax(CArrayObj *list_source, ENUM_PATTERN_PROP_STRING property)
  {
    if(list_source == NULL || list_source.Total() == 0) return WRONG_VALUE;
    int index = 0;
    for(int i = 1; i < list_source.Total(); i++)
      {
        CBarPattern *obj = list_source.At(i);
        CBarPattern *max = list_source.At(index);
        if(CompareValues(obj.GetProperty(property), max.GetProperty(property), MORE)) index = i;
      }
    return index;
  }
//+------------------------------------------------------------------+
//| FindPatternMin - Integer                                         |
//+------------------------------------------------------------------+
int CTimeseriesSelect::FindPatternMin(CArrayObj *list_source, ENUM_PATTERN_PROP_INTEGER property)
  {
    if(list_source == NULL || list_source.Total() == 0) return WRONG_VALUE;
    int index = 0;
    for(int i = 1; i < list_source.Total(); i++)
      {
        CBarPattern *obj = list_source.At(i);
        CBarPattern *min = list_source.At(index);
        if(CompareValues(obj.GetProperty(property), min.GetProperty(property), LESS)) index = i;
      }
    return index;
  }
//+------------------------------------------------------------------+
//| FindPatternMin - Double                                          |
//+------------------------------------------------------------------+
int CTimeseriesSelect::FindPatternMin(CArrayObj *list_source, ENUM_PATTERN_PROP_DOUBLE property)
  {
    if(list_source == NULL || list_source.Total() == 0) return WRONG_VALUE;
    int index = 0;
    for(int i = 1; i < list_source.Total(); i++)
      {
        CBarPattern *obj = list_source.At(i);
        CBarPattern *min = list_source.At(index);
        if(CompareValues(obj.GetProperty(property), min.GetProperty(property), LESS)) index = i;
      }
    return index;
  }
//+------------------------------------------------------------------+
//| FindPatternMin - String                                          |
//+------------------------------------------------------------------+
int CTimeseriesSelect::FindPatternMin(CArrayObj *list_source, ENUM_PATTERN_PROP_STRING property)
  {
    if(list_source == NULL || list_source.Total() == 0) return WRONG_VALUE;
    int index = 0;
    for(int i = 1; i < list_source.Total(); i++)
      {
        CBarPattern *obj = list_source.At(i);
        CBarPattern *min = list_source.At(index);
        if(CompareValues(obj.GetProperty(property), min.GetProperty(property), LESS)) index = i;
      }
    return index;
  }
//+------------------------------------------------------------------+
//| ByIndicatorDataProperty - Integer                                |
//+------------------------------------------------------------------+
CArrayObj *CTimeseriesSelect::ByIndicatorDataProperty(CArrayObj *list_source, ENUM_IND_DATA_PROP_INTEGER property, long value, ENUM_COMPARER_TYPE mode)
  {
    if(list_source == NULL) return NULL;
    CArrayObj *list = new CArrayObj();
    if(list == NULL) return NULL;
    list.FreeMode(false);
    CommonListStorage.Add(list);
    int total = list_source.Total();
    for(int i = 0; i < total; i++)
      {
        CDataInd *obj = list_source.At(i);
        if(!obj.SupportProperty(property)) continue;
        if(CompareValues(obj.GetProperty(property), value, mode)) list.Add(obj);
      }
    return list;
  }
//+------------------------------------------------------------------+
//| ByIndicatorDataProperty - Double                                 |
//+------------------------------------------------------------------+
CArrayObj *CTimeseriesSelect::ByIndicatorDataProperty(CArrayObj *list_source, ENUM_IND_DATA_PROP_DOUBLE property, double value, ENUM_COMPARER_TYPE mode)
  {
    if(list_source == NULL) return NULL;
    CArrayObj *list = new CArrayObj();
    if(list == NULL) return NULL;
    list.FreeMode(false);
    CommonListStorage.Add(list);
    for(int i = 0; i < list_source.Total(); i++)
      {
        CDataInd *obj = list_source.At(i);
        if(!obj.SupportProperty(property)) continue;
        if(CompareValues(obj.GetProperty(property), value, mode)) list.Add(obj);
      }
    return list;
  }
//+------------------------------------------------------------------+
//| ByIndicatorDataProperty - String                                 |
//+------------------------------------------------------------------+
CArrayObj *CTimeseriesSelect::ByIndicatorDataProperty(CArrayObj *list_source, ENUM_IND_DATA_PROP_STRING property, string value, ENUM_COMPARER_TYPE mode)
  {
    if(list_source == NULL) return NULL;
    CArrayObj *list = new CArrayObj();
    if(list == NULL) return NULL;
    list.FreeMode(false);
    CommonListStorage.Add(list);
    for(int i = 0; i < list_source.Total(); i++)
      {
        CDataInd *obj = list_source.At(i);
        if(!obj.SupportProperty(property)) continue;
        if(CompareValues(obj.GetProperty(property), value, mode)) list.Add(obj);
      }
    return list;
  }
#endif // CTIMESERIES_SELECT_MQH_IMPLEMENTATION
#endif // __TIMESERIES_SELECT_MQH__
