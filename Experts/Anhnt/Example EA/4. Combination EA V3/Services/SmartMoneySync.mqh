//+------------------------------------------------------------------+
//|                                               SmartMoneySync.mqh |
//+------------------------------------------------------------------+
#ifndef __SMARTMONEYSYNC_MQH__
#define __SMARTMONEYSYNC_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #define SMC_DRAW_BARS              (1000)           //Number of Bar to Draw
 #define SMC_LINE_NAME              "SMC_Line_"
 #define SMC_MARKER_NAME            "SMC_Marker_"
//+------------------------------------------------------------------+
//| Draws what Python calculated: one CCandleMarker per Swing/BOS/   |
//| CHoCH candle and one CStructureBreakLine per BOS/CHoCH, all      |
//| children of the CGraphElementsCollection. The EA keeps the lists |
//| (what Python sent), this class only reads them                   |
//+------------------------------------------------------------------+
 class CSmartMoneySync : public CBaseObj
  {
   private:
     CGraphElementsCollection  *m_GraphElementsCollection;   // EA owns
     CSmartMoneySetting        *m_SmartMoneySetting;         // EA owns
     CMarkerSetting            *m_MarkerSetting;             // EA owns - the Buy/Sell badge and line colors
     CIndicatorTemplateManager *m_IndicatorTemplateManager;  // EA owns - the Buy / Sell flag of every indicator
     CPatternManager           *m_PatternManager;            // EA owns - the Buy / Sell flag of every candle pattern
     CArrayObj                 *m_swings;                   // EA owns - CBarSwingSeries received from Python
     CArrayObj                 *m_structures;                // EA owns - CMarketStructureSeries received from Python
     CArrayObj                 *m_signals;                   // EA owns - CIndicatorSignalSeries received from Python
     CArrayObj                 *m_patterns;                  // EA owns - candle patterns received from Python
     CCandleMarker            *FindMarker(const string name) const;
   //--- Create the bare marker when missing (no chart query): the first geometry query after a new object waits for the chart to rebuild, so all are created before any is placed
     void                      Reserve(const datetime time,const bool is_buy);
   //--- Reserve / Mark every entry of a CIndicatorSignalSeries list drawn from from_time on; marks changed
     void                      ReserveList(CArrayObj *list,const int source,const datetime from_time);
   //--- The flag of the signal's indicator template / candle pattern lets its marker show
     bool                      ShowSignal(CIndicatorSignalSeries *signal,const int source) const;
     int                       MarkList(CArrayObj *list,const int source,const datetime from_time);
     bool                      Mark(const datetime time,const bool is_buy,const int source);
     bool                      DrawStructureLine(CMarketStructureSeries *ms);
   public:
     void                      OnInitEvent(CGraphElementsCollection *collection,CSmartMoneySetting *setting,CMarkerSetting *marker_setting,CIndicatorTemplateManager *indicators,CPatternManager *patterns_setting,CArrayObj *swings,CArrayObj *structures,CArrayObj *signals,CArrayObj *patterns);
   //--- Draw the last SMC_DRAW_BARS bars of both lists
     void                      Sync(void);
   //--- One new item (live): mark/draw it and refresh the chart
     void                      Add(CBarSwingSeries *swing);
     void                      Add(CMarketStructureSeries *ms);
     void                      Add(CIndicatorSignalSeries *signal,const int source);
     void                      DeleteMarkers(void);
                               CSmartMoneySync(void);
  };
//+------------------------------------------------------------------+
CSmartMoneySync::CSmartMoneySync(void) : m_GraphElementsCollection(NULL),
                                         m_SmartMoneySetting(NULL),
                                         m_MarkerSetting(NULL),
                                         m_IndicatorTemplateManager(NULL),
                                         m_PatternManager(NULL),
                                         m_swings(NULL),
                                         m_structures(NULL),
                                         m_signals(NULL),
                                         m_patterns(NULL)
  {
  }
//+------------------------------------------------------------------+
void CSmartMoneySync::OnInitEvent(CGraphElementsCollection *collection,CSmartMoneySetting *setting,CMarkerSetting *marker_setting,CIndicatorTemplateManager *indicators,CPatternManager *patterns_setting,CArrayObj *swings,CArrayObj *structures,CArrayObj *signals,CArrayObj *patterns)
  {
   this.m_GraphElementsCollection=collection;
   this.m_SmartMoneySetting=setting;
   this.m_MarkerSetting=marker_setting;
   this.m_IndicatorTemplateManager=indicators;
   this.m_PatternManager=patterns_setting;
   this.m_swings=swings;
   this.m_structures=structures;
   this.m_signals=signals;
   this.m_patterns=patterns;
  }
