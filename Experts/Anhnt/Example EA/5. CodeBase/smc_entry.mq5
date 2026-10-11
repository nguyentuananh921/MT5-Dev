//+------------------------------------------------------------------+
//|                                MarketStructureScatter.mq5        |
//|                                Made For smc traders              |
//| https://www.mql5.com/en/code/76685                               |
//+------------------------------------------------------------------+
#property copyright "asma"
#property link      "mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 7
#property indicator_plots   3

//--- Plot 1: Candle Heatmap
#property indicator_label1  "Heatmap Open;Heatmap High;Heatmap Low;Heatmap Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- Plot 2: Buy Arrow Entry
#property indicator_label2  "Buy Entry Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  C'0,150,136'
#property indicator_width2  2

//--- Plot 3: Sell Arrow Entry
#property indicator_label3  "Sell Entry Signal"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  C'255,152,0'
#property indicator_width3  2

//--- Enumerations
enum ENUM_HEATMAP_MODE
{
   HEATMAP_COMBINED, // Combined
   HEATMAP_IMPULSE,  // Impulse
   HEATMAP_PULLBACK  // Pullback
};

enum ENUM_COLOR_THEME
{
   THEME_DARK_Israr,  // Dark: Israr Classic (Teal / Amber)
   THEME_DARK_CYBER,    // Dark: Cyber Neon (Cyan / Hot Pink)
   THEME_DARK_EMERALD,  // Dark: Obsidian Emerald (Vivid Green / Ruby)
   THEME_LIGHT_MINT,    // Light: Fresh Mint & Sunset Coral
   THEME_LIGHT_CLASSIC, // Light: Royal Navy & Bright Orange
   THEME_LIGHT_FOREST,  // Light: Forest Green & Deep Rose
   THEME_CUSTOM         // Custom (Manual Color Selection Below)
};

//--- Inputs
input group "=== Color Theme Presets (3 Dark / 3 Light) ==="
input ENUM_COLOR_THEME   InpTheme             = THEME_DARK_Israr;// Color Theme Preset
input color              InpCustomBullColor   = C'0,150,136';      // Custom Bullish Color (if Custom Theme)
input color              InpCustomBearColor   = C'255,152,0';      // Custom Bearish Color (if Custom Theme)

input group "=== Left-Side Dashboard Panel ==="
input bool               InpShowPanel         = true;              // Show Left-Side Multi-TF & Setup Panel
input int                InpPanelX            = 20;                // Panel X Distance (Pixels)
input int                InpPanelY            = 35;                // Panel Y Distance (Pixels)

input group "=== Structure & Heatmap Settings ==="
input int                InpPivotLength       = 8;                // Pivot Length
input bool               InpHeatmap           = true;              // Color Candles via Heatmap
input ENUM_HEATMAP_MODE  InpHeatmapMode       = HEATMAP_PULLBACK;  // Heatmap Mode
input int                InpMaxHistoryBars    = 1200;              // Max Bars to Process (Fast Load / No Freeze)

input group "=== Swing Structure Dots ==="
input bool               InpShowSwingDots     = true;              // Show Dots at Swing Points
input int                InpSwingDotSize      = 7;                 // Swing Dot Size

input group "=== Entry Signals ==="
input bool               InpShowSignals       = true;              // Enable BOS-after-CHoCH Signals
input bool               InpOnlyFirstBOS      = true;              // Signal only on 1st BOS after CHoCH
input bool               InpChochEMAEntry     = true;              // Enable CHoCH + EMA Cross Signals
input int                InpEMAPeriod         = 200;               // EMA Period for Filter/Cross
input string             InpEntryText         = "Entry";           // Text label for Entry

input group "=== Multi-Channel Alerts (Terminal & Mobile Push) ==="
input bool               InpAlertPopup        = true;              // Terminal Popup Alerts
input bool               InpAlertPush         = true;              // Mobile Push Notifications
input bool               InpAlertSound        = true;              // Alert Audio Sound
input bool               InpAlertBreakouts    = true;              // Alert on CHoCH / BOS Breakouts
input bool               InpAlertEntries      = true;              // Alert on Entry (with Full SL/TP/RRR Breakdown)

input group "=== TradingView Risk / Reward Box (Max 3 on Chart) ==="
input bool               InpShowRRBox         = false;              // Show TradingView Style R:R Box
input int                InpMaxRRBoxes        = 3;                 // Display Max Number of R:R Boxes in History

input group "=== Dynamic Trade Tracking & Pip Counter ==="
input bool               InpShowTradeHistory  = true;              // Show Dotted Trade Extension Lines

//--- Constants
#define MAX_HISTORY 80
#define GRADIENT_STEPS 64
#define OBJ_PREFIX "LAMS_"

//--- Indicator Buffers
double BufferOpen[];
double BufferHigh[];
double BufferLow[];
double BufferClose[];
double BufferColors[];
double BufferBuy[];
double BufferSell[];

//--- Internal EMA Calculation Buffer
double BufferEMA[];

//--- Internal Tracking Structure
struct SSMCPoint
{
   double price;
   int    type; // +1 = High, -1 = Low
   int    barIndex;
};

SSMCPoint altPoints[];

//--- Theme Resolved Colors
color bullColor, bearColor, profitBoxColor, lossBoxColor;
color tp1Color, tp2Color, tp3Color, slColor, entryLvlColor;
color swingHColor, swingLColor, winTradeColor, lossTradeColor;
color panelBgColor, panelBorderColor, panelHeaderColor, panelTextColor;

//--- State Variables
double top_y     = EMPTY_VALUE;
int    top_x     = -1;
bool   top_cross = true;

double btm_y     = EMPTY_VALUE;
int    btm_x     = -1;
bool   btm_cross = true;

int    trend     = 0;

// State tracking for BOS after CHoCH
bool   bullChochOccurred = false;
bool   bearChochOccurred = false;
datetime lastBreakAlertTime = 0;
datetime lastEntryAlertTime = 0;

// Dynamic Trade & RRR Engine
bool     activeTrade       = false;
int      tradeDirection    = 0; // +1 = Buy, -1 = Sell
datetime tradeEntryTime    = 0;
double   tradeEntryPrice   = 0.0;
int      tradeEntryBar     = 0;
double   tradeSLPrice      = 0.0;
double   tradeTP1Price     = 0.0;
double   tradeTP2Price     = 0.0;
double   tradeTP3Price     = 0.0;
datetime tradeLastTPTime   = 0;
double   tradeLastTPPrice  = 0.0;
datetime tradePeakTime     = 0;
double   tradePeakPrice    = 0.0;

// Last Setup Details for Left-Side Panel
struct SLastSetupInfo
{
   bool     valid;
   bool     isActive;
   int      direction;
   double   entry;
   double   sl;
   double   tp1;
   double   tp2;
   double   tp3;
   double   pips;
};
SLastSetupInfo lastSetupInfo;

// Track active valid boxes (Max 3 in history)
string   activeBoxKeys[];

//+------------------------------------------------------------------+
//| Formula: Convert Price Difference to Pips (10 Points = 1 Pip)    |
//+------------------------------------------------------------------+
double CalculatePips(const double priceDiff)
{
   if(_Point <= 0.0) return 0.0;
   double points = priceDiff / _Point;
   return (points / 10.0);
}

//+------------------------------------------------------------------+
//| Unified Multi-Channel Alert Dispatcher                           |
//+------------------------------------------------------------------+
void SendNotificationAlert(const string title, const string message)
{
   if(InpAlertPopup)
      Alert(title + "\n" + message);
   if(InpAlertPush)
      SendNotification(title + "\n" + message);
   if(InpAlertSound)
      PlaySound("alert.wav");
}

