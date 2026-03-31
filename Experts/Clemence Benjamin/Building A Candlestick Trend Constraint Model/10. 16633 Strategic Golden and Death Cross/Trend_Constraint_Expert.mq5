//+------------------------------------------------------------------+
//|                                      Trend Constraint Expert.mq5 |
//|                                Copyright 2024, Clemence Benjamin |
//|             https://www.mql5.com/en/users/billionaire2024/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Clemence Benjamini"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property version   "1.03"

#include <Trade\Trade.mqh>
CTrade trade;

// Input parameters for controlling strategies
input bool UseTrendFollowingStrategy = false;   // Enable/Disable Trend Following Strategy
input bool UseBreakoutStrategy = false;         // Enable/Disable Breakout Strategy
input bool UseDivergenceStrategy = false;       // Enable/Disable Divergence Strategy
input bool UseGoldenDeathCrossStrategy = true;  // Enable/Disable Golden/Death Cross Strategy

// Input parameters for Golden/Death Cross Strategy
input double GDC_LotSize = 1.0;            // Trade volume (lots) for Golden Death Cross
input int GDC_Slippage = 20;               // Slippage in points for Golden Death Cross
input int GDC_TimerInterval = 1000;        // Timer interval in seconds for Golden Death Cross
input double GDC_StopLossPips = 1500;      // Stop Loss in pips for Golden Death Cross
input int GDC_FastEMAPeriod = 50;          // Fast EMA period for Golden Death Cross
input int GDC_SlowEMAPeriod = 200;         // Slow EMA period for Golden Death Cross

int GDC_fastEMAHandle, GDC_slowEMAHandle;  // Handles for EMA indicators in Golden Death Cross

// Global variables
double prevShortMA, prevLongMA;

// Input parameters for Trend Constraint Strategy
input int    RSI_Period = 14;            // RSI period
input double RSI_Overbought = 70.0;     // RSI overbought level
input double RSI_Oversold = 30.0;       // RSI oversold level
input double Lots = 0.1;                // Lot size
input double StopLoss = 100;            // Stop Loss in points
input double TakeProfit = 200;          // Take Profit in points
input double TrailingStop = 50;         // Trailing Stop in points
input int    MagicNumber = 12345678;    // Magic number for the Trend Constraint EA
input int    OrderLifetime = 43200;     // Order lifetime in seconds (12 hours)

// Input parameters for Breakout Strategy
input int InpDonchianPeriod = 20;       // Period for Donchian Channel
input double RiskRewardRatio = 1.5;     // Risk-to-reward ratio
input double LotSize = 0.1;             // Default lot size for trading
input double pipsToStopLoss = 15;       // Stop loss in pips for Breakout
input double pipsToTakeProfit = 30;     // Take profit in pips for Breakout

// Input parameters for Divergence Strategy
input int DivergenceMACDPeriod = 12;    // MACD Fast EMA period
input int DivergenceSignalPeriod = 9;   // MACD Signal period
input double DivergenceLots = 1.0;      // Lot size for Divergence trades
input double DivergenceStopLoss = 300;   // Stop Loss in points for Divergence
input double DivergenceTakeProfit = 500; // Take Profit in points for Divergence
input int DivergenceMagicNumber = 87654321;     // Magic number for Divergence Strategy
input int DivergenceLookBack = 8;       // Number of periods to look back for divergence
input double profitLockerPoints  = 20;  // Number of profit points to lock
 

// Indicator handle storage
int rsi_handle;                         
int handle;                             // Handle for Donchian Channel
int macd_handle;

