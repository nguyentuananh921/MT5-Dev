//+------------------------------------------------------------------+
//|                                             EA Configuration.mqh |
//+------------------------------------------------------------------+
#ifndef __EACONFIGURATION_MQH__
#define __EACONFIGURATION_MQH__
//+------------------------------------------------------------------+
//| INPUTS OF THE EA: the colours, and the Market State and Phase    |
//| settings that have no box in the Quick Setting tab. Everything   |
//| else (what is shown, how it is calculated, the risk) is set in   |
//| the Quick Setting tab, saved in Config_Setting.json and read at  |
//| the start: the Setting classes start from default values         |
//+------------------------------------------------------------------+
//------------------------------------------------------------------
// INPUTS: Swing   (read by CSwingSetting)
//------------------------------------------------------------------
//Inputs of the EA: the Swings
input group "=== Swing Visual==="
 input color  InpSwingHighColor   = clrRed;          // Swing High
 input color  InpSwingLowColor    = clrDodgerBlue;   // Swing Low

//------------------------------------------------------------------
// INPUTS: Market structure (BOS / CHoCH)   (read by CStructureSetting)
//------------------------------------------------------------------
//Inputs of the EA: the breaks of the market structure
 input group "=== Market Structure: Visual ==="
 input color  InpStructureBuyColor  = clrDodgerBlue;    // BOS / CHoCH up
 input color  InpStructureSellColor = clrRed;           // BOS / CHoCH down

//------------------------------------------------------------------
// INPUTS: Trendline   (read by CTrendlineSetting)
//------------------------------------------------------------------
//Inputs of the EA: the Trendline part of the Inputs table
 input group "=== Trendline: Visual ==="
 input color  InpTrendlineSupportColor    = clrDodgerBlue; // Support
 input color  InpTrendlineResistanceColor = clrRed;        // Resistance
 input color  InpTrendlineDeadColor       = clrGray;       // Dead line colour
//------------------------------------------------------------------
// INPUTS: Market State and Phase   (read by CMarketConditionSetting)
//------------------------------------------------------------------
//Inputs of the EA: the Market State and Phase part of the Inputs table
 input group "=== Market State and Phase: Calculation ==="
 input double InpMarketMinStepATR     = 0.3;    // Min break distance (ATR)
 input group "=== Market State and Phase: Visual ==="
 input color  InpPhaseAccumulationColor = clrGold;        // Accumulation Phase
 input color  InpPhaseMarkupColor       = clrLimeGreen;   // Markup Phase
 input color  InpPhaseDistributionColor = clrOrange;      // Distribution Phase
 input color  InpPhaseMarkdownColor     = clrTomato;      // Markdown Phase
 input color  InpMoveImpulseColor       = clrDodgerBlue;  // Impulse leg
 input color  InpMovePullbackColor      = clrRed;         // Pullback leg
 input color  InpMoveNoneColor          = clrSilver;      // Leg of a range

//------------------------------------------------------------------
// INPUTS: Support / Resistance zone   (read by CSupportResistanceSetting)
//------------------------------------------------------------------
//Inputs of the EA: the Support / Resistance zones (the ones of the swings; the supply / demand zones of the momentum candles are in SupplyDemandSetting.mqh)
 input group "=== Support / Resistance zone: Visual ==="
 input color  InpSupportResistanceSupportColor    = clrRoyalBlue;      // Support colour (None = blue / red)
 input color  InpSupportResistanceResistanceColor = clrDarkGoldenrod;  // Resistance colour (None = blue / red)
 input color  InpSupportResistanceDeadColor       = clrGray; // Dead zone colour

//------------------------------------------------------------------
// INPUTS: Momentum candle   (read by CMomentumCandleSetting)
//------------------------------------------------------------------
//Inputs of the EA: the momentum candles (a body bigger than a multiple of the biggest body before it)
 input group "=== Momentum candle: Visual ==="
 input color  InpMomentumCandleBuyColor   = clrDodgerBlue;    // Momentum candle up colour
 input color  InpMomentumCandleSellColor  = clrRed;  // Momentum candle down colour

//------------------------------------------------------------------
// INPUTS: Supply / Demand zone   (read by CSupplyDemandSetting)
//------------------------------------------------------------------
//Inputs of the EA: the supply and demand zones of the momentum candles (what Python calculates is in MomentumSetting.mqh)
 input group "=== Supply / Demand zones: Visual ==="
 input color  InpSupplyDemandDemandColor = clrLimeGreen;   // Demand colour
 input color  InpSupplyDemandSupplyColor = clrTomato;          // Supply colour
 input color  InpSupplyDemandDeadColor   = clrGray;             // Dead zone colour

//------------------------------------------------------------------
// INPUTS: Fair value gap (FVG)   (read by CFvgSetting)
//------------------------------------------------------------------
//Inputs of the EA: the fair value gaps (FVG) of the momentum candles (what Python calculates is in MomentumCandleSetting.mqh)
 input group "=== Fair value gap (FVG): Visual ==="
 input color  InpFvgBullishColor  = clrTeal;           // Bullish FVG outline colour (a blue green, next to the green of the demand zone it touches)
 input color  InpFvgBearishColor  = clrMediumVioletRed; // Bearish FVG outline colour (a magenta, next to the red of the supply zone it touches)
 input color  InpFvgDeadColor     = clrGray;        // Filled FVG colour

