//+------------------------------------------------------------------+
//|                                                TableCellView.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|               https://www.mql5.com/en/articles/19979             |
//+------------------------------------------------------------------+

#ifndef __TABLE_CELL_VIEW_MQH__
#define __TABLE_CELL_VIEW_MQH__
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Canvas\Canvas.mqh>

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+

#include "..\Base\BoundedObj.mqh"
#include "..\Table\TableCell.mqh"
#include "..\Controls\TableRowView.mqh"
#include "ImagePainter.mqh"
//+------------------------------------------------------------------+
//| Class representing the visual representation of a table cell    |
//+------------------------------------------------------------------+
class CTableCellView : public CBoundedObj
  {
protected:
   CTableCell       *m_table_cell_model;     // Pointer to the cell model
   CImagePainter    *m_painter;              // Pointer to drawing object
   CTableRowView    *m_element_base;         // Pointer to the base element (table row)
   CCanvas          *m_background;           // Pointer to background canvas
   CCanvas          *m_foreground;           // Pointer to foreground canvas
   int               m_index;                // Index in the cell list
   ENUM_ANCHOR_POINT m_text_anchor;          // Text anchor point (alignment inside the cell)
   int               m_text_x;               // Text X coordinate (offset relative to left boundary)
   int               m_text_y;               // Text Y coordinate (offset relative to top boundary)
   ushort            m_text[];               // Text
   color             m_fore_color;           // Foreground color
   
//--- Returns offsets of the initial drawing coordinates relative to the canvas and base element
   int CanvasOffsetX(void) const { return(this.m_element_base.ObjectX()-this.m_element_base.X()); }
   int CanvasOffsetY(void) const { return(this.m_element_base.ObjectY()-this.m_element_base.Y()); }

//--- Returns adjusted canvas coordinate considering canvas offset relative to base element
   int AdjX(const int x) const { return(x-this.CanvasOffsetX()); }
   int AdjY(const int y) const { return(y-this.CanvasOffsetY()); }

//--- Returns X and Y text coordinates depending on anchor point
   bool GetTextCoordsByAnchor(int &x,int &y,int &dir_x,int dir_y);

//--- Returns pointer to table rows panel container
   CContainer *GetRowsPanelContainer(void);
   
public:
//--- Returns assigned canvases: (1) background, (2) foreground
   CCanvas *GetBackground(void) { return this.m_background; }
   CCanvas *GetForeground(void) { return this.m_foreground; }

//--- Getting parent container boundaries
   int ContainerLimitLeft(void) const { return(this.m_element_base==NULL ? this.X() : this.m_element_base.LimitLeft()); }
   int ContainerLimitRight(void) const { return(this.m_element_base==NULL ? this.Right() : this.m_element_base.LimitRight()); }
   int ContainerLimitTop(void) const { return(this.m_element_base==NULL ? this.Y() : this.m_element_base.LimitTop()); }
   int ContainerLimitBottom(void) const { return(this.m_element_base==NULL ? this.Bottom() : this.m_element_base.LimitBottom()); }

//--- Returns flag indicating that object is outside its container
   virtual bool IsOutOfContainer(void);

//--- (1) Set, (2) get cell text
   void SetText(const string text) { ::StringToShortArray(text,this.m_text); }
   string Text(void) const { return ::ShortArrayToString(this.m_text); }

//--- (1) Set, (2) get cell text color
   void SetForeColor(const color clr) { this.m_fore_color=clr; }
   color ForeColor(void) const { return this.m_fore_color; }

//--- Set identifier
   virtual void SetID(const int id) { this.m_index=this.m_id=id; }

//--- (1) Set, (2) get cell index
   void SetIndex(const int index) { this.SetID(index); }
   int Index(void) const { return this.m_index; }

//--- (1) Set, (2) get text X shift
   void SetTextShiftX(const int shift) { this.m_text_x=shift; }
   int TextShiftX(void) const { return this.m_text_x; }

//--- (1) Set, (2) get text Y shift
   void SetTextShiftY(const int shift) { this.m_text_y=shift; }
   int TextShiftY(void) const { return this.m_text_y; }

//--- (1) Set, (2) get text anchor
   void SetTextAnchor(const ENUM_ANCHOR_POINT anchor,const bool cell_redraw,const bool chart_redraw);
   int TextAnchor(void) const { return this.m_text_anchor; }

//--- Set text anchor and shift
   void SetTextPosition(const ENUM_ANCHOR_POINT anchor,const int shift_x,const int shift_y,const bool cell_redraw,const bool chart_redraw);

//--- Assign base element (table row)
   void RowAssign(CTableRowView *base_element);

//--- (1) Assign, (2) get cell model
   bool TableCellModelAssign(CTableCell *cell_model,int dx,int dy,int w,int h);
   CTableCell *GetTableCellModel(void) { return this.m_table_cell_model; }

//--- Print assigned cell model to log
   void TableCellModelPrint(void);

//--- (1) Fill object with background color, (2) update object, (3) draw appearance
   virtual void Clear(const bool chart_redraw);
   virtual void Update(const bool chart_redraw);
   virtual void Draw(const bool chart_redraw);

//--- Draw text
   virtual void DrawText(const int dx,const int dy,const string text,const bool chart_redraw);

//--- Virtual methods: (1) comparison, (2) save to file, (3) load from file, (4) object type
   virtual int Compare(const CObject *node,const int mode=0)const { return CBaseObj::Compare(node,mode); }
   virtual bool Save(const int file_handle);
   virtual bool Load(const int file_handle);
   virtual int Type(void) const { return(ELEMENT_TYPE_TABLE_CELL_VIEW); }

//--- Class object initialization
   void Init(const string text);

//--- Returns object description
   virtual string Description(void);

//--- Constructors / destructor
   CTableCellView(void);
   CTableCellView(const int id,const string user_name,const string text,const int x,const int y,const int w,const int h);
   ~CTableCellView(void){}
  };
