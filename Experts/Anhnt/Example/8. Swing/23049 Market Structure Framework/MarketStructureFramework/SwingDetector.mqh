//+------------------------------------------------------------------+
//|                                SwingDetector.mqh                 |
//|                                Copyright 2026, MetaQuotes        |
//|                                https://www.mql5.com              |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict
#include "MarketStructureTypes.mqh"

//+------------------------------------------------------------------+
//| Swing detector – identifies local maxima and minima              |
//+------------------------------------------------------------------+
class CSwingDetector
  {
   private:
    int                  m_strength;                                                                          // number of left/right bars that must be lower/higher
    int                  m_maxHistory;                                                                        // maximum bars to scan for performance bounding
    SSwingPoint          m_swingHighs[];                                                                      // array of confirmed swing highs (oldest first)
    SSwingPoint          m_swingLows[];                                                                       // array of confirmed swing lows (oldest first)
    int                  m_highCount;                                                                         // current number of stored swing highs
    int                  m_lowCount;                                                                          // current number of stored swing lows

    bool                GetLastOpposite(const datetime checkTime, bool isHigh, SSwingPoint &out);             // find last opposite swing before a given time
    double              CalcBreakoutScore(const SSwingPoint &swing, const SSwingPoint &opposite, double atr); // ATR-based breakout distance score

   public:
                     CSwingDetector();
    void                Init(int strength, int maxHistory=1000);                                              // set detection strength and history bounds
    void                Clear();                                                                              // reset all stored swings

    bool                IsSwingHigh(int idx, const double &high[]) const;                                     // test if bar idx is a swing high
    bool                IsSwingLow(int idx, const double &low[]) const;                                       // test if bar idx is a swing low

    void                AddSwingHigh(datetime time, double price);                                            // register a new swing high
    void                AddSwingLow(datetime time, double price);                                             // register a new swing low

    int                 GetSwingHighCount() const { return m_highCount; }                                     // number of swing highs stored
    int                 GetSwingLowCount() const { return m_lowCount; }                                       // number of swing lows stored
    bool                GetSwingHigh(int index, SSwingPoint &out) const;                                      // retrieve a swing high by index (0 = oldest)
    bool                GetSwingLow(int index, SSwingPoint &out) const;                                       // retrieve a swing low by index (0 = oldest)
    int                 GetStrength() const { return m_strength; }                                            // current swing strength setting
    double              CalcSwingConfidence(const SSwingPoint &swing, double atr);                            // pure quality score for a swing (no directional bias)
  };

//+------------------------------------------------------------------+
//| Set default strength to 5 and max history to 1000                |
//+------------------------------------------------------------------+
CSwingDetector::CSwingDetector()
  {
   m_strength=5;
   m_maxHistory=1000;
   m_highCount=0;
   m_lowCount=0;
  }

//+------------------------------------------------------------------+
//| Initialize the swing detector with strength and history bounds   |
//| Strength is forced to be at least 2. maxHistory is forced to be  |
//| at least 2 * strength.                                           |
//+------------------------------------------------------------------+
void CSwingDetector::Init(int strength, int maxHistory=1000)
  {
   m_strength=MathMax(2,strength);                                 // minimum strength of 2
   m_maxHistory=MathMax(m_strength*2, maxHistory);                 // ensure enough room for left/right comparisons
   Clear();                                                        // start with empty arrays
  }

//+------------------------------------------------------------------+
//| Reset the swing detector, clearing all stored swing points       |
//+------------------------------------------------------------------+
void CSwingDetector::Clear()
  {
   ArrayFree(m_swingHighs);
   ArrayFree(m_swingLows);
   m_highCount=0;
   m_lowCount=0;
  }

