//+------------------------------------------------------------------+
//|                                               CommonDefines.mqh
//|  Extracted from Artyom Trishkin's DoEasy Defines.mqh            |
//+------------------------------------------------------------------+
#ifndef __COMMON_DEFINES_MQH__
#define __COMMON_DEFINES_MQH__

  //+------------------------------------------------------------------+
  //| Include files                                                    |
  //+------------------------------------------------------------------+
  // #include "DataSND.mqh"
  // #include "DataIMG.mqh"
  // #include "Data.mqh" //Change name to MesageData and move to Notify
 #include "..\Notify\Message\MessageData.mqh"
  // #ifdef __MQL4__
  //   #include "ToMQL4.mqh"
  // #endif 
  //+------------------------------------------------------------------+
  //| Resources                                                        |
  //+------------------------------------------------------------------+
  //#define PATH_TO_EVENT_CTRL_IND         "Indicators\\Vendors\\Artyom Trishkin\\DoEasy\\EventControl.ex5"
  //\\Vendors\\Artyom Trishkin\\DoEasy
  //+------------------------------------------------------------------+

  //| Macro substitutions                                              |
  //+------------------------------------------------------------------+
  //--- Describe the function with the error line number
   #define DFUN_ERR_LINE                  (__FUNCTION__+(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian" ? ", Page " : ", Line ")+(string)__LINE__+": ")
   #define DFUN                           (__FUNCTION__+": ")        // "Function description"
   #define END_TIME                       (D'31.12.3000 23:59:59')   // End date for account history data requests
   #define TIMER_FREQUENCY                (16)                       // Minimal frequency of the library timer in milliseconds
   #define TOTAL_TRADE_TRY                (5)                        // Default number of trading attempts
   #define IND_COLORS_TOTAL               (64)                       // Maximum possible number of indicator buffer colors
   #define IND_BUFFERS_MAX                (512)                      // Maximum possible number of indicator buffers
  //--- Data parameters for file operations
   #define DIRECTORY                      ("DoEasy\\")               // Library directory for storing object folders
   #define RESOURCE_DIR                   ("DoEasy\\Resource\\")     // Library directory for storing resource folders
   #define SCREENSHOT_DIR                 ("DoEasy\\ScreenShots\\")  // Library directory for storing screenshot folders
   #define TEMPLATE_DIR                   ("DoEasy\\")               // Library directory for storing template folders
   #define FILE_EXT_GIF                   (".gif")                   // GIF image file name extension
   #define FILE_EXT_PNG                   (".png")                   // PNG image file name extension
   #define FILE_EXT_BMP                   (".bmp")                   // BMP image file name extension
   #define SCREENSHOT_FILE_EXT            (FILE_EXT_PNG)             // Chart screenshot file format (extension: .gif, .png and .bmp can be used)
  //--- Symbol parameters
   #define CLR_MW_DEFAULT                 (0xFF000000)               // Default symbol background color in the Market Watch
   #ifdef __MQL5__
    #define SYMBOLS_COMMON_TOTAL        (TerminalInfoInteger(TERMINAL_BUILD)<2430 ? 1000 : 5000)   // Total number of MQL5 working symbols
   #else 
    #define SYMBOLS_COMMON_TOTAL        (1000)                     // Total number of MQL4 working symbols
   #endif 
  //--- Parameters of the orders and deals collection timer
   #define COLLECTION_ORD_PAUSE           (250)                      // Orders and deals collection timer pause in milliseconds
   #define COLLECTION_ORD_COUNTER_STEP    (16)                       // Increment of the orders and deals collection timer counter
   #define COLLECTION_ORD_COUNTER_ID      (1)                        // Orders and deals collection timer counter ID
  //--- Parameters of the account collection timer
   #define COLLECTION_ACC_PAUSE           (1000)                     // Account collection timer pause in milliseconds
   #define COLLECTION_ACC_COUNTER_STEP    (16)                       // Account timer counter increment
   #define COLLECTION_ACC_COUNTER_ID      (2)                        // Account timer counter ID
  //--- Symbol collection timer 1 parameters
  #define COLLECTION_SYM_PAUSE1          (100)                      // Pause of the symbol collection timer 1 in milliseconds (for scanning market watch symbols)
  #define COLLECTION_SYM_COUNTER_STEP1   (16)                       // Increment of the symbol timer 1 counter
  #define COLLECTION_SYM_COUNTER_ID1     (3)                        // Symbol timer 1 counter ID
 //--- Symbol collection timer 2 parameters
  #define COLLECTION_SYM_PAUSE2          (300)                      // Pause of the symbol collection timer 2 in milliseconds (for events of the market watch symbol list)
  #define COLLECTION_SYM_COUNTER_STEP2   (16)                       // Increment of the symbol timer 2 counter
  #define COLLECTION_SYM_COUNTER_ID2     (4)                        // Symbol timer 2 counter ID
 //--- Trading class timer parameters
  #define COLLECTION_REQ_PAUSE           (300)                      // Trading class timer pause in milliseconds
  #define COLLECTION_REQ_COUNTER_STEP    (16)                       // Trading class timer counter increment
  #define COLLECTION_REQ_COUNTER_ID      (5)                        // Trading class timer counter ID
 //--- Parameters of the timeseries collection timer
  #define COLLECTION_TS_PAUSE            (64)                       // Timeseries collection timer pause in milliseconds
  #define COLLECTION_TS_COUNTER_STEP     (16)                       // Account timer counter increment
  #define COLLECTION_TS_COUNTER_ID       (6)                        // Timeseries timer counter ID
 //--- Parameters of the timer of indicator data timeseries collection
  #define COLLECTION_IND_TS_PAUSE        (64)                       // Pause of the timer of indicator data timeseries collection in milliseconds
  #define COLLECTION_IND_TS_COUNTER_STEP (16)                       // Increment of indicator data timeseries timer counter
  #define COLLECTION_IND_TS_COUNTER_ID   (7)                        // ID of indicator data timeseries timer counter
 //--- Parameters of the tick series collection timer
  #define COLLECTION_TICKS_PAUSE         (64)                       // Tick series collection timer pause in milliseconds
  #define COLLECTION_TICKS_COUNTER_STEP  (16)                       // Tick series timer counter increment step
  #define COLLECTION_TICKS_COUNTER_ID    (8)                        // Tick series timer counter ID
 //--- Parameters of the chart collection timer
  #define COLLECTION_CHARTS_PAUSE        (500)                      // Chart collection timer pause in milliseconds
  #define COLLECTION_CHARTS_COUNTER_STEP (16)                       // Chart timer counter increment
  #define COLLECTION_CHARTS_COUNTER_ID   (9)                        // Chart timer counter ID
 //--- Parameters of the graphical objects collection timer
  #define COLLECTION_GRAPH_OBJ_PAUSE        (250)                   // Graphical objects collection timer pause in milliseconds
  #define COLLECTION_GRAPH_OBJ_COUNTER_STEP (16)                    // Graphical objects timer counter increment
  #define COLLECTION_GRAPH_OBJ_COUNTER_ID   (10)                    // Graphical objects timer counter ID
 //--- Parameters of the timer for the collection of graphical elements on canvas
  #define COLLECTION_GRAPH_ELM_PAUSE        (16)                    // Graphical elements collection timer pause in milliseconds
  #define COLLECTION_GRAPH_ELM_COUNTER_STEP (16)                    // Graphical elements timer counter increment
  #define COLLECTION_GRAPH_ELM_COUNTER_ID   (11)                    // Graphical elements timer counter ID
 //--- Collection list IDs
  #define COLLECTION_HISTORY_ID          (0x777A)                   // Historical collection list ID
  #define COLLECTION_MARKET_ID           (0x777B)                   // Market collection list ID
  #define COLLECTION_EVENTS_ID           (0x777C)                   // Event collection list ID
  #define COLLECTION_ACCOUNT_ID          (0x777D)                   // Account collection list ID
  #define COLLECTION_SYMBOLS_ID          (0x777E)                   // Symbol collection list ID
  #define COLLECTION_SERIES_ID           (0x777F)                   // Timeseries collection list ID
  #define COLLECTION_SERIES_PATTERNS_ID  (0x7780)                   // Timeseries pattern list ID
  #define COLLECTION_BUFFERS_ID          (0x7781)                   // Indicator buffer collection list ID
  #define COLLECTION_INDICATORS_ID       (0x7782)                   // Indicator collection list ID
  #define COLLECTION_INDICATORS_DATA_ID  (0x7783)                   // Indicator data collection list ID
  #define COLLECTION_TICKSERIES_ID       (0x7784)                   // Tick series collection list ID
  #define COLLECTION_MBOOKSERIES_ID      (0x7785)                   // DOM series collection list ID
  #define COLLECTION_MQL5_SIGNALS_ID     (0x7786)                   // MQL5 signals collection list ID
  #define COLLECTION_CHARTS_ID           (0x7787)                   // Chart collection list ID
  #define COLLECTION_CHART_WND_ID        (0x7788)                   // Chart window list ID
  #define COLLECTION_GRAPH_OBJ_ID        (0x7789)                   // Graphical object collection list ID
  #define COLLECTION_ID_LIST_END         (COLLECTION_GRAPH_OBJ_ID)  // End of collection ID list
 //--- Pending request type IDs
  #define PENDING_REQUEST_ID_TYPE_ERR    (1)                        // Type of a pending request created based on the server return code
  #define PENDING_REQUEST_ID_TYPE_REQ    (2)                        // Type of a pending request created by request
 //--- Timeseries parameters
  #define SERIES_DEFAULT_BARS_COUNT      (1000)                     // Required default amount of timeseries data
  #define PAUSE_FOR_SYNC_ATTEMPTS        (16)                       // Amount of pause milliseconds between synchronization attempts
  #define ATTEMPTS_FOR_SYNC              (5)                        // Number of attempts to receive synchronization with the server
 //--- Tick series parameters
  #define TICKSERIES_DEFAULT_DAYS_COUNT  (1)                        // Required number of days for tick data in default series
  #define TICKSERIES_MAX_DATA_TOTAL      (200000)                   // Maximum number of stored tick data of a single symbol
 //--- Parameters of the DOM snapshot series
  #define MBOOKSERIES_DEFAULT_DAYS_COUNT (1)                        // The default required number of days for DOM snapshots in the series
  #define MBOOKSERIES_MAX_DATA_TOTAL     (200000)                   // Maximum number of stored DOM snapshots of a single symbol
 //--- Graphical object parameters
  #define PROGRAM_OBJ_MAX_ID             (10000)                    // Maximum value of an ID of a graphical object belonging to a program
  #define CTRL_POINT_RADIUS              (5)                        // Radius of the control point on the form for managing graphical object pivot points
  #define CTRL_POINT_COLOR               (clrDodgerBlue)            // Radius of the control point on the form for managing graphical object pivot points
  #define CTRL_FORM_SIZE                 (40)                       // Size of the control point form for managing graphical object pivot points
 //--- Canvas parameters
  #define PAUSE_FOR_CANV_UPDATE                         (16)                 // Canvas update frequency
  #define CLR_CANV_NULL                                 (0x00FFFFFF)         // Zero for the canvas with the alpha channel
  #define CLR_DEF_FORE_COLOR                            (C'0x2D,0x43,0x48')  // Default color for texts of objects on canvas
  #define CLR_DEF_FORE_COLOR_MOUSE_DOWN                 (C'0x0E,0x11,0x98')  // Default color for texts of objects on canvas when clicking the mouse on the control
  #define CLR_DEF_FORE_COLOR_MOUSE_OVER                 (C'0x14,0x67,0xF1')  // Default color for texts of objects on canvas when hovering the mouse over the control
  #define CLR_DEF_FORE_COLOR_OPACITY                    (255)                // Default color opacity for canvas object texts
  #define CLR_DEF_BORDER_COLOR                          (C'0x2D,0x43,0x48')  // Default color for object frames on canvas
  #define CLR_DEF_BORDER_MOUSE_DOWN                     (C'0x61,0x88,0xC9')  // Default color for object frames on canvas when clicking the mouse on the control
  #define CLR_DEF_BORDER_MOUSE_OVER                     (C'0x93,0xAD,0xC8')  // Default color for object frames on canvas when hovering the mouse over the control
  #define CLR_DEF_BORDER_COLOR_OPACITY                  (255)                // Default color non-transparency for canvas object frames
  #define CLR_DEF_BORDER_COLOR_DARKNESS                 (-2.0)               // Default color opacity for canvas object frames (when using the background color)
  #define CLR_DEF_FRAME_GBOX_COLOR                      (C'0xDC,0xDC,0xDC')  // Default color for GroupBox object frames on canvas
  #define CLR_DEF_OPACITY                               (200)                // Default color opacity for canvas objects
  #define CLR_DEF_SHADOW_COLOR                          (C'0x6B,0x6B,0x6B')  // Default color for canvas object shadows
  #define CLR_DEF_SHADOW_OPACITY                        (127)                // Default color opacity for canvas objects
  #define DEF_SHADOW_BLUR                               (4)                  // Default blur for canvas object shadows
  #define CLR_DEF_CHECK_BACK_COLOR                      (C'0xFF,0xFF,0xFF')  // Color of control checkbox background
  #define CLR_DEF_CHECK_BACK_OPACITY                    (255)                // Opacity of the control checkbox background color
  #define CLR_DEF_CHECK_BACK_MOUSE_DOWN                 (C'0xC0,0xDC,0xF3')  // Color of control checkbox background when clicking on the control
  #define CLR_DEF_CHECK_BACK_MOUSE_OVER                 (C'0xD8,0xE6,0xF2')  // Color of control checkbox background when hovering the mouse over the control
  #define CLR_DEF_CHECK_BORDER_COLOR                    (C'0x2D,0x43,0x48')  // Color of control checkbox frame
  #define CLR_DEF_CHECK_BORDER_OPACITY                  (255)                // Opacity of the control checkbox frame color
  #define CLR_DEF_CHECK_BORDER_MOUSE_DOWN               (C'0x00,0x54,0x99')  // Color of control checkbox frame when clicking on the control
  #define CLR_DEF_CHECK_BORDER_MOUSE_OVER               (C'0x00,0x78,0xD7')  // Color of control checkbox frame when hovering the mouse over the control
  #define CLR_DEF_CHECK_FLAG_COLOR                      (C'0x04,0x7B,0x0D')  // Color of control checkbox
  #define CLR_DEF_CHECK_FLAG_OPACITY                    (255)                // Opacity of the control checkbox color
  #define CLR_DEF_CHECK_FLAG_MOUSE_DOWN                 (C'0x00,0x54,0x99')  // Color of control checkbox when clicking on the control
  #define CLR_DEF_CHECK_FLAG_MOUSE_OVER                 (C'0x00,0x78,0xD7')  // Color of control checkbox when hovering the mouse over the control
  #define CLR_DEF_CONTROL_STD_BACK_COLOR                (C'0xF0,0xF0,0xF0')  // Standard controls background color
  #define CLR_DEF_CONTROL_STD_MOUSE_DOWN                (C'0xC0,0xDC,0xF3')  // Color of standard control background when clicking on the control
  #define CLR_DEF_CONTROL_STD_MOUSE_OVER                (C'0xD8,0xE6,0xF2')  // Color of standard controls background when hovering the mouse over the control
  #define CLR_DEF_CONTROL_STD_OPACITY                   (255)                // Opacity of standard controls background color 
  #define CLR_DEF_CONTROL_STD_BACK_COLOR_ON             (C'0xC9,0xDE,0xD0')  // Background color of standard controls which are on
  #define CLR_DEF_CONTROL_STD_BACK_DOWN_ON              (C'0xA6,0xC8,0xB0')  // Color of standard control background when clicking on the control when it is on
  #define CLR_DEF_CONTROL_STD_BACK_OVER_ON              (C'0xB8,0xD3,0xC0')  // Color of standard control background when hovering the mouse over the control when it is on
  #define CLR_DEF_CONTROL_TAB_BACK_COLOR                (CLR_CANV_NULL)      // TabControl background color
  #define CLR_DEF_CONTROL_TAB_MOUSE_DOWN                (CLR_CANV_NULL)      // Color of TabControl background when clicking on the control
  #define CLR_DEF_CONTROL_TAB_MOUSE_OVER                (CLR_CANV_NULL)      // Color of TabControl background when hovering the mouse over the control
  #define CLR_DEF_CONTROL_TAB_OPACITY                   (0)                  // TabControl background opacity
  #define CLR_DEF_CONTROL_TAB_BACK_COLOR_ON             (CLR_CANV_NULL)      // Enabled TabControl background color
  #define CLR_DEF_CONTROL_TAB_BACK_DOWN_ON              (CLR_CANV_NULL)      // Color of enabled TabControl background when clicking on the control
  #define CLR_DEF_CONTROL_TAB_BACK_OVER_ON              (CLR_CANV_NULL)      // Color of enabled TabControl background when hovering the mouse over the control
  #define CLR_DEF_CONTROL_TAB_BORDER_COLOR              (CLR_CANV_NULL)      // TabControl frame color
  #define CLR_DEF_CONTROL_TAB_BORDER_MOUSE_DOWN         (CLR_CANV_NULL)      // Color of TabControl frame when clicking on the control
  #define CLR_DEF_CONTROL_TAB_BORDER_MOUSE_OVER         (CLR_CANV_NULL)      // Color of TabControl frame when hovering the mouse over the control  
  #define CLR_DEF_CONTROL_TAB_BORDER_COLOR_ON           (CLR_CANV_NULL)      // Enabled TabControl frame color
  #define CLR_DEF_CONTROL_TAB_BORDER_DOWN_ON            (CLR_CANV_NULL)      // Color of enabled TabControl frame when clicking on the control
  #define CLR_DEF_CONTROL_TAB_BORDER_OVER_ON            (CLR_CANV_NULL)      // Color of enabled TabControl frame when hovering the mouse over the control
  #define CLR_DEF_CONTROL_TAB_PAGE_BACK_COLOR           (C'0xFF,0xFF,0xFF')  // TabPage control background color
  #define CLR_DEF_CONTROL_TAB_PAGE_MOUSE_DOWN           (C'0xFF,0xFF,0xFF')  // Color of TabPage control background when clicking on the control
  #define CLR_DEF_CONTROL_TAB_PAGE_MOUSE_OVER           (C'0xFF,0xFF,0xFF')  // Color of TabPage control background when hovering the mouse over the control
  #define CLR_DEF_CONTROL_TAB_PAGE_OPACITY              (255)                  // TabPage background opacity    
  #define CLR_DEF_CONTROL_TAB_PAGE_BACK_COLOR_ON        (C'0xFF,0xFF,0xFF')  // Color of the enabled TabPage control background
  #define CLR_DEF_CONTROL_TAB_PAGE_BACK_DOWN_ON         (C'0xFF,0xFF,0xFF')  // Color of the enabled TabPage control background when clicking on the control
  #define CLR_DEF_CONTROL_TAB_PAGE_BACK_OVER_ON         (C'0xFF,0xFF,0xFF')  // Color of the enabled TabPage control background when hovering the mouse over the control
  #define CLR_DEF_CONTROL_TAB_PAGE_BORDER_COLOR         (C'0xDD,0xDD,0xDD')  // TabPage control frame color
  #define CLR_DEF_CONTROL_TAB_PAGE_BORDER_MOUSE_DOWN    (C'0xDD,0xDD,0xDD')  // Color of TabPage control background frame when clicking on the control
  #define CLR_DEF_CONTROL_TAB_PAGE_BORDER_MOUSE_OVER    (C'0xDD,0xDD,0xDD')  // Color of TabPage control background frame when hovering the mouse over the control    
  #define CLR_DEF_CONTROL_TAB_PAGE_BORDER_COLOR_ON      (C'0xDD,0xDD,0xDD')  // Color of the enabled TabPage control frame
  #define CLR_DEF_CONTROL_TAB_PAGE_BORDER_DOWN_ON       (C'0xDD,0xDD,0xDD')  // Color of the enabled TabPage control frame when clicking on the control
  #define CLR_DEF_CONTROL_TAB_PAGE_BORDER_OVER_ON       (C'0xDD,0xDD,0xDD')  // Color of the enabled TabPage control frame when hovering the mouse over the control
  #define CLR_DEF_CONTROL_TAB_HEAD_BACK_COLOR           (C'0xF0,0xF0,0xF0')  // TabPage control header background color
  #define CLR_DEF_CONTROL_TAB_HEAD_MOUSE_DOWN           (C'0xF0,0xF0,0xF0')  // Color of TabPage control header background when clicking on the control
  #define CLR_DEF_CONTROL_TAB_HEAD_MOUSE_OVER           (C'0xD8,0xEA,0xF9')  // Color of TabPage control header background when hovering the mouse over the control
  #define CLR_DEF_CONTROL_TAB_HEAD_OPACITY              (255)                  // TabPage header background opacity 
  #define CLR_DEF_CONTROL_TAB_HEAD_BACK_COLOR_ON        (C'0xFF,0xFF,0xFF')  // Color of the enabled TabPage control header background
  #define CLR_DEF_CONTROL_TAB_HEAD_BACK_DOWN_ON         (C'0xFF,0xFF,0xFF')  // Color of the enabled TabPage control header background when clicking on the control
  #define CLR_DEF_CONTROL_TAB_HEAD_BACK_OVER_ON         (C'0xFF,0xFF,0xFF')  // Color of the enabled TabPage control header background when clicking on the control
  #define CLR_DEF_CONTROL_TAB_HEAD_BORDER_COLOR         (C'0xD9,0xD9,0xD9')  // TabPage control header frame color
  #define CLR_DEF_CONTROL_TAB_HEAD_BORDER_MOUSE_DOWN    (C'0xD9,0xD9,0xD9')  // Color of TabPage control header frame when clicking on the control
  #define CLR_DEF_CONTROL_TAB_HEAD_BORDER_MOUSE_OVER    (C'0xD9,0xD9,0xD9')  // Color of TabPage control header frame when hovering the mouse over the control
  #define CLR_DEF_CONTROL_TAB_HEAD_BORDER_COLOR_ON      (C'0xDD,0xDD,0xDD')  // Color of the enabled TabPage control header frame
  #define CLR_DEF_CONTROL_TAB_HEAD_BORDER_DOWN_ON       (C'0xDD,0xDD,0xDD')  // Color of the enabled TabPage control header frame when clicking on the control
  #define CLR_DEF_CONTROL_TAB_HEAD_BORDER_OVER_ON       (C'0xDD,0xDD,0xDD')  // Color of the enabled TabPage control header frame when hovering the mouse over the control
  #define CLR_DEF_CONTROL_SPLIT_CONTAINER_BACK_COLOR    (C'0xF0,0xF0,0xF0')  // SplitContainer control background color
  #define CLR_DEF_CONTROL_SPLIT_CONTAINER_MOUSE_DOWN    (C'0xF0,0xF0,0xF0')  // Color of SplitContainer control background when clicking on the control
  #define CLR_DEF_CONTROL_SPLIT_CONTAINER_MOUSE_OVER    (C'0xF0,0xF0,0xF0')  // Color of SplitContainer control background when hovering the mouse over the control
  #define CLR_DEF_CONTROL_SPLIT_CONTAINER_BORDER_COLOR  (C'0x65,0x65,0x65')  // SplitContainer control frame color
  #define CLR_DEF_CONTROL_HINT_BACK_COLOR               (C'0xFF,0xFF,0xE1')  // Hint control background color
  #define CLR_DEF_CONTROL_HINT_BORDER_COLOR             (C'0x76,0x76,0x76')  // Hint control frame color
  #define CLR_DEF_CONTROL_HINT_FORE_COLOR               (C'0x5A,0x5A,0x5A')  // Hint control text color
  #define CLR_DEF_CONTROL_PROGRESS_BAR_BACK_COLOR       (C'0xF0,0xF0,0xF0')  // ProgressBar control background color
  #define CLR_DEF_CONTROL_PROGRESS_BAR_BORDER_COLOR     (C'0xBC,0xBC,0xBC')  // ProgressBar control frame color
  #define CLR_DEF_CONTROL_PROGRESS_BAR_FORE_COLOR       (C'0x00,0x78,0xD7')  // ProgressBar control text color
  #define CLR_DEF_CONTROL_PROGRESS_BAR_BAR_COLOR        (C'0x06,0xB0,0x25')  // ProgressBar control progress line color
  #define CLR_DEF_CONTROL_SCROLL_BAR_TRACK_BACK_COLOR   (C'0xF0,0xF0,0xF0')  // ScrollBar control background color
  #define CLR_DEF_CONTROL_SCROLL_BAR_TRACK_BORDER_COLOR (C'0xFF,0xFF,0xFF')  // ScrollBar control frame color
  #define CLR_DEF_CONTROL_SCROLL_BAR_TRACK_FORE_COLOR   (C'0x60,0x60,0x60')  // ScrollBar control text color
  #define CLR_DEF_CONTROL_SCROLL_BAR_TRACK_FORE_MOUSE_DOWN (C'0x00,0x00,0x00')// Color of ScrollBar control text when clicking on the control
  #define CLR_DEF_CONTROL_SCROLL_BAR_TRACK_FORE_MOUSE_OVER (C'0x00,0x00,0x00')// Color of ScrollBar control text when hovering the mouse over the control
  #define CLR_DEF_CONTROL_SCROLL_BAR_THUMB_COLOR        (C'0xCD,0xCD,0xCD')  // ScrollBar control capture area color
  #define CLR_DEF_CONTROL_SCROLL_BAR_THUMB_BORDER_COLOR (C'0xCD,0xCD,0xCD')  // ScrollBar control capture area frame color
  #define CLR_DEF_CONTROL_SCROLL_BAR_THUMB_MOUSE_DOWN   (C'0x60,0x60,0x60')  // Color of ScrollBar control capture area when clicking on the control
  #define CLR_DEF_CONTROL_SCROLL_BAR_THUMB_MOUSE_OVER   (C'0xA6,0xA6,0xA6')  // Color of ScrollBar control capture area when hovering over the control
  #define CLR_DEF_CONTROL_SCROLL_BAR_THUMB_FORE_COLOR   (C'0x60,0x60,0x60')  // ScrollBar control capture area text color
  #define CLR_DEF_CONTROL_SCROLL_BAR_THUMB_FORE_MOUSE_DOWN (C'0xFF,0xFF,0xFF')// Color of ScrollBar control capture area text when clicking on the control
  #define CLR_DEF_CONTROL_SCROLL_BAR_THUMB_FORE_MOUSE_OVER (C'0x00,0x00,0x00')// Color of ScrollBar control capture area text when hovering the mouse over the control
  #define CLR_DEF_CONTROL_SCROLL_BAR_BUTT_COLOR         (C'0xF0,0xF0,0xF0')  // ScrollBar control button color
  #define CLR_DEF_CONTROL_SCROLL_BAR_BUTT_BORDER_COLOR  (C'0xCD,0xCD,0xCD')  // ScrollBar control button frame color
  #define CLR_DEF_CONTROL_SCROLL_BAR_BUTT_MOUSE_DOWN    (C'0x60,0x60,0x60')  // Color of ScrollBar control buttons when clicking on the control
  #define CLR_DEF_CONTROL_SCROLL_BAR_BUTT_MOUSE_OVER    (C'0xDA,0xDA,0xDA')  // Color of ScrollBar control buttons when hovering the mouse over the control
  #define CLR_DEF_CONTROL_SCROLL_BAR_BUTT_FORE_COLOR    (C'0x60,0x60,0x60')  // ScrollBar control button text color
  #define CLR_DEF_CONTROL_SCROLL_BAR_BUTT_FORE_MOUSE_DOWN (C'0xFF,0xFF,0xFF')// Color of ScrollBar control button text when clicking on the control
  #define CLR_DEF_CONTROL_SCROLL_BAR_BUTT_FORE_MOUSE_OVER (C'0x00,0x00,0x00')// Color of ScrollBar control button text when hovering the mouse over the control 
  #define DEF_CONTROL_SCROLL_BAR_WIDTH                  (11)                 // Default ScrollBar control width
  #define DEF_CONTROL_SCROLL_BAR_THUMB_SIZE_MIN         (8)                  // Minimum size of the capture area (slider)
  #define DEF_CONTROL_SCROLL_BAR_SCROLL_STEP_CLICK      (2)                  // Shift step in pixels of the container content when scrolling by clicking the button
  #define DEF_CONTROL_SCROLL_BAR_SCROLL_STEP_WHELL      (4)                  // Shift step in pixels of the container content when scrolling with the mouse wheel
  #define DEF_CONTROL_CORNER_AREA                       (4)                  // Number of pixels defining the corner area to resize
  #define DEF_CONTROL_LIST_MARGIN_X                     (1)                  // Gap between columns in ListBox controls
  #define DEF_CONTROL_LIST_MARGIN_Y                     (0)                  // Gap between rows in ListBox controls
  #define DEF_CONTROL_TOOLTIP_INITIAL_DELAY             (500)                // Initial tooltip display delay
  #define DEF_CONTROL_TOOLTIP_AUTO_POP_DELAY            (5000)               // Tooltip display duration
  #define DEF_CONTROL_TOOLTIP_RESHOW_DELAY              (100)                // New tooltip display delay
  #define DEF_CONTROL_PROCESS_DURATION                  (1000)               // Process duration
 //Fonts
  #define DEF_FONT                                      ("Calibri")          // Default font
  #define DEF_FONT_SIZE                                 (8)                  // Default font size
  #define DEF_CHECK_SIZE                                (12)                 // Checkbox default size
  #define DEF_ARROW_BUTTON_SIZE                         (15)                 // Default arrow button size
  #define OUTER_AREA_SIZE                               (16)                 // Size of one side of the outer area around the form workspace
  #define DEF_FRAME_WIDTH_SIZE                          (3)                  // Default form/panel/window frame width
  #define DEF_HINT_ICON_SIZE                            (11)                 // Hint object side size
 //+------------------------------------------------------------------+
 //| Enumerations                                                     |
 //+------------------------------------------------------------------+
 //+------------------------------------------------------------------+
 //| List of library object types                                     |
 //+------------------------------------------------------------------+
 enum ENUM_OBJECT_DE_TYPE
  {
   //--- Graphics
    OBJECT_DE_TYPE_GBASE =  COLLECTION_ID_LIST_END+1,              // "Base object of all library graphical objects" object type
    OBJECT_DE_TYPE_GELEMENT,                                       // "Graphical element" object type
    OBJECT_DE_TYPE_GFORM,                                          // "Form" object type
    OBJECT_DE_TYPE_GFORM_CONTROL,                                  // "Form for managing pivot points of graphical object" object type
    OBJECT_DE_TYPE_GSHADOW,                                        // "Shadow" object type
    OBJECT_DE_TYPE_GGLARE,                                         // Glare object type
    OBJECT_DE_TYPE_GBITMAP,                                        // Bitmap object type
   //--- WinForms
    OBJECT_DE_TYPE_GWF_BASE,                                       // WinForms Base object type (base abstract WinForms object)
    OBJECT_DE_TYPE_GWF_CONTAINER,                                  // WinForms container object type
    OBJECT_DE_TYPE_GWF_COMMON,                                     // WinForms standard control object type
    OBJECT_DE_TYPE_GWF_HELPER,                                     // WinForms auxiliary control object type
   //--- Animation
   OBJECT_DE_TYPE_GFRAME,                                         // "Single animation frame" object type
   OBJECT_DE_TYPE_GFRAME_TEXT,                                    // "Single text animation frame" object type
   OBJECT_DE_TYPE_GFRAME_QUAD,                                    // "Single rectangular animation frame" object type
   OBJECT_DE_TYPE_GFRAME_GEOMETRY,                                // "Single geometric animation frame" object type
   OBJECT_DE_TYPE_GANIMATIONS,                                    // "Animations" object type
  //--- Managing graphical objects
   OBJECT_DE_TYPE_GELEMENT_CONTROL,                               // "Managing graphical objects" object type
  //--- Standard graphical objects
   OBJECT_DE_TYPE_GSTD_OBJ,                                       // "Standard graphical object" object type
   OBJECT_DE_TYPE_GSTD_VLINE              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_VLINE,            // "Vertical line" object type
   OBJECT_DE_TYPE_GSTD_HLINE              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_HLINE,            // "Horizontal line" object type
   OBJECT_DE_TYPE_GSTD_TREND              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TREND,            // "Trend line" object type
   OBJECT_DE_TYPE_GSTD_TRENDBYANGLE       =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TRENDBYANGLE,     // "Trend line by angle" object type
   OBJECT_DE_TYPE_GSTD_CYCLES             =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_CYCLES,           // "Cyclic lines" object type
   OBJECT_DE_TYPE_GSTD_ARROWED_LINE       =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROWED_LINE,     // "Arrowed line" object type
   OBJECT_DE_TYPE_GSTD_CHANNEL            =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_CHANNEL,          // "Equidistant channel" object type
   OBJECT_DE_TYPE_GSTD_STDDEVCHANNEL      =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_STDDEVCHANNEL,    // "Standard deviation channel" object type
   OBJECT_DE_TYPE_GSTD_REGRESSION         =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_REGRESSION,       // "Linear regression channel" object type
   OBJECT_DE_TYPE_GSTD_PITCHFORK          =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_PITCHFORK,        // "Andrews' pitchfork" object type
   OBJECT_DE_TYPE_GSTD_GANNLINE           =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_GANNLINE,         // "Gann line" object type
   OBJECT_DE_TYPE_GSTD_GANNFAN            =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_GANNFAN,          // "Gann fan" object type
   OBJECT_DE_TYPE_GSTD_GANNGRID           =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_GANNGRID,         // "Gann grid" object type
   OBJECT_DE_TYPE_GSTD_FIBO               =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_FIBO,             // "Fibo levels" object type
   OBJECT_DE_TYPE_GSTD_FIBOTIMES          =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_FIBOTIMES,        // "Fibo time zones" object type
   OBJECT_DE_TYPE_GSTD_FIBOFAN            =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_FIBOFAN,          // "Fibo fan" object type
   OBJECT_DE_TYPE_GSTD_FIBOARC            =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_FIBOARC,          // "Fibo arcs" object type
   OBJECT_DE_TYPE_GSTD_FIBOCHANNEL        =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_FIBOCHANNEL,      // "Fibo channel" object type
   OBJECT_DE_TYPE_GSTD_EXPANSION          =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_EXPANSION,        // "Fibo expansion" object type
   OBJECT_DE_TYPE_GSTD_ELLIOTWAVE5        =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ELLIOTWAVE5,      // "Elliott 5 waves" object type
   OBJECT_DE_TYPE_GSTD_ELLIOTWAVE3        =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ELLIOTWAVE3,      // "Elliott 3 waves" object type
   OBJECT_DE_TYPE_GSTD_RECTANGLE          =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_RECTANGLE,        // "Rectangle" object type
   OBJECT_DE_TYPE_GSTD_TRIANGLE           =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TRIANGLE,         // "Triangle" object type
   OBJECT_DE_TYPE_GSTD_ELLIPSE            =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ELLIPSE,          // "Ellipse" object type
   OBJECT_DE_TYPE_GSTD_ARROW_THUMB_UP     =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_THUMB_UP,   // "Thumb up" object type
   OBJECT_DE_TYPE_GSTD_ARROW_THUMB_DOWN   =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_THUMB_DOWN, // "Thumb down" object type
   OBJECT_DE_TYPE_GSTD_ARROW_UP           =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_UP,         // "Arrow up" object type
   OBJECT_DE_TYPE_GSTD_ARROW_DOWN         =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_DOWN,       // "Arrow down" object type
   OBJECT_DE_TYPE_GSTD_ARROW_STOP         =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_STOP,       // "Stop sign" object type
   OBJECT_DE_TYPE_GSTD_ARROW_CHECK        =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_CHECK,      // "Check mark" object type
   OBJECT_DE_TYPE_GSTD_ARROW_LEFT_PRICE   =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_LEFT_PRICE, // "Left price label" object type
   OBJECT_DE_TYPE_GSTD_ARROW_RIGHT_PRICE  =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_RIGHT_PRICE,// "Right price label" object type
   OBJECT_DE_TYPE_GSTD_ARROW_BUY          =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_BUY,        // "Buy" object type
   OBJECT_DE_TYPE_GSTD_ARROW_SELL         =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW_SELL,       // "Sell" object type
   OBJECT_DE_TYPE_GSTD_ARROW              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_ARROW,            // "Arrow" object type
   OBJECT_DE_TYPE_GSTD_TEXT               =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_TEXT,             // "Text" object type
   OBJECT_DE_TYPE_GSTD_LABEL              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_LABEL,            // "Text label" object type
   OBJECT_DE_TYPE_GSTD_BUTTON             =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_BUTTON,           // "Button" object type
   OBJECT_DE_TYPE_GSTD_CHART              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_CHART,            // "Chart" object type
   OBJECT_DE_TYPE_GSTD_BITMAP             =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_BITMAP,           // "Bitmap" object type
   OBJECT_DE_TYPE_GSTD_BITMAP_LABEL       =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_BITMAP_LABEL,     // "Bitmap label" object type
   OBJECT_DE_TYPE_GSTD_EDIT               =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_EDIT,             // "Edit" object type
   OBJECT_DE_TYPE_GSTD_EVENT              =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_EVENT,            // "Event object which corresponds to an event in Economic Calendar" object type
   OBJECT_DE_TYPE_GSTD_RECTANGLE_LABEL    =  OBJECT_DE_TYPE_GSTD_OBJ+1+OBJ_RECTANGLE_LABEL,  // "Event object which corresponds to an event in Economic Calendar" object type   
  //--- Objects
   OBJECT_DE_TYPE_BASE  =  OBJECT_DE_TYPE_GSTD_RECTANGLE_LABEL+1, // Base object for all library objects
   OBJECT_DE_TYPE_BASE_EXT,                                       // Extended base object for all library objects
   
   OBJECT_DE_TYPE_ACCOUNT,                                        // "Account" object type
   OBJECT_DE_TYPE_BOOK_ORDER,                                     // "Book order" object type
   OBJECT_DE_TYPE_BOOK_BUY,                                       // "Book buy order" object type
   OBJECT_DE_TYPE_BOOK_BUY_MARKET,                                // "Book buy order at market price" object type
   OBJECT_DE_TYPE_BOOK_SELL,                                      // "Book sell order" object type
   OBJECT_DE_TYPE_BOOK_SELL_MARKET,                               // "Book sell order at market price" object type
   OBJECT_DE_TYPE_BOOK_SNAPSHOT,                                  // "Book snapshot" object type
   OBJECT_DE_TYPE_BOOK_SERIES,                                    // "Book snapshot series" object type
   
   OBJECT_DE_TYPE_CHART,                                          // "Chart" object type
   OBJECT_DE_TYPE_CHART_WND,                                      // "Chart window" object type
   OBJECT_DE_TYPE_CHART_WND_IND,                                  // "Chart window indicator" object type
   
   OBJECT_DE_TYPE_EVENT,                                          // "Event" object type
   OBJECT_DE_TYPE_EVENT_BALANCE,                                  // "Balance operation event" object type
   OBJECT_DE_TYPE_EVENT_MODIFY,                                   // "Pending order/position modification event" object type
   OBJECT_DE_TYPE_EVENT_ORDER_PLASED,                             // "Placing a pending order event" object type
   OBJECT_DE_TYPE_EVENT_ORDER_REMOVED,                            // "Pending order removal event" object type
   OBJECT_DE_TYPE_EVENT_POSITION_CLOSE,                           // "Position closure event" object type
   OBJECT_DE_TYPE_EVENT_POSITION_OPEN,                            // "Position opening event" object type
   
   OBJECT_DE_TYPE_IND_BUFFER,                                     // "Indicator buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_ARROW,                               // "Arrow rendering buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_BAR,                                 // "Bar buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_CALCULATE,                           // "Calculated buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_CANDLE,                              // "Candle buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_FILLING,                             // "Filling buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_HISTOGRAMM,                          // "Histogram buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_HISTOGRAMM2,                         // "Histogram 2 buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_LINE,                                // "Line buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_SECTION,                             // "Section buffer" object type
   OBJECT_DE_TYPE_IND_BUFFER_ZIGZAG,                              // "Zigzag buffer" object type
   OBJECT_DE_TYPE_INDICATOR,                                      // "Indicator" object type
   OBJECT_DE_TYPE_IND_DATA,                                       // "Indicator data" object type
   OBJECT_DE_TYPE_IND_DATA_LIST,                                  // "Indicator data list" object type
   
   OBJECT_DE_TYPE_IND_AC,                                         // "Accelerator Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_AD,                                         // "Accumulation/Distribution indicator" object type
   OBJECT_DE_TYPE_IND_ADX,                                        // "Average Directional Index indicator" object type
   OBJECT_DE_TYPE_IND_ADXW,                                       // "ADX indicator by Welles Wilder" object type
   OBJECT_DE_TYPE_IND_ALLIGATOR,                                  // "Alligator indicator" object type
   OBJECT_DE_TYPE_IND_AMA,                                        // "Adaptive Moving Average indicator" object type
   OBJECT_DE_TYPE_IND_AO,                                         // "Awesome Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_ATR,                                        // "Average True Range" object type
   OBJECT_DE_TYPE_IND_BANDS,                                      // "Bollinger Bands® indicator" object type
   OBJECT_DE_TYPE_IND_BEARS,                                      // "Bears Power indicator" object type
   OBJECT_DE_TYPE_IND_BULLS,                                      // "Bulls Power indicator" object type
   OBJECT_DE_TYPE_IND_BWMFI,                                      // "Market Facilitation Index indicator" object type
   OBJECT_DE_TYPE_IND_CCI,                                        // "Commodity Channel Index indicator" object type
   OBJECT_DE_TYPE_IND_CHAIKIN,                                    // "Chaikin Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_CUSTOM,                                     // "Custom indicator" object type
   OBJECT_DE_TYPE_IND_DEMA,                                       // "Double Exponential Moving Average indicator" object type
   OBJECT_DE_TYPE_IND_DEMARKER,                                   // "DeMarker indicator" object type
   OBJECT_DE_TYPE_IND_ENVELOPES,                                  // "Envelopes indicator" object type
   OBJECT_DE_TYPE_IND_FORCE,                                      // "Force Index indicator" object type
   OBJECT_DE_TYPE_IND_FRACTALS,                                   // "Fractals indicator" object type
   OBJECT_DE_TYPE_IND_FRAMA,                                      // "Fractal Adaptive Moving Average indicator" object type
   OBJECT_DE_TYPE_IND_GATOR,                                      // "Gator Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_ICHIMOKU,                                   // "Ichimoku Kinko Hyo indicator" object type
   OBJECT_DE_TYPE_IND_MA,                                         // "Moving Average indicator" object type
   OBJECT_DE_TYPE_IND_MACD,                                       // "Moving Average Convergence/Divergence indicator" object type
   OBJECT_DE_TYPE_IND_MFI,                                        // "Money Flow Index indicator" object type
   OBJECT_DE_TYPE_IND_MOMENTUM,                                   // "Momentum indicator" object type
   OBJECT_DE_TYPE_IND_OBV,                                        // "On Balance Volume indicator" object type
   OBJECT_DE_TYPE_IND_OSMA,                                       // "Moving Average of Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_RSI,                                        // "Relative Strength Index indicator" object type
   OBJECT_DE_TYPE_IND_RVI,                                        // "Relative Vigor Index indicator" object type
   OBJECT_DE_TYPE_IND_SAR,                                        // "Parabolic SAR indicator" object type
   OBJECT_DE_TYPE_IND_STDEV,                                      // "Standard Deviation indicator" object type
   OBJECT_DE_TYPE_IND_STOCH,                                      // "Stochastic Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_TEMA,                                       // "Triple Exponential Moving Average indicator" object
   OBJECT_DE_TYPE_IND_TRIX,                                       // "Triple Exponential Moving Averages Oscillator indicator" object type
   OBJECT_DE_TYPE_IND_VIDYA,                                      // "Variable Index Dynamic Average indicator" object type
   OBJECT_DE_TYPE_IND_VOLUMES,                                    // "Volumes indicator" object type
   OBJECT_DE_TYPE_IND_WPR,                                        // "Williams' Percent Range indicator" object type
   
   OBJECT_DE_TYPE_MQL5_SIGNAL,                                    // "mql5 signal" object type
   
   OBJECT_DE_TYPE_ORDER_DEAL_POSITION,                            // "Order/Deal/Position" object type
   OBJECT_DE_TYPE_HISTORY_BALANCE,                                // "Historical balance operation" object type
   OBJECT_DE_TYPE_HISTORY_DEAL,                                   // "Historical deal" object type
   OBJECT_DE_TYPE_HISTORY_ORDER_MARKET,                           // "Historical market order" object type
   OBJECT_DE_TYPE_HISTORY_ORDER_PENDING,                          // "Historical removed pending order" object type
   OBJECT_DE_TYPE_MARKET_ORDER,                                   // "Market order" object type
   OBJECT_DE_TYPE_MARKET_PENDING,                                 // "Pending order" object type
   OBJECT_DE_TYPE_MARKET_POSITION,                                // "Market position" object type
   
   OBJECT_DE_TYPE_PENDING_REQUEST,                                // "Pending trading request" object type
   OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_OPEN,                  // "Pending request to open a position" object type
   OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_CLOSE,                 // "Pending request to close a position" object type
   OBJECT_DE_TYPE_PENDING_REQUEST_POSITION_SLTP,                  // "Pending request to modify position stop orders" object type
   OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_PLACE,                    // "Pending request to place a pending order" object type
   OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_REMOVE,                   // "Pending request to delete a pending order" object type
   OBJECT_DE_TYPE_PENDING_REQUEST_ORDER_MODIFY,                   // "Pending request to modify pending order parameters" object type
   
   OBJECT_DE_TYPE_SERIES_BAR,                                     // "Bar" object type
   OBJECT_DE_TYPE_SERIES_PERIOD,                                  // "Period timeseries" object type
   OBJECT_DE_TYPE_SERIES_SYMBOL,                                  // "Symbol timeseries" object type
   
   OBJECT_DE_TYPE_SERIES_PATTERN,                                 // "Pattern" object type
   OBJECT_DE_TYPE_SERIES_PATTERN_CONTROL,                         // "Pattern management" object type
   OBJECT_DE_TYPE_SERIES_PATTERNS_CONTROLLERS,                    // "Patterns management" object type
   
   OBJECT_DE_TYPE_SYMBOL,                                         // "Symbol" object type
   OBJECT_DE_TYPE_SYMBOL_BONDS,                                   // "Bond symbol" object type
   OBJECT_DE_TYPE_SYMBOL_CFD,                                     // "CFD (contract for difference) symbol" object type
   OBJECT_DE_TYPE_SYMBOL_COLLATERAL,                              // "Non-tradable asset symbol" object type" object type
   OBJECT_DE_TYPE_SYMBOL_COMMODITY,                               // "Commodity symbol" object type
   OBJECT_DE_TYPE_SYMBOL_COMMON,                                  // "Common group symbol" object type
   OBJECT_DE_TYPE_SYMBOL_CRYPTO,                                  // "Cryptocurrency symbol" object type
   OBJECT_DE_TYPE_SYMBOL_CUSTOM,                                  // "Custom symbol" object type
   OBJECT_DE_TYPE_SYMBOL_EXCHANGE,                                // "Exchange symbol" object type
   OBJECT_DE_TYPE_SYMBOL_FUTURES,                                 // "Futures symbol" object type
   OBJECT_DE_TYPE_SYMBOL_FX,                                      // "Forex symbol" object type
   OBJECT_DE_TYPE_SYMBOL_FX_EXOTIC,                               // "Exotic Forex symbol" object type
   OBJECT_DE_TYPE_SYMBOL_FX_MAJOR,                                // "Major Forex symbol" object type
   OBJECT_DE_TYPE_SYMBOL_FX_MINOR,                                // "Minor Forex symbol" object type
   OBJECT_DE_TYPE_SYMBOL_FX_RUB,                                  // "RUB Forex symbol" object type
   OBJECT_DE_TYPE_SYMBOL_INDEX,                                   // "Index symbol" object type
   OBJECT_DE_TYPE_SYMBOL_INDICATIVE,                              // "Indicative symbol" object type
   OBJECT_DE_TYPE_SYMBOL_METALL,                                  // "Metal symbol" object type
   OBJECT_DE_TYPE_SYMBOL_OPTION,                                  // "Option symbol" object type
   OBJECT_DE_TYPE_SYMBOL_STOCKS,                                  // "Stock symbol" object type
   
   OBJECT_DE_TYPE_TICK,                                           // "Tick" object type
   OBJECT_DE_TYPE_NEW_TICK,                                       // "New tick" object type
   OBJECT_DE_TYPE_TICKSERIES,                                     // "Tick data series" object type
   
   OBJECT_DE_TYPE_TRADE,                                          // "Trading object" object type
   
   OBJECT_DE_TYPE_LONG,                                           // "Long type data" object type
   OBJECT_DE_TYPE_DOUBLE,                                         // "Double type data" object type
   OBJECT_DE_TYPE_STRING,                                         // "String type data" object type
   OBJECT_DE_TYPE_OBJECT,                                         // "Object type data" object type
  };

