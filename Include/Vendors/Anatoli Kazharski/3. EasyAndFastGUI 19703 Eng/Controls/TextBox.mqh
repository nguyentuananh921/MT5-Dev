//+------------------------------------------------------------------+
//|                                                      TextBox.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Scrolls.mqh"
#include "..\Keys.mqh"
#include "..\Element.mqh"
#include "..\TimeCounter.mqh"
#include <Charts\Chart.mqh>
//+------------------------------------------------------------------+
// | Class for creating a multiline text field |
//+------------------------------------------------------------------+
class CTextBox : public CElement
  {
private:
   // --- An instance of the class for working with the keyboard
   CKeys             m_keys;
   // --- Object for working with a timer counter
   CTimeCounter      m_counter;
   // --- Objects for creating an element
   CRectCanvas       m_textbox;
   CScrollV          m_scrollv;
   CScrollH          m_scrollh;
   // --- Symbols and their properties
   struct StringOptions
     {
      string            m_symbol[];     // Symbols
      int               m_width[];      // Character width
      bool              m_end_of_line;  // Line terminator
     };
   StringOptions     m_lines[];
   // --- Overall size and visible size of the element
   int               m_area_x_size;
   int               m_area_y_size;
   int               m_area_visible_x_size;
   int               m_area_visible_y_size;
   // --- Background and character color of selected text
   color             m_selected_back_color;
   color             m_selected_text_color;
   // --- Starting and ending indexes of lines and characters (selected text)
   int               m_selected_line_from;
   int               m_selected_line_to;
   int               m_selected_symbol_from;
   int               m_selected_symbol_to;
   // ---Default text color
   color             m_default_text_color;
   // ---Default text
   string            m_default_text;
   // --- Variable for working with a string
   string            m_temp_input_string;
   // --- Indents for text from the edges of the input field
   int               m_text_x_offset;
   int               m_text_y_offset;
   // --- Current coordinates of the text cursor
   int               m_text_cursor_x;
   int               m_text_cursor_y;
   // --- Current position of the text cursor
   uint              m_text_cursor_x_pos;
   uint              m_text_cursor_y_pos;
   // --- To calculate the boundaries of the visible part of the input field
   int               m_x_limit;
   int               m_y_limit;
   int               m_x2_limit;
   int               m_y2_limit;
   // --- Step size for horizontal offset
   int               m_shift_x_step;
   // --- Offset restrictions
   int               m_shift_x2_limit;
   int               m_shift_y2_limit;
   // --- Multiline mode
   bool              m_multi_line_mode;
   // --- "Word Wrap" mode
   bool              m_word_wrap_mode;
   // --- Read-only mode
   bool              m_read_only_mode;
   // --- Auto text selection mode
   bool              m_auto_selection_mode;
   // --- Input field status
   bool              m_text_edit_state;
   // --- Timer counter for list rewind
   int               m_timer_counter;
   //---
public:
                     CTextBox(void);
                    ~CTextBox(void);
   // --- Methods for creating an element
   bool              CreateTextBox(const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreateTextBox(void);
   bool              CreateScrollV(void);
   bool              CreateScrollH(void);
   //---
public:
   // --- Returns pointers to scroll bars
   CScrollV         *GetScrollVPointer(void)                   { return(::GetPointer(m_scrollv)); }
   CScrollH         *GetScrollHPointer(void)                   { return(::GetPointer(m_scrollh)); }
   // --- Background and character color of selected text
   void              SelectedBackColor(const color clr)        { m_selected_back_color=clr;       }
   void              SelectedTextColor(const color clr)        { m_selected_text_color=clr;       }
   // --- (1) Default text and (2) default text color
   void              DefaultText(const string text)            { m_default_text=text;             }
   void              DefaultTextColor(const color clr)         { m_default_text_color=clr;        }
   // --- (1) Multiline mode, (2) Word Wrap mode
   void              MultiLineMode(const bool mode)            { m_multi_line_mode=mode;          }
   bool              MultiLineMode(void)                const  { return(m_multi_line_mode);       }
   void              WordWrapMode(const bool mode)             { m_word_wrap_mode=mode;           }
   // --- (1) Read-only mode, (2) input field state, (3) mode for automatic text selection
   bool              ReadOnlyMode(void)                  const { return(m_read_only_mode);        }
   void              ReadOnlyMode(const bool mode)             { m_read_only_mode=mode;           }
   bool              TextEditState(void)                 const { return(m_text_edit_state);       }
   void              AutoSelectionMode(const bool state)       { m_auto_selection_mode=state;     }
   // --- (1) Indents for text from the edges of the input field, (2) text alignment mode
   void              TextXOffset(const int x_offset)           { m_text_x_offset=x_offset;        }
   void              TextYOffset(const int y_offset)           { m_text_y_offset=y_offset;        }
   // --- Returns the index of the (1) line, (2) character on which the text cursor is located,
   // (3) number of lines, (4) number of visible lines
   uint              TextCursorLine(void)                      { return(m_text_cursor_y_pos);     }
   uint              TextCursorColumn(void)                    { return(m_text_cursor_x_pos);     }
   uint              LinesTotal(void)                          { return(::ArraySize(m_lines));    }
   uint              VisibleLinesTotal(void);
   // --- Number of characters in the specified string
   uint              ColumnsTotal(const uint line_index);
   // --- Text cursor information (line/number of lines, column/number of columns)
   string            TextCursorInfo(void);
   // --- Adds a line
   void              AddLine(const string added_text="");
   // --- Adds text to the specified line
   void              AddText(const uint line_index,const string added_text);
   // --- Returns text from the specified string
   string            GetValue(const uint line_index=0);
   // --- Clears the text input field
   void              ClearTextBox(void);
   // --- Table scrolling: (1) vertical and (2) horizontal
   void              VerticalScrolling(const int pos=WRONG_VALUE);
   void              HorizontalScrolling(const int pos=WRONG_VALUE);
   // --- Data offset relative to scrollbar positions
   void              ShiftData(void);
   // --- Adjusting the size of the input field
   void              CorrectSize(void);
   // --- Activate the input field
   void              ActivateTextBox(void);
   // --- Disables the input field
   void              DeactivateTextBox(void);
   // --- Resizing
   void              ChangeSize(const uint x_size,const uint y_size);
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // --- Timer
   virtual void      OnEventTimer(void);
   // ---Move element
   virtual void      Moving(const bool only_visible=true);
   // --- Management
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Delete(void);
   // --- (1) Installation, (2) reset priorities by pressing the left mouse button
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   // --- Draws an element
   virtual void      Draw(void);
   // --- Item update
   virtual void      Update(const bool redraw=false);
   //---
private:
   // --- Handling clicks on an element
   bool              OnClickTextBox(const string clicked_object);

   // --- Keystroke processing
   bool              OnPressedKey(const long key_code);
   // --- Handling the "Backspace" key press
   bool              OnPressedKeyBackspace(const long key_code);
   // --- Handling pressing the "Enter" key
   bool              OnPressedKeyEnter(const long key_code);
   // --- Processing the "Left" key press
   bool              OnPressedKeyLeft(const long key_code);
   // --- Handling the "Right" key press
   bool              OnPressedKeyRight(const long key_code);
   // --- Handling the "Up" key press
   bool              OnPressedKeyUp(const long key_code);
   // --- Handling the "Down" key press
   bool              OnPressedKeyDown(const long key_code);
   // --- Handling the "Home" key press
   bool              OnPressedKeyHome(const long key_code);
   // --- Handling the "End" key
   bool              OnPressedKeyEnd(const long key_code);

   // --- Handling the Ctrl + Left key press
   bool              OnPressedKeyCtrlAndLeft(const long key_code);
   // --- Handling the Ctrl + Right key press
   bool              OnPressedKeyCtrlAndRight(const long key_code);
   // --- Handling simultaneous pressing of Ctrl + Home keys
   bool              OnPressedKeyCtrlAndHome(const long key_code);
   // --- Handling simultaneous Ctrl + End key presses
   bool              OnPressedKeyCtrlAndEnd(const long key_code);

   // --- Handling Shift + Left key presses
   bool              OnPressedKeyShiftAndLeft(const long key_code);
   // --- Handling Shift + Right key presses
   bool              OnPressedKeyShiftAndRight(const long key_code);
   // --- Handling Shift + Up key presses
   bool              OnPressedKeyShiftAndUp(const long key_code);
   // --- Handling Shift + Down key presses
   bool              OnPressedKeyShiftAndDown(const long key_code);
   // --- Handling Shift + Home key presses
   bool              OnPressedKeyShiftAndHome(const long key_code);
   // --- Handling Shift + End key presses
   bool              OnPressedKeyShiftAndEnd(const long key_code);

   // --- Handling key presses Ctrl + Shift + Left
   bool              OnPressedKeyCtrlShiftAndLeft(const long key_code);
   // --- Handling key presses Ctrl + Shift + Right
   bool              OnPressedKeyCtrlShiftAndRight(const long key_code);
   // --- Handling key presses Ctrl + Shift + Home
   bool              OnPressedKeyCtrlShiftAndHome(const long key_code);
   // --- Handling key presses Ctrl + Shift + End
   bool              OnPressedKeyCtrlShiftAndEnd(const long key_code);
   //---
private:
   // --- Sets (1) starting and (2) ending indexes for text selection
   void              SetStartSelectedTextIndexes(void);
   void              SetEndSelectedTextIndexes(void);
   // --- Select all text
   void              SelectAllText(void);
   // --- Reset selected text
   void              ResetSelectedText(void);
   // --- Fast forward input field
   void              FastSwitching(void);

   // --- Outputting text to canvas
   void              TextOut(void);
   // --- Draws a frame
   virtual void      DrawBorder(void);
   // --- Draws a text cursor
   void              DrawCursor(void);
   // ---Displays text and blinking cursor
   void              DrawTextAndCursor(const bool show_state=false);

   // --- Returns the current background color
   uint              AreaColorCurrent(void);
   // --- Returns the current text color
   uint              TextColorCurrent(void);
   // --- Returns the current border color
   uint              BorderColorCurrent(void);
   // --- Changing the color of objects
   void              ChangeObjectsColor(void);

   // --- Collects a string of characters
   string            CollectString(const uint line_index,const uint symbols_total=0);
   // --- Adds a symbol and its properties to structure arrays
   void              AddSymbol(const string key_symbol);
   // --- Deletes a character
   void              DeleteSymbol(void);
   // --- Deletes (1) selected text, (2) on one line, (3) on multiple lines
   bool              DeleteSelectedText(void);
   void              DeleteTextOnOneLine(void);
   void              DeleteTextOnMultipleLines(void);

   // --- Returns the row height
   uint              LineHeight(void);
   // --- Returns the line width of the specified character in pixels
   uint              LineWidth(const uint symbol_index,const uint line_index);
   // --- Returns the maximum line width
   uint              MaxLineWidth(void);

   // --- Shifts rows up one position
   void              ShiftOnePositionUp(void);
   // --- Shifts rows down one position
   void              ShiftOnePositionDown(void);

   // --- Checking for selected text
   bool              CheckSelectedText(const uint line_index,const uint symbol_index);
   // --- Check for mandatory first line
   uint              CheckFirstLine(void);

   // --- Sets a new size to the property arrays of the specified string
   void              ArraysResize(const uint line_index,const uint new_size);
   // --- Makes a copy of the specified (source) string to a new location (destination)
   void              LineCopy(const uint destination,const uint source);
   // --- Clears the specified string
   void              ClearLine(const uint line_index);

   // --- Move the text cursor in the specified direction
   void              MoveTextCursor(const ENUM_MOVE_TEXT_CURSOR direction);
   void              MoveTextCursor(const ENUM_MOVE_TEXT_CURSOR direction,const bool with_highlighted_text);
   // --- Move the text cursor to the left
   void              MoveTextCursorToLeft(const bool to_next_word=false);
   // --- Move the text cursor to the right
   void              MoveTextCursorToRight(const bool to_next_word=false);
   // --- Move the text cursor up one line
   void              MoveTextCursorToUp(void);
   // --- Move the text cursor down one line
   void              MoveTextCursorToDown(void);

   // --- Places the cursor at the specified positions
   void              SetTextCursor(const uint x_pos,const uint y_pos);
   // --- Places the cursor at the specified positions by the mouse cursor
   void              SetTextCursorByMouseCursor(void);
   // ---Adjusting the text cursor along the X axis
   void              CorrectingTextCursorXPos(const int x_pos=WRONG_VALUE);

   // --- Calculation of coordinates for a text cursor
   void              CalculateTextCursorX(void);
   void              CalculateTextCursorY(void);

   // --- Calculation of input field boundaries
   void              CalculateBoundaries(void);
   void              CalculateXBoundaries(void);
   void              CalculateYBoundaries(void);
   // --- Calculate the X-position of the scroll bar in the left border of the input field
   int               CalculateScrollThumbX(void);
   // --- Calculate the X-position of the scroll bar at the right edge of the input field
   int               CalculateScrollThumbX2(void);
   // --- Calculate the X-position of the scrollbar slider
   int               CalculateScrollPosX(const bool to_right=false);
   // --- Calculate the Y-position of the scroll bar at the top border of the input field
   int               CalculateScrollThumbY(void);
   // --- Calculate the Y-position of the scroll bar at the bottom border of the input field
   int               CalculateScrollThumbY2(void);
   // --- Calculate the Y-position of the scroll bar slider
   int               CalculateScrollPosY(const bool to_down=false);
   // ---Adjusting the horizontal scroll bar
   void              CorrectingHorizontalScrollThumb(void);
   // ---Adjusting the vertical scroll bar
   void              CorrectingVerticalScrollThumb(void);

   // --- Calculates the dimensions of a text input field
   void              CalculateTextBoxSize(void);
   bool              CalculateTextBoxXSize(void);
   bool              CalculateTextBoxYSize(void);
   // --- Change the basic dimensions of an element
   void              ChangeMainSize(const int x_size,const int y_size);
   // --- Resize the input field
   void              ChangeTextBoxSize(const bool x_offset=false,const bool y_offset=false);
   // --- Resize scrollbars
   void              ChangeScrollsSize(void);

   // --- Word wrapping
   void              WordWrap(void);
   // --- Returns the indexes of the first visible character and space
   bool              CheckForOverflow(const uint line_index,int &symbol_index,int &space_index);
   // --- Number of words in the specified line
   uint              WordsTotal(const uint line_index);
   // --- Returns the number of characters to be carried
   bool              WrapSymbolsTotal(const uint line_index,uint &wrap_symbols_total);
   // --- Returns the index of the space character by its number
   uint              SymbolIndexBySpaceNumber(const uint line_index,const uint space_index);
   // --- Moves lines
   void              MoveLines(const uint from_index,const uint to_index,const uint count,const bool to_down=true);
   // --- Move characters in the specified string
   void              MoveSymbols(const uint line_index,const uint from_pos,const uint to_pos,const bool to_left=true);
   // --- Add text to the specified line
   void              AddToString(const uint line_index,const string text);
   // --- Copies characters for wrapping to another line into the passed array
   void              CopyWrapSymbols(const uint line_index,const uint start_pos,const uint symbols_total,string &array[]);
   // --- Inserts characters from the passed array into the specified string
   void              PasteWrapSymbols(const uint line_index,const uint start_pos,string &array[]);
   // --- Wrap text to next line
   void              WrapTextToNewLine(const uint curr_line_index,const uint symbol_index,const bool by_pressed_enter=false);
   // --- Wrap text from the specified line to the previous one
   void              WrapTextToPrevLine(const uint next_line_index,const uint wrap_symbols_total,const bool is_all_text=false);

   // --- Change the width along the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
   // --- Change the height along the bottom edge of the window
   virtual void      ChangeHeightByBottomWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTextBox::CTextBox(void) : m_selected_text_color(clrWhite),
                           m_selected_back_color(C'51,153,255'),
                           m_selected_line_from(WRONG_VALUE),
                           m_selected_line_to(WRONG_VALUE),
                           m_selected_symbol_from(WRONG_VALUE),
                           m_selected_symbol_to(WRONG_VALUE),
                           m_default_text_color(clrTomato),
                           m_default_text(""),
                           m_temp_input_string(""),
                           m_text_x_offset(5),
                           m_text_y_offset(4),
                           m_multi_line_mode(false),
                           m_word_wrap_mode(false),
                           m_read_only_mode(false),
                           m_auto_selection_mode(false),
                           m_text_edit_state(false),
                           m_text_cursor_x_pos(0),
                           m_text_cursor_y_pos(0),
                           m_shift_x_step(10),
                           m_shift_x2_limit(0),
                           m_shift_y2_limit(0)
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
// --- Initial coordinates of the text cursor
   m_text_cursor_x=m_text_x_offset;
   m_text_cursor_y=m_text_y_offset;
// --- Setting parameters for the timer counter
   m_counter.SetParameters(16,200);
// --- Required first line of a multi-line input field
   ::ArrayResize(m_lines,1);
// --- Set the line end flag
   m_lines[0].m_end_of_line=true;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTextBox::~CTextBox(void)
  {
  }
//+------------------------------------------------------------------+
// | Graphics Event Handler |
//+------------------------------------------------------------------+
void CTextBox::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      // --- Checking the status of scroll bars
      bool is_scroll_state=m_scrollv.ScrollBarControl() || ((m_multi_line_mode)? m_scrollh.ScrollBarControl() : false);
      //---
      if(m_text_edit_state)
        {
         // --- If (1) not in focus and (2) left mouse button pressed and (3) not in scrollbar moving mode
         if(!CElementBase::MouseFocus() && m_mouse.LeftButtonState() && !is_scroll_state)
           {
            // --- Send a message about the end of entering a line into the input field if the field was active
            string str=(m_multi_line_mode)? TextCursorInfo() : "";
            ::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),CElementBase::Index(),str);
            // --- Disable the input field
            DeactivateTextBox();
            // --- Update
            Update(true);
           }
        }
      // --- Changing the color of objects
      ChangeObjectsColor();
      // --- Exit if multiline mode is disabled
      if(!m_multi_line_mode)
         return;
      // --- If the scrollbar is in effect
      if(is_scroll_state)
        {
         // --- Move data relative to scroll bars
         ShiftData();
         // --- Disable the input field
         DeactivateTextBox();
         // --- Update
         Update(true);
         // --- Refresh scrollbar in action
         if(m_scrollh.State()) m_scrollh.Update(true);
         if(m_scrollv.State()) m_scrollv.Update(true);
        }
      // --- If one of the scroll bar buttons is pressed
      if(m_mouse.LeftButtonState() && 
         (m_scrollv.ScrollIncState() || m_scrollv.ScrollDecState() || 
         m_scrollh.ScrollIncState() || m_scrollh.ScrollDecState()))
        {
         // --- Disable the input field
         DeactivateTextBox();
         // --- Update
         Update(true);
        }
      //---
      return;
     }
