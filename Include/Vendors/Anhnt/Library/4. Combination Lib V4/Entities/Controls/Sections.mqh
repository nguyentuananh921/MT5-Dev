//+------------------------------------------------------------------+
//|                                                     Sections.mqh |
//| The sections of a tab of CTabs, one under the other: a header    |
//| (the blue arrow and the name) that opens and closes its body, the|
//| toggles (a flag icon and the switch) at the right of the header, and   |
//| the controls of the body in columns and rows (a check box, or any|
//| control the owner made). A control may belong to a header of the |
//| body (a type): it shows only while that header is open. A section that is  |
//| closed takes its header only, the ones under it move up. The     |
//| scroll moves them when they are taller than the tab. The owner   |
//| asks what was clicked (SectionOfToggle, BodyOf) and writes what  |
//| the model holds into the controls (SetToggle, SetBodyState)      |
//+------------------------------------------------------------------+
#ifndef CSECTIONS_MQH
#define CSECTIONS_MQH
 #include "Tabs.mqh"
 #include "CheckBox.mqh"
 #include "Scrolls\ScrollV.mqh"
#ifndef CSECTIONS_MQH_DECLARATION
#define CSECTIONS_MQH_DECLARATION
 class CSections
  {
   private:
    CTabs            *m_tabs;                 // Not owned: the tabs the sections are in, the tab shows and hides them with its other children (the tab frees them)
    int               m_tab;                  // the tab of m_tabs the sections are in
    long              m_chart_id;
    int               m_subwindow;
    string            m_name;                 // the start of the name of every control
    CScrollV          m_scroll;               // a child of the tab: its size and place come with the sections
    CButtonTriggered *m_header[];             // the arrow and the name: opens and closes the body below
    CButtonTriggered *m_toggle[];             // the switches at the right of the header: m_toggle_total for each section, one after the other
    int               m_rows[];               // the rows of the body of each section
    CGElement        *m_body[];               // the controls of the bodies of every section (not owned: the tab frees them)
    int               m_body_section[];       // the section of each, its column, its row, what it stands for (value) and which one of that value (slot): the owner gives them
    int               m_body_column[];
    int               m_body_row[];
    long              m_body_value[];
    int               m_body_slot[];
    int               m_column_x[];           // the x of each column in the body (empty: M_SECTION_COLUMN_WIDTH each)
    int               m_top_offset;           // how far under the top of the tab the sections start (the owner has controls above them)
    int               m_toggle_x[];           // the x of each toggle of a header, from the indent of the body (the count of them is the number of toggles of a header)
    int               m_toggle_total;
    string            m_body_param[];         // the name of the parameter a control edits (empty: none)
    bool              m_body_header[];        // it opens and closes the controls that belong to its value
    bool              m_body_owned[];         // it belongs to the header of its value: it shows only while that header is open
    bool              IsHeaderOpen(const long value) const;
    int               VisibleRows(const int section,int &offset[]) const;
   public:
   //--- No border, only the colour of the hover and of the press: for the controls the owner makes and adds (call it after Create)
    void              StyleSwitch(CButton *button);
   //--- A switch with no text: the icon of the flag it stands for at the left, then the switch (red OFF, green ON). Call it before Create
    void              FlagSwitch(CButtonTriggered *button,const uint flag_icon);
                      CSections(void) : m_tabs(NULL),m_tab(WRONG_VALUE),m_chart_id(0),m_subwindow(0),m_name(""),m_top_offset(0),m_toggle_total(0) {}
                     ~CSections(void) {}
   //--- The x of each column of the bodies, from the indent
    void              SetColumns(const int &x[])  { ::ArrayCopy(m_column_x,x); }
   //--- The toggles of a header and where each stands (the x from the indent of the body, as the columns): over the columns it rules. Call it before AddSection
    void              SetToggleColumns(const int &x[])                       { ::ArrayCopy(m_toggle_x,x); m_toggle_total=::ArraySize(m_toggle_x); }
   //--- The sections start this far under the top of the tab
    void              SetTopOffset(const int offset)                          { m_top_offset=offset; }
   //--- The controls of the body of a section go (freed), its rows are none: the owner makes them again
    void              ClearBody(const int section);
   //--- The scroll, in the tab of the tabs
    bool              Create(const long chart_id,const int subwin,CTabs *tabs,const int tab,const string name);
   //--- A section: its header and its toggles (the flag icon and the state of each). Returns its index, WRONG_VALUE when it is not made
    int               AddSection(const string text,const uint &icons[],const bool &states[],const bool opened);
   //--- A toggle of the header: its switch with the flag icon, made and registered in the tab
    CButtonTriggered *NewToggle_Sections(const string name,const uint flag_icon,const bool on);
   //--- A check box in the body of a section, in a column (0 or 1) and a row. The value says what it stands for
    bool              AddCheckBox(const int section,const string text,const bool state,const int column,const int row,const long value,const int slot,const bool owned=false);
   //--- Any control the owner made (registered in the tab and created, at 0,0): the header opens and closes the controls that are owned by its value
    bool              AddControl(const int section,CGElement *control,const int column,const int row,const long value,const int slot,const string param="",const bool header=false,const bool owned=false);
   //--- The sections one under the other from the top of the tab, moved up by the scroll: what is out of the tab is hidden
    void              Arrange(void);
   //--- The tab was opened, the scroll moved, a window changed its size, a header was clicked: the sections are arranged again
    bool              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- What was clicked: the section of a toggle (WRONG_VALUE when it is none), and the value and the column of a check box of the bodies
    int               SectionOfToggle(const long object_id,int &which) const;
    int               SectionOfHeader(const long object_id) const;
    bool              BodyOf(const long object_id,long &value,int &slot,string &param) const;
   //--- What the model holds goes into the controls
    void              SetToggle(const int section,const int which,const bool on);
    void              SetBodyState(const long value,const int slot,const bool on);
    int               SectionsTotal(void) const { return ::ArraySize(m_header); }
   //--- The rows of the body of a section (0: its body is not made yet, the owner may make it when it is opened)
    int               RowsTotal(const int section) const { return (section>=0 && section<::ArraySize(m_rows) ? m_rows[section] : 0); }
  };
