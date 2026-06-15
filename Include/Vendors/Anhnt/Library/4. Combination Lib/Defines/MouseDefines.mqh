//+------------------------------------------------------------------+
//|                                               MouseDefines.mqh
//|  Extracted from Artyom Trishkin's DoEasy Defines.mqh            |
//+------------------------------------------------------------------+
#ifndef __MOUSE_DEFINES_MQH__
#define __MOUSE_DEFINES_MQH__
#include "EventDefines.mqh"
//+------------------------------------------------------------------+
//| Data for working with mouse                                      |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| The list of possible mouse buttons, Shift and Ctrl keys states   |
//+------------------------------------------------------------------+
enum ENUM_MOUSE_BUTT_KEY_STATE
  {
   MOUSE_BUTT_KEY_STATE_NONE              = 0,        // Nothing is clicked
//--- Mouse buttons
   MOUSE_BUTT_KEY_STATE_LEFT              = 1,        // The left mouse button is clicked
   MOUSE_BUTT_KEY_STATE_RIGHT             = 2,        // The right mouse button is clicked
   MOUSE_BUTT_KEY_STATE_MIDDLE            = 16,       // The middle mouse button is clicked
   MOUSE_BUTT_KEY_STATE_WHELL             = 128,      // Scrolling the mouse wheel
   MOUSE_BUTT_KEY_STATE_X1                = 32,       // The first additional mouse button is clicked
   MOUSE_BUTT_KEY_STATE_X2                = 64,       // The second additional mouse button is clicked
   MOUSE_BUTT_KEY_STATE_LEFT_RIGHT        = 3,        // The left and right mouse buttons clicked
//--- Keyboard keys
   MOUSE_BUTT_KEY_STATE_SHIFT             = 4,        // Shift is being held
   MOUSE_BUTT_KEY_STATE_CTRL              = 8,        // Ctrl is being held
   MOUSE_BUTT_KEY_STATE_CTRL_CHIFT        = 12,       // Ctrl and Shift are being held
//--- Left mouse button combinations
   MOUSE_BUTT_KEY_STATE_LEFT_WHELL        = 129,      // The left mouse button is clicked and the wheel is being scrolled
   MOUSE_BUTT_KEY_STATE_LEFT_SHIFT        = 5,        // The left mouse button is clicked and Shift is being held
   MOUSE_BUTT_KEY_STATE_LEFT_CTRL         = 9,        // The left mouse button is clicked and Ctrl is being held
   MOUSE_BUTT_KEY_STATE_LEFT_CTRL_CHIFT   = 13,       // The left mouse button is clicked, Ctrl and Shift are being held
//--- Right mouse button combinations
   MOUSE_BUTT_KEY_STATE_RIGHT_WHELL       = 130,      // The right mouse button is clicked and the wheel is being scrolled
   MOUSE_BUTT_KEY_STATE_RIGHT_SHIFT       = 6,        // The right mouse button is clicked and Shift is being held
   MOUSE_BUTT_KEY_STATE_RIGHT_CTRL        = 10,       // The right mouse button is clicked and Ctrl is being held
   MOUSE_BUTT_KEY_STATE_RIGHT_CTRL_CHIFT  = 14,       // The right mouse button is clicked, Ctrl and Shift are being held
//--- Middle mouse button combinations
   MOUSE_BUTT_KEY_STATE_MIDDLE_WHEEL      = 144,      // The middle mouse button is clicked and the wheel is being scrolled
   MOUSE_BUTT_KEY_STATE_MIDDLE_SHIFT      = 20,       // The middle mouse button is clicked and Shift is being held
   MOUSE_BUTT_KEY_STATE_MIDDLE_CTRL       = 24,       // The middle mouse button is clicked and Ctrl is being held
   MOUSE_BUTT_KEY_STATE_MIDDLE_CTRL_CHIFT = 28,       // The middle mouse button is clicked, Ctrl and Shift are being held
  };
