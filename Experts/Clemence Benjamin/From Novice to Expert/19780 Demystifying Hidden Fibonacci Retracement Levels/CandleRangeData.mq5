//+------------------------------------------------------------------+
//| CandleRangeData.mq5                                           |
//| Collect bar-range retracement observations, emphasize "same-dir" |
//| - SameDirSupport flag, RetracePips, RetracePct, NearestFibPct    |
//| - Auto filename CandleRangeData_<SYMBOL>_<TF>.csv                |
//| - ISO timestamp (YYYY-MM-DDTHH:MM:SS)                            |
//+------------------------------------------------------------------+
#property script_show_inputs
#property copyright "Clemence Benjamin"
#property version   "1.0"

//--- Input configuration
input int    BarsToProcess           = 20000;      // Max observations to write
input int    StartShift              = 2;          // Reference bar shift (2 = two bars back)
input int    ATR_Period              = 14;         // ATR period
input double ATR_Multiplier          = 0.5;        // Minimum range = ATR * multiplier
input bool   UseExtendedWindow       = true;       // allow lookahead merging of inside bars
input int    MaxLookaheadBars        = 5;          // max bars to look ahead when extending
input int    MaxInsideBars           = 4;          // limit for inside-bar collapse
input bool   UsePerfectSetupFilter   = true;       // require open in range and close not against direction
input bool   IncludeInvalidRows      = false;      // write invalid rows too (for diagnostics)
input bool   IncludeSpread           = true;       // include current spread in CSV
input bool   OutputOnlySameDir       = true;       // output only observations where the test bar supports same direction
input string OutFilePrefix           = "CandleRangeData"; // prefix for auto filename

//--- Standard Fibonacci levels to compare (percent)
double ClassicFibs[] = {23.6, 38.2, 50.0, 61.8, 78.6, 100.0};

//+------------------------------------------------------------------+
//| helper: format double                                             |
//+------------------------------------------------------------------+
string fmt(double v,int d)
  {
   return(DoubleToString(v,d));
  }

//+------------------------------------------------------------------+
//| map Period int to readable label                                 |
//+------------------------------------------------------------------+
string PeriodToString(int period)
  {
   switch(period)
     {
      case PERIOD_M1:  return "M1";
      case PERIOD_M5:  return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN";
      default:         return IntegerToString(period);
     }
  }

