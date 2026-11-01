//+------------------------------------------------------------------+
//|                         Adaptive Crossover RSI Trading Suite.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Forex Algo-Trader, Allan"
#property link      "https://t.me/Forex_Algo_Trader"
#property version   "1.00"
#property description "EA that trades based on MA Crossover, RSI + Day Filter"
#property strict

#include <Trade\Trade.mqh>
CTrade obj_Trade;

sinput group "GENERAL SETTINGS"
sinput double inpLots = 0.01; // LotSize
input int inpSLPts = 300; // Stoploss Points
input double inpR2R = 1.0; // Risk to Reward Ratio
sinput ulong inpMagicNo = 1234567; // Magic Number
input bool inpisAllowTrailingStop = true; // Apply Trailing Stop?
input int inpTrailPts = 50; // Trailing Stop Points
input int inpMinTrailPts = 50; // Minimum Trailing Stop Points

sinput group "INDICATOR SETTINGS"
input int inpMA_Fast_Period = 14; // Fast MA Period
input ENUM_MA_METHOD inpMA_Fast_Method = MODE_EMA; // Fast MA Method
input int inpMA_Slow_Period = 50; // Slow MA Period
input ENUM_MA_METHOD inpMA_Slow_Method = MODE_EMA; // Slow MA Method

sinput group "FILTER SETTINGS"
input ENUM_TIMEFRAMES inpRSI_Tf = PERIOD_CURRENT; // RSI Timeframe
input int inpRSI_Period = 14; // RSI Period
input ENUM_APPLIED_PRICE inpRSI_Applied_Price = PRICE_CLOSE; // RSI Application Price
input double inpRsiBUYThreshold = 50; // BUY Signal Threshold
input double inpRsiSELLThreshold = 50; // SELL Signal Threshold

input bool Sunday = false; // Trade on Sunday?
input bool Monday = false; // Trade on Monday?
input bool Tuesday = true; // Trade on Tuesday?
input bool Wednesday = true; // Trade on Wednesday?
input bool Thursday = true; // Trade on Thursday?
input bool Friday = false; // Trade on Friday?
input bool Saturday = false; // Trade on Saturday?

int handleMAFast = INVALID_HANDLE;
int handleMASlow = INVALID_HANDLE;
int handleRSIFilter = INVALID_HANDLE;

double bufferMAFast[];
double bufferMASlow[];
double bufferRSIFilter[];


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
   
   handleMAFast = iMA(_Symbol,_Period,inpMA_Fast_Period,0,inpMA_Fast_Method,PRICE_CLOSE);
   handleMASlow = iMA(_Symbol,_Period,inpMA_Slow_Period,0,inpMA_Slow_Method,PRICE_CLOSE);
   
   handleRSIFilter = iRSI(_Symbol,inpRSI_Tf,inpRSI_Period,inpRSI_Applied_Price);
   
   if (handleMAFast == INVALID_HANDLE || handleMASlow == INVALID_HANDLE || handleRSIFilter == INVALID_HANDLE){
      Print("ERROR! Unable to create the indicator handles. Reveting Now!");
      return (INIT_FAILED);
   }
   
   if (inpMA_Fast_Period <= 0 || inpMA_Slow_Period <= 0 || inpRSI_Period <= 0){
      Print("ERROR! Periods cannot be <= 0. Reverting Now!");
      return (INIT_PARAMETERS_INCORRECT);
   }
   
   ArraySetAsSeries(bufferMAFast,true);
   ArraySetAsSeries(bufferMASlow,true);
   ArraySetAsSeries(bufferRSIFilter,true);
   
   obj_Trade.SetExpertMagicNumber(inpMagicNo);
   
   createDashboard();
   
   Print("SUCCESS INITIALIZATION. ACCOUNT TYPE = ",trading_Account_Mode());
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//---
   IndicatorRelease(handleMAFast);
   IndicatorRelease(handleMASlow);
   IndicatorRelease(handleRSIFilter);
   
   deleteDashboard();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//--- Check if data can be retrieved for the fast moving average (MA)
   if (CopyBuffer(handleMAFast,0,0,3,bufferMAFast) < 3){
   //--- Print error message for fast MA data retrieval failure
      Print("ERROR! Failed to retrieve the requested FAST MA data. Reverting.");
   //--- Exit the function if data retrieval fails
      return;
   }
