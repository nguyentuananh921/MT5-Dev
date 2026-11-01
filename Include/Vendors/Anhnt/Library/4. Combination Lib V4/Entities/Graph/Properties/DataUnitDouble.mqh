//+------------------------------------------------------------------+
//|                                 DataUnitDouble.mqh              |
//+------------------------------------------------------------------+
#ifndef __DATAUNITDOUBLE_MQH__
#define __DATAUNITDOUBLE_MQH__
 #include "DataUnit.mqh"
#ifndef CDATAUNITDOUBLE_MQH_DECLARATION
#define CDATAUNITDOUBLE_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Double data unit class                                          |
  //+------------------------------------------------------------------+
  class CDataUnitDouble : public CDataUnit
   {
      private:

         protected:

         public:
         double            Value;
                           CDataUnitDouble() : CDataUnit(OBJECT_DE_TYPE_DOUBLE){}
   };
#endif // CDATAUNITDOUBLE_MQH_DECLARATION
#endif // __DATAUNITDOUBLE_MQH__
