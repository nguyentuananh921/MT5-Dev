//+------------------------------------------------------------------+
//|                                              BarSwingControl.mqh |
//| Swing High/Low detection - "N bars left, N bars right" local     |
//| extremum scan, mirroring CBarPatternsControl's role for Patterns |
//| (pure data, no GUI). One instance per (Symbol, Timeframe), same  |
//| as CBarPatternsControl - NOT per-type like Pattern's subclasses, |
//| since High and Low detection share the exact same algorithm.     |
//|                                                                    |
//| Strength (N) and PriceBasis (Wick/Body) are BOTH live-changeable  |
//| Options - changing either invalidates every previously-detected   |
//| Swing for this Symbol+Timeframe (the definition of "is this a     |
//| Swing" changed retroactively for the whole history), so both      |
//| setters clear this Control's own rows from the shared Swings      |
//| table and rescan from scratch - this is an Indicator-parameter-   |
//| style "change param -> full recompute", NOT a Pattern-style       |
//| "just keep detecting forward" (Anhnt/Claude, 2026-09-18).          |
//+------------------------------------------------------------------+
#ifndef __BARSWINGCONTROL_MQH__
#define __BARSWINGCONTROL_MQH__
#property strict
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "..\..\..\Base\BaseObj.mqh"
#include "..\Bar.mqh"
#include "..\BarSwingSeries\BarSwing.mqh"

#ifndef CBARSWINGCONTROL_MQH_DECLARATION
#define CBARSWINGCONTROL_MQH_DECLARATION
class CBarSwingControl : public CBaseObj
 {
   private:
      string                  m_symbol;                                                // Swing timeseries symbol
      ENUM_TIMEFRAMES         m_timeframe;                                             // Swing timeseries chart period
      ulong                   m_symbol_code;                                           // Symbol name as a number, same formula CBarPattern uses
      int                     m_strength;                                              // N - left/right bars required each side (Option, live-changeable)
      ENUM_SWING_PRICE_BASIS  m_price_basis;                                           // Wick or Body (Option, live-changeable)
      datetime                m_last_processed_time;                                   // Newest candidate bar's Time() already run through ProcessCandidate() - tracks
                                                                                        // progress across calls so UpdateSwingList() never re-derives a fixed-size
                                                                                        // window (a real tick gap can let "hi" jump by more bars than that window
                                                                                        // covered, silently skipping candidates in between - Anhnt/Claude, 2026-09-22)
      CArrayObj              *m_list_series;                                           // Pointer to the Bars table (CBarSeriesDE::m_list_series) - index 0 = newest
      CArrayObj              *m_list_all_swings;                                       // Pointer to the (possibly shared, multi-symbol) Swings table
      CBarSwing               m_swing_instance;                                        // Scratch instance for Search()-by-code, mirrors CBarPatternsControl::m_pattern_instance
   //--- Price used for the High/Low comparison at a given m_list_series index, per m_price_basis
      double                  SwingHighPrice(const int idx) const;
      double                  SwingLowPrice(const int idx) const;
   //--- Local-extremum test at idx against m_strength bars each side (idx-j = newer, idx+j = older)
      bool                    IsSwingHighAt(const int idx) const;
      bool                    IsSwingLowAt(const int idx) const;
   //--- Unique code (Primary Key) - time+type+period+symbol, mirrors CBarPattern's own code formula
      ulong                   GetSwingCode(const ENUM_SWING_TYPE type, const datetime pivot_time) const;
   //--- HH/LH/HL/LL vs the last CONFIRMED Swing of the SAME type (High vs High, Low vs Low only)
      ENUM_SWING_STRUCTURE    ClassifyStructure(const ENUM_SWING_TYPE type, const double price) const;
   //--- Create+dedupe+insert one confirmed Swing at idx, if not already present
      void                    ProcessCandidate(const int idx);
   //--- Remove every Swing this Control owns (this Symbol+Timeframe only) from the shared table
      void                    RemoveOwnSwings(void);
   public:
   //--- Return itself
      CBarSwingControl       *GetObject(void) { return &this; }
   //--- Constructor - Strength/PriceBasis start at 5/Wick; the owner (EA's CTimeSeriesEngine) overrides
   //--- them from its shared CSwingSetting right after construction, before InitSwingList()
                              CBarSwingControl(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                                CArrayObj *list_series, CArrayObj *list_swings);
   //--- Return (1) symbol, (2) timeframe
      string                  Symbol(void)    const { return this.m_symbol;    }
      ENUM_TIMEFRAMES         Timeframe(void) const { return this.m_timeframe; }
   //--- Strength (N) - setter clears+rescans this Symbol+Timeframe's own Swings on real change
      int                     Strength(void) const { return this.m_strength; }
      void                    Strength(const int n);
   //--- Price basis (Wick/Body) - setter clears+rescans this Symbol+Timeframe's own Swings on real change
      ENUM_SWING_PRICE_BASIS  PriceBasis(void) const { return this.m_price_basis; }
      void                    PriceBasis(const ENUM_SWING_PRICE_BASIS basis);
   //--- Full scan of the entire available history - call once at startup (mirrors CBarPatternsControl's initial pass)
      int                     InitSwingList(void);
   //--- Incremental scan: only the newest n_bars candidates (call on every new-bar event, mirrors UpdatePatternList)
      int                     UpdateSwingList(const int n_bars=4);
 };
