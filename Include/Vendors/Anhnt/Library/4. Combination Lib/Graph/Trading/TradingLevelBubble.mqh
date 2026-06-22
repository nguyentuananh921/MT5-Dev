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
 #include "..\..\Collections\MarketCollection.mqh"   // CMarketCollection + CMarketPosition + CTradingSelect
 #include "..\..\Trading\TradingControl.mqh"         // CTradingControl
 #include "..\..\Services\MouseCombine.mqh"
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
   #define BUBBLE_RPAD    52    // right padding from chart right edge to bubble tip
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
 //+------------------------------------------------------------------+
 //| CTradingLevelBubble                                              |
 //| Draws up to 4 price-anchored SL/TP bubbles on the chart canvas. |
 //| - Drag bubble  → modify SL or TP for all positions (same side). |
 //| - Click X btn  → close all positions on that side.              |
 //+------------------------------------------------------------------+
#ifndef CTRADING_LEVEL_BUBBLE_DECLARATION
#define CTRADING_LEVEL_BUBBLE_DECLARATION
 class CTradingLevelBubble
  {
   private:
    CCanvas            m_canvas;
    CMarketCollection *m_market;           // Collection of market orders and deals Trading Engine Own
    CTradingControl   *m_trading_control;  // Trading management object CTradingEngine own it
    bool               m_need_resize;
    bool               m_need_redraw;     // set true bởi CHARTEVENT_CHART_CHANGE (zoom/scroll)
    double             m_last_sl_buy; 
    double             m_last_tp_buy; 
    double             m_last_sl_sell; 
    double             m_last_tp_sell;

    int                m_drag_offset_y;    
    CMouseCombine     *m_mouse;
    // Drag state
     bool              m_is_dragging;
     ENUM_BUBBLE_TYPE  m_drag_type;
     int               m_drag_y;        // current drag Y in pixels
    // Interaction boxes (one slot per ENUM_BUBBLE_TYPE)
     SBubbleBox        m_hitbox[BUBBLE_TOTAL];   // X close button
     SBubbleBox        m_dragbox[BUBBLE_TOTAL];  // draggable body    
    //Calculation profit
     double CalcProfitAt(ENUM_BUBBLE_TYPE type, double target_price);
    // Internal helpers
     bool              HasBuys(void);
     bool              HasSells(void);
     double            GetSL(ENUM_POSITION_TYPE dir);
     double            GetTP(ENUM_POSITION_TYPE dir);
     void              DrawBubble(ENUM_BUBBLE_TYPE type, int y_pixel);
     void              CloseAll(ENUM_POSITION_TYPE dir);
     void              ModifyAll(ENUM_BUBBLE_TYPE type, double new_price);     
     string            BubbleLabel(ENUM_BUBBLE_TYPE type, double price);
     int               PriceToY(double price);
    void               ResolveOverlap(int &ya, int &yb, bool a_dragged, bool b_dragged);

public:
    CTradingLevelBubble(void);
   ~CTradingLevelBubble(void);

    bool OnInitEvent(void);
    void OnDeinitEvent(void);
    //void OnTickEvent(void);
    void OnPoll(void);
    void OnChartEvent(const int id, const long &lparam,
                      const double &dparam, const string &sparam);
    bool IsDragging(void) const { return m_is_dragging; }
    void Draw(void);

    //For pointer
     void MousePointer(CMouseCombine &object)                 { m_mouse = GetPointer(object);        }
     void SetMarketCollection(CMarketCollection *market)      { m_market = market;                   }
     void SetTradingControl(CTradingControl *trading_control) { m_trading_control = trading_control; }

    //void SetMagic(const ulong magic) { m_trade.SetExpertMagicNumber(magic); }
};
#endif // CTRADING_LEVEL_BUBBLE_DECLARATION

