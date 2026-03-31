//+------------------------------------------------------------------+
//|                                          Admin Panel.mq5         |
//|                   Copyright 2024, Clemence Benjamin              |
//|       https://www.mql5.com/en/users/billionaire2024/seller       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Clemence Benjamin"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property description "A responsive Admin Panel. Send messages to your telegram clients without leaving MT5"
#property version   "1.09"

#include <Trade\Trade.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>  // Use CLabel for displaying text

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string QuickMessage1 = "Updates";
input string QuickMessage2 = "Close all";
input string QuickMessage3 = "In deep profits";
input string QuickMessage4 = "Hold position";
input string QuickMessage5 = "Swing Entry";
input string QuickMessage6 = "Scalp Entry";
input string QuickMessage7 = "Book profit";
input string QuickMessage8 = "Invalid Signal";
input string InputChatId = "Enter Chat ID from Telegram bot API";  // User's Telegram chat ID
input string InputBotToken = "Enter BOT TOKEN from your Telegram bot"; // User's Telegram bot token

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
CDialog adminPanel;
CButton sendButton;
CButton clearButton;
CButton minimizeButton;
CButton maximizeButton;
CButton closeButton;
CButton quickMessageButtons[8];
CEdit inputBox;
CLabel charCounter;  // Use CLabel for the character counter
bool minimized = false;
int MAX_MESSAGE_LENGTH = 600;  // Maximum number of characters

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    long chart_id = ChartID();

    // Create the dialog
    if (!adminPanel.Create(chart_id, "Admin Panel", 0, 30, 30, 500, 500))
    {
        Print("Failed to create dialog");
        return INIT_FAILED;
    }

    // Create the input box
    if (!inputBox.Create(chart_id, "InputBox", 0, 5, 5, 460, 75))
    {
        Print("Failed to create input box");
        return INIT_FAILED;
    }
    adminPanel.Add(inputBox);

    // Create the clear button for the input box
    if (!clearButton.Create(chart_id, "ClearButton", 0, 180, 75, 270, 105))
    {
        Print("Failed to create clear button");
        return INIT_FAILED;
    }
    clearButton.Text("Clear");
    adminPanel.Add(clearButton);

    // Create the send button for custom messages
    if (!sendButton.Create(chart_id, "SendButton", 0, 270, 75, 460, 105))
    {
        Print("Failed to create send button");
        return INIT_FAILED;
    }
    sendButton.Text("Send Message");
    adminPanel.Add(sendButton);

    // Create the character counter label
    if (!charCounter.Create(chart_id, "CharCounter", 0, 380, 110, 460, 130))
    {
        Print("Failed to create character counter label");
        return INIT_FAILED;
    }
    charCounter.Text("0/" + IntegerToString(MAX_MESSAGE_LENGTH));
    adminPanel.Add(charCounter);

    // Create the quick message buttons
    string quickMessages[8] = { QuickMessage1, QuickMessage2, QuickMessage3, QuickMessage4, QuickMessage5, QuickMessage6, QuickMessage7, QuickMessage8 };
    int startX = 5, startY = 160, width = 222, height = 65, spacing = 5;

    for (int i = 0; i < 8; i++)
    {
        if (!quickMessageButtons[i].Create(chart_id, "QuickMessageButton" + IntegerToString(i + 1), 0, startX + (i % 2) * (width + spacing), startY + (i / 2) * (height + spacing), startX + (i % 2) * (width + spacing) + width, startY + (i / 2) * (height + spacing) + height))
        {
            Print("Failed to create quick message button ", i + 1);
            return INIT_FAILED;
        }
        quickMessageButtons[i].Text(quickMessages[i]);
        adminPanel.Add(quickMessageButtons[i]);
    }

    adminPanel.Show();
     // Create the minimize button
    if (!minimizeButton.Create(chart_id, "MinimizeButton", 0, 375, -22, 405, 0))
    {
        Print("Failed to create minimize button");
        return INIT_FAILED;
    }
    minimizeButton.Text("_");
    adminPanel.Add(minimizeButton);

    // Create the maximize button
    if (!maximizeButton.Create(chart_id, "MaximizeButton", 0, 405, -22, 435, 0))
    {
        Print("Failed to create maximize button");
        return INIT_FAILED;
    }
    maximizeButton.Text("[ ]");
    adminPanel.Add(maximizeButton);

    // Create the close button
    if (!closeButton.Create(chart_id, "CloseButton", 0, 435, -22, 465, 0))
    {
        Print("Failed to create close button");
        return INIT_FAILED;
    }
    closeButton.Text("X");
    adminPanel.Add(closeButton);

    adminPanel.Show();

    // Enable chart events
    ChartSetInteger(ChartID(), CHART_EVENT_OBJECT_CREATE, true);
    ChartSetInteger(ChartID(), CHART_EVENT_OBJECT_DELETE, true);
    ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_WHEEL, true);
    ChartRedraw();

    Print("Initialization complete");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    adminPanel.Destroy();
    Print("Deinitialization complete");
}

