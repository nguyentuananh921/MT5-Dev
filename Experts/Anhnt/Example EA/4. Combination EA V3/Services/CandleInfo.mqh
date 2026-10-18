//+------------------------------------------------------------------+
//|                                                   CandleInfo.mqh |
//| What was found on one candle of the chart, for the popup         |
//+------------------------------------------------------------------+
#ifndef __CANDLEINFO_MQH__
#define __CANDLEINFO_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
#ifndef CCANDLEINFO_MQH_DECLARATION
#define CCANDLEINFO_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Reads what Python sent (the lists of the bridge, the lifecycle   |
 //| collection) and gives the rows of the popup of one candle        |
 //+------------------------------------------------------------------+
 class CCandleInfo : public CBaseObj
  {
   private:
     CArrayObj                 *m_signals;                   // CPythonBridge owns
     CArrayObj                 *m_patterns;
     CArrayObj                 *m_swings;
     CArrayObj                 *m_structures;
     CArrayObj                 *m_movements;
     CArrayObj                 *m_conditions;
     CLifecycleCollection      *m_LifecycleCollection;       // EA owns
     CPatternManager           *m_PatternManager;            // EA owns
     void                      AddRow(string &row_label[],string &row_tf[],ENUM_SIGNAL_DIR &row_dir[],datetime &row_time[],int &row_source[],
                                      const string label,const string tf,const ENUM_SIGNAL_DIR dir,const datetime time,const int source) const;
     string                    Tf(const ENUM_TIMEFRAMES tf,const string chart_tf) const;
     string                    MovementText(const CMovementSeries *leg,const int digits) const;
     string                    MarketConditionText(const CMarketConditionSeries *mc) const;
     string                    LifecycleText(const CLifecycleSeries *lc,const int digits) const;
   public:
     void                      OnInitEvent(CArrayObj *signals,CArrayObj *patterns,CArrayObj *swings,CArrayObj *structures,CArrayObj *movements,CArrayObj *conditions,
                                           CLifecycleCollection *lifecycle,CPatternManager *patterns_setting);
   //--- Every row of the candle that starts at bar_time, on every TF held, time ascending; row_source: 0 = Indicator, 1 = Pattern, 2 = Swing,
   //--- 3 = Market Structure, 4 = Trendline, 5 = Zone, 6 = Market State change, 7 = leg, 8 = Momentum candle. Returns the rows
     int                       GetRows(const datetime bar_time,string &row_label[],string &row_tf[],ENUM_SIGNAL_DIR &row_dir[],datetime &row_time[],int &row_source[]) const;
                               CCandleInfo(void);
  };
