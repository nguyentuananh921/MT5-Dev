//+------------------------------------------------------------------+
//|                                                CChartManager.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.00"

#ifndef _CCHART_MANAGER_
#define _CCHART_MANAGER_

//--- Include required definitions
#include "DashboardDefines.mqh"

//+------------------------------------------------------------------+
//| Class CChartManager                                              |
//| Manages chart operations for symbols in the trading platform     |
//+------------------------------------------------------------------+
class CChartManager
  {
private:
   ENUM_TIMEFRAMES   m_defaultTF;   // Default timeframe for new charts

public:
   //+------------------------------------------------------------------+
   //| Constructor – sets the default timeframe                         |
   //+------------------------------------------------------------------+
                     CChartManager();

   //+------------------------------------------------------------------+
   //| Opens a new chart for the given symbol                           |
   //+------------------------------------------------------------------+
   bool              Open(string symbol);

   //+------------------------------------------------------------------+
   //| Closes the first chart found for the given symbol                |
   //+------------------------------------------------------------------+
   bool              Close(string symbol);

   //+------------------------------------------------------------------+
   //| Checks whether a chart for the given symbol is open              |
   //+------------------------------------------------------------------+
   bool              IsOpen(string symbol);

   //+------------------------------------------------------------------+
   //| Returns the Chart ID of the first chart with the given symbol    |
   //+------------------------------------------------------------------+
   long              GetChartID(string symbol);

   //+------------------------------------------------------------------+
   //| (Optional) Activates the chart (not used in Phase 1)             |
   //+------------------------------------------------------------------+
   void              Activate(string symbol);
  };

//+------------------------------------------------------------------+
//| Constructor – initializes the default timeframe                  |
//+------------------------------------------------------------------+
CChartManager::CChartManager() : m_defaultTF(DEFAULT_TIMEFRAME)
  {
//--- Initialize manager with default timeframe from defines
  }

//+------------------------------------------------------------------+
//| Opens a new chart for the specified symbol                       |
//+------------------------------------------------------------------+
bool CChartManager::Open(string symbol)
  {
//--- Validate input parameter - empty symbol is not allowed
   if(symbol == "")
      return false;

//--- Attempt to open a new chart with default timeframe
   long chart = ChartOpen(symbol, m_defaultTF);

//--- Return true if chart was opened successfully (valid chart ID)
   return (chart != -1);
  }

//+------------------------------------------------------------------+
//| Closes the first chart found for the specified symbol            |
//+------------------------------------------------------------------+
bool CChartManager::Close(string symbol)
  {
//--- Get the chart ID for the symbol
   long chart = GetChartID(symbol);

//--- If no chart found, return false
   if(chart == -1)
      return false;

//--- Close the chart and return the result
   return ChartClose(chart);
  }

//+------------------------------------------------------------------+
//| Checks if any chart for the specified symbol is open             |
//+------------------------------------------------------------------+
bool CChartManager::IsOpen(string symbol)
  {
//--- Check if GetChartID returns a valid chart ID
   return (GetChartID(symbol) != -1);
  }

//+------------------------------------------------------------------+
//| Finds and returns the Chart ID of the first chart with given symbol |
//+------------------------------------------------------------------+
long CChartManager::GetChartID(string symbol)
  {
//--- Get the first chart in the chart list
   long curr = ChartFirst();

//--- Iterate through all open charts
   while(curr != -1)
     {
      //--- Check if the current chart's symbol matches the requested symbol
      if(ChartSymbol(curr) == symbol)
         return curr;  //--- Return the chart ID when match is found

      //--- Move to the next chart in the list
      curr = ChartNext(curr);
     }

//--- No matching chart found - return -1
   return -1;
  }

//+------------------------------------------------------------------+
//| Activates the chart (placeholder - not implemented in Phase 1)   |
//+------------------------------------------------------------------+
void CChartManager::Activate(string symbol)
  {
//--- This function is reserved for future implementation
//--- Currently does nothing as per Phase 1 requirements
  }

#endif
//+------------------------------------------------------------------+