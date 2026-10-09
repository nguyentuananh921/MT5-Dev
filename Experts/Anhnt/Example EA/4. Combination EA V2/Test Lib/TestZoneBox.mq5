//+------------------------------------------------------------------+
//|                                                  TestZoneBox.mq5 |
//| Native OBJ_RECTANGLE zones through CZoneBox : CGBaseObj:      |
//| open-ended Supply, closed Demand, hollow Resistance. Check:      |
//| scroll/zoom follow with no lag, child CTooltip on hover          |
//+------------------------------------------------------------------+
#property version "2.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Graph\Composite\ZoneBox.mqh>

CZoneBox g_box[3];

//--- Exercises the Properties package pulled from V1: sizes, current/previous copy, read back
void TestProperties(void)
  {
   CProperties *p=new CProperties(GRAPH_OBJ_PROP_INTEGER_TOTAL,GRAPH_OBJ_PROP_DOUBLE_TOTAL,GRAPH_OBJ_PROP_STRING_TOTAL);
   if(p==NULL)
     {
      ::Print("MY DEBUG TestZoneBox::TestProperties: new CProperties failed");
      return;
     }
   p.SetSizeRange(GRAPH_OBJ_PROP_TIME,2);
   p.SetSizeRange(GRAPH_OBJ_PROP_PRICE,2);
   datetime t0=::iTime(_Symbol,_Period,40);
   p.Curr.SetLong(GRAPH_OBJ_PROP_FILL,0,1);
   p.Curr.SetLong(GRAPH_OBJ_PROP_TIME,0,(long)t0);
   p.Curr.SetLong(GRAPH_OBJ_PROP_TIME,1,(long)::iTime(_Symbol,_Period,0));
   p.Curr.SetDouble(GRAPH_OBJ_PROP_PRICE,0,1.2345);
   p.Curr.SetDouble(GRAPH_OBJ_PROP_PRICE,1,1.1111);
   p.Curr.SetString(GRAPH_OBJ_PROP_NAME,0,"TestZoneBox");
   p.CurrentToPrevious();
   p.Curr.SetDouble(GRAPH_OBJ_PROP_PRICE,0,2.5);
   ::Print("MY DEBUG TestZoneBox::TestProperties: sizes TIME=",p.CurrSize(GRAPH_OBJ_PROP_TIME)," PRICE=",p.CurrSize(GRAPH_OBJ_PROP_PRICE),
           " fill=",p.Curr.GetLong(GRAPH_OBJ_PROP_FILL,0),
           " time0 ok=",(p.Curr.GetLong(GRAPH_OBJ_PROP_TIME,0)==(long)t0),
           " price0 curr=",p.Curr.GetDouble(GRAPH_OBJ_PROP_PRICE,0)," prev=",p.Prev.GetDouble(GRAPH_OBJ_PROP_PRICE,0),
           " price1 curr=",p.Curr.GetDouble(GRAPH_OBJ_PROP_PRICE,1)," name=",p.Curr.GetString(GRAPH_OBJ_PROP_NAME,0));
   delete p;
  }

//--- What the terminal really holds for each box (read back from the chart object)
void DumpBoxes(const long chart_id)
  {
   for(int i=0; i<3; i++)
     {
      string n=g_box[i].Name();
      ::Print("MY DEBUG TestZoneBox::DumpBoxes: ",n," exists=",(::ObjectFind(chart_id,n)>=0),
              " color=",::ColorToString((color)::ObjectGetInteger(chart_id,n,OBJPROP_COLOR),true),
              " fill=",::ObjectGetInteger(chart_id,n,OBJPROP_FILL)," back=",::ObjectGetInteger(chart_id,n,OBJPROP_BACK),
              " ray_right=",::ObjectGetInteger(chart_id,n,OBJPROP_RAY_RIGHT),
              " tf=",::ObjectGetInteger(chart_id,n,OBJPROP_TIMEFRAMES),
              " t0=",::TimeToString((datetime)::ObjectGetInteger(chart_id,n,OBJPROP_TIME,0))," p0=",::ObjectGetDouble(chart_id,n,OBJPROP_PRICE,0),
              " t1=",::TimeToString((datetime)::ObjectGetInteger(chart_id,n,OBJPROP_TIME,1))," p1=",::ObjectGetDouble(chart_id,n,OBJPROP_PRICE,1));
     }
   ::Print("MY DEBUG TestZoneBox::DumpBoxes: chart price max=",::ChartGetDouble(chart_id,CHART_PRICE_MAX)," min=",::ChartGetDouble(chart_id,CHART_PRICE_MIN),
           " first visible bar=",::ChartGetInteger(chart_id,CHART_FIRST_VISIBLE_BAR));
  }

int OnInit(void)
  {
   TestProperties();
   const long chart_id=::ChartID();
   int hi_i=::iHighest(_Symbol,_Period,MODE_HIGH,60,1);
   int lo_i=::iLowest(_Symbol,_Period,MODE_LOW,60,1);
   if(hi_i<0 || lo_i<0)
      return INIT_FAILED;
   double hi=::iHigh(_Symbol,_Period,hi_i);
   double lo=::iLow(_Symbol,_Period,lo_i);
   double range=hi-lo;
   if(range<=0.0)
      return INIT_FAILED;

   string names[3]={"TestZoneBox_Supply","TestZoneBox_Demand","TestZoneBox_Resistance"};
   for(int i=0; i<3; i++)
      if(!g_box[i].Create(chart_id,0,names[i]))
        {
         ::Print("MY DEBUG TestZoneBox::OnInit: CZoneBox.Create failed #",i," error ",::GetLastError());
         return INIT_FAILED;
        }

   g_box[0].SetZone(hi,hi-range*0.10,::iTime(_Symbol,_Period,40),0,"Supply",SIGNAL_SELL);
   g_box[0].SetZoneStyle(clrRed,70,true,1);
   g_box[0].SetInfo("Supply | SELL | open to the right | test");

   g_box[1].SetZone(lo+range*0.10,lo,::iTime(_Symbol,_Period,50),::iTime(_Symbol,_Period,10),"Demand",SIGNAL_BUY);
   g_box[1].SetZoneStyle(clrLimeGreen,70,true,1);
   g_box[1].SetInfo("Demand | BUY | closed on the right | test");

   g_box[2].SetZone(lo+range*0.62,lo+range*0.52,::iTime(_Symbol,_Period,80),0,"Resistance",SIGNAL_SELL);
   g_box[2].SetZoneStyle(clrDodgerBlue,255,false,1);
   g_box[2].SetInfo("Resistance | hollow | open to the right | test");

   DumpBoxes(chart_id);
   ::EventSetMillisecondTimer(TIMER_STEP_MSC);
   ::ChartRedraw(chart_id);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   ::EventKillTimer();
  }

void OnTimer(void)
  {
   for(int i=0; i<3; i++)
      g_box[i].OnTimerEvent();
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   for(int i=0; i<3; i++)
      g_box[i].OnChartEvent(id,lparam,dparam,sparam);
  }

void OnTick(void)
  {
  }
