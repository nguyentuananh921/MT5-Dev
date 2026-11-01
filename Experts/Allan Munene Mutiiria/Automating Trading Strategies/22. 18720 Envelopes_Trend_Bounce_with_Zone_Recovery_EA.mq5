//+------------------------------------------------------------------+
//|                 Envelopes Trend Bounce with Zone Recovery EA.mq5 |
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
input int    magicNumber = 123456789;                                  // Magic Number
input int    maxOrders = 1;                                            // Maximum Initial Positions
input double zoneTargetPoints = 600;                                   // Zone Target Points
input double zoneSizePoints = 300;                                     // Zone Size Points
input bool   restrictMaxOrders = true;                                 // Apply Maximum Orders Restriction

class MarketZoneTrader {
private:
   //--- Trade State Definition
   enum TradeState { INACTIVE, RUNNING, TERMINATING };                 //--- Define trade lifecycle states

   //--- Data Structures
   struct TradeMetrics {
      bool   operationSuccess;                                         //--- Track operation success
      double totalVolume;                                              //--- Sum closed trade volumes
      double netProfitLoss;                                            //--- Accumulate profit/loss
   };

   struct ZoneBoundaries {
      double zoneHigh;                                                 //--- Upper recovery zone boundary
      double zoneLow;                                                  //--- Lower recovery zone boundary
      double zoneTargetHigh;                                           //--- Upper profit target
      double zoneTargetLow;                                            //--- Lower profit target
   };

   struct TradeConfig {
      string         marketSymbol;                                     //--- Trading symbol
      double         openPrice;                                        //--- Position entry price
      double         initialVolume;                                    //--- Initial trade volume
      long           tradeIdentifier;                                  //--- Magic number
      string         tradeLabel;                                       //--- Trade comment
      ulong          activeTickets[];                                  //--- Active position tickets
      ENUM_ORDER_TYPE direction;                                       //--- Trade direction
      double         zoneProfitSpan;                                   //--- Profit target range
      double         zoneRecoverySpan;                                 //--- Recovery zone range
      double         accumulatedBuyVolume;                             //--- Total buy volume
      double         accumulatedSellVolume;                            //--- Total sell volume
      TradeState     currentState;                                     //--- Current trade state
   };

   struct LossTracker {
      double tradeLossTracker;                                         //--- Track cumulative profit/loss
   };

   //--- Member Variables
   TradeConfig           m_tradeConfig;                                //--- Store trade configuration
   ZoneBoundaries        m_zoneBounds;                                 //--- Store zone boundaries
   LossTracker           m_lossTracker;                                //--- Track profit/loss
   string                m_lastError;                                  //--- Store error message
   int                   m_errorStatus;                                //--- Store error code
   CTrade                m_tradeExecutor;                              //--- Manage trade execution
   int                   m_handleRsi;                                  //--- RSI indicator handle
   int                   m_handleEnvUpper;                            //--- Upper Envelopes handle
   int                   m_handleEnvLower;                            //--- Lower Envelopes handle
   double                m_rsiBuffer[];                                //--- RSI data buffer
   double                m_envUpperBandBuffer[];                       //--- Upper Envelopes buffer
   double                m_envLowerBandBuffer[];                       //--- Lower Envelopes buffer
   TradingLotSizeOptions m_lotOption;                                  //--- Lot size option
   double                m_initialLotSize;                             //--- Fixed lot size
   double                m_riskPercentage;                             //--- Risk percentage
   int                   m_riskPoints;                                //--- Risk points
   int                   m_maxOrders;                                 //--- Maximum positions
   bool                  m_restrictMaxOrders;                          //--- Position restriction flag
   double                m_zoneTargetPoints;                           //--- Profit target points
   double                m_zoneSizePoints;                             //--- Recovery zone points

   //--- Error Handling
   void logError(string message, int code) {
      //--- Error Logging Start
      m_lastError = message;                                           //--- Store error message
      m_errorStatus = code;                                            //--- Store error code
      Print("Error: ", message);                                       //--- Log error to Experts tab
      //--- Error Logging End
   }

   //--- Market Data Access
   double getMarketVolumeStep() {
      //--- Volume Step Retrieval Start
      return SymbolInfoDouble(m_tradeConfig.marketSymbol, SYMBOL_VOLUME_STEP); //--- Retrieve broker's volume step
      //--- Volume Step Retrieval End
   }