//+------------------------------------------------------------------+
//| CTableCellView::Default constructor. Builds an object in the     |
//| main window of the current chart at 0,0 with default dimensions  |
//+------------------------------------------------------------------+
CTableCellView::CTableCellView(void) : CBoundedObj("TableCell",-1,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H), m_index(-1),m_text_anchor(ANCHOR_LEFT)
  {
//--- Initialization
   this.Init("");
   this.SetID(-1);
   this.SetName("TableCell");
  }

//+------------------------------------------------------------------+
//| CTableCellView::Parametric constructor. Builds an object in the  |
//| specified chart window with given text, coordinates, and sizes   |
//+------------------------------------------------------------------+
CTableCellView::CTableCellView(const int id, const string user_name, const string text, const int x, const int y, const int w, const int h) :
   CBoundedObj(user_name,id,x,y,w,h), m_index(-1),m_text_anchor(ANCHOR_LEFT)
  {
//--- Initialization
   this.Init(text);
   this.SetID(id);
   this.SetName(user_name);
  }

//+------------------------------------------------------------------+
//| CTableCellView::Initialization                                   |
//+------------------------------------------------------------------+
void CTableCellView::Init(const string text)
  {
//--- The class does not manage canvases independently
   this.m_canvas_owner=false;
//--- Cell text
   this.SetText(text);
//--- Default text offsets
   this.m_text_x=2;
   this.m_text_y=0;
  }

//+------------------------------------------------------------------+
//| CTableCellView::Returns object description                       |
//+------------------------------------------------------------------+
string CTableCellView::Description(void)
  {
   string nm=this.Name();
   string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   return ::StringFormat("%s%s ID %d, X %d, Y %d, W %d, H %d, Value: \"%s\"",
                         ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,
                         this.ID(),this.X(),this.Y(),this.Width(),this.Height(),this.Text());
  }

//+------------------------------------------------------------------+
//| CTableCellView::Assigns row, background, and foreground canvases |
//+------------------------------------------------------------------+
void CTableCellView::RowAssign(CTableRowView *base_element)
  {
   if(base_element==NULL)
     {
      ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
      return;
     }
   this.m_element_base=base_element;
   this.m_background=this.m_element_base.GetBackground();
   this.m_foreground=this.m_element_base.GetForeground();
   this.m_painter=this.m_element_base.Painter();
   this.m_fore_color=this.m_element_base.ForeColor();
  }

