//+------------------------------------------------------------------+
//|                                 infinity_candlestick_pattern.mqh |
//|                        Copyright 2025, Clemence Benjamin         |
//|                  https://www.mql5.com/en/users/billionaire2024   |
//+------------------------------------------------------------------+
//|                                      From Novice to Expert       |
//|                                       Programming Candlesticks   |
//|                        https://www.mql5.com/en/articles/17525    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Metaquotes Ltd"
#property link      "https://www.mql5.com/"
#ifndef INFINITY_CANDLESTICK_PATTERNS_MQH
#define INFINITY_CANDLESTICK_PATTERNS_MQH

//+------------------------------------------------------------------+
//| Multi-Candlestick Pattern Functions                              |
//+------------------------------------------------------------------+

// Morning Star
bool IsMorningStar(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 3) return false; // Ensure enough candles are available
   return (close[index+2] < open[index+2] &&                          // Candle at index+2 is bearish
           MathAbs(close[index+1] - open[index+1]) < 0.3 * patternATR[index] && // Candle at index+1 has a small body
           close[index] > open[index] &&                              // Candle at index is bullish
           close[index] > (open[index+2] + close[index+2]) / 2);      // Closes above midpoint of candle at index+2
}

// Evening Star
bool IsEveningStar(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 3) return false;
   return (close[index+2] > open[index+2] &&                          // Candle at index+2 is bullish
           MathAbs(close[index+1] - open[index+1]) < 0.3 * patternATR[index] && // Candle at index+1 has a small body
           close[index] < open[index] &&                              // Candle at index is bearish
           close[index] < (open[index+2] + close[index+2]) / 2);      // Closes below midpoint of candle at index+2
}

// Three White Soldiers
bool IsThreeWhiteSoldiers(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 3) return false;
   return (close[index+2] > open[index+2] && (close[index+2] - open[index+2]) > patternATR[index] && (high[index+2] - close[index+2]) < 0.3 * patternATR[index] && // Candle 3
           close[index+1] > open[index+1] && (close[index+1] - open[index+1]) > patternATR[index] && (high[index+1] - close[index+1]) < 0.3 * patternATR[index] && // Candle 2
           close[index] > open[index] && (close[index] - open[index]) > patternATR[index] && (high[index] - close[index]) < 0.3 * patternATR[index] &&         // Candle 1
           open[index+1] > open[index+2] && open[index+1] < close[index+2] && close[index+1] > close[index+2] &&                           // Candle 2 opens in body
           open[index] > open[index+1] && open[index] < close[index+1] && close[index] > close[index+1]);                                  // Candle 1 opens in body
}

// Three Black Crows
bool IsThreeBlackCrows(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 3) return false;
   return (close[index+2] < open[index+2] && (open[index+2] - close[index+2]) > patternATR[index] && (open[index+2] - low[index+2]) < 0.3 * patternATR[index] && // Candle 3
           close[index+1] < open[index+1] && (open[index+1] - close[index+1]) > patternATR[index] && (open[index+1] - low[index+1]) < 0.3 * patternATR[index] && // Candle 2
           close[index] < open[index] && (open[index] - close[index]) > patternATR[index] && (open[index] - low[index]) < 0.3 * patternATR[index] &&         // Candle 1
           open[index+1] < open[index+2] && open[index+1] > close[index+2] && close[index+1] < close[index+2] &&                           // Candle 2 opens in body
           open[index] < open[index+1] && open[index] > close[index+1] && close[index] < close[index+1]);                                  // Candle 1 opens in body
}

// Bullish Harami
bool IsBullishHarami(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 2) return false;
   return (close[index+1] < open[index+1] && (open[index+1] - close[index+1]) > patternATR[index] && // Candle at index+1 is bearish with large body
           close[index] > open[index] && open[index] > close[index+1] && close[index] < open[index+1]); // Candle at index is bullish and within body
}

// Bearish Harami
bool IsBearishHarami(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 2) return false;
   return (close[index+1] > open[index+1] && (close[index+1] - open[index+1]) > patternATR[index] && // Candle at index+1 is bullish with large body
           close[index] < open[index] && open[index] < close[index+1] && close[index] > open[index+1]); // Candle at index is bearish and within body
}

// Bullish Engulfing
bool IsBullishEngulfing(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 2) return false;
   return (close[index+1] < open[index+1] &&            // Candle at index+1 is bearish
           close[index] > open[index] &&                // Candle at index is bullish
           open[index] < close[index+1] &&              // Opens below previous close
           close[index] > open[index+1]);               // Closes above previous open
}

// Bearish Engulfing
bool IsBearishEngulfing(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 2) return false;
   return (close[index+1] > open[index+1] &&            // Candle at index+1 is bullish
           close[index] < open[index] &&                // Candle at index is bearish
           open[index] > close[index+1] &&              // Opens above previous close
           close[index] < open[index+1]);               // Closes below previous open
}

// Three Inside Up
bool IsThreeInsideUp(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 3) return false;
   return (close[index+2] < open[index+2] && (open[index+2] - close[index+2]) > patternATR[index] && // Candle 3 is bearish with large body
           close[index+1] > open[index+1] && open[index+1] > close[index+2] && close[index+1] < open[index+2] && // Candle 2 is bullish and within body
           close[index] > open[index] && close[index] > high[index+1]); // Candle 1 is bullish and closes above candle 2's high
}

