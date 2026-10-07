//+------------------------------------------------------------------+
//|                                                      Message.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
#ifndef __MESSAGE_MQH__
#define __MESSAGE_MQH__
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
//#include "..\..\Defines\Defines.mqh"
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
    static string     m_subject;
    static string     m_text;
    static bool       m_log;
    static bool       m_push;
    static bool       m_mail;
   //--- Get a message from the necessary array by message ID
    static void       GetTextByID(const int msg_id);
   public:
    //--- (1) Display a text message in the journal, send a push notification and e-mail,
    //--- (2) Display a message by ID, send a push notification and e-mail,
    //--- (3) play an audio file
    //--- (4) Stop playing any sound
      static bool       Out(const string text,const bool push=false,const bool mail=false,const string subject=NULL);
      static bool       OutByID(const int msg_id,const bool code=true);
      static bool       PlaySound(const string file_name);
      static bool       StopPlaySound(void);
      //--- Return (1) a message, (2) a code in the "(code)" format
      static string     Text(const int msg_id);
      static string     Retcode(const int msg_id)     { return "("+(string)msg_id+")";    }
    //--- Set (1) the text message language index (0 - user's country language, 1 - English, 2 ... N - added by a user),
    //--- (2) email header,
    //--- the flag of sending messages (3) to the journal, (4) a mobile device, (5) a mailbox
      static void       SetLangNum(const uchar num=0) { CMessage::m_lang_num=num;         }
      static void       SetSubject(const string subj) { CMessage::m_subject=subj;         }
      static void       SetLog(const bool flag)       { CMessage::m_log=flag;             }
      static void       SetPush(const bool flag)      { CMessage::m_push=flag;            }
      static void       SetMail(const bool flag)      { CMessage::m_mail=flag;            }
    //--- (1,2) display a message in the journal by ID, (3) to e-mail, (4) to a mobile device
      static void       ToLog(const int msg_id,const bool code=false);
      static void       ToLog(const string source,const int msg_id,const bool code=false);
      static bool       ToMail(const string message,const string subject=NULL);
      static bool       Push(const string message);
    //--- (1) send a file to FTP, (2) return an error code
      static bool       ToFTP(const string filename,const string ftp_path=NULL);
    //--- Write a debug line to Files/<folder>/Debug_<class_name>.txt (Anhnt, 2026-09-01) -
    //--- reuses this Notify class instead of each class needing its own file-debug method.
      static void       ToFile(const string folder,const string class_name,const string method_name,const string message);
      static int        GetError(void)                { return CMessage::m_global_error;  }
  };
 #endif // CMESSAGE_MQH_DECLARATION
 #ifndef CMESSAGE_MQH_IMPLEMENTATION
 #define CMESSAGE_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Initialization of static variables                               |
//+------------------------------------------------------------------+
  uchar  CMessage::m_lang_num=(::TerminalInfoString(TERMINAL_LANGUAGE)==COUNTRY_LANG ? 0 : 1);
  int    CMessage::m_global_error=ERR_SUCCESS;
  string CMessage::m_subject=::MQLInfoString(MQL_PROGRAM_NAME);
  string CMessage::m_text=NULL;
  bool   CMessage::m_log=true;
  bool   CMessage::m_push=true;
  bool   CMessage::m_mail=false;
//+------------------------------------------------------------------------------+
//| Display a text message in the journal, send a push notification and e-mail   |
//+------------------------------------------------------------------------------+
bool CMessage::Out(const string text,const bool push=false,const bool mail=false,const string subject=NULL)
  {
   bool res=true;
   if(CMessage::m_log)
      ::Print(text);
   if(push)
      res &=CMessage::Push(text);
   if(mail)
      res &=CMessage::ToMail(text,subject);
   return res;
  }
