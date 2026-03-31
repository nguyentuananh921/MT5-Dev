//+------------------------------------------------------------------+
//|                                                     Telegram.mqh |
//|                 Telegram Communication Include File              |
//+------------------------------------------------------------------+

//--- Helper to escape special characters in JSON messages
string EscapeJson(string text)
{
   StringReplace(text, "\\", "\\\\");
   StringReplace(text, "\"", "\\\"");
   StringReplace(text, "\n", "\\n");
   StringReplace(text, "\r", "\\r");
   return text;
}

//--- Helper to check if string is empty after trimming whitespace
bool IsEmpty(string text)
{
   string trimmed = text;
   StringTrimRight(trimmed);
   StringTrimLeft(trimmed);
   return trimmed == "";
}

//--- Main Telegram message sender
bool SendMessageToTelegram(string message, string chatId, string botToken)
{
   if (IsEmpty(chatId) || IsEmpty(botToken))
   {
      Print("Telegram Error: Chat ID or Bot Token is missing.");
      return false;
   }

   string url = "https://api.telegram.org/bot" + botToken + "/sendMessage";
   string escapedMessage = EscapeJson(message);
   string jsonMessage = "{\"chat_id\":\"" + chatId + "\", \"text\":\"" + escapedMessage + "\"}";

   char postData[];
   ArrayResize(postData, StringToCharArray(jsonMessage, postData, 0, WHOLE_ARRAY) - 1);

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