double ExtUpBuffer[];                   // Upper Donchian buffer
double ExtDnBuffer[];                   // Lower Donchian buffer
double ExtMacdBuffer[];                 // MACD buffer
double ExtSignalBuffer[];               // Signal buffer
int globalMagicNumber;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    prevShortMA = 0.0;
    prevLongMA = 0.0;
    // Initialize RSI handle
    rsi_handle = iRSI(_Symbol, PERIOD_CURRENT, RSI_Period, PRICE_CLOSE);
    if (rsi_handle == INVALID_HANDLE)
    {
        Print("Failed to create RSI indicator handle. Error: ", GetLastError());
        return INIT_FAILED;
    }

    // Create a handle for the Donchian Channel
    handle = iCustom(_Symbol, PERIOD_CURRENT, "Free Indicators\\Donchian Channel", InpDonchianPeriod);
    if (handle == INVALID_HANDLE)
    {
        Print("Failed to load the Donchian Channel indicator. Error: ", GetLastError());
        return INIT_FAILED;
    }

    // Initialize MACD handle for divergence
    globalMagicNumber = DivergenceMagicNumber;
    macd_handle = iMACD(_Symbol, PERIOD_CURRENT, DivergenceMACDPeriod, 26, DivergenceSignalPeriod, PRICE_CLOSE);
    if (macd_handle == INVALID_HANDLE)
    {
        Print("Failed to create MACD indicator handle for divergence strategy. Error: ", GetLastError());
        return INIT_FAILED;
    }
    
    
    if(UseGoldenDeathCrossStrategy)
{
    // Check if there are enough bars to calculate the EMA
    if(Bars(_Symbol, PERIOD_CURRENT) < GDC_SlowEMAPeriod)
    {
        Print("Not enough bars for EMA calculation for Golden Death Cross");
        return INIT_FAILED;
    }
    GDC_fastEMAHandle = iMA(_Symbol, PERIOD_CURRENT, GDC_FastEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
    GDC_slowEMAHandle = iMA(_Symbol, PERIOD_CURRENT, GDC_SlowEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
    if(GDC_fastEMAHandle < 0 || GDC_slowEMAHandle < 0)
    {
        Print("Failed to create EMA handles for Golden Death Cross. Error: ", GetLastError());
        return INIT_FAILED;
    }
}

    // Resize arrays for MACD buffers
    ArrayResize(ExtMacdBuffer, DivergenceLookBack);
    ArrayResize(ExtSignalBuffer, DivergenceLookBack);

    Print("Trend Constraint Expert initialized.");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    IndicatorRelease(rsi_handle);
    IndicatorRelease(handle);
    IndicatorRelease(macd_handle);
    Print("Trend Constraint Expert deinitialized.");
}


//+------------------------------------------------------------------+
//| Check Golden/Death Cross Trading Logic                           |
//+------------------------------------------------------------------+
void CheckGoldenDeathCross()
{
    double fastEMAArray[2], slowEMAArray[2];
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

    if(CopyBuffer(GDC_fastEMAHandle, 0, 0, 2, fastEMAArray) <= 0 ||
       CopyBuffer(GDC_slowEMAHandle, 0, 0, 2, slowEMAArray) <= 0)
    {
        Print("Failed to copy EMA data for Golden Death Cross. Error: ", GetLastError());
        return;
    }

    bool hasPosition = PositionSelect(_Symbol);

    if(!hasPosition)
    {
        if(fastEMAArray[0] > slowEMAArray[0] && fastEMAArray[1] <= slowEMAArray[1]) // Death Cross 
        {
            double sl = NormalizeDouble(ask + GDC_StopLossPips * point, _Digits);
            if(!trade.Sell(GDC_LotSize, _Symbol, ask, sl ))
                Print("Sell order error for Golden Death Cross ", GetLastError());
            else
                Print("Sell order opened for Golden Death Cross with SL ", GDC_StopLossPips, " pips");
        }
        else if(fastEMAArray[0] < slowEMAArray[0] && fastEMAArray[1] >= slowEMAArray[1]) // Golden Cross
        {
            double sl = NormalizeDouble(bid - GDC_StopLossPips * point, _Digits);
            if(!trade.Buy(GDC_LotSize, _Symbol, bid, sl ))
                Print("Buy order error for Golden Death Cross ", GetLastError());
            else
                Print("Buy order opened for Golden Death Cross with SL ", GDC_StopLossPips, " pips");
        }
    }
    else
    {
        if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && fastEMAArray[0] < slowEMAArray[0]) ||
           (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && fastEMAArray[0] > slowEMAArray[0]))
        {
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            if(!trade.PositionClose(ticket))
                Print("Failed to close position for Golden Death Cross (Ticket: ", ticket, "). Error: ", GetLastError());
            else  
                Print("Position closed for Golden Death Cross: ", ticket);
        }
    }
}

