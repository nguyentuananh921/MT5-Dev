//+------------------------------------------------------------------+
//|                                               EventDefines.mqh   |
//|  Complete event-code chain for Artyom Trishkin's DoEasy library  |
//|  All event enums in sequence - no cross-file includes needed     |
//|  Extracted from Artyom Trishkin's DoEasy Defines.mqh             |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __EVENT_DEFINES_MQH__
#define __EVENT_DEFINES_MQH__
#include "CommonDefines.mqh"

//------ 1. Trading events -----------------------------------------------
//+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| Data for working with account events                             |
 //+------------------------------------------------------------------+
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
 #define TRADE_EVENTS_NEXT_CODE   (TRADE_EVENT_MODIFY_POSITION_TP+1)  // The code of the next event after the last trading event code
 // Next-code after last account event (no account-event enum)
 #define ACCOUNT_EVENTS_NEXT_CODE       (TRADE_EVENTS_NEXT_CODE+1) // The code of the next event after the last account event code
//------ 2. Market Watch (Symbol) events --------------------------------
 //+------------------------------------------------------------------+
 //| List of possible symbol events in the Market Watch window        |
 //+------------------------------------------------------------------+
 enum ENUM_MW_EVENT
  {
   MARKET_WATCH_EVENT_NO_EVENT = ACCOUNT_EVENTS_NEXT_CODE,  // No event
   MARKET_WATCH_EVENT_SYMBOL_ADD,                           // Adding a symbol to the Market Watch window
   MARKET_WATCH_EVENT_SYMBOL_DEL,                           // Removing a symbol from the Market Watch window
   MARKET_WATCH_EVENT_SYMBOL_SORT,                          // Sorting symbols in the Market Watch window
  };
 #define SYMBOL_EVENTS_NEXT_CODE  (MARKET_WATCH_EVENT_SYMBOL_SORT+1)  // The code of the next event after the last symbol event code
 //+------------------------------------------------------------------+
//------ 3. Timeseries events -------------------------------------------
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| List of possible timeseries events                               |
 //+------------------------------------------------------------------+
 enum ENUM_SERIES_EVENT
  {
   SERIES_EVENTS_NO_EVENT = SYMBOL_EVENTS_NEXT_CODE,        // No event
   SERIES_EVENTS_NEW_BAR,                                   // "New bar" event
   SERIES_EVENTS_MISSING_BARS,                              // "Bars skipped" event
   SERIES_EVENTS_PATTERN,                                   // "Pattern" event
  };
 #define SERIES_EVENTS_NEXT_CODE  (SERIES_EVENTS_PATTERN+1)  // Code of the next event after the "Pattern" event
//------ 4. Chart-domain event next-codes -------------------------------
 //+------------------------------------------------------------------+
 //| List of possible DOM events                                      |
 //+------------------------------------------------------------------+
 #define MBOOK_ORD_EVENTS_NEXT_CODE  (SERIES_EVENTS_NEXT_CODE+1)   // The code of the next event after the last DOM event code
 //+------------------------------------------------------------------+
 //| The list of possible signal events                               |
 //+------------------------------------------------------------------+
 #define SIGNAL_MQL5_EVENTS_NEXT_CODE  (MBOOK_ORD_EVENTS_NEXT_CODE+1)   // The code of the next event after the last signal event code

//------ 5. Chart object events -----------------------------------------
 //+------------------------------------------------------------------+
 //| Data for working with charts                                     |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| List of possible chart events                                    |
 //+------------------------------------------------------------------+
 enum ENUM_CHART_OBJ_EVENT
  {
   CHART_OBJ_EVENT_NO_EVENT = SIGNAL_MQL5_EVENTS_NEXT_CODE, // No event
   CHART_OBJ_EVENT_CHART_OPEN,                        // "New chart opening" event
   CHART_OBJ_EVENT_CHART_CLOSE,                       // "Chart closure" event
   CHART_OBJ_EVENT_CHART_SYMB_CHANGE,                 // "Chart symbol changed" event
   CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE,              // "Chart symbol and timeframe changed" event
   CHART_OBJ_EVENT_CHART_TF_CHANGE,                   // "Chart timeframe changed" event
   CHART_OBJ_EVENT_CHART_WND_ADD,                     // "Adding a new window on the chart" event
   CHART_OBJ_EVENT_CHART_WND_DEL,                     // "Removing a window from the chart" event
   CHART_OBJ_EVENT_CHART_WND_IND_ADD,                 // "Adding a new indicator to the chart window" event
   CHART_OBJ_EVENT_CHART_WND_IND_DEL,                 // "Removing an indicator from the chart window" event
   CHART_OBJ_EVENT_CHART_WND_IND_CHANGE,              // "Changing indicator parameters in the chart window" event
  };
 #define CHART_OBJ_EVENTS_NEXT_CODE  (CHART_OBJ_EVENT_CHART_WND_IND_CHANGE+1)  // The code of the next event after the last chart event code
