//+------------------------------------------------------------------+
//|                            Equidistant Channel Auto-Placement.mq5|
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "2025 Clemence Benjamin"
#property version   "1.00"
#property strict

//--- Enums
enum ENUM_CHANNEL_TYPE
{
   CHANNEL_NONE,
   CHANNEL_RISING,   // Higher lows - Sell setups 
   CHANNEL_FALLING   // Lower highs - Buy setups 
};

//--- Input parameters
input bool   EnableRisingChannels   = true;    // Enable rising channels (higher lows) - Sell
input bool   EnableFallingChannels  = true;    // Enable falling channels (lower highs) - Buy
input int    LookbackBars           = 150;     // Bars to scan for swing points
input int    SwingStrength          = 2;       // Swing strength (bars each side)
input bool   ShowChannel            = true;    // Draw the channel
input color  RisingChannelColor     = clrRed;  // Red for rising (sell)
input color  FallingChannelColor    = clrLimeGreen; // Green for falling (buy)
input int    ChannelWidth           = 1;       // Channel line width
input int    MinChannelLengthBars   = 15;      // Minimum bars between swing points
input double MinChannelHeightPct    = 0.5;     // Minimum channel height as % of price
input bool   AlertOnNewChannel      = true;    // Alert when new channel detected
input int    MinTouchesPerLine      = 2;       // Minimum touches per channel line
input double TouchTolerancePips     = 5.0;     // Touch tolerance in pips
input int    MaxExtensionBars       = 50;      // Maximum bars to extend channel
input bool   ExtendLeft             = true;    // Extend channel slightly left
input bool   ExtendRight            = false;   // Don't extend to right edge

//--- Global variables
datetime lastBarTime = 0;
string currentChannelName = "";
string channelPrefix = "SmartCh_";
bool channelFound = false;
ENUM_CHANNEL_TYPE currentChannelType = CHANNEL_NONE;
datetime lastAlertTime = 0;
int channelStartBar = -1;
int channelEndBar = -1;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Clean any existing channels
   DeleteAllChannels();
   
   Print("Smart Single Channel EA initialized");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Optional: Delete channel on exit
   // DeleteAllChannels();
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   // Only process on new bar (every 5 minutes on M5)
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   if(currentBarTime <= lastBarTime) return;
   lastBarTime = currentBarTime;
   
   // Only check for channels every few bars to avoid continuous alerts
   int barShift = iBarShift(_Symbol, _Period, currentBarTime);
   if(barShift % 3 != 0) return; // Check every 3 bars
   
   // Find and draw the single most recent valid channel
   FindAndDrawSingleChannel();
}

