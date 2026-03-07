//+------------------------------------------------------------------+
//|                        larryWilliamsMarketStructureIndicator.mq5 |
//|                          https://www.mql5.com/en/users/chachaian |
//+------------------------------------------------------------------+
//                      Larry Williams Market Secrets                |
//                      1. Building a Swing Structure Indicator      |
//                      https://www.mql5.com/en/articles/20512       |
//+------------------------------------------------------------------+


#property copyright "Copyright 2025, MetaQuotes Ltd. Developer is Chacha Ian"
#property link      "https://www.mql5.com/en/users/chachaian"
#property version   "1.00"

#resource "\\Indicators\\Vendors\\Chacha Ian Maroa\\Larry Williams Market Secrets\\1. larryWilliamsMarketStructureIndicator.ex5"


//+------------------------------------------------------------------+
//| Standard Libraries                                               |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>


//+------------------------------------------------------------------+
//| Custom Enumerations                                              |
//+------------------------------------------------------------------+
enum ENUM_TRADE_DIRECTION  
{ 
   ONLY_LONG, 
   ONLY_SHORT, 
   TRADE_BOTH 
};

enum ENUM_LOT_SIZE_INPUT_MODE 
{ 
   MODE_MANUAL, 
   MODE_AUTO 
};

enum ENUM_STOP_LOSS_STRUCTURE{
   SL_AT_SHORT_TERM_SWING,
   SL_AT_INTERMEDIATE_SWING
};

enum ENUM_RISK_REWARD_RATIO   
{ 
   ONE_TO_ONE, 
   ONE_TO_ONEandHALF, 
   ONE_TO_TWO, 
   ONE_TO_THREE, 
   ONE_TO_FOUR, 
   ONE_TO_FIVE, 
   ONE_TO_SIX 
};


//+------------------------------------------------------------------+
//| User input variables                                             |
//+------------------------------------------------------------------+
input group "Information"
input ulong           magicNumber = 254700680002;                 
input ENUM_TIMEFRAMES timeframe   = PERIOD_CURRENT;

input group "Trade and Risk Management"
input ENUM_TRADE_DIRECTION            direction  = TRADE_BOTH;
input ENUM_LOT_SIZE_INPUT_MODE      lotSizeMode  = MODE_AUTO;
input double                 riskPerTradePercent = 1.0;
input double                             lotSize = 5.0;
input ENUM_STOP_LOSS_STRUCTURE stopLossStructure = SL_AT_INTERMEDIATE_SWING;
input int              minimumStopDistancePoints = 100;
input int              maximumStopDistancePoints = 600;
input ENUM_RISK_REWARD_RATIO     riskRewardRatio = ONE_TO_TWO;
input bool                    enableTrailingStop = false;


//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
struct MqlTradeInfo
{
   ulong orderTicket;                 
   ENUM_ORDER_TYPE type;
   ENUM_POSITION_TYPE posType;
   double entryPrice;
   double takeProfitLevel;
   double stopLossLevel;
   datetime openTime;
   double lotSize;   
};

struct MqlTrailingStop
{
   double level1;
   double level2;
   double level3;
   double level4;
   double level5;
   
   double stopLevel1;
   double stopLevel2;
   double stopLevel3;
   double stopLevel4;
   double stopLevel5;
   
   bool isLevel1Active;
   bool isLevel2Active;
   bool isLevel3Active;
   bool isLevel4Active;
   bool isLevel5Active;
};


//--- Create a CTrade object to handle trading operations
CTrade Trade;

//--- Instantiate the trade information data structure
MqlTradeInfo tradeInfo;

//--- Instantiate the trailing stop structure
MqlTrailingStop trailingStop;

//--- Bid and Ask
double   askPrice;
double   bidPrice;

//--- The Larry Williams Market Structure Indicator handle
int larryWilliamsMarketStructureIndicatorHandle;

//--- Arrays to track market structure data
double shortTermLows [];
double shortTermHighs[];
double intermediateTermLows [];
double intermediateTermHighs[];

