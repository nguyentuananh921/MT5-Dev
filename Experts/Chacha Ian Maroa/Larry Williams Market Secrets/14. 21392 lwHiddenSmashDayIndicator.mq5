
//+------------------------------------------------------------------+
//|                                    lwHiddenSmashDayIndicator.mq5 |
//|          Copyright 2026, MetaQuotes Ltd. Developer is Chacha Ian |
//|Larry Williams Market Secrets                                     |
//|14. Detecting Hidden Smash Day Reversals with a Custom Indicator  |
//|                     https://www.mql5.com/en/articles/21392       |
//+------------------------------------------------------------------+

#property copyright "Copyright 2026, MetaQuotes Ltd. Developer is Chacha Ian"
#property link      "https://www.mql5.com/en/users/chachaian"
#property version   "1.00"


//+------------------------------------------------------------------+
//| Custom Indicator specific directives                             |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_plots 2
#property indicator_buffers 2


//+------------------------------------------------------------------+
//| Defines how Hidden Smash Day patterns are validated               |
//+------------------------------------------------------------------+
enum ENUM_HIDDEN_SMASH_VALIDATION_MODE
{
   HIDDEN_SMASH_BAR_ONLY,
   HIDDEN_SMASH_CONFIRMED
};


//+------------------------------------------------------------------+
//| Hidden Smash Detection Settings                                  |
//+------------------------------------------------------------------+
input ENUM_HIDDEN_SMASH_VALIDATION_MODE hiddenSmashValidationMode = HIDDEN_SMASH_CONFIRMED;


//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;


//+------------------------------------------------------------------+
//| Indicator buffers                                                |
//+------------------------------------------------------------------+
double buySmashArrowBuffer [];
double sellSmashArrowBuffer[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){

   //--- To configure the chart's appearance
   if(!ConfigureChartAppearance()){
      Print("Error while configuring chart appearance: ", GetLastError());
      return INIT_FAILED;
   }
   
   //--- Set arrays as series
   ArraySetAsSeries(buySmashArrowBuffer,  false);
   ArraySetAsSeries(sellSmashArrowBuffer, false);
   
   //--- Bind arrays to indicator buffers
   SetIndexBuffer(0, buySmashArrowBuffer,  INDICATOR_DATA);
   SetIndexBuffer(1, sellSmashArrowBuffer, INDICATOR_DATA);
   
   //--- Configure Graphic Plots   
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrSeaGreen);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, +20);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   PlotIndexSetDouble (0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString (0, PLOT_LABEL, "Hidden Smash Buy Bar");
   
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrBlack);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -20);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   PlotIndexSetDouble (1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString (1, PLOT_LABEL, "Hidden Smash Sell bar");
   
   //--- General indicator configurations
   IndicatorSetString(INDICATOR_SHORTNAME, "Larry Williams Market Structure Indicator");

   return(INIT_SUCCEEDED);
}
 
 
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t  rates_total,
                const int32_t  prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int32_t  &spread[])
{  

   ArraySetAsSeries(open,  false);
   ArraySetAsSeries(high,  false);
   ArraySetAsSeries(low,   false);
   ArraySetAsSeries(close, false);

   //--- Temporary buffers used to store price data for rendering custom colored candles
   double lwOpen [];
   double lwHigh [];
   double lwLow  [];
   double lwClose[];
   
   //--- Copy price data into local working buffers to safely manipulate candle values without altering the original price arrays
   ArrayCopy(lwOpen, open);
   ArrayCopy(lwHigh, high);
   ArrayCopy(lwLow, low);
   ArrayCopy(lwClose, close); 

   //--- This block will be executed whenever the indicator is initially attached on a chart
   if(prev_calculated == 0){
      
      //--- Start with clean arrays
      ArrayInitialize(buySmashArrowBuffer,  EMPTY_VALUE);
      ArrayInitialize(sellSmashArrowBuffer, EMPTY_VALUE);
      
      //--- Map all hidden smash bar patterns
      MapHiddenSmashPatternsOnInitialization(rates_total, lwOpen, lwHigh, lwLow, lwClose, hiddenSmashValidationMode);
      
   }
   
   //--- This block is executed on new bar open
   if(prev_calculated != rates_total && prev_calculated != 0){
      
      //--- Update buffers on new bar open
      ProcessHiddenSmashOnNewBar(lwOpen, lwHigh, lwLow, lwClose, rates_total);
   
   }
   
   //--- This block is executed on arrival of new price (tick) data
   if(prev_calculated == rates_total){
      
      //--- Update buffers on new tick
      ProcessHiddenSmashOnTick(lwOpen, lwHigh, lwLow, lwClose, rates_total);
      
   }
   
   return(rates_total);
}


