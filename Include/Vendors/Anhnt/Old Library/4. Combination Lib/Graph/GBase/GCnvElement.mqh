 //+--------------------------------------------------------------------+
 //|                                                    GCnvElement.mqh |
 //|                                    Copyright 2021, MetaQuotes Ltd. |
 //|Link                          https://www.mql5.com/en/articles/9493 |
 //|Link                          https://www.mql5.com/en/articles/9515 |
 //|Link                          https://www.mql5.com/en/articles/9553 |
 //|Link                          https://www.mql5.com/en/articles/9575 |
 //|Link                          https://www.mql5.com/en/articles/9612 |
 //|Link                          https://www.mql5.com/en/articles/9652 |
 //|Link                        https://www.mql5.com/en/articles/10733  |
 //|Link                        https://www.mql5.com/en/articles/10663  |
 //|Link                        https://www.mql5.com/en/articles/10733  |
 //|Link                        https://www.mql5.com/en/articles/10989  | 
 //|Link                        https://www.mql5.com/en/articles/11121  |
 //|Link                        https://www.mql5.com/en/articles/11173  |
 //|Link                        https://www.mql5.com/en/articles/11194  |
 //|Link                        https://www.mql5.com/en/articles/11260  |
 //|Link Naming                 https://www.mql5.com/en/articles/11288  |
 //|Scrolling tabs in TabControl htps://www.mql5.com/en/articles/11490  |
 //|Link TabcontrolUpdate       https://www.mql5.com/en/articles/11316  |
 //|Lib https://www.mql5.com/en/articles/14710                          |
 //+--------------------------------------------------------------------+
 #property copyright "Copyright 2021, MetaQuotes Ltd."
 #property link      "https://mql5.com/en/users/artmedia70"
 #property version   "1.00"
