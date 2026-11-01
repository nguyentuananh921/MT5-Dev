//+------------------------------------------------------------------+
//|   Envelopes Trend Bounce with Zone Recovery Trailing Stop EA.mq5 |
//|                           Copyright 2025, Allan Munene Mutiiria. |
//|                                   https://t.me/Forex_Algo_Trader |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Allan Munene Mutiiria."
#property link      "https://t.me/Forex_Algo_Trader"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>                                                    //--- Include trade library

enum TradingLotSizeOptions { FIXED_LOTSIZE, UNFIXED_LOTSIZE };         //--- Define lot size options

input group "======= EA GENERAL SETTINGS ======="
input TradingLotSizeOptions lotOption = UNFIXED_LOTSIZE;               // Lot Size Option
input double initialLotSize = 0.01;                                    // Initial Lot Size
input double riskPercentage = 1.0;                                     // Risk Percentage (%)
input int    riskPoints = 300;                                         // Risk Points
input int    baseMagicNumber = 123456789;                              // Base Magic Number
input int    maxInitialPositions = 1;                                  // Maximum Initial Positions (Baskets/Signals)
input double zoneTargetPoints = 600;                                   // Zone Target Points
input double zoneSizePoints = 300;                                     // Zone Size Points
input bool   enableInitialTrailing = true;                             // Enable Trailing Stop for Initial Positions
input int    trailingStopPoints = 50;                                  // Trailing Stop Points
input int    minProfitPoints = 50;                                     // Minimum Profit Points to Start Trailing

//--- Forward Declaration of MarketZoneTrader
class MarketZoneTrader;

//--- Basket Manager Class to Handle Multiple Traders
class BasketManager {
private:
   MarketZoneTrader* m_traders[];                                        //--- Array of trader instances
   int               m_handleRsi;                                        //--- RSI indicator handle
   int               m_handleEnvUpper;                                   //--- Upper Envelopes handle
   int               m_handleEnvLower;                                   //--- Lower Envelopes handle
   double            m_rsiBuffer[];                                     //--- RSI data buffer
   double            m_envUpperBandBuffer[];                            //--- Upper Envelopes buffer
   double            m_envLowerBandBuffer[];                            //--- Lower Envelopes buffer
   string            m_symbol;                                          //--- Trading symbol
   int               m_baseMagicNumber;                                 //--- Base magic number
   int               m_maxInitialPositions;                             //--- Maximum baskets (signals)

   //--- Initialize Indicators
   bool initializeIndicators() {
      m_handleRsi = iRSI(m_symbol, PERIOD_CURRENT, 8, PRICE_CLOSE);
      if (m_handleRsi == INVALID_HANDLE) {
         Print("Failed to initialize RSI indicator");
         return false;
      }
      m_handleEnvUpper = iEnvelopes(m_symbol, PERIOD_CURRENT, 150, 0, MODE_SMA, PRICE_CLOSE, 0.1);
      if (m_handleEnvUpper == INVALID_HANDLE) {
         Print("Failed to initialize upper Envelopes indicator");
         return false;
      }
      m_handleEnvLower = iEnvelopes(m_symbol, PERIOD_CURRENT, 95, 0, MODE_SMA, PRICE_CLOSE, 1.4);
      if (m_handleEnvLower == INVALID_HANDLE) {
         Print("Failed to initialize lower Envelopes indicator");
         return false;
      }
      ArraySetAsSeries(m_rsiBuffer, true);
      ArraySetAsSeries(m_envUpperBandBuffer, true);
      ArraySetAsSeries(m_envLowerBandBuffer, true);
      return true;
   }

   //--- Cleanup Indicators
   void cleanupIndicators() {
      if (m_handleRsi != INVALID_HANDLE) IndicatorRelease(m_handleRsi);
      if (m_handleEnvUpper != INVALID_HANDLE) IndicatorRelease(m_handleEnvUpper);
      if (m_handleEnvLower != INVALID_HANDLE) IndicatorRelease(m_handleEnvLower);
      ArrayFree(m_rsiBuffer);
      ArrayFree(m_envUpperBandBuffer);
      ArrayFree(m_envLowerBandBuffer);
   }

   //--- Check for New Bar
   bool isNewBar() {
      static datetime previousTime = 0;
      datetime currentTime = iTime(m_symbol, Period(), 0);
      bool result = (currentTime != previousTime);
      previousTime = currentTime;
      return result;
   }

