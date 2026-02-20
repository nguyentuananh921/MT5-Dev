//This is iBand_Display.mqh
#ifndef __IBAND_DISPLAY_MQH__
#define __IBAND_DISPLAY_MQH__

//--------------------------------------------------
// Dependencies
//--------------------------------------------------
#include <Anhnt/Configuration/EnumConfiguration.mqh>
#include <Anhnt/Configuration/IndicatorConfiguration.mqh>
#include <Anhnt/Configuration/ColorConfiguration.mqh>
#include <Anhnt/Configuration/NamingConfiguration.mqh>
#include <Anhnt/Utilities/Timeframe.mqh>
//--------------------------------------------------
// Globals
//--------------------------------------------------
// Indicator attached to chart (visual only)
int g_bband_visual_handle = INVALID_HANDLE;

// Indicator handles used for logic (one per timeframe)
int g_bband_logic_handles[];
//bool g_bband_visual_attached    = false;
#ifndef __IBAND_DISPLAY_MQH_COMMON__
#define __IBAND_DISPLAY_MQH_COMMON__
   // Create BBand handle (shared by logic & visual)
   int CreateBBHandle(
      ENUM_TIMEFRAMES tf,
      bool showMiddle,
      bool showUpper,
      bool showLower
   )
   {
      return iCustom(
         _Symbol,
         tf,
         "Anhnt\\iBand_Display",

         inp_EA_BB_Period,
         inp_EA_Applied_Price,
         inp_EA_BB_Deviation,         
         0, // InpBBShift

         inp_EA_BB_Middle_Color,
         inp_EA_BB_Upper_Color,
         inp_EA_BB_Lower_Color,
      
         inp_EA_BB_Width,
         inp_EA_BB_Width,
         inp_EA_BB_Width,
         
         showUpper,
         showMiddle,
         showLower,         

         inp_EA_BB_Middle_Style,
         inp_EA_BB_Upper_Style,
         inp_EA_BB_Lower_Style
         
      );
   }
   void BB_Deinit()
   {
      BB_DeinitVisual();
      BB_DeinitLogic();
   }
#endif // __IBAND_DISPLAY_MQH_COMMON__

#ifndef __IBAND_DISPLAY_MQH_LOGICPART__
#define __IBAND_DISPLAY_MQH_LOGICPART__
   bool BB_InitLogicHandles()
   {
      if(ArraySize(g_bband_logic_handles) != g_num_supported_timeframes)
      {
         ArrayResize(g_bband_logic_handles, g_num_supported_timeframes);

         for(int i = 0; i < g_num_supported_timeframes; i++)
            g_bband_logic_handles[i] = INVALID_HANDLE;
      }
      for(int i = 0; i < g_num_supported_timeframes; i++)
      {
         if(g_bband_logic_handles[i] == INVALID_HANDLE)
         {
            g_bband_logic_handles[i] = CreateBBHandle(
               g_supported_timeframes[i],
               true,   // middle
               true,   // upper
               true    // lower
            );
            if(g_bband_logic_handles[i] == INVALID_HANDLE)
            {
               Print("BB_InitLogicHandles FAILED at TF: ",
                     GetTimeframeShortName(g_supported_timeframes[i]));
               return false;
            }
         }
      }
      return true;
   }

   void BB_DeinitLogic()
   {
      for(int i = 0; i < ArraySize(g_bband_logic_handles); i++)
         {
            if(g_bband_logic_handles[i] != INVALID_HANDLE)
            {
               IndicatorRelease(g_bband_logic_handles[i]);         
               g_bband_logic_handles[i] = INVALID_HANDLE; //Reset handle
            }     
         }
         ArrayResize(g_bband_logic_handles, 0);//Clear array after releasing all handles
   }

   double BB_GetUpperValue(ENUM_TIMEFRAMES tf, int shift)
   {
      int idx = GetTFIndex(tf);
      if(idx < 0) return EMPTY_VALUE;

      double val[1];
      if(CopyBuffer(g_bband_logic_handles[idx], 1, shift, 1, val) <= 0)
         return EMPTY_VALUE;

      return val[0];
   }

   //--------------------------------------------------
   double BB_GetMiddleValue(ENUM_TIMEFRAMES tf, int shift)
   {
      int idx = GetTFIndex(tf);
      if(idx < 0) return EMPTY_VALUE;

      double val[1];
      if(CopyBuffer(g_bband_logic_handles[idx], 0, shift, 1, val) <= 0)
         return EMPTY_VALUE;

      return val[0];
   }

   //--------------------------------------------------
   double BB_GetLowerValue(ENUM_TIMEFRAMES tf, int shift)
   {
      int idx = GetTFIndex(tf);
      if(idx < 0) return EMPTY_VALUE;

      double val[1];
      if(CopyBuffer(g_bband_logic_handles[idx], 2, shift, 1, val) <= 0)
         return EMPTY_VALUE;

      return val[0];
   }