//+------------------------------------------------------------------+
//| The list of possible mouse states relative to the form           |
//+------------------------------------------------------------------+
enum ENUM_MOUSE_FORM_STATE
  {
   MOUSE_FORM_STATE_NONE = 0,                         // Undefined state
//--- Outside the form
   MOUSE_FORM_STATE_OUTSIDE_FORM_NOT_PRESSED,         // The cursor is outside the form, the mouse buttons are not clicked
   MOUSE_FORM_STATE_OUTSIDE_FORM_PRESSED,             // The cursor is outside the form, any mouse button is clicked
   MOUSE_FORM_STATE_OUTSIDE_FORM_WHEEL,               // The cursor is outside the form, the mouse wheel is being scrolled
//--- Within the form
   MOUSE_FORM_STATE_INSIDE_FORM_NOT_PRESSED,          // The cursor is inside the form, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_FORM_PRESSED,              // The cursor is inside the form, any mouse button is clicked
   MOUSE_FORM_STATE_INSIDE_FORM_WHEEL,                // The cursor is inside the form, the mouse wheel is being scrolled
//--- Within the window header area
   MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_NOT_PRESSED,   // The cursor is inside the active area, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_PRESSED,       // The cursor is inside the active area,  any mouse button is clicked
   MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_WHEEL,         // The cursor is inside the active area, the mouse wheel is being scrolled
   MOUSE_FORM_STATE_INSIDE_ACTIVE_AREA_RELEASED,      // The cursor is inside the active area, left mouse button is released
   
//--- Within the window scrolling area to the right
   MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_RIGHT_NOT_PRESSED,// The cursor is within the window scrolling area to the right, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_RIGHT_PRESSED,    // The cursor is within the window scrolling area to the right, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_RIGHT_WHEEL,      // The cursor is within the window scrolling area to the right, the mouse wheel is being scrolled
//--- Within the window scrolling area at the bottom
   MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_BOTTOM_NOT_PRESSED,// The cursor is within the window scrolling area at the bottom, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_BOTTOM_PRESSED,   // The cursor is within the window scrolling area at the bottom, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_SCROLL_AREA_BOTTOM_WHEEL,     // The cursor is within the window scrolling area at the bottom, the mouse wheel is being scrolled

//--- Within the window resizing area at the top
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_AREA_NOT_PRESSED,  // The cursor is within the window resizing area at the top, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_AREA_PRESSED,      // The cursor is within the window resizing area at the top, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_AREA_WHEEL,        // The cursor is within the window resizing area at the top, the mouse wheel is being scrolled
//--- Within the window resizing area at the bottom
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the bottom, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_AREA_PRESSED,   // The cursor is within the window resizing area at the bottom, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_AREA_WHEEL,     // The cursor is within the window resizing area at the bottom, the mouse wheel is being scrolled
//--- Within the window resizing area to the left
   MOUSE_FORM_STATE_INSIDE_RESIZE_LEFT_AREA_NOT_PRESSED, // The cursor is within the window resizing area to the left, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_LEFT_AREA_PRESSED,     // The cursor is within the window resizing area to the left, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_LEFT_AREA_WHEEL,       // The cursor is within the window resizing area to the left, the mouse wheel is being scrolled
//--- Within the window resizing area to the right
   MOUSE_FORM_STATE_INSIDE_RESIZE_RIGHT_AREA_NOT_PRESSED,// The cursor is within the window resizing area to the right, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_RIGHT_AREA_PRESSED,    // The cursor is within the window resizing area to the right, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_RIGHT_AREA_WHEEL,      // The cursor is within the window resizing area to the right, the mouse wheel is being scrolled
//--- Within the window resizing area to the top-left
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_LEFT_AREA_NOT_PRESSED,   // The cursor is within the window resizing area at the top-left, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_LEFT_AREA_PRESSED,       // The cursor is within the window resizing area at the top-left, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_LEFT_AREA_WHEEL,         // The cursor is within the window resizing area at the top-left, the mouse wheel is being scrolled
//--- Within the window resizing area to the top-right
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_RIGHT_AREA_NOT_PRESSED,  // The cursor is within the window resizing area at the top-right, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_RIGHT_AREA_PRESSED,      // The cursor is within the window resizing area at the top-right, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_TOP_RIGHT_AREA_WHEEL,        // The cursor is within the window resizing area at the top-right, the mouse wheel is being scrolled
//--- Within the window resizing area at the bottom left
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_LEFT_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the bottom-left, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_LEFT_AREA_PRESSED,    // The cursor is within the window resizing area at the bottom-left, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_LEFT_AREA_WHEEL,      // The cursor is within the window resizing area at the bottom-left, the mouse wheel is being scrolled
//--- Within the window resizing area at the bottom-right
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_NOT_PRESSED,// The cursor is within the window resizing area at the bottom-right, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_PRESSED,   // The cursor is within the window resizing area at the bottom-right, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_RESIZE_BOTTOM_RIGHT_AREA_WHEEL,     // The cursor is within the window resizing area at the bottom-right, the mouse wheel is being scrolled
   
//--- Within the control area
   MOUSE_FORM_STATE_INSIDE_CONTROL_AREA_NOT_PRESSED,  // The cursor is within the control area, the mouse buttons are not clicked
   MOUSE_FORM_STATE_INSIDE_CONTROL_AREA_PRESSED,      // The cursor is within the control area, the mouse button (any) is clicked
   MOUSE_FORM_STATE_INSIDE_CONTROL_AREA_WHEEL,        // The cursor is within the control area, the mouse wheel is being scrolled
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

#endif // __MOUSE_DEFINES_MQH__