//------------------------------------------------------------------
// INPUTS: Candle patterns   (read by CPatternManager (gets them in OnInit: SetMarkers))
//------------------------------------------------------------------
//Inputs of the EA: the colours of the candle pattern badges (the flags of each pattern are in its table)
 input group "=== Candle Patterns: Visual ==="
 input color  InpPatternBuyColor  = clrDodgerBlue;   // Candle pattern Buy
 input color  InpPatternSellColor = clrRed;          // Candle pattern Sell

//------------------------------------------------------------------
// INPUTS: Indicators   (read by CIndicatorTemplateManager (gets them in OnInit: SetMarkers))
//------------------------------------------------------------------
//Inputs of the EA: the badges of the indicator signals (the Buy / Sell flags of each template are in its table)
 input group "=== Indicators: Visual ==="
 input color  InpIndicatorBuyColor  = clrDodgerBlue;   // Indicator Buy
 input color  InpIndicatorSellColor = clrRed;          // Indicator Sell

//------------------------------------------------------------------
// INPUTS: Trading: risk per new trade   (CRiskManagementSettingManager gets them in OnInit: SetRisk)
//------------------------------------------------------------------
//Inputs of the EA: the risk of a new trade, the same for every Symbol (it was the "Use RPT %" checkbox and its edit of the Trading tab)

//+------------------------------------------------------------------+
//| OBJECTS OF THE EA: the children it owns                          |
//+------------------------------------------------------------------+
//Include and declare properties
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\SymbolsCollection.mqh>
   CSymbolsCollection m_SymbolsCollection;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\Settings\SymbolTFManager.mqh>
   CSymbolTFManager m_SymbolTFManager;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\Settings\IndicatorTemplateManager.mqh>
   CIndicatorTemplateManager m_IndicatorTemplateManager;
   CChartObj *m_ChartObj = NULL;   // rebuilt in OnInit: a chart-change re-init keeps the globals but the symbol / timeframe changed
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\Settings\PatternManager.mqh>
   CPatternManager m_PatternManager;
  #include "TimeSeriesSetting\SwingSetting.mqh"
   CSwingSetting m_SwingSetting;
  #include "TimeSeriesSetting\StructureSetting.mqh"
   CStructureSetting m_StructureSetting;
  #include "TimeSeriesSetting\MarketConditionSetting.mqh"
   CMarketConditionSetting m_MarketConditionSetting;
  #include "TimeSeriesSetting\ZoneSetting\FvgSetting.mqh"
   CFvgSetting m_FvgSetting;
  #include "TimeSeriesSetting\ZoneSetting\MomentumCandleSetting.mqh"
   CMomentumCandleSetting m_MomentumCandleSetting;
  #include "TimeSeriesSetting\ZoneSetting\SupplyDemandSetting.mqh"
   CSupplyDemandSetting m_SupplyDemandSetting;
  #include "TimeSeriesSetting\TrendlineSetting.mqh"
   CTrendlineSetting m_TrendlineSetting;
  #include "TimeSeriesSetting\ZoneSetting\SupportResistanceSetting.mqh"
   CSupportResistanceSetting m_SupportResistanceSetting;
  #include "TimeSeriesSetting\SmartMoneySettingManager.mqh"
   CSmartMoneySettingManager m_SmartMoneySettingManager;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\IndicatorsCollection.mqh>
   CIndicatorsCollection m_IndicatorsCollection;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\Settings\RiskManagementSettingManager.mqh>
   CRiskManagementSettingManager m_RiskManagementManager;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\AccountsCollection.mqh>
   CAccountsCollection m_AccountsCollection;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\GraphElementsCollection.mqh>
   CGraphElementsCollection g_GraphElementsCollection;
   bool g_ea_init_done = false;   // the timer does nothing until the panel and the children are made
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Timeseries\SmartMoney\BarSwingSeries.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Timeseries\SmartMoney\MarketStructureSeries.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Timeseries\SmartMoney\MarketConditionSeries.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Timeseries\SmartMoney\MovementSeries.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Timeseries\Signal\IndicatorSignalSeries.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\CandleMarker.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\StructureBreakLine.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\MovementLine.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\DELib\CommonDELib.mqh>
  #include "..\Services\SmartMoneySync.mqh"
   CSmartMoneySync m_SmartMoneySync;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\LifecycleCollection.mqh>
   CLifecycleCollection m_LifecycleCollection;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\TrendlineLine.mqh>
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Graph\Composite\ZoneTagBox.mqh>
  #include "..\Services\LifecycleSync.mqh"
   CLifecycleSync m_LifecycleSync;
  #include "..\Services\Python\PythonBridge.mqh"
   CPythonBridge m_PythonBridge;
  #include "..\Services\CandleInfo.mqh"
   CCandleInfo m_CandleInfo;
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\LibDatabase.mqh>   // the database of the library (the account the terminal is logged in to has a row)
  #include <Vendors\Anhnt\Library\4. Combination Lib V3\Trading\TradingControl.mqh>   // sends the orders, and works out the Stop Loss, the Trailing and the lot by risk
   CTradingControl m_TradingControl;
  #include "..\GUIPannel\GUIPannel.mqh"
   CGUIPannel m_GUIPannel;
#endif // __EACONFIGURATION_MQH__
