//+------------------------------------------------------------------+
//|                                                     Calendar.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#ifndef __CALENDAR_MQH__
#define __CALENDAR_MQH__
 #include "..\Element.mqh"
 #include "TextEdit.mqh"
 #include "ComboBox.mqh"
 #include "Button.mqh"
 #include "ButtonsGroup.mqh"
 #include <Tools\DateTime.mqh>
 // --- Number of days in the table
 #define DAYS_TOTAL 42
 //+------------------------------------------------------------------+
 // | Class for creating a calendar |
 //+------------------------------------------------------------------+
 class CCalendar : public CElement 
  {
    private:
     // --- Elements for creating a calendar
        CButton m_month_dec;
        CButton m_month_inc;
        CComboBox m_months;
        CTextEdit m_years;
        CButtonsGroup m_days;
        CButton m_button_today;
     // --- Instances of the structure for working with dates and times:
        CDateTime m_date;      // user selected date
        CDateTime m_today;     // current (local on the user's computer) date
        CDateTime m_temp_date; // copy for calculations and checks
     // --- Current day item color
        color m_today_color;
     // --- Dividing line color
        color m_sepline_color;
     // --- Timer counter for list rewind
        int m_timer_counter;
        //---
    public:
        CCalendar(void);
        ~CCalendar(void);
        // ---Methods for creating a calendar
        bool CreateCalendar(const int x_gap, const int y_gap);
        //---
    private:
        void InitializeProperties(const int x_gap, const int y_gap);
        bool CreateCanvas(void);
        bool CreateMonthArrow(CButton& button_obj, const int index);
        bool CreateMonthsList(void);
        bool CreateYearsSpinEdit(void);
        bool CreateDaysMonth(void);
        bool CreateButtonToday(void);
        //---
    public:
        // --- Returns pointers to calendar items
        CButton*    GetMonthDecPointer(void)    {return (::GetPointer(m_month_dec));}
        CButton*    GetMonthIncPointer(void)    {return (::GetPointer(m_month_inc));}
        CComboBox*  GetComboBoxPointer(void)    {return (::GetPointer(m_months));}
        CTextEdit*  GetSpinEditPointer(void)    {return (::GetPointer(m_years));}
        CButton*    GetTodayButtonPointer(void) {return (::GetPointer(m_button_today));}
        CButtonsGroup* GetDayButtonsPointer(void) {return (::GetPointer(m_days));}
        // --- (1) get the current date in the calendar, (2) Set (select) and (3) get the selected date
        datetime    Today(void)                 {return (m_today.DateTime());}
        datetime    SelectedDate(void)          {return (m_date.DateTime());}
        void        SelectedDate(const datetime date);
        // --- Display the latest changes in the calendar
        void UpdateCalendar(void);
        // --- Updates calendar items
        void UpdateElements(void);
        // --- Update current date
        void UpdateCurrentDate(void);
        //---
    public:
        // ---Graph event handler
        virtual void OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);
        // --- Timer
        virtual void OnEventTimer(void);
        // --- Show
        virtual void Show(void);
        // --- Draws an element
        virtual void Draw(void);
        //---
    private:
        // --- Handling clicks on the button to go to the previous month
        bool OnClickMonthDec(const string clicked_object, const int id, const int index);
        // --- Handling clicks on the button to go to the next month
        bool OnClickMonthInc(const string clicked_object, const int id, const int index);
        // --- Handling month selection in list
        bool OnClickMonthList(const int id);
        // --- Processing the value entered in the years input field
        bool OnEndEnterYear(const string edited_object, const int id);
        // --- Handling clicks on the button to move to the next year
        bool OnClickYearInc(const string clicked_object, const int id, const int index);
        // --- Handling clicks on the button to go to the previous year
        bool OnClickYearDec(const string clicked_object, const int id, const int index);
        // --- Handling clicks on the day of the month
        bool OnClickDayOfMonth(const string clicked_object, const int id, const int index);
        // --- Handling a click on the button to go to the current date
        bool OnClickTodayButton(const string clicked_object, const int id, const int index);

        // ---Adjustment of the allocated day by the number of days in the month
        void CorrectingSelectedDay(void);
        // --- Determining the difference from the first item of the calendar table to the item of the first day of the current month
        int OffsetFirstDayOfMonth(void);
        // --- Displays the latest changes in the calendar table
        void SetCalendar(void);
        // --- Fast forward calendar values
        void FastSwitching(void);
        // --- Highlighting the current day and the user-selected day
        void HighlightDate(void);
        // --- Resetting the time to the beginning of the day
        void ResetTime(void);

        // --- Draws the names of the days of the week
        void DrawDaysWeek(void);
        // --- Draws a dividing line
        void DrawSeparateLine(void);
  };
