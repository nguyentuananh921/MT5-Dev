//+------------------------------------------------------------------+
//|                                          PatternRenderer.mqh     |
//|                                         Copyright 2025, Anhnt    |
//+------------------------------------------------------------------+
//| Refresh(list)   — priority algo, visible range only, caches.     |
//| UpdateNew(list) — adds new patterns from last 3 bars (new bar).  |
//| Redraw()        — redraws cached masters in visible range.       |
//| OnChartEvent()  — calls Refresh on CHARTEVENT_CHART_CHANGE.      |
//+------------------------------------------------------------------+
#ifndef __PATTERN_RENDERER_MQH__
#define __PATTERN_RENDERER_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include <Arrays\ArrayObj.mqh>
 #include "..\GCnvBitmap.mqh"
 #include "..\..\Timeseries\Bars\BarSeriesPatterns\Pattern.mqh"

 #ifndef SDRAWNPATTERN_DECLARATION
 #define SDRAWNPATTERN_DECLARATION
  //+------------------------------------------------------------------+
  //| Cached drawing data for one master pattern                       |
  //+------------------------------------------------------------------+
  struct SDrawnPattern
   {
    datetime               time;
    double                 price_high;
    double                 price_low;
    int                    n_candles;
    ENUM_PATTERN_DIRECTION dir;
   };
 #endif // SDRAWNPATTERN_DECLARATION

 #ifndef CPATTERNRENDERER_MQH_DECLARATION
 #define CPATTERNRENDERER_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Renders CBarPattern objects as CGCnvBitmap rectangles on chart   |
  //+------------------------------------------------------------------+
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

    //--- Helpers
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
      void              OnDeinitEvent(void)        { Clear();                                    }
    //--- Full rebuild for visible range (on init / scroll)
      void              Refresh(CArrayObj *pattern_list);
    //--- Add only new patterns from last 3 bars (on new bar)
      void              UpdateNew(CArrayObj *pattern_list);
    //--- Redraw cached masters in current visible range
      void              Redraw(void);
    //--- CHARTEVENT_CHART_CHANGE → Refresh visible range
      void              OnChartEvent(const int id, CArrayObj *pattern_list);
    //--- Remove all markers and cached data
      void              Clear(void);
   };
 #endif // CPATTERNRENDERER_MQH_DECLARATION
 #ifndef CPATTERNRENDERER_MQH_IMPLEMENTATION
 #define CPATTERNRENDERER_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Init                                                             |
  //+------------------------------------------------------------------+
  bool CPatternRenderer::OnInitEvent(const long chart_id, const int subwin,
                                      const string symbol, const ENUM_TIMEFRAMES period)
   {
      m_chart_id = (chart_id == 0 || chart_id == NULL ? ::ChartID() : chart_id);
      m_subwin   = subwin;
      m_obj_id   = 0;
      m_symbol   = (symbol == NULL || symbol == "" ? ::Symbol() : symbol);
      m_period   = (period == PERIOD_CURRENT ? ::Period() : period);
      m_list_bitmaps.Clear();
      m_list_bitmaps.FreeMode(true);
      ::ArrayFree(m_drawn);
      return true;
   }
  //+------------------------------------------------------------------+
  //| Visible time range from chart properties                         |
  //+------------------------------------------------------------------+
  void CPatternRenderer::GetVisibleTimeRange(datetime &t_from, datetime &t_to) const
   {
    int first_vis = (int)::ChartGetInteger(m_chart_id, CHART_FIRST_VISIBLE_BAR);
    t_from = ::iTime(m_symbol, m_period, first_vis);
    t_to   = ::iTime(m_symbol, m_period, 0);
    if(t_from == 0) t_from = t_to - (datetime)(first_vis * ::PeriodSeconds(m_period));
   }
  //+------------------------------------------------------------------+
  //| Fill color by direction                                          |
  //+------------------------------------------------------------------+
  color CPatternRenderer::ColorByDirection(const ENUM_PATTERN_DIRECTION dir) const
   {
    switch(dir)
      {
       case PATTERN_DIRECTION_BULLISH : return clrCornflowerBlue;   //Increase
       case PATTERN_DIRECTION_BEARISH : return clrLightSalmon;      //Decrease
       default                        : return clrSilver;
      }
   }
  //+------------------------------------------------------------------+
  //| Border color by direction                                        |
  //+------------------------------------------------------------------+
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
  //| Bitmap width = bar_pixel_width * n_candles                       |
  //+------------------------------------------------------------------+
  int CPatternRenderer::BitmapWidth(const int n_candles) const
   {
    int scale = (int)::ChartGetInteger(m_chart_id, CHART_SCALE);
    int bar_w = (int)(1 << scale);
    return bar_w * n_candles;
   }
  //+------------------------------------------------------------------+
  //| Bitmap height proportional to formation price range              |
  //+------------------------------------------------------------------+
  int CPatternRenderer::BitmapHeight(const SDrawnPattern &p) const
   {
    double price_max = ::ChartGetDouble(m_chart_id, CHART_PRICE_MAX);
    double price_min = ::ChartGetDouble(m_chart_id, CHART_PRICE_MIN);
    double vis_range = price_max - price_min;
    if(vis_range <= 0) return 4;
    int    chart_h   = (int)::ChartGetInteger(m_chart_id, CHART_HEIGHT_IN_PIXELS);
    double bar_range = p.price_high - p.price_low;
    int    h         = (int)::MathRound(chart_h * bar_range / vis_range);
    return (h < 4 ? 4 : h);
   }
  //+------------------------------------------------------------------+
  //| Draw filled rectangle across the entire bitmap                   |
  //+------------------------------------------------------------------+
  void CPatternRenderer::DrawView(CGCnvBitmap *bitmap, const ENUM_PATTERN_DIRECTION dir)
   {
    if(bitmap == NULL) return;
    int   w    = bitmap.Width();
    int   h    = bitmap.Height();
    color fill = ColorByDirection(dir);
    color bord = BorderByDirection(dir);
    bitmap.Erase(CLR_CANV_NULL, 0);
    bitmap.DrawRectangleFill(0, 0, w - 1, h - 1, fill, 60);
    bitmap.DrawRectangle(0, 0, w - 1, h - 1, bord, 200);
    bitmap.Update(false);
   }
  //+------------------------------------------------------------------+
  //| Create one bitmap for a cached master pattern                    |
  //+------------------------------------------------------------------+
  bool CPatternRenderer::CreateBitmap(const SDrawnPattern &p, const int idx)
   {
    int    w    = BitmapWidth(p.n_candles);
    int    h    = BitmapHeight(p);
    string name = "PR_" + (string)p.time + "_" + (string)idx;

    CGCnvBitmap *bitmap = new CGCnvBitmap(GRAPH_ELEMENT_TYPE_BITMAP, NULL, NULL,
                                           m_obj_id++, 0, m_chart_id, m_subwin,
                                           name, p.time, p.price_high, w, h, clrNONE, 200);
    if(bitmap == NULL) return false;
      ::ObjectSetInteger(m_chart_id, bitmap.Name(), OBJPROP_ANCHOR,  ANCHOR_LEFT_UPPER);
      ::ObjectSetString(m_chart_id,  bitmap.Name(), OBJPROP_TOOLTIP, "\n");
      ::ObjectSetInteger(m_chart_id, bitmap.Name(), OBJPROP_BACK,    true);  // behind GUI panel
    DrawView(bitmap, p.dir);
    bitmap.Show();
    return m_list_bitmaps.Add(bitmap);
   }
  //+------------------------------------------------------------------+
  //| Remove bitmap objects only — keeps m_drawn[] intact              |
  //+------------------------------------------------------------------+
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
  //+------------------------------------------------------------------+
  //| Remove all markers and clear cached master data                  |
  //+------------------------------------------------------------------+
  void CPatternRenderer::Clear(void)
   {
    ClearBitmaps();
    ::ArrayFree(m_drawn);
    ::ChartRedraw(m_chart_id);
   }
  //+------------------------------------------------------------------+
  //| Redraw cached masters in current visible range                   |
  //+------------------------------------------------------------------+
  void CPatternRenderer::Redraw(void)
   {
    ClearBitmaps();
    datetime t_from, t_to;
    GetVisibleTimeRange(t_from, t_to);
    int total = ::ArraySize(m_drawn);
    for(int i = 0; i < total; i++)
      {
       if(m_drawn[i].time >= t_from && m_drawn[i].time <= t_to)
         CreateBitmap(m_drawn[i], i);
      }
    ::ChartRedraw(m_chart_id);
   }
  //+------------------------------------------------------------------+
  //| Full rebuild — visible range only                                |
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

    datetime cov_start[];
    datetime cov_end[];
    int      n_cov = 0;

    for(int pass = 3; pass >= 1; pass--)
      {
       for(int i = 0; i < total; i++)
         {
          CBarPattern *p = pattern_list.At(i);
          if(p == NULL) continue;
          int n = (int)p.GetProperty(PATTERN_PROP_CANDLES);
          if(n != pass) continue;

          datetime t_start = p.MotherBarTime();
          if(t_start < t_from || t_start > t_to) continue;

          ENUM_TIMEFRAMES tf  = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
          datetime        t_end = t_start + (datetime)(n - 1) * ::PeriodSeconds(tf);

          bool covered = false;
          for(int j = 0; j < n_cov; j++)
            {
             if(t_start >= cov_start[j] && t_start <= cov_end[j])
               { covered = true; break; }
            }
          if(covered) continue;

          ::ArrayResize(cov_start, n_cov + 1);
          ::ArrayResize(cov_end,   n_cov + 1);
          cov_start[n_cov] = t_start;
          cov_end[n_cov]   = t_end;
          n_cov++;

          int sz = ::ArraySize(m_drawn);
          ::ArrayResize(m_drawn, sz + 1);
          m_drawn[sz].time       = t_start;
          m_drawn[sz].price_high = p.MotherBarHigh();
          m_drawn[sz].price_low  = p.MotherBarLow();
          m_drawn[sz].n_candles  = n;
          m_drawn[sz].dir        = (ENUM_PATTERN_DIRECTION)(long)p.GetProperty(PATTERN_PROP_DIRECTION);
          CreateBitmap(m_drawn[sz], sz);
         }
      }

    ::ChartRedraw(m_chart_id);
   }
  //+------------------------------------------------------------------+
  //| Add only new patterns from last 3 bars — no full clear           |
  //+------------------------------------------------------------------+
  void CPatternRenderer::UpdateNew(CArrayObj *pattern_list)
   {
    if(pattern_list == NULL) return;
    int total = pattern_list.Total();
    if(total == 0) return;

    datetime t_from, t_to;
    GetVisibleTimeRange(t_from, t_to);

    //--- Cutoff: 3 bars back (enough for 3-candle patterns)
    datetime t_cutoff = ::iTime(m_symbol, m_period, 3);
    if(t_cutoff == 0) t_cutoff = t_to - (datetime)(3 * ::PeriodSeconds(m_period));

    //--- Pre-populate covered ranges from already-drawn patterns
    datetime cov_start[];
    datetime cov_end[];
    int      n_cov    = ::ArraySize(m_drawn);
    ::ArrayResize(cov_start, n_cov);
    ::ArrayResize(cov_end,   n_cov);
    for(int i = 0; i < n_cov; i++)
      {
       cov_start[i] = m_drawn[i].time;
       cov_end[i]   = m_drawn[i].time +
                      (datetime)(m_drawn[i].n_candles - 1) * ::PeriodSeconds(m_period);
      }

    //--- Process only patterns from last 3 bars
    for(int pass = 3; pass >= 1; pass--)
      {
       for(int i = 0; i < total; i++)
         {
          CBarPattern *p = pattern_list.At(i);
          if(p == NULL) continue;
          int n = (int)p.GetProperty(PATTERN_PROP_CANDLES);
          if(n != pass) continue;

          datetime t_start = p.MotherBarTime();
          if(t_start < t_cutoff)    continue;   // skip old patterns
          if(t_start < t_from || t_start > t_to) continue; // skip invisible

          ENUM_TIMEFRAMES tf    = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
          datetime        t_end = t_start + (datetime)(n - 1) * ::PeriodSeconds(tf);

          bool covered = false;
          for(int j = 0; j < n_cov; j++)
            {
             if(t_start >= cov_start[j] && t_start <= cov_end[j])
               { covered = true; break; }
            }
          if(covered) continue;

          //--- New master: extend covered ranges and add bitmap
          ::ArrayResize(cov_start, n_cov + 1);
          ::ArrayResize(cov_end,   n_cov + 1);
          cov_start[n_cov] = t_start;
          cov_end[n_cov]   = t_end;
          n_cov++;

          int sz = ::ArraySize(m_drawn);
          ::ArrayResize(m_drawn, sz + 1);
          m_drawn[sz].time       = t_start;
          m_drawn[sz].price_high = p.MotherBarHigh();
          m_drawn[sz].price_low  = p.MotherBarLow();
          m_drawn[sz].n_candles  = n;
          m_drawn[sz].dir        = (ENUM_PATTERN_DIRECTION)(long)p.GetProperty(PATTERN_PROP_DIRECTION);
          CreateBitmap(m_drawn[sz], sz);
         }
      }

    ::ChartRedraw(m_chart_id);
   }
  //+------------------------------------------------------------------+
  //| Handle chart events                                              |
  //+------------------------------------------------------------------+
  void CPatternRenderer::OnChartEvent(const int id, CArrayObj *pattern_list)
   {
    if(id == CHARTEVENT_CHART_CHANGE)
      Refresh(pattern_list);
   }
 #endif // CPATTERNRENDERER_MQH_IMPLEMENTATION
#endif // __PATTERN_RENDERER_MQH__
