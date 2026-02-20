//This is EMA_Display.mqh
#ifndef __EMA_DISPLAY_MQH__
#define __EMA_DISPLAY_MQH__

//--------------------------------------------------
// Dependencies
//--------------------------------------------------
#include <Anhnt/Configuration/IndicatorConfiguration.mqh>
#include <Anhnt/Configuration/ColorConfiguration.mqh>
#include <Anhnt/Configuration/EnumConfiguration.mqh>
#include <Anhnt/Utilities/timeframe.mqh>

#include <Anhnt/Utilities/EA_common.mqh>
//--------------------------------------------------
// Globals
//--------------------------------------------------
int g_ema_visual_handle = INVALID_HANDLE;
int g_ema_logic_handles[];
#ifndef __EMA_DISPLAY_MQH_COMMON_PART__
#define __EMA_DISPLAY_MQH_COMMON_PART__
   // Create EMA handle (shared by logic & visual)
   //--------------------------------------------------
   int CreateEMAHandle(
      ENUM_TIMEFRAMES tf,
      bool showFast,
      bool showSlow,
      bool showLong
   )
   {
      int handle = iCustom(
         _Symbol,
         tf,
         "Anhnt\\EMA_Display",
         inp_EA_EMA_Fast_Period,
         inp_EA_EMA_Slow_Period,
         inp_EA_EMA_Long_Period,

         inp_EA_EMA_Applied_Price,

         showFast,
         showSlow,
         showLong,

         inp_EA_EMA_Fast_Color,
         inp_EA_EMA_Slow_Color,
         inp_EA_EMA_Long_Color,

         inp_EA_EMA_Fast_Style,
         inp_EA_EMA_Slow_Style,
         inp_EA_EMA_Long_Style,

         inp_EA_EMA_Width,

         inp_EA_EMA_Update_OnClosedBar
      );

      return handle;
   }
   void EMA_Deinit()
   {
      //Delete EMA from chart before releasing handle
      string short_name = SMT_PREFIX + SMT_EMA_NAME + "(" +
                        (string)inp_EA_EMA_Fast_Period + "," +
                        (string)inp_EA_EMA_Slow_Period + "," +
                        (string)inp_EA_EMA_Long_Period + ")";

      ChartIndicatorDelete(0, 0, short_name);
      // release visual
      if(g_ema_visual_handle != INVALID_HANDLE)
      {
         IndicatorRelease(g_ema_visual_handle);
         g_ema_visual_handle = INVALID_HANDLE;
      }

      // release logic
      for(int i = 0; i < ArraySize(g_ema_logic_handles); i++)
      {
         if(g_ema_logic_handles[i] != INVALID_HANDLE)
            IndicatorRelease(g_ema_logic_handles[i]);
      }
      ArrayResize(g_ema_logic_handles, 0);
   }

#endif // __EMA_DISPLAY_MQH_COMMON_PART__

#ifndef __EMA_DISPLAY_MQH_LOGIC_PART__
#define __EMA_DISPLAY_MQH_LOGIC_PART__
   bool EMA_InitLogicHandles()
   {
      if(ArraySize(g_ema_logic_handles) != g_num_supported_timeframes)
      {
         ArrayResize(g_ema_logic_handles, g_num_supported_timeframes);

         // ChatGPT add here: initialize handles
         for(int i = 0; i < g_num_supported_timeframes; i++)
            g_ema_logic_handles[i] = INVALID_HANDLE;
      }

      for(int i = 0; i < g_num_supported_timeframes; i++)
      {
         if(g_ema_logic_handles[i] == INVALID_HANDLE)
         {
            g_ema_logic_handles[i] = CreateEMAHandle(
               g_supported_timeframes[i],
               true, true, true // ChatGPT add here: logic must calculate all lines
            );
            if(g_ema_logic_handles[i] == INVALID_HANDLE)
               return false;
         }
      }
      return true;
   }

   //--------------------------------------------------
   // GET EMA VALUES (LOGIC)
   //--------------------------------------------------
   bool GetEMA_Current(
      ENUM_TIMEFRAMES tf,
      int shift,
      double &fast,
      double &slow,
      double &lng
   )
   {
      int index = GetTFIndex(tf); // ChatGPT modify here

      if(index < 0)
         return false;

      int handle = g_ema_logic_handles[index];

      if(handle == INVALID_HANDLE)
         return false;

      if(BarsCalculated(handle) <= shift)
         return false;

      double fast_buf[1];
      double slow_buf[1];
      double long_buf[1];

      if(CopyBuffer(handle, 0, shift, 1, fast_buf) <= 0)
         return false;

      if(CopyBuffer(handle, 1, shift, 1, slow_buf) <= 0)
         return false;

      if(CopyBuffer(handle, 2, shift, 1, long_buf) <= 0)
         return false;

      fast = fast_buf[0];
      slow = slow_buf[0];
      lng  = long_buf[0];

      return true;
   }   
#endif // __EMA_DISPLAY_MQH_LOGIC_PART__

#ifndef __EMA_DISPLAY_MQH_VISUAL_PART__
#define __EMA_DISPLAY_MQH_VISUAL_PART__
   bool EMA_InitVisualHandles()
   {
      //RemoveSMTChartIndicators(); // Clean up call function in Utilities/EA_common.mqh
      //Rebuild exact short name to delete old instance (avoid duplicate on TF change)
      // string short_name = SMT_PREFIX + SMT_EMA_NAME + "(" +
      //                   (string)inp_EA_EMA_Fast_Period + "," +
      //                   (string)inp_EA_EMA_Slow_Period + "," +
      //                   (string)inp_EA_EMA_Long_Period + ")";

      // //Always delete old EMA before adding new one
      // ChartIndicatorDelete(0, 0, short_name);

      if(g_ema_visual_handle != INVALID_HANDLE)
      {
         IndicatorRelease(g_ema_visual_handle);
         g_ema_visual_handle = INVALID_HANDLE;
      }

      ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)_Period;
      g_ema_visual_handle = CreateEMAHandle(
         tf,
         inp_EA_EMA_Fast_Show,
         inp_EA_EMA_Slow_Show,
         inp_EA_EMA_Long_Show
      );
      if(g_ema_visual_handle == INVALID_HANDLE) //Can't create visual handle
      {
         Print("From EMA Helper visual handle create failed. Error = ", GetLastError());
         return false;
      }  

      //Chat GPT add here: check add result to avoid silent failure
      if(!ChartIndicatorAdd(0, 0, g_ema_visual_handle))
      {
         Print("From EMA Helper ChartIndicatorAdd FAILED. Error = ", GetLastError());
         IndicatorRelease(g_ema_visual_handle);
         g_ema_visual_handle = INVALID_HANDLE;
         return false;
      }      
      return true;
   }  

#endif // __EMA_DISPLAY_MQH_VISUAL_PART__
#endif // __EMA_DISPLAY_MQH__
