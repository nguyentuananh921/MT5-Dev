//+------------------------------------------------------------------+
//|                                             Admin Panel.mq5      |
//|                     Copyright 2024, Clemence Benjamin            |
//|     https://www.mql5.com/en/users/billionaire2024/seller         |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Clemence Benjamin"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property description "A responsive Admin Panel. Send messages to your telegram clients without leaving MT5"
#property version   "1.09"

#include <Trade\Trade.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>

// Input parameters
input string QuickMessage1 = "Updates";
input string QuickMessage2 = "Close all";
input string QuickMessage3 = "In deep profits";
input string QuickMessage4 = "Hold position";
input string QuickMessage5 = "Swing Entry";
input string QuickMessage6 = "Scalp Entry";
input string QuickMessage7 = "Book profit";
input string QuickMessage8 = "Invalid Signal";
input string InputChatId = "Enter Chat ID from Telegram bot API";
input string InputBotToken = "Enter BOT TOKEN from your Telegram bot";

// Global variables
CDialog adminPanel;
CButton sendButton, clearButton, changeFontButton, toggleThemeButton;
CButton quickMessageButtons[8], minimizeButton, maximizeButton, closeButton;
CEdit inputBox;
CLabel charCounter;
#define BG_RECT_NAME "BackgroundRect"
bool minimized = false;
bool darkTheme = false;
int MAX_MESSAGE_LENGTH = 4096;
string availableFonts[] = { "Arial", "Courier New", "Verdana", "Times New Roman" };
int currentFontIndex = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialize the Dialog
    if (!adminPanel.Create(ChartID(), "Admin Panel", 0, 30, 30, 500, 500))
    {
        Print("Failed to create dialog");
        return INIT_FAILED;
    }

    // Create controls
    if (!CreateControls())
    {
        Print("Control creation failed");
        return INIT_FAILED;
    }

    adminPanel.Show();
    // Initialize with the default theme
    CreateOrUpdateBackground(ChartID(), darkTheme ? clrBlack : clrWhite);

    Print("Initialization complete");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Create necessary UI controls                                    |
//+------------------------------------------------------------------+
bool CreateControls()
{
    long chart_id = ChartID();

    // Create the input box
    if (!inputBox.Create(chart_id, "InputBox", 0, 5, 25, 460, 95))
    {
        Print("Failed to create input box");
        return false;
    }
    adminPanel.Add(inputBox);

    // Character counter
    if (!charCounter.Create(chart_id, "CharCounter", 0, 380, 5, 460, 25))
    {
        Print("Failed to create character counter");
        return false;
    }
    charCounter.Text("0/" + IntegerToString(MAX_MESSAGE_LENGTH));
    adminPanel.Add(charCounter);

    // Clear button
    if (!clearButton.Create(chart_id, "ClearButton", 0, 235, 95, 345, 125))
    {
        Print("Failed to create clear button");
        return false;
    }
    clearButton.Text("Clear");
    adminPanel.Add(clearButton);

    // Send button
    if (!sendButton.Create(chart_id, "SendButton", 0, 350, 95, 460, 125))
    {
        Print("Failed to create send button");
        return false;
    }
    sendButton.Text("Send");
    adminPanel.Add(sendButton);

    // Change font button
    if (!changeFontButton.Create(chart_id, "ChangeFontButton", 0, 95, 95, 230, 115))
    {
        Print("Failed to create change font button");
        return false;
    }
    changeFontButton.Text("Font<>");
    adminPanel.Add(changeFontButton);

    // Toggle theme button
    if (!toggleThemeButton.Create(chart_id, "ToggleThemeButton", 0, 5, 95, 90, 115))
    {
        Print("Failed to create toggle theme button");
        return false;
    }
    toggleThemeButton.Text("Theme<>");
    adminPanel.Add(toggleThemeButton);

    // Minimize button
    if (!minimizeButton.Create(chart_id, "MinimizeButton", 0, 375, -22, 405, 0))
    {
        Print("Failed to create minimize button");
        return false;
    }
    minimizeButton.Text("_");
    adminPanel.Add(minimizeButton);

    // Maximize button
    if (!maximizeButton.Create(chart_id, "MaximizeButton", 0, 405, -22, 435, 0))
    {
        Print("Failed to create maximize button");
        return false;
    }
    maximizeButton.Text("[ ]");
    adminPanel.Add(maximizeButton);

    // Close button
    if (!closeButton.Create(chart_id, "CloseButton", 0, 435, -22, 465, 0))
    {
        Print("Failed to create close button");
        return false;
    }
    closeButton.Text("X");
    adminPanel.Add(closeButton);

    // Quick messages
    return CreateQuickMessageButtons();
}