// --- Handling the event of pressing the left mouse button on an object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      // --- Click on the input field
      if(OnClickTextBox(sparam))
         return;
      //---
      return;
     }
// --- Handling click events on scrollbar buttons
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      // --- If there was a click on the list scroll bar buttons
      if(m_scrollv.OnClickScrollInc((uint)lparam,(uint)dparam) ||
         m_scrollv.OnClickScrollDec((uint)lparam,(uint)dparam))
        {
         // --- Shifts data
         ShiftData();
         m_scrollv.Update(true);
         return;
        }
      // --- If there was a click on the list scroll bar buttons
      if(m_scrollh.OnClickScrollInc((uint)lparam,(uint)dparam) ||
         m_scrollh.OnClickScrollDec((uint)lparam,(uint)dparam))
        {
         // --- Shifts data
         ShiftData();
         m_scrollh.Update(true);
         return;
        }
     }
// --- Handling a button press on the keyboard
   if(id==CHARTEVENT_KEYDOWN)
     {
      // --- Quit if the input field is not activated
      if(!m_text_edit_state)
         return;
      // --- Pressing the symbol key
      if(OnPressedKey(lparam))
         return;
      // --- Pressing the "Backspace" key
      if(OnPressedKeyBackspace(lparam))
         return;
      // --- Pressing the "Enter" key
      if(OnPressedKeyEnter(lparam))
         return;
      // --- Pressing the "Left" key
      if(OnPressedKeyLeft(lparam))
         return;
      // --- Pressing the "Right" key
      if(OnPressedKeyRight(lparam))
         return;
      // --- Pressing the "Up" key
      if(OnPressedKeyUp(lparam))
         return;
      // --- Pressing the "Down" key
      if(OnPressedKeyDown(lparam))
         return;
      // --- Pressing the "Home" key
      if(OnPressedKeyHome(lparam))
         return;
      // --- Pressing the "End" key
      if(OnPressedKeyEnd(lparam))
         return;
      // --- Simultaneously pressing the Ctrl + Left keys
      if(OnPressedKeyCtrlAndLeft(lparam))
         return;
      // --- Simultaneous pressing of Ctrl + Right keys
      if(OnPressedKeyCtrlAndRight(lparam))
         return;
      // --- Simultaneously pressing the Ctrl + Home keys
      if(OnPressedKeyCtrlAndHome(lparam))
         return;
      // --- Simultaneously pressing the Ctrl + End keys
      if(OnPressedKeyCtrlAndEnd(lparam))
         return;
      // --- Press Shift + Left keys simultaneously
      if(OnPressedKeyShiftAndLeft(lparam))
         return;
      // --- Press Shift + Right keys simultaneously
      if(OnPressedKeyShiftAndRight(lparam))
         return;
      // --- Simultaneously pressing the Shift + Up keys
      if(OnPressedKeyShiftAndUp(lparam))
         return;
      // --- Press Shift + Down keys simultaneously
      if(OnPressedKeyShiftAndDown(lparam))
         return;
      // --- Press Shift + Home keys simultaneously
      if(OnPressedKeyShiftAndHome(lparam))
         return;
      // --- Press Shift + End keys simultaneously
      if(OnPressedKeyShiftAndEnd(lparam))
         return;
      // --- Simultaneous pressing of Ctrl + Shift + Left keys
      if(OnPressedKeyCtrlShiftAndLeft(lparam))
         return;
      // --- Simultaneous pressing of Ctrl + Shift + Right keys
      if(OnPressedKeyCtrlShiftAndRight(lparam))
         return;
      // --- Simultaneously pressing the Ctrl + Shift + Home keys
      if(OnPressedKeyCtrlShiftAndHome(lparam))
         return;
      // --- Simultaneously pressing the Ctrl + Shift + End keys
      if(OnPressedKeyCtrlShiftAndEnd(lparam))
         return;
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
// | Timer |
//+------------------------------------------------------------------+
void CTextBox::OnEventTimer(void)
  {
// --- Fast forward values
   FastSwitching();
// --- Pause between text cursor updates
   if(m_counter.CheckTimeCounter())
     {
      // --- Update the text cursor if the element is visible and the input field is activated
      if(CElementBase::IsVisible() && m_text_edit_state)
         DrawTextAndCursor();
     }
  }
//+------------------------------------------------------------------+
// | Creates an element "Text input field" |
//+------------------------------------------------------------------+
bool CTextBox::CreateTextBox(const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
// --- Initializing properties
   InitializeProperties(x_gap,y_gap);
// --- Calculate the size of the text input field
   CalculateTextBoxSize();
// ---Creating an element
   if(!CreateCanvas())
      return(false);
   if(!CreateTextBox())
      return(false);
   if(!CreateScrollV())
      return(false);
   if(!CreateScrollH())
      return(false);
// --- Resize text input field
   ChangeTextBoxSize();
// --- In word wrap mode, you need to recalculate and set the dimensions
   if(m_word_wrap_mode)
     {
      CalculateTextBoxSize();
      ChangeTextBoxSize();
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CTextBox::InitializeProperties(const int x_gap,const int y_gap)
  {
   m_x        =CElement::CalculateX(x_gap);
   m_y        =CElement::CalculateY(y_gap);
   m_x_size   =(m_x_size<0 || m_auto_xresize_mode)? m_main.X2()-CElementBase::X()-m_auto_xresize_right_offset : m_x_size;
   m_y_size   =(m_y_size<0 || m_auto_yresize_mode)? m_main.Y2()-CElementBase::Y()-m_auto_yresize_bottom_offset : m_y_size;
// ---Default colors
   m_back_color           =(m_back_color!=clrNONE)? m_back_color : clrWhite;
   m_back_color_locked    =(m_back_color_locked!=clrNONE)? m_back_color_locked : clrWhiteSmoke;
   m_border_color         =(m_border_color!=clrNONE)? m_border_color : clrGray;
   m_border_color_hover   =(m_border_color_hover!=clrNONE)? m_border_color_hover : clrBlack;
   m_border_color_locked  =(m_border_color_locked!=clrNONE)? m_border_color_locked : clrSilver;
   m_border_color_pressed =(m_border_color_pressed!=clrNONE)? m_border_color_pressed : clrCornflowerBlue;
   m_label_color          =(m_label_color!=clrNONE)? m_label_color : clrBlack;
   m_label_color_locked   =(m_label_color_locked!=clrNONE)? m_label_color_locked : clrSilver;
// --- Indents from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
// | Creates a canvas for background painting |
//+------------------------------------------------------------------+
bool CTextBox::CreateCanvas(void)
  {
// --- Formation of object name
   string name=CElementBase::ElementName("textbox");
// ---Create an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
// --- Check for mandatory first line
   CheckFirstLine();
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a canvas for drawing an input field |
//+------------------------------------------------------------------+
bool CTextBox::CreateTextBox(void)
  {
// --- Formation of object name
   string name="";
   if(m_index==WRONG_VALUE)
      name=m_program_name+"_"+"textbox_edit"+"_"+(string)m_id;
   else
      name=m_program_name+"_"+"textbox_edit"+"_"+(string)m_index+"__"+(string)m_id;
// --- Coordinates
   int x =m_x+1;
   int y =m_y+1;
// --- Size
   int x_size =m_area_x_size-2;
   int y_size =m_area_y_size-2;
// ---Create an object
   ::ResetLastError();
   if(!m_textbox.CreateBitmapLabel(m_chart_id,m_subwin,name,x,y,x_size,y_size,COLOR_FORMAT_ARGB_NORMALIZE))
     {
      ::Print(__FUNCTION__," > Не удалось создать холст для рисования поля ввода: ",::GetLastError());
      return(false);
     }
// --- Get a pointer to the base class
   if(!m_textbox.Attach(m_chart_id,name,COLOR_FORMAT_ARGB_NORMALIZE))
     {
      ::Print(__FUNCTION__," > Не удалось присоединить холст для рисования к графику: ",::GetLastError());
      return(false);
     }
// --- Properties
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_ZORDER,m_zorder+1);
   ::ObjectSetString(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_TOOLTIP,"\n");
// --- Coordinates
   m_textbox.X(x);
   m_textbox.Y(y);
// --- Indents from the extreme point of the panel
   m_textbox.XGap(CElement::CalculateXGap(x));
   m_textbox.YGap(CElement::CalculateYGap(y));
// --- Set the size of the visible area
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_XSIZE,m_area_visible_x_size);
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_YSIZE,m_area_visible_y_size);
// --- Set the offset of the frame inside the image along the X and Y axes
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_XOFFSET,0);
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_YOFFSET,0);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a vertical scroll |
//+------------------------------------------------------------------+
bool CTextBox::CreateScrollV(void)
  {
// --- Save parent element pointer
   m_scrollv.MainPointer(this);
// --- If multiline mode is disabled
   if(!m_multi_line_mode)
     {
      // --- Initializing the vertical scroll bar
      m_scrollv.Reinit(m_area_y_size,m_area_visible_y_size);
      // --- Save parent element pointer
      m_scrollv.GetIncButtonPointer().MainPointer(m_scrollv);
      m_scrollv.GetDecButtonPointer().MainPointer(m_scrollv);
      return(true);
     }
// --- Coordinates
   int x =m_scrollv.ScrollWidth()+1;
   int y =1;
// --- Set properties
   m_scrollv.Index(0);
   m_scrollv.IsDropdown(CElementBase::IsDropdown());
   m_scrollv.XSize(m_scrollv.ScrollWidth());
   m_scrollv.YSize(m_y_size-m_scrollv.ScrollWidth()-1);
   m_scrollv.AnchorRightWindowSide(true);
// --- Calculation of the number of steps for displacement
   uint lines_total         =LinesTotal()+1;
   uint visible_lines_total =VisibleLinesTotal();
// --- Creating a scrollbar
   if(!m_scrollv.CreateScroll(x,y,lines_total,visible_lines_total))
      return(false);
// --- Add element to array
   CElement::AddToArray(m_scrollv);
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a horizontal scroll |
//+------------------------------------------------------------------+
bool CTextBox::CreateScrollH(void)
  {
// --- Save parent element pointer
   m_scrollh.MainPointer(this);
// --- If multiline mode is disabled
   if(!m_multi_line_mode)
     {
      // ---Initializing the horizontal scrollbar
      m_scrollh.Reinit(m_area_x_size,m_area_visible_x_size);
      // --- Save main element pointer
      m_scrollh.GetIncButtonPointer().MainPointer(m_scrollh);
      m_scrollh.GetDecButtonPointer().MainPointer(m_scrollh);
      return(true);
     }
// --- Coordinates
   int x =1;
   int y =m_scrollh.ScrollWidth()+1;
// --- Set properties
   m_scrollh.Index(1);
   m_scrollh.IsDropdown(CElementBase::IsDropdown());
   m_scrollh.XSize(CElementBase::XSize()-m_scrollv.ScrollWidth()-1);
   m_scrollh.YSize(m_scrollv.ScrollWidth());
   m_scrollh.AnchorBottomWindowSide(true);
// --- Calculation of the number of steps for displacement
   uint x_size_total         =m_area_x_size/m_shift_x_step;
   uint visible_x_size_total =m_area_visible_x_size/m_shift_x_step;
// --- Creating a scrollbar
   if(!m_scrollh.CreateScroll(x,y,x_size_total,visible_x_size_total))
      return(false);
// --- Add element to array
   CElement::AddToArray(m_scrollh);
   return(true);
  }
//+------------------------------------------------------------------+
// | Returns the number of visible rows |
//+------------------------------------------------------------------+
uint CTextBox::VisibleLinesTotal(void)
  {
   return((m_area_visible_y_size-(m_text_y_offset*2))/LineHeight());
  }
//+------------------------------------------------------------------+
// | Returns the number of characters in the specified string |
//+------------------------------------------------------------------+
uint CTextBox::ColumnsTotal(const uint line_index)
  {
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Preventing out of range
   uint check_index=(line_index<lines_total)? line_index : lines_total-1;
// --- Get the size of the array of characters in the string
   uint symbols_total=::ArraySize(m_lines[check_index].m_symbol);
// --- Return the number of characters
   return(symbols_total);
  }
//+------------------------------------------------------------------+
// | Text cursor information |
//+------------------------------------------------------------------+
string CTextBox::TextCursorInfo(void)
  {
// --- Components for a string
   string lines_total        =(string)LinesTotal();
   string columns_total      =(string)ColumnsTotal(TextCursorLine());
   string text_cursor_line   =string(TextCursorLine()+1);
   string text_cursor_column =string(TextCursorColumn()+1);
// --- Let's create a string
   string text_box_info="Ln "+text_cursor_line+"/"+lines_total+", "+"Col "+text_cursor_column+"/"+columns_total;
// --- Return string
   return(text_box_info);
  }
//+------------------------------------------------------------------+
// | Adds the line |
//+------------------------------------------------------------------+
void CTextBox::AddLine(const string added_text="")
  {
// --- Exit if multiline mode is disabled
   if(!m_multi_line_mode)
      return;
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// ---Array reserve size
   int reserve_size=10000;
// --- Set the size of structure arrays
   ::ArrayResize(m_lines,lines_total+1,reserve_size);
// --- Set the line end flag
   m_lines[lines_total].m_end_of_line=true;
// --- Install the font
   m_textbox.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_NORMAL);
// --- Add text to the line
   AddToString(lines_total,added_text);
// --- Exit if the composite element's pointer to the main element is invalid
   if(::CheckPointer(m_scrollh.MainPointer())==POINTER_INVALID)
      return;
// --- Calculate the size of the input field
   CalculateTextBoxSize();
// --- Set a new size for the input field
   ChangeTextBoxSize();
// --- In word wrap mode, you need to recalculate and set the dimensions
   if(m_word_wrap_mode)
     {
      CalculateTextBoxSize();
      ChangeTextBoxSize();
     }
// ---Redraw scrollbars
   //if(m_scrollh.IsScroll())
   //   m_scrollh.Update(true);
   //if(m_scrollv.IsScroll())
   //   m_scrollv.Update(true);
  }
//+------------------------------------------------------------------+
// | Adds text to the specified line |
//+------------------------------------------------------------------+
void CTextBox::AddText(const uint line_index,const string added_text)
  {
// --- Exit if an empty string is passed
   if(added_text=="")
      return;
// --- Get the size of the string array, checking for the presence of the required first line
   uint lines_total=CheckFirstLine();
// --- Preventing out of range
   uint l=(line_index<lines_total)? line_index : lines_total-1;
// --- Index adjustment taking into account the word wrapping mode
   if(m_word_wrap_mode)
     {
      for(uint i=0,j=0; i<lines_total; i++)
        {
         // --- Count lines based on ending
         if(m_lines[i].m_end_of_line)
           {
            //---
            if(l==j || i+1>=lines_total)
              {
               l=i;
               break;
              }
            //---
            j++;
           }
        }
     }
// --- Install the font
   m_textbox.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_NORMAL);
// --- Add text to the line
   AddToString(l,added_text);
  }
