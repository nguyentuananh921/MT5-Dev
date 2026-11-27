//+------------------------------------------------------------------+
//|                                                     Sections.mqh |
//+------------------------------------------------------------------+
//--- Parent Child Structure: CSections > CSection (a header, its toggles) > CSectionRow (the controls of a row). A row comes or goes alone
//--- (AddControl, RemoveRows): the other rows are not made again. The controls are owned by the tab of CTabs (it shows, hides and frees them)
#ifndef CSECTIONS_MQH
#define CSECTIONS_MQH
 #include "Tabs.mqh"
 #include "CheckBox.mqh"
 #include "Scrolls\ScrollV.mqh"
#ifndef CSECTIONS_MQH_DECLARATION
#define CSECTIONS_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| A row of the body of a section: its controls                     |
 //+------------------------------------------------------------------+
 class CSectionRow : public CGBaseObj
  {
   public:
    int               m_row;                  // its place in the section, from 0
    CGElement        *m_control[];            // not owned: the tab frees them
    int               m_column[];             // the column of each, what it stands for (value), which one of that value (slot), the parameter it edits
    long              m_value[];
    int               m_slot[];
    string            m_param[];
    bool              m_header[];             // it opens and closes the controls that belong to its value
    bool              m_owned[];              // it belongs to the header of its value: it shows only while that header is open
    int               ControlsTotal(void) const { return ::ArraySize(m_control); }
    void              AddControl(CGElement *control,const int column,const long value,const int slot,const string param,const bool header,const bool owned);
    bool              HasValue(const long value) const;
                      CSectionRow(const int row) : m_row(row) {}
  };
 //+------------------------------------------------------------------+
 //| A section: its header, its toggles, its rows (children)          |
 //+------------------------------------------------------------------+
 class CSection : public CGBaseObj
  {
   public:
    CButtonTriggered *m_header;               // not owned: the arrow and the name, opens and closes the body below
    CButtonTriggered *m_toggle[];             // not owned: the switches at the right of the header
    int               RowsTotal(void);        // the last row + 1
    CSectionRow      *Row(const int row,const bool make);
                      CSection(void) : m_header(NULL) {}
  };
 //+------------------------------------------------------------------+
 //| The sections of a tab (children)                                 |
 //+------------------------------------------------------------------+
 class CSections : public CGBaseObj
  {
   private:
    CTabs            *m_tabs;                 // Not owned: the tabs the sections are in, the tab shows and hides them with its other children (the tab frees them)
    int               m_tab;                  // the tab of m_tabs the sections are in
    CScrollV          m_scroll;               // a child of the tab: its size and place come with the sections
    int               m_column_x[];           // the x of each column in the body (empty: M_SECTION_COLUMN_WIDTH each)
    int               m_top_offset;           // how far under the top of the tab the sections start (the owner has controls above them)
    int               m_left_offset;          // how far right of the left of the tab the sections start (two of them side by side)
    int               m_width;                // the width they take, the scroll at its right end (0: to the right of the tab)
    int               m_toggle_x[];           // the x of each toggle of a header, from the indent of the body (the count of them is the number of toggles of a header)
    int               m_toggle_total;
    int               m_header_width;         // the width of the header of the next AddSection with no toggle (M_SECTION_HEADER_WIDTH first)
    bool              m_nested;               // the first section holds the others: they show (indented) under its body only while it is open
    bool              m_accordion;            // nested: one section in the first one open at a time
    int               m_pin_x;                // the header of the first section stays on the first line at this x (WRONG_VALUE: not pinned); the rest scrolls under it
    int               m_controls_made;        // for the names of the check boxes
    CSection         *Section(const int section);
    bool              IsHeaderOpen(const long value);
    int               VisibleRows(CSection *section,int &offset[]);
    void              FreeControls(CSectionRow *row);
   public:
   //--- No border, only the colour of the hover and of the press: for the controls the owner makes and adds (call it after Create)
    void              StyleSwitch(CButton *button);
   //--- A switch with no text: the icon of the flag it stands for at the left, then the switch (red OFF, green ON). Call it before Create
    void              FlagSwitch(CButtonTriggered *button,const uint flag_icon);
                      CSections(void) : m_tabs(NULL),m_tab(WRONG_VALUE),m_top_offset(0),m_left_offset(0),m_width(0),m_toggle_total(0),m_header_width(M_SECTION_HEADER_WIDTH),m_nested(false),m_accordion(false),m_pin_x(WRONG_VALUE),m_controls_made(0) {}
                     ~CSections(void) {}
   //--- The x of each column of the bodies, from the indent
    void              SetColumns(const int &x[])  { ::ArrayCopy(m_column_x,x); }
   //--- The toggles of a header and where each stands (the x from the indent of the body, as the columns): over the columns it rules. Call it before AddSection
    void              SetToggleColumns(const int &x[])                       { ::ArrayCopy(m_toggle_x,x); m_toggle_total=::ArraySize(m_toggle_x); }
   //--- The sections start this far under the top of the tab
    void              SetTopOffset(const int offset)                          { m_top_offset=offset; }
   //--- The sections start this far right of the left of the tab and take this width (0: to the right of the tab): two of them side by side
    void              SetLeftOffset(const int offset)                         { m_left_offset=offset; }
    void              SetWidth(const int width)                               { m_width=width; }
   //--- New in V5: the width of the headers with no toggle of the next AddSection (the first header shares a row with the owner's buttons). Call it before AddSection
    void              SetHeaderWidth(const int width)                         { m_header_width=(width>0 ? width : M_SECTION_HEADER_WIDTH); }
   //--- New in V5: the first section holds the others (its header opens and closes them all, they are indented under its body)
    void              SetNested(const bool nested)                            { m_nested=nested; }
   //--- New in V5: nested, one section in the first one open at a time (opening one closes the others)
    void              SetAccordion(const bool accordion)                      { m_accordion=accordion; }
   //--- New in V5: the header of the first section stays on the first line at this x from the left offset (several sections share that line, as
   //--- the headers of a menu); the body and the other sections scroll under it from the left offset
    void              SetPinnedHeader(const int x)                            { m_pin_x=x; }
   //--- New in V5: a section opened or closed by the owner (one closes when another opens); then Arrange
    void              SetOpened(const int section,const bool opened);
    bool              IsOpened(const int section);
   //--- The rows of the body of a section go (their controls freed): the owner makes them again
    void              ClearBody(const int section);
   //--- The rows that hold a control of this value go (their controls freed), the rows under them move up: one template (one type) went
    void              RemoveRows(const long value);
   //--- The scroll, in the tab of the tabs
    bool              Create(const long chart_id,const int subwin,CTabs *tabs,const int tab,const string name);
   //--- A section: its header and its toggles (the flag icon and the state of each; icon 0: "ON" / "OFF" and the switch). Returns its index, WRONG_VALUE when it is not made
    int               AddSection(const string text,const uint &icons[],const bool &states[],const bool opened);
   //--- A toggle of the header: its switch with the flag icon, made and registered in the tab
    CButtonTriggered *NewToggle_Sections(const string name,const uint flag_icon,const bool on);
   //--- A check box in the body of a section, in a column (0 or 1) and a row. The value says what it stands for
    bool              AddCheckBox(const int section,const string text,const bool state,const int column,const int row,const long value,const int slot,const bool owned=false);
   //--- Any control the owner made (registered in the tab and created, at 0,0) in a row of a section (a new row when it has none): the header opens and closes
   //--- the controls that are owned by its value
    bool              AddControl(const int section,CGElement *control,const int column,const int row,const long value,const int slot,const string param="",const bool header=false,const bool owned=false);
   //--- The sections one under the other from the top of the tab, moved up by the scroll: what is out of the tab is hidden
    void              Arrange(void);
   //--- The tab was opened, the scroll moved, a window changed its size, a header was clicked: the sections are arranged again
    virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- What was clicked: the section of a toggle (WRONG_VALUE when it is none), and the value and the column of a check box of the bodies
    int               SectionOfToggle(const long object_id,int &which);
    int               SectionOfHeader(const long object_id);
    bool              BodyOf(const long object_id,long &value,int &slot,string &param);
   //--- What the model holds goes into the controls
    void              SetToggle(const int section,const int which,const bool on);
    void              SetBodyState(const long value,const int slot,const bool on);
   //--- The control of the bodies of this slot that edits this parameter (NULL: none): the owner puts the value of the model in it
    CGElement        *BodyControl(const int slot,const string param);
   //--- The name of a section on its header (what is chosen in it)
    void              SetHeaderText(const int section,const string text);
    int               SectionsTotal(void) const { return this.ChildrenTotal(); }
   //--- The rows of the body of a section (0: its body is not made yet, the owner may make it when it is opened)
    int               RowsTotal(const int section);
  };
