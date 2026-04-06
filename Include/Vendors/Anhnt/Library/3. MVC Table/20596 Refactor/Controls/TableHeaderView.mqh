//+------------------------------------------------------------------+
//|                                            TableHeaderView.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Table header visual class |
//+------------------------------------------------------------------+

#ifndef __TABLEHEADERVIEW_MQH__
#define __TABLEHEADERVIEW_MQH__ 
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "Panel.mqh"
   class CTableHeader;     
  class CTableHeaderView : public CPanel
   {
    protected:
      CColumnCaptionView m_temp_caption;                                // Temporary column header object to search
      CTableHeader     *m_table_header_model;                           // Pointer to table header model
      bool              m_sortable;                                     // Sorting control flag

     // --- Creates and adds a new column header view object to the list
      CColumnCaptionView *InsertNewColumnCaptionView(const string text, const int x, const int y, const int w, const int h);
      
    public:
     // --- (1) Sets, (2) returns the table header model
      bool              TableHeaderModelAssign(CTableHeader *header_model);
      CTableHeader     *GetTableHeaderModel(void)                          { return this.m_table_header_model;       }

     // --- Recalculates header areas
      bool              RecalculateBounds(CBound *bound,int new_width);

     // --- Prints the assigned table header model in the log
      void              TableHeaderModelPrint(const bool detail, const bool as_table=false, const int cell_width=CELL_WIDTH_IN_CHARS);
      
     // ---Draws the appearance
      virtual void      Draw(const bool chart_redraw);

     // --- (1) Sets, (2) returns the sortable flag
      void              SetSortableFlag(const bool flag);
      bool              IsSortabe(void)                              const { return this.m_sortable;                 }

     // --- Sets the column header sorting flag
      void              SetSortedColumnCaption(const uint index);

     // --- Gets the column header (1) by index, (2) with sort flag
      CColumnCaptionView *GetColumnCaption(const uint index);
      CColumnCaptionView *GetSortedColumnCaption(void);
     // --- Returns the index of the column header with the sort flag
      int               IndexSortedColumnCaption(void);
      
     // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0)const { return CPanel::Compare(node,mode);      }
      virtual bool      Save(const int file_handle)                        { return CPanel::Save(file_handle);       }
      virtual bool      Load(const int file_handle)                        { return CPanel::Load(file_handle);       }
      virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_HEADER_VIEW); }
      
     // --- Handler for a custom element event when an object area is clicked
      virtual void      MousePressHandler(const int id, const long lparam, const double dparam, const string sparam);

     // --- Initialize (1) class object, (2) default object colors
      void              Init(void);
      virtual void      InitColors(void);

     // --- Constructors/destructor
                        CTableHeaderView(void);
                        CTableHeaderView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                     ~CTableHeaderView (void){}
   };
  #ifndef CTABLEHEADERVIEW_IMPLEMENTATION
  #define CTABLEHEADERVIEW_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CTableHeaderView::Default constructor. Builds an object in |
   // | main window of the current chart in coordinates 0,0 |
   // | with default sizes |
   //+------------------------------------------------------------------+
   CTableHeaderView::CTableHeaderView(void) : CPanel("TableHeader","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H),m_sortable(true)
    {
     // ---Initialization
      this.Init();
    }
   //+------------------------------------------------------------------+
   // | CTableHeaderView::Parametric constructor. Builds an object in |
   // | the specified window of the specified chart with the specified text, |
   // | coordinates and dimensions |
   //+------------------------------------------------------------------+
   CTableHeaderView::CTableHeaderView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
      CPanel(object_name,text,chart_id,wnd,x,y,w,h),m_sortable(true)
    {
     // ---Initialization
      this.Init();
    }
   //+------------------------------------------------------------------+
   // | CTableHeaderView::Initializing |
   //+------------------------------------------------------------------+
   void CTableHeaderView::Init(void)
    {
     // --- Initializing the parent object
      CPanel::Init();
     // --- Background color - opaque
      this.SetAlphaBG(255);
     // --- Frame width
      this.SetBorderWidth(1);
    }
   //+------------------------------------------------------------------+
   // | CTableHeaderView::Initializing default object colors |
   //+------------------------------------------------------------------+
   void CTableHeaderView::InitColors(void)
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
   // | CTableHeaderView::Creates and adds to the list |
   // | new column header view object |
   //+------------------------------------------------------------------+
   CColumnCaptionView *CTableHeaderView::InsertNewColumnCaptionView(const string text,const int x,const int y,const int w,const int h)
    {
     // --- Create an object name and return the result of creating a new column header
      string user_name="ColumnCaptionView"+(string)this.m_list_elm.Total();
      CColumnCaptionView *caption_view=this.InsertNewElement(ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW,text,user_name,x,y,w,h);
      return(caption_view!=NULL ? caption_view : NULL);
    }
   //+------------------------------------------------------------------+
   // | CTableHeaderView::Sets the header model |
   //+------------------------------------------------------------------+
   bool CTableHeaderView::TableHeaderModelAssign(CTableHeader *header_model)
    {
     // --- If an empty object is passed, we report this and return false
      if(header_model==NULL)
      {
         ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
         return false;
      }
     // --- If the passed header model does not have a single column header, report this and return false
      int total=(int)header_model.ColumnsTotal();
      if(total==0)
      {
         ::PrintFormat("%s: Error. Header model does not contain any columns",__FUNCTION__);
         return false;
      }
     // --- We save a pointer to the passed table header model and calculate the width of each column header
      this.m_table_header_model=header_model;
      int caption_w=(int)::fmax(::round((double)this.Width()/(double)total),DEF_TABLE_COLUMN_MIN_W);

     // --- Loop through the number of column headers in the table header model
      for(int i=0;i<total;i++)
      {
         // --- we get the model of the next column header,
         CColumnCaption *caption_model=this.m_table_header_model.GetColumnCaption(i);
         if(caption_model==NULL)
            return false;
         // --- calculate the coordinate and create a name for the column header area
         int x=caption_w*i;
         string name="CaptionBound"+(string)i;
         // --- Create a new column header area
         CBound *caption_bound=this.InsertNewBound(name,x,0,caption_w,this.Height());
         if(caption_bound==NULL)
            return false;
         caption_bound.SetID(i);
         // --- Create a new object for visual representation of the column header
         CColumnCaptionView *caption_view=this.InsertNewColumnCaptionView(caption_model.Value(),x,0,caption_w,this.Height());
         if(caption_view==NULL)
            return false;
         caption_view.SetIndex(i);
         
         // --- Assign the corresponding object for visual representation of the column header to the current area of ​​the column header
         caption_bound.AssignObject(caption_view);
         caption_view.AssignBoundNode(caption_bound);
         
         // --- For the very first heading, set the sort flag in ascending order
         if(i==0 && caption_view.IsSortabe())
            caption_view.SetSortMode(TABLE_SORT_MODE_ASC);
      }
     // --- Everything is successful
      return true;
    }
   //+------------------------------------------------------------------+
   // | CTableHeaderView::Recalculates header areas |
   //+------------------------------------------------------------------+
   bool CTableHeaderView::RecalculateBounds(CBound *bound,int new_width)
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
   // | CTableHeaderView::Draws the appearance |
   //+------------------------------------------------------------------+
   void CTableHeaderView::Draw(const bool chart_redraw)
    {
     // --- Fill the object with the background color, draw a line line and update the background canvas
      this.Fill(this.BackColor(),false);
      this.m_background.Line(this.AdjX(0),this.AdjY(this.Height()-1),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
      this.m_background.Update(false);
      
     // --- Draw column headers
      int total=this.m_list_bounds.Total();
      for(int i=0;i<total;i++)
      {
         // --- Getting the area of ​​the next column header
         CBound *cell_bound=this.GetBoundAt(i);
         if(cell_bound==NULL)
            continue;
         
         // --- From the column header area we get the attached column header object
         CColumnCaptionView *caption_view=cell_bound.GetAssignedObj();
         // --- Draw a visual representation of the column header
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
   // | CTableHeaderView::Sets the sortable flag |
   //+------------------------------------------------------------------+
   void CTableHeaderView::SetSortableFlag(const bool flag)
    {
     // --- Write down the flag value
      this.m_sortable=flag;
      
     // --- In a loop by the number of column headers
      int total=this.m_list_bounds.Total();
      for(int i=0;i<total;i++)
      {
         // --- get the next column header object and set the sorting flag for it
         CColumnCaptionView *caption_view=this.GetColumnCaption(i);
         if(caption_view!=NULL)
            caption_view.SetSortableFlag(flag);
      }
     // --- If the table is being sorted, set the zero column sorted in ascending order
      if(this.m_sortable)
         this.SetSortedColumnCaption(0);

     // --- Redraw the title
      this.Draw(true);
    }
   //+------------------------------------------------------------------+
   // | CTableHeaderView::Sets the column header sort flag|
   //+------------------------------------------------------------------+
   void CTableHeaderView::SetSortedColumnCaption(const uint index)
    {
      int total=this.m_list_bounds.Total();
      for(int i=0;i<total;i++)
      {
         // --- Getting the next column header object
         CColumnCaptionView *caption_view=this.GetColumnCaption(i);
         if(caption_view==NULL)
            continue;
         
         // --- If the loop index is equal to the required index, set the sorting flag in ascending order
         if(i==index)
         {
            caption_view.SetSortMode(TABLE_SORT_MODE_ASC);
            caption_view.Draw(false);
         }
         // --- Otherwise, reset the sorting flag
         else
         {
            caption_view.SetSortMode(TABLE_SORT_MODE_NONE);
            caption_view.Draw(false);
         }
      }
     // --- Redraw the title
      this.Draw(true);
    }
   //+------------------------------------------------------------------+
   // | CTableHeaderView::Gets column header by index |
   //+------------------------------------------------------------------+
   CColumnCaptionView *CTableHeaderView::GetColumnCaption(const uint index)
    {
     // --- Get the column header area by index
      CBound *capt_bound=this.GetBoundAt(index);
      if(capt_bound==NULL)
         return NULL;
     // --- From the column header area, return a pointer to the attached column header object
      return capt_bound.GetAssignedObj();
    }
   //+------------------------------------------------------------------+
   // | CTableHeaderView::Gets the column header with the sort flag |
   //+------------------------------------------------------------------+
   CColumnCaptionView *CTableHeaderView::GetSortedColumnCaption(void)
    {
      int total=this.m_list_bounds.Total();
      for(int i=0;i<total;i++)
      {
         // --- We get the area of ​​the next column header and
         // --- from it we get the attached column header object
         CColumnCaptionView *caption_view=this.GetColumnCaption(i);
         
         // --- If an object is received and its sorting flag is set, return a pointer to it
         if(caption_view!=NULL && caption_view.SortMode()!=TABLE_SORT_MODE_NONE)
            return caption_view;
      }
      return NULL;
    }
   //+------------------------------------------------------------------+
   // | CTableHeaderView::Returns the index of the sorted column |
   //+------------------------------------------------------------------+
   int CTableHeaderView::IndexSortedColumnCaption(void)
    {
      int total=this.m_list_bounds.Total();
      for(int i=0;i<total;i++)
      {
         // --- We get the area of ​​the next column header and
         // --- from it we get the attached column header object
         CColumnCaptionView *caption_view=this.GetColumnCaption(i);
      
         // --- If the object is received and its sorting flag is set, return the area index
         if(caption_view!=NULL && caption_view.SortMode()!=TABLE_SORT_MODE_NONE)
            return i;
      }
      return WRONG_VALUE;
    }
   //+------------------------------------------------------------------+
   // | CTableHeaderView::Prints to log |
   // | designated table header model |
   //+------------------------------------------------------------------+
   void CTableHeaderView::TableHeaderModelPrint(const bool detail,const bool as_table=false,const int cell_width=CELL_WIDTH_IN_CHARS)
    {
      if(this.m_table_header_model!=NULL)
         this.m_table_header_model.Print(detail,as_table,cell_width);
    }
   //+------------------------------------------------------------------+
   // | CTableHeaderView::Element Custom Event Handler |
   // | when clicking on an area of ​​an object |
   //+------------------------------------------------------------------+
   void CTableHeaderView::MousePressHandler(const int id,const long lparam,const double dparam,const string sparam)
    {
     // --- Get the name of the table header object from sparam
      int len=::StringLen(this.NameFG());
      string header_str=::StringSubstr(sparam,0,len);
     // --- If the extracted name does not match the name of this object - not our event, leave
      if(header_str!=this.NameFG())
         return;
      
     // --- Let's find the index of the column header in sparam
      string capt_str=::StringSubstr(sparam,len+1);
      string index_str=::StringSubstr(capt_str,6,capt_str.Length()-8);
      
     // --- First character before "FG" (last digit of search index)
      int pos=(int)capt_str.Length()-3;
      int end=pos;
      
     // --- We are looking for all the numbers on the left up to the first “non-digit”
      while(!::IsStopped() && pos>=0 && capt_str.GetChar(pos)>='0' && capt_str.GetChar(pos)<='9')
         pos--;

     // --- Start of digits of the searched index
      int start=pos+1;
     // --- If the index numbers are not found, we leave
      if(start>end)
         return;

     // --- Get index from string
      index_str=StringSubstr(capt_str,start,end-start+1);

     // --- Write the index of the column header
      int index=(int)::StringToInteger(index_str);
      
     // --- Get the column header by index
      CColumnCaptionView *caption=this.GetColumnCaption(index);
      if(caption==NULL)
         return;
      
     // --- If the title does not have a sorting flag, set the sorting flag in ascending order
      if(caption.IsSortabe() && caption.SortMode()==TABLE_SORT_MODE_NONE)
      {
         this.SetSortedColumnCaption(index);
      }
     // --- Send a custom event to the chart with the title index in lparam, sort mode in dparam and object name in sparam
     // --- Since the standard OBJECT_CLICK event sends cursor coordinates to lparam and dparam, we will pass negative values ​​here
      ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_OBJECT_CLICK, -(10000+index), -(10000+caption.SortMode()), this.NameFG());
      ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
  #endif // CTABLEHEADERVIEW_IMPLEMENTATION
#endif // __TABLEHEADERVIEW_MQH__


