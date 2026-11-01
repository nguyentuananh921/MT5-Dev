//+------------------------------------------------------------------+
//|                                   DataUnitLong.mqh              |
//+------------------------------------------------------------------+
#ifndef __DATAUNITLONG_MQH__
#define __DATAUNITLONG_MQH__
 #include "DataUnit.mqh"
#ifndef CDATAUNITLONG_MQH_DECLARATION
#define CDATAUNITLONG_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Long data unit class                                             |
  //+------------------------------------------------------------------+
  class CDataUnitLong : public CDataUnit
   {
     private:      
     protected:
     public:
     long            Value;
                     CDataUnitLong() : CDataUnit(OBJECT_DE_TYPE_LONG){}
   };
#endif // CDATAUNITLONG_MQH_DECLARATION
#endif // __DATAUNITLONG_MQH__
