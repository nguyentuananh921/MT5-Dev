//+------------------------------------------------------------------+
//|                                              TradingSelect.mqh   |
//|                         Copyright 2020, MetaQuotes Software Corp.|
//|  Extracted from Artyom Trishkin's DoEasy Select.mqh              |
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __TRADING_SELECT_MQH__
#define __TRADING_SELECT_MQH__
  //+------------------------------------------------------------------+
  //| Include files                                                    |
  //+------------------------------------------------------------------+
  #include <Arrays\ArrayObj.mqh>
  #include "..\..\Trading\Orders\Order.mqh"
  #include "..\..\Trading\Accounts\Account.mqh"
  #include "..\..\Trading\Symbols\Symbol.mqh"
  #include "..\..\Trading\PendRequest\PendRequest.mqh"
  #include "..\..\Trading\Book\MarketBookOrd.mqh"
  #include "..\..\Trading\TradeEvent\TradeEvent.mqh"

  #ifndef CTRADINGSELECT_MQH_DECLARATION
  #define CTRADINGSELECT_MQH_DECLARATION
    //+------------------------------------------------------------------+
    //| Storage list                                                     |
    //+------------------------------------------------------------------+
    CArrayObj     TradingListStorage; // Storage object for storing sorted collection lists
    //+------------------------------------------------------------------+
    //| Class for selecting objects meeting a criterion                  |
    //+------------------------------------------------------------------+
  class CTradingSelect
    {
     private:
       //--- Method for comparing two values
         template<typename T>
         static bool              CompareValues(T value1, T value2, ENUM_COMPARER_TYPE mode);
     public:
       //+------------------------------------------------------------------+
       //| Methods of working with orders                                   |
       //+------------------------------------------------------------------+
       //--- Return the list of orders with one out of (1) integer, (2) real and (3) string properties meeting a specified criterion
           static CArrayObj*      ByOrderProperty(CArrayObj* list_source, ENUM_ORDER_PROP_INTEGER property, long   value, ENUM_COMPARER_TYPE mode);
           static CArrayObj*      ByOrderProperty(CArrayObj* list_source, ENUM_ORDER_PROP_DOUBLE  property, double value, ENUM_COMPARER_TYPE mode);
           static CArrayObj*      ByOrderProperty(CArrayObj* list_source, ENUM_ORDER_PROP_STRING  property, string value, ENUM_COMPARER_TYPE mode);
       //--- Return the order index with the maximum value of the order's (1) integer, (2) real and (3) string properties
           static int             FindOrderMax(CArrayObj* list_source, ENUM_ORDER_PROP_INTEGER property);
           static int             FindOrderMax(CArrayObj* list_source, ENUM_ORDER_PROP_DOUBLE  property);
           static int             FindOrderMax(CArrayObj* list_source, ENUM_ORDER_PROP_STRING  property);
       //--- Return the order index with the minimum value of the order's (1) integer, (2) real and (3) string properties
           static int             FindOrderMin(CArrayObj* list_source, ENUM_ORDER_PROP_INTEGER property);
           static int             FindOrderMin(CArrayObj* list_source, ENUM_ORDER_PROP_DOUBLE  property);
           static int             FindOrderMin(CArrayObj* list_source, ENUM_ORDER_PROP_STRING  property);
       //+------------------------------------------------------------------+
       //| Methods of working with accounts                                 |
       //+------------------------------------------------------------------+
       //--- Return the list of accounts with one out of (1) integer, (2) real and (3) string properties meeting a specified criterion
           static CArrayObj*      ByAccountProperty(CArrayObj* list_source, ENUM_ACCOUNT_PROP_INTEGER property, long   value, ENUM_COMPARER_TYPE mode);
           static CArrayObj*      ByAccountProperty(CArrayObj* list_source, ENUM_ACCOUNT_PROP_DOUBLE  property, double value, ENUM_COMPARER_TYPE mode);
           static CArrayObj*      ByAccountProperty(CArrayObj* list_source, ENUM_ACCOUNT_PROP_STRING  property, string value, ENUM_COMPARER_TYPE mode);
       //--- Return the account index with the maximum value of the account (1) integer, (2) real and (3) string properties
           static int             FindAccountMax(CArrayObj* list_source, ENUM_ACCOUNT_PROP_INTEGER property);
           static int             FindAccountMax(CArrayObj* list_source, ENUM_ACCOUNT_PROP_DOUBLE  property);
           static int             FindAccountMax(CArrayObj* list_source, ENUM_ACCOUNT_PROP_STRING  property);
       //--- Return the account index with the minimum value of the account (1) integer, (2) real and (3) string properties
           static int             FindAccountMin(CArrayObj* list_source, ENUM_ACCOUNT_PROP_INTEGER property);
           static int             FindAccountMin(CArrayObj* list_source, ENUM_ACCOUNT_PROP_DOUBLE  property);
           static int             FindAccountMin(CArrayObj* list_source, ENUM_ACCOUNT_PROP_STRING  property);
       //+------------------------------------------------------------------+
       //| Methods of working with symbols                                  |
       //+------------------------------------------------------------------+
       //--- Return the list of symbols with one out of (1) integer, (2) real and (3) string properties meeting a specified criterion
           static CArrayObj*      BySymbolProperty(CArrayObj* list_source, ENUM_SYMBOL_PROP_INTEGER property, long   value, ENUM_COMPARER_TYPE mode);
           static CArrayObj*      BySymbolProperty(CArrayObj* list_source, ENUM_SYMBOL_PROP_DOUBLE  property, double value, ENUM_COMPARER_TYPE mode);
           static CArrayObj*      BySymbolProperty(CArrayObj* list_source, ENUM_SYMBOL_PROP_STRING  property, string value, ENUM_COMPARER_TYPE mode);
       //--- Return the symbol index with the maximum value of the symbol's (1) integer, (2) real and (3) string properties
           static int             FindSymbolMax(CArrayObj* list_source, ENUM_SYMBOL_PROP_INTEGER property);
           static int             FindSymbolMax(CArrayObj* list_source, ENUM_SYMBOL_PROP_DOUBLE  property);
           static int             FindSymbolMax(CArrayObj* list_source, ENUM_SYMBOL_PROP_STRING  property);
       //--- Return the symbol index with the minimum value of the symbol's (1) integer, (2) real and (3) string properties
           static int             FindSymbolMin(CArrayObj* list_source, ENUM_SYMBOL_PROP_INTEGER property);
           static int             FindSymbolMin(CArrayObj* list_source, ENUM_SYMBOL_PROP_DOUBLE  property);
           static int             FindSymbolMin(CArrayObj* list_source, ENUM_SYMBOL_PROP_STRING  property);
       //+------------------------------------------------------------------+
       //| Methods of working with pending requests                         |
       //+------------------------------------------------------------------+
       //--- Return the list of pending requests with one out of (1) integer, (2) real and (3) string properties meeting a specified criterion
           static CArrayObj*      ByPendReqProperty(CArrayObj* list_source, ENUM_PEND_REQ_PROP_INTEGER property, long   value, ENUM_COMPARER_TYPE mode);
           static CArrayObj*      ByPendReqProperty(CArrayObj* list_source, ENUM_PEND_REQ_PROP_DOUBLE  property, double value, ENUM_COMPARER_TYPE mode);
           static CArrayObj*      ByPendReqProperty(CArrayObj* list_source, ENUM_PEND_REQ_PROP_STRING  property, string value, ENUM_COMPARER_TYPE mode);
       //--- Return the pending request index with the maximum value of the pending request's (1) integer, (2) real and (3) string properties
           static int             FindPendReqMax(CArrayObj* list_source, ENUM_PEND_REQ_PROP_INTEGER property);
           static int             FindPendReqMax(CArrayObj* list_source, ENUM_PEND_REQ_PROP_DOUBLE  property);
           static int             FindPendReqMax(CArrayObj* list_source, ENUM_PEND_REQ_PROP_STRING  property);
       //--- Return the pending request index with the minimum value of the pending request's (1) integer, (2) real and (3) string properties
           static int             FindPendReqMin(CArrayObj* list_source, ENUM_PEND_REQ_PROP_INTEGER property);
           static int             FindPendReqMin(CArrayObj* list_source, ENUM_PEND_REQ_PROP_DOUBLE  property);
           static int             FindPendReqMin(CArrayObj* list_source, ENUM_PEND_REQ_PROP_STRING  property);
       //+------------------------------------------------------------------+
       //| Methods of working with DOM data (Book)                          |
       //+------------------------------------------------------------------+
       //--- Return the list of DOM data with one out of (1) integer, (2) real and (3) string properties meeting a specified criterion
           static CArrayObj*      ByMBookProperty(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_INTEGER property, long   value, ENUM_COMPARER_TYPE mode);
           static CArrayObj*      ByMBookProperty(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_DOUBLE  property, double value, ENUM_COMPARER_TYPE mode);
           static CArrayObj*      ByMBookProperty(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_STRING  property, string value, ENUM_COMPARER_TYPE mode);
       //--- Return the DOM data index in the list with the maximum value of (1) integer, (2) real and (3) string property of data
           static int             FindMBookMax(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_INTEGER property);
           static int             FindMBookMax(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_DOUBLE  property);
           static int             FindMBookMax(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_STRING  property);
       //--- Return the DOM data index in the list with the minimum value of (1) integer, (2) real and (3) string property of data
           static int             FindMBookMin(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_INTEGER property);
           static int             FindMBookMin(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_DOUBLE  property);
           static int             FindMBookMin(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_STRING  property);
       //+------------------------------------------------------------------+
       //| Methods of working with events                                   |
       //+------------------------------------------------------------------+
       //--- Return the list of events with one out of (1) integer, (2) real and (3) string properties meeting a specified criterion
           static CArrayObj*      ByEventProperty(CArrayObj* list_source, ENUM_EVENT_PROP_INTEGER property, long   value, ENUM_COMPARER_TYPE mode);
           static CArrayObj*      ByEventProperty(CArrayObj* list_source, ENUM_EVENT_PROP_DOUBLE  property, double value, ENUM_COMPARER_TYPE mode);
           static CArrayObj*      ByEventProperty(CArrayObj* list_source, ENUM_EVENT_PROP_STRING  property, string value, ENUM_COMPARER_TYPE mode);
       //--- Return the event index with the maximum value of the event's (1) integer, (2) real and (3) string properties
           static int             FindEventMax(CArrayObj* list_source, ENUM_EVENT_PROP_INTEGER property);
           static int             FindEventMax(CArrayObj* list_source, ENUM_EVENT_PROP_DOUBLE  property);
           static int             FindEventMax(CArrayObj* list_source, ENUM_EVENT_PROP_STRING  property);
       //--- Return the event index with the minimum value of the event's (1) integer, (2) real and (3) string properties
           static int             FindEventMin(CArrayObj* list_source, ENUM_EVENT_PROP_INTEGER property);
           static int             FindEventMin(CArrayObj* list_source, ENUM_EVENT_PROP_DOUBLE  property);
           static int             FindEventMin(CArrayObj* list_source, ENUM_EVENT_PROP_STRING  property);
    };
    //+------------------------------------------------------------------+
  #endif // CTRADINGSELECT_MQH_DECLARATION
  #ifndef CTRADINGSELECT_MQH_IMPLEMENTATION
  #define CTRADINGSELECT_MQH_IMPLEMENTATION
    //+------------------------------------------------------------------+
    //| Two values comparison method                                     |
    //+------------------------------------------------------------------+
    template<typename T>
    bool CTradingSelect::CompareValues(T value1, T value2, ENUM_COMPARER_TYPE mode)
      {
        switch(mode)
          {
            case EQUAL         : return(value1==value2   ? true : false);
            case NO_EQUAL      : return(value1!=value2   ? true : false);
            case MORE          : return(value1>value2    ? true : false);
            case LESS          : return(value1<value2    ? true : false);
            case EQUAL_OR_MORE : return(value1>=value2   ? true : false);
            case EQUAL_OR_LESS : return(value1<=value2   ? true : false);
            default            : return false;
          }
      }
    //+------------------------------------------------------------------+
    //| Methods of working with order lists                              |
    //+------------------------------------------------------------------+
    //+------------------------------------------------------------------+
    //| Return the list of orders with one integer                       |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::ByOrderProperty(CArrayObj* list_source, ENUM_ORDER_PROP_INTEGER property, long value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        int total=list_source.Total();
        for(int i=0; i<total; i++)
          {
            COrder* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            long obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the list of orders with one real                          |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::ByOrderProperty(CArrayObj* list_source, ENUM_ORDER_PROP_DOUBLE property, double value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        for(int i=0; i<list_source.Total(); i++)
          {
            COrder* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            double obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the list of orders with one string                        |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::ByOrderProperty(CArrayObj* list_source, ENUM_ORDER_PROP_STRING property, string value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        for(int i=0; i<list_source.Total(); i++)
          {
            COrder* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            string obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the listed order index                                    |
    //| with the maximum integer property value                          |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindOrderMax(CArrayObj* list_source, ENUM_ORDER_PROP_INTEGER property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int    index  =0;
        COrder* max_obj=NULL;
        int    total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            COrder* obj      =list_source.At(i);
            long    obj1_prop=obj.GetProperty(property);
            max_obj          =list_source.At(index);
            long    obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed order index                                    |
    //| with the maximum real property value                             |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindOrderMax(CArrayObj* list_source, ENUM_ORDER_PROP_DOUBLE property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int    index  =0;
        COrder* max_obj=NULL;
        int    total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            COrder* obj      =list_source.At(i);
            double  obj1_prop=obj.GetProperty(property);
            max_obj          =list_source.At(index);
            double  obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed order index                                    |
    //| with the maximum string property value                           |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindOrderMax(CArrayObj* list_source, ENUM_ORDER_PROP_STRING property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int    index  =0;
        COrder* max_obj=NULL;
        int    total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            COrder* obj      =list_source.At(i);
            string  obj1_prop=obj.GetProperty(property);
            max_obj          =list_source.At(index);
            string  obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed order index                                    |
    //| with the minimum integer property value                          |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindOrderMin(CArrayObj* list_source, ENUM_ORDER_PROP_INTEGER property)
      {
        int    index  =0;
        COrder* min_obj=NULL;
        int    total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            COrder* obj      =list_source.At(i);
            long    obj1_prop=obj.GetProperty(property);
            min_obj          =list_source.At(index);
            long    obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed order index                                    |
    //| with the minimum real property value                             |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindOrderMin(CArrayObj* list_source, ENUM_ORDER_PROP_DOUBLE property)
      {
        int    index  =0;
        COrder* min_obj=NULL;
        int    total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            COrder* obj      =list_source.At(i);
            double  obj1_prop=obj.GetProperty(property);
            min_obj          =list_source.At(index);
            double  obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed order index                                    |
    //| with the minimum string property value                           |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindOrderMin(CArrayObj* list_source, ENUM_ORDER_PROP_STRING property)
      {
        int    index  =0;
        COrder* min_obj=NULL;
        int    total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            COrder* obj      =list_source.At(i);
            string  obj1_prop=obj.GetProperty(property);
            min_obj          =list_source.At(index);
            string  obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Methods of working with account lists                            |
    //+------------------------------------------------------------------+
    //+------------------------------------------------------------------+
    //| Return the list of accounts with one integer                     |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::ByAccountProperty(CArrayObj* list_source, ENUM_ACCOUNT_PROP_INTEGER property, long value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        int total=list_source.Total();
        for(int i=0; i<total; i++)
          {
            CAccount* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            long obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the list of accounts with one real                        |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::ByAccountProperty(CArrayObj* list_source, ENUM_ACCOUNT_PROP_DOUBLE property, double value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        for(int i=0; i<list_source.Total(); i++)
          {
            CAccount* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            double obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the list of accounts with one string                      |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::ByAccountProperty(CArrayObj* list_source, ENUM_ACCOUNT_PROP_STRING property, string value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        for(int i=0; i<list_source.Total(); i++)
          {
            CAccount* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            string obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the listed account index                                  |
    //| with the maximum integer property value                          |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindAccountMax(CArrayObj* list_source, ENUM_ACCOUNT_PROP_INTEGER property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int       index  =0;
        CAccount* max_obj=NULL;
        int       total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CAccount* obj      =list_source.At(i);
            long      obj1_prop=obj.GetProperty(property);
            max_obj            =list_source.At(index);
            long      obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed account index                                  |
    //| with the maximum real property value                             |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindAccountMax(CArrayObj* list_source, ENUM_ACCOUNT_PROP_DOUBLE property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int       index  =0;
        CAccount* max_obj=NULL;
        int       total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CAccount* obj      =list_source.At(i);
            double    obj1_prop=obj.GetProperty(property);
            max_obj            =list_source.At(index);
            double    obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed account index                                  |
    //| with the maximum string property value                           |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindAccountMax(CArrayObj* list_source, ENUM_ACCOUNT_PROP_STRING property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int       index  =0;
        CAccount* max_obj=NULL;
        int       total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CAccount* obj      =list_source.At(i);
            string    obj1_prop=obj.GetProperty(property);
            max_obj            =list_source.At(index);
            string    obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed account index                                  |
    //| with the minimum integer property value                          |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindAccountMin(CArrayObj* list_source, ENUM_ACCOUNT_PROP_INTEGER property)
      {
        int       index  =0;
        CAccount* min_obj=NULL;
        int       total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CAccount* obj      =list_source.At(i);
            long      obj1_prop=obj.GetProperty(property);
            min_obj            =list_source.At(index);
            long      obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed account index                                  |
    //| with the minimum real property value                             |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindAccountMin(CArrayObj* list_source, ENUM_ACCOUNT_PROP_DOUBLE property)
      {
        int       index  =0;
        CAccount* min_obj=NULL;
        int       total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CAccount* obj      =list_source.At(i);
            double    obj1_prop=obj.GetProperty(property);
            min_obj            =list_source.At(index);
            double    obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed account index                                  |
    //| with the minimum string property value                           |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindAccountMin(CArrayObj* list_source, ENUM_ACCOUNT_PROP_STRING property)
      {
        int       index  =0;
        CAccount* min_obj=NULL;
        int       total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CAccount* obj      =list_source.At(i);
            string    obj1_prop=obj.GetProperty(property);
            min_obj            =list_source.At(index);
            string    obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Methods of working with symbol lists                             |
    //+------------------------------------------------------------------+
    //+------------------------------------------------------------------+
    //| Return the list of symbols with one integer                      |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::BySymbolProperty(CArrayObj* list_source, ENUM_SYMBOL_PROP_INTEGER property, long value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        int total=list_source.Total();
        for(int i=0; i<total; i++)
          {
            CSymbol* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            long obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the list of symbols with one real                         |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::BySymbolProperty(CArrayObj* list_source, ENUM_SYMBOL_PROP_DOUBLE property, double value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        for(int i=0; i<list_source.Total(); i++)
          {
            CSymbol* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            double obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the list of symbols with one string                       |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::BySymbolProperty(CArrayObj* list_source, ENUM_SYMBOL_PROP_STRING property, string value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        for(int i=0; i<list_source.Total(); i++)
          {
            CSymbol* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            string obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the listed symbol index                                   |
    //| with the maximum integer property value                          |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindSymbolMax(CArrayObj* list_source, ENUM_SYMBOL_PROP_INTEGER property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int      index  =0;
        CSymbol* max_obj=NULL;
        int      total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CSymbol* obj      =list_source.At(i);
            long     obj1_prop=obj.GetProperty(property);
            max_obj           =list_source.At(index);
            long     obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed symbol index                                   |
    //| with the maximum real property value                             |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindSymbolMax(CArrayObj* list_source, ENUM_SYMBOL_PROP_DOUBLE property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int      index  =0;
        CSymbol* max_obj=NULL;
        int      total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CSymbol* obj      =list_source.At(i);
            double   obj1_prop=obj.GetProperty(property);
            max_obj           =list_source.At(index);
            double   obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed symbol index                                   |
    //| with the maximum string property value                           |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindSymbolMax(CArrayObj* list_source, ENUM_SYMBOL_PROP_STRING property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int      index  =0;
        CSymbol* max_obj=NULL;
        int      total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CSymbol* obj      =list_source.At(i);
            string   obj1_prop=obj.GetProperty(property);
            max_obj           =list_source.At(index);
            string   obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed symbol index                                   |
    //| with the minimum integer property value                          |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindSymbolMin(CArrayObj* list_source, ENUM_SYMBOL_PROP_INTEGER property)
      {
        int      index  =0;
        CSymbol* min_obj=NULL;
        int      total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CSymbol* obj      =list_source.At(i);
            long     obj1_prop=obj.GetProperty(property);
            min_obj           =list_source.At(index);
            long     obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed symbol index                                   |
    //| with the minimum real property value                             |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindSymbolMin(CArrayObj* list_source, ENUM_SYMBOL_PROP_DOUBLE property)
      {
        int      index  =0;
        CSymbol* min_obj=NULL;
        int      total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CSymbol* obj      =list_source.At(i);
            double   obj1_prop=obj.GetProperty(property);
            min_obj           =list_source.At(index);
            double   obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed symbol index                                   |
    //| with the minimum string property value                           |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindSymbolMin(CArrayObj* list_source, ENUM_SYMBOL_PROP_STRING property)
      {
        int      index  =0;
        CSymbol* min_obj=NULL;
        int      total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CSymbol* obj      =list_source.At(i);
            string   obj1_prop=obj.GetProperty(property);
            min_obj           =list_source.At(index);
            string   obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Methods of working with pending request lists                    |
    //+------------------------------------------------------------------+
    //+------------------------------------------------------------------+
    //| Return the list of pending requests with one integer             |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::ByPendReqProperty(CArrayObj* list_source, ENUM_PEND_REQ_PROP_INTEGER property, long value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        int total=list_source.Total();
        for(int i=0; i<total; i++)
          {
            CPendRequest* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            long obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the list of pending requests with one real                |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::ByPendReqProperty(CArrayObj* list_source, ENUM_PEND_REQ_PROP_DOUBLE property, double value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        for(int i=0; i<list_source.Total(); i++)
          {
            CPendRequest* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            double obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the list of pending requests with one string              |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::ByPendReqProperty(CArrayObj* list_source, ENUM_PEND_REQ_PROP_STRING property, string value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        for(int i=0; i<list_source.Total(); i++)
          {
            CPendRequest* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            string obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the listed pending request index                          |
    //| with the maximum integer property value                          |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindPendReqMax(CArrayObj* list_source, ENUM_PEND_REQ_PROP_INTEGER property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int           index  =0;
        CPendRequest* max_obj=NULL;
        int           total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CPendRequest* obj      =list_source.At(i);
            long          obj1_prop=obj.GetProperty(property);
            max_obj                =list_source.At(index);
            long          obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed pending request index                          |
    //| with the maximum real property value                             |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindPendReqMax(CArrayObj* list_source, ENUM_PEND_REQ_PROP_DOUBLE property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int           index  =0;
        CPendRequest* max_obj=NULL;
        int           total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CPendRequest* obj      =list_source.At(i);
            double        obj1_prop=obj.GetProperty(property);
            max_obj                =list_source.At(index);
            double        obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed pending request index                          |
    //| with the maximum string property value                           |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindPendReqMax(CArrayObj* list_source, ENUM_PEND_REQ_PROP_STRING property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int           index  =0;
        CPendRequest* max_obj=NULL;
        int           total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CPendRequest* obj      =list_source.At(i);
            string        obj1_prop=obj.GetProperty(property);
            max_obj                =list_source.At(index);
            string        obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed pending request index                          |
    //| with the minimum integer property value                          |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindPendReqMin(CArrayObj* list_source, ENUM_PEND_REQ_PROP_INTEGER property)
      {
        int           index  =0;
        CPendRequest* min_obj=NULL;
        int           total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CPendRequest* obj      =list_source.At(i);
            long          obj1_prop=obj.GetProperty(property);
            min_obj                =list_source.At(index);
            long          obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed pending request index                          |
    //| with the minimum real property value                             |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindPendReqMin(CArrayObj* list_source, ENUM_PEND_REQ_PROP_DOUBLE property)
      {
        int           index  =0;
        CPendRequest* min_obj=NULL;
        int           total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CPendRequest* obj      =list_source.At(i);
            double        obj1_prop=obj.GetProperty(property);
            min_obj                =list_source.At(index);
            double        obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed pending request index                          |
    //| with the minimum string property value                           |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindPendReqMin(CArrayObj* list_source, ENUM_PEND_REQ_PROP_STRING property)
      {
        int           index  =0;
        CPendRequest* min_obj=NULL;
        int           total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CPendRequest* obj      =list_source.At(i);
            string        obj1_prop=obj.GetProperty(property);
            min_obj                =list_source.At(index);
            string        obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Methods of working with DOM (Book) lists                         |
    //+------------------------------------------------------------------+
    //+------------------------------------------------------------------+
    //| Return the list of DOM data with one integer                     |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::ByMBookProperty(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_INTEGER property, long value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        int total=list_source.Total();
        for(int i=0; i<total; i++)
          {
            CMarketBookOrd* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            long obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the list of DOM data with one real                        |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::ByMBookProperty(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_DOUBLE property, double value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        for(int i=0; i<list_source.Total(); i++)
          {
            CMarketBookOrd* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            double obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the list of DOM data with one string                      |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj* CTradingSelect::ByMBookProperty(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_STRING property, string value, ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj* list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        for(int i=0; i<list_source.Total(); i++)
          {
            CMarketBookOrd* obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            string obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the listed DOM data index                                 |
    //| with the maximum integer property value                          |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindMBookMax(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_INTEGER property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int             index  =0;
        CMarketBookOrd* max_obj=NULL;
        int             total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CMarketBookOrd* obj      =list_source.At(i);
            long            obj1_prop=obj.GetProperty(property);
            max_obj                  =list_source.At(index);
            long            obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed DOM data index                                 |
    //| with the maximum real property value                             |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindMBookMax(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_DOUBLE property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int             index  =0;
        CMarketBookOrd* max_obj=NULL;
        int             total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CMarketBookOrd* obj      =list_source.At(i);
            double          obj1_prop=obj.GetProperty(property);
            max_obj                  =list_source.At(index);
            double          obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed DOM data index                                 |
    //| with the maximum string property value                           |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindMBookMax(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_STRING property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int             index  =0;
        CMarketBookOrd* max_obj=NULL;
        int             total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CMarketBookOrd* obj      =list_source.At(i);
            string          obj1_prop=obj.GetProperty(property);
            max_obj                  =list_source.At(index);
            string          obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed DOM data index                                 |
    //| with the minimum integer property value                          |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindMBookMin(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_INTEGER property)
      {
        int             index  =0;
        CMarketBookOrd* min_obj=NULL;
        int             total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CMarketBookOrd* obj      =list_source.At(i);
            long            obj1_prop=obj.GetProperty(property);
            min_obj                  =list_source.At(index);
            long            obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed DOM data index                                 |
    //| with the minimum real property value                             |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindMBookMin(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_DOUBLE property)
      {
        int             index  =0;
        CMarketBookOrd* min_obj=NULL;
        int             total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CMarketBookOrd* obj      =list_source.At(i);
            double          obj1_prop=obj.GetProperty(property);
            min_obj                  =list_source.At(index);
            double          obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed DOM data index                                 |
    //| with the minimum string property value                           |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindMBookMin(CArrayObj* list_source, ENUM_MBOOK_ORD_PROP_STRING property)
      {
        int             index  =0;
        CMarketBookOrd* min_obj=NULL;
        int             total  =list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CMarketBookOrd* obj      =list_source.At(i);
            string          obj1_prop=obj.GetProperty(property);
            min_obj                  =list_source.At(index);
            string          obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+

    //+------------------------------------------------------------------+
    //| Methods of working with CEvent lists                             |
    //+------------------------------------------------------------------+
    //+------------------------------------------------------------------+
    //| Return the list of events with one integer                       |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj *CTradingSelect::ByEventProperty(CArrayObj *list_source,ENUM_EVENT_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj *list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        int total=list_source.Total();
        for(int i=0; i<total; i++)
          {
            CTradeEvent *obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            long obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the list of events with one real                          |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj *CTradingSelect::ByEventProperty(CArrayObj *list_source,ENUM_EVENT_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj *list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        for(int i=0; i<list_source.Total(); i++)
          {
            CTradeEvent *obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            double obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the list of events with one string                        |
    //| property meeting the specified criterion                         |
    //+------------------------------------------------------------------+
    CArrayObj *CTradingSelect::ByEventProperty(CArrayObj *list_source,ENUM_EVENT_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode)
      {
        if(list_source==NULL) return NULL;
        CArrayObj *list=new CArrayObj();
        if(list==NULL) return NULL;
        list.FreeMode(false);
        TradingListStorage.Add(list);
        for(int i=0; i<list_source.Total(); i++)
          {
            CTradeEvent *obj=list_source.At(i);
            if(!obj.SupportProperty(property)) continue;
            string obj_prop=obj.GetProperty(property);
            if(CompareValues(obj_prop,value,mode)) list.Add(obj);
          }
        return list;
      }
    //+------------------------------------------------------------------+
    //| Return the listed event index                                    |
    //| with the maximum integer property value                          |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindEventMax(CArrayObj *list_source,ENUM_EVENT_PROP_INTEGER property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int index=0;
        CTradeEvent *max_obj=NULL;
        int total=list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CTradeEvent *obj=list_source.At(i);
            long obj1_prop=obj.GetProperty(property);
            max_obj=list_source.At(index);
            long obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed event index                                    |
    //| with the maximum real property value                             |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindEventMax(CArrayObj *list_source,ENUM_EVENT_PROP_DOUBLE property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int index=0;
        CTradeEvent *max_obj=NULL;
        int total=list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CTradeEvent *obj=list_source.At(i);
            double obj1_prop=obj.GetProperty(property);
            max_obj=list_source.At(index);
            double obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed event index                                    |
    //| with the maximum string property value                           |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindEventMax(CArrayObj *list_source,ENUM_EVENT_PROP_STRING property)
      {
        if(list_source==NULL) return WRONG_VALUE;
        int index=0;
        CTradeEvent *max_obj=NULL;
        int total=list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CTradeEvent *obj=list_source.At(i);
            string obj1_prop=obj.GetProperty(property);
            max_obj=list_source.At(index);
            string obj2_prop=max_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed event index                                    |
    //| with the minimum integer property value                          |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindEventMin(CArrayObj *list_source,ENUM_EVENT_PROP_INTEGER property)
      {
        int index=0;
        CTradeEvent *min_obj=NULL;
        int total=list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CTradeEvent *obj=list_source.At(i);
            long obj1_prop=obj.GetProperty(property);
            min_obj=list_source.At(index);
            long obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed event index                                    |
    //| with the minimum real property value                             |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindEventMin(CArrayObj *list_source,ENUM_EVENT_PROP_DOUBLE property)
      {
        int index=0;
        CTradeEvent *min_obj=NULL;
        int total=list_source.Total();
        if(total== 0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CTradeEvent *obj=list_source.At(i);
            double obj1_prop=obj.GetProperty(property);
            min_obj=list_source.At(index);
            double obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
    //| Return the listed event index                                    |
    //| with the minimum string property value                           |
    //+------------------------------------------------------------------+
    int CTradingSelect::FindEventMin(CArrayObj *list_source,ENUM_EVENT_PROP_STRING property)
      {
        int index=0;
        CTradeEvent *min_obj=NULL;
        int total=list_source.Total();
        if(total==0) return WRONG_VALUE;
        for(int i=1; i<total; i++)
          {
            CTradeEvent *obj=list_source.At(i);
            string obj1_prop=obj.GetProperty(property);
            min_obj=list_source.At(index);
            string obj2_prop=min_obj.GetProperty(property);
            if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
          }
        return index;
      }
    //+------------------------------------------------------------------+
  #endif // CTRADINGSELECT_MQH_IMPLEMENTATION
#endif // __TRADING_SELECT_MQH__
