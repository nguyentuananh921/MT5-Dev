//+------------------------------------------------------------------+
//|                                 Test_GraphElementsCollection.mq5 |
//| Isolated test: does CGraphElementsCollection compile inside an   |
//| EA, and can it drive Wingdings OBJ_ARROW / OBJ_TEXT markers the  |
//| way SignalMarkers.mq5 plots them today (V11 CChartGraphicEngine) |
//+------------------------------------------------------------------+
#property copyright "Anhnt"
#property version   "1.00"
#property strict

#include <Vendors\Anhnt\Library\4. Combination Lib\Collections\GraphElementsCollection.mqh>

input int    InpMarkers        = 300;    // markers to create (one per bar, newest first)
input uchar  InpBuyArrowCode   = 233;    // Wingdings: arrow up
input uchar  InpSellArrowCode  = 234;    // Wingdings: arrow down
input color  InpBuyColor       = clrDodgerBlue;
input color  InpSellColor      = clrOrangeRed;
input color  InpOtherTFColor   = clrGray;
input int    InpTimerMs        = 1000;   // Refresh() only watches for user-drawn/deleted objects - no need for 250ms
input bool   InpBatchCreate    = true;   // SetRedrawOnAdd(false) during the bulk loop, one ChartRedraw at the end

CGraphElementsCollection g_graph;
string                   g_prefix;      // MQL_PROGRAM_NAME + "_" - what the collection prepends to every name
int                      g_created = 0;
int                      g_failed  = 0;
//+------------------------------------------------------------------+
//| Create one marker through the collection and color it            |
//+------------------------------------------------------------------+
bool CreateMarker(const string name, const datetime time, const double price, const bool is_buy, const color clr)
  {
   uchar code = is_buy ? InpBuyArrowCode : InpSellArrowCode;
   ENUM_ARROW_ANCHOR anchor = is_buy ? ANCHOR_TOP : ANCHOR_BOTTOM;
   if(!g_graph.CreateArrow(::ChartID(), name, 0, false, time, price, code, anchor))
      return false;
   CGStdGraphObj *obj = g_graph.GetStdGraphObject(g_prefix + name, ::ChartID());
   if(obj == NULL) return false;
   obj.SetColor(clr);
   obj.SetFlagSelectable(false, false);
   return true;
  }
//+------------------------------------------------------------------+
int OnInit()
  {
   g_prefix = ::MQLInfoString(MQL_PROGRAM_NAME) + "_";
   int charts = g_graph.CreateChartControlList();
   Print(__FUNCTION__, ": chart control objects = ", charts, ", prefix='", g_prefix, "'");
   //--- Baseline: what is already on the chart BEFORE we add anything (GUI panels etc. when run next to the real EA)
   Print(__FUNCTION__, ": chart objects before = ", ::ObjectsTotal(::ChartID()));

   ulong t0 = ::GetMicrosecondCount();
   g_graph.SetRedrawOnAdd(!InpBatchCreate);
   int bars = MathMin(InpMarkers, ::Bars(_Symbol, _Period));
   for(int i = 1; i <= bars; i++)
     {
      datetime t   = ::iTime(_Symbol, _Period, i);
      bool     buy = (i % 2 == 0);
      double   p   = buy ? ::iLow(_Symbol, _Period, i) : ::iHigh(_Symbol, _Period, i);
      color    clr = (i % 7 == 0) ? InpOtherTFColor : (buy ? InpBuyColor : InpSellColor);
      string   nm  = "MK_" + (string)(long)t + "_" + (buy ? "B" : "S");
      if(CreateMarker(nm, t, p, buy, clr)) g_created++; else g_failed++;
      //--- Every 25th bar also gets a structure label, like the Swing HH/LH/HL/LL ones
      if(i % 25 == 0)
        {
         string lbl = "LB_" + (string)(long)t;
         if(g_graph.CreateText(::ChartID(), lbl, 0, false, t, ::iHigh(_Symbol, _Period, i), buy ? "HH" : "LL", 8, ANCHOR_LOWER, 0.0))
           {
            CGStdGraphObj *o = g_graph.GetStdGraphObject(g_prefix + lbl, ::ChartID());
            if(o != NULL) { o.SetColor(clr); o.SetFlagSelectable(false, false); }
            g_created++;
           }
         else g_failed++;
        }
     }
   g_graph.SetRedrawOnAdd(true);
   ::ChartRedraw();
   ulong dt = ::GetMicrosecondCount() - t0;
   Print(__FUNCTION__, ": created=", g_created, " failed=", g_failed, " in ", dt / 1000, " ms (batch=", InpBatchCreate,
         "); collection list=", g_graph.GetListGraphObj().Total(), " chart objects now=", ::ObjectsTotal(::ChartID()));
   ::EventSetMillisecondTimer(InpTimerMs);
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ::EventKillTimer();
   //--- Our objects all carry the program prefix - one call cleans the chart, then the collection itself
   int n = ::ObjectsDeleteAll(::ChartID(), g_prefix);
   g_graph.OnDeinit();
   Print(__FUNCTION__, ": deleted ", n, " objects, reason=", reason);
  }
//+------------------------------------------------------------------+
void OnTick() {}
//+------------------------------------------------------------------+
void OnTimer()
  {
   ulong t0 = ::GetMicrosecondCount();
   g_graph.Refresh();
   ulong dt = ::GetMicrosecondCount() - t0;
   //--- Report only when something changed on the chart, plus a slow-scan warning
   if(g_graph.IsEvent())
      Print(__FUNCTION__, ": Refresh saw ", g_graph.NewObjects(), " new object(s), list=", g_graph.GetListGraphObj().Total(), ", ", dt, " us");
   else if(dt > 2000)
      Print(__FUNCTION__, ": Refresh took ", dt, " us with ", ::ObjectsTotal(::ChartID()), " objects on chart");
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   g_graph.OnChartEvent(id, lparam, dparam, sparam);
   //--- What the collection reports back about user interaction with our (or any) object
   if(id == CHARTEVENT_OBJECT_DRAG || id == CHARTEVENT_OBJECT_CLICK || id == CHARTEVENT_OBJECT_DELETE)
      Print(__FUNCTION__, ": id=", id, " obj='", sparam, "'");
  }
//+------------------------------------------------------------------+
