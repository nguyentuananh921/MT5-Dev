//+------------------------------------------------------------------+
//|                                                 PythonBridge.mqh |
//+------------------------------------------------------------------+
//--- Python is the other Controller of the database: the EA only starts it when it is not running. No socket and no message: Python takes the place in the
//--- table Setting_PythonBridge (its process id) and writes the time it was alive there once a second, the EA reads it and clears the place when it is closed.
//--- A launch needs "Allow DLL imports" in the options of the EA
#ifndef __PYTHONBRIDGE_MQH__
#define __PYTHONBRIDGE_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Services\DELib\DatabaseService.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Defines\EventDefines.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Defines\BarDefines.mqh>
 #import "kernel32.dll"
  uint WinExec(uchar &command[],int show);
  long OpenProcess(uint access,int inherit,uint pid);
  int  GetExitCodeProcess(long handle,uint &code);
  int  CloseHandle(long handle);
 #import
 #define PYTHON_EXE                 "python"
 #define PYTHON_SCRIPT              "\\MQL5\\Include\\Vendors\\Anhnt\\Library\\4. Combination Lib V4\\Python\\main.py"
 #define PYTHON_ALIVE_MS            (10000)   // Python is running when it wrote in the table this long ago at most (Python reads it: alive_ms)
 #define PYTHON_HUNG_MS             (120000)  // a Python whose process runs but wrote nothing for this long is hung (its watchdog ends it at 90 s): before that it is busy, not gone (Python reads it: hung_ms)
 #define PYTHON_PROCESS_QUERY       (0x1000)  // PROCESS_QUERY_LIMITED_INFORMATION
 #define PYTHON_STILL_ACTIVE        (259)     // the exit code of a process that has not ended
 #define PYTHON_RELAUNCH_BLOCK_MS   (30000)   // after a launch the next one waits this long: Python needs time to start and to write
 #define PYTHON_CHECK_MS            (5000)    // how often the EA looks at the table
 #define PYTHON_WINDOW_SHOW         (7)       // SW_SHOWMINNOACTIVE: its console is on the taskbar, minimized, and does not take the focus
 //--- Next to the database: Python makes them at its milestones, the EA tells each in the journal and takes the file away. The Current worker, in this order:
 #define PYTHON_CURRENT_START_FILE                "Python_CurrentStart.flag"     // it started
 #define PYTHON_CURRENT_START_CURRENT_CHART_FILE  "Python_CurrentChart.flag"     // the first chunk of the chart pair is in the database
 #define PYTHON_CURRENT_START_SYMBOL_TF_FILE      "Python_CurrentSymbolTF.flag"  // and the first chunk of every pair of Setting_SymbolTF (stays: see OnTimerEvent)
 #define PYTHON_CURRENT_DONE_FILE                 "Python_CurrentDone.flag"      // the newest bars of every pair are there, it ends
 #define PYTHON_HISTORY_FILE                      "Python_HistoryDone.flag"      // every worker of the history is asleep
 //--- The other way: the EA makes it, Python takes it away (libdb.JOBS_FLAG)
 #define PYTHON_JOBS_FILE                         "Python_Jobs.flag"             // a template or a pair came or went, or the rows of a changed parameter are deleted: the Current worker runs again at once
