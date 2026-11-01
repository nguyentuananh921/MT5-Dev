//+------------------------------------------------------------------+
//|                                                    RiskTypes.mqh |
//|                                    Copyright 2026, soloharbinger |
//|                      https://www.mql5.com/en/users/soloharbinger |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, soloharbinger"
#property link      "https://www.mql5.com/en/users/soloharbinger"
#property description "Shared vocabulary for the overall risk framework. The trade, the basket, and the account."

#ifndef RISKMANAGEMENT_RISKTYPES_MQH
#define RISKMANAGEMENT_RISKTYPES_MQH

//+------------------------------------------------------------------+
//| How the trader expresses "how much am I willing to risk?"        |
//+------------------------------------------------------------------+
enum ENUM_RISK_MODE
  {
   RISK_PERCENT,        // Percentage of account
   RISK_FIXED_CASH,     // Fixed cash amount
   RISK_FIXED_LOT       // Fixed lot size
  };

//+------------------------------------------------------------------+
//| Balance ignores open floating P/L; equity includes it            |
//+------------------------------------------------------------------+
enum ENUM_RISK_BASE
  {
   RISK_BASE_BALANCE,   // Account balance
   RISK_BASE_EQUITY     // Account equity
  };

//+------------------------------------------------------------------+
//| How the EA gets into the market                                  |
//+------------------------------------------------------------------+
enum ENUM_ENTRY_MODE
  {
   ENTRY_MARKET,        // Market order (immediate)
   ENTRY_LIMIT,         // Pending limit (pullback entry)
   ENTRY_STOP           // Pending stop (breakout entry)
  };

//+------------------------------------------------------------------+
//| How far a pending entry sits from the current price              |
//+------------------------------------------------------------------+
enum ENUM_OFFSET_MODE
  {
   OFFSET_ATR,          // ATR-based offset
   OFFSET_POINTS        // Fixed points offset
  };

//+------------------------------------------------------------------+
//| A fully-specified trade, before anything reaches the broker.     |
//+------------------------------------------------------------------+
struct STradePlan
  {
   int               direction;      // 1 = Buy, -1 = Sell
   ENUM_ORDER_TYPE   orderType;      // Concrete order type being sent
   bool              isPending;      // True for limit/stop entries
   double            entryPrice;     // Intended entry, not necessarily current price
   double            stopLoss;
   double            takeProfit;
   double            stopDistance;   // Derived from entryPrice and stopLoss
   double            lotSize;
   double            riskAmount;     // Intended monetary risk (0 in fixed-lot mode)
  };

//+------------------------------------------------------------------+
//| Every position one EA holds on one symbol, viewed as one unit    |
//+------------------------------------------------------------------+
struct SBasketState
  {
   int               positionCount;
   double            totalVolume;
   double            weightedEntryPrice;  // Volume-weighted average entry
   double            floatingPL;          // Profit + swap
   double            usedMargin;          // Computed per leg - see the note in CBasketRisk
   int               netDirection;        // 1 = net long, -1 = net short, 0 = flat or balanced
   datetime          oldestOpenTime;
  };

//+------------------------------------------------------------------+
//| Trade-level configuration (Risk Management I - III)              |
//+------------------------------------------------------------------+
struct SRiskConfig
  {
   //--- Identity
   long              magic;

   //--- Risk model
   ENUM_RISK_MODE    riskMode;
   ENUM_RISK_BASE    riskBase;
   double            riskPercent;
   double            fixedCashRisk;
   double            fixedLotSize;
   bool              allowMinLotOverRisk;

   //--- Drawdown scaling
   bool              enableDrawdownScaling;
   double            drawdownTrigger;        // % from peak equity
   double            drawdownFactor;         // Multiplier once triggered
   bool              applyDrawdownToFixedLot;

   //--- Stops and targets
   double            stopATRMultiplier;
   double            tpRatio;

   //--- Order execution
   ENUM_ENTRY_MODE   entryMode;
   ENUM_OFFSET_MODE  offsetMode;
   double            pendingOffsetATR;
   int               pendingOffsetPoints;
   int               pendingExpiryBars;

   //--- Broker and margin safety
   double            maxMarginUsagePercent;
   bool              enableAdaptiveMarginCap;
   double            marginLevelSafe;
   double            marginLevelDanger;

   //--- Position rules
   bool              allowHedging;

   void              SetDefaults(void);
  };

//+------------------------------------------------------------------+
//| Sensible starting values, so an EA only overrides what it cares  |
//| about instead of filling in every field                          |
//+------------------------------------------------------------------+
void SRiskConfig::SetDefaults(void)
  {
   magic                   = 0;

   riskMode                = RISK_PERCENT;
   riskBase                = RISK_BASE_BALANCE;
   riskPercent             = 1.0;
   fixedCashRisk           = 100.0;
   fixedLotSize            = 0.10;
   allowMinLotOverRisk     = true;

   enableDrawdownScaling   = false;
   drawdownTrigger         = 3.0;
   drawdownFactor          = 0.5;
   applyDrawdownToFixedLot = false;

   stopATRMultiplier       = 1.5;
   tpRatio                 = 2.0;

   entryMode               = ENTRY_MARKET;
   offsetMode              = OFFSET_ATR;
   pendingOffsetATR        = 0.5;
   pendingOffsetPoints     = 150;
   pendingExpiryBars       = 10;

   maxMarginUsagePercent   = 50.0;
   enableAdaptiveMarginCap = false;
   marginLevelSafe         = 500.0;
   marginLevelDanger       = 150.0;

   allowHedging            = false;
  }