//+------------------------------------------------------------------+
CCandleMarker *CSmartMoneySync::FindMarker(const string name) const
  {
   for(int i=0;i<this.m_GraphElementsCollection.ChildrenTotal();i++)
     {
      CCandleMarker *marker=dynamic_cast<CCandleMarker *>(this.m_GraphElementsCollection.Child(i));
      if(marker!=NULL && marker.Name()==name)
         return marker;
     }
   return NULL;
  }
//+------------------------------------------------------------------+
void CSmartMoneySync::Reserve(const datetime time,const bool is_buy)
  {
   string name=SMC_MARKER_NAME+(string)(long)time+(is_buy ? "_B" : "_S");
   if(this.FindMarker(name)!=NULL)
      return;
   CCandleMarker *marker=new CCandleMarker();
   if(marker==NULL || !marker.Create(::ChartID(),0,name) || !this.m_GraphElementsCollection.AddChild(marker))
      delete marker;
  }
//+------------------------------------------------------------------+
bool CSmartMoneySync::Mark(const datetime time,const bool is_buy,const int source)
  {
   string name=SMC_MARKER_NAME+(string)(long)time+(is_buy ? "_B" : "_S");
   CCandleMarker *marker=this.FindMarker(name);
   int sources=((marker!=NULL) ? marker.Sources() : 0)|source;
   if(marker!=NULL && marker.Sources()==sources)
      return false;
   string symbol=::Symbol();
   ENUM_TIMEFRAMES timeframe=(ENUM_TIMEFRAMES)::Period();
   int shift=::iBarShift(symbol,timeframe,time,false);
   if(shift<0)
      return false;
   if(marker==NULL)
     {
      marker=new CCandleMarker();
      if(marker==NULL || !marker.Create(::ChartID(),0,name) || !this.m_GraphElementsCollection.AddChild(marker))
        {
         delete marker;
         return false;
        }
     }
   marker.SetMarker(time,::iHigh(symbol,timeframe,shift),::iLow(symbol,timeframe,shift),is_buy,
                    (is_buy ? this.m_MarkerSetting.BuyColor() : this.m_MarkerSetting.SellColor()),sources);
   if(!marker.IsVisible())
      marker.Show();
   return true;
  }