//+------------------------------------------------------------------+
//| Setup Theme Colors (Optimized for Crystal Readability)           |
//+------------------------------------------------------------------+
void ApplyThemeColors()
{
   switch(InpTheme)
   {
      case THEME_DARK_Israr:
         bullColor        = C'0,150,136';   // Teal
         bearColor        = C'255,152,0';   // Amber
         profitBoxColor   = C'10,40,35';    // Deep Dark Teal (High Contrast Fill)
         lossBoxColor     = C'50,15,15';    // Deep Dark Red (High Contrast Fill)
         tp1Color         = C'140,255,190';
         tp2Color         = C'70,255,160';
         tp3Color         = C'0,255,210';
         slColor          = C'255,100,100';
         entryLvlColor    = clrWhite;
         swingHColor      = bullColor;
         swingLColor      = bearColor;
         winTradeColor    = C'0,230,118';
         lossTradeColor   = C'255,61,0';
         panelBgColor     = C'18,22,25';
         panelBorderColor = C'35,45,50';
         panelHeaderColor = C'0,229,255';
         panelTextColor   = C'220,230,235';
         break;

      case THEME_DARK_CYBER:
         bullColor        = C'0,229,255';   // Neon Cyan
         bearColor        = C'255,23,68';   // Hot Pink
         profitBoxColor   = C'5,35,45';
         lossBoxColor     = C'50,10,20';
         tp1Color         = clrBlack;
         tp2Color         = clrBlack;
         tp3Color         = clrBlack;
         slColor          = clrLavenderBlush;
         entryLvlColor    = clrBlack;
         swingHColor      = bullColor;
         swingLColor      = bearColor;
         winTradeColor    = C'0,229,255';
         lossTradeColor   = C'255,23,68';
         panelBgColor     = C'15,18,30';
         panelBorderColor = C'30,40,65';
         panelHeaderColor = C'0,229,255';
         panelTextColor   = C'225,235,250';
         break;

      case THEME_DARK_EMERALD:
         bullColor        = C'0,230,118';   // Vivid Emerald
         bearColor        = C'213,0,0';     // Ruby
         profitBoxColor   = C'10,40,20';
         lossBoxColor     = C'50,10,10';
         tp1Color         = C'130,255,180';
         tp2Color         = C'0,230,118';
         tp3Color         = C'0,255,140';
         slColor          = C'255,90,90';
         entryLvlColor    = clrWhite;
         swingHColor      = bullColor;
         swingLColor      = bearColor;
         winTradeColor    = C'0,230,118';
         lossTradeColor   = C'213,0,0';
         panelBgColor     = C'15,25,18';
         panelBorderColor = C'25,50,30';
         panelHeaderColor = C'0,230,118';
         panelTextColor   = C'220,240,225';
         break;

      case THEME_LIGHT_MINT:
         bullColor        = C'0,191,165';   // Mint
         bearColor        = C'255,109,0';   // Sunset Coral
         profitBoxColor   = C'210,245,238';
         lossBoxColor     = C'255,225,215';
         tp1Color         = C'0,120,105';
         tp2Color         = C'0,95,80';
         tp3Color         = C'0,70,60';
         slColor          = C'210,50,15';
         entryLvlColor    = clrBlack;
         swingHColor      = C'0,137,123';
         swingLColor      = C'230,81,0';
         winTradeColor    = C'0,150,136';
         lossTradeColor   = C'244,81,30';
         panelBgColor     = C'245,250,248';
         panelBorderColor = C'190,220,210';
         panelHeaderColor = C'0,137,123';
         panelTextColor   = C'35,45,40';
         break;

      case THEME_LIGHT_CLASSIC:
         bullColor        = C'21,101,192';  // Royal Navy Blue
         bearColor        = C'230,81,0';    // Deep Orange
         profitBoxColor   = C'220,235,255';
         lossBoxColor     = C'255,230,210';
         tp1Color         = C'20,95,180';
         tp2Color         = C'15,75,150';
         tp3Color         = C'10,50,120';
         slColor          = C'190,50,10';
         entryLvlColor    = clrBlack;
         swingHColor      = C'21,101,192';
         swingLColor      = C'230,81,0';
         winTradeColor    = C'21,101,192';
         lossTradeColor   = C'230,81,0';
         panelBgColor     = C'245,248,255';
         panelBorderColor = C'195,215,245';
         panelHeaderColor = C'21,101,192';
         panelTextColor   = C'30,40,55';
         break;

      case THEME_LIGHT_FOREST:
         bullColor        = C'46,125,50';   // Forest Green
         bearColor        = C'194,24,91';   // Deep Rose
         profitBoxColor   = C'225,245,225';
         lossBoxColor     = C'255,220,235';
         tp1Color         = C'40,110,45';
         tp2Color         = C'30,90,35';
         tp3Color         = C'20,70,25';
         slColor          = C'170,20,80';
         entryLvlColor    = clrBlack;
         swingHColor      = C'46,125,50';
         swingLColor      = C'194,24,91';
         winTradeColor    = C'46,125,50';
         lossTradeColor   = C'194,24,91';
         panelBgColor     = C'248,250,248';
         panelBorderColor = C'205,225,205';
         panelHeaderColor = C'46,125,50';
         panelTextColor   = C'35,45,35';
         break;

      case THEME_CUSTOM:
      default:
         bullColor        = InpCustomBullColor;
         bearColor        = InpCustomBearColor;
         profitBoxColor   = C'10,40,35';
         lossBoxColor     = C'50,15,15';
         tp1Color         = C'140,255,190';
         tp2Color         = C'70,255,160';
         tp3Color         = C'0,255,210';
         slColor          = C'255,100,100';
         entryLvlColor    = clrWhite;
         swingHColor      = bullColor;
         swingLColor      = bearColor;
         winTradeColor    = C'0,200,83';
         lossTradeColor   = C'255,61,0';
         panelBgColor     = C'18,22,25';
         panelBorderColor = C'35,45,50';
         panelHeaderColor = C'0,229,255';
         panelTextColor   = C'220,230,235';
         break;
   }
}

//+------------------------------------------------------------------+
//| Delete All Objects of an R:R Box Setup                           |
//+------------------------------------------------------------------+
void DeleteTradeBox(const string boxKey)
{
   ObjectDelete(0, OBJ_PREFIX + "RR_TP_BOX_" + boxKey);
   ObjectDelete(0, OBJ_PREFIX + "RR_SL_BOX_" + boxKey);
   ObjectDelete(0, OBJ_PREFIX + "RR_TP1_L_" + boxKey);
   ObjectDelete(0, OBJ_PREFIX + "RR_TP2_L_" + boxKey);
   ObjectDelete(0, OBJ_PREFIX + "RR_TP3_L_" + boxKey);
   ObjectDelete(0, OBJ_PREFIX + "RR_ENT_L_" + boxKey);
   ObjectDelete(0, OBJ_PREFIX + "RR_SL_L_"  + boxKey);
   ObjectDelete(0, OBJ_PREFIX + "RR_TP1_T_" + boxKey);
   ObjectDelete(0, OBJ_PREFIX + "RR_TP2_T_" + boxKey);
   ObjectDelete(0, OBJ_PREFIX + "RR_TP3_T_" + boxKey);
   ObjectDelete(0, OBJ_PREFIX + "RR_ENT_T_" + boxKey);
   ObjectDelete(0, OBJ_PREFIX + "RR_SL_T_"  + boxKey);
}

//+------------------------------------------------------------------+
//| Anti-Flicker Object Helper: Bold Centered Text                   |
//+------------------------------------------------------------------+
void CreateOrUpdateText(const string name, const datetime t, const double p, const string txt, const color clr, const ENUM_ANCHOR_POINT anchor, const int fontSize, const string font = "Arial Bold")
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
   }
   else
   {
      ObjectMove(0, name, 0, t, p);
   }
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
}

//+------------------------------------------------------------------+
//| Anti-Flicker Object Helper: Trend Line                           |
//+------------------------------------------------------------------+
void CreateOrUpdateTrend(const string name, const datetime t1, const double p1, const datetime t2, const double p2, const color clr, const ENUM_LINE_STYLE style, const int width)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
   }
   else
   {
      ObjectMove(0, name, 0, t1, p1);
      ObjectMove(0, name, 1, t2, p2);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
}

//+------------------------------------------------------------------+
//| Anti-Flicker Object Helper: Rectangle Box                        |
//+------------------------------------------------------------------+
void CreateOrUpdateBox(const string name, const datetime t1, const double p1, const datetime t2, const double p2, const color clr, const color bgClr, const int width)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
   }
   else
   {
      ObjectMove(0, name, 0, t1, p1);
      ObjectMove(0, name, 1, t2, p2);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgClr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
}

//+------------------------------------------------------------------+
//| GUI Helper: Label for Dashboard Panel                            |
//+------------------------------------------------------------------+
void CreateOrUpdateUILabel(const string name, int x, int y, string text, color clr, int fontSize, string font="Arial Bold", ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
}

//+------------------------------------------------------------------+
//| GUI Helper: Panel Background Box                                 |
//+------------------------------------------------------------------+
void CreateOrUpdateUIPanel(const string name, int x, int y, int width, int height, color bgClr, color borderClr, ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgClr);
   ObjectSetInteger(0, name, OBJPROP_COLOR, borderClr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
}

