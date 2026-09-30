//+------------------------------------------------------------------+
//|                                             ChartDashboardEA.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.00"
#property strict

//--- Include all required classes
#include "Include\DashboardDefines.mqh"
#include "Include\CSymbolManager.mqh"
#include "Include\CChartManager.mqh"
#include "Include\CPanel.mqh"

//--- Global instances
CSymbolManager *g_symMgr = NULL;
CChartManager  *g_chartMgr = NULL;
CPanel         *g_panel = NULL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Create and initialize symbol manager
   g_symMgr = new CSymbolManager();
   if(!g_symMgr.Initialize())
     {
      Print("Failed to load symbols");
      return INIT_FAILED;
     }

//--- Create chart manager and panel
   g_chartMgr = new CChartManager();
   g_panel = new CPanel();
   g_panel.SetManagers(g_symMgr, g_chartMgr);
   g_panel.Draw();

//--- Start timer for periodic refresh
   EventSetTimer(1);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Kill timer and clean up objects
   EventKillTimer();
   if(g_panel)
      delete g_panel;
   if(g_chartMgr)
      delete g_chartMgr;
   if(g_symMgr)
      delete g_symMgr;
   ObjectsDeleteAll(0, OBJ_PREFIX);
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- Refresh the panel periodically to update statuses
   if(g_panel)
      g_panel.Refresh();
  }

//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//--- Handle clicks on dashboard objects
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(g_panel)
         g_panel.HandleClick(sparam);
     }

//--- Handle edit finish on the search box
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
     {
      if(StringFind(sparam, OBJ_PREFIX + "search") == 0)
         if(g_panel)
            g_panel.Refresh();
     }
  }
//+------------------------------------------------------------------+