#endif // CBARSWINGCONTROL_MQH_DECLARATION
#ifndef CBARSWINGCONTROL_MQH_IMPLEMENTATION
#define CBARSWINGCONTROL_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CBarSwingControl::CBarSwingControl(const string symbol, const ENUM_TIMEFRAMES timeframe,
                                    CArrayObj *list_series, CArrayObj *list_swings)
 {
   this.m_type          = OBJECT_DE_TYPE_SERIES_SWING_CONTROL;
   this.m_symbol        = symbol;
   this.m_timeframe     = timeframe;
   this.m_list_series   = list_series;
   this.m_list_all_swings = list_swings;
   this.m_strength      = 5;
   this.m_price_basis   = SWING_PRICE_BASIS_WICK;
   this.m_last_processed_time = 0;
   this.m_symbol_code   = 0;
   for(int i = 0; i < (int)StringLen(symbol); i++)
      this.m_symbol_code += (ulong)StringGetCharacter(symbol, i);
 }
//+------------------------------------------------------------------+
//| Price used for the High comparison - wick (native High) or       |
//| body (max of Open/Close)                                          |
//+------------------------------------------------------------------+
double CBarSwingControl::SwingHighPrice(const int idx) const
 {
   CBar *bar = this.m_list_series.At(idx);
   if(bar == NULL) return 0.0;
   return (this.m_price_basis == SWING_PRICE_BASIS_BODY) ? ::MathMax(bar.Open(), bar.Close()) : bar.High();
 }
//+------------------------------------------------------------------+
//| Price used for the Low comparison - wick (native Low) or         |
//| body (min of Open/Close)                                          |
//+------------------------------------------------------------------+
double CBarSwingControl::SwingLowPrice(const int idx) const
 {
   CBar *bar = this.m_list_series.At(idx);
   if(bar == NULL) return 0.0;
   return (this.m_price_basis == SWING_PRICE_BASIS_BODY) ? ::MathMin(bar.Open(), bar.Close()) : bar.Low();
 }
//+------------------------------------------------------------------+
//| Is the bar at idx a Swing High - strictly higher than every bar  |
//| within m_strength bars each side (idx-j and idx+j are simply the |
//| two opposite neighbours - m_list_series is ascending by time, 0  |
//| = oldest, Total()-1 = newest, but the comparison itself doesn't  |
//| care which side is which). Strict comparison (>= disqualifies) - |
//| a tie with a neighbour does NOT count.                            |
//+------------------------------------------------------------------+
bool CBarSwingControl::IsSwingHighAt(const int idx) const
 {
   double cur = this.SwingHighPrice(idx);
   for(int j = 1; j <= this.m_strength; j++)
    {
      if(this.m_list_series.At(idx-j) == NULL || this.m_list_series.At(idx+j) == NULL)
         return false;
      double left  = this.SwingHighPrice(idx-j);
      double right = this.SwingHighPrice(idx+j);
      if(left >= cur || right >= cur) return false;
    }
   return true;
 }
