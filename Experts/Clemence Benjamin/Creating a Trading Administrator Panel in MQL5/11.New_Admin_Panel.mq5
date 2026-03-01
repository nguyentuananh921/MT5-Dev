//+------------------------------------------------------------------+
//|                                               New_Admin_Pane.mq5 |
//|                        Copyright 2025, Clemence Benjamin         |
//|                  https://www.mql5.com/en/users/billionaire2024   |
//+------------------------------------------------------------------+
//|             Creating a Trading Administrator Panel in MQL5       |
//|                    XI: Modern feature communications interface   |
//|                        https://www.mql5.com/en/articles/18817    |
//+------------------------------------------------------------------+
#property version   "1.12"
#property strict

// Main-interface resources
#resource "\\Images\\expand.bmp"
#resource "\\Images\\collapse.bmp"
#resource "\\Images\\TradeManagementPanelButton.bmp"
#resource "\\Images\\TradeManagementPanelButtonPressed.bmp"
#resource "\\Images\\CommunicationPanelButton.bmp"
#resource "\\Images\\CommunicationPanelButtonPressed.bmp"
#resource "\\Images\\AnalyticsPanelButton.bmp"
#resource "\\Images\\AnalyticsPanelButtonPressed.bmp"
#resource "\\Images\\ShowAllHideAllButton.bmp"
#resource "\\Images\\ShowAllHideAllButtonPressed.bmp"

input string AuthPassword      = "2024";
input string TwoFactorChatID   = "YOUR_CHAT_ID";
input string TwoFactorBotToken = "YOUR_BOT_TOKEN";

#include "Authentication.mqh"
#include "CommunicationsDialog.mqh"        
#include "Telegram.mqh"
#include <Controls\Dialog.mqh>
#include "TradeManagementPanel.mqh"
#include "AnalyticsPanel.mqh"

// button names
string toggleButtonName    = "ToggleButton";
string tradeButtonName     = "TradeButton";
string commButtonName      = "CommButton";
string analyticsButtonName = "AnalyticsButton";
string showAllButtonName   = "ShowAllButton";

// button coords & hide constant
const int BUTTON_TOGGLE_X    = 10, BUTTON_TOGGLE_Y    = 30;
const int BUTTON_TRADE_X     = 10, BUTTON_TRADE_Y     = 100;
const int BUTTON_COMM_X      = 10, BUTTON_COMM_Y      = 170;
const int BUTTON_ANALYTICS_X = 10, BUTTON_ANALYTICS_Y = 240;
const int BUTTON_SHOWALL_X   = 10, BUTTON_SHOWALL_Y   = 310;
const int HIDDEN_X           = -50;

long g_chart_id=0;
int  g_subwin=0;

CCommunicationDialog *g_commPanel     = NULL;
CTradeManagementPanel *g_tradePanel  = NULL;
CAnalyticsPanel     *g_analyticsPanel= NULL;

// create a bitmap-label button
bool CreateObjectBITMAP_LABEL(string name,int X,int Y,string res1,string res2)
  {
   if(ObjectFind(0,name)==-1 && !ObjectCreate(0,name,OBJ_BITMAP_LABEL,0,0,0))
      return(false);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,Y);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,1000);
   ObjectSetString(0,name,OBJPROP_BMPFILE,0,res1);
   ObjectSetString(0,name,OBJPROP_BMPFILE,1,res2);
   ObjectSetInteger(0,name,OBJPROP_STATE,false);
   return(true);
  }

// show/hide helpers for ToggleInterface
void HideButton(string buttonName)
  { ObjectSetInteger(0,buttonName,OBJPROP_XDISTANCE,HIDDEN_X); }
