//+------------------------------------------------------------------+
//|                                                ColumnsWindow.mqh |
//| A small window to show, hide and move the columns of a CTable at |
//| run time: a list with a check for each column (in the order the  |
//| table shows them), Up and Down for the selected one, Reset       |
//+------------------------------------------------------------------+
#property strict

#ifndef CCOLUMNSWINDOW_MQH
#define CCOLUMNSWINDOW_MQH
 #include "..\Window.mqh"
 #include "..\ListView.mqh"
 #include "..\Button.mqh"
 #include "Table.mqh"
 #define COLUMNS_WINDOW_WIDTH     190
 #define COLUMNS_WINDOW_ROWS_MAX  12
#ifndef CCOLUMNSWINDOW_MQH_DECLARATION
#define CCOLUMNSWINDOW_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Asks the table what it shows and tells it what the user chose;   |
//| tells the outside with ON_TABLE_COLUMNS_CHANGED (lparam = the    |
//| ObjectID of the table), for whoever keeps the layout             |
//+------------------------------------------------------------------+
class CColumnsWindow : public CWindow
 {
  private:
    CTable           *m_table;          // not owned
    CListView         m_list;
    CButton           m_button_up;
    CButton           m_button_down;
    CButton           m_button_reset;
    int               m_column_at[];    // the column of the table in each row of the list
    string            CaptionOf(const int column);
    void              Fill(const int select_column);
    void              Notify(void);
  public:
    bool              CreateColumnsWindow(const long chart_id,const int subwin,const int x,const int y,CTable *table);
    void              Open(void);       // the list is filled again, then the window is shown
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
                     CColumnsWindow(void) : m_table(NULL) {}
                    ~CColumnsWindow(void) {}
 };
