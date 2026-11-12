//+------------------------------------------------------------------+
//|                                                       Source.mqh |
//| Use Cases (Clean Architecture): the port a judge reads its values |
//| through. An outer class implements it (CIndicatorDE), the judge   |
//| never knows the indicator nor MT5                                 |
//+------------------------------------------------------------------+
//--- New in V5 (RiskManagement My Note: ISource for the judges and the slots of a Strategy). An abstract class, not an interface:
//--- MQL5 has no class + interface inheritance ("multiple inheritance is not supported yet"), CIndicatorDE : CSource : CBaseObj
#ifndef __SOURCE_MQH__
#define __SOURCE_MQH__
 #include "..\..\Entities\Bases\BaseObj.mqh"
#ifndef CSOURCE_MQH_DECLARATION
#define CSOURCE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The values a judge reads, by the open time of a bar               |
 //+------------------------------------------------------------------+
 class CSource : public CBaseObj
  {
   public:
   //--- (1) the values up to the newest closed bar go to RAM, (2) RAM has every buffer at the bar of the time, (3) the value of a buffer (EMPTY_VALUE: none)
    virtual void      Refresh(void)                                   { }
    virtual bool      IsReady(const datetime time)                    { return false;       }
    virtual double    Value(const int buffer,const datetime time)     { return EMPTY_VALUE; }
  };
#endif // CSOURCE_MQH_DECLARATION
#endif // __SOURCE_MQH__
