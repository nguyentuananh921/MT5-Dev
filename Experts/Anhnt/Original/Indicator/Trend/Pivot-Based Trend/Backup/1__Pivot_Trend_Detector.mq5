//+------------------------------------------------------------------+
//|                                      1. Pivot Trend Detector.mq5 |
//|                           Copyright 2025, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Allan Munene Mutiiria."
#property link      "https://t.me/Forex_Algo_Trader"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots 4

#property indicator_label1 "PTD slow line up"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrDodgerBlue
#property indicator_width1 2

#property indicator_label2 "PTD slow line down"
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrCrimson
#property indicator_width2 2

#property indicator_label3 "PTD fast line"
#property indicator_type3 DRAW_COLOR_LINE
#property indicator_color3 clrDodgerBlue,clrCrimson
#property indicator_style3 STYLE_DOT

#property indicator_label4 "PTD trend start"
#property indicator_type4 DRAW_COLOR_ARROW
#property indicator_color4 clrDodgerBlue,clrCrimson
#property indicator_width4 2

#include <Canvas/Canvas.mqh>
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CCanvas obj_Canvas;                                                   //--- Canvas object
//--- input parameters
input int    fastPeriod       = 5;                                // Fast period
input int    slowPeriod       = 10;                               // Slow period
input color  upColor          = clrDodgerBlue;                    // Up trend color
input color  downColor        = clrCrimson;                       // Down trend color
input int    fillOpacity      = 128;                              // Fill opacity (0-255)
input int    arrowCode        = 77;                              // Arrow code for trend start
input bool   showExtensions   = true;                             // Show line extensions
input bool   enableFilling    = true;                             // Enable canvas fill (disable for speed)
input int    extendBars       = 1;                                // Extension bars to protrude lines/fill

//--- indicator buffers
double slowLineUpBuffer[],slowLineDownBuffer[],slowLineBuffer[],fastLineBuffer[],fastLineColorBuffer[],trendArrowColorBuffer[],trendArrowBuffer[],trendBuffer[]; //--- Indicator buffers

//--- chart properties
int    currentChartWidth = 0;                                     //--- Current chart width
int    currentChartHeight = 0;                                    //--- Current chart height
int    currentChartScale = 0;                                     //--- Current chart scale
int    firstVisibleBarIndex = 0;                                  //--- First visible bar index
int    visibleBarsCount = 0;                                      //--- Visible bars count
double minPrice = 0.0;                                            //--- Minimum price
double maxPrice = 0.0;                                            //--- Maximum price

//--- optimization flags
static datetime lastRedrawTime = 0;                               //--- Last redraw time
static double   previousTrend = -1;                               //--- Previous trend
string objectPrefix = "PTD_";                                     //--- Object prefix

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
// Set chart properties
   currentChartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS); //--- Get chart width
   currentChartHeight = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS); //--- Get chart height
   currentChartScale = (int)ChartGetInteger(0, CHART_SCALE);      //--- Get chart scale
   firstVisibleBarIndex = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR); //--- Get first visible bar
   visibleBarsCount = (int)ChartGetInteger(0, CHART_VISIBLE_BARS); //--- Get visible bars
   minPrice = ChartGetDouble(0, CHART_PRICE_MIN, 0);              //--- Get min price
   maxPrice = ChartGetDouble(0, CHART_PRICE_MAX, 0);              //--- Get max price
   
// Indicator buffers
   SetIndexBuffer(0,slowLineUpBuffer,INDICATOR_DATA);             //--- Set slow up buffer
   SetIndexBuffer(1,slowLineDownBuffer,INDICATOR_DATA);           //--- Set slow down buffer
   SetIndexBuffer(2,fastLineBuffer,INDICATOR_DATA);               //--- Set fast buffer
   SetIndexBuffer(3,fastLineColorBuffer,INDICATOR_COLOR_INDEX);   //--- Set fast color buffer
   SetIndexBuffer(4,trendArrowBuffer,INDICATOR_DATA);             //--- Set arrow buffer
   SetIndexBuffer(5,trendArrowColorBuffer,INDICATOR_COLOR_INDEX); //--- Set arrow color buffer
   SetIndexBuffer(6,trendBuffer,INDICATOR_CALCULATIONS);          //--- Set trend buffer
   SetIndexBuffer(7,slowLineBuffer,INDICATOR_CALCULATIONS);       //--- Set slow buffer
   
