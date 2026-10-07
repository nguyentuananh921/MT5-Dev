//+------------------------------------------------------------------+
//|                                         MarketStructureSeries.mqh |
//| One Market Structure event (BOS or CHoCH) - pure data, no GUI.   |
//| Same shape as CBarSwingSeries (CBaseObj + property arrays +      |
//| Compare/IsEqual for CArrayObj::Sort/Search/InsertSort).          |
//| 1 instance = 1 candle that closed beyond the reference Swing.    |
//+------------------------------------------------------------------+
#ifndef __MARKETSTRUCTURESERIES_MQH__
#define __MARKETSTRUCTURESERIES_MQH__
#include "..\..\Bases\BaseObj.mqh"
#include "..\..\Defines\MarketStructureDefines.mqh"

#ifndef CMARKETSTRUCTURESERIES_MQH_DECLARATION
#define CMARKETSTRUCTURESERIES_MQH_DECLARATION
class CMarketStructureSeries : public CBaseObj
 {
   private:
      long      m_long_prop[MARKET_STRUCTURE_PROP_INTEGER_TOTAL];                      // Integer properties
      double    m_double_prop[MARKET_STRUCTURE_PROP_DOUBLE_TOTAL];                     // Real properties
      string    m_string_prop[MARKET_STRUCTURE_PROP_STRING_TOTAL];                     // String properties
      int       IndexProp(ENUM_MARKET_STRUCTURE_PROP_DOUBLE property) const { return (int)property-MARKET_STRUCTURE_PROP_INTEGER_TOTAL; }
      int       IndexProp(ENUM_MARKET_STRUCTURE_PROP_STRING property) const { return (int)property-MARKET_STRUCTURE_PROP_INTEGER_TOTAL-MARKET_STRUCTURE_PROP_DOUBLE_TOTAL; }
   public:
   //--- Set (1) integer, (2) real and (3) string properties
      void      SetProperty(ENUM_MARKET_STRUCTURE_PROP_INTEGER property, long value)   { this.m_long_prop[property] = value; }
      void      SetProperty(ENUM_MARKET_STRUCTURE_PROP_DOUBLE  property, double value) { this.m_double_prop[this.IndexProp(property)] = value; }
      void      SetProperty(ENUM_MARKET_STRUCTURE_PROP_STRING  property, string value) { this.m_string_prop[this.IndexProp(property)] = value; }
   //--- Return (1) integer, (2) real and (3) string properties
      long      GetProperty(ENUM_MARKET_STRUCTURE_PROP_INTEGER property) const { return this.m_long_prop[property]; }
      double    GetProperty(ENUM_MARKET_STRUCTURE_PROP_DOUBLE  property) const { return this.m_double_prop[this.IndexProp(property)]; }
      string    GetProperty(ENUM_MARKET_STRUCTURE_PROP_STRING  property) const { return this.m_string_prop[this.IndexProp(property)]; }
   //--- Return itself
      CMarketStructureSeries *GetObject(void) { return &this; }
   //--- Compare by a specified property (for CArrayObj::Sort/Search/InsertSort)
      virtual int Compare(const CObject *node, const int mode=0) const;
   //--- Compare by ALL properties
      bool      IsEqual(CMarketStructureSeries *compared_obj) const;
   //--- Constructors/Destructor
                CMarketStructureSeries(void) { this.m_type = OBJECT_DE_TYPE_SERIES_MARKET_STRUCTURE; }
                CMarketStructureSeries(const ENUM_MARKET_STRUCTURE_TYPE type, const ENUM_SIGNAL_DIR direction,
                                       const string symbol, const ENUM_TIMEFRAMES timeframe,
                                       const datetime break_time, const datetime swing_time, const double level);
               ~CMarketStructureSeries(void) {}
   //--- Return (1) type (BOS/CHoCH), (2) direction, (3) timeframe, (4) unique code, (5) break candle time,
   //--- (6) pivot time of the broken Swing, (7) price of the broken Swing, (8) symbol
      ENUM_MARKET_STRUCTURE_TYPE TypeStructure(void) const { return (ENUM_MARKET_STRUCTURE_TYPE)this.GetProperty(MARKET_STRUCTURE_PROP_TYPE); }
      ENUM_SIGNAL_DIR         Direction(void)     const { return (ENUM_SIGNAL_DIR)this.GetProperty(MARKET_STRUCTURE_PROP_DIRECTION); }
      ENUM_TIMEFRAMES         Timeframe(void)     const { return (ENUM_TIMEFRAMES)this.GetProperty(MARKET_STRUCTURE_PROP_PERIOD); }
      ulong                   Code(void)          const { return (ulong)this.GetProperty(MARKET_STRUCTURE_PROP_CODE); }
      datetime                Time(void)          const { return (datetime)this.GetProperty(MARKET_STRUCTURE_PROP_TIME); }
      datetime                SwingTime(void)     const { return (datetime)this.GetProperty(MARKET_STRUCTURE_PROP_SWING_TIME); }
      double                  Level(void)         const { return this.GetProperty(MARKET_STRUCTURE_PROP_LEVEL); }
      string                  Symbol(void)        const { return this.GetProperty(MARKET_STRUCTURE_PROP_SYMBOL); }
 };
