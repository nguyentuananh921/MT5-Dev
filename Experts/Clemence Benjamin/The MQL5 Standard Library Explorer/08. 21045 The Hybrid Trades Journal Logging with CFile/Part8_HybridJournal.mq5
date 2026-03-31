//+------------------------------------------------------------------+
//|                                         Part8_HybridJournal.mq5  |
//|                        Copyright 2025, MQL5 Standard Lib Explorer|
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Clemence Benjamin"
#property version   "1.00" 
#property description "Hybrid Trading System: Interactive Labels + CSV Journaling"

//--- 1. INCLUDES
#include <Canvas\Canvas.mqh>       // For drawing custom graphics
#include <Trade\PositionInfo.mqh>  // For reading trade details
#include <Trade\Trade.mqh>         // For executing trades
#include <Indicators\Trend.mqh>    // For Moving Averages
#include <Files\FileTxt.mqh>       // For writing the Journal

//--- 2. INPUTS
enum EnumBubbleShape
  {
   SHAPE_ROUNDED_RECT,
   SHAPE_CIRCLE,
   SHAPE_TRIANGLE
  };

input group "Strategy Settings"
input int             InpFastMA = 10;               // Fast MA Period
input int             InpSlowMA = 20;               // Slow MA Period
input int             InpSL     = 300;              // Stop Loss (Points)
input int             InpTP     = 600;              // Take Profit (Points)

input group "Visual Settings"
input EnumBubbleShape InpShape  = SHAPE_ROUNDED_RECT; 

//--- 3. THE JOURNAL CLASS (SANDBOX VERSION)
class CTradeJournal
  {
private:
   CFileTxt          m_file;       // Standard Library File Object
   string            m_filename;
   string            m_sep;        // CSV Separator (Comma)

public:
   CTradeJournal() : m_sep(",") {} // Constructor sets default separator

   // Initialize and create header if new
   bool Init(string filename)
     {
      m_filename = filename;
      
      // FIX APPLIED: Removed FILE_COMMON.
      // Now writes to MQL5/Files (Live) or Tester/Files (Testing).
      // Added FILE_SHARE_READ so you can view it in Excel read-only.
      int flags = FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ;

      // Reset any previous errors
      ResetLastError();

      // Attempt to open
      if(m_file.Open(filename, flags) == INVALID_HANDLE)
        {
         Print("CRITICAL ERROR: Failed to open file: ", filename);
         Print("Error Code: ", GetLastError());
         return(false);
        }

      // Check if file is empty (brand new). If so, write the CSV Header.
      if(m_file.Size() == 0)
        {
         string header = "Time,Ticket,Symbol,Action,Source,Profit";
         m_file.WriteString(header + "\n"); 
         m_file.Flush(); // Force save to disk
        }
      
      // Move "Cursor" to the end of the file to append new logs
      m_file.Seek(0, SEEK_END); 
      return(true);
     }

   // The Main Logging Method
   void Log(ulong ticket, string action, string source, double profit)
     {
      // Construct the CSV row string manually
      string line = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + m_sep +
                    IntegerToString(ticket) + m_sep +
                    _Symbol + m_sep +
                    action + m_sep +
                    source + m_sep +
                    DoubleToString(profit, 2);
      
      // Write to file
      m_file.WriteString(line + "\n");
      
      // INSTANT WRITE: Forces data from RAM to Disk immediately.
      // This ensures logs are saved even if you stop the test abruptly.
      m_file.Flush(); 
      
      Print("Journal Entry Saved: ", action, " by ", source);
     }
     
   ~CTradeJournal()
     {
      m_file.Close();
     }
  };

//--- 4. GLOBAL OBJECTS
CCanvas           ExtCanvas;       // Visuals
CPositionInfo     ExtPosition;     // Data
CTrade            ExtTrade;        // Execution
CiMA              ExtFastMA;       // Signals
CiMA              ExtSlowMA;       // Signals
CTradeJournal     ExtJournal;      // Journal Object

// Optimization Flags
bool              ExtNeedResize = true; 

// Hitbox Structure
struct BubbleHitbox
  {
   ulong    ticket;
   int      x1, y1, x2, y2;
  };
BubbleHitbox ExtHitboxes[]; 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // A. Initialize Indicators
   if(!ExtFastMA.Create(_Symbol, _Period, InpFastMA, 0, MODE_SMA, PRICE_CLOSE)) return(INIT_FAILED);
   if(!ExtSlowMA.Create(_Symbol, _Period, InpSlowMA, 0, MODE_SMA, PRICE_CLOSE)) return(INIT_FAILED);

   // B. Initialize Canvas
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true); 
   if(!ExtCanvas.CreateBitmapLabel("TradeBubblesCanvas", 0, 0,
                                   (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS),
                                   (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS),
                                   COLOR_FORMAT_ARGB_NORMALIZE))
      return(INIT_FAILED);
   ExtCanvas.FontSet("Calibri", 16);

   // C. Initialize Journal
   // Since we removed FILE_COMMON, this file will appear in:
   // Live: MQL5\Files\HybridJournal.csv
   // Tester: Tester\Files\HybridJournal.csv (after test finishes)
   if(!ExtJournal.Init("HybridJournal.csv"))
     {
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtCanvas.Destroy();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // 1. Update Strategy Logic
   ExtFastMA.Refresh(-1);
   ExtSlowMA.Refresh(-1);

   if(PositionsTotal() == 0)
     {
      CheckStrategy();
     }

   // 2. Update Visuals
   if(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) return;

   static uint last_render_time = 0;
   uint current_pc_time = GetTickCount();

   if(current_pc_time - last_render_time > 30)
     {
      DrawBubbles();
      last_render_time = current_pc_time;
     }
  }