// Plot settings
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,slowPeriod);             //--- Set slow draw begin
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,slowPeriod);             //--- Set slow draw begin
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,fastPeriod);             //--- Set fast draw begin
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,fastPeriod);             //--- Set fast draw begin
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,slowPeriod);             //--- Set arrow draw begin
   PlotIndexSetInteger(3,PLOT_ARROW,arrowCode);                   //--- Set arrow code
   
// Line extensions
   PlotIndexSetInteger(0,PLOT_SHIFT,extendBars);                  //--- Set slow up shift
   PlotIndexSetInteger(1,PLOT_SHIFT,extendBars);                  //--- Set slow down shift
   PlotIndexSetInteger(2,PLOT_SHIFT,extendBars);                  //--- Set fast shift
   PlotIndexSetInteger(3,PLOT_SHIFT,0);                           //--- Set arrow shift
   
// Set plot colors dynamically
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, upColor);          //--- Set slow up color
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 0, downColor);        //--- Set slow down color
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 0, upColor);          //--- Set fast up color
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 1, downColor);        //--- Set fast down color
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, 0, upColor);          //--- Set arrow up color
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, 1, downColor);        //--- Set arrow down color
   
// Short name
   string shortName = "PTD(" + IntegerToString(fastPeriod) + "," + IntegerToString(slowPeriod) + ")"; //--- Set short name
   IndicatorSetString(INDICATOR_SHORTNAME, shortName);            //--- Set indicator short name

