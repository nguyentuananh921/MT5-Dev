//+------------------------------------------------------------------+
//|                                               SmartMoneySync.mqh |
//+------------------------------------------------------------------+
#ifndef __SMARTMONEYSYNC_MQH__
#define __SMARTMONEYSYNC_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #define SMC_DRAW_BARS              (1000)           //Number of Bar to Draw
 #define SMC_LINE_NAME              "SMC_Line_"
 #define SMC_MARKER_NAME            "SMC_Marker_"
#define SMC_MOVE_NAME              "SMC_Move_"
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
     CSwingSetting             *m_SwingSetting;              // EA owns - which Swings are drawn
     CStructureSetting         *m_StructureSetting;          // EA owns - which BOS / CHoCH are drawn
     CMomentumCandleSetting          *m_MomentumCandleSetting;           // EA owns - the colours of the momentum candle markers
     CMarketConditionSetting   *m_MarketConditionSetting;    // EA owns - what is drawn of the legs and their colours
     CArrayObj                 *m_movements;                 // EA owns - CMovementSeries received from Python
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
     color                     MarkerColour(const int sources,const bool is_buy) const;
     bool                      DrawStructureLine(CMarketStructureSeries *ms);
     string                    StructureTooltip(CMarketStructureSeries *ms) const;
     color                     StructureColor(const ENUM_SIGNAL_DIR direction) const { return (direction==SIGNAL_BUY ? this.m_StructureSetting.BuyColor() : this.m_StructureSetting.SellColor()); }
   //--- A leg between two Swings as a line of the colour of its kind; false when it is not drawn (other TF, switched off, already there)
     bool                      DrawMovement(CMovementSeries *leg);
   public:
     void                      SetMarketConditionSetting(CMarketConditionSetting *setting) { this.m_MarketConditionSetting=setting; }
     void                      SetMovements(CArrayObj *movements) { this.m_movements=movements; }
     void                      SetMomentumCandleSetting(CMomentumCandleSetting *setting) { this.m_MomentumCandleSetting=setting; }
   //--- The marker of a momentum candle (CLifecycleSync announces them): true when the marker changed. The caller arranges the markers
     bool                      MarkMomentum(const datetime time,const bool is_buy);
     void                      OnInitEvent(CGraphElementsCollection *collection,CSwingSetting *swing_setting,CStructureSetting *structure_setting,CIndicatorTemplateManager *indicators,CPatternManager *patterns_setting,CArrayObj *swings,CArrayObj *structures,CArrayObj *signals,CArrayObj *patterns);
   //--- Draw the last SMC_DRAW_BARS bars of both lists
     void                      Sync(void);
   //--- One new item (live): mark/draw it and refresh the chart
     void                      Add(CBarSwingSeries *swing);
     void                      Add(CMarketStructureSeries *ms);
     void                      Add(CMovementSeries *leg);
     void                      Add(CIndicatorSignalSeries *signal,const int source);
     void                      DeleteMarkers(void);
                               CSmartMoneySync(void);
  };
//+------------------------------------------------------------------+
CSmartMoneySync::CSmartMoneySync(void) : m_GraphElementsCollection(NULL),
                                         m_SwingSetting(NULL),
                                         m_StructureSetting(NULL),
                                         m_MomentumCandleSetting(NULL),
                                         m_MarketConditionSetting(NULL),
                                         m_movements(NULL),
                                         m_IndicatorTemplateManager(NULL),
                                         m_PatternManager(NULL),
                                         m_swings(NULL),
                                         m_structures(NULL),
                                         m_signals(NULL),
                                         m_patterns(NULL)
  {
  }
