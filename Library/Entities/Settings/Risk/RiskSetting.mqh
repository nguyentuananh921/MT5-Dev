//+------------------------------------------------------------------+
//|                                                  RiskSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = Setting_Risk on RAM. Change in V5 (2026-11-25): the |
//| properties as DoEasy declares them (CBar): integer / real /      |
//| string arrays indexed by ENUM_RISK_PROP_* (RiskManagementDefines),|
//| GetProperty / SetProperty. risk_property_list is the catalog, as |
//| standard_indicator_list of the indicators: a row for each input  |
//| of FixedMACrossover_Part7.mq5 (Solomon Anietie Sunday\Risk       |
//| Management\7. 24477) that is a risk setting, as the author       |
//| declared it (its input group, its type, its name, its default,   |
//| its comment), in its order = Setting_Risk.ord. CTradingControl   |
//| writes and reads the table from it. Not ported: the MA / ATR     |
//| periods (slots of the Strategy), Order Execution (the Strategy   |
//| decides the order type), inpMagicNumber (the input of the EA),   |
//| MaxSpreadPips (a filter of the example EA, not of the risk). New |
//| in V5: the group "V5" (EntryStrategies, StopLossTemplates,       |
//| TrailingTemplates)                                               |
//+------------------------------------------------------------------+
#ifndef __RISKSETTING_MQH__
#define __RISKSETTING_MQH__
 #include "..\..\Bases\BaseObj.mqh"
 #include "..\..\Defines\RiskManagementDefines.mqh"
 #include "..\..\Defines\EventDefines.mqh"
 #ifndef CRISKSETTING_MQH_DECLARATION
 #define CRISKSETTING_MQH_DECLARATION
 //--- A row of the catalog: a property and how the author declared its input (Setting_Risk.grp, type, name, the default, comment)
 struct SRiskPropertyRow
  {
   int                property;      // ENUM_RISK_PROP_INTEGER / _DOUBLE / _STRING
   string             group;         // the input group of the author
   string             type;          // bool, int, double, string or the ENUM_ of the input
   string             name;          // the name of the input: the key of the row in Setting_Risk
   double             value;         // the default (a string property: "")
   string             comment;       // the comment of the input
  };
 SRiskPropertyRow risk_property_list[] =
  {
   {RISK_PROP_RISK_MODE,                       "Risk Model",                   "ENUM_RISK_MODE",      "RiskMode",                      RISK_PERCENT,           "How risk per trade is defined"},
   {RISK_PROP_RISK_BASE,                       "Risk Model",                   "ENUM_RISK_BASE",      "RiskBase",                      RISK_BASE_BALANCE,      "Risk percentage measured against"},
   {RISK_PROP_PERCENTAGE_RISK_PER_OPERATION,   "Risk Model",                   "double",              "percentage_risk_per_operation", 1.0,                    "Risk per trade [%] (percent mode)"},
   {RISK_PROP_FIXED_CASH_RISK,                 "Risk Model",                   "double",              "FixedCashRisk",                 100.0,                  "Risk per trade [account currency] (cash mode)"},
   //--- Change in V5 (2026-11-23): no FixedLotSize (Part 7 0.10): the fixed-lot mode is the min lot of the symbol, no ApplyDrawdownToFixedLot (it cannot shrink)
   {RISK_PROP_ALLOW_MIN_LOT_OVER_RISK,         "Risk Model",                   "bool",                "AllowMinLotOverRisk",           1,                      "Trade min lot even if it exceeds intended risk"},
   {RISK_PROP_ATR_MULTIPLIER,                  "Stops and Targets",            "double",              "ATRMultiplier",                 1.5,                    "ATR multiplier for stop distance"},
   {RISK_PROP_TAKE_PROFIT_RATIO,               "Stops and Targets",            "double",              "TakeProfitRatio",               2.0,                    "Take profit ratio"},
   {RISK_PROP_ALLOW_HEDGING,                   "Stops and Targets",            "bool",                "AllowHedging",                  0,                      "Allow opposing position"},
   {RISK_PROP_ENABLE_ADAPTIVE_RISK,            "Adaptive Risk (Drawdown)",     "bool",                "EnableAdaptiveRisk",            0,                      "Reduce risk during drawdowns"},
   {RISK_PROP_DROP_DOWN_LEVEL,                 "Adaptive Risk (Drawdown)",     "double",              "DropDownLevel",                 3.0,                    "Drawdown % that triggers reduced risk"},
   {RISK_PROP_RISK_REDUCTION_FACTOR,           "Adaptive Risk (Drawdown)",     "double",              "RiskReductionFactor",           0.5,                    "Risk multiplier when triggered"},
   {RISK_PROP_MAX_MARGIN_USAGE_PERCENT,        "Broker & Margin Safety",       "double",              "MaxMarginUsagePercent",         50.0,                   "Max % of free margin one trade may use"},
   {RISK_PROP_ENABLE_ADAPTIVE_MARGIN_CAP,      "Broker & Margin Safety",       "bool",                "EnableAdaptiveMarginCap",       0,                      "Scale the cap with account margin level"},
   {RISK_PROP_MARGIN_LEVEL_SAFE,               "Broker & Margin Safety",       "double",              "MarginLevelSafe",               500.0,                  "Margin level [%] where the full cap applies"},
   {RISK_PROP_MARGIN_LEVEL_DANGER,             "Broker & Margin Safety",       "double",              "MarginLevelDanger",             150.0,                  "Margin level [%] where trades are blocked"},
   {RISK_PROP_ENABLE_BASKET_RISK,              "Basket Risk",                  "bool",                "EnableBasketRisk",              1,                      "Limit risk across this EA's positions"},
   {RISK_PROP_MAX_BASKET_LOSS_PERCENT,         "Basket Risk",                  "double",              "MaxBasketLossPercent",          3.0,                    "Close the basket at this loss % [0 = off]"},
   {RISK_PROP_BASKET_LOSS_BASE,                "Basket Risk",                  "ENUM_RISK_BASE",      "BasketLossBase",                RISK_BASE_BALANCE,      "Basket cut measured against"},
   {RISK_PROP_MAX_BASKET_MARGIN_PERCENT,       "Basket Risk",                  "double",              "MaxBasketMarginPercent",        25.0,                   "Max % of equity the basket may tie up [0 = off]"},
   {RISK_PROP_ENABLE_MAE_TRACKING,             "Basket Risk",                  "bool",                "EnableMAETracking",             1,                      "Track adverse excursion"},
   {RISK_PROP_MAX_BASKET_HOLD_BARS,            "Basket Risk",                  "int",                 "MaxBasketHoldBars",             0,                      "Close a losing basket after N bars [0 = off]"},
   {RISK_PROP_ENABLE_PORTFOLIO_RISK,           "Portfolio Risk (account-wide)","bool",                "EnablePortfolioRisk",           1,                      "Check account-wide limits before trading"},
   {RISK_PROP_PORTFOLIO_SCOPE,                 "Portfolio Risk (account-wide)","ENUM_PORTFOLIO_SCOPE","PortfolioScope",                PORTFOLIO_ACCOUNT_WIDE, "What counts as the portfolio"},
   {RISK_PROP_EXTRA_PORTFOLIO_MAGICS,          "Portfolio Risk (account-wide)","string",              "ExtraPortfolioMagics",          0,                      "Extra magic numbers, comma-separated"},
   {RISK_PROP_MAX_PORTFOLIO_POSITIONS,         "Portfolio Risk (account-wide)","int",                 "MaxPortfolioPositions",         6,                      "Max positions portfolio-wide [0 = off]"},
   {RISK_PROP_MAX_POSITIONS_PER_SYMBOL,        "Portfolio Risk (account-wide)","int",                 "MaxPositionsPerSymbol",         2,                      "Max positions on one symbol [0 = off]"},
   {RISK_PROP_MAX_PORTFOLIO_SYMBOLS,           "Portfolio Risk (account-wide)","int",                 "MaxPortfolioSymbols",           4,                      "Max distinct symbols at once [0 = off]"},
   {RISK_PROP_MAX_PORTFOLIO_MARGIN_PERCENT,    "Portfolio Risk (account-wide)","double",              "MaxPortfolioMarginPercent",     40.0,                   "Max % of equity in margin [0 = off]"},
   {RISK_PROP_MAX_PORTFOLIO_LOSS_PERCENT,      "Portfolio Risk (account-wide)","double",              "MaxPortfolioLossPercent",       6.0,                    "Block new trades past this loss % [0 = off]"},
   {RISK_PROP_MAX_NET_CURRENCY_LOTS,           "Portfolio Risk (account-wide)","double",              "MaxNetCurrencyLots",            2.0,                    "Max net lots per currency [0 = off]"},
   {RISK_PROP_LOG_PORTFOLIO_SNAPSHOT,          "Portfolio Risk (account-wide)","bool",                "LogPortfolioSnapshot",          0,                      "Log the portfolio picture every bar"},
   //--- New in V5 (many strategies, chosen by the user on the Trading tab, Auto): the strategies that trade (CTradingControl uses it; not trading_enabled
   //--- of Setting_Strategy: that one makes the templates of the slots), the bases (Setting_IndicatorTemplate.id) that give the stop / the trailing
   {RISK_PROP_ENTRY_STRATEGIES,                "V5",                           "string",              "EntryStrategies",               0,                      "Setting_Strategy.strategy_id of the strategies that take part in trading, comma-separated"},
   {RISK_PROP_STOP_LOSS_TEMPLATES,             "V5",                           "string",              "StopLossTemplates",             0,                      "Bases that give the stop loss, comma-separated: PSAR its price, ATR x ATRMultiplier; the nearest valid stop wins"},
   {RISK_PROP_TRAILING_TEMPLATES,              "V5",                           "string",              "TrailingTemplates",             0,                      "Bases that trail the stop, comma-separated: the best price wins"}
  };
  class CRiskSetting : public CBaseObj
   {
     private:
      long                       m_long_prop[RISK_PROP_INTEGER_TOTAL];    // Integer properties
      double                     m_double_prop[RISK_PROP_DOUBLE_TOTAL];   // Real properties
      string                     m_string_prop[RISK_PROP_STRING_TOTAL];   // String properties
      int                        IndexProp(ENUM_RISK_PROP_DOUBLE property)   const { return (int)property-RISK_PROP_INTEGER_TOTAL;                         }
      int                        IndexProp(ENUM_RISK_PROP_STRING property)   const { return (int)property-RISK_PROP_INTEGER_TOTAL-RISK_PROP_DOUBLE_TOTAL;  }
      int                        Row(const int property) const;           // the row of a property in risk_property_list (WRONG_VALUE: none)
     public:
                                 CRiskSetting(void);
                                ~CRiskSetting(void) {}
    //--- The properties (DoEasy). SetProperty fires RISK_SETTING_EVENT_CHANGED (lparam = save_now, dparam = the value, sparam = the name of the
    //--- input) when it changes, unless notify is false. save_now: the owner of the table writes it at once (the Risk Management tab); false:
    //--- working on RAM, written at OnDeinit (the Trading tab). The same value with save_now: fired too (the RAM value is saved)
      bool                       SetProperty(ENUM_RISK_PROP_INTEGER property,long value,const bool notify=true,const bool save_now=false);
      bool                       SetProperty(ENUM_RISK_PROP_DOUBLE property,double value,const bool notify=true,const bool save_now=false);
      bool                       SetProperty(ENUM_RISK_PROP_STRING property,string value,const bool notify=true,const bool save_now=false);
      long                       GetProperty(ENUM_RISK_PROP_INTEGER property) const { return this.m_long_prop[property];                    }
      double                     GetProperty(ENUM_RISK_PROP_DOUBLE property)  const { return this.m_double_prop[this.IndexProp(property)];  }
      string                     GetProperty(ENUM_RISK_PROP_STRING property)  const { return this.m_string_prop[this.IndexProp(property)];  }
    //--- The catalog: the rows in the order of the inputs (Setting_Risk.ord), what the author declared for each property; a property by its name
      int                        PropertiesTotal(void)                 const { return ::ArraySize(risk_property_list);                    }
      int                        PropertyOfRow(const int row)          const { return risk_property_list[row].property;                   }
      int                        Property(const string name)           const;
      string                     PropertyName(const int property)      const { const int r=this.Row(property); return (r<0 ? NULL : risk_property_list[r].name);    }
      string                     PropertyGroup(const int property)     const { const int r=this.Row(property); return (r<0 ? NULL : risk_property_list[r].group);   }
      string                     PropertyType(const int property)      const { const int r=this.Row(property); return (r<0 ? NULL : risk_property_list[r].type);    }
      string                     PropertyDescription(const int property) const { const int r=this.Row(property); return (r<0 ? NULL : risk_property_list[r].comment); }
      bool                       IsString(const int property)          const { return property>=RISK_PROP_INTEGER_TOTAL+RISK_PROP_DOUBLE_TOTAL;         }
    //--- Any property by its number, for what goes over the catalog (the table, the View): an integer or a real as a double (EMPTY_VALUE: a string);
    //--- a string as its text (NULL: a number)
      double                     Value(const int property) const;
      bool                       SetValue(const int property,const double value,const bool notify=true,const bool save_now=false);
      string                     Text(const int property) const;
      bool                       SetText(const int property,const string text,const bool notify=true,const bool save_now=false);
    //--- Risk Model, Stops and Targets, Adaptive Risk, Broker & Margin Safety (SRiskConfig)
      ENUM_RISK_MODE             RiskMode(void)                        const { return (ENUM_RISK_MODE)this.GetProperty(RISK_PROP_RISK_MODE);              }
      ENUM_RISK_BASE             RiskBase(void)                        const { return (ENUM_RISK_BASE)this.GetProperty(RISK_PROP_RISK_BASE);              }
      double                     RiskPercent(void)                     const { return this.GetProperty(RISK_PROP_PERCENTAGE_RISK_PER_OPERATION);          }
      double                     FixedCashRisk(void)                   const { return this.GetProperty(RISK_PROP_FIXED_CASH_RISK);                        }
      bool                       AllowMinLotOverRisk(void)             const { return this.GetProperty(RISK_PROP_ALLOW_MIN_LOT_OVER_RISK)!=0;             }
      bool                       EnableDrawdownScaling(void)           const { return this.GetProperty(RISK_PROP_ENABLE_ADAPTIVE_RISK)!=0;                }
      double                     DrawdownTrigger(void)                 const { return this.GetProperty(RISK_PROP_DROP_DOWN_LEVEL);                        }
      double                     DrawdownFactor(void)                  const { return this.GetProperty(RISK_PROP_RISK_REDUCTION_FACTOR);                  }
      double                     StopATRMultiplier(void)               const { return this.GetProperty(RISK_PROP_ATR_MULTIPLIER);                         }
      double                     TPRatio(void)                         const { return this.GetProperty(RISK_PROP_TAKE_PROFIT_RATIO);                      }
      double                     MaxMarginUsagePercent(void)           const { return this.GetProperty(RISK_PROP_MAX_MARGIN_USAGE_PERCENT);               }
      bool                       EnableAdaptiveMarginCap(void)         const { return this.GetProperty(RISK_PROP_ENABLE_ADAPTIVE_MARGIN_CAP)!=0;          }
      double                     MarginLevelSafe(void)                 const { return this.GetProperty(RISK_PROP_MARGIN_LEVEL_SAFE);                      }
      double                     MarginLevelDanger(void)               const { return this.GetProperty(RISK_PROP_MARGIN_LEVEL_DANGER);                    }
      bool                       AllowHedging(void)                    const { return this.GetProperty(RISK_PROP_ALLOW_HEDGING)!=0;                       }
     //--- New in V5: the strategies (strategy_id) that take part in trading
      string                     EntryStrategies(void)                 const { return this.GetProperty(RISK_PROP_ENTRY_STRATEGIES);                       }
     //--- The bases (Setting_IndicatorTemplate.id, comma-separated) that give the stop / trail it: any number ON, the best price wins
      string                     StopLossTemplates(void)               const { return this.GetProperty(RISK_PROP_STOP_LOSS_TEMPLATES);                    }
      string                     TrailingTemplates(void)               const { return this.GetProperty(RISK_PROP_TRAILING_TEMPLATES);                     }
     //--- An id in a list property (EntryStrategies, StopLossTemplates, TrailingTemplates: "3,5"); SetIdOn puts it in / out
      bool                       IsIdOn(ENUM_RISK_PROP_STRING property,const long id) const;
      bool                       SetIdOn(ENUM_RISK_PROP_STRING property,const long id,const bool on);
    //--- Basket Risk (SBasketConfig)
      bool                       BasketEnabled(void)                   const { return this.GetProperty(RISK_PROP_ENABLE_BASKET_RISK)!=0;                  }
      double                     BasketMaxLossPercent(void)            const { return this.GetProperty(RISK_PROP_MAX_BASKET_LOSS_PERCENT);                }
      ENUM_RISK_BASE             BasketLossBase(void)                  const { return (ENUM_RISK_BASE)this.GetProperty(RISK_PROP_BASKET_LOSS_BASE);       }
      double                     BasketMaxMarginPercent(void)          const { return this.GetProperty(RISK_PROP_MAX_BASKET_MARGIN_PERCENT);              }
      bool                       BasketTrackExcursion(void)            const { return this.GetProperty(RISK_PROP_ENABLE_MAE_TRACKING)!=0;                 }
      int                        BasketMaxHoldBars(void)               const { return (int)this.GetProperty(RISK_PROP_MAX_BASKET_HOLD_BARS);              }
    //--- Portfolio Risk (CTradingControl, TradingControl_Risk.mqh)
      bool                       PortfolioEnabled(void)                const { return this.GetProperty(RISK_PROP_ENABLE_PORTFOLIO_RISK)!=0;               }
      ENUM_PORTFOLIO_SCOPE       PortfolioScope(void)                  const { return (ENUM_PORTFOLIO_SCOPE)this.GetProperty(RISK_PROP_PORTFOLIO_SCOPE);  }
      string                     PortfolioExtraMagics(void)            const { return this.GetProperty(RISK_PROP_EXTRA_PORTFOLIO_MAGICS);                 }
      int                        PortfolioMaxTotalPositions(void)      const { return (int)this.GetProperty(RISK_PROP_MAX_PORTFOLIO_POSITIONS);           }
      int                        PortfolioMaxPositionsPerSymbol(void)  const { return (int)this.GetProperty(RISK_PROP_MAX_POSITIONS_PER_SYMBOL);          }
      int                        PortfolioMaxSymbols(void)             const { return (int)this.GetProperty(RISK_PROP_MAX_PORTFOLIO_SYMBOLS);             }
      double                     PortfolioMaxMarginPercent(void)       const { return this.GetProperty(RISK_PROP_MAX_PORTFOLIO_MARGIN_PERCENT);           }
      double                     PortfolioMaxLossPercent(void)         const { return this.GetProperty(RISK_PROP_MAX_PORTFOLIO_LOSS_PERCENT);             }
      double                     PortfolioMaxNetCurrencyLots(void)     const { return this.GetProperty(RISK_PROP_MAX_NET_CURRENCY_LOTS);                  }
      bool                       PortfolioLogSnapshot(void)            const { return this.GetProperty(RISK_PROP_LOG_PORTFOLIO_SNAPSHOT)!=0;              }
   };
 #endif // CRISKSETTING_MQH_DECLARATION
 #ifndef CRISKSETTING_MQH_IMPLEMENTATION
 #define CRISKSETTING_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor: the defaults of the catalog                         |
  //+------------------------------------------------------------------+
  CRiskSetting::CRiskSetting(void)
   {
    this.m_object_type=OBJECT_DE_TYPE_RISK_SETTING;
    this.m_name="Setting_Risk";
    ::ArrayInitialize(this.m_long_prop,0);
    ::ArrayInitialize(this.m_double_prop,0.0);
    for(int i=0;i<RISK_PROP_STRING_TOTAL;i++)
       this.m_string_prop[i]="";
    for(int r=0;r<this.PropertiesTotal();r++)
       if(!this.IsString(risk_property_list[r].property))
          this.SetValue(risk_property_list[r].property,risk_property_list[r].value,false);
   }
  int CRiskSetting::Row(const int property) const
   {
    for(int r=0;r<::ArraySize(risk_property_list);r++)
       if(risk_property_list[r].property==property)
          return r;
    return WRONG_VALUE;
   }
  int CRiskSetting::Property(const string name) const
   {
    for(int r=0;r<::ArraySize(risk_property_list);r++)
       if(risk_property_list[r].name==name)
          return risk_property_list[r].property;
    return WRONG_VALUE;
   }
  bool CRiskSetting::SetProperty(ENUM_RISK_PROP_INTEGER property,long value,const bool notify=true,const bool save_now=false)
   {
    if(this.m_long_prop[property]==value && !save_now)
       return true;
    this.m_long_prop[property]=value;
    if(notify)
       this.EventSend((ushort)RISK_SETTING_EVENT_CHANGED,(save_now ? 1 : 0),(double)value,this.PropertyName(property));
    return true;
   }
  bool CRiskSetting::SetProperty(ENUM_RISK_PROP_DOUBLE property,double value,const bool notify=true,const bool save_now=false)
   {
    const int i=this.IndexProp(property);
    if(this.m_double_prop[i]==value && !save_now)
       return true;
    this.m_double_prop[i]=value;
    if(notify)
       this.EventSend((ushort)RISK_SETTING_EVENT_CHANGED,(save_now ? 1 : 0),value,this.PropertyName(property));
    return true;
   }
  //--- dparam = 0: the listener reads the text
  bool CRiskSetting::SetProperty(ENUM_RISK_PROP_STRING property,string value,const bool notify=true,const bool save_now=false)
   {
    const int i=this.IndexProp(property);
    if(this.m_string_prop[i]==value && !save_now)
       return true;
    this.m_string_prop[i]=value;
    if(notify)
       this.EventSend((ushort)RISK_SETTING_EVENT_CHANGED,(save_now ? 1 : 0),0,this.PropertyName(property));
    return true;
   }
  double CRiskSetting::Value(const int property) const
   {
    if(property>=0 && property<RISK_PROP_INTEGER_TOTAL)
       return (double)this.GetProperty((ENUM_RISK_PROP_INTEGER)property);
    if(property>=RISK_PROP_INTEGER_TOTAL && !this.IsString(property) && property<RISK_PROP_TOTAL)
       return this.GetProperty((ENUM_RISK_PROP_DOUBLE)property);
    return EMPTY_VALUE;
   }
  bool CRiskSetting::SetValue(const int property,const double value,const bool notify=true,const bool save_now=false)
   {
    if(property>=0 && property<RISK_PROP_INTEGER_TOTAL)
       return this.SetProperty((ENUM_RISK_PROP_INTEGER)property,(long)::MathRound(value),notify,save_now);
    if(property>=RISK_PROP_INTEGER_TOTAL && !this.IsString(property) && property<RISK_PROP_TOTAL)
       return this.SetProperty((ENUM_RISK_PROP_DOUBLE)property,value,notify,save_now);
    return false;
   }
  string CRiskSetting::Text(const int property) const
   {
    return (this.IsString(property) && property<RISK_PROP_TOTAL ? this.GetProperty((ENUM_RISK_PROP_STRING)property) : NULL);
   }
  bool CRiskSetting::SetText(const int property,const string text,const bool notify=true,const bool save_now=false)
   {
    return (this.IsString(property) && property<RISK_PROP_TOTAL ? this.SetProperty((ENUM_RISK_PROP_STRING)property,text,notify,save_now) : false);
   }
  //--- An id in a list property of V5 ("3,5")
  bool CRiskSetting::IsIdOn(ENUM_RISK_PROP_STRING property,const long id) const
   {
    string part[];
    const int count=::StringSplit(this.GetProperty(property),',',part);
    for(int i=0;i<count;i++)
       if(::StringToInteger(part[i])==id)
          return true;
    return false;
   }
  //--- An id goes in / out of a list property; SetProperty fires RISK_SETTING_EVENT_CHANGED when the list changes
  bool CRiskSetting::SetIdOn(ENUM_RISK_PROP_STRING property,const long id,const bool on)
   {
    string part[],list="";
    const int count=::StringSplit(this.GetProperty(property),',',part);
    for(int i=0;i<count;i++)
       if(part[i]!="" && ::StringToInteger(part[i])!=id)
          list+=(list=="" ? "" : ",")+part[i];
    if(on)
       list+=(list=="" ? "" : ",")+(string)id;
    return this.SetProperty(property,list);
   }
 #endif // CRISKSETTING_MQH_IMPLEMENTATION
#endif // __RISKSETTING_MQH__
