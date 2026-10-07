//+------------------------------------------------------------------+
//|                                              CandleMarkerSync.mqh |
//+------------------------------------------------------------------+
#ifndef __CANDLEMARKERSYNC_MQH__
#define __CANDLEMARKERSYNC_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\BarTimeSeriesCollection.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\IndicatorsCollection.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\SignalsCollection.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\GraphElementsCollection.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Indicators\IndicatorDE.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\BarPatternsControl\BarPatternsControl.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\SwingSetting.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Graph\Composite\CandleMarker.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Graph\Composite\StructureBreakLine.mqh>
 #include "MarkerSetting.mqh"
 #include "IndicatorTemplateManager.mqh"   // CIndicatorTemplateManager - EA-owned, read LIVE (no copy needed)
 #include "SymbolTFManager.mqh"            // CSymbolTFManager - EA-owned, read LIVE (no copy needed)
#ifndef CCANDLEMARKERSYNC_MQH_DECLARATION
#define CCANDLEMARKERSYNC_MQH_DECLARATION
 #define CANDLE_MARKER_NAME        "CandleMarker_"   // + candle time + side
 #define STRUCTURE_LINE_NAME       "StructureLine_"  // + break candle time + type
 //+------------------------------------------------------------------+
 //| One CCandleMarker per candle and side (blue below a Buy candle,  |
 //| red above a Sell one) of the chart's Symbol + Timeframe that has |
 //| an Indicator signal, a candle Pattern, a Swing, a BOS or a CHoCH.|
 //| The marker is the sum of its sources (its icon); the details are |
 //| in the candle information window. Markers are children of the    |
 //| graph elements collection and hold the facts themselves.         |
 //| Each source keeps a watermark (the newest time it has read) and  |
 //| Sync() only reads past it. A change of the Buy/Sell gates or of  |
 //| the Swing setting restarts everything (Sync(true)). Every BOS   |
 //| and CHoCH of an element shown in the Smart Money table also     |
 //| gets its CStructureBreakLine (children of the same collection)  |
 //+------------------------------------------------------------------+
 class CCandleMarkerSync
  {
   private:
     CSignalsCollection        *m_SignalsCollection;         // CTimeSeriesEngine owns
     CIndicatorsCollection     *m_IndicatorsCollection;      // CTimeSeriesEngine owns
     CBarTimeSeriesCollection  *m_BarTimeSeriesCollection;   // CTimeSeriesEngine owns
     CBarPatternsControl       *m_patterns_control;          // CTimeSeriesEngine owns
     CSwingSetting             *m_SwingSetting;              // CTimeSeriesEngine owns
     CIndicatorTemplateManager *m_indicator_template_manager;   // EA owns
     CSymbolTFManager          *m_symbol_tf_manager;         // EA owns
     CGraphElementsCollection  *m_GraphElementsCollection;   // EA owns
     CMarkerSetting            *m_MarkerSetting;             // EA owns - the badge colors
   //--- Newest time read per source: Indicator / Pattern history time, Swing ConfirmedTime, BOS/CHoCH time
     datetime                  m_wm_indicator;
     datetime                  m_wm_pattern;
     datetime                  m_wm_swing;
     datetime                  m_wm_structure;
     bool                      GetIndicatorTemplateSetting(const ENUM_INDICATOR type,MqlParam &raw_params[],bool &buy,bool &sell);
     bool                      GetSymbolTFSetting(const string sym,const ENUM_TIMEFRAMES tf,bool &buy,bool &sell);
     CCandleMarker            *FindMarker(const string name) const;
     bool                      DrawStructureLine(CMarketStructureSeries *ms);
     bool                      IsShown(const int sources) const;
     bool                      Mark(const datetime time,const bool is_buy,const int source);
     bool                      DeleteMarkers(void);
     bool                      ReadNewFacts(void);
   public:
     void                      OnInitEvent(CSignalsCollection *signals,CIndicatorsCollection *ind,CBarTimeSeriesCollection *bars,
                                           CIndicatorTemplateManager *tmpl_mgr,CSymbolTFManager *symtf_mgr,CBarPatternsControl *patterns_ctrl,
                                           CSwingSetting *swing_setting,CMarkerSetting *marker_setting,CGraphElementsCollection *collection);
   //--- Read what is new past the watermarks; full_rebuild (gates or colors changed): delete every marker and read from the start
     void                      Sync(const bool full_rebuild=false);
   //--- A Buy/Sell gate or the Swing setting changed: true when Sync(true) was run
     bool                      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
                               CCandleMarkerSync(void);
  };
