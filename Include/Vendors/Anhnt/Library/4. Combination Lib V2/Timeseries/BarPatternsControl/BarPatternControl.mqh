//+------------------------------------------------------------------+
//|                                              PatternControl.mqh  |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                     https://mql5.com/en/users/artmedia70         |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
// Pure data only — GUI code removed (chart fields, Draw/Redraw calls).
// CPattern changed to CBarPattern throughout.
//+------------------------------------------------------------------+
//| Abstract pattern management class                                |
//+------------------------------------------------------------------+
#ifndef __BARPATTERNCONTROL_MQH__
#define __BARPATTERNCONTROL_MQH__
#include "..\..\Entities\Defines\EventDefines.mqh"
//--- First link off SIGNAL_EVENTS_NEXT_CODE; the Manager chains continue from BARPATTERN_CONTROL_EVENTS_NEXT_CODE
enum ENUM_BARPATTERN_CONTROL_EVENT
 {
  BARPATTERN_CONTROL_EVENT_NO_EVENT = SIGNAL_EVENTS_NEXT_CODE,
  BARPATTERN_CONTROL_EVENT_BUYSELL_CHANGED, // this control's Buy or Sell signal setting was toggled
 };
#define BARPATTERN_CONTROL_EVENTS_NEXT_CODE (BARPATTERN_CONTROL_EVENT_BUYSELL_CHANGED+1)  // The code of the next event after the last BarPatternControl event code
//+------------------------------------------------------------------+
//| Shared default detection thresholds for all pattern controls     |
//| Each control uses these as defaults; EA can override via params. |
//+------------------------------------------------------------------+
   //--- Body ratios
    #define PATTERN_DEF_LARGE_BODY                   60.0   // min body ratio: "large" candle (Morning Star bar0, Harami bar0, etc.)
    #define PATTERN_DEF_SMALL_BODY                   35.0   // max body ratio: "small" candle (Hammer, InvertedHammer, PinBar)
    #define PATTERN_DEF_DOJI_BODY                    5.0    // max body ratio: Doji (and Doji variants)
    #define PATTERN_DEF_SPINNING_TOP_BODY             35.0   // max body ratio: Spinning Top (small body)
    #define PATTERN_DEF_SPINNING_TOP_SHADOW           25.0   // min ratio EACH shadow must reach: Spinning Top (both roughly balanced)
    #define PATTERN_DEF_MARUBOZU_BODY                 90.0   // min body ratio: Marubozu (little/no shadow either side)
    #define PATTERN_DEF_INNER_BODY                   30.0   // max body ratio: inner candle (Harami bar1, Three Inside bar1)
   //--- Shadow ratios
    #define PATTERN_DEF_LONG_SHADOW                  55.0   // min shadow ratio: long shadow (Hammer lower, InvertedHammer upper)
    #define PATTERN_DEF_SHORT_SHADOW                 10.0   // max shadow ratio: short shadow (opposite side of Hammer/PinBar)
    #define PATTERN_DEF_DEEP_SHADOW                  70.0   // min shadow ratio: very long shadow (Dragonfly/Gravestone Doji)
   //--- Multi-candle thresholds
    #define PATTERN_DEF_PENETRATION                  50.0   // min penetration into body (Morning Star bar2, Piercing Line bar1)
    #define PATTERN_DEF_SIMILARITY                   70.0   // min body size similarity ratio (Rails)
    //--- Misc
    #define PATTERN_DEF_TWEEZER_PTS                  5      // max High/Low difference in points (Tweezer)
   //For Outside Bar
    #define PATTERN_DEF_OUTSIDE_BAR_MIN_BODY_SIZE    0      // OutsideBar param[0]
    #define PATTERN_DEF_OUTSIDE_BAR_RATIO_CANDLES    50.0   // OutsideBar param[1]
    #define PATTERN_DEF_OUTSIDE_BAR_RATIO_BODY       50.0   // OutsideBar param[2]
   //For Inside Bar
    #define PATTERN_DEF_INSIDE_BAR_MIN_BODY_SIZE     0      // InsideBar param[0]
    // #define PATTERN_DEF_INSIDE_BAR_RATIO_CANDLES  50.0   // InsideBar param[1]
    // #define PATTERN_DEF_INSIDE_BAR_RATIO_BODY     50.0   // InsideBar param[2]
   //For PinBar
    //#define PATTERN_DEF_PINBAR_BODY                  30.0   // PinBar param[0]
    #define PATTERN_DEF_PINBAR_MIN_BODY_SIZE         0      // PinBar param[0]
    #define PATTERN_DEF_PINBAR_RATIO_BODY            30.0   // PinBar param[1]
    #define PATTERN_DEF_PINBAR_LARGER_SHADOW         60.0   // PinBar param[2]
    #define PATTERN_DEF_PINBAR_SMALLER_SHADOW        30.0   // PinBar param[3]
   //For Pivot Point Reversal
    //#define PATTERN_DEF_PPR_MIN_BODY_SIZE            30     // PivotPointReversal param[0] 30 Point not 30%
    #define PATTERN_DEF_PPR_RATIO_CANDLE_SIZE         20.0   // PivotPointReversal param[0] - min % of bar1's own High-Low range
 //+------------------------------------------------------------------+
 //| Include Custom files                                             |
 //+------------------------------------------------------------------+
  #include "..\..\Services\Select\TimeseriesSelect.mqh"
  #include "..\BarSeries\NewBarObj.mqh"
  #include "..\..\Entities\Bar.mqh"
  #include "..\BarPatternsSeries\BarPattern.mqh"
  #include "..\..\Entities\Bases\BaseObjExt.mqh"
 #ifndef CBarPatternControl_MQH_DECLARATION
 #define CBarPatternControl_MQH_DECLARATION
