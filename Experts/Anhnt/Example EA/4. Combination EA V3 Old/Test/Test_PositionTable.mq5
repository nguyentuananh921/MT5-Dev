//+------------------------------------------------------------------+
//|                                            Test_PositionTable.mq5 |
//| Isolated test: the positions of the account, with the time, the  |
//| bid, the ask and the spread of the entry and of the exit, read   |
//| from the SQLite file that Python writes (the view                |
//| position_summary) with the SQLite functions of MQL5, read only,  |
//| and shown in a CWindow with a CTable. The Columns button opens   |
//| the window to show, hide and move the columns                    |
//+------------------------------------------------------------------+
#property copyright "Anhnt"
#property version   "1.00"
#property strict

#include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Trading\TradeDatabase.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Table\Table.mqh>

input int  InpMaxRows = 500;   // the newest positions shown

enum ENUM_COLUMN_POSITION
  {
   COL_P_POSITION,
   COL_P_SYMBOL,
   COL_P_SIDE,
   COL_P_VOLUME,
   COL_P_OPEN_TICKET,
   COL_P_OPEN_TIME,
   COL_P_OPEN_PRICE,
   COL_P_OPEN_BID,
   COL_P_OPEN_ASK,
   COL_P_OPEN_SPREAD,
   COL_P_OPEN_SOURCE,
   COL_P_CLOSE_TICKET,
   COL_P_CLOSE_TIME,
   COL_P_CLOSE_PRICE,
   COL_P_CLOSE_BID,
   COL_P_CLOSE_ASK,
   COL_P_CLOSE_SPREAD,
   COL_P_CLOSE_SOURCE,
   COL_P_NET,
   COL_P_TOTAL
  };
//--- The columns of the view position_summary, in its order (Python makes the view)
const string POSITION_CAPTION[COL_P_TOTAL]={"Position","Symbol","Side","Volume","Open ticket","Open time","Open price","Open bid","Open ask","Open spread","Open source",
                                            "Close ticket","Close time","Close price","Close bid","Close ask","Close spread","Close source","Net"};
const int    POSITION_WIDTH[COL_P_TOTAL]={80,70,50,55,90,150,80,80,80,80,80,90,150,80,80,80,80,80,70};
#define POSITION_LAYOUT_FILE   "EA LibV3\\Table Position Columns.txt"
#define POSITION_WINDOW_W      900
#define POSITION_WINDOW_H      380