#ifndef CCALENDAR_MQH_IMPLEMENTATION
#define CCALENDAR_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCalendar::CCalendar(void) : m_today_color(C'0,102,204') 
 {
    // --- Save the element class name in the base class
    CElementBase::ClassName(CLASS_NAME);
    // ---Initializing time structures
    m_date.DateTime(::TimeLocal());
    m_today.DateTime(::TimeLocal());
 }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CCalendar::~CCalendar(void) {}
//+------------------------------------------------------------------+
// | Event Handler |
//+------------------------------------------------------------------+
void CCalendar::OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam) 
 {
  // --- Handling the event of selecting an item in a drop-down list
    if (id == CHARTEVENT_CUSTOM + ON_CLICK_COMBOBOX_ITEM) {
        // --- Processing the value entered in the years input field
        if (OnClickMonthList((int)lparam))
            return;
        //---
        return;
    }
  // --- Handling the event of entering a value in the input field
    if (id == CHARTEVENT_CUSTOM + ON_END_EDIT) 
    {
        // --- Processing the value entered in the years input field
        if (OnEndEnterYear(sparam, (int)lparam))
            return;
        //---
        return;
    }
  // --- Handling the click event on a button in a group
    if (id == CHARTEVENT_CUSTOM + ON_CLICK_GROUP_BUTTON) {
        // --- Handling clicks on the bottom of the calendar
        if (OnClickDayOfMonth(sparam, (int)lparam, (int)dparam))
            return;
        //---
        return;
    }
  // --- Handling the button click event
    if (id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON) {
        // --- Handling clicks on month switching buttons
        if (OnClickMonthDec(sparam, (int)lparam, (int)dparam))
            return;
        if (OnClickMonthInc(sparam, (int)lparam, (int)dparam))
            return;
        // --- Processing clicks on transition buttons by year
        if (OnClickYearInc(sparam, (int)lparam, (int)dparam))
            return;
        if (OnClickYearDec(sparam, (int)lparam, (int)dparam))
            return;
        // --- Handling a click on the button to go to the current date
        if (OnClickTodayButton(sparam, (int)lparam, (int)dparam))
            return;
        //---
        return;
    }
 }
//+------------------------------------------------------------------+
// | Timer |
//+------------------------------------------------------------------+
void CCalendar::OnEventTimer(void) 
 {
    // --- Fast forward values
    FastSwitching();
    // ---Updating the current calendar date
    UpdateCurrentDate();
 }
//+------------------------------------------------------------------+
// | Creates a context menu |
//+------------------------------------------------------------------+
bool CCalendar::CreateCalendar(const int x_gap, const int y_gap) 
 {
    // --- Quit if there is no pointer to the main element
    if (!CElement::CheckMainPointer())
        return (false);
    // ---Initializing properties
    InitializeProperties(x_gap, y_gap);
    // ---Creating an element
    if (!CreateCanvas())
        return (false);
    if (!CreateMonthArrow(m_month_dec, 0))
        return (false);
    if (!CreateMonthArrow(m_month_inc, 1))
        return (false);
    if (!CreateMonthsList())
        return (false);
    if (!CreateYearsSpinEdit())
        return (false);
    if (!CreateDaysMonth())
        return (false);
    if (!CreateButtonToday())
        return (false);
    // --- Refresh calendar
    UpdateCalendar();
    return (true);
 }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CCalendar::InitializeProperties(const int x_gap, const int y_gap) 
 {
    m_x = CElement::CalculateX(x_gap);
    m_y = CElement::CalculateY(y_gap);
    m_x_size = 161;
    m_y_size = 158;
    // ---Default colors
    m_back_color = (m_back_color != clrNONE) ? m_back_color : clrWhite;
    m_border_color = (m_border_color != clrNONE) ? m_border_color : C'150,170,180';
    m_label_color = (m_label_color != clrNONE) ? m_label_color : clrBlack;
    m_label_color_locked = (m_label_color_locked != clrNONE) ? m_label_color_locked :C'200,200,200';
    // --- Indents from the extreme point
    CElementBase::XGap(x_gap);
    CElementBase::YGap(y_gap);
 }
//+------------------------------------------------------------------+
// | Creates an object to draw |
//+------------------------------------------------------------------+
bool CCalendar::CreateCanvas(void) 
 {
    // --- Formation of object name
    string name = CElementBase::ElementName("calendar");
    // ---Create an object
    if (!CElement::CreateCanvas(name, m_x, m_y, m_x_size, m_y_size))
        return (false);
    //---
    return (true);
 }
