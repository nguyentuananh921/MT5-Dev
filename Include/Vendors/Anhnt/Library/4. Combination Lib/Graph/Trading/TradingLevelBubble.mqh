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
    int                m_drag_offset_y;
    bool               m_chart_changed;  // init = false trong constructor
    CMouseCombine     *m_mouse;
    // Drag state
     bool              m_is_dragging;
     ENUM_BUBBLE_TYPE  m_drag_type;
     int               m_drag_y;        // current drag Y in pixels
    // Interaction boxes (one slot per ENUM_BUBBLE_TYPE)
     SBubbleBox        m_hitbox[BUBBLE_TOTAL];   // X close button
     SBubbleBox        m_dragbox[BUBBLE_TOTAL];  // draggable body
    // Bubble geometry constants
     static const int  TIP_W;    // triangle tip width (horizontal)
     static const int  BDY_W;    // rectangle body width
     static const int  BDY_H;    // bubble height (half = 17 each side)
     static const int  XSZ;      // X button square size
     static const int  RPAD;     // right padding from chart edge
    // Internal helpers
     bool              HasBuys(void);
     bool              HasSells(void);
     double            GetSL(ENUM_POSITION_TYPE dir);
     double            GetTP(ENUM_POSITION_TYPE dir);
     void              DrawBubble(ENUM_BUBBLE_TYPE type, int y_pixel);
     void              CloseAll(ENUM_POSITION_TYPE dir);
     void              ModifyAll(ENUM_BUBBLE_TYPE type, double new_price);
     color             BubbleColor(ENUM_BUBBLE_TYPE type);
     string            BubbleLabel(ENUM_BUBBLE_TYPE type, double price);
     int               PriceToY(double price);
    void              ResolveOverlap(int &ya, int &yb, bool a_dragged, bool b_dragged);

