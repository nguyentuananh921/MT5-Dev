//+------------------------------------------------------------------+
//|                                                  TableControl.mqh|
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __TABLE_CONTROL_MQH__
#define __TABLE_CONTROL_MQH__
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "Panel.mqh"
#include "../Table/ListObj.mqh"
//--- Forward declaration of control element classes
class CTable;
class CTableView;
class CTableRowView;
class CTableCellView;
class CTableCell;

//+------------------------------------------------------------------+
//| Table management class                                           |
//+------------------------------------------------------------------+
class CTableControl : public CPanel
{
   protected:
      CListObj m_list_table_model;

   //--- Adds (1) a table model object (CTable), (2) a table view object (CTableView) to the list
      bool        TableModelAdd(CTable *table_model,const int table_id,const string source);
      CTableView *TableViewAdd(CTable *table_model,const string source);

   //--- Updates the specified column of the specified table
      bool        ColumnUpdate(const string source,CTable *table_model,const uint table,const uint col,const bool cells_redraw);

   public:

   //--- Returns (1) table model, (2) table view object
      CTable     *GetTable(const uint index)             { return this.m_list_table_model.GetNodeAtIndex(index); }
      CTableView *GetTableView(const uint index)         { return this.GetAttachedElementAt(index);              }

   //--- Create table based on provided data
   template<typename T>
      CTableView *TableCreate(T &row_data[][],const string &column_names[],const int table_id=WRONG_VALUE);

      CTableView *TableCreate(const uint num_rows,const uint num_columns,const int table_id=WRONG_VALUE);

      CTableView *TableCreate(const matrix &row_data,const string &column_names[],const int table_id=WRONG_VALUE);

      CTableView *TableCreate(CList &row_data,const string &column_names[],const int table_id=WRONG_VALUE);

   //--- Returns (1) string value of specified cell (Model), (2) row view, (3) cell view
      string          CellValueAt(const uint table,const uint row,const uint col);
      CTableRowView  *GetRowView(const uint table,const uint index);
      CTableCellView *GetCellView(const uint table,const uint row,const uint col);

   //--- Set (1) value, (2) digits precision, (3) time display flags,
   //--- (4) color name display flag for specified cell (Model + View)
   template<typename T>
      void CellSetValue(const uint table,const uint row,const uint col,const T value,const bool chart_redraw);

      void CellSetDigits(const uint table,const uint row,const uint col,const int digits,const bool chart_redraw);
      void CellSetTimeFlags(const uint table,const uint row,const uint col,const uint flags,const bool chart_redraw);
      void CellSetColorNamesFlag(const uint table,const uint row,const uint col,const bool flag,const bool chart_redraw);

   //--- Set foreground color of specified cell (View)
      void CellSetForeColor(const uint table,const uint row,const uint col,const color clr,const bool chart_redraw);

   //--- (1) Set, (2) get text anchor point in specified cell (View)
      void              CellSetTextAnchor(const uint table,const uint row,const uint col,const ENUM_ANCHOR_POINT anchor,const bool cell_redraw,const bool chart_redraw);
      ENUM_ANCHOR_POINT CellTextAnchor(const uint table,const uint row,const uint col);

   //--- Set for specified column:
   //--- (1) digits precision
   //--- (2) time display flags
   //--- (3) color name display flag
   //--- (4) text anchor point
   //--- (5) data type
      void ColumnSetDigits(const uint table,const uint col,const int digits,const bool cells_redraw,const bool chart_redraw);
      void ColumnSetTimeFlags(const uint table,const uint col,const uint flags,const bool cells_redraw,const bool chart_redraw);
      void ColumnSetColorNamesFlag(const uint table,const uint col,const bool flag,const bool cells_redraw,const bool chart_redraw);
      void ColumnSetTextAnchor(const uint table,const uint col,const ENUM_ANCHOR_POINT anchor,const bool cells_redraw,const bool chart_redraw);
      void ColumnSetDatatype(const uint table,const uint col,const ENUM_DATATYPE type,const bool cells_redraw,const bool chart_redraw);

   //--- Object type
      virtual int Type(void) const { return(ELEMENT_TYPE_TABLE_CONTROL_VIEW); }

