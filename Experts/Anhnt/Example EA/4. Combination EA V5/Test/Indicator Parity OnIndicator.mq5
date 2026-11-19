#property copyright "Copyright 2026, Anhnt"
#property script_show_inputs
//--- Writes the buffers of MT5 indicators made on another indicator (applied = its handle), closed bars, oldest first, to
//--- MQL5\Files\<script name>\parity_<tag>.csv (same format as V3 Old\Test\Indicator Parity.mq5): the source and the average side by side
 input int InpBars      = 3000;   // closed bars exported
 input int InpRsiPeriod = 14;
 input int InpMaPeriod  = 9;
 input int InpVolMa     = 20;

 bool Export(const string tag,const int source,const int average,const string params)
  {
   if(source==INVALID_HANDLE || average==INVALID_HANDLE)
     {
      ::Print(__FUNCTION__,": ",tag," handle failed, error ",::GetLastError());
      return false;
     }
   string symbol=::Symbol();
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::Period();
   for(int wait=0;wait<100 && (::BarsCalculated(source)<InpBars+1 || ::BarsCalculated(average)<InpBars+1);wait++)
      ::Sleep(100);
   datetime times[];
   double src[],avg[];
   if(::CopyTime(symbol,tf,1,InpBars,times)!=InpBars || ::CopyBuffer(source,0,1,InpBars,src)!=InpBars || ::CopyBuffer(average,0,1,InpBars,avg)!=InpBars)
     {
      ::Print(__FUNCTION__,": ",tag," copy failed, error ",::GetLastError());
      return false;
     }
   string file=::MQLInfoString(MQL_PROGRAM_NAME)+"\\parity_"+tag+".csv";
   int h=::FileOpen(file,FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(h==INVALID_HANDLE)
     {
      ::Print(__FUNCTION__,": cannot open ",file,", error ",::GetLastError());
      return false;
     }
   string tf_text=::EnumToString(tf);
   ::StringReplace(tf_text,"PERIOD_","");
   ::FileWriteString(h,"#tag="+tag+";symbol="+symbol+";tf="+tf_text+";"+params+"\n");
   ::FileWriteString(h,"time,source,average\n");
   for(int i=0;i<InpBars;i++)
      ::FileWriteString(h,(string)(long)times[i]+","+(src[i]==EMPTY_VALUE ? "nan" : ::DoubleToString(src[i],10))+","+(avg[i]==EMPTY_VALUE ? "nan" : ::DoubleToString(avg[i],10))+"\n");
   ::FileClose(h);
   ::Print(__FUNCTION__,": ",tag," ",InpBars," bars written to ",file);
   return true;
  }

 void OnStart(void)
  {
   string symbol=::Symbol();
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::Period();
   int rsi=::iRSI(symbol,tf,InpRsiPeriod,PRICE_CLOSE);
   int volumes=::iVolumes(symbol,tf,VOLUME_TICK);
   Export("RSI_EMA",rsi,::iMA(symbol,tf,InpMaPeriod,0,MODE_EMA,rsi),"source=RSI;rsi_period="+(string)InpRsiPeriod+";period="+(string)InpMaPeriod+";method=EMA");
   Export("RSI_SMA",rsi,::iMA(symbol,tf,InpMaPeriod,0,MODE_SMA,rsi),"source=RSI;rsi_period="+(string)InpRsiPeriod+";period="+(string)InpMaPeriod+";method=SMA");
   Export("VOLUMES_SMA",volumes,::iMA(symbol,tf,InpVolMa,0,MODE_SMA,volumes),"source=VOLUMES;period="+(string)InpVolMa+";method=SMA");
   //--- the other averages on the RSI (the template text Python reads is in params)
   Export("RSI_AMA",rsi,::iAMA(symbol,tf,10,2,30,0,rsi),"source=RSI;type=AMA;params=10,2,30,0");
   Export("RSI_DEMA",rsi,::iDEMA(symbol,tf,14,0,rsi),"source=RSI;type=DEMA;params=14,0");
   Export("RSI_TEMA",rsi,::iTEMA(symbol,tf,14,0,rsi),"source=RSI;type=TEMA;params=14,0");
   Export("RSI_VIDYA",rsi,::iVIDyA(symbol,tf,9,12,0,rsi),"source=RSI;type=VIDYA;params=9,12,0");
   Export("RSI_FRAMA",rsi,::iFrAMA(symbol,tf,14,0,rsi),"source=RSI;type=FRAMA;params=14,0");
  }
