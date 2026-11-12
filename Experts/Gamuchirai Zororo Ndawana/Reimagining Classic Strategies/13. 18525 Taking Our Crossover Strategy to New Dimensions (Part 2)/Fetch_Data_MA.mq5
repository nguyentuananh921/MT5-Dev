//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

//--- Define our moving average indicator
#define MA_PERIOD 2                 //--- Moving Average Period
#define MA_TYPE   MODE_SMA          //--- Type of moving average we have
#define HORIZON   5                 //--- Forecast horizon

//--- Our handlers for our indicators
int ma_handle,ma_o_handle,ma_h_handle,ma_l_handle;

//--- Data structures to store the readings from our indicators
double ma_reading[],ma_o_reading[],ma_h_reading[],ma_l_reading[];

//--- File name
string file_name = Symbol() + " Market Data As Series Moving Average.csv";

//--- Amount of data requested
input int size = 3000;

//+------------------------------------------------------------------+
//| Our script execution                                             |
//+------------------------------------------------------------------+
void OnStart()
  {
  int fetch = size + (HORIZON * 2);
//---Setup our technical indicators
   ma_handle = iMA(_Symbol,PERIOD_CURRENT,MA_PERIOD,0,MA_TYPE,PRICE_CLOSE);
   ma_o_handle = iMA(_Symbol,PERIOD_CURRENT,MA_PERIOD,0,MA_TYPE,PRICE_OPEN);
   ma_h_handle = iMA(_Symbol,PERIOD_CURRENT,MA_PERIOD,0,MA_TYPE,PRICE_HIGH);
   ma_l_handle = iMA(_Symbol,PERIOD_CURRENT,MA_PERIOD,0,MA_TYPE,PRICE_LOW);

//---Set the values as series
   CopyBuffer(ma_handle,0,0,fetch,ma_reading);
   ArraySetAsSeries(ma_reading,true);
   CopyBuffer(ma_o_handle,0,0,fetch,ma_o_reading);
   ArraySetAsSeries(ma_o_reading,true);
   CopyBuffer(ma_h_handle,0,0,fetch,ma_h_reading);
   ArraySetAsSeries(ma_h_reading,true);
   CopyBuffer(ma_l_handle,0,0,fetch,ma_l_reading);
   ArraySetAsSeries(ma_l_reading,true);

//---Write to file
   int file_handle=FileOpen(file_name,FILE_WRITE|FILE_ANSI|FILE_CSV,",");

   for(int i=size;i>=1;i--)
     {
      if(i == size)
        {
         FileWrite(file_handle,"Time",
                              //--- OHLC
                              "True Open",
                              "True High",
                              "True Low",
                              "True Close",
                              //--- MA OHLC
                              "True MA C",
                              "True MA O",
                              "True MA H",
                              "True MA L",
                              //--- Growth in OHLC
                              "Diff Open",
                              "Diff High",
                              "Diff Low",
                              "Diff Close",
                              //--- Growth in MA OHLC
                              "Diff MA Close 2",
                              "Diff MA Open 2",
                              "Diff MA High 2",
                              "Diff MA Low 2",
                              //--- Grwoth between channels
                              "O - C",
                              "Delta O - C",
                              "O - L",
                              "Delta O - L",
                              "O - H",
                              "Delta O - H",
                              "H - L",
                              "Delta H - L",
                              "C - H",
                              "Delta C - H",
                              "C - L",
                              "Delta C - L",
                              //--- Grwoth between MA channels
                              "MA O - C",
                              "MA Delta O - C",
                              "MA O - L",
                              "MA Delta O - L",
                              "MA O - H",
                              "MA Delta O - H",
                              "MA H - L",
                              "MA Delta H - L",
                              "MA C - H",
                              "MA Delta C - H",
                              "MA C - L",
                              "MA Delta C - L"
                  );
        }

      else
        {
         FileWrite(file_handle,
                   iTime(_Symbol,PERIOD_CURRENT,i), 
                   //--- OHLC
                   iOpen(_Symbol,PERIOD_CURRENT,i),
                   iHigh(_Symbol,PERIOD_CURRENT,i),
                   iLow(_Symbol,PERIOD_CURRENT,i),
                   iClose(_Symbol,PERIOD_CURRENT,i),
                   //--- MA OHLC
                   ma_reading[i],
                   ma_o_reading[i],
                   ma_h_reading[i],
                   ma_l_reading[i],
                   //--- Growth in OHLC
                   iOpen(_Symbol,PERIOD_CURRENT,i)   - iOpen(_Symbol,PERIOD_CURRENT,(i + HORIZON)), 
                   iHigh(_Symbol,PERIOD_CURRENT,i)   - iHigh(_Symbol,PERIOD_CURRENT,(i + HORIZON)),
                   iLow(_Symbol,PERIOD_CURRENT,i)    - iLow(_Symbol,PERIOD_CURRENT,(i + HORIZON)),
                   iClose(_Symbol,PERIOD_CURRENT,i)  - iClose(_Symbol,PERIOD_CURRENT,(i + HORIZON)),
                   //--- Growth in MA OHLC
                   ma_reading[i] - ma_reading[(i + HORIZON)],
                   ma_o_reading[i] - ma_o_reading[(i + HORIZON)],
                   ma_h_reading[i] - ma_h_reading[(i + HORIZON)],
                   ma_l_reading[i] - ma_l_reading[(i + HORIZON)],
                   //--- Growth between channels
                   iOpen(_Symbol,PERIOD_CURRENT,i) - iClose(_Symbol,PERIOD_CURRENT,i),
                   iOpen(_Symbol,PERIOD_CURRENT,i + HORIZON) - iClose(_Symbol,PERIOD_CURRENT,i + HORIZON),
                   iOpen(_Symbol,PERIOD_CURRENT,i) - iLow(_Symbol,PERIOD_CURRENT,i),
                   iOpen(_Symbol,PERIOD_CURRENT,i + HORIZON) - iLow(_Symbol,PERIOD_CURRENT,i + HORIZON),
                   iOpen(_Symbol,PERIOD_CURRENT,i) - iHigh(_Symbol,PERIOD_CURRENT,i),
                   iOpen(_Symbol,PERIOD_CURRENT,i + HORIZON) - iHigh(_Symbol,PERIOD_CURRENT,i + HORIZON),
                   iHigh(_Symbol,PERIOD_CURRENT,i) - iLow(_Symbol,PERIOD_CURRENT,i),
                   iHigh(_Symbol,PERIOD_CURRENT,i + HORIZON) - iLow(_Symbol,PERIOD_CURRENT,i + HORIZON),
                   iClose(_Symbol,PERIOD_CURRENT,i)  -  iHigh(_Symbol,PERIOD_CURRENT,i),
                   iClose(_Symbol,PERIOD_CURRENT,i + HORIZON)  -  iHigh(_Symbol,PERIOD_CURRENT,i + HORIZON),
                   iClose(_Symbol,PERIOD_CURRENT,i)  -  iLow(_Symbol,PERIOD_CURRENT,i),
                   iClose(_Symbol,PERIOD_CURRENT,i + HORIZON)  -  iLow(_Symbol,PERIOD_CURRENT,i + HORIZON),
                   //--- Growth between moving average channels
                   ma_o_reading[i] - ma_reading[i],
                   ma_o_reading[(i + HORIZON)] -  ma_reading[(i + HORIZON)],
                   ma_o_reading[i] -  ma_l_reading[i],
                   ma_o_reading[(i + HORIZON)] - ma_l_reading[(i + HORIZON)],
                   ma_o_reading[i] -  ma_h_reading[i],
                   ma_o_reading[(i + HORIZON)] - ma_h_reading[(i + HORIZON)],
                   ma_h_reading[i] - ma_l_reading[i],
                   ma_h_reading[(i + HORIZON)] - ma_l_reading[(i + HORIZON)],
                   ma_reading[i] -  ma_h_reading[i],
                   ma_reading[(i + HORIZON)] - ma_h_reading[(i + HORIZON)],
                   ma_reading[i] -  ma_l_reading[i],
                   ma_reading[(i + HORIZON)] - ma_l_reading[(i + HORIZON)]
                   );
        }
     }
//--- Close the file
   FileClose(file_handle);
  }
//+------------------------------------------------------------------+
