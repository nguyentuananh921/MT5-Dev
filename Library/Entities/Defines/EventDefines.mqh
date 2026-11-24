//+------------------------------------------------------------------+
//|                                                 EventDefines.mqh |
//| Event code chain: every group starts at the NEXT_CODE of the     |
//| previous one so codes sent through EventChartCustom never clash  |
//+------------------------------------------------------------------+
#ifndef __EVENTDEFINES_MQH__
#define __EVENTDEFINES_MQH__
 #define EVENTS_START_CODE   (100) // The first code of the chain
 //+------------------------------------------------------------------+
 //| Events of the chart: its indicators (lparam = the index in the   |
 //| window, dparam = the window, sparam = the short name), its       |
 //| objects (lparam = ObjectsTotal of the chart)                     |
 //+------------------------------------------------------------------+
 enum ENUM_CHART_OBJ_EVENT
  {
   CHART_OBJ_EVENT_NO_EVENT = EVENTS_START_CODE,            // No event
   CHART_OBJ_EVENT_CHART_WND_IND_ADD,                       // "Adding a new indicator to the chart window" event
   CHART_OBJ_EVENT_CHART_WND_IND_DEL,                       // "Removing an indicator from the chart window" event
   CHART_OBJ_EVENT_CHART_WND_IND_CHANGE,                    // "Changing indicator parameters in the chart window" event
   CHART_OBJ_EVENT_OBJECTS_CHANGE,                          // "The objects of the chart changed" event (the terminal or a program made or deleted one: the arrows of a trade)
   CHART_OBJ_EVENT_VISIBLE_CHANGE,                          // The chart shows other bars or prices (scrolled, zoomed, the price scale): lparam CBaseObj::EventPack (the oldest bar shown, how many bars, is_new: older bars came into view), dparam its TF, sparam its symbol
  };
 #define CHART_OBJ_EVENTS_NEXT_CODE  (CHART_OBJ_EVENT_VISIBLE_CHANGE+1)  // The code of the next event after the last chart event code
 enum ENUM_MOUSE_EVENT
  {
   MOUSE_EVENT_NO_EVENT = CHART_OBJ_EVENTS_NEXT_CODE, // No event
  };
 #define MOUSE_EVENT_NEXT_CODE  (MOUSE_EVENT_NO_EVENT+1)   // The code of the next event after the last mouse event code
 //+------------------------------------------------------------------+
 //| GUI events of a window                                           |
 //+------------------------------------------------------------------+
 enum ENUM_WINDOW_EVENT
  {
   WINDOW_EVENT_NO_EVENT = MOUSE_EVENT_NEXT_CODE,           // No event
   WINDOW_EVENT_EXPAND,                                     // The window was expanded
   WINDOW_EVENT_COLLAPSE,                                   // The window was collapsed
   WINDOW_EVENT_CHANGE_XSIZE,                               // The width of the window changed
   WINDOW_EVENT_CHANGE_YSIZE,                               // The height of the window changed
   WINDOW_EVENT_TOOLTIPS,                                   // The tooltips button was clicked
   WINDOW_EVENT_OPEN_DIALOG_BOX,                            // A window opened
   WINDOW_EVENT_CLOSE_DIALOG_BOX,                           // A window closed
   WINDOW_EVENT_BRING_TO_TOP,                               // A child was shown on top of the windows
  };
 #define WINDOW_EVENTS_NEXT_CODE  (WINDOW_EVENT_BRING_TO_TOP+1)  // The code of the next event after the last window event code
 //+------------------------------------------------------------------+
 //| GUI events of a click                                            |
 //+------------------------------------------------------------------+
 enum ENUM_CLICK_EVENT
  {
   CLICK_EVENT_NO_EVENT = WINDOW_EVENTS_NEXT_CODE,          // No event
   CLICK_EVENT_BUTTON,                                      // A button was clicked
   CLICK_EVENT_MENU_ITEM,                                   // A menu item was clicked
   CLICK_EVENT_CONTEXTMENU_ITEM,                            // A context menu item was clicked
   CLICK_EVENT_DOUBLE,                                      // A double click
   CLICK_EVENT_CHECKBOX,                                    // A check box was clicked
   CLICK_EVENT_GROUP_BUTTON,                                // A button of a group of buttons was clicked
   CLICK_EVENT_TAB,                                         // A tab was clicked
   CLICK_EVENT_INC,                                         // The increase button was clicked
   CLICK_EVENT_DEC,                                         // The decrease button was clicked
   CLICK_EVENT_COMBOBOX_BUTTON,                             // The button of a combo box was clicked
   CLICK_EVENT_LIST_ITEM,                                   // An item of a list was clicked
   CLICK_EVENT_COMBOBOX_ITEM,                               // An item of the list of a combo box was chosen
  };
 #define CLICK_EVENTS_NEXT_CODE  (CLICK_EVENT_COMBOBOX_ITEM+1)  // The code of the next event after the last click event code
 //+------------------------------------------------------------------+
 //| GUI events of a change in the state of the controls              |
 //+------------------------------------------------------------------+
 enum ENUM_CHANGE_EVENT
  {
   CHANGE_EVENT_NO_EVENT = CLICK_EVENTS_NEXT_CODE,          // No event
   CHANGE_EVENT_MOUSE_LEFT_BUTTON,                          // The state of the left mouse button changed
   CHANGE_EVENT_SET_AVAILABLE,                              // lparam = the control, dparam = 0 locks the other branches of its parent, 1 unlocks them
   CHANGE_EVENT_END_EDIT,                                   // The text of an edit box was edited
   CHANGE_EVENT_TREE_PATH,                                  // The path of a tree view changed
   CHANGE_EVENT_SORT_DATA,                                  // The data of a table were sorted
   CHANGE_EVENT_SCROLL,                                     // A scroll bar moved
   CHANGE_EVENT_TABLE_COLUMNS,                              // The columns of a table were shown, hidden or moved: lparam ObjectID of the table
  };
 #define CHANGE_EVENTS_NEXT_CODE  (CHANGE_EVENT_TABLE_COLUMNS+1)  // The code of the next event after the last change event code
 //+------------------------------------------------------------------+
 //| Events of the markers on the candles                             |
 //+------------------------------------------------------------------+
 enum ENUM_BAR_MARKER_EVENT
  {
   BAR_MARKER_EVENT_NO_EVENT = CHANGE_EVENTS_NEXT_CODE,  // No event
   BAR_MARKER_EVENT_ENTER,                               // The cursor entered a bar marker: lparam candle time, dparam badge Y
   BAR_MARKER_EVENT_LEAVE,                               // The cursor left a bar marker: lparam candle time
  };
 #define BAR_MARKER_EVENTS_NEXT_CODE  (BAR_MARKER_EVENT_LEAVE+1)  // The code of the next event after the last bar marker event code
 //+------------------------------------------------------------------+
 //| Events of the box of a planned trade                             |
 //+------------------------------------------------------------------+
 enum ENUM_TRADE_SETUP_EVENT
  {
   TRADE_SETUP_EVENT_NO_EVENT = BAR_MARKER_EVENTS_NEXT_CODE,  // No event
   TRADE_SETUP_EVENT_SEND,                                  // Send order clicked: lparam SIGNAL_DIRECTION_BUY/SELL, dparam lots (the lot chosen, <= MaxLot of the risk), sparam symbol, or "symbol;magic" (the magic typed in the panel). From CButton, not the Automation of Entry x Order: no spread gate; the risk tiers as usual, or the lot alone without SL / TP when the risk makes no plan
   TRADE_SETUP_EVENT_CLOSE,                                 // Close icon clicked: lparam SIGNAL_DIRECTION_BUY/SELL, sparam symbol
   TRADE_SETUP_EVENT_CLOSE_ALL,                             // Close all positions clicked (emergency, no confirmation): every position of the account
  };
 #define TRADE_SETUP_EVENTS_NEXT_CODE  (TRADE_SETUP_EVENT_CLOSE_ALL+1)  // The code of the next event after the last trade setup event code
 //+------------------------------------------------------------------+
 //| Events of the bubbles of the trading levels                      |
 //+------------------------------------------------------------------+
 enum ENUM_BUBBLE_EVENT
  {
   BUBBLE_EVENT_NO_EVENT = TRADE_SETUP_EVENTS_NEXT_CODE,    // No event
   BUBBLE_EVENT_PRESS,                                      // A bubble was pressed
   BUBBLE_EVENT_RELEASE,                                    // A bubble was released
   BUBBLE_EVENT_CLOSE,                                      // A bubble was closed
   BUBBLE_EVENT_RESTORE,                                    // A bubble drop was not applied: the bubbles show the real levels again
  };
 #define BUBBLE_EVENTS_NEXT_CODE  (BUBBLE_EVENT_RESTORE+1)  // The code of the next event after the last bubble event code
 //+------------------------------------------------------------------+
 //| Events of the pairs Symbol + TF the EA cares about               |
 //+------------------------------------------------------------------+
 enum ENUM_SYMBOLTF_MANAGER_EVENT
  {
   SYMBOLTF_MANAGER_EVENT_NO_EVENT = BUBBLE_EVENTS_NEXT_CODE,  // No event
   SYMBOLTF_MANAGER_EVENT_ADDED,                            // A pair was added: lparam = its TF, sparam = its Symbol
   SYMBOLTF_MANAGER_EVENT_DELETE,                           // A pair was removed: lparam = its TF, sparam = its Symbol
   SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED,                  // A pair was picked, the chart goes there: lparam = its TF, sparam = its Symbol
   SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED,                  // The Buy / Sell flag of a pair changed
  };
 #define SYMBOLTF_MANAGER_EVENTS_NEXT_CODE  (SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED+1)  // The code of the next event after the last pair event code
 //+------------------------------------------------------------------+
 //| Events of the indicator templates (lparam = the type of the      |
 //| indicator, sparam = its params: the identity, never a position)  |
 //+------------------------------------------------------------------+
 enum ENUM_INDICATOR_TEMPLATE_MANAGER_EVENT
  {
   INDICATOR_TEMPLATE_MANAGER_EVENT_NO_EVENT = SYMBOLTF_MANAGER_EVENTS_NEXT_CODE,  // No event
   INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED,                  // A template was added
   INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE,                 // A template was removed
   INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED,        // The Buy / Sell flag of a template changed
   INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED,           // The Show on chart flag of a template changed
  };
 #define INDICATOR_TEMPLATE_MANAGER_EVENTS_NEXT_CODE  (INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED+1)  // The code of the next event after the last indicator template event code
 //+------------------------------------------------------------------+
 //| Events of the information of a bar (lparam = its type_infor, the |
 //| identity, never a position; WRONG_VALUE = several of them)       |
 //+------------------------------------------------------------------+
 enum ENUM_BAR_INFORMATION_MANAGER_EVENT
  {
   BAR_INFORMATION_MANAGER_EVENT_NO_EVENT = INDICATOR_TEMPLATE_MANAGER_EVENTS_NEXT_CODE,  // No event
   BAR_INFORMATION_MANAGER_EVENT_SHOW_CHANGED,              // The Show Buy / Show Sell flag of a type changed (WRONG_VALUE: of every type of a group, dparam = the group)
   BAR_INFORMATION_MANAGER_EVENT_SETUP_CHANGED,             // A parameter of a type changed (lparam = the type)
   BAR_INFORMATION_MANAGER_EVENT_RESET_DONE,                // The marks of a type whose parameter changed are deleted (CSyncManager, lparam = the type): the Current worker of Python runs again
  };
 #define BAR_INFORMATION_MANAGER_EVENTS_NEXT_CODE  (BAR_INFORMATION_MANAGER_EVENT_RESET_DONE+1)  // The code of the next event after the last bar information event code
 //+------------------------------------------------------------------+
 //| Timeseries events (CBarTimeSeriesCollection). lparam = the open  |
 //| time of the new bar, dparam = its timeframe, sparam = its symbol |
 //+------------------------------------------------------------------+
 enum ENUM_SERIES_EVENT
  {
   SERIES_EVENTS_NO_EVENT = BAR_INFORMATION_MANAGER_EVENTS_NEXT_CODE,  // No event
   SERIES_EVENTS_NEW_BAR,                                              // A new bar opened on a symbol and timeframe
   SERIES_EVENTS_MISSING_BARS,                                         // Bars were skipped and are filled now: lparam = the bars added at this beat (>1, the market closed is not counted), dparam = the timeframe, sparam = the symbol (V2)
   SERIES_EVENTS_PATTERN,                                              // A row of a pattern was found: lparam = CBaseObj::EventPack, its key = the type of the bar information, dparam = its timeframe, sparam = its symbol (V2 SERIES_EVENTS_PATTERN)
   SERIES_EVENTS_SWING,                                                // A swing was found (CBarSwing): lparam = CBaseObj::EventPack, its time = its pivot bar, dparam = its timeframe, sparam = its symbol
   SERIES_EVENTS_BOS,                                                  // A BOS was found (CBarBOS): lparam = CBaseObj::EventPack, its time = the break bar, dparam = its timeframe, sparam = its symbol
   SERIES_EVENTS_CHOCH,                                                // A CHoCH was found (CBarCHoCH): lparam = CBaseObj::EventPack, its time = the break bar, dparam = its timeframe, sparam = its symbol
   SERIES_EVENTS_SIGNAL,                                               // The signal of an indicator template flipped (CSignal): lparam = CBaseObj::EventPack, its key = the type of the indicator, dparam = its timeframe, sparam = its symbol;the column params of its template
   //--- New in V5: a pivot pattern (Harmonic, Chart Pattern: CBarPattern) before its CONFIRM (the row, SERIES_EVENTS_PATTERN). Live only, RAM only (no row in the table)
   SERIES_EVENTS_PATTERN_FOUND,                                        // Its last pivot is a Pivot Point Reversal, the rule holds: lparam = CBaseObj::EventPack, its time = the bar of the last pivot, its key = the type, dparam = its timeframe, sparam = its symbol
   SERIES_EVENTS_PATTERN_INVALID,                                      // A FOUND whose last pivot did not become the swing: the same contract (its bit on the bar is gone)
  };
 #define SERIES_EVENTS_NEXT_CODE  (SERIES_EVENTS_PATTERN_INVALID+1)  // The code of the next event after the last timeseries event code
 //+------------------------------------------------------------------+
 //| Python bridge events (CPythonBridge, from the files Python makes  |
 //| at its milestones)                                                |
 //+------------------------------------------------------------------+
 enum ENUM_PYTHON_BRIDGE_EVENT
  {
   PYTHON_BRIDGE_EVENT_NO_EVENT = SERIES_EVENTS_NEXT_CODE,  // No event
   PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE,                       // The Current worker wrote the first chunk of every pair of Setting_SymbolTF: what is in the table goes to RAM, the library judges from now on
   PYTHON_BRIDGE_EVENT_CURRENT_START,                       // A Current worker started (again): the library judges nothing until its SYMBOLTF_DONE (one writer for a pair at a time)
  };
 #define PYTHON_BRIDGE_EVENTS_NEXT_CODE  (PYTHON_BRIDGE_EVENT_CURRENT_START+1)  // The code of the next event after the last Python bridge event code
 //+------------------------------------------------------------------+
 //| Tick events (CNewTickObj of a symbol).                           |
 //| lparam = time_msc of the tick, dparam = its Bid, sparam = symbol  |
 //+------------------------------------------------------------------+
 enum ENUM_TICK_EVENT
  {
   TICK_EVENT_NO_EVENT = PYTHON_BRIDGE_EVENTS_NEXT_CODE,   // No event
   TICK_EVENT_PAUSE,                                       // No tick for TICK_PAUSE_SECONDS (a closed market): the hands of the symbol rest (lparam: its last tick)
   TICK_EVENT_RESUME,                                      // The symbol ticks again after a pause: its hands go on
   TICK_EVENT_NEW,                                         // New in V5: a new tick of the symbol (the chart's at OnTick, the others at OnTimer): what follows its ticks refreshes (no asking)
  };
 #define TICK_EVENTS_NEXT_CODE  (TICK_EVENT_NEW+1)  // The code of the next event after the last tick event code
 //+------------------------------------------------------------------+
 //| Market Watch events (V3, CSymbolsCollection::MarketWatchEvents-  |
 //| Control): lparam = CBaseObj::EventPack (when, key = the index of |
 //| the symbol in CSymbolsCollection, is_new = added), sparam = name |
 //+------------------------------------------------------------------+
 enum ENUM_MW_EVENT
  {
   MARKET_WATCH_EVENT_NO_EVENT = TICK_EVENTS_NEXT_CODE,   // No event (the value of an indicator is not an Event: Event.md)
   MARKET_WATCH_EVENT_SYMBOL_ADD,                           // Adding a symbol to the Market Watch window
   MARKET_WATCH_EVENT_SYMBOL_DEL,                           // Removing a symbol from the Market Watch window
   MARKET_WATCH_EVENT_SYMBOL_SORT,                          // Sorting symbols in the Market Watch window
  };
 #define SYMBOL_EVENTS_NEXT_CODE  (MARKET_WATCH_EVENT_SYMBOL_SORT+1)  // The code of the next event after the last symbol event code
 //+------------------------------------------------------------------+
 //| Events of the strategies (CStrategyManager): lparam = the        |
 //| strategy_id, sparam = the slot                                   |
 //+------------------------------------------------------------------+
 enum ENUM_STRATEGY_MANAGER_EVENT
  {
   STRATEGY_MANAGER_EVENT_NO_EVENT = SYMBOL_EVENTS_NEXT_CODE,  // No event
   STRATEGY_MANAGER_EVENT_SLOT_CHANGED,                        // The params or the tf of a slot changed (Setting_StrategyIndicator)
   STRATEGY_MANAGER_EVENT_SHOW_CHANGED,                        // The show_on_chart flag of a strategy changed (Setting_Strategy): its markers are shown or hidden
   STRATEGY_MANAGER_EVENT_ENABLED_CHANGED,                     // New in V5: On / Off in trading changed (Setting_Strategy.trading_enabled): the EA judges it live or not
   STRATEGY_MANAGER_EVENT_AVAILABLE_CHANGED,                   // New in V5: every slot has its source, or not any more (Setting_Strategy.available): Python calculates it or not
  };
 #define STRATEGY_MANAGER_EVENTS_NEXT_CODE  (STRATEGY_MANAGER_EVENT_AVAILABLE_CHANGED+1)  // The code of the next event after the last strategy event code
 //+------------------------------------------------------------------+
 //| Events of the results of a strategy on a pair (CStrategyBase,    |
 //| the rows Python found): lparam = CBaseObj::EventPack, its key =  |
 //| the strategy_id, dparam = the timeframe, sparam = the symbol     |
 //+------------------------------------------------------------------+
 enum ENUM_STRATEGY_EVENT
  {
   STRATEGY_EVENT_NO_EVENT = STRATEGY_MANAGER_EVENTS_NEXT_CODE,  // No event
   STRATEGY_EVENT_ENTRY,                                         // The strategy enters: the side is the one it opens
   STRATEGY_EVENT_EXIT,                                          // The strategy exits: the side is the one it closes
  };
 #define STRATEGY_EVENTS_NEXT_CODE  (STRATEGY_EVENT_EXIT+1)  // The code of the next event after the last strategy result event code
 //+------------------------------------------------------------------+
 //| Events of the account (CAccount): lparam = CBaseObj::EventPack,  |
 //| its time = when, its key = the property (ENUM_ACCOUNT_PROP_*),   |
 //| its side = up (BUY) / down (SELL); dparam = the change           |
 //+------------------------------------------------------------------+
 //--- New in V5 (was id = the property itself, as DoEasy: out of this chain, the same numbers as ENUM_TRADE_EVENT)
 enum ENUM_ACCOUNT_EVENT
  {
   ACCOUNT_EVENT_NO_EVENT = STRATEGY_EVENTS_NEXT_CODE,      // No event
   ACCOUNT_EVENT_PROPERTY_CHANGED,                          // A property of the account changed over its controlled value
  };
 #define ACCOUNT_EVENTS_NEXT_CODE  (ACCOUNT_EVENT_PROPERTY_CHANGED+1)  // The code of the next event after the last account event code
 //+------------------------------------------------------------------+
 //| Events of a symbol (CSymbol): lparam = CBaseObj::EventPack, its  |
 //| time = when, its key = the property (ENUM_SYMBOL_PROP_*), its    |
 //| side = up (BUY) / down (SELL); dparam = the change, sparam = the  |
 //| symbol                                                           |
 //+------------------------------------------------------------------+
 //--- New in V5: the symbol tells its own changes (the controlled ones: CSymbolsCollection sets them)
 enum ENUM_SYMBOL_EVENT
  {
   SYMBOL_EVENT_NO_EVENT = ACCOUNT_EVENTS_NEXT_CODE,       // No event
   SYMBOL_EVENT_PROPERTY_CHANGED,                          // A property of the symbol changed over its controlled value
  };
 #define SYMBOL_OBJ_EVENTS_NEXT_CODE  (SYMBOL_EVENT_PROPERTY_CHANGED+1)  // The code of the next event after the last symbol object event code
 //+------------------------------------------------------------------+
 //| Events of the line of a position of a strategy on the chart      |
 //| (CStrategyTrade): lparam = CBaseObj::EventPack, its time = the   |
 //| entry, its key = the strategy_id, its side = the position;       |
 //| dparam = the exit time, sparam = the symbol                      |
 //+------------------------------------------------------------------+
 //--- New in V5
 enum ENUM_STRATEGY_TRADE_EVENT
  {
   STRATEGY_TRADE_EVENT_NO_EVENT = SYMBOL_OBJ_EVENTS_NEXT_CODE,   // No event
   STRATEGY_TRADE_EVENT_CLICK,                                    // The line was clicked: the chart shows its entry and its exit (CChartObj::ShowRange)
  };
 #define STRATEGY_TRADE_EVENTS_NEXT_CODE  (STRATEGY_TRADE_EVENT_CLICK+1)  // The code of the next event after the last strategy trade event code
 //+------------------------------------------------------------------+
 //| Events of the risk setting (CRiskSetting, Setting_Risk):         |
 //| dparam = the new value, sparam = the name of the key             |
 //+------------------------------------------------------------------+
 enum ENUM_RISK_SETTING_EVENT
  {
   RISK_SETTING_EVENT_NO_EVENT = STRATEGY_TRADE_EVENTS_NEXT_CODE,  // No event
   RISK_SETTING_EVENT_CHANGED,                                     // A key of Setting_Risk changed its value
  };
 #define RISK_SETTING_EVENTS_NEXT_CODE  (RISK_SETTING_EVENT_CHANGED+1)  // The code of the next event after the last risk setting event code
 //+------------------------------------------------------------------+
 //| Events of the risk (CTradingControl, TradingControl_Risk.mqh):    |
 //| lparam = CBaseObj::EventPack, its time = the bar of the Entry,   |
 //| its key = the strategy_id, its side = the side; dparam = the      |
 //| tier that blocked (0 trade, 1 basket, 2 portfolio), sparam = the |
 //| symbol                                                           |
 //+------------------------------------------------------------------+
 //--- New in V5
 enum ENUM_RISK_EVENT
  {
   RISK_EVENT_NO_EVENT = RISK_SETTING_EVENTS_NEXT_CODE,            // No event
   RISK_EVENT_ENTRY_BLOCKED,                                       // An Entry of a strategy is not traded: its plan failed a risk check (the log tells which)
  };
 #define RISK_EVENTS_NEXT_CODE  (RISK_EVENT_ENTRY_BLOCKED+1)  // The code of the next event after the last risk event code
 //+------------------------------------------------------------------+
 //| List of trading event flags on the account                       |
 //+------------------------------------------------------------------+
 enum ENUM_TRADE_EVENT_FLAGS
  {
   TRADE_EVENT_FLAG_NO_EVENT        =  0x0,                 // No event
   TRADE_EVENT_FLAG_ORDER_PLACED    =  0x1,                 // Pending order placed
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
 #define TRADE_EVENTS_NEXT_CODE   (TRADE_EVENT_MODIFY_POSITION_TP+1)  // The code of the next event after the last trading event code (V1)
#endif // __EVENTDEFINES_MQH__
