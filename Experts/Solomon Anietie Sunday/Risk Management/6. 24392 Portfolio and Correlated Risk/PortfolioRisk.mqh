//+------------------------------------------------------------------+
//|                                                PortfolioRisk.mqh |
//|                                    Copyright 2026, soloharbinger |
//|                      https://www.mql5.com/en/users/soloharbinger |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, soloharbinger"
#property link        "https://www.mql5.com/en/users/soloharbinger"
#property description "Account-level risk accounting for MetaTrader 5"

#ifndef SOLOEA_PORTFOLIORISK_MQH
#define SOLOEA_PORTFOLIORISK_MQH

//+------------------------------------------------------------------+
//| What counts as "the portfolio".                                  |
//+------------------------------------------------------------------+
enum ENUM_PORTFOLIO_SCOPE
  {
   PORTFOLIO_ACCOUNT_WIDE,     // Every position on the account
   PORTFOLIO_MAGIC_FILTERED    // Only registered magic numbers
  };

//+------------------------------------------------------------------+
//| A snapshot of total account exposure                             |
//+------------------------------------------------------------------+
struct SPortfolioState
  {
   int               positionCount;
   int               pendingCount;
   int               symbolCount;
   double            totalVolume;
   double            floatingPL;
   double            usedMargin;
   double            freeMargin;
   double            marginLevel;
   double            equity;
   double            balance;
  };

//+------------------------------------------------------------------+
//| Net directional exposure to a single currency                    |
//+------------------------------------------------------------------+
struct SCurrencyExposure
  {
   string            currency;
   double            netLots;        // Signed: positive = net long this currency
   double            grossLots;      // Unsigned total, regardless of direction
   int               positionCount;
  };

//+------------------------------------------------------------------+
//| CPortfolioRisk                                                   |
//+------------------------------------------------------------------+
class CPortfolioRisk
  {
private:
   ENUM_PORTFOLIO_SCOPE m_scope;
   long              m_magics[];

   //--- Limits. Zero or negative disables the individual check.
   int               m_maxTotalPositions;
   int               m_maxPositionsPerSymbol;
   int               m_maxSymbols;
   double            m_maxMarginPercent;
   double            m_maxLossPercent;
   double            m_maxNetCurrencyLots;

   bool              IsTracked(const long magic) const;
   int               FindCurrency(const SCurrencyExposure &list[], const string currency) const;
   void              AccumulateCurrency(SCurrencyExposure &list[], const string currency,
                                        const double signedLots, const bool countPosition);

public:
                     CPortfolioRisk(void);

   //--- Configuration
   void              SetScope(const ENUM_PORTFOLIO_SCOPE scope) { m_scope = scope; }
   void              RegisterMagic(const long magic);
   void              SetPositionLimits(const int maxTotal, const int maxPerSymbol, const int maxSymbols);
   void              SetMarginLimit(const double maxMarginPercent)   { m_maxMarginPercent = maxMarginPercent; }
   void              SetLossLimit(const double maxLossPercent)       { m_maxLossPercent = maxLossPercent; }
   void              SetCurrencyLimit(const double maxNetLots)       { m_maxNetCurrencyLots = maxNetLots; }

   //--- Measurement
   bool              Scan(SPortfolioState &state);
   int               GetCurrencyExposure(SCurrencyExposure &exposure[]);
   double            NetLotsForCurrency(const string currency);
   void              PrintSnapshot(void);

   //--- The gate
   bool              CanOpenPosition(const string symbol, const ENUM_ORDER_TYPE orderType,
                                     const double volume, const double price, string &reason);
  };

//+------------------------------------------------------------------+
//| Constructor - every limit starts disabled                        |
//+------------------------------------------------------------------+
CPortfolioRisk::CPortfolioRisk(void)
  {
   m_scope                 = PORTFOLIO_ACCOUNT_WIDE;
   m_maxTotalPositions     = 0;
   m_maxPositionsPerSymbol = 0;
   m_maxSymbols            = 0;
   m_maxMarginPercent      = 0.0;
   m_maxLossPercent        = 0.0;
   m_maxNetCurrencyLots    = 0.0;
   ArrayResize(m_magics, 0);
  }

