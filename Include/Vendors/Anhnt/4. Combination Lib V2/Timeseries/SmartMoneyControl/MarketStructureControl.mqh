//+------------------------------------------------------------------+
//|                                       MarketStructureControl.mqh |
//| BOS / CHoCH detection from the confirmed Swings (pure data, no   |
//| GUI). One instance per (Symbol, Timeframe), like CBarSwingControl|
//| which calls it whenever its Swings change.                       |
//|                                                                  |
//| Rule: candles are replayed oldest to newest. The reference levels|
//| are the latest CONFIRMED Swing High and the latest CONFIRMED     |
//| Swing Low. A candle that CLOSES beyond a reference level that was|
//| not broken yet breaks it, once: a High labelled HH or a Low      |
//| labelled LL = BOS (with the trend), a High labelled LH or a Low  |
//| labelled HL = CHoCH (against it). A Swing without a label gives  |
//| no event. A new Swing of the same type becomes the new reference.|
//+------------------------------------------------------------------+
#ifndef __MARKETSTRUCTURECONTROL_MQH__
#define __MARKETSTRUCTURECONTROL_MQH__
#property strict
#include <Arrays\ArrayObj.mqh>
#include "..\..\Entities\Bases\BaseObj.mqh"
#include "..\..\Entities\Bar.mqh"
#include "..\SmartMoney\BarSwingSeries.mqh"
#include "..\SmartMoney\MarketStructureSeries.mqh"

#ifndef CMARKETSTRUCTURECONTROL_MQH_DECLARATION
#define CMARKETSTRUCTURECONTROL_MQH_DECLARATION
class CMarketStructureControl : public CBaseObj
 {
   private:
      string                  m_symbol;                                                // Timeseries symbol
      ENUM_TIMEFRAMES         m_timeframe;                                             // Timeseries chart period
      CArrayObj              *m_list_series;                                           // CBarSeriesDE bars table - index 0 = oldest
      CArrayObj              *m_list_all_swings;                                       // Shared (multi-symbol) Swings table
      CArrayObj              *m_list_all_structures;                                   // Shared (multi-symbol) Market Structure table
      datetime                m_last_processed_time;                                   // Newest closed candle already replayed
      datetime                m_applied_swing_time;                                    // ConfirmedTime of the newest Swing already applied as a reference
      //--- Reference levels: the latest confirmed Swing High / Low and whether a close already broke it
      bool                    m_has_high;
      double                  m_high_price;
      datetime                m_high_time;
      ENUM_SWING_STRUCTURE    m_high_structure;
      bool                    m_high_used;
      bool                    m_has_low;
      double                  m_low_price;
      datetime                m_low_time;
      ENUM_SWING_STRUCTURE    m_low_structure;
      bool                    m_low_used;
      void                    ResetState(void);
   //--- Replay the candles after m_last_processed_time
      void                    Process(void);
   //--- Create+dedupe(by Code)+insert one event
      void                    AddStructure(const ENUM_MARKET_STRUCTURE_TYPE type,const ENUM_SIGNAL_DIR direction,const datetime break_time,
                                           const datetime swing_time,const double level);
   //--- Remove every event this Control owns (this Symbol+Timeframe only) from the shared table
      void                    RemoveOwnStructures(void);
   //--- Number of events of this Symbol+Timeframe
      int                     OwnTotal(void) const;
   public:
   //--- Return itself
      CMarketStructureControl *GetObject(void) { return &this; }
                              CMarketStructureControl(const string symbol,const ENUM_TIMEFRAMES timeframe,
                                                      CArrayObj *list_series,CArrayObj *list_swings,CArrayObj *list_structures);
      string                  Symbol(void)    const { return this.m_symbol;    }
      ENUM_TIMEFRAMES         Timeframe(void) const { return this.m_timeframe; }
   //--- Clear this Symbol+Timeframe's own events and replay the whole history - call after the Swings were rescanned
      void                    Rescan(void);
   //--- Full replay of the available history
      int                     InitMarketStructureList(void);
   //--- Incremental replay: the closed candles since the last call (call on every new bar, after the Swings are updated)
      int                     UpdateMarketStructureList(void);
 };
#endif // CMARKETSTRUCTURECONTROL_MQH_DECLARATION
#ifndef CMARKETSTRUCTURECONTROL_MQH_IMPLEMENTATION
#define CMARKETSTRUCTURECONTROL_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMarketStructureControl::CMarketStructureControl(const string symbol,const ENUM_TIMEFRAMES timeframe,
                                                 CArrayObj *list_series,CArrayObj *list_swings,CArrayObj *list_structures)
 {
   this.m_type                 = OBJECT_DE_TYPE_SERIES_MARKET_STRUCTURE_CONTROL;
   this.m_symbol               = symbol;
   this.m_timeframe            = timeframe;
   this.m_list_series          = list_series;
   this.m_list_all_swings      = list_swings;
   this.m_list_all_structures  = list_structures;
   this.ResetState();
 }
