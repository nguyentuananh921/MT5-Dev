//+------------------------------------------------------------------+
//|                                     Project9 Trend Indicator.mq5 |
//|                                 Abioye Israel Pelumi (Forex YMN) |
//|                             https://linktr.ee/abioyeisraelpelumi |
//|Link                        https://www.mql5.com/en/articles/17689|
//+------------------------------------------------------------------+
#property copyright "Abioye Israel Pelumi (Forex YMN)"
#property link      "https://linktr.ee/abioyeisraelpelumi"
#property version   "1.00"
#property indicator_chart_window

// CHART ID
long chart_id = ChartID();

// Input parameters
input int  LookbackBars = 10;   // Number of bars to look back/forward for swing points
input int  bars_check   = 1000; // Number of bars to check for swing points
input bool show_bullish = true; //Show Buy Signals
input bool show_bearish = true; //Show Sell Signals


// Variables for Bullish Market Structure

double L;              // Low: the starting low point in the up trend. and second swing for down trend
datetime L_time;       // Time of the low
string L_letter;       // Label for the low point (e.g., "L")

double H;              // High: the first high after the low. and the first swing for down trend
datetime H_time;       // Time of the high
string H_letter;       // Label for the high point (e.g., "H")

double HL;             // Higher Low: the next low that is higher than the first low
datetime HL_time;      // Time of the higher low
string HL_letter;      // Label for the higher low point (e.g., "HL")

double HH;             // Higher High: the next high that is higher than the first high
datetime HH_time;      // Time of the higher high
string HH_letter;      // Label for the higher high point (e.g., "HH")

// Variables for Bearish Market Structure
double LH;              // Lower High: the high formed after the initial low in a downtrend
datetime LH_time;       // Time of the Lower High
string LH_letter;       // Label used to display the Lower High on the chart (e.g., "LH")

double LL;              // Lower Low: the new low formed after the Lower High in a downtrend
datetime LL_time;       // Time of the Lower Low
string LL_letter;       // Label used to display the Lower Low on the chart (e.g., "LL")

// Variables for Premium and Discount
string pre_dis_box;     // Name/ID for the premium-discount zone box (rectangle object on chart)
double lvl_50;          // The price level representing the 50% retracement between Higher Low and Higher High
string lvl_50_line;     // Name/ID for the horizontal line marking the 50% level





// Variables for Entry, Stop Loss, and Take Profit
string entry_line;        // Line object to represent the entry point on the chart
string entry_txt;         // Text object for displaying "BUY" at the entry point
double lvl_SL;            // Stop Loss level (set at the 50% retracement level)
string lvl_sl_line;       // Line object for representing the Stop Loss level
string lvl_sl_txt;        // Text object for labeling the Stop Loss level
double TP1;               // Take Profit 1 level (1:1 risk-reward ratio)
double TP2;               // Take Profit 2 level (1:2 risk-reward ratio)
string lvl_tp_line;       // Line object for representing the Take Profit 1 level
string lvl_tp2_line;      // Line object for representing the Take Profit 2 level
string lvl_tp_txt;        // Text object for labeling the Take Profit 1 level
string lvl_tp2_txt;       // Text object for labeling the Take Profit 2 level
string buy_object;        // Arrow object to indicate the Buy signal on the chart
string sell_object; // Arrow object to indicate the Sell signal on the chart

