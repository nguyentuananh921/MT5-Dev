//+------------------------------------------------------------------+
//|                                               CommonDefines.mqh  |
//|  Extracted from Artyom Trishkin's DoEasy Defines.mqh             |
//|Lib https://www.mql5.com/en/articles/14710                        |
//+------------------------------------------------------------------+
#ifndef __COMMON_DEFINES_MQH__
#define __COMMON_DEFINES_MQH__
//+------------------------------------------------------------------+
  //| Macro substitutions                                              |
  //+------------------------------------------------------------------+
  //--- Describe the function with the error line number
   #define DFUN_ERR_LINE                  (__FUNCTION__+(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian" ? ", Page " : ", Line ")+(string)__LINE__+": ")
   #define DFUN                           (__FUNCTION__+": ")        // "Function description"
   
//+------------------------------------------------------------------+
 //|  Logging level                                                   |
 //+------------------------------------------------------------------+
 enum ENUM_LOG_LEVEL
  {
   LOG_LEVEL_NO_MSG,                                        // Logging disabled
   LOG_LEVEL_ERROR_MSG,                                     // Errors only
   LOG_LEVEL_ALL_MSG                                        // Full logging
  };

 //+------------------------------------------------------------------+
 //| Signal direction                                                 |
 //+------------------------------------------------------------------+
 enum ENUM_SIGNAL_DIR
  {
   SIGNAL_NONE =  0,                                        // No signal
   SIGNAL_BUY  =  1,                                        // Buy
   SIGNAL_SELL = -1                                         // Sell
  };

  //+------------------------------------------------------------------+
 //| List of library object types                                     |
 //+------------------------------------------------------------------+
 enum ENUM_OBJECT_DE_TYPE
  {
   //--- Base objects
    OBJECT_DE_TYPE_BASE,                                           // Base object for all library objects
    OBJECT_DE_TYPE_BASE_EXT,                                       // Extended base object for all library objects
    // Pure Data
      OBJECT_DE_TYPE_SYMBOLTF_SETTING,                                // "Symbol+TF config row (CSymbolTFSetting)" object type
    // Time Serries
      OBJECT_DE_TYPE_SERIES_SWING,                                   // "Swing point" object type
      OBJECT_DE_TYPE_SERIES_MARKET_STRUCTURE,                        // "Market structure event" object type
   //--- Graphics
    OBJECT_DE_TYPE_GBASE,                                          // Base object of all library graphical objects
   //--- Standard graphical objects (keep last: values are OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_xxx)
    OBJECT_DE_TYPE_GSTD_OBJ,                                       // Standard graphical object
  };
 //+------------------------------------------------------------------+
 //| Possible event reasons of the object library base object         |
 //+------------------------------------------------------------------+
 enum ENUM_BASE_EVENT_REASON
  {
   BASE_EVENT_REASON_INC,                                   // Increase in the object property value
   BASE_EVENT_REASON_DEC,                                   // Decrease in the object property value
   BASE_EVENT_REASON_MORE_THEN,                             // Object property value exceeds the control value
   BASE_EVENT_REASON_LESS_THEN,                             // Object property value is less than the control value
   BASE_EVENT_REASON_EQUALS                                 // Object property value is equal to the control value
  };
#endif // __COMMON_DEFINES_MQH__