   //--- Count Active Baskets
   int countActiveBaskets() {
      int count = 0;
      for (int i = 0; i < ArraySize(m_traders); i++) {
         if (m_traders[i] != NULL && m_traders[i].getCurrentState() != MarketZoneTrader::INACTIVE) {
            count++;
         }
      }
      return count;
   }

   //--- Cleanup Terminated Baskets
   void cleanupTerminatedBaskets() {
      int newSize = 0;
      for (int i = 0; i < ArraySize(m_traders); i++) {
         if (m_traders[i] != NULL && m_traders[i].getCurrentState() == MarketZoneTrader::INACTIVE) {
            delete m_traders[i];
            m_traders[i] = NULL;
         }
         if (m_traders[i] != NULL) newSize++;
      }
      MarketZoneTrader* temp[];
      ArrayResize(temp, newSize);
      int index = 0;
      for (int i = 0; i < ArraySize(m_traders); i++) {
         if (m_traders[i] != NULL) {
            temp[index] = m_traders[i];
            index++;
         }
      }
      ArrayFree(m_traders);
      ArrayResize(m_traders, newSize);
      for (int i = 0; i < newSize; i++) {
         m_traders[i] = temp[i];
      }
      ArrayFree(temp);
   }

public:
   BasketManager(string symbol, int baseMagic, int maxInitPos) {
      m_symbol = symbol;
      m_baseMagicNumber = baseMagic;
      m_maxInitialPositions = maxInitPos;
      ArrayResize(m_traders, 0);
      m_handleRsi = INVALID_HANDLE;
      m_handleEnvUpper = INVALID_HANDLE;
      m_handleEnvLower = INVALID_HANDLE;
   }

   ~BasketManager() {
      for (int i = 0; i < ArraySize(m_traders); i++) {
         if (m_traders[i] != NULL) delete m_traders[i];
      }
      ArrayFree(m_traders);
      cleanupIndicators();
   }

   bool initialize() {
      if (!initializeIndicators()) return false;
      //--- Load existing positions into baskets
      int totalPositions = PositionsTotal();
      for (int i = 0; i < totalPositions; i++) {
         ulong ticket = PositionGetTicket(i);
         if (PositionSelectByTicket(ticket)) {
            if (PositionGetString(POSITION_SYMBOL) == m_symbol) {
               long magic = PositionGetInteger(POSITION_MAGIC);
               if (magic >= m_baseMagicNumber && magic < m_baseMagicNumber + m_maxInitialPositions) {
                  //--- Check if basket already exists for this magic
                  bool exists = false;
                  for (int j = 0; j < ArraySize(m_traders); j++) {
                     if (m_traders[j] != NULL && m_traders[j].getMagicNumber() == magic) {
                        exists = true;
                        break;
                     }
                  }
                  if (!exists && countActiveBaskets() < m_maxInitialPositions) {
                     createNewBasket(magic, ticket);
                  }
               }
            }
         }
      }
      Print("BasketManager initialized with ", ArraySize(m_traders), " existing baskets");
      return true;
   }

