//+------------------------------------------------------------------+
//|                                            iCorrelationTable.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers   0
#property indicator_plots     0

#define   CHART_FLOAT_WIDTH   750                                    // Width of opening symbol chart
#define   CHART_FLOAT_HEIGHT  500                                    // Height of the opened symbol chart

//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
//#include "Controls\Controls.mqh"    // Controls Library
//#include <Vendors\Anhnt\3. MVC Table\20596 Lib\Controls\Controls_EN.mqh>
#include <Vendors\Anhnt\Library\3. MVC Table\20596 Refactor\Controls\TableControl.mqh>
#include <Vendors\Anhnt\Library\3. MVC Table\20596 Refactor\Controls\TableView.mqh>
#include <Vendors\Anhnt\Library\3. MVC Table\20596 Refactor\Services\DELib.mqh>


//--- input parameters
input(name="Bars Total (at least 10)") uint              InpBarsTotal   =  1000;                                                 // Number of data bars to calculate correlation (at least 10)
input(name="Timeframe")                ENUM_TIMEFRAMES   InpTimeframe   =  PERIOD_CURRENT;                                       // Data timeframe for correlation calculation
input(name="Symbols for Correlation")  string            InpSymbols     =  "EURUSD,GBPUSD,USDJPY,USDCHF,AUDUSD,NZDUSD,USDCAD";   // Symbols for calculating correlation

//--- global variables
string   ExtSymbolsArray[];                                          // Character array for correlation calculation
matrix   ExtPricesData;                                              // Symbol Data Matrix (Close Prices)
uint     ExtBarsTotal;                                               // Number of data bars to calculate correlation
matrix   ExtCorrelationMatrix;                                       // Matrix of calculated pairwise correlations between all characters
bool     ExtDataReady;                                               // Data ready flag for all symbols
long     ExtSymbolsChart;                                            // New plot ID for correlation symbols
CTableControl *ExtTableCtrl;                                         // Pointer to a CTableControl object
CTableView *ExtTableView;                                            // Pointer to a table visual object
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

// --- ID of the chart to open
   ExtSymbolsChart=0;

// --- Looking for a chart subwindow
   int wnd=ChartWindowFind();

// --- Fill the array of symbols from those specified in the input parameter InpSymbols
   string sep=",";   // character delimiter
   ushort u_sep;     // delimiter character code
// --- get the separator code
   u_sep=StringGetCharacter(sep,0); 
// --- get substrings from the InpSymbols string using the u_sep separator and write them to the ExtSymbolsArray array
   StringSplit(InpSymbols,u_sep,ExtSymbolsArray);
   
// --- Let's print a set of symbols in the journal to calculate the correlation
   Print("\nSymbols Array:");
   ArrayPrint(ExtSymbolsArray);
   
// --- We include all symbols in the market review
   SymbolsSelect(ExtSymbolsArray);

// --- We receive symbol data (at least 10 bars) to calculate the correlation
   ExtBarsTotal=(InpBarsTotal<10 ? 10 : InpBarsTotal);
   ExtDataReady=GetAndCalculateData(ExtBarsTotal);
   
// --- Create a graphical table control element
   int w=500;
   int h=138;
   ExtTableCtrl=new CTableControl("TableControl0",0,wnd,8,8,w-0,h-0);
   if(ExtTableCtrl==NULL)
     {
      Print("Error. Failed to create TableControl object");
      return INIT_FAILED;
     }

// --- The chart must have one main element
   ExtTableCtrl.SetAsMain();

// --- You can set the parameters of the created table control
   ExtTableCtrl.SetID(0);                      // Identifier
   ExtTableCtrl.SetName("Table Control 0");    // Name

// --- If the symbol data and its correlations are successfully received,
// --- create table object 0 (Model + View component) inside the table control
// --- from the above created matrix ExtCorrelationMatrixSymmetric and
// --- string-array of symbols ExtSymbolsArray as column headers
   if(ExtDataReady && !CreateTable(ExtTableCtrl))
      return INIT_FAILED;
   
