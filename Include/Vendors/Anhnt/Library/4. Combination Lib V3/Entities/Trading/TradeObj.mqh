//+------------------------------------------------------------------+
//|                                                     TradeObj.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/7229                 |
//|Lib https://www.mql5.com/en/articles/14710                        |

//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __TRADEOBJ_MQH__
#define __TRADEOBJ_MQH__
#define TRADE_OBJ_COMMENT_SUFFIX (" by DoEasy")   // Appended to the program name in the default order comment

//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
 #include "..\Defines\CommonDefines.mqh" 
 #include "..\Defines\TradingDefines.mqh"
 #include "..\..\Entities\Bases\BaseObjExt.mqh"
 #include "..\..\Services\DELib\TradingDELib.mqh"

 #ifndef CTRADEOBJ_MQH_DECLARATION
 #define CTRADEOBJ_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Trading object class                                             |
  //+------------------------------------------------------------------+
  class CTradeObj : public CBaseObjExt
   {
    private:
     struct SActionsFlags
      {
        private:
         //Bool flags for sound
          bool                    m_use_sound_open;          // The flag of using the position opening/order placing sound
          bool                    m_use_sound_close;         // The flag of using the position closing/order removal sound
          bool                    m_use_sound_modify_sl;     // The flag of using the StopLoss position/order modification sound
          bool                    m_use_sound_modify_tp;     // The flag of using the TakeProfit position/order modification sound
          bool                    m_use_sound_modify_price;  // The flag of using the order placement price modification sound
         //--- Sound file names
          string                  m_sound_open;              // Position opening/order placing sound
          string                  m_sound_close;             // Position closing/order removal sound
          string                  m_sound_modify_sl;         // StopLoss position/order modification sound
          string                  m_sound_modify_tp;         // TakeProfit position/order modification sound
          string                  m_sound_modify_price;      // Order placement price modification sound
         //---Sound file names for errors
          string                  m_sound_open_err;          // Position opening/order placing error sound
          string                  m_sound_close_err;         // Position closing/order removal error sound
          string                  m_sound_modify_sl_err;     // StopLoss position/order modification error sound
          string                  m_sound_modify_tp_err;     // TakeProfit position/order modification error sound
          string                  m_sound_modify_price_err;  // Order placement price modification error sound
        public:
         //--- Method of Accessing flags for sound
          //Set flags for sound
           void                    UseSoundOpen(const bool flag)                      { this.m_use_sound_open=flag;             }
           void                    UseSoundClose(const bool flag)                     { this.m_use_sound_close=flag;            }
           void                    UseSoundModifySL(const bool flag)                  { this.m_use_sound_modify_sl=flag;        }
           void                    UseSoundModifyTP(const bool flag)                  { this.m_use_sound_modify_tp=flag;        }
           void                    UseSoundModifyPrice(const bool flag)               { this.m_use_sound_modify_price=flag;     }
          //Getting flags for sound
           bool                    UseSoundOpen(void)                           const { return this.m_use_sound_open;           }
           bool                    UseSoundClose(void)                          const { return this.m_use_sound_close;          }
           bool                    UseSoundModifySL(void)                       const { return this.m_use_sound_modify_sl;      }
           bool                    UseSoundModifyTP(void)                       const { return this.m_use_sound_modify_tp;      }
           bool                    UseSoundModifyPrice(void)                    const { return this.m_use_sound_modify_price;   }
          //--- Method of Accessing sound file names
          //Set sound file names
           void                    SoundOpen(const string sound)                      { this.m_sound_open=sound;                }
           void                    SoundClose(const string sound)                     { this.m_sound_close=sound;               }
           void                    SoundModifySL(const string sound)                  { this.m_sound_modify_sl=sound;           }
           void                    SoundModifyTP(const string sound)                  { this.m_sound_modify_tp=sound;           }
           void                    SoundModifyPrice(const string sound)               { this.m_sound_modify_price=sound;        }
          //Getting sound file names
           string                  SoundOpen(void)                              const { return this.m_sound_open;               }
           string                  SoundClose(void)                             const { return this.m_sound_close;              }
           string                  SoundModifySL(void)                          const { return this.m_sound_modify_sl;          }
           string                  SoundModifyTP(void)                          const { return this.m_sound_modify_tp;          }
           string                  SoundModifyPrice(void)                       const { return this.m_sound_modify_price;       }
          //---Method of Accessing Sound file names for errors
          //Set sound file names for errors
           void                    SoundErrorOpen(const string sound)                 { this.m_sound_open_err=sound;            }
           void                    SoundErrorClose(const string sound)                { this.m_sound_close_err=sound;           }
           void                    SoundErrorModifySL(const string sound)             { this.m_sound_modify_sl_err=sound;       }
           void                    SoundErrorModifyTP(const string sound)             { this.m_sound_modify_tp_err=sound;       }
           void                    SoundErrorModifyPrice(const string sound)          { this.m_sound_modify_price_err=sound;    }
          //Getting sound file names for errors
           string                  SoundErrorOpen(void)                             const { return this.m_sound_open_err;           }
           string                  SoundErrorClose(void)                            const { return this.m_sound_close_err;          }
           string                  SoundErrorModifySL(void)                         const { return this.m_sound_modify_sl_err;      }
           string                  SoundErrorModifyTP(void)                         const { return this.m_sound_modify_tp_err;      }
           string                  SoundErrorModifyPrice(void)                      const { return this.m_sound_modify_price_err;   }
      };
      struct SActions
       {
        SActionsFlags           Buy;
        SActionsFlags           BuyStop;
        SActionsFlags           BuyLimit;
        SActionsFlags           BuyStopLimit;
        SActionsFlags           Sell;
        SActionsFlags           SellStop;
        SActionsFlags           SellLimit;
        SActionsFlags           SellStopLimit;
       };
      SActions                   m_data;
      MqlTradeRequest            m_request;                                         // Trading request structure
      MqlTradeResult             m_result;                                          // Trading request execution result structure
      ENUM_SYMBOL_CHART_MODE     m_chart_mode;                                      // Price type for constructing bars
      ENUM_ACCOUNT_MARGIN_MODE   m_margin_mode;                                     // Margin calculation mode
      ENUM_ORDER_TYPE_FILLING    m_type_filling;                                    // Filling policy
      ENUM_ORDER_TYPE_TIME       m_type_time;                                       // Order type per expiration
      int                        m_symbol_expiration_flags;                         // Flags of order expiration modes for a trading object symbol
      ulong                      m_magic;                                           // Magic number
      string                     m_symbol;                                          // Symbol
      string                     m_comment;                                         // Comment
      ulong                      m_deviation;                                       // Slippage in points
      double                     m_volume;                                          // Volume
      datetime                   m_expiration;                                      // Order expiration time (for ORDER_TIME_SPECIFIED type orders)
      bool                       m_async_mode;                                      // Flag of asynchronous sending of a trade request
      int                        m_stop_limit;                                      // Distance of placing a StopLimit order in points
      uint                       m_multiplier;                                      // The spread multiplier to adjust levels relative to StopLevel
        
      //--- Play the sound of (1) opening/placing a specified position/order type,
      //--- (2) closing/removal of a specified position/order type, (3) StopLoss modification for a specified position/order type,
      //--- (4) TakeProfit modification for a specified position/order type, (5) placement price modification for a specified order type
        void                       PlaySoundOpen(const int action);
        void                       PlaySoundClose(const int action);
        void                       PlaySoundModifySL(const int action);
        void                       PlaySoundModifyTP(const int action);
        void                       PlaySoundModifyPrice(const int action);
      //--- Play the error sound of (1) opening/placing a specified position/order type,
      //--- (2) closing/removal of a specified position/order type, (3) StopLoss modification for a specified position/order type,
      //--- (4) TakeProfit modification for a specified position/order type, (5) placement price modification for a specified order type
        void                       PlaySoundErrorOpen(const int action);
        void                       PlaySoundErrorClose(const int action);
        void                       PlaySoundErrorModifySL(const int action);
        void                       PlaySoundErrorModifyTP(const int action);
        void                       PlaySoundErrorModifyPrice(const int action);
        
      public:
       //--- Constructor
                                    CTradeObj();

       //--- Set/return the spread multiplier
        void                       SetSpreadMultiplier(const uint value)        { this.m_multiplier=(value==0 ? 1 : value);  }
        uint                       SpreadMultiplier(void)                 const { return this.m_multiplier;                  }
       //--- Set default values
        void                       Init(const string symbol,
                                        const ulong magic,
                                        const double volume,
                                        const ulong deviation,
                                        const int stoplimit,
                                        const datetime expiration,
                                        const bool async_mode,
                                        const ENUM_ORDER_TYPE_FILLING type_filling,
                                        const ENUM_ORDER_TYPE_TIME type_expiration,
                                        ENUM_LOG_LEVEL log_level);
       //Working with sound
        //--- Set default sounds and flags of using sounds,
         void                       InitSounds(const bool use_sound=false,
                                              const string sound_open=NULL,
                                              const string sound_close=NULL,
                                              const string sound_sl=NULL,
                                              const string sound_tp=NULL,
                                              const string sound_price=NULL,
                                              const string sound_error=NULL);
        //--- Allow working with sounds and set standard sounds
         void                       SetSoundsStandard(void);
        //--- Set the flag of using the sound of (1) opening/placing a specified position/order type,
        //--- (2) closing/removal of a specified position/order type, (3) StopLoss modification for a specified position/order type,
        //--- (4) TakeProfit modification for a specified position/order type, (5) placement price modification for a specified order type
         void                       UseSoundOpen(const int action,const bool flag);
         void                       UseSoundClose(const int action,const bool flag);
         void                       UseSoundModifySL(const int action,const bool flag);
         void                       UseSoundModifyTP(const int action,const bool flag);
         void                       UseSoundModifyPrice(const int action,const bool flag);
        //--- Return the flag of using the sound of (1) opening/placing a specified position/order type,
        //--- (2) closing/removal of a specified position/order type, (3) StopLoss modification for a specified position/order type,
        //--- (4) TakeProfit modification for a specified position/order type, (5) placement price modification for a specified order type
         bool                       UseSoundOpen(const int action)            const;
         bool                       UseSoundClose(const int action)           const;
         bool                       UseSoundModifySL(const int action)        const;
         bool                       UseSoundModifyTP(const int action)        const;
         bool                       UseSoundModifyPrice(const int action)     const;
        //--- Set the sound of (1) opening/placing a specified position/order type,
        //--- (2) closing/removal of a specified position/order type, (3) StopLoss modification for a specified position/order type,
        //--- (4) TakeProfit modification for a specified position/order type, (5) placement price modification for a specified order type
         void                       SetSoundOpen(const ENUM_ORDER_TYPE action,const string sound);
         void                       SetSoundClose(const ENUM_ORDER_TYPE action,const string sound);
         void                       SetSoundModifySL(const ENUM_ORDER_TYPE action,const string sound);
         void                       SetSoundModifyTP(const ENUM_ORDER_TYPE action,const string sound);
         void                       SetSoundModifyPrice(const ENUM_ORDER_TYPE action,const string sound);
         //--- Set the error sound of (1) opening/placing a specified position/order type,
         //--- (2) closing/removal of a specified position/order type, (3) StopLoss modification for a specified position/order type,
         //--- (4) TakeProfit modification for a specified position/order type, (5) placement price modification for a specified order type
          void                       SetSoundErrorOpen(const ENUM_ORDER_TYPE action,const string sound);
          void                       SetSoundErrorClose(const ENUM_ORDER_TYPE action,const string sound);
          void                       SetSoundErrorModifySL(const ENUM_ORDER_TYPE action,const string sound);
          void                       SetSoundErrorModifyTP(const ENUM_ORDER_TYPE action,const string sound);
          void                       SetSoundErrorModifyPrice(const ENUM_ORDER_TYPE action,const string sound);
         //--- Return the sound of (1) opening/placing a specified position/order type,
         //--- (2) closing/removal of a specified position/order type, (3) StopLoss modification for a specified position/order type,
         //--- (4) TakeProfit modification for a specified position/order type, (5) placement price modification for a specified order type
          string                     GetSoundOpen(const ENUM_ORDER_TYPE action)               const;
          string                     GetSoundClose(const ENUM_ORDER_TYPE action)              const;
          string                     GetSoundModifySL(const ENUM_ORDER_TYPE action)           const;
          string                     GetSoundModifyTP(const ENUM_ORDER_TYPE action)           const;
          string                     GetSoundModifyPrice(const ENUM_ORDER_TYPE action)        const;
         //--- Return the error sound of (1) opening/placing a specified position/order type,
         //--- (2) closing/removal of a specified position/order type, (3) StopLoss modification for a specified position/order type,
         //--- (4) TakeProfit modification for a specified position/order type, (5) placement price modification for a specified order type
          string                     GetSoundErrorOpen(const ENUM_ORDER_TYPE action)          const;
          string                     GetSoundErrorClose(const ENUM_ORDER_TYPE action)         const;
          string                     GetSoundErrorModifySL(const ENUM_ORDER_TYPE action)      const;
          string                     GetSoundErrorModifyTP(const ENUM_ORDER_TYPE action)      const;
          string                     GetSoundErrorModifyPrice(const ENUM_ORDER_TYPE action)   const;

        //--- Play a sound of a specified trading event for a set position/order type
          void                       PlaySoundSuccess(const ENUM_ACTION_TYPE action,const int order,bool sl=false,bool tp=false,bool pr=false);
        //--- Play an error sound of a specified trading event for a set position/order type
          void                       PlaySoundError(const ENUM_ACTION_TYPE action,const int order,bool sl=false,bool tp=false,bool pr=false);
       //Working with Order
        //--- (1) Return the margin calculation mode, (2) hedge account flag
          ENUM_ACCOUNT_MARGIN_MODE   GetMarginMode(void)                                const { return this.m_margin_mode;           }
          bool                       IsHedge(void) const { return this.GetMarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING;          }
        //--- (1) Set, (2) return the filling policy
          void                       SetTypeFilling(const ENUM_ORDER_TYPE_FILLING type)       { this.m_type_filling=type;            }
          ENUM_ORDER_TYPE_FILLING    GetTypeFilling(void)                               const { return this.m_type_filling;          }
        //--- (1) Set, (2) return order expiration type
          void                       SetTypeExpiration(const ENUM_ORDER_TYPE_TIME type)       { this.m_type_time=type;               }
          ENUM_ORDER_TYPE_TIME       GetTypeExpiration(void)                            const { return this.m_type_time;             }
        //--- (1) Set, (2) return the magic number
          void                       SetMagic(const ulong magic)                              { this.m_magic=magic;                  }
          ulong                      GetMagic(void)                                     const { return this.m_magic;                 }
        //--- (1) Set, (2) return a symbol
          void                       SetSymbol(const string symbol)                           { this.m_symbol=symbol;                }
          string                     GetSymbol(void)                                    const { return this.m_symbol;                }
        //--- (1) Set, (2) return a comment
          void                       SetComment(const string comment)                         { this.m_comment=comment;              }
          string                     GetComment(void)                                   const { return this.m_comment;               }
        //--- (1) Set, (2) return slippage
          void                       SetDeviation(const ulong deviation)                      { this.m_deviation=deviation;          }
          ulong                      GetDeviation(void)                                 const { return this.m_deviation;             }
        //--- (1) Set, (2) return volume
          void                       SetVolume(const double volume)                           { this.m_volume=volume;                }
          double                     GetVolume(void)                                    const { return this.m_volume;                }
        //--- (1) Set, (2) return order expiration date
          void                       SetExpiration(const datetime time)                       { this.m_expiration=time;              }
          datetime                   GetExpiration(void)                                const { return this.m_expiration;            }
        //--- (1) Set, (2) return the flag of the asynchronous sending of a trading request
          void                       SetAsyncMode(const bool async)                           { this.m_async_mode=async;             }
          bool                       IsAsyncMode(void)                                  const { return this.m_async_mode;            }
       //--- Last request data:
       //--- Return (1) executed action type, (2) magic number, (3) order ticket, (4) volume,
       //--- (5) open, (6) StopLimit order, (7) StopLoss, (8) TakeProfit price, (9) deviation,
       //--- type of (10) order, (11) execution, (12) lifetime, (13) order expiration date,
       //--- (14) comment, (15) position ticket, (16) opposite position ticket
        ENUM_TRADE_REQUEST_ACTIONS GetLastRequestAction(void)                         const { return this.m_request.action;        }
        ulong                      GetLastRequestMagic(void)                          const { return this.m_request.magic;         }
        ulong                      GetLastRequestOrder(void)                          const { return this.m_request.order;         }
        double                     GetLastRequestVolume(void)                         const { return this.m_request.volume;        }
        double                     GetLastRequestPrice(void)                          const { return this.m_request.price;         }
        double                     GetLastRequestStopLimit(void)                      const { return this.m_request.stoplimit;     }
        double                     GetLastRequestStopLoss(void)                       const { return this.m_request.sl;            }
        double                     GetLastRequestTakeProfit(void)                     const { return this.m_request.tp;            }
        ulong                      GetLastRequestDeviation(void)                      const { return this.m_request.deviation;     }
        ENUM_ORDER_TYPE            GetLastRequestType(void)                           const { return this.m_request.type;          }
        ENUM_ORDER_TYPE_FILLING    GetLastRequestTypeFilling(void)                    const { return this.m_request.type_filling;  }
        ENUM_ORDER_TYPE_TIME       GetLastRequestTypeTime(void)                       const { return this.m_request.type_time;     }
        datetime                   GetLastRequestExpiration(void)                     const { return this.m_request.expiration;    }
        string                     GetLastRequestComment(void)                        const { return this.m_request.comment;       }
        ulong                      GetLastRequestPosition(void)                       const { return this.m_request.position;      }
        ulong                      GetLastRequestPositionBy(void)                     const { return this.m_request.position_by;   }

       //--- Set the error code in the last request result
        void                       SetResultRetcode(const uint retcode)                     { this.m_result.retcode=retcode;       }
        void                       SetResultComment(const string comment)                   { this.m_result.comment=comment;       }
       //--- Data on the last request result:
       //--- Return (1) operation result code, (2) performed deal ticket, (3) placed order ticket,
       //--- (4) deal volume confirmed by a broker, (5) deal price confirmed by a broker,
       //--- (6) current market Bid (requote) price, (7) current market Ask (requote) price
       //--- (8) broker comment to operation (by default, it is filled by the trade server return code description),
       //--- (9) request ID set by the terminal when sending, (10) external trading system return code
        uint                       GetResultRetcode(void)                             const { return this.m_result.retcode;        }
        ulong                      GetResultDeal(void)                                const { return this.m_result.deal;           }
        ulong                      GetResultOrder(void)                               const { return this.m_result.order;          }
        double                     GetResultVolume(void)                              const { return this.m_result.volume;         }
        double                     GetResultPrice(void)                               const { return this.m_result.price;          }
        double                     GetResultBid(void)                                 const { return this.m_result.bid;            }
        double                     GetResultAsk(void)                                 const { return this.m_result.ask;            }
        string                     GetResultComment(void)                             const { return this.m_result.comment;        }
        uint                       GetResultRequestID(void)                           const { return this.m_result.request_id;     }
        uint                       GetResultRetcodeEXT(void)                          const { return this.m_result.retcode_external;}

       //--- Return the description of the (1) executed action type, (2) magic number, (3) order ticket, (4) volume,
       //--- (5) open, (6) StopLimit order, (7) StopLoss, (8) TakeProfit price, (9) deviation,
       //--- type of (10) order, (11) execution, (12) lifetime, (13) order expiration date,
       //--- (14) comment, (15) position ticket, (16) opposite position ticket
        string                     GetRequestActionDescription(void)                  const { return RequestActionDescription(this.m_request);       }
        string                     GetRequestMagicDescription(void)                   const { return RequestMagicDescription(this.m_request);        }
        string                     GetRequestOrderDescription(void)                   const { return RequestOrderDescription(this.m_request);        }
        string                     GetRequestSymbolDescription(void)                  const { return RequestSymbolDescription(this.m_request);       }
        string                     GetRequestVolumeDescription(void)                  const { return RequestVolumeDescription(this.m_request);       }
        string                     GetRequestPriceDescription(void)                   const { return RequestPriceDescription(this.m_request);        }
        string                     GetRequestStopLimitDescription(void)               const { return RequestStopLimitDescription(this.m_request);    }
        string                     GetRequestStopLossDescription(void)                const { return RequestStopLossDescription(this.m_request);     }
        string                     GetRequestTakeProfitDescription(void)              const { return RequestTakeProfitDescription(this.m_request);   }
        string                     GetRequestDeviationDescription(void)               const { return RequestDeviationDescription(this.m_request);    }
        string                     GetRequestTypeDescription(void)                    const { return RequestTypeDescription(this.m_request);         }
        string                     GetRequestTypeFillingDescription(void)             const { return RequestTypeFillingDescription(this.m_request);  }
        string                     GetRequestTypeTimeDescription(void)                const { return RequestTypeTimeDescription(this.m_request);     }
        string                     GetRequestExpirationDescription(void)              const { return RequestExpirationDescription(this.m_request);   }
        string                     GetRequestCommentDescription(void)                 const { return RequestCommentDescription(this.m_request);      }
        string                     GetRequestPositionDescription(void)                const { return RequestPositionDescription(this.m_request);     }
        string                     GetRequestPositionByDescription(void)              const { return RequestPositionByDescription(this.m_request);   }

       //--- Open a position
        bool                       OpenPosition(const ENUM_POSITION_TYPE type,
                                                const double volume,
                                                const double sl=0,
                                                const double tp=0,
                                                const ulong magic=ULONG_MAX,
                                                const string comment=NULL,
                                                const ulong deviation=ULONG_MAX,
                                                const ENUM_ORDER_TYPE_FILLING type_filling=WRONG_VALUE);
       //--- Close a position
        bool                       ClosePosition(const ulong ticket,
                                                  const string comment=NULL,
                                                  const ulong deviation=ULONG_MAX);
       //--- Close a position partially
        bool                       ClosePositionPartially(const ulong ticket,
                                                          const double volume,
                                                          const string comment=NULL,
                                                          const ulong deviation=ULONG_MAX);
       //--- Close a position by an opposite one
        bool                       ClosePositionBy(const ulong ticket,const ulong ticket_by);
       //--- Modify a position
        bool                       ModifyPosition(const ulong ticket,const double sl=WRONG_VALUE,const double tp=WRONG_VALUE);
       //--- Place an order
        bool                       SetOrder(const ENUM_ORDER_TYPE type,
                                            const double volume,
                                            const double price,
                                            const double sl=0,
                                            const double tp=0,
                                            const double price_stoplimit=0,
                                            const ulong magic=ULONG_MAX,
                                            const string comment=NULL,
                                            const datetime expiration=0,
                                            const ENUM_ORDER_TYPE_TIME type_time=WRONG_VALUE,
                                            const ENUM_ORDER_TYPE_FILLING type_filling=WRONG_VALUE);
       //--- Remove an order
        bool                       DeleteOrder(const ulong ticket);
       //--- Modify an order
        bool                       ModifyOrder(const ulong ticket,
                                                const double price=WRONG_VALUE,
                                                const double sl=WRONG_VALUE,
                                                const double tp=WRONG_VALUE,
                                                const double price_stoplimit=WRONG_VALUE,
                                                const datetime expiration=WRONG_VALUE,
                                                const ENUM_ORDER_TYPE_TIME type_time=WRONG_VALUE,
                                                const ENUM_ORDER_TYPE_FILLING type_filling=WRONG_VALUE);
    
    };
 #endif // CTRADEOBJ_MQH_DECLARATION
 #ifndef CTRADEOBJ_MQH_IMPLEMENTATION
 #define CTRADEOBJ_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeObj::CTradeObj(void) : m_magic(0),
                             m_deviation(5),
                             m_stop_limit(0),
                             m_expiration(0),
                             m_async_mode(false),
                             m_type_filling(ORDER_FILLING_FOK),
                             m_type_time(ORDER_TIME_GTC),
                             m_comment(::MQLInfoString(MQL_PROGRAM_NAME)+TRADE_OBJ_COMMENT_SUFFIX)
  {
    this.m_type=OBJECT_DE_TYPE_TRADE; 
   //--- Margin calculation mode
    this.m_margin_mode=
     (
      #ifdef __MQL5__ (ENUM_ACCOUNT_MARGIN_MODE)::AccountInfoInteger(ACCOUNT_MARGIN_MODE)
      #else /* MQL4 */ ACCOUNT_MARGIN_MODE_RETAIL_HEDGING #endif 
     );
   //--- Spread multiplier
    this.m_multiplier=1;
   //--- Set default sounds and flags of using sounds
    this.m_use_sound=false;
    this.m_log_level=LOG_LEVEL_ERROR_MSG;
    this.InitSounds();
  }
