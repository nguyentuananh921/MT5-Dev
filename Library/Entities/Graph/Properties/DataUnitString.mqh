//+------------------------------------------------------------------+
//|                                 DataUnitString.mqh              |
//+------------------------------------------------------------------+
#ifndef __DATAUNITSTRING_MQH__
#define __DATAUNITSTRING_MQH__
 #include "DataUnit.mqh"
#ifndef CDATAUNITSTRING_MQH_DECLARATION
#define CDATAUNITSTRING_MQH_DECLARATION
  //+------------------------------------------------------------------+   
  //| String data unit class                                          |
  //+------------------------------------------------------------------+
  class CDataUnitString : public CDataUnit
   {
      private:

         protected:

      public:
         string            Value;
                           CDataUnitString() : CDataUnit(OBJECT_DE_TYPE_STRING){}
   };
#endif // CDATAUNITSTRING_MQH_DECLARATION
#endif // __DATAUNITSTRING_MQH__