// --- Everything is successful
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int32_t reason)
  {
// --- Remove the table control and destroy the library shared resource manager
   delete ExtTableCtrl;
   CCommonManager::DestroyInstance();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[])
  {
// --- We receive data until it is ready
   ExtDataReady=GetAndCalculateData(ExtBarsTotal);
   if(!ExtDataReady)
     {
      Print("The symbol data and their correlations have not yet been obtained. Waiting for the next tick...");
      return 0;
     }
   
// --- If the table has not yet been created
// --- create table object 0 (Model + View component) inside the table control
// --- from the above created matrix ExtCorrelationMatrixSymmetric and
// --- string-array of symbols ExtSymbolsArray as column headers
   if(ExtTableView==NULL && !CreateTable(ExtTableCtrl))
      return 0;

// --- Updating the data in the table with setting the correlation colors
   UpdateTableValuesAndColors(ExtTableCtrl.GetTableView(0),ExtCorrelationMatrix);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
// --- Once every minute and a half we receive data on characters from the array
   static int count=0;
   count++;
   if(count>=3000)
     {
      double array[];
      for(int i=0;i<(int)ExtSymbolsArray.Size();i++)
         CopyClose(ExtSymbolsArray[i],InpTimeframe,0,ExtBarsTotal,array);
      count=0;
     }
// --- Call the OnTimer handler of the table control
   ExtTableCtrl.OnTimer();
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int32_t id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
// --- Call the OnChartEvent handler of the table control
   ExtTableCtrl.OnChartEvent(id,lparam,dparam,sparam);
   if(id>=CHARTEVENT_CUSTOM)
     {
      // --- Convert the identifier of the received custom event to the values ​​of standard events
      ENUM_CHART_EVENT chart_event=ENUM_CHART_EVENT(id-CHARTEVENT_CUSTOM);
      
      // --- If the click event on a graphic object
      if(chart_event==CHARTEVENT_OBJECT_CLICK)
        {
         // --- If the event name (sparam value) contains the name of the table row (starts with "TableCellView")
         if(StringFind(sparam,"TableCellView")==0)
           {
            // --- Get the row and column number from the event parameters
            int row=(int)lparam;
            int col=(int)dparam;
            
            string sep=";";                  // character delimiter
            ushort u_sep;                    // delimiter character code
            string result[];                 // array to receive strings
            
            // --- Get the separator code and divide sparam into substrings
            u_sep=StringGetCharacter(sep,0); 
            int n=StringSplit(sparam,u_sep,result);
            
            // --- There must be three substrings
            if(n==3)
              {
               // --- Get the row character and the column character
               string row_symb=result[1];
               string col_symb=result[2];
               
               // --- If the chart is not yet open, open it
               if(ExtSymbolsChart==0 || !IsExistChart(ExtSymbolsChart))
                  ExtSymbolsChart=OpenCharts(row_symb,col_symb);

               // --- If the chart is already open
               if(ExtSymbolsChart!=0)
                 {
                  // --- Set symbols for two graph objects and redraw the graph
                  ObjectSetString(ExtSymbolsChart,"ChartRowSymbol",OBJPROP_SYMBOL,row_symb);
                  ObjectSetString(ExtSymbolsChart,"ChartColSymbol",OBJPROP_SYMBOL,col_symb);
                  ChartRedraw(ExtSymbolsChart);
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
// | Includes characters from the array in the market overview |
//+------------------------------------------------------------------+
bool SymbolsSelect(string &array[])
  {
   bool res=true;
   for(int i=0;i<(int)array.Size();i++)
      res &=SymbolSelect(array[i],true);
   return res;
  }
//+------------------------------------------------------------------+
// | Returns a character at array index |
//+------------------------------------------------------------------+
string GetSymbolByIndex(const int index,string &array[])
  {
   int total=(int)array.Size();
   if(index<0 || index>total-1)
      return StringFormat("%s: Error. Invalid index (%d)",__FUNCTION__,index);
   return array[index];
  }
//+------------------------------------------------------------------+
// | Fills the character data matrix |
//+------------------------------------------------------------------+
bool SymbolsDataMatrixFill(const ENUM_TIMEFRAMES timeframe,string &array[],matrix &data,const int data_count)
  {
// --- In a loop by the number of characters in the array
   int total=(int)array.Size();
   for(int i=0; i<total; i++)
     {
      // --- get closing prices in data_count quantity
      double close[];
      int copied=CopyClose(array[i], timeframe, 0, data_count, close);
      if(copied!=data_count)
         return false;
      
      // --- Write prices into a row of the matrix so that cell 0 of the row corresponds to bar 0
      for(int j=0; j<data_count; j++)
        {
         string symbol=GetSymbolByIndex(i,array);
         int    digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
         data[i][data_count-1-j]=NormalizeDouble(close[j],digits);
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
// |Calculates a symmetric correlation matrix between all characters|
//+------------------------------------------------------------------+
bool SymbolsCorrelationMatrixSymmetric(const matrix &data, matrix &correlation)
  {
   int symb_total=(int)data.Rows();    // number of characters

// --- Set the size of the correlation matrix
   if(!correlation.Resize(symb_total,symb_total))
      return false;

// --- Outer loop over all characters (strings)
   for(int i=0;i<symb_total;i++)
     {
      // --- Get a time series of prices for symbol i
      vector vi=data.Row(i);
      // --- Inner loop through all characters (columns)
      for(int j=0;j<symb_total;j++)
        {
         // --- If the characters in the row and column are the same, then it is a correlation with itself
         if(i==j)
            correlation[i][j]=1.0;
         
         // --- Characters in row and column are different
         else
           {
            // --- We get a time series of prices for symbol j and calculate the correlation between symbols i and j
            vector vj=data.Row(j);
            correlation[i][j]=vi.CorrCoef(vj);
           }
        }
     }
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
// | Prints a symmetric correlation matrix in the journal |
//+------------------------------------------------------------------+
void SymbolsCorrelationMatrixSymmetricPrint(const string &symb_array[],matrix &correlation)
  {
// --- Create and print the header
   Print("Correlation matrix:");
   string header="        ";
   for(int j=0;j<(int)symb_array.Size();j++)
      header+=symb_array[j]+" ";
   Print(header);

// --- Print out the symbol correlation data
   for(int i=0;i<(int)symb_array.Size();i++)
     {
      string row=symb_array[i]+" ";
      for(int j=0;j<(int)symb_array.Size();j++)
         row+=DoubleToString(correlation[i][j],2)+" ";
      Print(row);
     }
  }
//+------------------------------------------------------------------+
// | Receives and calculates all necessary data |
//+------------------------------------------------------------------+
bool GetAndCalculateData(uint bars_total)
  {
// --- Getting values ​​for data by characters
   const int symb_total=(int)ExtSymbolsArray.Size();     // number of characters

// --- Change the size of the matrix: rows are symbols, columns are bars
   if(!ExtPricesData.Resize(symb_total,bars_total))
     {
      Print("Error. Failed to resize the symbol data matrix");
      return false;
     }

// --- Fill the matrix with symbol closing prices and assign a value to the data readiness flag
   ExtDataReady=SymbolsDataMatrixFill(InpTimeframe,ExtSymbolsArray,ExtPricesData,bars_total);
   if(!ExtDataReady)
      return false;
      
// --- Calculate the symmetric correlation matrix
   if(!SymbolsCorrelationMatrixSymmetric(ExtPricesData,ExtCorrelationMatrix))
     {
      Print("Error calculating correlation matrix");
      return false;
     }
   return true; 
  }
//+------------------------------------------------------------------+
// | Creates a table of symbols on the panel with data on their correlations |
//+------------------------------------------------------------------+
bool CreateTable(CTableControl *table_ctrl)
  {
// --- create table object 0 (Model + View component) inside the table control
// --- from the above created matrix ExtCorrelationMatrixSymmetric and
// --- string-array of symbols ExtSymbolsArray as column headers
   ExtTableView=table_ctrl.TableCreate(ExtCorrelationMatrix,ExtSymbolsArray,ExtSymbolsArray);
   if(ExtTableView==NULL)
      return false;
   
// --- Set the columns to display text in the center of the cell
   int total=(int)table_ctrl.RowsTotal(0);
   for(int i=0;i<total;i++)
     {
      table_ctrl.ColumnSetTextAnchor(0,i,ANCHOR_CENTER,true,false);
     }
   
// --- Set the table row highlighting mode for individual cells
   table_ctrl.SetRowsHighlightMode(0,ROWS_HIGHLIGHT_MODE_CELLS);
// --- and make the table unsortable
   table_ctrl.SetSortable(0,false);
   
// --- Let's draw and color the table in symbol correlation colors
   table_ctrl.Draw(false);
   UpdateTableValuesAndColors(table_ctrl.GetTableView(0),ExtCorrelationMatrix);
   
// --- Get the table model with index 0 and print it in the log
   CTable *table_model=table_ctrl.GetTableModel(0);
   table_model.Print(7);
   
// --- Everything is successful
   return true;
  }
//+------------------------------------------------------------------+
// | Updates table cell values ​​and colors based on the correlation matrix |
//+------------------------------------------------------------------+
void UpdateTableValuesAndColors(CTableView *table_view, matrix &corr_matrix)
  {
// --- Let's check the validity of the pointer to the table
   if(table_view==NULL)
      return;

// --- Number of rows and columns of the table
   int total_row=table_view.RowsTotal();
   int total_col=table_view.CellsInRow(0);

// --- Looping through table rows
   for(int r=0; r<total_row; r++)
     {
      // --- we get the next object for visual representation of the line
      CTableRowView *row_obj=table_view.GetRowView(r);
      if(row_obj==NULL)
         continue;
      // --- Getting the color control element
      CColorElement *ce=row_obj.GetBackColorControl();
      if(ce==NULL)
         continue;
      
      // --- In a loop by the number of cells in a row
      for(int c=0; c<total_col; c++)
        {
         // --- we get the next object of visual representation of the cell
         CTableCellView *cell=table_view.GetCellView(r,c);
         if(cell==NULL)
            continue;
         
         // --- Take the correlation value from the matrix
         double val=corr_matrix[r][c];
         // --- Update the cell text,
         cell.SetText(DoubleToString(val,2));
         // --- update the cell color
         color new_color=ce.InterpolateColorByCoeff(clrRed,clrYellow,clrGreen,val);
         cell.SetBackColor(new_color);
         
         // --- Redraw the cell (the graph is updated on the last cell of the table)
         bool flag=(r==total_row-1 && c==total_col-1 ? true : false); 
         cell.Draw(flag);
        }
     }
  }
//+------------------------------------------------------------------+
// | Returns the flag of the existence of a chart with the specified identifier|
//+------------------------------------------------------------------+
bool IsExistChart(const long id)
  {
// --- Variables for chart identifiers
   long curr_chart=0, prev_chart=0; 
   int i=0; 

// --- We go through all the charts
   while(!IsStopped() && i<CHARTS_MAX)
     { 
      // --- Based on the previous one, we get a new graph
      curr_chart=ChartNext(prev_chart);   // prev_chart==0 - get the first chart
      // --- If we have reached the end of the list of graphs, exit the loop
      if(curr_chart<0)
         break;
      // --- If the graph identifier matches the one you are looking for, such a graph exists
      if(curr_chart==id)
         return true;
      // --- Remember the identifier of the current chart for the next ChartNext()
      prev_chart=curr_chart;
      // --- increase the counter
      i++;
     }
// --- There is no required schedule
   return false;
  }
//+------------------------------------------------------------------+
// | Opens symbol charts |
//+------------------------------------------------------------------+
long OpenCharts(const string row_symb,const string col_symb)
  {
   // --- set the symbol and timeframe for the new chart
   string symbol=row_symb; 
   if(symbol==NULL || symbol=="") 
      symbol=Symbol(); 
    
// --- open a new chart with the specified symbol and period
   long id=ChartOpen(symbol,PERIOD_CURRENT);
   if(id==0) 
     { 
      Print("ChartOpen() failed. Error ", GetLastError()); 
      return 0; 
     }
// --- Unpin the chart and make it empty
   ChartSetInteger(id,CHART_IS_DOCKED,false);
   ChartSetInteger(id,CHART_SHOW,false);

// --- Get the coordinates of the sides of the detached chart
   int top=(int)ChartGetInteger(id,CHART_FLOAT_TOP);
   int bottom=(int)ChartGetInteger(id,CHART_FLOAT_BOTTOM);
   int left=(int)ChartGetInteger(id,CHART_FLOAT_LEFT);
   int right=(int)ChartGetInteger(id,CHART_FLOAT_RIGHT);
   
// --- Set new width and height of the graph
   ChartSetInteger(id,CHART_FLOAT_RIGHT,left+CHART_FLOAT_WIDTH);
   ChartSetInteger(id,CHART_FLOAT_BOTTOM,top+CHART_FLOAT_HEIGHT);
   
// --- Get the graph dimensions in pixels
   int cw=(int)ChartGetInteger(id,CHART_WIDTH_IN_PIXELS);
   int ch=(int)ChartGetInteger(id,CHART_HEIGHT_IN_PIXELS);
   
// --- Set the height for the top and bottom graphic objects
   int h0=(int)round(ch/2);
   int h1=ch-h0;
   
// --- Create two chart objects with row and column symbols on the detached chart
   if(!CreateChartObject(id,"ChartRowSymbol",row_symb,PERIOD_CURRENT,0,0,cw,h0))
      return 0;
   if(!CreateChartObject(id,"ChartColSymbol",col_symb,PERIOD_CURRENT,0,h0-1,cw,h1+1))
      return 0;
      
// --- Update the open chart and return its identifier
   ChartRedraw(id);
   return id;
  }
//+------------------------------------------------------------------+
// | Creates a graph object of the specified symbol |
//+------------------------------------------------------------------+
bool CreateChartObject(const long chart_id,const string name,const string symbol,const ENUM_TIMEFRAMES timeframe,const int x,const int y,const int w,const int h)
  {
// --- Create a graph object with the specified coordinates and dimensions
// --- and set its properties - symbol, period, coordinates and dimensions
   if(ObjectCreate(chart_id,name,OBJ_CHART,0,x,y,w,h))
     {
      ObjectSetString(chart_id,name,OBJPROP_SYMBOL,symbol);
      ObjectSetInteger(chart_id,name,OBJPROP_PERIOD,timeframe);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(chart_id,name,OBJPROP_XSIZE,w);
      ObjectSetInteger(chart_id,name,OBJPROP_YSIZE,h);
      return true;
     }
// --- Error creating graph object
   return false;
  } 
//+------------------------------------------------------------------+
