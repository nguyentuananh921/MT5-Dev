//+------------------------------------------------------------------+
//|                                           ChartGraphicEngine.mqh |
//| Graphic-side engine (Anhnt, 2026-09-21): owns the                |
//| CGraphElementsCollection and draws signal / pattern / swing       |
//| markers as standard OBJ_ARROW / OBJ_TEXT objects straight from   |
//| the in-memory collections. Replaces CSignalBridgeWriter +        |
//| SignalMarkers.mq5 (file bridge). PureData engines never touch it.|
//+------------------------------------------------------------------+
#ifndef CCHARTGRAPHICENGINE_MQH
#define CCHARTGRAPHICENGINE_MQH
 //+------------------------------------------------------------------+
 //| Include Custom files                                             |
 //+------------------------------------------------------------------+
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\GraphElementsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\BarTimeSeriesCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\IndicatorsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Collections\SignalsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeries\BarPatternsControl.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeriesPatterns\BarSwing.mqh>
  #include "..\Services\IndicatorTemplateManager.mqh"
  #include "..\Services\SymbolTFManager.mqh"
  #include "..\Services\SwingSetting.mqh"
#ifndef CCHARTGRAPHICENGINE_MQH_DECLARATION
#define CCHARTGRAPHICENGINE_MQH_DECLARATION
 //--- Marker style slots - same order as CGUIPannel::GetMarkerSettings / the old SignalMarkers inputs
 enum ENUM_MARKER_SLOT
  {
   MARKER_SINGLE_BUY = 0, MARKER_SINGLE_SELL, MARKER_MULTI_BUY, MARKER_MULTI_SELL,
   MARKER_PATTERN_BUY,    MARKER_PATTERN_SELL, MARKER_COMBO_BUY, MARKER_COMBO_SELL,
   MARKER_SWING_HIGH,     MARKER_SWING_LOW,
   MARKER_SLOTS_TOTAL
  };
 //+------------------------------------------------------------------+
 //| One chart bar's aggregated marks - the tallies SignalMarkers::    |
 //| ComputeBar kept per bar. Transient: built from the PureData        |
 //| collections for one pass, held in a sorted CArrayObj (Search by   |
 //| bar time), gone once the bar's objects are in the graph collection|
 //+------------------------------------------------------------------+
 class CBarMarks : public CObject
  {
   public:
    datetime          time;
    int               ind_buy, ind_sell, pat_buy, pat_sell, own_buy, own_sell;
    int               swing_low, swing_high, own_swing_low, own_swing_high, swing_low_struct, swing_high_struct;
                      CBarMarks(const datetime t);
    virtual int       Compare(const CObject *node, const int mode = 0) const;
  };
 class CChartGraphicEngine
  {
    private:
     //Owns
      CGraphElementsCollection   m_GraphCollection;               // every marker object goes through it
     //Borrow (same sources CSignalBridgeWriter walked - PureData, never modified here)
      CSignalsCollection        *m_SignalsCollection;
      CIndicatorsCollection     *m_IndicatorsCollection;
      CBarTimeSeriesCollection  *m_BarTimeSeriesCollection;
      CIndicatorTemplateManager *m_indicator_template_manager;
      CSymbolTFManager          *m_symbol_tf_manager;
      CBarPatternsControl       *m_patterns_control;
      CSwingSetting             *m_swing_setting;
     //Marker style - pushed by the EA from the GUI's Marker Setting
      int                        m_code[MARKER_SLOTS_TOTAL];      // Wingdings glyph per slot
      color                      m_clr_buy, m_clr_sell, m_clr_nonrelated;
     //Drawing state
      string                     m_name_prefix;                   // "<program>_" - what the collection prepends to every name
      int                        m_window_bars;                   // sliding window: only the last N chart bars carry objects
      string                     m_drawn_symbol;                  // what the current object set was built for
      ENUM_TIMEFRAMES            m_drawn_tf;
      datetime                   m_watermark;                     // newest signal/pattern/swing time already drawn
      bool                       m_need_full_rebuild;
      CArrayObj                  m_pending;                       // CBarMarks still to draw (newest first) - spread over timer ticks so the GUI never freezes
      int                        m_pending_pos;
      int                        m_bars_per_tick;                 // creation budget per OnTimerEvent (each object costs ~10ms of chart API)
     //Gates - copied 1:1 from CSignalBridgeWriter
      bool                       GetIndicatorTemplateSetting(const ENUM_INDICATOR type, MqlParam &raw_params[], bool &buy, bool &sell);
      bool                       GetSymbolTFSetting(const string sym, const ENUM_TIMEFRAMES tf, bool &buy, bool &sell);
      bool                       GetCandlePatternSetting(const ENUM_PATTERN_TYPE type, bool &buy, bool &sell);
     //Source walk (PureData in, CBarMarks out)
      datetime                   NewestSourceTime(const string sym);
      int                        CollectBarMarks(const string sym, const datetime since, CArrayObj &marks);
      CBarMarks                 *FindOrAddMark(CArrayObj &marks, const datetime bar_time, const bool add);
      datetime                   ChartBarOf(const string sym, const ENUM_TIMEFRAMES chart_tf, const datetime t);
     //Objects - every one lives in m_GraphCollection; bar membership is read back from it by GRAPH_OBJ_PROP_TIME
      string                     ObjName(const datetime bar_time, const string kind);
      void                       DrawBar(const CBarMarks &m);
      void                       DrawPending(void);               // draws up to m_bars_per_tick bars from m_pending
      void                       DeleteObjectsInList(CArrayObj *list);
      void                       DeleteBarObjects(const datetime bar_time);
      void                       DeleteAllObjects(void);
      void                       PruneWindow(void);
      bool                       CreateArrowMarker(const string name, const datetime t, const double price, const int code, const bool below, const color clr);
      bool                       CreateLabel(const string name, const datetime t, const double price, const string text, const bool above, const color clr);
    public:
                                 CChartGraphicEngine(void);
                                ~CChartGraphicEngine(void);
     //Lifecycle ->Implementation in ChartGraphicEngine_Markers.mqh
      void                       OnInitEvent(CSignalsCollection *signals, CIndicatorsCollection *ind, CBarTimeSeriesCollection *bars,
                                             CIndicatorTemplateManager *tmpl_mgr, CSymbolTFManager *symtf_mgr,
                                             CBarPatternsControl *patterns_ctrl, CSwingSetting *swing_setting);
      void                       OnTimerEvent(void);
      bool                       OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
      void                       OnDeinitEvent(const int reason);
     //Style (from CGUIPannel::GetMarkerSettings) - any change forces a full rebuild
      void                       SetMarkerStyle(const int &codes[], const color buy_clr, const color sell_clr, const color nonrelated_clr);
      void                       WindowBars(const int bars)                { m_window_bars = MathMax(bars, 10); m_need_full_rebuild = true; }
      int                        WindowBars(void) const                    { return m_window_bars; }
      void                       BarsPerTick(const int bars)               { m_bars_per_tick = MathMax(bars, 1); }
      bool                       IsDrawing(void) const                     { return m_pending_pos < m_pending.Total(); }
      void                       RebuildAll(void)                          { m_need_full_rebuild = true; }
     // Gateway
      CGraphElementsCollection  *GetGraphCollection(void)                  { return &m_GraphCollection; }
  };
#endif // CCHARTGRAPHICENGINE_MQH_DECLARATION
#ifndef CCHARTGRAPHICENGINE_MQH_IMPLEMENTATION
#define CCHARTGRAPHICENGINE_MQH_IMPLEMENTATION
 #include "ChartGraphicEngine_Lifecycle.mqh"
 #include "ChartGraphicEngine_Markers.mqh" 
#endif // CCHARTGRAPHICENGINE_MQH_IMPLEMENTATION
#endif // CCHARTGRAPHICENGINE_MQH
