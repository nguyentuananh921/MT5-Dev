//+------------------------------------------------------------------+
//|                                                     Telegram.mqh |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


// Telegram.mqh - Telegram Communication Include File              

bool SendMessageToTelegram(string message, string chatId, string botToken)
  {
   string url = "https://api.telegram.org/bot" + botToken + "/sendMessage";
   string jsonMessage = "{\"chat_id\":\"" + chatId + "\", \"text\":\"" + message + "\"}";

   char postData[];
   ArrayResize(postData, StringToCharArray(jsonMessage, postData) - 1);

   int timeout = 5000;
   char result[];
   string responseHeaders;
   int responseCode = WebRequest("POST", url, "Content-Type: application/json\r\n", timeout, postData, result, responseHeaders);

   if (responseCode == 200)
     {
      Print("Message sent successfully: ", message);
      return true;
     }
   else
     {
      Print("Failed to send message. HTTP code: ", responseCode, " Error code: ", GetLastError());
      Print("Response: ", CharArrayToString(result));
      return false;
     }
  }
//+------------------------------------------------------------------+

