//+------------------------------------------------------------------+
//|                              Part7_InteractivePositionLabeler.mq5|
//|                        Copyright 2025, MQL5 Standard Lib Explorer|
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Clemence Benjamin"
#property version   "1.00" 
#property description "Interactive Position Info Bubbles with MA Cross Strategy"

//--- 1. INCLUDES
#include <Canvas\Canvas.mqh>       // For drawing custom graphics
#include <Trade\PositionInfo.mqh>  // For reading trade details
#include <Trade\Trade.mqh>         // For executing trades
#include <Indicators\Trend.mqh>    // For Moving Averages

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
input EnumBubbleShape InpShape  = SHAPE_TRIANGLE; // Default to test layout logic

//--- 3. GLOBAL OBJECTS
CCanvas           ExtCanvas;       // The drawing canvas
CPositionInfo     ExtPosition;     // Position reader
CTrade            ExtTrade;        // Execution module
CiMA              ExtFastMA;       // Fast Moving Average
CiMA              ExtSlowMA;       // Slow Moving Average

// Performance flags
bool              ExtNeedResize = true; // Optimization: Only resize when needed

//--- HITBOX STRUCTURE (For Mouse Clicks)
struct BubbleHitbox
  {
   ulong    ticket; 
   int      x1, y1, x2, y2;
  };
BubbleHitbox ExtHitboxes[]; // Dynamic array to store clickable areas

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // A. Initialize Indicators
   if(!ExtFastMA.Create(_Symbol, _Period, InpFastMA, 0, MODE_SMA, PRICE_CLOSE))
      return(INIT_FAILED);
   if(!ExtSlowMA.Create(_Symbol, _Period, InpSlowMA, 0, MODE_SMA, PRICE_CLOSE))
      return(INIT_FAILED);

   // B. Initialize Canvas
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true); // Enable mouse tracking
   
   if(!ExtCanvas.CreateBitmapLabel("TradeBubblesCanvas", 0, 0,
                                   (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS),
                                   (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS),
                                   COLOR_FORMAT_ARGB_NORMALIZE))
      return(INIT_FAILED);

   ExtCanvas.FontSet("Calibri", 16); // Set font size
   
   Print("System Ready: Optimization Mode Active (30 FPS Limit)");
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
//| Expert tick function (SPEED OPTIMIZED)                           |
//+------------------------------------------------------------------+
void OnTick()
  {
   // --- PRIORITY 1: STRATEGY (Always Run) ---
   ExtFastMA.Refresh(-1);
   ExtSlowMA.Refresh(-1);

   // Simple Logic: Only open if no positions exist
   if(PositionsTotal() == 0)
     {
      CheckStrategy();
     }

   // --- PRIORITY 2: VISUALS (Throttled) ---
   // If testing without visuals, skip drawing entirely for speed
   if(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) return;

   static uint last_render_time = 0;
   uint current_pc_time = GetTickCount();

   // Max 30 FPS cap
   if(current_pc_time - last_render_time > 30)
     {
      DrawBubbles();
      last_render_time = current_pc_time;
     }
  }

//+------------------------------------------------------------------+
//| Strategy Logic: MA Crossover                                     |
//+------------------------------------------------------------------+
void CheckStrategy()
  {
   double fast0 = ExtFastMA.Main(0);
   double fast1 = ExtFastMA.Main(1);
   double slow0 = ExtSlowMA.Main(0);
   double slow1 = ExtSlowMA.Main(1);

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   if(fast1 < slow1 && fast0 > slow0)
     {
      double sl = ask - (InpSL * point);
      double tp = ask + (InpTP * point);
      ExtTrade.Buy(0.10, _Symbol, ask, sl, tp, "MA_Cross_Buy");
     }

   if(fast1 > slow1 && fast0 < slow0)
     {
      double sl = bid + (InpSL * point);
      double tp = bid - (InpTP * point);
      ExtTrade.Sell(0.10, _Symbol, bid, sl, tp, "MA_Cross_Sell");
     }
  }

