//+------------------------------------------------------------------+
//|                                                   SignalBase.mqh |
//|  Base class for indicator signal wrappers (Option B pattern).   |
//|  A genuine time series, mirroring CBarSeriesDE's grow-only model:|
//|  m_current_val is the live, still-forming bar - safe to refresh  |
//|  every tick, never stored. m_hist_* arrays are permanent history,|
//|  oldest->newest, one entry per bar where the direction actually  |
//|  FLIPPED (sparse - most bars have no signal, only a flip does).  |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_BASE_MQH__
#define __SIGNAL_BASE_MQH__
#include "../Indicators/IndicatorDE.mqh"

//--- signal direction values
#define SIGNAL_BUF_BUY   1.0
#define SIGNAL_BUF_SELL (-1.0)

//--- signal direction enum
#ifndef ENUM_SIGNAL_DIR_DEFINED
#define ENUM_SIGNAL_DIR_DEFINED
 enum ENUM_SIGNAL_DIR
  {
   SIGNAL_NONE =  0,
   SIGNAL_BUY  =  1,
   SIGNAL_SELL = -1
  };
#endif

//+------------------------------------------------------------------+
// CBaseObj-derived like every other PureData object (CIndicatorDE, CBar, CSymbol...):
// lives inside CListObj collections, and each concrete subclass sets this.m_type to its
// own OBJECT_DE_TYPE_SIGNAL_* id in its constructor (CommonDefines object type list).
// CSignalsCollection stores and OWNS the instances in its CListObj m_list.
class CSignalBase : public CBaseObj
  {
   protected:
     // BORROWED - CIndicatorsCollection owns the CIndicatorDE. CSignalsCollection guarantees
     // this signal is deleted (DeleteSignal) BEFORE the indicator itself is, so m_indicator
     // is never dangling inside a live signal.
     CIndicatorDE    *m_indicator;
     double           m_current_val;   // live value for the still-forming bar (shift 0)

    //--- permanent history, oldest->newest - one entry per bar whose direction FLIPPED
     datetime         m_hist_time[];
     double           m_hist_val[];
     double           m_hist_low[];
     double           m_hist_high[];

   public:
                          CSignalBase(void);
         virtual          ~CSignalBase(void);

    //--- setup
     void             SetIndicator(CIndicatorDE *indicator);

    //--- pure signal math for one bar shift - subclasses implement, no storage side effects
     virtual double   ComputeAt(int bar) const = 0;

    //--- realtime: recompute the still-forming bar (shift 0) - safe every tick, never touches history
     void             RefreshCurrent(void);

    //--- permanent: append the bar that just closed (shift 1, read at the moment its new-bar
    //--- event fires) to history, but ONLY if its direction differs from the last recorded one.
    //--- Call exactly once per closed bar - never call every tick.
     void             CommitClosedBar(void);

    //--- catch up: backfill flip history for bars 1..total_bars-1 that closed before this signal
    //--- object existed - mirrors CBarSeriesDE::SyncData's "grow to what's required" pattern.
    //--- Call once, right after SetIndicator, while history is still empty.
     void             SyncHistory(int total_bars);

    //--- read results
     ENUM_SIGNAL_DIR  GetCurrentSignal(void) const;
     int              HistoryTotal(void)        const { return ::ArraySize(m_hist_time); }
     datetime         HistoryTime(int index)    const;
     ENUM_SIGNAL_DIR  HistoryDir(int index)     const;
     double           HistoryLow(int index)     const;
     double           HistoryHigh(int index)    const;
     CIndicatorDE    *GetIndicator(void) const;

   protected:
    //--- helpers
     double                  Buf(int buffer_num, int bar) const;
     static ENUM_SIGNAL_DIR  DirOf(double v);
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalBase::CSignalBase(void)
   : m_indicator(NULL), m_current_val(EMPTY_VALUE)
  {
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalBase::~CSignalBase(void)
  {
  }

//+------------------------------------------------------------------+
//| Bind indicator pointer                                           |
//+------------------------------------------------------------------+
void CSignalBase::SetIndicator(CIndicatorDE *indicator)
  {
   m_indicator = indicator;
  }

//+------------------------------------------------------------------+
//| Recompute the live, still-forming bar - never stored in history |
//+------------------------------------------------------------------+
void CSignalBase::RefreshCurrent(void)
  {
   m_current_val = ComputeAt(0);
  }

//+------------------------------------------------------------------+
//| Append the just-closed bar (shift 1) to history if it flipped   |
//+------------------------------------------------------------------+
void CSignalBase::CommitClosedBar(void)
  {
   if(m_indicator == NULL) return;
   datetime t[1];
   if(::CopyTime(m_indicator.Symbol(), m_indicator.Timeframe(), 1, 1, t) != 1) return;

   int total = ::ArraySize(m_hist_time);
   if(total > 0 && m_hist_time[total - 1] >= t[0]) return; // already committed

   double v          = ComputeAt(1);
   ENUM_SIGNAL_DIR dir  = DirOf(v);
   ENUM_SIGNAL_DIR last = (total > 0) ? DirOf(m_hist_val[total - 1]) : SIGNAL_NONE;
   if(dir == SIGNAL_NONE || dir == last) return; // no flip - nothing arrow-worthy happened

   double lo[1] = {0}, hi[1] = {0};
   ::CopyLow(m_indicator.Symbol(), m_indicator.Timeframe(), 1, 1, lo);
   ::CopyHigh(m_indicator.Symbol(), m_indicator.Timeframe(), 1, 1, hi);

   ::ArrayResize(m_hist_time, total + 1);
   ::ArrayResize(m_hist_val,  total + 1);
   ::ArrayResize(m_hist_low,  total + 1);
   ::ArrayResize(m_hist_high, total + 1);
   m_hist_time[total] = t[0];
   m_hist_val[total]  = v;
   m_hist_low[total]  = lo[0];
   m_hist_high[total] = hi[0];
  }

//+------------------------------------------------------------------+
//| Backfill flip history for bars 1..total_bars-1 - call once,     |
//| right after SetIndicator, while history is still empty.         |
//+------------------------------------------------------------------+
void CSignalBase::SyncHistory(int total_bars)
  {
   if(m_indicator == NULL || total_bars <= 1) return;
   for(int shift = total_bars - 1; shift >= 1; shift--)
     {
      double v   = ComputeAt(shift);
      ENUM_SIGNAL_DIR dir  = DirOf(v);
      int total = ::ArraySize(m_hist_time);
      ENUM_SIGNAL_DIR last = (total > 0) ? DirOf(m_hist_val[total - 1]) : SIGNAL_NONE;
      if(dir == SIGNAL_NONE || dir == last) continue; // no flip at this bar

      datetime t[1];
      if(::CopyTime(m_indicator.Symbol(), m_indicator.Timeframe(), shift, 1, t) != 1) continue;
      double lo[1] = {0}, hi[1] = {0};
      ::CopyLow(m_indicator.Symbol(), m_indicator.Timeframe(), shift, 1, lo);
      ::CopyHigh(m_indicator.Symbol(), m_indicator.Timeframe(), shift, 1, hi);

      ::ArrayResize(m_hist_time, total + 1);
      ::ArrayResize(m_hist_val,  total + 1);
      ::ArrayResize(m_hist_low,  total + 1);
      ::ArrayResize(m_hist_high, total + 1);
      m_hist_time[total] = t[0];
      m_hist_val[total]  = v;
      m_hist_low[total]  = lo[0];
      m_hist_high[total] = hi[0];
     }
  }

//+------------------------------------------------------------------+
//| Current (still-forming) bar's direction                         |
//+------------------------------------------------------------------+
ENUM_SIGNAL_DIR CSignalBase::GetCurrentSignal(void) const
  {
   return DirOf(m_current_val);
  }

//+------------------------------------------------------------------+
datetime CSignalBase::HistoryTime(int index) const
  {
   if(index < 0 || index >= ::ArraySize(m_hist_time)) return 0;
   return m_hist_time[index];
  }

//+------------------------------------------------------------------+
ENUM_SIGNAL_DIR CSignalBase::HistoryDir(int index) const
  {
   if(index < 0 || index >= ::ArraySize(m_hist_val)) return SIGNAL_NONE;
   return DirOf(m_hist_val[index]);
  }

//+------------------------------------------------------------------+
double CSignalBase::HistoryLow(int index) const
  {
   if(index < 0 || index >= ::ArraySize(m_hist_low)) return 0;
   return m_hist_low[index];
  }

//+------------------------------------------------------------------+
double CSignalBase::HistoryHigh(int index) const
  {
   if(index < 0 || index >= ::ArraySize(m_hist_high)) return 0;
   return m_hist_high[index];
  }

//+------------------------------------------------------------------+
CIndicatorDE *CSignalBase::GetIndicator(void) const
  {
   return m_indicator;
  }

//+------------------------------------------------------------------+
//| Read indicator buffer value; returns EMPTY_VALUE on failure     |
//+------------------------------------------------------------------+
double CSignalBase::Buf(int buffer_num, int bar) const
  {
   if(m_indicator == NULL) return EMPTY_VALUE;
   return m_indicator.GetDataBuffer(buffer_num, bar);
  }

//+------------------------------------------------------------------+
//| Convert a raw computed value to ENUM_SIGNAL_DIR                 |
//+------------------------------------------------------------------+
ENUM_SIGNAL_DIR CSignalBase::DirOf(double v)
  {
   if(v == EMPTY_VALUE) return SIGNAL_NONE;
   return (v > 0.0 ? SIGNAL_BUY : SIGNAL_SELL);
  }

#endif // __SIGNAL_BASE_MQH__