   void processTick() {
      //--- Process existing baskets
      for (int i = 0; i < ArraySize(m_traders); i++) {
         if (m_traders[i] != NULL) {
            m_traders[i].processTick(m_rsiBuffer, m_envUpperBandBuffer, m_envLowerBandBuffer);
         }
      }
      cleanupTerminatedBaskets();

      //--- Check for new signals on new bar
      if (!isNewBar()) return;

      if (!CopyBuffer(m_handleRsi, 0, 0, 3, m_rsiBuffer)) {
         Print("Error loading RSI data. Reverting.");
         return;
      }
      if (!CopyBuffer(m_handleEnvUpper, 0, 0, 3, m_envUpperBandBuffer)) {
         Print("Error loading upper envelopes data. Reverting.");
         return;
      }
      if (!CopyBuffer(m_handleEnvLower, 1, 0, 3, m_envLowerBandBuffer)) {
         Print("Error loading lower envelopes data. Reverting.");
         return;
      }

      const int rsiOverbought = 70;
      const int rsiOversold = 30;
      int ticket = -1;
      ENUM_ORDER_TYPE signalType = (ENUM_ORDER_TYPE)-1;

      double askPrice = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_ASK), Digits());
      double bidPrice = NormalizeDouble(SymbolInfoDouble(m_symbol, SYMBOL_BID), Digits());

      if (m_rsiBuffer[1] < rsiOversold && m_rsiBuffer[2] > rsiOversold && m_rsiBuffer[0] < rsiOversold) {
         if (askPrice > m_envUpperBandBuffer[0]) {
            if (countActiveBaskets() < m_maxInitialPositions) {
               signalType = ORDER_TYPE_BUY;
            }
         }
      } else if (m_rsiBuffer[1] > rsiOverbought && m_rsiBuffer[2] < rsiOverbought && m_rsiBuffer[0] > rsiOverbought) {
         if (bidPrice < m_envLowerBandBuffer[0]) {
            if (countActiveBaskets() < m_maxInitialPositions) {
               signalType = ORDER_TYPE_SELL;
            }
         }
      }

      if (signalType != (ENUM_ORDER_TYPE)-1) {
         //--- Create new basket with unique magic number
         int newMagic = m_baseMagicNumber + ArraySize(m_traders);
         if (newMagic < m_baseMagicNumber + m_maxInitialPositions) {
            MarketZoneTrader* newTrader = new MarketZoneTrader(lotOption, initialLotSize, riskPercentage, riskPoints, zoneTargetPoints, zoneSizePoints, newMagic);
            ticket = newTrader.openInitialOrder(signalType); //--- Open INITIAL position
            if (ticket > 0 && newTrader.activateTrade(ticket)) {
               int size = ArraySize(m_traders);
               ArrayResize(m_traders, size + 1);
               m_traders[size] = newTrader;
               Print("New basket created: Magic=", newMagic, ", Ticket=", ticket, ", Type=", EnumToString(signalType));
            } else {
               delete newTrader;
               Print("Failed to create new basket: Ticket=", ticket);
            }
         } else {
            Print("Maximum initial positions (baskets) reached: ", m_maxInitialPositions);
         }
      }
   }

private:
   void createNewBasket(long magic, ulong ticket) {
      MarketZoneTrader* newTrader = new MarketZoneTrader(lotOption, initialLotSize, riskPercentage, riskPoints, zoneTargetPoints, zoneSizePoints, magic);
      if (newTrader.activateTrade(ticket)) {
         int size = ArraySize(m_traders);
         ArrayResize(m_traders, size + 1);
         m_traders[size] = newTrader;
         Print("Existing position loaded into basket: Magic=", magic, ", Ticket=", ticket);
      } else {
         delete newTrader;
         Print("Failed to load existing position into basket: Ticket=", ticket);
      }
   }
};

//--- Modified MarketZoneTrader Class
class MarketZoneTrader {
private:
   enum TradeState { INACTIVE, RUNNING, TERMINATING };

   struct TradeMetrics {
      bool   operationSuccess;
      double totalVolume;
      double netProfitLoss;
   };

   struct ZoneBoundaries {
      double zoneHigh;
      double zoneLow;
      double zoneTargetHigh;
      double zoneTargetLow;
   };

   struct TradeConfig {
      string         marketSymbol;
      double         openPrice;
      double         initialVolume;
      long           tradeIdentifier;
      string         initialTradeLabel;  //--- Label for initial positions
      string         recoveryTradeLabel; //--- Label for recovery positions
      ulong          activeTickets[];
      ENUM_ORDER_TYPE direction;
      double         zoneProfitSpan;
      double         zoneRecoverySpan;
      double         accumulatedBuyVolume;
      double         accumulatedSellVolume;
      TradeState     currentState;
      bool           hasRecoveryTrades;  //--- Flag to track recovery trades
      double         trailingStopLevel;  //--- Virtual trailing stop level
   };

   struct LossTracker {
      double tradeLossTracker;
   };

   TradeConfig           m_tradeConfig;
   ZoneBoundaries        m_zoneBounds;
   LossTracker           m_lossTracker;
   string                m_lastError;
   int                   m_errorStatus;
   CTrade                m_tradeExecutor;
   TradingLotSizeOptions m_lotOption;
   double                m_initialLotSize;
   double                m_riskPercentage;
   int                   m_riskPoints;
   double                m_zoneTargetPoints;
   double                m_zoneSizePoints;

   void logError(string message, int code) {
      m_lastError = message;
      m_errorStatus = code;
      Print("Error [Magic=", m_tradeConfig.tradeIdentifier, "]: ", message);
   }

   double getMarketVolumeStep() {
      return SymbolInfoDouble(m_tradeConfig.marketSymbol, SYMBOL_VOLUME_STEP);
   }

