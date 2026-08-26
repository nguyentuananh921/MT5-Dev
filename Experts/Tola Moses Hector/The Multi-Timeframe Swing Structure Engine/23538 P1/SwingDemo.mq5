//+------------------------------------------------------------------+
//|                                                    SwingDemo.mq5 |
//|     Visual demonstration of CSwingEngine — H4 structure drawn on |
//|                 whatever timeframe this indicator is attached to |
//|                                Copyright 2026, Tola Moses Hector |
//|                                          https://t.me/tolahector |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Tola Moses Hector"
#property link      "https://t.me/tolahector"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

#include "SwingEngine.mqh"

input int              InpStrength = 3;                       // Swing strength — H4 bars on each side
input int              InpLookback = 200;                     // Maximum H4 bars to scan
input ENUM_TIMEFRAMES  InpSwingTF  = PERIOD_H4;               // Timeframe swings are calculated on

CSwingEngine g_engine;
int          g_atr_handle = INVALID_HANDLE;                   // ATR on the swing timeframe — sets label offset

//+------------------------------------------------------------------+
//| Indicator initialization function                                |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!g_engine.Init(InpStrength, InpLookback, InpSwingTF))
      return INIT_FAILED;
   g_atr_handle = iATR(_Symbol, InpSwingTF, 14);              // ATR computed on the SAME TF as swings
   if(g_atr_handle == INVALID_HANDLE)
      return INIT_FAILED;
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Removes all objects drawn by this indicator                      |
//+------------------------------------------------------------------+
void ClearObjects()
  {
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, "SWING_") == 0)
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//| Draws all H4 swing points on the current chart timeframe         |
//+------------------------------------------------------------------+
void DrawSwings()
  {
   ClearObjects();
   double atr_buf[];
   ArraySetAsSeries(atr_buf, true);
   double offset = 0;
   if(CopyBuffer(g_atr_handle, 0, 1, 1, atr_buf) >= 1)
      offset = atr_buf[0] * 0.3;                                             // Label/arrow offset

   int count = g_engine.GetSwingCount();
   for(int i = 0; i < count; i++)
     {
      SSwingPoint sp    = g_engine.GetSwing(i);                              // Get swing (time = H4 bar time)
      string      name  = "SWING_" + IntegerToString(i) + "_" +
                          TimeToString(sp.time, TIME_DATE | TIME_MINUTES);   // Unique name
      bool   is_confirm = (sp.label == "HH" || sp.label == "HL");            // Bright vs dim
      color  clr;
      int    arrow;
      double label_price, arrow_price;
      if(sp.is_high)
        {
         clr         = is_confirm ? C'100,200,255' : C'60,130,180';          // Bright = HH, dim = LH
         arrow       = 218;                                                  // Down arrow
         label_price = sp.price + offset;
         arrow_price = sp.price + offset * 0.4;
        }
      else
        {
         clr         = is_confirm ? C'100,255,120' : C'60,160,80';           // Bright = HL, dim = LL
         arrow       = 217;                                                  // Up arrow
         label_price = sp.price - offset;
         arrow_price = sp.price - offset * 0.4;
        }
      //--- sp.time is an H4 bar time. MetaTrader positions time-anchored
      //--- objects at the correct x-coordinate on ANY chart period, so
      //--- these draw correctly here even though they were computed
      //--- entirely from H4 data.
      ObjectCreate(0, name + "_A", OBJ_ARROW, 0, sp.time, arrow_price);
      ObjectSetInteger(0, name + "_A", OBJPROP_ARROWCODE, arrow);
      ObjectSetInteger(0, name + "_A", OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name + "_A", OBJPROP_WIDTH, 1);
      ObjectCreate(0, name + "_L", OBJ_TEXT, 0, sp.time, label_price);
      ObjectSetString(0,  name + "_L", OBJPROP_TEXT, sp.label);
      ObjectSetInteger(0, name + "_L", OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name + "_L", OBJPROP_FONTSIZE, 8);
     }
//--- Draw trend label
   string label_name = "SWING_TREND_LABEL";
   string trend_str  = g_engine.GetTrendString();
   color  trend_clr  = (g_engine.GetTrend() == TREND_UP)   ? clrLime :
                       (g_engine.GetTrend() == TREND_DOWN)  ? clrRed  : clrGray;
   ObjectCreate(0, label_name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, label_name, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, label_name, OBJPROP_YDISTANCE, 30);
   ObjectSetString(0,  label_name, OBJPROP_TEXT,
                   "H4 Trend: " + trend_str);
   ObjectSetInteger(0, label_name, OBJPROP_COLOR, trend_clr);
   ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, 12);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
//--- Update() is internally gated on a new H4 bar, so calling it on
//--- every OnCalculate() pass—even on a fast chart timeframe—is cheap.
   if(g_engine.Update())
      DrawSwings();
   return rates_total;
  }

//+------------------------------------------------------------------+
//| Indicator deinitialization                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(g_atr_handle);
   ClearObjects();
  }
//+------------------------------------------------------------------+
