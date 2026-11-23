//+------------------------------------------------------------------+
//|                                                       Symbol.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/7014                 |
//|Topic link: https://www.mql5.com/en/articles/7229                 |
//|Link                      https://www.mql5.com/en/articles/10989  |
//|Link                      https://www.mql5.com/en/articles/10663  |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __SYMBOL_MQH__
#define __SYMBOL_MQH__
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
 #include "..\..\Entities\Bases\BaseObjExt.mqh"
 #include "..\Defines\TradingDefines.mqh"
 #include "..\..\Services\DELib\CommonDELib.mqh"
 #include "TradeObj.mqh"
 //#include "..\TradingExecution\TradeObj.mqh"

 #ifndef CSYMBOL_MQH_DECLARATION
 #define CSYMBOL_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Abstract symbol class                                            |
 //+------------------------------------------------------------------+
 class CSymbol : public CBaseObjExt
  {
   private: //Private variables
    struct MqlMarginRate
     {
      double         Initial;                                  // initial margin rate
      double         Maintenance;                              // maintenance margin rate
     };
    struct MqlMarginRateMode
     {
      MqlMarginRate  Long;                                     // MarginRate of long positions
      MqlMarginRate  Short;                                    // MarginRate of short positions
      MqlMarginRate  BuyStop;                                  // MarginRate of BuyStop orders
      MqlMarginRate  BuyLimit;                                 // MarginRate of BuyLimit orders
      MqlMarginRate  BuyStopLimit;                             // MarginRate of BuyStopLimit orders
      MqlMarginRate  SellStop;                                 // MarginRate of SellStop orders
      MqlMarginRate  SellLimit;                                // MarginRate of SellLimit orders
      MqlMarginRate  SellStopLimit;                            // MarginRate of SellStopLimit orders
     };
    MqlMarginRateMode m_margin_rate;                            // Margin ratio structure
    MqlBookInfo       m_book_info_array[];                      // Array of the market depth data structures
      
    long              m_long_prop[SYMBOL_PROP_INTEGER_TOTAL];   // Integer properties
    double            m_double_prop[SYMBOL_PROP_DOUBLE_TOTAL];  // Real properties
    string            m_string_prop[SYMBOL_PROP_STRING_TOTAL];  // String properties
    bool              m_is_change_trade_mode;                   // Flag of changing trading mode for a symbol
    bool              m_book_subscribed;                        // Flag of subscribing to the Depth of Market by symbol 
    //https://www.mql5.com/en/articles/7229     
     CTradeObj         m_trade_obj;                              // Trading class object
    //--- Return the index of the array the symbol's (1) double and (2) string properties are located at
     int               IndexProp(ENUM_SYMBOL_PROP_DOUBLE property)  const { return(int)property-SYMBOL_PROP_INTEGER_TOTAL;                                    }
     int               IndexProp(ENUM_SYMBOL_PROP_STRING property)  const { return(int)property-SYMBOL_PROP_INTEGER_TOTAL-SYMBOL_PROP_DOUBLE_TOTAL;           }
    //--- (1) Fill in all the "margin ratio" symbol properties, (2) initialize the ratios
     bool              MarginRates(void);
     void              InitMarginRates(void);
    //--- Reset all symbol object data
     void              Reset(void);
    //--- Return the current day of the week
     ENUM_DAY_OF_WEEK  CurrentDayOfWeek(void)              const;
   private: //Private methods
     int               SessionHours(const ulong duration_sec)       const;
     int               SessionMinutes(const ulong duration_sec)     const;
     int               SessionSeconds(const ulong duration_sec)     const;
   public:
      //--- Default constructor
                           CSymbol(void){ this.m_type=OBJECT_DE_TYPE_SYMBOL; }
      //--- Destructor
                        ~CSymbol(void);
   protected:
    //--- Protected parametric constructor
                        CSymbol(ENUM_SYMBOL_STATUS symbol_status,const string name,const int index);

    //--- Get and return integer properties of a selected symbol from its parameters
      bool              SymbolExists(const string name)     const;
      long              SymbolExists(void)                  const;
      long              SymbolCustom(void)                  const;
      long              SymbolChartMode(void)               const;
      long              SymbolMarginHedgedUseLEG(void)      const;
      long              SymbolOrderFillingMode(void)        const;
      long              SymbolOrderMode(void)               const;
      long              SymbolExpirationMode(void)          const;
      long              SymbolOrderGTCMode(void)            const;
      long              SymbolOptionMode(void)              const;
      long              SymbolOptionRight(void)             const;
      long              SymbolBackgroundColor(void)         const;
      long              SymbolCalcMode(void)                const;
      long              SymbolSwapMode(void)                const;
      long              SymbolSubscriptionDelay(void)       const;
      long              SymbolDigitsLot(void);
      int               SymbolDigitsBySwap(void);
    //--- Get and return real properties of a selected symbol from its parameters
      double            SymbolBidHigh(void)                 const;
      double            SymbolBidLow(void)                  const;
      double            SymbolVolumeReal(void)              const;
      double            SymbolVolumeHighReal(void)          const;
      double            SymbolVolumeLowReal(void)           const;
      double            SymbolOptionStrike(void)            const;
      double            SymbolTradeAccruedInterest(void)    const;
      double            SymbolTradeFaceValue(void)          const;
      double            SymbolTradeLiquidityRate(void)      const;
      double            SymbolMarginHedged(void)            const;
      double            SymbolSwapRatio(ENUM_DAY_OF_WEEK day)const;
      bool              SymbolMarginLong(void);
      bool              SymbolMarginShort(void);
      bool              SymbolMarginBuyStop(void);
      bool              SymbolMarginBuyLimit(void);
      bool              SymbolMarginBuyStopLimit(void);
      bool              SymbolMarginSellStop(void);
      bool              SymbolMarginSellLimit(void);
      bool              SymbolMarginSellStopLimit(void);
    //--- Get and return string properties of a selected symbol from its parameters
      string            SymbolBasis(void)                   const;
      string            SymbolBank(void)                    const;
      string            SymbolISIN(void)                    const;
      string            SymbolFormula(void)                 const;
      string            SymbolPage(void)                    const;
      string            SymbolCategory(void)                const;
      string            SymbolExchange(void)                const;
    //--- Search for a symbol and return the flag indicating its presence on the server
      bool              Exist(void)                         const;
   public:
    //--- Set (1) integer, (2) real and (3) string symbol properties
      void              SetProperty(ENUM_SYMBOL_PROP_INTEGER property,long value)   { this.m_long_prop[property]=value;                                        }
      void              SetProperty(ENUM_SYMBOL_PROP_DOUBLE property,double value)  { this.m_double_prop[this.IndexProp(property)]=value;                      }
      void              SetProperty(ENUM_SYMBOL_PROP_STRING property,string value)  { this.m_string_prop[this.IndexProp(property)]=value;                      }
    //--- Return (1) integer, (2) real and (3) string symbol properties from the properties array
      long              GetProperty(ENUM_SYMBOL_PROP_INTEGER property)        const { return this.m_long_prop[property];                                       }
      double            GetProperty(ENUM_SYMBOL_PROP_DOUBLE property)         const { return this.m_double_prop[this.IndexProp(property)];                     }
      string            GetProperty(ENUM_SYMBOL_PROP_STRING property)         const { return this.m_string_prop[this.IndexProp(property)];                     }

    //--- Return the flag of a symbol supporting the property
      virtual bool      SupportProperty(ENUM_SYMBOL_PROP_INTEGER property)          { return true; }
      virtual bool      SupportProperty(ENUM_SYMBOL_PROP_DOUBLE property)           { return true; }
      virtual bool      SupportProperty(ENUM_SYMBOL_PROP_STRING property)           { return true; }
      
    //--- Return the flag of allowing (1) market, (2) limit, (3) stop (4) and stop limit orders,
    //--- the flag of allowing setting (5) StopLoss and (6) TakeProfit orders, (7) as well as closing by an opposite order
      bool              IsMarketOrdersAllowed(void)            const { return((this.OrderModeFlags() & SYMBOL_ORDER_MARKET)==SYMBOL_ORDER_MARKET);             }
      bool              IsLimitOrdersAllowed(void)             const { return((this.OrderModeFlags() & SYMBOL_ORDER_LIMIT)==SYMBOL_ORDER_LIMIT);               }
      bool              IsStopOrdersAllowed(void)              const { return((this.OrderModeFlags() & SYMBOL_ORDER_STOP)==SYMBOL_ORDER_STOP);                 }
      bool              IsStopLimitOrdersAllowed(void)         const { return((this.OrderModeFlags() & SYMBOL_ORDER_STOP_LIMIT)==SYMBOL_ORDER_STOP_LIMIT);     }
      bool              IsStopLossOrdersAllowed(void)          const { return((this.OrderModeFlags() & SYMBOL_ORDER_SL)==SYMBOL_ORDER_SL);                     }
      bool              IsTakeProfitOrdersAllowed(void)        const { return((this.OrderModeFlags() & SYMBOL_ORDER_TP)==SYMBOL_ORDER_TP);                     }
      bool              IsCloseByOrdersAllowed(void)           const;

    //--- Return the (1) FOK and (2) IOC filling flag
      bool              IsFillingModeFOK(void)                 const { return((this.FillingModeFlags() & SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK);             }
      bool              IsFillingModeIOC(void)                 const { return((this.FillingModeFlags() & SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC);             }

    //--- Return the flag of order expiration: (1) GTC, (2) DAY, (3) Specified and (4) Specified Day
      bool              IsExpirationModeGTC(void)              const { return((this.ExpirationModeFlags() & SYMBOL_EXPIRATION_GTC)==SYMBOL_EXPIRATION_GTC);    }
      bool              IsExpirationModeDAY(void)              const { return((this.ExpirationModeFlags() & SYMBOL_EXPIRATION_DAY)==SYMBOL_EXPIRATION_DAY);    }
      bool              IsExpirationModeSpecified(void)        const { return((this.ExpirationModeFlags() & SYMBOL_EXPIRATION_SPECIFIED)==SYMBOL_EXPIRATION_SPECIFIED);          }
      bool              IsExpirationModeSpecifiedDay(void)     const { return((this.ExpirationModeFlags() & SYMBOL_EXPIRATION_SPECIFIED_DAY)==SYMBOL_EXPIRATION_SPECIFIED_DAY);  }

    //--- Return the description of allowing (1) market, (2) limit, (3) stop and (4) stop limit orders,
    //--- the description of allowing (5) StopLoss and (6) TakeProfit orders, (7) as well as closing by an opposite order
      string            GetMarketOrdersAllowedDescription(void)      const;
      string            GetLimitOrdersAllowedDescription(void)       const;
      string            GetStopOrdersAllowedDescription(void)        const;
      string            GetStopLimitOrdersAllowedDescription(void)   const;
      string            GetStopLossOrdersAllowedDescription(void)    const;
      string            GetTakeProfitOrdersAllowedDescription(void)  const;
      string            GetCloseByOrdersAllowedDescription(void)     const;

    //--- Return the description of allowing the filling type (1) FOK and (2) IOC, (3) as well as allowed order expiration modes
      string            GetFillingModeFOKAllowedDescrioption(void)   const;
      string            GetFillingModeIOCAllowedDescrioption(void)   const;

    //--- Return the description of order expiration: (1) GTC, (2) DAY, (3) Specified and (4) Specified Day
      string            GetExpirationModeGTCDescription(void)        const;
      string            GetExpirationModeDAYDescription(void)        const;
      string            GetExpirationModeSpecifiedDescription(void)  const;
      string            GetExpirationModeSpecDayDescription(void)    const;

    //--- Return the description of the (1) status, (2) price type for constructing bars, 
    //--- (3) method of calculating margin, (4) instrument trading mode,
    //--- (5) deal execution mode for a symbol, (6) swap calculation mode,
    //--- (7) StopLoss and TakeProfit lifetime, (8) option type, (9) option rights
    //--- flags of (10) allowed order types, (11) allowed filling types,
    //--- (12) allowed order expiration modes, (13) economy sector,
    //--- (14) industry or economy branch,
    //--- (15) swap accrual ratio for a specified day of the week
      string            GetStatusDescription(void)                   const;
      string            GetChartModeDescription(void)                const;
      string            GetCalcModeDescription(void)                 const;
      string            GetTradeModeDescription(void)                const;
      string            GetTradeExecDescription(void)                const;
      string            GetSwapModeDescription(void)                 const;
      string            GetOrderGTCModeDescription(void)             const;
      string            GetOptionTypeDescription(void)               const;
      string            GetOptionRightDescription(void)              const;
      string            GetOrderModeFlagsDescription(void)           const;
      string            GetFillingModeFlagsDescription(void)         const;
      string            GetExpirationModeFlagsDescription(void)      const;
      string            GetSectorDescription(void)                   const;
      string            GetIndustryDescription(void)                 const;
      string            GetSwapRatioDescription(const ENUM_DAY_OF_WEEK day)const;
      
    //--- Return (1) execution type, (2) order expiration type equal to 'type' if it is available on a symbol, otherwise - the correct option
      ENUM_ORDER_TYPE_FILLING GetCorrectTypeFilling(const uint type=ORDER_FILLING_RETURN);
      ENUM_ORDER_TYPE_TIME    GetCorrectTypeExpiration(uint expiration=ORDER_TIME_GTC);
    //+------------------------------------------------------------------+
    //| Description of symbol object properties                          |
    //+------------------------------------------------------------------+
    //--- Get description of a symbol (1) integer, (2) real and (3) string properties
      string            GetPropertyDescription(ENUM_SYMBOL_PROP_INTEGER property);
      string            GetPropertyDescription(ENUM_SYMBOL_PROP_DOUBLE property);
      string            GetPropertyDescription(ENUM_SYMBOL_PROP_STRING property);

    //--- Display the description of the object properties in the journal (full_prop=true - all properties, false - supported ones only - implemented in descendant classes)
      virtual void      Print(const bool full_prop=false,const bool dash=false);
    //--- Display a short description of the object in the journal
      virtual void      PrintShort(const bool dash=false,const bool symbol=false);

    //--- Compare CSymbol objects by all possible properties (for sorting lists by a specified symbol object property)
      virtual int       Compare(const CObject *node,const int mode=0) const;
    //--- Compare CSymbol objects by all properties (for searching for equal symbol objects)
      bool              IsEqual(CSymbol* compared_symbol) const;

    //--- Update all symbol data
      virtual void      Refresh(void);
    //--- Update quote data by a symbol
      bool              RefreshRates(void);

    //--- (1) Add, (2) remove a symbol from the Market Watch window, (3) return the data synchronization flag by a symbol
      bool              SetToMarketWatch(void)                       const { return ::SymbolSelect(this.m_name,true);      }
      bool              RemoveFromMarketWatch(void)                  const { return ::SymbolSelect(this.m_name,false);     }
      bool              IsSynchronized(void)                         const { return ::SymbolIsSynchronized(this.m_name);   }
    //--- Return the (1) start and (2) end time of the week day's quote session, (3) the start and end time of the required quote session
      long              SessionQuoteTimeFrom(const uint session_index,ENUM_DAY_OF_WEEK day_of_week=WRONG_VALUE)   const;
      long              SessionQuoteTimeTo(const uint session_index,ENUM_DAY_OF_WEEK day_of_week=WRONG_VALUE)     const;
      bool              GetSessionQuote(const uint session_index,ENUM_DAY_OF_WEEK day_of_week,datetime &from,datetime &to);
    //--- Return the (1) start and (2) end time of the week day's trading session, (3) the start and end time of the required trading session
      long              SessionTradeTimeFrom(const uint session_index,ENUM_DAY_OF_WEEK day_of_week=WRONG_VALUE)   const;
      long              SessionTradeTimeTo(const uint session_index,ENUM_DAY_OF_WEEK day_of_week=WRONG_VALUE)     const;
      bool              GetSessionTrade(const uint session_index,ENUM_DAY_OF_WEEK day_of_week,datetime &from,datetime &to);
    //--- (1) Perform (1) subscription to DOM and (2) closing DOM
      bool              BookAdd(void);
      bool              BookClose(void);
    //--- Return (1) a session duration description in the hh:mm:ss format, number of (1) hours, (2) minutes and (3) seconds in the session duration time
      string            SessionDurationDescription(const ulong duration_sec) const;
    //+------------------------------------------------------------------+
    //| Methods of a simplified access to the order object properties    |
    //+------------------------------------------------------------------+
    //--- Integer properties
      long              Status(void)                                 const { return this.GetProperty(SYMBOL_PROP_STATUS);                                      }
      int               IndexInMarketWatch(void)                     const { return (int)this.GetProperty(SYMBOL_PROP_INDEX_MW);                               }
      ENUM_SYMBOL_SECTOR Sector(void)                                const { return (ENUM_SYMBOL_SECTOR)this.GetProperty(SYMBOL_PROP_SECTOR);                  }
      ENUM_SYMBOL_INDUSTRY Industry(void)                            const { return (ENUM_SYMBOL_INDUSTRY)this.GetProperty(SYMBOL_PROP_INDUSTRY);              }
      bool              IsCustom(void)                               const { return (bool)this.GetProperty(SYMBOL_PROP_CUSTOM);                                }
      color             ColorBackground(void)                        const { return (color)this.GetProperty(SYMBOL_PROP_BACKGROUND_COLOR);                     }
      ENUM_SYMBOL_CHART_MODE ChartMode(void)                         const { return (ENUM_SYMBOL_CHART_MODE)this.GetProperty(SYMBOL_PROP_CHART_MODE);          }
      bool              IsExist(void)                                const { return (bool)this.GetProperty(SYMBOL_PROP_EXIST);                                 }
      bool              IsExist(const string name)                   const { return this.SymbolExists(name);                                                   }
      bool              IsSelect(void)                               const { return (bool)this.GetProperty(SYMBOL_PROP_SELECT);                                }
      bool              IsVisible(void)                              const { return (bool)this.GetProperty(SYMBOL_PROP_VISIBLE);                               }
      long              SessionDeals(void)                           const { return this.GetProperty(SYMBOL_PROP_SESSION_DEALS);                               }
      long              SessionBuyOrders(void)                       const { return this.GetProperty(SYMBOL_PROP_SESSION_BUY_ORDERS);                          }
      long              SessionSellOrders(void)                      const { return this.GetProperty(SYMBOL_PROP_SESSION_SELL_ORDERS);                         }
      long              Volume(void)                                 const { return this.GetProperty(SYMBOL_PROP_VOLUME);                                      }
      long              VolumeHigh(void)                             const { return this.GetProperty(SYMBOL_PROP_VOLUMEHIGH);                                  }
      long              VolumeLow(void)                              const { return this.GetProperty(SYMBOL_PROP_VOLUMELOW);                                   }
      long              Time(void)                                   const { return (datetime)this.GetProperty(SYMBOL_PROP_TIME);                              }
      long              TimeMSC(void)                                const { return (long)this.GetProperty(SYMBOL_PROP_TIME_MSC);                              }
      int               Digits(void)                                 const { return (int)this.GetProperty(SYMBOL_PROP_DIGITS);                                 }
      int               DigitsLot(void)                              const { return (int)this.GetProperty(SYMBOL_PROP_DIGITS_LOTS);                            }
      int               Spread(void)                                 const { return (int)this.GetProperty(SYMBOL_PROP_SPREAD);                                 }
      bool              IsSpreadFloat(void)                          const { return (bool)this.GetProperty(SYMBOL_PROP_SPREAD_FLOAT);                          }
      int               TicksBookdepth(void)                         const { return (int)this.GetProperty(SYMBOL_PROP_TICKS_BOOKDEPTH);                        }
      bool              BookdepthSubscription(void)                  const { return (bool)this.GetProperty(SYMBOL_PROP_BOOKDEPTH_STATE);                       }
      ENUM_SYMBOL_CALC_MODE TradeCalcMode(void)                      const { return (ENUM_SYMBOL_CALC_MODE)this.GetProperty(SYMBOL_PROP_TRADE_CALC_MODE);      }
      ENUM_SYMBOL_TRADE_MODE TradeMode(void)                         const { return (ENUM_SYMBOL_TRADE_MODE)this.GetProperty(SYMBOL_PROP_TRADE_MODE);          }
      datetime          StartTime(void)                              const { return (datetime)this.GetProperty(SYMBOL_PROP_START_TIME);                        }
      datetime          ExpirationTime(void)                         const { return (datetime)this.GetProperty(SYMBOL_PROP_EXPIRATION_TIME);                   }
      int               TradeStopLevel(void)                         const { return (int)this.GetProperty(SYMBOL_PROP_TRADE_STOPS_LEVEL);                      }
      int               TradeFreezeLevel(void)                       const { return (int)this.GetProperty(SYMBOL_PROP_TRADE_FREEZE_LEVEL);                     }
      ENUM_SYMBOL_TRADE_EXECUTION TradeExecutionMode(void)           const { return (ENUM_SYMBOL_TRADE_EXECUTION)this.GetProperty(SYMBOL_PROP_TRADE_EXEMODE);  }
      ENUM_SYMBOL_SWAP_MODE SwapMode(void)                           const { return (ENUM_SYMBOL_SWAP_MODE)this.GetProperty(SYMBOL_PROP_SWAP_MODE);            }
      ENUM_DAY_OF_WEEK  SwapRollover3Days(void)                      const { return (ENUM_DAY_OF_WEEK)this.GetProperty(SYMBOL_PROP_SWAP_ROLLOVER3DAYS);        }
      bool              IsMarginHedgedUseLeg(void)                   const { return (bool)this.GetProperty(SYMBOL_PROP_MARGIN_HEDGED_USE_LEG);                 }
      int               ExpirationModeFlags(void)                    const { return (int)this.GetProperty(SYMBOL_PROP_EXPIRATION_MODE);                        }
      int               FillingModeFlags(void)                       const { return (int)this.GetProperty(SYMBOL_PROP_FILLING_MODE);                           }
      int               OrderModeFlags(void)                         const { return (int)this.GetProperty(SYMBOL_PROP_ORDER_MODE);                             }
      ENUM_SYMBOL_ORDER_GTC_MODE OrderModeGTC(void)                  const { return (ENUM_SYMBOL_ORDER_GTC_MODE)this.GetProperty(SYMBOL_PROP_ORDER_GTC_MODE);  }
      ENUM_SYMBOL_OPTION_MODE OptionMode(void)                       const { return (ENUM_SYMBOL_OPTION_MODE)this.GetProperty(SYMBOL_PROP_OPTION_MODE);        }
      ENUM_SYMBOL_OPTION_RIGHT OptionRight(void)                     const { return (ENUM_SYMBOL_OPTION_RIGHT)this.GetProperty(SYMBOL_PROP_OPTION_RIGHT);      }
      long              SubscriptionDelay(void)                      const { return this.GetProperty(SYMBOL_PROP_SUBSCRIPTION_DELAY);                          }
    //--- Real properties
      double            Bid(void)                                    const { return this.GetProperty(SYMBOL_PROP_BID);                                         }
      double            BidHigh(void)                                const { return this.GetProperty(SYMBOL_PROP_BIDHIGH);                                     }
      double            BidLow(void)                                 const { return this.GetProperty(SYMBOL_PROP_BIDLOW);                                      }
      double            Ask(void)                                    const { return this.GetProperty(SYMBOL_PROP_ASK);                                         }
      double            AskHigh(void)                                const { return this.GetProperty(SYMBOL_PROP_ASKHIGH);                                     }
      double            AskLow(void)                                 const { return this.GetProperty(SYMBOL_PROP_ASKLOW);                                      }
      double            Last(void)                                   const { return this.GetProperty(SYMBOL_PROP_LAST);                                        }
      double            LastHigh(void)                               const { return this.GetProperty(SYMBOL_PROP_LASTHIGH);                                    }
      double            LastLow(void)                                const { return this.GetProperty(SYMBOL_PROP_LASTLOW);                                     }
      double            VolumeReal(void)                             const { return this.GetProperty(SYMBOL_PROP_VOLUME_REAL);                                 }
      double            VolumeHighReal(void)                         const { return this.GetProperty(SYMBOL_PROP_VOLUMEHIGH_REAL);                             }
      double            VolumeLowReal(void)                          const { return this.GetProperty(SYMBOL_PROP_VOLUMELOW_REAL);                              }
      double            OptionStrike(void)                           const { return this.GetProperty(SYMBOL_PROP_OPTION_STRIKE);                               }
      double            Point(void)                                  const { return this.GetProperty(SYMBOL_PROP_POINT);                                       }
      double            TradeTickValue(void)                         const { return this.GetProperty(SYMBOL_PROP_TRADE_TICK_VALUE);                            }
      double            TradeTickValueProfit(void)                   const { return this.GetProperty(SYMBOL_PROP_TRADE_TICK_VALUE_PROFIT);                     }
      double            TradeTickValueLoss(void)                     const { return this.GetProperty(SYMBOL_PROP_TRADE_TICK_VALUE_LOSS);                       }
      double            TradeTickSize(void)                          const { return this.GetProperty(SYMBOL_PROP_TRADE_TICK_SIZE);                             }
      double            TradeContractSize(void)                      const { return this.GetProperty(SYMBOL_PROP_TRADE_CONTRACT_SIZE);                         }
      double            TradeAccuredInterest(void)                   const { return this.GetProperty(SYMBOL_PROP_TRADE_ACCRUED_INTEREST);                      }
      double            TradeFaceValue(void)                         const { return this.GetProperty(SYMBOL_PROP_TRADE_FACE_VALUE);                            }
      double            TradeLiquidityRate(void)                     const { return this.GetProperty(SYMBOL_PROP_TRADE_LIQUIDITY_RATE);                        }
      double            LotsMin(void)                                const { return this.GetProperty(SYMBOL_PROP_VOLUME_MIN);                                  }
      double            LotsMax(void)                                const { return this.GetProperty(SYMBOL_PROP_VOLUME_MAX);                                  }
      double            LotsStep(void)                               const { return this.GetProperty(SYMBOL_PROP_VOLUME_STEP);                                 }
      double            VolumeLimit(void)                            const { return this.GetProperty(SYMBOL_PROP_VOLUME_LIMIT);                                }
      double            SwapLong(void)                               const { return this.GetProperty(SYMBOL_PROP_SWAP_LONG);                                   }
      double            SwapShort(void)                              const { return this.GetProperty(SYMBOL_PROP_SWAP_SHORT);                                  }
      double            MarginInitial(void)                          const { return this.GetProperty(SYMBOL_PROP_MARGIN_INITIAL);                              }
      double            MarginMaintenance(void)                      const { return this.GetProperty(SYMBOL_PROP_MARGIN_MAINTENANCE);                          }
      double            MarginLongInitial(void)                      const { return this.GetProperty(SYMBOL_PROP_MARGIN_LONG_INITIAL);                         }
      double            MarginBuyStopInitial(void)                   const { return this.GetProperty(SYMBOL_PROP_MARGIN_BUY_STOP_INITIAL);                     }
      double            MarginBuyLimitInitial(void)                  const { return this.GetProperty(SYMBOL_PROP_MARGIN_BUY_LIMIT_INITIAL);                    }
      double            MarginBuyStopLimitInitial(void)              const { return this.GetProperty(SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_INITIAL);                }
      double            MarginLongMaintenance(void)                  const { return this.GetProperty(SYMBOL_PROP_MARGIN_LONG_MAINTENANCE);                     }
      double            MarginBuyStopMaintenance(void)               const { return this.GetProperty(SYMBOL_PROP_MARGIN_BUY_STOP_MAINTENANCE);                 }
      double            MarginBuyLimitMaintenance(void)              const { return this.GetProperty(SYMBOL_PROP_MARGIN_BUY_LIMIT_MAINTENANCE);                }
      double            MarginBuyStopLimitMaintenance(void)          const { return this.GetProperty(SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_MAINTENANCE);            }
      double            MarginShortInitial(void)                     const { return this.GetProperty(SYMBOL_PROP_MARGIN_SHORT_INITIAL);                        }
      double            MarginSellStopInitial(void)                  const { return this.GetProperty(SYMBOL_PROP_MARGIN_SELL_STOP_INITIAL);                    }
      double            MarginSellLimitInitial(void)                 const { return this.GetProperty(SYMBOL_PROP_MARGIN_SELL_LIMIT_INITIAL);                   }
      double            MarginSellStopLimitInitial(void)             const { return this.GetProperty(SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_INITIAL);               }
      double            MarginShortMaintenance(void)                 const { return this.GetProperty(SYMBOL_PROP_MARGIN_SHORT_MAINTENANCE);                    }
      double            MarginSellStopMaintenance(void)              const { return this.GetProperty(SYMBOL_PROP_MARGIN_SELL_STOP_MAINTENANCE);                }
      double            MarginSellLimitMaintenance(void)             const { return this.GetProperty(SYMBOL_PROP_MARGIN_SELL_LIMIT_MAINTENANCE);               }
      double            MarginSellStopLimitMaintenance(void)         const { return this.GetProperty(SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_MAINTENANCE);           }
      double            SessionVolume(void)                          const { return this.GetProperty(SYMBOL_PROP_SESSION_VOLUME);                              }
      double            SessionTurnover(void)                        const { return this.GetProperty(SYMBOL_PROP_SESSION_TURNOVER);                            }
      double            SessionInterest(void)                        const { return this.GetProperty(SYMBOL_PROP_SESSION_INTEREST);                            }
      double            SessionBuyOrdersVolume(void)                 const { return this.GetProperty(SYMBOL_PROP_SESSION_BUY_ORDERS_VOLUME);                   }
      double            SessionSellOrdersVolume(void)                const { return this.GetProperty(SYMBOL_PROP_SESSION_SELL_ORDERS_VOLUME);                  }
      double            SessionOpen(void)                            const { return this.GetProperty(SYMBOL_PROP_SESSION_OPEN);                                }
      double            SessionClose(void)                           const { return this.GetProperty(SYMBOL_PROP_SESSION_CLOSE);                               }
      double            SessionAW(void)                              const { return this.GetProperty(SYMBOL_PROP_SESSION_AW);                                  }
      double            SessionPriceSettlement(void)                 const { return this.GetProperty(SYMBOL_PROP_SESSION_PRICE_SETTLEMENT);                    }
      double            SessionPriceLimitMin(void)                   const { return this.GetProperty(SYMBOL_PROP_SESSION_PRICE_LIMIT_MIN);                     }
      double            SessionPriceLimitMax(void)                   const { return this.GetProperty(SYMBOL_PROP_SESSION_PRICE_LIMIT_MAX);                     }
      double            MarginHedged(void)                           const { return this.GetProperty(SYMBOL_PROP_MARGIN_HEDGED);                               }
      double            PriceChange(void)                            const { return this.GetProperty(SYMBOL_PROP_PRICE_CHANGE);                                }
      double            PriceVolatility(void)                        const { return this.GetProperty(SYMBOL_PROP_PRICE_VOLATILITY);                            }
      double            PriceTheoretical(void)                       const { return this.GetProperty(SYMBOL_PROP_PRICE_THEORETICAL);                           }
      double            PriceDelta(void)                             const { return this.GetProperty(SYMBOL_PROP_PRICE_DELTA);                                 }
      double            PriceTheta(void)                             const { return this.GetProperty(SYMBOL_PROP_PRICE_THETA);                                 }
      double            PriceGamma(void)                             const { return this.GetProperty(SYMBOL_PROP_PRICE_GAMMA);                                 }
      double            PriceVega(void)                              const { return this.GetProperty(SYMBOL_PROP_PRICE_VEGA);                                  }
      double            PriceRho(void)                               const { return this.GetProperty(SYMBOL_PROP_PRICE_RHO);                                   }
      double            PriceOmega(void)                             const { return this.GetProperty(SYMBOL_PROP_PRICE_OMEGA);                                 }
      double            PriceSensitivity(void)                       const { return this.GetProperty(SYMBOL_PROP_PRICE_SENSITIVITY);                           }
      double            SwapRatioSunday(void)                        const { return this.GetProperty(SYMBOL_PROP_SWAP_SUNDAY);                                 }
      double            SwapRatioMonday(void)                        const { return this.GetProperty(SYMBOL_PROP_SWAP_MONDAY);                                 }
      double            SwapRatioTuesday(void)                       const { return this.GetProperty(SYMBOL_PROP_SWAP_TUESDAY);                                }
      double            SwapRatioWednesday(void)                     const { return this.GetProperty(SYMBOL_PROP_SWAP_WEDNESDAY);                              }
      double            SwapRatioThursday(void)                      const { return this.GetProperty(SYMBOL_PROP_SWAP_THURSDAY);                               }
      double            SwapRatioFriday(void)                        const { return this.GetProperty(SYMBOL_PROP_SWAP_FRIDAY);                                 }
      double            SwapRatioSaturday(void)                      const { return this.GetProperty(SYMBOL_PROP_SWAP_SATURDAY);                               }
      double            SwapRatioDay(const ENUM_DAY_OF_WEEK day)     const;
      double            NormalizedPrice(const double price)          const;
      double            NormalizedLot(const double volume)           const;
      double            BidLast(void)                                const;
      double            BidLastHigh(void)                            const;
      double            BidLastLow(void)                             const;
      double            AskLast(void)                                const;
      double            AskLastHigh(void)                            const;
      double            AskLastLow(void)                             const;
    //--- String properties
      string            Name(void)                                   const { return this.GetProperty(SYMBOL_PROP_NAME);                                        }
      string            Basis(void)                                  const { return this.GetProperty(SYMBOL_PROP_BASIS);                                       }
      string            CurrencyBase(void)                           const { return this.GetProperty(SYMBOL_PROP_CURRENCY_BASE);                               }
      string            CurrencyProfit(void)                         const { return this.GetProperty(SYMBOL_PROP_CURRENCY_PROFIT);                             }
      string            CurrencyMargin(void)                         const { return this.GetProperty(SYMBOL_PROP_CURRENCY_MARGIN);                             }
      string            Bank(void)                                   const { return this.GetProperty(SYMBOL_PROP_BANK);                                        }
      string            Description(void)                            const { return this.GetProperty(SYMBOL_PROP_DESCRIPTION);                                 }
      string            Formula(void)                                const { return this.GetProperty(SYMBOL_PROP_FORMULA);                                     }
      string            ISIN(void)                                   const { return this.GetProperty(SYMBOL_PROP_ISIN);                                        }
      string            Page(void)                                   const { return this.GetProperty(SYMBOL_PROP_PAGE);                                        }
      string            Path(void)                                   const { return this.GetProperty(SYMBOL_PROP_PATH);                                        }
      string            Category(void)                               const { return this.GetProperty(SYMBOL_PROP_CATEGORY);                                    }
      string            Exchange(void)                               const { return this.GetProperty(SYMBOL_PROP_EXCHANGE);                                    }
      string            Country(void)                                const { return this.GetProperty(SYMBOL_PROP_COUNTRY);                                     }
      string            SectorName(void)                             const { return this.GetProperty(SYMBOL_PROP_SECTOR_NAME);                                 }
      string            IndustryName(void)                           const { return this.GetProperty(SYMBOL_PROP_INDUSTRY_NAME);                               }
    //+------------------------------------------------------------------+
    //| Get and set the parameters of tracked property changes           |
    //+------------------------------------------------------------------+
      //--- Execution
      //--- Flag of changing the trading mode for a symbol
         bool              IsChangedTradeMode(void)                              const { return this.m_is_change_trade_mode;                                               } 
      //--- Current session deals
      //--- setting the controlled value of (1) growth, (2) decrease and (3) control level of the number of deals during the current session
      //--- getting (3) the number of deals change value during the current session,
      //--- getting the flag of the number of deals change during the current session exceeding the (4) increase, (5) decrease value
         void              SetControlSessionDealsInc(const long value)                 { this.SetControlledValueINC(SYMBOL_PROP_SESSION_DEALS,(long)::fabs(value));        }
         void              SetControlSessionDealsDec(const long value)                 { this.SetControlledValueDEC(SYMBOL_PROP_SESSION_DEALS,(long)::fabs(value));        }
         void              SetControlSessionDealsLevel(const long value)               { this.SetControlledValueLEVEL(SYMBOL_PROP_SESSION_DEALS,(long)::fabs(value));      }
         long              GetValueChangedSessionDeals(void)                     const { return this.GetPropLongChangedValue(SYMBOL_PROP_SESSION_DEALS);                   }
         bool              IsIncreasedSessionDeals(void)                         const { return (bool)this.GetPropLongFlagINC(SYMBOL_PROP_SESSION_DEALS);                  }
         bool              IsDecreasedSessionDeals(void)                         const { return (bool)this.GetPropLongFlagDEC(SYMBOL_PROP_SESSION_DEALS);                  }
      //--- Buy orders of the current session
      //--- setting the controlled value of (1) increase, (2) decrease and (3) control level of the current number of Buy orders
      //--- getting (4) the current number of Buy orders change value,
      //--- getting the flag of the current Buy orders' number change exceeding the (5) increase, (6) decrease value
         void              SetControlSessionBuyOrdInc(const long value)                { this.SetControlledValueINC(SYMBOL_PROP_SESSION_BUY_ORDERS,(long)::fabs(value));   }
         void              SetControlSessionBuyOrdDec(const long value)                { this.SetControlledValueDEC(SYMBOL_PROP_SESSION_BUY_ORDERS,(long)::fabs(value));   }
         void              SetControlSessionBuyOrdLevel(const long value)              { this.SetControlledValueLEVEL(SYMBOL_PROP_SESSION_BUY_ORDERS,(long)::fabs(value)); }
         long              GetValueChangedSessionBuyOrders(void)                 const { return this.GetPropLongChangedValue(SYMBOL_PROP_SESSION_BUY_ORDERS);              }
         bool              IsIncreasedSessionBuyOrders(void)                     const { return (bool)this.GetPropLongFlagINC(SYMBOL_PROP_SESSION_BUY_ORDERS);             }
         bool              IsDecreasedSessionBuyOrders(void)                     const { return (bool)this.GetPropLongFlagDEC(SYMBOL_PROP_SESSION_BUY_ORDERS);             }
      //--- Sell orders of the current session
      //--- setting the controlled value of (1) increase, (2) decrease and (3) control level of the current number of Sell orders
      //--- getting (4) the current number of Sell orders change value,
      //--- getting the flag of the current Sell orders' number change exceeding the (5) increase, (6) decrease value
         void              SetControlSessionSellOrdInc(const long value)               { this.SetControlledValueINC(SYMBOL_PROP_SESSION_SELL_ORDERS,(long)::fabs(value));  }
         void              SetControlSessionSellOrdDec(const long value)               { this.SetControlledValueDEC(SYMBOL_PROP_SESSION_SELL_ORDERS,(long)::fabs(value));  }
         void              SetControlSessionSellOrdLevel(const long value)             { this.SetControlledValueLEVEL(SYMBOL_PROP_SESSION_SELL_ORDERS,(long)::fabs(value));}
         long              GetValueChangedSessionSellOrders(void)                const { return this.GetPropLongChangedValue(SYMBOL_PROP_SESSION_SELL_ORDERS);             }
         bool              IsIncreasedSessionSellOrders(void)                    const { return (bool)this.GetPropLongFlagINC(SYMBOL_PROP_SESSION_SELL_ORDERS);            }
         bool              IsDecreasedSessionSellOrders(void)                    const { return (bool)this.GetPropLongFlagDEC(SYMBOL_PROP_SESSION_SELL_ORDERS);            }
      //--- Volume of the last deal
      //--- setting the last deal volume controlled (1) increase, (2) decrease and (3) control level
      //--- getting (4) volume change values in the last deal,
      //--- getting the flag of the volume change in the last deal exceeding the (5) increase, (6) decrease value
         void              SetControlVolumeInc(const long value)                       { this.SetControlledValueINC(SYMBOL_PROP_VOLUME,(long)::fabs(value));               }
         void              SetControlVolumeDec(const long value)                       { this.SetControlledValueDEC(SYMBOL_PROP_VOLUME,(long)::fabs(value));               }
         void              SetControlVolumeLevel(const long value)                     { this.SetControlledValueLEVEL(SYMBOL_PROP_VOLUME,(long)::fabs(value));             }
         long              GetValueChangedVolume(void)                           const { return this.GetPropLongChangedValue(SYMBOL_PROP_VOLUME);                          }
         bool              IsIncreasedVolume(void)                               const { return (bool)this.GetPropLongFlagINC(SYMBOL_PROP_VOLUME);                         }
         bool              IsDecreasedVolume(void)                               const { return (bool)this.GetPropLongFlagDEC(SYMBOL_PROP_VOLUME);                         }
      //--- Maximum volume within a day
      //--- setting the maximum day volume controlled (1) increase, (2) decrease and (3) control level
      //--- getting (4) the maximum volume change value within a day,
      //--- getting the flag of the maximum day volume change exceeding the (5) increase, (6) decrease value
         void              SetControlVolumeHighInc(const long value)                   { this.SetControlledValueINC(SYMBOL_PROP_VOLUMEHIGH,(long)::fabs(value));           }
         void              SetControlVolumeHighDec(const long value)                   { this.SetControlledValueDEC(SYMBOL_PROP_VOLUMEHIGH,(long)::fabs(value));           }
         void              SetControlVolumeHighLevel(const long value)                 { this.SetControlledValueLEVEL(SYMBOL_PROP_VOLUMEHIGH,(long)::fabs(value));         }
         long              GetValueChangedVolumeHigh(void)                       const { return this.GetPropLongChangedValue(SYMBOL_PROP_VOLUMEHIGH);                      }
         bool              IsIncreasedVolumeHigh(void)                           const { return (bool)this.GetPropLongFlagINC(SYMBOL_PROP_VOLUMEHIGH);                     }
         bool              IsDecreasedVolumeHigh(void)                           const { return (bool)this.GetPropLongFlagDEC(SYMBOL_PROP_VOLUMEHIGH);                     }
      //--- Minimum volume within a day
      //--- setting the minimum day volume controlled (1) increase, (2) decrease and (3) control level
      //--- getting (4) the minimum volume change value within a day,
      //--- getting the flag of the minimum day volume change exceeding the (5) increase, (6) decrease value
         void              SetControlVolumeLowInc(const long value)                    { this.SetControlledValueINC(SYMBOL_PROP_VOLUMELOW,(long)::fabs(value));            }
         void              SetControlVolumeLowDec(const long value)                    { this.SetControlledValueDEC(SYMBOL_PROP_VOLUMELOW,(long)::fabs(value));            }
         void              SetControlVolumeLowLevel(const long value)                  { this.SetControlledValueLEVEL(SYMBOL_PROP_VOLUMELOW,(long)::fabs(value));          }
         long              GetValueChangedVolumeLow(void)                        const { return this.GetPropLongChangedValue(SYMBOL_PROP_VOLUMELOW);                       }
         bool              IsIncreasedVolumeLow(void)                            const { return (bool)this.GetPropLongFlagINC(SYMBOL_PROP_VOLUMELOW);                      }
         bool              IsDecreasedVolumeLow(void)                            const { return (bool)this.GetPropLongFlagDEC(SYMBOL_PROP_VOLUMELOW);                      }
      //--- Spread
      //--- setting the controlled spread (1) increase, (2) decrease value and (3) control level in points
      //--- getting (4) spread change value in points,
      //--- getting the flag of the spread change in points exceeding the (5) increase, (6) decrease value
         void              SetControlSpreadInc(const int value)                        { this.SetControlledValueINC(SYMBOL_PROP_SPREAD,(long)::fabs(value));               }
         void              SetControlSpreadDec(const int value)                        { this.SetControlledValueDEC(SYMBOL_PROP_SPREAD,(long)::fabs(value));               }
         void              SetControlSpreadLevel(const int value)                      { this.SetControlledValueLEVEL(SYMBOL_PROP_SPREAD,(long)::fabs(value));             }
         int               GetValueChangedSpread(void)                           const { return (int)this.GetPropLongChangedValue(SYMBOL_PROP_SPREAD);                     }
         bool              IsIncreasedSpread(void)                               const { return (bool)this.GetPropLongFlagINC(SYMBOL_PROP_SPREAD);                         }
         bool              IsDecreasedSpread(void)                               const { return (bool)this.GetPropLongFlagDEC(SYMBOL_PROP_SPREAD);                         }
      //--- StopLevel
      //--- setting the controlled StopLevel (1) increase, (2) decrease value and (3) control level in points
      //--- getting (4) StopLevel change value in points,
      //--- getting the flag of StopLevel change in points exceeding the (5) increase, (6) decrease value
         void              SetControlStopLevelInc(const int value)                     { this.SetControlledValueINC(SYMBOL_PROP_TRADE_STOPS_LEVEL,(long)::fabs(value));    }
         void              SetControlStopLevelDec(const int value)                     { this.SetControlledValueDEC(SYMBOL_PROP_TRADE_STOPS_LEVEL,(long)::fabs(value));    }
         void              SetControlStopLevelLevel(const int value)                   { this.SetControlledValueLEVEL(SYMBOL_PROP_TRADE_STOPS_LEVEL,(long)::fabs(value));  }
         int               GetValueChangedStopLevel(void)                        const { return (int)this.GetPropLongChangedValue(SYMBOL_PROP_TRADE_STOPS_LEVEL);          }
         bool              IsIncreasedStopLevel(void)                            const { return (bool)this.GetPropLongFlagINC(SYMBOL_PROP_TRADE_STOPS_LEVEL);              }
         bool              IsDecreasedStopLevel(void)                            const { return (bool)this.GetPropLongFlagDEC(SYMBOL_PROP_TRADE_STOPS_LEVEL);              }
      //--- Freeze distance
      //--- setting the controlled FreezeLevel (1) increase, (2) decrease value and (3) control level in points
      //--- getting (4) FreezeLevel change value in points,
      //--- getting the flag of FreezeLevel change in points exceeding the (5) increase, (6) decrease value
         void              SetControlFreezeLevelInc(const int value)                   { this.SetControlledValueINC(SYMBOL_PROP_TRADE_FREEZE_LEVEL,(long)::fabs(value));   }
         void              SetControlFreezeLevelDec(const int value)                   { this.SetControlledValueDEC(SYMBOL_PROP_TRADE_FREEZE_LEVEL,(long)::fabs(value));   }
         void              SetControlFreezeLevelLevel(const int value)                 { this.SetControlledValueLEVEL(SYMBOL_PROP_TRADE_FREEZE_LEVEL,(long)::fabs(value)); }
         int               GetValueChangedFreezeLevel(void)                      const { return (int)this.GetPropLongChangedValue(SYMBOL_PROP_TRADE_FREEZE_LEVEL);         }
         bool              IsIncreasedFreezeLevel(void)                          const { return (bool)this.GetPropLongFlagINC(SYMBOL_PROP_TRADE_FREEZE_LEVEL);             }
         bool              IsDecreasedFreezeLevel(void)                          const { return (bool)this.GetPropLongFlagDEC(SYMBOL_PROP_TRADE_FREEZE_LEVEL);             }
      
      //--- Bid
      //--- setting the controlled Bid price (1) increase, (2) decrease value and (3) control level in points
      //--- getting (4) Bid or Last price change value,
      //--- getting the flag of the Bid or Last price change exceeding the (5) increase, (6) decrease value
         void              SetControlBidInc(const double value)                        { this.SetControlledValueINC(SYMBOL_PROP_BID,::fabs(value));                        }
         void              SetControlBidDec(const double value)                        { this.SetControlledValueDEC(SYMBOL_PROP_BID,::fabs(value));                        }
         void              SetControlBidLevel(const double value)                      { this.SetControlledValueLEVEL(SYMBOL_PROP_BID,::fabs(value));                      }
         double            GetValueChangedBid(void)                              const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_BID);                           }
         bool              IsIncreasedBid(void)                                  const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_BID);                          }
         bool              IsDecreasedBid(void)                                  const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_BID);                          }
      //--- The highest Bid price of the day
      //--- setting the controlled maximum Bid price (1) increase, (2) decrease value and (3) control level in points
      //--- getting the (4) maximum Bid or Last price change value,
      //--- getting the flag of the maximum Bid or Last price change exceeding the (5) increase, (6) decrease value
         void              SetControlBidHighInc(const double value)                    { this.SetControlledValueINC(SYMBOL_PROP_BIDHIGH,::fabs(value));                    }
         void              SetControlBidHighDec(const double value)                    { this.SetControlledValueDEC(SYMBOL_PROP_BIDHIGH,::fabs(value));                    }
         void              SetControlBidHighLevel(const double value)                  { this.SetControlledValueLEVEL(SYMBOL_PROP_BIDHIGH,::fabs(value));                  }
         double            GetValueChangedBidHigh(void)                          const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_BIDHIGH);                       }
         bool              IsIncreasedBidHigh(void)                              const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_BIDHIGH);                      }
         bool              IsDecreasedBidHigh(void)                              const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_BIDHIGH);                      }
      //--- The lowest Bid price of the day
      //--- setting the controlled minimum Bid price (1) increase, (2) decrease value and (3) control level in points
      //--- getting the (4) minimum Bid or Last price change value,
      //--- getting the flag of the minimum Bid or Last price change exceeding the (5) increase, (6) decrease value
         void              SetControlBidLowInc(const double value)                     { this.SetControlledValueINC(SYMBOL_PROP_BIDLOW,::fabs(value));                     }
         void              SetControlBidLowDec(const double value)                     { this.SetControlledValueDEC(SYMBOL_PROP_BIDLOW,::fabs(value));                     }
         void              SetControlBidLowLevel(const double value)                   { this.SetControlledValueLEVEL(SYMBOL_PROP_BIDLOW,::fabs(value));                   }
         double            GetValueChangedBidLow(void)                           const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_BIDLOW);                        }
         bool              IsIncreasedBidLow(void)                               const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_BIDLOW);                       }
         bool              IsDecreasedBidLow(void)                               const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_BIDLOW);                       }
      
      //--- Last
      //--- setting the controlled Last price (1) increase, (2) decrease value and (3) control level in points
      //--- getting (4) Bid or Last price change value,
      //--- getting the flag of the Bid or Last price change exceeding the (5) increase, (6) decrease value
         void              SetControlLastInc(const double value)                       { this.SetControlledValueINC(SYMBOL_PROP_LAST,::fabs(value));                       }
         void              SetControlLastDec(const double value)                       { this.SetControlledValueDEC(SYMBOL_PROP_LAST,::fabs(value));                       }
         void              SetControlLastLevel(const double value)                     { this.SetControlledValueLEVEL(SYMBOL_PROP_LAST,::fabs(value));                     }
         double            GetValueChangedLast(void)                             const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_LAST);                          }
         bool              IsIncreasedLast(void)                                 const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_LAST);                         }
         bool              IsDecreasedLast(void)                                 const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_LAST);                         }
      //--- The highest Last price of the day
      //--- setting the controlled maximum Last price (1) increase, (2) decrease value and (3) control level in points
      //--- getting the (4) maximum Bid or Last price change value,
      //--- getting the flag of the maximum Bid or Last price change exceeding the (5) increase, (6) decrease value
         void              SetControlLastHighInc(const double value)                   { this.SetControlledValueINC(SYMBOL_PROP_LASTHIGH,::fabs(value));                   }
         void              SetControlLastHighDec(const double value)                   { this.SetControlledValueDEC(SYMBOL_PROP_LASTHIGH,::fabs(value));                   }
         void              SetControlLastHighLevel(const double value)                 { this.SetControlledValueLEVEL(SYMBOL_PROP_LASTHIGH,::fabs(value));                 }
         double            GetValueChangedLastHigh(void)                         const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_LASTHIGH);                      }
         bool              IsIncreasedLastHigh(void)                             const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_LASTHIGH);                     }
         bool              IsDecreasedLastHigh(void)                             const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_LASTHIGH);                     }
      //--- The lowest Last price of the day
      //--- setting the controlled minimum Last price (1) increase, (2) decrease value and (3) control level in points
      //--- getting the (4) minimum Bid or Last price change value,
      //--- getting the flag of the minimum Bid or Last price change exceeding the (5) increase, (6) decrease value
         void              SetControlLastLowInc(const double value)                    { this.SetControlledValueINC(SYMBOL_PROP_LASTLOW,::fabs(value));                    }
         void              SetControlLastLowDec(const double value)                    { this.SetControlledValueDEC(SYMBOL_PROP_LASTLOW,::fabs(value));                    }
         void              SetControlLastLowLevel(const double value)                  { this.SetControlledValueLEVEL(SYMBOL_PROP_LASTLOW,::fabs(value));                  }
         double            GetValueChangedLastLow(void)                          const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_LASTLOW);                       }
         bool              IsIncreasedLastLow(void)                              const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_LASTLOW);                      }
         bool              IsDecreasedLastLow(void)                              const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_LASTLOW);                      }
      
      //--- Bid/Last
      //--- setting the controlled Bid or Last price (1) increase, (2) decrease value and (3) control level in points
      //--- getting (4) Bid or Last price change value,
      //--- getting the flag of the Bid or Last price change exceeding the (5) increase, (6) decrease value
         void              SetControlBidLastInc(const double value);
         void              SetControlBidLastDec(const double value);
         void              SetControlBidLastLevel(const double value);
         double            GetValueChangedBidLast(void)                          const;
         bool              IsIncreasedBidLast(void)                              const;
         bool              IsDecreasedBidLast(void)                              const;
      //--- Maximum Bid/Last of the day
      //--- setting the controlled maximum Bid or Last price (1) increase, (2) decrease value and (3) control level in points
      //--- getting the (4) maximum Bid or Last price change value,
      //--- getting the flag of the maximum Bid or Last price change exceeding the (5) increase, (6) decrease value
         void              SetControlBidLastHighInc(const double value);
         void              SetControlBidLastHighDec(const double value);
         void              SetControlBidLastHighLevel(const double value);
         double            GetValueChangedBidLastHigh(void)                      const;
         bool              IsIncreasedBidLastHigh(void)                          const;
         bool              IsDecreasedBidLastHigh(void)                          const;
      //--- Minimum Bid/Last of the day
      //--- setting the controlled minimum Bid or Last price (1) increase, (2) decrease value and (3) control level in points
      //--- getting the (4) minimum Bid or Last price change value,
      //--- getting the flag of the minimum Bid or Last price change exceeding the (5) increase, (6) decrease value
         void              SetControlBidLastLowInc(const double value);
         void              SetControlBidLastLowDec(const double value);
         void              SetControlBidLastLowLevev(const double value);
         double            GetValueChangedBidLastLow(void)                       const;
         bool              IsIncreasedBidLastLow(void)                           const;
         bool              IsDecreasedBidLastLow(void)                           const;
      
      //--- Ask
      //--- setting the controlled Ask price (1) increase, (2) decrease value and (3) control level in points
      //--- getting (4) Ask price change value,
      //--- getting the flag of the Ask price change exceeding the (5) increase, (6) decrease value
         void              SetControlAskInc(const double value)                        { this.SetControlledValueINC(SYMBOL_PROP_ASK,::fabs(value));                        }
         void              SetControlAskDec(const double value)                        { this.SetControlledValueDEC(SYMBOL_PROP_ASK,::fabs(value));                        }
         void              SetControlAskLevel(const double value)                      { this.SetControlledValueLEVEL(SYMBOL_PROP_ASK,::fabs(value));                      }
         double            GetValueChangedAsk(void)                              const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_ASK);                           }
         bool              IsIncreasedAsk(void)                                  const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_ASK);                          }
         bool              IsDecreasedAsk(void)                                  const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_ASK);                          }
      //--- Maximum Ask price for the day
      //--- setting the maximum day Ask controlled (1) increase, (2) decrease and (3) control level
      //--- getting (4) the maximum Ask change value within a day,
      //--- getting the flag of the maximum day Ask change exceeding the (5) increase, (6) decrease value
         void              SetControlAskHighInc(const double value)                    { this.SetControlledValueINC(SYMBOL_PROP_ASKHIGH,::fabs(value));                    }
         void              SetControlAskHighDec(const double value)                    { this.SetControlledValueDEC(SYMBOL_PROP_ASKHIGH,::fabs(value));                    }
         void              SetControlAskHighLevel(const double value)                  { this.SetControlledValueLEVEL(SYMBOL_PROP_ASKHIGH,::fabs(value));                  }
         double            GetValueChangedAskHigh(void)                          const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_ASKHIGH);                       }
         bool              IsIncreasedAskHigh(void)                              const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_ASKHIGH);                      }
         bool              IsDecreasedAskHigh(void)                              const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_ASKHIGH);                      }
      //--- Minimum Ask price for the day
      //--- setting the minimum day Ask controlled (1) increase, (2) decrease and (3) control level
      //--- getting (4) the minimum Ask change value within a day,
      //--- getting the flag of the minimum day Ask change exceeding the (5) increase, (6) decrease value
         void              SetControlAskLowInc(const double value)                     { this.SetControlledValueINC(SYMBOL_PROP_ASKLOW,::fabs(value));                     }
         void              SetControlAskLowDec(const double value)                     { this.SetControlledValueDEC(SYMBOL_PROP_ASKLOW,::fabs(value));                     }
         void              SetControlAskLowLevel(const double value)                   { this.SetControlledValueLEVEL(SYMBOL_PROP_ASKLOW,::fabs(value));                   }
         double            GetValueChangedAskLow(void)                           const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_ASKLOW);                        }
         bool              IsIncreasedAskLow(void)                               const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_ASKLOW);                       }
         bool              IsDecreasedAskLow(void)                               const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_ASKLOW);                       }
      //--- Real Volume for the day
      //--- setting the real day volume controlled (1) increase, (2) decrease and (3) control level
      //--- getting (4) the change value of the real day volume,
      //--- getting the flag of the real day volume change exceeding the (5) increase, (6) decrease value
         void              SetControlVolumeRealInc(const double value)                 { this.SetControlledValueINC(SYMBOL_PROP_VOLUME_REAL,::fabs(value));                }
         void              SetControlVolumeRealDec(const double value)                 { this.SetControlledValueDEC(SYMBOL_PROP_VOLUME_REAL,::fabs(value));                }
         void              SetControlVolumeRealLevel(const double value)               { this.SetControlledValueLEVEL(SYMBOL_PROP_VOLUME_REAL,::fabs(value));              }
         double            GetValueChangedVolumeReal(void)                       const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_VOLUME_REAL);                   }
         bool              IsIncreasedVolumeReal(void)                           const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_VOLUME_REAL);                  }
         bool              IsDecreasedVolumeReal(void)                           const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_VOLUME_REAL);                  }
      //--- Maximum real volume for the day
      //--- setting the maximum real day volume controlled (1) increase, (2) decrease and (3) control level
      //--- getting (4) the change value of the maximum real day volume,
      //--- getting the flag of the maximum real day volume change exceeding the (5) increase, (6) decrease value
         void              SetControlVolumeHighRealInc(const double value)             { this.SetControlledValueINC(SYMBOL_PROP_VOLUMEHIGH_REAL,::fabs(value));            }
         void              SetControlVolumeHighRealDec(const double value)             { this.SetControlledValueDEC(SYMBOL_PROP_VOLUMEHIGH_REAL,::fabs(value));            }
         void              SetControlVolumeHighRealLevel(const double value)           { this.SetControlledValueLEVEL(SYMBOL_PROP_VOLUMEHIGH_REAL,::fabs(value));          }
         double            GetValueChangedVolumeHighReal(void)                   const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_VOLUMEHIGH_REAL);               }
         bool              IsIncreasedVolumeHighReal(void)                       const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_VOLUMEHIGH_REAL);              }
         bool              IsDecreasedVolumeHighReal(void)                       const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_VOLUMEHIGH_REAL);              }
      //--- Minimum real volume for the day
      //--- setting the minimum real day volume controlled (1) increase, (2) decrease and (3) control level
      //--- getting (4) the change value of the minimum real day volume,
      //--- getting the flag of the minimum real day volume change exceeding the (5) increase, (6) decrease value
         void              SetControlVolumeLowRealInc(const double value)              { this.SetControlledValueINC(SYMBOL_PROP_VOLUMELOW_REAL,::fabs(value));             }
         void              SetControlVolumeLowRealDec(const double value)              { this.SetControlledValueDEC(SYMBOL_PROP_VOLUMELOW_REAL,::fabs(value));             }
         void              SetControlVolumeLowRealLevel(const double value)            { this.SetControlledValueLEVEL(SYMBOL_PROP_VOLUMELOW_REAL,::fabs(value));           }
         double            GetValueChangedVolumeLowReal(void)                    const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_VOLUMELOW_REAL);                }
         bool              IsIncreasedVolumeLowReal(void)                        const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_VOLUMELOW_REAL);               }
         bool              IsDecreasedVolumeLowReal(void)                        const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_VOLUMELOW_REAL);               }
      //--- Strike price
      //--- setting the controlled strike price (1) increase, (2) decrease value and (3) control level in points
      //--- getting (4) the change value of the strike price,
      //--- getting the flag of the strike price change exceeding the (5) increase, (6) decrease value
         void              SetControlOptionStrikeInc(const double value)               { this.SetControlledValueINC(SYMBOL_PROP_OPTION_STRIKE,::fabs(value));              }
         void              SetControlOptionStrikeDec(const double value)               { this.SetControlledValueDEC(SYMBOL_PROP_OPTION_STRIKE,::fabs(value));              }
         void              SetControlOptionStrikeLevel(const double value)             { this.SetControlledValueLEVEL(SYMBOL_PROP_OPTION_STRIKE,::fabs(value));            }
         double            GetValueChangedOptionStrike(void)                     const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_OPTION_STRIKE);                 } 
         bool              IsIncreasedOptionStrike(void)                         const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_OPTION_STRIKE);                }
         bool              IsDecreasedOptionStrike(void)                         const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_OPTION_STRIKE);                }
      //--- Maximum allowed total volume of unidirectional positions and orders
      //--- (1) Setting the control level
      //--- (2) getting the change value of the maximum allowed total volume of unidirectional positions and orders,
      //--- getting the flag of (3) increasing, (4) decreasing the maximum allowed total volume of unidirectional positions and orders
         void              SetControlVolumeLimitLevel(const double value)              { this.SetControlledValueLEVEL(SYMBOL_PROP_VOLUME_LIMIT,::fabs(value));             }
         double            GetValueChangedVolumeLimit(void)                      const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_VOLUME_LIMIT);                  }
         bool              IsIncreasedVolumeLimit(void)                          const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_VOLUME_LIMIT);                 }
         bool              IsDecreasedVolumeLimit(void)                          const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_VOLUME_LIMIT);                 }
      //---  Swap long
      //--- (1) Setting the control level
      //--- (2) getting the swap long change value,
      //--- getting the flag of (3) increasing, (4) decreasing the swap long
         void              SetControlSwapLongLevel(const double value)                 { this.SetControlledValueLEVEL(SYMBOL_PROP_SWAP_LONG,::fabs(value));                }
         double            GetValueChangedSwapLong(void)                         const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SWAP_LONG);                     }
         bool              IsIncreasedSwapLong(void)                             const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SWAP_LONG);                    }
         bool              IsDecreasedSwapLong(void)                             const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SWAP_LONG);                    }
      //---  Swap short
      //--- (1) Setting the control level
      //--- (2) getting the swap short change value,
      //--- getting the flag of (3) increasing, (4) decreasing the swap short
         void              SetControlSwapShortLevel(const double value)                { this.SetControlledValueLEVEL(SYMBOL_PROP_SWAP_SHORT,::fabs(value));               }
         double            GetValueChangedSwapShort(void)                        const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SWAP_SHORT);                    }
         bool              IsIncreasedSwapShort(void)                            const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SWAP_SHORT);                   }
         bool              IsDecreasedSwapShort(void)                            const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SWAP_SHORT);                   }
      //--- The total volume of deals in the current session
      //--- setting the controlled value of (1) increase, (2) decrease and (3) control level of the total volume of deals during the current session
      //--- getting (4) the total deal volume change value in the current session,
      //--- getting the flag of the total deal volume change during the current session exceeding the (5) increase, (6) decrease value
         void              SetControlSessionVolumeInc(const double value)              { this.SetControlledValueINC(SYMBOL_PROP_SESSION_VOLUME,::fabs(value));             }
         void              SetControlSessionVolumeDec(const double value)              { this.SetControlledValueDEC(SYMBOL_PROP_SESSION_VOLUME,::fabs(value));             }
         void              SetControlSessionVolumeLevel(const double value)            { this.SetControlledValueLEVEL(SYMBOL_PROP_SESSION_VOLUME,::fabs(value));           }
         double            GetValueChangedSessionVolume(void)                    const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SESSION_VOLUME);                }
         bool              IsIncreasedSessionVolume(void)                        const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SESSION_VOLUME);               }
         bool              IsDecreasedSessionVolume(void)                        const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SESSION_VOLUME);               }
      //--- The total turnover in the current session
      //--- setting the controlled value of (1) increase, (2) decrease and (3) control level of the total turnover during the current session
      //--- getting (4) the total turnover change value in the current session,
      //--- getting the flag of the total turnover change during the current session exceeding the (5) increase, (6) decrease value
         void              SetControlSessionTurnoverInc(const double value)            { this.SetControlledValueINC(SYMBOL_PROP_SESSION_TURNOVER,::fabs(value));           }
         void              SetControlSessionTurnoverDec(const double value)            { this.SetControlledValueDEC(SYMBOL_PROP_SESSION_TURNOVER,::fabs(value));           }
         void              SetControlSessionTurnoverLevel(const double value)          { this.SetControlledValueLEVEL(SYMBOL_PROP_SESSION_TURNOVER,::fabs(value));         }
         double            GetValueChangedSessionTurnover(void)                  const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SESSION_TURNOVER);              }
         bool              IsIncreasedSessionTurnover(void)                      const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SESSION_TURNOVER);             }
         bool              IsDecreasedSessionTurnover(void)                      const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SESSION_TURNOVER);             }
      //--- The total volume of open positions
      //--- setting the controlled value of (1) increase, (2) decrease and (3) control level of the total volume of open positions during the current session
      //--- getting (4) the change value of the open positions total volume in the current session,
      //--- getting the flag of the open positions total volume change during the current session exceeding the (5) increase, (6) decrease value
         void              SetControlSessionInterestInc(const double value)            { this.SetControlledValueINC(SYMBOL_PROP_SESSION_INTEREST,::fabs(value));           }
         void              SetControlSessionInterestDec(const double value)            { this.SetControlledValueDEC(SYMBOL_PROP_SESSION_INTEREST,::fabs(value));           }
         void              SetControlSessionInterestLevel(const double value)          { this.SetControlledValueLEVEL(SYMBOL_PROP_SESSION_INTEREST,::fabs(value));         }
         double            GetValueChangedSessionInterest(void)                  const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SESSION_INTEREST);              }
         bool              IsIncreasedSessionInterest(void)                      const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SESSION_INTEREST);             }
         bool              IsDecreasedSessionInterest(void)                      const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SESSION_INTEREST);             }
      //--- The total volume of Buy orders at the moment
      //--- setting the controlled value of (1) increase, (2) decrease and (3) control level of the current total buy order volume
      //--- getting (4) the change value of the current total buy order volume,
      //--- getting the flag of the current total buy orders' volume change exceeding the (5) increase, (6) decrease value
         void              SetControlSessionBuyOrdVolumeInc(const double value)        { this.SetControlledValueINC(SYMBOL_PROP_SESSION_BUY_ORDERS_VOLUME,::fabs(value));  }
         void              SetControlSessionBuyOrdVolumeDec(const double value)        { this.SetControlledValueDEC(SYMBOL_PROP_SESSION_BUY_ORDERS_VOLUME,::fabs(value));  }
         void              SetControlSessionBuyOrdVolumeLevel(const double value)      { this.SetControlledValueLEVEL(SYMBOL_PROP_SESSION_BUY_ORDERS_VOLUME,::fabs(value));}
         double            GetValueChangedSessionBuyOrdVolume(void)              const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SESSION_BUY_ORDERS_VOLUME);     }
         bool              IsIncreasedSessionBuyOrdVolume(void)                  const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SESSION_BUY_ORDERS_VOLUME);    }
         bool              IsDecreasedSessionBuyOrdVolume(void)                  const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SESSION_BUY_ORDERS_VOLUME);    }
      //--- The total volume of Sell orders at the moment
      //--- setting the controlled value of (1) increase, (2) decrease and (3) control level of the current total sell order volume
      //--- getting (4) the change value of the current total sell order volume,
      //--- getting the flag of the current total sell orders' volume change exceeding the (5) increase, (6) decrease value
         void              SetControlSessionSellOrdVolumeInc(const double value)       { this.SetControlledValueINC(SYMBOL_PROP_SESSION_SELL_ORDERS_VOLUME,::fabs(value)); }
         void              SetControlSessionSellOrdVolumeDec(const double value)       { this.SetControlledValueDEC(SYMBOL_PROP_SESSION_SELL_ORDERS_VOLUME,::fabs(value)); }
         void              SetControlSessionSellOrdVolumeLevel(const double value)     { this.SetControlledValueLEVEL(SYMBOL_PROP_SESSION_SELL_ORDERS_VOLUME,::fabs(value));}
         double            GetValueChangedSessionSellOrdVolume(void)             const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SESSION_SELL_ORDERS_VOLUME);    }
         bool              IsIncreasedSessionSellOrdVolume(void)                 const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SESSION_SELL_ORDERS_VOLUME);   }
         bool              IsDecreasedSessionSellOrdVolume(void)                 const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SESSION_SELL_ORDERS_VOLUME);   }
      //--- Session open price
      //--- setting the controlled session open price (1) increase, (2) decrease and (3) control value
      //--- getting (4) the change value of the session open price,
      //--- getting the flag of the session open price change exceeding the (5) increase, (6) decrease value
         void              SetControlSessionPriceOpenInc(const double value)           { this.SetControlledValueINC(SYMBOL_PROP_SESSION_OPEN,::fabs(value));               }
         void              SetControlSessionPriceOpenDec(const double value)           { this.SetControlledValueDEC(SYMBOL_PROP_SESSION_OPEN,::fabs(value));               }
         void              SetControlSessionPriceOpenLevel(const double value)         { this.SetControlledValueLEVEL(SYMBOL_PROP_SESSION_OPEN,::fabs(value));             }
         double            GetValueChangedSessionPriceOpen(void)                 const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SESSION_OPEN);                  }
         bool              IsIncreasedSessionPriceOpen(void)                     const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SESSION_OPEN);                 }
         bool              IsDecreasedSessionPriceOpen(void)                     const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SESSION_OPEN);                 }
      //--- Session close price
      //--- setting the controlled session close price (1) increase, (2) decrease and (3) control value
      //--- getting (4) the change value of the session close price,
      //--- getting the flag of the session close price change exceeding the (5) increase, (6) decrease value
         void              SetControlSessionPriceCloseInc(const double value)          { this.SetControlledValueINC(SYMBOL_PROP_SESSION_CLOSE,::fabs(value));              }
         void              SetControlSessionPriceCloseDec(const double value)          { this.SetControlledValueDEC(SYMBOL_PROP_SESSION_CLOSE,::fabs(value));              }
         void              SetControlSessionPriceCloseLevel(const double value)        { this.SetControlledValueLEVEL(SYMBOL_PROP_SESSION_CLOSE,::fabs(value));            }
         double            GetValueChangedSessionPriceClose(void)                const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SESSION_CLOSE);                 }
         bool              IsIncreasedSessionPriceClose(void)                    const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SESSION_CLOSE);                }
         bool              IsDecreasedSessionPriceClose(void)                    const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SESSION_CLOSE);                }
      //--- The average weighted session price
      //--- setting the controlled session average weighted price (1) increase, (2) decrease and (3) control value
      //--- getting (4) the change value of the average weighted session price,
      //--- getting the flag of the average weighted session price change exceeding the (5) increase, (6) decrease value
         void              SetControlSessionPriceAWInc(const double value)             { this.SetControlledValueINC(SYMBOL_PROP_SESSION_AW,::fabs(value));                 }
         void              SetControlSessionPriceAWDec(const double value)             { this.SetControlledValueDEC(SYMBOL_PROP_SESSION_AW,::fabs(value));                 }
         void              SetControlSessionPriceAWLevel(const double value)           { this.SetControlledValueLEVEL(SYMBOL_PROP_SESSION_AW,::fabs(value));               }
         double            GetValueChangedSessionPriceAW(void)                   const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SESSION_AW);                    }
         bool              IsIncreasedSessionPriceAW(void)                       const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SESSION_AW);                   }
         bool              IsDecreasedSessionPriceAW(void)                       const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SESSION_AW);                   }
      //--- Change of the current price relative to the end of the previous trading day
      //--- setting the controlled Bid or Last price (1) increase, (2) decrease value and (3) control level of the current price dynamics relative to the end of the previous trading day
      //--- getting (4) the value of the change of the current price relative to the end of the previous trading day,
      //--- getting the flag indicating the Change of the current price relative to the end of the previous trading day property change by the value exceeding the (5) growth, (6) decrease
         void              SetControlPriceChangeInc(const double value)                { this.SetControlledValueINC(SYMBOL_PROP_PRICE_CHANGE,::fabs(value));               }
         void              SetControlPriceChangeDec(const double value)                { this.SetControlledValueDEC(SYMBOL_PROP_PRICE_CHANGE,::fabs(value));               }
         void              SetControlPriceChangeLevel(const double value)              { this.SetControlledValueLEVEL(SYMBOL_PROP_PRICE_CHANGE,::fabs(value));             }
         double            GetValueChangedPriceChange(void)                      const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_PRICE_CHANGE);                  }
         bool              IsIncreasedPriceChange(void)                          const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_PRICE_CHANGE);                 }
         bool              IsDecreasedPriceChange(void)                          const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_PRICE_CHANGE);                 }
      //--- Price volatility in %
      //--- setting the controlled session average weighted price (1) increase, (2) decrease and (3) price volatility control in %
      //--- getting (4) the value of the price volatility change in %,
      //--- getting the flag of the price volatility change in % exceeding the (5) growth and (6) decrease value
         void              SetControlPriceVolatilityInc(const double value)            { this.SetControlledValueINC(SYMBOL_PROP_PRICE_VOLATILITY,::fabs(value));           }
         void              SetControlPriceVolatilityDec(const double value)            { this.SetControlledValueDEC(SYMBOL_PROP_PRICE_VOLATILITY,::fabs(value));           }
         void              SetControlPriceVolatilityLevel(const double value)          { this.SetControlledValueLEVEL(SYMBOL_PROP_PRICE_VOLATILITY,::fabs(value));         }
         double            GetValueChangedPriceVolatility(void)                  const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_PRICE_VOLATILITY);              }
         bool              IsIncreasedPriceVolatility(void)                      const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_PRICE_VOLATILITY);             }
         bool              IsDecreasedPriceVolatility(void)                      const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_PRICE_VOLATILITY);             }
      //--- Theoretical option price
      //--- setting the controlled strike price (1) increase, (2) decrease value and (3) theoretical option price control level
      //--- getting (4) the change value of the theoretical option price,
      //--- getting the flag of the theoretical option price change exceeding the (5) increase, (6) decrease value
         void              SetControlPriceTheoreticalInc(const double value)           { this.SetControlledValueINC(SYMBOL_PROP_PRICE_THEORETICAL,::fabs(value));          }
         void              SetControlPriceTheoreticalDec(const double value)           { this.SetControlledValueDEC(SYMBOL_PROP_PRICE_THEORETICAL,::fabs(value));          }
         void              SetControlPriceTheoreticalLevel(const double value)         { this.SetControlledValueLEVEL(SYMBOL_PROP_PRICE_THEORETICAL,::fabs(value));        }
         double            GetValueChangedPriceTheoretical(void)                 const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_PRICE_THEORETICAL);             }
         bool              IsIncreasedPriceTheoretical(void)                     const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_PRICE_THEORETICAL);            }
         bool              IsDecreasedPriceTheoretical(void)                     const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_PRICE_THEORETICAL);            }
      //--- Option/warrant delta
      //--- setting the controlled maximum Bid price (1) increase, (2) decrease value and (3) option/warrant delta control level in points
      //--- getting (4) option/warrant delta change value in points,
      //--- getting the flag of the option/warrant delta change exceeding the (5) increase, (6) decrease value
         void              SetControlPriceDeltaInc(const double value)              { this.SetControlledValueINC(SYMBOL_PROP_PRICE_DELTA,::fabs(value));                   }
         void              SetControlPriceDeltaDec(const double value)              { this.SetControlledValueDEC(SYMBOL_PROP_PRICE_DELTA,::fabs(value));                   }
         void              SetControlPriceDeltaLevel(const double value)            { this.SetControlledValueLEVEL(SYMBOL_PROP_PRICE_DELTA,::fabs(value));                 }
         double            GetValueChangedPriceDelta(void)                    const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_PRICE_DELTA);                      }
         bool              IsIncreasedPriceDelta(void)                        const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_PRICE_DELTA);                     }
         bool              IsDecreasedPriceDelta(void)                        const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_PRICE_DELTA);                     }
      //--- Option/warrant theta
      //--- setting the controlled maximum Bid price (1) increase, (2) decrease value and (3) option/warrant theta control level in points
      //--- getting (4) option/warrant theta change value in points,
      //--- getting the flag of the option/warrant theta change exceeding the (5) increase, (6) decrease value
         void              SetControlPriceThetaInc(const double value)              { this.SetControlledValueINC(SYMBOL_PROP_PRICE_THETA,::fabs(value));                   }
         void              SetControlPriceThetaDec(const double value)              { this.SetControlledValueDEC(SYMBOL_PROP_PRICE_THETA,::fabs(value));                   }
         void              SetControlPriceThetaLevel(const double value)            { this.SetControlledValueLEVEL(SYMBOL_PROP_PRICE_THETA,::fabs(value));                 }
         double            GetValueChangedPriceTheta(void)                    const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_PRICE_THETA);                      }
         bool              IsIncreasedPriceTheta(void)                        const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_PRICE_THETA);                     }
         bool              IsDecreasedPriceTheta(void)                        const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_PRICE_THETA);                     }
      //--- Option/warrant gamma
      //--- setting the controlled maximum Bid price (1) increase, (2) decrease value and (3) option/warrant gamma control level in points
      //--- getting (4) option/warrant gamma change value in points,
      //--- getting the flag of the option/warrant gamma change exceeding the (5) increase, (6) decrease value
         void              SetControlPriceGammaInc(const double value)              { this.SetControlledValueINC(SYMBOL_PROP_PRICE_GAMMA,::fabs(value));                   }
         void              SetControlPriceGammaDec(const double value)              { this.SetControlledValueDEC(SYMBOL_PROP_PRICE_GAMMA,::fabs(value));                   }
         void              SetControlPriceGammaLevel(const double value)            { this.SetControlledValueLEVEL(SYMBOL_PROP_PRICE_GAMMA,::fabs(value));                 }
         double            GetValueChangedPriceGamma(void)                    const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_PRICE_GAMMA);                      }
         bool              IsIncreasedPriceGamma(void)                        const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_PRICE_GAMMA);                     }
         bool              IsDecreasedPriceGamma(void)                        const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_PRICE_GAMMA);                     }
      //--- Option/warrant vega
      //--- setting the controlled maximum Bid price (1) increase, (2) decrease value and (3) option/warrant vega control level in points
      //--- getting (4) the change value of the average weighted session price,
      //--- getting the flag of the average weighted session price change exceeding the (5) increase, (6) decrease value
         void              SetControlPriceVegaInc(const double value)               { this.SetControlledValueINC(SYMBOL_PROP_PRICE_VEGA,::fabs(value));                    }
         void              SetControlPriceVegaDec(const double value)               { this.SetControlledValueDEC(SYMBOL_PROP_PRICE_VEGA,::fabs(value));                    }
         void              SetControlPriceVegaLevel(const double value)             { this.SetControlledValueLEVEL(SYMBOL_PROP_PRICE_VEGA,::fabs(value));                  }
         double            GetValueChangedPriceVega(void)                     const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_PRICE_VEGA);                       }
         bool              IsIncreasedPriceVega(void)                         const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_PRICE_VEGA);                      }
         bool              IsDecreasedPriceVega(void)                         const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_PRICE_VEGA);                      }
      //--- Option/warrant rho
      //--- setting the controlled maximum Bid price (1) increase, (2) decrease value and (3) option/warrant rho control level in points
      //--- getting (4) option/warrant rho change value in points,
      //--- getting the flag of the option/warrant rho change exceeding the (5) increase, (6) decrease value
         void              SetControlPriceRhoInc(const double value)                { this.SetControlledValueINC(SYMBOL_PROP_PRICE_RHO,::fabs(value));                     }
         void              SetControlPriceRhoDec(const double value)                { this.SetControlledValueDEC(SYMBOL_PROP_PRICE_RHO,::fabs(value));                     }
         void              SetControlPriceRhoLevel(const double value)              { this.SetControlledValueLEVEL(SYMBOL_PROP_PRICE_RHO,::fabs(value));                   }
         double            GetValueChangedPriceRho(void)                      const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_PRICE_RHO);                        }
         bool              IsIncreasedPriceRho(void)                          const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_PRICE_RHO);                       }
         bool              IsDecreasedPriceRho(void)                          const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_PRICE_RHO);                       }
      //--- Option/warrant omega
      //--- setting the controlled maximum Bid price (1) increase, (2) decrease value and (3) option/warrant omega control level in points
      //--- getting (4) option/warrant omega change value in points,
      //--- getting the flag of the option/warrant omega change exceeding the (5) increase, (6) decrease value
         void              SetControlPriceOmegaInc(const double value)              { this.SetControlledValueINC(SYMBOL_PROP_PRICE_OMEGA,::fabs(value));                   }
         void              SetControlPriceOmegaDec(const double value)              { this.SetControlledValueDEC(SYMBOL_PROP_PRICE_OMEGA,::fabs(value));                   }
         void              SetControlPriceOmegaLevel(const double value)            { this.SetControlledValueLEVEL(SYMBOL_PROP_PRICE_OMEGA,::fabs(value));                 }
         double            GetValueChangedPriceOmega(void)                    const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_PRICE_OMEGA);                      }
         bool              IsIncreasedPriceOmega(void)                        const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_PRICE_OMEGA);                     }
         bool              IsDecreasedPriceOmega(void)                        const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_PRICE_OMEGA);                     }
      //--- Option/warrant sensitivity
      //--- setting the controlled maximum Bid price (1) increase, (2) decrease value and (3) option/warrant sensitivity control level in points
      //--- getting (4) option/warrant sensitivity change value in points,
      //--- getting the flag of the option/warrant sensitivity change exceeding the (5) increase, (6) decrease value
         void              SetControlPriceSensitivityInc(const double value)        { this.SetControlledValueINC(SYMBOL_PROP_PRICE_SENSITIVITY,::fabs(value));             }
         void              SetControlPriceSensitivityDec(const double value)        { this.SetControlledValueDEC(SYMBOL_PROP_PRICE_SENSITIVITY,::fabs(value));             }
         void              SetControlPriceSensitivityLevel(const double value)      { this.SetControlledValueLEVEL(SYMBOL_PROP_PRICE_SENSITIVITY,::fabs(value));           }
         double            GetValueChangedPriceSensitivity(void)              const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_PRICE_SENSITIVITY);                }
         bool              IsIncreasedPriceSensitivity(void)                  const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_PRICE_SENSITIVITY);               }
         bool              IsDecreasedPriceSensitivity(void)                  const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_PRICE_SENSITIVITY);               }
    //--- Swap accrual ratio
      //--- setting the controlled Sunday swap accrual ratio (1) increase, (2) decrease and (3) control levels
      //--- get (4) the swap accrual ratio change (Sunday),
      //--- get the swap accrual ratio change for Sunday exceeding the (5) increase and (6) decrease values
         void              SetControlSwapSundayInc(const double value)              { this.SetControlledValueINC(SYMBOL_PROP_SWAP_SUNDAY,::fabs(value));                   }
         void              SetControlSwapSundayDec(const double value)              { this.SetControlledValueDEC(SYMBOL_PROP_SWAP_SUNDAY,::fabs(value));                   }
         void              SetControlSwapSundayLevel(const double value)            { this.SetControlledValueLEVEL(SYMBOL_PROP_SWAP_SUNDAY,::fabs(value));                 }
         double            GetValueChangedSwapSunday(void)                    const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SWAP_SUNDAY);                      }
         bool              IsIncreasedSwapSunday(void)                        const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SWAP_SUNDAY);                     }
         bool              IsDecreasedSwapSunday(void)                        const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SWAP_SUNDAY);                     }
      //--- setting the controlled Monday swap accrual ratio (1) increase, (2) decrease and (3) control levels
      //--- get (4) the swap accrual ratio change (Monday),
      //--- get the swap accrual ratio change for Monday exceeding the (5) increase and (6) decrease values
         void              SetControlSwapMondayInc(const double value)              { this.SetControlledValueINC(SYMBOL_PROP_SWAP_MONDAY,::fabs(value));                   }
         void              SetControlSwapMondayDec(const double value)              { this.SetControlledValueDEC(SYMBOL_PROP_SWAP_MONDAY,::fabs(value));                   }
         void              SetControlSwapMondayLevel(const double value)            { this.SetControlledValueLEVEL(SYMBOL_PROP_SWAP_MONDAY,::fabs(value));                 }
         double            GetValueChangedSwapMonday(void)                    const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SWAP_MONDAY);                      }
         bool              IsIncreasedSwapMonday(void)                        const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SWAP_MONDAY);                     }
         bool              IsDecreasedSwapMonday(void)                        const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SWAP_MONDAY);                     }
      //--- setting the controlled Tuesday swap accrual ratio (1) increase, (2) decrease and (3) control levels
      //--- get (4) the swap accrual ratio change (Tuesday),
      //--- get the swap accrual ratio change for Tuesday exceeding the (5) increase and (6) decrease values
         void              SetControlSwapTuesdayInc(const double value)             { this.SetControlledValueINC(SYMBOL_PROP_SWAP_TUESDAY,::fabs(value));                  }
         void              SetControlSwapTuesdayDec(const double value)             { this.SetControlledValueDEC(SYMBOL_PROP_SWAP_TUESDAY,::fabs(value));                  }
         void              SetControlSwapTuesdayLevel(const double value)           { this.SetControlledValueLEVEL(SYMBOL_PROP_SWAP_TUESDAY,::fabs(value));                }
         double            GetValueChangedSwapTuesday(void)                   const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SWAP_TUESDAY);                     }
         bool              IsIncreasedSwapTuesday(void)                       const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SWAP_TUESDAY);                    }
         bool              IsDecreasedSwapTuesday(void)                       const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SWAP_TUESDAY);                    }
      //--- setting the controlled Wednesday swap accrual ratio (1) increase, (2) decrease and (3) control levels
      //--- get (4) the swap accrual ratio change (Wednesday),
      //--- get the swap accrual ratio change for Wednesday exceeding the (5) increase and (6) decrease values
         void              SetControlSwapWednesdayInc(const double value)           { this.SetControlledValueINC(SYMBOL_PROP_SWAP_WEDNESDAY,::fabs(value));                }
         void              SetControlSwapWednesdayDec(const double value)           { this.SetControlledValueDEC(SYMBOL_PROP_SWAP_WEDNESDAY,::fabs(value));                }
         void              SetControlSwapWednesdayLevel(const double value)         { this.SetControlledValueLEVEL(SYMBOL_PROP_SWAP_WEDNESDAY,::fabs(value));              }
         double            GetValueChangedSwapWednesday(void)                 const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SWAP_WEDNESDAY);                   }
         bool              IsIncreasedSwapWednesday(void)                     const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SWAP_WEDNESDAY);                  }
         bool              IsDecreasedSwapWednesday(void)                     const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SWAP_WEDNESDAY);                  }
      //--- setting the controlled Thursday swap accrual ratio (1) increase, (2) decrease and (3) control levels
      //--- get (4) the swap accrual ratio change (Thursday),
      //--- get the swap accrual ratio change for Thursday exceeding the (5) increase and (6) decrease values
         void              SetControlSwapThursdayInc(const double value)            { this.SetControlledValueINC(SYMBOL_PROP_SWAP_THURSDAY,::fabs(value));                 }
         void              SetControlSwapThursdayDec(const double value)            { this.SetControlledValueDEC(SYMBOL_PROP_SWAP_THURSDAY,::fabs(value));                 }
         void              SetControlSwapThursdayLevel(const double value)          { this.SetControlledValueLEVEL(SYMBOL_PROP_SWAP_THURSDAY,::fabs(value));               }
         double            GetValueChangedSwapThursday(void)                  const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SWAP_THURSDAY);                    }
         bool              IsIncreasedSwapThursday(void)                      const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SWAP_THURSDAY);                   }
         bool              IsDecreasedSwapThursday(void)                      const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SWAP_THURSDAY);                   }
      //--- setting the controlled Friday swap accrual ratio (1) increase, (2) decrease and (3) control levels
      //--- get (4) the swap accrual ratio change (Friday),
      //--- get the swap accrual ratio change for Friday exceeding the (5) increase and (6) decrease values
         void              SetControlSwapFridayInc(const double value)              { this.SetControlledValueINC(SYMBOL_PROP_SWAP_FRIDAY,::fabs(value));                   }
         void              SetControlSwapFridayDec(const double value)              { this.SetControlledValueDEC(SYMBOL_PROP_SWAP_FRIDAY,::fabs(value));                   }
         void              SetControlSwapFridayLevel(const double value)            { this.SetControlledValueLEVEL(SYMBOL_PROP_SWAP_FRIDAY,::fabs(value));                 }
         double            GetValueChangedSwapFriday(void)                    const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SWAP_FRIDAY);                      }
         bool              IsIncreasedSwapFriday(void)                        const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SWAP_FRIDAY);                     }
         bool              IsDecreasedSwapFriday(void)                        const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SWAP_FRIDAY);                     }
      //--- setting the controlled Saturday swap accrual ratio (1) increase, (2) decrease and (3) control levels
      //--- get (4) the swap accrual ratio change (Saturday),
      //--- get the swap accrual ratio change for Saturday exceeding the (5) increase and (6) decrease values
         void              SetControlSwapSaturdayInc(const double value)            { this.SetControlledValueINC(SYMBOL_PROP_SWAP_SATURDAY,::fabs(value));                 }
         void              SetControlSwapSaturdayDec(const double value)            { this.SetControlledValueDEC(SYMBOL_PROP_SWAP_SATURDAY,::fabs(value));                 }
         void              SetControlSwapSaturdayLevel(const double value)          { this.SetControlledValueLEVEL(SYMBOL_PROP_SWAP_SATURDAY,::fabs(value));               }
         double            GetValueChangedSwapSaturday(void)                  const { return this.GetPropDoubleChangedValue(SYMBOL_PROP_SWAP_SATURDAY);                    }
         bool              IsIncreasedSwapSaturday(void)                      const { return (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_SWAP_SATURDAY);                   }
         bool              IsDecreasedSwapSaturday(void)                      const { return (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_SWAP_SATURDAY);                   }

    //--- Return a trading object
      CTradeObj        *GetTradeObj(void)                                          { return &this.m_trade_obj; }

  };
 #endif // CSYMBOL_MQH_DECLARATION
 #ifndef CSYMBOL_MQH_IMPLEMENTATION
 #define CSYMBOL_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Class methods                                                    |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| Closed parametric constructor                                    |
 //+------------------------------------------------------------------+
 CSymbol::CSymbol(ENUM_SYMBOL_STATUS symbol_status,const string name,const int index)
  {
   this.m_type=OBJECT_DE_TYPE_SYMBOL; 
   this.m_name=name;
   this.m_book_subscribed=false;
   if(!this.Exist())
     {
      ::Print(DFUN_ERR_LINE,"\"",this.m_name,"\"",": ",CMessage::Text(MSG_LIB_SYS_NOT_SYMBOL_ON_SERVER));
      this.m_global_error=ERR_MARKET_UNKNOWN_SYMBOL;
     }
   bool select=::SymbolInfoInteger(this.m_name,SYMBOL_SELECT);
   ::ResetLastError();
   if(!select)
     {
      if(!this.SetToMarketWatch())
        {
         this.m_global_error=::GetLastError();
         ::Print(DFUN_ERR_LINE,"\"",this.m_name,"\": ",CMessage::Text(MSG_LIB_SYS_FAILED_PUT_SYMBOL),this.m_global_error);
        }
     }
   ::ResetLastError();
   if(!::SymbolInfoTick(this.m_name,this.m_tick))
     {
      this.m_global_error=::GetLastError();
      ::Print(DFUN_ERR_LINE,"\"",this.m_name,"\": ",CMessage::Text(MSG_LIB_SYS_NOT_GET_PRICE),this.m_global_error);
     }
   //--- Initialize base object data arrays
     this.SetControlDataArraySizeLong(SYMBOL_PROP_INTEGER_TOTAL);
     this.SetControlDataArraySizeDouble(SYMBOL_PROP_DOUBLE_TOTAL);
     this.ResetChangesParams();
     this.ResetControlsParams();   
   //--- Initialize symbol data
     this.Reset();
     this.InitMarginRates();
   #ifdef __MQL5__
     ::ResetLastError();
    if(!this.MarginRates())
     {
      this.m_global_error=::GetLastError();
      ::Print(DFUN_ERR_LINE,this.Name(),": ",CMessage::Text(MSG_LIB_SYS_NOT_GET_MARGIN_RATES),this.m_global_error);
      return;
     }
   #endif 
   //--- Save integer properties
     this.m_long_prop[SYMBOL_PROP_STATUS]                                             = symbol_status;
     this.m_long_prop[SYMBOL_PROP_INDEX_MW]                                           = index;
     this.m_long_prop[SYMBOL_PROP_VOLUME]                                             = (long)this.m_tick.volume;
     this.m_long_prop[SYMBOL_PROP_SELECT]                                             = ::SymbolInfoInteger(this.m_name,SYMBOL_SELECT);
     this.m_long_prop[SYMBOL_PROP_VISIBLE]                                            = ::SymbolInfoInteger(this.m_name,SYMBOL_VISIBLE);
     this.m_long_prop[SYMBOL_PROP_SESSION_DEALS]                                      = ::SymbolInfoInteger(this.m_name,SYMBOL_SESSION_DEALS);
     this.m_long_prop[SYMBOL_PROP_SESSION_BUY_ORDERS]                                 = ::SymbolInfoInteger(this.m_name,SYMBOL_SESSION_BUY_ORDERS);
     this.m_long_prop[SYMBOL_PROP_SESSION_SELL_ORDERS]                                = ::SymbolInfoInteger(this.m_name,SYMBOL_SESSION_SELL_ORDERS);
     this.m_long_prop[SYMBOL_PROP_VOLUMEHIGH]                                         = ::SymbolInfoInteger(this.m_name,SYMBOL_VOLUMEHIGH);
     this.m_long_prop[SYMBOL_PROP_VOLUMELOW]                                          = ::SymbolInfoInteger(this.m_name,SYMBOL_VOLUMELOW);
     this.m_long_prop[SYMBOL_PROP_DIGITS]                                             = ::SymbolInfoInteger(this.m_name,SYMBOL_DIGITS);
     this.m_long_prop[SYMBOL_PROP_SPREAD]                                             = ::SymbolInfoInteger(this.m_name,SYMBOL_SPREAD);
     this.m_long_prop[SYMBOL_PROP_SPREAD_FLOAT]                                       = ::SymbolInfoInteger(this.m_name,SYMBOL_SPREAD_FLOAT);
     this.m_long_prop[SYMBOL_PROP_TICKS_BOOKDEPTH]                                    = ::SymbolInfoInteger(this.m_name,SYMBOL_TICKS_BOOKDEPTH);
     this.m_long_prop[SYMBOL_PROP_TRADE_MODE]                                         = ::SymbolInfoInteger(this.m_name,SYMBOL_TRADE_MODE);
     this.m_long_prop[SYMBOL_PROP_START_TIME]                                         = ::SymbolInfoInteger(this.m_name,SYMBOL_START_TIME);
     this.m_long_prop[SYMBOL_PROP_EXPIRATION_TIME]                                    = ::SymbolInfoInteger(this.m_name,SYMBOL_EXPIRATION_TIME);
     this.m_long_prop[SYMBOL_PROP_TRADE_STOPS_LEVEL]                                  = ::SymbolInfoInteger(this.m_name,SYMBOL_TRADE_STOPS_LEVEL);
     this.m_long_prop[SYMBOL_PROP_TRADE_FREEZE_LEVEL]                                 = ::SymbolInfoInteger(this.m_name,SYMBOL_TRADE_FREEZE_LEVEL);
     this.m_long_prop[SYMBOL_PROP_TRADE_EXEMODE]                                      = ::SymbolInfoInteger(this.m_name,SYMBOL_TRADE_EXEMODE);
     this.m_long_prop[SYMBOL_PROP_SWAP_ROLLOVER3DAYS]                                 = ::SymbolInfoInteger(this.m_name,SYMBOL_SWAP_ROLLOVER3DAYS);
     this.m_long_prop[SYMBOL_PROP_SECTOR]                                             = ::SymbolInfoInteger(this.m_name,SYMBOL_SECTOR);
     this.m_long_prop[SYMBOL_PROP_INDUSTRY]                                           = ::SymbolInfoInteger(this.m_name,SYMBOL_INDUSTRY);
     this.m_long_prop[SYMBOL_PROP_TIME_MSC]                                           = ::SymbolInfoInteger(this.m_name,SYMBOL_TIME_MSC);
     this.m_long_prop[SYMBOL_PROP_TIME]                                               = this.TickTime();
     this.m_long_prop[SYMBOL_PROP_EXIST]                                              = this.SymbolExists();
     this.m_long_prop[SYMBOL_PROP_CUSTOM]                                             = this.SymbolCustom();
     this.m_long_prop[SYMBOL_PROP_MARGIN_HEDGED_USE_LEG]                              = this.SymbolMarginHedgedUseLEG();
     this.m_long_prop[SYMBOL_PROP_ORDER_MODE]                                         = this.SymbolOrderMode();
     this.m_long_prop[SYMBOL_PROP_FILLING_MODE]                                       = this.SymbolOrderFillingMode();
     this.m_long_prop[SYMBOL_PROP_EXPIRATION_MODE]                                    = this.SymbolExpirationMode();
     this.m_long_prop[SYMBOL_PROP_ORDER_GTC_MODE]                                     = this.SymbolOrderGTCMode();
     this.m_long_prop[SYMBOL_PROP_OPTION_MODE]                                        = this.SymbolOptionMode();
     this.m_long_prop[SYMBOL_PROP_OPTION_RIGHT]                                       = this.SymbolOptionRight();
     this.m_long_prop[SYMBOL_PROP_BACKGROUND_COLOR]                                   = this.SymbolBackgroundColor();
     this.m_long_prop[SYMBOL_PROP_CHART_MODE]                                         = this.SymbolChartMode();
     this.m_long_prop[SYMBOL_PROP_TRADE_CALC_MODE]                                    = this.SymbolCalcMode();
     this.m_long_prop[SYMBOL_PROP_SWAP_MODE]                                          = this.SymbolSwapMode();
     this.m_long_prop[SYMBOL_PROP_BOOKDEPTH_STATE]                                    = this.m_book_subscribed;
     this.m_long_prop[SYMBOL_PROP_SUBSCRIPTION_DELAY]                                 = this.SymbolSubscriptionDelay();
   //--- Save real properties
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_ASKHIGH)]                          = ::SymbolInfoDouble(this.m_name,SYMBOL_ASKHIGH);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_ASKLOW)]                           = ::SymbolInfoDouble(this.m_name,SYMBOL_ASKLOW);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_LASTHIGH)]                         = ::SymbolInfoDouble(this.m_name,SYMBOL_LASTHIGH);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_LASTLOW)]                          = ::SymbolInfoDouble(this.m_name,SYMBOL_LASTLOW);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_POINT)]                            = ::SymbolInfoDouble(this.m_name,SYMBOL_POINT);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_TICK_VALUE)]                 = ::SymbolInfoDouble(this.m_name,SYMBOL_TRADE_TICK_VALUE);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_TICK_VALUE_PROFIT)]          = ::SymbolInfoDouble(this.m_name,SYMBOL_TRADE_TICK_VALUE_PROFIT);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_TICK_VALUE_LOSS)]            = ::SymbolInfoDouble(this.m_name,SYMBOL_TRADE_TICK_VALUE_LOSS);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_TICK_SIZE)]                  = ::SymbolInfoDouble(this.m_name,SYMBOL_TRADE_TICK_SIZE);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_CONTRACT_SIZE)]              = ::SymbolInfoDouble(this.m_name,SYMBOL_TRADE_CONTRACT_SIZE);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUME_MIN)]                       = ::SymbolInfoDouble(this.m_name,SYMBOL_VOLUME_MIN);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUME_MAX)]                       = ::SymbolInfoDouble(this.m_name,SYMBOL_VOLUME_MAX);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUME_STEP)]                      = ::SymbolInfoDouble(this.m_name,SYMBOL_VOLUME_STEP);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUME_LIMIT)]                     = ::SymbolInfoDouble(this.m_name,SYMBOL_VOLUME_LIMIT);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SWAP_LONG)]                        = ::SymbolInfoDouble(this.m_name,SYMBOL_SWAP_LONG);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SWAP_SHORT)]                       = ::SymbolInfoDouble(this.m_name,SYMBOL_SWAP_SHORT);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_INITIAL)]                   = ::SymbolInfoDouble(this.m_name,SYMBOL_MARGIN_INITIAL);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_MAINTENANCE)]               = ::SymbolInfoDouble(this.m_name,SYMBOL_MARGIN_MAINTENANCE);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_VOLUME)]                   = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_VOLUME);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_TURNOVER)]                 = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_TURNOVER);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_INTEREST)]                 = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_INTEREST);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_BUY_ORDERS_VOLUME)]        = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_BUY_ORDERS_VOLUME);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_SELL_ORDERS_VOLUME)]       = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_SELL_ORDERS_VOLUME);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_OPEN)]                     = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_OPEN);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_CLOSE)]                    = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_CLOSE);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_AW)]                       = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_AW);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_PRICE_SETTLEMENT)]         = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_PRICE_SETTLEMENT);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_PRICE_LIMIT_MIN)]          = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_PRICE_LIMIT_MIN);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_PRICE_LIMIT_MAX)]          = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_PRICE_LIMIT_MAX);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_PRICE_CHANGE)]                     = ::SymbolInfoDouble(this.m_name,SYMBOL_PRICE_CHANGE);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_PRICE_VOLATILITY)]                 = ::SymbolInfoDouble(this.m_name,SYMBOL_PRICE_VOLATILITY);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_PRICE_THEORETICAL)]                = ::SymbolInfoDouble(this.m_name,SYMBOL_PRICE_THEORETICAL);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_PRICE_DELTA)]                      = ::SymbolInfoDouble(this.m_name,SYMBOL_PRICE_DELTA);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_PRICE_THETA)]                      = ::SymbolInfoDouble(this.m_name,SYMBOL_PRICE_THETA);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_PRICE_GAMMA)]                      = ::SymbolInfoDouble(this.m_name,SYMBOL_PRICE_GAMMA);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_PRICE_VEGA)]                       = ::SymbolInfoDouble(this.m_name,SYMBOL_PRICE_VEGA);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_PRICE_RHO)]                        = ::SymbolInfoDouble(this.m_name,SYMBOL_PRICE_RHO);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_PRICE_OMEGA)]                      = ::SymbolInfoDouble(this.m_name,SYMBOL_PRICE_OMEGA);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_PRICE_SENSITIVITY)]                = ::SymbolInfoDouble(this.m_name,SYMBOL_PRICE_SENSITIVITY);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_BID)]                              = this.m_tick.bid;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_ASK)]                              = this.m_tick.ask;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_LAST)]                             = this.m_tick.last;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_BIDHIGH)]                          = this.SymbolBidHigh();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_BIDLOW)]                           = this.SymbolBidLow();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUME_REAL)]                      = this.SymbolVolumeReal();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUMEHIGH_REAL)]                  = this.SymbolVolumeHighReal();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUMELOW_REAL)]                   = this.SymbolVolumeLowReal();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_OPTION_STRIKE)]                    = this.SymbolOptionStrike();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_ACCRUED_INTEREST)]           = this.SymbolTradeAccruedInterest();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_FACE_VALUE)]                 = this.SymbolTradeFaceValue();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_LIQUIDITY_RATE)]             = this.SymbolTradeLiquidityRate();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_HEDGED)]                    = this.SymbolMarginHedged();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_LONG_INITIAL)]              = this.m_margin_rate.Long.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_BUY_STOP_INITIAL)]          = this.m_margin_rate.BuyStop.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_BUY_LIMIT_INITIAL)]         = this.m_margin_rate.BuyLimit.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_INITIAL)]     = this.m_margin_rate.BuyStopLimit.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_LONG_MAINTENANCE)]          = this.m_margin_rate.Long.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_BUY_STOP_MAINTENANCE)]      = this.m_margin_rate.BuyStop.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_BUY_LIMIT_MAINTENANCE)]     = this.m_margin_rate.BuyLimit.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_MAINTENANCE)] = this.m_margin_rate.BuyStopLimit.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SHORT_INITIAL)]             = this.m_margin_rate.Short.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SELL_STOP_INITIAL)]         = this.m_margin_rate.SellStop.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SELL_LIMIT_INITIAL)]        = this.m_margin_rate.SellLimit.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_INITIAL)]    = this.m_margin_rate.SellStopLimit.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SHORT_MAINTENANCE)]         = this.m_margin_rate.Short.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SELL_STOP_MAINTENANCE)]     = this.m_margin_rate.SellStop.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SELL_LIMIT_MAINTENANCE)]    = this.m_margin_rate.SellLimit.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_MAINTENANCE)]= this.m_margin_rate.SellStopLimit.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SWAP_SUNDAY)]                      = this.SymbolSwapRatio(SUNDAY);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SWAP_MONDAY)]                      = this.SymbolSwapRatio(MONDAY);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SWAP_TUESDAY)]                     = this.SymbolSwapRatio(TUESDAY);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SWAP_WEDNESDAY)]                   = this.SymbolSwapRatio(WEDNESDAY);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SWAP_THURSDAY)]                    = this.SymbolSwapRatio(THURSDAY);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SWAP_FRIDAY)]                      = this.SymbolSwapRatio(FRIDAY);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SWAP_SATURDAY)]                    = this.SymbolSwapRatio(SATURDAY);
   //--- Save string properties
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_NAME)]                             = this.m_name;
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_CURRENCY_BASE)]                    = ::SymbolInfoString(this.m_name,SYMBOL_CURRENCY_BASE);
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_CURRENCY_PROFIT)]                  = ::SymbolInfoString(this.m_name,SYMBOL_CURRENCY_PROFIT);
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_CURRENCY_MARGIN)]                  = ::SymbolInfoString(this.m_name,SYMBOL_CURRENCY_MARGIN);
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_DESCRIPTION)]                      = ::SymbolInfoString(this.m_name,SYMBOL_DESCRIPTION);
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_PATH)]                             = ::SymbolInfoString(this.m_name,SYMBOL_PATH);
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_COUNTRY)]                          = ::SymbolInfoString(this.m_name,SYMBOL_COUNTRY);
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_SECTOR_NAME)]                      = ::SymbolInfoString(this.m_name,SYMBOL_SECTOR_NAME);
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_INDUSTRY_NAME)]                    = ::SymbolInfoString(this.m_name,SYMBOL_INDUSTRY_NAME);
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_BASIS)]                            = this.SymbolBasis();
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_BANK)]                             = this.SymbolBank();
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_ISIN)]                             = this.SymbolISIN();
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_FORMULA)]                          = this.SymbolFormula();
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_PAGE)]                             = this.SymbolPage();
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_CATEGORY)]                         = this.SymbolCategory();
     this.m_string_prop[this.IndexProp(SYMBOL_PROP_EXCHANGE)]                         = this.SymbolExchange();
   //--- Save additional integer properties
     this.m_long_prop[SYMBOL_PROP_DIGITS_LOTS]                                        = this.SymbolDigitsLot();   
   //--- Fill in the symbol current data
     for(int i=0;i<SYMBOL_PROP_INTEGER_TOTAL;i++)
        this.m_long_prop_event[i][3]=this.m_long_prop[i];
     for(int i=0;i<SYMBOL_PROP_DOUBLE_TOTAL;i++)
        this.m_double_prop_event[i][3]=this.m_double_prop[i];
   //--- Update the base object data and search for changes
     CBaseObjExt::Refresh();
   //---
    if(!select)
      this.RemoveFromMarketWatch();
   //--- Initializing default values of a trading object
    this.m_trade_obj.Init(this.Name(),0,this.LotsMin(),5,0,0,false,this.GetCorrectTypeFilling(),this.GetCorrectTypeExpiration(),LOG_LEVEL_ERROR_MSG);
  }
 //+------------------------------------------------------------------+
 //| Destructor                                                       |
 //+------------------------------------------------------------------+
 CSymbol::~CSymbol(void)
  {
   if(this.m_book_subscribed)
      this.BookClose();
  }
 //+------------------------------------------------------------------------------------------------------------+
 //|Compare CSymbol objects by all possible properties (for sorting lists by a specified symbol object property)|
 //+------------------------------------------------------------------------------------------------------------+
 int CSymbol::Compare(const CObject *node,const int mode=0) const
  {
   const CSymbol *symbol_compared=node;
   //--- compare integer properties of two symbols
    if(mode<SYMBOL_PROP_INTEGER_TOTAL)
     {
      long value_compared=symbol_compared.GetProperty((ENUM_SYMBOL_PROP_INTEGER)mode);
      long value_current=this.GetProperty((ENUM_SYMBOL_PROP_INTEGER)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   //--- compare real properties of two symbols
    else if(mode<SYMBOL_PROP_INTEGER_TOTAL+SYMBOL_PROP_DOUBLE_TOTAL)
     {
      double value_compared=symbol_compared.GetProperty((ENUM_SYMBOL_PROP_DOUBLE)mode);
      double value_current=this.GetProperty((ENUM_SYMBOL_PROP_DOUBLE)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   //--- compare string properties of two symbols
    else if(mode<SYMBOL_PROP_INTEGER_TOTAL+SYMBOL_PROP_DOUBLE_TOTAL+SYMBOL_PROP_STRING_TOTAL)
     {
      string value_compared=symbol_compared.GetProperty((ENUM_SYMBOL_PROP_STRING)mode);
      string value_current=this.GetProperty((ENUM_SYMBOL_PROP_STRING)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   return 0;
  }
 //+------------------------------------------------------------------+
 //| Compare CSymbol objects by all properties                        |
 //+------------------------------------------------------------------+
 bool CSymbol::IsEqual(CSymbol *compared_symbol) const
  {
   int begin=0, end=SYMBOL_PROP_INTEGER_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_SYMBOL_PROP_INTEGER prop=(ENUM_SYMBOL_PROP_INTEGER)i;
      if(this.GetProperty(prop)!=compared_symbol.GetProperty(prop)) return false; 
     }
   begin=end; end+=SYMBOL_PROP_DOUBLE_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_SYMBOL_PROP_DOUBLE prop=(ENUM_SYMBOL_PROP_DOUBLE)i;
      if(this.GetProperty(prop)!=compared_symbol.GetProperty(prop)) return false; 
     }
   begin=end; end+=SYMBOL_PROP_STRING_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_SYMBOL_PROP_STRING prop=(ENUM_SYMBOL_PROP_STRING)i;
      if(this.GetProperty(prop)!=compared_symbol.GetProperty(prop)) return false; 
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Fill in the margin ratio variables                               |
 //+------------------------------------------------------------------+
 bool CSymbol::MarginRates(void)
  {
   bool res=true;
   #ifdef __MQL5__
      res &=this.SymbolMarginLong();
      res &=this.SymbolMarginBuyStop();
      res &=this.SymbolMarginBuyLimit();
      res &=this.SymbolMarginBuyStopLimit();
      res &=this.SymbolMarginShort();
      res &=this.SymbolMarginSellStop();
      res &=this.SymbolMarginSellLimit();
      res &=this.SymbolMarginSellStopLimit();
   #else 
      this.InitMarginRates();
      res=false;
   #endif 
   return res;
  }
 //+------------------------------------------------------------------+
 //| Initialize margin ratios                                         |
 //+------------------------------------------------------------------+
 void CSymbol::InitMarginRates(void)
  {
   this.m_margin_rate.Long.Initial=0;           this.m_margin_rate.Long.Maintenance=0;
   this.m_margin_rate.BuyStop.Initial=0;        this.m_margin_rate.BuyStop.Maintenance=0;
   this.m_margin_rate.BuyLimit.Initial=0;       this.m_margin_rate.BuyLimit.Maintenance=0;
   this.m_margin_rate.BuyStopLimit.Initial=0;   this.m_margin_rate.BuyStopLimit.Maintenance=0;
   this.m_margin_rate.Short.Initial=0;          this.m_margin_rate.Short.Maintenance=0;
   this.m_margin_rate.SellStop.Initial=0;       this.m_margin_rate.SellStop.Maintenance=0;
   this.m_margin_rate.SellLimit.Initial=0;      this.m_margin_rate.SellLimit.Maintenance=0;
   this.m_margin_rate.SellStopLimit.Initial=0;  this.m_margin_rate.SellStopLimit.Maintenance=0;
  }
 //+------------------------------------------------------------------+
 //| Reset all symbol object data                                     |
 //+------------------------------------------------------------------+
 void CSymbol::Reset(void)
  {
   int begin=0, end=SYMBOL_PROP_INTEGER_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_SYMBOL_PROP_INTEGER prop=(ENUM_SYMBOL_PROP_INTEGER)i;
      this.SetProperty(prop,0);
     }
   begin=end; end+=SYMBOL_PROP_DOUBLE_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_SYMBOL_PROP_DOUBLE prop=(ENUM_SYMBOL_PROP_DOUBLE)i;
      this.SetProperty(prop,0);
     }
   begin=end; end+=SYMBOL_PROP_STRING_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_SYMBOL_PROP_STRING prop=(ENUM_SYMBOL_PROP_STRING)i;
      this.SetProperty(prop,NULL);
     }
  }
 //+------------------------------------------------------------------+
 //| Integer properties                                               |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| Return the symbol existence flag                                 |
 //+------------------------------------------------------------------+
 long CSymbol::SymbolExists(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoInteger(this.m_name,SYMBOL_EXIST) #else this.Exist() #endif);
  }
 //+------------------------------------------------------------------+
 bool CSymbol::SymbolExists(const string name) const
  {
   return(#ifdef __MQL5__ (bool)::SymbolInfoInteger(name,SYMBOL_EXIST) #else Exist(name) #endif);
  }
 //+------------------------------------------------------------------+
 //| Return the custom symbol flag                                    |
 //+------------------------------------------------------------------+
 long CSymbol::SymbolCustom(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoInteger(this.m_name,SYMBOL_CUSTOM) #else false #endif);
  }
 //+------------------------------------------------------------------+
 //| Return the price type for building bars - Bid or Last            |
 //+------------------------------------------------------------------+
 long CSymbol::SymbolChartMode(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoInteger(this.m_name,SYMBOL_CHART_MODE) #else SYMBOL_CHART_MODE_BID #endif);
  }
 //+--------------------------------------------------------------------+
 //|Return the calculation mode of a hedging margin using the larger leg|
 //+--------------------------------------------------------------------+
 long CSymbol::SymbolMarginHedgedUseLEG(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoInteger(this.m_name,SYMBOL_MARGIN_HEDGED_USE_LEG) #else false #endif);
  }
 //+------------------------------------------------------------------+
 //| Return the order filling policies flags                          |
 //+------------------------------------------------------------------+
 long CSymbol::SymbolOrderFillingMode(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoInteger(this.m_name,SYMBOL_FILLING_MODE) #else 0 #endif );
  }
 //+------------------------------------------------------------------+
 //| Return the flag allowing the closure by an opposite position     |
 //+------------------------------------------------------------------+
 bool CSymbol::IsCloseByOrdersAllowed(void) const
  {
   return(#ifdef __MQL5__(this.OrderModeFlags() & SYMBOL_ORDER_CLOSEBY)==SYMBOL_ORDER_CLOSEBY #else (bool)::MarketInfo(this.m_name,MODE_CLOSEBY_ALLOWED)  #endif );
  }  
 //| Return the option type                                           |
 //+------------------------------------------------------------------+
 long CSymbol::SymbolOptionMode(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoInteger(this.m_name,SYMBOL_OPTION_MODE) #else SYMBOL_OPTION_MODE_NONE #endif);
  }
 //+------------------------------------------------------------------+
 //| Return the option right                                          |
 //+------------------------------------------------------------------+
 long CSymbol::SymbolOptionRight(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoInteger(this.m_name,SYMBOL_OPTION_RIGHT) #else SYMBOL_OPTION_RIGHT_NONE #endif);
  }
 //+----------------------------------------------------------------------+
 //|Return the background color used to highlight a symbol in Market Watch|
 //+----------------------------------------------------------------------+
 long CSymbol::SymbolBackgroundColor(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoInteger(this.m_name,SYMBOL_BACKGROUND_COLOR) #else clrNONE #endif);
  }
 //+------------------------------------------------------------------+
 //| Return the margin calculation method                             |
 //+------------------------------------------------------------------+
 long CSymbol::SymbolCalcMode(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoInteger(this.m_name,SYMBOL_TRADE_CALC_MODE) #else (long)::MarketInfo(this.m_name,MODE_MARGINCALCMODE) #endif);
  }
 //+------------------------------------------------------------------+
 //| Return the swaps calculation method                              |
 //+------------------------------------------------------------------+
 long CSymbol::SymbolSwapMode(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoInteger(this.m_name,SYMBOL_SWAP_MODE) #else (long)::MarketInfo(this.m_name,MODE_SWAPTYPE) #endif);
  }
 //+------------------------------------------------------------------+
 //| Return the flags of allowed order expiration modes               |
 //+------------------------------------------------------------------+
 long CSymbol::SymbolExpirationMode(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoInteger(this.m_name,SYMBOL_EXPIRATION_MODE) #else (long)SYMBOL_EXPIRATION_GTC #endif);
  }
 //+------------------------------------------------------------------+
 //| Return the lifetime of pending orders and                        |
 //| placed StopLoss/TakeProfit levels                                |
 //+------------------------------------------------------------------+
 long CSymbol::SymbolOrderGTCMode(void) const
  {
   return
     (
     #ifdef __MQL5__ 
      this.IsExpirationModeGTC() ? ::SymbolInfoInteger(this.m_name,SYMBOL_ORDER_GTC_MODE) : WRONG_VALUE
     #else 
      SYMBOL_ORDERS_GTC 
     #endif
     );
  }
 //+------------------------------------------------------------------+
 //| Return the flags of allowed order types                          |
 //+------------------------------------------------------------------+
 long CSymbol::SymbolOrderMode(void) const
  {
   return
     (
      #ifdef __MQL5__
         ::SymbolInfoInteger(this.m_name,SYMBOL_ORDER_MODE)
      #else 
         (SYMBOL_ORDER_MARKET+SYMBOL_ORDER_LIMIT+SYMBOL_ORDER_STOP+SYMBOL_ORDER_SL+SYMBOL_ORDER_TP+(this.IsCloseByOrdersAllowed() ? SYMBOL_ORDER_CLOSEBY : 0))
      #endif 
     );
  }
 //+------------------------------------------------------------------+
 //| Calculate and return the number of decimal places                |
 //| in a symbol lot                                                  |
 //+------------------------------------------------------------------+
 long CSymbol::SymbolDigitsLot(void)
  {
   if(this.LotsMax()==0 || this.LotsMin()==0 || this.LotsStep()==0)
     {
      ::Print(DFUN_ERR_LINE,CMessage::Text(MSG_LIB_SYS_NOT_GET_DATAS),"\"",this.Name(),"\"");
      this.m_global_error=ERR_MARKET_UNKNOWN_SYMBOL;
      return 2;
     }
   return long(fmax(this.GetDigits(this.LotsMin()),this.GetDigits(this.LotsStep())));
  }
 //+------------------------------------------------------------------+
 //| Return the number of decimal places                              |
 //| depending on the swap calculation method                         |
 //+------------------------------------------------------------------+
 int CSymbol::SymbolDigitsBySwap(void)
  {
   return
     (
      this.SwapMode()==SYMBOL_SWAP_MODE_POINTS           || 
      this.SwapMode()==SYMBOL_SWAP_MODE_REOPEN_CURRENT   || 
      this.SwapMode()==SYMBOL_SWAP_MODE_REOPEN_BID       ?  this.Digits() :
      this.SwapMode()==SYMBOL_SWAP_MODE_CURRENCY_SYMBOL  || 
      this.SwapMode()==SYMBOL_SWAP_MODE_CURRENCY_MARGIN  || 
      this.SwapMode()==SYMBOL_SWAP_MODE_CURRENCY_PROFIT  || 
      this.SwapMode()==SYMBOL_SWAP_MODE_CURRENCY_DEPOSIT ?  this.DigitsCurrency():
      this.SwapMode()==SYMBOL_SWAP_MODE_INTEREST_CURRENT || 
      this.SwapMode()==SYMBOL_SWAP_MODE_INTEREST_OPEN    ?  1  :  0
     );
  }
 //+------------------------------------------------------------------+
 //| Return the delay size for quotes passed by symbol                |
 //| in case of subscription-based symbols                            |
 //+------------------------------------------------------------------+
 long CSymbol::SymbolSubscriptionDelay(void) const
  {
   return
     (
      #ifdef __MQL5__ (::TerminalInfoInteger(TERMINAL_BUILD)>=3245 ? ::SymbolInfoInteger(this.m_name,SYMBOL_SUBSCRIPTION_DELAY) : 0)
      #else 0
      #endif 
     );
  }
 //+------------------------------------------------------------------+
 //|Return the swap accrual ratio for a specified day of the week     |
 //+------------------------------------------------------------------+
 double CSymbol::SymbolSwapRatio(ENUM_DAY_OF_WEEK day) const
  {
   #ifdef __MQL4__ 
      return 0;
   #else 
      switch(day)
      {
         case MONDAY    :  return ::SymbolInfoDouble(this.m_name,SYMBOL_SWAP_MONDAY);
         case TUESDAY   :  return ::SymbolInfoDouble(this.m_name,SYMBOL_SWAP_TUESDAY);
         case WEDNESDAY :  return ::SymbolInfoDouble(this.m_name,SYMBOL_SWAP_WEDNESDAY);
         case THURSDAY  :  return ::SymbolInfoDouble(this.m_name,SYMBOL_SWAP_THURSDAY);
         case FRIDAY    :  return ::SymbolInfoDouble(this.m_name,SYMBOL_SWAP_FRIDAY);
         case SATURDAY  :  return ::SymbolInfoDouble(this.m_name,SYMBOL_SWAP_SATURDAY);
         //---SUNDAY
         default        :  return (int)::SymbolInfoDouble(this.m_name,SYMBOL_SWAP_SUNDAY);
      }
   #endif 
  }
 //+------------------------------------------------------------------+
 //|Return the swap accrual ratio for a specified day of the week     |
 //+------------------------------------------------------------------+
 double CSymbol::SwapRatioDay(const ENUM_DAY_OF_WEEK day) const
  {
   switch(day)
     {
      case MONDAY    :  return this.SwapRatioMonday();
      case TUESDAY   :  return this.SwapRatioTuesday();
      case WEDNESDAY :  return this.SwapRatioWednesday();
      case THURSDAY  :  return this.SwapRatioThursday();
      case FRIDAY    :  return this.SwapRatioFriday();
      case SATURDAY  :  return this.SwapRatioSaturday();
      //---SUNDAY
      default        :  return this.SwapRatioSunday();
     }
  }
 //+------------------------------------------------------------------+
 //| Real properties                                                  |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| Return maximum Bid for a day                                     |
 //+------------------------------------------------------------------+
 double CSymbol::SymbolBidHigh(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoDouble(this.m_name,SYMBOL_BIDHIGH) #else ::MarketInfo(this.m_name,MODE_HIGH) #endif);
  }
 //+------------------------------------------------------------------+
 //| Return minimum Bid for a day                                     |
 //+------------------------------------------------------------------+
 double CSymbol::SymbolBidLow(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoDouble(this.m_name,SYMBOL_BIDLOW) #else ::MarketInfo(this.m_name,MODE_LOW) #endif);
  }
 //+------------------------------------------------------------------+
 //| Return real Volume for a day                                     |
 //+------------------------------------------------------------------+
 double CSymbol::SymbolVolumeReal(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoDouble(this.m_name,SYMBOL_VOLUME_REAL) #else 0 #endif);
  }
 //+------------------------------------------------------------------+
 //| Return real maximum Volume for a day                             |
 //+------------------------------------------------------------------+
 double CSymbol::SymbolVolumeHighReal(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoDouble(this.m_name,SYMBOL_VOLUMEHIGH_REAL) #else 0 #endif);
  }
 //+------------------------------------------------------------------+
 //| Return real minimum Volume for a day                             |
 //+------------------------------------------------------------------+
 double CSymbol::SymbolVolumeLowReal(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoDouble(this.m_name,SYMBOL_VOLUMELOW_REAL) #else 0 #endif);
  }
 //+------------------------------------------------------------------+
 //| Return an option execution price                                 |
 //+------------------------------------------------------------------+
 double CSymbol::SymbolOptionStrike(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoDouble(this.m_name,SYMBOL_OPTION_STRIKE) #else 0 #endif);
  }
 //+------------------------------------------------------------------+
 //| Return accrued interest                                          |
 //+------------------------------------------------------------------+
 double CSymbol::SymbolTradeAccruedInterest(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoDouble(this.m_name,SYMBOL_TRADE_ACCRUED_INTEREST) #else 0 #endif);
  }
 //+------------------------------------------------------------------+
 //| Return a bond face value                                         |
 //+------------------------------------------------------------------+
 double CSymbol::SymbolTradeFaceValue(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoDouble(this.m_name,SYMBOL_TRADE_FACE_VALUE) #else 0 #endif);
  }
 //+------------------------------------------------------------------+
 //| Return a liquidity rate                                          |
 //+------------------------------------------------------------------+
 double CSymbol::SymbolTradeLiquidityRate(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoDouble(this.m_name,SYMBOL_TRADE_LIQUIDITY_RATE) #else 0 #endif);
  }
 //+------------------------------------------------------------------+
 //| Return a contract or margin size                                 |
 //| for a single lot of covered positions                            |
 //+------------------------------------------------------------------+
 double CSymbol::SymbolMarginHedged(void) const
  {
   return(#ifdef __MQL5__ ::SymbolInfoDouble(this.m_name,SYMBOL_MARGIN_HEDGED) #else ::MarketInfo(this.m_name, MODE_MARGINHEDGED) #endif);
  }
 //+------------------------------------------------------------------+
 //| Fill in the margin ratios for long positions                     |
 //+------------------------------------------------------------------+
 bool CSymbol::SymbolMarginLong(void)
  {
   return(#ifdef __MQL5__ ::SymbolInfoMarginRate(this.m_name,ORDER_TYPE_BUY,this.m_margin_rate.Long.Initial,this.m_margin_rate.Long.Maintenance) #else false #endif);
  }
 //+------------------------------------------------------------------+
 //| Fill in the margin ratios for short positions                    |
 //+------------------------------------------------------------------+
 bool CSymbol::SymbolMarginShort(void)
  {
   return(#ifdef __MQL5__ ::SymbolInfoMarginRate(this.m_name,ORDER_TYPE_SELL,this.m_margin_rate.Short.Initial,this.m_margin_rate.Short.Maintenance) #else false #endif);
  }
 //+------------------------------------------------------------------+
 //| Fill in the margin ratios for BuyStop orders                     |
 //+------------------------------------------------------------------+
 bool CSymbol::SymbolMarginBuyStop(void)
  {
   return(#ifdef __MQL5__ ::SymbolInfoMarginRate(this.m_name,ORDER_TYPE_BUY_STOP,this.m_margin_rate.BuyStop.Initial,this.m_margin_rate.BuyStop.Maintenance) #else false #endif);
  }
 //+------------------------------------------------------------------+
 //| Fill in the margin ratios for BuyLimit orders                    |
 //+------------------------------------------------------------------+
 bool CSymbol::SymbolMarginBuyLimit(void)
  {
   return(#ifdef __MQL5__ ::SymbolInfoMarginRate(this.m_name,ORDER_TYPE_BUY_LIMIT,this.m_margin_rate.BuyLimit.Initial,this.m_margin_rate.BuyLimit.Maintenance) #else false #endif);
  }
 //+------------------------------------------------------------------+
 //| Fill in the margin ratios for BuyStopLimit orders                |
 //+------------------------------------------------------------------+
 bool CSymbol::SymbolMarginBuyStopLimit(void)
  {
   return(#ifdef __MQL5__ ::SymbolInfoMarginRate(this.m_name,ORDER_TYPE_BUY_STOP_LIMIT,this.m_margin_rate.BuyStopLimit.Initial,this.m_margin_rate.BuyStopLimit.Maintenance) #else false #endif);
  }
 //+------------------------------------------------------------------+
 //| Fill in the margin ratios for SellStop orders                    |
 //+------------------------------------------------------------------+
 bool CSymbol::SymbolMarginSellStop(void)
  {
   return(#ifdef __MQL5__ ::SymbolInfoMarginRate(this.m_name,ORDER_TYPE_SELL_STOP,this.m_margin_rate.SellStop.Initial,this.m_margin_rate.SellStop.Maintenance) #else false #endif);
  }
 //+------------------------------------------------------------------+
 //| Fill in the margin ratios for SellLimit orders                   |
 //+------------------------------------------------------------------+
 bool CSymbol::SymbolMarginSellLimit(void)
  {
   return(#ifdef __MQL5__ ::SymbolInfoMarginRate(this.m_name,ORDER_TYPE_SELL_LIMIT,this.m_margin_rate.SellLimit.Initial,this.m_margin_rate.SellLimit.Maintenance) #else false #endif);
  }
 //+------------------------------------------------------------------+
 //| Fill in the margin ratios for SellStopLimit orders               |
 //+------------------------------------------------------------------+
 bool CSymbol::SymbolMarginSellStopLimit(void)
  {
   return(#ifdef __MQL5__ ::SymbolInfoMarginRate(this.m_name,ORDER_TYPE_SELL_STOP_LIMIT,this.m_margin_rate.SellStopLimit.Initial,this.m_margin_rate.SellStopLimit.Maintenance) #else false #endif);
  }
 //+------------------------------------------------------------------+
 //| Return Bid or Last price                                         |
 //| depending on the chart construction method and price availability|
 //+------------------------------------------------------------------+
 double CSymbol::BidLast(void) const
  {
   return
     (
      this.ChartMode()==SYMBOL_CHART_MODE_BID ? this.GetProperty(SYMBOL_PROP_BID)  : 
     (this.GetProperty(SYMBOL_PROP_BID)==0    ? this.GetProperty(SYMBOL_PROP_LAST) : this.GetProperty(SYMBOL_PROP_BID))
     );
  }  
 //+------------------------------------------------------------------+
 //| Return maximum Bid or Last price for a day                       |
 //| depending on the chart construction method and price availability|
 //+------------------------------------------------------------------+
 double CSymbol::BidLastHigh(void) const
  {
   return
     (
      this.ChartMode()==SYMBOL_CHART_MODE_BID   ? this.GetProperty(SYMBOL_PROP_BIDHIGH)   : 
     (this.GetProperty(SYMBOL_PROP_BIDHIGH)==0  ? this.GetProperty(SYMBOL_PROP_LASTHIGH)  : this.GetProperty(SYMBOL_PROP_BIDHIGH))
     );
  }  
 //+------------------------------------------------------------------+
 //| Return minimum Bid or Last price for a day                       |
 //| depending on the chart construction method and price availability|
 //+------------------------------------------------------------------+
 double CSymbol::BidLastLow(void) const
  {
   return
     (
      this.ChartMode()==SYMBOL_CHART_MODE_BID   ? this.GetProperty(SYMBOL_PROP_BIDLOW)  : 
     (this.GetProperty(SYMBOL_PROP_BIDLOW)==0   ? this.GetProperty(SYMBOL_PROP_LASTLOW) : this.GetProperty(SYMBOL_PROP_BIDLOW))
     );
  }
 //+------------------------------------------------------------------+
 //| Return Ask or Last price                                         |
 //| depending on the chart construction method and price availability|
 //+------------------------------------------------------------------+
 double CSymbol::AskLast(void) const
  {
   return
     (
      this.ChartMode()==SYMBOL_CHART_MODE_BID ? this.GetProperty(SYMBOL_PROP_ASK)  : 
     (this.GetProperty(SYMBOL_PROP_ASK)==0    ? this.GetProperty(SYMBOL_PROP_LAST) : this.GetProperty(SYMBOL_PROP_ASK))
     );
  }  
 //+------------------------------------------------------------------+
 //| Return maximum Ask or Last price for a day                       |
 //| depending on the chart construction method and price availability|
 //+------------------------------------------------------------------+
 double CSymbol::AskLastHigh(void) const
  {
   return
     (
      this.ChartMode()==SYMBOL_CHART_MODE_BID   ? this.GetProperty(SYMBOL_PROP_ASKHIGH)   : 
     (this.GetProperty(SYMBOL_PROP_ASKHIGH)==0  ? this.GetProperty(SYMBOL_PROP_LASTHIGH)  : this.GetProperty(SYMBOL_PROP_ASKHIGH))
     );
  }  
 //+------------------------------------------------------------------+
 //| Return minimum Ask or Last price for a day                       |
 //| depending on the chart construction method and price availability|
 //+------------------------------------------------------------------+
 double CSymbol::AskLastLow(void) const
  {
   return
     (
      this.ChartMode()==SYMBOL_CHART_MODE_BID   ? this.GetProperty(SYMBOL_PROP_ASKLOW)  : 
     (this.GetProperty(SYMBOL_PROP_ASKLOW)==0   ? this.GetProperty(SYMBOL_PROP_LASTLOW) : this.GetProperty(SYMBOL_PROP_ASKLOW))
     );
  }
 //+------------------------------------------------------------------+
 //| String properties                                                |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //|  Return a base asset name for a derivative instrument            |
 //+------------------------------------------------------------------+
 string CSymbol::SymbolBasis(void) const
  {
   return
     (
      #ifdef __MQL5__ 
         ::SymbolInfoString(this.m_name,SYMBOL_BASIS) 
      #else 
         ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4)
      #endif
     );
  }
 //+------------------------------------------------------------------+
 //| Return a quote source for a symbol                               |
 //+------------------------------------------------------------------+
 string CSymbol::SymbolBank(void) const
  {
   return
     (
      #ifdef __MQL5__ 
         ::SymbolInfoString(this.m_name,SYMBOL_BANK) 
      #else 
         ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4)
      #endif
     );
  }
 //+------------------------------------------------------------------+
 //| Return a symbol name to ISIN                                     |
 //+------------------------------------------------------------------+
 string CSymbol::SymbolISIN(void) const
  {
   return
     (
      #ifdef __MQL5__ 
         ::SymbolInfoString(this.m_name,SYMBOL_ISIN) 
      #else 
         ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4)
      #endif
     );
  }
 //+------------------------------------------------------------------+
 //| Return a formula for constructing a custom symbol price          |
 //+------------------------------------------------------------------+
 string CSymbol::SymbolFormula(void) const
  {
   return
     (
      #ifdef __MQL5__ 
         ::SymbolInfoString(this.m_name,SYMBOL_FORMULA) 
      #else 
         ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4)
      #endif
     );
  }
 //+------------------------------------------------------------------+
 //| Return an address of a web page with a symbol data               |
 //+------------------------------------------------------------------+
 string CSymbol::SymbolPage(void) const
  {
   return
     (
      #ifdef __MQL5__ 
         ::SymbolInfoString(this.m_name,SYMBOL_PAGE) 
      #else 
         ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4)
      #endif
     );
  }
 //+------------------------------------------------------------------+
 //| Return a symbol category                                         |
 //+------------------------------------------------------------------+
 string CSymbol::SymbolCategory(void) const
  {
   return
     (
      #ifdef __MQL5__ 
         (
          ::TerminalInfoInteger(TERMINAL_BUILD)<2155 ? ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MT5_LESS_2155) :
          ::SymbolInfoString(this.m_name,SYMBOL_CATEGORY)
         ) 
      #else 
         ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4)
      #endif
     );
  }
 //+------------------------------------------------------------------+
 //| Return an exchange name                                          |
 //| a symbol is traded on                                            |
 //+------------------------------------------------------------------+
 string CSymbol::SymbolExchange(void) const
  {
   return
     (
      #ifdef __MQL5__ 
         (
          ::TerminalInfoInteger(TERMINAL_BUILD)<2155 ? ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MT5_LESS_2155) :
          ::SymbolInfoString(this.m_name,SYMBOL_EXCHANGE)
         ) 
      #else 
         ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4)
      #endif
     );
  }
 //+------------------------------------------------------------------+
 //| Send symbol properties to the journal                            |
 //+------------------------------------------------------------------+
 void CSymbol::Print(const bool full_prop=false,const bool dash=false)
  {
   ::Print("============= ",
           CMessage::Text(MSG_LIB_PARAMS_LIST_BEG),": \"",
           this.Name(),"\""," ",(this.Description()!= #ifdef __MQL5__ "" #else NULL #endif  ? "("+this.Description()+")" : ""),
           " =================="
          );
   int begin=0, end=SYMBOL_PROP_INTEGER_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_SYMBOL_PROP_INTEGER prop=(ENUM_SYMBOL_PROP_INTEGER)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   begin=end; end+=SYMBOL_PROP_DOUBLE_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_SYMBOL_PROP_DOUBLE prop=(ENUM_SYMBOL_PROP_DOUBLE)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   begin=end; end+=SYMBOL_PROP_STRING_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_SYMBOL_PROP_STRING prop=(ENUM_SYMBOL_PROP_STRING)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("================== ",
           CMessage::Text(MSG_LIB_PARAMS_LIST_END),": \"",
           this.Name(),"\""," ",(this.Description()!= #ifdef __MQL5__ "" #else NULL #endif  ? "("+this.Description()+")" : ""),
           " ==================\n"
          );
  }
 //+------------------------------------------------------------------+
 //| Return the description of the symbol integer property            |
 //+------------------------------------------------------------------+
 string CSymbol::GetPropertyDescription(ENUM_SYMBOL_PROP_INTEGER property)
  {
   return
     (
      property==SYMBOL_PROP_STATUS              ?  CMessage::Text(MSG_ORD_STATUS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetStatusDescription()
         )  :
      property==SYMBOL_PROP_INDEX_MW            ?  CMessage::Text(MSG_SYM_PROP_INDEX)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==SYMBOL_PROP_SECTOR              ?  CMessage::Text(MSG_SYM_PROP_SECTOR)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetSectorDescription()
         )  :
      property==SYMBOL_PROP_INDUSTRY            ?  CMessage::Text(MSG_SYM_PROP_INDUSTRY)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetIndustryDescription()
         )  :
      property==SYMBOL_PROP_CUSTOM              ?  CMessage::Text(MSG_SYM_PROP_CUSTOM)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property)   ?  CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==SYMBOL_PROP_CHART_MODE          ?  CMessage::Text(MSG_SYM_PROP_CHART_MODE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetChartModeDescription()
         )  :
      property==SYMBOL_PROP_EXIST               ?  CMessage::Text(MSG_SYM_PROP_EXIST)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property)   ?  CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==SYMBOL_PROP_SELECT  ?  CMessage::Text(MSG_SYM_PROP_SELECT)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property)   ?  CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==SYMBOL_PROP_VISIBLE ?  CMessage::Text(MSG_SYM_PROP_VISIBLE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property)   ?  CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==SYMBOL_PROP_SESSION_DEALS       ?  CMessage::Text(MSG_SYM_PROP_SESSION_DEALS)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__(string)this.GetProperty(property) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SESSION_BUY_ORDERS  ?  CMessage::Text(MSG_SYM_PROP_SESSION_BUY_ORDERS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__(string)this.GetProperty(property) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SESSION_SELL_ORDERS ?  CMessage::Text(MSG_SYM_PROP_SESSION_SELL_ORDERS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__(string)this.GetProperty(property) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_VOLUME              ?  CMessage::Text(MSG_SYM_PROP_VOLUME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__(string)this.GetProperty(property) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_VOLUMEHIGH          ?  CMessage::Text(MSG_SYM_PROP_VOLUMEHIGH)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__(string)this.GetProperty(property) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_VOLUMELOW           ?  CMessage::Text(MSG_SYM_PROP_VOLUMELOW)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__(string)this.GetProperty(property) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_TIME                ?  CMessage::Text(MSG_SYM_PROP_TIME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property)==0 ? "("+CMessage::Text(MSG_LIB_SYS_NO_TICKS_YET)+")" : TimeMSCtoString(this.GetProperty(property)))
         )  :
      property==SYMBOL_PROP_TIME_MSC            ?  CMessage::Text(MSG_SYM_PROP_TIME_MSC)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property)==0 ? "("+CMessage::Text(MSG_LIB_SYS_NO_TICKS_YET)+")" : TimeMSCtoString(this.GetProperty(property)))
         )  :
      property==SYMBOL_PROP_DIGITS              ?  CMessage::Text(MSG_SYM_PROP_DIGITS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==SYMBOL_PROP_DIGITS_LOTS         ?  CMessage::Text(MSG_SYM_PROP_DIGITS_LOTS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==SYMBOL_PROP_SPREAD              ?  CMessage::Text(MSG_SYM_PROP_SPREAD)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==SYMBOL_PROP_SPREAD_FLOAT        ?  CMessage::Text(MSG_SYM_PROP_SPREAD_FLOAT)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property)   ?  CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_YES))
         )  :
      property==SYMBOL_PROP_TICKS_BOOKDEPTH     ?  CMessage::Text(MSG_SYM_PROP_TICKS_BOOKDEPTH)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__(string)this.GetProperty(property) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_BOOKDEPTH_STATE     ?  CMessage::Text(MSG_SYM_SYMBOLS_MODE_BOOK)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__
                  (this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO)) 
                #else 
                  CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) 
                #endif 
         )  :
      property==SYMBOL_PROP_TRADE_CALC_MODE     ?  CMessage::Text(MSG_SYM_PROP_TRADE_CALC_MODE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetCalcModeDescription()
         )  :
      property==SYMBOL_PROP_TRADE_MODE ?  CMessage::Text(MSG_SYM_PROP_TRADE_MODE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetTradeModeDescription()
         )  :
      property==SYMBOL_PROP_START_TIME          ?  CMessage::Text(MSG_SYM_PROP_START_TIME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": "+TimeMSCtoString(this.GetProperty(property)*1000))
         )  :
      property==SYMBOL_PROP_EXPIRATION_TIME     ?  CMessage::Text(MSG_SYM_PROP_EXPIRATION_TIME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": "+TimeMSCtoString(this.GetProperty(property)*1000))
         )  :
      property==SYMBOL_PROP_TRADE_STOPS_LEVEL   ?  CMessage::Text(MSG_SYM_PROP_TRADE_STOPS_LEVEL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==SYMBOL_PROP_TRADE_FREEZE_LEVEL  ?  CMessage::Text(MSG_SYM_PROP_TRADE_FREEZE_LEVEL)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==SYMBOL_PROP_TRADE_EXEMODE       ?  CMessage::Text(MSG_SYM_PROP_TRADE_EXEMODE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetTradeExecDescription()
         )  :
      property==SYMBOL_PROP_SWAP_MODE           ?  CMessage::Text(MSG_SYM_PROP_SWAP_MODE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetSwapModeDescription()
         )  :
      property==SYMBOL_PROP_SWAP_ROLLOVER3DAYS  ?  CMessage::Text(MSG_SYM_PROP_SWAP_ROLLOVER3DAYS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+DayOfWeekDescription(this.SwapRollover3Days())
         )  :
      property==SYMBOL_PROP_MARGIN_HEDGED_USE_LEG  ?  CMessage::Text(MSG_SYM_PROP_MARGIN_HEDGED_USE_LEG)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED)   :
          ": "+(this.GetProperty(property)   ?  CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==SYMBOL_PROP_EXPIRATION_MODE     ?  CMessage::Text(MSG_SYM_PROP_EXPIRATION_MODE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetExpirationModeFlagsDescription()
         )  :
      property==SYMBOL_PROP_FILLING_MODE        ?  CMessage::Text(MSG_SYM_PROP_FILLING_MODE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetFillingModeFlagsDescription()
         )  :
      property==SYMBOL_PROP_ORDER_MODE          ?  CMessage::Text(MSG_SYM_PROP_ORDER_MODE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetOrderModeFlagsDescription()
         )  :
      property==SYMBOL_PROP_ORDER_GTC_MODE      ?  CMessage::Text(MSG_SYM_PROP_ORDER_GTC_MODE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetOrderGTCModeDescription()
         )  :
      property==SYMBOL_PROP_OPTION_MODE         ?  CMessage::Text(MSG_SYM_PROP_OPTION_MODE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetOptionTypeDescription()
         )  :
      property==SYMBOL_PROP_OPTION_RIGHT        ?  CMessage::Text(MSG_SYM_PROP_OPTION_RIGHT)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetOptionRightDescription()
         )  :
      property==SYMBOL_PROP_BACKGROUND_COLOR    ?  CMessage::Text(MSG_SYM_PROP_BACKGROUND_COLOR)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         #ifdef __MQL5__
         (this.GetProperty(property)==CLR_MW_DEFAULT || this.GetProperty(property)==CLR_NONE ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": "+::ColorToString((color)this.GetProperty(property),true))
         #else ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SUBSCRIPTION_DELAY  ?  CMessage::Text(MSG_SYM_PROP_SUBSCRIPTION_DELAY)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         #ifdef __MQL5__
         (::TerminalInfoInteger(TERMINAL_BUILD)<3245 ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MT5_LESS_3245)+")" : ": "+(string)this.GetProperty(property))
         #else ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      ""
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of the symbol real property               |
 //+------------------------------------------------------------------+
 string CSymbol::GetPropertyDescription(ENUM_SYMBOL_PROP_DOUBLE property)
  {
   int dg=this.Digits();
   int dgl=this.DigitsLot();
   int dgc=this.DigitsCurrency();
   return
     (
      property==SYMBOL_PROP_BID              ?  CMessage::Text(MSG_LIB_PROP_BID)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property)==0 ? "("+CMessage::Text(MSG_LIB_SYS_NO_TICKS_YET)+")" : ::DoubleToString(this.GetProperty(property),dg))
         )  :
      property==SYMBOL_PROP_BIDHIGH          ?  CMessage::Text(MSG_SYM_PROP_BIDHIGH)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==SYMBOL_PROP_BIDLOW           ?  CMessage::Text(MSG_SYM_PROP_BIDLOW)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==SYMBOL_PROP_ASK              ?  CMessage::Text(MSG_LIB_PROP_ASK)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property)==0 ? "("+CMessage::Text(MSG_LIB_SYS_NO_TICKS_YET)+")" : ::DoubleToString(this.GetProperty(property),dg))
         )  :
      property==SYMBOL_PROP_ASKHIGH          ?  CMessage::Text(MSG_SYM_PROP_ASKHIGH)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dg) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_ASKLOW           ?  CMessage::Text(MSG_SYM_PROP_ASKLOW)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dg) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_LAST             ?  CMessage::Text(MSG_LIB_PROP_LAST)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dg) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_LASTHIGH         ?  CMessage::Text(MSG_SYM_PROP_LASTHIGH)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dg) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_LASTLOW          ?  CMessage::Text(MSG_SYM_PROP_LASTLOW)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dg) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_VOLUME_REAL      ?  CMessage::Text(MSG_SYM_PROP_VOLUME_REAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dgl) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_VOLUMEHIGH_REAL  ?  CMessage::Text(MSG_SYM_PROP_VOLUMEHIGH_REAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dgl) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_VOLUMELOW_REAL   ?  CMessage::Text(MSG_SYM_PROP_VOLUMELOW_REAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dgl) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_OPTION_STRIKE    ?  CMessage::Text(MSG_SYM_PROP_OPTION_STRIKE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dg) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_POINT            ?  CMessage::Text(MSG_SYM_PROP_POINT)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==SYMBOL_PROP_TRADE_TICK_VALUE ?  CMessage::Text(MSG_SYM_PROP_TRADE_TICK_VALUE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dgc)
         )  :
      property==SYMBOL_PROP_TRADE_TICK_VALUE_PROFIT   ?  CMessage::Text(MSG_SYM_PROP_TRADE_TICK_VALUE_PROFIT)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dgc) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_TRADE_TICK_VALUE_LOSS  ?  CMessage::Text(MSG_SYM_PROP_TRADE_TICK_VALUE_LOSS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dgc) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_TRADE_TICK_SIZE  ?  CMessage::Text(MSG_SYM_PROP_TRADE_TICK_SIZE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==SYMBOL_PROP_TRADE_CONTRACT_SIZE ?  CMessage::Text(MSG_SYM_PROP_TRADE_CONTRACT_SIZE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dgc)
         )  :
      property==SYMBOL_PROP_TRADE_ACCRUED_INTEREST ?  CMessage::Text(MSG_SYM_PROP_TRADE_ACCRUED_INTEREST)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dgc) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_TRADE_FACE_VALUE ?  CMessage::Text(MSG_SYM_PROP_TRADE_FACE_VALUE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dgc) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_TRADE_LIQUIDITY_RATE   ?  CMessage::Text(MSG_SYM_PROP_TRADE_LIQUIDITY_RATE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),2) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_VOLUME_MIN       ?  CMessage::Text(MSG_SYM_PROP_VOLUME_MIN)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dgl)
         )  :
      property==SYMBOL_PROP_VOLUME_MAX       ?  CMessage::Text(MSG_SYM_PROP_VOLUME_MAX)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dgl)
         )  :
      property==SYMBOL_PROP_VOLUME_STEP      ?  CMessage::Text(MSG_SYM_PROP_VOLUME_STEP)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dgl)
         )  :
      property==SYMBOL_PROP_VOLUME_LIMIT     ?  CMessage::Text(MSG_SYM_PROP_VOLUME_LIMIT)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dgl) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SWAP_LONG        ?  CMessage::Text(MSG_SYM_PROP_SWAP_LONG)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dgc)
         )  :
      property==SYMBOL_PROP_SWAP_SHORT       ?  CMessage::Text(MSG_SYM_PROP_SWAP_SHORT)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dgc)
         )  :
      property==SYMBOL_PROP_MARGIN_INITIAL   ?  CMessage::Text(MSG_SYM_PROP_MARGIN_INITIAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),8)
         )  :
      property==SYMBOL_PROP_MARGIN_MAINTENANCE  ?  CMessage::Text(MSG_SYM_PROP_MARGIN_MAINTENANCE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),8)
         )  :
     //--- Initial margin requirement of a Long position
      property==SYMBOL_PROP_MARGIN_LONG_INITIAL          ?  CMessage::Text(MSG_SYM_PROP_MARGIN_LONG_INITIAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
     //--- Initial margin requirement of a Short position
      property==SYMBOL_PROP_MARGIN_SHORT_INITIAL     ?  CMessage::Text(MSG_SYM_PROP_MARGIN_SHORT_INITIAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
     //--- Maintenance margin requirement of a Long position
      property==SYMBOL_PROP_MARGIN_LONG_MAINTENANCE          ?  CMessage::Text(MSG_SYM_PROP_MARGIN_LONG_MAINTENANCE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
     //--- Maintenance margin requirement of a Short position
      property==SYMBOL_PROP_MARGIN_SHORT_MAINTENANCE          ?  CMessage::Text(MSG_SYM_PROP_MARGIN_SHORT_MAINTENANCE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
     //--- Initial margin requirements of Long orders
      property==SYMBOL_PROP_MARGIN_BUY_STOP_INITIAL      ?  CMessage::Text(MSG_SYM_PROP_MARGIN_BUY_STOP_INITIAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_MARGIN_BUY_LIMIT_INITIAL     ?  CMessage::Text(MSG_SYM_PROP_MARGIN_BUY_LIMIT_INITIAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_INITIAL ?  CMessage::Text(MSG_SYM_PROP_MARGIN_BUY_STOPLIMIT_INITIAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
     //--- Initial margin requirements of Short orders
      property==SYMBOL_PROP_MARGIN_SELL_STOP_INITIAL      ?  CMessage::Text(MSG_SYM_PROP_MARGIN_SELL_STOP_INITIAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_MARGIN_SELL_LIMIT_INITIAL     ?  CMessage::Text(MSG_SYM_PROP_MARGIN_SELL_LIMIT_INITIAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_INITIAL ?  CMessage::Text(MSG_SYM_PROP_MARGIN_SELL_STOPLIMIT_INITIAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
     //--- Maintenance margin requirements of Long orders
      property==SYMBOL_PROP_MARGIN_BUY_STOP_MAINTENANCE      ?  CMessage::Text(MSG_SYM_PROP_MARGIN_BUY_STOP_MAINTENANCE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_MARGIN_BUY_LIMIT_MAINTENANCE     ?  CMessage::Text(MSG_SYM_PROP_MARGIN_BUY_LIMIT_MAINTENANCE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_MAINTENANCE ?  CMessage::Text(MSG_SYM_PROP_MARGIN_BUY_STOPLIMIT_MAINTENANCE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
     //--- Maintenance margin requirements of Short orders
      property==SYMBOL_PROP_MARGIN_SELL_STOP_MAINTENANCE      ?  CMessage::Text(MSG_SYM_PROP_MARGIN_SELL_STOP_MAINTENANCE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_MARGIN_SELL_LIMIT_MAINTENANCE     ?  CMessage::Text(MSG_SYM_PROP_MARGIN_SELL_LIMIT_MAINTENANCE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_MAINTENANCE ?  CMessage::Text(MSG_SYM_PROP_MARGIN_SELL_STOPLIMIT_MAINTENANCE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ 
          #ifdef __MQL5__ (this.GetProperty(property)==0  ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SET)+")" : (::DoubleToString(this.GetProperty(property),8)))
          #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
     //---
      property==SYMBOL_PROP_SESSION_VOLUME   ?  CMessage::Text(MSG_SYM_PROP_SESSION_VOLUME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dgl) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SESSION_TURNOVER ?  CMessage::Text(MSG_SYM_PROP_SESSION_TURNOVER)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dgc) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SESSION_INTEREST ?  CMessage::Text(MSG_SYM_PROP_SESSION_INTEREST)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dgl) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SESSION_BUY_ORDERS_VOLUME ?  CMessage::Text(MSG_SYM_PROP_SESSION_BUY_ORDERS_VOLUME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dgl) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SESSION_SELL_ORDERS_VOLUME   ?  CMessage::Text(MSG_SYM_PROP_SESSION_SELL_ORDERS_VOLUME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dgl) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SESSION_OPEN     ?  CMessage::Text(MSG_SYM_PROP_SESSION_OPEN)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dg) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SESSION_CLOSE    ?  CMessage::Text(MSG_SYM_PROP_SESSION_CLOSE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dg) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SESSION_AW       ?  CMessage::Text(MSG_SYM_PROP_SESSION_AW)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dg) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SESSION_PRICE_SETTLEMENT  ?  CMessage::Text(MSG_SYM_PROP_SESSION_PRICE_SETTLEMENT)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dg) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SESSION_PRICE_LIMIT_MIN   ?  CMessage::Text(MSG_SYM_PROP_SESSION_PRICE_LIMIT_MIN)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dg) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SESSION_PRICE_LIMIT_MAX   ?  CMessage::Text(MSG_SYM_PROP_SESSION_PRICE_LIMIT_MAX)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ #ifdef __MQL5__::DoubleToString(this.GetProperty(property),dg) #else CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_MARGIN_HEDGED    ?  CMessage::Text(MSG_SYM_PROP_MARGIN_HEDGED)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dgc)
         )  :
      property==SYMBOL_PROP_PRICE_CHANGE     ?  CMessage::Text(MSG_SYM_PROP_PRICE_CHANGE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==SYMBOL_PROP_PRICE_VOLATILITY ?  CMessage::Text(MSG_SYM_PROP_PRICE_VOLATILITY)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==SYMBOL_PROP_PRICE_THEORETICAL ?  CMessage::Text(MSG_SYM_PROP_PRICE_THEORETICAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==SYMBOL_PROP_PRICE_DELTA      ?  CMessage::Text(MSG_SYM_PROP_PRICE_DELTA)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==SYMBOL_PROP_PRICE_THETA      ?  CMessage::Text(MSG_SYM_PROP_PRICE_THETA)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==SYMBOL_PROP_PRICE_GAMMA      ?  CMessage::Text(MSG_SYM_PROP_PRICE_GAMMA)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==SYMBOL_PROP_PRICE_VEGA       ?  CMessage::Text(MSG_SYM_PROP_PRICE_VEGA)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==SYMBOL_PROP_PRICE_RHO        ?  CMessage::Text(MSG_SYM_PROP_PRICE_RHO)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==SYMBOL_PROP_PRICE_OMEGA      ?  CMessage::Text(MSG_SYM_PROP_PRICE_OMEGA)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==SYMBOL_PROP_PRICE_SENSITIVITY   ?  CMessage::Text(MSG_SYM_PROP_PRICE_SENSITIVITY)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==SYMBOL_PROP_SWAP_SUNDAY      ?  CMessage::Text(MSG_SYM_PROP_SWAP_SUNDAY)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         #ifdef __MQL5__
         (::TerminalInfoInteger(TERMINAL_BUILD)<3260 ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MT5_LESS_3260)+")" : 
                                                        ": "+this.GetSwapRatioDescription(SUNDAY))
         #else ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SWAP_MONDAY      ?  CMessage::Text(MSG_SYM_PROP_SWAP_MONDAY)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         #ifdef __MQL5__
         (::TerminalInfoInteger(TERMINAL_BUILD)<3260 ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MT5_LESS_3260)+")" : 
                                                        ": "+this.GetSwapRatioDescription(MONDAY))
         #else ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SWAP_TUESDAY     ?  CMessage::Text(MSG_SYM_PROP_SWAP_TUESDAY)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         #ifdef __MQL5__
         (::TerminalInfoInteger(TERMINAL_BUILD)<3260 ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MT5_LESS_3260)+")" : 
                                                        ": "+this.GetSwapRatioDescription(TUESDAY))
         #else ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SWAP_WEDNESDAY   ?  CMessage::Text(MSG_SYM_PROP_SWAP_WEDNESDAY)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         #ifdef __MQL5__
         (::TerminalInfoInteger(TERMINAL_BUILD)<3260 ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MT5_LESS_3260)+")" : 
                                                        ": "+this.GetSwapRatioDescription(WEDNESDAY))
         #else ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SWAP_THURSDAY    ?  CMessage::Text(MSG_SYM_PROP_SWAP_THURSDAY)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         #ifdef __MQL5__
         (::TerminalInfoInteger(TERMINAL_BUILD)<3260 ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MT5_LESS_3260)+")" : 
                                                        ": "+this.GetSwapRatioDescription(THURSDAY))
         #else ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SWAP_FRIDAY      ?  CMessage::Text(MSG_SYM_PROP_SWAP_FRIDAY)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         #ifdef __MQL5__
         (::TerminalInfoInteger(TERMINAL_BUILD)<3260 ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MT5_LESS_3260)+")" : 
                                                        ": "+this.GetSwapRatioDescription(FRIDAY))
         #else ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      property==SYMBOL_PROP_SWAP_SATURDAY    ?  CMessage::Text(MSG_SYM_PROP_SWAP_SATURDAY)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         #ifdef __MQL5__
         (::TerminalInfoInteger(TERMINAL_BUILD)<3260 ?  ": ("+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MT5_LESS_3260)+")" : 
                                                        ": "+this.GetSwapRatioDescription(SATURDAY))
         #else ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #endif 
         )  :
      ""
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of the symbol string property             |
 //+------------------------------------------------------------------+
 string CSymbol::GetPropertyDescription(ENUM_SYMBOL_PROP_STRING property)
  {
   return
     (
      property==SYMBOL_PROP_NAME             ?  CMessage::Text(MSG_SYM_PROP_NAME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+this.GetProperty(property)
         )  :
      property==SYMBOL_PROP_BASIS            ?  CMessage::Text(MSG_SYM_PROP_BASIS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_COUNTRY          ?  CMessage::Text(MSG_SYM_PROP_COUNTRY)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_SECTOR_NAME      ?  CMessage::Text(MSG_SYM_PROP_SECTOR_NAME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_INDUSTRY_NAME    ?  CMessage::Text(MSG_SYM_PROP_INDUSTRY_NAME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_CURRENCY_BASE    ?  CMessage::Text(MSG_SYM_PROP_CURRENCY_BASE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_CURRENCY_PROFIT  ?  CMessage::Text(MSG_SYM_PROP_CURRENCY_PROFIT)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_CURRENCY_MARGIN  ?  CMessage::Text(MSG_SYM_PROP_CURRENCY_MARGIN)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_BANK             ?  CMessage::Text(MSG_SYM_PROP_BANK)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_DESCRIPTION      ?  CMessage::Text(MSG_SYM_PROP_DESCRIPTION)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_FORMULA          ?  CMessage::Text(MSG_SYM_PROP_FORMULA)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_ISIN             ?  CMessage::Text(MSG_SYM_PROP_ISIN)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_PAGE             ?  CMessage::Text(MSG_SYM_PROP_PAGE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_PATH             ?  CMessage::Text(MSG_SYM_PROP_PATH)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_CATEGORY         ?  CMessage::Text(MSG_SYM_PROP_CAYEGORY)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      property==SYMBOL_PROP_EXCHANGE         ?  CMessage::Text(MSG_SYM_PROP_EXCHANGE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
         (this.GetProperty(property)=="" || this.GetProperty(property)==NULL  ?  ": ("+CMessage::Text(MSG_LIB_PROP_EMPTY)+")" : ": \""+this.GetProperty(property)+"\"")
         )  :
      ""
     );
  }
 //+---------------------------------------------------------------------+
 //| Return the description of a session duration in the hh:mm:ss format |
 //+---------------------------------------------------------------------+
 string CSymbol::SessionDurationDescription(const ulong duration_sec) const
  {
   int sec=this.SessionSeconds(duration_sec);
   int min=this.SessionMinutes(duration_sec);
   int hour=this.SessionHours(duration_sec);
   return ::IntegerToString(hour,2,'0')+":"+::IntegerToString(min,2,'0')+":"+::IntegerToString(sec,2,'0');
  }
 //+------------------------------------------------------------------+
 //| Return the status description                                    |
 //+------------------------------------------------------------------+
 string CSymbol::GetStatusDescription() const
  {
   return
     (
      this.Status()==SYMBOL_STATUS_FX           ? CMessage::Text(MSG_SYM_STATUS_FX)          :
      this.Status()==SYMBOL_STATUS_FX_MAJOR     ? CMessage::Text(MSG_SYM_STATUS_FX_MAJOR)    :
      this.Status()==SYMBOL_STATUS_FX_MINOR     ? CMessage::Text(MSG_SYM_STATUS_FX_MINOR)    :
      this.Status()==SYMBOL_STATUS_FX_EXOTIC    ? CMessage::Text(MSG_SYM_STATUS_FX_EXOTIC)   :
      this.Status()==SYMBOL_STATUS_FX_RUB       ? CMessage::Text(MSG_SYM_STATUS_FX_RUB)      :
      this.Status()==SYMBOL_STATUS_METAL        ? CMessage::Text(MSG_SYM_STATUS_METAL)       :
      this.Status()==SYMBOL_STATUS_INDEX        ? CMessage::Text(MSG_SYM_STATUS_INDEX)       :
      this.Status()==SYMBOL_STATUS_INDICATIVE   ? CMessage::Text(MSG_SYM_STATUS_INDICATIVE)  :
      this.Status()==SYMBOL_STATUS_CRYPTO       ? CMessage::Text(MSG_SYM_STATUS_CRYPTO)      :
      this.Status()==SYMBOL_STATUS_COMMODITY    ? CMessage::Text(MSG_SYM_STATUS_COMMODITY)   :
      this.Status()==SYMBOL_STATUS_EXCHANGE     ? CMessage::Text(MSG_SYM_STATUS_EXCHANGE)    : 
      this.Status()==SYMBOL_STATUS_FUTURES      ? CMessage::Text(MSG_SYM_STATUS_FUTURES)     : 
      this.Status()==SYMBOL_STATUS_CFD          ? CMessage::Text(MSG_SYM_STATUS_CFD)         : 
      this.Status()==SYMBOL_STATUS_STOCKS       ? CMessage::Text(MSG_SYM_STATUS__STOCKS)     : 
      this.Status()==SYMBOL_STATUS_BONDS        ? CMessage::Text(MSG_SYM_STATUS_BONDS)       : 
      this.Status()==SYMBOL_STATUS_OPTION       ? CMessage::Text(MSG_SYM_STATUS_OPTION)      : 
      this.Status()==SYMBOL_STATUS_COLLATERAL   ? CMessage::Text(MSG_SYM_STATUS_COLLATERAL)  : 
      this.Status()==SYMBOL_STATUS_CUSTOM       ? CMessage::Text(MSG_SYM_STATUS_CUSTOM)      :
      this.Status()==SYMBOL_STATUS_COMMON       ? CMessage::Text(MSG_SYM_STATUS_COMMON)      :
      ::EnumToString((ENUM_SYMBOL_STATUS)this.Status())
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of the price type for constructing bars   |
 //+------------------------------------------------------------------+
 string CSymbol::GetChartModeDescription(void) const
  {
   return
     (
      this.ChartMode()==SYMBOL_CHART_MODE_BID ? CMessage::Text(MSG_SYM_CHART_MODE_BID) : 
      CMessage::Text(MSG_SYM_CHART_MODE_LAST)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of the margin calculation method          |
 //+------------------------------------------------------------------+
 string CSymbol::GetCalcModeDescription(void) const
  {
   return
     (
      this.TradeCalcMode()==SYMBOL_CALC_MODE_FOREX                ? CMessage::Text(MSG_SYM_CALC_MODE_FOREX)                :
      this.TradeCalcMode()==SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE    ? CMessage::Text(MSG_SYM_CALC_MODE_FOREX_NO_LEVERAGE)    :
      this.TradeCalcMode()==SYMBOL_CALC_MODE_FUTURES              ? CMessage::Text(MSG_SYM_CALC_MODE_FUTURES)              :
      this.TradeCalcMode()==SYMBOL_CALC_MODE_CFD                  ? CMessage::Text(MSG_SYM_CALC_MODE_CFD)                  :
      this.TradeCalcMode()==SYMBOL_CALC_MODE_CFDINDEX             ? CMessage::Text(MSG_SYM_CALC_MODE_CFDINDEX)             :
      this.TradeCalcMode()==SYMBOL_CALC_MODE_CFDLEVERAGE          ? CMessage::Text(MSG_SYM_CALC_MODE_CFDLEVERAGE)          :
      this.TradeCalcMode()==SYMBOL_CALC_MODE_EXCH_STOCKS          ? CMessage::Text(MSG_SYM_CALC_MODE_EXCH_STOCKS)          :
      this.TradeCalcMode()==SYMBOL_CALC_MODE_EXCH_FUTURES         ? CMessage::Text(MSG_SYM_CALC_MODE_EXCH_FUTURES)         :
      this.TradeCalcMode()==SYMBOL_CALC_MODE_EXCH_FUTURES_FORTS   ? CMessage::Text(MSG_SYM_CALC_MODE_EXCH_FUTURES_FORTS)   :
      this.TradeCalcMode()==SYMBOL_CALC_MODE_EXCH_BONDS           ? CMessage::Text(MSG_SYM_CALC_MODE_EXCH_BONDS)           :
      this.TradeCalcMode()==SYMBOL_CALC_MODE_EXCH_STOCKS_MOEX     ? CMessage::Text(MSG_SYM_CALC_MODE_EXCH_STOCKS_MOEX)     :
      this.TradeCalcMode()==SYMBOL_CALC_MODE_EXCH_BONDS_MOEX      ? CMessage::Text(MSG_SYM_CALC_MODE_EXCH_BONDS_MOEX)      :
      this.TradeCalcMode()==SYMBOL_CALC_MODE_SERV_COLLATERAL      ? CMessage::Text(MSG_SYM_CALC_MODE_SERV_COLLATERAL)      :
      CMessage::Text(MSG_SYM_MODE_UNKNOWN)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of a symbol trading mode                  |
 //+------------------------------------------------------------------+
 string CSymbol::GetTradeModeDescription(void) const
  {
   return
     (
      this.TradeMode()==SYMBOL_TRADE_MODE_DISABLED    ?  CMessage::Text(MSG_SYM_TRADE_MODE_DISABLED)  :
      this.TradeMode()==SYMBOL_TRADE_MODE_LONGONLY    ?  CMessage::Text(MSG_SYM_TRADE_MODE_LONGONLY)  :
      this.TradeMode()==SYMBOL_TRADE_MODE_SHORTONLY   ?  CMessage::Text(MSG_SYM_TRADE_MODE_SHORTONLY) :
      this.TradeMode()==SYMBOL_TRADE_MODE_CLOSEONLY   ?  CMessage::Text(MSG_SYM_TRADE_MODE_CLOSEONLY) :
      this.TradeMode()==SYMBOL_TRADE_MODE_FULL        ?  CMessage::Text(MSG_SYM_TRADE_MODE_FULL)      :
      CMessage::Text(MSG_SYM_MODE_UNKNOWN)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of a symbol trade execution mode          |
 //+------------------------------------------------------------------+
 string CSymbol::GetTradeExecDescription(void) const
  {
   return
     (
      this.TradeExecutionMode()==SYMBOL_TRADE_EXECUTION_REQUEST   ? CMessage::Text(MSG_SYM_TRADE_EXECUTION_REQUEST)  :
      this.TradeExecutionMode()==SYMBOL_TRADE_EXECUTION_INSTANT   ? CMessage::Text(MSG_SYM_TRADE_EXECUTION_INSTANT)  :
      this.TradeExecutionMode()==SYMBOL_TRADE_EXECUTION_MARKET    ? CMessage::Text(MSG_SYM_TRADE_EXECUTION_MARKET)   :
      this.TradeExecutionMode()==SYMBOL_TRADE_EXECUTION_EXCHANGE  ? CMessage::Text(MSG_SYM_TRADE_EXECUTION_EXCHANGE) :
      CMessage::Text(MSG_SYM_MODE_UNKNOWN)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of a swap calculation model               |
 //+------------------------------------------------------------------+
 string CSymbol::GetSwapModeDescription(void) const
  {
   return
     (
      this.SwapMode()==SYMBOL_SWAP_MODE_DISABLED         ?  CMessage::Text(MSG_SYM_SWAP_MODE_DISABLED)         :
      this.SwapMode()==SYMBOL_SWAP_MODE_POINTS           ?  CMessage::Text(MSG_SYM_SWAP_MODE_POINTS)           :
      this.SwapMode()==SYMBOL_SWAP_MODE_CURRENCY_SYMBOL  ?  CMessage::Text(MSG_SYM_SWAP_MODE_CURRENCY_SYMBOL)  :
      this.SwapMode()==SYMBOL_SWAP_MODE_CURRENCY_MARGIN  ?  CMessage::Text(MSG_SYM_SWAP_MODE_CURRENCY_MARGIN)  :
      this.SwapMode()==SYMBOL_SWAP_MODE_CURRENCY_DEPOSIT ?  CMessage::Text(MSG_SYM_SWAP_MODE_CURRENCY_DEPOSIT) :
      this.SwapMode()==SYMBOL_SWAP_MODE_CURRENCY_PROFIT  ?  CMessage::Text(MSG_SYM_SWAP_MODE_CURRENCY_PROFIT)  :
      this.SwapMode()==SYMBOL_SWAP_MODE_INTEREST_CURRENT ?  CMessage::Text(MSG_SYM_SWAP_MODE_INTEREST_CURRENT) :
      this.SwapMode()==SYMBOL_SWAP_MODE_INTEREST_OPEN    ?  CMessage::Text(MSG_SYM_SWAP_MODE_INTEREST_OPEN)    :
      this.SwapMode()==SYMBOL_SWAP_MODE_REOPEN_CURRENT   ?  CMessage::Text(MSG_SYM_SWAP_MODE_REOPEN_CURRENT)   :
      this.SwapMode()==SYMBOL_SWAP_MODE_REOPEN_BID       ?  CMessage::Text(MSG_SYM_SWAP_MODE_REOPEN_BID)       :
      CMessage::Text(MSG_SYM_MODE_UNKNOWN)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of StopLoss and TakeProfit order lifetime |
 //+------------------------------------------------------------------+
 string CSymbol::GetOrderGTCModeDescription(void) const
  {
   return
     (this.IsExpirationModeGTC() ? 
      (
       this.OrderModeGTC()==SYMBOL_ORDERS_GTC                     ? CMessage::Text(MSG_SYM_ORDERS_GTC)                     :
       this.OrderModeGTC()==SYMBOL_ORDERS_DAILY                   ? CMessage::Text(MSG_SYM_ORDERS_DAILY)                   :
       this.OrderModeGTC()==SYMBOL_ORDERS_DAILY_EXCLUDING_STOPS   ? CMessage::Text(MSG_SYM_ORDERS_DAILY_EXCLUDING_STOPS)   :
       CMessage::Text(MSG_SYM_MODE_UNKNOWN)
      )                                                           :
      CMessage::Text(MSG_LIB_PROP_AS_IN_ORDER)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the option type description                               |
 //+------------------------------------------------------------------+
 string CSymbol::GetOptionTypeDescription(void) const
  {
   return
     (
      #ifdef __MQL4__ CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #else 
      this.OptionMode()==SYMBOL_OPTION_MODE_EUROPEAN  ?  CMessage::Text(MSG_SYM_OPTION_MODE_EUROPEAN) :
      this.OptionMode()==SYMBOL_OPTION_MODE_AMERICAN  ?  CMessage::Text(MSG_SYM_OPTION_MODE_AMERICAN) :
      CMessage::Text(MSG_SYM_OPTION_MODE_UNKNOWN)
      #endif 
     );
  }
 //+------------------------------------------------------------------+
 //| Return the option right description                              |
 //+------------------------------------------------------------------+
 string CSymbol::GetOptionRightDescription(void) const
  {
   return
     (
      #ifdef __MQL4__ CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED_MQL4) #else 
      this.OptionRight()==SYMBOL_OPTION_RIGHT_CALL ? 
      CMessage::Text(MSG_SYM_OPTION_RIGHT_CALL)  : 
      CMessage::Text(MSG_SYM_OPTION_RIGHT_PUT)
      #endif 
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of the flags of allowed order types       |
 //+------------------------------------------------------------------+
 string CSymbol::GetOrderModeFlagsDescription(void) const
  {
   string first=#ifdef __MQL5__ "\n - " #else ""   #endif ;
   string next= #ifdef __MQL5__ "\n - " #else "; " #endif ;
   return
     (
      first+this.GetMarketOrdersAllowedDescription()+
      next+this.GetLimitOrdersAllowedDescription()+
      next+this.GetStopOrdersAllowedDescription()+
      next+this.GetStopLimitOrdersAllowedDescription()+
      next+this.GetStopLossOrdersAllowedDescription()+
      next+this.GetTakeProfitOrdersAllowedDescription()+
      next+this.GetCloseByOrdersAllowedDescription()
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of the flags of allowed filling types     |
 //+------------------------------------------------------------------+
 string CSymbol::GetFillingModeFlagsDescription(void) const
  {
   string first=#ifdef __MQL5__ "\n - " #else ""   #endif ;
   string next= #ifdef __MQL5__ "\n - " #else "; " #endif ;
   return
     (
      first+CMessage::Text(MSG_SYM_FILLING_MODE_RETURN_YES)+
      next+this.GetFillingModeFOKAllowedDescrioption()+
      next+this.GetFillingModeIOCAllowedDescrioption()
     );
  }
 //+------------------------------------------------------------------------+
 //| Return the description of the flags of allowed order expiration modes  |
 //+------------------------------------------------------------------------+
 string CSymbol::GetExpirationModeFlagsDescription(void) const
  {
   string first=#ifdef __MQL5__ "\n - " #else ""   #endif ;
   string next= #ifdef __MQL5__ "\n - " #else "; " #endif ;
   return
     (
      first+this.GetExpirationModeGTCDescription()+
      next+this.GetExpirationModeDAYDescription()+
      next+this.GetExpirationModeSpecifiedDescription()+
      next+this.GetExpirationModeSpecDayDescription()
     );
  }
 //+------------------------------------------------------------------+
 //| Return the economy sector description                            |
 //+------------------------------------------------------------------+
 string CSymbol::GetSectorDescription(void) const
  {
   switch(this.Sector())
     {
      case SECTOR_BASIC_MATERIALS         : return CMessage::Text(MSG_SYM_SECTOR_BASIC_MATERIALS);
      case SECTOR_COMMUNICATION_SERVICES  : return CMessage::Text(MSG_SYM_SECTOR_COMMUNICATION_SERVICES);
      case SECTOR_CONSUMER_CYCLICAL       : return CMessage::Text(MSG_SYM_SECTOR_CONSUMER_CYCLICAL);
      case SECTOR_CONSUMER_DEFENSIVE      : return CMessage::Text(MSG_SYM_SECTOR_CONSUMER_DEFENSIVE);
      case SECTOR_CURRENCY                : return CMessage::Text(MSG_SYM_SECTOR_CURRENCY);
      case SECTOR_CURRENCY_CRYPTO         : return CMessage::Text(MSG_SYM_SECTOR_CURRENCY_CRYPTO);
      case SECTOR_ENERGY                  : return CMessage::Text(MSG_SYM_SECTOR_ENERGY);
      case SECTOR_FINANCIAL               : return CMessage::Text(MSG_SYM_SECTOR_FINANCIAL);
      case SECTOR_HEALTHCARE              : return CMessage::Text(MSG_SYM_SECTOR_HEALTHCARE);
      case SECTOR_INDUSTRIALS             : return CMessage::Text(MSG_SYM_SECTOR_INDUSTRIALS);
      case SECTOR_REAL_ESTATE             : return CMessage::Text(MSG_SYM_SECTOR_REAL_ESTATE);
      case SECTOR_TECHNOLOGY              : return CMessage::Text(MSG_SYM_SECTOR_TECHNOLOGY);
      case SECTOR_UTILITIES               : return CMessage::Text(MSG_SYM_SECTOR_UTILITIES);
      case SECTOR_INDEXES                 : return CMessage::Text(MSG_SYM_SECTOR_INDEXES);
      case SECTOR_COMMODITIES             : return CMessage::Text(MSG_SYM_SECTOR_COMMODITIES);
      default                             : return CMessage::Text(MSG_SYM_SECTOR_UNDEFINED);
     }
  }
 //+------------------------------------------------------------------+
 //| Return the industry or economy branch description                |
 //+------------------------------------------------------------------+
 string CSymbol::GetIndustryDescription(void) const
  {
   switch(this.Industry())
     {
      case INDUSTRY_AGRICULTURAL_INPUTS            : return CMessage::Text(MSG_SYM_INDUSTRY_AGRICULTURAL_INPUTS);
      case INDUSTRY_ALUMINIUM                      : return CMessage::Text(MSG_SYM_INDUSTRY_ALUMINIUM);
      case INDUSTRY_BUILDING_MATERIALS             : return CMessage::Text(MSG_SYM_INDUSTRY_BUILDING_MATERIALS);
      case INDUSTRY_CHEMICALS                      : return CMessage::Text(MSG_SYM_INDUSTRY_CHEMICALS);
      case INDUSTRY_COKING_COAL                    : return CMessage::Text(MSG_SYM_INDUSTRY_COKING_COAL);
      case INDUSTRY_COPPER                         : return CMessage::Text(MSG_SYM_INDUSTRY_COPPER);
      case INDUSTRY_GOLD                           : return CMessage::Text(MSG_SYM_INDUSTRY_GOLD);
      case INDUSTRY_LUMBER_WOOD                    : return CMessage::Text(MSG_SYM_INDUSTRY_LUMBER_WOOD);
      case INDUSTRY_INDUSTRIAL_METALS              : return CMessage::Text(MSG_SYM_INDUSTRY_INDUSTRIAL_METALS);
      case INDUSTRY_PRECIOUS_METALS                : return CMessage::Text(MSG_SYM_INDUSTRY_PRECIOUS_METALS);
      case INDUSTRY_PAPER                          : return CMessage::Text(MSG_SYM_INDUSTRY_PAPER);
      case INDUSTRY_SILVER                         : return CMessage::Text(MSG_SYM_INDUSTRY_SILVER);
      case INDUSTRY_SPECIALTY_CHEMICALS            : return CMessage::Text(MSG_SYM_INDUSTRY_SPECIALTY_CHEMICALS);
      case INDUSTRY_STEEL                          : return CMessage::Text(MSG_SYM_INDUSTRY_STEEL);
      case INDUSTRY_ADVERTISING                    : return CMessage::Text(MSG_SYM_INDUSTRY_ADVERTISING);
      case INDUSTRY_BROADCASTING                   : return CMessage::Text(MSG_SYM_INDUSTRY_BROADCASTING);
      case INDUSTRY_GAMING_MULTIMEDIA              : return CMessage::Text(MSG_SYM_INDUSTRY_GAMING_MULTIMEDIA);
      case INDUSTRY_ENTERTAINMENT                  : return CMessage::Text(MSG_SYM_INDUSTRY_ENTERTAINMENT);
      case INDUSTRY_INTERNET_CONTENT               : return CMessage::Text(MSG_SYM_INDUSTRY_INTERNET_CONTENT);
      case INDUSTRY_PUBLISHING                     : return CMessage::Text(MSG_SYM_INDUSTRY_PUBLISHING);
      case INDUSTRY_TELECOM                        : return CMessage::Text(MSG_SYM_INDUSTRY_TELECOM);
      case INDUSTRY_APPAREL_MANUFACTURING          : return CMessage::Text(MSG_SYM_INDUSTRY_APPAREL_MANUFACTURING);
      case INDUSTRY_APPAREL_RETAIL                 : return CMessage::Text(MSG_SYM_INDUSTRY_APPAREL_RETAIL);
      case INDUSTRY_AUTO_MANUFACTURERS             : return CMessage::Text(MSG_SYM_INDUSTRY_AUTO_MANUFACTURERS);
      case INDUSTRY_AUTO_PARTS                     : return CMessage::Text(MSG_SYM_INDUSTRY_AUTO_PARTS);
      case INDUSTRY_AUTO_DEALERSHIP                : return CMessage::Text(MSG_SYM_INDUSTRY_AUTO_DEALERSHIP);
      case INDUSTRY_DEPARTMENT_STORES              : return CMessage::Text(MSG_SYM_INDUSTRY_DEPARTMENT_STORES);
      case INDUSTRY_FOOTWEAR_ACCESSORIES           : return CMessage::Text(MSG_SYM_INDUSTRY_FOOTWEAR_ACCESSORIES);
      case INDUSTRY_FURNISHINGS                    : return CMessage::Text(MSG_SYM_INDUSTRY_FURNISHINGS);
      case INDUSTRY_GAMBLING                       : return CMessage::Text(MSG_SYM_INDUSTRY_GAMBLING);
      case INDUSTRY_HOME_IMPROV_RETAIL             : return CMessage::Text(MSG_SYM_INDUSTRY_HOME_IMPROV_RETAIL);
      case INDUSTRY_INTERNET_RETAIL                : return CMessage::Text(MSG_SYM_INDUSTRY_INTERNET_RETAIL);
      case INDUSTRY_LEISURE                        : return CMessage::Text(MSG_SYM_INDUSTRY_LEISURE);
      case INDUSTRY_LODGING                        : return CMessage::Text(MSG_SYM_INDUSTRY_LODGING);
      case INDUSTRY_LUXURY_GOODS                   : return CMessage::Text(MSG_SYM_INDUSTRY_LUXURY_GOODS);
      case INDUSTRY_PACKAGING_CONTAINERS           : return CMessage::Text(MSG_SYM_INDUSTRY_PACKAGING_CONTAINERS);
      case INDUSTRY_PERSONAL_SERVICES              : return CMessage::Text(MSG_SYM_INDUSTRY_PERSONAL_SERVICES);
      case INDUSTRY_RECREATIONAL_VEHICLES          : return CMessage::Text(MSG_SYM_INDUSTRY_RECREATIONAL_VEHICLES);
      case INDUSTRY_RESIDENT_CONSTRUCTION          : return CMessage::Text(MSG_SYM_INDUSTRY_RESIDENT_CONSTRUCTION);
      case INDUSTRY_RESORTS_CASINOS                : return CMessage::Text(MSG_SYM_INDUSTRY_RESORTS_CASINOS);
      case INDUSTRY_RESTAURANTS                    : return CMessage::Text(MSG_SYM_INDUSTRY_RESTAURANTS);
      case INDUSTRY_SPECIALTY_RETAIL               : return CMessage::Text(MSG_SYM_INDUSTRY_SPECIALTY_RETAIL);
      case INDUSTRY_TEXTILE_MANUFACTURING          : return CMessage::Text(MSG_SYM_INDUSTRY_TEXTILE_MANUFACTURING);
      case INDUSTRY_TRAVEL_SERVICES                : return CMessage::Text(MSG_SYM_INDUSTRY_TRAVEL_SERVICES);
      case INDUSTRY_BEVERAGES_BREWERS              : return CMessage::Text(MSG_SYM_INDUSTRY_BEVERAGES_BREWERS);
      case INDUSTRY_BEVERAGES_NON_ALCO             : return CMessage::Text(MSG_SYM_INDUSTRY_BEVERAGES_NON_ALCO);
      case INDUSTRY_BEVERAGES_WINERIES             : return CMessage::Text(MSG_SYM_INDUSTRY_BEVERAGES_WINERIES);
      case INDUSTRY_CONFECTIONERS                  : return CMessage::Text(MSG_SYM_INDUSTRY_CONFECTIONERS);
      case INDUSTRY_DISCOUNT_STORES                : return CMessage::Text(MSG_SYM_INDUSTRY_DISCOUNT_STORES);
      case INDUSTRY_EDUCATION_TRAINIG              : return CMessage::Text(MSG_SYM_INDUSTRY_EDUCATION_TRAINIG);
      case INDUSTRY_FARM_PRODUCTS                  : return CMessage::Text(MSG_SYM_INDUSTRY_FARM_PRODUCTS);
      case INDUSTRY_FOOD_DISTRIBUTION              : return CMessage::Text(MSG_SYM_INDUSTRY_FOOD_DISTRIBUTION);
      case INDUSTRY_GROCERY_STORES                 : return CMessage::Text(MSG_SYM_INDUSTRY_GROCERY_STORES);
      case INDUSTRY_HOUSEHOLD_PRODUCTS             : return CMessage::Text(MSG_SYM_INDUSTRY_HOUSEHOLD_PRODUCTS);
      case INDUSTRY_PACKAGED_FOODS                 : return CMessage::Text(MSG_SYM_INDUSTRY_PACKAGED_FOODS);
      case INDUSTRY_TOBACCO                        : return CMessage::Text(MSG_SYM_INDUSTRY_TOBACCO);
      case INDUSTRY_OIL_GAS_DRILLING               : return CMessage::Text(MSG_SYM_INDUSTRY_OIL_GAS_DRILLING);
      case INDUSTRY_OIL_GAS_EP                     : return CMessage::Text(MSG_SYM_INDUSTRY_OIL_GAS_EP);
      case INDUSTRY_OIL_GAS_EQUIPMENT              : return CMessage::Text(MSG_SYM_INDUSTRY_OIL_GAS_EQUIPMENT);
      case INDUSTRY_OIL_GAS_INTEGRATED             : return CMessage::Text(MSG_SYM_INDUSTRY_OIL_GAS_INTEGRATED);
      case INDUSTRY_OIL_GAS_MIDSTREAM              : return CMessage::Text(MSG_SYM_INDUSTRY_OIL_GAS_MIDSTREAM);
      case INDUSTRY_OIL_GAS_REFINING               : return CMessage::Text(MSG_SYM_INDUSTRY_OIL_GAS_REFINING);
      case INDUSTRY_THERMAL_COAL                   : return CMessage::Text(MSG_SYM_INDUSTRY_THERMAL_COAL);
      case INDUSTRY_URANIUM                        : return CMessage::Text(MSG_SYM_INDUSTRY_URANIUM);
      case INDUSTRY_EXCHANGE_TRADED_FUND           : return CMessage::Text(MSG_SYM_INDUSTRY_EXCHANGE_TRADED_FUND);
      case INDUSTRY_ASSETS_MANAGEMENT              : return CMessage::Text(MSG_SYM_INDUSTRY_ASSETS_MANAGEMENT);
      case INDUSTRY_BANKS_DIVERSIFIED              : return CMessage::Text(MSG_SYM_INDUSTRY_BANKS_DIVERSIFIED);
      case INDUSTRY_BANKS_REGIONAL                 : return CMessage::Text(MSG_SYM_INDUSTRY_BANKS_REGIONAL);
      case INDUSTRY_CAPITAL_MARKETS                : return CMessage::Text(MSG_SYM_INDUSTRY_CAPITAL_MARKETS);
      case INDUSTRY_CLOSE_END_FUND_DEBT            : return CMessage::Text(MSG_SYM_INDUSTRY_CLOSE_END_FUND_DEBT);
      case INDUSTRY_CLOSE_END_FUND_EQUITY          : return CMessage::Text(MSG_SYM_INDUSTRY_CLOSE_END_FUND_EQUITY);
      case INDUSTRY_CLOSE_END_FUND_FOREIGN         : return CMessage::Text(MSG_SYM_INDUSTRY_CLOSE_END_FUND_FOREIGN);
      case INDUSTRY_CREDIT_SERVICES                : return CMessage::Text(MSG_SYM_INDUSTRY_CREDIT_SERVICES);
      case INDUSTRY_FINANCIAL_CONGLOMERATE         : return CMessage::Text(MSG_SYM_INDUSTRY_FINANCIAL_CONGLOMERATE);
      case INDUSTRY_FINANCIAL_DATA_EXCHANGE        : return CMessage::Text(MSG_SYM_INDUSTRY_FINANCIAL_DATA_EXCHANGE);
      case INDUSTRY_INSURANCE_BROKERS              : return CMessage::Text(MSG_SYM_INDUSTRY_INSURANCE_BROKERS);
      case INDUSTRY_INSURANCE_DIVERSIFIED          : return CMessage::Text(MSG_SYM_INDUSTRY_INSURANCE_DIVERSIFIED);
      case INDUSTRY_INSURANCE_LIFE                 : return CMessage::Text(MSG_SYM_INDUSTRY_INSURANCE_LIFE);
      case INDUSTRY_INSURANCE_PROPERTY             : return CMessage::Text(MSG_SYM_INDUSTRY_INSURANCE_PROPERTY);
      case INDUSTRY_INSURANCE_REINSURANCE          : return CMessage::Text(MSG_SYM_INDUSTRY_INSURANCE_REINSURANCE);
      case INDUSTRY_INSURANCE_SPECIALTY            : return CMessage::Text(MSG_SYM_INDUSTRY_INSURANCE_SPECIALTY);
      case INDUSTRY_MORTGAGE_FINANCE               : return CMessage::Text(MSG_SYM_INDUSTRY_MORTGAGE_FINANCE);
      case INDUSTRY_SHELL_COMPANIES                : return CMessage::Text(MSG_SYM_INDUSTRY_SHELL_COMPANIES);
      case INDUSTRY_BIOTECHNOLOGY                  : return CMessage::Text(MSG_SYM_INDUSTRY_BIOTECHNOLOGY);
      case INDUSTRY_DIAGNOSTICS_RESEARCH           : return CMessage::Text(MSG_SYM_INDUSTRY_DIAGNOSTICS_RESEARCH);
      case INDUSTRY_DRUGS_MANUFACTURERS            : return CMessage::Text(MSG_SYM_INDUSTRY_DRUGS_MANUFACTURERS);
      case INDUSTRY_DRUGS_MANUFACTURERS_SPEC       : return CMessage::Text(MSG_SYM_INDUSTRY_DRUGS_MANUFACTURERS_SPEC);
      case INDUSTRY_HEALTHCARE_PLANS               : return CMessage::Text(MSG_SYM_INDUSTRY_HEALTHCARE_PLANS);
      case INDUSTRY_HEALTH_INFORMATION             : return CMessage::Text(MSG_SYM_INDUSTRY_HEALTH_INFORMATION);
      case INDUSTRY_MEDICAL_FACILITIES             : return CMessage::Text(MSG_SYM_INDUSTRY_MEDICAL_FACILITIES);
      case INDUSTRY_MEDICAL_DEVICES                : return CMessage::Text(MSG_SYM_INDUSTRY_MEDICAL_DEVICES);
      case INDUSTRY_MEDICAL_DISTRIBUTION           : return CMessage::Text(MSG_SYM_INDUSTRY_MEDICAL_DISTRIBUTION);
      case INDUSTRY_MEDICAL_INSTRUMENTS            : return CMessage::Text(MSG_SYM_INDUSTRY_MEDICAL_INSTRUMENTS);
      case INDUSTRY_PHARM_RETAILERS                : return CMessage::Text(MSG_SYM_INDUSTRY_PHARM_RETAILERS);
      case INDUSTRY_AEROSPACE_DEFENSE              : return CMessage::Text(MSG_SYM_INDUSTRY_AEROSPACE_DEFENSE);
      case INDUSTRY_AIRLINES                       : return CMessage::Text(MSG_SYM_INDUSTRY_AIRLINES);
      case INDUSTRY_AIRPORTS_SERVICES              : return CMessage::Text(MSG_SYM_INDUSTRY_AIRPORTS_SERVICES);
      case INDUSTRY_BUILDING_PRODUCTS              : return CMessage::Text(MSG_SYM_INDUSTRY_BUILDING_PRODUCTS);
      case INDUSTRY_BUSINESS_EQUIPMENT             : return CMessage::Text(MSG_SYM_INDUSTRY_BUSINESS_EQUIPMENT);
      case INDUSTRY_CONGLOMERATES                  : return CMessage::Text(MSG_SYM_INDUSTRY_CONGLOMERATES);
      case INDUSTRY_CONSULTING_SERVICES            : return CMessage::Text(MSG_SYM_INDUSTRY_CONSULTING_SERVICES);
      case INDUSTRY_ELECTRICAL_EQUIPMENT           : return CMessage::Text(MSG_SYM_INDUSTRY_ELECTRICAL_EQUIPMENT);
      case INDUSTRY_ENGINEERING_CONSTRUCTION       : return CMessage::Text(MSG_SYM_INDUSTRY_ENGINEERING_CONSTRUCTION);
      case INDUSTRY_FARM_HEAVY_MACHINERY           : return CMessage::Text(MSG_SYM_INDUSTRY_FARM_HEAVY_MACHINERY);
      case INDUSTRY_INDUSTRIAL_DISTRIBUTION        : return CMessage::Text(MSG_SYM_INDUSTRY_INDUSTRIAL_DISTRIBUTION);
      case INDUSTRY_INFRASTRUCTURE_OPERATIONS      : return CMessage::Text(MSG_SYM_INDUSTRY_INFRASTRUCTURE_OPERATIONS);
      case INDUSTRY_FREIGHT_LOGISTICS              : return CMessage::Text(MSG_SYM_INDUSTRY_FREIGHT_LOGISTICS);
      case INDUSTRY_MARINE_SHIPPING                : return CMessage::Text(MSG_SYM_INDUSTRY_MARINE_SHIPPING);
      case INDUSTRY_METAL_FABRICATION              : return CMessage::Text(MSG_SYM_INDUSTRY_METAL_FABRICATION);
      case INDUSTRY_POLLUTION_CONTROL              : return CMessage::Text(MSG_SYM_INDUSTRY_POLLUTION_CONTROL);
      case INDUSTRY_RAILROADS                      : return CMessage::Text(MSG_SYM_INDUSTRY_RAILROADS);
      case INDUSTRY_RENTAL_LEASING                 : return CMessage::Text(MSG_SYM_INDUSTRY_RENTAL_LEASING);
      case INDUSTRY_SECURITY_PROTECTION            : return CMessage::Text(MSG_SYM_INDUSTRY_SECURITY_PROTECTION);
      case INDUSTRY_SPEALITY_BUSINESS_SERVICES     : return CMessage::Text(MSG_SYM_INDUSTRY_SPEALITY_BUSINESS_SERVICES);
      case INDUSTRY_SPEALITY_MACHINERY             : return CMessage::Text(MSG_SYM_INDUSTRY_SPEALITY_MACHINERY);
      case INDUSTRY_STUFFING_EMPLOYMENT            : return CMessage::Text(MSG_SYM_INDUSTRY_STUFFING_EMPLOYMENT);
      case INDUSTRY_TOOLS_ACCESSORIES              : return CMessage::Text(MSG_SYM_INDUSTRY_TOOLS_ACCESSORIES);
      case INDUSTRY_TRUCKING                       : return CMessage::Text(MSG_SYM_INDUSTRY_TRUCKING);
      case INDUSTRY_WASTE_MANAGEMENT               : return CMessage::Text(MSG_SYM_INDUSTRY_WASTE_MANAGEMENT);
      case INDUSTRY_REAL_ESTATE_DEVELOPMENT        : return CMessage::Text(MSG_SYM_INDUSTRY_REAL_ESTATE_DEVELOPMENT);
      case INDUSTRY_REAL_ESTATE_DIVERSIFIED        : return CMessage::Text(MSG_SYM_INDUSTRY_REAL_ESTATE_DIVERSIFIED);
      case INDUSTRY_REAL_ESTATE_SERVICES           : return CMessage::Text(MSG_SYM_INDUSTRY_REAL_ESTATE_SERVICES);
      case INDUSTRY_REIT_DIVERSIFIED               : return CMessage::Text(MSG_SYM_INDUSTRY_REIT_DIVERSIFIED);
      case INDUSTRY_REIT_HEALTCARE                 : return CMessage::Text(MSG_SYM_INDUSTRY_REIT_HEALTCARE);
      case INDUSTRY_REIT_HOTEL_MOTEL               : return CMessage::Text(MSG_SYM_INDUSTRY_REIT_HOTEL_MOTEL);
      case INDUSTRY_REIT_INDUSTRIAL                : return CMessage::Text(MSG_SYM_INDUSTRY_REIT_INDUSTRIAL);
      case INDUSTRY_REIT_MORTAGE                   : return CMessage::Text(MSG_SYM_INDUSTRY_REIT_MORTAGE);
      case INDUSTRY_REIT_OFFICE                    : return CMessage::Text(MSG_SYM_INDUSTRY_REIT_OFFICE);
      case INDUSTRY_REIT_RESIDENTAL                : return CMessage::Text(MSG_SYM_INDUSTRY_REIT_RESIDENTAL);
      case INDUSTRY_REIT_RETAIL                    : return CMessage::Text(MSG_SYM_INDUSTRY_REIT_RETAIL);
      case INDUSTRY_REIT_SPECIALITY                : return CMessage::Text(MSG_SYM_INDUSTRY_REIT_SPECIALITY);
      case INDUSTRY_COMMUNICATION_EQUIPMENT        : return CMessage::Text(MSG_SYM_INDUSTRY_COMMUNICATION_EQUIPMENT);
      case INDUSTRY_COMPUTER_HARDWARE              : return CMessage::Text(MSG_SYM_INDUSTRY_COMPUTER_HARDWARE);
      case INDUSTRY_CONSUMER_ELECTRONICS           : return CMessage::Text(MSG_SYM_INDUSTRY_CONSUMER_ELECTRONICS);
      case INDUSTRY_ELECTRONIC_COMPONENTS          : return CMessage::Text(MSG_SYM_INDUSTRY_ELECTRONIC_COMPONENTS);
      case INDUSTRY_ELECTRONIC_DISTRIBUTION        : return CMessage::Text(MSG_SYM_INDUSTRY_ELECTRONIC_DISTRIBUTION);
      case INDUSTRY_IT_SERVICES                    : return CMessage::Text(MSG_SYM_INDUSTRY_IT_SERVICES);
      case INDUSTRY_SCIENTIFIC_INSTRUMENTS         : return CMessage::Text(MSG_SYM_INDUSTRY_SCIENTIFIC_INSTRUMENTS);
      case INDUSTRY_SEMICONDUCTOR_EQUIPMENT        : return CMessage::Text(MSG_SYM_INDUSTRY_SEMICONDUCTOR_EQUIPMENT);
      case INDUSTRY_SEMICONDUCTORS                 : return CMessage::Text(MSG_SYM_INDUSTRY_SEMICONDUCTORS);
      case INDUSTRY_SOFTWARE_APPLICATION           : return CMessage::Text(MSG_SYM_INDUSTRY_SOFTWARE_APPLICATION);
      case INDUSTRY_SOFTWARE_INFRASTRUCTURE        : return CMessage::Text(MSG_SYM_INDUSTRY_SOFTWARE_INFRASTRUCTURE);
      case INDUSTRY_SOLAR                          : return CMessage::Text(MSG_SYM_INDUSTRY_SOLAR);
      case INDUSTRY_UTILITIES_DIVERSIFIED          : return CMessage::Text(MSG_SYM_INDUSTRY_UTILITIES_DIVERSIFIED);
      case INDUSTRY_UTILITIES_POWERPRODUCERS       : return CMessage::Text(MSG_SYM_INDUSTRY_UTILITIES_POWERPRODUCERS);
      case INDUSTRY_UTILITIES_RENEWABLE            : return CMessage::Text(MSG_SYM_INDUSTRY_UTILITIES_RENEWABLE);
      case INDUSTRY_UTILITIES_REGULATED_ELECTRIC   : return CMessage::Text(MSG_SYM_INDUSTRY_UTILITIES_REGULATED_ELECTRIC);
      case INDUSTRY_UTILITIES_REGULATED_GAS        : return CMessage::Text(MSG_SYM_INDUSTRY_UTILITIES_REGULATED_GAS);
      case INDUSTRY_UTILITIES_REGULATED_WATER      : return CMessage::Text(MSG_SYM_INDUSTRY_UTILITIES_REGULATED_WATER);
      default                                      : return CMessage::Text(MSG_SYM_INDUSTRY_UNDEFINED);
     }
  }
 //+------------------------------------------------------------------+
 //| Return the swap accrual ratio description                        |
 //| for a specified day of the week                                  |
 //+------------------------------------------------------------------+
 string CSymbol::GetSwapRatioDescription(const ENUM_DAY_OF_WEEK day) const
  {
   double ratio=this.SwapRatioDay(day);
   return
     (
      ratio==0 ? CMessage::Text(MSG_SYM_PROP_SWAP_0)  :
      ratio==1 ? CMessage::Text(MSG_SYM_PROP_SWAP_1)  :
      ratio==3 ? CMessage::Text(MSG_SYM_PROP_SWAP_3)  : 
      ::DoubleToString(ratio,3)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of allowing to use market orders          |
 //+------------------------------------------------------------------+
 string CSymbol::GetMarketOrdersAllowedDescription(void) const
  {
   return
     (this.IsMarketOrdersAllowed() ? 
      CMessage::Text(MSG_SYM_MARKET_ORDER_ALLOWED_YES) : 
      CMessage::Text(MSG_SYM_MARKET_ORDER_ALLOWED_NO)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of allowing to use limit orders           |
 //+------------------------------------------------------------------+
 string CSymbol::GetLimitOrdersAllowedDescription(void) const
  {
   return
     (this.IsLimitOrdersAllowed() ? 
      CMessage::Text(MSG_SYM_LIMIT_ORDER_ALLOWED_YES) : 
      CMessage::Text(MSG_SYM_LIMIT_ORDER_ALLOWED_NO)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of allowing to use stop orders            |
 //+------------------------------------------------------------------+
 string CSymbol::GetStopOrdersAllowedDescription(void) const
  {
   return
     (this.IsStopOrdersAllowed() ? 
      CMessage::Text(MSG_SYM_STOP_ORDER_ALLOWED_YES) : 
      CMessage::Text(MSG_SYM_STOP_ORDER_ALLOWED_NO)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of allowing to use stop limit orders      |
 //+------------------------------------------------------------------+
 string CSymbol::GetStopLimitOrdersAllowedDescription(void) const
  {
   return
     (this.IsStopLimitOrdersAllowed() ? 
      CMessage::Text(MSG_SYM_STOPLIMIT_ORDER_ALLOWED_YES) : 
      CMessage::Text(MSG_SYM_STOPLIMIT_ORDER_ALLOWED_NO)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of allowing to set StopLoss orders        |
 //+------------------------------------------------------------------+
 string CSymbol::GetStopLossOrdersAllowedDescription(void) const
  {
   return
     (this.IsStopLossOrdersAllowed() ? 
      CMessage::Text(MSG_SYM_STOPLOSS_ORDER_ALLOWED_YES) : 
      CMessage::Text(MSG_SYM_STOPLOSS_ORDER_ALLOWED_NO)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of allowing to set TakeProfit orders      |
 //+------------------------------------------------------------------+
 string CSymbol::GetTakeProfitOrdersAllowedDescription(void) const
  {
   return
     (this.IsTakeProfitOrdersAllowed() ? 
      CMessage::Text(MSG_SYM_TAKEPROFIT_ORDER_ALLOWED_YES) : 
      CMessage::Text(MSG_SYM_TAKEPROFIT_ORDER_ALLOWED_NO)
     );
  }
 //+---------------------------------------------------------------------+
 //| Return the description of allowing to close by an opposite position |
 //+---------------------------------------------------------------------+
 string CSymbol::GetCloseByOrdersAllowedDescription(void) const
  {
   return
     (this.IsCloseByOrdersAllowed() ? 
      CMessage::Text(MSG_SYM_CLOSEBY_ORDER_ALLOWED_YES) : 
      CMessage::Text(MSG_SYM_CLOSEBY_ORDER_ALLOWED_NO)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of allowing FOK filling type              |
 //+------------------------------------------------------------------+
 string CSymbol::GetFillingModeFOKAllowedDescrioption(void) const
  {
   return
     (this.IsFillingModeFOK() ? 
      CMessage::Text(MSG_SYM_FILLING_MODE_FOK_YES) : 
      CMessage::Text(MSG_SYM_FILLING_MODE_FOK_NO)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of allowing IOC filling type              |
 //+------------------------------------------------------------------+
 string CSymbol::GetFillingModeIOCAllowedDescrioption(void) const
  {
   return
     (this.IsFillingModeIOC() ? 
      CMessage::Text(MSG_SYM_FILLING_MODE_IOK_YES) : 
      CMessage::Text(MSG_SYM_FILLING_MODE_IOK_NO)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of GTC order expiration                   |
 //+------------------------------------------------------------------+
 string CSymbol::GetExpirationModeGTCDescription(void) const
  {
   return
     (this.IsExpirationModeGTC() ? 
      CMessage::Text(MSG_SYM_EXPIRATION_MODE_GTC_YES) : 
      CMessage::Text(MSG_SYM_EXPIRATION_MODE_GTC_NO)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of DAY order expiration                   |
 //+------------------------------------------------------------------+
 string CSymbol::GetExpirationModeDAYDescription(void) const
  {
   return
     (this.IsExpirationModeDAY() ? 
      CMessage::Text(MSG_SYM_EXPIRATION_MODE_DAY_YES) : 
      CMessage::Text(MSG_SYM_EXPIRATION_MODE_DAY_NO)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of Specified order expiration             |
 //+------------------------------------------------------------------+
 string CSymbol::GetExpirationModeSpecifiedDescription(void) const
  {
   return
     (this.IsExpirationModeSpecified() ? 
      CMessage::Text(MSG_SYM_EXPIRATION_MODE_SPECIFIED_YES) : 
      CMessage::Text(MSG_SYM_EXPIRATION_MODE_SPECIFIED_NO)
     );
  }
 //+------------------------------------------------------------------+
 //| Return the description of Specified Day order expiration         |
 //+------------------------------------------------------------------+
 string CSymbol::GetExpirationModeSpecDayDescription(void) const
  {
   return
     (this.IsExpirationModeSpecifiedDay() ? 
      CMessage::Text(MSG_SYM_EXPIRATION_MODE_SPECIFIED_DAY_YES) : 
      CMessage::Text(MSG_SYM_EXPIRATION_MODE_SPECIFIED_DAY_NO)
     );
  }
 //+--------------------------------------------------------------------------------+
 //| Search for a symbol and return the flag indicating its presence on the server  |
 //+--------------------------------------------------------------------------------+
 bool CSymbol::Exist(void) const
  {
   int total=::SymbolsTotal(false);
   for(int i=0;i<total;i++)
      if(::SymbolName(i,false)==this.m_name)
         return true;
   return false;
  }
 //+------------------------------------------------------------------+
 //| Subscribe to the market depth                                    |
 //+------------------------------------------------------------------+
 bool CSymbol::BookAdd(void)
  {
   this.m_book_subscribed=(#ifdef __MQL5__ ::MarketBookAdd(this.m_name) #else false #endif);
   this.m_long_prop[SYMBOL_PROP_BOOKDEPTH_STATE]=this.m_book_subscribed;
   if(this.m_book_subscribed)
      ::Print(CMessage::Text(MSG_SYM_SYMBOLS_BOOK_ADD)+" "+this.m_name);
   else
      ::Print(CMessage::Text(MSG_SYM_SYMBOLS_ERR_BOOK_ADD)+": "+CMessage::Text(::GetLastError()));
   return this.m_book_subscribed;
  }
 //+------------------------------------------------------------------+
 //| Close the market depth                                           |
 //+------------------------------------------------------------------+
 bool CSymbol::BookClose(void)
  {
   //--- If the DOM subscription flag is off, subscription is disabled (or not enabled yet). Return 'true'
    if(!this.m_book_subscribed)
      return true;
   //--- Save the result of unsubscribing from the DOM
    bool res=( #ifdef __MQL5__ ::MarketBookRelease(this.m_name) #else true #endif );
   //--- If unsubscribed successfully, reset the DOM subscription flag and write the status to the object property
    if(res)
     {
      this.m_long_prop[SYMBOL_PROP_BOOKDEPTH_STATE]=this.m_book_subscribed=false;
      ::Print(CMessage::Text(MSG_SYM_SYMBOLS_BOOK_DEL)+" "+this.m_name);
     }
    else
     {
      this.m_long_prop[SYMBOL_PROP_BOOKDEPTH_STATE]=this.m_book_subscribed=true;
      int err=::GetLastError();
      ::Print(CMessage::Text(MSG_SYM_SYMBOLS_ERR_BOOK_DEL)+": "+CMessage::Text(err)+" (",(string)err,")");
     }
   //--- Return the result of unsubscribing from DOM
    return res;
  }
 //+------------------------------------------------------------------+
 //| Return the quote session start time                              |
 //| in seconds from the beginning of a day                           |
 //+------------------------------------------------------------------+
 long CSymbol::SessionQuoteTimeFrom(const uint session_index,ENUM_DAY_OF_WEEK day_of_week=WRONG_VALUE) const
  {
   MqlDateTime time={0};
   datetime from=0,to=0;
   ENUM_DAY_OF_WEEK day=(day_of_week<0 || day_of_week>SATURDAY ? this.CurrentDayOfWeek() : day_of_week);
   return(::SymbolInfoSessionQuote(this.m_name,day,session_index,from,to) ? from : WRONG_VALUE);
  }
 //+------------------------------------------------------------------+
 //| Return the time in seconds since the day start                   |
 //| up to the end of a quote session                                 |
 //+------------------------------------------------------------------+
 long CSymbol::SessionQuoteTimeTo(const uint session_index,ENUM_DAY_OF_WEEK day_of_week=WRONG_VALUE) const
  {
   MqlDateTime time={0};
   datetime from=0,to=0;
   ENUM_DAY_OF_WEEK day=(day_of_week<0 || day_of_week>SATURDAY ? this.CurrentDayOfWeek() : day_of_week);
   return(::SymbolInfoSessionQuote(this.m_name,day,session_index,from,to) ? to : WRONG_VALUE);
  }
 //+------------------------------------------------------------------+
 //| Return the start and end time of a required quote session        |
 //+------------------------------------------------------------------+
 bool CSymbol::GetSessionQuote(const uint session_index,ENUM_DAY_OF_WEEK day_of_week,datetime &from,datetime &to)
  {
   ENUM_DAY_OF_WEEK day=(day_of_week<0 || day_of_week>SATURDAY ? this.CurrentDayOfWeek() : day_of_week);
   return ::SymbolInfoSessionQuote(this.m_name,day,session_index,from,to);
  }
 //+------------------------------------------------------------------+
 //| Return the trading session start time                            |
 //| in seconds from the beginning of a day                           |
 //+------------------------------------------------------------------+
 long CSymbol::SessionTradeTimeFrom(const uint session_index,ENUM_DAY_OF_WEEK day_of_week=WRONG_VALUE) const
  {
   MqlDateTime time={0};
   datetime from=0,to=0;
   ENUM_DAY_OF_WEEK day=(day_of_week<0 || day_of_week>SATURDAY ? this.CurrentDayOfWeek() : day_of_week);
   return(::SymbolInfoSessionTrade(this.m_name,day,session_index,from,to) ? from : WRONG_VALUE);
  }
 //+------------------------------------------------------------------+
 //| Return the time in seconds since the day start                   |
 //| up to the end of a trading session                               |
 //+------------------------------------------------------------------+
 long CSymbol::SessionTradeTimeTo(const uint session_index,ENUM_DAY_OF_WEEK day_of_week=WRONG_VALUE) const
  {
   MqlDateTime time={0};
   datetime from=0,to=0;
   ENUM_DAY_OF_WEEK day=(day_of_week<0 || day_of_week>SATURDAY ? this.CurrentDayOfWeek() : day_of_week);
   return(::SymbolInfoSessionTrade(this.m_name,day,session_index,from,to) ? to : WRONG_VALUE);
  }
 //+------------------------------------------------------------------+
 //| Return the start and end time of a required trading session      |
 //+------------------------------------------------------------------+
 bool CSymbol::GetSessionTrade(const uint session_index,ENUM_DAY_OF_WEEK day_of_week,datetime &from,datetime &to)
  {
   ENUM_DAY_OF_WEEK day=(day_of_week<0 || day_of_week>SATURDAY ? this.CurrentDayOfWeek() : day_of_week);
   return ::SymbolInfoSessionTrade(this.m_name,day,session_index,from,to);
  }
 //+------------------------------------------------------------------+
 //| Return the current day of the week                               |
 //+------------------------------------------------------------------+
 ENUM_DAY_OF_WEEK CSymbol::CurrentDayOfWeek(void) const
  {
   MqlDateTime time={0};
   ::TimeCurrent(time);
   return(ENUM_DAY_OF_WEEK)time.day_of_week;
  }
 //+------------------------------------------------------------------+
 //| Return the number of seconds in a session duration time          |
 //+------------------------------------------------------------------+
 int CSymbol::SessionSeconds(const ulong duration_sec) const
  {
   return int(duration_sec % 60);
  }
 //+------------------------------------------------------------------+
 //| Return the number of minutes in a session duration time          |
 //+------------------------------------------------------------------+
 int CSymbol::SessionMinutes(const ulong duration_sec) const
  {
   return int((duration_sec-this.SessionSeconds(duration_sec)) % 3600)/60;
  }
 //+------------------------------------------------------------------+
 //| Return the number of hours in a session duration time            |
 //+------------------------------------------------------------------+
 int CSymbol::SessionHours(const ulong duration_sec) const
  {
   return int(duration_sec-this.SessionSeconds(duration_sec)-this.SessionMinutes(duration_sec))/3600;
  }
 //+------------------------------------------------------------------+
 //| Return a normalized price considering symbol properties          |
 //+------------------------------------------------------------------+
 double CSymbol::NormalizedPrice(const double price) const
  {
   double tsize=this.TradeTickSize();
   return(tsize!=0 ? ::NormalizeDouble(::round(price/tsize)*tsize,this.Digits()) : ::NormalizeDouble(price,this.Digits()));
  }
 //+------------------------------------------------------------------+
 //| Return a normalized lot considering symbol properties            |
 //+------------------------------------------------------------------+
 double CSymbol::NormalizedLot(const double volume) const
  {
   double ml=this.LotsMin();
   double mx=this.LotsMax();
   double ln=::NormalizeDouble(volume,this.DigitsLot());
   return(ln<ml ? ml : ln>mx ? mx : ln);
  }
 //+------------------------------------------------------------------+
 //| Update all symbol data                                           |
 //+------------------------------------------------------------------+
 void CSymbol::Refresh(void)
  {
   //--- Update quote data
    if(!this.RefreshRates())
      return;
    #ifdef __MQL5__
      ::ResetLastError();
      if(!this.MarginRates())
      {
        this.m_global_error=::GetLastError();
        return;
      }
    #endif 
   //--- Initialize event data
     this.m_is_event=false;
     this.m_hash_sum=0;
   //--- Update integer properties
     this.m_long_prop[SYMBOL_PROP_SELECT]                                             = ::SymbolInfoInteger(this.m_name,SYMBOL_SELECT);
     this.m_long_prop[SYMBOL_PROP_VISIBLE]                                            = ::SymbolInfoInteger(this.m_name,SYMBOL_VISIBLE);
     this.m_long_prop[SYMBOL_PROP_SESSION_DEALS]                                      = ::SymbolInfoInteger(this.m_name,SYMBOL_SESSION_DEALS);
     this.m_long_prop[SYMBOL_PROP_SESSION_BUY_ORDERS]                                 = ::SymbolInfoInteger(this.m_name,SYMBOL_SESSION_BUY_ORDERS);
     this.m_long_prop[SYMBOL_PROP_SESSION_SELL_ORDERS]                                = ::SymbolInfoInteger(this.m_name,SYMBOL_SESSION_SELL_ORDERS);
     this.m_long_prop[SYMBOL_PROP_VOLUMEHIGH]                                         = ::SymbolInfoInteger(this.m_name,SYMBOL_VOLUMEHIGH);
     this.m_long_prop[SYMBOL_PROP_VOLUMELOW]                                          = ::SymbolInfoInteger(this.m_name,SYMBOL_VOLUMELOW);
     this.m_long_prop[SYMBOL_PROP_SPREAD]                                             = ::SymbolInfoInteger(this.m_name,SYMBOL_SPREAD);
     this.m_long_prop[SYMBOL_PROP_TICKS_BOOKDEPTH]                                    = ::SymbolInfoInteger(this.m_name,SYMBOL_TICKS_BOOKDEPTH);
     this.m_long_prop[SYMBOL_PROP_START_TIME]                                         = ::SymbolInfoInteger(this.m_name,SYMBOL_START_TIME);
     this.m_long_prop[SYMBOL_PROP_EXPIRATION_TIME]                                    = ::SymbolInfoInteger(this.m_name,SYMBOL_EXPIRATION_TIME);
     this.m_long_prop[SYMBOL_PROP_TRADE_STOPS_LEVEL]                                  = ::SymbolInfoInteger(this.m_name,SYMBOL_TRADE_STOPS_LEVEL);
     this.m_long_prop[SYMBOL_PROP_TRADE_FREEZE_LEVEL]                                 = ::SymbolInfoInteger(this.m_name,SYMBOL_TRADE_FREEZE_LEVEL);
     this.m_long_prop[SYMBOL_PROP_BACKGROUND_COLOR]                                   = this.SymbolBackgroundColor();
     this.m_long_prop[SYMBOL_PROP_BOOKDEPTH_STATE]                                    = this.m_book_subscribed;
   //--- Update real properties
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_TICK_VALUE)]                 = ::SymbolInfoDouble(this.m_name,SYMBOL_TRADE_TICK_VALUE);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_TICK_VALUE_PROFIT)]          = ::SymbolInfoDouble(this.m_name,SYMBOL_TRADE_TICK_VALUE_PROFIT);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_TICK_VALUE_LOSS)]            = ::SymbolInfoDouble(this.m_name,SYMBOL_TRADE_TICK_VALUE_LOSS);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_TICK_SIZE)]                  = ::SymbolInfoDouble(this.m_name,SYMBOL_TRADE_TICK_SIZE);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_CONTRACT_SIZE)]              = ::SymbolInfoDouble(this.m_name,SYMBOL_TRADE_CONTRACT_SIZE);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUME_MIN)]                       = ::SymbolInfoDouble(this.m_name,SYMBOL_VOLUME_MIN);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUME_MAX)]                       = ::SymbolInfoDouble(this.m_name,SYMBOL_VOLUME_MAX);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUME_STEP)]                      = ::SymbolInfoDouble(this.m_name,SYMBOL_VOLUME_STEP);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUME_LIMIT)]                     = ::SymbolInfoDouble(this.m_name,SYMBOL_VOLUME_LIMIT);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SWAP_LONG)]                        = ::SymbolInfoDouble(this.m_name,SYMBOL_SWAP_LONG);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SWAP_SHORT)]                       = ::SymbolInfoDouble(this.m_name,SYMBOL_SWAP_SHORT);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_INITIAL)]                   = ::SymbolInfoDouble(this.m_name,SYMBOL_MARGIN_INITIAL);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_MAINTENANCE)]               = ::SymbolInfoDouble(this.m_name,SYMBOL_MARGIN_MAINTENANCE);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_VOLUME)]                   = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_VOLUME);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_TURNOVER)]                 = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_TURNOVER);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_INTEREST)]                 = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_INTEREST);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_BUY_ORDERS_VOLUME)]        = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_BUY_ORDERS_VOLUME);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_SELL_ORDERS_VOLUME)]       = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_SELL_ORDERS_VOLUME);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_OPEN)]                     = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_OPEN);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_CLOSE)]                    = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_CLOSE);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_AW)]                       = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_AW);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_PRICE_SETTLEMENT)]         = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_PRICE_SETTLEMENT);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_PRICE_LIMIT_MIN)]          = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_PRICE_LIMIT_MIN);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_SESSION_PRICE_LIMIT_MAX)]          = ::SymbolInfoDouble(this.m_name,SYMBOL_SESSION_PRICE_LIMIT_MAX);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUME_REAL)]                      = this.SymbolVolumeReal();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUMEHIGH_REAL)]                  = this.SymbolVolumeHighReal();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_VOLUMELOW_REAL)]                   = this.SymbolVolumeLowReal();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_OPTION_STRIKE)]                    = this.SymbolOptionStrike();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_ACCRUED_INTEREST)]           = this.SymbolTradeAccruedInterest();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_FACE_VALUE)]                 = this.SymbolTradeFaceValue();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_TRADE_LIQUIDITY_RATE)]             = this.SymbolTradeLiquidityRate();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_HEDGED)]                    = this.SymbolMarginHedged();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_LONG_INITIAL)]              = this.m_margin_rate.Long.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_BUY_STOP_INITIAL)]          = this.m_margin_rate.BuyStop.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_BUY_LIMIT_INITIAL)]         = this.m_margin_rate.BuyLimit.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_INITIAL)]     = this.m_margin_rate.BuyStopLimit.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_LONG_MAINTENANCE)]          = this.m_margin_rate.Long.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_BUY_STOP_MAINTENANCE)]      = this.m_margin_rate.BuyStop.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_BUY_LIMIT_MAINTENANCE)]     = this.m_margin_rate.BuyLimit.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_BUY_STOPLIMIT_MAINTENANCE)] = this.m_margin_rate.BuyStopLimit.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SHORT_INITIAL)]             = this.m_margin_rate.Short.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SELL_STOP_INITIAL)]         = this.m_margin_rate.SellStop.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SELL_LIMIT_INITIAL)]        = this.m_margin_rate.SellLimit.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_INITIAL)]    = this.m_margin_rate.SellStopLimit.Initial;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SHORT_MAINTENANCE)]         = this.m_margin_rate.Short.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SELL_STOP_MAINTENANCE)]     = this.m_margin_rate.SellStop.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SELL_LIMIT_MAINTENANCE)]    = this.m_margin_rate.SellLimit.Maintenance;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_MARGIN_SELL_STOPLIMIT_MAINTENANCE)]= this.m_margin_rate.SellStopLimit.Maintenance;
   
   //--- Fill in the symbol current data
     for(int i=0;i<SYMBOL_PROP_INTEGER_TOTAL;i++)
      this.m_long_prop_event[i][3]=this.m_long_prop[i];
     for(int i=0;i<SYMBOL_PROP_DOUBLE_TOTAL;i++)
      this.m_double_prop_event[i][3]=this.m_double_prop[i];
   
   //--- Update the base object data and search for changes
     CBaseObjExt::Refresh();
     this.CheckEvents();
  }
 //+------------------------------------------------------------------+
 //| Update quote data by a symbol                                    |
 //+------------------------------------------------------------------+
 bool CSymbol::RefreshRates(void)
  {
   //--- Get quote data
     ::ResetLastError();
     if(!::SymbolInfoTick(this.m_name,this.m_tick))
     {
      this.m_global_error=::GetLastError();
      return false;
     }
   //--- Update integer properties
     this.m_long_prop[SYMBOL_PROP_VOLUME]                                             = (long)this.m_tick.volume;
     this.m_long_prop[SYMBOL_PROP_TIME]                                               = this.TickTime();
   //--- Update real properties
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_ASK)]                              = this.m_tick.ask;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_ASKHIGH)]                          = ::SymbolInfoDouble(this.m_name,SYMBOL_ASKHIGH);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_ASKLOW)]                           = ::SymbolInfoDouble(this.m_name,SYMBOL_ASKLOW);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_BID)]                              = this.m_tick.bid;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_BIDHIGH)]                          = this.SymbolBidHigh();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_BIDLOW)]                           = this.SymbolBidLow();
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_LAST)]                             = this.m_tick.last;
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_LASTHIGH)]                         = ::SymbolInfoDouble(this.m_name,SYMBOL_LASTHIGH);
     this.m_double_prop[this.IndexProp(SYMBOL_PROP_LASTLOW)]                          = ::SymbolInfoDouble(this.m_name,SYMBOL_LASTLOW);
   return true;
  }  
 //+------------------------------------------------------------------+
 //| Set the Bid or Last price controlled increase                    |
 //+------------------------------------------------------------------+
 void CSymbol::SetControlBidLastInc(const double value)
  {
   this.SetControlledValueINC((this.ChartMode()==SYMBOL_CHART_MODE_BID ? SYMBOL_PROP_BID : SYMBOL_PROP_LAST),::fabs(value));
  }
 //+------------------------------------------------------------------+
 //|Set the Bid or Last price controlled decrease                     |
 //+------------------------------------------------------------------+
 void CSymbol::SetControlBidLastDec(const double value)
  {
   this.SetControlledValueDEC((this.ChartMode()==SYMBOL_CHART_MODE_BID ? SYMBOL_PROP_BID : SYMBOL_PROP_LAST),::fabs(value));
  }
 //+------------------------------------------------------------------+
 //| Set the Bid or Last price control level                          |
 //+------------------------------------------------------------------+
 void CSymbol::SetControlBidLastLevel(const double value)
  {
   this.SetControlledValueLEVEL((this.ChartMode()==SYMBOL_CHART_MODE_BID ? SYMBOL_PROP_BID : SYMBOL_PROP_LAST),::fabs(value));
  }
 //+------------------------------------------------------------------+
 //| Return the Bid or Last price change value                        |
 //+------------------------------------------------------------------+
 double CSymbol::GetValueChangedBidLast(void) const
  {
   return(this.ChartMode()==SYMBOL_CHART_MODE_BID ? this.GetPropDoubleChangedValue(SYMBOL_PROP_BID) : this.GetPropDoubleChangedValue(SYMBOL_PROP_LAST));
  }
 //+------------------------------------------------------------------+
 //| Return the flag of the Bid or Last price change                  |
 //| exceeding the increase value                                     |
 //+------------------------------------------------------------------+
 bool CSymbol::IsIncreasedBidLast(void) const
  {
   return(this.ChartMode()==SYMBOL_CHART_MODE_BID ? (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_BID) : (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_LAST));
  }
 //+------------------------------------------------------------------+
 //| Return the flag of the Bid or Last price change                  |
 //| exceeding the decrease value                                     |
 //+------------------------------------------------------------------+
 bool CSymbol::IsDecreasedBidLast(void) const
  {
   return(this.ChartMode()==SYMBOL_CHART_MODE_BID ? (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_BID) : (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_LAST));
  }
 //+------------------------------------------------------------------+
 //| Set the controlled increase value                                |
 //| of the maximum Bid or Last price                                 |
 //+------------------------------------------------------------------+
 void CSymbol::SetControlBidLastHighInc(const double value)
  {
   this.SetControlledValueINC((this.ChartMode()==SYMBOL_CHART_MODE_BID ? SYMBOL_PROP_BIDHIGH : SYMBOL_PROP_LASTHIGH),::fabs(value));
  }
 //+------------------------------------------------------------------+
 //| Set the controlled decrease value                                |
 //| of the maximum Bid or Last price                                 |
 //+------------------------------------------------------------------+
 void CSymbol::SetControlBidLastHighDec(const double value)
  {
   this.SetControlledValueDEC((this.ChartMode()==SYMBOL_CHART_MODE_BID ? SYMBOL_PROP_BIDHIGH : SYMBOL_PROP_LASTHIGH),::fabs(value));
  }
 //+------------------------------------------------------------------+
 //| Set the maximum Bid or Last price control level                  |
 //+------------------------------------------------------------------+
 void CSymbol::SetControlBidLastHighLevel(const double value)
  {
   this.SetControlledValueLEVEL((this.ChartMode()==SYMBOL_CHART_MODE_BID ? SYMBOL_PROP_BIDHIGH : SYMBOL_PROP_LASTHIGH),::fabs(value));
  }
 //+------------------------------------------------------------------+
 //| Return the maximum Bid or Last price change value                |
 //+------------------------------------------------------------------+
 double CSymbol::GetValueChangedBidLastHigh(void) const
  {
   return(this.ChartMode()==SYMBOL_CHART_MODE_BID ? this.GetPropDoubleChangedValue(SYMBOL_PROP_BIDHIGH) : this.GetPropDoubleChangedValue(SYMBOL_PROP_LASTHIGH));
  }
 //+------------------------------------------------------------------+
 //| Return the flag of a change of the maximum                       |
 //| Bid or Last price exceeding the increase value                   |
 //+------------------------------------------------------------------+
 bool CSymbol::IsIncreasedBidLastHigh(void) const
  {
   return(this.ChartMode()==SYMBOL_CHART_MODE_BID ? (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_BIDHIGH) : (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_LASTHIGH));
  }
 //+------------------------------------------------------------------+
 //| Return the flag of a change of the maximum                       |
 //| Bid or Last price exceeding the decrease value                   |
 //+------------------------------------------------------------------+
 bool CSymbol::IsDecreasedBidLastHigh(void) const
  {
   return(this.ChartMode()==SYMBOL_CHART_MODE_BID ? (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_BIDHIGH) : (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_LASTHIGH));
  }
 //+------------------------------------------------------------------+
 //| Set the controlled increase value                                |
 //| of the minimum Bid or Last price                                 |
 //+------------------------------------------------------------------+
 void CSymbol::SetControlBidLastLowInc(const double value)
  {
   this.SetControlledValueINC((this.ChartMode()==SYMBOL_CHART_MODE_BID ? SYMBOL_PROP_BIDLOW : SYMBOL_PROP_LASTLOW),::fabs(value));
  }
 //+------------------------------------------------------------------+
 //| Set the controlled decrease value                                |
 //| of the minimum Bid or Last price                                 |
 //+------------------------------------------------------------------+
 void CSymbol::SetControlBidLastLowDec(const double value)
  {
   this.SetControlledValueDEC((this.ChartMode()==SYMBOL_CHART_MODE_BID ? SYMBOL_PROP_BIDLOW : SYMBOL_PROP_LASTLOW),::fabs(value));
  }
 //+------------------------------------------------------------------+
 //| Set the minimum Bid or Last price control level                  |
 //+------------------------------------------------------------------+
 void CSymbol::SetControlBidLastLowLevev(const double value)
  {
   this.SetControlledValueLEVEL((this.ChartMode()==SYMBOL_CHART_MODE_BID ? SYMBOL_PROP_BIDLOW : SYMBOL_PROP_LASTLOW),::fabs(value));
  }
 //+------------------------------------------------------------------+
 //| Return the minimum Bid or Last price change value                |
 //+------------------------------------------------------------------+
 double CSymbol::GetValueChangedBidLastLow(void) const
  {
   return(this.ChartMode()==SYMBOL_CHART_MODE_BID ? this.GetPropDoubleChangedValue(SYMBOL_PROP_BIDLOW) : this.GetPropDoubleChangedValue(SYMBOL_PROP_LASTLOW));
  }
 //+------------------------------------------------------------------+
 //| Return the flag of a change of the minimum                       |
 //| Bid or Last price exceeding the increase value                   |
 //+------------------------------------------------------------------+
 bool CSymbol::IsIncreasedBidLastLow(void) const
  {
   return(this.ChartMode()==SYMBOL_CHART_MODE_BID ? (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_BIDLOW) : (bool)this.GetPropDoubleFlagINC(SYMBOL_PROP_LASTLOW));
  }
 //+------------------------------------------------------------------+
 //| Return the flag of a change of the minimum                       |
 //| Bid or Last price exceeding the decrease value                   |
 //+------------------------------------------------------------------+
 bool CSymbol::IsDecreasedBidLastLow(void) const
  {
   return(this.ChartMode()==SYMBOL_CHART_MODE_BID ? (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_BIDLOW) : (bool)this.GetPropDoubleFlagDEC(SYMBOL_PROP_LASTLOW));
  }
 //+----------------------------------------------------------------------+
 //| Return an order expiration type equal to 'type'                      |
 //| if it is available on a symbol, otherwise, return the correct option |
 //| https://www.mql5.com/ru/forum/170952/page4#comment_4128864           |
 //+----------------------------------------------------------------------+
 ENUM_ORDER_TYPE_FILLING CSymbol::GetCorrectTypeFilling(const uint type=ORDER_FILLING_RETURN)
  {
  const ENUM_SYMBOL_TRADE_EXECUTION exe_mode=this.TradeExecutionMode();
  const int filling_mode=this.FillingModeFlags();

  return(
         (filling_mode == 0 || (type >= ORDER_FILLING_RETURN) || ((filling_mode & (type + 1)) != type + 1)) ?
         (((exe_mode == SYMBOL_TRADE_EXECUTION_EXCHANGE) || (exe_mode == SYMBOL_TRADE_EXECUTION_INSTANT)) ?
           ORDER_FILLING_RETURN : ((filling_mode == SYMBOL_FILLING_IOC) ? ORDER_FILLING_IOC : ORDER_FILLING_FOK)) :
         (ENUM_ORDER_TYPE_FILLING)type
        );
  }
 //+--------------------------------------------------------------------------+
 //| Return order expiration type equal to 'expiration'                       |
 //| if it is available on Symb symbol, otherwise, return the correct option  |
 //| https://www.mql5.com/ru/forum/170952/page4#comment_4128871               |
 //| Application:                                                             |
 //| Request.type_time = GetExpirationType((uint)Expiration);                 |
 //| 'Expiration' can be datetime                                             |
 //| if(Expiration > ORDER_TIME_DAY) Request.expiration = Expiration;         |
 //+--------------------------------------------------------------------------+
 ENUM_ORDER_TYPE_TIME CSymbol::GetCorrectTypeExpiration(uint expiration=ORDER_TIME_GTC)
  {
   #ifdef __MQL5__
   const int expiration_mode=this.ExpirationModeFlags();
   if((expiration > ORDER_TIME_SPECIFIED_DAY) || (((expiration_mode >> expiration) & 1) == 0))
      {
         if((expiration < ORDER_TIME_SPECIFIED) || (expiration_mode < SYMBOL_EXPIRATION_SPECIFIED))
            expiration=ORDER_TIME_GTC;
         else if(expiration > ORDER_TIME_DAY)
            expiration=ORDER_TIME_SPECIFIED;

         uint i=1 << expiration;
         while((expiration <= ORDER_TIME_SPECIFIED_DAY) && ((expiration_mode & i) != i))
         {
            i <<= 1;
            expiration++;
         }
      }
   #endif 
  return (ENUM_ORDER_TYPE_TIME)expiration;
  }
 //+------------------------------------------------------------------+

 #endif // CSYMBOL_MQH_IMPLEMENTATION
#endif // __SYMBOL_MQH__
