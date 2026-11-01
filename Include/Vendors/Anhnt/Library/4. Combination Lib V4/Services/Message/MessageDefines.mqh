//+------------------------------------------------------------------+
//|                                                MessageDefines.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//| Lib https://www.mql5.com/en/articles/14710                       |
//+------------------------------------------------------------------+
#ifndef __MESSAGE_DEFINES_MQH__
#define __MESSAGE_DEFINES_MQH__
 //--- Country language (used by CMessage for language detection)
  #define COUNTRY_LANG                   ("Russian")                // Country language
 //--- Standard sounds (used by CMessage::PlaySound and trade notifications, V3)
  #define SND_ALERT                      "alert.wav"
  #define SND_ALERT2                     "alert2.wav"
  #define SND_CONNECT                    "connect.wav"
  #define SND_DISCONNECT                 "disconnect.wav"
  #define SND_EMAIL                      "email.wav"
  #define SND_EXPERT                     "expert.wav"
  #define SND_NEWS                       "news.wav"
  #define SND_OK                         "ok.wav"
  #define SND_REQUEST                    "request.wav"
  #define SND_STOPS                      "stops.wav"
  #define SND_TICK                       "tick.wav"
  #define SND_TIMEOUT                    "timeout.wav"
  #define SND_WAIT                       "wait.wav"
#endif // __MESSAGE_DEFINES_MQH__
