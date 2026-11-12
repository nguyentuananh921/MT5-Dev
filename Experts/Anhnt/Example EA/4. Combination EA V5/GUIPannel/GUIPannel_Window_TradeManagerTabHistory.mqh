//+------------------------------------------------------------------+
//|                         GUIPannel_Window_TradeManagerTabHistory.mqh |
//| The History tab of the Trade Manage window (TAB_TRADE_HISTORY_   |
//| POSITION): the trades, one row for each position that was closed,|
//| newest first, from the deals of CHistoryCollection. A pending    |
//| order that was deleted is not a trade: it is not shown           |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_WINDOW_TRADEMANAGERTABHISTORY_MQH
#define CGUIPANNEL_WINDOW_TRADEMANAGERTABHISTORY_MQH
#include "GUIPannel.mqh"
 //--- The table in the History tab
 bool CGUIPannel::CreateTable_TradeManagerTabHistory(void)
  {
   int no_spread[];   // the Bid and the Ask are in the Order detail window
   if(!CreateTable_Trade(m_table_trade_history,"TableTradeHistory",TAB_TRADE_HISTORY_POSITION,COLUMNS_TRADE_TOTAL,TRADE_CAPTION,TRADE_WIDTH,TRADE_NUMBER_COLUMNS,COL_T_DIRECTION,no_spread,COL_T_DETAIL))
      return false;
   m_table_trade_history.FixedColumns(2,2,false);   // Symbol and Direction at left, Profit and Detail at right stay still while the others scroll
   //--- The Reason is an icon: no text in its header (the caption stays for the window of the columns), a filter on it, and a tooltip for each icon
   m_table_trade_history.View().GetHeaderViewPointer().CaptionVisible(COL_T_REASON,false);
   m_table_trade_history.ColumnContentAlign(COL_T_REASON,ALIGN_CENTER);
   m_table_trade_history.View().IsFilterMode(COL_T_REASON,true);
   m_table_trade_history.View().ColumnTooltips(COL_T_REASON,TRADE_REASON_VALUE,TRADE_REASON_TOOLTIP);
   m_table_trade_history.View().Rebuild(true);
   this.LoadLayout_Table(m_table_trade_history,this.LayoutFile_TradeManage(TAB_TRADE_HISTORY_POSITION));
   return true;
  }
 //--- The trades: one row for each position that was closed (its deals grouped), newest first. The query adds its deals up: the volume, the costs and the Profit are
 //--- sums with two decimals, the prices are averages by volume, the Fee is the whole cost: a half of the spread of its deals in plus a half of the spread of its deals out (a price difference here, in money once shown) and the Commission and the Swap,
 //--- the Time hold is the Time close less the Time open; a zero is left blank. The deals themselves are in the Order detail window
 void CGUIPannel::FillTable_TradeManagerTabHistory(void)
  {
   CArrayObj *list=(m_HistoryCollection!=NULL ? m_HistoryCollection.GetList() : NULL);
   if(list==NULL)
      return;
   //--- The positions of the deals, sorted: the index of a position is found by its id
   long ids[];
   int deals=0;
   for(int i=0;i<list.Total();i++)
     {
      COrder *deal=list.At(i);
      if(deal==NULL || deal.GetProperty(ORDER_PROP_STATUS)!=ORDER_STATUS_DEAL || deal.GetProperty(ORDER_PROP_TYPE)>ORDER_TYPE_SELL)
         continue;
      ::ArrayResize(ids,deals+1,1024);
      ids[deals++]=deal.GetProperty(ORDER_PROP_POSITION_ID);
     }
   int total=0;
   if(deals>0)
      ::ArraySort(ids);
   for(int i=0;i<deals;i++)
      if(i==0 || ids[i]!=ids[i-1])
         ids[total++]=ids[i];
   ::ArrayResize(ids,total);
   string symbols[];
   long types[],t_open[],t_close[],reasons[];
   double vol_in[],vol_out[],value_in[],value_out[],commission[],swap[],profit[],s_in[],s_out[];
   int n_in[],n_out[];
   ::ArrayResize(symbols,total);
   ::ArrayResize(types,total);
   ::ArrayResize(t_open,total);
   ::ArrayResize(t_close,total);
   ::ArrayResize(reasons,total);
   ::ArrayResize(vol_in,total);
   ::ArrayResize(vol_out,total);
   ::ArrayResize(value_in,total);
   ::ArrayResize(value_out,total);
   ::ArrayResize(commission,total);
   ::ArrayResize(swap,total);
   ::ArrayResize(profit,total);
   ::ArrayResize(s_in,total);
   ::ArrayResize(s_out,total);
   ::ArrayResize(n_in,total);
   ::ArrayResize(n_out,total);
   if(total>0)
     {
      ::ArrayInitialize(t_open,0);
      ::ArrayInitialize(t_close,0);
      ::ArrayInitialize(types,-1);
      ::ArrayInitialize(reasons,-1);
      ::ArrayInitialize(vol_in,0);
      ::ArrayInitialize(vol_out,0);
      ::ArrayInitialize(value_in,0);
      ::ArrayInitialize(value_out,0);
      ::ArrayInitialize(commission,0);
      ::ArrayInitialize(swap,0);
      ::ArrayInitialize(profit,0);
      ::ArrayInitialize(s_in,0);
      ::ArrayInitialize(s_out,0);
      ::ArrayInitialize(n_in,0);
      ::ArrayInitialize(n_out,0);
     }
   int closed=0;
   for(int i=0;i<list.Total() && total>0;i++)
     {
      COrder *deal=list.At(i);
      if(deal==NULL || deal.GetProperty(ORDER_PROP_STATUS)!=ORDER_STATUS_DEAL || deal.GetProperty(ORDER_PROP_TYPE)>ORDER_TYPE_SELL)
         continue;
      int k=::ArrayBsearch(ids,deal.GetProperty(ORDER_PROP_POSITION_ID));
      const long time=deal.GetProperty(ORDER_PROP_TIME_OPEN);
      const double volume=deal.GetProperty(ORDER_PROP_VOLUME),price=deal.GetProperty(ORDER_PROP_PRICE_OPEN);
      const double bid=deal.GetProperty(ORDER_PROP_BID),ask=deal.GetProperty(ORDER_PROP_ASK);
      symbols[k]=deal.GetProperty(ORDER_PROP_SYMBOL);
      commission[k]+=deal.GetProperty(ORDER_PROP_COMMISSION);
      swap[k]+=deal.GetProperty(ORDER_PROP_SWAP);
      profit[k]+=deal.GetProperty(ORDER_PROP_PROFIT);
      if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_IN)
        {
         if(t_open[k]==0 || time<t_open[k])
            t_open[k]=time;
         if(types[k]<0 || deal.GetProperty(ORDER_PROP_TYPE)<types[k])
            types[k]=deal.GetProperty(ORDER_PROP_TYPE);
         vol_in[k]+=volume;
         value_in[k]+=price*volume;
         if(bid>0 && ask>0)
           {
            s_in[k]+=ask-bid;
            n_in[k]++;
           }
        }
      else
        {
         if(t_close[k]==0)
            closed++;
         if(time>=t_close[k])
           {
            t_close[k]=time;
            reasons[k]=deal.GetProperty(ORDER_PROP_REASON);
           }
         vol_out[k]+=volume;
         value_out[k]+=price*volume;
         if(bid>0 && ask>0)
           {
            s_out[k]+=ask-bid;
            n_out[k]++;
           }
        }
     }
   //--- The positions that have a deal out, the newest first
   long order_keys[][2];
   ::ArrayResize(order_keys,closed);
   int at=0;
   for(int k=0;k<total;k++)
      if(t_close[k]!=0)
        {
         order_keys[at][0]=t_close[k];
         order_keys[at][1]=k;
         at++;
        }
   if(closed>1)
      ::ArraySort(order_keys);
   int rows=::MathMin(closed,TRADE_ROWS_MAX);
   string cells[];
   ::ArrayResize(cells,rows*COLUMNS_TRADE_TOTAL);
   for(int row=0;row<rows;row++)
     {
      const int k=(int)order_keys[closed-1-row][1];
      const int digits=(int)::SymbolInfoInteger(symbols[k],SYMBOL_DIGITS);
      const long seconds=(t_open[k]>0 ? (t_close[k]-t_open[k])/1000 : 0);
      string opened=::TimeToString((datetime)(t_open[k]/1000),TIME_DATE|TIME_MINUTES),shut=::TimeToString((datetime)(t_close[k]/1000),TIME_DATE|TIME_MINUTES);
      ::StringReplace(opened,".","-");
      ::StringReplace(shut,".","-");
      int c=row*COLUMNS_TRADE_TOTAL;
      cells[c++]=symbols[k];
      cells[c++]=(types[k]==ORDER_TYPE_BUY ? "BUY" : types[k]==ORDER_TYPE_SELL ? "SELL" : "");
      cells[c++]=(reasons[k]==DEAL_REASON_CLIENT ? "CLIENT" : reasons[k]==DEAL_REASON_MOBILE ? "MOBILE" : reasons[k]==DEAL_REASON_WEB ? "WEB" : reasons[k]==DEAL_REASON_EXPERT ? "EXPERT" :
                  reasons[k]==DEAL_REASON_SL ? "SL" : reasons[k]==DEAL_REASON_TP ? "TP" : reasons[k]==DEAL_REASON_SO ? "SO" : "");
      cells[c++]=(vol_in[k]>0 ? ::DoubleToString(vol_in[k],2) : "");
      cells[c++]=(seconds>=86400 ? (string)(seconds/86400)+"d " : "")+::StringFormat("%02d:%02d:%02d",(seconds%86400)/3600,(seconds%3600)/60,seconds%60);
      cells[c++]=(commission[k]!=0 ? ::DoubleToString(commission[k],2) : "");
      cells[c++]=(swap[k]!=0 ? ::DoubleToString(swap[k],2) : "");
      cells[c++]=(string)ids[k];
      cells[c++]=(t_open[k]>0 ? opened : "");
      cells[c++]=shut;
      cells[c++]=(vol_in[k]>0 ? ::DoubleToString(value_in[k]/vol_in[k],digits) : "");
      cells[c++]=(vol_out[k]>0 ? ::DoubleToString(value_out[k]/vol_out[k],digits) : "");
      cells[c++]=(n_in[k]>0 && n_out[k]>0 ? ::DoubleToString(s_in[k]/n_in[k]/2+s_out[k]/n_out[k]/2,8) : "");
      cells[c++]=(profit[k]!=0 ? ::DoubleToString(profit[k],2) : "");
      cells[c++]="";
     }
   int no_spread[];
   this.FillTable_Trade(m_table_trade_history,cells,rows,COLUMNS_TRADE_TOTAL,COL_T_SYMBOL,no_spread,COL_T_FEE,COL_T_VOLUME,COL_T_COMMISSION,COL_T_SWAP);
   this.FormatTradeRows(m_table_trade_history,rows,COL_T_SYMBOL,COL_T_DIRECTION,COL_T_PROFIT,COL_T_DETAIL);
   //--- The Reason: the icon of its text (the text stays in the cell: the filter lists it, the tooltip is found by it, the narrow column does not show it)
   uint reason_img[TRADE_REASON_TOTAL]={IMAGE_RESOURCE_BMP16_ORDER_REASON_CLIENT_PNG,IMAGE_RESOURCE_BMP16_ORDER_REASON_MOBILE_PNG,IMAGE_RESOURCE_BMP16_ORDER_REASON_WEB_PNG,
                                        IMAGE_RESOURCE_BMP16_ADVISOR_BMP,IMAGE_RESOURCE_BMP16_STOP_RED_BMP,IMAGE_RESOURCE_BMP16_PROFIT_GREEN_PNG,IMAGE_RESOURCE_BMP16_ORDER_REASON_SO_PNG};
   for(int row=0;row<rows;row++)
     {
      string reason=m_table_trade_history.Cell(COL_T_REASON,row).ValueS();
      CTableCellView *view=m_table_trade_history.CellView(COL_T_REASON,row);
      if(view==NULL)
         continue;
      for(int k=0;k<TRADE_REASON_TOTAL;k++)
         if(TRADE_REASON_VALUE[k]==reason)
           {
            view.SetImages(reason_img);
            view.ChangeImage(k);
           }
     }
   m_table_trade_history.View().Rebuild(true,true);
  }
#endif // CGUIPANNEL_WINDOW_TRADEMANAGERTABHISTORY_MQH
