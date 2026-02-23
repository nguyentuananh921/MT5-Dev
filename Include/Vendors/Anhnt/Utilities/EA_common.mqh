// Utilities/EA_common.mqh
#ifndef _EA_COMMON_MQH_
#define _EA_COMMON_MQH_
#include <Anhnt/Configuration/NamingConfiguration.mqh>

void RemoveSMTChartIndicators()
{
   int total = ChartIndicatorsTotal(0, 0);

   // Loop backward for safety
   for(int i = total - 1; i >= 0; i--)
   {
      string indi_name = ChartIndicatorName(0, 0, i);
      // Only remove indicators created by this EA
      if(StringFind(indi_name, SMT_PREFIX) == 0)
      {
         ChartIndicatorDelete(0, 0, indi_name);
      }
   }
}
#endif // _TIMEFRAME_MQH_
