//+------------------------------------------------------------------+
//|                                            ColumnCaptionView.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+
//| Class representing the visual representation of a table column   |
//| caption                                                          |
//+------------------------------------------------------------------+
#ifndef __COLUMN_CAPTION_VIEW_MQH__
#define __COLUMN_CAPTION_VIEW_MQH__


//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "Button.mqh"
//chain: CButton→Label.mqh→ElementBase.mqh→CanvasBase.mqh→BoundedObj.mqh→BaseObj.mqh→Object.mqh
//enums: ControlEnums.mqh
#include "..\Base\Bound.mqh"
#include "..\Base\BaseEnums.mqh"
#include "..\Table\ColumnCaption.mqh"
#include "..\Controls\TableHeaderView.mqh"
#include "..\Controls\VisualHint.mqh"

class CColumnCaptionView : public CButton
  {
protected:
   CColumnCaption   *m_column_caption_model;                         // Pointer to the column caption model
   CBound           *m_bound_node;                                   // Pointer to the caption area
   int               m_index;                                        // Index in the column list
   ENUM_TABLE_SORT_MODE m_sort_mode;                                 // Table column sorting mode
   
//--- Adds arrow hint objects to the list
   virtual bool      AddHintsArrowed(void);
//--- Displays resize cursor hint
   virtual bool      ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y);
   
public:
//--- Sets identifier
   virtual void      SetID(const int id)                                { this.m_index=this.m_id=id;                 }
//--- (1) Sets, (2) returns cell index
   void              SetIndex(const int index)                          { this.SetID(index);                         }
   int               Index(void)                                  const { return this.m_index;                       }
   
//--- (1) Assigns, (2) returns the caption area assigned to the object
   void              AssignBoundNode(CBound *bound)                     { this.m_bound_node=bound;                   }
   CBound           *GetBoundNode(void)                                 { return this.m_bound_node;                  }

//--- (1) Assigns, (2) returns the column caption model
   bool              ColumnCaptionModelAssign(CColumnCaption *caption_model);
   CColumnCaption   *ColumnCaptionModel(void)                           { return this.m_column_caption_model;        }

//--- Prints the assigned column caption model to the log
   void              ColumnCaptionModelPrint(void);

//--- (1) Sets, (2) returns sorting mode
   void              SetSortMode(const ENUM_TABLE_SORT_MODE mode)       { this.m_sort_mode=mode;                     }
   ENUM_TABLE_SORT_MODE SortMode(void)                            const { return this.m_sort_mode;                   }
   
//--- Sets the opposite sorting direction
   void              SetSortModeReverse(void);
   
//--- Draws (1) appearance, (2) sorting direction arrow
   virtual void      Draw(const bool chart_redraw);
protected:
   void              DrawSortModeArrow(void);
public:  
//--- Handler for resizing the element from the right side
   virtual bool      ResizeZoneRightHandler(const int x, const int y);
   
//--- Handlers for resizing the element by sides and corners
   virtual bool      ResizeZoneLeftHandler(const int x, const int y)       { return false;                           }
   virtual bool      ResizeZoneTopHandler(const int x, const int y)        { return false;                           }
   virtual bool      ResizeZoneBottomHandler(const int x, const int y)     { return false;                           }
   virtual bool      ResizeZoneLeftTopHandler(const int x, const int y)    { return false;                           }
   virtual bool      ResizeZoneRightTopHandler(const int x, const int y)   { return false;                           }
   virtual bool      ResizeZoneLeftBottomHandler(const int x, const int y) { return false;                           }
   virtual bool      ResizeZoneRightBottomHandler(const int x, const int y){ return false;                           }
   
//--- Changes the width of the object
   virtual bool      ResizeW(const int w);
   
//--- Mouse button press event handler
   virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);
   
//--- Virtual methods (1) comparison, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0)const { return CButton::Compare(node,mode);        }
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW);}
  
//--- Initialization (1) class object, (2) default object colors
   void              Init(const string text);
   virtual void      InitColors(void);
   
//--- Returns object description
   virtual string    Description(void);
   
//--- Constructors/destructor
                     CColumnCaptionView(void);
                     CColumnCaptionView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h); 
                    ~CColumnCaptionView(void){}
  };

//+------------------------------------------------------------------+
//| Default constructor. Creates object in the main window of the    |
//| current chart at coordinates 0,0 with default size               |
//+------------------------------------------------------------------+
CColumnCaptionView::CColumnCaptionView(void) :
   CButton("ColumnCaption","Caption",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H),
   m_index(0),
   m_sort_mode(TABLE_SORT_MODE_NONE)
  {
//--- Initialization
   this.Init("Caption");
   this.SetID(0);
   this.SetName("ColumnCaption");
  }

