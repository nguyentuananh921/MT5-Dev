//+------------------------------------------------------------------+
//|                                               New_Admin_Pane.mq5 |
//|                                Copyright 2024, Clemence Benjamin |
//|             https://www.mql5.com/en/users/billionaire2024/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Clemence Benjamin"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property version   "1.00"

// Panel coordinate defines
#define MAIN_DIALOG_X        30
#define MAIN_DIALOG_Y        80
#define MAIN_DIALOG_WIDTH    300
#define MAIN_DIALOG_HEIGHT   250

#include "AdminHomeDialog.mqh"
#include <Authentication.mqh>
#include <CommunicationsDialog.mqh>  // Include Communications Panel
#include <Telegram.mqh>

// Input parameters for authentication and Telegram
input string AuthPassword = "2024";
input string TwoFactorChatID = "YOUR_CHAT_ID";
input string TwoFactorBotToken = "YOUR_BOT_TOKEN";

CAdminHomeDialog *ExtDialog;  // Pointer instead of static object
CAuthenticationManager authManager(AuthPassword, TwoFactorChatID, TwoFactorBotToken);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{  
   // Dynamically allocate ExtDialog with chatId and botToken
   ExtDialog = new CAdminHomeDialog(TwoFactorChatID, TwoFactorBotToken);
   
   if(!authManager.Initialize() || !CreateHiddenPanels())
   {
      Print("Initialization failed");
      delete ExtDialog;
      ExtDialog = NULL;
      return INIT_FAILED;
   }
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(ExtDialog != NULL)
   {
      ExtDialog.Destroy(reason);
      delete ExtDialog;
      ExtDialog = NULL;
   }
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
      ExtDialog.OnEvent(id, lparam, dparam, sparam);
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
      ExtDialog.Hide(); // Keep hidden until authentication
      ChartRedraw();
   }
   
   return success;
}