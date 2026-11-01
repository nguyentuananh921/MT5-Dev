//+------------------------------------------------------------------+
//|                                                    TradeRisk.mqh |
//|                                    Copyright 2026, soloharbinger |
//|                      https://www.mql5.com/en/users/soloharbinger |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, soloharbinger"
#property link      "https://www.mql5.com/en/users/soloharbinger"
#property description "Tier one of the risk framework: the individual trade. Containing risk-based sizing, drawdown scaling, volume rules, margin, broker validation, risk models, and order types"

#ifndef RISKMANAGEMENT_TRADERISK_MQH
#define RISKMANAGEMENT_TRADERISK_MQH

#include <Trade/Trade.mqh>
#include "RiskTypes.mqh"

//+------------------------------------------------------------------+
//| CTradeRisk                                                       |
//+------------------------------------------------------------------+
class CTradeRisk
  {
private:
   SRiskConfig       m_cfg;
   string            m_symbol;
   CTrade            m_trade;
   double            m_peakEquity;
   bool              m_ready;

   //--- Sizing internals
   double            DrawdownFactor(void);
   double            RiskAmount(void);
   double            CalculateLotSize(const double stopDistance, const double riskAmount);

   //--- Broker constraint internals
   double            MarginUsageCap(void);
   double            CapLotToMargin(const ENUM_ORDER_TYPE orderType, const double lotSize,
                                    const double price);

   //--- Order construction internals
   ENUM_ORDER_TYPE   ResolveOrderType(const int direction) const;
   double            PendingOffset(const double atrValue) const;
   double            ResolveEntryPrice(const ENUM_ORDER_TYPE orderType, const double atrValue,
                                       const MqlTick &tick) const;
   double            MinStopDistance(const MqlTick &tick) const;
   bool              IsPendingDistanceValid(const STradePlan &plan, const MqlTick &tick) const;

public:
                     CTradeRisk(void);

   //--- Setup
   bool              Init(const SRiskConfig &config, const string symbol = NULL);
   bool              Validate(string &error) const;
   bool              IsReady(void) const { return m_ready; }

   //--- Per-bar housekeeping
   void              ManagePendingOrders(void);

   //--- Exposure counting, shared with the higher tiers
   int               CountPositions(void) const;
   int               CountPositionsByDirection(const int direction) const;
   int               CountPendingOrders(void) const;
   int               CountPendingOrdersByDirection(const int direction) const;

   //--- The pipeline
   bool              BuildPlan(const int direction, const double atrValue,
                               const MqlTick &tick, STradePlan &plan);
   bool              ValidatePlan(STradePlan &plan, const MqlTick &tick);
   bool              ExecutePlan(const STradePlan &plan);

   //--- Diagnostics
   double            CurrentRiskAmount(void) { return RiskAmount(); }
   CTrade            *Trade(void) { return GetPointer(m_trade); }
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeRisk::CTradeRisk(void)
  {
   m_cfg.SetDefaults();
   m_symbol     = NULL;
   m_peakEquity = 0.0;
   m_ready      = false;
  }

//+------------------------------------------------------------------+
//| Adopt a configuration                                            |
//+------------------------------------------------------------------+
bool CTradeRisk::Init(const SRiskConfig &config, const string symbol = NULL)
  {
   m_cfg    = config;
   m_symbol = (symbol == NULL || symbol == "") ? _Symbol : symbol;

   m_trade.SetExpertMagicNumber(m_cfg.magic);

   string error = "";
   if(!Validate(error))
     {
      Print("CTradeRisk: ", error);
      m_ready = false;
      return false;
     }

   m_ready = true;
   return true;
  }

//+------------------------------------------------------------------+
//| Check the configuration before the EA is allowed to trade.       |
//+------------------------------------------------------------------+
bool CTradeRisk::Validate(string &error) const
  {
   error = "";

   if(m_cfg.riskMode == RISK_PERCENT && m_cfg.riskPercent <= 0)
     {
      error = "risk percent must be greater than zero in percentage mode.";
      return false;
     }

   if(m_cfg.riskMode == RISK_FIXED_CASH && m_cfg.fixedCashRisk <= 0)
     {
      error = "fixed cash risk must be greater than zero in cash mode.";
      return false;
     }

   if(m_cfg.riskMode == RISK_FIXED_LOT && m_cfg.fixedLotSize <= 0)
     {
      error = "fixed lot size must be greater than zero in fixed-lot mode.";
      return false;
     }

   if(m_cfg.stopATRMultiplier <= 0 || m_cfg.tpRatio <= 0)
     {
      error = "stop multiplier and take-profit ratio must be greater than zero.";
      return false;
     }

   if(m_cfg.maxMarginUsagePercent <= 0 || m_cfg.maxMarginUsagePercent > 100)
     {
      error = "max margin usage must be between 0 and 100.";
      return false;
     }

   if(m_cfg.enableAdaptiveMarginCap && m_cfg.marginLevelSafe <= m_cfg.marginLevelDanger)
     {
      error = "margin safe level must be greater than the danger level.";
      return false;
     }

   if(m_cfg.entryMode != ENTRY_MARKET)
     {
      if(m_cfg.offsetMode == OFFSET_ATR && m_cfg.pendingOffsetATR <= 0)
        {
         error = "pending offset (ATR multiple) must be greater than zero.";
         return false;
        }

      if(m_cfg.offsetMode == OFFSET_POINTS && m_cfg.pendingOffsetPoints <= 0)
        {
         error = "pending offset (points) must be greater than zero.";
         return false;
        }

      if(m_cfg.pendingExpiryBars < 0)
        {
         error = "pending expiry bars cannot be negative.";
         return false;
        }
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Drawdown-based risk factor [1.0 = no reduction].                 |
//| Shared by every risk mode, so the rule is written once.          |
//+------------------------------------------------------------------+
double CTradeRisk::DrawdownFactor(void)
  {
   if(!m_cfg.enableDrawdownScaling)
      return 1.0;

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);

   if(m_peakEquity == 0.0 || equity > m_peakEquity)
      m_peakEquity = equity;

   double drawdownPercent = 0.0;
   if(m_peakEquity > 0.0)
      drawdownPercent = (m_peakEquity - equity) / m_peakEquity * 100.0;

   if(drawdownPercent >= m_cfg.drawdownTrigger)
     {
      PrintFormat("Adaptive Risk | Drawdown: %.2f%% >= %.2f%% | Risk scaled by %.2f",
                  drawdownPercent, m_cfg.drawdownTrigger, m_cfg.drawdownFactor);
      return m_cfg.drawdownFactor;
     }

   return 1.0;
  }

//+------------------------------------------------------------------+
//| The monetary amount to risk, in account currency.                |
//+------------------------------------------------------------------+
double CTradeRisk::RiskAmount(void)
  {
   double amount = 0.0;

   if(m_cfg.riskMode == RISK_FIXED_CASH)
      amount = m_cfg.fixedCashRisk;
   else
      amount = AccountValueByBase(m_cfg.riskBase) * (m_cfg.riskPercent / 100.0);

   return amount * DrawdownFactor();
  }

//+------------------------------------------------------------------+
//| Convert a risk amount and stop distance into a tradable volume.  |
//+------------------------------------------------------------------+
double CTradeRisk::CalculateLotSize(const double stopDistance, const double riskAmount)
  {
   double minLot  = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);

   if(minLot <= 0 || lotStep <= 0 || maxLot < minLot)
     {
      Print("Invalid broker volume specification. Cannot calculate lot size.");
      return 0.0;
     }

//--- Fixed-lot mode never consults the risk budget
   if(m_cfg.riskMode == RISK_FIXED_LOT)
     {
      double rawLot = m_cfg.fixedLotSize;

      if(m_cfg.enableDrawdownScaling && m_cfg.applyDrawdownToFixedLot)
        {
         double factor = DrawdownFactor();
         if(factor < 1.0)
           {
            PrintFormat("Fixed lot %.2f scaled by drawdown factor %.2f.", rawLot, factor);
            rawLot *= factor;
           }
        }

      double fixedLot = FloorToVolumeStep(rawLot, lotStep);
      if(fixedLot > maxLot)
         fixedLot = FloorToVolumeStep(maxLot, lotStep);

      //--- Below the minimum lot, the same switch decides as in the other modes
      if(fixedLot < minLot)
        {
         if(!m_cfg.allowMinLotOverRisk)
           {
            PrintFormat("Fixed lot (%.4f) is below the minimum lot (%.2f). Trade skipped.",
                        rawLot, minLot);
            return 0.0;
           }

         PrintFormat("Caution: fixed lot (%.4f) is below the minimum lot (%.2f). Trading %.2f.",
                     rawLot, minLot, minLot);
         fixedLot = minLot;
        }

      return fixedLot;
     }

//--- Every other mode is the same conversion
   if(stopDistance <= 0)
     {
      Print("Stop distance is zero. Cannot calculate lot size.");
      return 0.0;
     }

   return VolumeForMoneyAndDistance(m_symbol, riskAmount, stopDistance,
                                    m_cfg.allowMinLotOverRisk);
  }

//+------------------------------------------------------------------+
//| How much of free margin one trade may consume.                   |
//+------------------------------------------------------------------+
double CTradeRisk::MarginUsageCap(void)
  {
   if(!m_cfg.enableAdaptiveMarginCap)
      return m_cfg.maxMarginUsagePercent;

//--- Flat account: the margin level reading is not meaningful yet
   if(AccountInfoDouble(ACCOUNT_MARGIN) <= 0.0)
      return m_cfg.maxMarginUsagePercent;

   double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);

   if(marginLevel <= m_cfg.marginLevelDanger)
     {
      PrintFormat("Adaptive Margin Cap | Margin Level: %.1f%% at/below danger threshold (%.1f%%). New trades blocked.",
                  marginLevel, m_cfg.marginLevelDanger);
      return 0.0;
     }

   if(marginLevel >= m_cfg.marginLevelSafe)
      return m_cfg.maxMarginUsagePercent;

   double ratio = (marginLevel - m_cfg.marginLevelDanger)
                  / (m_cfg.marginLevelSafe - m_cfg.marginLevelDanger);
   double cap = m_cfg.maxMarginUsagePercent * ratio;

   PrintFormat("Adaptive Margin Cap | Margin Level: %.1f%% | Cap Scaled To: %.1f%% (baseline %.1f%%)",
               marginLevel, cap, m_cfg.maxMarginUsagePercent);

   return cap;
  }

