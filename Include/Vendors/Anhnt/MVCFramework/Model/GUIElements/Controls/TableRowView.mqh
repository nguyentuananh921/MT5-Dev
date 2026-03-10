//+------------------------------------------------------------------+
//|                                                TableRowView.mqh  |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|               https://www.mql5.com/en/articles/19979             |
//+------------------------------------------------------------------+

#ifndef __TABLE_ROW_VIEW_MQH__
#define __TABLE_ROW_VIEW_MQH__
//|Include stadard library                                           |
//+------------------------------------------------------------------+

// Forward declarations
class CTableRow;
class CTableCell;
class CCanvasBase;

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "Panel.mqh"
#include "TableCellView.mqh"
#include "..\Controls\ListElm.mqh"

#include "..\Base\BaseEnums.mqh"
#include "..\Base\Bound.mqh"
//+------------------------------------------------------------------+
//| Class representing the visual representation of a table row      |
//+------------------------------------------------------------------+
class CTableRowView : public CPanel
  {
protected:
   CTableCellView    m_temp_cell;         // Temporary cell object used for search
   CTableRow        *m_table_row_model;   // Pointer to row model
   CListElm          m_list_cells;        // List of cells
   int               m_index;             // Index in the row list

//--- Creates and adds a new cell view object to the list
   CTableCellView   *InsertNewCellView(const int index,const string text,const int dx,const int dy,const int w,const int h);

//--- Deletes specified row area and the cell with the corresponding index
   bool              BoundCellDelete(const int index);
   
public:
//--- Returns (1) list, (2) number of cells, (3) cell object
   CListElm         *GetListCells(void)                                 { return &this.m_list_cells;                       }
   int               CellsTotal(void)                             const { return this.m_list_cells.Total();                }
   CTableCellView   *GetCellView(const uint index)                      { return this.m_list_cells.GetNodeAtIndex(index);  }
   
//--- Sets identifier
   virtual void      SetID(const int id)                                { this.m_index=this.m_id=id;                       }

//--- (1) Set, (2) get row index
   void              SetIndex(const int index)                          { this.SetID(index);                               }
   int               Index(void)                                  const { return this.m_index;                             }

//--- (1) Assign, (2) get row model
   bool              TableRowModelAssign(CTableRow *row_model);
   CTableRow        *GetTableRowModel(void)                             { return this.m_table_row_model;                   }

//--- Updates the row using updated model
   bool              TableRowModelUpdate(CTableRow *row_model);

//--- Recalculates cell bounds
   bool              RecalculateBounds(CListElm *list_bounds);

//--- Prints assigned row model to log
   void              TableRowModelPrint(const bool detail,const bool as_table=false,const int cell_width=CELL_WIDTH_IN_CHARS);
   
//--- Draws visual appearance
   virtual void      Draw(const bool chart_redraw);
   
//--- Virtual methods: (1) compare, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0)const { return CLabel::Compare(node,mode);               }
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_ROW_VIEW);             }
  
//--- Initialization (1) class object, (2) default object colors
   void              Init(void);
   virtual void      InitColors(void);

//--- Constructors / destructor
                     CTableRowView(void);
                     CTableRowView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
                    ~CTableRowView(void){ this.m_list_cells.Clear(); }
  };