class CBarPatternControl : public CBaseObjExt
  {
   private:
      ENUM_TIMEFRAMES             m_timeframe;                           // Pattern timeseries chart period
      string                      m_symbol;                              // Pattern timeseries symbol
      double                      m_point;                               // Symbol Point
      bool                        m_used;                                // Pattern use flag
    //--- Handled pattern
      ENUM_PATTERN_TYPE           m_type_pattern;                        // Pattern type
      bool                        m_buy_signal;                          // opt-in: count this pattern's Buy into the Signal Bridge
      bool                        m_sell_signal;                         // opt-in: count this pattern's Sell into the Signal Bridge
      bool                        m_sound_alert;
      bool                        m_message_alert;
   protected:
    //--- Candle proportions
      double                      m_ratio_body_to_candle_size;           // Percentage ratio of candle body to full candle size
      double                      m_ratio_larger_shadow_to_candle_size;  // Percentage ratio of the larger shadow to candle size
      double                      m_ratio_smaller_shadow_to_candle_size; // Percentage ratio of the smaller shadow to candle size
      double                      m_ratio_candle_sizes;                  // Percentage of candle sizes
      uint                        m_min_body_size;                       // Minimum size of the candlestick body
      ulong                       m_object_id;                           // Unique object code based on pattern search criteria
    //--- List views
      CArrayObj                  *m_list_series;                         // Pointer to the timeseries list
      CArrayObj                  *m_list_all_patterns;                   // Pointer to the list of all patterns
      CBarPattern                 m_pattern_instance;                    // Pattern object for searching by property
    //--- Symbol code
      ulong                       m_symbol_code;                         // Chart symbol name as a number
    //--- Pattern search, creation, code and managed-pattern list
      virtual CBarPattern        *CreatePattern(const ENUM_PATTERN_DIRECTION direction, const uint id, CBar *bar) { return NULL; }
      virtual ulong               GetPatternCode(const ENUM_PATTERN_DIRECTION direction, const datetime time) const { return 0; }
      virtual CArrayObj          *GetListPatterns(void) { return NULL; }       
    //--- Create object ID based on pattern search criteria
      virtual ulong               CreateObjectID(void)  { return 0; }
    //--- Write bar data to the rates structure
      void                        SetBarData(CBar *bar, MqlRates &rates) const;
    //--- Variant subclass built via a sibling's constructor (HangingMan -> Hammer) restores its own type
      void                        SetTypePattern(const ENUM_PATTERN_TYPE type) { this.m_type_pattern = type; }
    //--- Protected parametric constructor
                                  CBarPatternControl(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                  const ENUM_PATTERN_STATUS status, const ENUM_PATTERN_TYPE type,
                                                  CArrayObj *list_series, CArrayObj *list_patterns,
                                                  const MqlParam &param[]);
   public:
      MqlParam                    PatternParams[];                        // Array of pattern parameters
    //--- Return itself
      CBarPatternControl         *GetObject(void)                        { return &this; } 
      uint                        Candles(void) const                     { return m_pattern_instance.Candles(); }
    //--- (1) Set and (2) return the pattern usage flag
      void                        SetUsed(const bool flag)               { this.m_used=flag; }
      bool                        IsUsed(void) const                     { return this.m_used; } 
    //--- Signal Bridge opt-in
      bool                        BuySignal(void) const                  { return this.m_buy_signal; }
      void                        BuySignal(const bool v)                { if(this.m_buy_signal==v) return; this.m_buy_signal=v; ::EventChartCustom(::ChartID(), (ushort)BARPATTERN_CONTROL_EVENT_BUYSELL_CHANGED, 0, 0.0, ""); }
      bool                        SellSignal(void) const                 { return this.m_sell_signal; }
      void                        SellSignal(const bool v)               { if(this.m_sell_signal==v) return; this.m_sell_signal=v; ::EventChartCustom(::ChartID(), (ushort)BARPATTERN_CONTROL_EVENT_BUYSELL_CHANGED, 0, 0.0, ""); }
      bool                        SoundAlert(void) const                 { return this.m_sound_alert; }
      void                        SoundAlert(const bool v)               { this.m_sound_alert=v; }
      bool                        MessageAlert(void) const               { return this.m_message_alert; }
      void                        MessageAlert(const bool v)             { this.m_message_alert=v; }
    //--- Set the necessary percentage ratios                                
      void                        SetRatioBodyToCandleSizeValue(const double value)              { this.m_ratio_body_to_candle_size=value; }
      void                        SetRatioLargerShadowToCandleSizeValue(const double value)      { this.m_ratio_larger_shadow_to_candle_size=value; }
      void                        SetRatioSmallerShadowToCandleSizeValue(const double value)      { this.m_ratio_smaller_shadow_to_candle_size=value; }
      void                        SetRatioCandleSizeValue(const double value)                     { this.m_ratio_candle_sizes=value; }
      void                        SetMinBodySize(const uint value)                                { this.m_min_body_size=value; }    
    //--- Return the necessary percentage ratios
      double                      RatioBodyToCandleSizeValue(void) const                          { return this.m_ratio_body_to_candle_size; }
      double                      RatioLargerShadowToCandleSizeValue(void) const                  { return this.m_ratio_larger_shadow_to_candle_size; }
      double                      RatioSmallerShadowToCandleSizeValue(void) const                 { return this.m_ratio_smaller_shadow_to_candle_size; }
      double                      RatioCandleSizeValue(void) const                                { return this.m_ratio_candle_sizes; }
      int                         MinBodySize(void) const                                         { return (int)this.m_min_body_size; }
    //--- Return object ID based on pattern search criteria      
      virtual ulong               ObjectID(void) const                                            { return this.m_object_id; }    
    //--- Return pattern (1) type, (2) timeframe, (3) symbol, (4) symbol Point, (5) symbol code
      ENUM_PATTERN_TYPE           TypePattern(void) const                                    { return this.m_type_pattern; }
      ENUM_TIMEFRAMES             Timeframe(void) const                                      { return this.m_timeframe; }
      string                      Symbol(void) const                                         { return this.m_symbol; }
      double                      Point(void) const                                          { return this.m_point; }
      ulong                       SymbolCode(void) const                                     { return this.m_symbol_code; }
    //--- Compare CBarPatternControl objects by all possible properties
      virtual int                 Compare(const CObject *node, const int mode=0) const;
    //--- Search for patterns and add found ones to the list of all patterns
      virtual int                 CreateAndRefreshPatternList(void);
    //--- Incremental scan: only last n_bars bars (for new bar event)
      virtual int                 UpdatePatternList(const int n_bars = 4);    
    //--- index = position of the pattern's last bar in the time-sorted m_list_series
     virtual ENUM_PATTERN_DIRECTION FindPattern(const int index, MqlRates &mother_bar_data) const { return WRONG_VALUE; }


  };
 #endif // CBarPatternControl_MQH_DECLARATION
 #ifndef CBarPatternControl_MQH_IMPLEMENTATION
 #define CBarPatternControl_MQH_IMPLEMENTATION  
  //+------------------------------------------------------------------+
  //| Write bar data to the rates structure                            |
  //+------------------------------------------------------------------+
  void CBarPatternControl::SetBarData(CBar *bar, MqlRates &rates) const
   {
      if(bar==NULL) return;
      rates.open  = bar.Open();
      rates.high  = bar.High();
      rates.low   = bar.Low();
      rates.close = bar.Close();
      rates.time  = bar.Time();
   }     
  //+------------------------------------------------------------------+
  //| Protected parametric constructor                                 |
  //+------------------------------------------------------------------+
  CBarPatternControl::CBarPatternControl(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                  const ENUM_PATTERN_STATUS status, const ENUM_PATTERN_TYPE type,
                                  CArrayObj *list_series, CArrayObj *list_patterns,
                                  const MqlParam &param[]) :
   m_used(true), m_buy_signal(true), m_sell_signal(true), m_sound_alert(true), m_message_alert(true)
   {
      this.m_type              = OBJECT_DE_TYPE_SERIES_PATTERN_CONTROL;
      this.m_type_pattern      = type;
      //--- Candle count is fixed per pattern type, so Candles() works before any detection
      int candles = 3; // default: 3-candle (Triple) formation
      if(type==PATTERN_TYPE_SHOOTING_STAR || type==PATTERN_TYPE_HAMMER || type==PATTERN_TYPE_INVERTED_HAMMER ||
         type==PATTERN_TYPE_HANGING_MAN   || type==PATTERN_TYPE_DOJI   || type==PATTERN_TYPE_DRAGONFLY_DOJI  ||
         type==PATTERN_TYPE_GRAVESTONE_DOJI || type==PATTERN_TYPE_PIN_BAR ||
         type==PATTERN_TYPE_SPINNING_TOP     || type==PATTERN_TYPE_MARUBOZU)
        candles = 1; // Single Candlestick
      else if(type==PATTERN_TYPE_HARAMI || type==PATTERN_TYPE_HARAMI_CROSS || type==PATTERN_TYPE_TWEEZER ||
              type==PATTERN_TYPE_PIERCING_LINE || type==PATTERN_TYPE_DARK_CLOUD_COVER || type==PATTERN_TYPE_ENGULFING ||
              type==PATTERN_TYPE_OUTSIDE_BAR   || type==PATTERN_TYPE_INSIDE_BAR       || type==PATTERN_TYPE_RAILS)
        candles = 2; // Double Candlestick
      this.m_pattern_instance.SetProperty(PATTERN_PROP_CANDLES, candles);
      this.m_symbol            = (symbol==NULL || symbol=="" ? ::Symbol() : symbol);
      this.m_timeframe         = (timeframe==PERIOD_CURRENT ? ::Period() : timeframe);
      this.m_point             = ::SymbolInfoDouble(this.m_symbol, SYMBOL_POINT);
      this.m_object_id         = 0;
      this.m_list_series       = list_series;
      this.m_list_all_patterns = list_patterns;
      for(int i=0; i<(int)this.m_symbol.Length(); i++)
            this.m_symbol_code += this.m_symbol.GetChar(i);
      int count=::ArrayResize(this.PatternParams, ::ArraySize(param));
      for(int i=0; i<count; i++)
      {
         this.PatternParams[i].type          = param[i].type;
         this.PatternParams[i].double_value  = param[i].double_value;
         this.PatternParams[i].integer_value = param[i].integer_value;
         this.PatternParams[i].string_value  = param[i].string_value;
      }
   }
  //+------------------------------------------------------------------+
  //| Compare CBarPatternControl objects by all possible properties    |
  //+------------------------------------------------------------------+
  int CBarPatternControl::Compare(const CObject *node, const int mode=0) const
   {
      const CBarPatternControl *obj_compared=node;
      return
      (
         this.SymbolCode()  > obj_compared.SymbolCode()  ||
         this.Timeframe()   > obj_compared.Timeframe()   ||
         this.TypePattern() > obj_compared.TypePattern() ||
         this.ObjectID()    > obj_compared.ObjectID()    ? 1  :
         this.SymbolCode()  < obj_compared.SymbolCode()  ||
         this.Timeframe()   < obj_compared.Timeframe()   ||
         this.TypePattern() < obj_compared.TypePattern() ||
         this.ObjectID()    < obj_compared.ObjectID()    ? -1 :
         0
      );
   }
  //+------------------------------------------------------------------+
  //| Search for patterns and add found ones to the list               |
  //+------------------------------------------------------------------+
  int CBarPatternControl::CreateAndRefreshPatternList(void)
   {
      if(!this.m_used || this.m_list_series==NULL)
            return 0;
      this.m_is_event=false;
      this.m_list_events.Clear();
      datetime time_open=0;
      if(!::SeriesInfoInteger(this.Symbol(), this.Timeframe(), SERIES_LASTBAR_DATE, time_open))
            return 0;
      MqlRates pattern_mother_bar_data={};
      this.m_list_series.Sort(SORT_BY_BAR_TIME);
      for(int i=this.m_list_series.Total()-1; i>=0; i--)
        {
          CBar *bar=this.m_list_series.At(i);
          if(bar==NULL || bar.Time()>=time_open)
                continue;
          ENUM_PATTERN_DIRECTION direction=this.FindPattern(i, pattern_mother_bar_data);
          if(direction==WRONG_VALUE)
                continue;
          ulong code=this.GetPatternCode(direction, bar.Time());
          this.m_pattern_instance.SetProperty(PATTERN_PROP_CODE, code);
          this.m_list_all_patterns.Sort(SORT_BY_PATTERN_CODE);
          int index=this.m_list_all_patterns.Search(&this.m_pattern_instance);
          if(index==WRONG_VALUE)
          {
              CBarPattern *pattern=this.CreatePattern(direction, this.m_list_all_patterns.Total(), bar);
              if(pattern==NULL)
                    continue;
              this.m_list_all_patterns.Sort(SORT_BY_PATTERN_TIME);
              if(!this.m_list_all_patterns.InsertSort(pattern))
                {
                  delete pattern;
                  continue;
                }
              bar.AddPatternType(pattern.TypePattern());
              pattern.SetPatternBar(bar);
              pattern.SetMotherBarData(pattern_mother_bar_data);
              datetime time_prev=time_open-::PeriodSeconds(this.Timeframe());
              if(bar.Time()==time_prev)
              {
                // Here is where the message is created and sent
              }
          }
        }
      this.m_list_all_patterns.Sort(SORT_BY_PATTERN_TIME);
      return m_list_all_patterns.Total();
   }
  //+------------------------------------------------------------------+
  //| Incremental scan: only last n_bars bars (for new bar event)     |
  //+------------------------------------------------------------------+
  int CBarPatternControl::UpdatePatternList(const int n_bars = 4)
    {
          if(!this.m_used || this.m_list_series == NULL) return 0;
          datetime   time_open = 0;
          if(!::SeriesInfoInteger(this.Symbol(), this.Timeframe(), SERIES_LASTBAR_DATE, time_open))
                      return 0;
          datetime   t_cutoff = time_open - (datetime)(n_bars * ::PeriodSeconds(this.Timeframe()));
          MqlRates   pattern_mother_bar_data = {};
          this.m_list_series.Sort(SORT_BY_BAR_TIME);
          for(int i = this.m_list_series.Total() - 1; i >= 0; i--)
          {
                CBar *bar = this.m_list_series.At(i);
                if(bar == NULL || bar.Time() >= time_open) continue;
                if(bar.Time() < t_cutoff) break;
                ENUM_PATTERN_DIRECTION direction = this.FindPattern(i, pattern_mother_bar_data);
                if(direction == WRONG_VALUE) continue;
                ulong code = this.GetPatternCode(direction, bar.Time());
                this.m_pattern_instance.SetProperty(PATTERN_PROP_CODE, code);
                this.m_list_all_patterns.Sort(SORT_BY_PATTERN_CODE);
                if(this.m_list_all_patterns.Search(&this.m_pattern_instance) != WRONG_VALUE)
                      continue;
                CBarPattern *pattern = this.CreatePattern(direction, this.m_list_all_patterns.Total(), bar);
                if(pattern == NULL) continue;
                this.m_list_all_patterns.Sort(SORT_BY_PATTERN_TIME);
                if(!this.m_list_all_patterns.InsertSort(pattern)) { delete pattern; continue; }
                bar.AddPatternType(pattern.TypePattern());
                pattern.SetPatternBar(bar);
                pattern.SetMotherBarData(pattern_mother_bar_data);
          }
          this.m_list_all_patterns.Sort(SORT_BY_PATTERN_TIME);
          return m_list_all_patterns.Total();
    }
  #endif // CBarPatternControl_MQH_IMPLEMENTATION
#endif // __BARPATTERNCONTROL_MQH__
