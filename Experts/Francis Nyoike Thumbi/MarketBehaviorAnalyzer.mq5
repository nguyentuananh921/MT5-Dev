//+------------------------------------------------------------------+
//|                                     MarketBehaviorAnalyzer.mq5   |
//|                               Copyright 2026, Francis Nyoike.    |
//|                                             https://www.mql5.com |
//| https://www.mql5.com/en/articles/23852                           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Francis Nyoike."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

//--- Input Parameters
input group "=== Lookback & Swing Settings ==="
input int      InpLookbackCandles = 100;                 // Recent bars to analyze
input int      InpDepth           = 10;                  // Bars each side for swing confirmation
input double   InpMinDistPoints   = 0.0;                 // Min distance from previous accepted pivot of the same type (points)

input group "=== Visual Settings ==="
input bool     InpShowLines       = true;                // Connect swings with lines
input bool     InpShowLabels      = true;                // Show HH/HL/LH/LL labels
input int      InpFontSize        = 8;                   // Label font size
input color    InpImpulseColor    = clrLimeGreen;        // Impulse line color
input color    InpPullbackColor   = clrTomato;           // Pullback line color
input color    InpLowColor        = clrDeepSkyBlue;      // Swing low arrow color
input bool     InpShowDashboard   = true;                // Show dashboard

input group "=== UI Settings ==="
input bool     InpShowMarketStory      = true;           // Enable Market Story Panel
input bool     InpEnableSwingInspector = true;           // Enable Swing Inspector on Click
input color    InpPanelBackground      = clrBlack;       // Panel background color
input color    InpPanelBorder          = clrDimGray;     // Panel border color
input color    InpPanelTitle           = clrDeepSkyBlue; // Panel title text color
input color    InpLabelColor           = clrSilver;      // Field label color
input color    InpValueColor           = clrWhite;       // Field value color
input color    InpBullishColor         = clrLimeGreen;   // Bullish status color
input color    InpBearishColor         = clrTomato;      // Bearish status color
input color    InpNeutralColor         = clrGold;        // Neutral/Transition status color

//--- Object prefix
string         Prefix = "MBA_";

//+------------------------------------------------------------------+
//| LAYER 1 — MARKET ANALYZER DATA STRUCTURES                        |
//+------------------------------------------------------------------+
struct SwingPt
  {
   datetime          t;                   // Timestamp of swing pivot
   double            price;               // Price level of swing pivot
   int               type;                // 1 = High, -1 = Low
   string            label;               // HH / LH / HL / LL classification
   int               bar_index;           // Bar index in series indexing (0 = current bar)
   double            move_length_pips;     // Length of move leading to this swing (in pips)
   int               bars_required;       // Bars taken to form move leading to this swing
   string            move_type;           // Impulse or Pullback
   double            retracement_pct;     // Retracement percentage relative to prior move (capped at 100%)
   int               prev_index;          // Array index of previous swing (-1 if none)
   int               next_index;          // Array index of next swing (-1 if pending)
  };

//+------------------------------------------------------------------+
//| LAYER 2 — STORY ENGINE DATA STRUCTURES                           |
//+------------------------------------------------------------------+
struct MarketStoryState
  {
   string            structure;               // Bullish, Bearish, or Transition (reserved fallback)
   string            current_phase;           // Impulse, Pullback, or Consolidation (reserved fallback)
   string            latest_swing_label;      // HH, HL, LH, LL, or N/A
   string            next_expectation;        // Expected next structural form
   double            last_impulse_pips;       // Size of last confirmed impulse (pips)
   double            current_pullback_pips;   // Size of latest completed pullback (pips)
   double            retracement_pct;         // Retracement ratio of latest completed pullback
   string            structure_status;        // Intact or Threat
  };

