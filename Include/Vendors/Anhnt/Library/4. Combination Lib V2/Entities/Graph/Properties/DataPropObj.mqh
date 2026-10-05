//+------------------------------------------------------------------+
//|                                                  DataPropObj.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                             https://mql5.com/en/users/artmedia70 |
//|Link                      https://www.mql5.com/en/articles/10237  |
//|Lib                       https://www.mql5.com/en/articles/14710  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
//#include "DELib.mqh"
#include "XDimArrayLong.mqh"
#include "XDimArrayDouble.mqh"
#include "XDimArrayString.mqh"

#ifndef CDATAPROPOBJ_MQH
#define CDATAPROPOBJ_MQH

 #ifndef CDATAPROPOBJ_MQH_DECLARATION
 #define CDATAPROPOBJ_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Object property class                                            |
//+------------------------------------------------------------------+
class CDataPropObj : public CObject
  {
private:
   CArrayObj         m_list;           // list of property objects
   int               m_total_int;      // Number of integer parameters
   int               m_total_dbl;      // Number of real parameters
   int               m_total_str;      // Number of string parameters
   int               m_prop_max_dbl;   // Maximum possible real property value
   int               m_prop_max_str;   // Maximum possible string property value

//--- Return the index of the array the int, double or string property is actually located at
   int               IndexProp(int property) const;

protected:

public:
//--- Constructor/destructor
                     CDataPropObj(const int prop_total_integer,const int prop_total_double,const int prop_total_string);
                    ~CDataPropObj();

//--- Return the pointer to (1) the list of property objects, as well as to the object of (2) integer, (3) real and (4) string properties
   CArrayObj        *GetList(void)                                                     { return &this.m_list;                                      }
   CXDimArrayLong   *Long()                                                      const { return this.m_list.At(0);                                 }
   CXDimArrayDouble *Double()                                                    const { return this.m_list.At(1);                                 }
   CXDimArrayString *String()                                                    const { return this.m_list.At(2);                                 }
   
//--- Set (1) integer, (2) real and (3) string properties in the appropriate property object
   void              SetLong(int property,int index,long value)                        { this.Long().Set(property,index,value);                    }
   void              SetDouble(int property,int index,double value)                    { this.Double().Set(this.IndexProp(property),index,value);  }
   void              SetString(int property,int index,string value)                    { this.String().Set(this.IndexProp(property),index,value);  }
//--- Return (1) integer, (2) real and (3) string property from the appropriate object
   long              GetLong(int property,int index)                             const { return this.Long().Get(property,index);                   }
   double            GetDouble(int property,int index)                           const { return this.Double().Get(this.IndexProp(property),index); }
   string            GetString(int property,int index)                           const { return this.String().Get(this.IndexProp(property),index); }
   
//--- Return the size of the specified first dimension data array
   int               Size(const int range) const;
//--- Set the array size in the specified dimensionality
   bool              SetSizeRange(const int range,const int size);
//--- Return the number of (1) integer, (2) real and (3) string parameters
   int               TotalLong(void)   const { return this.m_total_int; }
   int               TotalDouble(void) const { return this.m_total_dbl; }
   int               TotalString(void) const { return this.m_total_str; }
  };
 #endif // CDATAPROPOBJ_MQH_DECLARATION
 #ifndef CDATAPROPOBJ_MQH_IMPLEMENTATION
 #define CDATAPROPOBJ_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Return the index of the array the property is actually located at|
 //+------------------------------------------------------------------+
 int CDataPropObj::IndexProp(int property) const
  {
   //--- If the passed value is less than the number of integer parameters,
   //--- this is an integer property. Return the value passed to the method
   if(property<this.m_total_int)
      return property;
   //--- Otherwise if the passed value is less than the maximum possible real property value,
   //--- then this is a real property - return the calculated index in the array of real properties
   else if(property<this.m_prop_max_dbl)
      return property-this.m_total_int;
   //--- Otherwise if the passed value is less than the maximum possible string property value,
   //--- then this is a string property - return the calculated index in the array of string properties
   else if(property<this.m_prop_max_str)
      return property-this.m_total_int-this.m_total_dbl;
   //--- Otherwise, if the passed value exceeds the maximum range of all values of all properties, 
   //--- inform of this in the journal and return INT_MAX causing the error
   //--- accessing the array in XDimArray file classes which send the appropriate warning to the journal
   CMessage::ToLog(DFUN,MSG_DATA_PROP_OBJ_OUT_OF_PROP_RANGE);
   return INT_MAX;
  }
 //+------------------------------------------------------------------+
 //| Return the size of the specified first dimension data array      |
 //+------------------------------------------------------------------+
 int CDataPropObj::Size(const int range) const
  {
   if(range<this.m_total_int)
      return this.Long().Size(range);
   else if(range<this.m_prop_max_dbl)
      return this.Double().Size(this.IndexProp(range));
   else if(range<this.m_prop_max_str)
      return this.String().Size(this.IndexProp(range));
   return 0;
  }
 //+------------------------------------------------------------------+
 //| Set the array size in the specified dimensionality               |
 //+------------------------------------------------------------------+
 bool CDataPropObj::SetSizeRange(const int range,const int size)
  {
   if(range<this.m_total_int)
      return this.Long().SetSizeRange(range,size);
   else if(range<this.m_prop_max_dbl)
      return this.Double().SetSizeRange(this.IndexProp(range),size);
   else if(range<this.m_prop_max_str)
      return this.String().SetSizeRange(this.IndexProp(range),size);
   return false;
  }
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CDataPropObj::CDataPropObj(const int prop_total_integer,const int prop_total_double,const int prop_total_string)
  {
   //--- Set the passed amounts of integer, real and string properties in the variables
   this.m_total_int=prop_total_integer;
   this.m_total_dbl=prop_total_double;
   this.m_total_str=prop_total_string;
   //--- Calculate and set the maximum values of real and string properties to the variables
   this.m_prop_max_dbl=this.m_total_int+this.m_total_dbl;
   this.m_prop_max_str=this.m_total_int+this.m_total_dbl+this.m_total_str;
   //--- Add newly created objects of integer, real and string properties to the list
   this.m_list.Add(new CXDimArrayLong(this.m_total_int, 1));
   this.m_list.Add(new CXDimArrayDouble(this.m_total_dbl,1));
   this.m_list.Add(new CXDimArrayString(this.m_total_str,1));
  }
 //+------------------------------------------------------------------+
 //| Destructor                                                       |
 //+------------------------------------------------------------------+
 CDataPropObj::~CDataPropObj()
  {
   m_list.Clear();
   m_list.Shutdown();
  }
 #endif // CDATAPROPOBJ_MQH_IMPLEMENTATION

#endif // CDATAPROPOBJ_MQH
