//+------------------------------------------------------------------+
//|                                        RiskManagementDefines.mqh |
//| The enums of RiskManagement in one place (Trading\RiskManagement)|
//| Combined from RiskTypes.mqh of Part 7 (Solomon Anietie Sunday\   |
//| Risk Management\7. 24477 ...\Include): ENUM_RISK_MODE,           |
//| ENUM_RISK_BASE, ENUM_ENTRY_MODE, ENUM_OFFSET_MODE. Its configs   |
//| (SRiskConfig, SBasketConfig) become Setting objects              |
//| (Entities\Settings\Risk), not structs here                       |
//+------------------------------------------------------------------+
#ifndef __RISKMANAGEMENT_DEFINES_MQH__
#define __RISKMANAGEMENT_DEFINES_MQH__
//+------------------------------------------------------------------+
//| Anhnt's own, not from DoEasy: the take profit levels of a trade   |
//| are put at these multiples of the stop distance (risk : reward)   |
//| Reference https://www.mql5.com/en/articles/20512                 |
//+------------------------------------------------------------------+
enum ENUM_RISK_REWARD_RATIO
  {
   ONE_TO_ONE,                                              // 1 : 1
   ONE_TO_ONEandHALF,                                       // 1 : 1.5
   ONE_TO_TWO,                                              // 1 : 2
   ONE_TO_THREE,                                            // 1 : 3
   ONE_TO_FOUR,                                             // 1 : 4
   ONE_TO_FIVE,                                             // 1 : 5
   ONE_TO_SIX                                               // 1 : 6
  };
#define RISK_REWARD_RATIOS_TOTAL  (7)                       // the number of ENUM_RISK_REWARD_RATIO values
//--- The reward of the ratio for a risk of 1: ONE_TO_ONEandHALF is 1.5
double RiskRewardRatioValue(const ENUM_RISK_REWARD_RATIO ratio)
  {
   switch(ratio)
     {
      case ONE_TO_ONE:        return 1.0;
      case ONE_TO_ONEandHALF: return 1.5;
      case ONE_TO_TWO:        return 2.0;
      case ONE_TO_THREE:      return 3.0;
      case ONE_TO_FOUR:       return 4.0;
      case ONE_TO_FIVE:       return 5.0;
      case ONE_TO_SIX:        return 6.0;
     }
   return 1.0;
  }
#endif // __RISKMANAGEMENT_DEFINES_MQH__