//+------------------------------------------------------------------+
//| Multi-Timeframe Structure Calculation Helper                     |
//+------------------------------------------------------------------+
void GetTFStructure(ENUM_TIMEFRAMES tf, string &outType, double &outPrice, color &outColor)
{
   outType  = "Ranging";
   outPrice = 0.0;
   outColor = clrGray;

   int count = InpPivotLength * 5 + 30;
   double h[], l[], c[];
   ArraySetAsSeries(h, true);
   ArraySetAsSeries(l, true);
   ArraySetAsSeries(c, true);

   if(CopyHigh(_Symbol, tf, 0, count, h) <= InpPivotLength * 2 ||
      CopyLow(_Symbol, tf, 0, count, l) <= InpPivotLength * 2 ||
      CopyClose(_Symbol, tf, 0, count, c) <= InpPivotLength * 2)
      return;

   double lastSH = 0.0;
   double lastSL = 0.0;
   int shBar = -1, slBar = -1;

   for(int k = InpPivotLength; k < count - InpPivotLength; k++)
   {
      if(lastSH == 0.0)
      {
         bool isHigh = true;
         for(int j = k - InpPivotLength; j <= k + InpPivotLength; j++)
         {
            if(j != k && h[j] >= h[k]) { isHigh = false; break; }
         }
         if(isHigh) { lastSH = h[k]; shBar = k; }
      }

      if(lastSL == 0.0)
      {
         bool isLow = true;
         for(int j = k - InpPivotLength; j <= k + InpPivotLength; j++)
         {
            if(j != k && l[j] <= l[k]) { isLow = false; break; }
         }
         if(isLow) { lastSL = l[k]; slBar = k; }
      }

      if(lastSH > 0 && lastSL > 0) break;
   }

   if(lastSH > 0 && c[0] > lastSH)
   {
      outType  = "Bullish BOS";
      outPrice = lastSH;
      outColor = bullColor;
   }
   else if(lastSL > 0 && c[0] < lastSL)
   {
      outType  = "Bearish BOS";
      outPrice = lastSL;
      outColor = bearColor;
   }
   else if(shBar != -1 && slBar != -1)
   {
      if(shBar < slBar)
      {
         outType  = "High Formed";
         outPrice = lastSH;
         outColor = bullColor;
      }
      else
      {
         outType  = "Low Formed";
         outPrice = lastSL;
         outColor = bearColor;
      }
   }
}

//+------------------------------------------------------------------+
//| Render Left-Side Multi-TF & Trade Details Dashboard Panel        |
//+------------------------------------------------------------------+
void RenderLeftPanel()
{
   if(!InpShowPanel)
   {
      ObjectsDeleteAll(0, OBJ_PREFIX + "PANEL_");
      return;
   }

   int pX = InpPanelX;
   int pY = InpPanelY;
   int pW = 255;
   int pH = 395;

   // Main Panel Container
   CreateOrUpdateUIPanel(OBJ_PREFIX + "PANEL_BG", pX, pY, pW, pH, panelBgColor, panelBorderColor);

   // Header: Symbol & Live Price
   double liveBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   string headStr = _Symbol + "   |   " + DoubleToString(liveBid, _Digits);
   CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_HEADER", pX + 15, pY + 12, headStr, panelHeaderColor, 10, "Arial Bold");

   // Separator Line 1
   CreateOrUpdateUIPanel(OBJ_PREFIX + "PANEL_SEP1", pX + 12, pY + 36, pW - 24, 1, panelBorderColor, panelBorderColor);

   // Section 1: Multi-Timeframe Structure Header
   CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_MTF_TITLE", pX + 15, pY + 44, "MULTI-TF STRUCTURE", panelTextColor, 8, "Arial Bold");

   ENUM_TIMEFRAMES tfs[5] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1};
   string tfNames[5]      = {"M1", "M5", "M15", "M30", "H1"};
   int curY = pY + 64;

   for(int k = 0; k < 5; k++)
   {
      string sType = "";
      double sPrice = 0.0;
      color  sColor = clrGray;
      GetTFStructure(tfs[k], sType, sPrice, sColor);

      string rowTF = tfNames[k] + ":";
      string rowVal = sType + " " + (sPrice > 0 ? DoubleToString(sPrice, _Digits) : "-");

      CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_TF_" + tfNames[k], pX + 15, curY, rowTF, panelTextColor, 8, "Arial Bold");
      CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_TFS_" + tfNames[k], pX + 55, curY, rowVal, sColor, 8, "Arial");
      curY += 17;
   }

   // Separator Line 2
   curY += 6;
   CreateOrUpdateUIPanel(OBJ_PREFIX + "PANEL_SEP2", pX + 12, curY, pW - 24, 1, panelBorderColor, panelBorderColor);

   // Section 2: Current Trade Details Header
   curY += 8;
   CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_SETUP_TITLE", pX + 15, curY, "CURRENT SETUP DETAILS", panelTextColor, 8, "Arial Bold");
   curY += 20;

   if(lastSetupInfo.valid)
   {
      string statStr = lastSetupInfo.isActive ? "[ ACTIVE ]" : "[ COMPLETED ]";
      color  statClr = lastSetupInfo.isActive ? panelHeaderColor : (lastSetupInfo.pips >= 0 ? winTradeColor : lossTradeColor);
      string dirStr  = (lastSetupInfo.direction == 1) ? "BUY SETUP" : "SELL SETUP";
      color  dirClr  = (lastSetupInfo.direction == 1) ? bullColor : bearColor;

      CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_ST_STAT", pX + 15, curY, "Status: " + statStr, statClr, 8, "Arial Bold");
      curY += 16;
      CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_ST_DIR",  pX + 15, curY, "Direction: " + dirStr, dirClr, 8, "Arial Bold");
      curY += 16;
      CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_ST_ENT",  pX + 15, curY, "Entry: " + DoubleToString(lastSetupInfo.entry, _Digits), entryLvlColor, 8, "Arial");
      curY += 16;

      double rPips  = CalculatePips(MathAbs(lastSetupInfo.entry - lastSetupInfo.sl));
      double tp1P   = CalculatePips(MathAbs(lastSetupInfo.tp1 - lastSetupInfo.entry));
      double tp2P   = CalculatePips(MathAbs(lastSetupInfo.tp2 - lastSetupInfo.entry));
      double tp3P   = CalculatePips(MathAbs(lastSetupInfo.tp3 - lastSetupInfo.entry));

      CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_ST_SL",   pX + 15, curY, "SL: " + DoubleToString(lastSetupInfo.sl, _Digits) + " (-" + DoubleToString(rPips, 1) + "p)", slColor, 8, "Arial");
      curY += 16;
      CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_ST_TP1",  pX + 15, curY, "TP1 (1:1): " + DoubleToString(lastSetupInfo.tp1, _Digits) + " (+" + DoubleToString(tp1P, 1) + "p)", tp1Color, 8, "Arial");
      curY += 16;
      CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_ST_TP2",  pX + 15, curY, "TP2 (1:2): " + DoubleToString(lastSetupInfo.tp2, _Digits) + " (+" + DoubleToString(tp2P, 1) + "p)", tp2Color, 8, "Arial");
      curY += 16;
      CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_ST_TP3",  pX + 15, curY, "TP3 (1:3): " + DoubleToString(lastSetupInfo.tp3, _Digits) + " (+" + DoubleToString(tp3P, 1) + "p)", tp3Color, 8, "Arial");
      curY += 17;

      string pText = (lastSetupInfo.pips >= 0 ? "+" : "") + DoubleToString(lastSetupInfo.pips, 1) + " Pips";
      color  pClr  = (lastSetupInfo.pips >= 0) ? winTradeColor : lossTradeColor;
      CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_ST_PIPS", pX + 15, curY, "Pips Count: " + pText, pClr, 9, "Arial Bold");
   }
   else
   {
      CreateOrUpdateUILabel(OBJ_PREFIX + "PANEL_ST_NONE", pX + 15, curY, "No Trade Setup Detected", clrGray, 8, "Arial Bold");
   }
}