//+------------------------------------------------------------------+
//| Create quick message buttons                                     |
//+------------------------------------------------------------------+
bool CreateQuickMessageButtons()
{
    string quickMessages[8] = { QuickMessage1, QuickMessage2, QuickMessage3, QuickMessage4, QuickMessage5, QuickMessage6, QuickMessage7, QuickMessage8 };
    int startX = 5, startY = 160, width = 222, height = 65, spacing = 5;

    for (int i = 0; i < 8; i++)
    {
        if (!quickMessageButtons[i].Create(ChartID(), "QuickMessageButton" + IntegerToString(i + 1), 0, startX + (i % 2) * (width + spacing), startY + (i / 2) * (height + spacing), startX + (i % 2) * (width + spacing) + width, startY + (i / 2) * (height + spacing) + height))
        {
            Print("Failed to create quick message button ", i + 1);
            return false;
        }
        quickMessageButtons[i].Text(quickMessages[i]);
        adminPanel.Add(quickMessageButtons[i]);
    }
    return true;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    adminPanel.Destroy();
    ObjectDelete(ChartID(), BG_RECT_NAME);
    Print("Deinitialization complete");
}

//+------------------------------------------------------------------+
//| Handle chart events                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    switch (id)
    {
        case CHARTEVENT_OBJECT_CLICK:
            if (sparam == "SendButton") OnSendButtonClick();
            else if (sparam == "ClearButton") OnClearButtonClick();
            else if (sparam == "ChangeFontButton") OnChangeFontButtonClick();
            else if (sparam == "ToggleThemeButton") OnToggleThemeButtonClick();
            else if (sparam == "MinimizeButton") OnMinimizeButtonClick();
            else if (sparam == "MaximizeButton") OnMaximizeButtonClick();
            else if (sparam == "CloseButton") OnCloseButtonClick();
            else if (StringFind(sparam, "QuickMessageButton") != -1)
            {
                int index = StringToInteger(StringSubstr(sparam, 18));
                OnQuickMessageButtonClick(index - 1);
            }
            break;

        case CHARTEVENT_OBJECT_ENDEDIT:
            if (sparam == "InputBox") OnInputChange();
            break;
    }
}

//+------------------------------------------------------------------+
//| Handle custom message send button click                          |
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
//| Handle clear button click                                        |
//+------------------------------------------------------------------+
void OnClearButtonClick()
{
    inputBox.Text(""); // Clear the text in the input box
    OnInputChange();   // Update the character counter
    Print("Input box cleared.");
}

//+------------------------------------------------------------------+
//| Handle quick message button click                                |
//+------------------------------------------------------------------+
void OnQuickMessageButtonClick(int index)
{
    string quickMessages[8] = { QuickMessage1, QuickMessage2, QuickMessage3, QuickMessage4, QuickMessage5, QuickMessage6, QuickMessage7, QuickMessage8 };
    string message = quickMessages[index];

    if (SendMessageToTelegram(message))
        Print("Quick message sent: ", message);
    else
        Print("Failed to send quick message.");
}

