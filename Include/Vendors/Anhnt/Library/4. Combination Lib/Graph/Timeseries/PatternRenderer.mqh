//+------------------------------------------------------------------+
//|                                          PatternRenderer.mqh     |
//|                                         Copyright 2025, Anhnt    |
//+------------------------------------------------------------------+
//| DoEasy-style OBJ_BITMAP positioning — matches PatternOutsideBar: |
//|                                                                  |
//|   OBJPROP_TIME  = t_oldest  (ANCHOR_CENTER → bar slot center)   |
//|   OBJPROP_PRICE = mid_price (center of price range)             |
//|   ANCHOR_CENTER                                                  |
//|   Width  = (2n-1)*slot_w + 1  (DoEasy formula)                  |
//|   Height = proportional to price range                           |
//|   Rect in bitmap: x = w/2 - slot_w/2  (left edge of oldest bar) |
//|                                                                  |
//|   Why ANCHOR_CENTER works:                                       |
//|   OBJPROP_TIME = bar.Time() on OBJ_BITMAP anchors at the        |
//|   CENTER of that bar's slot, not the left edge.                  |
//|   With ANCHOR_CENTER, bitmap center = bar slot center.           |
//|   Rect offset x = w/2 - slot_w/2 shifts rect left by slot_w/2   |
//|   → rect left edge = bar slot LEFT EDGE. ✓                      |
//|                                                                  |
//|   Reposition() is a no-op: OBJ_BITMAP auto-follows on scroll.   |
//|   Redraw() clears and recreates bitmaps (zoom change only).      |
//+------------------------------------------------------------------+
#ifndef __PATTERN_RENDERER_MQH__
#define __PATTERN_RENDERER_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\GCnvBitmap.mqh"
 #include "..\..\Timeseries\Bars\BarSeriesPatterns\Pattern.mqh"

 #ifndef SDRAWNPATTERN_DECLARATION
 #define SDRAWNPATTERN_DECLARATION
  struct SDrawnPattern
   {
    datetime               time;             // NEWEST bar (PATTERN_PROP_TIME)
    double                 price_high;       // max High across all n bars
    double                 price_low;        // min Low  across all n bars
    int                    n_candles;
    ENUM_PATTERN_DIRECTION dir;
    int                    pattern_period_s;
   };
 #endif

 #ifndef CPATTERNRENDERER_MQH_DECLARATION
 #define CPATTERNRENDERER_MQH_DECLARATION
  class CPatternRenderer
   {
    private:
      CArrayObj         m_list_bitmaps;
      SDrawnPattern     m_drawn[];
      long              m_chart_id;
      int               m_subwin;
      int               m_obj_id;
      string            m_symbol;
      ENUM_TIMEFRAMES   m_period;
      datetime          m_prev_bar0;   // last known bar[0] open time (new-bar gate)

      color             ColorByDirection(const ENUM_PATTERN_DIRECTION dir) const;
      color             BorderByDirection(const ENUM_PATTERN_DIRECTION dir) const;
      int               BitmapWidth(const int n_candles) const;
      int               BitmapHeight(const SDrawnPattern &p) const;
      void              DrawView(CGCnvBitmap *bitmap, const ENUM_PATTERN_DIRECTION dir);
      bool              CreateBitmap(const SDrawnPattern &p, const int idx);
      void              ClearBitmaps(void);
      void              GetVisibleTimeRange(datetime &t_from, datetime &t_to) const;

    public:
      bool              OnInitEvent(const long chart_id, const int subwin,
                                    const string symbol, const ENUM_TIMEFRAMES period);
      void              OnDeinitEvent(void)        { Clear(); }
      void              Refresh(CArrayObj *pattern_list);
      void              UpdateNew(CArrayObj *pattern_list);
      void              Redraw(void);
      void              Reposition(void);
      void              Clear(void);
   };
 #endif
 #ifndef CPATTERNRENDERER_MQH_IMPLEMENTATION
 #define CPATTERNRENDERER_MQH_IMPLEMENTATION

  bool CPatternRenderer::OnInitEvent(const long chart_id, const int subwin,
                                      const string symbol, const ENUM_TIMEFRAMES period)
   {
      m_chart_id  = (chart_id == 0 || chart_id == NULL ? ::ChartID() : chart_id);
      m_subwin    = subwin;
      m_obj_id    = 0;
      m_symbol    = (symbol == NULL || symbol == "" ? ::Symbol() : symbol);
      m_period    = (period == PERIOD_CURRENT ? ::Period() : period);
      m_prev_bar0 = 0;
      m_list_bitmaps.Clear();
      m_list_bitmaps.FreeMode(true);
      ::ArrayFree(m_drawn);
      return true;
   }

  void CPatternRenderer::GetVisibleTimeRange(datetime &t_from, datetime &t_to) const
   {
      int first_vis = (int)::ChartGetInteger(m_chart_id, CHART_FIRST_VISIBLE_BAR);
      t_from = ::iTime(m_symbol, m_period, first_vis);
      t_to   = ::iTime(m_symbol, m_period, 0);
      if(t_from == 0) t_from = t_to - (datetime)(first_vis * ::PeriodSeconds(m_period));
   }

  color CPatternRenderer::ColorByDirection(const ENUM_PATTERN_DIRECTION dir) const
   {
    switch(dir)
      {
        case PATTERN_DIRECTION_BULLISH : return clrCornflowerBlue;
        case PATTERN_DIRECTION_BEARISH : return clrLightSalmon;
        default                        : return clrSilver;
      }
   }

  color CPatternRenderer::BorderByDirection(const ENUM_PATTERN_DIRECTION dir) const
   {
      switch(dir)
        {
        case PATTERN_DIRECTION_BULLISH : return clrRoyalBlue;
        case PATTERN_DIRECTION_BEARISH : return clrCrimson;
        default                        : return clrDimGray;
        }
   }

  //+------------------------------------------------------------------+
  //| Width = DoEasy formula: (2n-1)*slot_w + 1                        |
  //| Makes the bitmap wider than n*slot_w so ANCHOR_CENTER can shift  |
  //| the rectangle to start exactly at the oldest bar's left edge.    |
  //+------------------------------------------------------------------+
  int CPatternRenderer::BitmapWidth(const int n_candles) const
   {
    int slot_w = (int)(1 << (int)::ChartGetInteger(m_chart_id, CHART_SCALE));
    return (2 * n_candles - 1) * slot_w + 1;
   }

  // DoEasy formula: ceil + 8px buffer (4px above high, 4px below low).
  // With ANCHOR_CENTER at mid_price, the extra 8px ensures the rectangle
  // encompasses the full price range without clipping candle wicks.
  int CPatternRenderer::BitmapHeight(const SDrawnPattern &p) const
   {
    double price_max = ::ChartGetDouble(m_chart_id, CHART_PRICE_MAX);
    double price_min = ::ChartGetDouble(m_chart_id, CHART_PRICE_MIN);
    double vis_range = price_max - price_min;
    if(vis_range <= 0) return 12;
    int    chart_h   = (int)::ChartGetInteger(m_chart_id, CHART_HEIGHT_IN_PIXELS);
    double bar_range = p.price_high - p.price_low;
    int    h         = (int)::MathCeil(chart_h * bar_range / vis_range) + 8;
    return (h < 12 ? 12 : h);
   }

  void CPatternRenderer::ClearBitmaps(void)
   {
    for(int i = m_list_bitmaps.Total() - 1; i >= 0; i--)
      {
       CGCnvBitmap *bmp = m_list_bitmaps.At(i);
       if(bmp != NULL) bmp.Hide();
      }
    m_list_bitmaps.Clear();
    m_obj_id = 0;
   }

  void CPatternRenderer::Clear(void)
   {
    ClearBitmaps();
    ::ArrayFree(m_drawn);
    ::ChartRedraw(m_chart_id);
   }

  //+------------------------------------------------------------------+
  //| Draw rectangle in bitmap using DoEasy's x-offset formula.        |
  //|                                                                  |
  //| x = w/2 - slot_w/2                                              |
  //|   = left edge of oldest bar slot within the bitmap canvas.       |
  //|                                                                  |
  //| Rectangle spans from x to w-1 → covers exactly n bar slots.    |
  //| Rectangle spans from y=0 to y=h-1 → covers full price range.   |
  //+------------------------------------------------------------------+
  void CPatternRenderer::DrawView(CGCnvBitmap *bitmap, const ENUM_PATTERN_DIRECTION dir)
   {
      if(bitmap == NULL) return;
      int   w      = bitmap.Width();
      int   h      = bitmap.Height();
      int   slot_w = (int)(1 << (int)::ChartGetInteger(m_chart_id, CHART_SCALE));
      int   x      = w / 2 - slot_w / 2;   // left edge of oldest bar slot
      color fill   = ColorByDirection(dir);
      color bord   = BorderByDirection(dir);
      bitmap.Erase(CLR_CANV_NULL, 0);
      bitmap.DrawRectangleFill(x, 0, w - 1, h - 1, fill, 100);
      bitmap.DrawRectangle(    x, 0, w - 1, h - 1, bord, 255);
      bitmap.Update(false);
   }

  //+------------------------------------------------------------------+
  //| Create one bitmap — matches DoEasy PatternOutsideBar approach:   |
  //|                                                                  |
  //| time      = t_oldest (MotherBarTime equivalent)                  |
  //| price     = mid_price = (high + low) / 2                        |
  //| ANCHOR_CENTER → bitmap center at (bar_center, mid_price)         |
  //| Width     = (2n-1)*slot_w + 1                                   |
  //| DrawView  → draws rect starting at w/2 - slot_w/2               |
  //+------------------------------------------------------------------+
  bool CPatternRenderer::CreateBitmap(const SDrawnPattern &p, const int idx)
    {
      int      ps        = p.pattern_period_s;
      datetime t_oldest  = p.time - (datetime)((p.n_candles - 1) * ps);
      double   mid_price = (p.price_high + p.price_low) / 2.0;

      int w = BitmapWidth(p.n_candles);
      int h = BitmapHeight(p);
      if(w < 2) w = 2;
      if(h < 2) h = 2;

      string name = "PR_" + (string)p.time + "_" + (string)idx;
      // Constructor sets OBJPROP_TIME = t_oldest, OBJPROP_PRICE = mid_price
      CGCnvBitmap *bitmap = new CGCnvBitmap(GRAPH_ELEMENT_TYPE_BITMAP, NULL, NULL,
                                              m_obj_id++, 0, m_chart_id, m_subwin,
                                              name, t_oldest, mid_price, w, h, clrNONE, 200);
      if(bitmap == NULL) return false;
      ::ObjectSetInteger(m_chart_id, bitmap.Name(), OBJPROP_ANCHOR,  ANCHOR_CENTER);
      ::ObjectSetString(m_chart_id,  bitmap.Name(), OBJPROP_TOOLTIP, "\n");
      ::ObjectSetInteger(m_chart_id, bitmap.Name(), OBJPROP_BACK,    true);
      DrawView(bitmap, p.dir);
      bitmap.Show();
      return m_list_bitmaps.Add(bitmap);
    }

  //+------------------------------------------------------------------+
  //| Redraw on zoom: clear and recreate with new slot_w.              |
  //+------------------------------------------------------------------+
  void CPatternRenderer::Redraw(void)
   {
    ClearBitmaps();
    datetime t_from, t_to;
    GetVisibleTimeRange(t_from, t_to);
    int total = ::ArraySize(m_drawn);
    for(int i = 0; i < total; i++)
      {
        int      ps      = m_drawn[i].pattern_period_s;
        datetime t_oldest = m_drawn[i].time - (datetime)((m_drawn[i].n_candles - 1) * ps);
        if(m_drawn[i].time < t_from || t_oldest > t_to) continue;
        CreateBitmap(m_drawn[i], i);
      }
    ::ChartRedraw(m_chart_id);
   }

  //+------------------------------------------------------------------+
  //| No-op: OBJ_BITMAP OBJPROP_TIME/PRICE auto-follows chart scroll.  |
  //+------------------------------------------------------------------+
  void CPatternRenderer::Reposition(void)
   {
    ::ChartRedraw(m_chart_id);
   }

  //+------------------------------------------------------------------+
  //| Full rebuild: pass 3→2→1 priority, visible range filter.         |
  //+------------------------------------------------------------------+
  void CPatternRenderer::Refresh(CArrayObj *pattern_list)
    {
      if(pattern_list == NULL) return;
      ClearBitmaps();
      ::ArrayFree(m_drawn);
      int total = pattern_list.Total();
      if(total == 0) { ::ChartRedraw(m_chart_id); return; }

      datetime t_from, t_to;
      GetVisibleTimeRange(t_from, t_to);

      datetime cov_start[]; datetime cov_end[]; int cov_pass[]; int n_cov = 0;

      for(int pass = 3; pass >= 1; pass--)
        {
          for(int i = 0; i < total; i++)
            {
              CBarPattern *p = pattern_list.At(i);
              if(p == NULL) continue;
              int n = (int)p.GetProperty(PATTERN_PROP_CANDLES);
              if(n != pass) continue;

              ENUM_TIMEFRAMES tf     = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
              int             tf_ps  = (int)::PeriodSeconds(tf);
              datetime        t_new  = (datetime)p.GetProperty(PATTERN_PROP_TIME);
              datetime        t_old  = t_new - (datetime)((n - 1) * tf_ps);

              if(t_new < t_from || t_old > t_to) continue;

              bool covered = false;
              for(int j = 0; j < n_cov; j++)
                if(cov_pass[j] >= pass && t_old <= cov_end[j] && t_new >= cov_start[j])
                { covered = true; break; }
              if(covered) continue;

              ::ArrayResize(cov_start, n_cov + 1); cov_start[n_cov] = t_old;
              ::ArrayResize(cov_end,   n_cov + 1); cov_end[n_cov]   = t_new;
              ::ArrayResize(cov_pass,  n_cov + 1); cov_pass[n_cov]  = n;
              n_cov++;

              int sz = ::ArraySize(m_drawn);
              ::ArrayResize(m_drawn, sz + 1);
              m_drawn[sz].time             = t_new;
              m_drawn[sz].price_high       = p.MotherBarHigh();
              m_drawn[sz].price_low        = p.MotherBarLow();
              m_drawn[sz].n_candles        = n;
              m_drawn[sz].dir              = (ENUM_PATTERN_DIRECTION)(long)p.GetProperty(PATTERN_PROP_DIRECTION);
              m_drawn[sz].pattern_period_s = tf_ps;
              CreateBitmap(m_drawn[sz], sz);
            }
        }
      ::ChartRedraw(m_chart_id);
    }

  //+------------------------------------------------------------------+
  //| Incremental update: runs ONCE per new bar, not on every tick.   |
  //|                                                                  |
  //| Gate: compares current bar[0].Time() with m_prev_bar0.          |
  //| If unchanged → same bar still forming → return immediately.     |
  //| This is the root fix for flickering: UpdateNew called every      |
  //| tick by EA, but we only execute when a new bar has opened.      |
  //+------------------------------------------------------------------+
  void CPatternRenderer::UpdateNew(CArrayObj *pattern_list)
    {
      // New-bar gate: only execute when bar[0] has advanced.
      datetime t_bar0 = ::iTime(m_symbol, m_period, 0);
      if(t_bar0 == m_prev_bar0) return;   // same bar still forming → no-op      
      m_prev_bar0 = t_bar0;
      if(pattern_list == NULL) return;
      int total = pattern_list.Total();
      if(total == 0) return;
      datetime t_from, t_to;
      GetVisibleTimeRange(t_from, t_to);
      datetime t_cutoff = ::iTime(m_symbol, m_period, 3);
      if(t_cutoff == 0) t_cutoff = t_to - (datetime)(3 * ::PeriodSeconds(m_period));

      int n_drawn = ::ArraySize(m_drawn);
      datetime cov_start[]; datetime cov_end[]; int cov_pass[];
      int n_cov = n_drawn;
      ::ArrayResize(cov_start, n_cov); ::ArrayResize(cov_end, n_cov); ::ArrayResize(cov_pass, n_cov);
      for(int i = 0; i < n_drawn; i++)
        {
          cov_start[i] = m_drawn[i].time - (datetime)((m_drawn[i].n_candles - 1) * m_drawn[i].pattern_period_s);
          cov_end[i]   = m_drawn[i].time;
          cov_pass[i]  = m_drawn[i].n_candles;
        }
      for(int pass = 3; pass >= 1; pass--)
        {
          for(int i = 0; i < total; i++)
            {
              CBarPattern *p = pattern_list.At(i);
              if(p == NULL) continue;
              int n = (int)p.GetProperty(PATTERN_PROP_CANDLES);
              if(n != pass) continue;

              ENUM_TIMEFRAMES tf    = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
              int             tf_ps = (int)::PeriodSeconds(tf);
              datetime        t_new = (datetime)p.GetProperty(PATTERN_PROP_TIME);
              datetime        t_old = t_new - (datetime)((n - 1) * tf_ps);

              if(t_new < t_cutoff)             continue;
              if(t_new >= t_bar0)              continue; // skip forming bar[0]
              if(t_new < t_from || t_old > t_to) continue;

              // Skip if this EXACT pattern (same newest-bar time, same n) is already
              // drawn. Without this check, same-priority coverage (>) would fail to
              // self-block and the pattern gets removed+redrawn every tick → flicker.
              bool already_drawn = false;
              for(int k = 0; k < ::ArraySize(m_drawn); k++)
                if(m_drawn[k].time == t_new && m_drawn[k].n_candles == n)
                { already_drawn = true; break; }
              if(already_drawn) continue;

              // Higher-priority coverage: only strictly higher blocks (not same).
              // Same-priority patterns from older bars can be replaced by newer ones.
              bool covered = false;
              for(int j = 0; j < n_cov; j++)
                if(cov_pass[j] > pass && t_old <= cov_end[j] && t_new >= cov_start[j])
                { covered = true; break; }
              if(covered) continue;

              // Remove overlapping same-or-lower-priority drawn patterns so a newer
              // bar's pattern replaces the older overlapping one of equal priority.
              for(int k = ::ArraySize(m_drawn) - 1; k >= 0; k--)
                {
                  if(m_drawn[k].n_candles > n) continue;  // strictly higher: keep
                  datetime ex_new = m_drawn[k].time;
                  datetime ex_old = ex_new - (datetime)((m_drawn[k].n_candles - 1) * m_drawn[k].pattern_period_s);
                  if(t_old <= ex_new && t_new >= ex_old)
                    {
                      m_list_bitmaps.Delete(k);
                      for(int m = k; m < ::ArraySize(m_drawn) - 1; m++) m_drawn[m] = m_drawn[m + 1];
                      ::ArrayResize(m_drawn, ::ArraySize(m_drawn) - 1);
                    }
                }

              ::ArrayResize(cov_start, n_cov + 1); cov_start[n_cov] = t_old;
              ::ArrayResize(cov_end,   n_cov + 1); cov_end[n_cov]   = t_new;
              ::ArrayResize(cov_pass,  n_cov + 1); cov_pass[n_cov]  = n;
              n_cov++;

              int sz = ::ArraySize(m_drawn);
              ::ArrayResize(m_drawn, sz + 1);
              m_drawn[sz].time             = t_new;
              m_drawn[sz].price_high       = p.MotherBarHigh();
              m_drawn[sz].price_low        = p.MotherBarLow();
              m_drawn[sz].n_candles        = n;
              m_drawn[sz].dir              = (ENUM_PATTERN_DIRECTION)(long)p.GetProperty(PATTERN_PROP_DIRECTION);
              m_drawn[sz].pattern_period_s = tf_ps;
              CreateBitmap(m_drawn[sz], sz);
            }
        }
      ::ChartRedraw(m_chart_id);
    }

 #endif // CPATTERNRENDERER_MQH_IMPLEMENTATION
#endif // __PATTERN_RENDERER_MQH__
