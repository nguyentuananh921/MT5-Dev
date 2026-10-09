//+------------------------------------------------------------------+
//|                                        TestTradingLevelBubble.mq5 |
//| CTradingLevelBubble as a composite: native line/tip/body, CLabel  |
//| texts, CButton X. Two fake levels around the last close (SL Buy   |
//| below, TP Buy above). Check: looks like the canvas bubble, MY     |
//| DEBUG lines on press/release, drag the dashed line left of the    |
//| tip (price + P&L follow), X hides the bubble for 3 s, scroll/zoom |
//| keeps the bubbles on their price                                  |
//+------------------------------------------------------------------+
#property version "2.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Graph\Composite\TradingLevelBubble.mqh>

CTradingLevelBubble g_bubble[2];
double              g_price[2];
double              g_entry;
datetime            g_hidden_until[2];

int PriceToY(const double price)
  {
   int x,y;
   if(!::ChartTimePriceToXY(0,0,::iTime(_Symbol,_Period,0),price,x,y))
      return INT_MIN;
   return y;
  }

int AnchorBX(void)
  {
   int x,y;
   if(!::ChartTimePriceToXY(0,0,::iTime(_Symbol,_Period,0),1.0,x,y))
      return 100;
   return x+BUBBLE_LOOKAHEAD;
  }

void Place(const int i)
  {
   if(::TimeCurrent()<g_hidden_until[i])
      return;
   int y=PriceToY(g_price[i]);
   if(y==INT_MIN)
      return;
   int  half  =BUBBLE_BDY_H/2+2;
   int  hi    =(int)::ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-half;
   bool pinned=(y<half || y>hi);
   y=(y<half ? half : y>hi ? hi : y);
   double pnl  =(g_price[i]-g_entry)*100.0;
   string label=(i==0 ? "SL Buy  " : "TP Buy  ")+::DoubleToString(g_price[i],_Digits);
   g_bubble[i].SetLevel(y,AnchorBX(),pinned,label,(pnl>=0 ? "+" : "")+::DoubleToString(pnl,2)+" $",pnl>=0);
   g_bubble[i].Show();
  }

void PlaceAll(void)
  {
   Place(0);
   Place(1);
   ::ChartRedraw();
  }

int OnInit(void)
  {
   double hi=::iHigh(_Symbol,_Period,::iHighest(_Symbol,_Period,MODE_HIGH,50,0));
   double lo=::iLow(_Symbol,_Period,::iLowest(_Symbol,_Period,MODE_LOW,50,0));
   double r =(hi-lo)/6.0;
   g_entry   =::iClose(_Symbol,_Period,0);
   g_price[0]=g_entry-r;
   g_price[1]=g_entry+r;
   g_hidden_until[0]=0;
   g_hidden_until[1]=0;
   ::ChartSetInteger(0,CHART_SHIFT,true);
   for(int i=0; i<2; i++)
      if(!g_bubble[i].Create(::ChartID(),0,(ENUM_BUBBLE_TYPE)i))
        {
         ::Print("MY DEBUG TestTradingLevelBubble::OnInit: bubble ",i," create failed, error ",::GetLastError());
         return INIT_FAILED;
        }
   PlaceAll();
   ::EventSetMillisecondTimer(500);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   ::EventKillTimer();
  }

void OnTimer(void)
  {
   for(int i=0; i<2; i++)
      if(!g_bubble[i].IsVisible())
         Place(i);
   ::ChartRedraw();
  }

//--- The bubble moved itself; the parent only updates what the bubble cannot know
double PriceAtY(const int y,const int i)
  {
   datetime t; double p; int sub;
   if(::ChartXYToTimePrice(0,AnchorBX(),y,sub,t,p))
      return p;
   return g_price[i];
  }

void OnBubbleEvent(const int event,const int i,const int y)
  {
   double price=PriceAtY(y,i);
   if(event==ON_BUBBLE_MOVE)
     {
      double pnl=(price-g_entry)*100.0;
      g_bubble[i].SetTexts((i==0 ? "SL Buy  " : "TP Buy  ")+::DoubleToString(price,_Digits),(pnl>=0 ? "+" : "")+::DoubleToString(pnl,2)+" $",pnl>=0);
      ::ChartRedraw();
      return;
     }
   ::Print("MY DEBUG TestTradingLevelBubble::OnBubbleEvent: event ",event," bubble ",i," y=",y," price=",::DoubleToString(price,_Digits));
   if(event==ON_BUBBLE_RELEASE)
     {
      g_price[i]=price;
      PlaceAll();
     }
   else if(event==ON_BUBBLE_CLOSE)
     {
      g_hidden_until[i]=::TimeCurrent()+3;
      g_bubble[i].Hide();
      ::ChartRedraw();
     }
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   for(int i=0; i<2; i++)
      g_bubble[i].OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CHART_CHANGE)
      PlaceAll();
   else if(id>=CHARTEVENT_CUSTOM+ON_BUBBLE_PRESS && id<=CHARTEVENT_CUSTOM+ON_BUBBLE_CLOSE)
      OnBubbleEvent(id-CHARTEVENT_CUSTOM,(int)lparam,(int)dparam);
  }

void OnTick(void)
  {
  }
