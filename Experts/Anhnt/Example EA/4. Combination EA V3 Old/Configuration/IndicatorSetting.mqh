//+------------------------------------------------------------------+
//|                                              IndicatorSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = 1 indicator template row of "Indicator_Templates"   |
//+------------------------------------------------------------------+
#ifndef __INDICATORSETTING_MQH__
#define __INDICATORSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\EventDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\DELib\CommonDELib.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\DELib\TimeseriesDELib.mqh>

#ifndef CINDICATORSETTING_MQH_DECLARATION
#define CINDICATORSETTING_MQH_DECLARATION
 class CIndicatorSetting : public CBaseObj
  {
    private:
     ENUM_INDICATOR  m_type_enum;           // identity, together with m_raw_params
     MqlParam        m_raw_params[];
     bool            m_buy_signal;
     bool            m_sell_signal;
     bool            m_sound_alert;
     bool            m_message_alert;
     bool            m_show_on_chart;       // the indicator is attached to the chart; the chart side can change it too
    public:
                     CIndicatorSetting(void);
                    ~CIndicatorSetting(void) {}
     ENUM_INDICATOR  TypeEnum(void)                 const { return m_type_enum; }
     void            TypeEnum(const ENUM_INDICATOR type)   { m_type_enum = type; }
     void            GetRawParams(MqlParam &out[])  const;
     void            SetRawParams(MqlParam &params[]);
   //--- Every param as text: Applied Price / Method / Volume / Stoch price by description, numbers with `decimals`
     void            ParamTexts(const int decimals, string &out[]) const;
     string          DisplayLabel(void)             const;
     void            JSONParamsText(string &out[])  const { ParamTexts(8, out); }
   //--- Buy / Sell fire INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED when they change, unless notify is false
     bool            BuySignal(void)      const { return m_buy_signal;    }
     void            BuySignal(const bool v,const bool notify=true,const int position=-1);
     bool            SellSignal(void)     const { return m_sell_signal;   }
     void            SellSignal(const bool v,const bool notify=true,const int position=-1);
     bool            SoundAlert(void)     const { return m_sound_alert;   }
     void            SoundAlert(const bool v)   { m_sound_alert = v;      }
     bool            MessageAlert(void)   const { return m_message_alert; }
     void            MessageAlert(const bool v) { m_message_alert = v;    }
     bool            ShowOnChart(void)    const { return m_show_on_chart; }
     void            ShowOnChart(const bool v)  { m_show_on_chart = v;    }
     virtual void    Print(const bool full_prop=false, const bool dash=false);
  };
#endif // CINDICATORSETTING_MQH_DECLARATION

#ifndef CINDICATORSETTING_MQH_IMPLEMENTATION
#define CINDICATORSETTING_MQH_IMPLEMENTATION
 CIndicatorSetting::CIndicatorSetting(void) : m_type_enum(IND_CUSTOM),
                                              m_buy_signal(true), m_sell_signal(true),
                                              m_sound_alert(true), m_message_alert(true),
                                              m_show_on_chart(true)
  {
   this.m_type = OBJECT_DE_TYPE_INDICATOR_SETTING;
  }
 void CIndicatorSetting::BuySignal(const bool v,const bool notify=true,const int position=-1)
  {
   if(m_buy_signal == v)
      return;
   m_buy_signal = v;
   if(notify)
      ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED, (long)position, 0.0, "");
  }
 void CIndicatorSetting::SellSignal(const bool v,const bool notify=true,const int position=-1)
  {
   if(m_sell_signal == v)
      return;
   m_sell_signal = v;
   if(notify)
      ::EventChartCustom(::ChartID(), (ushort)INDICATOR_TEMPLATE_MANAGER_EVENT_BUYSELL_CHANGED, (long)position, 0.0, "");
  }
 void CIndicatorSetting::GetRawParams(MqlParam &out[]) const
  {
   int total = ::ArraySize(m_raw_params);
   ::ArrayResize(out, total);
   for(int i = 0; i < total; i++)
      out[i] = m_raw_params[i];
  }
 void CIndicatorSetting::SetRawParams(MqlParam &params[])
  {
   int total = ::ArraySize(params);
   ::ArrayResize(m_raw_params, total);
   for(int i = 0; i < total; i++)
      m_raw_params[i] = params[i];
  }
 void CIndicatorSetting::ParamTexts(const int decimals, string &out[]) const
  {
   SIndicatorParam schema[];
   GetIndicatorParamSchema(m_type_enum, schema);
   int total = ::ArraySize(m_raw_params);
   ::ArrayResize(out, total);
   for(int p = 0; p < total; p++)
    {
     string choices = (p < ::ArraySize(schema)) ? schema[p].choices : "";
     if(choices == PRICE_CHOICES)
        out[p] = AppliedPriceDescription((ENUM_APPLIED_PRICE)m_raw_params[p].integer_value);
     else if(choices == CALCULATION_METHOD_CHOICES)
        out[p] = AveragingMethodDescription((ENUM_MA_METHOD)m_raw_params[p].integer_value);
     else if(choices == VOLUME_CHOICES)
        out[p] = AppliedVolumeDescription((ENUM_APPLIED_VOLUME)m_raw_params[p].integer_value);
     else if(choices == STOCH_PRICE_CHOICES)
        out[p] = StochPriceDescription((ENUM_STO_PRICE)m_raw_params[p].integer_value);
     else if(m_raw_params[p].type == TYPE_DOUBLE)
        out[p] = ::DoubleToString(m_raw_params[p].double_value, decimals);
     else
        out[p] = ::IntegerToString((int)m_raw_params[p].integer_value);
    }
  }
 string CIndicatorSetting::DisplayLabel(void) const
  {
   string short_name = GetIndicatorNameForType(m_type_enum);
   if(short_name == "")
      short_name = IndicatorTypeDescription(m_type_enum);
   string vals[];
   ParamTexts(2, vals);
   string pvalues = "";
   for(int i = 0; i < ::ArraySize(vals); i++)
      pvalues += (i > 0 ? ", " : "") + vals[i];
   return short_name + (pvalues != "" ? "  (" + pvalues + ")" : "");
  }
 void CIndicatorSetting::Print(const bool full_prop=false, const bool dash=false)
  {
   ::Print((dash ? " - " : ""), "CIndicatorSetting::Print label=", DisplayLabel(),
           " buy=", m_buy_signal, " sell=", m_sell_signal, " sound=", m_sound_alert, " message=", m_message_alert, " show=", m_show_on_chart);
  }
#endif // CINDICATORSETTING_MQH_IMPLEMENTATION
#endif // __INDICATORSETTING_MQH__
