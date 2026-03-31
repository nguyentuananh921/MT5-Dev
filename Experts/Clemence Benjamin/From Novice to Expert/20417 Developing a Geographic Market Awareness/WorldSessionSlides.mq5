//+------------------------------------------------------------------+
//|                                               WorldSessionSlides |
//|   Session-based world map slideshow + session time markers       |
//|   with terminal & push notifications on session changes          |
//+------------------------------------------------------------------+
#property strict
#property copyright "Clemence Benjamin"
#property link      "https://mql5.com"
#property version   "1.01"

//--- Embed BLUE OCEAN bitmaps as resources
#resource "\\Images\\world_idle.bmp"
#resource "\\Images\\world_sydney.bmp"
#resource "\\Images\\world_tokyo.bmp"
#resource "\\Images\\world_london.bmp"
#resource "\\Images\\world_newyork.bmp"

//--- Embed DARK GRAY theme bitmaps as resources
#resource "\\Images\\world_idle_dark.bmp"
#resource "\\Images\\world_sydney_dark.bmp"
#resource "\\Images\\world_tokyo_dark.bmp"
#resource "\\Images\\world_london_dark.bmp"
#resource "\\Images\\world_newyork_dark.bmp"

//--- Session time marker helper
#include <SessionVisualizer.mqh>

//--- Inputs: session times in broker time (hours 0..23)
input int  InpSydneyOpen    = 22;
input int  InpSydneyClose   = 7;
input int  InpTokyoOpen     = 0;
input int  InpTokyoClose    = 9;
input int  InpLondonOpen    = 8;
input int  InpLondonClose   = 17;
input int  InpNewYorkOpen   = 13;
input int  InpNewYorkClose  = 22;

//--- Timer period in seconds
input int  InpCheckPeriod   = 15;

//--- Theme toggle: false = blue ocean, true = dark gray
input bool InpUseDarkTheme  = false;

//--- Marker control
input bool InpShowSessionMarkers = true;
input int  InpMarkersGMTOffset   = 0;   // offset from GMT for marker schedule

//--- Notification control
enum ENUM_NOTIFY_MODE
  {
   NOTIFY_OFF = 0,
   NOTIFY_SESSION_CHANGES,       // any change (none/single/overlap)
   NOTIFY_OVERLAPS_ONLY         // only when 2+ sessions overlap
  };

input ENUM_NOTIFY_MODE InpNotifyMode        = NOTIFY_SESSION_CHANGES;
input bool             InpTerminalAlerts    = true;   // Alert()
input bool             InpPushNotifications = false;  // SendNotification()

//--- Object names
string   g_bg_name          = "WSLIDE_BG";
string   g_text_name        = "WSLIDE_TEXT";

//--- Current session tracking
enum SESSION_ID
  {
   SESSION_NONE    = -1,
   SESSIONs_SYDNEY  = 0,
   SESSIONs_TOKYO   = 1,
   SESSIONs_LONDON  = 2,
   SESSIONs_NEWYORK = 3
  };

// Bitmask of active sessions (bit 0 = Sydney, 1 = Tokyo, 2 = London, 3 = New York)
int     g_current_session_mask = 0;
long    g_chart_id             = 0;
int     g_check_period         = 15;   // runtime copy of InpCheckPeriod
string  g_last_bitmap_file     = "";   // last resource used for centering

// Session visualizer
CSessionVisualizer g_sess_vis;

//+------------------------------------------------------------------+
//| Helper: check if hour is inside [start, end) with wrap support   |
//+------------------------------------------------------------------+
bool HourInRange(int start_hour,int end_hour,int h)
  {
   // no wrap (e.g. 08 -> 17)
   if(start_hour < end_hour)
      return (h >= start_hour && h < end_hour);

   // wrap over midnight (e.g. 22 -> 7)
   if(start_hour > end_hour)
      return (h >= start_hour || h < end_hour);

   // start == end  => treat as closed (no active range)
   return(false);
  }