   double getMarketAsk() {
      return SymbolInfoDouble(m_tradeConfig.marketSymbol, SYMBOL_ASK);
   }

   double getMarketBid() {
      return SymbolInfoDouble(m_tradeConfig.marketSymbol, SYMBOL_BID);
   }

   bool configureTrade(ulong ticket) {
      if (!PositionSelectByTicket(ticket)) {
         logError("Failed to select ticket " + IntegerToString(ticket), INIT_FAILED);
         return false;
      }
      m_tradeConfig.marketSymbol = PositionGetString(POSITION_SYMBOL);
      m_tradeConfig.tradeIdentifier = PositionGetInteger(POSITION_MAGIC);
      m_tradeConfig.direction = (ENUM_ORDER_TYPE)PositionGetInteger(POSITION_TYPE);
      m_tradeConfig.openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      m_tradeConfig.initialVolume = PositionGetDouble(POSITION_VOLUME);
      m_tradeExecutor.SetExpertMagicNumber(m_tradeConfig.tradeIdentifier);
      return true;
   }

   void storeTradeTicket(ulong ticket) {
      int ticketCount = ArraySize(m_tradeConfig.activeTickets);
      ArrayResize(m_tradeConfig.activeTickets, ticketCount + 1);
      m_tradeConfig.activeTickets[ticketCount] = ticket;
   }

   ulong openMarketTrade(ENUM_ORDER_TYPE tradeDirection, double tradeVolume, double price, string comment) {
      //--- Open position with specified comment (INITIAL or RECOVERY)
      ulong ticket = 0;
      if (m_tradeExecutor.PositionOpen(m_tradeConfig.marketSymbol, tradeDirection, tradeVolume, price, 0, 0, comment)) {
         ticket = m_tradeExecutor.ResultOrder();
      } else {
         Print("Failed to open trade [Magic=", m_tradeConfig.tradeIdentifier, "]: Direction=", EnumToString(tradeDirection), ", Volume=", tradeVolume, ", Comment=", comment);
      }
      return ticket;
   }

   void closeActiveTrades(TradeMetrics &metrics) {
      for (int i = ArraySize(m_tradeConfig.activeTickets) - 1; i >= 0; i--) {
         if (m_tradeConfig.activeTickets[i] > 0) {
            if (m_tradeExecutor.PositionClose(m_tradeConfig.activeTickets[i])) {
               m_tradeConfig.activeTickets[i] = 0;
               metrics.totalVolume += m_tradeExecutor.ResultVolume();
               if ((ENUM_ORDER_TYPE)PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY) {
                  metrics.netProfitLoss += m_tradeExecutor.ResultVolume() * (m_tradeExecutor.ResultPrice() - PositionGetDouble(POSITION_PRICE_OPEN));
               } else {
                  metrics.netProfitLoss += m_tradeExecutor.ResultVolume() * (PositionGetDouble(POSITION_PRICE_OPEN) - m_tradeExecutor.ResultPrice());
               }
            } else {
               metrics.operationSuccess = false;
               Print("Failed to close ticket [Magic=", m_tradeConfig.tradeIdentifier, "]: ", m_tradeConfig.activeTickets[i]);
            }
         }
      }
   }

   double calculateLotSize(double riskPercent, int riskPips) {
      double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * riskPercent / 100;
      double tickSize = SymbolInfoDouble(m_tradeConfig.marketSymbol, SYMBOL_TRADE_TICK_SIZE);
      double tickValue = SymbolInfoDouble(m_tradeConfig.marketSymbol, SYMBOL_TRADE_TICK_VALUE);
      if (tickSize == 0 || tickValue == 0) {
         Print("Invalid tick size or value [Magic=", m_tradeConfig.tradeIdentifier, "]");
         return -1;
      }
      double lotValue = (riskPips * _Point) / tickSize * tickValue;
      if (lotValue == 0) {
         Print("Invalid lot value [Magic=", m_tradeConfig.tradeIdentifier, "]");
         return -1;
      }
      return NormalizeDouble(riskMoney / lotValue, 2);
   }

public:
   MarketZoneTrader(TradingLotSizeOptions lotOpt, double initLot, double riskPct, int riskPts, double targetPts, double sizePts, long magic) {
      m_tradeConfig.currentState = INACTIVE;
      ArrayResize(m_tradeConfig.activeTickets, 0);
      m_tradeConfig.zoneProfitSpan = targetPts * _Point;
      m_tradeConfig.zoneRecoverySpan = sizePts * _Point;
      m_lossTracker.tradeLossTracker = 0.0;
      m_lotOption = lotOpt;
      m_initialLotSize = initLot;
      m_riskPercentage = riskPct;
      m_riskPoints = riskPts;
      m_zoneTargetPoints = targetPts;
      m_zoneSizePoints = sizePts;
      m_tradeConfig.marketSymbol = _Symbol;
      m_tradeConfig.tradeIdentifier = magic;
      m_tradeConfig.initialTradeLabel = "EA_INITIAL_" + IntegerToString(magic); //--- Label for initial positions
      m_tradeConfig.recoveryTradeLabel = "EA_RECOVERY_" + IntegerToString(magic); //--- Label for recovery positions
      m_tradeConfig.hasRecoveryTrades = false; //--- Initialize recovery flag
      m_tradeConfig.trailingStopLevel = 0.0; //--- Initialize trailing stop
      m_tradeExecutor.SetExpertMagicNumber(magic);
   }

