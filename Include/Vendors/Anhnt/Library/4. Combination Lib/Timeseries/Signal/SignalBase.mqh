//+------------------------------------------------------------------+
//|                                                   SignalBase.mqh |
//|  Base class for indicator signal wrappers (Option B pattern).   |
//|  Maintains a time-indexed buffer: 1.0=BUY, -1.0=SELL, EMPTY=no.|
//|  Buffer index matches bar shift: [0]=current bar, [1]=prev bar. |
//+------------------------------------------------------------------+
#ifndef __SIGNAL_BASE_MQH__
#define __SIGNAL_BASE_MQH__
#include "../Indicators/IndicatorDE.mqh"

//--- signal direction values stored in buffer
#define SIGNAL_BUF_BUY   1.0
#define SIGNAL_BUF_SELL (-1.0)

//--- signal direction enum
#ifndef ENUM_SIGNAL_DIR
#define ENUM_SIGNAL_DIR
enum ENUM_SIGNAL_DIR
  {
   SIGNAL_NONE =  0,
   SIGNAL_BUY  =  1,
   SIGNAL_SELL = -1
  };
#endif

//+------------------------------------------------------------------+
class CSignalBase
  {
protected:
   CIndicatorDE    *m_ind;
   double           m_buffer[];   // [bar_shift]: BUY_VAL / SELL_VAL / EMPTY_VALUE

public:
                    CSignalBase(void);
   virtual          ~CSignalBase(void);

   //--- setup
   void             SetIndicator(CIndicatorDE *ind);
   bool             Init(int history_bars);

   //--- compute signal at one bar and store in buffer
   virtual void     Update(int bar = 1) = 0;

   //--- fill entire buffer from bar 1..total_bars
   void             UpdateAll(int total_bars);

   //--- read results
   double           GetBufferAt(int bar) const;
   ENUM_SIGNAL_DIR  GetSignalAt(int bar = 1) const;
   CIndicatorDE    *GetIndicator(void) const;

protected:
   //--- helpers
   double           Buf(int buffer_num, int bar) const;
   void             SetAt(int bar, ENUM_SIGNAL_DIR dir);
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalBase::CSignalBase(void)
   : m_ind(NULL)
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
void CSignalBase::SetIndicator(CIndicatorDE *ind)
  {
   m_ind = ind;
  }

//+------------------------------------------------------------------+
//| Allocate buffer for history_bars bars                            |
//+------------------------------------------------------------------+
bool CSignalBase::Init(int history_bars)
  {
   if(history_bars <= 0) return false;
   if(::ArrayResize(m_buffer, history_bars) != history_bars) return false;
   ::ArrayInitialize(m_buffer, EMPTY_VALUE);
   return true;
  }

//+------------------------------------------------------------------+
//| Fill buffer from bar 1 to total_bars                            |
//+------------------------------------------------------------------+
void CSignalBase::UpdateAll(int total_bars)
  {
   int size = ::ArraySize(m_buffer);
   int limit = (total_bars < size ? total_bars : size);
   for(int i = 1; i < limit; i++)
      Update(i);
  }

//+------------------------------------------------------------------+
//| Return raw buffer value at bar shift                             |
//+------------------------------------------------------------------+
double CSignalBase::GetBufferAt(int bar) const
  {
   if(bar < 0 || bar >= ::ArraySize(m_buffer)) return EMPTY_VALUE;
   return m_buffer[bar];
  }

//+------------------------------------------------------------------+
//| Convert buffer value to ENUM_SIGNAL_DIR                          |
//+------------------------------------------------------------------+
ENUM_SIGNAL_DIR CSignalBase::GetSignalAt(int bar) const
  {
   double v = GetBufferAt(bar);
   if(v == EMPTY_VALUE) return SIGNAL_NONE;
   return (v > 0.0 ? SIGNAL_BUY : SIGNAL_SELL);
  }

//+------------------------------------------------------------------+
CIndicatorDE *CSignalBase::GetIndicator(void) const
  {
   return m_ind;
  }

//+------------------------------------------------------------------+
//| Read indicator buffer value; returns EMPTY_VALUE on failure     |
//+------------------------------------------------------------------+
double CSignalBase::Buf(int buffer_num, int bar) const
  {
   if(m_ind == NULL) return EMPTY_VALUE;
   return m_ind.GetDataBuffer(buffer_num, bar);
  }

//+------------------------------------------------------------------+
//| Store signal direction at bar shift                              |
//+------------------------------------------------------------------+
void CSignalBase::SetAt(int bar, ENUM_SIGNAL_DIR dir)
  {
   if(bar < 0 || bar >= ::ArraySize(m_buffer)) return;
   m_buffer[bar] = (dir == SIGNAL_BUY  ? SIGNAL_BUF_BUY  :
                    dir == SIGNAL_SELL ? SIGNAL_BUF_SELL :
                    EMPTY_VALUE);
  }

#endif // __SIGNAL_BASE_MQH__
