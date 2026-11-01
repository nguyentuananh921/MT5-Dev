//+------------------------------------------------------------------+
//|                                                 PythonBridge.mqh |
//+------------------------------------------------------------------+
//--- Python is the other Controller of the database: the EA only starts it when it is not running. No socket and no message: Python takes the place in the
//--- table Setting_PythonBridge (its process id) and writes the time it was alive there once a second, the EA reads it and clears the place when it is closed.
//--- A launch needs "Allow DLL imports" in the options of the EA
#ifndef __PYTHONBRIDGE_MQH__
#define __PYTHONBRIDGE_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Services\LibDatabase.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V4\Entities\Defines\EventDefines.mqh>
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
#ifndef CPYTHONBRIDGE_MQH_DECLARATION
#define CPYTHONBRIDGE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Starts Python when it is not running                             |
 //+------------------------------------------------------------------+
 class CPythonBridge : public CBaseObj
  {
   private:
    int               m_db;                  // the open database: the table Setting_PythonBridge is asked here
    ulong             m_launch_ms;           // when Python was launched last (0 = never)
    ulong             m_check_ms;            // when the table was read last
    bool              m_symboltf_told;       // PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE was sent for the run of Current (its file stays while Python runs: an EA loaded again finds it)
    bool              CreateTable_PythonBridge(void);
    void              Launch(void);
   //--- The place of Python in the table (the lines pid and alive_at): the process id of the Python (the parent) and the time of its mark
    bool              Row_PythonBridge(long &pid,long &alive_at) const;
   //--- Python wrote a while ago, but the process of the table still runs: it is busy (the history is loading), not gone, and a new one is not started
    bool              IsBusy(void) const;
   //--- A file Python made when it reached a milestone: it is told in the journal and the file is taken away (the file is the memory: nothing is kept here)
    bool              TellMilestone(const string file,const string text);   // true when the milestone was there (told now)
   public:
                      CPythonBridge(void) : m_db(INVALID_HANDLE),m_launch_ms(0),m_check_ms(0),m_symboltf_told(false) { }
                     ~CPythonBridge(void) { if(m_db != INVALID_HANDLE) ::DatabaseClose(m_db); }
   //--- Lifecycle: opens the database, makes the table Setting_PythonBridge when it is not there, starts Python when it is not running
    bool              OnInitEvent(void);
   //--- The EA is closed (it removes itself, the user removes it, the chart or the terminal closes, another account is activated): the place is cleared, the Python of the
   //--- table sees it gone and stops with its workers. A chart change, a new compile, a change of the parameters or of the template keeps it: the history is loaded once
    void              OnDeinitEvent(const int reason);
   //--- Python wrote in the table lately
    bool              IsAlive(void) const;
   //--- The rhythm of the EA: Python that stopped is started again
    void              OnTimerEvent(void);
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
 bool CPythonBridge::CreateTable_PythonBridge(void)
  {
   string who="Make Setting_PythonBridge";
   LibDatabase_AskToWrite();   // the workers of Python let this write go first
   //--- A table of the older shape (one row: id, pid, alive_at) goes: it held only the place of Python
   const bool old_shape=LibDatabase_TableExists(m_db,"Setting_PythonBridge") && !LibDatabase_ColumnExists(m_db,"Setting_PythonBridge","name");
   const string place="('pid', 0, 'Process id of the parent Python that holds the place (0 = nobody). Python writes it, the EA clears it when it is closed'), "
                      "('alive_at', 0, 'Time of the last mark of life of that Python, UTC milliseconds. Python writes it once a second, the EA clears it when it is closed')";
   const string settings="('write_rows', '"+(string)EA_PYTHON_WRITE_ROWS+"', 'Results a worker gathers before it stands in the line to write, and the rows of one turn (EA_PYTHON_WRITE_ROWS)'), "
                         "('store_bars', '"+(string)(int)EA_STORE_BARS+"', '1: the bars of the terminal are copied into BarSeriesDE. 0: none is kept, they are taken from the terminal when they are judged (EA_STORE_BARS)'), "
                         "('alive_ms', '"+(string)PYTHON_ALIVE_MS+"', 'Python is running when its mark of life is not older than this, milliseconds (PYTHON_ALIVE_MS)'), "
                         "('hung_ms', '"+(string)PYTHON_HUNG_MS+"', 'A Python whose process runs but wrote nothing for this long, milliseconds, is hung and is ended; before it is only busy (PYTHON_HUNG_MS)'), "
                         "('write_queue', '"+LibDatabase_Quoted(LIB_DATABASE_WRITE_QUEUE)+"', 'Name of the Windows mutex the workers of Python and the EA stand in to write (LIB_DATABASE_WRITE_QUEUE)'), "
                         "('write_flag', '"+LibDatabase_Quoted(LIB_DATABASE_WRITE_FLAG)+"', 'File next to the database that tells the workers of Python that the EA is next (LIB_DATABASE_WRITE_FLAG)'), "
                         "('chart_symbol', '"+LibDatabase_Quoted(::Symbol())+"', 'Symbol of the chart the EA is on (the Current Python worker calculates its pair first)'), "
                         "('chart_tf', '"+(string)(int)::Period()+"', 'TF (tf_enum) of the chart the EA is on')";
   const bool done=(!old_shape || ::DatabaseExecute(m_db,"DROP TABLE Setting_PythonBridge")) &&
                   ::DatabaseExecute(m_db,"CREATE TABLE IF NOT EXISTS Setting_PythonBridge (name TEXT NOT NULL PRIMARY KEY, value NOT NULL, comment TEXT NOT NULL DEFAULT '') WITHOUT ROWID") &&
                   (LibDatabase_ColumnExists(m_db,"Setting_PythonBridge","comment") || ::DatabaseExecute(m_db,"ALTER TABLE Setting_PythonBridge ADD COLUMN comment TEXT NOT NULL DEFAULT ''")) &&
                   ::DatabaseExecute(m_db,"INSERT INTO Setting_PythonBridge (name, value, comment) VALUES "+place+" ON CONFLICT(name) DO UPDATE SET comment = excluded.comment") &&   // the place of Python is never reset here
                   ::DatabaseExecute(m_db,"INSERT INTO Setting_PythonBridge (name, value, comment) VALUES "+settings+" ON CONFLICT(name) DO UPDATE SET value = excluded.value, comment = excluded.comment");
   if(!done)
     {
      LibDatabase_WriteRefused(who);
      ::Print(__FUNCTION__," > the table Setting_PythonBridge is not made, error ",::GetLastError());
      return false;
     }
   LibDatabase_WriteDone(who);
   return true;
  }
 bool CPythonBridge::OnInitEvent(void)
  {
   if(m_db==INVALID_HANDLE)
     {
      m_db=LibDatabase_Open(DATABASE_OPEN_READWRITE);
      if(m_db==INVALID_HANDLE)
        {
         ::Print(__FUNCTION__," > the database ",LIB_DATABASE_FILE," is not opened, error ",::GetLastError());
         return false;
        }
      ::DatabaseExecute(m_db,"PRAGMA busy_timeout=5000");
      if(!this.CreateTable_PythonBridge())
         return false;
     }
   if(!this.IsAlive() && !this.IsBusy())
     {
      //--- No Python runs: what an earlier one reported is not true any more
      LibDatabase_DoneFile(PYTHON_CURRENT_START_FILE);
      LibDatabase_DoneFile(PYTHON_CURRENT_START_CURRENT_CHART_FILE);
      LibDatabase_DoneFile(PYTHON_CURRENT_START_SYMBOL_TF_FILE);
      LibDatabase_DoneFile(PYTHON_CURRENT_DONE_FILE);
      LibDatabase_DoneFile(PYTHON_HISTORY_FILE);
      this.Launch();
     }
   return true;
  }
 void CPythonBridge::OnDeinitEvent(const int reason)
  {
   //--- The EA starts again at once on the same chart: Python keeps running. Every other reason ends it: the EA removes itself (ExpertRemove of the close button of the
   //--- panel: REASON_PROGRAM), the user removes it, the chart or the terminal closes, or another account is activated (the EA starts again and starts the one of the new account)
   if(reason==REASON_RECOMPILE || reason==REASON_CHARTCHANGE || reason==REASON_PARAMETERS || reason==REASON_TEMPLATE || m_db==INVALID_HANDLE)
      return;
   string who="Clear Setting_PythonBridge";
   for(int attempt=0;attempt<3;attempt++)
     {
      LibDatabase_AskToWrite();   // the workers of Python let this write go first
      if(::DatabaseExecute(m_db,"UPDATE Setting_PythonBridge SET value = 0 WHERE name IN ('pid', 'alive_at')"))
        {
         LibDatabase_WriteDone(who);
         return;
        }
      LibDatabase_WriteRefused(who);
      ::Sleep(200);
     }
  }
 bool CPythonBridge::Row_PythonBridge(long &pid,long &alive_at) const
  {
   pid=0;
   alive_at=0;
   if(m_db==INVALID_HANDLE)
      return false;
   int request=::DatabasePrepare(m_db,"SELECT name, value FROM Setting_PythonBridge WHERE name IN ('pid', 'alive_at')");
   if(request==INVALID_HANDLE)
      return false;
   bool found=false;
   while(::DatabaseRead(request))
     {
      string name;
      long value=0;
      ::DatabaseColumnText(request,0,name);
      ::DatabaseColumnLong(request,1,value);
      if(name=="pid")
        {
         pid=value;
         found=true;
        }
      else
         alive_at=value;
     }
   ::DatabaseFinalize(request);
   return found;
  }
 bool CPythonBridge::IsAlive(void) const
  {
   long pid,alive_at;
   if(!this.Row_PythonBridge(pid,alive_at))
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
   if(!this.Row_PythonBridge(pid,alive_at) || pid<=0 || alive_at<=0)
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
   string command=PYTHON_EXE+" \""+::TerminalInfoString(TERMINAL_DATA_PATH)+PYTHON_SCRIPT+"\"";   // nothing else: what the EA decides is in Setting_PythonBridge
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
   if(!m_symboltf_told && LibDatabase_FileExists(PYTHON_CURRENT_START_SYMBOL_TF_FILE))
     {
      m_symboltf_told=true;
      ::Print("Python Current Python: every pair of Setting_SymbolTF is in the database");
      ::EventChartCustom(::ChartID(),(ushort)PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE,0,0.0,"");   // CSyncManager, then the collections hear it: what Python wrote goes to RAM, the library judges
     }
   this.TellMilestone(PYTHON_CURRENT_DONE_FILE,"Current Python complete: every Symbol + TF is in the database");
   this.TellMilestone(PYTHON_HISTORY_FILE,"history complete: every symbol and timeframe has its history, only the new bars go on");
  }
 bool CPythonBridge::TellMilestone(const string file,const string text)
  {
   if(!LibDatabase_FileExists(file))
      return false;
   ::Print("Python ",text);
   LibDatabase_DoneFile(file);
   return true;
  }
#endif // CPYTHONBRIDGE_MQH_IMPLEMENTATION
#endif // __PYTHONBRIDGE_MQH__