   ~MarketZoneTrader() {
      ArrayFree(m_tradeConfig.activeTickets);
   }

   TradeState getCurrentState() {
      return m_tradeConfig.currentState;
   }

   long getMagicNumber() {
      return m_tradeConfig.tradeIdentifier;
   }

   double getZoneTargetHigh() {
      return m_zoneBounds.zoneTargetHigh;
   }

   double getZoneTargetLow() {
      return m_zoneBounds.zoneTargetLow;
   }

   double getZoneHigh() {
      return m_zoneBounds.zoneHigh;
   }

   double getZoneLow() {
      return m_zoneBounds.zoneLow;
   }

   bool activateTrade(ulong ticket) {
      m_tradeConfig.currentState = INACTIVE;
      ArrayResize(m_tradeConfig.activeTickets, 0);
      m_lossTracker.tradeLossTracker = 0.0;
      m_tradeConfig.hasRecoveryTrades = false;
      m_tradeConfig.trailingStopLevel = 0.0;
      if (!configureTrade(ticket)) {
         return false;
      }
      storeTradeTicket(ticket);
      if (m_tradeConfig.direction == ORDER_TYPE_BUY) {
         m_zoneBounds.zoneHigh = m_tradeConfig.openPrice;
         m_zoneBounds.zoneLow = m_zoneBounds.zoneHigh - m_tradeConfig.zoneRecoverySpan;
         m_tradeConfig.accumulatedBuyVolume = m_tradeConfig.initialVolume;
         m_tradeConfig.accumulatedSellVolume = 0.0;
      } else {
         m_zoneBounds.zoneLow = m_tradeConfig.openPrice;
         m_zoneBounds.zoneHigh = m_zoneBounds.zoneLow + m_tradeConfig.zoneRecoverySpan;
         m_tradeConfig.accumulatedSellVolume = m_tradeConfig.initialVolume;
         m_tradeConfig.accumulatedBuyVolume = 0.0;
      }
      m_zoneBounds.zoneTargetHigh = m_zoneBounds.zoneHigh + m_tradeConfig.zoneProfitSpan;
      m_zoneBounds.zoneTargetLow = m_zoneBounds.zoneLow - m_tradeConfig.zoneProfitSpan;
      m_tradeConfig.currentState = RUNNING;
      return true;
   }

   int openInitialOrder(ENUM_ORDER_TYPE orderType) {
      //--- Open INITIAL position based on signal
      int ticket;
      double openPrice;
      if (orderType == ORDER_TYPE_BUY) {
         openPrice = NormalizeDouble(getMarketAsk(), Digits());
      } else if (orderType == ORDER_TYPE_SELL) {
         openPrice = NormalizeDouble(getMarketBid(), Digits());
      } else {
         Print("Invalid order type [Magic=", m_tradeConfig.tradeIdentifier, "]");
         return -1;
      }
      double lotSize = 0;
      if (m_lotOption == FIXED_LOTSIZE) {
         lotSize = m_initialLotSize;
      } else if (m_lotOption == UNFIXED_LOTSIZE) {
         lotSize = calculateLotSize(m_riskPercentage, m_riskPoints);
      }
      if (lotSize <= 0) {
         Print("Invalid lot size [Magic=", m_tradeConfig.tradeIdentifier, "]: ", lotSize);
         return -1;
      }
      if (m_tradeExecutor.PositionOpen(m_tradeConfig.marketSymbol, orderType, lotSize, openPrice, 0, 0, m_tradeConfig.initialTradeLabel)) {
         ticket = (int)m_tradeExecutor.ResultOrder();
         Print("INITIAL trade opened [Magic=", m_tradeConfig.tradeIdentifier, "]: Ticket=", ticket, ", Type=", EnumToString(orderType), ", Volume=", lotSize);
      } else {
         ticket = -1;
         Print("Failed to open INITIAL order [Magic=", m_tradeConfig.tradeIdentifier, "]: Type=", EnumToString(orderType), ", Volume=", lotSize);
      }
      return ticket;
   }