#endif // __IBAND_DISPLAY_MQH_LOGICPART__

#ifndef __IBAND_DISPLAY_MQH_VISUALPART__
#define __IBAND_DISPLAY_MQH_VISUALPART__   
   bool BB_InitVisualHandle()
   {   
      // Print("Debug BB_InitVisualHandle from Helper START");
      // Print("From Helper Symbol = ", _Symbol,
      //       " | _Period = ", (ENUM_TIMEFRAMES)_Period);

      string short_name = SMT_PREFIX + SMT_BB_NAME +
                       "(" + (string)inp_EA_BB_Period + "," +
                       DoubleToString(inp_EA_BB_Deviation, 1) + ")";

      //Always try delete old indicator before creating new one (avoid 4114 on TF change)
      ChartIndicatorDelete(0, 0, short_name);

      ResetLastError();
      g_bband_visual_handle = CreateBBHandle(
                                 (ENUM_TIMEFRAMES)_Period,
                                 inp_EA_BB_Show_Middle,
                                 inp_EA_BB_Show_Upper,
                                 inp_EA_BB_Show_Lower
                              );
      // Print("From Helper CreateBBHandle returned handle = ",
      //       g_bband_visual_handle,
      //       " | GetLastError = ", GetLastError());
      if(g_bband_visual_handle == INVALID_HANDLE)
      {
         Print("Debug from Helper BB_InitVisualHandle FAILED.",
               " | Handle = ", g_bband_visual_handle,
               " | GetLastError = ", GetLastError());
         return false;
      }      

      if(!ChartIndicatorAdd(0, 0, g_bband_visual_handle))
      {         
         Print("Debug from helper ChartIndicatorAdd FAILED.",
               " | Handle = ", g_bband_visual_handle,
               " | BarsCalculated = ", BarsCalculated(g_bband_visual_handle),
               " | Bar count = ", Bars(_Symbol,_Period),
               " | Error = ", GetLastError());               
         return false;
      }           
      
      // Print("Debug from Helper BB_InitVisualHandle in Helper SUCCESS. Handle stored = ",
      //       g_bband_visual_handle);
      // Print("--------------------------------------------------");       
      return true;
   }   
   void BB_DeinitVisual()
   {
      int total = ChartIndicatorsTotal(0,0);

      for(int i = total-1; i >= 0; i--) // Check all indicators on chart for remove them
      {
         string name = ChartIndicatorName(0,0,i);

         if(StringFind(name, "iBand_Display") >= 0)
         {
            ChartIndicatorDelete(0,0,name);
         }
      }

      if(g_bband_visual_handle != INVALID_HANDLE)
      {
         IndicatorRelease(g_bband_visual_handle);
         g_bband_visual_handle = INVALID_HANDLE;
      }
   }
#endif // __IBAND_DISPLAY_MQH_VISUALPART__
#endif // __IBAND_DISPLAY_MQH__
