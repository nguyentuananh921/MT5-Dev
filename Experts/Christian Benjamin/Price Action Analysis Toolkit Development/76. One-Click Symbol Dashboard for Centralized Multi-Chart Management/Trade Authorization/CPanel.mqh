//+------------------------------------------------------------------+
//|                                                      CPanel.mqh  |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.00"

#ifndef _CPANEL_
#define _CPANEL_

#include "DashboardDefines.mqh"
#include "CSymbolManager.mqh"
#include "CChartManager.mqh"

//+------------------------------------------------------------------+
//| Class CPanel                                                     |
//| Draws and manages the dashboard UI (symbol list, status, buttons)|
//+------------------------------------------------------------------+
class CPanel
  {
private:
   CSymbolManager    *m_symMgr;       // Symbol manager reference
   CChartManager     *m_chartMgr;     // Chart manager reference

   int               m_scrollOffset;  // Current scroll position
   string            m_searchText;    // Last search text
   bool              m_needRedraw;    // Flag to trigger redraw
   int               m_maxRows;       // Number of visible rows

   //--- Status cache to avoid frequent IsOpen() calls
   struct StatusCache
     {
      string         symbol;
      bool           isOpen;
     };
   StatusCache       m_statusCache[];

   //+------------------------------------------------------------------+
   //| Creates a graphical object with standard properties              |
   //+------------------------------------------------------------------+
   bool              CreateObject(string name, ENUM_OBJECT type, int x, int y,
                                  int w, int h, color clr, string text = "",
                                  int fontSize = FONT_SIZE, string tooltip = "");

   //+------------------------------------------------------------------+
   //| Removes all dashboard objects from the chart                     |
   //+------------------------------------------------------------------+
   void              ClearObjects();

   //+------------------------------------------------------------------+
   //| Returns the symbol for the given row index (including scroll)    |
   //+------------------------------------------------------------------+
   string            GetSymbolForRow(int rowIndex);

   //+------------------------------------------------------------------+
   //| Updates the cached open status for a symbol                      |
   //+------------------------------------------------------------------+
   void              UpdateStatusCache(string symbol, bool isOpen);

   //+------------------------------------------------------------------+
   //| Retrieves the cached open status for a symbol                    |
   //+------------------------------------------------------------------+
   bool              GetCachedStatus(string symbol);

   //+------------------------------------------------------------------+
   //| Draws the header row with column labels                          |
   //+------------------------------------------------------------------+
   void              DrawHeader(int y);

   //+------------------------------------------------------------------+
   //| Draws the rows of symbols with status and buttons                |
   //+------------------------------------------------------------------+
   void              DrawRows(int startY);

   //+------------------------------------------------------------------+
   //| Updates the scroll buttons' enabled/disabled state               |
   //+------------------------------------------------------------------+
   void              UpdateScrollButtons();

   //+------------------------------------------------------------------+
   //| Scrolls the list up by one row                                   |
   //+------------------------------------------------------------------+
   void              ScrollUp();

   //+------------------------------------------------------------------+
   //| Scrolls the list down by one row                                 |
   //+------------------------------------------------------------------+
   void              ScrollDown();

public:
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
                     CPanel();

   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
                    ~CPanel();

   //+------------------------------------------------------------------+
   //| Sets the symbol and chart manager references                     |
   //+------------------------------------------------------------------+
   void              SetManagers(CSymbolManager *symMgr, CChartManager *chartMgr);

   //+------------------------------------------------------------------+
   //| Draws the entire dashboard from scratch                          |
   //+------------------------------------------------------------------+
   void              Draw();

   //+------------------------------------------------------------------+
   //| Refreshes the dashboard – updates filter and status              |
   //+------------------------------------------------------------------+
   void              Refresh();

   //+------------------------------------------------------------------+
   //| Handles clicks on dashboard objects                              |
   //+------------------------------------------------------------------+
   void              HandleClick(string objectName);
  };

//+------------------------------------------------------------------+
//| Creates a graphical object with standard properties              |
//+------------------------------------------------------------------+
bool CPanel::CreateObject(string name, ENUM_OBJECT type, int x, int y,
                          int w, int h, color clr, string text,
                          int fontSize, string tooltip)
  {
//--- Delete existing object with same name
   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);
//--- Create the object
   if(!ObjectCreate(0, name, type, 0, 0, 0))
      return false;

//--- Set position
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);

