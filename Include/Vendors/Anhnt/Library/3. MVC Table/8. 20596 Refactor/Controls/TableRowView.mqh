//+------------------------------------------------------------------+
//|                                               TableRowView.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in:                                                    |
//|   Integrating the Model Component into the View Component        |
//|                           https://www.mql5.com/en/articles/19288 |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Table row visualization class                                   |
//+------------------------------------------------------------------+
#ifndef __TABLEROWVIEW_MQH__
#define __TABLEROWVIEW_MQH__
  //+------------------------------------------------------------------+
  //| Included Standard Libraries                                      |
  //+------------------------------------------------------------------+
  //#include <Arrays\List.mqh>
  //+------------------------------------------------------------------+
  //| Included Custome Libraries                                       |
  //+------------------------------------------------------------------+
  
  #include "Panel.mqh"
  #include "TableCellView.mqh" 
  #include "..\Collections\ListElm.mqh"  
  
  #include "RowCaptionView.mqh"
  #include "ColumnCaptionView.mqh"
  #include "TableView.mqh"
   
  class CTableRow; 
        
  class CTableRowView : public CPanel
   {
      protected:
         CTableCellView    m_temp_cell;                                    // Temporary cell object to search
         CTableRow        *m_table_row_model;                              // Pointer to a string model
         CListElm          m_list_cells;                                   // List of cells
         int               m_index;                                        // Index in a list of strings
         ENUM_ROWS_HIGHLIGHT_MODE m_highlight_mode;                        // Line highlighting mode
         
      // --- Creates and adds a new cell view object to the list
         CTableCellView   *InsertNewCellView(const int index,const string text,const int dx,const int dy,const int w,const int h);
      // --- Deletes the specified row area and the cell at the corresponding index
         bool              BoundCellDelete(const int index);
      // --- Returns a visual representation of (1) table, (2) column headers, (3) rows
         CTableView       *GetTableView(void);
         CTableHeaderView *GetHeaderView(void);
         CTableRowsHeaderView *GetRowsHeaderView(void);
         
      // --- Sets the specified header (1) column, (2) row as selected
         void              SetColumnCaptionSelected(const uint index);
         void              SetRowCaptionSelected(const uint index);
      // --- Deselects all (1) column, (2) row headers
         void              SetAllColumnCaptionsUnselected(const int exclude=-1);
         void              SetAllRowCaptionsUnselected(const int exclude=-1);
         
      public:
      // --- Returns (1) list, (2) number of cells, (3) cell, (4) column header, (5) rows
         CListElm         *GetListCells(void)                                 { return &this.m_list_cells;                       }
         int               CellsTotal(void)                             const { return this.m_list_cells.Total();                }
         CTableCellView   *GetCellView(const uint index)                      { return this.m_list_cells.GetNodeAtIndex(index);  }
         CColumnCaptionView *GetColumnCaption(const uint index);
         CRowCaptionView  *GetRowCaption(const uint index);
         
      // --- Sets the ID
         virtual void      SetID(const int id)                                { this.m_id=id;                                    }
      // --- (1) Sets, (2) returns the row index
         void              SetIndex(const int index)                          { this.m_index=index;                              }
         int               Index(void)                                  const { return this.m_index;                             }

      // --- (1) Sets, (2) returns the string model
         bool              TableRowModelAssign(CTableRow *row_model);
         CTableRow        *GetTableRowModel(void)                             { return this.m_table_row_model;                   }
      // --- Updates the stack with the updated model
         bool              TableRowModelUpdate(CTableRow *row_model);

      // --- (1) Sets, (2) returns the line highlighting mode
         void              SetHighlightMode(const ENUM_ROWS_HIGHLIGHT_MODE mode) { this.m_highlight_mode=mode;                   }
         ENUM_ROWS_HIGHLIGHT_MODE HighlightMode(void)                   const { return this.m_highlight_mode;                    }
         
      // --- Recalculates cell areas
         bool              RecalculateBounds(CListElm *list_bounds);

      // --- Prints the assigned line model in the log
         void              TableRowModelPrint(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS);
         
      // ---Draws the appearance
         virtual void      Draw(const bool chart_redraw);
         
      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0)const { return CLabel::Compare(node,mode);               }
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_ROW_VIEW);             }
      
      // --- Initialize (1) class object, (2) default object colors
         void              Init(void);
         virtual void      InitColors(void);

      // --- Event handlers for (1) cursor hover (Focus), (2) mouse button clicks (Press),
         virtual void      OnFocusEvent(const int id, const long lparam, const double dparam, const string sparam);
         virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);
         
      // --- Constructors/destructor
                           CTableRowView(void);
                           CTableRowView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                           ~CTableRowView (void){ this.m_list_cells.Clear(); }
   };
  #ifndef CTABLEROWVIEW_IMPLEMENTATION
  #define CTABLEROWVIEW_IMPLEMENTATION
    //+------------------------------------------------------------------+
    // | CTableRowView::Default constructor. Builds an object in the main |
    // | window of the current chart in coordinates 0,0 with default sizes |
    //+------------------------------------------------------------------+
    CTableRowView::CTableRowView(void) : CPanel("TableRow","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H), m_index(-1), m_highlight_mode(ROWS_HIGHLIGHT_MODE_ROW)
     {
        // ---Initialization
            this.Init();
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Parametric constructor. Builds an object in |
    // | the specified window of the specified chart with the specified text, |
    // | coordinates and dimensions |
    //+------------------------------------------------------------------+
    CTableRowView::CTableRowView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
        CPanel(object_name,text,chart_id,wnd,x,y,w,h), m_index(-1), m_highlight_mode(ROWS_HIGHLIGHT_MODE_ROW)
     {
      // ---Initialization
        this.Init();
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Initializing |
    //+------------------------------------------------------------------+
    void CTableRowView::Init(void)
     {
      // --- Initializing the parent object
        CPanel::Init();
      // --- Background - opaque
        this.SetAlphaBG(255);
      // --- Frame width
        this.SetBorderWidth(1);
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Initializing default object colors |
    //+------------------------------------------------------------------+
    void CTableRowView::InitColors(void)
     {
      // --- Initialize the background colors for normal and activated states and make it the current background color
        this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
        this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
        this.BackColorToDefault();
        
      // --- Initialize the foreground colors for normal and activated states and make it the current text color
        this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
        this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
        this.ForeColorToDefault();
        
      // --- Initialize the border colors for the normal and activated states and make it the current border color
        this.InitBorderColors(C'200,200,200',C'200,200,200',C'200,200,200',clrSilver);
        this.InitBorderColorsAct(C'200,200,200',C'200,200,200',C'200,200,200',clrSilver);
        this.BorderColorToDefault();
        
      // --- Initialize the border color and foreground color for the locked element
        this.InitBorderColorBlocked(clrSilver);
        this.InitForeColorBlocked(clrSilver);
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Creates and adds to the list |
    // | new cell view object |
    //+------------------------------------------------------------------+
    CTableCellView *CTableRowView::InsertNewCellView(const int index,const string text,const int dx,const int dy,const int w,const int h)
     {
      // --- Check if there is an object with the specified identifier in the list and, if so, report it and return NULL
        this.m_temp_cell.SetIndex(index);
      // --- Remember the list sorting method
        int sort_mode=this.m_list_cells.SortMode();
      // --- Set the list to sort by identifier
        this.m_list_cells.Sort(ELEMENT_SORT_BY_ID);
        if(this.m_list_cells.Search(&this.m_temp_cell)!=NULL)
        {
            // --- We return the initial sorting to the list, inform that such an object already exists and return NULL
            this.m_list_cells.Sort(sort_mode);
            ::PrintFormat("%s: Error. The TableCellView object with index %d is already in the list",__FUNCTION__,index);
            return NULL;
        }
      // --- Return the list to its original sorting
        this.m_list_cells.Sort(sort_mode);
      // --- Create a cell object name
        string name="TableCellView"+(string)this.Index()+"x"+(string)index;
      // --- Create a new TableCellView object; if it fails, we report it and return NULL
        CTableCellView *cell_view=new CTableCellView(index,name,text,dx,dy,w,h);
        if(cell_view==NULL)
        {
            ::PrintFormat("%s: Error. Failed to create CTableCellView object",__FUNCTION__);
            return NULL;
        }
      // --- If a new object could not be added to the list, we report this, delete the object and return NULL
        if(this.m_list_cells.Add(cell_view)==-1)
        {
            ::PrintFormat("%s: Error. Failed to add CTableCellView object to list",__FUNCTION__);
            delete cell_view;
            return NULL;
        }
      // --- Assign a base element (string) and return a pointer to the object
        cell_view.RowAssign(&this);
        return cell_view;
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Sets the row model |
    //+------------------------------------------------------------------+
    bool CTableRowView::TableRowModelAssign(CTableRow *row_model)
     {
      // --- If an empty object is passed, we report this and return false
        if(row_model==NULL)
        {
            ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
            return false;
        }
      // --- If there is not a single cell in the passed row model, we report this and return false
        int total=(int)row_model.CellsTotal();
        if(total==0)
        {
            ::PrintFormat("%s: Error. Row model does not contain any cells",__FUNCTION__);
            return false;
        }
      // --- Save a pointer to the passed string model
        this.m_table_row_model=row_model;
      // --- calculate the cell width based on the width of the row panel
        CCanvasBase *base=this.GetContainer();
        int w=(base!=NULL ? base.Width() : this.Width());
        int cell_w=(int)::fmax(::round((double)w/(double)total),DEF_TABLE_COLUMN_MIN_W);

      // --- In a loop by the number of cells in the row model
        for(int i=0;i<total;i++)
        {
            // --- we get the model of the next cell,
            CTableCell *cell_model=this.m_table_row_model.GetCell(i);
            if(cell_model==NULL)
                return false;
            // --- calculate the coordinate and create a name for the cell area
            int x=cell_w*i;
            string name="CellBound"+(string)this.m_table_row_model.Index()+"x"+(string)i;
            // --- Create a new cell area
            CBound *cell_bound=this.InsertNewBound(name,x,0,cell_w,this.Height());
            if(cell_bound==NULL)
                return false;
            // --- Create a new cell visual representation object
            CTableCellView *cell_view=this.InsertNewCellView(i,cell_model.Value(),x,0,cell_w,this.Height());
            if(cell_view==NULL)
                return false;
            // --- We assign the corresponding object of visual representation of the cell to the current area of ​​the cell
            cell_bound.AssignObject(cell_view);
        }
      // --- Everything is successful
        return true;
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Updates the row with the updated model |
    //+------------------------------------------------------------------+
    bool CTableRowView::TableRowModelUpdate(CTableRow *row_model)
     {
      // --- If an empty object is passed, we report this and return false
        if(row_model==NULL)
        {
            ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
            return false;
        }
      // --- If there is not a single cell in the passed row model, we report this and return false
        int total_model=(int)row_model.CellsTotal(); // Number of cells in row model
        if(total_model==0)
        {
            ::PrintFormat("%s: Error. Row model does not contain any cells",__FUNCTION__);
            return false;
        }
      // --- Save a pointer to the passed string model
        this.m_table_row_model=row_model;

      // --- Calculate the cell width based on the width of the row panel
        CCanvasBase *base=this.GetContainer();
        int w=(base!=NULL ? base.Width() : this.Width());
        int cell_w=(int)::fmax(::round((double)w/(double)total_model),DEF_TABLE_COLUMN_MIN_W);
        
        CBound *cell_bound=NULL;
        int total_bounds=this.m_list_bounds.Total(); // Number of areas
        int diff=total_model-total_bounds;           // Difference between number of areas in a row and cells in a row model
        
      // --- If there are more cells in the model than areas in the list, we will create the missing areas and cells at the end of the lists
        if(diff>0)
        {
            // --- In a loop based on the number of missing areas
            for(int i=total_bounds;i<total_bounds+diff;i++)
            {
                // --- create and add to the diff list the number of areas of row cells.
                // --- We get the model of the next cell,
                CTableCell *cell_model=this.m_table_row_model.GetCell(i);
                if(cell_model==NULL)
                return false;
                // --- calculate the coordinate and create a name for the cell area
                int x=cell_w*i;
                string name="CellBound"+(string)this.m_table_row_model.Index()+"x"+(string)i;
                // --- Create a new cell area
                CBound *cell_bound=this.InsertNewBound(name,x,0,cell_w,this.Height());
                if(cell_bound==NULL)
                return false;
                
                // --- Create a new cell visual representation object
                CTableCellView *cell_view=this.InsertNewCellView(i,cell_model.Value(),x,0,cell_w,this.Height());
                if(cell_view==NULL)
                return false;
            }
        }

      // --- If there are more areas in the list than there are cells in the model, remove the extra areas at the end of the list
        if(diff<0)
        {
            int  start=total_bounds-1;
            int  end=start-diff;
            bool res=true;
            for(int i=start;i>end;i--)
            {
                if(!this.BoundCellDelete(i))
                return false;
            }
        }
        
      // --- In a loop by the number of cells in the row model
        for(int i=0;i<total_model;i++)
        {
            // --- we get the model of the next cell,
            CTableCell *cell_model=this.m_table_row_model.GetCell(i);
            if(cell_model==NULL)
                return false;
            
            // --- calculate the cell coordinate
            int x=cell_w*i;
            // --- We get the next area of ​​the cell
            CBound *cell_bound=this.GetBoundAt(i);
            if(cell_bound==NULL)
                return false;
            
            // --- We get a cell visual representation object from the list
            CTableCellView *cell_view=this.m_list_cells.GetNodeAtIndex(i);
            if(cell_view==NULL)
                return false;
            
            // --- Assign the corresponding visual object of the cell and its text to the current area of ​​the cell
            cell_bound.AssignObject(cell_view);
            cell_view.SetText(cell_model.Value());
        }
      // --- Everything is successful
        return true;
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Deletes the specified row area |
    // | and the cell with the corresponding index |
    //+------------------------------------------------------------------+
    bool CTableRowView::BoundCellDelete(const int index)
     {
        if(!this.m_list_cells.Delete(index))
            return false;
        return this.m_list_bounds.Delete(index);
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Draws the appearance |
    //+------------------------------------------------------------------+
    void CTableRowView::Draw(const bool chart_redraw)
     {
      // --- If the line is outside the container, we leave
        if(this.IsOutOfContainer())
            return;

      // --- Fill the object with the background color, draw a line line and update the background canvas
        this.Fill(this.BackColor(),false);
        this.m_background.Line(this.AdjX(0),this.AdjY(this.Height()-1),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));

      // --- Draw row cells
        int total=this.m_list_bounds.Total();
        for(int i=0;i<total;i++)
        {
            // --- Getting the area of ​​the next cell
            CBound *cell_bound=this.GetBoundAt(i);
            if(cell_bound==NULL)
                continue;
            
            // --- From the cell area we get the attached cell object
            CTableCellView *cell_view=cell_bound.GetAssignedObj();
            // --- Draw a visual representation of the cell
            if(cell_view!=NULL)
                cell_view.Draw(false);
        }
      // --- Update the background and foreground canvases with the specified graph redraw flag
        this.Update(chart_redraw);
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Prints the assigned row model in the log |
    //+------------------------------------------------------------------+
    void CTableRowView::TableRowModelPrint(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS)
     {
        if(this.m_table_row_model!=NULL)
            this.m_table_row_model.Print(detail,as_table,cell_width);
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Recalculates cell areas |
    //+------------------------------------------------------------------+
    bool CTableRowView::RecalculateBounds(CListElm *list_bounds)
     {
      // --- Checking the list
        if(list_bounds==NULL)
            return false;

      // --- In a loop based on the number of areas in the list
        for(int i=0;i<list_bounds.Total();i++)
        {
            // --- we get the next header area and the corresponding cell area
            CBound *capt_bound=list_bounds.GetNodeAtIndex(i);
            CBound *cell_bound=this.GetBoundAt(i);
            if(capt_bound==NULL || cell_bound==NULL)
                return false;

            // --- In the cell area we set the coordinate and size of the header area
            cell_bound.SetX(capt_bound.X());
            cell_bound.ResizeW(capt_bound.Width());
            
            // --- From the cell area we get the attached cell object
            CTableCellView *cell_view=cell_bound.GetAssignedObj();
            if(cell_view==NULL)
                return false;

            // --- Set the coordinate and size of the cell area to the visual representation object of the cell
            cell_view.BoundSetX(cell_bound.X());
            cell_view.BoundResizeW(cell_bound.Width());
        }
      // --- Everything is successful
        return true;
     }     
    //+------------------------------------------------------------------+
    // |CTableRowView::Sets the specified column header as selected|
    //+------------------------------------------------------------------+
    void CTableRowView::SetColumnCaptionSelected(const uint index)
     {
        CColumnCaptionView *capt=this.GetColumnCaption(index);
        if(capt==NULL || capt.State()==ELEMENT_STATE_ACT)
            return;
        capt.SetState(ELEMENT_STATE_ACT);
        capt.GetBackground().FillRectangle(0,capt.Height()-2,capt.Width()-1,capt.Height()-1,ColorToARGB(clrCadetBlue));
        capt.GetBackground().Update(false);
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Sets the specified row header as selected|
    //+------------------------------------------------------------------+
    void CTableRowView::SetRowCaptionSelected(const uint index)
     {
        CRowCaptionView *capt=this.GetRowCaption(index);
        if(capt==NULL || capt.State()==ELEMENT_STATE_ACT)
            return;
        capt.SetState(ELEMENT_STATE_ACT);
        capt.GetBackground().FillRectangle(capt.Width()-2,2,capt.Width()-1,capt.Height()-0,ColorToARGB(clrCadetBlue));
        capt.GetBackground().Update(false);
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Deselects all column headers |
    //+------------------------------------------------------------------+
    void CTableRowView::SetAllColumnCaptionsUnselected(const int exclude=-1)
     {
        CTableHeaderView *header=this.GetHeaderView();
        if(header==NULL)
            return;
        int total=header.BoundsTotal();
        for(int i=0;i<total;i++)
        {
            CColumnCaptionView *capt=this.GetColumnCaption(i);
            if(capt==NULL || (exclude>-1 && i==exclude))
                continue;
            if(capt.State()!=ELEMENT_STATE_DEF)
            {
                capt.SetState(ELEMENT_STATE_DEF);
                capt.Draw(false);
            }
        }
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Deselects all row headers |
    //+------------------------------------------------------------------+
    void CTableRowView::SetAllRowCaptionsUnselected(const int exclude=-1)
     {
        CTableRowsHeaderView *header=this.GetRowsHeaderView();
        if(header==NULL)
            return;
        int total=header.BoundsTotal();
        for(int i=0;i<total;i++)
        {
            CRowCaptionView *capt=this.GetRowCaption(i);
            if(capt==NULL || (exclude>-1 && capt.ID()==exclude))
                continue;
            if(capt.State()!=ELEMENT_STATE_DEF)
            {
                capt.SetState(ELEMENT_STATE_DEF);
                capt.Draw(false);
            }
        }
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Hover Handler |
    //+------------------------------------------------------------------+
    void CTableRowView::OnFocusEvent(const int id,const long lparam,const double dparam,const string sparam)
     {
      // --- If the entire string is processed, call the event handler of the parent class
        if(this.m_highlight_mode==ROWS_HIGHLIGHT_MODE_ROW)
        {
            CCanvasBase::OnFocusEvent(id,lparam,dparam,sparam);
            return;
        }

      // --- Getting the cursor coordinates
        int x=int(lparam-this.X());
        int y=int(dparam-this.m_wnd_y-this.Y());

      // --- In a loop through areas of row cells
        int total=this.m_list_bounds.Total();
        for(int i=0;i<total;i++)
        {
            // --- we get another area
            CBound *bound=this.GetBoundAt(i);
            if(bound==NULL)
                continue;

            // --- From the current area we get the element assigned to it
            CBaseObj *obj=bound.GetAssignedObj();
            CTableCellView *cell=NULL;
            
            // --- If the resulting element is not a table cell, move on
            if(obj==NULL || obj.Type()!=ELEMENT_TYPE_TABLE_CELL_VIEW)
                continue;

            // --- This is a table cell. We determine its coordinates in the table (row/column)
            cell=obj;
            int row=this.ID();
            int col=obj.ID();
            
            // --- Get the corresponding row and column headers
            CColumnCaptionView *col_capt=this.GetColumnCaption(col);
            CRowCaptionView    *row_capt=this.GetRowCaption(row);
            if(col_capt==NULL || row_capt==NULL)
                continue;
            
            // --- If the cursor is on the cell area
            if(bound.Contains(x,y))
            {
                // --- Set the column and row headers to be selected,
                this.SetColumnCaptionSelected(i);
                this.SetRowCaptionSelected(this.ID());
                // --- remove the selected header flag from all line headers except the current one
                this.SetAllRowCaptionsUnselected(this.ID());
            }
            // --- If the cursor is outside the cell area
            else
            {
                // --- If the title is selected,
                if(col_capt.State()!=ELEMENT_STATE_DEF)
                {
                // --- deselect it and redraw the object as not selected
                col_capt.SetState(ELEMENT_STATE_DEF);
                col_capt.Draw(false);
                }
            }
        }
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Object click handler |
    //+------------------------------------------------------------------+
    void CTableRowView::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
     {
      // --- If the entire string is processed, call the event handler of the parent class
        if(this.m_highlight_mode==ROWS_HIGHLIGHT_MODE_ROW)
        {
            CCanvasBase::OnPressEvent(id,lparam,dparam,sparam);
            return;
        }

      // --- In a loop through all areas of the string
        int total=this.m_list_bounds.Total();
        for(int i=0;i<total;i++)
        {
            // --- we get another area
            CBound *bound=this.GetBoundAt(i);
            if(bound==NULL)
                continue;

            // --- Get the cursor coordinates and
            int x=int(lparam-this.X());
            int y=int(dparam-this.m_wnd_y-this.Y());
            // --- check that the cursor is inside the area
            if(bound.Contains(x,y))
            {
                // --- Getting an attached object (cell) from the area
                CBaseObj *obj=bound.GetAssignedObj();
                if(obj!=NULL)
                {
                // --- Write down the cell address in the table (row/column)
                int row=this.ID();
                int col=obj.ID();
                
                // --- Based on the row and column identifiers, we get pointers to the corresponding headers
                CRowCaptionView    *row_capt=this.GetRowCaption(row);
                CColumnCaptionView *col_capt=this.GetColumnCaption(col);
                if(row_capt==NULL || col_capt==NULL)
                    return;
                
                // --- Create a text value for a custom event from the string name and header texts
                string sprm=obj.Name()+";"+row_capt.Text()+";"+col_capt.Text();
                // --- Send a custom object click event with row and column coordinates and text
                ::EventChartCustom(this.m_chart_id,CHARTEVENT_OBJECT_CLICK,row,col,sprm);
                }
            }
        }
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Saving to file |
    //+------------------------------------------------------------------+
    bool CTableRowView::Save(const int file_handle)
     {
      // --- Save the data of the parent object
        if(!CPanel::Save(file_handle))
            return false;

      // --- Save the list of cells
        if(!this.m_list_cells.Save(file_handle))
            return false;
      // --- Save the line number
        if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
            return false;
      // --- Save the backlight mode
        if(::FileWriteInteger(file_handle,this.m_highlight_mode,INT_VALUE)!=INT_VALUE)
            return false;
        
      // --- Everything is successful
        return true;
     }
    //+------------------------------------------------------------------+
    // | CTableRowView::Loading from file |
    //+------------------------------------------------------------------+
    bool CTableRowView::Load(const int file_handle)
     {
      // --- Loading the data of the parent object
        if(!CPanel::Load(file_handle))
            return false;
        
      // --- Loading a list of cells
        if(!this.m_list_cells.Load(file_handle))
            return false;
      // --- Load the line number
        this.m_index=(int)::FileReadInteger(file_handle,INT_VALUE);
      // --- Loading backlight mode
        this.m_highlight_mode=(ENUM_ROWS_HIGHLIGHT_MODE)::FileReadInteger(file_handle,INT_VALUE);
        
      // --- Everything is successful
        return true;
     }
    //+------------------------------------------------------------------+
  #ifndef MOVE_TO_DELIB_MQH
  #define MOVE_TO_DELIB_MQH
  //  //+------------------------------------------------------------------+
  //   // | CTableRowView::Returns the row title |
  //   //+------------------------------------------------------------------+
  //   CRowCaptionView *CTableRowView::GetRowCaption(const uint index)
  //    {
  //       CTableRowsHeaderView *header=this.GetRowsHeaderView();
  //       return(header!=NULL ? header.GetRowCaption(index) : NULL);
  //    }     
  //   //+------------------------------------------------------------------+
  //   // | CTableRowView::Returns the column title |
  //   //+------------------------------------------------------------------+
  //   CColumnCaptionView *CTableRowView::GetColumnCaption(const uint index)
  //    {
  //       CTableHeaderView *header=this.GetHeaderView();
  //       return(header!=NULL ? header.GetColumnCaption(index) : NULL);
  //    }  
  //   //+------------------------------------------------------------------+
  //   // |CTableRowView::Returns a visual representation of the row headers|
  //   //+------------------------------------------------------------------+
  //   CTableRowsHeaderView *CTableRowView::GetRowsHeaderView(void)
  //    {
  //       CTableView *table=this.GetTableView();
  //       return(table!=NULL ? table.GetRowsHeader() : NULL);
  //    }
  //   //+------------------------------------------------------------------+
  //   // | CTableRowView::Returns the visual view |
  //   // | column headers |
  //   //+------------------------------------------------------------------+
  //   CTableHeaderView *CTableRowView::GetHeaderView(void)
  //    {
  //       CTableView *table=this.GetTableView();
  //       return(table!=NULL ? table.GetHeader() : NULL);
  //    }
  //   //+------------------------------------------------------------------+
  //   // | CTableRowView::Returns a visual view of the table |
  //   //+------------------------------------------------------------------+
  //   CTableView *CTableRowView::GetTableView(void)
  //    {
  //       CTableView *obj=NULL;
  //     // --- We get a panel with table rows
  //       CElementBase *base0=this.GetContainer();
  //       if(base0==NULL)
  //           return NULL;
        
  //     // --- Getting the table row panel container
  //       CElementBase *base1=base0.GetContainer();
  //       if(base1==NULL)
  //           return NULL;
        
  //     // --- Get the table visual representation object
  //       CElementBase *base2=base1.GetContainer();
  //       if(base2!=NULL && base2.Type()==ELEMENT_TYPE_TABLE_VIEW)
  //       {
  //           obj=base2;
  //           return obj;
  //       }
  //       return NULL;
  //    }
  #endif // MOVE_TO_DELIB_MQH

  #endif // CTABLEROWVIEW_IMPLEMENTATION
#endif // __TABLEROWVIEW_MQH__


