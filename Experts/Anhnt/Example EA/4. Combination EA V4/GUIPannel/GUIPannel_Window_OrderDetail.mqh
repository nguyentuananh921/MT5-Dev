//+------------------------------------------------------------------+
//|                                     GUIPannel_Window_OrderDetail.mqh |
//| The Order detail window (m_window_order_detail): what happened to |
//| a position, one row each, oldest first: its order, each change   |
//| that the terminal has: its orders and its deals (the list of     |
//| CHistoryCollection), with the Bid and the Ask of a deal. Any table of the|
//| panel with an order or a position opens it with                  |
//| OpenWindow_OrderDetail(position_id)                              |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_WINDOW_ORDERDETAIL_MQH
#define CGUIPANNEL_WINDOW_ORDERDETAIL_MQH
#include "GUIPannel.mqh"
 //--- The window, born hidden, with its table
 bool CGUIPannel::CreateWindow_OrderDetail(const string caption_text,const int x_gap,const int y_gap)
  {
   m_window_order_detail.FontSize(DEF_FONT_SIZE);
   m_window_order_detail.IsMovable(true);
   m_window_order_detail.ResizeMode(true);
   m_window_order_detail.CloseButtonIsUsed(true);
   m_window_order_detail.CollapseButtonIsUsed(true);
   m_window_order_detail.TooltipsButtonIsUsed(false);
   m_window_order_detail.FullscreenButtonIsUsed(false);
   m_window_order_detail.SetObjectType(OBJECT_DE_TYPE_GUICONTROL_WINDOW_DIALOG);
   if(!m_window_order_detail.CreateWindow(this.m_chart_id,M_SUBWINDOW_MAIN,caption_text,x_gap,y_gap,M_WINDOW_ORDERDETAIL_WIDTH,M_WINDOW_ORDERDETAIL_HEIGHT))
      return false;
   return CreateTable_Trade(m_table_order_detail,"TableOrderDetail",WRONG_VALUE,COLUMNS_ORDER_DETAIL_TOTAL,ORDER_DETAIL_CAPTION,ORDER_DETAIL_WIDTH,ORDER_DETAIL_NUMBER_COLUMNS,
                            COL_O_DIRECTION,ORDER_DETAIL_SPREAD_COLUMNS,WRONG_VALUE);
  }
 //--- The Detail button of a row: the table is filled, then the window opens
 void CGUIPannel::OpenWindow_OrderDetail(const long position_id)
  {
   this.FillTable_OrderDetail(position_id);
   m_window_order_detail.OpenWindow();
   ::ChartRedraw(this.m_chart_id);
  }
 //--- The orders and the deals of the position, oldest first (live from the terminal). A zero is left blank
 void CGUIPannel::FillTable_OrderDetail(const long position_id)
  {
   CArrayObj *list=(m_HistoryCollection!=NULL ? m_HistoryCollection.GetList() : NULL);
   if(list==NULL)
      return;
   long keys[][2];   // the time, the index in the list
   int found=0;
   for(int i=0;i<list.Total();i++)
     {
      COrder *order=list.At(i);
      if(order==NULL || order.GetProperty(ORDER_PROP_POSITION_ID)!=position_id)
         continue;
      const long status=order.GetProperty(ORDER_PROP_STATUS);
      if(status!=ORDER_STATUS_HISTORY_ORDER && status!=ORDER_STATUS_HISTORY_PENDING && status!=ORDER_STATUS_DEAL)
         continue;
      if(status==ORDER_STATUS_DEAL && order.GetProperty(ORDER_PROP_TYPE)>ORDER_TYPE_SELL)
         continue;
      ::ArrayResize(keys,found+1);
      keys[found][0]=order.GetProperty(ORDER_PROP_TIME_OPEN);
      keys[found][1]=i;
      found++;
     }
   if(found>1)
      ::ArraySort(keys);
   int rows=::MathMin(found,ORDER_DETAIL_ROWS_MAX);
   string cells[];
   ::ArrayResize(cells,rows*COLUMNS_ORDER_DETAIL_TOTAL);
   for(int row=0;row<rows;row++)
     {
      COrder *order=list.At((int)keys[row][1]);
      const bool deal=(order.GetProperty(ORDER_PROP_STATUS)==ORDER_STATUS_DEAL);
      if(deal && order.GetProperty(ORDER_PROP_BID)==0)
         order.BidAskFromTicks();   // the tick of its time, kept on RAM
      const string symbol=order.GetProperty(ORDER_PROP_SYMBOL);
      const int digits=(int)::SymbolInfoInteger(symbol,SYMBOL_DIGITS);
      const long type=order.GetProperty(ORDER_PROP_TYPE);
      const long entry=order.GetProperty(ORDER_PROP_DEAL_ENTRY);
      const double sl=order.GetProperty(ORDER_PROP_SL),tp=order.GetProperty(ORDER_PROP_TP),bid=order.GetProperty(ORDER_PROP_BID),ask=order.GetProperty(ORDER_PROP_ASK);
      string time=::TimeToString((datetime)(keys[row][0]/1000),TIME_DATE|TIME_SECONDS);
      ::StringReplace(time,".","-");
      int c=row*COLUMNS_ORDER_DETAIL_TOTAL;
      cells[c++]=symbol;
      cells[c++]=(type==ORDER_TYPE_BUY || type==ORDER_TYPE_BUY_LIMIT || type==ORDER_TYPE_BUY_STOP || type==ORDER_TYPE_BUY_STOP_LIMIT ? "BUY" : "SELL");   // a pending order too
      cells[c++]=time;
      cells[c++]=(!deal ? "ORDER" : entry==DEAL_ENTRY_IN ? "DEAL IN" : entry==DEAL_ENTRY_OUT ? "DEAL OUT" : entry==DEAL_ENTRY_INOUT ? "DEAL IN/OUT" : "DEAL OUT BY");
      cells[c++]=::DoubleToString(order.GetProperty(ORDER_PROP_PRICE_OPEN),digits);
      cells[c++]=(sl!=0 ? ::DoubleToString(sl,digits) : "");
      cells[c++]=(tp!=0 ? ::DoubleToString(tp,digits) : "");
      cells[c++]=::DoubleToString(order.GetProperty(ORDER_PROP_VOLUME),2);
      cells[c++]=(deal && bid>0 ? ::DoubleToString(bid,digits) : "");
      cells[c++]=(deal && ask>0 ? ::DoubleToString(ask,digits) : "");
      cells[c++]=(deal && bid>0 && ask>0 ? ::DoubleToString(ask-bid,8) : "");
     }
   this.FillTable_Trade(m_table_order_detail,cells,rows,COLUMNS_ORDER_DETAIL_TOTAL,COL_O_SYMBOL,ORDER_DETAIL_SPREAD_COLUMNS,WRONG_VALUE,WRONG_VALUE,WRONG_VALUE,WRONG_VALUE);
   this.FormatTradeRows(m_table_order_detail,rows,COL_O_SYMBOL,COL_O_DIRECTION,WRONG_VALUE,WRONG_VALUE);
   m_table_order_detail.View().Rebuild(true,true);
  }
#endif // CGUIPANNEL_WINDOW_ORDERDETAIL_MQH