//+------------------------------------------------------------------+
//| Register a magic number as part of this portfolio                |
//+------------------------------------------------------------------+
void CPortfolioRisk::RegisterMagic(const long magic)
  {
   int size = ArraySize(m_magics);
   for(int i = 0; i < size; i++)
      if(m_magics[i] == magic)
         return;

   ArrayResize(m_magics, size + 1);
   m_magics[size] = magic;
  }

//+------------------------------------------------------------------+
//| Set position-count ceilings [0 disables an individual limit]     |
//+------------------------------------------------------------------+
void CPortfolioRisk::SetPositionLimits(const int maxTotal, const int maxPerSymbol, const int maxSymbols)
  {
   m_maxTotalPositions     = maxTotal;
   m_maxPositionsPerSymbol = maxPerSymbol;
   m_maxSymbols            = maxSymbols;
  }

//+------------------------------------------------------------------+
//| Does this position belong to the portfolio being measured?       |
//+------------------------------------------------------------------+
bool CPortfolioRisk::IsTracked(const long magic) const
  {
   if(m_scope == PORTFOLIO_ACCOUNT_WIDE)
      return true;

   int size = ArraySize(m_magics);
   for(int i = 0; i < size; i++)
      if(m_magics[i] == magic)
         return true;

   return false;
  }

//+------------------------------------------------------------------+
//| Locate a currency in the exposure list, or -1                    |
//+------------------------------------------------------------------+
int CPortfolioRisk::FindCurrency(const SCurrencyExposure &list[], const string currency) const
  {
   int size = ArraySize(list);
   for(int i = 0; i < size; i++)
      if(list[i].currency == currency)
         return i;

   return -1;
  }

//+------------------------------------------------------------------+
//| Add signed exposure to a currency, creating its entry if needed  |
//+------------------------------------------------------------------+
void CPortfolioRisk::AccumulateCurrency(SCurrencyExposure &list[], const string currency,
                                        const double signedLots, const bool countPosition)
  {
   if(currency == "")
      return;

   int index = FindCurrency(list, currency);
   if(index < 0)
     {
      index = ArraySize(list);
      ArrayResize(list, index + 1);
      list[index].currency      = currency;
      list[index].netLots       = 0.0;
      list[index].grossLots     = 0.0;
      list[index].positionCount = 0;
     }

   list[index].netLots   += signedLots;
   list[index].grossLots += MathAbs(signedLots);
   if(countPosition)
      list[index].positionCount++;
  }

//+------------------------------------------------------------------+
//| Take a snapshot of total exposure.                               |
//+------------------------------------------------------------------+
bool CPortfolioRisk::Scan(SPortfolioState &state)
  {
   ZeroMemory(state);

   state.equity     = AccountInfoDouble(ACCOUNT_EQUITY);
   state.balance    = AccountInfoDouble(ACCOUNT_BALANCE);
   state.freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   state.marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);

   string seenSymbols[];
   ArrayResize(seenSymbols, 0);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;
      if(!IsTracked(PositionGetInteger(POSITION_MAGIC)))
         continue;

      string symbol = PositionGetString(POSITION_SYMBOL);
      double volume = PositionGetDouble(POSITION_VOLUME);

      state.positionCount++;
      state.totalVolume += volume;
      state.floatingPL  += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);

      //--- Distinct symbol tally
      bool known = false;
      int seen = ArraySize(seenSymbols);
      for(int s = 0; s < seen; s++)
         if(seenSymbols[s] == symbol)
           {
            known = true;
            break;
           }
      if(!known)
        {
         ArrayResize(seenSymbols, seen + 1);
         seenSymbols[seen] = symbol;
        }

      //--- Only needed when the account-wide figure does not apply
      if(m_scope == PORTFOLIO_MAGIC_FILTERED)
        {
         ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         ENUM_ORDER_TYPE asOrder = (posType == POSITION_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
         double legMargin = 0.0;
         if(OrderCalcMargin(asOrder, symbol, volume,
                            PositionGetDouble(POSITION_PRICE_OPEN), legMargin))
            state.usedMargin += legMargin;
        }
     }

   state.symbolCount = ArraySize(seenSymbols);

   if(m_scope == PORTFOLIO_ACCOUNT_WIDE)
      state.usedMargin = AccountInfoDouble(ACCOUNT_MARGIN);

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(!IsTracked(OrderGetInteger(ORDER_MAGIC)))
         continue;

      state.pendingCount++;
     }

   return (state.positionCount > 0 || state.pendingCount > 0);
  }

