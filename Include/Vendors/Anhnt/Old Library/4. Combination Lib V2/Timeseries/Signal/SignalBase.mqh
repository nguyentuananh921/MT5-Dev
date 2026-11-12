//+------------------------------------------------------------------+
//|                                                   SignalBase.mqh |
//|  Base of the indicator signal wrappers.                          |
//|  Live bar (shift 0): refreshed every tick, never stored.         |
//|  History: one (time, direction) entry per direction flip,        |
//|  oldest->newest.                                                 |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_BASE_MQH__
#define __SIGNAL_BASE_MQH__
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayInt.mqh>
#include "../../Entities/Defines/TimeseriesDefines.mqh"
#include "../Indicators/IndicatorDE.mqh"
//--- signal direction values
#define SIGNAL_BUF_BUY   1.0
#define SIGNAL_BUF_SELL (-1.0)

//+------------------------------------------------------------------+
// Owned by CSignalsCollection; each subclass sets m_type (OBJECT_DE_TYPE_SIGNAL_*).
class CSignalBase : public CBaseObj
  {
   protected:
     CIndicatorDE    *m_indicator;     // borrowed - the signal is deleted before its indicator
     double           m_current_val;   // live value of the forming bar (shift 0)
     CArrayLong       m_hist_time;     // datetime of each flip
     CArrayInt        m_hist_dir;      // ENUM_SIGNAL_DIR of each flip (never SIGNAL_NONE)
     datetime         m_bar_time;      // open time of the forming bar seen by CommitIfNewBar
   public:
                          CSignalBase(void);
         virtual          ~CSignalBase(void);

    //--- setup
     void             SetIndicator(CIndicatorDE *indicator);

    //--- signal value at one bar shift, no side effects - subclasses implement
     virtual double   ComputeAt(int bar) const = 0;

    //--- recompute the forming bar - safe every tick, never touches history; sends SIGNAL_EVENT_LIVE_FLIP when it flips to BUY/SELL
     void             RefreshCurrent(void);
    //--- append the just-closed bar (shift 1) if its direction flipped - once per closed bar
     void             CommitClosedBar(void);
    //--- CommitClosedBar + CommitClosedBarExtra when the forming bar changed since the last call; cheap per tick
     void             CommitIfNewBar(void);
    //--- backfill flips of bars 1..total_bars-1 - once, right after SetIndicator
     void             SyncHistory(int total_bars);

    //--- per-subclass hooks; RefreshCurrentExtra runs inside RefreshCurrent
     virtual void     RefreshCurrentExtra(void) { }
     virtual void     CommitClosedBarExtra(void) { }
     virtual void     SyncHistoryExtra(int total_bars) { }

    //--- read results
     ENUM_SIGNAL_DIR  GetCurrentSignal(void) const;
     int              HistoryTotal(void)        const { return m_hist_time.Total(); }
     datetime         HistoryTime(int index)    const;
     ENUM_SIGNAL_DIR  HistoryDir(int index)     const;
     CIndicatorDE    *GetIndicator(void) const;

   protected:
    //--- helpers
     double                  Buf(int buffer_num, int bar) const;
     void                    SendLiveFlip(const ENUM_SIGNAL_DIR dir, const string line);
     static ENUM_SIGNAL_DIR  DirOf(double v);
  };

//+------------------------------------------------------------------+
CSignalBase::CSignalBase(void)
   : m_indicator(NULL), m_current_val(EMPTY_VALUE), m_bar_time(0)
  {
  }

//+------------------------------------------------------------------+
CSignalBase::~CSignalBase(void)
  {
  }

//+------------------------------------------------------------------+
void CSignalBase::SetIndicator(CIndicatorDE *indicator)
  {
   m_indicator = indicator;
  }

//+------------------------------------------------------------------+
void CSignalBase::RefreshCurrent(void)
  {
   ENUM_SIGNAL_DIR before = DirOf(m_current_val);
   m_current_val = ComputeAt(0);
   ENUM_SIGNAL_DIR now = DirOf(m_current_val);
   RefreshCurrentExtra();
   if(m_first_start)
     {
      m_first_start = false;
      return;
     }
   if(now != SIGNAL_NONE && now != before)
      SendLiveFlip(now, "");
  }

