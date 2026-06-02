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
     //For filter on Chart
      bool m_show_bull[PATTERNS_TOTAL];  // initialized true
      bool m_show_bear[PATTERNS_TOTAL];  // initialized true
     //Private method
      // m_prev_scale changed: recreate bitmaps
      void              Redraw    (CArrayObj *plist, const bool redraw=true);   
      bool              CreatePatternBitmap(CBarPattern *p);
      
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
      if(reason != REASON_CHARTCHANGE)
       {
            m_obj_id = 0;
            CleanupChartObjects();  // clean stale objects from previous session
            for(int i = 0; i < PATTERNS_TOTAL; i++)
             m_show_bull[i] = m_show_bear[i] = true;
       }      
      return true;
   }
  void CPatternRenderer::OnDeinitEvent(CArrayObj *plist,const int reason)
    {
        if(reason == REASON_CHARTCHANGE) return;  // keep bitmaps alive for no-flicker
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
        Refresh(plist, true, false);
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
     // Hide bitmaps from other timeframes — they stay in memory for no-flicker TF switching 
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

      datetime drawn_confirmation_bar[];   // t_new of bars that already have a bitmap
      int      drawn_candle_count[];       // candle count of the pattern drawn at that bar
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
              if(tf != m_period) continue;
              int      tf_ps = (int)::PeriodSeconds(tf);
              datetime t_new = (datetime)p.GetProperty(PATTERN_PROP_TIME);
              datetime t_old = t_new - (datetime)((n - 1) * tf_ps);

              if(t_new < t_from || t_old > t_to)
                {
                    if(p.HasBitmap() && p.GetBitmap().IsVisible()) p.GetBitmap().Hide();
                    continue;
                }

              // Hide if same confirmation bar already has higher-or-equal priority pattern
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
                  CreatePatternBitmap(p);
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

      // Hide bitmaps from other timeframes (kept in memory for no-flicker TF switching)
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

      datetime drawn_confirmation_bar[];  // confirmation bar times already occupied
      int      drawn_candle_count[];      // candle count of pattern occupying that bar
      int      n_drawn = 0;

      // Priority pass: 3-candle first, then 2, then 1
      for(int pass = 3; pass >= 1; pass--)
      {
          for(int i = 0; i < total; i++)
          {
              CBarPattern *p = plist.At(i);
              if(p == NULL) continue;
              int n = (int)p.GetProperty(PATTERN_PROP_CANDLES);
              if(n != pass) continue;

              ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
              if(tf != m_period) continue;

              // --- Direction filter check (before coverage) ---
              // A filtered pattern is hidden AND does NOT register as occupying its bar,
              // so a lower-priority non-filtered pattern on the same bar can still show.
              if(apply_filter)
              {
                  int fidx = TypeIndex(p.TypePattern());
                  ENUM_PATTERN_DIRECTION dir = p.Direction();
                  if(fidx >= 0 && fidx < PATTERNS_TOTAL)
                      if((dir == PATTERN_DIRECTION_BULLISH && !m_show_bull[fidx]) ||
                        (dir == PATTERN_DIRECTION_BEARISH && !m_show_bear[fidx]))
                      {
                          if(p.HasBitmap() && p.GetBitmap().IsVisible()) p.GetBitmap().Hide();
                          continue;  // skip: does not count as covering the bar
                      }
              }
              // -----------------------------------------------

              int      tf_ps = (int)::PeriodSeconds(tf);
              datetime t_new = (datetime)p.GetProperty(PATTERN_PROP_TIME);
              datetime t_old = t_new - (datetime)((n - 1) * tf_ps);

              // Hide if outside visible range
              if(t_new < t_from || t_old > t_to)
              {
                  if(p.HasBitmap() && p.GetBitmap().IsVisible()) p.GetBitmap().Hide();
                  continue;
              }

              // Hide if the same confirmation bar already has a higher-or-equal priority pattern
              bool same_bar_higher_priority = false;
              for(int j = 0; j < n_drawn; j++)
                  if(drawn_candle_count[j] >= pass && drawn_confirmation_bar[j] == t_new)
                  { same_bar_higher_priority = true; break; }
              if(same_bar_higher_priority)
              {
                  if(p.HasBitmap() && p.GetBitmap().IsVisible()) p.GetBitmap().Hide();
                  continue;
              }

              // Register this bar as occupied by a pattern of candle count = pass
              ::ArrayResize(drawn_confirmation_bar, n_drawn + 1);
              ::ArrayResize(drawn_candle_count,     n_drawn + 1);
              drawn_confirmation_bar[n_drawn] = t_new;
              drawn_candle_count[n_drawn]     = n;
              n_drawn++;

              // Show existing bitmap or create a new one
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

      // Seed coverage from already-visible patterns
        datetime drawn_confirmation_bar[];
        int      drawn_candle_count[];
        int      n_drawn = 0;

      for(int i = 0; i < total; i++)
      {
          CBarPattern *p = plist.At(i);
          if(p == NULL || !p.HasBitmap() || !p.GetBitmap().IsVisible()) continue;
          ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
          if(tf != m_period) continue;
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
              if(tf != m_period) continue;
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

              // Remove lower-priority bitmaps at the SAME confirmation bar
              for(int k = 0; k < total; k++)
              {
                  CBarPattern *pk = plist.At(k);
                  if(pk == NULL || !pk.HasBitmap()) continue;
                  ENUM_TIMEFRAMES tfk = (ENUM_TIMEFRAMES)(long)pk.GetProperty(PATTERN_PROP_PERIOD);
                  if(tfk != m_period) continue;
                  int      nk  = (int)pk.GetProperty(PATTERN_PROP_CANDLES);
                  if(nk >= n)  continue;
                  datetime t_nk = (datetime)pk.GetProperty(PATTERN_PROP_TIME);
                  if(t_nk == t_new)   // same confirmation bar, lower priority → replace
                      pk.ClearBitmap();
              }

              ::ArrayResize(drawn_confirmation_bar, n_drawn + 1);
              ::ArrayResize(drawn_candle_count,     n_drawn + 1);
              drawn_confirmation_bar[n_drawn] = t_new;
              drawn_candle_count[n_drawn]     = n;
              n_drawn++;
              CreatePatternBitmap(p);
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

      // Seed coverage from already-visible non-filtered patterns
      datetime drawn_confirmation_bar[];
      int      drawn_candle_count[];
      int      n_drawn = 0;

      for(int i = 0; i < total; i++)
      {
          CBarPattern *p = plist.At(i);
          if(p == NULL || !p.HasBitmap() || !p.GetBitmap().IsVisible()) continue;
          ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)(long)p.GetProperty(PATTERN_PROP_PERIOD);
          if(tf != m_period) continue;

          // Don't count filtered patterns as occupying their bar
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
              if(tf != m_period) continue;

              // Filter check — filtered pattern skipped, does not occupy bar
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

              // Replace lower-priority bitmaps at same confirmation bar
              for(int k = 0; k < total; k++)
              {
                  CBarPattern *pk = plist.At(k);
                  if(pk == NULL || !pk.HasBitmap()) continue;
                  ENUM_TIMEFRAMES tfk = (ENUM_TIMEFRAMES)(long)pk.GetProperty(PATTERN_PROP_PERIOD);
                  if(tfk != m_period) continue;
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