//+------------------------------------------------------------------+
//| Default constructor. Creates object in the main chart window     |
//| at coordinates 0,0 with default size                             |
//+------------------------------------------------------------------+
CTableRowView::CTableRowView(void) :
   CPanel("TableRow","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H),
   m_index(-1)
  {
//--- Initialization
   this.Init();
  }

//+------------------------------------------------------------------+
//| Parameterized constructor. Creates object in the specified       |
//| chart window with specified text, coordinates and size           |
//+------------------------------------------------------------------+
CTableRowView::CTableRowView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CPanel(object_name,text,chart_id,wnd,x,y,w,h),
   m_index(-1)
  {
//--- Initialization
   this.Init();
  }

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void CTableRowView::Init(void)
  {
//--- Initialize parent object
   CPanel::Init();

//--- Background is opaque
   this.SetAlphaBG(255);

//--- Border width
   this.SetBorderWidth(1);
  }

//+------------------------------------------------------------------+
//| Initialize default object colors                                 |
//+------------------------------------------------------------------+
void CTableRowView::InitColors(void)
  {
//--- Initialize background colors for normal and active states
   this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.BackColorToDefault();
   
//--- Initialize foreground (text) colors
   this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   this.ForeColorToDefault();
   
//--- Initialize border colors
   this.InitBorderColors(C'200,200,200',C'200,200,200',C'200,200,200',clrSilver);
   this.InitBorderColorsAct(C'200,200,200',C'200,200,200',C'200,200,200',clrSilver);
   this.BorderColorToDefault();
   
//--- Initialize colors for blocked element
   this.InitBorderColorBlocked(clrSilver);
   this.InitForeColorBlocked(clrSilver);
  }

  //+------------------------------------------------------------------+
//| CTableRowView::Creates and adds a new cell view object to list    |
//+------------------------------------------------------------------+
CTableCellView *CTableRowView::InsertNewCellView(const int index,const string text,const int dx,const int dy,const int w,const int h)
  {
//--- Check if an object with the specified ID already exists; if so, report and return NULL
   this.m_temp_cell.SetIndex(index);
//--- Store current list sorting mode
   int sort_mode=this.m_list_cells.SortMode();
//--- Set sorting flag by ID for searching
   this.m_list_cells.Sort(ELEMENT_SORT_BY_ID);
   if(this.m_list_cells.Search(&this.m_temp_cell)!=NULL)
     {
      //--- Restore original sorting, report duplicate object, and return NULL
      this.m_list_cells.Sort(sort_mode);
      ::PrintFormat("%s: Error. The TableCellView object with index %d is already in the list",__FUNCTION__,index);
      return NULL;
     }
//--- Restore original list sorting
   this.m_list_cells.Sort(sort_mode);
//--- Generate cell object name
   string name="TableCellView"+(string)this.Index()+"x"+(string)index;
//--- Create new TableCellView object; on failure, report and return NULL
   CTableCellView *cell_view=new CTableCellView(index,name,text,dx,dy,w,h);
   if(cell_view==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create CTableCellView object",__FUNCTION__);
      return NULL;
     }
//--- If adding to list fails, report, delete object, and return NULL
   if(this.m_list_cells.Add(cell_view)==-1)
     {
      ::PrintFormat("%s: Error. Failed to add CTableCellView object to list",__FUNCTION__);
      delete cell_view;
      return NULL;
     }
//--- Assign base element (row) and return pointer to the object
   cell_view.RowAssign(&this);
   return cell_view;
  }

//+------------------------------------------------------------------+
//| CTableRowView::Assigns the row model                             |
//+------------------------------------------------------------------+
bool CTableRowView::TableRowModelAssign(CTableRow *row_model)
  {
//--- If an empty object is passed, report and return false
   if(row_model==NULL)
     {
      ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
      return false;
     }
//--- If the passed row model contains no cells, report and return false
   int total=(int)row_model.CellsTotal();
   if(total==0)
     {
      ::PrintFormat("%s: Error. Row model does not contain any cells",__FUNCTION__);
      return false;
     }
//--- Save pointer to the row model
   this.m_table_row_model=row_model;
//--- Calculate cell width based on the row panel width
   CCanvasBase *base=this.GetContainer();
   int w=(base!=NULL ? base.Width() : this.Width());
   int cell_w=(int)::fmax(::round((double)w/(double)total),DEF_TABLE_COLUMN_MIN_W);

//--- Loop through the number of cells in the row model
   for(int i=0;i<total;i++)
     {
      //--- Get model for the current cell
      CTableCell *cell_model=this.m_table_row_model.GetCell(i);
      if(cell_model==NULL)
          return false;
      //--- Calculate coordinate and generate name for the cell bound
      int x=cell_w*i;
      string name="CellBound"+(string)this.m_table_row_model.Index()+"x"+(string)i;
      //--- Create new cell bound
      CBound *cell_bound=this.InsertNewBound(name,x,0,cell_w,this.Height());
      if(cell_bound==NULL)
          return false;
      //--- Create new cell visual representation object
      CTableCellView *cell_view=this.InsertNewCellView(i,cell_model.Value(),x,0,cell_w,this.Height());
      if(cell_view==NULL)
          return false;
      //--- Assign the visual representation object to the current cell bound
      cell_bound.AssignObject(cell_view);
     }
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| CTableRowView::Updates the row with an updated model             |
//+------------------------------------------------------------------+
bool CTableRowView::TableRowModelUpdate(CTableRow *row_model)
  {
//--- If empty object passed, report and return false
   if(row_model==NULL)
     {
      ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
      return false;
     }
//--- If the row model contains no cells, report and return false
   int total_model=(int)row_model.CellsTotal(); // Number of cells in row model
   if(total_model==0)
     {
      ::PrintFormat("%s: Error. Row model does not contain any cells",__FUNCTION__);
      return false;
     }
//--- Save pointer to the row model
   this.m_table_row_model=row_model;

//--- Calculate cell width based on row panel width
   CCanvasBase *base=this.GetContainer();
   int w=(base!=NULL ? base.Width() : this.Width());
   int cell_w=(int)::fmax(::round((double)w/(double)total_model),DEF_TABLE_COLUMN_MIN_W);
   
   CBound *cell_bound=NULL;
   int total_bounds=this.m_list_bounds.Total(); // Current number of bounds
   int diff=total_model-total_bounds;           // Difference between model cells and existing bounds
   
//--- If model has more cells, create missing bounds and cells at the end
   if(diff>0)
     {
      for(int i=total_bounds;i<total_bounds+diff;i++)
        {
         CTableCell *cell_model=this.m_table_row_model.GetCell(i);
         if(cell_model==NULL)
            return false;
         int x=cell_w*i;
         string name="CellBound"+(string)this.m_table_row_model.Index()+"x"+(string)i;
         CBound *cell_bound=this.InsertNewBound(name,x,0,cell_w,this.Height());
         if(cell_bound==NULL)
            return false;
            
         CTableCellView *cell_view=this.InsertNewCellView(i,cell_model.Value(),x,0,cell_w,this.Height());
         if(cell_view==NULL)
            return false;
        }
     }
 
//--- If list has more bounds than model, delete extra bounds from the end
   if(diff<0)
     {
      int start=total_bounds-1;
      int end=start-diff;
      for(int i=start;i>end;i--)
        {
         if(!this.BoundCellDelete(i))
            return false;
        }
     }
   
//--- Sync existing cells with model data
   for(int i=0;i<total_model;i++)
     {
      CTableCell *cell_model=this.m_table_row_model.GetCell(i);
      if(cell_model==NULL)
          return false;
      
      int x=cell_w*i;
      CBound *cell_bound=this.GetBoundAt(i);
      if(cell_bound==NULL)
          return false;
      
      CTableCellView *cell_view=this.m_list_cells.GetNodeAtIndex(i);
      if(cell_view==NULL)
          return false;
      
      //--- Assign object to current bound and update its text
      cell_bound.AssignObject(cell_view);
      cell_view.SetText(cell_model.Value());
     }
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| CTableRowView::Deletes specified row bound and corresponding cell|
//+------------------------------------------------------------------+
bool CTableRowView::BoundCellDelete(const int index)
  {
   if(!this.m_list_cells.Delete(index))
      return false;
   return this.m_list_bounds.Delete(index);
  }

//+------------------------------------------------------------------+
//| CTableRowView::Renders visual appearance                         |
//+------------------------------------------------------------------+
void CTableRowView::Draw(const bool chart_redraw)
  {
//--- Exit if row is outside container
   if(this.IsOutOfContainer())
      return;

//--- Fill with background color, draw row line, and update canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Line(this.AdjX(0),this.AdjY(this.Height()-1),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
  
//--- Draw row cells
   int total=this.m_list_bounds.Total();
   for(int i=0;i<total;i++)
     {
      CBound *cell_bound=this.GetBoundAt(i);
      if(cell_bound==NULL)
          continue;
      
      CTableCellView *cell_view=cell_bound.GetAssignedObj();
      if(cell_view!=NULL)
          cell_view.Draw(false);
     }
//--- Update background and foreground canvases
   this.Update(chart_redraw);
  }

//+------------------------------------------------------------------+
//| CTableRowView::Prints row model to journal                       |
//+------------------------------------------------------------------+
void CTableRowView::TableRowModelPrint(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS)
  {
   if(this.m_table_row_model!=NULL)
      this.m_table_row_model.Print(detail,as_table,cell_width);
  }

//+------------------------------------------------------------------+
//| CTableRowView::Recalculates cell bounds                           |
//+------------------------------------------------------------------+
bool CTableRowView::RecalculateBounds(CListElm *list_bounds)
  {
//--- Check list validity
   if(list_bounds==NULL)
      return false;

//--- Loop through bounds in the list
   for(int i=0;i<list_bounds.Total();i++)
     {
      //--- Get current header bound and its corresponding cell bound
      CBound *capt_bound=list_bounds.GetNodeAtIndex(i);
      CBound *cell_bound=this.GetBoundAt(i);
      if(capt_bound==NULL || cell_bound==NULL)
          return false;

      //--- Set header bound coordinates and size to the cell bound
      cell_bound.SetX(capt_bound.X());
      cell_bound.ResizeW(capt_bound.Width());
      
      //--- Get assigned object from the cell bound
      CTableCellView *cell_view=cell_bound.GetAssignedObj();
      if(cell_view==NULL)
          return false;

      //--- Sync cell visual object with the cell bound
      cell_view.BoundSetX(cell_bound.X());
      cell_view.BoundResizeW(cell_bound.Width());
     }
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| CTableRowView::Save to file                                      |
//+------------------------------------------------------------------+
bool CTableRowView::Save(const int file_handle)
  {
//--- Save parent object data
   if(!CPanel::Save(file_handle))
      return false;

//--- Save cell list
   if(!this.m_list_cells.Save(file_handle))
      return false;
//--- Save row index
   if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
      return false;
   
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| CTableRowView::Load from file                                    |
//+------------------------------------------------------------------+
bool CTableRowView::Load(const int file_handle)
  {
//--- Load parent object data
   if(!CPanel::Load(file_handle))
      return false;
      
//--- Load cell list
   if(!this.m_list_cells.Load(file_handle))
      return false;
//--- Load row index
   this.m_id=this.m_index=(uchar)::FileReadInteger(file_handle,INT_VALUE);
   
//--- Success
   return true;
  }
  #endif //__TABLE_ROW_VIEW_MQH__
