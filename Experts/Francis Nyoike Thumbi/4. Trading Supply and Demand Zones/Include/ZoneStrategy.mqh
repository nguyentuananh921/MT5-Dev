//+------------------------------------------------------------------+
//|                                                 ZoneStrategy.mqh |
//|                                  Copyright 2026, Francis Nyoike. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Francis Nyoike."
#property link      "https://www.mql5.com"
#property version   "2.00"

#include <Arrays\ArrayObj.mqh>
#include "TradeManager.mqh"

//+------------------------------------------------------------------+
//| Directional and Momentum Context Enumeration                     |
//+------------------------------------------------------------------+
enum ENUM_APPROACH_CONTEXT
  {
   APPROACH_NEUTRAL,
   APPROACH_BULLISH_AGGRESSIVE,
   APPROACH_BULLISH_CONSERVATIVE,
   APPROACH_BEARISH_AGGRESSIVE,
   APPROACH_BEARISH_CONSERVATIVE
  };

//+------------------------------------------------------------------+
//| Analytical  Filter Strategy Module                               |
//+------------------------------------------------------------------+
class CZoneStrategy
  {
private:

   double            min_zone_score;
   int               bounce_closes;
   double            risk_reward;
   double            atr_buffer_mult;

   //--- HTF Trend Filter Configuration
   bool              use_htf_filter;
   ENUM_TIMEFRAMES   htf_timeframe;
   int               htf_ma_period;

   //--- HTF RSI Exhaustion Filter Configuration
   bool              use_htf_rsi_filter;
   int               htf_rsi_period;
   double            htf_rsi_overbought;
   double            htf_rsi_oversold;

   //--- Context Analysis Parameter Configurations
   int               approach_lookback_bars;      // Number of bars to evaluate before zone touch
   double            approach_velocity_threshold; // ATR multiplier threshold for momentum sprint

   //--- Internal Private Verification Paths
   bool              VerifyBullishRejection(const MqlRates &bar, double zone_bottom);
   bool              VerifyBearishRejection(const MqlRates &bar, double zone_top);

   //--- Proximity Gate Check
   bool              ValidateZoneInteraction(double z_top, double z_bottom, double cached_atr, const MqlRates &current_bar);

   //--- Context Analyzer: Deciphers aggressive momentum sprint vs. casual exhaust
   ENUM_APPROACH_CONTEXT EvaluateApproachContext(const MqlRates &rates[], const double cached_atr);

   //--- HTF Bias & Exhaustion Checker
   bool              CheckHTFBias(bool bullish);

   //--- Premium Price Action Mathematical Core
   bool              IsPinBarBullish(const MqlRates &b);
   bool              IsPinBarBearish(const MqlRates &b);
   bool              IsBullishEngulfing(const MqlRates &p, const MqlRates &c);
   bool              IsBearishEngulfing(const MqlRates &p, const MqlRates &c);

public:

                     CZoneStrategy(const double min_score,
                 const int confirm_closes,
                 const double rr,
                 const double atr_mult,
                 const bool use_htf,
                 const ENUM_TIMEFRAMES htf_tf,
                 const int htf_ma,
                 const bool use_htf_rsi,
                 const int htf_rsi_len,
                 const double htf_rsi_ob,
                 const double htf_rsi_os,
                 const int approach_bars,
                 const double approach_threshold);

                    ~CZoneStrategy(void);


   bool              EvaluateSingleZoneSignal(CTradeManager *trade_manager,
         const double cached_atr,
         string z_name,
         int z_type,
         double z_top,
         double z_bottom,
         bool z_is_broken,
         bool z_is_pending,
         double z_current_score,
         bool z_buy_triggered,
         bool z_sell_triggered);

  };


//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CZoneStrategy::CZoneStrategy(const double min_score,
                             const int confirm_closes,
                             const double rr,
                             const double atr_mult,
                             const bool use_htf,
                             const ENUM_TIMEFRAMES htf_tf,
                             const int htf_ma,
                             const bool use_htf_rsi,
                             const int htf_rsi_len,
                             const double htf_rsi_ob,
                             const double htf_rsi_os,
                             const int approach_bars,
                             const double approach_threshold)
   :
   min_zone_score(min_score),
   bounce_closes(confirm_closes),
   risk_reward(rr),
   atr_buffer_mult(atr_mult),

