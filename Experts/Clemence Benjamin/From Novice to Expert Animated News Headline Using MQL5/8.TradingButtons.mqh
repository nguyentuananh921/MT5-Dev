//+------------------------------------------------------------------+
//|                                             TradingButtons.mqh   |
//+------------------------------------------------------------------+
//|                        Copyright 2025, Clemence Benjamin         |
//|             https://www.mql5.com/en/users/billionaire2024/seller |
//+------------------------------------------------------------------+
//|   From Novice to Expert: Animated News Headline Using MQL5       |
//|                      VIII:Quick Trade Buttons for News Trading   |
//|                        https://www.mql5.com/en/articles/18975    |
//+------------------------------------------------------------------+
#property copyright "Clemence Benjamin"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property strict

#include <Controls\Button.mqh>
#include <Trade\Trade.mqh>
#include <Canvas\Canvas.mqh>

//+------------------------------------------------------------------+
//| CTradingButtons Class                                            |
//+------------------------------------------------------------------+
class CTradingButtons
{
private:
   CButton btnBuy, btnSell, btnCloseAll, btnDeleteOrders, btnCloseProfit, btnCloseLoss, btnBuyStop, btnSellStop;
   CCanvas buttonPanel;
   CTrade  trade;
   int     buttonWidth;
   int     buttonHeight;
   int     buttonSpacing;

public:
   double LotSize;
   int    StopLoss;
   int    TakeProfit;
   int    StopOrderDistancePips;
   double RiskRewardRatio;

   CTradingButtons() : buttonWidth(100), buttonHeight(30), buttonSpacing(10),
                      LotSize(0.1), StopLoss(50), TakeProfit(100),
                      StopOrderDistancePips(8), RiskRewardRatio(2.0) {}

   void Init()
   {
      trade.SetExpertMagicNumber(123456);
      trade.SetDeviationInPoints(10);
      trade.SetTypeFillingBySymbol(_Symbol);
      CreateButtonPanel();
      CreateButtons();
   }

   void Deinit()
   {
      btnBuy.Destroy();
      btnSell.Destroy();
      btnCloseAll.Destroy();
      btnDeleteOrders.Destroy();
      btnCloseProfit.Destroy();
      btnCloseLoss.Destroy();
      btnBuyStop.Destroy();
      btnSellStop.Destroy();
      buttonPanel.Destroy();
      ObjectDelete(0, "ButtonPanel");
   }

   void HandleChartEvent(const int id, const string &sparam)
   {
      if(id == CHARTEVENT_OBJECT_CLICK)
      {
         if(sparam == btnBuy.Name())
            OpenBuyOrder();
         else if(sparam == btnSell.Name())
            OpenSellOrder();
         else if(sparam == btnCloseAll.Name())
            CloseAllPositions();
         else if(sparam == btnDeleteOrders.Name())
            DeleteAllPendingOrders();
         else if(sparam == btnCloseProfit.Name())
            CloseProfitablePositions();
         else if(sparam == btnCloseLoss.Name())
            CloseLosingPositions();
         else if(sparam == btnBuyStop.Name())
            PlaceBuyStop();
         else if(sparam == btnSellStop.Name())
            PlaceSellStop();
      }
   }

private:
   void CreateButtonPanel()
   {
      int panelWidth = buttonWidth + 20;
      int panelHeight = (buttonHeight + buttonSpacing) * 8 + buttonSpacing + 40;
      int x = 0;
      int y = 40;

      if(!buttonPanel.CreateBitmap(0, 0, "ButtonPanel", x, y, panelWidth, panelHeight, COLOR_FORMAT_ARGB_NORMALIZE))
      {
         Print("Failed to create button panel: Error=", GetLastError());
         return;
      }

      ObjectSetInteger(0, "ButtonPanel", OBJPROP_ZORDER, 10);
      buttonPanel.FillRectangle(0, 0, panelWidth, panelHeight, ColorToARGB(clrDarkGray, 200));
      buttonPanel.Rectangle(0, 0, panelWidth - 1, panelHeight - 1, ColorToARGB(clrRed, 255));
      buttonPanel.Rectangle(1, 1, panelWidth - 2, panelHeight - 2, ColorToARGB(clrRed, 255));
      buttonPanel.FillRectangle(0, 0, 20, 20, ColorToARGB(clrYellow, 255));
      buttonPanel.Update(true);
      ChartRedraw(0);
      Print("Button panel created at x=", x, ", y=", y, ", width=", panelWidth, ", height=", panelHeight, ", ZOrder=10, ChartID=", ChartID());
      Print("Chart Foreground: ", ChartGetInteger(0, CHART_FOREGROUND, 0), ", Chart Show: ", ChartGetInteger(0, CHART_SHOW, 0));
   }

