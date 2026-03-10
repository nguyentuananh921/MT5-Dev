//+------------------------------------------------------------------+
//|                                                    TableView.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __TABLE_VIEW_MQH__
#define __TABLE_VIEW_MQH__
//+------------------------------------------------------------------+
//| Class representing the visual representation of a table          |
//+------------------------------------------------------------------+
//| Include standard library                                         |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Include Custom Library                                         |
//+------------------------------------------------------------------+
#include "Panel.mqh"
#include "..\Table\Table.mqh"
#include "..\Table\TableModel.mqh"
#include "..\Table\TableHeader.mqh"
#include "..\Table\TableRow.mqh"
#include "TableHeaderView.mqh"
#include "TableRowView.mqh"
#include "TableCellView.mqh"
#include "ColumnCaptionView.mqh"
#include "..\Controls\ListElm.mqh"
#include "..\Table\TableDefines.mqh"
#include "..\Table\TableEnums.mqh"
//+------------------------------------------------------------------+

class CTableView : public CPanel
  {
protected:
//--- Table data obtained
   CTable           *m_table_obj;                  // Pointer to the table object (contains table and header models)
   CTableModel      *m_table_model;                // Pointer to the table model (obtained from CTable)
   CTableHeader     *m_header_model;               // Pointer to the table header model (obtained from CTable)
   
   //--- View component data
   CTableHeaderView *m_header_view;                // Pointer to the table header view
   CPanel           *m_table_area;                 // Panel for placing table rows
   CContainer       *m_table_area_container;       // Container holding the panel with table rows
   
   //--- (1) Sets, (2) returns the table model
   bool              TableModelAssign(CTableModel *table_model);
   CTableModel      *GetTableModel(void)                                { return this.m_table_model;           }
   
   //--- (1) Sets, (2) returns the table header model
   bool              HeaderModelAssign(CTableHeader *header_model);
   CTableHeader     *GetHeaderModel(void)                               { return this.m_header_model;          }

//--- Creates from model: (1) header object, (2) table object, (3) updates modified table
   bool              CreateHeader(void);
   bool              CreateTable(void);
   bool              UpdateTable(void);
   
public:
//--- (1) Sets, (2) returns the table object
   bool              TableObjectAssign(CTable *table_obj);
   CTable           *GetTableObj(void)                                  { return this.m_table_obj;             }

//--- Returns (1) header, (2) table area, (3) table area container
   CTableHeaderView *GetHeader(void)                                    { return this.m_header_view;           }
   CPanel           *GetTableArea(void)                                 { return this.m_table_area;            }
   CContainer       *GetTableAreaContainer(void)                        { return this.m_table_area_container;  }

//--- Prints assigned models to the log: (1) table, (2) header, (3) table object
   void              TableModelPrint(const bool detail);
   void              HeaderModelPrint(const bool detail,const bool as_table=false,const int cell_width=CELL_WIDTH_IN_CHARS);
   void              TablePrint(const int column_width=CELL_WIDTH_IN_CHARS);
   
//--- Gets column caption (1) by index, (2) with sorting flag
   CColumnCaptionView *GetColumnCaption(const uint index)
                       { return(this.GetHeader()!=NULL ? this.GetHeader().GetColumnCaption(index) : NULL);     }
   CColumnCaptionView *GetSortedColumnCaption(void)
                       { return(this.GetHeader()!=NULL ? this.GetHeader().GetSortedColumnCaption() : NULL);    }

//--- Returns visual object for (1) row, (2) cell
   CTableRowView    *GetRowView(const uint index)
                       { return(this.GetTableArea()!=NULL ? this.GetTableArea().GetAttachedElementAt(index) : NULL); }
   CTableCellView   *GetCellView(const uint row,const uint col)
                       { return(this.GetRowView(row)!=NULL ? this.GetRowView(row).GetCellView(col) : NULL);    }
                       
//--- Returns number of table rows
   int               RowsTotal(void)
                       { return(this.GetTableArea()!=NULL ? this.GetTableArea().AttachedElementsTotal() : 0);  }

//--- Draws the visual appearance
   virtual void      Draw(const bool chart_redraw);
   
//--- Virtual methods: (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0)const { return CPanel::Compare(node,mode);   }
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_VIEW);     }
   
