//+------------------------------------------------------------------+
//|                                LevelTracker.mqh                  |
//|                                Copyright 2026, MetaQuotes        |
//|                                https://www.mql5.com              |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict
#include "MarketStructureTypes.mqh"

//+------------------------------------------------------------------+
//| Level Tracker – maintains protected highs/lows and trend model   |
//+------------------------------------------------------------------+
class CLevelTracker
  {
   private:
    SSwingPoint          m_swingHighs[3];                                                                  // rolling history of the last three swing highs
    SSwingPoint          m_swingLows[3];                                                                   // rolling history of the last three swing lows
    int                  m_highCount;                                                                      // number of swing highs currently stored (max 3)
    int                  m_lowCount;                                                                       // number of swing lows currently stored (max 3)
    int                  m_currentTrend;                                                                   // 1 = bullish, -1 = bearish, 0 = neutral/range
    SProtectedLevel      m_protectedHigh;                                                                  // the active protected high (if valid)
    SProtectedLevel      m_protectedLow;                                                                   // the active protected low (if valid)

    double               m_atrForTrend;                                                                    // ATR value used to compute the minimum slope threshold
    int                  m_trendConfirmation;                                                              // counter for hysteresis (consecutive identical readings)
    int                  m_previousTrend;                                                                  // raw trend from the previous evaluation

    void                UpdateTrend();                                                                     // recalculate trend based on regression slopes
    void                UpdateProtectedLevels();                                                           // select the appropriate protected high/low given the trend
    void                AddToHistory(SSwingPoint &history[], int &count, const SSwingPoint &swing);        // push a new swing into a rolling 3-element history
    double              LinearRegressionSlope(const SSwingPoint &points[], int count, int lookback) const; // compute slope of the last 'lookback' swing points

   public:
                     CLevelTracker();
    void                Init();                                                                            // reset all internal state
    void                SetATR(double atr) { m_atrForTrend = atr; }                                        // supply the current ATR for slope threshold
    void                ProcessSwingHigh(const SSwingPoint &swing);                                        // update with a new swing high
    void                ProcessSwingLow(const SSwingPoint &swing);                                         // update with a new swing low
    int                 GetTrend() const { return m_currentTrend; }                                        // current trend direction
    bool                GetProtectedHigh(SProtectedLevel &out) const;                                      // copy out the protected high if valid
   bool                GetProtectedLow(SProtectedLevel &out) const;                                       // copy out the protected low if valid
   void                InvalidateHigh();                                                                  // mark the protected high as broken
   void                InvalidateLow();                                                                   // mark the protected low as broken
  };

//+--------------------------------------------------------------------+
//| Initialize all members to default values, protected levels invalid |
//+--------------------------------------------------------------------+
CLevelTracker::CLevelTracker()
  {
   m_highCount = 0;
   m_lowCount = 0;
   m_currentTrend = 0;
   m_protectedHigh.isValid = false;
   m_protectedLow.isValid = false;
   m_atrForTrend = 0;
   m_trendConfirmation = 0;
   m_previousTrend = 0;
  }

//+------------------------------------------------------------------+
//| Reset the level tracker to its default state                     |
//+------------------------------------------------------------------+
void CLevelTracker::Init()
  {
   m_highCount = 0;
   m_lowCount = 0;
   m_currentTrend = 0;
   m_protectedHigh.isValid = false;
   m_protectedLow.isValid = false;
   m_atrForTrend = 0;
   m_trendConfirmation = 0;
   m_previousTrend = 0;
  }

//+------------------------------------------------------------------+
//| Add a swing point to a rolling history of the last three points  |
//+------------------------------------------------------------------+
void CLevelTracker::AddToHistory(SSwingPoint &history[], int &count, const SSwingPoint &swing)
  {
   if(count < 3)
      count++;                                                        // still filling the array
   else
     {
      //--- shift elements left to make room for the newest at the end
      for(int i=0; i<2; i++)
         history[i] = history[i+1];
     }
   history[count-1] = swing;                                          // place the new swing at the last position
  }

//+------------------------------------------------------------------+
//| Compute linear regression slope over the last N swing points     |
//| Returns the slope (price change per unit of x) of the best-fit   |
//| line through the last 'lookback' points. Used to detect trend.   |
//+------------------------------------------------------------------+
double CLevelTracker::LinearRegressionSlope(const SSwingPoint &points[], int count, int lookback) const
  {
   if(lookback < 2 || count < lookback)
      return 0.0;                                                     // not enough points

   double sumX=0, sumY=0, sumXY=0, sumX2=0;
   int startIdx = count - lookback;                                   // index of the first point in the window
   for(int i=0; i<lookback; i++)
     {
      double x = i;                                                   // use sequential integers for x-axis
      double y = points[startIdx + i].price;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
     }
   double n = (double)lookback;
   double denom = n * sumX2 - sumX * sumX;
   if(MathAbs(denom) < DBL_EPSILON)
      return 0.0;                                                     // avoid division by zero (vertical line)
   return (n * sumXY - sumX * sumY) / denom;
  }