// Create canvas only if enabled
   if(enableFilling) {
      if(!obj_Canvas.CreateBitmapLabel(0, 0, shortName + "_Canvas", 0, 0, currentChartWidth, currentChartHeight, COLOR_FORMAT_ARGB_NORMALIZE)) {
         Print("Failed to create canvas");                           //--- Log failure
         return(INIT_FAILED);                                        //--- Return failure
      }
   }
   return(INIT_SUCCEEDED);                                        //--- Return success
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   if(enableFilling) obj_Canvas.Destroy();                            //--- Destroy canvas if enabled
   ObjectsDeleteAll(0,objectPrefix,0,OBJ_ARROW_RIGHT_PRICE);      //--- Delete right price arrows
   ChartRedraw(0);                                                //--- Redraw chart
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
                const int& spread[]) {
// Always calculate buffers
   int startBar = prev_calculated - 1;                            //--- Set start bar
   if(startBar < 0) startBar = 0;                                 //--- Adjust start bar
   for(int barIndex = startBar; barIndex < rates_total && !_StopFlag; barIndex++) {
      int fastStartBar = barIndex - fastPeriod + 1;               //--- Calc fast start
      if(fastStartBar < 0) fastStartBar = 0;                      //--- Adjust fast start
      int slowStartBar = barIndex - slowPeriod + 1;               //--- Calc slow start
      if(slowStartBar < 0) slowStartBar = 0;                      //--- Adjust slow start
      double slowHigh = high[ArrayMaximum(high, slowStartBar, slowPeriod)]; //--- Get slow high
      double slowLow = low[ArrayMinimum(low, slowStartBar, slowPeriod)]; //--- Get slow low
      double fastHigh = high[ArrayMaximum(high, fastStartBar, fastPeriod)]; //--- Get fast high
      double fastLow = low[ArrayMinimum(low, fastStartBar, fastPeriod)]; //--- Get fast low
      if(barIndex > 0) {
         slowLineBuffer[barIndex] = (close[barIndex] > slowLineBuffer[barIndex-1]) ? slowLow : slowHigh; //--- Set slow line
         fastLineBuffer[barIndex] = (close[barIndex] > fastLineBuffer[barIndex-1]) ? fastLow : fastHigh; //--- Set fast line
         trendBuffer[barIndex] = trendBuffer[barIndex-1];         //--- Set trend
         if(close[barIndex] < slowLineBuffer[barIndex] && close[barIndex] < fastLineBuffer[barIndex]) trendBuffer[barIndex] = 1; //--- Set up trend
         if(close[barIndex] > slowLineBuffer[barIndex] && close[barIndex] > fastLineBuffer[barIndex]) trendBuffer[barIndex] = 0; //--- Set down trend
         trendArrowBuffer[barIndex] = (trendBuffer[barIndex] != trendBuffer[barIndex-1]) ? slowLineBuffer[barIndex] : EMPTY_VALUE; //--- Set arrow
         slowLineUpBuffer[barIndex] = (trendBuffer[barIndex] == 0) ? slowLineBuffer[barIndex] : EMPTY_VALUE; //--- Set slow up
         slowLineDownBuffer[barIndex] = (trendBuffer[barIndex] == 1) ? slowLineBuffer[barIndex] : EMPTY_VALUE; //--- Set slow down
      } else {
         trendArrowBuffer[barIndex] = slowLineUpBuffer[barIndex] = slowLineDownBuffer[barIndex] = EMPTY_VALUE; //--- Set empties
         trendBuffer[barIndex] = fastLineColorBuffer[barIndex] = trendArrowColorBuffer[barIndex] = 0; //--- Set zeros
         fastLineBuffer[barIndex] = slowLineBuffer[barIndex] = close[barIndex]; //--- Set first lines
      }
      fastLineColorBuffer[barIndex] = trendArrowColorBuffer[barIndex] = trendBuffer[barIndex]; //--- Set colors
   }
   
// Draw line extensions if enabled
   if(showExtensions && rates_total > 0) {
      int latestBarIndex = rates_total - 1;                       //--- Get latest index
      double slowLineValue = slowLineBuffer[latestBarIndex];      //--- Get slow value
      double fastLineValue = fastLineBuffer[latestBarIndex];      //--- Get fast value
      double currentTrend = trendBuffer[latestBarIndex];          //--- Get trend
      color lineColor = (currentTrend == 0.0) ? upColor : downColor; //--- Set line color
      datetime currentBarTime = iTime(_Symbol, _Period, 0);       //--- Get current time
      long timeOffset = (long)extendBars * PeriodSeconds(_Period); //--- Calc offset
      datetime extensionTime = currentBarTime + (datetime)timeOffset; //--- Calc extension time
      drawRightPrice(objectPrefix + "SLOW", extensionTime, slowLineValue, lineColor, STYLE_SOLID); //--- Draw slow extension
      drawRightPrice(objectPrefix + "FAST", extensionTime, fastLineValue, lineColor, STYLE_DOT); //--- Draw fast extension
   }
   if(!enableFilling) return(rates_total);                       //--- Return if no filling
   
// Canvas logic only if enabled
   bool isNewBar = (rates_total > prev_calculated);               //--- Check new bar
   bool hasTrendChanged = false;                                  //--- Init trend changed
   if(rates_total > 0 && trendBuffer[rates_total-1] != previousTrend) {
      hasTrendChanged = true;                                     //--- Set changed
      previousTrend = trendBuffer[rates_total-1];                 //--- Update previous trend
   }
   
// Update chart properties (only if changed)
   bool hasChartChanged = false;                                  //--- Init chart changed
   int newChartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS); //--- Get new width
   int newChartHeight = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS); //--- Get new height
   int newChartScale = (int)ChartGetInteger(0, CHART_SCALE);     //--- Get new scale
   int newFirstVisibleBar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR); //--- Get new first visible
   int newVisibleBars = (int)ChartGetInteger(0, CHART_VISIBLE_BARS); //--- Get new visible bars
   double newMinPrice = ChartGetDouble(0, CHART_PRICE_MIN, 0);    //--- Get new min price
   double newMaxPrice = ChartGetDouble(0, CHART_PRICE_MAX, 0);    //--- Get new max price
   if(newChartWidth != currentChartWidth || newChartHeight != currentChartHeight) {
      obj_Canvas.Resize(newChartWidth, newChartHeight);               //--- Resize canvas
      currentChartWidth = newChartWidth;                          //--- Update width
      currentChartHeight = newChartHeight;                        //--- Update height
      hasChartChanged = true;                                     //--- Set changed
   }
   if(newChartScale != currentChartScale || newFirstVisibleBar != firstVisibleBarIndex || newVisibleBars != visibleBarsCount ||
         newMinPrice != minPrice || newMaxPrice != maxPrice) {
      currentChartScale = newChartScale;                          //--- Update scale
      firstVisibleBarIndex = newFirstVisibleBar;                  //--- Update first visible
      visibleBarsCount = newVisibleBars;                          //--- Update visible bars
      minPrice = newMinPrice;                                     //--- Update min price
      maxPrice = newMaxPrice;                                     //--- Update max price
      hasChartChanged = true;                                     //--- Set changed
   }
   
