//+------------------------------------------------------------------+
//|                                     GUIPannel_Window_OrderDetail.mqh |
//| The Order detail window (m_window_order_detail): what happened to |
//| a position, one row each, oldest first: its order, each change   |
//| that was seen (TradeEvent) and its deals, with the Bid and the |
//| Ask of the moment. Any table of the panel with an order or a     |
//| position opens it with OpenOrderDetail(position_id)              |
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
   m_window_order_detail.WindowType(W_DIALOG);
   if(!m_window_order_detail.CreateWindow(this.m_chart_id,M_SUBWINDOW_MAIN,caption_text,x_gap,y_gap,M_WINDOW_ORDERDETAIL_WIDTH,M_WINDOW_ORDERDETAIL_HEIGHT))
      return false;
   return CreateTable_Trade(m_table_order_detail,"TableOrderDetail",WRONG_VALUE,COLUMNS_ORDER_DETAIL_TOTAL,ORDER_DETAIL_CAPTION,ORDER_DETAIL_WIDTH,ORDER_DETAIL_NUMBER_COLUMNS,
                            COL_O_DIRECTION,ORDER_DETAIL_SPREAD_COLUMNS,WRONG_VALUE);
  }
 //--- The Detail button of a row: the table is filled, then the window opens
 void CGUIPannel::OpenOrderDetail(const long position_id)
  {
   this.FillTable_OrderDetail(position_id);
   m_window_order_detail.OpenWindow();
   ::ChartRedraw(this.m_chart_id);
  }
 //--- The order or orders of the position, what was seen of them while a program was running, and the deals. A zero is left blank
 void CGUIPannel::FillTable_OrderDetail(const long position_id)
  {
   string p=(string)position_id;
   string spread="CASE WHEN bid>0 AND ask>0 THEN ROUND(ask-bid,8) END";
   string side="CASE WHEN type IN (0,2,4,6) THEN 'BUY' WHEN type IN (1,3,5,7) THEN 'SELL' END";   // a pending order too
   string side_event="CASE WHEN type_order_event IN (0,2,4,6) THEN 'BUY' WHEN type_order_event IN (1,3,5,7) THEN 'SELL' END";   // type of the order of the event
   string spread_event="CASE WHEN price_event_bid>0 AND price_event_ask>0 THEN ROUND(price_event_ask-price_event_bid,8) END";
   string event_name="CASE WHEN type_event="+(string)TRADE_EVENT_PENDING_ORDER_PLASED+" THEN 'PLACED' WHEN type_event="+(string)TRADE_EVENT_POSITION_OPENED+" THEN 'OPENED' "
                     "WHEN type_event="+(string)TRADE_EVENT_TRIGGERED_STOP_LIMIT_ORDER+" THEN 'TRIGGERED' WHEN type_event>="+(string)TRADE_EVENT_MODIFY_ORDER_PRICE+" THEN 'MODIFY' END";
   string sql="SELECT symbol,side,strftime('%Y-%m-%d %H:%M:%S',t/1000.0,'unixepoch'),event,price,sl,tp,volume,bid,ask,spread FROM ("
              "SELECT time_open AS t,symbol,"+side+" AS side,'ORDER' AS event,price_open AS price,NULLIF(sl,0) AS sl,NULLIF(tp,0) AS tp,volume,NULL AS bid,NULL AS ask,NULL AS spread "
              "FROM orders WHERE status IN (3,4) AND position_id="+p+" "
              "UNION ALL "
              "SELECT time_event,symbol,"+side_event+","+event_name+",price_open,NULLIF(price_sl,0),NULLIF(price_tp,0),COALESCE(volume_position_executed,volume_order_initial),"
              "NULLIF(price_event_bid,0),NULLIF(price_event_ask,0),"+spread_event+" "
              "FROM TradeEvent WHERE position_id="+p+" OR ticket_order_event="+p+" OR ticket_order_event IN (SELECT ticket FROM orders WHERE status IN (3,4) AND position_id="+p+") "
              "UNION ALL "
              "SELECT time_open,symbol,"+side+",CASE deal_entry WHEN 0 THEN 'DEAL IN' WHEN 1 THEN 'DEAL OUT' WHEN 2 THEN 'DEAL IN/OUT' ELSE 'DEAL OUT BY' END,price_open,NULLIF(sl,0),NULLIF(tp,0),volume,NULLIF(bid,0),NULLIF(ask,0),"+spread+" "
              "FROM orders WHERE status=6 AND type IN (0,1) AND position_id="+p+
              ") ORDER BY t LIMIT "+(string)ORDER_DETAIL_ROWS_MAX;
   int rows=this.FillTable_Trade(m_table_order_detail,sql,COLUMNS_ORDER_DETAIL_TOTAL,COL_O_SYMBOL,ORDER_DETAIL_SPREAD_COLUMNS,WRONG_VALUE,WRONG_VALUE,WRONG_VALUE,WRONG_VALUE);
   if(rows==WRONG_VALUE)
      return;
   this.FormatTradeRows(m_table_order_detail,rows,COL_O_SYMBOL,COL_O_DIRECTION,WRONG_VALUE,WRONG_VALUE);
   m_table_order_detail.View().Rebuild(true,true);
  }
#endif // CGUIPANNEL_WINDOW_ORDERDETAIL_MQH
