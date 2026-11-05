//+------------------------------------------------------------------+
//| Smart Money Concepts BOS CHoCH                   XPro by Xander  |
//| Version 1.0  |  2026-10-25  |  MetaTrader 5                      |
//| Developer: Cristhian Gaibor (Xander)                             |
//| Profile:   https://www.mql5.com/en/users/09151993a               |
//+------------------------------------------------------------------+
// XPro by Xander. Tested code, compiles clean and runs on demo and
// live accounts as it is. Built from more than 10 years of trading
// and coding experience, so you can use it today or take it as the
// base for your own EA or indicator. You will find more tools like
// this one on my profile. If something is not clear, ask in the
// comments and I will answer. Results depend on your settings, your
// broker and your risk management, so test your configuration first.
// Provided as is, use at your own risk.
// Updates and new tools first on my MQL5 channel:
// https://www.mql5.com/en/channels/xander
//+------------------------------------------------------------------+
// CHANGELOG
// v1.0 - 2026-10-25 - Initial release
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Cristhian Gaibor (Xander)"
#property link        "https://www.mql5.com/en/users/09151993a"
#property version     "1.00"
#property description "XPro by Xander. Tested code, compiles clean, ready for demo and live accounts."
#property description "Use it as it is or as the base for your own EA or indicator. 10+ years of experience behind it."
#property description "More tools on my profile. Updates first on my MQL5 channel: mql5.com/en/channels/xander"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

#property indicator_label1  "BOS Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_width1  1

#property indicator_label2  "BOS Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrOrangeRed
#property indicator_width2  1

#property indicator_label3  "CHoCH Up"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDodgerBlue
#property indicator_width3  2

#property indicator_label4  "CHoCH Down"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrOrangeRed
#property indicator_width4  2

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string sep0            = "★ Smart Money Concepts BOS CHoCH";    // ══ XPro by Xander ══
input string sep1            = "══════ STRUCTURE ══════";            // ─────────────────────
input int    InpSwingLength  = 5;        // Swing length: bars on each side of a swing high/low
input int    InpMaxBars      = 1500;     // Bars to analyze from the right (0 = all)

input string sep2            = "══════ DISPLAY ══════";              // ─────────────────────
input bool   InpShowBOS      = true;     // Draw BOS (break of structure) lines
input bool   InpShowCHoCH    = true;     // Draw CHoCH (change of character) lines
input bool   InpShowSwings   = true;     // Label swings as HH, HL, LH, LL
input bool   InpShowArrows   = false;    // Show arrow buffers on the chart (always available for EAs)
input color  InpBullColor    = clrDodgerBlue;  // Bullish color
input color  InpBearColor    = clrOrangeRed;   // Bearish color
input color  InpSwingColor   = clrGray;        // Swing label color
input int    InpLineWidth    = 1;        // Line width
input ENUM_LINE_STYLE InpBOSStyle   = STYLE_DOT;   // BOS line style
input ENUM_LINE_STYLE InpCHoCHStyle = STYLE_SOLID; // CHoCH line style
input int    InpFontSize     = 8;        // Label font size

input string sep3            = "══════ ALERTS ══════";               // ─────────────────────
input bool   InpAlertPopup   = false;    // Pop-up alert on new BOS / CHoCH
input bool   InpAlertPush    = false;    // Push notification on new BOS / CHoCH
input bool   InpAlertSound   = false;    // Sound on new BOS / CHoCH
input string InpAlertSoundFile = "alert.wav"; // Sound file

input string sep4            = "══════ INDICATOR SETTINGS ══════";   // ─────────────────────
input string InpPrefix       = "XP_SMC_"; // Object prefix (change it to run two copies)

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
#define XP_NAME "Smart Money Concepts BOS CHoCH"

double XP_BosUp[];
double XP_BosDown[];
double XP_ChochUp[];
double XP_ChochDown[];

// market structure state, rebuilt from scratch whenever prev_calculated is 0
int    XP_trend;          // 1 bullish, -1 bearish, 0 undefined
double XP_lastHigh;       // last confirmed swing high price
int    XP_lastHighBar;    // its bar index
bool   XP_highBroken;     // already broken by a close
double XP_lastLow;
int    XP_lastLowBar;
bool   XP_lowBroken;
double XP_prevHigh;       // previous swing high, to label HH / LH
double XP_prevLow;        // previous swing low, to label HL / LL