//--- Handler for custom element event when clicking the object area
   virtual void      MousePressHandler(const int id,const long lparam,const double dparam,const string sparam);
   
//--- Sorts the table by column value and direction
   bool              Sort(const uint column,const ENUM_TABLE_SORT_MODE sort_mode);
  
//--- Initialization (1) class object, (2) default object colors
   void              Init(void);

//--- Constructors/destructor
                     CTableView(void);
                     CTableView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
                    ~CTableView(void){}
  };

//+------------------------------------------------------------------+
//| Default constructor. Creates element in the main window of       |
//| the current chart at coordinates 0,0 with default size           |
//+------------------------------------------------------------------+
CTableView::CTableView(void) :
   CPanel("TableView","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H),
   m_table_model(NULL),m_header_model(NULL),m_table_obj(NULL),m_header_view(NULL),m_table_area(NULL),m_table_area_container(NULL)
  {
//--- Initialization
   this.Init();
  }

//+------------------------------------------------------------------+
//| Parameterized constructor. Creates element in the specified      |
//| window of the specified chart with given text, coordinates       |
//| and dimensions                                                   |
//+------------------------------------------------------------------+
CTableView::CTableView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CPanel(object_name,text,chart_id,wnd,x,y,w,h),
   m_table_model(NULL),m_header_model(NULL),m_table_obj(NULL),m_header_view(NULL),m_table_area(NULL),m_table_area_container(NULL)
  {
//--- Initialization
   this.Init();
  }

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void CTableView::Init(void)
  {
//--- Initialize parent object
   CPanel::Init();

//--- Border width
   this.SetBorderWidth(1);

//--- Create table header
   this.m_header_view=this.InsertNewElement(ELEMENT_TYPE_TABLE_HEADER_VIEW,"","TableHeader",0,0,this.Width(),DEF_TABLE_HEADER_H);
   if(this.m_header_view==NULL)
      return;
   this.m_header_view.SetBorderWidth(1);
   
//--- Create container that will hold the panel with table rows
   this.m_table_area_container=this.InsertNewElement(ELEMENT_TYPE_CONTAINER,"","TableAreaContainer",0,DEF_TABLE_HEADER_H,this.Width(),this.Height()-DEF_TABLE_HEADER_H);
   if(this.m_table_area_container==NULL)
      return;
   this.m_table_area_container.SetBorderWidth(0);
   this.m_table_area_container.SetScrollable(true);
   
//--- Attach a panel to the container for storing table rows
   int shift_y=0;
   this.m_table_area=this.m_table_area_container.InsertNewElement(ELEMENT_TYPE_PANEL,"","TableAreaPanel",0,shift_y,this.m_table_area_container.Width(),this.m_table_area_container.Height()-shift_y);
   if(m_table_area==NULL)
      return;
   this.m_table_area.SetBorderWidth(0);
  }
//+------------------------------------------------------------------+
//| CTableView::Sets the table model                                 |
//+------------------------------------------------------------------+
bool CTableView::TableModelAssign(CTableModel *table_model)
  {
   if(table_model==NULL)
     {
      ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
      return false;
     }
   this.m_table_model=table_model;
   return true;
  }

//+------------------------------------------------------------------+
//| CTableView::Sets the table header model                          |
//+------------------------------------------------------------------+
bool CTableView::HeaderModelAssign(CTableHeader *header_model)
  {
   if(header_model==NULL)
     {
      ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
      return false;
     }
   this.m_header_model=header_model;
   return true;
  }

//+------------------------------------------------------------------+
//| CTableView::Assigns the main table object                        |
//+------------------------------------------------------------------+
bool CTableView::TableObjectAssign(CTable *table_obj)
  {
//--- If an empty table object is passed - report and return false
   if(table_obj==NULL)
     {
      ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
      return false;
     }
//--- Save the pointer to variable
   this.m_table_obj=table_obj;
//--- Assign table model and header model from the main table object
   bool res=this.TableModelAssign(this.m_table_obj.GetTableModel());
   res &=this.HeaderModelAssign(this.m_table_obj.GetTableHeader());
   
//--- If any model assignment failed - return false
   if(!res)
      return false;
   
//--- Create the header and table rows based on the assigned models
   res=this.CreateHeader();
   res&=this.CreateTable();
   
//--- Return result
   return res;
  }

//+------------------------------------------------------------------+
//| CTableView::Creates the header object from the model             |
//+------------------------------------------------------------------+
bool CTableView::CreateHeader(void)
  {
   if(this.m_header_view==NULL)
     {
      ::PrintFormat("%s: Error. Table header object not created",__FUNCTION__);
      return false;
     }
   return this.m_header_view.TableHeaderModelAssign(this.m_header_model);
  }

//+------------------------------------------------------------------+
//| CTableView::Creates table row objects from the model             |
//+------------------------------------------------------------------+
bool CTableView::CreateTable(void)
  {
   if(this.m_table_area==NULL)
      return false;
   
//--- Loop to create and attach Row objects (TableRowView) to the Panel (m_table_area)
   int total=(int)this.m_table_model.RowsTotal();
   int y=1;                    // Vertical offset
   int table_height=0;         // Calculated panel height
   CTableRowView *row=NULL;
   for(int i=0;i<total;i++)
     {
      //--- Create and attach a table row object to the panel
      row=this.m_table_area.InsertNewElement(ELEMENT_TYPE_TABLE_ROW_VIEW,"","TableRow"+(string)i,0,y+(row!=NULL ? row.Height()*i : 0),this.m_table_area.Width()-1,DEF_TABLE_ROW_H);
      if(row==NULL)
          return false;
      
      //--- Set row ID
      row.SetID(i);
      //--- Set zebra-striping background colors (even/odd rows)
      if(row.ID()%2==0)
          row.InitBackColorDefault(clrWhite);
      else
          row.InitBackColorDefault(C'242,242,242');
      row.BackColorToDefault();
      row.InitBackColorFocused(row.GetBackColorControl().NewColor(row.BackColor(),-4,-4,-4));
      
      //--- Get row model from the table model
      CTableRow *row_model=this.m_table_model.GetRow(i);
      if(row_model==NULL)
          return false;
      //--- Assign the row model to the created row object
      row.TableRowModelAssign(row_model);
      //--- Calculate cumulative panel height
      table_height+=row.Height();
     }
//--- Resize the panel height based on calculated total row heights
   return this.m_table_area.ResizeH(table_height+y);
  }

//+------------------------------------------------------------------+
//| CTableView::Updates the table after changes                      |
//+------------------------------------------------------------------+
bool CTableView::UpdateTable(void)
  {
   if(this.m_table_area==NULL)
      return false;
   
   int total_model=(int)this.m_table_model.RowsTotal();        // Rows in model
   int total_view =this.m_table_area.AttachedElementsTotal();  // Rows in UI
   int diff=total_model-total_view;                            // Difference
   int y=1;                                                    // Vertical offset
   int table_height=0;                                         // Calculated height
   CTableRowView *row=NULL;
   
//--- If model has more rows, create the missing UI rows at the end of the list
   if(diff>0)
     {
      row=this.m_table_area.GetAttachedElementAt(total_view-1);
      for(int i=total_view;i<total_view+diff;i++)
        {
         row=this.m_table_area.InsertNewElement(ELEMENT_TYPE_TABLE_ROW_VIEW,"","TableRow"+(string)i,0,y+(row!=NULL ? row.Height()*i : 0),this.m_table_area.Width()-1,DEF_TABLE_ROW_H);
         if(row==NULL)
            return false;
        }
     }
 
//--- If UI has more rows than model, delete the extra UI rows from the end
   if(diff<0)
     {
      CListElm *list=this.m_table_area.GetListAttachedElements();
      if(list==NULL)
          return false;
      
      int  start=total_view-1;
      int  end=start-diff;
      bool res=true;
      for(int i=start;i>end;i--)
          res &=list.Delete(i);
      if(!res)
          return false;
     }
   
//--- Iterate through the table model row list to sync UI
   for(int i=0;i<total_model;i++)
     {
      //--- Get the UI row object
      row=this.m_table_area.GetAttachedElementAt(i);
      if(row==NULL)
          return false;
      if(row.Type()!=ELEMENT_TYPE_TABLE_ROW_VIEW)
          continue;
          
      //--- Update row ID and zebra-striping
      row.SetID(i);
      if(row.ID()%2==0)
          row.InitBackColorDefault(clrWhite);
      else
          row.InitBackColorDefault(C'242,242,242');
      row.BackColorToDefault();
      row.InitBackColorFocused(row.GetBackColorControl().NewColor(row.BackColor(),-4,-4,-4));
      
      //--- Get data from model and update row cells
      CTableRow *row_model=this.m_table_model.GetRow(i);
      if(row_model==NULL)
          return false;

      row.TableRowModelUpdate(row_model);
      table_height+=row.Height();
     }
//--- Adjust panel height to match content
   return this.m_table_area.ResizeH(table_height+y);
  }

//+------------------------------------------------------------------+
//| CTableView::Renders the visual appearance                        |
//+------------------------------------------------------------------+
void CTableView::Draw(const bool chart_redraw)
  {
//--- Draw header and table rows
   this.m_header_view.Draw(false);
   this.m_table_area_container.Draw(false);
//--- Update chart if specified
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }

//+------------------------------------------------------------------+
//| CTableView::Handler for custom event when clicking object area   |
//+------------------------------------------------------------------+
void CTableView::MousePressHandler(const int id,const long lparam,const double dparam,const string sparam)
  {
   // Filter out standard clicks
   if(id==CHARTEVENT_OBJECT_CLICK && lparam>=0 && dparam>=0)
      return;
      
//--- Extract table header name from sparam
   int len=::StringLen(this.NameFG());
   string header_str=::StringSubstr(sparam,0,len);
   if(header_str!=this.NameFG())
      return;
   
//--- Recover column index from the "negative value" trick in lparam
   int index=(int)::fabs(lparam+1000);
   
//--- Get column caption by index
   CColumnCaptionView *caption=this.GetColumnCaption(index);
   if(caption==NULL)
      return;
   
//--- Sort row list by column value/sort mode and update the table UI
   this.Sort(index,caption.SortMode());
   if(this.UpdateTable())
      this.Draw(true);
  }

//+------------------------------------------------------------------+
//| CTableView::Sorts table by column and direction                  |
//+------------------------------------------------------------------+
bool CTableView::Sort(const uint column,const ENUM_TABLE_SORT_MODE sort_mode)
  {
//--- If model is missing, report error
   if(this.m_table_model==NULL)
     {
      ::PrintFormat("%s: Error. The table model is not assigned. Please use the TableObjectAssign() first",__FUNCTION__);
      return false;
     }

//--- If header is missing or sort is NONE, exit
   if(this.m_header_model==NULL || sort_mode==TABLE_SORT_MODE_NONE)
      return false;
   
//--- Set sort direction and trigger sorting in the Table Model
   bool descending=(sort_mode==TABLE_SORT_MODE_DESC);
   this.m_table_model.SortByColumn(column,descending);
//--- Success
   return true;
  }
#endif