//--- Set size for non-label objects
   if(type != OBJ_LABEL)
     {
      ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
     }

//--- Set color and appearance based on type
   if(type == OBJ_LABEL)
     {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
     }
   else
      if(type == OBJ_BUTTON)
        {
         ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
         ObjectSetInteger(0, name, OBJPROP_COLOR, COLOR_BUTTON_TEXT);
         ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, C'160,160,160');
         ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
        }
      else
         if(type == OBJ_RECTANGLE_LABEL)
           {
            ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
            ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, C'200,200,200');
            ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
            ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
           }
         else
            if(type == OBJ_EDIT)
              {
               ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
               ObjectSetInteger(0, name, OBJPROP_COLOR, COLOR_SEARCH_TEXT);
               ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, COLOR_SEARCH_BORDER);
               ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
               ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
              }

//--- Set text, font, and tooltip
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, FONT_NAME);

   if(tooltip != "")
      ObjectSetString(0, name, OBJPROP_TOOLTIP, tooltip);

   return true;
  }

//+------------------------------------------------------------------+
//| Removes all dashboard objects from the chart                     |
//+------------------------------------------------------------------+
void CPanel::ClearObjects()
  {
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, OBJ_PREFIX) == 0)
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//| Returns the symbol for the given row index (including scroll)    |
//+------------------------------------------------------------------+
string CPanel::GetSymbolForRow(int rowIndex)
  {
   int idx = m_scrollOffset + rowIndex;
   if(idx < 0 || idx >= m_symMgr.GetFilteredCount())
      return("");
   return m_symMgr.GetFilteredSymbol(idx);
  }

//+------------------------------------------------------------------+
//| Updates the cached open status for a symbol                      |
//+------------------------------------------------------------------+
void CPanel::UpdateStatusCache(string symbol, bool isOpen)
  {
//--- Find existing entry and update
   for(int i = 0; i < ArraySize(m_statusCache); i++)
     {
      if(m_statusCache[i].symbol == symbol)
        {
         m_statusCache[i].isOpen = isOpen;
         return;
        }
     }
//--- Add new entry
   int sz = ArraySize(m_statusCache);
   ArrayResize(m_statusCache, sz + 1);
   m_statusCache[sz].symbol = symbol;
   m_statusCache[sz].isOpen = isOpen;
  }

//+------------------------------------------------------------------+
//| Retrieves the cached open status for a symbol                    |
//+------------------------------------------------------------------+
bool CPanel::GetCachedStatus(string symbol)
  {
   for(int i = 0; i < ArraySize(m_statusCache); i++)
      if(m_statusCache[i].symbol == symbol)
         return m_statusCache[i].isOpen;
   return false;
  }

//+------------------------------------------------------------------+
//| Draws the header row with column labels                          |
//+------------------------------------------------------------------+
void CPanel::DrawHeader(int y)
  {
   int sepWidth = PANEL_WIDTH - 10 - 45;
//--- Separator line
   CreateObject(OBJ_PREFIX + "sep", OBJ_RECTANGLE_LABEL, PANEL_X + 5, y - 2,
                sepWidth, 2, COLOR_BORDER, "");

//--- Column labels
   CreateObject(OBJ_PREFIX + "hdr_sym", OBJ_LABEL, PANEL_X + 15, y,
                100, ROW_HEIGHT, COLOR_TITLE, "Symbol", FONT_SIZE, "");
   CreateObject(OBJ_PREFIX + "hdr_status", OBJ_LABEL, PANEL_X + 120, y,
                60, ROW_HEIGHT, COLOR_TITLE, "Status", FONT_SIZE, "");
   CreateObject(OBJ_PREFIX + "hdr_actions", OBJ_LABEL, PANEL_X + 198, y,
                60, ROW_HEIGHT, COLOR_TITLE, "Actions", FONT_SIZE, "");
  }

