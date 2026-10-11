//+------------------------------------------------------------------+
//|                                               MarketCache.mqh   |
//|                                Copyright 2026, Clemence Benjamin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Clemence Benjamin"
#property link      "https://www.mql5.com"

#include "../Common/Structures.mqh"

//+------------------------------------------------------------------+
//| Class: CMarketDataCache                                          |
//| Purpose: Caches market data for performance                      |
//+------------------------------------------------------------------+
class CMarketDataCache
{
private:
   MarketSnapshot m_snapshot;
   datetime       m_lastUpdate;
   int            m_updateInterval;
   
public:
   CMarketDataCache(int updateInterval = 1);
   ~CMarketDataCache();
   
   void Refresh();
   MarketSnapshot GetSnapshot();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMarketDataCache::CMarketDataCache(int updateInterval)
{
   m_updateInterval = updateInterval;
   m_lastUpdate = 0;
   ZeroMemory(m_snapshot);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMarketDataCache::~CMarketDataCache()
{
}

//+------------------------------------------------------------------+
//| Refresh market data if needed                                    |
//+------------------------------------------------------------------+
void CMarketDataCache::Refresh()
{
   datetime now = TimeCurrent();
   if (now - m_lastUpdate < m_updateInterval)
      return;
      
   m_snapshot.open = iOpen(_Symbol, _Period, 0);
   m_snapshot.high = iHigh(_Symbol, _Period, 0);
   m_snapshot.low = iLow(_Symbol, _Period, 0);
   m_snapshot.close = iClose(_Symbol, _Period, 0);
   m_snapshot.bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   m_snapshot.ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   m_snapshot.time = now;
   
   m_lastUpdate = now;
}

//+------------------------------------------------------------------+
//| Get cached market snapshot                                       |
//+------------------------------------------------------------------+
MarketSnapshot CMarketDataCache::GetSnapshot()
{
   Refresh();
   return m_snapshot;
}