//+------------------------------------------------------------------+
//| Display a message in the journal by ID,                          |
//| send a push notification and an e-mail                           |
//+------------------------------------------------------------------+
bool CMessage::OutByID(const int msg_id,const bool code=true)
  {
   bool res=true;
   if(CMessage::m_log)
      CMessage::ToLog(msg_id,code);
   else
      CMessage::GetTextByID(msg_id);
   if(CMessage::m_push)
      res &=CMessage::Push(CMessage::m_text);
   if(CMessage::m_mail)
      res &=CMessage::ToMail(CMessage::m_text,CMessage::m_subject);
   return res;
  }
//+------------------------------------------------------------------+
//| Display a message in the journal by a message ID                 |
//+------------------------------------------------------------------+
void CMessage::ToLog(const int msg_id,const bool code=false)
  {
   CMessage::GetTextByID(msg_id);
   ::Print(m_text,(!code || msg_id>ERR_USER_ERROR_FIRST-1 ? "" : " "+CMessage::Retcode(msg_id)));
  }
//+------------------------------------------------------------------+
//| Display a message in the journal by a message ID                 |
//+------------------------------------------------------------------+
void CMessage::ToLog(const string source,const int msg_id,const bool code=false)
  {
   CMessage::GetTextByID(msg_id);
   ::Print(source,m_text,(!code || msg_id>ERR_USER_ERROR_FIRST-1 ? "" : " "+CMessage::Retcode(msg_id)));
  }
//+------------------------------------------------------------------+
//| Send an email                                                    |
//+------------------------------------------------------------------+
bool CMessage::ToMail(const string message,const string subject=NULL)
  {
   //--- If sending emails is disabled in the terminal
    if(!::TerminalInfoInteger(TERMINAL_EMAIL_ENABLED))
      {
        //--- display the appropriate message in the journal, write the error code and return 'false'
        CMessage::ToLog(MSG_LIB_TEXT_TERMINAL_NOT_MAIL_ENABLED,false);
        CMessage::m_global_error=ERR_MAIL_SEND_FAILED;
        return false;
      }
   //--- If failed to send a message
    if(!::SendMail(subject==NULL ? CMessage::m_subject : subject,message))
      {
        //--- write an error code, create an error description text, display it in the journal and return 'false'
        CMessage::m_global_error=::GetLastError();
        string txt=CMessage::Text(MSG_LIB_SYS_ERROR)+CMessage::Text(CMessage::m_global_error);
        string code=CMessage::Retcode(CMessage::m_global_error);
        ::Print(txt+" "+code);
        return false;
      }
   //--- Successful - return 'true'
   return true;
  }
//+------------------------------------------------------------------+
//| Send push notifications to a mobile device                       |
//+------------------------------------------------------------------+
bool CMessage::Push(const string message)
  {
   //--- If sending push notifications is not allowed in the terminal
    if(!::TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))
      {
        //--- display the appropriate message in the journal, write the error code and return 'false'
        CMessage::ToLog(MSG_LIB_TEXT_TERMINAL_NOT_PUSH_ENABLED,false);
        CMessage::m_global_error=ERR_NOTIFICATION_SEND_FAILED;
        return false;
      }
    //--- If failed to send a message
    if(!::SendNotification(message))
      {
        //--- write an error code, create an error description text, display it in the journal and return 'false'
        CMessage::m_global_error=::GetLastError();
        string txt=CMessage::Text(MSG_LIB_SYS_ERROR)+CMessage::Text(CMessage::m_global_error);
        string code=CMessage::Retcode(CMessage::m_global_error);
        ::Print(txt+" "+code);
        return false;
      }
    //--- Successful - return 'true'
    return true;
  }
