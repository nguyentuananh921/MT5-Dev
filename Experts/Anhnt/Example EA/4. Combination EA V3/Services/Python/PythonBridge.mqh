//+------------------------------------------------------------------+
//|                                                 PythonBridge.mqh |
//+------------------------------------------------------------------+
#ifndef __PYTHONBRIDGE_MQH__
#define __PYTHONBRIDGE_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\IndicatorsCollection.mqh>
 #import "kernel32.dll"
  uint WinExec(uchar &command[],int show);
 #import
 #define PYTHON_HOST                "127.0.0.1"
 #define PYTHON_PORT                (9090)
 #define PYTHON_EXE                 "python"
 #define PYTHON_SCRIPT              "\\MQL5\\Include\\Vendors\\Anhnt\\Library\\4. Combination Lib V3\\Python\\main.py"
 #define PYTHON_CONNECT_TIMEOUT_MS  (100)
 #define PYTHON_RETRY_MS            (500)
 #define SEND_RETRY_MS              (300)     // a message that does not go at once (Python has not read the last one) is sent again for this long at most
 #define PYTHON_WAIT_MS             (20000)
 #define PYTHON_RELAUNCH_BLOCK_MS   (30000)
 #define PYTHON_WINDOW_SHOW         (1)
 #define PYTHON_PRETRADE_MONITOR_INTERVAL_MS (250)    // the indicator states are asked for at most this often
 #define PYTHON_PRETRADE_MONITOR_TIMEOUT_MS  (3000)   // an unanswered ask is dropped after this long
 #define PYTHON_CANDLE_TIMEOUT_MS            (3000)   // the same for the ask of the candle window
 enum ENUM_PYTHON_STATE
  {
   PYTHON_STATE_DISCONNECTED,
   PYTHON_STATE_CONNECTING,
   PYTHON_STATE_READY
  };
//+------------------------------------------------------------------+
//| Talks to the Python process over a local socket: launches it,    |
//| sends the config (init + watch), reads the Swing, BOS/CHoCH and  |
//| indicator signal lines it answers with and keeps them as         |
//| CBarSwingSeries / CMarketStructureSeries / CIndicatorSignalSeries.|
//| Drawing is CSmartMoneySync's job                                 |
//+------------------------------------------------------------------+
 class CPythonBridge : public CBaseObj
  {
   private:
     CSymbolTFManager          *m_symbol_tf_manager;         // EA owns: the pairs the EA shows
     CSymbolsCollection        *m_SymbolsCollection;         // EA owns: the Market Watch symbols, Python calculates every one of them on every TF
     string                    m_last_init;                  // the init Python got last: a Reconfigure that would send the same one is not sent
     CSwingSetting        *m_SwingSetting;         // EA owns
     CTrendlineSetting         *m_TrendlineSetting;          // EA owns: what Python calculates goes to it in the init (Json)
     CSupportResistanceSetting *m_SupportResistanceSetting;    // EA owns: the same
     CMomentumCandleSetting          *m_MomentumCandleSetting;           // EA owns: the same (the momentum candles and the supply / demand zones)
     CMarketConditionSetting   *m_MarketConditionSetting;    // EA owns: the same
     CIndicatorTemplateManager *m_IndicatorTemplateManager;  // EA owns
     CPatternManager           *m_PatternManager;            // EA owns
     CSmartMoneySync          *m_SmartMoneySync;            // EA owns
     CIndicatorsCollection    *m_IndicatorsCollection;      // EA owns: one CIndicatorDE per indicator, the state Python reports, what the panel shows
     CLifecycleCollection     *m_LifecycleCollection;       // EA owns: the lifecycle events Python reports (Born ... Dead)
     CLifecycleSync           *m_LifecycleSync;             // EA owns: draws them
     CArrayObj                 m_swings;                     // CBarSwingSeries received from Python
     CArrayObj                 m_structures;                 // CMarketStructureSeries received from Python
     CArrayObj                 m_signals;                    // CIndicatorSignalSeries received from Python
     CArrayObj                 m_patterns;                   // candle patterns received from Python, same class: the label is the pattern name
     CArrayObj                 m_conditions;                 // CMarketConditionSeries received from Python: every change of Market State / Phase, every TF
     CArrayObj                 m_movements;                  // CMovementSeries received from Python: every leg between two Swings (Impulse / Pullback), every TF
     int                       m_socket;
     string                    m_rx;
     ENUM_PYTHON_STATE         m_state;
     ulong                     m_launch_ms;                  // members survive a chart change: do not launch a second Python
     ulong                     m_wait_start_ms;
     ulong                     m_last_try_ms;
     int                       m_connect_error;
     bool                      m_indicator_state_changed;              // an indicator of this answer reported a value or a signal that is not the same
     bool                      m_pre_trade_monitor_busy;               // an ask for the indicator states is on its way
     ulong                     m_pre_trade_monitor_ms;                 // when it was sent
     bool                      m_watch_done;
     bool                      m_candle_mode;                          // the lines of the answer for one candle are arriving: they are kept like the others, not drawn or announced
     bool                      m_candle_done;                          // that answer is complete
     datetime                  m_candle_time;                          // the candle it was asked for
     ulong                     m_candle_ms;                            // when it was asked
     int                       m_candle_waiting;                       // asked and not answered yet: the answer is complete when none is left
     void                      Log(const string method,const string text) const;
     bool                      Send(const string text);
     string                    BuildInit(void);
     void                      SendInit(void);
     void                      SendWatch(void);
     void                      SendPreTradeSymbolMonitor(void);
     ENUM_SWING_TYPE           SwingTypeByText(const string text) const;
     ENUM_SWING_STRUCTURE      SwingStructureByText(const string text) const;
     ENUM_MARKET_STRUCTURE_TYPE MarketStructureTypeByText(const string text) const;
     void                      StoreSwing(const string line);
     void                      StoreStructure(const string line);
     void                      StoreLifecycle(const string line);
     void                      StoreCondition(const string line);
     void                      StoreMovement(const string line);
     ENUM_MOVE_TYPE            MoveTypeByText(const string text) const;
     ENUM_PULLBACK_DEPTH       PullbackDepthByText(const string text) const;
     ENUM_MARKET_STATE         MarketStateByText(const string text) const;
     ENUM_MARKET_PHASE         MarketPhaseByText(const string text) const;
     ENUM_LIFECYCLE_EVENT      LifecycleEventByText(const string text) const;
     ENUM_LIFECYCLE_OBJECT_KIND LifecycleKindByText(const string text) const;
     ENUM_LIFECYCLE_DEAD_REASON LifecycleReasonByText(const string text) const;
     void                      StoreSignal(const string line,CArrayObj &list,const int source);
     void                      StorePreTradeSymbolMonitor(const string line);
     bool                      TryConnect(void);
     void                      Launch(void);
   public:
     void                      OnInitEvent(CSymbolTFManager *symtf_mgr,CSwingSetting *setting,CTrendlineSetting *trendline,CSupportResistanceSetting *support_resistance,CMarketConditionSetting *condition,
                                           CIndicatorTemplateManager *indicators,CPatternManager *patterns,CSmartMoneySync *sync,CIndicatorsCollection *indicators_collection);
   //--- Connect to Python (launch it when it is not running) and ask for the current chart
     void                      SetMomentumCandleSetting(CMomentumCandleSetting *setting) { this.m_MomentumCandleSetting=setting; }
     void                      Start(void);
   //--- Read what Python sent; call on every timer
     void                      Poll(void);
   //--- Ask Python for the states of the indicators on the forming bar; call on every tick, it is throttled and one ask at a time
     void                      RequestPreTradeSymbolMonitor(void);
   //--- The tracked pairs or the Swing setting changed: send the configuration and the chart again
     void                      Reconfigure(void);
   //--- quit_python: also tell Python to shut down (EA removed), otherwise it keeps running
     void                      Stop(const bool quit_python);
     CArrayObj                *Swings(void)                  { return &this.m_swings;      }
     CArrayObj                *Structures(void)              { return &this.m_structures;  }
     CArrayObj                *Signals(void)                 { return &this.m_signals;     }
     CArrayObj                *Patterns(void)                { return &this.m_patterns;    }
     CArrayObj                *Conditions(void)              { return &this.m_conditions;  }
     CArrayObj                *Movements(void)               { return &this.m_movements;   }
   //--- Where the lifecycle events go (the collection keeps them, the sync draws them)
     void                      SetLifecycle(CLifecycleCollection *collection,CLifecycleSync *sync) { this.m_LifecycleCollection=collection; this.m_LifecycleSync=sync; }
     void                      SetSymbolsCollection(CSymbolsCollection *collection) { this.m_SymbolsCollection=collection; }
   //--- A new bar was seen on these TFs of a symbol (by the time engine of the EA): Python calculates those pairs and sends the new lines
     bool                      SendNewBar(const string symbol,const ENUM_TIMEFRAMES &tfs[]);
   //--- Ask Python for every line that falls on the candle that starts at bar_time, on every TF the EA shows; false when it cannot be asked now
     bool                      RequestCandleInfo(const datetime bar_time);
   //--- true once, when the answer to the last RequestCandleInfo is complete; bar_time = the candle it was for
     bool                      CandleInfoDone(datetime &bar_time);
   //--- true when the answer of the last watch is complete: the markers are drawn from it, once, by Poll
     bool                      WatchDone(void)                  const { return this.m_watch_done;     }
                               CPythonBridge(void);
  };
