//+------------------------------------------------------------------+
//|                                              IndicatorSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Replaces struct SJsonIndicatorEntry (formerly in JSONConfig.mqh, since removed) with a |
//| class - see Implementaion Plan\ImplementaionClassForSetting.md for the full discussion.|
//| 1 instance = 1 indicator (config row) - held in CIndicatorTemplateManager's list.       |
//+------------------------------------------------------------------+
#ifndef __INDICATORSETTING_MQH__
#define __INDICATORSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib\Base\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib\Services\DELib\TimeseriesDELib.mqh>

 #ifndef CINDICATORSETTING_MQH_DECLARATION
 #define CINDICATORSETTING_MQH_DECLARATION
 //+------------------------------------------------------------------------------------+
 //| CIndicatorSetting - 1 indicator's config row, replaces struct SJsonIndicatorEntry.  |
 //| CBaseObj (not CBaseObjExt) - static config row, no INC/DEC/LEVEL threshold          |
 //| tracking needed (ImplementaionClassForSetting.md muc 3).                            |
 //+------------------------------------------------------------------------------------+
 class CIndicatorSetting : public CBaseObj
   {
     private:
       ENUM_INDICATOR  m_type_enum;           // real enum value - IDENTITY (SOLE source of truth -
                                               // no stored text mirror; both display and JSON text
                                               // are derived on demand from this + m_raw_params below)
       MqlParam        m_raw_params[];        // real params - IDENTITY + input straight for Layer 1
       bool            m_buy_signal;          // opt-in: count this indicator's Buy cross into the Signal Bridge
       bool            m_sell_signal;         // opt-in: count this indicator's Sell cross into the Signal Bridge
       bool            m_sound_alert;
       bool            m_message_alert;
       bool            m_show_on_chart;       // preference: default shown on a new chart - PureData, Layer 2 mirrors it

       //--- shared enum-choice decode loop for DisplayLabel/JsonParamsText - same schema-based
       //--- decode BuildIndicatorTextLabel/BuildIndicatorParamsText (TimeseriesDELib.mqh) used to
       //--- do from outside; only the rounding precision differs between the two callers.
       void            ParamTexts(const int decimals, string &out[]) const;

     public:
                         CIndicatorSetting(void);
                        ~CIndicatorSetting(void) {}

      //--- identity (raw) - the ONLY thing used for matching, never text
       ENUM_INDICATOR    TypeEnum(void)                          const { return m_type_enum; }
       void              TypeEnum(const ENUM_INDICATOR type)           { m_type_enum = type;  }
       void              GetRawParams(MqlParam &out[])            const;
       void              SetRawParams(MqlParam &params[]);
       bool              MatchesIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const;

       //--- display label (Table col 0 + Message Alert - SAME text both already use, GUIPannel_
       //--- SoundAndMessageAlerts.mqh:118 and the old UpdateRow_IndicatorTemplateSetting both called
       //--- BuildIndicatorTextLabel() fresh, never stored it - computed here, not cached, rounds
       //--- doubles to 2 decimals (display-only - JSON save needs full precision, see
       //--- JsonParamsText below). Self-contained (Anhnt, 2026-08-30) - no longer calls the
       //--- Library's BuildIndicatorTextLabel(), builds straight off m_type_enum/m_raw_params via
       //--- the private ParamTexts() helper shared with JsonParamsText (same decode, different
       //--- rounding precision).
       string            DisplayLabel(void) const;
       //--- full-precision per-param text for JSON persistence (was BuildIndicatorParamsText());
       //--- same enum-choice decode as DisplayLabel, just 8 decimals instead of 2 - see
       //--- CIndicatorTemplateManager::BuildJsonSection.
       void              JsonParamsText(string &out[]) const;

       //--- toggles - mirror table columns 2/3/5/6 directly
       bool              BuySignal(void)      const { return m_buy_signal;    }
       void              BuySignal(const bool v)    { m_buy_signal = v;       }
       bool              SellSignal(void)     const { return m_sell_signal;   }
       void              SellSignal(const bool v)   { m_sell_signal = v;      }
       bool              SoundAlert(void)     const { return m_sound_alert;   }
       void              SoundAlert(const bool v)   { m_sound_alert = v;      }
       bool              MessageAlert(void)   const { return m_message_alert; }
       void              MessageAlert(const bool v) { m_message_alert = v;    }

       //--- preference - default shown on chart; NOT the live "is it actually on THIS chart
       //--- right now" state (that stays resolved live via chart scan to avoid staleness)
       bool              ShowOnChart(void)     const { return m_show_on_chart; }
       void              ShowOnChart(const bool v)   { m_show_on_chart = v;    }

       virtual void      Print(const bool full_prop=false, const bool dash=false);
   };
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CIndicatorSetting::CIndicatorSetting(void) : m_type_enum(IND_CUSTOM),
                                               m_buy_signal(true), m_sell_signal(true),
                                               m_sound_alert(true), m_message_alert(true),
                                               m_show_on_chart(true)
   {
     this.m_type = OBJECT_DE_TYPE_INDICATOR_SETTING;
   }
 //+------------------------------------------------------------------+
 //| Copy out the raw params (identity + Layer 1 input)                |
 //+------------------------------------------------------------------+
 void CIndicatorSetting::GetRawParams(MqlParam &out[]) const
   {
     int total = ::ArraySize(m_raw_params);
     ::ArrayResize(out, total);
     for(int i = 0; i < total; i++)
        out[i] = m_raw_params[i];
   }
 //+------------------------------------------------------------------+
 //| Replace the raw params                                            |
 //+------------------------------------------------------------------+
 void CIndicatorSetting::SetRawParams(MqlParam &params[])
   {
     int total = ::ArraySize(params);
     ::ArrayResize(m_raw_params, total);
     for(int i = 0; i < total; i++)
        m_raw_params[i] = params[i];
   }
 //+------------------------------------------------------------------+
 //| Identity match - same RAW style TemplateBuySellFor/                |
 //| IsIndicatorInTemplateSetting already use (type + IsEqualMqlParamArrays). Copies |
 //| m_raw_params out first - IsEqualMqlParamArrays takes non-const references, and  |
 //| every member is implicitly const inside a const method.                        |
 //+------------------------------------------------------------------+
 bool CIndicatorSetting::MatchesIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const
   {
     if(m_type_enum != type) return false;
     MqlParam raw[];
     GetRawParams(raw);
     return IsEqualMqlParamArrays(raw, params);
   }
 //+------------------------------------------------------------------+
 //| Shared per-param text decode - schema-typed params (Applied      |
 //| Price/MA Method/Applied Volume/Stoch Price) resolve to their      |
 //| description text; everything else is just DoubleToString/         |
 //| IntegerToString at the caller's requested precision. Same         |
 //| decode BuildIndicatorTextLabel/BuildIndicatorParamsText used to    |
 //| do from outside (TimeseriesDELib.mqh) - ported in directly since   |
 //| m_type_enum/m_raw_params are already right here (Anhnt, 2026-08-30). |
 //+------------------------------------------------------------------+
 void CIndicatorSetting::ParamTexts(const int decimals, string &out[]) const
   {
     SIndicatorParam schema[];
     GetIndicatorParamSchema(m_type_enum, schema);
     int total = ArraySize(m_raw_params);
     ArrayResize(out, total);
     for(int p = 0; p < total; p++)
      {
       string choices = (p < ArraySize(schema)) ? schema[p].choices : "";
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
 //+------------------------------------------------------------------+
 //| Human-readable label (2-decimal rounded) - Table col 0 + Message  |
 //| Alert share this exact computation, see the declaration comment.  |
 //+------------------------------------------------------------------+
 string CIndicatorSetting::DisplayLabel(void) const
   {
     // --- Same catalog-name-first-then-fallback lookup BuildJsonSection (IndicatorTemplateManager.mqh)
     // --- already inlines for its type_key - kept consistent with what JSON persists as
     // --- "m_indicator_type", not switched to IndicatorTypeDescription()'s raw enum-suffix text.
     SIndicatorCatalogItem catalog[];
     GetIndicatorCatalog(catalog);
     string short_name = "";
     for(int c = 0; c < ArraySize(catalog); c++)
       if(catalog[c].ind_type == m_type_enum) { short_name = catalog[c].name; break; }
     if(short_name == "") short_name = IndicatorTypeDescription(m_type_enum);
     string vals[];
     ParamTexts(2, vals);
     string pvalues = "";
     for(int i = 0; i < ArraySize(vals); i++)
      {
       if(i > 0) pvalues += ", ";
       pvalues += vals[i];
      }
     return short_name + (pvalues != "" ? "  (" + pvalues + ")" : "");
   }
 //+------------------------------------------------------------------+
 //| Full-precision per-param text for JSON persistence (was the free  |
 //| BuildIndicatorParamsText()) - see the declaration comment.        |
 //+------------------------------------------------------------------+
 void CIndicatorSetting::JsonParamsText(string &out[]) const
   {
     ParamTexts(8, out);
   }
 //+------------------------------------------------------------------+
 //| Debug dump                                                        |
 //+------------------------------------------------------------------+
 void CIndicatorSetting::Print(const bool full_prop=false, const bool dash=false)
   {
     ::Print((dash ? " - " : ""), "CIndicatorSetting::Print label=", DisplayLabel(),
             " buy=", m_buy_signal, " sell=", m_sell_signal, " sound=", m_sound_alert,
             " message=", m_message_alert, " show=", m_show_on_chart);
   }
 #endif // CINDICATORSETTING_MQH_DECLARATION
#endif // __INDICATORSETTING_MQH__
