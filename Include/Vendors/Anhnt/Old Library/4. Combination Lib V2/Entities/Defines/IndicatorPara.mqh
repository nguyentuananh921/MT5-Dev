//+------------------------------------------------------------------+
//|                                             IndicatorPara.mqh    |
//|     Defines for working with indicator parameters                |
//+------------------------------------------------------------------+
#ifndef CINDICATORPARA_MQH
#define CINDICATORPARA_MQH  
  #define INDICATOR_PARAM_SLOTS_MAX 8
  //To Display on Combobox
   #define CALCULATION_METHOD_CHOICES "SMA|EMA|SMMA|LWMA"
   #define PRICE_CHOICES  "Close|Open|High|Low|Median|Typical|WClose"
   #define STOCH_PRICE_CHOICES "Low/High|Close/Close"
   #define VOLUME_CHOICES "Tick|Real"
  // --- Named param-slot indices for GetIndicatorGuiLayout() (Tang 2 GUI layer).
  // --- Values MUST mirror the index order in GetIndicatorParamSchema() for the
  // --- same type - co-located here so a schema reorder forces a review of the
  // --- matching enum in the same file.
   enum ENUM_MA_PARAM            { MA_PERIOD = 0, MA_SHIFT, MA_METHOD, MA_APPLIED_PRICE };  // shape also shared by IND_STDDEV
   enum ENUM_ICHIMOKU_PARAM      { ICHIMOKU_TENKAN = 0, ICHIMOKU_KIJUN, ICHIMOKU_SENKOU_B };
   enum ENUM_SAR_PARAM           { SAR_STEP = 0, SAR_MAXIMUM };
   enum ENUM_BANDS_PARAM         { BANDS_PERIOD = 0, BANDS_SHIFT, BANDS_DEVIATION, BANDS_APPLIED_PRICE };
  // --- Jaw/Teeth/Lips period+shift pairs + Method + Applied Price - identical
  // --- 8-param shape for both Alligator and Gator Oscillator.
   enum ENUM_JAW_TEETH_LIPS_PARAM
    {
     JTL_JAW_PERIOD = 0, JTL_JAW_SHIFT, JTL_TEETH_PERIOD, JTL_TEETH_SHIFT,
     JTL_LIPS_PERIOD, JTL_LIPS_SHIFT, JTL_METHOD, JTL_APPLIED_PRICE
    };
   enum ENUM_ENVELOPES_PARAM      
    { 
     ENVELOPES_PERIOD = 0, ENVELOPES_SHIFT,ENVELOPES_METHOD, 
     ENVELOPES_APPLIED_PRICE, ENVELOPES_DEVIATION_PCT 
    };
  // --- Period + Shift + Applied Price - shape shared by FRAMA, DEMA, TEMA.
   enum ENUM_PERIOD_SHIFT_PRICE_PARAM { PSP_PERIOD = 0, PSP_SHIFT, PSP_APPLIED_PRICE };
   enum ENUM_AMA_PARAM           { AMA_PERIOD = 0, AMA_FAST_EMA_PERIOD, AMA_SLOW_EMA_PERIOD, AMA_SHIFT, AMA_APPLIED_PRICE };
   enum ENUM_VIDYA_PARAM         { VIDYA_CMO_PERIOD = 0, VIDYA_EMA_PERIOD, VIDYA_SHIFT, VIDYA_APPLIED_PRICE };
  // --- Period + Applied Price - shape shared by RSI, CCI, Momentum.
   enum ENUM_PERIOD_PRICE_PARAM  { PP_PERIOD = 0, PP_APPLIED_PRICE };
  // --- Fast/Slow EMA + Signal + Applied Price - shape shared by MACD, OsMA.
   enum ENUM_EMA_SIGNAL_PRICE_PARAM { ESP_FAST_EMA = 0, ESP_SLOW_EMA, ESP_SIGNAL, ESP_APPLIED_PRICE };
   enum ENUM_STOCHASTIC_PARAM    { STOCH_K_PERIOD = 0, STOCH_D_PERIOD, STOCH_SLOWING, STOCH_METHOD, STOCH_PRICE_FIELD };
   enum ENUM_FORCE_PARAM         { FORCE_PERIOD = 0, FORCE_METHOD, FORCE_APPLIED_VOLUME };
   enum ENUM_CHAIKIN_PARAM       { CHAIKIN_FAST_MA_PERIOD = 0, CHAIKIN_SLOW_MA_PERIOD, CHAIKIN_METHOD, CHAIKIN_APPLIED_VOLUME };
#endif // CINDICATORPARA_MQH