//+------------------------------------------------------------------+
// | Returns text from the specified string |
//+------------------------------------------------------------------+
string CTextBox::GetValue(const uint line_index=0)
  {
// --- Get the size of the string array, checking for the presence of the required first line
   uint lines_total=CheckFirstLine();
// --- Preventing out of range
   uint l=(line_index<lines_total)? line_index : lines_total-1;
// --- Return text
   return(CollectString(l));
  }
//+------------------------------------------------------------------+
// | Clears a text input field |
//+------------------------------------------------------------------+
void CTextBox::ClearTextBox(void)
  {
// --- Delete all lines except the first
   ::ArrayResize(m_lines,1);
// --- Clear the first line
   ClearLine(0);
  }
//+------------------------------------------------------------------+
// | Horizontal scrolling of the input field |
//+------------------------------------------------------------------+
void CTextBox::HorizontalScrolling(const int pos=WRONG_VALUE)
  {
// --- To determine the position of the slider
   int index=0;
// ---Last position index
   int last_pos_index=int(m_area_x_size-m_area_visible_x_size);
// --- Adjustment in case of leaving the range
   if(pos<0)
      index=last_pos_index;
   else
      index=(pos>last_pos_index)? last_pos_index : pos;
// --- Move the scroll bar slider
   m_scrollh.MovingThumb(index);
// --- Move the input field
   ShiftData();
// --- Refresh scrollbar
   m_scrollh.Update();
  }
//+------------------------------------------------------------------+
// | Vertical scrolling of an input field |
//+------------------------------------------------------------------+
void CTextBox::VerticalScrolling(const int pos=WRONG_VALUE)
  {
// --- To determine the position of the slider
   int index=0;
// ---Last position index
   int last_pos_index=int((m_area_y_size-m_area_visible_y_size)/(double)LineHeight());
// --- Adjustment in case of leaving the range
   if(pos<0)
      index=last_pos_index;
   else
      index=(pos>last_pos_index)? last_pos_index : pos;
// --- Move the scroll bar slider
   m_scrollv.MovingThumb(index);
// --- Move the input field
   ShiftData();
// --- Refresh scrollbar
   m_scrollv.Update(true);
  }
//+------------------------------------------------------------------+
// | Shifts data relative to scroll bars |
//+------------------------------------------------------------------+
void CTextBox::ShiftData(void)
  {
// --- Get the current positions of the horizontal and vertical scroll bar sliders
   int h_offset =m_scrollh.CurrentPos()*m_shift_x_step;
   int v_offset =m_text_y_offset+(m_scrollv.CurrentPos()*(int)LineHeight())-2;
// --- Calculate the indentation for the offset
   int x_offset =(h_offset<1)? 0 : (h_offset>=m_shift_x2_limit)? m_shift_x2_limit : h_offset;
   int y_offset =(v_offset<1)? 0 : (v_offset>=m_shift_y2_limit)? m_shift_y2_limit : v_offset;
// --- Calculate data position relative to scrollbar sliders
   long x =(m_area_x_size>m_area_visible_x_size && !m_word_wrap_mode)? x_offset : 0;
   long y =(m_area_y_size>m_area_visible_y_size)? y_offset : 0;
// ---Data offset
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_XOFFSET,x);
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_YOFFSET,y);
  }
//+------------------------------------------------------------------+
// | Adjusting the size of the input field |
//+------------------------------------------------------------------+
void CTextBox::CorrectSize(void)
  {
// --- Calculate the size of the input field
   CalculateTextBoxSize();
// --- Set a new size for the input field
   ChangeTextBoxSize(true,true);
  }
//+------------------------------------------------------------------+
// | Activating the input field |
//+------------------------------------------------------------------+
void CTextBox::ActivateTextBox(void)
  {
   OnClickTextBox(m_textbox.ChartObjectName());
  }
//+------------------------------------------------------------------+
// | Resizing |
//+------------------------------------------------------------------+
void CTextBox::ChangeSize(const uint x_size,const uint y_size)
  {
// --- Set new size
   ChangeMainSize(x_size,y_size);
// --- Calculate the size of the input field
   CalculateTextBoxSize();
// --- Set a new size for the input field
   ChangeTextBoxSize();
  }
//+------------------------------------------------------------------+
// | Moving an element |
//+------------------------------------------------------------------+
void CTextBox::Moving(const bool only_visible=true)
  {
// --- Exit if element is hidden
   if(only_visible)
      if(!CElementBase::IsVisible())
         return;
// --- If the anchor is on the right
   if(m_anchor_right_window_side)
     {
      // ---Saving coordinates in element fields
      CElementBase::X(m_main.X2()-XGap());
      // ---Saving coordinates in object fields
      m_textbox.X(m_main.X2()-m_textbox.XGap());
     }
   else
     {
      CElementBase::X(m_main.X()+XGap());
      m_textbox.X(m_main.X()+m_textbox.XGap());
     }
// --- If the binding is below
   if(m_anchor_bottom_window_side)
     {
      CElementBase::Y(m_main.Y2()-YGap());
      m_textbox.Y(m_main.Y2()-m_textbox.YGap());
     }
   else
     {
      CElementBase::Y(m_main.Y()+YGap());
      m_textbox.Y(m_main.Y()+m_textbox.YGap());
     }
// --- Coordinates update
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_XDISTANCE,m_textbox.X());
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_YDISTANCE,m_textbox.Y());
// --- Update object position
   CElement::Moving(only_visible);
  }
//+------------------------------------------------------------------+
// | Shows element |
//+------------------------------------------------------------------+
void CTextBox::Show(void)
  {
// --- Exit if element is already visible
   if(CElementBase::IsVisible())
      return;
// --- Make all objects visible
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
// --- Visibility state
   CElementBase::IsVisible(true);
// --- Update element position
   Moving();
// --- Show scroll bars
   if(m_scrollv.IsScroll())
      m_scrollv.Show();
   if(m_scrollh.IsScroll())
      m_scrollh.Show();
  }
//+------------------------------------------------------------------+
// | Hides the element |
//+------------------------------------------------------------------+
void CTextBox::Hide(void)
  {
// --- Exit if element is hidden
   if(!CElementBase::IsVisible())
      return;
// --- Hide all objects
   ::ObjectSetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   m_scrollv.Hide();
   m_scrollh.Hide();
// --- Visibility state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
// | Removal |
//+------------------------------------------------------------------+
void CTextBox::Delete(void)
  {
// --- Deleting objects
   m_canvas.Destroy();
   m_textbox.Destroy();
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Freeing element arrays
   for(uint i=0; i<lines_total; i++)
     {
      ::ArrayFree(m_lines[i].m_width);
      ::ArrayFree(m_lines[i].m_symbol);
     }
//---
   ::ArrayFree(m_lines);
// --- Initializing variables to default values
   m_text_edit_state=false;
   CElementBase::IsVisible(true);
   CElementBase::MouseFocus(false);
  }
//+------------------------------------------------------------------+
// | Setting Priorities |
//+------------------------------------------------------------------+
void CTextBox::SetZorders(void)
  {
   CElement::SetZorders();
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_ZORDER,m_zorder+1);
  }
//+------------------------------------------------------------------+
// | Reset priorities |
//+------------------------------------------------------------------+
void CTextBox::ResetZorders(void)
  {
   CElement::ResetZorders();
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_ZORDER,WRONG_VALUE);
  }
//+------------------------------------------------------------------+
// | Handling a click on an element |
//+------------------------------------------------------------------+
bool CTextBox::OnClickTextBox(const string clicked_object)
  {
// --- Exit if the object name is foreign
   if(m_textbox.ChartObjectName()!=clicked_object)
     {
      // --- Send a message about the end of entering a line into the input field if the field was active
      if(m_text_edit_state)
        {
         string str=(m_multi_line_mode)? TextCursorInfo() : "";
         ::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),CElementBase::Index(),str);
        }
      // --- Disable input field
      DeactivateTextBox();
      // --- Update
      Update(true);
      return(false);
     }
// --- Quit if (1) read-only mode is enabled or (2) the item is locked
   if(m_read_only_mode || CElementBase::IsLocked())
      return(true);
// --- Exit if the scrollbar is in active mode
   if(m_scrollv.State() || m_scrollh.State())
      return(true);
// --- If (1) auto text selection mode is enabled and (2) the input field has just been activated
   if(m_auto_selection_mode && !m_text_edit_state)
      SelectAllText();
// --- Reset selection
   else
      ResetSelectedText();
// --- Disable schedule management
   m_chart.SetInteger(CHART_KEYBOARD_CONTROL,false);
// --- If (1) auto text selection mode is enabled and (2) the input field is activated
   if(!m_auto_selection_mode || (m_auto_selection_mode && m_text_edit_state))
     {
      // --- Set text cursor to mouse cursor
      SetTextCursorByMouseCursor();
     }
// --- If the multi-line input field mode is enabled, adjust the vertical scroll bar
   if(m_multi_line_mode)
      CorrectingVerticalScrollThumb();
// --- Activate input field
   m_text_edit_state=true;
// --- Refresh text and cursor
   DrawTextAndCursor(true);