//--- To help track new bar open
datetime lastBarOpenTime;

//--- The size of a point for this financial security
double pointValue;

//--- To store minutes data
double closePriceMinutesData [];


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   //---  Assign a unique magic number to identify trades opened by this EA
   Trade.SetExpertMagicNumber(magicNumber);

   //--- Initialize larryWilliamsMarketStructureIndicator
   larryWilliamsMarketStructureIndicatorHandle    = iCustom(_Symbol, timeframe, "::\\Indicators\\Vendors\\Chacha Ian Maroa\\Larry Williams Market Secrets\\1. larryWilliamsMarketStructureIndicator.ex5");
   if(larryWilliamsMarketStructureIndicatorHandle == INVALID_HANDLE){
      Print("Error while initializing Larry Williams' Market Structure Indicator: ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Initialize global variables
   lastBarOpenTime = 0;
   pointValue      = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   //--- Treat the following arrays as timeseries (index 0 becomes the most recent bar)
   ArraySetAsSeries(shortTermLows,  true);
   ArraySetAsSeries(shortTermHighs, true);
   ArraySetAsSeries(intermediateTermLows,  true);
   ArraySetAsSeries(intermediateTermHighs, true);
   ArraySetAsSeries(closePriceMinutesData, true);

   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   
   //--- Notify why the program stopped running
   Print("Program terminated! Reason code: ", reason);
   
}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

   //--- Scope variables
   askPrice      = SymbolInfoDouble (_Symbol, SYMBOL_ASK);
   bidPrice      = SymbolInfoDouble (_Symbol, SYMBOL_BID);
   
   //--- Get some minutes data
   if(CopyClose(_Symbol, PERIOD_M1, 0, 7, closePriceMinutesData) == -1){
      Print("Error while copying minutes datas ", GetLastError());
      return;
   }

   //--- Execute logic only when a new bar opens
   if(IsNewBar(_Symbol, timeframe, lastBarOpenTime)){
   
      //--- Get updated market structure data
      RefreshMarketStructureBuffers();
      
      //--- Handle Buy signals
      if(IsBuySignal()){
      
         //--- Open a long position if there is no active position
         if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
            if(direction == ONLY_LONG || direction == TRADE_BOTH){
               OpenBuy(askPrice);
            }
         }
      }
      
      //--- Handle Sell signals
      if(IsSelSignal()){
         
         //--- Open a short position if there is no active position
         if(!IsThereAnActiveBuyPosition(magicNumber) && !IsThereAnActiveSellPosition(magicNumber)){
            if(direction == ONLY_LONG || direction == ONLY_SHORT){
               OpenSel(bidPrice);
            }
         }
      }
      
   }
   
   //--- Manage trailing stop
   if(enableTrailingStop){
      ManageTrailingStop();
   }
   
}


//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
}


//--- UTILITY FUNCTIONS
//+------------------------------------------------------------------+
//| Function to check if there's a new bar on a given chart timeframe|
//+------------------------------------------------------------------+
bool IsNewBar(string symbol, ENUM_TIMEFRAMES tf, datetime &lastTm)
{

   datetime currentTm = iTime(symbol, tf, 0);
   if(currentTm != lastTm){
      lastTm       = currentTm;
      return true;
   }  
   return false;
   
}