//+------------------------------------------------------------------+
//| Parameterized constructor. Creates object in the specified       |
//| chart window with specified text, coordinates and size           |
//+------------------------------------------------------------------+
CColumnCaptionView::CColumnCaptionView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CButton(object_name,text,chart_id,wnd,x,y,w,h),
   m_index(0),
   m_sort_mode(TABLE_SORT_MODE_NONE)
  {
//--- Initialization
   this.Init(text);
   this.SetID(0);
  }

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void CColumnCaptionView::Init(const string text)
  {
//--- Default text offsets
   this.m_text_x=4;
   this.m_text_y=2;

//--- Set colors for different states
   this.InitColors();

//--- Enable resizing
   this.SetResizable(true);
   this.SetMovable(false);
   this.SetImageBound(this.ObjectWidth()-14,4,8,11);
  }

//+------------------------------------------------------------------+
//| Initialize default object colors                                 |
//+------------------------------------------------------------------+
void CColumnCaptionView::InitColors(void)
  {
//--- Initialize background colors for normal and active states and set default
   this.InitBackColors(clrWhiteSmoke,this.GetBackColorControl().NewColor(clrWhiteSmoke,-6,-6,-6),clrWhiteSmoke,clrWhiteSmoke);
   this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.BackColorToDefault();
   
//--- Initialize foreground (text) colors
   this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   this.ForeColorToDefault();
   
//--- Initialize border colors
   this.InitBorderColors(clrLightGray,clrLightGray,clrLightGray,clrLightGray);
   this.InitBorderColorsAct(clrLightGray,clrLightGray,clrLightGray,clrLightGray);
   this.BorderColorToDefault();
   
//--- Initialize colors for blocked element
   this.InitBorderColorBlocked(clrNULL);
   this.InitForeColorBlocked(clrSilver);
  }
//+------------------------------------------------------------------+
//| CColumnCaptionView::Renders the visual appearance                |
//+------------------------------------------------------------------+
void CColumnCaptionView::Draw(const bool chart_redraw)
  {
//--- If the object is outside its container - exit
   if(this.IsOutOfContainer())
      return;

//--- Fill the object with background color, draw a light vertical line on the left and a dark one on the right
   this.Fill(this.BackColor(),false);
   color clr_dark =this.BorderColor();                                                                    // "Dark color"
   color clr_light=this.GetBackColorControl().NewColor(this.BorderColor(), 100, 100, 100);    // "Light color"
   this.m_background.Line(this.AdjX(0),this.AdjY(0),this.AdjX(0),this.AdjY(this.Height()-1),::ColorToARGB(clr_light,this.AlphaBG()));                          // Left line
   this.m_background.Line(this.AdjX(this.Width()-1),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(clr_dark,this.AlphaBG())); // Right line
//--- Update background canvas
   this.m_background.Update(false);
   
//--- Output the caption text
   CLabel::Draw(false);
      
//--- Draw sorting direction arrows
   this.DrawSortModeArrow();

//--- Update the chart if specified
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }

