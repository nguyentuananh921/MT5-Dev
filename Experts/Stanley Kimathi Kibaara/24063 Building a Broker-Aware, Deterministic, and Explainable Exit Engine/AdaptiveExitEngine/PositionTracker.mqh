//+------------------------------------------------------------------+
//|                                              PositionTracker.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// --- Include the shared data types
#include "AdaptiveExitTypes.mqh"                                              // Shared enums and structures

//+------------------------------------------------------------------+
//| Position Tracker - captures terminal positions into snapshots    |
//+------------------------------------------------------------------+
class CPositionTracker
  {
private:
   // --- Member variables
   string            m_symbol;                                                // Symbol filter (e.g., EURUSD)
   long              m_magic;                                                 // Magic number of positions managed by this EA
   int               m_refresh_ms;                                            // Minimum time between scans (milliseconds)
   uint              m_last_scan_tick;                                        // Time of the last scan (GetTickCount, milliseconds)
   bool              m_scanned;                                               // False until the first scan is done
   SPositionSnapshot m_cached_snapshots[EXIT_MAX_POSITIONS];                  // Cached snapshots
   int               m_cache_count;                                           // Number of cached positions

   // --- Build a snapshot from the selected position; management fields come from the engine
   void              FillFromSelected(ulong ticket, SPositionSnapshot &snap)
     {
      ZeroMemory(snap);                                                       // Clear all fields
      snap.ticket = ticket;                                                   // Position ticket
      snap.symbol = PositionGetString(POSITION_SYMBOL);                       // Symbol
      snap.magic = PositionGetInteger(POSITION_MAGIC);                        // Magic number
      snap.direction = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); // Direction (Buy/Sell)
      snap.entry_price = PositionGetDouble(POSITION_PRICE_OPEN);              // Entry price (price units)
      snap.current_price = PositionGetDouble(POSITION_PRICE_CURRENT);         // Current price (price units)
      snap.current_sl = PositionGetDouble(POSITION_SL);                       // Stop-loss (price units)
      snap.current_tp = PositionGetDouble(POSITION_TP);                       // Take-profit (price units)
      snap.volume = PositionGetDouble(POSITION_VOLUME);                       // Volume (lots)
      snap.open_time = (datetime)PositionGetInteger(POSITION_TIME);           // Open time (timestamp)
      snap.initial_risk_distance = 0.0;                                       // Set by the engine
      snap.current_R = 0.0;                                                   // Set by the engine
      snap.max_favorable_R = 0.0;                                             // Set by the engine
      snap.flags = 0;                                                         // Set by the engine
     }

public:
   // --- Constructor - stores symbol, magic number and refresh interval
                     CPositionTracker(string symbol, long magic, int refresh_ms=1000)
     {
      m_symbol = symbol;                                                      // Symbol filter
      m_magic = magic;                                                        // Magic number filter
      m_refresh_ms = refresh_ms;                                              // Refresh interval (milliseconds)
      m_last_scan_tick = 0;                                                   // No scan yet
      m_scanned = false;                                                      // Force the first scan
      m_cache_count = 0;                                                      // Empty cache
     }

   // --- Get all managed positions, respecting the refresh interval
   bool              GetPositions(SPositionSnapshot &snapshots[])
     {
      uint now = GetTickCount();                                              // Current time (milliseconds)
      bool fresh = (now - m_last_scan_tick < (uint)m_refresh_ms);             // Cache still valid
      if(m_scanned && fresh)                                                  // Serve from cache
        {
         ArrayResize(snapshots, m_cache_count);                               // Match cache size
         for(int i = 0; i < m_cache_count; i++)                               // Copy every cached snapshot
            snapshots[i] = m_cached_snapshots[i];                             // Copy one snapshot
         return true;                                                         // Cached data
        }

      m_cache_count = 0;                                                      // Rebuild the cache
      for(int i = 0; i < PositionsTotal(); i++)                               // Every open position
        {
         ulong ticket = PositionGetTicket(i);                                 // Ticket of position i
         if(ticket == 0 || !PositionSelectByTicket(ticket))                   // Not selectable
            continue;                                                         // Skip it
         if(PositionGetString(POSITION_SYMBOL) != m_symbol)                   // Other symbol
            continue;                                                         // Skip it
         if(PositionGetInteger(POSITION_MAGIC) != m_magic)                    // Other EA
            continue;                                                         // Skip it
         if(m_cache_count >= EXIT_MAX_POSITIONS)                              // Cache full
            break;                                                            // Stop scanning
         SPositionSnapshot snap;                                              // New snapshot
         FillFromSelected(ticket, snap);                                      // Fill from selected position
         m_cached_snapshots[m_cache_count] = snap;                            // Store in cache
         m_cache_count++;                                                     // One more cached position
        }

      m_last_scan_tick = now;                                                 // Remember scan time
      m_scanned = true;                                                       // First scan done
      ArrayResize(snapshots, m_cache_count);                                  // Match cache size
      for(int i = 0; i < m_cache_count; i++)                                  // Copy every snapshot
         snapshots[i] = m_cached_snapshots[i];                                // Copy one snapshot
      return true;                                                            // Fresh data
     }

   // --- Get one position by ticket; force=true bypasses the cache
   bool              GetPositionByTicket(ulong ticket, SPositionSnapshot &snapshot, bool force=false)
     {
      if(force)                                                               // Query the terminal directly
        {
         if(!PositionSelectByTicket(ticket))                                  // Position no longer exists
            return false;                                                     // Not found
         FillFromSelected(ticket, snapshot);                                  // Fill from selected position
         return true;                                                         // Found
        }

      SPositionSnapshot snapshots[];                                          // Cached positions
      GetPositions(snapshots);                                                // Respects the cache
      for(int i = 0; i < ArraySize(snapshots); i++)                           // Search the ticket
        {
         if(snapshots[i].ticket == ticket)                                    // Ticket matches
           {
            snapshot = snapshots[i];                                          // Copy snapshot
            return true;                                                      // Found
           }
        }
      return false;                                                           // Not found
     }
  };

//+------------------------------------------------------------------+