   void CreateButtons()
   {
      int x = 10;
      int y = 160;
      string font = "Calibri";
      int fontSize = 8;
      color buttonBgColor = clrBlack; // Button background color

      btnBuy.Create(0, "btnBuy", 0, x, y, x + buttonWidth, y + buttonHeight);
      btnBuy.Text("Buy");
      btnBuy.Font(font);
      btnBuy.FontSize(fontSize);
      btnBuy.ColorBackground(buttonBgColor);
      btnBuy.Color(clrLime); // Bright green text
      ObjectSetInteger(0, "btnBuy", OBJPROP_ZORDER, 11);

      y += buttonHeight + buttonSpacing;
      btnSell.Create(0, "btnSell", 0, x, y, x + buttonWidth, y + buttonHeight);
      btnSell.Text("Sell");
      btnSell.Font(font);
      btnSell.FontSize(fontSize);
      btnSell.ColorBackground(buttonBgColor);
      btnSell.Color(clrRed); // Bright red text
      ObjectSetInteger(0, "btnSell", OBJPROP_ZORDER, 11);

      y += buttonHeight + buttonSpacing;
      btnCloseAll.Create(0, "btnCloseAll", 0, x, y, x + buttonWidth, y + buttonHeight);
      btnCloseAll.Text("Close All");
      btnCloseAll.Font(font);
      btnCloseAll.FontSize(fontSize);
      btnCloseAll.ColorBackground(buttonBgColor);
      btnCloseAll.Color(clrYellow); // Bright yellow text
      ObjectSetInteger(0, "btnCloseAll", OBJPROP_ZORDER, 11);

      y += buttonHeight + buttonSpacing;
      btnDeleteOrders.Create(0, "btnDeleteOrders", 0, x, y, x + buttonWidth, y + buttonHeight);
      btnDeleteOrders.Text("Delete Orders");
      btnDeleteOrders.Font(font);
      btnDeleteOrders.FontSize(fontSize);
      btnDeleteOrders.ColorBackground(buttonBgColor);
      btnDeleteOrders.Color(clrAqua); // Bright cyan text
      ObjectSetInteger(0, "btnDeleteOrders", OBJPROP_ZORDER, 11);

      y += buttonHeight + buttonSpacing;
      btnCloseProfit.Create(0, "btnCloseProfit", 0, x, y, x + buttonWidth, y + buttonHeight);
      btnCloseProfit.Text("Close Profit");
      btnCloseProfit.Font(font);
      btnCloseProfit.FontSize(fontSize);
      btnCloseProfit.ColorBackground(buttonBgColor);
      btnCloseProfit.Color(clrGold); // Bright gold text
      ObjectSetInteger(0, "btnCloseProfit", OBJPROP_ZORDER, 11);

      y += buttonHeight + buttonSpacing;
      btnCloseLoss.Create(0, "btnCloseLoss", 0, x, y, x + buttonWidth, y + buttonHeight);
      btnCloseLoss.Text("Close Loss");
      btnCloseLoss.Font(font);
      btnCloseLoss.FontSize(fontSize);
      btnCloseLoss.ColorBackground(buttonBgColor);
      btnCloseLoss.Color(clrOrange); // Bright orange text
      ObjectSetInteger(0, "btnCloseLoss", OBJPROP_ZORDER, 11);

      y += buttonHeight + buttonSpacing;
      btnBuyStop.Create(0, "btnBuyStop", 0, x, y, x + buttonWidth, y + buttonHeight);
      btnBuyStop.Text("Buy Stop");
      btnBuyStop.Font(font);
      btnBuyStop.FontSize(fontSize);
      btnBuyStop.ColorBackground(buttonBgColor);
      btnBuyStop.Color(clrLightPink); // Bright pink text
      ObjectSetInteger(0, "btnBuyStop", OBJPROP_ZORDER, 11);

      y += buttonHeight + buttonSpacing;
      btnSellStop.Create(0, "btnSellStop", 0, x, y, x + buttonWidth, y + buttonHeight);
      btnSellStop.Text("Sell Stop");
      btnSellStop.Font(font);
      btnSellStop.FontSize(fontSize);
      btnSellStop.ColorBackground(buttonBgColor);
      btnSellStop.Color(clrLightCoral); // Bright coral text
      ObjectSetInteger(0, "btnSellStop", OBJPROP_ZORDER, 11);
   }

   double PipSize()
   {
      return SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10.0;
   }

