#property copyright "Copyright 2026, Anhnt"
#property script_show_inputs
//--- Writes the buffers of the MT5 indicators (closed bars, oldest first) to MQL5\Files\<script name>\parity_<IND>.csv;
//--- Python\parity.py reads them and recalculates the same indicator with the same parameters
 input int              InpBars         = 3000;          // closed bars exported per indicator
 input double           InpSarStep      = 0.02;
 input double           InpSarMaximum   = 0.2;
 input int              InpMaPeriod     = 20;
 input ENUM_MA_METHOD   InpMaMethod     = MODE_EMA;
 input ENUM_APPLIED_PRICE InpMaApplied  = PRICE_CLOSE;
 input int              InpRsiPeriod    = 14;
 input ENUM_APPLIED_PRICE InpRsiApplied = PRICE_CLOSE;
 input int              InpMacdFast     = 12;
 input int              InpMacdSlow     = 26;
 input int              InpMacdSignal   = 9;
 input ENUM_APPLIED_PRICE InpMacdApplied = PRICE_CLOSE;
 input int              InpBandsPeriod  = 20;
 input double           InpBandsDeviation = 2.0;
 input ENUM_APPLIED_PRICE InpBandsApplied = PRICE_CLOSE;
 input int              InpAdxPeriod    = 14;

 string TimeframeText(const ENUM_TIMEFRAMES tf)
  {
   string text = ::EnumToString(tf);
   ::StringReplace(text, "PERIOD_", "");
   return text;
  }

 string Applied(const ENUM_APPLIED_PRICE price)
  {
   return ::EnumToString(price);
  }

 //--- pick: the MT5 buffer index of each exported column ("" = 0..buffers-1); tag: file name suffix when the same indicator is exported twice
 bool Export(const string name, const int handle, const int buffers, const string params, const string pick = "", const string tag = "")
  {
   if(handle == INVALID_HANDLE)
     {
      ::Print(__FUNCTION__, ": ", name, " handle failed, error ", ::GetLastError());
      return false;
     }
   string symbol = ::Symbol();
   ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::Period();
   for(int wait = 0; wait < 100 && ::BarsCalculated(handle) < InpBars + 1; wait++)
      ::Sleep(100);
   datetime times[];
   if(::CopyTime(symbol, tf, 1, InpBars, times) != InpBars)
     {
      ::Print(__FUNCTION__, ": ", name, " CopyTime failed, error ", ::GetLastError());
      return false;
     }
   int source[8];
   string picked[];
   int picked_total = (pick == "" ? 0 : ::StringSplit(pick, ',', picked));
   for(int b = 0; b < buffers; b++)
      source[b] = (b < picked_total ? (int)::StringToInteger(picked[b]) : b);
   double columns[];
   double values[][8];
   ::ArrayResize(values, InpBars);
   for(int b = 0; b < buffers; b++)
     {
      if(::CopyBuffer(handle, source[b], 1, InpBars, columns) != InpBars)
        {
         ::Print(__FUNCTION__, ": ", name, " CopyBuffer ", source[b], " failed, error ", ::GetLastError());
         return false;
        }
      for(int i = 0; i < InpBars; i++)
         values[i][b] = columns[i];
     }
   string file = ::MQLInfoString(MQL_PROGRAM_NAME) + "\\parity_" + (tag == "" ? name : tag) + ".csv";
   int h = ::FileOpen(file, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
     {
      ::Print(__FUNCTION__, ": cannot open ", file, ", error ", ::GetLastError());
      return false;
     }
   ::FileWriteString(h, "#ind=" + name + ";symbol=" + symbol + ";tf=" + TimeframeText(tf) + ";" + params + (tag == "" ? "" : ";tag=" + tag) + "\n");
   string head = "time";
   for(int b = 0; b < buffers; b++)
      head += ",b" + (string)b;
   ::FileWriteString(h, head + "\n");
   for(int i = 0; i < InpBars; i++)
     {
      string line = (string)(long)times[i];
      for(int b = 0; b < buffers; b++)
         line += "," + (values[i][b] == EMPTY_VALUE ? "nan" : ::DoubleToString(values[i][b], 10));
      ::FileWriteString(h, line + "\n");
     }
   ::FileClose(h);
   ::Print(__FUNCTION__, ": ", name, " ", InpBars, " bars written to ", file);
   return true;
  }

 void OnStart(void)
  {
   string symbol = ::Symbol();
   ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::Period();
   Export("SAR", ::iSAR(symbol, tf, InpSarStep, InpSarMaximum), 1,
          "step=" + ::DoubleToString(InpSarStep, 6) + ";maximum=" + ::DoubleToString(InpSarMaximum, 6));
   Export("MA", ::iMA(symbol, tf, InpMaPeriod, 0, InpMaMethod, InpMaApplied), 1,
          "period=" + (string)InpMaPeriod + ";method=" + ::EnumToString(InpMaMethod) + ";applied=" + Applied(InpMaApplied));
   Export("RSI", ::iRSI(symbol, tf, InpRsiPeriod, InpRsiApplied), 1,
          "period=" + (string)InpRsiPeriod + ";applied=" + Applied(InpRsiApplied));
   Export("MACD", ::iMACD(symbol, tf, InpMacdFast, InpMacdSlow, InpMacdSignal, InpMacdApplied), 2,
          "fast=" + (string)InpMacdFast + ";slow=" + (string)InpMacdSlow + ";signal=" + (string)InpMacdSignal + ";applied=" + Applied(InpMacdApplied));
   Export("BANDS", ::iBands(symbol, tf, InpBandsPeriod, 0, InpBandsDeviation, InpBandsApplied), 3,
          "period=" + (string)InpBandsPeriod + ";deviation=" + ::DoubleToString(InpBandsDeviation, 4) + ";applied=" + Applied(InpBandsApplied));
   Export("ADX", ::iADX(symbol, tf, InpAdxPeriod), 3, "period=" + (string)InpAdxPeriod);

   //--- Every other indicator of the EA form with the form defaults; the parameter names are the keys of Python TEMPLATE_TYPES
   //--- (no parameter: "none=1", the header must not end in an empty item)
   string alligator = "jaw_period=13;jaw_shift=8;teeth_period=8;teeth_shift=5;lips_period=5;lips_shift=3;method=MODE_SMMA;applied=PRICE_MEDIAN";
   Export("ALLIGATOR", ::iAlligator(symbol, tf, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN), 3, alligator);
   Export("GATOR", ::iGator(symbol, tf, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN), 2, alligator, "0,2");
   Export("ICHIMOKU", ::iIchimoku(symbol, tf, 9, 26, 52), 5, "tenkan=9;kijun=26;senkou_b=52");
   Export("ENVELOPES", ::iEnvelopes(symbol, tf, 14, 0, MODE_SMA, PRICE_CLOSE, 0.1), 2, "period=14;shift=0;method=MODE_SMA;applied=PRICE_CLOSE;deviation=0.1");
   Export("FRAMA", ::iFrAMA(symbol, tf, 14, 0, PRICE_CLOSE), 1, "period=14;shift=0;applied=PRICE_CLOSE");
   Export("AMA", ::iAMA(symbol, tf, 9, 2, 30, 0, PRICE_CLOSE), 1, "ama_period=9;fast=2;slow=30;shift=0;applied=PRICE_CLOSE");
   Export("DEMA", ::iDEMA(symbol, tf, 14, 0, PRICE_CLOSE), 1, "period=14;shift=0;applied=PRICE_CLOSE");
   Export("TEMA", ::iTEMA(symbol, tf, 14, 0, PRICE_CLOSE), 1, "period=14;shift=0;applied=PRICE_CLOSE");
   Export("VIDYA", ::iVIDyA(symbol, tf, 9, 12, 0, PRICE_CLOSE), 1, "cmo_period=9;ema_period=12;shift=0;applied=PRICE_CLOSE");
   Export("ADXW", ::iADXWilder(symbol, tf, 14), 3, "period=14");
   Export("STDDEV", ::iStdDev(symbol, tf, 20, 0, MODE_SMA, PRICE_CLOSE), 1, "period=20;shift=0;method=MODE_SMA;applied=PRICE_CLOSE");
   Export("STOCHASTIC", ::iStochastic(symbol, tf, 5, 3, 3, MODE_SMA, STO_LOWHIGH), 2, "k=5;d=3;slowing=3;method=MODE_SMA;field=LOWHIGH");
   Export("CCI", ::iCCI(symbol, tf, 14, PRICE_TYPICAL), 1, "period=14;applied=PRICE_TYPICAL");
   Export("MOMENTUM", ::iMomentum(symbol, tf, 14, PRICE_CLOSE), 1, "period=14;applied=PRICE_CLOSE");
   Export("DEMARKER", ::iDeMarker(symbol, tf, 14), 1, "period=14");
   Export("RVI", ::iRVI(symbol, tf, 10), 2, "period=10");
   Export("WPR", ::iWPR(symbol, tf, 14), 1, "period=14");
   Export("OSMA", ::iOsMA(symbol, tf, 12, 26, 9, PRICE_CLOSE), 1, "fast=12;slow=26;signal=9;applied=PRICE_CLOSE");
   Export("TRIX", ::iTriX(symbol, tf, 14, PRICE_CLOSE), 1, "period=14");
   Export("ATR", ::iATR(symbol, tf, 14), 1, "period=14");
   Export("FORCE", ::iForce(symbol, tf, 13, MODE_EMA, VOLUME_TICK), 1, "period=13;method=MODE_EMA;volume=TICK");
   Export("AO", ::iAO(symbol, tf), 1, "none=1", "0");
   Export("AC", ::iAC(symbol, tf), 1, "none=1", "0");
   Export("BEARS", ::iBearsPower(symbol, tf, 13), 1, "period=13");
   Export("BULLS", ::iBullsPower(symbol, tf, 13), 1, "period=13");
   Export("CHAIKIN", ::iChaikin(symbol, tf, 3, 10, MODE_EMA, VOLUME_TICK), 1, "fast=3;slow=10;method=MODE_EMA;volume=TICK");
   Export("OBV", ::iOBV(symbol, tf, VOLUME_TICK), 1, "volume=TICK");
   Export("AD", ::iAD(symbol, tf, VOLUME_TICK), 1, "volume=TICK");
   Export("MFI", ::iMFI(symbol, tf, 14, VOLUME_TICK), 1, "period=14");
   Export("VOLUMES", ::iVolumes(symbol, tf, VOLUME_TICK), 1, "volume=TICK", "0");
   Export("BWMFI", ::iBWMFI(symbol, tf, VOLUME_TICK), 1, "none=1", "0");
   Export("FRACTALS", ::iFractals(symbol, tf), 2, "none=1");
   //--- Shifted lines: the value of the buffer at a bar must be the one calculated "shift" bars before (Python shifted())
   Export("MA", ::iMA(symbol, tf, 14, 3, MODE_SMA, PRICE_CLOSE), 1, "period=14;shift=3;method=MODE_SMA;applied=PRICE_CLOSE", "", "MA_SHIFT3");
   Export("BANDS", ::iBands(symbol, tf, 20, 2, 2.0, PRICE_CLOSE), 3, "period=20;shift=2;deviation=2.0;applied=PRICE_CLOSE", "", "BANDS_SHIFT2");
  }
