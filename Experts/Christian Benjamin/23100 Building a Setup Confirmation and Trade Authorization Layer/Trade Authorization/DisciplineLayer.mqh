//+------------------------------------------------------------------+
//|                                                  DisciplineLayer.mqh |
//|                              Copyright 2026, Christian Benjamin. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Christian Benjamin."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "2.00"

//--- Setup state enumeration
enum ENUM_SETUP_STATE
  {
   NO_SETUP = 0,          // No valid setup exists
   SETUP_FORMING,         // Conditions are developing
   SETUP_CONFIRMED,       // Setup fully validated
   SETUP_ACTIVE,          // Trade window open
   SETUP_EXPIRED          // Setup no longer valid
  };

//--- Trade denial reasons
enum ENUM_DISCIPLINE_REASON
  {
   DISC_OK = 0,
   DISC_GLOBAL_LOCK,
   DISC_SETUP_NOT_CONFIRMED,
   DISC_SETUP_EXPIRED,
   DISC_SIGNAL_STALE,
   DISC_SESSION_BLOCKED
  };

//+------------------------------------------------------------------+
//| CDisciplineLayer: Trade authorization layer                      |
//+------------------------------------------------------------------+
class CDisciplineLayer
  {
private:
   ENUM_SETUP_STATE       m_state;
   ENUM_DISCIPLINE_REASON m_lastReason;
   datetime               m_setupDetectedTime;
   datetime               m_setupConfirmedTime;
   datetime               m_setupExpiryTime;

   //--- Session filter
   bool                   m_sessionFilterEnabled;
   int                    m_sessionStartHour;
   int                    m_sessionStartMinute;
   int                    m_sessionEndHour;
   int                    m_sessionEndMinute;

   //--- Signal freshness
   int                    m_signalFreshnessMinutes;

   //--- Global lock
   string                 m_globalLockName;

   bool                   IsSetupConfirmed() const;
   bool                   IsTradeWindowValid() const;
   bool                   IsSessionAllowed() const;
   bool                   IsSignalFresh() const;

public:
                        CDisciplineLayer();
   bool                 Initialize();
   void                 SetSetupState(ENUM_SETUP_STATE state);
   void                 ConfirmSetup(datetime expiryTime);
   void                 ExpireSetup();
   bool                 CanTrade();

   void                 EnableSessionFilter(int startHour, int startMin, int endHour, int endMin);
   void                 DisableSessionFilter()                { m_sessionFilterEnabled = false; }
   void                 SetSignalFreshnessMinutes(int minutes) { m_signalFreshnessMinutes = minutes; }
   void                 SetGlobalLockName(string name)        { m_globalLockName = name; }

   //--- Reason getters
   ENUM_DISCIPLINE_REASON GetLastReason() const               { return m_lastReason; }
   string                 GetLastReasonText() const;

   //--- Getters for dashboard
   ENUM_SETUP_STATE     GetState()                      const { return m_state; }
   datetime             GetExpiryTime()                const { return m_setupExpiryTime; }
   datetime             GetSetupConfirmedTime()        const { return m_setupConfirmedTime; }
   bool                 IsSessionFilterEnabled()       const { return m_sessionFilterEnabled; }
   void                 GetSessionTimes(int &sh, int &sm, int &eh, int &em) const;
   int                  GetSignalFreshnessMinutes()    const { return m_signalFreshnessMinutes; }
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDisciplineLayer::CDisciplineLayer()
  {
   m_state = NO_SETUP;
   m_lastReason = DISC_OK;
   m_setupDetectedTime = 0;
   m_setupConfirmedTime = 0;
   m_setupExpiryTime = 0;

   m_sessionFilterEnabled = false;
   m_sessionStartHour = 0;
   m_sessionStartMinute = 0;
   m_sessionEndHour = 23;
   m_sessionEndMinute = 59;

   m_signalFreshnessMinutes = 0;
   m_globalLockName = "DISC_GLOBAL_LOCK";
  }

//+------------------------------------------------------------------+
//| Initializes runtime variables                                    |
//+------------------------------------------------------------------+
bool CDisciplineLayer::Initialize()
  {
   m_state = NO_SETUP;
   m_lastReason = DISC_OK;
   m_setupDetectedTime = 0;
   m_setupConfirmedTime = 0;
   m_setupExpiryTime = 0;
   return true;
  }

//+------------------------------------------------------------------+
//| Enables session filter with given start and end times            |
//+------------------------------------------------------------------+
void CDisciplineLayer::EnableSessionFilter(int startHour, int startMin, int endHour, int endMin)
  {
   m_sessionFilterEnabled = true;
   m_sessionStartHour = startHour;
   m_sessionStartMinute = startMin;
   m_sessionEndHour = endHour;
   m_sessionEndMinute = endMin;
  }

//+------------------------------------------------------------------+
//| Returns session start/end times                                  |
//+------------------------------------------------------------------+
void CDisciplineLayer::GetSessionTimes(int &sh, int &sm, int &eh, int &em) const
  {
   sh = m_sessionStartHour;
   sm = m_sessionStartMinute;
   eh = m_sessionEndHour;
   em = m_sessionEndMinute;
  }

//+------------------------------------------------------------------+
//| Returns a readable denial reason                                 |
//+------------------------------------------------------------------+
string CDisciplineLayer::GetLastReasonText() const
  {
   switch(m_lastReason)
     {
      case DISC_OK:
         return "Authorized";

      case DISC_GLOBAL_LOCK:
         return "Global lock active";

      case DISC_SETUP_NOT_CONFIRMED:
         return "Setup not confirmed";

      case DISC_SETUP_EXPIRED:
         return "Setup expired";

      case DISC_SIGNAL_STALE:
         return "Signal freshness exceeded";

      case DISC_SESSION_BLOCKED:
         return "Outside permitted trading session";

      default:
         return "Unknown";
     }
  }

//+------------------------------------------------------------------+
//| Checks if current time is inside the allowed session             |
//+------------------------------------------------------------------+
bool CDisciplineLayer::IsSessionAllowed() const
  {
   if(!m_sessionFilterEnabled)
      return true;

   MqlDateTime tm;
   TimeCurrent(tm);

   int cur   = tm.hour * 60 + tm.min;
   int start = m_sessionStartHour * 60 + m_sessionStartMinute;
   int end   = m_sessionEndHour * 60 + m_sessionEndMinute;

   if(start <= end)
      return (cur >= start && cur <= end);

   return (cur >= start || cur <= end);
  }

//+------------------------------------------------------------------+
//| Checks if the confirmed setup is still "fresh"                   |
//+------------------------------------------------------------------+
bool CDisciplineLayer::IsSignalFresh() const
  {
   if(m_signalFreshnessMinutes <= 0 || m_setupConfirmedTime == 0)
      return true;

   return (TimeCurrent() - m_setupConfirmedTime) <= m_signalFreshnessMinutes * 60;
  }

//+------------------------------------------------------------------+
//| Returns true if the setup is in CONFIRMED or ACTIVE state        |
//+------------------------------------------------------------------+
bool CDisciplineLayer::IsSetupConfirmed() const
  {
   return (m_state == SETUP_CONFIRMED || m_state == SETUP_ACTIVE);
  }

//+------------------------------------------------------------------+
//| Checks that the expiry time has not passed                       |
//+------------------------------------------------------------------+
bool CDisciplineLayer::IsTradeWindowValid() const
  {
   if(m_setupExpiryTime == 0)
      return true;

   return TimeCurrent() <= m_setupExpiryTime;
  }

//+------------------------------------------------------------------+
//| Master authorisation function                                    |
//+------------------------------------------------------------------+
bool CDisciplineLayer::CanTrade()
  {
   m_lastReason = DISC_OK;

   //--- Global lock check
   if(GlobalVariableGet(m_globalLockName) > 0.5)
     {
      m_lastReason = DISC_GLOBAL_LOCK;
      return false;
     }

   //--- Setup must be confirmed
   if(!IsSetupConfirmed())
     {
      m_lastReason = DISC_SETUP_NOT_CONFIRMED;
      return false;
     }

   //--- Expiry window
   if(!IsTradeWindowValid())
     {
      if(m_state != SETUP_EXPIRED)
         ExpireSetup();

      m_lastReason = DISC_SETUP_EXPIRED;
      return false;
     }

   //--- Signal freshness
   if(!IsSignalFresh())
     {
      m_lastReason = DISC_SIGNAL_STALE;
      return false;
     }

   //--- Session filter
   if(!IsSessionAllowed())
     {
      m_lastReason = DISC_SESSION_BLOCKED;
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Manually sets the state                                          |
//+------------------------------------------------------------------+
void CDisciplineLayer::SetSetupState(ENUM_SETUP_STATE state)
  {
   m_state = state;

   if(state == NO_SETUP || state == SETUP_EXPIRED)
     {
      m_setupConfirmedTime = 0;
      m_setupExpiryTime = 0;
     }
   else if(state == SETUP_FORMING && m_setupDetectedTime == 0)
      m_setupDetectedTime = TimeCurrent();
  }

//+------------------------------------------------------------------+
//| Called by strategy when a valid setup is confirmed               |
//+------------------------------------------------------------------+
void CDisciplineLayer::ConfirmSetup(datetime expiryTime)
  {
   m_setupConfirmedTime = TimeCurrent();
   m_setupExpiryTime = expiryTime;
   m_state = SETUP_CONFIRMED;
   m_lastReason = DISC_OK;
  }

//+------------------------------------------------------------------+
//| Expires the current setup                                        |
//+------------------------------------------------------------------+
void CDisciplineLayer::ExpireSetup()
  {
   m_state = SETUP_EXPIRED;
   m_setupExpiryTime = 0;
  }
//+------------------------------------------------------------------+