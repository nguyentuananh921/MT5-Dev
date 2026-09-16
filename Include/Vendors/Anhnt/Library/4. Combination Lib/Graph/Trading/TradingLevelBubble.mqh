//+------------------------------------------------------------------+
//|                                           TradingLevelBubble.mqh |
//|Topic link https://www.mql5.com/en/articles/20892                 |
//|Topic link https://www.mql5.com/en/articles/3236                  |
//+------------------------------------------------------------------+

#ifndef __TRADING_LEVEL_BUBBLE_MQH__
#define __TRADING_LEVEL_BUBBLE_MQH__
 #include <Canvas\Canvas.mqh>
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\..\Collections\MarketCollection.mqh"   // CMarketCollection + CMarketPosition
 #include "..\..\Trading\TradingControl.mqh"         // CTradingControl
 #include "..\..\Services\MouseCombine.mqh"
 #include "..\GBase\GBaseObj.mqh"                    // CGBaseObj - shared Layer-3 graphic-object identity (name/chart_id/species)
 #include "..\..\Collections\ChartObjCollection.mqh" // CChartObjCollection - CHART_OBJ_EVENT_CHART_*_CHANGE (real symbol/TF change signal)
 #include "..\..\GUI Lib\Controls\Window.mqh"        // CWindow::CustomEventChartState - see SetWindow()
 //+------------------------------------------------------------------+
 //| Bubble type: which SL/TP level this bubble represents            |
 //+------------------------------------------------------------------+
 enum ENUM_BUBBLE_TYPE
  {
    BUBBLE_SL_BUY  = 0,
    BUBBLE_TP_BUY  = 1,
    BUBBLE_SL_SELL = 2,
    BUBBLE_TP_SELL = 3,
    BUBBLE_TOTAL   = 4
  };
  //--- Bubble geometry
   #define BUBBLE_TIP_W   18    // triangle tip width in pixels (horizontal extent of the arrow)
   #define BUBBLE_BDY_W   155   // rectangle body width in pixels
   #define BUBBLE_BDY_H   52    // total bubble height in pixels (half = 26px above/below center)
   #define BUBBLE_XSZ     18    // X close button square size in pixels
   #define BUBBLE_RPAD    52    // right padding from chart right edge to bubble tip (fallback only)
   #define BUBBLE_LOOKAHEAD 30  // pixels between the last bar's real X and the bubble tip
   #define BUBBLE_BDR_W   3     // border thickness in pixels (outer minus inner fill offset)
  //--- Bubble colors
    #define BUBBLE_CLR_BG         clrWhiteSmoke    // shared background fill for all bubbles
    #define BUBBLE_CLR_BUY        clrMediumSeaGreen // border color for Buy-side bubbles (SL + TP)
    #define BUBBLE_CLR_SELL       clrCrimson        // border color for Sell-side bubbles (SL + TP)
    #define BUBBLE_CLR_LABEL      clrDimGray        // price label text color
    #define BUBBLE_CLR_PROFIT_POS clrLimeGreen      // P&L text when profit is positive
    #define BUBBLE_CLR_PROFIT_NEG clrTomato         // P&L text when profit is negative
 //+------------------------------------------------------------------+
 //| Clickable / draggable region on canvas                           |
 //+------------------------------------------------------------------+
 struct SBubbleBox
  {
    bool             active;
    ENUM_BUBBLE_TYPE type;
    int              x1, y1, x2, y2;
  }; 
