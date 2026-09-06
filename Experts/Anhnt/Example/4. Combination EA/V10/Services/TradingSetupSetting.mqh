//+------------------------------------------------------------------+
//|                                          TradingSetupSetting.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = 1 Symbol's StopLost + Trailing config row - held in |
//| CTrading's own list. Same pattern as CIndicatorSetting/           |
//| CSymbolTFSetting - a plain data row, no Layer 1 pointers.        |
//+------------------------------------------------------------------+
#ifndef __TRADINGSETUPSETTING_MQH__
#define __TRADINGSETUPSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib\Base\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib\Services\DELib\TimeseriesDELib.mqh>

 #ifndef ENUM_STOPLOST_TRAILING_MODE_DECLARATION
 #define ENUM_STOPLOST_TRAILING_MODE_DECLARATION
  enum ENUM_STOPLOST_TRAILING_MODE
   {
    SL_MODE_FIXED = 0,
    SL_MODE_INDICATOR,
   };
 #endif // ENUM_STOPLOST_TRAILING_MODE_DECLARATION

 #ifndef CTRADINGSETUPSETTING_MQH_DECLARATION
 #define CTRADINGSETUPSETTING_MQH_DECLARATION
 //+------------------------------------------------------------------------------------+
 //| CTradingSetupSetting - 1 Symbol's StopLost+Trailing config row.                    |
 //| StopLost is computed ONCE, at OrderSend/PositionModify time. Trailing is           |
 //| re-evaluated every tick, only ever moving SL in the favorable direction            |
 //| (Buy: up, Sell: down) once past trail_start, and only by at least trail_step.      |
 //+------------------------------------------------------------------------------------+
 class CTradingSetupSetting : public CBaseObj
   {
     private:
       string           m_symbol;                 // IDENTITY
       //--- StopLost
       bool             m_sl_active;
       ENUM_STOPLOST_TRAILING_MODE     m_sl_mode;
       int              m_sl_fixed_pts;            // Fixed: distance from Mid, in points
       ENUM_TIMEFRAMES  m_sl_ind_tf;               // ByInd: TF of the driving Indicator
       ENUM_INDICATOR   m_sl_ind_type;             // ByInd: Indicator type (e.g. IND_ATR)
       MqlParam         m_sl_ind_params[];         // ByInd: raw params (period, etc.)
       double           m_sl_ind_multiplier;       // ByInd: multiplier on the Indicator's value

       //--- Trailing
       bool             m_trail_active;
       ENUM_STOPLOST_TRAILING_MODE     m_trail_mode;
       int              m_trail_fixed_offset_pts;  // Fixed: offset from current price
       ENUM_TIMEFRAMES  m_trail_ind_tf;            // ByInd: TF of the driving Indicator
       ENUM_INDICATOR   m_trail_ind_type;          // ByInd: Indicator type (e.g. IND_MA, IND_SAR)
       MqlParam         m_trail_ind_params[];      // ByInd: raw params
       int              m_trail_ind_offset_pts;    // ByInd: offset from the Indicator's line
       int              m_trail_start_pts;         // profit (points) required before trailing starts
       int              m_trail_step_pts;          // minimum improvement (points) before moving SL

     public:
                         CTradingSetupSetting(void);
                        ~CTradingSetupSetting(void) {}

      //--- identity (raw) - the ONLY thing used for matching, never text
       string            Symbol(void)                                const { return m_symbol; }
       void              Symbol(const string sym)                          { m_symbol = sym;   }
       bool              MatchesIdentity(const string sym)             const { return m_symbol == sym; }

      //--- StopLost
       bool              StopLostActive(void)                          const { return m_sl_active; }
       void              StopLostActive(const bool v)                       { m_sl_active = v;     }
       ENUM_STOPLOST_TRAILING_MODE      StopLostMode(void)                            const { return m_sl_mode; }
       void              StopLostMode(const ENUM_STOPLOST_TRAILING_MODE mode)               { m_sl_mode = mode;  }
       int               StopLostFixedPts(void)                        const { return m_sl_fixed_pts; }
       void              StopLostFixedPts(const int pts)                     { m_sl_fixed_pts = pts;   }
       ENUM_TIMEFRAMES   StopLostIndTF(void)                           const { return m_sl_ind_tf; }
       void              StopLostIndTF(const ENUM_TIMEFRAMES tf)             { m_sl_ind_tf = tf;    }
       ENUM_INDICATOR    StopLostIndType(void)                         const { return m_sl_ind_type; }
       void              StopLostIndType(const ENUM_INDICATOR type)          { m_sl_ind_type = type;  }
       void              GetStopLostIndParams(MqlParam &out[])         const;
       void              SetStopLostIndParams(MqlParam &params[]);
       double            StopLostIndMultiplier(void)                   const { return m_sl_ind_multiplier; }
       void              StopLostIndMultiplier(const double mult)            { m_sl_ind_multiplier = mult;  }

      //--- Trailing
       bool              TrailingActive(void)                          const { return m_trail_active; }
       void              TrailingActive(const bool v)                       { m_trail_active = v;     }
       ENUM_STOPLOST_TRAILING_MODE      TrailingMode(void)                            const { return m_trail_mode; }
       void              TrailingMode(const ENUM_STOPLOST_TRAILING_MODE mode)               { m_trail_mode = mode;  }
       int               TrailingFixedOffsetPts(void)                  const { return m_trail_fixed_offset_pts; }
       void              TrailingFixedOffsetPts(const int pts)               { m_trail_fixed_offset_pts = pts;   }
       ENUM_TIMEFRAMES   TrailingIndTF(void)                           const { return m_trail_ind_tf; }
       void              TrailingIndTF(const ENUM_TIMEFRAMES tf)             { m_trail_ind_tf = tf;    }
       ENUM_INDICATOR    TrailingIndType(void)                         const { return m_trail_ind_type; }
       void              TrailingIndType(const ENUM_INDICATOR type)          { m_trail_ind_type = type;  }
       void              GetTrailingIndParams(MqlParam &out[])         const;
       void              SetTrailingIndParams(MqlParam &params[]);
       int               TrailingIndOffsetPts(void)                    const { return m_trail_ind_offset_pts; }
       void              TrailingIndOffsetPts(const int pts)                 { m_trail_ind_offset_pts = pts;   }
       int               TrailingStartPts(void)                        const { return m_trail_start_pts; }
       void              TrailingStartPts(const int pts)                     { m_trail_start_pts = pts;   }
       int               TrailingStepPts(void)                         const { return m_trail_step_pts; }
       void              TrailingStepPts(const int pts)                      { m_trail_step_pts = pts;   }

       virtual void      Print(const bool full_prop=false, const bool dash=false);
   };
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CTradingSetupSetting::CTradingSetupSetting(void) : m_sl_active(false), m_sl_mode(SL_MODE_FIXED), m_sl_fixed_pts(0),
                                                     m_sl_ind_tf(PERIOD_CURRENT), m_sl_ind_type(WRONG_VALUE),
                                                     m_sl_ind_multiplier(1.0),
                                                     m_trail_active(false), m_trail_mode(SL_MODE_FIXED),
                                                     m_trail_fixed_offset_pts(0),
                                                     m_trail_ind_tf(PERIOD_CURRENT), m_trail_ind_type(WRONG_VALUE),
                                                     m_trail_ind_offset_pts(0), m_trail_start_pts(0), m_trail_step_pts(0)
   {
     this.m_type = OBJECT_DE_TYPE_TRADING_SETUP_SETTING;
   }
 //+------------------------------------------------------------------+
 //| StopLost ByInd raw params                                        |
 //+------------------------------------------------------------------+
 void CTradingSetupSetting::GetStopLostIndParams(MqlParam &out[]) const
   {
     int total = ::ArraySize(m_sl_ind_params);
     ::ArrayResize(out, total);
     for(int i = 0; i < total; i++)
        out[i] = m_sl_ind_params[i];
   }
 void CTradingSetupSetting::SetStopLostIndParams(MqlParam &params[])
   {
     int total = ::ArraySize(params);
     ::ArrayResize(m_sl_ind_params, total);
     for(int i = 0; i < total; i++)
        m_sl_ind_params[i] = params[i];
   }
 //+------------------------------------------------------------------+
 //| Trailing ByInd raw params                                        |
 //+------------------------------------------------------------------+
 void CTradingSetupSetting::GetTrailingIndParams(MqlParam &out[]) const
   {
     int total = ::ArraySize(m_trail_ind_params);
     ::ArrayResize(out, total);
     for(int i = 0; i < total; i++)
        out[i] = m_trail_ind_params[i];
   }
 void CTradingSetupSetting::SetTrailingIndParams(MqlParam &params[])
   {
     int total = ::ArraySize(params);
     ::ArrayResize(m_trail_ind_params, total);
     for(int i = 0; i < total; i++)
        m_trail_ind_params[i] = params[i];
   }
 //+------------------------------------------------------------------+
 //| Debug dump                                                        |
 //+------------------------------------------------------------------+
 void CTradingSetupSetting::Print(const bool full_prop=false, const bool dash=false)
   {
     ::Print((dash ? " - " : ""), "CTradingSetupSetting::Print symbol=", m_symbol,
             " sl_mode=", EnumToString(m_sl_mode), " trail_active=", m_trail_active,
             " trail_mode=", EnumToString(m_trail_mode));
   }
 #endif // CTRADINGSETUPSETTING_MQH_DECLARATION
#endif // __TRADINGSETUPSETTING_MQH__
