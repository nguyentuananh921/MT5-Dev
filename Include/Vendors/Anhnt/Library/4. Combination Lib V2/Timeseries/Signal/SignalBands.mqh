//+------------------------------------------------------------------+
//|                                                  SignalBands.mqh |
//|  Signal for band-type indicators: price vs bands.                |
//|  CSignalBollinger (buf 0=middle, 1=upper, 2=lower): primary      |
//|    signal = close crossing the MidBand (BUY above, SELL below);  |
//|    Upper and Lower lines also keep their own cross history.     |
//|  CSignalEnvelopes (buf 0=upper, 1=lower): close below lower =    |
//|    BUY, close above upper = SELL.                                |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_BANDS_MQH__
#define __SIGNAL_BANDS_MQH__
#include "SignalBase.mqh"

//--- Line index of CSignalBollinger's per-line cross histories (the Mid cross is the base history); buffers: Upper=1, Lower=2
#define BBAND_LINE_UPPER 0
#define BBAND_LINE_LOWER 1
//+------------------------------------------------------------------+
//--- Bollinger Bands: buffers 0=middle (BASE_LINE), 1=upper, 2=lower
//+------------------------------------------------------------------+
class CSignalBollinger : public CSignalBase
  {
private:
   //--- One sparse flip history per line (Upper/Lower), same rule as CSignalBase, scoped to one buffer
   CArrayLong       m_line_time[2];     // datetime of each flip, per line
   CArrayInt        m_line_dir[2];      // ENUM_SIGNAL_DIR of each flip, per line
   double           m_line_current[2];  // live value of the forming bar, per line
   int              m_line_buffer[2]; // {Upper->1, Lower->2}, set in constructor

   double           LineComputeAt(int buffer_index, int bar) const;
   void             RefreshLineCurrent(int line_idx);
   void             CommitLineClosedBar(int line_idx);
   void             SyncLineHistory(int line_idx, int total_bars);

public:
                    CSignalBollinger(void);
   virtual          ~CSignalBollinger(void);

   virtual double   ComputeAt(int bar) const;

   //--- Independent Upper/Lower line-cross history - line_idx is BBAND_LINE_UPPER or BBAND_LINE_LOWER
   ENUM_SIGNAL_DIR  LineCurrentSignal(int line_idx) const { return DirOf(m_line_current[line_idx]); }
   int              LineHistoryTotal(int line_idx)  const { return m_line_time[line_idx].Total(); }
   datetime         LineHistoryTime(int line_idx, int index) const;
   ENUM_SIGNAL_DIR  LineHistoryDir(int line_idx, int index)  const;

   virtual void     RefreshCurrentExtra(void);
   virtual void     CommitClosedBarExtra(void);
   virtual void     SyncHistoryExtra(int total_bars);
  };

