// Utilities/PriceUtilities.mqh
#ifndef __PRICEUTILITIES_MQH__
#define __PRICEUTILITIES_MQH__

double GetAppliedPrice(ENUM_APPLIED_PRICE price_type,
                       int index,
                       const double &open[],
                       const double &high[],
                       const double &low[],
                       const double &close[])
{

   if(index < 0 || index >= ArraySize(close))
   return EMPTY_VALUE;
   
   switch(price_type)
   {
      case PRICE_OPEN:     return open[index];
      case PRICE_HIGH:     return high[index];
      case PRICE_LOW:      return low[index];
      case PRICE_MEDIAN:   return (high[index] + low[index]) / 2.0;
      case PRICE_TYPICAL:  return (high[index] + low[index] + close[index]) / 3.0;
      case PRICE_WEIGHTED: return (high[index] + low[index] + close[index] + close[index]) / 4.0;
      case PRICE_CLOSE:
      default:             return close[index];
   }
}

string AppliedPriceToString(ENUM_APPLIED_PRICE price)
{
   switch(price)
   {
      case PRICE_OPEN:     return "PRICE_OPEN";
      case PRICE_HIGH:     return "PRICE_HIGH";
      case PRICE_LOW:      return "PRICE_LOW";
      case PRICE_CLOSE:    return "PRICE_CLOSE";
      case PRICE_MEDIAN:   return "PRICE_MEDIAN";
      case PRICE_TYPICAL:  return "PRICE_TYPICAL";
      case PRICE_WEIGHTED: return "PRICE_WEIGHTED";
      default:             return "UNKNOWN_PRICE";
   }
}
#endif // __PRICEUTILITIES_MQH__