//+------------------------------------------------------------------+
//| CColumnCaptionView::Draws the sorting direction arrow            |
//+------------------------------------------------------------------+
void CColumnCaptionView::DrawSortModeArrow(void)
  {
//--- Set arrow color for normal and blocked states
   color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
   switch(this.m_sort_mode)
     {
      //--- Ascending sort
      case TABLE_SORT_MODE_ASC   :  
         //--- Clear drawing area and draw a down arrow
         this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
         this.m_painter.ArrowDown(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
         break;
      //--- Descending sort
      case TABLE_SORT_MODE_DESC  :  
         //--- Clear drawing area and draw an up arrow
         this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
         this.m_painter.ArrowUp(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
         break;
      //--- No sorting
      default : 
         //--- Clear drawing area
         this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
         break;
     }
  }

//+------------------------------------------------------------------+
//| CColumnCaptionView::Reverses the sorting direction               |
//+------------------------------------------------------------------+
void CColumnCaptionView::SetSortModeReverse(void)
  {
   switch(this.m_sort_mode)
     {
      case TABLE_SORT_MODE_ASC   :  this.m_sort_mode=TABLE_SORT_MODE_DESC; break;
      case TABLE_SORT_MODE_DESC  :  this.m_sort_mode=TABLE_SORT_MODE_ASC;  break;
      default                    :  break;
     }
  }

//+------------------------------------------------------------------+
//| CColumnCaptionView::Returns object description                   |
//+------------------------------------------------------------------+
string CColumnCaptionView::Description(void)
  {
   string nm=this.Name();
   string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   string sort=(this.SortMode()==TABLE_SORT_MODE_ASC ? "ascending" : this.SortMode()==TABLE_SORT_MODE_DESC ? "descending" : "none");
   return ::StringFormat("%s%s ID %d, X %d, Y %d, W %d, H %d, sort %s",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.ID(),this.X(),this.Y(),this.Width(),this.Height(),sort);
  }

//+------------------------------------------------------------------+
//| CColumnCaptionView::Assigns the column caption model             |
//+------------------------------------------------------------------+
bool CColumnCaptionView::ColumnCaptionModelAssign(CColumnCaption *caption_model)
  {
//--- If an invalid model object is passed - report and return false
   if(caption_model==NULL)
     {
      ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
      return false;
     }
//--- Save the column caption model
   this.m_column_caption_model=caption_model;
//--- Set drawing area dimensions for the visual representation
   this.m_painter.SetBound(0,0,this.Width(),this.Height());
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| CColumnCaptionView::Prints the assigned model to the journal     |
//+------------------------------------------------------------------+
void CColumnCaptionView::ColumnCaptionModelPrint(void)
  {
   if(this.m_column_caption_model!=NULL)
      this.m_column_caption_model.Print();
  }

//+------------------------------------------------------------------+
//| CColumnCaptionView::Adds arrowed hint objects to the list        |
//+------------------------------------------------------------------+
bool CColumnCaptionView::AddHintsArrowed(void)
  {
//--- Create a horizontal shift arrow hint
   CVisualHint *hint=this.CreateAndAddNewHint(HINT_TYPE_ARROW_SHIFT_HORZ,DEF_HINT_NAME_SHIFT_HORZ,18,18);
   if(hint==NULL)
      return false;

//--- Set the hint's image area size
   hint.SetImageBound(0,0,hint.Width(),hint.Height());
   
//--- Hide hint and draw visual appearance
   hint.Hide(false);
   hint.Draw(false);
   
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| CColumnCaptionView::Displays the resize cursor hint              |
//+------------------------------------------------------------------+
bool CColumnCaptionView::ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y)
  {
   CVisualHint *hint=NULL;          // Hint pointer
   int hint_shift_x=0;              // Hint X offset
   int hint_shift_y=0;              // Hint Y offset
   
//--- Depending on cursor location at element edges,
//--- specify hint offsets relative to cursor coordinates,
//--- display required hint on chart and get pointer to the object
   if(edge!=CURSOR_REGION_RIGHT)
      return false;
   
   hint_shift_x=-8;
   hint_shift_y=-12;
   this.ShowHintArrowed(HINT_TYPE_ARROW_SHIFT_HORZ,x+hint_shift_x,y+hint_shift_y);
   hint=this.GetHint(DEF_HINT_NAME_SHIFT_HORZ);

//--- Return the result of adjusting hint position relative to the cursor
   return(hint!=NULL ? hint.Move(x+hint_shift_x,y+hint_shift_y) : false);
  }

//+------------------------------------------------------------------+
//| CColumnCaptionView::Handler for resizing by the right edge       |
//+------------------------------------------------------------------+
bool CColumnCaptionView::ResizeZoneRightHandler(const int x,const int y)
  {
//--- Calculate and set new element width
   int width=::fmax(x-this.X()+1,DEF_TABLE_COLUMN_MIN_W);
   if(!this.ResizeW(width))
      return false;
//--- Get pointer to the hint
   CVisualHint *hint=this.GetHint(DEF_HINT_NAME_SHIFT_HORZ);
   if(hint==NULL)
      return false;
//--- Shift hint by specified values relative to the cursor
   int shift_x=-8;
   int shift_y=-12;
   
   CTableHeaderView *header=this.m_container;
   if(header==NULL)
      return false;
   
   bool res=header.RecalculateBounds(this.GetBoundNode(),this.Width());
   res &=hint.Move(x+shift_x,y+shift_y);
   if(res)
      ::ChartRedraw(this.m_chart_id);
   return res;
  }

//+------------------------------------------------------------------+
//| CColumnCaptionView::Changes the object width                     |
//+------------------------------------------------------------------+
bool CColumnCaptionView::ResizeW(const int w)
  {
   if(!CCanvasBase::ResizeW(w))
      return false;
//--- Clear drawing area at the old location
   this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
//--- Set new drawing area
   this.SetImageBound(this.Width()-14,4,8,11);
   return true;
  }

//+------------------------------------------------------------------+
//| CColumnCaptionView::Mouse button press event handler             |
//+------------------------------------------------------------------+
void CColumnCaptionView::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
//--- If mouse button released in the right-edge dragging area - exit
   if(this.ResizeRegion()==CURSOR_REGION_RIGHT)
      return;
//--- Reverse sorting direction arrow and call mouse click handler
   this.SetSortModeReverse();
   CCanvasBase::OnPressEvent(id,lparam,dparam,sparam);
  }

//+------------------------------------------------------------------+
//| CColumnCaptionView::Save to file                                 |
//+------------------------------------------------------------------+
bool CColumnCaptionView::Save(const int file_handle)
  {
//--- Save parent object data
   if(!CButton::Save(file_handle))
      return false;
  
//--- Save caption index
   if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
      return false;
//--- Save sorting direction
   if(::FileWriteInteger(file_handle,this.m_sort_mode,INT_VALUE)!=INT_VALUE)
      return false;
      
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| CColumnCaptionView::Load from file                               |
//+------------------------------------------------------------------+
bool CColumnCaptionView::Load(const int file_handle)
  {
//--- Load parent object data
   if(!CButton::Load(file_handle))
      return false;
      
//--- Load caption index
   this.m_id=this.m_index=::FileReadInteger(file_handle,INT_VALUE);
//--- Load sorting direction
   this.m_id=this.m_sort_mode=(ENUM_TABLE_SORT_MODE)::FileReadInteger(file_handle,INT_VALUE);
   
//--- Success
   return true;
  }
#endif