//--- HTF FILTER SETTINGS
   use_htf_filter(use_htf),
   htf_timeframe(htf_tf),
   htf_ma_period(htf_ma),

//--- HTF RSI FILTER SETTINGS
   use_htf_rsi_filter(use_htf_rsi),
   htf_rsi_period(htf_rsi_len),
   htf_rsi_overbought(htf_rsi_ob),
   htf_rsi_oversold(htf_rsi_os),

//--- CONTEXT ANALYSIS SETTINGS
   approach_lookback_bars(approach_bars),
   approach_velocity_threshold(approach_threshold)
  {

  }


//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CZoneStrategy::~CZoneStrategy(void)
  {

  }


//+------------------------------------------------------------------+
//| HTF Moving Average Direction & RSI Exhaustion Filter             |
//+------------------------------------------------------------------+
bool CZoneStrategy::CheckHTFBias(bool bullish)
  {
//--- Bypass evaluation completely if user has deactivated HTF Trend Filtering
   if(!use_htf_filter)
      return true;

//--- 1. TREND DIRECTIONAL FILTER (EMA CHECK)
   int ma_handle=iMA(_Symbol,
                     htf_timeframe,
                     htf_ma_period,
                     0,
                     MODE_EMA,
                     PRICE_CLOSE);

   if(ma_handle==INVALID_HANDLE)
     {
      PrintFormat("[HTF WARNING] Failed to obtain EMA handle for %s. Bypassing filter.", EnumToString(htf_timeframe));
      return true;
     }

   double ma_buffer[];
   ArraySetAsSeries(ma_buffer,true);

   if(CopyBuffer(ma_handle,0,0,2,ma_buffer)<2)
     {
      IndicatorRelease(ma_handle);
      return true;
     }

   double htf_price=iClose(_Symbol,htf_timeframe,0);
   IndicatorRelease(ma_handle);

//--- Evaluate simple trend orientation
   bool trend_aligned = bullish ? (htf_price > ma_buffer[0]) : (htf_price < ma_buffer[0]);
   if(!trend_aligned)
      return false;

//--- 2. TREND EXHAUSTION FILTER (RSI CHECK)
   if(use_htf_rsi_filter)
     {
      int rsi_handle = iRSI(_Symbol, htf_timeframe, htf_rsi_period, PRICE_CLOSE);
      if(rsi_handle != INVALID_HANDLE)
        {
         double rsi_buffer[];
         ArraySetAsSeries(rsi_buffer, true);

         if(CopyBuffer(rsi_handle, 0, 0, 1, rsi_buffer) > 0)
           {
            double current_rsi = rsi_buffer[0];
            IndicatorRelease(rsi_handle);

            //--- If we want to BUY, ensure HTF is not overbought (Exhausted at the top)
            if(bullish && current_rsi >= htf_rsi_overbought)
              {
               PrintFormat("[RSI EXHAUSTION] Blocked BUY. HTF RSI Overbought (%.2f >= %.2f)", current_rsi, htf_rsi_overbought);
               return false;
              }

            //--- If we want to SELL, ensure HTF is not oversold (Exhausted at the bottom)
            if(!bullish && current_rsi <= htf_rsi_oversold)
              {
               PrintFormat("[RSI EXHAUSTION] Blocked SELL. HTF RSI Oversold (%.2f <= %.2f)", current_rsi, htf_rsi_oversold);
               return false;
              }
           }
         else
           {
            IndicatorRelease(rsi_handle);
           }
        }
     }

   return true;
  }


//+------------------------------------------------------------------+
//|Candlestick Bullish Pin Bar Check                                 |
//+------------------------------------------------------------------+
bool CZoneStrategy::IsPinBarBullish(const MqlRates &b)
  {
   double range = b.high - b.low;
   if(range <= 0)
      return false;

   double body = MathAbs(b.open - b.close);
   double lower_tail = MathMin(b.open, b.close) - b.low;
   double upper_tail = b.high - MathMax(b.open, b.close);

   bool rejectionOK = (lower_tail >= body * 2.0); // Strict PinBarRatio of 2.0
   bool cleanTop    = (upper_tail <= range * 0.15);
   bool compactBody = (body <= range * 0.30);

   return (rejectionOK && cleanTop && compactBody);
  }