//+------------------------------------------------------------------+
//| Send a file to a specified address                               |
//+------------------------------------------------------------------+
bool CMessage::ToFTP(const string filename,const string ftp_path=NULL)
  {
   //--- If sending files to an FTP server is not allowed in the terminal
    if(!::TerminalInfoInteger(TERMINAL_FTP_ENABLED))
      {
        //--- display the appropriate message in the journal, write the error code and return 'false'
        CMessage::ToLog(MSG_LIB_TEXT_TERMINAL_NOT_FTP_ENABLED,false);
        CMessage::m_global_error=ERR_FTP_SEND_FAILED;
        return false;
      }
   //--- If failed to send a file
   if(!::SendFTP(filename,ftp_path))
     {
      //--- write an error code, create an error description text, display it in the journal and return 'false'
      CMessage::m_global_error=::GetLastError();
      string txt=CMessage::Text(MSG_LIB_SYS_ERROR)+CMessage::Text(CMessage::m_global_error);
      string code=CMessage::Retcode(CMessage::m_global_error);
      ::Print(txt+" "+code);
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Write Debug text to Files/<folder>/Debug_<class_name>.txt        |
//|  Add Since V10 (by Anhnt, 2026-09-01)                            |
//+------------------------------------------------------------------+
void CMessage::ToFile(const string folder,const string class_name,const string method_name,const string message)
  {
   string filepath=(folder!="" ? folder+"/" : "")+"Debug_"+class_name+".txt";
   int fh=::FileOpen(filepath,FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(fh==INVALID_HANDLE)
      return;
   if(::FileSize(fh)>0)
      ::FileSeek(fh,0,SEEK_END);
   ::FileWrite(fh,::TimeToString(::TimeLocal(),TIME_DATE|TIME_SECONDS)+"  "+class_name+"::"+method_name+"  "+message);
   ::FileClose(fh);
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
     #ifdef __MQL5__
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
     
     #else // MQL4
      msg_id>0    && msg_id<10      ?  messages_ts_ret_code_mql4[msg_id][m_lang_num]               :
      msg_id>63   && msg_id<66      ?  messages_ts_ret_code_mql4[msg_id-54][m_lang_num]            :
      msg_id>127  && msg_id<151     ?  messages_ts_ret_code_mql4[msg_id-116][m_lang_num]           :
      msg_id<4000                   ?  messages_ts_ret_code_mql4[26][m_lang_num]                   :
      //--- MQL4 runtime errors (4000 - 4030)
      msg_id<4031                   ?  messages_runtime_4000_4030[msg_id-4000][m_lang_num]         :
      //--- MQL4 runtime errors (4050 - 4075)
      msg_id>4049 && msg_id<4076    ?  messages_runtime_4050_4075[msg_id-4050][m_lang_num]         :
      //--- MQL4 runtime errors (4099 - 4112)
      msg_id>4098 && msg_id<4113    ?  messages_runtime_4099_4112[msg_id-4099][m_lang_num]         :
      //--- MQL4 runtime errors (4200 - 4220)
      msg_id>4199 && msg_id<4221    ?  messages_runtime_4200_4220[msg_id-4200][m_lang_num]         :
      //--- MQL4 runtime errors (4250 - 4266)
      msg_id>4249 && msg_id<4267    ?  messages_runtime_4250_4266[msg_id-4250][m_lang_num]         :
      //--- MQL4 runtime errors (5001 - 5029)
      msg_id>5000 && msg_id<5030    ?  messages_runtime_5001_5029[msg_id-5001][m_lang_num]         :
      //--- MQL4 runtime errors (5200 - 5203)
      msg_id>5199 && msg_id<5204    ?  messages_runtime_5200_5203[msg_id-5200][m_lang_num]         :
     #endif 
      
      //--- Library messages (ERR_USER_ERROR_FIRST)
      msg_id>ERR_USER_ERROR_FIRST-1 ?  messages_library[msg_id-ERR_USER_ERROR_FIRST][m_lang_num]   : 
      messages_library[MSG_LIB_SYS_ERROR_CODE_OUT_OF_RANGE-ERR_USER_ERROR_FIRST][m_lang_num]
     );
  }
//+------------------------------------------------------------------+

 #endif // CMESSAGE_MQH_IMPLEMENTATION
#endif // __MESSAGE_MQH__