#ifndef CTRADING_LEVEL_BUBBLE_IMPLEMENTATION
#define CTRADING_LEVEL_BUBBLE_IMPLEMENTATION 

 CTradingLevelBubble::CTradingLevelBubble(void)
    : m_need_resize(true),
      m_need_redraw(true),
      m_is_dragging(false),
      m_drag_type(BUBBLE_SL_BUY),
      m_drag_y(0), m_market(NULL),
      m_trading_control(NULL), 
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
  }
 CTradingLevelBubble::~CTradingLevelBubble(void) {}

 //+------------------------------------------------------------------+
 bool CTradingLevelBubble::OnInitEvent(void)
  {
    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
    ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, false); // hide MT5 default lines
    m_canvas.Destroy();
    int w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
    int h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

    if(!m_canvas.CreateBitmapLabel("TradingLevelBubbleCanvas", 0, 0, w, h,
                                   COLOR_FORMAT_ARGB_NORMALIZE))
        return false;

    m_canvas.FontSet("Calibri", 18, FW_BOLD);
    Draw(); // populate bubbles for positions already open when EA attaches
    return true;
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::OnDeinitEvent(void)
  {
    ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
    ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, true); // restore
    m_canvas.Destroy();
    ChartRedraw();
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::OnPoll(void)
  {
   if(m_mouse == NULL) return;

   bool left_btn = m_mouse.IsLeftBtn();
   // End drag: button released without a MOUSE_MOVE event to catch it
    if(m_is_dragging && !left_btn)
     {
       int mx = m_mouse.X();
       ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
       datetime t; double new_price; int sub;
       ChartXYToTimePrice(0, mx, m_drag_y, sub, t, new_price);
       ModifyAll(m_drag_type, new_price);
       m_is_dragging = false;
       Draw();
       return;
     }
   // While dragging, OnChartEvent(MOUSE_MOVE) already redraws each frame
    if(m_is_dragging) return;

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
   // No periodic SL/TP scan anymore — Draw() is now triggered by real
   // CHARTEVENT_CUSTOM trade events (see OnChartEvent) instead of polling.
  }

 //+------------------------------------------------------------------+
 void CTradingLevelBubble::OnChartEvent(const int id, const long &lparam,
                                     const double &dparam, const string &sparam)
  {
    if(id == CHARTEVENT_CHART_CHANGE)
     {
       m_need_redraw = true;
       Draw(); // zoom/scroll moves bubble pixel position even if SL/TP price didn't change
       return;
     }
    // Trade event broadcast by CTradingEngine (CTradeEventsCollection) — react instead of polling
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
        ChartSetInteger(0, CHART_MOUSE_SCROLL, !over);

        // Begin drag immediately (no 16ms delay)
        if(!m_is_dragging && left_btn && over && over_idx >= 0)
        {
            ENUM_BUBBLE_TYPE btype = m_dragbox[over_idx].type;
            bool is_buy = (btype == BUBBLE_SL_BUY || btype == BUBBLE_TP_BUY);
            bool is_sl  = (btype == BUBBLE_SL_BUY || btype == BUBBLE_SL_SELL);
            ENUM_POSITION_TYPE dir = is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
            double price  = is_sl ? GetSL(dir) : GetTP(dir);
            int    anchor = PriceToY(price);
            m_is_dragging   = true;
            m_drag_type     = btype;
            m_drag_y        = anchor;
            m_drag_offset_y = my - anchor;
            ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
        }
        if(m_is_dragging)
        {
            m_drag_y = my - m_drag_offset_y;
            Draw();
        }
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
            CloseAll(dir);
            Draw();
            return;
        }
    }
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::Draw(void)
  {
    ulong t0 = ::GetMicrosecondCount();

    double sl_buy  = GetSL(POSITION_TYPE_BUY);
    double tp_buy  = GetTP(POSITION_TYPE_BUY);
    double sl_sell = GetSL(POSITION_TYPE_SELL);
    double tp_sell = GetTP(POSITION_TYPE_SELL);

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
 void CTradingLevelBubble::DrawBubble(ENUM_BUBBLE_TYPE type, int by)
  {
      int chart_w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);

      // Geometry
      int bx   = chart_w - BUBBLE_RPAD - BUBBLE_TIP_W - BUBBLE_BDY_W;
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
          datetime dt; int sub;
          ChartXYToTimePrice(0, bx, by, sub, dt, display_price);
      }
      else
      {
          ENUM_POSITION_TYPE dir = is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
          display_price = is_sl ? GetSL(dir) : GetTP(dir);
      }
      string lbl = BubbleLabel(type, display_price);
      m_canvas.TextOut(body_x1 + 8, by - 12, lbl, label_clr, TA_LEFT | TA_VCENTER);

      // P&L label (bottom): color by sign
      double pnl     = CalcProfitAt(type, display_price);
      string pnl_str = (pnl >= 0 ? "+" : "") + DoubleToString(pnl, 2) + " $";
      uint   pnl_clr = ColorToARGB(pnl >= 0 ? BUBBLE_CLR_PROFIT_POS : BUBBLE_CLR_PROFIT_NEG);
      m_canvas.TextOut(body_x1 + 8, by + 12, pnl_str, pnl_clr, TA_LEFT | TA_VCENTER);

      // Register hitbox (X button)
      m_hitbox[type].active = true;
      m_hitbox[type].type   = type;
      m_hitbox[type].x1     = btn_x1;
      m_hitbox[type].y1     = btn_y1;
      m_hitbox[type].x2     = btn_x2;
      m_hitbox[type].y2     = btn_y2;

      // Register drag zone
      m_dragbox[type].active = true;
      m_dragbox[type].type   = type;
      m_dragbox[type].x1     = 0;
      m_dragbox[type].y1     = body_y1;
      m_dragbox[type].x2     = btn_x1 - 4;
      m_dragbox[type].y2     = body_y2;
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
 //+------------------------------------------------------------------+
 bool CTradingLevelBubble::HasBuys(void)
  {
    if(m_market == NULL) return false;
    CArrayObj *list = m_market.GetList();
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, _Symbol, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)POSITION_TYPE_BUY, EQUAL);
    return (list != NULL && list.Total() > 0);
  }
 bool CTradingLevelBubble::HasSells(void)
  {
    if(m_market == NULL) return false;
    CArrayObj *list = m_market.GetList();
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, _Symbol, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)POSITION_TYPE_SELL, EQUAL);
    return (list != NULL && list.Total() > 0);
  }
 double CTradingLevelBubble::GetSL(ENUM_POSITION_TYPE dir)
  {
    if(m_market == NULL) return 0;
    CArrayObj *list = m_market.GetList();
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, _Symbol, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
    if(list == NULL) return 0;
    for(int i = 0; i < list.Total(); i++)
     {
        CMarketPosition *pos = (CMarketPosition*)list.At(i);
        if(pos == NULL) continue;
        double sl = pos.StopLoss();
        if(sl > 0) return sl;
     }
    return 0;
  }
 double CTradingLevelBubble::GetTP(ENUM_POSITION_TYPE dir)
  {
    if(m_market == NULL) return 0;
    CArrayObj *list = m_market.GetList();
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, _Symbol, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
    if(list == NULL) return 0;
    for(int i = 0; i < list.Total(); i++)
    {
        CMarketPosition *pos = (CMarketPosition*)list.At(i);
        if(pos == NULL) continue;
        double tp = pos.TakeProfit();
        if(tp > 0) return tp;
    }
    return 0;
  }
 void CTradingLevelBubble::CloseAll(ENUM_POSITION_TYPE dir)
  {
    if(m_market == NULL || m_trading_control == NULL) return;
    CArrayObj *list = m_market.GetList();
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, _Symbol, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
    if(list == NULL) return;
    for(int i = list.Total() - 1; i >= 0; i--)
     {
        CMarketPosition *pos = (CMarketPosition*)list.At(i);
        if(pos == NULL) continue;
        m_trading_control.ClosePosition((ulong)pos.Ticket());
     }
  }

 void CTradingLevelBubble::ModifyAll(ENUM_BUBBLE_TYPE type, double new_price)
  {
    if(m_market == NULL || m_trading_control == NULL) return;
    ENUM_POSITION_TYPE dir = (type <= BUBBLE_TP_BUY) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
    bool modify_sl = (type == BUBBLE_SL_BUY || type == BUBBLE_SL_SELL);
    CArrayObj *list = m_market.GetList();
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, _Symbol, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
    if(list == NULL) return;
    for(int i = list.Total() - 1; i >= 0; i--)
     {
        CMarketPosition *pos = (CMarketPosition*)list.At(i);
        if(pos == NULL) continue;
        double sl = modify_sl ? new_price : pos.StopLoss();
        double tp = modify_sl ? pos.TakeProfit() : new_price;
        m_trading_control.ModifyPosition((ulong)pos.Ticket(), sl, tp);
     }
  }
 double CTradingLevelBubble::CalcProfitAt(ENUM_BUBBLE_TYPE type, double target_price)
  {
    if(m_market == NULL || target_price <= 0) return 0;
    ENUM_POSITION_TYPE dir = (type <= BUBBLE_TP_BUY) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
    CArrayObj *list = m_market.GetList();
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, _Symbol, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
    if(list == NULL) return 0;
    double total = 0;
    for(int i = 0; i < list.Total(); i++)
     {
        CMarketPosition *pos = (CMarketPosition*)list.At(i);
        if(pos == NULL) continue;
        double p = 0;
        if(OrderCalcProfit((ENUM_ORDER_TYPE)dir, _Symbol, pos.Volume(), pos.PriceOpen(), target_price, p))
            total += p;
     }
    return total;
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
