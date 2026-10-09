//+------------------------------------------------------------------+
//|                      External and Internal Structure Mapping.mq5 |
//|                                             Abioye Israel Pelumi |
//|                                              https://Algoyin.com |
//| https://www.mql5.com/en/articles/22968
//+------------------------------------------------------------------+
#property copyright "Abioye Israel Pelumi"
#property link      "https://Algoyin.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#define OBJ_PREFIX      "EISM_"   // Prefix for all chart objects

int look_back     = 1000;         // number of candles to scan for pattern detection
int EX_SwingLookback = 15;        // swing validation range (left and right candles)
datetime lastTradeBarTime = 0;    // ensures logic runs once per new bar
int window_start;                 // starting index of scan window

//--- External structure points (swing high/low anchors)
double s1_l;                      // swing 1 low price
datetime s1_l_t;                  // swing 1 low time
double s2_h;                      // swing 2 high price
datetime s2_h_t;                  // swing 2 high time
double s3_l;                      // swing 3 low price
datetime s3_l_t;                  // swing 3 low time
double s4_h;                      // swing 4 high price
datetime s4_h_t;                  // swing 4 high time

//--- Refined price extremes between external swing points
int s3_s4_lbars;                  // bar count between s3 low and s4 high
int s3_lowest_index;              // index of lowest low between s3 and s4
double s3_lowest;                 // lowest low price between s3 and s4
datetime s3_lowest_t;             // time of lowest low between s3 and s4

int s2_s3_hbars;                  // bar count between s2 high and s3 lowest
int s2_higest_index;              // index of highest high between s2 and s3 lowest
double s2_highest;                // highest high price between s2 and s3 lowest
datetime s2_highest_t;            // time of highest high between s2 and s3 lowest

int s1_s2_lbars;                  // bar count between s1 low and s2 highest
int s1_lowest_index;              // index of lowest low between s1 and s2 highest
double s1_lowest;                 // lowest low price between s1 and s2 highest
datetime s1_lowest_t;             // time of lowest low between s1 and s2 highest

//--- Object name strings for external structure lines and labels
string line_s1_2;                 // trendline from swing 1 low to swing 2 high
string line_s2_3;                 // trendline from swing 2 high to swing 3 low
string line_s3_4;                 // trendline from swing 3 low to swing 4 high
string EXLow;                     // text label for external low
string EXHigh;                    // text label for external high

//--- Internal structure swing points
double i_high;                    // internal high price
datetime i_high_t;                // internal high time
double i_low;                     // internal low price
datetime i_low_t;                 // internal low time
int in_bars;                      // bar count from s4 high to current scan bar

//--- External structure bar range and search flag
int ex_bars;                      // total bar count of the external structure range
bool found;                       // flag — true once a valid internal setup is found for this structure

//--- Object name strings for internal structure and trade objects
string in_line_s1_2;              // trendline from internal high to internal low
string in_line_s1_c;              // trendline from internal high to CHoCH cross candle

//--- External high/low references used to validate structure uniqueness
int exll_bars;                    // bar count from s3 lowest to current candle
double exll;                      // lowest low from s3 lowest to current candle
int exhh_bars;                    // bar count from s4 high to current candle
double exhh;                      // highest high from s4 high to current candle

//--- Trade objects calculation variables
double tp;                        // computed take profit price (1.5R)
string tp_line;                   // take profit horizontal line object name
string tp_txt;                    // take profit text label object name
string buy_obj;                   // buy arrow object at entry candle
string sl_line;                   // stop loss horizontal line
string sl_txt;                    // stop loss text label

//+------------------------------------------------------------------+
//| Create or update a trendline                                     |
//| Returns true if a new object was created                         |
//+------------------------------------------------------------------+
bool DrawTrend(const string name,
               datetime x1t, double x1,
               datetime x2t, double x2,
               color fillCol)
  {
   bool created = false;

//--- Create object only if it does not exist
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TREND, 0, x1t, x1, x2t, x2);
      //--- Set object properties
      ObjectSetInteger(0, name, OBJPROP_COLOR, fillCol);

      created = true;
     }

   return created;
  }