void CMarketStructureControl::ResetState(void)
 {
   this.m_last_processed_time = 0;
   this.m_applied_swing_time  = 0;
   this.m_has_high            = false;
   this.m_high_price          = 0.0;
   this.m_high_time           = 0;
   this.m_high_structure      = SWING_STRUCTURE_NONE;
   this.m_high_used           = false;
   this.m_has_low             = false;
   this.m_low_price           = 0.0;
   this.m_low_time            = 0;
   this.m_low_structure       = SWING_STRUCTURE_NONE;
   this.m_low_used            = false;
 }
//+------------------------------------------------------------------+
//| Create+dedupe(by Code)+insert one event, kept sorted by time     |
//+------------------------------------------------------------------+
void CMarketStructureControl::AddStructure(const ENUM_MARKET_STRUCTURE_TYPE type,const ENUM_SIGNAL_DIR direction,const datetime break_time,
                                           const datetime swing_time,const double level)
 {
   CMarketStructureSeries *structure = new CMarketStructureSeries(type, direction, this.m_symbol, this.m_timeframe, break_time, swing_time, level);
   if(structure == NULL) return;
   this.m_list_all_structures.Sort(SORT_BY_MARKET_STRUCTURE_CODE);
   if(this.m_list_all_structures.Search(structure) != WRONG_VALUE)
    {
      delete structure;      // already detected - dedupe by Primary Key
      return;
    }
   this.m_list_all_structures.Sort(SORT_BY_MARKET_STRUCTURE_TIME);
   if(!this.m_list_all_structures.InsertSort(structure))
    {
      delete structure;
      return;
    }
 }
//+------------------------------------------------------------------+
//| Replay the closed candles after m_last_processed_time, oldest to |
//| newest. The newest element of the bars table is the still-forming|
//| candle and is never used. Swings are applied as references from  |
//| their ConfirmedTime on, so a candle only sees what was known then|
//+------------------------------------------------------------------+
void CMarketStructureControl::Process(void)
 {
   if(this.m_list_series == NULL || this.m_list_all_swings == NULL || this.m_list_all_structures == NULL) return;
   this.m_list_series.Sort(SORT_BY_BAR_TIME);
   int hi = this.m_list_series.Total() - 2;
   if(hi < 0) return;
   //--- This Symbol+Timeframe's Swings, ordered by confirmation time
   datetime sw_confirmed[], sw_time[];
   double   sw_price[];
   int      sw_type[], sw_structure[];
   int n = 0;
   for(int i = 0; i < this.m_list_all_swings.Total(); i++)
    {
      CBarSwingSeries *s = this.m_list_all_swings.At(i);
      if(s == NULL || s.Symbol() != this.m_symbol || s.Timeframe() != this.m_timeframe) continue;
      ::ArrayResize(sw_confirmed, n + 1);
      ::ArrayResize(sw_time,      n + 1);
      ::ArrayResize(sw_price,     n + 1);
      ::ArrayResize(sw_type,      n + 1);
      ::ArrayResize(sw_structure, n + 1);
      int k = n;
      while(k > 0 && sw_confirmed[k - 1] > s.ConfirmedTime())   // insertion by ConfirmedTime
       {
         sw_confirmed[k] = sw_confirmed[k - 1];
         sw_time[k]      = sw_time[k - 1];
         sw_price[k]     = sw_price[k - 1];
         sw_type[k]      = sw_type[k - 1];
         sw_structure[k] = sw_structure[k - 1];
         k--;
       }
      sw_confirmed[k] = s.ConfirmedTime();
      sw_time[k]      = s.Time();
      sw_price[k]     = s.Price();
      sw_type[k]      = (int)s.TypeSwing();
      sw_structure[k] = (int)s.Structure();
      n++;
    }
   int sp = 0;
   while(sp < n && sw_confirmed[sp] <= this.m_applied_swing_time) sp++;   // already applied
   //--- First closed candle not replayed yet
   int start = 0;
   if(this.m_last_processed_time > 0)
    {
      start = hi + 1;
      for(int i = 0; i <= hi; i++)
       {
         CBar *b = this.m_list_series.At(i);
         if(b != NULL && b.Time() > this.m_last_processed_time) { start = i; break; }
       }
    }
   for(int i = start; i <= hi; i++)
    {
      CBar *bar = this.m_list_series.At(i);
      if(bar == NULL) continue;
      datetime t = bar.Time();
      while(sp < n && sw_confirmed[sp] <= t)
       {
         if(sw_type[sp] == SWING_TYPE_HIGH)
          {
            this.m_has_high = true; this.m_high_price = sw_price[sp]; this.m_high_time = sw_time[sp];
            this.m_high_structure = (ENUM_SWING_STRUCTURE)sw_structure[sp]; this.m_high_used = false;
          }
         else if(sw_type[sp] == SWING_TYPE_LOW)
          {
            this.m_has_low = true; this.m_low_price = sw_price[sp]; this.m_low_time = sw_time[sp];
            this.m_low_structure = (ENUM_SWING_STRUCTURE)sw_structure[sp]; this.m_low_used = false;
          }
         this.m_applied_swing_time = sw_confirmed[sp];
         sp++;
       }
      double close = bar.Close();
      if(this.m_has_high && !this.m_high_used && close > this.m_high_price)
       {
         this.m_high_used = true;
         ENUM_MARKET_STRUCTURE_TYPE type = (this.m_high_structure == SWING_STRUCTURE_HH ? MARKET_STRUCTURE_BOS :
                                            this.m_high_structure == SWING_STRUCTURE_LH ? MARKET_STRUCTURE_CHOCH : MARKET_STRUCTURE_NONE);
         if(type != MARKET_STRUCTURE_NONE)
            this.AddStructure(type, SIGNAL_BUY, t, this.m_high_time, this.m_high_price);
       }
      if(this.m_has_low && !this.m_low_used && close < this.m_low_price)
       {
         this.m_low_used = true;
         ENUM_MARKET_STRUCTURE_TYPE type = (this.m_low_structure == SWING_STRUCTURE_LL ? MARKET_STRUCTURE_BOS :
                                            this.m_low_structure == SWING_STRUCTURE_HL ? MARKET_STRUCTURE_CHOCH : MARKET_STRUCTURE_NONE);
         if(type != MARKET_STRUCTURE_NONE)
            this.AddStructure(type, SIGNAL_SELL, t, this.m_low_time, this.m_low_price);
       }
    }
   CBar *hi_bar = this.m_list_series.At(hi);
   if(hi_bar != NULL) this.m_last_processed_time = hi_bar.Time();
 }
