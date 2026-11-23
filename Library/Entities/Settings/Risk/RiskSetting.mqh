//+------------------------------------------------------------------+
//|                                                  RiskSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = the rows of Setting_Risk on RAM: a row for each     |
//| input of FixedMACrossover_Part7.mq5 (Solomon Anietie Sunday\Risk |
//| Management\7. 24477) that is a risk setting, as the author       |
//| declared it: its input group, its type, its name, its default    |
//| and its comment, in its order. CTradingControl writes and reads  |
//| the table. Not ported: the MA / ATR periods (slots of the        |
//| Strategy), Order Execution (the Strategy decides the order type),|
//| inpMagicNumber (the input of the EA). New in V5: the group "V5"  |
//| (StopLossTemplates, TrailingTemplates)                           |
//+------------------------------------------------------------------+
#ifndef __RISKSETTING_MQH__
#define __RISKSETTING_MQH__
 #include "..\..\Bases\BaseObj.mqh"
 #include "..\..\Defines\RiskManagementDefines.mqh"
 #include "..\..\Defines\EventDefines.mqh"
 #ifndef CRISKSETTING_MQH_DECLARATION
 #define CRISKSETTING_MQH_DECLARATION
  class CRiskSetting : public CBaseObj
   {
     private:
      string                     m_group[];         // Setting_Risk.grp: the input group of the author
      string                     m_type[];          // Setting_Risk.type: bool, int, double, string or the ENUM_ of the input
      string                     m_key[];           // Setting_Risk.name: the name of the input
      double                     m_value[];         // Setting_Risk.value of a number key (bool, int, double, enum)
      string                     m_text[];          // Setting_Risk.value of a string key
      string                     m_comment[];       // Setting_Risk.comment: the comment of the input
      void                       AddKey(const string group,const string type,const string name,const double value,const string text,const string comment);
     public:
                                 CRiskSetting(void);
                                ~CRiskSetting(void) {}
    //--- The keys, in the order of the inputs (Setting_Risk.ord)
      int                        KeysTotal(void)                const { return ::ArraySize(m_key); }
      int                        Index(const string name)       const;
      string                     KeyGroup(const int index)      const { return m_group[index];     }
      string                     KeyType(const int index)       const { return m_type[index];      }
      string                     KeyName(const int index)       const { return m_key[index];       }
      double                     KeyValue(const int index)      const { return m_value[index];     }
      string                     KeyText(const int index)       const { return m_text[index];      }
      string                     KeyComment(const int index)    const { return m_comment[index];   }
      bool                       KeyIsText(const int index)     const { return m_type[index]=="string"; }
    //--- A key by its name (EMPTY_VALUE / NULL: no such key). SetValue / SetText fire RISK_SETTING_EVENT_CHANGED (sparam = name) when it changes, unless notify is false
      double                     Value(const string name) const;
      bool                       SetValue(const string name,const double value,const bool notify=true);
      string                     Text(const string name) const;
      bool                       SetText(const string name,const string text,const bool notify=true);
    //--- Risk Model, Stops and Targets, Adaptive Risk, Broker & Margin Safety, Trading Signal (SRiskConfig)
      ENUM_RISK_MODE             RiskMode(void)                        const { return (ENUM_RISK_MODE)(int)Value("RiskMode");                      }
      ENUM_RISK_BASE             RiskBase(void)                        const { return (ENUM_RISK_BASE)(int)Value("RiskBase");                      }
      double                     RiskPercent(void)                     const { return Value("percentage_risk_per_operation");                      }
      double                     FixedCashRisk(void)                   const { return Value("FixedCashRisk");                                      }
      double                     FixedLotSize(void)                    const { return Value("FixedLotSize");                                       }
      bool                       AllowMinLotOverRisk(void)             const { return Value("AllowMinLotOverRisk")!=0;                             }
      bool                       EnableDrawdownScaling(void)           const { return Value("EnableAdaptiveRisk")!=0;                              }
      double                     DrawdownTrigger(void)                 const { return Value("DropDownLevel");                                      }
      double                     DrawdownFactor(void)                  const { return Value("RiskReductionFactor");                                }
      bool                       ApplyDrawdownToFixedLot(void)         const { return Value("ApplyDrawdownToFixedLot")!=0;                         }
      double                     StopATRMultiplier(void)               const { return Value("ATRMultiplier");                                      }
      double                     TPRatio(void)                         const { return Value("TakeProfitRatio");                                    }
      double                     MaxMarginUsagePercent(void)           const { return Value("MaxMarginUsagePercent");                              }
      bool                       EnableAdaptiveMarginCap(void)         const { return Value("EnableAdaptiveMarginCap")!=0;                         }
      double                     MarginLevelSafe(void)                 const { return Value("MarginLevelSafe");                                    }
      double                     MarginLevelDanger(void)               const { return Value("MarginLevelDanger");                                  }
      bool                       AllowHedging(void)                    const { return Value("AllowHedging")!=0;                                    }
      double                     MaxSpreadPips(void)                   const { return Value("MaxSpreadPips");                                      }
     //--- New in V5: the strategies (strategy_id) that take part in trading
      string                    EntryStrategies(void)                 const { return Text("EntryStrategies");                                     }
     //--- The bases (Setting_IndicatorTemplate.id, comma-separated) that give the stop / trail it: any number ON, the best price wins
      string                     StopLossTemplates(void)               const { return Text("StopLossTemplates");                                   }
      string                     TrailingTemplates(void)               const { return Text("TrailingTemplates");                                   }
     //--- An id in a list key (EntryStrategies, StopLossTemplates, TrailingTemplates: "3,5"); SetIdOn puts it in / out
      bool                       IsIdOn(const string name,const long id) const;
      bool                       SetIdOn(const string name,const long id,const bool on);
    //--- Basket Risk (SBasketConfig)
      bool                       BasketEnabled(void)                   const { return Value("EnableBasketRisk")!=0;                                }
      double                     BasketMaxLossPercent(void)            const { return Value("MaxBasketLossPercent");                               }
      ENUM_RISK_BASE             BasketLossBase(void)                  const { return (ENUM_RISK_BASE)(int)Value("BasketLossBase");                }
      double                     BasketMaxMarginPercent(void)          const { return Value("MaxBasketMarginPercent");                             }
      bool                       BasketTrackExcursion(void)            const { return Value("EnableMAETracking")!=0;                               }
      int                        BasketMaxHoldBars(void)               const { return (int)Value("MaxBasketHoldBars");                             }
    //--- Portfolio Risk (CTradingControl, TradingControl_Risk.mqh)
      bool                       PortfolioEnabled(void)                const { return Value("EnablePortfolioRisk")!=0;                             }
      ENUM_PORTFOLIO_SCOPE       PortfolioScope(void)                  const { return (ENUM_PORTFOLIO_SCOPE)(int)Value("PortfolioScope");          }
      string                     PortfolioExtraMagics(void)            const { return Text("ExtraPortfolioMagics");                                }
      int                        PortfolioMaxTotalPositions(void)      const { return (int)Value("MaxPortfolioPositions");                         }
      int                        PortfolioMaxPositionsPerSymbol(void)  const { return (int)Value("MaxPositionsPerSymbol");                         }
      int                        PortfolioMaxSymbols(void)             const { return (int)Value("MaxPortfolioSymbols");                           }
      double                     PortfolioMaxMarginPercent(void)       const { return Value("MaxPortfolioMarginPercent");                          }
      double                     PortfolioMaxLossPercent(void)         const { return Value("MaxPortfolioLossPercent");                            }
      double                     PortfolioMaxNetCurrencyLots(void)     const { return Value("MaxNetCurrencyLots");                                 }
      bool                       PortfolioLogSnapshot(void)            const { return Value("LogPortfolioSnapshot")!=0;                            }
   };
 #endif // CRISKSETTING_MQH_DECLARATION
 #ifndef CRISKSETTING_MQH_IMPLEMENTATION
 #define CRISKSETTING_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor: the inputs of FixedMACrossover_Part7, as written     |
  //+------------------------------------------------------------------+
  CRiskSetting::CRiskSetting(void)
   {
    this.m_object_type=OBJECT_DE_TYPE_RISK_SETTING;
    this.m_name="Setting_Risk";
    this.AddKey("Trading Signal",               "double",              "MaxSpreadPips",                 2.0,                    "","Maximum allowed spread");
    this.AddKey("Risk Model",                   "ENUM_RISK_MODE",      "RiskMode",                      RISK_PERCENT,           "","How risk per trade is defined");
    this.AddKey("Risk Model",                   "ENUM_RISK_BASE",      "RiskBase",                      RISK_BASE_BALANCE,      "","Risk percentage measured against");
    this.AddKey("Risk Model",                   "double",              "percentage_risk_per_operation", 1.0,                    "","Risk per trade [%] (percent mode)");
    this.AddKey("Risk Model",                   "double",              "FixedCashRisk",                 100.0,                  "","Risk per trade [account currency] (cash mode)");
    this.AddKey("Risk Model",                   "double",              "FixedLotSize",                  0,                      "","Lot size (fixed-lot mode) [0 = min lot of the symbol]");
    this.AddKey("Risk Model",                   "bool",                "AllowMinLotOverRisk",           1,                      "","Trade min lot even if it exceeds intended risk");
    this.AddKey("Stops and Targets",            "double",              "ATRMultiplier",                 1.5,                    "","ATR multiplier for stop distance");
    this.AddKey("Stops and Targets",            "double",              "TakeProfitRatio",               2.0,                    "","Take profit ratio");
    this.AddKey("Stops and Targets",            "bool",                "AllowHedging",                  0,                      "","Allow opposing position");
    this.AddKey("Adaptive Risk (Drawdown)",     "bool",                "EnableAdaptiveRisk",            0,                      "","Reduce risk during drawdowns");
    this.AddKey("Adaptive Risk (Drawdown)",     "double",              "DropDownLevel",                 3.0,                    "","Drawdown % that triggers reduced risk");
    this.AddKey("Adaptive Risk (Drawdown)",     "double",              "RiskReductionFactor",           0.5,                    "","Risk multiplier when triggered");
    this.AddKey("Adaptive Risk (Drawdown)",     "bool",                "ApplyDrawdownToFixedLot",       0,                      "","Also shrink the fixed lot");
    this.AddKey("Broker & Margin Safety",       "double",              "MaxMarginUsagePercent",         50.0,                   "","Max % of free margin one trade may use");
    this.AddKey("Broker & Margin Safety",       "bool",                "EnableAdaptiveMarginCap",       0,                      "","Scale the cap with account margin level");
    this.AddKey("Broker & Margin Safety",       "double",              "MarginLevelSafe",               500.0,                  "","Margin level [%] where the full cap applies");
    this.AddKey("Broker & Margin Safety",       "double",              "MarginLevelDanger",             150.0,                  "","Margin level [%] where trades are blocked");
    this.AddKey("Basket Risk",                  "bool",                "EnableBasketRisk",              1,                      "","Limit risk across this EA's positions");
    this.AddKey("Basket Risk",                  "double",              "MaxBasketLossPercent",          3.0,                    "","Close the basket at this loss % [0 = off]");
    this.AddKey("Basket Risk",                  "ENUM_RISK_BASE",      "BasketLossBase",                RISK_BASE_BALANCE,      "","Basket cut measured against");
    this.AddKey("Basket Risk",                  "double",              "MaxBasketMarginPercent",        25.0,                   "","Max % of equity the basket may tie up [0 = off]");
    this.AddKey("Basket Risk",                  "bool",                "EnableMAETracking",             1,                      "","Track adverse excursion");
    this.AddKey("Basket Risk",                  "int",                 "MaxBasketHoldBars",             0,                      "","Close a losing basket after N bars [0 = off]");
    this.AddKey("Portfolio Risk (account-wide)","bool",                "EnablePortfolioRisk",           1,                      "","Check account-wide limits before trading");
    this.AddKey("Portfolio Risk (account-wide)","ENUM_PORTFOLIO_SCOPE","PortfolioScope",                PORTFOLIO_ACCOUNT_WIDE, "","What counts as the portfolio");
    this.AddKey("Portfolio Risk (account-wide)","string",              "ExtraPortfolioMagics",          0,                      "","Extra magic numbers, comma-separated");
    this.AddKey("Portfolio Risk (account-wide)","int",                 "MaxPortfolioPositions",         6,                      "","Max positions portfolio-wide [0 = off]");
    this.AddKey("Portfolio Risk (account-wide)","int",                 "MaxPositionsPerSymbol",         2,                      "","Max positions on one symbol [0 = off]");
    this.AddKey("Portfolio Risk (account-wide)","int",                 "MaxPortfolioSymbols",           4,                      "","Max distinct symbols at once [0 = off]");
    this.AddKey("Portfolio Risk (account-wide)","double",              "MaxPortfolioMarginPercent",     40.0,                   "","Max % of equity in margin [0 = off]");
    this.AddKey("Portfolio Risk (account-wide)","double",              "MaxPortfolioLossPercent",       6.0,                    "","Block new trades past this loss % [0 = off]");
    this.AddKey("Portfolio Risk (account-wide)","double",              "MaxNetCurrencyLots",            2.0,                    "","Max net lots per currency [0 = off]");
    this.AddKey("Portfolio Risk (account-wide)","bool",                "LogPortfolioSnapshot",          0,                      "","Log the portfolio picture every bar");
    //--- New in V5 (many strategies, chosen by the user on the Trading tab, Auto): the strategies that trade (CTradingControl uses it; not trading_enabled
    //--- of Setting_Strategy: that one makes the templates of the slots), the bases (Setting_IndicatorTemplate.id) that give the stop / the trailing
    this.AddKey("V5",                           "string",              "EntryStrategies",               0,                      "","Setting_Strategy.strategy_id of the strategies that take part in trading, comma-separated");
    this.AddKey("V5",                           "string",              "StopLossTemplates",             0,                      "","Bases that give the stop loss, comma-separated: PSAR its price, ATR x ATRMultiplier; the nearest valid stop wins");
    this.AddKey("V5",                           "string",              "TrailingTemplates",             0,                      "","Bases that trail the stop, comma-separated: the best price wins");
   }
  void CRiskSetting::AddKey(const string group,const string type,const string name,const double value,const string text,const string comment)
   {
    const int n=::ArraySize(m_key);
    ::ArrayResize(m_group,n+1);
    ::ArrayResize(m_type,n+1);
    ::ArrayResize(m_key,n+1);
    ::ArrayResize(m_value,n+1);
    ::ArrayResize(m_text,n+1);
    ::ArrayResize(m_comment,n+1);
    m_group[n]=group;
    m_type[n]=type;
    m_key[n]=name;
    m_value[n]=value;
    m_text[n]=text;
    m_comment[n]=comment;
   }
  int CRiskSetting::Index(const string name) const
   {
    for(int i=0;i<::ArraySize(m_key);i++)
       if(m_key[i]==name)
          return i;
    return WRONG_VALUE;
   }
  double CRiskSetting::Value(const string name) const
   {
    const int i=this.Index(name);
    return (i<0 ? EMPTY_VALUE : m_value[i]);
   }
  //--- The event: dparam = the new value, sparam = the name
  bool CRiskSetting::SetValue(const string name,const double value,const bool notify=true)
   {
    const int i=this.Index(name);
    if(i<0 || this.KeyIsText(i))
       return false;
    if(m_value[i]==value)
       return true;
    m_value[i]=value;
    if(notify)
       this.EventSend((ushort)RISK_SETTING_EVENT_CHANGED,0,value,name);
    return true;
   }
  string CRiskSetting::Text(const string name) const
   {
    const int i=this.Index(name);
    return (i<0 ? NULL : m_text[i]);
   }
  //--- The event: dparam = 0, sparam = the name; the listener reads Text()
  bool CRiskSetting::SetText(const string name,const string text,const bool notify=true)
   {
    const int i=this.Index(name);
    if(i<0 || !this.KeyIsText(i))
       return false;
    if(m_text[i]==text)
       return true;
    m_text[i]=text;
    if(notify)
       this.EventSend((ushort)RISK_SETTING_EVENT_CHANGED,0,0,name);
    return true;
   }
  //--- An id in a list key of V5 ("3,5")
  bool CRiskSetting::IsIdOn(const string name,const long id) const
   {
    string part[];
    const int count=::StringSplit(this.Text(name),',',part);
    for(int i=0;i<count;i++)
       if(::StringToInteger(part[i])==id)
          return true;
    return false;
   }
  //--- An id goes in / out of a list key; SetText fires RISK_SETTING_EVENT_CHANGED when the list changes
  bool CRiskSetting::SetIdOn(const string name,const long id,const bool on)
   {
    string part[],list="";
    const int count=::StringSplit(this.Text(name),',',part);
    for(int i=0;i<count;i++)
       if(part[i]!="" && ::StringToInteger(part[i])!=id)
          list+=(list=="" ? "" : ",")+part[i];
    if(on)
       list+=(list=="" ? "" : ",")+(string)id;
    return this.SetText(name,list);
   }
 #endif // CRISKSETTING_MQH_IMPLEMENTATION
#endif // __RISKSETTING_MQH__
