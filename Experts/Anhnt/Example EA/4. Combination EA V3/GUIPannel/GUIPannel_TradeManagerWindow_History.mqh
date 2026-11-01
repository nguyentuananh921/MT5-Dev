//+------------------------------------------------------------------+
//|                           GUIPannel_TradeManagerWindow_History.mqh |
//| The History tab of the Trade Manage window (TAB_TRADE_HISTORY_  |
//| POSITION): the deals, one row each, newest first. Only deals     |
//| that were done are shown, not a pending order that was deleted  |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TRADEMANAGERWINDOW_HISTORY_MQH
#define CGUIPANNEL_TRADEMANAGERWINDOW_HISTORY_MQH
#include "GUIPannel.mqh"
 //--- The table in the History tab
 bool CGUIPannel::CreateTable_TradeHistory(void)
  {
   int no_spread[];   // the Bid and the Ask are in the Order detail window
   if(!CreateTable_Trade(m_table_trade_history,"TableTradeHistory",TAB_TRADE_HISTORY_POSITION,COLUMNS_TRADE_TOTAL,TRADE_CAPTION,TRADE_WIDTH,TRADE_NUMBER_COLUMNS,COL_T_DIRECTION,no_spread,COL_T_DETAIL))
      return false;
   m_table_trade_history.FixedColumns(2,2,false);   // Symbol and Direction at left, Profit and Detail at right stay still while the others scroll
   this.LoadLayout_Table(m_table_trade_history,TRADE_HISTORY_LAYOUT_FILE);
   return true;
  }
 //--- The trades: one row for each position that was closed (its deals grouped), newest first. The query adds its deals up: the volume, the costs and the Profit are
 //--- sums with two decimals, the prices are averages by volume, the Fee is the whole cost: a half of the spread of its deals in plus a half of the spread of its deals out (a price difference here, in money once shown) and the Commission and the Swap,
 //--- the Time hold is the Time close less the Time open; a zero is left blank. The deals themselves are in the Order detail window
 void CGUIPannel::FillTable_TradeHistory(void)
  {
   string deal_in="deal_entry=0",deal_out="deal_entry<>0";
   string seconds="CAST((t_close-t_open)/1000 AS INTEGER)";
   string sql="SELECT symbol,CASE dtype WHEN 0 THEN 'BUY' WHEN 1 THEN 'SELL' END,"
              "CASE reason WHEN 0 THEN 'CLIENT' WHEN 1 THEN 'MOBILE' WHEN 2 THEN 'WEB' WHEN 3 THEN 'EXPERT' WHEN 4 THEN 'SL' WHEN 5 THEN 'TP' WHEN 6 THEN 'SO' END,"
              "volume,"
              "(CASE WHEN "+seconds+">=86400 THEN ("+seconds+"/86400)||'d ' ELSE '' END)||printf('%02d:%02d:%02d',("+seconds+"%86400)/3600,("+seconds+"%3600)/60,"+seconds+"%60),"
              "CASE WHEN NULLIF(commission,0) IS NULL THEN NULL ELSE printf('%.2f',commission) END,CASE WHEN NULLIF(swap,0) IS NULL THEN NULL ELSE printf('%.2f',swap) END,"
              "position_id,strftime('%Y-%m-%d %H:%M',t_open/1000.0,'unixepoch'),strftime('%Y-%m-%d %H:%M',t_close/1000.0,'unixepoch'),p_open,p_close,"
              "CASE WHEN s_open IS NOT NULL AND s_close IS NOT NULL THEN s_open/2+s_close/2 END,"
              "CASE WHEN NULLIF(profit,0) IS NULL THEN NULL ELSE printf('%.2f',profit) END,'' "
              "FROM (SELECT position_id,MAX(symbol) AS symbol,MIN(CASE WHEN "+deal_in+" THEN type END) AS dtype,SUM(CASE WHEN "+deal_in+" THEN volume END) AS volume,"
              "MIN(CASE WHEN "+deal_in+" THEN time_open END) AS t_open,MAX(CASE WHEN "+deal_out+" THEN time_open END) AS t_close,"
              "ROUND(SUM(CASE WHEN "+deal_in+" THEN price_open*volume END)/SUM(CASE WHEN "+deal_in+" THEN volume END),8) AS p_open,"
              "ROUND(SUM(CASE WHEN "+deal_out+" THEN price_open*volume END)/SUM(CASE WHEN "+deal_out+" THEN volume END),8) AS p_close,"
              "SUM(commission) AS commission,SUM(swap) AS swap,SUM(profit) AS profit,"
              "AVG(CASE WHEN "+deal_in+" AND bid>0 AND ask>0 THEN ask-bid END) AS s_open,AVG(CASE WHEN "+deal_out+" AND bid>0 AND ask>0 THEN ask-bid END) AS s_close,"
              "(SELECT x.reason FROM orders x WHERE x.status=6 AND x.position_id=d.position_id AND x.deal_entry<>0 ORDER BY x.time_open DESC LIMIT 1) AS reason "
              "FROM orders d WHERE status=6 AND type IN (0,1) GROUP BY position_id HAVING SUM(CASE WHEN "+deal_out+" THEN 1 ELSE 0 END)>0 "
              "ORDER BY t_close DESC LIMIT "+(string)TRADE_ROWS_MAX+")";
   int no_spread[];
   int rows=this.FillTable_Trade(m_table_trade_history,sql,COLUMNS_TRADE_TOTAL,COL_T_SYMBOL,no_spread,COL_T_FEE,COL_T_VOLUME,COL_T_COMMISSION,COL_T_SWAP);
   if(rows==WRONG_VALUE)
      return;
   this.FormatTradeRows(m_table_trade_history,rows,COL_T_SYMBOL,COL_T_DIRECTION,COL_T_PROFIT,COL_T_DETAIL);
   m_table_trade_history.View().Rebuild(true,true);
  }
#endif // CGUIPANNEL_TRADEMANAGERWINDOW_HISTORY_MQH