//+------------------------------------------------------------------+
//| Create text objects on the chart                                 |
//+------------------------------------------------------------------+
bool DrawTxt(const string name,
             datetime xt, double x,
             string message, color fillCol)
  {
   bool created = false;

//--- Create object only if it does not exist
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TEXT, 0, xt, x);
      ObjectSetString(0, name, OBJPROP_TEXT, message);
      ObjectSetInteger(0, name, OBJPROP_COLOR, fillCol);

      created = true;
     }

   return created;
  }

//+------------------------------------------------------------------+
//| Create arrow or shape objects on the chart                       |
//+------------------------------------------------------------------+
bool DrawObject(const string name,
                datetime xt, double x,
                ENUM_OBJECT obj_type)
  {
   bool created = false;

//--- Create object only if it does not exist
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, obj_type, 0, xt, x);
      created = true;
     }

   return created;
  }
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
//| OnDeinit — runs when indicator is removed from chart             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Remove all objects created by this indicator
   ObjectsDeleteAll(0, OBJ_PREFIX);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[])
  {
//---
//--- Skip processing if not enough bars are available
   if(rates_total < look_back + EX_SwingLookback)
      return 0;

//--- Get the time of the current (latest) candle
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);

//--- Define the start of the scanning window accounting for swing lookback
   window_start = rates_total - look_back + EX_SwingLookback;

   bool need_redraw = false; // tracks whether any new object was drawn this pass

