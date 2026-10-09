//+------------------------------------------------------------------+
//|                                                EventDefines.mqh |
//| Event code chain: every group starts at the NEXT_CODE of the     |
//| previous one so codes sent through EventChartCustom never clash  |
//+------------------------------------------------------------------+
#ifndef __EVENT_DEFINES_MQH__
#define __EVENT_DEFINES_MQH__
 #define EVENTS_START_CODE   (100) // Model events start above every ON_* GUI code (GUIDefines.mqh, keep those < 100)
 enum ENUM_SYMBOLTF_MANAGER_EVENT
  {
   SYMBOLTF_MANAGER_EVENT_NO_EVENT = EVENTS_START_CODE,
   SYMBOLTF_MANAGER_EVENT_ADDED,
   SYMBOLTF_MANAGER_EVENT_DELETE,
   SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED,
   SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED,
  };
  
 #define SYMBOLTF_MANAGER_EVENTS_NEXT_CODE  (SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED+1)
 enum ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT
  {
   INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT = SYMBOLTF_MANAGER_EVENTS_NEXT_CODE,
   INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED,     // a row (type,params) was added, lparam = type
   INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE,    // a row (type,params) was removed, lparam = type
   INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED,   // a Buy / Sell flag changed, lparam = row position (-1: several)
   INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED,      // a row was attached to / detached from the chart, lparam = row position
  };
 #define INDICATOR_TEMPLATE_MANAGER_EVENTS_NEXT_CODE  (INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED+1)
 //+------------------------------------------------------------------+
 //| List of possible symbol events in the Market Watch window        |
 //+------------------------------------------------------------------+
 enum ENUM_PATTERN_MANAGER_EVENT
  {
   PATTERN_MANAGER_EVENT_NO_EVENT = INDICATOR_TEMPLATE_MANAGER_EVENTS_NEXT_CODE,
   PATTERN_MANAGER_EVENT_BUYSELL_CHANGED,      // a pattern Buy / Sell flag changed, sparam = pattern name (empty: several)
   PATTERN_MANAGER_EVENT_CATALOG_CHANGED,      // Python sent the pattern catalog and it changed the list
  };
 #define PATTERN_MANAGER_EVENTS_NEXT_CODE  (PATTERN_MANAGER_EVENT_CATALOG_CHANGED+1)
 enum ENUM_MW_EVENT
  {
   MARKET_WATCH_EVENT_NO_EVENT = PATTERN_MANAGER_EVENTS_NEXT_CODE,  // No event
   MARKET_WATCH_EVENT_SYMBOL_ADD,                           // Adding a symbol to the Market Watch window
   MARKET_WATCH_EVENT_SYMBOL_DEL,                           // Removing a symbol from the Market Watch window
   MARKET_WATCH_EVENT_SYMBOL_SORT,                          // Sorting symbols in the Market Watch window
  };
 #define SYMBOL_EVENTS_NEXT_CODE  (MARKET_WATCH_EVENT_SYMBOL_SORT+1)  // The code of the next event after the last symbol event code
 enum ENUM_CHART_OBJ_EVENT
  {
   CHART_OBJ_EVENT_NO_EVENT = SYMBOL_EVENTS_NEXT_CODE,      // No event
   CHART_OBJ_EVENT_CHART_SYMB_CHANGE,                       // "Chart symbol changed" event
   CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE,                    // "Chart symbol and timeframe changed" event
   CHART_OBJ_EVENT_CHART_TF_CHANGE,                         // "Chart timeframe changed" event
   CHART_OBJ_EVENT_CHART_WND_IND_ADD,                       // "Adding a new indicator to the chart window" event
   CHART_OBJ_EVENT_CHART_WND_IND_DEL,                       // "Removing an indicator from the chart window" event
   CHART_OBJ_EVENT_CHART_WND_IND_CHANGE,                    // "Changing indicator parameters in the chart window" event
  };
 #define CHART_OBJ_EVENTS_NEXT_CODE  (CHART_OBJ_EVENT_CHART_WND_IND_CHANGE+1)  // The code of the next event after the last chart event code
 enum ENUM_MOUSE_EVENT
  {
   MOUSE_EVENT_NO_EVENT = CHART_OBJ_EVENTS_NEXT_CODE, // No event
  };
 #define MOUSE_EVENT_NEXT_CODE  (MOUSE_EVENT_NO_EVENT+1)   // The code of the next event after the last mouse event code
 //+------------------------------------------------------------------+
 //| List of trading event flags on the account                       |
 //+------------------------------------------------------------------+
 enum ENUM_TRADE_EVENT_FLAGS
  {
   TRADE_EVENT_FLAG_NO_EVENT        =  0x0,                 // No event
   TRADE_EVENT_FLAG_ORDER_PLASED    =  0x1,                 // Pending order placed
   TRADE_EVENT_FLAG_ORDER_REMOVED   =  0x2,                 // Pending order removed
   TRADE_EVENT_FLAG_ORDER_ACTIVATED =  0x4,                 // Pending order activated by price
   TRADE_EVENT_FLAG_POSITION_OPENED =  0x8,                 // Position opened
   TRADE_EVENT_FLAG_POSITION_CHANGED=  0x10,                // Position changed
   TRADE_EVENT_FLAG_POSITION_REVERSE=  0x20,                // Position reversal
   TRADE_EVENT_FLAG_POSITION_CLOSED =  0x40,                // Position closed
   TRADE_EVENT_FLAG_ACCOUNT_BALANCE =  0x80,                // Balance operation (clarified by a deal type)
   TRADE_EVENT_FLAG_PARTIAL         =  0x100,               // Partial execution
   TRADE_EVENT_FLAG_BY_POS          =  0x200,               // Executed by opposite position
   TRADE_EVENT_FLAG_PRICE           =  0x400,               // Modify the placement price
   TRADE_EVENT_FLAG_SL              =  0x800,               // Executed by StopLoss
   TRADE_EVENT_FLAG_TP              =  0x1000,              // Executed by TakeProfit
   TRADE_EVENT_FLAG_ORDER_MODIFY    =  0x2000,              // Modify an order
   TRADE_EVENT_FLAG_POSITION_MODIFY =  0x4000,              // Modify a position
  };
 //+------------------------------------------------------------------+
 //| List of possible trading events on the account                   |
 //+------------------------------------------------------------------+
 enum ENUM_TRADE_EVENT
  {
   //--- (new constants cannot be removed or added below)
    TRADE_EVENT_NO_EVENT = 0,                                // No trading event
    TRADE_EVENT_PENDING_ORDER_PLASED,                        // Pending order placed
    TRADE_EVENT_PENDING_ORDER_REMOVED,                       // Pending order removed
   //--- enumeration members matching the ENUM_DEAL_TYPE enumeration members
   //--- (constant order below should not be changed, no constants should be added/deleted)
    TRADE_EVENT_ACCOUNT_CREDIT = DEAL_TYPE_CREDIT,           // Charging credit (3)
    TRADE_EVENT_ACCOUNT_CHARGE,                              // Additional charges
    TRADE_EVENT_ACCOUNT_CORRECTION,                          // Correcting entry
    TRADE_EVENT_ACCOUNT_BONUS,                               // Charging bonuses
    TRADE_EVENT_ACCOUNT_COMISSION,                           // Additional commissions
    TRADE_EVENT_ACCOUNT_COMISSION_DAILY,                     // Commission charged at the end of a day
    TRADE_EVENT_ACCOUNT_COMISSION_MONTHLY,                   // Commission charged at the end of a month
    TRADE_EVENT_ACCOUNT_COMISSION_AGENT_DAILY,               // Agent commission charged at the end of a trading day
    TRADE_EVENT_ACCOUNT_COMISSION_AGENT_MONTHLY,             // Agent commission charged at the end of a month
    TRADE_EVENT_ACCOUNT_INTEREST,                            // Accrual of interest on free funds
    TRADE_EVENT_BUY_CANCELLED,                               // Canceled buy deal
    TRADE_EVENT_SELL_CANCELLED,                              // Canceled sell deal
    TRADE_EVENT_DIVIDENT,                                    // Accrual of dividends
    TRADE_EVENT_DIVIDENT_FRANKED,                            // Accrual of franked dividend
    TRADE_EVENT_TAX                        = DEAL_TAX,       // Tax accrual
   //--- constants related to the DEAL_TYPE_BALANCE deal type from the DEAL_TYPE_BALANCE enumeration
    TRADE_EVENT_ACCOUNT_BALANCE_REFILL     = DEAL_TAX+1,     // Replenishing account balance
    TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL = DEAL_TAX+2,     // Withdrawing funds from an account
   //--- Remaining possible trading events
   //--- (constant order below can be changed, constants can be added/deleted)
    TRADE_EVENT_PENDING_ORDER_ACTIVATED    = DEAL_TAX+3,     // Pending order activated by price
    TRADE_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL,             // Pending order partially activated by price
    TRADE_EVENT_POSITION_OPENED,                             // Position opened
    TRADE_EVENT_POSITION_OPENED_PARTIAL,                     // Position opened partially
    TRADE_EVENT_POSITION_CLOSED,                             // Position closed
    TRADE_EVENT_POSITION_CLOSED_BY_POS,                      // Position closed by an opposite one
    TRADE_EVENT_POSITION_CLOSED_BY_SL,                       // Position closed by StopLoss
    TRADE_EVENT_POSITION_CLOSED_BY_TP,                       // Position closed by TakeProfit
    TRADE_EVENT_POSITION_REVERSED_BY_MARKET,                 // Position reversal by a new deal (netting)
    TRADE_EVENT_POSITION_REVERSED_BY_PENDING,                // Position reversal by activating a pending order (netting)
    TRADE_EVENT_POSITION_REVERSED_BY_MARKET_PARTIAL,         // Position reversal by partial market order execution (netting)
    TRADE_EVENT_POSITION_REVERSED_BY_PENDING_PARTIAL,        // Position reversal by activating a pending order (netting)
    TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET,               // Added volume to a position by a new deal (netting)
    TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET_PARTIAL,       // Added volume to a position by partial execution of a market order (netting)
    TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING,              // Added volume to a position by activating a pending order (netting)
    TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING_PARTIAL,      // Added volume to a position by partial activation of a pending order (netting)
    TRADE_EVENT_POSITION_CLOSED_PARTIAL,                     // Position closed partially
    TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS,              // Position partially closed by an opposite one
    TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL,               // Position closed partially by StopLoss
    TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP,               // Position closed partially by TakeProfit
    TRADE_EVENT_TRIGGERED_STOP_LIMIT_ORDER,                  // StopLimit order activation
    TRADE_EVENT_MODIFY_ORDER_PRICE,                          // Changing order price
    TRADE_EVENT_MODIFY_ORDER_PRICE_SL,                       // Changing order and StopLoss price 
    TRADE_EVENT_MODIFY_ORDER_PRICE_TP,                       // Changing order and TakeProfit price
    TRADE_EVENT_MODIFY_ORDER_PRICE_SL_TP,                    // Changing order, StopLoss and TakeProfit price
    TRADE_EVENT_MODIFY_ORDER_SL_TP,                          // Changing order's StopLoss and TakeProfit price
    TRADE_EVENT_MODIFY_ORDER_SL,                             // Changing order's StopLoss
    TRADE_EVENT_MODIFY_ORDER_TP,                             // Changing order's TakeProfit
    TRADE_EVENT_MODIFY_POSITION_SL_TP,                       // Changing position's StopLoss and TakeProfit
    TRADE_EVENT_MODIFY_POSITION_SL,                          // Change position's StopLoss
    TRADE_EVENT_MODIFY_POSITION_TP,                          // Change position's TakeProfit
  };
#endif // __EVENT_DEFINES_MQH__