//+------------------------------------------------------------------+
//| Candlestick  Bearish Pin Bar Check                               |
//+------------------------------------------------------------------+
bool CZoneStrategy::IsPinBarBearish(const MqlRates &b)
  {
   double range = b.high - b.low;
   if(range <= 0)
      return false;

   double body = MathAbs(b.open - b.close);
   double upper_tail = b.high - MathMax(b.open, b.close);
   double lower_tail = MathMin(b.open, b.close) - b.low;

   bool rejectionOK = (upper_tail >= body * 2.0); // Strict PinBarRatio of 2.0
   bool cleanBottom = (lower_tail <= range * 0.15);
   bool compactBody = (body <= range * 0.30);

   return (rejectionOK && cleanBottom && compactBody);
  }

//+------------------------------------------------------------------+
//|Candlestick Bullish Engufing Check                                |
//+------------------------------------------------------------------+
bool CZoneStrategy::IsBullishEngulfing(const MqlRates &p, const MqlRates &c)
  {
   double pRange = p.high - p.low;
   double cRange = c.high - c.low;
   if(pRange <= 0 || cRange <= 0)
      return false;

   double pBody = MathAbs(p.close - p.open);
   double cBody = MathAbs(c.close - c.open);

   if(pBody / pRange < 0.30)
      return false;
   if(cBody / cRange < 0.55)
      return false;

   if(!(p.close < p.open && c.close > c.open))
      return false;

   if(!(c.open <= p.close && c.close >= p.open))
      return false;

   if(cBody < pBody * 1.2)
      return false;

   return true;
  }

//+------------------------------------------------------------------+
//|Candlestick Bearish Engulfing Bar Check                           |
//+------------------------------------------------------------------+
bool CZoneStrategy::IsBearishEngulfing(const MqlRates &p, const MqlRates &c)
  {
   double pRange = p.high - p.low;
   double cRange = c.high - c.low;
   if(pRange <= 0 || cRange <= 0)
      return false;

   double pBody = MathAbs(p.close - p.open);
   double cBody = MathAbs(c.close - c.open);

   if(pBody / pRange < 0.30)
      return false;
   if(cBody / cRange < 0.55)
      return false;

   if(!(p.close > p.open && c.close < c.open))
      return false;

   if(!(c.open >= p.close && c.close <= p.open))
      return false;

   if(cBody < pBody * 1.2)
      return false;

   return true;
  }


//+------------------------------------------------------------------+
//| Bullish rejection                                                |
//+------------------------------------------------------------------+
bool CZoneStrategy::VerifyBullishRejection(const MqlRates &bar,
      double zone_bottom)
  {
//--- The function is passed rates[1] as 'bar' in the single-zone loop.
//--- To evaluate Engulfing Patterns, we copy local context rates to access rates[2].
   MqlRates local_rates[];
   ArraySetAsSeries(local_rates, true);
   if(CopyRates(_Symbol, _Period, 0, 3, local_rates) < 3)
      return false;

//--- Verify close level boundary validation rules
   bool close_confirmed = local_rates[1].close >= zone_bottom;
   if(!close_confirmed)
      return false;

//--- Execute pattern validation checks
   bool is_pin = IsPinBarBullish(local_rates[1]);
   bool is_engulf = IsBullishEngulfing(local_rates[2], local_rates[1]);

   return (is_pin || is_engulf);
  }


//+------------------------------------------------------------------+
//| Bearish rejection                                                |
//+------------------------------------------------------------------+
bool CZoneStrategy::VerifyBearishRejection(const MqlRates &bar,
      double zone_top)
  {
//--- The function is passed rates[1] as 'bar' in the single-zone loop.
//--- To evaluate Engulfing Patterns, we copy local context rates to access rates[2].
   MqlRates local_rates[];
   ArraySetAsSeries(local_rates, true);
   if(CopyRates(_Symbol, _Period, 0, 3, local_rates) < 3)
      return false;

//--- Verify close level boundary validation rules
   bool close_confirmed = local_rates[1].close <= zone_top;
   if(!close_confirmed)
      return false;

//--- Execute pattern validation checks
   bool is_pin = IsPinBarBearish(local_rates[1]);
   bool is_engulf = IsBearishEngulfing(local_rates[2], local_rates[1]);

   return (is_pin || is_engulf);
  }


