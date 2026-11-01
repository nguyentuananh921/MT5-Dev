//+------------------------------------------------------------------+
//|                                            TradeAuditJournal.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Christian Benjamin."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.00"

#ifndef TRADE_AUDIT_JOURNAL_MQH
#define TRADE_AUDIT_JOURNAL_MQH
#include <Trade Audit/TradeAuditTypes.mqh>
//--- Free text is escaped so every record occupies one physical CSV line.

//+------------------------------------------------------------------+
//| Escapes reserved characters in journal text                      |
//+------------------------------------------------------------------+
string AuditEncode(string value)
  {
//--- Normalize both NULL and empty optional fields before replacement
   if(StringLen(value) == 0)
      return("");

   StringReplace(value, "%", "%25");
   StringReplace(value, ";", "%3B");
   StringReplace(value, "\"", "%22");
   StringReplace(value, "\r", "%0D");
   StringReplace(value, "\n", "%0A");
   return(value);
  }

//+------------------------------------------------------------------+
//| Restores escaped journal text                                    |
//+------------------------------------------------------------------+
string AuditDecode(string value)
  {
//--- Normalize both NULL and empty optional fields before replacement
   if(StringLen(value) == 0)
      return("");

   StringReplace(value, "%0A", "\n");
   StringReplace(value, "%0D", "\r");
   StringReplace(value, "%3B", ";");
   StringReplace(value, "%22", "\"");
   StringReplace(value, "%25", "%");
   return(value);
  }

//--- Validate syntax before the conversion functions can turn errors into zero.

//+------------------------------------------------------------------+
//| Validates numeric text before conversion                         |
//+------------------------------------------------------------------+
bool AuditNumber(string value, bool integerOnly = false)
  {
   int n = StringLen(value), i = 0, digits = 0;
   if(n == 0)
      return(false);
   ushort c = StringGetCharacter(value, 0);
   if(c == '+' || c == '-')
      i++;
   while(i < n && StringGetCharacter(value, i) >= '0' && StringGetCharacter(value, i) <= '9')
     {
      i++;
      digits++;
     }
   if(!integerOnly && i < n && StringGetCharacter(value, i) == '.')
     {
      i++;
      while(i < n && StringGetCharacter(value, i) >= '0' && StringGetCharacter(value, i) <= '9')
        {
         i++;
         digits++;
        }
     }
   if(digits == 0)
      return(false);
   if(!integerOnly && i < n && (StringGetCharacter(value, i) == 'e' || StringGetCharacter(value, i) == 'E'))
     {
      i++;
      digits = 0;
      if(i < n && (StringGetCharacter(value, i) == '+' || StringGetCharacter(value, i) == '-'))
         i++;
      while(i < n && StringGetCharacter(value, i) >= '0' && StringGetCharacter(value, i) <= '9')
        {
         i++;
         digits++;
        }
      if(digits == 0)
         return(false);
     }
   return(i == n && MathIsValidNumber(StringToDouble(value)));
  }

//+------------------------------------------------------------------+
//| Initializes journal ownership state                              |
//+------------------------------------------------------------------+
class CTradeAuditJournal
  {
private:
   string               m_fileName, m_error;
   int                  m_lock;
   long                 m_login;
   string               m_server;
   bool                 ReadFields(int handle, string &values[]);
   bool                 Header(int handle, bool create);
   bool                 ReadRow(int handle, STradeAuditRecord &record);
   bool                 WriteRow(int handle, STradeAuditRecord &record);
   datetime             PeriodStart(int days);
public:

//+------------------------------------------------------------------+
//| Initializes journal ownership state                              |
//+------------------------------------------------------------------+
   CTradeAuditJournal()
     {
      m_lock = INVALID_HANDLE;
     }

//+------------------------------------------------------------------+
//| Releases the journal ownership handle                            |
//+------------------------------------------------------------------+
   ~CTradeAuditJournal()
     {
      if(m_lock != INVALID_HANDLE)
         FileClose(m_lock);
     }

   bool                 Initialize(string fileName);
   bool                 Append(STradeAuditRecord &record);
   bool                 GetSummary(int days,
                                   int &events,
                                   int &violations,
                                   int &liveEvents,
                                   int &recoveredEvents,
                                   STradeAuditRecord &recent[]);
   bool                 ExportPeriod(int days, string &savedAs);
   bool                 RecordedObjects(ulong &orders[], ulong &deals[]);

//+------------------------------------------------------------------+
//| Returns the current journal error                                |
//+------------------------------------------------------------------+
   string Error() const
     {
      return(m_error);
     }

  };

