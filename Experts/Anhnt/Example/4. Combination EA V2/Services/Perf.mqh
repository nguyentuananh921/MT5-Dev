//+------------------------------------------------------------------+
//|                                                         Perf.mqh |
//| Temporary profiler: time spent per named section of OnTick /     |
//| OnTimer / OnChartEvent, summed over a window and written to      |
//| Files\<program>\Debug_CPerf.txt. Every use is marked              |
//| //Print Debug so it can be removed with one search               |
//+------------------------------------------------------------------+
#ifndef __PERF_MQH__
#define __PERF_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Services\Message\Message.mqh>
 #define PERF_WINDOW_US   5000000   // one summary every 5 seconds
 #define PERF_BEGIN       ulong perf_t0=::GetMicrosecondCount();
 #define PERF_LAP(name)   g_perf.Lap(name,perf_t0);
 class CPerf
  {
   private:
     string            m_name[];
     ulong             m_calls[];
     ulong             m_total_us[];
     ulong             m_max_us[];
     ulong             m_window_start;
     int               Find(const string name);
   public:
     void              Add(const string name,const ulong us);
   //--- us since t0 goes to the section, t0 is moved to now (the next section starts here)
     void              Lap(const string name,ulong &t0);
   //--- Window over: one line per section (most expensive first), then everything restarts
     void              Dump(const string folder);
                       CPerf(void) : m_window_start(0) {}
  };
 int CPerf::Find(const string name)
  {
   for(int i=0; i<::ArraySize(this.m_name); i++)
      if(this.m_name[i]==name)
         return i;
   int n=::ArraySize(this.m_name);
   ::ArrayResize(this.m_name,n+1);
   ::ArrayResize(this.m_calls,n+1);
   ::ArrayResize(this.m_total_us,n+1);
   ::ArrayResize(this.m_max_us,n+1);
   this.m_name[n]=name;
   this.m_calls[n]=0;
   this.m_total_us[n]=0;
   this.m_max_us[n]=0;
   return n;
  }
 void CPerf::Add(const string name,const ulong us)
  {
   int i=this.Find(name);
   this.m_calls[i]++;
   this.m_total_us[i]+=us;
   if(us>this.m_max_us[i])
      this.m_max_us[i]=us;
  }
 void CPerf::Lap(const string name,ulong &t0)
  {
   ulong t1=::GetMicrosecondCount();
   this.Add(name,t1-t0);
   t0=t1;
  }
 void CPerf::Dump(const string folder)
  {
   ulong now=::GetMicrosecondCount();
   if(this.m_window_start==0)
     {
      this.m_window_start=now;
      return;
     }
   if(now-this.m_window_start<PERF_WINDOW_US)
      return;
   int n=::ArraySize(this.m_name);
   bool used[];
   ::ArrayResize(used,n);
   ::ArrayInitialize(used,false);
   CMessage::ToFile(folder,"CPerf","Dump","---- window "+::DoubleToString((now-this.m_window_start)/1000000.0,1)+" s ----");
   for(int k=0; k<n; k++)
     {
      int best=-1;
      for(int i=0; i<n; i++)
         if(!used[i] && this.m_calls[i]>0 && (best<0 || this.m_total_us[i]>this.m_total_us[best]))
            best=i;
      if(best<0)
         break;
      used[best]=true;
      CMessage::ToFile(folder,"CPerf","Dump",this.m_name[best]+"  calls="+(string)this.m_calls[best]+
                       "  total="+::DoubleToString(this.m_total_us[best]/1000.0,1)+"ms  avg="+
                       ::DoubleToString((double)this.m_total_us[best]/(double)this.m_calls[best],0)+"us  max="+(string)this.m_max_us[best]+"us");
     }
   for(int i=0; i<n; i++)
     {
      this.m_calls[i]=0;
      this.m_total_us[i]=0;
      this.m_max_us[i]=0;
     }
   this.m_window_start=now;
  }
 CPerf g_perf;
#endif // __PERF_MQH__
