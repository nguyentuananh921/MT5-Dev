//+------------------------------------------------------------------+
//|                                        TableRowsHeaderView.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Class for visual representation of table row headers |
//+------------------------------------------------------------------+

#ifndef __TABLEROWSHEADERVIEW_MQH__
#define __TABLEROWSHEADERVIEW_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "Panel.mqh" 
   #include "RowCaptionView.mqh"
   #include "TableView.mqh"

      
  class CTableRowsHeaderView : public CPanel
    {
      protected:
         CRowCaptionView   m_temp_caption;                                 // Temporary row header object for search
         string            m_table_row_columns[];                          // Array of table row headers

      // --- Creates and adds to the list a new row header view object
         CRowCaptionView *InsertNewRowCaptionView(const string text, const int x, const int y, const int w, const int h);
         
      public:
      // --- (1) Sets an array of table row headers
         bool              TableRowCaptionsAssign(string &captions_array[]);

      // --- Recalculates header areas
         bool              RecalculateBounds(CBound *bound,int new_width);

      // --- Prints the assigned table header model in the log
         void              TableRowHeaderModelPrint(void)                     { ::ArrayPrint(this.m_table_row_columns);       }
         
      // ---Draws the appearance
         virtual void      Draw(const bool chart_redraw);
         
      // --- Gets the row header by index
         CRowCaptionView  *GetRowCaption(const uint index);
         
      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0)const { return CPanel::Compare(node,mode);            }
         virtual bool      Save(const int file_handle)                        { return CPanel::Save(file_handle);             }
         virtual bool      Load(const int file_handle)                        { return CPanel::Load(file_handle);             }
         virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW);  }
         
      // --- Initialize (1) class object, (2) default object colors
         void              Init(void);
         virtual void      InitColors(void);

      // --- Constructors/destructor
                           CTableRowsHeaderView(void);
                           CTableRowsHeaderView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                        ~CTableRowsHeaderView (void){}
    };
  #ifndef CTABLEROWSHEADERVIEW_IMPLEMENTATION
  #define CTABLEROWSHEADERVIEW_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CTableRowsHeaderView::Default constructor. Builds an object in |
   // | main window of the current chart in coordinates 0,0 |
   // | with default sizes |
   //+------------------------------------------------------------------+
   CTableRowsHeaderView::CTableRowsHeaderView(void) : CPanel("TableRowHeader","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H)
    {
     // ---Initialization
      this.Init();
    }
   //+------------------------------------------------------------------+
   // | CTableRowsHeaderView::Parametric constructor. Builds an object |
   // | in the specified window of the specified chart with the specified text, |
   // | coordinates and dimensions |
   //+------------------------------------------------------------------+
   CTableRowsHeaderView::CTableRowsHeaderView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
      CPanel(object_name,text,chart_id,wnd,x,y,w,h)
    {
     // ---Initialization
      this.Init();
    }
   //+------------------------------------------------------------------+
   // | CTableRowsHeaderView::Initializing |
   //+------------------------------------------------------------------+
   void CTableRowsHeaderView::Init(void)
    {
     // --- Initializing the parent object
      CPanel::Init();
     // --- Background color - opaque
      this.SetAlphaBG(255);
     // --- Frame width
      this.SetBorderWidth(1);
    }
   //+------------------------------------------------------------------+
   // | CTableRowsHeaderView::Initializing default object colors |
   //+------------------------------------------------------------------+
   void CTableRowsHeaderView::InitColors(void)
    {
     // --- Initialize the background colors for normal and activated states and make it the current background color
      this.InitBackColors(C'230,230,230',C'230,230,230',C'230,230,230',clrWhiteSmoke);
      this.InitBackColorsAct(C'230,230,230',C'230,230,230',C'230,230,230',clrWhiteSmoke);
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
   // | CTableRowsHeaderView::Creates and adds to the list |
   // | new row header view object |
   //+------------------------------------------------------------------+
   CRowCaptionView *CTableRowsHeaderView::InsertNewRowCaptionView(const string text,const int x,const int y,const int w,const int h)
    {
     // --- Create an object name and return the result of creating a new column header
      string user_name="RowCaptionView"+(string)this.m_list_elm.Total();
      CRowCaptionView *caption_view=this.InsertNewElement(ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW,text,user_name,x,y,w,h);
      return(caption_view!=NULL ? caption_view : NULL);
    }
   //+------------------------------------------------------------------+
   // | CTableRowsHeaderView::Sets the vertical header |
   //+------------------------------------------------------------------+
   bool CTableRowsHeaderView::TableRowCaptionsAssign(string &captions_array[])
    {
     // --- Get a pointer to the table object (View)
      CPanel *obj=this.GetContainer();
      if(obj==NULL)
         return false;
      CTableView *table_view=obj.GetContainer();
      if(table_view==NULL)
         return false;
         
     // --- From the table object we get a pointer to the panel with table rows
      CPanel *table_area=table_view.GetTableArea();
      if(table_area==NULL)
         return false;
      
     // --- Get a list of table rows
      CListElm *list=table_area.GetListAttachedElements();
      int total_rows=list.Total();

     // --- Save the passed array of table row headers
      ::ArrayCopy(this.m_table_row_columns,captions_array);
      int total_captions=(int)this.m_table_row_columns.Size();
     //---
      int total=::fmax(total_rows,total_captions);
     // --- We go through the loop through the number of created headers
      for(int i=0;i<total;i++)
      {
         // --- we get the next line
         CTableRowView *row=table_area.GetAttachedElementAt(i);
         if(row==NULL)
            continue;
         
         // --- calculate the coordinate and create a name for the row header area
         int y=row.Height()*i;
         string name="CaptionBound"+(string)i;
         // --- Create a new row header area
         CBound *caption_bound=this.InsertNewBound(name,0,y,this.Width(),row.Height());
         if(caption_bound==NULL)
            return false;
         caption_bound.SetID(row.ID());
         // --- Define the text for the row header
         // --- If the headers array is smaller than the rows in the table, then the headers will first have the values ​​from the array, and then the row numbers
         // --- If the header array has no size, then all lines will be headed by serial numbers
         string text=(this.m_table_row_columns.Size()>0 ? (i<(int)this.m_table_row_columns.Size() ? this.m_table_row_columns[i] : string(i+1)) : string(i+1));
         // --- Create a new object for visual representation of the row header
         CRowCaptionView *caption_view=this.InsertNewRowCaptionView(text,0,y,this.Width(),row.Height());
         if(caption_view==NULL)
            return false;
         caption_view.SetIndex(i);
         
         // --- We assign the corresponding object for visual representation of the row header to the current area of ​​the row header
         caption_bound.AssignObject(caption_view);
         caption_view.AssignBoundNode(caption_bound);
      }
     // --- Everything is successful
      return true;
    }
   //+------------------------------------------------------------------+
   // | CTableRowsHeaderView::Recalculates header areas |
   //+------------------------------------------------------------------+
   bool CTableRowsHeaderView::RecalculateBounds(CBound *bound,int new_width)
    {
     // --- If an empty area object is passed or its width has not changed, return false
      if(bound==NULL || bound.Width()==new_width)
         return false;
         
     // --- Get the index of the area in the list
      int index=this.m_list_bounds.IndexOf(bound);
      if(index==WRONG_VALUE)
         return false;

     // --- Calculate the offset and, if it is not there, return false
      int delta=new_width-bound.Width();
      if(delta==0)
         return false;

     // --- Change the width of the current area and the object assigned to the area
      bound.ResizeW(new_width);
      CElementBase *assigned_obj=bound.GetAssignedObj();
      if(assigned_obj!=NULL)
         assigned_obj.ResizeW(new_width);

     // --- Get the next area after the current one
      CBound *next_bound=this.m_list_bounds.GetNextNode();
     // --- Recalculate X coordinates for all subsequent areas
      while(!::IsStopped() && next_bound!=NULL)
      {
         // --- Shift the area by delta value
         int new_x = next_bound.X()+delta;
         int prev_width=next_bound.Width();
         next_bound.SetX(new_x);
         next_bound.Resize(prev_width,next_bound.Height());
         
         // --- If there is an assigned object in the area, update its position
         CElementBase *assigned_obj=next_bound.GetAssignedObj();
         if(assigned_obj!=NULL)
         {
            assigned_obj.Move(assigned_obj.X()+delta,assigned_obj.Y());
            
            // --- This code block is part of an effort to troubleshoot artifacts when dragging headers
            CCanvasBase *base_obj=assigned_obj.GetContainer();
            if(base_obj!=NULL)
            {
               if(assigned_obj.X()>base_obj.ContainerLimitRight())
                  assigned_obj.Hide(false);
               else
                  assigned_obj.Show(false);
            }
         }
         // --- Moving on to the next area
         next_bound=this.m_list_bounds.GetNextNode();
      }
      
     // --- Calculate the new width of the table header based on the width of the column headers
      int header_width=0;
      for(int i=0;i<this.m_list_bounds.Total();i++)
      {
         CBound *bound=this.GetBoundAt(i);
         if(bound!=NULL)
            header_width+=bound.Width();
      }

     // --- If the calculated width of the table header differs from the current one, change the width
      if(header_width!=this.Width())
      {
         if(!this.ResizeW(header_width))
            return false;
      }

     // --- Get a pointer to the table object (View)
      CPanel *obj=this.GetContainer();
      if(obj==NULL)
         return false;
      CTableView *table_view=obj.GetContainer();
      if(table_view==NULL)
         return false;

     // --- From the table object we get a pointer to the panel with table rows
      CPanel *table_area=table_view.GetTableArea();
      if(table_area==NULL)
         return false;
      
     // --- Change the size of the table row panel to the overall size of the column headers
      if(!table_area.ResizeW(header_width))
         return false;
      
     // --- Get a list of table rows and loop through all the rows
      CListElm *list=table_area.GetListAttachedElements();
      int total=list.Total();
      for(int i=0;i<total;i++)
      {
         // --- We get the next row of the table
         CTableRowView *row=table_area.GetAttachedElementAt(i);
         if(row!=NULL)
         {
            // --- Change the row size to fit the panel size and recalculate the cell areas
            row.ResizeW(table_area.Width());
            row.RecalculateBounds(&this.m_list_bounds);
         }
      }
     // --- Redraw all table rows
      table_area.Draw(false);
      return true;
    }
   //+------------------------------------------------------------------+
   // | CTableRowsHeaderView::Gets row header by index |
   //+------------------------------------------------------------------+
   CRowCaptionView *CTableRowsHeaderView::GetRowCaption(const uint index)
    {
     // --- Get the row header area by index
      CBound *capt_bound=this.GetBoundAt(index);
      if(capt_bound==NULL)
         return NULL;
     // --- From the row header area, return a pointer to the attached row header object
      return capt_bound.GetAssignedObj();
    }
   //+------------------------------------------------------------------+
   // | CTableRowsHeaderView::Draws the appearance |
   //+------------------------------------------------------------------+
   void CTableRowsHeaderView::Draw(const bool chart_redraw)
    {
     // --- Fill the object with the background color, draw a line line and update the background canvas
      this.Fill(this.BackColor(),false);
      this.m_background.Line(this.AdjX(0),this.AdjY(this.Height()-1),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
      this.m_background.Update(false);
      
     // --- Drawing line headers
      int total=this.m_list_bounds.Total();
      for(int i=0;i<total;i++)
      {
         // --- Get the row header object by loop index
         CRowCaptionView *caption_view=this.GetRowCaption(i);
         // --- Draw a visual representation of the row header
         if(caption_view!=NULL)
         {
            caption_view.Draw(false);
         }
      }
     // --- If indicated, update the schedule
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   #endif // CTABLEROWSHEADERVIEW_IMPLEMENTATION
#endif // __TABLEROWSHEADERVIEW_MQH__