   void processTick(double &rsiBuffer[], double &envUpperBuffer[], double &envLowerBuffer[]) {
      if (m_tradeConfig.currentState == INACTIVE) return;
      evaluateMarketTick();
   }

   void evaluateMarketTick() {
      if (m_tradeConfig.currentState == INACTIVE) return;
      if (m_tradeConfig.currentState == TERMINATING) {
         finalizePosition();
         return;
      }
      double currentPrice;
      double profitPoints = 0.0;

      //--- Handle BUY initial position
      if (m_tradeConfig.direction == ORDER_TYPE_BUY) {
         currentPrice = getMarketBid();
         profitPoints = (currentPrice - m_tradeConfig.openPrice) / _Point;

         //--- Trailing Stop Logic for Initial Position
         if (enableInitialTrailing && !m_tradeConfig.hasRecoveryTrades && profitPoints >= minProfitPoints) {
            //--- Calculate desired trailing stop level
            double newTrailingStop = currentPrice - trailingStopPoints * _Point;
            //--- Start or update trailing stop if profit exceeds minProfitPoints + trailingStopPoints
            if (profitPoints >= minProfitPoints + trailingStopPoints) {
               if (m_tradeConfig.trailingStopLevel == 0.0 || newTrailingStop > m_tradeConfig.trailingStopLevel) {
                  m_tradeConfig.trailingStopLevel = newTrailingStop;
                  Print("Trailing stop updated [Magic=", m_tradeConfig.tradeIdentifier, "]: Level=", m_tradeConfig.trailingStopLevel, ", Profit=", profitPoints, " points");
               }
            }
            //--- Check if price has hit trailing stop
            if (m_tradeConfig.trailingStopLevel > 0.0 && currentPrice <= m_tradeConfig.trailingStopLevel) {
               Print("Trailing stop triggered [Magic=", m_tradeConfig.tradeIdentifier, "]: Bid=", currentPrice, " <= TrailingStop=", m_tradeConfig.trailingStopLevel);
               finalizePosition();
               return;
            }
         }

         //--- Zone Recovery Logic
         if (currentPrice > m_zoneBounds.zoneTargetHigh) {
            Print("Closing position [Magic=", m_tradeConfig.tradeIdentifier, "]: Bid=", currentPrice, " > TargetHigh=", m_zoneBounds.zoneTargetHigh);
            finalizePosition();
            return;
         } else if (currentPrice < m_zoneBounds.zoneLow) {
            Print("Triggering RECOVERY trade [Magic=", m_tradeConfig.tradeIdentifier, "]: Bid=", currentPrice, " < ZoneLow=", m_zoneBounds.zoneLow);
            triggerRecoveryTrade(ORDER_TYPE_SELL, currentPrice);
         }
      }
      //--- Handle SELL initial position
      else if (m_tradeConfig.direction == ORDER_TYPE_SELL) {
         currentPrice = getMarketAsk();
         profitPoints = (m_tradeConfig.openPrice - currentPrice) / _Point;

         //--- Trailing Stop Logic for Initial Position
         if (enableInitialTrailing && !m_tradeConfig.hasRecoveryTrades && profitPoints >= minProfitPoints) {
            //--- Calculate desired trailing stop level
            double newTrailingStop = currentPrice + trailingStopPoints * _Point;
            //--- Start or update trailing stop if profit exceeds minProfitPoints + trailingStopPoints
            if (profitPoints >= minProfitPoints + trailingStopPoints) {
               if (m_tradeConfig.trailingStopLevel == 0.0 || newTrailingStop < m_tradeConfig.trailingStopLevel) {
                  m_tradeConfig.trailingStopLevel = newTrailingStop;
                  Print("Trailing stop updated [Magic=", m_tradeConfig.tradeIdentifier, "]: Level=", m_tradeConfig.trailingStopLevel, ", Profit=", profitPoints, " points");
               }
            }
            //--- Check if price has hit trailing stop
            if (m_tradeConfig.trailingStopLevel > 0.0 && currentPrice >= m_tradeConfig.trailingStopLevel) {
               Print("Trailing stop triggered [Magic=", m_tradeConfig.tradeIdentifier, "]: Ask=", currentPrice, " >= TrailingStop=", m_tradeConfig.trailingStopLevel);
               finalizePosition();
               return;
            }
         }

         //--- Zone Recovery Logic
         if (currentPrice < m_zoneBounds.zoneTargetLow) {
            Print("Closing position [Magic=", m_tradeConfig.tradeIdentifier, "]: Ask=", currentPrice, " < TargetLow=", m_zoneBounds.zoneTargetLow);
            finalizePosition();
            return;
         } else if (currentPrice > m_zoneBounds.zoneHigh) {
            Print("Triggering RECOVERY trade [Magic=", m_tradeConfig.tradeIdentifier, "]: Ask=", currentPrice, " > ZoneHigh=", m_zoneBounds.zoneHigh);
            triggerRecoveryTrade(ORDER_TYPE_BUY, currentPrice);
         }
      }
   }