//+------------------------------------------------------------------+
//| Search and sorting data                                          |
//+------------------------------------------------------------------+
enum ENUM_COMPARER_TYPE
  {
   EQUAL,                                                   // Equal
   MORE,                                                    // More
   LESS,                                                    // Less
   NO_EQUAL,                                                // Not equal
   EQUAL_OR_MORE,                                           // Equal or more
   EQUAL_OR_LESS                                            // Equal or less
  };
//+------------------------------------------------------------------+
//| Possible options of selecting by time                            |
//+------------------------------------------------------------------+
enum ENUM_SELECT_BY_TIME
  {
   SELECT_BY_TIME_OPEN,                                     // By open time (in milliseconds)
   SELECT_BY_TIME_CLOSE,                                    // By close time (in milliseconds)
  };
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
//+------------------------------------------------------------------+
//| List of flags of possible order and position change options      |
//+------------------------------------------------------------------+
enum ENUM_CHANGE_TYPE_FLAGS
  {
   CHANGE_TYPE_FLAG_NO_CHANGE    =  0x0,                    // No changes
   CHANGE_TYPE_FLAG_TYPE         =  0x1,                    // Order type change
   CHANGE_TYPE_FLAG_PRICE        =  0x2,                    // Price change
   CHANGE_TYPE_FLAG_STOP         =  0x4,                    // StopLoss change
   CHANGE_TYPE_FLAG_TAKE         =  0x8,                    // TakeProfit change
   CHANGE_TYPE_FLAG_ORDER        =  0x10                    // Order properties change flag
  };