//+------------------------------------------------------------------+
//| CTableCellView::Assigns the cell model                           |
//+------------------------------------------------------------------+
bool CTableCellView::TableCellModelAssign(CTableCell *cell_model,int dx,int dy,int w,int h)
  {
//--- If an invalid cell model object is passed - report error and return false
   if(cell_model==NULL)
     {
      ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
      return false;
     }
//--- If the base element (table row) is not assigned - report error and return false
   if(this.m_element_base==NULL)
     {
      ::PrintFormat("%s: Error. Base element not assigned. Please use RowAssign() method first",__FUNCTION__);
      return false;
     }
//--- Save the cell model
   this.m_table_cell_model=cell_model;
//--- Set coordinates and dimensions of the cell's visual representation
   this.BoundSetXY(dx,dy);
   this.BoundResize(w,h);
//--- Set drawing area dimensions for the cell's visual representation
   this.m_painter.SetBound(dx,dy,w,h);
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| CTableCellView::Returns X and Y coordinates of the text          |
//| depending on the anchor point                                    |
//+------------------------------------------------------------------+
bool CTableCellView::GetTextCoordsByAnchor(int &x,int &y, int &dir_x,int dir_y)
  {
//--- Get text dimensions in the cell
   int text_w=0, text_h=0;
   this.m_foreground.TextSize(this.Text(),text_w,text_h);
   if(text_w==0 || text_h==0)
      return false;
//--- Depending on the text anchor point in the cell,
//--- calculate its starting coordinates (top-left corner)
   switch(this.m_text_anchor)
     {
      //--- Left-center anchor point
      case ANCHOR_LEFT :
        x=0;
        y=(this.Height()-text_h)/2;
        dir_x=1;
        dir_y=1;
        break;
      //--- Left-lower anchor point
      case ANCHOR_LEFT_LOWER :
        x=0;
        y=this.Height()-text_h;
        dir_x= 1;
        dir_y=-1;
        break;
      //--- Bottom-center anchor point
      case ANCHOR_LOWER :
        x=(this.Width()-text_w)/2;
        y=this.Height()-text_h;
        dir_x= 1;
        dir_y=-1;
        break;
      //--- Right-lower anchor point
      case ANCHOR_RIGHT_LOWER :
        x=this.Width()-text_w;
        y=this.Height()-text_h;
        dir_x=-1;
        dir_y=-1;
        break;
      //--- Right-center anchor point
      case ANCHOR_RIGHT :
        x=this.Width()-text_w;
        y=(this.Height()-text_h)/2;
        dir_x=-1;
        dir_y= 1;
        break;
      //--- Right-upper anchor point
      case ANCHOR_RIGHT_UPPER :
        x=this.Width()-text_w;
        y=0;
        dir_x=-1;
        dir_y= 1;
        break;
      //--- Top-center anchor point
      case ANCHOR_UPPER :
        x=(this.Width()-text_w)/2;
        y=0;
        dir_x=1;
        dir_y=1;
        break;
      //--- Anchor point strictly at the center of the object
      case ANCHOR_CENTER :
        x=(this.Width()-text_w)/2;
        y=(this.Height()-text_h)/2;
        dir_x=1;
        dir_y=1;
        break;
      //--- Left-upper anchor point
      //--- ANCHOR_LEFT_UPPER
      default:
        x=0;
        y=0;
        dir_x=1;
        dir_y=1;
        break;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| CTableCellView::Sets the text anchor point                       |
//+------------------------------------------------------------------+
void CTableCellView::SetTextAnchor(const ENUM_ANCHOR_POINT anchor,const bool cell_redraw,const bool chart_redraw)
  {
   if(this.m_text_anchor==anchor)
      return;
   this.m_text_anchor=anchor;
   if(cell_redraw)
      this.Draw(chart_redraw);
  }

//+------------------------------------------------------------------+
//| CTableCellView::Sets text anchor point and offsets               |
//+------------------------------------------------------------------+
void CTableCellView::SetTextPosition(const ENUM_ANCHOR_POINT anchor,const int shift_x,const int shift_y,const bool cell_redraw,const bool chart_redraw)
  {
   this.SetTextShiftX(shift_x);
   this.SetTextShiftY(shift_y);
   this.SetTextAnchor(anchor,cell_redraw,chart_redraw);
  }

//+------------------------------------------------------------------+
//| CTableCellView::Fills the object with color                      |
//+------------------------------------------------------------------+
void CTableCellView::Clear(const bool chart_redraw)
  {
//--- Set correct coordinates for cell corners
   int x1=this.AdjX(this.m_bound.X());
   int y1=this.AdjY(this.m_bound.Y());
   int x2=this.AdjX(this.m_bound.Right());
   int y2=this.AdjY(this.m_bound.Bottom());
//--- Erase background and foreground within the rectangular cell area
   if(this.m_background!=NULL)
      this.m_background.FillRectangle(x1,y1,x2,y2-1,::ColorToARGB(this.m_element_base.BackColor(),this.m_element_base.AlphaBG()));
   if(this.m_foreground!=NULL)
      this.m_foreground.FillRectangle(x1,y1,x2,y2-1,clrNULL);
  }

//+------------------------------------------------------------------+
//| CTableCellView::Updates the object to reflect changes            |
//+------------------------------------------------------------------+
void CTableCellView::Update(const bool chart_redraw)
  {
   if(this.m_background!=NULL)
      this.m_background.Update(false);
   if(this.m_foreground!=NULL)
      this.m_foreground.Update(chart_redraw);
  }

//+------------------------------------------------------------------+
//| CTableCellView::Returns a pointer                                | 
//| to the table row panel container                                 |
//+------------------------------------------------------------------+
CContainer *CTableCellView::GetRowsPanelContainer(void)
  {
//--- Check the row element
   if(this.m_element_base==NULL)
      return NULL;
//--- Get the panel for row placement
   CPanel *rows_area=this.m_element_base.GetContainer();
   if(rows_area==NULL)
      return NULL;
//--- Return the container of the row panel
   return rows_area.GetContainer();
  }
  //+------------------------------------------------------------------+
//| CTableCellView::Returns a flag indicating if the object is       |
//| located outside its container boundaries                         |
//+------------------------------------------------------------------+
bool CTableCellView::IsOutOfContainer(void)
  {
//--- Check the base row element
   if(this.m_element_base==NULL)
      return false;

//--- Get the container of the row panel
   CContainer *container=this.GetRowsPanelContainer();
   if(container==NULL)
      return false;
  
//--- Get cell boundaries on all sides
   int cell_l=this.m_element_base.X()+this.X();
   int cell_r=this.m_element_base.X()+this.Right();
   int cell_t=this.m_element_base.Y()+this.Y();
   int cell_b=this.m_element_base.Y()+this.Bottom();
   
//--- Return true if the object is completely outside the container limits
   return(cell_r <= container.X() || cell_l >= container.Right() || cell_b <= container.Y() || cell_t >= container.Bottom());
  }

//+------------------------------------------------------------------+
//| CTableCellView::Renders the visual appearance                    |
//+------------------------------------------------------------------+
void CTableCellView::Draw(const bool chart_redraw)
  {
//--- If the cell is outside the table row container - exit
   if(this.IsOutOfContainer())
      return;
      
//--- Get text coordinates and offset direction based on the anchor point
   int text_x=0, text_y=0;
   int dir_horz=0, dir_vert=0;
   if(!this.GetTextCoordsByAnchor(text_x,text_y,dir_horz,dir_vert))
      return;
//--- Adjust text coordinates
   int x=this.AdjX(this.X()+text_x);
   int y=this.AdjY(this.Y()+text_y);
   
//--- Set coordinates for the separator line
   int x1=this.AdjX(this.X());
   int x2=this.AdjX(this.X());
   int y1=this.AdjY(this.Y());
   int y2=this.AdjY(this.Bottom());
   
//--- Output text on the foreground canvas considering offset direction without chart update
   this.DrawText(x+this.m_text_x*dir_horz,y+this.m_text_y*dir_vert,this.Text(),false);
   
//--- If this is not the rightmost cell - draw a vertical separator line on the right
   if(this.m_element_base!=NULL && this.Index()<this.m_element_base.CellsTotal()-1)
     {
      int line_x=this.AdjX(this.Right());
      this.m_background.Line(line_x,y1,line_x,y2,::ColorToARGB(this.m_element_base.BorderColor(),this.m_element_base.AlphaBG()));
     }
//--- Update background canvas with the specified chart redraw flag
   this.m_background.Update(chart_redraw);
  }

//+------------------------------------------------------------------+
//| CTableCellView::Outputs text to the canvas                       |
//+------------------------------------------------------------------+
void CTableCellView::DrawText(const int dx,const int dy,const string text,const bool chart_redraw)
  {
//--- Check the base element
   if(this.m_element_base==NULL)
      return;
      
//--- Clear the cell and set the text
   this.Clear(false);
   this.SetText(text);
   
//--- Output the set text on the foreground canvas
   this.m_foreground.TextOut(dx,dy,this.Text(),::ColorToARGB(this.ForeColor(),this.m_element_base.AlphaFG()));
   
//--- If the text exceeds the right boundary of the cell area
   if(this.Right()-dx<this.m_foreground.TextWidth(text))
     {
//--- Get dimensions of the ellipsis text ("...")
      int w=0,h=0;
      this.m_foreground.TextSize("... ",w,h);
      if(w>0 && h>0)
        {
//--- Erase text at the right boundary and replace with ellipsis
         this.m_foreground.FillRectangle(this.AdjX(this.Right())-w,this.AdjY(this.Y()),this.AdjX(this.Right()),this.AdjY(this.Y())+h,clrNULL);
         this.m_foreground.TextOut(this.AdjX(this.Right())-w,this.AdjY(dy),"...",::ColorToARGB(this.ForeColor(),this.m_element_base.AlphaFG()));
        }
     }
//--- Update foreground canvas with the specified chart redraw flag
   this.m_foreground.Update(chart_redraw);
  }

//+------------------------------------------------------------------+
//| CTableCellView::Prints the assigned row model to the journal     |
//+------------------------------------------------------------------+
void CTableCellView::TableCellModelPrint(void)
  {
   if(this.m_table_cell_model!=NULL)
      this.m_table_cell_model.Print();
  }

//+------------------------------------------------------------------+
//| CTableCellView::Save to file                                     |
//+------------------------------------------------------------------+
bool CTableCellView::Save(const int file_handle)
  {
//--- Save parent object data
   if(!CBaseObj::Save(file_handle))
      return false;
  
//--- Save cell index
   if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
      return false;
//--- Save text anchor point
   if(::FileWriteInteger(file_handle,this.m_text_anchor,INT_VALUE)!=INT_VALUE)
      return false;
//--- Save text X coordinate
   if(::FileWriteInteger(file_handle,this.m_text_x,INT_VALUE)!=INT_VALUE)
      return false;
//--- Save text Y coordinate
   if(::FileWriteInteger(file_handle,this.m_text_y,INT_VALUE)!=INT_VALUE)
      return false;
//--- Save text
   if(::FileWriteArray(file_handle,this.m_text)!=sizeof(this.m_text))
      return false;
      
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| CTableCellView::Load from file                                   |
//+------------------------------------------------------------------+
bool CTableCellView::Load(const int file_handle)
  {
//--- Load parent object data
   if(!CBaseObj::Load(file_handle))
      return false;
      
//--- Load cell index
   this.m_id=this.m_index=::FileReadInteger(file_handle,INT_VALUE);
//--- Load text anchor point
   this.m_text_anchor=(ENUM_ANCHOR_POINT)::FileReadInteger(file_handle,INT_VALUE);
//--- Load text X coordinate
   this.m_text_x=::FileReadInteger(file_handle,INT_VALUE);
//--- Load text Y coordinate
   this.m_text_y=::FileReadInteger(file_handle,INT_VALUE);
//--- Load text
   if(::FileReadArray(file_handle,this.m_text)!=sizeof(this.m_text))
      return false;
   
//--- Success
   return true;
  }
#endif