//+------------------------------------------------------------------+
//| Set default values                                               |
//+------------------------------------------------------------------+
void CTradeObj::Init(const string symbol,
                     const ulong magic,
                     const double volume,
                     const ulong deviation,
                     const int stoplimit,
                     const datetime expiration,
                     const bool async_mode,
                     const ENUM_ORDER_TYPE_FILLING type_filling,
                     const ENUM_ORDER_TYPE_TIME type_expiration,
                     ENUM_LOG_LEVEL log_level)
  {
   this.SetSymbol(symbol);
   this.SetMagic(magic);
   this.SetDeviation(deviation);
   this.SetVolume(volume);
   this.SetExpiration(expiration);
   this.SetTypeFilling(type_filling);
   this.SetTypeExpiration(type_expiration);
   this.SetAsyncMode(async_mode);
   this.m_log_level=log_level;
   this.m_symbol_expiration_flags=(int)::SymbolInfoInteger(this.m_symbol,SYMBOL_EXPIRATION_MODE);
   this.m_volume=::SymbolInfoDouble(this.m_symbol,SYMBOL_VOLUME_MIN);
   this.m_chart_mode=#ifdef __MQL5__ (ENUM_SYMBOL_CHART_MODE)::SymbolInfoInteger(this.m_symbol,SYMBOL_CHART_MODE) #else SYMBOL_CHART_MODE_BID #endif ;
  }
