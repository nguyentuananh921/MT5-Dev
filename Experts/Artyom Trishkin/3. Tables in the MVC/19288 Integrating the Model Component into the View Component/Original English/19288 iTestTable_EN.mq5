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
#include "Controls\Controls_En.mqh"    // Controls Library

CPanel     *panel=NULL; // Pointer to the Panel graphic element
CTable     *table;      // Pointer to a table object (Model)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// --- Looking for a chart subwindow
   int wnd=ChartWindowFind();

// --- Create a graphic element "Panel"
   panel=new CPanel("Panel","",0,wnd,100,40,400,192);
   if(panel==NULL)
      return INIT_FAILED;
// --- Set panel parameters
   panel.SetID(1);                     // Identifier
   panel.SetAsMain();                  // There must be one main element on the chart
   panel.SetBorderWidth(1);            // Border width (visible area indentation by one pixel on each side of the container)
   panel.SetResizable(false);          // The ability to change sizes by dragging edges and corners is disabled
   panel.SetName("Main container");    // Name
   
// --- Create data for the table
// --- Declare and fill an array of column headers with a dimension of 4
   string captions[4]={"Column 0","Column 1","Column 2","Column 3"};
  
// --- We declare and fill a data array with a dimension of 10x4
// --- Array type can be double, long, datetime, color, string
   long array[10][4]={{ 1,  2,  3,  4},
                      { 5,  6,  7,  8},
                      { 9, 10, 11, 12},
                      {13, 14, 15, 16},
                      {17, 18, 19, 20},
                      {21, 22, 23, 24},
                      {25, 26, 27, 28},
                      {29, 30, 31, 32},
                      {33, 34, 35, 36},
                      {37, 38, 39, 40}};
// --- Create a table object from the above created long array 10x4 and string array of column headers (Model component)
   table=new CTable(array,captions);
   if(table==NULL)
      return INIT_FAILED;
   PrintFormat("The [%s] has been successfully created:",table.Description());
   
// --- Create a new element on the panel - a table (View component)
   CTableView *table_view=panel.InsertNewElement(ELEMENT_TYPE_TABLE,"","TableView",4,4,panel.Width()-8,panel.Height()-8);
// --- Assign a table object (Model) to the graphic element "Table" (View)
   table_view.TableObjectAssign(table);
// --- Print the table model in the journal
   table_view.TablePrint();
   
// --- Let's draw a table together with a panel
   panel.Draw(true);

// --- Successfully
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom deindicator initialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// --- Delete the Panel element and destroy the table and library shared resource manager
   delete panel;
   delete table;
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
// --- Call the OnChartEvent handler of the Panel element
   panel.OnChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
// | Timer |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
// --- Call the OnTimer handler of the Panel element
   panel.OnTimer();
  }
//+------------------------------------------------------------------+