//+------------------------------------------------------------------+
//| Build a bitmask of all active sessions at time t                 |
//| bit 0: Sydney, bit 1: Tokyo, bit 2: London, bit 3: New York      |
//+------------------------------------------------------------------+
int GetSessionMaskFromTime(datetime t)
  {
   MqlDateTime st;
   TimeToStruct(t,st);
   int h    = st.hour;
   int mask = 0;

   if(HourInRange(InpSydneyOpen,InpSydneyClose,h))
      mask |= (1 << SESSION_SYDNEY);
   if(HourInRange(InpTokyoOpen,InpTokyoClose,h))
      mask |= (1 << SESSION_TOKYO);
   if(HourInRange(InpLondonOpen,InpLondonClose,h))
      mask |= (1 << SESSION_LONDON);
   if(HourInRange(InpNewYorkOpen,InpNewYorkClose,h))
      mask |= (1 << SESSION_NEWYORK);

   return(mask);
  }

//+------------------------------------------------------------------+
//| Count how many sessions are active in mask (for overlaps)        |
//+------------------------------------------------------------------+
int CountActiveSessions(int mask)
  {
   int count = 0;
   for(int i=0; i<4; ++i)
     {
      if(mask & (1<<i))
         count++;
     }
   return(count);
  }

//+------------------------------------------------------------------+
//| Pick one "dominant" session from a mask (for bitmap selection)   |
//| Priority: New York > London > Tokyo > Sydney                     |
//+------------------------------------------------------------------+
int DominantSessionFromMask(int mask)
  {
   if((mask & (1 << SESSION_NEWYORK)) != 0)
      return SESSION_NEWYORK;
   if((mask & (1 << SESSION_LONDON)) != 0)
      return SESSION_LONDON;
   if((mask & (1 << SESSION_TOKYO)) != 0)
      return SESSION_TOKYO;
   if((mask & (1 << SESSION_SYDNEY)) != 0)
      return SESSION_SYDNEY;

   return SESSION_NONE;
  }

//+------------------------------------------------------------------+
//| Build human-readable label from mask (handles overlaps)          |
//+------------------------------------------------------------------+
string BuildSessionLabel(int mask)
  {
   if(mask == 0)
      return "NO MAJOR SESSION (IDLE MAP)";

   string label = "";
   int    count = 0;

   if((mask & (1 << SESSION_SYDNEY)) != 0)
     {
      if(count > 0) label += " + ";
      label += "SYDNEY";
      count++;
     }

   if((mask & (1 << SESSION_TOKYO)) != 0)
     {
      if(count > 0) label += " + ";
      label += "TOKYO";
      count++;
     }

   if((mask & (1 << SESSION_LONDON)) != 0)
     {
      if(count > 0) label += " + ";
      label += "LONDON";
      count++;
     }

   if((mask & (1 << SESSION_NEWYORK)) != 0)
     {
      if(count > 0) label += " + ";
      label += "NEW YORK";
      count++;
     }

   if(count > 1)
      label += " SESSIONS (OVERLAP)";
   else
      label += " SESSION (LIVE)";

   return(label);
  }

//+------------------------------------------------------------------+
//| Map dominant session + theme to the correct bitmap resource file |
//+------------------------------------------------------------------+
string GetBitmapFileForSession(int dominant_session)
  {
   bool dark = InpUseDarkTheme;
   string file;

   switch(dominant_session)
     {
      case SESSION_SYDNEY:
         file = dark ? "::Images\\world_sydney_dark.bmp"
                     : "::Images\\world_sydney.bmp";
         break;

      case SESSION_TOKYO:
         file = dark ? "::Images\\world_tokyo_dark.bmp"
                     : "::Images\\world_tokyo.bmp";
         break;

      case SESSION_LONDON:
         file = dark ? "::Images\\world_london_dark.bmp"
                     : "::Images\\world_london.bmp";
         break;

      case SESSION_NEWYORK:
         file = dark ? "::Images\\world_newyork_dark.bmp"
                     : "::Images\\world_newyork.bmp";
         break;

      case SESSION_NONE:
      default:
         file = dark ? "::Images\\world_idle_dark.bmp"
                     : "::Images\\world_idle.bmp";
         break;
     }

   return(file);
  }