//+------------------------------------------------------------------+
//| Draw / Update TradingView R:R Box with Max 3 History Cap         |
//+------------------------------------------------------------------+
void UpdateRRBox(const string boxKey, datetime startT, datetime endT, double entryP, double slP, double tp1P, double tp2P, double tp3P, int dir)
{
   if(!InpShowRRBox) return;

   bool found = false;
   for(int k = 0; k < ArraySize(activeBoxKeys); k++)
   {
      if(activeBoxKeys[k] == boxKey)
      {
         found = true;
         break;
      }
   }

   if(!found)
   {
      int size = ArraySize(activeBoxKeys);
      ArrayResize(activeBoxKeys, size + 1);
      activeBoxKeys[size] = boxKey;

      if(ArraySize(activeBoxKeys) > InpMaxRRBoxes)
      {
         DeleteTradeBox(activeBoxKeys[0]);
         for(int k = 0; k < ArraySize(activeBoxKeys) - 1; k++)
            activeBoxKeys[k] = activeBoxKeys[k + 1];
         ArrayResize(activeBoxKeys, ArraySize(activeBoxKeys) - 1);
      }
   }

   datetime boxMid = (datetime)(startT + (endT - startT) / 2);
   double risk = MathAbs(entryP - slP);

   double slPips  = CalculatePips(risk);
   double tp1Pips = CalculatePips(1.0 * risk);
   double tp2Pips = CalculatePips(2.0 * risk);
   double tp3Pips = CalculatePips(3.0 * risk);

   if(dir == 1) // BUY
   {
      CreateOrUpdateBox(OBJ_PREFIX + "RR_TP_BOX_" + boxKey, startT, tp3P, endT, entryP, bullColor, profitBoxColor, 1);
      CreateOrUpdateBox(OBJ_PREFIX + "RR_SL_BOX_" + boxKey, startT, entryP, endT, slP, slColor, lossBoxColor, 1);
   }
   else if(dir == -1) // SELL
   {
      CreateOrUpdateBox(OBJ_PREFIX + "RR_TP_BOX_" + boxKey, startT, entryP, endT, tp3P, bullColor, profitBoxColor, 1);
      CreateOrUpdateBox(OBJ_PREFIX + "RR_SL_BOX_" + boxKey, startT, slP, endT, entryP, slColor, lossBoxColor, 1);
   }

   // Horizontal Level Lines
   CreateOrUpdateTrend(OBJ_PREFIX + "RR_TP1_L_" + boxKey, startT, tp1P, endT, tp1P, tp1Color, STYLE_DASH, 1);
   CreateOrUpdateTrend(OBJ_PREFIX + "RR_TP2_L_" + boxKey, startT, tp2P, endT, tp2P, tp2Color, STYLE_DASH, 1);
   CreateOrUpdateTrend(OBJ_PREFIX + "RR_TP3_L_" + boxKey, startT, tp3P, endT, tp3P, tp3Color, STYLE_SOLID, 1);
   CreateOrUpdateTrend(OBJ_PREFIX + "RR_ENT_L_" + boxKey, startT, entryP, endT, entryP, entryLvlColor, STYLE_SOLID, 1);
   CreateOrUpdateTrend(OBJ_PREFIX + "RR_SL_L_"  + boxKey, startT, slP, endT, slP, slColor, STYLE_SOLID, 1);

   // Crystal Readable BOLD Text Labels (Positioned Clearly In Middle of Lines)
   CreateOrUpdateText(OBJ_PREFIX + "RR_TP3_T_" + boxKey, boxMid, tp3P, "★ TP3 (1:3)  +" + DoubleToString(tp3Pips, 1) + " Pips", tp3Color, ANCHOR_CENTER, 8);
   CreateOrUpdateText(OBJ_PREFIX + "RR_TP2_T_" + boxKey, boxMid, tp2P, "TP2 (1:2)  +" + DoubleToString(tp2Pips, 1) + " Pips", tp2Color, ANCHOR_CENTER, 8);
   CreateOrUpdateText(OBJ_PREFIX + "RR_TP1_T_" + boxKey, boxMid, tp1P, "TP1 (1:1)  +" + DoubleToString(tp1Pips, 1) + " Pips", tp1Color, ANCHOR_CENTER, 8);
   CreateOrUpdateText(OBJ_PREFIX + "RR_ENT_T_" + boxKey, boxMid, entryP, "Entry: " + DoubleToString(entryP, _Digits), entryLvlColor, ANCHOR_CENTER, 8);
   CreateOrUpdateText(OBJ_PREFIX + "RR_SL_T_"  + boxKey, boxMid, slP, "SL: -" + DoubleToString(slPips, 1) + " Pips", slColor, ANCHOR_CENTER, 8);
}

//+------------------------------------------------------------------+
//| Dynamic Box End Search (Detects SL Hit to Cancel Display)        |
//+------------------------------------------------------------------+
datetime FindTradeBoxEnd(const datetime &time[], const double &high[], const double &low[], const double &close[],
                         int startIdx, int total, int dir, double sl, double tp1, double tp2, double tp3, bool &slHitNoTP)
{
   datetime endT = time[total - 1];
   int lastTPBar = -1;
   slHitNoTP = false;

   for(int k = startIdx; k < total; k++)
   {
      if(dir == 1) // BUY
      {
         if(high[k] >= tp3)
         {
            endT = time[k];
            return endT;
         }
         if(high[k] >= tp2)
         {
            lastTPBar = k;
         }
         else if(high[k] >= tp1 && lastTPBar == -1)
         {
            lastTPBar = k;
         }

         if(low[k] <= sl)
         {
            if(lastTPBar != -1)
            {
               endT = time[lastTPBar];
            }
            else
            {
               slHitNoTP = true;
               endT = time[k];
            }
            return endT;
         }
      }
      else if(dir == -1) // SELL
      {
         if(low[k] <= tp3)
         {
            endT = time[k];
            return endT;
         }
         if(low[k] <= tp2)
         {
            lastTPBar = k;
         }
         else if(low[k] <= tp1 && lastTPBar == -1)
         {
            lastTPBar = k;
         }

         if(high[k] >= sl)
         {
            if(lastTPBar != -1)
            {
               endT = time[lastTPBar];
            }
            else
            {
               slHitNoTP = true;
               endT = time[k];
            }
            return endT;
         }
      }
   }

   if(endT <= time[startIdx] && startIdx + 3 < total)
      endT = time[startIdx + 3];

   return endT;
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   ApplyThemeColors();

   // Bind candle & color buffers
   SetIndexBuffer(0, BufferOpen,   INDICATOR_DATA);
   SetIndexBuffer(1, BufferHigh,   INDICATOR_DATA);
   SetIndexBuffer(2, BufferLow,    INDICATOR_DATA);
   SetIndexBuffer(3, BufferClose,  INDICATOR_DATA);
   SetIndexBuffer(4, BufferColors, INDICATOR_COLOR_INDEX);

   // Bind Buy/Sell Arrow Buffers
   SetIndexBuffer(5, BufferBuy,    INDICATOR_DATA);
   SetIndexBuffer(6, BufferSell,   INDICATOR_DATA);

   // Setup Arrows (Wingdings: 233 = Up Arrow, 234 = Down Arrow)
   PlotIndexSetInteger(1, PLOT_ARROW, 233);
   PlotIndexSetInteger(2, PLOT_ARROW, 234);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, bullColor);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, bearColor);

   // Configure Dynamic Gradient Palette for DRAW_COLOR_CANDLES
   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, GRADIENT_STEPS);
   for(int i = 0; i < GRADIENT_STEPS; i++)
   {
      double factor = (double)i / (double)(GRADIENT_STEPS - 1);
      color gradColor = InterpColor(bearColor, bullColor, factor);
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, i, gradColor);
   }

   IndicatorSetString(INDICATOR_SHORTNAME, "Israr - MS Panel & RRR Engine");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, OBJ_PREFIX);
}
color InterpColor(color c1, color c2, double factor)
{
   // Clamp factor between 0 and 1
   factor = MathMax(0.0, MathMin(1.0, factor));

   // Extract RGB components
   int r1 = (int)(c1 & 0xFF);
   int g1 = (int)((c1 >> 8) & 0xFF);
   int b1 = (int)((c1 >> 16) & 0xFF);

   int r2 = (int)(c2 & 0xFF);
   int g2 = (int)((c2 >> 8) & 0xFF);
   int b2 = (int)((c2 >> 16) & 0xFF);

   // Interpolate
   int r = (int)(r1 + (r2 - r1) * factor);
   int g = (int)(g1 + (g2 - g1) * factor);
   int b = (int)(b1 + (b2 - b1) * factor);

   return (color)(r | (g << 8) | (b << 16));
}
//+------------------------------------------------------------------+
//| Array Helper Functions                                           |
//+------------------------------------------------------------------+
void PushAltPoint(double price, int type, int barIdx)
{
   int size = ArraySize(altPoints);
   ArrayResize(altPoints, size + 1);
   altPoints[size].price    = price;
   altPoints[size].type     = type;
   altPoints[size].barIndex = barIdx;

   if(ArraySize(altPoints) > MAX_HISTORY)
   {
      for(int i = 0; i < ArraySize(altPoints) - 1; i++)
         altPoints[i] = altPoints[i + 1];
      ArrayResize(altPoints, ArraySize(altPoints) - 1);
   }
}

//+------------------------------------------------------------------+
//| Pivot Detection Helpers                                          |
//+------------------------------------------------------------------+
bool IsPivotHigh(const double &high[], int index, int len, int total)
{
   if(index - len < 0 || index + len >= total) return false;
   double center = high[index];
   for(int i = index - len; i <= index + len; i++)
   {
      if(i != index && high[i] >= center)
         return false;
   }
   return true;
}