//+------------------------------------------------------------------+
//| Set default sounds and flags of using sounds                     |
//+------------------------------------------------------------------+
void CTradeObj::InitSounds(const bool use_sound=false,
                           const string sound_open=NULL,
                           const string sound_close=NULL,
                           const string sound_sl=NULL,
                           const string sound_tp=NULL,
                           const string sound_price=NULL,
                           const string sound_error=NULL)
  {
   this.m_data.Buy.UseSoundOpen(use_sound);
   this.m_data.Buy.UseSoundClose(use_sound);
   this.m_data.Buy.UseSoundModifySL(use_sound);
   this.m_data.Buy.UseSoundModifyTP(use_sound);
   this.m_data.Buy.UseSoundModifyPrice(use_sound);
   this.m_data.Buy.SoundOpen(sound_open);
   this.m_data.Buy.SoundClose(sound_close);
   this.m_data.Buy.SoundModifySL(sound_sl);
   this.m_data.Buy.SoundModifyTP(sound_tp);
   this.m_data.Buy.SoundModifyPrice(sound_price);
   this.m_data.Buy.SoundErrorClose(sound_error);
   this.m_data.Buy.SoundErrorOpen(sound_error);
   this.m_data.Buy.SoundErrorModifySL(sound_error);
   this.m_data.Buy.SoundErrorModifyTP(sound_error);
   this.m_data.Buy.SoundErrorModifyPrice(sound_error);
   
   this.m_data.BuyStop.UseSoundOpen(use_sound);
   this.m_data.BuyStop.UseSoundClose(use_sound);
   this.m_data.BuyStop.UseSoundModifySL(use_sound);
   this.m_data.BuyStop.UseSoundModifyTP(use_sound);
   this.m_data.BuyStop.UseSoundModifyPrice(use_sound);
   this.m_data.BuyStop.SoundOpen(sound_open);
   this.m_data.BuyStop.SoundClose(sound_close);
   this.m_data.BuyStop.SoundModifySL(sound_sl);
   this.m_data.BuyStop.SoundModifyTP(sound_tp);
   this.m_data.BuyStop.SoundModifyPrice(sound_price);
   this.m_data.BuyStop.SoundErrorClose(sound_error);
   this.m_data.BuyStop.SoundErrorOpen(sound_error);
   this.m_data.BuyStop.SoundErrorModifySL(sound_error);
   this.m_data.BuyStop.SoundErrorModifyTP(sound_error);
   this.m_data.BuyStop.SoundErrorModifyPrice(sound_error);
   
   this.m_data.BuyLimit.UseSoundOpen(use_sound);
   this.m_data.BuyLimit.UseSoundClose(use_sound);
   this.m_data.BuyLimit.UseSoundModifySL(use_sound);
   this.m_data.BuyLimit.UseSoundModifyTP(use_sound);
   this.m_data.BuyLimit.UseSoundModifyPrice(use_sound);
   this.m_data.BuyLimit.SoundOpen(sound_open);
   this.m_data.BuyLimit.SoundClose(sound_close);
   this.m_data.BuyLimit.SoundModifySL(sound_sl);
   this.m_data.BuyLimit.SoundModifyTP(sound_tp);
   this.m_data.BuyLimit.SoundModifyPrice(sound_price);
   this.m_data.BuyLimit.SoundErrorClose(sound_error);
   this.m_data.BuyLimit.SoundErrorOpen(sound_error);
   this.m_data.BuyLimit.SoundErrorModifySL(sound_error);
   this.m_data.BuyLimit.SoundErrorModifyTP(sound_error);
   this.m_data.BuyLimit.SoundErrorModifyPrice(sound_error);
   
   this.m_data.BuyStopLimit.UseSoundOpen(use_sound);
   this.m_data.BuyStopLimit.UseSoundClose(use_sound);
   this.m_data.BuyStopLimit.UseSoundModifySL(use_sound);
   this.m_data.BuyStopLimit.UseSoundModifyTP(use_sound);
   this.m_data.BuyStopLimit.UseSoundModifyPrice(use_sound);
   this.m_data.BuyStopLimit.SoundOpen(sound_open);
   this.m_data.BuyStopLimit.SoundClose(sound_close);
   this.m_data.BuyStopLimit.SoundModifySL(sound_sl);
   this.m_data.BuyStopLimit.SoundModifyTP(sound_tp);
   this.m_data.BuyStopLimit.SoundModifyPrice(sound_price);
   this.m_data.BuyStopLimit.SoundErrorClose(sound_error);
   this.m_data.BuyStopLimit.SoundErrorOpen(sound_error);
   this.m_data.BuyStopLimit.SoundErrorModifySL(sound_error);
   this.m_data.BuyStopLimit.SoundErrorModifyTP(sound_error);
   this.m_data.BuyStopLimit.SoundErrorModifyPrice(sound_error);
   
   this.m_data.Sell.UseSoundOpen(use_sound);
   this.m_data.Sell.UseSoundClose(use_sound);
   this.m_data.Sell.UseSoundModifySL(use_sound);
   this.m_data.Sell.UseSoundModifyTP(use_sound);
   this.m_data.Sell.UseSoundModifyPrice(use_sound);
   this.m_data.Sell.SoundOpen(sound_open);
   this.m_data.Sell.SoundClose(sound_close);
   this.m_data.Sell.SoundModifySL(sound_sl);
   this.m_data.Sell.SoundModifyTP(sound_tp);
   this.m_data.Sell.SoundModifyPrice(sound_price);
   this.m_data.Sell.SoundErrorClose(sound_error);
   this.m_data.Sell.SoundErrorOpen(sound_error);
   this.m_data.Sell.SoundErrorModifySL(sound_error);
   this.m_data.Sell.SoundErrorModifyTP(sound_error);
   this.m_data.Sell.SoundErrorModifyPrice(sound_error);
   
   this.m_data.SellStop.UseSoundOpen(use_sound);
   this.m_data.SellStop.UseSoundClose(use_sound);
   this.m_data.SellStop.UseSoundModifySL(use_sound);
   this.m_data.SellStop.UseSoundModifyTP(use_sound);
   this.m_data.SellStop.UseSoundModifyPrice(use_sound);
   this.m_data.SellStop.SoundOpen(sound_open);
   this.m_data.SellStop.SoundClose(sound_close);
   this.m_data.SellStop.SoundModifySL(sound_sl);
   this.m_data.SellStop.SoundModifyTP(sound_tp);
   this.m_data.SellStop.SoundModifyPrice(sound_price);
   this.m_data.SellStop.SoundErrorClose(sound_error);
   this.m_data.SellStop.SoundErrorOpen(sound_error);
   this.m_data.SellStop.SoundErrorModifySL(sound_error);
   this.m_data.SellStop.SoundErrorModifyTP(sound_error);
   this.m_data.SellStop.SoundErrorModifyPrice(sound_error);
   
   this.m_data.SellLimit.UseSoundOpen(use_sound);
   this.m_data.SellLimit.UseSoundClose(use_sound);
   this.m_data.SellLimit.UseSoundModifySL(use_sound);
   this.m_data.SellLimit.UseSoundModifyTP(use_sound);
   this.m_data.SellLimit.UseSoundModifyPrice(use_sound);
   this.m_data.SellLimit.SoundOpen(sound_open);
   this.m_data.SellLimit.SoundClose(sound_close);
   this.m_data.SellLimit.SoundModifySL(sound_sl);
   this.m_data.SellLimit.SoundModifyTP(sound_tp);
   this.m_data.SellLimit.SoundModifyPrice(sound_price);
   this.m_data.SellLimit.SoundErrorClose(sound_error);
   this.m_data.SellLimit.SoundErrorOpen(sound_error);
   this.m_data.SellLimit.SoundErrorModifySL(sound_error);
   this.m_data.SellLimit.SoundErrorModifyTP(sound_error);
   this.m_data.SellLimit.SoundErrorModifyPrice(sound_error);
   
   this.m_data.SellStopLimit.UseSoundOpen(use_sound);
   this.m_data.SellStopLimit.UseSoundClose(use_sound);
   this.m_data.SellStopLimit.UseSoundModifySL(use_sound);
   this.m_data.SellStopLimit.UseSoundModifyTP(use_sound);
   this.m_data.SellStopLimit.UseSoundModifyPrice(use_sound);
   this.m_data.SellStopLimit.SoundOpen(sound_open);
   this.m_data.SellStopLimit.SoundClose(sound_close);
   this.m_data.SellStopLimit.SoundModifySL(sound_sl);
   this.m_data.SellStopLimit.SoundModifyTP(sound_tp);
   this.m_data.SellStopLimit.SoundModifyPrice(sound_price);
   this.m_data.SellStopLimit.SoundErrorClose(sound_error);
   this.m_data.SellStopLimit.SoundErrorOpen(sound_error);
   this.m_data.SellStopLimit.SoundErrorModifySL(sound_error);
   this.m_data.SellStopLimit.SoundErrorModifyTP(sound_error);
   this.m_data.SellStopLimit.SoundErrorModifyPrice(sound_error);
  }  
