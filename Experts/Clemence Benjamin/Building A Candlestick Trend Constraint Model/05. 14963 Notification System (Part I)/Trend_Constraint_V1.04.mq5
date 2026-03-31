///Indicator Name: Trend Constraint
#property copyright "Clemence Benjamin"
#property link      "https://mql5.com"
#property version   "1.04"
#property description "A model that seek to produce sell signal when D1 candle is Bearish only and  buy signal when it is Bullish"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 6

#property indicator_type1 DRAW_ARROW
#property indicator_width1 5
#property indicator_color1 0xFF3C00
#property indicator_label1 "Buy"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 5
#property indicator_color2 0x0000FF
#property indicator_label2 "Sell"

#property indicator_type3 DRAW_ARROW
#property indicator_width3 2
#property indicator_color3 0xE8351A
#property indicator_label3 "Buy Reversal"

#property indicator_type4 DRAW_ARROW
#property indicator_width4 2
#property indicator_color4 0x1A1AE8
#property indicator_label4 "Sell Reversal"

#property indicator_type5 DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 2
#property indicator_color5 0xFFAA00
#property indicator_label5 "Buy Trend"

#property indicator_type6 DRAW_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 2
#property indicator_color6 0x0000FF
#property indicator_label6 "Sell Trend"

#define PLOT_MAXIMUM_BARS_BACK 5000
#define OMIT_OLDEST_BARS 50

//--- indicator buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];
double Buffer6[];

