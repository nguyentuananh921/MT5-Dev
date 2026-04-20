//+------------------------------------------------------------------+
//|                                               PicturesSlider.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "Picture.mqh"
#include "Button.mqh"
#include "ButtonsGroup.mqh"
// --- Default picture
#resource "\\Icons\\bmp64\\no_image.bmp"
//+------------------------------------------------------------------+
// | Class for creating an image slider |
//+------------------------------------------------------------------+
class CPicturesSlider : public CElement
  {
private:
   // --- Objects for creating an element
   CPicture          m_pictures[];
   CButtonsGroup     m_radio_buttons;
   CButton           m_left_arrow;
   CButton           m_right_arrow;
   // --- Array of pictures (path to pictures)
   string            m_file_path[];
   // --- Path to default image
   string            m_default_path;
   // --- Indent for pictures along the Y axis
   int               m_pictures_y_gap;
   // --- Padding for buttons
   int               m_arrows_x_gap;
   int               m_arrows_y_gap;
   // --- Radio button width
   int               m_radio_button_width;
   // --- Padding for radio buttons
   int               m_radio_buttons_x_gap;
   int               m_radio_buttons_y_gap;
   int               m_radio_buttons_x_offset;
   //---
public:
                     CPicturesSlider(void);
                    ~CPicturesSlider(void);
   // --- Methods for creating an image slider
   bool              CreatePicturesSlider(const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreatePictures(void);
   bool              CreateRadioButtons(void);
   bool              CreateArrow(CButton &button_obj,const int index);
   //---
public:
   // --- Returns pointers to constituent elements
   CButtonsGroup    *GetRadioButtonsPointer(void)            { return(::GetPointer(m_radio_buttons)); }
   CButton          *GetLeftArrowPointer(void)               { return(::GetPointer(m_left_arrow));    }
   CButton          *GetRightArrowPointer(void)              { return(::GetPointer(m_right_arrow));   }
   CPicture         *GetPicturePointer(const uint index);
   // --- Padding for arrow buttons
   void              ArrowsXGap(const int x_gap)             { m_arrows_x_gap=x_gap;                  }
   void              ArrowsYGap(const int y_gap)             { m_arrows_y_gap=y_gap;                  }
   // --- (1) Returns the number of pictures, (2) the Y-axis offset for pictures
   int               PicturesTotal(void)               const { return(::ArraySize(m_pictures));       }
   void              PictureYGap(const int y_gap)            { m_pictures_y_gap=y_gap;                }
   // --- (1) Radio button padding, (2) distance between radio buttons
   void              RadioButtonsXGap(const int x_gap)       { m_radio_buttons_x_gap=x_gap;           }
   void              RadioButtonsYGap(const int y_gap)       { m_radio_buttons_y_gap=y_gap;           }
   void              RadioButtonsXOffset(const int x_offset) { m_radio_buttons_x_offset=x_offset;     }
   // --- Adds a picture
   void              AddPicture(const string file_path="");
   // --- Switches the image at the specified index
   void              SelectPicture(const int index);
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // --- Show, delete
   virtual void      Show(void);
   virtual void      Delete(void);
   // --- Draws an element
   virtual void      Draw(void);
   //---
private:
   // --- Handling a click on a radio button
   bool              OnClickRadioButton(const string clicked_object,const int id,const int index);
   // --- Handling clicks on the left button
   bool              OnClickLeftArrow(const string clicked_object,const int id,const int index);
   // --- Handling clicks on the right button
   bool              OnClickRightArrow(const string clicked_object,const int id,const int index);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPicturesSlider::CPicturesSlider(void) : m_default_path("Images\\EasyAndFastGUI\\Icons\\bmp64\\no_image.bmp"),
                                         m_arrows_x_gap(2),
                                         m_arrows_y_gap(2),
                                         m_radio_button_width(18),
                                         m_radio_buttons_x_gap(25),
                                         m_radio_buttons_y_gap(1),
                                         m_radio_buttons_x_offset(20),
                                         m_pictures_y_gap(25)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPicturesSlider::~CPicturesSlider(void)
  {
  }
//+------------------------------------------------------------------+
// | Event Handler |
//+------------------------------------------------------------------+
void CPicturesSlider::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handling the event of pressing the left mouse button on an object
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      // --- Pressing the radio button
      if(OnClickRadioButton(sparam,(int)lparam,(int)dparam))
         return;
      // --- If you click on the slider arrow buttons, switch the picture
      if(OnClickLeftArrow(sparam,(int)lparam,(int)dparam))
         return;
      if(OnClickRightArrow(sparam,(int)lparam,(int)dparam))
         return;
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
// | Creates an element |
//+------------------------------------------------------------------+
bool CPicturesSlider::CreatePicturesSlider(const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// ---Initializing properties
   InitializeProperties(x_gap,y_gap);
// ---Creating an element
   if(!CreateCanvas())
      return(false);
   if(!CreatePictures())
      return(false);
   if(!CreateRadioButtons())
      return(false);
   if(!CreateArrow(m_left_arrow,0))
      return(false);
   if(!CreateArrow(m_right_arrow,1))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CPicturesSlider::InitializeProperties(const int x_gap,const int y_gap)
  {
   m_x      =CElement::CalculateX(x_gap);
   m_y      =CElement::CalculateY(y_gap);
   m_x_size =(m_x_size<1)? 300 : m_x_size;
   m_y_size =(m_y_size<1)? 300 : m_y_size;
// ---Default properties
   m_back_color   =(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
   m_border_color =(m_border_color!=clrNONE)? m_border_color : m_main.BackColor();
// --- Indents from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
// | Creates an object to draw |
//+------------------------------------------------------------------+
bool CPicturesSlider::CreateCanvas(void)
  {
// --- Formation of object name
   string name=CElementBase::ElementName("pictures_slider");
// ---Create an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a group of pictures |
//+------------------------------------------------------------------+
bool CPicturesSlider::CreatePictures(void)
  {
// --- Get the number of pictures
   int pictures_total=PicturesTotal();
// --- If there are no pictures in the group, report it
   if(pictures_total<1)
     {
      ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, "
              "когда в группе есть хотя бы одна картинка! Воспользуйтесь методом CPicturesSlider::AddPicture()");
      return(false);
     }
// --- Coordinates
   uint x=0,y=m_pictures_y_gap;
// --- Dimensions
   uint x_size=0,y_size=0;
// --- Array for image
   uint image_data[];
//---
   for(int i=0; i<pictures_total; i++)
     {
      // --- Save the pointer to the window
      m_pictures[i].MainPointer(this);
      // --- Read image data
      if(!::ResourceReadImage("::"+m_file_path[i],image_data,x_size,y_size))
        {
         ::Print(__FUNCTION__," > Ошибка при чтении изображения ("+m_file_path[i]+"): ",::GetLastError());
         return(false);
        }
      // --- Calculate indentation
      x=(m_x_size>>1)-(x_size>>1);
      // --- Properties
      m_pictures[i].Index(i);
      m_pictures[i].XSize(x_size);
      m_pictures[i].YSize(y_size);
      m_pictures[i].NamePart("picture_slider");
      m_pictures[i].IconFile(m_file_path[i]);
      m_pictures[i].IconFileLocked(m_file_path[i]);
      // --- Creating a button
      if(!m_pictures[i].CreatePicture(x,y))
         return(false);
      // --- Add element to array
      CElement::AddToArray(m_pictures[i]);
     }
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a group of radio buttons |
//+------------------------------------------------------------------+
bool CPicturesSlider::CreateRadioButtons(void)
  {
// --- Save a pointer to the parent element
   m_radio_buttons.MainPointer(this);
// ---Coordinates
   int x=m_radio_buttons_x_gap,y=m_radio_buttons_y_gap;
// --- Number of pictures
   int pictures_total=PicturesTotal();
// --- Properties
   int buttons_x_offset[];
// --- Set the size of the arrays
   ::ArrayResize(buttons_x_offset,pictures_total);
// --- Padding between radio buttons
   for(int i=0; i<pictures_total; i++)
      buttons_x_offset[i]=(i>0)? buttons_x_offset[i-1]+m_radio_buttons_x_offset : 0;
//---
   m_radio_buttons.NamePart("radio_button");
   m_radio_buttons.RadioButtonsMode(true);
   m_radio_buttons.RadioButtonsStyle(true);
// --- Add buttons to the group
   for(int i=0; i<pictures_total; i++)
      m_radio_buttons.AddButton(buttons_x_offset[i],0,"",m_radio_button_width);
// --- Create a button group
   if(!m_radio_buttons.CreateButtonsGroup(x,y))
      return(false);
// --- Show the picture using the selected radio button
   SelectPicture(1);
// --- Add element to array
   CElement::AddToArray(m_radio_buttons);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates an arrow button |
//+------------------------------------------------------------------+
//#resource "\\Images\\EasyAndFastGUI\\Controls\\left_thin_black.bmp"
//#resource "\\Images\\EasyAndFastGUI\\Controls\\right_thin_black.bmp"
//---
bool CPicturesSlider::CreateArrow(CButton &button_obj,const int index)
  {
// --- Save the pointer to the main element
   button_obj.MainPointer(this);
// ---Coordinates
   int x =(index<1)? m_arrows_x_gap : m_arrows_x_gap+16;
   int y =m_arrows_y_gap;
// --- Set the properties before creating
   button_obj.Index(index);
   button_obj.XSize(16);
   button_obj.YSize(16);
// --- Labels for buttons
   if(index<1)
     {
      button_obj.IconFile(IMAGE_RESOURCE_CONTROLS_LEFT_THIN_BLACK_BMP);
      button_obj.IconFileLocked(IMAGE_RESOURCE_CONTROLS_LEFT_THIN_BLACK_BMP);
     }
   else
     {
      button_obj.IconFile(IMAGE_RESOURCE_CONTROLS_RIGHT_THIN_BLACK_BMP);
      button_obj.IconFileLocked(IMAGE_RESOURCE_CONTROLS_RIGHT_THIN_BLACK_BMP);
      button_obj.AnchorRightWindowSide(true);
     }
// --- Let's create a control
   if(!button_obj.CreateButton("",x,y))
      return(false);
// --- Add element to array
   CElement::AddToArray(button_obj);
   return(true);
  }
//+------------------------------------------------------------------+
// | Adds a picture |
//+------------------------------------------------------------------+
CPicture *CPicturesSlider::GetPicturePointer(const uint index)
  {
   uint array_size=PicturesTotal();
// --- Checking the size of an array of objects
   if(array_size<1)
     {
      Print(__FUNCTION__," > В группе нет ни одного элемента!");
      return(NULL);
     }
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Return object pointer
   return(::GetPointer(m_pictures[i]));
  }
//+------------------------------------------------------------------+
// | Adds a picture |
//+------------------------------------------------------------------+
void CPicturesSlider::AddPicture(const string file_path="")
  {
// --- Increase the size of the arrays by one element
   int array_size=::ArraySize(m_pictures);
   int new_size=array_size+1;
   ::ArrayResize(m_pictures,new_size);
   ::ArrayResize(m_file_path,new_size);
// --- Save the values ​​of the passed parameters
   m_file_path[array_size]=(file_path=="")? m_default_path : file_path;
  }
//+------------------------------------------------------------------+
// | Specifies which picture should be shown |
//+------------------------------------------------------------------+
void CPicturesSlider::SelectPicture(const int index)
  {
// --- Get the number of pictures
   int pictures_total=PicturesTotal();
// --- If there are no pictures in the group, report it
   if(pictures_total<1)
     {
      ::Print(__FUNCTION__," > Вызов этого метода нужно осуществлять, "
              "когда в группе есть хотя бы одна картинка! Воспользуйтесь методом CPicturesSlider::AddPicture()");
      return;
     }
// --- Adjust index value if out of range
   uint correct_index=(index>=pictures_total)? pictures_total-1 :(index<0)? 0 : index;
// --- Select a radio button by this index
   m_radio_buttons.SelectButton(correct_index);
// --- Switch picture
   for(int i=0; i<pictures_total; i++)
     {
      if(i==correct_index)
         m_pictures[i].Show();
      else
         m_pictures[i].Hide();
     }
  }
//+------------------------------------------------------------------+
// | Show |
//+------------------------------------------------------------------+
void CPicturesSlider::Show(void)
  {
   CElement::Show();
   SelectPicture(m_radio_buttons.SelectedButtonIndex());
  }
//+------------------------------------------------------------------+
// | Removal |
//+------------------------------------------------------------------+
void CPicturesSlider::Delete(void)
  {
   CElement::Delete();
// --- Freeing element arrays
   ::ArrayFree(m_pictures);
  }
//+------------------------------------------------------------------+
// | Clicking the radio button |
//+------------------------------------------------------------------+
bool CPicturesSlider::OnClickRadioButton(const string clicked_object,const int id,const int index)
  {
// --- Exit if the button was not pressed
   if(::StringFind(clicked_object,m_radio_buttons.NamePart(),0)<0)
      return(false);
// --- Exit if (1) IDs do not match or (2) element is locked
   if(id!=CElementBase::Id() || CElementBase::IsLocked())
      return(false);
// --- Exit if index matches
   if(index==m_radio_buttons.SelectedButtonIndex())
      return(true);
// --- Select image
   SelectPicture(index);
// --- Redraw element
   m_radio_buttons.Update(true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Clicking the left button |
//+------------------------------------------------------------------+
bool CPicturesSlider::OnClickLeftArrow(const string clicked_object,const int id,const int index)
  {
// --- Exit if the button was not pressed
   if(::StringFind(clicked_object,m_left_arrow.NamePart(),0)<0)
      return(false);
// --- Exit if (1) IDs do not match or (2) element is locked
   if(id!=CElementBase::Id() || index!=m_left_arrow.Index() || CElementBase::IsLocked())
      return(false);
// --- Get the current index of the selected radio button
   int selected_radio_button=m_radio_buttons.SelectedButtonIndex();
// --- Switching pictures
   SelectPicture(--selected_radio_button);
// --- Redraw radio buttons
   m_radio_buttons.Update(true);
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_CLICK_BUTTON,CElementBase::Id(),CElementBase::Index(),"");
   return(true);
  }
//+------------------------------------------------------------------+
// | Clicking the right button |
//+------------------------------------------------------------------+
bool CPicturesSlider::OnClickRightArrow(const string clicked_object,const int id,const int index)
  {
// --- Exit if the button was not pressed
   if(::StringFind(clicked_object,m_right_arrow.NamePart(),0)<0)
      return(false);
// --- Exit if (1) IDs do not match or (2) element is locked
   if(id!=CElementBase::Id() || index!=m_right_arrow.Index() || CElementBase::IsLocked())
      return(false);
// --- Get the current index of the selected radio button
   int selected_radio_button=m_radio_buttons.SelectedButtonIndex();
// --- Switching pictures
   SelectPicture(++selected_radio_button);
// --- Redraw radio buttons
   m_radio_buttons.Update(true);
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_CLICK_BUTTON,CElementBase::Id(),CElementBase::Index(),"");
   return(true);
  }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CPicturesSlider::Draw(void)
  {
// --- Draw background
   CElement::DrawBackground();
// --- Draw a frame
   CElement::DrawBorder();
  }
//+------------------------------------------------------------------+
