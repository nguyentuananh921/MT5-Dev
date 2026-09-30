//+------------------------------------------------------------------+
//|                                                 SignalLogger.mqh |
//|                                     Copyright 2026, Anhnt        |
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef __SIGNALLOGGER_MQH__
#define __SIGNALLOGGER_MQH__
#include "JSONConfig.mqh" // Working with JSON Config file
 #ifndef CSIGNALLOGGER_MQH_DECLARATION
 #define CSIGNALLOGGER_MQH_DECLARATION
 class CSignalLogger
  {
   private:
     string            m_wm_type[];
     string            m_wm_params[];
     datetime          m_wm_time[];

     // --- Only this class needs "time" (int) out of a JSON watermark record - kept private
     // --- here rather than in the shared JSONConfig.mqh. JSONConfig_StringValue is NOT duplicated
     // --- here (Marker/Sound also need it) - the call below resolves to the shared global.
     bool              JsonIntValue(const string content, const string key, int &value);

   public:
                     CSignalLogger(void);
                    ~CSignalLogger(void);

     void              WriteSignalLogRow(const string time_text, const string source_type, const string tf, const string status, const string direction, const string name, const string price_text, const string cross_text);
     datetime          GetSignalLogWatermark(const string type_key, const string params_key);
     void              SetSignalLogWatermark(const string type_key, const string params_key, const datetime t);
     void              LoadSignalLogWatermarks(void);
     void              SaveSignalLogWatermarksToFile(void);
  };
 #endif // CSIGNALLOGGER_MQH_DECLARATION
 #ifndef CSIGNALLOGGER_MQH_IMPLEMENTATION
 #define CSIGNALLOGGER_MQH_IMPLEMENTATION  
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CSignalLogger::CSignalLogger(void)
   {    
    ArrayResize(m_wm_type, 0);
    ArrayResize(m_wm_params, 0);
    ArrayResize(m_wm_time, 0);
   }
  //+------------------------------------------------------------------+
  //| Destructor                                                       |
  //+------------------------------------------------------------------+
  CSignalLogger::~CSignalLogger(void)
   {
   }
  
  //+------------------------------------------------------------------+
  //| WriteSignalLogRow                                                |
  //+------------------------------------------------------------------+  
  void CSignalLogger::WriteSignalLogRow(const string time_text, const string source_type, const string tf, const string status, const string direction, const string name, const string price_text, const string cross_text)
   {
    string base_fname = "Signal_Log_" + ::Symbol() + ".csv";
    string filepath = (g_ea_folder != "") ? (g_ea_folder + "/" + base_fname) : base_fname;
    int fh = ::FileOpen(filepath, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, ';');
    if(fh == INVALID_HANDLE) return;
    bool is_new = (::FileSize(fh) == 0);
    if(is_new)
      {
        ::FileWriteString(fh, "sep=;\n");
        ::FileWrite(fh, "Time", "Source", "TF", "Status", "Direction", "Name", "Price", "Cross");
      }
    else
        ::FileSeek(fh, 0, SEEK_END);
    ::FileWrite(fh, time_text, source_type, tf, status, direction, name, price_text, cross_text);
    ::FileClose(fh);
   }
  //+------------------------------------------------------------------+
  //| GetSignalLogWatermark                                            |
  //+------------------------------------------------------------------+
  datetime CSignalLogger::GetSignalLogWatermark(const string type_key, const string params_key)
   {
    for(int i = 0; i < ArraySize(m_wm_type); i++)
       if(m_wm_type[i] == type_key && m_wm_params[i] == params_key)
          return m_wm_time[i];
    return 0;
   }
  //+------------------------------------------------------------------+
  //| SetSignalLogWatermark                                            |
  //+------------------------------------------------------------------+
  void CSignalLogger::SetSignalLogWatermark(const string type_key, const string params_key, const datetime t)
   {
    for(int i = 0; i < ArraySize(m_wm_type); i++)
       if(m_wm_type[i] == type_key && m_wm_params[i] == params_key)
         {
          m_wm_time[i] = t;
          SaveSignalLogWatermarksToFile();
          return;
         }
    int n = ArraySize(m_wm_type);
    ArrayResize(m_wm_type,   n + 1);
    ArrayResize(m_wm_params, n + 1);
    ArrayResize(m_wm_time,   n + 1);
    m_wm_type[n]   = type_key;
    m_wm_params[n] = params_key;
    m_wm_time[n]   = t;
    SaveSignalLogWatermarksToFile();
   }
  
  //+------------------------------------------------------------------+
  //| LoadSignalLogWatermarks                                          |
  //+------------------------------------------------------------------+
  void CSignalLogger::LoadSignalLogWatermarks(void)
   {
    // --- One file per SYMBOL, not per (symbol,TF) - watermarks now span every tracked TF of
    // --- the symbol (Anhnt, 2026-08-10), so params_key already carries its own "|<TF>" suffix
    // --- (see CGUIPannel::CheckIndicatorAlerts) to keep entries from different TFs apart.
    string base_fname = "Signal_Log_Watermark_" + ::Symbol() + ".json";
    string fname = (g_ea_folder != "") ? (g_ea_folder + "/" + base_fname) : base_fname;
    string content = JSONConfig_ReadWholeFile(fname);
    if(content == "") return;

    int pos = ::StringFind(content, "\"watermarks\"");
    if(pos < 0) return;
    int arr_start = ::StringFind(content, "[", pos);
    int arr_end   = ::StringFind(content, "]", arr_start);
    if(arr_start < 0 || arr_end < 0) return;

    int i = arr_start + 1;
    while(i < arr_end)
     {
      int obj_start = ::StringFind(content, "{", i);
      if(obj_start < 0 || obj_start > arr_end) break;
      int obj_end = ::StringFind(content, "}", obj_start);
      if(obj_end < 0 || obj_end > arr_end) break;
      string obj = ::StringSubstr(content, obj_start, obj_end - obj_start + 1);

      string type_key, params_key; int t;
      if(JSONConfig_StringValue(obj, "type", type_key) && JSONConfig_StringValue(obj, "params", params_key) && JsonIntValue(obj, "time", t))
        {
         int n = ArraySize(m_wm_type);
         ArrayResize(m_wm_type,   n + 1);
         ArrayResize(m_wm_params, n + 1);
         ArrayResize(m_wm_time,   n + 1);
         m_wm_type[n]   = type_key;
         m_wm_params[n] = params_key;
         m_wm_time[n]   = (datetime)t;
        }
      i = obj_end + 1;
     }
   }

  //+------------------------------------------------------------------+
  //| SaveSignalLogWatermarksToFile                                    |
  //+------------------------------------------------------------------+
  void CSignalLogger::SaveSignalLogWatermarksToFile(void)
   {
    // --- One file per SYMBOL - see LoadSignalLogWatermarks (Anhnt, 2026-08-10).
    string base_fname = "Signal_Log_Watermark_" + ::Symbol() + ".json";
    string fname = (g_ea_folder != "") ? (g_ea_folder + "/" + base_fname) : base_fname;
    string json = "{\n \"watermarks\": [\n";
    int n = ArraySize(m_wm_type);
    for(int i = 0; i < n; i++)
     {
      string type_esc = m_wm_type[i]; ::StringReplace(type_esc, "\\", "\\\\");
      string params_esc = m_wm_params[i]; ::StringReplace(params_esc, "\\", "\\\\");
      json += "  { \"type\": \"" + type_esc + "\", \"params\": \"" + params_esc + "\", \"time\": " + (string)(int)m_wm_time[i] + " }";
      json += (i < n - 1) ? ",\n" : "\n";
     }
    json += " ]\n}";

    int fh = ::FileOpen(fname, FILE_TXT|FILE_WRITE|FILE_ANSI);
    if(fh == INVALID_HANDLE) return;
    ::FileWriteString(fh, json);
    ::FileClose(fh);
   }

  //+------------------------------------------------------------------+
  //| JsonIntValue                                                     |
  //+------------------------------------------------------------------+
  bool CSignalLogger::JsonIntValue(const string content, const string key, int &value)
   {
    int pos = ::StringFind(content, "\"" + key + "\"");
    if(pos < 0) return false;
    int colon = ::StringFind(content, ":", pos);
    if(colon < 0) return false;
    int len = ::StringLen(content);
    int i = colon + 1;
    while(i < len && ::StringGetCharacter(content, i) == ' ') i++;
    int start = i;
    while(i < len)
     {
      ushort ch = ::StringGetCharacter(content, i);
      if((ch < '0' || ch > '9') && ch != '-') break;
      i++;
     }
    string num = ::StringSubstr(content, start, i - start);
    if(num == "") return false;
    value = (int)::StringToInteger(num);
    return true;
   }
 #endif // CSIGNALLOGGER_MQH_IMPLEMENTATION
#endif // __SIGNALLOGGER_MQH__
