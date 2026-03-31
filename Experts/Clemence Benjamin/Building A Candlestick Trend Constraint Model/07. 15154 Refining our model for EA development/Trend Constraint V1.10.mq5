//+------------------------------------------------------------------+
//|                                       Trend Constraint V1.10.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property copyright "Copyright 2024, Clemence Benjamin"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property version   "1.10"
#property description "A model that seeks to produce sell signals when D1 candle is Bearish only and buy signals when it is Bullish"

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots 8

#property indicator_type1 DRAW_ARROW
#property indicator_width1 5
#property indicator_color1 0xFF3C00
#property indicator_label1 "Buy Zone"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 5
#property indicator_color2 0x0000FF
#property indicator_label2 "Sell Zone"

#property indicator_type3 DRAW_ARROW
#property indicator_width3 2
#property indicator_color3 0xE8351A
#property indicator_label3 "Buy Swing"

#property indicator_type4 DRAW_ARROW
#property indicator_width4 2
#property indicator_color4 0x1A1AE8
#property indicator_label4 "Sell  Swing"

#property indicator_type5 DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 2
#property indicator_color5 0xFFAA00
#property indicator_label5 ""

#property indicator_type6 DRAW_ARROW
#property indicator_width6 1
#property indicator_color6 0x0000FF
#property indicator_label6 "Sell"

#property indicator_type7 DRAW_ARROW
#property indicator_width7 1
#property indicator_color7 0xFFAA00
#property indicator_label7 "Buy"

#property indicator_type8 DRAW_LINE
#property indicator_style8 STYLE_SOLID
#property indicator_width8 2
#property indicator_color8 0x0000FF
#property indicator_label8 ""

#define PLOT_MAXIMUM_BARS_BACK 5000
#define OMIT_OLDEST_BARS 50

//--- indicator buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];
double Buffer6[];
double Buffer7[];
double Buffer8[];


//--- new inputs for rectangles
input int RectWidth = 5;                 // Width of the rectangle in bars
input int RectHeightPointsBuy = 50;      // Height of the profit rectangle in points for Buy
input int RectHeightPointsSell = 50;     // Height of the profit rectangle in points for Sell
input color ProfitRectColor = clrGreen;  // Color of the profit rectangle
input color RiskRectColor = clrRed;      // Color of the risk rectangle


input double Oversold = 30;
input double Overbought = 70;
input int Slow_MA_period = 200;
input int Fast_MA_period = 100;
input int Entry_MA_fast = 7;
input int Entry_MA_slow = 21;
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
int MA_handle7;
double MA7[];
int MA_handle8;
double MA8[];
int MA_handle9;
double MA9[];
double Open2[];

