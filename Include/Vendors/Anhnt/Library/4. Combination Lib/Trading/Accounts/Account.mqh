//+------------------------------------------------------------------+
//|                                                      Account.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/7258                 |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __ACCOUNT_MQH__
#define __ACCOUNT_MQH__

#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "..\..\Base\BaseObjExt.mqh"
 #include "..\..\Defines\TradingDefines.mqh"
 #ifndef CACCOUNT_MQH_DECLARATION
 #define CACCOUNT_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Account class                                                    |
 //+------------------------------------------------------------------+
 class CAccount : public CBaseObjExt
  {
   private:
    struct SData
     {
      //--- Account integer properties
       long           login;                        // ACCOUNT_LOGIN (Account number)
       int            trade_mode;                   // ACCOUNT_TRADE_MODE (Trading account type)
       long           leverage;                     // ACCOUNT_LEVERAGE (Leverage)
       int            limit_orders;                 // ACCOUNT_LIMIT_ORDERS (Maximum allowed number of active pending orders)
       int            margin_so_mode;               // ACCOUNT_MARGIN_SO_MODE (Mode of setting the minimum available margin level)
       bool           trade_allowed;                // ACCOUNT_TRADE_ALLOWED (Permission to trade for the current account from the server side)
       bool           trade_expert;                 // ACCOUNT_TRADE_EXPERT (Permission to trade for an EA from the server side)
       int            margin_mode;                  // ACCOUNT_MARGIN_MODE (Margin calculation mode)
       int            currency_digits;              // ACCOUNT_CURRENCY_DIGITS (Number of decimal places for the account currency)
       int            server_type;                  // Trade server type (MetaTrader 5, MetaTrader 4)
       bool           fifo_close;                   // ACCOUNT_FIFO_CLOSE (The flag indicating that positions can be closed only by the FIFO rule)
       bool           hedge_allowed;                // ACCOUNT_HEDGE_ALLOWED (Permission to open opposite positions and set pending orders)
      //--- Account real properties
       double         balance;                      // ACCOUNT_BALANCE (Account balance in a deposit currency)
       double         credit;                       // ACCOUNT_CREDIT (Credit in a deposit currency)
       double         profit;                       // ACCOUNT_PROFIT (Current profit on an account in the account currency)
       double         equity;                       // ACCOUNT_EQUITY (Equity on an account in the deposit currency)
       double         margin;                       // ACCOUNT_MARGIN (Reserved margin on an account in a deposit currency)
       double         margin_free;                  // ACCOUNT_MARGIN_FREE (Free funds available for opening a position in a deposit currency)
       double         margin_level;                 // ACCOUNT_MARGIN_LEVEL (Margin level on an account in %)
       double         margin_so_call;               // ACCOUNT_MARGIN_SO_CALL (MarginCall)
       double         margin_so_so;                 // ACCOUNT_MARGIN_SO_SO (StopOut)
       double         margin_initial;               // ACCOUNT_MARGIN_INITIAL (Funds reserved on an account to ensure a guarantee amount for all pending orders)
       double         margin_maintenance;           // ACCOUNT_MARGIN_MAINTENANCE (Funds reserved on an account to ensure a minimum amount for all open positions)
       double         assets;                       // ACCOUNT_ASSETS (Current assets on an account)
       double         liabilities;                  // ACCOUNT_LIABILITIES (Current liabilities on an account)
       double         comission_blocked;            // ACCOUNT_COMMISSION_BLOCKED (Current sum of blocked commissions on an account)
      //--- Account string properties
       uchar          name[128];                    // ACCOUNT_NAME (Client name)
       uchar          server[64];                   // ACCOUNT_SERVER (Trade server name)
       uchar          currency[32];                 // ACCOUNT_CURRENCY (Deposit currency)
       uchar          company[128];                 // ACCOUNT_COMPANY (Name of a company serving an account)
     };
    SData             m_struct_obj;                                      // Account object structure
    uchar             m_uchar_array[];                                   // uchar array of the account object structure
   
   //--- Object properties
    long              m_long_prop[ACCOUNT_PROP_INTEGER_TOTAL];           // Integer properties
    double            m_double_prop[ACCOUNT_PROP_DOUBLE_TOTAL];          // Real properties
    string            m_string_prop[ACCOUNT_PROP_STRING_TOTAL];          // String properties
    uchar             m_type_server;                                     // Server type (4 or 5)

   //--- Return the index of the array the account's (1) double and (2) string properties are located at
    int               IndexProp(ENUM_ACCOUNT_PROP_DOUBLE property) const { return(int)property-ACCOUNT_PROP_INTEGER_TOTAL;                                   }
    int               IndexProp(ENUM_ACCOUNT_PROP_STRING property) const { return(int)property-ACCOUNT_PROP_INTEGER_TOTAL-ACCOUNT_PROP_DOUBLE_TOTAL;         }
   protected:
    //--- Create (1) the account object structure and (2) the account object from the structure
     bool              ObjectToStruct(void);
     void              StructToObject(void);
   public:
    //--- Constructor
     CAccount(void);
    //--- Set account's (1) integer, (2) real and (3) string properties
     void              SetProperty(ENUM_ACCOUNT_PROP_INTEGER property,long value)        { this.m_long_prop[property]=value;                                  }
     void              SetProperty(ENUM_ACCOUNT_PROP_DOUBLE property,double value)       { this.m_double_prop[this.IndexProp(property)]=value;                }
     void              SetProperty(ENUM_ACCOUNT_PROP_STRING property,string value)       { this.m_string_prop[this.IndexProp(property)]=value;                }
    //--- Return (1) integer, (2) real and (3) string order properties from the account string property
     long              GetProperty(ENUM_ACCOUNT_PROP_INTEGER property)             const { return this.m_long_prop[property];                                 }
     double            GetProperty(ENUM_ACCOUNT_PROP_DOUBLE property)              const { return this.m_double_prop[this.IndexProp(property)];               }
     string            GetProperty(ENUM_ACCOUNT_PROP_STRING property)              const { return this.m_string_prop[this.IndexProp(property)];               }
    //--- Return the flag of calculating MarginCall and StopOut levels in %
     bool              IsPercentsForSOLevels(void)                                 const { return this.MarginSOMode()==ACCOUNT_STOPOUT_MODE_PERCENT;          }
    //--- Return the flag of supporting the property by the account object
     virtual bool      SupportProperty(ENUM_ACCOUNT_PROP_INTEGER property)               { return true; }
     virtual bool      SupportProperty(ENUM_ACCOUNT_PROP_DOUBLE property)                { return true; }
     virtual bool      SupportProperty(ENUM_ACCOUNT_PROP_STRING property)                { return true; }
    //--- Compare CAccount objects by all possible properties (for sorting the lists by a specified account object property)
     virtual int       Compare(const CObject *node,const int mode=0) const;
    //--- Compare CAccount objects by account properties (to search for equal account objects)
     bool              IsEqual(CAccount* compared_account) const;
    //--- Update all account data
     virtual void      Refresh(void);
    //--- (1) Save the account object to the file, (2), download the account object from the file
     virtual bool      Save(const int file_handle);
     virtual bool      Load(const int file_handle);
    //--- Return the margin required for opening a position or placing a pending order
      double            MarginForAction(const ENUM_ORDER_TYPE action,const string symbol,const double volume,const double price) const;
    //+------------------------------------------------------------------+
    //| Methods of a simplified access to the account object properties  |
    //+------------------------------------------------------------------+
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

    //+------------------------------------------------------------------+
    //| Descriptions of the account object properties                    |
    //+------------------------------------------------------------------+
    //--- Return the description of the account's (1) integer, (2) real and (3) string properties
      string            GetPropertyDescription(ENUM_ACCOUNT_PROP_INTEGER property);
      string            GetPropertyDescription(ENUM_ACCOUNT_PROP_DOUBLE property);
      string            GetPropertyDescription(ENUM_ACCOUNT_PROP_STRING property);
    //--- Return a name of a trading account type (demo, contest, real)
      string            TradeModeDescription(void)    const;
    //--- Return a name of a trade server type (MetaTrader 5, MetaTrader 4)
      string            ServerTypeDescription(void)    const;
    //--- Return the description of the mode for setting the minimum available margin level
      string            MarginSOModeDescription(void) const;
    //--- Return the description of the margin calculation mode
      string            MarginModeDescription(void)   const;
    //--- Display the description of the object properties in the journal (full_prop=true - all properties, false - supported ones only - implemented in descendant classes)
      virtual void      Print(const bool full_prop=false,const bool dash=false);
    //--- Display a short description of the object in the journal
      virtual void      PrintShort(const bool dash=false,const bool symbol=false);
  };
 #endif // CACCOUNT_MQH_DECLARATION
 #ifndef CACCOUNT_MQH_IMPLEMENTATION
 #define CACCOUNT_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Class methods                                                    |
  //+------------------------------------------------------------------+
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CAccount::CAccount(void)
   {
     this.m_type=OBJECT_DE_TYPE_ACCOUNT;
    //--- Initialize control data
     this.SetControlDataArraySizeLong(ACCOUNT_PROP_INTEGER_TOTAL);
     this.SetControlDataArraySizeDouble(ACCOUNT_PROP_DOUBLE_TOTAL);
     this.ResetChangesParams();
     this.ResetControlsParams();
  
    //--- Save integer properties
     this.m_long_prop[ACCOUNT_PROP_LOGIN]                              = ::AccountInfoInteger(ACCOUNT_LOGIN);
     this.m_long_prop[ACCOUNT_PROP_TRADE_MODE]                         = ::AccountInfoInteger(ACCOUNT_TRADE_MODE);
     this.m_long_prop[ACCOUNT_PROP_LEVERAGE]                           = ::AccountInfoInteger(ACCOUNT_LEVERAGE);
     this.m_long_prop[ACCOUNT_PROP_LIMIT_ORDERS]                       = ::AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
     this.m_long_prop[ACCOUNT_PROP_MARGIN_SO_MODE]                     = ::AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
     this.m_long_prop[ACCOUNT_PROP_TRADE_ALLOWED]                      = ::AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
     this.m_long_prop[ACCOUNT_PROP_TRADE_EXPERT]                       = ::AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
     this.m_long_prop[ACCOUNT_PROP_MARGIN_MODE]                        = #ifdef __MQL5__::AccountInfoInteger(ACCOUNT_MARGIN_MODE) #else ACCOUNT_MARGIN_MODE_RETAIL_HEDGING #endif ;
     this.m_long_prop[ACCOUNT_PROP_CURRENCY_DIGITS]                    = #ifdef __MQL5__::AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS) #else 2 #endif ;
     this.m_long_prop[ACCOUNT_PROP_SERVER_TYPE]                        = (::StringFind(::TerminalInfoString(TERMINAL_NAME),"MetaTrader 5")>WRONG_VALUE ? 5 : 4);
     this.m_long_prop[ACCOUNT_PROP_FIFO_CLOSE]                         = (#ifdef __MQL5__::TerminalInfoInteger(TERMINAL_BUILD)<2155 ? false : ::AccountInfoInteger(ACCOUNT_FIFO_CLOSE) #else false #endif );
     this.m_long_prop[ACCOUNT_PROP_HEDGE_ALLOWED]                      = (#ifdef __MQL5__::TerminalInfoInteger(TERMINAL_BUILD)<3245 ? false : ::AccountInfoInteger(ACCOUNT_HEDGE_ALLOWED) #else false #endif );
   
    //--- Save real properties
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_BALANCE)]          = ::AccountInfoDouble(ACCOUNT_BALANCE);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_CREDIT)]           = ::AccountInfoDouble(ACCOUNT_CREDIT);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_PROFIT)]           = ::AccountInfoDouble(ACCOUNT_PROFIT);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_EQUITY)]           = ::AccountInfoDouble(ACCOUNT_EQUITY);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN)]           = ::AccountInfoDouble(ACCOUNT_MARGIN);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_FREE)]      = ::AccountInfoDouble(ACCOUNT_MARGIN_FREE);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_LEVEL)]     = ::AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_SO_CALL)]   = ::AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_SO_SO)]     = ::AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_INITIAL)]   = ::AccountInfoDouble(ACCOUNT_MARGIN_INITIAL);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_MAINTENANCE)]=::AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_ASSETS)]           = ::AccountInfoDouble(ACCOUNT_ASSETS);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_LIABILITIES)]      = ::AccountInfoDouble(ACCOUNT_LIABILITIES);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_COMMISSION_BLOCKED)]=::AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED);
   
    //--- Save string properties
     this.m_string_prop[this.IndexProp(ACCOUNT_PROP_NAME)]             = ::AccountInfoString(ACCOUNT_NAME);
     this.m_string_prop[this.IndexProp(ACCOUNT_PROP_SERVER)]           = ::AccountInfoString(ACCOUNT_SERVER);
     this.m_string_prop[this.IndexProp(ACCOUNT_PROP_CURRENCY)]         = ::AccountInfoString(ACCOUNT_CURRENCY);
     this.m_string_prop[this.IndexProp(ACCOUNT_PROP_COMPANY)]          = ::AccountInfoString(ACCOUNT_COMPANY);

    //--- Account object name, object and account type (MetaTrader 5 or 4)
      this.m_name=CMessage::Text(MSG_LIB_PROP_ACCOUNT)+" "+(string)this.Login()+": "+this.Name()+" ("+this.Company()+")";
      this.m_type=COLLECTION_ACCOUNT_ID;
      this.m_type_server=(uchar)this.m_long_prop[ACCOUNT_PROP_SERVER_TYPE];

    //--- Filling in the current account data
      for(int i=0;i<ACCOUNT_PROP_INTEGER_TOTAL;i++)
         this.m_long_prop_event[i][3]=this.m_long_prop[i];
      for(int i=0;i<ACCOUNT_PROP_DOUBLE_TOTAL;i++)
         this.m_double_prop_event[i][3]=this.m_double_prop[i];

    //--- Update the base object data and search for changes
      CBaseObjExt::Refresh();
   }  
  //+-------------------------------------------------------------------+
  //|Compare CAccount objects by all possible properties                |
  //+-------------------------------------------------------------------+
  int CAccount::Compare(const CObject *node,const int mode=0) const
   {
    const CAccount *account_compared=node;
    //--- compare integer properties of two accounts
    if(mode<ACCOUNT_PROP_INTEGER_TOTAL)
      {
       long value_compared=account_compared.GetProperty((ENUM_ACCOUNT_PROP_INTEGER)mode);
       long value_current=this.GetProperty((ENUM_ACCOUNT_PROP_INTEGER)mode);
       return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
    //--- comparing real properties of two accounts
    else if(mode<ACCOUNT_PROP_DOUBLE_TOTAL+ACCOUNT_PROP_INTEGER_TOTAL)
      {
       double value_compared=account_compared.GetProperty((ENUM_ACCOUNT_PROP_DOUBLE)mode);
       double value_current=this.GetProperty((ENUM_ACCOUNT_PROP_DOUBLE)mode);
       return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
    //--- compare string properties of two accounts
    else if(mode<ACCOUNT_PROP_DOUBLE_TOTAL+ACCOUNT_PROP_INTEGER_TOTAL+ACCOUNT_PROP_STRING_TOTAL)
      {
       string value_compared=account_compared.GetProperty((ENUM_ACCOUNT_PROP_STRING)mode);
       string value_current=this.GetProperty((ENUM_ACCOUNT_PROP_STRING)mode);
       return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
    return 0;
   }
  //+------------------------------------------------------------------+
  //| Compare CAccount objects by account properties                   |
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
  //| Update all account data                                          |
  //+------------------------------------------------------------------+
  void CAccount::Refresh(void)
   {
    //--- Initialize event data
     this.m_is_event=false;
     this.m_hash_sum=0;
    //--- Update integer properties
     this.m_long_prop[ACCOUNT_PROP_LOGIN]                                 = ::AccountInfoInteger(ACCOUNT_LOGIN);
     this.m_long_prop[ACCOUNT_PROP_TRADE_MODE]                            = ::AccountInfoInteger(ACCOUNT_TRADE_MODE);
     this.m_long_prop[ACCOUNT_PROP_LEVERAGE]                              = ::AccountInfoInteger(ACCOUNT_LEVERAGE);
     this.m_long_prop[ACCOUNT_PROP_LIMIT_ORDERS]                          = ::AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
     this.m_long_prop[ACCOUNT_PROP_MARGIN_SO_MODE]                        = ::AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
     this.m_long_prop[ACCOUNT_PROP_TRADE_ALLOWED]                         = ::AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
     this.m_long_prop[ACCOUNT_PROP_TRADE_EXPERT]                          = ::AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
     this.m_long_prop[ACCOUNT_PROP_MARGIN_MODE]                           = #ifdef __MQL5__::AccountInfoInteger(ACCOUNT_MARGIN_MODE) #else ACCOUNT_MARGIN_MODE_RETAIL_HEDGING #endif ;
     this.m_long_prop[ACCOUNT_PROP_CURRENCY_DIGITS]                       = #ifdef __MQL5__::AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS) #else 2 #endif ;
     this.m_long_prop[ACCOUNT_PROP_SERVER_TYPE]                           = this.m_type_server;
     this.m_long_prop[ACCOUNT_PROP_FIFO_CLOSE]                            = (#ifdef __MQL5__::TerminalInfoInteger(TERMINAL_BUILD)<2155 ? false : ::AccountInfoInteger(ACCOUNT_FIFO_CLOSE) #else false #endif );
     this.m_long_prop[ACCOUNT_PROP_HEDGE_ALLOWED]                         = (#ifdef __MQL5__::TerminalInfoInteger(TERMINAL_BUILD)<3245 ? false : ::AccountInfoInteger(ACCOUNT_HEDGE_ALLOWED) #else false #endif );
    //--- Update real properties
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_BALANCE)]             = ::AccountInfoDouble(ACCOUNT_BALANCE);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_CREDIT)]              = ::AccountInfoDouble(ACCOUNT_CREDIT);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_PROFIT)]              = ::AccountInfoDouble(ACCOUNT_PROFIT);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_EQUITY)]              = ::AccountInfoDouble(ACCOUNT_EQUITY);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN)]              = ::AccountInfoDouble(ACCOUNT_MARGIN);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_FREE)]         = ::AccountInfoDouble(ACCOUNT_MARGIN_FREE);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_LEVEL)]        = ::AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_SO_CALL)]      = ::AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_SO_SO)]        = ::AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_INITIAL)]      = ::AccountInfoDouble(ACCOUNT_MARGIN_INITIAL);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_MAINTENANCE)]  = ::AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_ASSETS)]              = ::AccountInfoDouble(ACCOUNT_ASSETS);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_LIABILITIES)]         = ::AccountInfoDouble(ACCOUNT_LIABILITIES);
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_COMMISSION_BLOCKED)]  = ::AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED);
    //--- Filling in the current account data in the base object
    for(int i=0;i<ACCOUNT_PROP_INTEGER_TOTAL;i++)
      this.m_long_prop_event[i][3]=this.m_long_prop[i];
    for(int i=0;i<ACCOUNT_PROP_DOUBLE_TOTAL;i++)
      this.m_double_prop_event[i][3]=this.m_double_prop[i];
    //--- Update the base object data and search for changes
    CBaseObjExt::Refresh();
    this.CheckEvents();
   }
  //+------------------------------------------------------------------+
  //| Save the account object to the file                              |
  //+------------------------------------------------------------------+
  bool CAccount::Save(const int file_handle)
    {
     if(!this.ObjectToStruct())
       {
        ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_OBJ_STRUCT));
        return false;
       }
     if(::FileWriteArray(file_handle,this.m_uchar_array)==0)
       {
        ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_WRITE_UARRAY_TO_FILE));
        return false;
       }
     return true;
    }
  //+------------------------------------------------------------------+
  //| Download the account object from the file                        |
  //+------------------------------------------------------------------+
  bool CAccount::Load(const int file_handle)
   {
     if(::FileReadArray(file_handle,this.m_uchar_array)==0)
       {
        ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_LOAD_UARRAY_FROM_FILE));
        return false;
       }
     if(!::CharArrayToStruct(this.m_struct_obj,this.m_uchar_array))
       {
        ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_OBJ_STRUCT_FROM_UARRAY));
        return false;
       }
     this.StructToObject();
     return true;
   }
  //+------------------------------------------------------------------+
  //| Create the account object structure                              |
  //+------------------------------------------------------------------+
  bool CAccount::ObjectToStruct(void)
   {
    //--- Save integer properties
     this.m_struct_obj.login=this.Login();
     this.m_struct_obj.trade_mode=this.TradeMode();
     this.m_struct_obj.leverage=this.Leverage();
     this.m_struct_obj.limit_orders=(int)this.LimitOrders();
     this.m_struct_obj.margin_so_mode=this.MarginSOMode();
     this.m_struct_obj.trade_allowed=this.TradeAllowed();
     this.m_struct_obj.trade_expert=this.TradeExpert();
     this.m_struct_obj.margin_mode=this.MarginMode();
     this.m_struct_obj.currency_digits=(int)this.CurrencyDigits();
     this.m_struct_obj.server_type=(int)this.ServerType();
     this.m_struct_obj.fifo_close=this.FIFOClose();
     this.m_struct_obj.hedge_allowed=this.HedgeAllowed();
    //--- Save real properties
     this.m_struct_obj.balance=this.Balance();
     this.m_struct_obj.credit=this.Credit();
     this.m_struct_obj.profit=this.Profit();
     this.m_struct_obj.equity=this.Equity();
     this.m_struct_obj.margin=this.Margin();
     this.m_struct_obj.margin_free=this.MarginFree();
     this.m_struct_obj.margin_level=this.MarginLevel();
     this.m_struct_obj.margin_so_call=this.MarginSOCall();
     this.m_struct_obj.margin_so_so=this.MarginSOSO();
     this.m_struct_obj.margin_initial=this.MarginInitial();
     this.m_struct_obj.margin_maintenance=this.MarginMaintenance();
     this.m_struct_obj.assets=this.Assets();
     this.m_struct_obj.liabilities=this.Liabilities();
     this.m_struct_obj.comission_blocked=this.ComissionBlocked();
    //--- Save string properties
      ::StringToCharArray(this.Name(),this.m_struct_obj.name);
      ::StringToCharArray(this.Server(),this.m_struct_obj.server);
      ::StringToCharArray(this.Currency(),this.m_struct_obj.currency);
      ::StringToCharArray(this.Company(),this.m_struct_obj.company);
    //--- Save the structure to the uchar array
      ::ResetLastError();
    if(!::StructToCharArray(this.m_struct_obj,this.m_uchar_array))
     {
      ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_SAVE_OBJ_STRUCT_TO_UARRAY),(string)::GetLastError());
      return false;
     }
    return true;
   }
  //+------------------------------------------------------------------+
  //| Create the account object from the structure                     |
  //+------------------------------------------------------------------+
  void CAccount::StructToObject(void)
   {
    //--- Save integer properties
     this.m_long_prop[ACCOUNT_PROP_LOGIN]                              = this.m_struct_obj.login;
     this.m_long_prop[ACCOUNT_PROP_TRADE_MODE]                         = this.m_struct_obj.trade_mode;
     this.m_long_prop[ACCOUNT_PROP_LEVERAGE]                           = this.m_struct_obj.leverage;
     this.m_long_prop[ACCOUNT_PROP_LIMIT_ORDERS]                       = this.m_struct_obj.limit_orders;
     this.m_long_prop[ACCOUNT_PROP_MARGIN_SO_MODE]                     = this.m_struct_obj.margin_so_mode;
     this.m_long_prop[ACCOUNT_PROP_TRADE_ALLOWED]                      = this.m_struct_obj.trade_allowed;
     this.m_long_prop[ACCOUNT_PROP_TRADE_EXPERT]                       = this.m_struct_obj.trade_expert;
     this.m_long_prop[ACCOUNT_PROP_MARGIN_MODE]                        = this.m_struct_obj.margin_mode;
     this.m_long_prop[ACCOUNT_PROP_CURRENCY_DIGITS]                    = this.m_struct_obj.currency_digits;
     this.m_long_prop[ACCOUNT_PROP_SERVER_TYPE]                        = this.m_struct_obj.server_type;
     this.m_long_prop[ACCOUNT_PROP_FIFO_CLOSE]                         = this.m_struct_obj.fifo_close;
     this.m_long_prop[ACCOUNT_PROP_HEDGE_ALLOWED]                      = this.m_struct_obj.hedge_allowed;
    //--- Save real properties
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_BALANCE)]          = this.m_struct_obj.balance;
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_CREDIT)]           = this.m_struct_obj.credit;
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_PROFIT)]           = this.m_struct_obj.profit;
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_EQUITY)]           = this.m_struct_obj.equity;
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN)]           = this.m_struct_obj.margin;
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_FREE)]      = this.m_struct_obj.margin_free;
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_LEVEL)]     = this.m_struct_obj.margin_level;
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_SO_CALL)]   = this.m_struct_obj.margin_so_call;
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_SO_SO)]     = this.m_struct_obj.margin_so_so;
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_INITIAL)]   = this.m_struct_obj.margin_initial;
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_MARGIN_MAINTENANCE)]=this.m_struct_obj.margin_maintenance;
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_ASSETS)]           = this.m_struct_obj.assets;
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_LIABILITIES)]      = this.m_struct_obj.liabilities;
     this.m_double_prop[this.IndexProp(ACCOUNT_PROP_COMMISSION_BLOCKED)]=this.m_struct_obj.comission_blocked;
    //--- Save string properties
     this.m_string_prop[this.IndexProp(ACCOUNT_PROP_NAME)]             = ::CharArrayToString(this.m_struct_obj.name);
     this.m_string_prop[this.IndexProp(ACCOUNT_PROP_SERVER)]           = ::CharArrayToString(this.m_struct_obj.server);
     this.m_string_prop[this.IndexProp(ACCOUNT_PROP_CURRENCY)]         = ::CharArrayToString(this.m_struct_obj.currency);
     this.m_string_prop[this.IndexProp(ACCOUNT_PROP_COMPANY)]          = ::CharArrayToString(this.m_struct_obj.company);
   }
  //+------------------------------------------------------------------+
  //| Send account properties to the journal                           |
  //+------------------------------------------------------------------+
  void CAccount::Print(const bool full_prop=false,const bool dash=false)
   {
    ::Print("============= ",CMessage::Text(MSG_LIB_PARAMS_LIST_BEG)," ==================");
    int begin=0, end=ACCOUNT_PROP_INTEGER_TOTAL;
    for(int i=begin; i<end; i++)
      {
       ENUM_ACCOUNT_PROP_INTEGER prop=(ENUM_ACCOUNT_PROP_INTEGER)i;
       if(!full_prop && !this.SupportProperty(prop)) continue;
       ::Print(this.GetPropertyDescription(prop));
      }
    ::Print("------");
    begin=end; end+=ACCOUNT_PROP_DOUBLE_TOTAL;
    for(int i=begin; i<end; i++)
      {
       ENUM_ACCOUNT_PROP_DOUBLE prop=(ENUM_ACCOUNT_PROP_DOUBLE)i;
       if(!full_prop && !this.SupportProperty(prop)) continue;
       ::Print(this.GetPropertyDescription(prop));
      }
    ::Print("------");
    begin=end; end+=ACCOUNT_PROP_STRING_TOTAL;
    for(int i=begin; i<end; i++)
      {
       ENUM_ACCOUNT_PROP_STRING prop=(ENUM_ACCOUNT_PROP_STRING)i;
       if(!full_prop && !this.SupportProperty(prop)) continue;
       ::Print(this.GetPropertyDescription(prop));
      }
    ::Print("================== ",CMessage::Text(MSG_LIB_PARAMS_LIST_END)," ==================\n");
   }
  //+------------------------------------------------------------------+
  //| Display a short account description in the journal               |
  //+------------------------------------------------------------------+
  void CAccount::PrintShort(const bool dash=false,const bool symbol=false)
   {
    string mode=(this.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING ? ", Hedge" : this.MarginMode()==ACCOUNT_MARGIN_MODE_EXCHANGE ? ", Exhange" : "");
    string names=this.m_name+" ";
    string values=::DoubleToString(this.Balance(),(int)this.CurrencyDigits())+" "+this.Currency()+", 1:"+(string)+this.Leverage()+mode+", "+this.TradeModeDescription()+" "+this.ServerTypeDescription();
    ::Print(names,values);
   }
  //+------------------------------------------------------------------+
  //| Return the description of the account integer property           |
  //+------------------------------------------------------------------+
  string CAccount::GetPropertyDescription(ENUM_ACCOUNT_PROP_INTEGER property)
   {
    return
      (
       property==ACCOUNT_PROP_LOGIN           ?  CMessage::Text(MSG_ACC_PROP_LOGIN)+": "+(string)this.GetProperty(property)                            :
       property==ACCOUNT_PROP_TRADE_MODE      ?  CMessage::Text(MSG_ACC_PROP_TRADE_MODE)+": "+this.TradeModeDescription()                              :
       property==ACCOUNT_PROP_LEVERAGE        ?  CMessage::Text(MSG_ACC_PROP_LEVERAGE)+": "+(string)this.GetProperty(property)                         :
       property==ACCOUNT_PROP_LIMIT_ORDERS    ?  CMessage::Text(MSG_ACC_PROP_LIMIT_ORDERS)+": "+(string)this.GetProperty(property)                     :
       property==ACCOUNT_PROP_MARGIN_SO_MODE  ?  CMessage::Text(MSG_ACC_PROP_MARGIN_SO_MODE)+": "+this.MarginSOModeDescription()                       :
       property==ACCOUNT_PROP_TRADE_ALLOWED   ?  CMessage::Text(MSG_ACC_PROP_TRADE_ALLOWED)+": "+
                                                   (this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))  :
       property==ACCOUNT_PROP_TRADE_EXPERT    ?  CMessage::Text(MSG_ACC_PROP_TRADE_EXPERT)+": "+
                                                   (this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))  :
       property==ACCOUNT_PROP_MARGIN_MODE     ?  CMessage::Text(MSG_ACC_PROP_MARGIN_MODE)+": "+this.MarginModeDescription()                            :
       property==ACCOUNT_PROP_CURRENCY_DIGITS ?  CMessage::Text(MSG_ACC_PROP_CURRENCY_DIGITS)+": "+(string)this.GetProperty(property)                  :
       property==ACCOUNT_PROP_SERVER_TYPE     ?  CMessage::Text(MSG_ACC_PROP_SERVER_TYPE)+": "+this.ServerTypeDescription()                            :
       property==ACCOUNT_PROP_FIFO_CLOSE      ?  CMessage::Text(MSG_ACC_PROP_FIFO_CLOSE)+": "+
                                                   (this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))  :
       property==ACCOUNT_PROP_HEDGE_ALLOWED   ?  CMessage::Text(MSG_ACC_PROP_HEDGE_ALLOWED)+": "+
                                                   (this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))  :
       ""
      );
   }
  //+------------------------------------------------------------------+
  //| Return the description of the account real property              |
  //+------------------------------------------------------------------+
  string CAccount::GetPropertyDescription(ENUM_ACCOUNT_PROP_DOUBLE property)
   {
    return
      (
       property==ACCOUNT_PROP_BALANCE            ?  CMessage::Text(MSG_ACC_PROP_BALANCE)+": "+
                                                   ::DoubleToString(this.GetProperty(property),(int)this.CurrencyDigits())+" "+this.Currency()  :
       property==ACCOUNT_PROP_CREDIT             ?  CMessage::Text(MSG_ACC_PROP_CREDIT)+": "+
                                                   ::DoubleToString(this.GetProperty(property),(int)this.CurrencyDigits())+" "+this.Currency()  :
       property==ACCOUNT_PROP_PROFIT             ?  CMessage::Text(MSG_ACC_PROP_PROFIT)+": "+
                                                   ::DoubleToString(this.GetProperty(property),(int)this.CurrencyDigits())+" "+this.Currency()  :
       property==ACCOUNT_PROP_EQUITY             ?  CMessage::Text(MSG_ACC_PROP_EQUITY)+": "+
                                                   ::DoubleToString(this.GetProperty(property),(int)this.CurrencyDigits())+" "+this.Currency()  :
       property==ACCOUNT_PROP_MARGIN             ?  CMessage::Text(MSG_ACC_PROP_MARGIN)+": "+
                                                   ::DoubleToString(this.GetProperty(property),(int)this.CurrencyDigits())+" "+this.Currency()  :
       property==ACCOUNT_PROP_MARGIN_FREE        ?  CMessage::Text(MSG_ACC_PROP_MARGIN_FREE)+": "+
                                                   ::DoubleToString(this.GetProperty(property),(int)this.CurrencyDigits())                      :
       property==ACCOUNT_PROP_MARGIN_LEVEL       ?  CMessage::Text(MSG_ACC_PROP_MARGIN_LEVEL)+": "+
                                                   ::DoubleToString(this.GetProperty(property),1)+"%"                                           :
       property==ACCOUNT_PROP_MARGIN_SO_CALL     ?  CMessage::Text(MSG_ACC_PROP_MARGIN_SO_CALL)+": "+
                                                   ::DoubleToString(this.GetProperty(property),(this.IsPercentsForSOLevels() ? 1 : (int)this.CurrencyDigits()))+
                                                   (this.IsPercentsForSOLevels() ? "%" : this.Currency())                                       :
       property==ACCOUNT_PROP_MARGIN_SO_SO       ?  CMessage::Text(MSG_ACC_PROP_MARGIN_SO_SO)+": "+
                                                   ::DoubleToString(this.GetProperty(property),(this.IsPercentsForSOLevels() ? 1 : (int)this.CurrencyDigits()))+
                                                   (this.IsPercentsForSOLevels() ? "%" : this.Currency())                                       :
       property==ACCOUNT_PROP_MARGIN_INITIAL     ?  CMessage::Text(MSG_ACC_PROP_MARGIN_INITIAL)+": "+
                                                   ::DoubleToString(this.GetProperty(property),(int)this.CurrencyDigits())                      :
       property==ACCOUNT_PROP_MARGIN_MAINTENANCE ? CMessage::Text(MSG_ACC_PROP_MARGIN_MAINTENANCE)+": "+
                                                   ::DoubleToString(this.GetProperty(property),(int)this.CurrencyDigits())                      :
       property==ACCOUNT_PROP_ASSETS             ?  CMessage::Text(MSG_ACC_PROP_ASSETS)+": "+
                                                   ::DoubleToString(this.GetProperty(property),(int)this.CurrencyDigits())                      :
       property==ACCOUNT_PROP_LIABILITIES        ?  CMessage::Text(MSG_ACC_PROP_LIABILITIES)+": "+
                                                   ::DoubleToString(this.GetProperty(property),(int)this.CurrencyDigits())                      :
       property==ACCOUNT_PROP_COMMISSION_BLOCKED ? CMessage::Text(MSG_ACC_PROP_COMMISSION_BLOCKED)+": "+
                                                   ::DoubleToString(this.GetProperty(property),(int)this.CurrencyDigits())                      :
       ""
      );
   }
  //+------------------------------------------------------------------+
  //| Return description of the account string property                |
  //+------------------------------------------------------------------+
  string CAccount::GetPropertyDescription(ENUM_ACCOUNT_PROP_STRING property)
   {
    return
      (
       property==ACCOUNT_PROP_NAME      ?  CMessage::Text(MSG_ACC_PROP_NAME)+": \""+this.GetProperty(property)+"\""      :
       property==ACCOUNT_PROP_SERVER    ?  CMessage::Text(MSG_ACC_PROP_SERVER)+": \""+this.GetProperty(property)+"\""    :
       property==ACCOUNT_PROP_CURRENCY  ?  CMessage::Text(MSG_ACC_PROP_CURRENCY)+": \""+this.GetProperty(property)+"\""  :
       property==ACCOUNT_PROP_COMPANY   ?  CMessage::Text(MSG_ACC_PROP_COMPANY)+": \""+this.GetProperty(property)+"\""   :
       ""
      );
   }
  //+------------------------------------------------------------------+
  //| Return a name of a trading account type                          |
  //+------------------------------------------------------------------+
  string CAccount::TradeModeDescription(void) const
   {
    return
      (
       this.TradeMode()==ACCOUNT_TRADE_MODE_DEMO    ? CMessage::Text(MSG_ACC_TRADE_MODE_DEMO)    :
       this.TradeMode()==ACCOUNT_TRADE_MODE_CONTEST ? CMessage::Text(MSG_ACC_TRADE_MODE_CONTEST) :
       this.TradeMode()==ACCOUNT_TRADE_MODE_REAL    ? CMessage::Text(MSG_ACC_TRADE_MODE_REAL)    :
       CMessage::Text(MSG_ACC_TRADE_MODE_UNKNOWN)
      );
   }
  //+------------------------------------------------------------------+
  //| Return a name of a trade server type                             |
  //+------------------------------------------------------------------+
  string CAccount::ServerTypeDescription(void) const
   {
    return(this.ServerType()==5 ? "MetaTrader 5" : "MetaTrader 4");
   }
  //+------------------------------------------------------------------+
  //| Return the description of the mode for setting                   |
  //| the minimum available margin level                               |
  //+------------------------------------------------------------------+
  string CAccount::MarginSOModeDescription(void) const
   {
    return
      (
       this.MarginSOMode()==ACCOUNT_STOPOUT_MODE_PERCENT  ? CMessage::Text(MSG_ACC_STOPOUT_MODE_PERCENT)  : 
       CMessage::Text(MSG_ACC_STOPOUT_MODE_MONEY)
      );
   }
  //+------------------------------------------------------------------+
  //| Return the description of the margin calculation mode            |
  //+------------------------------------------------------------------+
  string CAccount::MarginModeDescription(void) const
   {
    return
     (
      this.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_NETTING ? CMessage::Text(MSG_ACC_MARGIN_MODE_RETAIL_NETTING)  :
      this.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING ? CMessage::Text(MSG_ACC_MARGIN_MODE_RETAIL_HEDGING)  :
      CMessage::Text(MSG_ACC_MARGIN_MODE_RETAIL_EXCHANGE)
     );
   }
  //+------------------------------------------------------------------+
  //| Return the margin required for opening a position                |
  //| or placing a pending order                                       |
  //+------------------------------------------------------------------+
  double CAccount::MarginForAction(const ENUM_ORDER_TYPE action,const string symbol,const double volume,const double price) const
   {
    double margin=EMPTY_VALUE;
      #ifdef __MQL5__
         return(!::OrderCalcMargin(ENUM_ORDER_TYPE(action%2),symbol,volume,price,margin) ? EMPTY_VALUE : margin);
      #else 
         return this.MarginFree()-::AccountFreeMarginCheck(symbol,ENUM_ORDER_TYPE(action%2),volume);
      #endif
   }
  //+------------------------------------------------------------------+
#endif // CACCOUNT_MQH_IMPLEMENTATION
#endif // __ACCOUNT_MQH__