//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpSwingLength<1)
     {
      Print("[", XP_NAME, "] Swing length must be 1 or more.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   SetIndexBuffer(0,XP_BosUp,INDICATOR_DATA);
   SetIndexBuffer(1,XP_BosDown,INDICATOR_DATA);
   SetIndexBuffer(2,XP_ChochUp,INDICATOR_DATA);
   SetIndexBuffer(3,XP_ChochDown,INDICATOR_DATA);

   for(int p=0;p<4;p++)
     {
      PlotIndexSetDouble(p,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      PlotIndexSetInteger(p,PLOT_ARROW,(p<2 ? 159 : 108));
      if(!InpShowArrows) PlotIndexSetInteger(p,PLOT_DRAW_TYPE,DRAW_NONE);
     }
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,InpBullColor);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,InpBearColor);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,InpBullColor);
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,InpBearColor);
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,10);
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,-10);

   IndicatorSetString(INDICATOR_SHORTNAME,XP_NAME+" ("+IntegerToString(InpSwingLength)+")");
   XP_ResetState();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinit: remove only our objects                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,InpPrefix);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| State reset                                                      |
//+------------------------------------------------------------------+
void XP_ResetState()
  {
   XP_trend=0;
   XP_lastHigh=0.0;  XP_lastHighBar=-1; XP_highBroken=true;
   XP_lastLow=0.0;   XP_lastLowBar=-1;  XP_lowBroken=true;
   XP_prevHigh=0.0;  XP_prevLow=0.0;
  }

