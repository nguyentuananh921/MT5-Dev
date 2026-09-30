//+------------------------------------------------------------------+
//|                                              DisciplinePanel.mqh |
//|                              Copyright 2026, Christian Benjamin. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Christian Benjamin."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "2.0"

#include "DisciplineLayer.mqh"
#include "DisciplineGuardian.mqh"

//+------------------------------------------------------------------+
//| Discipline dashboard                                             |
//+------------------------------------------------------------------+
class CDisciplinePanel
  {
private:
   string               m_prefix;
   int                  m_cornerX;
   int                  m_cornerY;
   int                  m_width;
   int                  m_lineHeight;
   int                  m_fontSize;
   string               m_fontName;
   color                m_bgColor;
   color                m_textColor;
   bool                 m_visible;
   int                  m_lines;

   //--- Creates the panel background
   void                 CreateBackground();

   //--- Creates or updates a label
   void                 CreateLabel(string name,
                                    string text,
                                    int line,
                                    color clr,
                                    bool bold = true);

   //--- Deletes all panel objects
   void                 DeletePanel();

public:
   //--- Constructor
                     CDisciplinePanel();

   //--- Destructor
                    ~CDisciplinePanel();

   //--- Initializes panel settings
   void                 Init(string prefix,
                             int cornerX,
                             int cornerY,
                             int width,
                             color bg,
                             color txt);

   //--- Shows the panel
   void                 Show();

   //--- Hides the panel
   void                 Hide();

   //--- Updates the panel display
   void                 Update(CDisciplineLayer &discipline,
                               ENUM_VIOLATION_MODE mode);
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDisciplinePanel::CDisciplinePanel()
  {
   m_prefix     = "DispPanel_";
   m_cornerX    = 10;
   m_cornerY    = 30;
   m_width      = 380;
   m_lineHeight = 24;
   m_fontSize   = 13;
   m_fontName   = "Arial Bold";
   m_bgColor    = clrDarkSlateGray;
   m_textColor  = clrWhite;
   m_visible    = true;
   m_lines      = 0;
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CDisciplinePanel::~CDisciplinePanel()
  {
   DeletePanel();
  }

//+------------------------------------------------------------------+
//| Initializes panel settings                                       |
//+------------------------------------------------------------------+
void CDisciplinePanel::Init(string prefix,
                            int cornerX,
                            int cornerY,
                            int width,
                            color bg,
                            color txt)
  {
   m_prefix    = prefix;
   m_cornerX   = cornerX;
   m_cornerY   = cornerY;
   m_width     = width;
   m_bgColor   = bg;
   m_textColor  = txt;
   m_visible   = true;
  }

//+------------------------------------------------------------------+
//| Shows the panel                                                  |
//+------------------------------------------------------------------+
void CDisciplinePanel::Show()
  {
   m_visible = true;
  }

//+------------------------------------------------------------------+
//| Hides the panel                                                  |
//+------------------------------------------------------------------+
void CDisciplinePanel::Hide()
  {
   m_visible = false;
   DeletePanel();
  }

//+------------------------------------------------------------------+
//| Creates the panel background                                     |
//+------------------------------------------------------------------+
void CDisciplinePanel::CreateBackground()
  {
   string objName = m_prefix + "bg";

   if(ObjectFind(0, objName) < 0)
     {
      ObjectCreate(0, objName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, m_cornerX);
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, m_cornerY);
      ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, m_bgColor);
      ObjectSetInteger(0, objName, OBJPROP_BORDER_TYPE, BORDER_RAISED);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, clrSilver);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, objName, OBJPROP_BACK, false);
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1000);
     }

   ObjectSetInteger(0, objName, OBJPROP_XSIZE, m_width);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, (m_lines + 2) * m_lineHeight);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1000);
  }

//+------------------------------------------------------------------+
//| Creates or updates a label                                       |
//+------------------------------------------------------------------+
void CDisciplinePanel::CreateLabel(string name,
                                   string text,
                                   int line,
                                   color clr,
                                   bool bold)
  {
   string objName = m_prefix + name;

   if(ObjectFind(0, objName) < 0)
     {
      ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, m_cornerX + 8);
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, m_cornerY + 4 + line * m_lineHeight);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, m_fontSize);
      ObjectSetString(0, objName, OBJPROP_FONT, bold ? m_fontName : "Arial");
      ObjectSetInteger(0, objName, OBJPROP_BACK, false);
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1001);
     }

   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1001);
  }

