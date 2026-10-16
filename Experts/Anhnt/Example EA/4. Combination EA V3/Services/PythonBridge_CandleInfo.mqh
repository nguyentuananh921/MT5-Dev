//+------------------------------------------------------------------+
//|                                       PythonBridge_CandleInfo.mqh |
//| What Python found on one candle of the chart, for the popup      |
//+------------------------------------------------------------------+
#ifndef CPYTHONBRIDGE_CANDLEINFO_MQH
#define CPYTHONBRIDGE_CANDLEINFO_MQH
 #include "PythonBridge.mqh"
 void CandleInfoAddRow(string &row_label[],string &row_tf[],ENUM_SIGNAL_DIR &row_dir[],datetime &row_time[],int &row_source[],
                       const string label,const string tf,const ENUM_SIGNAL_DIR dir,const datetime time,const int source)
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
 string CandleInfoTf(const ENUM_TIMEFRAMES tf,const string chart_tf)
  {
   return (tf==PERIOD_CURRENT ? chart_tf : TimeframeDescription(tf));
  }
 //+------------------------------------------------------------------+
 //| The words of a leg between two Swings, in the candle window      |
 //+------------------------------------------------------------------+
 string MovementInfoText(const CMovementSeries *leg,const int digits)
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
 //+------------------------------------------------------------------+
 //| The words of a Market State / Phase change                       |
 //+------------------------------------------------------------------+
 string MarketConditionInfoText(const CMarketConditionSeries *mc)
  {
   string state=(mc.State()==MARKET_STATE_UPTREND ? "Uptrend" : mc.State()==MARKET_STATE_DOWNTREND ? "Downtrend" : mc.State()==MARKET_STATE_RANGE ? "Range" : "");
   string phase=(mc.Phase()==MARKET_PHASE_ACCUMULATION ? "Accumulation" : mc.Phase()==MARKET_PHASE_MARKUP ? "Markup" :
                 mc.Phase()==MARKET_PHASE_DISTRIBUTION ? "Distribution" : mc.Phase()==MARKET_PHASE_MARKDOWN ? "Markdown" : "");
   return "Market became "+state+(phase!="" ? " ("+phase+")" : "");
  }
 //+------------------------------------------------------------------+
 //| The words of a trendline / zone event: what it is and what it did|
 //+------------------------------------------------------------------+
 string LifecycleInfoText(const CLifecycleSeries *lc,const int digits)
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
 //| Indicator flips, candle patterns, Swings, BOS and CHoCH of the   |
 //| chart's Symbol, on EVERY TF held, inside [bar_time, next bar), ALL of them:  |
 //| the Show Marker check boxes only decide which markers are drawn, |
 //| not what the popup tells. Time ascending. row_source: 0 =        |
 //| Indicator, 1 = Pattern, 2 = Swing, 3 = Market Structure,         |
 //| 4 = Trendline, 5 = Zone, 6 = Market State change, 7 = leg       |
 //| Returns the rows                                                 |
 //+------------------------------------------------------------------+
 int CPythonBridge::GetCandleInfo(const datetime bar_time,string &row_label[],string &row_tf[],
                                  ENUM_SIGNAL_DIR &row_dir[],datetime &row_time[],int &row_source[])
  {
   ::ArrayResize(row_label,0);
   ::ArrayResize(row_tf,0);
   ::ArrayResize(row_dir,0);
   ::ArrayResize(row_time,0);
   ::ArrayResize(row_source,0);
   datetime next_bar_time=bar_time+::PeriodSeconds();
   string chart_tf=TimeframeDescription((ENUM_TIMEFRAMES)::Period());   // for what does not know its TF
   string sym=::Symbol();
   int digits=(int)::SymbolInfoInteger(sym,SYMBOL_DIGITS);
   //--- Indicator flips
   for(int i=0;i<this.m_signals.Total();i++)
     {
      CIndicatorSignalSeries *s=this.m_signals.At(i);
      if(s==NULL || s.Time()<bar_time || s.Time()>=next_bar_time)
         continue;
      CandleInfoAddRow(row_label,row_tf,row_dir,row_time,row_source,s.Label(),CandleInfoTf(s.Timeframe(),chart_tf),(s.IsBuy() ? SIGNAL_BUY : SIGNAL_SELL),s.Time(),0);
     }
   //--- Candle patterns
   for(int i=0;i<this.m_patterns.Total();i++)
     {
      CIndicatorSignalSeries *p=this.m_patterns.At(i);
      if(p==NULL || p.Time()<bar_time || p.Time()>=next_bar_time)
         continue;
      CPatternSetting *setting=(this.m_PatternManager!=NULL) ? this.m_PatternManager.Find(p.Label()) : NULL;
      uint candles=(setting!=NULL) ? setting.Candles() : 0;
      string name=((candles>0) ? "["+::IntegerToString(candles)+"B] " : "")+p.Label();
      CandleInfoAddRow(row_label,row_tf,row_dir,row_time,row_source,name,CandleInfoTf(p.Timeframe(),chart_tf),(p.IsNeutral() ? SIGNAL_NONE : (p.IsBuy() ? SIGNAL_BUY : SIGNAL_SELL)),p.Time(),1);
     }
   //--- Swings whose pivot bar is in the span
   for(int i=0;i<this.m_swings.Total();i++)
     {
      CBarSwingSeries *sw=this.m_swings.At(i);
      if(sw==NULL || sw.Time()<bar_time || sw.Time()>=next_bar_time)
         continue;
      string name=SwingTypeDescription(sw.TypeSwing())+" ("+SwingStructureDescription(sw.Structure())+") "+::DoubleToString(sw.Price(),digits);
      CandleInfoAddRow(row_label,row_tf,row_dir,row_time,row_source,name,CandleInfoTf(sw.Timeframe(),chart_tf),(sw.TypeSwing()==SWING_TYPE_LOW ? SIGNAL_BUY : SIGNAL_SELL),sw.Time(),2);
     }
   //--- BOS / CHoCH whose break candle is in the span
   for(int i=0;i<this.m_structures.Total();i++)
     {
      CMarketStructureSeries *ms=this.m_structures.At(i);
      if(ms==NULL || ms.Time()<bar_time || ms.Time()>=next_bar_time)
         continue;
      string name=(ms.TypeStructure()==MARKET_STRUCTURE_BOS ? "BOS" : "CHoCH")+(ms.Direction()==SIGNAL_BUY ? " (up) " : " (down) ")+::DoubleToString(ms.Level(),digits);
      //--- the level that was broken is the weak one, the swing the move started from is the strong one (a break up: weak high, strong low)
      name+=" | weak "+(ms.Direction()==SIGNAL_BUY ? "high " : "low ")+::DoubleToString(ms.Level(),digits);
      if(ms.StrongTime()>0)
         name+=", strong "+(ms.Direction()==SIGNAL_BUY ? "low " : "high ")+::DoubleToString(ms.StrongPrice(),digits);
      CandleInfoAddRow(row_label,row_tf,row_dir,row_time,row_source,name,CandleInfoTf(ms.Timeframe(),chart_tf),ms.Direction(),ms.Time(),3);
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
         string text=LifecycleInfoText(lc,digits),tf_text=CandleInfoTf(lc.Timeframe(),chart_tf);
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
         CandleInfoAddRow(row_label,row_tf,row_dir,row_time,row_source,text,tf_text,lc.Direction(),lc.Time(),(lc.Kind()==LIFECYCLE_OBJECT_MOMENTUM ? 8 : (lc.Kind()==LIFECYCLE_OBJECT_ZONE || lc.Kind()==LIFECYCLE_OBJECT_SUPPLYDEMAND || lc.Kind()==LIFECYCLE_OBJECT_FVG) ? 5 : 4));
        }
     }
   //--- The legs that end on this candle (a leg is final a swing later, but it ends where its swing is), every TF
   for(int i=0;i<this.m_movements.Total();i++)
     {
      CMovementSeries *leg=this.m_movements.At(i);
      if(leg==NULL || leg.EndTime()<bar_time || leg.EndTime()>=next_bar_time)
         continue;
      CandleInfoAddRow(row_label,row_tf,row_dir,row_time,row_source,MovementInfoText(leg,digits),CandleInfoTf(leg.Timeframe(),chart_tf),
                       leg.Direction(),leg.EndTime(),7);
     }
   //--- Market State / Phase changes on this candle, every TF
   for(int i=0;i<this.m_conditions.Total();i++)
     {
      CMarketConditionSeries *mc=this.m_conditions.At(i);
      if(mc==NULL || mc.Time()<bar_time || mc.Time()>=next_bar_time)
         continue;
      CandleInfoAddRow(row_label,row_tf,row_dir,row_time,row_source,MarketConditionInfoText(mc),CandleInfoTf(mc.Timeframe(),chart_tf),
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
#endif // CPYTHONBRIDGE_CANDLEINFO_MQH
