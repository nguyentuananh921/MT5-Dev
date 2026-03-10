//+------------------------------------------------------------------+
//|                                              TableHeaderView.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+
//| Class representing the visual representation of a table header   |
//+------------------------------------------------------------------+
#ifndef __TABLE_HEADER_VIEW_MQH__
#define __TABLE_HEADER_VIEW_MQH__

//+------------------------------------------------------------------+
//| Forward declarations                                             |
//+------------------------------------------------------------------+
class CTableHeader;
class CColumnCaption;
class CTableView;
//+------------------------------------------------------------------+
//| Include standard library                                         |
//+------------------------------------------------------------------+
#include <Object.mqh>

//+------------------------------------------------------------------+
//| Include GUI base classes                                         |
//+------------------------------------------------------------------+
#include "Panel.mqh"
#include "ColumnCaptionView.mqh"

#include "../Base/CanvasBase.mqh"
#include "ElementBase.mqh"
#include "..\Base\Bound.mqh"
#include "ListElm.mqh"
#include "TableRowView.mqh"

#include "..\Table\TableDefines.mqh"
#include "..\Table\TableEnums.mqh"



class CTableHeaderView : public CPanel
  {
protected:
   CColumnCaptionView m_temp_caption;                                // Temporary column caption object for search
   CTableHeader     *m_table_header_model;                           // Pointer to the table header model

//--- Creates and adds a new column caption view object to the list
   CColumnCaptionView *InsertNewColumnCaptionView(const string text,const int x,const int y,const int w,const int h);
   
public:
//--- (1) Sets, (2) returns the table header model
   bool              TableHeaderModelAssign(CTableHeader *header_model);
   CTableHeader     *GetTableHeaderModel(void)                          { return this.m_table_header_model;    }

//--- Recalculates caption bounds
   bool              RecalculateBounds(CBound *bound,int new_width);

//--- Prints the assigned table header model to the log
   void              TableHeaderModelPrint(const bool detail,const bool as_table=false,const int cell_width=CELL_WIDTH_IN_CHARS);
   
//--- Draws the visual appearance
   virtual void      Draw(const bool chart_redraw);
   
//--- Sets the sorting flag for a column caption
   void              SetSortedColumnCaption(const uint index);

//--- Gets column caption (1) by index, (2) with sorting flag
   CColumnCaptionView *GetColumnCaption(const uint index);
   CColumnCaptionView *GetSortedColumnCaption(void);
//--- Returns the index of the sorted column caption
   int               IndexSortedColumnCaption(void);
   
//--- Virtual methods (1) comparison, (2) save to file, (3) load from file, (4) object type
   virtual int       Compare(const CObject *node,const int mode=0)const { return CPanel::Compare(node,mode);      }
   virtual bool      Save(const int file_handle)                        { return CPanel::Save(file_handle);       }
   virtual bool      Load(const int file_handle)                        { return CPanel::Load(file_handle);       }
   virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_HEADER_VIEW); }
   
//--- Handler for custom element event when clicking inside the object area
   virtual void      MousePressHandler(const int id,const long lparam,const double dparam,const string sparam);
  
//--- Initialization (1) class object, (2) default object colors
   void              Init(void);
   virtual void      InitColors(void);

//--- Constructors/destructor
                     CTableHeaderView(void);
                     CTableHeaderView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
                    ~CTableHeaderView(void){}
  };

//+------------------------------------------------------------------+
//| CTableHeaderView::Default constructor. Creates the object in the |
//| main window of the current chart at coordinates 0,0              |
//| with default size                                                |
//+------------------------------------------------------------------+
CTableHeaderView::CTableHeaderView(void) :
   CPanel("TableHeader","",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H)
  {
//--- Initialization
   this.Init();
  }

