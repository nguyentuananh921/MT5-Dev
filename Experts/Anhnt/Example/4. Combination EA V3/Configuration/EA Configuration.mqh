//+------------------------------------------------------------------+
//|                                             EA Configuration.mqh |
//+------------------------------------------------------------------+
#ifndef __EACONFIGURATION_MQH__
#define __EACONFIGURATION_MQH__
//Include and declare properties
  #include "SymbolTFManager.mqh"
   CSymbolTFManager m_SymbolTFManager;
 #import "kernel32.dll"
  uint WinExec(uchar &command[], int show);
 #import
   enum ENUM_PYTHON_STATE
    {
     PYTHON_STATE_DISCONNECTED,
     PYTHON_STATE_CONNECTING,
     PYTHON_STATE_READY
    };
   #define PYTHON_HOST                "127.0.0.1"
   #define PYTHON_PORT                (9090)
   #define PYTHON_EXE                 "python"
   #define PYTHON_SCRIPT              "\\MQL5\\Include\\Vendors\\Anhnt\\Library\\4. Combination Lib V3\\Python\\main.py"
   #define PYTHON_CONNECT_TIMEOUT_MS  (100)
   #define PYTHON_RETRY_MS            (500)
   #define PYTHON_WAIT_MS             (20000)
   #define PYTHON_RELAUNCH_BLOCK_MS   (30000)
   #define PYTHON_WINDOW_SHOW         (1)
   bool              g_ea_init_done = false;
   int               g_python_socket = INVALID_HANDLE;
   string            g_python_rx = "";
   ENUM_PYTHON_STATE g_python_state = PYTHON_STATE_DISCONNECTED;
   ulong             g_python_launch_ms = 0;       // globals survive a chart change: do not launch a second Python
   ulong             g_python_wait_start_ms = 0;
   ulong             g_python_last_try_ms = 0;
   int               g_python_connect_error = 0;
   bool              g_python_watch_done = false;

   struct SPythonSwing
    {
     datetime time;
     datetime confirmed_time;
     bool     is_high;
     double   price;
     string   structure;
    };
   SPythonSwing g_python_swings[];
#endif // __EACONFIGURATION_MQH__