//--- Check if data can be retrieved for the slow moving average (MA)
   if (CopyBuffer(handleMASlow,0,0,3,bufferMASlow) < 3){
   //--- Print error message for slow MA data retrieval failure
      Print("ERROR! Failed to retrieve the requested SLOW MA data. Reverting.");
   //--- Exit the function if data retrieval fails
      return;
   }
//--- Check if data can be retrieved for the RSI filter
   if (CopyBuffer(handleRSIFilter,0,0,3,bufferRSIFilter) < 3){
   //--- Print error message for RSI data retrieval failure
      Print("ERROR! Failed to retrieve the requested RSI data. Reverting.");
   //--- Exit the function if data retrieval fails
      return;
   }
   
   //--- Check if a new bar has formed
   if (isNewBar()){
   //--- Print debug message for a new tick
      //Print("THIS IS A NEW TICK");
      
   //--- Identify if a buy crossover has occurred
      bool isMACrossOverBuy = bufferMAFast[1] > bufferMASlow[1] && bufferMAFast[2] <= bufferMASlow[2];
   //--- Identify if a sell crossover has occurred
      bool isMACrossOverSell = bufferMAFast[1] < bufferMASlow[1] && bufferMAFast[2] >= bufferMASlow[2];
      
   //--- Check if the RSI confirms a buy signal
      bool isRSIConfirmBuy = bufferRSIFilter[1] >= inpRsiBUYThreshold;
   //--- Check if the RSI confirms a sell signal
      bool isRSIConfirmSell = bufferRSIFilter[1] <= inpRsiSELLThreshold;
      
   //--- Handle buy signal conditions
      if (isMACrossOverBuy){
         if (isRSIConfirmBuy){
         //--- Print buy signal message
            Print("BUY SIGNAL");
         //--- Verify trading days filter before placing a trade
            if (isCheckTradingDaysFilter()){
            //--- Retrieve the current ask price
               double Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            //--- Retrieve the current bid price
               double Bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
               
            //--- Set the open price to the ask price
               double openPrice = Ask;
            //--- Calculate the stop-loss price
               double stoploss = Bid - inpSLPts*_Point;
            //--- Calculate the take-profit price
               double takeprofit = Bid + (inpSLPts*inpR2R)*_Point;
            //--- Define the trade comment
               string comment = "BUY TRADE";
               
            //--- Execute a buy trade
               obj_Trade.Buy(inpLots,_Symbol,openPrice,stoploss,takeprofit,comment);
            //--- Initialize the ticket variable
               ulong ticket = 0;
            //--- Retrieve the order result ticket
               ticket = obj_Trade.ResultOrder();
            //--- Print success message if the trade is opened
               if (ticket > 0){
                  Print("SUCCESS. Opened the BUY position with ticket # ",ticket);
               }
            //--- Print error message if the trade fails to open
               else {Print("ERROR! Failed to open the BUY position.");}
            }
         //--- Retrieve the time of the signal
            datetime textTime = iTime(_Symbol,_Period,1);
         //--- Retrieve the price of the signal
            double textPrice = iLow(_Symbol,_Period,1);
         //--- Create a visual signal on the chart for a buy
            createSignalText(textTime,textPrice,221,1,clrBlue,-90,"Buy Signal");
         }
      }
   //--- Handle sell signal conditions
      else if (isMACrossOverSell){
         if (isRSIConfirmSell){
         //--- Print sell signal message
            Print("SELL SIGNAL");
         //--- Verify trading days filter before placing a trade
            if (isCheckTradingDaysFilter()){
            //--- Retrieve the current ask price
               double Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            //--- Retrieve the current bid price
               double Bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
               
            //--- Set the open price to the bid price
               double openPrice = Bid;
            //--- Calculate the stop-loss price
               double stoploss = Ask + inpSLPts*_Point;
            //--- Calculate the take-profit price
               double takeprofit = Ask - (inpSLPts*inpR2R)*_Point;
            //--- Define the trade comment
               string comment = "SELL TRADE";
               
            //--- Execute a sell trade
               obj_Trade.Sell(inpLots,_Symbol,openPrice,stoploss,takeprofit,comment);
            //--- Initialize the ticket variable
               ulong ticket = 0;
            //--- Retrieve the order result ticket
               ticket = obj_Trade.ResultOrder();
            //--- Print success message if the trade is opened
               if (ticket > 0){
                  Print("SUCCESS. Opened the SELL position with ticket # ",ticket);
               }
            //--- Print error message if the trade fails to open
               else {Print("ERROR! Failed to open the SELL position.");}
            }
         //--- Retrieve the time of the signal
            datetime textTime = iTime(_Symbol,_Period,1);
         //--- Retrieve the price of the signal
            double textPrice = iHigh(_Symbol,_Period,1);
         //--- Create a visual signal on the chart for a sell
            createSignalText(textTime,textPrice,222,-1,clrRed,90,"Sell Signal");
         }
      }
   }
