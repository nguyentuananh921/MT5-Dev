//+------------------------------------------------------------------+
//|                                      RSI Price Action Panel.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd.|
//|                          https://www.mql5.com/en/users/lynnchris|
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   0

//--- Inputs --------------------------------------------------------
input int      InpRSIPeriod      = 14;
input double   InpOverbought     = 70.0;
input double   InpOversold       = 30.0;
input bool     InpUseAsk         = false;
input int      InpTimeOffsetSec  = 90;
input string   InpFontName       = "Segoe UI";
input int      InpFontSize       = 9;
input bool     InpShowAlerts     = true;
input bool     InpLogToExperts   = true;

//--- Panel appearance ----------------------------------------------
input color   InpPanelBgColor    = clrDarkSlateGray;
input color   InpBorderColor     = clrGoldenrod;
input int     InpPanelWidth      = 290;
input int     InpPanelHeight     = 36;

//--- Global objects ------------------------------------------------
string g_PanelName   = "RSI_Panel";
string g_ArrowName   = "RSI_ArrowChar";
string g_TextValue   = "RSI_Val";
string g_TextState   = "RSI_State";
string g_TextSignal  = "RSI_Signal";

int    g_RSIHandle   = INVALID_HANDLE;
double g_PrevRSI     = EMPTY_VALUE;
bool   g_AlertOB     = false;
bool   g_AlertOS     = false;

//+------------------------------------------------------------------+
//| Get signal classification                                        |
//+------------------------------------------------------------------+
string GetSignalClassification(double rsi,double prevRSI,bool isOB,bool isOS,color &textColor)
  {
   double slope = (prevRSI != EMPTY_VALUE) ? (rsi - prevRSI) : 0;
   string signal = "";

   if(isOB)
     {
      if(rsi >= 80)
         signal = "‼ EXTREME SELL";
      else
         if(slope < -1.5)
            signal = "▼▼ STRONG SELL";
         else
            if(slope > 0)
               signal = "▼ WEAK SELL";
            else
               signal = "▼ SELL";
      textColor = clrOrangeRed;
     }
   else
      if(isOS)
        {
         if(rsi <= 20)
            signal = "‼ EXTREME BUY";
         else
            if(slope > 1.5)
               signal = "▲▲ STRONG BUY";
            else
               if(slope < 0)
                  signal = "▲ WEAK BUY";
               else
                  signal = "▲ BUY";
         textColor = clrDodgerBlue;
        }
      else
        {
         signal = "●";
         textColor = clrSilver;
        }

   return signal;
  }

//+------------------------------------------------------------------+
//| Get state string with an icon                                    |
//+------------------------------------------------------------------+
string GetStateIconAndText(double rsi)
  {
   if(rsi >= InpOverbought)
      return "🔻 OVERBOUGHT";
   if(rsi <= InpOversold)
      return "🔺 OVERSOLD";
   return "⚫ NEUTRAL";
  }

//+------------------------------------------------------------------+
//| Update a text label                                              |
//+------------------------------------------------------------------+
void UpdateLabel(string name,int x,int y,string text,color clr,int fontSize=-1)
  {
   if(fontSize == -1)
      fontSize = InpFontSize;

   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      return;

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,InpFontName);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//| Clamp panel position to stay inside chart window                 |
//+------------------------------------------------------------------+
void ClampPanelPosition(int &panelX,int &panelY,int &arrowX,int &arrowY,int priceX,int priceY)
  {
   int chartWidth  = (int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int chartHeight = (int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);

//--- Clamp panel
   if(panelX + InpPanelWidth > chartWidth)
      panelX = chartWidth - InpPanelWidth - 5;
   if(panelX < 5)
      panelX = 5;

   if(panelY < 5)
      panelY = 5;
   if(panelY + InpPanelHeight > chartHeight - 5)
      panelY = chartHeight - InpPanelHeight - 5;

//--- Clamp arrow
   arrowX = priceX - 45;
   if(arrowX < 5)
      arrowX = 5;
   arrowY = priceY - 2;
   if(arrowY < 5)
      arrowY = 5;
   if(arrowY > chartHeight - 20)
      arrowY = chartHeight - 20;
  }

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_RSIHandle = iRSI(_Symbol,PERIOD_CURRENT,InpRSIPeriod,PRICE_CLOSE);
   if(g_RSIHandle == INVALID_HANDLE)
      return(INIT_FAILED);

//--- Panel rectangle
   if(!ObjectCreate(0,g_PanelName,OBJ_RECTANGLE_LABEL,0,0,0))
      return(INIT_FAILED);
   ObjectSetInteger(0,g_PanelName,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,g_PanelName,OBJPROP_BACK,false);
   ObjectSetInteger(0,g_PanelName,OBJPROP_ZORDER,100);
   ObjectSetInteger(0,g_PanelName,OBJPROP_XSIZE,InpPanelWidth);
   ObjectSetInteger(0,g_PanelName,OBJPROP_YSIZE,InpPanelHeight);
   ObjectSetInteger(0,g_PanelName,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,g_PanelName,OBJPROP_BORDER_COLOR,InpBorderColor);
   ObjectSetInteger(0,g_PanelName,OBJPROP_BGCOLOR,InpPanelBgColor);
   ObjectSetInteger(0,g_PanelName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,g_PanelName,OBJPROP_HIDDEN,true);

//--- Arrow
   if(!ObjectCreate(0,g_ArrowName,OBJ_TEXT,0,0,0))
      return(INIT_FAILED);
   ObjectSetString(0,g_ArrowName,OBJPROP_TEXT,"◄");
   ObjectSetString(0,g_ArrowName,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,g_ArrowName,OBJPROP_FONTSIZE,14);
   ObjectSetInteger(0,g_ArrowName,OBJPROP_COLOR,clrYellow);
   ObjectSetInteger(0,g_ArrowName,OBJPROP_ANCHOR,ANCHOR_RIGHT);
   ObjectSetInteger(0,g_ArrowName,OBJPROP_BACK,false);
   ObjectSetInteger(0,g_ArrowName,OBJPROP_ZORDER,99);
   ObjectSetInteger(0,g_ArrowName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,g_ArrowName,OBJPROP_HIDDEN,true);

//--- Pre-create text segments
   UpdateLabel(g_TextValue,  0,0,"",clrWhite);
   UpdateLabel(g_TextState,  0,0,"",clrWhite);
   UpdateLabel(g_TextSignal, 0,0,"",clrWhite);

   Print("RSI Composite Sticker – panel always fully visible");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_RSIHandle != INVALID_HANDLE)
      IndicatorRelease(g_RSIHandle);
   ObjectDelete(0,g_PanelName);
   ObjectDelete(0,g_ArrowName);
   ObjectDelete(0,g_TextValue);
   ObjectDelete(0,g_TextState);
   ObjectDelete(0,g_TextSignal);
  }

