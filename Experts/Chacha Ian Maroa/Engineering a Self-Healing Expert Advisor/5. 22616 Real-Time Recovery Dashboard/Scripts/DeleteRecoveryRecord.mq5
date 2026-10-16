//+------------------------------------------------------------------+
//|                                      DeleteRecoveryRecord.mq5    |
//|            Copyright 2026, MetaQuotes Ltd. Developer: Chacha Ian |
//|                          https://www.mql5.com/en/users/chachaian |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd. Developer is Chacha Ian"
#property link      "https://www.mql5.com/en/users/chachaian"
#property version   "1.00"
#property script_show_inputs

//+------------------------------------------------------------------+
//| Database configuration                                           |
//+------------------------------------------------------------------+
#define DATABASE_FILE_NAME "self_healing_trade_manager.sqlite"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- open the existing SQLite database file
   int database = DatabaseOpen(DATABASE_FILE_NAME,
                               DATABASE_OPEN_READWRITE);

   if(database == INVALID_HANDLE)
     {
      PrintFormat("Failed to open recovery database. Error: %d", GetLastError());
      return;
     }

//--- delete all active recovery records
   string query = "DELETE FROM trade_states WHERE state='ACTIVE';";

   if(!DatabaseExecute(database, query))
     {
      PrintFormat("Failed to delete active recovery records. Error: %d", GetLastError());
      DatabaseClose(database);
      return;
     }
     
//--- close SQLite database connection
   DatabaseClose(database);

   Print("All ACTIVE recovery records have been deleted successfully.");
  }
//+------------------------------------------------------------------+