#ifndef __GCNVELEMENT_MQH__
#define __GCNVELEMENT_MQH__
 #property strict    // Necessary for mql4
  #include <Math\Alglib\alglib.mqh>
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
 #include "GBaseObj.mqh"
 #include "GraphINI.mqh"
 #include "..\..\Services\Pause.mqh"
 #include "..\..\Services\Colors.mqh"
 #ifndef CGCNVELEMENT_MQH_DECLARATION
 #define CGCNVELEMENT_MQH_DECLARATION
  //+------------------------------------------------------------------+
  //| Class of the graphical element object                            |
  //+------------------------------------------------------------------+
  class CGCnvElement : public CGBaseObj
   {
    private: //Private Properties
     //Ref https://www.mql5.com/en/articles/9515
      struct SData
         {
          //--- Object integer properties
            int            id;                                       // Element ID
            int            type;                                     // Graphical element type
            int            belong;                                   // Graphical element affiliation
            int            number;                                   // Element index in the list
            long           chart_id;                                 // Chart ID
            int            subwindow;                                // Chart subwindow index
            int            coord_x;                                  // Element X coordinate on the chart
            int            coord_y;                                  // Element Y coordinate on the chart
            int            width;                                    // Element width
            int            height;                                   // Element height
            int            edge_right;                               // Element right border
            int            edge_bottom;                              // Element bottom border
            int            act_shift_left;                           // Active area offset from the left edge of the element
            int            act_shift_top;                            // Active area offset from the top edge of the element
            int            act_shift_right;                          // Active area offset from the right edge of the element
            int            act_shift_bottom;                         // Active area offset from the bottom edge of the element
            bool           movable;                                  // Element moveability flag
            bool           active;                                   // Element activity flag
            bool           interaction;                              // Flag of interaction with the outside environment
            int            coord_act_x;                              // X coordinate of the element active area
            int            coord_act_y;                              // Y coordinate of the element active area
            int            coord_act_right;                          // Right border of the element active area
            int            coord_act_bottom;                         // Bottom border of the element active area
            long           zorder;                                   // Priority of a graphical object for receiving the event of clicking on a chart
            bool           enabled;                                  // Element availability flag
            bool           resizable;                                // Size changeability flag
            color          fore_color;                               // Default text color for all control objects
            uchar          fore_color_opacity;                       // Default text color opacity for all control objects
            color          background_color;                         // Control background color
            uchar          background_color_opacity;                 // Opacity of control background color
            color          background_color_mouse_down;              // Control background color when clicking on the control
            color          background_color_mouse_over;              // Control background color when hovering the mouse over the control
            int            bold_type;                                // Font width type
            int            border_style;                             // Control frame style
            int            border_size_top;                          // Control frame top size
            int            border_size_bottom;                       // Control frame bottom size
            int            border_size_left;                         // Control frame left size
            int            border_size_right;                        // Control frame right size
            color          border_color;                             // Control frame color
            color          border_color_mouse_down;                  // Control frame color when clicking on the control
            color          border_color_mouse_over;                  // Control frame color when hovering the mouse over the control
            bool           autosize;                                 // Flag of the element auto resizing depending on the content
            int            autosize_mode;                            // Mode of the element auto resizing depending on the content
            bool           autoscroll;                               // Auto scrollbar flag
            int            autoscroll_margin_w;                      // Width of the field inside the element during auto scrolling
            int            autoscroll_margin_h;                      // Height of the field inside the element during auto scrolling
            int            dock_mode;                                // Mode of binding control borders to the container
            int            margin_top;                               // Top margin between the fields of this and another control
            int            margin_bottom;                            // Bottom margin between the fields of this and another control
            int            margin_left;                              // Left margin between the fields of this and another control
            int            margin_right;                             // Right margin between the fields of this and another control
            int            padding_top;                              // Top margin inside the control
            int            padding_bottom;                           // Bottom margin inside the control
            int            padding_left;                             // Left margin inside the control
            int            padding_right;                            // Right margin inside the control
            int            text_align;                               // Text position within text label boundaries
            int            check_align;                              // Position of the checkbox within control borders
            bool           checked;                                  // Control checkbox status
            int            check_state;                              // Status of a control having a checkbox
            bool           autocheck;                                // Auto change flag status when it is selected
            color          check_background_color;                   // Color of control checkbox background
            color          check_background_color_opacity;           // Opacity of the control checkbox background color
            color          check_background_color_mouse_down;        // Color of control checkbox background when clicking on the control
            color          check_background_color_mouse_over;        // Color of control checkbox background when hovering the mouse over the control
            color          check_fore_color;                         // Color of control checkbox frame
            color          check_fore_color_opacity;                 // Opacity of the control checkbox frame color
            color          check_fore_color_mouse_down;              // Color of control checkbox background when clicking on the control
            color          check_fore_color_mouse_over;              // Color of control checkbox background when hovering the mouse over the control
            color          check_flag_color;                         // Color of control checkbox
            color          check_flag_color_opacity;                 // Opacity of the control checkbox color
            color          check_flag_color_mouse_down;              // Color of control checkbox when clicking on the control
            color          check_flag_color_mouse_over;              // Color of control checkbox when clicking on the control
            color          fore_color_mouse_down;                    // Default control text color when clicking on the control
            color          fore_color_mouse_over;                    // Default control text color when hovering the mouse over the control
            color          fore_color_toggle;                        // Text color of the control which is on
            color          fore_color_toggle_mouse_down;             // Default control text color when clicking on the control which is on
            color          fore_color_toggle_mouse_over;             // Default control text color when hovering the mouse over the control which is on
            color          background_color_toggle;                  // Background color of the control which is on
            color          background_color_toggle_mouse_down;       // Control background color when clicking on the control which is on
            color          background_color_toggle_mouse_over;       // Control background color when hovering the mouse over the control which is on
            bool           button_toggle;                            // Toggle flag of the control featuring a button
            bool           button_state;                             // Status of the Toggle control featuring a button
            bool           button_group_flag;                        // Button group flag
            bool           multicolumn;                              // Horizontal display of columns in the ListBox control
            int            column_width;                             // Width of each ListBox control column
            bool           tab_multiline;                            // Several lines of tabs in TabControl
            int            tab_alignment;                            // Location of tabs inside the control
            int            alignment;                                // Location of the object inside the control
            int            visible_area_x;                           // Visibility scope X coordinate
            int            visible_area_y;                           // Visibility scope Y coordinate
            int            visible_area_w;                           // Visibility scope width
            int            visible_area_h;                           // Visibility scope height
            bool           displayed;                                // Non-hidden control display flag
            int            display_state;                            // Control display state
            long           display_duration;                         // Control display duration
            int            split_container_fixed_panel;              // Panel that retains its size when the container is resized
            bool           split_container_splitter_fixed;           // Separator moveability flag
            int            split_container_splitter_distance;        // Distance from edge to separator
            int            split_container_splitter_width;           // Separator width
            int            split_container_splitter_orientation;     // Separator location
            bool           split_container_panel1_collapsed;         // Flag for collapsed panel 1
            int            split_container_panel1_min_size;          // Panel 1 minimum size
            bool           split_container_panel2_collapsed;         // Flag for collapsed panel 2
            int            split_container_panel2_min_size;          // Panel 2 minimum size
            int            control_area_x;                           // Control area X coordinate
            int            control_area_y;                           // Control area Y coordinate
            int            control_area_width;                       // Control area width
            int            control_area_height;                      // Control area height
            int            scroll_area_x_right;                      // Right scroll area X coordinate
            int            scroll_area_y_right;                      // Right scroll area Y coordinate
            int            scroll_area_width_right;                  // Right scroll area width
            int            scroll_area_height_right;                 // Right scroll area height
            int            scroll_area_x_bottom;                     // Bottom scroll area X coordinate
            int            scroll_area_y_bottom;                     // Bottom scroll area Y coordinate
            int            scroll_area_width_bottom;                 // Bottom scroll area width
            int            scroll_area_height_bottom;                // Bottom scroll area height
            int            border_left_area_width;                   // Left edge area width
            int            border_bottom_area_width;                 // Bottom edge area width
            int            border_right_area_width;                  // Right edge area width
            int            border_top_area_width;                    // Upper edge area width
            //---
            int            group;                                    // Group the graphical element belongs to
            int            tab_size_mode;                            // Tab size setting mode
            int            tab_page_number;                          // Tab index number
            int            tab_page_row;                             // Tab row index
            int            tab_page_column;                          // Tab column index
            int            progress_bar_minimum;                     // The lower bound of the range ProgressBar operates in
            int            progress_bar_maximum;                     // The upper bound of the range ProgressBar operates in
            int            progress_bar_step;                        // ProgressBar increment needed to redraw it
            int            progress_bar_style;                       // ProgressBar style
            int            progress_bar_value;                       // Current ProgressBar value from Min to Max
            int            progress_bar_marquee_speed;               // Progress bar animation speed in case of Marquee style
            uchar          button_arrow_size;                        // Size of the arrow drawn on the button
          //---
            ulong          tooltip_initial_delay;                    // Tooltip display delay
            ulong          tooltip_auto_pop_delay;                   // Tooltip display duration
            ulong          tooltip_reshow_delay;                     // One element new tooltip display delay
            bool           tooltip_show_always;                      // Display a tooltip in inactive window
            int            tooltip_icon;                             // Icon displayed in a tooltip
            bool           tooltip_is_balloon;                       // Tooltip in the form of a "cloud"
            bool           tooltip_use_fading;                       // Fade when showing/hiding a tooltip
          //--- Object real properties

          //--- Object string properties
            uchar          name_obj[64];                             // Graphical element object name
            uchar          name_res[64];                             // Graphical resource name
            uchar          text[256];                                // Graphical element text
            uchar          descript[256];                            // Graphical element description
            uchar          tooltip_title[256];                       // Element tooltip title
            uchar          tooltip_text[256];                        // Element tooltip text
         };
      SData                m_struct_obj;        // Object structure      
      uchar                m_uchar_array[];     // uchar array of the object structure
    //Ref https://www.mql5.com/en/articles/9493      
      long              m_long_prop[CANV_ELEMENT_PROP_INTEGER_TOTAL];   // Integer properties      
      double            m_double_prop[CANV_ELEMENT_PROP_DOUBLE_TOTAL];  // Real properties      
      string            m_string_prop[CANV_ELEMENT_PROP_STRING_TOTAL];  // String properties      

      ENUM_FRAME_ANCHOR m_text_anchor; // Current text alignment
      int               m_text_x;      // Text last X coordinate
      int               m_text_y;      // Text last Y coordinate
    //Private Methods
      //--- Return the index of the array the order's (1) double and (2) string properties are located at
         int               IndexProp(ENUM_CANV_ELEMENT_PROP_DOUBLE property)  const { return(int)property-CANV_ELEMENT_PROP_INTEGER_TOTAL;                                 }
         int               IndexProp(ENUM_CANV_ELEMENT_PROP_STRING property)  const { return(int)property-CANV_ELEMENT_PROP_INTEGER_TOTAL-CANV_ELEMENT_PROP_DOUBLE_TOTAL;  }
      //--- Save the colors to the background color array
         void              SaveColorsBG(color &colors[])                         { this.CopyArraysColors(this.m_array_colors_bg,colors,DFUN);      }
         void              SaveColorsBGMouseDown(color &colors[])                { this.CopyArraysColors(this.m_array_colors_bg_dwn,colors,DFUN);  }
         void              SaveColorsBGMouseOver(color &colors[])                { this.CopyArraysColors(this.m_array_colors_bg_ovr,colors,DFUN);  }
         void              SaveColorsBGInit(color &colors[])                     { this.CopyArraysColors(this.m_array_colors_bg_init,colors,DFUN); }      
    protected: 
      CGCnvElement     *m_element_main;                           // Pointer to the initial parent element within all the groups of bound objects
      CGCnvElement     *m_element_base;                           // Pointer to the parent element within related objects of the current group
     // https://www.mql5.com/en/articles/9493 
      CCanvas           m_canvas;                                 // CCanvas class object
      CPause            m_pause;                                  // Pause class object
      bool              m_shadow;                                 // Shadow presence
      color             m_chart_color_bg;                         // Chart background color
      uint              m_duplicate_res[];                        // Array for storing resource data copy
      color             m_array_colors_bg[];                      // Array of element background colors
      color             m_array_colors_bg_dwn[];                  // Array of control background colors when clicking on the control
      color             m_array_colors_bg_ovr[];                  // Array of control background colors when hovering the mouse over the control
      bool              m_gradient_v;                             // Vertical gradient filling flag
      bool              m_gradient_c;                             // Cyclic gradient filling flag
      int               m_init_relative_x;                        // Initial relative X coordinate
      int               m_init_relative_y;                        // Initial relative Y coordinate
      color             m_array_colors_bg_init[];                 // Array of element background colors (initial color)
      int               m_shift_coord_x;                          // Offset of the X coordinate relative to the base object
      int               m_shift_coord_y;                          // Offset of the Y coordinate relative to the base object      
    //Protected Methods      
       //--- Create (1) the object structure and (2) the object from the structure
         virtual bool      ObjectToStruct(void);
         virtual void      StructToObject(void);
       //--- Copy the color array to the specified background color array
         void              CopyArraysColors(color &array_dst[],const color &array_src[],const string source);
         
       //--- Return the number of graphical elements (1) by type, (2) by name and type
         int               GetNumGraphElements(const ENUM_GRAPH_ELEMENT_TYPE type) const;
         int               GetNumGraphElements(const string name,const ENUM_GRAPH_ELEMENT_TYPE type) const;
       //--- Create and return the graphical element name by its type
         string            CreateNameGraphElement(const ENUM_GRAPH_ELEMENT_TYPE type);
         
       //--- Gaussian blur
         bool              GaussianBlur(const uint radius);
       //--- Return the array of weight ratios
         bool              GetQuadratureWeights(const double mu0,const int n,double &weights[]); 
       //--- Initialize property values
         void              Initialize(const ENUM_GRAPH_ELEMENT_TYPE element_type,
                                    const int element_id,const int element_num,
                                    const int x,const int y,const int w,const int h,
                                    const string descript,const bool movable,const bool activity);
       //--- Protected constructor
                           CGCnvElement(const ENUM_GRAPH_ELEMENT_TYPE element_type,
                                       CGCnvElement *main_obj,CGCnvElement *base_obj,
                                       const long    chart_id,
                                       const int     wnd_num,
                                       const string  descript,
                                       const int     x,
                                       const int     y,
                                       const int     w,
                                       const int     h);                           
       
    public:
      //--- Set object's (1) integer, (2) real and (3) string properties
         void              SetProperty(ENUM_CANV_ELEMENT_PROP_INTEGER property,long value)   { this.m_long_prop[property]=value;                   }
         void              SetProperty(ENUM_CANV_ELEMENT_PROP_DOUBLE property,double value)  { this.m_double_prop[this.IndexProp(property)]=value; }
         void              SetProperty(ENUM_CANV_ELEMENT_PROP_STRING property,string value)  { this.m_string_prop[this.IndexProp(property)]=value; }
      //--- Return object’s (1) integer, (2) real and (3) string property from the properties array
         long              GetProperty(ENUM_CANV_ELEMENT_PROP_INTEGER property)        const { return this.m_long_prop[property];                  }
         double            GetProperty(ENUM_CANV_ELEMENT_PROP_DOUBLE property)         const { return this.m_double_prop[this.IndexProp(property)];}
         string            GetProperty(ENUM_CANV_ELEMENT_PROP_STRING property)         const { return this.m_string_prop[this.IndexProp(property)];}

      //--- Return the flag of the object supporting this property
         virtual bool      SupportProperty(ENUM_CANV_ELEMENT_PROP_INTEGER property)          { return true;    }
         virtual bool      SupportProperty(ENUM_CANV_ELEMENT_PROP_DOUBLE property)           { return false;   }
         virtual bool      SupportProperty(ENUM_CANV_ELEMENT_PROP_STRING property)           { return true;    }

      //--- Return itself
         CGCnvElement     *GetObject(void)                                                   { return &this;   }

      //--- Compare CGCnvElement objects with each other by all possible properties (for sorting the lists by a specified object property)
         virtual int       Compare(const CObject *node,const int mode=0) const;
      //--- Compare CGCnvElement objects with each other by all properties (to search equal objects)
         bool              IsEqual(CGCnvElement* compared_obj) const;

      //--- (1) Save the object to file and (2) upload the object from the file
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
      //--- (1) Save the graphical resource to the array and (2) restore the resource from the array
         bool              ResourceStamp(const string source);
         virtual bool      Reset(void);         
      //--- Return the cursor position relative to the (1) entire element, (2) visible part, (3) active area and (4) element control area
         bool              CursorInsideElement(const int x,const int y);
         bool              CursorInsideVisibleArea(const int x,const int y);
         bool              CursorInsideActiveArea(const int x,const int y);
         bool              CursorInsideControlArea(const int x,const int y);
      //--- Return the cursor position relative to the (1) right, (2) bottom element scroll area
         bool              CursorInsideScrollRightArea(const int x,const int y);
         bool              CursorInsideScrollBottomArea(const int x,const int y);
      //--- Return the cursor position relative to the (1) upper, (2) lower, (3) left and (4) right element resize area
         bool              CursorInsideResizeTopArea(const int x,const int y);
         bool              CursorInsideResizeBottomArea(const int x,const int y);
         bool              CursorInsideResizeLeftArea(const int x,const int y);
         bool              CursorInsideResizeRightArea(const int x,const int y);
      //--- Return the cursor position relative to the (1) top-left, (2) top-right,
      //--- (3) bottom-left, (4) bottom-right element resize area corner
         bool              CursorInsideResizeTopLeftArea(const int x,const int y);
         bool              CursorInsideResizeTopRightArea(const int x,const int y);
         bool              CursorInsideResizeBottomLeftArea(const int x,const int y);
         bool              CursorInsideResizeBottomRightArea(const int x,const int y);
      //--- Create the element
         virtual bool      Create(const long chart_id, 
                                 const int wnd_num,
                                 const int x,
                                 const int y,
                                 const int w,
                                 const int h,
                                 const bool redraw=false);
      //--- (1) Set and (2) return the initial shift of the (1) X and (2) Y coordinate relative to the base object
         void              SetCoordXRelativeInit(const int value)                            { this.m_init_relative_x=value;              }
         void              SetCoordYRelativeInit(const int value)                            { this.m_init_relative_y=value;              }
         int               CoordXRelativeInit(void)                                    const { return this.m_init_relative_x;             }
         int               CoordYRelativeInit(void)                                    const { return this.m_init_relative_y;             }
         
      //--- Return the pointer to the parent element within related objects of the current group
         CGCnvElement     *GetBase(void)                                                     { return this.m_element_base;                }
      //--- Return the pointer to the parent element within all groups of related objects
         CGCnvElement     *GetMain(void)     { return(this.m_element_main==NULL ? this.GetObject() : this.m_element_main);                }
      //--- Return the flag indicating that the object is (1) main, (2) base
         bool              IsMain(void)                                                      { return this.m_element_main==NULL;          }
         bool              IsDependent(void)                                                 { return this.m_element_base!=NULL;          }

      //--- Get the (1) main and (2) base object ID
         int               GetMainID(void);
         int               GetBaseID(void);
      //--- Return the pointer to a canvas object
         CCanvas          *GetCanvasObj(void)                                                { return &this.m_canvas;                     }
      //--- Set the canvas update frequency
         void              SetFrequency(const ulong value)                                   { this.m_pause.SetWaitingMSC(value);         }
      //--- Update the canvas
         void              CanvasUpdate(const bool redraw=false)                             { this.m_canvas.Update(redraw);              }
      //--- Return the size of the graphical resource copy array
         uint              DuplicateResArraySize(void)                                       { return ::ArraySize(this.m_duplicate_res);  }
      //--- Update the coordinates (shift the canvas)
         virtual bool      Move(const int x,const int y,const bool redraw=false);
      //--- Save an image to the array
         bool              ImageCopy(const string source,uint &array[]);
      //--- Change the lightness of (1) ARGB and (2) COLOR by a specified amount
         uint              ChangeColorLightness(const uint clr,const double change_value);
         color             ChangeColorLightness(const color colour,const double change_value);
      //--- Change the saturation of (1) ARGB and (2) COLOR by a specified amount
         uint              ChangeColorSaturation(const uint clr,const double change_value);
         color             ChangeColorSaturation(const color colour,const double change_value);
      //--- Changes the color component of RGB-Color
         color             ChangeRGBComponents(color clr,const uchar R,const uchar G,const uchar B);
      //--- (1) Set and (2) return the X coordinate shift relative to the base object
         void              SetCoordXRelative(const int value)                                { this.m_shift_coord_x=value;                }
         int               CoordXRelative(void)                                        const { return this.m_shift_coord_x;               }
      //--- (1) Set and (2) return the Y coordinate shift relative to the base object
         void              SetCoordYRelative(const int value)                                { this.m_shift_coord_y=value;                }
         int               CoordYRelative(void)                                        const { return this.m_shift_coord_y;               }
      //--- Set the pointer to the parent element within related objects of the current group
         void              SetBase(CGCnvElement *base)                                       { this.m_element_base=base;                  }
      //--- Event handler
         virtual void      OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam);
      //--- Parametric constructor
                     CGCnvElement(const ENUM_GRAPH_ELEMENT_TYPE element_type,
                                  CGCnvElement *main_obj,CGCnvElement *base_obj,
                                  const int     element_id,
                                  const int     element_num,
                                  const long    chart_id,
                                  const int     wnd_num,
                                  const string  descript,
                                  const int     x,
                                  const int     y,
                                  const int     w,
                                  const int     h,
                                  const color   colour,
                                  const uchar   opacity,
                                  const bool    movable=true,
                                  const bool    activity=true,
                                  const bool    redraw=false);
      //--- Default constructor
                     CGCnvElement();                     
      //--- Destructor
                    ~CGCnvElement()
                        { this.m_canvas.Destroy();             }
      //+------------------------------------------------------------------+
      //| Methods of simplified access to object properties                |
      //+------------------------------------------------------------------+
       //--- Set the (1) X, (2) Y coordinates, (3) element width, (4) height, (5) right (6) and bottom edge,
         virtual bool      SetCoordX(const int coord_x);
         virtual bool      SetCoordY(const int coord_y);
         virtual bool      SetWidth(const int width);
         virtual bool      SetHeight(const int height);
         void              SetRightEdge(void)                        { this.SetProperty(CANV_ELEMENT_PROP_RIGHT,this.RightEdge());           }
         void              SetBottomEdge(void)                       { this.SetProperty(CANV_ELEMENT_PROP_BOTTOM,this.BottomEdge());         }
       //--- Set the shift of the (1) left, (2) top, (3) right, (4) bottom edge of the active area relative to the element,
       //--- (5) all shifts of the active area edges relative to the element, (6) opacity
         void              SetActiveAreaLeftShift(const int value)   { this.SetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_LEFT,fabs(value));       }
         void              SetActiveAreaRightShift(const int value)  { this.SetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_RIGHT,fabs(value));      }
         void              SetActiveAreaTopShift(const int value)    { this.SetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_TOP,fabs(value));        }
         void              SetActiveAreaBottomShift(const int value) { this.SetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_BOTTOM,fabs(value));     }
         void              SetActiveAreaShift(const int left_shift,const int bottom_shift,const int right_shift,const int top_shift);
         virtual void      SetOpacity(const uchar value,const bool redraw=false);
       //--- (1) Set and (2) return the Tooltip text
         virtual void      SetTooltipText(const string text)         { this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_TEXT,text);                }
         virtual string    TooltipText(void)                         { return this.GetProperty(CANV_ELEMENT_PROP_TOOLTIP_TEXT);              }
       //--- (1) Set and (2) return the flag for displaying a non-hidden control
         virtual void      SetDisplayed(const bool flag)             { this.SetProperty(CANV_ELEMENT_PROP_DISPLAYED,flag);                   }
         bool              Displayed(void)                     const { return (bool)this.GetProperty(CANV_ELEMENT_PROP_DISPLAYED);           }
       //--- (1) Set and (2) return the control display status
         void              SetDisplayState(const ENUM_CANV_ELEMENT_DISPLAY_STATE state)
                           { this.SetProperty(CANV_ELEMENT_PROP_DISPLAY_STATE,state);                                                      }
         ENUM_CANV_ELEMENT_DISPLAY_STATE DisplayState(void)    const
                           { return (ENUM_CANV_ELEMENT_DISPLAY_STATE)this.GetProperty(CANV_ELEMENT_PROP_DISPLAY_STATE);                    }
       //--- (1) Set and (2) return the control display duration
         void              SetDisplayDuration(const long value)      { this.SetProperty(CANV_ELEMENT_PROP_DISPLAY_DURATION,value);           }
         long              DisplayDuration(void)               const { return this.GetProperty(CANV_ELEMENT_PROP_DISPLAY_DURATION);          }
       //--- (1) Set and (2) return the graphical element type
         void              SetTypeElement(const ENUM_GRAPH_ELEMENT_TYPE type);
         ENUM_GRAPH_ELEMENT_TYPE TypeGraphElement(void)  const { return (ENUM_GRAPH_ELEMENT_TYPE)this.GetProperty(CANV_ELEMENT_PROP_TYPE);   }
       //--- Set the main background color
         void              SetBackgroundColor(const color colour,const bool set_init_color);
         void              SetBackgroundColors(color &colors[],const bool set_init_colors);
       //--- Set the background color when clicking on the control
         void              SetBackgroundColorMouseDown(const color colour);
         void              SetBackgroundColorsMouseDown(color &colors[]);
       //--- Set the background color when hovering the mouse over control
         void              SetBackgroundColorMouseOver(const color colour);
         void              SetBackgroundColorsMouseOver(color &colors[]);
       //--- Set the initial main background color
         void              SetBackgroundColorInit(const color colour);
         void              SetBackgroundColorsInit(color &colors[])   { this.SaveColorsBGInit(colors); }
       //--- Set (1) object movability, (2) activity, (3) interaction,
       //--- (4) element ID, (5) element index in the list, the flag of (6) availability, (7) changeable size, (8) shadow
         void              SetMovable(const bool flag)               { this.SetProperty(CANV_ELEMENT_PROP_MOVABLE,flag);                     }
         void              SetActive(const bool flag)                { this.SetProperty(CANV_ELEMENT_PROP_ACTIVE,flag);                      }
         void              SetInteraction(const bool flag)           { this.SetProperty(CANV_ELEMENT_PROP_INTERACTION,flag);                 }
         void              SetID(const int id)                       { this.SetProperty(CANV_ELEMENT_PROP_ID,id);                            }
         void              SetNumber(const int number)               { this.SetProperty(CANV_ELEMENT_PROP_NUM,number);                       }
         void              SetEnabled(const bool flag)               { this.SetProperty(CANV_ELEMENT_PROP_ENABLED,flag);                     }
         void              SetResizable(const bool flag)             { this.SetProperty(CANV_ELEMENT_PROP_RESIZABLE,flag);                   }
         void              SetShadow(const bool flag)                { this.m_shadow=flag;                                                   }
       //--- Set the (1) X, (2) Y coordinates, (3) width and (4) height of the element control area
         void              SetControlAreaX(const int value)          { this.SetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_X,value);             }
         void              SetControlAreaY(const int value)          { this.SetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_Y,value);             }
         void              SetControlAreaWidth(const int value)      { this.SetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_WIDTH,value);         }
         void              SetControlAreaHeight(const int value)     { this.SetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_HEIGHT,value);        }
       //--- Return the shift (1) of the left, (2) right, (3) top and (4) bottom edge of the element active area
         int               ActiveAreaLeftShift(void)           const { return (int)this.GetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_LEFT);       }
         int               ActiveAreaRightShift(void)          const { return (int)this.GetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_RIGHT);      }
         int               ActiveAreaTopShift(void)            const { return (int)this.GetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_TOP);        }
         int               ActiveAreaBottomShift(void)         const { return (int)this.GetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_BOTTOM);     }
       //--- Return the coordinate (1) of the left, (2) right, (3) top and (4) bottom edge of the element active area
         int               ActiveAreaLeft(void)                const { return int(this.CoordX()+this.ActiveAreaLeftShift());                 }
         int               ActiveAreaRight(void)               const { return int(this.RightEdge()-this.ActiveAreaRightShift());             }
         int               ActiveAreaTop(void)                 const { return int(this.CoordY()+this.ActiveAreaTopShift());                  }
         int               ActiveAreaBottom(void)              const { return int(this.BottomEdge()-this.ActiveAreaBottomShift());           }
       //--- Return the shift of the (1) X, (2) Y coordinates, (3) width, (4) height of the element control area
         int               ControlAreaXShift(void)             const { return (int)this.GetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_X);       }
         int               ControlAreaYShift(void)             const { return (int)this.GetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_Y);       }
         int               ControlAreaWidth(void)              const { return (int)this.GetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_WIDTH);   }
         int               ControlAreaHeight(void)             const { return (int)this.GetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_HEIGHT);  }
       //--- Return the coordinate (1) of the left, (2) right, (3) top and (4) bottom edge of the element control area
         int               ControlAreaLeft(void)               const { return this.CoordX()+this.ControlAreaXShift();                        }
         int               ControlAreaRight(void)              const { return this.ControlAreaLeft()+this.ControlAreaWidth();                }
         int               ControlAreaTop(void)                const { return this.CoordY()+this.ControlAreaYShift();                        }
         int               ControlAreaBottom(void)             const { return this.ControlAreaTop()+this.ControlAreaHeight();                }
       //--- Return the relative coordinate (1) of the left, (2) right, (3) top and (4) bottom edge of the element control area
         int               ControlAreaLeftRelative(void)       const { return this.ControlAreaLeft()-this.CoordX();                          }
         int               ControlAreaRightRelative(void)      const { return this.ControlAreaRight()-this.CoordX();                         }
         int               ControlAreaTopRelative(void)        const { return this.ControlAreaTop()-this.CoordY();                           }
         int               ControlAreaBottomRelative(void)     const { return this.ControlAreaBottom()-this.CoordY();                        }
       //--- Return the shift of the (1) X, (2) Y coordinates, (3) width, (4) height of the element scroll area to the right
         int               ScrollAreaRightXShift(void)         const { return (int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_X_RIGHT);     }
         int               ScrollAreaRightYShift(void)         const { return (int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_Y_RIGHT);     }
         int               ScrollAreaRightWidth(void)          const { return (int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_WIDTH_RIGHT); }
         int               ScrollAreaRightHeight(void)         const { return (int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_HEIGHT_RIGHT);}
       //--- Return the coordinate (1) of the left, (2) right, (3) top and (4) bottom edge of the element scroll area to the right
         int               ScrollAreaRightLeft(void)           const { return this.CoordX()+this.ScrollAreaRightXShift();                       }
         int               ScrollAreaRightRight(void)          const { return this.ScrollAreaRightLeft()+this.ScrollAreaRightWidth();           }
         int               ScrollAreaRightTop(void)            const { return this.CoordY()+this.ScrollAreaRightYShift();                       }
         int               ScrollAreaRightBottom(void)         const { return this.ScrollAreaRightTop()+this.ScrollAreaRightHeight();           }
       //--- Return the relative coordinate (1) of the left, (2) right, (3) top and (4) bottom edge of the element scroll area to the right
         int               ScrollAreaRightLeftRelative(void)   const { return this.ScrollAreaRightLeft()-this.CoordX();                         }
         int               ScrollAreaRightRightRelative(void)  const { return this.ScrollAreaRightRight()-this.CoordX();                        }
         int               ScrollAreaRightTopRelative(void)    const { return this.ScrollAreaRightTop()-this.CoordY();                          }
         int               ScrollAreaRightBottomRelative(void) const { return this.ScrollAreaRightBottom()-this.CoordY();                       }
       //--- Return the shift of the (1) X, (2) Y coordinates, (3) width, (4) height of the element scroll area at the bottom
         int               ScrollAreaBottomXShift(void)        const { return (int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_X_BOTTOM);    }
         int               ScrollAreaBottomYShift(void)        const { return (int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_Y_BOTTOM);    }
         int               ScrollAreaBottomWidth(void)         const { return (int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_WIDTH_BOTTOM);}
         int               ScrollAreaBottomHeight(void)        const { return (int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_HEIGHT_BOTTOM);}
       //--- Return the coordinate (1) of the left, (2) right, (3) top and (4) bottom edge of the element control area
         int               ScrollAreaBottomLeft(void)          const { return this.CoordX()+this.ScrollAreaBottomXShift();                      }
         int               ScrollAreaBottomRight(void)         const { return this.ScrollAreaBottomLeft()+this.ScrollAreaBottomWidth();         }
         int               ScrollAreaBottomTop(void)           const { return this.CoordY()+this.ScrollAreaBottomYShift();                      }
         int               ScrollAreaBottomBottom(void)        const { return this.ScrollAreaBottomTop()+this.ScrollAreaBottomHeight();         }
       //--- Return the relative coordinate (1) of the left, (2) right, (3) top and (4) bottom edge of the element control area
         int               ScrollAreaBottomLeftRelative(void)  const { return this.ScrollAreaBottomLeft()-this.CoordX();                        }
         int               ScrollAreaBottomRightRelative(void) const { return this.ScrollAreaBottomRight()-this.CoordX();                       }
         int               ScrollAreaBottomTopRelative(void)   const { return this.ScrollAreaBottomTop()-this.CoordY();                         }
         int               ScrollAreaBottomBottomRelative(void)const { return this.ScrollAreaBottomBottom()-this.CoordY();                      }
       //--- Return the width of the (1) left, (2) right, (3) upper and (4) lower element edge area
         int               BorderResizeAreaLeft(void)          const { return (int)this.GetProperty(CANV_ELEMENT_PROP_BORDER_LEFT_AREA_WIDTH);     }
         int               BorderResizeAreaRight(void)         const { return (int)this.GetProperty(CANV_ELEMENT_PROP_BORDER_RIGHT_AREA_WIDTH);    }
         int               BorderResizeAreaTop(void)           const { return (int)this.GetProperty(CANV_ELEMENT_PROP_BORDER_TOP_AREA_WIDTH);      }
         int               BorderResizeAreaBottom(void)        const { return (int)this.GetProperty(CANV_ELEMENT_PROP_BORDER_BOTTOM_AREA_WIDTH);   }
       //--- Return the number of colors set for the gradient filling of the (1) main background, when clicking (2), (3) when hovering the mouse over the control
         uint              BackgroundColorsTotal(void)         const { return this.m_array_colors_bg.Size();                                 }
         uint              BackgroundColorsMouseDownTotal(void)const { return this.m_array_colors_bg_dwn.Size();                             }
         uint              BackgroundColorsMouseOverTotal(void)const { return this.m_array_colors_bg_ovr.Size();                             }
       //--- Return the main background color
         color             BackgroundColor(void)               const { return (color)this.GetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR);   }
         color             BackgroundColor(const uint index)   const;
       //--- Return the background color when clicking on the control
         color             BackgroundColorMouseDown(void)      const { return (color)this.GetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_DOWN); }
         color             BackgroundColorMouseDown(const uint index) const;
       //--- Return the background color when hovering the mouse over the control
         color             BackgroundColorMouseOver(void)      const { return (color)this.GetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_OVER); }
         color             BackgroundColorMouseOver(const uint index) const;
       //--- Return the initial color of the main background
         color             BackgroundColorInit(void)           const { return (color)this.m_array_colors_bg_init[0];    }
         color             BackgroundColorInit(const uint index)const;
       //--- Return (1) the opacity, coordinate (2) of the right and (3) bottom element edge
         uchar             Opacity(void)                       const { return (uchar)this.GetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_OPACITY); }
         int               RightEdge(void)                     const { return this.CoordX()+this.m_canvas.Width();                           }
         int               BottomEdge(void)                    const { return this.CoordY()+this.m_canvas.Height();                          }
       //--- Return the relative coordinate of the (1) right and (2) bottom element edge
         int               RightEdgeRelative(void)             const { return this.CoordXRelative()+this.m_canvas.Width();                   }
         int               BottomEdgeRelative(void)            const { return this.CoordYRelative()+this.m_canvas.Height();                  }
       //--- Return the (1) X, (2) Y coordinates, (3) element width and (4) height,
         int               CoordX(void)                        const { return (int)this.GetProperty(CANV_ELEMENT_PROP_COORD_X);              }
         int               CoordY(void)                        const { return (int)this.GetProperty(CANV_ELEMENT_PROP_COORD_Y);              }
         int               Width(void)                         const { return (int)this.GetProperty(CANV_ELEMENT_PROP_WIDTH);                }
         int               Height(void)                        const { return (int)this.GetProperty(CANV_ELEMENT_PROP_HEIGHT);               }
       //--- Return the (1) element movability, (2) activity, (3) interaction, (4) availability and (5) size changeability flag
         bool              Movable(void)                       const { return (bool)this.GetProperty(CANV_ELEMENT_PROP_MOVABLE);             }
         bool              Active(void)                        const { return (bool)this.GetProperty(CANV_ELEMENT_PROP_ACTIVE);              }
         bool              Interaction(void)                   const { return (bool)this.GetProperty(CANV_ELEMENT_PROP_INTERACTION);         }
         bool              Enabled(void)                       const { return (bool)this.GetProperty(CANV_ELEMENT_PROP_ENABLED);             }
         bool              Resizable(void)                     const { return (bool)this.GetProperty(CANV_ELEMENT_PROP_RESIZABLE);           }
       //--- Return (1) the object name, (2) the graphical resource name, (3) the chart ID and (4) the chart subwindow index
         string            NameObj(void)                       const { return this.GetProperty(CANV_ELEMENT_PROP_NAME_OBJ);                  }
         string            NameRes(void)                       const { return this.GetProperty(CANV_ELEMENT_PROP_NAME_RES);                  }
         long              ChartID(void)                       const { return this.GetProperty(CANV_ELEMENT_PROP_CHART_ID);                  }
         int               WindowNum(void)                     const { return (int)this.GetProperty(CANV_ELEMENT_PROP_WND_NUM);              }
       //--- Return (1) the element ID, (2) element index in the list, (3) flag of the shadow presence and (4) the chart background color
         int               ID(void)                            const { return (int)this.GetProperty(CANV_ELEMENT_PROP_ID);                   }
         int               Number(void)                        const { return (int)this.GetProperty(CANV_ELEMENT_PROP_NUM);                  }
         bool              IsShadow(void)                      const { return this.m_shadow;                                                 }
         color             ChartBackgroundColor(void)          const { return this.m_chart_color_bg;                                         }
       //--- Set the object above all
         virtual void      BringToTop(void)                          { CGBaseObj::SetVisibleFlag(false,false); CGBaseObj::SetVisibleFlag(true,false);}
       //--- (1) Show and (2) hide the element
         virtual void      Show(void)                                { CGBaseObj::SetVisibleFlag(true,false);                                }
         virtual void      Hide(void)                                { CGBaseObj::SetVisibleFlag(false,false);                               }
       //--- Priority of a graphical object for receiving the event of clicking on a chart
         virtual long      Zorder(void)                        const { return this.GetProperty(CANV_ELEMENT_PROP_ZORDER);                    }
         virtual bool      SetZorder(const long value,const bool only_prop);
       //--- Graphical object group
         virtual int       Group(void)                         const { return (int)this.GetProperty(CANV_ELEMENT_PROP_GROUP);                }
         virtual void      SetGroup(const int value);
       //--- Visibility scope X coordinate
         virtual int       XOffset(void)                       const { return (int)this.GetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_X);       }
         virtual bool      SetXOffset(const int value,const bool only_prop);
       //--- Visibility scope Y coordinate
         virtual int       YOffset(void)                       const { return (int)this.GetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_Y);       }
         virtual bool      SetYOffset(const int value,const bool only_prop);
       //--- Visibility scope width
         virtual int       XSize(void)                         const { return (int)this.GetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_WIDTH);   }
         virtual bool      SetXSize(const int value,const bool only_prop);
       //--- Visibility scope height
         virtual int       YSize(void)                         const { return (int)this.GetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_HEIGHT);  }
         virtual bool      SetYSize(const int value,const bool only_prop);
       //--- Visibility scope X coordinate
         virtual int       VisibleAreaX(void)                  const { return this.XOffset();                                                }
         virtual bool      SetVisibleAreaX(const int value,const bool only_prop);
       //--- Visibility scope Y coordinate
         virtual int       VisibleAreaY(void)                  const { return this.YOffset();                                                }
         virtual bool      SetVisibleAreaY(const int value,const bool only_prop);
       //--- Visibility scope width
         virtual int       VisibleAreaWidth(void)              const { return this.XSize();                                                  }
         virtual bool      SetVisibleAreaWidth(const int value,const bool only_prop);
       //--- Visibility scope height
         virtual int       VisibleAreaHeight(void)             const { return this.YSize();                                                  }
         virtual bool      SetVisibleAreaHeight(const int value,const bool only_prop);
       //--- Set relative coordinates and size of the visible area
         void              SetVisibleArea(const int x,const int y,const int w,const int h,const bool only_prop);
       //--- Sets the size of the visible area equal to the entire object
         void              ResetVisibleArea(void)                    { this.SetVisibleArea(0,0,this.Width(),this.Height(),false);            }
       //--- Return the (1) X coordinate, (2) right border, (3) Y coordinate, (4) bottom border of the visible area
         int               CoordXVisibleArea(void)             const { return this.CoordX()+this.VisibleAreaX();                             }
         int               RightEdgeVisibleArea(void)          const { return this.CoordXVisibleArea()+this.VisibleAreaWidth();              }
         int               RightEdgeVisibleAreaRelative(void)  const { return this.VisibleAreaX()+this.VisibleAreaWidth();                   }
         int               CoordYVisibleArea(void)             const { return this.CoordY()+this.VisibleAreaY();                             }
         int               BottomEdgeVisibleArea(void)         const { return this.CoordYVisibleArea()+this.VisibleAreaHeight();             }
         int               BottomEdgeVisibleAreaRelative(void) const { return this.VisibleAreaY()+this.VisibleAreaHeight();                  }
       //--- Graphical element description
         string            Description(void)                   const { return this.GetProperty(CANV_ELEMENT_PROP_DESCRIPTION);               }
         void              SetDescription(const string descr)        { this.SetProperty(CANV_ELEMENT_PROP_DESCRIPTION,descr);                }
      //+------------------------------------------------------------------+
      //| The methods of receiving raster data                             |
      //+------------------------------------------------------------------+
       //--- Get a color of the dot with the specified coordinates
         uint              GetPixel(const int x,const int y)   const { return this.m_canvas.PixelGet(x,y);                                   }
      //+------------------------------------------------------------------+
      //| The methods of filling, clearing and updating raster data        |
      //+------------------------------------------------------------------+
       //--- Clear the element filling it with color and opacity
         virtual void      Erase(const color colour,const uchar opacity,const bool redraw=false);
       //--- Clear the element with a gradient fill
         virtual void      Erase(color &colors[],const uchar opacity,const bool vgradient,const bool cycle,const bool redraw=false);
       //--- Clear the element completely
         virtual void      Erase(const bool redraw=false);
       protected:
       //--- Clear the element filling it with color and opacity without cropping and updating
         virtual void      EraseNoCrop(const color colour,const uchar opacity,const bool redraw=false);
       //--- Clears the element with a gradient fill without cropping and updating
         virtual void      EraseNoCrop(color &colors[],const uchar opacity,const bool vgradient,const bool cycle,const bool redraw=false);
       public:
       //--- Crops the image outlined by (1) the specified and (2) previously set rectangular visibility scope
         void              Crop(const uint coord_x,const uint coord_y,const uint width,const uint height);  
         virtual void      Crop(void);
       //--- Update the element
         void              Update(const bool redraw=false)           { this.m_canvas.Update(redraw); }
      //+------------------------------------------------------------------+
      //| The methods of drawing primitives without smoothing              |
      //+------------------------------------------------------------------+
       //--- Set the color of the dot with the specified coordinates
         void              SetPixel(const int x,const int y,const color clr,const uchar opacity=255)
                           { this.m_canvas.PixelSet(x,y,::ColorToARGB(clr,opacity));                }                       
       //--- Draw a segment of a vertical line
         void              DrawLineVertical(const int x,                // X coordinate of the segment
                                          const int y1,               // Y coordinate of the segment first point
                                          const int y2,               // Y coordinate of the segment second point
                                          const color clr,            // Color
                                          const uchar opacity=255)    // Opacity
                           { this.m_canvas.LineVertical(x,y1,y2,::ColorToARGB(clr,opacity));        }                           
       //--- Draw a segment of a horizontal line
         void              DrawLineHorizontal(const int x1,             // X coordinate of the segment's first point
                                             const int x2,             // X coordinate of the segment second point
                                             const int y,              // Segment Y coordinate
                                             const color clr,          // Color
                                             const uchar opacity=255)  // Opacity
                           { this.m_canvas.LineHorizontal(x1,x2,y,::ColorToARGB(clr,opacity));      }                           
       //--- Draw a segment of a freehand line
         void              DrawLine(const int x1,                       // X coordinate of the segment's first point
                                    const int y1,                       // Y coordinate of the segment first point
                                    const int x2,                       // X coordinate of the segment second point
                                    const int y2,                       // Y coordinate of the segment second point
                                    const color clr,                    // Color
                                    const uchar opacity=255)            // Opacity
                           { this.m_canvas.Line(x1,y1,x2,y2,::ColorToARGB(clr,opacity));}
                           
       //--- Draw a polyline
         void              DrawPolyline(int &array_x[],                 // Array with the X coordinates of polyline points
                                       int & array_y[],                // Array with the Y coordinates of polyline points
                                       const color clr,                // Color
                                       const uchar opacity=255)        // Opacity
                           { this.m_canvas.Polyline(array_x,array_y,::ColorToARGB(clr,opacity));}                           
       //--- Draw a polygon
         void              DrawPolygon(int &array_x[],                  // Array with the X coordinates of polygon points
                                       int &array_y[],                  // Array with the Y coordinates of polygon points
                                       const color clr,                 // Color
                                       const uchar opacity=255)         // Opacity
                           { this.m_canvas.Polygon(array_x,array_y,::ColorToARGB(clr,opacity));                                            }
                           
       //--- Draw a rectangle using two points
         void              DrawRectangle(const int x1,                  // X coordinate of the first point defining the rectangle
                                       const int y1,                  // Y coordinate of the first point defining the rectangle
                                       const int x2,                  // X coordinate of the second point defining the rectangle
                                       const int y2,                  // Y coordinate of the second point defining the rectangle
                                       const color clr,               // color
                                       const uchar opacity=255)       // Opacity
                           { this.m_canvas.Rectangle(x1,y1,x2,y2,::ColorToARGB(clr,opacity));                                              }
                           
       //--- Draw a circle
         void              DrawCircle(const int x,                      // X coordinate of the circle center
                                    const int y,                      // Y coordinate of the circle center
                                    const int r,                      // Circle radius
                                    const color clr,                  // Color
                                    const uchar opacity=255)          // Opacity
                           { this.m_canvas.Circle(x,y,r,::ColorToARGB(clr,opacity));                                                       }
                           
       //--- Draw a triangle
         void              DrawTriangle(const int x1,                   // X coordinate of the triangle first vertex
                                       const int y1,                   // Y coordinate of the triangle first vertex
                                       const int x2,                   // X coordinate of the triangle second vertex
                                       const int y2,                   // Y coordinate of the triangle second vertex
                                       const int x3,                   // X coordinate of the triangle third vertex
                                       const int y3,                   // Y coordinate of the triangle third vertex
                                       const color clr,                // Color
                                       const uchar opacity=255)        // Opacity
                           { m_canvas.Triangle(x1,y1,x2,y2,x3,y3,::ColorToARGB(clr,opacity));                                              }
                           
       //--- Draw an ellipse using two points
         void              DrawEllipse(const int x1,                    // X coordinate of the first point defining the ellipse
                                       const int y1,                    // Y coordinate of the first point defining the ellipse
                                       const int x2,                    // X coordinate of the second point defining the ellipse
                                       const int y2,                    // Y coordinate of the second point defining the ellipse
                                       const color clr,                 // Color
                                       const uchar opacity=255)         // Opacity
                           { this.m_canvas.Ellipse(x1,y1,x2,y2,::ColorToARGB(clr,opacity)); }

       //--- Draw an arc of an ellipse inscribed in a rectangle with corners at (x1,y1) and (x2,y2).
       //--- The arc boundaries are clipped by lines from the center of the ellipse, which extend to two points with coordinates (x3,y3) and (x4,y4)
         void              DrawArc(const int x1,                        // X coordinate of the top left corner forming the rectangle
                                 const int y1,                        // Y coordinate of the top left corner forming the rectangle
                                 const int x2,                        // X coordinate of the bottom right corner forming the rectangle
                                 const int y2,                        // Y coordinate of the bottom right corner forming the rectangle
                                 const int x3,                        // X coordinate of the first point, to which a line from the rectangle center is drawn in order to obtain the arc boundary
                                 const int y3,                        // Y coordinate of the first point, to which a line from the rectangle center is drawn in order to obtain the arc boundary
                                 const int x4,                        // X coordinate of the second point, to which a line from the rectangle center is drawn in order to obtain the arc boundary
                                 const int y4,                        // Y coordinate of the second point, to which a line from the rectangle center is drawn in order to obtain the arc boundary
                                 const color clr,                     // Color
                                 const uchar opacity=255)             // Opacity
                           { m_canvas.Arc(x1,y1,x2,y2,x3,y3,x4,y4,::ColorToARGB(clr,opacity));                                             }
                           
       //--- Draw a filled sector of an ellipse inscribed in a rectangle with corners at (x1,y1) and (x2,y2).
       //--- The sector boundaries are clipped by lines from the center of the ellipse, which extend to two points with coordinates (x3,y3) and (x4,y4)
         void              DrawPie(const int x1,                        // X coordinate of the upper left corner of the rectangle
                                 const int y1,                        // Y coordinate of the upper left corner of the rectangle
                                 const int x2,                        // X coordinate of the bottom right corner of the rectangle
                                 const int y2,                        // Y coordinate of the bottom right corner of the rectangle
                                 const int x3,                        // X coordinate of the first point to find the arc boundaries
                                 const int y3,                        // Y coordinate of the first point to find the arc boundaries
                                 const int x4,                        // X coordinate of the second point to find the arc boundaries
                                 const int y4,                        // Y coordinate of the second point to find the arc boundaries
                                 const color clr,                     // Line color
                                 const color fill_clr,                // Fill color
                                 const uchar opacity=255)             // Opacity
                           { this.m_canvas.Pie(x1,y1,x2,y2,x3,y3,x4,y4,::ColorToARGB(clr,opacity),ColorToARGB(fill_clr,opacity));          }
                                 
      //+------------------------------------------------------------------+
      //| The methods of drawing filled primitives without smoothing       |
      //+------------------------------------------------------------------+
        //--- Fill in the area
         void              Fill(const int x,                            // X coordinate of the filling start point
                              const int y,                            // Y coordinate of the filling start point
                              const color clr,                        // Color
                              const uchar opacity=255,                // Opacity
                              const uint threshould=0)                // Threshold
                           { this.m_canvas.Fill(x,y,::ColorToARGB(clr,opacity),threshould);                                                }
                           
        //--- Draw a filled rectangle
         void              DrawRectangleFill(const int x1,              // X coordinate of the first point defining the rectangle
                                             const int y1,              // Y coordinate of the first point defining the rectangle
                                             const int x2,              // X coordinate of the second point defining the rectangle
                                             const int y2,              // Y coordinate of the second point defining the rectangle
                                             const color clr,           // Color
                                             const uchar opacity=255)   // Opacity
                           { this.m_canvas.FillRectangle(x1,y1,x2,y2,::ColorToARGB(clr,opacity));                                          }

        //--- Draw a filled circle
         void              DrawCircleFill(const int x,                  // X coordinate of the circle center
                                          const int y,                  // Y coordinate of the circle center
                                          const int r,                  // Circle radius
                                          const color clr,              // Color
                                          const uchar opacity=255)      // Opacity
                           { this.m_canvas.FillCircle(x,y,r,::ColorToARGB(clr,opacity));                                                   }
                           
        //--- Draw a filled triangle
         void              DrawTriangleFill(const int         x1,      // X coordinate of the triangle first vertex
                                          const int         y1,      // Y coordinate of the triangle first vertex
                                          const int         x2,      // X coordinate of the triangle second vertex
                                          const int         y2,      // Y coordinate of the triangle second vertex
                                          const int         x3,      // X coordinate of the triangle third vertex
                                          const int         y3,      // Y coordinate of the triangle third vertex
                                          const color clr,           // Color
                                          const uchar opacity=255)   // Opacity
                           { this.m_canvas.FillTriangle(x1,y1,x2,y2,x3,y3,::ColorToARGB(clr,opacity));                                     }
                           
        //--- Draw a filled polygon
         void              DrawPolygonFill(int &array_x[],              // Array with the X coordinates of polygon points
                                          int &array_y[],              // Array with the Y coordinates of polygon points
                                          const color clr,             // Color
                                          const uchar opacity=255)     // Opacity
                           { this.m_canvas.FillPolygon(array_x,array_y,::ColorToARGB(clr,opacity));                                        }
                           
        //--- Draw a filled ellipse inscribed in a rectangle with the specified coordinates
         void              DrawEllipseFill(const int x1,                // X coordinate of the top left corner forming the rectangle
                                          const int y1,                // Y coordinate of the top left corner forming the rectangle
                                          const int x2,                // X coordinate of the bottom right corner forming the rectangle
                                          const int y2,                // Y coordinate of the bottom right corner forming the rectangle
                                          const color clr,             // Color
                                          const uchar opacity=255)     // Opacity
                           { this.m_canvas.FillEllipse(x1,y1,x2,y2,::ColorToARGB(clr,opacity));                                            }
                           
      //+------------------------------------------------------------------+
      //| The methods of drawing primitives using smoothing                |
      //+------------------------------------------------------------------+
       //--- Draw a point using AntiAliasing algorithm
         void              SetPixelAA(const double x,                   // Pixel X coordinate
                                    const double y,                   // Pixel Y coordinate
                                    const color clr,                  // Color
                                    const uchar opacity=255)          // Opacity
                           { this.m_canvas.PixelSetAA(x,y,::ColorToARGB(clr,opacity));                                                     }
                           
       //--- Draw a segment of a freehand line using AntiAliasing algorithm
         void              DrawLineAA(const int   x1,                   // X coordinate of the segment first point
                                    const int   y1,                   // Y coordinate of the segment first point
                                    const int   x2,                   // X coordinate of the segment second point
                                    const int   y2,                   // Y coordinate of the segment second point
                                    const color clr,                  // Color
                                    const uchar opacity=255,          // Opacity
                                    const uint  style=UINT_MAX)       // Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                           { this.m_canvas.LineAA(x1,y1,x2,y2,::ColorToARGB(clr,opacity),style);                                           }
                           
       //--- Draw a segment of a freehand line using Wu algorithm
         void              DrawLineWu(const int   x1,                   // X coordinate of the segment's first point
                                    const int   y1,                   // Y coordinate of the segment first point
                                    const int   x2,                   // X coordinate of the segment second point
                                    const int   y2,                   // Y coordinate of the segment second point
                                    const color clr,                  // Color
                                    const uchar opacity=255,          // Opacity
                                    const uint  style=UINT_MAX)       // Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                           { this.m_canvas.LineWu(x1,y1,x2,y2,::ColorToARGB(clr,opacity),style);                                           }
                           
        //--- Draws a segment of a freehand line having a specified width using smoothing algorithm with the preliminary filtration
         void              DrawLineThick(const int   x1,                // X coordinate of the segment first point
                                       const int   y1,                // Y coordinate of the segment first point
                                       const int   x2,                // X coordinate of the segment second point
                                       const int   y2,                // Y coordinate of the segment second point
                                       const int   size,              // Line width
                                       const color clr,               // Color
                                       const uchar opacity=255,       // Opacity
                                       const uint  style=STYLE_SOLID, // Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                                       ENUM_LINE_END end_style=LINE_END_ROUND) // Line style is one of the ENUM_LINE_END enumeration's values
                           { this.m_canvas.LineThick(x1,y1,x2,y2,::ColorToARGB(clr,opacity),size,style,end_style);                         }
      
       //--- Draw a vertical segment of a freehand line having a specified width using smoothing algorithm with the preliminary filtration
         void              DrawLineThickVertical(const int   x,         // X coordinate of the segment
                                                const int   y1,        // Y coordinate of the segment first point
                                                const int   y2,        // Y coordinate of the segment second point
                                                const int   size,      // Line width
                                                const color clr,       // Color
                                                const uchar opacity=255,// Opacity
                                                const uint  style=STYLE_SOLID,  // Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                                                const ENUM_LINE_END end_style=LINE_END_ROUND)  // Line style is one of the ENUM_LINE_END enumeration's values
                           { this.m_canvas.LineThickVertical(x,y1,y2,::ColorToARGB(clr,opacity),size,style,end_style);                     }
                           
       //--- Draw a horizontal segment of a freehand line having a specified width using smoothing algorithm with the preliminary filtration
         void              DrawLineThickHorizontal(const int   x1,      // X coordinate of the segment first point
                                                   const int   x2,      // X coordinate of the segment second point
                                                   const int   y,       // Segment Y coordinate
                                                   const int   size,    // Line width
                                                   const color clr,     // Color
                                                   const uchar opacity=255,// Opacity
                                                   const uint  style=STYLE_SOLID,  // Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                                                   const ENUM_LINE_END end_style=LINE_END_ROUND)  // Line style is one of the ENUM_LINE_END enumeration's values
                           { this.m_canvas.LineThickHorizontal(x1,x2,y,::ColorToARGB(clr,opacity),size,style,end_style);                   }

       //--- Draws a polyline using AntiAliasing algorithm
         void              DrawPolylineAA(int        &array_x[],        // Array with the X coordinates of polyline points
                                          int        &array_y[],        // Array with the Y coordinates of polyline points
                                          const color clr,              // Color
                                          const uchar opacity=255,      // Opacity
                                          const uint  style=UINT_MAX)   // Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                           { this.m_canvas.PolylineAA(array_x,array_y,::ColorToARGB(clr,opacity),style);                                   }
                           
       //--- Draws a polyline using Wu algorithm
         void              DrawPolylineWu(int        &array_x[],        // Array with the X coordinates of polyline points
                                          int        &array_y[],        // Array with the Y coordinates of polyline points
                                          const color clr,              // Color
                                          const uchar opacity=255,      // Opacity
                                          const uint  style=UINT_MAX)   // Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                           { this.m_canvas.PolylineWu(array_x,array_y,::ColorToARGB(clr,opacity),style);                                   }
                           
       //--- Draw a polyline with a specified width consecutively using two antialiasing algorithms.
       //--- First, individual line segments are smoothed based on Bezier curves.
       //--- Then, the raster antialiasing algorithm is applied to the polyline built from these segments to improve the rendering quality
         void              DrawPolylineSmooth(const int   &array_x[],   // Array with the X coordinates of polyline points
                                             const int   &array_y[],   // Array with the Y coordinates of polyline points
                                             const int    size,        // Line width
                                             const color  clr,         // Color
                                             const uchar  opacity=255, // Opacity
                                             const double tension=0.5, // Smoothing parameter value
                                             const double step=10,     // Approximation step
                                             const ENUM_LINE_STYLE style=STYLE_SOLID,// Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                                             const ENUM_LINE_END   end_style=LINE_END_ROUND)// Line style is one of the ENUM_LINE_END enumeration values
                           { this.m_canvas.PolylineSmooth(array_x,array_y,::ColorToARGB(clr,opacity),size,style,end_style,tension,step);   }
                           
       //--- Draw a polyline having a specified width using smoothing algorithm with the preliminary filtration
         void              DrawPolylineThick(const int     &array_x[],  // Array with the X coordinates of polyline points
                                             const int     &array_y[],  // Array with the Y coordinates of polyline points
                                             const int      size,       // Line width
                                             const color    clr,        // Color
                                             const uchar    opacity=255,// Opacity
                                             const uint     style=STYLE_SOLID,         // Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                                             ENUM_LINE_END  end_style=LINE_END_ROUND)  // Line style is one of the ENUM_LINE_END enumeration values
                           { this.m_canvas.PolylineThick(array_x,array_y,::ColorToARGB(clr,opacity),size,style,end_style);                 }
                           
       //--- Draw a polygon using AntiAliasing algorithm
         void              DrawPolygonAA(int        &array_x[],         // Array with the X coordinates of polygon points
                                       int        &array_y[],         // Array with the Y coordinates of polygon points
                                       const color clr,               // Color
                                       const uchar opacity=255,       // Opacity
                                       const uint  style=UINT_MAX)    // Line style is one of the ENUM_LINE_STYLE enumeration values or a custom value
                           { this.m_canvas.PolygonAA(array_x,array_y,::ColorToARGB(clr,opacity),style);                                    }
                           
       //--- Draw a polygon using Wu algorithm
         void              DrawPolygonWu(int        &array_x[],         // Array with the X coordinates of polygon points
                                       int        &array_y[],         // Array with the Y coordinates of polygon points
                                       const color clr,               // Color
                                       const uchar opacity=255,       // Opacity
                                       const uint  style=UINT_MAX)    // Line style is one of the ENUM_LINE_STYLE enumeration values or a custom value
                           { this.m_canvas.PolygonWu(array_x,array_y,::ColorToARGB(clr,opacity),style);                                    }
                           
       //--- Draw a polygon with a specified width consecutively using two smoothing algorithms.
       //--- First, individual segments are smoothed based on Bezier curves.
       //--- Then, the raster smoothing algorithm is applied to the polygon built from these segments to improve the rendering quality. 
         void              DrawPolygonSmooth(int         &array_x[],    // Array with the X coordinates of polyline points
                                             int         &array_y[],    // Array with the Y coordinates of polyline points
                                             const int    size,         // Line width
                                             const color  clr,          // Color
                                             const uchar  opacity=255,  // Opacity
                                             const double tension=0.5,  // Smoothing parameter value
                                             const double step=10,      // Approximation step
                                             const ENUM_LINE_STYLE style=STYLE_SOLID,// Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                                             const ENUM_LINE_END   end_style=LINE_END_ROUND)// Line style is one of the ENUM_LINE_END enumeration values
                           { this.m_canvas.PolygonSmooth(array_x,array_y,::ColorToARGB(clr,opacity),size,style,end_style,tension,step);    }
                           
       //--- Draw a polygon having a specified width using smoothing algorithm with the preliminary filtration
         void              DrawPolygonThick(const int  &array_x[],      // array with the X coordinates of polygon points
                                          const int  &array_y[],      // array with the Y coordinates of polygon points
                                          const int   size,           // Line width
                                          const color clr,            // Color
                                          const uchar opacity=255,    // Opacity
                                          const uint  style=STYLE_SOLID,// line style
                                          ENUM_LINE_END end_style=LINE_END_ROUND) // line ends style
                           { this.m_canvas.PolygonThick(array_x,array_y,::ColorToARGB(clr,opacity),size,style,end_style);                  }
                           
       //--- Draw a triangle using AntiAliasing algorithm
         void              DrawTriangleAA(const int   x1,               // X coordinate of the triangle first vertex
                                          const int   y1,               // Y coordinate of the triangle first vertex
                                          const int   x2,               // X coordinate of the triangle second vertex
                                          const int   y2,               // Y coordinate of the triangle second vertex
                                          const int   x3,               // X coordinate of the triangle third vertex
                                          const int   y3,               // Y coordinate of the triangle third vertex
                                          const color clr,              // Color
                                          const uchar opacity=255,      // Opacity
                                          const uint  style=UINT_MAX)   // Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                           { this.m_canvas.TriangleAA(x1,y1,x2,y2,x3,y3,::ColorToARGB(clr,opacity),style);                                 }
                           
       //--- Draw a triangle using Wu algorithm
         void              DrawTriangleWu(const int   x1,               // X coordinate of the triangle first vertex
                                          const int   y1,               // Y coordinate of the triangle first vertex
                                          const int   x2,               // X coordinate of the triangle second vertex
                                          const int   y2,               // Y coordinate of the triangle second vertex
                                          const int   x3,               // X coordinate of the triangle third vertex
                                          const int   y3,               // Y coordinate of the triangle third vertex
                                          const color clr,              // Color
                                          const uchar opacity=255,      // Opacity
                                          const uint  style=UINT_MAX)   // Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                           { this.m_canvas.TriangleWu(x1,y1,x2,y2,x3,y3,::ColorToARGB(clr,opacity),style);                                 }
                           
       //--- Draw a circle using AntiAliasing algorithm
         void              DrawCircleAA(const int    x,                 // X coordinate of the circle center
                                       const int    y,                 // Y coordinate of the circle center
                                       const double r,                 // Circle radius
                                       const color  clr,               // Color
                                       const uchar opacity=255,        // Opacity
                                       const uint  style=UINT_MAX)     // Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                           { this.m_canvas.CircleAA(x,y,r,::ColorToARGB(clr,opacity),style);                                               }
                           
       //--- Draw a circle using Wu algorithm
         void              DrawCircleWu(const int    x,                 // X coordinate of the circle center
                                       const int    y,                 // Y coordinate of the circle center
                                       const double r,                 // Circle radius
                                       const color  clr,               // Color
                                       const uchar opacity=255,        // Opacity
                                       const uint  style=UINT_MAX)     // Line style is one of the ENUM_LINE_STYLE enumeration's values or a custom value
                           { this.m_canvas.CircleWu(x,y,r,::ColorToARGB(clr,opacity),style);                                               }
                           
       //--- Draw an ellipse by two points using AntiAliasing algorithm
         void              DrawEllipseAA(const double x1,               // X coordinate of the first point defining the ellipse
                                       const double y1,               // Y coordinate of the first point defining the ellipse
                                       const double x2,               // X coordinate of the second point defining the ellipse
                                       const double y2,               // Y coordinate of the second point defining the ellipse
                                       const color  clr,              // Color
                                       const uchar opacity=255,       // Opacity
                                       const uint  style=UINT_MAX)    // Line style is one of the ENUM_LINE_STYLE enumeration values or a custom value
                           { this.m_canvas.EllipseAA(x1,y1,x2,y2,::ColorToARGB(clr,opacity),style);                                        }
                           
       //--- Draw an ellipse by two points using Wu algorithm
         void              DrawEllipseWu(const int   x1,                // X coordinate of the first point defining the ellipse
                                       const int   y1,                // Y coordinate of the first point defining the ellipse
                                       const int   x2,                // X coordinate of the second point defining the ellipse
                                       const int   y2,                // Y coordinate of the second point defining the ellipse
                                       const color clr,               // Color
                                       const uchar opacity=255,       // Opacity
                                       const uint  style=UINT_MAX)    // Line style is one of the ENUM_LINE_STYLE enumeration values or a custom value
                           { this.m_canvas.EllipseWu(x1,y1,x2,y2,::ColorToARGB(clr,opacity),style);                                        }
      //+------------------------------------------------------------------+
      //| The methods of working with text                                 |
      //+------------------------------------------------------------------+
       //--- Set the last text coordinate (1) X, (2) Y
         void              SetTextLastX(const int x)                    { this.m_text_x=x;                                                   }
         void              SetTextLastY(const int y)                    { this.m_text_y=y;                                                   }
       //--- Return (1) alignment type (anchor method), the last (2) X and (3) Y text coordinate
         ENUM_FRAME_ANCHOR TextAnchor(void)                       const { return this.m_text_anchor;                                         }
         int               TextLastX(void)                        const { return this.m_text_x;                                              }
         int               TextLastY(void)                        const { return this.m_text_y;                                              }
       //--- Set the current font
         bool              SetFont(const string name,                   // Font name. For example, "Arial"
                                    const int    size,                   // Font size
                                    const uint   flags=0,                // Font creation flags
                                    const uint   angle=0,                // Font slope angle in tenths of a degree
                                    const bool   relative=true)          // Relative font size flag
                              { return this.m_canvas.FontSet(name,(relative ? size*-10 : size),flags,angle);                                  }
       //--- Set a font name
         bool              SetFontName(const string name)               // Font name. For example, "Arial"
                       { return this.m_canvas.FontNameSet(name);                                                                       }

       //--- Set a font size
         bool              SetFontSize(const int size,                  // Font size
                                       const bool relative=true)        // Relative font size flag
                           { return this.m_canvas.FontSizeSet(relative ? size*-10 : size);                                                 }

       //--- Set font flags
       //--- FONT_ITALIC - Italic, FONT_UNDERLINE - Underline, FONT_STRIKEOUT - Strikeout
         bool              SetFontFlags(const uint flags)               // Font creation flags
                           { return this.m_canvas.FontFlagsSet(flags);                                                                     }

       //--- Set a font slope angle
         bool              SetFontAngle(const float angle)              // Font slope angle in tenths of a degree
                           { return this.m_canvas.FontAngleSet(uint(angle*10));                                                            }

       //--- Set the font anchor angle (alignment type)
         void              SetTextAnchor(const uint flags=0)      { this.m_text_anchor=(ENUM_FRAME_ANCHOR)flags;                             }

       //--- Gets the current font parameters and write them to variables
         void              GetFont(string &name,                        // The reference to the variable for returning a font name
                                 int    &size,                        // Reference to the variable for returning a font size
                                 uint   &flags,                       // Reference to the variable for returning font flags
                                 uint   &angle)                       // Reference to the variable for returning a font slope angle
                           { this.m_canvas.FontGet(name,size,flags,angle);                                                                 }

       //--- Return (1) the font name, (2) size, (3) flags and (4) slope angle
         string            FontName(void)                         const { return this.m_canvas.FontNameGet();                                }
         int               FontSize(void)                         const { return this.m_canvas.FontSizeGet();                                }
         int               FontSizeRelative(void)                 const { return(this.FontSize()<0 ? -this.FontSize()/10 : this.FontSize()); }
         uint              FontFlags(void)                        const { return this.m_canvas.FontFlagsGet();                               }
         uint              FontAngle(void)                        const { return this.m_canvas.FontAngleGet();                               }

       //--- Return the text (1) width, (2) height and (3) all sizes (the current font is used to measure the text)
         int               TextWidth(const string text)                 { return this.m_canvas.TextWidth(text);                              }
         int               TextHeight(const string text)                { return this.m_canvas.TextHeight(text);                             }
         void              TextSize(const string text,                  // Text for measurement
                                    int         &width,                 // Reference to the variable for returning a text width
                                    int         &height)                // Reference to the variable for returning a text height
                           { this.m_canvas.TextSize(text,width,height);                                                                    }
       //--- Display the text in the current font
         void              Text(  int         x,                          // X coordinate of the text anchor point
                                  int         y,                          // Y coordinate of the text anchor point
                                  string      text,                       // Display text
                                  const color clr,                        // Color
                                  const uchar opacity=255,                // Opacity
                                  uint        alignment=0);                // Text anchoring method
       //--- Return coordinate offsets relative to the text anchor point by text
         void              GetShiftXYbyText(const string text,          // Text for calculating the size of its outlining rectangle
                                 const ENUM_FRAME_ANCHOR anchor,        // Text anchor point, relative to which the offsets are calculated
                                 int &shift_x,                          // X coordinate of the rectangle upper left corner
                                 int &shift_y);                         // Y coordinate of the rectangle upper left corner
       //--- Return coordinate offsets relative to the rectangle anchor point by size
         void              GetShiftXYbySize(const int width,               // Rectangle size by width
                                          const int height,              // Rectangle size by height
                                          const ENUM_FRAME_ANCHOR anchor,// Rectangle anchor point, relative to which the offsets are calculated
                                          int &shift_x,                  // X coordinate of the rectangle upper left corner
                                          int &shift_y);                 // Y coordinate of the rectangle upper left corner
      //+------------------------------------------------------------------+
      //| Methods for drawing predefined standard images                   |
      //+------------------------------------------------------------------+
         //--- Draw the Info icon
            void              DrawIconInfo(const int coord_x,const int coord_y,const uchar opacity);
         //--- Draw the Warning icon
            void              DrawIconWarning(const int coord_x,const int coord_y,const uchar opacity);
         //--- Draw the Error icon
            void              DrawIconError(const int coord_x,const int coord_y,const uchar opacity);
         //--- Draw the left arrow
            void              DrawArrowLeft(const int base_x,const int base_y,const int size,const color clr,const uchar opacity);
         //--- Draw the right arrow
            void              DrawArrowRight(const int base_x,const int base_y,const int size,const color clr,const uchar opacity);
         //--- Draw the up arrow
            void              DrawArrowUp(const int base_x,const int base_y,const int size,const color clr,const uchar opacity);
         //--- Draw the down arrow
            void              DrawArrowDown(const int base_x,const int base_y,const int size,const color clr,const uchar opacity);
   };
 #endif // CGCNVELEMENT_MQH_DECLARATION
 #ifndef CGCNVELEMENT_MQH_IMPLEMENTATION
 #define CGCNVELEMENT_MQH_IMPLEMENTATION
  //--- Get CGCnvElement::the (1) main and (2) base object ID
  int CGCnvElement::GetMainID(void)
   {
      if(this.IsMain())
      return this.ID();
      CGCnvElement *main=this.GetMain();
      return(main!=NULL ? main.ID() : WRONG_VALUE);
   }

  int CGCnvElement::GetBaseID(void)
   {
      if(!this.IsDependent())
      return this.ID();
      CGCnvElement *base=this.GetBase();
      return(base!=NULL ? base.ID() : WRONG_VALUE);
   }
  //--- Default constructor
  CGCnvElement::CGCnvElement() : m_shadow(false),m_chart_color_bg((color)::ChartGetInteger(::ChartID(),CHART_COLOR_BACKGROUND))
   {
      this.m_type=OBJECT_DE_TYPE_GELEMENT;
      this.m_element_main=NULL;
      this.m_element_base=NULL;
      this.m_shift_coord_x=0;
      this.m_shift_coord_y=0;
   }

  //---CGCnvElement:: (1) Set and (2) return the graphical element type
  void CGCnvElement::SetTypeElement(const ENUM_GRAPH_ELEMENT_TYPE type)
   {
      CGBaseObj::SetTypeElement(type);
      this.SetProperty(CANV_ELEMENT_PROP_TYPE,type);
   }

  //--- Set the main background color
  void              CGCnvElement::SetBackgroundColor(const color colour,const bool set_init_color)
   {
      if(this.BackgroundColor()==colour)
      return;
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR,colour);
      color arr[1];
      arr[0]=colour;
      this.SaveColorsBG(arr);
      if(set_init_color)
      this.SetBackgroundColorInit(this.BackgroundColor());
   }

  void              CGCnvElement::SetBackgroundColors(color &colors[],const bool set_init_colors)
   {
      if(::ArrayCompare(colors,this.m_array_colors_bg)==0)
      return;
      this.SaveColorsBG(colors);
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR,this.m_array_colors_bg[0]);
      if(set_init_colors)
      this.SetBackgroundColorsInit(colors);
   }

  //--- Set the background color when clicking on the control
  void              CGCnvElement::SetBackgroundColorMouseDown(const color colour)
   {
      if(this.BackgroundColorMouseDown()==colour)
      return;
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_DOWN,colour);
      color arr[1];
      arr[0]=colour;
      this.SaveColorsBGMouseDown(arr);
   }

  void              CGCnvElement::SetBackgroundColorsMouseDown(color &colors[])
   {
      if(::ArrayCompare(colors,this.m_array_colors_bg_dwn)==0)
      return;
      this.SaveColorsBGMouseDown(colors);
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_DOWN,this.m_array_colors_bg_dwn[0]);
   }

  //--- Set the background color when hovering the mouse over control
  void              CGCnvElement::SetBackgroundColorMouseOver(const color colour)
   {
      if(this.BackgroundColorMouseOver()==colour)
      return;
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_OVER,colour);
      color arr[1];
      arr[0]=colour;
      this.SaveColorsBGMouseOver(arr);
   }

  void              CGCnvElement::SetBackgroundColorsMouseOver(color &colors[])
   {
      if(::ArrayCompare(colors,this.m_array_colors_bg_ovr)==0)
      return;
      this.SaveColorsBGMouseOver(colors);
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_OVER,this.m_array_colors_bg_ovr[0]);
   }

  //--- Set the initial main background color
  void              CGCnvElement::SetBackgroundColorInit(const color colour)
   {
      color arr[1];
      arr[0]=colour;
      this.SaveColorsBGInit(arr);
   }

  color             CGCnvElement::BackgroundColor(const uint index)   const
   {
      uint total=this.m_array_colors_bg.Size();
      if(total==0)
      return this.BackgroundColor();
      return(index>total-1 ? this.m_array_colors_bg[total-1] : this.m_array_colors_bg[index]);
   }

  color             CGCnvElement::BackgroundColorMouseDown(const uint index) const
   {
      uint total=this.m_array_colors_bg_dwn.Size();
      if(total==0)
      return this.BackgroundColorMouseDown();
      return(index>total-1 ? this.m_array_colors_bg_dwn[total-1] : this.m_array_colors_bg_dwn[index]);
   }

  color             CGCnvElement::BackgroundColorMouseOver(const uint index) const
   {
      uint total=this.m_array_colors_bg_ovr.Size();
      if(total==0)
      return this.BackgroundColorMouseOver();
      return(index>total-1 ? this.m_array_colors_bg_ovr[total-1] : this.m_array_colors_bg_ovr[index]);
   }

  color             CGCnvElement::BackgroundColorInit(const uint index)const
   {
      uint total=this.m_array_colors_bg_init.Size();
      if(total==0)
      return this.BackgroundColor();
      return(index>total-1 ? this.m_array_colors_bg_init[total-1] : this.m_array_colors_bg_init[index]);
   }

  bool      CGCnvElement::SetZorder(const long value,const bool only_prop)
   {
      if(!CGBaseObj::SetZorder(value,only_prop))
      return false;
      this.SetProperty(CANV_ELEMENT_PROP_ZORDER,value);
      return true;
   }

  void      CGCnvElement::SetGroup(const int value)
   {
      CGBaseObj::SetGroup(value);
      this.SetProperty(CANV_ELEMENT_PROP_GROUP,value);
   }

  bool      CGCnvElement::SetXOffset(const int value,const bool only_prop)
   {
      ::ResetLastError();
      if((!only_prop && CGBaseObj::SetXOffset(value)) || only_prop)
      {
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_X,value);
      return true;
      }
      else
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
   }

  bool      CGCnvElement::SetYOffset(const int value,const bool only_prop)
   {
      ::ResetLastError();
      if((!only_prop && CGBaseObj::SetYOffset(value)) || only_prop)
      {
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_Y,value);
      return true;
      }
      else
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
   }

  bool      CGCnvElement::SetXSize(const int value,const bool only_prop)
   {
      ::ResetLastError();
      if((!only_prop && CGBaseObj::SetXSize(value)) || only_prop)
      {
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_WIDTH,value);
      return true;
      }
      else
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
   }

  bool      CGCnvElement::SetYSize(const int value,const bool only_prop)
   {
      ::ResetLastError();
      if((!only_prop && CGBaseObj::SetYSize(value)) || only_prop)
      {
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_HEIGHT,value);
      return true;
      }
      else
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
   }

  bool      CGCnvElement::SetVisibleAreaX(const int value,const bool only_prop)
   {
      ::ResetLastError();
      if((!only_prop && CGBaseObj::SetXOffset(value)) || only_prop)
      {
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_X,value);
      return true;
      }
      else
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
   }

  bool      CGCnvElement::SetVisibleAreaY(const int value,const bool only_prop)
   {
      ::ResetLastError();
      if((!only_prop && CGBaseObj::SetYOffset(value)) || only_prop)
      {
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_Y,value);
      return true;
      }
      else
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
   }

  bool      CGCnvElement::SetVisibleAreaWidth(const int value,const bool only_prop)
   {
      ::ResetLastError();
      if((!only_prop && CGBaseObj::SetXSize(value)) || only_prop)
      {
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_WIDTH,value);
      return true;
      }
      else
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
   }

  bool      CGCnvElement::SetVisibleAreaHeight(const int value,const bool only_prop)
   {
      ::ResetLastError();
      if((!only_prop && CGBaseObj::SetYSize(value)) || only_prop)
      {
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_HEIGHT,value);
      return true;
      }
      else
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
   }

  //--- Set relative coordinates and size of the visible area
  void              CGCnvElement::SetVisibleArea(const int x,const int y,const int w,const int h,const bool only_prop)
   {
      this.SetVisibleAreaX(x,only_prop);
      this.SetVisibleAreaY(y,only_prop);
      this.SetVisibleAreaWidth(w,only_prop);
      this.SetVisibleAreaHeight(h,only_prop);
   }

  //--- Display the text in the current font
  void              CGCnvElement::Text(int         x,                          // X coordinate of the text anchor point
  int         y,                          // Y coordinate of the text anchor point
  string      text,                       // Display text
  const color clr,                        // Color
  const uchar opacity,                // Opacity
  uint        alignment)                // Text anchoring method
   {
      this.m_text_anchor=(ENUM_FRAME_ANCHOR)alignment;
      this.m_text_x=x;
      this.m_text_y=y;
      this.m_canvas.TextOut(x,y,text,::ColorToARGB(clr,opacity),alignment);
   }

  //+------------------------------------------------------------------+
  //| Parametric constructor                                           |
  //+------------------------------------------------------------------+
  CGCnvElement::CGCnvElement(const ENUM_GRAPH_ELEMENT_TYPE element_type,
  CGCnvElement *main_obj,CGCnvElement *base_obj,
  const int      element_id,
  const int      element_num,
  const long     chart_id,
  const int      wnd_num,
  const string   descript,
  const int      x,
  const int      y,
  const int      w,
  const int      h,
  const color    colour,
  const uchar    opacity,
  const bool     movable=true,
  const bool     activity=true,
  const bool     redraw=false) : m_shadow(false)
   {
      this.SetTypeElement(element_type);
      this.m_type=OBJECT_DE_TYPE_GELEMENT;
      this.m_element_main=main_obj;
      this.m_element_base=base_obj;
      this.m_chart_color_bg=(color)::ChartGetInteger((chart_id==NULL ? ::ChartID() : chart_id),CHART_COLOR_BACKGROUND);
      this.m_name=this.CreateNameGraphElement(element_type);
      this.m_chart_id=(chart_id==NULL || chart_id==0 ? ::ChartID() : chart_id);
      this.m_subwindow=wnd_num;
      this.SetFont(DEF_FONT,DEF_FONT_SIZE);
      this.m_text_anchor=0;
      this.m_text_x=0;
      this.m_text_y=0;
      this.SetBackgroundColor(colour,true);
      this.SetOpacity(opacity);
      this.m_shift_coord_x=0;
      this.m_shift_coord_y=0;
      if(::ArrayResize(this.m_array_colors_bg,1)==1)
      this.m_array_colors_bg[0]=this.BackgroundColor();
      if(::ArrayResize(this.m_array_colors_bg_dwn,1)==1)
      this.m_array_colors_bg_dwn[0]=this.BackgroundColor();
      if(::ArrayResize(this.m_array_colors_bg_ovr,1)==1)
      this.m_array_colors_bg_ovr[0]=this.BackgroundColor();
      if(this.Create(chart_id,wnd_num,x,y,w,h,redraw))
      {
         this.Initialize(element_type,element_id,element_num,x,y,w,h,descript,movable,activity);
         this.SetVisibleFlag(false,false);
      }
      else
      {
         ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_ELM_OBJ),"\"",this.TypeElementDescription(element_type),"\" ",this.NameObj());
      }
   }
  //+------------------------------------------------------------------+
  //| Protected constructor                                            |
  //+------------------------------------------------------------------+
  CGCnvElement::CGCnvElement(const ENUM_GRAPH_ELEMENT_TYPE element_type,
  CGCnvElement *main_obj,CGCnvElement *base_obj,
  const long    chart_id,
  const int     wnd_num,
  const string  descript,
  const int     x,
  const int     y,
  const int     w,
  const int     h) : m_shadow(false)
   {
      this.m_type=OBJECT_DE_TYPE_GELEMENT;
      this.m_element_main=main_obj;
      this.m_element_base=base_obj;
      this.m_chart_color_bg=(color)::ChartGetInteger((chart_id==NULL ? ::ChartID() : chart_id),CHART_COLOR_BACKGROUND);
      this.m_name=this.CreateNameGraphElement(element_type);
      this.m_chart_id=(chart_id==NULL || chart_id==0 ? ::ChartID() : chart_id);
      this.m_subwindow=wnd_num;
      this.m_type_element=element_type;
      this.SetFont(DEF_FONT,DEF_FONT_SIZE);
      this.m_text_anchor=0;
      this.m_text_x=0;
      this.m_text_y=0;
      this.SetBackgroundColor(CLR_CANV_NULL,true);
      this.SetOpacity(0);
      this.m_shift_coord_x=0;
      this.m_shift_coord_y=0;
      if(::ArrayResize(this.m_array_colors_bg,1)==1)
      this.m_array_colors_bg[0]=this.BackgroundColor();
      if(::ArrayResize(this.m_array_colors_bg_dwn,1)==1)
      this.m_array_colors_bg_dwn[0]=this.BackgroundColor();
      if(::ArrayResize(this.m_array_colors_bg_ovr,1)==1)
      this.m_array_colors_bg_ovr[0]=this.BackgroundColor();
      if(this.Create(chart_id,wnd_num,x,y,w,h,false))
      {
         this.Initialize(element_type,0,0,x,y,w,h,descript,false,false);
         this.SetVisibleFlag(false,false);
      }
      else
      {
         ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_FAILED_CREATE_ELM_OBJ),"\"",this.TypeElementDescription(element_type),"\" ",this.NameObj());
      }
   }
  //+------------------------------------------------------------------+
  //| Destructor                                                       |
  //+------------------------------------------------------------------+
  //CGCnvElement::~CGCnvElement()
  //  {
  //   this.m_canvas.Destroy();
  //  }
  //+------------------------------------------------------------------+
  //| Initialize the properties                                        |
  //+------------------------------------------------------------------+
  void CGCnvElement::Initialize(const ENUM_GRAPH_ELEMENT_TYPE element_type,
  const int element_id,const int element_num,
  const int x,const int y,const int w,const int h,
  const string descript,const bool movable,const bool activity)
   {
      this.SetProperty(CANV_ELEMENT_PROP_NAME_RES,this.m_canvas.ResourceName()); // Graphical resource name
      this.SetProperty(CANV_ELEMENT_PROP_CHART_ID,CGBaseObj::ChartID());         // Chart ID
      this.SetProperty(CANV_ELEMENT_PROP_WND_NUM,CGBaseObj::SubWindow());        // Chart subwindow index
      this.SetProperty(CANV_ELEMENT_PROP_NAME_OBJ,CGBaseObj::Name());            // Element object name
      this.SetProperty(CANV_ELEMENT_PROP_TYPE,element_type);                     // Graphical element type
      this.SetProperty(CANV_ELEMENT_PROP_ID,element_id);                         // Element ID
      this.SetProperty(CANV_ELEMENT_PROP_NUM,element_num);                       // Element index in the list
      this.SetProperty(CANV_ELEMENT_PROP_COORD_X,x);                             // Element's X coordinate on the chart
      this.SetProperty(CANV_ELEMENT_PROP_COORD_Y,y);                             // Element's Y coordinate on the chart
      this.SetProperty(CANV_ELEMENT_PROP_WIDTH,w);                               // Element width
      this.SetProperty(CANV_ELEMENT_PROP_HEIGHT,h);                              // Element height
      this.SetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_LEFT,0);                      // Active area offset from the left edge of the element
      this.SetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_TOP,0);                       // Active area offset from the upper edge of the element
      this.SetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_RIGHT,0);                     // Active area offset from the right edge of the element
      this.SetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_BOTTOM,0);                    // Active area offset from the bottom edge of the element
      this.SetProperty(CANV_ELEMENT_PROP_MOVABLE,movable);                       // Element moveability flag
      this.SetProperty(CANV_ELEMENT_PROP_ACTIVE,activity);                       // Element activity flag
      this.SetProperty(CANV_ELEMENT_PROP_INTERACTION,false);                     // Flag of interaction with the outside environment
      this.SetProperty(CANV_ELEMENT_PROP_ENABLED,true);                          // Element availability flag
      this.SetProperty(CANV_ELEMENT_PROP_RESIZABLE,false);                       // Element changeable size flag
      this.SetProperty(CANV_ELEMENT_PROP_RIGHT,this.RightEdge());                // Element right border
      this.SetProperty(CANV_ELEMENT_PROP_BOTTOM,this.BottomEdge());              // Element bottom border
      this.SetProperty(CANV_ELEMENT_PROP_COORD_ACT_X,this.ActiveAreaLeft());     // X coordinate of the element active area
      this.SetProperty(CANV_ELEMENT_PROP_COORD_ACT_Y,this.ActiveAreaTop());      // Y coordinate of the element active area
      this.SetProperty(CANV_ELEMENT_PROP_ACT_RIGHT,this.ActiveAreaRight());      // Right border of the element active area
      this.SetProperty(CANV_ELEMENT_PROP_ACT_BOTTOM,this.ActiveAreaBottom());    // Bottom border of the element active area
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_X,0);                      // Visibility scope X coordinate
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_Y,0);                      // Visibility scope Y coordinate
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_WIDTH,w);                  // Visibility scope width
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_HEIGHT,h);                 // Visibility scope height
      this.SetProperty(CANV_ELEMENT_PROP_DISPLAYED,true);                        // Non-hidden control display flag
      this.SetProperty(CANV_ELEMENT_PROP_DISPLAY_STATE,CANV_ELEMENT_DISPLAY_STATE_NORMAL);// Control display state
      this.SetProperty(CANV_ELEMENT_PROP_DISPLAY_DURATION,DEF_CONTROL_PROCESS_DURATION);  // Control display duration
      this.SetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_X,0);                      // Control area X coordinate
      this.SetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_Y,0);                      // Control area Y coordinate
      this.SetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_WIDTH,0);                  // Control area width
      this.SetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_HEIGHT,0);                 // Control area height
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_X_RIGHT,0);                 // Right scroll area X coordinate
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_Y_RIGHT,0);                 // Right scroll area Y coordinate
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_WIDTH_RIGHT,0);             // Right scroll area width
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_HEIGHT_RIGHT,0);            // Right scroll area height
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_X_BOTTOM,0);                // Bottom scroll area X coordinate
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_Y_BOTTOM,0);                // Bottom scroll area Y coordinate
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_WIDTH_BOTTOM,0);            // Bottom scroll area width
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_HEIGHT_BOTTOM,0);           // Bottom scroll area height
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_LEFT_AREA_WIDTH,2);              // Left edge area width
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_BOTTOM_AREA_WIDTH,2);            // Bottom edge area width
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_RIGHT_AREA_WIDTH,2);             // Right edge area width
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_TOP_AREA_WIDTH,2);               // Upper edge area width
      //---
      this.SetProperty(CANV_ELEMENT_PROP_BELONG,ENUM_GRAPH_OBJ_BELONG::GRAPH_OBJ_BELONG_PROGRAM);  // Graphical element affiliation
      this.SetProperty(CANV_ELEMENT_PROP_ZORDER,0);                              // Priority of a graphical object for receiving the event of clicking on a chart
      this.SetProperty(CANV_ELEMENT_PROP_BOLD_TYPE,FW_NORMAL);                   // Font width type
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_STYLE,FRAME_STYLE_NONE);         // Control frame style
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_TOP,0);                     // Control frame top size
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_BOTTOM,0);                  // Control frame bottom size
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_LEFT,0);                    // Control frame left size
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_RIGHT,0);                   // Control frame right size
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_COLOR,this.BackgroundColor());   // Control frame color
      this.SetProperty(CANV_ELEMENT_PROP_AUTOSIZE,false);                        // Flag of the element auto resizing depending on the content
      this.SetProperty(CANV_ELEMENT_PROP_AUTOSIZE_MODE,CANV_ELEMENT_AUTO_SIZE_MODE_GROW); // Mode of the element auto resizing depending on the content
      this.SetProperty(CANV_ELEMENT_PROP_AUTOSCROLL,false);                      // Auto scrollbar flag
      this.SetProperty(CANV_ELEMENT_PROP_AUTOSCROLL_MARGIN_W,0);                 // Width of the field inside the element during auto scrolling
      this.SetProperty(CANV_ELEMENT_PROP_AUTOSCROLL_MARGIN_H,0);                 // Height of the field inside the element during auto scrolling
      this.SetProperty(CANV_ELEMENT_PROP_DOCK_MODE,CANV_ELEMENT_DOCK_MODE_NONE); // Mode of binding control borders to the container
      this.SetProperty(CANV_ELEMENT_PROP_MARGIN_TOP,0);                          // Top margin between the fields of this and another control
      this.SetProperty(CANV_ELEMENT_PROP_MARGIN_BOTTOM,0);                       // Bottom margin between the fields of this and another control
      this.SetProperty(CANV_ELEMENT_PROP_MARGIN_LEFT,0);                         // Left margin between the fields of this and another control
      this.SetProperty(CANV_ELEMENT_PROP_MARGIN_RIGHT,0);                        // Right margin between the fields of this and another control
      this.SetProperty(CANV_ELEMENT_PROP_PADDING_TOP,0);                         // Top margin inside the control
      this.SetProperty(CANV_ELEMENT_PROP_PADDING_BOTTOM,0);                      // Bottom margin inside the control
      this.SetProperty(CANV_ELEMENT_PROP_PADDING_LEFT,0);                        // Left margin inside the control
      this.SetProperty(CANV_ELEMENT_PROP_PADDING_RIGHT,0);                       // Right margin inside the control
      this.SetProperty(CANV_ELEMENT_PROP_TEXT_ALIGN,ANCHOR_LEFT_UPPER);          // Text position within text label boundaries
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_ALIGN,ANCHOR_LEFT_UPPER);         // Position of the checkbox within control borders
      this.SetProperty(CANV_ELEMENT_PROP_CHECKED,false);                         // Control checkbox status
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_STATE,CANV_ELEMENT_CHEK_STATE_UNCHECKED);  // Status of a control having a checkbox
      this.SetProperty(CANV_ELEMENT_PROP_AUTOCHECK,true);                        // Auto change flag status when it is selected
      //---
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR,CLR_DEF_CHECK_BACK_COLOR);            // Color of control checkbox background
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_OPACITY,CLR_DEF_CHECK_BACK_OPACITY);  // Opacity of the control checkbox background color
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_MOUSE_DOWN,CLR_DEF_CHECK_BACK_MOUSE_DOWN);// Color of control checkbox background when clicking on the control
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_MOUSE_OVER,CLR_DEF_CHECK_BACK_MOUSE_OVER);// Color of control checkbox background when hovering the mouse over the control
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FORE_COLOR,CLR_DEF_CHECK_BORDER_COLOR);                // Color of control checkbox frame
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FORE_COLOR_OPACITY,CLR_DEF_CHECK_BORDER_OPACITY);      // Opacity of the control checkbox frame color
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FORE_COLOR_MOUSE_DOWN,CLR_DEF_CHECK_BORDER_MOUSE_DOWN);// Color of control checkbox frame when clicking on the control
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FORE_COLOR_MOUSE_OVER,CLR_DEF_CHECK_BORDER_MOUSE_OVER);// Color of control checkbox frame when hovering the mouse over the control
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FLAG_COLOR,CLR_DEF_CHECK_FLAG_COLOR);                  // Control checkbox color
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_OPACITY,CLR_DEF_CHECK_FLAG_OPACITY);        // Control checkbox color opacity
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_MOUSE_DOWN,CLR_DEF_CHECK_FLAG_MOUSE_DOWN);  // Control checkbox color when clicking on the control
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_MOUSE_OVER,CLR_DEF_CHECK_FLAG_MOUSE_OVER);  // Control checkbox color when hovering the mouse over the control
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR,CLR_DEF_FORE_COLOR);                              // Default text color for all control objects
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR_OPACITY,CLR_DEF_FORE_COLOR_OPACITY);              // Default text color opacity for all control objects
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR_MOUSE_DOWN,CLR_DEF_FORE_COLOR_MOUSE_DOWN);        // Default control text color when clicking on the control
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR_MOUSE_OVER,CLR_DEF_FORE_COLOR_MOUSE_OVER);        // Default control text color when hovering the mouse over the control
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON,CLR_DEF_FORE_COLOR);                     // Text color of the control which is on
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON_MOUSE_DOWN,CLR_DEF_FORE_COLOR_MOUSE_DOWN);// Default control text color when clicking on the control which is on
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON_MOUSE_OVER,CLR_DEF_FORE_COLOR_MOUSE_OVER);// Default control text color when hovering the mouse over the control which is on
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_DOWN,this.BackgroundColor());         // Control background color when clicking on the control
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_OVER,this.BackgroundColor());         // Control background color when hovering the mouse over the control
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON,CLR_DEF_CONTROL_STD_BACK_COLOR_ON);// Background color of the control which is on
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON_MOUSE_DOWN,CLR_DEF_CONTROL_STD_BACK_DOWN_ON);// Control background color when clicking on the control which is on
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON_MOUSE_OVER,CLR_DEF_CONTROL_STD_BACK_OVER_ON);// Control background color when hovering the cursor over the control which is on
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_COLOR_MOUSE_DOWN,CLR_DEF_BORDER_MOUSE_DOWN);          // Control frame color when clicking on the control
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_COLOR_MOUSE_OVER,CLR_DEF_BORDER_MOUSE_OVER);          // Control frame color when hovering the mouse over the control
      this.SetProperty(CANV_ELEMENT_PROP_BUTTON_TOGGLE,false);                                        // Toggle flag of the control featuring a button
      this.SetProperty(CANV_ELEMENT_PROP_BUTTON_STATE,false);                                         // Status of the Toggle control featuring a button
      this.SetProperty(CANV_ELEMENT_PROP_BUTTON_GROUP,false);                                         // Button group flag
      this.SetProperty(CANV_ELEMENT_PROP_LIST_BOX_MULTI_COLUMN,false);                                // Horizontal display of columns in the ListBox control
      this.SetProperty(CANV_ELEMENT_PROP_LIST_BOX_COLUMN_WIDTH,0);                                    // Width of each ListBox control column
      this.SetProperty(CANV_ELEMENT_PROP_TAB_MULTILINE,false);                                        // Several lines of tabs in TabControl
      this.SetProperty(CANV_ELEMENT_PROP_TAB_ALIGNMENT,CANV_ELEMENT_ALIGNMENT_TOP);                   // Location of tabs inside the control
      this.SetProperty(CANV_ELEMENT_PROP_ALIGNMENT,CANV_ELEMENT_ALIGNMENT_TOP);                       // Location of an object inside the control
      this.SetProperty(CANV_ELEMENT_PROP_TEXT,"");                                                    // Graphical element text
      this.SetProperty(CANV_ELEMENT_PROP_DESCRIPTION,descript);                                       // Graphical element description
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_FIXED_PANEL,0);                              // Panel that retains its size when the container is resized
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_FIXED,true);                        // Separator moveability flag
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_DISTANCE,50);                       // Distance from edge to separator
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_WIDTH,4);                           // Separator width
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_ORIENTATION,0);                     // Separator location
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL1_COLLAPSED,false);                     // Flag for collapsed panel 1
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL1_MIN_SIZE,25);                         // Panel 1 minimum size
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL2_COLLAPSED,false);                     // Flag for collapsed panel 1
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL2_MIN_SIZE,25);                         // Panel 2 minimum size
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_INITIAL_DELAY,500);                                  // Tooltip display delay
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_AUTO_POP_DELAY,5000);                                // Tooltip display duration
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_RESHOW_DELAY,100);                                   // One element new tooltip display delay
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_SHOW_ALWAYS,false);                                  // Display a tooltip in inactive window
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_ICON,CANV_ELEMENT_TOOLTIP_ICON_NONE);                // Icon displayed in a tooltip
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_IS_BALLOON,false);                                   // Tooltip in the form of a "cloud"
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_USE_FADING,true);                                    // Fade when showing/hiding a tooltip
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_TITLE,"");                                           // Tooltip title for the element
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_TEXT,"");                                            // Tooltip text for the element
      this.SetProperty(CANV_ELEMENT_PROP_GROUP,0);                               // Group the graphical element belongs to
      this.SetProperty(CANV_ELEMENT_PROP_TAB_SIZE_MODE,CANV_ELEMENT_TAB_SIZE_MODE_NORMAL);// Tab size setting mode
      this.SetProperty(CANV_ELEMENT_PROP_TAB_PAGE_NUMBER,0);                     // Tab index number
      this.SetProperty(CANV_ELEMENT_PROP_TAB_PAGE_ROW,0);                        // Tab row index
      this.SetProperty(CANV_ELEMENT_PROP_TAB_PAGE_COLUMN,0);                     // Tab column index
      this.SetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_MAXIMUM,100);              // The upper bound of the range ProgressBar operates in
      this.SetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_MINIMUM,0);                // The lower bound of the range ProgressBar operates in
      this.SetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_STEP,10);                  // ProgressBar increment needed to redraw it
      this.SetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_STYLE,CANV_ELEMENT_PROGRESS_BAR_STYLE_CONTINUOUS); // ProgressBar style
      this.SetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_VALUE,50);                 // Current ProgressBar value from Min to Max
      this.SetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_MARQUEE_ANIM_SPEED,10);    // Progress bar animation speed in case of Marquee style
      this.SetProperty(CANV_ELEMENT_PROP_BUTTON_ARROW_SIZE,3);                   // Size of the arrow drawn on the button
   }
  //+----------------------------------------------------------------------+
  //|Compare CGCnvElement objects with each other by the specified property|
  //+----------------------------------------------------------------------+
  int CGCnvElement::Compare(const CObject *node,const int mode=0) const
   {
      const CGCnvElement *obj_compared=node;
      //--- compare integer properties of two objects
      if(mode<CANV_ELEMENT_PROP_INTEGER_TOTAL)
      {
         long value_compared=obj_compared.GetProperty((ENUM_CANV_ELEMENT_PROP_INTEGER)mode);
         long value_current=this.GetProperty((ENUM_CANV_ELEMENT_PROP_INTEGER)mode);
         return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
      //--- compare real properties of two objects
      else if(mode<CANV_ELEMENT_PROP_DOUBLE_TOTAL+CANV_ELEMENT_PROP_INTEGER_TOTAL)
      {
         double value_compared=obj_compared.GetProperty((ENUM_CANV_ELEMENT_PROP_DOUBLE)mode);
         double value_current=this.GetProperty((ENUM_CANV_ELEMENT_PROP_DOUBLE)mode);
         return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
      //--- compare string properties of two objects
      else if(mode<CANV_ELEMENT_PROP_DOUBLE_TOTAL+CANV_ELEMENT_PROP_INTEGER_TOTAL+CANV_ELEMENT_PROP_STRING_TOTAL)
      {
         string value_compared=obj_compared.GetProperty((ENUM_CANV_ELEMENT_PROP_STRING)mode);
         string value_current=this.GetProperty((ENUM_CANV_ELEMENT_PROP_STRING)mode);
         return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
      return 0;
   }
  //+------------------------------------------------------------------+
  //| Compare CGCnvElement objects with each other by all properties   |
  //+------------------------------------------------------------------+
  bool CGCnvElement::IsEqual(CGCnvElement *compared_obj) const
   {
      int begin=0, end=CANV_ELEMENT_PROP_INTEGER_TOTAL;
      for(int i=begin; i<end; i++)
      {
         ENUM_CANV_ELEMENT_PROP_INTEGER prop=(ENUM_CANV_ELEMENT_PROP_INTEGER)i;
          if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false;
      }
      begin=end; end+=CANV_ELEMENT_PROP_DOUBLE_TOTAL;
      for(int i=begin; i<end; i++)
      {
         ENUM_CANV_ELEMENT_PROP_DOUBLE prop=(ENUM_CANV_ELEMENT_PROP_DOUBLE)i;
          if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false;
      }
      begin=end; end+=CANV_ELEMENT_PROP_STRING_TOTAL;
      for(int i=begin; i<end; i++)
      {
         ENUM_CANV_ELEMENT_PROP_STRING prop=(ENUM_CANV_ELEMENT_PROP_STRING)i;
          if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false;
      }
      return true;
   }
  //+------------------------------------------------------------------+
  //| Create the object structure                                      |
  //+------------------------------------------------------------------+
  bool CGCnvElement::ObjectToStruct(void)
   {
      //--- Save integer properties
      this.m_struct_obj.id=(int)this.GetProperty(CANV_ELEMENT_PROP_ID);                               // Element ID
      this.m_struct_obj.type=(int)this.GetProperty(CANV_ELEMENT_PROP_TYPE);                           // Graphical element type
      this.m_struct_obj.belong=(int)this.GetProperty(CANV_ELEMENT_PROP_BELONG);                       // Graphical element affiliation
      this.m_struct_obj.number=(int)this.GetProperty(CANV_ELEMENT_PROP_NUM);                          // Element index in the list
      this.m_struct_obj.chart_id=this.GetProperty(CANV_ELEMENT_PROP_CHART_ID);                        // Chart ID
      this.m_struct_obj.subwindow=(int)this.GetProperty(CANV_ELEMENT_PROP_WND_NUM);                   // Chart subwindow index
      this.m_struct_obj.coord_x=(int)this.GetProperty(CANV_ELEMENT_PROP_COORD_X);                     // Form's X coordinate on the chart
      this.m_struct_obj.coord_y=(int)this.GetProperty(CANV_ELEMENT_PROP_COORD_Y);                     // Form's Y coordinate on the chart
      this.m_struct_obj.width=(int)this.GetProperty(CANV_ELEMENT_PROP_WIDTH);                         // Element width
      this.m_struct_obj.height=(int)this.GetProperty(CANV_ELEMENT_PROP_HEIGHT);                       // Element height
      this.m_struct_obj.edge_right=(int)this.GetProperty(CANV_ELEMENT_PROP_RIGHT);                    // Element right border
      this.m_struct_obj.edge_bottom=(int)this.GetProperty(CANV_ELEMENT_PROP_BOTTOM);                  // Element bottom border
      this.m_struct_obj.act_shift_left=(int)this.GetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_LEFT);       // Active area offset from the left edge of the element
      this.m_struct_obj.act_shift_top=(int)this.GetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_TOP);         // Active area offset from the top edge of the element
      this.m_struct_obj.act_shift_right=(int)this.GetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_RIGHT);     // Active area offset from the right edge of the element
      this.m_struct_obj.act_shift_bottom=(int)this.GetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_BOTTOM);   // Active area offset from the bottom edge of the element
      this.m_struct_obj.movable=(bool)this.GetProperty(CANV_ELEMENT_PROP_MOVABLE);                    // Element moveability flag
      this.m_struct_obj.active=(bool)this.GetProperty(CANV_ELEMENT_PROP_ACTIVE);                      // Element activity flag
      this.m_struct_obj.interaction=(bool)this.GetProperty(CANV_ELEMENT_PROP_INTERACTION);            // Flag of interaction with the outside environment
      this.m_struct_obj.coord_act_x=(int)this.GetProperty(CANV_ELEMENT_PROP_COORD_ACT_X);             // X coordinate of the element active area
      this.m_struct_obj.coord_act_y=(int)this.GetProperty(CANV_ELEMENT_PROP_COORD_ACT_Y);             // Y coordinate of the element active area
      this.m_struct_obj.coord_act_right=(int)this.GetProperty(CANV_ELEMENT_PROP_ACT_RIGHT);           // Right border of the element active area
      this.m_struct_obj.coord_act_bottom=(int)this.GetProperty(CANV_ELEMENT_PROP_ACT_BOTTOM);         // Bottom border of the element active area
      this.m_struct_obj.visible_area_x=(int)this.GetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_X);       // Visibility scope X coordinate
      this.m_struct_obj.visible_area_y=(int)this.GetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_Y);       // Visibility scope Y coordinate
      this.m_struct_obj.visible_area_w=(int)this.GetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_WIDTH);   // Visibility scope width
      this.m_struct_obj.visible_area_h=(int)this.GetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_HEIGHT);  // Visibility scope height
      this.m_struct_obj.displayed=(bool)this.GetProperty(CANV_ELEMENT_PROP_DISPLAYED);                // Non-hidden control display flag
      this.m_struct_obj.display_state=(int)this.GetProperty(CANV_ELEMENT_PROP_DISPLAY_STATE);         // Control display state
      this.m_struct_obj.display_duration=this.GetProperty(CANV_ELEMENT_PROP_DISPLAY_DURATION);        // Control display duration
      this.m_struct_obj.zorder=this.GetProperty(CANV_ELEMENT_PROP_ZORDER);                            // Priority of a graphical object for receiving the event of clicking on a chart
      this.m_struct_obj.enabled=(bool)this.GetProperty(CANV_ELEMENT_PROP_ENABLED);                    // Element availability flag
      this.m_struct_obj.resizable=(bool)this.GetProperty(CANV_ELEMENT_PROP_RESIZABLE);                // Element size changeability flag
      this.m_struct_obj.fore_color=(color)this.GetProperty(CANV_ELEMENT_PROP_FORE_COLOR);             // Default text color for all control objects
      this.m_struct_obj.fore_color_opacity=(uchar)this.GetProperty(CANV_ELEMENT_PROP_FORE_COLOR_OPACITY); // Opacity of the default text color for all control objects
      this.m_struct_obj.background_color=(color)this.GetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR); // Element background color
      this.m_struct_obj.background_color_opacity=(uchar)this.GetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_OPACITY);      // Element opacity
      this.m_struct_obj.background_color_mouse_down=(color)this.GetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_DOWN);// Control background color when clicking on the control
      this.m_struct_obj.background_color_mouse_over=(color)this.GetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_OVER);// Control background color when clicking on the control
      this.m_struct_obj.bold_type=(int)this.GetProperty(CANV_ELEMENT_PROP_BOLD_TYPE);                 // Font width type
      this.m_struct_obj.border_style=(int)this.GetProperty(CANV_ELEMENT_PROP_BORDER_STYLE);           // Control frame style
      this.m_struct_obj.border_size_top=(int)this.GetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_TOP);     // Control frame top size
      this.m_struct_obj.border_size_bottom=(int)this.GetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_BOTTOM);// Control frame bottom size
      this.m_struct_obj.border_size_left=(int)this.GetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_LEFT);   // Control frame left size
      this.m_struct_obj.border_size_right=(int)this.GetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_RIGHT); // Control frame right size
      this.m_struct_obj.border_color=(color)this.GetProperty(CANV_ELEMENT_PROP_BORDER_COLOR);         // Control frame color
      this.m_struct_obj.border_color_mouse_down=(color)this.GetProperty(CANV_ELEMENT_PROP_BORDER_COLOR_MOUSE_DOWN);// Control frame color when clicking on the control
      this.m_struct_obj.border_color_mouse_over=(color)this.GetProperty(CANV_ELEMENT_PROP_BORDER_COLOR_MOUSE_OVER);// Control frame color when hovering the mouse over the control
      this.m_struct_obj.autosize=this.GetProperty(CANV_ELEMENT_PROP_AUTOSIZE);                        // Flag of the element auto resizing depending on the content
      this.m_struct_obj.autosize_mode=(int)this.GetProperty(CANV_ELEMENT_PROP_AUTOSIZE_MODE);         // Mode of the element auto resizing depending on the content
      this.m_struct_obj.autoscroll=this.GetProperty(CANV_ELEMENT_PROP_AUTOSCROLL);        // Auto scrollbar flag
      this.m_struct_obj.autoscroll_margin_w=(int)this.GetProperty(CANV_ELEMENT_PROP_AUTOSCROLL_MARGIN_W);  // Width of the field inside the element during auto scrolling
      this.m_struct_obj.autoscroll_margin_h=(int)this.GetProperty(CANV_ELEMENT_PROP_AUTOSCROLL_MARGIN_H);  // Height of the field inside the element during auto scrolling
      this.m_struct_obj.dock_mode=(int)this.GetProperty(CANV_ELEMENT_PROP_DOCK_MODE);                 // Mode of binding control borders to the container
      this.m_struct_obj.margin_top=(int)this.GetProperty(CANV_ELEMENT_PROP_MARGIN_TOP);               // Top margin between the fields of this and another control
      this.m_struct_obj.margin_bottom=(int)this.GetProperty(CANV_ELEMENT_PROP_MARGIN_BOTTOM);         // Bottom margin between the fields of this and another control
      this.m_struct_obj.margin_left=(int)this.GetProperty(CANV_ELEMENT_PROP_MARGIN_LEFT);             // Left margin between the fields of this and another control
      this.m_struct_obj.margin_right=(int)this.GetProperty(CANV_ELEMENT_PROP_MARGIN_RIGHT);           // Right margin between the fields of this and another control
      this.m_struct_obj.padding_top=(int)this.GetProperty(CANV_ELEMENT_PROP_PADDING_TOP);             // Top margin inside the control
      this.m_struct_obj.padding_bottom=(int)this.GetProperty(CANV_ELEMENT_PROP_PADDING_BOTTOM);       // Bottom margin inside the control
      this.m_struct_obj.padding_left=(int)this.GetProperty(CANV_ELEMENT_PROP_PADDING_LEFT);           // Left margin inside the control
      this.m_struct_obj.padding_right=(int)this.GetProperty(CANV_ELEMENT_PROP_PADDING_RIGHT);         // Right margin inside the control
      this.m_struct_obj.text_align=(int)this.GetProperty(CANV_ELEMENT_PROP_TEXT_ALIGN);               // Text position within text label boundaries
      this.m_struct_obj.check_align=(int)this.GetProperty(CANV_ELEMENT_PROP_CHECK_ALIGN);             // Position of the checkbox within control borders
      this.m_struct_obj.checked=(int)this.GetProperty(CANV_ELEMENT_PROP_CHECKED);                     // Control checkbox status
      this.m_struct_obj.check_state=(int)this.GetProperty(CANV_ELEMENT_PROP_CHECK_STATE);             // Status of a control having a checkbox
      this.m_struct_obj.autocheck=(int)this.GetProperty(CANV_ELEMENT_PROP_AUTOCHECK);                 // Auto change flag status when it is selected
      this.m_struct_obj.check_background_color=(color)this.GetProperty(CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR);          // Color of control checkbox background
      this.m_struct_obj.check_background_color_opacity=(color)this.GetProperty(CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_OPACITY); // Opacity of the control checkbox background color
      this.m_struct_obj.check_background_color_mouse_down=(color)this.GetProperty(CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_MOUSE_DOWN);// Color of control checkbox background when clicking on the control
      this.m_struct_obj.check_background_color_mouse_over=(color)this.GetProperty(CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_MOUSE_OVER);// Color of control checkbox background when hovering the mouse over the control
      this.m_struct_obj.check_fore_color=(color)this.GetProperty(CANV_ELEMENT_PROP_CHECK_FORE_COLOR);                      // Color of control checkbox frame
      this.m_struct_obj.check_fore_color_opacity=(color)this.GetProperty(CANV_ELEMENT_PROP_CHECK_FORE_COLOR_OPACITY);      // Opacity of the control checkbox frame color
      this.m_struct_obj.check_fore_color_mouse_down=(color)this.GetProperty(CANV_ELEMENT_PROP_CHECK_FORE_COLOR_MOUSE_DOWN);// Color of control checkbox frame when clicking on the control
      this.m_struct_obj.check_fore_color_mouse_over=(color)this.GetProperty(CANV_ELEMENT_PROP_CHECK_FORE_COLOR_MOUSE_OVER);// Color of control checkbox frame when hovering the mouse over the control
      this.m_struct_obj.check_flag_color=(color)this.GetProperty(CANV_ELEMENT_PROP_CHECK_FLAG_COLOR);                      // Color of control checkbox
      this.m_struct_obj.check_flag_color_opacity=(color)this.GetProperty(CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_OPACITY);      // Opacity of the control checkbox color
      this.m_struct_obj.check_flag_color_mouse_down=(color)this.GetProperty(CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_MOUSE_DOWN);// Color of control checkbox when clicking on the control
      this.m_struct_obj.check_flag_color_mouse_over=(color)this.GetProperty(CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_MOUSE_OVER);// Color of control checkbox when hovering the mouse over the control
      this.m_struct_obj.fore_color_mouse_down=(color)this.GetProperty(CANV_ELEMENT_PROP_FORE_COLOR_MOUSE_DOWN);            // Default control text color when clicking on the control
      this.m_struct_obj.fore_color_mouse_over=(color)this.GetProperty(CANV_ELEMENT_PROP_FORE_COLOR_MOUSE_OVER);            // Default control text color when hovering the mouse over the control
      this.m_struct_obj.fore_color_toggle=(color)this.GetProperty(CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON);                  // Text color of the control which is on
      this.m_struct_obj.fore_color_toggle_mouse_down=(color)this.GetProperty(CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON_MOUSE_DOWN);// Default control text color when clicking on the control which is on
      this.m_struct_obj.fore_color_toggle_mouse_over=(color)this.GetProperty(CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON_MOUSE_OVER);// Default control text color when clicking on the control which is on
      this.m_struct_obj.background_color_toggle=(color)this.GetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON);      // Background color of the control which is on
      this.m_struct_obj.background_color_toggle_mouse_down=(color)this.GetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON_MOUSE_DOWN);// Control background color when clicking on the control which is on
      this.m_struct_obj.background_color_toggle_mouse_over=(color)this.GetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON_MOUSE_OVER);// Control background color when hovering the mouse over the control which is on
      this.m_struct_obj.button_toggle=(bool)this.GetProperty(CANV_ELEMENT_PROP_BUTTON_TOGGLE);                             // Toggle flag of the control featuring a button
      this.m_struct_obj.button_state=(bool)this.GetProperty(CANV_ELEMENT_PROP_BUTTON_STATE);                               // Status of the Toggle control featuring a button
      this.m_struct_obj.button_group_flag=(bool)this.GetProperty(CANV_ELEMENT_PROP_BUTTON_GROUP);                          // Button group flag
      this.m_struct_obj.multicolumn=(bool)this.GetProperty(CANV_ELEMENT_PROP_LIST_BOX_MULTI_COLUMN);                       // Horizontal display of columns in the ListBox control
      this.m_struct_obj.column_width=(int)this.GetProperty(CANV_ELEMENT_PROP_LIST_BOX_COLUMN_WIDTH);                       // Width of each ListBox control column
      this.m_struct_obj.tab_multiline=(bool)this.GetProperty(CANV_ELEMENT_PROP_TAB_MULTILINE);                             // Several lines of tabs in TabControl
      this.m_struct_obj.tab_alignment=(int)this.GetProperty(CANV_ELEMENT_PROP_TAB_ALIGNMENT);                              // Location of tabs inside the control
      this.m_struct_obj.alignment=(int)this.GetProperty(CANV_ELEMENT_PROP_ALIGNMENT);                                      // Location of the object inside the control
      this.m_struct_obj.split_container_fixed_panel=(bool)this.GetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_FIXED_PANEL);             // Panel that retains its size when the container is resized
      this.m_struct_obj.split_container_splitter_fixed=(bool)this.GetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_FIXED);       // Separator moveability flag
      this.m_struct_obj.split_container_splitter_distance=(int)this.GetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_DISTANCE);  // Distance from edge to separator
      this.m_struct_obj.split_container_splitter_width=(int)this.GetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_WIDTH);        // Separator width
      this.m_struct_obj.split_container_splitter_orientation=(int)this.GetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_ORIENTATION);  // Separator location
      this.m_struct_obj.split_container_panel1_collapsed=(bool)this.GetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL1_COLLAPSED);   // Flag for collapsed panel 1
      this.m_struct_obj.split_container_panel1_min_size=(int)this.GetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL1_MIN_SIZE);      // Panel 1 minimum size
      this.m_struct_obj.split_container_panel2_collapsed=(bool)this.GetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL2_COLLAPSED);   // Flag for collapsed panel 1
      this.m_struct_obj.split_container_panel2_min_size=(int)this.GetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL2_MIN_SIZE);      // Panel 2 minimum size
      this.m_struct_obj.control_area_x=(int)this.GetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_X);                      // Control area X coordinate
      this.m_struct_obj.control_area_y=(int)this.GetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_Y);                      // Control area Y coordinate
      this.m_struct_obj.control_area_width=(int)this.GetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_WIDTH);              // Control area width
      this.m_struct_obj.control_area_height=(int)this.GetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_HEIGHT);            // Control area height
      this.m_struct_obj.scroll_area_x_right=(int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_X_RIGHT);            // Right scroll area X coordinate
      this.m_struct_obj.scroll_area_y_right=(int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_Y_RIGHT);            // Right scroll area Y coordinate
      this.m_struct_obj.scroll_area_width_right=(int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_WIDTH_RIGHT);    // Right scroll area width
      this.m_struct_obj.scroll_area_height_right=(int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_HEIGHT_RIGHT);  // Right scroll area height
      this.m_struct_obj.scroll_area_x_bottom=(int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_X_BOTTOM);          // Bottom scroll area X coordinate
      this.m_struct_obj.scroll_area_y_bottom=(int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_Y_BOTTOM);          // Bottom scroll area Y coordinate
      this.m_struct_obj.scroll_area_width_bottom=(int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_WIDTH_BOTTOM);  // Bottom scroll area width
      this.m_struct_obj.scroll_area_height_bottom=(int)this.GetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_HEIGHT_BOTTOM);// Bottom scroll area height
      this.m_struct_obj.border_left_area_width=(int)this.GetProperty(CANV_ELEMENT_PROP_BORDER_LEFT_AREA_WIDTH);      // Left edge area width
      this.m_struct_obj.border_bottom_area_width=(int)this.GetProperty(CANV_ELEMENT_PROP_BORDER_BOTTOM_AREA_WIDTH);  // Bottom edge area width
      this.m_struct_obj.border_right_area_width=(int)this.GetProperty(CANV_ELEMENT_PROP_BORDER_RIGHT_AREA_WIDTH);    // Right edge area width
      this.m_struct_obj.border_top_area_width=(int)this.GetProperty(CANV_ELEMENT_PROP_BORDER_TOP_AREA_WIDTH);        // Left edge area width
      //---
      this.m_struct_obj.tooltip_initial_delay=this.GetProperty(CANV_ELEMENT_PROP_TOOLTIP_INITIAL_DELAY);    // Tooltip display delay
      this.m_struct_obj.tooltip_auto_pop_delay=this.GetProperty(CANV_ELEMENT_PROP_TOOLTIP_AUTO_POP_DELAY);  // Tooltip display duration
      this.m_struct_obj.tooltip_reshow_delay=this.GetProperty(CANV_ELEMENT_PROP_TOOLTIP_RESHOW_DELAY);      // One element new tooltip display delay
      this.m_struct_obj.tooltip_show_always=this.GetProperty(CANV_ELEMENT_PROP_TOOLTIP_SHOW_ALWAYS);        // Display a tooltip in inactive window
      this.m_struct_obj.tooltip_icon=(int)this.GetProperty(CANV_ELEMENT_PROP_TOOLTIP_ICON);                 // Icon displayed in tooltip
      this.m_struct_obj.tooltip_is_balloon=(bool)this.GetProperty(CANV_ELEMENT_PROP_TOOLTIP_IS_BALLOON);    // Balloon tooltip
      this.m_struct_obj.tooltip_use_fading=(bool)this.GetProperty(CANV_ELEMENT_PROP_TOOLTIP_USE_FADING);    // Fade when showing/hiding a tooltip
      //---
      this.m_struct_obj.group=(int)this.GetProperty(CANV_ELEMENT_PROP_GROUP);                               // Group the graphical element belongs to
      this.m_struct_obj.tab_size_mode=(int)this.GetProperty(CANV_ELEMENT_PROP_TAB_SIZE_MODE);               // Tab size setting mode
      this.m_struct_obj.tab_page_number=(int)this.GetProperty(CANV_ELEMENT_PROP_TAB_PAGE_NUMBER);           // Tab index number
      this.m_struct_obj.tab_page_row=(int)this.GetProperty(CANV_ELEMENT_PROP_TAB_PAGE_ROW);                 // Tab row index
      this.m_struct_obj.tab_page_column=(int)this.GetProperty(CANV_ELEMENT_PROP_TAB_PAGE_COLUMN);           // Tab column index
      this.m_struct_obj.progress_bar_maximum=(int)this.GetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_MAXIMUM); // The upper bound of the range ProgressBar operates in
      this.m_struct_obj.progress_bar_minimum=(int)this.GetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_MINIMUM); // The lower bound of the range ProgressBar operates in
      this.m_struct_obj.progress_bar_step=(int)this.GetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_STEP);       // ProgressBar increment needed to redraw it
      this.m_struct_obj.progress_bar_style=(int)this.GetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_STYLE);     // ProgressBar style
      this.m_struct_obj.progress_bar_value=(int)this.GetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_VALUE);     // Current ProgressBar value from Min to Max
      this.m_struct_obj.progress_bar_marquee_speed=(int)this.GetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_MARQUEE_ANIM_SPEED);// Progress bar animation speed in case of Marquee style
      this.m_struct_obj.button_arrow_size=(uchar)this.GetProperty(CANV_ELEMENT_PROP_BUTTON_ARROW_SIZE);     // Size of the arrow drawn on the button
      //--- Save real properties

      //--- Save string properties
      ::StringToCharArray(this.GetProperty(CANV_ELEMENT_PROP_NAME_OBJ),this.m_struct_obj.name_obj);   // Graphical element object name
      ::StringToCharArray(this.GetProperty(CANV_ELEMENT_PROP_NAME_RES),this.m_struct_obj.name_res);   // Graphical resource name
      ::StringToCharArray(this.GetProperty(CANV_ELEMENT_PROP_TEXT),this.m_struct_obj.text);           // Graphical element text
      ::StringToCharArray(this.GetProperty(CANV_ELEMENT_PROP_DESCRIPTION),this.m_struct_obj.descript);// Graphical element description
      ::StringToCharArray(this.GetProperty(CANV_ELEMENT_PROP_TOOLTIP_TITLE),this.m_struct_obj.tooltip_title);// Tooltip title for the element
      ::StringToCharArray(this.GetProperty(CANV_ELEMENT_PROP_TOOLTIP_TEXT),this.m_struct_obj.tooltip_text);  // Tooltip text for the element
      //--- Save the structure to the uchar array
      ::ResetLastError();
      if(!::StructToCharArray(this.m_struct_obj,this.m_uchar_array))
      {
         CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_SAVE_OBJ_STRUCT_TO_UARRAY,true);
         return false;
      }
      return true;
   }
  //+------------------------------------------------------------------+
  //| Create the object from the structure                             |
  //+------------------------------------------------------------------+
  void CGCnvElement::StructToObject(void)
   {
      //--- Save integer properties
      this.SetProperty(CANV_ELEMENT_PROP_ID,this.m_struct_obj.id);                                    // Element ID
      this.SetProperty(CANV_ELEMENT_PROP_TYPE,this.m_struct_obj.type);                                // Graphical element type
      this.SetProperty(CANV_ELEMENT_PROP_BELONG,this.m_struct_obj.belong);                            // Graphical element affiliation
      this.SetProperty(CANV_ELEMENT_PROP_NUM,this.m_struct_obj.number);                               // Element index in the list
      this.SetProperty(CANV_ELEMENT_PROP_CHART_ID,this.m_struct_obj.chart_id);                        // Chart ID
      this.SetProperty(CANV_ELEMENT_PROP_WND_NUM,this.m_struct_obj.subwindow);                        // Chart subwindow index
      this.SetProperty(CANV_ELEMENT_PROP_COORD_X,this.m_struct_obj.coord_x);                          // Form's X coordinate on the chart
      this.SetProperty(CANV_ELEMENT_PROP_COORD_Y,this.m_struct_obj.coord_y);                          // Form's Y coordinate on the chart
      this.SetProperty(CANV_ELEMENT_PROP_WIDTH,this.m_struct_obj.width);                              // Element width
      this.SetProperty(CANV_ELEMENT_PROP_HEIGHT,this.m_struct_obj.height);                            // Element height
      this.SetProperty(CANV_ELEMENT_PROP_RIGHT,this.m_struct_obj.edge_right);                         // Element right border
      this.SetProperty(CANV_ELEMENT_PROP_BOTTOM,this.m_struct_obj.edge_bottom);                       // Element bottom border
      this.SetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_LEFT,this.m_struct_obj.act_shift_left);            // Active area offset from the left edge of the element
      this.SetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_TOP,this.m_struct_obj.act_shift_top);              // Active area offset from the upper edge of the element
      this.SetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_RIGHT,this.m_struct_obj.act_shift_right);          // Active area offset from the right edge of the element
      this.SetProperty(CANV_ELEMENT_PROP_ACT_SHIFT_BOTTOM,this.m_struct_obj.act_shift_bottom);        // Active area offset from the bottom edge of the element
      this.SetProperty(CANV_ELEMENT_PROP_MOVABLE,this.m_struct_obj.movable);                          // Element moveability flag
      this.SetProperty(CANV_ELEMENT_PROP_ACTIVE,this.m_struct_obj.active);                            // Element activity flag
      this.SetProperty(CANV_ELEMENT_PROP_INTERACTION,this.m_struct_obj.interaction);                  // Flag of interaction with the outside environment
      this.SetProperty(CANV_ELEMENT_PROP_COORD_ACT_X,this.m_struct_obj.coord_act_x);                  // X coordinate of the element active area
      this.SetProperty(CANV_ELEMENT_PROP_COORD_ACT_Y,this.m_struct_obj.coord_act_y);                  // Y coordinate of the element active area
      this.SetProperty(CANV_ELEMENT_PROP_ACT_RIGHT,this.m_struct_obj.coord_act_right);                // Right border of the element active area
      this.SetProperty(CANV_ELEMENT_PROP_ACT_BOTTOM,this.m_struct_obj.coord_act_bottom);              // Bottom border of the element active area
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_X,this.m_struct_obj.visible_area_x);            // Visibility scope X coordinate
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_Y,this.m_struct_obj.visible_area_y);            // Visibility scope Y coordinate
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_WIDTH,this.m_struct_obj.visible_area_w);        // Visibility scope width
      this.SetProperty(CANV_ELEMENT_PROP_VISIBLE_AREA_HEIGHT,this.m_struct_obj.visible_area_h);       // Visibility scope height
      this.SetProperty(CANV_ELEMENT_PROP_DISPLAYED,this.m_struct_obj.displayed);                      // Non-hidden control display flag
      this.SetProperty(CANV_ELEMENT_PROP_DISPLAY_STATE,this.m_struct_obj.display_state);              // Control display state
      this.SetProperty(CANV_ELEMENT_PROP_DISPLAY_DURATION,this.m_struct_obj.display_duration);        // Control display duration
      this.SetProperty(CANV_ELEMENT_PROP_ZORDER,this.m_struct_obj.zorder);                            // Priority of a graphical object for receiving the event of clicking on a chart
      this.SetProperty(CANV_ELEMENT_PROP_ENABLED,this.m_struct_obj.enabled);                          // Element availability flag
      this.SetProperty(CANV_ELEMENT_PROP_RESIZABLE,this.m_struct_obj.resizable);                      // Element size changeability flag
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR,this.m_struct_obj.fore_color);                    // Default text color for all control objects
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR_OPACITY,this.m_struct_obj.fore_color_opacity);    // Default text color opacity for all control objects
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR,this.m_struct_obj.background_color);        // Element background color
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_OPACITY,this.m_struct_obj.background_color_opacity);       // Element opacity
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_DOWN,this.m_struct_obj.background_color_mouse_down); // Control background color when clicking on the control
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_MOUSE_OVER,this.m_struct_obj.background_color_mouse_over); // Control background color when hovering the mouse over the control
      this.SetProperty(CANV_ELEMENT_PROP_BOLD_TYPE,this.m_struct_obj.bold_type);                      // Font width type
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_STYLE,this.m_struct_obj.border_style);                // Control frame style
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_TOP,this.m_struct_obj.border_size_top);          // Control frame top size
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_BOTTOM,this.m_struct_obj.border_size_bottom);    // Control frame bottom size
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_LEFT,this.m_struct_obj.border_size_left);        // Control frame left size
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_RIGHT,this.m_struct_obj.border_size_right);      // Control frame right size
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_COLOR,this.m_struct_obj.border_color);                // Control frame color
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_COLOR_MOUSE_DOWN,this.m_struct_obj.border_color_mouse_down);// Control frame color when clicking on the control
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_COLOR_MOUSE_OVER,this.m_struct_obj.border_color_mouse_over);// Control frame color when hovering the mouse over the control
      this.SetProperty(CANV_ELEMENT_PROP_AUTOSIZE,this.m_struct_obj.autosize);                        // Flag of the element auto resizing depending on the content
      this.SetProperty(CANV_ELEMENT_PROP_AUTOSIZE_MODE,this.m_struct_obj.autosize_mode);              // Mode of the element auto resizing depending on the content
      this.SetProperty(CANV_ELEMENT_PROP_AUTOSCROLL,this.m_struct_obj.autoscroll);                    // Auto scrollbar flag
      this.SetProperty(CANV_ELEMENT_PROP_AUTOSCROLL_MARGIN_W,this.m_struct_obj.autoscroll_margin_w);  // Width of the field inside the element during auto scrolling
      this.SetProperty(CANV_ELEMENT_PROP_AUTOSCROLL_MARGIN_H,this.m_struct_obj.autoscroll_margin_h);  // Height of the field inside the element during auto scrolling
      this.SetProperty(CANV_ELEMENT_PROP_DOCK_MODE,this.m_struct_obj.dock_mode);                      // Mode of binding control borders to the container
      this.SetProperty(CANV_ELEMENT_PROP_MARGIN_TOP,this.m_struct_obj.margin_top);                    // Top margin between the fields of this and another control
      this.SetProperty(CANV_ELEMENT_PROP_MARGIN_BOTTOM,this.m_struct_obj.margin_bottom);              // Bottom margin between the fields of this and another control
      this.SetProperty(CANV_ELEMENT_PROP_MARGIN_LEFT,this.m_struct_obj.margin_left);                  // Left margin between the fields of this and another control
      this.SetProperty(CANV_ELEMENT_PROP_MARGIN_RIGHT,this.m_struct_obj.margin_right);                // Right margin between the fields of this and another control
      this.SetProperty(CANV_ELEMENT_PROP_PADDING_TOP,this.m_struct_obj.padding_top);                  // Top margin inside the control
      this.SetProperty(CANV_ELEMENT_PROP_PADDING_BOTTOM,this.m_struct_obj.padding_bottom);            // Bottom margin inside the control
      this.SetProperty(CANV_ELEMENT_PROP_PADDING_LEFT,this.m_struct_obj.padding_left);                // Left margin inside the control
      this.SetProperty(CANV_ELEMENT_PROP_PADDING_RIGHT,this.m_struct_obj.padding_right);              // Right margin inside the control
      this.SetProperty(CANV_ELEMENT_PROP_TEXT_ALIGN,this.m_struct_obj.text_align);                    // Text position within text label boundaries
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_ALIGN,this.m_struct_obj.check_align);                  // Position of the checkbox within control borders
      this.SetProperty(CANV_ELEMENT_PROP_CHECKED,this.m_struct_obj.checked);                          // Control checkbox status
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_STATE,this.m_struct_obj.check_state);                  // Status of a control having a checkbox
      this.SetProperty(CANV_ELEMENT_PROP_AUTOCHECK,this.m_struct_obj.autocheck);                      // Auto change flag status when it is selected
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR,this.m_struct_obj.check_background_color);           // Color of control checkbox background
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_OPACITY,this.m_struct_obj.check_background_color_opacity); // Opacity of the control checkbox background color
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_MOUSE_DOWN,this.m_struct_obj.check_background_color_mouse_down);// Color of control checkbox background when clicking on the control
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_BACKGROUND_COLOR_MOUSE_OVER,this.m_struct_obj.check_background_color_mouse_over);// Color of control checkbox background when hovering the mouse over the control
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FORE_COLOR,this.m_struct_obj.check_fore_color);                       // Color of control checkbox frame
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FORE_COLOR_OPACITY,this.m_struct_obj.check_fore_color_opacity);       // Opacity of the control checkbox frame color
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FORE_COLOR_MOUSE_DOWN,this.m_struct_obj.check_fore_color_mouse_down); // Color of control checkbox frame when clicking on the control
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FORE_COLOR_MOUSE_OVER,this.m_struct_obj.check_fore_color_mouse_over); // Color of control checkbox frame when hovering the mouse over the control
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FLAG_COLOR,this.m_struct_obj.check_flag_color);                       // Control checkbox color
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_OPACITY,this.m_struct_obj.check_flag_color_opacity);       // Control checkbox color opacity
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_MOUSE_DOWN,this.m_struct_obj.check_flag_color_mouse_down); // Control checkbox color when clicking on the control
      this.SetProperty(CANV_ELEMENT_PROP_CHECK_FLAG_COLOR_MOUSE_OVER,this.m_struct_obj.check_flag_color_mouse_over); // Control checkbox color when hovering the mouse over the control
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR_MOUSE_DOWN,this.m_struct_obj.fore_color_mouse_down);             // Default control text color when clicking on the control
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR_MOUSE_OVER,this.m_struct_obj.fore_color_mouse_over);             // Default control text color when hovering the mouse over the control
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON,this.m_struct_obj.fore_color_toggle);                   // Text color of the control which is on
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON_MOUSE_DOWN,this.m_struct_obj.fore_color_toggle_mouse_down);// Default control text color when clicking on the control which is on
      this.SetProperty(CANV_ELEMENT_PROP_FORE_COLOR_STATE_ON_MOUSE_OVER,this.m_struct_obj.fore_color_toggle_mouse_over);// Default control text color when hovering the mouse over the control which is on
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON,this.m_struct_obj.background_color_toggle);       // Background color of the control which is on
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON_MOUSE_DOWN,this.m_struct_obj.background_color_toggle_mouse_down);// Control background color when clicking on the control which is on
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_STATE_ON_MOUSE_OVER,this.m_struct_obj.background_color_toggle_mouse_over);// Control background color when clicking on the control which is on
      this.SetProperty(CANV_ELEMENT_PROP_BUTTON_TOGGLE,this.m_struct_obj.button_toggle);                             // Toggle flag of the control featuring a button
      this.SetProperty(CANV_ELEMENT_PROP_BUTTON_STATE,this.m_struct_obj.button_state);                               // Status of the Toggle control featuring a button
      this.SetProperty(CANV_ELEMENT_PROP_BUTTON_GROUP,this.m_struct_obj.button_group_flag);                          // Button group flag
      this.SetProperty(CANV_ELEMENT_PROP_LIST_BOX_MULTI_COLUMN,this.m_struct_obj.multicolumn);                       // Horizontal display of columns in the ListBox control
      this.SetProperty(CANV_ELEMENT_PROP_LIST_BOX_COLUMN_WIDTH,this.m_struct_obj.column_width);                      // Width of each ListBox control column
      this.SetProperty(CANV_ELEMENT_PROP_TAB_MULTILINE,this.m_struct_obj.tab_multiline);                             // Several lines of tabs in TabControl
      this.SetProperty(CANV_ELEMENT_PROP_TAB_ALIGNMENT,this.m_struct_obj.tab_alignment);                             // Location of tabs inside the control
      this.SetProperty(CANV_ELEMENT_PROP_ALIGNMENT,this.m_struct_obj.alignment);                                     // Location of an object inside the control
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_FIXED_PANEL,this.m_struct_obj.split_container_fixed_panel);             // Panel that retains its size when the container is resized
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_FIXED,this.m_struct_obj.split_container_splitter_fixed);       // Separator moveability flag
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_DISTANCE,this.m_struct_obj.split_container_splitter_distance); // Distance from edge to separator
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_WIDTH,this.m_struct_obj.split_container_splitter_width);       // Separator width
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_SPLITTER_ORIENTATION,this.m_struct_obj.split_container_splitter_orientation); // Separator location
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL1_COLLAPSED,this.m_struct_obj.split_container_panel1_collapsed);   // Flag for collapsed panel 1
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL1_MIN_SIZE,this.m_struct_obj.split_container_panel1_min_size);     // Panel 1 minimum size
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL2_COLLAPSED,this.m_struct_obj.split_container_panel2_collapsed);   // Flag for collapsed panel 1
      this.SetProperty(CANV_ELEMENT_PROP_SPLIT_CONTAINER_PANEL2_MIN_SIZE,this.m_struct_obj.split_container_panel2_min_size);     // Panel 2 minimum size
      this.SetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_X,this.m_struct_obj.control_area_x);                        // Control area X coordinate
      this.SetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_Y,this.m_struct_obj.control_area_y);                        // Control area Y coordinate
      this.SetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_WIDTH,this.m_struct_obj.control_area_width);                // Control area width
      this.SetProperty(CANV_ELEMENT_PROP_CONTROL_AREA_HEIGHT,this.m_struct_obj.control_area_height);              // Control area height
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_X_RIGHT,this.m_struct_obj.scroll_area_x_right);              // Right scroll area X coordinate
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_Y_RIGHT,this.m_struct_obj.scroll_area_y_right);              // Right scroll area Y coordinate
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_WIDTH_RIGHT,this.m_struct_obj.scroll_area_width_right);      // Right scroll area width
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_HEIGHT_RIGHT,this.m_struct_obj.scroll_area_height_right);    // Right scroll area height
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_X_BOTTOM,this.m_struct_obj.scroll_area_x_bottom);            // Bottom scroll area X coordinate
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_Y_BOTTOM,this.m_struct_obj.scroll_area_y_bottom);            // Bottom scroll area Y coordinate
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_WIDTH_BOTTOM,this.m_struct_obj.scroll_area_width_bottom);    // Bottom scroll area width
      this.SetProperty(CANV_ELEMENT_PROP_SCROLL_AREA_HEIGHT_BOTTOM,this.m_struct_obj.scroll_area_height_bottom);  // Bottom scroll area height
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_LEFT_AREA_WIDTH,this.m_struct_obj.border_left_area_width);        // Left edge area width
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_BOTTOM_AREA_WIDTH,this.m_struct_obj.border_bottom_area_width);    // Bottom edge area width
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_RIGHT_AREA_WIDTH,this.m_struct_obj.border_right_area_width);      // Right edge area width
      this.SetProperty(CANV_ELEMENT_PROP_BORDER_TOP_AREA_WIDTH,this.m_struct_obj.border_top_area_width);          // Upper edge area width
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_INITIAL_DELAY,this.m_struct_obj.tooltip_initial_delay);             // Tooltip display delay
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_AUTO_POP_DELAY,this.m_struct_obj.tooltip_auto_pop_delay);// Tooltip display duration
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_RESHOW_DELAY,this.m_struct_obj.tooltip_reshow_delay);// One element new tooltip display delay
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_SHOW_ALWAYS,this.m_struct_obj.tooltip_show_always);// Display a tooltip in inactive window
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_ICON,this.m_struct_obj.tooltip_icon);             // Icon displayed in a tooltip
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_IS_BALLOON,this.m_struct_obj.tooltip_is_balloon); // Balloon tooltip
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_USE_FADING,this.m_struct_obj.tooltip_use_fading); // Fade when showing/hiding a tooltip
      this.SetProperty(CANV_ELEMENT_PROP_GROUP,this.m_struct_obj.group);                           // Group the graphical element belongs to
      this.SetProperty(CANV_ELEMENT_PROP_TAB_SIZE_MODE,this.m_struct_obj.tab_size_mode);           // Tab size setting mode
      this.SetProperty(CANV_ELEMENT_PROP_TAB_PAGE_NUMBER,this.m_struct_obj.tab_page_number);       // Tab index number
      this.SetProperty(CANV_ELEMENT_PROP_TAB_PAGE_ROW,this.m_struct_obj.tab_page_row);             // Tab row index
      this.SetProperty(CANV_ELEMENT_PROP_TAB_PAGE_COLUMN,this.m_struct_obj.tab_page_column);       // Tab column index
      this.SetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_MAXIMUM,this.m_struct_obj.progress_bar_maximum);// The upper bound of the range ProgressBar operates in
      this.SetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_MINIMUM,this.m_struct_obj.progress_bar_minimum);// The lower bound of the range ProgressBar operates in
      this.SetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_STEP,this.m_struct_obj.progress_bar_step);   // ProgressBar increment needed to redraw it
      this.SetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_STYLE,this.m_struct_obj.progress_bar_style); // ProgressBar style
      this.SetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_VALUE,this.m_struct_obj.progress_bar_value); // Current ProgressBar value from Min to Max
      this.SetProperty(CANV_ELEMENT_PROP_PROGRESS_BAR_MARQUEE_ANIM_SPEED,this.m_struct_obj.progress_bar_marquee_speed);  // Progress bar animation speed in case of Marquee style
      this.SetProperty(CANV_ELEMENT_PROP_BUTTON_ARROW_SIZE,this.m_struct_obj.button_arrow_size);   // Size of the arrow drawn on the button
      //--- Save real properties

      //--- Save string properties
      this.SetProperty(CANV_ELEMENT_PROP_NAME_OBJ,::CharArrayToString(this.m_struct_obj.name_obj));   // Graphical element object name
      this.SetProperty(CANV_ELEMENT_PROP_NAME_RES,::CharArrayToString(this.m_struct_obj.name_res));   // Graphical resource name
      this.SetProperty(CANV_ELEMENT_PROP_TEXT,::CharArrayToString(this.m_struct_obj.text));           // Graphical element text
      this.SetProperty(CANV_ELEMENT_PROP_DESCRIPTION,::CharArrayToString(this.m_struct_obj.descript));// Graphical element description
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_TITLE,::CharArrayToString(this.m_struct_obj.tooltip_title));// Tooltip title for the element
      this.SetProperty(CANV_ELEMENT_PROP_TOOLTIP_TEXT,::CharArrayToString(this.m_struct_obj.tooltip_text));  // Tooltip text for the element
   }
  //+------------------------------------------------------------------+
  //| Save the object to the file                                      |
  //+------------------------------------------------------------------+
  bool CGCnvElement::Save(const int file_handle)
   {
      if(!this.ObjectToStruct())
      {
         CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_CREATE_OBJ_STRUCT);
         return false;
      }
      ::ResetLastError();
      if(::FileWriteArray(file_handle,this.m_uchar_array)==0)
      {
         CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_WRITE_UARRAY_TO_FILE,true);
         return false;
      }
      return true;
   }
  //+------------------------------------------------------------------+
  //| Upload the object from the file                                  |
  //+------------------------------------------------------------------+
  bool CGCnvElement::Load(const int file_handle)
   {
      ::ResetLastError();
      if(::FileReadArray(file_handle,this.m_uchar_array)==0)
      {
         CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_LOAD_UARRAY_FROM_FILE,true);
         return false;
      }
      if(!::CharArrayToStruct(this.m_struct_obj,this.m_uchar_array))
      {
         CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_CREATE_OBJ_STRUCT_FROM_UARRAY,true);
         return false;
      }
      this.StructToObject();
      return true;
   }
  //+------------------------------------------------------------------+
  //| Create the graphical element object                              |
  //+------------------------------------------------------------------+
  bool CGCnvElement::Create(const long chart_id,     // Chart ID
  const int wnd_num,       // Chart subwindow
  const int x,             // X coordinate
  const int y,             // Y coordinate
  const int w,             // Width
  const int h,             // Height
  const bool redraw=false) // Flag indicating the need to redraw

   {
      ::ResetLastError();
      if(this.m_canvas.CreateBitmapLabel((chart_id==NULL ? ::ChartID() : chart_id),wnd_num,this.m_name,x,y,w,h,COLOR_FORMAT_ARGB_NORMALIZE))
      {
            this.Erase(CLR_CANV_NULL);
            this.m_canvas.Update(redraw);
         this.m_shift_y=(int)::ChartGetInteger((chart_id==NULL ? ::ChartID() : chart_id),CHART_WINDOW_YDISTANCE,wnd_num);
         return true;
      }
      int err=::GetLastError();
      int code=(err==0 ? (w<1 ? MSG_CANV_ELEMENT_ERR_FAILED_SET_WIDTH : h<1 ? MSG_CANV_ELEMENT_ERR_FAILED_SET_HEIGHT : ERR_OBJECT_ERROR) : err);
      string subj=(w<1 ? "Width="+(string)w+". " : h<1 ? "Height="+(string)h+". " : "");
      CMessage::ToLog(DFUN_ERR_LINE+subj,code,true);
      return false;
   }
  //+------------------------------------------------------------------+
  //| Return the number of graphical elements by type                  |
  //+------------------------------------------------------------------+
  int CGCnvElement::GetNumGraphElements(const ENUM_GRAPH_ELEMENT_TYPE type) const
   {
      //--- Declare a variable with the number of graphical objects and
      //--- get the total number of graphical objects on the chart and the subwindow where the graphical element is created
      int n=0, total=::ObjectsTotal(this.ChartID(),this.SubWindow());
      //--- Create the name of a graphical object by its type
      string name=TypeGraphElementAsString(type);
      //--- In the loop by all chart and subwindow objects,
      for(int i=0;i<total;i++)
      {
         //--- get the name of the next object
         string name_obj=::ObjectName(this.ChartID(),i,this.SubWindow());
         //--- if the object name does not contain the set prefix of the names of the library graphical objects, move on - this is not the object we are looking for
         if(::StringFind(name_obj,this.NamePrefix())==WRONG_VALUE)
            continue;
         //--- If the name of a graphical object selected in the loop has a substring with the created object name by its type,
         //--- then there is a graphical object of this type - increase the counter of objects of this type
         if(::StringFind(name_obj,name)>0)
            n++;
      }
      //--- Return the number of found objects by their type
      return n;
   }
  //+------------------------------------------------------------------+
  //| Return the number of graphical elements by name and type         |
  //+------------------------------------------------------------------+
  int CGCnvElement::GetNumGraphElements(const string name,const ENUM_GRAPH_ELEMENT_TYPE type) const
   {
      //--- Declare a variable with the number of graphical objects and
      //--- get the total number of graphical objects on the chart and the subwindow where the graphical element is created
      int n=0, total=::ObjectsTotal(this.ChartID(),this.SubWindow());
      //--- In the loop by all chart and subwindow objects,
      for(int i=0;i<total;i++)
      {
            //--- get the name of the next object
            string name_obj=::ObjectName(this.ChartID(),i,this.SubWindow());
            //--- if the object name does not contain the set prefix of the names of the library graphical objects, move on - this is not the object we are looking for
            if(::StringFind(name_obj,this.NamePrefix())==WRONG_VALUE)
               continue;
            //--- If the name of a graphical object selected in the loop has a substring with the created object name by its type,
            //--- then there is a graphical object of this type - increase the counter of objects of this type
            if(::StringFind(name_obj,name)>0)
               n++;
      }
      //--- Return the number of found objects by their type
      return n;
   }
  //+------------------------------------------------------------------+
  //| Create and return the graphical element name by its type         |
  //+------------------------------------------------------------------+
  string CGCnvElement::CreateNameGraphElement(const ENUM_GRAPH_ELEMENT_TYPE type)
   {
      //--- Create the name of a graphical object by its type
      string name=TypeGraphElementAsString(type);
      //--- Return the prefix + created object name by its type + the total number of objects of this type created by the library on the chart in the subwindow where the graphical element is created
      return this.NamePrefix()+name+(string)this.GetNumGraphElements(name,type);
   }
  //+------------------------------------------------------------------+
  //| Return the cursor position relative to the element               |
  //+------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideElement(const int x,const int y)
   {
      return(x>=this.CoordX() && x<=this.RightEdge() && y>=this.CoordY() && y<=this.BottomEdge());
   }
  //+-----------------------------------------------------------------------------+
  //|Return the position of the cursor relative to the visible area of the element|
  //+-----------------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideVisibleArea(const int x,const int y)
   {
      return(x>=this.CoordXVisibleArea() && x<=this.RightEdgeVisibleArea() && y>=this.CoordYVisibleArea() && y<=this.BottomEdgeVisibleArea());
   }
  //+------------------------------------------------------------------+
  //| Return the cursor position relative to the element active area   |
  //+------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideActiveArea(const int x,const int y)
   {
      return(x>=this.ActiveAreaLeft() && x<=this.ActiveAreaRight() && y>=this.ActiveAreaTop() && y<=this.ActiveAreaBottom());
   }
  //+------------------------------------------------------------------+
  //|Return the cursor position relative to the element control area   |
  //+------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideControlArea(const int x,const int y)
   {
      return(x>=this.ControlAreaLeft() && x<=this.ControlAreaRight() && y>=this.ControlAreaTop() && y<=this.ControlAreaBottom());
   }
  //+------------------------------------------------------------------+
  //| Return the cursor position relative to the                       |
  //| element right scrolling area                                     |
  //+------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideScrollRightArea(const int x,const int y)
   {
      return(x>=this.ScrollAreaRightLeft() && x<=this.ScrollAreaRightRight() && y>=this.ScrollAreaRightTop() && y<=this.ScrollAreaRightBottom());
   }
  //+------------------------------------------------------------------+
  //| Return the cursor position relative to the                       |
  //| element bottom scrolling area                                    |
  //+------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideScrollBottomArea(const int x,const int y)
   {
      return(x>=this.ScrollAreaBottomLeft() && x<=this.ScrollAreaBottomRight() && y>=this.ScrollAreaBottomTop() && y<=this.ScrollAreaBottomBottom());
   }
  //+------------------------------------------------------------------+
  //| Return the cursor position relative to the                       |
  //| element resize upper area                                        |
  //+------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideResizeTopArea(const int x,const int y)
   {
      return(x>=this.CoordX()+DEF_CONTROL_CORNER_AREA && x<=this.RightEdge()-DEF_CONTROL_CORNER_AREA && y>=this.CoordY() && y<=this.CoordY()+this.BorderResizeAreaTop());
   }
  //+------------------------------------------------------------------+
  //| Return the cursor position relative to the                       |
  //| element resize lower area                                        |
  //+------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideResizeBottomArea(const int x,const int y)
   {
      return(x>=this.CoordX()+DEF_CONTROL_CORNER_AREA && x<=this.RightEdge()-DEF_CONTROL_CORNER_AREA && y>=this.BottomEdge()-this.BorderResizeAreaBottom() && y<=this.BottomEdge());
   }
  //+------------------------------------------------------------------+
  //| Return the cursor position relative to the                       |
  //| element resize left area                                         |
  //+------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideResizeLeftArea(const int x,const int y)
   {
      return(x>=this.CoordX() && x<=this.CoordX()+this.BorderResizeAreaLeft() && y>=this.CoordY()+DEF_CONTROL_CORNER_AREA && y<=this.BottomEdge()-DEF_CONTROL_CORNER_AREA);
   }
  //+------------------------------------------------------------------+
  //| Return the cursor position relative to the                       |
  //| element resize right area                                        |
  //+------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideResizeRightArea(const int x,const int y)
   {
      return(x>=this.RightEdge()-this.BorderResizeAreaRight() && x<=this.RightEdge() && y>=this.CoordY()+DEF_CONTROL_CORNER_AREA && y<=this.BottomEdge()-DEF_CONTROL_CORNER_AREA);
   }
  //+------------------------------------------------------------------+
  //| Return the cursor position relative to the                       |
  //| element resize area upper left corner                            |
  //+------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideResizeTopLeftArea(const int x,const int y)
   {
      return
      (
      (x>=this.CoordX() && x<this.CoordX()+DEF_CONTROL_CORNER_AREA && y>=this.CoordY() && y<=this.CoordY()+this.BorderResizeAreaTop()) ||
      (x>=this.CoordX() && x<=this.BorderResizeAreaLeft() && y>=this.CoordY() && y<=this.CoordY()+DEF_CONTROL_CORNER_AREA)
      );
   }
  //+------------------------------------------------------------------+
  //| Return the cursor position relative to the                       |
  //| element resize area upper right corner                           |
  //+------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideResizeTopRightArea(const int x,const int y)
   {
      return
      (
      (x>this.RightEdge()-DEF_CONTROL_CORNER_AREA && x<=this.RightEdge() && y>=this.CoordY() && y<=this.CoordY()+this.BorderResizeAreaTop()) ||
      (x>=this.RightEdge()-this.BorderResizeAreaRight() && x<=this.RightEdge() && y>=this.CoordY() && y<=this.CoordY()+DEF_CONTROL_CORNER_AREA)
      );
   }
  //+------------------------------------------------------------------+
  //| Return the cursor position relative to the                       |
  //| element resize area lower left corner                            |
  //+------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideResizeBottomLeftArea(const int x,const int y)
   {
      return
      (
      (x>=this.CoordX() && x<this.CoordX()+DEF_CONTROL_CORNER_AREA && y>=this.BottomEdge()-this.BorderResizeAreaBottom() && y<=this.BottomEdge()) ||
      (x>=this.CoordX() && x<=this.CoordX()+this.BorderResizeAreaLeft() && y>this.BottomEdge()-DEF_CONTROL_CORNER_AREA && y<=this.BottomEdge())
      );
   }
  //+------------------------------------------------------------------+
  //| Return the cursor position relative to the                       |
  //| element resize area lower right corner                           |
  //+------------------------------------------------------------------+
  bool CGCnvElement::CursorInsideResizeBottomRightArea(const int x,const int y)
   {
      return
      (
      (x>this.RightEdge()-DEF_CONTROL_CORNER_AREA && x<=this.RightEdge() && y>=this.BottomEdge()-this.BorderResizeAreaBottom() && y<=this.BottomEdge()) ||
      (x>=this.RightEdge()-this.BorderResizeAreaRight() && x<=this.RightEdge() && y>this.BottomEdge()-DEF_CONTROL_CORNER_AREA && y<=this.BottomEdge())
      );
   }
  //+------------------------------------------------------------------+
  //| Update the coordinate elements                                   |
  //+------------------------------------------------------------------+
  bool CGCnvElement::Move(const int x,const int y,const bool redraw=false)
   {
      //--- If failed to set new values into graphical object properties, return 'false'
      if(!this.SetCoordX(x) || !this.SetCoordY(y))
      return false;
      //--- If the update flag is activated, redraw the chart.
      if(redraw)
      ::ChartRedraw(this.ChartID());
      //--- Return 'true'
      return true;
   }
  //+------------------------------------------------------------------+
  //| Set the new X coordinate                                         |
  //+------------------------------------------------------------------+
  bool CGCnvElement::SetCoordX(const int coord_x)
   {
      int x=(int)::ObjectGetInteger(this.ChartID(),this.NameObj(),OBJPROP_XDISTANCE);
      if(coord_x==x)
      {
         if(coord_x==this.GetProperty(CANV_ELEMENT_PROP_COORD_X))
            return true;
         this.SetProperty(CANV_ELEMENT_PROP_COORD_X,coord_x);
         this.SetRightEdge();
         return true;
      }
      if(::ObjectSetInteger(this.ChartID(),this.NameObj(),OBJPROP_XDISTANCE,coord_x))
      {
         this.SetProperty(CANV_ELEMENT_PROP_COORD_X,coord_x);
         this.SetRightEdge();
         return true;
      }
      return false;
   }
  //+------------------------------------------------------------------+
  //| Set the new Y coordinate                                         |
  //+------------------------------------------------------------------+
  bool CGCnvElement::SetCoordY(const int coord_y)
   {
      int y=(int)::ObjectGetInteger(this.ChartID(),this.NameObj(),OBJPROP_YDISTANCE);
      if(coord_y==y)
      {
         if(coord_y==this.GetProperty(CANV_ELEMENT_PROP_COORD_Y))
            return true;
         this.SetProperty(CANV_ELEMENT_PROP_COORD_Y,coord_y);
         this.SetBottomEdge();
         return true;
      }
      if(::ObjectSetInteger(this.ChartID(),this.NameObj(),OBJPROP_YDISTANCE,coord_y))
      {
         this.SetProperty(CANV_ELEMENT_PROP_COORD_Y,coord_y);
         this.SetBottomEdge();
         return true;
      }
      return false;
   }
  //+------------------------------------------------------------------+
  //| Set the new width                                                |
  //+------------------------------------------------------------------+
  bool CGCnvElement::SetWidth(const int width)
   {
      if(this.GetProperty(CANV_ELEMENT_PROP_WIDTH)==width)
      return true;
      if(!this.m_canvas.Resize(width,this.m_canvas.Height()))
      {
      CMessage::ToLog(DFUN+this.TypeElementDescription()+": width="+(string)width+": ",MSG_CANV_ELEMENT_ERR_FAILED_SET_WIDTH);
      return false;
      }
      this.SetProperty(CANV_ELEMENT_PROP_WIDTH,width);
      this.SetVisibleAreaX(0,true);
      this.SetVisibleAreaWidth(width,true);
      this.SetRightEdge();
      return true;
   }
  //+------------------------------------------------------------------+
  //| Set the new height                                               |
  //+------------------------------------------------------------------+
  bool CGCnvElement::SetHeight(const int height)
   {
      if(this.GetProperty(CANV_ELEMENT_PROP_HEIGHT)==height)
      return true;
      if(!this.m_canvas.Resize(this.m_canvas.Width(),height))
      {
         CMessage::ToLog(DFUN+this.TypeElementDescription()+": height="+(string)height+": ",MSG_CANV_ELEMENT_ERR_FAILED_SET_HEIGHT);
         return false;
      }
      this.SetProperty(CANV_ELEMENT_PROP_HEIGHT,height);
      this.SetVisibleAreaY(0,true);
      this.SetVisibleAreaHeight(height,true);
      this.SetBottomEdge();
      return true;
   }
  //+------------------------------------------------------------------+
  //| Set all shifts of the active area relative to the element        |
  //+------------------------------------------------------------------+
  void CGCnvElement::SetActiveAreaShift(const int left_shift,const int bottom_shift,const int right_shift,const int top_shift)
   {
      this.SetActiveAreaLeftShift(left_shift);
      this.SetActiveAreaBottomShift(bottom_shift);
      this.SetActiveAreaRightShift(right_shift);
      this.SetActiveAreaTopShift(top_shift);
   }
  //+------------------------------------------------------------------+
  //| Set the element opacity                                          |
  //+------------------------------------------------------------------+
  void CGCnvElement::SetOpacity(const uchar value,const bool redraw=false)
   {
      this.SetProperty(CANV_ELEMENT_PROP_BACKGROUND_COLOR_OPACITY,value);
      this.m_canvas.TransparentLevelSet(value);
      this.m_canvas.Update(redraw);
   }
  //+------------------------------------------------------------------+
  //| Clear the element filling it with color and opacity              |
  //+------------------------------------------------------------------+
  void CGCnvElement::Erase(const color colour,const uchar opacity,const bool redraw=false)
   {
      this.EraseNoCrop(colour,opacity,false);
      this.Crop();
      this.Update(redraw);
   }
  //+------------------------------------------------------------------+
  //| Clear the element with a gradient fill                           |
  //+------------------------------------------------------------------+
  void CGCnvElement::Erase(color &colors[],const uchar opacity,const bool vgradient,const bool cycle,const bool redraw=false)
   {
      this.EraseNoCrop(colors,opacity,vgradient,cycle,false);
      this.Crop();
      //--- If specified, update the canvas
      this.Update(redraw);
   }
  //+------------------------------------------------------------------+
  //| Clear the element completely                                     |
  //+------------------------------------------------------------------+
  void CGCnvElement::Erase(const bool redraw=false)
   {
      this.m_canvas.Erase(CLR_CANV_NULL);
      this.Update(redraw);
   }
  //+------------------------------------------------------------------+
  //| Clear the element filling it with color and opacity              |
  //| without cropping and with the chart update by flag               |
  //+------------------------------------------------------------------+
  void CGCnvElement::EraseNoCrop(const color colour,const uchar opacity,const bool redraw=false)
   {
      color arr[1];
      arr[0]=colour;
      this.SaveColorsBG(arr);
      this.m_canvas.Erase(::ColorToARGB(colour,opacity));
      if(redraw)
      this.Update(redraw);
   }
  //+------------------------------------------------------------------+
  //| Clear the element with a gradient fill without cropping          |
  //| but with updating the chart by flag                              |
  //+------------------------------------------------------------------+
  void CGCnvElement::EraseNoCrop(color &colors[],const uchar opacity,const bool vgradient,const bool cycle,const bool redraw=false)
   {
      //--- Set the vertical and cyclic gradient filling flags
      this.m_gradient_v=vgradient;
      this.m_gradient_c=cycle;
      //--- Check the size of the color array
      int size=::ArraySize(colors);
      //--- If there are less than two colors in the array
      if(size<2)
      {
      //--- if the array is empty, erase the background completely and leave
      if(size==0)
      {
         this.Erase(redraw);
         return;
      }
      //--- in case of one color, fill the background with this color and opacity, and leave
      this.EraseNoCrop(colors[0],opacity,redraw);
      return;
      }
      //--- Declare the receiver array
      color out[];
      //--- Set the gradient size depending on the filling direction (vertical/horizontal)
      int total=(vgradient ? this.Height() : this.Width());
      //--- and get the set of colors in the receiver array
      CColors::Gradient(colors,out,total,cycle);
      total=::ArraySize(out);
      //--- In the loop by the number of colors in the array
      for(int i=0;i<total;i++)
      {
      //--- depending on the filling direction
      switch(vgradient)
      {
         //--- Horizontal gradient - draw vertical segments from left to right with the color from the array
         case false :
            DrawLineVertical(i,0,this.Height()-1,out[i],opacity);
           break;
         //--- Vertical gradient - draw horizontal segments downwards with the color from the array
         default:
            DrawLineHorizontal(0,this.Width()-1,i,out[i],opacity);
           break;
      }
      }
      //--- Save the background color array
      this.SaveColorsBG(colors);
      this.Update(redraw);
   }
  //+--------------------------------------------------------------------+
  //| Crop the image outlined by a specified rectangular visibility scope|
  //+--------------------------------------------------------------------+
  void CGCnvElement::Crop(const uint coord_x,const uint coord_y,const uint width,const uint height)
   {
      //--- If the passed coordinates and the size of the visibility scope match the size of the object, leave
      if(coord_x==0 && coord_y==0 && width==this.Width() && height==this.Height())
      return;
      //--- Set the coordinates and size of the visibility scope in the object properties
      this.SetVisibleAreaX(coord_x,true);
      this.SetVisibleAreaY(coord_y,true);
      this.SetVisibleAreaWidth(width,true);
      this.SetVisibleAreaHeight(height,true);
      //--- If the object in the current state has not yet been saved,
      //--- save its bitmap to the array for subsequent restoration
      if(::ArraySize(this.m_duplicate_res)==0)
      this.ResourceStamp(DFUN);
      //--- In the loop through the image lines of the graphical object
      for(int y=0;y<this.Height();y++)
      {
      //--- go through each pixel of the current line
      for(int x=0;x<this.Width();x++)
      {
         //--- If the string and its pixel are in the visibility scope, skip the pixel
         if(y>=this.VisibleAreaY() && y<=this.BottomEdgeVisibleAreaRelative() && x>=this.VisibleAreaX() && x<=this.RightEdgeVisibleAreaRelative())
            continue;
         //--- If the line pixel is outside the visibility scope, set a transparent color for it
         this.SetPixel(x,y,CLR_CANV_NULL,0);
      }
      }
      this.Update(true);
   }
  //+------------------------------------------------------------------+
  //| Crop the image outlined by the calculated                        |
  //| rectangular visibility scope                                     |
  //+------------------------------------------------------------------+
  void CGCnvElement::Crop(void)
   {
      //--- Get the pointer to the base object
      CGCnvElement *base=this.GetBase();
      //--- If the object does not have a base object it is attached to, then there is no need to crop the hidden areas - leave
      if(!this.IsDependent())
      return;
      //--- Set the initial coordinates and size of the visibility scope to the entire object
      int vis_x=0;
      int vis_y=0;
      int vis_w=this.Width();
      int vis_h=this.Height();
      //--- Set the size of the top, bottom, left and right areas that go beyond the container
      int crop_top=0;
      int crop_bottom=0;
      int crop_left=0;
      int crop_right=0;
      //--- Calculate the boundaries of the container area, inside which the object is fully visible
      int top=fmax(base.CoordY()+(int)base.GetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_TOP),base.CoordYVisibleArea());
      int bottom=fmin(base.BottomEdge()-(int)base.GetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_BOTTOM),base.BottomEdgeVisibleArea()+1);
      int left=fmax(base.CoordX()+(int)base.GetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_LEFT),base.CoordXVisibleArea());
      int right=fmin(base.RightEdge()-(int)base.GetProperty(CANV_ELEMENT_PROP_BORDER_SIZE_RIGHT),base.RightEdgeVisibleArea()+1);
      //--- Calculate the values of the top, bottom, left and right areas, at which the object goes beyond
      //--- the boundaries of the container area, inside which the object is fully visible
      crop_top=this.CoordY()-top;
      if(crop_top<0)
      vis_y=-crop_top;
      crop_bottom=bottom-this.BottomEdge()-1;
      if(crop_bottom<0)
      vis_h=this.Height()+crop_bottom-vis_y;
      crop_left=this.CoordX()-left;
      if(crop_left<0)
      vis_x=-crop_left;
      crop_right=right-this.RightEdge()-1;
      if(crop_right<0)
      vis_w=this.Width()+crop_right-vis_x;
      //--- If there are areas that need to be hidden, call the cropping method with the calculated size of the object visibility scope
      if(crop_top<0 || crop_bottom<0 || crop_left<0 || crop_right<0)
      this.Crop(vis_x,vis_y,vis_w,vis_h);
   }
  //+------------------------------------------------------------------+
  //| Change the ARGB color lightness by the specified amount          |
  //+------------------------------------------------------------------+
  uint CGCnvElement::ChangeColorLightness(const uint clr,const double change_value)
   {
      if(change_value==0.0)
      return clr;
      double a=GETRGBA(clr);
      double r=GETRGBR(clr);
      double g=GETRGBG(clr);
      double b=GETRGBB(clr);
      double h=0,s=0,l=0;
      CColors::RGBtoHSL(r,g,b,h,s,l);
      double nl=l+change_value*0.01;
      if(nl>1.0) nl=1.0;
      if(nl<0.0) nl=0.0;
      CColors::HSLtoRGB(h,s,nl,r,g,b);
      return ARGB(a,r,g,b);
   }
  //+------------------------------------------------------------------+
  //| Change the COLOR lightness by the specified amount               |
  //+------------------------------------------------------------------+
  color CGCnvElement::ChangeColorLightness(const color colour,const double change_value)
   {
      if(change_value==0.0)
      return colour;
      uint clr=::ColorToARGB(colour,0);
      double r=GETRGBR(clr);
      double g=GETRGBG(clr);
      double b=GETRGBB(clr);
      double h=0,s=0,l=0;
      CColors::RGBtoHSL(r,g,b,h,s,l);
      double nl=l+change_value*0.01;
      if(nl>1.0) nl=1.0;
      if(nl<0.0) nl=0.0;
      CColors::HSLtoRGB(h,s,nl,r,g,b);
      return CColors::RGBToColor(r,g,b);
   }
  //+------------------------------------------------------------------+
  //| Change the ARGB color saturation by a specified amount           |
  //+------------------------------------------------------------------+
  uint CGCnvElement::ChangeColorSaturation(const uint clr,const double change_value)
   {
      if(change_value==0.0)
      return clr;
      double a=GETRGBA(clr);
      double r=GETRGBR(clr);
      double g=GETRGBG(clr);
      double b=GETRGBB(clr);
      double h=0,s=0,l=0;
      CColors::RGBtoHSL(r,g,b,h,s,l);
      double ns=s+change_value*0.01;
      if(ns>1.0) ns=1.0;
      if(ns<0.0) ns=0.0;
      CColors::HSLtoRGB(h,ns,l,r,g,b);
      return ARGB(a,r,g,b);
   }
  //+------------------------------------------------------------------+
  //| Change the COLOR saturation by a specified amount                |
  //+------------------------------------------------------------------+
  color CGCnvElement::ChangeColorSaturation(const color colour,const double change_value)
   {
      if(change_value==0.0)
      return colour;
      uint clr=::ColorToARGB(colour,0);
      double r=GETRGBR(clr);
      double g=GETRGBG(clr);
      double b=GETRGBB(clr);
      double h=0,s=0,l=0;
      CColors::RGBtoHSL(r,g,b,h,s,l);
      double ns=s+change_value*0.01;
      if(ns>1.0) ns=1.0;
      if(ns<0.0) ns=0.0;
      CColors::HSLtoRGB(h,ns,l,r,g,b);
      return CColors::RGBToColor(r,g,b);
   }
  //+------------------------------------------------------------------+
  //| Change the color component of RGB-Color                          |
  //+------------------------------------------------------------------+
  color CGCnvElement::ChangeRGBComponents(color clr,const uchar R,const uchar G,const uchar B)
   {
      double r=CColors::GetR(clr)+R;
      if(r>255)
      r=255;
      double g=CColors::GetG(clr)+G;
      if(g>255)
      g=255;
      double b=CColors::GetB(clr)+B;
      if(b>255)
      b=255;
      return CColors::RGBToColor(r,g,b);
   }
  //+------------------------------------------------------------------+
  //| Save the image to the array                                      |
  //+------------------------------------------------------------------+
  bool CGCnvElement::ImageCopy(const string source,uint &array[])
   {
      ::ResetLastError();
      uint w=0,h=0;
      if(!::ResourceReadImage(this.NameRes(),array,w,h))
      {
      CMessage::ToLog(source,MSG_LIB_SYS_FAILED_GET_DATA_GRAPH_RES,true);
      return false;
      }
      return true;
   }
  //+------------------------------------------------------------------+
  //| Save the graphical resource to the array                         |
  //+------------------------------------------------------------------+
  bool CGCnvElement::ResourceStamp(const string source)
   {
      return this.ImageCopy(DFUN,this.m_duplicate_res);
   }
  //+------------------------------------------------------------------+
  //| Restore the graphical resource from the array                    |
  //+------------------------------------------------------------------+
  bool CGCnvElement::Reset(void)
   {
      //--- Get the size of the graphical resource copy array
      int size=::ArraySize(this.m_duplicate_res);
      //--- If the array is empty, inform of that and return 'false'
      if(size==0)
      {
      CMessage::ToLog(DFUN,MSG_CANV_ELEMENT_ERR_EMPTY_ARRAY);
      return false;
      }
      //--- If the size of the graphical resource copy array does not match the size of the graphical resource,
      //--- inform of that in the journal and return 'false'
      if(this.m_canvas.Width()*this.m_canvas.Height()!=size)
      {
      CMessage::ToLog(DFUN,MSG_CANV_ELEMENT_ERR_ARRAYS_NOT_MATCH);
      return false;
      }
      //--- Set the index of the array for setting the image pixel
      int n=0;
      //--- In the loop by the resource height,
      for(int y=0;y<this.m_canvas.Height();y++)
      {
      //--- in the loop by the resource width
      for(int x=0;x<this.m_canvas.Width();x++)
      {
         //--- Restore the next image pixel from the array and increase the array index
         this.m_canvas.PixelSet(x,y,this.m_duplicate_res[n]);
         n++;
      }
      }
      //--- Update the data on the canvas and return 'true'
      this.m_canvas.Update(false);
      return true;
   }
  //+------------------------------------------------------------------+
  //| Return coordinate offsets relative to the rectangle anchor point |
  //| by size                                                          |
  //+------------------------------------------------------------------+
  void CGCnvElement::GetShiftXYbySize(const int width,const int height,const ENUM_FRAME_ANCHOR anchor,int &shift_x,int &shift_y)
   {
      switch(anchor)
      {
      case FRAME_ANCHOR_LEFT_TOP       :  shift_x=0;        shift_y=0;           break;
      case FRAME_ANCHOR_LEFT_CENTER    :  shift_x=0;        shift_y=-height/2;   break;
      case FRAME_ANCHOR_LEFT_BOTTOM    :  shift_x=0;        shift_y=-height;     break;
      case FRAME_ANCHOR_CENTER_TOP     :  shift_x=-width/2; shift_y=0;           break;
      case FRAME_ANCHOR_CENTER         :  shift_x=-width/2; shift_y=-height/2;   break;
      case FRAME_ANCHOR_CENTER_BOTTOM  :  shift_x=-width/2; shift_y=-height;     break;
      case FRAME_ANCHOR_RIGHT_TOP      :  shift_x=-width;   shift_y=0;           break;
      case FRAME_ANCHOR_RIGHT_CENTER   :  shift_x=-width;   shift_y=-height/2;   break;
      case FRAME_ANCHOR_RIGHT_BOTTOM   :  shift_x=-width;   shift_y=-height;     break;
      default                          :  shift_x=0;        shift_y=0;           break;
      }
   }
  //+------------------------------------------------------------------+
  //| Return coordinate offsets relative to the text anchor point      |
  //+------------------------------------------------------------------+
  void CGCnvElement::GetShiftXYbyText(const string text,const ENUM_FRAME_ANCHOR anchor,int &shift_x,int &shift_y)
   {
      int tw=0,th=0;
      this.TextSize(text,tw,th);
      this.GetShiftXYbySize(tw,th,anchor,shift_x,shift_y);
   }
  //+------------------------------------------------------------------+
  //| Event handler                                                    |
  //+------------------------------------------------------------------+
  void CGCnvElement::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
   {
      //--- In case of a chart change event, recalculate the shift by Y for the subwindow
      if(id==CHARTEVENT_CHART_CHANGE)
      {
      this.m_shift_y=(int)::ChartGetInteger(this.ChartID(),CHART_WINDOW_YDISTANCE,this.WindowNum());
      }
   }
  //+------------------------------------------------------------------+
  //| Copy the color array to the specified background color array     |
  //+------------------------------------------------------------------+
  void CGCnvElement::CopyArraysColors(color &array_dst[],const color &array_src[],const string source)
   {
      if(array_dst.Size()!=array_src.Size())
      {
      ::ResetLastError();
      if(::ArrayResize(array_dst,array_src.Size())!=array_src.Size())
      {
         CMessage::ToLog(source,MSG_LIB_SYS_FAILED_COLORS_ARRAY_RESIZE);
         CMessage::ToLog(::GetLastError(),true);
         return;
      }
      }
      ::ArrayCopy(array_dst,array_src);
   }
  //+------------------------------------------------------------------+
  //| Gaussian blur                                                    |
  //| https://www.mql5.com/en/articles/1612#chapter4                   |
  //+------------------------------------------------------------------+
  bool CGCnvElement::GaussianBlur(const uint radius)
   {
      //---
      int n_nodes=(int)radius*2+1;
      //--- Read graphical resource data. If failed, return false
      if(!CGCnvElement::ResourceStamp(DFUN))
      return false;
      //--- Check the blur amount. If the blur radius exceeds half of the width or height, return 'false'
      if((int)radius>=this.Width()/2 || (int)radius>=this.Height()/2)
      {
      ::Print(DFUN,CMessage::Text(MSG_SHADOW_OBJ_IMG_SMALL_BLUR_LARGE));
      return false;
      }

      //--- Decompose image data from the resource into a, r, g, b color components
      int  size=::ArraySize(this.m_duplicate_res);
      //--- arrays for storing A, R, G and B color components
      //--- for horizontal and vertical blur
      uchar a_h_data[],r_h_data[],g_h_data[],b_h_data[];
      uchar a_v_data[],r_v_data[],g_v_data[],b_v_data[];

      //--- Change the size of component arrays according to the array size of the graphical resource data
      if(::ArrayResize(a_h_data,size)==-1)
      {
      CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_ARRAY_RESIZE);
      ::Print(DFUN_ERR_LINE,": \"a_h_data\"");
      return false;
      }
      if(::ArrayResize(r_h_data,size)==-1)
      {
      CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_ARRAY_RESIZE);
      ::Print(DFUN_ERR_LINE,": \"r_h_data\"");
      return false;
      }
      if(::ArrayResize(g_h_data,size)==-1)
      {
      CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_ARRAY_RESIZE);
      ::Print(DFUN_ERR_LINE,": \"g_h_data\"");
      return false;
      }
      if(ArrayResize(b_h_data,size)==-1)
      {
      CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_ARRAY_RESIZE);
      ::Print(DFUN_ERR_LINE,": \"b_h_data\"");
      return false;
      }
      if(::ArrayResize(a_v_data,size)==-1)
      {
      CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_ARRAY_RESIZE);
      ::Print(DFUN_ERR_LINE,": \"a_v_data\"");
      return false;
      }
      if(::ArrayResize(r_v_data,size)==-1)
      {
      CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_ARRAY_RESIZE);
      ::Print(DFUN_ERR_LINE,": \"r_v_data\"");
      return false;
      }
      if(::ArrayResize(g_v_data,size)==-1)
      {
      CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_ARRAY_RESIZE);
      ::Print(DFUN_ERR_LINE,": \"g_v_data\"");
      return false;
      }
      if(::ArrayResize(b_v_data,size)==-1)
      {
      CMessage::ToLog(DFUN,MSG_LIB_SYS_FAILED_ARRAY_RESIZE);
      ::Print(DFUN_ERR_LINE,": \"b_v_data\"");
      return false;
      }
      //--- Declare the array for storing blur weight ratios and,
      //--- if failed to get the array of weight ratios, return 'false'
      double weights[];
      if(!this.GetQuadratureWeights(1,n_nodes,weights))
      return false;

      //--- Set components of each image pixel to the color component arrays
      for(int i=0;i<size;i++)
      {
      a_h_data[i]=GETRGBA(this.m_duplicate_res[i]);
      r_h_data[i]=GETRGBR(this.m_duplicate_res[i]);
      g_h_data[i]=GETRGBG(this.m_duplicate_res[i]);
      b_h_data[i]=GETRGBB(this.m_duplicate_res[i]);
      }

      //--- Blur the image horizontally (along the X axis)
      uint XY; // Pixel coordinate in the array
      double a_temp=0.0,r_temp=0.0,g_temp=0.0,b_temp=0.0;
      int coef=0;
      int j=(int)radius;
      //--- Loop by the image width
      for(int Y=0;Y<this.Height();Y++)
      {
      //--- Loop by the image height
      for(uint X=radius;X<this.Width()-radius;X++)
      {
         XY=Y*this.Width()+X;
         a_temp=0.0; r_temp=0.0; g_temp=0.0; b_temp=0.0;
         coef=0;
         //--- Multiply each color component by the weight ratio corresponding to the current image pixel
         for(int i=-1*j;i<j+1;i=i+1)
      {
            a_temp+=a_h_data[XY+i]*weights[coef];
            r_temp+=r_h_data[XY+i]*weights[coef];
            g_temp+=g_h_data[XY+i]*weights[coef];
            b_temp+=b_h_data[XY+i]*weights[coef];
            coef++;
      }
         //--- Save each rounded color component calculated according to the ratios to the component arrays
         a_h_data[XY]=(uchar)::round(a_temp);
         r_h_data[XY]=(uchar)::round(r_temp);
         g_h_data[XY]=(uchar)::round(g_temp);
         b_h_data[XY]=(uchar)::round(b_temp);
      }
      //--- Remove blur artifacts to the left by copying adjacent pixels
      for(uint x=0;x<radius;x++)
      {
         XY=Y*this.Width()+x;
         a_h_data[XY]=a_h_data[Y*this.Width()+radius];
         r_h_data[XY]=r_h_data[Y*this.Width()+radius];
         g_h_data[XY]=g_h_data[Y*this.Width()+radius];
         b_h_data[XY]=b_h_data[Y*this.Width()+radius];
      }
      //--- Remove blur artifacts to the right by copying adjacent pixels
      for(int x=int(this.Width()-radius);x<this.Width();x++)
      {
         XY=Y*this.Width()+x;
         a_h_data[XY]=a_h_data[(Y+1)*this.Width()-radius-1];
         r_h_data[XY]=r_h_data[(Y+1)*this.Width()-radius-1];
         g_h_data[XY]=g_h_data[(Y+1)*this.Width()-radius-1];
         b_h_data[XY]=b_h_data[(Y+1)*this.Width()-radius-1];
      }
      }

      //--- Blur vertically (along the Y axis) the image already blurred horizontally
      int dxdy=0;
      //--- Loop by the image height
      for(int X=0;X<this.Width();X++)
      {
      //--- Loop by the image width
      for(uint Y=radius;Y<this.Height()-radius;Y++)
      {
         XY=Y*this.Width()+X;
         a_temp=0.0; r_temp=0.0; g_temp=0.0; b_temp=0.0;
         coef=0;
         //--- Multiply each color component by the weight ratio corresponding to the current image pixel
         for(int i=-1*j;i<j+1;i=i+1)
      {
            dxdy=i*(int)this.Width();
            a_temp+=a_h_data[XY+dxdy]*weights[coef];
            r_temp+=r_h_data[XY+dxdy]*weights[coef];
            g_temp+=g_h_data[XY+dxdy]*weights[coef];
            b_temp+=b_h_data[XY+dxdy]*weights[coef];
            coef++;
      }
         //--- Save each rounded color component calculated according to the ratios to the component arrays
         a_v_data[XY]=(uchar)::round(a_temp);
         r_v_data[XY]=(uchar)::round(r_temp);
         g_v_data[XY]=(uchar)::round(g_temp);
         b_v_data[XY]=(uchar)::round(b_temp);
      }
      //--- Remove blur artifacts at the top by copying adjacent pixels
      for(uint y=0;y<radius;y++)
      {
         XY=y*this.Width()+X;
         a_v_data[XY]=a_v_data[X+radius*this.Width()];
         r_v_data[XY]=r_v_data[X+radius*this.Width()];
         g_v_data[XY]=g_v_data[X+radius*this.Width()];
         b_v_data[XY]=b_v_data[X+radius*this.Width()];
      }
      //--- Remove blur artifacts at the bottom by copying adjacent pixels
      for(int y=int(this.Height()-radius);y<this.Height();y++)
      {
         XY=y*this.Width()+X;
         a_v_data[XY]=a_v_data[X+(this.Height()-1-radius)*this.Width()];
         r_v_data[XY]=r_v_data[X+(this.Height()-1-radius)*this.Width()];
         g_v_data[XY]=g_v_data[X+(this.Height()-1-radius)*this.Width()];
         b_v_data[XY]=b_v_data[X+(this.Height()-1-radius)*this.Width()];
      }
      }

      //--- Set the twice blurred (horizontally and vertically) image pixels to the graphical resource data array
      for(int i=0;i<size;i++)
      this.m_duplicate_res[i]=ARGB(a_v_data[i],r_v_data[i],g_v_data[i],b_v_data[i]);
      //--- Display the image pixels on the canvas in a loop by the image height and width from the graphical resource data array
      for(int X=0;X<this.Width();X++)
      {
      for(uint Y=radius;Y<this.Height()-radius;Y++)
      {
         XY=Y*this.Width()+X;
         this.m_canvas.PixelSet(X,Y,this.m_duplicate_res[XY]);
      }
      }
      //--- Done
      return true;
   }
  //+------------------------------------------------------------------+
  //| Return the array of weight ratios                                |
  //| https://www.mql5.com/en/articles/1612#chapter3_2                 |
  //+------------------------------------------------------------------+
  bool CGCnvElement::GetQuadratureWeights(const double mu0,const int n,double &weights[])
   {
      CAlglib alglib;
      double  alp[];
      double  bet[];
      ::ArrayResize(alp,n);
      ::ArrayResize(bet,n);
      ::ArrayInitialize(alp,1.0);
      ::ArrayInitialize(bet,1.0);
      //---
      double out_x[];
      int    info=0;
      alglib.GQGenerateRec(alp,bet,mu0,n,info,out_x,weights);
      if(info!=1)
      {
      string txt=(info==-3 ? "internal eigenproblem solver hasn't converged" : info==-2 ? "Beta[i]<=0" : "incorrect N was passed");
      ::Print("Call error in CGaussQ::GQGenerateRec: ",txt);
      return false;
      }
      return true;
   }
  //+------------------------------------------------------------------+
  //| Draw the Info icon                                               |
  //+------------------------------------------------------------------+
  void CGCnvElement::DrawIconInfo(const int coord_x,const int coord_y,const uchar opacity)
   {
      int x=coord_x+8;
      int y=coord_y+8;
      this.DrawCircleFill(x,y,7,C'0x00,0x77,0xD7',opacity);
      if(opacity>127)
      this.DrawCircleWu(x,y,7.5,C'0x00,0x3D,0x8C',opacity);
      else
      this.DrawCircle(x,y,8,C'0x00,0x3D,0x8C',opacity);
      this.DrawRectangle(x,y-5,x+1,y-4, C'0xFF,0xFF,0xFF',opacity);
      this.DrawRectangle(x,y-2,x+1,y+4,C'0xFF,0xFF,0xFF',opacity);
   }
  //+------------------------------------------------------------------+
  //| Draw the Warning icon                                            |
  //+------------------------------------------------------------------+
  void CGCnvElement::DrawIconWarning(const int coord_x,const int coord_y,const uchar opacity)
   {
      int x=coord_x+8;
      int y=coord_y+1;
      this.DrawTriangleFill(x,y,x+8,y+14,x-8,y+14,C'0xFC,0xE1,0x00',opacity);
      if(opacity>127)
      this.DrawTriangleWu(x,y,x+8,y+14,x-7,y+14,C'0xFF,0xB9,0x00',opacity);
      else
      this.DrawTriangle(x,y,x+8,y+14,x-7,y+14,C'0xFF,0xB9,0x00',opacity);
      this.DrawRectangle(x,y+5,x+1,y+9,  C'0x00,0x00,0x00',opacity);
      this.DrawRectangle(x,y+11,x+1,y+12,C'0x00,0x00,0x00',opacity);
   }
  //+------------------------------------------------------------------+
  //| Draw the Error icon                                              |
  //+------------------------------------------------------------------+
  void CGCnvElement::DrawIconError(const int coord_x,const int coord_y,const uchar opacity)
   {
      int x=coord_x+8;
      int y=coord_y+8;
      this.DrawCircleFill(x,y,7,C'0xF0,0x39,0x16',opacity);
      if(opacity>127)
      {
      this.DrawCircleWu(x,y,7.5,C'0xA5,0x25,0x12',opacity);
      this.DrawLineWu(x-3,y-3,x+3,y+3,C'0xFF,0xFF,0xFF',opacity);
      this.DrawLineWu(x+3,y-3,x-3,y+3,C'0xFF,0xFF,0xFF',opacity);
      }
      else
      {
      this.DrawCircle(x,y,8,C'0xA5,0x25,0x12',opacity);
      this.DrawLine(x-3,y-3,x+3,y+3,C'0xFF,0xFF,0xFF',opacity);
      this.DrawLine(x+3,y-3,x-3,y+3,C'0xFF,0xFF,0xFF',opacity);
      }
   }
  //+------------------------------------------------------------------+
  //| Draw the left arrow                                              |
  //+------------------------------------------------------------------+
  void CGCnvElement::DrawArrowLeft(const int base_x,const int base_y,const int size,const color clr,const uchar opacity)
   {
      int x=base_x;
      int y=base_y;
      int s=(size<1 ? 1 : size);
      this.DrawTriangleFill(x-s,y,x,y-s,x,y+s,clr,opacity);
      this.DrawTriangleWu(  x-s,y,x,y-s,x,y+s,clr,opacity);
   }
  //+------------------------------------------------------------------+
  //| Draw the right arrow                                             |
  //+------------------------------------------------------------------+
  void CGCnvElement::DrawArrowRight(const int base_x,const int base_y,const int size,const color clr,const uchar opacity)
   {
      int x=base_x;
      int y=base_y;
      int s=(size<1 ? 1 : size);
      this.DrawTriangleFill(x+s,y,x,y+s,x,y-s,clr,opacity);
      this.DrawTriangleWu(  x+s,y,x,y+s,x,y-s,clr,opacity);
   }
  //+------------------------------------------------------------------+
  //| Draw the up arrow                                                |
  //+------------------------------------------------------------------+
  void CGCnvElement::DrawArrowUp(const int base_x,const int base_y,const int size,const color clr,const uchar opacity)
   {
      int x=base_x;
      int y=base_y;
      int s=(size<1 ? 1 : size);
      this.DrawTriangleFill(x,y-s,x+s,y,x-s,y,clr,opacity);
      this.DrawTriangleWu(  x,y-s,x+s,y,x-s,y,clr,opacity);
   }
  //+------------------------------------------------------------------+
  //| Draw the down arrow                                              |
  //+------------------------------------------------------------------+
  void CGCnvElement::DrawArrowDown(const int base_x,const int base_y,const int size,const color clr,const uchar opacity)
   {
      int x=base_x;
      int y=base_y;
      int s=(size<1 ? 1 : size);
      this.DrawTriangleFill(x,y+s,x-s,y,x+s,y,clr,opacity);
      this.DrawTriangleWu(  x,y+s,x-s,y,x+s,y,clr,opacity);
   }
  //+------------------------------------------------------------------+

 #endif // CGCNVELEMENT_MQH_IMPLEMENTATION
#endif // __GCNVELEMENT_MQH__