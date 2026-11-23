//+------------------------------------------------------------------+
//|                                               MovementSeries.mqh |
//| One leg between two Swings of one timeframe, as Python decided   |
//| it (Impulse / Pullback, how deep) - pure data.                   |
//| Compare for CArrayObj::Sort/Search/InsertSort                    |
//+------------------------------------------------------------------+
#ifndef __MOVEMENTSERIES_MQH__
#define __MOVEMENTSERIES_MQH__
 #include "..\..\Bases\BaseObj.mqh"
 #include "..\..\Defines\MarketStructureDefines.mqh"
 #include "..\..\Defines\CommonDefines.mqh"
#ifndef CMOVEMENTSERIES_MQH_DECLARATION
#define CMOVEMENTSERIES_MQH_DECLARATION
 class CMovementSeries : public CBaseObj
  {
   private:
     datetime                m_time;          // bar time at which the swing after the leg was confirmed: the leg is final from then on
     ENUM_TIMEFRAMES         m_timeframe;
     datetime                m_start_time;    // the swing the leg starts at
     double                  m_start_price;
     datetime                m_end_time;      // the swing it ends at
     double                  m_end_price;
     ENUM_SIGNAL_DIR         m_direction;     // BUY = it goes up, SELL = it goes down
     ENUM_MOVE_TYPE          m_move;          // Impulse / Pullback, NONE when the market is in a range
     double                  m_length_atr;    // its length in ATRs
     int                     m_bars;          // its length in bars
     double                  m_retracement;   // its length against the leg before it, 0.5 = half of it
     ENUM_PULLBACK_DEPTH     m_depth;         // how deep a pullback is, NONE for the others
   public:
     datetime                Time(void)       const { return this.m_time;        }
     ENUM_TIMEFRAMES         Timeframe(void)  const { return this.m_timeframe;   }
     datetime                StartTime(void)  const { return this.m_start_time;  }
     double                  StartPrice(void) const { return this.m_start_price; }
     datetime                EndTime(void)    const { return this.m_end_time;    }
     double                  EndPrice(void)   const { return this.m_end_price;   }
     ENUM_SIGNAL_DIR         Direction(void)  const { return this.m_direction;   }
     ENUM_MOVE_TYPE          Move(void)       const { return this.m_move;        }
     double                  LengthATR(void)  const { return this.m_length_atr;  }
     int                     Bars(void)       const { return this.m_bars;        }
     double                  Retracement(void) const { return this.m_retracement; }
     ENUM_PULLBACK_DEPTH     Depth(void)      const { return this.m_depth;       }
   //--- The words: how deep a pullback is, and the short text of the leg (the corner label, the tooltip of its line)
     string                  DepthText(void)  const;
     string                  ShortText(void)  const;
   //--- By the end of the leg, then its start, then the timeframe: one entry per leg and TF
     virtual int             Compare(const CObject *node,const int mode=0) const;
                             CMovementSeries(const datetime time,const ENUM_TIMEFRAMES timeframe,const datetime start_time,const double start_price,
                                             const datetime end_time,const double end_price,const ENUM_SIGNAL_DIR direction,const ENUM_MOVE_TYPE move,
                                             const double length_atr,const int bars,const double retracement,const ENUM_PULLBACK_DEPTH depth);
  };
#endif // CMOVEMENTSERIES_MQH_DECLARATION
#ifndef CMOVEMENTSERIES_MQH_IMPLEMENTATION
#define CMOVEMENTSERIES_MQH_IMPLEMENTATION
 CMovementSeries::CMovementSeries(const datetime time,const ENUM_TIMEFRAMES timeframe,const datetime start_time,const double start_price,
                                  const datetime end_time,const double end_price,const ENUM_SIGNAL_DIR direction,const ENUM_MOVE_TYPE move,
                                  const double length_atr,const int bars,const double retracement,const ENUM_PULLBACK_DEPTH depth) : m_time(time),
                                                                                                                                 m_timeframe(timeframe),
                                                                                                                                 m_start_time(start_time),
                                                                                                                                 m_start_price(start_price),
                                                                                                                                 m_end_time(end_time),
                                                                                                                                 m_end_price(end_price),
                                                                                                                                 m_direction(direction),
                                                                                                                                 m_move(move),
                                                                                                                                 m_length_atr(length_atr),
                                                                                                                                 m_bars(bars),
                                                                                                                                 m_retracement(retracement),
                                                                                                                                 m_depth(depth)
  {
  }
 string CMovementSeries::DepthText(void) const
  {
   return (this.m_depth==PULLBACK_DEPTH_AGGRESSIVE ? "aggressive" : this.m_depth==PULLBACK_DEPTH_HEALTHY ? "healthy" : this.m_depth==PULLBACK_DEPTH_DEEP ? "deep" :
           this.m_depth==PULLBACK_DEPTH_WEAK ? "weak" : this.m_depth==PULLBACK_DEPTH_INVALID ? "invalid" : "");
  }
 string CMovementSeries::ShortText(void) const
  {
   if(this.m_move==MOVE_TYPE_PULLBACK)
      return "Pullback "+::DoubleToString(this.m_retracement,2)+" ("+this.DepthText()+")";
   if(this.m_move==MOVE_TYPE_IMPULSE)
      return "Impulse "+::DoubleToString(this.m_length_atr,1)+" ATR";
   return "Leg "+::DoubleToString(this.m_length_atr,1)+" ATR";
  }
 int CMovementSeries::Compare(const CObject *node,const int mode=0) const
  {
   const CMovementSeries *compared=node;
   if(this.m_end_time!=compared.m_end_time)
      return (this.m_end_time>compared.m_end_time ? 1 : -1);
   if(this.m_start_time!=compared.m_start_time)
      return (this.m_start_time>compared.m_start_time ? 1 : -1);
   if(this.m_timeframe==compared.m_timeframe)
      return 0;
   return (this.m_timeframe>compared.m_timeframe ? 1 : -1);
  }
#endif // CMOVEMENTSERIES_MQH_IMPLEMENTATION
#endif // __MOVEMENTSERIES_MQH__
