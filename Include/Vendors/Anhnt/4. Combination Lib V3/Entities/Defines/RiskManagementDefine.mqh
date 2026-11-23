//+------------------------------------------------------------------+
//|                                          RiskManagementDefine.mqh |
//| The words every class of the risk management uses: how much the |
//| trader is willing to risk, on what base, and the plan of a trade |
//| before anything reaches the broker. The classes that calculate  |
//| (lot, stop, trailing) and the ones that send are written on     |
//| these words, so they are declared here, in one place            |
//+------------------------------------------------------------------+
 //| Reference (read them together, the concept is the author's):     |
 //| Series 1: Building Your Personal Expert Advisor (soloharbinger)  |
 //|   2. Risk Management and Dynamic Lot Sizing                      |
 //|                           https://www.mql5.com/en/articles/23638 |
 //|   3. Margin and Allowable Risk                                   |
 //|                           https://www.mql5.com/en/articles/23897 |
 //|   4. Risk Models and Order Execution                             |
 //|                           https://www.mql5.com/en/articles/21231 |
 //|   5. Basket Risk and Strategy-Specific Sizing                    |
 //|                           https://www.mql5.com/en/articles/24331 |
 //|   6. Portfolio and Correlated Risk                               |
 //|                           https://www.mql5.com/en/articles/24392 |
 //|   7. Consolidating the Risk Framework (RiskTypes.mqh)            |
 //|                           https://www.mql5.com/en/articles/24477 |
 //| Series 2: Risk Management (Niquel Mendoza)                       |
 //|   1. Fundamentals for Building a Risk Management Class           |
 //|                           https://www.mql5.com/en/articles/16820 |
 //|   2. Implementing Lot Calculation in a Graphical Interface       |
 //|                           https://www.mql5.com/en/articles/16985 |
 //|   3. Building the Main Class for Risk Management                 |
 //|                           https://www.mql5.com/en/articles/17249 |
 //|   4. Completing the Key Class Methods                            |
 //|                           https://www.mql5.com/en/articles/17508 |
 //|   5. Integrating the Risk Management System into EA              |
 //|                           https://www.mql5.com/en/articles/17640 |
 //+------------------------------------------------------------------+
#ifndef __RISK_MANAGEMENT_DEFINE_MQH__
#define __RISK_MANAGEMENT_DEFINE_MQH__
enum ENUM_STOPLOST_TRAILING_MODE
   {
     SL_MODE_FIXED = 0,
     SL_MODE_INDICATOR,
   };
//+------------------------------------------------------------------+
//| How the trader says "how much am I willing to risk?" for a trade |
//| (a percentage of the account, a cash amount, or a fixed lot)     |
//+------------------------------------------------------------------+
 //|1. Developing a Multi-Timeframe Indicator                         |
 //|                          https://www.mql5.com/en/articles/21330  |
 //|2. Automating the Strategy with an Expert Advisor                 |
 //|                          https://www.mql5.com/en/articles/21135  |
 //|3. Defining Structural Validity Beyond Simple Highs/Lows          |
 //|                          https://www.mql5.com/en/articles/21888  |
 //|4. Dynamic Pullback Depth Using Volatility Models                 |
 //|                          https://www.mql5.com/en/articles/22807  |
 //| Calculate STOP LOST BASE ON SWING 
 //|5. Filtering Weak Swings Using Candle Imbalance                   |
 //|                          https://www.mql5.com/en/articles/23613  |
enum ENUM_RISK_MODE
  {
   RISK_PERCENT,        // Percentage of account
   RISK_FIXED_CASH,     // Fixed cash amount
   RISK_FIXED_LOT       // Fixed lot size
  };
//+------------------------------------------------------------------+
//| The balance leaves the floating profit out, the equity has it in |
//+------------------------------------------------------------------+
enum ENUM_RISK_BASE
  {
   RISK_BASE_BALANCE,   // The balance of the account
   RISK_BASE_EQUITY     // The equity of the account
  };
//+------------------------------------------------------------------+
//| A trade fully worked out, before anything is sent: what the      |
//| calculation gives and what the sending reads                     |
//+------------------------------------------------------------------+
struct STradePlan
  {
   ENUM_POSITION_TYPE direction;     // Buy or Sell
   ENUM_ORDER_TYPE    order_type;    // The order type that is sent (market, or a pending one)
   bool               is_pending;    // true for a limit or a stop entry
   double             entry_price;   // Where the trade is meant to be entered, not always the price of now
   double             stop_loss;     // 0 = none
   double             take_profit;   // 0 = none
   double             stop_distance; // From the entry to the stop loss, in price units
   double             lot_size;
   double             risk_amount;   // What the stop makes the trade lose, in the currency of the account (0 = unknown)
  };
#endif // __RISK_MANAGEMENT_DEFINE_MQH__