   double getMarketAsk() {
      //--- Ask Price Retrieval Start
      return SymbolInfoDouble(m_tradeConfig.marketSymbol, SYMBOL_ASK); //--- Retrieve ask price
      //--- Ask Price Retrieval End
   }

   double getMarketBid() {
      //--- Bid Price Retrieval Start
      return SymbolInfoDouble(m_tradeConfig.marketSymbol, SYMBOL_BID); //--- Retrieve bid price
      //--- Bid Price Retrieval End
   }

   //--- Trade Initialization
   bool configureTrade(ulong ticket) {
      //--- Trade Configuration Start
      if (!PositionSelectByTicket(ticket)) {                            //--- Select position by ticket
         logError("Failed to select ticket " + IntegerToString(ticket), INIT_FAILED); //--- Log selection failure
         return false;                                                 //--- Return failure
      }
      m_tradeConfig.marketSymbol = PositionGetString(POSITION_SYMBOL);  //--- Set symbol
      m_tradeConfig.tradeLabel = __FILE__;                             //--- Set trade comment
      m_tradeConfig.tradeIdentifier = PositionGetInteger(POSITION_MAGIC); //--- Set magic number
      m_tradeConfig.direction = (ENUM_ORDER_TYPE)PositionGetInteger(POSITION_TYPE); //--- Set direction
      m_tradeConfig.openPrice = PositionGetDouble(POSITION_PRICE_OPEN); //--- Set entry price
      m_tradeConfig.initialVolume = PositionGetDouble(POSITION_VOLUME); //--- Set initial volume
      m_tradeExecutor.SetExpertMagicNumber(m_tradeConfig.tradeIdentifier); //--- Set magic number for executor
      return true;                                                     //--- Return success
      //--- Trade Configuration End
   }

   //--- Trade Ticket Management
   void storeTradeTicket(ulong ticket) {
      //--- Ticket Storage Start
      int ticketCount = ArraySize(m_tradeConfig.activeTickets);        //--- Get ticket count
      ArrayResize(m_tradeConfig.activeTickets, ticketCount + 1);       //--- Resize ticket array
      m_tradeConfig.activeTickets[ticketCount] = ticket;               //--- Store ticket
      //--- Ticket Storage End
   }

   //--- Trade Execution
   ulong openMarketTrade(ENUM_ORDER_TYPE tradeDirection, double tradeVolume, double price) {
      //--- Trade Opening Start
      ulong ticket = 0;                                                //--- Initialize ticket
      if (m_tradeExecutor.PositionOpen(m_tradeConfig.marketSymbol, tradeDirection, tradeVolume, price, 0, 0, m_tradeConfig.tradeLabel)) { //--- Open position
         ticket = m_tradeExecutor.ResultOrder();                       //--- Get ticket
      } else {
         Print("Failed to open trade: Direction=", EnumToString(tradeDirection), ", Volume=", tradeVolume); //--- Log failure
      }
      return ticket;                                                   //--- Return ticket
      //--- Trade Opening End
   }

   //--- Trade Closure
   void closeActiveTrades(TradeMetrics &metrics) {
      //--- Trade Closure Start
      for (int i = ArraySize(m_tradeConfig.activeTickets) - 1; i >= 0; i--) { //--- Iterate tickets in reverse
         if (m_tradeConfig.activeTickets[i] > 0) {                     //--- Check valid ticket
            if (m_tradeExecutor.PositionClose(m_tradeConfig.activeTickets[i])) { //--- Close position
               m_tradeConfig.activeTickets[i] = 0;                     //--- Clear ticket
               metrics.totalVolume += m_tradeExecutor.ResultVolume();  //--- Accumulate volume
               if ((ENUM_ORDER_TYPE)PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY) { //--- Check buy position
                  metrics.netProfitLoss += m_tradeExecutor.ResultVolume() * (m_tradeExecutor.ResultPrice() - PositionGetDouble(POSITION_PRICE_OPEN)); //--- Calculate buy profit
               } else {                                              //--- Handle sell position
                  metrics.netProfitLoss += m_tradeExecutor.ResultVolume() * (PositionGetDouble(POSITION_PRICE_OPEN) - m_tradeExecutor.ResultPrice()); //--- Calculate sell profit
               }
            } else {
               metrics.operationSuccess = false;                     //--- Mark failure
               Print("Failed to close ticket: ", m_tradeConfig.activeTickets[i]); //--- Log failure
            }
         }
      }
      //--- Trade Closure End
   }