//+------------------------------------------------------------------+
//| Allow working with sounds and set standard sounds                |
//+------------------------------------------------------------------+
void CTradeObj::SetSoundsStandard(void)
  {
   this.SetUseSound(true);
   this.m_data.Buy.UseSoundClose(true);
   this.m_data.Buy.UseSoundOpen(true);
   this.m_data.Buy.UseSoundModifySL(true);
   this.m_data.Buy.UseSoundModifyTP(true);
   this.m_data.Buy.UseSoundModifyPrice(true);
   this.m_data.Buy.SoundOpen(SND_OK);
   this.m_data.Buy.SoundClose(SND_OK);
   this.m_data.Buy.SoundModifySL(SND_OK);
   this.m_data.Buy.SoundModifyTP(SND_OK);
   this.m_data.Buy.SoundModifyPrice(SND_OK);
   this.m_data.Buy.SoundErrorClose(SND_TIMEOUT);
   this.m_data.Buy.SoundErrorOpen(SND_TIMEOUT);
   this.m_data.Buy.SoundErrorModifySL(SND_TIMEOUT);
   this.m_data.Buy.SoundErrorModifyTP(SND_TIMEOUT);
   this.m_data.Buy.SoundErrorModifyPrice(SND_TIMEOUT);
   
   this.m_data.BuyStop.UseSoundClose(true);
   this.m_data.BuyStop.UseSoundOpen(true);
   this.m_data.BuyStop.UseSoundModifySL(true);
   this.m_data.BuyStop.UseSoundModifyTP(true);
   this.m_data.BuyStop.UseSoundModifyPrice(true);
   this.m_data.BuyStop.SoundOpen(SND_OK);
   this.m_data.BuyStop.SoundClose(SND_OK);
   this.m_data.BuyStop.SoundModifySL(SND_OK);
   this.m_data.BuyStop.SoundModifyTP(SND_OK);
   this.m_data.BuyStop.SoundModifyPrice(SND_OK);
   this.m_data.BuyStop.SoundErrorClose(SND_TIMEOUT);
   this.m_data.BuyStop.SoundErrorOpen(SND_TIMEOUT);
   this.m_data.BuyStop.SoundErrorModifySL(SND_TIMEOUT);
   this.m_data.BuyStop.SoundErrorModifyTP(SND_TIMEOUT);
   this.m_data.BuyStop.SoundErrorModifyPrice(SND_TIMEOUT);
   
   this.m_data.BuyLimit.UseSoundClose(true);
   this.m_data.BuyLimit.UseSoundOpen(true);
   this.m_data.BuyLimit.UseSoundModifySL(true);
   this.m_data.BuyLimit.UseSoundModifyTP(true);
   this.m_data.BuyLimit.UseSoundModifyPrice(true);
   this.m_data.BuyLimit.SoundOpen(SND_OK);
   this.m_data.BuyLimit.SoundClose(SND_OK);
   this.m_data.BuyLimit.SoundModifySL(SND_OK);
   this.m_data.BuyLimit.SoundModifyTP(SND_OK);
   this.m_data.BuyLimit.SoundModifyPrice(SND_OK);
   this.m_data.BuyLimit.SoundErrorClose(SND_TIMEOUT);
   this.m_data.BuyLimit.SoundErrorOpen(SND_TIMEOUT);
   this.m_data.BuyLimit.SoundErrorModifySL(SND_TIMEOUT);
   this.m_data.BuyLimit.SoundErrorModifyTP(SND_TIMEOUT);
   this.m_data.BuyLimit.SoundErrorModifyPrice(SND_TIMEOUT);
   
   this.m_data.BuyStopLimit.UseSoundClose(true);
   this.m_data.BuyStopLimit.UseSoundOpen(true);
   this.m_data.BuyStopLimit.UseSoundModifySL(true);
   this.m_data.BuyStopLimit.UseSoundModifyTP(true);
   this.m_data.BuyStopLimit.UseSoundModifyPrice(true);
   this.m_data.BuyStopLimit.SoundOpen(SND_OK);
   this.m_data.BuyStopLimit.SoundClose(SND_OK);
   this.m_data.BuyStopLimit.SoundModifySL(SND_OK);
   this.m_data.BuyStopLimit.SoundModifyTP(SND_OK);
   this.m_data.BuyStopLimit.SoundModifyPrice(SND_OK);
   this.m_data.BuyStopLimit.SoundErrorClose(SND_TIMEOUT);
   this.m_data.BuyStopLimit.SoundErrorOpen(SND_TIMEOUT);
   this.m_data.BuyStopLimit.SoundErrorModifySL(SND_TIMEOUT);
   this.m_data.BuyStopLimit.SoundErrorModifyTP(SND_TIMEOUT);
   this.m_data.BuyStopLimit.SoundErrorModifyPrice(SND_TIMEOUT);
   
   this.m_data.Sell.UseSoundClose(true);
   this.m_data.Sell.UseSoundOpen(true);
   this.m_data.Sell.UseSoundModifySL(true);
   this.m_data.Sell.UseSoundModifyTP(true);
   this.m_data.Sell.UseSoundModifyPrice(true);
   this.m_data.Sell.SoundOpen(SND_OK);
   this.m_data.Sell.SoundClose(SND_OK);
   this.m_data.Sell.SoundModifySL(SND_OK);
   this.m_data.Sell.SoundModifyTP(SND_OK);
   this.m_data.Sell.SoundModifyPrice(SND_OK);
   this.m_data.Sell.SoundErrorClose(SND_TIMEOUT);
   this.m_data.Sell.SoundErrorOpen(SND_TIMEOUT);
   this.m_data.Sell.SoundErrorModifySL(SND_TIMEOUT);
   this.m_data.Sell.SoundErrorModifyTP(SND_TIMEOUT);
   this.m_data.Sell.SoundErrorModifyPrice(SND_TIMEOUT);
   
   this.m_data.SellStop.UseSoundClose(true);
   this.m_data.SellStop.UseSoundOpen(true);
   this.m_data.SellStop.UseSoundModifySL(true);
   this.m_data.SellStop.UseSoundModifyTP(true);
   this.m_data.SellStop.UseSoundModifyPrice(true);
   this.m_data.SellStop.SoundOpen(SND_OK);
   this.m_data.SellStop.SoundClose(SND_OK);
   this.m_data.SellStop.SoundModifySL(SND_OK);
   this.m_data.SellStop.SoundModifyTP(SND_OK);
   this.m_data.SellStop.SoundModifyPrice(SND_OK);
   this.m_data.SellStop.SoundErrorClose(SND_TIMEOUT);
   this.m_data.SellStop.SoundErrorOpen(SND_TIMEOUT);
   this.m_data.SellStop.SoundErrorModifySL(SND_TIMEOUT);
   this.m_data.SellStop.SoundErrorModifyTP(SND_TIMEOUT);
   this.m_data.SellStop.SoundErrorModifyPrice(SND_TIMEOUT);
   
   this.m_data.SellLimit.UseSoundClose(true);
   this.m_data.SellLimit.UseSoundOpen(true);
   this.m_data.SellLimit.UseSoundModifySL(true);
   this.m_data.SellLimit.UseSoundModifyTP(true);
   this.m_data.SellLimit.UseSoundModifyPrice(true);
   this.m_data.SellLimit.SoundOpen(SND_OK);
   this.m_data.SellLimit.SoundClose(SND_OK);
   this.m_data.SellLimit.SoundModifySL(SND_OK);
   this.m_data.SellLimit.SoundModifyTP(SND_OK);
   this.m_data.SellLimit.SoundModifyPrice(SND_OK);
   this.m_data.SellLimit.SoundErrorClose(SND_TIMEOUT);
   this.m_data.SellLimit.SoundErrorOpen(SND_TIMEOUT);
   this.m_data.SellLimit.SoundErrorModifySL(SND_TIMEOUT);
   this.m_data.SellLimit.SoundErrorModifyTP(SND_TIMEOUT);
   this.m_data.SellLimit.SoundErrorModifyPrice(SND_TIMEOUT);
   
   this.m_data.SellStopLimit.UseSoundClose(true);
   this.m_data.SellStopLimit.UseSoundOpen(true);
   this.m_data.SellStopLimit.UseSoundModifySL(true);
   this.m_data.SellStopLimit.UseSoundModifyTP(true);
   this.m_data.SellStopLimit.UseSoundModifyPrice(true);
   this.m_data.SellStopLimit.SoundOpen(SND_OK);
   this.m_data.SellStopLimit.SoundClose(SND_OK);
   this.m_data.SellStopLimit.SoundModifySL(SND_OK);
   this.m_data.SellStopLimit.SoundModifyTP(SND_OK);
   this.m_data.SellStopLimit.SoundModifyPrice(SND_OK);
   this.m_data.SellStopLimit.SoundErrorClose(SND_TIMEOUT);
   this.m_data.SellStopLimit.SoundErrorOpen(SND_TIMEOUT);
   this.m_data.SellStopLimit.SoundErrorModifySL(SND_TIMEOUT);
   this.m_data.SellStopLimit.SoundErrorModifyTP(SND_TIMEOUT);
   this.m_data.SellStopLimit.SoundErrorModifyPrice(SND_TIMEOUT);
  }
//+------------------------------------------------------------------+
//| Open a position                                                  |
//+------------------------------------------------------------------+
bool CTradeObj::OpenPosition(const ENUM_POSITION_TYPE type,
                             const double volume,
                             const double sl=0,
                             const double tp=0,
                             const ulong magic=ULONG_MAX,
                             const string comment=NULL,
                             const ulong deviation=ULONG_MAX,
                             const ENUM_ORDER_TYPE_FILLING type_filling=WRONG_VALUE)
  {
   if(this.m_program==PROGRAM_INDICATOR || this.m_program==PROGRAM_SERVICE)
      return true;
   ::ResetLastError();
   //--- If failed to get the current prices, write the error code and description, send the message to the journal and return 'false'
    if(!::SymbolInfoTick(this.m_symbol,this.m_tick))
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_NOT_GET_PRICE),CMessage::Text(this.m_result.retcode));
      return false;
     }
   //--- Clear the structures
    ::ZeroMemory(this.m_request);
    ::ZeroMemory(this.m_result);
   //--- Fill in the request structure
    this.m_request.action      =  TRADE_ACTION_DEAL;
    this.m_request.symbol      =  this.m_symbol;
    this.m_request.magic       =  (magic==ULONG_MAX ? this.m_magic : magic);
    this.m_request.type        =  (ENUM_ORDER_TYPE)type;
    this.m_request.price       =  (type==POSITION_TYPE_BUY ? this.m_tick.ask : this.m_tick.bid);
    this.m_request.volume      =  volume;
    this.m_request.sl          =  sl;
    this.m_request.tp          =  tp;
    this.m_request.deviation   =  (deviation==ULONG_MAX ? this.m_deviation : deviation);
    this.m_request.type_filling=  (type_filling>WRONG_VALUE ? type_filling : this.m_type_filling);
    this.m_request.comment     =  (comment==NULL ? this.m_comment : comment);
   //--- Return the result of sending a request to the server
    #ifdef __MQL5__
      return(!this.m_async_mode ? ::OrderSend(this.m_request,this.m_result) : ::OrderSendAsync(this.m_request,this.m_result));
    #else 
      ::ResetLastError();
      int ticket=::OrderSend(m_request.symbol,m_request.type,m_request.volume,m_request.price,(int)m_request.deviation,m_request.sl,m_request.tp,m_request.comment,(int)m_request.magic,m_request.expiration,clrNONE);
      this.m_result.retcode=::GetLastError();
      ::SymbolInfoTick(this.m_symbol,this.m_tick);
      this.m_result.ask=this.m_tick.ask;
      this.m_result.bid=this.m_tick.bid;
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(ticket!=WRONG_VALUE)
        {
          this.m_result.deal=ticket;
          this.m_result.price=(::OrderSelect(ticket,SELECT_BY_TICKET) ? ::OrderOpenPrice() : this.m_request.price);
          this.m_result.volume=(::OrderSelect(ticket,SELECT_BY_TICKET) ? ::OrderLots() : this.m_request.volume);
          return true;
        }
      else
       {
         return false;
        }
    #endif 
  }
