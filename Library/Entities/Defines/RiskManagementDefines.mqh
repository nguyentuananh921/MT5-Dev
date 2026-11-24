//+------------------------------------------------------------------+
//|                                        RiskManagementDefines.mqh |
//| The enums of RiskManagement in one place (Trading\RiskManagement)|
//| Combined from RiskTypes.mqh of Part 7 (Solomon Anietie Sunday\   |
//| Risk Management\7. 24477 ...\Include): ENUM_RISK_MODE,           |
//| ENUM_RISK_BASE, ENUM_PORTFOLIO_SCOPE. Its configs (SRiskConfig,  |
//| SBasketConfig) become CRiskSetting (Entities\Settings\Risk).     |
//| Not ported: ENUM_ENTRY_MODE, ENUM_OFFSET_MODE: the order type    |
//| (ENUM_ORDER_TYPE) and its price are decisions of the Strategy    |
//+------------------------------------------------------------------+
#ifndef __RISKMANAGEMENT_DEFINES_MQH__
#define __RISKMANAGEMENT_DEFINES_MQH__
//+------------------------------------------------------------------+
//| Anhnt's own, not from DoEasy: the take profit levels of a trade   |
//| are put at these multiples of the stop distance (risk : reward)   |
//| Reference https://www.mql5.com/en/articles/20512                 |
//+------------------------------------------------------------------+
enum ENUM_RISK_REWARD_RATIO
  {
   ONE_TO_ONE,                                              // 1 : 1
   ONE_TO_ONEandHALF,                                       // 1 : 1.5
   ONE_TO_TWO,                                              // 1 : 2
   ONE_TO_THREE,                                            // 1 : 3
   ONE_TO_FOUR,                                             // 1 : 4
   ONE_TO_FIVE,                                             // 1 : 5
   ONE_TO_SIX                                               // 1 : 6
  };
#define RISK_REWARD_RATIOS_TOTAL  (7)                       // the number of ENUM_RISK_REWARD_RATIO values
//--- The reward of the ratio for a risk of 1: ONE_TO_ONEandHALF is 1.5
double RiskRewardRatioValue(const ENUM_RISK_REWARD_RATIO ratio)
  {
   switch(ratio)
     {
      case ONE_TO_ONE:        return 1.0;
      case ONE_TO_ONEandHALF: return 1.5;
      case ONE_TO_TWO:        return 2.0;
      case ONE_TO_THREE:      return 3.0;
      case ONE_TO_FOUR:       return 4.0;
      case ONE_TO_FIVE:       return 5.0;
      case ONE_TO_SIX:        return 6.0;
     }
   return 1.0;
  }
//+------------------------------------------------------------------+
//| Part 7 RiskTypes.mqh: how the trader says how much to risk       |
//+------------------------------------------------------------------+
enum ENUM_RISK_MODE
  {
   RISK_PERCENT,                                            // Percentage of account
   RISK_FIXED_CASH,                                         // Fixed cash amount
   RISK_FIXED_LOT                                           // Fixed lot size. Change in V5 (2026-11-23): always the min lot of the symbol (no FixedLotSize key)
  };
#define RISK_MODES_TOTAL  (3)                               // the number of ENUM_RISK_MODE values
//--- What the author wrote for each value (the comment of the enum: MQL5 cannot read it), for the View
string RiskModeText(const ENUM_RISK_MODE mode)
  {
   switch(mode)
     {
      case RISK_PERCENT:    return "Percentage of account";
      case RISK_FIXED_CASH: return "Fixed cash amount";
      case RISK_FIXED_LOT:  return "Min lot";
     }
   return "?";
  }
//--- The key of Setting_Risk that holds the amount of each mode (the input of Part 7). "": the mode has no amount (RISK_FIXED_LOT: the min lot of the symbol)
string RiskModeValueKey(const ENUM_RISK_MODE mode)
  {
   switch(mode)
     {
      case RISK_PERCENT:    return "percentage_risk_per_operation";
      case RISK_FIXED_CASH: return "FixedCashRisk";
      case RISK_FIXED_LOT:  return "";
     }
   return "";
  }
//+------------------------------------------------------------------+
//| Balance ignores open floating P/L; equity includes it            |
//| RISK_BASE_FREEMARGIN reference from                               |
//| D:\MT5-Dev\Experts\Allan Munene Mutiiria\Automating Trading Strategies
//| 47. 21096 NRTR_-_Nick_Rypock_Trailing_Reverse_-_EA
//+------------------------------------------------------------------+
enum ENUM_RISK_BASE
  {
   RISK_BASE_BALANCE,                                       // Account balance
   RISK_BASE_EQUITY,                                        // Account equity
   RISK_BASE_FREEMARGIN,                                    // Free margin
  };
#define RISK_BASES_TOTAL  (3)                               // the number of ENUM_RISK_BASE values
string RiskBaseText(const ENUM_RISK_BASE base)
  {
   switch(base)
     {
      case RISK_BASE_BALANCE: return "Balance";
      case RISK_BASE_EQUITY:  return "Equity";
      case RISK_BASE_FREEMARGIN: return "Free Margin";
     }
   return "?";
  }
