//+------------------------------------------------------------------+
//|                         Market Structure Swing Map MT5.mq5       |
//|                         Copyright 2026, Shahrukh                  |
//|                         https://www.mql5.com                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Shahrukh"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Confirmed swing structure map with HH, HL, LH and LL labels."
#property indicator_chart_window
#property indicator_plots 0
#property indicator_buffers 0

input group "Swing Detection"
input int              InpSwingStrength      = 3;       // Bars on each side
input int              InpMaximumBars        = 500;     // Maximum bars to scan
input bool             InpShowSwingPrice     = false;   // Add price to labels

input group "Visual Style"
input bool             InpShowStructureLine  = true;    // Connect confirmed swings
input color            InpBullishColor       = clrLimeGreen;
input color            InpBearishColor       = clrTomato;
input color            InpNeutralColor       = clrDarkGray;
input color            InpStructureLineColor = clrSlateGray;
input ENUM_LINE_STYLE  InpStructureLineStyle = STYLE_DOT;
input int              InpFontSize           = 9;

input group "Alerts"
input bool             InpEnableAlerts       = false;

string   g_prefix="MSSM_";
datetime g_last_bar=0;
datetime g_last_alert_time=0;

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpSwingStrength<1 || InpMaximumBars<20)
     {
      Print("Invalid settings: SwingStrength must be >= 1 and MaximumBars >= 20.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   IndicatorSetString(INDICATOR_SHORTNAME,"Market Structure Swing Map");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,g_prefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
bool IsSwingHigh(const double &high[],const int index,const int strength,const int rates_total)
  {
   if(index-strength<0 || index+strength>=rates_total)
      return(false);

   const double value=high[index];
   for(int offset=1; offset<=strength; offset++)
     {
      if(value<=high[index-offset] || value<high[index+offset])
         return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
bool IsSwingLow(const double &low[],const int index,const int strength,const int rates_total)
  {
   if(index-strength<0 || index+strength>=rates_total)
      return(false);

   const double value=low[index];
   for(int offset=1; offset<=strength; offset++)
     {
      if(value>=low[index-offset] || value>low[index+offset])
         return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
void DrawLabel(const string name,const datetime when,const double price,
               const string structure,const bool is_high)
  {
   if(!ObjectCreate(0,name,OBJ_TEXT,0,when,price))
      return;

   string text=structure;
   if(InpShowSwingPrice)
      text+=StringFormat("  %.*f",_Digits,price);

   color label_color=InpNeutralColor;
   if(structure=="HH" || structure=="HL") label_color=InpBullishColor;
   if(structure=="LH" || structure=="LL") label_color=InpBearishColor;

   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,InpFontSize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,label_color);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,is_high ? ANCHOR_LOWER : ANCHOR_UPPER);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
void DrawStructureLine(const string name,const datetime time1,const double price1,
                       const datetime time2,const double price2)
  {
   if(!InpShowStructureLine || time1==0)
      return;
   if(!ObjectCreate(0,name,OBJ_TREND,0,time1,price1,time2,price2))
      return;

   ObjectSetInteger(0,name,OBJPROP_COLOR,InpStructureLineColor);
   ObjectSetInteger(0,name,OBJPROP_STYLE,InpStructureLineStyle);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
void BuildStructure(const int rates_total,const datetime &time[],
                    const double &high[],const double &low[])
  {
   ObjectsDeleteAll(0,g_prefix);

   const int oldest=MathMin(InpMaximumBars,rates_total-InpSwingStrength-1);
   double last_high=0.0,last_low=0.0;
   datetime previous_time=0;
   double previous_price=0.0;
   int sequence=0;
   string newest_structure="";
   datetime newest_structure_time=0;

   for(int index=oldest; index>=InpSwingStrength; index--)
     {
      const bool swing_high=IsSwingHigh(high,index,InpSwingStrength,rates_total);
      const bool swing_low =IsSwingLow(low,index,InpSwingStrength,rates_total);

      // An outside bar can technically satisfy both tests. Keep the more
      // significant side relative to the previous confirmed structure point.
      bool use_high=swing_high;
      bool use_low=swing_low;
      if(swing_high && swing_low && previous_time!=0)
        {
         const double high_distance=MathAbs(high[index]-previous_price);
         const double low_distance =MathAbs(low[index]-previous_price);
         use_high=(high_distance>=low_distance);
         use_low=!use_high;
        }

      if(use_high)
        {
         string structure=(last_high==0.0 ? "SH" : (high[index]>last_high ? "HH" : "LH"));
         string id=IntegerToString(sequence++);
         DrawLabel(g_prefix+"LABEL_"+id,time[index],high[index],structure,true);
         DrawStructureLine(g_prefix+"LINE_"+id,previous_time,previous_price,time[index],high[index]);
         previous_time=time[index];
         previous_price=high[index];
         last_high=high[index];
         newest_structure=structure;
         newest_structure_time=time[index];
        }
      else if(use_low)
        {
         string structure=(last_low==0.0 ? "SL" : (low[index]>last_low ? "HL" : "LL"));
         string id=IntegerToString(sequence++);
         DrawLabel(g_prefix+"LABEL_"+id,time[index],low[index],structure,false);
         DrawStructureLine(g_prefix+"LINE_"+id,previous_time,previous_price,time[index],low[index]);
         previous_time=time[index];
         previous_price=low[index];
         last_low=low[index];
         newest_structure=structure;
         newest_structure_time=time[index];
        }
     }

   if(InpEnableAlerts && newest_structure_time>g_last_alert_time &&
      newest_structure_time>0 && g_last_alert_time>0)
     {
      Alert(_Symbol," ",EnumToString(_Period)," confirmed structure: ",newest_structure);
     }
   if(newest_structure_time>0)
      g_last_alert_time=newest_structure_time;

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],
                const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],
                const long &volume[],const int &spread[])
  {
   const int required=InpSwingStrength*2+10;
   if(rates_total<required)
      return(0);

   if(time[0]!=g_last_bar || prev_calculated==0)
     {
      g_last_bar=time[0];
      BuildStructure(rates_total,time,high,low);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
