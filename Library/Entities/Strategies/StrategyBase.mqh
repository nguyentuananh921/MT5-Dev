//+------------------------------------------------------------------+
//|                                                 StrategyBase.mqh |
//|                                     Copyright 2026, Anhnt        |
//| 1 instance = a strategy on a pair: the entries and exits Python  |
//| found (the rows of the table StrategyCollection), as CSignal for |
//| a template. New in V5                                             |
//+------------------------------------------------------------------+
#ifndef __STRATEGYBASE_MQH__
#define __STRATEGYBASE_MQH__
 #include <Arrays\ArrayLong.mqh>
 #include <Arrays\ArrayInt.mqh>
 #include "..\Bases\BaseObj.mqh"
 #include "..\Defines\EventDefines.mqh"
 #define STRATEGY_ROLE_ENTRY   "entry"   // StrategyCollection.role: the side is the one the strategy opens
 #define STRATEGY_ROLE_EXIT    "exit"    // the side is the one it closes
#ifndef CSTRATEGYBASE_MQH_DECLARATION
#define CSTRATEGYBASE_MQH_DECLARATION
 class CStrategyBase : public CBaseObj
  {
   private:
    //--- The key (the key columns of the table StrategyCollection: name, tf_enum, strategy_id)
    long              m_strategy_id;
    string            m_symbol;
    ENUM_TIMEFRAMES   m_timeframe;
    CArrayLong        m_hist_time;                   // the rows, the oldest first: a bar has at most one entry and one exit
    CArrayInt         m_hist_exit;                   // 1: an exit, 0: an entry
    CArrayInt         m_hist_dir;
    datetime          m_judged_to;                   // RAM only: the newest closed bar of its tf the rule looked at (the isNewBar of the source EA)
   public:
    void              SetKey(const long strategy_id,const string symbol,const ENUM_TIMEFRAMES timeframe)
                         { this.m_strategy_id=strategy_id; this.m_symbol=symbol; this.m_timeframe=timeframe; }
    long              StrategyId(void)              const { return this.m_strategy_id; }
    string            Symbol(void)                  const { return this.m_symbol;      }
    ENUM_TIMEFRAMES   Timeframe(void)               const { return this.m_timeframe;   }
    datetime          JudgedTo(void)                const { return this.m_judged_to;   }
    void              SetJudgedTo(const datetime time)    { this.m_judged_to=time;     }
   //--- The rows, the oldest first
    int               HistoryTotal(void)            const { return this.m_hist_time.Total();                  }
    datetime          HistoryTime(const int index)  const { return (datetime)this.m_hist_time.At(index);      }
    bool              HistoryExit(const int index)  const { return this.m_hist_exit.At(index)!=0;            }
    ENUM_SIGNAL_DIRECTION HistoryDir(const int index) const { return (ENUM_SIGNAL_DIRECTION)this.m_hist_dir.At(index); }
   //--- A row goes in its place by its time (false: the bar has this role already)
    bool              AddRow(const datetime time,const string role,const ENUM_SIGNAL_DIRECTION direction);
   //--- A row Python found (CPythonBridge) is added and told (Working with Event): STRATEGY_EVENT_ENTRY / STRATEGY_EVENT_EXIT,
   //--- lparam = EventPack(bar time, strategy_id, side, is_new), dparam = the timeframe, sparam = the symbol. False: the bar had it already (no event)
    bool              StoreRow(const datetime time,const string role,const ENUM_SIGNAL_DIRECTION direction,const bool is_new);
   //--- The rows before the time go. Returns how many went
    int               DeleteRows(const datetime before);
   //--- The positions of a side open after the newest row (the entries after its last exit): what the rule needs
    int               OpenTotal(const ENUM_SIGNAL_DIRECTION side) const;
   //--- The trades on RAM: each entry with the exit that closes its side (an entry with none yet is open: not in). Returns how many
    int               Trades(datetime &entries[],datetime &exits[],bool &is_buy[]) const;
                      CStrategyBase(void) : m_strategy_id(WRONG_VALUE),m_symbol(""),m_timeframe(PERIOD_CURRENT),m_judged_to(0) { this.m_object_type=OBJECT_DE_TYPE_STRATEGY; }
  };
