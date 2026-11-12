Task Risk Management 
[] New Concept: Strategy
    - Strategy = template ghép các signal cơ bản (Indicator template, Bar information); 1 điều kiện cũng là 1 Strategy.
    - Source (Order Block, Zone...) build ở tầng signal cơ bản, không nằm trong Strategy.
    - Entry và Exit đều là Strategy; Trade dùng Entry để mở, Exit để đóng.
    - Python tính lịch sử, EA tính điểm mới (như Swing).
    - Chart: CButtonTriggered show Buy/Sell của Strategy (nguồn mới của CBarMarker).
    - Thống kê: SQL trên table Python tính sẵn (Buy/Sell: total, win). Bàn sau, khi chốt SL / TP / Exit
    - Risk Management / Trade chỉ nghe event của Strategy.
    -  Setting_Strategy             (strategy_id, name, ...)
         1
         │
         n
      Setting_StrategyCondition    (strategy_id, role, collection, type, params, side, ...)
         n
         │
         1
      Nguồn có sẵn = (collection, type, params)
         ├─ COLLECTION_SIGNALS_ID → một row Setting_IndicatorTemplate   (type = ENUM_INDICATOR, params)
         ├─ COLLECTION_SERIES_ID  → một row Setting_BarInformation      (type = ENUM_BAR_INFOR_TYPE, params "")
         └─ sau này: Order Block, Zone... → nguồn mới, cùng cách khoá
    [] Rà soát lại standard indicator.
      -Ichimoku hiện thiếu signal giá phá qua Kumo (Close so với Span A/B, buffer 2 và 3) 
        - Reference:  
          + 1. The Kumo Breakout System with Ichimoku and Awesome Oscillator 
          + https://www.mql5.com/en/articles/16657
      - MA(14) cắt lên MA(50) + RSI (14) ngưỡng 50
          + 05. 17040 Adaptive_Crossover_RSI_Trading_Suite 
          + https://www.mql5.com/en/articles/17040
          + Setting_StrategyTemplate: slot Fast = MA(14), slot Slow = MA(50)
      - Boillinger Band đang chỉ có một Band
    [] Strategy on Indicator: CalculateRSIAverage,CalculateRSIStandardDeviation
      - RSI: CIndVolumes, CIndicatorSeriesDE và CSignalVolumes  https://www.mql5.com/en/articles/17741
[] Change Rule: Working in RAM, Python save to DB.
[] Risk Management concept.
 [] CTradingStrategy
   + Reference: 20. 18604 MultiSymbolCCIAO_EA 
 [] isTradeAllowed  //lag to allow trade on a new bar
   - Reference: 07. 17190 Grid_EA_With_Dynamic_Lot-Sizing
       + https://www.mql5.com/en/articles/17109
   - CalculateWeightedBreakevenPrice()
   - breakevenPoints = 50 * _Point
   - enum ClosureMode 
     {
       CLOSE_BY_PROFIT,      //--- Use total profit (in currency) to close positions
       CLOSE_BY_POINTS       //--- Use a points threshold from breakeven to close positions
     };
   -BasketInfo
     Reference 
      11. 17350 Multi-Level_Grid_System_EA https://www.mql5.com/en/articles/17350
      23. 18778 Envelopes_Trend_Bounce_with_Zone_Recovery_Trailing_Stop_EA https://www.mql5.com/en/articles/18778
  [] enum ORDER_GROUP_TYPE //--- Define enumerations for order grouping
      { 
       Single=1,                                              //--- Group as single order
       SymbolOrderType=2,                                     //--- Group by symbol and order type
       Basket=3,                                              //--- Group all orders as a basket
       SymbolCode=4                                           //--- Group by symbol
      };  
      + Reference: 18. 18269 Envelopes_Trend_Bounce_Scalping_Part_1 https://www.mql5.com/en/articles/18269
  [] enum ORDER_PROFIT_CALCULATION_TYPE //--- Define enumerations for profit calculation
      { 
        Pips=1,                                                //--- Calculate profit in pips
        Money=2,                                               //--- Calculate profit in currency
        EquityPercentage=3                                     //--- Calculate profit as equity percentage
      };
  [] input bool UseTrailingStop = false;            // Toggle to enable or disable trailing stop functionality
   input int MinTrailPoints = 50;                 // Minimum profit in points before trailing stop activates
   input int TrailingPoints = 30;                 // Distance in points to maintain behind current price when trailing
    + Reference: 13. 17618 Head_f_Shoulders_Pattern https://www.mql5.com/en/articles/17618
   bool buySequenceActive = false;//---- Flag to track if a buy sequence is active
   bool sellSequenceActive = false;//---- Flag to track if a sell sequence is active
    + Reference: 14. 17741 Trade_Layering_Strategy_with_MACD-RSI_Statistical_Methods  https://www.mql5.com/en/articles/17741
  [] bool isHaveDailyRange_Prices = false; //--- Initialize flag to indicate if daily range prices are calculated
    bool isHaveRangeBreak = false; //--- Initialize flag to indicate if a range breakout has occurred
    bool isTakenTrade = false; //--- Initialize flag to indicate if a trade is taken for the current day
     + Reference: 16. 17876 Midnight_Range_Break_of_Structure_Breakout  https://www.mql5.com/en/articles/17876
  [] bool tradingEnabled = true;         //--- Indicate if trading is allowed based on drawdown limits
   + Reference: 17. 18038 GridMart_Scalper_MT5_EA https://www.mql5.com/en/articles/18038
  [] enum TradingLotSizeOptions { FIXED_LOTSIZE, UNFIXED_LOTSIZE }; 
     enum TradeState { INACTIVE, RUNNING, TERMINATING };
   + Reference: 
      * 22. 18720 Envelopes_Trend_Bounce_with_Zone_Recovery_EA                https://www.mql5.com/en/articles/18720
      * 23. 18778 Envelopes_Trend_Bounce_with_Zone_Recovery_Trailing_Stop_EA  https://www.mql5.com/en/articles/18778
  [] enum ENUM_TRADE_TYPE //--- Enumeration for trade types
      {     
      TRADE_ALL,              // All Trades (Buy and Sell)
      TRADE_BUY_ONLY,         // Buy Trades Only
      TRADE_SELL_ONLY         // Sell Trades Only
      };
    + Reference: 24. 18867 London_Breakout_EA  https://www.mql5.com/en/articles/18867
[] Chart Pattern and Harmonic_Pattern
  - Butterfly Strategy
    https://www.mql5.com/en/articles/17223
    https://www.litefinance.org/blog/for-beginners/harmonic-patterns/
[] Detect Zone 
 + Consolidation 12. 17547 Mitigation_Order_Blocks
 + Dead zone for calculation history.
 + Live Zone for trading.
[] Update Popupwindows
  + Not only Simple signal from simple indicator 
  + Cần thêm statistic

  