//+------------------------------------------------------------------+
// | Creates a month switch to the left |
//+------------------------------------------------------------------+
bool CCalendar::CreateMonthArrow(CButton& button_obj, const int index) 
 {
    // --- Save the pointer to the main element
    button_obj.MainPointer(this);
    // --- Dimensions
    int x_size = 12;
    int y_size = 18;
    // --- Indent
    int offset = 2;
    // ---Coordinates
    int x = (index < 1) ? offset : x_size + offset;
    int y = offset;
    // --- Properties
    button_obj.Index(index);
    button_obj.XSize(x_size);
    button_obj.YSize(y_size);
    button_obj.IconXGap(-2);
    button_obj.IconYGap(1);
    button_obj.IsDropdown(CElementBase::IsDropdown());
    // --- Labels for buttons
    if (index < 1) {
        button_obj.IconFile(IMAGE_RESOURCE_CONTROLS_LEFT_THIN_BLACK_BMP);
        button_obj.IconFileLocked(IMAGE_RESOURCE_CONTROLS_LEFT_THIN_BLACK_BMP);
    } else {
        button_obj.IconFile(IMAGE_RESOURCE_CONTROLS_RIGHT_THIN_BLACK_BMP);
        button_obj.IconFileLocked(IMAGE_RESOURCE_CONTROLS_RIGHT_THIN_BLACK_BMP);
        button_obj.AnchorRightWindowSide(true);
    }
    // --- Let's create a control
    if (!button_obj.CreateButton("", x, y))
        return (false);
    // --- Add element to array
    CElement::AddToArray(button_obj);
    return (true);
 }
//+------------------------------------------------------------------+
// | Creates a combo box with months |
//+------------------------------------------------------------------+
bool CCalendar::CreateMonthsList(void) 
 {
    // --- Save the pointer to the main element
    m_months.MainPointer(this);
    // --- Coordinates
    int x = 14, y = 2;
    // --- Properties
    m_months.XSize(50);
    m_months.YSize(18);
    m_months.ItemsTotal(12);
    m_months.GetButtonPointer().XGap(1);
    m_months.GetButtonPointer().LabelYGap(3);
    m_months.IsDropdown(CElementBase::IsDropdown());
    // --- Get a pointer to the list
    CListView* lv = m_months.GetListViewPointer();
    // --- Set list properties
    lv.YSize(93);
    lv.LightsHover(true);
    // --- Enter the values ​​into the list (month names)
    for (int i = 0; i < 12; i++)
        m_months.SetValue(i, m_date.MonthName(i + 1));
    // --- Select the current month in the list
    m_months.SelectItem(m_date.mon - 1);
    // --- Let's create a control
    if (!m_months.CreateComboBox("", x, y))
        return (false);
    // --- Add element to array
    CElement::AddToArray(m_months);
    return (true);
 }
//+------------------------------------------------------------------+
// | Creates a year input field |
//+------------------------------------------------------------------+
bool CCalendar::CreateYearsSpinEdit(void) 
 {
    // --- Save the pointer to the main element
    m_years.MainPointer(this);
    // --- Coordinates
    int x = 95, y = 2;
    // --- Properties
    m_years.Index(m_is_dropdown ? 1 : 0);
    m_years.XSize(50);
    m_years.YSize(18);
    m_years.MaxValue(2099);
    m_years.MinValue(1970);
    m_years.StepValue(1);
    m_years.SetDigits(0);
    m_years.SpinEditMode(true);
    m_years.GetTextBoxPointer().AutoSelectionMode(true);
    m_years.SetValue((string)m_date.year);
    m_years.GetTextBoxPointer().XGap(1);
    m_years.GetTextBoxPointer().XSize(50);
    m_years.GetIncButtonPointer().NamePart("cal_spin_inc");
    m_years.GetDecButtonPointer().NamePart("cal_spin_dec");
    // --- Let's create a control
    if (!m_years.CreateTextEdit("", x, y))
        return (false);
    // --- Indent text in the input field
    m_years.GetTextBoxPointer().TextYOffset(4);
    // --- Add element to array
    CElement::AddToArray(m_years);
    return (true);
 }