//+------------------------------------------------------------------+
//| Close a position                                                 |
//+------------------------------------------------------------------+
bool CTradeObj::ClosePosition(const ulong ticket,
                              const string comment=NULL,
                              const ulong deviation=ULONG_MAX)
  {
   if(this.m_program==PROGRAM_INDICATOR || this.m_program==PROGRAM_SERVICE)
      return true;
    ::ResetLastError();
   //--- If failed to select a position. Write the error code and description, send the message to the journal and return 'false'
    if(!::PositionSelectByTicket(ticket))
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,"#",(string)ticket,": ",CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_SELECT_POS),CMessage::Text(this.m_result.retcode));
      return false;
     }
   //--- If failed to get the current prices, write the error code and description, send the message to the journal and return 'false'
    if(!::SymbolInfoTick(this.m_symbol,this.m_tick))
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_NOT_GET_PRICE),CMessage::Text(this.m_result.retcode));
      return false;
     }
   //--- Get a position type and an order type inverse of the position type
    ENUM_POSITION_TYPE position_type=(ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE);
    ENUM_ORDER_TYPE type=OrderTypeOppositeByPositionType(position_type);
   //--- Clear the structures
    ::ZeroMemory(this.m_request);
    ::ZeroMemory(this.m_result);
   //--- Fill in the request structure
    this.m_request.action      =  TRADE_ACTION_DEAL;
    this.m_request.symbol      =  this.m_symbol;
    this.m_request.type        =  type;
    this.m_request.magic       =  ::PositionGetInteger(POSITION_MAGIC);
    this.m_request.price       =  (position_type==POSITION_TYPE_SELL ? this.m_tick.ask : this.m_tick.bid);
    this.m_request.volume      =  ::PositionGetDouble(POSITION_VOLUME);
    this.m_request.deviation   =  (deviation==ULONG_MAX ? this.m_deviation : deviation);
    this.m_request.comment     =  (comment==NULL ? this.m_comment : comment);
    this.m_request.type_filling=  this.m_type_filling;
   //--- In case of a hedging account, write the ticket of a closed position to the structure
    if(this.IsHedge())
      this.m_request.position=::PositionGetInteger(POSITION_TICKET);
   //--- Return the result of sending a request to the server
    #ifdef __MQL5__
      return(!this.m_async_mode ? ::OrderSend(this.m_request,this.m_result) : ::OrderSendAsync(this.m_request,this.m_result));
    #else 
      ::SymbolInfoTick(this.m_symbol,this.m_tick);
      this.m_result.ask=this.m_tick.ask;
      this.m_result.bid=this.m_tick.bid;
      ::ResetLastError();
     if(::OrderClose((int)this.m_request.position,this.m_request.volume,this.m_request.price,(int)this.m_request.deviation,clrNONE))
      {
       this.m_result.retcode=::GetLastError();
       this.m_result.deal=ticket;
       this.m_result.price=(::OrderSelect((int)ticket,SELECT_BY_TICKET) ? ::OrderClosePrice() : this.m_request.price);
       this.m_result.volume=(::OrderSelect((int)ticket,SELECT_BY_TICKET) ? ::OrderLots() : this.m_request.volume);
       this.m_result.comment=CMessage::Text(this.m_result.retcode);
       return true;
      }
     else
      {
       this.m_result.retcode=::GetLastError();
       this.m_result.ask=this.m_tick.ask;
       this.m_result.bid=this.m_tick.bid;
       this.m_result.comment=CMessage::Text(this.m_result.retcode);
       return false;
      }
    #endif 
  }
//+------------------------------------------------------------------+
//| Close a position partially                                       |
//+------------------------------------------------------------------+
bool CTradeObj::ClosePositionPartially(const ulong ticket,
                                       const double volume,
                                       const string comment=NULL,
                                       const ulong deviation=ULONG_MAX)
  {
   if(this.m_program==PROGRAM_INDICATOR || this.m_program==PROGRAM_SERVICE)
      return true;
   ::ResetLastError();
   //--- If failed to select a position. Write the error code and description, send the message to the journal and return 'false'
    if(!::PositionSelectByTicket(ticket))
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,"#",(string)ticket,": ",CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_SELECT_POS),CMessage::Text(this.m_result.retcode));
      return false;
     }
   //--- If failed to get the current prices, write the error code and description, send the message to the journal and return 'false'
    if(!::SymbolInfoTick(this.m_symbol,this.m_tick))
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_NOT_GET_PRICE),CMessage::Text(this.m_result.retcode));
      return false;
     }
   //--- Get a position type and an order type inverse of the position type
    ENUM_POSITION_TYPE position_type=(ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE);
    ENUM_ORDER_TYPE type=OrderTypeOppositeByPositionType(position_type);
   //--- Get a position volume
    double position_volume=::PositionGetDouble(POSITION_VOLUME);
   //--- Clear the structures
    ::ZeroMemory(this.m_request);
    ::ZeroMemory(this.m_result);
   //--- Fill in the request structure
    this.m_request.action      =  TRADE_ACTION_DEAL;
    this.m_request.position    =  ticket;
    this.m_request.symbol      =  this.m_symbol;
    this.m_request.magic       =  ::PositionGetInteger(POSITION_MAGIC);
    this.m_request.type        =  type;
    this.m_request.price       =  (position_type==POSITION_TYPE_SELL ? this.m_tick.ask : this.m_tick.bid);
    this.m_request.volume      =  (volume<position_volume ? volume : position_volume);
    this.m_request.deviation   =  (deviation==ULONG_MAX ? this.m_deviation : deviation);
    this.m_request.comment     =  (comment==NULL ? this.m_comment : comment);
    this.m_request.type_filling=  this.m_type_filling;
   //--- In case of a hedging account, write the ticket of a closed position to the structure
    if(this.IsHedge())
      this.m_request.position=::PositionGetInteger(POSITION_TICKET);
   //--- Return the result of sending a request to the server
   #ifdef __MQL5__
     return(!this.m_async_mode ? ::OrderSend(this.m_request,this.m_result) : ::OrderSendAsync(this.m_request,this.m_result));
   #else 
    ::SymbolInfoTick(this.m_symbol,this.m_tick);
    this.m_result.ask=this.m_tick.ask;
    this.m_result.bid=this.m_tick.bid;
     ::ResetLastError();
    if(::OrderClose((int)this.m_request.position,this.m_request.volume,this.m_request.price,(int)this.m_request.deviation,clrNONE))
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.deal=ticket;
      this.m_result.price=(::OrderSelect((int)ticket,SELECT_BY_TICKET) ? ::OrderClosePrice() : this.m_request.price);
      this.m_result.volume=(::OrderSelect((int)ticket,SELECT_BY_TICKET) ? ::OrderLots() : this.m_request.volume);
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      return true;
     }
    else
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      return false;
     }
   #endif 
  }
//+------------------------------------------------------------------+
//| Close a position by an opposite one                              |
//+------------------------------------------------------------------+
bool CTradeObj::ClosePositionBy(const ulong ticket,const ulong ticket_by)
  {
   if(this.m_program==PROGRAM_INDICATOR || this.m_program==PROGRAM_SERVICE)
      return true;
    ::ResetLastError();
   //--- Closed position
   //--- If failed to select a position, write the error code and description, send the message to the journal and return 'false'
    if(!::PositionSelectByTicket(ticket))
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,"#",(string)ticket,": ",CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_SELECT_POS),CMessage::Text(this.m_result.retcode));
      return false;
     }
   //--- Get a type and magic of a closed position
    ENUM_POSITION_TYPE position_type=(ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE);
    ulong magic=::PositionGetInteger(POSITION_MAGIC);
   
   //--- Opposite position
   //--- If failed to select a position, write the error code and description, send the message to the journal and return 'false'
    if(!::PositionSelectByTicket(ticket_by))
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,"#",(string)ticket_by,": ",CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_SELECT_POS),CMessage::Text(this.m_result.retcode));
      return false;
     }
   //--- Get an opposite position type
    ENUM_POSITION_TYPE position_type_by=(ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE);
   //--- If types of a closed and an opposite position match, write the error code and description, send the message to the journal and return 'false'
    if(position_type==position_type_by)
     {
      this.m_result.retcode=MSG_ACC_SAME_TYPE_CLOSE_BY;
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,CMessage::Text(MSG_ACC_SAME_TYPE_CLOSE_BY));
      return false;
     }
   //--- Clear the structures
    ::ZeroMemory(this.m_request);
    ::ZeroMemory(this.m_result);
   //--- Fill in the request structure
    this.m_request.action      =  TRADE_ACTION_CLOSE_BY;
    this.m_request.position    =  ticket;
    this.m_request.position_by =  ticket_by;
    this.m_request.magic       =  magic;
   //--- Return the result of sending a request to the server
    #ifdef __MQL5__
      return(!this.m_async_mode ? ::OrderSend(this.m_request,this.m_result) : ::OrderSendAsync(this.m_request,this.m_result));
    #else 
     ::SymbolInfoTick(this.m_symbol,this.m_tick);
     this.m_result.ask=this.m_tick.ask;
     this.m_result.bid=this.m_tick.bid;
     ::ResetLastError();
     if(::OrderCloseBy((int)this.m_request.position,(int)this.m_request.position_by,clrNONE))
      {
       this.m_result.retcode=::GetLastError();
       this.m_result.deal=ticket;
      this.m_result.order=ticket_by;
      this.m_result.price=(::OrderSelect((int)ticket,SELECT_BY_TICKET) ? ::OrderClosePrice() : this.m_request.price);
      this.m_result.volume=(::OrderSelect((int)ticket,SELECT_BY_TICKET) ? ::OrderLots() : this.m_request.volume);
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      return true;
     }
   else
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      return false;
     }
#endif 
  }
//+------------------------------------------------------------------+
//| Modify a position                                                |
//+------------------------------------------------------------------+
bool CTradeObj::ModifyPosition(const ulong ticket,const double sl=WRONG_VALUE,const double tp=WRONG_VALUE)
  {
   if(this.m_program==PROGRAM_INDICATOR || this.m_program==PROGRAM_SERVICE)
      return true;
   ::ResetLastError();
   //--- If all default values are passed, there is nothing to be modified
   if(sl==WRONG_VALUE && tp==WRONG_VALUE)
     {
      //--- There are no changes in the request - write the error code and description, send the message to the journal and return 'false'
      this.m_result.retcode= #ifdef __MQL5__ TRADE_RETCODE_NO_CHANGES #else 10025 #endif ;
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,CMessage::Text(this.m_result.retcode),CMessage::Retcode(this.m_result.retcode));
      return false;
     }
   //--- If failed to select a position, write the error code and description, send the message to the journal and return 'false'
   if(!::PositionSelectByTicket(ticket))
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,"#",(string)ticket,": ",CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_SELECT_POS),CMessage::Text(this.m_result.retcode));
      return false;
     }
   //--- Clear the structures
   ::ZeroMemory(this.m_request);
   ::ZeroMemory(this.m_result);
   //--- Fill in the request structure
   this.m_request.action   =  TRADE_ACTION_SLTP;
   this.m_request.position =  ticket;
   this.m_request.symbol   =  this.m_symbol;
   this.m_request.magic    =  ::PositionGetInteger(POSITION_MAGIC);
   this.m_request.sl       =  (sl==WRONG_VALUE ? ::PositionGetDouble(POSITION_SL) : sl);
   this.m_request.tp       =  (tp==WRONG_VALUE ? ::PositionGetDouble(POSITION_TP) : tp);
   //--- Return the result of sending a request to the server
#ifdef __MQL5__
   return(!this.m_async_mode ? ::OrderSend(this.m_request,this.m_result) : ::OrderSendAsync(this.m_request,this.m_result));
#else 
   ::SymbolInfoTick(this.m_symbol,this.m_tick);
   this.m_result.ask=this.m_tick.ask;
   this.m_result.bid=this.m_tick.bid;
   ::ResetLastError();
   if(::OrderModify((int)this.m_request.position,::OrderOpenPrice(),this.m_request.sl,this.m_request.tp,::OrderExpiration(),clrNONE))
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.deal=ticket;
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      return true;
     }
   else
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      return false;
     }
#endif 
  }
//+------------------------------------------------------------------+
//| Place an order                                                   |
//+------------------------------------------------------------------+
bool CTradeObj::SetOrder(const ENUM_ORDER_TYPE type,
                         const double volume,
                         const double price,
                         const double sl=0,
                         const double tp=0,
                         const double price_stoplimit=0,
                         const ulong magic=ULONG_MAX,
                         const string comment=NULL,
                         const datetime expiration=0,
                         const ENUM_ORDER_TYPE_TIME type_time=WRONG_VALUE,
                         const ENUM_ORDER_TYPE_FILLING type_filling=WRONG_VALUE)
  {
   if(this.m_program==PROGRAM_INDICATOR || this.m_program==PROGRAM_SERVICE)
      return true;
   ::ResetLastError();
   //--- If an invalid order type has been passed, write the error code and description, send the message to the journal and return 'false'
   if(type==ORDER_TYPE_BUY || type==ORDER_TYPE_SELL || type==ORDER_TYPE_CLOSE_BY 
      #ifdef __MQL4__ || type==ORDER_TYPE_BUY_STOP_LIMIT || type==ORDER_TYPE_SELL_STOP_LIMIT #endif )
     {
      this.m_result.retcode=MSG_LIB_SYS_INVALID_ORDER_TYPE;
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_INVALID_ORDER_TYPE),OrderTypeDescription(type));
      return false;
     }
   //--- Clear the structures
   ::ZeroMemory(this.m_request);
   ::ZeroMemory(this.m_result);
   //--- Fill in the request structure
   this.m_request.action      =  TRADE_ACTION_PENDING;
   this.m_request.symbol      =  this.m_symbol;
   this.m_request.magic       =  (magic==ULONG_MAX ? this.m_magic : magic);
   this.m_request.volume      =  volume;
   this.m_request.type        =  type;
   this.m_request.stoplimit   =  price_stoplimit;
   this.m_request.price       =  price;
   this.m_request.sl          =  sl;
   this.m_request.tp          =  tp;
   this.m_request.expiration  =  expiration;
   this.m_request.type_time   =  (type_time>WRONG_VALUE ? type_time : this.m_type_time);
   this.m_request.type_filling=  (type_filling>WRONG_VALUE ? type_filling : this.m_type_filling);
   this.m_request.comment     =  (comment==NULL ? this.m_comment : comment);
   //--- Return the result of sending a request to the server