//+------------------------------------------------------------------+
//| Copies the latest swing high and low data from the market structure indicator |
//+------------------------------------------------------------------+
void RefreshMarketStructureBuffers(){

   //--- Get the last 200 short-term swing low points
   int copiedShortTermSwingLows = CopyBuffer(larryWilliamsMarketStructureIndicatorHandle, 0, 0, 200, shortTermLows);
   if(copiedShortTermSwingLows == -1){
      Print("Error while copying short-term swing lows: ", GetLastError());
      return;
   }
   
   //--- Get the last 200 short-term swing high points
   int copiedShortTermSwingHighs = CopyBuffer(larryWilliamsMarketStructureIndicatorHandle, 1, 0, 200, shortTermHighs);
   if(copiedShortTermSwingHighs == -1){
      Print("Error while copying short-term swing highs: ", GetLastError());
      return;
   }
   
   //--- Get the last 200 intermediate swing low points
   int copiedIntermediateSwingLows = CopyBuffer(larryWilliamsMarketStructureIndicatorHandle, 2, 0, 200, intermediateTermLows);
   if(copiedIntermediateSwingLows == -1){
      Print("Error while copying intermediate swing lows: ", GetLastError());
      return;
   }
   
   //--- Get the last 200 intermediate swing high points
   int copiedIntermediateSwingHighs = CopyBuffer(larryWilliamsMarketStructureIndicatorHandle, 3, 0, 200, intermediateTermHighs);
   if(copiedIntermediateSwingHighs == -1){
      Print("Error while copying intermediate swing highs: ", GetLastError());
      return;
   }
   
   //--- Treat the following arrays as timeseries (index 0 becomes the most recent bar)
   ArraySetAsSeries(shortTermLows,  true);
   ArraySetAsSeries(shortTermHighs, true);
   ArraySetAsSeries(intermediateTermLows,  true);
   ArraySetAsSeries(intermediateTermHighs, true);
      
}


//+------------------------------------------------------------------+
//| Checks whether current market structure conditions generate a buy signal  |
//+------------------------------------------------------------------+
bool IsBuySignal(){

   if(shortTermLows[2] == EMPTY_VALUE){
      return false;
   }
   
   int commonIndex = -1;
   for(int i = 3; i < ArraySize(shortTermLows); i++){
      if(shortTermLows[i] != EMPTY_VALUE){
         commonIndex = i;
         break;
      }
   }
   
   if(commonIndex == -1){
      return false;
   }
   
   if(intermediateTermLows[commonIndex] != EMPTY_VALUE){
      return true;
   }
   
   return false;
   
}


//+------------------------------------------------------------------+
//| Checks whether current market structure conditions generate a sell signal |
//+------------------------------------------------------------------+
bool IsSelSignal(){

   if(shortTermHighs[2] == EMPTY_VALUE){
      return false;
   }
   
   int commonIndex = -1;
   for(int i = 3; i < ArraySize(shortTermHighs); i++){
      if(shortTermHighs[i] != EMPTY_VALUE){
         commonIndex = i;
         break;
      }
   }
   
   if(commonIndex == -1){
      return false;
   }
   
   if(intermediateTermHighs[commonIndex] != EMPTY_VALUE){
      return true;
   }
   
   return false;
   
}

//+------------------------------------------------------------------+
//| To verify whether this EA currently has an active buy position.  |                                 |
//+------------------------------------------------------------------+
bool IsThereAnActiveBuyPosition(ulong magic){
   
   for(int i = PositionsTotal() - 1; i >= 0; i--){
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0){
         Print("Error while fetching position ticket ", _LastError);
         continue;
      }else{
         if(PositionGetInteger(POSITION_MAGIC) == magic && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
            return true;
         }
      }
   }
   
   return false;
}


//+------------------------------------------------------------------+
//| To verify whether this EA currently has an active sell position. |                                 |
//+------------------------------------------------------------------+
bool IsThereAnActiveSellPosition(ulong magic){
   
   for(int i = PositionsTotal() - 1; i >= 0; i--){
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0){
         Print("Error while fetching position ticket ", _LastError);
         continue;
      }else{
         if(PositionGetInteger(POSITION_MAGIC) == magic && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
            return true;
         }
      }
   }
   
   return false;
}


