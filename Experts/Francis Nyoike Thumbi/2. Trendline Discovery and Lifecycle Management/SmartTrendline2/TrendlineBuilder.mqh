//+------------------------------------------------------------------+
//|                                             TrendlineBuilder.mqh |
//|                                   Copyright 2026, Francis Nyoike |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Francis Nyoike"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Common.mqh"
#include "Geometry.mqh"

//+------------------------------------------------------------------+
//| Internal Swing Point Structure for Builder Detection             |
//+------------------------------------------------------------------+
struct BuilderSwingPt
  {
   datetime          t;          // Timestamp of swing pivot
   double            price;      // Price level of swing pivot
   int               type;       // 1 = High, -1 = Low
   string            label;      // HH, HL, LH, LL
   int               bar_index;  // Series bar index
  };

//+------------------------------------------------------------------+
//| Automatic Trendline Builder Engine                               |
//| Discovers market swings and constructs candidate trendlines.     |
//+------------------------------------------------------------------+
class CTrendlineBuilder
  {
private:
   long              m_chart_id;
   string            m_prefix;

   //--- Structural Detection Parameters
   int               m_lookback_bars;
   int               m_depth;
   int               m_min_swings;
   int               m_min_bars_between;
   int               m_confirmation_bars;
   bool              m_auto_bullish;
   bool              m_auto_bearish;

   //--- Internal Swing Buffer
   BuilderSwingPt    m_swings[];

private:
   bool              IsSwingHigh(const int i, const double &high[], const int total_bars);
   bool              IsSwingLow(const int i, const double &low[], const int total_bars);
   int               ExtractSwings(const datetime &time[], const double &high[], const double &low[], const int total_bars);

   bool              BuildBullishTrendline(const datetime &time[]);
   bool              BuildBearishTrendline(const datetime &time[]);

   string            GenerateObjectName(const string dir, const datetime t1, const datetime t2);
   bool              CreateChartTrendline(const string name, const datetime t1, const double p1, const datetime t2, const double p2);

public:
                     CTrendlineBuilder(const string prefix = DEFAULT_TRENDLINE_PREFIX,
                     int lookback_bars = 100,
                     int depth = 5,
                     int min_swings = 2,
                     int min_bars_between = 5,
                     int confirmation_bars = 3,
                     bool auto_bullish = true,
                     bool auto_bearish = true,
                     long chart_id = 0);
                    ~CTrendlineBuilder();

   //--- Configuration Setter
   void              Configure(int lookback_bars, int depth, int min_swings, int min_bars_between,
                               int confirmation_bars, bool auto_bullish, bool auto_bearish);

   //--- Core Scan & Build Routine (Returns number of created lines)
   int               ScanAndBuild(const datetime &time[], const double &high[], const double &low[], const int rates_total);
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTrendlineBuilder::CTrendlineBuilder(const string prefix,
                                     int lookback_bars,
                                     int depth,
                                     int min_swings,
                                     int min_bars_between,
                                     int confirmation_bars,
                                     bool auto_bullish,
                                     bool auto_bearish,
                                     long chart_id)
   : m_prefix(prefix),
     m_lookback_bars(lookback_bars),
     m_depth(depth),
     m_min_swings(min_swings),
     m_min_bars_between(min_bars_between),
     m_confirmation_bars(confirmation_bars),
     m_auto_bullish(auto_bullish),
     m_auto_bearish(auto_bearish),
     m_chart_id(chart_id)
  {
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTrendlineBuilder::~CTrendlineBuilder()
  {
   ArrayFree(m_swings);
  }

//+------------------------------------------------------------------+
//| Updates builder configuration at runtime                         |
//+------------------------------------------------------------------+
void CTrendlineBuilder::Configure(int lookback_bars, int depth, int min_swings, int min_bars_between,
                                  int confirmation_bars, bool auto_bullish, bool auto_bearish)
  {
   m_lookback_bars     = lookback_bars;
   m_depth             = depth;
   m_min_swings        = min_swings;
   m_min_bars_between  = min_bars_between;
   m_confirmation_bars = confirmation_bars;
   m_auto_bullish      = auto_bullish;
   m_auto_bearish      = auto_bearish;
  }

//+------------------------------------------------------------------+
//| Bilateral Swing High Detection                                   |
//+------------------------------------------------------------------+
bool CTrendlineBuilder::IsSwingHigh(const int i, const double &high[], const int total_bars)
  {
   if(i - m_depth < 0 || i + m_depth >= total_bars)
      return false;

   for(int k = 1; k <= m_depth; k++)
     {
      if(high[i] <= high[i - k] || high[i] <= high[i + k])
         return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Bilateral Swing Low Detection                                    |
//+------------------------------------------------------------------+
bool CTrendlineBuilder::IsSwingLow(const int i, const double &low[], const int total_bars)
  {
   if(i - m_depth < 0 || i + m_depth >= total_bars)
      return false;

   for(int k = 1; k <= m_depth; k++)
     {
      if(low[i] >= low[i - k] || low[i] >= low[i + k])
         return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Scans lookback range and extracts classified swing structure     |
//+------------------------------------------------------------------+
int CTrendlineBuilder::ExtractSwings(const datetime &time[], const double &high[], const double &low[], const int total_bars)
  {
   ArrayFree(m_swings);
   BuilderSwingPt temp[];
   int scan_limit = MathMin(m_lookback_bars, total_bars - m_depth - 1);
   ArrayResize(temp, scan_limit);
   int count = 0;

   double last_high_price = 0.0;
   double last_low_price  = 0.0;
   bool has_high = false;
   bool has_low  = false;

   int start_bar = scan_limit;
   int end_bar   = MathMax(m_depth, m_confirmation_bars);

   for(int i = start_bar; i >= end_bar; i--)
     {
      if(IsSwingHigh(i, high, total_bars))
        {
         double price = high[i];
         string label = (!has_high || price > last_high_price) ? "HH" : "LH";
         last_high_price = price;
         has_high = true;

         temp[count].t         = time[i];
         temp[count].price     = price;
         temp[count].type      = 1;
         temp[count].label     = label;
         temp[count].bar_index = i;
         count++;
        }

      if(IsSwingLow(i, low, total_bars))
        {
         double price = low[i];
         string label = (!has_low || price > last_low_price) ? "HL" : "LL";
         last_low_price = price;
         has_low = true;

         temp[count].t         = time[i];
         temp[count].price     = price;
         temp[count].type      = -1;
         temp[count].label     = label;
         temp[count].bar_index = i;
         count++;
        }
     }

   if(count == 0)
      return 0;

   ArrayResize(m_swings, count);
   for(int s = 0; s < count; s++)
      m_swings[s] = temp[s];

   return count;
  }

//+------------------------------------------------------------------+
//| Identifies qualifying HL sequence and creates Bullish trendline  |
//+------------------------------------------------------------------+
bool CTrendlineBuilder::BuildBullishTrendline(const datetime &time[])
  {
   int total = ArraySize(m_swings);
   if(total < m_min_swings)
      return false;

   int hl_indices[];
   int hl_count = 0;

   for(int i = 0; i < total; i++)
     {
      if(m_swings[i].label == "HL")
        {
         ArrayResize(hl_indices, hl_count + 1);
         hl_indices[hl_count] = i;
         hl_count++;
        }
     }

   if(hl_count < m_min_swings)
      return false;

   int idx_anchor2 = hl_indices[hl_count - 1];
   int idx_anchor1 = hl_indices[hl_count - m_min_swings];

   BuilderSwingPt p1 = m_swings[idx_anchor1];
   BuilderSwingPt p2 = m_swings[idx_anchor2];

   if(MathAbs(p1.bar_index - p2.bar_index) < m_min_bars_between)
      return false;

   if(p2.price <= p1.price)
      return false;

   string line_name = GenerateObjectName("BULL", p1.t, p2.t);
   return CreateChartTrendline(line_name, p1.t, p1.price, p2.t, p2.price);
  }

//+------------------------------------------------------------------+
//| Identifies qualifying LH sequence and creates Bearish trendline  |
//+------------------------------------------------------------------+
bool CTrendlineBuilder::BuildBearishTrendline(const datetime &time[])
  {
   int total = ArraySize(m_swings);
   if(total < m_min_swings)
      return false;

   int lh_indices[];
   int lh_count = 0;

   for(int i = 0; i < total; i++)
     {
      if(m_swings[i].label == "LH")
        {
         ArrayResize(lh_indices, lh_count + 1);
         lh_indices[lh_count] = i;
         lh_count++;
        }
     }

   if(lh_count < m_min_swings)
      return false;

   int idx_anchor2 = lh_indices[lh_count - 1];
   int idx_anchor1 = lh_indices[lh_count - m_min_swings];

   BuilderSwingPt p1 = m_swings[idx_anchor1];
   BuilderSwingPt p2 = m_swings[idx_anchor2];

   if(MathAbs(p1.bar_index - p2.bar_index) < m_min_bars_between)
      return false;

   if(p2.price >= p1.price)
      return false;

   string line_name = GenerateObjectName("BEAR", p1.t, p2.t);
   return CreateChartTrendline(line_name, p1.t, p1.price, p2.t, p2.price);
  }

//+------------------------------------------------------------------+
//| Generates deterministic object name based on structural anchors  |
//+------------------------------------------------------------------+
string CTrendlineBuilder::GenerateObjectName(const string dir, const datetime t1, const datetime t2)
  {
   return StringFormat("%sAUTO_%s_%d_%d", m_prefix, dir, (int)t1, (int)t2);
  }

//+------------------------------------------------------------------+
//| Creates OBJ_TREND on chart if duplicate does not exist           |
//+------------------------------------------------------------------+
bool CTrendlineBuilder::CreateChartTrendline(const string name, const datetime t1, const double p1, const datetime t2, const double p2)
  {
   if(ObjectFind(m_chart_id, name) >= 0)
      return false;

   if(!ObjectCreate(m_chart_id, name, OBJ_TREND, 0, t1, p1, t2, p2))
      return false;

   ObjectSetInteger(m_chart_id, name, OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(m_chart_id, name, OBJPROP_BACK, true);
   ObjectSetInteger(m_chart_id, name, OBJPROP_WIDTH, TrendlineDefaults::DefaultWidth);
   ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, TrendlineDefaults::ActiveColor);
   ObjectSetInteger(m_chart_id, name, OBJPROP_SELECTABLE, true);

   PrintFormat("//--- [TrendlineBuilder] Created auto trendline: '%s' (P1: %.5f @ %s | P2: %.5f @ %s)",
               name, p1, TimeToString(t1), p2, TimeToString(t2));

   return true;
  }

//+------------------------------------------------------------------+
//| Master Execution Method                                          |
//+------------------------------------------------------------------+
int CTrendlineBuilder::ScanAndBuild(const datetime &time[], const double &high[], const double &low[], const int rates_total)
  {
   if(rates_total < m_lookback_bars || rates_total < (m_depth * 2 + 1))
      return 0;

   int swing_count = ExtractSwings(time, high, low, rates_total);
   if(swing_count < m_min_swings)
      return 0;

   int created = 0;

   if(m_auto_bullish && BuildBullishTrendline(time))
      created++;

   if(m_auto_bearish && BuildBearishTrendline(time))
      created++;

   return created;
  }
//+------------------------------------------------------------------+

