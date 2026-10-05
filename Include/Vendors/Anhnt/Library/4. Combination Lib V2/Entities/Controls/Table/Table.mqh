//+------------------------------------------------------------------+
//|                                                        Table.mqh |
//| Kazharski control API over the MVC model/view split              |
//+------------------------------------------------------------------+
#property strict

#ifndef CTABLE_MQH
#define CTABLE_MQH
 #include "View\TableView.mqh"
#ifndef CTABLE_MQH_DECLARATION
#define CTABLE_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Model (data) + View (child element) + controller (this class):   |
//| view actions change the model, events go out with this table's id|
//+------------------------------------------------------------------+
class CTable : public CGElement
 {
  private:
    CTableModel       m_model;
    CTableView        m_view;
    bool              m_auto_xresize_mode;
    bool              m_auto_yresize_mode;
    int               m_auto_xresize_right_offset;
    int               m_auto_yresize_bottom_offset;

    void              SetCellFromText(CTableCell *cell,const string text);
  protected:
    virtual void      InitColors(void);
  public:
    bool              CreateTable(const long chart_id,const int subwin,const string name,const int x,const int y,const int w=0,const int h=0);
    CTableModel      *Model(void)                                { return(::GetPointer(this.m_model)); }
    CTableView       *View(void)                                 { return(::GetPointer(this.m_view));  }
    bool              CellIndexes(const string cell_id,int &column,int &row);
    void              TableSize(const int columns_total,const int rows_total);
    CTableRow        *AddRow(const int row_index=WRONG_VALUE,const bool redraw=false);
    void              DeleteRow(const int row_index,const bool redraw=false);
    void              DeleteAllRows(const bool redraw=false);
    void              SetHeaderText(const uint column_index,const string value)   { this.m_model.Header().SetCaption((int)column_index,value); }
    void              SetHeaderImage(const uint column_index,const uint &resource_index[]) { this.m_view.GetHeaderViewPointer().SetHeaderImage(column_index,resource_index); }
    template<typename T> void SetValue(const uint column_index,const uint row_index,const T value) { this.m_model.CellSetValue(row_index,column_index,value); }
    CTableCell       *Cell(const uint column_index,const uint row_index)         { return(this.m_model.Cell(row_index,column_index)); }
    CTableCellView   *CellView(const uint column_index,const uint row_index)     { CTableRowView *row=this.m_view.RowViewByModel((int)row_index); return(row!=NULL ? row.CellView((int)column_index) : NULL); }
    void              SortData(const uint column_index,const ENUM_CSORT_MODE direction);
    void              AutoXResizeMode(const bool mode)           { this.m_auto_xresize_mode=mode;           }
    void              AutoYResizeMode(const bool mode)           { this.m_auto_yresize_mode=mode;           }
    void              AutoXResizeRightOffset(const int offset)   { this.m_auto_xresize_right_offset=offset; }
    void              AutoYResizeBottomOffset(const int offset)  { this.m_auto_yresize_bottom_offset=offset; }
    bool              Update(const bool redraw=false)            { return(this.m_view.Update(redraw)); }
    virtual void      ChangeWidthByRightWindowSide(void);
    virtual void      ChangeHeightByBottomWindowSide(void);
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
                     CTable(void);
                    ~CTable(void) {}
 };
#endif // CTABLE_MQH_DECLARATION
#ifndef CTABLE_MQH_IMPLEMENTATION
#define CTABLE_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTable::CTable(void) : m_auto_xresize_mode(false),
                       m_auto_yresize_mode(false),
                       m_auto_xresize_right_offset(0),
                       m_auto_yresize_bottom_offset(0)
 {
 }
//+------------------------------------------------------------------+
//| The shell itself draws nothing                                   |
//+------------------------------------------------------------------+
void CTable::InitColors(void)
 {
  this.m_color_background.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_border.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_background_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_border_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
 }
//+------------------------------------------------------------------+
//| View options go before; w/h < 1 or auto mode: up to the parent   |
//| right/bottom edge minus the offsets                              |
//+------------------------------------------------------------------+
bool CTable::CreateTable(const long chart_id,const int subwin,const string name,const int x,const int y,const int w=0,const int h=0)
 {
  int tw=w,th=h;
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  if(parent!=NULL && (tw<1 || this.m_auto_xresize_mode))
     tw=parent.Width()-x-this.m_auto_xresize_right_offset;
  if(parent!=NULL && (th<1 || this.m_auto_yresize_mode))
     th=parent.Height()-y-this.m_auto_yresize_bottom_offset;
  tw=::MathMax(tw,1);
  th=::MathMax(th,1);
  if(!this.Create(chart_id,subwin,name,x,y,tw,th))
     return(false);
  this.AddChild(::GetPointer(this.m_view));
  this.m_view.Bind(::GetPointer(this.m_model));
  return(this.m_view.CreateTableView(chart_id,subwin,this.Name()+"_view",0,0,tw,th));
 }
