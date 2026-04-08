//+------------------------------------------------------------------+
//|                                                  TableView.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Table visual class |
//+------------------------------------------------------------------+
#ifndef __TABLEVIEW_MQH__
#define __TABLEVIEW_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+

   #include "Panel.mqh"
   class CTable; 
   class CTableRowView;
   class CTableModel;                // Pointer to the table model (obtained from CTable)
   class CTableHeader; 
   class CTableHeaderView;
   class CTableRowsHeaderView;
   class CContainer;
   class CColumnCaptionView;
   class CTableCellView;      
 class CTableView : public CPanel
  {
   private:
      int               m_rows_header_panel_w;        // Width when creating table row header panel
      
   protected:
   // --- Retrieved table data
      CTable           *m_table_obj;                  // Pointer to a table object (includes table and header models)
      CTableModel      *m_table_model;                // Pointer to the table model (obtained from CTable)
      CTableHeader     *m_header_model;               // Pointer to the table header model (obtained from CTable)
      
   // --- View component data
      CPanel           *m_header_panel;               // Panel for placing table header
      CTableHeaderView *m_header_view;                // Pointer to table header (View)
      CPanel           *m_rows_header_panel;          // Panel for placing table row headers
      CTableRowsHeaderView *m_rows_header_view;       // Pointer to table row headers (View)
      CPanel           *m_table_area;                 // Panel for placing table rows
      CContainer       *m_table_area_container;       // Container for placing a panel with table rows
      bool              m_sortable;                   // Sortable table flag
      
   // --- (1) Sets, (2) returns the table model
      bool              TableModelAssign(CTableModel *table_model);
      CTableModel      *GetTableModel(void)                                { return this.m_table_model;           }
      
   // --- (1) Sets, (2) returns the table header model
      bool              HeaderModelAssign(CTableHeader *header_model);
      CTableHeader     *GetHeaderModel(void)                               { return this.m_header_model;          }
      
   // --- (1) Sets the required size of the row header panel, (2) returns the width of the table row header
      void              SetRowsHeaderPanelSize(const int width)            { this.m_rows_header_panel_w=width;    }
      int               RowsHeaderWidth(void) const
                        {
                           return(this.m_rows_header_view!=NULL ? this.m_rows_header_view.Width() : 0);
                        }

   // --- Creates a (1) table object, (2-3) header object from the model, (4) updates the modified table
      bool              CreateTable(void);
      bool              CreateHeader(void);
   public:
      bool              CreateRowsHeader(string &captions_array[]);
      bool              UpdateTable(void);
      
   // --- (1) Sets, (2) returns a table object
      bool              TableObjectAssign(CTable *table_obj);
      CTable           *GetTableObj(void)                                  { return this.m_table_obj;             }

   // --- Returns (1-2) title, (3) table area, (4) table area container
      CTableHeaderView *GetHeader(void)                                    { return this.m_header_view;           }
      CTableRowsHeaderView *GetRowsHeader(void)                            { return this.m_rows_header_view;      }
      CPanel           *GetTableArea(void)                                 { return this.m_table_area;            }
      CContainer       *GetTableAreaContainer(void)                        { return this.m_table_area_container;  }

   // --- Prints the assigned model of (1) table, (2) header, (3) table object in the log
      void              TableModelPrint(const bool detail);
      void              HeaderModelPrint(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS);
      void              TablePrint(const int column_width=CELL_WIDTH_IN_CHARS);
      
   // --- Gets the column header (1) by index, (2) with sort flag
      CColumnCaptionView *GetColumnCaption(const uint index)
                        { return(this.GetHeader()!=NULL ? this.GetHeader().GetColumnCaption(index) : NULL);     }
      CColumnCaptionView *GetSortedColumnCaption(void)
                        { return(this.GetHeader()!=NULL ? this.GetHeader().GetSortedColumnCaption(): NULL);     }

   // --- Returns a visual object representing the specified (1) row, (2) cell
      CTableRowView    *GetRowView(const uint index)
                        { return(this.GetTableArea()!=NULL ? this.GetTableArea().GetAttachedElementAt(index) : NULL); }
      CTableCellView   *GetCellView(const uint row,const uint col)
                        { return(this.GetRowView(row)!=NULL ? this.GetRowView(row).GetCellView(col) : NULL);    }
                        
   // --- Returns the number of table rows
      int               RowsTotal(void)
                        { return(this.GetTableArea()!=NULL ? this.GetTableArea().AttachedElementsTotal() : 0);  }
                        
   // --- Returns the number of cells in the specified table row
      int               CellsInRow(const uint row)
                        { return(this.GetRowView(row)!=NULL ? this.GetRowView(row).CellsTotal() : 0);           }

   // --- Sets the row highlighting method
      void              SetRowsHighlightMode(const ENUM_ROWS_HIGHLIGHT_MODE mode);
      
   // --- (1) Sets, (2) returns the flag of the table being sorted
      void              SetSortable(const bool flag);
      bool              IsSortable(void)                             const { return this.m_sortable;              }
      
   // ---Draws the appearance
      virtual void      Draw(const bool chart_redraw);
      
   // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0)const { return CPanel::Compare(node,mode);   }
      virtual bool      Save(const int file_handle);
      virtual bool      Load(const int file_handle);
      virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_VIEW);     }
      
   // --- Handler for a custom element event when an object area is clicked
      virtual void      MousePressHandler(const int id, const long lparam, const double dparam, const string sparam);
      
   // --- Sorts the table by column value and direction
      bool              Sort(const uint column,const ENUM_TABLE_SORT_MODE sort_mode);

   // --- Initialize (1) class object, (2) default object colors
      void              Init(void);

   // --- Constructors/destructor
                        CTableView(void);
                        CTableView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                        ~CTableView (void){}
  };
  #ifndef CTABLEVIEW_IMPLEMENTATION
  #define CTABLEVIEW_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CTableView::Default constructor.                            |
   // | Plots an element in the main window of the current chart |
   // | at coordinates 0,0 with default dimensions |
   //+------------------------------------------------------------------+
   CTableView::CTableView(void) : CPanel("TableView","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_PANEL_H),
      m_table_model(NULL),m_header_model(NULL),m_table_obj(NULL),m_header_view(NULL),m_rows_header_view(NULL),
      m_table_area(NULL),m_table_area_container(NULL),m_rows_header_panel_w(0),m_sortable(true)
    {
     // ---Initialization
      this.Init();
    }
   //+------------------------------------------------------------------+
   // | CTableView::Parametric constructor.                         |
   // | Plots an element in the specified window of the specified chart |
   // | with specified text, coordinates and dimensions |
   //+------------------------------------------------------------------+
   CTableView::CTableView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
      CPanel(object_name,text,chart_id,wnd,x,y,w,h),m_table_model(NULL),m_header_model(NULL),m_rows_header_view(NULL),m_table_obj(NULL),m_header_view(NULL),
      m_table_area(NULL),m_table_area_container(NULL),m_rows_header_panel_w(0),m_sortable(true)
    {
     // ---Initialization
      this.Init();
    }
   //+------------------------------------------------------------------+
   // | CTableView::Initialization |
   //+------------------------------------------------------------------+
   void CTableView::Init(void)
    {
     // --- Initializing the parent object
      CPanel::Init();
     // --- Frame width, opacity
      this.SetBorderWidth(1);
      this.SetAlphaBG(255);
      this.SetAlphaFG(255);
     // --- Initialize the background colors of the panel and make it the current background color
      this.InitBackColors(C'230,230,230',C'230,230,230',C'230,230,230',clrSilver);
      this.BackColorToDefault();
     // --- Initialize the panel border colors and make it the current border color
      this.InitBorderColors(C'180,180,180',C'180,180,180',C'180,180,180',clrSilver);
      this.BorderColorToDefault();
      
     // --- X coordinate offset for table header and rows (vertical row header width)
      int dx=(int)::StringToInteger(this.Text());

      this.m_rows_header_panel_w=dx;
      this.SetText("");
      if(dx>DEF_TABLE_ROWS_HEADER_W)
         dx+=12;
      
     // --- Coordinates and dimensions of the table header panel (table header is horizontal)
      int x=1+dx;
      int y=1;
      int w=this.Width()-2-dx;
      int h=DEF_TABLE_HEADER_H;
     // --- Create a panel for the table header
      this.m_header_panel=this.InsertNewElement(ELEMENT_TYPE_PANEL,"","TableHeaderPanel",x,y,w,h);
      if(this.m_header_panel==NULL)
         return;
     // --- Initialize the background colors of the panel and make it the current background color
      this.m_header_panel.InitBackColors(C'230,230,230',C'230,230,230',C'230,230,230',clrSilver);
      this.m_header_panel.BackColorToDefault();
      this.m_header_panel.SetBorderWidth(0);
      this.m_header_panel.SetAlphaBG(255);
     // --- Create a table header
      this.m_header_view=this.m_header_panel.InsertNewElement(ELEMENT_TYPE_TABLE_HEADER_VIEW,"","TableHeader",0,0,this.m_header_panel.Width(),this.m_header_panel.Height());
      if(this.m_header_view==NULL)
         return;
      this.m_header_view.SetBorderWidth(0);
      
     // --- Coordinates and dimensions of the panel for the table row header (the table header is vertical)
      x=1;
      y=DEF_TABLE_HEADER_H;
      w=(dx>0 ? dx : 1);
      h=this.Height()-2-DEF_TABLE_HEADER_H;
     // ---Creating a panel
      this.m_rows_header_panel=this.InsertNewElement(ELEMENT_TYPE_PANEL,"","TableRowsHeaderPanel",x,y,w,h);
      if(this.m_rows_header_panel==NULL)
         return;
     // --- Initialize the background colors of the panel and make it the current background color
      this.m_rows_header_panel.InitBackColors(C'230,230,230',C'230,230,230',C'230,230,230',clrSilver);
      this.m_rows_header_panel.BackColorToDefault();
      this.m_rows_header_panel.SetBorderWidth(0);
      this.m_rows_header_panel.SetAlphaBG(255);
     // --- Create table row headers
      this.m_rows_header_view=this.m_rows_header_panel.InsertNewElement(ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW,"","TableRowsHeader",0,0,this.m_rows_header_panel.Width(),this.m_rows_header_panel.Height());
      if(this.m_rows_header_view==NULL)
         return;
      this.m_rows_header_view.SetBorderWidth(0);
      this.m_rows_header_view.SetAlphaBG(0);
      if(this.m_rows_header_panel_w==0)
         this.m_rows_header_view.Hide(false);
      
     // --- Coordinates and dimensions of the container in which the table row panel will be located
      x=1+dx;
      y=1+DEF_TABLE_HEADER_H;
      w=this.Width()-2-dx;
      h=this.Height()-2-DEF_TABLE_HEADER_H;
     // --- Create a container
      this.m_table_area_container=this.InsertNewElement(ELEMENT_TYPE_CONTAINER,"","TableAreaContainer",x,y,w,h);
      if(this.m_table_area_container==NULL)
         return;
      this.m_table_area_container.SetBorderWidth(0);
      this.m_table_area_container.SetScrollable(true);
      
     // --- Attach a panel to the container for storing table rows
      this.m_table_area=this.m_table_area_container.InsertNewElement(ELEMENT_TYPE_PANEL,"","TableAreaPanel",0,0,this.m_table_area_container.Width()-0,this.m_table_area_container.Height()-0);
      if(m_table_area==NULL)
         return;
      this.m_table_area.SetBorderWidth(0);
    }
   //+------------------------------------------------------------------+
   // | CTableView::Sets the table model |
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
   // | CTableView::Sets the table header model |
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
   // | CTableView::Sets a table object |
   //+------------------------------------------------------------------+
   bool CTableView::TableObjectAssign(CTable *table_obj)
    {
     // --- If an empty table object is passed, we report this and return false
      if(table_obj==NULL)
      {
         ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
         return false;
      }
     // --- Save the pointer to a variable
      this.m_table_obj=table_obj;
     // --- Write down the result of assigning the table model and header model
      bool res=this.TableModelAssign(this.m_table_obj.GetTableModel());
      res &=this.HeaderModelAssign(this.m_table_obj.GetTableHeader());
      
     // --- If it was not possible to assign any model, return false
      if(!res)
         return false;
      
     // --- We record the result of creating a table header from the model and a table from the model
      res=this.CreateHeader();
      res&=this.CreateTable();
      
     // --- Return the result
      return res;
    }
   //+------------------------------------------------------------------+
   // | CTableView::Creates a title object from the model |
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
   // | CTableView::Creates a row header object |
   //+------------------------------------------------------------------+
   bool CTableView::CreateRowsHeader(string &captions_array[])
    {
      if(this.m_rows_header_view==NULL)
      {
         ::PrintFormat("%s: Error. Table rows header object not created",__FUNCTION__);
         return false;
      }
      return this.m_rows_header_view.TableRowCaptionsAssign(captions_array);
    }
   //+------------------------------------------------------------------+
   // | CTableView::Creates a table object from a model |
   //+------------------------------------------------------------------+
   bool CTableView::CreateTable(void)
    {
      if(this.m_table_area==NULL)
         return false;

     // --- In a loop, we create and attach RowsTotal rows from TableRowView elements to the Panel element (m_table_area)
      int total=(int)this.m_table_model.RowsTotal();
      int y=1;                   // Vertical offset
      int table_height=0;        // Calculated panel height
      CTableRowView *row=NULL;
      for(int i=0;i<total;i++)
      {
         // --- Create and attach a table row object to the panel
         row=this.m_table_area.InsertNewElement(ELEMENT_TYPE_TABLE_ROW_VIEW,"","TableRow"+(string)i,0,y+(row!=NULL ? row.Height()*i : 0),this.m_table_area.Width()-1,DEF_TABLE_ROW_H);
         if(row==NULL)
            return false;
         
         // --- Set the row identifier
         row.SetID(i);
         row.SetIndex(i);
         // --- Depending on the line number (even/odd), we set its background color
         if(row.ID()%2==0)
            row.InitBackColorDefault(clrWhite);
         else
            row.InitBackColorDefault(C'242,242,242');
         row.BackColorToDefault();
         row.InitBackColorFocused(row.GetBackColorControl().NewColor(row.BackColor(),-4,-4,-4));
         
         // --- Getting the row model from the table object
         CTableRow *row_model=this.m_table_model.GetRow(i);
         if(row_model==NULL)
            return false;
         // --- Assign the resulting row model to the created table row object
         row.TableRowModelAssign(row_model);
         // --- Calculate the new value of the panel height
         table_height+=row.Height();
      }
     // --- Return the result of resizing the panel to the value calculated in the loop
      return this.m_table_area.ResizeH(table_height+y);
    }
   //+------------------------------------------------------------------+
   // | CTableView::Updates a modified table |
   //+------------------------------------------------------------------+
   bool CTableView::UpdateTable(void)
    {
      if(this.m_table_area==NULL)
         return false;
      
      int total_model=(int)this.m_table_model.RowsTotal();        // Number of rows in the model
      int total_view =this.m_table_area.AttachedElementsTotal();  // Number of rows in visual representation
      int diff=total_model-total_view;                            // Difference in number of rows of two components
      int y=1;                                                    // Vertical offset
      int table_height=0;                                         // Calculated panel height
      CTableRowView *row=NULL;                                    // Pointer to a string rendering object
      
     // --- If there are more rows in the model than in the visual representation, we will create the missing rows in the visual representation at the end of the list
      if(diff>0)
      {
         // --- We get the last row of the visual representation of the table (based on its coordinates, the added rows will be placed)
         row=this.m_table_area.GetAttachedElementAt(total_view-1);
         // --- In a loop based on the number of missing lines
         for(int i=total_view;i<total_view+diff;i++)
         {
            // --- create and attach to the diff panel the number of objects for visual representation of a table row
            row=this.m_table_area.InsertNewElement(ELEMENT_TYPE_TABLE_ROW_VIEW,"","TableRow"+(string)i,0,y+(row!=NULL ? row.Height()*i : 0),this.m_table_area.Width()-1,DEF_TABLE_ROW_H);
            if(row==NULL)
               return false;
         }
      }

     // --- If there are more lines in the visual representation than in the model, delete the extra lines in the visual representation at the end of the list
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
      
     // --- Looping through a list of table model rows
      for(int i=0;i<total_model;i++)
      {
         // --- we get from the list of the row panel the next object of visual representation of a table row
         row=this.m_table_area.GetAttachedElementAt(i);
         if(row==NULL)
            return false;
         // --- Let's check the object type
         if(row.Type()!=ELEMENT_TYPE_TABLE_ROW_VIEW)
            continue;
            
         // --- Set the row identifier
         row.SetID(i);
         row.SetIndex(i);
         // --- Depending on the line number (even/odd), we set its background color
         if(row.ID()%2==0)
            row.InitBackColorDefault(clrWhite);
         else
            row.InitBackColorDefault(C'242,242,242');
         row.BackColorToDefault();
         row.InitBackColorFocused(row.GetBackColorControl().NewColor(row.BackColor(),-4,-4,-4));
         
         // --- Getting the row model from the table object
         CTableRow *row_model=this.m_table_model.GetRow(i);
         if(row_model==NULL)
            return false;

         // --- Update the cells of the table row object according to the row model
         row.TableRowModelUpdate(row_model);
         // --- Calculate the new value of the panel height
         table_height+=row.Height();
      }
     // --- Return the result of resizing the panel to the value calculated in the loop
      return this.m_table_area.ResizeH(table_height+y);
    }
   //+------------------------------------------------------------------+
   // | CTableView::Draws appearance |
   //+------------------------------------------------------------------+
   void CTableView::Draw(const bool chart_redraw)
    {
     // --- Draw the base
      CPanel::Draw(false);
     // --- Draw the table title and rows
      if(this.m_header_view!=NULL)
         this.m_header_view.Draw(false);
      if(this.m_table_area_container!=NULL)
         this.m_table_area_container.Draw(false);
         
     // --- Set the offset and dimensions of the image area
      int x=this.m_rows_header_panel.Width()-16;
      int y=this.m_header_panel.Height()-16;
      int w=11;
      int h=w;
     // --- Clear the area and draw a corner
      m_painter.Clear(x,y,w,h,false);
      m_painter.TriangleRB(x,y,w,h,BorderColor(),AlphaFG(),true);
         
     // --- If indicated, update the schedule
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | CTableView::Sets the row highlighting method |
   //+------------------------------------------------------------------+
   void CTableView::SetRowsHighlightMode(const ENUM_ROWS_HIGHLIGHT_MODE highlight_mode)
    {
      int total=this.RowsTotal();
      for(int i=0;i<total;i++)
      {
         CTableRowView *row=this.GetRowView(i);
         if(row!=NULL)
            row.SetHighlightMode(highlight_mode);
      }
    }
   //+------------------------------------------------------------------+
   // | CTableView::Sets the sortable table flag |
   //+------------------------------------------------------------------+
   void CTableView::SetSortable(const bool flag)
    {
      this.m_sortable=flag;
      CTableHeaderView *header=this.GetHeader();
      if(header!=NULL)
         header.SetSortableFlag(flag);
    }
   //+------------------------------------------------------------------+
   // | CTableView::Prints the assigned table model in the log |
   //+------------------------------------------------------------------+
   void CTableView::TableModelPrint(const bool detail)
    {
      if(this.m_table_model!=NULL)
         this.m_table_model.Print(detail);
    }
   //+------------------------------------------------------------------+
   // | CTableView::Prints the assigned title model in the log |
   //+------------------------------------------------------------------+
   void CTableView::HeaderModelPrint(const bool detail,const bool as_table=false,const int column_width=CELL_WIDTH_IN_CHARS)
    {
      if(this.m_header_model!=NULL)
         this.m_header_model.Print(detail,as_table,column_width);
    }
   //+------------------------------------------------------------------+
   // | CTableView::Prints the assigned table object in the log |
   //+------------------------------------------------------------------+
   void CTableView::TablePrint(const int column_width=CELL_WIDTH_IN_CHARS)
    {
      if(this.m_table_obj!=NULL)
         this.m_table_obj.Print(column_width);
    }
   //+------------------------------------------------------------------+
   // | CTableView::Element Custom Event Handler |
   // | when clicking on an area of ​​an object |
   //+------------------------------------------------------------------+
   void CTableView::MousePressHandler(const int id,const long lparam,const double dparam,const string sparam)
    {
      if(id==CHARTEVENT_OBJECT_CLICK && lparam>=0 && dparam>=0)
         return;
         
     // --- Get the name of the table header object from sparam
      int len=::StringLen(this.NameFG());
      string header_str=::StringSubstr(sparam,0,len);
     // --- If the extracted name does not match the name of this object - not our event, leave
      if(header_str!=this.NameFG())
         return;
      
     // --- Write the index of the column header
     // --- Since the standard OBJECT_CLICK event transfers cursor coordinates to lparam and dparam,
     // --- then for this handler a negative value of the index of the header on which the event occurred is passed
      int index=(int)::fabs(lparam+10000);
      
     // --- Get the column header by index
      CColumnCaptionView *caption=this.GetColumnCaption(index);
      if(caption==NULL)
         return;
      
     // --- Sort the list of rows by the sort value in the column header and update the table
      if(this.Sort(index,caption.SortMode()) && this.UpdateTable())
         this.Draw(true);
    }
   //+------------------------------------------------------------------+
   // | CTableView::Sorts table by column value and direction |
   //+------------------------------------------------------------------+
   bool CTableView::Sort(const uint column,const ENUM_TABLE_SORT_MODE sort_mode)
    {
     // --- If the table model is not assigned, report this and return false
      if(this.m_table_model==NULL)
      {
         ::PrintFormat("%s: Error. The table model is not assigned. Please use the TableObjectAssign() method first",__FUNCTION__);
         return false;
      }

     // --- If the table does not have a header or there is no sorting, return false
      if(this.m_header_model==NULL || !this.m_sortable || sort_mode==TABLE_SORT_MODE_NONE)
         return false;
      
     // --- Set the sort direction flag and sort the table model by the specified column and direction
      bool descending=(sort_mode==TABLE_SORT_MODE_DESC);
      this.m_table_model.SortByColumn(column,descending);
     // --- Successfully
      return true;
    }
   //+------------------------------------------------------------------+
  #endif // CTABLEVIEW_IMPLEMENTATION
#endif // __TABLEVIEW_MQH__