//+------------------------------------------------------------------+
//| Break exposure down by currency.                                 |
//+------------------------------------------------------------------+
int CPortfolioRisk::GetCurrencyExposure(SCurrencyExposure &exposure[])
  {
   ArrayResize(exposure, 0);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;
      if(!IsTracked(PositionGetInteger(POSITION_MAGIC)))
         continue;

      string symbol = PositionGetString(POSITION_SYMBOL);
      double volume = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      string baseCurrency  = SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE);
      string quoteCurrency = SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT);

      double signedLots = (posType == POSITION_TYPE_BUY) ? volume : -volume;

      //--- Long the pair means long the base and short the quote
      AccumulateCurrency(exposure, baseCurrency,  signedLots,  true);
      AccumulateCurrency(exposure, quoteCurrency, -signedLots, false);
     }

   return ArraySize(exposure);
  }

//+------------------------------------------------------------------+
//| Net lots held in one currency across the whole portfolio         |
//+------------------------------------------------------------------+
double CPortfolioRisk::NetLotsForCurrency(const string currency)
  {
   SCurrencyExposure exposure[];
   GetCurrencyExposure(exposure);

   int index = FindCurrency(exposure, currency);
   return (index < 0) ? 0.0 : exposure[index].netLots;
  }

//+------------------------------------------------------------------+
//| Log the current portfolio picture                                |
//+------------------------------------------------------------------+
void CPortfolioRisk::PrintSnapshot(void)
  {
   SPortfolioState state;
   Scan(state);

   PrintFormat("PORTFOLIO | Positions: %d across %d symbol(s) | Pending: %d | Volume: %.2f | Floating: %.2f | Margin used: %.2f | Margin level: %.1f%%",
               state.positionCount, state.symbolCount, state.pendingCount,
               state.totalVolume, state.floatingPL, state.usedMargin, state.marginLevel);

   SCurrencyExposure exposure[];
   int count = GetCurrencyExposure(exposure);

   for(int i = 0; i < count; i++)
      if(MathAbs(exposure[i].netLots) > 0.0)
         PrintFormat("   %s | Net: %+.2f lots | Gross: %.2f lots",
                     exposure[i].currency, exposure[i].netLots, exposure[i].grossLots);
  }

//+------------------------------------------------------------------+
//| The gate: can this trade be added to the portfolio?              |
//+------------------------------------------------------------------+
bool CPortfolioRisk::CanOpenPosition(const string symbol, const ENUM_ORDER_TYPE orderType,
                                     const double volume, const double price, string &reason)
  {
   reason = "";

   SPortfolioState state;
   Scan(state);

//--- Total position count
   if(m_maxTotalPositions > 0 && state.positionCount + state.pendingCount >= m_maxTotalPositions)
     {
      reason = StringFormat("portfolio already holds %d position(s)/order(s), limit is %d",
                            state.positionCount + state.pendingCount, m_maxTotalPositions);
      return false;
     }

//--- Concentration in one symbol
   if(m_maxPositionsPerSymbol > 0)
     {
      int symbolCount = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(!PositionSelectByTicket(ticket))
            continue;
         if(!IsTracked(PositionGetInteger(POSITION_MAGIC)))
            continue;
         if(PositionGetString(POSITION_SYMBOL) == symbol)
            symbolCount++;
        }

      if(symbolCount >= m_maxPositionsPerSymbol)
        {
         reason = StringFormat("%s already holds %d position(s), limit is %d",
                               symbol, symbolCount, m_maxPositionsPerSymbol);
         return false;
        }
     }

