//+------------------------------------------------------------------+
//|                                              Test_HistoryTable.mq5 |
//| Isolated test: CHistoryCollection shown in a CWindow with a      |
//| CTable. The Columns button opens a small window to show, hide    |
//| and move the columns at run time (only the view changes, the     |
//| model keeps every column); the layout is kept in a file          |
//+------------------------------------------------------------------+
#property copyright "Anhnt"
#property version   "1.00"
#property strict

#include <Vendors\Anhnt\Library\4. Combination Lib V3\Collections\HistoryCollection.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Controls\Table\ColumnsWindow.mqh>

input int  InpMaxRows        = 300;   // the newest lines of the history shown
input int  InpRefreshSeconds = 5;     // the history is read again this often

enum ENUM_COLUMN_HISTORY
  {
   COL_H_TICKET,
   COL_H_TIME,
   COL_H_STATUS,
   COL_H_TYPE,
   COL_H_SYMBOL,
   COL_H_VOLUME,
   COL_H_PRICE_OPEN,
   COL_H_PRICE_CLOSE,
   COL_H_SL,
   COL_H_TP,
   COL_H_PROFIT,
   COL_H_COMMISSION,
   COL_H_SWAP,
   COL_H_MAGIC,
   COL_H_COMMENT,
   COL_H_TOTAL
  };
const int  HISTORY_WIDTH[COL_H_TOTAL]={80,120,100,110,80,60,80,80,80,80,70,70,60,70,160};
const string HISTORY_CAPTION[COL_H_TOTAL]={"Ticket","Time","Status","Type","Symbol","Volume","Open","Close","SL","TP","Profit","Commission","Swap","Magic","Comment"};
#define HISTORY_LAYOUT_FILE   "EA LibV3\\Table History Columns.txt"
#define HISTORY_WINDOW_W      800
#define HISTORY_WINDOW_H      420