//+------------------------------------------------------------------+
//| Draws the rows of symbols with status and buttons                |
//+------------------------------------------------------------------+
void CPanel::DrawRows(int startY)
  {
   int filteredCount = m_symMgr.GetFilteredCount();
   int rowsToDraw = MathMin(m_maxRows, filteredCount - m_scrollOffset);
   if(rowsToDraw < 0)
      rowsToDraw = 0;

   for(int row = 0; row < m_maxRows; row++)
     {
      int curY = startY + row * (ROW_HEIGHT + ROW_MARGIN);
      string symbol = GetSymbolForRow(row);
      bool validRow = (symbol != "");

      //--- Row background (alternating colors)
      string bgName = OBJ_PREFIX + "bg_" + IntegerToString(row);
      if(validRow)
        {
         color bg = (row % 2 == 0) ? COLOR_BG : COLOR_HIGHLIGHT;
         CreateObject(bgName, OBJ_RECTANGLE_LABEL, PANEL_X + 5, curY,
                      PANEL_WIDTH - 10, ROW_HEIGHT, bg, "");
        }
      else
        {
         if(ObjectFind(0, bgName) >= 0)
            ObjectDelete(0, bgName);
        }

      //--- Symbol label
      string symName = OBJ_PREFIX + "sym_" + IntegerToString(row);
      if(validRow)
         CreateObject(symName, OBJ_LABEL, PANEL_X + 15, curY + 6,
                      100, ROW_HEIGHT, COLOR_TEXT, symbol, FONT_SIZE, "");
      else
        {
         if(ObjectFind(0, symName) >= 0)
            ObjectDelete(0, symName);
        }

      //--- Status indicator (open/closed)
      string statusName = OBJ_PREFIX + "status_" + IntegerToString(row);
      if(validRow)
        {
         bool isOpen = m_chartMgr.IsOpen(symbol);
         UpdateStatusCache(symbol, isOpen);
         string indicator = isOpen ? "●" : "○";
         color clr = isOpen ? COLOR_OPEN : COLOR_CLOSED;
         CreateObject(statusName, OBJ_LABEL, PANEL_X + 120, curY + 4,
                      STATUS_INDICATOR_WIDTH, ROW_HEIGHT, clr, indicator,
                      FONT_SIZE + 2, isOpen ? "Chart open" : "Chart closed");
        }
      else
        {
         if(ObjectFind(0, statusName) >= 0)
            ObjectDelete(0, statusName);
        }

      //--- Open button
      string openName = OBJ_PREFIX + "open_" + IntegerToString(row);
      if(validRow)
        {
         bool isOpen = m_chartMgr.IsOpen(symbol);
         color btnClr = isOpen ? COLOR_BUTTON : COLOR_OPEN;
         string tip = isOpen ? "Already open" : "Open chart for " + symbol;
         CreateObject(openName, OBJ_BUTTON, PANEL_X + 170, curY + 3,
                      BUTTON_WIDTH, BUTTON_HEIGHT, btnClr, "Open",
                      FONT_SIZE, tip);
         ObjectSetInteger(0, openName, OBJPROP_STATE, false);
         ObjectSetInteger(0, openName, OBJPROP_BGCOLOR, btnClr);
        }
      else
        {
         if(ObjectFind(0, openName) >= 0)
            ObjectDelete(0, openName);
        }

      //--- Close button
      string closeName = OBJ_PREFIX + "close_" + IntegerToString(row);
      if(validRow)
        {
         bool isOpen = m_chartMgr.IsOpen(symbol);
         color btnClr = isOpen ? COLOR_CLOSED : COLOR_BUTTON;
         string tip = isOpen ? "Close chart for " + symbol : "Not open";
         CreateObject(closeName, OBJ_BUTTON, PANEL_X + 170 + BUTTON_WIDTH + 6,
                      curY + 3, BUTTON_WIDTH, BUTTON_HEIGHT, btnClr,
                      "Close", FONT_SIZE, tip);
         ObjectSetInteger(0, closeName, OBJPROP_STATE, false);
         ObjectSetInteger(0, closeName, OBJPROP_BGCOLOR, btnClr);
        }
      else
        {
         if(ObjectFind(0, closeName) >= 0)
            ObjectDelete(0, closeName);
        }
     }

   UpdateScrollButtons();
  }

