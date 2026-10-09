//+------------------------------------------------------------------+
//|                                                    TestTable.mq5 |
//| Positions-like table: live cells, button/checkbox/combobox/edit  |
//| cells, sort by caption, column resize, follows window resize     |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Window.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Table\Table.mqh>

enum ENUM_COL_TEST
  {
   COL_SYMBOL=0,
   COL_TYPE,
   COL_VOLUME,
   COL_PROFIT,
   COL_SL_MODE,
   COL_CLOSE,
   COL_TRAIL,
   COL_TOTAL
  };

CWindow m_window_main;
CTable  m_table;
CButton m_btn_add;
CButton m_btn_delete;

void SetupRow(const int row)
  {
   int total=::SymbolsTotal(true);
   m_table.SetValue(COL_SYMBOL,row,::SymbolName(row%total,true));
   m_table.SetValue(COL_TYPE,row,(row%2==0 ? "Buy" : "Sell"));
   m_table.Cell(COL_VOLUME,row).SetDigits(2);
   m_table.SetValue(COL_VOLUME,row,0.01*(1+row%5));
   m_table.CellView(COL_VOLUME,row).CellType(CELL_EDIT);
   m_table.Cell(COL_PROFIT,row).SetDigits(2);
   m_table.SetValue(COL_PROFIT,row,0.0);
   uint direction[]={IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG,IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG,IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
   m_table.CellView(COL_PROFIT,row).SetImages(direction);
   m_table.CellView(COL_PROFIT,row).DirectionImages(true);
   string modes[]={"Fixed","ATR","Indicator"};
   m_table.SetValue(COL_SL_MODE,row,modes[row%3]);
   m_table.CellView(COL_SL_MODE,row).SetValueList(modes);
   m_table.CellView(COL_SL_MODE,row).CellType(CELL_COMBOBOX);
   uint close[]={IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
   m_table.CellView(COL_CLOSE,row).SetImages(close);
   m_table.CellView(COL_CLOSE,row).CellType(CELL_BUTTON);
   m_table.CellView(COL_TRAIL,row).CellType(CELL_CHECKBOX);
  }

int OnInit(void)
  {
   const long chart_id=::ChartID();
   m_window_main.IsMovable(true);
   m_window_main.ResizeMode(true);
   m_window_main.MinimumXSize(250);
   m_window_main.MinimumYSize(200);
   m_window_main.CloseButtonIsUsed(true);
   if(!m_window_main.CreateWindow(chart_id,0,"TABLE",60,40,540,310))
      return INIT_FAILED;

   m_table.TableSize(COL_TOTAL,25);
   string captions[]={"Symbol","Type","Volume","Profit","SL mode","Close","Trail"};
   for(int i=0; i<COL_TOTAL; i++)
      m_table.SetHeaderText(i,captions[i]);
   m_table.View().ShowHeaders(true);
   m_table.View().LightsHover(true);
   m_table.View().SelectableRow(true);
   m_table.View().IsSortMode(true);
   m_table.View().ColumnResizeMode(true);
   m_table.AutoXResizeMode(true);
   m_table.AutoXResizeRightOffset(10);
   m_table.AutoYResizeMode(true);
   m_table.AutoYResizeBottomOffset(40);
   m_window_main.AddChild(&m_table);
   if(!m_table.CreateTable(chart_id,0,"TestTable",10,30))
      return INIT_FAILED;
   int widths[]={90,45,60,100,85,45,40};
   m_table.View().GetHeaderViewPointer().ColumnsWidth(widths);
   ENUM_ALIGN_MODE align[]={ALIGN_LEFT,ALIGN_CENTER,ALIGN_RIGHT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT};
   m_table.View().GetHeaderViewPointer().TextAlign(align);
   int image_x[]={3,3,3,3,3,15,12};
   m_table.View().GetHeaderViewPointer().ImageXOffset(image_x);
   for(int r=0; r<25; r++)
      SetupRow(r);
   m_table.View().Rebuild(true);

   m_window_main.AddChild(&m_btn_add);
   m_btn_add.SetText("Add row");
   if(!m_btn_add.Create(chart_id,0,"TestTableAdd",10,310-30,100,20))
      return INIT_FAILED;
   m_window_main.AddChild(&m_btn_delete);
   m_btn_delete.SetText("Delete selected");
   if(!m_btn_delete.Create(chart_id,0,"TestTableDelete",120,310-30,120,20))
      return INIT_FAILED;

   ::MathSrand((uint)::GetTickCount());
   ::EventSetMillisecondTimer(TIMER_STEP_MSC);
   ::ChartRedraw(chart_id);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   ::EventKillTimer();
  }

void OnTick(void)
  {
  }

void OnTimer(void)
  {
   m_window_main.OnTimerEvent();
   static uint last=0;
   if(::GetTickCount()-last<250)
      return;
   last=::GetTickCount();
   uint rows=m_table.Model().RowsTotal();
   for(uint r=0; r<rows; r++)
     {
      if(::MathRand()%3!=0)
         continue;
      CTableCell *cell=m_table.Cell(COL_PROFIT,r);
      double profit=::NormalizeDouble(cell.ValueD()+(::MathRand()%201-100)/100.0,2);
      cell.SetValue(profit);
      color clr=(profit>0 ? clrGreen : profit<0 ? clrRed : clrBlack);
      if(m_table.CellView(COL_PROFIT,r).TextColor()!=clr)
         m_table.CellView(COL_PROFIT,r).TextColor(clr);
     }
   m_table.Update(true);
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   m_window_main.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_add.ObjectID())
     {
      m_table.AddRow();
      SetupRow((int)m_table.Model().RowsTotal()-1);
      m_table.View().Rebuild(true);
     }
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_delete.ObjectID())
      m_table.DeleteRow(m_table.View().SelectedItem(),true);
   if(lparam==m_table.ObjectID() && id>CHARTEVENT_CUSTOM)
     {
      string parts[];
      ::StringSplit(sparam,'_',parts);
      int row=(ArraySize(parts)==2 ? (int)::StringToInteger(parts[1]) : -1);
      CTableCell *symbol=(row>=0 ? m_table.Cell(COL_SYMBOL,row) : NULL);
      CTableCell *mode  =(row>=0 ? m_table.Cell(COL_SL_MODE,row) : NULL);
      CTableCell *volume=(row>=0 ? m_table.Cell(COL_VOLUME,row) : NULL);
      ::Print("MY DEBUG TestTable::OnChartEvent: event=",id-CHARTEVENT_CUSTOM," dparam=",dparam," sparam=",sparam,
              " symbol=",(symbol!=NULL ? symbol.ValueS() : ""),
              " mode=",(mode!=NULL ? mode.ValueS() : ""),
              " volume=",(volume!=NULL ? volume.Value() : ""));
     }
  }
