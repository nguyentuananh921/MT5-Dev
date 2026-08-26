//+------------------------------------------------------------------+
//|                                                SwingEngine.mqh   |
//|   Multi-timeframe swing detection and trend classification       |
//|   Swings are calculated on a higher timeframe (default H4) and   |
//|   drawn correctly on whatever timeframe the chart is showing.    |
//+------------------------------------------------------------------+
#ifndef SWINGENGINE_MQH
#define SWINGENGINE_MQH

//+------------------------------------------------------------------+
//| Market structure classification                                  |
//+------------------------------------------------------------------+
enum ENUM_SWING_TREND
  {
   TREND_UP,    // Last confirmed swing high is HH and swing low is HL
   TREND_DOWN,  // Last confirmed swing high is LH and swing low is LL
   TREND_RANGE  // Mixed labels or insufficient swing history
  };

//+------------------------------------------------------------------+
//| One detected swing point                                         |
//+------------------------------------------------------------------+
struct SSwingPoint
  {
   bool              is_high;   // true = swing high, false = swing low
   double            price;     // Price of the swing (H4 high or low)
   datetime          time;      // Open time of the H4 swing bar
   int               bar_index; // H4 bars ago at time of detection
   string            label;     // "HH", "LH", "HL", or "LL"
  };

//+------------------------------------------------------------------+
//| Monetary value of one pip for a given symbol and lot size        |
//+------------------------------------------------------------------+
double GetPipValue(const string symbol, double lots)
  {
   double tick_val  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);   // Tick value
   double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);    // Tick size
   int    digits    = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);       // Symbol digits
   double point     = SymbolInfoDouble(symbol, SYMBOL_POINT);              // Point size
   double pip_size  = (digits == 3 || digits == 5) ? point * 10.0 : point; // Pip size
   if(tick_size <= 0 || tick_val <= 0)
      return 0;                                                            // Validate inputs
   return (pip_size / tick_size) * tick_val * lots;                        // Return pip value
  }

//+------------------------------------------------------------------+
//| Returns pip size in price units for the given symbol             |
//+------------------------------------------------------------------+
double PipSize(const string symbol)
  {
   int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);          // Symbol digits
   double point  = SymbolInfoDouble(symbol, SYMBOL_POINT);                 // Point size
   return (digits == 3 || digits == 5) ? point * 10.0 : point;             // Return pip size
  }