//+------------------------------------------------------------------+
//| Updates the scroll buttons' enabled/disabled state               |
//+------------------------------------------------------------------+
void CPanel::UpdateScrollButtons()
  {
   int total = m_symMgr.GetFilteredCount();
   bool canUp = (m_scrollOffset > 0);
   bool canDown = (m_scrollOffset + m_maxRows < total);

//--- Up button
   if(ObjectFind(0, OBJ_PREFIX + "scroll_up") >= 0)
     {
      ObjectSetInteger(0, OBJ_PREFIX + "scroll_up", OBJPROP_STATE, false);
      ObjectSetInteger(0, OBJ_PREFIX + "scroll_up", OBJPROP_BGCOLOR,
                       canUp ? COLOR_BUTTON : COLOR_BG);
      ObjectSetInteger(0, OBJ_PREFIX + "scroll_up", OBJPROP_BORDER_COLOR,
                       canUp ? C'160,160,160' : C'200,200,200');
     }
//--- Down button
   if(ObjectFind(0, OBJ_PREFIX + "scroll_down") >= 0)
     {
      ObjectSetInteger(0, OBJ_PREFIX + "scroll_down", OBJPROP_STATE, false);
      ObjectSetInteger(0, OBJ_PREFIX + "scroll_down", OBJPROP_BGCOLOR,
                       canDown ? COLOR_BUTTON : COLOR_BG);
      ObjectSetInteger(0, OBJ_PREFIX + "scroll_down", OBJPROP_BORDER_COLOR,
                       canDown ? C'160,160,160' : C'200,200,200');
     }
  }

//+------------------------------------------------------------------+
//| Scrolls the list up by one row                                   |
//+------------------------------------------------------------------+
void CPanel::ScrollUp()
  {
   if(m_scrollOffset > 0)
     {
      m_scrollOffset--;
      m_needRedraw = true;
     }
  }

//+------------------------------------------------------------------+
//| Scrolls the list down by one row                                 |
//+------------------------------------------------------------------+
void CPanel::ScrollDown()
  {
   int total = m_symMgr.GetFilteredCount();
   if(m_scrollOffset + m_maxRows < total)
     {
      m_scrollOffset++;
      m_needRedraw = true;
     }
  }

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPanel::CPanel() : m_symMgr(NULL), m_chartMgr(NULL),
   m_scrollOffset(0), m_needRedraw(true), m_maxRows(0) {}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPanel::~CPanel() {}

//+------------------------------------------------------------------+
//| Sets the symbol and chart manager references                     |
//+------------------------------------------------------------------+
void CPanel::SetManagers(CSymbolManager *symMgr, CChartManager *chartMgr)
  {
   m_symMgr = symMgr;
   m_chartMgr = chartMgr;
  }

//+------------------------------------------------------------------+
//| Draws the entire dashboard from scratch                          |
//+------------------------------------------------------------------+
void CPanel::Draw()
  {
   ClearObjects();

//--- Main panel background
   CreateObject(OBJ_PREFIX + "bg", OBJ_RECTANGLE_LABEL, PANEL_X, PANEL_Y,
                PANEL_WIDTH, PANEL_HEIGHT, COLOR_BG, "");
   ObjectSetInteger(0, OBJ_PREFIX + "bg", OBJPROP_BORDER_COLOR, COLOR_BORDER);
   ObjectSetInteger(0, OBJ_PREFIX + "bg", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, OBJ_PREFIX + "bg", OBJPROP_WIDTH, 1);

//--- Colored header strip
   int headerHeight = 40;
   CreateObject(OBJ_PREFIX + "header_strip", OBJ_RECTANGLE_LABEL,
                PANEL_X + 1, PANEL_Y + 1, PANEL_WIDTH - 2, headerHeight,
                COLOR_HEADER_BG, "");
   ObjectSetInteger(0, OBJ_PREFIX + "header_strip", OBJPROP_BORDER_COLOR, COLOR_BORDER);
   ObjectSetInteger(0, OBJ_PREFIX + "header_strip", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, OBJ_PREFIX + "header_strip", OBJPROP_WIDTH, 1);

//--- Title
   CreateObject(OBJ_PREFIX + "title", OBJ_LABEL, PANEL_X + 15, PANEL_Y + 10,
                300, 30, COLOR_TITLE, "Multi Chart Dashboard", FONT_TITLE_SIZE, "");

//--- Search box
   int searchY = PANEL_Y + 45;
   CreateObject(OBJ_PREFIX + "search", OBJ_EDIT, PANEL_X + 15, searchY,
                SEARCH_WIDTH, 28, COLOR_SEARCH_BG, "Search symbols...");
   ObjectSetInteger(0, OBJ_PREFIX + "search", OBJPROP_BGCOLOR, COLOR_SEARCH_BG);
   ObjectSetInteger(0, OBJ_PREFIX + "search", OBJPROP_COLOR, COLOR_SEARCH_TEXT);
   ObjectSetString(0, OBJ_PREFIX + "search", OBJPROP_TEXT, "");
   ObjectSetInteger(0, OBJ_PREFIX + "search", OBJPROP_BORDER_COLOR, COLOR_SEARCH_BORDER);
   ObjectSetInteger(0, OBJ_PREFIX + "search", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, OBJ_PREFIX + "search", OBJPROP_WIDTH, 1);

//--- Scroll buttons (up/down)
   int scrollX = PANEL_X + PANEL_WIDTH - 35;
   CreateObject(OBJ_PREFIX + "scroll_up", OBJ_BUTTON, scrollX, searchY,
                24, 24, COLOR_BUTTON, "▲", FONT_SIZE, "Scroll up");
   CreateObject(OBJ_PREFIX + "scroll_down", OBJ_BUTTON, scrollX, searchY + 28,
                24, 24, COLOR_BUTTON, "▼", FONT_SIZE, "Scroll down");

//--- Compute vertical positions for header and rows
   int headerY = searchY + 28 + 10;
   int rowsStartY = headerY + ROW_HEIGHT + 5;

   int availableHeight = PANEL_HEIGHT - (rowsStartY - PANEL_Y) - 10;
   m_maxRows = availableHeight / (ROW_HEIGHT + ROW_MARGIN);
   if(m_maxRows < 1)
      m_maxRows = 1;

//--- Draw header and rows
   DrawHeader(headerY);
   m_searchText = "";
   m_symMgr.Filter("");
   m_scrollOffset = 0;
   DrawRows(rowsStartY);
   m_needRedraw = false;
  }