//+------------------------------------------------------------------+
//| Remove every event this Control owns - other Symbols/Timeframes  |
//| in the same table are untouched                                  |
//+------------------------------------------------------------------+
void CMarketStructureControl::RemoveOwnStructures(void)
 {
   if(this.m_list_all_structures == NULL) return;
   for(int i = this.m_list_all_structures.Total() - 1; i >= 0; i--)
    {
      CMarketStructureSeries *s = this.m_list_all_structures.At(i);
      if(s != NULL && s.Symbol() == this.m_symbol && s.Timeframe() == this.m_timeframe)
         this.m_list_all_structures.Delete(i);
    }
 }
int CMarketStructureControl::OwnTotal(void) const
 {
   int count = 0;
   if(this.m_list_all_structures == NULL) return 0;
   for(int i = 0; i < this.m_list_all_structures.Total(); i++)
    {
      CMarketStructureSeries *s = this.m_list_all_structures.At(i);
      if(s != NULL && s.Symbol() == this.m_symbol && s.Timeframe() == this.m_timeframe) count++;
    }
   return count;
 }
//+------------------------------------------------------------------+
//| Clear own events and replay the whole history                    |
//+------------------------------------------------------------------+
void CMarketStructureControl::Rescan(void)
 {
   this.RemoveOwnStructures();
   this.InitMarketStructureList();
 }
//+------------------------------------------------------------------+
//| Full replay of the available history                             |
//+------------------------------------------------------------------+
int CMarketStructureControl::InitMarketStructureList(void)
 {
   if(this.m_list_series == NULL || this.m_list_all_swings == NULL || this.m_list_all_structures == NULL) return 0;
   this.ResetState();
   this.Process();
   this.m_list_all_structures.Sort(SORT_BY_MARKET_STRUCTURE_TIME);
   return this.OwnTotal();
 }
//+------------------------------------------------------------------+
//| Incremental replay: only the closed candles since the last call  |
//+------------------------------------------------------------------+
int CMarketStructureControl::UpdateMarketStructureList(void)
 {
   if(this.m_list_series == NULL || this.m_list_all_swings == NULL || this.m_list_all_structures == NULL) return 0;
   this.Process();
   this.m_list_all_structures.Sort(SORT_BY_MARKET_STRUCTURE_TIME);
   return this.m_list_all_structures.Total();
 }
#endif // CMARKETSTRUCTURECONTROL_MQH_IMPLEMENTATION
#endif // __MARKETSTRUCTURECONTROL_MQH__