CHistoryCollection g_history;
CWindow            g_window;
CTable             g_table;
CButton            g_button_columns;
CButton            g_button_refresh;
CColumnsWindow     g_columns;
int                g_listed=-1;       // how many lines of the history the table shows now
datetime           g_last_refresh=0;
//+------------------------------------------------------------------+
//| The layout of the columns is kept in a text file                 |
//+------------------------------------------------------------------+
void SaveLayout(void)
  {
   int handle=::FileOpen(HISTORY_LAYOUT_FILE,FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(handle==INVALID_HANDLE)
      return;
   ::FileWriteString(handle,g_table.ColumnsLayout());
   ::FileClose(handle);
  }
void LoadLayout(void)
  {
   int handle=::FileOpen(HISTORY_LAYOUT_FILE,FILE_READ|FILE_TXT|FILE_ANSI);
   if(handle==INVALID_HANDLE)
      return;
   string layout=::FileReadString(handle);
   ::FileClose(handle);
   if(!g_table.ColumnsLayout(layout,false))
      ::Print(__FUNCTION__,": the saved layout does not fit the table, the default one is kept");
  }
//+------------------------------------------------------------------+
//| The newest lines of the history, one row each                    |
//+------------------------------------------------------------------+
void FillTable(void)
  {
   CArrayObj *list=g_history.GetList();
   int total=(list!=NULL ? list.Total() : 0);
   int count=::MathMin(total,InpMaxRows);
   g_table.DeleteAllRows(false);
   for(int i=0;i<count;i++)
      g_table.AddRow();
   for(int row=0;row<count;row++)
     {
      COrder *order=list.At(total-1-row);   // the newest first
      if(order==NULL)
         continue;
      int digits=(int)::SymbolInfoInteger(order.Symbol(),SYMBOL_DIGITS);
      g_table.SetValue(COL_H_TICKET,row,order.Ticket());
      g_table.SetValue(COL_H_TIME,row,(datetime)(order.TimeOpen()/1000));
      g_table.SetValue(COL_H_STATUS,row,order.StatusDescription());
      g_table.SetValue(COL_H_TYPE,row,order.TypeDescription());
      g_table.SetValue(COL_H_SYMBOL,row,order.Symbol());
      g_table.SetValue(COL_H_VOLUME,row,order.Volume());
      g_table.SetValue(COL_H_PRICE_OPEN,row,order.PriceOpen());
      g_table.SetValue(COL_H_PRICE_CLOSE,row,order.PriceClose());
      g_table.SetValue(COL_H_SL,row,order.StopLoss());
      g_table.SetValue(COL_H_TP,row,order.TakeProfit());
      g_table.SetValue(COL_H_PROFIT,row,order.Profit());
      g_table.SetValue(COL_H_COMMISSION,row,order.Comission());
      g_table.SetValue(COL_H_SWAP,row,order.Swap());
      g_table.SetValue(COL_H_MAGIC,row,order.Magic());
      g_table.SetValue(COL_H_COMMENT,row,order.OrderComment());
      g_table.Cell(COL_H_VOLUME,row).SetDigits(2);
      g_table.Cell(COL_H_PRICE_OPEN,row).SetDigits(digits);
      g_table.Cell(COL_H_PRICE_CLOSE,row).SetDigits(digits);
      g_table.Cell(COL_H_SL,row).SetDigits(digits);
      g_table.Cell(COL_H_TP,row).SetDigits(digits);
      g_table.Cell(COL_H_PROFIT,row).SetDigits(2);
      g_table.Cell(COL_H_COMMISSION,row).SetDigits(2);
      g_table.Cell(COL_H_SWAP,row).SetDigits(2);
     }
   g_table.View().Rebuild(true,true);
   g_listed=total;
   ::Print(__FUNCTION__,": ",count," line(s) of ",total," in the history");
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
   if(!g_window.CreateWindow(chart,0,"History",20,40,HISTORY_WINDOW_W,HISTORY_WINDOW_H))
      return false;
   int top=WINDOW_CAPTION_HEIGHT+M_CONTROL_BORDER_GAP;
   g_window.AddChild(&g_button_columns);
   g_window.AddChild(&g_button_refresh);
   if(!g_button_columns.Create(chart,0,"HistoryColumns",M_CONTROL_BORDER_GAP,top,90,M_CONTROL_HEIGHT) ||
      !g_button_refresh.Create(chart,0,"HistoryRefresh",2*M_CONTROL_BORDER_GAP+90,top,90,M_CONTROL_HEIGHT))
      return false;
   g_button_columns.SetText("Columns...");
   g_button_refresh.SetText("Refresh");
   g_button_columns.Draw(false);
   g_button_refresh.Draw(false);
   int table_y=top+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
   g_table.TableSize(COL_H_TOTAL,0);
   g_table.View().ShowHeaders(true);
   g_table.View().ColumnResizeMode(true);
   g_table.View().SelectableRow(true);
   g_table.View().LightsHover(true);
   g_table.View().IsSortMode(true);
   g_window.AddChild(&g_table);
   if(!g_table.CreateTable(chart,0,"TableHistory",1,table_y,HISTORY_WINDOW_W-2,HISTORY_WINDOW_H-table_y-1))
      return false;
   CTableHeaderView *header=g_table.View().GetHeaderViewPointer();
   header.ColumnsWidth(HISTORY_WIDTH);
   for(int c=0;c<COL_H_TOTAL;c++)
      g_table.SetHeaderText(c,HISTORY_CAPTION[c]);
   g_table.View().Rebuild(true);
   //--- the window of the columns, beside the history window
   if(!g_columns.CreateColumnsWindow(chart,0,HISTORY_WINDOW_W+30,40,&g_table))
      return false;
   LoadLayout();
   return true;
  }
//+------------------------------------------------------------------+
int OnInit()
  {
   ::ChartSetInteger(::ChartID(),CHART_EVENT_MOUSE_MOVE,true);
   g_history.Refresh();
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
void OnTimer()
  {
   g_window.OnTimerEvent();
   g_columns.OnTimerEvent();
   if(::TimeLocal()-g_last_refresh<InpRefreshSeconds)
      return;
   g_last_refresh=::TimeLocal();
   g_history.Refresh();
   CArrayObj *list=g_history.GetList();
   if(list!=NULL && list.Total()!=g_listed)
      FillTable();
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   g_window.OnChartEvent(id,lparam,dparam,sparam);
   g_columns.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      if(lparam==(long)g_button_columns.ObjectID())
         g_columns.Open();
      else if(lparam==(long)g_button_refresh.ObjectID())
        {
         g_history.Refresh();
         FillTable();
        }
     }
   else if(id==CHARTEVENT_CUSTOM+ON_TABLE_COLUMNS_CHANGED && lparam==(long)g_table.ObjectID())
      SaveLayout();
  }
//+------------------------------------------------------------------+
