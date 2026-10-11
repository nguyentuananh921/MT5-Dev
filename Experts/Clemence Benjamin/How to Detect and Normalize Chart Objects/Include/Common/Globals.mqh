//+------------------------------------------------------------------+
//|                                                   Globals.mqh   |
//|                                Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Global cached values                                             |
//+------------------------------------------------------------------+
double g_point = 0.00001;
int    g_digits = 5;

//+------------------------------------------------------------------+
//| Price cache arrays for performance                               |
//+------------------------------------------------------------------+
double g_highCache[];
double g_lowCache[];
double g_closeCache[];
double g_openCache[];
datetime g_timeCache[];
int g_cacheSize = 0;

//+------------------------------------------------------------------+
//| Function to ensure globals are initialized                       |
//+------------------------------------------------------------------+
void InitGlobals()
{
   g_point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   g_digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   g_cacheSize = 0;
}
//+------------------------------------------------------------------+