//+------------------------------------------------------------------+
//| Check Trend Following Strategy                                   |
//+------------------------------------------------------------------+
void CheckTrendFollowing()
{
   if (PositionsTotal() >= 2) return; // Ensure no more than 2 orders from this strategy

    double rsi_value;
    double rsi_values[];
    if (CopyBuffer(rsi_handle, 0, 0, 1, rsi_values) <= 0)
    {
        Print("Failed to get RSI value. Error: ", GetLastError());
        return;
    }
    rsi_value = rsi_values[0];

    double ma_short = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE);
    double ma_long = iMA(_Symbol, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE);

    bool is_uptrend = ma_short > ma_long;
    bool is_downtrend = ma_short < ma_long;

    if (is_uptrend && rsi_value < RSI_Oversold)
    {
        double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double stopLossPrice = currentPrice - StopLoss * _Point;
        double takeProfitPrice = currentPrice + TakeProfit * _Point;

        // Corrected Buy method call with 6 parameters
        if (trade.Buy(Lots, _Symbol, 0, stopLossPrice, takeProfitPrice, "Trend Following Buy"))
        {
            Print("Trend Following Buy order placed.");
        }
    }
    else if (is_downtrend && rsi_value > RSI_Overbought)
    {
        double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        double stopLossPrice = currentPrice + StopLoss * _Point;
        double takeProfitPrice = currentPrice - TakeProfit * _Point;

        // Corrected Sell method call with 6 parameters
        if (trade.Sell(Lots, _Symbol, 0, stopLossPrice, takeProfitPrice, "Trend Following Sell"))
        {
            Print("Trend Following Sell order placed.");
        }
    }
}

//+------------------------------------------------------------------+
//| Check Breakout Strategy                                          |
//+------------------------------------------------------------------+
void CheckBreakoutTrading()
{
    if (PositionsTotal() >= 2) return; // Ensure no more than 2 orders from this strategy

    ArrayResize(ExtUpBuffer, 2);
    ArrayResize(ExtDnBuffer, 2);

    if (CopyBuffer(handle, 0, 0, 2, ExtUpBuffer) <= 0 || CopyBuffer(handle, 2, 0, 2, ExtDnBuffer) <= 0)
    {
        Print("Error reading Donchian Channel buffer. Error: ", GetLastError());
        return;
    }

    double closePrice = iClose(_Symbol, PERIOD_CURRENT, 0);
    double lastOpen = iOpen(_Symbol, PERIOD_D1, 1);
    double lastClose = iClose(_Symbol, PERIOD_D1, 1);

    bool isBullishDay = lastClose > lastOpen;
    bool isBearishDay = lastClose < lastOpen;

    if (isBullishDay && closePrice > ExtUpBuffer[1])
    {
        double stopLoss = closePrice - pipsToStopLoss * _Point;
        double takeProfit = closePrice + pipsToTakeProfit * _Point;
        if (trade.Buy(LotSize, _Symbol, 0, stopLoss, takeProfit, "Breakout Buy") > 0)
        {
            Print("Breakout Buy order placed.");
        }
    }
    else if (isBearishDay && closePrice < ExtDnBuffer[1])
    {
        double stopLoss = closePrice + pipsToStopLoss * _Point;
        double takeProfit = closePrice - pipsToTakeProfit * _Point;
        if (trade.Sell(LotSize, _Symbol, 0, stopLoss, takeProfit, "Breakout Sell") > 0)
        {
            Print("Breakout Sell order placed.");
        }
    }
}