public:
    CTradingLevelBubble(void);
   ~CTradingLevelBubble(void);

    bool OnInitEvent(void);
    void OnDeinitEvent(void);
    void OnTickEvent(void);
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
 // Static const definitions
  const int CTradingLevelBubble::TIP_W = 18;
  const int CTradingLevelBubble::BDY_W = 155;
  const int CTradingLevelBubble::BDY_H = 34;
  const int CTradingLevelBubble::XSZ   = 18;
  const int CTradingLevelBubble::RPAD  = 52;
 CTradingLevelBubble::CTradingLevelBubble(void)
    : m_need_resize(true),
      m_is_dragging(false),
      m_drag_type(BUBBLE_SL_BUY),
      m_drag_y(0), m_market(NULL),
      m_trading_control(NULL), m_drag_offset_y(0), m_chart_changed(false),
      m_mouse(NULL)
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
    return true;
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::OnDeinitEvent(void)
  {
    ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, true); // restore
    m_canvas.Destroy();
    ChartRedraw();
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::OnTickEvent(void)
  { 
    // Catch mouse button release when mouse is stationary (no MOUSE_MOVE fires)
    //if(m_is_dragging && !m_left_btn)
    if(m_is_dragging && !m_mouse.IsLeftBtn() && m_mouse.GapBetweenCalls() > 16)
     {
        ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
        datetime t; double new_price; int sub;
        int any_x = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) / 2;
        ChartXYToTimePrice(0, any_x, m_drag_y, sub, t, new_price);
        ModifyAll(m_drag_type, new_price);
        m_is_dragging = false;
        Draw();
        return;
     }   
    if(m_is_dragging) return;
    if(m_chart_changed)
     {
          m_chart_changed = false;
          Draw();
          return;
     }
    static uint last_ms = 0;
    uint now = GetTickCount();
    if(now - last_ms < 100) return;
    last_ms = now;
    Draw();
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::OnChartEvent(const int id, const long &lparam,
                                      const double &dparam, const string &sparam)
  {
    if(id == CHARTEVENT_CHART_CHANGE)
     {
        m_need_resize = true;
        m_chart_changed = true;
        Draw();
        return;
     }
    if(id == CHARTEVENT_MOUSE_MOVE)
     {
      int  mx       = (int)lparam;
      int  my       = (int)dparam;
      //bool left_btn = ((int)StringToInteger(sparam) & 1) != 0;
      //m_left_btn    = left_btn;
      bool left_btn = m_mouse.IsLeftBtn();
      // Hover detection — disable scroll when over drag zone
        bool over_drag = false;
      for(int i = 0; i < BUBBLE_TOTAL; i++)
      {
        if(!m_dragbox[i].active) continue;
        if(mx >= m_dragbox[i].x1 && mx <= m_dragbox[i].x2 &&
          my >= m_dragbox[i].y1 && my <= m_dragbox[i].y2)
        { over_drag = true; break; }
      }
      ChartSetInteger(0, CHART_MOUSE_SCROLL, !(over_drag || m_is_dragging));
      // Begin drag
      if(left_btn && !m_is_dragging)
       {
        for(int i = 0; i < BUBBLE_TOTAL; i++)
         {
          if(!m_dragbox[i].active) continue;
          if(mx >= m_dragbox[i].x1 && mx <= m_dragbox[i].x2 &&
              my >= m_dragbox[i].y1 && my <= m_dragbox[i].y2)
           {
            // Compute actual bubble Y to avoid snap-on-click jump
             ENUM_POSITION_TYPE d = (m_dragbox[i].type <= BUBBLE_TP_BUY)
                                   ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
             bool is_sl = (m_dragbox[i].type == BUBBLE_SL_BUY ||
                          m_dragbox[i].type == BUBBLE_SL_SELL);
             double price = is_sl ? GetSL(d) : GetTP(d);
             int anchor = PriceToY(price);
             m_is_dragging    = true;
             m_drag_type      = m_dragbox[i].type;
             m_drag_y         = anchor;
             m_drag_offset_y  = my - anchor;   // mouse offset from bubble center
             ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
             break;
           }
         }
       }
      // Continue drag
      if(m_is_dragging && left_btn)
      {
        m_drag_y = my-m_drag_offset_y;
        Draw();
        return;
      }
      // End drag
      if(m_is_dragging && !left_btn)
      {
        ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
        datetime t; double new_price; int sub;
        //ChartXYToTimePrice(0, mx, my, sub, t, new_price);
        ChartXYToTimePrice(0, mx, m_drag_y, sub, t, new_price);
        ModifyAll(m_drag_type, new_price);
        m_is_dragging = false;
        Draw();
        return;
      }
      return;
     }
    // X button click
    if(id == CHARTEVENT_CLICK)
     {
      int mx = (int)lparam;
      int my = (int)dparam;
      for(int i = 0; i < BUBBLE_TOTAL; i++)
       {
        if(!m_hitbox[i].active) continue;
        if(mx >= m_hitbox[i].x1 && mx <= m_hitbox[i].x2 &&
        my >= m_hitbox[i].y1 && my <= m_hitbox[i].y2)
        {
            ENUM_POSITION_TYPE dir = (i <= BUBBLE_TP_BUY)
                                    ? POSITION_TYPE_BUY
                                    : POSITION_TYPE_SELL;
            CloseAll(dir);
            Draw();
            return;
        }
       }
     }
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::Draw(void)
  {
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
    if(HasBuys())
     {
      double sl = GetSL(POSITION_TYPE_BUY);
      double tp = GetTP(POSITION_TYPE_BUY);
      int y_sl = -1, y_tp = -1;
      if(sl > 0) y_sl = (m_is_dragging && m_drag_type == BUBBLE_SL_BUY) ? m_drag_y : PriceToY(sl);
      if(tp > 0) y_tp = (m_is_dragging && m_drag_type == BUBBLE_TP_BUY) ? m_drag_y : PriceToY(tp);
      ResolveOverlap(y_sl, y_tp,
                     m_is_dragging && m_drag_type == BUBBLE_SL_BUY,
                     m_is_dragging && m_drag_type == BUBBLE_TP_BUY);
      if(sl > 0 && y_sl >= 0) DrawBubble(BUBBLE_SL_BUY, y_sl);
      if(tp > 0 && y_tp >= 0) DrawBubble(BUBBLE_TP_BUY, y_tp);
     }
    if(HasSells())
     {
      double sl = GetSL(POSITION_TYPE_SELL);
      double tp = GetTP(POSITION_TYPE_SELL);
      int y_sl = -1, y_tp = -1;
      if(sl > 0) y_sl = (m_is_dragging && m_drag_type == BUBBLE_SL_SELL) ? m_drag_y : PriceToY(sl);
      if(tp > 0) y_tp = (m_is_dragging && m_drag_type == BUBBLE_TP_SELL) ? m_drag_y : PriceToY(tp);
      ResolveOverlap(y_sl, y_tp,
                     m_is_dragging && m_drag_type == BUBBLE_SL_SELL,
                     m_is_dragging && m_drag_type == BUBBLE_TP_SELL);
      if(sl > 0 && y_sl >= 0) DrawBubble(BUBBLE_SL_SELL, y_sl);
      if(tp > 0 && y_tp >= 0) DrawBubble(BUBBLE_TP_SELL, y_tp);
     }
    m_canvas.Update();
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::DrawBubble(ENUM_BUBBLE_TYPE type, int by)
  {
    int chart_w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);

    // Right-aligned: tip starts at bx, body extends right toward price axis
    int bx    = chart_w - RPAD - TIP_W - BDY_W;
    int half  = BDY_H / 2;

    uint bg       = ColorToARGB(BubbleColor(type), 210);
    uint text_clr = ColorToARGB(clrWhite);

    // Triangle tip (points left toward price)
     m_canvas.FillTriangle(bx,        by,
                          bx + TIP_W, by - half,
                          bx + TIP_W, by + half,
                          bg);
    // Horizontal dashed level line from chart left edge to bubble tip
      //uint line_clr = ColorToARGB(BubbleColor(type), 110); // semi-transparent
      uint line_clr = ColorToARGB(BubbleColor(type), 180); // semi-transparent
      int dash_w = 10, gap_w = 5;
      for(int x = 0; x < bx; x += dash_w + gap_w)
       {
          int x2 = MathMin(x + dash_w - 1, bx - 1);
          m_canvas.LineHorizontal(x, x2, by - 1, line_clr);
          m_canvas.LineHorizontal(x, x2, by,     line_clr);
          m_canvas.LineHorizontal(x, x2, by + 1, line_clr);
       }

    // Rectangle body
     int body_x1 = bx + TIP_W;
     int body_x2 = bx + TIP_W + BDY_W;
     int body_y1 = by - half;
     int body_y2 = by + half;
     m_canvas.FillRectangle(body_x1, body_y1, body_x2, body_y2, bg);
    // X button (right end of body)
     int btn_x1 = body_x2 - XSZ - 4;
     int btn_y1 = by - XSZ / 2;
     int btn_x2 = btn_x1 + XSZ;
     int btn_y2 = btn_y1 + XSZ;
     m_canvas.FillRectangle(btn_x1, btn_y1, btn_x2, btn_y2, ColorToARGB(clrFireBrick));
     m_canvas.TextOut(btn_x1 + XSZ / 2, by, "X", text_clr, TA_CENTER | TA_VCENTER);

    // Label text
    // Price for label: during drag we show current drag price; otherwise use the stored SL/TP
    double display_price = 0;
    if(m_is_dragging && m_drag_type == type)
     {
        datetime t; int sub;
        ChartXYToTimePrice(0, bx, by, sub, t, display_price);
     }
    else
     {
        ENUM_POSITION_TYPE dir = (type <= BUBBLE_TP_BUY) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
        bool is_sl = (type == BUBBLE_SL_BUY || type == BUBBLE_SL_SELL);
        display_price = is_sl ? GetSL(dir) : GetTP(dir);
     }
    string lbl = BubbleLabel(type, display_price);
    m_canvas.TextOut(body_x1 + 8, by, lbl, text_clr, TA_LEFT | TA_VCENTER);

    // Register hitbox (X button)
     m_hitbox[type].active = true;
     m_hitbox[type].type   = type;
     m_hitbox[type].x1     = btn_x1;
     m_hitbox[type].y1     = btn_y1;
     m_hitbox[type].x2     = btn_x2;
     m_hitbox[type].y2     = btn_y2;
    // Register drag zone (body minus X button) line + body đều kéo được
     m_dragbox[type].active = true;
     m_dragbox[type].type   = type;
     m_dragbox[type].x1     = 0;          // ← đổi từ bx → 0
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
    if(MathAbs(ya - yb) >= BDY_H + 2) return;
    int gap = BDY_H + 2;
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

 //+------------------------------------------------------------------+
 color CTradingLevelBubble::BubbleColor(ENUM_BUBBLE_TYPE type)
  {
    return (type == BUBBLE_SL_BUY || type == BUBBLE_SL_SELL)
           ? clrCrimson
           : clrMediumSeaGreen;
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