//+------------------------------------------------------------------+
//| Zone Interaction Gate Check                                      |
//+------------------------------------------------------------------+
bool CZoneStrategy::ValidateZoneInteraction(double z_top, double z_bottom, double cached_atr, const MqlRates &current_bar)
  {
   double current_price = current_bar.close;
   double buffer = cached_atr * 0.5; // 0.5 ATR execution tolerance cushion

//--- Is the current price inside the zone boundaries or within the ATR-based proximity tolerance?
   if(current_price >= (z_bottom - buffer) && current_price <= (z_top + buffer))
     {
      return true;
     }

   return false;
  }


//+------------------------------------------------------------------+
//| Deciphers structure-based market context and directional flow    |
//+------------------------------------------------------------------+
ENUM_APPROACH_CONTEXT CZoneStrategy::EvaluateApproachContext(const MqlRates &rates[], const double cached_atr)
  {
//--- Safeguard array size bounds check
   if(ArraySize(rates) < (approach_lookback_bars + 1))
      return APPROACH_NEUTRAL;

   int bullish_closes = 0;
   int bearish_closes = 0;
   double total_displacement = rates[1].close - rates[approach_lookback_bars].open;

//--- Measure structural direction and candle overlap metrics
   for(int i = 1; i <= approach_lookback_bars; i++)
     {
      //--- Bullish pressure check
      if(rates[i].close > rates[i].open && rates[i].close > rates[i+1].close)
         bullish_closes++;

      //--- Bearish pressure check
      else
         if(rates[i].close < rates[i].open && rates[i].close < rates[i+1].close)
            bearish_closes++;
     }

//--- Normalize structural displacement value by volatility
   double normalized_displacement = MathAbs(total_displacement) / (cached_atr > 0 ? cached_atr : 1.0);

//--- Evaluate direction bias and calculate the approach profiles
   if(bullish_closes > bearish_closes)
     {
      //--- Strong displacement with consecutive control confirms aggression
      if(normalized_displacement > approach_velocity_threshold)
         return APPROACH_BULLISH_AGGRESSIVE;

      return APPROACH_BULLISH_CONSERVATIVE;
     }
   else
      if(bearish_closes > bullish_closes)
        {
         if(normalized_displacement > approach_velocity_threshold)
            return APPROACH_BEARISH_AGGRESSIVE;

         return APPROACH_BEARISH_CONSERVATIVE;
        }

   return APPROACH_NEUTRAL;
  }


