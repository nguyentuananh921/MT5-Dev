//+------------------------------------------------------------------+
//|                                                         Keys.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//| Introduction at https://www.mql5.com/en/articles/3004            |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#ifndef __KEYS_MQH__
#define __KEYS_MQH__
  #include "KeyCodes.mqh"
  //+------------------------------------------------------------------+
  //| Keyboard class |
  //+------------------------------------------------------------------+
  class CKeys
   {
    public:
                     CKeys(void);
                    ~CKeys(void);
     // --- Returns the character of the pressed key
      string            KeySymbol(const long key_code);
     // --- Returns the state of the Ctrl key
      bool              KeyCtrlState(void);
     // --- Returns the state of the Shift key
      bool              KeyShiftState(void);
   };
 #ifndef CKEYS_MQH_IMPLEMENTATION
 #define CKEYS_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CKeys::CKeys(void)
     {
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CKeys::~CKeys(void)
     {
     }
   //+------------------------------------------------------------------+
   // | Returns the character of the pressed key |
   //+------------------------------------------------------------------+
   string CKeys::KeySymbol(const long key_code)
     {
       string key_symbol="";
      // --- If you need to enter a space ("Space" key)
       if(key_code==KEY_SPACE)
         {
           key_symbol=" ";
         }
      // --- When you need to enter (1) an alphabetic character or (2) a numeric key character or (3) a special character
       else if((key_code>=KEY_A && key_code<=KEY_Z) ||
               (key_code>=KEY_0 && key_code<=KEY_9) ||
               (key_code>=KEY_NUMLOCK_0 && key_code<=KEY_NUMLOCK_SLASH) ||
               (key_code>=KEY_SEMICOLON && key_code<=KEY_SINGLE_QUOTE))
         {
         key_symbol=::ShortToString(::TranslateKey((int)key_code));
        }
      // --- Return character
       return(key_symbol);
     }
   //+------------------------------------------------------------------+
   // | Returns the state of the Ctrl key |
   //+------------------------------------------------------------------+
   bool CKeys::KeyCtrlState(void)
     {
      return(::TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL)<0);
     }
   //+------------------------------------------------------------------+
   // | Returns the state of the Shift key |
   //+------------------------------------------------------------------+
   bool CKeys::KeyShiftState(void)
     {
      return(::TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT)<0);
     }
   //+------------------------------------------------------------------+
 #endif // CKEYS_MQH_IMPLEMENTATION
#endif // __KEYS_MQH__