//+------------------------------------------------------------------+
//| Calculation                                                      |
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
   int n=InpSwingLength;
   if(rates_total<2*n+2) return(0);

   int start;
   if(prev_calculated<=0)
     {
      ArrayInitialize(XP_BosUp,EMPTY_VALUE);
      ArrayInitialize(XP_BosDown,EMPTY_VALUE);
      ArrayInitialize(XP_ChochUp,EMPTY_VALUE);
      ArrayInitialize(XP_ChochDown,EMPTY_VALUE);
      ObjectsDeleteAll(0,InpPrefix);
      XP_ResetState();
      start=2*n;
      if(InpMaxBars>0 && rates_total-InpMaxBars>start) start=rates_total-InpMaxBars;
     }
   else
     {
      start=prev_calculated-1;
      for(int i=start;i<rates_total;i++)
        {
         XP_BosUp[i]=EMPTY_VALUE; XP_BosDown[i]=EMPTY_VALUE;
         XP_ChochUp[i]=EMPTY_VALUE; XP_ChochDown[i]=EMPTY_VALUE;
        }
     }

   // only closed bars are processed, the forming bar never paints anything
   for(int i=start;i<rates_total-1;i++)
     {
      XP_ConfirmSwings(i,n,time,high,low);
      XP_CheckBreaks(i,rates_total,time,high,low,close,prev_calculated>0);
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| A swing at bar c = i - n is confirmed once n bars closed after it |
//+------------------------------------------------------------------+
void XP_ConfirmSwings(const int i,const int n,const datetime &time[],const double &high[],const double &low[])
  {
   int c=i-n;
   if(c-n<0) return;

   bool isHigh=true, isLow=true;
   for(int k=1;k<=n && (isHigh || isLow);k++)
     {
      if(high[c]<=high[c-k] || high[c]<=high[c+k]) isHigh=false;
      if(low[c]>=low[c-k]   || low[c]>=low[c+k])   isLow=false;
     }

   if(isHigh)
     {
      if(InpShowSwings && XP_prevHigh>0.0)
         XP_DrawSwingLabel(time[c],high[c],(high[c]>XP_prevHigh ? "HH" : "LH"),true);
      XP_prevHigh=high[c];
      XP_lastHigh=high[c];
      XP_lastHighBar=c;
      XP_highBroken=false;
     }
   if(isLow)
     {
      if(InpShowSwings && XP_prevLow>0.0)
         XP_DrawSwingLabel(time[c],low[c],(low[c]<XP_prevLow ? "LL" : "HL"),false);
      XP_prevLow=low[c];
      XP_lastLow=low[c];
      XP_lastLowBar=c;
      XP_lowBroken=false;
     }
  }

//+------------------------------------------------------------------+
//| Close above the last swing high or below the last swing low      |
//| Same direction as the trend = BOS, against it = CHoCH            |
//+------------------------------------------------------------------+
void XP_CheckBreaks(const int i,const int rates_total,const datetime &time[],const double &high[],
                    const double &low[],const double &close[],const bool live)
  {
   bool isLastClosed=(i==rates_total-2);

   if(!XP_highBroken && XP_lastHigh>0.0 && close[i]>XP_lastHigh)
     {
      bool choch=(XP_trend==-1);
      XP_highBroken=true;
      XP_trend=1;
      if(choch)
        {
         XP_ChochUp[i]=low[i];
         if(InpShowCHoCH) XP_DrawBreak(time[XP_lastHighBar],time[i],XP_lastHigh,"CHoCH",true,InpCHoCHStyle);
        }
      else
        {
         XP_BosUp[i]=low[i];
         if(InpShowBOS) XP_DrawBreak(time[XP_lastHighBar],time[i],XP_lastHigh,"BOS",true,InpBOSStyle);
        }
      if(live && isLastClosed) XP_Alert((choch ? "Bullish CHoCH" : "Bullish BOS"),XP_lastHigh);
     }

   if(!XP_lowBroken && XP_lastLow>0.0 && close[i]<XP_lastLow)
     {
      bool choch=(XP_trend==1);
      XP_lowBroken=true;
      XP_trend=-1;
      if(choch)
        {
         XP_ChochDown[i]=high[i];
         if(InpShowCHoCH) XP_DrawBreak(time[XP_lastLowBar],time[i],XP_lastLow,"CHoCH",false,InpCHoCHStyle);
        }
      else
        {
         XP_BosDown[i]=high[i];
         if(InpShowBOS) XP_DrawBreak(time[XP_lastLowBar],time[i],XP_lastLow,"BOS",false,InpBOSStyle);
        }
      if(live && isLastClosed) XP_Alert((choch ? "Bearish CHoCH" : "Bearish BOS"),XP_lastLow);
     }
  }

//+------------------------------------------------------------------+
//| Drawing: a horizontal segment from the swing to the break bar    |
//| plus a plain text label in the middle. No canvas, basic objects. |
//+------------------------------------------------------------------+
void XP_DrawBreak(const datetime t1,const datetime t2,const double price,const string tag,
                  const bool bullish,const ENUM_LINE_STYLE style)
  {
   color  clr=(bullish ? InpBullColor : InpBearColor);
   string id=InpPrefix+tag+(bullish ? "_U_" : "_D_")+IntegerToString((long)t2);

   string ln=id+"_L";
   if(ObjectFind(0,ln)<0)
     {
      ObjectCreate(0,ln,OBJ_TREND,0,t1,price,t2,price);
      ObjectSetInteger(0,ln,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,ln,OBJPROP_STYLE,style);
      ObjectSetInteger(0,ln,OBJPROP_WIDTH,InpLineWidth);
      ObjectSetInteger(0,ln,OBJPROP_RAY_RIGHT,false);
      ObjectSetInteger(0,ln,OBJPROP_RAY_LEFT,false);
      ObjectSetInteger(0,ln,OBJPROP_BACK,true);
      ObjectSetInteger(0,ln,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,ln,OBJPROP_HIDDEN,true);
     }

   string tx=id+"_T";
   datetime mid=t1+(t2-t1)/2;
   if(ObjectFind(0,tx)<0)
     {
      ObjectCreate(0,tx,OBJ_TEXT,0,mid,price);
      ObjectSetString(0,tx,OBJPROP_TEXT,tag);
      ObjectSetString(0,tx,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,tx,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetInteger(0,tx,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,tx,OBJPROP_ANCHOR,(bullish ? ANCHOR_LOWER : ANCHOR_UPPER));
      ObjectSetInteger(0,tx,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,tx,OBJPROP_HIDDEN,true);
     }
  }

//+------------------------------------------------------------------+
//| Swing label (HH, HL, LH, LL)                                     |
//+------------------------------------------------------------------+
void XP_DrawSwingLabel(const datetime t,const double price,const string tag,const bool isHigh)
  {
   string id=InpPrefix+"SW_"+IntegerToString((long)t);
   if(ObjectFind(0,id)>=0) return;
   ObjectCreate(0,id,OBJ_TEXT,0,t,price);
   ObjectSetString(0,id,OBJPROP_TEXT,tag);
   ObjectSetString(0,id,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,id,OBJPROP_FONTSIZE,InpFontSize);
   ObjectSetInteger(0,id,OBJPROP_COLOR,InpSwingColor);
   ObjectSetInteger(0,id,OBJPROP_ANCHOR,(isHigh ? ANCHOR_LOWER : ANCHOR_UPPER));
   ObjectSetInteger(0,id,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,id,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//| Alerts, only for the bar that just closed                        |
//+------------------------------------------------------------------+
void XP_Alert(const string what,const double level)
  {
   if(!InpAlertPopup && !InpAlertPush && !InpAlertSound) return;
   string msg=StringFormat("[%s] %s %s: %s at %s",XP_NAME,_Symbol,EnumToString(_Period),what,
                           DoubleToString(level,_Digits));
   if(InpAlertPopup) Alert(msg);
   if(InpAlertPush)  SendNotification(msg);
   if(InpAlertSound) PlaySound(InpAlertSoundFile);
  }
//+------------------------------------------------------------------+