#ifndef CTRADING_LEVEL_BUBBLE_DECLARATION
#define CTRADING_LEVEL_BUBBLE_DECLARATION 
 class CTradingLevelBubble : public CGBaseObj
  {
   private:
    CCanvas              m_canvas;                     // Object drawing
    CMarketCollection    *m_market_collection;         // Collection of market orders and deals Trading Engine Own
    CTradingControl      *m_trading_control;           // Trading management object CTradingEngine own it
    CChartObjCollection  *m_chart_obj_collection;      // BORROWED - EA owns it
    CWindow              *m_window_main;                    // BORROWED - CGUIPannel owns it, see SetWindow()
    bool                 m_created;                    // canvas exists - set by OnInitEvent()
    bool                 m_orig_chart_shift;           // CHART_SHIFT value before we forced it on, restored on deinit
    bool                 m_need_resize;                // set true bởi CHARTEVENT_CHART_CHANGE (zoom/scroll)
    bool                 m_need_redraw;                // set true bởi CHARTEVENT_CHART_CHANGE (zoom/scroll)
    double               m_last_sl_buy;
    double               m_last_tp_buy;
    double               m_last_sl_sell;
    double               m_last_tp_sell;
    int                  m_drag_offset_y;
    CMouseCombine        *m_mouse;
    // Drag state
     bool                 m_is_dragging;
     ENUM_BUBBLE_TYPE     m_drag_type;
     int                  m_drag_y;             // current drag Y in pixels
     int                  m_drag_bx;            // X frozen at drag-start - see DrawBubble() note
    //Add properties here
     int                  m_drag_anchor_y;      // Y anchor at drag-start (pixel)
     double               m_drag_price_anchor;  // price at anchor (capture at drag-start)
     double               m_price_per_pixel;    // price change per vertical pixel at drag-start
    //Mouse State
     bool                 m_prev_left_btn;      // previous MOUSE_MOVE's button state - see OnChartEvent note
     bool                 m_prev_over;          // previous MOUSE_MOVE's dragbox-hover state     
     bool                 m_scroll_locked_by_me;
    // Interaction boxes (one slot per ENUM_BUBBLE_TYPE)
     SBubbleBox           m_hitbox[BUBBLE_TOTAL];     // X close button
     SBubbleBox           m_dragbox[BUBBLE_TOTAL];    // draggable body
    // Internal helpers
     void                 DrawBubble(ENUM_BUBBLE_TYPE type, int y_pixel);
     string               BubbleLabel(ENUM_BUBBLE_TYPE type, double price);
     int                  PriceToY(double price);
     int                  AnchorBX(void);
     void                 ResolveOverlap(int &ya, int &yb, bool a_dragged, bool b_dragged);

   public:
                         CTradingLevelBubble(void);
                         ~CTradingLevelBubble(void);
    bool                 OnInitEvent(void);
    void                 OnDeinitEvent(void);
    //void                 OnTickEvent(void);
    void                 OnPoll(void);
    void                 OnChartEvent(const int id, const long &lparam,
                                     const double &dparam, const string &sparam);
    bool                 IsDragging(void) const { return m_is_dragging; }
    void                 Draw(void);
    //For pointer
     void                 MousePointer(CMouseCombine &object)                 { m_mouse = GetPointer(object);        }
     void                 SetMarketCollection(CMarketCollection *market)      { m_market_collection = market;                   }
     void                 SetTradingControl(CTradingControl *trading_control) { m_trading_control = trading_control; }
     void SetChartObjCollection(CChartObjCollection *coll)    { m_chart_obj_collection = coll;        }
     void SetWindow(CWindow *window)                          { m_window_main = window;                    }
};
#endif // CTRADING_LEVEL_BUBBLE_DECLARATION
#ifndef CTRADING_LEVEL_BUBBLE_IMPLEMENTATION
#define CTRADING_LEVEL_BUBBLE_IMPLEMENTATION
 CTradingLevelBubble::CTradingLevelBubble(void)
    : m_created(false),
      m_orig_chart_shift(true),
      m_need_resize(true),
      m_need_redraw(true),
      m_is_dragging(false),
      m_drag_type(BUBBLE_SL_BUY),
      m_drag_y(0), m_drag_bx(0),
      //Adding new Properties in constructor
       m_drag_anchor_y(0), m_drag_price_anchor(0.0), m_price_per_pixel(0.0),
      m_prev_left_btn(false), m_prev_over(false), m_scroll_locked_by_me(false), m_market_collection(NULL),
      m_trading_control(NULL),
      m_chart_obj_collection(NULL),
      m_window_main(NULL),
      m_drag_offset_y(0),
      m_mouse(NULL),
      m_last_sl_buy(0), m_last_tp_buy(0),
      m_last_sl_sell(0), m_last_tp_sell(0)
  {
    for(int i = 0; i < BUBBLE_TOTAL; i++)
    {
        m_hitbox[i].active  = false;
        m_dragbox[i].active = false;
    }
     this.SetName(::MQLInfoString(MQL_PROGRAM_NAME) + "_TradingLevelBubble");
     this.SetChartID(::ChartID());
     this.SetBelong(GRAPH_OBJ_BELONG_PROGRAM);
     this.SetSpecies(GRAPH_OBJ_SPECIES_GRAPHICAL);
     this.m_type = OBJECT_DE_TYPE_TRADING_LEVEL_BUBBLE;
  }
 CTradingLevelBubble::~CTradingLevelBubble(void) {}
 //+------------------------------------------------------------------+
 bool CTradingLevelBubble::OnInitEvent(void)
  {
    // m_market_collection/m_trading_control are set once (before this runs) - every event-driven
    // path below trusts them from here on, no per-call NULL check needed.
    if(m_market_collection == NULL || m_trading_control == NULL) return false;
    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
    ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, false); // hide MT5 default lines - this class owns dragging now    
    m_orig_chart_shift = (bool)ChartGetInteger(0, CHART_SHIFT);
    ChartSetInteger(0, CHART_SHIFT, true);
    int w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
    int h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);    
    if(w <= 0 || h <= 0)
       return false;
    m_canvas.Destroy();
    if(!m_canvas.CreateBitmapLabel("TradingLevelBubbleCanvas", 0, 0, w, h,
                                   COLOR_FORMAT_ARGB_NORMALIZE))
        return false;

    m_canvas.FontSet("Calibri", 18, FW_BOLD);
    m_created = true;
    Draw(); // catch positions/SL/TP that already existed before this class started listening
    return true;
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::OnDeinitEvent(void)
  {
    ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
    ChartSetInteger(0, CHART_AUTOSCROLL, true);
    ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, true); // restore
    ChartSetInteger(0, CHART_SHIFT, m_orig_chart_shift); // restore
    m_canvas.Destroy();
    m_created = false;
    ChartRedraw();
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::OnPoll(void)
  {
   if(!m_created || m_mouse == NULL) return;
   bool left_btn = m_mouse.IsLeftBtn();
   // End drag: button released without a MOUSE_MOVE event to catch it
    if(m_is_dragging && !left_btn)
     {
       // Use the frozen drag X captured at drag-start so horizontal mouse movement
       // (diagonal/sideways) doesn't change the mapped time coordinate.
        ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
        ChartSetInteger(0, CHART_AUTOSCROLL, true);
        m_scroll_locked_by_me = false;
        int dy = m_drag_y - m_drag_anchor_y;
        double new_price = m_drag_price_anchor + dy * m_price_per_pixel;
        ENUM_POSITION_TYPE modify_dir = (m_drag_type <= BUBBLE_TP_BUY) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
        bool modify_sl = (m_drag_type == BUBBLE_SL_BUY || m_drag_type == BUBBLE_SL_SELL);
        m_trading_control.ModifyPositions(_Symbol, modify_dir, modify_sl, new_price);
        m_is_dragging = false;
        Draw();
        return;
     }
   // While dragging, OnChartEvent(MOUSE_MOVE) already redraws each frame
    if(m_is_dragging) return;   
     {
      int mx = m_mouse.X(), my = m_mouse.Y();
      bool over_now = false;
      for(int i = 0; i < BUBBLE_TOTAL; i++)
       {
        if(!m_dragbox[i].active) continue;
        if(mx >= m_dragbox[i].x1 && mx <= m_dragbox[i].x2 &&
           my >= m_dragbox[i].y1 && my <= m_dragbox[i].y2)
           { over_now = true; break; }
       }       
      if(!over_now && m_scroll_locked_by_me)
       {
         ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
         ChartSetInteger(0, CHART_AUTOSCROLL, true);
         m_scroll_locked_by_me = false;
       }
     }
    // Canvas resize check
     static uint last_resize_ms = 0;
     uint now_rc = GetTickCount();
     if(now_rc - last_resize_ms >= 250)
      {
       last_resize_ms = now_rc;
       int chart_w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
       int chart_h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
       if(chart_w != m_canvas.Width() || chart_h != m_canvas.Height())
        {
         m_need_resize = true;
         Draw();
        }
      }
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::OnChartEvent(const int id, const long &lparam,
                                     const double &dparam, const string &sparam)
  {
    if(!m_created) return;
    if(id == CHARTEVENT_CHART_CHANGE)
     {
       m_need_redraw = true;
       Draw(); // zoom/scroll moves bubble pixel position even if SL/TP price didn't change
       return;
     }
    if(m_chart_obj_collection != NULL &&
       (id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_SYMB_CHANGE ||
        id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_TF_CHANGE ||
        id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE))
     {
       m_need_redraw = true;
       Draw();
       return;
     }    
    if(id >= CHARTEVENT_CUSTOM)
     {
        ushort trade_event = (ushort)(id - CHARTEVENT_CUSTOM);
        if(trade_event == (ushort)TRADE_EVENT_MODIFY_POSITION_SL    ||
           trade_event == (ushort)TRADE_EVENT_MODIFY_POSITION_TP    ||
           trade_event == (ushort)TRADE_EVENT_MODIFY_POSITION_SL_TP ||
           trade_event == (ushort)TRADE_EVENT_POSITION_OPENED       ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED)
            Draw();
        return;
     }
    if(id == CHARTEVENT_MOUSE_MOVE)
     {
        int mx = (int)lparam, my = (int)dparam;
        uint state    = (uint)StringToInteger(sparam);
        bool left_btn = ((state & 1) != 0);  // bit 0 = left mouse button

        bool over = false; int over_idx = -1;
        for(int i = 0; i < BUBBLE_TOTAL; i++)
         {
            if(!m_dragbox[i].active) continue;
            if(mx >= m_dragbox[i].x1 && mx <= m_dragbox[i].x2 &&
              my >= m_dragbox[i].y1 && my <= m_dragbox[i].y2)
            { over = true; over_idx = i; break; }
         }        
        bool wandered_in   = left_btn && m_prev_left_btn && !m_prev_over;
        bool safe_to_engage = !wandered_in;

        bool lock = m_is_dragging || (over && safe_to_engage);
        if(lock)
          {
           // CWindow::SetChartState() runs right after this same event and would otherwise
           // flip CHART_MOUSE_SCROLL back on (it only sees "mouse is over the chart, not the
           // panel") - going through its own m_custom_event_chart_state flag instead of a raw
           // ChartSetInteger makes it agree with us for this event.
           if(m_window_main != NULL) m_window_main.CustomEventChartState(true);
           ChartSetInteger(0, CHART_AUTOSCROLL,   false);
           m_scroll_locked_by_me = true;
          }
        else if(m_scroll_locked_by_me)
          {
           ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
           ChartSetInteger(0, CHART_AUTOSCROLL,   true);
           m_scroll_locked_by_me = false;
          }        
        if(!m_is_dragging && left_btn && over && over_idx >= 0 && safe_to_engage)
         {
            ENUM_BUBBLE_TYPE btype = m_dragbox[over_idx].type;
            bool is_buy = (btype == BUBBLE_SL_BUY || btype == BUBBLE_TP_BUY);
            bool is_sl  = (btype == BUBBLE_SL_BUY || btype == BUBBLE_SL_SELL);
            ENUM_POSITION_TYPE dir = is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
            double price  = is_sl ? m_market_collection.GetSL(_Symbol, dir) : m_market_collection.GetTP(_Symbol, dir);
            int    anchor = PriceToY(price);
            m_is_dragging   = true;
            m_drag_type     = btype;
            m_drag_y        = anchor;
            m_drag_bx       = AnchorBX(); // frozen for the whole drag - see DrawBubble() note

            // capture pixel anchor and price-per-pixel at drag-start
              m_drag_anchor_y = anchor;
              {
                datetime ttmp; double p0 = 0.0, p1 = 0.0; int sub;
                if(ChartXYToTimePrice(0, m_drag_bx, m_drag_anchor_y, sub, ttmp, p0) &&
                  ChartXYToTimePrice(0, m_drag_bx, m_drag_anchor_y + 1, sub, ttmp, p1))
                {
                    m_drag_price_anchor = p0;
                    m_price_per_pixel   = p1 - p0;
                    if(MathAbs(m_price_per_pixel) < 1e-12)
                        m_price_per_pixel = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
                }
                else
                {
                    // fallback: use current SL/TP and tick step
                    ENUM_POSITION_TYPE dir = is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
                    m_drag_price_anchor = is_sl ? m_market_collection.GetSL(_Symbol, dir) : m_market_collection.GetTP(_Symbol, dir);
                    m_price_per_pixel   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
                }

              }
            m_drag_offset_y = my - anchor;
            if(m_window_main != NULL) m_window_main.CustomEventChartState(true);
            ChartSetInteger(0, CHART_AUTOSCROLL, false);
         }
        if(m_is_dragging)
         {
            m_drag_y = my - m_drag_offset_y;
            Draw();
         }
        m_prev_left_btn = left_btn;
        m_prev_over     = over;
        return;
     }
    if(id != CHARTEVENT_CLICK) return;
    int mx = (int)lparam;
    int my = (int)dparam;
    for(int i = 0; i < BUBBLE_TOTAL; i++)
     {
        if(!m_hitbox[i].active) continue;
        if(mx >= m_hitbox[i].x1 && mx <= m_hitbox[i].x2 &&
           my >= m_hitbox[i].y1 && my <= m_hitbox[i].y2)
        {
            ENUM_POSITION_TYPE dir = (i <= BUBBLE_TP_BUY)
                                    ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
            m_trading_control.ClosePositions(_Symbol, dir);
            Draw();
            return;
        }
     }
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::Draw(void)
  {
    if(!m_created) return; // canvas not created yet
    ulong t0 = ::GetMicrosecondCount();
    double sl_buy  = m_market_collection.GetSL(_Symbol, POSITION_TYPE_BUY);
    double tp_buy  = m_market_collection.GetTP(_Symbol, POSITION_TYPE_BUY);
    double sl_sell = m_market_collection.GetSL(_Symbol, POSITION_TYPE_SELL);
    double tp_sell = m_market_collection.GetTP(_Symbol, POSITION_TYPE_SELL);

    ulong fetch_us = ::GetMicrosecondCount() - t0;

    bool unchanged = !m_need_resize && !m_need_redraw && !m_is_dragging &&
                 sl_buy == m_last_sl_buy && tp_buy == m_last_tp_buy &&
                 sl_sell == m_last_sl_sell && tp_sell == m_last_tp_sell;
    if(unchanged)
     {
        ulong us = ::GetMicrosecondCount() - t0;
        if(us > 1000)
           ::Print("PERF CTradingLevelBubble::Draw(skip) us= ", us, " fetch=", fetch_us, "us");
        return;
     }
    m_last_sl_buy = sl_buy;  m_last_tp_buy = tp_buy;
    m_last_sl_sell = sl_sell; m_last_tp_sell = tp_sell;
    m_need_redraw = false;

    if(m_need_resize)
     {
        int w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
        int h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
        if(w != m_canvas.Width() || h != m_canvas.Height())
            m_canvas.Resize(w, h);
        m_need_resize = false;
     }
    m_canvas.Erase(0x00000000); // transparent
    for(int i = 0; i < BUBBLE_TOTAL; i++)
     {
        m_hitbox[i].active  = false;
        m_dragbox[i].active = false;
     }
    if(sl_buy > 0 || tp_buy > 0)
     {
      int y_sl = -1, y_tp = -1;
      if(sl_buy > 0) y_sl = (m_is_dragging && m_drag_type == BUBBLE_SL_BUY) ? m_drag_y : PriceToY(sl_buy);
      if(tp_buy > 0) y_tp = (m_is_dragging && m_drag_type == BUBBLE_TP_BUY) ? m_drag_y : PriceToY(tp_buy);
      ResolveOverlap(y_sl, y_tp,
                     m_is_dragging && m_drag_type == BUBBLE_SL_BUY,
                     m_is_dragging && m_drag_type == BUBBLE_TP_BUY);
      if(sl_buy > 0 && y_sl >= 0) DrawBubble(BUBBLE_SL_BUY, y_sl);
      if(tp_buy > 0 && y_tp >= 0) DrawBubble(BUBBLE_TP_BUY, y_tp);
     }
    if(sl_sell > 0 || tp_sell > 0)
     {
      int y_sl = -1, y_tp = -1;
      if(sl_sell > 0) y_sl = (m_is_dragging && m_drag_type == BUBBLE_SL_SELL) ? m_drag_y : PriceToY(sl_sell);
      if(tp_sell > 0) y_tp = (m_is_dragging && m_drag_type == BUBBLE_TP_SELL) ? m_drag_y : PriceToY(tp_sell);
      ResolveOverlap(y_sl, y_tp,
                     m_is_dragging && m_drag_type == BUBBLE_SL_SELL,
                     m_is_dragging && m_drag_type == BUBBLE_TP_SELL);
      if(sl_sell > 0 && y_sl >= 0) DrawBubble(BUBBLE_SL_SELL, y_sl);
      if(tp_sell > 0 && y_tp >= 0) DrawBubble(BUBBLE_TP_SELL, y_tp);
     }
    m_canvas.Update();

    ulong us = ::GetMicrosecondCount() - t0;
    if(us > 1000)
       ::Print("PERF CTradingLevelBubble::Draw us= ", us, " fetch=", fetch_us, " us canvas= ", m_canvas.Width(), "x", m_canvas.Height());
  }
 //+------------------------------------------------------------------+
 //| Horizontal anchor: the last bar's actual on-screen X + a fixed   |
 //| look-ahead gap, clamped to never pass the chart's own right edge |
 //+------------------------------------------------------------------+
 int CTradingLevelBubble::AnchorBX(void)
  {
   int chart_w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int max_bx  = chart_w - BUBBLE_RPAD - BUBBLE_TIP_W - BUBBLE_BDY_W;

   int      last_x, dummy_y;
   datetime t0    = iTime(_Symbol, PERIOD_CURRENT, 0);
   bool     got_x = (t0 > 0) && ChartTimePriceToXY(0, 0, t0, 1.0, last_x, dummy_y);
   int      bx    = got_x ? last_x + BUBBLE_LOOKAHEAD : max_bx; // fallback if off-canvas
   if(bx > max_bx) bx = max_bx; // never past the chart's own right edge
   return bx;
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::DrawBubble(ENUM_BUBBLE_TYPE type, int by)
  {      
    int bx = (m_is_dragging && m_drag_type == type) ? m_drag_bx : AnchorBX();
    int half = BUBBLE_BDY_H / 2;

    // Flags
     bool is_sl  = (type == BUBBLE_SL_BUY  || type == BUBBLE_SL_SELL);
     bool is_buy = (type == BUBBLE_SL_BUY  || type == BUBBLE_TP_BUY);
    // Colors
     uint border_clr = ColorToARGB(is_sl  ? BUBBLE_CLR_SELL : BUBBLE_CLR_BUY);  // SL=red, TP=green
     uint label_clr  = ColorToARGB(is_buy ? BUBBLE_CLR_BUY  : BUBBLE_CLR_SELL); // Buy=green, Sell=red
     uint bg         = ColorToARGB(BUBBLE_CLR_BG);
    // Dashed horizontal level line
     uint line_clr = ColorToARGB(is_sl ? BUBBLE_CLR_SELL : BUBBLE_CLR_BUY, 180);
     int  dash_w = 10, gap_w = 5;
     for(int x = 0; x < bx; x += dash_w + gap_w)
      {
       int x2 = MathMin(x + dash_w - 1, bx - 1);
       m_canvas.LineHorizontal(x, x2, by - 1, line_clr);
       m_canvas.LineHorizontal(x, x2, by,     line_clr);
       m_canvas.LineHorizontal(x, x2, by + 1, line_clr);
      }
    // Bubble body
     int body_x1 = bx + BUBBLE_TIP_W;
     int body_x2 = bx + BUBBLE_TIP_W + BUBBLE_BDY_W;
     int body_y1 = by - half;
     int body_y2 = by + half;
    // Outer fill: border color (full size)
      m_canvas.FillTriangle(bx, by, bx + BUBBLE_TIP_W, by - half, bx + BUBBLE_TIP_W, by + half, border_clr);
      m_canvas.FillRectangle(body_x1, body_y1, body_x2, body_y2, border_clr);

    // Inner fill: background (inset BUBBLE_BDR_W — no left inset on rect = no left border)
      m_canvas.FillTriangle(bx + BUBBLE_BDR_W, by,
                            bx + BUBBLE_TIP_W,  by - half + BUBBLE_BDR_W,
                            bx + BUBBLE_TIP_W,  by + half - BUBBLE_BDR_W, bg);
      m_canvas.FillRectangle(body_x1, body_y1 + BUBBLE_BDR_W, body_x2 - BUBBLE_BDR_W, body_y2 - BUBBLE_BDR_W, bg);

      // X close button
      int btn_x1 = body_x2 - BUBBLE_XSZ - 4;
      int btn_y1 = by - BUBBLE_XSZ / 2;
      int btn_x2 = btn_x1 + BUBBLE_XSZ;
      int btn_y2 = btn_y1 + BUBBLE_XSZ;
      m_canvas.FillRectangle(btn_x1, btn_y1, btn_x2, btn_y2, ColorToARGB(clrFireBrick));
      m_canvas.TextOut(btn_x1 + BUBBLE_XSZ / 2, by, "X", ColorToARGB(clrWhite), TA_CENTER | TA_VCENTER);

      // Price label (top): drag price during drag, else stored SL/TP
      double display_price = 0;
      if(m_is_dragging && m_drag_type == type)
      {
          int dy = m_drag_y - m_drag_anchor_y;
          display_price = m_drag_price_anchor + dy * m_price_per_pixel;
      }
      else
      {
          ENUM_POSITION_TYPE dir = is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
          display_price = is_sl ? m_market_collection.GetSL(_Symbol, dir) : m_market_collection.GetTP(_Symbol, dir);
      }
      string lbl = BubbleLabel(type, display_price);
      m_canvas.TextOut(body_x1 + 8, by - 12, lbl, label_clr, TA_LEFT | TA_VCENTER);

      // P&L label (bottom): color by sign
      double pnl     = (display_price > 0)
                        ? m_market_collection.SumFloatingProfit(_Symbol, is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL, display_price)
                        : 0;
      string pnl_str = (pnl >= 0 ? "+" : "") + DoubleToString(pnl, 2) + " $";
      uint   pnl_clr = ColorToARGB(pnl >= 0 ? BUBBLE_CLR_PROFIT_POS : BUBBLE_CLR_PROFIT_NEG);
      m_canvas.TextOut(body_x1 + 8, by + 12, pnl_str, pnl_clr, TA_LEFT | TA_VCENTER);

      // Register hitbox (X button) — expand slightly for easier clicking
      int hit_pad = 6;
      m_hitbox[type].active = true;
      m_hitbox[type].type   = type;
      m_hitbox[type].x1     = MathMax(0, btn_x1 - hit_pad);
      m_hitbox[type].y1     = MathMax(0, btn_y1 - hit_pad);
      m_hitbox[type].x2     = btn_x2 + hit_pad;
      m_hitbox[type].y2     = btn_y2 + hit_pad;

      // Register drag zone — spans the WHOLE horizontal level line (x=0..bx), same grab target
      // native MT5 SL/TP lines give, not just the flag body on the right edge.
      int drag_pad_y = 4;
      m_dragbox[type].active = true;
      m_dragbox[type].type   = type;
      m_dragbox[type].x1     = 0;
      m_dragbox[type].y1     = body_y1 - drag_pad_y;
      m_dragbox[type].x2     = MathMin(body_x2, btn_x1 - 4);
      m_dragbox[type].y2     = body_y2 + drag_pad_y;
  }
 //+------------------------------------------------------------------+
 int CTradingLevelBubble::PriceToY(double price)
  {
    int x, y;
    datetime t = iTime(_Symbol, PERIOD_CURRENT, 0);
    if(!ChartTimePriceToXY(0, 0, t, price, x, y)) return -1;
    return y;
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::ResolveOverlap(int &ya, int &yb, bool a_dragged, bool b_dragged)
  {
    if(ya < 0 || yb < 0) return;
    if(MathAbs(ya - yb) >= BUBBLE_BDY_H + 2) return;
    //int gap = BDY_H + 2;
    int gap = BUBBLE_BDY_H + BUBBLE_BDY_W + 6;
    if(a_dragged)
        yb = (ya >= yb) ? ya - gap : ya + gap;
    else if(b_dragged)
        ya = (yb >= ya) ? yb - gap : yb + gap;
    else
     {
        int mid = (ya + yb) / 2;
        int half = gap / 2;
        if(ya >= yb) { ya = mid + half; yb = mid - half; }
        else         { ya = mid - half; yb = mid + half; }
     }
  }
 string CTradingLevelBubble::BubbleLabel(ENUM_BUBBLE_TYPE type, double price)
  {
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    string prefix = "";
    switch(type)
    {
        case BUBBLE_SL_BUY:  prefix = "SL Buy  "; break;
        case BUBBLE_TP_BUY:  prefix = "TP Buy  "; break;
        case BUBBLE_SL_SELL: prefix = "SL Sell "; break;
        case BUBBLE_TP_SELL: prefix = "TP Sell "; break;
    }
    return prefix + DoubleToString(price, digits);
  }

#endif // CTRADING_LEVEL_BUBBLE_IMPLEMENTATION
#endif // __TRADING_LEVEL_BUBBLE_MQH__