//+------------------------------------------------------------------+
//| CSwingEngine—HTF swing detection, chart-timeframe-agnostic       |
//+------------------------------------------------------------------+
class CSwingEngine
  {
private:
   SSwingPoint       m_swings[];     // Confirmed swing points (newest first)
   int               m_count;        // Number of swings currently stored
   int               m_strength;     // H4 bars required on each side to confirm a swing
   int               m_lookback;     // Maximum H4 bars to scan on each Update() call
   ENUM_SWING_TREND  m_trend;        // Current classified trend
   string            m_symbol;       // Symbol being analyzed
   ENUM_TIMEFRAMES   m_swing_tf;     // Timeframe swings are CALCULATED on (default H4)
   datetime          m_last_htf_bar; // Last H4 bar time processed

   //+------------------------------------------------------------------+
   //| Checks if H4 bar at index is a confirmed swing high              |
   //+------------------------------------------------------------------+
   bool              IsSwingHigh(const double &high[], int idx, int total)
     {
      if(idx - m_strength < 0 || idx + m_strength >= total)
         return false;                                                      // Boundary check
      for(int i = 1; i <= m_strength; i++)
        {
         if(high[idx - i] >= high[idx])
            return false;                                                   // Left side must be lower
         if(high[idx + i] >= high[idx])
            return false;                                                   // Right side must be lower
        }
      return true;                                                          // Confirmed swing high
     }

   //+------------------------------------------------------------------+
   //| Checks if H4 bar at index is a confirmed swing low               |
   //+------------------------------------------------------------------+
   bool              IsSwingLow(const double &low[], int idx, int total)
     {
      if(idx - m_strength < 0 || idx + m_strength >= total)
         return false;                                                      // Boundary check
      for(int i = 1; i <= m_strength; i++)
        {
         if(low[idx - i] <= low[idx])
            return false;                                                   // Left side must be higher
         if(low[idx + i] <= low[idx])
            return false;                                                   // Right side must be higher
        }
      return true;                                                          // Confirmed swing low
     }

   //+------------------------------------------------------------------+
   //| Sorts swings oldest-to-newest, assigns HH/LH/HL/LL labels, then  |
   //| reverses to newest-first so index 0 is always the most recent    |
   //+------------------------------------------------------------------+
   void              LabelSwings()
     {
      //--- Sort ascending by time—labeling must walk oldest to newest
      for(int i = 0; i < m_count - 1; i++)
         for(int j = i + 1; j < m_count; j++)
            if(m_swings[i].time > m_swings[j].time)
              {
               SSwingPoint tmp = m_swings[i];
               m_swings[i] = m_swings[j];
               m_swings[j] = tmp;
              }
      //--- Assign HH/LH/HL/LL by comparing each swing to the last of its kind
      double lastHigh = -1, lastLow = DBL_MAX;
      for(int i = 0; i < m_count; i++)
        {
         if(m_swings[i].is_high)
           {
            m_swings[i].label = (lastHigh < 0 || m_swings[i].price > lastHigh) ? "HH" : "LH";
            lastHigh = m_swings[i].price;
           }
         else
           {
            m_swings[i].label = (lastLow == DBL_MAX || m_swings[i].price > lastLow) ? "HL" : "LL";
            lastLow = m_swings[i].price;
           }
        }
      //--- Reverse to newest-first—matches the public GetSwing(0) contract
      for(int i = 0, j = m_count - 1; i < j; i++, j--)
        {
         SSwingPoint tmp = m_swings[i];
         m_swings[i] = m_swings[j];
         m_swings[j] = tmp;
        }
     }

   //+------------------------------------------------------------------+
   //| Classifies trend from the two most recent labels                 |
   //+------------------------------------------------------------------+
   void              ClassifyTrend()
     {
      if(m_count < 4)
        {
         m_trend = TREND_RANGE;
         return;
        }                                                                   // Need at least 4 swings
      SSwingPoint lastHigh = GetLastSwingHigh();                            // Most recent labeled high
      SSwingPoint lastLow  = GetLastSwingLow();                             // Most recent labeled low
      if(lastHigh.label == "HH" && lastLow.label == "HL")
         m_trend = TREND_UP;                                                // New high + higher low
      else
         if(lastHigh.label == "LH" && lastLow.label == "LL")
            m_trend = TREND_DOWN;                                           // New low + lower high
         else
            m_trend = TREND_RANGE;                                          // Mixed sequence
     }

public:
                     CSwingEngine() : m_count(0), m_strength(3), m_lookback(200),
                     m_trend(TREND_RANGE), m_swing_tf(PERIOD_H4),
                     m_last_htf_bar(0)
     { m_symbol = _Symbol; }

   //+------------------------------------------------------------------+
   //| Initialize the engine                                            |
   //| swing_tf is the timeframe structure is READ from (default H4).   |
   //| It is independent of whatever chart the calling code is on.      |
   //+------------------------------------------------------------------+
   bool              Init(int strength, int lookback,
                          ENUM_TIMEFRAMES swing_tf = PERIOD_H4,
                          const string symbol = "")
     {
      m_strength  = MathMax(1, strength);                                   // Minimum strength of 1
      m_lookback  = MathMax(m_strength * 4, lookback);                      // Minimum sensible lookback
      m_swing_tf  = swing_tf;                                               // Analysis timeframe
      m_symbol    = (symbol == "") ? _Symbol : symbol;                      // Use chart symbol if blank
      m_count     = 0;                                                      // Reset swing count
      m_last_htf_bar = 0;                                                   // Reset HTF bar tracker
      m_trend     = TREND_RANGE;                                            // Start as range
      ArrayResize(m_swings, 0);                                             // Clear swing array
      int bars_available = Bars(m_symbol, m_swing_tf);                      // Check available H4 bars
      if(bars_available < m_lookback + m_strength * 2)                      // Insufficient bars
        {
         Print("CSwingEngine: Insufficient ", EnumToString(m_swing_tf),
               " bars. Available:", bars_available,
               " Required:", m_lookback + m_strength * 2);
         return false;
        }
      Print(StringFormat(
               "CSwingEngine: Initialized | Symbol:%s | SwingTF:%s | Strength:%d | Lookback:%d",
               m_symbol, EnumToString(m_swing_tf), m_strength, m_lookback));
      return true;
     }

   //+------------------------------------------------------------------+
   //| Scans H4 bars and updates swing points and trend classification  |
   //| Gated on a NEW H4 BAR, not a new bar on the calling chart.       |
   //| Safe to call every tick from OnTick() or OnCalculate().          |
   //+------------------------------------------------------------------+
   bool              Update()
     {
      datetime htf_bar = iTime(m_symbol, m_swing_tf, 0);                    // Current H4 bar time
      if(htf_bar == 0)
         return false;                                                      // H4 data not ready
      if(htf_bar == m_last_htf_bar)
         return false;                                                      // Same H4 bar — skip
      m_last_htf_bar = htf_bar;                                             // Update HTF bar tracker
      //--- Copy H4 price data for the lookback window
      int    total = m_lookback + m_strength * 2;                           // Total H4 bars needed
      double high[], low[];
      datetime times[];
      ArraySetAsSeries(high,  true);                                        // Newest first
      ArraySetAsSeries(low,   true);                                        // Newest first
      ArraySetAsSeries(times, true);                                        // Newest first
      if(CopyHigh(m_symbol, m_swing_tf, 0, total, high)  < total)
         return false;                                                      // Copy H4 highs
      if(CopyLow(m_symbol,  m_swing_tf, 0, total, low)   < total)
         return false;                                                      // Copy H4 lows
      if(CopyTime(m_symbol, m_swing_tf, 0, total, times) < total)
         return false;                                                      // Copy H4 times
      //--- Scan for swing points in the confirmed zone
      ArrayResize(m_swings, 0);                                             // Clear and rebuild
      m_count = 0;
      for(int i = m_strength; i < total - m_strength; i++)                  // Scan confirmed zone
        {
         if(IsSwingHigh(high, i, total))                                    // Confirmed swing high
           {
            SSwingPoint sp;
            sp.is_high = true;
            sp.price = high[i];
            sp.time = times[i];
            sp.bar_index = i;
            sp.label = "";
            ArrayResize(m_swings, m_count + 1);
            m_swings[m_count] = sp;
            m_count++;
           }
         if(IsSwingLow(low, i, total))                                      // Confirmed swing low
           {
            SSwingPoint sp;
            sp.is_high = false;
            sp.price = low[i];
            sp.time = times[i];
            sp.bar_index = i;
            sp.label = "";
            ArrayResize(m_swings, m_count + 1);
            m_swings[m_count] = sp;
            m_count++;
           }
        }
      LabelSwings();                                                        // Sort, label, reverse
      ClassifyTrend();                                                      // Classify from labels
      return true;                                                          // New H4 bar processed
     }

   //+------------------------------------------------------------------+
   //| Returns the current classified market trend                      |
   //+------------------------------------------------------------------+
   ENUM_SWING_TREND  GetTrend()       { return m_trend; }

   //+------------------------------------------------------------------+
   //| Returns the timeframe swings are calculated on                   |
   //+------------------------------------------------------------------+
   ENUM_TIMEFRAMES   GetSwingTimeframe() { return m_swing_tf; }

   //+------------------------------------------------------------------+
   //| Returns the total number of confirmed swings currently stored    |
   //+------------------------------------------------------------------+
   int               GetSwingCount()  { return m_count; }

   //+------------------------------------------------------------------+
   //| Returns the swing point at the given index (0 = most recent)     |
   //+------------------------------------------------------------------+
   SSwingPoint       GetSwing(int index)
     {
      SSwingPoint empty = {false, 0, 0, 0, ""};                             // Empty result
      if(index < 0 || index >= m_count)
         return empty;                                                      // Bounds check
      return m_swings[index];                                               // Return swing
     }

   //+------------------------------------------------------------------+
   //| Returns the most recent confirmed swing high                     |
   //+------------------------------------------------------------------+
   SSwingPoint       GetLastSwingHigh()
     {
      SSwingPoint empty = {true, 0, 0, 0, ""};                              // Empty result
      for(int i = 0; i < m_count; i++)                                      // Scan from newest
         if(m_swings[i].is_high)
            return m_swings[i];                                             // Return first high
      return empty;                                                         // None found
     }

   //+------------------------------------------------------------------+
   //| Returns the most recent confirmed swing low                      |
   //+------------------------------------------------------------------+
   SSwingPoint       GetLastSwingLow()
     {
      SSwingPoint empty = {false, 0, 0, 0, ""};                             // Empty result
      for(int i = 0; i < m_count; i++)                                      // Scan from newest
         if(!m_swings[i].is_high)
            return m_swings[i];                                             // Return first low
      return empty;                                                         // None found
     }

   //+------------------------------------------------------------------+
   //| Returns a human-readable string for the current trend            |
   //+------------------------------------------------------------------+
   string            GetTrendString()
     {
      switch(m_trend)
        {
         case TREND_UP:
            return "UPTREND";
         case TREND_DOWN:
            return "DOWNTREND";
         default:
            return "RANGE";
        }
     }
  };

#endif // SWINGENGINE_MQH
//+------------------------------------------------------------------+
