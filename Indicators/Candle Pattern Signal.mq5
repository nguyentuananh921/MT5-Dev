//+------------------------------------------------------------------+
//|                   Candle Pattern Signal		  	                  |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2

//--- plot BullLow
#property indicator_label1  "Bull Low Line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrNONE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot BearHigh
#property indicator_label2  "Bear High Line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrNONE
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- buffers
double bull_buffer[];
double bear_buffer[];
double state_buffer[];

enum ENUM_PATTERN_START{

   pattern_current_bar, // Immediate Formation
   pattern_confirmed // Formation Confirmed 
};


#define OBJ_PREFIX "CandlePatternLine_"

//--- inputs
input int ma_period = 12; // Period for average candle body
input double MinBodyRatio = 0.5; // Body multiplier relative to average
input ENUM_PATTERN_START pattern_start = pattern_confirmed; // Pattern scanning mode
input bool using_states = false; // Use state machine


// Boolean inputs for enabling/disabling candlestick patterns
input bool Enable_ThreeBlackCrows = true;     // Enable Three Black Crows
input bool Enable_ThreeWhiteSoldiers = true;  // Enable Three White Soldiers
input bool Enable_DarkCloudCover = true;      // Enable Dark Cloud Cover
input bool Enable_PiercingLine = true;        // Enable Piercing Line
input bool Enable_MorningDoji = true;         // Enable Morning Doji
input bool Enable_EveningDoji = true;         // Enable Evening Doji
input bool Enable_BearishEngulfing = true;    // Enable Bearish Engulfing
input bool Enable_BullishEngulfing = true;    // Enable Bullish Engulfing
input bool Enable_EveningStar = true;         // Enable Evening Star
input bool Enable_MorningStar = true;         // Enable Morning Star
input bool Enable_Hammer = true;              // Enable Hammer
input bool Enable_HangingMan = true;          // Enable Hanging Man
input bool Enable_BearishHarami = false;       // Enable Bearish Harami
input bool Enable_BullishHarami = false;       // Enable Bullish Harami
input bool Enable_BearishMeetingLines = false; // Enable Bearish Meeting Lines
input bool Enable_BullishMeetingLines = false; // Enable Bullish Meeting Lines

//--- enumerators
enum ENUM_CANDLE_PATTERNS
  {
   CANDLE_PATTERN_THREE_BLACK_CROWS     = 1,
   CANDLE_PATTERN_THREE_WHITE_SOLDIERS  = 2,
   CANDLE_PATTERN_DARK_CLOUD_COVER      = 3,
   CANDLE_PATTERN_PIERCING_LINE         = 4,
   CANDLE_PATTERN_MORNING_DOJI          = 5,
   CANDLE_PATTERN_EVENING_DOJI          = 6,
   CANDLE_PATTERN_BEARISH_ENGULFING     = 7,
   CANDLE_PATTERN_BULLISH_ENGULFING     = 8,
   CANDLE_PATTERN_EVENING_STAR          = 9,
   CANDLE_PATTERN_MORNING_STAR          = 10,
   CANDLE_PATTERN_HAMMER                = 11,
   CANDLE_PATTERN_HANGING_MAN           = 12,
   CANDLE_PATTERN_BEARISH_HARAMI        = 13,
   CANDLE_PATTERN_BULLISH_HARAMI        = 14,
   CANDLE_PATTERN_BEARISH_MEETING_LINES = 15,
   CANDLE_PATTERN_BULLISH_MEETING_LINES = 16
  };




//+------------------------------------------------------------------+
//| Global variables for tracking active lines                       |
//+------------------------------------------------------------------+
bool isBullishLineActive = false;
bool isBearishLineActive = false;
string bullishLineName = "";
string bearishLineName = "";
datetime bullishLineStartTime = 0;
datetime bearishLineStartTime = 0;
double bullishLinePrice = 0;
double bearishLinePrice = 0;



//+------------------------------------------------------------------+
//| CCandlePattern class                                             |
//+------------------------------------------------------------------+
class CCandlePattern
{
protected:
   int m_ma_period;

public:

   CCandlePattern() : m_ma_period(ma_period) {}
   void MAPeriod(int period) { m_ma_period = period; }
   