#ifdef __MQL5__
   return(!this.m_async_mode ? ::OrderSend(this.m_request,this.m_result) : ::OrderSendAsync(this.m_request,this.m_result));
#else 
   ::ResetLastError();
   int ticket=::OrderSend(this.m_request.symbol,
                          this.m_request.type,
                          this.m_request.volume,
                          this.m_request.price,
                          (int)this.m_request.deviation,
                          this.m_request.sl,
                          this.m_request.tp,
                          this.m_request.comment,
                          (int)this.m_request.magic,
                          this.m_request.expiration,
                          clrNONE);
   this.m_result.retcode=::GetLastError();
   this.m_result.comment=CMessage::Text(this.m_result.retcode);
   ::SymbolInfoTick(this.m_symbol,this.m_tick);
   this.m_result.ask=this.m_tick.ask;
   this.m_result.bid=this.m_tick.bid;
   if(ticket!=WRONG_VALUE)
     {
      this.m_result.order=ticket;
      this.m_result.price=(::OrderSelect(ticket,SELECT_BY_TICKET) ? ::OrderOpenPrice() : this.m_request.price);
      this.m_result.volume=(::OrderSelect(ticket,SELECT_BY_TICKET) ? ::OrderLots() : this.m_request.volume);
      return true;
     }
   else
     {
      return false;
     }
#endif 
  }
//+------------------------------------------------------------------+
//| Remove an order                                                  |
//+------------------------------------------------------------------+
bool CTradeObj::DeleteOrder(const ulong ticket)
  {
   if(this.m_program==PROGRAM_INDICATOR || this.m_program==PROGRAM_SERVICE)
      return true;
   ::ResetLastError();
   //--- Clear the structures
   ::ZeroMemory(this.m_request);
   ::ZeroMemory(this.m_result);
   //--- Fill in the request structure
   this.m_request.action   =  TRADE_ACTION_REMOVE;
   this.m_request.order    =  ticket;
   //--- Return the result of sending a request to the server
#ifdef __MQL5__
   return(!this.m_async_mode ? ::OrderSend(this.m_request,this.m_result) : ::OrderSendAsync(this.m_request,this.m_result));
#else 
   ::SymbolInfoTick(this.m_symbol,this.m_tick);
   this.m_result.ask=this.m_tick.ask;
   this.m_result.bid=this.m_tick.bid;
   ::ResetLastError();
   if(::OrderDelete((int)this.m_request.order,clrNONE))
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.order=ticket;
      this.m_result.price=(::OrderSelect((int)ticket,SELECT_BY_TICKET) ? ::OrderClosePrice() : this.m_request.price);
      this.m_result.volume=(::OrderSelect((int)ticket,SELECT_BY_TICKET) ? ::OrderLots() : this.m_request.volume);
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      return true;
     }
   else
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      return false;
     }
#endif 
  }
//+------------------------------------------------------------------+
//| Modify an order                                                  |
//+------------------------------------------------------------------+
bool CTradeObj::ModifyOrder(const ulong ticket,
                            const double price=WRONG_VALUE,
                            const double sl=WRONG_VALUE,
                            const double tp=WRONG_VALUE,
                            const double price_stoplimit=WRONG_VALUE,
                            const datetime expiration=WRONG_VALUE,
                            const ENUM_ORDER_TYPE_TIME type_time=WRONG_VALUE,
                            const ENUM_ORDER_TYPE_FILLING type_filling=WRONG_VALUE)
  {
   if(this.m_program==PROGRAM_INDICATOR || this.m_program==PROGRAM_SERVICE)
      return true;
   ::ResetLastError();
   //--- If failed to select an order, write the error code and description, send the message to the journal and return 'false'
   if(#ifdef __MQL5__ !::OrderSelect(ticket) #else !::OrderSelect((int)ticket,SELECT_BY_TICKET) #endif)
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,"#",(string)ticket,": ",CMessage::Text(MSG_LIB_SYS_ERROR_FAILED_SELECT_ORD),CMessage::Text(this.m_result.retcode));
      return false;
     }
   double order_price=::OrderGetDouble(ORDER_PRICE_OPEN);
   double order_sl=::OrderGetDouble(ORDER_SL);
   double order_tp=::OrderGetDouble(ORDER_TP);
   double order_stoplimit=::OrderGetDouble(ORDER_PRICE_STOPLIMIT);
   ENUM_ORDER_TYPE_TIME order_type_time=(ENUM_ORDER_TYPE_TIME)::OrderGetInteger(ORDER_TYPE_TIME);
   ENUM_ORDER_TYPE_FILLING order_type_filling=(ENUM_ORDER_TYPE_FILLING)::OrderGetInteger(ORDER_TYPE_FILLING);
   datetime order_expiration=(datetime)::OrderGetInteger(ORDER_TIME_EXPIRATION);
   //--- If the default values are passed and the price is equal to the price set in the order, the request is unchanged
   //---Write the error code and description, send the message to the journal and return 'false'
   if(price==order_price && sl==WRONG_VALUE && tp==WRONG_VALUE && price_stoplimit==WRONG_VALUE && type_time==WRONG_VALUE && expiration==WRONG_VALUE)
     {
      this.m_result.retcode = #ifdef __MQL5__ TRADE_RETCODE_NO_CHANGES #else 10025 #endif ;
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,CMessage::Text(this.m_result.retcode),CMessage::Retcode(this.m_result.retcode));
      return false;
     }
   //--- Clear the structures
   ::ZeroMemory(this.m_request);
   ::ZeroMemory(this.m_result);
   //--- Fill in the request structure
   this.m_request.action      =  TRADE_ACTION_MODIFY;
   this.m_request.order       =  ticket;
   this.m_request.price       =  (price==WRONG_VALUE ? order_price : price);
   this.m_request.sl          =  (sl==WRONG_VALUE ? order_sl : sl);
   this.m_request.tp          =  (tp==WRONG_VALUE ? order_tp : tp);
   this.m_request.stoplimit   =  (price_stoplimit==WRONG_VALUE ? order_stoplimit : price_stoplimit);
   this.m_request.type_time   =  (type_time==WRONG_VALUE ? order_type_time : type_time);
   this.m_request.type_filling=  (type_filling==WRONG_VALUE ? order_type_filling : type_filling);
   this.m_request.expiration  =  (expiration==WRONG_VALUE ? order_expiration : expiration);
   //--- Return an order modification result
#ifdef __MQL5__
   return(!this.m_async_mode ? ::OrderSend(this.m_request,this.m_result) : ::OrderSendAsync(this.m_request,this.m_result));
#else 
   ::SymbolInfoTick(this.m_symbol,this.m_tick);
   this.m_result.ask=this.m_tick.ask;
   this.m_result.bid=this.m_tick.bid;
   ::ResetLastError();
   if(::OrderModify((int)this.m_request.order,this.m_request.price,this.m_request.sl,this.m_request.tp,this.m_request.expiration,clrNONE))
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.order=ticket;
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      return true;
     }
   else
     {
      this.m_result.retcode=::GetLastError();
      this.m_result.comment=CMessage::Text(this.m_result.retcode);
      return false;
     }
#endif 
  }
//+------------------------------------------------------------------+
//| Set the flag of using sounds                                     |
//| of opening/placing a specified position/order type               |
//+------------------------------------------------------------------+
void CTradeObj::UseSoundOpen(const int action,const bool flag)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   this.m_data.Buy.UseSoundOpen(flag);           break;
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.UseSoundOpen(flag);       break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.UseSoundOpen(flag);      break;
      case ORDER_TYPE_SELL             :   this.m_data.Sell.UseSoundOpen(flag);          break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.UseSoundOpen(flag);      break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.UseSoundOpen(flag);     break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.UseSoundOpen(flag);  break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.UseSoundOpen(flag); break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Set the flag of using a sound                                    |
//| of closing/removal of a specified position/order type            |
//+------------------------------------------------------------------+
void CTradeObj::UseSoundClose(const int action,const bool flag)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   this.m_data.Buy.UseSoundClose(flag);             break;
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.UseSoundClose(flag);         break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.UseSoundClose(flag);        break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.UseSoundClose(flag);    break;
      case ORDER_TYPE_SELL             :   this.m_data.Sell.UseSoundClose(flag);            break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.UseSoundClose(flag);        break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.UseSoundClose(flag);       break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.UseSoundClose(flag);   break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Set the flag of using a sound                                    |
//| of StopLoss modification for a specified position/order type     |
//+------------------------------------------------------------------+
void CTradeObj::UseSoundModifySL(const int action,const bool flag)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   this.m_data.Buy.UseSoundModifySL(flag);             break;
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.UseSoundModifySL(flag);         break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.UseSoundModifySL(flag);        break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.UseSoundModifySL(flag);    break;
      case ORDER_TYPE_SELL             :   this.m_data.Sell.UseSoundModifySL(flag);            break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.UseSoundModifySL(flag);        break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.UseSoundModifySL(flag);       break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.UseSoundModifySL(flag);   break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Set the flag of using a sound                                    |
//| of TakeProfit modification for a specified position/order type   |
//+------------------------------------------------------------------+
void CTradeObj::UseSoundModifyTP(const int action,const bool flag)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   this.m_data.Buy.UseSoundModifyTP(flag);             break;
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.UseSoundModifyTP(flag);         break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.UseSoundModifyTP(flag);        break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.UseSoundModifyTP(flag);    break;
      case ORDER_TYPE_SELL             :   this.m_data.Sell.UseSoundModifyTP(flag);            break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.UseSoundModifyTP(flag);        break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.UseSoundModifyTP(flag);       break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.UseSoundModifyTP(flag);   break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Set the flag of using a modification sound                       |
//| of the placement price for a specified order type                |
//+------------------------------------------------------------------+
void CTradeObj::UseSoundModifyPrice(const int action,const bool flag)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.UseSoundModifyPrice(flag);         break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.UseSoundModifyPrice(flag);        break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.UseSoundModifyPrice(flag);    break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.UseSoundModifyPrice(flag);        break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.UseSoundModifyPrice(flag);       break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.UseSoundModifyPrice(flag);   break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Return the flag of using the sound of opening/placing            |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
bool CTradeObj::UseSoundOpen(const int action) const
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   return this.m_data.Buy.UseSoundOpen();
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.UseSoundOpen();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.UseSoundOpen();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.UseSoundOpen();
      case ORDER_TYPE_SELL             :   return this.m_data.Sell.UseSoundOpen();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.UseSoundOpen();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.UseSoundOpen();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.UseSoundOpen();
      default: return false;
     }
  }
//+------------------------------------------------------------------+
//| Return the flag of using the sound of closing/removal of         |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
bool CTradeObj::UseSoundClose(const int action) const
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   return this.m_data.Buy.UseSoundClose();
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.UseSoundClose();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.UseSoundClose();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.UseSoundClose();
      case ORDER_TYPE_SELL             :   return this.m_data.Sell.UseSoundClose();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.UseSoundClose();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.UseSoundClose();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.UseSoundClose();
      default: return false;
     }
  }
//+------------------------------------------------------------------+
//| Return the flag of using a sound                                 |
//| of StopLoss modification for a specified position/order type     |
//+------------------------------------------------------------------+
bool CTradeObj::UseSoundModifySL(const int action) const
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   return this.m_data.Buy.UseSoundModifySL();
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.UseSoundModifySL();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.UseSoundModifySL();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.UseSoundModifySL();
      case ORDER_TYPE_SELL             :   return this.m_data.Sell.UseSoundModifySL();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.UseSoundModifySL();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.UseSoundModifySL();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.UseSoundModifySL();
      default: return false;
     }
  }