//+------------------------------------------------------------------+
//| Cap a volume to what free margin can safely support.             |
//+------------------------------------------------------------------+
double CTradeRisk::CapLotToMargin(const ENUM_ORDER_TYPE orderType, const double lotSize,
                                  const double price)
  {
//--- Market-order margin scales linearly with volume
   double marginPerLot = 0.0;
   ResetLastError();
   if(!OrderCalcMargin(orderType, m_symbol, 1.0, price, marginPerLot) || marginPerLot <= 0.0)
     {
      PrintFormat("OrderCalcMargin() failed for %s. Error %d", m_symbol, GetLastError());
      return 0.0;
     }

   double capPercent = MarginUsageCap();
   if(capPercent <= 0.0)
     {
      Print("Margin check: account margin level is too low for new exposure. Trade skipped.");
      return 0.0;
     }

   double freeMargin    = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double usedMargin    = AccountInfoDouble(ACCOUNT_MARGIN);
   double allowedMargin = freeMargin * (capPercent / 100.0);

   double minLot  = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
   double lotStep = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);

   double maxAffordable = FloorToVolumeStep(allowedMargin / marginPerLot, lotStep);

   if(maxAffordable < minLot)
     {
      //--- Leverage and contract size aren't used in the calculation directly
      long   leverage     = AccountInfoInteger(ACCOUNT_LEVERAGE);
      double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
      PrintFormat("Margin check: cannot safely support even the minimum lot (%.2f).", minLot);
      PrintFormat("Free: %.2f | Used: %.2f | Leverage: 1:%d | Contract Size: %.0f. Trade skipped.",
                  freeMargin, usedMargin, (int)leverage, contractSize);
      return 0.0;
     }

   if(lotSize > maxAffordable)
     {
      PrintFormat("Margin check: risk-based lot %.2f exceeds the %.1f%% margin-usage cap.", lotSize, capPercent);
      PrintFormat("Free: %.2f | Used: %.2f | %.2f lots affordable. Reducing to %.2f.",
                  freeMargin, usedMargin, maxAffordable, maxAffordable);
      return maxAffordable;
     }
   return lotSize;
  }