   //--- Bar Detection
   bool isNewBar() {
      //--- New Bar Detection Start
      static datetime previousTime = 0;                                //--- Store previous bar time
      datetime currentTime = iTime(m_tradeConfig.marketSymbol, Period(), 0); //--- Get current bar time
      bool result = (currentTime != previousTime);                      //--- Check for new bar
      previousTime = currentTime;                                      //--- Update previous time
      return result;                                                   //--- Return new bar status
      //--- New Bar Detection End
   }

   //--- Lot Size Calculation
   double calculateLotSize(double riskPercent, int riskPips) {
      //--- Lot Size Calculation Start
      double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * riskPercent / 100; //--- Calculate risk amount
      double tickSize = SymbolInfoDouble(m_tradeConfig.marketSymbol, SYMBOL_TRADE_TICK_SIZE); //--- Get tick size
      double tickValue = SymbolInfoDouble(m_tradeConfig.marketSymbol, SYMBOL_TRADE_TICK_VALUE); //--- Get tick value
      if (tickSize == 0 || tickValue == 0) {                           //--- Validate tick data
         Print("Invalid tick size or value");                          //--- Log invalid data
         return -1;                                                    //--- Return invalid lot
      }
      double lotValue = (riskPips * _Point) / tickSize * tickValue;    //--- Calculate lot value
      if (lotValue == 0) {                                             //--- Validate lot value
         Print("Invalid lot value");                                   //--- Log invalid lot
         return -1;                                                    //--- Return invalid lot
      }
      return NormalizeDouble(riskMoney / lotValue, 2);                  //--- Return normalized lot size
      //--- Lot Size Calculation End
   }

   //--- Order Execution
   int openOrder(ENUM_ORDER_TYPE orderType, double stopLoss, double takeProfit) {
      //--- Order Opening Start
      int ticket;                                                      //--- Initialize ticket
      double openPrice;                                                //--- Initialize open price
      
      if (orderType == ORDER_TYPE_BUY) {                               //--- Check buy order
         openPrice = NormalizeDouble(getMarketAsk(), Digits());        //--- Set buy price
      } else if (orderType == ORDER_TYPE_SELL) {                       //--- Check sell order
         openPrice = NormalizeDouble(getMarketBid(), Digits());        //--- Set sell price
      } else {
         Print("Invalid order type");                                  //--- Log invalid type
         return -1;                                                    //--- Return invalid ticket
      }
      
      double lotSize = 0;                                              //--- Initialize lot size
      
      if (m_lotOption == FIXED_LOTSIZE) {                              //--- Check fixed lot
         lotSize = m_initialLotSize;                                   //--- Use fixed lot size
      } else if (m_lotOption == UNFIXED_LOTSIZE) {                     //--- Check dynamic lot
         lotSize = calculateLotSize(m_riskPercentage, m_riskPoints);   //--- Calculate risk-based lot
      }
      
      if (lotSize <= 0) {                                              //--- Validate lot size
         Print("Invalid lot size: ", lotSize);                         //--- Log invalid lot
         return -1;                                                    //--- Return invalid ticket
      }
      
      if (m_tradeExecutor.PositionOpen(m_tradeConfig.marketSymbol, orderType, lotSize, openPrice, 0, 0, __FILE__)) { //--- Open position
         ticket = (int)m_tradeExecutor.ResultOrder();                  //--- Get ticket
         Print("New trade opened: Ticket=", ticket, ", Type=", EnumToString(orderType), ", Volume=", lotSize); //--- Log success
      } else {
         ticket = -1;                                                  //--- Set invalid ticket
         Print("Failed to open order: Type=", EnumToString(orderType), ", Volume=", lotSize); //--- Log failure
      }
      
      return ticket;                                                   //--- Return ticket
      //--- Order Opening End
   }

public:
   //--- Constructor
   MarketZoneTrader(TradingLotSizeOptions lotOpt, double initLot, double riskPct, int riskPts, int maxOrds, bool restrictOrds, double targetPts, double sizePts) {
      //--- Constructor Start
      m_tradeConfig.currentState = INACTIVE;                           //--- Set initial state
      ArrayResize(m_tradeConfig.activeTickets, 0);                     //--- Initialize ticket array
      m_tradeConfig.zoneProfitSpan = targetPts * _Point;               //--- Set profit target
      m_tradeConfig.zoneRecoverySpan = sizePts * _Point;               //--- Set recovery zone
      m_lossTracker.tradeLossTracker = 0.0;                            //--- Initialize loss tracker
      m_lotOption = lotOpt;                                            //--- Set lot size option
      m_initialLotSize = initLot;                                      //--- Set initial lot
      m_riskPercentage = riskPct;                                      //--- Set risk percentage
      m_riskPoints = riskPts;                                          //--- Set risk points
      m_maxOrders = maxOrds;                                           //--- Set max positions
      m_restrictMaxOrders = restrictOrds;                              //--- Set restriction flag
      m_zoneTargetPoints = targetPts;                                  //--- Set target points
      m_zoneSizePoints = sizePts;                                      //--- Set zone points
      m_tradeConfig.marketSymbol = _Symbol;                            //--- Set symbol
      m_tradeConfig.tradeIdentifier = magicNumber;                     //--- Set magic number
      //--- Constructor End
   }