#endif // CSECTIONS_MQH_DECLARATION

#ifndef CSECTIONS_MQH_IMPLEMENTATION
#define CSECTIONS_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| CSectionRow                                                      |
 //+------------------------------------------------------------------+
 void CSectionRow::AddControl(CGElement *control,const int column,const long value,const int slot,const string param,const bool header,const bool owned)
  {
   int n=::ArraySize(m_control);
   ::ArrayResize(m_control,n+1);
   ::ArrayResize(m_column,n+1);
   ::ArrayResize(m_value,n+1);
   ::ArrayResize(m_slot,n+1);
   ::ArrayResize(m_param,n+1);
   ::ArrayResize(m_header,n+1);
   ::ArrayResize(m_owned,n+1);
   m_control[n]=control;
   m_column[n]=column;
   m_value[n]=value;
   m_slot[n]=slot;
   m_param[n]=param;
   m_header[n]=header;
   m_owned[n]=owned;
  }
 bool CSectionRow::HasValue(const long value) const
  {
   for(int i=0;i<::ArraySize(m_value);i++)
      if(m_value[i]==value)
         return true;
   return false;
  }
 //+------------------------------------------------------------------+
 //| CSection                                                         |
 //+------------------------------------------------------------------+
 int CSection::RowsTotal(void)
  {
   int total=0;
   for(int i=0;i<this.ChildrenTotal();i++)
     {
      CSectionRow *row=dynamic_cast<CSectionRow *>(this.Child(i));
      if(row!=NULL && row.m_row+1>total)
         total=row.m_row+1;
     }
   return total;
  }
 CSectionRow *CSection::Row(const int row,const bool make)
  {
   for(int i=0;i<this.ChildrenTotal();i++)
     {
      CSectionRow *item=dynamic_cast<CSectionRow *>(this.Child(i));
      if(item!=NULL && item.m_row==row)
         return item;
     }
   if(!make)
      return NULL;
   CSectionRow *item=new CSectionRow(row);
   if(item==NULL || !this.AddChild(item))
     {
      delete item;
      return NULL;
     }
   return item;
  }
 //+------------------------------------------------------------------+
 //| No border, only the colour of the hover and of the press (set     |
 //| after Create: it gives the default ones)                          |
 //+------------------------------------------------------------------+
 void CSections::StyleSwitch(CButton *button)
  {
   button.GetBackColorControl().InitColors(clrNONE,C'229,241,251',C'204,228,247',clrNONE);
   button.GetBackColorActControl().InitColors(clrNONE,C'229,241,251',C'204,228,247',clrNONE);
   button.GetBorderColorControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
   button.GetBorderColorActControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
   button.ColorChange(COLOR_STATE_DEFAULT);
   button.Draw(false);
  }
 //+------------------------------------------------------------------+
 //| The icon of the flag at the left, the switch after it            |
 //+------------------------------------------------------------------+
 void CSections::FlagSwitch(CButtonTriggered *button,const uint flag_icon)
  {
   button.IconFile(IMAGE_RESOURCE_BMP16_SWITCH_OFF_RED_PNG);
   button.IconFileLocked(IMAGE_RESOURCE_BMP16_SWITCH_OFF_RED_PNG);
   button.IconFilePressed(IMAGE_RESOURCE_BMP16_SWITCH_ON_GREEN_PNG);
   button.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_SWITCH_ON_GREEN_PNG);
   button.IconXGap(M_FLAG_SWITCH_X);
   button.AddImagesGroup(0,(M_CONTROL_HEIGHT-16)/2);   // the second group of images: the flag, 16x16 centred in the height
   button.AddImage(1,flag_icon);
  }
 CButtonTriggered *CSections::NewToggle_Sections(const string name,const uint flag_icon,const bool on)
  {
   CButtonTriggered *toggle=new CButtonTriggered();
   if(toggle==NULL)
      return NULL;
   //--- Change in V5: flag_icon 0 = no flag, its state as text ("ON" / "OFF", CButtonTriggered::StateTexts) then the switch
   if(flag_icon==0)
     {
      toggle.IconFile(IMAGE_RESOURCE_BMP16_SWITCH_OFF_RED_PNG);
      toggle.IconFileLocked(IMAGE_RESOURCE_BMP16_SWITCH_OFF_RED_PNG);
      toggle.IconFilePressed(IMAGE_RESOURCE_BMP16_SWITCH_ON_GREEN_PNG);
      toggle.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_SWITCH_ON_GREEN_PNG);
      toggle.LabelXGap(0);
      toggle.IconXGap(M_SECTION_TEXT_TOGGLE_X);
      toggle.StateTexts("ON","OFF");
     }
   else
      this.FlagSwitch(toggle,flag_icon);
   toggle.SetState(on);
   m_tabs.AddToElementsArray(m_tab,toggle);
   if(!toggle.Create(m_chart_id,m_subwindow,name,0,0,(flag_icon==0 ? M_SECTION_TEXT_TOGGLE_WIDTH : M_SECTION_TOGGLE_WIDTH),M_CONTROL_HEIGHT))
      return NULL;
   this.StyleSwitch(toggle);
   return toggle;
  }
 bool CSections::Create(const long chart_id,const int subwin,CTabs *tabs,const int tab,const string name)
  {
   m_chart_id=chart_id;
   m_subwindow=subwin;
   m_tabs=tabs;
   m_tab=tab;
   m_name=name;
   m_tabs.AddToElementsArray(m_tab,m_scroll);
   return m_scroll.CreateScroll(m_chart_id,m_subwindow,m_name+"_Scroll",0,0,15,100,1,1);
  }
 CSection *CSections::Section(const int section)
  {
   return (section>=0 && section<this.ChildrenTotal() ? dynamic_cast<CSection *>(this.Child(section)) : NULL);
  }
 int CSections::RowsTotal(const int section)
  {
   CSection *item=this.Section(section);
   return (item!=NULL ? item.RowsTotal() : 0);
  }
 //+------------------------------------------------------------------+
 //| The header (the arrow and the name) and its toggles              |
 //+------------------------------------------------------------------+
 int CSections::AddSection(const string text,const uint &icons[],const bool &states[],const bool opened)
  {
   //--- Change in V5: a section may have fewer toggles (as many as its icons, none: empty arrays): the toggle of one section only
   const int toggles=::MathMin(::ArraySize(icons),m_toggle_total);
   if(m_tabs==NULL || ::ArraySize(states)<toggles)
      return WRONG_VALUE;
   int index=this.ChildrenTotal();
   CSection *section=new CSection();
   if(section==NULL)
      return WRONG_VALUE;
   if(!this.AddChild(section))
     {
      delete section;
      return WRONG_VALUE;
     }
   CButtonTriggered *header=new CButtonTriggered();
   if(header==NULL)
      return WRONG_VALUE;
   header.SetText(text);
   header.IconFile(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);
   header.IconFileLocked(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);
   header.IconFilePressed(IMAGE_RESOURCE_BMP16_ARROWDOWN_BLUE_BMP);
   header.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_ARROWDOWN_BLUE_BMP);
   header.SetState(opened);
   m_tabs.AddToElementsArray(m_tab,header);
   //--- Change in V5: the header ends where its first toggle starts (a click on the toggle does not open / close the section)
   int header_width=m_header_width;
   if(toggles>0)
      header_width=::MathMin(header_width,M_SECTION_BODY_INDENT+m_toggle_x[0]);
   if(!header.Create(m_chart_id,m_subwindow,m_name+"_Header"+(string)index,0,0,header_width,M_CONTROL_HEIGHT))
      return WRONG_VALUE;
   this.StyleSwitch(header);
   section.m_header=header;
   ::ArrayResize(section.m_toggle,toggles);
   for(int k=0;k<toggles;k++)
     {
      CButtonTriggered *toggle=this.NewToggle_Sections(m_name+"_Toggle"+(string)index+"_"+(string)k,icons[k],states[k]);
      if(toggle==NULL)
         return WRONG_VALUE;
      section.m_toggle[k]=toggle;
     }
   return index;
  }
 bool CSections::AddCheckBox(const int section,const string text,const bool state,const int column,const int row,const long value,const int slot,const bool owned=false)
  {
   if(m_tabs==NULL || this.Section(section)==NULL)
      return false;
   CCheckBox *box=new CCheckBox();
   if(box==NULL)
      return false;
   box.SetText(text);
   box.SetState(state);
   m_tabs.AddToElementsArray(m_tab,box);
   if(!box.Create(m_chart_id,m_subwindow,m_name+"_Body"+(string)(m_controls_made++),0,0,M_SECTION_COLUMN_WIDTH-M_CONTROL_BORDER_GAP,M_CONTROL_HEIGHT))
      return false;
   return this.AddControl(section,box,column,row,value,slot,"",false,owned);
  }
 bool CSections::AddControl(const int section,CGElement *control,const int column,const int row,const long value,const int slot,const string param="",const bool header=false,const bool owned=false)
  {
   CSection *item=this.Section(section);
   if(control==NULL || item==NULL)
      return false;
   CSectionRow *line=item.Row(row,true);
   if(line==NULL)
      return false;
   line.AddControl(control,column,value,slot,param,header,owned);
   return true;
  }
 //+------------------------------------------------------------------+
 //| The controls of a row leave the tab and are freed                |
 //+------------------------------------------------------------------+
 void CSections::FreeControls(CSectionRow *row)
  {
   for(int i=row.ControlsTotal()-1;i>=0;i--)
     {
      CGElement *control=row.m_control[i];
      if(control==NULL)
         continue;
      control.Hide();
      m_tabs.RemoveFromElementsArray(m_tab,control);
      delete control;
     }
   ::ArrayResize(row.m_control,0);
  }
 void CSections::ClearBody(const int section)
  {
   CSection *item=this.Section(section);
   if(m_tabs==NULL || item==NULL)
      return;
   for(int i=item.ChildrenTotal()-1;i>=0;i--)
     {
      CSectionRow *row=dynamic_cast<CSectionRow *>(item.Child(i));
      if(row==NULL)
         continue;
      this.FreeControls(row);
      item.DeleteChild(row);
      delete row;
     }
  }
 void CSections::RemoveRows(const long value)
  {
   if(m_tabs==NULL)
      return;
   for(int s=0;s<this.ChildrenTotal();s++)
     {
      CSection *item=this.Section(s);
      if(item==NULL)
         continue;
      int removed[];
      for(int i=item.ChildrenTotal()-1;i>=0;i--)
        {
         CSectionRow *row=dynamic_cast<CSectionRow *>(item.Child(i));
         if(row==NULL || !row.HasValue(value))
            continue;
         int n=::ArraySize(removed);
         ::ArrayResize(removed,n+1);
         removed[n]=row.m_row;
         this.FreeControls(row);
         item.DeleteChild(row);
         delete row;
        }
      //--- the rows under the ones that went move up
      for(int i=0;i<item.ChildrenTotal() && ::ArraySize(removed)>0;i++)
        {
         CSectionRow *row=dynamic_cast<CSectionRow *>(item.Child(i));
         if(row==NULL)
            continue;
         int below=0;
         for(int k=0;k<::ArraySize(removed);k++)
            if(removed[k]<row.m_row)
               below++;
         row.m_row-=below;
        }
     }
  }
 //+------------------------------------------------------------------+
 //| Is the header of this value open (a value with no header: yes)    |
 //+------------------------------------------------------------------+
 bool CSections::IsHeaderOpen(const long value)
  {
   for(int s=0;s<this.ChildrenTotal();s++)
     {
      CSection *item=this.Section(s);
      for(int r=0;item!=NULL && r<item.ChildrenTotal();r++)
        {
         CSectionRow *row=dynamic_cast<CSectionRow *>(item.Child(r));
         for(int i=0;row!=NULL && i<row.ControlsTotal();i++)
            if(row.m_header[i] && row.m_value[i]==value)
               return row.m_control[i].State();
        }
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| The rows of a section that show now, and for each row how many   |
 //| rows that show are above it (a row whose controls all wait for a |
 //| closed header takes no room). Returns the number of rows         |
 //+------------------------------------------------------------------+
 int CSections::VisibleRows(CSection *section,int &offset[])
  {
   const int rows=section.RowsTotal();
   bool shown[];
   ::ArrayResize(shown,rows);
   ::ArrayInitialize(shown,false);
   for(int r=0;r<section.ChildrenTotal();r++)
     {
      CSectionRow *row=dynamic_cast<CSectionRow *>(section.Child(r));
      for(int i=0;row!=NULL && i<row.ControlsTotal();i++)
         if(!row.m_owned[i] || this.IsHeaderOpen(row.m_value[i]))
            shown[row.m_row]=true;
     }
   ::ArrayResize(offset,rows);
   int count=0;
   for(int r=0;r<rows;r++)
     {
      offset[r]=count;
      if(shown[r])
         count++;
     }
   return count;
  }
 //+------------------------------------------------------------------+
 //| The sections one under the other, from the top of the tab, moved  |
 //| up by the scroll: a closed one takes its header only, what is out |
 //| of the tab is hidden                                              |
 //+------------------------------------------------------------------+
 void CSections::Arrange(void)
  {
   if(m_tabs==NULL || m_tabs.SelectedTab()!=m_tab || !m_tabs.IsVisible())
      return;   // another tab is open, or the window is hidden (born hidden: nothing is shown before it)
   const int x=m_tabs.X()+M_CONTROL_BORDER_GAP+m_left_offset;
   const int right=(m_width>0 ? x+m_width : m_tabs.X()+m_tabs.Width()-1);
   const int line=m_tabs.Y()+M_CONTROL_BORDER_GAP+m_top_offset;   // the first line: a pinned header stays on it
   const bool pinned=(m_pin_x!=WRONG_VALUE);
   const int top=(pinned ? line+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP : line);   // what scrolls starts here
   const int bottom=m_tabs.Y()+m_tabs.Height()-M_CONTROL_BORDER_GAP;
   const int total=this.ChildrenTotal();
   //--- Nested: the first section holds the others, they show under its body (indented) only while it is open
   CSection *first=this.Section(0);
   const bool first_open=(first!=NULL && first.m_header.State());
   //--- Pinned: the header of the first section on the first line at its x, with its toggles; not scrolled
   if(pinned && first!=NULL)
     {
      first.m_header.Move(x+m_pin_x,line);
      if(!first.m_header.IsVisible())
         first.m_header.Show();
      for(int k=0;k<::ArraySize(first.m_toggle);k++)
        {
         first.m_toggle[k].Move(x+m_pin_x+M_SECTION_BODY_INDENT+m_toggle_x[k],line);
         if(!first.m_toggle[k].IsVisible())
            first.m_toggle[k].Show();
        }
     }
   //--- The height of all the sections: the scroll gets it in rows
   int total_h=M_CONTROL_BORDER_GAP;
   for(int s=0;s<total;s++)
     {
      CSection *item=this.Section(s);
      if(m_nested && s>0 && !first_open)
         continue;
      if(!(pinned && s==0))
         total_h+=M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
      if(item!=NULL && item.m_header.State())
        {
         int offset[];
         total_h+=this.VisibleRows(item,offset)*M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
        }
     }
   m_scroll.ChangeYSize(::MathMax(bottom-top-M_CONTROL_BORDER_GAP,1));
   m_scroll.Move(right-m_scroll.ScrollWidth(),top+1);
   m_scroll.ChangeThumbSize((total_h+M_CONTROL_HEIGHT-1)/M_CONTROL_HEIGHT,::MathMax((bottom-top)/M_CONTROL_HEIGHT,1));
   if(m_scroll.IsScroll())
      m_scroll.Show();
   else
      m_scroll.Hide();
   int y=top+M_CONTROL_BORDER_GAP-m_scroll.CurrentPos()*M_CONTROL_HEIGHT;
   for(int s=0;s<total;s++)
     {
      CSection *item=this.Section(s);
      if(item==NULL)
         continue;
      const bool folded=(m_nested && s>0 && !first_open);   // in the first one, closed: hidden, takes no room
      const bool pin_head=(pinned && s==0);                  // placed above, on the first line
      const int sx=x+(m_nested && s>0 ? M_SECTION_BODY_INDENT : 0);
      bool in_view=(!folded && y>=top && y+M_CONTROL_HEIGHT<=bottom);
      for(int k=0;k<::ArraySize(item.m_toggle) && !pin_head;k++)
        {
         CButtonTriggered *toggle=item.m_toggle[k];
         toggle.Move(sx+M_SECTION_BODY_INDENT+m_toggle_x[k],y);
         if(in_view && !toggle.IsVisible())
            toggle.Show();
         else if(!in_view && toggle.IsVisible())
            toggle.Hide();
        }
      if(!pin_head)
        {
         item.m_header.Move(sx,y);
         if(in_view && !item.m_header.IsVisible())
            item.m_header.Show();
         else if(!in_view && item.m_header.IsVisible())
            item.m_header.Hide();
        }
      if(!folded && !pin_head)
         y+=M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
      bool opened=(!folded && item.m_header.State());
      int offset[];
      int visible=this.VisibleRows(item,offset);
      for(int r=0;r<item.ChildrenTotal();r++)
        {
         CSectionRow *row=dynamic_cast<CSectionRow *>(item.Child(r));
         if(row==NULL)
            continue;
         int yc=y+offset[row.m_row]*M_CONTROL_HEIGHT;
         for(int i=0;i<row.ControlsTotal();i++)
           {
            CGElement *control=row.m_control[i];
            bool waits=(row.m_owned[i] && !this.IsHeaderOpen(row.m_value[i]));
            if(opened && !waits && yc>=top && yc+M_CONTROL_HEIGHT<=bottom)
              {
               int xc=sx+M_SECTION_BODY_INDENT+(row.m_column[i]<::ArraySize(m_column_x) ? m_column_x[row.m_column[i]] : row.m_column[i]*M_SECTION_COLUMN_WIDTH);
               if(control.X()!=xc || control.Y()!=yc)
                  control.Move(xc,yc);
               if(!control.IsVisible())
                 {
                  control.Show();
                  control.Draw(false);   // what was hidden is drawn now: a label shows with the box next to it
                 }
              }
            else if(control.IsVisible())
               control.Hide();
           }
        }
      if(opened)
         y+=visible*M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
     }
   ::ChartRedraw(m_chart_id);
  }
 void CSections::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(m_tabs==NULL)
      return;
   //--- The tab was opened: it showed its children, the closed sections hide their bodies again. The scroll moved, or a window changed its size
   if((id==CHARTEVENT_CUSTOM+CLICK_EVENT_TAB && lparam==m_tabs.ObjectID()) ||
      (id==CHARTEVENT_CUSTOM+CHANGE_EVENT_SCROLL && lparam==m_scroll.ObjectID()) ||
      id==CHARTEVENT_CUSTOM+WINDOW_EVENT_CHANGE_XSIZE || id==CHARTEVENT_CUSTOM+WINDOW_EVENT_CHANGE_YSIZE)
     {
      this.Arrange();
      return;
     }
   if(id!=CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON)
      return;
   //--- A header of a section, or the header of a type: its body opens or closes and the sections under it move. Accordion: a section in the
   //--- first one opened closes the other ones in it
   const int header=this.SectionOfHeader(lparam);
   if(header!=WRONG_VALUE)
     {
      if(m_accordion && m_nested && header>0 && this.IsOpened(header))
         for(int s=1;s<this.ChildrenTotal();s++)
            if(s!=header)
               this.SetOpened(s,false);
      this.Arrange();
      return;
     }
   for(int s=0;s<this.ChildrenTotal();s++)
     {
      CSection *item=this.Section(s);
      for(int r=0;item!=NULL && r<item.ChildrenTotal();r++)
        {
         CSectionRow *row=dynamic_cast<CSectionRow *>(item.Child(r));
         for(int i=0;row!=NULL && i<row.ControlsTotal();i++)
            if(row.m_header[i] && row.m_control[i].ObjectID()==lparam)
              {
               this.Arrange();
               return;
              }
        }
     }
  }
 int CSections::SectionOfToggle(const long object_id,int &which)
  {
   for(int s=0;s<this.ChildrenTotal();s++)
     {
      CSection *item=this.Section(s);
      for(int k=0;item!=NULL && k<::ArraySize(item.m_toggle);k++)
         if(item.m_toggle[k].ObjectID()==object_id)
           {
            which=k;
            return s;
           }
     }
   return WRONG_VALUE;
  }
 int CSections::SectionOfHeader(const long object_id)
  {
   for(int s=0;s<this.ChildrenTotal();s++)
     {
      CSection *item=this.Section(s);
      if(item!=NULL && item.m_header!=NULL && item.m_header.ObjectID()==object_id)
         return s;
     }
   return WRONG_VALUE;
  }
 bool CSections::BodyOf(const long object_id,long &value,int &slot,string &param)
  {
   for(int s=0;s<this.ChildrenTotal();s++)
     {
      CSection *item=this.Section(s);
      for(int r=0;item!=NULL && r<item.ChildrenTotal();r++)
        {
         CSectionRow *row=dynamic_cast<CSectionRow *>(item.Child(r));
         for(int i=0;row!=NULL && i<row.ControlsTotal();i++)
            if(row.m_control[i].ObjectID()==object_id)
              {
               value=row.m_value[i];
               slot=row.m_slot[i];
               param=row.m_param[i];
               return true;
              }
        }
     }
   return false;
  }
 void CSections::SetToggle(const int section,const int which,const bool on)
  {
   CSection *item=this.Section(section);
   if(item==NULL || which<0 || which>=::ArraySize(item.m_toggle))
      return;
   CButtonTriggered *toggle=item.m_toggle[which];
   toggle.SetState(on);
   toggle.Draw(true);
  }
 void CSections::SetBodyState(const long value,const int slot,const bool on)
  {
   for(int s=0;s<this.ChildrenTotal();s++)
     {
      CSection *item=this.Section(s);
      for(int r=0;item!=NULL && r<item.ChildrenTotal();r++)
        {
         CSectionRow *row=dynamic_cast<CSectionRow *>(item.Child(r));
         for(int i=0;row!=NULL && i<row.ControlsTotal();i++)
            if(row.m_value[i]==value && row.m_slot[i]==slot)
              {
               row.m_control[i].SetState(on);
               row.m_control[i].Draw(true);
               return;
              }
        }
     }
  }
 CGElement *CSections::BodyControl(const int slot,const string param)
  {
   for(int s=0;s<this.ChildrenTotal();s++)
     {
      CSection *item=this.Section(s);
      for(int r=0;item!=NULL && r<item.ChildrenTotal();r++)
        {
         CSectionRow *row=dynamic_cast<CSectionRow *>(item.Child(r));
         for(int i=0;row!=NULL && i<row.ControlsTotal();i++)
            if(row.m_slot[i]==slot && row.m_param[i]==param)
               return row.m_control[i];
        }
     }
   return NULL;
  }
 void CSections::SetOpened(const int section,const bool opened)
  {
   CSection *item=this.Section(section);
   if(item==NULL || item.m_header==NULL || item.m_header.State()==opened)
      return;
   item.m_header.SetState(opened);
   item.m_header.Draw(false);
  }
 bool CSections::IsOpened(const int section)
  {
   CSection *item=this.Section(section);
   return (item!=NULL && item.m_header!=NULL && item.m_header.State());
  }
 void CSections::SetHeaderText(const int section,const string text)
  {
   CSection *item=this.Section(section);
   if(item==NULL || item.m_header==NULL)
      return;
   item.m_header.SetText(text);
   item.m_header.Draw(true);
  }
#endif // CSECTIONS_MQH_IMPLEMENTATION
#endif // CSECTIONS_MQH