//+------------------------------------------------------------------+
//| Concrete order type from direction and entry mode                |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE CTradeRisk::ResolveOrderType(const int direction) const
  {
   if(direction == 1)
     {
      switch(m_cfg.entryMode)
        {
         case ENTRY_LIMIT:
            return ORDER_TYPE_BUY_LIMIT;
         case ENTRY_STOP:
            return ORDER_TYPE_BUY_STOP;
         default:
            return ORDER_TYPE_BUY;
        }
     }

   switch(m_cfg.entryMode)
     {
      case ENTRY_LIMIT:
         return ORDER_TYPE_SELL_LIMIT;
      case ENTRY_STOP:
         return ORDER_TYPE_SELL_STOP;
      default:
         return ORDER_TYPE_SELL;
     }
  }

//+------------------------------------------------------------------+
//| Distance a pending entry sits from the current market            |
//+------------------------------------------------------------------+
double CTradeRisk::PendingOffset(const double atrValue) const
  {
   if(m_cfg.offsetMode == OFFSET_POINTS)
      return m_cfg.pendingOffsetPoints * SymbolInfoDouble(m_symbol, SYMBOL_POINT);

   return atrValue * m_cfg.pendingOffsetATR;
  }

//+------------------------------------------------------------------+
//| The price this trade actually intends to enter at.               |
//+------------------------------------------------------------------+
double CTradeRisk::ResolveEntryPrice(const ENUM_ORDER_TYPE orderType, const double atrValue,
                                     const MqlTick &tick) const
  {
   double offset = PendingOffset(atrValue);

   switch(orderType)
     {
      //--- Buys fill at Ask, sells at Bid
      case ORDER_TYPE_BUY:
         return tick.ask;
      case ORDER_TYPE_SELL:
         return tick.bid;

      //--- Limit orders wait for a better price than the market offers
      case ORDER_TYPE_BUY_LIMIT:
         return tick.ask - offset;
      case ORDER_TYPE_SELL_LIMIT:
         return tick.bid + offset;

      //--- Stop orders wait for confirmation in the signal's direction
      case ORDER_TYPE_BUY_STOP:
         return tick.ask + offset;
      case ORDER_TYPE_SELL_STOP:
         return tick.bid - offset;
     }

   return 0.0;
  }

