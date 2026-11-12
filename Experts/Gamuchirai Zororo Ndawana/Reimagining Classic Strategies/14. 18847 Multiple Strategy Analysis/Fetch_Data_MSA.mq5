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
#define MA_PERIOD  100               //--- Period for our moving average
#define MA_TYPE    MODE_EMA          //--- Type of moving average we have 
#define RSI_PERIOD 24                //--- Period For Our RSI Indicator
#define RSI_PRICE  PRICE_CLOSE       //--- Applied Price For our RSI Indicator
#define HORIZON    38                //--- Holding period
#define TF PERIOD_H3                 //--- Time Frame

//--- Our handlers for our indicators
int ma_handle,ma_o_handle,rsi_handle;

//--- Data structures to store the readings from our indicators
double ma_reading[],ma_o_reading[],rsi_reading[];

//--- File name
string file_name = Symbol() + " Market Data As Series Multiple Strategy Analysis.csv";

//--- Amount of data requested
input int size = 3000;

//+------------------------------------------------------------------+
//| Our script execution                                             |
//+------------------------------------------------------------------+
void OnStart()
  {
  int fetch = size + (HORIZON * 2);
//---Setup our technical indicators
   ma_handle = iMA(_Symbol,TF,MA_PERIOD,0,MA_TYPE,PRICE_CLOSE);
   ma_o_handle = iMA(_Symbol,TF,MA_PERIOD,0,MA_TYPE,PRICE_OPEN);
   rsi_handle = iRSI(_Symbol,TF,RSI_PERIOD,RSI_PRICE);

//---Set the values as series
   CopyBuffer(ma_handle,0,0,fetch,ma_reading);
   ArraySetAsSeries(ma_reading,true);
   CopyBuffer(ma_o_handle,0,0,fetch,ma_o_reading);
   ArraySetAsSeries(ma_o_reading,true);
   CopyBuffer(rsi_handle,0,0,fetch,rsi_reading);
   ArraySetAsSeries(rsi_reading,true);

//---Write to file
   int file_handle=FileOpen(file_name,FILE_WRITE|FILE_ANSI|FILE_CSV,",");

   for(int i=size;i>=1;i--)
     {
      if(i == size)
        {
         FileWrite(file_handle,"Time","True Open","True High","True Low","True Close","True MA C","True MA O","True RSI","Open","High","Low","Close","MA Close","MA Open","RSI");
        }

      else
        {
         FileWrite(file_handle,
                   iTime(_Symbol,TF,i), 
                   iOpen(_Symbol,TF,i),
                   iHigh(_Symbol,TF,i),
                   iLow(_Symbol,TF,i),
                   iClose(_Symbol,TF,i),
                   ma_reading[i],
                   ma_o_reading[i],
                   rsi_reading[i],
                   iOpen(_Symbol,TF,i)   - iOpen(_Symbol,TF,(i + HORIZON)), 
                   iHigh(_Symbol,TF,i)   - iHigh(_Symbol,TF,(i + HORIZON)),
                   iLow(_Symbol,TF,i)    - iLow(_Symbol,TF,(i + HORIZON)),
                   iClose(_Symbol,TF,i)  - iClose(_Symbol,TF,(i + HORIZON)),
                   ma_reading[i] - ma_reading[(i + HORIZON)],
                   ma_o_reading[i] - ma_o_reading[(i + HORIZON)],
                   rsi_reading[i] - rsi_reading[(i + HORIZON)]
                   );
        }
     }
//--- Close the file
   FileClose(file_handle);
  }
//+------------------------------------------------------------------+
