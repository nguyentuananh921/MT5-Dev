//+------------------------------------------------------------------+
//|                                                   BasketRisk.mqh |
//|                                    Copyright 2026, soloharbinger |
//|                      https://www.mql5.com/en/users/soloharbinger |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, soloharbinger"
#property link        "https://www.mql5.com/en/users/soloharbinger"
#property description "Tier two of the risk framework: the basket. The moment an EA can hold more than one position, the individual trade stops being the unit of risk."

#ifndef RISKMANAGEMENT_BASKETRISK_MQH
#define RISKMANAGEMENT_BASKETRISK_MQH

#include <Trade/Trade.mqh>
#include "RiskTypes.mqh"

//+------------------------------------------------------------------+
//| CBasketRisk                                                      |
//+------------------------------------------------------------------+
class CBasketRisk
  {
private:
   SBasketConfig     m_cfg;
   string            m_symbol;
   CTrade            m_trade;

   //--- Running statistics, in memory only. A terminal restart resets
   //--- these: the positions survive, the measurement of them does not.
   double            m_maxAdverse;
   double            m_maxFavourable;
   int               m_peakCount;

   void              UpdateExcursion(const SBasketState &basketState);

public:
                     CBasketRisk(void);

   //--- Setup
   bool              Init(const SBasketConfig &config, const string symbol = NULL);
   bool              Validate(string &error) const;

   //--- Measurement
   bool              GetState(SBasketState &basketState) const;

   //--- Per-bar protection
   void              Manage(void);

   //--- Gate. Answers whether the basket can carry one more trade.
   bool              AcceptsNewTrade(const STradePlan &plan, const int pendingCount = 0);

   //--- Actions
   void              CloseAll(const string reason);
   void              ResetTracking(void);

   //--- Diagnostics
   double            MaxAdverseExcursion(void) const { return m_maxAdverse; }
   double            MaxFavourableExcursion(void) const { return m_maxFavourable; }
   int               PeakPositionCount(void) const { return m_peakCount; }
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CBasketRisk::CBasketRisk(void)
  {
   m_cfg.SetDefaults();
   m_symbol        = NULL;
   m_maxAdverse    = 0.0;
   m_maxFavourable = 0.0;
   m_peakCount     = 0;
  }

//+------------------------------------------------------------------+
//| Adopt a configuration                                            |
//+------------------------------------------------------------------+
bool CBasketRisk::Init(const SBasketConfig &config, const string symbol = NULL)
  {
   m_cfg    = config;
   m_symbol = (symbol == NULL || symbol == "") ? _Symbol : symbol;

   m_trade.SetExpertMagicNumber(m_cfg.magic);

   string error = "";
   if(!Validate(error))
     {
      Print("CBasketRisk: ", error);
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Configuration sanity                                             |
//+------------------------------------------------------------------+
bool CBasketRisk::Validate(string &error) const
  {
   error = "";

   if(!m_cfg.enabled)
      return true;

   if(m_cfg.maxPositions < 1)
     {
      error = "max basket positions must be at least 1.";
      return false;
     }

   if(m_cfg.maxLossPercent < 0 || m_cfg.maxLossPercent > 100)
     {
      error = "max basket loss percent must be between 0 and 100.";
      return false;
     }

   if(m_cfg.maxMarginPercent < 0 || m_cfg.maxMarginPercent > 100)
     {
      error = "max basket margin percent must be between 0 and 100.";
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Aggregate every position this EA holds into a single view.       |
//+------------------------------------------------------------------+
bool CBasketRisk::GetState(SBasketState &basketState) const
  {
   ZeroMemory(basketState);

   double weightedEntrySum = 0.0;
   double signedVolume     = 0.0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != m_symbol ||
         PositionGetInteger(POSITION_MAGIC) != m_cfg.magic)
         continue;

      double volume    = PositionGetDouble(POSITION_VOLUME);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      basketState.positionCount++;
      basketState.totalVolume += volume;

      //--- Carrying cost is part of what a basket costs
      basketState.floatingPL += PositionGetDouble(POSITION_PROFIT)
                           + PositionGetDouble(POSITION_SWAP);

      weightedEntrySum += openPrice * volume;
      signedVolume     += (posType == POSITION_TYPE_BUY) ? volume : -volume;

      double legMargin = 0.0;
      ENUM_ORDER_TYPE asOrder = (posType == POSITION_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      if(OrderCalcMargin(asOrder, m_symbol, volume, openPrice, legMargin))
         basketState.usedMargin += legMargin;

      datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
      if(basketState.oldestOpenTime == 0 || openTime < basketState.oldestOpenTime)
         basketState.oldestOpenTime = openTime;
     }

   if(basketState.positionCount == 0)
      return false;

   if(basketState.totalVolume > 0)
      basketState.weightedEntryPrice = weightedEntrySum / basketState.totalVolume;

//--- Net direction
   if(signedVolume > 0)
      basketState.netDirection = 1;
   else
      if(signedVolume < 0)
         basketState.netDirection = -1;

   return true;
  }

//+------------------------------------------------------------------+
//| Track how far the basket travels against and in favour of us.    |
//+------------------------------------------------------------------+
void CBasketRisk::UpdateExcursion(const SBasketState &basketState)
  {
   if(!m_cfg.trackExcursion)
      return;

   if(basketState.positionCount > m_peakCount)
      m_peakCount = basketState.positionCount;

   if(basketState.floatingPL < 0 && MathAbs(basketState.floatingPL) > m_maxAdverse)
      m_maxAdverse = MathAbs(basketState.floatingPL);

   if(basketState.floatingPL > m_maxFavourable)
      m_maxFavourable = basketState.floatingPL;
  }

//+------------------------------------------------------------------+
//| Report what the closed basket did, then start clean              |
//+------------------------------------------------------------------+
void CBasketRisk::ResetTracking(void)
  {
   if(m_peakCount > 0)
      PrintFormat("Basket closed | Peak positions: %d | Max adverse excursion: %.2f | Max favourable: %.2f",
                  m_peakCount, m_maxAdverse, m_maxFavourable);

   m_maxAdverse    = 0.0;
   m_maxFavourable = 0.0;
   m_peakCount     = 0;
  }

//+------------------------------------------------------------------+
//| Close every position and pending order this EA holds             |
//+------------------------------------------------------------------+
void CBasketRisk::CloseAll(const string reason)
  {
   PrintFormat("BASKET CLOSE | %s", reason);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != m_symbol ||
         PositionGetInteger(POSITION_MAGIC) != m_cfg.magic)
         continue;

      if(!m_trade.PositionClose(ticket))
         PrintFormat("Failed to close position #%I64u. Retcode: %u (%s)",
                     ticket, m_trade.ResultRetcode(), m_trade.ResultRetcodeDescription());
     }

//--- A pending order belonging to a cut basket is orphaned intent
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != m_symbol ||
         OrderGetInteger(ORDER_MAGIC) != m_cfg.magic)
         continue;

      if(!m_trade.OrderDelete(ticket))
         PrintFormat("Failed to delete pending order #%I64u. Retcode: %u (%s)",
                     ticket, m_trade.ResultRetcode(), m_trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//| Basket-level protection, evaluated once per bar.                 |
//+------------------------------------------------------------------+
void CBasketRisk::Manage(void)
  {
   if(!m_cfg.enabled)
      return;

   SBasketState basketState;
   if(!GetState(basketState))
     {
      ResetTracking();
      return;
     }

   UpdateExcursion(basketState);

//--- Aggregate loss cut
   if(m_cfg.maxLossPercent > 0)
     {
      double maxLoss = AccountValueByBase(m_cfg.lossBase) * (m_cfg.maxLossPercent / 100.0);

      if(basketState.floatingPL <= -maxLoss)
        {
         CloseAll(StringFormat("Aggregate loss %.2f breached the %.1f%% limit (%.2f) across %d position(s).",
                               basketState.floatingPL, m_cfg.maxLossPercent, maxLoss, basketState.positionCount));
         ResetTracking();
         return;
        }
     }

//--- Time stop.
   if(m_cfg.maxHoldBars > 0 && basketState.floatingPL < 0 && basketState.oldestOpenTime > 0)
     {
      int barSeconds = PeriodSeconds(_Period);
      if(barSeconds > 0)
        {
         int barsHeld = (int)((TimeCurrent() - basketState.oldestOpenTime) / barSeconds);
         if(barsHeld >= m_cfg.maxHoldBars)
           {
            CloseAll(StringFormat("Held %d bars while losing %.2f (limit %d bars).",
                                  barsHeld, basketState.floatingPL, m_cfg.maxHoldBars));
            ResetTracking();
            return;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Would adding this trade push the basket past its limits?         |
//+------------------------------------------------------------------+
bool CBasketRisk::AcceptsNewTrade(const STradePlan &plan, const int pendingCount = 0)
  {
   if(!m_cfg.enabled)
      return true;

   SBasketState basketState;
   bool hasBasket = GetState(basketState);

//--- Position ceiling, counting pending orders as committed intent
   int committed = (hasBasket ? basketState.positionCount : 0) + pendingCount;
   if(committed >= m_cfg.maxPositions)
     {
      PrintFormat("Basket full: %d position(s)/order(s) already committed, limit is %d. Trade skipped.",
                  committed, m_cfg.maxPositions);
      return false;
     }

//--- Aggregate margin ceiling for this basket
   if(m_cfg.maxMarginPercent > 0)
     {
      double newLegMargin = 0.0;
      if(!OrderCalcMargin(MarketOrderTypeOf(plan.orderType), m_symbol,
                          plan.lotSize, plan.entryPrice, newLegMargin))
        {
         PrintFormat("OrderCalcMargin() failed for %s. Error %d", m_symbol, GetLastError());
         return false;
        }

      double projected = (hasBasket ? basketState.usedMargin : 0.0) + newLegMargin;
      double equity    = AccountInfoDouble(ACCOUNT_EQUITY);
      double ceiling   = equity * (m_cfg.maxMarginPercent / 100.0);

      if(equity > 0 && projected > ceiling)
        {
         PrintFormat("Basket margin ceiling: this trade would tie up %.2f of %.2f allowed (%.1f%% of equity). Trade skipped.",
                     projected, ceiling, m_cfg.maxMarginPercent);
         return false;
        }
     }

   return true;
  }

#endif // RISKMANAGEMENT_BASKETRISK_MQH
//+------------------------------------------------------------------+