#endif // CCANDLEMARKERSYNC_MQH_DECLARATION
#ifndef CCANDLEMARKERSYNC_MQH_IMPLEMENTATION
#define CCANDLEMARKERSYNC_MQH_IMPLEMENTATION
 CCandleMarkerSync::CCandleMarkerSync(void) : m_SignalsCollection(NULL),m_IndicatorsCollection(NULL),m_BarTimeSeriesCollection(NULL),
                                              m_patterns_control(NULL),m_SwingSetting(NULL),m_indicator_template_manager(NULL),
                                              m_symbol_tf_manager(NULL),m_GraphElementsCollection(NULL),m_MarkerSetting(NULL),
                                              m_wm_indicator(0),m_wm_pattern(0),m_wm_swing(0),m_wm_structure(0)
  {
  }
 void CCandleMarkerSync::OnInitEvent(CSignalsCollection *signals,CIndicatorsCollection *ind,CBarTimeSeriesCollection *bars,
                                     CIndicatorTemplateManager *tmpl_mgr,CSymbolTFManager *symtf_mgr,CBarPatternsControl *patterns_ctrl,
                                     CSwingSetting *swing_setting,CMarkerSetting *marker_setting,CGraphElementsCollection *collection)
  {
   this.m_MarkerSetting=marker_setting;
   this.m_SignalsCollection=signals;
   this.m_IndicatorsCollection=ind;
   this.m_BarTimeSeriesCollection=bars;
   this.m_indicator_template_manager=tmpl_mgr;
   this.m_symbol_tf_manager=symtf_mgr;
   this.m_patterns_control=patterns_ctrl;
   this.m_SwingSetting=swing_setting;
   this.m_GraphElementsCollection=collection;
  }
 //--- Identity-only lookup against the LIVE CIndicatorTemplateManager
 bool CCandleMarkerSync::GetIndicatorTemplateSetting(const ENUM_INDICATOR type,MqlParam &raw_params[],bool &buy,bool &sell)
  {
   buy=false;
   sell=false;
   if(this.m_indicator_template_manager==NULL)
      return false;
   CIndicatorSetting *entry=this.m_indicator_template_manager.FindByIdentity(type,raw_params);
   if(entry==NULL)
      return false;
   buy =entry.BuySignal();
   sell=entry.SellSignal();
   return true;
  }
 //--- Symbol + TF level gate, applies equally to Indicator and Pattern facts of that (symbol, tf)
 bool CCandleMarkerSync::GetSymbolTFSetting(const string sym,const ENUM_TIMEFRAMES tf,bool &buy,bool &sell)
  {
   buy=false;
   sell=false;
   if(this.m_symbol_tf_manager==NULL)
      return false;
   CSymbolTFSetting *entry=this.m_symbol_tf_manager.FindByIdentity(sym,tf);
   if(entry==NULL)
      return false;
   buy =entry.BuySignal();
   sell=entry.SellSignal();
   return true;
  }
 CCandleMarker *CCandleMarkerSync::FindMarker(const string name) const
  {
   for(int i=0; i<this.m_GraphElementsCollection.ChildrenTotal(); i++)
     {
      CCandleMarker *m=dynamic_cast<CCandleMarker *>(this.m_GraphElementsCollection.Child(i));
      if(m!=NULL && m.Name()==name)
         return m;
     }
   return NULL;
  }
 //--- A marker is shown when any of its sources is enabled (combinations included). Smart Money facts are read only
 //--- for the elements shown in the Smart Money table, so a marker that has the Smart Money source is always shown
 bool CCandleMarkerSync::IsShown(const int sources) const
  {
   if((sources&CANDLE_MARKER_SOURCE_SMC)!=0)
      return true;
   if((sources&CANDLE_MARKER_SOURCE_INDICATOR)!=0 && this.m_MarkerSetting.ShowIndicator())
      return true;
   return ((sources&CANDLE_MARKER_SOURCE_CANDLE)!=0 && this.m_MarkerSetting.ShowCandle());
  }
 //--- One marker per candle and side: another fact on the same candle and side only adds its source. True when a marker was created or changed
 bool CCandleMarkerSync::Mark(const datetime time,const bool is_buy,const int source)
  {
   string name=CANDLE_MARKER_NAME+(string)(long)time+(is_buy ? "_B" : "_S");
   CCandleMarker *m=this.FindMarker(name);
   int sources=((m!=NULL) ? m.Sources() : 0)|source;
   if(m!=NULL && m.Sources()==sources)
      return false;
   string sym=::Symbol();
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::Period();
   int shift=::iBarShift(sym,tf,time,false);
   if(shift<0)
      return false;
   bool created=(m==NULL);
   if(created)
     {
      m=new CCandleMarker();
      if(m==NULL || !m.Create(::ChartID(),0,name) || !this.m_GraphElementsCollection.AddChild(m))
        {
         delete m;
         return false;
        }
     }
   m.SetMarker(time,::iHigh(sym,tf,shift),::iLow(sym,tf,shift),is_buy,(is_buy ? this.m_MarkerSetting.BuyColor() : this.m_MarkerSetting.SellColor()),sources);
   bool want=this.IsShown(sources);
   if(want && !m.IsVisible())
      m.Show();
   else if(!want && m.IsVisible())
      m.Hide();
   return true;
  }
 //--- The line and the name of one BOS / CHoCH, Buy color for a break up and Sell color for a break down. True when it was created
 bool CCandleMarkerSync::DrawStructureLine(CMarketStructureSeries *ms)
  {
   string name=STRUCTURE_LINE_NAME+(string)(long)ms.Time()+"_"+(string)(int)ms.TypeStructure();
   for(int i=0; i<this.m_GraphElementsCollection.ChildrenTotal(); i++)
     {
      CStructureBreakLine *exists=dynamic_cast<CStructureBreakLine *>(this.m_GraphElementsCollection.Child(i));
      if(exists!=NULL && exists.Name()==name)
         return false;
     }
   CStructureBreakLine *line=new CStructureBreakLine();
   if(line==NULL || !line.Create(::ChartID(),0,name) || !this.m_GraphElementsCollection.AddChild(line))
     {
      delete line;
      return false;
     }
   bool is_up=(ms.Direction()==SIGNAL_BUY);
   line.SetBreak(ms.SwingTime(),ms.Time(),ms.Level(),MarketStructureTypeDescription(ms.TypeStructure()),is_up,
                 (is_up ? this.m_MarkerSetting.BuyColor() : this.m_MarkerSetting.SellColor()));
   return true;
  }
 bool CCandleMarkerSync::DeleteMarkers(void)
  {
   bool deleted=false;
   for(int i=this.m_GraphElementsCollection.ChildrenTotal()-1; i>=0; i--)
     {
      CGBaseObj *child=this.m_GraphElementsCollection.Child(i);
      if(dynamic_cast<CCandleMarker *>(child)==NULL && dynamic_cast<CStructureBreakLine *>(child)==NULL)
         continue;
      this.m_GraphElementsCollection.DeleteChild(child);
      delete child;
      deleted=true;
     }
   return deleted;
  }
 //--- Mark the facts past each watermark, gated like the candle information window; true when a marker was created or changed
 bool CCandleMarkerSync::ReadNewFacts(void)
  {
   if(this.m_BarTimeSeriesCollection==NULL || this.m_IndicatorsCollection==NULL || this.m_SignalsCollection==NULL || this.m_MarkerSetting==NULL)
      return false;
   string sym=::Symbol();
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::Period();
   datetime new_indicator=this.m_wm_indicator;
   datetime new_pattern  =this.m_wm_pattern;
   datetime new_swing    =this.m_wm_swing;
   datetime new_structure=this.m_wm_structure;
   bool changed=false;
   bool symtf_buy,symtf_sell;
   this.GetSymbolTFSetting(sym,tf,symtf_buy,symtf_sell);
   //--- Indicators: history is oldest->newest, walk back to the watermark
   CArrayObj *ind_list=this.m_IndicatorsCollection.GetList();
   int ind_total=(ind_list!=NULL) ? ind_list.Total() : 0;
   for(int ii=0; ii<ind_total; ii++)
     {
      CIndicatorDE *ind=ind_list.At(ii);
      if(ind==NULL || ind.Symbol()!=sym || ind.Timeframe()!=tf)
         continue;
      MqlParam params[];
      ind.GetMqlParams(params);
      bool buy_on,sell_on;
      if(!this.GetIndicatorTemplateSetting(ind.TypeIndicator(),params,buy_on,sell_on))
         continue;
      buy_on =buy_on  && symtf_buy;
      sell_on=sell_on && symtf_sell;
      if(!buy_on && !sell_on)
         continue;
      CSignalBase *signal=this.m_SignalsCollection.GetOrCreateSignal(ind);
      if(signal==NULL)
         continue;
      for(int h=signal.HistoryTotal()-1; h>=0; h--)
        {
         datetime ht=signal.HistoryTime(h);
         if(ht<=this.m_wm_indicator)
            break;
         if(ht>new_indicator)
            new_indicator=ht;
         ENUM_SIGNAL_DIR dir=signal.HistoryDir(h);
         if(dir==SIGNAL_NONE || (dir==SIGNAL_BUY && !buy_on) || (dir==SIGNAL_SELL && !sell_on))
            continue;
         if(this.Mark(ht,(dir==SIGNAL_BUY),CANDLE_MARKER_SOURCE_INDICATOR))
            changed=true;
        }
      if(ind.TypeIndicator()!=IND_BANDS)
         continue;
      CSignalBollinger *bb=(CSignalBollinger*)signal;
      for(int li=0; li<2; li++)
         for(int h=bb.LineHistoryTotal(li)-1; h>=0; h--)
           {
            datetime lht=bb.LineHistoryTime(li,h);
            if(lht<=this.m_wm_indicator)
               break;
            if(lht>new_indicator)
               new_indicator=lht;
            ENUM_SIGNAL_DIR ldir=bb.LineHistoryDir(li,h);
            if(ldir==SIGNAL_NONE || (ldir==SIGNAL_BUY && !buy_on) || (ldir==SIGNAL_SELL && !sell_on))
               continue;
            if(this.Mark(lht,(ldir==SIGNAL_BUY),CANDLE_MARKER_SOURCE_INDICATOR))
               changed=true;
           }
     }
   //--- Candle patterns
   CArrayObj *patterns=this.m_BarTimeSeriesCollection.GetListAllPatterns();
   for(int p=0; patterns!=NULL && p<patterns.Total(); p++)
     {
      CBarPattern *pat=patterns.At(p);
      if(pat==NULL || pat.Symbol()!=sym || pat.Timeframe()!=tf)
         continue;
      datetime pt=pat.Time();
      if(pt<=this.m_wm_pattern)
         continue;
      if(pt>new_pattern)
         new_pattern=pt;
      ENUM_PATTERN_DIRECTION pdir=pat.Direction();
      if(pdir!=PATTERN_DIRECTION_BULLISH && pdir!=PATTERN_DIRECTION_BEARISH)
         continue;
      bool is_buy=(pdir==PATTERN_DIRECTION_BULLISH);
      if(this.m_patterns_control==NULL)
         continue;
      if(is_buy  && !(this.m_patterns_control.PatternSignalBuy(pat.TypePattern())  && symtf_buy))
         continue;
      if(!is_buy && !(this.m_patterns_control.PatternSignalSell(pat.TypePattern()) && symtf_sell))
         continue;
      if(this.Mark(pt,is_buy,CANDLE_MARKER_SOURCE_CANDLE))
         changed=true;
     }
   //--- Swings: the watermark is the ConfirmedTime (pivot + N bars), the marker goes on the pivot candle
   CArrayObj *swings=this.m_BarTimeSeriesCollection.GetListAllSwings();
   for(int w=0; swings!=NULL && w<swings.Total(); w++)
     {
      CBarSwingSeries *sw=swings.At(w);
      if(sw==NULL || sw.Symbol()!=sym || sw.Timeframe()!=tf)
         continue;
      datetime ct=sw.ConfirmedTime();
      if(ct<=this.m_wm_swing)
         continue;
      if(ct>new_swing)
         new_swing=ct;
      if(this.m_SwingSetting==NULL || !this.m_SwingSetting.SignalShow(sw.TypeSwing()))
         continue;
      if(this.Mark(sw.Time(),(sw.TypeSwing()==SWING_TYPE_LOW),CANDLE_MARKER_SOURCE_SMC))
         changed=true;
     }
   //--- BOS / CHoCH: the marker goes on the break candle
   CArrayObj *structures=this.m_BarTimeSeriesCollection.GetListAllMarketStructures();
   for(int s=0; structures!=NULL && s<structures.Total(); s++)
     {
      CMarketStructureSeries *ms=structures.At(s);
      if(ms==NULL || ms.Symbol()!=sym || ms.Timeframe()!=tf)
         continue;
      datetime mt=ms.Time();
      if(mt<=this.m_wm_structure)
         continue;
      if(mt>new_structure)
         new_structure=mt;
      if(this.m_SwingSetting==NULL || !this.m_SwingSetting.SignalShow(ms.TypeStructure()))
         continue;
      if(this.Mark(mt,(ms.Direction()==SIGNAL_BUY),CANDLE_MARKER_SOURCE_SMC))
         changed=true;
      if(this.DrawStructureLine(ms))
         changed=true;
     }
   this.m_wm_indicator=new_indicator;
   this.m_wm_pattern  =new_pattern;
   this.m_wm_swing    =new_swing;
   this.m_wm_structure=new_structure;
   return changed;
  }
 void CCandleMarkerSync::Sync(const bool full_rebuild)
  {
   if(this.m_GraphElementsCollection==NULL)
      return;
   bool changed=false;
   if(full_rebuild)
     {
      changed=this.DeleteMarkers();
      this.m_wm_indicator=0;
      this.m_wm_pattern  =0;
      this.m_wm_swing    =0;
      this.m_wm_structure=0;
     }
   if(this.ReadNewFacts())
      changed=true;
   if(!changed)
      return;
   CCandleMarker::Arrange(this.m_GraphElementsCollection);
   this.m_GraphElementsCollection.BringToTopAllCanvElm();   // the new badges are canvases created after the panel windows
   ::ChartRedraw(::ChartID());
  }
 bool CCandleMarkerSync::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- A Symbol+TF of another symbol never touches this chart's markers
   if((id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED || id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE) &&
      sparam!=::Symbol())
      return false;
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED ||
      id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED ||
      id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED ||
      id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE ||
      id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED ||
      id==CHARTEVENT_CUSTOM+BARPATTERN_CONTROL_EVENT_BUYSELL_CHANGED ||
      id==CHARTEVENT_CUSTOM+SWING_SETTING_EVENT_CHANGED)
     {
      this.Sync(true);
      return true;
     }
   return false;
  }
#endif // CCANDLEMARKERSYNC_MQH_IMPLEMENTATION
#endif // __CANDLEMARKERSYNC_MQH__
