//+------------------------------------------------------------------+
//|                                                     BarSwing.mqh |
//| Swing High/Low point - pure data, no GUI. Mirrors CBarPattern's  |
//| shape (CBaseObj + property arrays + Compare/IsEqual for          |
//| CArrayObj::Sort/Search/InsertSort) so it plugs into the same     |
//| Table/Row conventions already used for CBarPattern.               |
//| 1 instance = 1 confirmed Swing point (High or Low).               |
//+------------------------------------------------------------------+
#ifndef __BARSWING_MQH__
#define __BARSWING_MQH__
#property strict
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "..\..\Entities\Bases\BaseObj.mqh"
#include "..\..\Entities\Bar.mqh"
#include "..\..\Entities\Defines\SwingDefines.mqh"

#ifndef CBARSWING_MQH_DECLARATION
#define CBARSWING_MQH_DECLARATION
class CBarSwing : public CBaseObj
 {
   private:
      CBar     *m_bar_swing;                                                          // Pointer to the pivot bar this Swing is formed on
      long      m_long_prop[SWING_PROP_INTEGER_TOTAL];                                 // Integer properties
      double    m_double_prop[SWING_PROP_DOUBLE_TOTAL];                                // Real properties
      string    m_string_prop[SWING_PROP_STRING_TOTAL];                                // String properties
      int       IndexProp(ENUM_SWING_PROP_DOUBLE property) const { return (int)property-SWING_PROP_INTEGER_TOTAL; }
      int       IndexProp(ENUM_SWING_PROP_STRING property) const { return (int)property-SWING_PROP_INTEGER_TOTAL-SWING_PROP_DOUBLE_TOTAL; }
   public:
   //--- Set (1) integer, (2) real and (3) string swing properties
      void      SetProperty(ENUM_SWING_PROP_INTEGER property, long value)   { this.m_long_prop[property] = value; }
      void      SetProperty(ENUM_SWING_PROP_DOUBLE  property, double value) { this.m_double_prop[this.IndexProp(property)] = value; }
      void      SetProperty(ENUM_SWING_PROP_STRING  property, string value) { this.m_string_prop[this.IndexProp(property)] = value; }
   //--- Return (1) integer, (2) real and (3) string swing properties
      long      GetProperty(ENUM_SWING_PROP_INTEGER property) const { return this.m_long_prop[property]; }
      double    GetProperty(ENUM_SWING_PROP_DOUBLE  property) const { return this.m_double_prop[this.IndexProp(property)]; }
      string    GetProperty(ENUM_SWING_PROP_STRING  property) const { return this.m_string_prop[this.IndexProp(property)]; }
   //--- Return itself
      CBarSwing *GetObject(void) { return &this; }
   //--- Compare CBarSwing objects by a specified property (for CArrayObj::Sort/Search/InsertSort)
      virtual int Compare(const CObject *node, const int mode=0) const;
   //--- Compare CBarSwing objects by ALL properties (search equal swing objects)
      bool      IsEqual(CBarSwing *compared_obj) const;
   //--- Constructors/Destructor
                CBarSwing(void) { this.m_type = OBJECT_DE_TYPE_SERIES_SWING; m_bar_swing = NULL; }
                CBarSwing(const ENUM_SWING_TYPE type, const string symbol, const ENUM_TIMEFRAMES timeframe,
                          const datetime pivot_time, const datetime confirmed_time, const double price,
                          const int strength, const ENUM_SWING_PRICE_BASIS basis);
               ~CBarSwing(void) {}
   //--- Return (1) type (High/Low), (2) timeframe, (3) unique code, (4) pivot bar time,
   //--- (5) confirmation time, (6) strength (N) used to detect it, (7) price basis (Wick/Body)
      ENUM_SWING_TYPE         TypeSwing(void)     const { return (ENUM_SWING_TYPE)this.GetProperty(SWING_PROP_TYPE); }              // High or Low
      ENUM_TIMEFRAMES         Timeframe(void)      const { return (ENUM_TIMEFRAMES)this.GetProperty(SWING_PROP_PERIOD); }            // Swing's own timeframe
      ulong                   Code(void)          const { return (ulong)this.GetProperty(SWING_PROP_CODE); }                        // Primary Key - time+type+period+symbol
      datetime                Time(void)          const { return (datetime)this.GetProperty(SWING_PROP_TIME); }                     // Pivot bar time (FK to CBar)
      datetime                ConfirmedTime(void) const { return (datetime)this.GetProperty(SWING_PROP_CONFIRMED_TIME); }           // Pivot time + Strength periods
      int                     Strength(void)      const { return (int)this.GetProperty(SWING_PROP_STRENGTH); }                      // N (left/right bars) used at detection time
      ENUM_SWING_PRICE_BASIS  PriceBasis(void)    const { return (ENUM_SWING_PRICE_BASIS)this.GetProperty(SWING_PROP_PRICE_BASIS); } // Wick or Body used at detection time
   //--- Get/set the HH/LH/HL/LL classification vs the last CONFIRMED Swing of the same type
      ENUM_SWING_STRUCTURE    Structure(void)      const { return (ENUM_SWING_STRUCTURE)this.GetProperty(SWING_PROP_STRUCTURE); }
      void                    Structure(const ENUM_SWING_STRUCTURE structure) { this.SetProperty(SWING_PROP_STRUCTURE, structure); }
   //--- Return (1) the swing's High/Low price, (2) its symbol
      double                  Price(void)         const { return this.GetProperty(SWING_PROP_PRICE); }
      string                  Symbol(void)        const { return this.GetProperty(SWING_PROP_SYMBOL); }
   //--- Set/return the pointer to the pivot bar
      void                    SetSwingBar(CBar *bar) { this.m_bar_swing = bar; }
      CBar                   *SwingBar(void)   const { return this.m_bar_swing; }
 };
