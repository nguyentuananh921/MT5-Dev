//+------------------------------------------------------------------+
//|                                          PatternRenderer.mqh     |
//|                                         Copyright 2025, Anhnt    |
//+------------------------------------------------------------------+
//| GUI renderer for CBarPattern Pure Data objects.                  |
//| Draws a CGCnvBitmap marker on the chart for each detected        |
//| pattern. Caller provides the shared pattern list (CArrayObj*)    |
//| that was passed into CBarPatternsControl at construction time.   |
//+------------------------------------------------------------------+
#ifndef __PATTERN_RENDERER_MQH__
#define __PATTERN_RENDERER_MQH__
  //+------------------------------------------------------------------+
  //| Include files                                                    |
  //+------------------------------------------------------------------+
  #include "..\GCnvBitmap.mqh"
  #include "..\GraphElmControl.mqh"
  #include "..\..\Timeseries\Bars\BarSeriesPatterns\Pattern.mqh"

  #ifndef CPATTERNRENDERER_MQH_DECLARATION
  #define CPATTERNRENDERER_MQH_DECLARATION
   //+------------------------------------------------------------------+
   //| Renders CBarPattern objects as CGCnvBitmap markers on chart      |
   //+------------------------------------------------------------------+
  class CPatternRenderer
   {
    private:
      CGraphElmControl  m_ctrl;
      CArrayObj         m_list_bitmaps;
      long              m_chart_id;
      int               m_subwin;
      int               m_obj_id;

      color             ColorByType(const ENUM_PATTERN_TYPE type)  const;
      int               BitmapWidth(void)                          const;
      int               BitmapHeight(const CBarPattern *p)         const;
      void              DrawView(CGCnvBitmap *bitmap, const ENUM_PATTERN_TYPE type);
      bool              CreateForPattern(const CBarPattern *pattern);

    public:
      bool              OnInitEvent(const long chart_id, const int subwin);
      void              OnDeinitEvent(void);
      //--- Rebuild all markers from the pattern list
      void              Refresh(CArrayObj *pattern_list);
      //--- Remove all markers from chart
      void              Clear(void);
   };
  #endif // CPATTERNRENDERER_MQH_DECLARATION
  #ifndef CPATTERNRENDERER_MQH_IMPLEMENTATION
  #define CPATTERNRENDERER_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Init                                                             |
   //+------------------------------------------------------------------+
   bool CPatternRenderer::OnInitEvent(const long chart_id, const int subwin)
    {
      m_chart_id = (chart_id == 0 || chart_id == NULL ? ::ChartID() : chart_id);
      m_subwin   = subwin;
      m_obj_id   = 0;
      m_list_bitmaps.Clear();
      m_list_bitmaps.FreeMode(true);
      return true;
    }
   //+------------------------------------------------------------------+
   //| Deinit                                                           |
   //+------------------------------------------------------------------+
   void CPatternRenderer::OnDeinitEvent(void)
    {
      Clear();
    }
   //+------------------------------------------------------------------+
   //| Return bitmap fill color for a given pattern type                |
   //+------------------------------------------------------------------+
   color CPatternRenderer::ColorByType(const ENUM_PATTERN_TYPE type) const
    {
      switch(type)
        {
        case PATTERN_TYPE_INSIDE_BAR  : return clrLightGray;
        case PATTERN_TYPE_OUTSIDE_BAR : return clrLightSteelBlue;
        case PATTERN_TYPE_PIN_BAR     : return clrLightCoral;
        default                       : return clrLightGray;
      }
    }
   //+------------------------------------------------------------------+
   //| Bitmap width based on current chart scale                        |
   //+------------------------------------------------------------------+
   int CPatternRenderer::BitmapWidth(void) const
    {
      int scale = (int)::ChartGetInteger(m_chart_id, CHART_SCALE);
      return (int)(1 << scale) * 3;
    }
   //+------------------------------------------------------------------+
   //| Bitmap height proportional to mother bar price range             |
   //+------------------------------------------------------------------+
   int CPatternRenderer::BitmapHeight(const CBarPattern *p) const
    {
      if(p == NULL) return 4;
      double price_max = ::ChartGetDouble(m_chart_id, CHART_PRICE_MAX);
      double price_min = ::ChartGetDouble(m_chart_id, CHART_PRICE_MIN);
      double range     = price_max - price_min;
      if(range <= 0) return 4;
      int    chart_h   = (int)::ChartGetInteger(m_chart_id, CHART_HEIGHT_IN_PIXELS);
      double bar_range = p.MotherBarHigh() - p.MotherBarLow();
      int    h         = (int)::MathRound(chart_h * bar_range / range);
      return(h < 4 ? 4 : h);
    }
   //+------------------------------------------------------------------+
   //| Draw filled rectangle on bitmap canvas (same style as 14710)    |
   //+------------------------------------------------------------------+
   void CPatternRenderer::DrawView(CGCnvBitmap *bitmap, const ENUM_PATTERN_TYPE type)
    {
      if(bitmap == NULL) return;
      int   w   = bitmap.Width();
      int   h   = bitmap.Height();
      color clr = ColorByType(type);
      int   cx  = w / 2 - (int)(1 << (int)::ChartGetInteger(m_chart_id, CHART_SCALE)) / 2;
      bitmap.Erase(CLR_CANV_NULL, 0);
      bitmap.DrawRectangleFill(cx, 0, w - 1, h - 1, clr, 80);
      bitmap.DrawRectangle(cx, 0, w - 1, h - 1, clrGray);
      bitmap.Update(false);
    }
   //+------------------------------------------------------------------+
   //| Create one bitmap marker for the given pattern                   |
   //+------------------------------------------------------------------+
   bool CPatternRenderer::CreateForPattern(const CBarPattern *pattern)
    {
      if(pattern == NULL) return false;
      datetime time  = pattern.MotherBarTime();
      double   price = (pattern.MotherBarHigh() + pattern.MotherBarLow()) / 2.0;
      int      w     = BitmapWidth();
      int      h     = BitmapHeight(pattern);
      string   name  = "PR_" + pattern.Symbol() + "_" +
                        ::EnumToString(pattern.TypePattern()) + "_" + (string)time;
      CGCnvBitmap *bitmap = m_ctrl.CreateBitmap(m_obj_id++, m_chart_id, m_subwin,
                                                 name, time, price, w, h, clrNONE);
      if(bitmap == NULL) return false;
      ::ObjectSetInteger(m_chart_id, bitmap.Name(), OBJPROP_ANCHOR,  ANCHOR_CENTER);
      ::ObjectSetString(m_chart_id,  bitmap.Name(), OBJPROP_TOOLTIP, "\n");
      DrawView(bitmap, pattern.TypePattern());
      bitmap.Show(false);
      return m_list_bitmaps.Add(bitmap);
    }
   //+------------------------------------------------------------------+
   //| Remove all bitmap markers from chart                             |
   //+------------------------------------------------------------------+
   void CPatternRenderer::Clear(void)
    {
      for(int i = m_list_bitmaps.Total() - 1; i >= 0; i--)
      {
        CGCnvBitmap *bmp = m_list_bitmaps.At(i);
        if(bmp != NULL) bmp.Hide(false);
      }
      m_list_bitmaps.Clear();
      ::ChartRedraw(m_chart_id);
    }
   //+------------------------------------------------------------------+
   //| Rebuild all markers from a flat CArrayObj of CBarPattern         |
   //+------------------------------------------------------------------+
   void CPatternRenderer::Refresh(CArrayObj *pattern_list)
    {
      if(pattern_list == NULL) return;
      Clear();
      int total = pattern_list.Total();
      for(int i = 0; i < total; i++)
        {
         CBarPattern *p = pattern_list.At(i);
         if(p == NULL) continue;
         CreateForPattern(p);
        }
      ::ChartRedraw(m_chart_id);
    }

#endif // CPATTERNRENDERER_MQH_IMPLEMENTATION
#endif // __PATTERN_RENDERER_MQH__