//+------------------------------------------------------------------+
// | Creates a table of days of the month |
//+------------------------------------------------------------------+
bool CCalendar::CreateDaysMonth(void) 
 {
    // --- Day counter
    int i = 0;
    // --- Coordinates and indentations
    int x = 0, y = 0;
    int x_offset = 7, y_offset = 44;
    // --- Dimensions
    int x_size = 21, y_size = 15;
    // --- Save the pointer to the main element
    m_days.MainPointer(this);
    //---
    int buttons_x_offset[DAYS_TOTAL] = {};
    int buttons_y_offset[DAYS_TOTAL] = {};
    string buttons_text[DAYS_TOTAL] = {};
    // --- Set up calendar day table objects
    for (int r = 0; r < 6; r++) {
        // --- Y coordinate calculation
        y = (r > 0) ? y + y_size : 0;
        //---
        for (int c = 0; c < 7; c++) {
            // --- X coordinate calculation
            x = (c > 0) ? x + x_size : 0;
            //--
            buttons_text[i] = string(i);
            buttons_x_offset[i] = x;
            buttons_y_offset[i] = y;
            //---
            i++;
        }
    }
    // --- Properties
    m_days.NamePart("day");
    m_days.ButtonYSize(y_size);
    m_days.LabelYGap(1);
    m_days.IsCenterText(true);
    m_days.RadioButtonsMode(true);
    m_days.IsDropdown(CElementBase::IsDropdown());

    // --- Add buttons to the group
    for (int j = 0; j < DAYS_TOTAL; j++)
        m_days.AddButton(buttons_x_offset[j], buttons_y_offset[j], buttons_text[j], x_size);

    // --- Create a button group
    x = x_offset;
    y = y_offset;
    if (!m_days.CreateButtonsGroup(x, y))
        return (false);
    // --- Properties
    for (int j = 0; j < DAYS_TOTAL; j++) {
        m_days.GetButtonPointer(j).BackColor(m_back_color);
        m_days.GetButtonPointer(j).BorderColor(m_back_color);
    }
    // --- Add element to array
    CElement::AddToArray(m_days);
    return (true);
 }
//+------------------------------------------------------------------+
// | Creates a button to go to the current date |
//+------------------------------------------------------------------+
bool CCalendar::CreateButtonToday(void) 
 {
    // --- Save the pointer to the main element
    m_button_today.MainPointer(this);
    // --- Coordinates
    int x = 22, y = YSize() - 23;
    // --- Properties
    m_button_today.NamePart("today_button");
    m_button_today.Index(2);
    m_button_today.XSize(120);
    m_button_today.YSize(20);
    m_button_today.IconXGap(1);
    m_button_today.IconYGap(1);
    m_button_today.LabelXGap(25);
    m_button_today.LabelYGap(4);
    m_button_today.BackColor(m_back_color);
    m_button_today.BackColorHover(m_back_color);
    m_button_today.BackColorLocked(m_back_color);
    m_button_today.BackColorPressed(m_back_color);
    m_button_today.BorderColor(m_back_color);
    m_button_today.BorderColorHover(m_back_color);
    m_button_today.BorderColorLocked(m_back_color);
    m_button_today.BorderColorPressed(m_back_color);
    m_button_today.LabelColorHover(C'0,102,250');
    m_button_today.IsDropdown(CElementBase::IsDropdown());
    m_button_today.IconFile(IMAGE_RESOURCE_CONTROLS_CALENDAR_TODAY_BMP);
    m_button_today.IconFileLocked(IMAGE_RESOURCE_CONTROLS_CALENDAR_TODAY_BMP);
    m_button_today.CElement::IconFilePressed(IMAGE_RESOURCE_CONTROLS_CALENDAR_TODAY_BMP);
    m_button_today.CElement::IconFilePressedLocked(IMAGE_RESOURCE_CONTROLS_CALENDAR_TODAY_BMP);
    // --- Let's create a control
    if (!m_button_today.CreateButton("Today: " + ::TimeToString(::TimeLocal(), TIME_DATE), x, y))
        return (false);
    // --- Add element to array
    CElement::AddToArray(m_button_today);
    return (true);
 }
//+------------------------------------------------------------------+
// | Selecting a new date |
//+------------------------------------------------------------------+
void CCalendar::SelectedDate(const datetime date) 
 {
    // --- Storing date in class structure and field
    m_date.DateTime(date);
    // --- Display the latest changes in the calendar
    UpdateCalendar();
 }
//+------------------------------------------------------------------+
// | Show the latest changes in the calendar |
//+------------------------------------------------------------------+
void CCalendar::UpdateCalendar(void) 
 {
    // --- Display changes in calendar table
    SetCalendar();
    // --- Highlighting the current day and the user-selected day
    HighlightDate();
    // --- Set the year in the input field
    m_years.SetValue((string)m_date.year, false);
    // --- Set the month in the combo box list
    m_months.SelectItem(m_date.mon - 1);
 }
//+------------------------------------------------------------------+
// | Updates calendar items |
//+------------------------------------------------------------------+
void CCalendar::UpdateElements(void) 
 {
    m_years.GetTextBoxPointer().Update(true);
    m_months.GetButtonPointer().Update(true);
    m_days.Update(true);
 }
