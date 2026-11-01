//+------------------------------------------------------------------+
//|                                                      Message.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Link https://www.mql5.com/en/articles/7176                        |
//|Link https://www.mql5.com/en/articles/7258                        |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property strict
#ifndef __MESSAGE_MQH__
#define __MESSAGE_MQH__
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
 #include "MessageDefines.mqh"
 #include "MessageData.mqh"
 #ifndef CMESSAGE_MQH_DECLARATION
 #define CMESSAGE_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Message class                                                    |
 //+------------------------------------------------------------------+
 class CMessage
  {
   private:
    static int        m_global_error;
    static uchar      m_lang_num;
    static string     m_text;
    static void       GetTextByID(const int msg_id);
   public:
    static string     Text(const int msg_id);
    static string     Retcode(const int msg_id)     { return "("+(string)msg_id+")";    }
    static void       ToLog(const string source,const int msg_id,const bool code=false);
    //--- (1) play an audio file, (2) stop playing any sound, (3) the error of the last call (V3: the sounds of the trading object)
    static bool       PlaySound(const string file_name);
    static bool       StopPlaySound(void);
    static int        GetError(void)                { return CMessage::m_global_error;  }
  };
 #endif // CMESSAGE_MQH_DECLARATION
 #ifndef CMESSAGE_MQH_IMPLEMENTATION
 #define CMESSAGE_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Initialization of static variables                               |
//+------------------------------------------------------------------+
  uchar  CMessage::m_lang_num=(::TerminalInfoString(TERMINAL_LANGUAGE)==COUNTRY_LANG ? 0 : 1);
  string CMessage::m_text=NULL;
  int    CMessage::m_global_error=ERR_SUCCESS;
//+------------------------------------------------------------------+
//| Display a message in the journal by a message ID                 |
//+------------------------------------------------------------------+
void CMessage::ToLog(const string source,const int msg_id,const bool code)
  {
   CMessage::GetTextByID(msg_id);
   ::Print(source,m_text,(!code || msg_id>ERR_USER_ERROR_FIRST-1 ? "" : " "+CMessage::Retcode(msg_id)));
  }
//+------------------------------------------------------------------+
//| Return the message text by a message ID                          |
//+------------------------------------------------------------------+
string CMessage::Text(const int msg_id)
  {
   CMessage::GetTextByID(msg_id);
   return m_text;
  }