   //--- Destructor
   ~MarketZoneTrader() {
      //--- Destructor Start
      cleanup();                                                       //--- Release resources
      //--- Destructor End
   }

   //--- Getters
   TradeState getCurrentState() {
      //--- Get Current State Start
      return m_tradeConfig.currentState;                               //--- Return trade state
      //--- Get Current State End
   }

   double getZoneTargetHigh() {
      //--- Get Target High Start
      return m_zoneBounds.zoneTargetHigh;                              //--- Return profit target high
      //--- Get Target High End
   }

   double getZoneTargetLow() {
      //--- Get Target Low Start
      return m_zoneBounds.zoneTargetLow;                               //--- Return profit target low
      //--- Get Target Low End
   }

   double getZoneHigh() {
      //--- Get Zone High Start
      return m_zoneBounds.zoneHigh;                                    //--- Return recovery zone high
      //--- Get Zone High End
   }

   double getZoneLow() {
      //--- Get Zone Low Start
      return m_zoneBounds.zoneLow;                                     //--- Return recovery zone low
      //--- Get Zone Low End
   }

   //--- Initialization
   int initialize() {
      //--- Initialization Start
      m_tradeExecutor.SetExpertMagicNumber(m_tradeConfig.tradeIdentifier); //--- Set magic number
      int totalPositions = PositionsTotal();                           //--- Get total positions
      
      for (int i = 0; i < totalPositions; i++) {                       //--- Iterate positions
         ulong ticket = PositionGetTicket(i);                          //--- Get ticket
         if (PositionSelectByTicket(ticket)) {                         //--- Select position
            if (PositionGetString(POSITION_SYMBOL) == m_tradeConfig.marketSymbol && PositionGetInteger(POSITION_MAGIC) == m_tradeConfig.tradeIdentifier) { //--- Check symbol and magic
               if (activateTrade(ticket)) {                            //--- Activate position
                  Print("Existing position activated: Ticket=", ticket); //--- Log activation
               } else {
                  Print("Failed to activate existing position: Ticket=", ticket); //--- Log failure
               }
            }
         }
      }
      
      m_handleRsi = iRSI(m_tradeConfig.marketSymbol, PERIOD_CURRENT, 8, PRICE_CLOSE); //--- Initialize RSI
      if (m_handleRsi == INVALID_HANDLE) {                             //--- Check RSI
         Print("Failed to initialize RSI indicator");                  //--- Log failure
         return INIT_FAILED;                                           //--- Return failure
      }
      
      m_handleEnvUpper = iEnvelopes(m_tradeConfig.marketSymbol, PERIOD_CURRENT, 150, 0, MODE_SMA, PRICE_CLOSE, 0.1); //--- Initialize upper Envelopes
      if (m_handleEnvUpper == INVALID_HANDLE) {                        //--- Check upper Envelopes
         Print("Failed to initialize upper Envelopes indicator");      //--- Log failure
         return INIT_FAILED;                                           //--- Return failure
      }
      
      m_handleEnvLower = iEnvelopes(m_tradeConfig.marketSymbol, PERIOD_CURRENT, 95, 0, MODE_SMA, PRICE_CLOSE, 1.4); //--- Initialize lower Envelopes
      if (m_handleEnvLower == INVALID_HANDLE) {                        //--- Check lower Envelopes
         Print("Failed to initialize lower Envelopes indicator");      //--- Log failure
         return INIT_FAILED;                                           //--- Return failure
      }
      
      ArraySetAsSeries(m_rsiBuffer, true);                             //--- Set RSI buffer
      ArraySetAsSeries(m_envUpperBandBuffer, true);                    //--- Set upper Envelopes buffer
      ArraySetAsSeries(m_envLowerBandBuffer, true);                    //--- Set lower Envelopes buffer
      
      Print("EA initialized successfully");                            //--- Log success
      return INIT_SUCCEEDED;                                           //--- Return success
      //--- Initialization End
   }

