//+------------------------------------------------------------------+
//|                                                     KeyCodes.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | ASCII character and control key codes |
// | to handle the keypress event (long event parameter) |
//+------------------------------------------------------------------+
#define KEY_BACKSPACE          8
#define KEY_TAB                9
#define KEY_NUMPAD_5           12
#define KEY_ENTER              13
#define KEY_SHIFT              16
#define KEY_CTRL               17
#define KEY_BREAK              19
#define KEY_CAPS_LOCK          20
#define KEY_ESC                27
#define KEY_SPACE              32
#define KEY_PAGE_UP            33
#define KEY_PAGE_DOWN          34
#define KEY_END                35
#define KEY_HOME               36
#define KEY_LEFT               37
#define KEY_UP                 38
#define KEY_RIGHT              39
#define KEY_DOWN               40
#define KEY_INSERT             45
#define KEY_DELETE             46
//---
#define KEY_0                  48
#define KEY_1                  49
#define KEY_2                  50
#define KEY_3                  51
#define KEY_4                  52
#define KEY_5                  53
#define KEY_6                  54
#define KEY_7                  55
#define KEY_8                  56
#define KEY_9                  57
//---
#define KEY_A                  65
#define KEY_B                  66
#define KEY_C                  67
#define KEY_D                  68
#define KEY_E                  69
#define KEY_F                  70
#define KEY_G                  71
#define KEY_H                  72
#define KEY_I                  73
#define KEY_J                  74
#define KEY_K                  75
#define KEY_L                  76
#define KEY_M                  77
#define KEY_N                  78
#define KEY_O                  79
#define KEY_P                  80
#define KEY_Q                  81
#define KEY_R                  82
#define KEY_S                  83
#define KEY_T                  84
#define KEY_U                  85
#define KEY_V                  86
#define KEY_W                  87
#define KEY_X                  88
#define KEY_Y                  89
#define KEY_Z                  90
//---
#define KEY_WIN                91
#define KEY_NUMLOCK_0          96
#define KEY_NUMLOCK_1          97
#define KEY_NUMLOCK_2          98
#define KEY_NUMLOCK_3          99
#define KEY_NUMLOCK_4          100 
#define KEY_NUMLOCK_5          101
#define KEY_NUMLOCK_6          102
#define KEY_NUMLOCK_7          103
#define KEY_NUMLOCK_8          104
#define KEY_NUMLOCK_9          105
#define KEY_NUMLOCK_STAR       106
#define KEY_NUMLOCK_PLUS       107
#define KEY_NUMLOCK_MINUS      109
#define KEY_NUMLOCK_DOT        110
#define KEY_NUMLOCK_SLASH      111
#define KEY_F5                 116
#define KEY_NUM_LOCK           144
#define KEY_SCROLL_LOCK        145
//---
#define KEY_SEMICOLON          186
#define KEY_EQUALS             187
#define KEY_COMMA              188
#define KEY_MINUS              189
#define KEY_DOT                190
#define KEY_SLASH              191
#define KEY_TILDE              192
#define KEY_L_PARENTHESIS      219
#define KEY_BACKSLASH          220
#define KEY_R_PARENTHESIS      221
#define KEY_SINGLE_QUOTE       222

// --- Bit
#define KEYSTATE_ON            16384
//+------------------------------------------------------------------+
// | Key scan codes (event string parameter) |
//+------------------------------------------------------------------+
// | Pressed once: KEYSTATE_XXX |
// | Clamped: KEYSTATE_XXX + KEYSTATE_ON |
//+------------------------------------------------------------------+
#define KEYSTATE_ESC           1
#define KEYSTATE_1             2
#define KEYSTATE_2             3
#define KEYSTATE_3             4
#define KEYSTATE_4             5
#define KEYSTATE_5             6
#define KEYSTATE_6             7
#define KEYSTATE_7             8
#define KEYSTATE_8             9
#define KEYSTATE_9             10
#define KEYSTATE_0             11
//---
#define KEYSTATE_MINUS         12
#define KEYSTATE_EQUALS        13
#define KEYSTATE_BACKSPACE     14
#define KEYSTATE_TAB           15
//---
#define KEYSTATE_Q             16
#define KEYSTATE_W             17
#define KEYSTATE_E             18
#define KEYSTATE_R             19
#define KEYSTATE_T             20
#define KEYSTATE_Y             21
#define KEYSTATE_U             22
#define KEYSTATE_I             23
#define KEYSTATE_O             24
#define KEYSTATE_P             25
//---
#define KEYSTATE_L_PARENTHESIS 26
#define KEYSTATE_R_PARENTHESIS 27
#define KEYSTATE_ENTER         28
#define KEYSTATE_L_CTRL        29
//---
#define KEYSTATE_A             30
#define KEYSTATE_S             31
#define KEYSTATE_D             32
#define KEYSTATE_F             33
#define KEYSTATE_G             34
#define KEYSTATE_H             35
#define KEYSTATE_J             36
#define KEYSTATE_K             37
#define KEYSTATE_L             38
//---
#define KEYSTATE_SEMICOLON     39
#define KEYSTATE_SINGLE_QUOTE  40
#define KEYSTATE_L_SHIFT       42
#define KEYSTATE_BACKSLASH     43
//---
#define KEYSTATE_Z             44
#define KEYSTATE_X             45
#define KEYSTATE_C             46
#define KEYSTATE_V             47
#define KEYSTATE_B             48
#define KEYSTATE_N             49
#define KEYSTATE_M             50
//---
#define KEYSTATE_COMMA         51
#define KEYSTATE_DOT           52
#define KEYSTATE_SLASH         53
#define KEYSTATE_R_SHIFT       54
#define KEYSTATE_NUMPAD_STAR   55
#define KEYSTATE_SPACE         57
#define KEYSTATE_BREAK         69
#define KEYSTATE_SCROLL_LOCK   70
#define KEYSTATE_NUMPAD_7      71
#define KEYSTATE_NUMPAD_8      72
#define KEYSTATE_NUMPAD_9      73
#define KEYSTATE_NUMPAD_MINUS  74
#define KEYSTATE_NUMPAD_4      75
#define KEYSTATE_NUMPAD_5      76
#define KEYSTATE_NUMPAD_6      77
#define KEYSTATE_NUMPAD_PLUS   78
#define KEYSTATE_NUMPAD_1      79
#define KEYSTATE_NUMPAD_2      80
#define KEYSTATE_NUMPAD_3      81
#define KEYSTATE_NUMPAD_0      82
#define KEYSTATE_NUMPAD_DELETE 83
//---
#define KEYSTATE_NUMPAD_ENTER  284
#define KEYSTATE_R_CTRL        285
#define KEYSTATE_NUMPAD_SLASH  309
#define KEYSTATE_NUM_LOCK      325
#define KEYSTATE_HOME          327
#define KEYSTATE_UP            328
#define KEYSTATE_PAGE_UP       329
#define KEYSTATE_LEFT          331
#define KEYSTATE_RIGHT         333
#define KEYSTATE_END           335
#define KEYSTATE_DOWN          336
#define KEYSTATE_PAGE_DOWN     337
#define KEYSTATE_INSERT        338
#define KEYSTATE_DELETE        339
//+------------------------------------------------------------------+