// Redraw only on: new bar, trend change, or chart resize/scroll. Debounce to 1x/sec max.
   datetime currentTime = TimeCurrent();                          //--- Get current time
   if((isNewBar || hasTrendChanged || hasChartChanged) && (currentTime - lastRedrawTime >= 1)) {
      Redraw();                                                   //--- Redraw canvas
      lastRedrawTime = currentTime;                               //--- Update last redraw
   }
   return(rates_total);                                           //--- Return total rates
}

//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {
   if(id != CHARTEVENT_CHART_CHANGE || !enableFilling) return;
   int newChartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS); //--- Get new width
   int newChartHeight = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS); //--- Get new height
   if(newChartWidth != currentChartWidth || newChartHeight != currentChartHeight) {
      obj_Canvas.Resize(newChartWidth, newChartHeight);               //--- Resize canvas
      currentChartWidth = newChartWidth;                          //--- Update width
      currentChartHeight = newChartHeight;                        //--- Update height
      Redraw();                                                   //--- Redraw canvas
      return;                                                     //--- Return
   }
   int newChartScale = (int)ChartGetInteger(0, CHART_SCALE);     //--- Get new scale
   int newFirstVisibleBar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR); //--- Get new first visible
   int newVisibleBars = (int)ChartGetInteger(0, CHART_VISIBLE_BARS); //--- Get new visible bars
   double newMinPrice = ChartGetDouble(0, CHART_PRICE_MIN, 0);    //--- Get new min price
   double newMaxPrice = ChartGetDouble(0, CHART_PRICE_MAX, 0);    //--- Get new max price
   if(newChartScale != currentChartScale || newFirstVisibleBar != firstVisibleBarIndex || newVisibleBars != visibleBarsCount ||
         newMinPrice != minPrice || newMaxPrice != maxPrice) {
      currentChartScale = newChartScale;                          //--- Update scale
      firstVisibleBarIndex = newFirstVisibleBar;                  //--- Update first visible
      visibleBarsCount = newVisibleBars;                          //--- Update visible bars
      minPrice = newMinPrice;                                     //--- Update min price
      maxPrice = newMaxPrice;                                     //--- Update max price
      Redraw();                                                   //--- Redraw canvas
   }
}

//+------------------------------------------------------------------+
//| Convert chart scale to bar width                                 |
//+------------------------------------------------------------------+
int BarWidth(int chartScale) {
   return (int)MathPow(2.0, chartScale);                          //--- Return bar width
}