//+------------------------------------------------------------------+
//| OnCalculate                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],
                const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],
                const long &volume[],const int &spread[])
  {
   double rsiBuf[1];

//--- Get RSI value
   if(CopyBuffer(g_RSIHandle,0,0,1,rsiBuf)!=1)
      return(rates_total);
   double rsi = rsiBuf[0];
   if(rsi<=0 || rsi>100)
      return(rates_total);

//--- Get current price
   double price = InpUseAsk ? SymbolInfoDouble(_Symbol,SYMBOL_ASK) : SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(price<=0)
      return(rates_total);

//--- Determine state & signal
   bool isOB = (rsi >= InpOverbought);
   bool isOS = (rsi <= InpOversold);
   string stateIconText = GetStateIconAndText(rsi);
   color stateColor = isOB ? clrOrangeRed : (isOS ? clrDodgerBlue : clrSilver);
   color signalColor;
   string signal = GetSignalClassification(rsi,g_PrevRSI,isOB,isOS,signalColor);

//--- Chart coordinates for price point
   datetime lastTime = time[rates_total-1];
   datetime anchorTime = lastTime + InpTimeOffsetSec;
   int priceX, priceY;
   if(!ChartTimePriceToXY(0,0,anchorTime,price,priceX,priceY))
      return(rates_total);

//--- Initial positions
   int arrowX = priceX - 45;
   int arrowY = priceY - 2;
   int panelX = priceX + 20;
   int panelY = priceY - (InpPanelHeight/2);

//--- Clamp both to ensure panel stays fully visible
   ClampPanelPosition(panelX,panelY,arrowX,arrowY,priceX,priceY);

//--- Apply positions
   ObjectSetInteger(0,g_ArrowName,OBJPROP_XDISTANCE,arrowX);
   ObjectSetInteger(0,g_ArrowName,OBJPROP_YDISTANCE,arrowY);
   ObjectSetInteger(0,g_PanelName,OBJPROP_XDISTANCE,panelX);
   ObjectSetInteger(0,g_PanelName,OBJPROP_YDISTANCE,panelY);

//--- Update text labels inside panel
   int colRSI    = 8;
   int colState  = 85;
   int colSignal = 185;
   int textY = (InpPanelHeight - InpFontSize)/2;

   UpdateLabel(g_TextValue,  panelX + colRSI,   panelY + textY,StringFormat("RSI: %.1f",rsi),clrWhite,InpFontSize);
   UpdateLabel(g_TextState,  panelX + colState, panelY + textY,stateIconText,stateColor,InpFontSize);
   UpdateLabel(g_TextSignal, panelX + colSignal,panelY + textY,signal,signalColor,InpFontSize);

//--- Alerts
   if(g_PrevRSI != EMPTY_VALUE && InpShowAlerts)
     {
      if(g_PrevRSI < InpOverbought && rsi >= InpOverbought && !g_AlertOB)
        {
         string msg = StringFormat("%s → OVERBOUGHT (RSI=%.1f) %s",_Symbol,rsi,signal);
         Alert(msg);
         if(InpLogToExperts)
            Print(msg);
         g_AlertOB = true;
         g_AlertOS = false;
        }
      else
         if(g_PrevRSI > InpOversold && rsi <= InpOversold && !g_AlertOS)
           {
            string msg = StringFormat("%s → OVERSOLD (RSI=%.1f) %s",_Symbol,rsi,signal);
            Alert(msg);
            if(InpLogToExperts)
               Print(msg);
            g_AlertOS = true;
            g_AlertOB = false;
           }

      if(rsi > InpOversold && rsi < InpOverbought)
         g_AlertOB = g_AlertOS = false;
     }

//--- Store previous RSI
   g_PrevRSI = rsi;

   ChartRedraw();
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