//+------------------------------------------------------------------+
//| Is the bar at idx a Swing Low - same rule as IsSwingHighAt,      |
//| mirrored for the Low side.                                        |
//+------------------------------------------------------------------+
bool CBarSwingControl::IsSwingLowAt(const int idx) const
 {
   double cur = this.SwingLowPrice(idx);
   for(int j = 1; j <= this.m_strength; j++)
    {
      if(this.m_list_series.At(idx-j) == NULL || this.m_list_series.At(idx+j) == NULL) return false;
      if(this.SwingLowPrice(idx-j) <= cur || this.SwingLowPrice(idx+j) <= cur) return false;
    }
   return true;
 }
//+------------------------------------------------------------------+
//| Unique code = pivot time + type + timeframe + symbol code -      |
//| same formula shape as CBarPattern's own code (time+type+status+  |
//| direction+timeframe+symbol), minus the fields Swing doesn't have. |
//+------------------------------------------------------------------+
ulong CBarSwingControl::GetSwingCode(const ENUM_SWING_TYPE type, const datetime pivot_time) const
 {
   return (ulong)pivot_time + (ulong)type + (ulong)this.m_timeframe + this.m_symbol_code;
 }
//+------------------------------------------------------------------+
//| HH/LH/HL/LL vs the last CONFIRMED Swing of the SAME type, SAME   |
//| Symbol+Timeframe - scans m_list_all_swings backward (newest      |
//| first) since it is sorted by time; this Control's own new Swing  |
//| has not been inserted yet when this runs, so the first match     |
//| found IS the correct "previous" reference (Anhnt/Claude,          |
//| 2026-09-18 - "so với Swing gần nhất trước đó" - N=1 by definition,|
//| not a multi-swing search).                                        |
//+------------------------------------------------------------------+
ENUM_SWING_STRUCTURE CBarSwingControl::ClassifyStructure(const ENUM_SWING_TYPE type, const double price) const
 {
   int total = this.m_list_all_swings.Total();
   for(int i = total - 1; i >= 0; i--)
    {
      CBarSwing *s = this.m_list_all_swings.At(i);
      if(s == NULL) continue;
      if(s.Symbol() != this.m_symbol || s.Timeframe() != this.m_timeframe) continue;
      if(s.TypeSwing() != type) continue;
      if(type == SWING_TYPE_HIGH) return (price > s.Price()) ? SWING_STRUCTURE_HH : SWING_STRUCTURE_LH;
      else                        return (price > s.Price()) ? SWING_STRUCTURE_HL : SWING_STRUCTURE_LL;
    }
   return SWING_STRUCTURE_NONE; // no earlier same-type Swing yet
 }
