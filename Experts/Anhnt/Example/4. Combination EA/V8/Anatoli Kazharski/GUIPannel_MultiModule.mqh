//+------------------------------------------------------------------+
//|                                     GUIPannel_MultiModule.mqh    |
//|   Implementation of function using in multi module GUI Pannel    |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_MultiModule_MQH
#define CGUIPANNEL_MultiModule_MQH 
 // Used in: UpdateStatusBar (Deposit Load status bar item).          |
 //+------------------------------------------------------------------+
 double CGUIPannel::DepositLoad(const bool percent_mode, const double price = 0.0, const string symbol = "", const double volume = 0.0)
 { 
   //--- Calculate the current value of the deposit load
    double margin = 0.0;
   //--- Total account load
    if (symbol == "" || volume == 0.0)
      margin = ::AccountInfoDouble(ACCOUNT_MARGIN);
   //--- Load on a specified symbol
    else
     {
      //--- Get margin calculation data
       double leverage = ((double)::AccountInfoInteger(ACCOUNT_LEVERAGE) == 0)
                            ? 1
                            : (double)::AccountInfoInteger(ACCOUNT_LEVERAGE);
       double contract_size = ::SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
       string account_currency = ::AccountInfoString(ACCOUNT_CURRENCY);
       string base_currency = ::SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE);
      //--- If trading account currency is the same as the symbol base currency
       if (account_currency == base_currency)
         margin = (volume * contract_size) / leverage;
       else
         margin = (volume * contract_size) / leverage * price;
     }
    //--- Get the current funds
     double equity = (::AccountInfoDouble(ACCOUNT_EQUITY) == 0)
                    ? 1
                    : ::AccountInfoDouble(ACCOUNT_EQUITY);
    //--- Return the current deposit load
     return ((!percent_mode) ? margin : (margin / equity) * 100);
 }

#endif