//+------------------------------------------------------------------+
// | Update current date |
//+------------------------------------------------------------------+
void CCalendar::UpdateCurrentDate(void) 
 {
    // --- Counter
    static int count = 0;
    // --- Exit if less than a second has passed
    if (count < 1000) {
        count += TIMER_STEP_MSC;
        return;
    }
    // --- Reset counter
    count = 0;
    // --- Get the current (local) time
    MqlDateTime local_time;
    ::TimeToStruct(::TimeLocal(), local_time);
    // ---If a new day has come
    if (local_time.day != m_today.day) {
        // --- Update date in calendar
        m_today.DateTime(::TimeLocal());
        m_button_today.LabelText(::TimeToString(m_today.DateTime()));
        // --- Show recent changes in calendar
        UpdateCalendar();
        return;
    }
    // --- Update date in calendar
    m_today.DateTime(::TimeLocal());
 }
//+------------------------------------------------------------------+
// | Shows calendar |
//+------------------------------------------------------------------+
void CCalendar::Show(void) 
 {
    // --- If the calendar does not drop down, make all its elements visible
    CElement::Show();
    // --- If the calendar drops down
    if (CElementBase::IsDropdown()) {
        int elements_total = ElementsTotal();
        for (int i = 0; i < elements_total; i++)
            m_elements[i].Show();
    }
 }
//+------------------------------------------------------------------+
// | Click on the left arrow. Go to previous month.          |
//+------------------------------------------------------------------+
bool CCalendar::OnClickMonthDec(const string clicked_object, const int id, const int index) 
 {
    // --- Exit if the click was not on this element
    if (!m_month_dec.CheckElementName(clicked_object))
        return (false);
    // --- Exit if (1) IDs do not match or (2) element is locked
    if (id != CElementBase::Id() || index != m_month_dec.Index() || CElementBase::IsLocked())
        return (false);
    // --- If the current year in the calendar is equal to the minimum specified and the current month is "January"
    if (m_date.year == m_years.MinValue() && m_date.mon == 1)
        return (true);
    // ---Go to previous month
    m_date.MonDec();
    // --- Set the first day of the month
    m_date.day = 1;
    // --- Set the time to the beginning of the day
    ResetTime();
    // --- Display the latest changes in the calendar
    UpdateCalendar();
    // --- Updates calendar items
    UpdateElements();
    // --- We will send a message about this
    ::EventChartCustom(m_chart_id, ON_CHANGE_DATE, CElementBase::Id(), m_date.DateTime(), "");
    return (true);
 }
//+------------------------------------------------------------------+
// | Click on the left arrow. Move to next month.           |
//+------------------------------------------------------------------+
bool CCalendar::OnClickMonthInc(const string clicked_object, const int id, const int index) 
 {
    // --- Exit if the click was not on this element
    if (!m_month_inc.CheckElementName(clicked_object))
        return (false);
    // --- Exit if (1) IDs do not match or (2) element is locked
    if (id != CElementBase::Id() || index != m_month_inc.Index() || CElementBase::IsLocked())
        return (false);
    // --- If the current year in the calendar is equal to the maximum specified and the current month is "December"
    if (m_date.year == m_years.MaxValue() && m_date.mon == 12)
        return (true);
    // ---Go to next month
    m_date.MonInc();
    // --- Set the first day of the month
    m_date.day = 1;
    // --- Set the time to the beginning of the day
    ResetTime();
    // --- Display the latest changes in the calendar
    UpdateCalendar();
    // --- Updates calendar items
    UpdateElements();
    // --- We will send a message about this
    ::EventChartCustom(m_chart_id, ON_CHANGE_DATE, CElementBase::Id(), m_date.DateTime(), "");
    return (true);
 }
//+------------------------------------------------------------------+
// | Handling month selection in list |
//+------------------------------------------------------------------+
bool CCalendar::OnClickMonthList(const int id) 
 {
    // --- Exit if element IDs do not match
    if (id != CElementBase::Id())
        return (false);
    // --- Get the selected month in the list
    int month = m_months.GetListViewPointer().SelectedItemIndex() + 1;
    m_date.Mon(month);
    // ---Adjustment of the allocated day by the number of days in the month
    CorrectingSelectedDay();
    // --- Set the time to the beginning of the day
    ResetTime();
    // --- Display changes in calendar table
    UpdateCalendar();
    // --- Updates calendar items
    UpdateElements();
    // --- We will send a message about this
    ::EventChartCustom(m_chart_id, ON_CHANGE_DATE, CElementBase::Id(), m_date.DateTime(), "");
    return (true);
 }
