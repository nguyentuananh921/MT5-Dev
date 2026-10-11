//+------------------------------------------------------------------+
//|                                              TradeManager.mqh    |
//|                                  Copyright 2026, Francis Nyoike. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Francis Nyoike."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Pure Execution & Risk Management Engine                          |
//+------------------------------------------------------------------+
class CTradeManager
  {
private:
   CTrade            trade;
   ulong             magic_number;
   double            fixed_lot;
   double            max_spread_pts;
   bool              enable_trailing;
   int               trailing_start;
   int               trailing_step;

   //--- Internal private environment safety checks
   bool              IsPositionOpen(string symbol);

public:
                     CTradeManager(const ulong magic, const double lot, const double max_spread, const bool use_trail, const int trail_start, const int trail_step);
                    ~CTradeManager(void);

   //--- Primary transactional order entry routers
   bool              ExecuteBuy(const string symbol, const double entry_price, const double sl, const double tp, const string comment);
   bool              ExecuteSell(const string symbol, const double entry_price, const double sl, const double tp, const string comment);

   //--- Post-execution protection tracking maintenance
   void              UpdateTrailingStop(const string symbol);

   //--- Global asset specification multipliers
   double            GetPipMultiplier(const string symbol) const;
  };

//+------------------------------------------------------------------+
//| Parametric Constructor Setup                                     |
//+------------------------------------------------------------------+
CTradeManager::CTradeManager(const ulong magic, const double lot, const double max_spread, const bool use_trail, const int trail_start, const int trail_step)
   : magic_number(magic),
     fixed_lot(lot),
     max_spread_pts(max_spread),
     enable_trailing(use_trail),
     trailing_start(trail_start),
     trailing_step(trail_step)
  {
//--- Configure internal standard trading platform parameters
   trade.SetExpertMagicNumber(magic_number);

//--- Resolve filling mode dynamically to protect against hardcoded type rejection
   uint filling=(uint)SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);
   if((filling & SYMBOL_FILLING_FOK)!=0)
      trade.SetTypeFilling(ORDER_FILLING_FOK);
   else
      if((filling & SYMBOL_FILLING_IOC)!=0)
         trade.SetTypeFilling(ORDER_FILLING_IOC);
      else
         trade.SetTypeFilling(ORDER_FILLING_RETURN);
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeManager::~CTradeManager(void)
  {
  }

//+------------------------------------------------------------------+
//| Calibration Engine for Universal Pip Definition Across Symbols   |
//+------------------------------------------------------------------+
double CTradeManager::GetPipMultiplier(const string symbol) const
  {
//--- Extract native floating point decimal digits from broker asset specifications
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

//--- Return point multiplier scaled for 3/5 digit fractional pricing environments
   return (digits == 3 || digits == 5) ? SymbolInfoDouble(symbol, SYMBOL_POINT) * 10.0 : SymbolInfoDouble(symbol, SYMBOL_POINT);
  }

