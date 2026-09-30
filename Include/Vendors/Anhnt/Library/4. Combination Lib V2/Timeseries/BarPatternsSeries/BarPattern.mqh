//+------------------------------------------------------------------+
//|                                                      Pattern.mqh |
//|                        Copyright 2023, MetaQuotes Ltd.           |
//|                               https://www.mql5.com               |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Abstract bar pattern class — pure data, no GUI                   |
//+------------------------------------------------------------------+
// Pure data only — GUI code removed from original DoEasy Pattern.
// CPattern renamed to CBarPattern.
//   Removed: CForm, color fields, chart size fields,
//             all Draw/Show/Hide/InfoPanel/SetChart methods.
// Original source: DoEasy article series (Artyom Trishkin, mql5.com)
#ifndef __BARPATTERN_MQH__
#define __BARPATTERN_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                     |
 //+------------------------------------------------------------------+
   #include "..\..\Entities\Bases\BaseObj.mqh"
   #include "..\..\Entities\Bar.mqh"
   #include "..\..\Entities\Defines\TimeseriesDefines.mqh"
 #ifndef CBARPATTERN_MQH_DECLARATION
 #define CBARPATTERN_MQH_DECLARATION   
  class CBarPattern : public CBaseObj
   {
    private:
     CBar                       *m_bar_pattern;                                        // Pointer to the bar the pattern is formed on
     MqlRates                    m_mother_bar_prop;                                    // "Mother" bar parameters
     long                        m_long_prop[PATTERN_PROP_INTEGER_TOTAL];              // Integer properties
     double                      m_double_prop[PATTERN_PROP_DOUBLE_TOTAL];             // Real properties
     string                      m_string_prop[PATTERN_PROP_STRING_TOTAL];             // String properties   
      int                         IndexProp(ENUM_PATTERN_PROP_DOUBLE property) const   { return(int)property-PATTERN_PROP_INTEGER_TOTAL; }
      int                         IndexProp(ENUM_PATTERN_PROP_STRING property) const   { return(int)property-PATTERN_PROP_INTEGER_TOTAL-PATTERN_PROP_DOUBLE_TOTAL; }
    protected:
     ulong                       m_symbol_code;                                        // Symbol as a number (sum of name symbol codes)
     int                         m_bars_formation;                                     // Number of bars in the formation (nested pattern)
    public:
     //--- Set pattern (1) integer, (2) real and (3) string properties
      void                        SetProperty(ENUM_PATTERN_PROP_INTEGER property, long value)   { this.m_long_prop[property]=value; }
      void                        SetProperty(ENUM_PATTERN_PROP_DOUBLE  property, double value) { this.m_double_prop[this.IndexProp(property)]=value; }
      void                        SetProperty(ENUM_PATTERN_PROP_STRING  property, string value) { this.m_string_prop[this.IndexProp(property)]=value; }
     //--- Return (1) integer, (2) real and (3) string pattern properties from the property array
      long                        GetProperty(ENUM_PATTERN_PROP_INTEGER property) const { return this.m_long_prop[property]; }
      double                      GetProperty(ENUM_PATTERN_PROP_DOUBLE  property) const { return this.m_double_prop[this.IndexProp(property)]; }
      string                      GetProperty(ENUM_PATTERN_PROP_STRING  property) const { return this.m_string_prop[this.IndexProp(property)]; }
     //--- Return the flag of the pattern supporting the specified property
      virtual bool                SupportProperty(ENUM_PATTERN_PROP_INTEGER property)  { return true; }
      virtual bool                SupportProperty(ENUM_PATTERN_PROP_DOUBLE  property)  { return true; }
      virtual bool                SupportProperty(ENUM_PATTERN_PROP_STRING  property)  { return true; }
     //--- Return itself
      CBarPattern                *GetObject(void)                                       { return &this; }      
     //--- Compare CBarPattern objects by all possible properties (for sorting the lists by a specified pattern object property)
      virtual int                 Compare(const CObject *node, const int mode=0) const;
     //--- Compare CBarPattern objects with each other by all properties (to search equal pattern objects)
      bool                        IsEqual(CBarPattern *compared_obj) const;
     //--- Constructors/Destructor
               CBarPattern() { this.m_type = OBJECT_DE_TYPE_SERIES_PATTERN; }
               ~CBarPattern(void);
    protected:
      //--- Protected parametric constructor
                                 CBarPattern(const ENUM_PATTERN_STATUS    status,
                                             const ENUM_PATTERN_TYPE      type,
                                             const uint                   id,
                                             const ENUM_PATTERN_DIRECTION direction,
                                             const string                 symbol,
                                             const ENUM_TIMEFRAMES        timeframe, MqlRates &rates);
    public:
     //+------------------------------------------------------------------+
     //| Methods of a simplified access to the pattern object properties  |
     //+------------------------------------------------------------------+
     //--- Return (1) type, (2) direction, (3) period, (4) status,
     //--- (5) code, (6) pattern defining bar time,
     //--- (7) number of candles forming the pattern
      ENUM_PATTERN_TYPE           TypePattern(void)     const { return (ENUM_PATTERN_TYPE)this.GetProperty(PATTERN_PROP_TYPE); }
      ENUM_PATTERN_DIRECTION      Direction(void)       const { return (ENUM_PATTERN_DIRECTION)this.GetProperty(PATTERN_PROP_DIRECTION); }
      ENUM_TIMEFRAMES             Timeframe(void)       const { return (ENUM_TIMEFRAMES)this.GetProperty(PATTERN_PROP_PERIOD); }
      ENUM_PATTERN_STATUS         Status(void)          const { return (ENUM_PATTERN_STATUS)this.GetProperty(PATTERN_PROP_STATUS); }
      ulong                       Code(void)            const { return this.GetProperty(PATTERN_PROP_CODE); }
      uint                        ID(void)              const { return (uint)this.GetProperty(PATTERN_PROP_ID); }
      ulong                       ControlObjectID(void) const { return this.GetProperty(PATTERN_PROP_CTRL_OBJ_ID); }
      datetime                    Time(void)            const { return (datetime)this.GetProperty(PATTERN_PROP_TIME); }
      uint                        Candles(void)         const { return (uint)this.GetProperty(PATTERN_PROP_CANDLES); }
     //--- Return pattern defining bar prices
      double                      BarPriceOpen(void)    const { return this.GetProperty(PATTERN_PROP_BAR_PRICE_OPEN); }
      double                      BarPriceHigh(void)    const { return this.GetProperty(PATTERN_PROP_BAR_PRICE_HIGH); }
      double                      BarPriceLow(void)     const { return this.GetProperty(PATTERN_PROP_BAR_PRICE_LOW); }
      double                      BarPriceClose(void)   const { return this.GetProperty(PATTERN_PROP_BAR_PRICE_CLOSE); }
     //--- Return pattern (1) symbol and (2) name
      string                      Symbol(void)          const { return this.GetProperty(PATTERN_PROP_SYMBOL); }
      string                      Name(void)            const { return this.GetProperty(PATTERN_PROP_NAME); }

     //--- Set the pointer to the (1) pattern bar, (2) "mother" bar data
      void                        SetPatternBar(CBar *bar)                  { this.m_bar_pattern=bar; }
      void                        SetMotherBarData(MqlRates &data);
     //--- Set the (1) "mother" bar OHLC and (2) the number of bars in nested formations
      void                        SetMotherBarOpen(const double open)       { this.m_mother_bar_prop.open=open; }
      void                        SetMotherBarHigh(const double high)       { this.m_mother_bar_prop.high=high; }
      void                        SetMotherBarLow(const double low)         { this.m_mother_bar_prop.low=low; }
      void                        SetMotherBarClose(const double close)     { this.m_mother_bar_prop.close=close; }
      void                        SetBarsInNestedFormations(const int bars) { this.m_bars_formation=bars; }

     //--- Return the pointer to the (1) pattern bar, (2) time, (3-6) "mother" bar OHLC and (7) the number of bars in nested formations
      CBar                       *PatternBar(void)             const { return this.m_bar_pattern; }
      datetime                    MotherBarTime(void)          const { return (datetime)this.GetProperty(PATTERN_PROP_MOTHERBAR_TIME); }
      double                      MotherBarOpen(void)          const { return this.m_mother_bar_prop.open; }
      double                      MotherBarHigh(void)          const { return this.m_mother_bar_prop.high; }
      double                      MotherBarLow(void)           const { return this.m_mother_bar_prop.low; }
      double                      MotherBarClose(void)         const { return this.m_mother_bar_prop.close; }
      int                         BarsInNestedFormations(void) const { return this.m_bars_formation; }

   };
 #endif // CBARPATTERN_MQH_DECLARATION
 #ifndef CBARPATTERN_MQH_IMPLEMENTATION
 #define CBARPATTERN_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CBarPattern::CBarPattern(const ENUM_PATTERN_STATUS    status,
                           const ENUM_PATTERN_TYPE      type,
                           const uint                   id,
                           const ENUM_PATTERN_DIRECTION direction,
                           const string                 symbol,
                           const ENUM_TIMEFRAMES        timeframe, MqlRates &rates)
   {
    //--- Set pattern object properties
      this.m_type=OBJECT_DE_TYPE_SERIES_PATTERN;
      this.SetProperty(PATTERN_PROP_STATUS,          status);
      this.SetProperty(PATTERN_PROP_TYPE,            type);
      this.SetProperty(PATTERN_PROP_ID,              id);
      this.SetProperty(PATTERN_PROP_DIRECTION,       direction);
      this.SetProperty(PATTERN_PROP_PERIOD,          timeframe);
      this.SetProperty(PATTERN_PROP_TIME,            rates.time);
      this.SetProperty(PATTERN_PROP_BAR_PRICE_OPEN,  rates.open);
      this.SetProperty(PATTERN_PROP_BAR_PRICE_HIGH,  rates.high);
      this.SetProperty(PATTERN_PROP_BAR_PRICE_LOW,   rates.low);
      this.SetProperty(PATTERN_PROP_BAR_PRICE_CLOSE, rates.close);
      this.SetProperty(PATTERN_PROP_SYMBOL,          symbol);
    //--- Create symbol code
      this.m_symbol_code=0;
      for(int i=0;i<(int)symbol.Length();i++)
            this.m_symbol_code+=symbol.GetChar(i);
    //--- Pattern code = defining bar time + type + status + pattern direction + timeframe + symbol code
      ulong code=(ulong)rates.time+type+status+direction+timeframe+this.m_symbol_code;
      this.SetProperty(PATTERN_PROP_CODE,code);
    //--- Init remaining data fields
      this.m_bars_formation=1;
   }
  //+------------------------------------------------------------------+
  //| Destructor                                                        |
  //+------------------------------------------------------------------+
  CBarPattern::~CBarPattern(void)
   {
   }
  //+------------------------------------------------------------------+
  //| Compare CBarPattern objects with each other by the specified      |
  //| property                                                          |
  //+------------------------------------------------------------------+
  int CBarPattern::Compare(const CObject *node, const int mode=0) const
   {
         const CBarPattern *obj_compared=node;
    //--- compare integer properties of two patterns
     if(mode<PATTERN_PROP_INTEGER_TOTAL)
      {
         long value_compared=obj_compared.GetProperty((ENUM_PATTERN_PROP_INTEGER)mode);
         long value_current=this.GetProperty((ENUM_PATTERN_PROP_INTEGER)mode);
         return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
    //--- compare real properties of two patterns
     else if(mode<PATTERN_PROP_DOUBLE_TOTAL+PATTERN_PROP_INTEGER_TOTAL)
      {
         double value_compared=obj_compared.GetProperty((ENUM_PATTERN_PROP_DOUBLE)mode);
         double value_current=this.GetProperty((ENUM_PATTERN_PROP_DOUBLE)mode);
         return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
    //--- compare string properties of two patterns
     else if(mode<PATTERN_PROP_DOUBLE_TOTAL+PATTERN_PROP_INTEGER_TOTAL+PATTERN_PROP_STRING_TOTAL)
      {
         string value_compared=obj_compared.GetProperty((ENUM_PATTERN_PROP_STRING)mode);
         string value_current=this.GetProperty((ENUM_PATTERN_PROP_STRING)mode);
         return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
         return 0;
   }
  //+------------------------------------------------------------------+
  //| Compare CBarPattern objects with each other by all properties    |
  //+------------------------------------------------------------------+
  bool CBarPattern::IsEqual(CBarPattern *compared_obj) const
   {
    int begin=0, end=PATTERN_PROP_INTEGER_TOTAL;
    for(int i=begin; i<end; i++)
     {
      ENUM_PATTERN_PROP_INTEGER prop=(ENUM_PATTERN_PROP_INTEGER)i;
      if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false;
     }
    begin=end; end+=PATTERN_PROP_DOUBLE_TOTAL;
    for(int i=begin; i<end; i++)
     {
      ENUM_PATTERN_PROP_DOUBLE prop=(ENUM_PATTERN_PROP_DOUBLE)i;
      if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false;
     }
    begin=end; end+=PATTERN_PROP_STRING_TOTAL;
    for(int i=begin; i<end; i++)
     {
      ENUM_PATTERN_PROP_STRING prop=(ENUM_PATTERN_PROP_STRING)i;
      if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false;
     }
      return true;
   }
  //+------------------------------------------------------------------+
  //| Set the "mother" bar data                                        |
  //+------------------------------------------------------------------+
  void CBarPattern::SetMotherBarData(MqlRates &data)
   {
    this.m_mother_bar_prop.open  = data.open;
    this.m_mother_bar_prop.high  = data.high;
    this.m_mother_bar_prop.low   = data.low;
    this.m_mother_bar_prop.close = data.close;
    this.m_mother_bar_prop.time  = data.time;
    this.SetProperty(PATTERN_PROP_MOTHERBAR_TIME,data.time);
   }
 #endif // CBARPATTERN_MQH_IMPLEMENTATION
#endif // __BARPATTERN_MQH__
