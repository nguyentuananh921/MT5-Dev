//+------------------------------------------------------------------+
//|                                          MultiSymbolCCIAO_EA.mq5 |
//|                           Copyright 2025, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Allan Munene Mutiiria."
#property link      "https://t.me/Forex_Algo_Trader"
#property version   "1.00"
#property strict
#property description "Multi-symbol trading strategy using CCI and AO indicators"

#include <Trade/Trade.mqh> //--- Include the Trade library for trading operations

//+------------------------------------------------------------------+
//| Input Parameters Structure                                       | //--- Define a structure for trading parameters
//+------------------------------------------------------------------+
struct TradingParameters {
   string            symbols;                  //--- Store comma-separated symbol list
   int               per_signal_cci;           //--- Set period for CCI signal
   int               per_trend_cci;            //--- Set period for CCI trend
   ENUM_APPLIED_PRICE price_cci;               //--- Specify applied price for CCI
   int               cci_signal_buy_value;     //--- Define CCI buy signal threshold
   int               cci_signal_sell_value;    //--- Define CCI sell signal threshold
   ENUM_TIMEFRAMES   tf_signal;                //--- Set timeframe for signal
   ENUM_TIMEFRAMES   tf_trend;                 //--- Set timeframe for trend
   bool              use_ao_for_trend;         //--- Enable AO for trend confirmation
   int               take;                     //--- Set take-profit in points
   int               stop;                     //--- Set stop-loss in points
   double            lots;                     //--- Specify trade lot size
   int               slip;                     //--- Set maximum slippage
   int               max_spread;               //--- Define maximum allowed spread
   int               magic;                    //--- Set magic number for trades
   bool              trade_anytime;            //--- Allow trading at any time
   string            comment;                  //--- Store trade comment
   int               tester_max_balance;       //--- Set tester balance limit
   bool              debug_mode;               //--- Enable debug mode
};

//+------------------------------------------------------------------+
//| Symbol Data Structure                                            | //--- Define a structure for symbol-specific data
//+------------------------------------------------------------------+
struct SymbolData {
   string            name;                     //--- Store symbol name
   datetime          last_bar_time;            //--- Track last bar timestamp
   int               cci_signal_handle;        //--- Hold CCI signal indicator handle
   int               cci_trend_handle;         //--- Hold CCI trend indicator handle
   int               ao_signal_handle;         //--- Hold AO signal indicator handle
   int               ao_trend_handle;          //--- Hold AO trend indicator handle
   double            cci_signal_data[];        //--- Store CCI signal data
   double            cci_trend_data[];         //--- Store CCI trend data
   double            ao_signal_data[];         //--- Store AO signal data
   double            ao_trend_data[];          //--- Store AO trend data
};

//+------------------------------------------------------------------+
//| Trading Strategy Class                                           | //--- Implement a class for trading strategy logic
//+------------------------------------------------------------------+
class CTradingStrategy {
private:
   CTrade            m_trade;                  //--- Initialize trade object for trading operations
   TradingParameters m_params;                 //--- Store trading parameters
   SymbolData        m_symbols[];             //--- Store array of symbol data
   int               m_array_size;             //--- Track number of symbols
   datetime          m_last_day;               //--- Store last day timestamp
   bool              m_is_new_day;             //--- Indicate new day detection
   int               m_candle_shift;           //--- Set candle shift for signal calculation
   const int         CCI_TREND_BUY_VALUE;      //--- Define constant for CCI trend buy threshold
   const int         CCI_TREND_SELL_VALUE;     //--- Define constant for CCI trend sell threshold
   
   void PrintDebug(string text) {              //--- Define method to print debug messages
      if(m_params.debug_mode && !MQLInfoInteger(MQL_OPTIMIZATION)) { //--- Check debug mode and optimization status
         Print(text);                          //--- Output debug message
      }
   }
   
   void PrintMessage(string text) {            //--- Define method to print informational messages
      if(!MQLInfoInteger(MQL_OPTIMIZATION)) {  //--- Check if not in optimization mode
         Print(text);                          //--- Output message
      }
   }
   
