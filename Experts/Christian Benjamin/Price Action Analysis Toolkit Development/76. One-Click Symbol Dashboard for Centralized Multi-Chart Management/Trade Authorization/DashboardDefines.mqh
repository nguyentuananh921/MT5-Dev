//+------------------------------------------------------------------+
//|                                             DashboardDefines.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.00"

#ifndef _DASHBOARD_DEFINES_
#define _DASHBOARD_DEFINES_

//--- Panel geometry: position, size, row spacing
#define PANEL_X             10
#define PANEL_Y             20
#define PANEL_WIDTH         550
#define PANEL_HEIGHT        620
#define ROW_HEIGHT          32
#define ROW_MARGIN          2

//--- Maximum visible rows calculated from available height
#define MAX_VISIBLE_ROWS    ((PANEL_HEIGHT - 110) / (ROW_HEIGHT + ROW_MARGIN))

//--- Controls size
#define BUTTON_WIDTH        55
#define BUTTON_HEIGHT       24
#define SEARCH_WIDTH        220
#define STATUS_INDICATOR_WIDTH 24

//--- Color palette for the dashboard
#define COLOR_BG            C'230,240,250'
#define COLOR_BORDER        C'150,180,210'
#define COLOR_HEADER_BG     C'200,220,240'
#define COLOR_TITLE         C'20,60,100'
#define COLOR_TEXT          C'40,40,40'
#define COLOR_OPEN          C'0,180,0'
#define COLOR_CLOSED        C'200,50,50'
#define COLOR_BUTTON        C'200,200,200'
#define COLOR_BUTTON_TEXT   C'50,50,50'
#define COLOR_HIGHLIGHT     C'240,248,255'
#define COLOR_SEARCH_BG     C'255,255,255'
#define COLOR_SEARCH_TEXT   C'40,40,40'
#define COLOR_SEARCH_BORDER C'160,180,200'

//--- Font settings
#define FONT_NAME           "Segoe UI"
#define FONT_SIZE           10
#define FONT_TITLE_SIZE     12
#define FONT_BOLD           "Segoe UI Bold"

//--- Default timeframe for new charts and object prefix
#define DEFAULT_TIMEFRAME   PERIOD_H1
#define OBJ_PREFIX          "DASH_"

#endif
//+------------------------------------------------------------------+