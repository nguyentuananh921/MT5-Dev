//+------------------------------------------------------------------+
//|                                                EventDefines.mqh |
//| Event code chain: every group starts at the NEXT_CODE of the     |
//| previous one so codes sent through EventChartCustom never clash  |
//+------------------------------------------------------------------+
#ifndef __EVENT_DEFINES_MQH__
#define __EVENT_DEFINES_MQH__
 #define EVENTS_START_CODE   (0)   // First code of the event chain
 enum ENUM_SYMBOLTF_MANAGER_EVENT
  {
   SYMBOLTF_MANAGER_EVENT_NO_EVENT = EVENTS_START_CODE,
   SYMBOLTF_MANAGER_EVENT_ADDED,
   SYMBOLTF_MANAGER_EVENT_DELETE,
   SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED,
   SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED,
  };
 #define SYMBOLTF_MANAGER_EVENTS_NEXT_CODE  (SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED+1)
#endif // __EVENT_DEFINES_MQH__