CTradeDatabase g_database;
CWindow        g_window;
CTable         g_table;
CButton        g_button_columns;
ulong          g_reload_at=0;   // when the table is asked again after a trade event: the EA that writes the file needs a moment
//+------------------------------------------------------------------+
void SaveLayout(void)
  {
   int handle=::FileOpen(POSITION_LAYOUT_FILE,FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(handle==INVALID_HANDLE)
      return;
   ::FileWriteString(handle,g_table.ColumnsLayout());
   ::FileClose(handle);
  }
void LoadLayout(void)
  {
   int handle=::FileOpen(POSITION_LAYOUT_FILE,FILE_READ|FILE_TXT|FILE_ANSI);
   if(handle==INVALID_HANDLE)
      return;
   string layout=::FileReadString(handle);
   ::FileClose(handle);
   if(!g_table.ColumnsLayout(layout,false))
      ::Print(__FUNCTION__,": the saved layout does not fit the table, the default one is kept");
  }
//+------------------------------------------------------------------+
//| The positions, newest first: one query on the view, one row each |
//+------------------------------------------------------------------+
void FillTable(void)
  {
   string names[],cells[];
   int rows=0;
   string sql="SELECT * FROM position_summary ORDER BY open_time DESC LIMIT "+(string)InpMaxRows;
   if(!g_database.Read(sql,names,cells,rows))
     {
      ::Print(__FUNCTION__,": ",g_database.Error());
      return;
     }
   int columns=::ArraySize(names);
   if(columns!=COL_P_TOTAL)
     {
      ::Print(__FUNCTION__,": the view has ",columns," column(s), the table expects ",COL_P_TOTAL);
      return;
     }
   g_table.DeleteAllRows(false);
   for(int i=0;i<rows;i++)
      g_table.AddRow();
   for(int row=0;row<rows;row++)
      for(int c=0;c<columns;c++)
         g_table.SetValue(c,row,cells[row*columns+c]);
   g_table.View().Rebuild(true,true);
   ::Print(__FUNCTION__,": ",rows," position(s) from ",CTradeDatabase::FileName());
  }
//+------------------------------------------------------------------+
bool CreateWindowAndTable(void)
  {
   long chart=::ChartID();
   g_window.Hide();   // born hidden: the children inherit it, shown once at the end
   g_window.FontSize(DEF_FONT_SIZE);
   g_window.IsMovable(true);
   g_window.ResizeMode(true);
   g_window.CloseButtonIsUsed(false);
   g_window.CollapseButtonIsUsed(true);
   g_window.TooltipsButtonIsUsed(false);
   g_window.FullscreenButtonIsUsed(false);
   if(!g_window.CreateWindow(chart,0,"Positions",20,40,POSITION_WINDOW_W,POSITION_WINDOW_H))
      return false;
   int top=WINDOW_CAPTION_HEIGHT+M_CONTROL_BORDER_GAP;
   g_window.AddChild(&g_button_columns);
   if(!g_button_columns.Create(chart,0,"PositionColumns",M_CONTROL_BORDER_GAP,top,90,M_CONTROL_HEIGHT))
      return false;
   g_button_columns.SetText("Columns...");
   g_button_columns.Draw(false);
   int table_y=top+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
   g_table.TableSize(COL_P_TOTAL,0);
   g_table.View().ShowHeaders(true);
   g_table.View().ColumnResizeMode(true);
   g_table.View().SelectableRow(true);
   g_table.View().LightsHover(true);
   g_table.View().IsSortMode(true);
   g_window.AddChild(&g_table);
   if(!g_table.CreateTable(chart,0,"TablePosition",1,table_y,POSITION_WINDOW_W-2,POSITION_WINDOW_H-table_y-1))
      return false;
   CTableHeaderView *header=g_table.View().GetHeaderViewPointer();
   header.ColumnsWidth(POSITION_WIDTH);
   for(int c=0;c<COL_P_TOTAL;c++)
      g_table.SetHeaderText(c,POSITION_CAPTION[c]);
   int numbers[]={COL_P_VOLUME,COL_P_OPEN_PRICE,COL_P_OPEN_BID,COL_P_OPEN_ASK,COL_P_OPEN_SPREAD,COL_P_CLOSE_PRICE,COL_P_CLOSE_BID,COL_P_CLOSE_ASK,COL_P_CLOSE_SPREAD,COL_P_NET};
   for(int i=0;i<ArraySize(numbers);i++)
      g_table.ColumnContentAlign(numbers[i],ALIGN_RIGHT);   // the cells of a column on the right, the caption stays centered
   g_table.View().Rebuild(true);
   LoadLayout();
   return true;
  }
//+------------------------------------------------------------------+
int OnInit()
  {
   ::ChartSetInteger(::ChartID(),CHART_EVENT_MOUSE_MOVE,true);
   if(!CreateWindowAndTable())
      return INIT_FAILED;
   FillTable();
   g_window.Show();
   ::ChartRedraw();
   ::EventSetMillisecondTimer(100);
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ::EventKillTimer();
   SaveLayout();
  }
//+------------------------------------------------------------------+
void OnTick() {}
//+------------------------------------------------------------------+
//| A trade event of the terminal: the table is asked again soon     |
//+------------------------------------------------------------------+
void OnTrade()
  {
   g_reload_at=::GetTickCount64()+1500;   // the file is written by EA LibV3 on its own OnTrade: read it a moment later
  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   g_window.OnTimerEvent();
   if(g_reload_at>0 && ::GetTickCount64()>=g_reload_at)
     {
      g_reload_at=0;
      FillTable();
      ::ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   g_window.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      if(lparam==(long)g_button_columns.ObjectID())
         g_table.ShowColumns();   // the table shows its own window to choose the columns
     }
   else if(id==CHARTEVENT_CUSTOM+ON_TABLE_COLUMNS_CHANGED && lparam==(long)g_table.ObjectID())
      SaveLayout();
  }
//+------------------------------------------------------------------+