//+------------------------------------------------------------------+
//| Expert event handling function                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    // Handle different types of events
    switch (id)
    {
        case CHARTEVENT_OBJECT_CLICK:
            if (sparam == "SendButton")
            {
                OnSendButtonClick();
            }
            else if (sparam == "ClearButton")
            {
                OnClearButtonClick();
            }
            else if (sparam == "MinimizeButton")
            {
                OnMinimizeButtonClick();
            }
            else if (sparam == "MaximizeButton")
            {
                OnMaximizeButtonClick();
            }
            else if (sparam == "CloseButton")
            {
                OnCloseButtonClick();
            }
            else if (StringFind(sparam, "QuickMessageButton") >= 0)
            {
                int index = StringToInteger(StringSubstr(sparam, StringLen("QuickMessageButton")));
                OnQuickMessageButtonClick(index - 1);
            }
            break;

        case CHARTEVENT_OBJECT_CHANGE:
            if (sparam == "InputBox")
            {
                OnInputChange();
            }
            break;

        default:
            break;
    }
}

//+------------------------------------------------------------------+
//| Function to handle custom message send button click              |
//+------------------------------------------------------------------+
void OnSendButtonClick()
{
    string message = inputBox.Text();
    if (message != "")
    {
        if (SendMessageToTelegram(message))
            Print("Custom message sent: ", message);
        else
            Print("Failed to send custom message.");
    }
    else
    {
        Print("No message entered.");
    }
}

//+------------------------------------------------------------------+
//| Function to handle clear button click                            |
//+------------------------------------------------------------------+
void OnClearButtonClick()
{
    inputBox.Text(""); // Clear the text in the input box
    OnInputChange();   // Update the character counter
    Print("Input box cleared.");
}

//+------------------------------------------------------------------+
//| Function to handle quick message button click                    |
//+------------------------------------------------------------------+
void OnQuickMessageButtonClick(int index)
{
    string quickMessages[8] = { QuickMessage1, QuickMessage2, QuickMessage3, QuickMessage4, QuickMessage5, QuickMessage6, QuickMessage7, QuickMessage8 };
    string message = quickMessages[index];

    if (SendMessageToTelegram(message))
        Print("Quick Message Button Clicked - Quick message sent: ", message);
    else
        Print("Failed to send quick message.");
}

//+------------------------------------------------------------------+
//| Function to update the character counter                         |
//+------------------------------------------------------------------+
void OnInputChange()
{
    string text = inputBox.Text();
    int currentLength = StringLen(text);
    charCounter.Text(IntegerToString(currentLength) + "/" + IntegerToString(MAX_MESSAGE_LENGTH));
}
//+------------------------------------------------------------------+
//| Function to handle minimize button click                         |
//+------------------------------------------------------------------+
void OnMinimizeButtonClick()
{
    minimized = true;

    // Hide the full admin panel
    adminPanel.Hide();
    minimizeButton.Show();
    maximizeButton.Show();
    closeButton.Show();
    
}    

   

//+------------------------------------------------------------------+
//| Function to handle maximize button click                         |
//+------------------------------------------------------------------+
void OnMaximizeButtonClick()
{
    if (minimized)
    {
      

        minimizeButton.Hide();
        maximizeButton.Hide();
        closeButton.Hide();
        adminPanel.Show();
    }
    
}

//+------------------------------------------------------------------+
//| Function to handle close button click                            |
//+------------------------------------------------------------------+
void OnCloseButtonClick()
{
    ExpertRemove(); // Completely remove the EA
    Print("Admin Panel closed.");
}

//+------------------------------------------------------------------+
//| Function to send the message to Telegram                         |
//+------------------------------------------------------------------+
bool SendMessageToTelegram(string message)
{
    // Use the input values for bot token and chat ID
    string botToken = InputBotToken;
    string chatId = InputChatId;

    string url = "https://api.telegram.org/bot" + botToken + "/sendMessage";
    char post_data[];

    // Prepare the message data
    string jsonMessage = "{\"chat_id\":\"" + chatId + "\", \"text\":\"" + message + "\"}";

    // Resize the character array to fit the JSON payload
    ArrayResize(post_data, StringToCharArray(jsonMessage, post_data));

    int timeout = 5000;
    char result[];
    string responseHeaders;

    // Make the WebRequest
    int res = WebRequest("POST", url, "Content-Type: application/json\r\n", timeout, post_data, result, responseHeaders);

    if (res == 200) // HTTP 200 OK
    {
        Print("Message sent successfully: ", message);
        return true;
    }
    else
    {
        Print("Failed to send message. HTTP code: ", res, " Error code: ", GetLastError());
        Print("Response: ", CharArrayToString(result));
        return false;
    }
}