void ShowButton(string buttonName,int X,int Y)
  {
   ObjectSetInteger(0,buttonName,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(0,buttonName,OBJPROP_YDISTANCE,Y);
  }

// hide all sub-panels
void MinimizeAllPanels()
  {
   if(g_commPanel)      g_commPanel.Hide();
   if(g_tradePanel)     g_tradePanel.Hide();
   if(g_analyticsPanel) g_analyticsPanel.Hide();
  }

// show or hide the four main interface buttons
void UpdateButtonVisibility(bool visible)
  {
   if(visible)
     {
      ShowButton(tradeButtonName,     BUTTON_TRADE_X,     BUTTON_TRADE_Y);
      ShowButton(commButtonName,      BUTTON_COMM_X,      BUTTON_COMM_Y);
      ShowButton(analyticsButtonName, BUTTON_ANALYTICS_X, BUTTON_ANALYTICS_Y);
      ShowButton(showAllButtonName,   BUTTON_SHOWALL_X,   BUTTON_SHOWALL_Y);
     }
   else
     {
      HideButton(tradeButtonName);
      HideButton(commButtonName);
      HideButton(analyticsButtonName);
      HideButton(showAllButtonName);
      MinimizeAllPanels();
     }
   ChartRedraw();
  }

// toggle collapse/expand of the main-interface buttons
void ToggleInterface()
  {
   bool state = ObjectGetInteger(0,toggleButtonName,OBJPROP_STATE);
   ObjectSetInteger(0,toggleButtonName,OBJPROP_STATE,!state);
   UpdateButtonVisibility(!state);
  }

// handle showing/hiding communications panel
void HandleCommunications()
{
   if(g_commPanel)
   {
      if(g_commPanel.IsVisible()) g_commPanel.Hide();
      else                        g_commPanel.Show();
      ChartRedraw();
      return;
   }

   // 1) instantiate
   g_commPanel = new CCommunicationDialog();

   // 2) create its UI
   if(!g_commPanel.CreatePanel(g_chart_id,
                               "CommunicationsPanel",
                               g_subwin,
                               80, 100, 430, 500))
   {
      delete g_commPanel;
      g_commPanel = NULL;
      Print("CommPanel creation failed: ", GetLastError());
      return;
   }

   // 3) (optional) pre-fill Chat-ID & Token fields
   g_commPanel.InitCredentials(TwoFactorChatID, TwoFactorBotToken);

   // 4) show it
   g_commPanel.Show();
   ChartRedraw();
}


// handle showing/hiding trade panel
void HandleTradeManagement()
  {
   if(g_tradePanel)
     {
      if(g_tradePanel.IsVisible()) g_tradePanel.Hide();
      else                         g_tradePanel.Show();
      ChartRedraw();
      return;
     }
   g_tradePanel=new CTradeManagementPanel();
   if(!g_tradePanel.Create(g_chart_id,"TradeManagementPanel",g_subwin,310,20,875,530))
     {
      delete g_tradePanel; g_tradePanel=NULL;
      return;
     }
   g_tradePanel.Show();
   ChartRedraw();
  }

// handle showing/hiding analytics panel
void HandleAnalytics()
  {
   if(g_analyticsPanel)
     {
      if(g_analyticsPanel.IsVisible()) g_analyticsPanel.Hide();
      else                             g_analyticsPanel.Show();
      ChartRedraw();
      return;
     }
   g_analyticsPanel=new CAnalyticsPanel();
   if(!g_analyticsPanel.CreatePanel(g_chart_id,"AnalyticsPanel",g_subwin,900,20,1400,480))
     {
      delete g_analyticsPanel; g_analyticsPanel=NULL;
      return;
     }
   g_analyticsPanel.Show();
   ChartRedraw();
  }

//----------------------------------------------------------------------

int OnInit()
  {
   g_chart_id=ChartID();
   g_subwin  =0;

   // main-interface buttons
   CreateObjectBITMAP_LABEL(toggleButtonName,    BUTTON_TOGGLE_X,    BUTTON_TOGGLE_Y,    "::Images\\expand.bmp","::Images\\collapse.bmp");
   CreateObjectBITMAP_LABEL(tradeButtonName,     BUTTON_TRADE_X,     BUTTON_TRADE_Y,     "::Images\\TradeManagementPanelButton.bmp","::Images\\TradeManagementPanelButtonPressed.bmp");
   CreateObjectBITMAP_LABEL(commButtonName,      BUTTON_COMM_X,      BUTTON_COMM_Y,      "::Images\\CommunicationPanelButton.bmp","::Images\\CommunicationPanelButtonPressed.bmp");
   CreateObjectBITMAP_LABEL(analyticsButtonName, BUTTON_ANALYTICS_X, BUTTON_ANALYTICS_Y, "::Images\\AnalyticsPanelButton.bmp","::Images\\AnalyticsPanelButtonPressed.bmp");
   CreateObjectBITMAP_LABEL(showAllButtonName,   BUTTON_SHOWALL_X,   BUTTON_SHOWALL_Y,   "::Images\\ShowAllHideAllButton.bmp","::Images\\ShowAllHideAllButtonPressed.bmp");

   UpdateButtonVisibility(true);
   ChartRedraw();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   // delete main-interface objects
   string names[5];
   names[0]=toggleButtonName; names[1]=tradeButtonName; names[2]=commButtonName;
   names[3]=analyticsButtonName; names[4]=showAllButtonName;
   for(int i=0;i<5;i++) ObjectDelete(0,names[i]);

   // destroy panels
   if(g_commPanel)     { g_commPanel.Destroy(reason);     delete g_commPanel;     g_commPanel=NULL; }
   if(g_tradePanel)    { g_tradePanel.Destroy(reason);    delete g_tradePanel;    g_tradePanel=NULL; }
   if(g_analyticsPanel){ g_analyticsPanel.Destroy(reason);delete g_analyticsPanel;g_analyticsPanel=NULL; }
  }

void OnTick()
  {
   if(g_analyticsPanel && g_analyticsPanel.IsVisible())
      g_analyticsPanel.UpdatePanel();
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam==toggleButtonName)    ToggleInterface();
      else if(sparam==commButtonName) HandleCommunications();
      else if(sparam==tradeButtonName)HandleTradeManagement();
      else if(sparam==analyticsButtonName)HandleAnalytics();
      else if(sparam==showAllButtonName)
         {
          // your ShowAll/HideAll logic here
         }
     }
   // forward to sub-panels
   if(g_commPanel      && g_commPanel.IsVisible())      g_commPanel.OnEvent(id,lparam,dparam,sparam);
   if(g_tradePanel     && g_tradePanel.IsVisible())     g_tradePanel.OnEvent(id,lparam,dparam,sparam);
   if(g_analyticsPanel && g_analyticsPanel.IsVisible()) g_analyticsPanel.OnEvent(id,lparam,dparam,sparam);
  }
