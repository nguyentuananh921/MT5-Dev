//+------------------------------------------------------------------+
//|                                                  SplitButton.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#ifndef __SPLITBUTTON_MQH__
#define __SPLITBUTTON_MQH__
#include "..\Element.mqh"
#include "Button.mqh"
#include "ContextMenu.mqh"
//+------------------------------------------------------------------+
// | Class for creating a double button |
//+------------------------------------------------------------------+
class CSplitButton : public CElement {
  private:
    // --- Objects for creating a button
    CButton m_button;
    CButton m_drop_button;
    CContextMenu m_drop_menu;
    // --- Context menu status
    bool m_drop_menu_state;
    //---
  public:
    CSplitButton(void);
    ~CSplitButton(void);
    // --- Methods for creating a button
    bool CreateSplitButton(const string text, const int x_gap, const int y_gap);
    //---
  private:
    void InitializeProperties(const string text, const int x_gap, const int y_gap);
    bool CreateButton(void);
    bool CreateDropButton(void);
    bool CreateDropMenu(void);
    //---
  public:
    // --- (1) getting the context menu pointer, (2) the general state of the button (available/locked)
    CButton* GetButtonPointer(void) {
        return (::GetPointer(m_button));
    }
    CButton* GetDropButtonPointer(void) {
        return (::GetPointer(m_drop_button));
    }
    CContextMenu* GetContextMenuPointer(void) {
        return (::GetPointer(m_drop_menu));
    }
    // --- Adds a menu item with the specified properties before creating the context menu
    // void              AddItem(const string text,const string path_bmp_on,const string path_bmp_off);
       void                 AddItem(const string text, const uint resource_index_on, const uint resource_index_off);
        // --- Adds a separator line after the specified item before creating the context menu
        void AddSeparateLine(const int item_index);
    //---
  public:
    // ---Graph event handler
    virtual void OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);
    //---
  private:
    // --- Handling a button click
    bool OnClickButton(const string pressed_object, const int id, const int index);
    // --- Handling a click on a button with a drop-down menu
    bool OnClickDropButton(const string pressed_object, const int id, const int index);

    // --- Hides the dropdown menu
    void HideDropDownMenu(void);
};
#ifndef CSPLITBUTTON_MQH_IMPLEMENTATION
#define CSPLITBUTTON_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSplitButton::CSplitButton(void) : m_drop_menu_state(false) {
    // --- Save the element class name in the base class
    CElementBase::ClassName(CLASS_NAME);
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSplitButton::~CSplitButton(void) {
}
//+------------------------------------------------------------------+
// | Event Handler |
//+------------------------------------------------------------------+
void CSplitButton::OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {
    // --- Handling the cursor movement event
    if (id == CHARTEVENT_MOUSE_MOVE) {
        // --- Checking focus on elements
        m_drop_button.MouseFocus(m_mouse.X() > m_drop_button.X() && m_mouse.X() < m_drop_button.X2() &&
                                 m_mouse.Y() > m_drop_button.Y() && m_mouse.Y() < m_drop_button.Y2());
        // --- Outside the element area and with the mouse button pressed
        if (!CElementBase::MouseFocus() && m_mouse.LeftButtonState()) {
            // --- Quit if focus is in the context menu
            if (m_drop_menu.MouseFocus())
                return;
            // ---Hide dropdown menu
            HideDropDownMenu();
            return;
        }
        return;
    }
    // --- Handling a click event on a free menu item
    if (id == CHARTEVENT_CUSTOM + ON_CLICK_FREEMENU_ITEM) {
        // --- Exit if IDs do not match
        if (CElementBase::Id() != lparam)
            return;
        // ---Hide dropdown menu
        HideDropDownMenu();
        // --- We will send a message
        ::EventChartCustom(m_chart_id, ON_CLICK_CONTEXTMENU_ITEM, lparam, dparam, sparam);
        return;
    }
    // --- Handling the event of pressing the left mouse button on an element
    if (id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON) {
        // --- Pressing the main button
        if (OnClickButton(sparam, (int)lparam, (int)dparam))
            return;
        // --- Clicking on a button with a drop-down menu
        if (OnClickDropButton(sparam, (int)lparam, (int)dparam))
            return;
    }
}
//+------------------------------------------------------------------+
// | Creates a "Button" element |
//+------------------------------------------------------------------+
bool CSplitButton::CreateSplitButton(const string text, const int x_gap, const int y_gap) {
    // --- Quit if there is no pointer to the main element
    if (!CElement::CheckMainPointer())
        return (false);
    // ---Initializing properties
    InitializeProperties(text, x_gap, y_gap);
    // --- Creating a button
    if (!CreateButton())
        return (false);
    if (!CreateDropButton())
        return (false);
    if (!CreateDropMenu())
        return (false);
    //---
    return (true);
}
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CSplitButton::InitializeProperties(const string text, const int x_gap, const int y_gap) {
    m_x = CElement::CalculateX(x_gap);
    m_y = CElement::CalculateY(y_gap);
    m_label_text = text;
    m_x_size = (m_x_size < 1) ? 80 : m_x_size;
    m_y_size = (m_y_size < 1) ? 20 : m_y_size;
    // --- Indents from the extreme point
    CElementBase::XGap(x_gap);
    CElementBase::YGap(y_gap);
    // ---Priority is the same as the main element, since the element does not have its own clickable area
    CElement::Z_Order(m_main.Z_Order());
}
//+------------------------------------------------------------------+
// | Creates a button |
//+------------------------------------------------------------------+
bool CSplitButton::CreateButton(void) {
    // --- Save a pointer to the parent element
    m_button.MainPointer(this);
    // --- Dimensions
    int x_size = m_x_size - 18;
    // --- Coordinates
    int x = 0, y = 0;
    // --- Indents for the image
    int icon_x_gap = (m_button.IconXGap() < 1) ? 3 : m_button.IconXGap();
    int icon_y_gap = (m_button.IconYGap() < 1) ? 3 : m_button.IconYGap();
    // --- Properties
    m_button.NamePart("split_button");
    m_button.Index(0);
    m_button.Alpha(m_alpha);
    m_button.XSize(x_size);
    m_button.YSize(m_y_size);
    m_button.IconXGap(icon_x_gap);
    m_button.IconYGap(icon_y_gap);
    m_button.IconFile(IconFile());
    m_button.IconFileLocked(IconFileLocked());
    // --- Let's create a control
    if (!m_button.CreateButton(m_label_text, x, y))
        return (false);
    // --- Add element to array
    CElement::AddToArray(m_button);
    return (true);
}
//+------------------------------------------------------------------+
// | Creates a button to call the context menu |
//+------------------------------------------------------------------+
bool CSplitButton::CreateDropButton(void) {
    // --- Save a pointer to the parent element
    m_drop_button.MainPointer(this);
    // --- Dimensions
    int x_size = 18;
    // --- Coordinates
    int x = m_button.XSize() - 1, y = 0;
    // --- Indents for the image
    int icon_x_gap = (m_drop_button.IconXGap() < 1) ? 1 : m_drop_button.IconXGap();
    int icon_y_gap = (m_drop_button.IconYGap() < 1) ? 3 : m_drop_button.IconYGap();
    // --- Set the properties before creating
    m_drop_button.NamePart("split_button");
    m_drop_button.Index(1);
    m_drop_button.Alpha(m_alpha);
    m_drop_button.TwoState(true);
    m_drop_button.XSize(x_size);
    m_drop_button.YSize(m_y_size);
    m_drop_button.IconXGap(icon_x_gap);
    m_drop_button.IconYGap(icon_y_gap);
    m_drop_button.IconFile(IMAGE_RESOURCE_CONTROLS_DOWN_THIN_BLACK_BMP);
    m_drop_button.IconFileLocked(IMAGE_RESOURCE_CONTROLS_DOWN_THIN_BLACK_BMP);
    m_drop_button.CElement::IconFilePressed(IMAGE_RESOURCE_CONTROLS_UP_THIN_BLACK_BMP);
    m_drop_button.CElement::IconFilePressedLocked(IMAGE_RESOURCE_CONTROLS_UP_THIN_BLACK_BMP);
    // --- Let's create a control
    if (!m_drop_button.CreateButton("", x, y))
        return (false);
    // --- Add element to array
    CElement::AddToArray(m_drop_button);
    return (true);
}
//+------------------------------------------------------------------+
// | Creates a dropdown menu |
//+------------------------------------------------------------------+
bool CSplitButton::CreateDropMenu(void) {
    // --- Save the pointer to the main element
    m_drop_menu.MainPointer(this);
    // --- Free context menu
    m_drop_menu.FreeContextMenu(true);
    // --- Coordinates
    int x = 0, y = m_y_size;
    // --- Set properties
    m_drop_menu.XSize((m_drop_menu.XSize() > 0) ? m_drop_menu.XSize() : m_x_size - 1);
    // --- Set up a context menu
    if (!m_drop_menu.CreateContextMenu(x, y))
        return (false);
    // --- Add element to array
    CElement::AddToArray(m_drop_menu);
    return (true);
}
//+------------------------------------------------------------------+
// | Adds a menu item |
//+------------------------------------------------------------------+
// void CSplitButton::AddItem(const string text,const string path_bmp_on,const string path_bmp_off)
void CSplitButton::AddItem(const string text, const uint resource_index_on, const uint resource_index_off) {
    m_drop_menu.AddItem(text, resource_index_on, resource_index_off, MI_SIMPLE);
}
//+------------------------------------------------------------------+
// | Adds a dividing line |
//+------------------------------------------------------------------+
void CSplitButton::AddSeparateLine(const int item_index) {
    m_drop_menu.AddSeparateLine(item_index);
}
//+------------------------------------------------------------------+
// | Clicking the button |
//+------------------------------------------------------------------+
bool CSplitButton::OnClickButton(const string pressed_object, const int id, const int index) {
    // --- Exit if the button was not pressed
    if (::StringFind(pressed_object, "split_button") < 0)
        return (false);
    // --- Exit if (1) IDs do not match or (2) element is locked
    if (id != CElementBase::Id() || index != m_button.Index() || CElementBase::IsLocked())
        return (false);
    // --- Hide the menu
    HideDropDownMenu();
    // --- We will send a message about this
    ::EventChartCustom(m_chart_id, ON_CLICK_BUTTON, CElementBase::Id(), CElementBase::Index(), "");
    return (true);
}
//+------------------------------------------------------------------+
// | Clicking a button with a drop-down menu |
//+------------------------------------------------------------------+
bool CSplitButton::OnClickDropButton(const string pressed_object, const int id, const int index) {
    // --- Exit if the button was not pressed
    if (::StringFind(pressed_object, "split_button") < 0)
        return (false);
    // --- Exit if (1) IDs do not match or (2) element is locked
    if (id != CElementBase::Id() || index != m_drop_button.Index() || CElementBase::IsLocked())
        return (false);
    // --- If the list is open, hide it
    if (m_drop_menu_state) {
        m_drop_menu_state = false;
        m_drop_menu.Hide();
        // --- Send a message to determine available elements
        ::EventChartCustom(m_chart_id, ON_SET_AVAILABLE, CElementBase::Id(), 1, "");
    }
    // --- If the list is hidden, open it
    else {
        m_drop_menu_state = true;
        m_drop_menu.Show();
        // --- Send a message to determine available elements
        ::EventChartCustom(m_chart_id, ON_SET_AVAILABLE, CElementBase::Id(), 0, "");
    }
    // --- Send a message about the change in the graphical interface
    ::EventChartCustom(m_chart_id, ON_CHANGE_GUI, CElementBase::Id(), 0.0, "");
    return (true);
}
//+------------------------------------------------------------------+
// | Hides dropdown menu |
//+------------------------------------------------------------------+
void CSplitButton::HideDropDownMenu(void) {
    // --- Hide the menu and set the appropriate attributes
    m_drop_menu.Hide();
    m_drop_menu_state = false;
    // --- Release the button if pressed
    if (m_drop_button.IsPressed()) {
        m_drop_button.IsPressed(false);
        m_drop_button.Update(true);
        // --- Send a message to determine available elements
        ::EventChartCustom(m_chart_id, ON_SET_AVAILABLE, CElementBase::Id(), 1, "");
        // --- Send a message about the change in the graphical interface
        ::EventChartCustom(m_chart_id, ON_CHANGE_GUI, CElementBase::Id(), 0.0, "");
    }
}
//+------------------------------------------------------------------+
#endif // CSPLITBUTTON_MQH_IMPLEMENTATION
#endif // __SPLITBUTTON_MQH__
