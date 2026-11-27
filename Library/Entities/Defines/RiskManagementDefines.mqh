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
   RISK_FIXED_LOT                                           // Fixed lot size. Change in V5: no FixedLotSize key; the lot of the symbol on RAM (CTradingControl::FixedLot: min lot at the start, then the last lot chosen)
  };
#define RISK_MODES_TOTAL  (3)                               // the number of ENUM_RISK_MODE values
//--- What the author wrote for each value (the comment of the enum: MQL5 cannot read it), for the View
string RiskModeText(const ENUM_RISK_MODE mode)
  {
   switch(mode)
     {
      case RISK_PERCENT:    return "Percentage of account";
      case RISK_FIXED_CASH: return "Fixed cash amount";
      case RISK_FIXED_LOT:  return "Fixed lot size";
     }
   return "?";
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
//+------------------------------------------------------------------+
//| The properties of CRiskSetting (Setting_Risk), as DoEasy declares |
//| the properties of an object (BarDefines.mqh): integer (bool, int,|
//| the enums), real, string. A new key of the risk = a new value    |
//| here and its row in risk_property_list (RiskSetting.mqh)          |
//+------------------------------------------------------------------+
enum ENUM_RISK_PROP_INTEGER
  {
   RISK_PROP_RISK_MODE = 0,                                 // RiskMode (ENUM_RISK_MODE)
   RISK_PROP_RISK_BASE,                                     // RiskBase (ENUM_RISK_BASE)
   RISK_PROP_ALLOW_MIN_LOT_OVER_RISK,                       // AllowMinLotOverRisk
   RISK_PROP_ALLOW_HEDGING,                                 // AllowHedging
   RISK_PROP_ENABLE_ADAPTIVE_RISK,                          // EnableAdaptiveRisk
   RISK_PROP_ENABLE_ADAPTIVE_MARGIN_CAP,                    // EnableAdaptiveMarginCap
   RISK_PROP_ENABLE_BASKET_RISK,                            // EnableBasketRisk
   RISK_PROP_BASKET_LOSS_BASE,                              // BasketLossBase (ENUM_RISK_BASE)
   RISK_PROP_ENABLE_MAE_TRACKING,                           // EnableMAETracking
   RISK_PROP_MAX_BASKET_HOLD_BARS,                          // MaxBasketHoldBars
   RISK_PROP_ENABLE_PORTFOLIO_RISK,                         // EnablePortfolioRisk
   RISK_PROP_PORTFOLIO_SCOPE,                               // PortfolioScope (ENUM_PORTFOLIO_SCOPE)
   RISK_PROP_MAX_PORTFOLIO_POSITIONS,                       // MaxPortfolioPositions
   RISK_PROP_MAX_POSITIONS_PER_SYMBOL,                      // MaxPositionsPerSymbol
   RISK_PROP_MAX_PORTFOLIO_SYMBOLS,                         // MaxPortfolioSymbols
   RISK_PROP_LOG_PORTFOLIO_SNAPSHOT,                        // LogPortfolioSnapshot
  };
#define RISK_PROP_INTEGER_TOTAL (16)                        // Total number of integer properties
enum ENUM_RISK_PROP_DOUBLE
  {
   RISK_PROP_PERCENTAGE_RISK_PER_OPERATION = RISK_PROP_INTEGER_TOTAL,   // percentage_risk_per_operation
   RISK_PROP_FIXED_CASH_RISK,                               // FixedCashRisk
   RISK_PROP_ATR_MULTIPLIER,                                // ATRMultiplier
   RISK_PROP_TAKE_PROFIT_RATIO,                             // TakeProfitRatio
   RISK_PROP_DROP_DOWN_LEVEL,                               // DropDownLevel
   RISK_PROP_RISK_REDUCTION_FACTOR,                         // RiskReductionFactor
   RISK_PROP_MAX_MARGIN_USAGE_PERCENT,                      // MaxMarginUsagePercent
   RISK_PROP_MARGIN_LEVEL_SAFE,                             // MarginLevelSafe
   RISK_PROP_MARGIN_LEVEL_DANGER,                           // MarginLevelDanger
   RISK_PROP_MAX_BASKET_LOSS_PERCENT,                       // MaxBasketLossPercent
   RISK_PROP_MAX_BASKET_MARGIN_PERCENT,                     // MaxBasketMarginPercent
   RISK_PROP_MAX_PORTFOLIO_MARGIN_PERCENT,                  // MaxPortfolioMarginPercent
   RISK_PROP_MAX_PORTFOLIO_LOSS_PERCENT,                    // MaxPortfolioLossPercent
   RISK_PROP_MAX_NET_CURRENCY_LOTS,                         // MaxNetCurrencyLots
  };
#define RISK_PROP_DOUBLE_TOTAL  (14)                        // Total number of real properties
enum ENUM_RISK_PROP_STRING
  {
   RISK_PROP_EXTRA_PORTFOLIO_MAGICS = (RISK_PROP_INTEGER_TOTAL+RISK_PROP_DOUBLE_TOTAL),   // ExtraPortfolioMagics
   RISK_PROP_ENTRY_STRATEGIES,                              // EntryStrategies (V5): Setting_Strategy.strategy_id that trade, comma-separated
   RISK_PROP_STOP_LOSS_TEMPLATES,                           // StopLossTemplates (V5): Setting_IndicatorTemplate.id that give the stop
   RISK_PROP_TRAILING_TEMPLATES,                            // TrailingTemplates (V5): Setting_IndicatorTemplate.id that trail the stop
  };
#define RISK_PROP_STRING_TOTAL  (4)                         // Total number of string properties
#define RISK_PROP_TOTAL         (RISK_PROP_INTEGER_TOTAL+RISK_PROP_DOUBLE_TOTAL+RISK_PROP_STRING_TOTAL)
//--- The property that holds the amount of each mode (the input of Part 7). WRONG_VALUE: the mode has no amount (RISK_FIXED_LOT: the lot of the
//--- symbol on RAM, chosen in the Manual Entry)
int RiskModeValueProperty(const ENUM_RISK_MODE mode)
  {
   switch(mode)
     {
      case RISK_PERCENT:    return RISK_PROP_PERCENTAGE_RISK_PER_OPERATION;
      case RISK_FIXED_CASH: return RISK_PROP_FIXED_CASH_RISK;
      case RISK_FIXED_LOT:  return WRONG_VALUE;
     }
   return WRONG_VALUE;
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
