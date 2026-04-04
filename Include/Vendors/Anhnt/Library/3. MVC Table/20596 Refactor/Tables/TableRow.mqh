//+------------------------------------------------------------------+
//|                                                   TableRow.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh>
#include "..\Collections\ListObj.mqh"
#include "TableCell.mqh"

#ifndef __TABLEROW_MQH__
#define __TABLEROW_MQH__
   //+------------------------------------------------------------------+
   // | Table row class |
   //+------------------------------------------------------------------+
   class CTableRow : public CObject
   {
    protected:
        CTableCell        m_cell_tmp;                            // Cell object to search in the list
        CListObj          m_list_cells;                          // List of cells
        uint              m_index;                               // Row index
        
    // --- Adds the specified cell to the end of the list
        bool              AddNewCell(CTableCell *cell);
        
    public:
    // --- (1) Sets, (2) returns the row index
        void              SetIndex(const uint index)                { this.m_index=index;  }
        uint              Index(void)                         const { return this.m_index; }
    // --- Sets row and column positions for all cells
        void              CellsPositionUpdate(void);
        
    // --- Creates a new cell and adds it to the end of the list
        CTableCell       *CellAddNew(const double value);
        CTableCell       *CellAddNew(const long value);
        CTableCell       *CellAddNew(const datetime value);
        CTableCell       *CellAddNew(const color value);
        CTableCell       *CellAddNew(const string value);
        
    // --- Returns (1) cell by index, (2) number of cells
        CTableCell       *GetCell(const uint index)                 { return this.m_list_cells.GetNodeAtIndex(index);  }
        uint              CellsTotal(void)                    const { return this.m_list_cells.Total();                }
        
    // --- Sets the value to the specified cell
        void              CellSetValue(const uint index,const double value);
        void              CellSetValue(const uint index,const long value);
        void              CellSetValue(const uint index,const datetime value);
        void              CellSetValue(const uint index,const color value);
        void              CellSetValue(const uint index,const string value);
    // --- (1) assigns to a cell, (2) removes an assigned object from a cell
        void              CellAssignObject(const uint index,CObject *object);
        void              CellUnassignObject(const uint index);
    
    // --- Returns (1) the object assigned to the cell, (2) the type of the object assigned to the cell
        CObject          *CellGetObject(const uint index);
        ENUM_OBJECT_TYPE  CellGetObjType(const uint index);
        
    // --- (1) Deletes (2) moves a cell
        bool              CellDelete(const uint index);
        bool              CellMoveTo(const uint cell_index, const uint index_to);
        
    // --- Resets row cell data to zero
        void              ClearData(void);

    // --- (1) Returns, (2) logs a description of the object
        virtual string    Description(void);
        void              Print(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS);

    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
        virtual int       Compare(const CObject *node,const int mode=0) const;
        virtual bool      Save(const int file_handle);
        virtual bool      Load(const int file_handle);
        virtual int       Type(void)                          const { return(OBJECT_TYPE_TABLE_ROW); }
        
    // --- Constructors/destructor
                            CTableRow(void) : m_index(0) {}
                            CTableRow(const uint index) : m_index(index) {}
                        ~CTableRow(void){}
   };
   //+------------------------------------------------------------------+
   // | Comparison of two objects |
   //+------------------------------------------------------------------+
   int CTableRow::Compare(const CObject *node,const int mode=0) const
   {
    /* Sort(0) - by row index
        
        Sort(ASC_IDX_CORRECTION) - ascending by column 0
        Sort(1+ASC_IDX_CORRECTION) - ascending by column 1
        Sort(2+ASC_IDX_CORRECTION) - ascending by column 2
        etc.
        Sort(DESC_IDX_CORRECTION) - descending by column 0
        Sort(1+DESC_IDX_CORRECTION) - descending by column 1
        Sort(2+DESC_IDX_CORRECTION) - descending by column 2
        etc. */  
        if(node==NULL)
            return -1;
        
        if(mode==0)
        {
            const CTableRow *obj=node;
            return(this.Index()>obj.Index() ? 1 : this.Index()<obj.Index() ? -1 : 0);
        }
        
    //---
        bool asc=(mode>=ASC_IDX_CORRECTION && mode<DESC_IDX_CORRECTION);
        int  col= mode%(asc ? ASC_IDX_CORRECTION : DESC_IDX_CORRECTION);
            
    // --- Remove node constancy
        CTableRow *nonconst_this=(CTableRow*)&this;
        CTableRow *nonconst_node=(CTableRow*)node;

    // --- Get the current and compared cells by index mode
        CTableCell *cell_current =nonconst_this.GetCell(col);
        CTableCell *cell_compared=nonconst_node.GetCell(col);
        if(cell_current==NULL || cell_compared==NULL)
            return -1;
        
    // --- Compare depending on cell type
        int cmp=0;
        switch(cell_current.Datatype())
        {
            case TYPE_DOUBLE  :  cmp=(cell_current.ValueD()>cell_compared.ValueD() ? 1 : cell_current.ValueD()<cell_compared.ValueD() ? -1 : 0); break;
            case TYPE_LONG    :
            case TYPE_DATETIME:
            case TYPE_COLOR   :  cmp=(cell_current.ValueL()>cell_compared.ValueL() ? 1 : cell_current.ValueL()<cell_compared.ValueL() ? -1 : 0); break;
            case TYPE_STRING  :  cmp=::StringCompare(cell_current.ValueS(),cell_compared.ValueS());                                              break;
            default           :  break;
        }
        return(asc ? cmp : -cmp);   
   }
   //+------------------------------------------------------------------+
   // | Creates a new double cell and adds it to the end of the list |
   //+------------------------------------------------------------------+
   CTableCell *CTableRow::CellAddNew(const double value)
   {
    // --- Create a new cell object storing a value of type double
        CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,2);
        if(cell==NULL)
        {
            ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
            return NULL;
        }
    // --- Add the created cell to the end of the list
        if(!this.AddNewCell(cell))
        {
            delete cell;
            return NULL;
        }
    // --- Return a pointer to the object
        return cell;
   }
   //+------------------------------------------------------------------+
   // | Creates a new long cell and adds it to the end of the list |
   //+------------------------------------------------------------------+
   CTableCell *CTableRow::CellAddNew(const long value)
   {
    // --- Create a new cell object storing a value of type long
        CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value);
        if(cell==NULL)
        {
            ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
            return NULL;
        }
    // --- Add the created cell to the end of the list
        if(!this.AddNewCell(cell))
        {
            delete cell;
            return NULL;
        }
    // --- Return a pointer to the object
        return cell;
   }
   //+------------------------------------------------------------------+
   // | Creates a new datetime cell and adds it to the end of the list |
   //+------------------------------------------------------------------+
   CTableCell *CTableRow::CellAddNew(const datetime value)
   {
    // --- Create a new cell object storing a value with type datetime
        CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
        if(cell==NULL)
        {
            ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
            return NULL;
        }
    // --- Add the created cell to the end of the list
        if(!this.AddNewCell(cell))
        {
            delete cell;
            return NULL;
        }
    // --- Return a pointer to the object
        return cell;
   }
   //+------------------------------------------------------------------+
   // | Creates a new color cell and adds it to the end of the list |
   //+------------------------------------------------------------------+
   CTableCell *CTableRow::CellAddNew(const color value)
   {
    // --- Create a new cell object storing a value of type color
        CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value,true);
        if(cell==NULL)
        {
            ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
            return NULL;
        }
    // --- Add the created cell to the end of the list
        if(!this.AddNewCell(cell))
        {
            delete cell;
            return NULL;
        }
    // --- Return a pointer to the object
        return cell;
   }
   //+------------------------------------------------------------------+
   // | Creates a new string cell and adds it to the end of the list |
   //+------------------------------------------------------------------+
   CTableCell *CTableRow::CellAddNew(const string value)
   {
    // --- Create a new cell object storing a value of type string
        CTableCell *cell=new CTableCell(this.m_index,this.CellsTotal(),value);
        if(cell==NULL)
        {
            ::PrintFormat("%s: Error. Failed to create new cell in row %u at position %u",__FUNCTION__, this.m_index, this.CellsTotal());
            return NULL;
        }
    // --- Add the created cell to the end of the list
        if(!this.AddNewCell(cell))
        {
            delete cell;
            return NULL;
        }
    // --- Return a pointer to the object
        return cell;
   }
   //+------------------------------------------------------------------+
   // | Adds a cell to the end of the list |
   //+------------------------------------------------------------------+
   bool CTableRow::AddNewCell(CTableCell *cell)
   {
    // --- If an empty object is passed, we report and return false
        if(cell==NULL)
        {
            ::PrintFormat("%s: Error. Empty CTableCell object passed",__FUNCTION__);
            return false;
        }
    // --- Set the cell index in the list and add the created cell to the end of the list
        cell.SetPositionInTable(this.m_index,this.CellsTotal());
        if(this.m_list_cells.Add(cell)==WRONG_VALUE)
        {
            ::PrintFormat("%s: Error. Failed to add cell (%u,%u) to list",__FUNCTION__,this.m_index,this.CellsTotal());
            return false;
        }
    // --- Successfully
        return true;
   }
   //+------------------------------------------------------------------+
   // | Sets a double value to the specified cell |
   //+------------------------------------------------------------------+
   void CTableRow::CellSetValue(const uint index,const double value)
   {
    // --- We get the desired cell from the list and write a new value into it
        CTableCell *cell=this.GetCell(index);
        if(cell!=NULL)
            cell.SetValue(value);
   }
   //+------------------------------------------------------------------+
   // | Sets a long value to the specified cell |
   //+------------------------------------------------------------------+
   void CTableRow::CellSetValue(const uint index,const long value)
   {
    // --- We get the desired cell from the list and write a new value into it
        CTableCell *cell=this.GetCell(index);
        if(cell!=NULL)
            cell.SetValue(value);
   }
   //+------------------------------------------------------------------+
   // | Sets a datetime value to the specified cell |
   //+------------------------------------------------------------------+
   void CTableRow::CellSetValue(const uint index,const datetime value)
   {
    // --- We get the desired cell from the list and write a new value into it
        CTableCell *cell=this.GetCell(index);
        if(cell!=NULL)
            cell.SetValue(value);
   }
   //+------------------------------------------------------------------+
   // | Sets the color value to the specified cell |
   //+------------------------------------------------------------------+
   void CTableRow::CellSetValue(const uint index,const color value)
   {
    // --- We get the desired cell from the list and write a new value into it
        CTableCell *cell=this.GetCell(index);
        if(cell!=NULL)
            cell.SetValue(value);
   }
   //+------------------------------------------------------------------+
   // | Sets a string value to the specified cell |
   //+------------------------------------------------------------------+
   void CTableRow::CellSetValue(const uint index,const string value)
   {
    // --- We get the desired cell from the list and write a new value into it
        CTableCell *cell=this.GetCell(index);
        if(cell!=NULL)
            cell.SetValue(value);
   }
   //+------------------------------------------------------------------+
   // | Assigns an object to a cell |
   //+------------------------------------------------------------------+
   void CTableRow::CellAssignObject(const uint index,CObject *object)
   {
    // --- Get the desired cell from the list and write a pointer to the object into it
        CTableCell *cell=this.GetCell(index);
        if(cell!=NULL)
            cell.AssignObject(object);
   }
   //+------------------------------------------------------------------+
   // | Unassigns an object to a cell |
   //+------------------------------------------------------------------+
   void CTableRow::CellUnassignObject(const uint index)
   {
    // --- We get the desired cell from the list and cancel the pointer to the object and its type in it
        CTableCell *cell=this.GetCell(index);
        if(cell!=NULL)
            cell.UnassignObject();
   }
   //+------------------------------------------------------------------+
   // | Returns the object assigned to the cell |
   //+------------------------------------------------------------------+
   CObject *CTableRow::CellGetObject(const uint index)
   {
    // --- Get the desired cell from the list and return a pointer to the assigned object
        CTableCell *cell=this.GetCell(index);
        return(cell!=NULL ? cell.AssignedObject() : NULL);
   }
   //+------------------------------------------------------------------+
   // | Returns the type of the object assigned to the cell |
   //+------------------------------------------------------------------+
   ENUM_OBJECT_TYPE CTableRow::CellGetObjType(const uint index)
   {
    // --- Get the desired cell from the list and return the type of the assigned object
        CTableCell *cell=this.GetCell(index);
        return(cell!=NULL ? cell.AssignedObjType() : (ENUM_OBJECT_TYPE)WRONG_VALUE);
   }
   //+------------------------------------------------------------------+
   // | Deletes a cell |
   //+------------------------------------------------------------------+
   bool CTableRow::CellDelete(const uint index)
   {
    // --- Delete a cell in the list by index
        if(!this.m_list_cells.Delete(index))
            return false;
    // --- Update indexes for the remaining cells in the list
        this.CellsPositionUpdate();
        return true;
   }
   //+------------------------------------------------------------------+
   // | Moves the cell to the specified position |
   //+------------------------------------------------------------------+
   bool CTableRow::CellMoveTo(const uint cell_index,const uint index_to)
   {
    // --- Get the desired cell by index in the list, making it current
        CTableCell *cell=this.GetCell(cell_index);
    // --- Move the current cell to the specified position in the list
        if(cell==NULL || !this.m_list_cells.MoveToIndex(index_to))
            return false;
    // --- Update the indexes of all cells in the list
        this.CellsPositionUpdate();
        return true;
   }
   //+------------------------------------------------------------------+
   // | Sets row and column positions for all cells |
   //+------------------------------------------------------------------+
   void CTableRow::CellsPositionUpdate(void)
   {
    // --- Loop through all cells in the list
        for(int i=0;i<this.m_list_cells.Total();i++)
        {
            // --- get the next cell and set the row and column indexes in it
            CTableCell *cell=this.GetCell(i);
            if(cell!=NULL)
                cell.SetPositionInTable(this.Index(),this.m_list_cells.IndexOf(cell));
        }
   }
   //+------------------------------------------------------------------+
   // | Resets row cell data to zero |
   //+------------------------------------------------------------------+
   void CTableRow::ClearData(void)
   {
    // --- Loop through all cells in the list
        for(uint i=0;i<this.CellsTotal();i++)
        {
            // --- get the next cell and set it to an empty value
            CTableCell *cell=this.GetCell(i);
            if(cell!=NULL)
                cell.ClearData();
        }
   }
   //+------------------------------------------------------------------+
   // | Returns the description of the object |
   //+------------------------------------------------------------------+
   string CTableRow::Description(void)
   {
      return(::StringFormat("%s: Position %u, Cells total: %u",
                           TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.Index(),this.CellsTotal()));
   }
   //+------------------------------------------------------------------+
   // | Logs a description of an object |
   //+------------------------------------------------------------------+
   void CTableRow::Print(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS)
   {
         
    // --- Number of cells
        int total=(int)this.CellsTotal();
        
    // --- If the output is in tabular form
        string res="";
        if(as_table)
        {
            // --- create a table row from the values ​​of all cells
            string head=" Row "+(string)this.Index();
            string res=::StringFormat("|%-*s |",cell_width,head);
            for(int i=0;i<total;i++)
            {
                CTableCell *cell=this.GetCell(i);
                if(cell==NULL)
                continue;
                res+=::StringFormat("%*s |",cell_width,cell.Value());
            }
            // --- Output the line to the log
            ::Print(res);
            return;
        }
        
    // --- Output the title as a line description
        ::Print(this.Description()+(detail ? ":" : ""));
        
    // --- If detailed description
        if(detail)
        {
            
            // ---Output not in tabular form
            // --- Loop through a list of row cells
            for(int i=0; i<total; i++)
            {
                // --- get the current cell and add its description to the final line
                CTableCell *cell=this.GetCell(i);
                if(cell!=NULL)
                res+="  "+cell.Description()+(i<total-1 ? "\n" : "");
            }
            // --- Log the line created in the loop
            ::Print(res);
        }
   }
   //+------------------------------------------------------------------+
   // | Saving to file |
   //+------------------------------------------------------------------+
   bool CTableRow::Save(const int file_handle)
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

    // --- Save the index
        if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
            return(false);
    // --- Save the list of cells
        if(!this.m_list_cells.Save(file_handle))
            return(false);
        
    // --- Successfully
        return true;
   }
   //+------------------------------------------------------------------+
   // | Loading from file |
   //+------------------------------------------------------------------+
   bool CTableRow::Load(const int file_handle)
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

    // --- Loading the index
        this.m_index=::FileReadInteger(file_handle,INT_VALUE);
    // --- Loading a list of cells
        if(!this.m_list_cells.Load(file_handle))
            return(false);
        
    // --- Successfully
        return true;
   }
   //+------------------------------------------------------------------+
#endif // __TABLEROW_MQH__
