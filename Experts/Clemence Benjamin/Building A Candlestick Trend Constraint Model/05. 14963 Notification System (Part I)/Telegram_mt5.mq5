//+------------------------------------------------------------------+
//|                                                 Telegram_mt5.mq5 |
//|                                Copyright 2024, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Clemence Benjamin"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void SendTelegramMessage(string chat_id, string message, string bot_token)
{
    string url = "http://your-server-url/send_telegram_message";
    char postData[];
    StringToCharArray("chat_id=" + chat_id + "&message=" + message + "&bot_token=" + bot_token, postData);
    
    char result[];
    int res = WebRequest("POST", url, "", NULL, 0, postData, 0, result, NULL);
    if (res != 200)
    {
        Print("Error sending message: ", GetLastError());
    }
    else
    {
        Print("Message sent successfully.");
    }
}