//+------------------------------------------------------------------+
//| Convert bar shift to x pixel                                     |
//+------------------------------------------------------------------+
int ShiftToX(int barShift) {
   return (int)((firstVisibleBarIndex - barShift) * BarWidth(currentChartScale) - 1); //--- Return x pixel
}

//+------------------------------------------------------------------+
//| Convert price to y pixel                                         |
//+------------------------------------------------------------------+
int PriceToY(double price) {
   if(maxPrice - minPrice == 0.0) return 0;                      //--- Return zero if no range
   return (int)MathRound(currentChartHeight * (maxPrice - price) / (maxPrice - minPrice) - 1); //--- Return y pixel
}

//+------------------------------------------------------------------+
//| Draw right price extension line/label                            |
//+------------------------------------------------------------------+
bool drawRightPrice(string objectName, datetime lineTime, double linePrice, color lineColor, ENUM_LINE_STYLE lineStyle = STYLE_SOLID) {
   bool objectExists = (ObjectFind(0, objectName) >= 0);          //--- Check exists
   if(!objectExists) {
      if(!ObjectCreate(0, objectName, OBJ_ARROW_RIGHT_PRICE, 0, lineTime, linePrice)) {
         Print("Failed to create ", objectName);                  //--- Log failure
         return false;                                            //--- Return failure
      }
   } else {
      ObjectSetInteger(0, objectName, OBJPROP_TIME, 0, lineTime); //--- Set time
      ObjectSetDouble(0, objectName, OBJPROP_PRICE, 0, linePrice); //--- Set price
   }
   long currentScale = ChartGetInteger(0, CHART_SCALE);           //--- Get scale
   int lineWidth = 1;                                             //--- Init width
   if(currentScale <= 1) lineWidth = 1;                           //--- Set width small
   else if(currentScale <= 3) lineWidth = 2;                      //--- Set width medium
   else lineWidth = 3;                                            //--- Set width large
   ObjectSetInteger(0, objectName, OBJPROP_COLOR, lineColor);     //--- Set color
   ObjectSetInteger(0, objectName, OBJPROP_WIDTH, lineWidth);     //--- Set width
   ObjectSetInteger(0, objectName, OBJPROP_STYLE, lineStyle);     //--- Set style
   ObjectSetInteger(0, objectName, OBJPROP_BACK, false);          //--- Set foreground
   ObjectSetInteger(0, objectName, OBJPROP_SELECTABLE, false);    //--- Set not selectable
   ObjectSetInteger(0, objectName, OBJPROP_SELECTED, false);      //--- Set not selected
   ChartRedraw(0);                                                //--- Redraw chart
   return true;                                                   //--- Return success
}