//+------------------------------------------------------------------+
// | Processing the entry of a value in the years input field |
//+------------------------------------------------------------------+
bool CCalendar::OnEndEnterYear(const string edited_object, const int id) 
 {
    // --- Exit if (1) IDs do not match or (2) element is locked
    if (id != CElementBase::Id() || CElementBase::IsLocked())
        return (false);
    // --- Exit if the value has not changed
    string value = m_years.GetValue();
    if (m_date.year == (int)value) {
        // --- Updates the input field
        m_years.GetTextBoxPointer().Update(true);
        return (false);
    }
    // --- We will adjust the value if the established limits are exceeded
    if ((int)value < m_years.MinValue())
        value = (string) int(m_years.MinValue());
    if ((int)value > m_years.MaxValue())
        value = (string) int(m_years.MaxValue());
    // --- Determine the number of days in the current month
    string year = value;
    string month = string(m_date.mon);
    string day = string(1);
    m_temp_date.DateTime(::StringToTime(year + "." + month + "." + day));
    // --- If the value of the selected day is greater than the number of days in the month,
    // set the current number of days in the month as the allocated day
    if (m_date.day > m_temp_date.DaysInMonth())
        m_date.day = m_temp_date.DaysInMonth();
    // --- Set the date to the structure
    m_date.DateTime(::StringToTime(year + "." + month + "." + string(m_date.day)));
    // --- Display changes in the calendar table
    UpdateCalendar();
    // --- Updates calendar items
    UpdateElements();
    // --- We will send a message about this
    ::EventChartCustom(m_chart_id, ON_CHANGE_DATE, CElementBase::Id(), m_date.DateTime(), "");
    return (true);
 }
//+------------------------------------------------------------------+
// | Processing a click on the button to go to next year |
//+------------------------------------------------------------------+
bool CCalendar::OnClickYearInc(const string clicked_object, const int id, const int index) 
 {
    // --- Exit if the click was not on this element
    if (!m_years.GetIncButtonPointer().CheckElementName(clicked_object))
        return (false);
    // --- If the list of months is open, close it
    if (m_months.GetListViewPointer().IsVisible())
        m_months.ChangeComboBoxListState();
    // --- Exit if element IDs do not match
    if (id != CElementBase::Id())
        return (false);
    // --- If the year is less than the maximum specified, increase the value by one
    if (m_date.year < m_years.MaxValue())
        m_date.YearInc();
    // ---Adjustment of the allocated day by the number of days in the month
    CorrectingSelectedDay();
    // --- Display changes in calendar table
    UpdateCalendar();
    // --- Updates calendar items
    UpdateElements();
    // --- We will send a message about this
    ::EventChartCustom(m_chart_id, ON_CHANGE_DATE, CElementBase::Id(), m_date.DateTime(), "");
    return (true);
 }
//+------------------------------------------------------------------+
// | Processing a click on the button to go to the previous year |
//+------------------------------------------------------------------+
bool CCalendar::OnClickYearDec(const string clicked_object, const int id, const int index)
 {
    // --- Exit if the click was not on this element
    if (!m_years.GetDecButtonPointer().CheckElementName(clicked_object))
        return (false);
    // --- If the list of months is open, close it
    if (m_months.GetListViewPointer().IsVisible())
        m_months.ChangeComboBoxListState();
    // --- Exit if element IDs do not match
    if (id != CElementBase::Id())
        return (false);
    // --- If the year is greater than the minimum specified, reduce the value by one
    if (m_date.year > m_years.MinValue())
        m_date.YearDec();
    // ---Adjustment of the allocated day by the number of days in the month
    CorrectingSelectedDay();
    // --- Display changes in calendar table
    UpdateCalendar();
    // --- Updates calendar items
    UpdateElements();
    // --- We will send a message about this
    ::EventChartCustom(m_chart_id, ON_CHANGE_DATE, CElementBase::Id(), m_date.DateTime(), "");
    return (true);
 }
//+------------------------------------------------------------------+
// | Handling a click on the day of the calendar month |
//+------------------------------------------------------------------+
bool CCalendar::OnClickDayOfMonth(const string clicked_object, const int id, const int index) 
 {
    // --- Exit if (1) IDs do not match or (2) element is locked
    if (id != CElementBase::Id() || CElementBase::IsLocked())
        return (false);
    // --- Determining the difference from the first item of the calendar table to the item of the first day of the current month
    OffsetFirstDayOfMonth();
    // --- Let's go through the calendar table items in a cycle
    int items_total = m_days.ButtonsTotal();
    for (int i = 0; i < items_total; i++) {
        // --- If the date of the current item is less than the minimum set in the system
        if (m_temp_date.DateTime() < datetime(D'01.01.1970')) {
            // --- If it's a clicked object
            if (i == index)
                return (false);
            // ---Go to next date
            m_temp_date.DayInc();
            continue;
        }
        // --- If it's a clicked object
        if (i == index) {
            // --- Save the date
            m_date.DateTime(m_temp_date.DateTime());
            // --- Display the latest changes in the calendar
            UpdateCalendar();
            break;
        }
        // ---Go to next date
        m_temp_date.DayInc();
        // --- Checking the maximum set in the system
        if (m_temp_date.year > m_years.MaxValue())
            return (false);
    }
    // --- Updates calendar items
    UpdateElements();
    // --- We will send a message about this
    ::EventChartCustom(m_chart_id, ON_CHANGE_DATE, CElementBase::Id(), m_date.DateTime(), "");
    return (true);
 }