//+------------------------------------------------------------------+
//| Reads one complete journal row                                   |
//+------------------------------------------------------------------+
bool CTradeAuditJournal::ReadFields(int handle, string &values[])
  {
   if(ArrayResize(values, 32) != 32)
     {
      m_error = "Allocation error";
      return(false);
     }
   for(int i = 0; i < 32; i++)
     {
      if(FileIsEnding(handle) || (i > 0 && FileIsLineEnding(handle)))
        {
         m_error = "Incomplete CSV row";
         return(false);
        }
      ResetLastError();
      values[i] = FileReadString(handle);
      if(GetLastError() != 0)
        {
         m_error = "CSV read error";
         return(false);
        }
     }
   if(!FileIsLineEnding(handle) && !FileIsEnding(handle))
     {
      m_error = "Extra CSV columns";
      return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Creates or validates the complete journal header                 |
//+------------------------------------------------------------------+
bool CTradeAuditJournal::Header(int handle, bool create)
  {
   string expected[] =
     {
      "record_time", "event_time", "event_type", "capture_mode", "account_login",
      "server", "symbol", "source", "action", "entry_type", "volume", "price",
      "stop_loss", "take_profit", "magic", "order_ticket", "deal_ticket", "position_id",
      "result_code", "result_message", "profit", "commission", "swap", "note",
      "request_action", "request_id", "position_ticket", "request_order", "requested_volume",
      "requested_price", "requested_sl", "requested_tp"
     };
   if(FileSize(handle) == 0)
     {
      if(!create)
        {
         m_error = "Missing CSV header";
         return(false);
        }
      ResetLastError();
      uint written = FileWrite(handle,
                     "record_time",
                     "event_time",
                     "event_type",
                     "capture_mode",
                     "account_login",
                     "server",
                     "symbol",
                     "source",
                     "action",
                     "entry_type",
                     "volume",
                     "price",
                     "stop_loss",
                     "take_profit",
                     "magic",
                     "order_ticket",
                     "deal_ticket",
                     "position_id",
                     "result_code",
                     "result_message",
                     "profit",
                     "commission",
                     "swap",
                     "note",
                     "request_action",
                     "request_id",
                     "position_ticket",
                     "request_order",
                     "requested_volume",
                     "requested_price",
                     "requested_sl",
                     "requested_tp");
      FileFlush(handle);
      if(written == 0 || GetLastError() != 0)
        {
         m_error = "Header write error";
         return(false);
        }
      return(true);
     }
   if(!FileSeek(handle, 0, SEEK_SET))
     {
      m_error = "CSV seek error";
      return(false);
     }
   string actual[];
   if(!ReadFields(handle, actual))
      return(false);
   for(int i = 0; i < 32; i++)
      if(actual[i] != expected[i])
        {
         m_error = "Incompatible CSV schema";
         return(false);
        }
   return(true);
  }

//+------------------------------------------------------------------+
//| Identifies errors raised while preparing a particular field      |
//+------------------------------------------------------------------+
bool AuditPreparedField(string name, string &error)
  {
   int code = GetLastError();
   if(code != 0)
     {
      error = StringFormat("Row preparation error %d in %s", code, name);
      return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Writes one structured audit record                               |
//+------------------------------------------------------------------+
bool CTradeAuditJournal::WriteRow(int handle, STradeAuditRecord &record)
  {
//--- Prepare each field and retain the exact error location
   string fields[32];

   ResetLastError();
   fields[0] = (string)(TimeToString(record.recordTime, TIME_DATE | TIME_SECONDS));
   if(!AuditPreparedField("record_time", m_error))
      return(false);

   ResetLastError();
   fields[1] = (string)(TimeToString(record.eventTime, TIME_DATE | TIME_SECONDS));
   if(!AuditPreparedField("event_time", m_error))
      return(false);

   ResetLastError();
   fields[2] = (string)(AuditActivityText(record.eventType));
   if(!AuditPreparedField("event_type", m_error))
      return(false);

   ResetLastError();
   fields[3] = (string)(record.captureMode);
   if(!AuditPreparedField("capture_mode", m_error))
      return(false);

   ResetLastError();
   fields[4] = (string)(record.accountLogin);
   if(!AuditPreparedField("account_login", m_error))
      return(false);

   ResetLastError();
   fields[5] = (string)(AuditEncode(record.server));
   if(!AuditPreparedField("server", m_error))
      return(false);

   ResetLastError();
   fields[6] = (string)(AuditEncode(record.symbol));
   if(!AuditPreparedField("symbol", m_error))
      return(false);

   ResetLastError();
   fields[7] = (string)(AuditEncode(record.source));
   if(!AuditPreparedField("source", m_error))
      return(false);

   ResetLastError();
   fields[8] = (string)(AuditEncode(record.action));
   if(!AuditPreparedField("action", m_error))
      return(false);

   ResetLastError();
   fields[9] = (string)(AuditEncode(record.entryType));
   if(!AuditPreparedField("entry_type", m_error))
      return(false);

   ResetLastError();
   fields[10] = (string)(DoubleToString(record.volume, 10));
   if(!AuditPreparedField("volume", m_error))
      return(false);

   ResetLastError();
   fields[11] = (string)(DoubleToString(record.price, 10));
   if(!AuditPreparedField("price", m_error))
      return(false);

   ResetLastError();
   fields[12] = (string)(DoubleToString(record.stopLoss, 10));
   if(!AuditPreparedField("stop_loss", m_error))
      return(false);

   ResetLastError();
   fields[13] = (string)(DoubleToString(record.takeProfit, 10));
   if(!AuditPreparedField("take_profit", m_error))
      return(false);

   ResetLastError();
   fields[14] = (string)(record.magic);
   if(!AuditPreparedField("magic", m_error))
      return(false);

   ResetLastError();
   fields[15] = (string)(record.orderTicket);
   if(!AuditPreparedField("order_ticket", m_error))
      return(false);

   ResetLastError();
   fields[16] = (string)(record.dealTicket);
   if(!AuditPreparedField("deal_ticket", m_error))
      return(false);

   ResetLastError();
   fields[17] = (string)(record.positionId);
   if(!AuditPreparedField("position_id", m_error))
      return(false);

   ResetLastError();
   fields[18] = (string)(record.resultCode);
   if(!AuditPreparedField("result_code", m_error))
      return(false);

   ResetLastError();
   fields[19] = (string)(AuditEncode(record.resultMessage));
   if(!AuditPreparedField("result_message", m_error))
      return(false);

   ResetLastError();
   fields[20] = (string)(DoubleToString(record.profit, 10));
   if(!AuditPreparedField("profit", m_error))
      return(false);

   ResetLastError();
   fields[21] = (string)(DoubleToString(record.commission, 10));
   if(!AuditPreparedField("commission", m_error))
      return(false);

   ResetLastError();
   fields[22] = (string)(DoubleToString(record.swap, 10));
   if(!AuditPreparedField("swap", m_error))
      return(false);

   ResetLastError();
   fields[23] = (string)(AuditEncode(record.note));
   if(!AuditPreparedField("note", m_error))
      return(false);

   ResetLastError();
   fields[24] = (string)(AuditEncode(record.requestAction));
   if(!AuditPreparedField("request_action", m_error))
      return(false);

   ResetLastError();
   fields[25] = (string)(record.requestId);
   if(!AuditPreparedField("request_id", m_error))
      return(false);

   ResetLastError();
   fields[26] = (string)(record.positionTicket);
   if(!AuditPreparedField("position_ticket", m_error))
      return(false);

   ResetLastError();
   fields[27] = (string)(record.requestOrder);
   if(!AuditPreparedField("request_order", m_error))
      return(false);

   ResetLastError();
   fields[28] = (string)(DoubleToString(record.requestedVolume, 10));
   if(!AuditPreparedField("requested_volume", m_error))
      return(false);

   ResetLastError();
   fields[29] = (string)(DoubleToString(record.requestedPrice, 10));
   if(!AuditPreparedField("requested_price", m_error))
      return(false);

   ResetLastError();
   fields[30] = (string)(DoubleToString(record.requestedSL, 10));
   if(!AuditPreparedField("requested_sl", m_error))
      return(false);

   ResetLastError();
   fields[31] = (string)(DoubleToString(record.requestedTP, 10));
   if(!AuditPreparedField("requested_tp", m_error))
      return(false);

//--- Check only errors raised by FileWrite itself
   ResetLastError();
   uint written = FileWrite(handle,
                            fields[0],
                            fields[1],
                            fields[2],
                            fields[3],
                            fields[4],
                            fields[5],
                            fields[6],
                            fields[7],
                            fields[8],
                            fields[9],
                            fields[10],
                            fields[11],
                            fields[12],
                            fields[13],
                            fields[14],
                            fields[15],
                            fields[16],
                            fields[17],
                            fields[18],
                            fields[19],
                            fields[20],
                            fields[21],
                            fields[22],
                            fields[23],
                            fields[24],
                            fields[25],
                            fields[26],
                            fields[27],
                            fields[28],
                            fields[29],
                            fields[30],
                            fields[31]);
   int writeError = GetLastError();
   if(written == 0 || writeError != 0)
     {
      m_error = StringFormat("Row write error %d (bytes %u)",
                             writeError, written);
      return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Validates and converts one journal record                        |
//+------------------------------------------------------------------+
bool CTradeAuditJournal::ReadRow(int handle, STradeAuditRecord &record)
  {
   if(FileIsEnding(handle))
      return(false);
   string v[];
   if(!ReadFields(handle, v))
      return(false);
   ZeroMemory(record);
   record.recordTime = StringToTime(v[0]);
   if(record.recordTime <= 0 || TimeToString(record.recordTime, TIME_DATE | TIME_SECONDS) != v[0])
     {
      m_error = "Invalid timestamp";
      return(false);
     }
   record.eventTime = StringToTime(v[1]);
   if(record.eventTime <= 0 || TimeToString(record.eventTime, TIME_DATE | TIME_SECONDS) != v[1])
     {
      m_error = "Invalid timestamp";
      return(false);
     }
   bool found = false;
   for(int k = 0; k <= (int) AUDIT_POSTTRADE_VIOLATION; k++)
      if(AuditActivityText((ENUM_AUDIT_ACTIVITY) k) == v[2])
        {
         record.eventType = (ENUM_AUDIT_ACTIVITY) k;
         found = true;
         break;
        }
   if(!found)
     {
      m_error = "Unknown event name";
      return(false);
     }
   if(v[3] != "LIVE" && v[3] != "RECOVERED")
     {
      m_error = "Unknown capture mode";
      return(false);
     }
   record.captureMode = v[3];
   if(!AuditNumber(v[4], true))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.accountLogin = StringToInteger(v[4]);
   record.server = AuditDecode(v[5]);
   record.symbol = AuditDecode(v[6]);
   record.source = AuditDecode(v[7]);
   record.action = AuditDecode(v[8]);
   record.entryType = AuditDecode(v[9]);
   if(!AuditNumber(v[10], false))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.volume = StringToDouble(v[10]);
   if(!AuditNumber(v[11], false))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.price = StringToDouble(v[11]);
   if(!AuditNumber(v[12], false))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.stopLoss = StringToDouble(v[12]);
   if(!AuditNumber(v[13], false))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.takeProfit = StringToDouble(v[13]);
   if(!AuditNumber(v[14], true))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.magic = StringToInteger(v[14]);
   if(!AuditNumber(v[15], true))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   if(StringFind(v[15], "-") >= 0)
     {
      m_error = "Negative ticket";
      return(false);
     }
   record.orderTicket = (ulong) StringToInteger(v[15]);
   if(!AuditNumber(v[16], true))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   if(StringFind(v[16], "-") >= 0)
     {
      m_error = "Negative ticket";
      return(false);
     }
   record.dealTicket = (ulong) StringToInteger(v[16]);
   if(!AuditNumber(v[17], true))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   if(StringFind(v[17], "-") >= 0)
     {
      m_error = "Negative ticket";
      return(false);
     }
   record.positionId = (ulong) StringToInteger(v[17]);
   if(!AuditNumber(v[18], true))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.resultCode = StringToInteger(v[18]);
   record.resultMessage = AuditDecode(v[19]);
   if(!AuditNumber(v[20], false))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.profit = StringToDouble(v[20]);
   if(!AuditNumber(v[21], false))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.commission = StringToDouble(v[21]);
   if(!AuditNumber(v[22], false))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.swap = StringToDouble(v[22]);
   record.note = AuditDecode(v[23]);
   record.requestAction = AuditDecode(v[24]);
   if(!AuditNumber(v[25], true))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   if(StringFind(v[25], "-") >= 0)
     {
      m_error = "Negative ticket";
      return(false);
     }
   record.requestId = (ulong) StringToInteger(v[25]);
   if(!AuditNumber(v[26], true))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   if(StringFind(v[26], "-") >= 0)
     {
      m_error = "Negative ticket";
      return(false);
     }
   record.positionTicket = (ulong) StringToInteger(v[26]);
   if(!AuditNumber(v[27], true))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   if(StringFind(v[27], "-") >= 0)
     {
      m_error = "Negative ticket";
      return(false);
     }
   record.requestOrder = (ulong) StringToInteger(v[27]);
   if(!AuditNumber(v[28], false))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.requestedVolume = StringToDouble(v[28]);
   if(!AuditNumber(v[29], false))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.requestedPrice = StringToDouble(v[29]);
   if(!AuditNumber(v[30], false))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.requestedSL = StringToDouble(v[30]);
   if(!AuditNumber(v[31], false))
     {
      m_error = "Invalid numeric field";
      return(false);
     }
   record.requestedTP = StringToDouble(v[31]);
   if(record.accountLogin != m_login || record.server != m_server)
     {
      m_error = "Account identity mismatch";
      return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Initializes account-bound storage and settings                   |
//+------------------------------------------------------------------+
bool CTradeAuditJournal::Initialize(string fileName)
  {
   m_error = "";
   m_fileName = fileName;
   m_login = AccountInfoInteger(ACCOUNT_LOGIN);
   m_server = AccountInfoString(ACCOUNT_SERVER);
   FolderCreate("TradeAudit");
   m_lock = FileOpen(m_fileName + ".lock", FILE_READ | FILE_WRITE | FILE_BIN);
   if(m_lock == INVALID_HANDLE)
     {
      m_error = "Journal already owned or unavailable";
      return(false);
     }
   int h = FileOpen(m_fileName,
                  FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ,
                  ';',
                  CP_UTF8);
   if(h == INVALID_HANDLE)
     {
      m_error = "Journal open error";
      return(false);
     }
   bool ok = Header(h, true);
   STradeAuditRecord row;
   while(ok && !FileIsEnding(h))
      ok = ReadRow(h, row);
   FileClose(h);
   if(ok)
      Print("[AUDIT] Journal build P9-2-J2 active");
   return(ok);
  }

//+------------------------------------------------------------------+
//| Appends and flushes one audit record                             |
//+------------------------------------------------------------------+
bool CTradeAuditJournal::Append(STradeAuditRecord &record)
  {
   if(record.accountLogin != m_login || record.server != m_server)
     {
      m_error = "Account identity mismatch";
      return(false);
     }
   if(m_error != "")
      return(false);

   ResetLastError();
   int h = FileOpen(m_fileName,
                    FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ,
                    ';', CP_UTF8);
   if(h == INVALID_HANDLE)
     {
      m_error = StringFormat("Journal open error %d: %s",
                             GetLastError(), m_fileName);
      return(false);
     }

//--- Preserve the exact failure before closing the handle
   ResetLastError();
   bool ok = FileSeek(h, 0, SEEK_END);
   if(!ok)
      m_error = StringFormat("Journal seek error %d: %s",
                             GetLastError(), m_fileName);
   if(ok)
      ok = WriteRow(h, record);

   ResetLastError();
   FileFlush(h);
   int flushError = GetLastError();
   if(flushError != 0)
     {
      if(ok)
         m_error = StringFormat("Journal flush error %d: %s",
                                flushError, m_fileName);
      ok = false;
     }
   FileClose(h);
   return(ok);
  }

//+------------------------------------------------------------------+
//| Returns the selected period boundary                             |
//+------------------------------------------------------------------+
datetime CTradeAuditJournal::PeriodStart(int days)
  {
   if(days == -1)
     {
      MqlDateTime d;
      TimeCurrent(d);
      d.hour = 0;
      d.min = 0;
      d.sec = 0;
      return(StructToTime(d));
     }
   return(days > 0 ? TimeCurrent() - days * 86400 : 0);
  }

//+------------------------------------------------------------------+
//| Reads period totals and recent activity                          |
//+------------------------------------------------------------------+
bool CTradeAuditJournal::GetSummary(int days,
               int &events,
               int &violations,
               int &liveEvents,
               int &recoveredEvents,
               STradeAuditRecord &recent[])
  {
   events = 0;
   violations = 0;
   liveEvents = 0;
   recoveredEvents = 0;
   ArrayResize(recent, 0);
   if(m_error != "")
      return(false);
   int h = FileOpen(m_fileName, FILE_READ | FILE_CSV | FILE_ANSI | FILE_SHARE_READ, ';', CP_UTF8);
   if(h == INVALID_HANDLE)
     {
      m_error = "Journal read error";
      return(false);
     }
   bool ok = Header(h, false);
   datetime from = PeriodStart(days), now = TimeCurrent();
   STradeAuditRecord row;
   while(ok && !FileIsEnding(h))
     {
      if(!ReadRow(h, row))
        {
         ok = false;
         break;
        }
      if(row.eventTime < from || row.eventTime > now)
         continue;
      events++;
      if(row.eventType == AUDIT_POSTTRADE_VIOLATION)
         violations++;
      if(row.captureMode == "LIVE")
         liveEvents++;
      else
         recoveredEvents++;
      bool visible = (row.eventType == AUDIT_ORDER_ADDED ||
         row.eventType == AUDIT_ORDER_UPDATED ||
         row.eventType == AUDIT_ORDER_REMOVED ||
         row.eventType == AUDIT_DEAL_ADDED ||
         row.eventType == AUDIT_ORDER_RECOVERED ||
         row.eventType == AUDIT_DEAL_RECOVERED ||
         row.eventType == AUDIT_POSTTRADE_VIOLATION);
      if(!visible)
         continue;
      int size = ArraySize(recent), pos = 0;
      while(pos < size && recent[pos].eventTime > row.eventTime)
         pos++;
      if(pos >= 3)
         continue;
      if(size < 3 && ArrayResize(recent, size + 1) != size + 1)
        {
         m_error = "Allocation error";
         ok = false;
         break;
        }
      for(int j = ArraySize(recent) - 1; j > pos; j--)
         recent[j] = recent[j - 1];
      recent[pos] = row;
     }
   FileClose(h);
   if(!ok)
     {
      events = 0;
      violations = 0;
      liveEvents = 0;
      recoveredEvents = 0;
      ArrayResize(recent, 0);
     }
   return(ok);
  }

//+------------------------------------------------------------------+
//| Rebuilds historical identities from the journal                  |
//+------------------------------------------------------------------+
bool CTradeAuditJournal::RecordedObjects(ulong &orders[], ulong &deals[])
  {
   ArrayResize(orders, 0);
   ArrayResize(deals, 0);
   if(m_error != "")
      return(false);
   int h = FileOpen(m_fileName, FILE_READ | FILE_CSV | FILE_ANSI | FILE_SHARE_READ, ';', CP_UTF8);
   if(h == INVALID_HANDLE)
     {
      m_error = "Journal read error";
      return(false);
     }
   bool ok = Header(h, false);
   STradeAuditRecord row;
   while(ok && !FileIsEnding(h))
     {
      if(!ReadRow(h, row))
        {
         ok = false;
         break;
        }
      if(StringFind(row.note, "history_object=1") < 0)
         continue;
      if(row.eventType == AUDIT_ORDER_RECOVERED ||
         row.eventType == AUDIT_HISTORY_ORDER_ADDED ||
         row.eventType == AUDIT_HISTORY_ORDER_UPDATED)
        {
         int n = ArraySize(orders);
         if(ArrayResize(orders, n + 1) != n + 1)
           {
            m_error = "Allocation error";
            ok = false;
            break;
           }
         orders[n] = row.orderTicket;
        }
      if(row.eventType == AUDIT_DEAL_RECOVERED ||
         row.eventType == AUDIT_DEAL_ADDED ||
         row.eventType == AUDIT_DEAL_UPDATED)
        {
         int n = ArraySize(deals);
         if(ArrayResize(deals, n + 1) != n + 1)
           {
            m_error = "Allocation error";
            ok = false;
            break;
           }
         deals[n] = row.dealTicket;
        }
     }
   FileClose(h);
   ArraySort(orders);
   ArraySort(deals);
   return(ok);
  }

//+------------------------------------------------------------------+
//| Exports a period without replacing earlier files                 |
//+------------------------------------------------------------------+
bool CTradeAuditJournal::ExportPeriod(int days, string &savedAs)
  {
   savedAs = "";
   if(m_error != "")
      return(false);
   datetime now = TimeCurrent(), from = PeriodStart(days);
   string label = days == -1 ? "Today" : days <= 0 ? "All" : (string) days + "Days";
   string date = TimeToString(now, TIME_DATE);
   StringReplace(date, ".", "-");
   savedAs = "TradeAudit\\TradeAudit_" + (string) m_login + "_" + date + "_" + label + "_" + (string) GetMicrosecondCount() + ".csv";
   int source = FileOpen(m_fileName, FILE_READ | FILE_CSV | FILE_ANSI | FILE_SHARE_READ, ';', CP_UTF8);
   if(source == INVALID_HANDLE)
      return(false);
   bool ok = Header(source, false);
   int target = INVALID_HANDLE;
   if(ok && savedAs != m_fileName && !FileIsExist(savedAs))
      target = FileOpen(savedAs, FILE_WRITE | FILE_CSV | FILE_ANSI, ';', CP_UTF8);
   if(target == INVALID_HANDLE)
      ok = false;
   if(ok)
      ok = Header(target, true);
   STradeAuditRecord row;
   while(ok && !FileIsEnding(source))
     {
      if(!ReadRow(source, row))
        {
         ok = false;
         break;
        }
      if(row.eventTime >= from && row.eventTime <= now)
         ok = WriteRow(target, row);
     }
   FileClose(source);
   if(target != INVALID_HANDLE)
     {
      ResetLastError();
      FileFlush(target);
      if(GetLastError() != 0)
         ok = false;
      FileClose(target);
      if(!ok)
         FileDelete(savedAs);
     }
   return(ok);
  }

#endif