//+------------------------------------------------------------------+
CPythonBridge::CPythonBridge(void) : m_symbol_tf_manager(NULL),
                                     m_SymbolsCollection(NULL),
                                     m_last_init(""),
                                     m_SwingSetting(NULL),
                                     m_IndicatorsCollection(NULL),
                                     m_LifecycleCollection(NULL),
                                     m_LifecycleSync(NULL),
                                     m_TrendlineSetting(NULL),
                                     m_SupportResistanceSetting(NULL),
                                     m_MomentumCandleSetting(NULL),
                                     m_MarketConditionSetting(NULL),
                                     m_indicator_state_changed(false),
                                     m_pre_trade_monitor_busy(false),
                                     m_pre_trade_monitor_ms(0),
                                     m_candle_mode(false),
                                     m_candle_done(false),
                                     m_candle_time(0),
                                     m_candle_ms(0),
                                     m_candle_waiting(0),
                                     m_IndicatorTemplateManager(NULL),
                                     m_PatternManager(NULL),
                                     m_SmartMoneySync(NULL),
                                     m_socket(INVALID_HANDLE),
                                     m_rx(""),
                                     m_state(PYTHON_STATE_DISCONNECTED),
                                     m_launch_ms(0),
                                     m_wait_start_ms(0),
                                     m_last_try_ms(0),
                                     m_connect_error(0),
                                     m_watch_done(false)
  {
  }
//+------------------------------------------------------------------+
void CPythonBridge::OnInitEvent(CSymbolTFManager *symtf_mgr,CSwingSetting *setting,CTrendlineSetting *trendline,CSupportResistanceSetting *support_resistance,CMarketConditionSetting *condition,
                                CIndicatorTemplateManager *indicators,CPatternManager *patterns,CSmartMoneySync *sync,CIndicatorsCollection *indicators_collection)
  {
   this.m_symbol_tf_manager=symtf_mgr;
   this.m_SwingSetting=setting;
   this.m_TrendlineSetting=trendline;
   this.m_SupportResistanceSetting=support_resistance;
   this.m_MarketConditionSetting=condition;
   this.m_IndicatorTemplateManager=indicators;
   this.m_PatternManager=patterns;
   this.m_SmartMoneySync=sync;
   this.m_IndicatorsCollection=indicators_collection;
  }
