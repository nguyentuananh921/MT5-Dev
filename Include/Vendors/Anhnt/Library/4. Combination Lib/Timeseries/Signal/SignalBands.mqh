//+------------------------------------------------------------------+
//|                                                  SignalBands.mqh |
//|  Signal for band-type indicators: price vs upper/lower band.    |
//|                                                                  |
//|  CSignalBollinger  (Bollinger Bands: buf 0=middle, 1=upper, 2=lower -
//|    confirmed against MT5's own Standard Library CiBands class,   |
//|    Include\Indicators\Trend.mqh:379-383)                          |
//|    Primary signal (this class's own ComputeAt/history) IS the    |
//|    MidBand cross: BUY when close crosses above MidBand, SELL when|
//|    it crosses below (Anhnt, 2026-07-19 - previously a contrarian |
//|    "close<Lower=Buy/close>Upper=Sell" rule, dropped because it   |
//|    disagreed in direction with the Upper/Lower line-cross events |
//|    below for the exact same bar). Upper/Lower crosses are tracked|
//|    separately as their own line-cross history (see m_lines[] /   |
//|    LineXxx() below) - same BUY-above/SELL-below convention, just |
//|    scoped to one line instead of Mid.                            |
//|                                                                  |
//|  CSignalEnvelopes  (Envelopes: buf 0=upper, 1=lower)            |
//|    Same logic as Bollinger's OLD contrarian rule (unchanged).    |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_BANDS_MQH__
#define __SIGNAL_BANDS_MQH__
#include "SignalBase.mqh"

//--- Which of CSignalBollinger's 3 independent line-cross histories a LineXxx() call refers to
//--- (Anhnt, 2026-07-17). Buffer mapping: Upper=1, Mid=0 (BASE_LINE), Lower=2 - same iBands
//--- order already confirmed for the primary close-vs-band-pair signal below.
#define BBAND_LINE_UPPER 0
#define BBAND_LINE_MID   1
#define BBAND_LINE_LOWER 2

//+------------------------------------------------------------------+
//--- Bollinger Bands: buffers 0=middle (BASE_LINE), 1=upper, 2=lower
//+------------------------------------------------------------------+
class CSignalBollinger : public CSignalBase
  {
private:
   //--- One independent sparse flip-history per line (Upper/Mid/Lower), mirroring CSignalBase's
   //--- own m_hist_time/m_hist_val pattern but scoped to a single extra buffer instead of the
   //--- primary close-vs-band-pair rule (Anhnt, 2026-07-17 - "1 Indicator = 1 Signal, 1 Signal
   //--- can have several Buffers", same as a custom indicator having 3 separate plots for 3
   //--- buffers). Keeps CSignalsCollection's 1:1 indicator->signal mapping intact.
   struct SLineHistory
     {
      datetime hist_time[];
      double   hist_val[];
      double   current_val;
     };
   SLineHistory     m_lines[3];
   int              m_line_buffer[3]; // {Upper->1, Mid->0, Lower->2}, set in constructor

   double           LineComputeAt(int buffer_index, int bar) const;
   void             RefreshLineCurrent(int line_idx);
   void             CommitLineClosedBar(int line_idx);
   void             SyncLineHistory(int line_idx, int total_bars);

public:
                    CSignalBollinger(void);
   virtual          ~CSignalBollinger(void);

   virtual double   ComputeAt(int bar) const;

   //--- Independent Upper/Mid/Lower line-cross history - line_idx is one of
   //--- BBAND_LINE_UPPER/BBAND_LINE_MID/BBAND_LINE_LOWER.
   ENUM_SIGNAL_DIR  LineCurrentSignal(int line_idx) const { return DirOf(m_lines[line_idx].current_val); }
   int              LineHistoryTotal(int line_idx)  const { return ::ArraySize(m_lines[line_idx].hist_time); }
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
   m_line_buffer[BBAND_LINE_MID]   = 0;
   m_line_buffer[BBAND_LINE_LOWER] = 2;
   for(int i = 0; i < 3; i++) m_lines[i].current_val = EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
CSignalBollinger::~CSignalBollinger(void)
  {
  }

//+------------------------------------------------------------------+
//| Primary signal = MidBand cross (Anhnt, 2026-07-19): same rule as |
//| LineComputeAt(BBAND_LINE_MID, bar) - kept as its own body (not a |
//| call into LineComputeAt) so this class's ComputeAt stays a pure  |
//| self-contained override of the abstract base method.            |
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
//| Pure math for one line at one bar - price vs a single buffer,   |
//| sticky position (not a momentary bar-vs-bar+1 event) - the same |
//| "only record on direction change" logic in Commit/SyncLineHistory|
//| below turns this into a real crossing event, same as the primary |
//| signal's own ComputeAt+CommitClosedBar pairing does.            |
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
   m_lines[line_idx].current_val = LineComputeAt(m_line_buffer[line_idx], 0);
  }