//+------------------------------------------------------------------+
bool CSmartMoneySync::DrawStructureLine(CMarketStructureSeries *ms)
  {
   string name=SMC_LINE_NAME+(string)(long)ms.Time()+"_"+(string)(int)ms.TypeStructure();
   for(int i=0;i<this.m_GraphElementsCollection.ChildrenTotal();i++)
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
//+------------------------------------------------------------------+
void CSmartMoneySync::Sync(void)
  {
   datetime from_time=::iTime(::Symbol(),::Period(),SMC_DRAW_BARS-1);   // 0 when the chart holds fewer bars
   int marked=0,drawn=0;
   for(int i=0;i<this.m_swings.Total();i++)
     {
      CBarSwingSeries *swing=this.m_swings.At(i);
      if(swing!=NULL && swing.Time()>=from_time && this.m_SmartMoneySetting.SignalShow(swing.TypeSwing()))
         this.Reserve(swing.Time(),swing.TypeSwing()==SWING_TYPE_LOW);
     }
   for(int i=0;i<this.m_structures.Total();i++)
     {
      CMarketStructureSeries *ms=this.m_structures.At(i);
      if(ms!=NULL && ms.Time()>=from_time && this.m_SmartMoneySetting.SignalShow(ms.TypeStructure()))
         this.Reserve(ms.Time(),ms.Direction()==SIGNAL_BUY);
     }
   this.ReserveList(this.m_signals,CANDLE_MARKER_SOURCE_INDICATOR,from_time);
   this.ReserveList(this.m_patterns,CANDLE_MARKER_SOURCE_CANDLE,from_time);
   for(int i=0;i<this.m_swings.Total();i++)
     {
      CBarSwingSeries *swing=this.m_swings.At(i);
      if(swing==NULL || swing.Time()<from_time || !this.m_SmartMoneySetting.SignalShow(swing.TypeSwing()))
         continue;
      if(this.Mark(swing.Time(),swing.TypeSwing()==SWING_TYPE_LOW,CANDLE_MARKER_SOURCE_SMC))
         marked++;
     }
   for(int i=0;i<this.m_structures.Total();i++)
     {
      CMarketStructureSeries *ms=this.m_structures.At(i);
      if(ms==NULL || ms.Time()<from_time || !this.m_SmartMoneySetting.SignalShow(ms.TypeStructure()))
         continue;
      if(this.Mark(ms.Time(),ms.Direction()==SIGNAL_BUY,CANDLE_MARKER_SOURCE_SMC))
         marked++;
      if(this.DrawStructureLine(ms))
         drawn++;
     }
   int signals_marked=0,patterns_marked=0;
   signals_marked=this.MarkList(this.m_signals,CANDLE_MARKER_SOURCE_INDICATOR,from_time);
   patterns_marked=this.MarkList(this.m_patterns,CANDLE_MARKER_SOURCE_CANDLE,from_time);
   CCandleMarker::Arrange(this.m_GraphElementsCollection);
   ::ChartRedraw();
   CMessage::ToFile(this.GetFolderName(),"CSmartMoneySync","Sync",(string)marked+" candle marker(s) changed, "+(string)drawn+" BOS/CHoCH line(s) drawn, "+
                    (string)signals_marked+" indicator marker(s) and "+(string)patterns_marked+" candle pattern marker(s) changed");
  }
//+------------------------------------------------------------------+
void CSmartMoneySync::Add(CBarSwingSeries *swing)
  {
   if(!this.m_SmartMoneySetting.SignalShow(swing.TypeSwing()))
      return;
   if(this.Mark(swing.Time(),swing.TypeSwing()==SWING_TYPE_LOW,CANDLE_MARKER_SOURCE_SMC))
     {
      CCandleMarker::Arrange(this.m_GraphElementsCollection);
      ::ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
void CSmartMoneySync::Add(CMarketStructureSeries *ms)
  {
   if(!this.m_SmartMoneySetting.SignalShow(ms.TypeStructure()))
      return;
   bool changed=this.Mark(ms.Time(),ms.Direction()==SIGNAL_BUY,CANDLE_MARKER_SOURCE_SMC);
   if(this.DrawStructureLine(ms))
      changed=true;
   if(changed)
     {
      CCandleMarker::Arrange(this.m_GraphElementsCollection);
      ::ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
bool CSmartMoneySync::ShowSignal(CIndicatorSignalSeries *signal,const int source) const
  {
   if(signal.IsNeutral())
      return false;
   if(source==CANDLE_MARKER_SOURCE_CANDLE)
      return (this.m_PatternManager==NULL || (signal.IsBuy() ? this.m_PatternManager.PatternSignalBuy(signal.Label()) : this.m_PatternManager.PatternSignalSell(signal.Label())));
   CIndicatorSetting *row=(this.m_IndicatorTemplateManager!=NULL && signal.TemplateIndex()>=0) ? this.m_IndicatorTemplateManager.At(signal.TemplateIndex()) : NULL;
   return (row==NULL || (signal.IsBuy() ? row.BuySignal() : row.SellSignal()));   // a template that is gone shows as before
  }
//+------------------------------------------------------------------+
void CSmartMoneySync::ReserveList(CArrayObj *list,const int source,const datetime from_time)
  {
   for(int i=0;i<list.Total();i++)
     {
      CIndicatorSignalSeries *signal=list.At(i);
      if(signal!=NULL && signal.Time()>=from_time && this.ShowSignal(signal,source))
         this.Reserve(signal.Time(),signal.IsBuy());
     }
  }
//+------------------------------------------------------------------+
int CSmartMoneySync::MarkList(CArrayObj *list,const int source,const datetime from_time)
  {
   int changed=0;
   for(int i=0;i<list.Total();i++)
     {
      CIndicatorSignalSeries *signal=list.At(i);
      if(signal==NULL || signal.Time()<from_time || !this.ShowSignal(signal,source))
         continue;
      if(this.Mark(signal.Time(),signal.IsBuy(),source))
         changed++;
     }
   return changed;
  }
//+------------------------------------------------------------------+
void CSmartMoneySync::Add(CIndicatorSignalSeries *signal,const int source)
  {
   if(!this.ShowSignal(signal,source))
      return;
   if(this.Mark(signal.Time(),signal.IsBuy(),source))
     {
      CCandleMarker::Arrange(this.m_GraphElementsCollection);
      ::ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
void CSmartMoneySync::DeleteMarkers(void)
  {
   CCandleMarker::ReleaseBox();
   for(int i=this.m_GraphElementsCollection.ChildrenTotal()-1;i>=0;i--)
     {
      CGBaseObj *child=this.m_GraphElementsCollection.Child(i);
      if(dynamic_cast<CCandleMarker *>(child)==NULL && dynamic_cast<CStructureBreakLine *>(child)==NULL)
         continue;
      this.m_GraphElementsCollection.DeleteChild(child);
      delete child;
     }
   ::ChartRedraw();
  }
//+------------------------------------------------------------------+
#endif // __SMARTMONEYSYNC_MQH__