//--- Number of distinct symbols in play
   if(m_maxSymbols > 0 && state.symbolCount >= m_maxSymbols)
     {
      bool alreadyTrading = false;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(!PositionSelectByTicket(ticket))
            continue;
         if(!IsTracked(PositionGetInteger(POSITION_MAGIC)))
            continue;
         if(PositionGetString(POSITION_SYMBOL) == symbol)
           {
            alreadyTrading = true;
            break;
           }
        }

      //--- Only a new symbol would widen the portfolio
      if(!alreadyTrading)
        {
         reason = StringFormat("portfolio already spans %d symbol(s), limit is %d",
                               state.symbolCount, m_maxSymbols);
         return false;
        }
     }

//--- Total margin consumption, projected
   if(m_maxMarginPercent > 0 && state.equity > 0)
     {
      double newLegMargin = 0.0;
      if(!OrderCalcMargin(orderType, symbol, volume, price, newLegMargin))
        {
         reason = StringFormat("OrderCalcMargin() failed for %s, error %d", symbol, GetLastError());
         return false;
        }

      double projected = state.usedMargin + newLegMargin;
      double ceiling   = state.equity * (m_maxMarginPercent / 100.0);

      if(projected > ceiling)
        {
         reason = StringFormat("margin would reach %.2f of %.2f allowed (%.1f%% of equity)",
                               projected, ceiling, m_maxMarginPercent);
         return false;
        }
     }

//--- Aggregate floating loss
   if(m_maxLossPercent > 0 && state.balance > 0)
     {
      double maxLoss = state.balance * (m_maxLossPercent / 100.0);
      if(state.floatingPL <= -maxLoss)
        {
         reason = StringFormat("portfolio is already down %.2f, limit is %.2f (%.1f%%)",
                               state.floatingPL, maxLoss, m_maxLossPercent);
         return false;
        }
     }

//--- Currency concentration, projected.
   if(m_maxNetCurrencyLots > 0)
     {
      SCurrencyExposure exposure[];
      GetCurrencyExposure(exposure);

      string baseCurrency  = SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE);
      string quoteCurrency = SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT);

      int direction = 0;
      switch(orderType)
        {
         case ORDER_TYPE_BUY:
         case ORDER_TYPE_BUY_LIMIT:
         case ORDER_TYPE_BUY_STOP:
            direction = 1;
            break;
         default:
            direction = -1;
            break;
        }

      double signedLots = volume * direction;

      AccumulateCurrency(exposure, baseCurrency,  signedLots,  false);
      AccumulateCurrency(exposure, quoteCurrency, -signedLots, false);

      int baseIndex  = FindCurrency(exposure, baseCurrency);
      int quoteIndex = FindCurrency(exposure, quoteCurrency);

      if(baseIndex >= 0 && MathAbs(exposure[baseIndex].netLots) > m_maxNetCurrencyLots)
        {
         reason = StringFormat("net %s exposure would reach %+.2f lots, limit is %.2f",
                               baseCurrency, exposure[baseIndex].netLots, m_maxNetCurrencyLots);
         return false;
        }

      if(quoteIndex >= 0 && MathAbs(exposure[quoteIndex].netLots) > m_maxNetCurrencyLots)
        {
         reason = StringFormat("net %s exposure would reach %+.2f lots, limit is %.2f",
                               quoteCurrency, exposure[quoteIndex].netLots, m_maxNetCurrencyLots);
         return false;
        }
     }

   return true;
  }
//+------------------------------------------------------------------+

#endif // SOLOEA_PORTFOLIORISK_MQH
//+------------------------------------------------------------------+