//+------------------------------------------------------------------+
//| Check Divergence Trading                                         |
//+------------------------------------------------------------------+
bool CheckBullishRegularDivergence()
{
    double priceLow1 = iLow(_Symbol, PERIOD_CURRENT, 2);
    double priceLow2 = iLow(_Symbol, PERIOD_CURRENT, DivergenceLookBack);
    double macdLow1 = ExtMacdBuffer[2];
    double macdLow2 = ExtMacdBuffer[DivergenceLookBack - 1];

    return (priceLow1 < priceLow2 && macdLow1 > macdLow2);
}

bool CheckBullishHiddenDivergence()
{
    double priceLow1 = iLow(_Symbol, PERIOD_CURRENT, 2);
    double priceLow2 = iLow(_Symbol, PERIOD_CURRENT, DivergenceLookBack);
    double macdLow1 = ExtMacdBuffer[2];
    double macdLow2 = ExtMacdBuffer[DivergenceLookBack - 1];

    return (priceLow1 > priceLow2 && macdLow1 < macdLow2);
}

bool CheckBearishRegularDivergence()
{
    double priceHigh1 = iHigh(_Symbol, PERIOD_CURRENT, 2);
    double priceHigh2 = iHigh(_Symbol, PERIOD_CURRENT, DivergenceLookBack);
    double macdHigh1 = ExtMacdBuffer[2];
    double macdHigh2 = ExtMacdBuffer[DivergenceLookBack - 1];

    return (priceHigh1 > priceHigh2 && macdHigh1 < macdHigh2);
}

bool CheckBearishHiddenDivergence()
{
    double priceHigh1 = iHigh(_Symbol, PERIOD_CURRENT, 2);
    double priceHigh2 = iHigh(_Symbol, PERIOD_CURRENT, DivergenceLookBack);
    double macdHigh1 = ExtMacdBuffer[2]; 
    double macdHigh2 = ExtMacdBuffer[DivergenceLookBack - 1];

    return (priceHigh1 < priceHigh2 && macdHigh1 > macdHigh2);
}

void CheckDivergenceTrading()
{
    if (!UseDivergenceStrategy) return;

    // Check if no position is open or if less than 3 positions are open
    int openDivergencePositions = CountOrdersByMagic(DivergenceMagicNumber);
    if (openDivergencePositions == 0 || openDivergencePositions < 3)
    {
        int barsAvailable = Bars(_Symbol, PERIOD_CURRENT);
        if (barsAvailable < DivergenceLookBack * 2)
        {
            Print("Not enough data bars for MACD calculation.");
            return;
        }

        int attempt = 0;
        while(attempt < 6)
        {
            if (CopyBuffer(macd_handle, 0, 0, DivergenceLookBack, ExtMacdBuffer) > 0 &&
                CopyBuffer(macd_handle, 1, 0, DivergenceLookBack, ExtSignalBuffer) > 0)
                break; 
            
            Print("Failed to copy MACD buffer, retrying...");
            Sleep(1000);
            attempt++;
        }
        if(attempt == 6)
        {
            Print("Failed to copy MACD buffers after ", attempt, " attempts.");
            return;
        }

        if(TimeCurrent() == iTime(_Symbol, PERIOD_CURRENT, 0))
        {
            Print("Skipping trade due to incomplete bar data.");
            return;
        }

        double currentClose = iClose(_Symbol, PERIOD_CURRENT, 0);
        double dailyClose = iClose(_Symbol, PERIOD_D1, 0);
        double dailyOpen = iOpen(_Symbol, PERIOD_D1, 0);
        bool isDailyBullish = dailyClose > dailyOpen;
        bool isDailyBearish = dailyClose < dailyOpen;

        // Only proceed with buy orders if D1 is bullish
        if (isDailyBullish)
        {
            if ((CheckBullishRegularDivergence() && ExtMacdBuffer[0] > ExtSignalBuffer[0]) ||
                CheckBullishHiddenDivergence())
            {
                ExecuteDivergenceOrder(true);
            }
        }

        // Only proceed with sell orders if D1 is bearish
        if (isDailyBearish)
        {
            if ((CheckBearishRegularDivergence() && ExtMacdBuffer[0] < ExtSignalBuffer[0]) ||
                CheckBearishHiddenDivergence())
            {
                ExecuteDivergenceOrder(false);
            }
        }
    }
    else
    {
        Print("Divergence strategy: Maximum number of positions reached.");
    }
}

