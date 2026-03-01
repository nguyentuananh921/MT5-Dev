//+------------------------------------------------------------------+
//|                                         MAwithArrows.mq5 		   |
//|                             https://www.mql5.com/en/code/45552|
//+------------------------------------------------------------------+

#property copyright "Copyright 2023, https://www.mql5.com/en/users/phade/"
#property link      "https://www.mql5.com/en/users/phade/"
#property version   "1.01"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

#property indicator_label1  "Buy"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrPurple
#property indicator_width1  3

#property indicator_label2  "Sell"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrPurple
#property indicator_width2  3

#property indicator_type3   DRAW_LINE
#property indicator_color3   clrPurple // change to clrNONE to hide the line
#property indicator_style3   STYLE_DOT
#property indicator_label3   "Line"
#property indicator_width3   1

double ema[];
int handle;

input int slowPeriod = 14; // Moving Average Length

double buy_arrow_price[];
double sell_arrow_price[];
   //
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // ChartSetInteger(0, CHART_FOREGROUND, false);
    SetIndexBuffer(0, buy_arrow_price,INDICATOR_DATA);
    SetIndexBuffer(1, sell_arrow_price,INDICATOR_DATA);
    SetIndexBuffer(2, ema,INDICATOR_DATA);     
    
    PlotIndexSetInteger(0, PLOT_ARROW, 233);   
    PlotIndexSetInteger(1, PLOT_ARROW, 234);
    
    handle = iMA(_Symbol, PERIOD_CURRENT, slowPeriod, 0, MODE_SMA, PRICE_CLOSE);

    if (handle == INVALID_HANDLE){
        Print("Get MA Handle failed!");
        return INIT_FAILED;
    }      
    ArrayInitialize(buy_arrow_price, 0.0);    
    ArrayInitialize(sell_arrow_price, 0.0);
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]){

    if (Bars(_Symbol, _Period) < rates_total)
      return (-1);
    // Copy data from indicator buffers
      CopyBuffer(handle, 0, 0, rates_total, ema);    

    // Calculate the indicator values
      for (int i = prev_calculated - (rates_total==prev_calculated); i < rates_total; i++)
         {      
               buy_arrow_price[i] = 0;
               sell_arrow_price[i] = 0;             
               // Check for MA cross up
               if (i >= 0 && (i - 2) >= 0 && close[i] > ema[i] && ema[i] > open[i])
               {         
                  buy_arrow_price[i] = low[i];                
               } 
               else
               {
                  buy_arrow_price[i] = 0;
               }
               
               if (i >= 0 && (i - 2) >= 0 && close[i] < ema[i] && ema[i] < open[i])
               {      
                  sell_arrow_price[i] = high[i];     
               }
               else
               {
                  sell_arrow_price[i] = 0; 
               } 
         }
         
    return rates_total;
}

//+------------------------------------------------------------------+

void OnDeinit(const int reason){

    ArrayFree(ema);
    IndicatorRelease(handle);
}