//+------------------------------------------------------------------+
//| Deletes all panel objects                                        |
//+------------------------------------------------------------------+
void CDisciplinePanel::DeletePanel()
  {
   for(int i = ObjectsTotal(0) - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, m_prefix) == 0)
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//| Updates the panel display                                        |
//+------------------------------------------------------------------+
void CDisciplinePanel::Update(CDisciplineLayer &discipline,
                              ENUM_VIOLATION_MODE mode)
  {
   if(!m_visible)
      return;

   DeletePanel();

   int lineCount = 0;
   lineCount++; 
   lineCount++; 
   lineCount++; 
   lineCount++; 

   if(discipline.GetSignalFreshnessMinutes() > 0 &&
      discipline.GetSetupConfirmedTime() > 0)
      lineCount++;

   if(discipline.IsSessionFilterEnabled())
      lineCount++;

   lineCount++; 

   m_lines = lineCount + 2;
   CreateBackground();

   int line = 0;

   CreateLabel("header", "DISCIPLINE DASHBOARD", line++, clrWhite, true);
   line++;

   ENUM_SETUP_STATE state = discipline.GetState();
   string stateStr = "";
   color stateColor = clrGray;

   switch(state)
     {
      case NO_SETUP:
         stateStr  = "[ ] NO SETUP";
         stateColor = clrGray;
         break;

      case SETUP_FORMING:
         stateStr  = "[~] FORMING";
         stateColor = clrYellow;
         break;

      case SETUP_CONFIRMED:
         stateStr  = "[+] CONFIRMED";
         stateColor = clrLimeGreen;
         break;

      case SETUP_ACTIVE:
         stateStr  = "[+] ACTIVE";
         stateColor = clrLimeGreen;
         break;

      case SETUP_EXPIRED:
         stateStr  = "[X] EXPIRED";
         stateColor = clrCrimson;
         break;

      default:
         stateStr  = "[?] UNKNOWN";
         stateColor = clrGray;
         break;
     }

   CreateLabel("state", "State: " + stateStr, line++, stateColor, true);

   bool canTrade = discipline.CanTrade();
   string tradeAllowed = canTrade ? "[ALLOWED]" : "[DENIED]";
   color tradeColor = canTrade ? clrLimeGreen : clrCrimson;
   CreateLabel("canTrade", "Trade Auth: " + tradeAllowed, line++, tradeColor, true);

   datetime expiry = discipline.GetExpiryTime();
   if(expiry > 0)
     {
      int remaining = (int)(expiry - TimeCurrent());
      string expiryStr = (remaining > 0)
                         ? TimeToString(expiry, TIME_MINUTES) + " (" + IntegerToString(remaining) + " sec)"
                         : "EXPIRED";
      CreateLabel("expiry", "Setup Expiry: " + expiryStr, line++, clrWhite, false);
     }
   else
      CreateLabel("expiry", "Setup Expiry: none", line++, clrWhite, false);

   int freshness = discipline.GetSignalFreshnessMinutes();
   if(freshness > 0 && discipline.GetSetupConfirmedTime() > 0)
     {
      int secondsOld = (int)(TimeCurrent() - discipline.GetSetupConfirmedTime());
      int remaining = freshness * 60 - secondsOld;
      string freshStr = (remaining > 0)
                        ? StringFormat("Signal fresh: %d sec", remaining)
                        : "Signal stale";
      CreateLabel("fresh", freshStr, line++, (remaining > 0) ? clrLightGreen : clrTomato, false);
     }

   if(discipline.IsSessionFilterEnabled())
     {
      int sh, sm, eh, em;
      discipline.GetSessionTimes(sh, sm, eh, em);

      MqlDateTime tm;
      TimeCurrent(tm);

      int cur = tm.hour * 60 + tm.min;
      int start = sh * 60 + sm;
      int end = eh * 60 + em;
      bool inSession = (start <= end) ? (cur >= start && cur <= end) : (cur >= start || cur <= end);

      string sessionStr = StringFormat("Session: %02d:%02d - %02d:%02d   %s",
                                       sh, sm, eh, em,
                                       inSession ? "ACTIVE" : "inactive");
      CreateLabel("session", sessionStr, line++, inSession ? clrLimeGreen : clrWhite, false);
     }

   string modeStr = "";
   switch(mode)
     {
      case MODE_ALERT_ONLY:
         modeStr = "ALERT ONLY";
         break;

      case MODE_AUTO_CLOSE:
         modeStr = "AUTO CLOSE";
         break;

      case MODE_AUTO_CLOSE_LOCK:
         modeStr = "AUTO CLOSE + LOCK";
         break;

      default:
         modeStr = "UNKNOWN";
         break;
     }

   CreateLabel("violation", "Guardian: " + modeStr, line++, clrCyan, true);

   m_lines = line;
   CreateBackground();
   ChartRedraw();
  }
//+------------------------------------------------------------------+