   //--- Cleanup
   void cleanup() {
      //--- Cleanup Start
      IndicatorRelease(m_handleRsi);                                   //--- Release RSI handle
      ArrayFree(m_rsiBuffer);                                          //--- Free RSI buffer
      IndicatorRelease(m_handleEnvUpper);                              //--- Release upper Envelopes handle
      ArrayFree(m_envUpperBandBuffer);                                 //--- Free upper Envelopes buffer
      IndicatorRelease(m_handleEnvLower);                              //--- Release lower Envelopes handle
      ArrayFree(m_envLowerBandBuffer);                                 //--- Free lower Envelopes buffer
      //--- Cleanup End
   }

   //--- Position Management
   bool activateTrade(ulong ticket) {
      //--- Position Activation Start
      m_tradeConfig.currentState = INACTIVE;                           //--- Set state to inactive
      ArrayResize(m_tradeConfig.activeTickets, 0);                     //--- Clear tickets
      m_lossTracker.tradeLossTracker = 0.0;                            //--- Reset loss tracker
      if (!configureTrade(ticket)) {                                    //--- Configure trade
         return false;                                                 //--- Return failure
      }
      storeTradeTicket(ticket);                                        //--- Store ticket
      if (m_tradeConfig.direction == ORDER_TYPE_BUY) {                 //--- Handle buy position
         m_zoneBounds.zoneHigh = m_tradeConfig.openPrice;              //--- Set zone high
         m_zoneBounds.zoneLow = m_zoneBounds.zoneHigh - m_tradeConfig.zoneRecoverySpan; //--- Set zone low
         m_tradeConfig.accumulatedBuyVolume = m_tradeConfig.initialVolume; //--- Set buy volume
         m_tradeConfig.accumulatedSellVolume = 0.0;                    //--- Reset sell volume
      } else {                                                         //--- Handle sell position
         m_zoneBounds.zoneLow = m_tradeConfig.openPrice;               //--- Set zone low
         m_zoneBounds.zoneHigh = m_zoneBounds.zoneLow + m_tradeConfig.zoneRecoverySpan; //--- Set zone high
         m_tradeConfig.accumulatedSellVolume = m_tradeConfig.initialVolume; //--- Set sell volume
         m_tradeConfig.accumulatedBuyVolume = 0.0;                     //--- Reset buy volume
      }
      m_zoneBounds.zoneTargetHigh = m_zoneBounds.zoneHigh + m_tradeConfig.zoneProfitSpan; //--- Set target high
      m_zoneBounds.zoneTargetLow = m_zoneBounds.zoneLow - m_tradeConfig.zoneProfitSpan; //--- Set target low
      m_tradeConfig.currentState = RUNNING;                            //--- Set state to running
      return true;                                                     //--- Return success
      //--- Position Activation End
   }