#endif // CBARSWING_MQH_DECLARATION
#ifndef CBARSWING_MQH_IMPLEMENTATION
#define CBARSWING_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Parametric constructor - computes the unique code (Primary Key)  |
//| from time+type+period+symbol, mirroring CBarPattern's own code   |
//| formula.                                                          |
//+------------------------------------------------------------------+
CBarSwing::CBarSwing(const ENUM_SWING_TYPE type, const string symbol, const ENUM_TIMEFRAMES timeframe,
                      const datetime pivot_time, const datetime confirmed_time, const double price,
                      const int strength, const ENUM_SWING_PRICE_BASIS basis)
 {
   this.m_type = OBJECT_DE_TYPE_SERIES_SWING;
   this.m_bar_swing = NULL;
   ulong symbol_code = 0;
   for(int i = 0; i < (int)StringLen(symbol); i++)
      symbol_code += (ulong)StringGetCharacter(symbol, i);
   ulong code = (ulong)pivot_time + (ulong)type + (ulong)timeframe + symbol_code;
   this.SetProperty(SWING_PROP_CODE,           (long)code);
   this.SetProperty(SWING_PROP_TIME,           pivot_time);
   this.SetProperty(SWING_PROP_CONFIRMED_TIME, confirmed_time);
   this.SetProperty(SWING_PROP_TYPE,           type);
   this.SetProperty(SWING_PROP_PERIOD,         timeframe);
   this.SetProperty(SWING_PROP_STRENGTH,       strength);
   this.SetProperty(SWING_PROP_PRICE_BASIS,    basis);
   this.SetProperty(SWING_PROP_STRUCTURE,      SWING_STRUCTURE_NONE);
   this.SetProperty(SWING_PROP_PRICE,          price);
   this.SetProperty(SWING_PROP_SYMBOL,         symbol);
 }
//+------------------------------------------------------------------+
//| Compare CBarSwing objects with each other by the specified       |
//| property                                                          |
//+------------------------------------------------------------------+
int CBarSwing::Compare(const CObject *node, const int mode=0) const
 {
   const CBarSwing *obj_compared = node;
   if(mode < SWING_PROP_INTEGER_TOTAL)
    {
      long value_compared = obj_compared.GetProperty((ENUM_SWING_PROP_INTEGER)mode);
      long value_current  = this.GetProperty((ENUM_SWING_PROP_INTEGER)mode);
      return(value_current > value_compared ? 1 : value_current < value_compared ? -1 : 0);
    }
   else if(mode < SWING_PROP_DOUBLE_TOTAL+SWING_PROP_INTEGER_TOTAL)
    {
      double value_compared = obj_compared.GetProperty((ENUM_SWING_PROP_DOUBLE)mode);
      double value_current  = this.GetProperty((ENUM_SWING_PROP_DOUBLE)mode);
      return(value_current > value_compared ? 1 : value_current < value_compared ? -1 : 0);
    }
   else if(mode < SWING_PROP_DOUBLE_TOTAL+SWING_PROP_INTEGER_TOTAL+SWING_PROP_STRING_TOTAL)
    {
      string value_compared = obj_compared.GetProperty((ENUM_SWING_PROP_STRING)mode);
      string value_current  = this.GetProperty((ENUM_SWING_PROP_STRING)mode);
      return(value_current > value_compared ? 1 : value_current < value_compared ? -1 : 0);
    }
   return 0;
 }
//+------------------------------------------------------------------+
//| Compare CBarSwing objects with each other by ALL properties      |
//+------------------------------------------------------------------+
bool CBarSwing::IsEqual(CBarSwing *compared_obj) const
 {
   int begin = 0, end = SWING_PROP_INTEGER_TOTAL;
   for(int i = begin; i < end; i++)
    {
      ENUM_SWING_PROP_INTEGER prop = (ENUM_SWING_PROP_INTEGER)i;
      if(this.GetProperty(prop) != compared_obj.GetProperty(prop)) return false;
    }
   begin = end; end += SWING_PROP_DOUBLE_TOTAL;
   for(int i = begin; i < end; i++)
    {
      ENUM_SWING_PROP_DOUBLE prop = (ENUM_SWING_PROP_DOUBLE)i;
      if(this.GetProperty(prop) != compared_obj.GetProperty(prop)) return false;
    }
   begin = end; end += SWING_PROP_STRING_TOTAL;
   for(int i = begin; i < end; i++)
    {
      ENUM_SWING_PROP_STRING prop = (ENUM_SWING_PROP_STRING)i;
      if(this.GetProperty(prop) != compared_obj.GetProperty(prop)) return false;
    }
   return true;
 }
#endif // CBARSWING_MQH_IMPLEMENTATION
#endif // __BARSWING_MQH__
