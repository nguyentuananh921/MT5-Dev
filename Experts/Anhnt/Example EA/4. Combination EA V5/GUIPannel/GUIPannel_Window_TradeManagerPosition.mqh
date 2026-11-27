//+------------------------------------------------------------------+
//|                       GUIPannel_Window_TradeManagerPosition.mqh |
//| The Open tab of the Trade Manage window (TAB_TRADE_OPEN_POSITION):|
//| the positions open now, one row each, newest first, from         |
//| CMarketCollection (its list is read again by the library at each |
//| refresh: the SL / TP moved by the Trailing are the ones shown).  |
//| As the History tab: the helpers of GUIPannel_Window_TradeManager |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_WINDOW_TRADEMANAGERPOSITION_MQH
#define CGUIPANNEL_WINDOW_TRADEMANAGERPOSITION_MQH
#include "GUIPannel.mqh"
 //--- The table in the Open tab
 bool CGUIPannel::CreateTable_TradeManagerPosition(void)
  {
   int no_spread[];
   if(!CreateTable_Trade(m_table_open_position,"TableOpenPosition",TAB_TRADE_OPEN_POSITION,COLUMNS_OPEN_POSITION_TOTAL,OPEN_POSITION_CAPTION,OPEN_POSITION_WIDTH,
                         OPEN_POSITION_NUMBER_COLUMNS,COL_P_DIRECTION,no_spread,COL_P_DETAIL))
      return false;
   m_table_open_position.FixedColumns(2,2,false);   // Symbol and Direction at left, Profit and Detail at right stay still while the others scroll
   this.LoadLayout_Table(m_table_open_position,this.LayoutFile_TradeManage(TAB_TRADE_OPEN_POSITION));
   return true;
  }
 //--- The positions open now, newest first: the Price is the one the position closes at (Bid for a Buy, Ask for a Sell), the Time hold runs to now
 void CGUIPannel::FillTable_TradeManagerPosition(void)
  {
   CArrayObj *list=(m_MarketCollection!=NULL ? m_MarketCollection.GetList() : NULL);
   if(list==NULL)
      return;
   long order_keys[][2];   // the open time, the index in the list
   int total=0;
   for(int i=0;i<list.Total();i++)
     {
      COrder *position=list.At(i);
      if(!m_MarketCollection.HasPosition(position))
         continue;
      ::ArrayResize(order_keys,total+1,64);
      order_keys[total][0]=position.GetProperty(ORDER_PROP_TIME_OPEN);
      order_keys[total][1]=i;
      total++;
     }
   if(total>1)
      ::ArraySort(order_keys);
   const int rows=::MathMin(total,TRADE_ROWS_MAX);
   const long now=::TimeCurrent();
   string cells[],keys[];
   ::ArrayResize(cells,rows*COLUMNS_OPEN_POSITION_TOTAL);
   ::ArrayResize(keys,rows);
   for(int row=0;row<rows;row++)
     {
      COrder *position=list.At((int)order_keys[total-1-row][1]);
      keys[row]=(string)position.GetProperty(ORDER_PROP_POSITION_ID);
      const string symbol=position.GetProperty(ORDER_PROP_SYMBOL);
      const int digits=(int)::SymbolInfoInteger(symbol,SYMBOL_DIGITS);
      const bool buy=(position.GetProperty(ORDER_PROP_TYPE)==POSITION_TYPE_BUY);
      const long t_open=position.GetProperty(ORDER_PROP_TIME_OPEN);
      const long seconds=(t_open>0 ? ::MathMax(now-t_open/1000,0) : 0);
      const double sl=position.GetProperty(ORDER_PROP_SL),tp=position.GetProperty(ORDER_PROP_TP);
      const double swap=position.GetProperty(ORDER_PROP_SWAP),profit=position.GetProperty(ORDER_PROP_PROFIT);
      string opened=::TimeToString((datetime)(t_open/1000),TIME_DATE|TIME_MINUTES);
      ::StringReplace(opened,".","-");
      int c=row*COLUMNS_OPEN_POSITION_TOTAL;
      cells[c++]=symbol;
      cells[c++]=(buy ? "BUY" : "SELL");
      cells[c++]=::DoubleToString(position.GetProperty(ORDER_PROP_VOLUME),2);
      cells[c++]=(seconds>=86400 ? (string)(seconds/86400)+"d " : "")+::StringFormat("%02d:%02d:%02d",(seconds%86400)/3600,(seconds%3600)/60,seconds%60);
      cells[c++]=(swap!=0 ? ::DoubleToString(swap,2) : "");
      cells[c++]=(string)position.GetProperty(ORDER_PROP_POSITION_ID);
      cells[c++]=(t_open>0 ? opened : "");
      cells[c++]=::DoubleToString(position.GetProperty(ORDER_PROP_PRICE_OPEN),digits);
      cells[c++]=(sl>0 ? ::DoubleToString(sl,digits) : "");
      cells[c++]=(tp>0 ? ::DoubleToString(tp,digits) : "");
      cells[c++]=::DoubleToString(::SymbolInfoDouble(symbol,(buy ? SYMBOL_BID : SYMBOL_ASK)),digits);
      cells[c++]=(profit!=0 ? ::DoubleToString(profit,2) : "");
      cells[c++]="";
     }
   //--- The same positions as shown: only the cells that changed are drawn (Price, Profit, Time hold...), not the whole table
   if(this.UpdateTable_TradeCells(m_table_open_position,cells,rows,COLUMNS_OPEN_POSITION_TOTAL,keys,m_shown_open_position,COL_P_DIRECTION,COL_P_PROFIT))
      return;
   int no_spread[];
   this.FillTable_Trade(m_table_open_position,cells,rows,COLUMNS_OPEN_POSITION_TOTAL,COL_P_SYMBOL,no_spread,WRONG_VALUE,WRONG_VALUE,WRONG_VALUE,WRONG_VALUE);
   this.FormatTradeRows(m_table_open_position,rows,COL_P_SYMBOL,COL_P_DIRECTION,COL_P_PROFIT,COL_P_DETAIL);
   m_table_open_position.View().Rebuild(true,true);
  }
#endif // CGUIPANNEL_WINDOW_TRADEMANAGERPOSITION_MQH