//+------------------------------------------------------------------+
//| Possible order and position change options                       |
//+------------------------------------------------------------------+
enum ENUM_CHANGE_TYPE
  {
   CHANGE_TYPE_NO_CHANGE,                                   // No changes
   CHANGE_TYPE_ORDER_TYPE,                                  // Order type change
   CHANGE_TYPE_ORDER_PRICE,                                 // Order price change
   CHANGE_TYPE_ORDER_PRICE_STOP_LOSS,                       // Order and StopLoss price change 
   CHANGE_TYPE_ORDER_PRICE_TAKE_PROFIT,                     // Order and TakeProfit price change
   CHANGE_TYPE_ORDER_PRICE_STOP_LOSS_TAKE_PROFIT,           // Order, StopLoss and TakeProfit price change
   CHANGE_TYPE_ORDER_STOP_LOSS_TAKE_PROFIT,                 // StopLoss and TakeProfit change
   CHANGE_TYPE_ORDER_STOP_LOSS,                             // Order's StopLoss change
   CHANGE_TYPE_ORDER_TAKE_PROFIT,                           // Order's TakeProfit change
   CHANGE_TYPE_POSITION_STOP_LOSS_TAKE_PROFIT,              // Change position's StopLoss and TakeProfit
   CHANGE_TYPE_POSITION_STOP_LOSS,                          // Change position's StopLoss
   CHANGE_TYPE_POSITION_TAKE_PROFIT,                        // Change position's TakeProfit
  };

#endif // __COMMON_DEFINES_MQH__