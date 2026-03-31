//+------------------------------------------------------------------+
//|                                                  SignalFibonacci |
//|                                                   Copyright 2025 |
//|                                                Clemence Benjamin |
//+------------------------------------------------------------------+
#ifndef SIGNAL_FIBONACCI_H
#define SIGNAL_FIBONACCI_H

#include <Expert\ExpertSignal.mqh>

// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of Fibonacci Retracement Levels                   |
//| Type=SignalAdvanced                                              |
//| Name=Fibonacci Retracement                                      |
//| ShortName=Fib                                                   |
//| Class=CSignalFibonacci                                          |
//| Page=signal_fibonacci                                           |
//+------------------------------------------------------------------+
// wizard description end

//+------------------------------------------------------------------+
//| CSignalFibonacci class                                           |
//| Purpose: Complete Fibonacci-based trading signal module         |
//+------------------------------------------------------------------+
class CSignalFibonacci : public CExpertSignal
{
protected:
    // Configuration parameters
    int               m_depth;              // Lookback period for swing detection
    double            m_min_retracement;    // Minimum retracement percentage
    double            m_max_retracement;    // Maximum retracement percentage  
    double            m_weight_factor;      // Weight multiplier for confidence
    bool              m_use_as_filter;      // Use as filter instead of primary
    double            m_filter_weight;      // Weight when used as filter
    bool              m_combine_with_trend; // Only trade with trend
    double            m_tolerance;          // Price tolerance for levels
    
    // Pattern weights (0-100)
    int               m_pattern_0;          // Model 0 "price at strong Fib level (0.382/0.618)"
    int               m_pattern_1;          // Model 1 "price at medium Fib level (0.500)"
    int               m_pattern_2;          // Model 2 "price at weak Fib level (0.236/0.786)"
    int               m_pattern_3;          // Model 3 "Fib level with price action confirmation"
    
    // Internal state variables
    double            m_high_price;
    double            m_low_price;
    datetime          m_high_time;
    datetime          m_low_time;
    bool              m_uptrend;
    double            m_current_strength;
    ENUM_TIMEFRAMES   m_actual_period;      // Store the actual timeframe to use

public:
    // Constructor and destructor
                     CSignalFibonacci(void)
                     : m_depth(50),
                       m_min_retracement(0.382),
                       m_max_retracement(0.618),
                       m_weight_factor(1.0),
                       m_use_as_filter(false),
                       m_filter_weight(30.0),
                       m_combine_with_trend(true),
                       m_tolerance(10.0),
                       m_pattern_0(80),
                       m_pattern_1(70),
                       m_pattern_2(60),
                       m_pattern_3(90),
                       m_high_price(0.0),
                       m_low_price(0.0),
                       m_high_time(0),
                       m_low_time(0),
                       m_uptrend(false),
                       m_current_strength(0.0),
                       m_actual_period(PERIOD_CURRENT)
                     {}
                    ~CSignalFibonacci(void) {}
    
    // Parameter methods for Wizard
    void             Depth(int value)                { m_depth = value; }
    void             MinRetracement(double value)    { m_min_retracement = value; }
    void             MaxRetracement(double value)    { m_max_retracement = value; }
    void             WeightFactor(double value)      { m_weight_factor = value; }
    void             UseAsFilter(bool value)         { m_use_as_filter = value; }
    void             FilterWeight(double value)      { m_filter_weight = value; }
    void             CombineWithTrend(bool value)    { m_combine_with_trend = value; }
    void             Tolerance(double value)         { m_tolerance = value; }
    
    // Pattern weight methods
    void             Pattern_0(int value)            { m_pattern_0 = value; }
    void             Pattern_1(int value)            { m_pattern_1 = value; }
    void             Pattern_2(int value)            { m_pattern_2 = value; }
    void             Pattern_3(int value)            { m_pattern_3 = value; }
    