//+------------------------------------------------------------------+
void CSmartMoneySync::OnInitEvent(CGraphElementsCollection *collection,CSwingSetting *swing_setting,CStructureSetting *structure_setting,CIndicatorTemplateManager *indicators,CPatternManager *patterns_setting,CArrayObj *swings,CArrayObj *structures,CArrayObj *signals,CArrayObj *patterns)
  {
   this.m_GraphElementsCollection=collection;
   this.m_SwingSetting=swing_setting;
   this.m_StructureSetting=structure_setting;
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
//--- The colour of a marker: the source of the highest priority in it decides: BOS / CHoCH, Candle pattern, Momentum candle, Indicator, Swing
color CSmartMoneySync::MarkerColour(const int sources,const bool is_buy) const
  {
   if((sources&CANDLE_MARKER_SOURCE_STRUCTURE)!=0)
      return (is_buy ? this.m_StructureSetting.BuyColor() : this.m_StructureSetting.SellColor());
   if((sources&CANDLE_MARKER_SOURCE_CANDLE)!=0)
      return (is_buy ? this.m_PatternManager.BuyColor() : this.m_PatternManager.SellColor());
   if((sources&CANDLE_MARKER_SOURCE_MOMENTUM)!=0 && this.m_MomentumCandleSetting!=NULL)
      return (is_buy ? this.m_MomentumCandleSetting.BuyColor() : this.m_MomentumCandleSetting.SellColor());
   if((sources&CANDLE_MARKER_SOURCE_INDICATOR)!=0)
      return (is_buy ? this.m_IndicatorTemplateManager.BuyColor() : this.m_IndicatorTemplateManager.SellColor());
   return (is_buy ? this.m_SwingSetting.Colour(SWING_TYPE_LOW) : this.m_SwingSetting.Colour(SWING_TYPE_HIGH));   // a Swing: a Low is a Buy marker, a High a Sell one
  }
//+------------------------------------------------------------------+
bool CSmartMoneySync::Mark(const datetime time,const bool is_buy,const int source)
  {
   string name=SMC_MARKER_NAME+(string)(long)time+(is_buy ? "_B" : "_S");
   CCandleMarker *marker=this.FindMarker(name);
   int sources=((marker!=NULL) ? marker.Sources() : 0)|source;
   if(marker!=NULL && marker.Sources()==sources)
      return false;   // nothing new
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
   marker.SetMarker(time,::iHigh(symbol,timeframe,shift),::iLow(symbol,timeframe,shift),is_buy,this.MarkerColour(sources,is_buy),sources);
   if(!marker.IsVisible())
      marker.Show();
   return true;
  }
//+------------------------------------------------------------------+
bool CSmartMoneySync::DrawMovement(CMovementSeries *leg)
  {
   if(this.m_MarketConditionSetting==NULL || !this.m_MarketConditionSetting.ShowMoves() || leg.Timeframe()!=(ENUM_TIMEFRAMES)::Period())
      return false;
   if(leg.Move()==MOVE_TYPE_NONE && !this.m_MarketConditionSetting.ShowUnclassified())
      return false;
   string name=SMC_MOVE_NAME+(string)(long)leg.EndTime()+"_"+(string)(long)leg.StartTime();
   for(int i=0;i<this.m_GraphElementsCollection.ChildrenTotal();i++)
     {
      CMovementLine *exists=dynamic_cast<CMovementLine *>(this.m_GraphElementsCollection.Child(i));
      if(exists!=NULL && exists.Name()==name)
         return false;
     }
   CMovementLine *line=new CMovementLine();
   if(line==NULL || !line.Create(::ChartID(),0,name) || !this.m_GraphElementsCollection.AddChild(line))
     {
      delete line;
      return false;
     }
   bool impulse=(leg.Move()==MOVE_TYPE_IMPULSE);
   line.SetLeg(leg.StartTime(),leg.StartPrice(),leg.EndTime(),leg.EndPrice(),this.m_MarketConditionSetting.MoveColor(leg.Move()),
               (impulse ? STYLE_SOLID : leg.Move()==MOVE_TYPE_PULLBACK ? STYLE_DASH : STYLE_DOT),2,leg.ShortText());
   return true;
  }
//+------------------------------------------------------------------+
void CSmartMoneySync::Add(CMovementSeries *leg)
  {
   if(this.DrawMovement(leg))
      ::ChartRedraw();
  }
//+------------------------------------------------------------------+
//--- What a BOS / CHoCH tells: the level that was broken is the weak one, the swing the move started from is the strong one
string CSmartMoneySync::StructureTooltip(CMarketStructureSeries *ms) const
  {
   int digits=(int)::SymbolInfoInteger(ms.Symbol(),SYMBOL_DIGITS);
   bool up=(ms.Direction()==SIGNAL_BUY);
   string text=MarketStructureTypeDescription(ms.TypeStructure())+(up ? " up" : " down")+"\n"+
               "Weak "+(up ? "high " : "low ")+::DoubleToString(ms.Level(),digits)+" (broken, "+::TimeToString(ms.SwingTime(),TIME_DATE|TIME_MINUTES)+")";
   if(ms.StrongTime()>0)
      text+="\nStrong "+(up ? "low " : "high ")+::DoubleToString(ms.StrongPrice(),digits)+" (the move started, "+::TimeToString(ms.StrongTime(),TIME_DATE|TIME_MINUTES)+")";
   return text;
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
   //--- two colours: the direction of the break (the colours of CStructureSetting); BOS or CHoCH is the text of the line
   line.SetBreak(ms.SwingTime(),ms.Time(),ms.Level(),MarketStructureTypeDescription(ms.TypeStructure()),is_up,
                 this.StructureColor(ms.Direction()),this.StructureTooltip(ms));
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
      if(swing!=NULL && swing.Timeframe()==(ENUM_TIMEFRAMES)::Period() && swing.Time()>=from_time && this.m_SwingSetting.SignalShow(swing.TypeSwing()))
         this.Reserve(swing.Time(),swing.TypeSwing()==SWING_TYPE_LOW);
     }
   for(int i=0;i<this.m_structures.Total();i++)
     {
      CMarketStructureSeries *ms=this.m_structures.At(i);
      if(ms!=NULL && ms.Timeframe()==(ENUM_TIMEFRAMES)::Period() && ms.Time()>=from_time && this.m_StructureSetting.SignalShow(ms.TypeStructure()))
         this.Reserve(ms.Time(),ms.Direction()==SIGNAL_BUY);
     }
   this.ReserveList(this.m_signals,CANDLE_MARKER_SOURCE_INDICATOR,from_time);
   this.ReserveList(this.m_patterns,CANDLE_MARKER_SOURCE_CANDLE,from_time);
   for(int i=0;i<this.m_swings.Total();i++)
     {
      CBarSwingSeries *swing=this.m_swings.At(i);
      if(swing==NULL || swing.Timeframe()!=(ENUM_TIMEFRAMES)::Period() || swing.Time()<from_time || !this.m_SwingSetting.SignalShow(swing.TypeSwing()))
         continue;
      if(this.Mark(swing.Time(),swing.TypeSwing()==SWING_TYPE_LOW,CANDLE_MARKER_SOURCE_SMC))
         marked++;
     }
   for(int i=0;i<this.m_structures.Total();i++)
     {
      CMarketStructureSeries *ms=this.m_structures.At(i);
      if(ms==NULL || ms.Timeframe()!=(ENUM_TIMEFRAMES)::Period() || ms.Time()<from_time || !this.m_StructureSetting.SignalShow(ms.TypeStructure()))
         continue;
      if(this.Mark(ms.Time(),ms.Direction()==SIGNAL_BUY,CANDLE_MARKER_SOURCE_SMC|CANDLE_MARKER_SOURCE_STRUCTURE))
         marked++;
      if(this.DrawStructureLine(ms))
         drawn++;
     }
   int legs=0;
   for(int i=0;this.m_movements!=NULL && i<this.m_movements.Total();i++)
     {
      CMovementSeries *leg=this.m_movements.At(i);
      if(leg!=NULL && leg.EndTime()>=from_time && this.DrawMovement(leg))
         legs++;
     }
   int signals_marked=0,patterns_marked=0;
   signals_marked=this.MarkList(this.m_signals,CANDLE_MARKER_SOURCE_INDICATOR,from_time);
   patterns_marked=this.MarkList(this.m_patterns,CANDLE_MARKER_SOURCE_CANDLE,from_time);
   CCandleMarker::Arrange(this.m_GraphElementsCollection);
   ::ChartRedraw();
   CMessage::ToFile(this.GetFolderName(),"CSmartMoneySync","Sync",(string)marked+" candle marker(s) changed, "+(string)drawn+" BOS/CHoCH line(s) drawn, "+
                    (string)signals_marked+" indicator marker(s) and "+(string)patterns_marked+" candle pattern marker(s) changed, "+(string)legs+" leg(s) drawn");
  }
