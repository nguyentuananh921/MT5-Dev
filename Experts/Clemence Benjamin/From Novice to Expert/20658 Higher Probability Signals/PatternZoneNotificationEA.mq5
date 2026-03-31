//+------------------------------------------------------------------+
//|                                  Pattern Zone Notification EA.mq5|
//|                                                Clemence Benjamin |
//|https://www.mql5.com/go?link=https://www.mql5.com/en/users/billionaire2024/seller |
//+------------------------------------------------------------------+

#property copyright "Clemence Benjamin"
#property link      "https://www.mql5.com/go?link=https://www.mql5.com/en/users/billionaire2024/seller"
#property version   "1.00"

// Include the pattern library
#include <infinity_Candlestick_Pattern.mqh>

//--- Input Parameters (EA Settings)
input bool   EnableEmailNotifications = true;    // Enable email notifications
input bool   EnablePushNotifications  = true;    // Enable push notifications
input bool   EnableAlertSounds        = true;    // Enable alert sounds
input bool   EnableOnScreenAlerts     = true;    // Show on-screen alerts
input string AlertSoundFile           = "alert.wav"; // Sound file for alerts
input bool   CheckOnNewBar            = true;    // Check only on new bar
input int    MaxAlertsPerDay          = 10;      // Maximum alerts per day
input bool   DrawPatternArrows        = true;    // Draw arrows on chart
input color  BullishArrowColor        = clrGreen;// Bullish pattern color
input color  BearishArrowColor        = clrRed;  // Bearish pattern color

//--- Input Parameters (Zone Indicator Settings - Must match SRProbabilityZones)
input int    Zone_LookBackPeriod   = 150;    // Bars to analyze
input int    Zone_SwingSensitivity = 5;      // Swing detection (3-10)
input int    Zone_ZonePadding      = 20;     // Zone padding in points
input color  Zone_SupportColor     = clrRoyalBlue;   // Support zone color
input color  Zone_ResistanceColor  = clrCrimson;     // Resistance zone color
input bool   Zone_ShowZoneLabels   = true;   // Show zone labels

//--- Global Variables
datetime lastBarTime = 0;
int alertsToday = 0;
datetime lastAlertDate = 0;
MqlRates rates[];
double highs[], lows[], opens[], closes[];
double atrValues[];
int atrHandle = INVALID_HANDLE;
int zoneIndicatorHandle = INVALID_HANDLE;

// Buffer indices for the zone indicator
#define ZONE_SUPPORT_HIGH_BUFFER 0
#define ZONE_SUPPORT_LOW_BUFFER  1
#define ZONE_RESISTANCE_HIGH_BUFFER 2
#define ZONE_RESISTANCE_LOW_BUFFER  3

//--- Pattern Names Array
string patternNames[24];