#endif // CCOLUMNSWINDOW_MQH_DECLARATION
#ifndef CCOLUMNSWINDOW_MQH_IMPLEMENTATION
#define CCOLUMNSWINDOW_MQH_IMPLEMENTATION
 bool CColumnsWindow::CreateColumnsWindow(const long chart_id,const int subwin,const int x,const int y,CTable *table)
  {
   if(table==NULL)
      return false;
   this.m_table=table;
   int total=table.View().GetHeaderViewPointer().ColumnsTotal();
   int rows=::MathMin(total,COLUMNS_WINDOW_ROWS_MAX);
   int item_h=20;
   int list_h=rows*item_h+4;
   int top=WINDOW_CAPTION_HEIGHT+M_CONTROL_BORDER_GAP;
   int buttons_y=top+list_h+M_CONTROL_BORDER_GAP;
   int height=buttons_y+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP+2;
   this.Hide();   // born hidden: the children inherit it
   this.FontSize(DEF_FONT_SIZE);
   this.IsMovable(true);
   this.ResizeMode(false);
   this.CloseButtonIsUsed(true);
   this.CollapseButtonIsUsed(false);
   this.TooltipsButtonIsUsed(false);
   this.FullscreenButtonIsUsed(false);
   if(!this.CreateWindow(chart_id,subwin,"Columns",x,y,COLUMNS_WINDOW_WIDTH,height))
      return false;
   int inner=COLUMNS_WINDOW_WIDTH-2*M_CONTROL_BORDER_GAP;
   this.m_list.CheckBoxMode(true);
   this.m_list.LightsHover(true);
   this.m_list.ItemYSize(item_h);
   this.AddChild(&this.m_list);
   if(!this.m_list.CreateListView(chart_id,subwin,"ColumnsList",M_CONTROL_BORDER_GAP,top,inner,list_h))
      return false;
   int button_w=(inner-2*M_CONTROL_BORDER_GAP)/3;
   this.AddChild(&this.m_button_up);
   this.AddChild(&this.m_button_down);
   this.AddChild(&this.m_button_reset);
   if(!this.m_button_up.Create(chart_id,subwin,"ColumnsUp",M_CONTROL_BORDER_GAP,buttons_y,button_w,M_CONTROL_HEIGHT) ||
      !this.m_button_down.Create(chart_id,subwin,"ColumnsDown",2*M_CONTROL_BORDER_GAP+button_w,buttons_y,button_w,M_CONTROL_HEIGHT) ||
      !this.m_button_reset.Create(chart_id,subwin,"ColumnsReset",3*M_CONTROL_BORDER_GAP+2*button_w,buttons_y,button_w,M_CONTROL_HEIGHT))
      return false;
   this.m_button_up.SetText("Up");
   this.m_button_down.SetText("Down");
   this.m_button_reset.SetText("Reset");
   this.m_button_up.Draw(false);
   this.m_button_down.Draw(false);
   this.m_button_reset.Draw(false);
   return true;
  }
 //--- The caption of the header, or "Column n" when the header has only an icon
 string CColumnsWindow::CaptionOf(const int column)
  {
   string caption=this.m_table.Model().Header().Caption(column);
   return (caption=="" ? "Column "+(string)(column+1) : caption);
  }
 //--- The list follows the table: one row for each column, in the order the table shows them, checked when shown
 void CColumnsWindow::Fill(const int select_column)
  {
   CTableHeaderView *header=this.m_table.View().GetHeaderViewPointer();
   int total=header.ColumnsTotal();
   ::ArrayResize(this.m_column_at,total);
   this.m_list.Rebuilding(total,false);
   int select=0;
   for(int p=0;p<total;p++)
     {
      int column=header.ColumnOrder(p);
      this.m_column_at[p]=column;
      this.m_list.SetValue(p,this.CaptionOf(column));
      this.m_list.SetState(p,header.ColumnShown(column));
      if(column==select_column)
         select=p;
     }
   this.m_list.SelectItem(select,false);
   this.m_list.Draw(true);
  }
 void CColumnsWindow::Notify(void)
  {
   ::EventChartCustom(this.ChartID(),(ushort)ON_TABLE_COLUMNS_CHANGED,(long)this.m_table.ObjectID(),0.0,"");
  }
 void CColumnsWindow::Open(void)
  {
   if(this.m_table==NULL)
      return;
   this.Fill(WRONG_VALUE);
   this.Show();
   ::ChartRedraw(this.ChartID());
  }
 //+------------------------------------------------------------------+
 //| A click on a row (it flips the check): the table shows or hides  |
 //| the column; Up and Down move the selected one; Reset: as made    |
 //+------------------------------------------------------------------+
 void CColumnsWindow::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   CWindow::OnChartEvent(id,lparam,dparam,sparam);
   if(this.m_table==NULL || !this.IsVisible() || id<CHARTEVENT_CUSTOM)
      return;
   int event=id-CHARTEVENT_CUSTOM;
   int selected=this.m_list.SelectedItemIndex();
   int column=(selected>=0 && selected<ArraySize(this.m_column_at) ? this.m_column_at[selected] : WRONG_VALUE);
   if(event==ON_CLICK_LIST_ITEM && lparam==(long)this.m_list.ObjectID())
     {
      if(column==WRONG_VALUE)
         return;
      this.m_table.ColumnShown(column,this.m_list.GetState(selected));
      this.Fill(column);   // the table refuses to hide the last column: the list shows what the table has
      this.Notify();
     }
   else if(event==ON_CLICK_BUTTON)
     {
      if(lparam==(long)this.m_button_up.ObjectID() || lparam==(long)this.m_button_down.ObjectID())
        {
         if(column==WRONG_VALUE)
            return;
         if(this.m_table.MoveColumn(column,lparam==(long)this.m_button_up.ObjectID() ? -1 : 1))
           {
            this.Fill(column);
            this.Notify();
           }
        }
      else if(lparam==(long)this.m_button_reset.ObjectID())
        {
         this.m_table.ColumnsReset();
         this.Fill(column);
         this.Notify();
        }
     }
  }
#endif // CCOLUMNSWINDOW_MQH_IMPLEMENTATION
#endif // CCOLUMNSWINDOW_MQH