//+------------------------------------------------------------------+
//| Basket-level configuration (Risk Management IV)                  |
//+------------------------------------------------------------------+
struct SBasketConfig
  {
   long              magic;
   bool              enabled;
   int               maxPositions;
   double            maxLossPercent;      // 0 disables
   ENUM_RISK_BASE    lossBase;
   double            maxMarginPercent;    // 0 disables
   bool              trackExcursion;
   int               maxHoldBars;         // 0 disables

   void              SetDefaults(void);
  };

//+------------------------------------------------------------------+
//| Basket defaults                                                  |
//+------------------------------------------------------------------+
void SBasketConfig::SetDefaults(void)
  {
   magic            = 0;
   enabled          = true;
   maxPositions     = 1;
   maxLossPercent   = 3.0;
   lossBase         = RISK_BASE_BALANCE;
   maxMarginPercent = 25.0;
   trackExcursion   = true;
   maxHoldBars      = 0;
  }

//+------------------------------------------------------------------+
//| Round a volume down to the broker's volume step.                 |
//+------------------------------------------------------------------+
double FloorToVolumeStep(const double volume, const double lotStep)
  {
   if(lotStep <= 0)
      return volume;

   double steps  = NormalizeDouble(volume / lotStep, 8);
   double result = MathFloor(steps) * lotStep;

   int stepDigits = (int)MathMax(0, MathCeil(-MathLog10(lotStep)));
   return NormalizeDouble(result, stepDigits);
  }

//+------------------------------------------------------------------+
//| Translate any order type into its trade direction                |
//+------------------------------------------------------------------+
int OrderTypeDirection(const ENUM_ORDER_TYPE orderType)
  {
   switch(orderType)
     {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_STOP_LIMIT:
         return 1;
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_LIMIT:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_STOP_LIMIT:
         return -1;
     }
   return 0;
  }

//+------------------------------------------------------------------+
//| Reduce any order type to the market order it becomes once filled |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE MarketOrderTypeOf(const ENUM_ORDER_TYPE orderType)
  {
   return (OrderTypeDirection(orderType) == 1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
  }

//+------------------------------------------------------------------+
//| What one lot gains or loses over a given price distance.         |
//+------------------------------------------------------------------+
double ValuePerLot(const string symbol, const double priceDistance)
  {
   if(priceDistance <= 0)
      return 0.0;

   double tickSize  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);

   if(tickSize <= 0 || tickValue <= 0)
      return 0.0;

   return (priceDistance / tickSize) * tickValue;
  }

//+------------------------------------------------------------------+
//| Convert a money amount and a price distance into a tradable      |
//| volume, respecting the broker's volume rules.                    |
//+------------------------------------------------------------------+
double VolumeForMoneyAndDistance(const string symbol, const double moneyAmount,
                                 const double priceDistance, const bool allowMinimumOverrun)
  {
   double minLot  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

   if(minLot <= 0 || lotStep <= 0 || maxLot < minLot)
     {
      Print("Invalid broker volume specification. Cannot size a position.");
      return 0.0;
     }

   if(priceDistance <= 0 || moneyAmount <= 0)
      return 0.0;

   double valuePerLot = ValuePerLot(symbol, priceDistance);
   if(valuePerLot <= 0)
     {
      Print("Cannot value the price distance. Cannot size a position.");
      return 0.0;
     }

   double rawLot  = moneyAmount / valuePerLot;
   double lotSize = FloorToVolumeStep(rawLot, lotStep);

   if(lotSize > maxLot)
      lotSize = FloorToVolumeStep(maxLot, lotStep);

   if(lotSize < minLot)
     {
      if(!allowMinimumOverrun)
        {
         PrintFormat("Correct volume (%.4f) is below the minimum lot (%.2f). Trade skipped to avoid overshooting the amount.",
                     rawLot, minLot);
         return 0.0;
        }

      PrintFormat("Caution: correct volume (%.4f) is below the minimum lot (%.2f). Trading %.2f - the actual amount will EXCEED %.2f.",
                  rawLot, minLot, minLot, moneyAmount);
      lotSize = minLot;
     }

   return lotSize;
  }

//+------------------------------------------------------------------+
//| Read an account figure by risk base                              |
//+------------------------------------------------------------------+
double AccountValueByBase(const ENUM_RISK_BASE base)
  {
   return (base == RISK_BASE_EQUITY)
          ? AccountInfoDouble(ACCOUNT_EQUITY)
          : AccountInfoDouble(ACCOUNT_BALANCE);
  }

#endif // RISKMANAGEMENT_RISKTYPES_MQH
//+------------------------------------------------------------------+