//+------------------------------------------------------------------+
//| sparam = line name ("" = the primary signal)                     |
//+------------------------------------------------------------------+
void CSignalBase::SendLiveFlip(const ENUM_SIGNAL_DIR dir, const string line)
  {
   if(m_indicator == NULL) return;
   ::EventChartCustom(::ChartID(), (ushort)SIGNAL_EVENT_LIVE_FLIP, (long)m_indicator.Handle(), (double)dir, line);
  }

//+------------------------------------------------------------------+
//| Flip = direction differs from the previous bar (threshold        |
//| signals pass through NONE between zone visits).                  |
//+------------------------------------------------------------------+
void CSignalBase::CommitClosedBar(void)
  {
   if(m_indicator == NULL) return;
   datetime t[1];
   if(::CopyTime(m_indicator.Symbol(), m_indicator.Timeframe(), 1, 1, t) != 1) return;

   int total = m_hist_time.Total();
   if(total > 0 && m_hist_time.At(total - 1) >= t[0]) return; // already committed

   ENUM_SIGNAL_DIR dir  = DirOf(ComputeAt(1));
   ENUM_SIGNAL_DIR prev = DirOf(ComputeAt(2));
   if(dir == SIGNAL_NONE || dir == prev) return;

   m_hist_time.Add((long)t[0]);
   m_hist_dir.Add((int)dir);
  }

//+------------------------------------------------------------------+
//| The first call only records the forming bar (SyncHistory already |
//| covered the closed ones).                                        |
//+------------------------------------------------------------------+
void CSignalBase::CommitIfNewBar(void)
  {
   if(m_indicator == NULL) return;
   datetime t = ::iTime(m_indicator.Symbol(), m_indicator.Timeframe(), 0);
   if(t == 0 || t == m_bar_time) return;
   bool first = (m_bar_time == 0);
   m_bar_time = t;
   if(first) return;
   CommitClosedBar();
   CommitClosedBarExtra();
  }

//+------------------------------------------------------------------+
//| Same flip rule as CommitClosedBar; prev carries over from the    |
//| older bar so ComputeAt runs once per bar.                        |
//+------------------------------------------------------------------+
void CSignalBase::SyncHistory(int total_bars)
  {
   if(m_indicator == NULL || total_bars <= 1) return;
   ENUM_SIGNAL_DIR prev = DirOf(ComputeAt(total_bars));
   for(int shift = total_bars - 1; shift >= 1; shift--)
     {
      ENUM_SIGNAL_DIR dir    = DirOf(ComputeAt(shift));
      ENUM_SIGNAL_DIR before = prev;
      prev = dir;
      if(dir == SIGNAL_NONE || dir == before) continue;

      datetime t[1];
      if(::CopyTime(m_indicator.Symbol(), m_indicator.Timeframe(), shift, 1, t) != 1) continue;

      m_hist_time.Add((long)t[0]);
      m_hist_dir.Add((int)dir);
     }
  }

//+------------------------------------------------------------------+
ENUM_SIGNAL_DIR CSignalBase::GetCurrentSignal(void) const
  {
   return DirOf(m_current_val);
  }
ENUM_SIGNAL_DIR CSignalBase::DirOf(double v)
 {
   if(v == EMPTY_VALUE) return SIGNAL_NONE;
   return (v > 0.0 ? SIGNAL_BUY : SIGNAL_SELL);
 }
//+------------------------------------------------------------------+
datetime CSignalBase::HistoryTime(int index) const
  {
   if(index < 0 || index >= m_hist_time.Total()) return 0;
   return (datetime)m_hist_time.At(index);
  }

//+------------------------------------------------------------------+
ENUM_SIGNAL_DIR CSignalBase::HistoryDir(int index) const
  {
   if(index < 0 || index >= m_hist_dir.Total()) return SIGNAL_NONE;
   return (ENUM_SIGNAL_DIR)m_hist_dir.At(index);
  }

//+------------------------------------------------------------------+
CIndicatorDE *CSignalBase::GetIndicator(void) const
  {
   return m_indicator;
  }

//+------------------------------------------------------------------+
//| Indicator buffer value; EMPTY_VALUE on failure                   |
//+------------------------------------------------------------------+
double CSignalBase::Buf(int buffer_num, int bar) const
  {
   if(m_indicator == NULL) return EMPTY_VALUE;
   return m_indicator.GetDataBuffer(buffer_num, bar);
  }

//+------------------------------------------------------------------+

#endif // __SIGNAL_BASE_MQH__