//+------------------------------------------------------------------+
bool CSmartMoneySync::MarkMomentum(const datetime time,const bool is_buy)
  {
   if(this.m_MomentumCandleSetting==NULL || !this.m_MomentumCandleSetting.Show())
      return false;
   return this.Mark(time,is_buy,CANDLE_MARKER_SOURCE_MOMENTUM);
  }
//+------------------------------------------------------------------+
void CSmartMoneySync::Add(CBarSwingSeries *swing)
  {
   if(swing.Timeframe()!=(ENUM_TIMEFRAMES)::Period() || !this.m_SwingSetting.SignalShow(swing.TypeSwing()))
      return;   // only the chart's TF is drawn
   if(this.Mark(swing.Time(),swing.TypeSwing()==SWING_TYPE_LOW,CANDLE_MARKER_SOURCE_SMC))
     {
      CCandleMarker::Arrange(this.m_GraphElementsCollection);
      ::ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
void CSmartMoneySync::Add(CMarketStructureSeries *ms)
  {
   if(ms.Timeframe()!=(ENUM_TIMEFRAMES)::Period() || !this.m_StructureSetting.SignalShow(ms.TypeStructure()))
      return;
   bool changed=this.Mark(ms.Time(),ms.Direction()==SIGNAL_BUY,CANDLE_MARKER_SOURCE_SMC|CANDLE_MARKER_SOURCE_STRUCTURE);
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
   if(signal.IsNeutral() || signal.Timeframe()!=(ENUM_TIMEFRAMES)::Period())
      return false;   // no side, or found on another TF: the chart draws its own TF only
   if(source==CANDLE_MARKER_SOURCE_CANDLE)
      return (this.m_PatternManager!=NULL && this.m_PatternManager.ShowMarkers() && (signal.IsBuy() ? this.m_PatternManager.PatternSignalBuy(signal.Label()) : this.m_PatternManager.PatternSignalSell(signal.Label())));
   if(this.m_IndicatorTemplateManager==NULL || !this.m_IndicatorTemplateManager.ShowMarkers())
      return false;   // the Indicators group of the Inputs
   CIndicatorSetting *row=(signal.TemplateIndex()>=0) ? this.m_IndicatorTemplateManager.At(signal.TemplateIndex()) : NULL;
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
      if(dynamic_cast<CCandleMarker *>(child)==NULL && dynamic_cast<CStructureBreakLine *>(child)==NULL && dynamic_cast<CMovementLine *>(child)==NULL)
         continue;
      this.m_GraphElementsCollection.DeleteChild(child);
      delete child;
     }
   ::ChartRedraw();
  }
//+------------------------------------------------------------------+
#endif // __SMARTMONEYSYNC_MQH__