//--- Global Engine State
datetime          g_lastBarTime       = 0;
SwingPt           g_swings[];                 // Global array storing current lookback swings
MarketStoryState  g_story;                    // Current evaluated market story
int               g_selectedSwingIdx  = -1;   // Index of swing currently displayed in Inspector
ulong g_lastObjectClickTime = 0;              // State tracking for event debouncing
//+------------------------------------------------------------------+
//| Pip Size Helper                                                  |
//+------------------------------------------------------------------+
double GetPipSize()
  {
//--- 3-digit (JPY pairs) and 5-digit standard Forex pairs
   if(_Digits == 3 || _Digits == 5)
      return(_Point * 10.0);

//-- 2-digit (Gold/XAUUSD) or 4-digit standard Forex
   return(_Point);
  }

//+------------------------------------------------------------------+
//| Custom Indicator Initialization Function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Enable chart event handling for mouse clicks
   ChartSetInteger(0, CHART_EVENT_OBJECT_CREATE, true);
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, false);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom Indicator Deinitialization Function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteAllObjects();
  }

//+------------------------------------------------------------------+
//| Custom Indicator Iteration Function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total < InpLookbackCandles || InpDepth < 1)
      return(rates_total);

   //--- Enforce series indexing: 0 = current live bar, moving backward into history
    ArraySetAsSeries(time, true);
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);

   //--- Only recalculate structural engine on new bar formation to maintain efficiency
    if(time[0] == g_lastBarTime && prev_calculated == rates_total)
      return(rates_total);

    g_lastBarTime = time[0];

   //--- Clear past objects so only active lookback window is rendered visually
    DeleteAllObjects();

   //--- LAYER 1: MARKET ANALYZER — DETECT & ENRICH SWING DATA

    int swing_count = AnalyzeMarketSwings(time, high, low);

   if(swing_count < 2)
     {
      if(InpShowDashboard && InpShowMarketStory)
         DrawEmptyMarketStoryPanel();
      return(rates_total);
     }

   //--- LAYER 2: STORY ENGINE — INTERPRET STRUCTURE & PHASES
    EvaluateMarketStory();

   //--- LAYER 3: USER INTERFACE — RENDER CHART OBJECTS & PANELS

    RenderChartVisuals();

   if(InpShowDashboard && InpShowMarketStory)
     {
      RenderMarketStoryPanel();
     }

   //--- Maintain active Swing Inspector panel state across bar updates
    if(InpEnableSwingInspector && g_selectedSwingIdx >= 0 && g_selectedSwingIdx < ArraySize(g_swings))
     {
      RenderSwingInspectorPanel(g_swings[g_selectedSwingIdx]);
     }

   ChartRedraw(0);
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| ChartEvent Handler for Interactive Swing Inspector               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(!InpEnableSwingInspector)
      return;

   //--- 1. Handle Object Click (User selects a swing arrow or text label)
    if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(StringFind(sparam, Prefix + "PT_") == 0)
        {
         //--- Record time of object click to prevent immediate trigger of CHARTEVENT_CLICK
         g_lastObjectClickTime = GetTickCount();

         //--- Parse swing timestamp and type from object name
         string parts[];
         if(StringSplit(sparam, '_', parts) >= 4)
           {
            datetime target_time = (datetime)StringToInteger(parts[2]);
            int target_type = (int)StringToInteger(parts[3]);
            int total_swings = ArraySize(g_swings);

            for(int i = 0; i < total_swings; i++)
              {
               if(g_swings[i].t == target_time && g_swings[i].type == target_type)
                 {
                  g_selectedSwingIdx = i;
                  RenderSwingInspectorPanel(g_swings[i]);
                  ChartRedraw(0);
                  return;
                 }
              }
           }
        }
     }
   //--- 2. Handle Empty Chart Click (User clicks on open space to close panel)
   if(id == CHARTEVENT_CLICK)
     {
      //--- Ignore click if it was triggered as part of an object click sequence (< 200ms)
      if(GetTickCount() - g_lastObjectClickTime < 200)
         return;

      if(g_selectedSwingIdx != -1)
        {
         g_selectedSwingIdx = -1;
         DeletePanelObjects(Prefix + "SI_");
         ChartRedraw(0);
        }
     }
  }

