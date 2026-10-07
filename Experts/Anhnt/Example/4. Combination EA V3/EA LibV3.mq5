#property copyright "Copyright 2026, Anhnt"
#property link      "http://www.mql5.com"
#property version   "3.00"
 #include "Configuration\EA Configuration.mqh"

 bool PythonSend(const string text)
  {
   uchar data[];
   int len = ::StringToCharArray(text, data, 0, WHOLE_ARRAY, CP_UTF8) - 1;   // drop the terminating zero
   return ::SocketSend(g_python_socket, data, len) == len;
  }

 void PythonSendInit(void)
  {
   string pairs = "";
   for(int i = 0; i < m_SymbolTFManager.Total(); i++)
     {
      CSymbolTFSetting *row = m_SymbolTFManager.At(i);
      if(row == NULL) continue;
      pairs += (pairs == "" ? "" : ",") + "[\"" + row.Symbol() + "\",\"" + row.TFText() + "\"]";
     }
   if(PythonSend("{\"cmd\":\"init\",\"count\":0,\"pairs\":[" + pairs + "]}\n"))
      ::Print(__FUNCTION__, ": init sent to Python, ", m_SymbolTFManager.Total(), " pair(s)");
   else
      ::Print(__FUNCTION__, ": send failed, error ", ::GetLastError());
  }

 void PythonSendWatch(void)
  {
   ::ArrayResize(g_python_swings, 0);
   g_python_watch_done = false;
   string tf_text = TimeframeDescription((ENUM_TIMEFRAMES)::Period());
   string text = "{\"cmd\":\"watch\",\"symbol\":\"" + ::Symbol() + "\",\"tf\":\"" + tf_text + "\"}\n";
   if(PythonSend(text))
      ::Print(__FUNCTION__, ": watch sent for ", ::Symbol(), " ", tf_text);
   else
      ::Print(__FUNCTION__, ": send failed, error ", ::GetLastError());
  }

 void PythonStoreSwing(const string line)
  {
   string part[];
   if(::StringSplit(line, '|', part) != 8)
     {
      ::Print(__FUNCTION__, ": malformed line ", line);
      return;
     }
   datetime time = (datetime)::StringToInteger(part[3]);
   bool is_high = (part[5] == "HIGH");
   if(g_python_watch_done)
      for(int i = ::ArraySize(g_python_swings) - 1; i >= 0; i--)
         if(g_python_swings[i].time == time && g_python_swings[i].is_high == is_high)
            return;
   int n = ::ArraySize(g_python_swings);
   ::ArrayResize(g_python_swings, n + 1, 256);
   g_python_swings[n].time = time;
   g_python_swings[n].confirmed_time = (datetime)::StringToInteger(part[4]);
   g_python_swings[n].is_high = is_high;
   g_python_swings[n].price = ::StringToDouble(part[6]);
   g_python_swings[n].structure = part[7];
   if(g_python_watch_done)
      ::Print(__FUNCTION__, ": new ", part[5], " ", part[7], " at ", ::TimeToString(time), " price ", part[6]);
  }

 void PythonClose(void)
  {
   if(g_python_socket != INVALID_HANDLE)
      ::SocketClose(g_python_socket);
   g_python_socket = INVALID_HANDLE;
   g_python_state = PYTHON_STATE_DISCONNECTED;
  }

 bool PythonTryConnect(void)
  {
   g_python_socket = ::SocketCreate();
   if(g_python_socket == INVALID_HANDLE)
      return false;
   if(!::SocketConnect(g_python_socket, PYTHON_HOST, PYTHON_PORT, PYTHON_CONNECT_TIMEOUT_MS))
     {
      g_python_connect_error = ::GetLastError();
      ::SocketClose(g_python_socket);
      g_python_socket = INVALID_HANDLE;
      return false;
     }
   g_python_state = PYTHON_STATE_READY;
   PythonSendInit();
   PythonSendWatch();
   return true;
  }

 void PythonLaunch(void)
  {
   if(g_python_launch_ms != 0 && ::GetTickCount64() - g_python_launch_ms < PYTHON_RELAUNCH_BLOCK_MS)
      return;
   string command = PYTHON_EXE + " \"" + ::TerminalInfoString(TERMINAL_DATA_PATH) + PYTHON_SCRIPT + "\"";
   uchar bytes[];
   ::StringToCharArray(command, bytes, 0, WHOLE_ARRAY, CP_ACP);
   uint result = WinExec(bytes, PYTHON_WINDOW_SHOW);
   g_python_launch_ms = ::GetTickCount64();
   if(result <= 31)
      ::Print(__FUNCTION__, ": WinExec failed, code ", result, ", command ", command);
   else
      ::Print(__FUNCTION__, ": Python launched, ", command);
  }

 void PythonStart(void)
  {
   if(PythonTryConnect())
      return;
   ::Print(__FUNCTION__, ": Python not reachable, error ", g_python_connect_error);
   PythonLaunch();
   g_python_state = PYTHON_STATE_CONNECTING;
   g_python_wait_start_ms = ::GetTickCount64();
   g_python_last_try_ms = g_python_wait_start_ms;
  }

 void PythonPoll(void)
  {
   ulong now = ::GetTickCount64();
   if(g_python_state == PYTHON_STATE_CONNECTING)
     {
      if(now - g_python_last_try_ms < PYTHON_RETRY_MS)
         return;
      g_python_last_try_ms = now;
      if(PythonTryConnect())
         return;
      if(now - g_python_wait_start_ms > PYTHON_WAIT_MS)
        {
         g_python_state = PYTHON_STATE_DISCONNECTED;
         ::Print(__FUNCTION__, ": Python did not answer within ", PYTHON_WAIT_MS, " ms, last error ", g_python_connect_error);
        }
      return;
     }
   if(g_python_state != PYTHON_STATE_READY)
      return;
   uint n = ::SocketIsReadable(g_python_socket);
   if(n == 0)
     {
      if(!::SocketIsConnected(g_python_socket))
        {
         PythonClose();
         ::Print(__FUNCTION__, ": Python connection lost");
        }
      return;
     }
   uchar buf[];
   int got = ::SocketRead(g_python_socket, buf, n, 0);
   if(got <= 0)
      return;
   g_python_rx += ::CharArrayToString(buf, 0, got, CP_UTF8);
   int eol;
   while((eol = ::StringFind(g_python_rx, "\n")) >= 0)
     {
      string line = ::StringSubstr(g_python_rx, 0, eol);
      g_python_rx = ::StringSubstr(g_python_rx, eol + 1);
      if(::StringFind(line, "swing|") == 0)
        {
         PythonStoreSwing(line);
         continue;
        }
      ::Print("Python: ", line);
      if(::StringFind(line, "\"event\": \"watch\"") >= 0)
        {
         g_python_watch_done = true;
         ::Print(__FUNCTION__, ": ", ::ArraySize(g_python_swings), " swing(s) held for ", ::Symbol(), " ", TimeframeDescription((ENUM_TIMEFRAMES)::Period()));
        }
     }
  }

 int OnInit(void)
  {
   g_ea_init_done = false;
   m_SymbolTFManager.OnInitEvent();
   PythonStart();
   EventSetMillisecondTimer(16);
   g_ea_init_done = true;
   return(INIT_SUCCEEDED);
  }

 void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(g_python_state == PYTHON_STATE_READY && reason == REASON_REMOVE)
      PythonSend("{\"cmd\":\"quit\"}\n");   // chart change/recompile: Python keeps running
   PythonClose();
  }

 void OnTick(void)
  {
  }

 void OnTimer(void)
  {
   if(!g_ea_init_done) return;
   PythonPoll();
  }

 void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
  }
