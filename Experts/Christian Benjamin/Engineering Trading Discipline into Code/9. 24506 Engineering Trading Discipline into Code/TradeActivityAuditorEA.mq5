//+------------------------------------------------------------------+
//|                                      TradeActivityAuditorEA.mq5  |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.01"
#property strict
#include <Trade Audit/TradeActivityAuditor.mqh>
#include <Trade Audit/TradeAuditPanel.mqh>

//--- Inputs define journal storage and the first recovery window
input string Input_JournalFile = "TradeAudit\\trade_activity_audit_v2";
input string Input_StateFile = "TradeAudit\\trade_activity_audit_v2";
input int Input_RecoveryDays = 30;
//--- An empty list keeps the auditor in observation-only mode
input string Input_AllowedSymbols = "";
//--- Inputs position the audit panel on the chart
input int Input_PanelX = 10;
input int Input_PanelY = 30;
CTradeActivityAuditor * g_auditor = NULL;
CTradeAuditPanel * g_panel = NULL;

//+------------------------------------------------------------------+
//| Initializes the account auditor                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Create the auditor before opening or recovering its journal
   g_auditor = new CTradeActivityAuditor();
   if(g_auditor == NULL ||
      !g_auditor.Initialize(Input_JournalFile, Input_StateFile, Input_AllowedSymbols, Input_RecoveryDays))
     {
      if(g_auditor != NULL)
        {
         delete g_auditor;
         g_auditor = NULL;
        }
      return(INIT_FAILED);
     }
//--- Build the panel only after the journal is available
   g_panel = new CTradeAuditPanel();
   if(g_panel == NULL)
     {
      delete g_auditor;
      g_auditor = NULL;
      return(INIT_FAILED);
     }
   g_panel.Initialize(Input_PanelX, Input_PanelY);
   g_auditor.Recover();
   g_panel.Update(* g_auditor.Journal(), g_auditor.Status());
   EventSetTimer(2);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Releases resources owned by the auditor                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
//--- Release the panel before its journal provider
   if(g_panel != NULL)
     {
      g_panel.Shutdown();
      delete g_panel;
      g_panel = NULL;
     }
   if(g_auditor != NULL)
     {
      delete g_auditor;
      g_auditor = NULL;
     }
  }

//+------------------------------------------------------------------+
//| Receives live account transaction stages                         |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- Store the transaction while the auditor is available
   if(g_auditor == NULL)
      return;
   g_auditor.Capture(trans, request, result);
//--- Display refresh is handled by the existing timer
  }

//+------------------------------------------------------------------+
//| Refreshes on-chart values                                        |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- Refresh the panel without adding journal rows
   if(g_auditor != NULL && g_panel != NULL)
      g_panel.Update(* g_auditor.Journal(), g_auditor.Status());
  }

//+------------------------------------------------------------------+
//| Forwards chart button events to the panel                        |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id != CHARTEVENT_OBJECT_CLICK)
      return;
   if(g_auditor == NULL || g_panel == NULL)
      return;
//--- Let the panel interpret its buttons and selected period
   string message;
   bool refresh = g_panel.HandleClick(sparam, * g_auditor.Journal(), message);
   if(refresh)
      g_auditor.Recover();
   if(message != "")
      Print("[AUDIT] ", message);
   g_panel.Update(* g_auditor.Journal(), g_auditor.Status());
  }

//+------------------------------------------------------------------+