void ExecuteDivergenceOrder(bool isBuy)
{
    // Ensure the magic number is set for the trade
    trade.SetExpertMagicNumber(DivergenceMagicNumber);
    
    double currentPrice = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double stopLossPrice = isBuy ? currentPrice - DivergenceStopLoss * _Point : currentPrice + DivergenceStopLoss * _Point;
    double takeProfitPrice = isBuy ? currentPrice + DivergenceTakeProfit * _Point : currentPrice - DivergenceTakeProfit * _Point;

    if (isBuy)
    {
        if (trade.Buy(DivergenceLots, _Symbol, 0, stopLossPrice, takeProfitPrice, "Divergence Buy"))
        {
            Print("Divergence Buy order placed.");
        }
    }
    else
    {
        if (trade.Sell(DivergenceLots, _Symbol, 0, stopLossPrice, takeProfitPrice, "Divergence Sell"))
        {
            Print("Divergence Sell order placed.");
        }
    }
}

int CountOrdersByMagic(int magic)
{
    int count = 0;
    for (int i = 0; i < PositionsTotal(); i++)
    {
        ulong ticket = PositionGetTicket(i);
        if (PositionSelectByTicket(ticket))
        {
            if (PositionGetInteger(POSITION_MAGIC) == magic)
            {
                count++;
            }
        }
    }
    return count;
}

//+------------------------------------------------------------------+
//| Profit Locking Logic                                             |
//+------------------------------------------------------------------+
void LockProfits()
{
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if (PositionSelectByTicket(ticket))
        {
            double entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double currentProfit = PositionGetDouble(POSITION_PROFIT);
            double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
            
            // Convert profit to points
            double profitPoints = MathAbs(currentProfit / _Point);

            // Check if profit has exceeded 100 points
            if (profitPoints >= 100)
            {
                double newStopLoss;
                
                if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                {
                    newStopLoss = entryPrice + profitLockerPoints * _Point; // 20 points above entry for buys
                }
                else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                {
                    newStopLoss = entryPrice - profitLockerPoints * _Point; // 20 points below entry for sells
                }
                else
                {
                    continue; // Skip if not a buy or sell position
                }

                // Modify stop loss only if the new stop loss is more protective
                double currentStopLoss = PositionGetDouble(POSITION_SL);
                if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                {
                    if (currentStopLoss < newStopLoss || currentStopLoss == 0)
                    {
                        if (trade.PositionModify(ticket, newStopLoss, PositionGetDouble(POSITION_TP)))
                        {
                            Print("Profit locking for buy position: Stop Loss moved to ", newStopLoss);
                        }
                    }
                }
                else // POSITION_TYPE_SELL
                {
                    if (currentStopLoss > newStopLoss || currentStopLoss == 0)
                    {
                        if (trade.PositionModify(ticket, newStopLoss, PositionGetDouble(POSITION_TP)))
                        {
                            Print("Profit locking for sell position: Stop Loss moved to ", newStopLoss);
                        }
                    }
                }
            }
        }
    }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if (UseTrendFollowingStrategy)
        CheckTrendFollowing();
    if (UseBreakoutStrategy)
        CheckBreakoutTrading();
    if (UseDivergenceStrategy)
        CheckDivergenceTrading();
    if(UseGoldenDeathCrossStrategy)
        CheckGoldenDeathCross();

}