//+------------------------------------------------------------------+
//| Simple swing high detection (copied from indicator)             |
//+------------------------------------------------------------------+
bool IsSwingHighSimple(int index, int period, const double& high[])
{
   if(index < period || index >= ArraySize(high)-period)
      return false;
   
   double currentHigh = high[index];
   
   for(int i=1; i<=period; i++)
   {
      if(currentHigh <= high[index-i] || currentHigh <= high[index+i])
         return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Simple swing low detection (copied from indicator)              |
//+------------------------------------------------------------------+
bool IsSwingLowSimple(int index, int period, const double& low[])
{
   if(index < period || index >= ArraySize(low)-period)
      return false;
   
   double currentLow = low[index];
   
   for(int i=1; i<=period; i++)
   {
      if(currentLow >= low[index-i] || currentLow >= low[index+i])
         return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Calculate zones directly in EA (for when indicator not available)|
//+------------------------------------------------------------------+
void CalculateZonesDirectly(double &supportHigh, double &supportLow,
                           double &resistanceHigh, double &resistanceLow)
{
   double supportLevels[], resistanceLevels[];
   ArrayResize(supportLevels, 0);
   ArrayResize(resistanceLevels, 0);
   
   // Get historical data
   int totalBars = Zone_LookBackPeriod + Zone_SwingSensitivity * 2 + 10;
   double highArray[], lowArray[];
   ArraySetAsSeries(highArray, true);
   ArraySetAsSeries(lowArray, true);
   
   if(CopyHigh(_Symbol, _Period, 0, totalBars, highArray) < totalBars ||
      CopyLow(_Symbol, _Period, 0, totalBars, lowArray) < totalBars)
   {
      Print("Failed to copy price data for zone calculation");
      return;
   }
   
   // Find swing points
   int limit = MathMin(Zone_LookBackPeriod, ArraySize(highArray)-Zone_SwingSensitivity);
   for(int i=Zone_SwingSensitivity; i<limit-Zone_SwingSensitivity; i++)
   {
      if(IsSwingLowSimple(i, Zone_SwingSensitivity, lowArray))
      {
         ArrayResize(supportLevels, ArraySize(supportLevels)+1);
         supportLevels[ArraySize(supportLevels)-1] = lowArray[i];
      }
      
      if(IsSwingHighSimple(i, Zone_SwingSensitivity, highArray))
      {
         ArrayResize(resistanceLevels, ArraySize(resistanceLevels)+1);
         resistanceLevels[ArraySize(resistanceLevels)-1] = highArray[i];
      }
   }
   
   // Calculate support zone
   if(ArraySize(supportLevels) > 0)
   {
      supportHigh = 0;
      supportLow = DBL_MAX;
      
      for(int i=0; i<ArraySize(supportLevels); i++)
      {
         if(supportLevels[i] > supportHigh) supportHigh = supportLevels[i];
         if(supportLevels[i] < supportLow) supportLow = supportLevels[i];
      }
      
      double zonePadding = Zone_ZonePadding * _Point;
      supportHigh += zonePadding;
      supportLow -= zonePadding * 2;
   }
   else
   {
      supportHigh = 0;
      supportLow = 0;
   }
   
   // Calculate resistance zone
   if(ArraySize(resistanceLevels) > 0)
   {
      resistanceHigh = 0;
      resistanceLow = DBL_MAX;
      
      for(int i=0; i<ArraySize(resistanceLevels); i++)
      {
         if(resistanceLevels[i] > resistanceHigh) resistanceHigh = resistanceLevels[i];
         if(resistanceLevels[i] < resistanceLow) resistanceLow = resistanceLevels[i];
      }
      
      double zonePadding = Zone_ZonePadding * _Point;
      resistanceHigh += zonePadding * 2;
      resistanceLow -= zonePadding;
   }
   else
   {
      resistanceHigh = 0;
      resistanceLow = 0;
   }
}

//+------------------------------------------------------------------+
//| Initialize pattern names array                                   |
//+------------------------------------------------------------------+
void InitializePatternNames()
{
    patternNames[0] = "Morning Star";
    patternNames[1] = "Evening Star";
    patternNames[2] = "Three White Soldiers";
    patternNames[3] = "Three Black Crows";
    patternNames[4] = "Bullish Harami";
    patternNames[5] = "Bearish Harami";
    patternNames[6] = "Bullish Engulfing";
    patternNames[7] = "Bearish Engulfing";
    patternNames[8] = "Three Inside Up";
    patternNames[9] = "Three Inside Down";
    patternNames[10] = "Tweezer Bottom";
    patternNames[11] = "Tweezer Top";
    patternNames[12] = "Bullish Kicker";
    patternNames[13] = "Bearish Kicker";
    patternNames[14] = "Bullish Breakaway";
    patternNames[15] = "Bearish Breakaway";
    patternNames[16] = "Hammer";
    patternNames[17] = "Shooting Star";
    patternNames[18] = "Standard Doji";
    patternNames[19] = "Dragonfly Doji";
    patternNames[20] = "Gravestone Doji";
    patternNames[21] = "Bullish Marubozu";
    patternNames[22] = "Bearish Marubozu";
    patternNames[23] = "Spinning Top";
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialize pattern names
    InitializePatternNames();
    
    // Initialize ATR indicator
    atrHandle = iATR(_Symbol, _Period, 14);
    if(atrHandle == INVALID_HANDLE)
    {
        Print("Failed to create ATR indicator");
        return(INIT_FAILED);
    }
    
    // Try to create zone indicator handle for testing
    zoneIndicatorHandle = iCustom(_Symbol, _Period, "SRProbabilityZones",
                                  Zone_LookBackPeriod,
                                  Zone_SwingSensitivity,
                                  Zone_ZonePadding,
                                  Zone_SupportColor,
                                  Zone_ResistanceColor,
                                  Zone_ShowZoneLabels);
    
    if(zoneIndicatorHandle == INVALID_HANDLE)
    {
        Print("Note: Could not create SRProbabilityZones indicator handle. Will calculate zones directly.");
    }
    else
    {
        Print("SRProbabilityZones indicator handle created successfully");
    }
    
    // Initialize arrays
    ArraySetAsSeries(rates, true);
    ArraySetAsSeries(highs, true);
    ArraySetAsSeries(lows, true);
    ArraySetAsSeries(opens, true);
    ArraySetAsSeries(closes, true);
    ArraySetAsSeries(atrValues, true);
    
    // Initialize last bar time
    lastBarTime = iTime(_Symbol, _Period, 0);
    if(lastBarTime == 0)
    {
        Print("Failed to get last bar time");
        return(INIT_FAILED);
    }
    
    // Initialize alert date
    lastAlertDate = TimeCurrent();
    
    // Create chart objects for displaying notifications
    if(EnableOnScreenAlerts)
        CreateNotificationPanel();
    
    Print("Pattern Zone Notification EA initialized successfully");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Clean up
    if(atrHandle != INVALID_HANDLE)
        IndicatorRelease(atrHandle);
    
    if(zoneIndicatorHandle != INVALID_HANDLE)
        IndicatorRelease(zoneIndicatorHandle);
    
    RemoveNotificationPanel();
    ObjectsDeleteAll(0, "PatternAlert_");
    ObjectsDeleteAll(0, "OnScreenAlert_");
    
    Print("Pattern Zone Notification EA deinitialized");
}

//+------------------------------------------------------------------+
//| Reset daily alert counter if new day                             |
//+------------------------------------------------------------------+
void CheckDailyReset()
{
    MqlDateTime nowStruct, lastStruct;
    TimeToStruct(TimeCurrent(), nowStruct);
    TimeToStruct(lastAlertDate, lastStruct);
    
    // Check if it's a new day, month, or year
    if(nowStruct.day != lastStruct.day ||
       nowStruct.mon != lastStruct.mon ||
       nowStruct.year != lastStruct.year)
    {
        alertsToday = 0;
        lastAlertDate = TimeCurrent();
        
        // Update counter display
        if(EnableOnScreenAlerts && ObjectFind(0, "AlertCounter") >= 0)
        {
            ObjectSetString(0, "AlertCounter", OBJPROP_TEXT,
                           "Alerts Today: " + IntegerToString(alertsToday));
        }
    }
}

//+------------------------------------------------------------------+
//| Get zone data from multiple sources                             |
//+------------------------------------------------------------------+
bool GetZoneData(double &supportHigh, double &supportLow,
                 double &resistanceHigh, double &resistanceLow)
{
    // First try global variables (if indicator is running on chart)
    if(GlobalVariableCheck("GLOBAL_SUPPORT_HIGH") &&
       GlobalVariableCheck("GLOBAL_SUPPORT_LOW") &&
       GlobalVariableCheck("GLOBAL_RESISTANCE_HIGH") &&
       GlobalVariableCheck("GLOBAL_RESISTANCE_LOW"))
    {
        supportHigh = GlobalVariableGet("GLOBAL_SUPPORT_HIGH");
        supportLow = GlobalVariableGet("GLOBAL_SUPPORT_LOW");
        resistanceHigh = GlobalVariableGet("GLOBAL_RESISTANCE_HIGH");
        resistanceLow = GlobalVariableGet("GLOBAL_RESISTANCE_LOW");
        
        if(supportHigh > 0 && supportLow > 0 && resistanceHigh > 0 && resistanceLow > 0)
        {
            if(EnableOnScreenAlerts && ObjectFind(0, "AlertStatus") >= 0)
                ObjectSetString(0, "AlertStatus", OBJPROP_TEXT, "Status: Using Indicator Globals");
            return true;
        }
    }
    
    // Next try indicator buffers
    if(zoneIndicatorHandle != INVALID_HANDLE)
    {
        double zoneSupportHighBuffer[], zoneSupportLowBuffer[];
        double zoneResistanceHighBuffer[], zoneResistanceLowBuffer[];
        
        ArraySetAsSeries(zoneSupportHighBuffer, true);
        ArraySetAsSeries(zoneSupportLowBuffer, true);
        ArraySetAsSeries(zoneResistanceHighBuffer, true);
        ArraySetAsSeries(zoneResistanceLowBuffer, true);
        
        if(CopyBuffer(zoneIndicatorHandle, ZONE_SUPPORT_HIGH_BUFFER, 0, 1, zoneSupportHighBuffer) > 0 &&
           CopyBuffer(zoneIndicatorHandle, ZONE_SUPPORT_LOW_BUFFER, 0, 1, zoneSupportLowBuffer) > 0 &&
           CopyBuffer(zoneIndicatorHandle, ZONE_RESISTANCE_HIGH_BUFFER, 0, 1, zoneResistanceHighBuffer) > 0 &&
           CopyBuffer(zoneIndicatorHandle, ZONE_RESISTANCE_LOW_BUFFER, 0, 1, zoneResistanceLowBuffer) > 0)
        {
            supportHigh = zoneSupportHighBuffer[0];
            supportLow = zoneSupportLowBuffer[0];
            resistanceHigh = zoneResistanceHighBuffer[0];
            resistanceLow = zoneResistanceLowBuffer[0];
            
            if(supportHigh > 0 && supportLow > 0 && resistanceHigh > 0 && resistanceLow > 0)
            {
                if(EnableOnScreenAlerts && ObjectFind(0, "AlertStatus") >= 0)
                    ObjectSetString(0, "AlertStatus", OBJPROP_TEXT, "Status: Using Indicator Buffers");
                return true;
            }
        }
    }
    
    // Finally, calculate zones directly
    CalculateZonesDirectly(supportHigh, supportLow, resistanceHigh, resistanceLow);
    
    if(supportHigh > 0 && supportLow > 0 && resistanceHigh > 0 && resistanceLow > 0)
    {
        if(EnableOnScreenAlerts && ObjectFind(0, "AlertStatus") >= 0)
            ObjectSetString(0, "AlertStatus", OBJPROP_TEXT, "Status: Using Direct Calculation");
        return true;
    }
    
    // No zone data available
    if(EnableOnScreenAlerts && ObjectFind(0, "AlertStatus") >= 0)
        ObjectSetString(0, "AlertStatus", OBJPROP_TEXT, "Status: No Zone Data");
    
    return false;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check if we should process (new bar or every tick)
    if(CheckOnNewBar)
    {
        datetime currentBarTime = iTime(_Symbol, _Period, 0);
        if(currentBarTime == lastBarTime)
            return;
        lastBarTime = currentBarTime;
    }
    
    CheckDailyReset();
    
    // Check if we've reached daily alert limit
    if(alertsToday >= MaxAlertsPerDay)
    {
        if(EnableOnScreenAlerts && ObjectFind(0, "AlertStatus") >= 0)
            ObjectSetString(0, "AlertStatus", OBJPROP_TEXT, "Status: Daily Limit Reached");
        return;
    }
    
    // Get zone data
    double supportHigh = 0;
    double supportLow = 0;
    double resistanceHigh = 0;
    double resistanceLow = 0;
    
    if(!GetZoneData(supportHigh, supportLow, resistanceHigh, resistanceLow))
    {
        // Zone data not available yet
        return;
    }
    
    // Get latest price data
    int barsToCopy = 20; // Enough for all patterns
    if(CopyRates(_Symbol, _Period, 0, barsToCopy, rates) < barsToCopy)
    {
        Print("Failed to copy rates data");
        return;
    }
    
    // Prepare arrays for pattern detection
    ArrayResize(opens, barsToCopy);
    ArrayResize(highs, barsToCopy);
    ArrayResize(lows, barsToCopy);
    ArrayResize(closes, barsToCopy);
    ArrayResize(atrValues, barsToCopy);
    
    for(int i = 0; i < barsToCopy; i++)
    {
        opens[i] = rates[i].open;
        highs[i] = rates[i].high;
        lows[i] = rates[i].low;
        closes[i] = rates[i].close;
    }
    
    // Get ATR values
    if(CopyBuffer(atrHandle, 0, 0, barsToCopy, atrValues) < barsToCopy)
    {
        Print("Failed to copy ATR data");
        return;
    }
    
    // Check for patterns at current bar (index 0)
    CheckPatternsAtBar(0, supportHigh, supportLow, resistanceHigh, resistanceLow);
    
    // Also check previous bars for recent patterns
    for(int i = 1; i < 3; i++)
    {
        if(i < barsToCopy)
            CheckPatternsAtBar(i, supportHigh, supportLow, resistanceHigh, resistanceLow);
    }
}

//+------------------------------------------------------------------+
//| Create notification panel on chart                               |
//+------------------------------------------------------------------+
void CreateNotificationPanel()
{
    // Create background panel
    ObjectCreate(0, "AlertPanel", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AlertPanel", OBJPROP_XDISTANCE, 10);
    ObjectSetInteger(0, "AlertPanel", OBJPROP_YDISTANCE, 10);
    ObjectSetInteger(0, "AlertPanel", OBJPROP_XSIZE, 300);
    ObjectSetInteger(0, "AlertPanel", OBJPROP_YSIZE, 80);
    ObjectSetInteger(0, "AlertPanel", OBJPROP_BGCOLOR, clrBlack);
    ObjectSetInteger(0, "AlertPanel", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, "AlertPanel", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, "AlertPanel", OBJPROP_BORDER_COLOR, clrGray);
    ObjectSetInteger(0, "AlertPanel", OBJPROP_BACK, false);
    
    // Create title label
    ObjectCreate(0, "AlertTitle", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AlertTitle", OBJPROP_XDISTANCE, 20);
    ObjectSetInteger(0, "AlertTitle", OBJPROP_YDISTANCE, 15);
    ObjectSetInteger(0, "AlertTitle", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetString(0, "AlertTitle", OBJPROP_TEXT, "Pattern Zone Alerts");
    ObjectSetInteger(0, "AlertTitle", OBJPROP_COLOR, clrYellow);
    ObjectSetInteger(0, "AlertTitle", OBJPROP_FONTSIZE, 10);
    ObjectSetInteger(0, "AlertTitle", OBJPROP_BACK, false);
    
    // Create status label
    ObjectCreate(0, "AlertStatus", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AlertStatus", OBJPROP_XDISTANCE, 20);
    ObjectSetInteger(0, "AlertStatus", OBJPROP_YDISTANCE, 40);
    ObjectSetInteger(0, "AlertStatus", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetString(0, "AlertStatus", OBJPROP_TEXT, "Status: Initializing");
    ObjectSetInteger(0, "AlertStatus", OBJPROP_COLOR, clrLime);
    ObjectSetInteger(0, "AlertStatus", OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, "AlertStatus", OBJPROP_BACK, false);
    
    // Create alert counter label
    ObjectCreate(0, "AlertCounter", OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AlertCounter", OBJPROP_XDISTANCE, 20);
    ObjectSetInteger(0, "AlertCounter", OBJPROP_YDISTANCE, 60);
    ObjectSetInteger(0, "AlertCounter", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetString(0, "AlertCounter", OBJPROP_TEXT, "Alerts Today: 0");
    ObjectSetInteger(0, "AlertCounter", OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, "AlertCounter", OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, "AlertCounter", OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
//| Remove notification panel                                        |
//+------------------------------------------------------------------+
void RemoveNotificationPanel()
{
    ObjectDelete(0, "AlertPanel");
    ObjectDelete(0, "AlertTitle");
    ObjectDelete(0, "AlertStatus");
    ObjectDelete(0, "AlertCounter");
}

//+------------------------------------------------------------------+
//| Show on-screen notification                                      |
//+------------------------------------------------------------------+
void ShowOnScreenNotification(string message, bool isBullish)
{
    string labelName = "OnScreenAlert_" + IntegerToString(GetTickCount());
    
    // Create temporary label
    ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, 50);
    ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, 120);
    ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetString(0, labelName, OBJPROP_TEXT, message);
    ObjectSetInteger(0, labelName, OBJPROP_COLOR, isBullish ? clrLime : clrRed);
    ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, labelName, OBJPROP_BACK, false);
    
    // Schedule removal after 10 seconds
    EventSetTimer(10);
}

//+------------------------------------------------------------------+
//| Draw pattern arrow on chart                                      |
//+------------------------------------------------------------------+
void DrawPatternArrow(datetime time, double price, bool isBullish, string patternName)
{
    string arrowName = "PatternAlert_" + TimeToString(time);
    
    // Delete existing arrow if any
    if(ObjectFind(0, arrowName) >= 0)
        ObjectDelete(0, arrowName);
    
    // Create arrow
    if(isBullish)
    {
        ObjectCreate(0, arrowName, OBJ_ARROW_BUY, 0, time, price - 50 * _Point);
        ObjectSetInteger(0, arrowName, OBJPROP_COLOR, BullishArrowColor);
        ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 3);
    }
    else
    {
        ObjectCreate(0, arrowName, OBJ_ARROW_SELL, 0, time, price + 50 * _Point);
        ObjectSetInteger(0, arrowName, OBJPROP_COLOR, BearishArrowColor);
        ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 3);
    }
    
    // Set arrow properties
    ObjectSetInteger(0, arrowName, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
    ObjectSetInteger(0, arrowName, OBJPROP_BACK, false);
    
    // Add text label
    string labelName = arrowName + "_Label";
    ObjectCreate(0, labelName, OBJ_TEXT, 0, time, isBullish ? price - 100 * _Point : price + 100 * _Point);
    ObjectSetString(0, labelName, OBJPROP_TEXT, patternName);
    ObjectSetInteger(0, labelName, OBJPROP_COLOR, isBullish ? BullishArrowColor : BearishArrowColor);
    ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, labelName, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
//| Send alert through all enabled methods                           |
//+------------------------------------------------------------------+
void SendAlert(string message, datetime time, double price, string zone, bool isBullish)
{
    // Check daily limit
    if(alertsToday >= MaxAlertsPerDay)
        return;
    
    string fullMessage = StringFormat("%s - %s at %s Price: %.5f", 
        _Symbol, message, TimeToString(time), price);
    
    // Terminal Alert
    Alert(fullMessage);
    
    // On-screen notification
    if(EnableOnScreenAlerts)
        ShowOnScreenNotification(fullMessage, isBullish);
    
    // Sound alert
    if(EnableAlertSounds && FileIsExist(AlertSoundFile, 0))
        PlaySound(AlertSoundFile);
    
    // Email notification
    if(EnableEmailNotifications)
        SendMail("Pattern Alert: " + _Symbol, fullMessage);
    
    // Push notification
    if(EnablePushNotifications)
        SendNotification(fullMessage);
    
    // Increment alert counter
    alertsToday++;
    lastAlertDate = TimeCurrent();
    
    // Update counter display
    if(EnableOnScreenAlerts && ObjectFind(0, "AlertCounter") >= 0)
        ObjectSetString(0, "AlertCounter", OBJPROP_TEXT, "Alerts Today: " + IntegerToString(alertsToday));
    
    // Log to experts journal
    Print(fullMessage);
}

//+------------------------------------------------------------------+
//| Check bullish patterns                                           |
//+------------------------------------------------------------------+
void CheckBullishPatterns(int index, datetime patternTime, double price, string zoneType)
{
    string patternDetected = "";
    
    // Check if we already have an arrow for this bar
    string arrowName = "PatternAlert_" + TimeToString(patternTime);
    if(ObjectFind(0, arrowName) >= 0)
        return; // Already alerted for this bar
    
    // Multi-candle bullish patterns
    if(IsMorningStar(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[0];
    else if(IsThreeWhiteSoldiers(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[2];
    else if(IsBullishHarami(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[4];
    else if(IsBullishEngulfing(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[6];
    else if(IsThreeInsideUp(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[8];
    else if(IsTweezerBottom(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[10];
    else if(IsBullishKicker(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[12];
    else if(IsBullishBreakaway(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[14];
    
    // Single candle bullish patterns
    else if(IsHammer(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[16];
    else if(IsDragonflyDoji(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[19];
    else if(IsBullishMarubozu(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[21];
    
    if(patternDetected != "")
    {
        SendAlert(patternDetected + " detected in " + zoneType, 
                  patternTime, price, zoneType, true);
        
        if(DrawPatternArrows)
            DrawPatternArrow(patternTime, price, true, patternDetected);
    }
}

//+------------------------------------------------------------------+
//| Check bearish patterns                                           |
//+------------------------------------------------------------------+
void CheckBearishPatterns(int index, datetime patternTime, double price, string zoneType)
{
    string patternDetected = "";
    
    // Check if we already have an arrow for this bar
    string arrowName = "PatternAlert_" + TimeToString(patternTime);
    if(ObjectFind(0, arrowName) >= 0)
        return; // Already alerted for this bar
    
    // Multi-candle bearish patterns
    if(IsEveningStar(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[1];
    else if(IsThreeBlackCrows(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[3];
    else if(IsBearishHarami(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[5];
    else if(IsBearishEngulfing(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[7];
    else if(IsThreeInsideDown(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[9];
    else if(IsTweezerTop(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[11];
    else if(IsBearishKicker(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[13];
    else if(IsBearishBreakaway(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[15];
    
    // Single candle bearish patterns
    else if(IsShootingStar(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[17];
    else if(IsGravestoneDoji(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[20];
    else if(IsBearishMarubozu(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[22];
    else if(IsSpinningTop(opens, highs, lows, closes, atrValues, index))
        patternDetected = patternNames[23];
    
    if(patternDetected != "")
    {
        SendAlert(patternDetected + " detected in " + zoneType, 
                  patternTime, price, zoneType, false);
        
        if(DrawPatternArrows)
            DrawPatternArrow(patternTime, price, false, patternDetected);
    }
}

//+------------------------------------------------------------------+
//| Check patterns at specific bar index                             |
//+------------------------------------------------------------------+
void CheckPatternsAtBar(int index, double supHigh, double supLow, double resHigh, double resLow)
{
    // Get current candle's close price
    double currentPrice = closes[index];
    datetime patternTime = rates[index].time;
    
    // Check if price is in support zone
    bool inSupportZone = (currentPrice >= supLow && currentPrice <= supHigh);
    
    // Check if price is in resistance zone
    bool inResistanceZone = (currentPrice >= resLow && currentPrice <= resHigh);
    
    if(!inSupportZone && !inResistanceZone)
        return;
    
    // Check for bullish patterns in support zone
    if(inSupportZone)
    {
        CheckBullishPatterns(index, patternTime, currentPrice, "Support Zone");
    }
    
    // Check for bearish patterns in resistance zone
    if(inResistanceZone)
    {
        CheckBearishPatterns(index, patternTime, currentPrice, "Resistance Zone");
    }
}

//+------------------------------------------------------------------+
//| Timer function to remove temporary alerts                        |
//+------------------------------------------------------------------+
void OnTimer()
{
    // Remove temporary alert labels
    for(int i = ObjectsTotal(0) - 1; i >= 0; i--)
    {
        string name = ObjectName(0, i);
        if(StringFind(name, "OnScreenAlert_") >= 0)
            ObjectDelete(0, name);
    }
}

//+------------------------------------------------------------------+