   //--- Tick Processing
   void processTick() {
      //--- Tick Processing Start
      double askPrice = NormalizeDouble(getMarketAsk(), Digits());     //--- Get ask price
      double bidPrice = NormalizeDouble(getMarketBid(), Digits());     //--- Get bid price
      
      evaluateMarketTick();                                            //--- Evaluate position
      
      if (!isNewBar()) return;                                         //--- Exit if not new bar
      
      if (!CopyBuffer(m_handleRsi, 0, 0, 3, m_rsiBuffer)) {            //--- Load RSI data
         Print("Error loading RSI data. Reverting.");                   //--- Log RSI failure
         return;                                                       //--- Exit
      }
      
      if (!CopyBuffer(m_handleEnvUpper, 0, 0, 3, m_envUpperBandBuffer)) { //--- Load upper Envelopes
         Print("Error loading upper envelopes data. Reverting.");       //--- Log failure
         return;                                                       //--- Exit
      }
      
      if (!CopyBuffer(m_handleEnvLower, 1, 0, 3, m_envLowerBandBuffer)) { //--- Load lower Envelopes
         Print("Error loading lower envelopes data. Reverting.");       //--- Log failure
         return;                                                       //--- Exit
      }
      
      int ticket = 0;                                                  //--- Initialize ticket
      
      const int rsiOverbought = 70;                                    //--- Set RSI overbought level
      const int rsiOversold = 30;                                      //--- Set RSI oversold level
      
      if (m_rsiBuffer[1] < rsiOversold && m_rsiBuffer[2] > rsiOversold && m_rsiBuffer[0] < rsiOversold) { //--- Check buy signal
         if (askPrice > m_envUpperBandBuffer[0]) {                     //--- Confirm price above upper Envelopes
            if (!m_restrictMaxOrders || PositionsTotal() < m_maxOrders) { //--- Check position limit
               ticket = openOrder(ORDER_TYPE_BUY, 0, 0);                //--- Open buy order
            }
         }
      } else if (m_rsiBuffer[1] > rsiOverbought && m_rsiBuffer[2] < rsiOverbought && m_rsiBuffer[0] > rsiOverbought) { //--- Check sell signal
         if (bidPrice < m_envLowerBandBuffer[0]) {                     //--- Confirm price below lower Envelopes
            if (!m_restrictMaxOrders || PositionsTotal() < m_maxOrders) { //--- Check position limit
               ticket = openOrder(ORDER_TYPE_SELL, 0, 0);               //--- Open sell order
            }
         }
      }
      
      if (ticket > 0) {                                                //--- Check if trade opened
         if (activateTrade(ticket)) {                                  //--- Activate position
            Print("New position activated: Ticket=", ticket);          //--- Log activation
         } else {
            Print("Failed to activate new position: Ticket=", ticket); //--- Log failure
         }
      }
      //--- Tick Processing End
   }

   //--- Market Tick Evaluation
   void evaluateMarketTick() {
      //--- Tick Evaluation Start
      if (m_tradeConfig.currentState == INACTIVE) return;              //--- Exit if inactive
      if (m_tradeConfig.currentState == TERMINATING) {                 //--- Check terminating state
         finalizePosition();                                           //--- Finalize position
         return;                                                       //--- Exit
      }
      double currentPrice;                                             //--- Initialize price
      if (m_tradeConfig.direction == ORDER_TYPE_BUY) {                 //--- Handle buy position
         currentPrice = getMarketBid();                                //--- Get bid price
         if (currentPrice > m_zoneBounds.zoneTargetHigh) {             //--- Check profit target
            Print("Closing position: Bid=", currentPrice, " > TargetHigh=", m_zoneBounds.zoneTargetHigh); //--- Log closure
            finalizePosition();                                        //--- Close position
            return;                                                    //--- Exit
         } else if (currentPrice < m_zoneBounds.zoneLow) {             //--- Check recovery trigger
            Print("Triggering recovery trade: Bid=", currentPrice, " < ZoneLow=", m_zoneBounds.zoneLow); //--- Log recovery
            triggerRecoveryTrade(ORDER_TYPE_SELL, currentPrice);       //--- Open sell recovery
         }
      } else if (m_tradeConfig.direction == ORDER_TYPE_SELL) {         //--- Handle sell position
         currentPrice = getMarketAsk();                                //--- Get ask price
         if (currentPrice < m_zoneBounds.zoneTargetLow) {              //--- Check profit target
            Print("Closing position: Ask=", currentPrice, " < TargetLow=", m_zoneBounds.zoneTargetLow); //--- Log closure
            finalizePosition();                                        //--- Close position
            return;                                                    //--- Exit
         } else if (currentPrice > m_zoneBounds.zoneHigh) {            //--- Check recovery trigger
            Print("Triggering recovery trade: Ask=", currentPrice, " > ZoneHigh=", m_zoneBounds.zoneHigh); //--- Log recovery
            triggerRecoveryTrade(ORDER_TYPE_BUY, currentPrice);        //--- Open buy recovery
         }
      }
      //--- Tick Evaluation End
   }

