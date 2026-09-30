//+------------------------------------------------------------------+
//|                                               DisciplineGuardian.mqh |
//|                              Copyright 2026, Christian Benjamin. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Christian Benjamin."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Violation handling modes                                         |
//+------------------------------------------------------------------+
enum ENUM_VIOLATION_MODE
  {
   MODE_ALERT_ONLY,
   MODE_AUTO_CLOSE,
   MODE_AUTO_CLOSE_LOCK
  };

//+------------------------------------------------------------------+
//| CDisciplineGuardian: Discipline enforcement engine               |
//+------------------------------------------------------------------+
class CDisciplineGuardian
  {
private:
   string               m_globalLockPrefix;
   ENUM_VIOLATION_MODE  m_violationMode;
   bool                 m_enabled;

   void                 ClosePosition(ulong ticket);
   void                 DeleteOrder(ulong ticket);
   void                 ActivateGlobalLock();

public:
                     CDisciplineGuardian();

   void                 SetGlobalLockPrefix(string prefix)
     { m_globalLockPrefix = prefix; }

   void                 SetViolationMode(ENUM_VIOLATION_MODE mode)
     { m_violationMode = mode; }

   void                 Enable()
     { m_enabled = true; }

   void                 Disable()
     { m_enabled = false; }

   void                 Enforce(bool isTradingAllowed);
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDisciplineGuardian::CDisciplineGuardian()
  {
   m_globalLockPrefix = "DISC_";
   m_violationMode = MODE_AUTO_CLOSE;
   m_enabled = true;
  }

//+------------------------------------------------------------------+
//| Closes an unauthorised position                                  |
//+------------------------------------------------------------------+
void CDisciplineGuardian::ClosePosition(ulong ticket)
  {
   if(!PositionSelectByTicket(ticket))
      return;

   MqlTradeRequest req = {};
   MqlTradeResult  res = {};

   req.action    = TRADE_ACTION_DEAL;
   req.symbol    = PositionGetString(POSITION_SYMBOL);
   req.volume    = PositionGetDouble(POSITION_VOLUME);
   req.type      = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                   ? ORDER_TYPE_SELL
                   : ORDER_TYPE_BUY;
   req.position  = ticket;
   req.deviation = 10;
   req.magic     = 0;

   if(OrderSend(req,res))
      Print("[GUARDIAN] Closed unauthorised position #",ticket);
   else
      Print("[GUARDIAN] Failed to close position #",
            ticket,
            " error ",
            GetLastError());
  }

//+------------------------------------------------------------------+
//| Deletes an unauthorised pending order                            |
//+------------------------------------------------------------------+
void CDisciplineGuardian::DeleteOrder(ulong ticket)
  {
   if(!OrderSelect(ticket))
      return;

   MqlTradeRequest req = {};
   MqlTradeResult  res = {};

   req.action = TRADE_ACTION_REMOVE;
   req.order  = ticket;

   if(OrderSend(req,res))
      Print("[GUARDIAN] Deleted unauthorised pending order #",ticket);
   else
      Print("[GUARDIAN] Failed to delete order #",
            ticket,
            " error ",
            GetLastError());
  }

//+------------------------------------------------------------------+
//| Activates the global trading lock                                |
//+------------------------------------------------------------------+
void CDisciplineGuardian::ActivateGlobalLock()
  {
   string lockName = m_globalLockPrefix + "GLOBAL_LOCK";

   GlobalVariableSet(lockName,1.0);

   Print("[GUARDIAN] Trading lock activated (",
         lockName,
         " = 1). Manual removal required.");
  }

//+------------------------------------------------------------------+
//| Enforces discipline rules on positions and orders                |
//+------------------------------------------------------------------+
void CDisciplineGuardian::Enforce(bool isTradingAllowed)
  {
   if(!m_enabled)
      return;

   if(isTradingAllowed)
      return;

//--- Process open positions
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      switch(m_violationMode)
        {
         case MODE_ALERT_ONLY:
            Print("[GUARDIAN] Alert: Position #",
                  ticket,
                  " not allowed");
            break;

         case MODE_AUTO_CLOSE:
            ClosePosition(ticket);
            break;

         case MODE_AUTO_CLOSE_LOCK:
            ClosePosition(ticket);
            ActivateGlobalLock();
            break;
        }
     }

//--- Process pending orders
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);

      if(ticket == 0)
         continue;

      switch(m_violationMode)
        {
         case MODE_ALERT_ONLY:
            Print("[GUARDIAN] Alert: Pending order #",
                  ticket,
                  " not allowed");
            break;

         case MODE_AUTO_CLOSE:
            DeleteOrder(ticket);
            break;

         case MODE_AUTO_CLOSE_LOCK:
            DeleteOrder(ticket);
            ActivateGlobalLock();
            break;
        }
     }
  }
//+------------------------------------------------------------------+