#endif // CCANDLEINFO_MQH_DECLARATION
#ifndef CCANDLEINFO_MQH_IMPLEMENTATION
#define CCANDLEINFO_MQH_IMPLEMENTATION
 CCandleInfo::CCandleInfo(void) : m_signals(NULL),m_patterns(NULL),m_swings(NULL),m_structures(NULL),m_movements(NULL),m_conditions(NULL),
                                  m_LifecycleCollection(NULL),m_PatternManager(NULL)
  {
  }
 void CCandleInfo::OnInitEvent(CArrayObj *signals,CArrayObj *patterns,CArrayObj *swings,CArrayObj *structures,CArrayObj *movements,CArrayObj *conditions,
                               CLifecycleCollection *lifecycle,CPatternManager *patterns_setting)
  {
   this.m_signals=signals;
   this.m_patterns=patterns;
   this.m_swings=swings;
   this.m_structures=structures;
   this.m_movements=movements;
   this.m_conditions=conditions;
   this.m_LifecycleCollection=lifecycle;
   this.m_PatternManager=patterns_setting;
  }
 void CCandleInfo::AddRow(string &row_label[],string &row_tf[],ENUM_SIGNAL_DIR &row_dir[],datetime &row_time[],int &row_source[],
                          const string label,const string tf,const ENUM_SIGNAL_DIR dir,const datetime time,const int source) const
  {
   int n=::ArraySize(row_label);
   ::ArrayResize(row_label,n+1);
   ::ArrayResize(row_tf,n+1);
   ::ArrayResize(row_dir,n+1);
   ::ArrayResize(row_time,n+1);
   ::ArrayResize(row_source,n+1);
   row_label[n]=label;
   row_tf[n]=tf;
   row_dir[n]=dir;
   row_time[n]=time;
   row_source[n]=source;
  }
 //--- The TF of a row: its own, the chart's when it does not know it
 string CCandleInfo::Tf(const ENUM_TIMEFRAMES tf,const string chart_tf) const
  {
   return (tf==PERIOD_CURRENT ? chart_tf : TimeframeDescription(tf));
  }
 //--- The words of a leg between two Swings
 string CCandleInfo::MovementText(const CMovementSeries *leg,const int digits) const
  {
   string what=(leg.Move()==MOVE_TYPE_PULLBACK ? "Pullback " : leg.Move()==MOVE_TYPE_IMPULSE ? "Impulse " : "Leg ")+(leg.Direction()==SIGNAL_BUY ? "up " : "down ");
   string text=what+::DoubleToString(leg.StartPrice(),digits)+" -> "+::DoubleToString(leg.EndPrice(),digits)+", "+::DoubleToString(leg.LengthATR(),1)+" ATR in "+
               (string)leg.Bars()+" bars";
   if(leg.Retracement()>0.0)
      text+=", "+::DoubleToString(leg.Retracement(),2)+" of the leg before";
   if(leg.Move()==MOVE_TYPE_PULLBACK)
      text+=" ("+leg.DepthText()+")";
   return text;
  }
 //--- The words of a Market State / Phase change
 string CCandleInfo::MarketConditionText(const CMarketConditionSeries *mc) const
  {
   string state=(mc.State()==MARKET_STATE_UPTREND ? "Uptrend" : mc.State()==MARKET_STATE_DOWNTREND ? "Downtrend" : mc.State()==MARKET_STATE_RANGE ? "Range" : "");
   string phase=(mc.Phase()==MARKET_PHASE_ACCUMULATION ? "Accumulation" : mc.Phase()==MARKET_PHASE_MARKUP ? "Markup" :
                 mc.Phase()==MARKET_PHASE_DISTRIBUTION ? "Distribution" : mc.Phase()==MARKET_PHASE_MARKDOWN ? "Markdown" : "");
   return "Market became "+state+(phase!="" ? " ("+phase+")" : "");
  }
 //--- The words of a trendline / zone event: what it is and what it did
 string CCandleInfo::LifecycleText(const CLifecycleSeries *lc,const int digits) const
  {
   bool zone=(lc.Kind()==LIFECYCLE_OBJECT_ZONE || lc.Kind()==LIFECYCLE_OBJECT_SUPPLYDEMAND || lc.Kind()==LIFECYCLE_OBJECT_FVG);
   string what=(lc.Kind()==LIFECYCLE_OBJECT_MOMENTUM ? (lc.Direction()==SIGNAL_BUY ? "Buy" : "Sell")+" momentum candle" :
                lc.Kind()==LIFECYCLE_OBJECT_SUPPLYDEMAND ? (lc.Direction()==SIGNAL_BUY ? "Demand" : "Supply")+" zone " :
                lc.Kind()==LIFECYCLE_OBJECT_FVG ? (lc.Direction()==SIGNAL_BUY ? "Bullish" : "Bearish")+" FVG " :
                (lc.Direction()==SIGNAL_BUY ? "Support" : "Resistance")+(zone ? " zone " : " line "));
   string event="";
   switch(lc.Event())
     {
      case LIFECYCLE_EVENT_BORN:        event="born";        break;
      case LIFECYCLE_EVENT_MODIFIED:    event="modified";    break;
      case LIFECYCLE_EVENT_TOUCHED:     event="touched";     break;
      case LIFECYCLE_EVENT_BOUNCED:     event="bounced";     break;
      case LIFECYCLE_EVENT_BROKEN:      event="broken";      break;
      case LIFECYCLE_EVENT_RESURRECTED: event="resurrected"; break;
      case LIFECYCLE_EVENT_SUPERSEDED:  event="superseded";  break;
      case LIFECYCLE_EVENT_CONFIRMED:   event="confirmed by a swing"; break;
      case LIFECYCLE_EVENT_DEAD:        event=(lc.DeadReason()==LIFECYCLE_DEAD_EXPIRED ? "died (expired)" :
                                               lc.DeadReason()==LIFECYCLE_DEAD_OBSOLETE ? "died (out of range)" : lc.DeadReason()==LIFECYCLE_DEAD_BROKEN ? "died (broken)" : lc.DeadReason()==LIFECYCLE_DEAD_REPLACED ? "replaced" : "died"); break;
      default:                          event="";            break;
     }
   if(lc.Kind()==LIFECYCLE_OBJECT_MOMENTUM)
      return what;   // a momentum candle is only born: the words say it all
   string where=(zone ? " "+::DoubleToString(lc.Bottom(),digits)+" - "+::DoubleToString(lc.Top(),digits) : "");
   return what+event+where;
  }
 //+------------------------------------------------------------------+
 //| Indicator flips, candle patterns, Swings, BOS and CHoCH, the     |
 //| trendline and zone events, the legs and the Market State changes |
 //| of the chart's Symbol inside [bar_time, next bar), ALL of them:  |
 //| the Show boxes of the Smart Money tab only decide which markers  |
 //| are drawn, not what the popup tells                              |
 //+------------------------------------------------------------------+
 int CCandleInfo::GetRows(const datetime bar_time,string &row_label[],string &row_tf[],ENUM_SIGNAL_DIR &row_dir[],datetime &row_time[],int &row_source[]) const
  {
   ::ArrayResize(row_label,0);
   ::ArrayResize(row_tf,0);
   ::ArrayResize(row_dir,0);
   ::ArrayResize(row_time,0);
   ::ArrayResize(row_source,0);
   datetime next_bar_time=bar_time+::PeriodSeconds();
   string chart_tf=TimeframeDescription((ENUM_TIMEFRAMES)::Period());   // for what does not know its TF
   int digits=(int)::SymbolInfoInteger(::Symbol(),SYMBOL_DIGITS);
   //--- Indicator flips
   for(int i=0;this.m_signals!=NULL && i<this.m_signals.Total();i++)
     {
      CIndicatorSignalSeries *s=this.m_signals.At(i);
      if(s==NULL || s.Time()<bar_time || s.Time()>=next_bar_time)
         continue;
      this.AddRow(row_label,row_tf,row_dir,row_time,row_source,s.Label(),this.Tf(s.Timeframe(),chart_tf),(s.IsBuy() ? SIGNAL_BUY : SIGNAL_SELL),s.Time(),0);
     }
   //--- Candle patterns
   for(int i=0;this.m_patterns!=NULL && i<this.m_patterns.Total();i++)
     {
      CIndicatorSignalSeries *p=this.m_patterns.At(i);
      if(p==NULL || p.Time()<bar_time || p.Time()>=next_bar_time)
         continue;
      CPatternSetting *setting=(this.m_PatternManager!=NULL) ? this.m_PatternManager.Find(p.Label()) : NULL;
      uint candles=(setting!=NULL) ? setting.Candles() : 0;
      string name=((candles>0) ? "["+::IntegerToString(candles)+"B] " : "")+p.Label();
      this.AddRow(row_label,row_tf,row_dir,row_time,row_source,name,this.Tf(p.Timeframe(),chart_tf),(p.IsNeutral() ? SIGNAL_NONE : (p.IsBuy() ? SIGNAL_BUY : SIGNAL_SELL)),p.Time(),1);
     }
   //--- Swings whose pivot bar is in the span
   for(int i=0;this.m_swings!=NULL && i<this.m_swings.Total();i++)
     {
      CBarSwingSeries *sw=this.m_swings.At(i);
      if(sw==NULL || sw.Time()<bar_time || sw.Time()>=next_bar_time)
         continue;
      string name=SwingTypeDescription(sw.TypeSwing())+" ("+SwingStructureDescription(sw.Structure())+") "+::DoubleToString(sw.Price(),digits);
      this.AddRow(row_label,row_tf,row_dir,row_time,row_source,name,this.Tf(sw.Timeframe(),chart_tf),(sw.TypeSwing()==SWING_TYPE_LOW ? SIGNAL_BUY : SIGNAL_SELL),sw.Time(),2);
     }
   //--- BOS / CHoCH whose break candle is in the span
   for(int i=0;this.m_structures!=NULL && i<this.m_structures.Total();i++)
     {
      CMarketStructureSeries *ms=this.m_structures.At(i);
      if(ms==NULL || ms.Time()<bar_time || ms.Time()>=next_bar_time)
         continue;
      string name=(ms.TypeStructure()==MARKET_STRUCTURE_BOS ? "BOS" : "CHoCH")+(ms.Direction()==SIGNAL_BUY ? " (up) " : " (down) ")+::DoubleToString(ms.Level(),digits);
      //--- the level that was broken is the weak one, the swing the move started from is the strong one (a break up: weak high, strong low)
      name+=" | weak "+(ms.Direction()==SIGNAL_BUY ? "high " : "low ")+::DoubleToString(ms.Level(),digits);
      if(ms.StrongTime()>0)
         name+=", strong "+(ms.Direction()==SIGNAL_BUY ? "low " : "high ")+::DoubleToString(ms.StrongPrice(),digits);
      this.AddRow(row_label,row_tf,row_dir,row_time,row_source,name,this.Tf(ms.Timeframe(),chart_tf),ms.Direction(),ms.Time(),3);
     }
   //--- Trendline and zone events on this candle: Python decided them (Born, Touched, ... Dead)
   if(this.m_LifecycleCollection!=NULL)
     {
      CArrayObj *events=this.m_LifecycleCollection.GetList();
      string same_text[],same_tf[];   // the same words on the same TF are one row with a count: many lines touched at once are one line of the table
      int    same_row[],same_count[];
      for(int i=0;i<events.Total();i++)
        {
         CLifecycleSeries *lc=events.At(i);
         if(lc==NULL || lc.Time()<bar_time || lc.Time()>=next_bar_time)
            continue;
         string text=this.LifecycleText(lc,digits),tf_text=this.Tf(lc.Timeframe(),chart_tf);
         int found=-1;
         for(int k=0;k<::ArraySize(same_text) && found<0;k++)
            if(same_text[k]==text && same_tf[k]==tf_text)
               found=k;
         if(found>=0)
           {
            same_count[found]++;
            row_label[same_row[found]]=text+" x"+(string)same_count[found];
            continue;
           }
         int k=::ArraySize(same_text);
         ::ArrayResize(same_text,k+1);  ::ArrayResize(same_tf,k+1);
         ::ArrayResize(same_row,k+1);   ::ArrayResize(same_count,k+1);
         same_text[k]=text;  same_tf[k]=tf_text;  same_count[k]=1;  same_row[k]=::ArraySize(row_label);
         this.AddRow(row_label,row_tf,row_dir,row_time,row_source,text,tf_text,lc.Direction(),lc.Time(),(lc.Kind()==LIFECYCLE_OBJECT_MOMENTUM ? 8 : (lc.Kind()==LIFECYCLE_OBJECT_ZONE || lc.Kind()==LIFECYCLE_OBJECT_SUPPLYDEMAND || lc.Kind()==LIFECYCLE_OBJECT_FVG) ? 5 : 4));
        }
     }
   //--- The legs that end on this candle (a leg is final a swing later, but it ends where its swing is), every TF
   for(int i=0;this.m_movements!=NULL && i<this.m_movements.Total();i++)
     {
      CMovementSeries *leg=this.m_movements.At(i);
      if(leg==NULL || leg.EndTime()<bar_time || leg.EndTime()>=next_bar_time)
         continue;
      this.AddRow(row_label,row_tf,row_dir,row_time,row_source,this.MovementText(leg,digits),this.Tf(leg.Timeframe(),chart_tf),leg.Direction(),leg.EndTime(),7);
     }
   //--- Market State / Phase changes on this candle, every TF
   for(int i=0;this.m_conditions!=NULL && i<this.m_conditions.Total();i++)
     {
      CMarketConditionSeries *mc=this.m_conditions.At(i);
      if(mc==NULL || mc.Time()<bar_time || mc.Time()>=next_bar_time)
         continue;
      this.AddRow(row_label,row_tf,row_dir,row_time,row_source,this.MarketConditionText(mc),this.Tf(mc.Timeframe(),chart_tf),
                  (mc.State()==MARKET_STATE_UPTREND ? SIGNAL_BUY : mc.State()==MARKET_STATE_DOWNTREND ? SIGNAL_SELL : SIGNAL_NONE),mc.Time(),6);
     }
   //--- Time ascending
   int count=::ArraySize(row_label);
   for(int a=0;a<count-1;a++)
      for(int b=a+1;b<count;b++)
        {
         if(row_time[b]>=row_time[a])
            continue;
         string          lbl_=row_label[a];  row_label[a]=row_label[b];   row_label[b]=lbl_;
         string          tf_=row_tf[a];      row_tf[a]=row_tf[b];         row_tf[b]=tf_;
         ENUM_SIGNAL_DIR d_=row_dir[a];      row_dir[a]=row_dir[b];       row_dir[b]=d_;
         datetime        tm_=row_time[a];    row_time[a]=row_time[b];     row_time[b]=tm_;
         int             src_=row_source[a]; row_source[a]=row_source[b]; row_source[b]=src_;
        }
   return count;
  }
#endif // CCANDLEINFO_MQH_IMPLEMENTATION
#endif // __CANDLEINFO_MQH__
