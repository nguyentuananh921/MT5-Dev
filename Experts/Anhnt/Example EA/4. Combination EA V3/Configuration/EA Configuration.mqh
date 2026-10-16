//+------------------------------------------------------------------+
//|                                             EA Configuration.mqh |
//+------------------------------------------------------------------+
#ifndef __EACONFIGURATION_MQH__
#define __EACONFIGURATION_MQH__
//Include and declare properties
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\SymbolsCollection.mqh>
   CSymbolsCollection m_SymbolsCollection;
  #include "SymbolTFManager.mqh"
   CSymbolTFManager m_SymbolTFManager;
  #include "IndicatorTemplateManager.mqh"
   CIndicatorTemplateManager m_IndicatorTemplateManager;
   CChartObj *m_ChartObj = NULL;   // rebuilt in OnInit: a chart-change re-init keeps the globals but the symbol / timeframe changed
  #include "PatternManager.mqh"
   CPatternManager m_PatternManager;
  #include "SwingSetting.mqh"
   CSwingSetting m_SwingSetting;
  #include "StructureSetting.mqh"
   CStructureSetting m_StructureSetting;
  #include "MarketConditionSetting.mqh"
   CMarketConditionSetting m_MarketConditionSetting;
  #include "TrendlineSetting.mqh"
   CTrendlineSetting m_TrendlineSetting;
  #include "ZoneSetting\SupportResistanceSetting.mqh"
   CSupportResistanceSetting m_SupportResistanceSetting;
  #include "ZoneSetting\MomentumCandleSetting.mqh"
   CMomentumCandleSetting m_MomentumCandleSetting;
  #include "ZoneSetting\SupplyDemandSetting.mqh"
   CSupplyDemandSetting m_SupplyDemandSetting;
  #include "ZoneSetting\FvgSetting.mqh"
   CFvgSetting m_FvgSetting;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Timeseries\SmartMoney\BarSwingSeries.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Timeseries\SmartMoney\MarketStructureSeries.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Timeseries\SmartMoney\MarketConditionSeries.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Timeseries\SmartMoney\MovementSeries.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Timeseries\Signal\IndicatorSignalSeries.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\GraphElementsCollection.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\CandleMarker.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\StructureBreakLine.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\MovementLine.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\DELib\CommonDELib.mqh>
   CGraphElementsCollection g_GraphElementsCollection;
   bool              g_ea_init_done = false;
  #include "..\Services\SmartMoneySync.mqh"
   CSmartMoneySync m_SmartMoneySync;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\LifecycleCollection.mqh>
   CLifecycleCollection m_LifecycleCollection;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\TrendlineLine.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\ZoneTagBox.mqh>
  #include "..\Services\LifecycleSync.mqh"
   CLifecycleSync m_LifecycleSync;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\IndicatorsCollection.mqh>
   CIndicatorsCollection m_IndicatorsCollection;
  #include "..\Services\PythonBridge.mqh"
   CPythonBridge m_PythonBridge;
  #include "..\Services\TradeHistorySync.mqh"
   CTradeHistorySync m_TradeHistorySync;
  #include "TradingSetupSettingManager.mqh"
   CTradingSetupSettingManager m_TradingSetupManager;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\MarketCollection.mqh>
   CMarketCollection m_MarketCollection;
  #include "..\Services\TradingEngine.mqh"
   CTradingEngine m_TradingEngine;
  #include "..\GUIPannel\GUIPannel.mqh"
   CGUIPannel m_GUIPannel;
#endif // __EACONFIGURATION_MQH__
