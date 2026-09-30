//+------------------------------------------------------------------+
//|                                                 CompileCheck.mq5 |
//| Compile-only check for 4. Combination Lib V2 - not for running.  |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Bases\BaseObjExt.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Bar.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\SwingSetting.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Services\DELib\TimeseriesDELib.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Services\Select\TimeseriesSelect.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\BarSwingControl\BarSwingControl.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\BarPatternsControl\BarPatternsControl.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\BarSeries\BarTimeSeriesDE.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Indicators\IndicatorDE.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Indicators\SeriesDataInd.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Signal\SignalBase.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Signal\SignalMA.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Signal\SignalSAR.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Signal\SignalBands.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Signal\SignalMACD.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Signal\SignalADX.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Signal\SignalOscillator.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Signal\SignalZeroCross.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Signal\SignalCrossover.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Timeseries\Signal\SignalFractals.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\IndicatorsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\SignalsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\BarTimeSeriesCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\SymbolsCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Collections\ChartObjCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\GBases\GElement.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Button.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Properties\Image.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Services\Keys.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Scrolls\ScrollV.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Scrolls\ScrollH.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\CheckBox.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Window.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\ButtonsGroup.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Tabs.mqh>

bool   g_suppress_del_rescan = false;
#include "..\Artyom Trishkin\TimeSeriesEngine.mqh"
#include "..\Services\SignalBridgeWriter.mqh"
#include "..\Artyom Trishkin\TradingEngine.mqh"

int OnInit(void)
  {
   return INIT_SUCCEEDED;
  }
void OnTick(void)
  {
  }