//+------------------------------------------------------------------+
//| Kazharski order: columns, rows                                   |
//+------------------------------------------------------------------+
void CTable::TableSize(const int columns_total,const int rows_total)
 {
  this.m_model.CreateTableModel(rows_total,columns_total);
  this.m_view.Rebuild(false);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTableRow *CTable::AddRow(const int row_index=WRONG_VALUE,const bool redraw=false)
 {
  CTableRow *row=this.m_model.AddRow(row_index);
  this.m_view.Rebuild(redraw);
  return(row);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTable::DeleteRow(const int row_index,const bool redraw=false)
 {
  if(row_index>=0 && this.m_model.RowDelete(row_index))
     this.m_view.Rebuild(redraw);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTable::DeleteAllRows(const bool redraw=false)
 {
  this.m_model.DeleteAllRows();
  this.m_view.Rebuild(redraw);
 }
//+------------------------------------------------------------------+
//| Kazharski SortData: model sorted, header arrow, view rebuilt     |
//+------------------------------------------------------------------+
void CTable::SortData(const uint column_index,const ENUM_CSORT_MODE direction)
 {
  this.m_model.SortByColumn(column_index,direction==SORT_DESCEND);
  this.m_view.GetHeaderViewPointer().SortState((int)column_index,direction);
  this.m_view.Rebuild(true,true);
 }
//+------------------------------------------------------------------+
//| "column_row" -> indexes                                          |
//+------------------------------------------------------------------+
bool CTable::CellIndexes(const string cell_id,int &column,int &row)
 {
  string parts[];
  if(::StringSplit(cell_id,'_',parts)!=2)
     return(false);
  column=(int)::StringToInteger(parts[0]);
  row   =(int)::StringToInteger(parts[1]);
  return(true);
 }
//+------------------------------------------------------------------+
//| Edited text back into the cell's own data type                   |
//+------------------------------------------------------------------+
void CTable::SetCellFromText(CTableCell *cell,const string text)
 {
  switch(cell.Datatype())
    {
     case TYPE_DOUBLE:
        cell.SetValue(::StringToDouble(text));
        break;
     case TYPE_DATETIME:
        cell.SetValue(::StringToTime(text));
        break;
     case TYPE_STRING:
        cell.SetValue(text);
        break;
     default:
        cell.SetValue(::StringToInteger(text));
        break;
    }
 }
//+------------------------------------------------------------------+
//| Auto x-resize: follow the parent's right edge                    |
//+------------------------------------------------------------------+
void CTable::ChangeWidthByRightWindowSide(void)
 {
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  if(!this.m_auto_xresize_mode || parent==NULL)
     return;
  int w=parent.Width()-this.m_x_gap-this.m_auto_xresize_right_offset;
  this.Resize(w,this.m_y_size);
  this.m_view.ChangeSize(w,this.m_y_size);
 }
//+------------------------------------------------------------------+
//| Auto y-resize: follow the parent's bottom edge                   |
//+------------------------------------------------------------------+
void CTable::ChangeHeightByBottomWindowSide(void)
 {
  CGElement *parent=dynamic_cast<CGElement *>(this.m_parent);
  if(!this.m_auto_yresize_mode || parent==NULL)
     return;
  int h=parent.Height()-this.m_y_gap-this.m_auto_yresize_bottom_offset;
  this.Resize(this.m_x_size,h);
  this.m_view.ChangeSize(this.m_x_size,h);
 }
//+------------------------------------------------------------------+
//| Controller: view actions change the model, then every event is   |
//| re-shouted with this id                                          |
//+------------------------------------------------------------------+
void CTable::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  CGElement::OnChartEvent(id,lparam,dparam,sparam);
  if(id<=CHARTEVENT_CUSTOM || lparam!=this.m_view.ObjectID())
     return;
  ushort event_id=(ushort)(id-CHARTEVENT_CUSTOM);
  int    column=0,row=0;
  if(event_id==ON_SORT_DATA)
    {
     CTableHeaderView *header=this.m_view.GetHeaderViewPointer();
     int sorted=(int)dparam;
     ENUM_CSORT_MODE direction=(header.SortedColumn()==sorted && header.SortDirection()==SORT_ASCEND ? SORT_DESCEND : SORT_ASCEND);
     this.SortData(sorted,direction);
     this.SendEvent(ON_SORT_DATA,sorted,(string)(int)direction);
     return;
    }
  if(!this.CellIndexes(sparam,column,row))
     return;
  CTableCell *cell=this.Cell(column,row);
  if(event_id==ON_CLICK_CHECKBOX && cell!=NULL)
    {
     cell.SetValue((long)(cell.ValueL()!=0 ? 0 : 1));
     this.m_view.Update(true);
     this.SendEvent(ON_CLICK_CHECKBOX,(double)cell.ValueL(),sparam);
     return;
    }
  if(event_id==ON_CLICK_COMBOBOX_ITEM && cell!=NULL)
    {
     CTableCellView *view=this.CellView(column,row);
     if(view!=NULL)
        cell.SetValue(view.ValueListItem((int)dparam));
     this.m_view.Update(true);
     this.SendEvent(ON_CLICK_COMBOBOX_ITEM,dparam,sparam);
     return;
    }
  if(event_id==ON_END_EDIT && cell!=NULL)
    {
     this.SetCellFromText(cell,this.m_view.EditedValue());
     this.m_view.Update(true);
     this.SendEvent(ON_END_EDIT,(cell.Datatype()==TYPE_DOUBLE ? cell.ValueD() : (double)cell.ValueL()),sparam);
     return;
    }
  if(event_id==ON_CLICK_BUTTON || event_id==ON_CLICK_LIST_ITEM)
     this.SendEvent(event_id,dparam,sparam);
 }
#endif // CTABLE_MQH_IMPLEMENTATION
#endif // CTABLE_MQH
