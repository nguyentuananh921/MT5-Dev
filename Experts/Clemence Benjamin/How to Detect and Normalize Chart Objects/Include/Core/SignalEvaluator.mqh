//+------------------------------------------------------------------+
//|                                              SignalEvaluator.mqh |
//|                                Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"

#include "../Common/Structures.mqh"
#include "../Helpers/MathHelpers.mqh"

//+------------------------------------------------------------------+
//| Class: CSignalEvaluator                                          |
//| Purpose: Evaluates price interactions with analytical objects    |
//| Enhanced for Part 5: Full Fibonacci family support              |
//+------------------------------------------------------------------+
class CSignalEvaluator
  {
private:
   string            m_name;         // object name
   ENUM_OBJECT       m_type;         // object type
   long              m_chartId;      // chart identifier
   double            m_threshold;    // touch threshold in pips
   double            m_slMultiplier; // stop loss multiplier
   double            m_tpMultiplier; // take profit multiplier

public:
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
                     CSignalEvaluator(long chartId, string name, ENUM_OBJECT type,
                    double threshold, double slMult, double tpMult)
      :              m_chartId(chartId),
        m_name(name),
        m_type(type),
        m_threshold(threshold),
        m_slMultiplier(slMult),
        m_tpMultiplier(tpMult) {}

   //+------------------------------------------------------------------+
   //| Analyzes price interaction with the object                       |
   //+------------------------------------------------------------------+
   bool              AnalyzeSignal(const MarketSnapshot &snapshot, TradeSignal &signal)
     {
      signal.isValid = false;
      double threshold = m_threshold * g_point * 10;
      switch(m_type)
        {
         case OBJ_TREND:
            return(AnalyzeTrendline(snapshot, signal, threshold));
         case OBJ_HLINE:
            return(AnalyzeHorizontalLine(snapshot, signal, threshold));
         case OBJ_FIBO:
            return(AnalyzeFibonacciRetracement(snapshot, signal, threshold));
         case OBJ_FIBOFAN:
            return(AnalyzeFibonacciFan(snapshot, signal, threshold));
         case OBJ_FIBOTIMES:
            return(AnalyzeFibonacciTimeZones(snapshot, signal, threshold));
         case OBJ_FIBOARC:
            return(AnalyzeFibonacciArcs(snapshot, signal, threshold));
         case OBJ_FIBOCHANNEL:
            return(AnalyzeFibonacciChannel(snapshot, signal, threshold));
         case OBJ_EXPANSION:
            return(AnalyzeFibonacciExpansion(snapshot, signal, threshold));
         case OBJ_CHANNEL:
            return(AnalyzeChannel(snapshot, signal, threshold));
         case OBJ_PITCHFORK:
            return(AnalyzePitchfork(snapshot, signal, threshold));
         default:
            return(false);
        }
     }

private:
   //+------------------------------------------------------------------+
   //| Analyzes trendline interaction                                   |
   //+------------------------------------------------------------------+
   bool              AnalyzeTrendline(const MarketSnapshot &snapshot, TradeSignal &signal, double threshold)
     {
      double linePrice = GetLineValueAtTime(m_chartId, m_name, snapshot.time);
      if(linePrice <= 0)
         return(false);
      if(MathAbs(snapshot.bid - linePrice) <= threshold)
        {
         bool uptrend = (GetEMA(20) > GetEMA(50));
         if(uptrend)
           {
            signal.orderType = ORDER_TYPE_BUY;
            signal.entryPrice = snapshot.ask;
            signal.stopLoss = linePrice - threshold * m_slMultiplier;
            signal.takeProfit = snapshot.ask + (snapshot.ask - linePrice) * m_tpMultiplier;
            signal.reason = StringFormat("Trendline touch on %s", m_name);
            signal.confidence = 0.65;
           }
         else
           {
            signal.orderType = ORDER_TYPE_SELL;
            signal.entryPrice = snapshot.bid;
            signal.stopLoss = linePrice + threshold * m_slMultiplier;
            signal.takeProfit = snapshot.bid - (linePrice - snapshot.bid) * m_tpMultiplier;
            signal.reason = StringFormat("Trendline touch on %s", m_name);
            signal.confidence = 0.65;
           }
         signal.isValid = true;
         signal.signalTime = snapshot.time;
         signal.objectName = m_name;
         signal.objectType = m_type;
         return(true);
        }
      return(false);
     }

   //+------------------------------------------------------------------+
   //| Analyzes horizontal line interaction                             |
   //+------------------------------------------------------------------+
   bool              AnalyzeHorizontalLine(const MarketSnapshot &snapshot, TradeSignal &signal, double threshold)
     {
      double levelPrice = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 0);
      if(levelPrice <= 0)
         return(false);
      if(MathAbs(snapshot.bid - levelPrice) <= threshold)
        {
         bool isSupport = (snapshot.bid > levelPrice);
         if(isSupport)
           {
            signal.orderType = ORDER_TYPE_BUY;
            signal.entryPrice = snapshot.ask;
            signal.stopLoss = levelPrice - threshold * m_slMultiplier;
            signal.takeProfit = snapshot.ask + (snapshot.ask - levelPrice) * m_tpMultiplier;
            signal.reason = StringFormat("Support on %s", m_name);
            signal.confidence = 0.70;
           }
         else
           {
            signal.orderType = ORDER_TYPE_SELL;
            signal.entryPrice = snapshot.bid;
            signal.stopLoss = levelPrice + threshold * m_slMultiplier;
            signal.takeProfit = snapshot.bid - (levelPrice - snapshot.bid) * m_tpMultiplier;
            signal.reason = StringFormat("Resistance on %s", m_name);
            signal.confidence = 0.70;
           }
         signal.isValid = true;
         signal.signalTime = snapshot.time;
         signal.objectName = m_name;
         signal.objectType = m_type;
         return(true);
        }
      return(false);
     }

   //+------------------------------------------------------------------+
   //| Analyzes Fibonacci retracement (OBJ_FIBO)                        |
   //+------------------------------------------------------------------+
   bool              AnalyzeFibonacciRetracement(const MarketSnapshot &snapshot, TradeSignal &signal, double threshold)
     {
      double p0 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 0);
      double p1 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 1);
      if(p0 <= 0 || p1 <= 0)
         return(false);
      int levels = (int)ObjectGetInteger(m_chartId, m_name, OBJPROP_LEVELS);
      double bid = snapshot.bid;
      
      for(int i = 0; i < levels && i < 10; i++)
        {
         double ratio = ObjectGetDouble(m_chartId, m_name, OBJPROP_LEVELVALUE, i);
         double fibPrice = p0 + (p1 - p0) * ratio;
         if(MathAbs(bid - fibPrice) <= threshold)
           {
            bool uptrend = (GetEMA(20) > GetEMA(50));
            if(uptrend)
              {
               signal.orderType = ORDER_TYPE_BUY;
               signal.entryPrice = snapshot.ask;
               signal.stopLoss = fibPrice - threshold * m_slMultiplier;
               signal.takeProfit = snapshot.ask + (snapshot.ask - fibPrice) * m_tpMultiplier;
               signal.reason = StringFormat("Fibonacci %.1f%% on %s", ratio * 100, m_name);
               signal.confidence = 0.70;
              }
            else
              {
               signal.orderType = ORDER_TYPE_SELL;
               signal.entryPrice = snapshot.bid;
               signal.stopLoss = fibPrice + threshold * m_slMultiplier;
               signal.takeProfit = snapshot.bid - (fibPrice - snapshot.bid) * m_tpMultiplier;
               signal.reason = StringFormat("Fibonacci %.1f%% on %s", ratio * 100, m_name);
               signal.confidence = 0.70;
              }
            signal.isValid = true;
            signal.signalTime = snapshot.time;
            signal.objectName = m_name;
            signal.objectType = m_type;
            return(true);
           }
        }
      return(false);
     }

   //+------------------------------------------------------------------+
   //| Analyzes Fibonacci fan (OBJ_FIBOFAN)                             |
   //+------------------------------------------------------------------+
   bool              AnalyzeFibonacciFan(const MarketSnapshot &snapshot, TradeSignal &signal, double threshold)
     {
      datetime t1 = (datetime)ObjectGetInteger(m_chartId, m_name, OBJPROP_TIME, 0);
      datetime t2 = (datetime)ObjectGetInteger(m_chartId, m_name, OBJPROP_TIME, 1);
      double p1 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 0);
      double p2 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 1);
      if(t1 == 0 || t2 == 0 || p1 <= 0 || p2 <= 0)
         return(false);
      
      int levels = (int)ObjectGetInteger(m_chartId, m_name, OBJPROP_LEVELS);
      double bid = snapshot.bid;
      
      for(int i = 0; i < levels && i < 10; i++)
        {
         double ratio = ObjectGetDouble(m_chartId, m_name, OBJPROP_LEVELVALUE, i);
         double priceAtT2 = p1 + (p2 - p1) * ratio;
         double linePrice = p1 + (priceAtT2 - p1) * (double)(snapshot.time - t1) / (double)(t2 - t1);
         if(linePrice <= 0) continue;
         
         if(MathAbs(bid - linePrice) <= threshold)
           {
            bool uptrend = (GetEMA(20) > GetEMA(50));
            if(uptrend)
              {
               signal.orderType = ORDER_TYPE_BUY;
               signal.entryPrice = snapshot.ask;
               signal.stopLoss = linePrice - threshold * m_slMultiplier;
               signal.takeProfit = snapshot.ask + (snapshot.ask - linePrice) * m_tpMultiplier;
               signal.reason = StringFormat("Fan %.1f%% on %s", ratio * 100, m_name);
               signal.confidence = 0.65;
              }
            else
              {
               signal.orderType = ORDER_TYPE_SELL;
               signal.entryPrice = snapshot.bid;
               signal.stopLoss = linePrice + threshold * m_slMultiplier;
               signal.takeProfit = snapshot.bid - (linePrice - snapshot.bid) * m_tpMultiplier;
               signal.reason = StringFormat("Fan %.1f%% on %s", ratio * 100, m_name);
               signal.confidence = 0.65;
              }
            signal.isValid = true;
            signal.signalTime = snapshot.time;
            signal.objectName = m_name;
            signal.objectType = m_type;
            return(true);
           }
        }
      return(false);
     }

   //+------------------------------------------------------------------+
   //| Analyzes Fibonacci time zones (OBJ_FIBOTIMES)                    |
   //+------------------------------------------------------------------+
   bool              AnalyzeFibonacciTimeZones(const MarketSnapshot &snapshot, TradeSignal &signal, double threshold)
     {
      datetime t0 = (datetime)ObjectGetInteger(m_chartId, m_name, OBJPROP_TIME, 0);
      if(t0 == 0) return(false);
      
      int levels = (int)ObjectGetInteger(m_chartId, m_name, OBJPROP_LEVELS);
      double bid = snapshot.bid;
      
      for(int i = 0; i < levels && i < 10; i++)
        {
         double offsetSeconds = ObjectGetDouble(m_chartId, m_name, OBJPROP_LEVELVALUE, i);
         datetime zoneTime = t0 + (datetime)offsetSeconds;
         
         // Calculate time difference in seconds
         long timeDiff = snapshot.time - zoneTime;
         if(timeDiff < 0) timeDiff = -timeDiff;
         
         // Convert threshold from seconds to compare
         if(timeDiff <= (long)(threshold * 60))
           {
            bool uptrend = (GetEMA(20) > GetEMA(50));
            if(uptrend)
              {
               signal.orderType = ORDER_TYPE_BUY;
               signal.entryPrice = snapshot.ask;
               signal.stopLoss = snapshot.bid - threshold * m_slMultiplier * 10;
               signal.takeProfit = snapshot.ask + threshold * m_tpMultiplier * 20;
               signal.reason = StringFormat("Time zone %d on %s", i, m_name);
               signal.confidence = 0.55;
              }
            else
              {
               signal.orderType = ORDER_TYPE_SELL;
               signal.entryPrice = snapshot.bid;
               signal.stopLoss = snapshot.ask + threshold * m_slMultiplier * 10;
               signal.takeProfit = snapshot.bid - threshold * m_tpMultiplier * 20;
               signal.reason = StringFormat("Time zone %d on %s", i, m_name);
               signal.confidence = 0.55;
              }
            signal.isValid = true;
            signal.signalTime = snapshot.time;
            signal.objectName = m_name;
            signal.objectType = m_type;
            return(true);
           }
        }
      return(false);
     }

   //+------------------------------------------------------------------+
   //| Analyzes Fibonacci arcs (OBJ_FIBOARC)                            |
   //+------------------------------------------------------------------+
   bool              AnalyzeFibonacciArcs(const MarketSnapshot &snapshot, TradeSignal &signal, double threshold)
     {
      double p0 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 0);
      double p1 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 1);
      if(p0 <= 0 || p1 <= 0) return(false);
      
      int levels = (int)ObjectGetInteger(m_chartId, m_name, OBJPROP_LEVELS);
      double bid = snapshot.bid;
      double priceRange = MathAbs(p1 - p0);
      
      for(int i = 0; i < levels && i < 10; i++)
        {
         double ratio = ObjectGetDouble(m_chartId, m_name, OBJPROP_LEVELVALUE, i);
         double arcPrice = p0 + priceRange * ratio;
         if(MathAbs(bid - arcPrice) <= threshold)
           {
            bool uptrend = (GetEMA(20) > GetEMA(50));
            if(uptrend)
              {
               signal.orderType = ORDER_TYPE_BUY;
               signal.entryPrice = snapshot.ask;
               signal.stopLoss = arcPrice - threshold * m_slMultiplier;
               signal.takeProfit = snapshot.ask + (snapshot.ask - arcPrice) * m_tpMultiplier;
               signal.reason = StringFormat("Arc %.1f%% on %s", ratio * 100, m_name);
               signal.confidence = 0.60;
              }
            else
              {
               signal.orderType = ORDER_TYPE_SELL;
               signal.entryPrice = snapshot.bid;
               signal.stopLoss = arcPrice + threshold * m_slMultiplier;
               signal.takeProfit = snapshot.bid - (arcPrice - snapshot.bid) * m_tpMultiplier;
               signal.reason = StringFormat("Arc %.1f%% on %s", ratio * 100, m_name);
               signal.confidence = 0.60;
              }
            signal.isValid = true;
            signal.signalTime = snapshot.time;
            signal.objectName = m_name;
            signal.objectType = m_type;
            return(true);
           }
        }
      return(false);
     }

   //+------------------------------------------------------------------+
   //| Analyzes Fibonacci channel (OBJ_FIBOCHANNEL)                     |
   //+------------------------------------------------------------------+
   bool              AnalyzeFibonacciChannel(const MarketSnapshot &snapshot, TradeSignal &signal, double threshold)
     {
      datetime t1 = (datetime)ObjectGetInteger(m_chartId, m_name, OBJPROP_TIME, 0);
      datetime t2 = (datetime)ObjectGetInteger(m_chartId, m_name, OBJPROP_TIME, 1);
      datetime t3 = (datetime)ObjectGetInteger(m_chartId, m_name, OBJPROP_TIME, 2);
      double p1 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 0);
      double p2 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 1);
      double p3 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 2);
      if(t1 == 0 || t2 == 0 || p1 <= 0 || p2 <= 0) return(false);
      
      double baseLine = GetLineValueAtTime(m_chartId, m_name, snapshot.time);
      if(baseLine <= 0) return(false);
      
      double offset = 0;
      if(t3 != 0 && p3 != 0)
        {
         double baseAtT3 = GetLineValueAtTime(m_chartId, m_name, t3);
         if(baseAtT3 > 0)
            offset = p3 - baseAtT3;
        }
      
      double upperLine = baseLine + offset;
      double lowerLine = baseLine - offset;
      double bid = snapshot.bid;
      
      if(MathAbs(bid - upperLine) <= threshold)
        {
         signal.orderType = ORDER_TYPE_SELL;
         signal.entryPrice = snapshot.bid;
         signal.stopLoss = upperLine + threshold * m_slMultiplier;
         signal.takeProfit = lowerLine + (upperLine - lowerLine) * 0.5;
         signal.reason = StringFormat("Channel resistance on %s", m_name);
         signal.confidence = 0.70;
         signal.isValid = true;
         signal.signalTime = snapshot.time;
         signal.objectName = m_name;
         signal.objectType = m_type;
         return(true);
        }
      if(MathAbs(bid - lowerLine) <= threshold)
        {
         signal.orderType = ORDER_TYPE_BUY;
         signal.entryPrice = snapshot.ask;
         signal.stopLoss = lowerLine - threshold * m_slMultiplier;
         signal.takeProfit = upperLine - (upperLine - lowerLine) * 0.5;
         signal.reason = StringFormat("Channel support on %s", m_name);
         signal.confidence = 0.70;
         signal.isValid = true;
         signal.signalTime = snapshot.time;
         signal.objectName = m_name;
         signal.objectType = m_type;
         return(true);
        }
      return(false);
     }

   //+------------------------------------------------------------------+
   //| Analyzes Fibonacci expansion (OBJ_EXPANSION)                     |
   //+------------------------------------------------------------------+
   bool              AnalyzeFibonacciExpansion(const MarketSnapshot &snapshot, TradeSignal &signal, double threshold)
     {
      double p0 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 0);
      double p1 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 1);
      double p2 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 2);
      if(p0 <= 0 || p1 <= 0 || p2 <= 0) return(false);
      
      int levels = (int)ObjectGetInteger(m_chartId, m_name, OBJPROP_LEVELS);
      double bid = snapshot.bid;
      double move1 = p1 - p0;
      
      for(int i = 0; i < levels && i < 10; i++)
        {
         double ratio = ObjectGetDouble(m_chartId, m_name, OBJPROP_LEVELVALUE, i);
         double expansionPrice = p2 + move1 * ratio;
         if(MathAbs(bid - expansionPrice) <= threshold)
           {
            bool uptrend = (GetEMA(20) > GetEMA(50));
            if(uptrend)
              {
               signal.orderType = ORDER_TYPE_BUY;
               signal.entryPrice = snapshot.ask;
               signal.stopLoss = expansionPrice - threshold * m_slMultiplier;
               signal.takeProfit = snapshot.ask + (snapshot.ask - expansionPrice) * m_tpMultiplier;
               signal.reason = StringFormat("Expansion %.2f on %s", ratio, m_name);
               signal.confidence = 0.65;
              }
            else
              {
               signal.orderType = ORDER_TYPE_SELL;
               signal.entryPrice = snapshot.bid;
               signal.stopLoss = expansionPrice + threshold * m_slMultiplier;
               signal.takeProfit = snapshot.bid - (expansionPrice - snapshot.bid) * m_tpMultiplier;
               signal.reason = StringFormat("Expansion %.2f on %s", ratio, m_name);
               signal.confidence = 0.65;
              }
            signal.isValid = true;
            signal.signalTime = snapshot.time;
            signal.objectName = m_name;
            signal.objectType = m_type;
            return(true);
           }
        }
      return(false);
     }

   //+------------------------------------------------------------------+
   //| Analyzes channel interaction                                     |
   //+------------------------------------------------------------------+
   bool              AnalyzeChannel(const MarketSnapshot &snapshot, TradeSignal &signal, double threshold)
     {
      datetime t1 = (datetime)ObjectGetInteger(m_chartId, m_name, OBJPROP_TIME, 0);
      datetime t2 = (datetime)ObjectGetInteger(m_chartId, m_name, OBJPROP_TIME, 1);
      datetime t3 = (datetime)ObjectGetInteger(m_chartId, m_name, OBJPROP_TIME, 2);
      double p1 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 0);
      double p2 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 1);
      double p3 = ObjectGetDouble(m_chartId, m_name, OBJPROP_PRICE, 2);
      if(t1 == 0 || t2 == 0 || p1 == 0 || p2 == 0)
         return(false);
      double baseLine = GetLineValueAtTime(m_chartId, m_name, snapshot.time);
      if(baseLine <= 0)
         return(false);
      double offset = 0;
      if(t3 != 0 && p3 != 0)
        {
         double baseAtT3 = GetLineValueAtTime(m_chartId, m_name, t3);
         if(baseAtT3 > 0)
            offset = p3 - baseAtT3;
        }
      double upperLine = baseLine + offset;
      double lowerLine = baseLine - offset;
      double bid = snapshot.bid;
      if(MathAbs(bid - upperLine) <= threshold)
        {
         signal.orderType = ORDER_TYPE_SELL;
         signal.entryPrice = snapshot.bid;
         signal.stopLoss = upperLine + threshold * m_slMultiplier;
         signal.takeProfit = lowerLine + (upperLine - lowerLine) * 0.5;
         signal.reason = StringFormat("Channel resistance on %s", m_name);
         signal.confidence = 0.70;
         signal.isValid = true;
         signal.signalTime = snapshot.time;
         signal.objectName = m_name;
         signal.objectType = m_type;
         return(true);
        }
      if(MathAbs(bid - lowerLine) <= threshold)
        {
         signal.orderType = ORDER_TYPE_BUY;
         signal.entryPrice = snapshot.ask;
         signal.stopLoss = lowerLine - threshold * m_slMultiplier;
         signal.takeProfit = upperLine - (upperLine - lowerLine) * 0.5;
         signal.reason = StringFormat("Channel support on %s", m_name);
         signal.confidence = 0.70;
         signal.isValid = true;
         signal.signalTime = snapshot.time;
         signal.objectName = m_name;
         signal.objectType = m_type;
         return(true);
        }
      return(false);
     }

   //+------------------------------------------------------------------+
   //| Analyzes pitchfork interaction                                   |
   //+------------------------------------------------------------------+
   bool              AnalyzePitchfork(const MarketSnapshot &snapshot, TradeSignal &signal, double threshold)
     {
      double medianLine = GetLineValueAtTime(m_chartId, m_name, snapshot.time);
      if(medianLine <= 0)
         return(false);
      if(MathAbs(snapshot.bid - medianLine) <= threshold)
        {
         bool uptrend = (GetEMA(20) > GetEMA(50));
         if(uptrend)
           {
            signal.orderType = ORDER_TYPE_BUY;
            signal.entryPrice = snapshot.ask;
            signal.stopLoss = medianLine - threshold * m_slMultiplier;
            signal.takeProfit = snapshot.ask + (snapshot.ask - medianLine) * m_tpMultiplier;
            signal.reason = StringFormat("Pitchfork support on %s", m_name);
            signal.confidence = 0.65;
           }
         else
           {
            signal.orderType = ORDER_TYPE_SELL;
            signal.entryPrice = snapshot.bid;
            signal.stopLoss = medianLine + threshold * m_slMultiplier;
            signal.takeProfit = snapshot.bid - (medianLine - snapshot.bid) * m_tpMultiplier;
            signal.reason = StringFormat("Pitchfork resistance on %s", m_name);
            signal.confidence = 0.65;
           }
         signal.isValid = true;
         signal.signalTime = snapshot.time;
         signal.objectName = m_name;
         signal.objectType = m_type;
         return(true);
        }
      return(false);
     }
  };
//+------------------------------------------------------------------+