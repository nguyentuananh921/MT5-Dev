//+------------------------------------------------------------------+
//|                                              TestBubbleNative.mq5 |
//| One SL-Buy level bubble drawn only with native chart objects:     |
//| dashed trend line to the left, triangle tip, two rectangle labels |
//| for the bordered body, X button, two labels. Drag the level by    |
//| pressing on the dashed line left of the tip and moving the mouse. |
//| Compare the look with CTradingLevelBubble and check scroll/zoom   |
//+------------------------------------------------------------------+
#property version "2.00"

#define BUB_TIP_W      18
#define BUB_BDY_W      155
#define BUB_BDY_H      52
#define BUB_XSZ        18
#define BUB_BDR_W      3
#define BUB_LOOKAHEAD  30
#define BUB_LINE_GRAB  4
#define BUB_CLR_BG     clrWhiteSmoke
#define BUB_CLR_BORDER clrCrimson
#define BUB_CLR_LABEL  clrMediumSeaGreen

#define N_LINE   "TBN_line"
#define N_TIP    "TBN_tip"
#define N_BORDER "TBN_border"
#define N_BODY   "TBN_body"
#define N_X      "TBN_x"
#define N_LABEL  "TBN_label"
#define N_PNL    "TBN_pnl"

double g_price=0.0;
int    g_tip_x=0;          // x of the tip, rebuilt from a bar time on every Place
bool   g_dragging=false;
bool   g_visible=true;
bool   g_scroll_saved=true;

void MakeLabel(const string name,const string text,const color clr)
  {
   ::ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ::ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT);
   ::ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ::ObjectSetInteger(0,name,OBJPROP_FONTSIZE,11);
   ::ObjectSetString(0,name,OBJPROP_FONT,"Calibri Bold");
   ::ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ::ObjectSetString(0,name,OBJPROP_TEXT,text);
  }

void MakeRectLabel(const string name,const color bg,const color border)
  {
   ::ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ::ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ::ObjectSetInteger(0,name,OBJPROP_COLOR,border);
   ::ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ::ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
  }

void Create(void)
  {
   ::ObjectCreate(0,N_LINE,OBJ_TREND,0,0,0,0,0);
   ::ObjectSetInteger(0,N_LINE,OBJPROP_COLOR,BUB_CLR_BORDER);
   ::ObjectSetInteger(0,N_LINE,OBJPROP_STYLE,STYLE_DASH);
   ::ObjectSetInteger(0,N_LINE,OBJPROP_WIDTH,3);
   ::ObjectSetInteger(0,N_LINE,OBJPROP_RAY_LEFT,true);
   ::ObjectSetInteger(0,N_LINE,OBJPROP_RAY_RIGHT,false);
   ::ObjectSetInteger(0,N_LINE,OBJPROP_SELECTABLE,false);
   ::ObjectCreate(0,N_TIP,OBJ_TRIANGLE,0,0,0,0,0,0,0);
   ::ObjectSetInteger(0,N_TIP,OBJPROP_COLOR,BUB_CLR_BORDER);
   ::ObjectSetInteger(0,N_TIP,OBJPROP_FILL,true);
   ::ObjectSetInteger(0,N_TIP,OBJPROP_BACK,false);
   ::ObjectSetInteger(0,N_TIP,OBJPROP_SELECTABLE,false);
   MakeRectLabel(N_BORDER,BUB_CLR_BORDER,BUB_CLR_BORDER);
   MakeRectLabel(N_BODY,BUB_CLR_BG,BUB_CLR_BG);
   ::ObjectCreate(0,N_X,OBJ_BUTTON,0,0,0);
   ::ObjectSetInteger(0,N_X,OBJPROP_BGCOLOR,clrFireBrick);
   ::ObjectSetInteger(0,N_X,OBJPROP_COLOR,clrWhite);
   ::ObjectSetInteger(0,N_X,OBJPROP_BORDER_COLOR,clrFireBrick);
   ::ObjectSetInteger(0,N_X,OBJPROP_XSIZE,BUB_XSZ);
   ::ObjectSetInteger(0,N_X,OBJPROP_YSIZE,BUB_XSZ);
   ::ObjectSetInteger(0,N_X,OBJPROP_FONTSIZE,9);
   ::ObjectSetString(0,N_X,OBJPROP_TEXT,"X");
   ::ObjectSetInteger(0,N_X,OBJPROP_SELECTABLE,false);
   MakeLabel(N_LABEL,"",BUB_CLR_LABEL);
   MakeLabel(N_PNL,"+0.00 $",clrLimeGreen);
  }