#endif // CSECTIONS_MQH_DECLARATION

#ifndef CSECTIONS_MQH_IMPLEMENTATION
#define CSECTIONS_MQH_IMPLEMENTATION
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
   this.FlagSwitch(toggle,flag_icon);
   toggle.SetState(on);
   m_tabs.AddToElementsArray(m_tab,toggle);
   if(!toggle.Create(m_chart_id,m_subwindow,name,0,0,M_SECTION_TOGGLE_WIDTH,M_CONTROL_HEIGHT))
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
 //+------------------------------------------------------------------+
 //| The header (the arrow and the name) and its two toggles          |
 //+------------------------------------------------------------------+
 int CSections::AddSection(const string text,const uint &icons[],const bool &states[],const bool opened)
  {
   if(m_tabs==NULL || ::ArraySize(icons)<m_toggle_total || ::ArraySize(states)<m_toggle_total)
      return WRONG_VALUE;
   int section=::ArraySize(m_header);
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
   if(!header.Create(m_chart_id,m_subwindow,m_name+"_Header"+(string)section,0,0,M_SECTION_HEADER_WIDTH,M_CONTROL_HEIGHT))
      return WRONG_VALUE;
   this.StyleSwitch(header);
   ::ArrayResize(m_toggle,(section+1)*m_toggle_total);
   for(int k=0;k<m_toggle_total;k++)
     {
      CButtonTriggered *toggle=this.NewToggle_Sections(m_name+"_Toggle"+(string)section+"_"+(string)k,icons[k],states[k]);
      if(toggle==NULL)
         return WRONG_VALUE;
      m_toggle[section*m_toggle_total+k]=toggle;
     }
   ::ArrayResize(m_header,section+1);
   ::ArrayResize(m_rows,section+1);
   m_header[section]=header;
   m_rows[section]=0;
   return section;
  }
 bool CSections::AddCheckBox(const int section,const string text,const bool state,const int column,const int row,const long value,const int slot,const bool owned=false)
  {
   if(m_tabs==NULL || section<0 || section>=::ArraySize(m_header))
      return false;
   CCheckBox *box=new CCheckBox();
   if(box==NULL)
      return false;
   box.SetText(text);
   box.SetState(state);
   m_tabs.AddToElementsArray(m_tab,box);
   if(!box.Create(m_chart_id,m_subwindow,m_name+"_Body"+(string)::ArraySize(m_body),0,0,M_SECTION_COLUMN_WIDTH-M_CONTROL_BORDER_GAP,M_CONTROL_HEIGHT))
      return false;
   return this.AddControl(section,box,column,row,value,slot,"",false,owned);
  }
 bool CSections::AddControl(const int section,CGElement *control,const int column,const int row,const long value,const int slot,const string param="",const bool header=false,const bool owned=false)
  {
   if(control==NULL || section<0 || section>=::ArraySize(m_header))
      return false;
   int n=::ArraySize(m_body);
   ::ArrayResize(m_body,n+1);
   ::ArrayResize(m_body_section,n+1);
   ::ArrayResize(m_body_column,n+1);
   ::ArrayResize(m_body_row,n+1);
   ::ArrayResize(m_body_value,n+1);
   ::ArrayResize(m_body_slot,n+1);
   ::ArrayResize(m_body_param,n+1);
   ::ArrayResize(m_body_header,n+1);
   ::ArrayResize(m_body_owned,n+1);
   m_body[n]=control;
   m_body_section[n]=section;
   m_body_column[n]=column;
   m_body_row[n]=row;
   m_body_value[n]=value;
   m_body_slot[n]=slot;
   m_body_param[n]=param;
   m_body_header[n]=header;
   m_body_owned[n]=owned;
   if(row+1>m_rows[section])
      m_rows[section]=row+1;
   return true;
  }
 //+------------------------------------------------------------------+
 //| Is the header of this value open (a value with no header: yes)    |
 //+------------------------------------------------------------------+
 bool CSections::IsHeaderOpen(const long value) const
  {
   for(int i=0;i<::ArraySize(m_body);i++)
      if(m_body_header[i] && m_body_value[i]==value)
         return m_body[i].State();
   return true;
  }
 //+------------------------------------------------------------------+
 //| The rows of a section that show now, and for each row how many   |
 //| rows that show are above it (a row whose controls all wait for a |
 //| closed header takes no room). Returns the number of rows         |
 //+------------------------------------------------------------------+
 int CSections::VisibleRows(const int section,int &offset[]) const
  {
   const int rows=m_rows[section];
   bool shown[];
   ::ArrayResize(shown,rows);
   ::ArrayInitialize(shown,false);
   for(int i=0;i<::ArraySize(m_body);i++)
      if(m_body_section[i]==section && (!m_body_owned[i] || this.IsHeaderOpen(m_body_value[i])))
         shown[m_body_row[i]]=true;
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
   const int x=m_tabs.X()+M_CONTROL_BORDER_GAP;
   const int top=m_tabs.Y()+M_CONTROL_BORDER_GAP+m_top_offset;
   const int bottom=m_tabs.Y()+m_tabs.Height()-M_CONTROL_BORDER_GAP;
   const int total=::ArraySize(m_header);
   //--- The height of all the sections: the scroll gets it in rows
   int total_h=M_CONTROL_BORDER_GAP;
   for(int s=0;s<total;s++)
     {
      total_h+=M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
      if(m_header[s].State())
        {
         int offset[];
         total_h+=this.VisibleRows(s,offset)*M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
        }
     }
   m_scroll.ChangeYSize(::MathMax(bottom-top-M_CONTROL_BORDER_GAP,1));
   m_scroll.Move(m_tabs.X()+m_tabs.Width()-m_scroll.ScrollWidth()-1,top+1);
   m_scroll.ChangeThumbSize((total_h+M_CONTROL_HEIGHT-1)/M_CONTROL_HEIGHT,::MathMax((bottom-top)/M_CONTROL_HEIGHT,1));
   if(m_scroll.IsScroll())
      m_scroll.Show();
   else
      m_scroll.Hide();
   int y=top+M_CONTROL_BORDER_GAP-m_scroll.CurrentPos()*M_CONTROL_HEIGHT;
   for(int s=0;s<total;s++)
     {
      bool in_view=(y>=top && y+M_CONTROL_HEIGHT<=bottom);
      m_header[s].Move(x,y);
      for(int k=0;k<m_toggle_total;k++)
        {
         CButtonTriggered *toggle=m_toggle[s*m_toggle_total+k];
         toggle.Move(x+M_SECTION_BODY_INDENT+m_toggle_x[k],y);
         if(in_view)
            toggle.Show();
         else
            toggle.Hide();
        }
      if(in_view)
         m_header[s].Show();
      else
         m_header[s].Hide();
      y+=M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
      bool opened=m_header[s].State();
      int offset[];
      int visible=this.VisibleRows(s,offset);
      for(int i=0;i<::ArraySize(m_body);i++)
        {
         if(m_body_section[i]!=s)
            continue;
         int yc=y+offset[m_body_row[i]]*M_CONTROL_HEIGHT;
         bool waits=(m_body_owned[i] && !this.IsHeaderOpen(m_body_value[i]));
         if(opened && !waits && yc>=top && yc+M_CONTROL_HEIGHT<=bottom)
           {
            bool was_hidden=!m_body[i].IsVisible();
            m_body[i].Move(x+M_SECTION_BODY_INDENT+(m_body_column[i]<::ArraySize(m_column_x) ? m_column_x[m_body_column[i]] : m_body_column[i]*M_SECTION_COLUMN_WIDTH),yc);
            m_body[i].Show();
            if(was_hidden)
               m_body[i].Draw(false);   // what was hidden is drawn now: a label shows with the box next to it
           }
         else
            m_body[i].Hide();
        }
      if(opened)
         y+=visible*M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
     }
   ::ChartRedraw(m_chart_id);
  }
 //+------------------------------------------------------------------+
 //| The controls of the body of a section are freed and leave the tab |
 //+------------------------------------------------------------------+
 void CSections::ClearBody(const int section)
  {
   if(m_tabs==NULL || section<0 || section>=::ArraySize(m_header))
      return;
   for(int i=::ArraySize(m_body)-1;i>=0;i--)
     {
      if(m_body_section[i]!=section)
         continue;
      CGElement *control=m_body[i];
      m_tabs.RemoveFromElementsArray(m_tab,control);
      delete control;
      const int last=::ArraySize(m_body)-1;
      for(int k=i;k<last;k++)
        {
         m_body[k]=m_body[k+1];
         m_body_section[k]=m_body_section[k+1];
         m_body_column[k]=m_body_column[k+1];
         m_body_row[k]=m_body_row[k+1];
         m_body_value[k]=m_body_value[k+1];
         m_body_slot[k]=m_body_slot[k+1];
         m_body_param[k]=m_body_param[k+1];
         m_body_header[k]=m_body_header[k+1];
         m_body_owned[k]=m_body_owned[k+1];
        }
      ::ArrayResize(m_body,last);
      ::ArrayResize(m_body_section,last);
      ::ArrayResize(m_body_column,last);
      ::ArrayResize(m_body_row,last);
      ::ArrayResize(m_body_value,last);
      ::ArrayResize(m_body_slot,last);
      ::ArrayResize(m_body_param,last);
      ::ArrayResize(m_body_header,last);
      ::ArrayResize(m_body_owned,last);
     }
   m_rows[section]=0;
  }
 bool CSections::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(m_tabs==NULL)
      return false;
   //--- The tab was opened: it showed its children, the closed sections hide their bodies again. The scroll moved, or a window changed its size
   if((id==CHARTEVENT_CUSTOM+CLICK_EVENT_TAB && lparam==m_tabs.ObjectID()) ||
      (id==CHARTEVENT_CUSTOM+CHANGE_EVENT_SCROLL && lparam==m_scroll.ObjectID()) ||
      id==CHARTEVENT_CUSTOM+WINDOW_EVENT_CHANGE_XSIZE || id==CHARTEVENT_CUSTOM+WINDOW_EVENT_CHANGE_YSIZE)
     {
      this.Arrange();
      return true;
     }
   //--- A header: its body opens or closes and the sections under it move
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON)
      for(int s=0;s<::ArraySize(m_header);s++)
         if(lparam==m_header[s].ObjectID())
           {
            this.Arrange();
            return true;
           }
   //--- The header of a type: the controls of the type open or close
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON)
      for(int i=0;i<::ArraySize(m_body);i++)
         if(m_body_header[i] && lparam==m_body[i].ObjectID())
           {
            this.Arrange();
            return true;
           }
   return false;
  }
 int CSections::SectionOfToggle(const long object_id,int &which) const
  {
   for(int i=0;i<::ArraySize(m_toggle);i++)
      if(m_toggle[i].ObjectID()==object_id)
        {
         which=i%m_toggle_total;
         return i/m_toggle_total;
        }
   return WRONG_VALUE;
  }
 int CSections::SectionOfHeader(const long object_id) const
  {
   for(int s=0;s<::ArraySize(m_header);s++)
      if(m_header[s].ObjectID()==object_id)
         return s;
   return WRONG_VALUE;
  }
 bool CSections::BodyOf(const long object_id,long &value,int &slot,string &param) const
  {
   for(int i=0;i<::ArraySize(m_body);i++)
      if(m_body[i].ObjectID()==object_id)
        {
         value=m_body_value[i];
         slot=m_body_slot[i];
         param=m_body_param[i];
         return true;
        }
   return false;
  }
 void CSections::SetToggle(const int section,const int which,const bool on)
  {
   if(section<0 || which<0 || which>=m_toggle_total || section*m_toggle_total+which>=::ArraySize(m_toggle))
      return;
   CButtonTriggered *toggle=m_toggle[section*m_toggle_total+which];
   toggle.SetState(on);
   toggle.Draw(true);
  }
 void CSections::SetBodyState(const long value,const int slot,const bool on)
  {
   for(int i=0;i<::ArraySize(m_body);i++)
      if(m_body_value[i]==value && m_body_slot[i]==slot)
        {
         m_body[i].SetState(on);
         m_body[i].Draw(true);
         return;
        }
  }
#endif // CSECTIONS_MQH_IMPLEMENTATION
#endif // CSECTIONS_MQH
