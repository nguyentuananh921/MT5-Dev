//+------------------------------------------------------------------+
//|                                                MarketBookOrd.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//|Link https://www.mql5.com/en/articles/9850                        |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __MARKETBOOKORD_MQH__
#define __MARKETBOOKORD_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\..\..\Entities\Bases\BaseObj.mqh"
 #include "..\..\Defines\TradingDefines.mqh"
 #ifndef CMARKETBOOKORD_MQH_DECLARATION
 #define CMARKETBOOKORD_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| DOM abstract order class                                         |
 //+------------------------------------------------------------------+
 class CMarketBookOrd : public CBaseObj
  {
   private:
    int               m_digits;                                       // Number of decimal places
    long              m_long_prop[MBOOK_ORD_PROP_INTEGER_TOTAL];      // Integer properties
    double            m_double_prop[MBOOK_ORD_PROP_DOUBLE_TOTAL];     // Real properties
    string            m_string_prop[MBOOK_ORD_PROP_STRING_TOTAL];     // String properties
    //--- Return the index of the array the (1) double and (2) string properties are actually located at
     int               IndexProp(ENUM_MBOOK_ORD_PROP_DOUBLE property)  const { return(int)property-MBOOK_ORD_PROP_INTEGER_TOTAL;                              }
     int               IndexProp(ENUM_MBOOK_ORD_PROP_STRING property)  const { return(int)property-MBOOK_ORD_PROP_INTEGER_TOTAL-MBOOK_ORD_PROP_DOUBLE_TOTAL;  }
   protected:
    //--- Protected parametric constructor
                     CMarketBookOrd(const ENUM_MBOOK_ORD_STATUS status,const MqlBookInfo &book_info,const string symbol);
   public:
    //--- Set object's (1) integer, (2) real and (3) string properties
     void              SetProperty(ENUM_MBOOK_ORD_PROP_INTEGER property,long value)   { this.m_long_prop[property]=value;                      }
     void              SetProperty(ENUM_MBOOK_ORD_PROP_DOUBLE property,double value)  { this.m_double_prop[this.IndexProp(property)]=value;    }
     void              SetProperty(ENUM_MBOOK_ORD_PROP_STRING property,string value)  { this.m_string_prop[this.IndexProp(property)]=value;    }
    //--- Return object’s (1) integer, (2) real and (3) string property from the properties array
     long              GetProperty(ENUM_MBOOK_ORD_PROP_INTEGER property)        const { return this.m_long_prop[property];                     }
     double            GetProperty(ENUM_MBOOK_ORD_PROP_DOUBLE property)         const { return this.m_double_prop[this.IndexProp(property)];   }
     string            GetProperty(ENUM_MBOOK_ORD_PROP_STRING property)         const { return this.m_string_prop[this.IndexProp(property)];   }
    //--- Return itself
     CMarketBookOrd   *GetObject(void)                                                { return &this;}

    //--- Return the flag of the object supporting this property
     virtual bool      SupportProperty(ENUM_MBOOK_ORD_PROP_INTEGER property)          { return true; }
     virtual bool      SupportProperty(ENUM_MBOOK_ORD_PROP_DOUBLE property)           { return true; }
     virtual bool      SupportProperty(ENUM_MBOOK_ORD_PROP_STRING property)           { return true; }
    //--- Get description of (1) integer, (2) real and (3) string properties
     string            GetPropertyDescription(ENUM_MBOOK_ORD_PROP_INTEGER property);
     string            GetPropertyDescription(ENUM_MBOOK_ORD_PROP_DOUBLE property);
     string            GetPropertyDescription(ENUM_MBOOK_ORD_PROP_STRING property);

    //--- Display the description of the object properties in the journal (full_prop=true - all properties, false - supported ones only - implemented in descendant classes)
     virtual void      Print(const bool full_prop=false,const bool dash=false);
    //--- Display a short description of the object in the journal
     virtual void      PrintShort(const bool dash=false,const bool symbol=false);
    //--- Return the object short name
     virtual string    Header(const bool symbol=false);
    //--- Compare CMarketBookOrd objects by a specified property (to sort the list by a specified request object property)
     virtual int       Compare(const CObject *node,const int mode=0) const;
    //--- Compare CMarketBookOrd objects by all properties (to search for equal request objects)
     bool              IsEqual(CMarketBookOrd* compared_req) const;
   
    //--- Default constructor
                     CMarketBookOrd(){ this.m_type=OBJECT_DE_TYPE_BOOK_ORDER; }                  
    //+-------------------------------------------------------------------+ 
    //|Methods of a simplified access to the DOM request object properties|
    //+-------------------------------------------------------------------+
    //--- Set a snapshot time - all orders of a single DOM snapshot have the same name
     void              SetTime(const long time_msc)  { this.SetProperty(MBOOK_ORD_PROP_TIME_MSC,time_msc);                      }
   
    //--- Return order (1) status, (2) type and (3) order volume
     ENUM_MBOOK_ORD_STATUS Status(void)        const { return (ENUM_MBOOK_ORD_STATUS)this.GetProperty(MBOOK_ORD_PROP_STATUS);   }
     ENUM_BOOK_TYPE    TypeOrd(void)           const { return (ENUM_BOOK_TYPE)this.GetProperty(MBOOK_ORD_PROP_TYPE);            }
     long              Volume(void)            const { return this.GetProperty(MBOOK_ORD_PROP_VOLUME);                          }
    //--- Return (1) the price and (2) extended accuracy order volume
     double            Price(void)             const { return this.GetProperty(MBOOK_ORD_PROP_PRICE);                           }
     double            VolumeReal(void)        const { return this.GetProperty(MBOOK_ORD_PROP_VOLUME_REAL);                     }
    //--- Return (1) order symbol and (2) symbol's Digits
     string            Symbol(void)            const { return this.GetProperty(MBOOK_ORD_PROP_SYMBOL);                          }
     int               Digits()                const { return this.m_digits;                                                    }
    //--- Return the description of order  (1) type (ENUM_BOOK_TYPE) and (2) status (ENUM_MBOOK_ORD_STATUS)
     virtual string    TypeDescription(void)   const { return this.StatusDescription();                                         }
   string            StatusDescription(void) const;

  };
 #endif // CMARKETBOOKORD_MQH_DECLARATION
 #ifndef CMARKETBOOKORD_MQH_IMPLEMENTATION
 #define CMARKETBOOKORD_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Protected parametric constructor                                 |
  //+------------------------------------------------------------------+
  CMarketBookOrd::CMarketBookOrd(const ENUM_MBOOK_ORD_STATUS status,const MqlBookInfo &book_info,const string symbol)
   {
    this.m_type=OBJECT_DE_TYPE_BOOK_ORDER;
    //--- Save symbol’s Digits
     this.m_digits=(int)::SymbolInfoInteger(symbol,SYMBOL_DIGITS);
    //--- Save integer object properties
     this.SetProperty(MBOOK_ORD_PROP_STATUS,status);
     this.SetProperty(MBOOK_ORD_PROP_TYPE,book_info.type);
     this.SetProperty(MBOOK_ORD_PROP_VOLUME,book_info.volume);
    //--- Save real object properties
     this.SetProperty(MBOOK_ORD_PROP_PRICE,book_info.price);
     this.SetProperty(MBOOK_ORD_PROP_VOLUME_REAL,book_info.volume_real);
    //--- Save additional object properties
     this.SetProperty(MBOOK_ORD_PROP_SYMBOL,(symbol==NULL || symbol=="" ? ::Symbol() : symbol));
    //--- Order time is not present in the parameters and is considered in the DOM snapshot class. Reset the time
     this.SetProperty(MBOOK_ORD_PROP_TIME_MSC,0);
   }
  //+------------------------------------------------------------------+
  //| Compare CMarketBookOrd objects                                   |
  //| by a specified property                                          |
  //+------------------------------------------------------------------+
  int CMarketBookOrd::Compare(const CObject *node,const int mode=0) const
   {
    const CMarketBookOrd *obj_compared=node;
    //--- compare integer properties of two objects
     if(mode<MBOOK_ORD_PROP_INTEGER_TOTAL)
      {
       long value_compared=obj_compared.GetProperty((ENUM_MBOOK_ORD_PROP_INTEGER)mode);
       long value_current=this.GetProperty((ENUM_MBOOK_ORD_PROP_INTEGER)mode);
       return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
    //--- compare real properties of two objects
     else if(mode<MBOOK_ORD_PROP_DOUBLE_TOTAL+MBOOK_ORD_PROP_INTEGER_TOTAL)
      {
       double value_compared=obj_compared.GetProperty((ENUM_MBOOK_ORD_PROP_DOUBLE)mode);
       double value_current=this.GetProperty((ENUM_MBOOK_ORD_PROP_DOUBLE)mode);
       return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
    //--- compare string properties of two objects
     else if(mode<MBOOK_ORD_PROP_DOUBLE_TOTAL+MBOOK_ORD_PROP_INTEGER_TOTAL+MBOOK_ORD_PROP_STRING_TOTAL)
      {
       string value_compared=obj_compared.GetProperty((ENUM_MBOOK_ORD_PROP_STRING)mode);
       string value_current=this.GetProperty((ENUM_MBOOK_ORD_PROP_STRING)mode);
       return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
    return 0;
   }
  //+------------------------------------------------------------------+
  //| Compare CMarketBookOrd objects by all properties                 |
  //+------------------------------------------------------------------+
  bool CMarketBookOrd::IsEqual(CMarketBookOrd *compared_obj) const
   {
    int begin=0, end=MBOOK_ORD_PROP_INTEGER_TOTAL;
    for(int i=begin; i<end; i++)
      {
       ENUM_MBOOK_ORD_PROP_INTEGER prop=(ENUM_MBOOK_ORD_PROP_INTEGER)i;
       if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false; 
      }
    begin=end; end+=MBOOK_ORD_PROP_DOUBLE_TOTAL;
    for(int i=begin; i<end; i++)
      {
       ENUM_MBOOK_ORD_PROP_DOUBLE prop=(ENUM_MBOOK_ORD_PROP_DOUBLE)i;
       if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false; 
      }
    begin=end; end+=MBOOK_ORD_PROP_STRING_TOTAL;
    for(int i=begin; i<end; i++)
      {
       ENUM_MBOOK_ORD_PROP_STRING prop=(ENUM_MBOOK_ORD_PROP_STRING)i;
       if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false; 
      }
    return true;
   }
  //+------------------------------------------------------------------+
  //| Display object properties in the journal                         |
  //+------------------------------------------------------------------+
  void CMarketBookOrd::Print(const bool full_prop=false,const bool dash=false)
   {
    ::Print("============= ",CMessage::Text(MSG_LIB_PARAMS_LIST_BEG)," (",this.Header(),") =============");
    int begin=0, end=MBOOK_ORD_PROP_INTEGER_TOTAL;
    for(int i=begin; i<end; i++)
      {
       ENUM_MBOOK_ORD_PROP_INTEGER prop=(ENUM_MBOOK_ORD_PROP_INTEGER)i;
       if(!full_prop && !this.SupportProperty(prop)) continue;
       ::Print(this.GetPropertyDescription(prop));
      }
    ::Print("------");
    begin=end; end+=MBOOK_ORD_PROP_DOUBLE_TOTAL;
    for(int i=begin; i<end; i++)
      {
       ENUM_MBOOK_ORD_PROP_DOUBLE prop=(ENUM_MBOOK_ORD_PROP_DOUBLE)i;
       if(!full_prop && !this.SupportProperty(prop)) continue;
       ::Print(this.GetPropertyDescription(prop));
      }
    ::Print("------");
    begin=end; end+=MBOOK_ORD_PROP_STRING_TOTAL;
    for(int i=begin; i<end; i++)
      {
       ENUM_MBOOK_ORD_PROP_STRING prop=(ENUM_MBOOK_ORD_PROP_STRING)i;
       if(!full_prop && !this.SupportProperty(prop)) continue;
       ::Print(this.GetPropertyDescription(prop));
      }
    ::Print("============= ",CMessage::Text(MSG_LIB_PARAMS_LIST_END)," (",this.Header(),") =============\n");
   }
  //+------------------------------------------------------------------+
  //| Return description of object's integer property                  |
  //+------------------------------------------------------------------+
  string CMarketBookOrd::GetPropertyDescription(ENUM_MBOOK_ORD_PROP_INTEGER property)
   {
    return
      (
       property==MBOOK_ORD_PROP_STATUS        ?  CMessage::Text(MSG_ORD_STATUS)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.StatusDescription()
         )  :
      property==MBOOK_ORD_PROP_TYPE          ?  CMessage::Text(MSG_ORD_TYPE)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.TypeDescription()
         )  :
      property==MBOOK_ORD_PROP_VOLUME        ?  CMessage::Text(MSG_MBOOK_ORD_VOLUME)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      ""
      );
   }
  //+------------------------------------------------------------------+
  //| Return description of object's real property                     |
  //+------------------------------------------------------------------+
  string CMarketBookOrd::GetPropertyDescription(ENUM_MBOOK_ORD_PROP_DOUBLE property)
   {
    int dg=(this.m_digits>0 ? this.m_digits : 1);
    return
      (
       property==MBOOK_ORD_PROP_PRICE         ?  CMessage::Text(MSG_LIB_TEXT_REQUEST_PRICE)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
       property==MBOOK_ORD_PROP_VOLUME_REAL   ?  CMessage::Text(MSG_MBOOK_ORD_VOLUME_REAL)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
       ""
      );
   }
  //+------------------------------------------------------------------+
  //| Return description of object's string property                   |
  //+------------------------------------------------------------------+
  string CMarketBookOrd::GetPropertyDescription(ENUM_MBOOK_ORD_PROP_STRING property)
   {
    return(property==MBOOK_ORD_PROP_SYMBOL ? CMessage::Text(MSG_LIB_PROP_SYMBOL)+": \""+this.GetProperty(property)+"\"" : "");
   }
  //+------------------------------------------------------------------+
  //| Return the object short name                                     |
  //+------------------------------------------------------------------+
  string CMarketBookOrd::Header(const bool symbol=false)
   {
    return this.TypeDescription()+(symbol ? " \""+this.Symbol()+"\"" : "");
   }
  //+------------------------------------------------------------------+
  //| Display a short description of the object in the journal         |
  //+------------------------------------------------------------------+
  void CMarketBookOrd::PrintShort(const bool dash=false,const bool symbol=false)
   {
    ::Print(this.Header(symbol));
   }
  //+------------------------------------------------------------------+
  //| Return the order status description in DOM                       |
  //+------------------------------------------------------------------+
  string CMarketBookOrd::StatusDescription(void) const
   {
    return
      (
       Status()==MBOOK_ORD_STATUS_SELL  ?  CMessage::Text(MSG_MBOOK_ORD_STATUS_SELL) :
       Status()==MBOOK_ORD_STATUS_BUY   ?  CMessage::Text(MSG_MBOOK_ORD_STATUS_BUY)  :
      ""
     );
   } 
 #endif // CMARKETBOOKORD_MQH_IMPLEMENTATION
#endif // __MARKETBOOKORD_MQH__