    // Main signal interface methods
    virtual bool      ValidationSettings(void);
    virtual bool      InitIndicators(CIndicators *indicators);
    virtual int       LongCondition(void);
    virtual int       ShortCondition(void);

protected:
    // Core Fibonacci logic
    bool              FindSwingPoints(void);
    double            CalculateRetracementLevel(double level);
    bool              IsAtFibonacciLevel(double price, int &pattern);
    double            GetPatternWeight(int pattern);
    
    // Price action confirmation
    bool              IsBullishReversal(void);
    bool              IsBearishReversal(void);
    bool              IsTrendAligned(void);
    
    // Utility methods
    bool              IsValidSwing(void);
    ENUM_TIMEFRAMES   GetActualPeriod(void);         // Helper to get actual timeframe
};
//+------------------------------------------------------------------+
//| Validation settings                                              |
//+------------------------------------------------------------------+
bool CSignalFibonacci::ValidationSettings(void)
{
    if(!CExpertSignal::ValidationSettings())
        return false;
        
    if(m_depth <= 0) {
        printf("Fibonacci Signal: Depth must be greater than 0");
        return false;
    }
    
    if(m_min_retracement >= m_max_retracement) {
        printf("Fibonacci Signal: Min retracement must be less than max retracement");
        return false;
    }
    
    return true;
}
//+------------------------------------------------------------------+
//| Initialize indicators                                            |
//+------------------------------------------------------------------+
bool CSignalFibonacci::InitIndicators(CIndicators *indicators)
{
    if(indicators == NULL)
        return false;
    
    // Store the actual period we'll use for calculations
    m_actual_period = GetActualPeriod();
        
    return true;
}
//+------------------------------------------------------------------+
//| Get actual timeframe for calculations                            |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES CSignalFibonacci::GetActualPeriod(void)
{
    if(m_period == PERIOD_CURRENT)
        return ::Period();  // Use global scope operator to call the built-in Period() function
    else
        return m_period;
}
//+------------------------------------------------------------------+
//| Find significant swing points                                    |
//+------------------------------------------------------------------+
bool CSignalFibonacci::FindSwingPoints(void)
{
    if(m_depth <= 0)
        return false;
    
    ENUM_TIMEFRAMES calc_period = GetActualPeriod();
        
    int highest_bar = iHighest(m_symbol.Name(), calc_period, MODE_HIGH, m_depth, 1);
    int lowest_bar = iLowest(m_symbol.Name(), calc_period, MODE_LOW, m_depth, 1);
    
    if(highest_bar == -1 || lowest_bar == -1)
        return false;
    
    m_high_price = iHigh(m_symbol.Name(), calc_period, highest_bar);
    m_low_price = iLow(m_symbol.Name(), calc_period, lowest_bar);
    m_high_time = iTime(m_symbol.Name(), calc_period, highest_bar);
    m_low_time = iTime(m_symbol.Name(), calc_period, lowest_bar);
    
    // Determine trend direction
    m_uptrend = (m_high_time > m_low_time);
    
    return IsValidSwing();
}
//+------------------------------------------------------------------+
//| Validate swing points                                            |
//+------------------------------------------------------------------+
bool CSignalFibonacci::IsValidSwing(void)
{
    if(m_high_price <= 0 || m_low_price <= 0)
        return false;
        
    // Ensure there's meaningful price movement
    double range = MathAbs(m_high_price - m_low_price);
    double min_range = m_symbol.Point() * 100; // At least 100 pips
    
    return (range >= min_range);
}
//+------------------------------------------------------------------+
//| Calculate Fibonacci retracement level                            |
//+------------------------------------------------------------------+
double CSignalFibonacci::CalculateRetracementLevel(double level)
{
    double range = m_high_price - m_low_price;
    
    if(m_uptrend) {
        // Uptrend: calculate retracement from high to low
        return m_high_price - (range * level);
    } else {
        // Downtrend: calculate retracement from low to high  
        return m_low_price + (range * level);
    }
}
//+------------------------------------------------------------------+
//| Check if price is at Fibonacci level and return pattern type     |
//+------------------------------------------------------------------+
bool CSignalFibonacci::IsAtFibonacciLevel(double price, int &pattern)
{
    if(!FindSwingPoints())
        return false;
    
    // Define Fibonacci levels and their pattern types
    struct FibLevel {
        double level;
        int pattern;
    };
    
    FibLevel levels[5] = {
        {0.236, 2},  // Weak level -> pattern 2
        {0.382, 0},  // Strong level -> pattern 0
        {0.500, 1},  // Medium level -> pattern 1
        {0.618, 0},  // Strong level -> pattern 0
        {0.786, 2}   // Weak level -> pattern 2
    };
    
    double tolerance_pips = m_symbol.Point() * m_tolerance;
    
    for(int i = 0; i < 5; i++) {
        double fib_level = CalculateRetracementLevel(levels[i].level);
        
        // Check if price is within tolerance of Fibonacci level
        if(MathAbs(price - fib_level) <= tolerance_pips) {
            // Validate this level is within our configured range
            if(levels[i].level >= m_min_retracement && levels[i].level <= m_max_retracement) {
                pattern = levels[i].pattern;
                return true;
            }
        }
    }
    
    pattern = -1;
    return false;
}
//+------------------------------------------------------------------+
//| Get weight for specific pattern                                  |
//+------------------------------------------------------------------+
double CSignalFibonacci::GetPatternWeight(int pattern)
{
    switch(pattern) {
        case 0: return m_pattern_0; // Strong Fib levels
        case 1: return m_pattern_1; // Medium Fib levels
        case 2: return m_pattern_2; // Weak Fib levels
        case 3: return m_pattern_3; // Fib + price action
        default: return 0;
    }
}
//+------------------------------------------------------------------+
//| Check for bullish reversal patterns                              |
//+------------------------------------------------------------------+
bool CSignalFibonacci::IsBullishReversal(void)
{
    ENUM_TIMEFRAMES calc_period = GetActualPeriod();
        
    double open1 = iOpen(m_symbol.Name(), calc_period, 1);
    double close1 = iClose(m_symbol.Name(), calc_period, 1);
    double high1 = iHigh(m_symbol.Name(), calc_period, 1);
    double low1 = iLow(m_symbol.Name(), calc_period, 1);
    
    double open2 = iOpen(m_symbol.Name(), calc_period, 2);
    double close2 = iClose(m_symbol.Name(), calc_period, 2);
    
    // Bullish engulfing pattern
    if(close1 > open1 && open2 > close2 && close1 > open2 && open1 < close2) {
        return true;
    }
    
    // Hammer pattern detection
    double range1 = high1 - low1;
    double body1 = MathAbs(close1 - open1);
    
    if(range1 > 0 && body1 > 0) {
        double lower_wick = (open1 > close1) ? (close1 - low1) : (open1 - low1);
        double upper_wick = (open1 > close1) ? (high1 - open1) : (high1 - close1);
        
        // Hammer: small body, long lower wick (at least 2x body)
        if(lower_wick >= (2 * body1) && upper_wick <= (body1 * 0.5)) {
            return true;
        }
    }
    
    return false;
}
//+------------------------------------------------------------------+
//| Check for bearish reversal patterns                              |
//+------------------------------------------------------------------+
bool CSignalFibonacci::IsBearishReversal(void)
{
    ENUM_TIMEFRAMES calc_period = GetActualPeriod();
        
    double open1 = iOpen(m_symbol.Name(), calc_period, 1);
    double close1 = iClose(m_symbol.Name(), calc_period, 1);
    double high1 = iHigh(m_symbol.Name(), calc_period, 1);
    double low1 = iLow(m_symbol.Name(), calc_period, 1);
    
    double open2 = iOpen(m_symbol.Name(), calc_period, 2);
    double close2 = iClose(m_symbol.Name(), calc_period, 2);
    
    // Bearish engulfing pattern
    if(close1 < open1 && open2 < close2 && close1 < open2 && open1 > close2) {
        return true;
    }
    
    // Shooting star pattern detection
    double range1 = high1 - low1;
    double body1 = MathAbs(close1 - open1);
    
    if(range1 > 0 && body1 > 0) {
        double upper_wick = (open1 > close1) ? (high1 - open1) : (high1 - close1);
        double lower_wick = (open1 > close1) ? (close1 - low1) : (open1 - low1);
        
        // Shooting star: small body, long upper wick (at least 2x body)
        if(upper_wick >= (2 * body1) && lower_wick <= (body1 * 0.5)) {
            return true;
        }
    }
    
    return false;
}
//+------------------------------------------------------------------+
//| Check if trade is aligned with trend                             |
//+------------------------------------------------------------------+
bool CSignalFibonacci::IsTrendAligned(void)
{
    if(!m_combine_with_trend)
        return true; // Skip trend check if disabled
        
    if(!FindSwingPoints())
        return false;
        
    double current_price = m_symbol.Bid();
    
    if(m_uptrend) {
        // For long trades in uptrend: price should be near support levels
        return (current_price <= CalculateRetracementLevel(0.618));
    } else {
        // For short trades in downtrend: price should be near resistance levels
        return (current_price >= CalculateRetracementLevel(0.618));
    }
}
//+------------------------------------------------------------------+
//| Long trading condition                                           |
//+------------------------------------------------------------------+
int CSignalFibonacci::LongCondition(void)
{
    int result = 0;
    int pattern = -1;
    double current_price = m_symbol.Bid();
    
    // Check if we're at a Fibonacci support level
    if(IsAtFibonacciLevel(current_price, pattern)) {
        if(pattern >= 0) {
            // Basic Fibonacci level detection
            if(IS_PATTERN_USAGE(pattern)) {
                result = (int)GetPatternWeight(pattern);
            }
            
            // Enhanced weight with price action confirmation
            if(IS_PATTERN_USAGE(3) && IsBullishReversal()) {
                int pa_weight = (int)GetPatternWeight(3);
                if(pa_weight > result) result = pa_weight;
            }
            
            // Apply trend filter if enabled
            if(m_combine_with_trend && !IsTrendAligned()) {
                result = 0;
            }
            
            // Apply weight factor
            if(result > 0) {
                result = (int)(result * m_weight_factor);
                result = MathMin(result, 100); // Cap at 100
                printf("Fibonacci LONG: Pattern=%d, Weight=%d", pattern, result);
            }
        }
    }
    
    return result;
}
//+------------------------------------------------------------------+
//| Short trading condition                                          |
//+------------------------------------------------------------------+
int CSignalFibonacci::ShortCondition(void)
{
    int result = 0;
    int pattern = -1;
    double current_price = m_symbol.Ask();
    
    // Check if we're at a Fibonacci resistance level
    if(IsAtFibonacciLevel(current_price, pattern)) {
        if(pattern >= 0) {
            // Basic Fibonacci level detection
            if(IS_PATTERN_USAGE(pattern)) {
                result = (int)GetPatternWeight(pattern);
            }
            
            // Enhanced weight with price action confirmation
            if(IS_PATTERN_USAGE(3) && IsBearishReversal()) {
                int pa_weight = (int)GetPatternWeight(3);
                if(pa_weight > result) result = pa_weight;
            }
            
            // Apply trend filter if enabled
            if(m_combine_with_trend && !IsTrendAligned()) {
                result = 0;
            }
            
            // Apply weight factor
            if(result > 0) {
                result = (int)(result * m_weight_factor);
                result = MathMin(result, 100); // Cap at 100
                printf("Fibonacci SHORT: Pattern=%d, Weight=%d", pattern, result);
            }
        }
    }
    
    return result;
}
//+------------------------------------------------------------------+

#endif