   virtual bool ValidationSettings()
   {
      if(m_ma_period <= 0)
      {
         Print(__FUNCTION__ + ": period MA must be greater than 0");
         return(false);
      }
      return(true);
   }
   bool CheckPatternAllBullish(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternAllBearish(const double &open[], const double &high[], const double &low[], const double &close[], int shift);

protected:

   double AvgBody(int ind, const double &open[], const double &close[], int shift)
   {
      double candle_body = 0;
      int rates = iBars(_Symbol, _Period);
      for(int i = shift + ind; i < shift + ind + m_ma_period && i<rates; i++)
         candle_body += MathAbs(open[i] - close[i]);
      return(candle_body / m_ma_period);
   }
   double MA(int ind, const double &close[], int shift) const
   {
      double sum = 0;
      int rates = iBars(_Symbol, _Period);
      for(int i = ind; i < ind + m_ma_period && i<rates; i++)
         sum += close[i];
      return(sum / m_ma_period);
   }
   double CloseAvg(int ind, const double &close[], int shift) const { return(MA(ind, close, shift)); }
   double MidPoint(int ind, const double &high[], const double &low[], int shift) const { return(0.5 * (high[shift+ind] + low[shift+ind])); }
   double MidOpenClose(int ind, const double &open[], const double &close[], int shift) const { return(0.5 * (open[shift+ind] + close[shift+ind])); } 
   
   bool CheckPatternThreeBlackCrows(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternThreeWhiteSoldiers(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternDarkCloudCover(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternPiercingLine(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternMorningDoji(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternEveningDoji(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternBearishEngulfing(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternBullishEngulfing(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternEveningStar(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternMorningStar(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternHammer(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternHangingMan(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternBearishHarami(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternBullishHarami(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternBearishMeetingLines(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
   bool CheckPatternBullishMeetingLines(const double &open[], const double &high[], const double &low[], const double &close[], int shift);
};

//+------------------------------------------------------------------+
//| Candlestick pattern checks                                       |
//+------------------------------------------------------------------+
bool CCandlePattern::CheckPatternThreeBlackCrows(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;
   int idx3 = shift + 3 - offset;

   if((open[idx3] > close[idx3]) &&                    // First candle bearish
      (open[idx2] > close[idx2]) &&                   // Second candle bearish
      (open[idx1] > close[idx1]) &&                   // Third candle bearish
      (close[idx2] < close[idx3]) &&                  // Second close lower than first
      (close[idx1] < close[idx2]))                    // Third close lower than second
   {
      if(MinBodyRatio > 0 &&
         ((open[idx3] - close[idx3]) < AvgBody(4, open, close, shift) * MinBodyRatio ||
          (open[idx2] - close[idx2]) < AvgBody(4, open, close, shift) * MinBodyRatio  ||
          (open[idx1] - close[idx1]) < AvgBody(4, open, close, shift) * MinBodyRatio ))
         return false;


      return true;
   }
   return false;
}

bool CCandlePattern::CheckPatternThreeWhiteSoldiers(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;
   int idx3 = shift + 3 - offset;

   // Standard Three White Soldiers conditions
   if((close[idx3] > open[idx3]) &&                    // First candle bullish
      (close[idx2] > open[idx2]) &&                   // Second candle bullish
      (close[idx1] > open[idx1]) &&                   // Third candle bullish
      (close[idx2] > close[idx3]) &&                  // Second close higher than first
      (close[idx1] > close[idx2]))                    // Third close higher than second
   {
      if(MinBodyRatio > 0 &&
         ((close[idx3] - open[idx3]) < AvgBody(4, open, close, shift) * MinBodyRatio  ||
          (close[idx2] - open[idx2]) < AvgBody(4, open, close, shift) * MinBodyRatio  ||
          (close[idx1] - open[idx1]) < AvgBody(4, open, close, shift) * MinBodyRatio ))
         return false;

      return true;
   }
   return false;
}

bool CCandlePattern::CheckPatternDarkCloudCover(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;

   if((close[idx2] > open[idx2]) &&                    // First candle bullish
      (open[idx1] > close[idx1]) &&                   // Second candle bearish
      (open[idx1] > high[idx2]) &&                    // Second candle opens above first candle's high
      (close[idx1] < (open[idx2] + close[idx2]) / 2) && // Second candle closes below first candle's midpoint
      (close[idx1] > open[idx2]))                    // Second candle closes above first candle's open
   {
      if(MinBodyRatio > 0 &&
         ((close[idx2] - open[idx2]) < AvgBody(3, open, close, shift) * MinBodyRatio ||
          (open[idx1] - close[idx1]) < AvgBody(3, open, close, shift) * MinBodyRatio))
         return false;

      return true;
   }
   return false;
}

bool CCandlePattern::CheckPatternPiercingLine(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;

   if((open[idx2] > close[idx2]) &&                    // First candle bearish
      (close[idx1] > open[idx1]) &&                   // Second candle bullish
      (open[idx1] < low[idx2]) &&                     // Second candle opens below first candle's low
      (close[idx1] > (open[idx2] + close[idx2]) / 2) && // Second candle closes above first candle's midpoint
      (close[idx1] < open[idx2]))                    // Second candle closes below first candle's open
   {
      if((close[idx1] - open[idx1]) < AvgBody(3, open, close, shift) * MinBodyRatio)
         return false;

      return true;
   }
   return false;
}

bool CCandlePattern::CheckPatternMorningDoji(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;
   int idx3 = shift + 3 - offset;

   if((open[idx3] > close[idx3]) &&                    // First candle bearish
      (MathAbs(open[idx2] - close[idx2]) < AvgBody(4, open, close, shift) * 0.1) && // Second candle Doji
      (close[idx1] > open[idx1]) &&                   // Third candle bullish
      (open[idx2] < close[idx3]) &&                   // Second candle gaps down
      (open[idx1] > close[idx2]) &&                   // Third candle gaps up
      (close[idx1] > (open[idx3] + close[idx3]) / 2)) // Third candle closes above first candle's midpoint
   {
      if(MinBodyRatio > 0 &&
         ((open[idx3] - close[idx3]) < AvgBody(4, open, close, shift) * MinBodyRatio ||
          (close[idx1] - open[idx1]) < AvgBody(4, open, close, shift) * MinBodyRatio))
         return false;

      return true;
   }
   return false;
}

bool CCandlePattern::CheckPatternEveningDoji(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;
   int idx3 = shift + 3 - offset;

   if((close[idx3] > open[idx3]) &&                    // First candle bullish
      (MathAbs(open[idx2] - close[idx2]) < AvgBody(4, open, close, shift) * 0.1) && // Second candle Doji
      (open[idx1] > close[idx1]) &&                   // Third candle bearish
      (open[idx2] > close[idx3]) &&                   // Second candle gaps up
      (open[idx1] < close[idx2]) &&                   // Third candle gaps down
      (close[idx1] < (open[idx3] + close[idx3]) / 2)) // Third candle closes below first candle's midpoint
   {
      if(MinBodyRatio > 0 &&
         ((close[idx3] - open[idx3]) < AvgBody(4, open, close, shift) * MinBodyRatio ||
          (open[idx1] - close[idx1]) < AvgBody(4, open, close, shift) * MinBodyRatio))
         return false;

      return true;
   }
   return false;
}

bool CCandlePattern::CheckPatternBearishEngulfing(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;

   if((open[idx2] < close[idx2]) &&                    // First candle bullish
      (open[idx1] > close[idx1]) &&                   // Second candle bearish
      (open[idx1] >= close[idx2]) &&                  // Second candle opens at or above first candle's close
      (close[idx1] <= open[idx2]))                    // Second candle closes at or below first candle's open
   {
      if((open[idx1] - close[idx1]) < AvgBody(3, open, close, shift) * 2.0)
         return false;

      return true;
   }
   return false;
}

bool CCandlePattern::CheckPatternBullishEngulfing(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;

   if((open[idx2] > close[idx2]) &&                    // First candle bearish
      (close[idx1] > open[idx1]) &&                   // Second candle bullish
      (open[idx1] <= close[idx2]) &&                  // Second candle opens at or below first candle's close
      (close[idx1] >= open[idx2]))                    // Second candle closes at or above first candle's open
   {
      if((close[idx1] - open[idx1]) < AvgBody(3, open, close, shift) * 2.0)
         return false;

      return true;
   }
   return false;
}

bool CCandlePattern::CheckPatternEveningStar(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;
   int idx3 = shift + 3 - offset;

   if((close[idx3] - open[idx3] > AvgBody(3, open, close, shift)) && // First candle is bullish with a body larger than the average body size of prior candles
      (MathAbs(close[idx2] - open[idx2]) < AvgBody(3, open, close, shift) * MinBodyRatio) && // Second candle has a small body, indicating indecision
      (close[idx2] > close[idx3]) && // Second candle's close is above the first candle's close, suggesting continued bullish momentum or gap up
      (open[idx2] > open[idx3]) &&   // Second candle's open is above the first candle's open, reinforcing upward movement
      (close[idx1] < MidOpenClose(3, open, close, shift))) // Third candle closes below the midpoint of the first candle's body, confirming bearish reversal
      return true;

   return false;
}

bool CCandlePattern::CheckPatternMorningStar(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;
   int idx3 = shift + 3 - offset;

   if((open[idx3] - close[idx3] > AvgBody(3, open, close, shift)) && // First candle is bearish with a body larger than the average body size
      (MathAbs(close[idx2] - open[idx2]) < AvgBody(3, open, close, shift) * MinBodyRatio) && // Second candle has a small body, indicating indecision
      (close[idx2] < close[idx3]) && // Second candle's close is below the first candle's close, suggesting a potential gap down
      (open[idx2] < open[idx3]) &&   // Second candle's open is below the first candle's open, reinforcing downward movement
      (close[idx1] > MidOpenClose(3, open, close, shift))) // Third candle closes above the midpoint of the first candle's body, confirming bullish reversal
      return true;

   return false;
}

bool CCandlePattern::CheckPatternHammer(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;

   double body = MathAbs(open[idx1] - close[idx1]);
   double lowerShadow = MathMin(open[idx1], close[idx1]) - low[idx1];
   double upperShadow = high[idx1] - MathMax(open[idx1], close[idx1]);

   if((body < AvgBody(3, open, close, shift) * MinBodyRatio) &&         // Small body
      (lowerShadow > body * 2.0) &&                            // Long lower shadow
      (upperShadow < body) &&                                 // Small or no upper shadow
      (high[idx1] < close[idx2]))                       // Hammer in downtrend context
   {
      return true;
   }
   return false;
}

bool CCandlePattern::CheckPatternHangingMan(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;

   double body = MathAbs(open[idx1] - close[idx1]);
   double lowerShadow = MathMin(open[idx1], close[idx1]) - low[idx1];
   double upperShadow = high[idx1] - MathMax(open[idx1], close[idx1]);

   if((body < AvgBody(3, open, close, shift) * MinBodyRatio) &&         // Small body
      (lowerShadow > body * 3.0) &&                            // Long lower shadow
      (upperShadow < body) &&                                 // Small or no upper shadow
      (high[idx1] > close[idx2]))                       // Hanging Man in uptrend context
   {
      return true;
   }
   return false;
}

bool CCandlePattern::CheckPatternBearishHarami(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;

   if((close[idx2] > open[idx2]) &&                    // First candle bullish
      (open[idx1] > close[idx1]) &&                   // Second candle bearish
      (close[idx1] > open[idx2]) &&                   // Second candle's close within first candle's body
      (open[idx1] < close[idx2]))                     // Second candle's open within first candle's body
   {
      // Ensure significant first candle body and small second candle body
      double firstBody = close[idx2] - open[idx2];
      double secondBody = MathAbs(open[idx1] - close[idx1]);
      if(firstBody < AvgBody(3, open, close, shift) * 0.5)
         return false;
      if(secondBody > firstBody * 0.5)
         return false;

      return true;
   }
   return false;
}

bool CCandlePattern::CheckPatternBullishHarami(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;

   if((open[idx2] > close[idx2]) &&                    // First candle bearish
      (close[idx1] > open[idx1]) &&                   // Second candle bullish
      (close[idx1] < open[idx2]) &&                   // Second candle's close within first candle's body
      (open[idx1] > close[idx2]))                     // Second candle's open within first candle's body
   {
      // Ensure significant first candle body and small second candle body
      double firstBody = open[idx2] - close[idx2];
      double secondBody = close[idx1] - open[idx1];
      if(firstBody < AvgBody(3, open, close, shift) * 0.5)
         return false;
      if(secondBody > firstBody * 0.5)
         return false;

      return true;
   }
   return false;
}

double CloseEqualityRatio = 0.1; // Max difference in closes relative to AvgBody

bool CCandlePattern::CheckPatternBearishMeetingLines(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;

   if((close[idx2] > open[idx2]) &&                    // First candle bullish
      (open[idx1] > close[idx1]) &&                   // Second candle bearish
      (open[idx1] > close[idx2]) &&                   // Second candle gaps up
      (MathAbs(close[idx1] - close[idx2]) < CloseEqualityRatio * AvgBody(3, open, close, shift))) // Closes nearly equal
   {
      if(MinBodyRatio > 0 &&
         ((close[idx2] - open[idx2]) < AvgBody(3, open, close, shift) * 0.5 ||
          (open[idx1] - close[idx1]) < AvgBody(3, open, close, shift) * 0.5))
         return false;

      if(!(open[shift] > close[shift] && close[shift] < low[idx1]))
         return false;

      return true;
   }
   return false;
}

bool CCandlePattern::CheckPatternBullishMeetingLines(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   int offset = (pattern_start == pattern_confirmed) ? 0 : 1;

   int idx1 = shift + 1 - offset;
   int idx2 = shift + 2 - offset;

   if((open[idx2] > close[idx2]) &&                    // First candle bearish
      (close[idx1] > open[idx1]) &&                   // Second candle bullish
      (open[idx1] < close[idx2]) &&                   // Second candle gaps down
      (MathAbs(close[idx1] - close[idx2]) < CloseEqualityRatio * AvgBody(3, open, close, shift))) // Closes nearly equal
   {
      if(MinBodyRatio > 0 &&
         ((open[idx2] - close[idx2]) < AvgBody(3, open, close, shift) * 0.5 ||
          (close[idx1] - open[idx1]) < AvgBody(3, open, close, shift) * 0.5))
         return false;

      if(!(close[shift] > open[shift] && close[shift] > high[idx1]))
         return false;

      return true;
   }
   return false;
}

bool CCandlePattern::CheckPatternAllBullish(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   return((Enable_ThreeWhiteSoldiers ? CheckPatternThreeWhiteSoldiers(open, high, low, close, shift) : false) ||
          (Enable_PiercingLine ? CheckPatternPiercingLine(open, high, low, close, shift) : false) ||
          (Enable_MorningDoji ? CheckPatternMorningDoji(open, high, low, close, shift) : false) || 
          (Enable_BullishEngulfing ? CheckPatternBullishEngulfing(open, high, low, close, shift) : false) ||
          (Enable_MorningStar ? CheckPatternMorningStar(open, high, low, close, shift) : false) ||
          (Enable_Hammer ? CheckPatternHammer(open, high, low, close, shift) : false) ||
          (Enable_BullishHarami ? CheckPatternBullishHarami(open, high, low, close, shift) : false) ||
          (Enable_BullishMeetingLines ? CheckPatternBullishMeetingLines(open, high, low, close, shift) : false));
          
   return false;
}


bool CCandlePattern::CheckPatternAllBearish(const double &open[], const double &high[], const double &low[], const double &close[], int shift)
{
   return((Enable_ThreeBlackCrows ? CheckPatternThreeBlackCrows(open, high, low, close, shift) : false)  ||
          (Enable_DarkCloudCover ? CheckPatternDarkCloudCover(open, high, low, close, shift) : false) ||
          (Enable_EveningDoji ? CheckPatternEveningDoji(open, high, low, close, shift) : false) ||
          (Enable_BearishEngulfing ? CheckPatternBearishEngulfing(open, high, low, close, shift) : false) ||
          (Enable_EveningStar ? CheckPatternEveningStar(open, high, low, close, shift) : false) ||
          (Enable_HangingMan ? CheckPatternHangingMan(open, high, low, close, shift) : false) ||
          (Enable_BearishHarami ? CheckPatternBearishHarami(open, high, low, close, shift) : false) ||
          (Enable_BearishMeetingLines ? CheckPatternBearishMeetingLines(open, high, low, close, shift) : false));
          
   return false;
}

CCandlePattern candle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   candle.MAPeriod(ma_period);
   if(!candle.ValidationSettings())
      return(INIT_PARAMETERS_INCORRECT);

   SetIndexBuffer(0, bull_buffer, INDICATOR_DATA);
   SetIndexBuffer(1, bear_buffer, INDICATOR_DATA);
   SetIndexBuffer(2, state_buffer, INDICATOR_CALCULATIONS);

   ArraySetAsSeries(bull_buffer, true);
   ArraySetAsSeries(bear_buffer, true);
   ArraySetAsSeries(state_buffer, true);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   ObjectsDeleteAll(0, OBJ_PREFIX);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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

   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(time, true);

   int limit = rates_total - prev_calculated;
   if(limit < ma_period + 3) limit = ma_period + 3;
   if(limit > rates_total - 1) limit = rates_total - 1;

   static int state = 0;
   static int drawingState = 0;  
    
   for(int i = limit; i >= 0 && !IsStopped(); i--)
   {
      bool is_bull = false;
      bool is_bear = false;

      bull_buffer[i] = EMPTY_VALUE;
      bear_buffer[i] = EMPTY_VALUE;
     
      UpdateLines(time, i, rates_total); 
      
      if(i < rates_total - 3)
      {
         is_bull = candle.CheckPatternAllBullish(open, high, low, close, i);
         is_bear = candle.CheckPatternAllBearish(open, high, low, close, i);
      }

      if(is_bull)
         state = 1;
      else if(is_bear)
         state = -1;

      state_buffer[i] = state;

      // Draw bullish line on state change to bullish pattern
      if(is_bull)
      {
         bull_buffer[i] = low[i];
         if(drawingState != 1)
         {
            DrawBullHorizontalLine("bull_pattern_", i, time, low[i], rates_total);
            if(using_states) drawingState = 1;
         }
      }
      // Draw bearish line on state change to bearish pattern
      if(is_bear)
      {
         bear_buffer[i] = high[i];
         if(drawingState != -1)
         {
            DrawBearHorizontalLine("bear_pattern_", i, time, high[i], rates_total);
            if(using_states) drawingState = -1;
         }
      }
      else
      {
        //  Continue buffer plotting for sustained states
         if(state == 1){
            bull_buffer[i] = low[i];
            }
         else if(state == -1){
            bear_buffer[i] = high[i];
            }
         if(state == 0)
            drawingState = 0;
      }
   }

   return(rates_total);
}


//+------------------------------------------------------------------+
//| Draw a horizontal green line that grows until 8 bars pass        |
//+------------------------------------------------------------------+
void DrawBullHorizontalLine(string name, int startBar, const datetime &time[], double price, const int rates_total)
{
   // Ensure valid startBar
   if(startBar < 0 || startBar >= rates_total)
      return;

   // Get time of start bar
   datetime time1 = (pattern_start == pattern_confirmed) ? time[startBar + 2] : time[startBar + 1];
   datetime time2 = (pattern_start == pattern_confirmed) ? time[startBar + 2] : time[startBar + 1]; // Start with same bar, end of line will be updated


   string obj_name = OBJ_PREFIX + name + IntegerToString(startBar);

   // Delete existing object if it exists
   if(ObjectFind(0, obj_name) >= 0)
      ObjectDelete(0, obj_name);

   // Create trend line
   if(!ObjectCreate(0, obj_name, OBJ_TREND, 0, time1, price, time2, price))
   {
      Print("Failed to create bullish line: ", obj_name, ", Error: ", GetLastError());
      return;
   }

   // Style settings
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clrGreen);
   ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, obj_name, OBJPROP_RAY_RIGHT, false); // Controlled by ObjectSet
   ObjectSetInteger(0, obj_name, OBJPROP_BACK, false);      // Show on top

   isBullishLineActive = true;
   bullishLineName = obj_name;
   bullishLineStartTime = time1;
   bullishLinePrice = price;
}

//+------------------------------------------------------------------+
//| Draw a horizontal red line that grows until 8 bars pass          |
//+------------------------------------------------------------------+
void DrawBearHorizontalLine(string name, int startBar, const datetime &time[], double price, const int rates_total)
{
   // Ensure valid startBar
   if(startBar < 0 || startBar >= rates_total)
      return;

   // Get time of start bar
   datetime time1 = (pattern_start == pattern_confirmed) ? time[startBar + 2] : time[startBar + 1];
   datetime time2 = (pattern_start == pattern_confirmed) ? time[startBar + 2] : time[startBar + 1]; // Start with same bar, end of line will be updated


   string obj_name = OBJ_PREFIX + name + IntegerToString(startBar);

   // Delete existing object if it exists
   if(ObjectFind(0, obj_name) >= 0)
      ObjectDelete(0, obj_name);

   // Create trend line
   if(!ObjectCreate(0, obj_name, OBJ_TREND, 0, time1, price, time2, price))
   {
      Print("Failed to create bearish line: ", obj_name, ", Error: ", GetLastError());
      return;
   }

   // Style settings
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, obj_name, OBJPROP_RAY_RIGHT, false); // Controlled by ObjectSet
   ObjectSetInteger(0, obj_name, OBJPROP_BACK, false);      // Show on top

   isBearishLineActive = true;
   bearishLineName = obj_name;
   bearishLineStartTime = time1;
   bearishLinePrice = price;
}

//+------------------------------------------------------------------+
//| Update lines to grow until more bars pass, then fix in position  |
//+------------------------------------------------------------------+
void UpdateLines(const datetime &time[], int current_index, const int rates_total)
{
   // Update bullish line if active
   if(isBullishLineActive)
   {
      datetime current_bar_open_time = time[current_index];      
      if(current_bar_open_time < bullishLineStartTime + 5 * PeriodSeconds())
      {
         ObjectSetInteger(0, bullishLineName, OBJPROP_TIME, time[current_index]);
         ObjectSetDouble(0, bullishLineName, OBJPROP_PRICE, bullishLinePrice);
         ObjectSetInteger(0, bullishLineName, OBJPROP_RAY_RIGHT, false); 
         ObjectSetInteger(0, bullishLineName, OBJPROP_RAY_LEFT, false); 
      }
      else
      {
         datetime end_time = bullishLineStartTime + 5 * PeriodSeconds();
         int endBar = iBarShift(NULL, 0, end_time, true);
         if(endBar >= 0 && endBar < rates_total)
         {
            ObjectSetInteger(0, bullishLineName, OBJPROP_TIME, time[endBar]);
            ObjectSetDouble(0, bullishLineName, OBJPROP_PRICE, bullishLinePrice);
            ObjectSetInteger(0, bullishLineName, OBJPROP_RAY_RIGHT, false); 
            ObjectSetInteger(0, bullishLineName, OBJPROP_RAY_LEFT, false); 
            isBullishLineActive = false; // Stop updates
            bullishLineName = "";
         }
      }
   }

   // Update bearish line if active
   if(isBearishLineActive)
   {
      datetime current_bar_open_time = time[current_index];
      if(current_bar_open_time < bearishLineStartTime + 5 * PeriodSeconds())
      {
         ObjectSetInteger(0, bearishLineName, OBJPROP_TIME, time[current_index]);
         ObjectSetDouble(0, bearishLineName, OBJPROP_PRICE, bearishLinePrice);
         ObjectSetInteger(0, bearishLineName, OBJPROP_RAY_RIGHT, false); 
         ObjectSetInteger(0, bearishLineName, OBJPROP_RAY_LEFT, false); 
      }
      else
      {
         datetime end_time = bearishLineStartTime + 5 * PeriodSeconds();
         int endBar = iBarShift(NULL, 0, end_time, true);
         if(endBar >= 0 && endBar < rates_total)
         {
            ObjectSetInteger(0, bearishLineName, OBJPROP_TIME, time[endBar]);
            ObjectSetDouble(0, bearishLineName, OBJPROP_PRICE, bearishLinePrice);
            ObjectSetInteger(0, bearishLineName, OBJPROP_RAY_RIGHT, false); 
            ObjectSetInteger(0, bearishLineName, OBJPROP_RAY_LEFT, false); 
            isBearishLineActive = false; // Stop updates
            bearishLineName = "";
         }
      }
   }
}