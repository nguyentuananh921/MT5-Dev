//+------------------------------------------------------------------+
//|                             MarketStructureIndicator.mq5         |
//|                             Copyright 2026, MetaQuotes           |
//|                             https://www.mql5.com                 |
//|Link                        https://www.mql5.com/en/articles/23049|
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

//--- plot SwingHigh
#property indicator_label1  "Swing High"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- plot SwingLow
#property indicator_label2  "Swing Low"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- plot ProtectedHigh (invisible – for EA consumption)
#property indicator_label3  "Protected High"
#property indicator_type3   DRAW_NONE

//--- plot ProtectedLow (invisible – for EA consumption)
#property indicator_label4  "Protected Low"
#property indicator_type4   DRAW_NONE

#include "MarketStructureFramework\MarketStructureFramework.mqh"

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input int               InpInternalSwingStrength = 5;                 // internal swing detection strength (bars)
input int               InpExternalSwingStrength = 8;                 // external swing detection strength (bars)
input ENUM_TIMEFRAMES   InpExternalTimeframe = PERIOD_H4;             // higher timeframe for external structure
input int               InpExternalHistoryBars = 500;                 // number of external bars to keep
input int               InpMaxSwingHistory = 1000;                    // maximum bars to scan for swings
input ENUM_STRUCTURE_LEVEL InpStateMachineSource = LEVEL_EXTERNAL;    // which structure drives the market state
input bool              InpEnablePersistence = false;                 // enable CSV event logging
input int               InpPersistenceFlushInterval = 10;             // events per file flush
input bool              InpShowObjects = true;                        // display chart objects (arrows, label)
input int               InpStateLabelYOffset = 40;                    // vertical pixel offset for state label

CMarketStructureFramework *gFramework = NULL;                         // main framework instance
double         SwingHighBuffer[];                                     // buffer for swing high arrows
double         SwingLowBuffer[];                                      // buffer for swing low arrows
double         ProtectedHighBuffer[];                                 // buffer for protected high (for EA access)
double         ProtectedLowBuffer[];                                  // buffer for protected low (for EA access)

//+------------------------------------------------------------------+
//| Object tracking helper                                           |
//+------------------------------------------------------------------+
string         g_objList[];                                           // list of chart object names created by this indicator
int            g_objCount = 0;                                        // current number of tracked objects

//+------------------------------------------------------------------+
//| Add a chart object name to the tracking list                     |
//+------------------------------------------------------------------+
void ObjListAdd(string name)
  {
   if(ObjectFind(0, name) < 0)
      return;                                                         // object doesn't exist yet
   for(int i=0; i<g_objCount; i++)
      if(g_objList[i] == name)
         return;                                                      // already tracked
   g_objCount++;
   ArrayResize(g_objList, g_objCount);
   g_objList[g_objCount-1] = name;                                    // append to list
  }