#endif // CSTRATEGYBASE_MQH_DECLARATION
#ifndef CSTRATEGYBASE_MQH_IMPLEMENTATION
#define CSTRATEGYBASE_MQH_IMPLEMENTATION
 bool CStrategyBase::AddRow(const datetime time,const string role,const ENUM_SIGNAL_DIRECTION direction)
  {
   const int is_exit=(int)(role==STRATEGY_ROLE_EXIT);
   int pos=this.m_hist_time.Total();
   while(pos>0 && (this.m_hist_time.At(pos-1)>(long)time || (this.m_hist_time.At(pos-1)==(long)time && this.m_hist_exit.At(pos-1)>is_exit)))
      pos--;
   if(pos>0 && this.m_hist_time.At(pos-1)==(long)time && this.m_hist_exit.At(pos-1)==is_exit)
      return false;   // the bar has this role already
   return (this.m_hist_time.Insert((long)time,pos) && this.m_hist_exit.Insert(is_exit,pos) && this.m_hist_dir.Insert((int)direction,pos));
  }
 bool CStrategyBase::StoreRow(const datetime time,const string role,const ENUM_SIGNAL_DIRECTION direction,const bool is_new)
  {
   if(!this.AddRow(time,role,direction))
      return false;
   //--- RAM changed: told, with all the Trading needs (no asking back)
   ushort id=(ushort)STRATEGY_EVENT_ENTRY;
   if(role==STRATEGY_ROLE_EXIT)
      id=(ushort)STRATEGY_EVENT_EXIT;
   this.EventSend(id,this.EventPack(time,this.m_strategy_id,direction,is_new),(double)this.m_timeframe,this.m_symbol);
   return true;
  }
 int CStrategyBase::OpenTotal(const ENUM_SIGNAL_DIRECTION side) const
  {
   int open=0;
   for(int i=this.m_hist_time.Total()-1;i>=0;i--)
     {
      if(this.HistoryDir(i)!=side)
         continue;
      if(this.HistoryExit(i))
         break;   // the exit closed every one before it
      open++;
     }
   return open;
  }
 int CStrategyBase::Trades(datetime &entries[],datetime &exits[],bool &is_buy[]) const
  {
   ::ArrayResize(entries,0);
   ::ArrayResize(exits,0);
   ::ArrayResize(is_buy,0);
   datetime open_time[];   // the entries not closed yet, oldest first (the source EA may hold several of a side)
   bool open_buy[];
   for(int i=0;i<this.m_hist_time.Total();i++)
     {
      const bool buy=(this.HistoryDir(i)==SIGNAL_DIRECTION_BUY);
      if(!this.HistoryExit(i))
        {
         const int n=::ArraySize(open_time);
         ::ArrayResize(open_time,n+1);
         ::ArrayResize(open_buy,n+1);
         open_time[n]=this.HistoryTime(i);
         open_buy[n]=buy;
         continue;
        }
      //--- An exit closes every open entry of its side
      for(int k=::ArraySize(open_time)-1;k>=0;k--)
        {
         if(open_buy[k]!=buy)
            continue;
         const int n=::ArraySize(entries);
         ::ArrayResize(entries,n+1);
         ::ArrayResize(exits,n+1);
         ::ArrayResize(is_buy,n+1);
         entries[n]=open_time[k];
         exits[n]=this.HistoryTime(i);
         is_buy[n]=buy;
         ::ArrayRemove(open_time,k,1);
         ::ArrayRemove(open_buy,k,1);
        }
     }
   return ::ArraySize(entries);
  }
 int CStrategyBase::DeleteRows(const datetime before)
  {
   int deleted=0;
   for(int i=this.m_hist_time.Total()-1;i>=0;i--)
     {
      if(this.m_hist_time.At(i)>=(long)before)
         continue;
      this.m_hist_time.Delete(i);
      this.m_hist_exit.Delete(i);
      this.m_hist_dir.Delete(i);
      deleted++;
     }
   return deleted;
  }
#endif // CSTRATEGYBASE_MQH_IMPLEMENTATION
#endif // __STRATEGYBASE_MQH__