bool IsPivotLow(const double &low[], int index, int len, int total)
{
   if(index - len < 0 || index + len >= total) return false;
   double center = low[index];
   for(int i = index - len; i <= index + len; i++)
   {
      if(i != index && low[i] <= center)
         return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Main Calculation Function                                        |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(rates_total < InpPivotLength * 2 + 10)
      return 0;

   // Resize internal EMA buffer
   if(ArraySize(BufferEMA) != rates_total)
      ArrayResize(BufferEMA, rates_total);

   // Anti-Freeze lookback limiter
   int maxLookback = MathMin(rates_total - 1, InpMaxHistoryBars);
   int limitStart  = rates_total - maxLookback;
   if(limitStart < 0) limitStart = 0;

   if(prev_calculated == 0)
   {
      ArrayResize(altPoints, 0);
      ArrayResize(activeBoxKeys, 0);
      top_y = EMPTY_VALUE;
      top_x = -1;
      top_cross = true;
      btm_y = EMPTY_VALUE;
      btm_x = -1;
      btm_cross = true;
      trend = 0;
      bullChochOccurred = false;
      bearChochOccurred = false;
      activeTrade       = false;
      tradeDirection    = 0;
      tradeEntryTime    = 0;
      tradeEntryPrice   = 0.0;
      tradeEntryBar     = 0;
      tradeLastTPTime   = 0;
      tradeLastTPPrice  = 0.0;
      tradePeakTime     = 0;
      tradePeakPrice    = 0.0;
      lastSetupInfo.valid = false;
      ArrayInitialize(BufferBuy, EMPTY_VALUE);
      ArrayInitialize(BufferSell, EMPTY_VALUE);
   }

   int start = (prev_calculated == 0) ? limitStart : prev_calculated - 1;
   if(start < limitStart) start = limitStart;

   // Pre-calculate EMA 200
   double alpha = 2.0 / (InpEMAPeriod + 1.0);
   for(int i = start; i < rates_total; i++)
   {
      if(i == 0 || i == limitStart)
         BufferEMA[i] = close[i];
      else
         BufferEMA[i] = close[i] * alpha + BufferEMA[i - 1] * (1.0 - alpha);
   }

   for(int i = start; i < rates_total; i++)
   {
      BufferBuy[i]  = EMPTY_VALUE;
      BufferSell[i] = EMPTY_VALUE;

      // Feed candle values
      if(InpHeatmap)
      {
         BufferOpen[i]  = open[i];
         BufferHigh[i]  = high[i];
         BufferLow[i]   = low[i];
         BufferClose[i] = close[i];
      }
      else
      {
         BufferOpen[i]  = EMPTY_VALUE;
         BufferHigh[i]  = EMPTY_VALUE;
         BufferLow[i]   = EMPTY_VALUE;
         BufferClose[i] = EMPTY_VALUE;
      }

      // Check for confirmed pivots
      int pIdx = i - InpPivotLength;
      if(pIdx >= InpPivotLength)
      {
         // 1. Swing High Registration & Dot Creation
         if(IsPivotHigh(high, pIdx, InpPivotLength, rates_total))
         {
            double ph = high[pIdx];
            top_y = ph;
            top_x = pIdx;
            top_cross = false;

            int size = ArraySize(altPoints);
            if(size == 0 || altPoints[size - 1].type == -1)
            {
               PushAltPoint(ph, 1, pIdx);
            }
            else if(altPoints[size - 1].type == 1)
            {
               if(ph > altPoints[size - 1].price)
               {
                  altPoints[size - 1].price    = ph;
                  altPoints[size - 1].barIndex = pIdx;
               }
            }

            if(InpShowSwingDots)
            {
               string dotName = OBJ_PREFIX + "SW_H_" + (string)(long)time[pIdx];
               CreateOrUpdateText(dotName, time[pIdx], ph, "●", swingHColor, ANCHOR_CENTER, InpSwingDotSize);
            }

            if(activeTrade && tradeDirection == 1 && pIdx >= tradeEntryBar)
            {
               if(ph >= tradePeakPrice)
               {
                  tradePeakPrice = ph;
                  tradePeakTime  = time[pIdx];
               }
            }
         }

         // 2. Swing Low Registration & Dot Creation
         if(IsPivotLow(low, pIdx, InpPivotLength, rates_total))
         {
            double pl = low[pIdx];
            btm_y = pl;
            btm_x = pIdx;
            btm_cross = false;

            int size = ArraySize(altPoints);
            if(size == 0 || altPoints[size - 1].type == 1)
            {
               PushAltPoint(pl, -1, pIdx);
            }
            else if(altPoints[size - 1].type == -1)
            {
               if(pl < altPoints[size - 1].price)
               {
                  altPoints[size - 1].price    = pl;
                  altPoints[size - 1].barIndex = pIdx;
               }
            }

            if(InpShowSwingDots)
            {
               string dotName = OBJ_PREFIX + "SW_L_" + (string)(long)time[pIdx];
               CreateOrUpdateText(dotName, time[pIdx], pl, "●", swingLColor, ANCHOR_CENTER, InpSwingDotSize);
            }

            if(activeTrade && tradeDirection == -1 && pIdx >= tradeEntryBar)
            {
               if(pl <= tradePeakPrice)
               {
                  tradePeakPrice = pl;
                  tradePeakTime  = time[pIdx];
               }
            }
         }
      }

      // Track running live trade & check TP/SL trims
      if(activeTrade && i >= tradeEntryBar)
      {
         string boxKey = (string)(long)tradeEntryTime;

         if(tradeDirection == 1) // BUY TRADE
         {
            if(high[i] > tradePeakPrice)
            {
               tradePeakPrice = high[i];
               tradePeakTime  = time[i];
            }

            if(high[i] >= tradeTP2Price)
            {
               tradeLastTPTime  = time[i];
               tradeLastTPPrice = tradeTP2Price;
            }
            else if(high[i] >= tradeTP1Price && tradeLastTPTime == 0)
            {
               tradeLastTPTime  = time[i];
               tradeLastTPPrice = tradeTP1Price;
            }

            // 1. Full Target TP3 Hit -> Lock & Trim at TP3 bar
            if(high[i] >= tradeTP3Price)
            {
               UpdateRRBox(boxKey, tradeEntryTime, time[i], tradeEntryPrice, tradeSLPrice, tradeTP1Price, tradeTP2Price, tradeTP3Price, 1);

               ObjectDelete(0, OBJ_PREFIX + "LIVE_TRD_L");
               ObjectDelete(0, OBJ_PREFIX + "LIVE_TRD_T");

               double pips = CalculatePips(tradeTP3Price - tradeEntryPrice);
               string trdLineName = OBJ_PREFIX + "TRD_L_" + (string)(long)tradeEntryTime + "_" + (string)(long)time[i];
               CreateOrUpdateTrend(trdLineName, tradeEntryTime, tradeEntryPrice, time[i], tradeTP3Price, winTradeColor, STYLE_DOT, 1);

               datetime midTime = (datetime)(tradeEntryTime + (time[i] - tradeEntryTime) / 2);
               double   midPrice = (tradeEntryPrice + tradeTP3Price) / 2.0;
               string trdLblName = OBJ_PREFIX + "TRD_T_" + (string)(long)tradeEntryTime + "_" + (string)(long)time[i];
               CreateOrUpdateText(trdLblName, midTime, midPrice, "+" + DoubleToString(pips, 1) + " Pips", winTradeColor, ANCHOR_UPPER, 8);

               lastSetupInfo.isActive = false;
               lastSetupInfo.pips     = pips;
               activeTrade = false;
            }
            // 2. SL Hit -> Remove if direct SL, or trim at last TP if profit was reached
            else if(low[i] <= tradeSLPrice && activeTrade)
            {
               ObjectDelete(0, OBJ_PREFIX + "LIVE_TRD_L");
               ObjectDelete(0, OBJ_PREFIX + "LIVE_TRD_T");

               if(tradeLastTPTime != 0)
               {
                  UpdateRRBox(boxKey, tradeEntryTime, tradeLastTPTime, tradeEntryPrice, tradeSLPrice, tradeTP1Price, tradeTP2Price, tradeTP3Price, 1);

                  double pips = CalculatePips(tradeLastTPPrice - tradeEntryPrice);
                  string trdLineName = OBJ_PREFIX + "TRD_L_" + (string)(long)tradeEntryTime + "_" + (string)(long)tradeLastTPTime;
                  CreateOrUpdateTrend(trdLineName, tradeEntryTime, tradeEntryPrice, tradeLastTPTime, tradeLastTPPrice, winTradeColor, STYLE_DOT, 1);

                  datetime midTime = (datetime)(tradeEntryTime + (tradeLastTPTime - tradeEntryTime) / 2);
                  double   midPrice = (tradeEntryPrice + tradeLastTPPrice) / 2.0;
                  string trdLblName = OBJ_PREFIX + "TRD_T_" + (string)(long)tradeEntryTime + "_" + (string)(long)tradeLastTPTime;
                  CreateOrUpdateText(trdLblName, midTime, midPrice, "+" + DoubleToString(pips, 1) + " Pips", winTradeColor, ANCHOR_UPPER, 8);

                  lastSetupInfo.isActive = false;
                  lastSetupInfo.pips     = pips;
               }
               else
               {
                  DeleteTradeBox(boxKey);
                  lastSetupInfo.valid = false;
               }

               activeTrade = false;
            }
            else if(activeTrade)
            {
               UpdateRRBox(boxKey, tradeEntryTime, time[i], tradeEntryPrice, tradeSLPrice, tradeTP1Price, tradeTP2Price, tradeTP3Price, 1);
               lastSetupInfo.pips = CalculatePips(tradePeakPrice - tradeEntryPrice);
            }
         }
         else if(tradeDirection == -1) // SELL TRADE
         {
            if(low[i] < tradePeakPrice)
            {
               tradePeakPrice = low[i];
               tradePeakTime  = time[i];
            }

            if(low[i] <= tradeTP2Price)
            {
               tradeLastTPTime  = time[i];
               tradeLastTPPrice = tradeTP2Price;
            }
            else if(low[i] <= tradeTP1Price && tradeLastTPTime == 0)
            {
               tradeLastTPTime  = time[i];
               tradeLastTPPrice = tradeTP1Price;
            }

            // 1. Full Target TP3 Hit -> Lock & Trim at TP3 bar
            if(low[i] <= tradeTP3Price)
            {
               UpdateRRBox(boxKey, tradeEntryTime, time[i], tradeEntryPrice, tradeSLPrice, tradeTP1Price, tradeTP2Price, tradeTP3Price, -1);

               ObjectDelete(0, OBJ_PREFIX + "LIVE_TRD_L");
               ObjectDelete(0, OBJ_PREFIX + "LIVE_TRD_T");

               double pips = CalculatePips(tradeEntryPrice - tradeTP3Price);
               string trdLineName = OBJ_PREFIX + "TRD_L_" + (string)(long)tradeEntryTime + "_" + (string)(long)time[i];
               CreateOrUpdateTrend(trdLineName, tradeEntryTime, tradeEntryPrice, time[i], tradeTP3Price, winTradeColor, STYLE_DOT, 1);

               datetime midTime = (datetime)(tradeEntryTime + (time[i] - tradeEntryTime) / 2);
               double   midPrice = (tradeEntryPrice + tradeTP3Price) / 2.0;
               string trdLblName = OBJ_PREFIX + "TRD_T_" + (string)(long)tradeEntryTime + "_" + (string)(long)time[i];
               CreateOrUpdateText(trdLblName, midTime, midPrice, "+" + DoubleToString(pips, 1) + " Pips", winTradeColor, ANCHOR_LOWER, 8);

               lastSetupInfo.isActive = false;
               lastSetupInfo.pips     = pips;
               activeTrade = false;
            }
            // 2. SL Hit -> Remove if direct SL, or trim at last TP if profit was reached
            else if(high[i] >= tradeSLPrice && activeTrade)
            {
               ObjectDelete(0, OBJ_PREFIX + "LIVE_TRD_L");
               ObjectDelete(0, OBJ_PREFIX + "LIVE_TRD_T");

               if(tradeLastTPTime != 0)
               {
                  UpdateRRBox(boxKey, tradeEntryTime, tradeLastTPTime, tradeEntryPrice, tradeSLPrice, tradeTP1Price, tradeTP2Price, tradeTP3Price, -1);

                  double pips = CalculatePips(tradeEntryPrice - tradeLastTPPrice);
                  string trdLineName = OBJ_PREFIX + "TRD_L_" + (string)(long)tradeEntryTime + "_" + (string)(long)tradeLastTPTime;
                  CreateOrUpdateTrend(trdLineName, tradeEntryTime, tradeEntryPrice, tradeLastTPTime, tradeLastTPPrice, winTradeColor, STYLE_DOT, 1);

                  datetime midTime = (datetime)(tradeEntryTime + (tradeLastTPTime - tradeEntryTime) / 2);
                  double   midPrice = (tradeEntryPrice + tradeLastTPPrice) / 2.0;
                  string trdLblName = OBJ_PREFIX + "TRD_T_" + (string)(long)tradeEntryTime + "_" + (string)(long)tradeLastTPTime;
                  CreateOrUpdateText(trdLblName, midTime, midPrice, "+" + DoubleToString(pips, 1) + " Pips", winTradeColor, ANCHOR_LOWER, 8);

                  lastSetupInfo.isActive = false;
                  lastSetupInfo.pips     = pips;
               }
               else
               {
                  DeleteTradeBox(boxKey);
                  lastSetupInfo.valid = false;
               }

               activeTrade = false;
            }
            else if(activeTrade)
            {
               UpdateRRBox(boxKey, tradeEntryTime, time[i], tradeEntryPrice, tradeSLPrice, tradeTP1Price, tradeTP2Price, tradeTP3Price, -1);
               lastSetupInfo.pips = CalculatePips(tradeEntryPrice - tradePeakPrice);
            }
         }
      }

      // Dynamic spacing based on volatility
      double avgRange = 0.0;
      int rCount = 0;
      for(int r = MathMax(0, i - 14); r <= i; r++)
      {
         avgRange += (high[r] - low[r]);
         rCount++;
      }
      avgRange = (rCount > 0) ? (avgRange / rCount) : (high[i] - low[i]);
      if(avgRange <= 0) avgRange = 25 * _Point;

      double arrowOffset = avgRange * 0.35;
      double textOffset  = avgRange * 0.95;

      // 3. SMC Breakout Detection & Signals
      if(top_y != EMPTY_VALUE && close[i] > top_y && !top_cross)
      {
         top_cross = true;
         bool isChoch = (trend <= 0);
         trend = 1;
         string txt = isChoch ? "CHoCH" : "BOS";
         bool triggerBuy = false;

         // CHoCH / BOS Breakout Alert
         if(InpAlertBreakouts && i == rates_total - 1 && time[i] != lastBreakAlertTime)
         {
            string bTitle = _Symbol + " [" + EnumToString((ENUM_TIMEFRAMES)_Period) + "] " + txt + " ALERT";
            string bMsg   = "Symbol=" + _Symbol + " TF=" + EnumToString((ENUM_TIMEFRAMES)_Period) +
                            " Event=" + txt + " Direction=BULLISH Price=" + DoubleToString(close[i], _Digits);
            SendNotificationAlert(bTitle, bMsg);
            lastBreakAlertTime = time[i];
         }

         if(isChoch)
         {
            bullChochOccurred = true;
            bearChochOccurred = false;

            if(activeTrade && tradeDirection == -1 && InpShowTradeHistory)
            {
               string prevBoxKey = (string)(long)tradeEntryTime;
               datetime trimTime = (tradeLastTPTime != 0) ? tradeLastTPTime : time[i];
               UpdateRRBox(prevBoxKey, tradeEntryTime, trimTime, tradeEntryPrice, tradeSLPrice, tradeTP1Price, tradeTP2Price, tradeTP3Price, -1);

               ObjectDelete(0, OBJ_PREFIX + "LIVE_TRD_L");
               ObjectDelete(0, OBJ_PREFIX + "LIVE_TRD_T");

               double pips = CalculatePips(tradeEntryPrice - tradePeakPrice);
               color trdColor = (pips >= 0) ? winTradeColor : lossTradeColor;
               string pipsTxt = (pips >= 0 ? "+" : "") + DoubleToString(pips, 1) + " Pips";

               string trdLineName = OBJ_PREFIX + "TRD_L_" + (string)(long)tradeEntryTime + "_" + (string)(long)tradePeakTime;
               CreateOrUpdateTrend(trdLineName, tradeEntryTime, tradeEntryPrice, tradePeakTime, tradePeakPrice, trdColor, STYLE_DOT, 1);

               datetime midTime = (datetime)(tradeEntryTime + (tradePeakTime - tradeEntryTime) / 2);
               double   midPrice = (tradeEntryPrice + tradePeakPrice) / 2.0;

               string trdLblName = OBJ_PREFIX + "TRD_T_" + (string)(long)tradeEntryTime + "_" + (string)(long)tradePeakTime;
               CreateOrUpdateText(trdLblName, midTime, midPrice, pipsTxt, trdColor, ANCHOR_LOWER, 8);

               lastSetupInfo.isActive = false;
               lastSetupInfo.pips     = pips;
               activeTrade = false;
            }

            if(InpChochEMAEntry && i > 0)
            {
               bool emaBullCross = (close[i] > BufferEMA[i] && (close[i - 1] <= BufferEMA[i - 1] || open[i] <= BufferEMA[i] || low[i] <= BufferEMA[i]));
               if(emaBullCross)
                  triggerBuy = true;
            }
         }
         else
         {
            if(bullChochOccurred && InpShowSignals)
            {
               triggerBuy = true;
               if(InpOnlyFirstBOS)
                  bullChochOccurred = false;
            }
         }

         // Draw Buy Signal & Process R:R Box
         if(triggerBuy)
         {
            BufferBuy[i] = low[i] - arrowOffset;

            string entryName = OBJ_PREFIX + "ENT_B_" + (string)(long)time[i];
            CreateOrUpdateText(entryName, time[i], low[i] - textOffset, InpEntryText, bullColor, ANCHOR_UPPER, 8);

            double slPrice = (btm_y != EMPTY_VALUE) ? btm_y : low[i];
            if(top_x >= 0 && top_x < i)
            {
               double minL = low[i];
               for(int k = top_x; k <= i; k++)
               {
                  if(low[k] < minL) minL = low[k];
               }
               slPrice = minL;
            }
            if(slPrice >= close[i]) slPrice = close[i] - (avgRange * 1.5);

            double risk = close[i] - slPrice;
            double tp1  = close[i] + 1.0 * risk;
            double tp2  = close[i] + 2.0 * risk;
            double tp3  = close[i] + 3.0 * risk;

            bool isDirectSL = false;
            datetime boxEnd = FindTradeBoxEnd(time, high, low, close, i, rates_total, 1, slPrice, tp1, tp2, tp3, isDirectSL);

            if(!isDirectSL)
            {
               UpdateRRBox((string)(long)time[i], time[i], boxEnd, close[i], slPrice, tp1, tp2, tp3, 1);

               activeTrade      = true;
               tradeDirection   = 1;
               tradeEntryTime   = time[i];
               tradeEntryPrice  = close[i];
               tradeEntryBar    = i;
               tradeSLPrice     = slPrice;
               tradeTP1Price    = tp1;
               tradeTP2Price    = tp2;
               tradeTP3Price    = tp3;
               tradeLastTPTime  = 0;
               tradeLastTPPrice = 0.0;
               tradePeakTime    = time[i];
               tradePeakPrice   = high[i];

               lastSetupInfo.valid     = true;
               lastSetupInfo.isActive  = true;
               lastSetupInfo.direction = 1;
               lastSetupInfo.entry     = close[i];
               lastSetupInfo.sl        = slPrice;
               lastSetupInfo.tp1       = tp1;
               lastSetupInfo.tp2       = tp2;
               lastSetupInfo.tp3       = tp3;
               lastSetupInfo.pips      = 0.0;
            }
            else
            {
               DeleteTradeBox((string)(long)time[i]);
            }

            // Structured Trade Entry Alert
            if(InpAlertEntries && i == rates_total - 1 && time[i] != lastEntryAlertTime)
            {
               double riskPips = CalculatePips(risk);
               double tp1Pips  = CalculatePips(1.0 * risk);
               double tp2Pips  = CalculatePips(2.0 * risk);
               double tp3Pips  = CalculatePips(3.0 * risk);

               string aTitle = _Symbol + " [" + EnumToString((ENUM_TIMEFRAMES)_Period) + "] BUY ENTRY SIGNAL";
               string aMsg   = "Symbol=" + _Symbol + " TF=" + EnumToString((ENUM_TIMEFRAMES)_Period) + " EVENT=BUY ENTRY\n" +
                               "Entry: " + DoubleToString(close[i], _Digits) + " | Direction: BUY\n" +
                               "SL: " + DoubleToString(slPrice, _Digits) + " (-" + DoubleToString(riskPips, 1) + " Pips / 100% Risk)\n" +
                               "TP1: " + DoubleToString(tp1, _Digits) + " (+" + DoubleToString(tp1Pips, 1) + " Pips / 1:1 RRR)\n" +
                               "TP2: " + DoubleToString(tp2, _Digits) + " (+" + DoubleToString(tp2Pips, 1) + " Pips / 1:2 RRR)\n" +
                               "TP3: " + DoubleToString(tp3, _Digits) + " (+" + DoubleToString(tp3Pips, 1) + " Pips / 1:3 RRR)";

               SendNotificationAlert(aTitle, aMsg);
               lastEntryAlertTime = time[i];
            }
         }

         // Draw BOS/CHoCH dashed structure line
         string lName = OBJ_PREFIX + "SMC_L_" + (string)(long)time[top_x] + "_" + (string)(long)time[i];
         CreateOrUpdateTrend(lName, time[top_x], top_y, time[i], top_y, bullColor, STYLE_DASH, 1);

         int midTime = (int)((long)time[top_x] + ((long)time[i] - (long)time[top_x]) / 2);
         string lblName = OBJ_PREFIX + "SMC_T_" + (string)(long)time[top_x] + "_" + (string)(long)time[i];
         CreateOrUpdateText(lblName, (datetime)midTime, top_y, txt, bullColor, ANCHOR_LOWER, 8);
      }

      if(btm_y != EMPTY_VALUE && close[i] < btm_y && !btm_cross)
      {
         btm_cross = true;
         bool isChoch = (trend >= 0);
         trend = -1;
         string txt = isChoch ? "CHoCH" : "BOS";
         bool triggerSell = false;

         // CHoCH / BOS Breakout Alert
         if(InpAlertBreakouts && i == rates_total - 1 && time[i] != lastBreakAlertTime)
         {
            string bTitle = _Symbol + " [" + EnumToString((ENUM_TIMEFRAMES)_Period) + "] " + txt + " ALERT";
            string bMsg   = "Symbol=" + _Symbol + " TF=" + EnumToString((ENUM_TIMEFRAMES)_Period) +
                            " Event=" + txt + " Direction=BEARISH Price=" + DoubleToString(close[i], _Digits);
            SendNotificationAlert(bTitle, bMsg);
            lastBreakAlertTime = time[i];
         }

         if(isChoch)
         {
            bearChochOccurred = true;
            bullChochOccurred = false;

            if(activeTrade && tradeDirection == 1 && InpShowTradeHistory)
            {
               string prevBoxKey = (string)(long)tradeEntryTime;
               datetime trimTime = (tradeLastTPTime != 0) ? tradeLastTPTime : time[i];
               UpdateRRBox(prevBoxKey, tradeEntryTime, trimTime, tradeEntryPrice, tradeSLPrice, tradeTP1Price, tradeTP2Price, tradeTP3Price, 1);

               ObjectDelete(0, OBJ_PREFIX + "LIVE_TRD_L");
               ObjectDelete(0, OBJ_PREFIX + "LIVE_TRD_T");

               double pips = CalculatePips(tradePeakPrice - tradeEntryPrice);
               color trdColor = (pips >= 0) ? winTradeColor : lossTradeColor;
               string pipsTxt = (pips >= 0 ? "+" : "") + DoubleToString(pips, 1) + " Pips";

               string trdLineName = OBJ_PREFIX + "TRD_L_" + (string)(long)tradeEntryTime + "_" + (string)(long)tradePeakTime;
               CreateOrUpdateTrend(trdLineName, tradeEntryTime, tradeEntryPrice, tradePeakTime, tradePeakPrice, trdColor, STYLE_DOT, 1);

               datetime midTime = (datetime)(tradeEntryTime + (tradePeakTime - tradeEntryTime) / 2);
               double   midPrice = (tradeEntryPrice + tradePeakPrice) / 2.0;

               string trdLblName = OBJ_PREFIX + "TRD_T_" + (string)(long)tradeEntryTime + "_" + (string)(long)tradePeakTime;
               CreateOrUpdateText(trdLblName, midTime, midPrice, pipsTxt, trdColor, ANCHOR_UPPER, 8);

               lastSetupInfo.isActive = false;
               lastSetupInfo.pips     = pips;
               activeTrade = false;
            }

            if(InpChochEMAEntry && i > 0)
            {
               bool emaBearCross = (close[i] < BufferEMA[i] && (close[i - 1] >= BufferEMA[i - 1] || open[i] >= BufferEMA[i] || high[i] >= BufferEMA[i]));
               if(emaBearCross)
                  triggerSell = true;
            }
         }
         else
         {
            if(bearChochOccurred && InpShowSignals)
            {
               triggerSell = true;
               if(InpOnlyFirstBOS)
                  bearChochOccurred = false;
            }
         }

         // Draw Sell Signal & Process R:R Box
         if(triggerSell)
         {
            BufferSell[i] = high[i] + arrowOffset;

            string entryName = OBJ_PREFIX + "ENT_S_" + (string)(long)time[i];
            CreateOrUpdateText(entryName, time[i], high[i] + textOffset, InpEntryText, bearColor, ANCHOR_LOWER, 8);

            double slPrice = (top_y != EMPTY_VALUE) ? top_y : high[i];
            if(btm_x >= 0 && btm_x < i)
            {
               double maxH = high[i];
               for(int k = btm_x; k <= i; k++)
               {
                  if(high[k] > maxH) maxH = high[k];
               }
               slPrice = maxH;
            }
            if(slPrice <= close[i]) slPrice = close[i] + (avgRange * 1.5);

            double risk = slPrice - close[i];
            double tp1  = close[i] - 1.0 * risk;
            double tp2  = close[i] - 2.0 * risk;
            double tp3  = close[i] - 3.0 * risk;

            bool isDirectSL = false;
            datetime boxEnd = FindTradeBoxEnd(time, high, low, close, i, rates_total, -1, slPrice, tp1, tp2, tp3, isDirectSL);

            if(!isDirectSL)
            {
               UpdateRRBox((string)(long)time[i], time[i], boxEnd, close[i], slPrice, tp1, tp2, tp3, -1);

               activeTrade      = true;
               tradeDirection   = -1;
               tradeEntryTime   = time[i];
               tradeEntryPrice  = close[i];
               tradeEntryBar    = i;
               tradeSLPrice     = slPrice;
               tradeTP1Price    = tp1;
               tradeTP2Price    = tp2;
               tradeTP3Price    = tp3;
               tradeLastTPTime  = 0;
               tradeLastTPPrice = 0.0;
               tradePeakTime    = time[i];
               tradePeakPrice   = low[i];

               lastSetupInfo.valid     = true;
               lastSetupInfo.isActive  = true;
               lastSetupInfo.direction = -1;
               lastSetupInfo.entry     = close[i];
               lastSetupInfo.sl        = slPrice;
               lastSetupInfo.tp1       = tp1;
               lastSetupInfo.tp2       = tp2;
               lastSetupInfo.tp3       = tp3;
               lastSetupInfo.pips      = 0.0;
            }
            else
            {
               DeleteTradeBox((string)(long)time[i]);
            }

            // Structured Trade Entry Alert
            if(InpAlertEntries && i == rates_total - 1 && time[i] != lastEntryAlertTime)
            {
               double riskPips = CalculatePips(risk);
               double tp1Pips  = CalculatePips(1.0 * risk);
               double tp2Pips  = CalculatePips(2.0 * risk);
               double tp3Pips  = CalculatePips(3.0 * risk);

               string aTitle = _Symbol + " [" + EnumToString((ENUM_TIMEFRAMES)_Period) + "] SELL ENTRY SIGNAL";
               string aMsg   = "Symbol=" + _Symbol + " TF=" + EnumToString((ENUM_TIMEFRAMES)_Period) + " EVENT=SELL ENTRY\n" +
                               "Entry: " + DoubleToString(close[i], _Digits) + " | Direction: SELL\n" +
                               "SL: " + DoubleToString(slPrice, _Digits) + " (-" + DoubleToString(riskPips, 1) + " Pips / 100% Risk)\n" +
                               "TP1: " + DoubleToString(tp1, _Digits) + " (+" + DoubleToString(tp1Pips, 1) + " Pips / 1:1 RRR)\n" +
                               "TP2: " + DoubleToString(tp2, _Digits) + " (+" + DoubleToString(tp2Pips, 1) + " Pips / 1:2 RRR)\n" +
                               "TP3: " + DoubleToString(tp3, _Digits) + " (+" + DoubleToString(tp3Pips, 1) + " Pips / 1:3 RRR)";

               SendNotificationAlert(aTitle, aMsg);
               lastEntryAlertTime = time[i];
            }
         }

         // Draw BOS/CHoCH dashed structure line
         string lName = OBJ_PREFIX + "SMC_L_" + (string)(long)time[btm_x] + "_" + (string)(long)time[i];
         CreateOrUpdateTrend(lName, time[btm_x], btm_y, time[i], btm_y, bearColor, STYLE_DASH, 1);

         int midTime = (int)((long)time[btm_x] + ((long)time[i] - (long)time[btm_x]) / 2);
         string lblName = OBJ_PREFIX + "SMC_T_" + (string)(long)time[btm_x] + "_" + (string)(long)time[i];
         CreateOrUpdateText(lblName, (datetime)midTime, btm_y, txt, bearColor, ANCHOR_UPPER, 8);
      }

      // 4. Candle Heatmap Calculation
      double colorIdx = (GRADIENT_STEPS - 1) / 2.0;

      int altCount = ArraySize(altPoints);
      if(InpHeatmap && altCount >= 2)
      {
         double currMaxX = 1.0;
         double currMaxY = 1.0;

         if(altCount >= 3)
         {
            for(int k = 2; k < altCount; k++)
            {
               double sp0 = altPoints[k - 2].price;
               double sp1 = altPoints[k - 1].price;
               double sp2 = altPoints[k].price;
               int    st2 = altPoints[k].type;

               if(st2 == 1 && sp0 > 0 && sp1 > 0)
               {
                  double simp  = (sp0 - sp1) / sp0 * 100.0;
                  double spull = (sp2 - sp1) / sp1 * 100.0;
                  if(simp > 0 && spull > 0)
                  {
                     currMaxX = MathMax(currMaxX, simp);
                     currMaxY = MathMax(currMaxY, spull);
                  }
               }
               else if(st2 == -1 && sp0 > 0 && sp1 > 0)
               {
                  double simp  = (sp1 - sp0) / sp0 * 100.0;
                  double spull = (sp1 - sp2) / sp1 * 100.0;
                  if(simp > 0 && spull > 0)
                  {
                     currMaxX = MathMax(currMaxX, simp);
                     currMaxY = MathMax(currMaxY, spull);
                  }
               }
            }
         }

         double p0 = altPoints[altCount - 2].price;
         double p1 = altPoints[altCount - 1].price;
         double p2 = close[i];
         int    t2 = -altPoints[altCount - 1].type;

         double px = 0.0, py = 0.0;
         bool valid = false;

         if(t2 == 1 && p0 > 0 && p1 > 0)
         {
            double impulse  = (p0 - p1) / p0 * 100.0;
            double pullback = (p2 - p1) / p1 * 100.0;
            if(impulse > 0 && pullback > 0)
            {
               px = -impulse;
               py = -pullback;
               valid = true;
               currMaxX = MathMax(currMaxX, impulse);
               currMaxY = MathMax(currMaxY, pullback);
            }
         }
         else if(t2 == -1 && p0 > 0 && p1 > 0)
         {
            double impulse  = (p1 - p0) / p0 * 100.0;
            double pullback = (p1 - p2) / p1 * 100.0;
            if(impulse > 0 && pullback > 0)
            {
               px = impulse;
               py = pullback;
               valid = true;
               currMaxX = MathMax(currMaxX, impulse);
               currMaxY = MathMax(currMaxY, pullback);
            }
         }

         if(valid)
         {
            double score = 0.0, minScore = 0.0, maxScore = 0.0;

            if(InpHeatmapMode == HEATMAP_COMBINED)
            {
               score    = px + py;
               minScore = -currMaxX - currMaxY;
               maxScore =  currMaxX + currMaxY;
            }
            else if(InpHeatmapMode == HEATMAP_IMPULSE)
            {
               score    = px;
               minScore = -currMaxX;
               maxScore =  currMaxX;
            }
            else if(InpHeatmapMode == HEATMAP_PULLBACK)
            {
               score    = py;
               minScore = -currMaxY;
               maxScore =  currMaxY;
            }

            double norm = (maxScore - minScore != 0) ? (score - minScore) / (maxScore - minScore) : 0.5;
            colorIdx = MathFloor(norm * (GRADIENT_STEPS - 1));
            colorIdx = MathMax(0.0, MathMin((double)(GRADIENT_STEPS - 1), colorIdx));
         }
      }

      BufferColors[i] = colorIdx;
   }

   // 5. Dynamic Real-time Extension on Live Bar
   if(activeTrade && InpShowTradeHistory)
   {
      double currentPips = 0.0;
      ENUM_ANCHOR_POINT anchorPos = ANCHOR_CENTER;

      if(tradeDirection == 1)
      {
         currentPips = CalculatePips(tradePeakPrice - tradeEntryPrice);
         anchorPos   = ANCHOR_UPPER;
      }
      else if(tradeDirection == -1)
      {
         currentPips = CalculatePips(tradeEntryPrice - tradePeakPrice);
         anchorPos   = ANCHOR_LOWER;
      }

      color trdColor = (currentPips >= 0) ? winTradeColor : lossTradeColor;
      string pipsTxt = (currentPips >= 0 ? "+" : "") + DoubleToString(currentPips, 1) + " Pips";

      string liveLineName = OBJ_PREFIX + "LIVE_TRD_L";
      CreateOrUpdateTrend(liveLineName, tradeEntryTime, tradeEntryPrice, tradePeakTime, tradePeakPrice, trdColor, STYLE_DOT, 1);

      datetime midTime = (datetime)(tradeEntryTime + (tradePeakTime - tradeEntryTime) / 2);
      double   midPrice = (tradeEntryPrice + tradePeakPrice) / 2.0;

      string liveLblName = OBJ_PREFIX + "LIVE_TRD_T";
      CreateOrUpdateText(liveLblName, midTime, midPrice, pipsTxt, trdColor, anchorPos, 8);
   }

   // 6. Update Left-Side Dashboard Panel
   RenderLeftPanel();

   return rates_total;
}
//+------------------------------------------------------------------+