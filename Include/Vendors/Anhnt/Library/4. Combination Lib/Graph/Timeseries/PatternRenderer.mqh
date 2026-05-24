//+------------------------------------------------------------------+
//|                                          PatternRenderer.mqh     |
//|                                         Copyright 2025, Anhnt    |
//+------------------------------------------------------------------+
//| DoEasy-style OBJ_BITMAP positioning:                             |
//|   OBJPROP_TIME  = t_oldest  (ANCHOR_CENTER → bar slot center)   |
//|   OBJPROP_PRICE = mid_price (center of price range)             |
//|   Width  = (2n-1)*slot_w + 1  (DoEasy formula)                  |
//|   Height = proportional to price range                           |
//|   Rect in bitmap: x = w/2 - slot_w/2 → left edge of oldest bar  |
//|                                                                  |
//| Bitmap ownership: each CBarPattern owns its CGCnvPatternBitmap.  |
//| PatternRenderer creates bitmaps and manages visibility only.     |
//|   TF switch → Hide() old TF, Show()/Create new TF — no flicker. |
//|   Zoom change → ClearBitmap() + Refresh() for new dimensions.   |
//|   Reposition() is a no-op: OBJ_BITMAP auto-follows chart scroll. |
//+------------------------------------------------------------------+
#ifndef __PATTERN_RENDERER_MQH__
#define __PATTERN_RENDERER_MQH__
 #include <Arrays\ArrayObj.mqh> 
 #include "..\Bitmaps\GCnvPatternBitmap.mqh"
 #include "..\..\Timeseries\Bars\BarSeriesPatterns\BarPattern.mqh" 

 #ifndef CPATTERNRENDERER_MQH_DECLARATION
 #define CPATTERNRENDERER_MQH_DECLARATION
  class CPatternRenderer
   {
    private:
      long              m_chart_id;
      int               m_subwin;
      int               m_obj_id;
      string            m_symbol;
      ENUM_TIMEFRAMES   m_period;
      datetime          m_prev_bar0;   // new-bar gate for UpdateNew
      int               m_prev_scale;  // track zoom change internally
      
      bool              CreatePatternBitmap(CBarPattern *p);
      
      void              GetVisibleTimeRange(datetime &t_from, datetime &t_to) const;
      void              CleanupChartObjects(void);   // remove stale "PR_" objects on deinit/init
      void              Redraw    (CArrayObj *plist, const bool redraw=true);   // zoom changed: recreate bitmaps
      void              Reposition(void)  { ::ChartRedraw(m_chart_id); }
      void              SetPeriod (const ENUM_TIMEFRAMES tf); 
    public:
      //CPatternRenderer Lifecycle
        bool              OnInitEvent(const long chart_id, const int subwin,
                                      const string symbol, const ENUM_TIMEFRAMES period);
        void OnDeinitEvent(CArrayObj *plist = NULL);
        bool OnChartEvent(const int id, CArrayObj *plist);

        
      void              Refresh   (CArrayObj *plist, const bool redraw=true);   // show/hide/create per TF + coverage
      void              UpdateNew (CArrayObj *plist, const bool redraw=true);   // incremental: new bar only           
   };
 #endif // CPATTERNRENDERER_MQH_DECLARATION

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
      m_prev_scale = (int)::ChartGetInteger(m_chart_id, CHART_SCALE); // init scale
      CleanupChartObjects();
      return true;
   }
  void CPatternRenderer::OnDeinitEvent(CArrayObj *plist)
    {
        if(plist != NULL)
            for(int i = 0; i < plist.Total(); i++)
            {
                CBarPattern *p = plist.At(i);
                if(p != NULL) p.ClearBitmap();
            }
        CleanupChartObjects();
    }
  bool CPatternRenderer::OnChartEvent(const int id, CArrayObj *plist)
    {
        if(id != CHARTEVENT_CHART_CHANGE) return false;
        
        ENUM_TIMEFRAMES curr_period = (ENUM_TIMEFRAMES)::ChartPeriod(0);
        int curr_scale = (int)::ChartGetInteger(m_chart_id, CHART_SCALE);
        
        if(curr_period != m_period)
        {
            SetPeriod(curr_period);
            Refresh(plist, false);
            return true; // TF changed
        }
        if(curr_scale != m_prev_scale)
        {
            m_prev_scale = curr_scale;
            Redraw(plist, false);
            return false;
        }
        //Reposition();
        Refresh(plist, false);
        return false;
    }
  
 void CPatternRenderer::CleanupChartObjects(void)
    {
        long cid = (m_chart_id == 0 ? ::ChartID() : m_chart_id);
        for(int i = ::ObjectsTotal(cid, m_subwin, OBJ_BITMAP) - 1; i >= 0; i--)
        {
            string name = ::ObjectName(cid, i, m_subwin, OBJ_BITMAP);
            ::ObjectDelete(cid, name);
        }
        ::ChartRedraw(cid);
    }    
  void CPatternRenderer::GetVisibleTimeRange(datetime &t_from, datetime &t_to) const
   {
      int first_vis = (int)::ChartGetInteger(m_chart_id, CHART_FIRST_VISIBLE_BAR);
      t_from = ::iTime(m_symbol, m_period, first_vis);
      t_to   = ::iTime(m_symbol, m_period, 0);
      if(t_to == 0)   t_to   = ::TimeCurrent();          // ← ADD này
      if(t_from == 0) t_from = t_to - (datetime)(first_vis * ::PeriodSeconds(m_period));
   }

  //+------------------------------------------------------------------+
  //| Create CGCnvPatternBitmap, attach to pattern, draw, show.        |
  //+------------------------------------------------------------------+
  bool CPatternRenderer::CreatePatternBitmap(CBarPattern *p)
   {
    if(p == NULL) return false;
    int             n      = (int)p.GetProperty(PATTERN_PROP_CANDLES);
    ENUM_TIMEFRAMES tf     = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
    int             tf_ps  = (int)::PeriodSeconds(tf);
    datetime        t_new  = (datetime)p.GetProperty(PATTERN_PROP_TIME);
    datetime        t_old  = t_new - (datetime)((n - 1) * tf_ps);   // oldest bar = anchor
    double          p_high = p.MotherBarHigh();
    double          p_low  = p.MotherBarLow();
    ENUM_PATTERN_DIRECTION dir = (ENUM_PATTERN_DIRECTION)(long)p.GetProperty(PATTERN_PROP_DIRECTION);

    string name = "PR_" + (string)t_new + "_" + (string)(m_obj_id);
    CGCnvPatternBitmap *bmp = new CGCnvPatternBitmap(
        m_chart_id, m_subwin, name, m_obj_id++,
        t_old, p_high, p_low, dir, n);
    if(bmp == NULL) return false;

    ::ObjectSetInteger(m_chart_id, bmp.Name(), OBJPROP_ANCHOR,  ANCHOR_CENTER);
    ::ObjectSetString (m_chart_id, bmp.Name(), OBJPROP_TOOLTIP, "\n");
    ::ObjectSetInteger(m_chart_id, bmp.Name(), OBJPROP_BACK,    true);
    bmp.DrawView();
    bmp.Show();
    p.AttachBitmap(bmp);
    return true;
   }

  //+------------------------------------------------------------------+
  //| Full pass: show/hide/create bitmaps for all patterns.            |
  //| Current TF + visible range + priority (3→2→1) → create/show.   |
  //| Other TF or covered/out-of-range → hide.                        |
  //+------------------------------------------------------------------+
  void CPatternRenderer::Refresh(CArrayObj *plist, const bool redraw)
   {
    if(plist == NULL || m_chart_id == 0) return;
    int total = plist.Total();
    if(total == 0) { if(redraw) ::ChartRedraw(m_chart_id); return; }

    // Hide patterns that don't belong to current TF
    for(int i = 0; i < total; i++)
      {
       CBarPattern *p = plist.At(i);
       if(p == NULL || !p.HasBitmap()) continue;
       ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
       if(tf != m_period && p.GetBitmap().IsVisible())
          p.GetBitmap().Hide();
      }

    datetime t_from, t_to;
    GetVisibleTimeRange(t_from, t_to);
    datetime cov_start[]; datetime cov_end[]; int cov_pass[]; int n_cov = 0;

    for(int pass = 3; pass >= 1; pass--)
      {
       for(int i = 0; i < total; i++)
         {
          CBarPattern *p = plist.At(i);
          if(p == NULL) continue;
          int n = (int)p.GetProperty(PATTERN_PROP_CANDLES);
          if(n != pass) continue;

          ENUM_TIMEFRAMES tf    = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
          if(tf != m_period) continue;
          int      tf_ps = (int)::PeriodSeconds(tf);
          datetime t_new = (datetime)p.GetProperty(PATTERN_PROP_TIME);
          datetime t_old = t_new - (datetime)((n - 1) * tf_ps);

          // Out of visible range → hide
          if(t_new < t_from || t_old > t_to)
            {
             if(p.HasBitmap() && p.GetBitmap().IsVisible()) p.GetBitmap().Hide();
             continue;
            }

          // Coverage: same-or-higher priority blocks this pattern
          bool covered = false;
          for(int j = 0; j < n_cov; j++)
            if(cov_pass[j] >= pass && t_old <= cov_end[j] && t_new >= cov_start[j])
            { covered = true; break; }
          if(covered)
            {
             if(p.HasBitmap() && p.GetBitmap().IsVisible()) p.GetBitmap().Hide();
             continue;
            }

          ::ArrayResize(cov_start, n_cov + 1); cov_start[n_cov] = t_old;
          ::ArrayResize(cov_end,   n_cov + 1); cov_end[n_cov]   = t_new;
          ::ArrayResize(cov_pass,  n_cov + 1); cov_pass[n_cov]  = n;
          n_cov++;

          if(p.HasBitmap())
            { if(!p.GetBitmap().IsVisible()) p.GetBitmap().Show(); }
          else
            CreatePatternBitmap(p);
         }
      }
    if(redraw) ::ChartRedraw(m_chart_id);
   }

  //+------------------------------------------------------------------+
  //| Incremental update on new bar only.                              |
  //| Builds coverage from already-drawn patterns, then creates new    |
  //| bitmaps for patterns that appeared in the last few bars.         |
  //+------------------------------------------------------------------+
  void CPatternRenderer::UpdateNew(CArrayObj *plist, const bool redraw)
   {
    datetime t_bar0 = ::iTime(m_symbol, m_period, 0);
    if(t_bar0 == m_prev_bar0) return;
    m_prev_bar0 = t_bar0;
    if(plist == NULL) return;
    int total = plist.Total();
    if(total == 0) return;

    datetime t_from, t_to;
    GetVisibleTimeRange(t_from, t_to);
    datetime t_cutoff = ::iTime(m_symbol, m_period, 3);
    if(t_cutoff == 0) t_cutoff = t_to - (datetime)(3 * ::PeriodSeconds(m_period));

    // Build initial coverage from currently visible patterns
    datetime cov_start[]; datetime cov_end[]; int cov_pass[]; int n_cov = 0;
    for(int i = 0; i < total; i++)
      {
       CBarPattern *p = plist.At(i);
       if(p == NULL || !p.HasBitmap() || !p.GetBitmap().IsVisible()) continue;
       ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
       if(tf != m_period) continue;
       int      n2    = (int)p.GetProperty(PATTERN_PROP_CANDLES);
       int      ps2   = (int)::PeriodSeconds(tf);
       datetime t_n2  = (datetime)p.GetProperty(PATTERN_PROP_TIME);
       datetime t_o2  = t_n2 - (datetime)((n2 - 1) * ps2);
       ::ArrayResize(cov_start, n_cov + 1); cov_start[n_cov] = t_o2;
       ::ArrayResize(cov_end,   n_cov + 1); cov_end[n_cov]   = t_n2;
       ::ArrayResize(cov_pass,  n_cov + 1); cov_pass[n_cov]  = n2;
       n_cov++;
      }

    for(int pass = 3; pass >= 1; pass--)
      {
       for(int i = 0; i < total; i++)
         {
          CBarPattern *p = plist.At(i);
          if(p == NULL) continue;
          int n = (int)p.GetProperty(PATTERN_PROP_CANDLES);
          if(n != pass) continue;

          ENUM_TIMEFRAMES tf    = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
          if(tf != m_period) continue;
          int      tf_ps = (int)::PeriodSeconds(tf);
          datetime t_new = (datetime)p.GetProperty(PATTERN_PROP_TIME);
          datetime t_old = t_new - (datetime)((n - 1) * tf_ps);

          if(t_new < t_cutoff || t_new >= t_bar0)           continue;
          if(t_new < t_from   || t_old > t_to)              continue;
          if(p.HasBitmap())                                  continue;  // already drawn

          // Coverage check
          bool covered = false;
          for(int j = 0; j < n_cov; j++)
            if(cov_pass[j] >= pass && t_old <= cov_end[j] && t_new >= cov_start[j])
            { covered = true; break; }
          if(covered) continue;

          // Remove lower-priority overlapping bitmaps
          for(int k = 0; k < total; k++)
            {
             CBarPattern *pk = plist.At(k);
             if(pk == NULL || !pk.HasBitmap()) continue;
             ENUM_TIMEFRAMES tfk = (ENUM_TIMEFRAMES)(long)pk.GetProperty(PATTERN_PROP_PERIOD);
             if(tfk != m_period) continue;
             int      nk    = (int)pk.GetProperty(PATTERN_PROP_CANDLES);
             if(nk >= n) continue;
             int      psk   = (int)::PeriodSeconds(tfk);
             datetime t_nk  = (datetime)pk.GetProperty(PATTERN_PROP_TIME);
             datetime t_ok  = t_nk - (datetime)((nk - 1) * psk);
             if(t_old <= t_nk && t_new >= t_ok)
                pk.ClearBitmap();
            }

          ::ArrayResize(cov_start, n_cov + 1); cov_start[n_cov] = t_old;
          ::ArrayResize(cov_end,   n_cov + 1); cov_end[n_cov]   = t_new;
          ::ArrayResize(cov_pass,  n_cov + 1); cov_pass[n_cov]  = n;
          n_cov++;
          CreatePatternBitmap(p);
         }
      }
    if(redraw) ::ChartRedraw(m_chart_id);
   }

  //+------------------------------------------------------------------+
  //| Zoom changed: clear current TF bitmaps, recreate via Refresh.    |
  //+------------------------------------------------------------------+
  void CPatternRenderer::Redraw(CArrayObj *plist, const bool redraw)
   {
    if(plist == NULL || m_chart_id == 0) return;
    int total = plist.Total();
    for(int i = 0; i < total; i++)
      {
       CBarPattern *p = plist.At(i);
       if(p == NULL || !p.HasBitmap()) continue;
       ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
       if(tf == m_period) p.ClearBitmap();   // old size, must recreate
      }
    Refresh(plist, redraw);
   }

  //+------------------------------------------------------------------+
  //| Set new TF filter — Refresh() will show/hide accordingly.        |
  //+------------------------------------------------------------------+
  void CPatternRenderer::SetPeriod(const ENUM_TIMEFRAMES tf)
   {
    m_period = (tf == PERIOD_CURRENT ? ::Period() : tf);
   }
  
 #endif // CPATTERNRENDERER_MQH_IMPLEMENTATION
#endif // __PATTERN_RENDERER_MQH__
