//+------------------------------------------------------------------+
//|                                  GUIPannel_TradeManagerWindow.mqh |
//| The Trade Manage window (m_window_tradeManage): the tabs         |
//| (ENUM_TAB_TRADE), the tables of the positions read from the      |
//| SQLite file that Python writes (the view position_summary), the  |
//| Columns button in the header of the tabs, the layout of the columns, kept|
//| in the Configuration folder                                      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TRADEMANAGERWINDOW_MQH
#define CGUIPANNEL_TRADEMANAGERWINDOW_MQH
#include "GUIPannel.mqh"
 //--- The tabs of the window, under its caption: the header on top, the content fills what is left
 bool CGUIPannel::CreateTabs_TradeManage(void)
  {
   string tabs_names[TAB_TRADE_TOTAL]={"By Symbol","Open","Pending","History"};   // the order of ENUM_TAB_TRADE
   m_tabs_tradeManage.PositionMode(TABS_TOP);
   m_tabs_tradeManage.AutoXResizeMode(true);
   m_tabs_tradeManage.AutoYResizeMode(true);
   m_tabs_tradeManage.AutoXResizeRightOffset(1);
   m_tabs_tradeManage.AutoYResizeBottomOffset(1);
   for(int i=0;i<TAB_TRADE_TOTAL;i++)
      m_tabs_tradeManage.AddTab(tabs_names[i],100);
   m_window_tradeManage.AddChild(&m_tabs_tradeManage);
   if(!m_tabs_tradeManage.CreateTabs(this.m_chart_id,M_SUBWINDOW_MAIN,"TabsTradeManage",1,2*M_CONTROL_HEIGHT))   // under the caption and the header of the tabs
      return false;
   //--- The Columns button: a child of the tabs, at the right end of their header row
   m_btn_table_columns.SetText("Columns...");
   m_btn_table_columns.IconFile(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);
   m_btn_table_columns.IconFilePressed(IMAGE_RESOURCE_BMP16_ARROWDOWN_BLUE_BMP);
   m_tabs_tradeManage.AddChild(&m_btn_table_columns);
   return m_btn_table_columns.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnTableColumns",m_tabs_tradeManage.Width()-M_BUTTON_TRADEMANAGE_WIDTH,-M_CONTROL_HEIGHT+1,M_BUTTON_TRADEMANAGE_WIDTH,M_CONTROL_HEIGHT);
  }
 //--- A table in a tab (tab<0: in the Order detail window): it takes the body of the tab; the columns, their captions, their widths and the ones with numbers (on the right) are given.
 //--- The Side (direction_column<0: none) has a picture for its header and for each cell, in the middle of its column; a Spread has the picture of the spread for its header, in the middle;
 //--- the Detail (detail_column<0: none) has the picture of the information
 bool CGUIPannel::CreateTable_Trade(CTable &table,const string name,const int tab,const int columns,const string &captions[],const int &widths[],const int &numbers[],
                                    const int direction_column,const int &spread_columns[],const int detail_column)
  {
   table.TableSize(columns,0);
   table.View().ShowHeaders(true);
   table.View().ColumnResizeMode(true);
   table.View().SelectableRow(true);
   table.View().LightsHover(true);
   table.View().IsSortMode(true);
   table.AutoXResizeMode(true);
   table.AutoXResizeRightOffset(tab>=0 ? 0 : 1);
   table.AutoYResizeMode(true);
   table.AutoYResizeBottomOffset(tab>=0 ? 0 : 1);
   int x=0,y=0,w=0,h=0;
   if(tab>=0)
     {
      m_tabs_tradeManage.AddToElementsArray(tab,table);
      w=m_tabs_tradeManage.Width();
      h=m_tabs_tradeManage.Height();
     }
   else
     {
      m_window_order_detail.AddChild(&table);
      x=1;
      y=M_CONTROL_HEIGHT;   // under the caption of the window
      w=m_window_order_detail.Width()-2;
      h=m_window_order_detail.Height()-M_CONTROL_HEIGHT-1;
     }
   if(!table.CreateTable(this.m_chart_id,M_SUBWINDOW_MAIN,name,x,y,w,h))
      return false;
   CTableHeaderView *header=table.View().GetHeaderViewPointer();
   header.ColumnsWidth(widths);
   for(int c=0;c<columns;c++)
      table.SetHeaderText(c,captions[c]);
   for(int i=0;i<::ArraySize(numbers);i++)
      table.ColumnContentAlign(numbers[i],ALIGN_RIGHT);   // the cells of a column on the right, the caption stays centered
   int offsets[];
   ::ArrayResize(offsets,columns);
   ::ArrayInitialize(offsets,3);
   uint spread_img[]={IMAGE_RESOURCE_BMP16_SPREADRED_PNG};
   for(int i=0;i<::ArraySize(spread_columns);i++)
     {
      table.SetHeaderImage(spread_columns[i],spread_img);   // the caption stays for the window of the columns, the header shows the picture
      offsets[spread_columns[i]]=(widths[spread_columns[i]]-16)/2;   // the picture is 16 wide: in the middle
     }
   header.ImageXOffset(offsets);
   if(direction_column>=0)
     {
      uint direction_header_img[]={IMAGE_RESOURCE_BMP16_ORDER_DIR_PNG};
      table.SetHeaderImage(direction_column,direction_header_img);
      table.ColumnContentAlign(direction_column,ALIGN_CENTER);
     }
   if(detail_column>=0)
     {
      uint detail_header_img[]={IMAGE_RESOURCE_BMP16_INFO_BMP};
      table.SetHeaderImage(detail_column,detail_header_img);
      table.ColumnContentAlign(detail_column,ALIGN_CENTER);
     }
   table.View().Rebuild(true);
   return true;
  }
 //--- The window, born hidden: the tabs with the Columns button and the tables of the positions
 bool CGUIPannel::CreateWindow_TradeManage(const string caption_text,const int x_gap,const int y_gap)
  {
   m_window_tradeManage.FontSize(DEF_FONT_SIZE);
   m_window_tradeManage.IsMovable(true);
   m_window_tradeManage.ResizeMode(true);
   m_window_tradeManage.CloseButtonIsUsed(true);
   m_window_tradeManage.CollapseButtonIsUsed(true);
   m_window_tradeManage.TooltipsButtonIsUsed(false);
   m_window_tradeManage.FullscreenButtonIsUsed(false);
   m_window_tradeManage.WindowType(W_DIALOG);
   if(!m_window_tradeManage.CreateWindow(this.m_chart_id,M_SUBWINDOW_MAIN,caption_text,x_gap,y_gap,M_WINDOW_TRADEMANAGE_WIDTH,M_WINDOW_TRADEMANAGE_HEIGHT))
      return false;
   if(!CreateTabs_TradeManage())
      return false;
   //--- The positions, for now in the Open tab; the History tab has its own table, the deals (GUIPannel_TradeManagerWindow_History.mqh)
   if(!CreateTable_Trade(m_table_position,"TablePosition",TAB_TRADE_OPEN_POSITION,COLUMNS_POSITION_TOTAL,POSITION_CAPTION,POSITION_WIDTH,POSITION_NUMBER_COLUMNS,COL_P_DIRECTION,POSITION_SPREAD_COLUMNS,COL_P_DETAIL))
      return false;
   m_table_position.FixedColumns(2,2,false);   // Position and Symbol at left, Net and Detail at right stay still while the others scroll
   this.LoadLayout_Table(m_table_position,POSITION_LAYOUT_FILE);
   if(!CreateTable_TradeHistory())
      return false;
   m_tabs_tradeManage.SelectTab(TAB_TRADE_OPEN_POSITION);   // the first tab with a table
   return true;
  }
 //--- The columns the user chose: a file in the Configuration folder (EA LibV3\Configuration) for each table, a line for each column in the order shown:
 //--- "Time=1" (shown) or "Time=0" (hidden); a column is found by its caption, so a column added later does not shift the others
 void CGUIPannel::SaveLayout_Table(CTable &table,const string file)
  {
   int handle=::FileOpen(::MQLInfoString(MQL_PROGRAM_NAME)+file,FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(handle==INVALID_HANDLE)
      return;
   for(int p=0;p<table.ColumnsTotal();p++)
     {
      int column=table.ColumnAtPosition(p);
      ::FileWrite(handle,table.ColumnCaption(column)+"="+(table.IsColumnShown(column) ? "1" : "0"));
     }
   ::FileClose(handle);
  }
 void CGUIPannel::LoadLayout_Table(CTable &table,const string file)
  {
   int handle=::FileOpen(::MQLInfoString(MQL_PROGRAM_NAME)+file,FILE_READ|FILE_TXT|FILE_ANSI);
   if(handle==INVALID_HANDLE)
      return;
   int total=table.ColumnsTotal();
   int order[],unknown=0;
   bool seen[],shown[];
   ::ArrayResize(seen,total);
   ::ArrayResize(shown,total);
   ::ArrayInitialize(seen,false);
   ::ArrayInitialize(shown,true);
   while(!::FileIsEnding(handle))
     {
      string line=::FileReadString(handle);
      int equal=::StringFind(line,"=");
      if(equal<1)
         continue;
      string caption=::StringSubstr(line,0,equal);
      bool found=false;
      for(int c=0;c<total && !found;c++)
         if(!seen[c] && table.ColumnCaption(c)==caption)
           {
            found=true;
            seen[c]=true;
            shown[c]=(::StringSubstr(line,equal+1)!="0");
            ::ArrayResize(order,::ArraySize(order)+1);
            order[::ArraySize(order)-1]=c;
           }
      if(!found)
         unknown++;
     }
   ::FileClose(handle);
   //--- The columns of the table are not the ones the file was written for (one was added, removed or renamed): the order of the table is the default one,
   //--- and the file is written again by the next choice of the user
   if(unknown>0 || ::ArraySize(order)!=total)
     {
      ::Print(__FUNCTION__,": the columns of the table are not the ones of ",file,", its default order is used");
      return;
     }
   string places="",flags="";   // the layout of the table: "the column of each place|shown flag of each column"
   for(int i=0;i<total;i++)
     {
      places+=(i>0 ? "," : "")+(string)order[i];
      flags+=(i>0 ? "," : "")+(shown[i] ? "1" : "0");
     }
   if(!table.ColumnsLayout(places+"|"+flags,false))
      ::Print(__FUNCTION__,": the saved columns of ",file," do not fit the table, the default ones are kept");
  }
 //--- Rows of a query: one row each, the rows made at once (AddRow one by one took 30 ms each); a spread comes as a difference of prices and is shown in points,
 //--- the fee (fee_column<0: none) is the whole cost of the trade: the half spreads, which come as a difference of prices, in money by the volume of its row,
 //--- plus its commission and its swap (they are costs already: negative); shown with two decimals, blank when the spread is not known.
 //--- Gives back the number of rows (WRONG_VALUE when the query failed); the table is not drawn: the caller puts the pictures of the cells, then draws
 int CGUIPannel::FillTable_Trade(CTable &table,const string sql,const int columns_expected,const int symbol_column,const int &spread_columns[],
                                const int fee_column,const int volume_column,const int commission_column,const int swap_column)
  {
   CTradeDatabase database;
   string names[],cells[];
   int rows=0;
   if(!database.Read(sql,names,cells,rows))
     {
      ::Print(__FUNCTION__,": ",database.Error());
      return WRONG_VALUE;
     }
   int columns=::ArraySize(names);
   if(columns!=columns_expected)
     {
      ::Print(__FUNCTION__,": the query has ",columns," column(s), the table expects ",columns_expected);
      return WRONG_VALUE;
     }
   table.TableSize(columns,rows);
   for(int row=0;row<rows;row++)
     {
      string symbol=cells[row*columns+symbol_column];
      double point=::SymbolInfoDouble(symbol,SYMBOL_POINT);
      double tick_size=::SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
      double tick_value=::SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
      for(int c=0;c<columns;c++)
        {
         string value=cells[row*columns+c];
         if(c==fee_column && volume_column>=0)   // the price difference to money: ticks of it, the value of a tick, the volume; then the commission and the swap
            value=(value=="" || tick_size<=0 ? "" : ::DoubleToString(-::StringToDouble(value)/tick_size*tick_value*::StringToDouble(cells[row*columns+volume_column])
                                                                     +(commission_column>=0 ? ::StringToDouble(cells[row*columns+commission_column]) : 0)
                                                                     +(swap_column>=0 ? ::StringToDouble(cells[row*columns+swap_column]) : 0),2));
         for(int s=0;s<::ArraySize(spread_columns);s++)
            if(c==spread_columns[s])
               value=(value=="" || point<=0 ? "" : ::DoubleToString(::StringToDouble(value)/point,0));
         table.SetValue(c,row,value);
        }
     }
   return rows;
  }
 //--- The positions, newest first: the view of the file, one row for a position
 void CGUIPannel::FillTable_Position(void)
  {
   int spreads[]={COL_P_OPEN_SPREAD,COL_P_CLOSE_SPREAD};
   int rows=this.FillTable_Trade(m_table_position,"SELECT *,'' FROM position_summary ORDER BY open_time DESC LIMIT "+(string)POSITION_ROWS_MAX,COLUMNS_POSITION_TOTAL,COL_P_SYMBOL,spreads,WRONG_VALUE,WRONG_VALUE,WRONG_VALUE,WRONG_VALUE);
   if(rows==WRONG_VALUE)
      return;
   this.FormatTradeRows(m_table_position,rows,COL_P_SYMBOL,COL_P_DIRECTION,COL_P_NET,COL_P_DETAIL);
   m_table_position.View().Rebuild(true,true);
  }
 //--- The rows as the user reads them: the symbol of the chart is in colour (as in the other tables), Buy and Sell are pictures instead of words,
 //--- a gain is green and a loss is red, and a button with the information picture opens the detail of the order (a column < 0 is not there)
 void CGUIPannel::FormatTradeRows(CTable &table,const int rows,const int symbol_column,const int direction_column,const int profit_column,const int detail_column)
  {
   uint symbol_img[]={IMAGE_RESOURCE_BMP16_BAR_CHART_BMP,IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
   uint side_img[]  ={IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG,IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG};
   uint detail_img[]={IMAGE_RESOURCE_BMP16_INFO_BMP};
   for(int row=0;row<rows;row++)
     {
      if(symbol_column>=0)
        {
         CTableCellView *symbol=table.CellView(symbol_column,row);
         if(symbol!=NULL)
           {
            symbol.SetImages(symbol_img);
            symbol.ChangeImage(table.Cell(symbol_column,row).ValueS()==::Symbol() ? 0 : 1);
           }
        }
      if(direction_column>=0)
        {
         string side=table.Cell(direction_column,row).ValueS();
         CTableCellView *direction=table.CellView(direction_column,row);
         if(direction!=NULL)
           {
            direction.SetImages(side_img);
            direction.ChangeImage(side=="BUY" ? 0 : 1);
           }
         table.SetValue(direction_column,row,"");   // the picture says it
        }
      if(profit_column>=0)
        {
         CTableCellView *profit=table.CellView(profit_column,row);
         if(profit!=NULL)
           {
            string text=table.Cell(profit_column,row).ValueS();
            double amount=::StringToDouble(text);
            profit.TextColor(text=="" || amount==0 ? clrNONE : (amount>0 ? M_COLOR_PROFIT : M_COLOR_LOSS));
           }
        }
      if(detail_column>=0)
        {
         CTableCellView *detail=table.CellView(detail_column,row);
         if(detail!=NULL)
           {
            detail.CellType(CELL_BUTTON);
            detail.SetImages(detail_img);
           }
        }
     }
  }
 //+------------------------------------------------------------------+
 //| What the user did in the Trade Manage window                     |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Window_TradeManage(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- The window changed its width: the Columns button stays at the right end of the header of the tabs
   if(id==CHARTEVENT_CUSTOM+ON_WINDOW_CHANGE_XSIZE && lparam==m_window_tradeManage.ObjectID())
     {
      m_btn_table_columns.Move(m_window_tradeManage.X()+m_window_tradeManage.Width()-1-M_BUTTON_TRADEMANAGE_WIDTH,m_tabs_tradeManage.Y()-M_CONTROL_HEIGHT+1);
      return;
     }
   //--- The window of the columns was closed (its X button): the arrow of the button goes back to the right
   if(id==CHARTEVENT_CUSTOM+ON_CLOSE_DIALOG_BOX && m_btn_table_columns.State())
     {
      CGElement *columns_open=(m_tabs_tradeManage.SelectedTab()==TAB_TRADE_HISTORY_POSITION) ? m_table_trade_history.ColumnsWindow() : m_table_position.ColumnsWindow();
      if(columns_open==NULL || !columns_open.IsVisible())
         m_btn_table_columns.SetState(false);
      return;
     }
   //--- A tab was chosen: the Columns button is there only for the tabs that have a table, its window of the other tab is closed
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_TAB && lparam==m_tabs_tradeManage.ObjectID() && m_window_tradeManage.IsVisible())
     {
      CGElement *columns_position=m_table_position.ColumnsWindow();
      CGElement *columns_history=m_table_trade_history.ColumnsWindow();
      if(columns_position!=NULL)
         columns_position.Hide();
      if(columns_history!=NULL)
         columns_history.Hide();
      m_btn_table_columns.SetState(false);
      int tab=m_tabs_tradeManage.SelectedTab();
      if(tab==TAB_TRADE_OPEN_POSITION || tab==TAB_TRADE_HISTORY_POSITION)
         m_btn_table_columns.Show();
      else
         m_btn_table_columns.Hide();
      return;
     }
   //--- The Detail button of a row: the window of the order opens with what happened to its position
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && (lparam==m_table_position.ObjectID() || lparam==m_table_trade_history.ObjectID()))
     {
      bool is_position=(lparam==m_table_position.ObjectID());
      CTable *table=is_position ? GetPointer(m_table_position) : GetPointer(m_table_trade_history);
      int column,row;
      if(!table.CellIndexes(sparam,column,row) || column!=(is_position ? (int)COL_P_DETAIL : (int)COL_T_DETAIL))
         return;
      this.OpenOrderDetail(::StringToInteger(table.Cell(is_position ? (int)COL_P_POSITION_ID : (int)COL_T_POSITION_ID,row).ValueS()));
      return;
     }
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      //--- The button of the Trading tab: the window opens with the positions of the file
      if(lparam==m_btn_tradeManage.ObjectID())
        {
         m_window_tradeManage.OpenWindow();
         this.FillTable_Position();
         this.FillTable_TradeHistory();
         ::ChartRedraw(this.m_chart_id);
        }
      //--- ON: the table of the tab that is open shows its own window to choose the columns, OFF: the window closes
      else if(lparam==m_btn_table_columns.ObjectID())
        {
         CTable *table=(m_tabs_tradeManage.SelectedTab()==TAB_TRADE_HISTORY_POSITION) ? GetPointer(m_table_trade_history) : GetPointer(m_table_position);
         if(dparam==0)
           {
            CGElement *columns_off=table.ColumnsWindow();
            if(columns_off!=NULL)
               columns_off.Hide();
            ::ChartRedraw(this.m_chart_id);
            return;
           }
         table.ShowColumns();
         //--- Its window is made on the first call: it joins the windows the collection stacks, on top, or the window of the table covers it
         CGElement *columns=table.ColumnsWindow();
         if(columns!=NULL && m_graph_elements!=NULL)
           {
            m_graph_elements.RegisterElement(columns);
            columns.BringToTop();
           }
        }
      return;
     }
   //--- The user chose the columns of a table: the layout is kept
   if(id==CHARTEVENT_CUSTOM+ON_TABLE_COLUMNS_CHANGED)
     {
      if(lparam==m_table_position.ObjectID())
         this.SaveLayout_Table(m_table_position,POSITION_LAYOUT_FILE);
      else if(lparam==m_table_trade_history.ObjectID())
         this.SaveLayout_Table(m_table_trade_history,TRADE_HISTORY_LAYOUT_FILE);
     }
  }
#endif // CGUIPANNEL_TRADEMANAGERWINDOW_MQH
