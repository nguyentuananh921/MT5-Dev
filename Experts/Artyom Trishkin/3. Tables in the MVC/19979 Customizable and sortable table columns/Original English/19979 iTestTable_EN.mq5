//+------------------------------------------------------------------+
//|                                                   iTestTable.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
#include "Controls\Controls.mqh"    // Controls Library

// --- Pointer to a CTableControl object
CTableControl *table_ctrl;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// --- Looking for a chart subwindow
   int wnd=ChartWindowFind();

// --- Create data for the table
// --- Declare and fill an array of column headers with a dimension of 4
   string captions[]={"Column 0","Column 1","Column 2","Column 3"};
   
// --- We declare and fill a data array with a dimension of 15x4
// --- Array type can be double, long, datetime, color, string
   long array[15][4]={{ 1,  2,  3,  4},
                      { 5,  6,  7,  8},
                      { 9, 10, 11, 12},
                      {13, 14, 15, 16},
                      {17, 18, 19, 20},
                      {21, 22, 23, 24},
                      {25, 26, 27, 28},
                      {29, 30, 31, 32},
                      {33, 34, 35, 36},
                      {37, 38, 39, 40},
                      {41, 42, 43, 44},
                      {45, 46, 47, 48},
                      {49, 50, 51, 52},
                      {53, 54, 55, 56},
                      {57, 58, 59, 60}};
                      
// --- Create a graphical table control element
   table_ctrl=new CTableControl("TableControl0",0,wnd,30,30,460,184);
   if(table_ctrl==NULL)
      return INIT_FAILED;

// --- The chart must have one main element
   table_ctrl.SetAsMain();

// ---Can set table control options
   table_ctrl.SetID(0);                      // Identifier
   table_ctrl.SetName("Table Control 0");    // Name

// --- Create table object 0 (Model + View component) from the above created long array 15x4 and string array of column headers
   if(table_ctrl.TableCreate(array,captions)==NULL)
      return INIT_FAILED;
      
// --- Additionally, set the text output for columns 1,2,3 to the center of the cell, and for column 0 - to the left edge
   table_ctrl.ColumnSetTextAnchor(0,0,ANCHOR_LEFT,true,false);
   table_ctrl.ColumnSetTextAnchor(0,1,ANCHOR_CENTER,true,false);
   table_ctrl.ColumnSetTextAnchor(0,2,ANCHOR_CENTER,true,false);
   table_ctrl.ColumnSetTextAnchor(0,3,ANCHOR_CENTER,true,false);

// --- Let's draw a table
   table_ctrl.Draw(true);
   
// --- Get the table with index 0 and print it in the log
   CTable *table=table_ctrl.GetTable(0);
   table.Print();
   
// --- Successfully
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom deindicator initialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// --- Remove the table control and destroy the library shared resource manager
   delete table_ctrl;
   CCommonManager::DestroyInstance();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
// --- Call the OnChartEvent handler of the table control
   table_ctrl.OnChartEvent(id,lparam,dparam,sparam);
   
// --- If the event is moving the mouse cursor
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      // --- get cursor coordinates
      int x=table_ctrl.CursorX();
      int y=table_ctrl.CursorY();
      
      // --- the X coordinate value is set to cell 0 of row 1
      table_ctrl.CellSetValue(0,1,0,x,false);
      
      // --- the Y coordinate value is set to cell 1 of row 1
      // --- the color of the text in the cell depends on the sign of the Y coordinate (for a negative value - red text)
      table_ctrl.CellSetForeColor(0,1,1,(y<0 ? clrRed : table_ctrl.ForeColor()),false);
      table_ctrl.CellSetValue(0,1,1,y,true);
     }
  }
//+------------------------------------------------------------------+
// | Timer |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
// --- Call the OnTimer handler of the table control
   table_ctrl.OnTimer();
  }
//+------------------------------------------------------------------+
