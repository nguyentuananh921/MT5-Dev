//+------------------------------------------------------------------+
//|                                               PriceExporter.mq5 |
//|                                Copyright 2024, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property copyright "Copyright 2024, Clemence Benjamin"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property version   "1.0"
#property description "Price Data Exporter"
#property strict
#property script_show_inputs

// Input parameters
input string ExportFileName = "PriceData.csv";       // Name of the file
input datetime StartTime = D'2023.01.01 00:00';       // Start time for data export
input datetime EndTime = D'2023.12.31 23:59';         // End time for data export
input ENUM_TIMEFRAMES TimeFrame = PERIOD_D1;          // Timeframe for data export
input double TimeScaleFactor = 60.0;                  // Timescale factor (e.g., 60 for 1 minute to 1 second)

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   string finalFileName = GenerateUniqueFileName(ExportFileName);
   ExportPriceData(finalFileName, StartTime, EndTime, TimeFrame, TimeScaleFactor);
  }
//+------------------------------------------------------------------+
//| Generate a unique file name if one already exists                |
//+------------------------------------------------------------------+
string GenerateUniqueFileName(string filename)
  {
   string name = filename;
   int counter = 1;
   
   while(FileIsExist(name))
     {
      name = StringFormat("%s_%d.csv", StringSubstr(filename, 0, StringFind(filename, ".csv")), counter);
      counter++;
     }
   
   return name;
  }
//+------------------------------------------------------------------+
//| Export price data to CSV file                                    |
//+------------------------------------------------------------------+
void ExportPriceData(string filename, datetime startTime, datetime endTime, ENUM_TIMEFRAMES timeframe, double timescale)
  {
   int handle = FileOpen(filename, FILE_WRITE|FILE_CSV, ',', CP_ACP);
   
   if(handle == INVALID_HANDLE)
     {
      Print("Error opening file: ", filename);
      return;
     }
   
   // Write the header
   FileWrite(handle, "Open", "Close", "Change", "Duration");
   
   // Get the total number of bars in the specified time frame
   int totalBars = iBars(_Symbol, timeframe);
   
   // Loop through the bars and collect data within the specified time range
   for(int i = totalBars - 1; i > 0; i--)
     {
      datetime time = iTime(_Symbol, timeframe, i);
      datetime nextTime = iTime(_Symbol, timeframe, i - 1); // Time of the next bar
      
      // Check if the bar's time is within the specified range
      if(time >= startTime && time <= endTime)
        {
         double open = iOpen(_Symbol, timeframe, i);
         double close = iClose(_Symbol, timeframe, i);
         double change = close - open;
         change = NormalizeDouble(change, 3);  // Round to 3 decimal places
         
         // Calculate duration in seconds and apply timescale factor
         double duration = (nextTime - time) / timescale;
         
         // Write data to file
         FileWrite(handle, open, close, change, duration);
        }
     }
   
   FileClose(handle);
   Print("Export completed. File: ", filename);
  }
//+------------------------------------------------------------------+
