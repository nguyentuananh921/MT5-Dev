//+------------------------------------------------------------------+
//|                                                EnumsTables.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __DELIB_MQH__
#define __DELIB_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "..\Collections\ListObj.mqh"
   #include "..\Collections\ListElm.mqh"
   #include "..\Controls\VisualHint.mqh"
   #include "..\Controls\Button.mqh"
   #include "..\Controls\ButtonArrowDown.mqh"
   #include "..\Controls\ButtonArrowLeft.mqh"
   #include "..\Controls\ButtonArrowRight.mqh"
   #include "..\Controls\ButtonArrowUp.mqh"
   #include "..\Controls\ButtonTriggered.mqh"
   #include "..\Controls\CaptionView.mqh"
   #include "..\Controls\CheckBox.mqh"
   #include "..\Controls\ColumnCaptionView.mqh"
   #include "..\Controls\Container.mqh"
   #include "..\Controls\ElementBase.mqh"
   #include "..\Controls\GroupBox.mqh"
   #include "..\Controls\Label.mqh"
   #include "..\Controls\Panel.mqh"
   #include "..\Controls\RadioButton.mqh"
   #include "..\Controls\RowCaptionView.mqh"
   #include "..\Controls\ScrollBarH.mqh"
   #include "..\Controls\ScrollBarThumbH.mqh"
   #include "..\Controls\ScrollBarThumbV.mqh"
   #include "..\Controls\ScrollBarV.mqh"
   #include "..\Controls\TableCellView.mqh"
   #include "..\Controls\TableControl.mqh"
   #include "..\Controls\TableHeaderView.mqh"
   #include "..\Controls\TableRowsHeaderView.mqh"
   #include "..\Controls\TableRowView.mqh"
   #include "..\Controls\TableView.mqh" 
   
   #include "..\Tables\ColumnCaption.mqh"
   #include "..\Tables\MqlParamObj.mqh"
   #include "..\Tables\Table.mqh"
   #include "..\Tables\TableByParam.mqh"
   #include "..\Tables\TableCell.mqh"
   #include "..\Tables\TableHeader.mqh"
   #include "..\Tables\TableModel.mqh"
   #include "..\Tables\TableRow.mqh"
  
  
   //+------------------------------------------------------------------+
   // | List item creation method |
   //+------------------------------------------------------------------+
   CObject *CListObj::CreateElement(void)
    {
     // --- Depending on the object type in m_element_type, create a new object
      switch(this.m_element_type)
      {
         case OBJECT_TYPE_TABLE_CELL      :  return new CTableCell();
         case OBJECT_TYPE_TABLE_ROW       :  return new CTableRow();
         case OBJECT_TYPE_TABLE_MODEL     :  return new CTableModel();
         case OBJECT_TYPE_COLUMN_CAPTION  :  return new CColumnCaption();
         case OBJECT_TYPE_TABLE_HEADER    :  return new CTableHeader();
         case OBJECT_TYPE_TABLE           :  return new CTable();
         case OBJECT_TYPE_TABLE_BY_PARAM  :  return new CTableByParam();
         default                          :  return NULL;
      }
    }
   //+------------------------------------------------------------------+
   //| List item creation method                                        |
   //+------------------------------------------------------------------+
   CObject *CListElm::CreateElement(void)
    {
      // --- Depending on the object type in m_element_type, create a new object
      switch(this.m_element_type)
      {
         case ELEMENT_TYPE_BASE                       :  return new CBaseObj();           // Basic object of graphic elements
         case ELEMENT_TYPE_COLOR                      :  return new CColor();             // Color object
         case ELEMENT_TYPE_COLORS_ELEMENT             :  return new CColorElement();      // Graphics Element Colors Object
         case ELEMENT_TYPE_RECTANGLE_AREA             :  return new CBound();             // Rectangular element area
         case ELEMENT_TYPE_IMAGE_PAINTER              :  return new CImagePainter();      // Object for drawing images
         case ELEMENT_TYPE_CANVAS_BASE                :  return new CCanvasBase();        // Basic graphic element canvas object
         case ELEMENT_TYPE_ELEMENT_BASE               :  return new CElementBase();       // Basic object of graphic elements
         case ELEMENT_TYPE_HINT                       :  return new CVisualHint();        // Clue
         case ELEMENT_TYPE_LABEL                      :  return new CLabel();             // Text label
         case ELEMENT_TYPE_BUTTON                     :  return new CButton();            // Simple button
         case ELEMENT_TYPE_BUTTON_TRIGGERED           :  return new CButtonTriggered();   // Two-position button
         case ELEMENT_TYPE_BUTTON_ARROW_UP            :  return new CButtonArrowUp();     // Up arrow button
         case ELEMENT_TYPE_BUTTON_ARROW_DOWN          :  return new CButtonArrowDown();   // Down arrow button
         case ELEMENT_TYPE_BUTTON_ARROW_LEFT          :  return new CButtonArrowLeft();   // Left Arrow Button
         case ELEMENT_TYPE_BUTTON_ARROW_RIGHT         :  return new CButtonArrowRight();  // Right arrow button
         case ELEMENT_TYPE_CHECKBOX                   :  return new CCheckBox();          // CheckBox control
         case ELEMENT_TYPE_RADIOBUTTON                :  return new CRadioButton();       // RadioButton control
         case ELEMENT_TYPE_TABLE_CELL_VIEW            :  return new CTableCellView();     // Table cell (View)
         case ELEMENT_TYPE_TABLE_ROW_VIEW             :  return new CTableRowView();      // Table row (View)
         case ELEMENT_TYPE_TABLE_CAPTION_VIEW         :  return new CCaptionView();       // Basic header object (View)
         case ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW  :  return new CColumnCaptionView(); // Table Column Header (View)
         case ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW     :  return new CRowCaptionView();    // Table Row Header (View)
         case ELEMENT_TYPE_TABLE_HEADER_VIEW          :  return new CTableHeaderView();   // Table title (View)
         case ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW     :  return new CTableRowsHeaderView();// Vertical table header (View)
         case ELEMENT_TYPE_TABLE_VIEW                 :  return new CTableView();         // Table (View)
         case ELEMENT_TYPE_PANEL                      :  return new CPanel();             // Panel control
         case ELEMENT_TYPE_GROUPBOX                   :  return new CGroupBox();          // GroupBox control
         case ELEMENT_TYPE_CONTAINER                  :  return new CContainer();         // GroupBox control
         default                                      :  return NULL;
      }
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Creates a new tooltip |
   //+------------------------------------------------------------------+
   CVisualHint *CElementBase::CreateNewHint(const ENUM_HINT_TYPE type,const string object_name,const string user_name,const int id, const int x,const int y,const int w,const int h)
    {
      // --- Create a new tooltip object
      CVisualHint *obj=new CVisualHint(object_name,this.m_chart_id,this.m_wnd,x,y,w,h);
      if(obj==NULL)
      {
         ::PrintFormat("%s: Error: Failed to create Hint object",__FUNCTION__);
         return NULL;
      }
      // --- Set the identifier, name and type of tooltip
      obj.SetID(id);
      obj.SetName(user_name);
      obj.SetHintType(type);
      
      // --- Return a pointer to the created object
      return obj;
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Creates and adds a new tooltip object to the list|
   //+------------------------------------------------------------------+
   CVisualHint *CElementBase::CreateAndAddNewHint(const ENUM_HINT_TYPE type,const string user_name,const int w,const int h)
    {
      // --- Create a name for the graphic object
      int obj_total=this.m_list_hints.Total();
      string obj_name=this.NameFG()+"_HNT"+(string)obj_total;

      // --- Calculate the coordinates of the object below and to the right of the lower right corner of the element
      int x=this.Right()+1;
      int y=this.Bottom()+1;

      // --- Create a new tooltip object
      CVisualHint *obj=this.CreateNewHint(type,obj_name,user_name,obj_total,x,y,w,h);

      // --- If a new object is not created, return NULL
      if(obj==NULL)
         return NULL;

      // --- Set image limits, container and z-order
      obj.SetImageBound(0,0,this.Width(),this.Height());
      obj.SetContainerObj(&this);
      obj.ObjectSetZOrder(this.ObjectZOrder()+1);

      // --- If the created element is not added to the list, we report this, delete the created element and return NULL
      if(!this.AddHintToList(obj))
      {
         ::PrintFormat("%s: Error. Failed to add Hint object with ID %d to list",__FUNCTION__,obj.ID());
         delete obj;
         return NULL;
      }

      // --- Return a pointer to the created and attached object
      return obj;
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Adds an existing tooltip object to the list |
   //+------------------------------------------------------------------+
   CVisualHint *CElementBase::AddHint(CVisualHint *obj,const int dx,const int dy)
    {
     // --- If an object is passed that does not have a hint type, we return NULL
      if(obj.Type()!=ELEMENT_TYPE_HINT)
      {
         ::PrintFormat("%s: Error. Only an object with the Hint type can be used here. The element type \"%s\" was passed",__FUNCTION__,ElementDescription((ENUM_ELEMENT_TYPE)obj.Type()));
         return NULL;
      }
     // --- Remember the object identifier and set a new one
      int id=obj.ID();
      obj.SetID(this.m_list_hints.Total());
      
     // --- Add an object to the list; if it fails, we report this, set the initial identifier and return NULL
      if(!this.AddHintToList(obj))
      {
         ::PrintFormat("%s: Error. Failed to add Hint object to list",__FUNCTION__);
         obj.SetID(id);
         return NULL;
      }
     // --- Set new coordinates, container and z-order of the object
      int x=this.X()+dx;
      int y=this.Y()+dy;
      obj.Move(x,y);
      obj.SetContainerObj(&this);
      obj.ObjectSetZOrder(this.ObjectZOrder()+1);
      
     // --- Return a pointer to the attached object
      return obj;
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Adds arrow tooltip objects to the list |
   //+------------------------------------------------------------------+
   bool CElementBase::AddHintsArrowed(void)
    {
     // --- Arrays of names and types of hints
      string array[4]={DEF_HINT_NAME_HORZ,DEF_HINT_NAME_VERT,DEF_HINT_NAME_NWSE,DEF_HINT_NAME_NESW};
      
      ENUM_HINT_TYPE type[4]={HINT_TYPE_ARROW_HORZ,HINT_TYPE_ARROW_VERT,HINT_TYPE_ARROW_NWSE,HINT_TYPE_ARROW_NESW};
      
     // --- In a loop we create four tooltips with arrows
      bool res=true;
      for(int i=0;i<(int)array.Size();i++)
         res &=(this.CreateAndAddNewHint(type[i],array[i],0,0)!=NULL);
         
     // --- If there were errors during creation, return false
      if(!res)
         return false;
         
     // --- In a loop through an array of names of hint objects
      for(int i=0;i<(int)array.Size();i++)
      {
         // --- we get the next object by name,
         CVisualHint *obj=this.GetHint(array[i]);
         if(obj==NULL)
            continue;
         // --- hide the object and draw the appearance (arrows according to the type of object)
         obj.Hide(false);
         obj.Draw(false);
      }
     // --- Everything is successful
      return true;
    }
   //+------------------------------------------------------------------+
   //| CElementBase::Removes arrow tooltip objects from the list |
   //+------------------------------------------------------------------+
   bool CElementBase::DeleteHintsArrowed(void)
    {
     // --- In a loop through a list of hint objects
      bool res=true;
      for(int i=this.m_list_hints.Total()-1;i>=0;i--)
      {
         // --- we get another object and, if it is not a tooltip, we delete it
         CVisualHint *obj=this.m_list_hints.GetNodeAtIndex(i);
         if(obj!=NULL && obj.HintType()!=HINT_TYPE_TOOLTIP)
            res &=this.m_list_hints.DeleteCurrent();
      }
     // --- Return the result of removing tooltips with arrows
      return res;
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Displays the specified tooltip |
   // | at the specified coordinates |
   //+------------------------------------------------------------------+
   void CElementBase::ShowHintArrowed(const ENUM_HINT_TYPE type,const int x,const int y)
    {
      CVisualHint *hint=NULL; // Pointer to the object being searched for
     // --- In a loop through a list of tooltip objects
      for(int i=0;i<this.m_list_hints.Total();i++)
      {
         // --- get a pointer to the next object
         CVisualHint *obj=this.GetHintAt(i);
         if(obj==NULL)
            continue;
         // --- If this is the type of hint you are looking for, remember the pointer,
         if(obj.HintType()==type)
            hint=obj;
         // --- otherwise - hide the object
         else
            obj.Hide(false);
      }
     // --- If the desired object is found and it is hidden
      if(hint!=NULL && hint.IsHidden())
      {
       // --- place the object at the specified coordinates,
       // --- draw the appearance and bring the object to the foreground, making it visible
         hint.Move(x,y);
         hint.Draw(false);
         hint.BringToTop(true);
      }
    }
   //+------------------------------------------------------------------+
   //| CElementBase::Hide all tooltips |
   //+------------------------------------------------------------------+
   void CElementBase::HideHintsAll(const bool chart_redraw)
    {
     // --- In a loop through a list of hint objects
      for(int i=0;i<this.m_list_hints.Total();i++)
      {
         // --- get another object and hide it
         CVisualHint *obj=this.GetHintAt(i);
         if(obj!=NULL)
            obj.Hide(false);
      }
     // --- If indicated, redraw the graph
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Displays resizing cursor |
   //+------------------------------------------------------------------+
   bool CElementBase::ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y)
    {
         CVisualHint *hint=NULL;          // Pointer to tooltip
         int hint_shift_x=0;              // Tooltip X offset
         int hint_shift_y=0;              // Tooltip Y Offset
         
      // --- Depending on the location of the cursor on the borders of the element
      // --- indicate the offset of the tooltip relative to the cursor coordinates,
      // --- display the required hint on the chart and get a pointer to this object
         switch(edge)
         {
            // --- Cursor on the right or left border - horizontal double arrow
            case CURSOR_REGION_RIGHT         :
            case CURSOR_REGION_LEFT          :
               hint_shift_x=1;
               hint_shift_y=18;
               this.ShowHintArrowed(HINT_TYPE_ARROW_HORZ,x+hint_shift_x,y+hint_shift_y);
               hint=this.GetHint(DEF_HINT_NAME_HORZ);
            break;
         
            // --- Cursor on the top or bottom border - vertical double arrow
            case CURSOR_REGION_TOP           :
            case CURSOR_REGION_BOTTOM        :
               hint_shift_x=12;
               hint_shift_y=4;
               this.ShowHintArrowed(HINT_TYPE_ARROW_VERT,x+hint_shift_x,y+hint_shift_y);
               hint=this.GetHint(DEF_HINT_NAME_VERT);
            break;
         
            // --- Cursor in the upper left or lower right corner - diagonal double arrow from top left to bottom right
            case CURSOR_REGION_LEFT_TOP      :
            case CURSOR_REGION_RIGHT_BOTTOM  :
               hint_shift_x=10;
               hint_shift_y=2;
               this.ShowHintArrowed(HINT_TYPE_ARROW_NWSE,x+hint_shift_x,y+hint_shift_y);
               hint=this.GetHint(DEF_HINT_NAME_NWSE);
            break;
         
            // --- Cursor in the lower left or upper right corner - diagonal double arrow from bottom left to top right
            case CURSOR_REGION_LEFT_BOTTOM   :
            case CURSOR_REGION_RIGHT_TOP     :
               hint_shift_x=5;
               hint_shift_y=12;
               this.ShowHintArrowed(HINT_TYPE_ARROW_NESW,x+hint_shift_x,y+hint_shift_y);
               hint=this.GetHint(DEF_HINT_NAME_NESW);
            break;
            
            // --- By default we do nothing
            default: break;
         }

      // --- Return the result of adjusting the position of the tooltip relative to the cursor
         return(hint!=NULL ? hint.Move(x+hint_shift_x,y+hint_shift_y) : false);
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Right resize handler |
   //+------------------------------------------------------------------+
   bool CElementBase::ResizeZoneRightHandler(const int x,const int y)
    {
      // --- Calculate and set the new width of the element
         int width=::fmax(x-this.X()+1,DEF_PANEL_MIN_W);
         if(!this.ResizeW(width))
            return false;
      // --- Get a pointer to a hint
         CVisualHint *hint=this.GetHint(DEF_HINT_NAME_HORZ);
         if(hint==NULL)
            return false;
      // --- Shift the tooltip by the specified amounts relative to the cursor
         int shift_x=1;
         int shift_y=18;
         return hint.Move(x+shift_x,y+shift_y);
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Handler for resizing beyond the bottom edge |
   //+------------------------------------------------------------------+
   bool CElementBase::ResizeZoneBottomHandler(const int x,const int y)
    {
      // --- Calculate and set the new height of the element
         int height=::fmax(y-this.Y(),DEF_PANEL_MIN_H);
         if(!this.ResizeH(height))
            return false;
      // --- Get a pointer to a hint
         CVisualHint *hint=this.GetHint(DEF_HINT_NAME_VERT);
         if(hint==NULL)
            return false;
      // --- Shift the tooltip by the specified amounts relative to the cursor
         int shift_x=12;
         int shift_y=4;
         return hint.Move(x+shift_x,y+shift_y);
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Resizing beyond the left edge |
   //+------------------------------------------------------------------+
   bool CElementBase::ResizeZoneLeftHandler(const int x,const int y)
    {
      // --- Calculate the new X coordinate and width of the element
         int new_x=::fmin(x,this.Right()-DEF_PANEL_MIN_W+1);
         int width=this.Right()-new_x+1;
      // --- Set new X coordinate and element width
         if(!this.MoveXYWidthResize(new_x,this.Y(),width,this.Height()))
            return false;
      // --- Get a pointer to a hint
         CVisualHint *hint=this.GetHint(DEF_HINT_NAME_HORZ);
         if(hint==NULL)
            return false;
      // --- Shift the tooltip by the specified amounts relative to the cursor
         int shift_x=1;
         int shift_y=18;
         return hint.Move(x+shift_x,y+shift_y);
    }
   //+------------------------------------------------------------------+
   //| CElementBase::Resizing beyond the top edge |
   //+------------------------------------------------------------------+
   bool CElementBase::ResizeZoneTopHandler(const int x,const int y)
    {
      // --- Calculate the new Y coordinate and height of the element
         int new_y=::fmin(y,this.Bottom()-DEF_PANEL_MIN_H+1);
         int height=this.Bottom()-new_y+1;
      // --- Set new Y coordinate and element height
         if(!this.MoveXYWidthResize(this.X(),new_y,this.Width(),height))
            return false;
      // --- Get a pointer to a hint
         CVisualHint *hint=this.GetHint(DEF_HINT_NAME_VERT);
         if(hint==NULL)
            return false;
      // --- Shift the tooltip by the specified amounts relative to the cursor
         int shift_x=12;
         int shift_y=4;
         return hint.Move(x+shift_x,y+shift_y);
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Resize for lower right corner |
   //+------------------------------------------------------------------+
   bool CElementBase::ResizeZoneRightBottomHandler(const int x,const int y)
    {
      // --- Calculate and set the new width and height of the element
         int width =::fmax(x-this.X()+1, DEF_PANEL_MIN_W);
         int height=::fmax(y-this.Y()+1, DEF_PANEL_MIN_H);
         if(!this.Resize(width,height))
            return false;
      // --- Get a pointer to a hint
         CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NWSE);
         if(hint==NULL)
            return false;
      // --- Shift the tooltip by the specified amounts relative to the cursor
         int shift_x=10;
         int shift_y=2;
         return hint.Move(x+shift_x,y+shift_y);
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Resizing for the upper right corner |
   //+------------------------------------------------------------------+
   bool CElementBase::ResizeZoneRightTopHandler(const int x,const int y)
    {
      // --- Calculate and set new Y coordinates, width and height of the element
         int new_y=::fmin(y, this.Bottom()-DEF_PANEL_MIN_H+1);
         int width =::fmax(x-this.X()+1, DEF_PANEL_MIN_W);
         int height=this.Bottom()-new_y+1;
         if(!this.MoveXYWidthResize(this.X(),new_y,width,height))
            return false;
      // --- Get a pointer to a hint
         CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NESW);
         if(hint==NULL)
            return false;
      // --- Shift the tooltip by the specified amounts relative to the cursor
         int shift_x=5;
         int shift_y=12;
         return hint.Move(x+shift_x,y+shift_y);
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Resize to bottom left corner |
   //+------------------------------------------------------------------+
   bool CElementBase::ResizeZoneLeftBottomHandler(const int x,const int y)
    {
      // --- Calculate and set new X coordinates, width and height of the element
         int new_x=::fmin(x, this.Right()-DEF_PANEL_MIN_W+1);
         int width =this.Right()-new_x+1;
         int height=::fmax(y-this.Y()+1, DEF_PANEL_MIN_H);
         if(!this.MoveXYWidthResize(new_x,this.Y(),width,height))
            return false;
      // --- Get a pointer to a hint
         CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NESW);
         if(hint==NULL)
            return false;
      // --- Shift the tooltip by the specified amounts relative to the cursor
         int shift_x=5;
         int shift_y=12;
         return hint.Move(x+shift_x,y+shift_y);
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Resize by upper left corner |
   //+------------------------------------------------------------------+
   bool CElementBase::ResizeZoneLeftTopHandler(const int x,const int y)
    {
      // --- Calculate and set new X and Y coordinates, width and height of the element
         int new_x=::fmin(x,this.Right()-DEF_PANEL_MIN_W+1);
         int new_y=::fmin(y,this.Bottom()-DEF_PANEL_MIN_H+1);
         int width =this.Right() -new_x+1;
         int height=this.Bottom()-new_y+1;
         if(!this.MoveXYWidthResize(new_x, new_y,width,height))
            return false;
      // --- Get a pointer to a hint
         CVisualHint *hint=this.GetHint(DEF_HINT_NAME_NWSE);
         if(hint==NULL)
            return false;
      // --- Shift the tooltip by the specified amounts relative to the cursor
         int shift_x=10;
         int shift_y=2;
         return hint.Move(x+shift_x,y+shift_y);
    }
   //+------------------------------------------------------------------+
   // | CElementBase::Adds a previously created tooltip object to the list|
   //+------------------------------------------------------------------+
   CVisualHint *CElementBase::InsertTooltip(CVisualHint *obj,const int dx,const int dy)
    {
     // --- If an empty or invalid pointer to an object is passed, return NULL
      if(::CheckPointer(obj)==POINTER_INVALID)
      {
         ::PrintFormat("%s: Error. Empty element passed",__FUNCTION__);
         return NULL;
      }
     // --- If the tooltip type is not tooltype, we report this and return NULL
      if(obj.HintType()!=HINT_TYPE_TOOLTIP)
      {
         ::PrintFormat("%s: Error. Only a tooltip can be added to an element",__FUNCTION__);
         return NULL;
      }
     // --- Add the specified hint object to the list;
     // --- Return a pointer to the created and attached object
      return this.AddHint(obj,dx,dy);
    }
   //+------------------------------------------------------------------+
   //| CElementBase::Creates and adds a new tooltip object to the list  |
   //+------------------------------------------------------------------+
   CVisualHint *CElementBase::InsertNewTooltip(const ENUM_HINT_TYPE type,const string user_name,const int w,const int h)
    {
     // --- If the tooltip type is not a tooltip, we report this and return NULL
      if(type!=HINT_TYPE_TOOLTIP)
      {
         ::PrintFormat("%s: Error. Only a tooltip can be added to an element",__FUNCTION__);
         return NULL;
      }
     // --- Create and add a new hint object to the list;
     // --- Return a pointer to the created and attached object
      return this.CreateAndAddNewHint(type,user_name,w,h);
    }
   //+------------------------------------------------------------------+
   //| CElementBase::Returns a pointer to the tooltip by index          |
   //+------------------------------------------------------------------+
   CVisualHint *CElementBase::GetHintAt(const int index)
    {
      return this.m_list_hints.GetNodeAtIndex(index);
    } 
   //+------------------------------------------------------------------+
   //| CElementBase::Returns a pointer to a tooltip by ID               |
   //+------------------------------------------------------------------+
   CVisualHint *CElementBase::GetHint(const int id)
    {
      int total=this.m_list_hints.Total();
      for(int i=0;i<total;i++)
      {
         CVisualHint *obj=this.GetHintAt(i);
         if(obj!=NULL && obj.ID()==id)
            return obj;
      }
      return NULL;
    }
   //+------------------------------------------------------------------+
   // |CElementBase:: Returns a pointer to the name hint                |
   //+------------------------------------------------------------------+
   CVisualHint *CElementBase::GetHint(const string name)
    {
      int total=this.m_list_hints.Total();
      for(int i=0;i<total;i++)
      {
         CVisualHint *obj=this.GetHintAt(i);
         if(obj!=NULL && obj.Name()==name)
            return obj;
      }
      return NULL;
    }
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Adds to list |
   // | tooltip objects with arrows |
   //+------------------------------------------------------------------+
   bool CColumnCaptionView::AddHintsArrowed(void)
      {
      // --- Create a horizontal offset arrow tooltip
      CVisualHint *hint=this.CreateAndAddNewHint(HINT_TYPE_ARROW_SHIFT_HORZ,DEF_HINT_NAME_SHIFT_HORZ,18,18);
      if(hint==NULL)
         return false;

      // --- Set the size of the tooltip image area
      hint.SetImageBound(0,0,hint.Width(),hint.Height());
      
      // --- hide the tooltip and draw the appearance
      hint.Hide(false);
      hint.Draw(false);
      
      // --- Everything is successful
      return true;
      }
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Displays resizing cursor |
   //+------------------------------------------------------------------+
   bool CColumnCaptionView::ShowCursorHint(const ENUM_CURSOR_REGION edge,int x,int y)
    {
      CVisualHint *hint=NULL;          // Pointer to tooltip
      int hint_shift_x=0;              // Tooltip X offset
      int hint_shift_y=0;              // Tooltip Y Offset
      
     // --- Depending on the location of the cursor on the borders of the element
     // --- indicate the offset of the tooltip relative to the cursor coordinates,
     // --- display the required hint on the chart and get a pointer to this object
      if(edge!=CURSOR_REGION_RIGHT)
         return false;
      
      hint_shift_x=-8;
      hint_shift_y=-12;
      this.ShowHintArrowed(HINT_TYPE_ARROW_SHIFT_HORZ,x+hint_shift_x,y+hint_shift_y);
      hint=this.GetHint(DEF_HINT_NAME_SHIFT_HORZ);

     // --- Return the result of adjusting the position of the tooltip relative to the cursor
      return(hint!=NULL ? hint.Move(x+hint_shift_x,y+hint_shift_y) : false);
    }
   //+------------------------------------------------------------------+
   // | CColumnCaptionView::Right resizing handler|
   //+------------------------------------------------------------------+
   bool CColumnCaptionView::ResizeZoneRightHandler(const int x,const int y)
    {
     // --- Calculate and set the new width of the element
      int width=::fmax(x-this.X()+1,DEF_TABLE_COLUMN_MIN_W);
      if(!this.ResizeW(width))
         return false;
     // --- Get a pointer to a hint
      CVisualHint *hint=this.GetHint(DEF_HINT_NAME_SHIFT_HORZ);
      if(hint==NULL)
         return false;
     // --- Shift the tooltip by the specified amounts relative to the cursor
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
#endif // __DELIB_MQH__

#ifndef MOVE_TO_FUNCTIONLIB_MQH
#define MOVE_TO_FUNCTIONLIB_MQH
      // //+------------------------------------------------------------------+
      // // |  Returns the object type as a string |
      // //+------------------------------------------------------------------+
      // string TypeDescription(const ENUM_OBJECT_TYPE type)
      // {
      //    string array[];
      //    int total=StringSplit(EnumToString(type),StringGetCharacter("_",0),array);
      //    string result="";
      //    for(int i=2;i<total;i++)
      //    {
      //       array[i]+=" ";
      //       array[i].Lower();
      //       array[i].SetChar(0,ushort(array[i].GetChar(0)-0x20));
      //       result+=array[i];
      //    }
      //    result.TrimLeft();
      //    result.TrimRight();
      //    return result;
      // }
#endif // MOVE_TO_FUNCTIONLIB_MQH
  
  // // --- Forward declaration of classes
   //  #ifndef __TABLEOBJECT_MQH__
   //  #define __TABLEOBJECT_MQH__
      
      
   //    class CTableCell;                   // Table cell class
   //    class CTableRow;                    // Table row class
   //    class CTableModel;                  // Table model class
   //    class CColumnCaption;               // Table Column Header Class
   //    class CTableHeader;                 // Table header class
   //    class CTable;                       // Table class
   //    class CTableByParam;                // Table class based on an array of parameters
   //  #endif // __TABLEOBJECT_MQH__
   //  #ifndef __CONTROLELEMENT_MQH__
   //  #define __CONTROLELEMENT_MQH__
   
   //  #endif // __CONTROLELEMENT_MQH__

      


   // // #include "..\Tables\CColumnCaption.mqh"
   // // #include "..\Tables\MqlParamObj.mqh"
   // // #include "..\Tables\Table.mqh"
   // // #include "..\Tables\TableByParam.mqh"
   // // #include "..\Tables\TableCell.mqh"
   // // #include "..\Tables\TableHeader.mqh"
   // // #include "..\Tables\TableModel.mqh"
   // // #include "..\Tables\TableRow.mqh"