//+------------------------------------------------------------------+
//| Create background bitmap label if missing                        |
//+------------------------------------------------------------------+
void EnsureBackgroundObject()
  {
   // Make sure chart is NOT in foreground mode so BACK objects sit behind candles
   ChartSetInteger(0,CHART_FOREGROUND,false);

   if(ObjectFind(0,g_bg_name) < 0)
     {
      if(!ObjectCreate(0,g_bg_name,OBJ_BITMAP_LABEL,0,0,0))
        {
         Print(__FUNCTION__,": failed to create bitmap label, error=",GetLastError());
         return;
        }

      ObjectSetInteger(0,g_bg_name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,g_bg_name,OBJPROP_BACK,true);   // draw behind candles
     }
  }

//+------------------------------------------------------------------+
//| Center the bitmap in the chart, using its original size          |
//| - No scaling; symmetric cropping when chart is smaller           |
//+------------------------------------------------------------------+
void CenterBackgroundToChart(const string file)
  {
   if(ObjectFind(0,g_bg_name) < 0)
      return;

   // Chart size in pixels
   int chartW = (int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   if(chartW <= 0 || chartH <= 0)
      return;

   // Read image size from resource
   uint imgW = 0, imgH = 0;
   uint data[];

   if(!ResourceReadImage(file,data,imgW,imgH))
     {
      // Fallback: put object at (0,0) and stretch object to chart
      ObjectSetInteger(0,g_bg_name,OBJPROP_XDISTANCE,0);
      ObjectSetInteger(0,g_bg_name,OBJPROP_YDISTANCE,0);
      ObjectSetInteger(0,g_bg_name,OBJPROP_XSIZE,chartW);
      ObjectSetInteger(0,g_bg_name,OBJPROP_YSIZE,chartH);
      return;
     }

   if(imgW == 0 || imgH == 0)
      return;

   int imgWi = (int)imgW;
   int imgHi = (int)imgH;

   // Object size = image size (no scaling)
   ObjectSetInteger(0,g_bg_name,OBJPROP_XSIZE,imgWi);
   ObjectSetInteger(0,g_bg_name,OBJPROP_YSIZE,imgHi);

   // Compute offset so that image center aligns with chart center
   int xOffset = (chartW - imgWi) / 2;
   int yOffset = (chartH - imgHi) / 2;

   // Negative offsets are allowed (chart will crop symmetrically)
   ObjectSetInteger(0,g_bg_name,OBJPROP_XDISTANCE,xOffset);
   ObjectSetInteger(0,g_bg_name,OBJPROP_YDISTANCE,yOffset);
  }

//+------------------------------------------------------------------+
//| Create or update the text label over the map                     |
//+------------------------------------------------------------------+
void EnsureTextObject(const string text)
  {
   if(ObjectFind(0,g_text_name) < 0)
     {
      if(!ObjectCreate(0,g_text_name,OBJ_LABEL,0,0,0))
        {
         Print(__FUNCTION__,": failed to create label, error=",GetLastError());
         return;
        }

      ObjectSetInteger(0,g_text_name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,g_text_name,OBJPROP_XDISTANCE,20);
      ObjectSetInteger(0,g_text_name,OBJPROP_YDISTANCE,20);
      ObjectSetInteger(0,g_text_name,OBJPROP_BACK,false);   // on top of candles
      ObjectSetInteger(0,g_text_name,OBJPROP_FONTSIZE,16);
      ObjectSetString (0,g_text_name,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,g_text_name,OBJPROP_COLOR,clrWhite);
     }

   ObjectSetString(0,g_text_name,OBJPROP_TEXT,text);
  }

//+------------------------------------------------------------------+
//| Notify terminal / mobile when session mask changes               |
//+------------------------------------------------------------------+
void NotifySessionChange(int old_mask,int new_mask)
  {
   if(InpNotifyMode == NOTIFY_OFF)
      return;

   int active = CountActiveSessions(new_mask);

   if(InpNotifyMode == NOTIFY_OVERLAPS_ONLY && active < 2)
      return;   // ignore non-overlap changes

   string label = BuildSessionLabel(new_mask);
   string tf    = EnumToString((ENUM_TIMEFRAMES)_Period);

   string msg = "WorldSessionSlides: " + label +
                " on " + _Symbol + " [" + tf + "]";

   if(InpTerminalAlerts)
      Alert(msg);

   if(InpPushNotifications)
     {
      if(!SendNotification(msg))
         Print(__FUNCTION__,": SendNotification failed, error=",GetLastError());
     }
  }

//+------------------------------------------------------------------+
//| Assign the correct bitmap + label for the current mask           |
//+------------------------------------------------------------------+
void ShowSessionSlideByMask(int session_mask)
  {
   EnsureBackgroundObject();

   int    dominant = DominantSessionFromMask(session_mask);
   string file     = GetBitmapFileForSession(dominant);
   string label    = BuildSessionLabel(session_mask);

   g_last_bitmap_file = file;   // remember which slide we are on

   // Set image from resource (modifier 0 = default state)
   if(!ObjectSetString(0,g_bg_name,OBJPROP_BMPFILE,0,file))
     {
      Print(__FUNCTION__,": failed to set bitmap resource '",file,
            "' for object '",g_bg_name,"', error=",GetLastError());
     }

   // Center the image on the chart using its real size
   CenterBackgroundToChart(file);

   EnsureTextObject(label);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Expert initialization                                             |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_chart_id = ChartID();

   // initial session mask & slide
   g_current_session_mask = GetSessionMaskFromTime(TimeCurrent());
   ShowSessionSlideByMask(g_current_session_mask);

   // --- Configure session markers (minimal, uncluttered) ---
   if(InpShowSessionMarkers)
   {
      g_sess_vis.SetGMTOffset(InpMarkersGMTOffset);
      g_sess_vis.SetShowWicks(false);       // no wicks, keep it clean
      g_sess_vis.SetMarkersOnly(true);      // markers-only mode
      g_sess_vis.RefreshSessions(1);        // only today (+ live window)
   }

   // start timer using runtime copy (input is read-only)
   g_check_period = (InpCheckPeriod < 5 ? 5 : InpCheckPeriod); // clamp minimum
   EventSetTimer(g_check_period);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectDelete(0,g_bg_name);
   ObjectDelete(0,g_text_name);

   if(InpShowSessionMarkers)
      g_sess_vis.ClearAll();
  }

//+------------------------------------------------------------------+
//| Timer: check session changes (including overlaps)                |
//+------------------------------------------------------------------+
void OnTimer()
  {
   int mask_now = GetSessionMaskFromTime(TimeCurrent());
   if(mask_now != g_current_session_mask)
     {
      int old_mask            = g_current_session_mask;
      g_current_session_mask  = mask_now;
      ShowSessionSlideByMask(g_current_session_mask);
      NotifySessionChange(old_mask, g_current_session_mask);
     }

   if(InpShowSessionMarkers)
      g_sess_vis.RefreshSessions(1);
  }

//+------------------------------------------------------------------+
//| Handle chart resize / scaling: recenter current slide            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      EnsureBackgroundObject();
      if(g_last_bitmap_file != "")
         CenterBackgroundToChart(g_last_bitmap_file);
     }
  }
//+------------------------------------------------------------------+