//------ 6. Mouse events ------------------------------------------------
 //+------------------------------------------------------------------+
 //| List of possible mouse events                                    |
 //+------------------------------------------------------------------+
 enum ENUM_MOUSE_EVENT
  {
    MOUSE_EVENT_NO_EVENT = CHART_OBJ_EVENTS_NEXT_CODE, // No event
   //---
    MOUSE_EVENT_OUTSIDE_FORM_NOT_PRESSED,              // The cursor is outside the form, the mouse buttons are not clicked
    MOUSE_EVENT_OUTSIDE_FORM_PRESSED,                  // The cursor is outside the form, the mouse button (any) is clicked
    MOUSE_EVENT_OUTSIDE_FORM_WHEEL,                    // The cursor is outside the form, the mouse wheel is being scrolled
   //--- Within the form
    MOUSE_EVENT_INSIDE_FORM_NOT_PRESSED,               // The cursor is inside the form, no mouse buttons are clicked
    MOUSE_EVENT_INSIDE_FORM_PRESSED,                   // The cursor is inside the form, the mouse button (any) is clicked
    MOUSE_EVENT_INSIDE_FORM_WHEEL,                     // The cursor is inside the form, the mouse wheel is being scrolled
   //--- Within the window active area
    MOUSE_EVENT_INSIDE_ACTIVE_AREA_NOT_PRESSED,        // The cursor is inside the active area, the mouse buttons are not clicked
    MOUSE_EVENT_INSIDE_ACTIVE_AREA_PRESSED,            // The cursor is inside the active area, any mouse button is clicked
    MOUSE_EVENT_INSIDE_ACTIVE_AREA_WHEEL,              // The cursor is inside the active area, the mouse wheel is being scrolled
    MOUSE_EVENT_INSIDE_ACTIVE_AREA_RELEASED,           // The cursor is inside the active area, left mouse button is released
   //--- Within the window scrolling area to the right
    MOUSE_EVENT_INSIDE_SCROLL_AREA_RIGHT_NOT_PRESSED,  // The cursor is within the window scrolling area to the right, the mouse buttons are not clicked
    MOUSE_EVENT_INSIDE_SCROLL_AREA_RIGHT_PRESSED,      // The cursor is within the window scrolling area to the right, the mouse button (any) is clicked
    MOUSE_EVENT_INSIDE_SCROLL_AREA_RIGHT_WHEEL,        // The cursor is within the window scrolling area to the right, the mouse wheel is being scrolled
   //--- Within the window scrolling area at the bottom
    MOUSE_EVENT_INSIDE_SCROLL_AREA_BOTTOM_NOT_PRESSED, // The cursor is within the window scrolling area at the bottom, the mouse buttons are not clicked
    MOUSE_EVENT_INSIDE_SCROLL_AREA_BOTTOM_PRESSED,     // The cursor is within the window scrolling area at the bottom, the mouse button (any) is clicked
    MOUSE_EVENT_INSIDE_SCROLL_AREA_BOTTOM_WHEEL,       // The cursor is within the window scrolling area at the bottom, the mouse wheel is being scrolled
   //--- Within the window resizing area at the top
    MOUSE_EVENT_INSIDE_RESIZE_TOP_AREA_NOT_PRESSED,    // The cursor is within the window resizing area at the top, the mouse buttons are not clicked
    MOUSE_EVENT_INSIDE_RESIZE_TOP_AREA_PRESSED,        // The cursor is within the window resizing area at the top, the mouse button (any) is clicked
    MOUSE_EVENT_INSIDE_RESIZE_TOP_AREA_WHEEL,          // The cursor is within the window resizing area at the top, the mouse wheel is being scrolled
   //--- Within the window resizing area at the bottom
    MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_AREA_NOT_PRESSED, // The cursor is within the window resizing area at the bottom, the mouse buttons are not clicked
    MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_AREA_PRESSED,     // The cursor is within the window resizing area at the bottom, the mouse button (any) is clicked
    MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_AREA_WHEEL,       // The cursor is within the window resizing area at the bottom, the mouse wheel is being scrolled
   //--- Within the window resizing area to the left
    MOUSE_EVENT_INSIDE_RESIZE_LEFT_AREA_NOT_PRESSED,   // The cursor is within the window resizing area to the left, the mouse buttons are not clicked
    MOUSE_EVENT_INSIDE_RESIZE_LEFT_AREA_PRESSED,       // The cursor is within the window resizing area to the left, the mouse button (any) is clicked
    MOUSE_EVENT_INSIDE_RESIZE_LEFT_AREA_WHEEL,         // The cursor is within the window resizing area to the left, the mouse wheel is being scrolled
   //--- Within the window resizing area to the right
    MOUSE_EVENT_INSIDE_RESIZE_RIGHT_AREA_NOT_PRESSED,  // The cursor is within the window resizing area to the right, the mouse buttons are not clicked
    MOUSE_EVENT_INSIDE_RESIZE_RIGHT_AREA_PRESSED,      // The cursor is within the window resizing area to the right, the mouse button (any) is clicked
    MOUSE_EVENT_INSIDE_RESIZE_RIGHT_AREA_WHEEL,        // The cursor is within the window resizing area to the right, the mouse wheel is being scrolled
   //--- Within the window resizing area to the top-left
    MOUSE_EVENT_INSIDE_RESIZE_TOP_LEFT_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the top-left, the mouse buttons are not clicked
    MOUSE_EVENT_INSIDE_RESIZE_TOP_LEFT_AREA_PRESSED,   // The cursor is within the window resizing area at the top-left, the mouse button (any) is clicked
    MOUSE_EVENT_INSIDE_RESIZE_TOP_LEFT_AREA_WHEEL,     // The cursor is within the window resizing area at the top-left, the mouse wheel is being scrolled
   //--- Within the window resizing area to the top-right
    MOUSE_EVENT_INSIDE_RESIZE_TOP_RIGHT_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the top-right, the mouse buttons are not clicked
    MOUSE_EVENT_INSIDE_RESIZE_TOP_RIGHT_AREA_PRESSED,  // The cursor is within the window resizing area at the top-right, the mouse button (any) is clicked
    MOUSE_EVENT_INSIDE_RESIZE_TOP_RIGHT_AREA_WHEEL,    // The cursor is within the window resizing area at the top-right, the mouse wheel is being scrolled
   //--- Within the window resizing area at the bottom left
    MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_LEFT_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the bottom-left, the mouse buttons are not clicked
    MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_LEFT_AREA_PRESSED,// The cursor is within the window resizing area at the bottom-left, the mouse button (any) is clicked
    MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_LEFT_AREA_WHEEL,  // The cursor is within the window resizing area at the bottom-left, the mouse wheel is being scrolled
   //--- Within the window resizing area at the bottom-right
    MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the bottom-right, the mouse buttons are not clicked
    MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_PRESSED,// The cursor is within the window resizing area at the bottom-right, the mouse button (any) is clicked
    MOUSE_EVENT_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_WHEEL, // The cursor is within the window resizing area at the bottom-right, the mouse wheel is being scrolled
   //--- Within the control area
    MOUSE_EVENT_INSIDE_CONTROL_AREA_NOT_PRESSED,       // The cursor is within the control area, the mouse buttons are not clicked
    MOUSE_EVENT_INSIDE_CONTROL_AREA_PRESSED,           // The cursor is within the control area, the mouse button (any) is clicked
    MOUSE_EVENT_INSIDE_CONTROL_AREA_WHEEL,             // The cursor is within the control area, the mouse wheel is being scrolled
  };
 #define MOUSE_EVENT_NEXT_CODE  (MOUSE_EVENT_INSIDE_CONTROL_AREA_WHEEL+1)   // The code of the next event after the last mouse event code