//+------------------------------------------------------------------+
//| Get messages from the text array by an ID                        |
//+------------------------------------------------------------------+
void CMessage::GetTextByID(const int msg_id)
  {
   CMessage::m_text=
     (
      //--- Runtime errors (0, 4001 - 4025)
      msg_id==0                     ?  messages_runtime[msg_id][m_lang_num]                        :
      msg_id>4000 && msg_id<4026    ?  messages_runtime[msg_id-4000][m_lang_num]                   :
      //--- Runtime errors (Charts 4101 - 4116)
      msg_id>4100 && msg_id<4117    ?  messages_runtime_charts[msg_id-4101][m_lang_num]            :
      //--- Runtime errors (Charts 4201 - 4205)
      msg_id>4200 && msg_id<4206    ?  messages_runtime_graph_obj[msg_id-4201][m_lang_num]         :
      //--- Runtime errors (MarketInfo 4301 - 4305)
      msg_id>4300 && msg_id<4306    ?  messages_runtime_market[msg_id-4301][m_lang_num]            :
      //--- Runtime errors (Access to history 4401 - 4407)
      msg_id>4400 && msg_id<4408    ?  messages_runtime_history[msg_id-4401][m_lang_num]           :
      //--- Runtime errors (Global Variables 4501 - 4524)
      msg_id>4500 && msg_id<4525    ?  messages_runtime_global[msg_id-4501][m_lang_num]            :
      //--- Runtime errors (Custom indicators 4601 - 4603)
      msg_id>4600 && msg_id<4604    ?  messages_runtime_custom_indicator[msg_id-4601][m_lang_num]  :
      //--- Runtime errors (Account 4701 - 4758)
      msg_id>4700 && msg_id<4759    ?  messages_runtime_account[msg_id-4701][m_lang_num]           :
      //--- Runtime errors (Indicators 4801 - 4812)
      msg_id>4800 && msg_id<4813    ?  messages_runtime_indicator[msg_id-4801][m_lang_num]         :
      //--- Runtime errors (Market depth 4901 - 4904)
      msg_id>4900 && msg_id<4905    ?  messages_runtime_books[msg_id-4901][m_lang_num]             :
      //--- Runtime errors (File operations 5001 - 5027)
      msg_id>5000 && msg_id<5028    ?  messages_runtime_files[msg_id-5001][m_lang_num]             :
      //--- Runtime errors (Converting strings 5030 - 5044)
      msg_id>5029 && msg_id<5045    ?  messages_runtime_string[msg_id-5030][m_lang_num]            :
      //--- Runtime errors (Working with arrays 5050 - 5063)
      msg_id>5049 && msg_id<5064    ?  messages_runtime_array[msg_id-5050][m_lang_num]             :
      //--- Runtime errors (Working with OpenCL 5100 - 5114)
      msg_id>5099 && msg_id<5115    ?  messages_runtime_opencl[msg_id-5100][m_lang_num]            :
      //--- Runtime errors (Working with databases 5120 - 5130)
      msg_id>5119 && msg_id<5131    ?  messages_runtime_database[msg_id-5120][m_lang_num]          :
      //--- Runtime errors (Working with WebRequest() 5200 - 5203)
      msg_id>5199 && msg_id<5204    ?  messages_runtime_webrequest[msg_id-5200][m_lang_num]        :
      //--- Runtime errors (Working with network (sockets) 5270 - 5275)
      msg_id>5269 && msg_id<5276    ?  messages_runtime_netsocket[msg_id-5270][m_lang_num]         :
      //--- Runtime errors (Custom symbols 5300 - 5310)
      msg_id>5299 && msg_id<5311    ?  messages_runtime_custom_symbol[msg_id-5300][m_lang_num]     :
      //--- Runtime errors (Economic calendar 5400 - 5402)
      msg_id>5399 && msg_id<5403    ?  messages_runtime_calendar[msg_id-5400][m_lang_num]          :
      //--- Runtime errors (Working with databases 5601 - 5626)
      msg_id>5600 && msg_id<5627    ?  messages_runtime_sqlite[msg_id-5601][m_lang_num]            :
      //--- Runtime errors (Matrix and vector methods 5700 - 5706)
      msg_id>5699 && msg_id<5707    ?  messages_runtime_matrix_vector[msg_id-5700][m_lang_num]     :
      //--- Runtime errors (ONNX models 5800 - 5808)
      msg_id>5799 && msg_id<5809    ?  messages_runtime_onnx[msg_id-5800][m_lang_num]              :
      //--- Trade server return codes (10004 - 10045)
      msg_id>10003 && msg_id<10047  ?  messages_ts_ret_code[msg_id-10004][m_lang_num]              :
      //--- Library messages (ERR_USER_ERROR_FIRST)
      msg_id>ERR_USER_ERROR_FIRST-1 ?  messages_library[msg_id-ERR_USER_ERROR_FIRST][m_lang_num]   :
      messages_library[MSG_LIB_SYS_ERROR_CODE_OUT_OF_RANGE-ERR_USER_ERROR_FIRST][m_lang_num]
     );
  }
//+------------------------------------------------------------------+
//| Play an audio file                                               |
//+------------------------------------------------------------------+
bool CMessage::PlaySound(const string file_name)
  {
   if(file_name==NULL)
      return true;
   string pref=(file_name==SND_ALERT       || file_name==SND_ALERT2   || file_name==SND_CONNECT  ||
                file_name==SND_DISCONNECT  || file_name==SND_EMAIL    || file_name==SND_EXPERT   ||
                file_name==SND_NEWS        || file_name==SND_OK       || file_name==SND_REQUEST  ||
                file_name==SND_STOPS       || file_name==SND_TICK     || file_name==SND_TIMEOUT  ||
                file_name==SND_WAIT        ?  "" : "\\Files\\");
   ::ResetLastError();
   bool res=::PlaySound(pref+file_name);
   CMessage::m_global_error=(res ? ERR_SUCCESS : ::GetLastError());
   return res;
  }
//+------------------------------------------------------------------+
//| Stop playing any sound                                           |
//+------------------------------------------------------------------+
bool CMessage::StopPlaySound(void)
  {
   ::ResetLastError();
   bool res=::PlaySound(NULL);
   CMessage::m_global_error=(res ? ERR_SUCCESS : ::GetLastError());
   return res;
  }
//+------------------------------------------------------------------+

 #endif // CMESSAGE_MQH_IMPLEMENTATION
#endif // __MESSAGE_MQH__
