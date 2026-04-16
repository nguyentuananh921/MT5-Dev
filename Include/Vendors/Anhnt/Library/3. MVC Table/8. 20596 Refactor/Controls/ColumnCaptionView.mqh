//+------------------------------------------------------------------+
//|                                          ColumnCaptionView.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in:                                                    |
//|   Integrating the Model Component into the View Component        |
//|                           https://www.mql5.com/en/articles/19288 |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Table column header visual representation class |
//+------------------------------------------------------------------+
#ifndef __COLUMNCAPTIONVIEW_MQH__
#define __COLUMNCAPTIONVIEW_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "CaptionView.mqh"
   #include "..\Tables\ColumnCaption.mqh"
//| Update in: Symbol Correlation Table                              |
//|                           https://www.mql5.com/ru/articles/20596 |
//|         class CColumnCaptionView : public CButton                |   
 class CColumnCaptionView : public CCaptionView
  {
   protected:
      CColumnCaption   *m_column_caption_model;                         // Pointer to column header model
      ENUM_TABLE_SORT_MODE m_sort_mode;                                 // Table column sort mode
      bool              m_sortable;                                     // Sorting control flag
      
   // --- Adds tooltip objects with arrows to the list
      virtual bool      AddHintsArrowed(void);
   // --- Displays resizing cursor
      virtual bool      ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y);
      
   public:
   // --- (1) Assigns, (2) returns the column header model
      bool              ColumnCaptionModelAssign(CColumnCaption *caption_model);
      CColumnCaption   *ColumnCaptionModel(void)                           { return this.m_column_caption_model;        }

   // --- Prints the assigned column header model in the log
      void              ColumnCaptionModelPrint(void);

   // --- (1) Sets, (2) returns the sortable flag
      void              SetSortableFlag(const bool flag)
                        {
                           this.m_sortable=flag;
                           this.SetSortMode(flag ? TABLE_SORT_MODE_ASC : TABLE_SORT_MODE_NONE);
                        }
      bool              IsSortabe(void)                              const { return this.m_sortable;                    }

   // --- (1) Sets, (2) returns the sort mode
      void              SetSortMode(const ENUM_TABLE_SORT_MODE mode)       { this.m_sort_mode=mode;                     }
      ENUM_TABLE_SORT_MODE SortMode(void)                            const { return this.m_sort_mode;                   }
      
   // --- Sets the opposite direction of sorting
      void              SetSortModeReverse(void);
      
   // --- Draws (1) appearance, (2) sort direction arrow
      virtual void      Draw(const bool chart_redraw);
   protected:
      void              DrawSortModeArrow(void);
   public:  
   // --- Right side element resizing handler
      virtual bool      ResizeZoneRightHandler(const int x, const int y);
      
   // --- Handlers for resizing an element by sides and corners
      virtual bool      ResizeZoneLeftHandler(const int x, const int y)       { return false;                           }
      virtual bool      ResizeZoneTopHandler(const int x, const int y)        { return false;                           }
      virtual bool      ResizeZoneBottomHandler(const int x, const int y)     { return false;                           }
      virtual bool      ResizeZoneLeftTopHandler(const int x, const int y)    { return false;                           }
      virtual bool      ResizeZoneRightTopHandler(const int x, const int y)   { return false;                           }
      virtual bool      ResizeZoneLeftBottomHandler(const int x, const int y) { return false;                           }
      virtual bool      ResizeZoneRightBottomHandler(const int x, const int y){ return false;                           }
      
   // --- Changes the width of an object
      virtual bool      ResizeW(const int w);
      
   // --- Event handler for mouse button clicks (Press)
      virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);
      
   // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0)const { return CButton::Compare(node,mode);        }
      virtual bool      Save(const int file_handle);
      virtual bool      Load(const int file_handle);
      virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW);}

   // --- Initialize (1) class object, (2) default object colors
      void              Init(const string text);
      //virtual void      InitColors(void);
      
   // --- Returns a description of the object
      virtual string    Description(void);
      
   // --- Constructors/destructor
                        CColumnCaptionView(void);
                        CColumnCaptionView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h); 
                     ~CColumnCaptionView (void){}
  };
  #ifndef CCOLUMNCAPTIONVIEW_IMPLEMENTATION
  #define CCOLUMNCAPTIONVIEW_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Default constructor. Builds an object |
   // | in the main window of the current chart at coordinates 0,0 |
   // | with default sizes |
   //+------------------------------------------------------------------+
   CColumnCaptionView::CColumnCaptionView(void) : CCaptionView("ColumnCaption","Caption",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H),m_sort_mode(TABLE_SORT_MODE_NONE),m_sortable(true)
    {
   // ---Initialization
      this.Init("Caption");
      this.SetID(0);
      this.SetIndex(-1);
      this.SetName("ColumnCaption");
    }
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::The constructor is parametric.                 |
   // | Plots an object in the specified window of the specified chart with |
   // | specified text, coordinates and dimensions |
   //+------------------------------------------------------------------+
   CColumnCaptionView::CColumnCaptionView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h) :
      CCaptionView(object_name,text,chart_id,wnd,x,y,w,h),m_sort_mode(TABLE_SORT_MODE_NONE),m_sortable(true)
    {
     // ---Initialization
      this.Init(text);
      this.SetID(0);
      this.SetIndex(-1);
    }
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Initializing |
   //+------------------------------------------------------------------+
   void CColumnCaptionView::Init(const string text)
    {
     // --- Initializing the parent object
      CCaptionView::Init(text);
     // --- Can be resized
      this.SetResizable(true);
      this.SetMovable(false);
    }
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Draws the appearance |
   //+------------------------------------------------------------------+
   void CColumnCaptionView::Draw(const bool chart_redraw)
    {
     // --- If the object is outside its container, we leave
      if(this.IsOutOfContainer())
         return;

     // --- Fill the object with the background color, draw a light vertical line on the left, and a dark one on the right
      this.Fill(this.BackColor(),false);
      color clr_dark =this.BorderColor();                                                       // "Dark color"
      color clr_light=this.GetBackColorControl().NewColor(this.BorderColor(), 20, 20, 20);      // "Light color"
      this.m_background.Line(this.AdjX(0),this.AdjY(0),this.AdjX(0),this.AdjY(this.Height()-1),::ColorToARGB(clr_light,this.AlphaBG()));                          // Line on the left
      this.m_background.Line(this.AdjX(this.Width()-1),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(clr_dark,this.AlphaBG())); // Line on the right

     // --- Output title text
      CLabel::Draw(false);
         
     // --- Draw sorting direction arrows
      this.DrawSortModeArrow();

     // --- updating the background canvas
      this.m_background.Update(false);
      
     // --- If indicated, update the schedule
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Draws a sort direction arrow |
   //+------------------------------------------------------------------+
   void CColumnCaptionView::DrawSortModeArrow(void)
    {
     // --- Set the arrow color for the normal and blocked states of the object
      color clr=(!this.IsBlocked() ? this.GetForeColorControl().NewColor(this.ForeColor(),90,90,90) : this.ForeColor());
      switch(this.m_sort_mode)
      {
         // --- Sort in ascending order
         case TABLE_SORT_MODE_ASC   :  
            // --- Clear the drawing area and draw a down arrow
            this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
            this.m_painter.ArrowDown(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
            break;
         // --- Sort in descending order
         case TABLE_SORT_MODE_DESC  :  
            // --- Clear the drawing area and draw an up arrow
            this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
            this.m_painter.ArrowUp(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),clr,this.AlphaFG(),true);
            break;
         // --- No sorting
         default : 
            // --- Clear the drawing area
            this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
            break;
      }
    }
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Expands sort direction |
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
   // | CColumnCaptionView::Returns the description of the object |
   //+------------------------------------------------------------------+
   string CColumnCaptionView::Description(void)
    {
      //--- 1. Get unified base info: "Column Caption View: Name (ID 123)"
      string baseDesc = CBaseObj::Description();
      
      //--- 2. Format Sort Mode string
      string sort = (this.SortMode() == TABLE_SORT_MODE_ASC  ? "ascending" : 
                     this.SortMode() == TABLE_SORT_MODE_DESC ? "descending" : "none");
      
      //--- 3. Combine with area and sort info
      return ::StringFormat("%s, Area: [X %d, Y %d, W %d, H %d], Sort: %s",
                           baseDesc,
                           this.X(), this.Y(), this.Width(), this.Height(),
                           sort);
      //----------------
      // string nm=this.Name();
      // string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
      // string sort=(this.SortMode()==TABLE_SORT_MODE_ASC ? "ascending" : this.SortMode()==TABLE_SORT_MODE_DESC ? "descending" : "none");
      // return ::StringFormat("%s%s ID %d, X %d, Y %d, W %d, H %d, sort %s",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.ID(),this.X(),this.Y(),this.Width(),this.Height(),sort);
    }
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Assigns a column header model |
   //+------------------------------------------------------------------+
   bool CColumnCaptionView::ColumnCaptionModelAssign(CColumnCaption *caption_model)
    {
     // --- If an invalid column header model object is passed, we report this and return false
      if(caption_model==NULL)
      {
         ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
         return false;
      }
     // --- Save the column header model
      this.m_column_caption_model=caption_model;
     // --- Set the dimensions of the drawing area of ​​the visual representation of the column header
      this.m_painter.SetBound(0,0,this.Width(),this.Height());
     // --- Everything is successful
      return true;
    }
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Prints in journal |
   // | assigned column header model |
   //+------------------------------------------------------------------+
   void CColumnCaptionView::ColumnCaptionModelPrint(void)
    {
      if(this.m_column_caption_model!=NULL)
         this.m_column_caption_model.Print();
    }
   
   
   
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Changes the width of an object |
   //+------------------------------------------------------------------+
   bool CColumnCaptionView::ResizeW(const int w)
    {
      if(!CCanvasBase::ResizeW(w))
         return false;
     // --- Clear the drawing area in the previous place
      this.m_painter.Clear(this.AdjX(this.m_painter.X()),this.AdjY(this.m_painter.Y()),this.m_painter.Width(),this.m_painter.Height(),false);
     // --- Set up a new drawing area
      this.SetImageBound(this.Width()-14,4,8,11);
      return true;
    }
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Mouse click event handler |
   //+------------------------------------------------------------------+
   void CColumnCaptionView::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
    {
     // --- If the mouse button is released in the drag area of ​​the right edge of the element, we leave
      if(this.ResizeRegion()==CURSOR_REGION_RIGHT)
         return;
     // --- Change the sorting direction arrow to the opposite one and call the mouse click handler
      if(this.m_sortable)
         this.SetSortModeReverse();
      CCanvasBase::OnPressEvent(id,lparam,dparam,sparam);
      ::EventChartCustom(this.m_chart_id,CHARTEVENT_OBJECT_CLICK,this.ID(),-(10000+this.SortMode()),this.NameFG());
    }
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Saving to file |
   //+------------------------------------------------------------------+
   bool CColumnCaptionView::Save(const int file_handle)
    {
     // --- Save the data of the parent object
      if(!CButton::Save(file_handle))
         return false;

     // --- Save the header number
      if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
         return false;
     // --- Save the sorting direction
      if(::FileWriteInteger(file_handle,this.m_sort_mode,INT_VALUE)!=INT_VALUE)
         return false;
     // --- Save the sorting control flag
      if(::FileWriteInteger(file_handle,this.m_sortable,INT_VALUE)!=INT_VALUE)
         return false;
         
     // --- Everything is successful
      return true;
    }
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Loading from file |
   //+------------------------------------------------------------------+
   bool CColumnCaptionView::Load(const int file_handle)
    {
     // --- Loading the data of the parent object
      if(!CButton::Load(file_handle))
         return false;
         
     // --- Loading the header number
      this.m_index=::FileReadInteger(file_handle,INT_VALUE);
     // --- Loading the sorting direction
      this.m_sort_mode=(ENUM_TABLE_SORT_MODE)::FileReadInteger(file_handle,INT_VALUE);
     // --- Load the sorting control flag
      this.m_sortable=(bool)::FileReadInteger(file_handle,INT_VALUE);
      
     // --- Everything is successful
      return true;
    }
   //+------------------------------------------------------------------+
  #ifndef MOVE_TO_DELIB_MQH
  #define MOVE_TO_DELIB_MQH
   // //+------------------------------------------------------------------+
   // // | CColumnCaptionView::Adds to list |
   // // | tooltip objects with arrows |
   // //+------------------------------------------------------------------+
   // bool CColumnCaptionView::AddHintsArrowed(void)
   //    {
   //    // --- Create a horizontal offset arrow tooltip
   //    CVisualHint *hint=this.CreateAndAddNewHint(HINT_TYPE_ARROW_SHIFT_HORZ,DEF_HINT_NAME_SHIFT_HORZ,18,18);
   //    if(hint==NULL)
   //       return false;

   //    // --- Set the size of the tooltip image area
   //    hint.SetImageBound(0,0,hint.Width(),hint.Height());
      
   //    // --- hide the tooltip and draw the appearance
   //    hint.Hide(false);
   //    hint.Draw(false);
      
   //    // --- Everything is successful
   //    return true;
   //    }
   // //+------------------------------------------------------------------+
   // // | CColumnCaptionView::Displays resizing cursor |
   // //+------------------------------------------------------------------+
   // bool CColumnCaptionView::ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y)
   //  {
   //    CVisualHint *hint=NULL;          // Pointer to tooltip
   //    int hint_shift_x=0;              // Tooltip X offset
   //    int hint_shift_y=0;              // Tooltip Y Offset
      
   //   // --- Depending on the location of the cursor on the borders of the element
   //   // --- indicate the offset of the tooltip relative to the cursor coordinates,
   //   // --- display the required hint on the chart and get a pointer to this object
   //    if(edge!=CURSOR_REGION_RIGHT)
   //       return false;
      
   //    hint_shift_x=-8;
   //    hint_shift_y=-12;
   //    this.ShowHintArrowed(HINT_TYPE_ARROW_SHIFT_HORZ,x+hint_shift_x,y+hint_shift_y);
   //    hint=this.GetHint(DEF_HINT_NAME_SHIFT_HORZ);

   //   // --- Return the result of adjusting the position of the tooltip relative to the cursor
   //    return(hint!=NULL ? hint.Move(x+hint_shift_x,y+hint_shift_y) : false);
   //  }
   // //+------------------------------------------------------------------+
   // // | CColumnCaptionView::Right resizing handler|
   // //+------------------------------------------------------------------+
   // bool CColumnCaptionView::ResizeZoneRightHandler(const int x,const int y)
   //  {
   //   // --- Calculate and set the new width of the element
   //    int width=::fmax(x-this.X()+1,DEF_TABLE_COLUMN_MIN_W);
   //    if(!this.ResizeW(width))
   //       return false;
   //   // --- Get a pointer to a hint
   //    CVisualHint *hint=this.GetHint(DEF_HINT_NAME_SHIFT_HORZ);
   //    if(hint==NULL)
   //       return false;
   //   // --- Shift the tooltip by the specified amounts relative to the cursor
   //    int shift_x=-8;
   //    int shift_y=-12;
      
   //    CTableHeaderView *header=this.m_container;
   //    if(header==NULL)
   //       return false;
      
   //    bool res=header.RecalculateBounds(this.GetBoundNode(),this.Width());
   //    res &=hint.Move(x+shift_x,y+shift_y);
   //    if(res)
   //       ::ChartRedraw(this.m_chart_id);
   //    return res;
   //  }
  #endif // MOVE_TO_DELIB_MQH

  #endif // CCOLUMNCAPTIONVIEW_IMPLEMENTATION
#endif // __COLUMNCAPTIONVIEW_MQH__


