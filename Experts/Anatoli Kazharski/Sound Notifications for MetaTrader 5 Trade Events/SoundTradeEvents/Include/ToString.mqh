//+------------------------------------------------------------------+
//| RETURNING THE TIMEFRAME STRING                                   |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES timeframe)
  {
   string str="";
//--- If the passed value is incorrect, take the time frame of the current chart
   if(timeframe==WRONG_VALUE|| timeframe== NULL)
      timeframe= Period();
   switch(timeframe)
     {
      case PERIOD_M1  : str="M1";  break;
      case PERIOD_M2  : str="M2";  break;
      case PERIOD_M3  : str="M3";  break;
      case PERIOD_M4  : str="M4";  break;
      case PERIOD_M5  : str="M5";  break;
      case PERIOD_M6  : str="M6";  break;
      case PERIOD_M10 : str="M10"; break;
      case PERIOD_M12 : str="M12"; break;
      case PERIOD_M15 : str="M15"; break;
      case PERIOD_M20 : str="M20"; break;
      case PERIOD_M30 : str="M30"; break;
      case PERIOD_H1  : str="H1";  break;
      case PERIOD_H2  : str="H2";  break;
      case PERIOD_H3  : str="H3";  break;
      case PERIOD_H4  : str="H4";  break;
      case PERIOD_H6  : str="H6";  break;
      case PERIOD_H8  : str="H8";  break;
      case PERIOD_H12 : str="H12"; break;
      case PERIOD_D1  : str="D1";  break;
      case PERIOD_W1  : str="W1";  break;
      case PERIOD_MN1 : str="MN1"; break;
     }
//---
   return(str);
  }
//+------------------------------------------------------------------+
//| CONVERTING FROM DATETIME TO STRING                               |
//| IN THE TIME_DATE|TIME_MINUTES FORMAT                             |
//+------------------------------------------------------------------+
string TSdm(datetime value)
  {
   return(TimeToString(value,TIME_DATE|TIME_MINUTES));
  }
//+------------------------------------------------------------------+
//| CONVERTING FROM DATETIME TO STRING                               |
//| IN THE TIME_DATE|TIME_MINUTES|TIME_SECONDS FORMAT                |
//+------------------------------------------------------------------+
string TSdms(datetime value)
  {
   return(TimeToString(value,TIME_DATE|TIME_MINUTES|TIME_SECONDS));
  }
//+------------------------------------------------------------------+