//+------------------------------------------------------------------+
//| Strategy Logic (With Logging)                                    |
//+------------------------------------------------------------------+
void CheckStrategy()
  {
   double fast0 = ExtFastMA.Main(0);
   double fast1 = ExtFastMA.Main(1);
   double slow0 = ExtSlowMA.Main(0);
   double slow1 = ExtSlowMA.Main(1);

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   // GOLDEN CROSS (Buy)
   if(fast1 < slow1 && fast0 > slow0)
     {
      double sl = ask - (InpSL * point);
      double tp = ask + (InpTP * point);
      
      if(ExtTrade.Buy(0.10, _Symbol, ask, sl, tp, "MA_Cross_Buy"))
        {
         // Log Algo Entry
         ExtJournal.Log(ExtTrade.ResultOrder(), "ENTRY_BUY", "ALGO", 0.0);
        }
     }
  }

//+------------------------------------------------------------------+
//| Interaction Logic (With Logging)                                 |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      ExtNeedResize = true; 
      DrawBubbles(); 
     }

   if(id == CHARTEVENT_CLICK)
     {
      int mouse_x = (int)lparam;
      int mouse_y = (int)dparam;

      for(int i = 0; i < ArraySize(ExtHitboxes); i++)
        {
         if(mouse_x >= ExtHitboxes[i].x1 && mouse_x <= ExtHitboxes[i].x2 &&
            mouse_y >= ExtHitboxes[i].y1 && mouse_y <= ExtHitboxes[i].y2)
           {
            // Log Manual Close
            if(ExtPosition.SelectByTicket(ExtHitboxes[i].ticket))
              {
               double final_profit = ExtPosition.Profit();
               ExtTrade.PositionClose(ExtHitboxes[i].ticket);
               
               ExtJournal.Log(ExtHitboxes[i].ticket, "CLOSE_MANUAL", "HUMAN", final_profit);
               
               DrawBubbles(); 
              }
            return;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Visual Drawing Logic                                             |
//+------------------------------------------------------------------+
void DrawBubbles()
  {
   if(ExtNeedResize)
     {
      int w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      int h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
      if(w != ExtCanvas.Width() || h != ExtCanvas.Height()) ExtCanvas.Resize(w, h);
      ExtNeedResize = false; 
     }

   ExtCanvas.Erase(0x00000000); 
   ArrayResize(ExtHitboxes, 0); 

   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(ExtPosition.SelectByIndex(i))
        {
         if(ExtPosition.Symbol() == _Symbol)
            DrawSingleBubble();
        }
     }
   ExtCanvas.Update();
  }

void DrawSingleBubble()
  {
   double open_price = ExtPosition.PriceOpen();
   double profit     = ExtPosition.Profit();
   ulong  ticket     = ExtPosition.Ticket(); 
   datetime time     = (datetime)ExtPosition.Time();

   int x, y;
   if(!ChartTimePriceToXY(0, 0, time, open_price, x, y)) return; 

   uint base_color = (profit >= 0) ? clrSeaGreen : clrFireBrick;
   uint bg_color   = ColorToARGB(base_color, 220); 
   uint text_color = ColorToARGB(clrWhite);
   string text     = StringFormat("#%I64u: $%.2f", ticket, profit); 

   int bubble_x = x + 30; int bubble_y = y - 30;
   int width = 160; int height = 40; int btn_size = 20;

   // Simple Rounded Rect Shape
   int r = 10;
   ExtCanvas.FillCircle(bubble_x + r, bubble_y + r, r, bg_color);
   ExtCanvas.FillCircle(bubble_x + width - r, bubble_y + r, r, bg_color);
   ExtCanvas.FillCircle(bubble_x + r, bubble_y + height - r, r, bg_color);
   ExtCanvas.FillCircle(bubble_x + width - r, bubble_y + height - r, r, bg_color);
   ExtCanvas.FillRectangle(bubble_x + r, bubble_y, bubble_x + width - r, bubble_y + height, bg_color);
   ExtCanvas.FillRectangle(bubble_x, bubble_y + r, bubble_x + width, bubble_y + height - r, bg_color);

   ExtCanvas.TextOut(bubble_x + 10, bubble_y + 12, text, text_color, TA_LEFT|TA_VCENTER);
   
   int btn_x1 = bubble_x + width - btn_size - 5;
   int btn_y1 = bubble_y + (height - btn_size)/2;
   int btn_x2 = btn_x1 + btn_size;
   int btn_y2 = btn_y1 + btn_size;

   ExtCanvas.FillRectangle(btn_x1, btn_y1, btn_x2, btn_y2, ColorToARGB(clrRed));
   ExtCanvas.TextOut(btn_x1 + btn_size/2, btn_y1 + btn_size/2, "X", text_color, TA_CENTER|TA_VCENTER);
   ExtCanvas.Line(x, y, bubble_x, bubble_y + height/2, ColorToARGB(base_color));

   int new_idx = ArraySize(ExtHitboxes);
   ArrayResize(ExtHitboxes, new_idx + 1);
   ExtHitboxes[new_idx].ticket = ticket;
   ExtHitboxes[new_idx].x1 = btn_x1;
   ExtHitboxes[new_idx].y1 = btn_y1;
   ExtHitboxes[new_idx].x2 = btn_x2;
   ExtHitboxes[new_idx].y2 = btn_y2;
  }
//+------------------------------------------------------------------+