//+------------------------------------------------------------------+
//| Append the just-closed bar (shift 1) to ONE line's history if it |
//| flipped - exact mirror of CSignalBase::CommitClosedBar, scoped   |
//| to m_lines[line_idx] instead of the base class's own arrays.     |
//+------------------------------------------------------------------+
void CSignalBollinger::CommitLineClosedBar(int line_idx)
  {
   if(m_indicator == NULL) return;
   datetime t[1];
   if(::CopyTime(m_indicator.Symbol(), m_indicator.Timeframe(), 1, 1, t) != 1) return;

   int total = ::ArraySize(m_lines[line_idx].hist_time);
   if(total > 0 && m_lines[line_idx].hist_time[total - 1] >= t[0]) return; // already committed

   double v = LineComputeAt(m_line_buffer[line_idx], 1);
   ENUM_SIGNAL_DIR dir  = DirOf(v);
   ENUM_SIGNAL_DIR last = (total > 0) ? DirOf(m_lines[line_idx].hist_val[total - 1]) : SIGNAL_NONE;
   if(dir == SIGNAL_NONE || dir == last) return; // no flip - nothing worth recording

   ::ArrayResize(m_lines[line_idx].hist_time, total + 1);
   ::ArrayResize(m_lines[line_idx].hist_val,  total + 1);
   m_lines[line_idx].hist_time[total] = t[0];
   m_lines[line_idx].hist_val[total]  = v;
  }

//+------------------------------------------------------------------+
//| Backfill ONE line's flip history for bars 1..total_bars-1 - exact|
//| mirror of CSignalBase::SyncHistory, scoped to m_lines[line_idx]. |
//+------------------------------------------------------------------+
void CSignalBollinger::SyncLineHistory(int line_idx, int total_bars)
  {
   if(m_indicator == NULL || total_bars <= 1) return;
   for(int shift = total_bars - 1; shift >= 1; shift--)
     {
      double v   = LineComputeAt(m_line_buffer[line_idx], shift);
      ENUM_SIGNAL_DIR dir  = DirOf(v);
      int total = ::ArraySize(m_lines[line_idx].hist_time);
      ENUM_SIGNAL_DIR last = (total > 0) ? DirOf(m_lines[line_idx].hist_val[total - 1]) : SIGNAL_NONE;
      if(dir == SIGNAL_NONE || dir == last) continue; // no flip at this bar

      datetime t[1];
      if(::CopyTime(m_indicator.Symbol(), m_indicator.Timeframe(), shift, 1, t) != 1) continue;

      ::ArrayResize(m_lines[line_idx].hist_time, total + 1);
      ::ArrayResize(m_lines[line_idx].hist_val,  total + 1);
      m_lines[line_idx].hist_time[total] = t[0];
      m_lines[line_idx].hist_val[total]  = v;
     }
  }

//+------------------------------------------------------------------+
datetime CSignalBollinger::LineHistoryTime(int line_idx, int index) const
  {
   if(index < 0 || index >= ::ArraySize(m_lines[line_idx].hist_time)) return 0;
   return m_lines[line_idx].hist_time[index];
  }

//+------------------------------------------------------------------+
ENUM_SIGNAL_DIR CSignalBollinger::LineHistoryDir(int line_idx, int index) const
  {
   if(index < 0 || index >= ::ArraySize(m_lines[line_idx].hist_val)) return SIGNAL_NONE;
   return DirOf(m_lines[line_idx].hist_val[index]);
  }

//+------------------------------------------------------------------+
void CSignalBollinger::RefreshCurrentExtra(void)
  {
   for(int i = 0; i < 3; i++) RefreshLineCurrent(i);
  }

//+------------------------------------------------------------------+
void CSignalBollinger::CommitClosedBarExtra(void)
  {
   for(int i = 0; i < 3; i++) CommitLineClosedBar(i);
  }

//+------------------------------------------------------------------+
void CSignalBollinger::SyncHistoryExtra(int total_bars)
  {
   for(int i = 0; i < 3; i++) SyncLineHistory(i, total_bars);
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