//+------------------------------------------------------------------+
//| Check if a bar at a given index is a swing high                  |
//| The bar's high must be strictly higher than all bars within      |
//| the m_strength window to its left and right.                     |
//+------------------------------------------------------------------+
bool CSwingDetector::IsSwingHigh(int idx, const double &high[]) const
  {
   double cur = high[idx];
   for(int j=1; j<=m_strength; j++)
      if(high[idx-j] >= cur || high[idx+j] >= cur)                    // any neighbouring bar equals or exceeds current high
         return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Check if a bar at a given index is a swing low                   |
//| The bar's low must be strictly lower than all bars within        |
//| the m_strength window to its left and right.                     |
//+------------------------------------------------------------------+
bool CSwingDetector::IsSwingLow(int idx, const double &low[]) const
  {
   double cur = low[idx];
   for(int j=1; j<=m_strength; j++)
      if(low[idx-j] <= cur || low[idx+j] <= cur)                      // any neighbouring bar equals or falls below current low
         return false;
   return true;
  }

//+------------------------------------------------------------------+
//| AddSwingHigh – registers a new swing high point                  |
//| The swing is appended to the end of the internal array.          |
//+------------------------------------------------------------------+
void CSwingDetector::AddSwingHigh(datetime time, double price)
  {
   m_highCount++;
   ArrayResize(m_swingHighs, m_highCount);                            // expand array by one element
   m_swingHighs[m_highCount-1].time = time;
   m_swingHighs[m_highCount-1].price = price;
   m_swingHighs[m_highCount-1].isHigh = true;
   m_swingHighs[m_highCount-1].confidence = 0;                        // confidence will be calculated later
  }

//+------------------------------------------------------------------+
//| AddSwingLow – registers a new swing low point                    |
//+------------------------------------------------------------------+
void CSwingDetector::AddSwingLow(datetime time, double price)
  {
   m_lowCount++;
   ArrayResize(m_swingLows, m_lowCount);
   m_swingLows[m_lowCount-1].time = time;
   m_swingLows[m_lowCount-1].price = price;
   m_swingLows[m_lowCount-1].isHigh = false;
   m_swingLows[m_lowCount-1].confidence = 0;
  }

//+------------------------------------------------------------------+
//| GetSwingHigh – retrieves a swing high by index (0 = oldest)      |
//+------------------------------------------------------------------+
bool CSwingDetector::GetSwingHigh(int index, SSwingPoint &out) const
  {
   if(index<0 || index>=m_highCount)
      return false;
   out=m_swingHighs[index];
   return true;
  }

//+------------------------------------------------------------------+
//| GetSwingLow – retrieves a swing low by index (0 = oldest)        |
//+------------------------------------------------------------------+
bool CSwingDetector::GetSwingLow(int index, SSwingPoint &out) const
  {
   if(index<0 || index>=m_lowCount)
      return false;
   out=m_swingLows[index];
   return true;
  }

//+------------------------------------------------------------------+
//| GetLastOpposite – finds the most recent swing of opposite type   |
//| before the specified time. Used in confidence calculations.      |
//+------------------------------------------------------------------+
bool CSwingDetector::GetLastOpposite(const datetime checkTime, bool isHigh, SSwingPoint &out)
  {
   if(isHigh)
     {
      //--- search lows array from newest to oldest
      for(int i=m_lowCount-1; i>=0; i--)
         if(m_swingLows[i].time < checkTime)
           {
            out=m_swingLows[i];
            return true;
           }
     }
   else
     {
      //--- search highs array from newest to oldest
      for(int i=m_highCount-1; i>=0; i--)
         if(m_swingHighs[i].time < checkTime)
           {
            out=m_swingHighs[i];
            return true;
           }
     }
   return false;
  }

//+------------------------------------------------------------------+
//| CalcBreakoutScore – computes breakout distance score (ATR-based) |
//| Measures how far the swing price extended beyond the opposite    |
//| extreme, normalized by ATR. Capped at 30 in the confidence calc. |
//+------------------------------------------------------------------+
double CSwingDetector::CalcBreakoutScore(const SSwingPoint &swing, const SSwingPoint &opposite, double atr)
  {
   if(atr<=0)
      return 0;
   double breakout = 0;
   if(swing.isHigh)
      breakout = (swing.price - opposite.price) / atr;                // distance above last low (in ATR)
   else
      breakout = (opposite.price - swing.price) / atr;                // distance below last high (in ATR)
   return MathMin(100.0, breakout * 20.0);
  }

//+------------------------------------------------------------------+
//| CalcSwingConfidence – pure swing quality score (ATR-based)       |
//| Combines magnitude, breakout distance, and a neutral baseline.   |
//| Does NOT assign any directional bias (no isHigh → bullish map).  |
//| Returns a value 0–100.                                           |
//+------------------------------------------------------------------+
double CSwingDetector::CalcSwingConfidence(const SSwingPoint &swing, double atr)
  {
   if(atr<=0)
      return 50.0;                                                    // default confidence when ATR unavailable

   double magnitudeScore = 0, breakoutScore = 0;

   SSwingPoint opposite;
   if(GetLastOpposite(swing.time, swing.isHigh, opposite))
     {
      //--- magnitude: absolute distance between swing and last opposite, in ATR terms
      double magnitude = MathAbs(swing.price - opposite.price);
      magnitudeScore = MathMin(50.0, (magnitude / atr) * 15.0);
      //--- breakout: how far the swing pushed beyond the opposite extreme
      breakoutScore  = MathMin(30.0, CalcBreakoutScore(swing, opposite, atr));
     }
   else
      magnitudeScore = 25.0;                                          // no opposite reference; give a moderate base

   double agreementScore = 10.0;                                      // neutral baseline, no directional agreement
   double total = magnitudeScore + breakoutScore + agreementScore;
   return MathMin(100.0, MathMax(0.0, total));
  }
//+------------------------------------------------------------------+