//+------------------------------------------------------------------+
//| Function used to open a market buy order.                        |   
//+------------------------------------------------------------------+
bool OpenBuy(const double askPr){

   ENUM_ORDER_TYPE action          = ORDER_TYPE_BUY;
   ENUM_POSITION_TYPE positionType = POSITION_TYPE_BUY;
   datetime currentTime            = TimeCurrent();
   double contractSize             = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   double accountBalance           = AccountInfoDouble(ACCOUNT_BALANCE);
   double rewardValue              = 1.0;
   
   switch(riskRewardRatio){
      case ONE_TO_ONE: 
         rewardValue = 1.0;
         break;
      case ONE_TO_ONEandHALF:
         rewardValue = 1.5;
         break;
      case ONE_TO_TWO: 
         rewardValue = 2.0;
         break;
      case ONE_TO_THREE: 
         rewardValue = 3.0;
         break;
      case ONE_TO_FOUR: 
         rewardValue = 4.0;
         break;
      case ONE_TO_FIVE: 
         rewardValue = 5.0;
         break;
      case ONE_TO_SIX: 
         rewardValue = 6.0;
         break;
      default:
         rewardValue = 1.0;
         break;
   }
   
   double stopLevel = 0;
   
   if(stopLossStructure == SL_AT_SHORT_TERM_SWING  ){
      stopLevel = NormalizeDouble(shortTermLows[2], Digits());
   }
   
   if(stopLossStructure == SL_AT_INTERMEDIATE_SWING){
   
      for(int i = 0; i < ArraySize(intermediateTermLows); i++){
         if(intermediateTermLows[i] != EMPTY_VALUE){
            stopLevel = NormalizeDouble(intermediateTermLows[i], Digits());
            break;
         }
      }
      
   }
   
   double stopDistance = NormalizeDouble(askPr - stopLevel, Digits());
   if(stopDistance > (maximumStopDistancePoints * pointValue) || stopDistance < (minimumStopDistancePoints * pointValue)){
      Print("The Stop Distance falls outside desired distance range");
      return false;
   }
   
   double targetLevel  = NormalizeDouble(askPr + (rewardValue * stopDistance), Digits());
   
   double volume       = NormalizeDouble(lotSize, 2);
   if(lotSizeMode == MODE_AUTO){
      double amountAtRisk = (riskPerTradePercent / 100.0) *  accountBalance;
      volume              = amountAtRisk / (contractSize * stopDistance);
      volume              = NormalizeDouble(volume, 2);
   }
   
   if(!Trade.Buy(volume, _Symbol, askPr, stopLevel, targetLevel)){
      Print("Error while opening a long position, ", GetLastError());
      Print(Trade.ResultRetcode());
      Print(Trade.ResultComment());
      return false;
   }else{
      MqlTradeResult result = {};
      Trade.Result(result);
      tradeInfo.orderTicket                 = result.order;
      tradeInfo.type                        = action;
      tradeInfo.posType                     = positionType;
      tradeInfo.entryPrice                  = result.price;
      tradeInfo.takeProfitLevel             = targetLevel;
      tradeInfo.stopLossLevel               = stopLevel;
      tradeInfo.openTime                    = currentTime;
      tradeInfo.lotSize                     = result.volume;
      
      //--- Refill the trailing Stop struct
      double targetDistance       = targetLevel - askPr;
      double trailingStep         = NormalizeDouble(targetDistance / 6,   Digits());
      trailingStop.level1         = NormalizeDouble(askPr + trailingStep, Digits());
      trailingStop.level2         = NormalizeDouble(trailingStop.level1 + trailingStep, Digits());      
      trailingStop.level3         = NormalizeDouble(trailingStop.level2 + trailingStep, Digits());
      trailingStop.level4         = NormalizeDouble(trailingStop.level3 + trailingStep, Digits());      
      trailingStop.level5         = NormalizeDouble(trailingStop.level4 + trailingStep, Digits());
      
      trailingStop.stopLevel1     = NormalizeDouble(stopLevel + trailingStep, Digits());
      trailingStop.stopLevel2     = NormalizeDouble(trailingStop.stopLevel1 + trailingStep, Digits());
      trailingStop.stopLevel3     = NormalizeDouble(trailingStop.stopLevel2 + trailingStep, Digits());
      trailingStop.stopLevel4     = NormalizeDouble(trailingStop.stopLevel3 + trailingStep, Digits());
      trailingStop.stopLevel5     = NormalizeDouble(trailingStop.stopLevel4 + trailingStep, Digits());
      
      trailingStop.isLevel1Active = false;
      trailingStop.isLevel2Active = false;
      trailingStop.isLevel3Active = false;
      trailingStop.isLevel4Active = false;
      trailingStop.isLevel5Active = false;
      
      return true;
   }
   
   return false;
}