//+------------------------------------------------------------------+
void OnStart()
  {
   // prepare file flags
   int file_flags = FILE_WRITE|FILE_CSV|FILE_ANSI;

   // generate human TF label and filename
   string tf_label = PeriodToString(_Period);
   string OutFileName = StringFormat("%s_%s_%s.csv", OutFilePrefix, _Symbol, tf_label);

   // open file
   int fh = FileOpen(OutFileName, file_flags);
   if(fh == INVALID_HANDLE)
     {
      Print("Failed to open file '", OutFileName, "'. Error=", GetLastError());
      return;
     }

   // Write header (added new diagnostic columns)
   FileWrite(fh,
             "Symbol","Timeframe","ObsTime",
             "RefTop","RefBot","Range","RefDir",
             "Ext","RetracePips","RetracePct","Type",
             "SeqType","InsideCount","LookaheadUsed","GapSize","HighMomentum",
             "SameDirSupport","NearestFibPct","NearestFibDistPct",
             "ValidSetup","InvalidReason",
             "Volume","Spread_pips");

   // ATR handle
   int atr_handle = iATR(_Symbol, _Period, ATR_Period);
   if(atr_handle == INVALID_HANDLE)
     {
      Print("Failed to create ATR handle. Error=", GetLastError());
      FileClose(fh);
      return;
     }

   int bars = iBars(_Symbol, _Period);
   if(bars < (StartShift+1))
     {
      PrintFormat("Not enough bars (need at least %d). Bars available: %d", StartShift+1, bars);
      IndicatorRelease(atr_handle);
      FileClose(fh);
      return;
     }

   int written = 0;
   int invalid_count = 0;

   // iterate reference bars r = StartShift .. bars-1 (r indexes closed bars)
   for(int r = StartShift; r <= bars - 1 && written < BarsToProcess; r++)
     {
      // reference bar (closed)
      double RefTop = iHigh(_Symbol,_Period,r);
      double RefBot = iLow(_Symbol,_Period,r);
      double Range  = RefTop - RefBot;
      if(Range <= 0.0) continue;

      // ATR at reference bar
      double atr_buf[];
      if(CopyBuffer(atr_handle,0,r,1,atr_buf) <= 0) continue;
      double atr_val = atr_buf[0];
      if(atr_val <= 0.0) continue;
      if(Range < atr_val * ATR_Multiplier) // small noisy range
         continue;

      // reference open/close to determine direction
      double RefOpen  = iOpen(_Symbol,_Period,r);
      double RefClose = iClose(_Symbol,_Period,r);
      string RefDir = "Neutral";
      if(RefClose > RefOpen) RefDir = "Bull";
      else if(RefClose < RefOpen) RefDir = "Bear";

      // Prepare validation and sequence metadata
      bool ValidSetup = true;
      string InvalidReason = "";
      string SeqType = "Single";
      int InsideCount = 0;
      int LookaheadUsed = 0;
      double GapSize = 0.0;
      bool HighMomentum = false;

      // Test-bar initial index (the bar immediately after reference)
      int testIndex = r - 1;
      if(testIndex < 0) continue;

      double testOpen  = iOpen(_Symbol,_Period,testIndex);
      double testClose = iClose(_Symbol,_Period,testIndex);
      double testHigh  = iHigh(_Symbol,_Period,testIndex);
      double testLow   = iLow(_Symbol,_Period,testIndex);

      // Perfect-setup validation applied to initial test bar (if enabled)
      if(UsePerfectSetupFilter)
        {
         if(testOpen < RefBot || testOpen > RefTop)
           {
            ValidSetup = false;
            InvalidReason = "OpenOutsideRange";
           }
         if(ValidSetup)
           {
            if(RefDir == "Bull" && testClose < testOpen)
              {
               ValidSetup = false;
               InvalidReason = "CloseAgainstDirection";
              }
            else if(RefDir == "Bear" && testClose > testOpen)
              {
               ValidSetup = false;
               InvalidReason = "CloseAgainstDirection";
              }
            else if(RefDir == "Neutral")
              {
               ValidSetup = false;
               InvalidReason = "NeutralRef";
              }
           }
        }

      if(!ValidSetup && !IncludeInvalidRows)
        {
         invalid_count++;
         continue;
        }

      // Extended-window handling (inside, engulf, gap) OR simple single-bar test
      double Ext = 0.0;
      double Rpct = 0.0;
      string Type = "NoRetrace";

      if(UseExtendedWindow)
        {
         // initialize Ext with initial test bar extreme depending on direction
         if(RefDir == "Bull") Ext = testLow;
         else if(RefDir == "Bear") Ext = testHigh;
         else Ext = iClose(_Symbol,_Period,testIndex);

         LookaheadUsed = 1;
         InsideCount = 0;
         SeqType = "Single";

         if(testOpen > RefTop || testOpen < RefBot)
           {
            SeqType = "Gap";
            GapSize = MathMin(MathAbs(testOpen - RefTop), MathAbs(testOpen - RefBot));
           }
         else
           {
            for(int k = 1; k <= MaxLookaheadBars; k++)
              {
               int idx = r - k;
               if(idx < 0) break;

               double kOpen  = iOpen(_Symbol,_Period, idx);
               double kClose = iClose(_Symbol,_Period, idx);
               double kHigh  = iHigh(_Symbol,_Period, idx);
               double kLow   = iLow(_Symbol,_Period, idx);

               // gap detection
               if(kOpen > RefTop || kOpen < RefBot)
                 {
                  SeqType = "Gap";
                  GapSize = MathMin(MathAbs(kOpen - RefTop), MathAbs(kOpen - RefBot));
                  LookaheadUsed = k;
                  break;
                 }

               // inside bar detection
               if(kHigh <= RefTop && kLow >= RefBot)
                 {
                  InsideCount++;
                  SeqType = "Inside";
                  LookaheadUsed = k;
                  if(RefDir == "Bull")
                     Ext = MathMin(Ext, kLow);
                  else if(RefDir == "Bear")
                     Ext = MathMax(Ext, kHigh);

                  if(InsideCount >= MaxInsideBars) break;
                  continue;
                 }

               // engulfing detection
               if(kHigh >= RefTop && kLow <= RefBot)
                 {
                  string kDir = (kClose > kOpen) ? "Bull" : (kClose < kOpen ? "Bear" : "Neutral");
                  SeqType = "Engulf";
                  LookaheadUsed = k;
                  if((RefDir == "Bull" && kDir == "Bear") || (RefDir == "Bear" && kDir == "Bull"))
                     HighMomentum = true;
                  if(RefDir == "Bull") Ext = MathMin(Ext, kLow);
                  else Ext = MathMax(Ext, kHigh);
                  break;
                 }

               // otherwise treat as single normal test and stop
               LookaheadUsed = k;
               if(RefDir == "Bull")
                  Ext = MathMin(Ext, kLow);
               else if(RefDir == "Bear")
                  Ext = MathMax(Ext, kHigh);
               break;
              } // end lookahead loop
           } // end non-gap else
        } // end UseExtendedWindow
      else
        {
         SeqType = "Single";
         LookaheadUsed = 1;
         InsideCount = 0;
         if(RefDir == "Bull") Ext = testLow;
         else if(RefDir == "Bear") Ext = testHigh;
         else Ext = iClose(_Symbol,_Period,testIndex);
        }

      // Compute R and Type (Rpct is percentage 0..100)
      if(RefDir == "Bull")
         Rpct = (RefTop - Ext) / Range * 100.0;
      else if(RefDir == "Bear")
         Rpct = (Ext - RefBot) / Range * 100.0;
      else
         Rpct = 0.0;

      if(Rpct < 0.0) { Type = "NoRetrace"; Rpct = 0.0; }
      else if(Rpct <= 100.0) Type = "Retracement";
      else Type = "Extension";

      // Determine if the bar (or collapsed sequence) supports same direction:
      // For Bull ref -> supporting test must be bullish (close >= open)
      // For Bear ref -> supporting test must be bearish (close <= open)
      bool SameDirSupport = false;
      // Decide representative bar for direction test:
      // We use the last lookahead bar used (testIndex + 0..LookaheadUsed-1)
      int repIndex = testIndex - (LookaheadUsed - 1); // the bar we last considered
      if(repIndex < 0) repIndex = testIndex;
      double repOpen = iOpen(_Symbol,_Period, repIndex);
      double repClose = iClose(_Symbol,_Period, repIndex);
      if(RefDir == "Bull" && repClose >= repOpen) SameDirSupport = true;
      else if(RefDir == "Bear" && repClose <= repOpen) SameDirSupport = true;

      // Compute retrace in pips/points: for Bull -> (RefTop - Ext) / _Point, Bear -> (Ext - RefBot) / _Point
      double RetracePips = 0.0;
      if(RefDir == "Bull") RetracePips = (RefTop - Ext) / _Point;
      else if(RefDir == "Bear") RetracePips = (Ext - RefBot) / _Point;

      // Find nearest classic Fibonacci percentage and distance
      double NearestFib = ClassicFibs[0];
      double NearestDist = MathAbs(Rpct - NearestFib);
      for(int fi=1; fi < ArraySize(ClassicFibs); fi++)
        {
         double d = MathAbs(Rpct - ClassicFibs[fi]);
         if(d < NearestDist)
           {
            NearestDist = d;
            NearestFib = ClassicFibs[fi];
           }
        }

      // Final validity accounting
      if(!ValidSetup) invalid_count++;

      // Optionally skip writing rows that do not support same direction
      if(OutputOnlySameDir && !SameDirSupport)
        {
         // optionally write invalid row for diagnostics if IncludeInvalidRows true
         if(IncludeInvalidRows)
           {
            // write row but mark SameDirSupport false
           }
         else
           {
            continue;
           }
        }

      // metadata
      datetime obsTime = (datetime)iTime(_Symbol,_Period, testIndex);
      MqlDateTime sdt;
      TimeToStruct(obsTime, sdt);
      string isoTime = StringFormat("%04d-%02d-%02dT%02d:%02d:%02d", sdt.year, sdt.mon, sdt.day, sdt.hour, sdt.min, sdt.sec);

      long vol = (long)iVolume(_Symbol,_Period, testIndex);
      double spread_pips = 0.0;
      if(IncludeSpread)
        {
         MqlTick tick;
         if(SymbolInfoTick(_Symbol, tick))
           {
            double spread_price = tick.ask - tick.bid;
            spread_pips = spread_price / _Point; // convert to pips/points
           }
         else
           spread_pips = 0.0;
        }

      string tfname = PeriodToString(_Period);
      // Write CSV row
      FileWrite(fh,
                _Symbol, tfname, isoTime,
                fmt(RefTop,_Digits), fmt(RefBot,_Digits), fmt(Range,_Digits), RefDir,
                fmt(Ext,_Digits), fmt(RetracePips,1), DoubleToString(Rpct,4), Type,
                SeqType, InsideCount, LookaheadUsed, fmt(GapSize,_Digits), (HighMomentum ? "1":"0"),
                (SameDirSupport ? "true":"false"), DoubleToString(NearestFib,2), DoubleToString(NearestDist,4),
                (ValidSetup ? "true":"false"), InvalidReason,
                vol, fmt(spread_pips,2));

      written++;
     } // end for r

   IndicatorRelease(atr_handle);
   FileClose(fh);
   PrintFormat("CandleRangeData_v2: finished. Wrote %d rows to %s. Invalid rows skipped=%d", written, OutFileName, invalid_count);
  }
//+------------------------------------------------------------------+