//+------------------------------------------------------------------+
//| Part 7 PortfolioRisk.mqh: what counts as "the portfolio"         |
//+------------------------------------------------------------------+
enum ENUM_PORTFOLIO_SCOPE
  {
   PORTFOLIO_ACCOUNT_WIDE,                                  // Every position on the account
   PORTFOLIO_MAGIC_FILTERED                                 // Only registered magic numbers
  };
#define PORTFOLIO_SCOPES_TOTAL  (2)                         // the number of ENUM_PORTFOLIO_SCOPE values
string PortfolioScopeText(const ENUM_PORTFOLIO_SCOPE scope)
  {
   switch(scope)
     {
      case PORTFOLIO_ACCOUNT_WIDE:   return "Every position on the account";
      case PORTFOLIO_MAGIC_FILTERED: return "Only registered magic numbers";
     }
   return "?";
  }
//--- The texts of the values of an enum by its type name (Setting_Risk.type), the value = the index; 0: not one of these enums
int RiskEnumItems(const string type,string &items[])
  {
   ::ArrayResize(items,0);
   if(type=="ENUM_RISK_MODE")
     {
      ::ArrayResize(items,RISK_MODES_TOTAL);
      for(int i=0;i<RISK_MODES_TOTAL;i++)
         items[i]=RiskModeText((ENUM_RISK_MODE)i);
     }
   else if(type=="ENUM_RISK_BASE")
     {
      ::ArrayResize(items,RISK_BASES_TOTAL);
      for(int i=0;i<RISK_BASES_TOTAL;i++)
         items[i]=RiskBaseText((ENUM_RISK_BASE)i);
     }
   else if(type=="ENUM_PORTFOLIO_SCOPE")
     {
      ::ArrayResize(items,PORTFOLIO_SCOPES_TOTAL);
      for(int i=0;i<PORTFOLIO_SCOPES_TOTAL;i++)
         items[i]=PortfolioScopeText((ENUM_PORTFOLIO_SCOPE)i);
     }
   return ::ArraySize(items);
  }
//+------------------------------------------------------------------+
//| Part 7 RiskTypes.mqh STradePlan: a fully priced trade, built and |
//| checked by CTradingControl::BuildPlan / ValidatePlan. New in V5:  |
//| strategy_id, symbol (many                                        |
//| strategies, many symbols); no isPending (market entries only)    |
//+------------------------------------------------------------------+
struct STradePlan
  {
   long              strategy_id;                           // the strategy of the Entry (goes into the magic)
   string            symbol;                                // the symbol of the Entry
   ENUM_ORDER_TYPE   orderType;                             // ORDER_TYPE_BUY / ORDER_TYPE_SELL (the side; Change in V5: no int direction of the author)
   double            entryPrice;                            // Ask for a buy, Bid for a sell
   double            stopLoss;                              // 0: the strategy gave no stop
   double            takeProfit;                            // 0: no stop, no target
   double            stopDistance;                          // from entryPrice and stopLoss (0: no stop)
   double            lotSize;
   double            riskAmount;                            // intended money risk (0 in fixed-lot mode)
  };
//+------------------------------------------------------------------+
//| Part 7 RiskTypes.mqh SBasketState: the positions dealt on a      |
//| symbol of one side seen as one (CMarketCollection::BasketState). |
//| Change in V5: the side is the basket (Concepts.md, Phạm vi), no   |
//| netDirection of the author                                       |
//+------------------------------------------------------------------+
struct SBasketState
  {
   ENUM_ORDER_TYPE   type;                                  // ORDER_TYPE_BUY / ORDER_TYPE_SELL: the side of the basket
   int               positionCount;
   double            totalVolume;
   double            weightedEntryPrice;                    // volume-weighted average entry
   double            floatingPL;                            // profit + swap
   double            usedMargin;                            // computed per leg
   datetime          oldestOpenTime;
  };
//+------------------------------------------------------------------+
//| Part 7 PortfolioRisk.mqh: the portfolio and its currency exposure|
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
struct SCurrencyExposure
  {
   string            currency;
   double            netLots;                               // signed: positive = net long this currency
   double            grossLots;                             // unsigned total, regardless of direction
   int               positionCount;
  };
//+------------------------------------------------------------------+
//| Part 7 RiskTypes.mqh: round a volume DOWN to the broker's step   |
//| (CSymbol::NormalizedLot rounds to nearest: not the same)         |
//+------------------------------------------------------------------+
double FloorToVolumeStep(const double volume,const double lotStep)
  {
   if(lotStep<=0)
      return volume;
   double steps =::NormalizeDouble(volume/lotStep,8);
   double result=::MathFloor(steps)*lotStep;
   int stepDigits=(int)::MathMax(0,::MathCeil(-::MathLog10(lotStep)));
   return ::NormalizeDouble(result,stepDigits);
  }
#endif // __RISKMANAGEMENT_DEFINES_MQH__
