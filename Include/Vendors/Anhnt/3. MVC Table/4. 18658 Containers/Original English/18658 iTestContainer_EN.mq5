//+------------------------------------------------------------------+
//|                                               iTestContainer.mq5 |
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
//#include <Arrays\ArrayObj.mqh>
// #include "..\..\..\Scripts\Work\Tables\Controls\Controls.mqh"
#include "Controls\Controls.mqh"    // Controls Library

CContainer       *container=NULL;   // Pointer to the Container graphic element

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// --- Looking for a chart subwindow
   int wnd=ChartWindowFind();

// --- Create a graphic element "Container"
   container=new CContainer("Container","",0,wnd,100,40,300,200);
   if(container==NULL)
      return INIT_FAILED;
   container.SetID(1);           // Identifier
   container.SetAsMain();        // There must be one main element on the chart
   container.SetBorderWidth(1);  // Border width (visible area indentation by one pixel on each side of the container)
   
// --- Attach the GroupBox element to the container
   CGroupBox *groupbox=container.InsertNewElement(ELEMENT_TYPE_GROUPBOX,"","Attached Groupbox",4,4,container.Width()*2+20,container.Height()*3+10);
   if(groupbox==NULL)
      return INIT_FAILED;
   groupbox.SetGroup(1);         // Group number
   
// --- In the loop, we create and attach 30 lines from the “Text Label” elements to the GroupBox element
   for(int i=0;i<30;i++)
     {
      string text=StringFormat("This is test line number %d to demonstrate how scrollbars work when scrolling the contents of the container.",(i+1));
      int len=groupbox.GetForeground().TextWidth(text);
      CLabel *lbl=groupbox.InsertNewElement(ELEMENT_TYPE_LABEL,text,"TextString"+string(i+1),8,8+(20*i),len,20);
      if(lbl==NULL)
         return INIT_FAILED;
     }
   
// --- Draw all created elements on the chart and print their description in the journal
   container.Draw(true);
   container.Print();
   
// --- Successfully
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom deindicator initialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// --- Delete the Container element and destroy the library shared resource manager
   delete container;
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
// --- Call the OnChartEvent handler of the Container element
   container.OnChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
// | Timer |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
// --- Call the OnTimer handler of the Container element
   container.OnTimer();
  }
//+------------------------------------------------------------------+