//+------------------------------------------------------------------+
//| Find and draw single most recent valid channel                  |
//+------------------------------------------------------------------+
void FindAndDrawSingleChannel()
{
   // First, look for rising channels (higher lows - sell setups)
   bool risingFound = false;
   int risePoint1 = -1, risePoint2 = -1;
   double riseSlope = 0;
   int riseTouchCount = 0;
   
   if(EnableRisingChannels)
   {
      risingFound = FindRisingChannel(risePoint1, risePoint2, riseSlope, riseTouchCount);
   }
   
   // Then, look for falling channels (lower highs - buy setups)
   bool fallingFound = false;
   int fallPoint1 = -1, fallPoint2 = -1;
   double fallSlope = 0;
   int fallTouchCount = 0;
   
   if(EnableFallingChannels)
   {
      fallingFound = FindFallingChannel(fallPoint1, fallPoint2, fallSlope, fallTouchCount);
   }
   
   // Decide which channel to display based on recency and validity
   bool drawChannel = false;
   int point1 = -1, point2 = -1;
   double slope = 0;
   ENUM_CHANNEL_TYPE newType = CHANNEL_NONE;
   int touchCount = 0;
   
   if(risingFound && fallingFound)
   {
      // Both found - choose based on recency and touch count
      if(risePoint1 > fallPoint1 || riseTouchCount > fallTouchCount + 1)
      {
         drawChannel = true;
         point1 = risePoint1;
         point2 = risePoint2;
         slope = riseSlope;
         newType = CHANNEL_RISING;
         touchCount = riseTouchCount;
      }
      else
      {
         drawChannel = true;
         point1 = fallPoint1;
         point2 = fallPoint2;
         slope = fallSlope;
         newType = CHANNEL_FALLING;
         touchCount = fallTouchCount;
      }
   }
   else if(risingFound && riseTouchCount >= MinTouchesPerLine * 2)
   {
      drawChannel = true;
      point1 = risePoint1;
      point2 = risePoint2;
      slope = riseSlope;
      newType = CHANNEL_RISING;
      touchCount = riseTouchCount;
   }
   else if(fallingFound && fallTouchCount >= MinTouchesPerLine * 2)
   {
      drawChannel = true;
      point1 = fallPoint1;
      point2 = fallPoint2;
      slope = fallSlope;
      newType = CHANNEL_FALLING;
      touchCount = fallTouchCount;
   }
   
   // Draw the channel if found with enough touches
   if(drawChannel && touchCount >= MinTouchesPerLine * 2)
   {
      // Check if this is a new channel (different from current or enough time passed)
      bool isNewChannel = (!channelFound) || 
                         (currentChannelType != newType) ||
                         (MathAbs(point1 - channelStartBar) > 10) ||
                         (TimeCurrent() - lastAlertTime > 3600); // 1 hour since last alert
      
      if(isNewChannel)
      {
         // Delete old channel if needed
         DeleteAllChannels();
         
         // Draw new channel
         if(DrawChannel(point1, point2, slope, newType))
         {
            channelFound = true;
            currentChannelType = newType;
            channelStartBar = point1;
            channelEndBar = point2;
            
            // Alert if enabled and enough time passed
            if(AlertOnNewChannel && (TimeCurrent() - lastAlertTime > 3600))
            {
               string typeStr = (newType == CHANNEL_RISING) ? "Rising (Sell Setup)" : "Falling (Buy Setup)";
               string message = StringFormat("%s channel detected on %s %s. %d touches confirmed.", 
                           typeStr, Symbol(), PeriodToString(_Period), touchCount);
               Alert(message);
               lastAlertTime = TimeCurrent();
            }
         }
      }
   }
   else
   {
      // No valid channel found
      if(channelFound)
      {
         // Check if current channel is still valid
         if(!IsChannelStillValid())
         {
            DeleteAllChannels();
            channelFound = false;
            currentChannelType = CHANNEL_NONE;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Find rising channel (higher lows - sell setup)                  |
//+------------------------------------------------------------------+
bool FindRisingChannel(int &point1, int &point2, double &slope, int &touchCount)
{
   // Find swing lows
   int swingLows[];
   FindSwingLows(swingLows, SwingStrength, LookbackBars);
   
   if(ArraySize(swingLows) < 2) return false;
   
   // Try to find the best rising channel (higher lows)
   int bestPoint1 = -1, bestPoint2 = -1;
   double bestScore = -1;
   int bestTouches = 0;
   
   for(int i = 0; i < ArraySize(swingLows) - 1; i++)
   {
      for(int j = i + 1; j < ArraySize(swingLows); j++)
      {
         int low1 = swingLows[i];      // More recent low
         int low2 = swingLows[j];      // Older low
         
         // Ensure lows are ascending (higher lows for rising channel)
         if(iLow(NULL, 0, low1) <= iLow(NULL, 0, low2)) continue;
         
         // Ensure minimum distance between lows
         if(MathAbs(low1 - low2) < MinChannelLengthBars) continue;
         
         // Calculate channel properties
         double low1Price = iLow(NULL, 0, low1);
         double low2Price = iLow(NULL, 0, low2);
         
         // Calculate slope (price per bar)
         double barDiff = MathAbs(low1 - low2);
         slope = (low1Price - low2Price) / barDiff;
         
         // Reject if slope is too flat
         if(slope < 0.00005) continue; // Very small positive slope
         
         // Calculate parallel upper line
         double channelHeight = CalculateChannelHeight(low1, low2, true);
         
         // Check for touches on both lines
         int touches = CountChannelTouches(low1, low2, slope, low2Price, channelHeight, true);
         
         // Calculate score based on recency, touches, and channel quality
         double recencyScore = 100.0 - (low1 * 100.0 / LookbackBars);
         double touchScore = touches * 25.0;
         double heightScore = (channelHeight / SymbolInfoDouble(_Symbol, SYMBOL_POINT)) / 100.0;
         
         double totalScore = recencyScore + touchScore + heightScore;
         
         if(totalScore > bestScore && touches >= MinTouchesPerLine * 2)
         {
            bestScore = totalScore;
            bestPoint1 = low1;
            bestPoint2 = low2;
            bestTouches = touches;
         }
      }
   }
   
   if(bestScore > 0)
   {
      point1 = bestPoint1;
      point2 = bestPoint2;
      slope = (iLow(NULL, 0, bestPoint1) - iLow(NULL, 0, bestPoint2)) / MathAbs(bestPoint1 - bestPoint2);
      touchCount = bestTouches;
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Find falling channel (lower highs - buy setup)                  |
//+------------------------------------------------------------------+
bool FindFallingChannel(int &point1, int &point2, double &slope, int &touchCount)
{
   // Find swing highs
   int swingHighs[];
   FindSwingHighs(swingHighs, SwingStrength, LookbackBars);
   
   if(ArraySize(swingHighs) < 2) return false;
   
   // Try to find the best falling channel (lower highs)
   int bestPoint1 = -1, bestPoint2 = -1;
   double bestScore = -1;
   int bestTouches = 0;
   
   for(int i = 0; i < ArraySize(swingHighs) - 1; i++)
   {
      for(int j = i + 1; j < ArraySize(swingHighs); j++)
      {
         int high1 = swingHighs[i];      // More recent high
         int high2 = swingHighs[j];      // Older high
         
         // Ensure highs are descending (lower highs for falling channel)
         if(iHigh(NULL, 0, high1) >= iHigh(NULL, 0, high2)) continue;
         
         // Ensure minimum distance between highs
         if(MathAbs(high1 - high2) < MinChannelLengthBars) continue;
         
         // Calculate channel properties
         double high1Price = iHigh(NULL, 0, high1);
         double high2Price = iHigh(NULL, 0, high2);
         
         // Calculate slope (price per bar) - negative for descending
         double barDiff = MathAbs(high1 - high2);
         slope = (high1Price - high2Price) / barDiff;
         
         // Reject if slope is too flat
         if(slope > -0.00005) continue; // Very small negative slope
         
         // Calculate parallel lower line
         double channelHeight = CalculateChannelHeight(high1, high2, false);
         
         // Check for touches on both lines
         int touches = CountChannelTouches(high1, high2, slope, high2Price, channelHeight, false);
         
         // Calculate score based on recency, touches, and channel quality
         double recencyScore = 100.0 - (high1 * 100.0 / LookbackBars);
         double touchScore = touches * 25.0;
         double heightScore = (channelHeight / SymbolInfoDouble(_Symbol, SYMBOL_POINT)) / 100.0;
         
         double totalScore = recencyScore + touchScore + heightScore;
         
         if(totalScore > bestScore && touches >= MinTouchesPerLine * 2)
         {
            bestScore = totalScore;
            bestPoint1 = high1;
            bestPoint2 = high2;
            bestTouches = touches;
         }
      }
   }
   
   if(bestScore > 0)
   {
      point1 = bestPoint1;
      point2 = bestPoint2;
      slope = (iHigh(NULL, 0, bestPoint1) - iHigh(NULL, 0, bestPoint2)) / MathAbs(bestPoint1 - bestPoint2);
      touchCount = bestTouches;
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Calculate channel height                                        |
//+------------------------------------------------------------------+
double CalculateChannelHeight(int point1, int point2, bool isRising)
{
   double maxHeight = 0;
   int startBar = MathMin(point1, point2);
   int endBar = MathMax(point1, point2);
   
   double price1 = (isRising) ? iLow(NULL, 0, point1) : iHigh(NULL, 0, point1);
   double price2 = (isRising) ? iLow(NULL, 0, point2) : iHigh(NULL, 0, point2);
   
   // Calculate slope
   double slope = (price1 - price2) / (point1 - point2);
   double intercept = price1 - slope * point1;
   
   // Find maximum deviation from base line
   for(int bar = startBar; bar <= endBar; bar++)
   {
      double currentPrice = (isRising) ? iHigh(NULL, 0, bar) : iLow(NULL, 0, bar);
      double baseLinePrice = slope * bar + intercept;
      double deviation = MathAbs(currentPrice - baseLinePrice);
      
      if(deviation > maxHeight)
      {
         maxHeight = deviation;
      }
   }
   
   // Add minimum height requirement
   double minHeight = (isRising) ? iLow(NULL, 0, startBar) * MinChannelHeightPct / 100.0 : 
                                   iHigh(NULL, 0, startBar) * MinChannelHeightPct / 100.0;
   
   return MathMax(maxHeight, minHeight);
}

//+------------------------------------------------------------------+
//| Count touches on channel lines                                  |
//+------------------------------------------------------------------+
int CountChannelTouches(int point1, int point2, double slope, double basePrice, double height, bool isRising)
{
   int touches = 0;
   int startBar = MathMin(point1, point2);
   int endBar = MathMax(point1, point2);
   
   double tolerance = TouchTolerancePips * SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10;
   
   // Check touches on lower line (for rising) / upper line (for falling)
   for(int bar = startBar; bar <= endBar; bar++)
   {
      double currentPrice = (isRising) ? iLow(NULL, 0, bar) : iHigh(NULL, 0, bar);
      double baseLinePrice = slope * (bar - point2) + basePrice;
      
      if(MathAbs(currentPrice - baseLinePrice) <= tolerance)
      {
         touches++;
      }
   }
   
   // Check touches on upper line (for rising) / lower line (for falling)
   for(int bar = startBar; bar <= endBar; bar++)
   {
      double currentPrice = (isRising) ? iHigh(NULL, 0, bar) : iLow(NULL, 0, bar);
      double parallelLinePrice = slope * (bar - point2) + basePrice + (isRising ? height : -height);
      
      if(MathAbs(currentPrice - parallelLinePrice) <= tolerance)
      {
         touches++;
      }
   }
   
   return touches;
}

//+------------------------------------------------------------------+
//| Find swing lows                                                  |
//+------------------------------------------------------------------+
void FindSwingLows(int &swingPoints[], int strength, int lookback)
{
   ArrayResize(swingPoints, 0);
   
   for(int i = strength; i < MathMin(lookback, Bars(NULL, 0) - strength); i++)
   {
      bool isSwingLow = true;
      double currentLow = iLow(NULL, 0, i);
      
      // Check left side
      for(int left = 1; left <= strength; left++)
      {
         if(iLow(NULL, 0, i - left) < currentLow)
         {
            isSwingLow = false;
            break;
         }
      }
      
      // Check right side
      if(isSwingLow)
      {
         for(int right = 1; right <= strength; right++)
         {
            if(iLow(NULL, 0, i + right) < currentLow)
            {
               isSwingLow = false;
               break;
            }
         }
      }
      
      if(isSwingLow)
      {
         int size = ArraySize(swingPoints);
         ArrayResize(swingPoints, size + 1);
         swingPoints[size] = i;
      }
   }
   
   // Sort from most recent to oldest
   ArraySort(swingPoints);
}

//+------------------------------------------------------------------+
//| Find swing highs                                                 |
//+------------------------------------------------------------------+
void FindSwingHighs(int &swingPoints[], int strength, int lookback)
{
   ArrayResize(swingPoints, 0);
   
   for(int i = strength; i < MathMin(lookback, Bars(NULL, 0) - strength); i++)
   {
      bool isSwingHigh = true;
      double currentHigh = iHigh(NULL, 0, i);
      
      // Check left side
      for(int left = 1; left <= strength; left++)
      {
         if(iHigh(NULL, 0, i - left) > currentHigh)
         {
            isSwingHigh = false;
            break;
         }
      }
      
      // Check right side
      if(isSwingHigh)
      {
         for(int right = 1; right <= strength; right++)
         {
            if(iHigh(NULL, 0, i + right) > currentHigh)
            {
               isSwingHigh = false;
               break;
            }
         }
      }
      
      if(isSwingHigh)
      {
         int size = ArraySize(swingPoints);
         ArrayResize(swingPoints, size + 1);
         swingPoints[size] = i;
      }
   }
   
   // Sort from most recent to oldest
   ArraySort(swingPoints);
}

//+------------------------------------------------------------------+
//| Draw channel with proper extension                             |
//+------------------------------------------------------------------+
bool DrawChannel(int point1, int point2, double slope, ENUM_CHANNEL_TYPE type)
{
   if(!ShowChannel) return false;
   
   // Delete any existing channel
   DeleteAllChannels();
   
   // Get prices and times
   datetime time1 = iTime(NULL, 0, point1);
   datetime time2 = iTime(NULL, 0, point2);
   
   double price1, price2;
   color channelColor;
   string channelLabel;
   bool isRising = (type == CHANNEL_RISING);
   
   if(isRising)
   {
      price1 = iLow(NULL, 0, point1);
      price2 = iLow(NULL, 0, point2);
      channelColor = RisingChannelColor;
      channelLabel = "Rising Channel (Sell)";
   }
   else // FALLING
   {
      price1 = iHigh(NULL, 0, point1);
      price2 = iHigh(NULL, 0, point2);
      channelColor = FallingChannelColor;
      channelLabel = "Falling Channel (Buy)";
   }
   
   // Calculate channel height
   double channelHeight = CalculateChannelHeight(point1, point2, isRising);
   
   // Calculate optimal extension points
   int extensionBars = MathMin(MaxExtensionBars, MathAbs(point1 - point2) / 2);
   datetime extendedTime1 = time1;
   datetime extendedTime2 = time2;
   
   if(ExtendLeft)
   {
      int extendBack = MathMin(extensionBars, point2);
      extendedTime2 = iTime(NULL, 0, point2 - extendBack);
   }
   
   if(ExtendRight)
   {
      int extendForward = MathMin(extensionBars, Bars(NULL, 0) - point1 - 1);
      extendedTime1 = iTime(NULL, 0, point1 + extendForward);
   }
   
   // Create main base line
   currentChannelName = channelPrefix + "Base";
   ObjectCreate(0, currentChannelName, OBJ_TREND, 0, extendedTime2, price2, time1, price1);
   ObjectSetInteger(0, currentChannelName, OBJPROP_COLOR, channelColor);
   ObjectSetInteger(0, currentChannelName, OBJPROP_WIDTH, ChannelWidth);
   ObjectSetInteger(0, currentChannelName, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, currentChannelName, OBJPROP_RAY_LEFT, ExtendLeft);
   ObjectSetInteger(0, currentChannelName, OBJPROP_BACK, true);
   
   // Create parallel line
   string parallelName = channelPrefix + "Parallel";
   double parallelPrice1 = price1 + (isRising ? channelHeight : -channelHeight);
   double parallelPrice2 = price2 + (isRising ? channelHeight : -channelHeight);
   
   ObjectCreate(0, parallelName, OBJ_TREND, 0, extendedTime2, parallelPrice2, time1, parallelPrice1);
   ObjectSetInteger(0, parallelName, OBJPROP_COLOR, channelColor);
   ObjectSetInteger(0, parallelName, OBJPROP_WIDTH, ChannelWidth);
   ObjectSetInteger(0, parallelName, OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0, parallelName, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, parallelName, OBJPROP_RAY_LEFT, ExtendLeft);
   ObjectSetInteger(0, parallelName, OBJPROP_BACK, true);
   
   // Create label at the most recent point
   string labelName = channelPrefix + "Label";
   ObjectCreate(0, labelName, OBJ_TEXT, 0, time1, isRising ? price1 + channelHeight * 1.1 : price1 - channelHeight * 1.1);
   ObjectSetString(0, labelName, OBJPROP_TEXT, channelLabel);
   ObjectSetInteger(0, labelName, OBJPROP_COLOR, channelColor);
   ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, labelName, OBJPROP_BACK, true);
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if current channel is still valid                        |
//+------------------------------------------------------------------+
bool IsChannelStillValid()
{
   if(!channelFound) return false;
   
   // Check if price has broken the channel significantly
   int recentBars = 10;
   bool isRising = (currentChannelType == CHANNEL_RISING);
   
   for(int i = 0; i < recentBars; i++)
   {
      double high = iHigh(NULL, 0, i);
      double low = iLow(NULL, 0, i);
      
      // For rising channel, check if price has broken above the upper line
      if(isRising)
      {
         // Simplified check - if price has moved significantly outside the channel
         if(low > iLow(NULL, 0, channelStartBar) * 1.01) // 1% above recent low
         {
            return false;
         }
      }
      else // Falling channel
      {
         // Check if price has broken below the lower line
         if(high < iHigh(NULL, 0, channelStartBar) * 0.99) // 1% below recent high
         {
            return false;
         }
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Delete all channels                                              |
//+------------------------------------------------------------------+
void DeleteAllChannels()
{
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, channelPrefix) == 0)
      {
         ObjectDelete(0, name);
      }
   }
   currentChannelName = "";
}

//+------------------------------------------------------------------+
//| Convert period to string                                         |
//+------------------------------------------------------------------+
string PeriodToString(ENUM_TIMEFRAMES period)
{
   switch(period)
   {
      case PERIOD_M1: return "M1";
      case PERIOD_M5: return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1: return "H1";
      case PERIOD_H4: return "H4";
      case PERIOD_D1: return "D1";
      case PERIOD_W1: return "W1";
      case PERIOD_MN1: return "MN1";
      default: return IntegerToString(period);
   }
}