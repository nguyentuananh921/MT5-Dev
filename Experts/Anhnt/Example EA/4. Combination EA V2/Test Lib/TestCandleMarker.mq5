//+------------------------------------------------------------------+
//|                                              TestCandleMarker.mq5 |
//| CCandleMarker on eight recent candles: one per icon (Indicator,   |
//| Candle, SMC) on both sides, plus two candles with two sources     |
//| (the combination icon). Check: blue badge below a Buy candle,     |
//| red above a Sell one, the icon stays readable on both colors, the |
//| text is not cut, the badge keeps its candle on scroll/zoom, the   |
//| cursor on a badge draws the box around the candle and prints one  |
//| MY DEBUG line (the panel would open its window there)             |
//+------------------------------------------------------------------+
#property version "2.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Graph\Composite\CandleMarker.mqh>

#define MARKER_TOTAL 8
CCandleMarker g_marker[MARKER_TOTAL];

int OnInit(void)
  {
   int    shift[MARKER_TOTAL]  ={4,8,12,16,20,24,28,32};
   string text[MARKER_TOTAL]   ={"BB Up","RSI Down","Hammer","Shooting Star","HL","LH","BOS+Hammer","BB+CHoCH"};
   bool   is_buy[MARKER_TOTAL] ={true,false,true,false,true,false,true,false};
   int    src[MARKER_TOTAL]    ={CANDLE_MARKER_SOURCE_INDICATOR,CANDLE_MARKER_SOURCE_INDICATOR,
                                 CANDLE_MARKER_SOURCE_CANDLE,CANDLE_MARKER_SOURCE_CANDLE,
                                 CANDLE_MARKER_SOURCE_SMC,CANDLE_MARKER_SOURCE_SMC,
                                 CANDLE_MARKER_SOURCE_SMC|CANDLE_MARKER_SOURCE_CANDLE,
                                 CANDLE_MARKER_SOURCE_INDICATOR|CANDLE_MARKER_SOURCE_SMC};
   for(int i=0; i<MARKER_TOTAL; i++)
     {
      if(!g_marker[i].Create(::ChartID(),0,"TestCandleMarker_"+(string)i))
        {
         ::Print("MY DEBUG TestCandleMarker::OnInit: marker ",i," create failed, error ",::GetLastError());
         return INIT_FAILED;
        }
      g_marker[i].SetMarker(::iTime(_Symbol,_Period,shift[i]),::iHigh(_Symbol,_Period,shift[i]),::iLow(_Symbol,_Period,shift[i]),
                            is_buy[i],(is_buy[i] ? clrDodgerBlue : clrCrimson),src[i]);
      g_marker[i].Show();
     }
   ::ChartRedraw();
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   for(int i=0; i<MARKER_TOTAL; i++)
      g_marker[i].OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CUSTOM+ON_CANDLE_MARKER_ENTER)
      ::Print("MY DEBUG TestCandleMarker::OnChartEvent: marker entered, candle=",::TimeToString((datetime)lparam,TIME_DATE|TIME_MINUTES)," badge y=",(int)dparam);
  }

void OnTick(void)
  {
  }