   void OpenBuyOrder()
   {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double sl = StopLoss > 0 ? price - StopLoss * Point() : 0;
      double tp = TakeProfit > 0 ? price + TakeProfit * Point() : 0;

      if(trade.Buy(LotSize, _Symbol, price, sl, tp))
         Print("Manual Buy order placed: Ticket #", trade.ResultOrder());
      else
         Print("Manual Buy order failed: Retcode=", trade.ResultRetcode(), ", Comment=", trade.ResultComment());
   }

   void OpenSellOrder()
   {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double sl = StopLoss > 0 ? price + StopLoss * Point() : 0;
      double tp = TakeProfit > 0 ? price - TakeProfit * Point() : 0;

      if(trade.Sell(LotSize, _Symbol, price, sl, tp))
         Print("Manual Sell order placed: Ticket #", trade.ResultOrder());
      else
         Print("Manual Sell order failed: Retcode=", trade.ResultRetcode(), ", Comment=", trade.ResultComment());
   }

   void CloseAllPositions()
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            if(trade.PositionClose(ticket))
               Print("Manual Position closed: Ticket #", ticket);
            else
               Print("Manual Close position failed: Retcode=", trade.ResultRetcode(), ", Comment=", trade.ResultComment());
         }
      }
   }

   void DeleteAllPendingOrders()
   {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol)
         {
            if(trade.OrderDelete(ticket))
               Print("Manual Pending order deleted: Ticket #", ticket);
            else
               Print("Manual Delete pending order failed: Retcode=", trade.ResultRetcode(), ", Comment=", trade.ResultComment());
         }
      }
   }

   void CloseProfitablePositions()
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double profit = PositionGetDouble(POSITION_PROFIT);
            if(profit > 0)
            {
               if(trade.PositionClose(ticket))
                  Print("Manual Profitable position closed: Ticket #", ticket);
               else
                  Print("Manual Close profitable position failed: Retcode=", trade.ResultRetcode(), ", Comment=", trade.ResultComment());
            }
         }
      }
   }

   void CloseLosingPositions()
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double profit = PositionGetDouble(POSITION_PROFIT);
            if(profit < 0)
            {
               if(trade.PositionClose(ticket))
                  Print("Manual Losing position closed: Ticket #", ticket);
               else
                  Print("Manual Close losing position failed: Retcode=", trade.ResultRetcode(), ", Comment=", trade.ResultComment());
            }
         }
      }
   }

   void PlaceBuyStop()
   {
      double pip = PipSize();
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

      long tradeMode = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE);
      if(tradeMode != SYMBOL_TRADE_MODE_FULL)
      {
         Print("Manual Trading disabled for symbol: TradeMode=", tradeMode);
         return;
      }

      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      if(LotSize < minLot || LotSize > maxLot)
      {
         Print("Manual Invalid lot size: ", LotSize, " (min: ", minLot, ", max: ", maxLot, ")");
         return;
      }

      double entry = ask + StopOrderDistancePips * pip;
      double sl = ask;
      double tp = RiskRewardRatio > 0 ? entry + StopOrderDistancePips * RiskRewardRatio * pip : 0;

      entry = NormalizeDouble(entry, _Digits);
      sl = NormalizeDouble(sl, _Digits);
      tp = NormalizeDouble(tp, _Digits);

      if(trade.BuyStop(LotSize, entry, _Symbol, sl, tp))
         Print("Manual Buy Stop order placed: Ticket #", trade.ResultOrder(), ", Price=", entry, ", SL=", sl, ", TP=", tp);
      else
         Print("Manual Buy Stop order failed: Retcode=", trade.ResultRetcode(), ", Comment=", trade.ResultComment());
   }

   void PlaceSellStop()
   {
      double pip = PipSize();
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

      long tradeMode = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE);
      if(tradeMode != SYMBOL_TRADE_MODE_FULL)
      {
         Print("Manual Trading disabled for symbol: TradeMode=", tradeMode);
         return;
      }

      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      if(LotSize < minLot || LotSize > maxLot)
      {
         Print("Manual Invalid lot size: ", LotSize, " (min: ", minLot, ", max: ", maxLot, ")");
         return;
      }

      double entry = bid - StopOrderDistancePips * pip;
      double sl = bid;
      double tp = RiskRewardRatio > 0 ? entry - StopOrderDistancePips * RiskRewardRatio * pip : 0;

      entry = NormalizeDouble(entry, _Digits);
      sl = NormalizeDouble(sl, _Digits);
      tp = NormalizeDouble(tp, _Digits);

      if(trade.SellStop(LotSize, entry, _Symbol, sl, tp))
         Print("Manual Sell Stop order placed: Ticket #", trade.ResultOrder(), ", Price=", entry, ", SL=", sl, ", TP=", tp);
      else
         Print("Manual Sell Stop order failed: Retcode=", trade.ResultRetcode(), ", Comment=", trade.ResultComment());
   }
};