//+------------------------------------------------------------------+
//| V5: the entity CSignal (Clean Architecture: Model / Entities)    |
//+------------------------------------------------------------------+
//--- Split from UseCases\Judges\Signals\Signal.mqh (CSignal : CJudge, rule + rows + DB + events): only the data of the signals of one indicator,
//--- as V2 CSignalBase (m_hist_time / m_hist_dir). The rule: CSignalJudge (UseCases), the judging and the events: CSignalsCollection
//--- V5 Clean Architecture: no pointer to CIndicatorDE (an outer class: its handle, MT5); its key is data, the key columns of the table SignalsCollection
#ifndef __SIGNAL_MQH__
#define __SIGNAL_MQH__
 #include <Arrays\ArrayLong.mqh>
 #include <Arrays\ArrayInt.mqh>
 #include "..\Bases\BaseObj.mqh"
 #include "..\Defines\EventDefines.mqh"
#ifndef CSIGNAL_MQH_DECLARATION
#define CSIGNAL_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The signals of the indicator of a template on a pair             |
 //+------------------------------------------------------------------+
 class CSignal : public CBaseObj
  {
   private:
    //CIndicatorDE     *m_indicator;                    // Borrowed (V2 CSignalBase): CIndicatorsCollection owns it
    //--- V5: the key (the key columns of the table SignalsCollection: name, tf_enum, type_enum, params)
    string            m_symbol;
    ENUM_TIMEFRAMES   m_timeframe;
    ENUM_INDICATOR    m_ind_type;
    string            m_params_text;
    CArrayLong        m_hist_time;                   // V2 CSignalBase: the rows of the table SignalsCollection, the oldest first, one per bar
    CArrayInt         m_hist_dir;
    datetime          m_judged_to;                    // RAM only: the newest closed bar the rows are judged to (0: not judged yet)
   public:
   //--- V2 CSignalBase::SetIndicator, GetIndicator: bound once (CSignalsCollection::GetOrCreateSignal)
    //void              SetIndicator(CIndicatorDE *indicator) { this.m_indicator=indicator; }
    //CIndicatorDE     *GetIndicator(void)            const { return this.m_indicator;       }
   //--- V5 (from SetIndicator): the key, set once (CSignalsCollection::GetOrCreateSignal)
    void              SetKey(const string symbol,const ENUM_TIMEFRAMES timeframe,const ENUM_INDICATOR type,const string params_text)
                         { this.m_symbol=symbol; this.m_timeframe=timeframe; this.m_ind_type=type; this.m_params_text=params_text; }
   //--- The template and the pair
    //ENUM_INDICATOR    TypeIndicator(void)           const { return (this.m_indicator!=NULL ? this.m_indicator.TypeIndicator() : (ENUM_INDICATOR)WRONG_VALUE); }
    //string            ParamsText(void)              const { return (this.m_indicator!=NULL ? this.m_indicator.ParamsText() : "");            }
    //string            Symbol(void)                  const { return (this.m_indicator!=NULL ? this.m_indicator.Symbol() : "");                }
    //ENUM_TIMEFRAMES   Timeframe(void)               const { return (this.m_indicator!=NULL ? this.m_indicator.Timeframe() : PERIOD_CURRENT); }
    ENUM_INDICATOR    TypeIndicator(void)           const { return this.m_ind_type;        }
    string            ParamsText(void)              const { return this.m_params_text;     }
    string            Symbol(void)                  const { return this.m_symbol;          }
    ENUM_TIMEFRAMES   Timeframe(void)               const { return this.m_timeframe;       }
   //--- V2 CSignalBase: the rows, the oldest first
    int               HistoryTotal(void)            const { return this.m_hist_time.Total();                  }
    datetime          HistoryTime(const int index)  const { return (datetime)this.m_hist_time.At(index);      }
    ENUM_SIGNAL_DIRECTION HistoryDir(const int index) const { return (ENUM_SIGNAL_DIRECTION)this.m_hist_dir.At(index); }
   //--- A row goes in its place by its time, one per bar (false: the bar has one already)
    bool              AddRow(const datetime time,const ENUM_SIGNAL_DIRECTION direction);
   //--- V5: a row Python found (CPythonBridge) is added and told (Event Rule): SERIES_EVENTS_SIGNAL, lparam = EventPack(bar time, type, side, is_new),
   //--- dparam = the timeframe, sparam = the symbol;the params. False: the bar had it already (judged on RAM before: no second event)
    bool              StoreRow(const datetime time,const ENUM_SIGNAL_DIRECTION direction,const bool is_new);
   //--- The rows before the time go. Returns how many went
    int               DeleteRows(const datetime before);
    datetime          JudgedTo(void)                const { return this.m_judged_to;       }
    void              SetJudgedTo(const datetime time)    { this.m_judged_to=time;         }
                      //CSignal(void) : m_indicator(NULL),m_judged_to(0) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL; }
                      CSignal(void) : m_symbol(""),m_timeframe(PERIOD_CURRENT),m_ind_type((ENUM_INDICATOR)WRONG_VALUE),m_params_text(""),m_judged_to(0) { this.m_object_type=OBJECT_DE_TYPE_SIGNAL; }
  };
#endif // CSIGNAL_MQH_DECLARATION
#ifndef CSIGNAL_MQH_IMPLEMENTATION
#define CSIGNAL_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| A row goes in its place by its time                               |
 //+------------------------------------------------------------------+
 bool CSignal::AddRow(const datetime time,const ENUM_SIGNAL_DIRECTION direction)
  {
   int pos=this.m_hist_time.Total();
   while(pos>0 && this.m_hist_time.At(pos-1)>(long)time)
      pos--;
   if(pos>0 && this.m_hist_time.At(pos-1)==(long)time)
      return false;   // the bar has a row already
   return (this.m_hist_time.Insert((long)time,pos) && this.m_hist_dir.Insert((int)direction,pos));
  }
 //+------------------------------------------------------------------+
 //| A row of Python is added and told                                 |
 //+------------------------------------------------------------------+
 bool CSignal::StoreRow(const datetime time,const ENUM_SIGNAL_DIRECTION direction,const bool is_new)
  {
   if(!this.AddRow(time,direction))
      return false;
   //--- RAM changed: told, with all the Automation Trading needs (no asking back)
   const string text=this.m_symbol+";"+this.m_params_text;
   this.EventSend((ushort)SERIES_EVENTS_SIGNAL,this.EventPack(time,(long)this.m_ind_type,direction,is_new),(double)this.m_timeframe,text);
   return true;
  }
 //+------------------------------------------------------------------+
 //| The rows before a time go                                         |
 //+------------------------------------------------------------------+
 int CSignal::DeleteRows(const datetime before)
  {
   int deleted=0;
   for(int i=this.m_hist_time.Total()-1;i>=0;i--)
     {
      if(this.m_hist_time.At(i)>=(long)before)
         continue;
      this.m_hist_time.Delete(i);
      this.m_hist_dir.Delete(i);
      deleted++;
     }
   return deleted;
  }
#endif // CSIGNAL_MQH_IMPLEMENTATION
#endif // __SIGNAL_MQH__