#ifndef CPYTHONBRIDGE_MQH_DECLARATION
#define CPYTHONBRIDGE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Starts Python when it is not running                             |
 //+------------------------------------------------------------------+
 //--- A line of Setting_PythonBridge, as CDatabaseService::Read binds it (the order of the SELECT)
 struct SPythonBridgeRow
  {
   string name;
   long   value;
  };
 class CPythonBridge : public CBaseObj
  {
   private:
    CDatabaseService *m_CDatabaseService;    // The EA holds it
    ulong             m_launch_ms;           // when Python was launched last (0 = never)
    ulong             m_check_ms;            // when the table was read last
    bool              m_symboltf_told;       // PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE was sent for the run of Current (its file stays while Python runs: an EA loaded again finds it)
    bool              CreateTable(void);
    void              Launch(void);
    string            FileNextToDatabase(const string name) const { return this.m_CDatabaseService.GetFolderName()+"\\"+name; }
    void              DoneFile(const string name) const;
   //--- The place of Python in the table (the lines pid and alive_at): the process id of the Python (the parent) and the time of its mark
    bool              Row(long &pid,long &alive_at) const;
   //--- Python wrote a while ago, but the process of the table still runs: it is busy (the history is loading), not gone, and a new one is not started
    bool              IsBusy(void) const;
   //--- A file Python made when it reached a milestone: it is told in the journal and the file is taken away (the file is the memory: nothing is kept here)
    bool              TellMilestone(const string file,const string text);   // true when the milestone was there (told now)
   public:
                      CPythonBridge(void) : m_CDatabaseService(NULL),m_launch_ms(0),m_check_ms(0),m_symboltf_told(false) { }
   void              SetDatabaseService(CDatabaseService *databaseService) { this.m_CDatabaseService=databaseService; }
                     ~CPythonBridge(void) {}
   //--- Lifecycle: opens the database, makes the table Setting_PythonBridge when it is not there, starts Python when it is not running
    bool              OnInitEvent(void);
   //--- The EA is closed (it removes itself, the user removes it, the chart or the terminal closes, another account is activated): the place is cleared, the Python of the
   //--- table sees it gone and stops with its workers. A chart change, a new compile, a change of the parameters or of the template keeps it: the history is loaded once
    void              OnDeinitEvent(const int reason);
   //--- Python wrote in the table lately
    bool              IsAlive(void) const;
   //--- The rhythm of the EA: Python that stopped is started again
    void              OnTimerEvent(void);
   //--- A template or a pair came or went (the events of the managers): Python is told (PYTHON_JOBS_FILE), the calculation of the history is its job
    void              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
  };
