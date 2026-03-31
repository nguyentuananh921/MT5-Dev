//+------------------------------------------------------------------+
//| SD_BaseExit_Research.mq5                                        |
//| Research Script: Quantifies the Base/Exit Candle Relationship   |
//| Core Logic: Finds a small candle followed by a larger one       |
//|             in the same direction.                              |
//+------------------------------------------------------------------+
#property script_show_inputs
#property copyright "Clemence Benjamin"
#property version   "3.1"

//--- Inputs: Define what "small" and "bigger" mean
input int    BarsToProcess    = 20000;     // Total bars to scan
input int    ATR_Period       = 14;        // For volatility context
input double MaxBaseBodyATR   = 0.5;       // Base candle max size (e.g., 0.5 * ATR)
input double MinExitBodyRatio = 2.0;       // Exit must be at least this many times bigger than base
input bool   CollectAllData   = true;      // TRUE=log all pairs, FALSE=use above filters now
input string OutFilePrefix    = "SD_BaseExit";

//--- Global variables
int atrHandle;
double atrBuffer[];

//+------------------------------------------------------------------+
string PeriodToString(int tf) {
   switch(tf) {
      case PERIOD_M15: return "M15";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";
      default:         return IntegerToString(tf);
   }
}
//+------------------------------------------------------------------+
void OnStart() {
   // 1. INITIALIZATION: Get ATR data and open the data log (CSV file)
   atrHandle = iATR(_Symbol, _Period, ATR_Period);
   if(atrHandle == INVALID_HANDLE) {
      Print("Error: Could not get ATR data.");
      return;
   }
   
   string tf = PeriodToString(_Period);
   string fileName = StringFormat("%s_%s_%s.csv", OutFilePrefix, _Symbol, tf);
   int fileHandle = FileOpen(fileName, FILE_WRITE|FILE_CSV|FILE_ANSI);
   
   if(fileHandle == INVALID_HANDLE) {
      Print("Failed to create file: ", fileName);
      return;
   }
   
   // Write the header. Each row will be one observed "base-exit" candle pair.
   FileWrite(fileHandle,
      "Pattern", "Symbol", "Timeframe", "Timestamp",
      "Base_BodyPips", "Exit_BodyPips", "ExitToBaseRatio",
      "ATR_Pips", "Base_BodyATR", "Exit_BodyATR",
      "Base_Open", "Base_Close", "Exit_Open", "Exit_Close"
   );
   
   int totalBars = iBars(_Symbol, _Period);
   int barsToCheck = MathMin(BarsToProcess, totalBars);
   int dataRowsWritten = 0;
   
   // Copy ATR values for the whole period we're checking
   if(CopyBuffer(atrHandle, 0, 0, barsToCheck, atrBuffer) < 0) {
      Print("Failed to copy ATR data.");
      FileClose(fileHandle);
      return;
   }
   
   // 2. MAIN SCANNING LOOP: Look at every consecutive pair of candles
   for(int i = 1; i < barsToCheck; i++) { // Start at 1 so we can look at candle i (exit) and i+1 (base)
      int baseIdx = i;      // The older candle (potential base)
      int exitIdx = i - 1;  // The newer candle (potential exit)
      
      // Get data for the BASE candle (candle i)
      double baseOpen   = iOpen(_Symbol, _Period, baseIdx);
      double baseClose  = iClose(_Symbol, _Period, baseIdx);
      double baseBody   = MathAbs(baseClose - baseOpen);
      double baseBodyPips = baseBody / _Point;
      double atrBase    = atrBuffer[baseIdx];
      double baseBodyATR = (atrBase > 0) ? baseBodyPips / (atrBase / _Point) : 0;
      
      // Get data for the EXIT candle (candle i-1)
      double exitOpen   = iOpen(_Symbol, _Period, exitIdx);
      double exitClose  = iClose(_Symbol, _Period, exitIdx);
      double exitBody   = MathAbs(exitClose - exitOpen);
      double exitBodyPips = exitBody / _Point;
      double atrExit    = atrBuffer[exitIdx];
      double exitBodyATR = (atrExit > 0) ? exitBodyPips / (atrExit / _Point) : 0;
      
      // Calculate the core metric: How much bigger is the exit?
      double exitToBaseRatio = (baseBodyPips > 0) ? exitBodyPips / baseBodyPips : 0;
      
      // 3. PATTERN IDENTIFICATION: Determine direction and type
      string patternType = "None";
      
      // Check if both candles are BULLISH (Demand Setup)
      bool isBullishBase = baseClose > baseOpen;
      bool isBullishExit = exitClose > exitOpen;
      
      // Check if both candles are BEARISH (Supply Setup)
      bool isBearishBase = baseClose < baseOpen;
      bool isBearishExit = exitClose < exitOpen;
      
      // The core logic: A valid pattern requires consecutive candles in the SAME direction.
      if(isBullishBase && isBullishExit) {
         patternType = "Demand";
      } else if(isBearishBase && isBearishExit) {
         patternType = "Supply";
      }
      
      // If candles are in mixed directions, it's not our pattern. Skip.
      if(patternType == "None") continue;
      
      // 4. DATA FILTERING (Optional): Apply size rules if not collecting everything
      if(!CollectAllData) {
         // Rule: Base candle must be relatively small compared to market noise
         bool isBaseSmallEnough = baseBodyATR < MaxBaseBodyATR;
         // Rule: Exit candle must be significantly larger than the base
         bool isExitLargeEnough = exitToBaseRatio >= MinExitBodyRatio;
         
         if(!isBaseSmallEnough || !isExitLargeEnough) {
            continue; // Skip this pair, it doesn't meet our current test filters
         }
      }
      // If CollectAllData is TRUE, we log EVERY same-direction pair, regardless of size.
      // This is best for initial research.
      
      // 5. DATA LOGGING: Write all details of this pair to our CSV file
      datetime exitTime = iTime(_Symbol, _Period, exitIdx);
      MqlDateTime dtStruct; TimeToStruct(exitTime, dtStruct);
      string timeStamp = StringFormat("%04d-%02d-%02dT%02d:%02d:%02d",
                                      dtStruct.year, dtStruct.mon, dtStruct.day,
                                      dtStruct.hour, dtStruct.min, dtStruct.sec);
      
      FileWrite(fileHandle,
         patternType, _Symbol, tf, timeStamp,
         DoubleToString(baseBodyPips, 2),
         DoubleToString(exitBodyPips, 2),
         DoubleToString(exitToBaseRatio, 2),
         DoubleToString(atrExit / _Point, 2),
         DoubleToString(baseBodyATR, 3),
         DoubleToString(exitBodyATR, 3),
         DoubleToString(baseOpen, _Digits),
         DoubleToString(baseClose, _Digits),
         DoubleToString(exitOpen, _Digits),
         DoubleToString(exitClose, _Digits)
      );
      
      dataRowsWritten++;
   }
   
   // 6. CLEANUP: Close the file and release the indicator handle
   FileClose(fileHandle);
   IndicatorRelease(atrHandle);
   
   Print("Research data collection finished.");
   Print("File created: ", fileName);
   Print("Total 'Base-Exit' pairs logged: ", dataRowsWritten);
}
//+------------------------------------------------------------------+