int PriceToY(const double price)
  {
   datetime t0=::iTime(_Symbol,_Period,0);
   int x=0,y=0;
   return (::ChartTimePriceToXY(0,0,t0,price,x,y) ? y : -1);
  }

//--- Everything follows one price and one bar-time anchor: tip and line end on the same bar
void Place(void)
  {
   int cy=PriceToY(g_price);
   if(cy<0)
      return;
   int slot=(int)(1<<(int)::ChartGetInteger(0,CHART_SCALE));
   int bars_ahead=(int)::MathMax(1,::MathRound((double)BUB_LOOKAHEAD/slot));
   int body_ahead=(int)::MathMax(1,::MathCeil((double)BUB_TIP_W/slot));
   datetime period=(datetime)::PeriodSeconds();
   datetime t_tip =::iTime(_Symbol,_Period,0)+period*bars_ahead;
   datetime t_body=t_tip+period*body_ahead;
   int body_x=0,y_dummy=0;
   ::ChartTimePriceToXY(0,0,t_tip,g_price,g_tip_x,y_dummy);
   ::ChartTimePriceToXY(0,0,t_body,g_price,body_x,y_dummy);
   //--- price span of half the body height, from the chart scale
   datetime t_tmp=0;
   double p0=0,p1=0;
   int sub=0;
   ::ChartXYToTimePrice(0,body_x,cy,sub,t_tmp,p0);
   ::ChartXYToTimePrice(0,body_x,cy+BUB_BDY_H/2,sub,t_tmp,p1);
   double half_price=::MathAbs(p0-p1);
   //--- dashed line to the left of the tip
   ::ObjectSetInteger(0,N_LINE,OBJPROP_TIME,0,t_tip);
   ::ObjectSetDouble(0,N_LINE,OBJPROP_PRICE,0,g_price);
   ::ObjectSetInteger(0,N_LINE,OBJPROP_TIME,1,t_tip-period*10);
   ::ObjectSetDouble(0,N_LINE,OBJPROP_PRICE,1,g_price);
   //--- tip: apex at the level, base at the body
   ::ObjectSetInteger(0,N_TIP,OBJPROP_TIME,0,t_tip);
   ::ObjectSetDouble(0,N_TIP,OBJPROP_PRICE,0,g_price);
   ::ObjectSetInteger(0,N_TIP,OBJPROP_TIME,1,t_body);
   ::ObjectSetDouble(0,N_TIP,OBJPROP_PRICE,1,g_price+half_price);
   ::ObjectSetInteger(0,N_TIP,OBJPROP_TIME,2,t_body);
   ::ObjectSetDouble(0,N_TIP,OBJPROP_PRICE,2,g_price-half_price);
   //--- bordered body: outer in the border color, inner in the background
   int top=cy-BUB_BDY_H/2;
   ::ObjectSetInteger(0,N_BORDER,OBJPROP_XDISTANCE,body_x);
   ::ObjectSetInteger(0,N_BORDER,OBJPROP_YDISTANCE,top);
   ::ObjectSetInteger(0,N_BORDER,OBJPROP_XSIZE,BUB_BDY_W);
   ::ObjectSetInteger(0,N_BORDER,OBJPROP_YSIZE,BUB_BDY_H);
   ::ObjectSetInteger(0,N_BODY,OBJPROP_XDISTANCE,body_x);
   ::ObjectSetInteger(0,N_BODY,OBJPROP_YDISTANCE,top+BUB_BDR_W);
   ::ObjectSetInteger(0,N_BODY,OBJPROP_XSIZE,BUB_BDY_W-BUB_BDR_W);
   ::ObjectSetInteger(0,N_BODY,OBJPROP_YSIZE,BUB_BDY_H-2*BUB_BDR_W);
   ::ObjectSetInteger(0,N_X,OBJPROP_XDISTANCE,body_x+BUB_BDY_W-BUB_XSZ-4-BUB_BDR_W);
   ::ObjectSetInteger(0,N_X,OBJPROP_YDISTANCE,cy-BUB_XSZ/2);
   ::ObjectSetInteger(0,N_LABEL,OBJPROP_XDISTANCE,body_x+8);
   ::ObjectSetInteger(0,N_LABEL,OBJPROP_YDISTANCE,cy-12);
   ::ObjectSetString(0,N_LABEL,OBJPROP_TEXT,"SL Buy  "+::DoubleToString(g_price,_Digits));
   ::ObjectSetInteger(0,N_PNL,OBJPROP_XDISTANCE,body_x+8);
   ::ObjectSetInteger(0,N_PNL,OBJPROP_YDISTANCE,cy+12);
   ::ChartRedraw();
  }