#endif // CPYTHONBRIDGE_MQH_DECLARATION
#ifndef CPYTHONBRIDGE_MQH_IMPLEMENTATION
#define CPYTHONBRIDGE_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Setting_PythonBridge: three columns, name, value and comment (what |
 //| the value means). 'pid' (the parent Python that holds the place,  |
 //| 0 = nobody) and 'alive_at' (the time of its mark, UTC milliseconds)|
 //| are written by Python, the EA clears them when it is closed. The   |
 //| other lines are what the EA decides (its Configuration): the EA    |
 //| writes them here, in OnInit, and Python reads them; no copy of     |
 //| them is kept in Python and no one is sent on its command line      |
 //+------------------------------------------------------------------+
 bool CPythonBridge::CreateTable(void)
  {
   const string place="('pid', 0, 'Process id of the parent Python that holds the place (0 = nobody). Python writes it, the EA clears it when it is closed'), "
                      "('alive_at', 0, 'Time of the last mark of life of that Python, UTC milliseconds. Python writes it once a second, the EA clears it when it is closed')";
   const string settings="('write_rows', '"+(string)EA_PYTHON_WRITE_ROWS+"', 'Results a worker gathers before it stands in the line to write, and the rows of one turn (EA_PYTHON_WRITE_ROWS)'), "
                         "('store_bars', '"+(string)(int)EA_STORE_BARS+"', '1: the bars of the terminal are copied into BarSeriesDE. 0: none is kept, they are taken from the terminal when they are judged (EA_STORE_BARS)'), "
                         "('alive_ms', '"+(string)PYTHON_ALIVE_MS+"', 'Python is running when its mark of life is not older than this, milliseconds (PYTHON_ALIVE_MS)'), "
                         "('hung_ms', '"+(string)PYTHON_HUNG_MS+"', 'A Python whose process runs but wrote nothing for this long, milliseconds, is hung and is ended; before it is only busy (PYTHON_HUNG_MS)'), "
                         "('write_queue', '"+this.m_CDatabaseService.QuoteSQLText(DATABASE_SERVICE_WRITE_QUEUE)+"', 'Name of the Windows mutex the workers of Python stand in to write (DATABASE_SERVICE_WRITE_QUEUE)'), "
                         "('write_flag', '"+this.m_CDatabaseService.QuoteSQLText(DATABASE_SERVICE_WRITE_FLAG)+"', 'File next to the database that tells the workers of Python that the EA is next (DATABASE_SERVICE_WRITE_FLAG)'), "
                         "('account_key', '"+this.m_CDatabaseService.QuoteSQLText(this.m_CDatabaseService.GetAccountKey())+"', 'The account of the EA (CDatabaseService::GetAccountKey)'), "
                         "('file_account', '"+this.m_CDatabaseService.QuoteSQLText(this.m_CDatabaseService.GetDatabaseFile("Account"))+"', 'The file of the account, under MQL5\\Files (CDatabaseService::GetDatabaseFile)'), "
                         "('chart_symbol', '"+this.m_CDatabaseService.QuoteSQLText(::Symbol())+"', 'Symbol of the chart the EA is on (the Current Python worker calculates its pair first)'), "
                         "('chart_tf', '"+(string)(int)::Period()+"', 'TF (tf_enum) of the chart the EA is on'), "
                         "('signal_buy', '"+(string)(int)SIGNAL_DIRECTION_BUY+"', 'signal_direction of a BUY row (SIGNAL_DIRECTION_BUY)'), "
                         "('signal_sell', '"+(string)(int)SIGNAL_DIRECTION_SELL+"', 'signal_direction of a SELL row (SIGNAL_DIRECTION_SELL)'), "
                         "('signal_none', '"+(string)(int)SIGNAL_DIRECTION_NONE+"', 'signal_direction of no side (SIGNAL_DIRECTION_NONE)'), "
                         "('object_python', '"+(string)(int)OBJECT_DE_TYPE_PYTHON+"', 'Setting_Sync.sync_by of Python (OBJECT_DE_TYPE_PYTHON)'), "
                         "('collection_series', '"+(string)(int)COLLECTION_SERIES_ID+"', 'Setting_Sync.sync_object of BarTimeSeriesCollection (COLLECTION_SERIES_ID)'), "
                         "('collection_signals', '"+(string)(int)COLLECTION_SIGNALS_ID+"', 'Setting_Sync.sync_object of SignalsCollection (COLLECTION_SIGNALS_ID)'), "
                         "('swing_price_basis_wick', '"+(string)(int)SWING_PRICE_BASIS_WICK+"', 'price_basis of High / Low (SWING_PRICE_BASIS_WICK)'), "
                         "('structure_lookback', '"+(string)STRUCTURE_LOOKBACK+"', 'BOS / CHoCH: bars back the swing before the broken one may be (STRUCTURE_LOOKBACK)'), "
                         "('file_current_start', '"+PYTHON_CURRENT_START_FILE+"', 'Python made it: Current started (PYTHON_CURRENT_START_FILE)'), "
                         "('file_current_chart', '"+PYTHON_CURRENT_START_CURRENT_CHART_FILE+"', 'Python made it: the chart pair is in the database (PYTHON_CURRENT_START_CURRENT_CHART_FILE)'), "
                         "('file_current_symboltf', '"+PYTHON_CURRENT_START_SYMBOL_TF_FILE+"', 'Python made it: every pair of Setting_SymbolTF has its first chunk (PYTHON_CURRENT_START_SYMBOL_TF_FILE)'), "
                         "('file_current_done', '"+PYTHON_CURRENT_DONE_FILE+"', 'Python made it: Current ended (PYTHON_CURRENT_DONE_FILE)'), "
                         "('file_history_done', '"+PYTHON_HISTORY_FILE+"', 'Python made it: every History worker is asleep (PYTHON_HISTORY_FILE)'), "
                         "('file_jobs', '"+PYTHON_JOBS_FILE+"', 'The EA made it: a template or a pair came or went (PYTHON_JOBS_FILE)')";
   // New In V4 after implemenation CDatabaseService
   if(!this.m_CDatabaseService.Create("Common","CREATE TABLE IF NOT EXISTS Setting_PythonBridge (name TEXT NOT NULL PRIMARY KEY, value NOT NULL, comment TEXT NOT NULL DEFAULT '') WITHOUT ROWID") ||
      !this.m_CDatabaseService.Create("Common","INSERT INTO Setting_PythonBridge (name, value, comment) VALUES "+place+" ON CONFLICT(name) DO UPDATE SET comment = excluded.comment") ||   // the place of Python is never reset here
      !this.m_CDatabaseService.Create("Common","INSERT INTO Setting_PythonBridge (name, value, comment) VALUES "+settings+" ON CONFLICT(name) DO UPDATE SET value = excluded.value, comment = excluded.comment"))
     {
      ::Print(__FUNCTION__," > the table Setting_PythonBridge is not made");
      return false;
     }
   return true;
  }
 bool CPythonBridge::OnInitEvent(void)
  {
   // New In V4 after implemenation CDatabaseService
   if(this.m_CDatabaseService==NULL)
     {
      ::Print(__FUNCTION__," > DatabaseService is not set");
      return false;
     }
   if(this.m_first_start)   // a chart change writes nothing
     {
      if(!this.CreateTable())
         return false;
      this.m_first_start=false;
     }
   if(!this.IsAlive() && !this.IsBusy())
     {
      //--- No Python runs: what an earlier one reported is not true any more
      this.DoneFile(PYTHON_CURRENT_START_FILE);
      this.DoneFile(PYTHON_CURRENT_START_CURRENT_CHART_FILE);
      this.DoneFile(PYTHON_CURRENT_START_SYMBOL_TF_FILE);
      this.DoneFile(PYTHON_CURRENT_DONE_FILE);
      this.DoneFile(PYTHON_HISTORY_FILE);
      this.Launch();
     }
   return true;
  }
 void CPythonBridge::OnDeinitEvent(const int reason)
  {
   //--- The EA starts again at once on the same chart: Python keeps running. Every other reason ends it: the EA removes itself (ExpertRemove of the close button of the
   //--- panel: REASON_PROGRAM), the user removes it, the chart or the terminal closes, or another account is activated (the EA starts again and starts the one of the new account)
   if(reason==REASON_RECOMPILE || reason==REASON_CHARTCHANGE || reason==REASON_PARAMETERS || reason==REASON_TEMPLATE || this.m_CDatabaseService==NULL)
      return;
   // New In V4 after implemenation CDatabaseService
   for(int attempt=0;attempt<3;attempt++)
     {
      if(this.m_CDatabaseService.Update("Common","UPDATE Setting_PythonBridge SET value = 0 WHERE name IN ('pid', 'alive_at')"))
         return;
      ::Sleep(200);
     }
  }
 bool CPythonBridge::Row(long &pid,long &alive_at) const
  {
   pid=0;
   alive_at=0;
   // New In V4 after implemenation CDatabaseService
   if(this.m_CDatabaseService==NULL)
      return false;
   SPythonBridgeRow rows[];
   if(!this.m_CDatabaseService.Read("Common","SELECT name, value FROM Setting_PythonBridge WHERE name IN ('pid', 'alive_at')",rows))
      return false;
   bool found=false;
   for(int i=0;i<::ArraySize(rows);i++)
     {
      if(rows[i].name=="pid")
        {
         pid=rows[i].value;
         found=true;
        }
      else
         alive_at=rows[i].value;
     }
   return found;
  }
 bool CPythonBridge::IsAlive(void) const
  {
   long pid,alive_at;
   if(!this.Row(pid,alive_at))
      return false;
   return(alive_at>0 && (long)::TimeGMT()*1000-alive_at<PYTHON_ALIVE_MS);
  }
 //+------------------------------------------------------------------+
 //| The process of the row runs and its mark is not older than       |
 //| PYTHON_HUNG_MS: it is busy. Older, or no process: gone or hung   |
 //+------------------------------------------------------------------+
 bool CPythonBridge::IsBusy(void) const
  {
   long pid,alive_at;
   if(!this.Row(pid,alive_at) || pid<=0 || alive_at<=0)
      return false;
   if((long)::TimeGMT()*1000-alive_at>=PYTHON_HUNG_MS)
      return false;
   long handle=OpenProcess(PYTHON_PROCESS_QUERY,0,(uint)pid);
   if(handle==0)
      return false;
   uint code=0;
   bool running=(GetExitCodeProcess(handle,code)!=0 && code==PYTHON_STILL_ACTIVE);
   CloseHandle(handle);
   return running;
  }
 //+------------------------------------------------------------------+
 //| Start Python: python "<MQL5 folder>\...\Python\main.py"          |
 //+------------------------------------------------------------------+
 void CPythonBridge::Launch(void)
  {
   if(m_launch_ms!=0 && ::GetTickCount64()-m_launch_ms<PYTHON_RELAUNCH_BLOCK_MS)
      return;
   string command=PYTHON_EXE+" \""+::TerminalInfoString(TERMINAL_DATA_PATH)+PYTHON_SCRIPT+"\" --database \""+this.m_CDatabaseService.GetDatabaseFile("Common")+"\"";   // where the table is: what the EA decides is in Setting_PythonBridge
   uchar bytes[];
   ::StringToCharArray(command,bytes,0,WHOLE_ARRAY,CP_ACP);
   uint result=WinExec(bytes,PYTHON_WINDOW_SHOW);
   m_launch_ms=::GetTickCount64();
   if(result<=31)
      ::Print(__FUNCTION__," > WinExec failed, code ",result,", command ",command);
   else
      ::Print(__FUNCTION__," > Python launched, ",command);
  }
 void CPythonBridge::OnTimerEvent(void)
  {
   if(::GetTickCount64()-m_check_ms<PYTHON_CHECK_MS)
      return;
   m_check_ms=::GetTickCount64();
   if(!this.IsAlive() && !this.IsBusy())
      this.Launch();
   if(this.TellMilestone(PYTHON_CURRENT_START_FILE,"Current Python start"))
     {
      m_symboltf_told=false;   // a new run of Current (it took the file of the run before away): the library waits for its SYMBOLTF_DONE
      ::EventChartCustom(::ChartID(),(ushort)PYTHON_BRIDGE_EVENT_CURRENT_START,0,0.0,"");
     }
   this.TellMilestone(PYTHON_CURRENT_START_CURRENT_CHART_FILE,"Current Python: the chart pair is in the database");
   //--- The file of this milestone stays while Python runs (Current takes it away when it starts again): an EA loaded again while Python runs (a new compile, the
   //--- parameters) finds it and the library starts at once. It is told once by this EA
   if(!m_symboltf_told && ::FileIsExist(this.FileNextToDatabase(PYTHON_CURRENT_START_SYMBOL_TF_FILE)))
     {
      m_symboltf_told=true;
      ::Print("Python Current Python: every pair of Setting_SymbolTF is in the database");
      ::EventChartCustom(::ChartID(),(ushort)PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE,0,0.0,"");   // CSyncManager, then the collections hear it: what Python wrote goes to RAM, the library judges
     }
   this.TellMilestone(PYTHON_CURRENT_DONE_FILE,"Current Python complete: every Symbol + TF is in the database");
   this.TellMilestone(PYTHON_HISTORY_FILE,"history complete: every symbol and timeframe has its history, only the new bars go on");
  }
 void CPythonBridge::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED && id!=CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE &&
      id!=CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED && id!=CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE &&
      id!=CHARTEVENT_CUSTOM+BAR_INFORMATION_MANAGER_EVENT_RESET_DONE)
      return;
   int handle=::FileOpen(this.FileNextToDatabase(PYTHON_JOBS_FILE),FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(handle==INVALID_HANDLE)
     {
      ::Print(__FUNCTION__," > ",PYTHON_JOBS_FILE," is not made, error ",::GetLastError());
      return;
     }
   ::FileWriteString(handle,(string)(id-CHARTEVENT_CUSTOM)+" "+sparam);
   ::FileClose(handle);
  }
 bool CPythonBridge::TellMilestone(const string file,const string text)
  {
   if(!::FileIsExist(this.FileNextToDatabase(file)))
      return false;
   ::Print("Python ",text);
   this.DoneFile(file);
   return true;
  }
 void CPythonBridge::DoneFile(const string name) const
  {
   if(::FileIsExist(this.FileNextToDatabase(name)))
      ::FileDelete(this.FileNextToDatabase(name));
  }
#endif // CPYTHONBRIDGE_MQH_IMPLEMENTATION
#endif // __PYTHONBRIDGE_MQH__
