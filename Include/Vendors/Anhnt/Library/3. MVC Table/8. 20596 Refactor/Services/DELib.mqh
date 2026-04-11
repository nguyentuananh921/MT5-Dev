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

   #include "..\Controls\ElementBase.mqh"
   #include "..\Controls\Label.mqh"
   #include "..\Controls\Button.mqh"

   #include "..\Controls\ButtonTriggered.mqh"
   #include "..\Controls\ButtonArrowUp.mqh"
   #include "..\Controls\ButtonArrowDown.mqh"
   #include "..\Controls\ButtonArrowLeft.mqh"
   #include "..\Controls\ButtonArrowRight.mqh"

   #include "..\Controls\VisualHint.mqh"
   #include "..\Controls\CheckBox.mqh"
   #include "..\Controls\RadioButton.mqh"
   #include "..\Controls\Panel.mqh"
   #include "..\Controls\GroupBox.mqh"

   #include "..\Controls\ScrollBarThumbH.mqh"
   #include "..\Controls\ScrollBarThumbV.mqh"
   #include "..\Controls\ScrollBarH.mqh"
   #include "..\Controls\ScrollBarV.mqh"

   #include "..\Controls\Container.mqh"

   #include "..\Controls\TableCellView.mqh"
   #include "..\Controls\TableRowView.mqh"

   #include "..\Controls\CaptionView.mqh"   
   #include "..\Controls\ColumnCaptionView.mqh"
   #include "..\Controls\RowCaptionView.mqh"

   #include "..\Controls\TableHeaderView.mqh"
   #include "..\Controls\TableRowsHeaderView.mqh"
   #include "..\Controls\TableView.mqh" 
   #include "..\Controls\TableControl.mqh"  
   
   #include "..\Tables\ColumnCaption.mqh"
   #include "..\Tables\MqlParamObj.mqh"
   #include "..\Tables\Table.mqh"
   #include "..\Tables\TableByParam.mqh"
   #include "..\Tables\TableCell.mqh"
   #include "..\Tables\TableHeader.mqh"
   #include "..\Tables\TableModel.mqh"
   #include "..\Tables\TableRow.mqh"
  
 #ifndef __MOVE_FROM_CLISTOBJ_CLASS__
 #define __MOVE_FROM_CLISTOBJ_CLASS__
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
   
 #endif // MOVE_FROM_CLISTOBJ_CLASS__ 
 
 #ifndef __MOVE_FROM_CLISTELM_CLASS__
 #define __MOVE_FROM_CLISTELM_CLASS__
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
   
 #endif // MOVE_FROM_CLISTELM_CLASS__

 #ifndef __MOVE_FROM_CELEMENTBASE_CLASS__
 #define __MOVE_FROM_CELEMENTBASE_CLASS__
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
      // --- Now using the clean Description() method instead of ElementDescription()
      if(obj.Type() != ELEMENT_TYPE_HINT)
      {
         ::PrintFormat("%s: Error. Only an object with the Hint type can be used here. Passed: %s", 
                     __FUNCTION__, obj.Description());
         return NULL;
      }

         //   // --- If an object is passed that does not have a hint type, we return NULL
         //    if(obj.Type()!=ELEMENT_TYPE_HINT)
         //    {
         //       ::PrintFormat("%s: Error. Only an object with the Hint type can be used here. The element type \"%s\" was passed",__FUNCTION__,ElementDescription((ENUM_ELEMENT_TYPE)obj.Type()));
         //       return NULL;
         //    }
     // --- Remember the object identifier and set a new one
      int id=obj.ID();
      obj.SetID(this.m_list_hints.Total());
      
     // --- Add an object to the list; if it fails, we report this, set the initial identifier and return NULL
      if(!this.AddHintToList(obj))
      {
         ::PrintFormat("%s: Error. Failed to add Hint object to list: %s", 
                    __FUNCTION__, obj.Description());
         // ::PrintFormat("%s: Error. Failed to add Hint object to list",__FUNCTION__);
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
 #endif // MOVE_FROM_CELEMENTBASE_CLASS__

 #ifndef __MOVE_FROM_CCOLUMNCAPTIONVIEW_CLASS__
 #define __MOVE_FROM_CCOLUMNCAPTIONVIEW_CLASS__
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
 #endif // MOVE_FROM_CCOLUMNCAPTIONVIEW_CLASS__

 #ifndef __MOVE_FROM_CPANEL_CLASS__
 #define __MOVE_FROM_CPANEL_CLASS__
  //+------------------------------------------------------------------+
  //| CPanel::Creates and adds a new element to the list |
  //+------------------------------------------------------------------+
  CElementBase *CPanel::InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h)
   {
      // --- Create a name for the graphic object
      int elm_total=this.m_list_elm.Total();
      //string obj_name=this.NameFG()+"_"+ElementShortName(type)+(string)elm_total;
      // --- Add here      
      // Call the static helper from the base class to get the prefix (e.g., "SBTN", "LBL")
      string obj_name=this.NameFG()+"_"+CBaseObj::FormatElementShortName(type)+(string)elm_total;
      // --- Calculate coordinates
      int x=this.X()+dx;
      int y=this.Y()+dy;
      // --- Depending on the type of object, we create a new object
      CElementBase *element=NULL;
      switch(type)
      {
         case ELEMENT_TYPE_LABEL                      :  element = new CLabel(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);             break;   // Text label
         case ELEMENT_TYPE_BUTTON                     :  element = new CButton(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);            break;   // Simple button
         case ELEMENT_TYPE_BUTTON_TRIGGERED           :  element = new CButtonTriggered(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Two-position button
         case ELEMENT_TYPE_BUTTON_ARROW_UP            :  element = new CButtonArrowUp(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);     break;   // Up arrow button
         case ELEMENT_TYPE_BUTTON_ARROW_DOWN          :  element = new CButtonArrowDown(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Down arrow button
         case ELEMENT_TYPE_BUTTON_ARROW_LEFT          :  element = new CButtonArrowLeft(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Left Arrow Button
         case ELEMENT_TYPE_BUTTON_ARROW_RIGHT         :  element = new CButtonArrowRight(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);  break;   // Right arrow button
         case ELEMENT_TYPE_CHECKBOX                   :  element = new CCheckBox(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);          break;   // CheckBox control
         case ELEMENT_TYPE_RADIOBUTTON                :  element = new CRadioButton(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);       break;   // RadioButton control
         case ELEMENT_TYPE_SCROLLBAR_THUMB_H          :  element = new CScrollBarThumbH(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Scrollbar horizontal ScrollBar
         case ELEMENT_TYPE_SCROLLBAR_THUMB_V          :  element = new CScrollBarThumbV(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Vertical ScrollBar
         case ELEMENT_TYPE_SCROLLBAR_H                :  element = new CScrollBarH(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);        break;   // Horizontal ScrollBar control
         case ELEMENT_TYPE_SCROLLBAR_V                :  element = new CScrollBarV(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);        break;   // Vertical ScrollBar control
         case ELEMENT_TYPE_TABLE_ROW_VIEW             :  element = new CTableRowView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);      break;   // Table row visual object
         case ELEMENT_TYPE_TABLE_CAPTION_VIEW         :  element = new CCaptionView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);       break;   // Basic header object (View)
         case ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW  :  element = new CColumnCaptionView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h); break;   // Table column header visual representation object
         case ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW     :  element = new CRowCaptionView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);    break;   // Table row header visual representation object
         case ELEMENT_TYPE_TABLE_HEADER_VIEW          :  element = new CTableHeaderView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);   break;   // Table header visual object
         case ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW     :  element = new CTableRowsHeaderView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);break;  // Object for visual representation of table row headers
         case ELEMENT_TYPE_TABLE_VIEW                 :  element = new CTableView(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);         break;   // Table visual object
         case ELEMENT_TYPE_PANEL                      :  element = new CPanel(obj_name,"",this.m_chart_id,this.m_wnd,x,y,w,h);               break;   // Panel control
         case ELEMENT_TYPE_GROUPBOX                   :  element = new CGroupBox(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);          break;   // GroupBox control
         case ELEMENT_TYPE_CONTAINER                  :  element = new CContainer(obj_name,text,this.m_chart_id,this.m_wnd,x,y,w,h);         break;   // Container control
         default                                      :  element = NULL;
      }
      // --- If a new element is not created, we report this and return NULL
      if(element==NULL)
       {
         //::PrintFormat("%s: Error. Failed to create graphic element %s",__FUNCTION__,ElementDescription(type));
         // --- Add here
         // Use static helper to format the type name because 'element' is still NULL
         ::PrintFormat("%s: Error. Failed to create graphic element: %s",__FUNCTION__,CBaseObj::FormatElementType(type));
         return NULL;
       }
       // --- Set the identifier, name, container and z-order of the element
       element.SetID(elm_total);
       element.SetName(user_name);
       //element.SetContainerObj(&this);
       element.SetContainerObj(GetPointer(this));
       element.ObjectSetZOrder(this.ObjectZOrder()+1);

       // --- If the created element is not added to the list, we report this, delete the created element and return NULL
      if(!this.AddNewElement(element))
       {
         //::PrintFormat("%s: Error. Failed to add %s element with ID %d to list",__FUNCTION__,ElementDescription(type),element.ID());
         // --- Add here
         // Use the object's own Description() method for detailed logging
         ::PrintFormat("%s: Error. Failed to add element to list: %s",__FUNCTION__,element.Description());
         delete element;
         return NULL;
       }
       // --- We get the parent element to which the children are attached
       CElementBase *elm=this.GetContainer();
       // --- If the parent element is of type "Container", then it has scrollbars
      if(elm!=NULL && elm.Type()==ELEMENT_TYPE_CONTAINER)
       {
         // --- Convert CElementBase to CContainer
         //CContainer *container_obj=elm;
         CContainer *container_obj = (CContainer*)elm;
         // --- If the horizontal scroll bar is visible,
         if(container_obj.ScrollBarHorzIsVisible())
         {
            // --- get a pointer to the horizontal scrollbar and move it to the front
            CScrollBarH *sbh=container_obj.GetScrollBarH();
            if(sbh!=NULL)
               sbh.BringToTop(false);
         }
         // --- If the vertical scroll bar is visible,
         if(container_obj.ScrollBarVertIsVisible())
         {
            // --- get the pointer to the vertical scrollbar and move it to the front
            CScrollBarV *sbv=container_obj.GetScrollBarV();
            if(sbv!=NULL)
               sbv.BringToTop(false);
         }
       }
      // --- Return a pointer to the created and attached element
      return element;
   }
  //+------------------------------------------------------------------+
  //| CPanel::Changes the width of an object |
  //+------------------------------------------------------------------+
  bool CPanel::ResizeW(const int w)
   {
      if(!this.ObjectResizeW(w))
         return false;
      this.BoundResizeW(w);
      this.SetImageSize(w,this.Height());
      if(!this.ObjectTrim())
      {
         this.Update(false);
         this.Draw(false);
      }
     // --- We get a pointer to the base element and, if it exists, its type - container,
     // --- check the ratio of the dimensions of the current element relative to the dimensions of the container
     // --- to display scrollbars in the container if necessary
     CCanvasBase *container_ptr = this.GetContainer();
     if(CheckPointer(container_ptr) != POINTER_INVALID)
      {
         // Check if the type matches before calling
         if(container_ptr.Type() == ELEMENT_TYPE_CONTAINER)
         {
            // Use dynamic pointer casting
            CContainer *base = (CContainer*)container_ptr;
            
            if(CheckPointer(base) != POINTER_INVALID)
            {
               base.CheckElementSizes(GetPointer(this));
            }
         }
      }
      /*
      if(this.GetContainer()!=NULL && this.GetContainer().Type()==ELEMENT_TYPE_CONTAINER)
      {         
         CContainer *base=this.GetContainer();
         base.CheckElementSizes(&this);
      }*/
         
     // --- In a loop through attached elements, we cut off each element along the boundaries of the container
      int total=this.m_list_elm.Total();
      for(int i=0;i<total;i++)
      {
         CElementBase *elm=this.GetAttachedElementAt(i);
         if(elm!=NULL)
            elm.ObjectTrim();
      }
     // --- Everything is successful
      return true;
   }
  //+------------------------------------------------------------------+
  // | CPanel::Changes the height of an object |
  //+------------------------------------------------------------------+
  bool CPanel::ResizeH(const int h)
   {
      if(!this.ObjectResizeH(h))
         return false;
      this.BoundResizeH(h);
      this.SetImageSize(this.Width(),h);
      if(!this.ObjectTrim())
      {
         this.Update(false);
         this.Draw(false);
      }
     // --- We get a pointer to the base element and, if it exists, its type - container,
     // --- check the ratio of the dimensions of the current element relative to the dimensions of the container
     // --- to display scrollbars in the container if necessary
      if(this.GetContainer()!=NULL && this.GetContainer().Type()==ELEMENT_TYPE_CONTAINER)
      {
         CContainer *base=this.GetContainer();         
         //base.CheckElementSizes(&this);
         base.CheckElementSizes(GetPointer(this));
      }
         
     // --- In a loop through attached elements, we cut off each element along the boundaries of the container
      int total=this.m_list_elm.Total();
      for(int i=0;i<total;i++)
      {
         CElementBase *elm=this.GetAttachedElementAt(i);
         if(elm!=NULL)
            elm.ObjectTrim();
      }
     // --- Everything is successful
      return true;
   }
  //+------------------------------------------------------------------+
  //| CPanel::Resizes an object |
  //+------------------------------------------------------------------+
  bool CPanel::Resize(const int w,const int h)
   {
      if(!this.ObjectResize(w,h))
         return false;
      this.BoundResize(w,h);
      this.SetImageSize(w,h);
      if(!this.ObjectTrim())
      {
         this.Update(false);
         this.Draw(false);
      }
     // --- We get a pointer to the base element and, if it exists, its type - container,
     // --- check the ratio of the dimensions of the current element relative to the dimensions of the container
     // --- to display scrollbars in the container if necessary
      CContainer *base=this.GetContainer();
      if(base!=NULL && base.Type()==ELEMENT_TYPE_CONTAINER)         
         //base.CheckElementSizes(&this);
         base.CheckElementSizes(GetPointer(this));
     // --- In a loop through attached elements, we cut off each element along the boundaries of the container
      int total=this.m_list_elm.Total();
      for(int i=0;i<total;i++)
      {
         CElementBase *elm=this.GetAttachedElementAt(i);
         if(elm!=NULL)
            elm.ObjectTrim();
      }
     // --- Everything is successful
      return true;
   }
 #endif // MOVE_FROM_CPANEL_CLASS__   

 #ifndef __MOVE_FROM_CTABLEROWVIEW_CLASS__
 #define __MOVE_FROM_CTABLEROWVIEW_CLASS__
  //+------------------------------------------------------------------+
  // | CTableRowView::Returns the row title |
  //+------------------------------------------------------------------+
  CRowCaptionView *CTableRowView::GetRowCaption(const uint index)
   {
      CTableRowsHeaderView *header=this.GetRowsHeaderView();
      return(header!=NULL ? header.GetRowCaption(index) : NULL);
   }     
  //+------------------------------------------------------------------+
  // | CTableRowView::Returns the column title |
  //+------------------------------------------------------------------+
  CColumnCaptionView *CTableRowView::GetColumnCaption(const uint index)
   {
      CTableHeaderView *header=this.GetHeaderView();
      return(header!=NULL ? header.GetColumnCaption(index) : NULL);
   }  
  //+------------------------------------------------------------------+
  // |CTableRowView::Returns a visual representation of the row headers|
  //+------------------------------------------------------------------+
  CTableRowsHeaderView *CTableRowView::GetRowsHeaderView(void)
   {
      CTableView *table=this.GetTableView();
      return(table!=NULL ? table.GetRowsHeader() : NULL);
   }
  //+------------------------------------------------------------------+
  // | CTableRowView::Returns the visual view |
  // | column headers |
  //+------------------------------------------------------------------+
  CTableHeaderView *CTableRowView::GetHeaderView(void)
   {
      CTableView *table=this.GetTableView();
      return(table!=NULL ? table.GetHeader() : NULL);
   }
  //+------------------------------------------------------------------+
  // | CTableRowView::Returns a visual view of the table |
  //+------------------------------------------------------------------+
  CTableView *CTableRowView::GetTableView(void)
   {
      CTableView *obj=NULL;
    // --- We get a panel with table rows
      CElementBase *base0=this.GetContainer();
      if(base0==NULL)
         return NULL;
      
    // --- Getting the table row panel container
      CElementBase *base1=base0.GetContainer();
      if(base1==NULL)
         return NULL;
      
    // --- Get the table visual representation object
      CElementBase *base2=base1.GetContainer();
      if(base2!=NULL && base2.Type()==ELEMENT_TYPE_TABLE_VIEW)
      {
         obj=base2;
         return obj;
      }
      return NULL;
   }
 #endif // MOVE_FROM_CTABLEROWVIEW_CLASS__


 #ifndef __MOVE_FROM_CGROUPBOX_CLASS__
 #define __MOVE_FROM_CGROUPBOX_CLASS__
   //+------------------------------------------------------------------+
   //| CGroupBox::Creates and adds a new element to the list            |
   //+------------------------------------------------------------------+
   CElementBase *CGroupBox::InsertNewElement(const ENUM_ELEMENT_TYPE type,const string text,const string user_name,const int dx,const int dy,const int w,const int h)
    {
     // --- Create and add a new element to the list of elements
      CElementBase *element=CPanel::InsertNewElement(type,text,user_name,dx,dy,w,h);
      if(element==NULL)
         return NULL;
     // --- Set the created element to a group equal to the group of this object
      element.SetGroup(this.Group());
      return element;
    }
  //+------------------------------------------------------------------+
  // | CGroupBox::Adds the specified element to the list |
  //+------------------------------------------------------------------+
  CElementBase *CGroupBox::InsertElement(CElementBase *element,const int dx,const int dy)
   {
     // --- Add a new element to the list of elements
      if(CPanel::InsertElement(element,dx,dy)==NULL)
         return NULL;
     // --- Set the added element to a group equal to the group of this object
      element.SetGroup(this.Group());
      return element;
   }
 #endif // MOVE_FROM_CGROUPBOX_CLASS__

 
 #ifndef __MOVE_FROM_CCONTAINER_CLASS__
 #define __MOVE_FROM_CCONTAINER_CLASS__
  //+-------------------------------------------------------------------+
  //|CContainer::Shifts content horizontally by the specified amount    |
  //+-------------------------------------------------------------------+
  bool CContainer::ContentShiftHorz(const int value)
   {
    // --- Get a pointer to the contents of the container
      CElementBase *elm=this.GetAttachedElement();
      if(elm==NULL)
         return false;
      
    // --- Calculate the offset value based on the position of the slider
      int content_offset=this.CalculateContentOffsetHorz(value);
      
    // --- For the CTableView element we get the table title
      bool res=true;
      CElementBase     *elm_container=elm.GetContainer();
      CTableHeaderView *table_header=NULL;
      if(elm_container!=NULL && ::StringFind(elm.Name(),"Table")==0)
      {
         CElementBase *obj=elm_container.GetContainer();
         if(obj!=NULL && obj.Type()==ELEMENT_TYPE_TABLE_VIEW)
         {
            CTableView *table_view = (CTableView*)obj;
               if(CheckPointer(table_view) != POINTER_INVALID)
               {
                  table_header = table_view.GetHeader();
                  if(CheckPointer(table_header) != POINTER_INVALID)
                     res &= table_header.MoveX(this.X() - content_offset);
               }

            // table_header=table_view.GetHeader();
            // // --- Move the title
            // if(table_header!=NULL)
            //    res &=table_header.MoveX(this.X()-content_offset);
         }
      }

    // --- Return the result of shifting the content by the calculated amount
      res &=elm.MoveX(this.X()-content_offset);
      return res;
   }
  //+------------------------------------------------------------------+
  //| CContainer::Shifts the content vertically by the specified value|
  //+------------------------------------------------------------------+
  bool CContainer::ContentShiftVert(const int value)
  {
   // --- Get a pointer to the contents of the container
      CElementBase *elm=this.GetAttachedElement();
      if(elm==NULL)
         return false;
      
   // --- Calculate the offset value based on the position of the slider
      int content_offset=this.CalculateContentOffsetVert(value);
      
   // --- For the CTableView element we get the vertical table header
      bool res=true;
      CElementBase         *elm_container=elm.GetContainer();
      CTableRowsHeaderView *table_header=NULL;
      if(elm_container!=NULL && ::StringFind(elm.Name(),"Table")==0)
      {
         CElementBase *obj=elm_container.GetContainer();
         if(obj!=NULL && obj.Type()==ELEMENT_TYPE_TABLE_VIEW)
         {
            CTableView *table_view=obj;
            table_header=table_view.GetRowsHeader();
            // --- Move the title
            if(table_header!=NULL)
               res &=table_header.MoveY(this.Y()-content_offset);
         }
      }

   // --- Return the result of shifting the content by the calculated amount
      res &=elm.MoveY(this.Y()-content_offset);
      return res;
  }
 #endif // MOVE_FROM_CCONTAINER_CLASS__
 

 #ifndef __MOVE_FROM_CTABLECELLVIEW_CLASS__
 #define __MOVE_FROM_CTABLECELLVIEW_CLASS__
  //+------------------------------------------------------------------+
  //| CTableCellView::Returns canvas offset X                          |
  //+------------------------------------------------------------------+
  int CTableCellView::CanvasOffsetX(void) const
   {
     return(this.m_element_base.ObjectX()-this.m_element_base.X());
   }
  //+------------------------------------------------------------------+
  //| CTableCellView::Returns canvas offset Y                          |
  //+------------------------------------------------------------------+
  int CTableCellView::CanvasOffsetY(void) const
   {
      return(this.m_element_base.ObjectY()-this.m_element_base.Y());
   }
  //+------------------------------------------------------------------+
  //| CTableCellView::Returns container limit left                     |
  //+------------------------------------------------------------------+
  int CTableCellView::ContainerLimitLeft(void) const
   {
      return(this.m_element_base==NULL ? this.X() : this.m_element_base.LimitLeft());
   }
  //+------------------------------------------------------------------+
  //| CTableCellView::Returns container limit right                    |
  //+------------------------------------------------------------------+
  int CTableCellView::ContainerLimitRight(void) const
   {
      return(this.m_element_base==NULL ? this.Right() : this.m_element_base.LimitRight());
   }
  //+------------------------------------------------------------------+
  //| CTableCellView::Returns container limit top                      |
  //+------------------------------------------------------------------+
  int CTableCellView::ContainerLimitTop(void) const
   {
      return(this.m_element_base==NULL ? this.Y() : this.m_element_base.LimitTop());
      }
      //+------------------------------------------------------------------+
      //| CTableCellView::Returns container limit bottom                   |
      //+------------------------------------------------------------------+
      int CTableCellView::ContainerLimitBottom(void) const
      {
      return(this.m_element_base==NULL ? this.Bottom() : this.m_element_base.LimitBottom());
   }
  //+------------------------------------------------------------------+
  //| CTableCellView::Assigns row, background and foreground canvases  |
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
  //| CTableCellView::Returns pointer to the table row panel container |
  //+------------------------------------------------------------------+
  CContainer *CTableCellView::GetRowsPanelContainer(void)
   {
      if(this.m_element_base==NULL)
         return NULL;
      CPanel *rows_area=this.m_element_base.GetContainer();
      if(rows_area==NULL)
         return NULL;
      return rows_area.GetContainer();
   }
  //+------------------------------------------------------------------+
  //| CTableCellView::Returns flag that object is outside container    |
  //+------------------------------------------------------------------+
  bool CTableCellView::IsOutOfContainer(void)
   {
      if(this.m_element_base==NULL)
         return false;
      CContainer *container=this.GetRowsPanelContainer();
      if(container==NULL)
         return false;
      int cell_l=this.m_element_base.X()+this.X();
      int cell_r=this.m_element_base.X()+this.Right();
      int cell_t=this.m_element_base.Y()+this.Y();
      int cell_b=this.m_element_base.Y()+this.Bottom();
      return(cell_r<=container.X() || cell_l>=container.Right() || cell_b<=container.Y() || cell_t>=container.Bottom());
   }
  //+------------------------------------------------------------------+
  //| CTableCellView::Fills object with color                          |
  //+------------------------------------------------------------------+
  void CTableCellView::Clear(const bool chart_redraw)
   {
      int x1=this.AdjX(this.m_bound.X());
      int y1=this.AdjY(this.m_bound.Y());
      int x2=this.AdjX(this.m_bound.Right());
      int y2=this.AdjY(this.m_bound.Bottom());
      if(this.m_background!=NULL)
         this.m_background.FillRectangle(x1,y1,x2,y2-1,::ColorToARGB(this.m_element_base.BackColor(),this.m_element_base.AlphaBG()));
      if(this.m_foreground!=NULL)
         this.m_foreground.FillRectangle(x1,y1,x2,y2-1,clrNULL);
   }
  //+------------------------------------------------------------------+
  //| CTableCellView::Draws appearance                                 |
  //+------------------------------------------------------------------+
  void CTableCellView::Draw(const bool chart_redraw)
   {
      if(this.IsOutOfContainer())
         return;
      int text_x=0, text_y=0;
      int dir_horz=0, dir_vert=0;
      if(!this.GetTextCoordsByAnchor(text_x,text_y,dir_horz,dir_vert))
         return;
      int x=this.AdjX(this.X()+text_x);
      int y=this.AdjY(this.Y()+text_y);
      int x1=this.AdjX(this.X());
      int y1=this.AdjY(this.Y());
      int x2=this.AdjX(this.X());
      int y2=this.AdjY(this.Bottom());
      this.DrawText(x+this.m_text_x*dir_horz,y+this.m_text_y*dir_vert,this.Text(),false);
      x1=this.AdjX(this.X());
      y1=this.AdjY(this.Y());
      x2=this.AdjX(this.Right());
      y2=this.AdjY(this.Bottom()-1);
      this.m_background.FillRectangle(x1,y1,x2,y2,::ColorToARGB(this.BackColor(),this.m_element_base.AlphaBG()));
      if(this.m_element_base!=NULL && this.Index()<this.m_element_base.CellsTotal()-1)
      {
         int line_x=this.AdjX(this.Right());
         this.m_background.Line(line_x,y1,line_x,y2,::ColorToARGB(this.m_element_base.BorderColor(),this.m_element_base.AlphaBG()));
      }
      this.m_background.Update(chart_redraw);
   }
  //+------------------------------------------------------------------+
  //| CTableCellView::Displays text                                    |
  //+------------------------------------------------------------------+
  void CTableCellView::DrawText(const int dx,const int dy,const string text,const bool chart_redraw)
   {
      if(this.m_element_base==NULL)
         return;
      this.Clear(false);
      this.SetText(text);
      this.m_foreground.TextOut(dx,dy,this.Text(),::ColorToARGB(this.ForeColor(),this.m_element_base.AlphaFG()));
      if(this.Right()-dx<this.m_foreground.TextWidth(text))
      {
         int w=0,h=0;
         this.m_foreground.TextSize("... ",w,h);
         if(w>0 && h>0)
         {
            this.m_foreground.FillRectangle(this.AdjX(this.Right())-w,this.AdjY(this.Y()),this.AdjX(this.Right()),this.AdjY(this.Y())+h,clrNULL);
            this.m_foreground.TextOut(this.AdjX(this.Right())-w,this.AdjY(dy),"...",::ColorToARGB(this.ForeColor(),this.m_element_base.AlphaFG()));
         }
      }
      this.m_foreground.Update(chart_redraw);
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
 #endif // __MOVE_FROM_CTABLECELLVIEW_CLASS__
 

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
  
  