//+------------------------------------------------------------------+
// | Processing a click on the button to go to the current date |
//+------------------------------------------------------------------+
bool CCalendar::OnClickTodayButton(const string clicked_object, const int id, const int index) 
 {
    // --- Exit if object name is foreign
    if (::StringFind(clicked_object, m_button_today.NamePart(), 0) < 0)
        return (false);
    // --- Exit if element IDs do not match
    if (id != CElementBase::Id())
        return (false);
    // --- If the list of months is open, close it
    if (m_months.GetListViewPointer().IsVisible())
        m_months.ChangeComboBoxListState();
    // ---Set current date
    m_date.DateTime(::TimeLocal());
    // --- Display the latest changes in the calendar
    UpdateCalendar();
    // --- Updates calendar items
    UpdateElements();
    // --- We will send a message about this
    ::EventChartCustom(m_chart_id, ON_CHANGE_DATE, CElementBase::Id(), m_date.DateTime(), "");
    return (true);
 }
//+------------------------------------------------------------------+
// | Determining the first day of the month |
//+------------------------------------------------------------------+
void CCalendar::CorrectingSelectedDay(void) 
 {
    // --- Set the current number of days in the month if the value of the selected day is greater
    if (m_date.day > m_date.DaysInMonth())
        m_date.day = m_date.DaysInMonth();
 }
//+------------------------------------------------------------------+
// | Determining the difference from the first item in the calendar table |
// | to the point of the first day of the current month |
//+------------------------------------------------------------------+
int CCalendar::OffsetFirstDayOfMonth(void) 
 {
    // --- Get the date of the first day of the selected year and month as a string
    string date = string(m_date.year) + "." + string(m_date.mon) + "." + string(1);
    // --- Let's set this date in the structure for calculations
    m_temp_date.DateTime(::StringToTime(date));
    // --- If the result of subtracting one from the current number of the day of the week is greater than or equal to zero,
    // return the result, otherwise return the value 6
    int diff = (m_temp_date.day_of_week - 1 >= 0) ? m_temp_date.day_of_week - 1 : 6;
    // --- Remember the date that falls on the first item in the table
    m_temp_date.DayDec(diff);
    return (diff);
 }
//+------------------------------------------------------------------+
// | Setting calendar values ​​|
//+------------------------------------------------------------------+
void CCalendar::SetCalendar(void) 
 {
    // --- Determining the difference from the first item of the calendar table to the item of the first day of the current month
    int diff = OffsetFirstDayOfMonth();
    // --- Let's go through all the items in the calendar table in a loop
    int items_total = m_days.ButtonsTotal();
    for (int i = 0; i < items_total; i++) {
        // --- Setting the day to the current table item
        m_days.GetButtonPointer(i).LabelText(string(m_temp_date.day));
        // ---Go to next date
        m_temp_date.DayInc();
    }
 }
//+------------------------------------------------------------------+
// | Fast forward calendar |
//+------------------------------------------------------------------+
void CCalendar::FastSwitching(void) 
 {
    // --- Exit if there is no focus on the element
    if (!CElementBase::MouseFocus())
        return;
    // --- Return the counter to its original value if the mouse button is released
    if (!m_mouse.LeftButtonState())
        m_timer_counter = SPIN_DELAY_MSC;
    // --- If the mouse button is pressed
    else {
        // --- Increase the counter by the set interval
        m_timer_counter += TIMER_STEP_MSC;
        // --- Exit if less than zero
        if (m_timer_counter < 0)
            return;
        // ---If the left arrow is pressed
        if (m_month_dec.MouseFocus()) {
            // --- If the current year in the calendar is greater than/equal to the minimum specified
            if (m_date.year >= m_years.MinValue()) {
                // --- If the current year in the calendar is already equal to the minimum specified and
                // current month "January"
                if (m_date.year == m_years.MinValue() && m_date.mon == 1)
                    return;
                // --- Go to next month (downwards)
                m_date.MonDec();
                // --- Set the first day of the month
                m_date.day = 1;
            }
        }
        // ---If the right arrow is pressed
        else if (m_month_inc.MouseFocus()) {
            // --- If the current year in the calendar is less/equal to the maximum specified
            if (m_date.year <= m_years.MaxValue()) {
                // --- If the current year in the calendar is already equal to the maximum specified and
                // current month "December"
                if (m_date.year == m_years.MaxValue() && m_date.mon == 12)
                    return;
                // --- Go to next month (up)
                m_date.MonInc();
                // --- Set the first day of the month
                m_date.day = 1;
            }
        }
        // --- If the increment button of the years input field is pressed
        else if (m_years.GetIncButtonPointer().MouseFocus()) {
            // ---If less than the maximum year specified,
            // move to next year (increasing)
            if (m_date.year < m_years.MaxValue())
                m_date.YearInc();
            else
                return;
        }
        // --- If the decrement button for the years input field is pressed
        else if (m_years.GetDecButtonPointer().MouseFocus()) {
            // ---If greater than the minimum year specified,
            // move to next year (downwards)
            if (m_date.year > m_years.MinValue())
                m_date.YearDec();
            else
                return;
        } else
            return;
        // --- Display the latest changes in the calendar
        UpdateCalendar();
        // --- Updates calendar items
        UpdateElements();
        // --- We will send a message about this
        ::EventChartCustom(m_chart_id, ON_CHANGE_DATE, CElementBase::Id(), m_date.DateTime(), "");
    }
 }
