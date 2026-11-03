//+------------------------------------------------------------------+
//|                                        BarInformationSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = 1 row of Setting_BarInformation (a type of the      |
//| information of a bar) and its rows of Setting_BarSetup (its      |
//| parameters)                                                      |
//+------------------------------------------------------------------+
//--- Change from V3 Entities\Settings\PatternSetting.mqh: renamed CPatternSetting -> CBarInformationSetting (every type of Setting_BarInformation, not only
//--- the candle patterns); Show Buy / Show Sell instead of Buy / Sell, the group and the parameters of the type are kept here
#ifndef __BARINFORMATIONSETTING_MQH__
#define __BARINFORMATIONSETTING_MQH__
 #include "..\Bases\BaseObj.mqh"
 #include "..\Defines\BarDefines.mqh"
 #include "..\Defines\EventDefines.mqh"
#ifndef CBARINFORMATIONSETTING_MQH_DECLARATION
#define CBARINFORMATIONSETTING_MQH_DECLARATION
 class CBarInformationSetting : public CBaseObj
  {
    private:
     ENUM_BAR_INFOR_TYPE        m_type_infor;      // identity
     ENUM_BAR_INFORMATION_GROUP m_group;
     int                        m_candles;         // how many candles make it
     bool                       m_has_buy;         // it can be Bullish
     bool                       m_has_sell;        // it can be Bearish
     bool                       m_sound_alert;
     bool                       m_message_alert;
     bool                       m_show_buy;        // its Buy markers are shown on the chart
     bool                       m_show_sell;
     string                     m_params[];        // its parameters (Setting_BarSetup), in the order of the table
     string                     m_displays[];
     double                     m_values[];
    public:
                                CBarInformationSetting(const ENUM_BAR_INFOR_TYPE type,const string name,const ENUM_BAR_INFORMATION_GROUP group,const int candles,const bool has_buy,const bool has_sell);
                               ~CBarInformationSetting(void) {}
     ENUM_BAR_INFOR_TYPE        TypeInfor(void)       const { return m_type_infor;    }
     string                     Name(void)            const { return m_name;          }
     ENUM_BAR_INFORMATION_GROUP Group(void)           const { return m_group;         }
     int                        Candles(void)         const { return m_candles;       }
     bool                       HasBuy(void)          const { return m_has_buy;       }
     bool                       HasSell(void)         const { return m_has_sell;      }
     bool                       SoundAlert(void)      const { return m_sound_alert;   }
     void                       SoundAlert(const bool v)    { m_sound_alert = v;      }
     bool                       MessageAlert(void)    const { return m_message_alert; }
     void                       MessageAlert(const bool v)  { m_message_alert = v;    }
   //--- Show Buy / Show Sell fire BAR_INFORMATION_MANAGER_EVENT_SHOW_CHANGED when they change, unless notify is false
     bool                       ShowBuy(void)         const { return m_show_buy;      }
     void                       ShowBuy(const bool v,const bool notify=true);
     bool                       ShowSell(void)        const { return m_show_sell;     }
     void                       ShowSell(const bool v,const bool notify=true);
   //--- The parameters: (1) one more (SyncDataFromDB), (2) all of them, (3) the value of one; setting it fires BAR_INFORMATION_MANAGER_EVENT_SETUP_CHANGED
     void                       AddParam(const string param,const string display,const double value);
     int                        Params(string &params[],string &displays[],double &values[]) const;
     bool                       ParamValue(const string param,double &value) const;
     bool                       ParamValue(const string param,const double value);
  };
#endif // CBARINFORMATIONSETTING_MQH_DECLARATION
#ifndef CBARINFORMATIONSETTING_MQH_IMPLEMENTATION
#define CBARINFORMATIONSETTING_MQH_IMPLEMENTATION
 CBarInformationSetting::CBarInformationSetting(const ENUM_BAR_INFOR_TYPE type,const string name,const ENUM_BAR_INFORMATION_GROUP group,const int candles,const bool has_buy,const bool has_sell) :
                                                m_type_infor(type),m_group(group),m_candles(candles),m_has_buy(has_buy),m_has_sell(has_sell),
                                                m_sound_alert(true),m_message_alert(true),m_show_buy(has_buy),m_show_sell(has_sell)
  {
   this.m_object_type=OBJECT_DE_TYPE_BAR_INFORMATION_SETTING;
   this.m_name=name;   // the name Python and the user call it
  }
 //--- The event: lparam = the type_infor
 void CBarInformationSetting::ShowBuy(const bool v,const bool notify=true)
  {
   if(m_show_buy == v)
      return;
   m_show_buy = v;
   if(notify)
      ::EventChartCustom(::ChartID(), (ushort)BAR_INFORMATION_MANAGER_EVENT_SHOW_CHANGED, (long)m_type_infor, 0.0, "");
  }
 void CBarInformationSetting::ShowSell(const bool v,const bool notify=true)
  {
   if(m_show_sell == v)
      return;
   m_show_sell = v;
   if(notify)
      ::EventChartCustom(::ChartID(), (ushort)BAR_INFORMATION_MANAGER_EVENT_SHOW_CHANGED, (long)m_type_infor, 0.0, "");
  }
 void CBarInformationSetting::AddParam(const string param,const string display,const double value)
  {
   int total = ::ArraySize(m_params);
   ::ArrayResize(m_params, total + 1);
   ::ArrayResize(m_displays, total + 1);
   ::ArrayResize(m_values, total + 1);
   m_params[total]   = param;
   m_displays[total] = display;
   m_values[total]   = value;
  }
 int CBarInformationSetting::Params(string &params[],string &displays[],double &values[]) const
  {
   int total = ::ArraySize(m_params);
   ::ArrayResize(params, total);
   ::ArrayResize(displays, total);
   ::ArrayResize(values, total);
   for(int i = 0; i < total; i++)
     {
      params[i]   = m_params[i];
      displays[i] = m_displays[i];
      values[i]   = m_values[i];
     }
   return total;
  }
 bool CBarInformationSetting::ParamValue(const string param,double &value) const
  {
   for(int i = 0; i < ::ArraySize(m_params); i++)
      if(m_params[i] == param)
        {
         value = m_values[i];
         return true;
        }
   return false;
  }
 bool CBarInformationSetting::ParamValue(const string param,const double value)
  {
   for(int i = 0; i < ::ArraySize(m_params); i++)
      if(m_params[i] == param)
        {
         if(m_values[i] != value)
           {
            m_values[i] = value;
            ::EventChartCustom(::ChartID(), (ushort)BAR_INFORMATION_MANAGER_EVENT_SETUP_CHANGED, (long)m_type_infor, 0.0, "");
           }
         return true;
        }
   return false;
  }
#endif // CBARINFORMATIONSETTING_MQH_IMPLEMENTATION
#endif // __BARINFORMATIONSETTING_MQH__