//+------------------------------------------------------------------+
//| Refreshes the dashboard – updates filter and status              |
//+------------------------------------------------------------------+
void CPanel::Refresh()
  {
   if(!m_symMgr || !m_chartMgr)
      return;

//--- Read search text from edit box
   string currentSearch = "";
   if(ObjectFind(0, OBJ_PREFIX + "search") >= 0)
      currentSearch = ObjectGetString(0, OBJ_PREFIX + "search", OBJPROP_TEXT);
   if(currentSearch != m_searchText)
     {
      m_searchText = currentSearch;
      m_symMgr.Filter(m_searchText);
      if(m_scrollOffset >= m_symMgr.GetFilteredCount())
         m_scrollOffset = MathMax(0, m_symMgr.GetFilteredCount() - m_maxRows);
      m_needRedraw = true;
     }

//--- Check if any open status changed (compare with cache)
   int filteredCount = m_symMgr.GetFilteredCount();
   for(int i = 0; i < MathMin(filteredCount, m_maxRows + m_scrollOffset); i++)
     {
      string sym = m_symMgr.GetFilteredSymbol(i);
      if(sym == "")
         continue;
      bool nowOpen = m_chartMgr.IsOpen(sym);
      bool cached = GetCachedStatus(sym);
      if(nowOpen != cached)
        {
         m_needRedraw = true;
         break;
        }
     }

//--- Redraw if needed
   if(m_needRedraw)
     {
      int searchY = PANEL_Y + 45;
      int headerY = searchY + 28 + 10;
      int rowsStartY = headerY + ROW_HEIGHT + 5;
      DrawRows(rowsStartY);
      m_needRedraw = false;
     }
  }

//+------------------------------------------------------------------+
//| Handles clicks on dashboard objects                              |
//+------------------------------------------------------------------+
void CPanel::HandleClick(string objectName)
  {
//--- Scroll buttons
   if(objectName == OBJ_PREFIX + "scroll_up")
     {
      ScrollUp();
      return;
     }
   if(objectName == OBJ_PREFIX + "scroll_down")
     {
      ScrollDown();
      return;
     }

//--- Parse row index from button names: "DASH_open_3" -> row=3
   int pos = StringFind(objectName, "_");
   if(pos == -1)
      return;
   string suffix = StringSubstr(objectName, pos + 1);
   int row = -1;
   if(StringFind(suffix, "open_") == 0)
      row = (int)StringToInteger(StringSubstr(suffix, 5));
   else
      if(StringFind(suffix, "close_") == 0)
         row = (int)StringToInteger(StringSubstr(suffix, 6));
      else
         return;

   if(row < 0 || row >= m_maxRows)
      return;
   string symbol = GetSymbolForRow(row);
   if(symbol == "")
      return;

//--- Perform action (open or close)
   if(StringFind(objectName, "open_") != -1)
      m_chartMgr.Open(symbol);
   else
      if(StringFind(objectName, "close_") != -1)
         m_chartMgr.Close(symbol);

   m_needRedraw = true;
   Refresh();
  }

#endif
//+------------------------------------------------------------------+