#endif // CMARKETSTRUCTURESERIES_MQH_DECLARATION
#ifndef CMARKETSTRUCTURESERIES_MQH_IMPLEMENTATION
#define CMARKETSTRUCTURESERIES_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Parametric constructor - the unique code (Primary Key) is        |
//| break time + type + period + symbol, as CBarSwingSeries does     |
//+------------------------------------------------------------------+
CMarketStructureSeries::CMarketStructureSeries(const ENUM_MARKET_STRUCTURE_TYPE type, const ENUM_SIGNAL_DIR direction,
                                               const string symbol, const ENUM_TIMEFRAMES timeframe,
                                               const datetime break_time, const datetime swing_time, const double level)
 {
   this.m_type = OBJECT_DE_TYPE_SERIES_MARKET_STRUCTURE;
   ulong symbol_code = 0;
   for(int i = 0; i < (int)StringLen(symbol); i++)
      symbol_code += (ulong)StringGetCharacter(symbol, i);
   ulong code = (ulong)break_time + (ulong)type + (ulong)timeframe + symbol_code;
   this.SetProperty(MARKET_STRUCTURE_PROP_CODE,       (long)code);
   this.SetProperty(MARKET_STRUCTURE_PROP_TIME,       break_time);
   this.SetProperty(MARKET_STRUCTURE_PROP_TYPE,       type);
   this.SetProperty(MARKET_STRUCTURE_PROP_DIRECTION,  direction);
   this.SetProperty(MARKET_STRUCTURE_PROP_PERIOD,     timeframe);
   this.SetProperty(MARKET_STRUCTURE_PROP_SWING_TIME, swing_time);
   this.SetProperty(MARKET_STRUCTURE_PROP_LEVEL,      level);
   this.SetProperty(MARKET_STRUCTURE_PROP_SYMBOL,     symbol);
 }
//+------------------------------------------------------------------+
//| Compare with another object by the specified property            |
//+------------------------------------------------------------------+
int CMarketStructureSeries::Compare(const CObject *node, const int mode=0) const
 {
   const CMarketStructureSeries *obj_compared = node;
   if(mode < MARKET_STRUCTURE_PROP_INTEGER_TOTAL)
    {
      long value_compared = obj_compared.GetProperty((ENUM_MARKET_STRUCTURE_PROP_INTEGER)mode);
      long value_current  = this.GetProperty((ENUM_MARKET_STRUCTURE_PROP_INTEGER)mode);
      return(value_current > value_compared ? 1 : value_current < value_compared ? -1 : 0);
    }
   else if(mode < MARKET_STRUCTURE_PROP_DOUBLE_TOTAL+MARKET_STRUCTURE_PROP_INTEGER_TOTAL)
    {
      double value_compared = obj_compared.GetProperty((ENUM_MARKET_STRUCTURE_PROP_DOUBLE)mode);
      double value_current  = this.GetProperty((ENUM_MARKET_STRUCTURE_PROP_DOUBLE)mode);
      return(value_current > value_compared ? 1 : value_current < value_compared ? -1 : 0);
    }
   else if(mode < MARKET_STRUCTURE_PROP_DOUBLE_TOTAL+MARKET_STRUCTURE_PROP_INTEGER_TOTAL+MARKET_STRUCTURE_PROP_STRING_TOTAL)
    {
      string value_compared = obj_compared.GetProperty((ENUM_MARKET_STRUCTURE_PROP_STRING)mode);
      string value_current  = this.GetProperty((ENUM_MARKET_STRUCTURE_PROP_STRING)mode);
      return(value_current > value_compared ? 1 : value_current < value_compared ? -1 : 0);
    }
   return 0;
 }
//+------------------------------------------------------------------+
//| Compare with another object by ALL properties                    |
//+------------------------------------------------------------------+
bool CMarketStructureSeries::IsEqual(CMarketStructureSeries *compared_obj) const
 {
   int begin = 0, end = MARKET_STRUCTURE_PROP_INTEGER_TOTAL;
   for(int i = begin; i < end; i++)
    {
      ENUM_MARKET_STRUCTURE_PROP_INTEGER prop = (ENUM_MARKET_STRUCTURE_PROP_INTEGER)i;
      if(this.GetProperty(prop) != compared_obj.GetProperty(prop)) return false;
    }
   begin = end; end += MARKET_STRUCTURE_PROP_DOUBLE_TOTAL;
   for(int i = begin; i < end; i++)
    {
      ENUM_MARKET_STRUCTURE_PROP_DOUBLE prop = (ENUM_MARKET_STRUCTURE_PROP_DOUBLE)i;
      if(this.GetProperty(prop) != compared_obj.GetProperty(prop)) return false;
    }
   begin = end; end += MARKET_STRUCTURE_PROP_STRING_TOTAL;
   for(int i = begin; i < end; i++)
    {
      ENUM_MARKET_STRUCTURE_PROP_STRING prop = (ENUM_MARKET_STRUCTURE_PROP_STRING)i;
      if(this.GetProperty(prop) != compared_obj.GetProperty(prop)) return false;
    }
   return true;
 }
#endif // CMARKETSTRUCTURESERIES_MQH_IMPLEMENTATION
#endif // __MARKETSTRUCTURESERIES_MQH__