//--- Apply trailing stop if allowed in the input parameters
   if (inpisAllowTrailingStop){
      applyTrailingStop(inpTrailPts,obj_Trade,inpMagicNo,inpMinTrailPts);
   }
   
   if (PositionsTotal() > 0){
      ObjectSetString(0,DASH_POSITIONS,OBJPROP_TEXT,"Positions: "+IntegerToString(PositionsTotal()));
      ObjectSetString(0,DASH_PROFIT,OBJPROP_TEXT,"Profit: "+DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT),2)+" "+AccountInfoString(ACCOUNT_CURRENCY));
   }
   
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|    OnTradeTransaction function                                   |
//+------------------------------------------------------------------+
void  OnTradeTransaction(
   const MqlTradeTransaction&    trans,     // trade transaction structure 
   const MqlTradeRequest&        request,   // request structure 
   const MqlTradeResult&         result     // response structure 
){
   if (trans.type == TRADE_TRANSACTION_DEAL_ADD){
      Print("A deal was added. Make updates.");
      if (PositionsTotal() <= 0){
         ObjectSetString(0,DASH_POSITIONS,OBJPROP_TEXT,"Positions: "+IntegerToString(PositionsTotal()));
         ObjectSetString(0,DASH_PROFIT,OBJPROP_TEXT,"Profit: "+DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT),2)+" "+AccountInfoString(ACCOUNT_CURRENCY));
      }
   }
}

//+------------------------------------------------------------------+
//|     Function to detect if a new bar is formed                   |
//+------------------------------------------------------------------+
bool isNewBar(){
//--- Static variable to store the last bar count
   static int lastBarCount = 0;
//--- Get the current bar count
   int currentBarCount = iBars(_Symbol,_Period);
//--- Check if the bar count has increased
   if (currentBarCount > lastBarCount){
   //--- Update the last bar count
      lastBarCount = currentBarCount;
   //--- Return true if a new bar is detected
      return true;
   }
//--- Return false if no new bar is detected
   return false;
}

//+------------------------------------------------------------------+
//|     Function to get trading account mode                        |
//+------------------------------------------------------------------+
string trading_Account_Mode(){
//--- Variable to store the account mode
   string account_mode;
//--- Switch case to determine account mode
   switch ((ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE)){
   //--- Case for demo account mode
      case ACCOUNT_TRADE_MODE_DEMO:
         account_mode = "DEMO";
         break;
   //--- Case for competition account mode
      case ACCOUNT_TRADE_MODE_CONTEST:
         account_mode = "COMPETITION";
         break;
   //--- Case for real account mode
      case ACCOUNT_TRADE_MODE_REAL:
         account_mode = "REAL";
         break;
   }
//--- Return the account mode
   return account_mode;
}

