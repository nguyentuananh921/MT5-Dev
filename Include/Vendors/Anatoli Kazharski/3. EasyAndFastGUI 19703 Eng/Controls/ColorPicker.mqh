//+------------------------------------------------------------------+
//|                                                  ColorPicker.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "TextEdit.mqh"
#include "Button.mqh"
#include "ButtonsGroup.mqh"
#include "ColorButton.mqh"
//+------------------------------------------------------------------+
// | Class for creating a color palette for color selection |
//+------------------------------------------------------------------+
class CColorPicker : public CElement
  {
private:
   // --- Pointer to the button calling the element to select a color
   CColorButton     *m_color_button;
   // --- Instances to create an element
   CButtonsGroup     m_radio_buttons;
   CTextEdit         m_spin_edits[9];
   CButton           m_buttons[2];
   // --- Coordinates
   int               m_pallete_x1;
   int               m_pallete_y1;
   int               m_pallete_x2;
   int               m_pallete_y2;
   // --- Palette sizes
   double            m_pallete_x_size;
   double            m_pallete_y_size;
   // --- Palette frame color
   color             m_palette_border_color;
   // --- Colors of (1) current, (2) selected and (3) mouse pointer
   color             m_current_color;
   color             m_picked_color;
   color             m_hover_color;
   // ---Component values ​​in different color models:
   //    HSL
   double            m_hsl_h;
   double            m_hsl_s;
   double            m_hsl_l;
   //--- RGB
   double            m_rgb_r;
   double            m_rgb_g;
   double            m_rgb_b;
   //--- Lab
   double            m_lab_l;
   double            m_lab_a;
   double            m_lab_b;
   //--- XYZ
   double            m_xyz_x;
   double            m_xyz_y;
   double            m_xyz_z;
   // --- Timer counter for list rewind
   int               m_timer_counter;
   //---
public:
                     CColorPicker(void);
                    ~CColorPicker(void);
   // --- Methods for creating an element
   bool              CreateColorPicker(const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreateRadioButtons(void);
   bool              CreateSpinEdits(void);
   bool              CreateButtons(void);
   //---
public:
   // --- Returns pointers to form elements
   CButtonsGroup    *GetRadioButtonsPointer(void) { return(::GetPointer(m_radio_buttons)); }
   CTextEdit        *GetSpinEditPointer(const uint index);
   CButton          *GetButtonPointer(const uint index);
   // --- Saves the pointer to the button that calls the color palette
   void              ColorButtonPointer(CColorButton &object);
   // --- Set the color of the user-selected color on the palette
   void              CurrentColor(const color clr);
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // --- Timer
   virtual void      OnEventTimer(void);
   // --- Draws an element
   virtual void      Draw(void);
   //---
private:
   // --- Getting color under the mouse cursor
   bool              OnHoverColor(const int x,const int y);
   // --- Handling clicks on the palette
   bool              OnClickPalette(const string clicked_object);
   // --- Handling a click on a radio button
   bool              OnClickRadioButton(const uint id,const uint index,const string pressed_object);
   // --- Processing the entry of a new value into the input field
   bool              OnEndEdit(const uint id,const uint index,const string pressed_object="");
   // --- Handling clicks on the 'OK' button
   bool              OnClickButtonOK(const uint id,const uint index,const string pressed_object);
   // --- Handling clicks on the 'Cancel' button
   bool              OnClickButtonCancel(const uint id,const uint index,const string pressed_object);

   // --- Draws a palette
   void              DrawPalette(const int index);
   // --- Draws a palette using the HSL color model (0: H, 1: S, 2: L)
   void              DrawHSL(const int index);
   // --- Draws a palette using the RGB color model (3: R, 4: G, 5: B)
   void              DrawRGB(const int index);
   // --- Draws a palette using the LAB color model (6: L, 7: a, 8: b)
   void              DrawLab(const int index);
   // --- Draws a palette frame
   void              DrawPaletteBorder(void);
   // --- Draws a frame of color markers
   void              DrawSamplesBorder(void);
   // --- Draws color markers
   void              DrawCurrentSample(void);
   void              DrawPickedSample(void);
   void              DrawHoverSample(void);

   // --- Calculation and installation of color components
   void              SetComponents(const int index,const bool fix_selected);
   // --- Setting current parameters in input fields
   void              SetControls(const int index,const bool fix_selected);

   // --- Setting color model parameters relative to (1) HSL, (2) RGB, (3) Lab
   void              SetHSL(void);
   void              SetRGB(void);
   void              SetLab(void);

   // --- Adjustment of RGB components
   void              AdjustmentComponentRGB(void);
   // ---Adjustment of HSL components
   void              AdjustmentComponentHSL(void);

   // --- Fast forward values ​​in the input field
   void              FastSwitching(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CColorPicker::CColorPicker(void) : m_palette_border_color(clrSilver),
                                   m_current_color(clrGold),
                                   m_picked_color(clrCornflowerBlue),
                                   m_hover_color(clrRed)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CColorPicker::~CColorPicker(void)
  {
  }
//+------------------------------------------------------------------+
// | Graphics event handler |
//+------------------------------------------------------------------+
void CColorPicker::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      // --- Getting color under the mouse cursor
      if(OnHoverColor(m_mouse.X(),m_mouse.Y()))
         return;
      //---
      return;
     }
// --- Handling the event of pressing the left mouse button on an object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      // --- If clicked on the palette
      if(OnClickPalette(sparam))
         return;
      //---
      return;
     }
// --- Processing the value entered into the input field
   if(id==CHARTEVENT_CUSTOM+ON_END_EDIT)
     {
      // --- Checking the entry of a new value
      if(OnEndEdit((uint)lparam,(uint)dparam))
         return;
      //---
      return;
     }
// --- Handling clicks on an element
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      // --- If you pressed the radio button
      if(OnClickRadioButton((uint)lparam,(uint)dparam,sparam))
         return;
      // --- Checking the entry of a new value
      if(OnEndEdit((uint)lparam,(uint)dparam,sparam))
         return;
      // --- If you clicked the "OK" button
      if(OnClickButtonOK((uint)lparam,(uint)dparam,sparam))
         return;
      // --- If you pressed the "CANCEL" button
      if(OnClickButtonCancel((uint)lparam,(uint)dparam,sparam))
         return;
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
// | Timer |
//+------------------------------------------------------------------+
void CColorPicker::OnEventTimer(void)
  {
// --- Fast forward values
   FastSwitching();
  }
//+------------------------------------------------------------------+
// | Creates a Color Picker object |
//+------------------------------------------------------------------+
bool CColorPicker::CreateColorPicker(const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// --- Initializing properties
   InitializeProperties(x_gap,y_gap);
// --- Let's create element objects
   if(!CreateCanvas())
      return(false);
   if(!CreateRadioButtons())
      return(false);
   if(!CreateSpinEdits())
      return(false);
   if(!CreateButtons())
      return(false);
// --- Calculate the components of all color models and draw a palette relative to the selected radio button
   SetComponents(m_radio_buttons.SelectedButtonIndex(),false);
   return(true);
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CColorPicker::InitializeProperties(const int x_gap,const int y_gap)
  {
   m_x_size =348;
   m_y_size =266;
   m_x      =CElement::CalculateX(x_gap);
   m_y      =CElement::CalculateY(y_gap);
// --- Palette dimensions and coordinates
   m_pallete_x_size =255.0;
   m_pallete_y_size =255.0;
   m_pallete_x1     =6;
   m_pallete_y1     =5;
   m_pallete_x2     =m_pallete_x1+(int)m_pallete_x_size;
   m_pallete_y2     =m_pallete_y1+(int)m_pallete_y_size;
// ---Default background color
   m_back_color=(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
// ---Default frame color
   m_border_color=(m_border_color!=clrNONE)? m_border_color : m_main.BackColor();
// --- Indents from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
// | Creates an object to draw |
//+------------------------------------------------------------------+
bool CColorPicker::CreateCanvas(void)
  {
// --- Formation of object name
   string name=CElementBase::ElementName("color_picker");
// ---Create an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a group of radio buttons |
//+------------------------------------------------------------------+
bool CColorPicker::CreateRadioButtons(void)
  {
// --- ID of the last added element
   CElementBase::LastId(m_main.LastId());
// --- Save a pointer to the parent element
   m_radio_buttons.MainPointer(this);
// --- Coordinates
   int x=266,y=35;
// --- Properties
   int    buttons_x_offset[] ={0,0,0,0,0,0,0,0,0};
   int    buttons_y_offset[] ={0,19,38,60,79,98,120,139,158};
   string buttons_text[]     ={"H:","S:","L:","R:","G:","B:","L:","a:","b:"};
   int    buttons_width[9];
   ::ArrayInitialize(buttons_width,35);
// --- Properties
   m_radio_buttons.NamePart("radio_button");
   m_radio_buttons.ButtonYSize(18);
   m_radio_buttons.RadioButtonsMode(true);
   m_radio_buttons.RadioButtonsStyle(true);
   m_radio_buttons.IconYGap(4);
   m_radio_buttons.LabelYGap(4);
   m_radio_buttons.LabelColor(clrBlack);
   m_radio_buttons.LabelColorLocked(clrSilver);
// --- Add radio buttons with the specified properties
   for(int i=0; i<9; i++)
      m_radio_buttons.AddButton(buttons_x_offset[i],buttons_y_offset[i],buttons_text[i],buttons_width[i]);
// --- Create a button group
   if(!m_radio_buttons.CreateButtonsGroup(x,y))
      return(false);
// --- Select the button in the group
   m_radio_buttons.SelectButton(8);
// --- Add element to array
   CElement::AddToArray(m_radio_buttons);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates input fields |
//+------------------------------------------------------------------+
bool CColorPicker::CreateSpinEdits(void)
  {
// --- Coordinates
   int x=297;
   int y[9]={36,55,74,96,115,134,156,175,194};
//---
   int max[9]   ={360,100,100,255,255,255,100,127,127};
   int min[9]   ={0,0,0,0,0,0,0,-128,-128};
   int value[9] ={360,50,100,50,50,50,50,50,50};
//---
   for(int i=0; i<9; i++)
     {
      // --- Save a pointer to the parent element
      m_spin_edits[i].MainPointer(this);
      // --- Properties
      m_spin_edits[i].Index(i);
      m_spin_edits[i].XSize(45);
      m_spin_edits[i].YSize(18);
      m_spin_edits[i].MaxValue(max[i]);
      m_spin_edits[i].MinValue(min[i]);
      m_spin_edits[i].StepValue(1);
      m_spin_edits[i].SetDigits(0);
      m_spin_edits[i].SpinEditMode(true);
      m_spin_edits[i].SetValue((string)value[i]);
      m_spin_edits[i].BackColor(m_back_color);
      m_spin_edits[i].GetTextBoxPointer().XGap(1);
      m_spin_edits[i].GetTextBoxPointer().AutoSelectionMode(true);
      m_spin_edits[i].GetTextBoxPointer().XSize(m_spin_edits[i].XSize());
      // ---Creating an element
      if(!m_spin_edits[i].CreateTextEdit("",x,y[i]))
         return(false);
      // --- Indentation for text in the input field
      m_spin_edits[i].GetTextBoxPointer().TextYOffset(4);
      // --- Add element to array
      CElement::AddToArray(m_spin_edits[i]);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates buttons |
//+------------------------------------------------------------------+
bool CColorPicker::CreateButtons(void)
  {
   for(int i=0; i<2; i++)
     {
      // --- Save the pointer to the form
      m_buttons[i].MainPointer(this);
      // --- Coordinates
      int x =267;
      int y =(i<1)? 218 : 241;
      //---
      string text=(i<1)? "OK" : "Cancel";
      // --- Properties
      m_buttons[i].Index(i+9);
      m_buttons[i].NamePart("button");
      m_buttons[i].XSize(76);
      m_buttons[i].YSize(20);
      m_buttons[i].IsCenterText(true);
      // ---Creating an element
      if(!m_buttons[i].CreateButton(text,x,y))
         return(false);
      // --- Add element to array
      CElement::AddToArray(m_buttons[i]);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Returns a pointer to the specified input field |
//+------------------------------------------------------------------+
CTextEdit *CColorPicker::GetSpinEditPointer(const uint index)
  {
   uint array_size=::ArraySize(m_spin_edits);
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
//---
   return(::GetPointer(m_spin_edits[i]));
  }
//+------------------------------------------------------------------+
// | Returns a pointer to the specified button |
//+------------------------------------------------------------------+
CButton *CColorPicker::GetButtonPointer(const uint index)
  {
   uint array_size=::ArraySize(m_buttons);
// --- Adjustment in case of leaving the range
   uint i=(index>=array_size)? array_size-1 : index;
// --- Return pointer
   return(::GetPointer(m_buttons[index]));
  }
//+------------------------------------------------------------------+
// | Saves the pointer to the button that calls the color palette and |
// | opens the window to which the palette is attached |
//+------------------------------------------------------------------+
void CColorPicker::ColorButtonPointer(CColorButton &object)
  {
// --- Save pointer to button
   m_color_button=::GetPointer(object);
// --- Set the color of the passed button to all palette markers
   CurrentColor(object.CurrentColor());
// --- If the pointer to the window to which the palette is attached is valid
   if(::CheckPointer(m_wnd)!=POINTER_INVALID)
     {
      // --- Open the window
      m_wnd.OpenWindow();
     }
// --- Reset button focus
   object.MouseFocus(false);
   object.Update(true);
   object.GetButtonPointer().MouseFocus(false);
   object.GetButtonPointer().Update(true);
  }
//+------------------------------------------------------------------+
// | Setting the current color |
//+------------------------------------------------------------------+
void CColorPicker::CurrentColor(const color clr)
  {
   m_hover_color=clr;
   DrawHoverSample();
//---
   m_picked_color=clr;
   DrawPickedSample();
//---
   m_current_color=clr;
   DrawCurrentSample();
  }
//+------------------------------------------------------------------+
// | Getting color under the mouse cursor |
//+------------------------------------------------------------------+
bool CColorPicker::OnHoverColor(const int x,const int y)
  {
// --- Exit if focus is not on element
   if(!CElementBase::MouseFocus())
      return(false);
// --- Check focus on palette
   m_canvas.MouseFocus(x>m_canvas.X()+m_pallete_x1 && x<m_canvas.X()+m_pallete_x2 && 
                       y>m_canvas.Y()+m_pallete_y1 && y<m_canvas.Y()+m_pallete_y2);
// --- Quit if the focus is not on the palette
   if(!m_canvas.MouseFocus())
     {
      ::ObjectSetString(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TOOLTIP,"\n");
      return(false);
     }
// --- Define the color on the palette under the mouse cursor
   int lx =x-m_canvas.X();
   int ly =y-m_canvas.Y();
   m_hover_color=(color)::ColorToARGB(m_canvas.PixelGet(lx,ly),0);
// --- Set the color and tooltip to the corresponding sample (marker)
   DrawHoverSample();
// --- Set a tooltip for the palette
   ::ObjectSetString(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TOOLTIP,::ColorToString(m_hover_color));
// --- Refresh canvas
   m_canvas.Update();
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling clicks on the color palette |
//+------------------------------------------------------------------+
bool CColorPicker::OnClickPalette(const string clicked_object)
  {
// --- Exit if object name does not match
   if(clicked_object!=m_canvas.ChartObjectName())
      return(false);
// --- Set the color and tooltip to the appropriate swatch
   m_picked_color=m_hover_color;
   DrawPickedSample();
// --- Calculate and set the color components relative to the selected radio button
   SetComponents();
// --- Update input fields
   for(int i=0; i<9; i++)
      m_spin_edits[i].GetTextBoxPointer().Update(true);
// --- Refresh canvas
   m_canvas.Update();
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling a click on a radio button |
//+------------------------------------------------------------------+
bool CColorPicker::OnClickRadioButton(const uint id,const uint index,const string pressed_object)
  {
// --- Exit if the press was not on the radio button
   if(::StringFind(pressed_object,m_radio_buttons.NamePart())<0)
      return(false);
// --- Exit if IDs do not match
   if(id!=CElementBase::Id() || index==m_radio_buttons.SelectedButtonIndex())
      return(false);
// --- Update the palette with the latest changes
   DrawPalette(index);
// --- Refresh canvas
   m_canvas.Update();
   return(true);
  }
//+------------------------------------------------------------------+
// | Processing the entry of a new value into an input field |
//+------------------------------------------------------------------+
bool CColorPicker::OnEndEdit(const uint id,const uint index,const string pressed_object="")
  {
// --- Exit if the button was not pressed
   if(pressed_object!="")
      if(::StringFind(pressed_object,"spin")<0)
         return(false);
// --- Exit if IDs do not match
   if(id!=CElementBase::Id())
      return(false);
// --- Calculate and set color components for all color models
   SetComponents(index>>1,false);
// --- Update input fields
   for(int i=0; i<9; i++)
      m_spin_edits[i].GetTextBoxPointer().Update(true);
// --- Refresh canvas
   m_canvas.Update();
   return(true);
  }
//+------------------------------------------------------------------+
// | Processing clicks on the 'OK' button |
//+------------------------------------------------------------------+
bool CColorPicker::OnClickButtonOK(const uint id,const uint index,const string pressed_object)
  {
// --- Exit if the button was not pressed
   if(::StringFind(pressed_object,m_buttons[0].NamePart())<0)
      return(false);
// --- Exit if IDs do not match
   if(id!=CElementBase::Id() || index!=m_buttons[0].Index())
      return(false);
// ---Save selected color
   m_current_color=m_picked_color;
   DrawCurrentSample();
   m_canvas.Update();
// --- If there is a window button pointer to select a color
   if(::CheckPointer(m_color_button)!=POINTER_INVALID)
     {
      // --- Set the button to the selected color
      m_color_button.CurrentColor(m_current_color);
      m_color_button.MouseFocus(false);
      m_color_button.Update(true);
      m_color_button.GetButtonPointer().Update(true);
      // --- Close the window
      m_wnd.CloseDialogBox();
      // --- We will send a message about this
      ::EventChartCustom(m_chart_id,ON_CHANGE_COLOR,CElementBase::Id(),CElementBase::Index(),m_color_button.LabelText());
      // --- Reset the pointer
      m_color_button=NULL;
     }
   else
     {
      // --- If there is no pointer and the window is a dialog,
      // display a message that there is no pointer to the button to call the element
      if(m_wnd.WindowType()==W_DIALOG)
         ::Print(__FUNCTION__," > Невалидный указатель вызывающего элемента (CColorButton).");
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling clicks on the 'Cancel' button |
//+------------------------------------------------------------------+
bool CColorPicker::OnClickButtonCancel(const uint id,const uint index,const string pressed_object)
  {
// --- Exit if the button was not pressed
   if(::StringFind(pressed_object,m_buttons[1].NamePart())<0)
      return(false);
// --- Exit if IDs do not match
   if(id!=CElementBase::Id() || index!=m_buttons[1].Index())
      return(false);
// --- Close the window if it is dialog
   if(m_wnd.WindowType()==W_DIALOG)
      m_wnd.CloseDialogBox();
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CColorPicker::Draw(void)
  {
// --- Draw background
   CElement::DrawBackground();
// --- Draw a frame
   CElement::DrawBorder();
// --- Draw a frame of color markers
   DrawSamplesBorder();
// --- Draw color markers
   DrawCurrentSample();
   DrawPickedSample();
   DrawHoverSample();
// --- Calculate the components of all color models and
// draw a palette relative to the selected radio button
   SetComponents(m_radio_buttons.SelectedButtonIndex(),false);
  }
//+------------------------------------------------------------------+
// | Draws a frame of color markers |
//+------------------------------------------------------------------+
void CColorPicker::DrawSamplesBorder(void)
  {
   uint clr=::ColorToARGB(m_palette_border_color);
// --- Calculate the coordinates
   int x1 =m_pallete_x1+(int)m_pallete_x_size+5;
   int y1 =m_pallete_y1-1;
   int x2 =x1+76;
   int y2 =m_pallete_y1+25;
// --- Draw a frame
   m_canvas.Line(x1,y1,x2,y1,clr);
   m_canvas.Line(x1,y2,x2,y2,clr);
   m_canvas.Line(x1,y1,x1,y2,clr);
   m_canvas.Line(x2,y1,x2,y2,clr);
  }
//+------------------------------------------------------------------+
// | Draws a marker with the current color |
//+------------------------------------------------------------------+
void CColorPicker::DrawCurrentSample(void)
  {
   uint clr=::ColorToARGB(m_current_color);
// --- Calculate the coordinates
   int x1 =m_pallete_x1+(int)m_pallete_x_size+6;
   int y1 =m_pallete_y1;
   int x2 =x1+24;
   int y2 =m_pallete_y1+24;
// ---Draw marker
   m_canvas.FillRectangle(x1,y1,x2,y2,clr);
  }
//+------------------------------------------------------------------+
// | Draws a marker with the selected color |
//+------------------------------------------------------------------+
void CColorPicker::DrawPickedSample(void)
  {
   uint clr=::ColorToARGB(m_picked_color);
// --- Calculate the coordinates
   int x1 =m_pallete_x1+(int)m_pallete_x_size+6+25;
   int y1 =m_pallete_y1;
   int x2 =x1+24;
   int y2 =m_pallete_y1+24;
// ---Draw marker
   m_canvas.FillRectangle(x1,y1,x2,y2,clr);
  }
//+------------------------------------------------------------------+
// | Draws a marker with the specified color |
//+------------------------------------------------------------------+
void CColorPicker::DrawHoverSample(void)
  {
   uint clr=::ColorToARGB(m_hover_color);
// --- Calculate the coordinates
   int x1 =m_pallete_x1+(int)m_pallete_x_size+6+50;
   int y1 =m_pallete_y1;
   int x2 =x1+24;
   int y2 =m_pallete_y1+24;
// ---Draw marker
   m_canvas.FillRectangle(x1,y1,x2,y2,clr);
  }
//+------------------------------------------------------------------+
// | Draws a palette |
//+------------------------------------------------------------------+
void CColorPicker::DrawPalette(const int index)
  {
   switch(index)
     {
      //--- HSL (0: H, 1: S, 2: L)
      case 0 : case 1 : case 2 :
        {
         DrawHSL(index);
         break;
        }
      //--- RGB (3: R, 4: G, 5: B)
      case 3 : case 4 : case 5 :
        {
         DrawRGB(index);
         break;
        }
      //--- LAB (6: L, 7: a, 8: b)
      case 6 : case 7 : case 8 :
        {
         DrawLab(index);
         break;
        }
     }
// --- Let's draw a frame for the palette
   DrawPaletteBorder();
  }
//+------------------------------------------------------------------+
// | Draws HSL palette |
//+------------------------------------------------------------------+
void CColorPicker::DrawHSL(const int index)
  {
   switch(index)
     {
      // --- Hue (H) - color tone in the range from 0 to 360
      case 0 :
        {
         // --- Let's calculate the H-component
         m_hsl_h=(double)m_spin_edits[0].GetValue()/360.0;
         //---
         for(int ly=m_pallete_y1; ly<m_pallete_y2; ly++)
           {
            // --- Let's calculate the L-component
            m_hsl_l=ly/m_pallete_y_size;
            //---
            for(int lx=m_pallete_x1; lx<m_pallete_x2; lx++)
              {
               // --- Let's calculate the S-component
               m_hsl_s=lx/m_pallete_x_size;
               // --- Convert HSL components to RGB components
               m_clr.HSLtoRGB(m_hsl_h,m_hsl_s,m_hsl_l,m_rgb_r,m_rgb_g,m_rgb_b);
               // ---Adjust if components are out of range
               AdjustmentComponentRGB();
               // --- Let's connect the channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,ly,rgb_color);
              }
           }
         break;
        }
      // --- Saturation (S) - saturation in the range from 0 to 100
      case 1 :
        {
         // --- Let's calculate the S-component
         m_hsl_s=(double)m_spin_edits[1].GetValue()/100.0;
         //---
         for(int ly=m_pallete_y1; ly<m_pallete_y2; ly++)
           {
            // --- Let's calculate the L-component
            m_hsl_l=ly/m_pallete_y_size;
            //---
            for(int lx=m_pallete_x1; lx<m_pallete_x2; lx++)
              {
               // --- Let's calculate the H-component
               m_hsl_h=lx/m_pallete_x_size;
               // --- Convert HSL components to RGB components
               m_clr.HSLtoRGB(m_hsl_h,m_hsl_s,m_hsl_l,m_rgb_r,m_rgb_g,m_rgb_b);
               // ---Adjust if components are out of range
               AdjustmentComponentRGB();
               // --- Let's connect the channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,ly,rgb_color);
              }
           }
         break;
        }
      // --- Lightness (L) - brightness in the range from 0 to 100
      case 2 :
        {
         // --- Let's calculate the L-component
         m_hsl_l=(double)m_spin_edits[2].GetValue()/100.0;
         //---
         for(int ly=m_pallete_y1; ly<m_pallete_y2; ly++)
           {
            // --- Let's calculate the S-component
            m_hsl_s=ly/m_pallete_y_size;
            //---
            for(int lx=m_pallete_x1; lx<m_pallete_x2; lx++)
              {
               // --- Let's calculate the H-component
               m_hsl_h=lx/m_pallete_x_size;
               // --- Convert HSL components to RGB components
               m_clr.HSLtoRGB(m_hsl_h,m_hsl_s,m_hsl_l,m_rgb_r,m_rgb_g,m_rgb_b);
               // ---Adjust if components are out of range
               AdjustmentComponentRGB();
               // --- Let's connect the channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,ly,rgb_color);
              }
           }
         break;
        }
     }
  }
//+------------------------------------------------------------------+
// | Draws an RGB palette |
//+------------------------------------------------------------------+
void CColorPicker::DrawRGB(const int index)
  {
// --- Steps along the X and Y axes to calculate RGB components
   double rgb_x_step =255.0/m_pallete_x_size;
   double rgb_y_step =255.0/m_pallete_y_size;
//---
   switch(index)
     {
      // --- Red (R) - red. Color range from 0 to 255
      case 3 :
        {
         // --- Get the current R-component and reset the B-component
         m_rgb_r =(double)m_spin_edits[3].GetValue();
         m_rgb_b =0;
         //---
         for(int ly=m_pallete_y1; ly<m_pallete_y2; ly++)
           {
            // --- Calculate the B-component and reset the R-component
            m_rgb_g=0;
            m_rgb_b+=rgb_y_step;
            //---
            for(int lx=m_pallete_x1; lx<m_pallete_x2; lx++)
              {
               // --- Let's calculate the G-component
               m_rgb_g+=rgb_x_step;
               // --- Let's connect the channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,ly,rgb_color);
              }
           }
         break;
        }
      // --- Green (G) - green. Color range from 0 to 255
      case 4 :
        {
         // --- Get the current G-component and reset the B-component
         m_rgb_g =(double)m_spin_edits[4].GetValue();
         m_rgb_b =0;
         //---
         for(int ly=m_pallete_y1; ly<m_pallete_y2; ly++)
           {
            // --- Calculate the B-component and reset the R-component
            m_rgb_r=0;
            m_rgb_b+=rgb_y_step;
            //---
            for(int lx=m_pallete_x1; lx<m_pallete_x2; lx++)
              {
               // --- Let's calculate the R-component
               m_rgb_r+=rgb_x_step;
               // --- Let's connect the channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,ly,rgb_color);
              }
           }
         break;
        }
      // --- Blue (B) - blue. Color range from 0 to 255
      case 5 :
        {
         // --- Get the current B-component and reset the G-component
         m_rgb_g =0;
         m_rgb_b =(double)m_spin_edits[5].GetValue();
         //---
         for(int ly=m_pallete_y1; ly<m_pallete_y2; ly++)
           {
            // --- Calculate the G-component and reset the R-component
            m_rgb_r=0;
            m_rgb_g+=rgb_y_step;
            //---
            for(int lx=m_pallete_x1; lx<m_pallete_x2; lx++)
              {
               // --- Let's calculate the R-component
               m_rgb_r+=rgb_x_step;
               // --- Let's connect the channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,ly,rgb_color);
              }
           }
         break;
        }
     }
  }
//+------------------------------------------------------------------+
// | Draws Palette Lab |
//+------------------------------------------------------------------+
void CColorPicker::DrawLab(const int index)
  {
   switch(index)
     {
      // --- Lightness (L) - brightness in the range from 0 to 100
      case 6 :
        {
         // --- Get the current L-component
         m_lab_l=(double)m_spin_edits[6].GetValue();
         //---
         for(int ly=m_pallete_y1; ly<=m_pallete_y2; ly++)
           {
            // --- Let's calculate the b-component
            m_lab_b=(ly/m_pallete_y_size*255.0)-128;
            //---
            for(int lx=m_pallete_x1; lx<m_pallete_x2; lx++)
              {
               // --- Let's calculate the a-component
               m_lab_a=(lx/m_pallete_x_size*255.0)-128;
               // --- Convert Lab components to RGB components
               m_clr.CIELabToXYZ(m_lab_l,m_lab_a,m_lab_b,m_xyz_x,m_xyz_y,m_xyz_z);
               m_clr.XYZtoRGB(m_xyz_x,m_xyz_y,m_xyz_z,m_rgb_r,m_rgb_g,m_rgb_b);
               // --- Adjustment of RGB components
               AdjustmentComponentRGB();
               // --- Let's connect the channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,ly,rgb_color);
              }
           }
         break;
        }
      // --- Chromatic component 'a' - range -128 (green) to 127 (magenta)
      case 7 :
        {
         // --- Get the current a-component
         m_lab_a=(double)m_spin_edits[7].GetValue();
         //---
         for(int ly=m_pallete_y1; ly<=m_pallete_y2; ly++)
           {
            // --- Let's calculate the b-component
            m_lab_b=(ly/m_pallete_y_size*255.0)-128;
            //---
            for(int lx=m_pallete_x1; lx<m_pallete_x2; lx++)
              {
               // --- Let's calculate the L-component
               m_lab_l=100.0*lx/m_pallete_x_size;
               // --- Convert Lab components to RGB components
               m_clr.CIELabToXYZ(m_lab_l,m_lab_a,m_lab_b,m_xyz_x,m_xyz_y,m_xyz_z);
               m_clr.XYZtoRGB(m_xyz_x,m_xyz_y,m_xyz_z,m_rgb_r,m_rgb_g,m_rgb_b);
               // --- Adjustment of RGB components
               AdjustmentComponentRGB();
               // --- Let's connect the channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,ly,rgb_color);
              }
           }
         break;
        }
      // --- Chromatic component 'b' - range -128 (blue) to 127 (yellow)
      case 8 :
        {
         // --- Get the current b-component
         m_lab_b=(double)m_spin_edits[8].GetValue();
         //---
         for(int ly=m_pallete_y1; ly<=m_pallete_y2; ly++)
           {
            // --- Let's calculate the a-component
            m_lab_a=(ly/m_pallete_y_size*255.0)-128;
            //---
            for(int lx=m_pallete_x1; lx<m_pallete_x2; lx++)
              {
               // --- Let's calculate the L-component
               m_lab_l=100.0*lx/m_pallete_x_size;
               // --- Convert Lab components to RGB components
               m_clr.CIELabToXYZ(m_lab_l,m_lab_a,m_lab_b,m_xyz_x,m_xyz_y,m_xyz_z);
               m_clr.XYZtoRGB(m_xyz_x,m_xyz_y,m_xyz_z,m_rgb_r,m_rgb_g,m_rgb_b);
               // --- Adjustment of RGB components
               AdjustmentComponentRGB();
               // --- Let's connect the channels
               uint rgb_color=XRGB(m_rgb_r,m_rgb_g,m_rgb_b);
               m_canvas.PixelSet(lx,ly,rgb_color);
              }
           }
         break;
        }
     }
  }
//+------------------------------------------------------------------+
// | Draws a palette frame |
//+------------------------------------------------------------------+
void CColorPicker::DrawPaletteBorder(void)
  {
   uint clr=::ColorToARGB(m_palette_border_color);
// --- Palette size
   int x1 =m_pallete_x1-1;
   int y1 =m_pallete_y1-1;
   int x2 =m_pallete_x1+(int)m_pallete_x_size;
   int y2 =m_pallete_y1+(int)m_pallete_y_size;
// --- Draw a frame
   m_canvas.Line(x1,y1,x2,y1,clr);
   m_canvas.Line(x1,y2,x2,y2,clr);
   m_canvas.Line(x2,y1,x2,y2,clr);
   m_canvas.Line(x1,y1,x1,y2,clr);
  }
//+------------------------------------------------------------------+
// | Calculation and installation of color components |
//+------------------------------------------------------------------+
void CColorPicker::SetComponents(const int index=0,const bool fix_selected=true)
  {
// --- If you need to adjust the colors relative to the component selected by the radio button
   if(fix_selected)
     {
      // --- Let's decompose the selected color into RGB components
      m_rgb_r =m_clr.GetR(m_picked_color);
      m_rgb_g =m_clr.GetG(m_picked_color);
      m_rgb_b =m_clr.GetB(m_picked_color);
      // --- Convert RGB components to HSL components
      m_clr.RGBtoHSL(m_rgb_r,m_rgb_g,m_rgb_b,m_hsl_h,m_hsl_s,m_hsl_l);
      // ---Adjustment of HSL components
      AdjustmentComponentHSL();
      // --- Convert RGB components to LAB components
      m_clr.RGBtoXYZ(m_rgb_r,m_rgb_g,m_rgb_b,m_xyz_x,m_xyz_y,m_xyz_z);
      m_clr.XYZtoCIELab(m_xyz_x,m_xyz_y,m_xyz_z,m_lab_l,m_lab_a,m_lab_b);
      // --- Set the colors in the input fields
      SetControls(m_radio_buttons.SelectedButtonIndex(),true);
      return;
     }
// --- Setting color model parameters
   switch(index)
     {
      case 0 : case 1 : case 2 :
         SetHSL();
         break;
      case 3 : case 4 : case 5 :
         SetRGB();
         break;
      case 6 : case 7 : case 8 :
         SetLab();
         break;
     }
// --- Draw a palette relative to the selected radio button
   DrawPalette(m_radio_buttons.SelectedButtonIndex());
  }
//+------------------------------------------------------------------+
// | Setting current parameters in input fields |
//+------------------------------------------------------------------+
void CColorPicker::SetControls(const int index,const bool fix_selected)
  {
// --- If you need to fix the value in the input field of the selected radio button
   if(fix_selected)
     {
      // --- HSL Components
      if(index!=0)
         m_spin_edits[0].SetValue(::DoubleToString(m_hsl_h,0),false);
      if(index!=1)
         m_spin_edits[1].SetValue(::DoubleToString(m_hsl_s,0),false);
      if(index!=2)
         m_spin_edits[2].SetValue(::DoubleToString(m_hsl_l,0),false);
      // --- RGB components
      if(index!=3)
         m_spin_edits[3].SetValue(::DoubleToString(m_rgb_r,0),false);
      if(index!=4)
         m_spin_edits[4].SetValue(::DoubleToString(m_rgb_g,0),false);
      if(index!=5)
         m_spin_edits[5].SetValue(::DoubleToString(m_rgb_b,0),false);
      // --- Lab Components
      if(index!=6)
         m_spin_edits[6].SetValue(::DoubleToString(m_lab_l,0),false);
      if(index!=7)
         m_spin_edits[7].SetValue(::DoubleToString(m_lab_a,0),false);
      if(index!=8)
         m_spin_edits[8].SetValue(::DoubleToString(m_lab_b,0),false);
      return;
     }
// --- If you need to adjust the values ​​in the input fields of all color models
   m_spin_edits[0].SetValue(::DoubleToString(m_hsl_h,0),false);
   m_spin_edits[1].SetValue(::DoubleToString(m_hsl_s,0),false);
   m_spin_edits[2].SetValue(::DoubleToString(m_hsl_l,0),false);
//---
   m_spin_edits[3].SetValue(::DoubleToString(m_rgb_r,0),false);
   m_spin_edits[4].SetValue(::DoubleToString(m_rgb_g,0),false);
   m_spin_edits[5].SetValue(::DoubleToString(m_rgb_b,0),false);
//---
   m_spin_edits[6].SetValue(::DoubleToString(m_lab_l,0),false);
   m_spin_edits[7].SetValue(::DoubleToString(m_lab_a,0),false);
   m_spin_edits[8].SetValue(::DoubleToString(m_lab_b,0),false);
  }
//+------------------------------------------------------------------+
// | Setting color model parameters relative to HSL |
//+------------------------------------------------------------------+
void CColorPicker::SetHSL(void)
  {
// --- Get the current values ​​of the HSL components
   m_hsl_h =(double)m_spin_edits[0].GetValue();
   m_hsl_s =(double)m_spin_edits[1].GetValue();
   m_hsl_l =(double)m_spin_edits[2].GetValue();
// --- Convert HSL components to RGB components
   m_clr.HSLtoRGB(m_hsl_h/360.0,m_hsl_s/100.0,m_hsl_l/100.0,m_rgb_r,m_rgb_g,m_rgb_b);
// --- Convert RGB components to Lab components
   m_clr.RGBtoXYZ(m_rgb_r,m_rgb_g,m_rgb_b,m_xyz_x,m_xyz_y,m_xyz_z);
   m_clr.XYZtoCIELab(m_xyz_x,m_xyz_y,m_xyz_z,m_lab_l,m_lab_a,m_lab_b);
// --- Setting current parameters in input fields
   SetControls(0,false);
  }
//+------------------------------------------------------------------+
// | Setting color model parameters relative to RGB |
//+------------------------------------------------------------------+
void CColorPicker::SetRGB(void)
  {
// --- Get the current values ​​of the RGB components
   m_rgb_r =(double)m_spin_edits[3].GetValue();
   m_rgb_g =(double)m_spin_edits[4].GetValue();
   m_rgb_b =(double)m_spin_edits[5].GetValue();
// --- Convert RGB components to HSL components
   m_clr.RGBtoHSL(m_rgb_r,m_rgb_g,m_rgb_b,m_hsl_h,m_hsl_s,m_hsl_l);
// ---Adjustment of HSL components
   AdjustmentComponentHSL();
// --- Convert RGB components to Lab components
   m_clr.RGBtoXYZ(m_rgb_r,m_rgb_g,m_rgb_b,m_xyz_x,m_xyz_y,m_xyz_z);
   m_clr.XYZtoCIELab(m_xyz_x,m_xyz_y,m_xyz_z,m_lab_l,m_lab_a,m_lab_b);
// --- Setting current parameters in input fields
   SetControls(0,false);
  }
//+------------------------------------------------------------------+
// | Setting color model parameters relative to Lab |
//+------------------------------------------------------------------+
void CColorPicker::SetLab(void)
  {
// --- Get the current values ​​of the Lab components
   m_lab_l =(double)m_spin_edits[6].GetValue();
   m_lab_a =(double)m_spin_edits[7].GetValue();
   m_lab_b =(double)m_spin_edits[8].GetValue();
// --- Convert Lab components to RGB components
   m_clr.CIELabToXYZ(m_lab_l,m_lab_a,m_lab_b,m_xyz_x,m_xyz_y,m_xyz_z);
   m_clr.XYZtoRGB(m_xyz_x,m_xyz_y,m_xyz_z,m_rgb_r,m_rgb_g,m_rgb_b);
// --- Adjustment of RGB components
   AdjustmentComponentRGB();
// --- Convert RGB components to HSL components
   m_clr.RGBtoHSL(m_rgb_r,m_rgb_g,m_rgb_b,m_hsl_h,m_hsl_s,m_hsl_l);
// ---Adjustment of HSL components
   AdjustmentComponentHSL();
// --- Setting current parameters in input fields
   SetControls(0,false);
  }
//+------------------------------------------------------------------+
// | Adjusting RGB components |
//+------------------------------------------------------------------+
void CColorPicker::AdjustmentComponentRGB(void)
  {
   m_rgb_r=::fmin(::fmax(m_rgb_r,0),255);
   m_rgb_g=::fmin(::fmax(m_rgb_g,0),255);
   m_rgb_b=::fmin(::fmax(m_rgb_b,0),255);
  }
//+------------------------------------------------------------------+
// | Adjustment of HSL components |
//+------------------------------------------------------------------+
void CColorPicker::AdjustmentComponentHSL(void)
  {
   m_hsl_h*=360;
   m_hsl_s*=100;
   m_hsl_l*=100;
  }
//+------------------------------------------------------------------+
// | Fast scrolling through values ​​in an input field |
//+------------------------------------------------------------------+
void CColorPicker::FastSwitching(void)
  {
// --- Exit if there is no focus on the element
   if(!CElementBase::MouseFocus())
      return;
// --- Return the counter to its original value if the mouse button is released
   if(!m_mouse.LeftButtonState())
      m_timer_counter=SPIN_DELAY_MSC;
// --- If the mouse button is pressed
   else
     {
      // --- Increase the counter by the set interval
      m_timer_counter+=TIMER_STEP_MSC;
      // --- Exit if less than zero
      if(m_timer_counter<0)
         return;
      // --- Determination of the activated counter for the activated radio button
      int index=WRONG_VALUE;
      //---
      for(int i=0; i<9; i++)
        {
         if(m_radio_buttons.SelectedButtonIndex()==i && 
            (m_spin_edits[i].GetIncButtonPointer().MouseFocus() || m_spin_edits[i].GetDecButtonPointer().MouseFocus()))
           {
            index=i;
            break;
           }
        }
      // --- If there is, we will update the palette
      if(index!=WRONG_VALUE)
        {
         DrawPalette(index);
         // --- Refresh canvas
         m_canvas.Update();
        }
      // --- Definition of activated counter
      index=WRONG_VALUE;
      //---
      for(int i=0; i<9; i++)
        {
         if(m_spin_edits[i].GetIncButtonPointer().MouseFocus() || m_spin_edits[i].GetDecButtonPointer().MouseFocus())
           {
            index=i;
            break;
           }
        }
      // --- If there is, we will recalculate the components of all color models and update the palette
      if(index!=WRONG_VALUE)
        {
         SetComponents(index,false);
         // --- Refresh canvas
         m_canvas.Update();
        }
     }
  }
//+------------------------------------------------------------------+