//+------------------------------------------------------------------+
//| LAYER 1 IMPLEMENTATION: DETECT AND ENRICH SWINGS                 |
//+------------------------------------------------------------------+
int AnalyzeMarketSwings(const datetime &time[], const double &high[], const double &low[])
  {
   ArrayFree(g_swings);
   SwingPt temp_swings[];
   ArrayResize(temp_swings, InpLookbackCandles*2);
   int count = 0;

   double last_high_price = 0.0;
   double last_low_price  = 0.0;
   bool has_high = false;
   bool has_low  = false;

   //--- Scan lookback window from oldest bars to newest
    for(int i = InpLookbackCandles - InpDepth - 1; i >= InpDepth; i--)
     {
      if(IsSwingHigh(i, high))
        {
         double price = high[i];
         if(!PassDistFilter(price, last_high_price, has_high))
            continue;

         string label = (!has_high || price > last_high_price) ? "HH" : "LH";
         last_high_price = price;
         has_high = true;

         temp_swings[count].t          = time[i];
         temp_swings[count].price      = price;
         temp_swings[count].type       = 1;
         temp_swings[count].label      = label;
         temp_swings[count].bar_index  = i;
         count++;
        }

      if(IsSwingLow(i, low))
        {
         double price = low[i];
         if(!PassDistFilter(price, last_low_price, has_low))
            continue;

         string label = (!has_low || price > last_low_price) ? "HL" : "LL";
         last_low_price = price;
         has_low = true;

         temp_swings[count].t          = time[i];
         temp_swings[count].price      = price;
         temp_swings[count].type       = -1;
         temp_swings[count].label      = label;
         temp_swings[count].bar_index  = i;
         count++;
        }
     }
    if(count == 0)
      return(0);

    ArrayResize(g_swings, count);

   //--- Copy and populate metadata linking swings together
    for(int s = 0; s < count; s++)
     {
      g_swings[s] = temp_swings[s];
      g_swings[s].prev_index = (s > 0) ? s - 1 : -1;
      g_swings[s].next_index = (s < count - 1) ? s + 1 : -1;

      if(s > 0)
        {
         g_swings[s].move_length_pips = MathAbs(g_swings[s].price - g_swings[s - 1].price) / GetPipSize();
         g_swings[s].bars_required   = MathAbs(g_swings[s].bar_index - g_swings[s - 1].bar_index);
         //--- Retracement calculation relative to previous swing move
         if(s >= 2)
           {
            double prior_move = MathAbs(g_swings[s - 1].price - g_swings[s - 2].price);
            double curr_move  = MathAbs(g_swings[s].price - g_swings[s - 1].price);

            double raw_retracement = (prior_move > 0) ? (curr_move / prior_move) * 100.0 : 0.0;
            g_swings[s].retracement_pct = MathMin(raw_retracement, 100.0);
           }
         else
           {
            g_swings[s].retracement_pct = 0.0;
           }
        }
      else
        {
         g_swings[s].move_length_pips = 0.0;
         g_swings[s].bars_required   = 0;
         g_swings[s].retracement_pct = 0.0;
        }
     }

    return(count);
  }
