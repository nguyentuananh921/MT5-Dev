//+------------------------------------------------------------------+
//|                                                       Button.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Lib Link https://www.mql5.com/en/code/19703                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Class for creating a button |
//+------------------------------------------------------------------+
#ifndef __BUTTON_MQH__
#define __BUTTON_MQH__
#include "..\Element.mqh"
 class CButton : public CElement 
  {
    private:
        // --- Two-state button mode
        bool m_two_state;
        //---
    public:
        CButton(void);
        ~CButton(void);
        // --- Methods for creating a button
        bool CreateButton(const string text, const int x_gap, const int y_gap);
        //---
    private:
        void InitializeProperties(const string text, const int x_gap,
                                const int y_gap);
        bool CreateCanvas(void);
        //---
    public:
      // --- (1) Setting the button mode, (2) button state (pressed/released)
        bool    TwoState(void) const {return (m_two_state);}
        void    TwoState(const bool flag) {m_two_state = flag;}
        bool    IsPressed(void) const {return (m_is_pressed);}
        void    IsPressed(const bool state);
      // --- Set shortcuts for the button in the pressed state (available/locked)
        void    IconFilePressed(const string file_path);
        void    IconFilePressedLocked(const string file_path);
        void    IconFilePressed(const uint resource_index);
        void    IconFilePressedLocked(const uint resource_index);
        // --- Resizing
        void ChangeSize(const uint x_size, const uint y_size);
    public:
      // ---Graph event handler
        virtual void OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);
      // --- Draws an element
        virtual void Draw(void);
    protected:
      // --- Draws the background
        virtual void DrawBackground(void);
      // --- Draws a frame
        virtual void DrawBorder(void);
      // --- Draws a picture
        virtual void DrawImage(void);
    private:
      // --- Handling a button click
        bool OnClickButton(const string pressed_object);
      // --- Change the width along the right edge of the window
        virtual void ChangeWidthByRightWindowSide(void);
    };
 #ifndef CBUTTON_MQH_IMPLEMENTATION
 #define CBUTTON_MQH_IMPLEMENTATION
    //+------------------------------------------------------------------+
    //| Constructor                                                      |
    //+------------------------------------------------------------------+
    CButton::CButton(void) : m_two_state(false) 
     {
        // --- Save the element class name in the base class
        CElementBase::ClassName(CLASS_NAME);
     }
    //+------------------------------------------------------------------+
    //| Destructor                                                       |
    //+------------------------------------------------------------------+
    CButton::~CButton(void) {}
    //+------------------------------------------------------------------+
    // | Event Handler |
    //+------------------------------------------------------------------+
    void CButton::OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam) 
     {
        // --- Handling the cursor movement event
        if (id == CHARTEVENT_MOUSE_MOVE) {
            // --- Redraw the element if there was a border crossing
            if (CElementBase::CheckCrossingBorder())
                Update(true);
            //---
            return;
        }
        // --- Handling the event of pressing the left mouse button on an object
        if (id == CHARTEVENT_OBJECT_CLICK) {
            if (OnClickButton(sparam))
                return;
            //---
            return;
        }
        // --- Handling the left mouse button state change event
        if (id == CHARTEVENT_CUSTOM + ON_CHANGE_MOUSE_LEFT_BUTTON) {
            if (!CElementBase::MouseFocus())
                return;
            // --- Redraw element
            Update(true);
            return;
        }
     }
    //+------------------------------------------------------------------+
    // | Creates an element |
    //+------------------------------------------------------------------+
    bool CButton::CreateButton(const string text, const int x_gap, const int y_gap) 
     {
        // --- Quit if there is no pointer to the main element
        if (!CElement::CheckMainPointer())
            return (false);
        // --- Initializing properties
        InitializeProperties(text, x_gap, y_gap);
        // ---Creating an element
        if (!CButton::CreateCanvas())
            return (false);
        //---
        return (true);
     }
    //+------------------------------------------------------------------+
    // | Initializing properties |
    //+------------------------------------------------------------------+
    void CButton::InitializeProperties(const string text, const int x_gap, const int y_gap) 
     {
        m_x = CElement::CalculateX(x_gap);
        m_y = CElement::CalculateY(y_gap);
        m_x_size = (m_x_size < 1 || m_auto_xresize_mode)
                    ? m_main.X2() - CElementBase::X() - m_auto_xresize_right_offset
                    : m_x_size;
        m_y_size = (m_y_size < 1) ? 20 : m_y_size;
        m_label_text = text;
        // ---Default background color
        m_back_color = (m_back_color != clrNONE) ? m_back_color : clrGainsboro;
        m_back_color_hover =
            (m_back_color_hover != clrNONE) ? m_back_color_hover : C'229,241,251';
        m_back_color_locked =
            (m_back_color_locked != clrNONE) ? m_back_color_locked : clrLightGray;
        m_back_color_pressed = (m_back_color_pressed != clrNONE)
                                ? m_back_color_pressed
                                : C'204,228,247';
        // ---Default frame color
        m_border_color = (m_border_color != clrNONE) ? m_border_color : C'150,170,180';
        m_border_color_hover = (m_border_color_hover != clrNONE) ? m_border_color_hover : C'0,120,215';
        m_border_color_locked = (m_border_color_locked != clrNONE) ? m_border_color_locked : clrDarkGray;
        m_border_color_pressed = (m_border_color_pressed != clrNONE) ? m_border_color_pressed : C'0,84,153';
        // --- Indentation and color of text label and image
        m_icon_x_gap = (m_icon_x_gap != WRONG_VALUE) ? m_icon_x_gap : 0;
        m_icon_y_gap = (m_icon_y_gap != WRONG_VALUE) ? m_icon_y_gap : 0;
        m_label_x_gap = (m_label_x_gap != WRONG_VALUE) ? m_label_x_gap : 24;
        m_label_y_gap = (m_label_y_gap != WRONG_VALUE) ? m_label_y_gap : 4;
        m_label_color = (m_label_color != clrNONE) ? m_label_color : clrBlack;
        m_label_color_hover =
            (m_label_color_hover != clrNONE) ? m_label_color_hover : clrBlack;
        m_label_color_locked =
            (m_label_color_locked != clrNONE) ? m_label_color_locked : clrGray;
        m_label_color_pressed =
            (m_label_color_pressed != clrNONE) ? m_label_color_pressed : clrBlack;
        // --- Indents from the extreme point
        CElementBase::XGap(x_gap);
        CElementBase::YGap(y_gap);
     }
    //+------------------------------------------------------------------+
    // | Creates an object to draw |
    //+------------------------------------------------------------------+
    bool CButton::CreateCanvas(void) 
     {
        // --- Formation of object name
        string name = CElementBase::ElementName("button");
        // ---Create an object
        if (!CElement::CreateCanvas(name, m_x, m_y, m_x_size, m_y_size))
            return (false);
        //---
        return (true);
     }
    //+------------------------------------------------------------------+
    // | Setting the button state - pressed/released |
    //+------------------------------------------------------------------+
    void CButton::IsPressed(const bool state) 
     {
        // --- Exit if (1) not in Two-State mode or (2) the element is locked or (3)
        // the button is already in this state
        if (!m_two_state || CElementBase::IsLocked() || m_is_pressed == state)
            return;
        // ---Status setting
        m_is_pressed = state;
        // --- Set the corresponding picture
        CElement::ChangeImage(0, !m_is_pressed ? 0 : 2);
     }
    //+------------------------------------------------------------------+
    // | Setting a picture for the pressed state (available) |
    //+------------------------------------------------------------------+
    void CButton::IconFilePressed(const string file_path) 
     {
        // --- Exit if the button has "Two states" mode disabled
        if (!m_two_state)
            return;
        // --- Add an image
        CElement::IconFilePressed(file_path);
     }
    //+------------------------------------------------------------------+
    // | Setting the picture for the pressed state (locked) |
    //+------------------------------------------------------------------+
    void CButton::IconFilePressedLocked(const string file_path) {
        // --- Exit if the button has "Two states" mode disabled
        if (!m_two_state)
            return;
        // --- Add an image
        CElement::IconFilePressedLocked(file_path);
    }
    //+------------------------------------------------------------------+
    // | Setting a picture for the pressed state (available) |
    //+------------------------------------------------------------------+
  void CButton::IconFilePressed(const uint resource_index)
   {
    if(!m_two_state)
        return;
    CElement::IconFilePressed(resource_index);
   }
  //+------------------------------------------------------------------+
  // | Setting the picture for the pressed state (locked) |
  //+------------------------------------------------------------------+
  void CButton::IconFilePressedLocked(const uint resource_index)
   {
    if(!m_two_state)
        return;
    CElement::IconFilePressedLocked(resource_index);
   }
  //+------------------------------------------------------------------+
  // | Resizing |
  //+------------------------------------------------------------------+
  void CButton::ChangeSize(const uint x_size, const uint y_size) 
   {
        int images_group = (int)ImagesGroupTotal();
        for (int i = 0; i < images_group; i++) {
            int right_gap = m_x_size - ImageGroupXGap(i);
            ImageGroupXGap(i, (int)x_size - right_gap);
        }
        // --- Set new size
        CElementBase::XSize(x_size);
        CElementBase::YSize(y_size);
        m_canvas.XSize(m_x_size);
        m_canvas.YSize(m_y_size);
        m_canvas.Resize(m_x_size, m_y_size);
    }
  //+------------------------------------------------------------------+
  // | Clicking the button |
  //+------------------------------------------------------------------+
  bool CButton::OnClickButton(const string pressed_object) 
   {
        // --- Exit if (1) the object name is foreign or (2) the element is locked
        if (m_canvas.ChartObjectName() != pressed_object || CElementBase::IsLocked())
            return (false);
        // --- If it is a button with two states
        if (m_two_state)
            IsPressed(!IsPressed());
        // --- Redraw element
        Update(true);
        // --- We will send a message about this
        ::EventChartCustom(m_chart_id, ON_CLICK_BUTTON, CElementBase::Id(),
                        CElementBase::Index(), m_canvas.ChartObjectName());
        return (true);
    }
  //+------------------------------------------------------------------+
  // | Draws an element |
  //+------------------------------------------------------------------+
  void CButton::Draw(void) 
   {
        // --- Draw background
        DrawBackground();
        // --- Draw a frame
        DrawBorder();
        // --- Draw a picture
        DrawImage();
        // --- Draw text
        CElement::DrawText();
    }
  //+------------------------------------------------------------------+
  // | Draws background |
  //+------------------------------------------------------------------+
  void CButton::DrawBackground(void) 
   {
        // --- Determine the color
        uint clr = (m_is_pressed) ? m_back_color_pressed : m_back_color;
        // --- If the element is not locked
        if (!CElementBase::IsLocked()) {
            if (CElementBase::MouseFocus())
                clr = (m_mouse.LeftButtonState() || m_is_pressed) ? m_back_color_pressed
                                                                : m_back_color_hover;
        } else
            clr = m_back_color_locked;
        // --- Drawing the background
        CElement::m_canvas.Erase(::ColorToARGB(clr, m_alpha));
    }
  //+------------------------------------------------------------------+
  // | Draws an input field frame |
  //+------------------------------------------------------------------+
  void CButton::DrawBorder(void) 
   {
        // --- Determine the color
        uint clr = (m_is_pressed) ? m_border_color_pressed : m_border_color;
        // --- If the element is not locked
        if (!CElementBase::IsLocked()) {
            if (CElementBase::MouseFocus())
                clr = (m_mouse.LeftButtonState() || m_is_pressed) ? m_border_color_pressed
                                                                : m_border_color_hover;
        } else
            clr = m_border_color_locked;
        // ---Coordinates
        int x1 = 0, y1 = 0;
        int x2 = (int)::ObjectGetInteger(m_chart_id, m_canvas.ChartObjectName(),
                                        OBJPROP_XSIZE) -
                1;
        int y2 = (int)::ObjectGetInteger(m_chart_id, m_canvas.ChartObjectName(),
                                        OBJPROP_YSIZE) -
                1;
        // --- Draw a rectangle without fill
        m_canvas.Rectangle(x1, y1, x2, y2, ::ColorToARGB(clr));
    }
  //+------------------------------------------------------------------+
  // | Draws a picture |
  //+------------------------------------------------------------------+
  void CButton::DrawImage(void) 
   {
        // --- Define the index
        uint image_index = (!m_two_state) ? 0 : (m_is_pressed) ? 2
                                                            : 0;
        // --- If the element is not locked
        if (!CElementBase::IsLocked()) {
            if (!m_two_state)
                image_index = 0;
            else {
                if (CElementBase::MouseFocus())
                    image_index = (m_mouse.LeftButtonState() || m_is_pressed) ? 2 : 0;
            }
        } else
            image_index = (!m_two_state) ? 1 : (m_is_pressed) ? 3
                                                            : 1;
        // --- Save index of selected image
        CElement::ChangeImage(0, image_index);
        // --- Draw a picture
        CElement::DrawImage();
    }
  //+------------------------------------------------------------------+
  // | Change the width along the right edge of the form |
  //+------------------------------------------------------------------+
  void CButton::ChangeWidthByRightWindowSide(void) 
   {
        // --- Exit if the mode of fixing to the right edge of the form is enabled
        if (m_anchor_right_window_side)
            return;
        // ---Coordinates
        int x = 0;
        // --- Dimensions
        int x_size = m_main.X2() - CElementBase::X() - m_auto_xresize_right_offset;
        int y_size = (m_auto_yresize_mode) ? m_main.Y2() - CElementBase::Y() -
                                                m_auto_yresize_bottom_offset
                                        : m_y_size;
        // --- Set new size
        m_canvas.Resize(x_size, y_size);
        // --- Redraw element
        Draw();
    }
    //+------------------------------------------------------------------+
 #endif // CBUTTON_MQH_IMPLEMENTATION
#endif // __BUTTON_MQH__
