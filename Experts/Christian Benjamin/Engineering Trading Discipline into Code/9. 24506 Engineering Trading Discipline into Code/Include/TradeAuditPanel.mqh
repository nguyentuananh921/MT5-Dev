//+------------------------------------------------------------------+
//|                                              TradeAuditPanel.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Christian Benjamin."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.00"
#ifndef TRADE_AUDIT_PANEL_MQH
#define TRADE_AUDIT_PANEL_MQH

#include <Trade Audit/TradeAuditJournal.mqh>

//+------------------------------------------------------------------+
//| Manages the audit panel display and chart controls               |
//+------------------------------------------------------------------+
class CTradeAuditPanel
  {
private:
   string               m_prefix;
   int                  m_x;
   int                  m_y;
   int                  m_periodDays;
   bool                 m_showDetails;
   void                 Label(string name, string text, int x, int y, color clr, int size = 10);
   void                 Button(string name, string text, int x, int y, int width);
   void                 DeleteObjects();
public:
                     CTradeAuditPanel();
   void                 Initialize(int x, int y);
   void                 Update(CTradeAuditJournal &journal, string status);
   bool                 HandleClick(string objectName, CTradeAuditJournal &journal, string &message);
   void                 Shutdown();
  };

//+------------------------------------------------------------------+
//| Sets the initial panel position and period                       |
//+------------------------------------------------------------------+
CTradeAuditPanel::CTradeAuditPanel()
  {
   m_prefix = "AuditPanel_";
   m_x = 10;
   m_y = 30;
   m_periodDays = -1;
   m_showDetails = false;
  }

//+------------------------------------------------------------------+
//| Creates or updates one panel label                               |
//+------------------------------------------------------------------+
void CTradeAuditPanel::Label(string name, string text, int x, int y, color clr, int size)
  {
   string objectName = m_prefix + name;
//--- Remove optional labels instead of exposing the OBJ_LABEL default text
   if(text == "")
     {
      ObjectDelete(0, objectName);
      return;
     }
   if(ObjectFind(0, objectName) < 0)
     {
      ObjectCreate(0, objectName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, objectName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, objectName, OBJPROP_SELECTABLE, false);
      ObjectSetString(0, objectName, OBJPROP_FONT, "Arial");
     }
   ObjectSetInteger(0, objectName, OBJPROP_XDISTANCE, m_x + x);
   ObjectSetInteger(0, objectName, OBJPROP_YDISTANCE, m_y + y);
   ObjectSetInteger(0, objectName, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, objectName, OBJPROP_COLOR, clr);
   ObjectSetString(0, objectName, OBJPROP_TEXT, text);
  }

//+------------------------------------------------------------------+
//| Creates or updates one panel button                              |
//+------------------------------------------------------------------+
void CTradeAuditPanel::Button(string name, string text, int x, int y, int width)
  {
//--- Reuse an existing chart button when the panel refreshes
   string objectName = m_prefix + name;
   if(ObjectFind(0, objectName) < 0)
     {
      ObjectCreate(0, objectName, OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, objectName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, objectName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objectName, OBJPROP_FONTSIZE, 8);
     }
   ObjectSetInteger(0, objectName, OBJPROP_XDISTANCE, m_x + x);
   ObjectSetInteger(0, objectName, OBJPROP_YDISTANCE, m_y + y);
   ObjectSetInteger(0, objectName, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, objectName, OBJPROP_YSIZE, 20);
   ObjectSetString(0, objectName, OBJPROP_TEXT, text);
  }

//+------------------------------------------------------------------+
//| Removes objects belonging to the audit panel                     |
//+------------------------------------------------------------------+
void CTradeAuditPanel::DeleteObjects()
  {
//--- Delete only objects created with this panel prefix
   for(int i = ObjectsTotal(0) - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, m_prefix) == 0)
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//| Creates the panel background and controls                        |
//+------------------------------------------------------------------+
void CTradeAuditPanel::Initialize(int x, int y)
  {
//--- Store the requested corner offsets before creating objects
   m_x = x;
   m_y = y;
   string background = m_prefix + "Background";
   ObjectCreate(0, background, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, background, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, background, OBJPROP_XDISTANCE, m_x);
   ObjectSetInteger(0, background, OBJPROP_YDISTANCE, m_y);
   ObjectSetInteger(0, background, OBJPROP_XSIZE, 420);
   ObjectSetInteger(0, background, OBJPROP_YSIZE, 250);
   ObjectSetInteger(0, background, OBJPROP_BGCOLOR, clrDarkSlateGray);
   ObjectSetInteger(0, background, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, background, OBJPROP_COLOR, clrSilver);
   ObjectSetInteger(0, background, OBJPROP_SELECTABLE, false);
   Button("Today", "TODAY", 10, 38, 62);
   Button("Week", "7 DAYS", 76, 38, 62);
   Button("Month", "30 DAYS", 142, 38, 68);
   Button("All", "ALL", 214, 38, 48);
   Button("Details", "DETAILS", 266, 38, 68);
   Button("Refresh", "REFRESH", 338, 38, 70);
   Button("Export", "EXPORT", 338, 218, 70);
  }

