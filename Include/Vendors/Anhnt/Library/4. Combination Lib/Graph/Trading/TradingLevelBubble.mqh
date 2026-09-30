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
    long                 m_panel_zorder;               // owner panel's Z-Order - canvas is forced one step below it, see SetPanelZOrder()
    bool                 m_created;                    // canvas exists - set by OnInitEvent()
    bool                 m_orig_chart_shift;           // CHART_SHIFT value before we forced it on, restored on deinit
    bool                 m_need_resize;                // set true bởi CHARTEVENT_CHART_CHANGE (zoom/scroll)
    bool                 m_need_redraw;                // set true bởi CHARTEVENT_CHART_CHANGE (zoom/scroll)
    double               m_last_sl_buy;                // last DISPLAYED level per slot - also the sticky pick when the group is mixed
    double               m_last_tp_buy;
    double               m_last_sl_sell;
    double               m_last_tp_sell;
    bool                 m_mixed[BUBBLE_TOTAL];        // positions of that direction don't all share this level (some differ / have none)
    int                  m_drag_offset_y;
    CMouseCombine        *m_mouse;
    // Drag state
     bool                 m_is_dragging;
     ENUM_BUBBLE_TYPE     m_drag_type;
     int                  m_drag_y;             // current drag Y in pixels
     int                  m_drag_bx;            // X frozen at drag-start - see DrawBubble() note
    //Add properties here
     int                  m_drag_anchor_y;      // Y anchor at drag-start (pixel) - fallback only, see DragPrice()
     double               m_drag_price_anchor;  // level price at drag-start - fallback only
     double               m_price_per_pixel;    // price per vertical pixel at drag-start - fallback only
    //Mouse State
     bool                 m_prev_left_btn;      // previous MOUSE_MOVE's button state - see OnChartEvent note
     bool                 m_prev_over;          // previous MOUSE_MOVE's dragbox-hover state
     bool                 m_scroll_locked_by_me;
     bool                 m_mouse_over_gui;     // set by the owner before each event - a GUI window covers the cursor, dragbox must not react
    // Interaction boxes (one slot per ENUM_BUBBLE_TYPE)
     SBubbleBox           m_hitbox[BUBBLE_TOTAL];     // X close button
     SBubbleBox           m_dragbox[BUBBLE_TOTAL];    // draggable body
     string               m_debug_path;               // owner-supplied file (Files\...) - empty = no debug log
    // Internal helpers
     void                 DrawBubble(ENUM_BUBBLE_TYPE type, int y_pixel, const bool pinned);
     string               BubbleLabel(ENUM_BUBBLE_TYPE type, double price);
     int                  PriceToY(double price);            // INT_MIN when the mapping fails
     int                  ClampY(const int y, bool &pinned); // edge-pin an off-screen level
     double               DragPrice(void);                   // level price under the dragged bubble, live chart mapping
     double               ResolveLevel(const ENUM_POSITION_TYPE dir, const bool is_sl, const double prev, bool &mixed); // one level for the whole direction
     int                  AnchorBX(void);
     void                 ResolveOverlap(int &ya, int &yb, bool a_dragged, bool b_dragged);
     void                 DebugLog(const string text);

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
     void SetPanelZOrder(const long zorder)                   { m_panel_zorder = zorder;                   }
     void SetMouseOverGUI(const bool over)                    { m_mouse_over_gui = over;                   }
     void SetDebugLogPath(const string path)                  { m_debug_path = path;                       }
    //--- The owner folds this into the GUI's chart-state (CWndEvents::SetExternalChartLock) -
    //--- this object only reports, it never writes CHART_MOUSE_SCROLL itself
     bool IsChartLockWanted(void) const                       { return m_is_dragging || m_scroll_locked_by_me; }
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
      m_prev_left_btn(false), m_prev_over(false), m_scroll_locked_by_me(false), m_mouse_over_gui(false), m_market_collection(NULL),
      m_trading_control(NULL),
      m_chart_obj_collection(NULL),
      m_panel_zorder(-999),
      m_debug_path(""),
      m_drag_offset_y(0),
      m_mouse(NULL),
      m_last_sl_buy(0), m_last_tp_buy(0),
      m_last_sl_sell(0), m_last_tp_sell(0)
  {
    for(int i = 0; i < BUBBLE_TOTAL; i++)
    {
        m_hitbox[i].active  = false;
        m_dragbox[i].active = false;
        m_mixed[i]          = false;
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
    static bool warned = false;   // OnPoll() retries every 16ms - log the failure once, not per poll
    if(w <= 0 || h <= 0)
     {
      // Terminal start-up with the EA in the profile: the chart is not sized yet - OnPoll() retries
      if(!warned) DebugLog("OnInitEvent: chart not sized yet w=" + (string)w + " h=" + (string)h + " - retry from OnPoll");
      warned = true;
      return false;
     }
    warned = false;
    m_canvas.Destroy();
    // Program-name prefix: CGraphElementsCollection only wraps objects that lack it, so the canvas
    // must carry it or it gets mirrored into a CGStdBitmapLabelObj on every collection refresh
    if(!m_canvas.CreateBitmapLabel(::MQLInfoString(MQL_PROGRAM_NAME) + "_TradingLevelBubbleCanvas", 0, 0, w, h,
                                   COLOR_FORMAT_ARGB_NORMALIZE))
     {
      DebugLog("OnInitEvent: CreateBitmapLabel FAILED err=" + (string)GetLastError());
      return false;
     }
    // Force this canvas BELOW the GUI Panel's own Z-Order (CElement::Init sets a Window's own
    // Z-Order to 0, and every nested control to main.Z_Order()+1
    ::ObjectSetInteger(0, m_canvas.ChartObjectName(), OBJPROP_ZORDER, m_panel_zorder - 1);
    m_canvas.FontSet("Calibri", 18, FW_BOLD);
    m_created = true;
    DebugLog("OnInitEvent: canvas created w=" + (string)w + " h=" + (string)h +
             " zorder=" + (string)(m_panel_zorder - 1) +
             " subwindows=" + (string)ChartGetInteger(0, CHART_WINDOWS_TOTAL) +
             " obj_y=" + (string)ObjectGetInteger(0, m_canvas.ChartObjectName(), OBJPROP_YDISTANCE) +
             " corner=" + (string)ObjectGetInteger(0, m_canvas.ChartObjectName(), OBJPROP_CORNER));
    Draw(); // catch positions/SL/TP that already existed before this class started listening
    return true;
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::OnDeinitEvent(void)
  {
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
   // Lazy-init retry: OnInitEvent() fails while the chart has no size yet (terminal start-up with
   // the EA in the profile) and nobody calls it again - keep trying from this 16ms poll.
   if(!m_created)
    {
     if(m_market_collection != NULL && m_trading_control != NULL) OnInitEvent();
     return;
    }
   if(m_mouse == NULL) return;
   bool left_btn = m_mouse.IsLeftBtn();
   // End drag: button released without a MOUSE_MOVE event to catch it
    if(m_is_dragging && !left_btn)
     {
       // Use the frozen drag X captured at drag-start so horizontal mouse movement
       // (diagonal/sideways) doesn't change the mapped time coordinate.
        ChartSetInteger(0, CHART_AUTOSCROLL, true);
        m_scroll_locked_by_me = false;
        double new_price = DragPrice();
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
      for(int i = 0; i < BUBBLE_TOTAL && !m_mouse_over_gui; i++)
       {
        if(!m_dragbox[i].active) continue;
        if(mx >= m_dragbox[i].x1 && mx <= m_dragbox[i].x2 &&
           my >= m_dragbox[i].y1 && my <= m_dragbox[i].y2)
           { over_now = true; break; }
       }       
      if(!over_now && m_scroll_locked_by_me)
       {
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
        if(trade_event == (ushort)TRADE_EVENT_MODIFY_POSITION_SL              ||
           trade_event == (ushort)TRADE_EVENT_MODIFY_POSITION_TP              ||
           trade_event == (ushort)TRADE_EVENT_MODIFY_POSITION_SL_TP           ||
           trade_event == (ushort)TRADE_EVENT_POSITION_OPENED                 ||
           //--- "Position closed" isn't one code - CTradeEvent classifies it by CAUSE
           //--- (TradeEvent.mqh) before firing, so every variant needs listing here,
           //--- not just the generic one (Anhnt/Claude, 2026-09-16 - a position closed
           //--- by StopLoss left a stale bubble on screen because TRADE_EVENT_POSITION_
           //--- CLOSED_BY_SL wasn't in this list, even though it was already firing).
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED                 ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL         ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_BY_SL           ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL   ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_BY_TP           ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP   ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_BY_POS          ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS)
         {
           if(m_debug_path != "")
            {
             CArrayObj *buys  = m_market_collection.GetPositionList(_Symbol, POSITION_TYPE_BUY);
             CArrayObj *sells = m_market_collection.GetPositionList(_Symbol, POSITION_TYPE_SELL);
             DebugLog("TradeEvent: id=" + (string)trade_event + " lparam=" + (string)lparam +
                      " buy_total=" + (string)(buys != NULL ? buys.Total() : -1) +
                      " sell_total=" + (string)(sells != NULL ? sells.Total() : -1));
            }
           Draw();
         }
        return;
     }
    if(id == CHARTEVENT_MOUSE_MOVE)
     {
        int mx = (int)lparam, my = (int)dparam;
        uint state    = (uint)StringToInteger(sparam);
        bool left_btn = ((state & 1) != 0);  // bit 0 = left mouse button

        bool over = false; int over_idx = -1;
        // The dragbox spans the whole chart width (it IS the level line), so a GUI window sitting
        // in the same y-band would otherwise count as "over" - e.g. holding a panel's scrollbar
        // dragged the bubble. The owner tells us when a window covers the cursor.
        if(!m_mouse_over_gui)
         for(int i = 0; i < BUBBLE_TOTAL; i++)
          {
            if(!m_dragbox[i].active) continue;
            if(mx >= m_dragbox[i].x1 && mx <= m_dragbox[i].x2 &&
              my >= m_dragbox[i].y1 && my <= m_dragbox[i].y2)
            { over = true; over_idx = i; break; }
          }
        bool wandered_in   = left_btn && m_prev_left_btn && !m_prev_over;
        bool safe_to_engage = !wandered_in;

        // Chart mouse-scroll itself is the GUI's property - the owner reads IsChartLockWanted()
        // after this call and folds it into CWndEvents::SetExternalChartLock; only AUTOSCROLL
        // (uncontested) is handled here.
        bool lock = m_is_dragging || (over && safe_to_engage);
        if(lock)
          {
           ChartSetInteger(0, CHART_AUTOSCROLL,   false);
           m_scroll_locked_by_me = true;
          }
        else if(m_scroll_locked_by_me)
          {
           ChartSetInteger(0, CHART_AUTOSCROLL,   true);
           m_scroll_locked_by_me = false;
          }
        if(!m_is_dragging && left_btn && over && over_idx >= 0 && safe_to_engage)
         {
            ENUM_BUBBLE_TYPE btype = m_dragbox[over_idx].type;
            // The level the bubble is DISPLAYING (group pick from ResolveLevel), not the first position's
            double price  = (btype == BUBBLE_SL_BUY)  ? m_last_sl_buy  :
                            (btype == BUBBLE_TP_BUY)  ? m_last_tp_buy  :
                            (btype == BUBBLE_SL_SELL) ? m_last_sl_sell : m_last_tp_sell;
            // Drag starts at the bubble's DRAWN (edge-clamped) Y. The live price comes from
            // DragPrice() each frame; the anchor/ppp captured here are only its fallback.
            bool   clamped;
            int    anchor = ClampY(PriceToY(price), clamped);
            m_is_dragging   = true;
            m_drag_type     = btype;
            m_drag_y        = anchor;
            m_drag_bx       = AnchorBX(); // frozen for the whole drag - see DrawBubble() note
            m_drag_anchor_y     = anchor;
            m_drag_price_anchor = price;
              {
                datetime ttmp; double p0 = 0.0, p1 = 0.0; int sub;
                if(ChartXYToTimePrice(0, m_drag_bx, m_drag_anchor_y, sub, ttmp, p0) &&
                  ChartXYToTimePrice(0, m_drag_bx, m_drag_anchor_y + 1, sub, ttmp, p1) &&
                  MathAbs(p1 - p0) >= 1e-12)
                    m_price_per_pixel = p1 - p0;
                else
                    m_price_per_pixel = -SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);   // y grows downward
              }
            m_drag_offset_y = my - anchor;
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
    if(id != CHARTEVENT_CLICK || m_mouse_over_gui) return;   // X button under a GUI window isn't clickable
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
    // One level per (direction, SL/TP) for the whole group - sticky to the last displayed one
    // when the positions disagree, and flagged 'mixed' so the label can say so ('*').
    bool mixed[BUBBLE_TOTAL];
    double sl_buy  = ResolveLevel(POSITION_TYPE_BUY,  true,  m_last_sl_buy,  mixed[BUBBLE_SL_BUY]);
    double tp_buy  = ResolveLevel(POSITION_TYPE_BUY,  false, m_last_tp_buy,  mixed[BUBBLE_TP_BUY]);
    double sl_sell = ResolveLevel(POSITION_TYPE_SELL, true,  m_last_sl_sell, mixed[BUBBLE_SL_SELL]);
    double tp_sell = ResolveLevel(POSITION_TYPE_SELL, false, m_last_tp_sell, mixed[BUBBLE_TP_SELL]);

    bool mixed_changed = false;
    for(int i = 0; i < BUBBLE_TOTAL; i++) if(mixed[i] != m_mixed[i]) mixed_changed = true;
    bool unchanged = !m_need_resize && !m_need_redraw && !m_is_dragging && !mixed_changed &&
                 sl_buy == m_last_sl_buy && tp_buy == m_last_tp_buy &&
                 sl_sell == m_last_sl_sell && tp_sell == m_last_tp_sell;
    if(unchanged) return;
    m_last_sl_buy = sl_buy;  m_last_tp_buy = tp_buy;
    m_last_sl_sell = sl_sell; m_last_tp_sell = tp_sell;
    for(int i = 0; i < BUBBLE_TOTAL; i++) m_mixed[i] = mixed[i];
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
    // One line per real repaint: every input of the price->pixel mapping, to diagnose a bubble
    // landing off its level (canvas vs chart size, window 0 price range, computed Y per level).
    if(m_debug_path != "")
      DebugLog("Draw: chart=" + (string)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) + "x" + (string)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) +
               " canvas=" + (string)m_canvas.Width() + "x" + (string)m_canvas.Height() +
               " canvas_y=" + (string)ObjectGetInteger(0, m_canvas.ChartObjectName(), OBJPROP_YDISTANCE) +
               " win0_price=" + DoubleToString(ChartGetDouble(0, CHART_PRICE_MIN, 0), _Digits) + ".." + DoubleToString(ChartGetDouble(0, CHART_PRICE_MAX, 0), _Digits) +
               " sl_buy=" + DoubleToString(sl_buy, _Digits) + "->y" + (string)(sl_buy > 0 ? PriceToY(sl_buy) : -1) +
               " tp_buy=" + DoubleToString(tp_buy, _Digits) + "->y" + (string)(tp_buy > 0 ? PriceToY(tp_buy) : -1) +
               " sl_sell=" + DoubleToString(sl_sell, _Digits) + "->y" + (string)(sl_sell > 0 ? PriceToY(sl_sell) : -1) +
               " tp_sell=" + DoubleToString(tp_sell, _Digits) + "->y" + (string)(tp_sell > 0 ? PriceToY(tp_sell) : -1) +
               " bx=" + (string)AnchorBX() + " dragging=" + (string)m_is_dragging + " drag_y=" + (string)m_drag_y +
               (m_is_dragging ? " drag_price=" + DoubleToString(DragPrice(), _Digits) : ""));
    // A level outside the visible price range (PriceToY off-canvas, e.g. SL 800$ away on an M1
    // chart) is pinned to the canvas edge with an arrow instead of vanishing - ClampY().
    if(sl_buy > 0 || tp_buy > 0)
     {
      int y_sl = INT_MIN, y_tp = INT_MIN;
      bool sl_pinned = false, tp_pinned = false;
      if(sl_buy > 0) y_sl = (m_is_dragging && m_drag_type == BUBBLE_SL_BUY) ? m_drag_y : PriceToY(sl_buy);
      if(tp_buy > 0) y_tp = (m_is_dragging && m_drag_type == BUBBLE_TP_BUY) ? m_drag_y : PriceToY(tp_buy);
      if(y_sl != INT_MIN) y_sl = ClampY(y_sl, sl_pinned);
      if(y_tp != INT_MIN) y_tp = ClampY(y_tp, tp_pinned);
      ResolveOverlap(y_sl, y_tp,
                     m_is_dragging && m_drag_type == BUBBLE_SL_BUY,
                     m_is_dragging && m_drag_type == BUBBLE_TP_BUY);
      if(y_sl != INT_MIN) DrawBubble(BUBBLE_SL_BUY, y_sl, sl_pinned);
      if(y_tp != INT_MIN) DrawBubble(BUBBLE_TP_BUY, y_tp, tp_pinned);
     }
    if(sl_sell > 0 || tp_sell > 0)
     {
      int y_sl = INT_MIN, y_tp = INT_MIN;
      bool sl_pinned = false, tp_pinned = false;
      if(sl_sell > 0) y_sl = (m_is_dragging && m_drag_type == BUBBLE_SL_SELL) ? m_drag_y : PriceToY(sl_sell);
      if(tp_sell > 0) y_tp = (m_is_dragging && m_drag_type == BUBBLE_TP_SELL) ? m_drag_y : PriceToY(tp_sell);
      if(y_sl != INT_MIN) y_sl = ClampY(y_sl, sl_pinned);
      if(y_tp != INT_MIN) y_tp = ClampY(y_tp, tp_pinned);
      ResolveOverlap(y_sl, y_tp,
                     m_is_dragging && m_drag_type == BUBBLE_SL_SELL,
                     m_is_dragging && m_drag_type == BUBBLE_TP_SELL);
      if(y_sl != INT_MIN) DrawBubble(BUBBLE_SL_SELL, y_sl, sl_pinned);
      if(y_tp != INT_MIN) DrawBubble(BUBBLE_TP_SELL, y_tp, tp_pinned);
     }
    m_canvas.Update();
  }
 //+------------------------------------------------------------------+
 //| The ONE level this direction's bubble stands for. 0 = no position |
 //| of that direction has this level (no bubble). 'mixed' = not every |
 //| position shares it (some differ or have none). When mixed, the    |
 //| pick is sticky: keep 'prev' (last displayed) if a position still   |
 //| holds it, so the bubble doesn't hop between levels - otherwise the |
 //| most common level, ties to the first seen.                         |
 //+------------------------------------------------------------------+
 double CTradingLevelBubble::ResolveLevel(const ENUM_POSITION_TYPE dir, const bool is_sl, const double prev, bool &mixed)
  {
    mixed = false;
    CArrayObj *list = m_market_collection.GetPositionList(_Symbol, dir);
    int total = (list != NULL) ? list.Total() : 0;
    if(total == 0) return 0;
    double levels[]; int counts[];
    int distinct = 0, without = 0;
    for(int i = 0; i < total; i++)
     {
      CMarketPosition *pos = (CMarketPosition*)list.At(i);
      if(pos == NULL) continue;
      double lv = is_sl ? pos.StopLoss() : pos.TakeProfit();
      if(lv <= 0) { without++; continue; }
      int k = 0;
      for(; k < distinct; k++) if(MathAbs(levels[k] - lv) < _Point / 2) break;
      if(k == distinct)
       {
        ArrayResize(levels, distinct + 1); ArrayResize(counts, distinct + 1);
        levels[distinct] = lv; counts[distinct] = 0; distinct++;
       }
      counts[k]++;
     }
    if(distinct == 0) return 0;
    mixed = (distinct > 1 || without > 0);
    if(distinct == 1) return levels[0];
    for(int k = 0; k < distinct; k++)
       if(MathAbs(levels[k] - prev) < _Point / 2) return levels[k];   // sticky
    int best = 0;
    for(int k = 1; k < distinct; k++) if(counts[k] > counts[best]) best = k;
    return levels[best];
  }
 //+------------------------------------------------------------------+
 //| Price of the level while dragging = the price under the bubble's  |
 //| current pixel, read from the chart NOW - so a scale change mid-   |
 //| drag (new high/low autoscales the chart) can't make the released  |
 //| price land away from where the bubble was dropped. Fallback to    |
 //| the drag-start anchor only if the chart mapping fails.            |
 //+------------------------------------------------------------------+
 double CTradingLevelBubble::DragPrice(void)
  {
    datetime t; double price; int sub;
    if(ChartXYToTimePrice(0, m_drag_bx, m_drag_y, sub, t, price) && sub == 0 && price > 0)
       return price;
    return m_drag_price_anchor + (m_drag_y - m_drag_anchor_y) * m_price_per_pixel;
  }
 //+------------------------------------------------------------------+
 //| Keep a bubble fully inside the canvas: off-screen levels are      |
 //| pinned to the top/bottom edge, 'pinned' tells the caller so       |
 //+------------------------------------------------------------------+
 int CTradingLevelBubble::ClampY(const int y, bool &pinned)
  {
    int half = BUBBLE_BDY_H / 2 + 2;
    int lo   = half;
    int hi   = m_canvas.Height() - half;
    pinned = (y < lo || y > hi);
    return (y < lo) ? lo : (y > hi) ? hi : y;
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
 void CTradingLevelBubble::DrawBubble(ENUM_BUBBLE_TYPE type, int by, const bool pinned)
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
    // Dashed horizontal level line - none when pinned (the real level is off-screen)
     uint line_clr = ColorToARGB(is_sl ? BUBBLE_CLR_SELL : BUBBLE_CLR_BUY, 180);
     int  dash_w = 10, gap_w = 5;
     for(int x = 0; !pinned && x < bx; x += dash_w + gap_w)
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

      // Price label (top): drag price during drag, else the group level Draw() resolved for this slot
      double display_price = 0;
      if(m_is_dragging && m_drag_type == type)
          display_price = DragPrice();
      else
          display_price = (type == BUBBLE_SL_BUY)  ? m_last_sl_buy  :
                          (type == BUBBLE_TP_BUY)  ? m_last_tp_buy  :
                          (type == BUBBLE_SL_SELL) ? m_last_sl_sell : m_last_tp_sell;
      // Pinned to the top edge => real level is above (arrow up), bottom edge => below.
      // '*' = not every position of this direction sits on this level (see ResolveLevel).
      string lbl = (pinned ? (by <= m_canvas.Height() / 2 ? "▲ " : "▼ ") : "") +
                   (m_mixed[type] && !(m_is_dragging && m_drag_type == type) ? "* " : "") +
                   BubbleLabel(type, display_price);
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
    // INT_MIN = mapping failed; a negative y is a VALID off-screen level (see ClampY)
    if(!ChartTimePriceToXY(0, 0, t, price, x, y)) return INT_MIN;
    return y;
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::ResolveOverlap(int &ya, int &yb, bool a_dragged, bool b_dragged)
  {
    if(ya == INT_MIN || yb == INT_MIN) return;
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
 //+------------------------------------------------------------------+
 //| Append one timestamped line to the owner-supplied debug file      |
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::DebugLog(const string text)
  {
    if(m_debug_path == "") return;
    int h = FileOpen(m_debug_path, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_SHARE_READ);
    if(h == INVALID_HANDLE) return;
    FileSeek(h, 0, SEEK_END);
    FileWriteString(h, TimeToString(TimeLocal(), TIME_DATE | TIME_SECONDS) + " " + text + "\r\n");
    FileClose(h);
  }

#endif // CTRADING_LEVEL_BUBBLE_IMPLEMENTATION
#endif // __TRADING_LEVEL_BUBBLE_MQH__