//+------------------------------------------------------------------+
//| Internal Core Position Existence Scanner                         |
//+------------------------------------------------------------------+
bool CTradeManager::IsPositionOpen(const string symbol)
  {
//--- Scan active trading pool backwards to identify existing tickets safely
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetSymbol(i) == symbol)
        {
         //--- Isolate tracking routine exclusively via your system magic number signature
         if(PositionGetInteger(POSITION_MAGIC) == magic_number)
            return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Standard Buy Order Processing Router                             |
//+------------------------------------------------------------------+
bool CTradeManager::ExecuteBuy(const string symbol, const double entry_price, const double sl, const double tp, const string comment)
  {
//--- DECOUPLED RISK SAFETY GATE
   if(IsPositionOpen(symbol))
      return false;

//--- ACCOUNT FOR LIVE MARKET SPECIFICATIONS
   double current_ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double current_bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

//--- EVALUATE UNEXPECTED SPREAD EXPANSION FILTERS
   double current_spread_points = (current_ask - current_bid) / point;
   if(max_spread_pts > 0 && current_spread_points > max_spread_pts)
     {
      PrintFormat(">>> [TRADE SPREAD BLOCK] Execution rejected on %s. Current Spread: %.1f pts | Max Allowed: %.1f pts", symbol, current_spread_points, max_spread_pts);
      return false;
     }

//--- ALIGN VOLUME SIZES SAFELY WITH THE EXCHANGE CONTRACT STEP SPECS
   double volume_min = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double volume_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double normalized_lot = MathMax(MathFloor(fixed_lot / volume_step) * volume_step, volume_min);

//--- EXPLICITLY EVALUATE VALIDATION SERVER ACCOUNT MARGIN LEVELS
   double required_margin = 0.0;
   if(OrderCalcMargin(ORDER_TYPE_BUY, symbol, normalized_lot, current_ask, required_margin))
     {
      if(AccountInfoDouble(ACCOUNT_MARGIN_FREE) < required_margin)
        {
         PrintFormat(">>> [VALIDATION SAFETY GATE] Buy Order blocked programmatically. Required Margin: %.2f | Free Margin: %.2f", required_margin, AccountInfoDouble(ACCOUNT_MARGIN_FREE));
         return false;
        }
     }

//--- ENFORCE BROKER STOPSLEVEL COMPLIANCE MATRICES
   long broker_stops = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   if(broker_stops <= 0)
      broker_stops = (long)MathMax(current_spread_points * 1.5, 10);
   double stops_level_price = (broker_stops + 2) * point;
   double final_sl = sl;
   double final_tp = tp;

//--- PUSH RECOVERY BOUNDARIES PAST THE INVALID BROKER LIMITS ENVELOPE
   if(final_sl > 0 && (current_ask - final_sl) < stops_level_price)
     {
      final_sl = current_ask - stops_level_price;
     }
   if(final_tp > 0 && (final_tp - current_ask) < stops_level_price)
     {
      final_tp = current_ask + stops_level_price;
     }

//--- INITIALIZE DATA STRUCT PRECISION NORMALIZATION
   final_sl = NormalizeDouble(final_sl, digits);
   final_tp = NormalizeDouble(final_tp, digits);

//--- ROUTE FINAL TRANS-ARRAY SHIPMENT TO SYSTEM SERVER
   if(trade.Buy(normalized_lot, symbol, current_ask, final_sl, final_tp, comment))
     {
      if(trade.ResultRetcode() == TRADE_RETCODE_DONE || trade.ResultRetcode() == TRADE_RETCODE_PLACED)
         return true;
     }

   PrintFormat(">>> [TRADE ERROR] Buy execution failed on %s. Retcode: %I64u", symbol, trade.ResultRetcode());
   return false;
  }

//+------------------------------------------------------------------+
//| Standard Sell Order Processing Router                            |
//+------------------------------------------------------------------+
bool CTradeManager::ExecuteSell(const string symbol, const double entry_price, const double sl, const double tp, const string comment)
  {
//--- DECOUPLED RISK SAFETY GATE
   if(IsPositionOpen(symbol))
      return false;

//--- ACCOUNT FOR LIVE MARKET SPECIFICATIONS
   double current_ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double current_bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

//--- EVALUATE UNEXPECTED SPREAD EXPANSION FILTERS
   double current_spread_points = (current_ask - current_bid) / point;
   if(max_spread_pts > 0 && current_spread_points > max_spread_pts)
     {
      PrintFormat(">>> [TRADE SPREAD BLOCK] Execution rejected on %s. Current Spread: %.1f pts | Max Allowed: %.1f pts", symbol, current_spread_points, max_spread_pts);
      return false;
     }

//--- ALIGN VOLUME SIZES SAFELY WITH THE EXCHANGE CONTRACT STEP SPECS
   double volume_min = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double volume_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double normalized_lot = MathMax(MathFloor(fixed_lot / volume_step) * volume_step, volume_min);

//--- EXPLICITLY EVALUATE VALIDATION SERVER ACCOUNT MARGIN LEVELS
   double required_margin = 0.0;
   if(OrderCalcMargin(ORDER_TYPE_SELL, symbol, normalized_lot, current_bid, required_margin))
     {
      if(AccountInfoDouble(ACCOUNT_MARGIN_FREE) < required_margin)
        {
         PrintFormat(">>> [VALIDATION SAFETY GATE] Sell Order blocked programmatically. Required Margin: %.2f | Free Margin: %.2f", required_margin, AccountInfoDouble(ACCOUNT_MARGIN_FREE));
         return false;
        }
     }

//--- ENFORCE BROKER STOPSLEVEL COMPLIANCE MATRICES
   long broker_stops = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   if(broker_stops <= 0)
      broker_stops = (long)MathMax(current_spread_points * 1.5, 10);
   double stops_level_price = (broker_stops + 2) * point;
   double final_sl = sl;
   double final_tp = tp;

//--- PUSH RECOVERY BOUNDARIES PAST THE INVALID BROKER LIMITS ENVELOPE
   if(final_sl > 0 && (final_sl - current_bid) < stops_level_price)
     {
      final_sl = current_bid + stops_level_price;
     }
   if(final_tp > 0 && (current_bid - final_tp) < stops_level_price)
     {
      final_tp = current_bid - stops_level_price;
     }

//--- INITIALIZE DATA STRUCT PRECISION NORMALIZATION
   final_sl = NormalizeDouble(final_sl, digits);
   final_tp = NormalizeDouble(final_tp, digits);

//--- ROUTE FINAL TRANS-ARRAY SHIPMENT TO SYSTEM SERVER
   if(trade.Sell(normalized_lot, symbol, current_bid, final_sl, final_tp, comment))
     {
      if(trade.ResultRetcode() == TRADE_RETCODE_DONE || trade.ResultRetcode() == TRADE_RETCODE_PLACED)
         return true;
     }

   PrintFormat(">>> [TRADE ERROR] Sell execution failed on %s. Retcode: %I64u", symbol, trade.ResultRetcode());
   return false;
  }

//+------------------------------------------------------------------+
//| Universal Capital Protection Trailing Module                     |
//+------------------------------------------------------------------+
void CTradeManager::UpdateTrailingStop(const string symbol)
  {
//--- CONFIRM HARDWARE DEPLOYMENT SWITCHES ARE ACTIVE
   if(!enable_trailing)
      return;

//--- POPULATE PIP CALIBRATORS AND GEOMETRIC VARIABLES
   double pip = GetPipMultiplier(symbol);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double current_ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double current_bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double current_spread_points = (current_ask - current_bid) / point;
   long broker_stops = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   if(broker_stops <= 0)
      broker_stops = (long)MathMax(current_spread_points * 1.5, 10);
   double stops_level_price = (broker_stops + 2) * point;

//--- RETRIEVE CURRENT POSITION ARRAY FROM TERMINAL STORAGE MATRIX
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetSymbol(i) == symbol)
        {
         //--- ENFORCE SECURITY AND IDENTITY SEPARATION
         if(PositionGetInteger(POSITION_MAGIC) != magic_number)
            continue;

         ulong  ticket      = PositionGetInteger(POSITION_TICKET);
         long   type        = PositionGetInteger(POSITION_TYPE);
         double open_price  = PositionGetDouble(POSITION_PRICE_OPEN);
         double current_sl  = PositionGetDouble(POSITION_SL);
         double current_tp  = PositionGetDouble(POSITION_TP);

         //--- PROCESSING BUY LIFECYCLE CHANNELS
         if(type == POSITION_TYPE_BUY)
           {
            double bid = SymbolInfoDouble(symbol, SYMBOL_BID);

            //--- VALIDATE IF PRICE HAS EXPANDED BEYOND TRADING START EXPANSION THRESHOLD
            if(bid - open_price > trailing_start * pip)
              {
               double new_sl = bid - (trailing_step * pip);

               //--- PROTECT TRANSACTION STRUCTS FROM THE BROKER STOPSLEVEL INFRASTRUCTURE
               if(bid - new_sl < stops_level_price)
                  new_sl = bid - stops_level_price;

               new_sl = NormalizeDouble(new_sl, digits);

               //--- PERFORMANCE CHECK: OPTIMIZE TRACKING TO ONLY PERMIT UPWARD EXPANSION
               if(new_sl > current_sl + (1 * point) || current_sl == 0)
                 {
                  if(bid - new_sl >= stops_level_price)
                    {
                     trade.PositionModify(ticket, new_sl, current_tp);
                    }
                 }
              }
           }
         //--- PROCESSING SELL LIFECYCLE CHANNELS
         else
            if(type == POSITION_TYPE_SELL)
              {
               double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

               //--- VALIDATE IF PRICE HAS EXPANDED BEYOND TRADING START EXPANSION THRESHOLD
               if(open_price - ask > trailing_start * pip)
                 {
                  double new_sl = ask + (trailing_step * pip);

                  //--- PROTECT TRANSACTION STRUCTS FROM THE BROKER STOPSLEVEL INFRASTRUCTURE
                  if(new_sl - ask < stops_level_price)
                     new_sl = ask + stops_level_price;

                  new_sl = NormalizeDouble(new_sl, digits);

                  //--- PERFORMANCE CHECK: OPTIMIZE TRACKING TO ONLY PERMIT DOWNWARD EXPANSION
                  if(new_sl < current_sl - (1 * point) || current_sl == 0)
                    {
                     if(new_sl - ask >= stops_level_price)
                       {
                        trade.PositionModify(ticket, new_sl, current_tp);
                       }
                    }
                 }
              }
        }
     }
  }
//+------------------------------------------------------------------+