//------ 7. Graphical object events -------------------------------------
 //| Data for handling graphical elements                             |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| List of possible graphical object events                         |
 //+------------------------------------------------------------------+
 enum ENUM_GRAPH_OBJ_EVENT
  {
   GRAPH_OBJ_EVENT_NO_EVENT = MOUSE_EVENT_NEXT_CODE,  // No event
   GRAPH_OBJ_EVENT_CREATE,                            // "Creating a new graphical object" event
   GRAPH_OBJ_EVENT_CHANGE,                            // "Changing graphical object properties" event
   GRAPH_OBJ_EVENT_RENAME,                            // "Renaming graphical object" event
   GRAPH_OBJ_EVENT_DELETE,                            // "Removing graphical object" event
   GRAPH_OBJ_EVENT_DEL_CHART,                         // "Removing a graphical object together with the chart window" event
  };
 #define GRAPH_OBJ_EVENTS_NEXT_CODE  (GRAPH_OBJ_EVENT_DEL_CHART+1) // The code of the next event after the last graphical object event code
//------ 8. WinForms control events -------------------------------------
  //+------------------------------------------------------------------+
  //+------------------------------------------------------------------+
  //| List of possible WinForms control events                         |
  //+------------------------------------------------------------------+
  enum ENUM_WF_CONTROL_EVENT
    {
    WF_CONTROL_EVENT_NO_EVENT = GRAPH_OBJ_EVENTS_NEXT_CODE,// No event
    WF_CONTROL_EVENT_CLICK,                            // "Click on the control" event
    WF_CONTROL_EVENT_CLICK_CANCEL,                     // "Canceling the click on the control" event
    WF_CONTROL_EVENT_MOVING,                           // "Control relocation" event
    WF_CONTROL_EVENT_STOP_MOVING,                      // "Control relocation stop" event
    WF_CONTROL_EVENT_TAB_SELECT,                       // "TabControl tab selection" event
    WF_CONTROL_EVENT_CLICK_SCROLL_LEFT,                // "Clicking the control left button" event
    WF_CONTROL_EVENT_CLICK_SCROLL_RIGHT,               // "Clicking the control right button" event
    WF_CONTROL_EVENT_CLICK_SCROLL_UP,                  // "Clicking the control up button" event
    WF_CONTROL_EVENT_CLICK_SCROLL_DOWN,                // "Clicking the control down button" event
  };
#define WF_CONTROL_EVENTS_NEXT_CODE (WF_CONTROL_EVENT_CLICK_SCROLL_DOWN+1)  // The code of the next event after the last graphical element event code

#endif // __EVENT_DEFINES_MQH__
