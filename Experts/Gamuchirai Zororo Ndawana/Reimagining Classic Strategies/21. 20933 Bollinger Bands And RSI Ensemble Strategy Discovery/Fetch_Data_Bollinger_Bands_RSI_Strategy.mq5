//+------------------------------------------------------------------+
//|                          Fetch Data Bollinger Bands RSI Strategy |
//|                                      Copyright 2026, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

//+------------------------------------------------------------------+
//| System definitions                                               |
//+------------------------------------------------------------------+
#define BB_PERIOD     30
#define BB_SD         2
#define BB_PRICE      PRICE_CLOSE
#define RSI_PERIOD    15
#define RSI_PRICE     PRICE_CLOSE
#define RSI_LEVEL_MAX 70
#define RSI_LEVEL_MIN 30
#define TF_MAIN       PERIOD_D1
#define SHIFT         0

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double   bb_upper[],bb_mid[],bb_lower[],rsi[];

//--- Setup the technical indicators
int bb_handler  = iBands(Symbol(),TF_MAIN,BB_PERIOD,SHIFT,BB_SD,BB_PRICE);
int rsi_handler = iRSI(Symbol(),TF_MAIN,RSI_PERIOD,RSI_PRICE);

//--- File name
string file_name = Symbol() + " Bollinger Band RSI Data.csv";

//--- Amount of data requested
input int size = 365;

//+------------------------------------------------------------------+
//| Our script execution                                             |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Write to file
   int file_handle=FileOpen(file_name,FILE_WRITE|FILE_ANSI|FILE_CSV,",");
   
   CopyBuffer(bb_handler,0,0,size,bb_mid);
   ArraySetAsSeries(bb_mid,true);
   CopyBuffer(bb_handler,1,0,size,bb_upper);
   ArraySetAsSeries(bb_upper,true);
   CopyBuffer(bb_handler,2,0,size,bb_lower);
   ArraySetAsSeries(bb_lower,true);
   CopyBuffer(rsi_handler,0,0,size,rsi);
   ArraySetAsSeries(rsi,true);
   
   for(int i=size;i>=1;i--)
     {
      if(i == size)
        {
        
         FileWrite(file_handle,
                  //--- Time
                  "Time",
                   //--- OHLC
                   "Open",
                   "High",
                   "Low",
                   "Close",
                   //--- Technical Indicators
                   "BB Upper",
                   "BB Mid",
                   "BB Lower",
                   "RSI"
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
                   //--- Technical Indicators
                   bb_upper[i],
                   bb_mid[i],
                   bb_lower[i],
                   rsi[i]
                   );
        }
     }
//--- Close the file
   FileClose(file_handle);
  }
//+------------------------------------------------------------------+