//+------------------------------------------------------------------+
//| LAYER 2 IMPLEMENTATION: STORY ENGINE (CONTEXT & PHASES)          |
//+------------------------------------------------------------------+
void EvaluateMarketStory()
  {
   int count = ArraySize(g_swings);
   if(count < 2)
      return;

   int last = count - 1;
   SwingPt latest_swing = g_swings[last];
   SwingPt prev_swing   = g_swings[last - 1];

   //--- 1. Determine Confirmed Structure based on the latest swing
    if(latest_swing.label == "HH" || latest_swing.label == "HL")
     {
      g_story.structure = "Bullish";
     }
    else
      if(latest_swing.label == "LH" || latest_swing.label == "LL")
        {
         g_story.structure = "Bearish";
        }
      else
        {
         g_story.structure = "Transition";
        }

   //--- 2. Classify Move Types (Impulse vs Pullback contextualized to Structure)
    for(int s = 1; s < count; s++)
     {
      bool rising = (g_swings[s - 1].price < g_swings[s].price);
      if(g_story.structure == "Bullish")
         g_swings[s].move_type = rising ? "Impulse" : "Pullback";
      else
         if(g_story.structure == "Bearish")
            g_swings[s].move_type = !rising ? "Impulse" : "Pullback";
         else
            g_swings[s].move_type = rising ? "Impulse" : "Pullback";
     }

   //--- 3. Latest Confirmed Phase & Structural Expectation
    g_story.current_phase      = g_swings[last].move_type;
    g_story.latest_swing_label = g_swings[last].label;

    if(g_story.structure == "Bullish")
     {
      g_story.next_expectation = (g_story.current_phase == "Impulse") ? "Higher Low" : "Higher High";
     }
    else
      if(g_story.structure == "Bearish")
        {
         g_story.next_expectation = (g_story.current_phase == "Impulse") ? "Lower High" : "Lower Low";
        }
      else
        {
         g_story.next_expectation = "Consolidation";
        }

   //--- 4. Calculate Impulse, Pullback & Retracement Metrics Phase-by-Phase
    if(g_story.current_phase == "Pullback")
     {
      g_story.current_pullback_pips = g_swings[last].move_length_pips;
      g_story.retracement_pct      = g_swings[last].retracement_pct;

      if(last >= 1)
         g_story.last_impulse_pips  = g_swings[last - 1].move_length_pips;
      else
         g_story.last_impulse_pips  = 0.0;

      //--- Structure threat check applies to the latest confirmed pullback
      if(g_story.retracement_pct > 80.0)
         g_story.structure_status = "Threatened";
      else
         g_story.structure_status = "Intact";
     }

   //--- Latest Phase == "Impulse"
    else
     {
      g_story.last_impulse_pips     = g_swings[last].move_length_pips;
      g_story.current_pullback_pips = 0.0;
      g_story.retracement_pct      = 0.0;
      g_story.structure_status     = "Intact"; // Active impulse expanding into structural territory is healthy
     }
  }
//+------------------------------------------------------------------+
//| LAYER 3 IMPLEMENTATION: RENDER CHART VISUALS                     |
//+------------------------------------------------------------------+
void RenderChartVisuals()
  {
   int count = ArraySize(g_swings);

   for(int s = 0; s < count; s++)
     {
      DrawSwingPoint(g_swings[s].t, g_swings[s].price, g_swings[s].type, g_swings[s].label);
     }

   if(InpShowLines)
     {
      for(int s = 0; s < count - 1; s++)
        {
         DrawSegmentLine(g_swings[s], g_swings[s + 1]);
        }
     }
  }

//+------------------------------------------------------------------+
//| MARKET STORY PANEL VISUALIZATION ENGINE                          |
//+------------------------------------------------------------------+
void RenderMarketStoryPanel()
  {
   string p = Prefix + "MS_";
   int x = 15;
   int y = 20;
   int width = 210;
   int row_h = 18;

   //--- Draw background card
   CreateOrUpdateRect(p + "BG", x, y, width, 185, InpPanelBackground, InpPanelBorder);

   //--- Title Header
    CreateOrUpdateLabel(p + "Title", x + 10, y + 8, "MARKET STORY", InpPanelTitle, 9, true);

   //--- Dynamic Color Formatting
    color struct_clr = (g_story.structure == "Bullish") ? InpBullishColor :
                      (g_story.structure == "Bearish") ? InpBearishColor : InpNeutralColor;
    color status_clr = (g_story.structure_status == "Intact") ? InpBullishColor : InpBearishColor;

    int curr_y = y + 28;
    DrawPanelRow(p, "Structure",        g_story.structure,                        x + 10, curr_y, struct_clr);
    curr_y += row_h;
    DrawPanelRow(p, "Latest Phase",    g_story.current_phase,                    x + 10, curr_y, InpValueColor);
    curr_y += row_h;
    DrawPanelRow(p, "Latest Swing",     g_story.latest_swing_label,               x + 10, curr_y, InpValueColor);
    curr_y += row_h;
    DrawPanelRow(p, "Next Expectation", g_story.next_expectation,                 x + 10, curr_y, InpNeutralColor);
    curr_y += row_h;
    DrawPanelRow(p, "Last Impulse",     StringFormat("%.1f pips", g_story.last_impulse_pips), x + 10, curr_y, InpValueColor);
    curr_y += row_h;
    DrawPanelRow(p, "Latest Pullback", StringFormat("%.1f pips", g_story.current_pullback_pips), x + 10, curr_y, InpValueColor);
    curr_y += row_h;
    DrawPanelRow(p, "Retracement",      StringFormat("%.1f%%", g_story.retracement_pct),      x + 10, curr_y, InpValueColor);
    curr_y += row_h;
    DrawPanelRow(p, "Structure Status", g_story.structure_status,                 x + 10, curr_y, status_clr);
  }

