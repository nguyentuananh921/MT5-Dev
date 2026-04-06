//+------------------------------------------------------------------+
//|                                               TableByParam.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in             https://www.mql5.com/en/articles/17653  |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Table class                                                      |
//+------------------------------------------------------------------+
#ifndef __TABLE_MQH__
#define __TABLE_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   #include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+	
   #include "..\Collections\ListObj.mqh"
   #include "TableCell.mqh"
   #include "MqlParamObj.mqh"
   #include "TableModel.mqh"
   #include "TableHeader.mqh"
 class CTable : public CObject 
   {
      private:
      // --- Populates an Excel-style array of column headers
         bool              FillArrayExcelNames(const uint num_columns);
      // --- Returns the column name as in Excel
         string            GetExcelColumnName(uint column_number);
      // --- Returns header availability
         bool              HeaderCheck(void) const { return(this.m_table_header!=NULL && this.m_table_header.ColumnsTotal()>0);  }
         
      protected:
         CTableModel      *m_table_model;                               // Pointer to table model
         CTableHeader     *m_table_header;                              // Pointer to table header
         CList             m_list_rows;                                 // List of parameter arrays from structure fields
         string            m_array_names[];                             // Column header array
         int               m_id;                                        // Table ID
      // --- Copies an array of header names
         bool              ArrayNamesCopy(const string &column_names[],const uint columns_total);
         
      public:
      // --- (1) Sets, (2) returns the table model
         void              SetTableModel(CTableModel *table_model)      { this.m_table_model=table_model;      }
         CTableModel      *GetTableModel(void)                          { return this.m_table_model;           }
      // --- (1) Sets, (2) returns header
         void              SetTableHeader(CTableHeader *table_header)   { this.m_table_header=m_table_header;  }
         CTableHeader     *GetTableHeader(void)                         { return this.m_table_header;          }

      // --- (1) Sets, (2) returns the table identifier
         void              SetID(const int id)                          { this.m_id=id;                        }
         int               ID(void)                               const { return this.m_id;                    }
         
      // --- Clears column header data
         void              HeaderClearData(void)
                           {
                              if(this.m_table_header!=NULL)
                                 this.m_table_header.ClearData();
                           }
      // --- Removes the table header
         void              HeaderDestroy(void)
                           {
                              if(this.m_table_header==NULL)
                                 return;
                              this.m_table_header.Destroy();
                              this.m_table_header=NULL;
                           }
                           
      // --- (1) Clears all data, (2) destroys table model and header
         void              ClearData(void)
                           {
                              if(this.m_table_model!=NULL)
                                 this.m_table_model.ClearData();
                           }
         void              Destroy(void)
                           {
                              if(this.m_table_model==NULL)
                                 return;
                              this.m_table_model.Destroy();
                              this.m_table_model=NULL;
                           }
         
      // --- Returns (1) title, (2) cell, (3) row by index, number of (4) rows, (5) columns, cells (6) in the specified row, (7) in the table
         CColumnCaption   *GetColumnCaption(const uint index)        { return(this.m_table_header!=NULL  ?  this.m_table_header.GetColumnCaption(index)  :  NULL);   }
         CTableCell       *GetCell(const uint row, const uint col)   { return(this.m_table_model!=NULL   ?  this.m_table_model.GetCell(row,col)          :  NULL);   }
         CTableRow        *GetRow(const uint index)                  { return(this.m_table_model!=NULL   ?  this.m_table_model.GetRow(index)             :  NULL);   }
         uint              RowsTotal(void)                     const { return(this.m_table_model!=NULL   ?  this.m_table_model.RowsTotal()               :  0);      }
         uint              ColumnsTotal(void)                  const { return(this.m_table_model!=NULL   ?  this.m_table_model.CellsInRow(0)             :  0);      }
         uint              CellsInRow(const uint index)              { return(this.m_table_model!=NULL   ?  this.m_table_model.CellsInRow(index)         :  0);      }
         uint              CellsTotal(void)                          { return(this.m_table_model!=NULL   ?  this.m_table_model.CellsTotal()              :  0);      }

      // --- Sets (1) value, (2) precision, (3) time display flags, (4) color name display flag to specified cell
      template<typename T>
         void              CellSetValue(const uint row, const uint col, const T value);
         void              CellSetDigits(const uint row, const uint col, const int digits);
         void              CellSetTimeFlags(const uint row, const uint col, const uint flags);
         void              CellSetColorNamesFlag(const uint row, const uint col, const bool flag);
      // --- (1) Assigns, (2) cancels an object in a cell
         void              CellAssignObject(const uint row, const uint col,CObject *object);
         void              CellUnassignObject(const uint row, const uint col);
      // --- Returns the string value of the specified cell
         virtual string    CellValueAt(const uint row, const uint col);

      protected:
      // --- (1) Deletes (2) moves a cell
         bool              CellDelete(const uint row, const uint col);
         bool              CellMoveTo(const uint row, const uint cell_index, const uint index_to);
         
      public:
      // --- (1) Returns, (2) logs the description of the cell, (3) the object assigned to the cell
         string            CellDescription(const uint row, const uint col);
         void              CellPrint(const uint row, const uint col);
      // ---Returns (1) the object assigned to the cell, (2) the type of the object assigned to the cell
         CObject          *CellGetObject(const uint row, const uint col);
         ENUM_OBJECT_TYPE  CellGetObjType(const uint row, const uint col);
         
      // --- Creates a new line and (1) appends it to the end of the list, (2) inserts it at the specified position in the list
         CTableRow        *RowAddNew(void);
         CTableRow        *RowInsertNewTo(const uint index_to);
      // --- (1) Deletes (2) moves a row, (3) clears row data
         bool              RowDelete(const uint index);
         bool              RowMoveTo(const uint row_index, const uint index_to);
         void              RowClearData(const uint index);
      // --- (1) Returns, (2) logs the description of the string
         string            RowDescription(const uint index);
         void              RowPrint(const uint index,const bool detail);
         
      // --- (1) Add new, (2) delete, (3) move column, (4) clear column data
         bool              ColumnAddNew(const string caption,const int index=-1);
         bool              ColumnDelete(const uint index);
         bool              ColumnMoveTo(const uint index, const uint index_to);
         void              ColumnClearData(const uint index);
         
      // --- Sets (1) the value of the specified header, (2) the accuracy of the data,
      // --- flags for displaying (3) time, (4) color names to the specified column
         void              ColumnCaptionSetValue(const uint index,const string value);
         void              ColumnSetDigits(const uint index,const int digits);
         void              ColumnSetTimeFlags(const uint index,const uint flags);
         void              ColumnSetColorNamesFlag(const uint col, const bool flag);
         
      // --- (1) Sets, (2) returns the data type for the specified column
         void              ColumnSetDatatype(const uint index,const ENUM_DATATYPE type);
         ENUM_DATATYPE     ColumnDatatype(const uint index);
         
      // --- (1) Returns, (2) logs a description of the object
         virtual string    Description(void);
         void              Print(const int column_width=CELL_WIDTH_IN_CHARS);
      
      // --- Sorts the table by the specified column and direction
         void              SortByColumn(const uint column, const bool descending)
                           {
                              if(this.m_table_model!=NULL)
                                 this.m_table_model.SortByColumn(column,descending);
                           }
         
      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0) const;
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                             const { return(OBJECT_TYPE_TABLE);           }
         
      // --- Constructors/destructor
                           CTable(void) : m_table_model(NULL), m_table_header(NULL) { this.m_list_rows.Clear();}
      template<typename T> CTable(T &row_data[][],const string &column_names[]);
                           CTable(const uint num_rows, const uint num_columns);
                           CTable(const matrix &row_data,const string &column_names[]);
                           ~CTable (void);
   };
   //+-------------------------------------------------------------------+
   // | Constructor specifying a table array and an array of headers.     |
   // | Determines the number and names of columns according to column_names|
   // | The number of rows is determined by the size of the data array row_data, |
   // | which is also used to fill out the table |
   //+-------------------------------------------------------------------+
  template<typename T>
  CTable::CTable(T &row_data[][],const string &column_names[]) : m_id(-1)
   {
      this.m_table_model=new CTableModel(row_data);
      if(column_names.Size()>0)
         this.ArrayNamesCopy(column_names,row_data.Range(1));
      else
      {
         ::PrintFormat("%s: An empty array names was passed. The header array will be filled in Excel style (A, B, C)",__FUNCTION__);
         this.FillArrayExcelNames((uint)::ArrayRange(row_data,1));
      }
      this.m_table_header=new CTableHeader(this.m_array_names);
   }
   //+------------------------------------------------------------------+
   //| Table constructor with determination of the number of columns and rows.   |
   //| The columns will have Excel names "A", "B", "C", etc.      |
   //+------------------------------------------------------------------+
  CTable::CTable(const uint num_rows,const uint num_columns) : m_table_header(NULL), m_id(-1)
   {
      this.m_table_model=new CTableModel(num_rows,num_columns);
      if(this.FillArrayExcelNames(num_columns))
         this.m_table_header=new CTableHeader(this.m_array_names);
   }
   //+-------------------------------------------------------------------+
   // | Table constructor with columns initialized according to column_names|
   // | The number of rows is determined by the row_data parameter, with type matrix |
   //+-------------------------------------------------------------------+
   CTable::CTable(const matrix &row_data,const string &column_names[]) : m_id(-1)
   {
      this.m_table_model=new CTableModel(row_data);
      if(column_names.Size()>0)
         this.ArrayNamesCopy(column_names,(uint)row_data.Cols());
      else
      {
         ::PrintFormat("%s: An empty array names was passed. The header array will be filled in Excel style (A, B, C)",__FUNCTION__);
         this.FillArrayExcelNames((uint)row_data.Cols());
      }
      this.m_table_header=new CTableHeader(this.m_array_names);
   }
   //+------------------------------------------------------------------+
   // | Destructor |
   //+------------------------------------------------------------------+
   CTable::~CTable(void)
   {
      if(this.m_table_model!=NULL)
      {
         this.m_table_model.Destroy();
         delete this.m_table_model;
      }
      if(this.m_table_header!=NULL)
      {
         this.m_table_header.Destroy();
         delete this.m_table_header;
      }
   }
   //+------------------------------------------------------------------+
   // | Comparison of two objects |
   //+------------------------------------------------------------------+
   int CTable::Compare(const CObject *node,const int mode=0) const
   {
      if(node==NULL)
         return -1;
      const CTable *obj=node;
      return(this.ID()>obj.ID() ? 1 : this.ID()<obj.ID() ? -1 : 0);
   }
   //+------------------------------------------------------------------+
   // | Returns the column name as in Excel |
   //+------------------------------------------------------------------+
   string CTable::GetExcelColumnName(uint column_number)
   {
      string column_name="";
      uint index=column_number;

   // --- Check that the column number is greater than 0
      if(index==0)
         return (__FUNCTION__+": Error. Invalid column number passed");
      
   // --- Convert number to column name
      while(!::IsStopped() && index>0)
      {
         index--;                                           // Decrease the number by 1 to make it 0-index
         uint  remainder =index % 26;                       // Remainder of division by 26
         uchar char_code ='A'+(uchar)remainder;             // Calculate the code of a character (letter)
         column_name=::CharToString(char_code)+column_name; // Add a letter to the beginning of the line
         index/=26;                                         // Let's move on to the next level
      }
      return column_name;
   }
   //+------------------------------------------------------------------+
   // | Fills an array of column headers in Excel style |
   //+------------------------------------------------------------------+
   bool CTable::FillArrayExcelNames(const uint num_columns)
   {
      ::ResetLastError();
      if(::ArrayResize(this.m_array_names,num_columns,num_columns)!=num_columns)
      {
         ::PrintFormat("%s: ArrayResize() failed. Error %d",__FUNCTION__,::GetLastError());
         return false;
      }
      for(int i=0;i<(int)num_columns;i++)
         this.m_array_names[i]=this.GetExcelColumnName(i+1);

      return true;
   }
   //+------------------------------------------------------------------+
   // | Copies an array of header names |
   //+------------------------------------------------------------------+
   bool CTable::ArrayNamesCopy(const string &column_names[],const uint columns_total)
   {
      if(columns_total==0)
      {
         ::PrintFormat("%s: Error. The table has no columns",__FUNCTION__);
         return false;
      }
      if(columns_total>column_names.Size())
      {
         ::PrintFormat("%s: The number of header names is less than the number of columns. The header array will be filled in Excel style (A, B, C)",__FUNCTION__);
         return this.FillArrayExcelNames(columns_total);
      }
      uint total=::fmin(columns_total,column_names.Size());
      return(::ArrayCopy(this.m_array_names,column_names,0,0,total)==total);
   }
   //+------------------------------------------------------------------+
   // | Sets the value to the specified cell |
   //+------------------------------------------------------------------+
   template<typename T>
   void CTable::CellSetValue(const uint row, const uint col, const T value)
   {
      if(this.m_table_model!=NULL)
         this.m_table_model.CellSetValue(row,col,value);
   }
   //+------------------------------------------------------------------+
   // | Sets the precision to the specified cell |
   //+------------------------------------------------------------------+
   void CTable::CellSetDigits(const uint row, const uint col, const int digits)
   {
      if(this.m_table_model!=NULL)
         this.m_table_model.CellSetDigits(row,col,digits);
   }
   //+------------------------------------------------------------------+
   // | Sets time display flags to the specified cell |
   //+------------------------------------------------------------------+
   void CTable::CellSetTimeFlags(const uint row, const uint col, const uint flags)
   {
      if(this.m_table_model!=NULL)
         this.m_table_model.CellSetTimeFlags(row,col,flags);
   }
   //+------------------------------------------------------------------+
   // | Sets the flag to display color names in the specified cell |
   //+------------------------------------------------------------------+
   void CTable::CellSetColorNamesFlag(const uint row, const uint col, const bool flag)
   {
      if(this.m_table_model!=NULL)
         this.m_table_model.CellSetColorNamesFlag(row,col,flag);
   }
   //+------------------------------------------------------------------+
   // | Assigns an object to a cell |
   //+------------------------------------------------------------------+
   void CTable::CellAssignObject(const uint row, const uint col,CObject *object)
   {
      if(this.m_table_model!=NULL)
         this.m_table_model.CellAssignObject(row,col,object);
   }
   //+------------------------------------------------------------------+
   // | Undoes an object in a cell |
   //+------------------------------------------------------------------+
   void CTable::CellUnassignObject(const uint row, const uint col)
   {
      if(this.m_table_model!=NULL)
         this.m_table_model.CellUnassignObject(row,col);
   }
   //+------------------------------------------------------------------+
   // | Returns the string value of the specified cell |
   //+------------------------------------------------------------------+
   string CTable::CellValueAt(const uint row,const uint col)
   {
      CTableCell *cell=this.GetCell(row,col);
      return(cell!=NULL ? cell.Value() : "");
   }
   //+------------------------------------------------------------------+
   // | Deletes a cell |
   //+------------------------------------------------------------------+
   bool CTable::CellDelete(const uint row, const uint col)
   {
      return(this.m_table_model!=NULL ? this.m_table_model.CellDelete(row,col) : false);
   }
   //+------------------------------------------------------------------+
   // | Moves a cell |
   //+------------------------------------------------------------------+
   bool CTable::CellMoveTo(const uint row, const uint cell_index, const uint index_to)
   {
      return(this.m_table_model!=NULL ? this.m_table_model.CellMoveTo(row,cell_index,index_to) : false);
   }
   //+------------------------------------------------------------------+
   // | Returns the object assigned to the cell |
   //+------------------------------------------------------------------+
   CObject *CTable::CellGetObject(const uint row, const uint col)
   {
      return(this.m_table_model!=NULL ? this.m_table_model.CellGetObject(row,col) : NULL);
   }
   //+------------------------------------------------------------------+
   // | Returns the type of the object assigned to the cell |
   //+------------------------------------------------------------------+
   ENUM_OBJECT_TYPE CTable::CellGetObjType(const uint row,const uint col)
   {
      return(this.m_table_model!=NULL ? this.m_table_model.CellGetObjType(row,col) : (ENUM_OBJECT_TYPE)WRONG_VALUE);
   }
   //+------------------------------------------------------------------+
   // | Returns cell description |
   //+------------------------------------------------------------------+
   string CTable::CellDescription(const uint row, const uint col)
   {
      return(this.m_table_model!=NULL ? this.m_table_model.CellDescription(row,col) : "");
   }
   //+------------------------------------------------------------------+
   // | Logs a cell description |
   //+------------------------------------------------------------------+
   void CTable::CellPrint(const uint row, const uint col)
   {
      if(this.m_table_model!=NULL)
         this.m_table_model.CellPrint(row,col);
   }
   //+------------------------------------------------------------------+
   // | Creates a new line and adds it to the end of the list |
   //+------------------------------------------------------------------+
   CTableRow *CTable::RowAddNew(void)
   {
      return(this.m_table_model!=NULL ? this.m_table_model.RowAddNew() : NULL);
   }
   //+------------------------------------------------------------------+
   // | Creates a new line and inserts it into the specified list position |
   //+------------------------------------------------------------------+
   CTableRow *CTable::RowInsertNewTo(const uint index_to)
   {
      return(this.m_table_model!=NULL ? this.m_table_model.RowInsertNewTo(index_to) : NULL);
   }
   //+------------------------------------------------------------------+
   // | Deletes a line |
   //+------------------------------------------------------------------+
   bool CTable::RowDelete(const uint index)
   {
      return(this.m_table_model!=NULL ? this.m_table_model.RowDelete(index) : false);
   }
   //+------------------------------------------------------------------+
   // | Moves line |
   //+------------------------------------------------------------------+
   bool CTable::RowMoveTo(const uint row_index, const uint index_to)
   {
      return(this.m_table_model!=NULL ? this.m_table_model.RowMoveTo(row_index,index_to) : false);
   }
   //+------------------------------------------------------------------+
   // | Clears row data |
   //+------------------------------------------------------------------+
   void CTable::RowClearData(const uint index)
   {
      if(this.m_table_model!=NULL)
         this.m_table_model.RowClearData(index);
   }
   //+------------------------------------------------------------------+
   // | Returns the description of a string |
   //+------------------------------------------------------------------+
   string CTable::RowDescription(const uint index)
   {
      return(this.m_table_model!=NULL ? this.m_table_model.RowDescription(index) : "");
   }
   //+------------------------------------------------------------------+
   // | Logs a description of a string |
   //+------------------------------------------------------------------+
   void CTable::RowPrint(const uint index,const bool detail)
   {
      if(this.m_table_model!=NULL)
         this.m_table_model.RowPrint(index,detail);
   }
   //+------------------------------------------------------------------+
   // | Creates a new column and adds it to the specified table position|
   //+------------------------------------------------------------------+
   bool CTable::ColumnAddNew(const string caption,const int index=-1)
   {
   // --- If there is no table model, or there is an error adding a new column to the model, return false
      if(this.m_table_model==NULL || !this.m_table_model.ColumnAddNew(index))
         return false;
   // --- If there is no header, return true (the column was added without a header)
      if(this.m_table_header==NULL)
         return true;
      
   // --- Check the creation of a new column header and, if not created, return false
      CColumnCaption *caption_obj=this.m_table_header.CreateNewColumnCaption(caption);
      if(caption_obj==NULL)
         return false;
   // --- If a non-negative index is passed, we return the result of moving the header to the specified index
   // --- Otherwise, everything is already ready - just return true
      return(index>-1 ? this.m_table_header.ColumnCaptionMoveTo(caption_obj.Column(),index) : true);
   }
   //+------------------------------------------------------------------+
   // | Removes a column |
   //+------------------------------------------------------------------+
   bool CTable::ColumnDelete(const uint index)
   {
      if(!this.HeaderCheck() || !this.m_table_header.ColumnCaptionDelete(index))
         return false;
      return this.m_table_model.ColumnDelete(index);
   }
   //+------------------------------------------------------------------+
   // | Moves column |
   //+------------------------------------------------------------------+
   bool CTable::ColumnMoveTo(const uint index, const uint index_to)
   {
      if(!this.HeaderCheck() || !this.m_table_header.ColumnCaptionMoveTo(index,index_to))
         return false;
      return this.m_table_model.ColumnMoveTo(index,index_to);
   }
   //+------------------------------------------------------------------+
   // | Clears column data |
   //+------------------------------------------------------------------+
   void CTable::ColumnClearData(const uint index)
   {
      if(this.m_table_model!=NULL)
         this.m_table_model.ColumnClearData(index);
   }
   //+------------------------------------------------------------------+
   // | Sets the value to the specified header |
   //+------------------------------------------------------------------+
   void CTable::ColumnCaptionSetValue(const uint index,const string value)
   {
      CColumnCaption *caption=this.m_table_header.GetColumnCaption(index);
      if(caption!=NULL)
         caption.SetValue(value);
   }
   //+------------------------------------------------------------------+
   // | Sets the data type for the specified column |
   //+------------------------------------------------------------------+
   void CTable::ColumnSetDatatype(const uint index,const ENUM_DATATYPE type)
   {
   // --- If there is a table model, set the data type for the column
      if(this.m_table_model!=NULL)
         this.m_table_model.ColumnSetDatatype(index,type);
   // --- If there is a header, set the data type for the header
      if(this.m_table_header!=NULL)
         this.m_table_header.ColumnCaptionSetDatatype(index,type);
   }
   //+------------------------------------------------------------------+
   // | Sets the data precision of the specified column |
   //+------------------------------------------------------------------+
   void CTable::ColumnSetDigits(const uint index,const int digits)
   {
      if(this.m_table_model!=NULL)
         this.m_table_model.ColumnSetDigits(index,digits);
   }
   //+------------------------------------------------------------------+
   // | Sets the time display flags for the specified column |
   //+------------------------------------------------------------------+
   void CTable::ColumnSetTimeFlags(const uint index,const uint flags)
   {
      if(this.m_table_model!=NULL)
         this.m_table_model.ColumnSetTimeFlags(index,flags);
   }
   //+------------------------------------------------------------------+
   // | Sets the color name display flags for the specified column |
   //+------------------------------------------------------------------+
   void CTable::ColumnSetColorNamesFlag(const uint index,const bool flag)
   {
      if(this.m_table_model!=NULL)
         this.m_table_model.ColumnSetColorNamesFlag(index,flag);
   }
   //+------------------------------------------------------------------+
   // | Returns the data type for the specified column |
   //+------------------------------------------------------------------+
   ENUM_DATATYPE CTable::ColumnDatatype(const uint index)
   {
      return(this.m_table_header!=NULL ? this.m_table_header.ColumnCaptionDatatype(index) : (ENUM_DATATYPE)WRONG_VALUE);
   }
   //+------------------------------------------------------------------+
   // | Returns the description of the object |
   //+------------------------------------------------------------------+
   string CTable::Description(void)
   {
      return(::StringFormat("%s: Rows total: %u, Columns total: %u",
                           TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.RowsTotal(),this.ColumnsTotal()));
   }
   //+------------------------------------------------------------------+
   // | Logs a description of an object |
   //+------------------------------------------------------------------+
   void CTable::Print(const int column_width=CELL_WIDTH_IN_CHARS)
   {
      if(this.HeaderCheck())
      {
         // --- Output the title as a line description
         ::Print(this.Description()+":");
         
         // --- Number of titles
         int total=(int)this.ColumnsTotal();
         
         string res="";
         // --- create a row from the values ​​of all table column headers
         res="|";
         for(int i=0;i<total;i++)
         {
            CColumnCaption *caption=this.GetColumnCaption(i);
            if(caption==NULL)
               continue;
            res+=::StringFormat("%*s |",column_width,caption.Value());
         }
         // --- We supplement the line on the left with a heading
         string hd="|";
         hd+=::StringFormat("%*s ",column_width,"n/n");
         res=hd+res;
         // --- Output the header line to the log
         ::Print(res);
      }
      
   // --- Let's loop through all the rows of the table and print them in tabular form
      for(uint i=0;i<this.RowsTotal();i++)
      {
         CTableRow *row=this.GetRow(i);
         if(row!=NULL)
         {
            // --- create a table row from the values ​​of all cells
            string head=" "+(string)row.Index();
            string res=::StringFormat("|%-*s |",column_width,head);
            for(int i=0;i<(int)row.CellsTotal();i++)
            {
               CTableCell *cell=row.GetCell(i);
               if(cell==NULL)
                  continue;
               res+=::StringFormat("%*s |",column_width,cell.Value());
            }
            // --- Output the line to the log
            ::Print(res);
         }
      }
   }
   //+------------------------------------------------------------------+
   // | Saving to file |
   //+------------------------------------------------------------------+
   bool CTable::Save(const int file_handle)
   {
   // --- Checking the handle
      if(file_handle==INVALID_HANDLE)
         return(false);
   // --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
      if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
         return(false);
   // --- Save the object type
      if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
         return(false);
         
   // --- Save the ID
      if(::FileWriteInteger(file_handle,this.m_id,INT_VALUE)!=INT_VALUE)
         return(false);
   // --- Checking the table model
      if(this.m_table_model==NULL)
         return false;
   // --- Save the table model
      if(!this.m_table_model.Save(file_handle))
         return(false);

   // --- Checking the table header
      if(this.m_table_header==NULL)
         return false;
   // --- Save the table header
      if(!this.m_table_header.Save(file_handle))
         return(false);
      
   // --- Successfully
      return true;
   }
   //+------------------------------------------------------------------+
   // | Loading from file |
   //+------------------------------------------------------------------+
   bool CTable::Load(const int file_handle)
   {
   // --- Checking the handle
      if(file_handle==INVALID_HANDLE)
         return(false);
   // --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
      if(::FileReadLong(file_handle)!=MARKER_START_DATA)
         return(false);
   // --- Loading the object type
      if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
         return(false);

   // --- Loading ID
      this.m_id=::FileReadInteger(file_handle,INT_VALUE);
   // --- Checking the table model
      if(this.m_table_model==NULL && (this.m_table_model=new CTableModel())==NULL)
         return(false);
   // --- Loading the table model
      if(!this.m_table_model.Load(file_handle))
         return(false);

   // --- Checking the table header
      if(this.m_table_header==NULL && (this.m_table_header=new CTableHeader())==NULL)
         return false;
   // --- Load the table header
      if(!this.m_table_header.Load(file_handle))
         return(false);
      
   // --- Successfully
      return true;
   }
   //+------------------------------------------------------------------+
#endif // __TABLE_MQH__