   void PrepareSymbolsList() {                 //--- Define method to prepare symbol list
      string symbols_array[];                  //--- Initialize temporary array for symbols
      ushort sep = StringGetCharacter(",", 0); //--- Get comma separator character
      m_array_size = StringSplit(m_params.symbols, sep, symbols_array); //--- Split symbols string into array
      ArrayResize(m_symbols, m_array_size);    //--- Resize symbol data array
      for(int i = 0; i < m_array_size; i++) {  //--- Iterate through symbols
         m_symbols[i].name = symbols_array[i]; //--- Set symbol name
         m_symbols[i].last_bar_time = 0;       //--- Initialize last bar time
         SymbolSelect(m_symbols[i].name, true); //--- Ensure symbol is in market watch
      }
   }
   
   bool InitializeIndicators(int index) {      //--- Define method to initialize indicators
      m_symbols[index].cci_signal_handle = iCCI(m_symbols[index].name, m_params.tf_signal, m_params.per_signal_cci, m_params.price_cci); //--- Create CCI signal indicator
      if(m_symbols[index].cci_signal_handle == INVALID_HANDLE) { //--- Check for invalid handle
         Print("INITIALIZATION OF CCI SIGNAL FAILED: ", m_symbols[index].name); //--- Log error
         return false;                         //--- Return failure
      }
      m_symbols[index].cci_trend_handle = iCCI(m_symbols[index].name, m_params.tf_trend, m_params.per_trend_cci, m_params.price_cci); //--- Create CCI trend indicator
      if(m_symbols[index].cci_trend_handle == INVALID_HANDLE) { //--- Check for invalid handle
         Print("INITIALIZATION OF CCI TREND FAILED: ", m_symbols[index].name); //--- Log error
         return false;                         //--- Return failure
      }
      m_symbols[index].ao_signal_handle = iAO(m_symbols[index].name, m_params.tf_signal); //--- Create AO signal indicator
      if(m_symbols[index].ao_signal_handle == INVALID_HANDLE) { //--- Check for invalid handle
         Print("INITIALIZATION OF AO SIGNAL FAILED: ", m_symbols[index].name); //--- Log error
         return false;                         //--- Return failure
      }
      m_symbols[index].ao_trend_handle = iAO(m_symbols[index].name, m_params.tf_trend); //--- Create AO trend indicator
      if(m_symbols[index].ao_trend_handle == INVALID_HANDLE) { //--- Check for invalid handle
         Print("INITIALIZATION OF AO TREND FAILED: ", m_symbols[index].name); //--- Log error
         return false;                         //--- Return failure
      }
      ArraySetAsSeries(m_symbols[index].cci_signal_data, true); //--- Set CCI signal data as series
      ArraySetAsSeries(m_symbols[index].cci_trend_data, true); //--- Set CCI trend data as series
      ArraySetAsSeries(m_symbols[index].ao_signal_data, true); //--- Set AO signal data as series
      ArraySetAsSeries(m_symbols[index].ao_trend_data, true); //--- Set AO trend data as series
      return true;                             //--- Return success
   }
   
   bool UpdateIndicatorData(int index) {       //--- Define method to update indicator data
      if(CopyBuffer(m_symbols[index].cci_signal_handle, 0, 0, 3, m_symbols[index].cci_signal_data) < 3) { //--- Copy CCI signal data
         Print("UNABLE TO COPY CCI SIGNAL DATA: ", m_symbols[index].name); //--- Log error
         return false;                         //--- Return failure
      }
      if(CopyBuffer(m_symbols[index].cci_trend_handle, 0, 0, 3, m_symbols[index].cci_trend_data) < 3) { //--- Copy CCI trend data
         Print("UNABLE TO COPY CCI TREND DATA: ", m_symbols[index].name); //--- Log error
         return false;                         //--- Return failure
      }
      if(CopyBuffer(m_symbols[index].ao_signal_handle, 0, 0, 3, m_symbols[index].ao_signal_data) < 3) { //--- Copy AO signal data
         Print("UNABLE TO COPY AO SIGNAL DATA: ", m_symbols[index].name); //--- Log error
         return false;                         //--- Return failure
      }
      if(CopyBuffer(m_symbols[index].ao_trend_handle, 0, 0, 3, m_symbols[index].ao_trend_data) < 3) { //--- Copy AO trend data
         Print("UNABLE TO COPY AO TREND DATA: ", m_symbols[index].name); //--- Log error
         return false;                         //--- Return failure
      }
      return true;                             //--- Return success
   }
   