//+------------------------------------------------------------------+
//| Create+dedupe(by Code)+classify+insert a confirmed Swing at idx, |
//| for whichever of High/Low (or both, e.g. an outside bar) match.  |
//+------------------------------------------------------------------+
void CBarSwingControl::ProcessCandidate(const int idx)
 {
   CBar *bar = this.m_list_series.At(idx);
   if(bar == NULL) return;
   // Up to 2 - a bar can be BOTH a Swing High and a Swing Low at once (e.g. an outside bar
   // during a volatile move), so check both independently instead of if/else.
   ENUM_SWING_TYPE types[2]; int types_total = 0;
   if(this.IsSwingHighAt(idx)) types[types_total++] = SWING_TYPE_HIGH;
   if(this.IsSwingLowAt(idx))  types[types_total++] = SWING_TYPE_LOW;
   for(int t = 0; t < types_total; t++)
    {
      ENUM_SWING_TYPE type = types[t];
      datetime pivot_time  = bar.Time();
      ulong code = this.GetSwingCode(type, pivot_time);
      this.m_swing_instance.SetProperty(SWING_PROP_CODE, (long)code);
      this.m_list_all_swings.Sort(SORT_BY_SWING_CODE);
      if(this.m_list_all_swings.Search(&this.m_swing_instance) != WRONG_VALUE)
         continue; // already detected - dedupe by Primary Key
      double price = (type == SWING_TYPE_HIGH) ? this.SwingHighPrice(idx) : this.SwingLowPrice(idx);
      // m_list_series is ascending by time (index 0 = oldest, Total()-1 = newest, confirmed via
      // CBarSeriesDE::Refresh()'s own Sort(SORT_BY_BAR_TIME)+InsertSort+Delete(0)-trims-oldest) -
      // the confirming bar (m_strength periods AFTER the pivot) is at the HIGHER index.
      CBar *confirm_bar = this.m_list_series.At(idx + this.m_strength);
      datetime confirmed_time = (confirm_bar != NULL) ? confirm_bar.Time() : pivot_time;
      this.m_list_all_swings.Sort(SORT_BY_SWING_TIME);
      ENUM_SWING_STRUCTURE structure = this.ClassifyStructure(type, price);
      CBarSwing *swing = new CBarSwing(type, this.m_symbol, this.m_timeframe, pivot_time, confirmed_time,
                                        price, this.m_strength, this.m_price_basis);
      if(swing == NULL) continue;
      swing.Structure(structure);
      swing.SetSwingBar(bar);
      if(!this.m_list_all_swings.InsertSort(swing))
       {
         delete swing;
         continue;
       }
    }
 }
//+------------------------------------------------------------------+
//| Remove every Swing this Control owns (this Symbol+Timeframe      |
//| only) from the shared table - other Symbols/Timeframes in the    |
//| same table are untouched.                                         |
//+------------------------------------------------------------------+
void CBarSwingControl::RemoveOwnSwings(void)
 {
   for(int i = this.m_list_all_swings.Total() - 1; i >= 0; i--)
    {
      CBarSwing *s = this.m_list_all_swings.At(i);
      if(s != NULL && s.Symbol() == this.m_symbol && s.Timeframe() == this.m_timeframe)
         this.m_list_all_swings.Delete(i); // CArrayObj FreeMode -> deletes the CBarSwing too
    }
 }
//+------------------------------------------------------------------+
//| Strength (N) setter - a live Option (Anhnt, 2026-09-17/18,        |
//| "cái N ấy thay đổi khi live được"). Changing it means every       |
//| previously-detected Swing used a DIFFERENT definition of "is this |
//| a Swing" - not additive like Pattern, so clear this Control's own |
//| rows and rescan the full available history from scratch.          |
//+------------------------------------------------------------------+
void CBarSwingControl::Strength(const int n)
 {
   int new_n = (n < 1) ? 1 : n;
   if(new_n == this.m_strength) return;
   this.m_strength = new_n;
   this.RemoveOwnSwings();
   this.InitSwingList();
 }
//+------------------------------------------------------------------+
//| Price basis (Wick/Body) setter - same full-rescan reasoning as   |
//| Strength() above.                                                  |
//+------------------------------------------------------------------+
void CBarSwingControl::PriceBasis(const ENUM_SWING_PRICE_BASIS basis)
 {
   if(basis == this.m_price_basis) return;
   this.m_price_basis = basis;
   this.RemoveOwnSwings();
   this.InitSwingList();
 }