//+------------------------------------------------------------------+
//| Return the flag of using a sound                                 |
//| of TakeProfit modification for a specified position/order type   |
//+------------------------------------------------------------------+
bool CTradeObj::UseSoundModifyTP(const int action) const
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   return this.m_data.Buy.UseSoundModifyTP();
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.UseSoundModifyTP();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.UseSoundModifyTP();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.UseSoundModifyTP();
      case ORDER_TYPE_SELL             :   return this.m_data.Sell.UseSoundModifyTP();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.UseSoundModifyTP();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.UseSoundModifyTP();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.UseSoundModifyTP();
      default: return false;
     }
  }
//+------------------------------------------------------------------+
//| Return the flag of using a modification sound                    |
//| of the placement price for a specified order type                |
//+------------------------------------------------------------------+
bool CTradeObj::UseSoundModifyPrice(const int action) const
  {
   switch(action)
     {
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.UseSoundModifyPrice();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.UseSoundModifyPrice();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.UseSoundModifyPrice();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.UseSoundModifyPrice();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.UseSoundModifyPrice();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.UseSoundModifyPrice();
      default: return false;
     }
  }
//+------------------------------------------------------------------+
//| Set the sound of opening/placing                                 |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::SetSoundOpen(const ENUM_ORDER_TYPE action,const string sound)
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   this.m_data.Buy.SoundOpen(sound);             break;
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.SoundOpen(sound);         break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.SoundOpen(sound);        break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.SoundOpen(sound);    break;
      case ORDER_TYPE_SELL             :   this.m_data.Sell.SoundOpen(sound);            break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.SoundOpen(sound);        break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.SoundOpen(sound);       break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.SoundOpen(sound);   break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Set the sound of closing/removal of                              |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::SetSoundClose(const ENUM_ORDER_TYPE action,const string sound)
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   this.m_data.Buy.SoundClose(sound);            break;
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.SoundClose(sound);        break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.SoundClose(sound);       break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.SoundClose(sound);   break;
      case ORDER_TYPE_SELL             :   this.m_data.Sell.SoundClose(sound);           break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.SoundClose(sound);       break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.SoundClose(sound);      break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.SoundClose(sound);  break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Set StopLoss modification sound of                               |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::SetSoundModifySL(const ENUM_ORDER_TYPE action,const string sound)
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   this.m_data.Buy.SoundModifySL(sound);            break;
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.SoundModifySL(sound);        break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.SoundModifySL(sound);       break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.SoundModifySL(sound);   break;
      case ORDER_TYPE_SELL             :   this.m_data.Sell.SoundModifySL(sound);           break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.SoundModifySL(sound);       break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.SoundModifySL(sound);      break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.SoundModifySL(sound);  break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Set TakeProfit modification sound of                             |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::SetSoundModifyTP(const ENUM_ORDER_TYPE action,const string sound)
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   this.m_data.Buy.SoundModifyTP(sound);            break;
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.SoundModifyTP(sound);        break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.SoundModifyTP(sound);       break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.SoundModifyTP(sound);   break;
      case ORDER_TYPE_SELL             :   this.m_data.Sell.SoundModifyTP(sound);           break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.SoundModifyTP(sound);       break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.SoundModifyTP(sound);      break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.SoundModifyTP(sound);  break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Set price modification sound                                     |
//| for a specified order type                                       |
//+------------------------------------------------------------------+
void CTradeObj::SetSoundModifyPrice(const ENUM_ORDER_TYPE action,const string sound)
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.SoundModifyPrice(sound);        break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.SoundModifyPrice(sound);       break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.SoundModifyPrice(sound);   break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.SoundModifyPrice(sound);       break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.SoundModifyPrice(sound);      break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.SoundModifyPrice(sound);  break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Set the error sound of opening/placing                           |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::SetSoundErrorOpen(const ENUM_ORDER_TYPE action,const string sound)
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   this.m_data.Buy.SoundErrorOpen(sound);             break;
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.SoundErrorOpen(sound);         break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.SoundErrorOpen(sound);        break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.SoundErrorOpen(sound);    break;
      case ORDER_TYPE_SELL             :   this.m_data.Sell.SoundErrorOpen(sound);            break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.SoundErrorOpen(sound);        break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.SoundErrorOpen(sound);       break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.SoundErrorOpen(sound);   break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Set the error sound of closing/removal of                        |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::SetSoundErrorClose(const ENUM_ORDER_TYPE action,const string sound)
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   this.m_data.Buy.SoundErrorClose(sound);            break;
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.SoundErrorClose(sound);        break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.SoundErrorClose(sound);       break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.SoundErrorClose(sound);   break;
      case ORDER_TYPE_SELL             :   this.m_data.Sell.SoundErrorClose(sound);           break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.SoundErrorClose(sound);       break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.SoundErrorClose(sound);      break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.SoundErrorClose(sound);  break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Set StopLoss modification error sound of                         |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::SetSoundErrorModifySL(const ENUM_ORDER_TYPE action,const string sound)
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   this.m_data.Buy.SoundErrorModifySL(sound);            break;
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.SoundErrorModifySL(sound);        break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.SoundErrorModifySL(sound);       break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.SoundErrorModifySL(sound);   break;
      case ORDER_TYPE_SELL             :   this.m_data.Sell.SoundErrorModifySL(sound);           break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.SoundErrorModifySL(sound);       break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.SoundErrorModifySL(sound);      break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.SoundErrorModifySL(sound);  break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Set TakeProfit modification error sound of                       |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::SetSoundErrorModifyTP(const ENUM_ORDER_TYPE action,const string sound)
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   this.m_data.Buy.SoundErrorModifyTP(sound);            break;
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.SoundErrorModifyTP(sound);        break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.SoundErrorModifyTP(sound);       break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.SoundErrorModifyTP(sound);   break;
      case ORDER_TYPE_SELL             :   this.m_data.Sell.SoundErrorModifyTP(sound);           break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.SoundErrorModifyTP(sound);       break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.SoundErrorModifyTP(sound);      break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.SoundErrorModifyTP(sound);  break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Set price modification error sound                               |
//| for a specified order type                                       |
//+------------------------------------------------------------------+
void CTradeObj::SetSoundErrorModifyPrice(const ENUM_ORDER_TYPE action,const string sound)
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY_STOP         :   this.m_data.BuyStop.SoundErrorModifyPrice(sound);        break;
      case ORDER_TYPE_BUY_LIMIT        :   this.m_data.BuyLimit.SoundErrorModifyPrice(sound);       break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   this.m_data.BuyStopLimit.SoundErrorModifyPrice(sound);   break;
      case ORDER_TYPE_SELL_STOP        :   this.m_data.SellStop.SoundErrorModifyPrice(sound);       break;
      case ORDER_TYPE_SELL_LIMIT       :   this.m_data.SellLimit.SoundErrorModifyPrice(sound);      break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   this.m_data.SellStopLimit.SoundErrorModifyPrice(sound);  break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Return the sound of opening/placing                              |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
string CTradeObj::GetSoundOpen(const ENUM_ORDER_TYPE action) const
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   return this.m_data.Buy.SoundOpen();
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.SoundOpen();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.SoundOpen();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.SoundOpen();
      case ORDER_TYPE_SELL             :   return this.m_data.Sell.SoundOpen();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.SoundOpen();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.SoundOpen();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.SoundOpen();
      default: return NULL;
     }
  }
//+------------------------------------------------------------------+
//| Return the sound of closing/removal of                           |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
string CTradeObj::GetSoundClose(const ENUM_ORDER_TYPE action) const
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   return this.m_data.Buy.SoundClose();
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.SoundClose();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.SoundClose();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.SoundClose();
      case ORDER_TYPE_SELL             :   return this.m_data.Sell.SoundClose();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.SoundClose();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.SoundClose();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.SoundClose();
      default: return NULL;
     }
  }
//+------------------------------------------------------------------+
//| Return StopLoss modification sound of                            |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
string CTradeObj::GetSoundModifySL(const ENUM_ORDER_TYPE action) const
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   return this.m_data.Buy.SoundModifySL();
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.SoundModifySL();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.SoundModifySL();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.SoundModifySL();
      case ORDER_TYPE_SELL             :   return this.m_data.Sell.SoundModifySL();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.SoundModifySL();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.SoundModifySL();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.SoundModifySL();
      default: return NULL;
     }
  }
//+------------------------------------------------------------------+
//| Return TakeProfit modification sound of                          |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
string CTradeObj::GetSoundModifyTP(const ENUM_ORDER_TYPE action) const
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   return this.m_data.Buy.SoundModifyTP();
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.SoundModifyTP();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.SoundModifyTP();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.SoundModifyTP();
      case ORDER_TYPE_SELL             :   return this.m_data.Sell.SoundModifyTP();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.SoundModifyTP();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.SoundModifyTP();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.SoundModifyTP();
      default: return NULL;
     }
  }
//+------------------------------------------------------------------+
//| Return price modification sound                                  |
//| for a specified order type                                       |
//+------------------------------------------------------------------+
string CTradeObj::GetSoundModifyPrice(const ENUM_ORDER_TYPE action) const
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.SoundModifyPrice();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.SoundModifyPrice();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.SoundModifyPrice();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.SoundModifyPrice();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.SoundModifyPrice();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.SoundModifyPrice();
      default: return NULL;
     }
  }
//+------------------------------------------------------------------+
//| Return the error sound of opening/placing                        |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
string CTradeObj::GetSoundErrorOpen(const ENUM_ORDER_TYPE action) const
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   return this.m_data.Buy.SoundErrorOpen();
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.SoundErrorOpen();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.SoundErrorOpen();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.SoundErrorOpen();
      case ORDER_TYPE_SELL             :   return this.m_data.Sell.SoundErrorOpen();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.SoundErrorOpen();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.SoundErrorOpen();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.SoundErrorOpen();
      default: return NULL;
     }
  }
//+------------------------------------------------------------------+
//| Return the error sound of closing/removal of                     |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
string CTradeObj::GetSoundErrorClose(const ENUM_ORDER_TYPE action) const
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   return this.m_data.Buy.SoundErrorClose();
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.SoundErrorClose();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.SoundErrorClose();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.SoundErrorClose();
      case ORDER_TYPE_SELL             :   return this.m_data.Sell.SoundErrorClose();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.SoundErrorClose();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.SoundErrorClose();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.SoundErrorClose();
      default: return NULL;
     }
  }
//+------------------------------------------------------------------+
//| Return StopLoss modification error sound of                      |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
string CTradeObj::GetSoundErrorModifySL(const ENUM_ORDER_TYPE action) const
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   return this.m_data.Buy.SoundErrorModifySL();
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.SoundErrorModifySL();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.SoundErrorModifySL();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.SoundErrorModifySL();
      case ORDER_TYPE_SELL             :   return this.m_data.Sell.SoundErrorModifySL();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.SoundErrorModifySL();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.SoundErrorModifySL();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.SoundErrorModifySL();
      default: return NULL;
     }
  }
//+------------------------------------------------------------------+
//| Return TakeProfit modification error sound of                    |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
string CTradeObj::GetSoundErrorModifyTP(const ENUM_ORDER_TYPE action) const
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY              :   return this.m_data.Buy.SoundErrorModifyTP();
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.SoundErrorModifyTP();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.SoundErrorModifyTP();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.SoundErrorModifyTP();
      case ORDER_TYPE_SELL             :   return this.m_data.Sell.SoundErrorModifyTP();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.SoundErrorModifyTP();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.SoundErrorModifyTP();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.SoundErrorModifyTP();
      default: return NULL;
     }
  }
//+------------------------------------------------------------------+
//| Return price modification error sound                            |
//| for a specified order type                                       |
//+------------------------------------------------------------------+
string CTradeObj::GetSoundErrorModifyPrice(const ENUM_ORDER_TYPE action) const
  {
   int index=action;
   switch(index)
     {
      case ORDER_TYPE_BUY_STOP         :   return this.m_data.BuyStop.SoundErrorModifyPrice();
      case ORDER_TYPE_BUY_LIMIT        :   return this.m_data.BuyLimit.SoundErrorModifyPrice();
      case ORDER_TYPE_BUY_STOP_LIMIT   :   return this.m_data.BuyStopLimit.SoundErrorModifyPrice();
      case ORDER_TYPE_SELL_STOP        :   return this.m_data.SellStop.SoundErrorModifyPrice();
      case ORDER_TYPE_SELL_LIMIT       :   return this.m_data.SellLimit.SoundErrorModifyPrice();
      case ORDER_TYPE_SELL_STOP_LIMIT  :   return this.m_data.SellStopLimit.SoundErrorModifyPrice();
      default: return NULL;
     }
  }
