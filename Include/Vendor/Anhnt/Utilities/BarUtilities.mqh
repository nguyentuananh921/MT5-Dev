//This is Include\Anhnt\Utilities\BarUtilities.mqh
#ifndef __BARUTILLITIES_MQH__
#define __BARUTILLITIES_MQH__
#include "..\Configuration\EnumConfiguration.mqh"
bool IsNewBar(ENUM_TIMEFRAMES _tf, int _index)   // index tương ứng với g_supported_timeframes[]
{
    datetime currentBarTime = iTime(_Symbol, _tf, 0);

    if(currentBarTime != g_lastBarTime[_index])
    {
        g_lastBarTime[_index] = currentBarTime;
        return true;
    }
    return false;
}
#endif // __BARUTILLITIES_MQH__