//+------------------------------------------------------------------+
//| SWING INSPECTOR PANEL VISUALIZATION ENGINE                       |
//+------------------------------------------------------------------+
void RenderSwingInspectorPanel(const SwingPt &sw)
  {
   string p = Prefix + "SI_";
   int x = 240; // Offset relative to Market Story panel
   int y = 20;
   int width = 210;
   int row_h = 18;

   CreateOrUpdateRect(p + "BG", x, y, width, 185, InpPanelBackground, InpPanelBorder);
   CreateOrUpdateLabel(p + "Title", x + 10, y + 8, "SWING INSPECTOR", InpPanelTitle, 9, true);

   string prev_label = (sw.prev_index >= 0) ? g_swings[sw.prev_index].label : "None";
   string next_label = (sw.next_index >= 0) ? g_swings[sw.next_index].label : "Pending";

   int curr_y = y + 28;
   DrawPanelRow(p, "Structure",      sw.label,                               x + 10, curr_y, InpPanelTitle);
   curr_y += row_h;
   DrawPanelRow(p, "Time",           TimeToString(sw.t, TIME_DATE|TIME_MINUTES), x + 10, curr_y, InpValueColor);
   curr_y += row_h;
   DrawPanelRow(p, "Price",          DoubleToString(sw.price, _Digits),     x + 10, curr_y, InpValueColor);
   curr_y += row_h;
   DrawPanelRow(p, "Move Type",      sw.move_type,                           x + 10, curr_y, (sw.move_type == "Impulse") ? InpImpulseColor : InpPullbackColor);
   curr_y += row_h;
   DrawPanelRow(p, "Move Length",    StringFormat("%.1f pips", sw.move_length_pips), x + 10, curr_y, InpValueColor);
   curr_y += row_h;
   DrawPanelRow(p, "Bars Required",  IntegerToString(sw.bars_required),     x + 10, curr_y, InpValueColor);
   curr_y += row_h;
   DrawPanelRow(p, "Previous Swing", prev_label,                             x + 10, curr_y, InpLabelColor);
   curr_y += row_h;
   DrawPanelRow(p, "Next Swing",     next_label,                             x + 10, curr_y, InpLabelColor);
  }
//+------------------------------------------------------------------+
//| UTILITY HELPERS FOR DRAWING AND OBJECT MANAGMENT                 |
//+------------------------------------------------------------------+
void DrawPanelRow(string prefix, string label, string val, int x, int y, color val_clr)
  {
    CreateOrUpdateLabel(prefix + label + "_L", x, y, label, InpLabelColor, 8, false);
   //--- Shift value X-offset to make room for wide values like dates
    CreateOrUpdateLabel(prefix + label + "_V", x + 100, y, val, val_clr, 8, true);
  }

//+------------------------------------------------------------------+
//| Creates or updates a panel rectangle background object           |
//+------------------------------------------------------------------+
void CreateOrUpdateRect(string name, int x, int y, int w, int h, color bg_clr, color border_clr)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
     }
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg_clr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, border_clr);
  }

//+------------------------------------------------------------------+
//| Creates or updates a UI text label object                        |
//+------------------------------------------------------------------+
void CreateOrUpdateLabel(string name, int x, int y, string text, color clr, int font_size, bool bold)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
     }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetString(0, name, OBJPROP_FONT, bold ? "Consolas Bold" : "Consolas");
  }

