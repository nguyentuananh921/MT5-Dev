//+------------------------------------------------------------------+
//|                                               TableControl.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Table management class |
//+------------------------------------------------------------------+
#ifndef __TABLECONTROL_MQH__
#define __TABLECONTROL_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "Panel.mqh"
   class CTable;
   class CTableView;
   class CTableRowView;
   class CTableCell; 
  class CTableControl : public CPanel
  {
   private:
   // --- Returns the maximum value of an integer array
      bool              ArrayMaximumValue(int &array[],int &value);
   // --- Returns the maximum text width in the row header array
      int               GetMaximumRowCaptionTextSize(string &array_row_captions[]);
      
   protected:
      CListObj          m_list_table_model;
   // --- Adds a (1) model (CTable), (2) visual representation (CTableView) table object to the list
      bool              TableModelAdd(CTable *table_model,const int table_id,const string source);
      CTableView       *TableViewAdd(CTable *table_model,string &row_names[],const string source);
   // --- Updates the specified column of the specified table
      bool              ColumnUpdate(const string source, CTable *table_model, const uint table, const uint col, const bool cells_redraw);
      
   public:
   // --- Returns (1) model, (2) table view object, (3) object type
      CTable           *GetTableModel(const uint index)              { return this.m_list_table_model.GetNodeAtIndex(index);  }
      CTableView       *GetTableView(const uint index)               { return this.GetAttachedElementAt(index);               }
      
   // --- Creating a table based on the transferred data
   template<typename T>
      CTableView       *TableCreate(T &row_data[][],const string &column_names[],const int table_id=WRONG_VALUE);
      CTableView       *TableCreate(const uint num_rows, const uint num_columns,const int table_id=WRONG_VALUE);
      CTableView       *TableCreate(const matrix &row_data,const string &column_names[],const int table_id=WRONG_VALUE);
      CTableView       *TableCreate(CList &row_data,const string &column_names[],const int table_id=WRONG_VALUE);
   template<typename T>
      CTableView       *TableCreate(T &row_data[][],const string &column_names[],string &row_names[],const int table_id=WRONG_VALUE);
      CTableView       *TableCreate(const uint num_rows, const uint num_columns,string &row_names[],const int table_id=WRONG_VALUE);
      CTableView       *TableCreate(const matrix &row_data,const string &column_names[],string &row_names[],const int table_id=WRONG_VALUE);
      CTableView       *TableCreate(CList &row_data,const string &column_names[],string &row_names[],const int table_id=WRONG_VALUE);
      
   // --- Returns (1) the string value of the specified cell (Model), the specified (2) row, (3) table cell (View)
      string            CellValueAt(const uint table, const uint row, const uint col);
      CTableRowView    *GetRowView(const uint table, const uint index);
      CTableCellView   *GetCellView(const uint table, const uint row, const uint col);
      
   // --- Sets (1) value, (2) precision, (3) time display flags, (4) color name display flag in the specified cell (Model + View)
   template<typename T>
      void              CellSetValue(const uint table, const uint row, const uint col, const T value, const bool chart_redraw);
      void              CellSetDigits(const uint table, const uint row, const uint col, const int digits, const bool chart_redraw);
      void              CellSetTimeFlags(const uint table, const uint row, const uint col, const uint flags, const bool chart_redraw);
      void              CellSetColorNamesFlag(const uint table, const uint row, const uint col, const bool flag, const bool chart_redraw);

   // --- Sets the color of (1) foreground, (2) background to the specified cell (View)
      void              CellSetForeColor(const uint table, const uint row, const uint col, const color clr, const bool chart_redraw);
      void              CellSetBackColor(const uint table, const uint row, const uint col, const color clr, const bool chart_redraw);
      
   // --- (1) Sets, (2) returns the text anchor point in the specified cell (View)
      void              CellSetTextAnchor(const uint table, const uint row, const uint col, const ENUM_ANCHOR_POINT anchor,const bool cell_redraw,const bool chart_redraw);
      ENUM_ANCHOR_POINT CellTextAnchor(const uint table, const uint row, const uint col);
      
   // --- Sets (1) precision, (2) time display flags, (3) color name display flag, (4) text anchor point, (5) data type in the specified column (View)
      void              ColumnSetDigits(const uint table, const uint col, const int digits, const bool cells_redraw, const bool chart_redraw);
      void              ColumnSetTimeFlags(const uint table, const uint col, const uint flags, const bool cells_redraw, const bool chart_redraw);
      void              ColumnSetColorNamesFlag(const uint table, const uint col, const bool flag, const bool cells_redraw, const bool chart_redraw);
      void              ColumnSetTextAnchor(const uint table, const uint col, const ENUM_ANCHOR_POINT anchor, const bool cells_redraw, const bool chart_redraw);
      void              ColumnSetDatatype(const uint table, const uint col, const ENUM_DATATYPE type, const bool cells_redraw, const bool chart_redraw);

   // --- Returns the number of (1) rows, (2) cells per row in the specified table
      uint              RowsTotal(const uint table);
      uint              CellsInRow(const uint table,const uint row);

   // --- Sets (1) the row highlighting mode, (2) the ability to sort the specified table
      void              SetRowsHighlightMode(const uint table,const ENUM_ROWS_HIGHLIGHT_MODE highlight_mode);
      void              SetSortable(const uint table,const bool flag);
      
   // ---Object type
      virtual int       Type(void)                             const { return(ELEMENT_TYPE_TABLE_CONTROL_VIEW);               }

   // --- Constructors/destructor
                        CTableControl(void) { this.m_list_table_model.Clear(); }
                        CTableControl(const string object_name, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                     ~CTableControl(void) {}
  };
 #ifndef CTABLECONTROL_IMPLEMENTATION
 #define CTABLECONTROL_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | Constructor |
   //+------------------------------------------------------------------+
   CTableControl::CTableControl(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
      CPanel(object_name,"",chart_id,wnd,x,y,w,h)
    {
      this.m_list_table_model.Clear();
      this.SetName("Table Control");
    }
   //+------------------------------------------------------------------+
   // | Returns the maximum value of an integer array |
   //+------------------------------------------------------------------+
   bool CTableControl::ArrayMaximumValue(int &array[],int &value)
    {
      ::ResetLastError();
      int index=::ArrayMaximum(array);
      if(index<0)
      {
         ::PrintFormat("%s: ArrayMaximum() failed. Error %d",__FUNCTION__,::GetLastError());
         return false;
      }
      value=array[index];
      return true;
    }
   //+------------------------------------------------------------------+
   // | Returns the maximum width of the text in the row header array |
   //+------------------------------------------------------------------+
   int CTableControl::GetMaximumRowCaptionTextSize(string &row_captions[])
    {
      int total=(int)row_captions.Size();
      if(total==0)
         return 0;

      int array[]={};
      ::ArrayResize(array,total);
      for(int i=0;i<total;i++)
      {
         string text=row_captions[i];
         text.TrimLeft();
         text.TrimRight();
         array[i]=this.m_foreground.TextWidth(text);
      }
      int value=0;
      return(this.ArrayMaximumValue(array,value) ? value : 0);
    }
   //+------------------------------------------------------------------+
   // | Adds a table model object (CTable) to the list |
   //+------------------------------------------------------------------+
   bool CTableControl::TableModelAdd(CTable *table_model,const int table_id,const string source)
    {
     // --- Checking the table model object
      if(table_model==NULL)
      {
         ::PrintFormat("%s::%s: Error. Failed to create Table Model object",source,__FUNCTION__);
         return false;
      }
     // --- We set an identifier in the table model - either by the size of the list or a given one
      table_model.SetID(table_id<0 ? this.m_list_table_model.Total() : table_id);
     // --- If a table model with a set identifier is in the list, we report this, delete the object and return false
      this.m_list_table_model.Sort(0);
      if(this.m_list_table_model.Search(table_model)!=NULL)
      {
         ::PrintFormat("%s::%s: Error: Table Model object with ID %d already exists in the list",source,__FUNCTION__,table_id);
         delete table_model;
         return false;
      }
     // --- If the table model is not added to the list, we report this, delete the object and return false
      if(this.m_list_table_model.Add(table_model)<0)
      {
         ::PrintFormat("%s::%s: Error. Failed to add Table Model object to list",source,__FUNCTION__);
         delete table_model;
         return false;
      }
     // --- Everything is successful
      return true;
    }
   //+------------------------------------------------------------------+
   //| Creates a new object and adds it to the list |
   //| visual table view (CTableView) |
   //+------------------------------------------------------------------+
   CTableView *CTableControl::TableViewAdd(CTable *table_model,string &row_names[],const string source)
    {
     // --- Checking the table model object
      if(table_model==NULL)
      {
         ::PrintFormat("%s::%s: Error. An invalid Table Model object was passed",source,__FUNCTION__);
         return NULL;
      }
     // --- Get the maximum width of the row header text
      int w=this.GetMaximumRowCaptionTextSize(row_names);
      if(w>0 && w<DEF_TABLE_ROWS_HEADER_W)
         w=DEF_TABLE_ROWS_HEADER_W;
         
     // --- Create a new element - a visual representation of the table, attached to the panel
      CTableView *table_view=this.InsertNewElement(ELEMENT_TYPE_TABLE_VIEW,(string)w,"TableView"+(string)table_model.ID(),1,1,this.Width()-2,this.Height()-2);
      if(table_view==NULL)
      {
         ::PrintFormat("%s::%s: Error. Failed to create Table View object",source,__FUNCTION__);
         return NULL;
      }
     // --- Assign the table object (Model) and its identifier to the graphic element “Table” (View)
      table_view.TableObjectAssign(table_model);
      table_view.CreateRowsHeader(row_names);
      table_view.SetID(table_model.ID());
      return table_view;
    }
   //+-------------------------------------------------------------------+
   // | Creates a table specifying a table array and a header array. |
   // | Determines the number and names of columns according to column_names|
   // | The number of rows is determined by the size of the data array row_data, |
   // | which is also used to fill out the table |
   //+-------------------------------------------------------------------+
   template<typename T>
   CTableView *CTableControl::TableCreate(T &row_data[][],const string &column_names[],const int table_id=WRONG_VALUE)
    {
     // --- Create a table object using the specified parameters
      CTable *table_model=new CTable(row_data,column_names);
     // --- If there are errors when creating or adding a table to the list, return NULL
      if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
         return NULL;
      
     // --- Create and return a table with an empty array of row headers
      string array[]={};
      return this.TableViewAdd(table_model,array,__FUNCTION__);
    }
   //+------------------------------------------------------------------+
   // | Creates a table defining the number of columns and rows.       |
   // | The columns will have Excel names "A", "B", "C", etc.      |
   //+------------------------------------------------------------------+
   CTableView *CTableControl::TableCreate(const uint num_rows,const uint num_columns,const int table_id=WRONG_VALUE)
    {
      CTable *table_model=new CTable(num_rows,num_columns);
     // --- If there are errors when creating or adding a table to the list, return NULL
      if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
         return NULL;
      
     // --- Create and return a table with an empty array of row headers
      string array[]={};
      return this.TableViewAdd(table_model,array,__FUNCTION__);
    }
   //+------------------------------------------------------------------+
   // | Creates a table with columns initialized according to column_names |
   // | The number of rows is determined by the row_data parameter, with type matrix |
   //+------------------------------------------------------------------+
   CTableView *CTableControl::TableCreate(const matrix &row_data,const string &column_names[],const int table_id=WRONG_VALUE)
    {
      CTable *table_model=new CTable(row_data,column_names);
     // --- If there are errors when creating or adding a table to the list, return NULL
      if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
         return NULL;
      
     // --- Create and return a table with an empty array of row headers
      string array[]={};
      return this.TableViewAdd(table_model,array,__FUNCTION__);
    }
   //+------------------------------------------------------------------+
   // | Creates a table specifying a table array based on |
   // | row_data list containing objects with structure field data.  |
   // | Determines the number and names of columns according to the quantity |
   // | column names in the column_names array |
   //+------------------------------------------------------------------+
   CTableView *CTableControl::TableCreate(CList &row_data,const string &column_names[],const int table_id=WRONG_VALUE)
    {
      CTableByParam *table_model=new CTableByParam(row_data,column_names);
     // --- If there are errors when creating or adding a table to the list, return NULL
      if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
         return NULL;
      
     // --- Create and return a table with an empty array of row headers
      string array[]={};
      return this.TableViewAdd(table_model,array,__FUNCTION__);
    }
   //+-------------------------------------------------------------------+
   // | Creates a table specifying a table array and a header array. |
   // | Determines the number and names of columns according to column_names|
   // | The number of rows is determined by the size of the data array row_data, |
   // | which is also used to fill out the table |
   //+-------------------------------------------------------------------+
   template<typename T>
   CTableView *CTableControl::TableCreate(T &row_data[][],const string &column_names[],string &row_names[],const int table_id=WRONG_VALUE)
    {
     // --- Create a table object using the specified parameters
      CTable *table_model=new CTable(row_data,column_names);
     // --- If there are errors when creating or adding a table to the list, return NULL
      if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
         return NULL;

     // --- Create and return the table
      return this.TableViewAdd(table_model,row_names,__FUNCTION__);
    }
   //+------------------------------------------------------------------+
   // | Creates a table defining the number of columns and rows.       |
   // | The columns will have Excel names "A", "B", "C", etc.      |
   //+------------------------------------------------------------------+
   CTableView *CTableControl::TableCreate(const uint num_rows,const uint num_columns,string &row_names[],const int table_id=WRONG_VALUE)
    {
      CTable *table_model=new CTable(num_rows,num_columns);
     // --- If there are errors when creating or adding a table to the list, return NULL
      if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
         return NULL;
      
     // --- Create and return the table
      return this.TableViewAdd(table_model,row_names,__FUNCTION__);
    }
   //+------------------------------------------------------------------+
   // | Creates a table with columns initialized according to column_names |
   // | The number of rows is determined by the row_data parameter, with type matrix |
   //+------------------------------------------------------------------+
   CTableView *CTableControl::TableCreate(const matrix &row_data,const string &column_names[],string &row_names[],const int table_id=WRONG_VALUE)
    {
      CTable *table_model=new CTable(row_data,column_names);
     // --- If there are errors when creating or adding a table to the list, return NULL
      if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
         return NULL;
      
     // --- Create and return the table
      return this.TableViewAdd(table_model,row_names,__FUNCTION__);
    }
   //+------------------------------------------------------------------+
   // | Creates a table specifying a table array based on |
   // | row_data list containing objects with structure field data.  |
   // | Determines the number and names of columns according to the quantity |
   // | column names in the column_names array |
   //+------------------------------------------------------------------+
   CTableView *CTableControl::TableCreate(CList &row_data,const string &column_names[],string &row_names[],const int table_id=WRONG_VALUE)
    {
      CTableByParam *table_model=new CTableByParam(row_data,column_names);
     // --- If there are errors when creating or adding a table to the list, return NULL
      if(!this.TableModelAdd(table_model,table_id,__FUNCTION__))
         return NULL;
      
     // --- Create and return the table
      return this.TableViewAdd(table_model,row_names,__FUNCTION__);
    }
   //+------------------------------------------------------------------+
   // | Sets the value to the specified cell (Model + View) |
   //+------------------------------------------------------------------+
   template<typename T>
   void CTableControl::CellSetValue(const uint table,const uint row,const uint col,const T value,const bool chart_redraw)
    {
     // --- Getting the table model
      CTable *table_model=this.GetTableModel(table);
      if(table_model==NULL)
         return;
      
     // --- From the table model we get the cell model
      CTableCell *cell_model=table_model.GetCell(row,col);
      if(cell_model==NULL)
         return;
         
     // --- Get the visual representation object of the cell
      CTableCellView *cell_view=this.GetCellView(table,row,col);
      if(cell_view==NULL)
         return;
         
     // --- Compare the value set in the cell with the value passed
      bool equal=false;
      ENUM_DATATYPE datatype=cell_model.Datatype();
      switch(datatype)
      {
         case TYPE_LONG    :  
         case TYPE_DATETIME:  
         case TYPE_COLOR   :  equal=(cell_model.ValueL()==value);                                           break;
         case TYPE_DOUBLE  :  equal=(::NormalizeDouble(cell_model.ValueD()-value,cell_model.Digits())==0);  break;
         //---TYPE_STRING
         default           :  equal=(::StringCompare(cell_model.ValueS(),(string)value)==0);                break;
      }
     // --- If the values ​​are equal, we leave
      if(equal)
         return;
         
     // --- We set a new value in the cell model;
     // --- enter the value from the cell model into the visual representation object of the cell
     // --- Redraw the cell with the graph update flag
      table_model.CellSetValue(row,col,value);
      cell_view.SetText(cell_model.Value());
      cell_view.Draw(chart_redraw);
    }
   //+------------------------------------------------------------------+
   // | Sets the precision to the specified cell (Model + View) |
   //+------------------------------------------------------------------+
   void CTableControl::CellSetDigits(const uint table,const uint row,const uint col,const int digits,const bool chart_redraw)
    {
     // --- Getting the table model
      CTable *table_model=this.GetTableModel(table);
      if(table_model==NULL)
         return;
      
     // --- From the table model we get the cell model
      CTableCell *cell_model=table_model.GetCell(row,col);
      if(cell_model==NULL || cell_model.Digits()==digits)
         return;
         
     // --- Get the visual representation object of the cell
      CTableCellView *cell_view=this.GetCellView(table,row,col);
      if(cell_view==NULL)
         return;
      
     // --- We set a new precision value in the cell model;
     // --- enter the value from the cell model into the visual representation object of the cell
     // --- Redraw the cell with the graph update flag
      table_model.CellSetDigits(row,col,digits);
      cell_view.SetText(cell_model.Value());
      cell_view.Draw(chart_redraw);
    }
   //+------------------------------------------------------------------+
   //| Sets time display flags                                          |
   //| to the specified cell (Model + View)                             |
   //+------------------------------------------------------------------+
   void CTableControl::CellSetTimeFlags(const uint table,const uint row,const uint col,const uint flags,const bool chart_redraw)
    {
     // --- Getting the table model
      CTable *table_model=this.GetTableModel(table);
      if(table_model==NULL)
         return;
      
     // --- From the table model we get the cell model
      CTableCell *cell_model=table_model.GetCell(row,col);
      if(cell_model==NULL || cell_model.DatetimeFlags()==flags)
         return;
         
     // --- Get the visual representation object of the cell
      CTableCellView *cell_view=this.GetCellView(table,row,col);
      if(cell_view==NULL)
         return;
      
     // --- We set a new value for the time display flags in the cell model;
     // --- enter the value from the cell model into the visual representation object of the cell
     // --- Redraw the cell with the graph update flag
      table_model.CellSetTimeFlags(row,col,flags);
      cell_view.SetText(cell_model.Value());
      cell_view.Draw(chart_redraw);
    }
   //+------------------------------------------------------------------+
   // | Sets the color name display flag |
   // | to the specified cell (Model + View) |
   //+------------------------------------------------------------------+
   void CTableControl::CellSetColorNamesFlag(const uint table,const uint row,const uint col,const bool flag,const bool chart_redraw)
    {
     // --- Getting the table model
      CTable *table_model=this.GetTableModel(table);
      if(table_model==NULL)
         return;
      
     // --- From the table model we get the cell model
      CTableCell *cell_model=table_model.GetCell(row,col);
      if(cell_model==NULL || cell_model.ColorNameFlag()==flag)
         return;
         
     // --- Get the visual representation object of the cell
      CTableCellView *cell_view=this.GetCellView(table,row,col);
      if(cell_view==NULL)
         return;
      
     // --- Set a new value for the flag for displaying color names in the cell model;
     // --- enter the value from the cell model into the visual representation object of the cell
     // --- Redraw the cell with the graph update flag
      table_model.CellSetColorNamesFlag(row,col,flag);
      cell_view.SetText(cell_model.Value());
      cell_view.Draw(chart_redraw);
    }
   //+------------------------------------------------------------------+
   //| Sets the foreground color to the specified cell (View)           |
   //+------------------------------------------------------------------+
   void CTableControl::CellSetForeColor(const uint table,const uint row,const uint col,const color clr,const bool chart_redraw)
    {
     // --- Get the visual representation object of the cell
      CTableCellView *cell_view=this.GetCellView(table,row,col);
      if(cell_view==NULL)
         return;
      
     // --- Set the cell text color to the cell visual representation object
     // --- Redraw the cell with the graph update flag
      cell_view.SetForeColor(clr);
      cell_view.Draw(chart_redraw);
    }
   //+------------------------------------------------------------------+
   // | Sets the background color to the specified cell (View)          |
   //+------------------------------------------------------------------+
   void CTableControl::CellSetBackColor(const uint table,const uint row,const uint col,const color clr,const bool chart_redraw)
    {
     // --- Get the visual representation object of the cell
      CTableCellView *cell_view=this.GetCellView(table,row,col);
      if(cell_view==NULL)
         return;
      
     // --- Set the cell background color to the cell visual representation object
     // --- Redraw the cell with the graph update flag
      cell_view.SetBackColor(clr);
      cell_view.Draw(chart_redraw);
    }
   //+------------------------------------------------------------------+
   // | Sets the text anchor point to the specified cell (View)         |
   //+------------------------------------------------------------------+
   void CTableControl::CellSetTextAnchor(const uint table,const uint row,const uint col,const ENUM_ANCHOR_POINT anchor,const bool cell_redraw,const bool chart_redraw)
    {
     // --- Get the visual representation object of the cell
      CTableCellView *cell_view=this.GetCellView(table,row,col);
      if(cell_view==NULL)
         return;
      
     // --- Set the text anchor point to the visual representation object of the cell
     // --- Redraw the cell with the graph update flag
      cell_view.SetTextAnchor(anchor,cell_redraw,chart_redraw);
    }
   //+------------------------------------------------------------------+
   //| Returns the text anchor point in the specified cell (View)       |
   //+------------------------------------------------------------------+
   ENUM_ANCHOR_POINT CTableControl::CellTextAnchor(const uint table,const uint row,const uint col)
    {
     // --- Get the visual representation object of the cell
      CTableCellView *cell_view=this.GetCellView(table,row,col);
      if(cell_view==NULL)
         return ANCHOR_LEFT_UPPER;
      
     // --- Return the text anchor point
      return((ENUM_ANCHOR_POINT)cell_view.TextAnchor());
    }
   //+------------------------------------------------------------------+
   //| Updates the specified column of the specified table              |
   //+------------------------------------------------------------------+
   bool CTableControl::ColumnUpdate(const string source,CTable *table_model,const uint table,const uint col,const bool cells_redraw)
    {
     // --- Checking the table model
      if(::CheckPointer(table_model)==POINTER_INVALID)
      {
         ::PrintFormat("%s::%s: Error. Invalid table model pointer passed",source,__FUNCTION__);
         return false;
      }
     // --- Getting a visual representation of the table
      CTableView *table_view=this.GetTableView(table);
      if(table_view==NULL)
      {
         ::PrintFormat("%s::%s: Error. Failed to get CTableView object",source,__FUNCTION__);
         return false;
      }
      
     // --- In a loop through the rows of the visual representation of the table
      int total=table_view.RowsTotal();
      for(int i=0;i<total;i++)
      {
         // --- we obtain from the next row of the table a visual representation of the cell in the specified column
         CTableCellView *cell_view=this.GetCellView(table,i,col);
         if(cell_view==NULL)
         {
            ::PrintFormat("%s::%s: Error. Failed to get CTableCellView object (row %d, col %u)",source,__FUNCTION__,i,col);
            return false;
         }
         // --- Get the model of the corresponding cell from the row model
         CTableCell *cell_model=table_model.GetCell(i,col);
         if(cell_model==NULL)
         {
            ::PrintFormat("%s::%s: Error. Failed to get CTableCell object (row %d, col %u)",source,__FUNCTION__,i,col);
            return false;
         }
         
         // --- We write the value from the cell model to the visual representation object of the cell
         cell_view.SetText(cell_model.Value());
         // --- If specified, redraw the visual representation of the cell
         if(cells_redraw)
            cell_view.Draw(false);
      }
      return true;
    }
   //+------------------------------------------------------------------+
   //| Sets the precision in the specified column (Model + View)        |
   //+------------------------------------------------------------------+
   void CTableControl::ColumnSetDigits(const uint table,const uint col,const int digits,const bool cells_redraw,const bool chart_redraw)
   {
     // --- Getting the table model
      CTable *table_model=this.GetTableModel(table);
      if(table_model==NULL)
      {
         ::PrintFormat("%s: Error. Failed to get CTable object",__FUNCTION__);
         return;
      }
     // --- Set Digits for the specified column in the table model
      table_model.ColumnSetDigits(col,digits);

     // --- Update the column data display and, if specified, redraw the graph
      if(this.ColumnUpdate(__FUNCTION__,table_model,table,col,cells_redraw) && chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | Устанавливает флаги отображения времени                         |
   // | in the specified column (Model + View) |
   //+------------------------------------------------------------------+
   void CTableControl::ColumnSetTimeFlags(const uint table,const uint col,const uint flags,const bool cells_redraw,const bool chart_redraw)
    {
     // --- Getting the table model
      CTable *table_model=this.GetTableModel(table);
      if(table_model==NULL)
      {
         ::PrintFormat("%s: Error. Failed to get CTable object",__FUNCTION__);
         return;
      }
     // --- Set the time display flags for the specified column in the table model
      table_model.ColumnSetTimeFlags(col,flags);

     // --- Update the column data display and, if specified, redraw the graph
      if(this.ColumnUpdate(__FUNCTION__,table_model,table,col,cells_redraw) && chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | Sets the color name display flag |
   // | in the specified column (Model + View) |
   //+------------------------------------------------------------------+
   void CTableControl::ColumnSetColorNamesFlag(const uint table,const uint col,const bool flag,const bool cells_redraw,const bool chart_redraw)
    {
     // --- Getting the table model
      CTable *table_model=this.GetTableModel(table);
      if(table_model==NULL)
      {
         ::PrintFormat("%s: Error. Failed to get CTable object",__FUNCTION__);
         return;
      }
     // --- Set the time display flags for the specified column in the table model
      table_model.ColumnSetColorNamesFlag(col,flag);

     // --- Update the column data display and, if specified, redraw the graph
      if(this.ColumnUpdate(__FUNCTION__,table_model,table,col,cells_redraw) && chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | Sets the data type in the specified column ( (Model + View)) |
   //+------------------------------------------------------------------+
   void CTableControl::ColumnSetDatatype(const uint table,const uint col,const ENUM_DATATYPE type,const bool cells_redraw,const bool chart_redraw)
    {
     // --- Getting the table model
      CTable *table_model=this.GetTableModel(table);
      if(table_model==NULL)
      {
         ::PrintFormat("%s: Error. Failed to get CTable object",__FUNCTION__); 
         return;
      }
     // --- Set the data type for the specified column in the table model
      table_model.ColumnSetDatatype(col,type);

     // --- Update the column data display and, if specified, redraw the graph
      if(this.ColumnUpdate(__FUNCTION__,table_model,table,col,cells_redraw) && chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   //| Sets the text anchor point in the specified column (View) |
   //+------------------------------------------------------------------+
   void CTableControl::ColumnSetTextAnchor(const uint table,const uint col,const ENUM_ANCHOR_POINT anchor,const bool cells_redraw,const bool chart_redraw)
    {
     // --- Getting a visual representation of the table
      CTableView *table_view=this.GetTableView(table);
      if(table_view==NULL)
      {
         ::PrintFormat("%s: Error. Failed to get CTableView object",__FUNCTION__);
         return;
      }
     // --- In a loop through all rows of the table
      int total=table_view.RowsTotal();
      for(int i=0;i<total;i++)
      {
         // --- we get the next object of visual representation of the cell
         // --- and insert a new anchor point into the object
         CTableCellView *cell_view=this.GetCellView(table,i,col);
         if(cell_view!=NULL && cell_view.TextAnchor()!=anchor)
            cell_view.SetTextAnchor(anchor,cells_redraw,false);
      }
     // --- If indicated, update the schedule
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | Returns the string value of the specified cell (Model) |
   //+------------------------------------------------------------------+
   string CTableControl::CellValueAt(const uint table,const uint row,const uint col)
    {
      CTable *table_model=this.GetTableModel(table);
      return(table_model!=NULL ? table_model.CellValueAt(row,col) : ::StringFormat("%s: Error. Failed to get table model",__FUNCTION__));
    }
   //+------------------------------------------------------------------+
   // | Returns the specified table row (View) |
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
   //| Returns the specified table cell (View) |
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
   //+------------------------------------------------------------------+
   //| Returns the number of rows in the specified table |
   //+------------------------------------------------------------------+
   uint CTableControl::RowsTotal(const uint table)
    {
      CTableView *table_view=this.GetTableView(table);
      if(table_view==NULL)
      {
         ::PrintFormat("%s: Error. Failed to get CTableView object",__FUNCTION__);
         return NULL;
      }
      return table_view.RowsTotal();
    }
   //+------------------------------------------------------------------+
   // | Returns the number of cells per row in the specified table |
   //+------------------------------------------------------------------+
   uint CTableControl::CellsInRow(const uint table,const uint row)
    {
      CTableRowView *row_view=this.GetRowView(table,row);
      return(row_view!=NULL ? row_view.CellsTotal() : 0);
    }
   //+------------------------------------------------------------------+
   // | Sets the highlighting mode for the rows of the specified table |
   //+------------------------------------------------------------------+
   void CTableControl::SetRowsHighlightMode(const uint table,const ENUM_ROWS_HIGHLIGHT_MODE highlight_mode)
    {
      CTableView *table_view=this.GetTableView(table);
      if(table_view==NULL)
      {
         ::PrintFormat("%s: Error. Failed to get CTableView object",__FUNCTION__);
         return;
      }
      table_view.SetRowsHighlightMode(highlight_mode);
    }
   //+------------------------------------------------------------------+
   // | Sets the ability to sort the specified table |
   //+------------------------------------------------------------------+
   void CTableControl::SetSortable(const uint table,const bool flag)
    {
      CTableView *table_view=this.GetTableView(table);
      if(table_view==NULL)
      {
         ::PrintFormat("%s: Error. Failed to get CTableView object",__FUNCTION__);
         return;
      }
      table_view.SetSortable(flag);
    }
   //+------------------------------------------------------------------+
 #endif // CTABLECONTROL_IMPLEMENTATION
#endif // __TABLECONTROL_MQH__