//+------------------------------------------------------------------+
//| Fill area between two lines using trend for color with gradient alpha from slow to fast |
//+------------------------------------------------------------------+
void DrawFilling(const double &slowLineValues[], const double &fastLineValues[], const double &trendValues[], color fillUpColor, color fillDownColor, uchar fillAlpha = 255, int extendShift = 0) {
   int firstVisibleBar = firstVisibleBarIndex;                    //--- Get first visible
   int totalBarsToDraw = visibleBarsCount + extendShift;          //--- Calc bars to draw
   int bufferSize = (int)ArraySize(slowLineValues);               //--- Get buffer size
   if(bufferSize == 0 || bufferSize != ArraySize(fastLineValues) || bufferSize != ArraySize(trendValues)) return; //--- Return if invalid
   int previousX = -1;                                            //--- Init previous X
   int previousY1 = -1;                                           //--- Init previous Y1
   int previousY2 = -1;                                           //--- Init previous Y2
   for(int offset = 0; offset < totalBarsToDraw; offset++) {
      int barPosition = firstVisibleBar - offset;                 //--- Calc bar position
      int x = ShiftToX(barPosition);                              //--- Calc x
      if(x >= currentChartWidth) break;                           //--- Break if beyond width
      int dataBarShift = firstVisibleBar - offset + extendShift;  //--- Calc data shift
      int bufferBarIndex = bufferSize - 1 - dataBarShift;         //--- Calc buffer index
      if(bufferBarIndex < 0 || bufferBarIndex >= bufferSize) {
         previousX = -1;                                          //--- Reset previous X
         continue;                                                //--- Continue
      }
      double value1 = slowLineValues[bufferBarIndex];             //--- Get value1
      double value2 = fastLineValues[bufferBarIndex];             //--- Get value2
      if(value1 == EMPTY_VALUE || value2 == EMPTY_VALUE) {
         previousX = -1;                                          //--- Reset previous X
         continue;                                                //--- Continue
      }
      int y1 = PriceToY(value1);                                  //--- Calc y1
      int y2 = PriceToY(value2);                                  //--- Calc y2
      double currentTrend = trendValues[bufferBarIndex];          //--- Get trend
      uint baseColorRGB = (currentTrend == 0.0) ? (ColorToARGB(fillUpColor, 255) & 0x00FFFFFF) : (ColorToARGB(fillDownColor, 255) & 0x00FFFFFF); //--- Set base RGB
      if(previousX != -1 && x > previousX) {
         double deltaX = x - previousX;                           //--- Calc delta X
         int endColumn = MathMin(x, currentChartWidth - 1);       //--- Calc end column
         double maxT = (double)(endColumn - previousX) / deltaX;  //--- Calc max T
         for(int column = previousX; column <= endColumn; column++) {
            double t = (column - previousX) / deltaX;             //--- Calc t
            double interpolatedY1 = previousY1 + t * (y1 - previousY1); //--- Interpolate Y1
            double interpolatedY2 = previousY2 + t * (y2 - previousY2); //--- Interpolate Y2
            int upperY = (int)MathRound(MathMin(interpolatedY1, interpolatedY2)); //--- Calc upper Y
            int lowerY = (int)MathRound(MathMax(interpolatedY1, interpolatedY2)); //--- Calc lower Y
            if(upperY > lowerY) continue;                        //--- Continue if invalid
            double slowLineY = interpolatedY1;                    //--- Set slow Y
            double height = MathAbs(interpolatedY1 - interpolatedY2); //--- Calc height
            if(height == 0.0) continue;                          //--- Continue if no height
            // Fill per row with gradient from slow (opaque) to fast (transparent)
            for(int row = upperY; row <= lowerY; row++) {
               double distanceFromSlow = MathAbs(row - slowLineY); //--- Calc distance
               double gradientFraction = distanceFromSlow / height; //--- Calc fraction
               uchar alphaValue = (uchar)(fillAlpha * (1.0 - gradientFraction)); //--- Calc alpha
               if(alphaValue > fillAlpha) alphaValue = fillAlpha; //--- Cap alpha
               uint pixelColor = ((uint)alphaValue << 24) | baseColorRGB; //--- Set pixel color
               obj_Canvas.FillRectangle(column, row, column, row, pixelColor); //--- Fill pixel
            }
         }
      }
      previousX = x;                                              //--- Update previous X
      previousY1 = y1;                                            //--- Update previous Y1
      previousY2 = y2;                                            //--- Update previous Y2
   }
}

//+------------------------------------------------------------------+
//| Redraw the canvas                                                |
//+------------------------------------------------------------------+
void Redraw(void) {
   if(currentChartWidth <= 0 || currentChartHeight <= 0) return;  //--- Return if invalid size
   uint defaultColor = 0;                                         //--- Default color
   obj_Canvas.Erase(defaultColor);                                    //--- Erase canvas
   DrawFilling(slowLineBuffer, fastLineBuffer, trendBuffer, upColor, downColor, (uchar)fillOpacity, extendBars); //--- Draw filling
   obj_Canvas.Update();                                               //--- Update canvas
}
//+------------------------------------------------------------------+