//+------------------------------------------------------------------+
//| Update character counter                                         |
//+------------------------------------------------------------------+
void OnInputChange()
{
    int currentLength = StringLen(inputBox.Text());
    charCounter.Text(IntegerToString(currentLength) + "/" + IntegerToString(MAX_MESSAGE_LENGTH));
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Handle toggle theme button click                                 |
//+------------------------------------------------------------------+
void OnToggleThemeButtonClick()
{
    darkTheme = !darkTheme;
    color bgColor = darkTheme ? clrBlack : clrWhite;
    color textColor = darkTheme ? clrWhite : clrBlack;

    // Set text color appropriate to the theme
    inputBox.Color(textColor);
    clearButton.Color(textColor);
    sendButton.Color(textColor);
    toggleThemeButton.Color(textColor);
    changeFontButton.Color(textColor);

    for(int i = 0; i < ArraySize(quickMessageButtons); i++)
    {
        quickMessageButtons[i].Color(textColor);
    }

    charCounter.Color(textColor);

    CreateOrUpdateBackground(ChartID(), bgColor);

    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Create and update background rectangle                           |
//+------------------------------------------------------------------+
void CreateOrUpdateBackground(long chart_id, color bgColor)
{
    if (!ObjectFind(chart_id, BG_RECT_NAME))
    {
        if (!ObjectCreate(chart_id, BG_RECT_NAME, OBJ_RECTANGLE, 0, 0, 0))
            Print("Failed to create background rectangle");
    }

    ObjectSetInteger(chart_id, BG_RECT_NAME, OBJPROP_COLOR, bgColor);
    ObjectSetInteger(chart_id, BG_RECT_NAME, OBJPROP_BACK, true);
    ObjectSetInteger(chart_id, BG_RECT_NAME, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(chart_id, BG_RECT_NAME, OBJPROP_SELECTED, false);
    ObjectSetInteger(chart_id, BG_RECT_NAME, OBJPROP_HIDDEN, false);
    ObjectSetInteger(chart_id, BG_RECT_NAME, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(chart_id, BG_RECT_NAME, OBJPROP_XOFFSET, 25); 
    ObjectSetInteger(chart_id, BG_RECT_NAME, OBJPROP_YOFFSET, 25);
}

//+------------------------------------------------------------------+
//| Handle change font button click                                  |
//+------------------------------------------------------------------+
void OnChangeFontButtonClick()
{
    currentFontIndex = (currentFontIndex + 1) % ArraySize(availableFonts);
    
    inputBox.Font(availableFonts[currentFontIndex]);
    clearButton.Font(availableFonts[currentFontIndex]);
    sendButton.Font(availableFonts[currentFontIndex]);
    toggleThemeButton.Font(availableFonts[currentFontIndex]);
    changeFontButton.Font(availableFonts[currentFontIndex]);
    
    for(int i = 0; i < ArraySize(quickMessageButtons); i++)
    {
        quickMessageButtons[i].Font(availableFonts[currentFontIndex]);
    }

    Print("Font changed to: ", availableFonts[currentFontIndex]);
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Handle minimize button click                                     |
//+------------------------------------------------------------------+
void OnMinimizeButtonClick()
{
    minimized = true;
    adminPanel.Hide();
    minimizeButton.Hide();
    maximizeButton.Show();
    closeButton.Show();
    Print("Panel minimized.");
}

//+------------------------------------------------------------------+
//| Handle maximize button click                                     |
//+------------------------------------------------------------------+
void OnMaximizeButtonClick()
{
    if (minimized)
    {
        adminPanel.Show();
        minimizeButton.Show();
        maximizeButton.Hide();
        closeButton.Hide();
        Print("Panel maximized.");
    }
}

//+------------------------------------------------------------------+
//| Handle close button click                                        |
//+------------------------------------------------------------------+
void OnCloseButtonClick()
{
    ExpertRemove(); // Completely remove the EA
    Print("Admin Panel closed.");
}

//+------------------------------------------------------------------+
//| Send the message to Telegram                                     |
//+------------------------------------------------------------------+
bool SendMessageToTelegram(string message)
{
    string url = "https://api.telegram.org/bot" + InputBotToken + "/sendMessage";
    string jsonMessage = "{\"chat_id\":\"" + InputChatId + "\", \"text\":\"" + message + "\"}";
    char post_data[];
    ArrayResize(post_data, StringToCharArray(jsonMessage, post_data, 0, WHOLE_ARRAY) - 1);

    int timeout = 5000;
    char result[];
    string responseHeaders;

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