//+------------------------------------------------------------------+
//| This function configures the chart's appearance.                 |
//+------------------------------------------------------------------+
bool ConfigureChartAppearance()
{
   if(!ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhite)){
      Print("Error while setting chart background, ", GetLastError());
      return false;
   }
   
   if(!ChartSetInteger(0, CHART_SHOW_GRID, false)){
      Print("Error while setting chart grid, ", GetLastError());
      return false;
   }
   
   if(!ChartSetInteger(0, CHART_MODE, CHART_CANDLES)){
      Print("Error while setting chart mode, ", GetLastError());
      return false;
   }

   if(!ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack)){
      Print("Error while setting chart foreground, ", GetLastError());
      return false;
   }

   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrSeaGreen)){
      Print("Error while setting bullish candles color, ", GetLastError());
      return false;
   }
      
   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrBlack)){
      Print("Error while setting bearish candles color, ", GetLastError());
      return false;
   }
   
   if(!ChartSetInteger(0, CHART_COLOR_CHART_UP, clrSeaGreen)){
      Print("Error while setting bullish candles color, ", GetLastError());
      return false;
   }
   
   if(!ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrBlack)){
      Print("Error while setting bearish candles color, ", GetLastError());
      return false;
   }
   
   return true;
}


//+------------------------------------------------------------------+
//| Identifies a Bullish Hidden Smash Bar at a specific index        |
//| Larry Williams definition applied to any timeframe               |
//+------------------------------------------------------------------+
bool IsHiddenSmashBuyBarAtIndex(
   const int i,
   const double &open[],
   const double &high[],
   const double &low[],
   const double &close[],
   const bool requireCloseBelowOpen = false
)
{
   // We need a previous bar to confirm an up close
   if(i < 1)
      return false;

   // 1. Must close higher than the previous bar
   if(close[i] <= close[i - 1])
      return false;

   // 2. Use the bar's own range
   double range = high[i] - low[i];
   if(range <= 0.0)
      return false;

   // 3. Close must be in the lower 25 percent of the bar range
   double lowerQuarter = low[i] + (range * 0.25);
   if(close[i] > lowerQuarter)
      return false;

   // 4. Best patterns only if requested
   if(requireCloseBelowOpen && close[i] >= open[i])
      return false;

   return true;
}


//+------------------------------------------------------------------+
//| Identifies a Bearish Hidden Smash Bar at a specific index        |
//| Larry Williams definition applied to any timeframe               |
//+------------------------------------------------------------------+
bool IsHiddenSmashSellBarAtIndex(
   const int i,
   const double &open[],
   const double &high[],
   const double &low[],
   const double &close[],
   const bool requireCloseAboveOpen = false
)
{
   // We need a previous bar to confirm a down close
   if(i < 1)
      return false;

   // 1. Must close lower than the previous bar
   if(close[i] >= close[i - 1])
      return false;

   // 2. Use the bar's own range
   double range = high[i] - low[i];
   if(range <= 0.0)
      return false;

   // 3. Close must be in the upper 25 percent of the bar range
   double upperQuarter = high[i] - (range * 0.25);
   if(close[i] < upperQuarter)
      return false;

   // 4. Best patterns only if requested
   if(requireCloseAboveOpen && close[i] <= open[i])
      return false;

   return true;
}