//+------------------------------------------------------------------+
//| Full scan of the entire available history. m_list_series is      |
//| ascending by time (index 0 = OLDEST, Total()-1 = NEWEST - see     |
//| CBarSeriesDE::Refresh()'s own Sort(SORT_BY_BAR_TIME)+InsertSort+  |
//| Delete(0)-trims-the-oldest, and CBarPatternControl's identical    |
//| Sort() before its own scan). Re-sorting here defensively before   |
//| indexing matches that same established convention. Must run      |
//| oldest-to-newest (idx INCREASING) so ClassifyStructure()'s        |
//| backward search always finds an already-inserted earlier Swing   |
//| to compare against, never a later one.                            |
//+------------------------------------------------------------------+
int CBarSwingControl::InitSwingList(void)
 {
   if(this.m_list_series == NULL || this.m_list_all_swings == NULL) return 0;
   this.m_list_series.Sort(SORT_BY_BAR_TIME);
   int total = this.m_list_series.Total();
   int lo = this.m_strength;                 // oldest candidate with m_strength older bars available
   // Newest element (total-1) is the still-forming bar 0 - it must NOT be one of the N confirming
   // bars, or a Swing gets "confirmed" while that bar can still overtake it (and its Time() would
   // push the bridge watermark one bar ahead of every closed-bar signal). Newest valid confirming
   // bar is total-2 (= bar 1), so the newest candidate is total-2-m_strength.
   int hi = total - 2 - this.m_strength;
   for(int i = lo; i <= hi; i++)             // oldest -> newest
      this.ProcessCandidate(i);
   this.m_list_all_swings.Sort(SORT_BY_SWING_TIME);
   if(hi >= lo)
     {
      CBar *hi_bar = this.m_list_series.At(hi);
      if(hi_bar != NULL) this.m_last_processed_time = hi_bar.Time();
     }
   return this.m_list_all_swings.Total();
 }
//+------------------------------------------------------------------+
//| Incremental scan: every candidate newer than the last one this   |
//| Control actually processed - call this on every new-bar event    |
//| once InitSwingList() has already run once.                        |
//| n_bars is now only the FALLBACK window for the one-time case     |
//| where m_last_processed_time is still unset (fresh instance that   |
//| never ran InitSwingList - shouldn't normally happen, but keeps    |
//| this method safe to call standalone).                             |
//| Tracks progress by bar TIME, not index - m_list_series trims its  |
//| oldest entries once past capacity (CBarSeriesDE::Refresh(),       |
//| Delete(0)), which would silently invalidate a remembered index.   |
//| A fixed n_bars-sized window here previously assumed "hi" only     |
//| ever advances by 1 bar between calls; a real tick gap (thin       |
//| liquidity, or the moments right after attach/reinit) can let it   |
//| jump by more, permanently skipping the candidates in between      |
//| (Anhnt/Claude, 2026-09-22 - traced several "missing Swing on      |
//| chart" reports back to exactly this).                             |
//+------------------------------------------------------------------+
int CBarSwingControl::UpdateSwingList(const int n_bars=4)
 {
   if(this.m_list_series == NULL || this.m_list_all_swings == NULL) return 0;
   this.m_list_series.Sort(SORT_BY_BAR_TIME);
   int total = this.m_list_series.Total();
   int lo_all = this.m_strength;
   int hi     = total - 2 - this.m_strength; // same closed-bars-only rule as InitSwingList
   int lo;
   if(this.m_last_processed_time <= 0)
      lo = ::MathMax(lo_all, hi - n_bars + 1);  // never processed before - one-time fallback window
   else
     {
      lo = hi + 1;   // default: nothing new since last time
      for(int i = lo_all; i <= hi; i++)
        {
         CBar *b = this.m_list_series.At(i);
         if(b != NULL && b.Time() > this.m_last_processed_time)
           { lo = i; break; }
        }
     }
   for(int i = lo; i <= hi; i++)             // oldest -> newest, every candidate since last processed
      this.ProcessCandidate(i);
   this.m_list_all_swings.Sort(SORT_BY_SWING_TIME);
   if(hi >= lo_all)
     {
      CBar *hi_bar = this.m_list_series.At(hi);
      if(hi_bar != NULL) this.m_last_processed_time = hi_bar.Time();
     }
   return this.m_list_all_swings.Total();
 }
#endif // CBARSWINGCONTROL_MQH_IMPLEMENTATION
#endif // __BARSWINGCONTROL_MQH__
