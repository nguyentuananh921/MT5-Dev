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
 //| Clickable region on canvas (X button) / hover zone (SL-TP line)  |
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
 //| - Dragging the level itself is done by MT5's OWN native SL/TP   |
 //|   line (Anhnt, 2026-08-14 - "Hybrid Native Line" redesign):     |
 //|   CHART_SHOW_TRADE_LEVELS is left ON, this class briefly hides  |
 //|   its own bubble whenever the mouse is holding the left button  |
 //|   near a line (so the user only ever sees the native line move,|
 //|   not our own stale bubble sitting on top of it), then reacts   |
 //|   to the resulting TRADE_EVENT_MODIFY_POSITION_SL/TP/SL_TP once |
 //|   MT5 commits it, syncing the SAME new SL/TP to every other     |
 //|   position on that side (SyncFromModifiedPosition) - the one    |
 //|   thing native dragging can't do on its own (it only ever       |
 //|   touches the ONE position whose line was grabbed).             |
 //| - Click X btn  → close all positions on that side (unchanged).  |
 //+------------------------------------------------------------------+
#ifndef CTRADING_LEVEL_BUBBLE_DECLARATION
#define CTRADING_LEVEL_BUBBLE_DECLARATION
 // --- Inherits CGBaseObj purely for Layer-3 graphic-object identity (name/chart_id/
 // --- Belong/Species/Type) - same base CGStdGraphObj/CGStdBitmapLabelObj use. Drawing
 // --- itself stays on CCanvas (own hitbox state) - no existing base in either
 // --- Trishkin's or Kazharski's hierarchy offers free-form pixel drawing, so that part
 // --- remains this class's own responsibility (see README/BugNote discussion 2026-07-13).
 class CTradingLevelBubble : public CGBaseObj
  {
   private:
    CCanvas            m_canvas;
    CMarketCollection *m_market;           // Collection of market orders and deals Trading Engine Own
    CTradingControl   *m_trading_control;  // Trading management object CTradingEngine own it
    CChartObjCollection *m_chart_obj_collection; // BORROWED - CGUIPannel owns it
    bool               m_created;         // canvas exists - self-managed, see EnsureCreated()
    bool               m_orig_chart_shift; // CHART_SHIFT value before we forced it on, restored on deinit
    bool               m_need_resize;
    bool               m_need_redraw;     // set true bởi CHARTEVENT_CHART_CHANGE (zoom/scroll)
    double             m_last_sl_buy;
    double             m_last_tp_buy;
    double             m_last_sl_sell;
    double             m_last_tp_sell;

    CMouseCombine     *m_mouse;
    // --- Hide-for-native-drag state (Anhnt, 2026-08-14 - "Hybrid Native Line"): while the
    // --- left button is held down with the mouse near a level's line, we assume the user is
    // --- dragging MT5's own native SL/TP line underneath our bubble and hide THAT one bubble
    // --- (others stay visible) so it doesn't visually fight the native line moving with the
    // --- mouse. Purely a heuristic - worst case it hides/shows a beat early/late, never wrong
    // --- in a way that blocks the native drag itself (we don't touch chart scroll/mouse
    // --- capture at all anymore - MT5 owns 100% of the actual drag).
     bool              m_hide_active;
     ENUM_BUBBLE_TYPE  m_hide_type;
    // Interaction boxes (one slot per ENUM_BUBBLE_TYPE)
     SBubbleBox        m_hitbox[BUBBLE_TOTAL];    // X close button
     SBubbleBox        m_linezone[BUBBLE_TOTAL];  // hover zone around this level's line - hide-heuristic only, no dragging
    //Calculation profit
     double CalcProfitAt(ENUM_BUBBLE_TYPE type, double target_price);
    // Internal helpers
     bool              HasBuys(void);
     bool              HasSells(void);
     double            GetSL(ENUM_POSITION_TYPE dir);
     double            GetTP(ENUM_POSITION_TYPE dir);
     void              DrawBubble(ENUM_BUBBLE_TYPE type, int y_pixel, bool visible);
     void              CloseAll(ENUM_POSITION_TYPE dir);
     // --- Reacts to a native SL/TP modify on ONE position (Anhnt, 2026-08-14): reads that
     // --- position's OWN just-committed SL/TP straight from m_market (already refreshed by the
     // --- time this event fires - CTradingEngine::TradeEventsControl() runs
     // --- m_market_collection.Refresh() BEFORE broadcasting), then applies the SAME SL/TP to
     // --- every OTHER position on the same side. Excludes modified_ticket itself so it never
     // --- re-modifies the position that just triggered the event (would be a harmless no-op
     // --- price-wise, but pointless extra broker round-trip / event noise).
     void              SyncFromModifiedPosition(const ulong modified_ticket);
     string            BubbleLabel(ENUM_BUBBLE_TYPE type, double price);
     int               PriceToY(double price);
     int               AnchorBX(void);
    void               ResolveOverlap(int &ya, int &yb, bool a_dragged, bool b_dragged);
    // --- Self-managed lazy-init (2026-07-14): a Position/SL/TP can appear from ANY
    // --- source (mobile app, manual, another EA), not just this EA's own trade events -
    // --- HasAnyLevel() queries the live m_market snapshot directly, so this check is
    // --- source-agnostic by construction. Called on every OnPoll()/OnChartEvent() entry
    // --- so the owner (CGUIPannel) never needs to track "is the bubble created yet" itself.
    void               EnsureCreated(void);

   public:
     CTradingLevelBubble(void);
     ~CTradingLevelBubble(void);
    bool      OnInitEvent(void);
    void      OnDeinitEvent(void);
    //void OnTickEvent(void);
    void      OnPoll(void);
    void      OnChartEvent(const int id, const long &lparam,
                      const double &dparam, const string &sparam);
    void      Draw(void);
    // --- Used internally by EnsureCreated() to decide whether it's time to lazily call
    // --- OnInitEvent() (canvas creation) - true as soon as any position on the current
    // --- chart's symbol has an SL or TP set, i.e. exactly the condition under which
    // --- Draw() would first paint something real. Queries m_market directly, so it's
    // --- source-agnostic (mobile app / manual / another EA all show up here the same way).
     bool     HasAnyLevel(void)
     {
      return GetSL(POSITION_TYPE_BUY) > 0 || GetTP(POSITION_TYPE_BUY) > 0 ||
             GetSL(POSITION_TYPE_SELL) > 0 || GetTP(POSITION_TYPE_SELL) > 0;
     }
    //For pointer
     void MousePointer(CMouseCombine &object)                 { m_mouse = GetPointer(object);        }
     void SetMarketCollection(CMarketCollection *market)      { m_market = market;                   }
     void SetTradingControl(CTradingControl *trading_control) { m_trading_control = trading_control; }
     void SetChartObjCollection(CChartObjCollection *coll)    { m_chart_obj_collection = coll;        }

    //void SetMagic(const ulong magic) { m_trade.SetExpertMagicNumber(magic); }
};
#endif // CTRADING_LEVEL_BUBBLE_DECLARATION

