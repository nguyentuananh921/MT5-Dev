#property copyright "Copyright 2026, Anhnt"
#property script_show_inputs
//--- Parity of CStrategyEngine (EA) with Python Strategy\engine.py on the chart pair: the engine replays the closed bars (shift InpBars .. 1)
//--- on MT5 handles and the AO rows of SignalsCollection (as the EA reads them), and its moves are compared with the rows Python saved in StrategyCollection
 #include <Combination Lib V5\Entities\Settings\Strategy\Setting_Profitunity.mqh>
 #include <Combination Lib V5\UseCases\Strategies\StrategyEngine.mqh>
 input int    InpBars     = 1000;              // closed bars replayed (the EA keeps 1000)
 input string InpProgram  = "EA V5 SQLLite";   // the folder of the EA in MQL5\Files

 #define PARITY_WARMUP  600   // bars more than InpBars copied: the fractal look-back (CONDITION_FRACTAL_BACK) and the warm-up

 //--- An indicator of a slot: every buffer copied once, read by bar time (CIndicatorDE::Value)
 class CParityIndicator : public CIndicatorDE
  {
   private:
    string            m_sym;
    ENUM_TIMEFRAMES   m_tf;
    int               m_h;
    int               m_count;
    double            m_buf0[],m_buf1[];   // series order: index = shift - 1
   public:
                      CParityIndicator(const string symbol,const ENUM_TIMEFRAMES tf,const int handle,const int count) : m_sym(symbol),m_tf(tf),m_h(handle),m_count(count)
                        {
                         for(int wait=0;wait<100 && ::BarsCalculated(handle)<count+1;wait++)
                            ::Sleep(100);
                         ::ArraySetAsSeries(this.m_buf0,true);
                         ::ArraySetAsSeries(this.m_buf1,true);
                         if(::CopyBuffer(handle,0,1,count,this.m_buf0)!=count)
                            ::Print(__FUNCTION__,": buffer 0 copy failed, error ",::GetLastError());
                         if(::CopyBuffer(handle,1,1,count,this.m_buf1)!=count)
                            ::ArrayResize(this.m_buf1,0);   // one buffer only (AO, AC)
                        }
                     ~CParityIndicator(void) { if(this.m_h!=INVALID_HANDLE) ::IndicatorRelease(this.m_h); }
    bool              Ok(void) const { return (this.m_h!=INVALID_HANDLE && ::ArraySize(this.m_buf0)==this.m_count); }
    virtual double    Value(const int buffer,const datetime time)
                        {
                         const int index=::iBarShift(this.m_sym,this.m_tf,time,true)-1;
                         if(index<0)
                            return EMPTY_VALUE;
                         if(buffer==0)
                            return (index<::ArraySize(this.m_buf0) ? this.m_buf0[index] : EMPTY_VALUE);
                         if(buffer==1)
                            return (index<::ArraySize(this.m_buf1) ? this.m_buf1[index] : EMPTY_VALUE);
                         return EMPTY_VALUE;
                        }
  };

 //--- The slots of the strategy on the chart pair (CStrategyPairSlots of the EA reads the collections)
 class CParitySlots : public CStrategySlots
  {
   private:
    CStrategySetting *m_strategy;
    string            m_names[];
    CParityIndicator *m_indicators[];
    CSignal          *m_signals[];
    int               Find(const string slot) const { for(int i=0;i<::ArraySize(this.m_names);i++) if(this.m_names[i]==slot) return i; return WRONG_VALUE; }
   public:
                     ~CParitySlots(void) { for(int i=0;i<::ArraySize(this.m_names);i++) { delete this.m_indicators[i]; delete this.m_signals[i]; } }
    bool              Add(const string slot,CParityIndicator *indicator,CSignal *signal)
                        {
                         const int n=::ArraySize(this.m_names);
                         ::ArrayResize(this.m_names,n+1); ::ArrayResize(this.m_indicators,n+1); ::ArrayResize(this.m_signals,n+1);
                         this.m_names[n]=slot; this.m_indicators[n]=indicator; this.m_signals[n]=signal;
                         return (indicator!=NULL && indicator.Ok());
                        }
    virtual CIndicatorDE *Indicator(const string slot) { const int i=this.Find(slot); return (i<0 ? NULL : this.m_indicators[i]); }
    virtual CSignal      *Signal(const string slot)    { const int i=this.Find(slot); return (i<0 ? NULL : this.m_signals[i]); }
  };

 //--- The handle of a slot of Profitunity (the params of CSetting_Profitunity, as Setting_StrategyIndicator has them)
 int Handle(const string symbol,const ENUM_TIMEFRAMES tf,const ENUM_INDICATOR type)
  {
   switch(type)
     {
      case IND_FRACTALS:  return ::iFractals(symbol,tf);
      case IND_ALLIGATOR: return ::iAlligator(symbol,tf,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN);
      case IND_AO:        return ::iAO(symbol,tf);
      case IND_AC:        return ::iAC(symbol,tf);
      default:            return INVALID_HANDLE;
     }
  }

 //--- The basic signal of a slot: the rows of SignalsCollection of the pair (the EA reads the same ones, CSignalsCollection::ReadDataFromDB)
 CSignal *SignalOf(const int db,const string symbol,const ENUM_TIMEFRAMES tf,const ENUM_INDICATOR type,const string params,const datetime from,const datetime to)
  {
   CSignal *signal=new CSignal();
   signal.SetKey(symbol,tf,type,params);
   const string sql=::StringFormat("SELECT bar_time,signal_direction FROM SignalsCollection WHERE name='%s' AND tf_enum=%d AND type_enum=%d AND params='%s' AND bar_time>=%I64d AND bar_time<=%I64d",
                                   symbol,(int)tf,(int)type,params,(long)from,(long)to);
   const int request=::DatabasePrepare(db,sql);
   if(request==INVALID_HANDLE)
     {
      ::Print(__FUNCTION__,": ",sql," failed, error ",::GetLastError());
      return signal;
     }
   long bar_time,direction;
   while(::DatabaseRead(request))
      if(::DatabaseColumnLong(request,0,bar_time) && ::DatabaseColumnLong(request,1,direction))
         signal.AddRow((datetime)bar_time,(ENUM_SIGNAL_DIRECTION)direction);
   ::DatabaseFinalize(request);
   signal.SetJudgedTo(to);
   return signal;
  }

 string Move(const datetime time,const string role,const long side) { return ::TimeToString(time)+" "+role+" "+(side==SIGNAL_DIRECTION_BUY ? "BUY" : side==SIGNAL_DIRECTION_SELL ? "SELL" : (string)side); }

 void OnStart(void)
  {
   const string symbol=::Symbol();
   const ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::Period();
   const string account=::AccountInfoString(ACCOUNT_COMPANY)+::AccountInfoString(ACCOUNT_SERVER)+"_"+(string)::AccountInfoInteger(ACCOUNT_LOGIN);
   const string file=InpProgram+"\\Database\\Accounts\\"+account+".sqlite3";
   const int db=::DatabaseOpen(file,DATABASE_OPEN_READONLY);
   if(db==INVALID_HANDLE)
     {
      ::Print("Strategy Parity: cannot open ",file,", error ",::GetLastError());
      return;
     }
   CSetting_Profitunity strategy;
   const datetime first=::iTime(symbol,tf,InpBars),last=::iTime(symbol,tf,1);
   //--- The slots
   CParitySlots slots;
   bool ok=true;
   for(int s=0;s<strategy.IndicatorsTotal();s++)
     {
      CStrategyIndicatorSetting *slot=strategy.Indicator(s);
      const ENUM_INDICATOR type=(ENUM_INDICATOR)slot.SourceId();
      CParityIndicator *indicator=new CParityIndicator(symbol,tf,Handle(symbol,tf,type),InpBars+PARITY_WARMUP);
      CSignal *signal=SignalOf(db,symbol,tf,type,slot.Params(),::iTime(symbol,tf,InpBars+PARITY_WARMUP),last);
      if(!slots.Add(slot.Slot(),indicator,signal))
        {
         ::Print("Strategy Parity: slot ",slot.Slot()," has no values (",::EnumToString(type),")");
         ok=false;
        }
     }
   //--- The rows Python saved on the bars replayed
   string py[];
   const string sql=::StringFormat("SELECT bar_time,role,signal_direction FROM StrategyCollection WHERE name='%s' AND tf_enum=%d AND strategy_id=%d AND bar_time>=%I64d AND bar_time<=%I64d ORDER BY bar_time,role",
                                   symbol,(int)tf,strategy.StrategyId(),(long)first,(long)last);
   const int request=::DatabasePrepare(db,sql);
   if(request!=INVALID_HANDLE)
     {
      long bar_time,side;
      string role;
      while(::DatabaseRead(request))
         if(::DatabaseColumnLong(request,0,bar_time) && ::DatabaseColumnText(request,1,role) && ::DatabaseColumnLong(request,2,side))
           {
            const int n=::ArraySize(py);
            ::ArrayResize(py,n+1);
            py[n]=Move((datetime)bar_time,role,side);
           }
      ::DatabaseFinalize(request);
     }
   else
      ::Print("Strategy Parity: ",sql," failed, error ",::GetLastError());
   ::DatabaseClose(db);
   if(!ok)
      return;
   //--- The engine on every bar, the open entries counted as Strategy\engine.py (an exit closes every position of its side)
   CStrategyEngine engine;
   string mine[];
   int buys=0,sells=0,waited=0;
   for(int shift=InpBars;shift>=1;shift--)
     {
      string roles[];
      ENUM_SIGNAL_DIRECTION sides[];
      const int moves=engine.Calculate(::GetPointer(strategy),::GetPointer(slots),symbol,tf,shift,buys,sells,roles,sides);
      if(moves==WRONG_VALUE)
        {
         waited++;
         continue;
        }
      const datetime time=::iTime(symbol,tf,shift);
      for(int i=0;i<moves;i++)
        {
         if(roles[i]==STRATEGY_ROLE_ENTRY)
           { if(sides[i]==SIGNAL_DIRECTION_BUY) buys++; else sells++; }
         else
           { if(sides[i]==SIGNAL_DIRECTION_BUY) buys=0; else sells=0; }
         const int n=::ArraySize(mine);
         ::ArrayResize(mine,n+1);
         mine[n]=Move(time,roles[i],sides[i]);
        }
     }
   //--- The comparison
   int matched=0,only_py=0,only_mine=0;
   for(int i=0;i<::ArraySize(py);i++)
     {
      bool found=false;
      for(int j=0;j<::ArraySize(mine) && !found;j++)
         found=(mine[j]==py[i]);
      if(found)
         matched++;
      else
        {
         only_py++;
         ::Print("Strategy Parity: only Python  ",py[i]);
        }
     }
   for(int j=0;j<::ArraySize(mine);j++)
     {
      bool found=false;
      for(int i=0;i<::ArraySize(py) && !found;i++)
         found=(py[i]==mine[j]);
      if(!found)
        {
         only_mine++;
         ::Print("Strategy Parity: only engine  ",mine[j]);
        }
     }
   ::Print("Strategy Parity ",symbol," ",::EnumToString(tf)," ",::TimeToString(first)," .. ",::TimeToString(last),": ",InpBars," bars (",waited," not ready), ",
           ::ArraySize(py)," rows of Python, ",::ArraySize(mine)," of the engine, ",matched," matched, ",only_py," only Python, ",only_mine," only engine");
  }
