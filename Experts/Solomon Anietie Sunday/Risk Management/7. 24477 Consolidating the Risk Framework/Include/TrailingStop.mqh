//+------------------------------------------------------------------+
//|                                                 TrailingStop.mqh |
//|                                    Copyright 2026, soloharbinger |
//|                      https://www.mql5.com/en/users/soloharbinger |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, soloharbinger"
#property link        "https://www.mql5.com/en/users/soloharbinger"
#property description "Trailing stops and break-even for positions that are already open."

#ifndef RISKMANAGEMENT_TRAILINGSTOP_MQH
#define RISKMANAGEMENT_TRAILINGSTOP_MQH

#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Which trailing method the engine builds                          |
//+------------------------------------------------------------------+
enum ENUM_TRAIL_METHOD
  {
   TRAIL_OFF,           // No trailing method
   TRAIL_ATR,           // Continuous, volatility-scaled
   TRAIL_RR_LADDER      // Discrete, locks R multiples
  };

//+------------------------------------------------------------------+
//| Everything a method may read about one position                  |
//+------------------------------------------------------------------+
struct STrailContext
  {
   string            symbol;
   ulong             ticket;
   ENUM_POSITION_TYPE positionType;
   double            entryPrice;
   double            currentSL;
   double            currentTP;
   double            bid;
   double            ask;
   double            closePrice;       // Bid for a buy, Ask for a sell
   double            profitDistance;   // How far closePrice is beyond entry
   double            originalRisk;     // R in price units, 0 when unknown
   double            atrValue;
   double            point;
   int               digits;
  };

//+------------------------------------------------------------------+
//| Trailing configuration, filled once by the EA                    |
//+------------------------------------------------------------------+
struct STrailConfig
  {
   long              magic;
   ENUM_TRAIL_METHOD method;
   double            activateAtR;            // 0 = act as soon as a stop can improve

   //--- Break-even
   bool              useBreakEven;
   double            breakEvenAtR;           // Profit in R that moves the stop to entry
   int               breakEvenOffsetPoints;  // Points beyond entry, to cover costs

   //--- ATR method
   double            atrMultiplier;

   //--- R-ladder method
   double            ladderStepR;            // Rung spacing, in R
   double            ladderLagR;             // How far behind the reached rung to lock, in R

   //--- Guards and logging
   int               minStepPoints;          // Ignore improvements smaller than this
   bool              verbose;                // Log every modification

   void              SetDefaults(void);
  };

//+------------------------------------------------------------------+
//| Trailing defaults                                                |
//+------------------------------------------------------------------+
void STrailConfig::SetDefaults(void)
  {
   magic                 = 0;
   method                = TRAIL_OFF;
   activateAtR           = 0.0;
   useBreakEven          = false;
   breakEvenAtR          = 1.0;
   breakEvenOffsetPoints = 20;
   atrMultiplier         = 2.0;
   ladderStepR           = 1.0;
   ladderLagR            = 1.0;
   minStepPoints         = 50;
   verbose               = true;
  }

//+------------------------------------------------------------------+
//| Base class: a method proposes a stop price, or 0 for no proposal |
//+------------------------------------------------------------------+
class CTrailMethod
  {
public:
   virtual          ~CTrailMethod(void) {}

   virtual double    ComputeStopLevel(const STrailContext &ctx) { return 0.0; }
   virtual bool      NeedsOriginalRisk(void) const { return false; }
   virtual string    Name(void) const { return "none"; }
  };

//+------------------------------------------------------------------+
//| ATR trailing                                                     |
//+------------------------------------------------------------------+
class CTrailATR : public CTrailMethod
  {
private:
   double            m_multiplier;

public:
                     CTrailATR(const double multiplier) { m_multiplier = multiplier; }

   virtual double    ComputeStopLevel(const STrailContext &ctx);
   virtual bool      NeedsOriginalRisk(void) const { return false; }
   virtual string    Name(void) const { return "ATR"; }
  };

//+------------------------------------------------------------------+
//| Trail at a volatility-scaled distance behind the closing side    |
//+------------------------------------------------------------------+
double CTrailATR::ComputeStopLevel(const STrailContext &ctx)
  {
   if(ctx.atrValue <= 0 || m_multiplier <= 0)
      return 0.0;

   double distance = ctx.atrValue * m_multiplier;

   if(ctx.positionType == POSITION_TYPE_BUY)
      return ctx.closePrice - distance;

   return ctx.closePrice + distance;
  }