//+------------------------------------------------------------------+
CSignalBollinger::CSignalBollinger(void)
  {
   this.m_type=OBJECT_DE_TYPE_SIGNAL_BOLLINGER;
   m_line_buffer[BBAND_LINE_UPPER] = 1;
   m_line_buffer[BBAND_LINE_LOWER] = 2;
   for(int i = 0; i < 2; i++) m_line_current[i] = EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
CSignalBollinger::~CSignalBollinger(void)
  {
  }

//+------------------------------------------------------------------+
//| Primary signal = MidBand cross (the base history); the per-line |
//| histories cover Upper and Lower only.                            |
//+------------------------------------------------------------------+
double CSignalBollinger::ComputeAt(int bar) const
  {
   if(m_indicator == NULL) return EMPTY_VALUE;
   double mid = Buf(0, bar);
   if(mid == EMPTY_VALUE) return EMPTY_VALUE;
   double close[1];
   if(::CopyClose(m_indicator.Symbol(), m_indicator.Timeframe(), bar, 1, close) != 1) return EMPTY_VALUE;
   if(close[0] > mid) return SIGNAL_BUF_BUY;
   if(close[0] < mid) return SIGNAL_BUF_SELL;
   return EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
//| Pure math for one line at one bar: close vs a single buffer     |
//| (sticky position, not an event); Commit/SyncLineHistory record   |
//| only the direction changes.                                      |
//+------------------------------------------------------------------+
double CSignalBollinger::LineComputeAt(int buffer_index, int bar) const
  {
   if(m_indicator == NULL) return EMPTY_VALUE;
   double line = Buf(buffer_index, bar);
   if(line == EMPTY_VALUE) return EMPTY_VALUE;
   double close[1];
   if(::CopyClose(m_indicator.Symbol(), m_indicator.Timeframe(), bar, 1, close) != 1) return EMPTY_VALUE;
   if(close[0] > line) return SIGNAL_BUF_BUY;
   if(close[0] < line) return SIGNAL_BUF_SELL;
   return EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
void CSignalBollinger::RefreshLineCurrent(int line_idx)
  {
   ENUM_SIGNAL_DIR before = DirOf(m_line_current[line_idx]);
   m_line_current[line_idx] = LineComputeAt(m_line_buffer[line_idx], 0);
   ENUM_SIGNAL_DIR now = DirOf(m_line_current[line_idx]);
   if(m_first_start || now == SIGNAL_NONE || now == before) return;
   SendLiveFlip(now, (line_idx == BBAND_LINE_UPPER) ? "Upper" : "Lower");
  }

//+------------------------------------------------------------------+
//| Append the just-closed bar (shift 1) to ONE line's history if it|
//| flipped - same rule as CSignalBase::CommitClosedBar.             |
//+------------------------------------------------------------------+
void CSignalBollinger::CommitLineClosedBar(int line_idx)
  {
   if(m_indicator == NULL) return;
   datetime t[1];
   if(::CopyTime(m_indicator.Symbol(), m_indicator.Timeframe(), 1, 1, t) != 1) return;

   int total = m_line_time[line_idx].Total();
   if(total > 0 && m_line_time[line_idx].At(total - 1) >= t[0]) return; // already committed

   ENUM_SIGNAL_DIR dir  = DirOf(LineComputeAt(m_line_buffer[line_idx], 1));
   ENUM_SIGNAL_DIR prev = DirOf(LineComputeAt(m_line_buffer[line_idx], 2));
   if(dir == SIGNAL_NONE || dir == prev) return;

   m_line_time[line_idx].Add((long)t[0]);
   m_line_dir[line_idx].Add((int)dir);
  }

//+------------------------------------------------------------------+
//| Backfill ONE line's flip history for bars 1..total_bars-1 - same|
//| rule as CSignalBase::SyncHistory.                                |
//+------------------------------------------------------------------+
void CSignalBollinger::SyncLineHistory(int line_idx, int total_bars)
  {
   if(m_indicator == NULL || total_bars <= 1) return;
   ENUM_SIGNAL_DIR prev = DirOf(LineComputeAt(m_line_buffer[line_idx], total_bars));
   for(int shift = total_bars - 1; shift >= 1; shift--)
     {
      ENUM_SIGNAL_DIR dir    = DirOf(LineComputeAt(m_line_buffer[line_idx], shift));
      ENUM_SIGNAL_DIR before = prev;
      prev = dir;
      if(dir == SIGNAL_NONE || dir == before) continue;

      datetime t[1];
      if(::CopyTime(m_indicator.Symbol(), m_indicator.Timeframe(), shift, 1, t) != 1) continue;

      m_line_time[line_idx].Add((long)t[0]);
      m_line_dir[line_idx].Add((int)dir);
     }
  }

//+------------------------------------------------------------------+
datetime CSignalBollinger::LineHistoryTime(int line_idx, int index) const
  {
   if(index < 0 || index >= m_line_time[line_idx].Total()) return 0;
   return (datetime)m_line_time[line_idx].At(index);
  }

//+------------------------------------------------------------------+
ENUM_SIGNAL_DIR CSignalBollinger::LineHistoryDir(int line_idx, int index) const
  {
   if(index < 0 || index >= m_line_dir[line_idx].Total()) return SIGNAL_NONE;
   return (ENUM_SIGNAL_DIR)m_line_dir[line_idx].At(index);
  }

//+------------------------------------------------------------------+
void CSignalBollinger::RefreshCurrentExtra(void)
  {
   for(int i = 0; i < 2; i++) RefreshLineCurrent(i);
  }

//+------------------------------------------------------------------+
void CSignalBollinger::CommitClosedBarExtra(void)
  {
   for(int i = 0; i < 2; i++) CommitLineClosedBar(i);
  }

//+------------------------------------------------------------------+
void CSignalBollinger::SyncHistoryExtra(int total_bars)
  {
   for(int i = 0; i < 2; i++) SyncLineHistory(i, total_bars);
  }

//+------------------------------------------------------------------+
//--- Envelopes: buffers 0=upper, 1=lower
//+------------------------------------------------------------------+
class CSignalEnvelopes : public CSignalBase
  {
public:
                    CSignalEnvelopes(void);
   virtual          ~CSignalEnvelopes(void);

   virtual double   ComputeAt(int bar) const;
  };

//+------------------------------------------------------------------+
CSignalEnvelopes::CSignalEnvelopes(void)
  {
   this.m_type=OBJECT_DE_TYPE_SIGNAL_ENVELOPES;
  }

//+------------------------------------------------------------------+
CSignalEnvelopes::~CSignalEnvelopes(void)
  {
  }

//+------------------------------------------------------------------+
double CSignalEnvelopes::ComputeAt(int bar) const
  {
   if(m_indicator == NULL) return EMPTY_VALUE;
   double upper = Buf(0, bar);
   double lower = Buf(1, bar);
   if(upper == EMPTY_VALUE || lower == EMPTY_VALUE) return EMPTY_VALUE;
   double close[1];
   if(::CopyClose(m_indicator.Symbol(), m_indicator.Timeframe(), bar, 1, close) != 1) return EMPTY_VALUE;
   if(close[0] < lower) return SIGNAL_BUF_BUY;
   if(close[0] > upper) return SIGNAL_BUF_SELL;
   return EMPTY_VALUE;
  }

#endif // __SIGNAL_BANDS_MQH__
