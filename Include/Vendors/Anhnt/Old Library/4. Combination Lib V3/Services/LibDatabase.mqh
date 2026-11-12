//+------------------------------------------------------------------+
//|                                                   LibDatabase.mqh |
//| The database of the library: one SQLite file for what the EA and |
//| Python share (EA LibV3\SQLite\EA LibV3_Common.sqlite3). The      |
//| tables follow the classes of the library (accounts =             |
//| CAccountsCollection, ...). What Python calculates from the bars  |
//| of an account is kept in its own file in the same folder,        |
//| <server>_<login>.sqlite3 (the key of the account)                |
//| What the terminal already has is not saved: the EA asks the      |
//| terminal by the key. Python makes the tables and writes them     |
//| when it starts (libdb.py); after that the EA writes when an      |
//| event happens and asks Python to calculate                       |
//+------------------------------------------------------------------+
#ifndef __LIBDATABASE_MQH__
#define __LIBDATABASE_MQH__
 #include "JSONConfig.mqh"   // the key of the account, the same one as the configuration and the trade database
 #define LIB_DATABASE_FILE      "EA LibV3\\SQLite\\EA LibV3_Common.sqlite3"
#endif // __LIBDATABASE_MQH__