// Declare variables to count bars
int n_bars;     // Number of bars from Higher Low to the end of the Premium/Discount box
int n_bars_2;   // Number of bars from the end of the Premium/Discount box to the bullish bar that broke HH
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   ObjectsDeleteAll(chart_id);
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
                const int &spread[])
  {
//---
// BULLISH TREND
   if(show_bullish == true) // Check if the bullish trend is to be displayed
     {
      if(rates_total >= bars_check) // Ensure enough bars are available for analysis
        {
         // Loop through the price data starting from a certain point based on bars_check and LookbackBars
         for(int i = rates_total - bars_check; i < rates_total - LookbackBars; i++)
           {
            // Check if the current bar is a swing low
            if(IsSwingLow(low, i, LookbackBars))
              {
               // Store the values for the swing low
               L = low[i];
               L_time = time[i];
               L_letter = StringFormat("Low%d", i);

               // Loop through further to find a swing high after the low
               for(int j = i; j < rates_total - LookbackBars; j++)
                 {
                  // Check if the current bar is a swing high and occurs after the identified swing low
                  if(IsSwingHigh(high, j, LookbackBars) && time[j] > L_time)
                    {
                     // Store the values for the swing high
                     H = high[j];
                     H_time = time[j];
                     H_letter = StringFormat("High%d", j);

                     // Loop further to find a higher low after the swing high
                     for(int k = j; k < rates_total - LookbackBars; k++)
                       {
                        // Check if the current bar is a swing low and occurs after the swing high
                        if(IsSwingLow(low, k, LookbackBars) && time[k] > H_time)
                          {
                           // Store the values for the higher low
                           HL = low[k];
                           HL_time = time[k];
                           HL_letter = StringFormat("Higher Low%d", j);

                           // Loop further to find a higher high after the higher low
                           for(int l = j ; l < rates_total - LookbackBars; l++)
                             {
                              // Check if the current bar is a swing high and occurs after the higher low
                              if(IsSwingHigh(high, l, LookbackBars) && time[l] > HL_time)
                                {
                                 // Store the values for the higher high
                                 HH = high[l];
                                 HH_time = time[l];
                                 HH_letter = StringFormat("Higher High%d", l);


                                 // Loop through the bars to check for the conditions for entry
                                 for(int m = l; m < rates_total-1; m++)
                                   {
                                    // Check if the current bar is a bullish bar and if the price has broken the higher high (HH)
                                    if(close[m] > open[m] && close[m] > HH && time[m] >= time[l+LookbackBars])
                                      {
                                       // Count the bars between HL_time and the end of the Premium/Discount box
                                       n_bars = Bars(_Symbol, PERIOD_CURRENT, HL_time, time[l + LookbackBars]);

                                       // Count the bars between the end of the Premium/Discount box and the candle that broke HH
                                       n_bars_2 = Bars(_Symbol, PERIOD_CURRENT, time[l + LookbackBars], time[m]);

                                       // Check if the pattern follows the expected bullish structure: Low < High, Higher Low < High, Higher High > High
                                       if(L < H && HL < H && HL > L && HH > H && open[l+LookbackBars] <= HH && n_bars_2 < n_bars)
                                         {
                                          // Create and display text objects for Low, High, Higher Low, and Higher High on the chart
                                          ObjectCreate(chart_id, L_letter, OBJ_TEXT, 0, L_time, L);
                                          ObjectSetString(chart_id, L_letter, OBJPROP_TEXT, "L");
                                          ObjectSetInteger(chart_id, L_letter, OBJPROP_COLOR, clrDarkGreen);
                                          ObjectSetInteger(chart_id, L_letter, OBJPROP_FONTSIZE, 15);

                                          ObjectCreate(chart_id, H_letter, OBJ_TEXT, 0, H_time, H);
                                          ObjectSetString(chart_id, H_letter, OBJPROP_TEXT, "H");
                                          ObjectSetInteger(chart_id, H_letter, OBJPROP_COLOR, clrDarkGreen);
                                          ObjectSetInteger(chart_id, H_letter, OBJPROP_FONTSIZE, 15);

                                          ObjectCreate(chart_id, HL_letter, OBJ_TEXT, 0, HL_time, HL);
                                          ObjectSetString(chart_id, HL_letter, OBJPROP_TEXT, "HL");
                                          ObjectSetInteger(chart_id, HL_letter, OBJPROP_COLOR, clrDarkGreen);
                                          ObjectSetInteger(chart_id, HL_letter, OBJPROP_FONTSIZE, 15);

                                          ObjectCreate(chart_id, HH_letter, OBJ_TEXT, 0, HH_time, HH);
                                          ObjectSetString(chart_id, HH_letter, OBJPROP_TEXT, "HH");
                                          ObjectSetInteger(chart_id, HH_letter, OBJPROP_COLOR, clrDarkGreen);
                                          ObjectSetInteger(chart_id, HH_letter, OBJPROP_FONTSIZE, 15);


                                          // Calculate the 50% retracement level between the Higher Low and Higher High
                                          lvl_50 = HL + ((HH - HL)/2);

                                          // Generate unique names for the premium-discount box and the 50% level line using the current loop index
                                          pre_dis_box = StringFormat("Premium and Discount Box%d", i);
                                          lvl_50_line = StringFormat("Level 50 Line%d", i);

                                          // Create a rectangle object representing the premium-discount zone from the Higher Low to the Higher High
                                          ObjectCreate(chart_id, pre_dis_box, OBJ_RECTANGLE, 0, HL_time, HL, time[l + LookbackBars], HH);

                                          // Create a trend line (horizontal line) marking the 50% retracement level
                                          ObjectCreate(chart_id, lvl_50_line, OBJ_TREND, 0, HL_time, lvl_50, time[l + LookbackBars], lvl_50);

                                          // Set the color of the premium-discount box to dark green
                                          ObjectSetInteger(chart_id, pre_dis_box, OBJPROP_COLOR, clrDarkGreen);

                                          // Set the color of the 50% level line to dark green
                                          ObjectSetInteger(chart_id, lvl_50_line, OBJPROP_COLOR, clrDarkGreen);

                                          // Set the width of the premium-discount box for better visibility
                                          ObjectSetInteger(chart_id, pre_dis_box, OBJPROP_WIDTH, 2);

                                          // Set the width of the 50% level line for better visibility
                                          ObjectSetInteger(chart_id, lvl_50_line, OBJPROP_WIDTH, 2);



                                          // Calculate Take Profit levels based on the 50% retracement
                                          TP1 = close[m] + (close[m] - lvl_50);    // TP1 at 1:1 risk-reward ratio
                                          TP2 = TP1 + (close[m] - lvl_50);          // TP2 at 1:2 risk-reward ratio

                                          // Create unique object names for Entry, Stop Loss, and Take Profit lines and text
                                          entry_line = StringFormat("Entry%d", m);
                                          lvl_sl_line = StringFormat("SL%d", m);
                                          lvl_tp_line =  StringFormat("TP%d", m);
                                          lvl_tp2_line =  StringFormat("TP 2%d", m);

                                          // Create the lines on the chart for Entry, Stop Loss, and Take Profit levels
                                          ObjectCreate(chart_id, entry_line, OBJ_TREND, 0, HL_time, close[m], time[m], close[m]);
                                          ObjectCreate(chart_id, lvl_sl_line, OBJ_TREND, 0, HL_time, lvl_50, time[m], lvl_50);
                                          ObjectCreate(chart_id, lvl_tp_line, OBJ_TREND, 0, HL_time, TP1, time[m], TP1);
                                          ObjectCreate(chart_id, lvl_tp2_line, OBJ_TREND, 0, HL_time, TP2, time[m], TP2);

                                          // Set the properties for the lines (width, color, etc.)
                                          ObjectSetInteger(chart_id, entry_line, OBJPROP_WIDTH, 2);
                                          ObjectSetInteger(chart_id, lvl_sl_line, OBJPROP_WIDTH, 2);
                                          ObjectSetInteger(chart_id, lvl_tp_line, OBJPROP_WIDTH, 2);
                                          ObjectSetInteger(chart_id, lvl_tp2_line, OBJPROP_WIDTH, 2);

                                          ObjectSetInteger(chart_id, entry_line, OBJPROP_COLOR, clrDarkGreen);
                                          ObjectSetInteger(chart_id, lvl_sl_line, OBJPROP_COLOR, clrDarkGreen);
                                          ObjectSetInteger(chart_id, lvl_tp_line, OBJPROP_COLOR, clrDarkGreen);
                                          ObjectSetInteger(chart_id, lvl_tp2_line, OBJPROP_COLOR, clrDarkGreen);

                                          // Create the text labels for Entry, Stop Loss, and Take Profit levels
                                          entry_txt = StringFormat("Entry Text%d", m);
                                          lvl_sl_txt = StringFormat("SL Text%d", m);
                                          lvl_tp_txt = StringFormat("TP 1 Text%d", m);
                                          lvl_tp2_txt = StringFormat("TP 2 Text%d", m);

                                          // Create the text objects for the Entry, Stop Loss, and Take Profit labels
                                          ObjectCreate(chart_id, lvl_sl_txt, OBJ_TEXT, 0, time[m], lvl_50);
                                          ObjectSetString(chart_id, lvl_sl_txt, OBJPROP_TEXT, "SL");
                                          ObjectSetInteger(chart_id, lvl_sl_txt, OBJPROP_COLOR, clrDarkGreen);
                                          ObjectSetInteger(chart_id, lvl_sl_txt, OBJPROP_FONTSIZE, 15);

                                          ObjectCreate(chart_id, entry_txt, OBJ_TEXT, 0, time[m], close[m]);
                                          ObjectSetString(chart_id, entry_txt, OBJPROP_TEXT, "BUY");
                                          ObjectSetInteger(chart_id, entry_txt, OBJPROP_COLOR, clrDarkGreen);
                                          ObjectSetInteger(chart_id, entry_txt, OBJPROP_FONTSIZE, 15);

                                          ObjectCreate(chart_id, lvl_tp_txt, OBJ_TEXT, 0, time[m], TP1);
                                          ObjectSetString(chart_id, lvl_tp_txt, OBJPROP_TEXT, "TP1");
                                          ObjectSetInteger(chart_id, lvl_tp_txt, OBJPROP_COLOR, clrDarkGreen);
                                          ObjectSetInteger(chart_id, lvl_tp_txt, OBJPROP_FONTSIZE, 15);

                                          ObjectCreate(chart_id, lvl_tp2_txt, OBJ_TEXT, 0, time[m], TP2);
                                          ObjectSetString(chart_id, lvl_tp2_txt, OBJPROP_TEXT, "TP2");
                                          ObjectSetInteger(chart_id, lvl_tp2_txt, OBJPROP_COLOR, clrDarkGreen);
                                          ObjectSetInteger(chart_id, lvl_tp2_txt, OBJPROP_FONTSIZE, 15);

                                          // Create a Buy arrow object to indicate the Buy signal on the chart
                                          buy_object = StringFormat("Buy Object%d", m);
                                          ObjectCreate(chart_id, buy_object, OBJ_ARROW_BUY, 0, time[m], close[m]);

                                          break; // Exit the loop once a Buy signal is found
                                         }
                                      }

                                   }

                                 break; // Exit the loop once the pattern is found
                                }
                             }

                           break; // Exit the loop once the higher low is found
                          }
                       }

                     break; // Exit the loop once the higher high is found
                    }
                 }
              }
           }
        }
     }


// BEARISH TREND
   if(show_bearish == true)  // Check if the user enabled the bearish trend display
     {
      if(rates_total >= bars_check)  // Ensure enough candles are available for processing
        {
         // Loop through historical bars to find a swing high (potential start of bearish structure)
         for(int i = rates_total - bars_check; i < rates_total - LookbackBars; i++)
           {
            if(IsSwingHigh(high, i, LookbackBars))  // Detect first swing high
              {
               H = high[i];
               H_time = time[i];
               H_letter = StringFormat("High B%d", i);  // Label for the high

               // From the swing high, look for the next swing low
               for(int j = i; j < rates_total - LookbackBars; j++)
                 {
                  if(IsSwingLow(low, j, LookbackBars) && time[j] > H_time)  // Confirm next swing low
                    {
                     L = low[j];
                     L_time = time[j];
                     L_letter = StringFormat("Low B%d", j);  // Label for the low

                     // From the swing low, look for the Lower High
                     for(int k = j; k < rates_total - LookbackBars; k++)
                       {
                        if(IsSwingHigh(high, k, LookbackBars) && time[k] > L_time)
                          {
                           LH = high[k];
                           LH_time = time[k];
                           LH_letter = StringFormat("Lower High%d", k);  // Label for the Lower High

                           // From the LH, find a Lower Low
                           for(int l = j ; l < rates_total - LookbackBars; l++)
                             {
                              if(IsSwingLow(low, l, LookbackBars) && time[l] > LH_time)
                                {
                                 LL = low[l];
                                 LL_time = time[l];
                                 LL_letter = StringFormat("Lower Low%d", l);  // Label for Lower Low

                                 // Calculate 50% retracement level from LH to LL
                                 lvl_50 = LL + ((LH - LL)/2);

                                 // Prepare object names
                                 pre_dis_box = StringFormat("Gan Box B%d", i);
                                 lvl_50_line = StringFormat("Level 50 Line B%d", i);

                                 // Search for a bearish entry condition
                                 for(int m = l; m < rates_total-1; m++)
                                   {
                                    // Confirm bearish candle breaking below the LL
                                    if(close[m] < open[m] && close[m] < LL && time[m] >= time[l+LookbackBars])
                                      {
                                       // Count bars for pattern distance validation
                                       n_bars = Bars(_Symbol,PERIOD_CURRENT,LH_time, time[l+LookbackBars]);  // From LH to box end
                                       n_bars_2 = Bars(_Symbol,PERIOD_CURRENT,time[l+LookbackBars], time[m]);  // From box end to break candle

                                       // Confirm valid bearish structure and proximity of break candle
                                       if(H > L && LH > L && LH < H && LL < L && open[l+LookbackBars] >= LL && n_bars_2 < n_bars)
                                         {
                                          // Draw the Premium/Discount box
                                          ObjectCreate(chart_id,pre_dis_box, OBJ_RECTANGLE,0,LH_time,LH, time[l+LookbackBars],LL);
                                          ObjectCreate(chart_id,lvl_50_line, OBJ_TREND,0,LH_time,lvl_50, time[l+LookbackBars],lvl_50);

                                          ObjectSetInteger(chart_id,pre_dis_box,OBJPROP_WIDTH,2);
                                          ObjectSetInteger(chart_id,lvl_50_line,OBJPROP_WIDTH,2);

                                          // Label the structure points
                                          ObjectCreate(chart_id, H_letter, OBJ_TEXT, 0, H_time, H);
                                          ObjectSetString(chart_id, H_letter, OBJPROP_TEXT, "H");
                                          ObjectSetInteger(chart_id,H_letter,OBJPROP_FONTSIZE,15);

                                          ObjectCreate(chart_id, L_letter, OBJ_TEXT, 0, L_time, L);
                                          ObjectSetString(chart_id, L_letter, OBJPROP_TEXT, "L");
                                          ObjectSetInteger(chart_id,L_letter,OBJPROP_FONTSIZE,15);

                                          ObjectCreate(chart_id, LH_letter, OBJ_TEXT, 0, LH_time, LH);
                                          ObjectSetString(chart_id, LH_letter, OBJPROP_TEXT, "LH");
                                          ObjectSetInteger(chart_id,LH_letter,OBJPROP_FONTSIZE,15);

                                          ObjectCreate(chart_id, LL_letter, OBJ_TEXT, 0, LL_time, LL);
                                          ObjectSetString(chart_id, LL_letter, OBJPROP_TEXT, "LL");
                                          ObjectSetInteger(chart_id,LL_letter,OBJPROP_FONTSIZE,15);

                                          ObjectSetInteger(chart_id,H_letter,OBJPROP_WIDTH,2);
                                          ObjectSetInteger(chart_id,L_letter,OBJPROP_WIDTH,2);
                                          ObjectSetInteger(chart_id,LL_letter,OBJPROP_WIDTH,2);
                                          ObjectSetInteger(chart_id,LH_letter,OBJPROP_WIDTH,2);

                                          // Calculate Take Profits based on 1:1 and 1:2 RR
                                          TP1 = close[m] - (lvl_50 - close[m]);
                                          TP2 = TP1 - (lvl_50 - close[m]);

                                          // Generate entry, SL and TP object names
                                          entry_line = StringFormat("Entry B%d", m);
                                          lvl_sl_line = StringFormat("SL B%d", m);
                                          lvl_tp_line =  StringFormat("TP B%d", m);
                                          lvl_tp2_line =  StringFormat("TP 2 B%d", m);

                                          // Draw entry, SL, TP1, TP2 levels
                                          ObjectCreate(chart_id,entry_line,OBJ_TREND,0,LH_time,close[m],time[m],close[m]);
                                          ObjectCreate(chart_id,lvl_sl_line, OBJ_TREND,0,LH_time,lvl_50, time[m],lvl_50);
                                          ObjectCreate(chart_id,lvl_tp_line, OBJ_TREND,0,LH_time,TP1, time[m],TP1);
                                          ObjectCreate(chart_id,lvl_tp2_line, OBJ_TREND,0,LH_time,TP2, time[m],TP2);

                                          ObjectSetInteger(chart_id,entry_line,OBJPROP_WIDTH,2);
                                          ObjectSetInteger(chart_id,lvl_sl_line,OBJPROP_WIDTH,2);
                                          ObjectSetInteger(chart_id,lvl_tp_line,OBJPROP_WIDTH,2);
                                          ObjectSetInteger(chart_id,lvl_tp2_line,OBJPROP_WIDTH,2);

                                          // Generate text labels
                                          entry_txt = StringFormat("Entry Text B%d", m);
                                          lvl_sl_txt = StringFormat("SL Text B%d", m);
                                          lvl_tp_txt = StringFormat("TP Text B%d", m);
                                          lvl_tp2_txt = StringFormat("TP 2 Text B%d", m);

                                          ObjectCreate(chart_id, entry_txt, OBJ_TEXT, 0,time[m],close[m]);
                                          ObjectSetString(chart_id, entry_txt, OBJPROP_TEXT, "SELL");
                                          ObjectSetInteger(chart_id,entry_txt,OBJPROP_FONTSIZE,15);

                                          ObjectCreate(chart_id, lvl_sl_txt, OBJ_TEXT, 0,time[m],lvl_50);
                                          ObjectSetString(chart_id, lvl_sl_txt, OBJPROP_TEXT, "SL");
                                          ObjectSetInteger(chart_id,lvl_sl_txt,OBJPROP_FONTSIZE,15);

                                          ObjectCreate(chart_id, lvl_tp_txt, OBJ_TEXT, 0,time[m],TP1);
                                          ObjectSetString(chart_id, lvl_tp_txt, OBJPROP_TEXT, "TP1");
                                          ObjectSetInteger(chart_id,lvl_tp_txt,OBJPROP_FONTSIZE,15);

                                          ObjectCreate(chart_id, lvl_tp2_txt, OBJ_TEXT, 0,time[m],TP2);
                                          ObjectSetString(chart_id, lvl_tp2_txt, OBJPROP_TEXT, "TP2");
                                          ObjectSetInteger(chart_id,lvl_tp2_txt,OBJPROP_FONTSIZE,15);

                                          // Draw sell arrow
                                          sell_object = StringFormat("Sell Object%d", m);
                                          ObjectCreate(chart_id,sell_object,OBJ_ARROW_SELL,0,time[m],close[m]);
                                         }

                                       break;  // Exit loop after valid setup
                                      }
                                   }

                                 break;  // Exit LL search
                                }
                             }

                           break;  // Exit LH search
                          }
                       }

                     break;  // Exit L search
                    }
                 }
              }
           }
        }
     }





//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| FUNCTION FOR LOWS                                                |
//+------------------------------------------------------------------+
bool IsSwingLow(const double &low[], int index, int lookback)
  {
// This function checks if the bar at the given index is a swing low.
// A swing low is a bar where the low is lower than the lows of the bars before and after it.
   for(int i = 1; i <= lookback; i++)
     {
      if(low[index] > low[index - i] || low[index] > low[index + i])
         return false; // If the current low is not the lowest, return false.
     }
   return true; // If the current low is the lowest, return true.
  }


//+------------------------------------------------------------------+
//| FUNCTION FOR HIGHS                                               |
//+------------------------------------------------------------------+
bool IsSwingHigh(const double &high[], int index, int lookback)
  {
// This function checks if the bar at the given index is a swing high.
// A swing high is a bar where the high is higher than the highs of the bars before and after it.
   for(int i = 1; i <= lookback; i++)
     {
      if(high[index] < high[index - i] || high[index] < high[index + i])
         return false; // If the current high is not the highest, return false.
     }
   return true; // If the current high is the highest, return true.
  }
//+------------------------------------------------------------------+