//+------------------------------------------------------------------+
//| R-multiple ladder trailing                                       |
//+------------------------------------------------------------------+
class CTrailRRLadder : public CTrailMethod
  {
private:
   double            m_stepR;
   double            m_lagR;

public:
                     CTrailRRLadder(const double stepR, const double lagR)
     {
      m_stepR = stepR;
      m_lagR  = lagR;
     }

   virtual double    ComputeStopLevel(const STrailContext &ctx);
   virtual bool      NeedsOriginalRisk(void) const { return true; }
   virtual string    Name(void) const { return "R-ladder"; }
  };

//+------------------------------------------------------------------+
//| Lock whole R multiples as they are cleared                       |
//+------------------------------------------------------------------+
double CTrailRRLadder::ComputeStopLevel(const STrailContext &ctx)
  {
//--- Without the original risk there is no R to count in
   if(ctx.originalRisk <= 0 || m_stepR <= 0 || ctx.profitDistance <= 0)
      return 0.0;

   double profitR = ctx.profitDistance / ctx.originalRisk;

//--- The highest rung fully cleared
   double rung = MathFloor(profitR / m_stepR);
   if(rung < 1)
      return 0.0;

//--- Lock this far behind the rung that was reached
   double lockR = (rung * m_stepR) - m_lagR;
   if(lockR <= 0)
      return 0.0;

   double lockDistance = lockR * ctx.originalRisk;

   if(ctx.positionType == POSITION_TYPE_BUY)
      return ctx.entryPrice + lockDistance;

   return ctx.entryPrice - lockDistance;
  }