//+------------------------------------------------------------------+
//| Returns true if a Hidden Smash Day Buy pattern is confirmed      |
//| Confirmation requires next bar to close above smash bar high     |
//+------------------------------------------------------------------+
bool IsConfirmedHiddenSmashBuyAtIndex(const double &open[],
                                      const double &high[],
                                      const double &low[],
                                      const double &close[],
                                      int index
                                      )
{
   int confirmationIndex = index + 1;

   // Ensure confirmation bar exists
   if(confirmationIndex >= ArraySize(close))
      return false;

   // Smash bar must be valid
   if(!IsHiddenSmashBuyBarAtIndex(index, open, high, low, close))
      return false;

   // Confirmation close above smash bar high
   if(close[confirmationIndex] > high[index])
      return true;

   return false;
}


//+------------------------------------------------------------------+
//| Returns true if a Hidden Smash Day Sell pattern is confirmed     |
//| Confirmation requires next bar to close below smash bar low      |
//+------------------------------------------------------------------+
bool IsConfirmedHiddenSmashSellAtIndex(const double &open[],
                                       const double &high[],
                                       const double &low[],
                                       const double &close[],
                                       int index
                                       )
{
   int confirmationIndex = index + 1;

   // Ensure confirmation bar exists
   if(confirmationIndex >= ArraySize(close))
      return false;

   // Smash bar must be valid
   if(!IsHiddenSmashSellBarAtIndex(index, open, high, low, close))
      return false;

   // Confirmation close below smash bar low
   if(close[confirmationIndex] < low[index])
      return true;

   return false;
}


//+------------------------------------------------------------------+
//| Scans historical bars and maps Hidden Smash patterns on load     |
//+------------------------------------------------------------------+
void MapHiddenSmashPatternsOnInitialization(
   const int rates_total,
   const double &open[],
   const double &high[],
   const double &low [],
   const double &close[],
   int hidden_SmashValidationMode,
   double closePercentThreshold = 25.0
)
{
   //--- Safety check
   if(rates_total <= 1)
      return;

   //--- Loop through all historical bars
   for(int i = 1; i <= rates_total - 1; i++)
   {
      //--- Default to empty
      buySmashArrowBuffer[i]  = EMPTY_VALUE;
      sellSmashArrowBuffer[i] = EMPTY_VALUE;

      //--- Mode 1: Bar only identification
      if(hiddenSmashValidationMode == HIDDEN_SMASH_BAR_ONLY)
      {
         if(IsHiddenSmashBuyBarAtIndex(i, open, high, low, close))
         {
            buySmashArrowBuffer[i] = low[i];
         }

         if(IsHiddenSmashSellBarAtIndex(i, open, high, low, close))
         {
            sellSmashArrowBuffer[i] = high[i];
         }
      }
      //--- Mode 2: Confirmed pattern identification
      else if(hiddenSmashValidationMode == HIDDEN_SMASH_CONFIRMED)
      {
         if(IsConfirmedHiddenSmashBuyAtIndex(open, high, low, close,
                                             i))
         {
            buySmashArrowBuffer[i] = low[i];
         }

         if(IsConfirmedHiddenSmashSellAtIndex(open, high, low, close,
                                              i))
         {
            sellSmashArrowBuffer[i] = high[i];
         }
      }
   }
}


