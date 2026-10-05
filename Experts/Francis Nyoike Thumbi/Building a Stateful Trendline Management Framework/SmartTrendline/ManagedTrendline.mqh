//+------------------------------------------------------------------+
//|                                         ManagedTrendline.mqh     |
//|                                  Copyright 2026, Francis Nyoike. |
//|                                      https://www.mql5.com        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Francis Nyoike."
#property link      "https://www.mql5.com"
#include <Object.mqh>
#include "Common.mqh"
#include "Geometry.mqh"

//+------------------------------------------------------------------+
//| Encapsulates a single chart trendline object and its state.      |
//| Inherits from CObject to enable CArrayObj collection management. |
//+------------------------------------------------------------------+
class CManagedTrendline : public CObject
  {
private:
   //--- Object Identity
   string               m_name;            // Chart object name
   long                 m_chart_id;        // Target chart ID

   //--- Time & Price Coordinates
   datetime             m_time1;           // Anchor 1 timestamp
   double               m_price1;          // Anchor 1 price
   datetime             m_time2;           // Anchor 2 timestamp
   double               m_price2;          // Anchor 2 price

   //--- State & Tracking
   ENUM_TRENDLINE_STATE m_state;              // Current lifecycle state
   int                  m_touch_count;        // Total touches recorded
   int                  m_bounce_count;       // Total confirmed bounces recorded
   datetime             m_last_touch_time;    // Timestamp of last touch
   datetime             m_break_time;         // Timestamp of breakout
   bool                 m_was_recently_moved; // Flag indicating direct user drag/modification

   //--- Pending Resolution Tracking
   int                  m_pending_close_count; // Number of completed candles observed in pending state
   int                  m_break_close_count;   // Accumulated breakout confirmation closes
   int                  m_bounce_close_count;  // Accumulated bounce confirmation closes
   bool                 m_support_context;     // Locked interaction context (true = support, false = resistance)

   //--- Settings & Volatility Thresholds
   double               m_proximity_pts;           // Touch tolerance in points
   double               m_break_atr_mult;          // ATR multiplier for BROKEN confirmation
   int                  m_break_confirm_closes;    // Required closes for breakout confirmation
   double               m_bounce_atr_mult;         // ATR multiplier for BOUNCED confirmation
   int                  m_bounce_confirm_closes;   // Required closes for bounce confirmation
   double               m_touch_atr_mult;          // ATR multiplier for TOUCH_PENDING trigger

private:
   //--- Internal Styling Helpers
   void                 UpdateVisualState();

public:
                     CManagedTrendline(const string name,
                     long chart_id = 0,
                     double proximity_pts = DEFAULT_TOUCH_PROXIMITY_PTS,
                     double break_atr = DEFAULT_BREAK_ATR_MULT,
                     int break_confirm_closes = 1,
                     double bounce_atr = DEFAULT_BOUNCE_ATR_MULT,
                     int bounce_confirm_closes = 1);
                    ~CManagedTrendline();

   //--- Lifecycle & State Engine
   bool                 RefreshProperties();
   bool                 Update(const double &open[], const double &high[], const double &low[], const double &close[], const datetime &time[], const double atr);
   void                 EvaluateLiveDrag();

   //--- Object Getters
   string               GetName()          const { return m_name; }
   ENUM_TRENDLINE_STATE GetState()         const { return m_state; }
   int                  GetTouchCount()    const { return m_touch_count; }
   int                  GetBounceCount()   const { return m_bounce_count; }
   bool                 WasRecentlyMoved() const { return m_was_recently_moved; }

   //--- Coordinate Conversion & Price Helpers
   double               GetPriceAtBarIndex(int bar_index, const datetime &time[]) const;
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CManagedTrendline::CManagedTrendline(const string name,
                                     long chart_id,
                                     double proximity_pts,
                                     double break_atr,
                                     int break_confirm_closes,
                                     double bounce_atr,
                                     int bounce_confirm_closes)
   : m_name(name),
     m_chart_id(chart_id),
     m_time1(0),
     m_price1(0.0),
     m_time2(0),
     m_price2(0.0),
     m_state(TRENDLINE_STATE_UNKNOWN),
     m_touch_count(0),
     m_bounce_count(0),
     m_last_touch_time(0),
     m_break_time(0),
     m_was_recently_moved(false),
     m_pending_close_count(0),
     m_break_close_count(0),
     m_bounce_close_count(0),
     m_support_context(false),
     m_proximity_pts(proximity_pts),
     m_break_atr_mult(break_atr),
     m_break_confirm_closes(break_confirm_closes),
     m_bounce_atr_mult(bounce_atr),
     m_bounce_confirm_closes(bounce_confirm_closes),
     m_touch_atr_mult(DEFAULT_TOUCH_ATR_MULT)
  {
   RefreshProperties();
   UpdateVisualState();

//--- Debug log on successful creation
   PrintFormat("//--- [SmartTrendline] Managed Trendline Created: '%s' | Initial State: %s",
               m_name, EnumToString(m_state));
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CManagedTrendline::~CManagedTrendline()
  {
//--- Debug log on object deletion
   PrintFormat("//--- [SmartTrendline] Managed Trendline Released: '%s' | Final Touch Count: %d | Final Bounce Count: %d",
               m_name, m_touch_count, m_bounce_count);
  }

//+------------------------------------------------------------------+
//| Refreshes anchor coordinates directly from chart properties.     |
//+------------------------------------------------------------------+
bool CManagedTrendline::RefreshProperties()
  {
   if(!ObjectGetInteger(m_chart_id, m_name, OBJPROP_TIME, 0, m_time1) ||
      !ObjectGetDouble(m_chart_id, m_name, OBJPROP_PRICE, 0, m_price1) ||
      !ObjectGetInteger(m_chart_id, m_name, OBJPROP_TIME, 1, m_time2) ||
      !ObjectGetDouble(m_chart_id, m_name, OBJPROP_PRICE, 1, m_price2))
     {
      return false;
     }

//--- Mark flag so live engine evaluates immediate tick proximity
   m_was_recently_moved = true;

//--- Default state to active if previously unknown or edited
   if(m_state == TRENDLINE_STATE_UNKNOWN)
      m_state = TRENDLINE_STATE_ACTIVE;

   return true;
  }

//+------------------------------------------------------------------+
//| Evaluates price projection relative to bar index using Geometry. |
//+------------------------------------------------------------------+
double CManagedTrendline::GetPriceAtBarIndex(int bar_index, const datetime &time[]) const
  {
   if(bar_index < 0 || bar_index >= ArraySize(time))
      return 0.0;

   Point2D p1, p2;
   p1.x = (double)m_time1;
   p1.y = m_price1;
   p2.x = (double)m_time2;
   p2.y = m_price2;

   return CGeometry::GetYAtX(p1, p2, (double)time[bar_index]);
  }

//+------------------------------------------------------------------+
//| Immediate On-Tick Live Drag Proximity Evaluation Routine.        |
//+------------------------------------------------------------------+
void CManagedTrendline::EvaluateLiveDrag()
  {
   if(!m_was_recently_moved)
      return;

//--- Lower flag after one-shot evaluation
   m_was_recently_moved = false;

//--- Only evaluate active lines
   if(m_state != TRENDLINE_STATE_ACTIVE)
      return;

   double live_bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   Point2D p1, p2;
   p1.x = (double)m_time1;
   p1.y = m_price1;
   p2.x = (double)m_time2;
   p2.y = m_price2;

   double line_price = CGeometry::GetYAtX(p1, p2, (double)TimeCurrent());

   if(line_price == 0.0)
      return;

   double proximity_margin = m_proximity_pts * _Point;

//--- Check if live bid is within proximity threshold upon manual edit/drag
   if(MathAbs(live_bid - line_price) <= proximity_margin)
     {
      ENUM_TRENDLINE_STATE previous_state = m_state;

      m_touch_count++;
      m_last_touch_time = TimeCurrent();
      m_pending_close_count = 0;
      m_break_close_count = 0;
      m_bounce_close_count = 0;
      m_support_context = (live_bid >= line_price);
      m_state            = TRENDLINE_STATE_TOUCH_PENDING;

      PrintFormat("//--- [SmartTrendline] Object '%s' Live Drag Touch Intercept: %s -> %s | Total Touches: %d",
                  m_name, EnumToString(previous_state), EnumToString(m_state), m_touch_count);

      UpdateVisualState();
     }
  }
//+------------------------------------------------------------------+
//| Core State Machine & Pending Resolution Engine Routine.          |
//+------------------------------------------------------------------+
bool CManagedTrendline::Update(const double &open[], const double &high[], const double &low[], const double &close[], const datetime &time[], const double atr)
  {
   if(ArraySize(close) < 3)
      return false;

//--- Evaluate latest closed bar (Bar 1)
   int bar_idx = 1;
   double expected_price = GetPriceAtBarIndex(bar_idx, time);
   if(expected_price == 0.0)
      return false;

   double current_close = close[bar_idx];

//--- Signed Difference: Positive = Above line (Support context), Negative = Below line (Resistance context)
   double signed_diff  = current_close - expected_price;
   double dist_to_line = MathAbs(signed_diff);

   ENUM_TRENDLINE_STATE previous_state = m_state;

//--- Convert point tolerance input to price units
   double proximity_price = m_proximity_pts * _Point;

//--- STATE 1: ACTIVE -> Shift to TOUCH_PENDING on Volatility/Proximity
   if(m_state == TRENDLINE_STATE_ACTIVE)
     {
      //--- Calculate dynamic touch threshold (ATR multiplier + static point proximity)
      double touch_threshold = (atr * m_touch_atr_mult) + proximity_price;

      if(dist_to_line <= touch_threshold ||
         MathAbs(high[bar_idx] - expected_price) <= touch_threshold ||
         MathAbs(low[bar_idx] - expected_price) <= touch_threshold)
        {
         if(m_last_touch_time != time[bar_idx])
           {
            m_touch_count++;
            m_last_touch_time = time[bar_idx];
            m_pending_close_count = 0;
            m_break_close_count = 0;
            m_bounce_close_count = 0;
            m_support_context = (current_close >= expected_price);
            m_state            = TRENDLINE_STATE_TOUCH_PENDING;
           }
        }
     }
//--- STATE 2: TOUCH_PENDING -> Deterministic Completed-Candle Resolution
   else
      if(m_state == TRENDLINE_STATE_TOUCH_PENDING)
        {
         m_pending_close_count++;

         double break_threshold  = (atr * m_break_atr_mult) + proximity_price;
         double bounce_threshold = (atr * m_bounce_atr_mult) + proximity_price;
         // --- SUPPORT INTERACTION CONTEXT ---
         if(m_support_context)
           {
            if(signed_diff <= -break_threshold)
              {
               m_break_close_count++;
               m_bounce_close_count = 0;
              }
            else
               if(signed_diff >= bounce_threshold)
                 {
                  m_bounce_close_count++;
                  m_break_close_count = 0;
                 }
               else
                 {
                  m_break_close_count = 0;
                  m_bounce_close_count = 0;
                 }
           }
         // --- RESISTANCE INTERACTION CONTEXT ---
         else
           {
            if(signed_diff >= break_threshold)
              {
               m_break_close_count++;
               m_bounce_close_count = 0;
              }
            else
               if(signed_diff <= -bounce_threshold)
                 {
                  m_bounce_close_count++;
                  m_break_close_count = 0;
                 }
               else
                 {
                  m_break_close_count = 0;
                  m_bounce_close_count = 0;
                 }
           }

         PrintFormat("//--- [SmartTrendline] '%s' Pending | Candles=%d | Break=%d | Bounce=%d",
                     m_name, m_pending_close_count, m_break_close_count, m_bounce_close_count);

         if(m_break_close_count >= m_break_confirm_closes)
           {
            m_state = TRENDLINE_STATE_BROKEN;
            m_break_time = time[bar_idx];
           }
         else
            if(m_bounce_close_count >= m_bounce_confirm_closes)
              {
               m_state = TRENDLINE_STATE_BOUNCED;
              }
        }
      //--- STATE 3: BOUNCED -> Record bounce count telemetry and reset to ACTIVE for subsequent retests
      else
         if(m_state == TRENDLINE_STATE_BOUNCED)
           {
            m_bounce_count++;
            PrintFormat("//--- [SmartTrendline] Object '%s' Bounce Confirmed! Total Bounces: %d", m_name, m_bounce_count);
            m_state = TRENDLINE_STATE_ACTIVE;
           }

//-- Handle state transition log & visual update
   if(m_state != previous_state)
     {
      PrintFormat("//--- [SmartTrendline] Object '%s' State Changed: %s -> %s | Total Touches: %d | Total Bounces: %d",
                  m_name, EnumToString(previous_state), EnumToString(m_state), m_touch_count, m_bounce_count);

      UpdateVisualState();
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Updates line visual appearance based on internal state.          |
//+------------------------------------------------------------------+
void CManagedTrendline::UpdateVisualState()
  {
   color target_color = TrendlineDefaults::ActiveColor;
   ENUM_LINE_STYLE target_style = TrendlineDefaults::ActiveStyle;
   int target_width = TrendlineDefaults::DefaultWidth;

   switch(m_state)
     {
      case TRENDLINE_STATE_ACTIVE:
      case TRENDLINE_STATE_BOUNCED:
         target_color = TrendlineDefaults::ActiveColor;
         target_style = TrendlineDefaults::ActiveStyle;
         break;

      case TRENDLINE_STATE_TOUCH_PENDING:
         target_color = TrendlineDefaults::TouchedColor;
         target_style = TrendlineDefaults::ActiveStyle;
         target_width = TrendlineDefaults::DefaultWidth + 1;
         break;

      case TRENDLINE_STATE_BROKEN:
         target_color = TrendlineDefaults::BrokenColor;
         target_style = TrendlineDefaults::BrokenStyle;
         break;

      case TRENDLINE_STATE_RETESTED:
         target_color = TrendlineDefaults::RetestedColor;
         target_style = TrendlineDefaults::ActiveStyle;
         break;

      default:
         break;
     }

//--- Apply visual modifications to chart object
   ObjectSetInteger(m_chart_id, m_name, OBJPROP_COLOR, target_color);
   ObjectSetInteger(m_chart_id, m_name, OBJPROP_STYLE, target_style);
   ObjectSetInteger(m_chart_id, m_name, OBJPROP_WIDTH, target_width);
   ChartRedraw(m_chart_id);
  }
//+------------------------------------------------------------------+