//+------------------------------------------------------------------+
//|     Function to check trading days filter                       |
//+------------------------------------------------------------------+
bool isCheckTradingDaysFilter(){
//--- Structure to store the current date and time
   MqlDateTime dateTIME;
//--- Convert the current time into structured format
   TimeToStruct(TimeCurrent(),dateTIME);
//--- Variable to store the day of the week
   string today = "DAY OF WEEK";
   
//--- Assign the day of the week based on the numeric value
   if (dateTIME.day_of_week == 0){today = "SUNDAY";}
   if (dateTIME.day_of_week == 1){today = "MONDAY";}
   if (dateTIME.day_of_week == 2){today = "TUESDAY";}
   if (dateTIME.day_of_week == 3){today = "WEDNESDAY";}
   if (dateTIME.day_of_week == 4){today = "THURSDAY";}
   if (dateTIME.day_of_week == 5){today = "FRIDAY";}
   if (dateTIME.day_of_week == 6){today = "SATURDAY";}
   
//--- Check if trading is allowed based on the input parameters
   if (
      (dateTIME.day_of_week == 0 && Sunday == true) ||
      (dateTIME.day_of_week == 1 && Monday == true) ||
      (dateTIME.day_of_week == 2 && Tuesday == true) ||
      (dateTIME.day_of_week == 3 && Wednesday == true) ||
      (dateTIME.day_of_week == 4 && Thursday == true) ||
      (dateTIME.day_of_week == 5 && Friday == true) ||
      (dateTIME.day_of_week == 6 && Saturday == true)
   ){
   //--- Print acceptance message for trading
      Print("Today is on ",today,". Trade ACCEPTED.");
   //--- Return true if trading is allowed
      return true;
   }
   else {
   //--- Print rejection message for trading
      Print("Today is on ",today,". Trade REJECTED.");
   //--- Return false if trading is not allowed
      return false;
   }
}

//+------------------------------------------------------------------+
//|         Trailing stop function                                   |
//+------------------------------------------------------------------+
void applyTrailingStop(int slpoints, CTrade &trade_object,ulong magicno=0,int minProfitPts=0){
//--- Calculate the stop loss price for buy positions
   double buySl = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID) - slpoints*_Point,_Digits);
//--- Calculate the stop loss price for sell positions
   double sellSl = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK) + slpoints*_Point,_Digits);
   
//--- Loop through all positions in the account
   for (int i=PositionsTotal()-1; i>=0; i--){
   //--- Get the ticket of the position
      ulong ticket = PositionGetTicket(i);
   //--- Ensure the ticket is valid
      if (ticket > 0){
      //--- Select the position by ticket
         if (PositionSelectByTicket(ticket)){
         //--- Check if the position matches the symbol and magic number (if provided)
            if (PositionGetSymbol(POSITION_SYMBOL) == _Symbol &&
               (magicno == 0 || PositionGetInteger(POSITION_MAGIC) == magicno)
            ){
            //--- Retrieve the open price and current stop loss of the position
               double positionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double positionSl = PositionGetDouble(POSITION_SL);
               
            //--- Handle trailing stop for buy positions
               if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
               //--- Calculate the minimum profit price for the trailing stop
                  double minProfitPrice = NormalizeDouble((positionOpenPrice+minProfitPts*_Point),_Digits);
               //--- Apply trailing stop only if conditions are met
                  if (buySl > minProfitPrice &&
                     buySl > positionOpenPrice &&
                     (positionSl == 0 || buySl > positionSl)
                  ){
                  //--- Modify the position's stop loss
                     trade_object.PositionModify(ticket,buySl,PositionGetDouble(POSITION_TP));
                  }
               }
               //--- Handle trailing stop for sell positions
               else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
               //--- Calculate the minimum profit price for the trailing stop
                  double minProfitPrice = NormalizeDouble((positionOpenPrice-minProfitPts*_Point),_Digits);
               //--- Apply trailing stop only if conditions are met
                  if (sellSl < minProfitPrice &&
                     sellSl < positionOpenPrice &&
                     (positionSl == 0 || sellSl < positionSl)
                  ){
                  //--- Modify the position's stop loss
                     trade_object.PositionModify(ticket,sellSl,PositionGetDouble(POSITION_TP));
                  }
               }
               
            }
         }
      }
   }
   
}