//+------------------------------------------------------------------+
//| Remove a chart object name from the tracking list and delete it  |
//+------------------------------------------------------------------+
void ObjListRemove(string name)
  {
   ObjectDelete(0, name);                                             // remove from chart
   for(int i=0; i<g_objCount; i++)
     {
      if(g_objList[i] == name)
        {
         //--- shift remaining names down
         for(int j=i; j<g_objCount-1; j++)
            g_objList[j] = g_objList[j+1];
         g_objCount--;
         ArrayResize(g_objList, g_objCount);
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Clear all tracked chart objects and reset the tracking list      |
//+------------------------------------------------------------------+
void ObjListClear()
  {
   for(int i=0; i<g_objCount; i++)
      ObjectDelete(0, g_objList[i]);                                  // delete every tracked object
   g_objCount = 0;
   ArrayFree(g_objList);
  }

//+------------------------------------------------------------------+
//| Indicator functions                                              |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- bind buffers to plots
   SetIndexBuffer(0, SwingHighBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SwingLowBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ProtectedHighBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, ProtectedLowBuffer, INDICATOR_DATA);

   //--- set arrow symbol (159 = Wingdings up/down depending on direction)
   PlotIndexSetInteger(0, PLOT_ARROW, 159);
   PlotIndexSetInteger(1, PLOT_ARROW, 159);
   //--- define empty (invisible) values
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   //--- create and initialise the framework
   gFramework = new CMarketStructureFramework();
   if(!gFramework.Init(InpInternalSwingStrength, InpExternalSwingStrength,
                       InpExternalTimeframe, InpEnablePersistence,
                       _Symbol, _Period, InpExternalHistoryBars,
                       InpMaxSwingHistory, InpStateMachineSource,
                       InpPersistenceFlushInterval))
     {
      Print("[MarketStructure] Init failed, status: ", EnumToString(gFramework.GetStatus()));
      delete gFramework;
      gFramework=NULL;
      return INIT_FAILED;
     }

   g_objCount = 0;
   ArrayFree(g_objList);                                             // start with empty object tracker
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Indicator deinitialization – release framework and clear objects |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(gFramework)
     {
      gFramework.OnDeinit();                                          // close files, release handles
      delete gFramework;
      gFramework = NULL;
     }
   ObjListClear();                                                    // remove all chart objects
   Comment("");                                                       // clear any previous comment
  }

//+------------------------------------------------------------------+
//| Indicator calculation entry point – fills buffers and manages    |
//| chart objects                                                    |
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
   if(!gFramework)
      return 0;
   //--- skip if no new bar has formed (framework is bar-close driven)
   if(prev_calculated > 0 && rates_total == prev_calculated)
      return rates_total;

   //--- ensure price arrays are in series order (0 = newest)
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   //--- let the framework process the new bar(s)
   gFramework.OnCalculate(time, high, low, close, rates_total);

   //--- clear all buffers before repopulating
   ArrayInitialize(SwingHighBuffer, EMPTY_VALUE);
   ArrayInitialize(SwingLowBuffer, EMPTY_VALUE);
   ArrayInitialize(ProtectedHighBuffer, EMPTY_VALUE);
   ArrayInitialize(ProtectedLowBuffer, EMPTY_VALUE);

   //--- fill internal swing high arrows (using time-to-barIndex conversion)
   int highCount = gFramework.GetSwingCount(true, LEVEL_INTERNAL);
   for(int i=0; i<highCount; i++)
     {
      SSwingPoint pt;
      if(gFramework.GetSwingPoint(true, LEVEL_INTERNAL, i, pt))
        {
         int seriesIdx = iBarShift(_Symbol, _Period, pt.time);        // series index (0 = newest)
         if(seriesIdx >= 0)
           {
            int barIdx = rates_total - 1 - seriesIdx;                 // non-series index for buffer
            if(barIdx >= 0 && barIdx < rates_total)
               SwingHighBuffer[barIdx] = high[seriesIdx];
           }
        }
     }
   //--- fill internal swing low arrows
   int lowCount = gFramework.GetSwingCount(false, LEVEL_INTERNAL);
   for(int i=0; i<lowCount; i++)
     {
      SSwingPoint pt;
      if(gFramework.GetSwingPoint(false, LEVEL_INTERNAL, i, pt))
        {
         int seriesIdx = iBarShift(_Symbol, _Period, pt.time);
         if(seriesIdx >= 0)
           {
            int barIdx = rates_total - 1 - seriesIdx;
            if(barIdx >= 0 && barIdx < rates_total)
               SwingLowBuffer[barIdx] = low[seriesIdx];
           }
        }
     }

   //--- fill protected level buffers (most recent value at index 0)
   double protHighPrice=0, protLowPrice=0;
   if(gFramework.GetProtectedLevels(protHighPrice, protLowPrice))
     {
      ProtectedHighBuffer[0] = protHighPrice;                           // EA can read this with iCustom(..., 2, 0)
      ProtectedLowBuffer[0] = protLowPrice;
     }

   //--- draw chart objects if enabled
   if(InpShowObjects)
     {
      string prefix = "MSF_"+_Symbol+"_"+IntegerToString(_Period)+"_";  // unique prefix for this chart

      //--- BOS arrow (external)
      string bosName = prefix + "BOS_Main";
      SStructureEvent bos;
      bool hasBOS = gFramework.GetLastBOS(bos, LEVEL_EXTERNAL);
      if(hasBOS)
        {
         if(ObjectFind(0, bosName) < 0)
           {
            ObjectCreate(0, bosName, OBJ_ARROW, 0, bos.time, bos.price);
            ObjListAdd(bosName);
           }
         ObjectSetInteger(0, bosName, OBJPROP_TIME, bos.time);
         ObjectSetDouble(0, bosName, OBJPROP_PRICE, bos.price);
         ObjectSetInteger(0, bosName, OBJPROP_ARROWCODE, (bos.direction==1)?233:234);   // 233 up, 234 down
         ObjectSetInteger(0, bosName, OBJPROP_COLOR, (bos.direction==1)?clrLime:clrRed);
         ObjectSetInteger(0, bosName, OBJPROP_WIDTH, 2);
        }
      else
         if(ObjectFind(0, bosName) >= 0)
            ObjListRemove(bosName);                                                     // no BOS event, remove old arrow

      //--- CHoCH arrow (external)
      string chochName = prefix + "CHoCH_Main";
      SStructureEvent choch;
      bool hasCHoCH = gFramework.GetLastCHoCH(choch, LEVEL_EXTERNAL);
      if(hasCHoCH)
        {
         if(ObjectFind(0, chochName) < 0)
           {
            ObjectCreate(0, chochName, OBJ_ARROW, 0, choch.time, choch.price);
            ObjListAdd(chochName);
           }
         ObjectSetInteger(0, chochName, OBJPROP_TIME, choch.time);
         ObjectSetDouble(0, chochName, OBJPROP_PRICE, choch.price);
         ObjectSetInteger(0, chochName, OBJPROP_ARROWCODE, (choch.direction==1)?233:234);
         ObjectSetInteger(0, chochName, OBJPROP_COLOR, (choch.direction==1)?clrBlue:clrMagenta);
         ObjectSetInteger(0, chochName, OBJPROP_WIDTH, 3);
        }
      else
         if(ObjectFind(0, chochName) >= 0)
            ObjListRemove(chochName);

      //--- Market state label
      string labelName = prefix + "StateLabel";
      ENUM_MARKET_STATE state = gFramework.GetCurrentState();
      string stateText="UNKNOWN";
      switch(state)
        {
         case STATE_BULLISH:
            stateText="BULLISH";
            break;
         case STATE_BEARISH:
            stateText="BEARISH";
            break;
         case STATE_TRANSITION:
            stateText="TRANSITION";
            break;
         case STATE_RANGE:
            stateText="RANGE";
            break;
        }
      if(ObjectFind(0, labelName) < 0)
        {
         ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);                           // create label at (0,0), positioned via offsets
         ObjListAdd(labelName);
        }
      ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, 10);                       // pixels from left edge
      ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, InpStateLabelYOffset);     // pixels from top
      ObjectSetString(0, labelName, OBJPROP_TEXT, "Market State: " + stateText);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrBlue);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 12);
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