// --- Change frame color
   DrawBorder();
   m_canvas.Update();
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_CLICK_TEXT_BOX,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling a keystroke |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKey(const long key_code)
  {
// --- Get the key symbol
   string pressed_key=m_keys.KeySymbol(key_code);
// --- Exit if there is no character
   if(pressed_key=="")
      return(false);
// --- If there is selected text, delete it
   DeleteSelectedText();
// --- Add a symbol and its properties
   AddSymbol(pressed_key);
// --- Calculate the size of the input field
   CalculateTextBoxSize();
// --- Set a new size for the input field
   ChangeTextBoxSize(true,true);
// --- Adjusting the horizontal scroll bar
   CorrectingHorizontalScrollThumb();
// --- If word wrap mode is enabled, adjust the vertical scroll bar
   if(m_word_wrap_mode)
      CorrectingVerticalScrollThumb();
// --- Update text in input field
   DrawTextAndCursor(true);
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling the 'Backspace' key press |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyBackspace(const long key_code)
  {
// --- Quit if it's not the 'Backspace' key
   if(key_code!=KEY_BACKSPACE)
      return(false);
// --- If there is selected text, delete it and exit
   if(DeleteSelectedText())
      return(true);
// --- Remove character if position is greater than zero
   if(m_text_cursor_x_pos>0)
      DeleteSymbol();
// --- If position is zero and not the first line,
// delete a line and move the lines up one position
   else if(m_text_cursor_y_pos>0)
      ShiftOnePositionUp();
// --- Calculate the size of the input field
   CalculateTextBoxSize();
// --- Set a new size for the input field
   ChangeTextBoxSize(true,true);
// --- Adjusting scroll bars
   CorrectingHorizontalScrollThumb();
   CorrectingVerticalScrollThumb();
// --- Update text in input field
   DrawTextAndCursor(true);
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling the "Enter" key |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyEnter(const long key_code)
  {
// --- Exit if it is not the 'Enter' key
   if(key_code!=KEY_ENTER)
      return(false);
// --- If there is selected text, delete it
   DeleteSelectedText();
// --- If multiline mode is disabled
   if(!m_multi_line_mode)
     {
      // --- Disable input field
      DeactivateTextBox();
      // --- Update
      Update(true);
      // --- We will send a message about this
      string str=(m_multi_line_mode)? TextCursorInfo() : "";
      ::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),CElementBase::Index(),str);
      return(false);
     }
// --- Move the lines down one position
   ShiftOnePositionDown();
// --- Calculate the size of the input field
   CalculateTextBoxSize();
// --- Set a new size for the input field
   ChangeTextBoxSize();
// --- Adjusting the vertical scroll bar
   CorrectingVerticalScrollThumb();
// ---Move cursor to beginning of line
   SetTextCursor(0,m_text_cursor_y_pos);
// ---Move scrollbar to top
   HorizontalScrolling(0);
// --- Update text in input field
   DrawTextAndCursor(true);
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling the 'Left' key |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyLeft(const long key_code)
  {
// --- Exit if (1) it is not the 'Left' key or (2) the 'Ctrl' key is pressed or (3) the 'Shift' key is pressed
   if(key_code!=KEY_LEFT || m_keys.KeyCtrlState() || m_keys.KeyShiftState())
      return(false);
// --- Move the text cursor to the left one character
   MoveTextCursor(TO_NEXT_LEFT_SYMBOL,false);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling the 'Right' key |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyRight(const long key_code)
  {
// --- Exit if (1) it is not the 'Right' key or (2) the 'Ctrl' key is pressed or (3) the 'Shift' key is pressed
   if(key_code!=KEY_RIGHT || m_keys.KeyCtrlState() || m_keys.KeyShiftState())
      return(false);
// --- Move the text cursor to the right one character
   MoveTextCursor(TO_NEXT_RIGHT_SYMBOL,false);
   return(true);
  }
//+------------------------------------------------------------------+
// | Processing the 'Up' key press |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyUp(const long key_code)
  {
// --- Exit if multiline mode is disabled
   if(!m_multi_line_mode)
      return(false);
// --- Exit if (1) it is not the 'Up' key or (2) the 'Shift' key is pressed
   if(key_code!=KEY_UP || m_keys.KeyShiftState())
      return(false);
// --- Move the text cursor up one line
   MoveTextCursor(TO_NEXT_UP_LINE,false);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling the 'Down' key |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyDown(const long key_code)
  {
// --- Exit if multiline mode is disabled
   if(!m_multi_line_mode)
      return(false);
// --- Exit if (1) it is not the 'Down' key or (2) the 'Shift' key is pressed
   if(key_code!=KEY_DOWN || m_keys.KeyShiftState())
      return(false);
// --- Move the text cursor down one line
   MoveTextCursor(TO_NEXT_DOWN_LINE,false);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling the 'Home' key press |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyHome(const long key_code)
  {
// --- Exit if (1) it is not the 'Home' key or (2) the 'Ctrl' key is pressed or (3) the 'Shift' key is pressed
   if(key_code!=KEY_HOME || m_keys.KeyCtrlState() || m_keys.KeyShiftState())
      return(false);
// --- Move the cursor to the beginning of the current line
   MoveTextCursor(TO_BEGIN_LINE,false);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling the 'End' key |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyEnd(const long key_code)
  {
// --- Exit if (1) it is not the 'End' key or (2) the 'Ctrl' key is pressed or (3) the 'Shift' key is pressed
   if(key_code!=KEY_END || m_keys.KeyCtrlState() || m_keys.KeyShiftState())
      return(false);
// --- Move cursor to the end of the current line
   MoveTextCursor(TO_END_LINE,false);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling simultaneous key presses Ctrl + Left |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlAndLeft(const long key_code)
  {
// --- Exit if (1) it is not the 'Left' key and (2) the 'Ctrl' key is not pressed or (3) the 'Shift' key is pressed
   if(!(key_code==KEY_LEFT && m_keys.KeyCtrlState()) || m_keys.KeyShiftState())
      return(false);
// --- Move the text cursor to the left one word
   MoveTextCursor(TO_NEXT_LEFT_WORD,false);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling simultaneous key presses Ctrl + Right |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlAndRight(const long key_code)
  {
// --- Exit if (1) it is not the 'Right' key and (2) the 'Ctrl' key is not pressed or (3) the 'Shift' key is pressed
   if(!(key_code==KEY_RIGHT && m_keys.KeyCtrlState()) || m_keys.KeyShiftState())
      return(false);
// --- Move the text cursor to the right one word
   MoveTextCursor(TO_NEXT_RIGHT_WORD,false);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling simultaneous key presses Ctrl + Home |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlAndHome(const long key_code)
  {
// --- Exit if (1) it is not the 'Home' key and (2) the 'Ctrl' key is not pressed or (3) the 'Shift' key is pressed
   if(!(key_code==KEY_HOME && m_keys.KeyCtrlState()) || m_keys.KeyShiftState())
      return(false);
// --- Move the cursor to the beginning of the first line
   MoveTextCursor(TO_BEGIN_FIRST_LINE,false);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling simultaneous key presses Ctrl + End |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlAndEnd(const long key_code)
  {
// --- Exit if (1) it is not the 'End' key and (2) the 'Ctrl' key is not pressed or (3) the 'Shift' key is pressed
   if(!(key_code==KEY_END && m_keys.KeyCtrlState()) || m_keys.KeyShiftState())
      return(false);
// ---Move cursor to end of last line
   MoveTextCursor(TO_END_LAST_LINE,false);
   return(true);
  }
//+------------------------------------------------------------------+
// | Processing key presses Shift + Left |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyShiftAndLeft(const long key_code)
  {
// --- Exit if (1) it is not the 'Left' key or (2) the 'Ctrl' key is pressed or (3) the 'Shift' key is not pressed
   if(key_code!=KEY_LEFT || m_keys.KeyCtrlState() || !m_keys.KeyShiftState())
      return(false);
// --- Move the text cursor to the left one character
   MoveTextCursor(TO_NEXT_LEFT_SYMBOL,true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Processing key presses Shift + Right |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyShiftAndRight(const long key_code)
  {
// --- Exit if (1) it is not the 'Right' key or (2) the 'Ctrl' key is pressed or (3) the 'Shift' key is not pressed
   if(key_code!=KEY_RIGHT || m_keys.KeyCtrlState() || !m_keys.KeyShiftState())
      return(false);
// --- Move the text cursor to the right one character
   MoveTextCursor(TO_NEXT_RIGHT_SYMBOL,true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Processing key presses Shift + Up |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyShiftAndUp(const long key_code)
  {
// --- Exit if (1) it is not the 'Up' key or (2) the 'Ctrl' key is pressed or (3) the 'Shift' key is not pressed
   if(key_code!=KEY_UP || m_keys.KeyCtrlState() || !m_keys.KeyShiftState())
      return(false);
// --- Move the text cursor up one line
   MoveTextCursor(TO_NEXT_UP_LINE,true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling key presses Shift + Down |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyShiftAndDown(const long key_code)
  {
// --- Exit if (1) it is not the 'Down' key or (2) the 'Ctrl' key is pressed or (3) the 'Shift' key is not pressed
   if(key_code!=KEY_DOWN || m_keys.KeyCtrlState() || !m_keys.KeyShiftState())
      return(false);
// --- Move the text cursor down one line
   MoveTextCursor(TO_NEXT_DOWN_LINE,true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling key presses Shift + Home |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyShiftAndHome(const long key_code)
  {
// --- Exit if (1) it is not the 'Home' key or (2) the 'Ctrl' key is pressed or (3) the 'Shift' key is not pressed
   if(key_code!=KEY_HOME || m_keys.KeyCtrlState() || !m_keys.KeyShiftState())
      return(false);
// --- Move the cursor to the beginning of the current line
   MoveTextCursor(TO_BEGIN_LINE,true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling key presses Shift + End |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyShiftAndEnd(const long key_code)
  {
// --- Exit if (1) it is not the 'End' key or (2) the 'Ctrl' key is pressed or (3) the 'Shift' key is not pressed
   if(key_code!=KEY_END || m_keys.KeyCtrlState() || !m_keys.KeyShiftState())
      return(false);
// --- Move cursor to the end of the current line
   MoveTextCursor(TO_END_LINE,true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling key presses Ctrl + Shift + Left |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlShiftAndLeft(const long key_code)
  {
// --- Exit if (1) it is not the 'Left' key and (2) the 'Ctrl' key is not pressed and (3) the 'Shift' key is pressed
   if(!(key_code==KEY_LEFT && m_keys.KeyCtrlState() && m_keys.KeyShiftState()))
      return(false);
// --- Move the text cursor to the left one word
   MoveTextCursor(TO_NEXT_LEFT_WORD,true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling key presses Ctrl + Shift + Right |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlShiftAndRight(const long key_code)
  {
// --- Exit if (1) it is not the 'Right' key and (2) the 'Ctrl' key is not pressed and (3) the 'Shift' key is pressed
   if(!(key_code==KEY_RIGHT && m_keys.KeyCtrlState() && m_keys.KeyShiftState()))
      return(false);
// --- Move the text cursor to the right one word
   MoveTextCursor(TO_NEXT_RIGHT_WORD,true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling key presses Ctrl + Shift + Home |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlShiftAndHome(const long key_code)
  {
// --- Exit if (1) it is not the 'Home' key and (2) the 'Ctrl' key is not pressed and (3) the 'Shift' key is pressed
   if(!(key_code==KEY_HOME && m_keys.KeyCtrlState() && m_keys.KeyShiftState()))
      return(false);
// --- Move the cursor to the beginning of the first line
   MoveTextCursor(TO_BEGIN_FIRST_LINE,true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Handling key presses Ctrl + Shift + End |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlShiftAndEnd(const long key_code)
  {
// --- Exit if (1) it is not the 'End' key and (2) the 'Ctrl' key is not pressed and (3) the 'Shift' key is pressed
   if(!(key_code==KEY_END && m_keys.KeyCtrlState() && m_keys.KeyShiftState()))
      return(false);
// ---Move cursor to end of last line
   MoveTextCursor(TO_END_LAST_LINE,true);
   return(true);
  }
//+------------------------------------------------------------------+
// | Set starting indexes for text selection |
//+------------------------------------------------------------------+
void CTextBox::SetStartSelectedTextIndexes(void)
  {
// --- If the starting indexes for text selection have not yet been set
   if(m_selected_line_from==WRONG_VALUE)
     {
      m_selected_line_from   =(int)m_text_cursor_y_pos;
      m_selected_symbol_from =(int)m_text_cursor_x_pos;
     }
  }
//+------------------------------------------------------------------+
// | Set ending indexes for text selection |
//+------------------------------------------------------------------+
void CTextBox::SetEndSelectedTextIndexes(void)
  {
// --- Set ending indexes for text selection
   m_selected_line_to   =(int)m_text_cursor_y_pos;
   m_selected_symbol_to =(int)m_text_cursor_x_pos;
// --- If all indices are equal, then reset the selection
   if(m_selected_line_from==m_selected_line_to && m_selected_symbol_from==m_selected_symbol_to)
      ResetSelectedText();
  }
//+------------------------------------------------------------------+
// | Select all text |
//+------------------------------------------------------------------+
void CTextBox::SelectAllText(void)
  {
// --- Get the size of the character array
   int symbols_total=::ArraySize(m_lines[0].m_symbol);
// --- Set indexes for text selection
   m_selected_line_from   =0;
   m_selected_line_to     =0;
   m_selected_symbol_from =0;
   m_selected_symbol_to   =symbols_total;
// --- Move the horizontal scrollbar slider to the last position
   HorizontalScrolling();
// ---Move cursor to end of line
   SetTextCursor(symbols_total,0);
  }
//+------------------------------------------------------------------+
// | Reset selected text |
//+------------------------------------------------------------------+
void CTextBox::ResetSelectedText(void)
  {
   m_selected_line_from   =WRONG_VALUE;
   m_selected_line_to     =WRONG_VALUE;
   m_selected_symbol_from =WRONG_VALUE;
   m_selected_symbol_to   =WRONG_VALUE;
  }
//+------------------------------------------------------------------+
// | Deactivating the input field |
//+------------------------------------------------------------------+
void CTextBox::DeactivateTextBox(void)
  {
// --- Exit if already deactivated
   if(!m_text_edit_state)
      return;
// --- Deactivate
   m_text_edit_state=false;
// --- Enable schedule management
   m_chart.SetInteger(CHART_KEYBOARD_CONTROL,true);
// --- Reset selection
   ResetSelectedText();
// --- If multiline mode is disabled
   if(!m_multi_line_mode)
     {
      // ---Move cursor to beginning of line
      SetTextCursor(0,0);
      // --- Move the scroll bar to the beginning of the line
      HorizontalScrolling(0);
     }
  }
//+------------------------------------------------------------------+
// | Fast forward scroll bar |
//+------------------------------------------------------------------+
void CTextBox::FastSwitching(void)
  {
// --- Exit if there is no focus on the element
   if(!CElementBase::MouseFocus())
      return;
// --- Return the counter to its original value if the mouse button is released
   if(!m_mouse.LeftButtonState() || m_scrollv.State() || m_scrollh.State())
      m_timer_counter=SPIN_DELAY_MSC;
// --- If the mouse button is pressed
   else
     {
      // --- Increase the counter by the set interval
      m_timer_counter+=TIMER_STEP_MSC;
      // --- Exit if less than zero
      if(m_timer_counter<0)
         return;
      //---
      bool scroll_v=false,scroll_h=false;
      // ---If scroll up
      if(m_scrollv.GetIncButtonPointer().MouseFocus())
        {
         m_scrollv.OnClickScrollInc((uint)Id(),0);
         scroll_v=true;
        }
      // --- If scroll down
      else if(m_scrollv.GetDecButtonPointer().MouseFocus())
        {
         m_scrollv.OnClickScrollDec((uint)Id(),1);
         scroll_v=true;
        }
      // --- If scroll left
      else if(m_scrollh.GetIncButtonPointer().MouseFocus())
        {
         m_scrollh.OnClickScrollInc((uint)Id(),2);
         scroll_h=true;
        }
      // --- If scroll to the right
      else if(m_scrollh.GetDecButtonPointer().MouseFocus())
        {
         m_scrollh.OnClickScrollDec((uint)Id(),3);
         scroll_h=true;
        }
      // --- Exit if no button is pressed
      if(!scroll_v && !scroll_h)
         return;
      // --- Offsets the input field
      ShiftData();
      // --- Refresh scrollbars
      if(scroll_v) m_scrollv.Update(true);
      if(scroll_h) m_scrollh.Update(true);
     }
  }
//+------------------------------------------------------------------+
// | Draws text |
//+------------------------------------------------------------------+
void CTextBox::Draw(void)
  {
// --- Output text
   CTextBox::TextOut();
// --- Drawing a frame
   DrawBorder();
  }
//+------------------------------------------------------------------+
// | Item Update |
//+------------------------------------------------------------------+
void CTextBox::Update(const bool redraw=false)
  {
// --- Redraw the table if specified
   if(redraw)
     {
      // ---Draw
      Draw();
      // --- Apply
      m_canvas.Update();
      m_textbox.Update();
      return;
     }
// --- Apply
   m_canvas.Update();
   m_textbox.Update();
  }
//+------------------------------------------------------------------+
// | Outputting text to canvas |
//+------------------------------------------------------------------+
void CTextBox::TextOut(void)
  {
// --- Clear canvas
   m_textbox.Erase(AreaColorCurrent());
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Adjustment in case of leaving the range
   m_text_cursor_y_pos=(m_text_cursor_y_pos>=lines_total)? lines_total-1 : m_text_cursor_y_pos;
// --- Get the size of the character array
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
// --- If multiline mode is enabled or the number of characters is greater than zero
   if(m_multi_line_mode || symbols_total>0)
     {
      // --- Text color
      uint text_color=TextColorCurrent();
      // --- Get the line width
      int line_width=(int)LineWidth(m_text_cursor_x_pos,m_text_cursor_y_pos);
      // --- Get the row height and loop through all the rows
      int line_height=(int)LineHeight();
      for(uint i=0; i<lines_total; i++)
        {
         // --- Get the coordinates for the text
         int x=m_text_x_offset;
         int y=m_text_y_offset+((int)i*line_height);
         // --- Get the size of the string
         uint string_length=::ArraySize(m_lines[i].m_symbol);
         // --- Drawing text
         for(uint s=0; s<string_length; s++)
           {
            // --- If there is selected text, determine its color, as well as the background color of the current character
            if(CheckSelectedText(i,s))
              {
               // --- Selected text color
               text_color=::ColorToARGB(m_selected_text_color);
               // --- Calculate the coordinates for drawing the background
               int x2 =x+m_lines[i].m_width[s];
               int y2 =y+line_height-1;
               // --- Draw the background color of the symbol
               m_textbox.FillRectangle(x,y,x2,y2,::ColorToARGB(m_selected_back_color,m_alpha));
              }
            else
               text_color=TextColorCurrent();
            // ---Draw symbol
            m_textbox.TextOut(x,y,m_lines[i].m_symbol[s],text_color,TA_LEFT);
            // --- X-coordinate for next character
            x+=m_lines[i].m_width[s];
           }
        }
     }
// --- If multiline mode is disabled and there are no characters, then the default text will be displayed (if specified)
   else
     {
      if(m_default_text!="")
         m_textbox.TextOut(m_area_x_size/2,m_area_y_size/2,m_default_text,::ColorToARGB(m_default_text_color),TA_CENTER|TA_VCENTER);
     }
  }
//+------------------------------------------------------------------+
// | Draws an input field frame |
//+------------------------------------------------------------------+
void CTextBox::DrawBorder(void)
  {
// --- Get the offset along the X axis
   int xo=(int)::ObjectGetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_XOFFSET);
   int yo=(int)::ObjectGetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_YOFFSET);
// --- Borders
   int x_size =(int)::ObjectGetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_XSIZE)-1;
   int y_size =(int)::ObjectGetInteger(m_chart_id,m_canvas.ChartObjectName(),OBJPROP_YSIZE)-1;
// --- Coordinates
   int x1=xo,y1=yo;
   int x2=xo+x_size;
   int y2=yo+y_size;
// --- Draw a rectangle without fill
   m_canvas.Rectangle(x1,y1,x2,y2,BorderColorCurrent());
  }
//+------------------------------------------------------------------+
// | Draws a text cursor |
//+------------------------------------------------------------------+
void CTextBox::DrawCursor(void)
  {
// --- Get the line height
   int line_height=(int)LineHeight();
// --- Get the X-coordinate of the cursor
   CalculateTextCursorX();
// --- Let's draw a text cursor
   for(int i=0; i<line_height; i++)
     {
      // --- Get the Y-coordinate for the pixel
      int y=m_text_y_offset+((int)m_text_cursor_y_pos*line_height)+i;
      // --- Get the current pixel color
      uint pixel_color=m_textbox.PixelGet(m_text_cursor_x,y);
      // --- Invert the color for the cursor
      pixel_color=::ColorToARGB(m_clr.Negative((color)pixel_color));
      m_textbox.PixelSet(m_text_cursor_x,y,::ColorToARGB(pixel_color));
     }
  }
//+------------------------------------------------------------------+
// | Displays text and blinking cursor |
//+------------------------------------------------------------------+
void CTextBox::DrawTextAndCursor(const bool show_state=false)
  {
// --- Define the state for the text cursor (show/hide)
   static bool state=false;
   state=(!show_state)? !state : show_state;
// --- Output text
   CTextBox::TextOut();
// --- Draw text cursor
   if(state)
      DrawCursor();
// --- Update input field
   m_canvas.Update();
   m_textbox.Update();
   m_scrollh.Update(true);
   m_scrollv.Update(true);
// --- Counter reset
   m_counter.ZeroTimeCounter();
  }
//+------------------------------------------------------------------+
// | Returns the background color relative to the current state of the element |
//+------------------------------------------------------------------+
uint CTextBox::AreaColorCurrent(void)
  {
   uint clr=(!CElementBase::IsLocked())? m_back_color : m_back_color_locked;
// ---Return color
   return(::ColorToARGB(clr,m_alpha));
  }
//+------------------------------------------------------------------+
// | Returns the text color relative to the element's current state |
//+------------------------------------------------------------------+
uint CTextBox::TextColorCurrent(void)
  {
   uint clr=(!CElementBase::IsLocked())? m_label_color : m_label_color_locked;
// ---Return color
   return(::ColorToARGB(clr));
  }
//+------------------------------------------------------------------+
// | Returns the border color relative to the element's current state |
//+------------------------------------------------------------------+
uint CTextBox::BorderColorCurrent(void)
  {
   uint clr=clrBlack;
// --- If the element is not locked
   if(!CElementBase::IsLocked())
     {
      // --- If the input field is activated
      if(m_text_edit_state)
         clr=m_border_color_pressed;
      // --- If not activated, then check the focus of the element
      else
         clr=(CElementBase::MouseFocus())? m_border_color_hover : m_border_color;
     }
// --- If the element is locked
   else
      clr=m_border_color_locked;
// ---Return color
   return(::ColorToARGB(clr));
  }
//+------------------------------------------------------------------+
// | Changing the color of objects |
//+------------------------------------------------------------------+
void CTextBox::ChangeObjectsColor(void)
  {
// --- Track color change only if itself and parent are available
   if(m_main.CElementBase::IsLocked() || !CElementBase::IsAvailable())
      return;
// --- If this is the moment of crossing the boundaries of the element
   if(CElementBase::CheckCrossingBorder())
     {
      // --- Change color
      DrawBorder();
      m_canvas.Update();
     }
  }
//+------------------------------------------------------------------+
// | Collects a string of characters |
//+------------------------------------------------------------------+
string CTextBox::CollectString(const uint line_index,const uint symbols_total=0)
  {
   m_temp_input_string="";
// --- Get the size of the string
   uint string_length=::ArraySize(m_lines[line_index].m_symbol);
//---
   for(uint i=0; i<string_length; i++)
     {
      if(symbols_total>0)
        {
         if(i==symbols_total)
            break;
        }
      //---
      ::StringAdd(m_temp_input_string,m_lines[line_index].m_symbol[i]);
     }
// --- Return the collected string
   return(m_temp_input_string);
  }
//+------------------------------------------------------------------+
// | Adds a symbol and its properties to structure arrays |
//+------------------------------------------------------------------+
void CTextBox::AddSymbol(const string key_symbol)
  {
// --- Get the size of the character array
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
// --- Set a new size for the arrays
   ArraysResize(m_text_cursor_y_pos,symbols_total+1);
// --- Shift all characters from the end of the array to the index of the character being added
   MoveSymbols(m_text_cursor_y_pos,0,m_text_cursor_x_pos,false);
// --- Get the width of the character
   int width=m_textbox.TextWidth(key_symbol);
// --- Add a character to the vacated element
   m_lines[m_text_cursor_y_pos].m_symbol[m_text_cursor_x_pos] =key_symbol;
   m_lines[m_text_cursor_y_pos].m_width[m_text_cursor_x_pos]  =width;
// --- Increment cursor position counter
   m_text_cursor_x_pos++;
  }
//+------------------------------------------------------------------+
// | Removes the character |
//+------------------------------------------------------------------+
void CTextBox::DeleteSymbol(void)
  {
// --- Get the size of the character array
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
// --- If the array is empty
   if(symbols_total<1)
     {
      // --- Set the cursor to the zero position of the current line
      SetTextCursor(0,m_text_cursor_y_pos);
      return;
     }
// --- Get the position of the previous character
   int check_pos=(int)m_text_cursor_x_pos-1;
// --- Exit if out of range
   if(check_pos<0)
      return;
// --- Shift all characters one element to the left of the index of the character to be removed
   MoveSymbols(m_text_cursor_y_pos,m_text_cursor_x_pos,check_pos);
// --- Decrement cursor position counter
   m_text_cursor_x_pos--;
// --- Set a new size for the arrays
   ArraysResize(m_text_cursor_y_pos,symbols_total-1);
  }
//+------------------------------------------------------------------+
// | Removes selected text |
//+------------------------------------------------------------------+
bool CTextBox::DeleteSelectedText(void)
  {
// --- Quit if no text is selected
   if(m_selected_line_from==WRONG_VALUE)
      return(false);
// --- If characters on the same line are deleted
   if(m_selected_line_from==m_selected_line_to)
      DeleteTextOnOneLine();
// --- If characters are removed from multiple lines
   else
      DeleteTextOnMultipleLines();
// --- Reset selected text
   ResetSelectedText();
// --- Calculate the size of the input field
   CalculateTextBoxSize();
// --- Set a new size for the input field
   ChangeTextBoxSize();
// --- Adjusting scroll bars
   CorrectingHorizontalScrollThumb();
   CorrectingVerticalScrollThumb();
// --- Update text in input field
   DrawTextAndCursor(true);
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
// | Deletes selected text on one line |
//+------------------------------------------------------------------+
void CTextBox::DeleteTextOnOneLine(void)
  {
   int symbols_total     =::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
   int symbols_to_delete =::fabs(m_selected_symbol_from-m_selected_symbol_to);
// --- If the starting index of the character is on the right
   if(m_selected_symbol_to<m_selected_symbol_from)
     {
      // --- Shift the characters to the free space in the current line
      MoveSymbols(m_text_cursor_y_pos,m_selected_symbol_from,m_selected_symbol_to);
     }
// --- If the starting index of the character is on the left
   else
     {
      // --- Move the text cursor to the left by the number of characters to be deleted
      m_text_cursor_x_pos-=symbols_to_delete;
      // --- Shift the characters to the free space in the current line
      MoveSymbols(m_text_cursor_y_pos,m_selected_symbol_to,m_selected_symbol_from);
     }
// --- Reduce the size of the current string array by the number of characters extracted from it
   ArraysResize(m_text_cursor_y_pos,symbols_total-symbols_to_delete);
  }
//+------------------------------------------------------------------+
// | Deletes selected text on multiple lines |
//+------------------------------------------------------------------+
void CTextBox::DeleteTextOnMultipleLines(void)
  {
// --- Total number of characters on the start and end lines
   uint symbols_total_line_from =::ArraySize(m_lines[m_selected_line_from].m_symbol);
   uint symbols_total_line_to   =::ArraySize(m_lines[m_selected_line_to].m_symbol);
// --- Number of intermediate lines to delete
   uint lines_to_delete=::fabs(m_selected_line_from-m_selected_line_to);
// --- Number of characters to remove on start and end lines
   uint symbols_to_delete_in_line_from =::fabs(symbols_total_line_from-m_selected_symbol_from);
   uint symbols_to_delete_in_line_to   =::fabs(symbols_total_line_to-m_selected_symbol_to);
// --- If the starting line is lower than the ending line
   if(m_selected_line_from>m_selected_line_to)
     {
      // --- Copy the characters that need to be transferred into the array
      string array[];
      CopyWrapSymbols(m_selected_line_from,m_selected_symbol_from,symbols_to_delete_in_line_from,array);
      // --- Set a new size for the destination line
      uint new_size=m_selected_symbol_to+symbols_to_delete_in_line_from;
      ArraysResize(m_selected_line_to,new_size);
      // --- Add data to the target string structure arrays
      PasteWrapSymbols(m_selected_line_to,m_selected_symbol_to,array);
      // --- Get the size of the string array
      uint lines_total=::ArraySize(m_lines);
      // --- Shift the lines up by the number of lines to be deleted
      MoveLines(m_selected_line_to+1,lines_total-lines_to_delete,lines_to_delete,false);
      // --- Set a new size to the string array
      ::ArrayResize(m_lines,lines_total-lines_to_delete);
     }
// --- If the starting line is higher than the ending line
   else
     {
      // --- Copy the characters that need to be transferred into the array
      string array[];
      CopyWrapSymbols(m_selected_line_to,m_selected_symbol_to,symbols_to_delete_in_line_to,array);
      // --- Set a new size for the destination line
      uint new_size=m_selected_symbol_from+symbols_to_delete_in_line_to;
      ArraysResize(m_selected_line_from,new_size);
      // --- Add data to the target string structure arrays
      PasteWrapSymbols(m_selected_line_from,m_selected_symbol_from,array);
      // --- Get the size of the string array
      uint lines_total=::ArraySize(m_lines);
      // --- Shift the lines up by the number of lines to be deleted
      MoveLines(m_selected_line_from+1,lines_total-lines_to_delete,lines_to_delete,false);
      // --- Set a new size to the string array
      ::ArrayResize(m_lines,lines_total-lines_to_delete);
      // --- Move the cursor to the starting position in the selection
      SetTextCursor(m_selected_symbol_from,m_selected_line_from);
     }
  }
//+------------------------------------------------------------------+
// | Returns the row height |
//+------------------------------------------------------------------+
uint CTextBox::LineHeight(void)
  {
// --- Set the font to be displayed on the canvas (needed to get the line height)
   m_textbox.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_NORMAL);
// --- Return the line height
   return(m_textbox.TextHeight("|"));
  }
//+------------------------------------------------------------------+
// | Возвращает ширину строки от начала до указанной позиции          |
//+------------------------------------------------------------------+
uint CTextBox::LineWidth(const uint symbol_index,const uint line_index)
  {
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Preventing out of range
   uint l=(line_index<lines_total)? line_index : lines_total-1;
// --- Get the size of the character array of the specified string
   uint symbols_total=::ArraySize(m_lines[l].m_symbol);
// --- Preventing out of range
   uint s=(symbol_index<symbols_total)? symbol_index : symbols_total;
// --- Sum up the width of all characters
   uint width=0;
   for(uint i=0; i<s; i++)
      width+=m_lines[l].m_width[i];
// --- Return line width
   return(width);
  }
//+------------------------------------------------------------------+
// | Returns the maximum line width |
//+------------------------------------------------------------------+
uint CTextBox::MaxLineWidth(void)
  {
   uint max_line_width=0;
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
   for(uint i=0; i<lines_total; i++)
     {
      // --- Get the size of the character array
      uint symbols_total=::ArraySize(m_lines[i].m_symbol);
      // --- Get the line width
      uint line_width=LineWidth(symbols_total,i);
      // --- Keep the maximum width
      if(line_width>max_line_width)
         max_line_width=line_width;
     }
// --- Return the maximum line width
   return(max_line_width);
  }
//+------------------------------------------------------------------+
// | Shifts rows up one position |
//+------------------------------------------------------------------+
void CTextBox::ShiftOnePositionUp(void)
  {
// --- If word wrapping is enabled
   if(m_word_wrap_mode)
     {
      // --- Index of previous row
      uint prev_line_index=m_text_cursor_y_pos-1;
      // --- Get the size of the character array
      uint symbols_total=::ArraySize(m_lines[prev_line_index].m_symbol);
      // --- If the previous line has an ending flag
      if(m_lines[prev_line_index].m_end_of_line)
        {
         // --- (1) Remove the terminator and (2) move the text cursor to the end of the line
         m_lines[prev_line_index].m_end_of_line=false;
         SetTextCursor(symbols_total,prev_line_index);
        }
      else
        {
         // --- (1) Move the text cursor to the end of the line and (2) delete the character
         SetTextCursor(symbols_total,prev_line_index);
         DeleteSymbol();
        }
      return;
     }
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Get the size of the character array
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
// --- If there are characters in this line, remember them to add to the previous line
   m_temp_input_string=(symbols_total>0)? CollectString(m_text_cursor_y_pos) : "";
// --- Shift the lines from the next element up one line
   MoveLines(m_text_cursor_y_pos,lines_total-1,1,false);
// --- Set a new size to the string array
   ::ArrayResize(m_lines,lines_total-1);
// --- Decrease the line counter
   m_text_cursor_y_pos--;
// --- Get the size of the character array
   symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
// --- Move the cursor to the end
   m_text_cursor_x_pos=symbols_total;
// --- Get the X-coordinate of the cursor
   CalculateTextCursorX();
// --- If there is a line that needs to be added to the previous one
   if(m_temp_input_string!="")
      AddToString(m_text_cursor_y_pos,m_temp_input_string);
  }
//+------------------------------------------------------------------+
// | Moves rows down one position |
//+------------------------------------------------------------------+
void CTextBox::ShiftOnePositionDown(void)
  {
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Increase the array by one element
   uint new_size=lines_total+1;
   ::ArrayResize(m_lines,new_size);
// --- Shift the lines from the current position one point down (starting from the end of the array)
   MoveLines(lines_total,m_text_cursor_y_pos+1,1);
// --- Move the text to a new line
   WrapTextToNewLine(m_text_cursor_y_pos,m_text_cursor_x_pos,true);
  }
//+------------------------------------------------------------------+
// | Checking for selected text |
//+------------------------------------------------------------------+
bool CTextBox::CheckSelectedText(const uint line_index,const uint symbol_index)
  {
   bool is_selected_text=false;
// --- Quit if there is no selected text
   if(m_selected_line_from==WRONG_VALUE)
      return(false);
// --- If the starting index is on the line below
   if(m_selected_line_from>m_selected_line_to)
     {
      // --- End line and character to the right of end selection
      if((int)line_index==m_selected_line_to && (int)symbol_index>=m_selected_symbol_to)
        { is_selected_text=true; }
      // --- Starting line and character to the left of the starting selection
      else if((int)line_index==m_selected_line_from && (int)symbol_index<m_selected_symbol_from)
        { is_selected_text=true; }
      // --- Intermediate line (all characters are highlighted)
      else if((int)line_index>m_selected_line_to && (int)line_index<m_selected_line_from)
        { is_selected_text=true; }
     }
// --- If the starting index is on the line above
   else if(m_selected_line_from<m_selected_line_to)
     {
      // --- End line and character to the left of end selection
      if((int)line_index==m_selected_line_to && (int)symbol_index<m_selected_symbol_to)
        { is_selected_text=true; }
      // --- Start line and character to the right of the start selection
      else if((int)line_index==m_selected_line_from && (int)symbol_index>=m_selected_symbol_from)
        { is_selected_text=true; }
      // --- Intermediate line (all characters are highlighted)
      else if((int)line_index<m_selected_line_to && (int)line_index>m_selected_line_from)
        { is_selected_text=true; }
     }
// --- If the start and end index are on the same line
   else
     {
      // --- Found the string being checked
      if((int)line_index>=m_selected_line_to && (int)line_index<=m_selected_line_from)
        {
         // --- If the cursor moves to the right and the character is in the selected range
         if(m_selected_symbol_from>m_selected_symbol_to)
           {
            if((int)symbol_index>=m_selected_symbol_to && (int)symbol_index<m_selected_symbol_from)
               is_selected_text=true;
           }
         // --- If the cursor is shifted to the left and the character is in the selected range
         else
           {
            if((int)symbol_index>=m_selected_symbol_from && (int)symbol_index<m_selected_symbol_to)
               is_selected_text=true;
           }
        }
     }
// --- Return result
   return(is_selected_text);
  }
//+------------------------------------------------------------------+
// | Checking for a required first line |
//+------------------------------------------------------------------+
uint CTextBox::CheckFirstLine(void)
  {
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- If there are no rows, set the size of the structure arrays
   if(lines_total<1)
      ::ArrayResize(m_lines,++lines_total);
// --- Return number of rows
   return(lines_total);
  }
//+------------------------------------------------------------------+
// | Sets a new size to the property arrays of the specified string |
//+------------------------------------------------------------------+
void CTextBox::ArraysResize(const uint line_index,const uint new_size)
  {
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Preventing out of range
   uint l=(line_index<lines_total)? line_index : lines_total-1;
// ---Array reserve size
   int reserve_size=100;
// --- Set the size of structure arrays
   ::ArrayResize(m_lines[line_index].m_symbol,new_size,reserve_size);
   ::ArrayResize(m_lines[line_index].m_width,new_size,reserve_size);
  }
//+------------------------------------------------------------------+
// | Makes a copy of the specified (source) string to a new location (dest.) |
//+------------------------------------------------------------------+
void CTextBox::LineCopy(const uint destination,const uint source)
  {
   ::ArrayCopy(m_lines[destination].m_width,m_lines[source].m_width);
   ::ArrayCopy(m_lines[destination].m_symbol,m_lines[source].m_symbol);
   m_lines[destination].m_end_of_line=m_lines[source].m_end_of_line;
  }
//+------------------------------------------------------------------+
// | Clears the specified string |
//+------------------------------------------------------------------+
void CTextBox::ClearLine(const uint line_index)
  {
   ::ArrayFree(m_lines[line_index].m_symbol);
   ::ArrayFree(m_lines[line_index].m_width);
  }
//+------------------------------------------------------------------+
// | Move the text cursor in a specified direction |
//+------------------------------------------------------------------+
void CTextBox::MoveTextCursor(const ENUM_MOVE_TEXT_CURSOR direction)
  {
   switch(direction)
     {
      // ---Move cursor one character to the left
      case TO_NEXT_LEFT_SYMBOL  : MoveTextCursorToLeft();        break;
      // ---Move cursor one character to the right
      case TO_NEXT_RIGHT_SYMBOL : MoveTextCursorToRight();       break;
      // ---Move cursor one word to the left
      case TO_NEXT_LEFT_WORD    : MoveTextCursorToLeft(true);    break;
      // ---Move cursor one word to the right
      case TO_NEXT_RIGHT_WORD   : MoveTextCursorToRight(true);   break;
      // ---Move cursor up one line
      case TO_NEXT_UP_LINE      : MoveTextCursorToUp();          break;
      // --- Move cursor down one line
      case TO_NEXT_DOWN_LINE    : MoveTextCursorToDown();        break;
      // --- Move the cursor to the beginning of the current line
      case TO_BEGIN_LINE : SetTextCursor(0,m_text_cursor_y_pos); break;
      // --- Move cursor to the end of the current line
      case TO_END_LINE :
        {
         // --- Get the number of characters in the current line
         uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
         // ---Move cursor
         SetTextCursor(symbols_total,m_text_cursor_y_pos);
         break;
        }
      // --- Move the cursor to the beginning of the first line
      case TO_BEGIN_FIRST_LINE : SetTextCursor(0,0); break;
      // ---Move cursor to end of last line
      case TO_END_LAST_LINE :
        {
         // --- Get the number of lines and characters in the last line
         uint lines_total   =::ArraySize(m_lines);
         uint symbols_total =::ArraySize(m_lines[lines_total-1].m_symbol);
         // ---Move cursor
         SetTextCursor(symbols_total,lines_total-1);
         break;
        }
     }
  }
//+------------------------------------------------------------------+
// | Move the text cursor in the specified direction and |
// | with condition |
//+------------------------------------------------------------------+
void CTextBox::MoveTextCursor(const ENUM_MOVE_TEXT_CURSOR direction,const bool with_highlighted_text)
  {
// --- If only moving the text cursor
   if(!with_highlighted_text)
     {
      // --- Reset selection
      ResetSelectedText();
      // --- Move the cursor to the beginning of the first line
      MoveTextCursor(direction);
     }
// --- If with text selection
   else
     {
      // --- Set starting indexes for text selection
      SetStartSelectedTextIndexes();
      // --- Move the text cursor one character
      MoveTextCursor(direction);
      // --- Set ending indexes for text selection
      SetEndSelectedTextIndexes();
     }
// --- Adjusting scroll bars
   CorrectingHorizontalScrollThumb();
   CorrectingVerticalScrollThumb();
// --- Update text in input field
   DrawTextAndCursor(true);
// --- We will send a message about this
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
  }
//+------------------------------------------------------------------+
// | Move the text cursor left |
//+------------------------------------------------------------------+
void CTextBox::MoveTextCursorToLeft(const bool to_next_word=false)
  {
// --- If you move to the next character
   if(!to_next_word)
     {
      // --- If the text cursor position is greater than zero
      if(m_text_cursor_x_pos>0)
        {
         // --- Shift it to the previous character
         m_text_cursor_x-=m_lines[m_text_cursor_y_pos].m_width[m_text_cursor_x_pos-1];
         // --- Decrease the character counter
         m_text_cursor_x_pos--;
        }
      else
        {
         // --- If this is not the first line
         if(m_text_cursor_y_pos>0)
           {
            // --- Let's go to the end of the previous line
            m_text_cursor_y_pos--;
            CorrectingTextCursorXPos();
           }
        }
      return;
     }
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Get the number of characters in the current line
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
// --- If the cursor is at the beginning of the current line and it is not the first line,
// move the cursor to the end of the previous line
   if(m_text_cursor_x_pos==0 && m_text_cursor_y_pos>0)
     {
      // --- Get the index of the previous row
      uint prev_line_index=m_text_cursor_y_pos-1;
      // --- Get the number of characters of the previous line
      symbols_total=::ArraySize(m_lines[prev_line_index].m_symbol);
      // --- Move the cursor to the end of the previous line
      SetTextCursor(symbols_total,prev_line_index);
     }
// --- If the cursor is not at the beginning of the current line or the cursor is on the first line
   else
     {
      // --- Find the beginning of a continuous sequence of characters (from right to left)
      for(uint i=m_text_cursor_x_pos; i<=symbols_total; i--)
        {
         // --- Move to next if cursor is at end of line
         if(i==symbols_total)
            continue;
         // --- If this is the first character of the line
         if(i==0)
           {
            // --- Place the cursor at the beginning of the line
            SetTextCursor(0,m_text_cursor_y_pos);
            break;
           }
         // --- If this is not the first character of the line
         else
           {
            // --- If you find the beginning of a continuous sequence on which for the first time.
            // The beginning is considered to be a space at the next index.
            if(i!=m_text_cursor_x_pos && 
               m_lines[m_text_cursor_y_pos].m_symbol[i]!=SPACE && 
               m_lines[m_text_cursor_y_pos].m_symbol[i-1]==SPACE)
              {
               // --- Place the cursor at the beginning of a new continuous sequence
               SetTextCursor(i,m_text_cursor_y_pos);
               break;
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
// | Move the text cursor one character to the right |
//+------------------------------------------------------------------+
void CTextBox::MoveTextCursorToRight(const bool to_next_word=false)
  {
// --- If you move to the next character
   if(!to_next_word)
     {
      // --- Get the size of the character array
      uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_width);
      // --- If this is not the end of the line
      if(m_text_cursor_x_pos<symbols_total)
        {
         // --- Move the text cursor position to the next character
         m_text_cursor_x+=m_lines[m_text_cursor_y_pos].m_width[m_text_cursor_x_pos];
         // --- Increase the symbol counter
         m_text_cursor_x_pos++;
        }
      else
        {
         // --- Get the size of the string array
         uint lines_total=::ArraySize(m_lines);
         // --- If this is not the last line
         if(m_text_cursor_y_pos<lines_total-1)
           {
            // ---Move cursor to beginning of next line
            m_text_cursor_x=m_text_x_offset;
            SetTextCursor(0,++m_text_cursor_y_pos);
           }
        }
      return;
     }
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Get the number of characters in the current line
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
// --- If the cursor is at the end of the line and it is not the last line, move the cursor to the beginning of the next line
   if(m_text_cursor_x_pos==symbols_total && m_text_cursor_y_pos<lines_total-1)
     {
      SetTextCursor(0,m_text_cursor_y_pos+1);
     }
// --- If the cursor is not at the end of the line or it is the last line
   else
     {
      // --- Find the beginning of a continuous sequence of characters (from left to right)
      for(uint i=m_text_cursor_x_pos; i<=symbols_total; i++)
        {
         // ---If this is the first character, move to the next
         if(i==0)
            continue;
         // --- If you reach the end of the line, move the cursor to the end
         if(i>=symbols_total-1)
           {
            SetTextCursor(symbols_total,m_text_cursor_y_pos);
            break;
           }
         // --- If you find the beginning of a continuous sequence on which for the first time.
         // The beginning is considered to be a space at the previous index.
         if(i!=m_text_cursor_x_pos && 
            m_lines[m_text_cursor_y_pos].m_symbol[i]!=SPACE && 
            m_lines[m_text_cursor_y_pos].m_symbol[i-1]==SPACE)
           {
            // --- Place the cursor at the end of a new continuous sequence
            SetTextCursor(i,m_text_cursor_y_pos);
            break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
// | Move the text cursor up one line |
//+------------------------------------------------------------------+
void CTextBox::MoveTextCursorToUp(void)
  {
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- If we do not go beyond the array
   if(m_text_cursor_y_pos-1<lines_total)
     {
      // --- Go to previous line
      m_text_cursor_y_pos--;
      // ---Adjusting the text cursor along the X axis
      CorrectingTextCursorXPos(m_text_cursor_x_pos);
     }
  }
//+------------------------------------------------------------------+
// | Move the text cursor down one line |
//+------------------------------------------------------------------+
void CTextBox::MoveTextCursorToDown(void)
  {
   uint lines_total=::ArraySize(m_lines);
// --- If we do not go beyond the array
   if(m_text_cursor_y_pos+1<lines_total)
     {
      // --- Go to next line
      m_text_cursor_y_pos++;
      // ---Adjusting the text cursor along the X axis
      CorrectingTextCursorXPos(m_text_cursor_x_pos);
     }
  }
//+------------------------------------------------------------------+
// | Places the cursor at the specified positions |
//+------------------------------------------------------------------+
void CTextBox::SetTextCursor(const uint x_pos,const uint y_pos)
  {
   m_text_cursor_x_pos=x_pos;
   m_text_cursor_y_pos=(!m_multi_line_mode)? 0 : y_pos;
  }
//+------------------------------------------------------------------+
// | Places the cursor at the specified positions by the mouse cursor |
//+------------------------------------------------------------------+
void CTextBox::SetTextCursorByMouseCursor(void)
  {
// --- Determine the coordinates in the input field under the mouse cursor
   int x =m_mouse.RelativeX(m_textbox);
   int y =m_mouse.RelativeY(m_textbox);
// --- Get the line height
   int line_height=(int)LineHeight();
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Define the pressing symbol
   for(uint l=0; l<lines_total; l++)
     {
      // --- Set the initial coordinates to check the condition
      int x_offset=m_text_x_offset;
      int y_offset=m_text_y_offset+((int)l*line_height);
      // --- Checking the Y axis condition
      bool y_pos_check=(l<lines_total-1)?(y>=y_offset && y<y_offset+line_height) : y>=y_offset;
      // --- If the click was not on this line, go to the next
      if(!y_pos_check)
         continue;
      // --- Get the size of the character array
      uint symbols_total=::ArraySize(m_lines[l].m_width);
      // --- If this is an empty string, move the cursor to the specified position and exit the loop
      if(symbols_total<1)
        {
         SetTextCursor(0,l);
         HorizontalScrolling(0);
         break;
        }
      // --- Find the symbol you clicked on
      for(uint s=0; s<symbols_total; s++)
        {
         // --- If a symbol is found, move the cursor to the specified position and exit the loop
         if(x>=x_offset && x<x_offset+m_lines[l].m_width[s])
           {
            SetTextCursor(s,l);
            l=lines_total;
            break;
           }
         // --- Add width of current character for next check
         x_offset+=m_lines[l].m_width[s];
         // --- If this is the last character, move the cursor to the end of the line and exit the loop
         if(s==symbols_total-1 && x>x_offset)
           {
            SetTextCursor(s+1,l);
            l=lines_total;
            break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
// | Adjusting the text cursor along the X axis |
//+------------------------------------------------------------------+
void CTextBox::CorrectingTextCursorXPos(const int x_pos=WRONG_VALUE)
  {
// --- Get the size of the character array
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_width);
// --- Determine the cursor position
   uint text_cursor_x_pos=0;
// --- If the position is specified
   if(x_pos!=WRONG_VALUE)
      text_cursor_x_pos=(x_pos>(int)symbols_total-1)? symbols_total : x_pos;
// --- If the position is not specified, then set the cursor to the end of the line
   else
      text_cursor_x_pos=symbols_total;
// --- Position zero if there are no characters in the string
   m_text_cursor_x_pos=(symbols_total<1)? 0 : text_cursor_x_pos;
// --- Get the X-coordinate of the cursor
   CalculateTextCursorX();
  }
//+------------------------------------------------------------------+
// | Calculating the X-coordinate for a text cursor |
//+------------------------------------------------------------------+
void CTextBox::CalculateTextCursorX(void)
  {
// --- Get the line width
   int line_width=(int)LineWidth(m_text_cursor_x_pos,m_text_cursor_y_pos);
// --- Calculate and save the X-coordinate of the cursor
   m_text_cursor_x=m_text_x_offset+line_width;
  }
//+------------------------------------------------------------------+
// | Calculation of Y-coordinate for a text cursor |
//+------------------------------------------------------------------+
void CTextBox::CalculateTextCursorY(void)
  {
// --- Get the line height
   int line_height=(int)LineHeight();
// --- Get the Y-coordinate of the cursor
   m_text_cursor_y=m_text_y_offset+int(line_height*m_text_cursor_y_pos);
  }
//+------------------------------------------------------------------+
// | Calculation of input field boundaries along two axes |
//+------------------------------------------------------------------+
void CTextBox::CalculateBoundaries(void)
  {
   CalculateXBoundaries();
   CalculateYBoundaries();
  }
//+------------------------------------------------------------------+
// | Calculation of input field boundaries along the X axis |
//+------------------------------------------------------------------+
void CTextBox::CalculateXBoundaries(void)
  {
// --- Get the X-coordinate and offset along the X axis
   int x       =(int)::ObjectGetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_XDISTANCE);
   int xoffset =(int)::ObjectGetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_XOFFSET);
// --- Calculate the boundaries of the visible part of the input field
   m_x_limit  =(x+xoffset)-x;
   m_x2_limit =(m_multi_line_mode)? (x+xoffset+m_x_size-m_scrollv.ScrollWidth()-m_text_x_offset)-x : (x+xoffset+m_x_size-m_text_x_offset)-x;
  }
//+------------------------------------------------------------------+
// | Calculation of input field boundaries along the Y axis |
//+------------------------------------------------------------------+
void CTextBox::CalculateYBoundaries(void)
  {
// --- Exit if multiline mode is disabled
   if(!m_multi_line_mode)
      return;
// --- Get the Y-coordinate and offset along the Y axis
   int y       =(int)::ObjectGetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_YDISTANCE);
   int yoffset =(int)::ObjectGetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_YOFFSET);
// --- Calculate the boundaries of the visible part of the input field
   m_y_limit  =(y+yoffset)-y;
   m_y2_limit =(y+yoffset+m_y_size-m_scrollh.ScrollWidth())-y;
  }
//+------------------------------------------------------------------+
// | Calculation of the X-coordinate of the scroll bar in the left border of the input field |
//+------------------------------------------------------------------+
int CTextBox::CalculateScrollThumbX(void)
  {
   return(m_text_cursor_x-m_text_x_offset);
  }
//+------------------------------------------------------------------+
// | Calculation of the X-coordinate of the scroll bar at the right border of the input field |
//+------------------------------------------------------------------+
int CTextBox::CalculateScrollThumbX2(void)
  {
   return((m_multi_line_mode)? m_text_cursor_x-m_x_size+m_scrollv.ScrollWidth()+m_text_x_offset : m_text_cursor_x-m_x_size+m_text_x_offset*2);
  }
//+------------------------------------------------------------------+
// | Calculating the X-position of a scrollbar slider |
//+------------------------------------------------------------------+
int CTextBox::CalculateScrollPosX(const bool to_right=false)
  {
   int    calc_x      =(!to_right)? CalculateScrollThumbX() : CalculateScrollThumbX2();
   double pos_x_value =(calc_x-::fmod((double)calc_x,(double)m_shift_x_step))/m_shift_x_step+((!to_right)? 0 : 1);
//---
   return((int)pos_x_value);
  }
//+------------------------------------------------------------------+
// | Calculation of the Y-coordinate of the scroll bar at the top border of the input field|
//+------------------------------------------------------------------+
int CTextBox::CalculateScrollThumbY(void)
  {
   return(m_text_cursor_y-m_text_y_offset);
  }
//+------------------------------------------------------------------+
// | Calculation of the Y-coordinate of the scroll bar at the bottom border of the input field |
//+------------------------------------------------------------------+
int CTextBox::CalculateScrollThumbY2(void)
  {
// --- Set the font to be displayed on the canvas (needed to get the line height)
   m_textbox.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_NORMAL);
// --- Get the line height
   int line_height=m_textbox.TextHeight("|");
// --- Calculate and return value
   return(m_text_cursor_y-m_y_size+m_scrollh.ScrollWidth()+m_text_y_offset+line_height);
  }
//+------------------------------------------------------------------+
// | Calculating the Y-position of a scroll bar |
//+------------------------------------------------------------------+
int CTextBox::CalculateScrollPosY(const bool to_down=false)
  {
   int    calc_y      =(!to_down)? CalculateScrollThumbY() : CalculateScrollThumbY2();
   double pos_y_value =(calc_y-::fmod((double)calc_y,(double)LineHeight()))/LineHeight()+((!to_down)? 0 : 1);
//---
   return((int)pos_y_value);
  }
//+------------------------------------------------------------------+
// | Adjusting the horizontal scroll bar |
//+------------------------------------------------------------------+
void CTextBox::CorrectingHorizontalScrollThumb(void)
  {
// --- Get the boundaries of the visible part of the input field
   CalculateXBoundaries();
// --- Get the X-coordinate of the cursor
   CalculateTextCursorX();
// --- If the text cursor has left the field of view to the left
   if(m_text_cursor_x<=m_x_limit)
     {
      HorizontalScrolling(CalculateScrollPosX());
     }
// --- If the text cursor has left the field of view to the right
   else if(m_text_cursor_x>=m_x2_limit)
     {
      HorizontalScrolling(CalculateScrollPosX(true));
     }
  }
//+------------------------------------------------------------------+
// | Adjusting the vertical scroll bar |
//+------------------------------------------------------------------+
void CTextBox::CorrectingVerticalScrollThumb(void)
  {
// --- Get the boundaries of the visible part of the input field
   CalculateYBoundaries();
// --- Get the Y-coordinate of the cursor
   CalculateTextCursorY();
// --- If the text cursor moves out of the visibility field upwards
   if(m_text_cursor_y<=m_y_limit)
     {
      VerticalScrolling(CalculateScrollPosY());
     }
// --- If the text cursor has left the field of view downwards
   else if(m_text_cursor_y+(int)LineHeight()>=m_y2_limit)
     {
      VerticalScrolling(CalculateScrollPosY(true));
     }
  }
//+------------------------------------------------------------------+
// | Calculates the dimensions of a text input field |
//+------------------------------------------------------------------+
void CTextBox::CalculateTextBoxSize(void)
  {
   CalculateTextBoxXSize();
   CalculateTextBoxYSize();
  }
//+------------------------------------------------------------------+
// | Calculates the width of a text input field |
//+------------------------------------------------------------------+
bool CTextBox::CalculateTextBoxXSize(void)
  {
// --- Remember the current sizes
   int area_x_size_curr=m_area_x_size;
// --- Get the maximum line width from the text input field
   int max_line_width=int((m_text_x_offset*2)+MaxLineWidth()+m_scrollv.ScrollWidth());
// --- Determine the total width
   m_area_x_size=(max_line_width>m_x_size)? max_line_width : m_x_size;
// --- Define the visible width
   m_area_visible_x_size=m_x_size-2;
// --- Let's keep the offset constraint
   m_shift_x2_limit=m_area_x_size-m_area_visible_x_size;
// --- A sign that the dimensions have not changed
   if(area_x_size_curr==m_area_x_size)
      return(false);
// --- A sign that the dimensions have changed
   return(true);
  }
//+------------------------------------------------------------------+
// | Calculates the height of a text input field |4
//+------------------------------------------------------------------+
bool CTextBox::CalculateTextBoxYSize(void)
  {
// --- Remember the current sizes
   int area_y_size_curr=m_area_y_size;
// --- Get the line height
   int line_height=(int)LineHeight();
// --- Get the size of the string array
   int lines_total=::ArraySize(m_lines);
// --- Calculate the total height of the element
   int lines_height=int((m_text_y_offset*2)+(line_height*lines_total)+m_scrollh.ScrollWidth());//*2);
// --- Determine the total height
   m_area_y_size=(m_multi_line_mode && lines_height>m_y_size)? lines_height : m_y_size;
// --- Determine the apparent height
   m_area_visible_y_size=m_y_size-2;
// --- Let's keep the offset constraint
   m_shift_y2_limit=m_area_y_size-m_area_visible_y_size;
// --- A sign that the dimensions have not changed
   if(area_y_size_curr==m_area_y_size)
      return(false);
// --- A sign that the dimensions have changed
   return(true);
  }
//+------------------------------------------------------------------+
// | Change the main dimensions of an element |
//+------------------------------------------------------------------+
void CTextBox::ChangeMainSize(const int x_size,const int y_size)
  {
// --- Set new size
   CElementBase::XSize(x_size);
   CElementBase::YSize(y_size);
   m_canvas.XSize(m_x_size);
   m_canvas.YSize(m_y_size);
   m_canvas.Resize(m_x_size,m_y_size);
  }
//+------------------------------------------------------------------+
// | Resize input field |
//+------------------------------------------------------------------+
void CTextBox::ChangeTextBoxSize(const bool is_x_offset=false,const bool is_y_offset=false)
  {
// --- Set new table size
   m_textbox.XSize(m_area_x_size);
   m_textbox.YSize(m_area_y_size);
   m_textbox.Resize(m_area_x_size,m_area_y_size);
// --- Set the size of the visible area
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_XSIZE,m_area_visible_x_size);
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_YSIZE,m_area_visible_y_size);
// --- Difference between total width and visible part
   int x_different =m_area_x_size-m_area_visible_x_size;
   int y_different =m_area_y_size-m_area_visible_y_size;
// --- Set the offset of the frame inside the image along the X and Y axes
   int x_offset  =(int)::ObjectGetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_XOFFSET);
   int y_offset  =(int)::ObjectGetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_YOFFSET);
   int x_offset2 =(!is_x_offset)? 0 : (x_offset<=x_different)? x_offset : x_different;
   int y_offset2 =(!is_y_offset)? 0 : (y_offset<=y_different)? y_offset : y_different;
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_XOFFSET,x_offset2);
   ::ObjectSetInteger(m_chart_id,m_textbox.ChartObjectName(),OBJPROP_YOFFSET,y_offset2);
// --- Resize scrollbars
   ChangeScrollsSize();
// --- Word wrapping
   WordWrap();
// --- Data correction
   ShiftData();
  }
//+------------------------------------------------------------------+
// | Resize scrollbars |
//+------------------------------------------------------------------+
void CTextBox::ChangeScrollsSize(void)
  {
// --- Calculation of the number of steps for displacement
   uint x_size_total         =m_area_x_size/m_shift_x_step;
   uint visible_x_size_total =m_area_visible_x_size/m_shift_x_step;
   uint y_size_total         =LinesTotal()+1;
   uint visible_y_size_total =VisibleLinesTotal();
// --- Calculate scrollbar sizes
   m_scrollh.Reinit(x_size_total,visible_x_size_total);
   m_scrollv.Reinit(y_size_total,visible_y_size_total);
// --- Exit if this is a single line input field
   if(!m_multi_line_mode)
      return;
// --- If (1) the horizontal scroll bar is not needed or (2) word wrap is enabled
   if(!m_scrollh.IsScroll() || m_word_wrap_mode)
     {
      HorizontalScrolling(0);
      // --- Hide horizontal scrollbar
      m_scrollh.Hide();
      // --- Change the height of the vertical scroll bar
      if(m_multi_line_mode)
         m_scrollv.ChangeYSize(CElementBase::YSize()-2);
     }
   else
     {
      // --- Show horizontal scroll bar
      if(CElementBase::IsVisible())
        {
         m_scrollh.Show();
         m_scrollh.GetIncButtonPointer().Show();
         m_scrollh.GetDecButtonPointer().Show();
         // --- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
        }
      // --- Calculate and change the height of the vertical scrollbar
      if(m_multi_line_mode)
         m_scrollv.ChangeYSize(CElementBase::YSize()-m_scrollh.ScrollWidth()-2);
     }
// --- If the vertical scroll bar is not needed
   if(!m_scrollv.IsScroll())
     {
      VerticalScrolling(0);
      // --- Hide vertical scroll bar
      m_scrollv.Hide();
      // --- Change the width of the horizontal scroll bar if word wrap is disabled
      if(!m_word_wrap_mode)
         m_scrollh.ChangeXSize(CElementBase::XSize()-1);
     }
   else
     {
      // --- Show vertical scroll bar
      if(CElementBase::IsVisible())
        {
         m_scrollv.Show();
         m_scrollv.GetIncButtonPointer().Show();
         m_scrollv.GetDecButtonPointer().Show();
         // --- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
        }
      // --- Change the width of the horizontal scroll bar if word wrap is disabled
      if(!m_word_wrap_mode)
         m_scrollh.ChangeXSize(CElementBase::XSize()-m_scrollh.ScrollWidth()-1);
     }
  }
//+------------------------------------------------------------------+
// | Word wrapping |
//+------------------------------------------------------------------+
void CTextBox::WordWrap(void)
  {
// --- Exit if (1) multiline input field or (2) word wrap modes are disabled
   if(!m_multi_line_mode || !m_word_wrap_mode)
      return;
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Let's check whether the text needs to be aligned to the width of the input field
   for(uint i=0; i<lines_total; i++)
     {
      // --- To determine the first visible indices of (1) character and (2) space
      int symbol_index =WRONG_VALUE;
      int space_index  =WRONG_VALUE;
      // --- Next line index
      uint next_line_index=i+1;
      // --- If the line does not fit, then move part of the current line to a new line
      if(CheckForOverflow(i,symbol_index,space_index))
        {
         // --- If a space is found, it will not be transferred
         if(space_index!=WRONG_VALUE)
            space_index++;
         // --- Increase the array of strings by one element
         ::ArrayResize(m_lines,++lines_total);
         // --- Shift the lines from the current position one point down
         MoveLines(lines_total-1,next_line_index,1);
         // --- Let's check the index of the character from which the text will be transferred
         int check_index=(space_index==WRONG_VALUE && symbol_index!=WRONG_VALUE)? symbol_index : space_index;
         // --- Move the text to a new line
         WrapTextToNewLine(i,check_index);
        }
      // --- If the line fits, then check whether it is necessary to carry out a reverse wrap
      else
        {
         // --- Skip if (1) it is a line ending or (2) it is the last line
         if(m_lines[i].m_end_of_line || next_line_index>=lines_total)
            continue;
         // --- Determine the number of characters to be transferred
         uint wrap_symbols_total=0;
         // --- If you need to wrap the remaining text of the next line to the current one
         if(WrapSymbolsTotal(i,wrap_symbols_total))
           {
            WrapTextToPrevLine(next_line_index,wrap_symbols_total,true);
            // --- Update array size for later use in loop
            lines_total=::ArraySize(m_lines);
            // ---Step back to avoid missing a line for the next check
            i--;
           }
         // --- Move only what fits
         else
            WrapTextToPrevLine(next_line_index,wrap_symbols_total);
        }
     }
  }
//+------------------------------------------------------------------+
// | Line overflow check |
//+------------------------------------------------------------------+
bool CTextBox::CheckForOverflow(const uint line_index,int &symbol_index,int &space_index)
  {
// --- Get the size of the character array
   uint symbols_total=::ArraySize(m_lines[line_index].m_symbol);
// --- Indents
   uint x_offset_plus=m_text_x_offset+m_scrollv.XSize();
// --- Get the full width of the line
   uint full_line_width=LineWidth(symbols_total,line_index)+x_offset_plus;
// --- If the width of this line fits in the field
   if(full_line_width<(uint)m_area_visible_x_size)
      return(false);
// --- Define the indices of the overflow symbols
   for(uint s=symbols_total-1; s>0; s--)
     {
      // --- Get (1) the width of the substring from the beginning to the current character and (2) the character
      uint   line_width =LineWidth(s,line_index)+x_offset_plus;
      string symbol     =m_lines[line_index].m_symbol[s];
      // --- If you haven't found a visible symbol yet
      if(symbol_index==WRONG_VALUE)
        {
         // --- If the width of the substring fits into the input field area, remember the character index
         if(line_width<(uint)m_area_visible_x_size)
            symbol_index=(int)s;
         // ---Go to next character
         continue;
        }
      // --- If it is a space, remember its index and stop the loop
      if(symbol==SPACE)
        {
         space_index=(int)s;
         break;
        }
     }
// --- Fulfilling the condition means that the line does not fit
   bool is_overflow=(symbol_index!=WRONG_VALUE || space_index!=WRONG_VALUE);
// --- Return result
   return(is_overflow);
  }
//+------------------------------------------------------------------+
// | Returns the number of words in the specified string |
//+------------------------------------------------------------------+
uint CTextBox::WordsTotal(const uint line_index)
  {
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Preventing out of range
   uint l=(line_index<lines_total)? line_index : lines_total-1;
// --- Get the size of the character array of the specified string
   uint symbols_total=::ArraySize(m_lines[l].m_symbol);
// --- Word counter
   uint words_counter=0;
// --- We look for a space at the specified index
   for(uint s=1; s<symbols_total; s++)
     {
      // --- We count if (2) we reached the end of the line or (2) we found a space (end of the word)
      if(s+1==symbols_total || (m_lines[l].m_symbol[s]!=SPACE && m_lines[l].m_symbol[s-1]==SPACE))
         words_counter++;
     }
// --- Return word count
   return((words_counter<1)? 1 : words_counter);
  }
//+------------------------------------------------------------------+
// | Returns the number of characters to be transferred with the volume attribute |
//+------------------------------------------------------------------+
bool CTextBox::WrapSymbolsTotal(const uint line_index,uint &wrap_symbols_total)
  {
// --- Signs of (1) the number of characters to wrap and (2) lines without spaces
   bool is_all_text=false,is_solid_row=false;
// --- Get the size of the character array
   uint symbols_total=::ArraySize(m_lines[line_index].m_symbol);
// --- Indents
   uint x_offset_plus=m_text_x_offset+m_scrollv.XSize();
// --- Get the full width of the line
   uint full_line_width=LineWidth(symbols_total,line_index)+x_offset_plus;
// --- Get the width of the free space
   uint free_space=m_area_visible_x_size-full_line_width;
// --- Get the number of words in the next line
   uint next_line_index =line_index+1;
   uint words_total     =WordsTotal(next_line_index);
// --- Get the size of the character array
   uint next_line_symbols_total=::ArraySize(m_lines[next_line_index].m_symbol);
// --- Determine the number of words that can be carried over from the next line (search by space)
   for(uint w=0; w<words_total; w++)
     {
      // --- Get (1) the space index and (2) the width of the substring from the beginning to the space
      uint ss_index        =SymbolIndexBySpaceNumber(next_line_index,w);
      uint substring_width =LineWidth(ss_index,next_line_index);
      // --- If the substring fits into the free space of the current line
      if(substring_width<free_space)
        {
         // --- ...let's check if we can add one more word
         wrap_symbols_total=ss_index;
         // --- Stop if this is the entire line
         if(next_line_symbols_total==wrap_symbols_total)
           {
            is_all_text=true;
            break;
           }
        }
      else
        {
         // --- If it is a continuous line without a space
         if(ss_index==next_line_symbols_total)
            is_solid_row=true;
         //---
         break;
        }
     }
// --- Return the result immediately if (1) it is a string with a space or (2) there is no free space
   if(!is_solid_row || free_space<1)
      return(is_all_text);
// --- Get the full width of the next line
   full_line_width=LineWidth(next_line_symbols_total,next_line_index)+x_offset_plus;
// --- If (1) the line does not fit and there are no spaces at the end of the (2) current and (3) previous lines
   if(full_line_width>free_space && 
      m_lines[line_index].m_symbol[symbols_total-1]!=SPACE && 
      m_lines[next_line_index].m_symbol[next_line_symbols_total-1]!=SPACE)
     {
      // --- Determine the number of characters that can be moved from the next line
      for(uint s=next_line_symbols_total-1; s>=0; s--)
        {
         // --- Get the width of the substring from the beginning to the specified character
         uint substring_width=LineWidth(s,next_line_index);
         // --- If the substring does not fit into the free space of the specified container, move to the next character
         if(substring_width>=free_space)
            continue;
         // --- If the substring fits, remember the value and stop
         wrap_symbols_total=s;
         break;
        }
     }
// --- Return true if all text needs to be moved
   return(is_all_text);
  }
//+------------------------------------------------------------------+
// | Returns the index of the space character by its number |
//+------------------------------------------------------------------+
uint CTextBox::SymbolIndexBySpaceNumber(const uint line_index,const uint space_index)
  {
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Preventing out of range
   uint l=(line_index<lines_total)? line_index : lines_total-1;
// --- Get the size of the character array of the specified string
   uint symbols_total=::ArraySize(m_lines[l].m_symbol);
// --- (1) To determine the index of the space character and (2) the space counter
   uint symbol_index  =0;
   uint space_counter =0;
// --- We look for a space at the specified index
   for(uint s=1; s<symbols_total; s++)
     {
      // --- If you find a gap
      if(m_lines[l].m_symbol[s]!=SPACE && m_lines[l].m_symbol[s-1]==SPACE)
        {
         // --- If the counter is equal to the specified space index, remember it and stop the loop
         if(space_counter==space_index)
           {
            symbol_index=s;
            break;
           }
         // ---Increase the space counter
         space_counter++;
        }
     }
// --- Return string size if space index is not found
   return((symbol_index<1)? symbols_total : symbol_index);
  }
//+------------------------------------------------------------------+
// | Move rows a specified number of positions |
//+------------------------------------------------------------------+
void CTextBox::MoveLines(const uint from_index,const uint to_index,const uint count,const bool to_down=true)
  {
// --- Shift rows downwards
   if(to_down)
     {
      for(uint i=from_index; i>to_index; i--)
        {
         // --- Index of the previous element of the string array
         uint prev_index=i-count;
         // --- Get the size of the character array
         uint symbols_total=::ArraySize(m_lines[prev_index].m_symbol);
         // --- Set a new size for the arrays
         ArraysResize(i,symbols_total);
         // --- Make a copy of a string
         LineCopy(i,prev_index);
         // ---If this is the last iteration
         if(prev_index==to_index)
           {
            // --- Exit if this is the first line
            if(to_index<1)
               break;
           }
        }
     }
// --- Shift lines upward
   else
     {
      for(uint i=from_index; i<to_index; i++)
        {
         // --- Index of the next element of the string array
         uint next_index=i+count;
         // --- Get the size of the character array
         uint symbols_total=::ArraySize(m_lines[next_index].m_symbol);
         // --- Set a new size for the arrays
         ArraysResize(i,symbols_total);
         // --- Make a copy of a string
         LineCopy(i,next_index);
        }
     }
  }
//+------------------------------------------------------------------+
// | Move characters in a specified string |
//+------------------------------------------------------------------+
void CTextBox::MoveSymbols(const uint line_index,const uint from_pos,const uint to_pos,const bool to_left=true)
  {
// --- Get the size of the character array
   uint symbols_total=::ArraySize(m_lines[line_index].m_symbol);
// --- Difference
   uint offset=from_pos-to_pos;
// --- If you need to shift characters to the left
   if(to_left)
     {
      for(uint s=to_pos; s<symbols_total-offset; s++)
        {
         uint i=s+offset;
         m_lines[line_index].m_symbol[s] =m_lines[line_index].m_symbol[i];
         m_lines[line_index].m_width[s]  =m_lines[line_index].m_width[i];
        }
     }
// --- If you need to shift characters to the right
   else
     {
      for(uint s=symbols_total-1; s>to_pos; s--)
        {
         uint i=s-1;
         m_lines[line_index].m_symbol[s] =m_lines[line_index].m_symbol[i];
         m_lines[line_index].m_width[s]  =m_lines[line_index].m_width[i];
        }
     }
  }
//+------------------------------------------------------------------+
// | Adds text to the specified line |
//+------------------------------------------------------------------+
void CTextBox::AddToString(const uint line_index,const string text)
  {
// --- Transfer the string to the array
   uchar array[];
   int total=::StringToCharArray(text,array)-1;
   if(total<0)
      return;
// --- Get the size of the character array
   uint symbols_total=::ArraySize(m_lines[line_index].m_symbol);
// --- Set a new size for the arrays
   uint new_size=symbols_total+total;
   ArraysResize(line_index,new_size);
// --- Add data to structure arrays
   for(uint i=symbols_total; i<new_size; i++)
     {
      m_lines[line_index].m_symbol[i] =::CharToString(array[i-symbols_total]);
      m_lines[line_index].m_width[i]  =m_textbox.TextWidth(m_lines[line_index].m_symbol[i]);
     }
  }
//+------------------------------------------------------------------+
// | Copies the characters to be transferred into the passed array |
//+------------------------------------------------------------------+
void CTextBox::CopyWrapSymbols(const uint line_index,const uint start_pos,const uint symbols_total,string &array[])
  {
// --- Set the size of the array
   ::ArrayResize(array,symbols_total);
// --- Copy the characters that need to be transferred into the array
   for(uint i=0; i<symbols_total; i++)
      array[i]=m_lines[line_index].m_symbol[start_pos+i];
  }
//+------------------------------------------------------------------+
// | Inserts characters into the specified string |
//+------------------------------------------------------------------+
void CTextBox::PasteWrapSymbols(const uint line_index,const uint start_pos,string &array[])
  {
   uint array_size=::ArraySize(array);
// --- Add data to newline structure arrays
   for(uint i=0; i<array_size; i++)
     {
      uint s=start_pos+i;
      m_lines[line_index].m_symbol[s] =array[i];
      m_lines[line_index].m_width[s]  =m_textbox.TextWidth(array[i]);
     }
  }
//+------------------------------------------------------------------+
// | Wrap text to new line |
//+------------------------------------------------------------------+
void CTextBox::WrapTextToNewLine(const uint line_index,const uint symbol_index,const bool by_pressed_enter=false)
  {
// --- Get the size of a character array from a string
   uint symbols_total=::ArraySize(m_lines[line_index].m_symbol);
// --- Last symbol index
   uint last_symbol_index=symbols_total-1;
// --- Correction in case of empty line
   uint check_symbol_index=(symbol_index>last_symbol_index && symbol_index!=symbols_total)? last_symbol_index : symbol_index;
// --- Next line index
   uint next_line_index=line_index+1;
// --- Number of characters to wrap on a new line
   uint new_line_size=symbols_total-check_symbol_index;
// --- Copy the characters that need to be transferred into the array
   string array[];
   CopyWrapSymbols(line_index,check_symbol_index,new_line_size,array);
// --- Set a new size for structure arrays in a row
   ArraysResize(line_index,symbols_total-new_line_size);
// --- Set a new size to the structure arrays in a new line
   ArraysResize(next_line_index,new_line_size);
// --- Add data to newline structure arrays
   PasteWrapSymbols(next_line_index,0,array);
// --- Define the new position of the text cursor
   int x_pos=int(new_line_size-(symbols_total-m_text_cursor_x_pos));
   m_text_cursor_x_pos =(x_pos<0)? (int)m_text_cursor_x_pos : x_pos;
   m_text_cursor_y_pos =(x_pos<0)? (int)line_index : (int)next_line_index;
// --- If it is specified that the call is made by pressing the Enter key
   if(by_pressed_enter)
     {
      // --- If the line had an ending sign, then set the ending sign for the current and the next one
      if(m_lines[line_index].m_end_of_line)
        {
         m_lines[line_index].m_end_of_line      =true;
         m_lines[next_line_index].m_end_of_line =true;
        }
      // --- If not, then only the current one
      else
        {
         m_lines[line_index].m_end_of_line      =true;
         m_lines[next_line_index].m_end_of_line =false;
        }
     }
   else
     {
      // --- If the line had an ending flag, then continue and set the flag on the next line
      if(m_lines[line_index].m_end_of_line)
        {
         m_lines[line_index].m_end_of_line      =false;
         m_lines[next_line_index].m_end_of_line =true;
        }
      // --- If the line did not have an ending sign, then continue in both lines
      else
        {
         m_lines[line_index].m_end_of_line      =false;
         m_lines[next_line_index].m_end_of_line =false;
        }
     }
  }
//+------------------------------------------------------------------+
// | Wrap text from next line to current |
//+------------------------------------------------------------------+
void CTextBox::WrapTextToPrevLine(const uint next_line_index,const uint wrap_symbols_total,const bool is_all_text=false)
  {
// --- Get the size of a character array from a string
   uint symbols_total=::ArraySize(m_lines[next_line_index].m_symbol);
// --- Index of previous row
   uint prev_line_index=next_line_index-1;
// --- Copy the characters that need to be transferred into the array
   string array[];
   CopyWrapSymbols(next_line_index,0,wrap_symbols_total,array);
// --- Get the size of the character array from the previous line
   uint prev_line_symbols_total=::ArraySize(m_lines[prev_line_index].m_symbol);
// --- Increase the size of the array of the previous line by the added number of characters
   uint new_prev_line_size=prev_line_symbols_total+wrap_symbols_total;
   ArraysResize(prev_line_index,new_prev_line_size);
// --- Add data to newline structure arrays
   PasteWrapSymbols(prev_line_index,new_prev_line_size-wrap_symbols_total,array);
// --- Shift the characters to the free space in the current line
   MoveSymbols(next_line_index,wrap_symbols_total,0);
// --- Reduce the size of the current string array by the number of characters extracted from it
   ArraysResize(next_line_index,symbols_total-wrap_symbols_total);
// --- Adjust text cursor
   if((is_all_text && next_line_index==m_text_cursor_y_pos) || 
      (!is_all_text && next_line_index==m_text_cursor_y_pos && wrap_symbols_total>0))
     {
      m_text_cursor_x_pos=new_prev_line_size-(wrap_symbols_total-m_text_cursor_x_pos);
      m_text_cursor_y_pos--;
     }
// --- Exit if this is not all the remaining text of the line
   if(!is_all_text)
      return;
// --- Add a terminator for the previous line if the current line also has one
   if(m_lines[next_line_index].m_end_of_line)
      m_lines[next_line_index-1].m_end_of_line=true;
// --- Get the size of the string array
   uint lines_total=::ArraySize(m_lines);
// --- Move the lines up one
   MoveLines(next_line_index,lines_total-1,1,false);
// --- Set a new size to the string array
   ::ArrayResize(m_lines,lines_total-1);
  }
//+------------------------------------------------------------------+
// | Change the width along the right edge of the form |
//+------------------------------------------------------------------+
void CTextBox::ChangeWidthByRightWindowSide(void)
  {
// --- Exit if the mode of fixing to the right edge of the form is enabled
   if(m_anchor_right_window_side)
      return;
// --- Coordinates
   int x=0;
// --- Dimensions
   int x_size =m_main.X2()-CElementBase::X()-m_auto_xresize_right_offset;
   int y_size =(m_auto_yresize_mode)? m_main.Y2()-CElementBase::Y()-m_auto_yresize_bottom_offset : m_y_size;
// --- Set new size
   ChangeMainSize(x_size,y_size);
// --- Calculate the size of the input field
   CalculateTextBoxSize();
// --- Set a new size for the input field
   ChangeTextBoxSize();
// --- In word wrap mode, you need to recalculate and set the dimensions
   if(m_word_wrap_mode)
     {
      CalculateTextBoxSize();
      ChangeTextBoxSize();
     }
// --- Draw text and deactivate the input field
   DeactivateTextBox();
// --- Redraw element
   Draw();
   if(m_scrollh.IsScroll())
      m_scrollh.Update(true);
   if(m_scrollv.IsScroll())
      m_scrollv.Update(true);
  }
//+------------------------------------------------------------------+
// | Change the height along the bottom edge of the window |
//+------------------------------------------------------------------+
void CTextBox::ChangeHeightByBottomWindowSide(void)
  {
// --- Exit if the mode of fixing to the bottom edge of the form is enabled
   if(m_anchor_bottom_window_side)
      return;
// --- Coordinates
   int y=0;
// --- Dimensions
   int x_size =(m_auto_xresize_mode)? m_main.X2()-CElementBase::X()-m_auto_xresize_right_offset : m_x_size;
   int y_size =m_main.Y2()-CElementBase::Y()-m_auto_yresize_bottom_offset;
// --- Set new size
   ChangeMainSize(x_size,y_size);
// --- Calculate the size of the input field
   CalculateTextBoxSize();
// --- Set a new size for the input field
   ChangeTextBoxSize();
// --- Draw text and deactivate the input field
   DeactivateTextBox();
// --- Redraw element
   Draw();
   if(m_scrollh.IsScroll())
      m_scrollh.Update(true);
   if(m_scrollv.IsScroll())
      m_scrollv.Update(true);
  }
//+------------------------------------------------------------------+