   int CountOrders(string symbol, int magic, ENUM_POSITION_TYPE type) { //--- Define method to count orders
      int count = 0;                           //--- Initialize order counter
      for(int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through positions
         ulong ticket = PositionGetTicket(i);   //--- Get position ticket
         if(PositionSelectByTicket(ticket)) {   //--- Select position by ticket
            if(PositionGetInteger(POSITION_MAGIC) == magic && //--- Check magic number
               PositionGetString(POSITION_SYMBOL) == symbol && //--- Check symbol
               PositionGetInteger(POSITION_TYPE) == type) { //--- Check position type
               count++;                        //--- Increment counter
            }
         }
      }
      return count;                            //--- Return order count
   }
   
   long OpenOrder(string symbol, ENUM_ORDER_TYPE type, double price, double sl, double tp, double lots, int magic, string comment) { //--- Define method to open orders
      long ticket = m_trade.PositionOpen(symbol, type, lots, price, sl, tp, comment); //--- Execute position open
      if(ticket < 0) {                         //--- Check for order failure
         PrintMessage(StringFormat("Info - OrderSend %s %d_%s_%.5f error %.5f_%.5f_%.5f_#%d", //--- Log error
            comment, type, symbol, price, price, sl, tp, GetLastError()));
      } else {                                 //--- Handle successful order
         PrintMessage(StringFormat("Info - OrderSend done. Comment:%s, Type:%d, Sym:%s, Price:%.5f, SL:%.5f, TP:%.5f", //--- Log success
            comment, type, symbol, price, sl, tp));
      }
      return ticket;                           //--- Return order ticket
   }

public:
   CTradingStrategy() : CCI_TREND_BUY_VALUE(-114), CCI_TREND_SELL_VALUE(134) { //--- Initialize constructor with constants
      m_last_day = 0;                          //--- Set initial last day
      m_is_new_day = true;                     //--- Set new day flag
      m_array_size = 0;                        //--- Set initial array size
   }
   
   bool Init() {                               //--- Define initialization method
      m_params.symbols = "EURUSDm,GBPUSDm,AUDUSDm"; //--- Set default symbols
      m_params.per_signal_cci = 20;            //--- Set CCI signal period
      m_params.per_trend_cci = 24;             //--- Set CCI trend period
      m_params.price_cci = PRICE_TYPICAL;      //--- Set CCI applied price
      m_params.cci_signal_buy_value = -90;     //--- Set CCI buy signal threshold
      m_params.cci_signal_sell_value = 130;    //--- Set CCI sell signal threshold
      m_params.tf_signal = PERIOD_M5;          //--- Set signal timeframe
      m_params.tf_trend = PERIOD_H1;           //--- Set trend timeframe
      m_params.use_ao_for_trend = false;       //--- Disable AO trend by default
      m_params.take = 200;                     //--- Set take-profit
      m_params.stop = 300;                     //--- Set stop-loss
      m_params.lots = 0.01;                    //--- Set lot size
      m_params.slip = 5;                       //--- Set slippage
      m_params.max_spread = 20;                //--- Set maximum spread
      m_params.magic = 123456789;              //--- Set magic number
      m_params.trade_anytime = false;          //--- Disable trade anytime
      m_params.comment = "EA_AO_BP";           //--- Set trade comment
      m_params.tester_max_balance = 0;         //--- Set tester balance limit
      m_params.debug_mode = false;             //--- Disable debug mode
      
      m_candle_shift = m_params.trade_anytime ? 0 : 1; //--- Set candle shift based on trade mode
      m_trade.SetExpertMagicNumber(m_params.magic); //--- Set magic number for trade object
      
      PrepareSymbolsList();                    //--- Prepare symbol list
      for(int i = 0; i < m_array_size; i++) {  //--- Iterate through symbols
         if(!InitializeIndicators(i)) {         //--- Initialize indicators
            return false;                      //--- Return failure on error
         }
      }
      PrintMessage("Current Spread on " + Symbol() + ": " + //--- Log current spread
         IntegerToString((int)SymbolInfoInteger(Symbol(), SYMBOL_SPREAD)));
      return true;                             //--- Return success
   }
   