//+------------------------------------------------------------------+
void CPythonBridge::Log(const string method,const string text) const
  {
   CMessage::ToFile(this.GetFolderName(),"CPythonBridge",method,text);
  }
//+------------------------------------------------------------------+
bool CPythonBridge::Send(const string text)
  {
   uchar data[];
   int len=::StringToCharArray(text,data,0,WHOLE_ARRAY,CP_UTF8)-1;   // drop the terminating zero
   //--- A big message does not go in one call when Python has not read the last one yet: what is left is sent again, for a short time at most
   int sent=0;
   ulong start=::GetTickCount64();
   while(sent<len)
     {
      uchar rest[];
      ::ArrayCopy(rest,data,0,sent,len-sent);
      int n=::SocketSend(this.m_socket,rest,len-sent);
      if(n<0)
         return false;
      sent+=n;
      if(sent<len)
        {
         if(::GetTickCount64()-start>SEND_RETRY_MS)
            return false;
         ::Sleep(1);
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
string CPythonBridge::BuildInit(void)
  {
   //--- The pairs the EA shows (its CSymbolTFManager) and the chart's own: Python has them loaded before it answers
   string pairs="";
   bool chart_listed=false;
   string pair_symbols[];
   ENUM_TIMEFRAMES pair_tfs[];
   int pair_total=this.m_symbol_tf_manager.Pairs(pair_symbols,pair_tfs);
   for(int i=0;i<pair_total;i++)
     {
      pairs+=(pairs=="" ? "" : ",")+"[\""+pair_symbols[i]+"\",\""+TimeframeDescription(pair_tfs[i])+"\"]";
      chart_listed|=(pair_symbols[i]==::Symbol() && pair_tfs[i]==(ENUM_TIMEFRAMES)::Period());
     }
   if(!chart_listed)
      pairs+=(pairs=="" ? "" : ",")+"[\""+::Symbol()+"\",\""+TimeframeDescription((ENUM_TIMEFRAMES)::Period())+"\"]";
   //--- Every Market Watch symbol: Python calculates all of them on every TF it knows
   string symbols="\""+::Symbol()+"\"";
   if(this.m_SymbolsCollection!=NULL)
     {
      CArrayObj *list=this.m_SymbolsCollection.GetList();
      for(int i=0;i<list.Total();i++)
        {
         CSymbol *symbol=list.At(i);
         if(symbol!=NULL && ::StringFind(symbols,"\""+symbol.Name()+"\"")<0)
            symbols+=",\""+symbol.Name()+"\"";
        }
     }
   string swing="{\"strength\":"+(string)this.m_SwingSetting.Strength()+
                ",\"use_wick\":"+(this.m_SwingSetting.PriceBasis()==SWING_PRICE_BASIS_WICK ? "true" : "false")+"}";
   //--- The templates as the panel holds them (saved or not), on one line
   string indicators="";
   if(this.m_IndicatorTemplateManager!=NULL)
      this.m_IndicatorTemplateManager.BuildJsonSection(indicators);
   ::StringReplace(indicators,"\r"," ");
   ::StringReplace(indicators,"\n"," ");
   if(indicators=="")
      indicators="[]";
   return "{\"cmd\":\"init\",\"count\":0,\"swing\":"+swing+",\"trendline\":"+this.m_TrendlineSetting.Json()+",\"zone\":"+this.m_SupportResistanceSetting.Json()+",\"momentum\":"+(this.m_MomentumCandleSetting!=NULL ? this.m_MomentumCandleSetting.Json() : "{}")+",\"condition\":"+this.m_MarketConditionSetting.Json()+
          ",\"pairs\":["+pairs+"],\"symbols\":["+symbols+"],\"indicators\":"+indicators+"}\n";
  }
//+------------------------------------------------------------------+
void CPythonBridge::SendInit(void)
  {
   string text=this.BuildInit();
   if(this.Send(text))
     {
      this.m_last_init=text;
      this.Log("SendInit","init sent to Python, "+(string)this.m_symbol_tf_manager.Total()+" pair(s) shown");
     }
   else
      this.Log("SendInit","send failed, error "+(string)::GetLastError());
  }
//+------------------------------------------------------------------+
void CPythonBridge::SendWatch(void)
  {
   this.m_swings.Clear();
   this.m_structures.Clear();
   this.m_signals.Clear();
   this.m_patterns.Clear();
   this.m_conditions.Clear();
   this.m_movements.Clear();
   if(this.m_LifecycleCollection!=NULL)
      this.m_LifecycleCollection.Clear();
   if(this.m_LifecycleSync!=NULL)
      this.m_LifecycleSync.DeleteAll();
   this.m_SmartMoneySync.DeleteMarkers();
   this.m_watch_done=false;
   this.m_candle_mode=false;
   this.m_candle_done=false;
   this.m_candle_waiting=0;
   string tf_text=TimeframeDescription((ENUM_TIMEFRAMES)::Period());
   //--- The TFs of this symbol the EA shows (its CSymbolTFManager): the candle window lists them, Python sends no other
   string tfs="\""+tf_text+"\"";
   ENUM_TIMEFRAMES own_tfs[];
   int own_total=this.m_symbol_tf_manager.TimeframesOf(::Symbol(),own_tfs);
   for(int i=0;i<own_total;i++)
     {
      string own_text=TimeframeDescription(own_tfs[i]);
      if(::StringFind(tfs,"\""+own_text+"\"")<0)
         tfs+=",\""+own_text+"\"";
     }
   //--- Everything is asked for the bars that are drawn only (SMC_DRAW_BARS), 0 when the chart holds fewer bars
   string drawn_from=(string)(long)::iTime(::Symbol(),::Period(),SMC_DRAW_BARS-1);
   string text="{\"cmd\":\"watch\",\"symbol\":\""+::Symbol()+"\",\"tf\":\""+tf_text+"\",\"structures\":true,\"signals\":true,\"patterns\":true,\"lifecycle\":true,\"conditions\":true,\"movements\":true,\"tfs\":["+tfs+"],\"from_time\":"+
               drawn_from+",\"signals_from\":"+drawn_from+"}\n";
   if(this.Send(text))
      this.Log("SendWatch","watch sent for "+::Symbol()+" "+tf_text);
   else
      this.Log("SendWatch","send failed, error "+(string)::GetLastError());
  }
bool CPythonBridge::SendNewBar(const string symbol,const ENUM_TIMEFRAMES &tfs[])
  {
   if(this.m_state!=PYTHON_STATE_READY)
      return false;
   string list="";
   for(int i=0;i<::ArraySize(tfs);i++)
      list+=(list=="" ? "" : ",")+"\""+TimeframeDescription(tfs[i])+"\"";
   if(this.Send("{\"cmd\":\"new_bar\",\"symbol\":\""+symbol+"\",\"tfs\":["+list+"]}\n"))
      return true;
   this.Log("SendNewBar","send failed, error "+(string)::GetLastError());
   return false;
  }
//+------------------------------------------------------------------+
bool CPythonBridge::RequestCandleInfo(const datetime bar_time)
  {
   if(this.m_state!=PYTHON_STATE_READY || !this.m_watch_done)
      return false;   // the first answer is still arriving: the lines of this one would be taken for part of it
   this.m_candle_time=bar_time;
   this.m_candle_done=false;
   string text="{\"cmd\":\"candle_info\",\"symbol\":\""+::Symbol()+"\",\"time\":"+(string)(long)bar_time+",\"seconds\":"+(string)::PeriodSeconds()+"}\n";
   if(!this.Send(text))
     {
      this.Log("RequestCandleInfo","send failed, error "+(string)::GetLastError());
      return false;
     }
   this.m_candle_waiting++;
   this.m_candle_mode=true;
   this.m_candle_ms=::GetTickCount64();
   return true;
  }
//+------------------------------------------------------------------+
bool CPythonBridge::CandleInfoDone(datetime &bar_time)
  {
   if(!this.m_candle_done)
      return false;
   this.m_candle_done=false;
   bar_time=this.m_candle_time;
   return true;
  }
//+------------------------------------------------------------------+
void CPythonBridge::SendPreTradeSymbolMonitor(void)
  {
   if(this.m_IndicatorsCollection==NULL)
      return;
   this.m_pre_trade_monitor_busy=false;
   this.m_pre_trade_monitor_ms=0;
   this.RequestPreTradeSymbolMonitor();
  }
//+------------------------------------------------------------------+
void CPythonBridge::RequestPreTradeSymbolMonitor(void)
  {
   if(this.m_IndicatorsCollection==NULL || this.m_state!=PYTHON_STATE_READY)
      return;
   ulong now=::GetTickCount64();
   if(this.m_pre_trade_monitor_busy && now-this.m_pre_trade_monitor_ms<PYTHON_PRETRADE_MONITOR_TIMEOUT_MS)
      return;
   if(now-this.m_pre_trade_monitor_ms<PYTHON_PRETRADE_MONITOR_INTERVAL_MS)
      return;
   this.m_pre_trade_monitor_ms=now;
   this.m_pre_trade_monitor_busy=this.Send("{\"cmd\":\"pre_trade_symbol_monitor\"}\n");
   if(!this.m_pre_trade_monitor_busy)
      this.Log("RequestPreTradeSymbolMonitor","send failed, error "+(string)::GetLastError());
  }
//+------------------------------------------------------------------+
void CPythonBridge::StorePreTradeSymbolMonitor(const string line)
  {
   string part[];
   if(this.m_IndicatorsCollection==NULL || this.m_IndicatorTemplateManager==NULL || ::StringSplit(line,'|',part)!=7)
      return;
   //--- part[3] is the position of the template row: it gives the type and the parameters
   CIndicatorSetting *template_row=this.m_IndicatorTemplateManager.At((int)::StringToInteger(part[3]));
   if(template_row==NULL)
      return;
   MqlParam params[];
   template_row.GetRawParams(params);
   ENUM_TIMEFRAMES tf=TimestampByDescription(part[2]);
   CIndicatorDE *indicator=this.m_IndicatorsCollection.GetIndicator(template_row.TypeEnum(),params,part[1],tf);
   if(indicator==NULL)
      indicator=this.m_IndicatorsCollection.CreateIndicator(template_row.TypeEnum(),params,part[1],tf);
   if(indicator==NULL)
      return;
   indicator.SetState((part[4]=="nan" ? EMPTY_VALUE : ::StringToDouble(part[4])),(part[5]=="nan" ? EMPTY_VALUE : ::StringToDouble(part[5])),
                      (part[6]=="BUY" ? SIGNAL_BUY : part[6]=="SELL" ? SIGNAL_SELL : SIGNAL_NONE));
   if(indicator.IsEvent())
      this.m_indicator_state_changed=true;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
ENUM_SWING_TYPE CPythonBridge::SwingTypeByText(const string text) const
  {
   return (text=="HIGH" ? SWING_TYPE_HIGH : text=="LOW" ? SWING_TYPE_LOW : SWING_TYPE_NONE);
  }
//+------------------------------------------------------------------+
ENUM_SWING_STRUCTURE CPythonBridge::SwingStructureByText(const string text) const
  {
   return (text=="HH" ? SWING_STRUCTURE_HH : text=="LH" ? SWING_STRUCTURE_LH :
           text=="HL" ? SWING_STRUCTURE_HL : text=="LL" ? SWING_STRUCTURE_LL : SWING_STRUCTURE_NONE);
  }
//+------------------------------------------------------------------+
ENUM_MARKET_STRUCTURE_TYPE CPythonBridge::MarketStructureTypeByText(const string text) const
  {
   return (text=="BOS" ? MARKET_STRUCTURE_BOS : text=="CHOCH" ? MARKET_STRUCTURE_CHOCH : MARKET_STRUCTURE_NONE);
  }
//+------------------------------------------------------------------+
void CPythonBridge::StoreSwing(const string line)
  {
   string part[];
   if(::StringSplit(line,'|',part)!=8)
     {
      this.Log("StoreSwing","malformed line "+line);
      return;
     }
   CBarSwingSeries *swing=new CBarSwingSeries(this.SwingTypeByText(part[5]),part[1],(ENUM_TIMEFRAMES)TimestampByDescription(part[2]),
                                              (datetime)::StringToInteger(part[3]),(datetime)::StringToInteger(part[4]),
                                              ::StringToDouble(part[6]),this.m_SwingSetting.Strength(),this.m_SwingSetting.PriceBasis());
   swing.Structure(this.SwingStructureByText(part[7]));
   if(!this.m_watch_done)
     {
      this.m_swings.Add(swing);   // initial burst: sorted and de-duplicated once, when it ends
      return;
     }
   this.m_swings.Sort(SORT_BY_SWING_CODE);
   if(this.m_swings.Search(swing)>=0)
     {
      delete swing;
      return;
     }
   this.m_swings.InsertSort(swing);
   if(this.m_candle_mode)
      return;   // asked for by the candle window: kept, not news
   this.Log("StoreSwing","new "+part[5]+" "+part[7]+" at "+::TimeToString(swing.Time())+" price "+part[6]);
   this.m_SmartMoneySync.Add(swing);
  }
//+------------------------------------------------------------------+
void CPythonBridge::StoreStructure(const string line)
  {
   string part[];
   if(::StringSplit(line,'|',part)!=11)
     {
      this.Log("StoreStructure","malformed line "+line);
      return;
     }
   CMarketStructureSeries *ms=new CMarketStructureSeries(this.MarketStructureTypeByText(part[5]),(part[6]=="BUY" ? SIGNAL_BUY : SIGNAL_SELL),
                                                         part[1],(ENUM_TIMEFRAMES)TimestampByDescription(part[2]),
                                                         (datetime)::StringToInteger(part[3]),(datetime)::StringToInteger(part[4]),
                                                         ::StringToDouble(part[7]));
   ms.Phase(this.MarketPhaseByText(part[8]));
   ms.Strong((datetime)::StringToInteger(part[9]),::StringToDouble(part[10]));
   if(!this.m_watch_done)
     {
      this.m_structures.Add(ms);   // initial burst: drawn once, when it ends
      return;
     }
   this.m_structures.Sort(SORT_BY_MARKET_STRUCTURE_CODE);
   if(this.m_structures.Search(ms)>=0)
     {
      delete ms;
      return;
     }
   this.m_structures.InsertSort(ms);
   if(this.m_candle_mode)
      return;
   this.Log("StoreStructure","new "+part[5]+" "+part[6]+" at "+::TimeToString(ms.Time())+" level "+part[7]);
   this.m_SmartMoneySync.Add(ms);
  }
//+------------------------------------------------------------------+
void CPythonBridge::StoreLifecycle(const string line)
  {
   if(this.m_LifecycleCollection==NULL)
      return;
   //--- lifecycle|symbol|tf|kind|origin_time|time|event|dir|time_a|price_a|time_b|price_b|source|reason
   string part[];
   if(::StringSplit(line,'|',part)!=14)
     {
      this.Log("StoreLifecycle","malformed line "+line);
      return;
     }
   ENUM_LIFECYCLE_EVENT event=this.LifecycleEventByText(part[6]);
   ENUM_LIFECYCLE_OBJECT_KIND kind=this.LifecycleKindByText(part[3]);
   if(event==LIFECYCLE_EVENT_NO_EVENT || kind==LIFECYCLE_OBJECT_NONE)
     {
      this.Log("StoreLifecycle","unknown event or kind in "+line);
      return;
     }
   CLifecycleSeries *record=new CLifecycleSeries(event,kind,part[1],(ENUM_TIMEFRAMES)TimestampByDescription(part[2]),
                                                 (datetime)::StringToInteger(part[4]),(datetime)::StringToInteger(part[5]),
                                                 (part[7]=="BUY" ? SIGNAL_BUY : SIGNAL_SELL),
                                                 (datetime)::StringToInteger(part[8]),::StringToDouble(part[9]),
                                                 (datetime)::StringToInteger(part[10]),::StringToDouble(part[11]),
                                                 (part[12]=="USER" ? LIFECYCLE_SOURCE_USER : LIFECYCLE_SOURCE_AUTO),
                                                 this.LifecycleReasonByText(part[13]));
   //--- the first burst after a watch is history, not news: it is kept without announcing it, and drawn once when it ends
   bool news=(this.m_watch_done && !this.m_candle_mode);   // what the candle window asked for is kept, not announced
   if(this.m_LifecycleCollection.Add(record,news) && news)
      this.Log("StoreLifecycle","new "+part[6]+" "+part[3]+" "+part[7]+" at "+::TimeToString((datetime)::StringToInteger(part[5])));
  }
//+------------------------------------------------------------------+
ENUM_MARKET_STATE CPythonBridge::MarketStateByText(const string text) const
  {
   return (text=="UPTREND" ? MARKET_STATE_UPTREND : text=="DOWNTREND" ? MARKET_STATE_DOWNTREND : text=="RANGE" ? MARKET_STATE_RANGE : MARKET_STATE_NONE);
  }
//+------------------------------------------------------------------+
ENUM_MARKET_PHASE CPythonBridge::MarketPhaseByText(const string text) const
  {
   return (text=="ACCUMULATION" ? MARKET_PHASE_ACCUMULATION : text=="MARKUP" ? MARKET_PHASE_MARKUP :
           text=="DISTRIBUTION" ? MARKET_PHASE_DISTRIBUTION : text=="MARKDOWN" ? MARKET_PHASE_MARKDOWN : MARKET_PHASE_NONE);
  }
//+------------------------------------------------------------------+
void CPythonBridge::StoreCondition(const string line)
  {
   //--- condition|symbol|tf|time|state|phase
   string part[];
   if(::StringSplit(line,'|',part)!=6)
     {
      this.Log("StoreCondition","malformed line "+line);
      return;
     }
   CMarketConditionSeries *condition=new CMarketConditionSeries((datetime)::StringToInteger(part[3]),(ENUM_TIMEFRAMES)TimestampByDescription(part[2]),
                                                                this.MarketStateByText(part[4]),this.MarketPhaseByText(part[5]));
   if(!this.m_watch_done)
     {
      this.m_conditions.Add(condition);   // initial burst: sorted once, when it ends
      return;
     }
   this.m_conditions.Sort();
   if(this.m_conditions.Search(condition)>=0)
     {
      delete condition;
      return;
     }
   this.m_conditions.InsertSort(condition);
   if(this.m_candle_mode)
      return;
   this.Log("StoreCondition","new "+part[4]+" / "+part[5]+" at "+::TimeToString(condition.Time())+" on "+part[2]);
   ::EventChartCustom(::ChartID(),(ushort)MARKET_STORY_EVENT_CHANGED,0,0.0,"");   // the Market Story table follows
  }
//+------------------------------------------------------------------+
ENUM_MOVE_TYPE CPythonBridge::MoveTypeByText(const string text) const
  {
   return (text=="IMPULSE" ? MOVE_TYPE_IMPULSE : text=="PULLBACK" ? MOVE_TYPE_PULLBACK : MOVE_TYPE_NONE);
  }
//+------------------------------------------------------------------+
ENUM_PULLBACK_DEPTH CPythonBridge::PullbackDepthByText(const string text) const
  {
   return (text=="AGGRESSIVE" ? PULLBACK_DEPTH_AGGRESSIVE : text=="HEALTHY" ? PULLBACK_DEPTH_HEALTHY : text=="DEEP" ? PULLBACK_DEPTH_DEEP :
           text=="WEAK" ? PULLBACK_DEPTH_WEAK : text=="INVALID" ? PULLBACK_DEPTH_INVALID : PULLBACK_DEPTH_NONE);
  }
//+------------------------------------------------------------------+
void CPythonBridge::StoreMovement(const string line)
  {
   //--- movement|symbol|tf|time|start_time|start_price|end_time|end_price|dir|move|length_atr|bars|retracement|depth
   string part[];
   if(::StringSplit(line,'|',part)!=14)
     {
      this.Log("StoreMovement","malformed line "+line);
      return;
     }
   CMovementSeries *leg=new CMovementSeries((datetime)::StringToInteger(part[3]),(ENUM_TIMEFRAMES)TimestampByDescription(part[2]),
                                            (datetime)::StringToInteger(part[4]),::StringToDouble(part[5]),
                                            (datetime)::StringToInteger(part[6]),::StringToDouble(part[7]),
                                            (part[8]=="BUY" ? SIGNAL_BUY : SIGNAL_SELL),this.MoveTypeByText(part[9]),
                                            ::StringToDouble(part[10]),(int)::StringToInteger(part[11]),::StringToDouble(part[12]),
                                            this.PullbackDepthByText(part[13]));
   if(!this.m_watch_done)
     {
      this.m_movements.Add(leg);   // initial burst: sorted once, when it ends
      return;
     }
   this.m_movements.Sort();
   if(this.m_movements.Search(leg)>=0)
     {
      delete leg;
      return;
     }
   this.m_movements.InsertSort(leg);
   if(this.m_candle_mode)
      return;
   this.Log("StoreMovement","new "+part[9]+" "+part[8]+" leg ending at "+::TimeToString(leg.EndTime())+" on "+part[2]);
   this.m_SmartMoneySync.Add(leg);
   ::EventChartCustom(::ChartID(),(ushort)MARKET_STORY_EVENT_CHANGED,0,0.0,"");
  }
//+------------------------------------------------------------------+
ENUM_LIFECYCLE_EVENT CPythonBridge::LifecycleEventByText(const string text) const
  {
   return (text=="BORN" ? LIFECYCLE_EVENT_BORN : text=="MODIFIED" ? LIFECYCLE_EVENT_MODIFIED :
           text=="TOUCHED" ? LIFECYCLE_EVENT_TOUCHED : text=="BOUNCED" ? LIFECYCLE_EVENT_BOUNCED :
           text=="BROKEN" ? LIFECYCLE_EVENT_BROKEN : text=="RESURRECTED" ? LIFECYCLE_EVENT_RESURRECTED :
           text=="SUPERSEDED" ? LIFECYCLE_EVENT_SUPERSEDED : text=="CONFIRMED" ? LIFECYCLE_EVENT_CONFIRMED :
           text=="DEAD" ? LIFECYCLE_EVENT_DEAD : LIFECYCLE_EVENT_NO_EVENT);
  }
//+------------------------------------------------------------------+
ENUM_LIFECYCLE_OBJECT_KIND CPythonBridge::LifecycleKindByText(const string text) const
  {
   return (text=="TRENDLINE" ? LIFECYCLE_OBJECT_TRENDLINE : text=="ZONE" ? LIFECYCLE_OBJECT_ZONE :
           text=="PROTECTED_LEVEL" ? LIFECYCLE_OBJECT_PROTECTED_LEVEL : text=="MOMENTUM" ? LIFECYCLE_OBJECT_MOMENTUM :
           text=="SUPPLYDEMAND" ? LIFECYCLE_OBJECT_SUPPLYDEMAND :
           text=="FVG" ? LIFECYCLE_OBJECT_FVG : LIFECYCLE_OBJECT_NONE);
  }
//+------------------------------------------------------------------+
ENUM_LIFECYCLE_DEAD_REASON CPythonBridge::LifecycleReasonByText(const string text) const
  {
   return (text=="EXPIRED" ? LIFECYCLE_DEAD_EXPIRED : text=="USER_DELETED" ? LIFECYCLE_DEAD_USER_DELETED :
           text=="MERGED" ? LIFECYCLE_DEAD_MERGED : text=="OBSOLETE" ? LIFECYCLE_DEAD_OBSOLETE : text=="BROKEN" ? LIFECYCLE_DEAD_BROKEN : text=="REPLACED" ? LIFECYCLE_DEAD_REPLACED : LIFECYCLE_DEAD_NONE);
  }
//+------------------------------------------------------------------+
void CPythonBridge::StoreSignal(const string line,CArrayObj &list,const int source)
  {
   string part[];
   int fields=::StringSplit(line,'|',part);
   if(fields!=6 && fields!=7)   // 7th = the indicator template position, patterns have none
     {
      this.Log("StoreSignal","malformed line "+line);
      return;
     }
   CIndicatorSignalSeries *signal=new CIndicatorSignalSeries((datetime)::StringToInteger(part[3]),part[5]=="BUY",part[4],(fields==7 ? (int)::StringToInteger(part[6]) : -1),
                                                             (ENUM_TIMEFRAMES)TimestampByDescription(part[2]));
   signal.Neutral(part[5]=="BOTH");
   if(!this.m_watch_done)
     {
      list.Add(signal);   // initial burst: sorted once, when it ends
      return;
     }
   list.Sort();
   if(list.Search(signal)>=0)
     {
      delete signal;
      return;
     }
   list.InsertSort(signal);
   if(this.m_candle_mode)
      return;
   this.Log("StoreSignal","new "+part[5]+" "+part[4]+" at "+::TimeToString(signal.Time()));
   this.m_SmartMoneySync.Add(signal,source);
  }
//+------------------------------------------------------------------+
bool CPythonBridge::TryConnect(void)
  {
   this.m_socket=::SocketCreate();
   if(this.m_socket==INVALID_HANDLE)
      return false;
   if(!::SocketConnect(this.m_socket,PYTHON_HOST,PYTHON_PORT,PYTHON_CONNECT_TIMEOUT_MS))
     {
      this.m_connect_error=::GetLastError();
      ::SocketClose(this.m_socket);
      this.m_socket=INVALID_HANDLE;
      return false;
     }
   this.m_state=PYTHON_STATE_READY;
   this.SendInit();
   this.SendWatch();
   this.SendPreTradeSymbolMonitor();
   return true;
  }
//+------------------------------------------------------------------+
void CPythonBridge::Launch(void)
  {
   if(this.m_launch_ms!=0 && ::GetTickCount64()-this.m_launch_ms<PYTHON_RELAUNCH_BLOCK_MS)
      return;
   string command=PYTHON_EXE+" \""+::TerminalInfoString(TERMINAL_DATA_PATH)+PYTHON_SCRIPT+"\"";
   uchar bytes[];
   ::StringToCharArray(command,bytes,0,WHOLE_ARRAY,CP_ACP);
   uint result=WinExec(bytes,PYTHON_WINDOW_SHOW);
   this.m_launch_ms=::GetTickCount64();
   if(result<=31)
      this.Log("Launch","WinExec failed, code "+(string)result+", command "+command);
   else
      this.Log("Launch","Python launched, "+command);
  }
//+------------------------------------------------------------------+
void CPythonBridge::Start(void)
  {
   if(this.TryConnect())
      return;
   this.Log("Start","Python not reachable, error "+(string)this.m_connect_error);
   this.Launch();
   this.m_state=PYTHON_STATE_CONNECTING;
   this.m_wait_start_ms=::GetTickCount64();
   this.m_last_try_ms=this.m_wait_start_ms;
  }
//+------------------------------------------------------------------+
void CPythonBridge::Reconfigure(void)
  {
   if(this.m_state!=PYTHON_STATE_READY)
      return;
   if(this.BuildInit()==this.m_last_init)
      return;   // nothing Python needs to know changed (the chart's own pair was added to the manager: it was in the init already)
   this.SendInit();
   this.SendWatch();
   this.SendPreTradeSymbolMonitor();
  }
//+------------------------------------------------------------------+
void CPythonBridge::Stop(const bool quit_python)
  {
   if(quit_python && this.m_state==PYTHON_STATE_READY)
      this.Send("{\"cmd\":\"quit\"}\n");
   if(this.m_socket!=INVALID_HANDLE)
      ::SocketClose(this.m_socket);
   this.m_socket=INVALID_HANDLE;
   this.m_state=PYTHON_STATE_DISCONNECTED;
  }
//+------------------------------------------------------------------+
void CPythonBridge::Poll(void)
  {
   ulong now=::GetTickCount64();
   if(this.m_state==PYTHON_STATE_CONNECTING)
     {
      if(now-this.m_last_try_ms<PYTHON_RETRY_MS)
         return;
      this.m_last_try_ms=now;
      if(this.TryConnect())
         return;
      if(now-this.m_wait_start_ms>PYTHON_WAIT_MS)
        {
         this.m_state=PYTHON_STATE_DISCONNECTED;
         this.Log("Poll","Python did not answer within "+(string)PYTHON_WAIT_MS+" ms, last error "+(string)this.m_connect_error);
        }
      return;
     }
   if(this.m_state!=PYTHON_STATE_READY)
      return;
   if(this.m_candle_mode && now-this.m_candle_ms>PYTHON_CANDLE_TIMEOUT_MS)
     {
      this.m_candle_mode=false;   // dropped: the lines after this are news again
      this.m_candle_waiting=0;
     }
   ulong p0=::GetMicrosecondCount();   //Print Debug
   uint n=::SocketIsReadable(this.m_socket);
   g_dbg_p_readable+=::GetMicrosecondCount()-p0;   //Print Debug
   if(n==0)
     {
      ulong p1=::GetMicrosecondCount();   //Print Debug
      bool connected=::SocketIsConnected(this.m_socket);   //Print Debug
      g_dbg_p_connected+=::GetMicrosecondCount()-p1; g_dbg_p_connected_n++;   //Print Debug
      if(!connected)
        {
         this.Stop(false);
         this.Log("Poll","Python connection lost, trying again");
         this.m_state=PYTHON_STATE_CONNECTING;   // Python restarts itself when its sources change: wait for it, do not launch a second one
         this.m_wait_start_ms=::GetTickCount64();
         this.m_last_try_ms=this.m_wait_start_ms;
        }
      return;
     }
   uchar buf[];
   int got=::SocketRead(this.m_socket,buf,n,0);
   if(got<0 || (got==0 && !::SocketIsConnected(this.m_socket)))
     {
      //--- Python closed the connection (it restarts when its sources change): wait for it again, then send the configuration and the chart again
      this.Log("Poll","Python connection lost (read "+(string)got+", error "+(string)::GetLastError()+"), trying again");
      this.Stop(false);
      this.m_rx="";   // half a line of the old connection is not the start of a new one
      this.m_state=PYTHON_STATE_CONNECTING;
      this.m_wait_start_ms=::GetTickCount64();
      this.m_last_try_ms=this.m_wait_start_ms;
      return;
     }
   if(got==0)
      return;
   this.m_rx+=::CharArrayToString(buf,0,got,CP_UTF8);
   int eol,pos=0;
   while((eol=::StringFind(this.m_rx,"\n",pos))>=0)
     {
      string line=::StringSubstr(this.m_rx,pos,eol-pos);
      pos=eol+1;
      if(::StringFind(line,"swing|")==0)
        {
         this.StoreSwing(line);
         continue;
        }
      if(::StringFind(line,"structure|")==0)
        {
         this.StoreStructure(line);
         continue;
        }
      if(::StringFind(line,"signal|")==0)
        {
         this.StoreSignal(line,this.m_signals,CANDLE_MARKER_SOURCE_INDICATOR);
         continue;
        }
      if(::StringFind(line,"lifecycle|")==0)
        {
         this.StoreLifecycle(line);
         continue;
        }
      if(::StringFind(line,"condition|")==0)
        {
         this.StoreCondition(line);
         continue;
        }
      if(::StringFind(line,"movement|")==0)
        {
         this.StoreMovement(line);
         continue;
        }
      if(::StringFind(line,"pre_trade_symbol_monitor|")==0)
        {
         this.StorePreTradeSymbolMonitor(line);
         continue;
        }
      if(::StringFind(line,"timeframe_info|")==0)
        {
         if(this.m_symbol_tf_manager!=NULL)
            this.m_symbol_tf_manager.SetAvailableTimeframes(::StringSubstr(line,15));
         continue;
        }
      if(::StringFind(line,"pattern_info|")==0)
        {
         //--- Every pattern and its candle count: the Candle Pattern table follows it
         if(this.m_PatternManager!=NULL && this.m_PatternManager.SetCatalog(::StringSubstr(line,13)))
            ::EventChartCustom(::ChartID(),(ushort)PATTERN_MANAGER_EVENT_CATALOG_CHANGED,0,0.0,"");
         continue;
        }
      if(::StringFind(line,"pattern|")==0)
        {
         this.StoreSignal(line,this.m_patterns,CANDLE_MARKER_SOURCE_CANDLE);
         continue;
        }
      if(::StringFind(line,"\"event\": \"pre_trade_symbol_monitor\"")>=0)
        {
         this.m_pre_trade_monitor_busy=false;   // the answer is complete: the next ask may go
         if(this.m_indicator_state_changed)
           {
            this.m_indicator_state_changed=false;
            ::EventChartCustom(::ChartID(),(ushort)INDICATOR_STATE_EVENT_CHANGED,0,0.0,"");   // the tables that show the indicators follow
           }
         continue;
        }
      if(::StringFind(line,"\"event\": \"candle_info\"")>=0)
        {
         if(this.m_candle_waiting>0)
            this.m_candle_waiting--;
         if(this.m_candle_waiting==0)
           {
            this.m_candle_mode=false;
            this.m_candle_done=true;   // the answer of the last ask is complete (an older one may have ended just before)
            this.Log("Poll","MY DEBUG candle info answered "+(string)(::GetTickCount64()-this.m_candle_ms)+" ms after the ask");   //Print Debug
           }
         continue;
        }
      this.Log("Poll","Python: "+line);
      if(::StringFind(line,"\"event\": \"watch\"")>=0)
        {
         this.m_watch_done=true;
         this.m_swings.Sort(SORT_BY_SWING_CODE);
         this.m_structures.Sort(SORT_BY_MARKET_STRUCTURE_CODE);
         this.m_signals.Sort();
         this.m_patterns.Sort();
         this.m_conditions.Sort();
         this.m_movements.Sort();
         ::EventChartCustom(::ChartID(),(ushort)MARKET_STORY_EVENT_CHANGED,0,0.0,"");   // the answer is complete: the table shows it
         this.Log("Poll",(string)this.m_swings.Total()+" swing(s) and "+(string)this.m_structures.Total()+" BOS/CHoCH held for "+
                  ::Symbol()+" "+TimeframeDescription((ENUM_TIMEFRAMES)::Period()));
         this.Log("Poll",(string)this.m_signals.Total()+" indicator signal(s) and "+(string)this.m_patterns.Total()+" candle pattern(s) held");
         this.m_SmartMoneySync.Sync();
         if(this.m_LifecycleCollection!=NULL && this.m_LifecycleSync!=NULL)
           {
            this.Log("Poll",(string)this.m_LifecycleCollection.Total()+" lifecycle event(s) held");
            this.m_LifecycleSync.Sync();
           }
        }
     }
   this.m_rx=::StringSubstr(this.m_rx,pos);   // keep the unfinished last line
  }
//+------------------------------------------------------------------+
#endif // __PYTHONBRIDGE_MQH__