//+------------------------------------------------------------------+
//| Main Drawing Function                                            |
//+------------------------------------------------------------------+
void DrawBubbles()
  {
   if(ExtNeedResize)
     {
      int w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      int h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
      if(w != ExtCanvas.Width() || h != ExtCanvas.Height()) 
         ExtCanvas.Resize(w, h);
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

//+------------------------------------------------------------------+
//| Helper: Draw a single bubble (WITH LAYOUT FIXES)                 |
//+------------------------------------------------------------------+
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

   // Base Dimensions
   int bubble_x = x + 30;
   int bubble_y = y - 30;
   int width = 160; int height = 40; int btn_size = 20;

   // --- INITIALIZE VARIABLES TO 0 TO PREVENT WARNINGS ---
   int text_x_final = 0;
   int text_y_final = 0;
   uint text_align_final = 0;
   int btn_x1_final = 0;
   int btn_y1_final = 0;

   // --- SHAPE DRAWING & LAYOUT CALCULATION ---
   switch(InpShape)
     {
      case SHAPE_ROUNDED_RECT:
         // Draw Shape
         {
            int r = 10;
            ExtCanvas.FillCircle(bubble_x + r, bubble_y + r, r, bg_color);
            ExtCanvas.FillCircle(bubble_x + width - r, bubble_y + r, r, bg_color);
            ExtCanvas.FillCircle(bubble_x + r, bubble_y + height - r, r, bg_color);
            ExtCanvas.FillCircle(bubble_x + width - r, bubble_y + height - r, r, bg_color);
            ExtCanvas.FillRectangle(bubble_x + r, bubble_y, bubble_x + width - r, bubble_y + height, bg_color);
            ExtCanvas.FillRectangle(bubble_x, bubble_y + r, bubble_x + width, bubble_y + height - r, bg_color);
         }
         // Layout: Standard left align, button on right edge
         text_x_final = bubble_x + 10;
         text_y_final = bubble_y + 12;
         text_align_final = TA_LEFT|TA_VCENTER;
         btn_x1_final = bubble_x + width - btn_size - 5;
         btn_y1_final = bubble_y + (height - btn_size)/2;
         break;

      case SHAPE_CIRCLE:
         // Draw Shape (Ellipse)
         ExtCanvas.FillCircle(bubble_x + width/2, bubble_y + height/2, height/2 + 10, bg_color);
         
         // Layout: Center text. Move button inward to clear curve.
         text_x_final = bubble_x + width/2;
         text_y_final = bubble_y + height/2;
         text_align_final = TA_CENTER|TA_VCENTER;
         btn_x1_final = bubble_x + width - btn_size - 25; 
         btn_y1_final = bubble_y + (height - btn_size)/2;
         break;

      case SHAPE_TRIANGLE:
         // Draw Shape
         ExtCanvas.FillTriangle(bubble_x, bubble_y + height/2, 
                                bubble_x + width, bubble_y - 10, 
                                bubble_x + width, bubble_y + height + 10, bg_color);
         
         // Layout: Shift text far right to avoid pointy tip. Button on edge is OK.
         text_x_final = bubble_x + 45; 
         text_y_final = bubble_y + 12;
         text_align_final = TA_LEFT|TA_VCENTER;
         btn_x1_final = bubble_x + width - btn_size - 5;
         btn_y1_final = bubble_y + (height - btn_size)/2;
         break;
     }

   // --- DRAW CONTENT USING CALCULATED LAYOUT ---
   
   // 1. Draw Text
   ExtCanvas.TextOut(text_x_final, text_y_final, text, text_color, text_align_final);

   // 2. Draw "X" Button
   int btn_x2_final = btn_x1_final + btn_size;
   int btn_y2_final = btn_y1_final + btn_size;
   ExtCanvas.FillRectangle(btn_x1_final, btn_y1_final, btn_x2_final, btn_y2_final, ColorToARGB(clrRed));
   ExtCanvas.TextOut(btn_x1_final + btn_size/2, btn_y1_final + btn_size/2, "X", text_color, TA_CENTER|TA_VCENTER);

   // 3. Draw Connector Line (Triangle doesn't need it)
   if(InpShape != SHAPE_TRIANGLE)
      ExtCanvas.Line(x, y, bubble_x, bubble_y + height/2, ColorToARGB(base_color));

   // 4. Register Hitbox
   int new_idx = ArraySize(ExtHitboxes);
   ArrayResize(ExtHitboxes, new_idx + 1);
   ExtHitboxes[new_idx].ticket = ticket;
   ExtHitboxes[new_idx].x1 = btn_x1_final;
   ExtHitboxes[new_idx].y1 = btn_y1_final;
   ExtHitboxes[new_idx].x2 = btn_x2_final;
   ExtHitboxes[new_idx].y2 = btn_y2_final;
  }

//+------------------------------------------------------------------+
//| Chart Event Handler (Clicks & Scrolls)                           |
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
            Print("Interactive Close: Ticket #", ExtHitboxes[i].ticket);
            ExtTrade.PositionClose(ExtHitboxes[i].ticket);
            DrawBubbles(); 
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+