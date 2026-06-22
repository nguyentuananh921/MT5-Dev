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
      CArrayObj         m_pending;     // patterns waiting for bitmap creation (non-owning pointers)
     //For filter on Chart
      bool m_show_bull[PATTERNS_TOTAL];  // initialized true
      bool m_show_bear[PATTERNS_TOTAL];  // initialized true
     //Private method
      // m_prev_scale changed: recreate bitmaps
      void              Redraw    (CArrayObj *plist, const bool redraw=true);   
      bool              CreatePatternBitmap(CBarPattern *p, const int scale, const int chart_h,
                                            const double price_max, const double price_min);
      void              QueuePending(CBarPattern *p);  // enqueue for later creation, skip if already queued

      void              GetVisibleTimeRange(datetime &t_from, datetime &t_to) const;
      void              CleanupChartObjects(void);   // remove stale "PR_" objects on deinit/init

      void              Reposition(void)  { ::ChartRedraw(m_chart_id); }
      //void              SetPeriod (const ENUM_TIMEFRAMES tf); 
    public:
      //CPatternRenderer Lifecycle        
        bool              OnInitEvent(const long chart_id, const int subwin,
                                      const string symbol, 
                                      const ENUM_TIMEFRAMES period,
                                      const int reason = REASON_PROGRAM);
                                      
        void              OnDeinitEvent(CArrayObj *plist = NULL,const int reason= REASON_PROGRAM);
        bool              OnChartEvent(const int id, CArrayObj *plist);        
        void              OnTimerEvent(void);   // drain m_pending, budgeted per tick
     //
        void              Refresh   (CArrayObj *plist, const bool redraw=true);
      // show/hide/create per TF + coverage with filter   
        void              Refresh   (CArrayObj *plist, const bool apply_filter, const bool redraw);
      // incremental: new bar only
        void              UpdateNew (CArrayObj *plist, const bool redraw=true); 
        void              UpdateNew (CArrayObj *plist, const bool apply_filter, const bool redraw);  
     //For filter on Chart
        static int TypeIndex(const ENUM_PATTERN_TYPE type);
        void SetFilter(const ENUM_PATTERN_TYPE type, const bool bull, const bool bear);
        bool GetFilterBull(const ENUM_PATTERN_TYPE type) const;
        bool GetFilterBear(const ENUM_PATTERN_TYPE type) const;
   };
 #endif // CPATTERNRENDERER_MQH_DECLARATION
 #ifndef CPATTERNRENDERER_MQH_IMPLEMENTATION
 #define CPATTERNRENDERER_MQH_IMPLEMENTATION
 #define PATTERN_RENDER_BUDGET_US 8000   // max us spent creating bitmaps per OnTimerEvent tick
  bool CPatternRenderer::OnInitEvent(const long chart_id, const int subwin,
                                      const string symbol, const ENUM_TIMEFRAMES period,const int reason)
   {
      m_chart_id  = (chart_id == 0 || chart_id == NULL ? ::ChartID() : chart_id);
      m_subwin    = subwin;
      m_obj_id    = 0;
      m_symbol    = (symbol == NULL || symbol == "" ? ::Symbol() : symbol);
      m_period    = (period == PERIOD_CURRENT ? ::Period() : period);
      m_prev_bar0 = 0;
      m_prev_scale = (int)::ChartGetInteger(m_chart_id, CHART_SCALE); // init scale     
      m_pending.FreeMode(false);   // pointers owned by the pattern collection, not by us
      if(reason != REASON_CHARTCHANGE)
       {
            m_obj_id = 0;
            m_pending.Clear();
            CleanupChartObjects();  // clean stale objects from previous session
            for(int i = 0; i < PATTERNS_TOTAL; i++)
             m_show_bull[i] = m_show_bear[i] = true;
       }      
      return true;
   }
  void CPatternRenderer::OnDeinitEvent(CArrayObj *plist,const int reason)
   {
    // Diagnostic: count patterns vs bitmaps for this chart's symbol/TF, plus real chart-object count
    int pat_count = 0, bmp_count = 0;
    if(plist != NULL)
       for(int i = 0; i < plist.Total(); i++)
        {
           CBarPattern *p = plist.At(i);
           if(p == NULL) continue;
           ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
           if(tf != m_period || p.Symbol() != m_symbol) continue;
           pat_count++;
           if(p.HasBitmap()) bmp_count++;
        }
    ::Print("PERF CPatternRenderer::OnDeinitEvent reason=", reason,
            " symbol=", m_symbol, " period=", EnumToString(m_period),
            " plistTotal=", (plist == NULL ? 0 : plist.Total()),
            " patterns=", pat_count, " bitmaps=", bmp_count,
            " objBitmapTotal=", ::ObjectsTotal(m_chart_id, m_subwin, OBJ_BITMAP));

    if(reason == REASON_CHARTCHANGE)
     {
        // Clear bitmaps only for the symbol/TF we're navigating away from —
        // their pixel size is baked to the old chart state, must recreate on return anyway.
        if(plist != NULL)
           for(int i = 0; i < plist.Total(); i++)
            {
               CBarPattern *p = plist.At(i);
               if(p == NULL || !p.HasBitmap()) continue;
               ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
               if(tf == m_period && p.Symbol() == m_symbol) p.ClearBitmap();
            }
        return;
     }
    m_pending.Clear();
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
    
    if(curr_scale != m_prev_scale)
    {
     m_prev_scale = curr_scale;
     Redraw(plist, false);
     return false;
    }        
    //Refresh(plist, false);
    ulong t0 = ::GetMicrosecondCount();

    Refresh(plist, true, false);
    ulong t1 = ::GetMicrosecondCount();
      if(t1 - t0 > 1000)
          ::Print("PERF CPatternRenderer::OnChartEvent Refresh plist.Total()=", plist.Total(), " cost=", t1 - t0, "us");
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
  void CPatternRenderer::QueuePending(CBarPattern *p)
   {
      for(int q = 0; q < m_pending.Total(); q++)
          if(m_pending.At(q) == p) return;   // already queued
      m_pending.Add(p);
   }
  //+------------------------------------------------------------------+
  //| Drain pending bitmap-creation queue, budgeted per call.          |
  //| Called from OnTimer() — spreads the cost across many ticks       |
  //| instead of one synchronous burst that freezes the terminal.      |
  //+------------------------------------------------------------------+
  void CPatternRenderer::OnTimerEvent(void)
   {
      if(m_pending.Total() == 0) return;
      ulong t0 = ::GetMicrosecondCount();
      int    scale     = (int)::ChartGetInteger(m_chart_id, CHART_SCALE);
      int    chart_h   = (int)::ChartGetInteger(m_chart_id, CHART_HEIGHT_IN_PIXELS);
      double price_max = ::ChartGetDouble (m_chart_id, CHART_PRICE_MAX);
      double price_min = ::ChartGetDouble (m_chart_id, CHART_PRICE_MIN);
      datetime t_from, t_to;
      GetVisibleTimeRange(t_from, t_to);   // re-check NOW — chart may have scrolled since queued
      int created = 0;
      int skipped = 0;
      while(m_pending.Total() > 0)
      {
          int last = m_pending.Total() - 1;
          CBarPattern *p = m_pending.At(last);
          m_pending.Delete(last);
          if(p != NULL && !p.HasBitmap())
          {
              int             n     = (int)p.GetProperty(PATTERN_PROP_CANDLES);
              ENUM_TIMEFRAMES tf    = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
              datetime        t_new = (datetime)p.GetProperty(PATTERN_PROP_TIME);
              datetime        t_old = t_new - (datetime)((n - 1) * ::PeriodSeconds(tf));

              if(t_new < t_from || t_old > t_to)
                  skipped++;   // scrolled out of view while waiting in queue — re-queued by Refresh() if it comes back
              else
              {
                  CreatePatternBitmap(p, scale, chart_h, price_max, price_min);
                  created++;
              }
          }
          if(::GetMicrosecondCount() - t0 >= PATTERN_RENDER_BUDGET_US) break;
      }
      if(created > 0) ::ChartRedraw(m_chart_id);
      ulong us = ::GetMicrosecondCount() - t0;
      if(us > 1000)
         ::Print("PERF CPatternRenderer::OnTimerEvent us=", us, " created=", created, " skipped=", skipped, " pending=", m_pending.Total());
   }
  //+------------------------------------------------------------------+
  //| Create CGCnvPatternBitmap, attach to pattern, draw, show.        |
  //+------------------------------------------------------------------+
  bool CPatternRenderer::CreatePatternBitmap(CBarPattern *p, const int scale, const int chart_h,
                                             const double price_max, const double price_min)
   {
    if(p == NULL) return false;
    ulong t0 = ::GetMicrosecondCount();
    int             n      = (int)p.GetProperty(PATTERN_PROP_CANDLES);
    ENUM_TIMEFRAMES tf     = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
    int             tf_ps  = (int)::PeriodSeconds(tf);
    datetime        t_new  = (datetime)p.GetProperty(PATTERN_PROP_TIME);
    datetime        t_old  = t_new - (datetime)((n - 1) * tf_ps);   // oldest bar = anchor
    double          p_high = p.MotherBarHigh();
    double          p_low  = p.MotherBarLow();
    ENUM_PATTERN_DIRECTION dir = (ENUM_PATTERN_DIRECTION)(long)p.GetProperty(PATTERN_PROP_DIRECTION);

    string name = "PR_" + (string)t_new + "_" + (string)(m_obj_id);
    ulong t1 = ::GetMicrosecondCount();
    CGCnvPatternBitmap *bmp = new CGCnvPatternBitmap(
        m_chart_id, m_subwin, name, m_obj_id++,
        t_old, p_high, p_low, dir, n,
        scale, chart_h, price_max, price_min);
    ulong t2 = ::GetMicrosecondCount();
    if(bmp == NULL) return false;
    ::ObjectSetInteger(m_chart_id, bmp.Name(), OBJPROP_ANCHOR,  ANCHOR_CENTER);
    ::ObjectSetString (m_chart_id, bmp.Name(), OBJPROP_TOOLTIP, "\n");
    ::ObjectSetInteger(m_chart_id, bmp.Name(), OBJPROP_BACK,    true);
    ulong t3 = ::GetMicrosecondCount();
    bmp.DrawView();
    ulong t4 = ::GetMicrosecondCount();
    bmp.Show();
    ulong t5 = ::GetMicrosecondCount();
    p.AttachBitmap(bmp);
    ulong us = t5 - t0;
    if(us > 1000)
       ::Print("PERF CPatternRenderer::CreatePatternBitmap us=", us, " prep=", t1-t0,
               " ctor=", t2-t1, " setprops=", t3-t2,
               " drawview=", t4-t3, " show=", t5-t4);
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
     // Hide bitmaps from other symbols/timeframes — they stay in memory for no-flicker TF switching 
      for(int i = 0; i < total; i++)
       {
          CBarPattern *p = plist.At(i);
          if(p == NULL || !p.HasBitmap()) continue;
          ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
          if((tf != m_period || p.Symbol() != m_symbol) && p.GetBitmap().IsVisible())
              p.GetBitmap().Hide();
       }

      datetime t_from, t_to;
      GetVisibleTimeRange(t_from, t_to);

      datetime drawn_confirmation_bar[];
      int      drawn_candle_count[];
      int      n_drawn = 0;

      for(int pass = 3; pass >= 1; pass--)
       {
        for(int i = 0; i < total; i++)
          {
              CBarPattern *p = plist.At(i);
              if(p == NULL) continue;
              int n = (int)p.GetProperty(PATTERN_PROP_CANDLES);
              if(n != pass) continue;

              ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
              if(tf != m_period || p.Symbol() != m_symbol) continue;
              int      tf_ps = (int)::PeriodSeconds(tf);
              datetime t_new = (datetime)p.GetProperty(PATTERN_PROP_TIME);
              datetime t_old = t_new - (datetime)((n - 1) * tf_ps);

              if(t_new < t_from || t_old > t_to)
                {
                    if(p.HasBitmap() && p.GetBitmap().IsVisible()) p.GetBitmap().Hide();
                    continue;
                }

                bool same_bar_higher_priority = false;
                for(int j = 0; j < n_drawn; j++)
                    if(drawn_candle_count[j] >= pass && drawn_confirmation_bar[j] == t_new)
                    { same_bar_higher_priority = true; break; }
                if(same_bar_higher_priority)
                {
                    if(p.HasBitmap() && p.GetBitmap().IsVisible()) p.GetBitmap().Hide();
                    continue;
                }

              ::ArrayResize(drawn_confirmation_bar, n_drawn + 1);
              ::ArrayResize(drawn_candle_count,     n_drawn + 1);
              drawn_confirmation_bar[n_drawn] = t_new;
              drawn_candle_count[n_drawn]     = n;
              n_drawn++;

              if(p.HasBitmap())
               { if(!p.GetBitmap().IsVisible()) p.GetBitmap().Show(); }
              else
                  QueuePending(p);
          }
       }
      if(redraw) ::ChartRedraw(m_chart_id);
   }
  //+------------------------------------------------------------------+
  //| Refresh with direction filter.                                   |
  //| Same priority logic as Refresh(plist, redraw):                  |
  //|   pass 3→2→1: higher candle-count patterns take precedence.     |
  //| Filtered patterns are hidden AND excluded from bar coverage,     |
  //| so lower-priority patterns on the same bar can still appear.    |
  //+------------------------------------------------------------------+
  void CPatternRenderer::Refresh(CArrayObj *plist, const bool apply_filter, const bool redraw)
   {
     if(plist == NULL || m_chart_id == 0) return;
     int total = plist.Total();
     if(total == 0) { if(redraw) ::ChartRedraw(m_chart_id); return; }

     ulong t0 = ::GetMicrosecondCount();

     for(int i = 0; i < total; i++)
     {
         CBarPattern *p = plist.At(i);
         if(p == NULL || !p.HasBitmap()) continue;
         ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
         if((tf != m_period || p.Symbol() != m_symbol) && p.GetBitmap().IsVisible())
             p.GetBitmap().Hide();
     }
     ulong t1 = ::GetMicrosecondCount();

     datetime t_from, t_to;
     GetVisibleTimeRange(t_from, t_to);
     ulong t2 = ::GetMicrosecondCount();

     datetime drawn_confirmation_bar[];
     int      drawn_candle_count[];
     int      n_drawn = 0;
     int      n_queued = 0;

     for(int pass = 3; pass >= 1; pass--)
     {
         for(int i = 0; i < total; i++)
         {
             CBarPattern *p = plist.At(i);
             if(p == NULL) continue;
             int n = (int)p.GetProperty(PATTERN_PROP_CANDLES);
             if(n != pass) continue;

             ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
             if(tf != m_period || p.Symbol() != m_symbol) continue;

             if(apply_filter)
             {
                 int fidx = TypeIndex(p.TypePattern());
                 ENUM_PATTERN_DIRECTION dir = p.Direction();
                 if(fidx >= 0 && fidx < PATTERNS_TOTAL)
                     if((dir == PATTERN_DIRECTION_BULLISH && !m_show_bull[fidx]) ||
                       (dir == PATTERN_DIRECTION_BEARISH && !m_show_bear[fidx]))
                     {
                         if(p.HasBitmap() && p.GetBitmap().IsVisible()) p.GetBitmap().Hide();
                         continue;
                     }
             }

             int      tf_ps = (int)::PeriodSeconds(tf);
             datetime t_new = (datetime)p.GetProperty(PATTERN_PROP_TIME);
             datetime t_old = t_new - (datetime)((n - 1) * tf_ps);

             if(t_new < t_from || t_old > t_to)
             {
                 if(p.HasBitmap() && p.GetBitmap().IsVisible()) p.GetBitmap().Hide();
                 continue;
             }

             bool same_bar_higher_priority = false;
             for(int j = 0; j < n_drawn; j++)
                 if(drawn_candle_count[j] >= pass && drawn_confirmation_bar[j] == t_new)
                 { same_bar_higher_priority = true; break; }
             if(same_bar_higher_priority)
             {
                 if(p.HasBitmap() && p.GetBitmap().IsVisible()) p.GetBitmap().Hide();
                 continue;
             }

             ::ArrayResize(drawn_confirmation_bar, n_drawn + 1);
             ::ArrayResize(drawn_candle_count,     n_drawn + 1);
             drawn_confirmation_bar[n_drawn] = t_new;
             drawn_candle_count[n_drawn]     = n;
             n_drawn++;

             if(p.HasBitmap())
             { if(!p.GetBitmap().IsVisible()) p.GetBitmap().Show(); }
             else
             { QueuePending(p); n_queued++; }
         }
     }
     ulong t3 = ::GetMicrosecondCount();

     if(redraw) ::ChartRedraw(m_chart_id);
     ulong t4 = ::GetMicrosecondCount();

     ulong total_us = t4 - t0;
     if(total_us > 1000)
        ::Print("PERF CPatternRenderer::Refresh total=", total_us,
                "us hideTF=", t1-t0, "us range=", t2-t1, "us mainLoop=", t3-t2,
                "us chartRedraw=", t4-t3, "us n_drawn=", n_drawn,
                " n_queued=", n_queued, " pending=", m_pending.Total(), " plist=", total);
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

        datetime drawn_confirmation_bar[];
        int      drawn_candle_count[];
        int      n_drawn = 0;

      for(int i = 0; i < total; i++)
      {
          CBarPattern *p = plist.At(i);
          if(p == NULL || !p.HasBitmap() || !p.GetBitmap().IsVisible()) continue;
          ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
          if(tf != m_period || p.Symbol() != m_symbol) continue;
          datetime t_n = (datetime)p.GetProperty(PATTERN_PROP_TIME);
          int      nc  = (int)p.GetProperty(PATTERN_PROP_CANDLES);
          ::ArrayResize(drawn_confirmation_bar, n_drawn + 1);
          ::ArrayResize(drawn_candle_count,     n_drawn + 1);
          drawn_confirmation_bar[n_drawn] = t_n;
          drawn_candle_count[n_drawn]     = nc;
          n_drawn++;
      }

      for(int pass = 3; pass >= 1; pass--)
      {
          for(int i = 0; i < total; i++)
          {
              CBarPattern *p = plist.At(i);
              if(p == NULL) continue;
              int n = (int)p.GetProperty(PATTERN_PROP_CANDLES);
              if(n != pass) continue;

              ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
              if(tf != m_period || p.Symbol() != m_symbol) continue;
              int      tf_ps = (int)::PeriodSeconds(tf);
              datetime t_new = (datetime)p.GetProperty(PATTERN_PROP_TIME);
              datetime t_old = t_new - (datetime)((n - 1) * tf_ps);

              if(t_new < t_cutoff || t_new >= t_bar0) continue;
              if(t_new < t_from   || t_old > t_to)   continue;
              if(p.HasBitmap())                       continue;

              bool same_bar_higher_priority = false;
              for(int j = 0; j < n_drawn; j++)
                  if(drawn_candle_count[j] >= pass && drawn_confirmation_bar[j] == t_new)
                  { same_bar_higher_priority = true; break; }
              if(same_bar_higher_priority) continue;

              for(int k = 0; k < total; k++)
              {
                  CBarPattern *pk = plist.At(k);
                  if(pk == NULL || !pk.HasBitmap()) continue;
                  ENUM_TIMEFRAMES tfk = (ENUM_TIMEFRAMES)(long)pk.GetProperty(PATTERN_PROP_PERIOD);
                  if(tfk != m_period || pk.Symbol() != m_symbol) continue;
                  int      nk  = (int)pk.GetProperty(PATTERN_PROP_CANDLES);
                  if(nk >= n)  continue;
                  datetime t_nk = (datetime)pk.GetProperty(PATTERN_PROP_TIME);
                  if(t_nk == t_new)
                      pk.ClearBitmap();
              }

              ::ArrayResize(drawn_confirmation_bar, n_drawn + 1);
              ::ArrayResize(drawn_candle_count,     n_drawn + 1);
              drawn_confirmation_bar[n_drawn] = t_new;
              drawn_candle_count[n_drawn]     = n;
              n_drawn++;
              QueuePending(p);
          }
      }
      if(redraw) ::ChartRedraw(m_chart_id);
   }

  //+------------------------------------------------------------------+
  //| Incremental update on new bar only — with direction filter.     |
  //| Same logic as UpdateNew(plist, redraw) but filtered patterns    |
  //| are skipped: not drawn AND not counted in bar coverage.         |
  //+------------------------------------------------------------------+
  void CPatternRenderer::UpdateNew(CArrayObj *plist, const bool apply_filter, const bool redraw)
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

      datetime drawn_confirmation_bar[];
      int      drawn_candle_count[];
      int      n_drawn = 0;

      for(int i = 0; i < total; i++)
      {
          CBarPattern *p = plist.At(i);
          if(p == NULL || !p.HasBitmap() || !p.GetBitmap().IsVisible()) continue;
          ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
          if(tf != m_period || p.Symbol() != m_symbol) continue;

          if(apply_filter)
          {
              int fidx = TypeIndex(p.TypePattern());
              ENUM_PATTERN_DIRECTION dir = p.Direction();
              if(fidx >= 0 && fidx < PATTERNS_TOTAL)
                  if((dir == PATTERN_DIRECTION_BULLISH && !m_show_bull[fidx]) ||
                    (dir == PATTERN_DIRECTION_BEARISH && !m_show_bear[fidx]))
                      continue;
          }

          datetime t_n = (datetime)p.GetProperty(PATTERN_PROP_TIME);
          int      nc  = (int)p.GetProperty(PATTERN_PROP_CANDLES);
          ::ArrayResize(drawn_confirmation_bar, n_drawn + 1);
          ::ArrayResize(drawn_candle_count,     n_drawn + 1);
          drawn_confirmation_bar[n_drawn] = t_n;
          drawn_candle_count[n_drawn]     = nc;
          n_drawn++;
      }

      for(int pass = 3; pass >= 1; pass--)
      {
          for(int i = 0; i < total; i++)
          {
              CBarPattern *p = plist.At(i);
              if(p == NULL) continue;
              int n = (int)p.GetProperty(PATTERN_PROP_CANDLES);
              if(n != pass) continue;

              ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
              if(tf != m_period || p.Symbol() != m_symbol) continue;

              if(apply_filter)
              {
                  int fidx = TypeIndex(p.TypePattern());
                  ENUM_PATTERN_DIRECTION dir = p.Direction();
                  if(fidx >= 0 && fidx < PATTERNS_TOTAL)
                      if((dir == PATTERN_DIRECTION_BULLISH && !m_show_bull[fidx]) ||
                        (dir == PATTERN_DIRECTION_BEARISH && !m_show_bear[fidx]))
                          continue;
              }

              int      tf_ps = (int)::PeriodSeconds(tf);
              datetime t_new = (datetime)p.GetProperty(PATTERN_PROP_TIME);
              datetime t_old = t_new - (datetime)((n - 1) * tf_ps);

              if(t_new < t_cutoff || t_new >= t_bar0) continue;
              if(t_new < t_from   || t_old > t_to)   continue;
              if(p.HasBitmap())                       continue;

              bool same_bar_higher_priority = false;
              for(int j = 0; j < n_drawn; j++)
                  if(drawn_candle_count[j] >= pass && drawn_confirmation_bar[j] == t_new)
                  { same_bar_higher_priority = true; break; }
              if(same_bar_higher_priority) continue;

              for(int k = 0; k < total; k++)
              {
                  CBarPattern *pk = plist.At(k);
                  if(pk == NULL || !pk.HasBitmap()) continue;
                  ENUM_TIMEFRAMES tfk = (ENUM_TIMEFRAMES)(long)pk.GetProperty(PATTERN_PROP_PERIOD);
                  if(tfk != m_period || pk.Symbol() != m_symbol) continue;
                  int      nk   = (int)pk.GetProperty(PATTERN_PROP_CANDLES);
                  if(nk >= n)   continue;
                  datetime t_nk = (datetime)pk.GetProperty(PATTERN_PROP_TIME);
                  if(t_nk == t_new)
                      pk.ClearBitmap();
              }

              ::ArrayResize(drawn_confirmation_bar, n_drawn + 1);
              ::ArrayResize(drawn_candle_count,     n_drawn + 1);
              drawn_confirmation_bar[n_drawn] = t_new;
              drawn_candle_count[n_drawn]     = n;
              n_drawn++;
              QueuePending(p);
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
    Refresh(plist, true, redraw);  // ← always apply current filter state   
   } 
  static int CPatternRenderer::TypeIndex(const ENUM_PATTERN_TYPE type)
   {
      if(type == PATTERN_TYPE_NONE) return -1;
      int idx = 0;
      long val = (long)type;
      while((val & 1) == 0 && idx < 28) { val >>= 1; idx++; }
      return idx;
   }

  void CPatternRenderer::SetFilter(const ENUM_PATTERN_TYPE type, const bool bull, const bool bear)
   {
      int idx = TypeIndex(type);
      if(idx < 0 || idx >= PATTERNS_TOTAL) return;
      m_show_bull[idx] = bull;
      m_show_bear[idx] = bear;
   }

  bool CPatternRenderer::GetFilterBull(const ENUM_PATTERN_TYPE type) const
   {
      int idx = TypeIndex(type);
      return (idx < 0 || idx >= PATTERNS_TOTAL) ? true : m_show_bull[idx];
   }

  bool CPatternRenderer::GetFilterBear(const ENUM_PATTERN_TYPE type) const
   {
      int idx = TypeIndex(type);
      return (idx < 0 || idx >= PATTERNS_TOTAL) ? true : m_show_bear[idx];
   }
 #endif // CPATTERNRENDERER_MQH_IMPLEMENTATION
#endif // __PATTERN_RENDERER_MQH__