//+------------------------------------------------------------------+
//| Play the sound of opening/placing                                |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::PlaySoundOpen(const int action)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.Buy.SoundOpen());             break;
      case ORDER_TYPE_BUY_STOP         :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.BuyStop.SoundOpen());         break;
      case ORDER_TYPE_BUY_LIMIT        :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.BuyLimit.SoundOpen());        break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.BuyStopLimit.SoundOpen());    break;
      case ORDER_TYPE_SELL             :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.Sell.SoundOpen());            break;
      case ORDER_TYPE_SELL_STOP        :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.SellStop.SoundOpen());        break;
      case ORDER_TYPE_SELL_LIMIT       :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.SellLimit.SoundOpen());       break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.SellStopLimit.SoundOpen());   break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Play the sound of closing/removal of                             |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::PlaySoundClose(const int action)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.Buy.SoundClose());            break;
      case ORDER_TYPE_BUY_STOP         :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.BuyStop.SoundClose());        break;
      case ORDER_TYPE_BUY_LIMIT        :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.BuyLimit.SoundClose());       break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.BuyStopLimit.SoundClose());   break;
      case ORDER_TYPE_SELL             :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.Sell.SoundClose());           break;
      case ORDER_TYPE_SELL_STOP        :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.SellStop.SoundClose());       break;
      case ORDER_TYPE_SELL_LIMIT       :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.SellLimit.SoundClose());      break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.SellStopLimit.SoundClose());  break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Play StopLoss modification sound of                              |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::PlaySoundModifySL(const int action)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.Buy.SoundModifySL());            break;
      case ORDER_TYPE_BUY_STOP         :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.BuyStop.SoundModifySL());        break;
      case ORDER_TYPE_BUY_LIMIT        :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.BuyLimit.SoundModifySL());       break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.BuyStopLimit.SoundModifySL());   break;
      case ORDER_TYPE_SELL             :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.Sell.SoundModifySL());           break;
      case ORDER_TYPE_SELL_STOP        :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.SellStop.SoundModifySL());       break;
      case ORDER_TYPE_SELL_LIMIT       :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.SellLimit.SoundModifySL());      break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.SellStopLimit.SoundModifySL());  break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Play TakeProfit modification sound of                            |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::PlaySoundModifyTP(const int action)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.Buy.SoundModifyTP());            break;
      case ORDER_TYPE_BUY_STOP         :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.BuyStop.SoundModifyTP());        break;
      case ORDER_TYPE_BUY_LIMIT        :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.BuyLimit.SoundModifyTP());       break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.BuyStopLimit.SoundModifyTP());   break;
      case ORDER_TYPE_SELL             :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.Sell.SoundModifyTP());           break;
      case ORDER_TYPE_SELL_STOP        :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.SellStop.SoundModifyTP());       break;
      case ORDER_TYPE_SELL_LIMIT       :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.SellLimit.SoundModifyTP());      break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.SellStopLimit.SoundModifyTP());  break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Play price modification sound                                    |
//| for a specified order type                                       |
//+------------------------------------------------------------------+
void CTradeObj::PlaySoundModifyPrice(const int action)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY_STOP         :   if(this.UseSoundModifyPrice(action))  CMessage::PlaySound(this.m_data.BuyStop.SoundModifyPrice());        break;
      case ORDER_TYPE_BUY_LIMIT        :   if(this.UseSoundModifyPrice(action))  CMessage::PlaySound(this.m_data.BuyLimit.SoundModifyPrice());       break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   if(this.UseSoundModifyPrice(action))  CMessage::PlaySound(this.m_data.BuyStopLimit.SoundModifyPrice());   break;
      case ORDER_TYPE_SELL_STOP        :   if(this.UseSoundModifyPrice(action))  CMessage::PlaySound(this.m_data.SellStop.SoundModifyPrice());       break;
      case ORDER_TYPE_SELL_LIMIT       :   if(this.UseSoundModifyPrice(action))  CMessage::PlaySound(this.m_data.SellLimit.SoundModifyPrice());      break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   if(this.UseSoundModifyPrice(action))  CMessage::PlaySound(this.m_data.SellStopLimit.SoundModifyPrice());  break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Play the error sound of opening/placing                          |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::PlaySoundErrorOpen(const int action)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.Buy.SoundErrorOpen());              break;
      case ORDER_TYPE_BUY_STOP         :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.BuyStop.SoundErrorOpen());          break;
      case ORDER_TYPE_BUY_LIMIT        :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.BuyLimit.SoundErrorOpen());         break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.BuyStopLimit.SoundErrorOpen());     break;
      case ORDER_TYPE_SELL             :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.Sell.SoundErrorOpen());             break;
      case ORDER_TYPE_SELL_STOP        :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.SellStop.SoundErrorOpen());         break;
      case ORDER_TYPE_SELL_LIMIT       :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.SellLimit.SoundErrorOpen());        break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   if(this.UseSoundOpen(action))   CMessage::PlaySound(this.m_data.SellStopLimit.SoundErrorOpen());    break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Play the error sound of closing/removal of                       |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::PlaySoundErrorClose(const int action)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.Buy.SoundErrorClose());             break;
      case ORDER_TYPE_BUY_STOP         :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.BuyStop.SoundErrorClose());         break;
      case ORDER_TYPE_BUY_LIMIT        :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.BuyLimit.SoundErrorClose());        break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.BuyStopLimit.SoundErrorClose());    break;
      case ORDER_TYPE_SELL             :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.Sell.SoundErrorClose());            break;
      case ORDER_TYPE_SELL_STOP        :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.SellStop.SoundErrorClose());        break;
      case ORDER_TYPE_SELL_LIMIT       :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.SellLimit.SoundErrorClose());       break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   if(this.UseSoundClose(action))  CMessage::PlaySound(this.m_data.SellStopLimit.SoundErrorClose());   break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Play StopLoss modification error sound of                        |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::PlaySoundErrorModifySL(const int action)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.Buy.SoundErrorModifySL());             break;
      case ORDER_TYPE_BUY_STOP         :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.BuyStop.SoundErrorModifySL());         break;
      case ORDER_TYPE_BUY_LIMIT        :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.BuyLimit.SoundErrorModifySL());        break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.BuyStopLimit.SoundErrorModifySL());    break;
      case ORDER_TYPE_SELL             :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.Sell.SoundErrorModifySL());            break;
      case ORDER_TYPE_SELL_STOP        :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.SellStop.SoundErrorModifySL());        break;
      case ORDER_TYPE_SELL_LIMIT       :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.SellLimit.SoundErrorModifySL());       break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   if(this.UseSoundModifySL(action))  CMessage::PlaySound(this.m_data.SellStopLimit.SoundErrorModifySL());   break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Play TakeProfit modification error sound of                      |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::PlaySoundErrorModifyTP(const int action)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY              :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.Buy.SoundErrorModifyTP());             break;
      case ORDER_TYPE_BUY_STOP         :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.BuyStop.SoundErrorModifyTP());         break;
      case ORDER_TYPE_BUY_LIMIT        :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.BuyLimit.SoundErrorModifyTP());        break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.BuyStopLimit.SoundErrorModifyTP());    break;
      case ORDER_TYPE_SELL             :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.Sell.SoundErrorModifyTP());            break;
      case ORDER_TYPE_SELL_STOP        :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.SellStop.SoundErrorModifyTP());        break;
      case ORDER_TYPE_SELL_LIMIT       :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.SellLimit.SoundErrorModifyTP());       break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   if(this.UseSoundModifyTP(action))  CMessage::PlaySound(this.m_data.SellStopLimit.SoundErrorModifyTP());   break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Play price modification error sound                              |
//| for a specified order type                                       |
//+------------------------------------------------------------------+
void CTradeObj::PlaySoundErrorModifyPrice(const int action)
  {
   switch(action)
     {
      case ORDER_TYPE_BUY_STOP         :   if(this.UseSoundModifyPrice(action))  CMessage::PlaySound(this.m_data.BuyStop.SoundErrorModifyPrice());         break;
      case ORDER_TYPE_BUY_LIMIT        :   if(this.UseSoundModifyPrice(action))  CMessage::PlaySound(this.m_data.BuyLimit.SoundErrorModifyPrice());        break;
      case ORDER_TYPE_BUY_STOP_LIMIT   :   if(this.UseSoundModifyPrice(action))  CMessage::PlaySound(this.m_data.BuyStopLimit.SoundErrorModifyPrice());    break;
      case ORDER_TYPE_SELL_STOP        :   if(this.UseSoundModifyPrice(action))  CMessage::PlaySound(this.m_data.SellStop.SoundErrorModifyPrice());        break;
      case ORDER_TYPE_SELL_LIMIT       :   if(this.UseSoundModifyPrice(action))  CMessage::PlaySound(this.m_data.SellLimit.SoundErrorModifyPrice());       break;
      case ORDER_TYPE_SELL_STOP_LIMIT  :   if(this.UseSoundModifyPrice(action))  CMessage::PlaySound(this.m_data.SellStopLimit.SoundErrorModifyPrice());   break;
      default: break;
     }
  }
//+------------------------------------------------------------------+
//| Play a sound of a specified trading event                        |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::PlaySoundSuccess(const ENUM_ACTION_TYPE action,const int order,bool sl=false,bool tp=false,bool pr=false)
  {
   if(!this.m_use_sound)
      return;
   switch((int)action)
     {
      //--- Open/set
      case ACTION_TYPE_BUY             :
      case ACTION_TYPE_BUY_LIMIT       :
      case ACTION_TYPE_BUY_STOP        :
      case ACTION_TYPE_BUY_STOP_LIMIT  :
      case ACTION_TYPE_SELL            :
      case ACTION_TYPE_SELL_LIMIT      :
      case ACTION_TYPE_SELL_STOP       :
      case ACTION_TYPE_SELL_STOP_LIMIT :
        this.PlaySoundOpen(order);  
        break;
      //--- Close/remove
      case ACTION_TYPE_CLOSE           :
      case ACTION_TYPE_CLOSE_BY        :
        this.PlaySoundClose(order); 
        break;
      //--- Modification
      case ACTION_TYPE_MODIFY          :
        if(sl) { this.PlaySoundModifySL(order);    return; }
        if(tp) { this.PlaySoundModifyTP(order);    return; }
        if(pr) { this.PlaySoundModifyPrice(order); return; }
        break;
      default:
        break;
     }
  }
//+------------------------------------------------------------------+
//| Play an error sound of a specified trading event                 |
//| a specified position/order type                                  |
//+------------------------------------------------------------------+
void CTradeObj::PlaySoundError(const ENUM_ACTION_TYPE action,const int order,bool sl=false,bool tp=false,bool pr=false)
  {
   if(!this.m_use_sound)
      return;
   switch((int)action)
     {
      //--- Open/set
      case ACTION_TYPE_BUY             :
      case ACTION_TYPE_BUY_LIMIT       :
      case ACTION_TYPE_BUY_STOP        :
      case ACTION_TYPE_BUY_STOP_LIMIT  :
      case ACTION_TYPE_SELL            :
      case ACTION_TYPE_SELL_LIMIT      :
      case ACTION_TYPE_SELL_STOP       :
      case ACTION_TYPE_SELL_STOP_LIMIT :
        this.PlaySoundErrorOpen(order);
        break;
      //--- Close/remove
      case ACTION_TYPE_CLOSE           :
      case ACTION_TYPE_CLOSE_BY        :
        this.PlaySoundErrorClose(order);
        break;
      //--- Modification
      case ACTION_TYPE_MODIFY          :
        if(sl) { this.PlaySoundErrorModifySL(order);    return; }
        if(tp) { this.PlaySoundErrorModifyTP(order);    return; }
        if(pr) { this.PlaySoundErrorModifyPrice(order); return; }
        break;
      default:
        break;
     }
  }
//+------------------------------------------------------------------+

 #endif // CTRADEOBJ_MQH_IMPLEMENTATION
#endif // __TRADEOBJ_MQH__