//+------------------------------------------------------------------+
//|    Create signal text function                                   |
//+------------------------------------------------------------------+
void createSignalText(datetime time,double price,int arrowcode,
            int direction,color clr,double angle,string txt
){
//--- Generate a unique name for the signal object
   string objName = " ";
   StringConcatenate(objName, "Signal @ ",time," at Price ",DoubleToString(price,_Digits));
//--- Create the arrow object at the specified time and price
   if (ObjectCreate(0,objName,OBJ_ARROW,0,time,price)){
   //--- Set arrow properties
      ObjectSetInteger(0,objName,OBJPROP_ARROWCODE,arrowcode);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
      if (direction > 0) ObjectSetInteger(0,objName,OBJPROP_ANCHOR,ANCHOR_TOP);
      if (direction < 0) ObjectSetInteger(0,objName,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
   }
   
//--- Generate a unique name for the description text object
   string objNameDesc = objName+txt;
//--- Create the text object at the specified time and price
   if (ObjectCreate(0,objNameDesc,OBJ_TEXT,0,time,price)){
   //--- Set text properties
      ObjectSetInteger(0,objNameDesc,OBJPROP_COLOR,clr);
      ObjectSetDouble(0,objNameDesc,OBJPROP_ANGLE,angle);
      if (direction > 0){
         ObjectSetInteger(0,objNameDesc,OBJPROP_ANCHOR,ANCHOR_LEFT);
         ObjectSetString(0,objNameDesc,OBJPROP_TEXT,"    "+txt);
      }
      if (direction < 0){
         ObjectSetInteger(0,objNameDesc,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
         ObjectSetString(0,objNameDesc,OBJPROP_TEXT,"    "+txt);
      }
      
   }
   
}

//+------------------------------------------------------------------+
//|     Create Rectangle label function                              |
//+------------------------------------------------------------------+
bool createRecLabel(string objNAME,int xD,int yD,int xS,int yS,
                  color clrBg,int widthBorder,color clrBorder = clrNONE,
                  ENUM_BORDER_TYPE borderType = BORDER_FLAT,ENUM_LINE_STYLE borderStyle = STYLE_SOLID
){
//--- Reset the last error code
   ResetLastError();
//--- Attempt to create the rectangle label object
   if (!ObjectCreate(0,objNAME,OBJ_RECTANGLE_LABEL,0,0,0)){
   //--- Log the error if creation fails
      Print(__FUNCTION__,": Failed to create the REC LABEL. Error Code = ",_LastError);
      return (false);
   }
   
//--- Set rectangle label properties
   ObjectSetInteger(0, objNAME,OBJPROP_XDISTANCE, xD);
   ObjectSetInteger(0, objNAME,OBJPROP_YDISTANCE, yD);
   ObjectSetInteger(0, objNAME,OBJPROP_XSIZE, xS);
   ObjectSetInteger(0, objNAME,OBJPROP_YSIZE, yS);
   ObjectSetInteger(0, objNAME,OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, objNAME,OBJPROP_BGCOLOR, clrBg);
   ObjectSetInteger(0, objNAME,OBJPROP_BORDER_TYPE, borderType);
   ObjectSetInteger(0, objNAME,OBJPROP_STYLE, borderStyle);
   ObjectSetInteger(0, objNAME,OBJPROP_WIDTH, widthBorder);
   ObjectSetInteger(0, objNAME,OBJPROP_COLOR, clrBorder);
   ObjectSetInteger(0, objNAME,OBJPROP_BACK, false);
   ObjectSetInteger(0, objNAME,OBJPROP_STATE, false);
   ObjectSetInteger(0, objNAME,OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objNAME,OBJPROP_SELECTED, false);
   
//--- Redraw the chart to reflect changes
   ChartRedraw(0);
   
   return (true);
}

//+------------------------------------------------------------------+
//|    Create label function                                         |
//+------------------------------------------------------------------+
bool createLabel(string objNAME,int xD,int yD,string txt,
                  color clrTxt = clrBlack,int fontSize = 12,
                  string font = "Arial Rounded MT Bold"
){
//--- Reset the last error code
   ResetLastError();
//--- Attempt to create the label object
   if (!ObjectCreate(0,objNAME,OBJ_LABEL,0,0,0)){
   //--- Log the error if creation fails
      Print(__FUNCTION__,": Failed to create the LABEL. Error Code = ",_LastError);
      return (false);
   }
   
//--- Set label properties
   ObjectSetInteger(0, objNAME,OBJPROP_XDISTANCE, xD);
   ObjectSetInteger(0, objNAME,OBJPROP_YDISTANCE, yD);
   ObjectSetInteger(0, objNAME,OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, objNAME,OBJPROP_TEXT, txt);
   ObjectSetInteger(0, objNAME,OBJPROP_COLOR, clrTxt);
   ObjectSetString(0, objNAME,OBJPROP_FONT, font);
   ObjectSetInteger(0, objNAME,OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, objNAME,OBJPROP_BACK, false);
   ObjectSetInteger(0, objNAME,OBJPROP_STATE, false);
   ObjectSetInteger(0, objNAME,OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objNAME,OBJPROP_SELECTED, false);
   
//--- Redraw the chart to reflect changes
   ChartRedraw(0);
   
   return (true);
}

//+------------------------------------------------------------------+
//|    Global constants for dashboard object names                  |
//+------------------------------------------------------------------+
const string DASH_MAIN = "MAIN";
const string DASH_HEAD = "HEAD";
const string DASH_ICON1 = "ICON 1";
const string DASH_ICON2 = "ICON 2";
const string DASH_NAME = "NAME";
const string DASH_OS = "OS";
const string DASH_COMPANY = "COMPANY";
const string DASH_PERIOD = "PERIOD";
const string DASH_POSITIONS = "POSITIONS";
const string DASH_PROFIT = "PROFIT";


//+------------------------------------------------------------------+
//|    Create dashboard function                                     |
//+------------------------------------------------------------------+
void createDashboard(){
//--- Create the main dashboard rectangle
   createRecLabel(DASH_MAIN,10,50+30,200,120+30,clrBlack,2,clrBlue,BORDER_FLAT,STYLE_SOLID);
   
//--- Add icons and text labels to the dashboard
   createLabel(DASH_ICON1,13,53+30,CharToString(40),clrRed,17,"Wingdings");
   createLabel(DASH_ICON2,180,53+30,"@",clrWhite,17,"Webdings");
   createLabel(DASH_HEAD,65,53+30,"Dashboard",clrWhite,14,"Impact");
   
   createLabel(DASH_NAME,20,90+30,"EA Name: Crossover RSI Suite",clrWhite,10,"Calibri");
   createLabel(DASH_COMPANY,20,90+30+15,"LTD: "+AccountInfoString(ACCOUNT_COMPANY),clrWhite,10,"Calibri");
   createLabel(DASH_OS,20,90+30+15+15,"OS: "+TerminalInfoString(TERMINAL_OS_VERSION),clrWhite,10,"Calibri");
   createLabel(DASH_PERIOD,20,90+30+15+15+15,"Period: "+EnumToString(Period()),clrWhite,10,"Calibri");
   
   createLabel(DASH_POSITIONS,20,90+30+15+15+15+30,"Positions: "+IntegerToString(PositionsTotal()),clrWhite,10,"Calibri");
   createLabel(DASH_PROFIT,20,90+30+15+15+15+30+15,"Profit: "+DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT),2)+" "+AccountInfoString(ACCOUNT_CURRENCY),clrWhite,10,"Calibri");
}

//+------------------------------------------------------------------+
//|     Delete dashboard function                                    |
//+------------------------------------------------------------------+
void deleteDashboard(){
//--- Delete all objects related to the dashboard
   ObjectDelete(0,DASH_MAIN);
   ObjectDelete(0,DASH_ICON1);
   ObjectDelete(0,DASH_ICON2);
   ObjectDelete(0,DASH_HEAD);
   ObjectDelete(0,DASH_NAME);
   ObjectDelete(0,DASH_COMPANY);
   ObjectDelete(0,DASH_OS);
   ObjectDelete(0,DASH_PERIOD);
   ObjectDelete(0,DASH_POSITIONS);
   ObjectDelete(0,DASH_PROFIT);
   
//--- Redraw the chart to reflect changes
   ChartRedraw();
} 

//+------------------------------------------------------------------+