//--- ShellExecuteW declaration ----------------------------------------------
#import "shell32.dll"
int ShellExecuteW(int hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
#import

//--- global variables ------------------------------------------------------
datetime last_alert_time;
input int alert_cooldown_seconds = 60; // Cooldown period in seconds

//--- myAlert function ------------------------------------------------------
void myAlert(string type, string message) {
    datetime current_time = TimeCurrent();
    if (current_time - last_alert_time < alert_cooldown_seconds) {
        // Skip alert if within cooldown period
        return;
    }

    last_alert_time = current_time;
    string full_message = type + " | Trend Constraint V1.08 @ " + Symbol() + "," + IntegerToString(Period()) + " | " + message;
    
    string comment = "Alert triggered by Trend Constraint V1.08 | Symbol: " + Symbol() + " | Period: " + IntegerToString(Period()) + " | Message: " + message;

    if (type == "print") {
        Print(message);
    } else if (type == "error") {
        Print(type + " | Trend Constraint V1.08 @ " + Symbol() + "," + IntegerToString(Period()) + " | " + message);
    } else if (type == "order") {
        // Add order alert handling if needed
    } else if (type == "modify") {
        // Add modify alert handling if needed
    } else if (type == "indicator" || type == "info") {
        if (Audible_Alerts) {
            Alert(full_message);
        }
        if (Push_Notifications) {
            SendNotification(full_message);
        }

        // Send to WhatsApp
        string python_path = "C:\\Users\\protech\\Your_Computer_Name\\Local\\Programs\\Python\\Python312\\python.exe";
        string whatsapp_script_path = "C:\\Users\\Your_Computer_Name\\AppData\\Local\\Programs\\Python\\Python312\\Scripts\\send_whatsapp_message.py";
        string whatsapp_command = python_path + " \"" + whatsapp_script_path + "\" \"" + full_message + "\"";
        
        // Debugging: Print the command being executed for WhatsApp
        Print("Executing command to send WhatsApp message: ", whatsapp_command);

        // Use cmd.exe to execute the command and then wait for 5 seconds
        string final_whatsapp_command = "/c " + whatsapp_command + " && timeout 5";
        int whatsapp_result = ShellExecuteW(0, "open", "cmd.exe", final_whatsapp_command, NULL, 0);
        if (whatsapp_result <= 32) {
            int error_code = GetLastError();
            Print("Failed to execute WhatsApp Python script. Error code: ", error_code);
            Comment("Failed to send message: " + message);
        } else {
            Print("Successfully executed WhatsApp Python script. Result code: ", whatsapp_result);
            Comment("Success message sent: " + message);
        }

        // Send to Telegram
        string telegram_script_path = "C:\\Users\\Your_Computer_Name\\AppData\\Local\\Programs\\Python\\Python312\\Scripts\\send_telegram_message.py";
        string telegram_command = python_path + " \"" + telegram_script_path + "\" \"" + full_message + "\"";
        
        // Debugging: Print the command being executed for Telegram
        Print("Executing command to send Telegram message: ", telegram_command);

        // Use cmd.exe to execute the command and then wait for 5 seconds
        string final_telegram_command = "/c " + telegram_command + " && timeout 5";
        int telegram_result = ShellExecuteW(0, "open", "cmd.exe", final_telegram_command, NULL, 0);
        if (telegram_result <= 32) {
            int error_code = GetLastError();
            Print("Failed to execute Telegram Python script. Error code: ", error_code);
            Comment("Failed to send message: " + message);
        } else {
            Print("Successfully executed Telegram Python script. Result code: ", telegram_result);
            Comment("Success message sent: " + message);
        }
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
   PlotIndexSetInteger(5, PLOT_ARROW, 242);
   SetIndexBuffer(6, Buffer7);
   PlotIndexSetDouble(6, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(6, PLOT_DRAW_BEGIN, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   PlotIndexSetInteger(6, PLOT_ARROW, 241);
   SetIndexBuffer(7, Buffer8);
   PlotIndexSetDouble(7, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(7, PLOT_DRAW_BEGIN, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   // Send test message on launch
   myAlert("info", "Thank you for subscribing. You shall be receiving Trend Constraint signal alerts via Whatsapp.");
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
   
   MA_handle7 = iMA(NULL, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE);
   if(MA_handle7 < 0)
     {
      Print("The creation of iMA has failed: MA_handle7=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   MA_handle8 = iMA(NULL, PERIOD_CURRENT, Entry_MA_fast, 0, MODE_SMA, PRICE_CLOSE);
   if(MA_handle8 < 0)
     {
      Print("The creation of iMA has failed: MA_handle8=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   MA_handle9 = iMA(NULL, PERIOD_CURRENT, Entry_MA_slow, 0, MODE_SMA, PRICE_CLOSE);
   if(MA_handle9 < 0)
     {
      Print("The creation of iMA has failed: MA_handle9=", INVALID_HANDLE);
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
   int begin = 1;
   int calculated = prev_calculated;
   int mycounted_bars = BarsCalculated(MA_handle);
   if(mycounted_bars < 0) return(-1);
   if(mycounted_bars > 0) mycounted_bars--;
   int limit = rates_total - mycounted_bars;
   int first = rates_total - limit;
   if(first < begin)
     {
      first = begin;
     }
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   ArraySetAsSeries(Buffer3, true);
   ArraySetAsSeries(Buffer4, true);
   ArraySetAsSeries(Buffer5, true);
   ArraySetAsSeries(Buffer6, true);
   ArraySetAsSeries(Buffer7, true);
   ArraySetAsSeries(Buffer8, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
      ArrayInitialize(Buffer3, EMPTY_VALUE);
      ArrayInitialize(Buffer4, EMPTY_VALUE);
      ArrayInitialize(Buffer5, EMPTY_VALUE);
      ArrayInitialize(Buffer6, EMPTY_VALUE);
      ArrayInitialize(Buffer7, EMPTY_VALUE);
      ArrayInitialize(Buffer8, EMPTY_VALUE);
     }
   else
      limit++;
   datetime Time[];
   
   datetime TimeShift[];
   if(CopyTime(Symbol(), PERIOD_CURRENT, 0, rates_total, TimeShift) <= 0) return(rates_total);
   ArraySetAsSeries(TimeShift, true);
   int barshift_M1[];
   ArrayResize(barshift_M1, rates_total);
   int barshift_D1[];
   ArrayResize(barshift_D1, rates_total);
   for(int i = 0; i < rates_total; i++)
     {
      barshift_M1[i] = iBarShift(Symbol(), PERIOD_M1, TimeShift[i]);
      barshift_D1[i] = iBarShift(Symbol(), PERIOD_D1, TimeShift[i]);
   }
   if(BarsCalculated(RSI_handle) <= 0) 
      return(0);
   if(CopyBuffer(RSI_handle, 0, 0, rates_total, RSI) <= 0) return(rates_total);
   ArraySetAsSeries(RSI, true);
   if(CopyOpen(Symbol(), PERIOD_M1, 0, rates_total, Open) <= 0) return(rates_total);
   ArraySetAsSeries(Open, true);
   if(CopyClose(Symbol(), PERIOD_D1, 0, rates_total, Close) <= 0) return(rates_total);
   ArraySetAsSeries(Close, true);
   if(BarsCalculated(MA_handle) <= 0) 
      return(0);
   if(CopyBuffer(MA_handle, 0, 0, rates_total, MA) <= 0) return(rates_total);
   ArraySetAsSeries(MA, true);
   if(BarsCalculated(MA_handle2) <= 0) 
      return(0);
   if(CopyBuffer(MA_handle2, 0, 0, rates_total, MA2) <= 0) return(rates_total);
   ArraySetAsSeries(MA2, true);
   if(BarsCalculated(MA_handle3) <= 0) 
      return(0);
   if(CopyBuffer(MA_handle3, 0, 0, rates_total, MA3) <= 0) return(rates_total);
   ArraySetAsSeries(MA3, true);
   if(BarsCalculated(MA_handle4) <= 0) 
      return(0);
   if(CopyBuffer(MA_handle4, 0, 0, rates_total, MA4) <= 0) return(rates_total);
   ArraySetAsSeries(MA4, true);
   if(CopyLow(Symbol(), PERIOD_CURRENT, 0, rates_total, Low) <= 0) return(rates_total);
   ArraySetAsSeries(Low, true);
   if(CopyHigh(Symbol(), PERIOD_CURRENT, 0, rates_total, High) <= 0) return(rates_total);
   ArraySetAsSeries(High, true);
   if(BarsCalculated(MA_handle5) <= 0) 
      return(0);
   if(CopyBuffer(MA_handle5, 0, 0, rates_total, MA5) <= 0) return(rates_total);
   ArraySetAsSeries(MA5, true);
   if(BarsCalculated(MA_handle6) <= 0) 
      return(0);
   if(CopyBuffer(MA_handle6, 0, 0, rates_total, MA6) <= 0) return(rates_total);
   ArraySetAsSeries(MA6, true);
   if(BarsCalculated(MA_handle7) <= 0) 
      return(0);
   if(CopyBuffer(MA_handle7, 0, 0, rates_total, MA7) <= 0) return(rates_total);
   ArraySetAsSeries(MA7, true);
   if(BarsCalculated(MA_handle8) <= 0) 
      return(0);
   if(CopyBuffer(MA_handle8, 0, 0, rates_total, MA8) <= 0) return(rates_total);
   ArraySetAsSeries(MA8, true);
   if(BarsCalculated(MA_handle9) <= 0) 
      return(0);
   if(CopyBuffer(MA_handle9, 0, 0, rates_total, MA9) <= 0) return(rates_total);
   ArraySetAsSeries(MA9, true);
   if(CopyOpen(Symbol(), PERIOD_CURRENT, 0, rates_total, Open2) <= 0) return(rates_total);
   ArraySetAsSeries(Open2, true);
   if(CopyTime(Symbol(), Period(), 0, rates_total, Time) <= 0) return(rates_total);
   ArraySetAsSeries(Time, true);
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(PLOT_MAXIMUM_BARS_BACK-1, rates_total-1-OMIT_OLDEST_BARS)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      if(barshift_M1[i] < 0 || barshift_M1[i] >= rates_total) continue;
      if(barshift_D1[i] < 0 || barshift_D1[i] >= rates_total) continue;
      
      //Indicator Buffer 1
      if(RSI[i] < Oversold
      && RSI[i+1] > Oversold //Relative Strength Index crosses below fixed value
      && Open[barshift_M1[i]] >= Close[1+barshift_D1[i]] //Candlestick Open >= Candlestick Close
      && MA[i] > MA2[i] //Moving Average > Moving Average
      && MA3[i] > MA4[i] //Moving Average > Moving Average
      )
        {
         Buffer1[i] = Low[i]; //Set indicator value at Candlestick Low
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Buy Zone"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(RSI[i] > Overbought
      && RSI[i+1] < Overbought //Relative Strength Index crosses above fixed value
      && Open[barshift_M1[i]] <= Close[1+barshift_D1[i]] //Candlestick Open <= Candlestick Close
      && MA[i] < MA2[i] //Moving Average < Moving Average
      && MA3[i] < MA4[i] //Moving Average < Moving Average
      )
        {
         Buffer2[i] = High[i]; //Set indicator value at Candlestick High
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Sell Zone"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer2[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 3
      if(MA5[i] > MA6[i]
      && MA5[i+1] < MA6[i+1] //Moving Average crosses above Moving Average
      )
        {
         Buffer3[i] = Low[i]; //Set indicator value at Candlestick Low
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Buy Swing"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer3[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 4
      if(MA5[i] < MA6[i]
      && MA5[i+1] > MA6[i+1] //Moving Average crosses below Moving Average
      )
        {
         Buffer4[i] = High[i]; //Set indicator value at Candlestick High
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Sell  Swing"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer4[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 5
      if(MA3[i] > MA7[i] //Moving Average > Moving Average
      )
        {
         Buffer5[i] = MA3[i]; //Set indicator value at Moving Average
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", ""); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer5[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 6
      if(MA8[i] < MA9[i]
      && MA8[i+1] > MA9[i+1] //Moving Average crosses below Moving Average
      && Open2[i] <= Close[1+barshift_D1[i]] //Candlestick Open <= Candlestick Close
      )
        {
         Buffer6[i] = High[i]; //Set indicator value at Candlestick High
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Sell"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer6[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 7
      if(MA8[i] > MA9[i]
      && MA8[i+1] < MA9[i+1] //Moving Average crosses above Moving Average
      && Open2[i] >= Close[1+barshift_D1[i]] //Candlestick Open >= Candlestick Close
      )
        {
         Buffer7[i] = Low[i]; //Set indicator value at Candlestick Low
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Buy"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer7[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 8
      if(MA3[i] < MA7[i] //Moving Average < Moving Average
      )
        {
         Buffer8[i] = MA3[i]; //Set indicator value at Moving Average
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", ""); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer8[i] = EMPTY_VALUE;
        }
      if(Buffer6[i] > 0)
        {
         // Draw Buy arrow and create a rectangle
         Buffer7[i] = close[i] + pips * myPoint;
         Buffer1[i] = close[i] + pips * myPoint;
         Buffer4[i] = close[i] + pips * myPoint;
         if (Buffer6[i - 1] < 0)
           {
            myAlert("indicator", "Buy Signal Detected!");
            if (Audible_Alerts)
               Alert(Symbol(), " ", Period(), ": Buy Signal Detected!");
            // Create rectangle
            double highRect = close[i] + RectHeightPointsBuy * myPoint;
            double lowRect = close[i];
            string rectName = "BuyRect" + IntegerToString(i);
            if (ObjectFind(0, rectName) != 0)
              {
               ObjectCreate(0, rectName, OBJ_RECTANGLE, 0, time[i], highRect, time[i + RectWidth], lowRect);
               ObjectSetInteger(0, rectName, OBJPROP_COLOR, RectColorBuy);
               ObjectSetInteger(0, rectName, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, rectName, OBJPROP_WIDTH, 2);
              }
           }
        }
      if(Buffer7[i] < 0)
        {
         // Draw Sell arrow and create a rectangle
         Buffer6[i] = close[i] - pips * myPoint;
         Buffer2[i] = close[i] - pips * myPoint;
         Buffer3[i] = close[i] - pips * myPoint;
         if (Buffer7[i - 1] > 0)
           {
            myAlert("indicator", "Sell Signal Detected!");
            if (Audible_Alerts)
               Alert(Symbol(), " ", Period(), ": Sell Signal Detected!");
            // Create rectangle
            double highRect = close[i];
            double lowRect = close[i] - RectHeightPointsSell * myPoint;
            string rectName = "SellRect" + IntegerToString(i);
            if (ObjectFind(0, rectName) != 0)
              {
               ObjectCreate(0, rectName, OBJ_RECTANGLE, 0, time[i], highRect, time[i + RectWidth], lowRect);
               ObjectSetInteger(0, rectName, OBJPROP_COLOR, RectColorSell);
               ObjectSetInteger(0, rectName, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, rectName, OBJPROP_WIDTH, 2);
              }
           }
        }
      if(Buffer6[i] > 0)
        {
         if(close[i] < MA[i])
            Buffer8[i] = MA[i];
        }
      if(Buffer7[i] < 0)
        {
         if(close[i] > MA[i])
            Buffer8[i] = MA[i];
        }
     
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+