//+------------------------------------------------------------------+
//| Function used to open a market sell order.                       |   
//+------------------------------------------------------------------+
bool OpenSel( const double bidPr){

   ENUM_ORDER_TYPE action          = ORDER_TYPE_SELL;
   ENUM_POSITION_TYPE positionType = POSITION_TYPE_SELL;
   datetime currentTime            = TimeCurrent();   
   double contractSize             = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   double accountBalance           = AccountInfoDouble(ACCOUNT_BALANCE);
   double rewardValue              = 1.0;
   
   switch(riskRewardRatio){
      case ONE_TO_ONE: 
         rewardValue = 1.0;
         break;
      case ONE_TO_ONEandHALF:
         rewardValue = 1.5;
         break;
      case ONE_TO_TWO: 
         rewardValue = 2.0;
         break;
      case ONE_TO_THREE: 
         rewardValue = 3.0;
         break;
      case ONE_TO_FOUR: 
         rewardValue = 4.0;
         break;
      case ONE_TO_FIVE: 
         rewardValue = 5.0;
         break;
      case ONE_TO_SIX: 
         rewardValue = 6.0;
         break;
      default:
         rewardValue = 1.0;
         break;
   }
   
   double stopLevel = 0;
   
   if(stopLossStructure == SL_AT_SHORT_TERM_SWING  ){
      stopLevel = NormalizeDouble(shortTermHighs[2], Digits());
   }
   
   if(stopLossStructure == SL_AT_INTERMEDIATE_SWING){
   
      for(int i = 0; i < ArraySize(intermediateTermHighs); i++){
         if(intermediateTermHighs[i] != EMPTY_VALUE){
            stopLevel = NormalizeDouble(intermediateTermHighs[i], Digits());
            break;
         }
      }
      
   }
   
   double stopDistance = NormalizeDouble(stopLevel - bidPr, Digits());
   if(stopDistance > (maximumStopDistancePoints * pointValue) || stopDistance < (minimumStopDistancePoints * pointValue)){
      Print("The Stop Distance falls outside desired distance range");
      return false;
   }
   
   double targetLevel  = NormalizeDouble(bidPr - (rewardValue * stopDistance), Digits());
   double volume       = NormalizeDouble(lotSize, 2);
   if(lotSizeMode == MODE_AUTO){
      double amountAtRisk = (riskPerTradePercent / 100.0) *  accountBalance;
      volume              = amountAtRisk / (contractSize * stopDistance);
      volume              = NormalizeDouble(volume, 2);
   }
   
   if(!Trade.Sell(volume, _Symbol, bidPr, stopLevel, targetLevel)){
      Print("Error while opening a short position, ", GetLastError());
      Print(Trade.ResultRetcode());
      Print(Trade.ResultComment());
      return false;
   }else{ 
      MqlTradeResult result = {};
      Trade.Result(result);
      tradeInfo.orderTicket                 = result.order;
      tradeInfo.type                        = action;
      tradeInfo.posType                     = positionType;
      tradeInfo.entryPrice                  = result.price;
      tradeInfo.takeProfitLevel             = targetLevel;
      tradeInfo.stopLossLevel               = stopLevel;
      tradeInfo.openTime                    = currentTime;
      tradeInfo.lotSize                     = result.volume;
      
      //--- Refill the trailing Stop struct
      double targetDistance       = bidPr - targetLevel;
      double trailingStep         = NormalizeDouble(targetDistance / 6,   Digits());
      trailingStop.level1         = NormalizeDouble(bidPr - trailingStep, Digits());
      trailingStop.level2         = NormalizeDouble(trailingStop.level1 - trailingStep, Digits());
      trailingStop.level3         = NormalizeDouble(trailingStop.level2 - trailingStep, Digits());
      trailingStop.level4         = NormalizeDouble(trailingStop.level3 - trailingStep, Digits());
      trailingStop.level5         = NormalizeDouble(trailingStop.level4 - trailingStep, Digits());
      
      trailingStop.stopLevel1     = NormalizeDouble(stopLevel - trailingStep, Digits());
      trailingStop.stopLevel2     = NormalizeDouble(trailingStop.stopLevel1 - trailingStep, Digits());
      trailingStop.stopLevel3     = NormalizeDouble(trailingStop.stopLevel2 - trailingStep, Digits());
      trailingStop.stopLevel2     = NormalizeDouble(trailingStop.stopLevel3 - trailingStep, Digits());
      trailingStop.stopLevel3     = NormalizeDouble(trailingStop.stopLevel4 - trailingStep, Digits());
      
      trailingStop.isLevel1Active = false;
      trailingStop.isLevel2Active = false;
      trailingStop.isLevel3Active = false;
      trailingStop.isLevel4Active = false;
      trailingStop.isLevel5Active = false;
      return true;
   }
   
   return false;
   
}