#ifndef CTRADING_LEVEL_BUBBLE_IMPLEMENTATION
#define CTRADING_LEVEL_BUBBLE_IMPLEMENTATION
 CTradingLevelBubble::CTradingLevelBubble(void)
    : m_created(false),
      m_orig_chart_shift(true),
      m_need_resize(true),
      m_need_redraw(true),
      m_hide_active(false), m_hide_type(BUBBLE_SL_BUY),
      m_market(NULL),
      m_trading_control(NULL),
      m_chart_obj_collection(NULL),
      m_mouse(NULL),
      m_last_sl_buy(0), m_last_tp_buy(0),
      m_last_sl_sell(0), m_last_tp_sell(0)
  {
   for(int i = 0; i < BUBBLE_TOTAL; i++)
    {
        m_hitbox[i].active   = false;
        m_linezone[i].active = false;
    }
    // --- CGBaseObj identity: not a native named object (no ObjectCreate behind it
    // --- beyond the CCanvas bitmap label), but still gets a name/chart_id/species so
    // --- it classifies as a proper Layer-3 graphic object like CGStdGraphObj does.
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
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   // --- Native SL/TP line stays ON (Anhnt, 2026-08-14 - "Hybrid Native Line"): dragging is
   // --- done by MT5 itself now, not by this class - see class header comment. Native dragging
   // --- proved buttery-smooth on its own; this class only adds the "sync to every same-side
   // --- position" behavior native dragging can't do, plus the nicer P&L-labeled bubble visual.
   ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, true);
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
   Draw(); // populate bubbles for positions already open when EA attaches
   return true;
 }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::EnsureCreated(void)
  {
   if(m_created) return;
   if(!HasAnyLevel()) return;
   OnInitEvent(); // sets m_created=true itself on success; a failed attempt (chart not
                   // laid out yet, w/h still 0) just leaves m_created false to retry later
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::OnDeinitEvent(void)
  {
   ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, true); // leave native lines visible
   ChartSetInteger(0, CHART_SHIFT, m_orig_chart_shift); // restore
   m_canvas.Destroy();
   m_created = false;
   ChartRedraw();
  }
 //+------------------------------------------------------------------+
 void CTradingLevelBubble::OnPoll(void)
  {
   EnsureCreated(); // periodic retry - covers positions/SL/TP that appeared from any source
   // Hide/un-hide for native drag, polled here NOT event-driven (Anhnt, 2026-08-14 v3 - "thấy
   // rõ ràng cái Bubble không ẩn đi"): both CHARTEVENT_MOUSE_MOVE and CHARTEVENT_CLICK turned
   // out unreliable for this - MT5 appears to take over mouse capture entirely for its own
   // native SL/TP line drag, so this EA stops receiving those events for the whole drag. This
   // timer (16ms, fires unconditionally regardless of MT5's event suppression) polls
   // m_mouse's LAST KNOWN state instead - CMouseCombine only updates on an actual MOUSE_MOVE,
   // so during a native drag its X/Y/button values sit frozen at whatever the last real event
   // reported (normally the click that started the drag, still correctly "held" since nothing
   // has told it otherwise) - false only once the drag truly ends and a real MOUSE_MOVE/CLICK
   // finally gets through again reporting the release.
    if(m_mouse != NULL)
     {
      int mx = m_mouse.X(), my = m_mouse.Y();
      bool left_btn = m_mouse.IsLeftBtn();
      bool over = false; int over_idx = -1;
      for(int i = 0; i < BUBBLE_TOTAL; i++)
       {
        if(!m_linezone[i].active) continue;
        if(mx >= m_linezone[i].x1 && mx <= m_linezone[i].x2 &&
           my >= m_linezone[i].y1 && my <= m_linezone[i].y2)
           { over = true; over_idx = i; break; }
       }
      bool want_hide = left_btn && over;
      bool hide_type_changed = want_hide && over_idx >= 0 && m_linezone[over_idx].type != m_hide_type;
      if(want_hide != m_hide_active || hide_type_changed)
       {
        m_hide_active = want_hide;
        if(want_hide && over_idx >= 0) m_hide_type = m_linezone[over_idx].type;
        m_need_redraw = true;
        Draw();
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
    EnsureCreated(); // react immediately instead of waiting for the next OnPoll() timer tick
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
    // Trade event broadcast by CTradingEngine (CTradeEventsCollection) — react instead of polling
    if(id >= CHARTEVENT_CUSTOM)
     {
       ushort trade_event = (ushort)(id - CHARTEVENT_CUSTOM);
       bool is_position_closed_event =
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED             ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_BY_POS      ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_BY_SL       ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_BY_TP       ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL     ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL  ||
           trade_event == (ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP;
       bool is_modify_event =
           trade_event == (ushort)TRADE_EVENT_MODIFY_POSITION_SL    ||
           trade_event == (ushort)TRADE_EVENT_MODIFY_POSITION_TP    ||
           trade_event == (ushort)TRADE_EVENT_MODIFY_POSITION_SL_TP;
       if(is_modify_event)
        {
         // lparam = ticket of the position MT5 (native line) just modified - sync its new
         // SL/TP to every other same-side position (see SyncFromModifiedPosition comment).
          SyncFromModifiedPosition((ulong)lparam);
         // Un-hide now - the drag that triggered the CHARTEVENT_CLICK hide is done, this is
         // the normal (not safety-net) path back to showing the bubble again.
          m_hide_active = false;
          m_need_redraw = true;
         Draw();
         return;
        }
       if(trade_event == (ushort)TRADE_EVENT_POSITION_OPENED || is_position_closed_event)
         {
          Draw();
         }
       return;
     }
    if(id != CHARTEVENT_CLICK) return;
    int mx = (int)lparam;
    int my = (int)dparam;
    // X close button. Hide-for-native-drag is handled by OnPoll()'s polling now, not here -
    // see its comment (Anhnt, 2026-08-14 v3): neither MOUSE_MOVE nor CLICK reliably fires
    // during an actual native-line drag once MT5 takes over mouse capture.
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
   if(!m_created) return; // canvas not created yet - EnsureCreated() owns that decision
   ulong t0 = ::GetMicrosecondCount();

   double sl_buy  = GetSL(POSITION_TYPE_BUY);
   double tp_buy  = GetTP(POSITION_TYPE_BUY);
   double sl_sell = GetSL(POSITION_TYPE_SELL);
   double tp_sell = GetTP(POSITION_TYPE_SELL);
   ulong fetch_us = ::GetMicrosecondCount() - t0;

   bool unchanged = !m_need_resize && !m_need_redraw &&
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
     m_hitbox[i].active   = false;
     m_linezone[i].active = false;
    }
   if(sl_buy > 0 || tp_buy > 0)
    {
     int y_sl = -1, y_tp = -1;
     if(sl_buy > 0) y_sl = PriceToY(sl_buy);
     if(tp_buy > 0) y_tp = PriceToY(tp_buy);
     ResolveOverlap(y_sl, y_tp, false, false); // neither side is ever "being dragged" anymore
     if(sl_buy > 0 && y_sl >= 0) DrawBubble(BUBBLE_SL_BUY, y_sl, !(m_hide_active && m_hide_type == BUBBLE_SL_BUY));
     if(tp_buy > 0 && y_tp >= 0) DrawBubble(BUBBLE_TP_BUY, y_tp, !(m_hide_active && m_hide_type == BUBBLE_TP_BUY));
    }
   if(sl_sell > 0 || tp_sell > 0)
    {
     int y_sl = -1, y_tp = -1;
     if(sl_sell > 0) y_sl = PriceToY(sl_sell);
     if(tp_sell > 0) y_tp = PriceToY(tp_sell);
     ResolveOverlap(y_sl, y_tp, false, false);
     if(sl_sell > 0 && y_sl >= 0) DrawBubble(BUBBLE_SL_SELL, y_sl, !(m_hide_active && m_hide_type == BUBBLE_SL_SELL));
     if(tp_sell > 0 && y_tp >= 0) DrawBubble(BUBBLE_TP_SELL, y_tp, !(m_hide_active && m_hide_type == BUBBLE_TP_SELL));
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
 void CTradingLevelBubble::DrawBubble(ENUM_BUBBLE_TYPE type, int by, bool visible)
  {
   int bx = AnchorBX();
   int half = BUBBLE_BDY_H / 2;
   // Flags
    bool is_sl  = (type == BUBBLE_SL_BUY  || type == BUBBLE_SL_SELL);
    bool is_buy = (type == BUBBLE_SL_BUY  || type == BUBBLE_TP_BUY);

    int body_x1 = bx + BUBBLE_TIP_W;
    int body_x2 = bx + BUBBLE_TIP_W + BUBBLE_BDY_W;
    int body_y1 = by - half;
    int body_y2 = by + half;
    int btn_x1 = body_x2 - BUBBLE_XSZ - 4;

    // Register line hover-zone UNCONDITIONALLY, even while hidden (Anhnt, 2026-08-14 v4 -
    // "nháy loạn xạ"/flicker fix): OnPoll() polls this every 16ms to decide hide/un-hide - if a
    // HIDDEN bubble stopped re-registering its own zone (used to bail out early before this
    // point when !visible), OnPoll() would see "not over anything" on the very next poll, un-
    // hide, which re-registers the zone, which gets hidden again next poll - a rapid hide/show
    // loop. Geometry must still track the CURRENT by/bx so the zone follows the live price.
    int zone_pad_y = 4;
    m_linezone[type].active = true;
    m_linezone[type].type   = type;
    m_linezone[type].x1     = 0;
    m_linezone[type].y1     = body_y1 - zone_pad_y;
    m_linezone[type].x2     = MathMin(body_x2, btn_x1 - 4);
    m_linezone[type].y2     = body_y2 + zone_pad_y;

    if(!visible) return; // hidden for native drag - zone above stays live, pixels don't

   // Colors
    uint border_clr = ColorToARGB(is_sl  ? BUBBLE_CLR_SELL : BUBBLE_CLR_BUY);  // SL=red, TP=green
    uint label_clr  = ColorToARGB(is_buy ? BUBBLE_CLR_BUY  : BUBBLE_CLR_SELL); // Buy=green, Sell=red
    uint bg         = ColorToARGB(BUBBLE_CLR_BG);

   // Dashed horizontal level line (purely visual now - the REAL draggable line is MT5's own
   // native one, drawn separately by the terminal since CHART_SHOW_TRADE_LEVELS is on)
    uint line_clr = ColorToARGB(is_sl ? BUBBLE_CLR_SELL : BUBBLE_CLR_BUY, 180);
    int  dash_w = 10, gap_w = 5;
    for(int x = 0; x < bx; x += dash_w + gap_w)
     {
      int x2 = MathMin(x + dash_w - 1, bx - 1);
      m_canvas.LineHorizontal(x, x2, by - 1, line_clr);
      m_canvas.LineHorizontal(x, x2, by,     line_clr);
      m_canvas.LineHorizontal(x, x2, by + 1, line_clr);
     }

    // Outer fill: border color (full size)
      m_canvas.FillTriangle(bx, by, bx + BUBBLE_TIP_W, by - half, bx + BUBBLE_TIP_W, by + half, border_clr);
      m_canvas.FillRectangle(body_x1, body_y1, body_x2, body_y2, border_clr);

      // Inner fill: background (inset BUBBLE_BDR_W — no left inset on rect = no left border)
      m_canvas.FillTriangle(bx + BUBBLE_BDR_W, by,
                            bx + BUBBLE_TIP_W,  by - half + BUBBLE_BDR_W,
                            bx + BUBBLE_TIP_W,  by + half - BUBBLE_BDR_W, bg);
      m_canvas.FillRectangle(body_x1, body_y1 + BUBBLE_BDR_W, body_x2 - BUBBLE_BDR_W, body_y2 - BUBBLE_BDR_W, bg);

      // X close button
      int btn_y1 = by - BUBBLE_XSZ / 2;
      int btn_x2 = btn_x1 + BUBBLE_XSZ;
      int btn_y2 = btn_y1 + BUBBLE_XSZ;
      m_canvas.FillRectangle(btn_x1, btn_y1, btn_x2, btn_y2, ColorToARGB(clrFireBrick));
      m_canvas.TextOut(btn_x1 + BUBBLE_XSZ / 2, by, "X", ColorToARGB(clrWhite), TA_CENTER | TA_VCENTER);

      // Price label (top)
      ENUM_POSITION_TYPE dir = is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
      double display_price = is_sl ? GetSL(dir) : GetTP(dir);
      string lbl = BubbleLabel(type, display_price);
      m_canvas.TextOut(body_x1 + 8, by - 12, lbl, label_clr, TA_LEFT | TA_VCENTER);

      // P&L label (bottom): color by sign
      double pnl     = CalcProfitAt(type, display_price);
      string pnl_str = (pnl >= 0 ? "+" : "") + DoubleToString(pnl, 2) + " $";
      uint   pnl_clr = ColorToARGB(pnl >= 0 ? BUBBLE_CLR_PROFIT_POS : BUBBLE_CLR_PROFIT_NEG);
      m_canvas.TextOut(body_x1 + 8, by + 12, pnl_str, pnl_clr, TA_LEFT | TA_VCENTER);

      // Register hitbox (X button) — expand slightly for easier clicking. Only while visible -
      // no equivalent flicker risk since CHARTEVENT_CLICK is discrete, not polled every 16ms.
      int hit_pad = 6;
      m_hitbox[type].active = true;
      m_hitbox[type].type   = type;
      m_hitbox[type].x1     = MathMax(0, btn_x1 - hit_pad);
      m_hitbox[type].y1     = MathMax(0, btn_y1 - hit_pad);
      m_hitbox[type].x2     = btn_x2 + hit_pad;
      m_hitbox[type].y2     = btn_y2 + hit_pad;
      // (line hover-zone already registered above, before the visibility check)
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

 //+------------------------------------------------------------------+
 void CTradingLevelBubble::SyncFromModifiedPosition(const ulong modified_ticket)
  {
   if(m_market == NULL || m_trading_control == NULL) return;
   ENUM_POSITION_TYPE dirs[2] = {POSITION_TYPE_BUY, POSITION_TYPE_SELL};
   for(int d = 0; d < 2; d++)
    {
     CArrayObj *list = m_market.GetList();
     list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
     list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, _Symbol, EQUAL);
     list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dirs[d], EQUAL);
     if(list == NULL) continue;
     double src_sl = 0, src_tp = 0; bool found = false;
     for(int i = 0; i < list.Total(); i++)
      {
       CMarketPosition *pos = (CMarketPosition*)list.At(i);
       if(pos != NULL && (ulong)pos.Ticket() == modified_ticket)
        { src_sl = pos.StopLoss(); src_tp = pos.TakeProfit(); found = true; break; }
      }
     if(!found) continue; // wrong direction, or not this chart's symbol at all
     for(int i = list.Total() - 1; i >= 0; i--)
      {
       CMarketPosition *pos = (CMarketPosition*)list.At(i);
       if(pos == NULL) continue;
       if((ulong)pos.Ticket() == modified_ticket) continue; // don't re-modify the source itself
       m_trading_control.ModifyPosition((ulong)pos.Ticket(), src_sl, src_tp);
      }
     return;
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