//+------------------------------------------------------------------+
//| Main Strategy Pipeline                                           |
//+------------------------------------------------------------------+
bool CZoneStrategy::EvaluateSingleZoneSignal(CTradeManager *trade_manager,
      const double cached_atr,
      string z_name,
      int z_type,
      double z_top,
      double z_bottom,
      bool z_is_broken,
      bool z_is_pending,
      double z_current_score,
      bool z_buy_triggered,
      bool z_sell_triggered)

  {
//--- 1. TRADEMANAGER VALIDATION
   if(trade_manager==NULL || cached_atr<=0)
      return false;

//--- 2. ZONE HEALTH VALIDATION
   if(!z_is_pending || z_current_score < min_zone_score)
      return false;

//--- 3. COPY RATES
   MqlRates rates[];
   ArraySetAsSeries(rates,true);

   if(CopyRates(_Symbol,_Period,0,approach_lookback_bars+2,rates)<(approach_lookback_bars+2))
      return false;

//--- 4. VALIDATE ZONE INTERACTION GATE (Exit early if price is nowhere near)
   if(!ValidateZoneInteraction(z_top, z_bottom, cached_atr, rates[0]))
      return false;

//--- 5. EVALUATE APPROACH CONTEXT
   ENUM_APPROACH_CONTEXT approach_context = EvaluateApproachContext(rates, cached_atr);


//+------------------------------------------------------------------+
//| CASE 1: SUPPORT ZONE PROCESSING                                  |
//+------------------------------------------------------------------+
   if(z_type==0)
     {
      //--- SCENARIO A: CASUAL / CONSERVATIVE APPROACH (Expect Reversal Bounce)
      if(approach_context == APPROACH_BEARISH_CONSERVATIVE || approach_context == APPROACH_NEUTRAL)
        {
         if(z_is_broken || z_buy_triggered)
            return false;

         if(!CheckHTFBias(true))
            return false;

         if(VerifyBullishRejection(rates[1], z_bottom))
           {
            double entry_price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            double sl_distance=(z_top-z_bottom)+(cached_atr*atr_buffer_mult);
            double sl=entry_price-sl_distance;
            double tp=entry_price+(sl_distance*risk_reward);

            string comment=StringFormat("SR4_REVERSAL_BUY_%s",z_name);

            if(trade_manager.ExecuteBuy(_Symbol,entry_price,sl,tp,comment))
              {
               PrintFormat(">>> [REVERSAL BOUNCE BUY] Zone: %s",z_name);
               return true;
              }
           }
        }
      //--- SCENARIO B: AGGRESSIVE SPRINT (Expect Breakout Pullback Sell)
      else
         if(approach_context == APPROACH_BEARISH_AGGRESSIVE)
           {
            if(!z_is_broken || z_sell_triggered)
               return false;

            if(!CheckHTFBias(false))
               return false;

            if(VerifyBearishRejection(rates[1], z_top))
              {
               double entry_price=SymbolInfoDouble(_Symbol,SYMBOL_BID);
               double sl_distance=(z_top-z_bottom)+(cached_atr*atr_buffer_mult);
               double sl=entry_price+sl_distance;
               double tp=entry_price-(sl_distance*risk_reward);

               string comment=StringFormat("SR4_BREAKOUT_SELL_%s",z_name);

               if(trade_manager.ExecuteSell(_Symbol,entry_price,sl,tp,comment))
                 {
                  PrintFormat(">>> [BREAKOUT PULLBACK SELL] Zone: %s",z_name);
                  return true;
                 }
              }
           }
     }

//+------------------------------------------------------------------+
//| CASE 2: RESISTANCE ZONE PROCESSING                               |
//+------------------------------------------------------------------+
   else
      if(z_type==1)
        {
         //--- SCENARIO A: CASUAL / CONSERVATIVE APPROACH (Expect Reversal Bounce)
         if(approach_context == APPROACH_BULLISH_CONSERVATIVE || approach_context == APPROACH_NEUTRAL)
           {
            if(z_is_broken || z_sell_triggered)
               return false;

            if(!CheckHTFBias(false))
               return false;

            if(VerifyBearishRejection(rates[1], z_top))
              {
               double entry_price=SymbolInfoDouble(_Symbol,SYMBOL_BID);
               double sl_distance=(z_top-z_bottom)+(cached_atr*atr_buffer_mult);
               double sl=entry_price+sl_distance;
               double tp=entry_price-(sl_distance*risk_reward);

               string comment=StringFormat("SR4_REVERSAL_SELL_%s",z_name);

               if(trade_manager.ExecuteSell(_Symbol,entry_price,sl,tp,comment))
                 {
                  PrintFormat(">>> [REVERSAL BOUNCE SELL] Zone: %s",z_name);
                  return true;
                 }
              }
           }
         //--- SCENARIO B: AGGRESSIVE SPRINT (Expect Breakout Pullback Buy)
         else
            if(approach_context == APPROACH_BULLISH_AGGRESSIVE)
              {
               if(!z_is_broken || z_buy_triggered)
                  return false;

               if(!CheckHTFBias(true))
                  return false;

               if(VerifyBullishRejection(rates[1], z_bottom))
                 {
                  double entry_price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
                  double sl_distance=(z_top-z_bottom)+(cached_atr*atr_buffer_mult);
                  double sl=entry_price-sl_distance;
                  double tp=entry_price+(sl_distance*risk_reward);

                  string comment=StringFormat("SR4_BREAKOUT_BUY_%s",z_name);

                  if(trade_manager.ExecuteBuy(_Symbol,entry_price,sl,tp,comment))
                    {
                     PrintFormat(">>> [BREAKOUT PULLBACK BUY] Zone: %s",z_name);
                     return true;
                    }
                 }
              }
        }

   return false;
  }
//+------------------------------------------------------------------+

