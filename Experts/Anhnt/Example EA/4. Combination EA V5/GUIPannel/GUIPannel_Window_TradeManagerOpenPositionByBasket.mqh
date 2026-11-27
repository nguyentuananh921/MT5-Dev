//+------------------------------------------------------------------+
//|          GUIPannel_Window_TradeManagerOpenPositionByBasket.mqh |
//| The By Basket tab of the Trade Manage window                     |
//| (TAB_TRADE_OPEN_POSITION_BY_BASKET): one row for each basket open|
//| now (Concepts.md, Phạm vi: a symbol and a side, every magic).    |
//| The View only shows: the baskets from CMarketCollection          |
//| (GetDistinctSymbolsAndDirections, BasketState), the BasketID on  |
//| RAM from CTradingControl::BasketId. As the Open tab: the helpers |
//| of GUIPannel_Window_TradeManager                                 |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_WINDOW_TRADEMANAGEROPENPOSITIONBYBASKET_MQH
#define CGUIPANNEL_WINDOW_TRADEMANAGEROPENPOSITIONBYBASKET_MQH
#include "GUIPannel.mqh"
 //--- The table in the By Basket tab
 bool CGUIPannel::CreateTable_TradeManagerOpenPositionByBasket(void)
  {
   int no_spread[];
   if(!CreateTable_Trade(m_table_open_position_by_basket,"TableOpenPositionByBasket",TAB_TRADE_OPEN_POSITION_BY_BASKET,COLUMNS_BASKET_TOTAL,BASKET_CAPTION,BASKET_WIDTH,
                         BASKET_NUMBER_COLUMNS,COL_B_DIRECTION,no_spread,WRONG_VALUE))
      return false;
   m_table_open_position_by_basket.FixedColumns(2,3,false);   // Symbol and Direction at left, Profit, Manage, Close at right stay still while the others scroll
   this.LoadLayout_Table(m_table_open_position_by_basket,this.LayoutFile_TradeManage(TAB_TRADE_OPEN_POSITION_BY_BASKET));
   return true;
  }
 //--- The baskets open now: the Price is the one the basket closes at (Bid for a Buy, Ask for a Sell); the Time open is the one of its oldest position
 void CGUIPannel::FillTable_TradeManagerOpenPositionByBasket(void)
  {
   CArrayObj *list=(m_MarketCollection!=NULL ? m_MarketCollection.GetList() : NULL);
   if(list==NULL)
      return;
   CAccount *account=(m_AccountsCollection!=NULL ? m_AccountsCollection.GetCurrentAccount() : NULL);
   string symbols[];
   ENUM_POSITION_TYPE dirs[];
   const int baskets=m_MarketCollection.GetDistinctSymbolsAndDirections(symbols,dirs);
   string cells[],keys[];
   ::ArrayResize(cells,baskets*COLUMNS_BASKET_TOTAL);
   ::ArrayResize(keys,baskets);
   int rows=0;
   for(int b=0;b<baskets;b++)
     {
      SBasketState state;
      if(!m_MarketCollection.BasketState(symbols[b],(ENUM_ORDER_TYPE)dirs[b],0,account,state))
         continue;
      //--- Its BasketID: the one of any of its positions (they share it)
      long basket_id=0;
      for(int i=0;i<list.Total() && basket_id==0 && m_TradingControl!=NULL;i++)
        {
         COrder *position=list.At(i);
         if(m_MarketCollection.HasPosition(position,symbols[b],dirs[b]))
            basket_id=m_TradingControl.BasketId(position.PositionID());
        }
      const int digits=(int)::SymbolInfoInteger(symbols[b],SYMBOL_DIGITS);
      const bool buy=(dirs[b]==POSITION_TYPE_BUY);
      string opened=::TimeToString(state.oldestOpenTime,TIME_DATE|TIME_MINUTES);
      ::StringReplace(opened,".","-");
      keys[rows]=symbols[b]+(buy ? " BUY" : " SELL");
      int c=rows*COLUMNS_BASKET_TOTAL;
      cells[c++]=symbols[b];
      cells[c++]=(buy ? "BUY" : "SELL");
      cells[c++]=(basket_id!=0 ? (string)basket_id : "");
      cells[c++]=(string)state.positionCount;
      cells[c++]=::DoubleToString(state.totalVolume,2);
      cells[c++]=(state.oldestOpenTime>0 ? opened : "");
      cells[c++]=::DoubleToString(state.weightedEntryPrice,digits);
      cells[c++]=::DoubleToString(::SymbolInfoDouble(symbols[b],(buy ? SYMBOL_BID : SYMBOL_ASK)),digits);
      cells[c++]=(state.usedMargin!=0 ? ::DoubleToString(state.usedMargin,2) : "");
      cells[c++]=(state.floatingPL!=0 ? ::DoubleToString(state.floatingPL,2) : "");
      cells[c++]="";   // Manage, Close: buttons, a picture each
      cells[c++]="";
      rows++;
     }
   //--- The same baskets as shown: only the cells that changed are drawn (Price, Margin, Profit...), not the whole table
   ::ArrayResize(keys,rows);
   if(this.UpdateTable_TradeCells(m_table_open_position_by_basket,cells,rows,COLUMNS_BASKET_TOTAL,keys,m_shown_open_position_by_basket,COL_B_DIRECTION,COL_B_PROFIT))
      return;
   int no_spread[];
   this.FillTable_Trade(m_table_open_position_by_basket,cells,rows,COLUMNS_BASKET_TOTAL,COL_B_SYMBOL,no_spread,WRONG_VALUE,WRONG_VALUE,WRONG_VALUE,WRONG_VALUE);
   this.FormatTradeRows(m_table_open_position_by_basket,rows,COL_B_SYMBOL,COL_B_DIRECTION,COL_B_PROFIT,WRONG_VALUE);
   //--- New 2026-11-27: the two buttons of each row (OnEvent_Window_TradeManage hears them)
   uint manage_img[]={IMAGE_RESOURCE_BMP16_SETTING_PNG};
   uint close_img[]={IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
   for(int row=0;row<rows;row++)
     {
      CTableCellView *manage=m_table_open_position_by_basket.CellView(COL_B_MANAGE,row);
      CTableCellView *close=m_table_open_position_by_basket.CellView(COL_B_CLOSE,row);
      if(manage!=NULL)
        {
         manage.CellType(CELL_BUTTON);
         manage.SetImages(manage_img);
        }
      if(close!=NULL)
        {
         close.CellType(CELL_BUTTON);
         close.SetImages(close_img);
        }
     }
   m_table_open_position_by_basket.View().Rebuild(true,true);
  }
 //+------------------------------------------------------------------+
 //| New 2026-11-27: Manage of a row: the box of the basket. Another  |
 //| symbol: the chart moves there first (the way of the combobox of  |
 //| the symbols), the box shows at OnInit of the chart change        |
 //+------------------------------------------------------------------+
 void CGUIPannel::ManageBasket(const string symbol,const bool buy)
  {
   m_box_basket_symbol=symbol;
   m_box_basket_buy=buy;
   if(symbol==::Symbol())
     {
      this.ShowBox_Basket();
      return;
     }
   m_box_basket.Hide();   // it belongs to the symbol of the chart now
   if(m_SymbolTFManager!=NULL)
      m_SymbolTFManager.Update_SymbolTF_Setting(symbol,(ENUM_TIMEFRAMES)::Period(),SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED);
  }
 //+------------------------------------------------------------------+
 //| The box shows the basket waiting (m_box_basket_symbol) when the  |
 //| chart is on its symbol: the entry is the close price now (Bid /  |
 //| Ask, so the SL / TP are on the side the broker asks), the stop   |
 //| CTradingControl::BasketStop, the lots the volume of the basket   |
 //| (the money at the SL / TP). Starts 20 bars back, 30 bars wide    |
 //+------------------------------------------------------------------+
 void CGUIPannel::ShowBox_Basket(void)
  {
   const string symbol=m_box_basket_symbol;
   if(symbol=="" || symbol!=::Symbol() || m_MarketCollection==NULL || m_TradingControl==NULL)
      return;
   m_box_basket_symbol="";   // shown once: a later chart change does not show it again
   const ENUM_ORDER_TYPE type=(m_box_basket_buy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   CAccount *account=(m_AccountsCollection!=NULL ? m_AccountsCollection.GetCurrentAccount() : NULL);
   SBasketState state;
   if(!m_MarketCollection.BasketState(symbol,type,0,account,state) || state.positionCount==0)
     {
      ::Print(__FUNCTION__," > no basket ",symbol," ",(m_box_basket_buy ? "BUY" : "SELL")," open now");
      return;
     }
   const double entry=::SymbolInfoDouble(symbol,(m_box_basket_buy ? SYMBOL_BID : SYMBOL_ASK));
   const double stop=m_TradingControl.BasketStop(symbol,type);
   m_box_basket.Hide();
   m_box_basket.Setup(::iTime(symbol,::Period(),20),30,entry,stop);
   m_box_basket.SetLots(state.totalVolume);
   m_box_basket.Show();
   ::ChartRedraw(this.m_chart_id);
  }
#endif // CGUIPANNEL_WINDOW_TRADEMANAGEROPENPOSITIONBYBASKET_MQH