//+------------------------------------------------------------------+
//| CTrailingStop                                                    |
//+------------------------------------------------------------------+
class CTrailingStop
  {
private:
   STrailConfig      m_cfg;
   string            m_symbol;
   CTrade            m_trade;
   CTrailMethod      *m_method;
   bool              m_ownsMethod;
   datetime          m_pausedBar;       // Bar in which the server refused a modification

   //--- Original risk per position, read from history once
   ulong             m_riskIds[];
   double            m_riskValues[];

   double            LookupOriginalRisk(const ulong positionId, const double entryPrice);
   void              PruneRiskCache(const ulong &liveIds[], const int liveCount);

   double            StopsLevelPrice(void) const;
   double            FreezeLevelPrice(void) const;

   bool              IsImprovement(const STrailContext &ctx, const double proposed) const;
   bool              ClearsMinimumStep(const STrailContext &ctx, const double proposed) const;
   bool              RespectsStopsLevel(const STrailContext &ctx, const double proposed) const;
   bool              IsFrozen(const STrailContext &ctx) const;

   double            BreakEvenLevel(const STrailContext &ctx) const;
   bool              ApplyStop(const STrailContext &ctx, const double newStop);

public:
                     CTrailingStop(void);
                    ~CTrailingStop(void);

   //--- Setup
   bool              Init(const STrailConfig &config, const string symbol = NULL);
   bool              Validate(string &error) const;
   bool              RegisterMethod(CTrailMethod *method);

   //--- Evaluate every position this EA holds
   void              Manage(const double atrValue);

   string            MethodName(void) const;
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTrailingStop::CTrailingStop(void)
  {
   m_cfg.SetDefaults();
   m_symbol     = NULL;
   m_method     = NULL;
   m_ownsMethod = false;
   m_pausedBar  = 0;
   ArrayResize(m_riskIds, 0);
   ArrayResize(m_riskValues, 0);
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTrailingStop::~CTrailingStop(void)
  {
   if(m_ownsMethod && CheckPointer(m_method) == POINTER_DYNAMIC)
      delete m_method;

   m_method = NULL;
  }

//+------------------------------------------------------------------+
//| Adopt a configuration and build the selected method              |
//+------------------------------------------------------------------+
bool CTrailingStop::Init(const STrailConfig &config, const string symbol = NULL)
  {
   m_cfg       = config;
   m_symbol    = (symbol == NULL || symbol == "") ? _Symbol : symbol;
   m_pausedBar = 0;

   m_trade.SetExpertMagicNumber(m_cfg.magic);

   string error = "";
   if(!Validate(error))
     {
      Print("CTrailingStop: ", error);
      return false;
     }

   if(m_ownsMethod && CheckPointer(m_method) == POINTER_DYNAMIC)
      delete m_method;
   m_method     = NULL;
   m_ownsMethod = false;

   switch(m_cfg.method)
     {
      case TRAIL_ATR:
         m_method     = new CTrailATR(m_cfg.atrMultiplier);
         m_ownsMethod = true;
         break;
      case TRAIL_RR_LADDER:
         m_method     = new CTrailRRLadder(m_cfg.ladderStepR, m_cfg.ladderLagR);
         m_ownsMethod = true;
         break;
      default:
         break;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Use a method the library does not ship. Call after Init().       |
//+------------------------------------------------------------------+
bool CTrailingStop::RegisterMethod(CTrailMethod *method)
  {
   if(CheckPointer(method) == POINTER_INVALID)
      return false;

   if(m_ownsMethod && CheckPointer(m_method) == POINTER_DYNAMIC)
      delete m_method;

   m_method     = method;
   m_ownsMethod = true;
   return true;
  }

//+------------------------------------------------------------------+
//| Configuration sanity                                             |
//+------------------------------------------------------------------+
bool CTrailingStop::Validate(string &error) const
  {
   error = "";

//--- Nothing will run, so nothing needs checking
   if(m_cfg.method == TRAIL_OFF && !m_cfg.useBreakEven)
      return true;

   if(m_cfg.method == TRAIL_ATR && m_cfg.atrMultiplier <= 0)
     {
      error = "ATR multiplier must be greater than zero.";
      return false;
     }

   if(m_cfg.method == TRAIL_RR_LADDER)
     {
      if(m_cfg.ladderStepR <= 0)
        {
         error = "ladder step (R) must be greater than zero.";
         return false;
        }

      if(m_cfg.ladderLagR < 0)
        {
         error = "ladder lag (R) cannot be negative.";
         return false;
        }
     }

   if(m_cfg.useBreakEven && m_cfg.breakEvenAtR <= 0)
     {
      error = "break-even trigger (R) must be greater than zero.";
      return false;
     }

   if(m_cfg.minStepPoints < 0)
     {
      error = "minimum trailing step cannot be negative.";
      return false;
     }

   if(m_cfg.activateAtR < 0)
     {
      error = "activation threshold (R) cannot be negative.";
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Name of the active method                                        |
//+------------------------------------------------------------------+
string CTrailingStop::MethodName(void) const
  {
   if(CheckPointer(m_method) == POINTER_INVALID)
      return "none";

   return m_method.Name();
  }

//+------------------------------------------------------------------+
//| The risk a position was opened with, in price units              |
//+------------------------------------------------------------------+
double CTrailingStop::LookupOriginalRisk(const ulong positionId, const double entryPrice)
  {
   int cached = ArraySize(m_riskIds);
   for(int i = 0; i < cached; i++)
      if(m_riskIds[i] == positionId)
         return m_riskValues[i];

   if(!HistorySelectByPosition(positionId))
      return 0.0;

//--- The order that opened the position carries the position's identifier as its ticket
   int    orders       = HistoryOrdersTotal();
   bool   found        = false;
   double originalRisk = 0.0;

   for(int i = 0; i < orders; i++)
     {
      if(HistoryOrderGetTicket(i) != positionId)
         continue;

      found = true;
      double orderSL = HistoryOrderGetDouble(positionId, ORDER_SL);
      if(orderSL > 0)
         originalRisk = MathAbs(entryPrice - orderSL);
      break;
     }

//--- Not in history yet: ask again on the next evaluation, cache nothing
   if(!found)
      return 0.0;

   ArrayResize(m_riskIds,    cached + 1);
   ArrayResize(m_riskValues, cached + 1);
   m_riskIds[cached]    = positionId;
   m_riskValues[cached] = originalRisk;

   if(originalRisk <= 0)
      PrintFormat("Position #%I64u was opened without a stop, so R is undefined. R-based features will not act on it.",
                  positionId);

   return originalRisk;
  }

//+------------------------------------------------------------------+
//| Drop cache entries for positions that are no longer open         |
//+------------------------------------------------------------------+
void CTrailingStop::PruneRiskCache(const ulong &liveIds[], const int liveCount)
  {
   int cached = ArraySize(m_riskIds);
   int kept   = 0;

   for(int i = 0; i < cached; i++)
     {
      bool stillOpen = false;
      for(int j = 0; j < liveCount; j++)
         if(liveIds[j] == m_riskIds[i])
           {
            stillOpen = true;
            break;
           }

      if(!stillOpen)
         continue;

      m_riskIds[kept]    = m_riskIds[i];
      m_riskValues[kept] = m_riskValues[i];
      kept++;
     }

   ArrayResize(m_riskIds,    kept);
   ArrayResize(m_riskValues, kept);
  }

//+------------------------------------------------------------------+
//| Broker's minimum stop distance, in price units                   |
//+------------------------------------------------------------------+
double CTrailingStop::StopsLevelPrice(void) const
  {
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   return (double)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;
  }

//+------------------------------------------------------------------+
//| Broker's freeze distance, in price units                         |
//+------------------------------------------------------------------+
double CTrailingStop::FreezeLevelPrice(void) const
  {
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   return (double)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_FREEZE_LEVEL) * point;
  }

//+------------------------------------------------------------------+
//| A stop may only move in the protective direction                 |
//+------------------------------------------------------------------+
bool CTrailingStop::IsImprovement(const STrailContext &ctx, const double proposed) const
  {
   if(ctx.currentSL <= 0)
      return true;

   if(ctx.positionType == POSITION_TYPE_BUY)
      return (proposed > ctx.currentSL);

   return (proposed < ctx.currentSL);
  }

//+------------------------------------------------------------------+
//| Is the improvement large enough to send?                         |
//+------------------------------------------------------------------+
bool CTrailingStop::ClearsMinimumStep(const STrailContext &ctx, const double proposed) const
  {
   if(ctx.currentSL <= 0)
      return true;

   if(m_cfg.minStepPoints <= 0)
      return true;

   double improvement = MathAbs(proposed - ctx.currentSL);
   return (improvement >= m_cfg.minStepPoints * ctx.point);
  }

//+------------------------------------------------------------------+
//| The server rejects a stop too close to, or beyond, the price     |
//+------------------------------------------------------------------+
bool CTrailingStop::RespectsStopsLevel(const STrailContext &ctx, const double proposed) const
  {
//--- Even with no broker minimum, the stop must sit at least a point on the protective side
   double minDistance = MathMax(StopsLevelPrice(), ctx.point);

//--- A buy's stop is tested against Bid, a sell's against Ask
   double distance = (ctx.positionType == POSITION_TYPE_BUY)
                     ? ctx.bid - proposed
                     : proposed - ctx.ask;

   return (distance >= minDistance);
  }

//+------------------------------------------------------------------+
//| Modification is refused while price is inside the freeze level   |
//+------------------------------------------------------------------+
bool CTrailingStop::IsFrozen(const STrailContext &ctx) const
  {
   double freezeLevel = FreezeLevelPrice();
   if(freezeLevel <= 0)
      return false;

   if(ctx.currentSL > 0 && MathAbs(ctx.closePrice - ctx.currentSL) < freezeLevel)
      return true;

   if(ctx.currentTP > 0 && MathAbs(ctx.closePrice - ctx.currentTP) < freezeLevel)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//| Break-even level for this position, or 0 if not reached yet      |
//+------------------------------------------------------------------+
double CTrailingStop::BreakEvenLevel(const STrailContext &ctx) const
  {
   if(!m_cfg.useBreakEven || ctx.originalRisk <= 0)
      return 0.0;

   if(ctx.profitDistance < m_cfg.breakEvenAtR * ctx.originalRisk)
      return 0.0;

   double offset = m_cfg.breakEvenOffsetPoints * ctx.point;

   if(ctx.positionType == POSITION_TYPE_BUY)
      return ctx.entryPrice + offset;

   return ctx.entryPrice - offset;
  }

//+------------------------------------------------------------------+
//| Send the modification, keeping the existing take-profit          |
//+------------------------------------------------------------------+
bool CTrailingStop::ApplyStop(const STrailContext &ctx, const double newStop)
  {
   double normalized = NormalizeDouble(newStop, ctx.digits);

   if(ctx.currentSL > 0 && MathAbs(normalized - ctx.currentSL) < ctx.point / 2.0)
      return false;

   if(!m_trade.PositionModify(ctx.ticket, normalized, ctx.currentTP))
     {
      //--- A refusal rarely clears on the next tick, so wait for the next bar
      m_pausedBar = iTime(m_symbol, PERIOD_CURRENT, 0);
      PrintFormat("Trailing: modifying #%I64u to %.*f was refused. Retcode: %u (%s). Paused until the next bar.",
                  ctx.ticket, ctx.digits, normalized,
                  m_trade.ResultRetcode(), m_trade.ResultRetcodeDescription());
      return false;
     }

   if(m_cfg.verbose)
     {
      double movedPoints = (ctx.currentSL > 0)
                           ? MathAbs(normalized - ctx.currentSL) / ctx.point
                           : 0.0;
      PrintFormat("Trailing [%s]: #%I64u stop %.*f -> %.*f (+%.1f pts)",
                  MethodName(), ctx.ticket,
                  ctx.digits, ctx.currentSL, ctx.digits, normalized, movedPoints);
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Evaluate every position this EA holds on its symbol              |
//+------------------------------------------------------------------+
void CTrailingStop::Manage(const double atrValue)
  {
   bool hasMethod = (CheckPointer(m_method) != POINTER_INVALID);
   if(!hasMethod && !m_cfg.useBreakEven)
      return;

//--- After a refusal, nothing is sent again until a new bar opens
   if(m_pausedBar != 0 && iTime(m_symbol, PERIOD_CURRENT, 0) == m_pausedBar)
      return;

   MqlTick tick;
   if(!SymbolInfoTick(m_symbol, tick))
      return;

   double point  = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   int    digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);

   bool needsRisk = m_cfg.useBreakEven || m_cfg.activateAtR > 0 ||
                    (hasMethod && m_method.NeedsOriginalRisk());

   ulong liveIds[];
   int   liveCount = 0;
   ArrayResize(liveIds, PositionsTotal());

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != m_symbol ||
         PositionGetInteger(POSITION_MAGIC) != m_cfg.magic)
         continue;

      ulong positionId = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
      liveIds[liveCount] = positionId;
      liveCount++;

      STrailContext ctx;
      ctx.symbol       = m_symbol;
      ctx.ticket       = ticket;
      ctx.positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      ctx.entryPrice   = PositionGetDouble(POSITION_PRICE_OPEN);
      ctx.currentSL    = PositionGetDouble(POSITION_SL);
      ctx.currentTP    = PositionGetDouble(POSITION_TP);
      ctx.bid          = tick.bid;
      ctx.ask          = tick.ask;
      ctx.atrValue     = atrValue;
      ctx.point        = point;
      ctx.digits       = digits;

      //--- A long closes on Bid, a short on Ask
      ctx.closePrice     = (ctx.positionType == POSITION_TYPE_BUY) ? tick.bid : tick.ask;
      ctx.profitDistance = (ctx.positionType == POSITION_TYPE_BUY)
                           ? ctx.closePrice - ctx.entryPrice
                           : ctx.entryPrice - ctx.closePrice;

      ctx.originalRisk = needsRisk ? LookupOriginalRisk(positionId, ctx.entryPrice) : 0.0;

      //--- Nothing acts until the position has reached the activation level
      if(m_cfg.activateAtR > 0)
        {
         if(ctx.originalRisk <= 0 || ctx.profitDistance < m_cfg.activateAtR * ctx.originalRisk)
            continue;
        }

      //--- Break-even is a floor; the method's proposal is used only when it is better
      double candidate = hasMethod ? m_method.ComputeStopLevel(ctx) : 0.0;
      double breakEven = BreakEvenLevel(ctx);

      if(breakEven > 0)
        {
         if(candidate <= 0)
            candidate = breakEven;
         else
            candidate = (ctx.positionType == POSITION_TYPE_BUY)
                        ? MathMax(candidate, breakEven)
                        : MathMin(candidate, breakEven);
        }

      if(candidate <= 0)
         continue;

      //--- Four guards, cheapest rejection first
      if(!IsImprovement(ctx, candidate))
         continue;

      if(!ClearsMinimumStep(ctx, candidate))
         continue;

      if(!RespectsStopsLevel(ctx, candidate))
         continue;

      if(IsFrozen(ctx))
        {
         if(m_cfg.verbose)
            PrintFormat("Trailing: #%I64u is inside the freeze level, modification not permitted right now.",
                        ticket);
         continue;
        }

      ApplyStop(ctx, candidate);
     }

   PruneRiskCache(liveIds, liveCount);
  }

#endif // RISKMANAGEMENT_TRAILINGSTOP_MQH
//+------------------------------------------------------------------+