   void triggerRecoveryTrade(ENUM_ORDER_TYPE tradeDirection, double price) {
      //--- Handle RECOVERY trade
      m_tradeConfig.hasRecoveryTrades = true; //--- Mark basket as having recovery trades
      TradeMetrics metrics = {true, 0.0, 0.0};
      closeActiveTrades(metrics);
      for (int i = 0; i < 10 && !metrics.operationSuccess; i++) {
         Sleep(1000);
         metrics.operationSuccess = true;
         closeActiveTrades(metrics);
      }
      m_lossTracker.tradeLossTracker += metrics.netProfitLoss;
      if (m_lossTracker.tradeLossTracker > 0 && metrics.operationSuccess) {
         Print("Closing position due to positive profit [Magic=", m_tradeConfig.tradeIdentifier, "]: ", m_lossTracker.tradeLossTracker);
         finalizePosition();
         m_lossTracker.tradeLossTracker = 0.0;
         return;
      }
      double tradeSize = determineRecoverySize(tradeDirection);
      ulong ticket = openMarketTrade(tradeDirection, tradeSize, price, m_tradeConfig.recoveryTradeLabel); //--- RECOVERY position
      if (ticket > 0) {
         storeTradeTicket(ticket);
         m_tradeConfig.direction = tradeDirection;
         if (tradeDirection == ORDER_TYPE_BUY) m_tradeConfig.accumulatedBuyVolume += tradeSize;
         else m_tradeConfig.accumulatedSellVolume += tradeSize;
         Print("RECOVERY trade opened [Magic=", m_tradeConfig.tradeIdentifier, "]: Ticket=", ticket, ", Direction=", EnumToString(tradeDirection), ", Volume=", tradeSize);
      }
   }

   bool finalizePosition() {
      m_tradeConfig.currentState = TERMINATING;
      TradeMetrics metrics = {true, 0.0, 0.0};
      closeActiveTrades(metrics);
      if (metrics.operationSuccess) {
         ArrayResize(m_tradeConfig.activeTickets, 0);
         m_tradeConfig.currentState = INACTIVE;
         Print("Position closed successfully [Magic=", m_tradeConfig.tradeIdentifier, "]");
      } else {
         Print("Failed to close position [Magic=", m_tradeConfig.tradeIdentifier, "]");
      }
      return metrics.operationSuccess;
   }

   double determineRecoverySize(ENUM_ORDER_TYPE tradeDirection) {
      double tradeSize = -m_lossTracker.tradeLossTracker / m_tradeConfig.zoneProfitSpan;
      tradeSize = MathCeil(tradeSize / getMarketVolumeStep()) * getMarketVolumeStep();
      return tradeSize;
   }
};

//--- Global Instance
BasketManager *manager = NULL;

int OnInit() {
   manager = new BasketManager(_Symbol, baseMagicNumber, maxInitialPositions);
   if (!manager.initialize()) {
      delete manager;
      manager = NULL;
      return INIT_FAILED;
   }
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
   if (manager != NULL) {
      delete manager;
      manager = NULL;
      Print("EA deinitialized");
   }
}

void OnTick() {
   if (manager != NULL) {
      manager.processTick();
   }
}