//+------------------------------------------------------------------+
//| Draws a swing point arrow and text label on the chart            |
//+------------------------------------------------------------------+
void DrawSwingPoint(const datetime t, const double price, const int type, const string label)
  {
   string base = Prefix + "PT_" + IntegerToString((long)t) + "_" + IntegerToString(type);

   ObjectCreate(0, base, OBJ_ARROW, 0, t, price);
   ObjectSetInteger(0, base, OBJPROP_COLOR, type == 1 ? InpPullbackColor : InpLowColor);
   ObjectSetInteger(0, base, OBJPROP_ARROWCODE, type == 1 ? 234 : 233);
   ObjectSetInteger(0, base, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, base, OBJPROP_BACK, false);

   if(InpShowLabels)
     {
      string txt = base + "_L";
      ObjectCreate(0, txt, OBJ_TEXT, 0, t, price);
      ObjectSetString(0, txt, OBJPROP_TEXT, label);
      ObjectSetInteger(0, txt, OBJPROP_COLOR, type == 1 ? InpPullbackColor : InpLowColor);
      ObjectSetInteger(0, txt, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetInteger(0, txt, OBJPROP_ANCHOR, type == 1 ? ANCHOR_LOWER : ANCHOR_UPPER);
      ObjectSetString(0, txt, OBJPROP_FONT, "Consolas");
     }
  }

//+------------------------------------------------------------------+
//| Draws connecting segment line between two swing points           |
//+------------------------------------------------------------------+
void DrawSegmentLine(const SwingPt &a, const SwingPt &b)
  {
   string name = Prefix + "LN_" + IntegerToString((long)a.t) + "_" + IntegerToString((long)b.t);

   ObjectCreate(0, name, OBJ_TREND, 0, a.t, a.price, b.t, b.price);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);

   color line_color = (b.move_type == "Impulse") ? InpImpulseColor : InpPullbackColor;
   ObjectSetInteger(0, name, OBJPROP_COLOR, line_color);
  }

//+------------------------------------------------------------------+
//| Draws default Market Story panel when insufficient swings exist  |
//+------------------------------------------------------------------+
void DrawEmptyMarketStoryPanel()
  {
   string p = Prefix + "MS_";
   CreateOrUpdateRect(p + "BG", 15, 20, 235, 185, InpPanelBackground, InpPanelBorder);
   CreateOrUpdateLabel(p + "Title", 25, 28, "MARKET STORY", InpPanelTitle, 9, true);
   CreateOrUpdateLabel(p + "Status", 25, 50, "Analyzing structure...", InpLabelColor, 8, false);
  }
//+------------------------------------------------------------------+
//| Swing high detection using series indexing                       |
//+------------------------------------------------------------------+
bool IsSwingHigh(const int i, const double &high[])
  {
   for(int k = 1; k <= InpDepth; k++)
     {
      if(high[i] <= high[i - k])
         return(false);
      if(high[i] <= high[i + k])
         return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Swing low detection using series indexing                        |
//+------------------------------------------------------------------+
bool IsSwingLow(const int i, const double &low[])
  {
   for(int k = 1; k <= InpDepth; k++)
     {
      if(low[i] >= low[i - k])
         return(false);
      if(low[i] >= low[i + k])
         return(false);
     }
   return(true);
  }

//+--------------------------------------------------------------------------------------+
//|Filters candidate pivots against the previous accepted pivot of the same type         |
//+--------------------------------------------------------------------------------------+
bool PassDistFilter(const double price, const double prev, const bool has_prev)
  {
   if(!has_prev || InpMinDistPoints <= 0.0)
      return(true);
   return(MathAbs(price - prev) >= InpMinDistPoints * _Point);
  }

//+------------------------------------------------------------------+
//| Deletes UI panel objects matching a specific prefix              |
//+------------------------------------------------------------------+
void DeletePanelObjects(string panel_prefix)
  {
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, panel_prefix) == 0)
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//| Deletes all indicator objects from the chart                     |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, Prefix) == 0)
         ObjectDelete(0, name);
     }
  }
//+------------------------------------------------------------------+