   void OnTick() {                             //--- Define tick handling method
      datetime new_day = iTime(Symbol(), PERIOD_D1, 0); //--- Get current day timestamp
      m_is_new_day = (m_last_day != new_day);  //--- Check for new day
      if(m_is_new_day) {                       //--- Handle new day
         m_last_day = new_day;                 //--- Update last day
      }
      
      for(int i = 0; i < m_array_size; i++) {  //--- Iterate through symbols
         bool is_new_bar = false;              //--- Initialize new bar flag
         bool buy_signal = false, sell_signal = false; //--- Initialize signal flags
         bool buy_trend = false, sell_trend = false; //--- Initialize trend flags
         
         datetime new_time = iTime(m_symbols[i].name, m_params.tf_signal, 0); //--- Get current bar time
         if(!m_params.trade_anytime && m_symbols[i].last_bar_time != new_time) { //--- Check for new bar
            is_new_bar = true;                 //--- Set new bar flag
            m_symbols[i].last_bar_time = new_time; //--- Update last bar time
         }
         
         if(!UpdateIndicatorData(i)) continue; //--- Update indicators, skip on failure
         
         double ask = SymbolInfoDouble(m_symbols[i].name, SYMBOL_ASK); //--- Get ask price
         double bid = SymbolInfoDouble(m_symbols[i].name, SYMBOL_BID); //--- Get bid price
         double point = SymbolInfoDouble(m_symbols[i].name, SYMBOL_POINT); //--- Get point value
         long spread = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD); //--- Get current spread
         
         int total_orders = CountOrders(m_symbols[i].name, m_params.magic, POSITION_TYPE_BUY) + //--- Count buy orders
                           CountOrders(m_symbols[i].name, m_params.magic, POSITION_TYPE_SELL); //--- Count sell orders
         
         // Generate signals
         buy_signal = m_symbols[i].cci_signal_data[m_candle_shift+1] < m_params.cci_signal_buy_value && //--- Check CCI buy signal condition
                     m_symbols[i].cci_signal_data[m_candle_shift] > m_params.cci_signal_buy_value && //--- Confirm CCI buy signal
                     m_symbols[i].ao_signal_data[m_candle_shift+1] < m_symbols[i].ao_signal_data[m_candle_shift]; //--- Confirm AO buy signal
                     
         sell_signal = m_symbols[i].cci_signal_data[m_candle_shift+1] > m_params.cci_signal_sell_value && //--- Check CCI sell signal condition
                      m_symbols[i].cci_signal_data[m_candle_shift] < m_params.cci_signal_sell_value && //--- Confirm CCI sell signal
                      m_symbols[i].ao_signal_data[m_candle_shift+1] > m_symbols[i].ao_signal_data[m_candle_shift]; //--- Confirm AO sell signal
         
         buy_trend = m_symbols[i].cci_trend_data[m_candle_shift+1] < m_symbols[i].cci_signal_data[m_candle_shift] && //--- Check CCI trend buy condition
                    m_symbols[i].cci_trend_data[m_candle_shift] > CCI_TREND_BUY_VALUE && //--- Confirm CCI trend buy threshold
                    m_symbols[i].cci_trend_data[m_candle_shift] < CCI_TREND_SELL_VALUE && //--- Confirm CCI trend sell threshold
                    (!m_params.use_ao_for_trend || //--- Check AO trend condition
                     (m_symbols[i].ao_trend_data[m_candle_shift+1] < m_symbols[i].ao_trend_data[m_candle_shift])); //--- Confirm AO trend buy
                     
         sell_trend = m_symbols[i].cci_trend_data[m_candle_shift+1] > m_symbols[i].cci_signal_data[m_candle_shift] && //--- Check CCI trend sell condition
                     m_symbols[i].cci_trend_data[m_candle_shift] > CCI_TREND_BUY_VALUE && //--- Confirm CCI trend buy threshold
                     m_symbols[i].cci_trend_data[m_candle_shift] < CCI_TREND_SELL_VALUE && //--- Confirm CCI trend sell threshold
                     (!m_params.use_ao_for_trend || //--- Check AO trend condition
                      (m_symbols[i].ao_trend_data[m_candle_shift+1] > m_symbols[i].ao_trend_data[m_candle_shift])); //--- Confirm AO trend sell
         
         // Execute trades
         if(spread < m_params.max_spread && total_orders == 0 && //--- Check spread and open orders
            (m_params.trade_anytime || is_new_bar)) { //--- Check trade timing
            if(buy_signal && buy_trend) {         //--- Check buy conditions
               double sl = m_params.stop == 0 ? 0 : ask - m_params.stop * point; //--- Calculate stop-loss
               double tp = m_params.take == 0 ? 0 : ask + m_params.take * point; //--- Calculate take-profit
               OpenOrder(m_symbols[i].name, ORDER_TYPE_BUY, ask, sl, tp, m_params.lots, //--- Open buy order
                        m_params.magic, "Open BUY " + m_params.comment);
            }
            if(sell_signal && sell_trend) {       //--- Check sell conditions
               double sl = m_params.stop == 0 ? 0 : bid + m_params.stop * point; //--- Calculate stop-loss
               double tp = m_params.take == 0 ? 0 : bid - m_params.take * point; //--- Calculate take-profit
               OpenOrder(m_symbols[i].name, ORDER_TYPE_SELL, bid, sl, tp, m_params.lots, //--- Open sell order
                        m_params.magic, "Open SELL " + m_params.comment);
            }
         }
         
         // Debug output
         if((m_params.trade_anytime || is_new_bar) && (buy_signal || sell_signal)) { //--- Check debug conditions
            PrintDebug(StringFormat("Debug - IsNewBar: %b - candle_shift: %d - buy_signal: %b - " //--- Log debug information
                                  "sell_signal: %b - buy_trend: %b - sell_trend: %b",
                                  is_new_bar, m_candle_shift, buy_signal, sell_signal, 
                                  buy_trend, sell_trend));
         }
      }
   }
   
   bool CloseAllTrades() {                     //--- Define method to close all trades
      for(int i = PositionsTotal() - 1; i >= 0; i--) { //--- Iterate through positions
         ulong ticket = PositionGetTicket(i);   //--- Get position ticket
         if(PositionSelectByTicket(ticket) &&   //--- Select position
            PositionGetInteger(POSITION_MAGIC) == m_params.magic) { //--- Check magic number
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); //--- Get position type
            if(type == POSITION_TYPE_BUY || type == POSITION_TYPE_SELL) { //--- Check position type
               m_trade.PositionClose(ticket);   //--- Close position
               PrintMessage("Position close " + IntegerToString(ticket)); //--- Log closure
            }
         }
      }
      for(int i = OrdersTotal() - 1; i >= 0; i--) { //--- Iterate through orders
         ulong ticket = OrderGetTicket(i);      //--- Get order ticket
         if(OrderSelect(ticket) && OrderGetInteger(ORDER_MAGIC) == m_params.magic) { //--- Select order and check magic
            ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE); //--- Get order type
            if(type >= ORDER_TYPE_BUY_STOP && type <= ORDER_TYPE_SELL_LIMIT) { //--- Check order type
               m_trade.OrderDelete(ticket);   //--- Delete order
               PrintMessage("Order delete " + IntegerToString(ticket)); //--- Log deletion
            }
         }
      }
      return true;                             //--- Return success
   }
};

//+------------------------------------------------------------------+
//| Global Variables and Functions                                   | //--- Define global variables and functions
//+------------------------------------------------------------------+
CTradingStrategy g_strategy;                   //--- Initialize global strategy object

//+------------------------------------------------------------------+
//| Expert Advisor Functions                                         | //--- Define EA core functions
//+------------------------------------------------------------------+
int OnInit() {                                 //--- Define initialization function
   return g_strategy.Init() ? INIT_SUCCEEDED : INIT_FAILED; //--- Initialize strategy and return status
}

void OnDeinit(const int reason) {              //--- Define deinitialization function
   g_strategy.CloseAllTrades();                //--- Close all trades
}

void OnTick() {                                //--- Define tick processing function
   g_strategy.OnTick();                        //--- Process tick event
}
//+------------------------------------------------------------------+