//+------------------------------------------------------------------+
//| Evaluates hidden smash patterns on new bar formation             |
//| Updates indicator buffers for the recently completed bar         |
//+------------------------------------------------------------------+
void ProcessHiddenSmashOnNewBar(
   const double &open[],
   const double &high[],
   const double &low[],
   const double &close[],
   int rates_total
)
{
   int completedBarIndex = rates_total - 2;
   int currentBarIndex   = rates_total - 1;

   //--- Safety check
   if(completedBarIndex < 0)
      return;

   //--- Always clear buffers for involved bars
   buySmashArrowBuffer [completedBarIndex] = EMPTY_VALUE;
   sellSmashArrowBuffer[completedBarIndex] = EMPTY_VALUE;

   buySmashArrowBuffer [currentBarIndex]   = EMPTY_VALUE;
   sellSmashArrowBuffer[currentBarIndex]   = EMPTY_VALUE;

   //--- Mode 1: Detect bar only
   if(hiddenSmashValidationMode == HIDDEN_SMASH_BAR_ONLY)
   {
      if(IsHiddenSmashBuyBarAtIndex(completedBarIndex, open, high, low, close))
         buySmashArrowBuffer[completedBarIndex] = low[completedBarIndex];

      if(IsHiddenSmashSellBarAtIndex(completedBarIndex, open, high, low, close))
         sellSmashArrowBuffer[completedBarIndex] = high[completedBarIndex];

      return;
   }

   //--- Mode 2: Confirmed smash
   if(hiddenSmashValidationMode == HIDDEN_SMASH_CONFIRMED)
   {
      int smashBarIndex = completedBarIndex - 1;
      if(smashBarIndex < 0)
         return;

      if(IsHiddenSmashBuyBarAtIndex(smashBarIndex, open, high, low, close))
      {
         if(close[completedBarIndex] > high[smashBarIndex])
            buySmashArrowBuffer[smashBarIndex] = low[smashBarIndex];
      }

      if(IsHiddenSmashSellBarAtIndex(smashBarIndex, open, high, low, close))
      {
         if(close[completedBarIndex] < low[smashBarIndex])
            sellSmashArrowBuffer[smashBarIndex] = high[smashBarIndex];
      }
   }
}


//+------------------------------------------------------------------+
//| Evaluates hidden smash patterns on tick updates                  |
//| Supports real-time detection and confirmation logic              |
//+------------------------------------------------------------------+
void ProcessHiddenSmashOnTick(
   const double &open[],
   const double &high[],
   const double &low[],
   const double &close[],
   int rates_total
)
{
   int currentBarIndex   = rates_total - 1;
   int completedBarIndex = rates_total - 2;

   if(currentBarIndex < 0)
      return;

   //--- Always reset current bar buffer values
   buySmashArrowBuffer [currentBarIndex] = EMPTY_VALUE;
   sellSmashArrowBuffer[currentBarIndex] = EMPTY_VALUE;

   //--- Mode 1: Bar-only detection in real time
   if(hiddenSmashValidationMode == HIDDEN_SMASH_BAR_ONLY)
   {
      if(IsHiddenSmashBuyBarAtIndex(currentBarIndex, open, high, low, close))
         buySmashArrowBuffer[currentBarIndex] = low[currentBarIndex];

      if(IsHiddenSmashSellBarAtIndex(currentBarIndex, open, high, low, close))
         sellSmashArrowBuffer[currentBarIndex] = high[currentBarIndex];

      return;
   }

   //--- Mode 2: Confirmed smash evaluated continuously
   if(hiddenSmashValidationMode == HIDDEN_SMASH_CONFIRMED)
   {
      int smashBarIndex = completedBarIndex;
      if(smashBarIndex < 0)
         return;

      if(IsHiddenSmashBuyBarAtIndex(smashBarIndex, open, high, low, close))
      {
         if(close[currentBarIndex] > high[smashBarIndex])
            buySmashArrowBuffer[smashBarIndex] = low[smashBarIndex];
      }

      if(IsHiddenSmashSellBarAtIndex(smashBarIndex, open, high, low, close))
      {
         if(close[currentBarIndex] < low[smashBarIndex])
            sellSmashArrowBuffer[smashBarIndex] = high[smashBarIndex];
      }
   }
}