//+------------------------------------------------------------------+
//| Smallest stop distance the broker will accept.                   |
//+------------------------------------------------------------------+
double CTradeRisk::MinStopDistance(const MqlTick &tick) const
  {
   double point      = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   double stopsLevel = (double)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;
   double spread     = tick.ask - tick.bid;

   if(spread < 0)
      spread = 0;

   return stopsLevel + spread;
  }

//+------------------------------------------------------------------+
//| A pending entry must sit far enough from the current price       |
//+------------------------------------------------------------------+
bool CTradeRisk::IsPendingDistanceValid(const STradePlan &plan, const MqlTick &tick) const
  {
   double point      = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   double stopsLevel = (double)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;
   double distance   = 0.0;

   switch(plan.orderType)
     {
      case ORDER_TYPE_BUY_LIMIT:
         distance = tick.ask - plan.entryPrice;
         break;
      case ORDER_TYPE_SELL_LIMIT:
         distance = plan.entryPrice - tick.bid;
         break;
      case ORDER_TYPE_BUY_STOP:
         distance = plan.entryPrice - tick.ask;
         break;
      case ORDER_TYPE_SELL_STOP:
         distance = tick.bid - plan.entryPrice;
         break;
      default:
         return true;
     }

   if(distance < stopsLevel)
     {
      PrintFormat("Pending entry sits %.1f points from market, broker minimum is %.1f. Trade skipped.",
                  distance / point, stopsLevel / point);
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Count this EA's open positions on its symbol                     |
//+------------------------------------------------------------------+
int CTradeRisk::CountPositions(void) const
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) == m_symbol &&
         PositionGetInteger(POSITION_MAGIC) == m_cfg.magic)
         count++;
     }
   return count;
  }