   //--- Constructors / destructor
               CTableControl(void) { this.m_list_table_model.Clear(); }
               CTableControl(const string object_name, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
               ~CTableControl(void) {}
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTableControl::CTableControl(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CPanel(object_name,"",chart_id,wnd,x,y,w,h)
  {
   this.m_list_table_model.Clear();
   this.SetName("Table Control");
  }

//+------------------------------------------------------------------+
//| Adds a table model object (CTable) to the internal list          |
//+------------------------------------------------------------------+
bool CTableControl::TableModelAdd(CTable *table_model,const int table_id,const string source)
  {
//--- Check the table model object
   if(table_model==NULL)
     {
      ::PrintFormat("%s::%s: Error. Failed to create Table Model object",source,__FUNCTION__);
      return false;
     }
//--- Set ID: use provided ID or default to list size
   table_model.SetID(table_id<0 ? this.m_list_table_model.Total() : table_id);
//--- Ensure ID is unique by searching the sorted list
   this.m_list_table_model.Sort(0);
   if(this.m_list_table_model.Search(table_model)!=NULL)
     {
      ::PrintFormat("%s::%s: Error: Table Model ID %d already exists",source,__FUNCTION__,table_id);
      delete table_model;
      return false;
     }
//--- Add model to list
   if(this.m_list_table_model.Add(table_model)<0)
     {
      ::PrintFormat("%s::%s: Error. Failed to add Table Model object to list",source,__FUNCTION__);
      delete table_model;
      return false;
     }
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| Creates and adds a new Table View object (CTableView)            |
//+------------------------------------------------------------------+
CTableView *CTableControl::TableViewAdd(CTable *table_model,const string source)
  {
//--- Validate model
   if(table_model==NULL)
     {
      ::PrintFormat("%s::%s: Error. Invalid Table Model object passed",source,__FUNCTION__);
      return NULL;
     }
//--- Create new View element attached to this panel
   CTableView *table_view=this.InsertNewElement(ELEMENT_TYPE_TABLE_VIEW,"","TableView"+(string)table_model.ID(),1,1,this.Width()-2,this.Height()-2);
   if(table_view==NULL)
     {
      ::PrintFormat("%s::%s: Error. Failed to create Table View object",source,__FUNCTION__);
      return NULL;
     }
//--- Sync View with Model
   table_view.TableObjectAssign(table_model);
   table_view.SetID(table_model.ID());
   return table_view;
  }

//+-------------------------------------------------------------------+
//| Create Table using 2D Array and Header names                      |
//+-------------------------------------------------------------------+
template<typename T>
CTableView *CTableControl::TableCreate(T &row_data[][],const string &column_names[],const int table_id=WRONG_VALUE)
  {
   CTable *table_model=new CTable(row_data,column_names);
   if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
      return NULL;
   
   return this.TableViewAdd(table_model,__FUNCTION__);
  }

//+------------------------------------------------------------------+
//| Set value in a specific cell (Updates both Model + View)         |
//+------------------------------------------------------------------+
template<typename T>
void CTableControl::CellSetValue(const uint table,const uint row,const uint col,const T value,const bool chart_redraw)
  {
//--- Get Model and Cell
   CTable *table_model=this.GetTable(table);
   if(table_model==NULL) return;
   
   CTableCell *cell_model=table_model.GetCell(row,col);
   if(cell_model==NULL) return;
      
//--- Get UI Cell View
   CTableCellView *cell_view=this.GetCellView(table,row,col);
   if(cell_view==NULL) return;
      
//--- Optimization: Compare new value with current value
   bool equal=false;
   ENUM_DATATYPE datatype=cell_model.Datatype();
   switch(datatype)
     {
      case TYPE_LONG:  
      case TYPE_DATETIME:  
      case TYPE_COLOR:   equal=(cell_model.ValueL()==value); break;
      case TYPE_DOUBLE:  equal=(::NormalizeDouble(cell_model.ValueD()-value,cell_model.Digits())==0); break;
      default:           equal=(::StringCompare(cell_model.ValueS(),(string)value)==0); break;
     }
//--- Exit if value hasn't changed to save resources
   if(equal) return;
      
//--- Update Model, sync UI text, and redraw
   table_model.CellSetValue(row,col,value);
   cell_view.SetText(cell_model.Value());
   cell_view.Draw(chart_redraw);
  }

//+------------------------------------------------------------------+
//| Update an entire column in a specific table                      |
//+------------------------------------------------------------------+
bool CTableControl::ColumnUpdate(const string source,CTable *table_model,const uint table,const uint col,const bool cells_redraw)
  {
//--- Pointer check
   if(::CheckPointer(table_model)==POINTER_INVALID)
     {
      ::PrintFormat("%s::%s: Error. Invalid table model pointer",source,__FUNCTION__);
      return false;
     }
//--- Get Table View
   CTableView *table_view=this.GetTableView(table);
   if(table_view==NULL) return false;
   
//--- Loop through all rows to update the specified column
   int total=table_view.RowsTotal();
   for(int i=0;i<total;i++)
     {
      CTableCellView *cell_view=this.GetCellView(table,i,col);
      CTableCell *cell_model=table_model.GetCell(i,col);
      
      if(cell_view!=NULL && cell_model!=NULL)
        {
         cell_view.SetText(cell_model.Value());
         if(cells_redraw)
            cell_view.Draw(false);
        }
     }
   return true;
  }
  //+------------------------------------------------------------------+
//| CTableControl::Sets digits precision for a specific column       |
//| (Updates both Model + View)                                      |
//+------------------------------------------------------------------+
void CTableControl::ColumnSetDigits(const uint table,const uint col,const int digits,const bool cells_redraw,const bool chart_redraw)
  {
//--- Get the table model
   CTable *table_model=this.GetTable(table);
   if(table_model==NULL)
     {
      ::PrintFormat("%s: Error. Failed to get CTable object",__FUNCTION__);
      return;
     }
//--- Set Digits for the specified column in the table model 
   table_model.ColumnSetDigits(col,digits);

//--- Update column data display and redraw chart if requested
   if(this.ColumnUpdate(__FUNCTION__,table_model,table,col,cells_redraw) && chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }

//+------------------------------------------------------------------+
//| CTableControl::Sets datetime display flags for a specific column |
//| (Updates both Model + View)                                      |
//+------------------------------------------------------------------+
void CTableControl::ColumnSetTimeFlags(const uint table,const uint col,const uint flags,const bool cells_redraw,const bool chart_redraw)
  {
//--- Get the table model
   CTable *table_model=this.GetTable(table);
   if(table_model==NULL)
     {
      ::PrintFormat("%s: Error. Failed to get CTable object",__FUNCTION__);
      return;
     }
//--- Set time display flags for the specified column in the model 
   table_model.ColumnSetTimeFlags(col,flags);

//--- Sync UI and redraw chart if requested
   if(this.ColumnUpdate(__FUNCTION__,table_model,table,col,cells_redraw) && chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }

//+------------------------------------------------------------------+
//| CTableControl::Sets color name display flag for a specific column|
//| (Updates both Model + View)                                      |
//+------------------------------------------------------------------+
void CTableControl::ColumnSetColorNamesFlag(const uint table,const uint col,const bool flag,const bool cells_redraw,const bool chart_redraw)
  {
   CTable *table_model=this.GetTable(table);
   if(table_model==NULL)
     {
      ::PrintFormat("%s: Error. Failed to get CTable object",__FUNCTION__);
      return;
     }
//--- Set color name flag in the model 
   table_model.ColumnSetColorNamesFlag(col,flag);

//--- Update display
   if(this.ColumnUpdate(__FUNCTION__,table_model,table,col,cells_redraw) && chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }

//+------------------------------------------------------------------+
//| CTableControl::Sets data type for a specific column              |
//| (Updates both Model + View)                                      |
//+------------------------------------------------------------------+
void CTableControl::ColumnSetDatatype(const uint table,const uint col,const ENUM_DATATYPE type,const bool cells_redraw,const bool chart_redraw)
  {
   CTable *table_model=this.GetTable(table);
   if(table_model==NULL)
     {
      ::PrintFormat("%s: Error. Failed to get CTable object",__FUNCTION__);
      return;
     }
//--- Set data type (int, double, string, etc.) for the column 
   table_model.ColumnSetDatatype(col,type);

//--- Update display
   if(this.ColumnUpdate(__FUNCTION__,table_model,table,col,cells_redraw) && chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }

//+------------------------------------------------------------------+
//| CTableControl::Sets text anchor point for a specific column      |
//| (Updates View only)                                              |
//+------------------------------------------------------------------+
void CTableControl::ColumnSetTextAnchor(const uint table,const uint col,const ENUM_ANCHOR_POINT anchor,const bool cells_redraw,const bool chart_redraw)
  {
//--- Get the table view
   CTableView *table_view=this.GetTableView(table);
   if(table_view==NULL)
     {
      ::PrintFormat("%s: Error. Failed to get CTableView object",__FUNCTION__);
      return;
     }
//--- Loop through all table rows
   int total=table_view.RowsTotal();
   for(int i=0;i<total;i++)
     {
      //--- Get cell view and set new anchor if it differs from current
      CTableCellView *cell_view=this.GetCellView(table,i,col);
      if(cell_view!=NULL && cell_view.TextAnchor()!=anchor)
          cell_view.SetTextAnchor(anchor,cells_redraw,false);
     }
//--- Redraw chart if requested
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }

//+------------------------------------------------------------------+
//| CTableControl::Returns string value of a specific cell (Model)   |
//+------------------------------------------------------------------+
string CTableControl::CellValueAt(const uint table,const uint row,const uint col)
  {
   CTable *table_model=this.GetTable(table);
   return(table_model!=NULL ? table_model.CellValueAt(row,col) : ::StringFormat("%s: Error. Failed to get table model",__FUNCTION__));
  }

//+------------------------------------------------------------------+
//| CTableControl::Returns a specific table row (View)               |
//+------------------------------------------------------------------+
CTableRowView *CTableControl::GetRowView(const uint table,const uint index)
  {
   CTableView *table_view=this.GetTableView(table);
   if(table_view==NULL)
     {
      ::PrintFormat("%s: Error. Failed to get CTableView object",__FUNCTION__);
      return NULL;
     }
   return table_view.GetRowView(index);
  }

//+------------------------------------------------------------------+
//| CTableControl::Returns a specific table cell (View)              |
//+------------------------------------------------------------------+
CTableCellView *CTableControl::GetCellView(const uint table,const uint row,const uint col)
  {
   CTableView *table_view=this.GetTableView(table);
   if(table_view==NULL)
     {
      ::PrintFormat("%s: Error. Failed to get CTableView object",__FUNCTION__);
      return NULL;
     }
   return table_view.GetCellView(row,col);
  }
#endif