// Three Inside Down
bool IsThreeInsideDown(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 3) return false;
   return (close[index+2] > open[index+2] && (close[index+2] - open[index+2]) > patternATR[index] && // Candle 3 is bullish with large body
           close[index+1] < open[index+1] && open[index+1] < close[index+2] && close[index+1] > open[index+2] && // Candle 2 is bearish and within body
           close[index] < open[index] && close[index] < low[index+1]); // Candle 1 is bearish and closes below candle 2's low
}

// Tweezer Bottom
bool IsTweezerBottom(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 2) return false;
   return (close[index+1] < open[index+1] &&            // Candle at index+1 is bearish
           close[index] > open[index] &&                // Candle at index is bullish
           MathAbs(low[index+1] - low[index]) < 0.1 * patternATR[index]); // Lows are nearly equal
}

// Tweezer Top
bool IsTweezerTop(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 2) return false;
   return (close[index+1] > open[index+1] &&            // Candle at index+1 is bullish
           close[index] < open[index] &&                // Candle at index is bearish
           MathAbs(high[index+1] - high[index]) < 0.1 * patternATR[index]); // Highs are nearly equal
}

// Bullish Kicker
bool IsBullishKicker(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 2) return false;
   return (close[index+1] < open[index+1] &&            // Candle at index+1 is bearish
           close[index] > open[index] &&                // Candle at index is bullish
           open[index] > open[index+1]);                // Opens above previous open
}

// Bearish Kicker
bool IsBearishKicker(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 2) return false;
   return (close[index+1] > open[index+1] &&            // Candle at index+1 is bullish
           close[index] < open[index] &&                // Candle at index is bearish
           open[index] < open[index+1]);                // Opens below previous open
}

// Bullish Breakaway
bool IsBullishBreakaway(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 5) return false;
   return (close[index+4] < open[index+4] && (open[index+4] - close[index+4]) > patternATR[index] && // Candle 5 is bearish with large body
           close[index] > open[index] && (close[index] - open[index]) > patternATR[index] && // Candle 1 is bullish with large body
           close[index] > open[index+4]); // Closes above candle 5's open
}

// Bearish Breakaway
bool IsBearishBreakaway(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 5) return false;
   return (close[index+4] > open[index+4] && (close[index+4] - open[index+4]) > patternATR[index] && // Candle 5 is bullish with large body
           close[index] < open[index] && (open[index] - close[index]) > patternATR[index] && // Candle 1 is bearish with large body
           close[index] < open[index+4]); // Closes below candle 5's open
}

//+------------------------------------------------------------------+
//| Single-Candlestick Pattern Functions                             |
//+------------------------------------------------------------------+

// Hammer
bool IsHammer(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 1) return false;
   double body = MathAbs(close[index] - open[index]);
   return (body < 0.3 * patternATR[index] &&                           // Small body
           (MathMin(open[index], close[index]) - low[index]) >= 2 * body && // Long lower wick
           (high[index] - MathMax(open[index], close[index])) <= 0.5 * body); // Small or no upper wick
}

// Shooting Star
bool IsShootingStar(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 1) return false;
   double body = MathAbs(close[index] - open[index]);
   return (body < 0.3 * patternATR[index] &&                           // Small body
           (high[index] - MathMax(open[index], close[index])) >= 2 * body && // Long upper wick
           (MathMin(open[index], close[index]) - low[index]) <= 0.5 * body); // Small or no lower wick
}

// Standard Doji
bool IsStandardDoji(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 1) return false;
   return (MathAbs(close[index] - open[index]) < 0.1 * patternATR[index]); // Open and close are nearly equal
}

// Dragonfly Doji
bool IsDragonflyDoji(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 1) return false;
   return (MathAbs(close[index] - open[index]) < 0.1 * patternATR[index] && // Small body
           (MathMin(open[index], close[index]) - low[index]) > 0.5 * patternATR[index] && // Long lower wick
           (high[index] - MathMax(open[index], close[index])) < 0.1 * patternATR[index]); // Little to no upper wick
}

// Gravestone Doji
bool IsGravestoneDoji(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 1) return false;
   return (MathAbs(close[index] - open[index]) < 0.1 * patternATR[index] && // Small body
           (high[index] - MathMax(open[index], close[index])) > 0.5 * patternATR[index] && // Long upper wick
           (MathMin(open[index], close[index]) - low[index]) < 0.1 * patternATR[index]); // Little to no lower wick
}

// Bullish Marubozu
bool IsBullishMarubozu(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 1) return false;
   return (close[index] > open[index] &&                        // Bullish candle
           (high[index] - close[index]) < 0.1 * patternATR[index] &&   // Close is very close to high
           (open[index] - low[index]) < 0.1 * patternATR[index]);      // Open is very close to low
}

// Bearish Marubozu
bool IsBearishMarubozu(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 1) return false;
   return (close[index] < open[index] &&                        // Bearish candle
           (high[index] - open[index]) < 0.1 * patternATR[index] &&    // Open is very close to high
           (close[index] - low[index]) < 0.1 * patternATR[index]);     // Close is very close to low
}

// Spinning Top
bool IsSpinningTop(double &open[], double &high[], double &low[], double &close[], double &patternATR[], int index)
{
   if (index < 1) return false;
   return (MathAbs(close[index] - open[index]) < 0.3 * patternATR[index] && // Small body
           (high[index] - MathMax(open[index], close[index])) > 0.5 * patternATR[index] && // Long upper wick
           (MathMin(open[index], close[index]) - low[index]) > 0.5 * patternATR[index]); // Long lower wick
}

#endif
//+------------------------------------------------------------------+