//+------------------------------------------------------------------+
//| Updates totals and the latest meaningful activity                |
//+------------------------------------------------------------------+
void CTradeAuditPanel::Update(CTradeAuditJournal &journal, string status)
  {
//--- Read totals and primary activity from the persistent journal
   int events, violations, liveEvents, recoveredEvents;
   STradeAuditRecord recent[];
   bool readable = journal.GetSummary(m_periodDays, events, violations, liveEvents, recoveredEvents, recent);
   if(!readable)
      status = "Journal error";
   string period = m_periodDays == -1 ? "TODAY" : m_periodDays == 7 ? "7 DAYS" : m_periodDays == 30 ? "30 DAYS" : "ALL";
   Label("Title", "TRADE ACTIVITY AUDITOR", 10, 9, clrWhite, 12);
   Label("Status",
         "Status: " + status + "   |   View: " + period,
         10,
         66,
         status == "Journal error" || status == "History error" || status == "State error" || status == "Account changed - reattach" ? clrTomato : clrLightGreen);
   Label("Totals",
         readable ? StringFormat("Rows: %d   Violations: %d   Live: %d   Recovered: %d", events, violations, liveEvents, recoveredEvents) : "Totals unavailable",
         10,
         88,
         violations > 0 ? clrTomato : clrWhite);
   int y = 116;
   for(int i = 0; i < 3; i++)
     {
      string text = "-";
      color clr = clrSilver;
      if(i < ArraySize(recent))
        {
         string symbol = recent[i].symbol;
         if(StringLen(symbol) > 20)
            symbol = StringSubstr(symbol, 0, 20) + "...";
         text = TimeToString(recent[i].eventTime,
                             TIME_SECONDS) + "  " + AuditActivityText(recent[i].eventType) + "  " + recent[i].source + "  " + symbol;
         clr = recent[i].eventType == AUDIT_POSTTRADE_VIOLATION ? clrTomato : clrWhite;
        }
      Label("Event" + (string) i, text, 10, y + i * 20, clr, 9);
     }
   if(m_showDetails && ArraySize(recent) > 0)
     {
      string reference = recent[0].dealTicket > 0 ? "Deal " + (string) recent[0].dealTicket : "Order " + (string) recent[0].orderTicket;
      Label("Detail", reference + " | " + recent[0].action + " | " + recent[0].note, 10, 182, clrAqua, 9);
     }
   else
      Label("Detail", "", 10, 182, clrWhite, 9);
   Label("Journal", "Journal writes immediately; inspect error status", 10, 222, clrSilver, 8);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Handles period, detail, refresh, and export buttons              |
//+------------------------------------------------------------------+
bool CTradeAuditPanel::HandleClick(string objectName, CTradeAuditJournal &journal, string &message)
  {
//--- Change the selected period or execute the requested panel action
   message = "";
   if(objectName == m_prefix + "Today")
      m_periodDays = -1;
   else
      if(objectName == m_prefix + "Week")
         m_periodDays = 7;
      else
         if(objectName == m_prefix + "Month")
            m_periodDays = 30;
         else
            if(objectName == m_prefix + "All")
               m_periodDays = 0;
            else
               if(objectName == m_prefix + "Details")
                  m_showDetails = !m_showDetails;
               else
                  if(objectName == m_prefix + "Refresh")
                     return(true);
                  else
                     if(objectName == m_prefix + "Export")
                       {
                        string fileName;
                        message = journal.ExportPeriod(m_periodDays,
                                                       fileName) ? "Exported to MQL5/Files/" + fileName : "Export failed";
                       }
                     else
                        return(false);
   return(false);
  }

//+------------------------------------------------------------------+
//| Removes the panel when the EA leaves the chart                   |
//+------------------------------------------------------------------+
void CTradeAuditPanel::Shutdown()
  {
   DeleteObjects();
  }

#endif
//+------------------------------------------------------------------+