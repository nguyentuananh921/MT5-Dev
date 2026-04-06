//+------------------------------------------------------------------+
//|                                              TableCellView.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Table cell visual representation class |
//+------------------------------------------------------------------+
#ifndef __TABLECELLVIEW_MQH__
#define __TABLECELLVIEW_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   #include <Canvas\Canvas.mqh>
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "..\Defines\ControlsDefines.mqh"
   #include "..\Defines\ControlsEnums.mqh"

   #include "..\Base\BoundedObj.mqh"
   // Forward declarations for Pointer variables và method params
   class CTableCell;      
   class CTableRowView; 
   class CImagePainter;
   class CContainer;        
 class CTableCellView : public CBoundedObj
  {
      protected:
         CTableCell       *m_table_cell_model;                       // Pointer to cell model
         CImagePainter    *m_painter;                                // Pointer to the drawing object
         CTableRowView    *m_element_base;                           // Pointer to base element (table row)
         CCanvas          *m_background;                             // Pointer to canvas background
         CCanvas          *m_foreground;                             // Pointer to foreground canvas
         int               m_index;                                  // Index in a list of cells
         ENUM_ANCHOR_POINT m_text_anchor;                            // Text anchor point (alignment in cell)
         int               m_text_x;                                 // X coordinate of the text (offset relative to the left edge of the object area)
         int               m_text_y;                                 // Y coordinate of the text (offset relative to the top border of the object area)
         ushort            m_text[];                                 // Text
         color             m_fore_color;                             // Foreground color
         color             m_back_color;                             // Background color
         
      // --- Returns the offsets of the initial drawing coordinates on the canvas relative to the canvas and the coordinates of the base element
         int               CanvasOffsetX(void)     const { return(this.m_element_base.ObjectX()-this.m_element_base.X());  }
         int               CanvasOffsetY(void)     const { return(this.m_element_base.ObjectY()-this.m_element_base.Y());  }
         
      // --- Returns the adjusted coordinate of a point on the canvas, taking into account the offset of the canvas relative to the base element
         int               AdjX(const int x)                            const { return(x-this.CanvasOffsetX());            }
         int               AdjY(const int y)                            const { return(y-this.CanvasOffsetY());            }

      // --- Returns the X and Y coordinates of the text depending on the anchor point
         bool              GetTextCoordsByAnchor(int &x, int &y, int &dir_x, int dir_y);

      // --- Returns a pointer to the table row pane container
         CContainer       *GetRowsPanelContainer(void);
         
      public:
      // --- Returns a pointer to the designated (1) background, (2) foreground canvas
         CCanvas          *GetBackground(void)                                { return this.m_background;                  }
         CCanvas          *GetForeground(void)                                { return this.m_foreground;                  }

      // --- Getting the bounds of the parent container object
         int               ContainerLimitLeft(void)   const { return(this.m_element_base==NULL ? this.X()      :  this.m_element_base.LimitLeft());   }
         int               ContainerLimitRight(void)  const { return(this.m_element_base==NULL ? this.Right()  :  this.m_element_base.LimitRight());  }
         int               ContainerLimitTop(void)    const { return(this.m_element_base==NULL ? this.Y()      :  this.m_element_base.LimitTop());    }
         int               ContainerLimitBottom(void) const { return(this.m_element_base==NULL ? this.Bottom() :  this.m_element_base.LimitBottom()); }

      // --- Returns a flag that an object is located outside of its container
         virtual bool      IsOutOfContainer(void);

      // --- (1) Sets, (2) returns the cell text
         void              SetText(const string text)                         { ::StringToShortArray(text,this.m_text);    }
         string            Text(void)                                   const { return ::ShortArrayToString(this.m_text);  }

      // --- (1) Sets, (2) returns the cell text color
         void              SetForeColor(const color clr)                      { this.m_fore_color=clr;                     }
         color             ForeColor(void)                              const { return this.m_fore_color;                  }

      // --- (1) Sets, (2) returns the background color of the cell
         void              SetBackColor(const color clr)                      { this.m_back_color=clr;                     }
         color             BackColor(void)                              const { return this.m_back_color;                  }

      // --- Sets the ID
         virtual void      SetID(const int id)                                { this.m_id=id;                              }
      // --- (1) Sets, (2) returns the cell index
         void              SetIndex(const int index)                          { this.m_index=index;                        }
         int               Index(void)                                  const { return this.m_index;                       }

      // --- (1) Sets, (2) returns the X offset of the text
         void              SetTextShiftX(const int shift)                     { this.m_text_x=shift;                       }
         int               TextShiftX(void)                             const { return this.m_text_x;                      }
         
      // --- (1) Sets, (2) returns the Y-axis offset of the text
         void              SetTextShiftY(const int shift)                     { this.m_text_y=shift;                       }
         int               TextShiftY(void)                             const { return this.m_text_y;                      }
         
      // --- (1) Sets, (2) returns the text anchor point
         void              SetTextAnchor(const ENUM_ANCHOR_POINT anchor,const bool cell_redraw,const bool chart_redraw);
         int               TextAnchor(void)                             const { return this.m_text_anchor;                 }
         
      // --- Sets the text anchor and offset point
         void              SetTextPosition(const ENUM_ANCHOR_POINT anchor,const int shift_x,const int shift_y,const bool cell_redraw,const bool chart_redraw);

      // --- Assigns a base element (table row)
         void              RowAssign(CTableRowView *base_element);
         
      // --- (1) Assigns, (2) returns the cell model
         bool              TableCellModelAssign(CTableCell *cell_model,int dx,int dy,int w,int h);
         CTableCell       *GetTableCellModel(void)                            { return this.m_table_cell_model;            }

      // --- Prints the assigned cell model in the journal
         void              TableCellModelPrint(void);
         
      // --- (1) Fills the object with the background color, (2) Updates the object to reflect the changes, (3) Draws the appearance
         virtual void      Clear(const bool chart_redraw);
         virtual void      Update(const bool chart_redraw);
         virtual void      Draw(const bool chart_redraw);
         
      // --- Outputs text
         virtual void      DrawText(const int dx, const int dy, const string text, const bool chart_redraw);
         
      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0)const { return CBaseObj::Compare(node,mode);       }
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_CELL_VIEW);      }
         
      // --- Initializing a class object
         void              Init(const string text);
         
      // --- Returns a description of the object
         virtual string    Description(void);
         
      // --- Constructors/destructor
                           CTableCellView(void);
                           CTableCellView(const int id, const string user_name, const string text, const int x, const int y, const int w, const int h);
                        ~CTableCellView (void){}
  };
  #ifndef CTABLECELLVIEW_IMPLEMENTATION
  #define CTABLECELLVIEW_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CTableCellView::Default constructor. Builds an object in the main|
   // | window of the current chart in coordinates 0,0 with default sizes |
   //+------------------------------------------------------------------+
   CTableCellView::CTableCellView(void) : CBoundedObj("TableCell",-1,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H), m_index(-1),m_text_anchor(ANCHOR_LEFT)
    {
      // ---Initialization
         this.Init("");
         this.SetID(-1);
         this.SetIndex(-1);
         this.SetName("TableCellView");
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Parametric constructor. Builds an object |
   // | in the specified window of the specified chart with the specified text, |
   // | coordinates and dimensions |
   //+------------------------------------------------------------------+
   CTableCellView::CTableCellView(const int id, const string user_name, const string text, const int x, const int y, const int w, const int h) :
      CBoundedObj(user_name,id,x,y,w,h), m_index(-1),m_text_anchor(ANCHOR_LEFT)
    {
      // ---Initialization
         this.Init(text);
         this.SetID(id);
         this.SetIndex(-1);
         this.SetName(user_name);
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Initializing |
   //+------------------------------------------------------------------+
   void CTableCellView::Init(const string text)
    {
      // --- The class does not manage canvases
         this.m_canvas_owner=false;
      // --- Cell text
         this.SetText(text);
      // --- Default text offsets
         this.m_text_x=2;
         this.m_text_y=0;
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Returns object description |
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
   // | CTableCellView::Assigns row, background and foreground canvases |
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
         this.m_back_color=this.m_element_base.BackColor();
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Assigns a cell model |
   //+------------------------------------------------------------------+
   bool CTableCellView::TableCellModelAssign(CTableCell *cell_model,int dx,int dy,int w,int h)
    {
      // --- If an invalid cell model object is passed, we report this and return false
         if(cell_model==NULL)
         {
            ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
            return false;
         }
      // --- If the base element (table row) is not assigned, we report this and return false
         if(this.m_element_base==NULL)
         {
            ::PrintFormat("%s: Error. Base element not assigned. Please use RowAssign() method first",__FUNCTION__);
            return false;
         }
      // --- Save the cell model
         this.m_table_cell_model=cell_model;
      // --- Set the coordinates and dimensions of the visual representation of the cell
         this.BoundSetXY(dx,dy);
         this.BoundResize(w,h);
      // --- Set the dimensions of the drawing area of ​​the visual representation of the cell
         this.m_painter.SetBound(dx,dy,w,h);
      // --- Everything is successful
         return true;
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Returns the X and Y coordinates of the text |
   // | depending on the anchor point |
   //+------------------------------------------------------------------+
   bool CTableCellView::GetTextCoordsByAnchor(int &x,int &y, int &dir_x,int dir_y)
    {
      // --- Get the dimensions of the text in the cell
         int text_w=0, text_h=0;
         this.m_foreground.TextSize(this.Text(),text_w,text_h);
         if(text_w==0 || text_h==0)
            return false;
      // --- Depending on the text anchor point in the cell
      // --- calculate its initial coordinates (upper left corner)
         switch(this.m_text_anchor)
         {
            // --- Anchor point left center
            case ANCHOR_LEFT :
            x=0;
            y=(this.Height()-text_h)/2;
            dir_x=1;
            dir_y=1;
            break;
            // --- Anchor point in the lower left corner
            case ANCHOR_LEFT_LOWER :
            x=0;
            y=this.Height()-text_h;
            dir_x= 1;
            dir_y=-1;
            break;
            // --- Anchor point bottom center
            case ANCHOR_LOWER :
            x=(this.Width()-text_w)/2;
            y=this.Height()-text_h;
            dir_x= 1;
            dir_y=-1;
            break;
            // --- Anchor point in the lower right corner
            case ANCHOR_RIGHT_LOWER :
            x=this.Width()-text_w;
            y=this.Height()-text_h;
            dir_x=-1;
            dir_y=-1;
            break;
            // --- Anchor point right center
            case ANCHOR_RIGHT :
            x=this.Width()-text_w;
            y=(this.Height()-text_h)/2;
            dir_x=-1;
            dir_y= 1;
            break;
            // --- Anchor point in the upper right corner
            case ANCHOR_RIGHT_UPPER :
            x=this.Width()-text_w;
            y=0;
            dir_x=-1;
            dir_y= 1;
            break;
            // --- Anchor point top center
            case ANCHOR_UPPER :
            x=(this.Width()-text_w)/2;
            y=0;
            dir_x=1;
            dir_y=1;
            break;
            // --- The anchor point is strictly in the center of the object
            case ANCHOR_CENTER :
            x=(this.Width()-text_w)/2;
            y=(this.Height()-text_h)/2;
            dir_x=1;
            dir_y=1;
            break;
            // --- Anchor point in the upper left corner
            //---ANCHOR_LEFT_UPPER
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
   // | CTableCellView::Sets text anchor point |
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
   // | CTableCellView::Sets text anchor and offset |
   //+------------------------------------------------------------------+
   void CTableCellView::SetTextPosition(const ENUM_ANCHOR_POINT anchor,const int shift_x,const int shift_y,const bool cell_redraw,const bool chart_redraw)
    {
         this.SetTextShiftX(shift_x);
         this.SetTextShiftY(shift_y);
         this.SetTextAnchor(anchor,cell_redraw,chart_redraw);
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Fills an object with color |
   //+------------------------------------------------------------------+
   void CTableCellView::Clear(const bool chart_redraw)
    {
      // --- Set the correct coordinates of the cell corners
         int x1=this.AdjX(this.m_bound.X());
         int y1=this.AdjY(this.m_bound.Y());
         int x2=this.AdjX(this.m_bound.Right());
         int y2=this.AdjY(this.m_bound.Bottom());
      // --- Erase the background and foreground inside the rectangular area of ​​the cell location
         if(this.m_background!=NULL)
            this.m_background.FillRectangle(x1,y1,x2,y2-1,::ColorToARGB(this.m_element_base.BackColor(),this.m_element_base.AlphaBG()));
         if(this.m_foreground!=NULL)
            this.m_foreground.FillRectangle(x1,y1,x2,y2-1,clrNULL);
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Updates an object to reflect changes |
   //+------------------------------------------------------------------+
   void CTableCellView::Update(const bool chart_redraw)
    {
         if(this.m_background!=NULL)
            this.m_background.Update(false);
         if(this.m_foreground!=NULL)
            this.m_foreground.Update(chart_redraw);
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Returns a pointer |
   // | to the table row panel container |
   //+------------------------------------------------------------------+
   CContainer *CTableCellView::GetRowsPanelContainer(void)
    {
      // --- Checking the string
         if(this.m_element_base==NULL)
            return NULL;
      // --- We get a panel for placing lines
         CPanel *rows_area=this.m_element_base.GetContainer();
         if(rows_area==NULL)
            return NULL;
      // --- Return the panel container with rows
         return rows_area.GetContainer();
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Returns the flag that the object |
   // | located outside of its container |
   //+------------------------------------------------------------------+
   bool CTableCellView::IsOutOfContainer(void)
    {
      // --- Checking the string
         if(this.m_element_base==NULL)
            return false;

      // --- We get a panel container with rows
         CContainer *container=this.GetRowsPanelContainer();
         if(container==NULL)
            return false;
      
      // --- We get the cell boundaries on all sides
         int cell_l=this.m_element_base.X()+this.X();
         int cell_r=this.m_element_base.X()+this.Right();
         int cell_t=this.m_element_base.Y()+this.Y();
         int cell_b=this.m_element_base.Y()+this.Bottom();
         
      // --- Return the result of checking that the object completely extends beyond the container
         return(cell_r <= container.X() || cell_l >= container.Right() || cell_b <= container.Y() || cell_t >= container.Bottom());
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Draws appearance |
   //+------------------------------------------------------------------+
   void CTableCellView::Draw(const bool chart_redraw)
    {
      // --- If the cell is outside the table row container - leave
         if(this.IsOutOfContainer())
            return;
            
      // --- Get text coordinates and offset direction depending on the anchor point
         int text_x=0, text_y=0;
         int dir_horz=0, dir_vert=0;
         if(!this.GetTextCoordsByAnchor(text_x,text_y,dir_horz,dir_vert))
            return;
      // --- Correcting text coordinates
         int x=this.AdjX(this.X()+text_x);
         int y=this.AdjY(this.Y()+text_y);
         
      // --- Set the coordinates of the dividing line
         int x1=this.AdjX(this.X());
         int y1=this.AdjY(this.Y());
         int x2=this.AdjX(this.X());
         int y2=this.AdjY(this.Bottom());

      // --- Displaying text on the foreground canvas taking into account the displacement direction without updating the graph
         this.DrawText(x+this.m_text_x*dir_horz,y+this.m_text_y*dir_vert,this.Text(),false);
         
      // --- Set the coordinates of the rectangular fill
         x1=this.AdjX(this.X());
         y1=this.AdjY(this.Y());
         x2=this.AdjX(this.Right());
         y2=this.AdjY(this.Bottom()-1);
         this.m_background.FillRectangle(x1,y1,x2,y2,::ColorToARGB(this.BackColor(),this.m_element_base.AlphaBG()));

      // --- If this is not the cell on the far right, draw a vertical dividing stripe near the cell on the right
         if(this.m_element_base!=NULL && this.Index()<this.m_element_base.CellsTotal()-1)
         {
            int line_x=this.AdjX(this.Right());
            this.m_background.Line(line_x,y1,line_x,y2,::ColorToARGB(this.m_element_base.BorderColor(),this.m_element_base.AlphaBG()));
         }
      // --- Update the background canvas with the specified graph redraw flag
         this.m_background.Update(chart_redraw);
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Displays text |
   //+------------------------------------------------------------------+
   void CTableCellView::DrawText(const int dx,const int dy,const string text,const bool chart_redraw)
    {
      // --- Checking the base element
         if(this.m_element_base==NULL)
            return;
            
      // --- Clear the cell and set the text
         this.Clear(false);
         this.SetText(text);
         
      // --- Display the set text on the foreground canvas
         this.m_foreground.TextOut(dx,dy,this.Text(),::ColorToARGB(this.ForeColor(),this.m_element_base.AlphaFG()));
         
      // --- If the text extends beyond the right border of the cell area
         if(this.Right()-dx<this.m_foreground.TextWidth(text))
         {
            // --- Getting the dimensions of the text "ellipsis"
            int w=0,h=0;
            this.m_foreground.TextSize("... ",w,h);
            if(w>0 && h>0)
            {
               // --- Erase the text at the right border of the object according to the text size "ellipsis" and replace the end of the label text with an ellipsis
               this.m_foreground.FillRectangle(this.AdjX(this.Right())-w,this.AdjY(this.Y()),this.AdjX(this.Right()),this.AdjY(this.Y())+h,clrNULL);
               this.m_foreground.TextOut(this.AdjX(this.Right())-w,this.AdjY(dy),"...",::ColorToARGB(this.ForeColor(),this.m_element_base.AlphaFG()));
            }
         }
      // --- Update the foreground canvas with the specified graph redraw flag
         this.m_foreground.Update(chart_redraw);
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Prints the assigned row model in the log|
   //+------------------------------------------------------------------+
   void CTableCellView::TableCellModelPrint(void)
    {
      if(this.m_table_cell_model!=NULL)
         this.m_table_cell_model.Print();
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Saving to file |
   //+------------------------------------------------------------------+
   bool CTableCellView::Save(const int file_handle)
    {
      // --- Save the data of the parent object
         if(!CBaseObj::Save(file_handle))
            return false;
      
      // --- Save the cell number
         if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
            return false;
      // --- Save the text anchor point
         if(::FileWriteInteger(file_handle,this.m_text_anchor,INT_VALUE)!=INT_VALUE)
            return false;
      // --- Save the X coordinate of the text
         if(::FileWriteInteger(file_handle,this.m_text_x,INT_VALUE)!=INT_VALUE)
            return false;
      // --- Save the Y coordinate of the text
         if(::FileWriteInteger(file_handle,this.m_text_y,INT_VALUE)!=INT_VALUE)
            return false;
      // --- Save the text
         if(::FileWriteArray(file_handle,this.m_text)!=sizeof(this.m_text))
            return false;
            
      // --- Everything is successful
         return true;
    }
   //+------------------------------------------------------------------+
   // | CTableCellView::Loading from file |
   //+------------------------------------------------------------------+
   bool CTableCellView::Load(const int file_handle)
    {
         // --- Loading the data of the parent object
            if(!CBaseObj::Load(file_handle))
               return false;
               
         // --- Load the cell number
            this.m_index=::FileReadInteger(file_handle,INT_VALUE);
         // --- Loading text anchor point
            this.m_text_anchor=(ENUM_ANCHOR_POINT)::FileReadInteger(file_handle,INT_VALUE);
         // --- Load the X coordinate of the text
            this.m_text_x=::FileReadInteger(file_handle,INT_VALUE);
         // --- Load the Y coordinate of the text
            this.m_text_y=::FileReadInteger(file_handle,INT_VALUE);
         // --- Loading text
            if(::FileReadArray(file_handle,this.m_text)!=sizeof(this.m_text))
               return false;
            
         // --- Everything is successful
            return true;
    }
   //+------------------------------------------------------------------+
  #endif // CTABLECELLVIEW_IMPLEMENTATION
#endif // __TABLECELLVIEW_MQH__