//+------------------------------------------------------------------+
// | Highlighting the current day and the user-selected day |
//+------------------------------------------------------------------+
void CCalendar::HighlightDate(void) 
 {
    // --- Determining the difference from the first item of the calendar table to the item of the first day of the current month
    OffsetFirstDayOfMonth();
    // --- Let's go through the calendar table items in a cycle
    int items_total = m_days.ButtonsTotal();
    for (int i = 0; i < items_total; i++) {
        // --- If the month of the item is the same as the current month and
        // the day of the item coincides with the selected day
        if (m_temp_date.mon == m_date.mon &&
            m_temp_date.day == m_date.day) {
            // --- Select this button
            m_days.SelectButton(i);
            // --- Go to next table item
            m_temp_date.DayInc();
            continue;
        }
        // ---If it is the current date (today)
        if (m_temp_date.year == m_today.year &&
            m_temp_date.mon == m_today.mon &&
            m_temp_date.day == m_today.day) {
            m_days.GetButtonPointer(i).LabelColor(m_today_color);
            m_days.GetButtonPointer(i).BorderColor(m_today_color);
            // --- Go to next table item
            m_temp_date.DayInc();
            continue;
        }
        //---
        m_days.GetButtonPointer(i).BorderColor(m_back_color);
        m_days.GetButtonPointer(i).LabelColor((m_temp_date.mon == m_date.mon) ? m_label_color : m_label_color_locked);
        // --- Go to next table item
        m_temp_date.DayInc();
    }
 }
//+------------------------------------------------------------------+
// | Resetting the time to the beginning of the day |
//+------------------------------------------------------------------+
void CCalendar::ResetTime(void) 
 {
    m_date.hour = 0;
    m_date.min = 0;
    m_date.sec = 0;
 }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CCalendar::Draw(void) 
 {
    // --- Draw background
    CElement::DrawBackground();
    // --- Draw a frame
    CElement::DrawBorder();
    // --- Draws the names of the days of the week
    DrawDaysWeek();
    // --- Draws a dividing line
    DrawSeparateLine();
 }
//+------------------------------------------------------------------+
// | Draws the names of the days of the week |
//+------------------------------------------------------------------+
void CCalendar::DrawDaysWeek(void) 
 {
    // ---Coordinates
    int x = 17, y = 26;
    // --- Dimensions
    int x_size = 21;
    int y_size = 16;
    // --- Counter of days of the week (for an array of objects)
    int w = 0;
    // --- Set up objects that display abbreviated names of the days of the week
    for (int i = 1; i < 7; i++, w++) {
        // --- X coordinate calculation
        x = (w > 0) ? x + x_size : x;
        // --- Font properties
        m_canvas.FontSet(CElement::Font(), -CElement::FontSize() * 10, FW_NORMAL);
        // --- Output text
        m_canvas.TextOut(x, y, m_date.ShortDayName(i), ::ColorToARGB(clrBlack), TA_CENTER);
        // --- If there was a reset, exit
        if (i == 0)
            break;
        // --- Reset if all days of the week have passed
        if (i >= 6)
            i = -1;
    }
 }
//+------------------------------------------------------------------+
// | Draws a dividing line |
//+------------------------------------------------------------------+
void CCalendar::DrawSeparateLine(void) 
 {
    // --- Coordinates
    int x1 = 7, x2 = 154, y = 42;
    // --- Draw a line
    m_canvas.Line(x1, y, x2, y, ::ColorToARGB(m_border_color));
 }
//+------------------------------------------------------------------+
#endif // CCALENDAR_MQH_IMPLEMENTATION
#endif // __CALENDAR_MQH__