//+------------------------------------------------------------------+
//| CTableHeaderView::Parameterized constructor. Creates the object  |
//| in the specified window of the specified chart with given text,  |
//| coordinates and size                                             |
//+------------------------------------------------------------------+
CTableHeaderView::CTableHeaderView(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
   CPanel(object_name,text,chart_id,wnd,x,y,w,h)
  {
//--- Initialization
   this.Init();
  }

//+------------------------------------------------------------------+
//| CTableHeaderView::Initialization                                 |
//+------------------------------------------------------------------+
void CTableHeaderView::Init(void)
  {
//--- Initialize parent object
   CPanel::Init();

//--- Background color is opaque
   this.SetAlphaBG(255);

//--- Border width
   this.SetBorderWidth(1);
  }

//+------------------------------------------------------------------+
//| CTableHeaderView::Initialize default object colors               |
//+------------------------------------------------------------------+
void CTableHeaderView::InitColors(void)
  {
//--- Initialize background colors for normal and active states and set as current background color
   this.InitBackColors(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.InitBackColorsAct(clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke,clrWhiteSmoke);
   this.BackColorToDefault();
   
//--- Initialize foreground colors for normal and active states and set as current text color
   this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
   this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
   this.ForeColorToDefault();
   
//--- Initialize border colors for normal and active states and set as current border color
   this.InitBorderColors(C'200,200,200',C'200,200,200',C'200,200,200',clrSilver);
   this.InitBorderColorsAct(C'200,200,200',C'200,200,200',C'200,200,200',clrSilver);
   this.BorderColorToDefault();
   
//--- Initialize border and foreground colors for blocked element
   this.InitBorderColorBlocked(clrSilver);
   this.InitForeColorBlocked(clrSilver);
  }

//+------------------------------------------------------------------+
//| Creates and adds a new column caption view object                |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CTableHeaderView::Creates and adds a new column caption view      |
//+------------------------------------------------------------------+
CColumnCaptionView *CTableHeaderView::InsertNewColumnCaptionView(const string text,const int x,const int y,const int w,const int h)
  {
//--- Create object name and return result of creating a new column caption
   string user_name="ColumnCaptionView"+(string)this.m_list_elm.Total();
   CColumnCaptionView *caption_view=this.InsertNewElement(ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW,text,user_name,x,y,w,h);
   return(caption_view!=NULL ? caption_view : NULL);
  }

//+------------------------------------------------------------------+
//| CTableHeaderView::Assigns the header model                       |
//+------------------------------------------------------------------+
bool CTableHeaderView::TableHeaderModelAssign(CTableHeader *header_model)
  {
//--- If an empty object is passed, report and return false
   if(header_model==NULL)
     {
      ::PrintFormat("%s: Error. Empty object passed",__FUNCTION__);
      return false;
     }
//--- If the header model contains no columns, report and return false
   int total=(int)header_model.ColumnsTotal();
   if(total==0)
     {
      ::PrintFormat("%s: Error. Header model does not contain any columns",__FUNCTION__);
      return false;
     }
//--- Save pointer to header model and calculate default width for each column caption
   this.m_table_header_model=header_model;
   int caption_w=(int)::fmax(::round((double)this.Width()/(double)total),DEF_TABLE_COLUMN_MIN_W);

//--- Loop through the number of column captions in the table header model
   for(int i=0;i<total;i++)
     {
      //--- Get model for current column caption
      CColumnCaption *caption_model=this.m_table_header_model.GetColumnCaption(i);
      if(caption_model==NULL)
          return false;
      //--- Calculate coordinate and create name for the caption bound
      int x=caption_w*i;
      string name="CaptionBound"+(string)i;
      //--- Create new column caption bound
      CBound *caption_bound=this.InsertNewBound(name,x,0,caption_w,this.Height());
      if(caption_bound==NULL)
          return false;
      caption_bound.SetID(i);
      //--- Create new column caption visual representation object
      CColumnCaptionView *caption_view=this.InsertNewColumnCaptionView(caption_model.Value(),x,0,caption_w,this.Height());
      if(caption_view==NULL)
          return false;
          
      //--- Assign the visual representation object to the current caption bound
      caption_bound.AssignObject(caption_view);
      caption_view.AssignBoundNode(caption_bound);
      
      //--- Set ascending sort flag for the very first caption by default
      if(i==0)
          caption_view.SetSortMode(TABLE_SORT_MODE_ASC);
     }
//--- Success
   return true;
  }

//+------------------------------------------------------------------+
//| CTableHeaderView::Recalculates header bounds and column widths    |
//+------------------------------------------------------------------+
bool CTableHeaderView::RecalculateBounds(CBound *bound,int new_width)
  {
//--- If empty bound or width hasn't changed, return false
   if(bound==NULL || bound.Width()==new_width)
      return false;
      
//--- Get the index of the bound in the list
   int index=this.m_list_bounds.IndexOf(bound);
   if(index==WRONG_VALUE)
      return false;

//--- Calculate the width difference (delta)
   int delta=new_width-bound.Width();
   if(delta==0)
      return false;

//--- Resize the current bound and its assigned visual object
   bound.ResizeW(new_width);
   CElementBase *assigned_obj=bound.GetAssignedObj();
   if(assigned_obj!=NULL)
      assigned_obj.ResizeW(new_width);

//--- Get the next bound in the list
   CBound *next_bound=this.m_list_bounds.GetNextNode();
//--- Recalculate X coordinates for all subsequent bounds
   while(!::IsStopped() && next_bound!=NULL)
     {
      //--- Shift the bound by the delta value
      int new_x = next_bound.X()+delta;
      int prev_width=next_bound.Width();
      next_bound.SetX(new_x);
      next_bound.Resize(prev_width,next_bound.Height());
      
      //--- Update position of the assigned object if it exists
      CElementBase *assigned_obj=next_bound.GetAssignedObj();
      if(assigned_obj!=NULL)
        {
         assigned_obj.Move(assigned_obj.X()+delta,assigned_obj.Y());
         
         //--- Artifact prevention: hide objects that move outside container limits
         CCanvasBase *base_obj=assigned_obj.GetContainer();
         if(base_obj!=NULL)
           {
            if(assigned_obj.X()>base_obj.ContainerLimitRight())
                assigned_obj.Hide(false);
            else
                assigned_obj.Show(false);
           }
        }
      //--- Move to next bound
      next_bound=this.m_list_bounds.GetNextNode();
     }
      
//--- Calculate new total header width based on column widths
   int header_width=0;
   for(int i=0;i<this.m_list_bounds.Total();i++)
     {
      CBound *bound=this.GetBoundAt(i);
      if(bound!=NULL)
          header_width+=bound.Width();
     }

//--- Resize table header if total calculated width differs from current
   if(header_width!=this.Width())
     {
      if(!this.ResizeW(header_width))
          return false;
     }

//--- Get pointer to the parent TableView object
   CTableView *table_view=this.GetContainer();
   if(table_view==NULL)
      return false;

//--- Get the table row panel (Table Area)
   CPanel *table_area=table_view.GetTableArea();
   if(table_area==NULL)
      return false;
   
//--- Resize the row panel to match the new total header width
   if(!table_area.ResizeW(header_width))
      return false;
   
//--- Sync all rows: loop through attached elements in the row panel
   CListElm *list=table_area.GetListAttachedElements();
   int total=list.Total();
   for(int i=0;i<total;i++)
     {
      CTableRowView *row=table_area.GetAttachedElementAt(i);
      if(row!=NULL)
        {
         //--- Match row width to panel width and trigger cell bound recalculation
         row.ResizeW(table_area.Width());
         row.RecalculateBounds(&this.m_list_bounds);
        }
     }
//--- Redraw all rows
   table_area.Draw(false);
   return true;
  }

//+------------------------------------------------------------------+
//| CTableHeaderView::Renders visual appearance                      |
//+------------------------------------------------------------------+
void CTableHeaderView::Draw(const bool chart_redraw)
  {
//--- Fill background, draw row line, and update canvas
   this.Fill(this.BackColor(),false);
   this.m_background.Line(this.AdjX(0),this.AdjY(this.Height()-1),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
   this.m_background.Update(false);
   
//--- Draw each column caption
   int total=this.m_list_bounds.Total();
   for(int i=0;i<total;i++)
     {
      CBound *cell_bound=this.GetBoundAt(i);
      if(cell_bound==NULL)
          continue;
      
      CColumnCaptionView *caption_view=cell_bound.GetAssignedObj();
      if(caption_view!=NULL)
          caption_view.Draw(false);
     }
//--- Update chart if requested
   if(chart_redraw)
      ::ChartRedraw(this.m_chart_id);
  }

//+------------------------------------------------------------------+
//| CTableHeaderView::Sets the sorting flag for a column caption     |
//+------------------------------------------------------------------+
void CTableHeaderView::SetSortedColumnCaption(const uint index)
  {
   int total=this.m_list_bounds.Total();
   for(int i=0;i<total;i++)
     {
      CColumnCaptionView *caption_view=this.GetColumnCaption(i);
      if(caption_view==NULL)
          continue;
      
      //--- Set ASC sort mode for target index, reset others to NONE
      if(i==index)
        {
         caption_view.SetSortMode(TABLE_SORT_MODE_ASC);
         caption_view.Draw(false);
        }
      else
        {
         caption_view.SetSortMode(TABLE_SORT_MODE_NONE);
         caption_view.Draw(false);
        }
     }
   this.Draw(true);
  }

//+------------------------------------------------------------------+
//| CTableHeaderView::Gets column caption by index                   |
//+------------------------------------------------------------------+
CColumnCaptionView *CTableHeaderView::GetColumnCaption(const uint index)
  {
   CBound *capt_bound=this.GetBoundAt(index);
   if(capt_bound==NULL)
      return NULL;
   return capt_bound.GetAssignedObj();
  }

//+------------------------------------------------------------------+
//| CTableHeaderView::Gets column caption with active sorting flag   |
//+------------------------------------------------------------------+
CColumnCaptionView *CTableHeaderView::GetSortedColumnCaption(void)
  {
   int total=this.m_list_bounds.Total();
   for(int i=0;i<total;i++)
     {
      CColumnCaptionView *caption_view=this.GetColumnCaption(i);
      if(caption_view!=NULL && caption_view.SortMode()!=TABLE_SORT_MODE_NONE)
          return caption_view;
     }
   return NULL;
  }

//+------------------------------------------------------------------+
//| CTableHeaderView::Returns the index of the sorted column         |
//+------------------------------------------------------------------+
int CTableHeaderView::IndexSortedColumnCaption(void)
  {
   int total=this.m_list_bounds.Total();
   for(int i=0;i<total;i++)
     {
      CColumnCaptionView *caption_view=this.GetColumnCaption(i);
      if(caption_view!=NULL && caption_view.SortMode()!=TABLE_SORT_MODE_NONE)
          return i;
     }
   return WRONG_VALUE;
  }
  //+------------------------------------------------------------------+
//| CTableHeaderView::Prints the assigned table header model         |
//| to the journal                                                   |
//+------------------------------------------------------------------+
void CTableHeaderView::TableHeaderModelPrint(const bool detail,const bool as_table=false,const int cell_width=CELL_WIDTH_IN_CHARS)
  {
   if(this.m_table_header_model!=NULL)
      this.m_table_header_model.Print(detail,as_table,cell_width);
  }

//+------------------------------------------------------------------+
//| CTableHeaderView::Handler for element's custom event             |
//| when the object area is clicked                                  |
//+------------------------------------------------------------------+
void CTableHeaderView::MousePressHandler(const int id,const long lparam,const double dparam,const string sparam)
  {
//--- Extract the table header object name from sparam
   int len=::StringLen(this.NameFG());
   string header_str=::StringSubstr(sparam,0,len);
//--- If the extracted name doesn't match this object's name - it's not our event, exit
   if(header_str!=this.NameFG())
      return;
   
//--- Find the column caption index within sparam
   string capt_str=::StringSubstr(sparam,len+1);
   string index_str=::StringSubstr(capt_str,5,capt_str.Length()-7);
//--- If no index is found in the string - exit
   if(index_str=="")
      return;
//--- Store the column caption index
   int index=(int)::StringToInteger(index_str);
   
//--- Get the column caption by index
   CColumnCaptionView *caption=this.GetColumnCaption(index);
   if(caption==NULL)
      return;
   
//--- If the caption has no sorting flag - set it to ascending sort mode
   if(caption.SortMode()==TABLE_SORT_MODE_NONE)
     {
      this.SetSortedColumnCaption(index);
     }

//--- Send a custom event to the chart:
//--- lparam: column index, dparam: sort mode, sparam: object name.
//--- Since standard OBJECT_CLICK events pass cursor coordinates in lparam/dparam, 
//--- we use negative values here to distinguish our custom data.
   ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_OBJECT_CLICK, -(1000+index), -(1000+caption.SortMode()), this.NameFG());
   ::ChartRedraw(this.m_chart_id);
  }


#endif