//+------------------------------------------------------------------+
//|                                                  PendRequest.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __PENDREQUEST_MQH__
#define __PENDREQUEST_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+ 
 #include "..\..\Entities\Bases\BaseObjExt.mqh"
 #include "..\Defines\TradingDefines.mqh"
 #include "..\..\Services\DELib\TradingDELib.mqh" 
 #ifndef CPENDREQUEST_MQH_DECLARATION
 #define CPENDREQUEST_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Abstract pending trading request class                           |
 //+------------------------------------------------------------------+
 class CPendRequest : public CBaseObjExt
  {
   private:
    MqlTradeRequest   m_request;                                            // Trading request structure
    CPause            m_pause;                                              // Pause class object
    bool              m_follow;                                             // The flag of the pending order distance reference point following the price
   /* Data on a pending request activation in the array:
       The first dimension contains the activation criteria number
       The second one features:

       m_activated_control[criterion number][0] - controlled property source
       m_activated_control[criterion number][1] - controlled property
       m_activated_control[criterion number][2] - type of comparing a controlled property with an actual value (=,>,<,!=,>=,<=)
       m_activated_control[criterion number][3] - property reference value for activation
       m_activated_control[criterion number][4] - actual property value
    */
    double            m_activated_control[][5];                             // Array of reference values of the pending request activation criterion
   
    //--- Copy trading request data
      void              CopyRequest(const MqlTradeRequest &request);
    //--- Return the index of the array the request (1) double and (2) string properties are actually located at
      int               IndexProp(ENUM_PEND_REQ_PROP_DOUBLE property)         const { return(int)property-PEND_REQ_PROP_INTEGER_TOTAL;                                  }
      int               IndexProp(ENUM_PEND_REQ_PROP_STRING property)         const { return(int)property-PEND_REQ_PROP_INTEGER_TOTAL-PEND_REQ_PROP_DOUBLE_TOTAL;       }
    protected:
      int               m_digits;                                             // Number of decimal places in a quote
      int               m_digits_lot;                                         // Number of decimal places in the symbol lot value
      bool              m_is_hedge;                                           // Hedging account flag
      long              m_long_prop[PEND_REQ_PROP_INTEGER_TOTAL];             // Request integer properties
      double            m_double_prop[PEND_REQ_PROP_DOUBLE_TOTAL];            // Request real properties
      string            m_string_prop[PEND_REQ_PROP_STRING_TOTAL];            // Request string properties
     //--- Protected parametric constructor
                     CPendRequest(const ENUM_PEND_REQ_STATUS status,
                                  const uchar id,
                                  const double price,
                                  const ulong time,
                                  const MqlTradeRequest &request,
                                  const int retcode);
      //--- Return (1) the magic number, ID of the (2) magic number, (3) the first group, (4) the second group,
      //--- (5) hedging account flag, (6) flag indicating the real property is equal to the value
        ulong             GetMagic(void)                                        const { return this.GetProperty(PEND_REQ_PROP_MQL_REQ_MAGIC);                                }
        ushort            GetMagicID(void)                                      const { return CBaseObjExt::GetMagicID((uint)this.GetProperty(PEND_REQ_PROP_MQL_REQ_MAGIC)); }
        uchar             GetGroupID1(void)                                     const { return CBaseObjExt::GetGroupID1((uint)this.GetProperty(PEND_REQ_PROP_MQL_REQ_MAGIC));}
        uchar             GetGroupID2(void)                                     const { return CBaseObjExt::GetGroupID2((uint)this.GetProperty(PEND_REQ_PROP_MQL_REQ_MAGIC));}
        bool              IsHedge(void)                                         const { return this.m_is_hedge;                                                              }
        bool              IsEqualByMode(const int mode,const double value)      const;
        bool              IsEqualByMode(const int mode,const long value)        const;
      //--- Return the flags indicating the pending request has completed changing each of the order/position parameters
        bool              IsCompletedVolume(void)                               const;
        bool              IsCompletedPrice(void)                                const;
        bool              IsCompletedStopLimit(void)                            const;
        bool              IsCompletedStopLoss(void)                             const;
        bool              IsCompletedTakeProfit(void)                           const;
        bool              IsCompletedTypeFilling(void)                          const;
        bool              IsCompletedTypeTime(void)                             const;
        bool              IsCompletedExpiration(void)                           const;
   
      //--- Return the flag of a successful check of a controlled object property and the appropriate actual property
        bool              IsComparisonCompleted(const uint index)               const;
      //--- Compare two data source values by a comparison type
        bool              IsCompared(const double actual_value,const double control_value,const ENUM_COMPARER_TYPE compare) const;
      //--- Return the number of decimal places of a controlled property
        int               DigitsControlledValue(const uint index)               const;
      //--- Set a new value changed by the shift (+/-) for all order prices
        void              SetAllMqlPrices(const double shift);

   public:
     //--- Default constructor
                     CPendRequest(){ this.m_type=OBJECT_DE_TYPE_PENDING_REQUEST; }
     //--- Set request (1) integer, (2) real and (3) string properties
      void              SetProperty(ENUM_PEND_REQ_PROP_INTEGER property,long value) { this.m_long_prop[property]=value;                                     }
      void              SetProperty(ENUM_PEND_REQ_PROP_DOUBLE property,double value){ this.m_double_prop[this.IndexProp(property)]=value;                   }
      void              SetProperty(ENUM_PEND_REQ_PROP_STRING property,string value){ this.m_string_prop[this.IndexProp(property)]=value;                   }
      //--- Return (1) integer, (2) real and (3) string request properties from the properties array
      long              GetProperty(ENUM_PEND_REQ_PROP_INTEGER property)      const { return this.m_long_prop[property];                                    }
      double            GetProperty(ENUM_PEND_REQ_PROP_DOUBLE property)       const { return this.m_double_prop[this.IndexProp(property)];                  }
      string            GetProperty(ENUM_PEND_REQ_PROP_STRING property)       const { return this.m_string_prop[this.IndexProp(property)];                  }

     //--- Return the flag of the request supporting the property
      virtual bool      SupportProperty(ENUM_PEND_REQ_PROP_INTEGER property)        { return true; }
      virtual bool      SupportProperty(ENUM_PEND_REQ_PROP_DOUBLE property)         { return true; }
      virtual bool      SupportProperty(ENUM_PEND_REQ_PROP_STRING property)         { return true; }

     //--- Return the flag indicating the pending request has completed its work
      virtual bool      IsCompleted(void)                                     const { return false;}
     //--- Return itself
      CPendRequest     *GetObject(void)                                             { return &this;}

     //--- Compare CPendRequest objects by a specified property (to sort the lists by a specified request object property)
      virtual int       Compare(const CObject *node,const int mode=0) const;
     //--- Compare CPendRequest objects by all properties (to search for equal request objects)
      bool              IsEqual(CPendRequest* compared_obj);
     //--- Return (1) the elapsed number of milliseconds, (2) waiting time completion from the pause object,
     //--- time of the (3) pause countdown start in milliseconds and (4) waiting time
      ulong             PausePassed(void)                                     const { return this.m_pause.Passed();                 }
      bool              PauseIsCompleted(void)                                const { return this.m_pause.IsCompleted();            }
      ulong             PauseTimeBegin(void)                                  const { return this.m_pause.TimeBegin();              }
      ulong             PauseTimeWait(void)                                   const { return this.m_pause.TimeWait();               }
     //--- Return the description (1) of an elapsed number of pause waiting seconds,
     //--- (2) pause countdown start time, as well as waiting time (3) in milliseconds and (4) in seconds
      string            PausePassedDescription(void)                          const { return this.m_pause.PassedDescription();      }
      string            PauseTimeBeginDescription(void)                       const { return this.m_pause.TimeBeginDescription();   }
      string            PauseWaitingMSCDescription(void)                      const { return this.m_pause.WaitingMSCDescription();  }
      string            PauseWaitingSecDescription(void)                      const { return this.m_pause.WaitingSECDescription();  }
   
     //+------------------------------------------------------------------+
     //| Methods of a simplified access to the request object properties  |
     //+------------------------------------------------------------------+
     //--- Return (1) request structure, (2) status, (3) type, (4) price at the moment of the request generation,
     //--- (5) request generation time, (6) next attempt activation time,
     //--- (7) waiting time between requests, (8) current attempt index,
     //--- (9) number of attempts, (10) request ID
     //--- (11) result a request is based on,
     //--- (12) order ticket, (13) position ticket, (14) trading operation type
      MqlTradeRequest      MqlRequest(void)                                   const { return this.m_request;                                                }
      ENUM_PEND_REQ_STATUS Status(void)                                       const { return (ENUM_PEND_REQ_STATUS)this.GetProperty(PEND_REQ_PROP_STATUS);  }
      ENUM_PEND_REQ_TYPE   TypeRequest(void)                                  const { return (ENUM_PEND_REQ_TYPE)this.GetProperty(PEND_REQ_PROP_TYPE);      }
      double               PriceCreate(void)                                  const { return this.GetProperty(PEND_REQ_PROP_PRICE_CREATE);                  }
      ulong                TimeCreate(void)                                   const { return this.GetProperty(PEND_REQ_PROP_TIME_CREATE);                   }
      ulong                TimeActivate(void)                                 const { return this.GetProperty(PEND_REQ_PROP_TIME_ACTIVATE);                 }
      ulong                WaitingMSC(void)                                   const { return this.GetProperty(PEND_REQ_PROP_WAITING);                       }
      uchar                CurrentAttempt(void)                               const { return (uchar)this.GetProperty(PEND_REQ_PROP_CURRENT_ATTEMPT);        }
      uchar                TotalAttempts(void)                                const { return (uchar)this.GetProperty(PEND_REQ_PROP_TOTAL);                  }
      uchar                ID(void)                                           const { return (uchar)this.GetProperty(PEND_REQ_PROP_ID);                     }
      int                  Retcode(void)                                      const { return (int)this.GetProperty(PEND_REQ_PROP_RETCODE);                  }
      ulong                Order(void)                                        const { return this.GetProperty(PEND_REQ_PROP_MQL_REQ_ORDER);                 }
      ulong                Position(void)                                     const { return this.GetProperty(PEND_REQ_PROP_MQL_REQ_POSITION);              }
      ENUM_TRADE_REQUEST_ACTIONS Action(void)                                 const { return (ENUM_TRADE_REQUEST_ACTIONS)this.GetProperty(PEND_REQ_PROP_MQL_REQ_ACTION);   }

     //--- Return the actual (1) volume, (2) order, (3) limit order,
     //--- (4) stoploss order and (5) takeprofit order prices, (6) order filling type,
     //--- (7) order expiration type and (8) order lifetime
      double               ActualVolume(void)                                 const { return this.GetProperty(PEND_REQ_PROP_ACTUAL_VOLUME);                 }
      double               ActualPrice(void)                                  const { return this.GetProperty(PEND_REQ_PROP_ACTUAL_PRICE);                  }
      double               ActualStopLimit(void)                              const { return this.GetProperty(PEND_REQ_PROP_ACTUAL_STOPLIMIT);              }
      double               ActualSL(void)                                     const { return this.GetProperty(PEND_REQ_PROP_ACTUAL_SL);                     }
      double               ActualTP(void)                                     const { return this.GetProperty(PEND_REQ_PROP_ACTUAL_TP);                     }
      ENUM_ORDER_TYPE_FILLING ActualTypeFilling(void)                         const { return (ENUM_ORDER_TYPE_FILLING)this.GetProperty(PEND_REQ_PROP_ACTUAL_TYPE_FILLING); }
      ENUM_ORDER_TYPE_TIME ActualTypeTime(void)                               const { return (ENUM_ORDER_TYPE_TIME)this.GetProperty(PEND_REQ_PROP_ACTUAL_TYPE_TIME);       }
      datetime             ActualExpiration(void)                             const { return (datetime)this.GetProperty(PEND_REQ_PROP_ACTUAL_EXPIRATION);   }

     //--- Modify order prices by the current price
      void                 CorrectMqlPricesByCurrentPrice(const double price);
                          
     //--- Set (1) the price when creating a request, (2) setting, (3) StopLoss, (4) TakeProfit, (5) stoplimit,
     //--- (6) request creation time, (7) current attempt time, (8) waiting time between requests, (9) current attempt index,
     //---  (10) number of attempts,(11) id, (12) order ticket, (13) position ticket, (14) pending request type
      void                 SetPriceCreate(const double price)           { this.SetProperty(PEND_REQ_PROP_PRICE_CREATE,price);                                              }
      void                 SetMqlPrice(const double price)              { this.SetProperty(PEND_REQ_PROP_MQL_REQ_PRICE,price); this.m_request.price=price;                 }
      void                 SetMqlSL(const double sl)                    { this.SetProperty(PEND_REQ_PROP_MQL_REQ_SL,sl); this.m_request.sl=sl;                             }
      void                 SetMqlTP(const double tp)                    { this.SetProperty(PEND_REQ_PROP_MQL_REQ_TP,tp); this.m_request.tp=tp;                             }
      void                 SetMqlStopLimit(const double stoplimit)      { this.SetProperty(PEND_REQ_PROP_MQL_REQ_STOPLIMIT,stoplimit); this.m_request.stoplimit=stoplimit; }
      void                 SetTimeCreate(const ulong time)
                          {
                           this.SetProperty(PEND_REQ_PROP_TIME_CREATE,time);
                           this.m_pause.SetTimeBegin(time);
                          }
      void                 SetTimeActivate(const ulong time)                        { this.SetProperty(PEND_REQ_PROP_TIME_ACTIVATE,time);                   }
      void                 SetWaitingMSC(const ulong miliseconds)
                          { 
                           this.SetProperty(PEND_REQ_PROP_WAITING,miliseconds);
                           this.m_pause.SetWaitingMSC(miliseconds);
                          }
      void                 SetCurrentAttempt(const uchar number)                    { this.SetProperty(PEND_REQ_PROP_CURRENT_ATTEMPT,number);               }
      void                 SetTotalAttempts(const uchar number)                     { this.SetProperty(PEND_REQ_PROP_TOTAL,number);                         }
      void                 SetID(const uchar id)                                    { this.SetProperty(PEND_REQ_PROP_ID,id);                                }
      void                 SetOrder(const ulong ticket)                             { this.SetProperty(PEND_REQ_PROP_MQL_REQ_ORDER,ticket);                 }
      void                 SetPosition(const ulong ticket)                          { this.SetProperty(PEND_REQ_PROP_MQL_REQ_POSITION,ticket);              }
      void                 SetTypeRequest(const ENUM_PEND_REQ_TYPE type)            { this.SetProperty(PEND_REQ_PROP_TYPE,type);                            }
   
     //--- Set the actual (1) volume, (2) order, (3) limit order,
     //--- (4) stoploss order and (5) takeprofit order prices, (6) order filling type,
     //--- (7) order expiration type and (8) order lifetime
      void                 SetActualVolume(const double volume)                     { this.SetProperty(PEND_REQ_PROP_ACTUAL_VOLUME,volume);                 }
      void                 SetActualPrice(const double price)                       { this.SetProperty(PEND_REQ_PROP_ACTUAL_PRICE,price);                   }
      void                 SetActualStopLimit(const double price)                   { this.SetProperty(PEND_REQ_PROP_ACTUAL_STOPLIMIT,price);               }
      void                 SetActualSL(const double price)                          { this.SetProperty(PEND_REQ_PROP_ACTUAL_SL,price);                      }
      void                 SetActualTP(const double price)                          { this.SetProperty(PEND_REQ_PROP_ACTUAL_TP,price);                      }
      void                 SetActualTypeFilling(const ENUM_ORDER_TYPE_FILLING type) { this.SetProperty(PEND_REQ_PROP_ACTUAL_TYPE_FILLING,type);             }
      void                 SetActualTypeTime(const ENUM_ORDER_TYPE_TIME type)       { this.SetProperty(PEND_REQ_PROP_ACTUAL_TYPE_TIME,type);                }
      void                 SetActualExpiration(const datetime expiration)           { this.SetProperty(PEND_REQ_PROP_ACTUAL_EXPIRATION,expiration);         }

     //--- Set a controlled property and a comparison method for a request activation criteria data by its index - both the actual one and the one in the object of
     //--- account, symbol or trading event property value (depends on 'source' value) for activating a pending request
      void                 SetNewActivationProperties(const ENUM_PEND_REQ_ACTIVATION_SOURCE source,
                                                   const int property,
                                                   const double control_value,
                                                   const ENUM_COMPARER_TYPE comparer_type,
                                                   const double actual_value);
   
     //--- Set a (1) controlled property, (2) comparison type, (3) object value and
     //--- (4) actual controlled property value for activating a pending request
      bool                 SetActivationProperty(const uint index,const ENUM_PEND_REQ_ACTIVATION_SOURCE source,const int property);
      bool                 SetActivationComparerType(const uint index,const ENUM_COMPARER_TYPE comparer_type);
      bool                 SetActivationControlValue(const uint index,const double value);
      bool                 SetActivationActualValue(const uint index,const double value);
   
     //--- Return (1) a pending request activation source, (2) controlled property, (3) comparison type,
     //---  (4) object value,(5) actual controlled property value for activating a pending request
      ENUM_PEND_REQ_ACTIVATION_SOURCE GetActivationSource(const uint index)         const;
      int                  GetActivationProperty(const uint index)                  const;
      ENUM_COMPARER_TYPE   GetActivationComparerType(const uint index)              const;
      double               GetActivationControlValue(const uint index)              const;
      double               GetActivationActualValue(const uint index)               const;
   
     //--- Return the flag of a successful check of all controlled object properties and the appropriate actual properties
      bool                 IsAllComparisonCompleted(void)  const;
     //--- Return/set the flag of the pending order distance reference point following the price
      bool                 IsFollowThePrice(void)                                   const { return this.m_follow; }
      void                 SetFollowThePrice(const bool flag)                             { this.m_follow=flag;   }
   
     //+------------------------------------------------------------------+
     //| Descriptions of request object properties                        |
     //+------------------------------------------------------------------+
     //--- Get description of a request (1) integer, (2) real and (3) string property
      string               GetPropertyDescription(ENUM_PEND_REQ_PROP_INTEGER property);
      string               GetPropertyDescription(ENUM_PEND_REQ_PROP_DOUBLE property);
      string               GetPropertyDescription(ENUM_PEND_REQ_PROP_STRING property);
   
     //--- Return the description of a (1) controlled property, (2) comparison type, (3) controlled property value in the object,
     //--- (4) actual controlled property value for activating a pending request, (5) total number of activation conditions
      string               GetActivationPropertyDescription(const uint index)       const;
      string               GetActivationComparerTypeDescription(const uint index)   const;
      string               GetActivationControlValueDescription(const uint index)   const;
      string               GetActivationActualValueDescription(const uint index)    const;
      uint                 GetActivationCriterionTotal(void)                        const { return ::ArrayRange(this.m_activated_control,0); }
   
     //--- Return the names of pending request object parameters
      string               StatusDescription(void)                const;
      string               TypeRequestDescription(void)           const;
      string               IDDescription(void)                    const;
      string               RetcodeDescription(void)               const;
      string               TimeCreateDescription(void)            const;
      string               TimeActivateDescription(void)          const;
      string               TimeWaitingDescription(void)           const;
      string               CurrentAttemptDescription(void)        const;
      string               TotalAttemptsDescription(void)         const;
      string               PriceCreateDescription(void)           const;
   
      string               TypeFillingActualDescription(void)     const;
      string               TypeTimeActualDescription(void)        const;
      string               ExpirationActualDescription(void)      const;
      string               VolumeActualDescription(void)          const;
      string               PriceActualDescription(void)           const;
      string               StopLimitActualDescription(void)       const;
      string               StopLossActualDescription(void)        const;
      string               TakeProfitActualDescription(void)      const;
   
     //--- Return the names of trading request structures parameters in the request object
      string               MqlReqActionDescription(void)          const;
      string               MqlReqMagicDescription(void)           const;
      string               MqlReqOrderDescription(void)           const;
      string               MqlReqSymbolDescription(void)          const;
      string               MqlReqVolumeDescription(void)          const;
      string               MqlReqPriceDescription(void)           const;
      string               MqlReqStopLimitDescription(void)       const;
      string               MqlReqStopLossDescription(void)        const;
      string               MqlReqTakeProfitDescription(void)      const;
      string               MqlReqDeviationDescription(void)       const;
      string               MqlReqTypeOrderDescription(void)       const;
      string               MqlReqTypeFillingDescription(void)     const;
      string               MqlReqTypeTimeDescription(void)        const;
      string               MqlReqExpirationDescription(void)      const;
      string               MqlReqCommentDescription(void)         const;
      string               MqlReqPositionDescription(void)        const;
      string               MqlReqPositionByDescription(void)      const;

     //--- Display (1) request activation parameters in the journal,
     //--- (2) the description of the object properties in the journal (full_prop=true - all properties, false - supported ones only - implemented in descendant classes)
     //--- (3) short message about the request, (4) short request name (3 and 4 - implementation in the class descendants)
      void                 PrintActivations(void);
      virtual void         Print(const bool full_prop=false,const bool dash=false);
      virtual void         PrintShort(const bool dash=false,const bool symbol=false){;}
   virtual string       Header(void){return NULL;}
  };
 #endif // CPENDREQUEST_MQH_DECLARATION
 #ifndef CPENDREQUEST_MQH_IMPLEMENTATION
 #define CPENDREQUEST_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CPendRequest::CPendRequest(const ENUM_PEND_REQ_STATUS status,
                              const uchar id,
                              const double price,
                              const ulong time,
                              const MqlTradeRequest &request,
                              const int retcode)
   {
    this.m_type=OBJECT_DE_TYPE_PENDING_REQUEST; 
    ::ZeroMemory(this.m_request);
    this.CopyRequest(request);
    this.m_is_hedge=#ifdef __MQL4__ true #else bool(::AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) #endif;
    this.m_digits=(int)::SymbolInfoInteger(this.GetProperty(PEND_REQ_PROP_MQL_REQ_SYMBOL),SYMBOL_DIGITS);
    int dg=(int)DigitsLots(this.GetProperty(PEND_REQ_PROP_MQL_REQ_SYMBOL));
    this.m_digits_lot=(dg==0 ? 1 : dg);
    this.SetProperty(PEND_REQ_PROP_STATUS,status);
    this.SetProperty(PEND_REQ_PROP_ID,id);
    this.SetProperty(PEND_REQ_PROP_RETCODE,retcode);
    this.SetProperty(PEND_REQ_PROP_TYPE,this.GetProperty(PEND_REQ_PROP_RETCODE)>0 ? PEND_REQ_TYPE_ERROR : PEND_REQ_TYPE_REQUEST);
    this.SetProperty(PEND_REQ_PROP_TIME_CREATE,time);
    this.SetProperty(PEND_REQ_PROP_PRICE_CREATE,price);
    this.m_pause.SetTimeBegin(this.GetProperty(PEND_REQ_PROP_TIME_CREATE));
    this.m_pause.SetWaitingMSC(this.GetProperty(PEND_REQ_PROP_WAITING));
    ::ArrayResize(this.m_activated_control,0,10);
    this.m_follow=true;
   }
  //+------------------------------------------------------------------+
  //| Compare CPendRequest objects by a specified property             |
  //+------------------------------------------------------------------+
  int CPendRequest::Compare(const CObject *node,const int mode=0) const
   {
      const CPendRequest *compared_obj=node;
     //--- compare integer properties of two events
     if(mode<PEND_REQ_PROP_INTEGER_TOTAL)
     {
      long value_compared=compared_obj.GetProperty((ENUM_PEND_REQ_PROP_INTEGER)mode);
      long value_current=this.GetProperty((ENUM_PEND_REQ_PROP_INTEGER)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
     //--- compare integer properties of two objects
     if(mode<PEND_REQ_PROP_DOUBLE_TOTAL+PEND_REQ_PROP_INTEGER_TOTAL)
     {
      double value_compared=compared_obj.GetProperty((ENUM_PEND_REQ_PROP_DOUBLE)mode);
      double value_current=this.GetProperty((ENUM_PEND_REQ_PROP_DOUBLE)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
     //--- compare string properties of two objects
     else if(mode<PEND_REQ_PROP_DOUBLE_TOTAL+PEND_REQ_PROP_INTEGER_TOTAL+PEND_REQ_PROP_STRING_TOTAL)
     {
      string value_compared=compared_obj.GetProperty((ENUM_PEND_REQ_PROP_STRING)mode);
      string value_current=this.GetProperty((ENUM_PEND_REQ_PROP_STRING)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
     return 0;
   }
  //+------------------------------------------------------------------+
  //| Compare CPendRequest objects by all properties                   |
  //+------------------------------------------------------------------+
  bool CPendRequest::IsEqual(CPendRequest *compared_obj)
   {
    int begin=0, end=PEND_REQ_PROP_INTEGER_TOTAL;
    for(int i=begin; i<end; i++)
      {
        ENUM_PEND_REQ_PROP_INTEGER prop=(ENUM_PEND_REQ_PROP_INTEGER)i;
        if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false; 
      }
    begin=end; end+=PEND_REQ_PROP_DOUBLE_TOTAL;
    for(int i=begin; i<end; i++)
      {
        ENUM_PEND_REQ_PROP_DOUBLE prop=(ENUM_PEND_REQ_PROP_DOUBLE)i;
        if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false; 
      }
    begin=end; end+=PEND_REQ_PROP_STRING_TOTAL;
    for(int i=begin; i<end; i++)
      {
        ENUM_PEND_REQ_PROP_STRING prop=(ENUM_PEND_REQ_PROP_STRING)i;
        if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false; 
      }
    //--- All properties are equal
    return true;
   }
  //+---------------------------------------------------------------------+
  //| Return the flag indicating the real value is equal to the passed one|
  //+---------------------------------------------------------------------+
  bool CPendRequest::IsEqualByMode(const int mode,const double value) const
   {
    CPendRequest *req=new CPendRequest();
    if(req==NULL)
        return false;
    req.SetProperty((ENUM_PEND_REQ_PROP_DOUBLE)mode,value);
    bool res=!this.Compare(req,mode);
    delete req;
    return res;
   }
  //+------------------------------------------------------------------------+
  //| Return the flag indicating the integer value is equal to the passed one|
  //+------------------------------------------------------------------------+
  bool CPendRequest::IsEqualByMode(const int mode,const long value) const
   {
    CPendRequest *req=new CPendRequest();
    if(req==NULL)
        return false;
    req.SetProperty((ENUM_PEND_REQ_PROP_INTEGER)mode,value);
    bool res=!this.Compare(req,mode);
    delete req;
    return res;
   }
  //+------------------------------------------------------------------+
  //| Return the flag of a successful volume change                    |
  //+------------------------------------------------------------------+
  bool CPendRequest::IsCompletedVolume(void) const
   {
    return this.IsEqualByMode(PEND_REQ_PROP_ACTUAL_VOLUME,this.GetProperty(PEND_REQ_PROP_MQL_REQ_VOLUME));
   }
  //+------------------------------------------------------------------+
  //| Return the flag of a successful price modification               |
  //+------------------------------------------------------------------+
  bool CPendRequest::IsCompletedPrice(void) const
   {
    return this.IsEqualByMode(PEND_REQ_PROP_ACTUAL_PRICE,this.GetProperty(PEND_REQ_PROP_MQL_REQ_PRICE));
   }
  //+-------------------------------------------------------------------+
  //| Return the flag of a successful StopLimit order price modification|
  //+-------------------------------------------------------------------+
  bool CPendRequest::IsCompletedStopLimit(void) const
   {
    return this.IsEqualByMode(PEND_REQ_PROP_ACTUAL_STOPLIMIT,this.GetProperty(PEND_REQ_PROP_MQL_REQ_STOPLIMIT));
   }
  //+------------------------------------------------------------------+
  //| Return the flag of a successful StopLoss order modification      |
  //+------------------------------------------------------------------+
  bool CPendRequest::IsCompletedStopLoss(void) const
   {
    return this.IsEqualByMode(PEND_REQ_PROP_ACTUAL_SL,this.GetProperty(PEND_REQ_PROP_MQL_REQ_SL));
   }
  //+------------------------------------------------------------------+
  //| Return the flag of a successful TakeProfit order modification    |
  //+------------------------------------------------------------------+
  bool CPendRequest::IsCompletedTakeProfit(void) const
   {
    return this.IsEqualByMode(PEND_REQ_PROP_ACTUAL_TP,this.GetProperty(PEND_REQ_PROP_MQL_REQ_TP));
   }
  //+------------------------------------------------------------------+
  //| Return the flag of a successful order filling type modification  |
  //+------------------------------------------------------------------+
  bool CPendRequest::IsCompletedTypeFilling(void) const
   {
    return this.IsEqualByMode(PEND_REQ_PROP_ACTUAL_TYPE_FILLING,this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE_FILLING));
   }
  //+-------------------------------------------------------------------+
  //| Return the flag of a successful order expiration type modification|
  //+-------------------------------------------------------------------+
  bool CPendRequest::IsCompletedTypeTime(void) const
   {
    return this.IsEqualByMode(PEND_REQ_PROP_ACTUAL_TYPE_TIME,this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE_TIME));
   }
  //+------------------------------------------------------------------+
  //| Return the flag of a successful order lifetime modification      |
  //+------------------------------------------------------------------+
  bool CPendRequest::IsCompletedExpiration(void) const
   {
    return this.IsEqualByMode(PEND_REQ_PROP_ACTUAL_EXPIRATION,this.GetProperty(PEND_REQ_PROP_MQL_REQ_EXPIRATION));
   }
  //+------------------------------------------------------------------+
  //| Copy trading request data                                        |
  //+------------------------------------------------------------------+
  void CPendRequest::CopyRequest(const MqlTradeRequest &request)
   {
    //--- Copy a passed structure to an object structure
     this.m_request=request;
    //--- Integer properties of a trading request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_ACTION,request.action);             // Type of a performed action in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_TYPE,request.type);                 // Order type in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_MAGIC,request.magic);               // EA stamp (magic number ID) in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_ORDER,request.order);               // Order ticket in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_POSITION,request.position);         // Position ticket in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_POSITION_BY,request.position_by);   // Opposite position ticket in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_DEVIATION,request.deviation);       // Maximum acceptable deviation from a requested price in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_EXPIRATION,request.expiration);     // Order expiration time (for ORDER_TIME_SPECIFIED type orders) in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_TYPE_FILLING,request.type_filling); // Order filling type in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_TYPE_TIME,request.type_time);       // Order lifetime type in the request structure
    //--- Real properties of a trading request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_VOLUME,request.volume);             // Requested volume of a deal in lots in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_PRICE,request.price);               // Price in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_STOPLIMIT,request.stoplimit);       // StopLimit level in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_SL,request.sl);                     // Stop Loss level in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_TP,request.tp);                     // Take Profit level in the request structure
    //--- String properties of a trading request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_SYMBOL,request.symbol);             // Trading instrument name in the request structure
     this.SetProperty(PEND_REQ_PROP_MQL_REQ_COMMENT,request.comment);           // Order comment in the request structure
   }
  //+------------------------------------------------------------------+
  //| Return the description of the request integer property           |
  //+------------------------------------------------------------------+
  string CPendRequest::GetPropertyDescription(ENUM_PEND_REQ_PROP_INTEGER property)
   {
    return
     (
      property==PEND_REQ_PROP_STATUS               ?  this.StatusDescription()            :
      property==PEND_REQ_PROP_TYPE                 ?  this.TypeRequestDescription()       :
      property==PEND_REQ_PROP_ID                   ?  this.IDDescription()                :
      property==PEND_REQ_PROP_RETCODE              ?  this.RetcodeDescription()           :
      property==PEND_REQ_PROP_TIME_CREATE          ?  this.TimeCreateDescription()        :
      property==PEND_REQ_PROP_TIME_ACTIVATE        ?  this.TimeActivateDescription()      :
      property==PEND_REQ_PROP_WAITING              ?  this.TimeWaitingDescription()       :
      property==PEND_REQ_PROP_CURRENT_ATTEMPT      ?  this.CurrentAttemptDescription()    :
      property==PEND_REQ_PROP_TOTAL                ?  this.TotalAttemptsDescription()     :
      property==PEND_REQ_PROP_ACTUAL_TYPE_FILLING  ?  this.TypeFillingActualDescription() :
      property==PEND_REQ_PROP_ACTUAL_TYPE_TIME     ?  this.TypeTimeActualDescription()    :
      property==PEND_REQ_PROP_ACTUAL_EXPIRATION    ?  this.ExpirationActualDescription()  :
      //--- MqlTradeRequest
      property==PEND_REQ_PROP_MQL_REQ_ACTION       ?  this.MqlReqActionDescription()      :
      property==PEND_REQ_PROP_MQL_REQ_TYPE         ?  this.MqlReqTypeOrderDescription()   :
      property==PEND_REQ_PROP_MQL_REQ_MAGIC        ?  this.MqlReqMagicDescription()       :
      property==PEND_REQ_PROP_MQL_REQ_ORDER        ?  this.MqlReqOrderDescription()       :
      property==PEND_REQ_PROP_MQL_REQ_POSITION     ?  this.MqlReqPositionDescription()    :
      property==PEND_REQ_PROP_MQL_REQ_POSITION_BY  ?  this.MqlReqPositionByDescription()  :
      property==PEND_REQ_PROP_MQL_REQ_DEVIATION    ?  this.MqlReqDeviationDescription()   :
      property==PEND_REQ_PROP_MQL_REQ_EXPIRATION   ?  this.MqlReqExpirationDescription()  :
      property==PEND_REQ_PROP_MQL_REQ_TYPE_FILLING ?  this.MqlReqTypeFillingDescription() :
      property==PEND_REQ_PROP_MQL_REQ_TYPE_TIME    ?  this.MqlReqTypeTimeDescription()    :
      ::EnumToString(property)
     );
   }
  //+------------------------------------------------------------------+
  //| Return the description of the request real property              |
  //+------------------------------------------------------------------+
  string CPendRequest::GetPropertyDescription(ENUM_PEND_REQ_PROP_DOUBLE property)
   {
    return
     (
      property==PEND_REQ_PROP_PRICE_CREATE      ?  this.PriceCreateDescription()          :
      property==PEND_REQ_PROP_ACTUAL_VOLUME     ?  this.VolumeActualDescription()         :
      property==PEND_REQ_PROP_ACTUAL_PRICE      ?  this.PriceActualDescription()          :
      property==PEND_REQ_PROP_ACTUAL_STOPLIMIT  ?  this.StopLimitActualDescription()      :
      property==PEND_REQ_PROP_ACTUAL_SL         ?  this.StopLossActualDescription()       :
      property==PEND_REQ_PROP_ACTUAL_TP         ?  this.TakeProfitActualDescription()     :
      //--- MqlTradeRequest
      property==PEND_REQ_PROP_MQL_REQ_VOLUME    ?  this.MqlReqVolumeDescription()         :
      property==PEND_REQ_PROP_MQL_REQ_PRICE     ?  this.MqlReqPriceDescription()          :
      property==PEND_REQ_PROP_MQL_REQ_STOPLIMIT ?  this.MqlReqStopLimitDescription()      :
      property==PEND_REQ_PROP_MQL_REQ_SL        ?  this.MqlReqStopLossDescription()       :
      property==PEND_REQ_PROP_MQL_REQ_TP        ?  this.MqlReqTakeProfitDescription()     :
      ::EnumToString(property)
     );
   }
  //+------------------------------------------------------------------+
  //| Return the description of the request string property            |
  //+------------------------------------------------------------------+
  string CPendRequest::GetPropertyDescription(ENUM_PEND_REQ_PROP_STRING property)
   {
    return
     (
      property==PEND_REQ_PROP_MQL_REQ_SYMBOL    ?  this.MqlReqSymbolDescription()         :
      property==PEND_REQ_PROP_MQL_REQ_COMMENT   ?  this.MqlReqCommentDescription()        :
      ::EnumToString(property)
     );
   }
  //+------------------------------------------------------------------+
  //| Return the pending request status name                           |
  //+------------------------------------------------------------------+
  string CPendRequest::StatusDescription(void) const
   {
    int code_descr=
     (
      this.GetProperty(PEND_REQ_PROP_STATUS)==PEND_REQ_STATUS_OPEN   ?  MSG_LIB_TEXT_PEND_REQUEST_STATUS_OPEN     :
      this.GetProperty(PEND_REQ_PROP_STATUS)==PEND_REQ_STATUS_CLOSE  ?  MSG_LIB_TEXT_PEND_REQUEST_STATUS_CLOSE    :
      this.GetProperty(PEND_REQ_PROP_STATUS)==PEND_REQ_STATUS_SLTP   ?  MSG_LIB_TEXT_PEND_REQUEST_STATUS_SLTP     :
      this.GetProperty(PEND_REQ_PROP_STATUS)==PEND_REQ_STATUS_PLACE  ?  MSG_LIB_TEXT_PEND_REQUEST_STATUS_PLACE    :
      this.GetProperty(PEND_REQ_PROP_STATUS)==PEND_REQ_STATUS_REMOVE ?  MSG_LIB_TEXT_PEND_REQUEST_STATUS_REMOVE   :
      this.GetProperty(PEND_REQ_PROP_STATUS)==PEND_REQ_STATUS_MODIFY ?  MSG_LIB_TEXT_PEND_REQUEST_STATUS_MODIFY   :
      MSG_EVN_STATUS_UNKNOWN
     );
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_STATUS)+": "+CMessage::Text(code_descr);
   }
  //+------------------------------------------------------------------+
  //| Return the pending request type name                             |
  //+------------------------------------------------------------------+
  string CPendRequest::TypeRequestDescription(void) const
   {
    int code_descr=
     (
      this.GetProperty(PEND_REQ_PROP_TYPE)==PEND_REQ_TYPE_ERROR   ?  MSG_LIB_TEXT_PEND_REQUEST_BY_ERROR     :
      this.GetProperty(PEND_REQ_PROP_TYPE)==PEND_REQ_TYPE_REQUEST ?  MSG_LIB_TEXT_PEND_REQUEST_BY_REQUEST   :
      MSG_SYM_MODE_UNKNOWN
     );
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_TYPE)+": "+CMessage::Text(code_descr);
   }
  //+------------------------------------------------------------------+
  //| Return the pending request ID description                        |
  //+------------------------------------------------------------------+
  string CPendRequest::IDDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_ID)+": #"+(string)this.GetProperty(PEND_REQ_PROP_ID);
   }
  //+------------------------------------------------------------------+
  //| Return the description of an error code a request is based on    |
  //+------------------------------------------------------------------+
  string CPendRequest::RetcodeDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_RETCODE)+": "+
           CMessage::Text((int)this.GetProperty(PEND_REQ_PROP_RETCODE))+
           " ("+(string)this.GetProperty(PEND_REQ_PROP_RETCODE)+")";
   }
  //+------------------------------------------------------------------+
  //| Return the description of a pending request creation time        |
  //+------------------------------------------------------------------+
  string CPendRequest::TimeCreateDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_TIME_CREATE)+": "+::TimeMSCtoString(this.GetProperty(PEND_REQ_PROP_TIME_CREATE));
   }
  //+------------------------------------------------------------------+
  //| Return the description of a pending request activation time      |
  //+------------------------------------------------------------------+
  string CPendRequest::TimeActivateDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_TIME_ACTIVATE)+": "+::TimeMSCtoString(this.GetProperty(PEND_REQ_PROP_TIME_ACTIVATE));
   }
  //+---------------------------------------------------------------------+
  //| Return the description of a time spent waiting for a pending request|
  //+---------------------------------------------------------------------+
  string CPendRequest::TimeWaitingDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_WAITING)+": "+
           (string)this.GetProperty(PEND_REQ_PROP_WAITING)+
           " ("+::TimeToString(this.GetProperty(PEND_REQ_PROP_WAITING)/1000,TIME_MINUTES|TIME_SECONDS)+")";
   }
  //+------------------------------------------------------------------+
  //| Return the description of the current pending request attempt    |
  //+------------------------------------------------------------------+
  string CPendRequest::CurrentAttemptDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_CURRENT_ATTEMPT)+": "+(string)this.GetProperty(PEND_REQ_PROP_CURRENT_ATTEMPT);
   }
  //+------------------------------------------------------------------+
  //| Return the description of a number of pending request attempts   |
  //+------------------------------------------------------------------+
  string CPendRequest::TotalAttemptsDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_TOTAL_ATTEMPTS)+": "+(string)this.GetProperty(PEND_REQ_PROP_TOTAL);
   }
  //+------------------------------------------------------------------+
  //| Return the description of the actual order filling mode          |
  //+------------------------------------------------------------------+
  string CPendRequest::TypeFillingActualDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_ACTUAL_TYPE_FILLING)+": "+OrderTypeFillingDescription((ENUM_ORDER_TYPE_FILLING)this.GetProperty(PEND_REQ_PROP_ACTUAL_TYPE_FILLING));
   }
  //+------------------------------------------------------------------+
  //| Return the actual order lifetime type                            |
  //+------------------------------------------------------------------+
  string CPendRequest::TypeTimeActualDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_ACTUAL_TYPE_TIME)+": "+OrderTypeTimeDescription((ENUM_ORDER_TYPE_TIME)this.GetProperty(PEND_REQ_PROP_ACTUAL_TYPE_TIME));
   }
  //+------------------------------------------------------------------+
  //| Return the description of the actual order lifetime              |
  //+------------------------------------------------------------------+
  string CPendRequest::ExpirationActualDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_ACTUAL_EXPIRATION)+": "+
           (this.GetProperty(PEND_REQ_PROP_ACTUAL_EXPIRATION)>0 ? 
            ::TimeToString(this.GetProperty(PEND_REQ_PROP_ACTUAL_EXPIRATION)) : 
            CMessage::Text(MSG_LIB_PROP_NOT_SET));
   }
  //+------------------------------------------------------------------+
  //| Return the description of a price when creating a request        |
  //+------------------------------------------------------------------+
  string CPendRequest::PriceCreateDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_PRICE_CREATE)+": "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_PRICE_CREATE),this.m_digits);
   }
  //+------------------------------------------------------------------+
  //| Return the description of the actual order volume                |
  //+------------------------------------------------------------------+
  string CPendRequest::VolumeActualDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_ACTUAL_VOLUME)+": "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_ACTUAL_VOLUME),this.m_digits_lot);
   }
  //+------------------------------------------------------------------+
  //| Return the description of the actual order price                 |
  //+------------------------------------------------------------------+
  string CPendRequest::PriceActualDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_ACTUAL_PRICE)+": "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_ACTUAL_PRICE),this.m_digits);
   }
  //+------------------------------------------------------------------+
  //| Return the description of the actual StopLimit order price       |
  //+------------------------------------------------------------------+
  string CPendRequest::StopLimitActualDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_ACTUAL_STOPLIMIT)+": "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_ACTUAL_STOPLIMIT),this.m_digits);
   }
  //+------------------------------------------------------------------+
  //| Return the description of the actual StopLoss order price        |
  //+------------------------------------------------------------------+
  string CPendRequest::StopLossActualDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_ACTUAL_SL)+": "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_ACTUAL_SL),this.m_digits);
   }
  //+------------------------------------------------------------------+
  //| Return the description of the actual TakeProfit order price      |
  //+------------------------------------------------------------------+
  string CPendRequest::TakeProfitActualDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_ACTUAL_TP)+": "+::DoubleToString(this.GetProperty(PEND_REQ_PROP_ACTUAL_TP),this.m_digits);
   }
  //+------------------------------------------------------------------+
  //| Return the executed action type description                      |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqActionDescription(void) const
   {
   int code_descr=
     (
      this.GetProperty(PEND_REQ_PROP_MQL_REQ_ACTION)==TRADE_ACTION_DEAL       ?  MSG_LIB_TEXT_REQUEST_ACTION_DEAL       :
      this.GetProperty(PEND_REQ_PROP_MQL_REQ_ACTION)==TRADE_ACTION_PENDING    ?  MSG_LIB_TEXT_REQUEST_ACTION_PENDING    :
      this.GetProperty(PEND_REQ_PROP_MQL_REQ_ACTION)==TRADE_ACTION_SLTP       ?  MSG_LIB_TEXT_REQUEST_ACTION_SLTP       :
      this.GetProperty(PEND_REQ_PROP_MQL_REQ_ACTION)==TRADE_ACTION_MODIFY     ?  MSG_LIB_TEXT_REQUEST_ACTION_MODIFY     :
      this.GetProperty(PEND_REQ_PROP_MQL_REQ_ACTION)==TRADE_ACTION_REMOVE     ?  MSG_LIB_TEXT_REQUEST_ACTION_REMOVE     :
      this.GetProperty(PEND_REQ_PROP_MQL_REQ_ACTION)==TRADE_ACTION_CLOSE_BY   ?  MSG_LIB_TEXT_REQUEST_ACTION_CLOSE_BY   :
      MSG_LIB_TEXT_REQUEST_ACTION_UNCNOWN
     );
   return CMessage::Text(MSG_LIB_TEXT_REQUEST_ACTION)+": "+CMessage::Text(code_descr);
   }
  //+------------------------------------------------------------------+
  //| Return the magic number value description                        |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqMagicDescription(void) const
   {
   return CMessage::Text(MSG_ORD_MAGIC)+": "+(string)this.GetProperty(PEND_REQ_PROP_MQL_REQ_MAGIC)+
          (this.GetMagicID()!=this.GetProperty(PEND_REQ_PROP_MQL_REQ_MAGIC) ? " ("+(string)this.GetMagicID()+")" : "");
   }
  //+------------------------------------------------------------------+
  //| Return the order ticket value description                        |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqOrderDescription(void) const
   {
   return CMessage::Text(MSG_LIB_TEXT_REQUEST_ORDER)+": "+
          (this.GetProperty(PEND_REQ_PROP_MQL_REQ_ORDER)>0 ? 
           "#"+(string)this.GetProperty(PEND_REQ_PROP_MQL_REQ_ORDER) : 
           CMessage::Text(MSG_LIB_PROP_NOT_SET));
   }
  //+------------------------------------------------------------------+
  //| Return the request position ticket description                   |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqPositionDescription(void) const
   {
   return CMessage::Text(MSG_LIB_TEXT_REQUEST_POSITION)+": "+
          (this.GetProperty(PEND_REQ_PROP_MQL_REQ_POSITION)>0 ? 
           (string)this.GetProperty(PEND_REQ_PROP_MQL_REQ_POSITION) : 
           CMessage::Text(MSG_LIB_PROP_NOT_SET));
   }
  //+------------------------------------------------------------------+
  //| Return the request opposite position ticket description          |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqPositionByDescription(void) const
   {
   return CMessage::Text(MSG_LIB_TEXT_REQUEST_POSITION_BY)+": "+
          (this.GetProperty(PEND_REQ_PROP_MQL_REQ_POSITION_BY)>0 ? 
           (string)this.GetProperty(PEND_REQ_PROP_MQL_REQ_POSITION_BY) : 
           CMessage::Text(MSG_LIB_PROP_NOT_SET));
   }
  //+------------------------------------------------------------------+
  //| Return the request deviation size description                    |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqDeviationDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_DEVIATION)+": "+(string)this.GetProperty(PEND_REQ_PROP_MQL_REQ_DEVIATION);
   }
  //+------------------------------------------------------------------+
  //| Return the request order type description                        |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqTypeOrderDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_TYPE)+": "+OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE));
   }
  //+------------------------------------------------------------------+
  //| Return the request order filling mode description                |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqTypeFillingDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_TYPE_FILLING)+": "+OrderTypeFillingDescription((ENUM_ORDER_TYPE_FILLING)this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE_FILLING));
   }
  //+------------------------------------------------------------------+
  //| Return the request order lifetime type description               |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqTypeTimeDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_TYPE_TIME)+": "+OrderTypeTimeDescription((ENUM_ORDER_TYPE_TIME)this.GetProperty(PEND_REQ_PROP_MQL_REQ_TYPE_TIME));
   }
  //+------------------------------------------------------------------+
  //| Return the request order expiration time description             |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqExpirationDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_EXPIRATION)+": "+
          (this.GetProperty(PEND_REQ_PROP_MQL_REQ_EXPIRATION)>0 ? 
           ::TimeToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_EXPIRATION)) : 
           CMessage::Text(MSG_LIB_PROP_NOT_SET));
   }
  //+------------------------------------------------------------------+
  //| Return the request volume description                            |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqVolumeDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_VOLUME)+": "+
          (this.GetProperty(PEND_REQ_PROP_MQL_REQ_VOLUME)>0 ? 
           ::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_VOLUME),this.m_digits_lot) : 
           CMessage::Text(MSG_LIB_PROP_NOT_SET));
   }
  //+------------------------------------------------------------------+
  //| Return the request price value description                       |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqPriceDescription(void) const
   {
      return CMessage::Text(MSG_LIB_TEXT_REQUEST_PRICE)+": "+
          (this.GetProperty(PEND_REQ_PROP_MQL_REQ_PRICE)>0 ? 
           ::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_PRICE),this.m_digits) : 
           CMessage::Text(MSG_LIB_PROP_NOT_SET));
   }
  //+------------------------------------------------------------------+
  //| Return the request StopLimit order price description             |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqStopLimitDescription(void) const
   {
     return CMessage::Text(MSG_LIB_TEXT_REQUEST_STOPLIMIT)+": "+
          (this.GetProperty(PEND_REQ_PROP_MQL_REQ_STOPLIMIT)>0 ? 
           ::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_STOPLIMIT),this.m_digits) : 
           CMessage::Text(MSG_LIB_PROP_NOT_SET));
   }
  //+------------------------------------------------------------------+
  //| Return the request StopLoss order price description              |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqStopLossDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_SL)+": "+
          (this.GetProperty(PEND_REQ_PROP_MQL_REQ_SL)>0 ? 
           ::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_SL),this.m_digits) : 
           CMessage::Text(MSG_LIB_PROP_NOT_SET));
    }
  //+------------------------------------------------------------------+
  //| Return the request TakeProfit order price description            |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqTakeProfitDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_TP)+": "+
          (this.GetProperty(PEND_REQ_PROP_MQL_REQ_TP)>0 ? 
           ::DoubleToString(this.GetProperty(PEND_REQ_PROP_MQL_REQ_TP),this.m_digits) : 
           CMessage::Text(MSG_LIB_PROP_NOT_SET));
   }
  //+------------------------------------------------------------------+
  //| Return the description of a trading instrument name in a request |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqSymbolDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_SYMBOL)+": "+this.GetProperty(PEND_REQ_PROP_MQL_REQ_SYMBOL);
   }
  //+------------------------------------------------------------------+
  //| Return the request order comment description                     |
  //+------------------------------------------------------------------+
  string CPendRequest::MqlReqCommentDescription(void) const
   {
    return CMessage::Text(MSG_LIB_TEXT_REQUEST_COMMENT)+": "+
          (this.GetProperty(PEND_REQ_PROP_MQL_REQ_COMMENT)!="" && this.GetProperty(PEND_REQ_PROP_MQL_REQ_COMMENT)!=NULL ? 
           "\""+this.GetProperty(PEND_REQ_PROP_MQL_REQ_COMMENT)+"\"" : 
           CMessage::Text(MSG_LIB_PROP_NOT_SET));
   }
  //+------------------------------------------------------------------+
  //| Display the pending request properties in the journal            |
  //+------------------------------------------------------------------+
  void CPendRequest::Print(const bool full_prop=false,const bool dash=false)
   {
     int header_code=
      (
        this.GetProperty(PEND_REQ_PROP_STATUS)==PEND_REQ_STATUS_OPEN   ? MSG_LIB_TEXT_PEND_REQUEST_STATUS_OPEN   :
        this.GetProperty(PEND_REQ_PROP_STATUS)==PEND_REQ_STATUS_CLOSE  ? MSG_LIB_TEXT_PEND_REQUEST_STATUS_CLOSE  :
        this.GetProperty(PEND_REQ_PROP_STATUS)==PEND_REQ_STATUS_SLTP   ? MSG_LIB_TEXT_PEND_REQUEST_STATUS_SLTP   :
        this.GetProperty(PEND_REQ_PROP_STATUS)==PEND_REQ_STATUS_PLACE  ? MSG_LIB_TEXT_PEND_REQUEST_STATUS_PLACE  :
        this.GetProperty(PEND_REQ_PROP_STATUS)==PEND_REQ_STATUS_REMOVE ? MSG_LIB_TEXT_PEND_REQUEST_STATUS_REMOVE :
        this.GetProperty(PEND_REQ_PROP_STATUS)==PEND_REQ_STATUS_MODIFY ? MSG_LIB_TEXT_PEND_REQUEST_STATUS_MODIFY :
        WRONG_VALUE
      );
     ::Print("============= \"",CMessage::Text(header_code),"\" =============");
     int begin=0, end=PEND_REQ_PROP_INTEGER_TOTAL;
     for(int i=begin; i<end; i++)
     {
      ENUM_PEND_REQ_PROP_INTEGER prop=(ENUM_PEND_REQ_PROP_INTEGER)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
     ::Print("------");
    begin=end; end+=PEND_REQ_PROP_DOUBLE_TOTAL;
    for(int i=begin; i<end; i++)
      {
        ENUM_PEND_REQ_PROP_DOUBLE prop=(ENUM_PEND_REQ_PROP_DOUBLE)i;
        if(!full_prop && !this.SupportProperty(prop)) continue;
        ::Print(this.GetPropertyDescription(prop));
      }
    ::Print("------");
    begin=end; end+=PEND_REQ_PROP_STRING_TOTAL;
    for(int i=begin; i<end; i++)
      {
        ENUM_PEND_REQ_PROP_STRING prop=(ENUM_PEND_REQ_PROP_STRING)i;
        if(!full_prop && !this.SupportProperty(prop)) continue;
        ::Print(this.GetPropertyDescription(prop));
      }
    this.PrintActivations();
    ::Print("================== ",CMessage::Text(MSG_LIB_PARAMS_LIST_END),": \"",CMessage::Text(header_code),"\" ==================\n");
   }
  //+------------------------------------------------------------------+
  //| Display request activation parameters in the journal             |
  //+------------------------------------------------------------------+
  void CPendRequest::PrintActivations(void)
   {
    //--- Get the size of the activation conditions data array's first dimension,
    //--- if it exceeds zero, send all data written in the data array to the journal
    int range=::ArrayRange(this.m_activated_control,0);
    if(range>0)
      {
       ::Print("--- ",CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_ACTIVATION_TERMS)," ---");
        for(int i=0;i<range;i++)
         {
          ENUM_PEND_REQ_ACTIVATION_SOURCE source = (ENUM_PEND_REQ_ACTIVATION_SOURCE)this.m_activated_control[i][0];
          string type = "";
          switch(source)
          {
              case PEND_REQ_ACTIVATION_SOURCE_ACCOUNT : type = CMessage::Text(MSG_ACC_ACCOUNT);      break;
              case PEND_REQ_ACTIVATION_SOURCE_SYMBOL  : type = CMessage::Text(MSG_LIB_PROP_SYMBOL);  break;
              case PEND_REQ_ACTIVATION_SOURCE_EVENT   : type = CMessage::Text(MSG_EVN_EVENT);       break;
              default                                 : type = "";                                  break;
          }
          string index_str = "#" + (string)(i + 1) + ". ";
          ::Print(" - ", CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_CRITERION), " ", index_str, type, ": ", this.GetActivationPropertyDescription(i));
         }
      }
     ::Print("");
   }
  //+------------------------------------------------------------------+
  //| Set a controlled property, values                                |
  //| and comparison method for activating a pending request           |
  //+------------------------------------------------------------------+
  void CPendRequest::SetNewActivationProperties(const ENUM_PEND_REQ_ACTIVATION_SOURCE source,
                                                const int property,
                                                const double control_value,
                                                const ENUM_COMPARER_TYPE comparer_type,
                                                const double actual_value)
   {
    int range=::ArrayRange(this.m_activated_control,0);
    if(::ArrayResize(this.m_activated_control,range+1,10)==WRONG_VALUE)
      {
       if(this.m_log_level>LOG_LEVEL_NO_MSG)
          ::Print(DFUN,CMessage::Text(MSG_LIB_TEXT_PEND_REQUEST_FAILED_ADD_PARAMS));
       return;
      }
    this.m_activated_control[range][0]=source;
    this.m_activated_control[range][1]=property;
    this.m_activated_control[range][2]=comparer_type;
    this.m_activated_control[range][3]=control_value;
    this.m_activated_control[range][4]=actual_value;
   }
  //+---------------------------------------------------------------------+
  //| Set a controlled property to activate a request                     |
  //+---------------------------------------------------------------------+
  bool CPendRequest::SetActivationProperty(const uint index,const ENUM_PEND_REQ_ACTIVATION_SOURCE source,const int property)
   {
    int range=::ArrayRange(this.m_activated_control,0);
    if((int)index>range-1 || range==0)
      {
       if(this.m_log_level>LOG_LEVEL_NO_MSG)
          ::Print(DFUN,CMessage::Text(4002));
       return false;
      }
    this.m_activated_control[index][0]=source;
    this.m_activated_control[index][1]=property;
    return true;
   }
  //+------------------------------------------------------------------+
  //| Set the object property comparison type                          |
  //| with the actual one for a pending request activation             |
  //+------------------------------------------------------------------+
  bool CPendRequest::SetActivationComparerType(const uint index,const ENUM_COMPARER_TYPE comparer_type)
   {
    int range=::ArrayRange(this.m_activated_control,0);
    if((int)index>range-1 || range==0)
      {
        if(this.m_log_level>LOG_LEVEL_NO_MSG)
          ::Print(DFUN,CMessage::Text(4002));
        return false;
      }
    this.m_activated_control[index][2]=comparer_type;
    return true;
   }
  //+------------------------------------------------------------------+
  //| Set the controlled property                                      |
  //| value for activating a pending request                           |
  //+------------------------------------------------------------------+
  bool CPendRequest::SetActivationControlValue(const uint index,const double value)
   {
    int range=::ArrayRange(this.m_activated_control,0);
    if((int)index>range-1 || range==0)
      {
       if(this.m_log_level>LOG_LEVEL_NO_MSG)
          ::Print(DFUN,CMessage::Text(4002));
        return false;
      }
    this.m_activated_control[index][3]=value;
    return true;
   }
  //+------------------------------------------------------------------+
  //| Set the actual value                                             |
  //| of a controlled property in the request object                   |
  //+------------------------------------------------------------------+
  bool CPendRequest::SetActivationActualValue(const uint index,const double value)
   {
    int range=::ArrayRange(this.m_activated_control,0);
    if((int)index>range-1 || range==0)
      {
        if(this.m_log_level>LOG_LEVEL_NO_MSG)
          ::Print(DFUN,CMessage::Text(4002));
        return false;
      }
    this.m_activated_control[index][4]=value;
    return true;
   }
  //+------------------------------------------------------------------+
  //| Return a pending request activation source                       |
  //+------------------------------------------------------------------+
  ENUM_PEND_REQ_ACTIVATION_SOURCE CPendRequest::GetActivationSource(const uint index) const
   {
    int range=::ArrayRange(this.m_activated_control,0);
    if((int)index>range-1 || range==0)
      {
       if(this.m_log_level>LOG_LEVEL_NO_MSG)
          ::Print(DFUN,CMessage::Text(4002));
       return WRONG_VALUE;
      }
    return (ENUM_PEND_REQ_ACTIVATION_SOURCE)this.m_activated_control[index][0];
   }
  //+------------------------------------------------------------------+
  //| Return a controlled property to activate a request               |
  //+------------------------------------------------------------------+
  int CPendRequest::GetActivationProperty(const uint index) const
   {
    int range=::ArrayRange(this.m_activated_control,0);
    if((int)index>range-1 || range==0)
      {
       if(this.m_log_level>LOG_LEVEL_NO_MSG)
          ::Print(DFUN,CMessage::Text(4002));
       return WRONG_VALUE;
      }
    return (int)this.m_activated_control[index][1];
   }
  //+------------------------------------------------------------------+
  //| Return the object property comparison type                       |
  //| with the actual one for a pending request activation             |
  //+------------------------------------------------------------------+
  ENUM_COMPARER_TYPE CPendRequest::GetActivationComparerType(const uint index) const
   {
    int range=::ArrayRange(this.m_activated_control,0);
    if((int)index>range-1 || range==0)
      {
       if(this.m_log_level>LOG_LEVEL_NO_MSG)
         ::Print(DFUN,CMessage::Text(4002));
      return WRONG_VALUE;
     }
    return (ENUM_COMPARER_TYPE)this.m_activated_control[index][2];
   }
  //+------------------------------------------------------------------+
  //| Return the controlled property                                   |
  //| value for activating a pending request                           |
  //+------------------------------------------------------------------+
  double CPendRequest::GetActivationControlValue(const uint index) const
   {
    int range=::ArrayRange(this.m_activated_control,0);
    if((int)index>range-1 || range==0)
      {
       if(this.m_log_level>LOG_LEVEL_NO_MSG)
          ::Print(DFUN,CMessage::Text(4002));
       return EMPTY_VALUE;
      }
    return this.m_activated_control[index][3];
   }
  //+------------------------------------------------------------------+
  //| Return the actual value                                          |
  //| of a controlled property in the request object                   |
  //+------------------------------------------------------------------+
  double CPendRequest::GetActivationActualValue(const uint index) const
   {
    int range=::ArrayRange(this.m_activated_control,0);
    if((int)index>range-1 || range==0)
      {
       if(this.m_log_level>LOG_LEVEL_NO_MSG)
          ::Print(DFUN,CMessage::Text(4002));
       return EMPTY_VALUE;
      }
    return this.m_activated_control[index][4];
   }
  //+------------------------------------------------------------------+
  //| Compare two data source values by a comparison type              |
  //+------------------------------------------------------------------+
  bool CPendRequest::IsCompared(const double actual_value,const double control_value,const ENUM_COMPARER_TYPE compare) const
   {
    switch((int)compare)
      {
       case EQUAL           :  return(actual_value<control_value || actual_value>control_value ? false : true);
       case NO_EQUAL        :  return(actual_value<control_value || actual_value>control_value ? true : false);
       case MORE            :  return(actual_value>control_value ? true  : false);
       case LESS            :  return(actual_value<control_value ? true  : false);
       case EQUAL_OR_MORE   :  return(actual_value<control_value ? false : true);
       case EQUAL_OR_LESS   :  return(actual_value>control_value ? false : true);
       default              :  break;
      }
    return false;
   }
  //+------------------------------------------------------------------------+
  //| Return the flag of a successful check of a controlled object property  |
  //| and the appropriate real property                                      |
  //+------------------------------------------------------------------------+
  bool CPendRequest::IsComparisonCompleted(const uint index) const
   {
    //--- If the controlled property is not set, return 'false'
    if(this.m_activated_control[index][1]==MSG_LIB_PROP_NOT_SET)
      return false;
    //--- Return the result of the specified comparison of a controlled property value with a real one
    ENUM_COMPARER_TYPE comparer=(ENUM_COMPARER_TYPE)this.m_activated_control[index][2];
    return this.IsCompared(this.m_activated_control[index][4],this.m_activated_control[index][3],comparer);
   }
  //+------------------------------------------------------------------+
  //| Return the flag of successful check of all controlled properties |
  //| of the object and the appropriate actual properties              |
  //+------------------------------------------------------------------+
  bool CPendRequest::IsAllComparisonCompleted(void) const
   {
    bool res=true;
    int range=::ArrayRange(this.m_activated_control,0);
    if(range==0)
       return false;
    for(int i=0;i<range;i++)
       res &=this.IsComparisonCompleted(i);
    return res;
   }
  //+-------------------------------------------------------------------+
  //|Return the number of decimal places of a controlled property       |
  //+-------------------------------------------------------------------+
  int CPendRequest::DigitsControlledValue(const uint index) const
   {
    int dg=0;
    //--- Depending on the activation condition source, check the activation conditions
    //--- and write the required number of decimal places to the result
    switch((int)this.m_activated_control[index][0])
      {
       //--- Account. If an activation condition is an integer value, then 0,
       //--- if it is a real value, then the number of decimal places in the current currency
       case PEND_REQ_ACTIVATION_SOURCE_ACCOUNT      :
         dg=(this.m_activated_control[index][1]<PEND_REQ_ACTIVATE_BY_ACCOUNT_BALANCE  ?  0 : this.m_digits_currency);
         break;
       //--- Symbol. Depending on a condition, write either a number of decimal places in a symbol quote,
       //--- or a number of decimal places in the current currency, or a number of decimal places in the lot value, or zero
       case PEND_REQ_ACTIVATION_SOURCE_SYMBOL       :
         //--- digits
         if(
           (this.m_activated_control[index][1]<PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_DEALS &&
            this.m_activated_control[index][1]>PEND_REQ_ACTIVATE_BY_SYMBOL_EMPTY)                     ||
            this.m_activated_control[index][1]==PEND_REQ_ACTIVATE_BY_SYMBOL_OPTION_STRIKE             ||
            this.m_activated_control[index][1]>PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_SELL_ORDERS_VOLUME ||
           (this.m_activated_control[index][1]>PEND_REQ_ACTIVATE_BY_SYMBOL_TRADE_FREEZE_LEVEL &&
            this.m_activated_control[index][1]<PEND_REQ_ACTIVATE_BY_SYMBOL_VOLUME_REAL)
           ) dg=this.m_digits;
         //--- not digits
         else if(
            this.m_activated_control[index][1]>PEND_REQ_ACTIVATE_BY_SYMBOL_LASTLOW)
           {
            //--- digits currency
            if(
               (this.m_activated_control[index][1]>PEND_REQ_ACTIVATE_BY_SYMBOL_OPTION_STRIKE    && 
                this.m_activated_control[index][1]<PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_VOLUME)  ||
               this.m_activated_control[index][1]==PEND_REQ_ACTIVATE_BY_SYMBOL_SESSION_TURNOVER
              ) dg=this.m_digits_currency;
            //--- digits lots
            else
               dg=(this.m_digits_lot==0 ? 1 : this.m_digits_lot);
           }
         //--- 0
         else
            dg=0;
         break;
       //--- Default is zero
       default:
         break;
      }
    return dg;
   }
  //+------------------------------------------------------------------+
  //| Return the controlled property description by index              |
  //+------------------------------------------------------------------+
  string CPendRequest::GetActivationPropertyDescription(const uint index) const
   {
     //--- Get the activation source and, depending on that source, create a description text for a type of comparison with the reference value
     ENUM_PEND_REQ_ACTIVATION_SOURCE source=(ENUM_PEND_REQ_ACTIVATION_SOURCE)this.m_activated_control[index][0];
     string value=
     (
      source==PEND_REQ_ACTIVATION_SOURCE_EVENT     ?  "" : 
      (
       this.m_activated_control[index][1]==MSG_LIB_PROP_NOT_SET ? ""  :
       this.GetActivationComparerTypeDescription(index)+this.GetActivationControlValueDescription(index)
      )
     );
     //--- Return the activation conditions description + comparison type + controlled value
     return
     (
      source==PEND_REQ_ACTIVATION_SOURCE_ACCOUNT   ?  CMessage::Text((ENUM_PEND_REQ_ACTIVATE_BY_ACCOUNT_PROP)this.m_activated_control[index][1])+value   :
      source==PEND_REQ_ACTIVATION_SOURCE_SYMBOL    ?  CMessage::Text((ENUM_PEND_REQ_ACTIVATE_BY_SYMBOL_PROP)this.m_activated_control[index][1])+value    :
      source==PEND_REQ_ACTIVATION_SOURCE_EVENT     ?  CMessage::Text((ENUM_PEND_REQ_ACTIVATE_BY_EVENT)this.m_activated_control[index][1])+value          :
      ""
     );
   }
  //+------------------------------------------------------------------+
  //| Return the comparison type description                           |
  //+------------------------------------------------------------------+
  string CPendRequest::GetActivationComparerTypeDescription(const uint index) const
   {
     return ComparisonTypeDescription((ENUM_COMPARER_TYPE)this.m_activated_control[index][2]);
   }
  //+------------------------------------------------------------------+
  //| Return a controlled property value description in an object      |
  //+------------------------------------------------------------------+
  string CPendRequest::GetActivationControlValueDescription(const uint index) const
   {
    return
     (
      this.m_activated_control[index][3]!=EMPTY_VALUE ? 
      (
       this.m_activated_control[index][0]==PEND_REQ_ACTIVATION_SOURCE_SYMBOL &&
       this.m_activated_control[index][1]==PEND_REQ_ACTIVATE_BY_SYMBOL_TIME   ? 
       ::TimeToString((ulong)this.m_activated_control[index][3])              :
       ::DoubleToString(this.m_activated_control[index][3],this.DigitsControlledValue(index))
      )  :  ""
     );
   }
  //+------------------------------------------------------------------+
  //|Return an actual controlled property value description            |
  //+------------------------------------------------------------------+
  string CPendRequest::GetActivationActualValueDescription(const uint index) const
   {
    return
     (
      this.m_activated_control[index][4]!=EMPTY_VALUE ? 
      (
       this.m_activated_control[index][0]==PEND_REQ_ACTIVATION_SOURCE_SYMBOL &&
       this.m_activated_control[index][1]==PEND_REQ_ACTIVATE_BY_SYMBOL_TIME   ? 
       ::TimeToString((ulong)this.m_activated_control[index][4])              :
       ::DoubleToString(this.m_activated_control[index][4],this.DigitsControlledValue(index))
      )  :  ""
     );
   }
  //+------------------------------------------------------------------+
  //| Set a new value changed by the shift (+/-),                      |
  //| for all order prices                                             |
  //+------------------------------------------------------------------+
  void CPendRequest::SetAllMqlPrices(const double shift)
   {
    this.SetMqlPrice(this.GetProperty(PEND_REQ_PROP_MQL_REQ_PRICE)-shift);
    if(this.GetProperty(PEND_REQ_PROP_MQL_REQ_SL)!=0)
        this.SetMqlSL(this.GetProperty(PEND_REQ_PROP_MQL_REQ_SL)-shift);
    if(this.GetProperty(PEND_REQ_PROP_MQL_REQ_TP)!=0)
        this.SetMqlTP(this.GetProperty(PEND_REQ_PROP_MQL_REQ_TP)-shift);
    if(this.GetProperty(PEND_REQ_PROP_MQL_REQ_STOPLIMIT)!=0)
        this.SetMqlStopLimit(this.GetProperty(PEND_REQ_PROP_MQL_REQ_STOPLIMIT)-shift);
   }
  //+------------------------------------------------------------------+
  //| Adjust order prices by the current price                         |
  //+------------------------------------------------------------------+
  void CPendRequest::CorrectMqlPricesByCurrentPrice(const double price)
   {
    ENUM_ORDER_TYPE type=this.m_request.type;
    if(!this.m_follow || (type<ORDER_TYPE_BUY_LIMIT && type>ORDER_TYPE_SELL_STOP_LIMIT))
        return;
    this.SetAllMqlPrices(this.PriceCreate()-price);
   }
 #endif // CPENDREQUEST_MQH_IMPLEMENTATION
#endif // __PENDREQUEST_MQH__