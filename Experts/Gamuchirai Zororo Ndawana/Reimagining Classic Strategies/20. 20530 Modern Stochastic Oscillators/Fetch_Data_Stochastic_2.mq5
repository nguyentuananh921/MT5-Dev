//+------------------------------------------------------------------+
//|                                            Fetch Data Mid Points |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

//--- File name
string file_name = Symbol() + " Stochastic Strategy.csv";

int stoch_handler = iStochastic(Symbol(),PERIOD_CURRENT,5,3,3,MODE_EMA,STO_LOWHIGH);
double stoch_main[],stoch_signal[];
double stoch_o,stoch_h,stoch_l;

//--- Amount of data requested
input int size = 365;

//+------------------------------------------------------------------+
//| Our script execution                                             |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Write to file
   int file_handle=FileOpen(file_name,FILE_WRITE|FILE_ANSI|FILE_CSV,",");

//--- 
   CopyBuffer(stoch_handler,0,0,size,stoch_main);
   stoch_o = stoch_main[0];
   stoch_h = stoch_main[0];
   stoch_l = stoch_main[0];
   ArraySetAsSeries(stoch_main,true);
   CopyBuffer(stoch_handler,1,0,size,stoch_signal);
   ArraySetAsSeries(stoch_signal,true);
   

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
                   //--- Stochastic Readings
                   "Stochastic Main",
                   "Stochastic Signal",
                   //--- Feature Engineering Stochastic Oscilator
                   "Stoch Main - Signal",
                   "Stoch M-S Mid",
                   "Stoch - 80",
                   "Stoch - 20",
                   "Stoch O",
                   "Stoch H",
                   "Stoch L",
                   "Stoch O-C",
                   "Stoch H-C",
                   "Stoch L-C"
                  );
        }

      else
        {
        
        //--- Set features
        stoch_h = (stoch_h < stoch_main[i]) ? stoch_main[i] : stoch_h;
        stoch_l = (stoch_l > stoch_main[i]) ? stoch_main[i] : stoch_l;
        
         FileWrite(file_handle,
                   iTime(_Symbol,PERIOD_CURRENT,i),
                   //--- OHLC
                   iOpen(_Symbol,PERIOD_CURRENT,i),
                   iHigh(_Symbol,PERIOD_CURRENT,i),
                   iLow(_Symbol,PERIOD_CURRENT,i),
                   iClose(_Symbol,PERIOD_CURRENT,i),
                   //--- Stochastic Readings
                   stoch_main[i],
                   stoch_signal[i],
                   //--- Stochastic Feature Engineering
                   stoch_main[i] - stoch_signal[i],
                   ((stoch_main[i] + stoch_signal[i])/2),
                   (stoch_main[i] - 80),
                   (stoch_main[i] - 20),
                   stoch_o,
                   stoch_h,
                   stoch_l,
                   stoch_o - stoch_main[i],
                   stoch_h - stoch_main[i],
                   stoch_l - stoch_main[i]
                   );
        }
     }
//--- Close the file
   FileClose(file_handle);
  }
//+------------------------------------------------------------------+