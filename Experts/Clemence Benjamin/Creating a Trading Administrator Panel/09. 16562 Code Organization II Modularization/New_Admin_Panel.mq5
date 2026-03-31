//+------------------------------------------------------------------+
//|                                                   Admin Pane.mq5 |
//|                                Copyright 2024, Clemence Benjamin |
//|             https://www.mql5.com/en/users/billionaire2024/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Clemence Benjamin"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property version   "1.00"

// Panel coordinate defines
#define MAIN_DIALOG_X        30
#define MAIN_DIALOG_Y        80
#define MAIN_DIALOG_WIDTH    285
#define MAIN_DIALOG_HEIGHT   285

#include "AdminHomeDialog.mqh"
#include <Authentication.mqh>

// Input parameters for authentication
input string TwoFactorChatID = "YOUR_CHAT_ID";
input string TwoFactorBotToken = "YOUR_BOT_TOKEN";
string AuthPassword = "2024";

CAdminHomeDialog ExtDialog;
CAuthenticationManager authManager(AuthPassword, TwoFactorChatID, TwoFactorBotToken);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{  
    if(!authManager.Initialize() || !CreateHiddenPanels())
    {
        Print("Initialization failed");
        return INIT_FAILED;
    }
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    ExtDialog.Destroy(reason);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    authManager.HandleEvent(id, lparam, dparam, sparam);
    
    if(authManager.IsAuthenticated())
    {
        if(!ExtDialog.IsVisible())
        {
            ExtDialog.Show();
            ChartRedraw();
        }
        // Handle dialog events only when authenticated
        ExtDialog.ChartEvent(id, lparam, dparam, sparam);
    }
    else
    {
        if(ExtDialog.IsVisible()) 
        {
            ExtDialog.Hide();
            
        }
    }
}

//+------------------------------------------------------------------+
//| Create hidden panels                                             |
//+------------------------------------------------------------------+
bool CreateHiddenPanels()
{
    bool success = ExtDialog.Create(0, "Admin Home", 0, 
                    MAIN_DIALOG_X, MAIN_DIALOG_Y, 
                    MAIN_DIALOG_X + MAIN_DIALOG_WIDTH, 
                    MAIN_DIALOG_Y + MAIN_DIALOG_HEIGHT);
    if(success) 
    {
        ExtDialog.Hide();
        ChartRedraw();
    }
    return success;
}