//+------------------------------------------------------------------+
//| Count open positions in one direction                            |
//+------------------------------------------------------------------+
int CTradeRisk::CountPositionsByDirection(const int direction) const
  {
   int count = 0;
   ENUM_POSITION_TYPE wanted = (direction == 1) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) == m_symbol &&
         PositionGetInteger(POSITION_MAGIC) == m_cfg.magic &&
         PositionGetInteger(POSITION_TYPE) == wanted)
         count++;
     }
   return count;
  }

//+------------------------------------------------------------------+
//| Count this EA's pending orders                                   |
//+------------------------------------------------------------------+
int CTradeRisk::CountPendingOrders(void) const
  {
   int count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) == m_symbol &&
         OrderGetInteger(ORDER_MAGIC) == m_cfg.magic)
         count++;
     }
   return count;
  }

//+------------------------------------------------------------------+
//| Count pending orders in one direction                            |
//+------------------------------------------------------------------+
int CTradeRisk::CountPendingOrdersByDirection(const int direction) const
  {
   int count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != m_symbol ||
         OrderGetInteger(ORDER_MAGIC) != m_cfg.magic)
         continue;

      if(OrderTypeDirection((ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE)) == direction)
         count++;
     }
   return count;
  }

//+------------------------------------------------------------------+
//| Delete pending orders that never triggered.                      |
//+------------------------------------------------------------------+
void CTradeRisk::ManagePendingOrders(void)
  {
   if(m_cfg.pendingExpiryBars <= 0)
      return;

   int barSeconds = PeriodSeconds(_Period);
   if(barSeconds <= 0)
      return;

   datetime now = TimeCurrent();

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != m_symbol ||
         OrderGetInteger(ORDER_MAGIC) != m_cfg.magic)
         continue;

      datetime setupTime = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
      if(setupTime <= 0 || now <= setupTime)
         continue;

      int barsElapsed = (int)((now - setupTime) / barSeconds);
      if(barsElapsed < m_cfg.pendingExpiryBars)
         continue;

      if(m_trade.OrderDelete(ticket))
         PrintFormat("Pending order #%I64u expired after %d bars (limit %d). Deleted.",
                     ticket, barsElapsed, m_cfg.pendingExpiryBars);
      else
         PrintFormat("Failed to delete expired pending order #%I64u. Retcode: %u (%s)",
                     ticket, m_trade.ResultRetcode(), m_trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//| Build a complete trade plan.                                     |
//+------------------------------------------------------------------+
bool CTradeRisk::BuildPlan(const int direction, const double atrValue,
                           const MqlTick &tick, STradePlan &plan)
  {
   ZeroMemory(plan);

   if(!m_ready)
     {
      Print("CTradeRisk is not initialised. Trade skipped.");
      return false;
     }

   plan.direction = direction;
   plan.orderType = ResolveOrderType(direction);
   plan.isPending = (m_cfg.entryMode != ENTRY_MARKET);

   int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);

//--- Anchored to the intended entry, not the current market price
   plan.entryPrice = ResolveEntryPrice(plan.orderType, atrValue, tick);
   if(plan.entryPrice <= 0)
     {
      Print("Failed to resolve an entry price. Trade skipped.");
      return false;
     }
   plan.entryPrice = NormalizeDouble(plan.entryPrice, digits);

   double stopDistance = atrValue * m_cfg.stopATRMultiplier;
   double minStop      = MinStopDistance(tick);

   if(stopDistance < minStop)
     {
      PrintFormat("Stop distance %.1f points is below the broker minimum %.1f (stops level + spread). Widening.",
                  stopDistance / point, minStop / point);
      stopDistance = minStop;
     }

   if(direction == 1)
     {
      plan.stopLoss   = NormalizeDouble(plan.entryPrice - stopDistance, digits);
      plan.takeProfit = NormalizeDouble(plan.entryPrice + (stopDistance * m_cfg.tpRatio), digits);
     }
   else
     {
      plan.stopLoss   = NormalizeDouble(plan.entryPrice + stopDistance, digits);
      plan.takeProfit = NormalizeDouble(plan.entryPrice - (stopDistance * m_cfg.tpRatio), digits);
     }

//--- Re-derive the sizing distance from the plan's own entry and stop.
   plan.stopDistance = MathAbs(plan.entryPrice - plan.stopLoss);
   if(plan.stopDistance <= 0)
     {
      Print("Entry and stop resolved to the same price. Trade skipped.");
      return false;
     }

   plan.riskAmount = (m_cfg.riskMode == RISK_FIXED_LOT) ? 0.0 : RiskAmount();
   plan.lotSize    = CalculateLotSize(plan.stopDistance, plan.riskAmount);

   if(plan.lotSize <= 0)
     {
      Print("Position sizing produced no tradable volume. Trade skipped.");
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Trade-level validation against live broker and account state.    |
//+------------------------------------------------------------------+
bool CTradeRisk::ValidatePlan(STradePlan &plan, const MqlTick &tick)
  {
   if(!m_ready)
      return false;

//--- Direction rules: may this trade exist alongside what is open?
   if(m_cfg.allowHedging)
     {
      if(CountPositionsByDirection(plan.direction) > 0 ||
         CountPendingOrdersByDirection(plan.direction) > 0)
         return false;
     }
   else
     {
      if(CountPositions() > 0 || CountPendingOrders() > 0)
         return false;
     }

//--- A pending entry too close to market is rejected by the server
   if(plan.isPending && !IsPendingDistanceValid(plan, tick))
      return false;

//--- Margin is priced for the position this order will become, at the price it intends to become it
   double capped = CapLotToMargin(MarketOrderTypeOf(plan.orderType),
                                  plan.lotSize, plan.entryPrice);
   if(capped <= 0)
     {
      Print("Trade skipped: insufficient free margin to safely open a position.");
      return false;
     }

   plan.lotSize = capped;
   return true;
  }

//+------------------------------------------------------------------+
//| Send the validated plan.                                         |
//+------------------------------------------------------------------+
bool CTradeRisk::ExecutePlan(const STradePlan &plan)
  {
   string comment = (plan.direction == 1) ? "SoloEA Buy" : "SoloEA Sell";
   bool   sent    = false;

   switch(plan.orderType)
     {
      case ORDER_TYPE_BUY:
         sent = m_trade.Buy(plan.lotSize, m_symbol, 0.0, plan.stopLoss, plan.takeProfit, comment);
         break;
      case ORDER_TYPE_SELL:
         sent = m_trade.Sell(plan.lotSize, m_symbol, 0.0, plan.stopLoss, plan.takeProfit, comment);
         break;
      case ORDER_TYPE_BUY_LIMIT:
         sent = m_trade.BuyLimit(plan.lotSize, plan.entryPrice, m_symbol,
                                 plan.stopLoss, plan.takeProfit, ORDER_TIME_GTC, 0, comment);
         break;
      case ORDER_TYPE_SELL_LIMIT:
         sent = m_trade.SellLimit(plan.lotSize, plan.entryPrice, m_symbol,
                                  plan.stopLoss, plan.takeProfit, ORDER_TIME_GTC, 0, comment);
         break;
      case ORDER_TYPE_BUY_STOP:
         sent = m_trade.BuyStop(plan.lotSize, plan.entryPrice, m_symbol,
                                plan.stopLoss, plan.takeProfit, ORDER_TIME_GTC, 0, comment);
         break;
      case ORDER_TYPE_SELL_STOP:
         sent = m_trade.SellStop(plan.lotSize, plan.entryPrice, m_symbol,
                                 plan.stopLoss, plan.takeProfit, ORDER_TIME_GTC, 0, comment);
         break;
      default:
         Print("Unsupported order type in trade plan. Nothing sent.");
         return false;
     }

   if(!sent)
     {
      PrintFormat("%s failed. Retcode: %u (%s)", EnumToString(plan.orderType),
                  m_trade.ResultRetcode(), m_trade.ResultRetcodeDescription());
      return false;
     }

   int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   PrintFormat("%s placed | Lot: %.2f | Entry: %.*f | SL: %.*f | TP: %.*f | Stop: %.1f pts | Intended risk: %.2f",
               EnumToString(plan.orderType), plan.lotSize,
               digits, plan.entryPrice, digits, plan.stopLoss, digits, plan.takeProfit,
               plan.stopDistance / point, plan.riskAmount);

   return true;
  }

#endif // RISKMANAGEMENT_TRADERISK_MQH
//+------------------------------------------------------------------+