//+------------------------------------------------------------------+
//| To detect a crossover at a given price level                     |                               
//+------------------------------------------------------------------+
bool IsCrossOver(const double price, const double &closePriceMinsData[]){
   if(closePriceMinsData[1] <= price && closePriceMinsData[0] > price){
      return true;
   }
   return false;
}


//+------------------------------------------------------------------+
//| To detect a crossunder at a given price level                    |                               
//+------------------------------------------------------------------+
bool IsCrossUnder(const double price, const double &closePriceMinsData[]){
   if(closePriceMinsData[1] >= price && closePriceMinsData[0] < price){
      return true;
   }
   return false;
}


//+------------------------------------------------------------------+
//| To track price action and updates the trailing stop              |   
//+------------------------------------------------------------------+
void ManageTrailingStop(){

   int totalPositions = PositionsTotal();
   //--- Loop through all open positions
   for(int i = totalPositions - 1; i >= 0; i--){
      ulong ticket = PositionGetTicket(i);
      if(ticket != 0){
         // Get some useful position properties
         ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  
         string symbol                   = PositionGetString (POSITION_SYMBOL);
         ulong magic                     = PositionGetInteger(POSITION_MAGIC);
         double targetLevel              = PositionGetDouble(POSITION_TP);
         if(positionType == POSITION_TYPE_BUY ){
            if(symbol == _Symbol && magic == magicNumber){
            
               if(IsCrossOver(trailingStop.level1, closePriceMinutesData) && !trailingStop.isLevel1Active){
                  if(!Trade.PositionModify(ticket, trailingStop.stopLevel1, targetLevel)){
                     Print("Error while trailing SL at level 1: ", GetLastError());
                     Print(Trade.ResultRetcodeDescription());
                     Print(Trade.ResultRetcode());
                  }else{
                     trailingStop.isLevel1Active = true;
                  }
               }
               
               if(IsCrossOver(trailingStop.level2, closePriceMinutesData) && !trailingStop.isLevel2Active){
                  if(!Trade.PositionModify(ticket, trailingStop.stopLevel2, targetLevel)){
                     Print("Error while trailing SL at level 2: ", GetLastError());
                     Print(Trade.ResultRetcodeDescription());
                     Print(Trade.ResultRetcode());
                  }else{
                     trailingStop.isLevel2Active = true;
                  }
               }
               
               if(IsCrossOver(trailingStop.level3, closePriceMinutesData) && !trailingStop.isLevel3Active){
                  if(!Trade.PositionModify(ticket, trailingStop.stopLevel3, targetLevel)){
                     Print("Error while trailing SL at level 3: ", GetLastError());
                     Print(Trade.ResultRetcodeDescription());
                     Print(Trade.ResultRetcode());
                  }else{
                     trailingStop.isLevel3Active = true;
                  }
               }
               
               if(IsCrossOver(trailingStop.level4, closePriceMinutesData) && !trailingStop.isLevel4Active){
                  if(!Trade.PositionModify(ticket, trailingStop.stopLevel4, targetLevel)){
                     Print("Error while trailing SL at level 4: ", GetLastError());
                     Print(Trade.ResultRetcodeDescription());
                     Print(Trade.ResultRetcode());
                  }else{
                     trailingStop.isLevel4Active = true;
                  }
               }
               
               if(IsCrossOver(trailingStop.level5, closePriceMinutesData) && !trailingStop.isLevel5Active){
                  if(!Trade.PositionModify(ticket, trailingStop.stopLevel5, targetLevel)){
                     Print("Error while trailing SL at level 5: ", GetLastError());
                     Print(Trade.ResultRetcodeDescription());
                     Print(Trade.ResultRetcode());
                  }else{
                     trailingStop.isLevel5Active = true;
                  }
               }
               
            }
         }
                
         
         if(positionType == POSITION_TYPE_SELL){
            if(symbol == _Symbol && magic == magicNumber){
            
               if(IsCrossUnder(trailingStop.level1, closePriceMinutesData) && !trailingStop.isLevel1Active){
                  if(!Trade.PositionModify(ticket, trailingStop.stopLevel1, targetLevel)){
                     Print("Error while trailing SL at level 1: ", GetLastError());
                     Print(Trade.ResultRetcodeDescription());
                     Print(Trade.ResultRetcode());
                  }else{
                     trailingStop.isLevel1Active = true;
                  }
               }
               
               if(IsCrossUnder(trailingStop.level2, closePriceMinutesData) && !trailingStop.isLevel2Active){
                  if(!Trade.PositionModify(ticket, trailingStop.stopLevel2, targetLevel)){
                     Print("Error while trailing SL at level 2: ", GetLastError());
                     Print(Trade.ResultRetcodeDescription());
                     Print(Trade.ResultRetcode());
                  }else{
                     trailingStop.isLevel2Active = true;
                  }
               }
               
               if(IsCrossUnder(trailingStop.level3, closePriceMinutesData) && !trailingStop.isLevel3Active){
                  if(!Trade.PositionModify(ticket, trailingStop.stopLevel3, targetLevel)){
                     Print("Error while trailing SL at level 3: ", GetLastError());
                     Print(Trade.ResultRetcodeDescription());
                     Print(Trade.ResultRetcode());
                  }else{
                     trailingStop.isLevel3Active = true;
                  }
               }
               
               if(IsCrossUnder(trailingStop.level4, closePriceMinutesData) && !trailingStop.isLevel4Active){
                  if(!Trade.PositionModify(ticket, trailingStop.stopLevel4, targetLevel)){
                     Print("Error while trailing SL at level 4: ", GetLastError());
                     Print(Trade.ResultRetcodeDescription());
                     Print(Trade.ResultRetcode());
                  }else{
                     trailingStop.isLevel4Active = true;
                  }
               }
               
               if(IsCrossUnder(trailingStop.level5, closePriceMinutesData) && !trailingStop.isLevel5Active){
                  if(!Trade.PositionModify(ticket, trailingStop.stopLevel5, targetLevel)){
                     Print("Error while trailing SL at level 5: ", GetLastError());
                     Print(Trade.ResultRetcodeDescription());
                     Print(Trade.ResultRetcode());
                  }else{
                     trailingStop.isLevel5Active = true;
                  }
               }
               
            }
         }
      }
   }
   
}

//+------------------------------------------------------------------+
