//+------------------------------------------------------------------+
//|                                       DataUnit.mqh              |
//+------------------------------------------------------------------+
#ifndef __DATAUNIT_MQH__
#define __DATAUNIT_MQH__
 #include <Object.mqh>
 #include "..\..\Defines\CommonDefines.mqh"
#ifndef CDATAUNIT_MQH_DECLARATION
#define CDATAUNIT_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Abstract data unit class                                         |
  //+------------------------------------------------------------------+
  class CDataUnit : public CObject
   {
     private:
      int               m_type;  
     protected:
                     CDataUnit(int type)  { this.m_type=type;        }
     public:
       virtual int       Type(void)     const { return this.m_type;      }
                     CDataUnit(){ this.m_type=OBJECT_DE_TYPE_OBJECT; }
   };
#endif // CDATAUNIT_MQH_DECLARATION
#endif // __DATAUNIT_MQH__