//--- Only execute logic once per new candle to avoid redundant processing
   if(currentBarTime != lastTradeBarTime)
     {
      //--- Scan for swing 1 low (S1) — the start of the external structure
      for(int i = window_start; i < rates_total - EX_SwingLookback - 2; i++)
        {
         if(IsSwingLow(low, i, EX_SwingLookback))
           {
            s1_l   = low[i];   // record S1 low price
            s1_l_t = time[i];  // record S1 low time

            //--- Scan forward for swing 2 high (S2) above S1 low
            for(int j = i; j < rates_total - EX_SwingLookback - 2; j++)
              {
               if(IsSwingHigh(high, j, EX_SwingLookback) && high[j] > s1_l)
                 {
                  s2_h   = high[j];  // record S2 high price
                  s2_h_t = time[j];  // record S2 high time

                  //--- Scan forward for swing 3 low (S3) below S2 high
                  for(int k = j; k < rates_total - EX_SwingLookback - 2; k++)
                    {
                     if(IsSwingLow(low, k, EX_SwingLookback) && low[k] < s2_h)
                       {
                        s3_l   = low[k];   // record S3 low price
                        s3_l_t = time[k];  // record S3 low time

                        //--- Scan forward for swing 4 high (S4) above S2 high — confirms external bullish structure
                        for(int l = k; l < rates_total - EX_SwingLookback - 2; l++)
                          {
                           if(IsSwingHigh(high, l, EX_SwingLookback) && high[l] > s2_h)
                             {
                              s4_h   = high[l];  // record S4 high price
                              s4_h_t = time[l];  // record S4 high time

                              //--- Find the true lowest low between S3 and S4 to refine external low
                              s3_s4_lbars     = Bars(_Symbol, PERIOD_CURRENT, s3_l_t, s4_h_t);
                              s3_lowest_index = ArrayMinimum(low, k, s3_s4_lbars);
                              s3_lowest       = low[s3_lowest_index];
                              s3_lowest_t     = time[s3_lowest_index];

                              //--- Find the true highest high between S2 and the refined S3 low
                              s2_s3_hbars     = Bars(_Symbol, PERIOD_CURRENT, s2_h_t, s3_lowest_t);
                              s2_higest_index = ArrayMaximum(high, j, s2_s3_hbars);
                              s2_highest      = high[s2_higest_index];
                              s2_highest_t    = time[s2_higest_index];

                              //--- Find the true lowest low between S1 and the refined S2 high
                              s1_s2_lbars     = Bars(_Symbol, PERIOD_CURRENT, s1_l_t, s2_highest_t);
                              s1_lowest_index = ArrayMinimum(low, i, s1_s2_lbars);
                              s1_lowest       = low[s1_lowest_index];
                              s1_lowest_t     = time[s1_lowest_index];

                              //--- Validate the external structure: higher low, lower high inside, and new high above S2
                              if(s1_lowest < s2_highest && s3_lowest < s2_highest && s3_lowest > s1_lowest && s4_h > s2_highest)
                                {

                                 //--- Build unique object names for external structure using swing point times
                                 line_s1_2 = OBJ_PREFIX + "Line S12" + TimeToString(time[i]) + TimeToString(time[j]);
                                 line_s2_3 = OBJ_PREFIX + "Line S23" + TimeToString(time[j]) + TimeToString(time[k]);
                                 line_s3_4 = OBJ_PREFIX + "Line S34" + TimeToString(time[k]) + TimeToString(time[l]);
                                 EXLow     = OBJ_PREFIX + "External Low"  + TimeToString(time[k]) + TimeToString(time[l]);
                                 EXHigh    = OBJ_PREFIX + "External High" + TimeToString(time[k]) + TimeToString(time[l]);


                                 if(DrawTrend(line_s1_2, s1_lowest_t, s1_lowest, s2_highest_t, s2_highest, clrBlue)
                                    && DrawTrend(line_s2_3, s2_highest_t, s2_highest, s3_lowest_t, s3_lowest, clrGreen)
                                    && DrawTrend(line_s3_4, s3_lowest_t, s3_lowest, s4_h_t, s4_h, clrRed)
                                    && DrawTxt(EXLow,  s3_lowest_t, s3_lowest, "EXL", clrRed)
                                    && DrawTxt(EXHigh, s4_h_t,      s4_h,      "EXH", clrGreen))
                                   {
                                    need_redraw = true; // mark chart for redraw
                                   }

                                 //--- Calculate total bar range of the confirmed external structure
                                 ex_bars = Bars(_Symbol, PERIOD_CURRENT, s1_lowest_t, s4_h_t);
                                 found   = false; // reset search flag for this structure

                                 //--- Scan for internal highs after the external structure completes
                                 for(int m = l + EX_SwingLookback; m < rates_total - 3 - 2; m++)
                                   {
                                    //--- Only search if no valid internal setup has been found yet for this structure
                                    if(found == false && IsSwingHigh(high, m, 3))
                                      {
                                       i_high   = high[m]; // record internal high price
                                       i_high_t = time[m]; // record internal high time

                                       //--- Scan forward for the first internal low after this internal high
                                       for(int n = m; n < rates_total - 3 - 2; n++)
                                         {
                                          if(IsSwingLow(low, n, 3))
                                            {
                                             i_low   = low[n];   // record internal low price
                                             i_low_t = time[n];  // record internal low time

                                             //--- Scan forward for a CHoCH candle that crosses above the internal high
                                             for(int o = n; o <= rates_total - 1; o++)
                                               {
                                                in_bars = Bars(_Symbol, PERIOD_CURRENT, s4_h_t, time[o]); // bars from S4 to current candle

                                                //--- CHoCH condition: candle opens below and closes above the internal high within the structure range
                                                if(in_bars <= ex_bars && open[o] < i_high && close[o] > i_high)
                                                  {
                                                   //--- Internal low must be below the internal high for a valid IH-IL-CHoCH sequence
                                                   if(i_low < i_high)
                                                     {

                                                      //--- Check whether a previous internal structure already exists between m and o
                                                      bool is_prev_in = false;

                                                      //--- Scan for any earlier internal high between the current IH and CHoCH candle
                                                      for(int x = m + 1; x <= o - 2; x++)
                                                        {
                                                         if(IsSwingHigh(high, x, 3))
                                                           {
                                                            //--- Scan for an internal low after that earlier high
                                                            for(int y = x; y <= o - 2; y++)
                                                              {
                                                               if(IsSwingLow(low, y, 3))
                                                                 {
                                                                  //--- Check if a CHoCH already occurred for that earlier internal high
                                                                  for(int z = y; z < o; z++)
                                                                    {
                                                                     if(open[z] < high[x] && close[z] > high[x])
                                                                       {
                                                                        is_prev_in = true; // a prior internal sequence already fired

                                                                        break; // stop scanning — prior internal found
                                                                       }
                                                                    }
                                                                  break; // use only the first internal low after x
                                                                 }
                                                              }
                                                           }
                                                        }

                                                      //--- Find the lowest low from S3 to the CHoCH candle for external low validation
                                                      exll_bars = Bars(_Symbol, PERIOD_CURRENT, s3_lowest_t, time[o]);
                                                      exll      = low[ArrayMinimum(low, s3_lowest_index, exll_bars)];

                                                      //--- Find the highest high from S4 to the CHoCH candle for external high validation
                                                      exhh_bars = Bars(_Symbol, PERIOD_CURRENT, s4_h_t, time[o]);
                                                      exhh      = high[ArrayMaximum(high, l, exhh_bars)];

                                                      //--- Build unique object names for this internal setup
                                                      in_line_s1_2 = OBJ_PREFIX + "In Line S12"       + TimeToString(time[m]) + TimeToString(time[n]);
                                                      in_line_s1_c = OBJ_PREFIX + "In Line Cross S12" + TimeToString(time[m]) + TimeToString(time[o]);


                                                      //--- Calculate take profit at 1.5x the risk from entry close
                                                      tp      = close[o] + ((close[o] - low[n]) * 1.5);
                                                      tp_line = OBJ_PREFIX + "TP Line" + TimeToString(time[n]) + TimeToString(time[o]);
                                                      tp_txt  = OBJ_PREFIX + "TP Text" + TimeToString(time[o]);
                                                      buy_obj      = OBJ_PREFIX + "Buy Object"         + TimeToString(time[o]);
                                                      sl_line      = OBJ_PREFIX + "SL Line"            + TimeToString(time[n]) + TimeToString(time[o]);
                                                      sl_txt       = OBJ_PREFIX + "SL Text"            + TimeToString(time[o]);

                                                      //--- Draw objects only if no prior internal exists and external structure is still intact
                                                      if(is_prev_in == false && exll == s3_lowest && exhh == s4_h)
                                                        {

                                                         //--- Draw internal structure lines, entry arrow, SL, and TP objects
                                                         if(DrawTrend(in_line_s1_2, i_high_t,  i_high,  i_low_t,  i_low,   clrBlue)
                                                            && DrawTrend(in_line_s1_c, i_high_t,  i_high,  time[o], i_high,  clrBlue
                                                                         && DrawObject(buy_obj,     time[o],   close[o],          OBJ_ARROW_BUY)
                                                                         && DrawTrend(sl_line,      time[n],   low[n],  time[o], low[n],  clrBlue)
                                                                         && DrawTxt(sl_txt,         time[o],   low[n],  "SL",    clrBlue)
                                                                         && DrawTrend(tp_line,      time[n],   tp,      time[o], tp,      clrBlue)
                                                                         && DrawTxt(tp_txt,         time[o],   tp,      "TP",    clrBlue))
                                                           )
                                                           {
                                                            need_redraw = true; // mark chart for redraw
                                                           }

                                                        }
                                                     }

                                                   found = true; // mark this structure as processed — stop scanning m for new internal highs
                                                   break;
                                                  }
                                               }

                                             break;
                                            }
                                         }
                                      }
                                   }

                                 //
                                }

                              break;
                             }
                          }
                        break;
                       }
                    }
                  break;
                 }
              }
           }
        }

      lastTradeBarTime = currentBarTime; // update last processed bar time to prevent re-running on same candle
     }

//--- Redraw the chart only if at least one new object was created
   if(need_redraw)
      ChartRedraw(0);

//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Returns true if the bar at index is a swing low                  |
//| Checks that it is lower than all bars within the lookback range  |
//+------------------------------------------------------------------+
bool IsSwingLow(const double &low_price[], int index, int lookback)
  {
   for(int i = 1; i <= lookback; i++)
     {
      //--- Fail if any left or right neighbour is lower than the candidate bar
      if(low_price[index] > low_price[index - i] || low_price[index] > low_price[index + i])
         return false;
     }
   return true; // all neighbours are higher — confirmed swing low
  }

//+------------------------------------------------------------------+
//| Returns true if the bar at index is a swing high                 |
//| Checks that it is higher than all bars within the lookback range |
//+------------------------------------------------------------------+
bool IsSwingHigh(const double &high_price[], int index, int lookback)
  {
   for(int i = 1; i <= lookback; i++)
     {
      //--- Fail if any left or right neighbour is higher than the candidate bar
      if(high_price[index] < high_price[index - i] || high_price[index] < high_price[index + i])
         return false;
     }
   return true; // all neighbours are lower — confirmed swing high
  }
//+------------------------------------------------------------------+
