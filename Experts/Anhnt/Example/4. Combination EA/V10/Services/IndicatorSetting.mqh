//+------------------------------------------------------------------+
//|                                              IndicatorSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Replaces struct SJsonIndicatorEntry (Anatoli Kazharski\JSONConfig.mqh) with a class -  |
//| see Implementaion Plan\ImplementaionClassForSetting.md for the full discussion.        |
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
       string          m_indicator_type;      // display text (catalog name) - JSON + table label
       string          m_indicator_params[];  // display text per schema, full precision
       ENUM_INDICATOR  m_type_enum;           // real enum value - IDENTITY
       MqlParam        m_raw_params[];        // real params - IDENTITY + input straight for Layer 1
       bool            m_buy_signal;          // opt-in: count this indicator's Buy cross into the Signal Bridge
       bool            m_sell_signal;         // opt-in: count this indicator's Sell cross into the Signal Bridge
       bool            m_sound_alert;
       bool            m_message_alert;
       bool            m_show_on_chart;       // preference: default shown on a new chart - PureData, Layer 2 mirrors it

     public:
                         CIndicatorSetting(void);
                        ~CIndicatorSetting(void) {}

      //--- identity (raw) - the ONLY thing used for matching, never text
       ENUM_INDICATOR    TypeEnum(void)                          const { return m_type_enum; }
       void              TypeEnum(const ENUM_INDICATOR type)           { m_type_enum = type;  }
       void              GetRawParams(MqlParam &out[])            const;
       void              SetRawParams(MqlParam &params[]);
       bool              MatchesIdentity(const ENUM_INDICATOR type, MqlParam &params[]) const;
      //--- save text (JSON round-trip, FULL precision - 8 decimals)
       string            TypeText(void)                          const { return m_indicator_type; }
       void              TypeText(const string type)                   { m_indicator_type = type; }
       void              GetParamsText(string &out[])              const;
       void              SetParamsText(string &params[]);

       //--- display label (Table col 0 + Message Alert - SAME text both already use, GUIPannel_
       //--- SoundAndMessageAlerts.mqh:118 and the old UpdateRow_IndicatorTemplateSetting both called
       //--- BuildIndicatorTextLabel() fresh, never stored it - computed here, not cached, rounds
       //--- doubles to 2 decimals (display-only; JSON save always uses TypeText()/GetParamsText()
       //--- above, full precision - never mix the two).
       string            DisplayLabel(void) const;

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
 //| Copy out the display-text params                                  |
 //+------------------------------------------------------------------+
 void CIndicatorSetting::GetParamsText(string &out[]) const
   {
     int total = ::ArraySize(m_indicator_params);
     ::ArrayResize(out, total);
     for(int i = 0; i < total; i++)
        out[i] = m_indicator_params[i];
   }
 //+------------------------------------------------------------------+
 //| Replace the display-text params                                   |
 //+------------------------------------------------------------------+
 void CIndicatorSetting::SetParamsText(string &params[])
   {
     int total = ::ArraySize(params);
     ::ArrayResize(m_indicator_params, total);
     for(int i = 0; i < total; i++)
        m_indicator_params[i] = params[i];
   }
 //+------------------------------------------------------------------+
 //| Human-readable label (2-decimal rounded) - Table col 0 + Message  |
 //| Alert share this exact computation, see the declaration comment.  |
 //+------------------------------------------------------------------+
 string CIndicatorSetting::DisplayLabel(void) const
   {
     SIndicatorCatalogItem catalog[];
     GetIndicatorCatalog(catalog);
     MqlParam params[];
     GetRawParams(params);
     return BuildIndicatorTextLabel(m_type_enum, params, catalog);
   }
 //+------------------------------------------------------------------+
 //| Debug dump                                                        |
 //+------------------------------------------------------------------+
 void CIndicatorSetting::Print(const bool full_prop=false, const bool dash=false)
   {
     ::Print((dash ? " - " : ""), "CIndicatorSetting::Print type=", m_indicator_type,
             " buy=", m_buy_signal, " sell=", m_sell_signal, " sound=", m_sound_alert,
             " message=", m_message_alert, " show=", m_show_on_chart);
   }
 #endif // CINDICATORSETTING_MQH_DECLARATION
#endif // __INDICATORSETTING_MQH__
