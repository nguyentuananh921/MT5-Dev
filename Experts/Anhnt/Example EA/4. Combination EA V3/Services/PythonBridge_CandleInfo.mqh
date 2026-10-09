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
 //+------------------------------------------------------------------+
 //| Indicator flips, candle patterns, Swings, BOS and CHoCH of the   |
 //| chart's Symbol and TF inside [bar_time, next bar), gated by the  |
 //| Buy/Sell settings. Time ascending. row_source: 0 = Indicator,    |
 //| 1 = Pattern, 2 = Swing, 3 = Market Structure. Returns the rows   |
 //+------------------------------------------------------------------+
 int CPythonBridge::GetCandleInfo(const datetime bar_time,string &row_label[],string &row_tf[],
                                  ENUM_SIGNAL_DIR &row_dir[],datetime &row_time[],int &row_source[])
  {
   ::ArrayResize(row_label,0);
   ::ArrayResize(row_tf,0);
   ::ArrayResize(row_dir,0);
   ::ArrayResize(row_time,0);
   ::ArrayResize(row_source,0);
   if(this.m_symbol_tf_manager==NULL || this.m_SmartMoneySetting==NULL)
      return 0;
   datetime next_bar_time=bar_time+::PeriodSeconds();
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::Period();
   string tf_text=TimeframeDescription(tf);
   string sym=::Symbol();
   int digits=(int)::SymbolInfoInteger(sym,SYMBOL_DIGITS);
   CSymbolTFSetting *pair=this.m_symbol_tf_manager.FindByIdentity(sym,tf);
   bool pair_buy=(pair!=NULL && pair.BuySignal());
   bool pair_sell=(pair!=NULL && pair.SellSignal());
   //--- Indicator flips
   for(int i=0;i<this.m_signals.Total();i++)
     {
      CIndicatorSignalSeries *s=this.m_signals.At(i);
      if(s==NULL || s.Time()<bar_time || s.Time()>=next_bar_time)
         continue;
      if(s.IsBuy() ? !pair_buy : !pair_sell)
         continue;
      CandleInfoAddRow(row_label,row_tf,row_dir,row_time,row_source,s.Label(),tf_text,(s.IsBuy() ? SIGNAL_BUY : SIGNAL_SELL),s.Time(),0);
     }
   //--- Candle patterns
   for(int i=0;i<this.m_patterns.Total();i++)
     {
      CIndicatorSignalSeries *p=this.m_patterns.At(i);
      if(p==NULL || p.Time()<bar_time || p.Time()>=next_bar_time)
         continue;
      if(!p.IsNeutral() && (p.IsBuy() ? !pair_buy : !pair_sell))
         continue;
      if(!p.IsNeutral() && this.m_PatternManager!=NULL && !(p.IsBuy() ? this.m_PatternManager.PatternSignalBuy(p.Label()) : this.m_PatternManager.PatternSignalSell(p.Label())))
         continue;
      CPatternSetting *setting=(this.m_PatternManager!=NULL) ? this.m_PatternManager.Find(p.Label()) : NULL;
      uint candles=(setting!=NULL) ? setting.Candles() : 0;
      string name=((candles>0) ? "["+::IntegerToString(candles)+"B] " : "")+p.Label();
      CandleInfoAddRow(row_label,row_tf,row_dir,row_time,row_source,name,tf_text,(p.IsNeutral() ? SIGNAL_NONE : (p.IsBuy() ? SIGNAL_BUY : SIGNAL_SELL)),p.Time(),1);
     }
   //--- Swings whose pivot bar is in the span
   for(int i=0;i<this.m_swings.Total();i++)
     {
      CBarSwingSeries *sw=this.m_swings.At(i);
      if(sw==NULL || sw.Time()<bar_time || sw.Time()>=next_bar_time)
         continue;
      if(!this.m_SmartMoneySetting.SignalShow(sw.TypeSwing()))
         continue;
      string name=SwingTypeDescription(sw.TypeSwing())+" ("+SwingStructureDescription(sw.Structure())+") "+::DoubleToString(sw.Price(),digits);
      CandleInfoAddRow(row_label,row_tf,row_dir,row_time,row_source,name,tf_text,(sw.TypeSwing()==SWING_TYPE_LOW ? SIGNAL_BUY : SIGNAL_SELL),sw.Time(),2);
     }
   //--- BOS / CHoCH whose break candle is in the span
   for(int i=0;i<this.m_structures.Total();i++)
     {
      CMarketStructureSeries *ms=this.m_structures.At(i);
      if(ms==NULL || ms.Time()<bar_time || ms.Time()>=next_bar_time)
         continue;
      if(!this.m_SmartMoneySetting.SignalShow(ms.TypeStructure()))
         continue;
      string name=(ms.TypeStructure()==MARKET_STRUCTURE_BOS ? "BOS" : "CHoCH")+(ms.Direction()==SIGNAL_BUY ? " (up) " : " (down) ")+::DoubleToString(ms.Level(),digits);
      CandleInfoAddRow(row_label,row_tf,row_dir,row_time,row_source,name,tf_text,ms.Direction(),ms.Time(),3);
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