void SetVisible(const bool visible)
  {
   g_visible=visible;
   string names[7]={N_LINE,N_TIP,N_BORDER,N_BODY,N_X,N_LABEL,N_PNL};
   for(int i=0; i<7; i++)
      ::ObjectSetInteger(0,names[i],OBJPROP_TIMEFRAMES,(visible ? OBJ_ALL_PERIODS : 0));
   ::ChartRedraw();
  }

int OnInit(void)
  {
   ::ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
   int lo=::iLowest(_Symbol,_Period,MODE_LOW,60,1);
   g_price=(lo>=0 ? ::iLow(_Symbol,_Period,lo) : ::SymbolInfoDouble(_Symbol,SYMBOL_BID));
   Create();
   Place();
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   ::ObjectsDeleteAll(0,"TBN_");
   if(g_dragging)
      ::ChartSetInteger(0,CHART_MOUSE_SCROLL,g_scroll_saved);
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE && g_visible)
     {
      Place();
      return;
     }
   if(id==CHARTEVENT_OBJECT_CLICK && sparam==N_X)
     {
      ::ObjectSetInteger(0,N_X,OBJPROP_STATE,false);
      ::Print("MY DEBUG TestBubbleNative::OnChartEvent: X clicked, bubble hidden for 3 s");
      SetVisible(false);
      ::EventSetTimer(3);
      return;
     }
   if(id!=CHARTEVENT_MOUSE_MOVE || !g_visible)
      return;
   int x=(int)lparam;
   int y=(int)dparam;
   bool left=((((int)::StringToInteger(sparam))&1)==1);
   if(!g_dragging)
     {
      int cy=PriceToY(g_price);
      if(left && cy>=0 && x<g_tip_x && ::MathAbs(y-cy)<=BUB_LINE_GRAB)
        {
         g_dragging=true;
         g_scroll_saved=(bool)::ChartGetInteger(0,CHART_MOUSE_SCROLL);
         ::ChartSetInteger(0,CHART_MOUSE_SCROLL,false);
        }
      return;
     }
   if(!left)
     {
      g_dragging=false;
      ::ChartSetInteger(0,CHART_MOUSE_SCROLL,g_scroll_saved);
      ::Print("MY DEBUG TestBubbleNative::OnChartEvent: dropped at ",::DoubleToString(g_price,_Digits));
      return;
     }
   datetime t=0;
   double price=0.0;
   int sub=0;
   if(::ChartXYToTimePrice(0,x,y,sub,t,price))
     {
      g_price=price;
      Place();
     }
  }

void OnTimer(void)
  {
   ::EventKillTimer();
   SetVisible(true);
   Place();
  }

void OnTick(void)
  {
  }