//+------------------------------------------------------------------+
//| Update the trend direction using regression slopes and hysteresis|
//| A minimum slope threshold (based on ATR) filters out noise.      |
//| Hysteresis requires two consecutive identical readings.          |
//+------------------------------------------------------------------+
void CLevelTracker::UpdateTrend()
  {
   const int lookback = 5;                                            // number of recent swings to analyze
   double minSlope = m_atrForTrend * 0.1 / PeriodSeconds();           // convert ATR to per-bar slope
   if(minSlope <= 0)
      minSlope = DBL_EPSILON;

   //--- compute slopes for the high and low sequences
   double highSlope = (m_highCount >= lookback) ? LinearRegressionSlope(m_swingHighs, m_highCount, lookback) : 0.0;
   double lowSlope  = (m_lowCount  >= lookback) ? LinearRegressionSlope(m_swingLows,  m_lowCount,  lookback) : 0.0;

   int rawTrend = 0;
   if(m_highCount >= lookback && m_lowCount >= lookback)
     {
      //--- bullish: high slope positive and low slope not negative
      if(highSlope > minSlope && lowSlope > -minSlope)
         rawTrend = 1;
      else
      //--- bearish: high slope negative and low slope not positive
      if(highSlope < -minSlope && lowSlope < minSlope)
         rawTrend = -1;
     }

   //--- hysteresis: only confirm a new trend after two consecutive identical raw readings
   if(rawTrend == m_previousTrend)
     {
      m_trendConfirmation++;
      if(m_trendConfirmation >= 2)
         m_currentTrend = rawTrend;       // trend confirmed
     }
   else
     {
      m_trendConfirmation = 1;            // reset counter on change
      m_previousTrend = rawTrend;
     }

   //--- force neutral if insufficient data
   if(m_highCount < lookback || m_lowCount < lookback)
      m_currentTrend = 0;
  }

//+------------------------------------------------------------------+
//| Update the protected high and low levels based on current trend  |
//| In a bearish trend the protected high must be a lower high;      |
//| in a bullish trend the protected low must be a higher low.       |
//+------------------------------------------------------------------+
void CLevelTracker::UpdateProtectedLevels()
  {
// --- Protected High
   if(m_highCount > 0)
     {
      if(m_currentTrend == -1 && m_highCount >= 2)
        {
         //--- bearish trend: prefer the most recent lower high
         if(m_swingHighs[m_highCount-1].price < m_swingHighs[m_highCount-2].price)
           {
            m_protectedHigh.time = m_swingHighs[m_highCount-1].time;
            m_protectedHigh.price = m_swingHighs[m_highCount-1].price;
           }
         else
           {
            //--- current high is not lower – keep the previous (lower) high
            m_protectedHigh.time = m_swingHighs[m_highCount-2].time;
            m_protectedHigh.price = m_swingHighs[m_highCount-2].price;
           }
        }
      else
        {
         //--- bullish or neutral: use the most recent high
         m_protectedHigh.time = m_swingHighs[m_highCount-1].time;
         m_protectedHigh.price = m_swingHighs[m_highCount-1].price;
        }
      m_protectedHigh.isHigh = true;
      m_protectedHigh.isValid = true;
     }
   else
      m_protectedHigh.isValid = false;

// --- Protected Low
   if(m_lowCount > 0)
     {
      if(m_currentTrend == 1 && m_lowCount >= 2)
        {
         //--- bullish trend: prefer the most recent higher low
         if(m_swingLows[m_lowCount-1].price > m_swingLows[m_lowCount-2].price)
           {
            m_protectedLow.time = m_swingLows[m_lowCount-1].time;
            m_protectedLow.price = m_swingLows[m_lowCount-1].price;
           }
         else
           {
            //--- current low is not higher – keep the previous (higher) low
            m_protectedLow.time = m_swingLows[m_lowCount-2].time;
            m_protectedLow.price = m_swingLows[m_lowCount-2].price;
           }
        }
      else
        {
         //--- bearish or neutral: use the most recent low
         m_protectedLow.time = m_swingLows[m_lowCount-1].time;
         m_protectedLow.price = m_swingLows[m_lowCount-1].price;
        }
      m_protectedLow.isHigh = false;
      m_protectedLow.isValid = true;
     }
   else
      m_protectedLow.isValid = false;
  }

//+------------------------------------------------------------------+
//| Process a new swing high – update history, trend, and levels     |
//+------------------------------------------------------------------+
void CLevelTracker::ProcessSwingHigh(const SSwingPoint &swing)
  {
   AddToHistory(m_swingHighs, m_highCount, swing);                    // store in rolling history
   UpdateTrend();                                                     // re-evaluate trend with new data
   UpdateProtectedLevels();                                           // recalculate protected levels
  }

//+------------------------------------------------------------------+
//| Process a new swing low – update history, trend, and levels      |
//+------------------------------------------------------------------+
void CLevelTracker::ProcessSwingLow(const SSwingPoint &swing)
  {
   AddToHistory(m_swingLows, m_lowCount, swing);
   UpdateTrend();
   UpdateProtectedLevels();
  }

//+------------------------------------------------------------------+
//| Retrieve the current protected high, if valid                    |
//+------------------------------------------------------------------+
bool CLevelTracker::GetProtectedHigh(SProtectedLevel &out) const
  {
   if(!m_protectedHigh.isValid)
      return false;
   out = m_protectedHigh;
   return true;
  }

//+------------------------------------------------------------------+
//| Retrieve the current protected low, if valid                     |
//+------------------------------------------------------------------+
bool CLevelTracker::GetProtectedLow(SProtectedLevel &out) const
  {
   if(!m_protectedLow.isValid)
      return false;
   out = m_protectedLow;
   return true;
  }

//+------------------------------------------------------------------+
//| Invalidate the protected high level (called after a break)       |
//+------------------------------------------------------------------+
void CLevelTracker::InvalidateHigh()
  {
   m_protectedHigh.isValid = false;
  }

//+------------------------------------------------------------------+
//| Invalidate the protected low level (called after a break)        |
//+------------------------------------------------------------------+
void CLevelTracker::InvalidateLow()
  {
   m_protectedLow.isValid = false;
  }
//+------------------------------------------------------------------+