input double Oversold = 30;
input double Overbought = 70;
input int Slow_MA_period = 200;
input int Fast_MA_period = 100;
datetime time_alert; //used when sending alert
input bool Audible_Alerts = true;
input bool Push_Notifications = true;
double myPoint; //initialized in OnInit
int RSI_handle;
double RSI[];
double Open[];
double Close[];
int MA_handle;
double MA[];
int MA_handle2;
double MA2[];
int MA_handle3;
double MA3[];
int MA_handle4;
double MA4[];
double Low[];
double High[];
int MA_handle5;
double MA5[];
int MA_handle6;
double MA6[];

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | Trend Constraint V1.04 @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
   else if(type == "indicator")
     {
      if(Audible_Alerts) Alert(type+" | Trend Constraint V1.04 @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Push_Notifications) SendNotification(type+" | Trend Constraint V1.04 @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
   SetIndexBuffer(0, Buffer1);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   PlotIndexSetInteger(0, PLOT_ARROW, 241);
   SetIndexBuffer(1, Buffer2);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   PlotIndexSetInteger(1, PLOT_ARROW, 242);
   SetIndexBuffer(2, Buffer3);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   PlotIndexSetInteger(2, PLOT_ARROW, 236);
   SetIndexBuffer(3, Buffer4);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   PlotIndexSetInteger(3, PLOT_ARROW, 238);
   SetIndexBuffer(4, Buffer5);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(4, PLOT_DRAW_BEGIN, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexBuffer(5, Buffer6);
   PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(5, PLOT_DRAW_BEGIN, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   RSI_handle = iRSI(NULL, PERIOD_CURRENT, 14, PRICE_CLOSE);
   if(RSI_handle < 0)
     {
      Print("The creation of iRSI has failed: RSI_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   MA_handle = iMA(NULL, PERIOD_CURRENT, 7, 0, MODE_SMMA, PRICE_CLOSE);
   if(MA_handle < 0)
     {
      Print("The creation of iMA has failed: MA_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   MA_handle2 = iMA(NULL, PERIOD_CURRENT, 400, 0, MODE_SMA, PRICE_CLOSE);
   if(MA_handle2 < 0)
     {
      Print("The creation of iMA has failed: MA_handle2=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   MA_handle3 = iMA(NULL, PERIOD_CURRENT, 100, 0, MODE_EMA, PRICE_CLOSE);
   if(MA_handle3 < 0)
     {
      Print("The creation of iMA has failed: MA_handle3=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   MA_handle4 = iMA(NULL, PERIOD_CURRENT, 200, 0, MODE_SMA, PRICE_CLOSE);
   if(MA_handle4 < 0)
     {
      Print("The creation of iMA has failed: MA_handle4=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   MA_handle5 = iMA(NULL, PERIOD_CURRENT, Fast_MA_period, 0, MODE_SMA, PRICE_CLOSE);
   if(MA_handle5 < 0)
     {
      Print("The creation of iMA has failed: MA_handle5=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   MA_handle6 = iMA(NULL, PERIOD_CURRENT, Slow_MA_period, 0, MODE_SMA, PRICE_CLOSE);
   if(MA_handle6 < 0)
     {
      Print("The creation of iMA has failed: MA_handle6=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   ArraySetAsSeries(Buffer3, true);
   ArraySetAsSeries(Buffer4, true);
   ArraySetAsSeries(Buffer5, true);
   ArraySetAsSeries(Buffer6, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
      ArrayInitialize(Buffer3, EMPTY_VALUE);
      ArrayInitialize(Buffer4, EMPTY_VALUE);
      ArrayInitialize(Buffer5, EMPTY_VALUE);
      ArrayInitialize(Buffer6, EMPTY_VALUE);
     }
   else
      limit++;
   datetime Time[];
   
   int RSIBuffer;
   int MABuffer;
   int RSIPeriod = 14;
   ArrayResize(RSI, rates_total);
   ArrayResize(Open, rates_total);
   ArrayResize(Close, rates_total);
   CopyOpen(NULL, 0, 0, rates_total, Open);
   CopyClose(NULL, 0, 0, rates_total, Close);
   if(CopyBuffer(RSI_handle, 0, 0, rates_total, RSI) < 0)
     {
      Print("Getting RSI values failed, not enough bars!");
     }
   ArrayResize(MA, rates_total);
   if(CopyBuffer(MA_handle, 0, 0, rates_total, MA) < 0)
     {
      Print("Getting MA values failed, not enough bars!");
     }
   ArrayResize(MA2, rates_total);
   if(CopyBuffer(MA_handle2, 0, 0, rates_total, MA2) < 0)
     {
      Print("Getting MA values failed, not enough bars!");
     }
   ArrayResize(MA3, rates_total);
   if(CopyBuffer(MA_handle3, 0, 0, rates_total, MA3) < 0)
     {
      Print("Getting MA values failed, not enough bars!");
     }
   ArrayResize(MA4, rates_total);
   if(CopyBuffer(MA_handle4, 0, 0, rates_total, MA4) < 0)
     {
      Print("Getting MA values failed, not enough bars!");
     }
   ArrayResize(Low, rates_total);
   if(CopyLow(NULL, 0, 0, rates_total, Low) < 0)
     {
      Print("Getting LOW values failed, not enough bars!");
     }
   ArrayResize(High, rates_total);
   if(CopyHigh(NULL, 0, 0, rates_total, High) < 0)
     {
      Print("Getting HIGH values failed, not enough bars!");
     }
   ArrayResize(MA5, rates_total);
   if(CopyBuffer(MA_handle5, 0, 0, rates_total, MA5) < 0)
     {
      Print("Getting MA values failed, not enough bars!");
     }
   ArrayResize(MA6, rates_total);
   if(CopyBuffer(MA_handle6, 0, 0, rates_total, MA6) < 0)
     {
      Print("Getting MA values failed, not enough bars!");
     }
   
   for(int i=limit-1; i>=0; i--)
     {
      if(i < rates_total-1 && time[i] != time[i+1]+PeriodSeconds())
        {
         continue;
        }
      Buffer1[i] = EMPTY_VALUE;
      Buffer2[i] = EMPTY_VALUE;
      Buffer3[i] = EMPTY_VALUE;
      Buffer4[i] = EMPTY_VALUE;
      Buffer5[i] = EMPTY_VALUE;
      Buffer6[i] = EMPTY_VALUE;

      // --- Indicator calculations
      // --- Buffer1 (Buy)
      if((Close[i] > MA[i] && MA[i] > MA2[i] && RSI[i] < Oversold) || (RSI[i] < Oversold && Close[i] > MA3[i]))
        {
         Buffer1[i] = Low[i] - 5 * myPoint;
         myAlert("indicator", "BUY OPPORTUNITY | RSI: " + DoubleToString(RSI[i], 2) + " | MA: " + DoubleToString(MA[i], 2));
        }
      
      // --- Buffer2 (Sell)
      if((Close[i] < MA[i] && MA[i] < MA2[i] && RSI[i] > Overbought) || (RSI[i] > Overbought && Close[i] < MA3[i]))
        {
         Buffer2[i] = High[i] + 5 * myPoint;
         myAlert("indicator", "SELL OPPORTUNITY | RSI: " + DoubleToString(RSI[i], 2) + " | MA: " + DoubleToString(MA[i], 2));
        }
      
      // --- Buffer3 (Buy Reversal)
      if(RSI[i] < Oversold && Close[i] > MA[i])
        {
         Buffer3[i] = Low[i] - 10 * myPoint;
         myAlert("indicator", "BUY REVERSAL | RSI: " + DoubleToString(RSI[i], 2) + " | MA: " + DoubleToString(MA[i], 2));
        }
      
      // --- Buffer4 (Sell Reversal)
      if(RSI[i] > Overbought && Close[i] < MA[i])
        {
         Buffer4[i] = High[i] + 10 * myPoint;
         myAlert("indicator", "SELL REVERSAL | RSI: " + DoubleToString(RSI[i], 2) + " | MA: " + DoubleToString(MA[i], 2));
        }
      
      // --- Buffer5 (Buy Trend)
      if(MA5[i] > MA6[i])
        {
         Buffer5[i] = Low[i] - 15 * myPoint;
         // Disabled myAlert from Buffer 5
         // myAlert("indicator", "BUY TREND | MA Fast: " + DoubleToString(MA5[i], 2) + " | MA Slow: " + DoubleToString(MA6[i], 2));
        }
      
      // --- Buffer6 (Sell Trend)
      if(MA5[i] < MA6[i])
        {
         Buffer6[i] = High[i] + 15 * myPoint;
         // Disabled myAlert from Buffer 6
         // myAlert("indicator", "SELL TREND | MA Fast: " + DoubleToString(MA5[i], 2) + " | MA Slow: " + DoubleToString(MA6[i], 2));
        }
     }
   return(rates_total);
  }
