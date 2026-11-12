//+------------------------------------------------------------------+
//|                                                      Account.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Topic link:               https://www.mql5.com/en/articles/7258   |
//|Link                      https://www.mql5.com/en/articles/9850   |
//|Link                      https://www.mql5.com/en/articles/10663  |
//|Link                      https://www.mql5.com/en/articles/11194  |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
//--- An account, asked of the terminal (Readme "Live on RAM, Save on DB for no more calculation"): who it is and its terms are asked once (the constructor) and
//--- are the row of the table accounts (CAccountsCollection writes it); what changes is asked by RefreshAccount and lives in RAM only, a change over a controlled
//--- value is its event (Event Rule). Change from V3: Refresh -> RefreshAccount (as RefreshSeries), the reads not written twice (V3: constructor and Refresh)
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __ACCOUNT_MQH__
#define __ACCOUNT_MQH__
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\Defines\TradingDefines.mqh"
 #include "..\Bases\BaseObjExt.mqh"
 #ifndef CACCOUNT_MQH_DECLARATION
 #define CACCOUNT_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Account class                                                    |
 //+------------------------------------------------------------------+
 class CAccount : public CBaseObjExt
  {
   private:
    long              m_long_prop[ACCOUNT_PROP_INTEGER_TOTAL];           // Integer properties
    double            m_double_prop[ACCOUNT_PROP_DOUBLE_TOTAL];          // Real properties
    string            m_string_prop[ACCOUNT_PROP_STRING_TOTAL];          // String properties
   //--- Return the index of the array the account's (1) double and (2) string properties are located at
    int               IndexProp(ENUM_ACCOUNT_PROP_DOUBLE property) const { return(int)property-ACCOUNT_PROP_INTEGER_TOTAL;                           }
    int               IndexProp(ENUM_ACCOUNT_PROP_STRING property) const { return(int)property-ACCOUNT_PROP_INTEGER_TOTAL-ACCOUNT_PROP_DOUBLE_TOTAL; }
   public:
   //--- Constructor
                      CAccount(void);
   //--- Compare CAccount objects by account properties (to search for equal account objects: CAccountsCollection::IsPresent)
    bool              IsEqual(CAccount *compared_account) const;
   //--- Set account's (1) integer, (2) real and (3) string properties
    void              SetProperty(ENUM_ACCOUNT_PROP_INTEGER property,long value)        { this.m_long_prop[property]=value;                   }
    void              SetProperty(ENUM_ACCOUNT_PROP_DOUBLE property,double value)       { this.m_double_prop[this.IndexProp(property)]=value; }
    void              SetProperty(ENUM_ACCOUNT_PROP_STRING property,string value)       { this.m_string_prop[this.IndexProp(property)]=value; }
   //--- Return (1) integer, (2) real and (3) string account properties from the property array
    long              GetProperty(ENUM_ACCOUNT_PROP_INTEGER property)             const { return this.m_long_prop[property];                  }
    double            GetProperty(ENUM_ACCOUNT_PROP_DOUBLE property)              const { return this.m_double_prop[this.IndexProp(property)];}
    string            GetProperty(ENUM_ACCOUNT_PROP_STRING property)              const { return this.m_string_prop[this.IndexProp(property)];}
    //--- Return the account's integer properties
      ENUM_ACCOUNT_TRADE_MODE    TradeMode(void)                        const { return (ENUM_ACCOUNT_TRADE_MODE)this.GetProperty(ACCOUNT_PROP_TRADE_MODE);           }
      ENUM_ACCOUNT_STOPOUT_MODE  MarginSOMode(void)                     const { return (ENUM_ACCOUNT_STOPOUT_MODE)this.GetProperty(ACCOUNT_PROP_MARGIN_SO_MODE);     }
      ENUM_ACCOUNT_MARGIN_MODE   MarginMode(void)                       const { return (ENUM_ACCOUNT_MARGIN_MODE)this.GetProperty(ACCOUNT_PROP_MARGIN_MODE);         }
      long              Login(void)                                     const { return this.GetProperty(ACCOUNT_PROP_LOGIN);                                         }
      long              Leverage(void)                                  const { return this.GetProperty(ACCOUNT_PROP_LEVERAGE);                                      }
      long              LimitOrders(void)                               const { return this.GetProperty(ACCOUNT_PROP_LIMIT_ORDERS);                                  }
      long              TradeAllowed(void)                              const { return this.GetProperty(ACCOUNT_PROP_TRADE_ALLOWED);                                 }
      long              TradeExpert(void)                               const { return this.GetProperty(ACCOUNT_PROP_TRADE_EXPERT);                                  }
      long              CurrencyDigits(void)                            const { return this.GetProperty(ACCOUNT_PROP_CURRENCY_DIGITS);                               }
      long              ServerType(void)                                const { return this.GetProperty(ACCOUNT_PROP_SERVER_TYPE);                                   }
      bool              FIFOClose(void)                                 const { return (bool)this.GetProperty(ACCOUNT_PROP_FIFO_CLOSE);                              }
      bool              IsHedge(void)                                   const { return this.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING;                        }
      bool              HedgeAllowed(void)                              const { return (bool)this.GetProperty(ACCOUNT_PROP_HEDGE_ALLOWED);                           }
    //--- Return the account's real properties
      double            Balance(void)                                   const { return this.GetProperty(ACCOUNT_PROP_BALANCE);                                       }
      double            Credit(void)                                    const { return this.GetProperty(ACCOUNT_PROP_CREDIT);                                        }
      double            Profit(void)                                    const { return this.GetProperty(ACCOUNT_PROP_PROFIT);                                        }
      double            Equity(void)                                    const { return this.GetProperty(ACCOUNT_PROP_EQUITY);                                        }
      double            Margin(void)                                    const { return this.GetProperty(ACCOUNT_PROP_MARGIN);                                        }
      double            MarginFree(void)                                const { return this.GetProperty(ACCOUNT_PROP_MARGIN_FREE);                                   }
      double            MarginLevel(void)                               const { return this.GetProperty(ACCOUNT_PROP_MARGIN_LEVEL);                                  }
      double            MarginSOCall(void)                              const { return this.GetProperty(ACCOUNT_PROP_MARGIN_SO_CALL);                                }
      double            MarginSOSO(void)                                const { return this.GetProperty(ACCOUNT_PROP_MARGIN_SO_SO);                                  }
      double            MarginInitial(void)                             const { return this.GetProperty(ACCOUNT_PROP_MARGIN_INITIAL);                                }
      double            MarginMaintenance(void)                         const { return this.GetProperty(ACCOUNT_PROP_MARGIN_MAINTENANCE);                            }
      double            Assets(void)                                    const { return this.GetProperty(ACCOUNT_PROP_ASSETS);                                        }
      double            Liabilities(void)                               const { return this.GetProperty(ACCOUNT_PROP_LIABILITIES);                                   }
      double            ComissionBlocked(void)                          const { return this.GetProperty(ACCOUNT_PROP_COMMISSION_BLOCKED);                            }
      
    //--- Return the account's string properties
      string            Name(void)                                      const { return this.GetProperty(ACCOUNT_PROP_NAME);                                          }
      string            Server(void)                                    const { return this.GetProperty(ACCOUNT_PROP_SERVER);                                        }
      string            Currency(void)                                  const { return this.GetProperty(ACCOUNT_PROP_CURRENCY);                                      }
      string            Company(void)                                   const { return this.GetProperty(ACCOUNT_PROP_COMPANY);                                       }

    //+------------------------------------------------------------------+
    //| Get and set the parameters of tracked property changes           |
    //+------------------------------------------------------------------+
    //--- setting the controlled leverage (1) increase, (2) decrease value and (3) control level
    //--- getting the (3) leverage change value,
    //--- getting the flag of the leverage change exceeding the (4) increase, (5) decrease value
      void              SetControlLeverageInc(const long value)               { this.SetControlledValueINC(ACCOUNT_PROP_LEVERAGE,(long)::fabs(value));               }
      void              SetControlLeverageDec(const long value)               { this.SetControlledValueDEC(ACCOUNT_PROP_LEVERAGE,(long)::fabs(value));               }
      void              SetControlLeverageLevel(const long value)             { this.SetControlledValueLEVEL(ACCOUNT_PROP_LEVERAGE,(long)::fabs(value));             }
      long              GetValueChangedLeverage(void)                   const { return this.GetPropLongChangedValue(ACCOUNT_PROP_LEVERAGE);                          }
      bool              IsIncreasedLeverage(void)                       const { return (bool)this.GetPropLongFlagINC(ACCOUNT_PROP_LEVERAGE);                         }
      bool              IsDecreasedLeverage(void)                       const { return (bool)this.GetPropLongFlagDEC(ACCOUNT_PROP_LEVERAGE);                         }
   
    //--- setting the controlled value of (1) growth, (2) decrease and (3) control level of the number of active pending orders
    //--- getting (3) the change value of the number of active pending orders,
    //--- getting the flag of the number of active pending orders exceeding the (4) increase, (5) decrease value
      void              SetControlLimitOrdersInc(const long value)            { this.SetControlledValueINC(ACCOUNT_PROP_LIMIT_ORDERS,(long)::fabs(value));           }
      void              SetControlLimitOrdersDec(const long value)            { this.SetControlledValueDEC(ACCOUNT_PROP_LIMIT_ORDERS,(long)::fabs(value));           }
      void              SetControlLimitOrdersLevel(const long value)          { this.SetControlledValueLEVEL(ACCOUNT_PROP_LIMIT_ORDERS,(long)::fabs(value));         }
      long              GetValueChangedLimitOrders(void)                const { return this.GetPropLongChangedValue(ACCOUNT_PROP_LIMIT_ORDERS);                      }
      bool              IsIncreasedLimitOrders(void)                    const { return (bool)this.GetPropLongFlagINC(ACCOUNT_PROP_LIMIT_ORDERS);                     }
      bool              IsDecreasedLimitOrders(void)                    const { return (bool)this.GetPropLongFlagDEC(ACCOUNT_PROP_LIMIT_ORDERS);                     }
   
    //--- setting the controlled value of (1) increase, (2) decrease and (3) control level of the permission to trade for the current account from the server side
    //--- getting (3) the value of the permission to trade for the current account from the server side,
    //--- getting the flag of a change of the permission to trade for the current account from the server side exceeding the (4) increase and (5) decrease values
      void              SetControlTradeAllowedInc(const long value)           { this.SetControlledValueINC(ACCOUNT_PROP_TRADE_ALLOWED,(long)::fabs(value));          }
      void              SetControlTradeAllowedDec(const long value)           { this.SetControlledValueDEC(ACCOUNT_PROP_TRADE_ALLOWED,(long)::fabs(value));          }
      void              SetControlTradeAllowedLevel(const long value)         { this.SetControlledValueLEVEL(ACCOUNT_PROP_TRADE_ALLOWED,(long)::fabs(value));        }
      long              GetValueChangedTradeAllowed(void)               const { return this.GetPropLongChangedValue(ACCOUNT_PROP_TRADE_ALLOWED);                     }
      bool              IsIncreasedTradeAllowed(void)                   const { return (bool)this.GetPropLongFlagINC(ACCOUNT_PROP_TRADE_ALLOWED);                    }
      bool              IsDecreasedTradeAllowed(void)                   const { return (bool)this.GetPropLongFlagDEC(ACCOUNT_PROP_TRADE_ALLOWED);                    }
   
    //--- setting the controlled value of (1) increase, (2) decrease and (3) control level of the permission to trade for an EA from the server side
    //--- getting (3) the value of the permission to trade for an EA from the server side,
    //--- getting the flag of a change of the permission to trade for an EA from the server side exceeding the (4) increase and (5) decrease values
      void              SetControlTradeExpertInc(const long value)            { this.SetControlledValueINC(ACCOUNT_PROP_TRADE_EXPERT,(long)::fabs(value));           }
      void              SetControlTradeExpertDec(const long value)            { this.SetControlledValueDEC(ACCOUNT_PROP_TRADE_EXPERT,(long)::fabs(value));           }
      void              SetControlTradeExpertLevel(const long value)          { this.SetControlledValueLEVEL(ACCOUNT_PROP_TRADE_EXPERT,(long)::fabs(value));         }
      long              GetValueChangedTradeExpert(void)                const { return this.GetPropLongChangedValue(ACCOUNT_PROP_TRADE_EXPERT);                      }
      bool              IsIncreasedTradeExpert(void)                    const { return (bool)this.GetPropLongFlagINC(ACCOUNT_PROP_TRADE_EXPERT);                     }
      bool              IsDecreasedTradeExpert(void)                    const { return (bool)this.GetPropLongFlagDEC(ACCOUNT_PROP_TRADE_EXPERT);                     }
   
    //--- setting the controlled balance (1) increase, (2) decrease value and (3) control level
    //--- getting (3) the balance change value,
    //--- getting the flag of the balance change exceeding the (4) increase value, (5) decrease value
      void              SetControlBalanceInc(const long value)                { this.SetControlledValueINC(ACCOUNT_PROP_BALANCE,(double)::fabs(value));              }
      void              SetControlBalanceDec(const long value)                { this.SetControlledValueDEC(ACCOUNT_PROP_BALANCE,(double)::fabs(value));              }
      void              SetControlBalanceLevel(const long value)              { this.SetControlledValueLEVEL(ACCOUNT_PROP_BALANCE,(double)::fabs(value));            }
      double            GetValueChangedBalance(void)                    const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_BALANCE);                         }
      bool              IsIncreasedBalance(void)                        const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_BALANCE);                        }
      bool              IsDecreasedBalance(void)                        const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_BALANCE);                        }
   
    //--- setting the controlled credit (1) increase, (2) decrease value and (3) control level
    //--- getting the (3) credit change value,
    //--- getting the flag of the credit change exceeding the (4) increase, (5) decrease value
      void              SetControlCreditInc(const long value)                 { this.SetControlledValueINC(ACCOUNT_PROP_CREDIT,(double)::fabs(value));               }
      void              SetControlCreditDec(const long value)                 { this.SetControlledValueDEC(ACCOUNT_PROP_CREDIT,(double)::fabs(value));               }
      void              SetControlCreditLevel(const long value)               { this.SetControlledValueLEVEL(ACCOUNT_PROP_CREDIT,(double)::fabs(value));             }
      double            GetValueChangedCredit(void)                     const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_CREDIT);                          }
      bool              IsIncreasedCredit(void)                         const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_CREDIT);                         }
      bool              IsDecreasedCredit(void)                         const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_CREDIT);                         }
   
    //--- setting the controlled profit (1) increase, (2) decrease value and (3) control level
    //--- getting the (3) profit change value,
    //--- getting the flag of the profit change exceeding the (4) increase, (5) decrease value
      void              SetControlProfitInc(const long value)                 { this.SetControlledValueINC(ACCOUNT_PROP_PROFIT,(double)::fabs(value));               }
      void              SetControlProfitDec(const long value)                 { this.SetControlledValueDEC(ACCOUNT_PROP_PROFIT,(double)::fabs(value));               }
      void              SetControlProfitLevel(const long value)               { this.SetControlledValueLEVEL(ACCOUNT_PROP_PROFIT,(double)::fabs(value));             }
      double            GetValueChangedProfit(void)                     const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_PROFIT);                          }
      bool              IsIncreasedProfit(void)                         const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_PROFIT);                         }
      bool              IsDecreasedProfit(void)                         const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_PROFIT);                         }
   
    //--- setting the controlled equity (1) increase, (2) decrease value and (3) control level
    //--- getting the (3) equity change value,
    //--- getting the flag of the equity change exceeding the (4) increase, (5) decrease value
      void              SetControlEquityInc(const long value)                 { this.SetControlledValueINC(ACCOUNT_PROP_EQUITY,(double)::fabs(value));               }
      void              SetControlEquityDec(const long value)                 { this.SetControlledValueDEC(ACCOUNT_PROP_EQUITY,(double)::fabs(value));               }
      void              SetControlEquityLevel(const long value)               { this.SetControlledValueLEVEL(ACCOUNT_PROP_EQUITY,(double)::fabs(value));             }
      double            GetValueChangedEquity(void)                     const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_EQUITY);                          }
      bool              IsIncreasedEquity(void)                         const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_EQUITY);                         }
      bool              IsDecreasedEquity(void)                         const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_EQUITY);                         }
   
    //--- setting the controlled margin (1) increase, (2) decrease value and (3) control level
    //--- getting the (3) margin change value,
    //--- getting the flag of the margin change exceeding the (4) increase, (5) decrease value
      void              SetControlMarginInc(const long value)                 { this.SetControlledValueINC(ACCOUNT_PROP_MARGIN,(double)::fabs(value));               }
      void              SetControlMarginDec(const long value)                 { this.SetControlledValueDEC(ACCOUNT_PROP_MARGIN,(double)::fabs(value));               }
      void              SetControlMarginLevel(const long value)               { this.SetControlledValueLEVEL(ACCOUNT_PROP_MARGIN,(double)::fabs(value));             }
      double            GetValueChangedMargin(void)                     const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_MARGIN);                          }
      bool              IsIncreasedMargin(void)                         const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_MARGIN);                         }
      bool              IsDecreasedMargin(void)                         const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_MARGIN);                         }
   
    //--- setting the controlled free margin (1) increase, (2) decrease value and (3) control level
    //--- getting the (3) free margin change value,
    //--- getting the flag of the free margin change exceeding the (4) increase, (5) decrease value
      void              SetControlMarginFreeInc(const long value)             { this.SetControlledValueINC(ACCOUNT_PROP_MARGIN_FREE,(double)::fabs(value));          }
      void              SetControlMarginFreeDec(const long value)             { this.SetControlledValueDEC(ACCOUNT_PROP_MARGIN_FREE,(double)::fabs(value));          }
      void              SetControlMarginFreeLevel(const long value)           { this.SetControlledValueLEVEL(ACCOUNT_PROP_MARGIN_FREE,(double)::fabs(value));        }
      double            GetValueChangedMarginFree(void)                 const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_MARGIN_FREE);                     }
      bool              IsIncreasedMarginFree(void)                     const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_MARGIN_FREE);                    }
      bool              IsDecreasedMarginFree(void)                     const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_MARGIN_FREE);                    }
   
    //--- setting the controlled margin level (1) increase, (2) decrease value and (3) control level
    //--- getting the (3) margin level change value,
    //--- getting the flag of the margin level change exceeding the (4) increase, (5) decrease value
      void              SetControlMarginLevelInc(const long value)            { this.SetControlledValueINC(ACCOUNT_PROP_MARGIN_LEVEL,(double)::fabs(value));         }
      void              SetControlMarginLevelDec(const long value)            { this.SetControlledValueDEC(ACCOUNT_PROP_MARGIN_LEVEL,(double)::fabs(value));         }
      void              SetControlMarginLevelLevel(const long value)          { this.SetControlledValueLEVEL(ACCOUNT_PROP_MARGIN_LEVEL,(double)::fabs(value));       }
      double            GetValueChangedMarginLevel(void)                const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_MARGIN_LEVEL);                    }
      bool              IsIncreasedMarginLevel(void)                    const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_MARGIN_LEVEL);                   }
      bool              IsDecreasedMarginLevel(void)                    const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_MARGIN_LEVEL);                   }
   
    //--- setting the controlled Margin Call (1) increase, (2) decrease value and (3) control level in points
    //--- getting (3) Margin Call level change value,
    //--- getting the flag of the Margin Call level change exceeding the (4) increase, (5) decrease value
      void              SetControlMarginCallInc(const long value)             { this.SetControlledValueINC(ACCOUNT_PROP_MARGIN_SO_CALL,(double)::fabs(value));       }
      void              SetControlMarginCallDec(const long value)             { this.SetControlledValueDEC(ACCOUNT_PROP_MARGIN_SO_CALL,(double)::fabs(value));       }
      void              SetControlMarginCallLevel(const long value)           { this.SetControlledValueLEVEL(ACCOUNT_PROP_MARGIN_SO_CALL,(double)::fabs(value));     }
      double            GetValueChangedMarginCall(void)                 const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_MARGIN_SO_CALL);                  }
      bool              IsIncreasedMarginCall(void)                     const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_MARGIN_SO_CALL);                 }
      bool              IsDecreasedMarginCall(void)                     const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_MARGIN_SO_CALL);                 }
   
    //--- setting the controlled Margin StopOut (1) increase, (2) decrease value and (3) control level
    //--- getting (3) Margin StopOut level change value,
    //--- getting the flag of the Margin StopOut level change exceeding the (4) increase, (5) decrease value
      void              SetControlMarginStopOutInc(const long value)          { this.SetControlledValueINC(ACCOUNT_PROP_MARGIN_SO_SO,(double)::fabs(value));         }
      void              SetControlMarginStopOutDec(const long value)          { this.SetControlledValueDEC(ACCOUNT_PROP_MARGIN_SO_SO,(double)::fabs(value));         }
      void              SetControlMarginStopOutLevel(const long value)        { this.SetControlledValueLEVEL(ACCOUNT_PROP_MARGIN_SO_SO,(double)::fabs(value));       }
      double            GetValueChangedMarginStopOut(void)              const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_MARGIN_SO_SO);                    }
      bool              IsIncreasedMarginStopOut(void)                  const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_MARGIN_SO_SO);                   }
      bool              IsDecreasedMarginStopOut(void)                  const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_MARGIN_SO_SO);                   }
   
    //--- setting the controlled value of the growth of the reserved funds for providing the guarantee sum for pending orders (1) increase, (2) decrease
    //--- getting (3) the change value of the growth of the reserved funds for providing the guarantee sum for pending orders,
    //--- getting the flag of the growth change of the reserved funds for providing the guarantee sum for pending orders exceeding the (4) increase, (5) decrease value
      void              SetControlMarginInitialInc(const long value)          { this.SetControlledValueINC(ACCOUNT_PROP_MARGIN_INITIAL,(double)::fabs(value));       }
      void              SetControlMarginInitialDec(const long value)          { this.SetControlledValueDEC(ACCOUNT_PROP_MARGIN_INITIAL,(double)::fabs(value));       }
      void              SetControlMarginInitialLevel(const long value)        { this.SetControlledValueLEVEL(ACCOUNT_PROP_MARGIN_INITIAL,(double)::fabs(value));     }
      double            GetValueChangedMarginInitial(void)              const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_MARGIN_INITIAL);                  }
      bool              IsIncreasedMarginInitial(void)                  const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_MARGIN_INITIAL);                 }
      bool              IsDecreasedMarginInitial(void)                  const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_MARGIN_INITIAL);                 }
   
    //--- setting the controlled value of the growth of the reserved funds for providing the minimum sum for all open positions (1) increase, (2) decrease value and (3) control level
    //--- getting (3) the change value of the growth of the reserved funds for providing the minimum sum for all open positions,
    //--- getting the flag of the growth change of the reserved funds for providing the minimum sum for all open positions exceeding the (4) increase, (5) decrease value
      void              SetControlMarginMaintenanceInc(const long value)      { this.SetControlledValueINC(ACCOUNT_PROP_MARGIN_MAINTENANCE,(double)::fabs(value));   }
      void              SetControlMarginMaintenanceDec(const long value)      { this.SetControlledValueDEC(ACCOUNT_PROP_MARGIN_MAINTENANCE,(double)::fabs(value));   }
      void              SetControlMarginMaintenanceLevel(const long value)    { this.SetControlledValueLEVEL(ACCOUNT_PROP_MARGIN_MAINTENANCE,(double)::fabs(value)); }
      double            GetValueChangedMarginMaintenance(void)          const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_MARGIN_MAINTENANCE);              }
      bool              IsIncreasedMarginMaintenance(void)              const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_MARGIN_MAINTENANCE);             }
      bool              IsDecreasedMarginMaintenance(void)              const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_MARGIN_MAINTENANCE);             }
   
    //--- setting the controlled assets (1) increase, (2) decrease value and (3) control level
    //--- getting (3) the assets change value,
    //--- getting the flag of the assets change exceeding the (4) increase, (5) decrease value
      void              SetControlAssetsInc(const long value)                 { this.SetControlledValueINC(ACCOUNT_PROP_ASSETS,(double)::fabs(value));               }
      void              SetControlAssetsDec(const long value)                 { this.SetControlledValueDEC(ACCOUNT_PROP_ASSETS,(double)::fabs(value));               }
      void              SetControlAssetsLevel(const long value)               { this.SetControlledValueLEVEL(ACCOUNT_PROP_ASSETS,(double)::fabs(value));             }
      double            GetValueChangedAssets(void)                     const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_ASSETS);                          }
      bool              IsIncreasedAssets(void)                         const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_ASSETS);                         }
      bool              IsDecreasedAssets(void)                         const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_ASSETS);                         }
   
    //--- setting the controlled liabilities (1) increase, (2) decrease value and (3) control level
    //--- getting (3) the liabilities change value,
    //--- getting the flag of the liabilities change exceeding the (4) increase, (5) decrease value
      void              SetControlLiabilitiesInc(const long value)            { this.SetControlledValueINC(ACCOUNT_PROP_LIABILITIES,(double)::fabs(value));          }
      void              SetControlLiabilitiesDec(const long value)            { this.SetControlledValueDEC(ACCOUNT_PROP_LIABILITIES,(double)::fabs(value));          }
      void              SetControlLiabilitiesLevel(const long value)          { this.SetControlledValueLEVEL(ACCOUNT_PROP_LIABILITIES,(double)::fabs(value));        }
      double            GetValueChangedLiabilities(void)                const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_LIABILITIES);                     }
      bool              IsIncreasedLiabilities(void)                    const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_LIABILITIES);                    }
      bool              IsDecreasedLiabilities(void)                    const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_LIABILITIES);                    }
   
    //--- setting the controlled blocked commissions (1) increase, (2) decrease value and (3) control level in points
    //--- getting (3) the blocked commissions change value,
    //--- getting the flag of the blocked commissions change exceeding the (4) increase, (5) decrease value
      void              SetControlComissionBlockedInc(const long value)       { this.SetControlledValueINC(ACCOUNT_PROP_COMMISSION_BLOCKED,(double)::fabs(value));   }
      void              SetControlComissionBlockedDec(const long value)       { this.SetControlledValueDEC(ACCOUNT_PROP_COMMISSION_BLOCKED,(double)::fabs(value));   }
      void              SetControlComissionBlockedLevel(const long value)     { this.SetControlledValueLEVEL(ACCOUNT_PROP_COMMISSION_BLOCKED,(double)::fabs(value)); }
      double            GetValueChangedComissionBlocked(void)           const { return this.GetPropDoubleChangedValue(ACCOUNT_PROP_COMMISSION_BLOCKED);              }
      bool              IsIncreasedComissionBlocked(void)               const { return (bool)this.GetPropDoubleFlagINC(ACCOUNT_PROP_COMMISSION_BLOCKED);             }
      bool              IsDecreasedComissionBlocked(void)               const { return (bool)this.GetPropDoubleFlagDEC(ACCOUNT_PROP_COMMISSION_BLOCKED);             }
   //--- What changes while the EA runs is asked of the terminal, its events are made (as CBarSeriesDE::RefreshSeries)
    void              RefreshAccount(void);
   //--- Return the margin required for opening a position or placing a pending order (V3)
    double            MarginForAction(const ENUM_ORDER_TYPE action,const string symbol,const double volume,const double price) const;
  };
 #endif // CACCOUNT_MQH_DECLARATION
 #ifndef CACCOUNT_MQH_IMPLEMENTATION
 #define CACCOUNT_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor: what does not change is asked once, then the live    |
 //| part (RefreshAccount)                                            |
 //+------------------------------------------------------------------+
 CAccount::CAccount(void)
  {
   this.m_object_type=OBJECT_DE_TYPE_ACCOUNT;
  //--- Initialize control data
   this.SetControlDataArraySizeLong(ACCOUNT_PROP_INTEGER_TOTAL);
   this.SetControlDataArraySizeDouble(ACCOUNT_PROP_DOUBLE_TOTAL);
   this.ResetChangesParams();
   this.ResetControlsParams();
  //--- Who the account is and its terms: they do not change while the EA runs (the row of the table accounts)
   this.SetProperty(ACCOUNT_PROP_LOGIN,::AccountInfoInteger(ACCOUNT_LOGIN));
   this.SetProperty(ACCOUNT_PROP_TRADE_MODE,::AccountInfoInteger(ACCOUNT_TRADE_MODE));
   this.SetProperty(ACCOUNT_PROP_MARGIN_SO_MODE,::AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE));
   this.SetProperty(ACCOUNT_PROP_MARGIN_MODE,::AccountInfoInteger(ACCOUNT_MARGIN_MODE));
   this.SetProperty(ACCOUNT_PROP_CURRENCY_DIGITS,::AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS));
   this.SetProperty(ACCOUNT_PROP_SERVER_TYPE,(::StringFind(::TerminalInfoString(TERMINAL_NAME),"MetaTrader 5")>WRONG_VALUE ? 5 : 4));
   this.SetProperty(ACCOUNT_PROP_FIFO_CLOSE,::AccountInfoInteger(ACCOUNT_FIFO_CLOSE));
   this.SetProperty(ACCOUNT_PROP_HEDGE_ALLOWED,::AccountInfoInteger(ACCOUNT_HEDGE_ALLOWED));
   this.SetProperty(ACCOUNT_PROP_NAME,::AccountInfoString(ACCOUNT_NAME));
   this.SetProperty(ACCOUNT_PROP_SERVER,::AccountInfoString(ACCOUNT_SERVER));
   this.SetProperty(ACCOUNT_PROP_CURRENCY,::AccountInfoString(ACCOUNT_CURRENCY));
   this.SetProperty(ACCOUNT_PROP_COMPANY,::AccountInfoString(ACCOUNT_COMPANY));
  //--- The name of the object (CBaseObj, GetName) is the property: one name, which is the column name of the table accounts
   this.m_name=this.GetProperty(ACCOUNT_PROP_NAME);
  //--- The live part, the first time (the first start of CBaseObjExt: no event)
   this.RefreshAccount();
  }
 //+------------------------------------------------------------------+
 //| Compare CAccount objects by account properties (V3)              |
 //+------------------------------------------------------------------+
 bool CAccount::IsEqual(CAccount *compared_account) const
  {
   if(this.GetProperty(ACCOUNT_PROP_COMPANY)!=compared_account.GetProperty(ACCOUNT_PROP_COMPANY) ||
      this.GetProperty(ACCOUNT_PROP_LOGIN)!=compared_account.GetProperty(ACCOUNT_PROP_LOGIN)     ||
      this.GetProperty(ACCOUNT_PROP_NAME)!=compared_account.GetProperty(ACCOUNT_PROP_NAME)
     ) return false;
   return true;
  }
 //+------------------------------------------------------------------+
 //| What changes while the EA runs is asked of the terminal (RAM     |
 //| only); a change over a controlled value is an event of the       |
 //| account (Event Rule: the method that changes the data tells it)  |
 //+------------------------------------------------------------------+
 void CAccount::RefreshAccount(void)
  {
  //--- Initialize event data
   this.m_is_event=false;
   this.m_hash_sum=0;
  //--- The permissions and the terms the broker may change (the last four are columns of the table accounts: written again when they change)
   this.SetProperty(ACCOUNT_PROP_TRADE_ALLOWED,::AccountInfoInteger(ACCOUNT_TRADE_ALLOWED));
   this.SetProperty(ACCOUNT_PROP_TRADE_EXPERT,::AccountInfoInteger(ACCOUNT_TRADE_EXPERT));
   this.SetProperty(ACCOUNT_PROP_LEVERAGE,::AccountInfoInteger(ACCOUNT_LEVERAGE));
   this.SetProperty(ACCOUNT_PROP_LIMIT_ORDERS,::AccountInfoInteger(ACCOUNT_LIMIT_ORDERS));
   this.SetProperty(ACCOUNT_PROP_MARGIN_SO_CALL,::AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
   this.SetProperty(ACCOUNT_PROP_MARGIN_SO_SO,::AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
  //--- The money and the margin
   this.SetProperty(ACCOUNT_PROP_BALANCE,::AccountInfoDouble(ACCOUNT_BALANCE));
   this.SetProperty(ACCOUNT_PROP_CREDIT,::AccountInfoDouble(ACCOUNT_CREDIT));
   this.SetProperty(ACCOUNT_PROP_PROFIT,::AccountInfoDouble(ACCOUNT_PROFIT));
   this.SetProperty(ACCOUNT_PROP_EQUITY,::AccountInfoDouble(ACCOUNT_EQUITY));
   this.SetProperty(ACCOUNT_PROP_MARGIN,::AccountInfoDouble(ACCOUNT_MARGIN));
   this.SetProperty(ACCOUNT_PROP_MARGIN_FREE,::AccountInfoDouble(ACCOUNT_MARGIN_FREE));
   this.SetProperty(ACCOUNT_PROP_MARGIN_LEVEL,::AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   this.SetProperty(ACCOUNT_PROP_MARGIN_INITIAL,::AccountInfoDouble(ACCOUNT_MARGIN_INITIAL));
   this.SetProperty(ACCOUNT_PROP_MARGIN_MAINTENANCE,::AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE));
   this.SetProperty(ACCOUNT_PROP_ASSETS,::AccountInfoDouble(ACCOUNT_ASSETS));
   this.SetProperty(ACCOUNT_PROP_LIABILITIES,::AccountInfoDouble(ACCOUNT_LIABILITIES));
   this.SetProperty(ACCOUNT_PROP_COMMISSION_BLOCKED,::AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED));
  //--- The current values are the cells [3] of the arrays of changes of CBaseObjExt, where the changes are looked for
   for(int i=0;i<ACCOUNT_PROP_INTEGER_TOTAL;i++)
      this.m_long_prop_event[i][3]=this.m_long_prop[i];
   for(int i=0;i<ACCOUNT_PROP_DOUBLE_TOTAL;i++)
      this.m_double_prop_event[i][3]=this.m_double_prop[i];
  //--- Update the base object data and search for changes
   CBaseObjExt::Refresh();
   this.CheckEvents();
  }
//+------------------------------------------------------------------+
//| Return the margin required for opening a position                |
//| or placing a pending order (V3)                                  |
//+------------------------------------------------------------------+
double CAccount::MarginForAction(const ENUM_ORDER_TYPE action,const string symbol,const double volume,const double price) const
  {
   double margin=EMPTY_VALUE;
   return(!::OrderCalcMargin(ENUM_ORDER_TYPE(action%2),symbol,volume,price,margin) ? EMPTY_VALUE : margin);
  }
 #endif // CACCOUNT_MQH_IMPLEMENTATION
#endif // __ACCOUNT_MQH__
