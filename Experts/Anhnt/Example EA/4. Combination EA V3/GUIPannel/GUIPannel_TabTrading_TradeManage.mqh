//+------------------------------------------------------------------+
//|                              GUIPannel_TabTrading_TradeManage.mqh |
//| The Trade Manage button of the Trading tab opens a window with   |
//| the positions of the account: the time, the bid, the ask and the |
//| spread of the entry and of the exit, read from the SQLite file   |
//| that Python writes (the view position_summary). As the test      |
//| Test_PositionTable: the Columns button shows, hides and moves    |
//| the columns, the layout is kept in the Configuration folder      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABTRADING_TRADEMANAGE_MQH
#define CGUIPANNEL_TABTRADING_TRADEMANAGE_MQH
#include "GUIPannel.mqh"
 //--- The button of the Trading tab, under the monitor
 bool CGUIPannel::CreateButton_TradeManage(const int x_gap,const int y_gap)
  {
   m_btn_tradeManage.SetText("Trade Manage");
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_btn_tradeManage);
   return m_btn_tradeManage.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnTradeManage",x_gap,y_gap,M_BUTTON_TRADEMANAGE_WIDTH,M_CONTROL_HEIGHT);
  }
 //--- The window, born hidden: the Columns button in its caption and the table of the positions
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
   //--- A child of the caption bar, next to its buttons: white text on the caption, the colors of the caption buttons on hover and press
   m_btn_position_columns.SetText("Columns...");
   m_window_tradeManage.GetCaptionPointer().AddChild(&m_btn_position_columns);
   if(!m_btn_position_columns.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnPositionColumns",M_WINDOW_TRADEMANAGE_WIDTH-m_window_tradeManage.CaptionRightLimit()-M_BUTTON_TRADEMANAGE_WIDTH,0,M_BUTTON_TRADEMANAGE_WIDTH,M_CONTROL_HEIGHT))
      return false;
   m_btn_position_columns.GetBackColorControl().InitColors(clrNONE,C'90,139,232',C'67,103,173',clrNONE);
   m_btn_position_columns.GetBackColorActControl().InitColors(C'67,103,173',C'67,103,173',C'67,103,173',clrNONE);
   m_btn_position_columns.GetBorderColorControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
   m_btn_position_columns.GetBorderColorActControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
   m_btn_position_columns.GetForeColorControl().InitColors(clrWhite,clrWhite,clrWhite,clrSilver);
   m_btn_position_columns.GetForeColorActControl().InitColors(clrWhite,clrWhite,clrWhite,clrSilver);
   m_btn_position_columns.ColorChange(COLOR_STATE_DEFAULT);
   m_btn_position_columns.Draw(false);
   const int table_y=M_CONTROL_HEIGHT;   // right under the caption
   m_table_position.TableSize(COLUMNS_POSITION_TOTAL,0);
   m_table_position.View().ShowHeaders(true);
   m_table_position.View().ColumnResizeMode(true);
   m_table_position.View().SelectableRow(true);
   m_table_position.View().LightsHover(true);
   m_table_position.View().IsSortMode(true);
   m_window_tradeManage.AddChild(&m_table_position);
   if(!m_table_position.CreateTable(this.m_chart_id,M_SUBWINDOW_MAIN,"TablePosition",1,table_y,M_WINDOW_TRADEMANAGE_WIDTH-2,M_WINDOW_TRADEMANAGE_HEIGHT-table_y-1))
      return false;
   CTableHeaderView *header=m_table_position.View().GetHeaderViewPointer();
   header.ColumnsWidth(POSITION_WIDTH);
   for(int c=0;c<COLUMNS_POSITION_TOTAL;c++)
      m_table_position.SetHeaderText(c,POSITION_CAPTION[c]);
   for(int i=0;i<::ArraySize(POSITION_NUMBER_COLUMNS);i++)
      m_table_position.ColumnContentAlign(POSITION_NUMBER_COLUMNS[i],ALIGN_RIGHT);   // the cells of a column on the right, the caption stays centered
   m_table_position.View().Rebuild(true);
   this.LoadLayout_Position();
   return true;
  }
 //--- The columns the user chose: kept in the Configuration folder
 void CGUIPannel::SaveLayout_Position(void)
  {
   int handle=::FileOpen(::MQLInfoString(MQL_PROGRAM_NAME)+POSITION_LAYOUT_FILE,FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(handle==INVALID_HANDLE)
      return;
   ::FileWriteString(handle,m_table_position.ColumnsLayout());
   ::FileClose(handle);
  }
 void CGUIPannel::LoadLayout_Position(void)
  {
   int handle=::FileOpen(::MQLInfoString(MQL_PROGRAM_NAME)+POSITION_LAYOUT_FILE,FILE_READ|FILE_TXT|FILE_ANSI);
   if(handle==INVALID_HANDLE)
      return;
   string layout=::FileReadString(handle);
   ::FileClose(handle);
   if(!m_table_position.ColumnsLayout(layout,false))
      ::Print(__FUNCTION__,": the saved layout does not fit the table, the default one is kept");
  }
 //--- The positions, newest first: one query on the view, one row each
 void CGUIPannel::FillTable_Position(void)
  {
   ulong d0=::GetMicrosecondCount();   //Print Debug
   CTradeDatabase database;
   string names[],cells[];
   int rows=0;
   string sql="SELECT * FROM position_summary ORDER BY open_time DESC LIMIT "+(string)POSITION_ROWS_MAX;
   if(!database.Read(sql,names,cells,rows))
     {
      ::Print(__FUNCTION__,": ",database.Error());
      return;
     }
   ulong d1=::GetMicrosecondCount();   //Print Debug
   int columns=::ArraySize(names);
   if(columns!=COLUMNS_POSITION_TOTAL)
     {
      ::Print(__FUNCTION__,": the view has ",columns," column(s), the table expects ",COLUMNS_POSITION_TOTAL);
      return;
     }
   m_table_position.TableSize(COLUMNS_POSITION_TOTAL,rows);   // the rows at once: AddRow one by one took 30 ms each
   ulong d2=::GetMicrosecondCount();   //Print Debug
   for(int row=0;row<rows;row++)
      for(int c=0;c<columns;c++)
         m_table_position.SetValue(c,row,cells[row*columns+c]);
   ulong d3=::GetMicrosecondCount();   //Print Debug
   m_table_position.View().Rebuild(true,true);
   CMessage::ToFile(::MQLInfoString(MQL_PROGRAM_NAME),"GUIPannel_TradeManage_Fill","FillTable_Position","MY DEBUG "+(string)rows+" row(s) x "+(string)columns+": SQLite "+(string)((d1-d0)/1000)+" ms, rows made "+(string)((d2-d1)/1000)+" ms, cells written "+(string)((d3-d2)/1000)+" ms, Rebuild "+(string)((::GetMicrosecondCount()-d3)/1000)+" ms");   //Print Debug
  }
 //--- A trade event of the terminal: the file is written by Python a moment later, the table is asked again then
 void CGUIPannel::OnTimerEvent(void)
  {
   if(m_position_reload_at==0 || ::GetTickCount64()<m_position_reload_at)
      return;
   m_position_reload_at=0;
   if(m_window_tradeManage.IsVisible())
     {
      this.FillTable_Position();
      ::ChartRedraw(this.m_chart_id);
     }
  }
 //+------------------------------------------------------------------+
 //| What the user did in the Trade Manage window                     |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Window_TradeManage(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- The window changed its width: the Columns button stays next to the caption buttons
   if(id==CHARTEVENT_CUSTOM+ON_WINDOW_CHANGE_XSIZE && lparam==m_window_tradeManage.ObjectID())
     {
      m_btn_position_columns.Move(m_window_tradeManage.X()+m_window_tradeManage.Width()-m_window_tradeManage.CaptionRightLimit()-M_BUTTON_TRADEMANAGE_WIDTH,m_window_tradeManage.Y());
      return;
     }
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      //--- The button of the Trading tab: the window opens with the positions of the file
      if(lparam==m_btn_tradeManage.ObjectID())
        {
         m_window_tradeManage.OpenWindow();
         this.FillTable_Position();
         ::ChartRedraw(this.m_chart_id);
        }
      //--- The table shows its own window to choose the columns
      else if(lparam==m_btn_position_columns.ObjectID())
        {
         m_table_position.ShowColumns();
         //--- Its window is made on the first call: it joins the windows the collection stacks, on top, or the window of the table covers it
         CGElement *columns=m_table_position.ColumnsWindow();
         if(columns!=NULL && m_graph_elements!=NULL)
           {
            m_graph_elements.RegisterElement(columns);
            columns.BringToTop();
           }
        }
      return;
     }
   if(id==CHARTEVENT_CUSTOM+ON_TABLE_COLUMNS_CHANGED && lparam==m_table_position.ObjectID())
      this.SaveLayout_Position();
  }
#endif // CGUIPANNEL_TABTRADING_TRADEMANAGE_MQH