   //--- Recovery Trade Handling
   void triggerRecoveryTrade(ENUM_ORDER_TYPE tradeDirection, double price) {
      //--- Recovery Trade Start
      TradeMetrics metrics = {true, 0.0, 0.0};                         //--- Initialize metrics
      closeActiveTrades(metrics);                                       //--- Close existing trades
      for (int i = 0; i < 10 && !metrics.operationSuccess; i++) {      //--- Retry closure
         Sleep(1000);                                                  //--- Wait 1 second
         metrics.operationSuccess = true;                              //--- Reset success flag
         closeActiveTrades(metrics);                                   //--- Retry closure
      }
      m_lossTracker.tradeLossTracker += metrics.netProfitLoss;         //--- Update loss tracker
      if (m_lossTracker.tradeLossTracker > 0 && metrics.operationSuccess) { //--- Check positive profit
         Print("Closing position due to positive profit: ", m_lossTracker.tradeLossTracker); //--- Log closure
         finalizePosition();                                           //--- Close position
         m_lossTracker.tradeLossTracker = 0.0;                         //--- Reset loss tracker
         return;                                                       //--- Exit
      }
      double tradeSize = determineRecoverySize(tradeDirection);        //--- Calculate trade size
      ulong ticket = openMarketTrade(tradeDirection, tradeSize, price); //--- Open recovery trade
      if (ticket > 0) {                                                //--- Check if trade opened
         storeTradeTicket(ticket);                                     //--- Store ticket
         m_tradeConfig.direction = tradeDirection;                     //--- Update direction
         if (tradeDirection == ORDER_TYPE_BUY) m_tradeConfig.accumulatedBuyVolume += tradeSize; //--- Update buy volume
         else m_tradeConfig.accumulatedSellVolume += tradeSize;        //--- Update sell volume
         Print("Recovery trade opened: Ticket=", ticket, ", Direction=", EnumToString(tradeDirection), ", Volume=", tradeSize); //--- Log recovery trade
      }
      //--- Recovery Trade End
   }

   //--- Position Finalization
   bool finalizePosition() {
      //--- Position Finalization Start
      m_tradeConfig.currentState = TERMINATING;                        //--- Set terminating state
      TradeMetrics metrics = {true, 0.0, 0.0};                         //--- Initialize metrics
      closeActiveTrades(metrics);                                       //--- Close all trades
      if (metrics.operationSuccess) {                                  //--- Check success
         ArrayResize(m_tradeConfig.activeTickets, 0);                  //--- Clear tickets
         m_tradeConfig.currentState = INACTIVE;                        //--- Set inactive state
         Print("Position closed successfully");                        //--- Log success
      } else {
         Print("Failed to close position");                            //--- Log failure
      }
      return metrics.operationSuccess;                                 //--- Return status
      //--- Position Finalization End
   }

   //--- Recovery Size Calculation
   double determineRecoverySize(ENUM_ORDER_TYPE tradeDirection) {
      //--- Recovery Size Calculation Start
      double tradeSize = -m_lossTracker.tradeLossTracker / m_tradeConfig.zoneProfitSpan; //--- Calculate lot size
      tradeSize = MathCeil(tradeSize / getMarketVolumeStep()) * getMarketVolumeStep(); //--- Round to volume step
      return tradeSize;                                                //--- Return trade size
      //--- Recovery Size Calculation End
   }
};

//--- Global Instance
MarketZoneTrader *trader = NULL;                                        //--- Declare trader instance

int OnInit() {
   //--- EA Initialization Start
   trader = new MarketZoneTrader(lotOption, initialLotSize, riskPercentage, riskPoints, maxOrders, restrictMaxOrders, zoneTargetPoints, zoneSizePoints); //--- Create trader instance
   return trader.initialize();                                           //--- Initialize EA
   //--- EA Initialization End
}

void OnDeinit(const int reason) {
   //--- EA Deinitialization Start
   if (trader != NULL) {                                                 //--- Check trader existence
      delete trader;                                                     //--- Delete trader
      trader = NULL;                                                     //--- Clear pointer
      Print("EA deinitialized");                                         //--- Log deinitialization
   }
   //--- EA Deinitialization End
}

void OnTick() {
   //--- Tick Handling Start
   if (trader != NULL) {                                                 //--- Check trader existence
      trader.processTick();                                              //--- Process tick
   }
   //--- Tick Handling End
}