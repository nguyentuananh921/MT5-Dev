//+------------------------------------------------------------------+
//|                                                 CanvasBase.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in: Base graphical element                             |
//|                           https://www.mql5.com/en/articles/17960 |
//| Update in: Simple controls                                       |
//|                           https://www.mql5.com/en/articles/18221 |
//| Update in: Containers                                            |
//|                           https://www.mql5.com/en/articles/18658 |
//| Update in: Resizable elements                                    |
//|                           https://www.mql5.com/en/articles/18941 |
//| Update in: Customizable and sortable table columns               |
//|                           https://www.mql5.com/en/articles/19979 |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Base graphic element canvas class |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __CANVASBASE_MQH__
#define __CANVASBASE_MQH__
    //+------------------------------------------------------------------+
    //| Included Libraries                                               |
    //+------------------------------------------------------------------+
    //#include <Arrays\List.mqh>
    #include <Canvas\Canvas.mqh>              // Class SB CCanvas
    //+------------------------------------------------------------------+
    //| Included Custome Libraries                                       |
    //+------------------------------------------------------------------+
    #include "ColorElement.mqh"
    #include "BoundedObj.mqh"
    #include "AutoRepeat.mqh"
 class CCanvasBase : public CBoundedObj
  {
      private: 
         bool              m_chart_mouse_wheel_flag;                 // Flag for sending messages about mouse wheel scrolling
         bool              m_chart_mouse_move_flag;                  // Flag for sending messages about mouse cursor movements
         bool              m_chart_object_create_flag;               // Flag for sending messages about the event of creating a graphic object
         bool              m_chart_mouse_scroll_flag;                // Flag for scrolling the chart with the left button and mouse wheel
         bool              m_chart_context_menu_flag;                // Flag for accessing the context menu by pressing the right mouse button
         bool              m_chart_crosshair_tool_flag;              // Flag for accessing the "Crosshair" tool by pressing the middle mouse button
         bool              m_flags_state;                            // Status of the chart scrolling flags with the wheel, context menu and crosshair
         
      // --- Setting restrictions for the chart (scrolling with the wheel, context menu and crosshair)
         void              SetFlags(const bool flag);
         
      protected:
        //| Update in                                                        |
        //|       Simple controls                                            |
        //|                           https://www.mql5.com/en/articles/18221 |
         CCanvas          *m_background;                             // Canvas for drawing background
         CCanvas          *m_foreground;                             // Canvas for drawing the foreground
        //CBound            m_bound; 
         
         CCanvasBase      *m_container;                              // Parent container object
         CColorElement     m_color_background;                       // Background color control object
         CColorElement     m_color_foreground;                       // Foreground color control object
         CColorElement     m_color_border;                           // Border color control object
        //| Update in: Simple controls                                       |
        //|                           https://www.mql5.com/en/articles/18221 | 
         CColorElement     m_color_background_act;                   // Object to control the background color of the activated element
         CColorElement     m_color_foreground_act;                   // The activated element's foreground color control object
         CColorElement     m_color_border_act;                       // Object for controlling the border color of an activated element
        //| Update in                                                        |
        //|       Integrating the Model Component into the View Component    |
        //|                           https://www.mql5.com/en/articles/19288 | 
         CAutoRepeat       m_autorepeat;                             // Event auto-repeat control object
        //-------------------------------------------------------------------- 
         ENUM_ELEMENT_STATE m_state;                                 // Element state (e.g. buttons (on/off))
         long              m_chart_id;                               // Graph ID
         int               m_wnd;                                    // Chart subwindow number
         int               m_wnd_y;                                  // Offset of the Y coordinate of the cursor in the subwindow
         int               m_obj_x;                                  // X coordinate of the graphic object
         int               m_obj_y;                                  // Y coordinate of the graphic object
         //| Update in                                                        |
         //|       Simple controls                                            |
         //|                           https://www.mql5.com/en/articles/18221 |
            uchar             m_alpha_bg;                               // Background transparency
            uchar             m_alpha_fg;                               // Foreground transparency
         //| Update in Containers                                             |
         //|                           https://www.mql5.com/en/articles/18658 | 
            uint              m_border_width_lt;                        // Left frame width
            uint              m_border_width_rt;                        // Right frame width
            uint              m_border_width_up;                        // Frame width at top
            uint              m_border_width_dn;                        // Bottom frame width

         string            m_program_name;                           // Program name
         bool              m_hidden;                                 // Hidden Object Flag
         bool              m_blocked;                                // Blocked element flag
         //| Update in Containers                                             |
         //|                           https://www.mql5.com/en/articles/18658 |
            bool              m_movable;                                // Movable element flag
         //| Update in: Resizable elements                                    |
         //|                           https://www.mql5.com/en/articles/18941 |
            bool              m_resizable;                              // Resize enable flag
         bool              m_focused;                                // Flag of the element in focus
         bool              m_main;                                   // Main object flag
         bool              m_autorepeat_flag;                        // Auto-repeat event sending flag
         bool              m_scroll_flag;                            // Flag for scrolling content using scrollbars
         bool              m_trim_flag;                              // Flag for cropping an element along the container boundaries
         bool              m_cropped;                                // Flag that the object is hidden outside the container's boundaries
         int               m_cursor_delta_x;                         // Distance from the cursor to the left edge of the element
         int               m_cursor_delta_y;                         // Distance from the cursor to the top edge of the element
         int               m_z_order;                                // Z-order of a graphic object
         
      // --- (1) Sets the name, returns (2) the name, (3) the flag of the active element
         void              SetActiveElementName(const string name)   { CCommonManager::GetInstance().SetElementName(name);                               }
         string            ActiveElementName(void)             const { return CCommonManager::GetInstance().ElementName();                               }
         bool              IsCurrentActiveElement(void)        const { return this.ActiveElementName()==this.NameFG();                                   }
      //| Update in: Resizable elements                                    |
      //|                           https://www.mql5.com/en/articles/18941 |   
       // --- (1) Sets, (2) returns the resizing mode flag
         void              SetResizeMode(const bool flag)            { CCommonManager::GetInstance().SetResizeMode(flag);                                }
         bool              ResizeMode(void)                    const { return CCommonManager::GetInstance().ResizeMode();                                }
         
       // --- (1) Sets, (2) returns the edge of the element to be resized.
         void              SetResizeRegion(const ENUM_CURSOR_REGION edge){ CCommonManager::GetInstance().SetResizeRegion(edge);                          }
         ENUM_CURSOR_REGION ResizeRegion(void)                 const { return CCommonManager::GetInstance().ResizeRegion();                              }
       //--------------------------------------------------------------------   
      // --- Returns the offsets of the initial drawing coordinates on the canvas relative to the canvas and object coordinates
         int               CanvasOffsetX(void)                 const { return(this.ObjectX()-this.X());                                                  }
         int               CanvasOffsetY(void)                 const { return(this.ObjectY()-this.Y());                                                  }
      // --- Returns the adjusted coordinate of a point on the canvas, taking into account the offset of the canvas relative to the object
         int               AdjX(const int x)                   const { return(x-this.CanvasOffsetX());                                                   }
         int               AdjY(const int y)                   const { return(y-this.CanvasOffsetY());                                                   }
         
      // --- Returns the adjusted chart identifier
         long              CorrectChartID(const long chart_id) const { return(chart_id!=0 ? chart_id : ::ChartID());                                     }

      public:
      // --- Getting the bounds of the parent container object
         int               ContainerLimitLeft(void)            const { return(this.m_container==NULL ? this.ObjectX()     : this.m_container.LimitLeft());  }
         int               ContainerLimitRight(void)           const { return(this.m_container==NULL ? this.ObjectRight() : this.m_container.LimitRight()); }
         int               ContainerLimitTop(void)             const { return(this.m_container==NULL ? this.ObjectY()     : this.m_container.LimitTop());   }
         int               ContainerLimitBottom(void)          const { return(this.m_container==NULL ? this.ObjectBottom(): this.m_container.LimitBottom());}
         string            ContainerDescription(void)          const { return(this.m_container==NULL ? "Not specified"    : this.m_container.Description());}
         
      // --- Return coordinates, boundaries and dimensions of a graphic object
         int               ObjectX(void)                       const { return this.m_obj_x;                                                              }
         int               ObjectY(void)                       const { return this.m_obj_y;                                                              }
         int               ObjectWidth(void)                   const { return this.m_background.Width();                                                 }
         int               ObjectHeight(void)                  const { return this.m_background.Height();                                                }
         int               ObjectRight(void)                   const { return this.ObjectX()+this.ObjectWidth()-1;                                       }
         int               ObjectBottom(void)                  const { return this.ObjectY()+this.ObjectHeight()-1;                                      }
         
      // --- Changes the (1) width, (2) height, (3) size of a graphic object
      protected:
         virtual bool      ObjectResizeW(const int size);
         virtual bool      ObjectResizeH(const int size);
         bool              ObjectResize(const int w,const int h);
         
      // --- Sets the (1) X, (2) Y, (3) both coordinates of the graphic object
         virtual bool      ObjectSetX(const int x);
         virtual bool      ObjectSetY(const int y);
         bool              ObjectSetXY(const int x,const int y)      { return(this.ObjectSetX(x) && this.ObjectSetY(y));                                 }
         
      // --- Sets simultaneously the coordinates and dimensions of a graphic object
         virtual bool      ObjectSetXYWidthResize(const int x,const int y,const int w,const int h);
         
      // --- (1) Sets, (2) offsets the graphic object by the specified coordinates/offset size
         bool              ObjectMove(const int x,const int y)       { return this.ObjectSetXY(x,y);                                                     }
         bool              ObjectShift(const int dx,const int dy)    { return this.ObjectSetXY(this.ObjectX()+dx,this.ObjectY()+dy);                     }
         
      // --- Returns the flag that the cursor is inside the object
         bool              Contains(const int x,const int y);
      // --- Returns the location of the cursor on the boundaries of the object
         ENUM_CURSOR_REGION CheckResizeZone(const int x,const int y);
         
      // --- Checks the set color against the specified one
         bool              CheckColor(const ENUM_COLOR_STATE state) const;
      // --- Changes the background, text and frame colors depending on the condition
         void              ColorChange(const ENUM_COLOR_STATE state);
         
      // --- Initialize (1) class object, (2) default object colors
         void              Init(void);
         void              InitColors(void);

      // --- Event handlers for (1) cursor hover (Focus), (2) mouse button clicks (Press),
      // --- (3) moving the cursor (Move), (4) leaving focus (Release), (5) creating a graphic object (Create),
      // --- (6) scrolling the wheel (Wheel), (7) resizing (Resize). Redefined in heirs.
         virtual void      OnFocusEvent(const int id, const long lparam, const double dparam, const string sparam);
         virtual void      OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);
         virtual void      OnMoveEvent(const int id, const long lparam, const double dparam, const string sparam);
         virtual void      OnReleaseEvent(const int id, const long lparam, const double dparam, const string sparam);
         virtual void      OnCreateEvent(const int id, const long lparam, const double dparam, const string sparam);
         virtual void      OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam)         { return;         }  // the handler is disabled here
         virtual void      OnResizeZoneEvent(const int id, const long lparam, const double dparam, const string sparam)    { return;         }  // the handler is disabled here
         
      // --- Handlers for resizing an element by sides and corners
         virtual bool      OnResizeZoneLeft(const int x, const int y)                                                      { return false;   }  // the handler is disabled here
         virtual bool      OnResizeZoneRight(const int x, const int y)                                                     { return false;   }  // the handler is disabled here
         virtual bool      OnResizeZoneTop(const int x, const int y)                                                       { return false;   }  // the handler is disabled here
         virtual bool      OnResizeZoneBottom(const int x, const int y)                                                    { return false;   }  // the handler is disabled here
         virtual bool      OnResizeZoneLeftTop(const int x, const int y)                                                   { return false;   }  // the handler is disabled here
         virtual bool      OnResizeZoneRightTop(const int x, const int y)                                                  { return false;   }  // the handler is disabled here
         virtual bool      OnResizeZoneLeftBottom(const int x, const int y)                                                { return false;   }  // the handler is disabled here
         virtual bool      OnResizeZoneRightBottom(const int x, const int y)                                               { return false;   }  // the handler is disabled here
         
      // --- Handlers for custom element events when hovering, clicking, scrolling the wheel in the object area and changing it
         virtual void      MouseMoveHandler(const int id, const long lparam, const double dparam, const string sparam)     { return;         }  // the handler is disabled here
         virtual void      MousePressHandler(const int id, const long lparam, const double dparam, const string sparam)    { return;         }  // the handler is disabled here
         virtual void      MouseWheelHandler(const int id, const long lparam, const double dparam, const string sparam)    { return;         }  // the handler is disabled here
         virtual void      ObjectChangeHandler(const int id, const long lparam, const double dparam, const string sparam)  { return;         }  // the handler is disabled here
         
      public:
      // --- Returns a pointer to (1) the container, (2) an object of the auto-repeat event class
         CCanvasBase      *GetContainer(void)                  const { return this.m_container;                                                          } 
         CAutoRepeat      *GetAutorepeatObj(void)                    { return &this.m_autorepeat;                                                        }

      // --- Returns a pointer to the (1) background, (2) foreground canvas
         CCanvas          *GetBackground(void)                       { return this.m_background;                                                         }
         CCanvas          *GetForeground(void)                       { return this.m_foreground;                                                         }
         
      // --- Returns a pointer to the color control object of (1) background, (2) foreground, (3) frame
         CColorElement    *GetBackColorControl(void)                 { return &this.m_color_background;                                                  }
         CColorElement    *GetForeColorControl(void)                 { return &this.m_color_foreground;                                                  }
         CColorElement    *GetBorderColorControl(void)               { return &this.m_color_border;                                                      }
         
      // --- Returns a pointer to the color control object of the (1) background, (2) foreground, (3) frame of the activated element
         CColorElement    *GetBackColorActControl(void)              { return &this.m_color_background_act;                                              }
         CColorElement    *GetForeColorActControl(void)              { return &this.m_color_foreground_act;                                              }
         CColorElement    *GetBorderColorActControl(void)            { return &this.m_color_border_act;                                                  }

      // --- Return the current color of (1) background, (2) foreground, (3) frame
         color             BackColor(void)         const { return(!this.State() ? this.m_color_background.GetCurrent() : this.m_color_background_act.GetCurrent());  }
         color             ForeColor(void)         const { return(!this.State() ? this.m_color_foreground.GetCurrent() : this.m_color_foreground_act.GetCurrent());  }
         color             BorderColor(void)       const { return(!this.State() ? this.m_color_border.GetCurrent()     : this.m_color_border_act.GetCurrent());      }
         
      // --- Return the preset color DEFAULT (1) background, (2) foreground, (3) frame
         color             BackColorDefault(void)  const { return(!this.State() ? this.m_color_background.GetDefault() : this.m_color_background_act.GetDefault());  }
         color             ForeColorDefault(void)  const { return(!this.State() ? this.m_color_foreground.GetDefault() : this.m_color_foreground_act.GetDefault());  }
         color             BorderColorDefault(void)const { return(!this.State() ? this.m_color_border.GetDefault()     : this.m_color_border_act.GetDefault());      }
         
      // --- Return the preset color FOCUSED (1) background, (2) foreground, (3) border
         color             BackColorFocused(void)  const { return(!this.State() ? this.m_color_background.GetFocused() : this.m_color_background_act.GetFocused());  }
         color             ForeColorFocused(void)  const { return(!this.State() ? this.m_color_foreground.GetFocused() : this.m_color_foreground_act.GetFocused());  }
         color             BorderColorFocused(void)const { return(!this.State() ? this.m_color_border.GetFocused()     : this.m_color_border_act.GetFocused());      }
         
      // --- Return the preset color PRESSED (1) background, (2) foreground, (3) frame
         color             BackColorPressed(void)  const { return(!this.State() ? this.m_color_background.GetPressed() : this.m_color_background_act.GetPressed());  }
         color             ForeColorPressed(void)  const { return(!this.State() ? this.m_color_foreground.GetPressed() : this.m_color_foreground_act.GetPressed());  }
         color             BorderColorPressed(void)const { return(!this.State() ? this.m_color_border.GetPressed()     : this.m_color_border_act.GetPressed());      }
         
      // --- Return the preset color BLOCKED (1) background, (2) foreground, (3) border
         color             BackColorBlocked(void)              const { return this.m_color_background.GetBlocked();                                      }
         color             ForeColorBlocked(void)              const { return this.m_color_foreground.GetBlocked();                                      }
         color             BorderColorBlocked(void)            const { return this.m_color_border.GetBlocked();                                          }
         
      // --- Set background colors for all states
         void              InitBackColors(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                           {
                              this.m_color_background.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                           }
         void              InitBackColors(const color clr)           { this.m_color_background.InitColors(clr);                                          }

      // --- Set foreground colors for all states
         void              InitForeColors(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                           {
                              this.m_color_foreground.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                           }
         void              InitForeColors(const color clr)           { this.m_color_foreground.InitColors(clr);                                          }

      // --- Set frame colors for all states
         void              InitBorderColors(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                           {
                              this.m_color_border.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                           }
         void              InitBorderColors(const color clr)         { this.m_color_border.InitColors(clr);                                              }

      // --- Initialize the color of (1) background, (2) foreground, (3) border with initial values
         void              InitBackColorDefault(const color clr)     { this.m_color_background.InitDefault(clr);                                         }
         void              InitForeColorDefault(const color clr)     { this.m_color_foreground.InitDefault(clr);                                         }
         void              InitBorderColorDefault(const color clr)   { this.m_color_border.InitDefault(clr);                                             }
         
      // --- Initialize the color of (1) background, (2) foreground, (3) frame on hover with initial values
         void              InitBackColorFocused(const color clr)     { this.m_color_background.InitFocused(clr);                                         }
         void              InitForeColorFocused(const color clr)     { this.m_color_foreground.InitFocused(clr);                                         }
         void              InitBorderColorFocused(const color clr)   { this.m_color_border.InitFocused(clr);                                             }
         
      // --- Initialize the color of (1) background, (2) foreground, (3) frame when clicking on an object with initial values
         void              InitBackColorPressed(const color clr)     { this.m_color_background.InitPressed(clr);                                         }
         void              InitForeColorPressed(const color clr)     { this.m_color_foreground.InitPressed(clr);                                         }
         void              InitBorderColorPressed(const color clr)   { this.m_color_border.InitPressed(clr);                                             }
         
      // --- Initialize the color of (1) background, (2) foreground, (3) border for a locked object with initial values
         void              InitBackColorBlocked(const color clr)     { this.m_color_background.InitBlocked(clr);                                         }
         void              InitForeColorBlocked(const color clr)     { this.m_color_foreground.InitBlocked(clr);                                         }
         void              InitBorderColorBlocked(const color clr)   { this.m_color_border.InitBlocked(clr);                                             }
         
      // --- Set background colors for all states
         void              InitBackColorsAct(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                           {
                              this.m_color_background_act.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                           }
         void              InitBackColorsAct(const color clr)        { this.m_color_background_act.InitColors(clr);                                      }

      // --- Set foreground colors for all states
         void              InitForeColorsAct(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                           {
                              this.m_color_foreground_act.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                           }
         void              InitForeColorsAct(const color clr)        { this.m_color_foreground_act.InitColors(clr);                                      }

      // --- Set frame colors for all states
         void              InitBorderColorsAct(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                           {
                              this.m_color_border_act.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                           }
         void              InitBorderColorsAct(const color clr)      { this.m_color_border_act.InitColors(clr);                                          }

      // --- Initialize the color of (1) background, (2) foreground, (3) border with initial values
         void              InitBackColorActDefault(const color clr)  { this.m_color_background_act.InitDefault(clr);                                     }
         void              InitForeColorActDefault(const color clr)  { this.m_color_foreground_act.InitDefault(clr);                                     }
         void              InitBorderColorActDefault(const color clr){ this.m_color_border_act.InitDefault(clr);                                         }
         
      // --- Initialize the color of (1) background, (2) foreground, (3) frame on hover with initial values
         void              InitBackColorActFocused(const color clr)  { this.m_color_background_act.InitFocused(clr);                                     }
         void              InitForeColorActFocused(const color clr)  { this.m_color_foreground_act.InitFocused(clr);                                     }
         void              InitBorderColorActFocused(const color clr){ this.m_color_border_act.InitFocused(clr);                                         }
         
      // --- Initialize the color of (1) background, (2) foreground, (3) frame when clicking on an object with initial values
         void              InitBackColorActPressed(const color clr)  { this.m_color_background_act.InitPressed(clr);                                     }
         void              InitForeColorActPressed(const color clr)  { this.m_color_foreground_act.InitPressed(clr);                                     }
         void              InitBorderColorActPressed(const color clr){ this.m_color_border_act.InitPressed(clr);                                         }
         
      // --- Set the current background color to different states
         bool              BackColorToDefault(void)
                           {
                              return(!this.State() ? this.m_color_background.SetCurrentAs(COLOR_STATE_DEFAULT) :
                                                   this.m_color_background_act.SetCurrentAs(COLOR_STATE_DEFAULT));
                           }
         bool              BackColorToFocused(void)
                           {
                              return(!this.State() ? this.m_color_background.SetCurrentAs(COLOR_STATE_FOCUSED) :
                                                   this.m_color_background_act.SetCurrentAs(COLOR_STATE_FOCUSED));
                           }
         bool              BackColorToPressed(void)
                           {
                              return(!this.State() ? this.m_color_background.SetCurrentAs(COLOR_STATE_PRESSED) :
                                                   this.m_color_background_act.SetCurrentAs(COLOR_STATE_PRESSED));
                           }
         bool              BackColorToBlocked(void)   { return this.m_color_background.SetCurrentAs(COLOR_STATE_BLOCKED);  }
         
      // ---Set the current foreground color to different states
         bool              ForeColorToDefault(void)
                           { return(!this.State() ? this.m_color_foreground.SetCurrentAs(COLOR_STATE_DEFAULT) :
                                                      this.m_color_foreground_act.SetCurrentAs(COLOR_STATE_DEFAULT));
                           }
         bool              ForeColorToFocused(void)
                           { return(!this.State() ? this.m_color_foreground.SetCurrentAs(COLOR_STATE_FOCUSED) :
                                                      this.m_color_foreground_act.SetCurrentAs(COLOR_STATE_FOCUSED));
                           }
         bool              ForeColorToPressed(void)
                           { return(!this.State() ? this.m_color_foreground.SetCurrentAs(COLOR_STATE_PRESSED) :
                                                      this.m_color_foreground_act.SetCurrentAs(COLOR_STATE_PRESSED));
                           }
         bool              ForeColorToBlocked(void)   { return this.m_color_foreground.SetCurrentAs(COLOR_STATE_BLOCKED);  }
         
      // --- Set the current frame color to different states
         bool              BorderColorToDefault(void)
                           { return(!this.State() ? this.m_color_border.SetCurrentAs(COLOR_STATE_DEFAULT) :
                                                      this.m_color_border_act.SetCurrentAs(COLOR_STATE_DEFAULT));
                           }
         bool              BorderColorToFocused(void)
                           { return(!this.State() ? this.m_color_border.SetCurrentAs(COLOR_STATE_FOCUSED) :
                                                      this.m_color_border_act.SetCurrentAs(COLOR_STATE_FOCUSED));
                           }
         bool              BorderColorToPressed(void)
                           { return(!this.State() ? this.m_color_border.SetCurrentAs(COLOR_STATE_PRESSED) :
                                                      this.m_color_border_act.SetCurrentAs(COLOR_STATE_PRESSED));
                           }
         bool              BorderColorToBlocked(void) { return this.m_color_border.SetCurrentAs(COLOR_STATE_BLOCKED);      }
         
      // ---Set the element's current colors to different states
         bool              ColorsToDefault(void);
         bool              ColorsToFocused(void);
         bool              ColorsToPressed(void);
         bool              ColorsToBlocked(void);
         
      // --- Sets a pointer to the parent container object
         void              SetContainerObj(CCanvasBase *obj);
         
      protected:
      // --- Creates background and foreground canvases
         bool              CreateCanvasObjects(void);
      // --- Creates OBJ_BITMAP_LABEL
         bool              Create(const long chart_id,const int wnd,const string object_name,const int x,const int y,const int w,const int h); 
      public:
      // --- (1) Sets, (2) returns state
         void              SetState(ENUM_ELEMENT_STATE state)        { this.m_state=state; this.ColorsToDefault();                                       }
         ENUM_ELEMENT_STATE State(void)                        const { return this.m_state;                                                              }

      // --- (1) Sets, (2) returns z-order
         bool              ObjectSetZOrder(const int value);
         int               ObjectZOrder(void)                  const { return this.m_z_order;                                                            }
         
      // --- Returns (1) whether the object belongs to the program, the flag (2) hidden, (3) locked,
      // --- (4) movable, (5) resizable, (6) main element, (7) in focus, (8, 9) graphic object name (background, text)
         bool              IsBelongsToThis(const string name)  const { return(::ObjectGetString(this.m_chart_id,name,OBJPROP_TEXT)==this.m_program_name);}
         bool              IsHidden(void)                      const { return this.m_hidden;                                                             }
         bool              IsBlocked(void)                     const { return this.m_blocked;                                                            }
         bool              IsMovable(void)                     const { return this.m_movable;                                                            }
         bool              IsResizable(void)                   const { return this.m_resizable;                                                          }
         bool              IsMain(void)                        const { return this.m_main;                                                               }
         bool              IsFocused(void)                     const { return this.m_focused;                                                            }
         bool              IsAutorepeat(void)                  const { return this.m_autorepeat_flag;                                                    }
         bool              IsScrollable(void)                  const { return this.m_scroll_flag;                                                        }
         bool              IsTrimmed(void)                     const { return this.m_trim_flag;                                                          }
         bool              IsCropped(void)                     const { return this.m_cropped;                                                            }
         string            NameBG(void)                        const { return this.m_background.ChartObjectName();                                       }
         string            NameFG(void)                        const { return this.m_foreground.ChartObjectName();                                       }
         
      // --- (1) Returns, (2) sets the background transparency
         uchar             AlphaBG(void)                       const { return this.m_alpha_bg;                                                           }
         void              SetAlphaBG(const uchar value)             { this.m_alpha_bg=value;                                                            }
      // --- (1) Returns, (2) sets the foreground transparency
         uchar             AlphaFG(void)                       const { return this.m_alpha_fg;                                                           }
         void              SetAlphaFG(const uchar value)             { this.m_alpha_fg=value;                                                            }

      // --- Sets transparency for the background and foreground
         void              SetAlpha(const uchar value)               { this.m_alpha_fg=this.m_alpha_bg=value;                                            }
         
      // --- (1) Returns, (2) sets the left border width
         uint             BorderWidthLeft(void)               const { return this.m_border_width_lt;                                                    } 
         void             SetBorderWidthLeft(const uint width)      { this.m_border_width_lt=width;                                                     }
         
      // --- (1) Returns, (2) sets the width of the border on the right
         uint             BorderWidthRight(void)              const { return this.m_border_width_rt;                                                    } 
         void             SetBorderWidthRight(const uint width)     { this.m_border_width_rt=width;                                                     }
                           
      // --- (1) Returns, (2) sets the border width at the top
         uint             BorderWidthTop(void)                const { return this.m_border_width_up;                                                    } 
         void             SetBorderWidthTop(const uint width)       { this.m_border_width_up=width;                                                     }
                           
      // --- (1) Returns, (2) sets the bottom border width
         uint             BorderWidthBottom(void)             const { return this.m_border_width_dn;                                                    } 
         void             SetBorderWidthBottom(const uint width)    { this.m_border_width_dn=width;                                                     }
                           
      // --- Sets the same frame width on all sides
         void             SetBorderWidth(const uint width)
                           {
                              this.m_border_width_lt=this.m_border_width_rt=this.m_border_width_up=this.m_border_width_dn=width;
                           }
                           
      // --- Sets the frame width
         void             SetBorderWidth(const uint left,const uint right,const uint top,const uint bottom)
                           {
                              this.m_border_width_lt=left;
                              this.m_border_width_rt=right;
                              this.m_border_width_up=top;
                              this.m_border_width_dn=bottom;
                           }
         
      // --- Returning the boundaries of an object taking into account the frame
         int               LimitLeft(void)                     const { return this.ObjectX()+(int)this.m_border_width_lt;                                }
         int               LimitRight(void)                    const { return this.ObjectRight()-(int)this.m_border_width_rt;                            }
         int               LimitTop(void)                      const { return this.ObjectY()+(int)this.m_border_width_up;                                }
         int               LimitBottom(void)                   const { return this.ObjectBottom()-(int)this.m_border_width_dn;                           }
         
      // --- Sets the object's (1) movability, (2) main object, (3) resizing flags,
      // --- (4) auto-repeat events, (5) scrolling inside the container, (6) trimming along the container borders
         void              SetMovable(const bool flag)               { this.m_movable=flag;                                                              }
         void              SetAsMain(void)                           { this.m_main=true;                                                                 }
         virtual void      SetResizable(const bool flag)             { this.m_resizable=flag;                                                            }
         void              SetAutorepeat(const bool flag)            { this.m_autorepeat_flag=flag;                                                      }
         void              SetScrollable(const bool flag)            { this.m_scroll_flag=flag;                                                          }
         virtual void      SetTrimmered(const bool flag)             { this.m_trim_flag=flag;                                                            }
         void              SetCropped(const bool flag)               { this.m_cropped=flag;                                                              }
         
      // --- Returns a flag that an object is located outside of its container
         virtual bool      IsOutOfContainer(void);
      // --- Limits the graphic object to the size of the container
         virtual bool      ObjectTrim(void);
         
      // --- Changes the size of an object
         virtual bool      ResizeW(const int w);
         virtual bool      ResizeH(const int h);
         virtual bool      Resize(const int w,const int h);

      // --- Sets the object to a new coordinate (1) X, (2) Y, (3) XY
         virtual bool      MoveX(const int x);
         virtual bool      MoveY(const int y);
         virtual bool      Move(const int x,const int y);
         
      // --- Sets both the coordinates and dimensions of an element
         virtual bool      MoveXYWidthResize(const int x,const int y,const int w,const int h);
         
      // --- Shifts the object along the (1) X, (2) Y, (3) XY axis by the specified offset
         virtual bool      ShiftX(const int dx);
         virtual bool      ShiftY(const int dy);
         virtual bool      Shift(const int dx,const int dy);
         
      // --- (1) Hides (2) displays the object on all chart periods,
      // --- (3) brings the item to the front, (4) locks, (5) unlocks the item,
      // --- (6) fills the object with the specified color with the transparency set
         virtual void      Hide(const bool chart_redraw);
         virtual void      Show(const bool chart_redraw);
         virtual void      BringToTop(const bool chart_redraw);
         virtual void      Block(const bool chart_redraw);
         virtual void      Unblock(const bool chart_redraw);
         void              Fill(const color clr,const bool chart_redraw);
         
      // --- (1) Fills the object with a transparent color, (2) updates the object to reflect the changes,
      // --- (3) draws the appearance, (4) destroys the object
         virtual void      Clear(const bool chart_redraw);
         virtual void      Update(const bool chart_redraw);
         virtual void      Draw(const bool chart_redraw);
         virtual void      Destroy(void);
         
      // --- Returns a description of the object
         virtual string    Description(void);
         
      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0) const;
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_CANVAS_BASE); }
         
      // --- Event handler
         virtual void      OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam);
         
      // --- (1) Timer, (2) timer event handler
         virtual void      OnTimer()                                 { this.TimerEventHandler();         }
         virtual void      TimerEventHandler(void)                   { return;                           }
         
      // --- Constructors/destructor
      //Modify m_alpha_bg=255 instead of 0 to meet MT5 5716 version
                           CCanvasBase(void) :
                              m_program_name(::MQLInfoString(MQL_PROGRAM_NAME)), m_chart_id(::ChartID()), m_wnd(0), m_alpha_bg(255), m_alpha_fg(255), 
                              m_hidden(false), m_blocked(false), m_focused(false), m_movable(false), m_resizable(false), m_main(false), 
                              m_autorepeat_flag(false), m_trim_flag(true), m_cropped(false), m_scroll_flag(false),
                              m_border_width_lt(0), m_border_width_rt(0), m_border_width_up(0), m_border_width_dn(0), m_z_order(0),
                              m_state(0), m_wnd_y(0), m_cursor_delta_x(0), m_cursor_delta_y(0) { this.CreateCanvasObjects(); this.Init(); }
                           CCanvasBase(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
                           ~CCanvasBase(void);
  };
 #ifndef CCANVASBASE_IMPLEMENTATION
 #define CCANVASBASE_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| CCanvasBase::Constructor                                         |
  //| Modify m_alpha_bg(0) to m_alpha_bg(255) to meet MT5 5716 version |
  //+------------------------------------------------------------------+
  CCanvasBase::CCanvasBase(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
        m_program_name(::MQLInfoString(MQL_PROGRAM_NAME)), m_wnd(wnd<0 ? 0 : wnd), m_alpha_bg(255), m_alpha_fg(255),
        m_hidden(false), m_blocked(false), m_focused(false), m_movable(false), m_resizable(false), m_main(false), 
        m_autorepeat_flag(false), m_trim_flag(true), m_cropped(false), m_scroll_flag(false),
        m_border_width_lt(0), m_border_width_rt(0), m_border_width_up(0), m_border_width_dn(0), m_z_order(0),
        m_state(0), m_cursor_delta_x(0), m_cursor_delta_y(0)
   {
    // --- Get the adjusted graph ID and distance in pixels along the vertical Y axis
    // --- between the top frame of the indicator subwindow and the top frame of the main chart window
        this.m_chart_id=this.CorrectChartID(chart_id);
        
    // --- If it was not possible to create canvases, we leave
        if(!this.CreateCanvasObjects())
            return;
            
    // --- If the graphic resource and graphic object are created
        if(this.Create(this.m_chart_id,this.m_wnd,object_name,x,y,w,h))
        {
            // --- Clear the background and foreground canvases and set the initial coordinate values,
            // --- names of graphic objects and properties of text drawn in the foreground
            this.Clear(false);
            this.m_obj_x=x;
            this.m_obj_y=y;
            this.m_color_background.SetName("Background");
            this.m_color_foreground.SetName("Foreground");
            this.m_color_border.SetName("Border");
            this.m_foreground.FontSet(DEF_FONTNAME,-DEF_FONTSIZE*10,FW_MEDIUM);
            this.m_bound.SetName("Perimeter");
            
            // --- Remember permissions for the mouse and graphics tools
            this.Init();
        }
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Destructor |
  //+------------------------------------------------------------------+
  CCanvasBase::~CCanvasBase(void)
   {
    // --- Destroy the object
        this.Destroy();
    // --- Restoring permissions for the mouse and graphics tools
        ::ChartSetInteger(this.m_chart_id, CHART_EVENT_MOUSE_WHEEL, this.m_chart_mouse_wheel_flag);
        ::ChartSetInteger(this.m_chart_id, CHART_EVENT_MOUSE_MOVE, this.m_chart_mouse_move_flag);
        ::ChartSetInteger(this.m_chart_id, CHART_EVENT_OBJECT_CREATE, this.m_chart_object_create_flag);
        ::ChartSetInteger(this.m_chart_id, CHART_MOUSE_SCROLL, this.m_chart_mouse_scroll_flag);
        ::ChartSetInteger(this.m_chart_id, CHART_CONTEXT_MENU, this.m_chart_context_menu_flag);
        ::ChartSetInteger(this.m_chart_id, CHART_CROSSHAIR_TOOL, this.m_chart_crosshair_tool_flag);
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Comparing two objects |
  //+------------------------------------------------------------------+
  int CCanvasBase::Compare(const CObject *node,const int mode=0) const
   {
        if(node==NULL)
            return -1;
        const CCanvasBase *obj=node;
        switch(mode)
        {
            case BASE_SORT_BY_NAME  :  return(this.Name()         >obj.Name()          ? 1 : this.Name()          <obj.Name()          ? -1 : 0);
            case BASE_SORT_BY_X     :  return(this.X()            >obj.X()             ? 1 : this.X()             <obj.X()             ? -1 : 0);
            case BASE_SORT_BY_Y     :  return(this.Y()            >obj.Y()             ? 1 : this.Y()             <obj.Y()             ? -1 : 0);
            case BASE_SORT_BY_WIDTH :  return(this.Width()        >obj.Width()         ? 1 : this.Width()         <obj.Width()         ? -1 : 0);
            case BASE_SORT_BY_HEIGHT:  return(this.Height()       >obj.Height()        ? 1 : this.Height()        <obj.Height()        ? -1 : 0);
            case BASE_SORT_BY_ZORDER:  return(this.ObjectZOrder() >obj.ObjectZOrder()  ? 1 : this.ObjectZOrder()  <obj.ObjectZOrder()  ? -1 : 0);
            default                 :  return(this.ID()           >obj.ID()            ? 1 : this.ID()            <obj.ID()            ? -1 : 0);
        }
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Creates background and foreground canvases |
  //+------------------------------------------------------------------+
  bool CCanvasBase::CreateCanvasObjects(void)
   {
    // --- If both canvases have already been created, or the class does not manage canvases, return true
        if((this.m_background!=NULL && this.m_foreground!=NULL) || !this.m_canvas_owner)
            return true;
    // ---Creating a background canvas
        this.m_background=new CCanvas();
        if(this.m_background==NULL)
        {
            ::PrintFormat("%s: Error! Failed to create background canvas",__FUNCTION__);
            return false;
        }
    // ---Creating a foreground canvas
        this.m_foreground=new CCanvas();
        if(this.m_foreground==NULL)
        {
            ::PrintFormat("%s: Error! Failed to create foreground canvas",__FUNCTION__);
            return false;
        }
    // --- Everything is successful
        return true;
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Creates background and foreground graphic objects   |
  //+------------------------------------------------------------------+
  bool CCanvasBase::Create(const long chart_id,const int wnd,const string object_name,const int x,const int y,const int w,const int h)
   {
    // --- Getting the adjusted chart identifier
        long id=this.CorrectChartID(chart_id);
    // --- Correct the passed name for the object
        string nm=object_name;
        ::StringReplace(nm," ","");
    // --- Create a name for the graphic object for the background and create a canvas
        string obj_name=nm+"BG";        
        if(!this.m_background.CreateBitmapLabel(id,(wnd<0 ? 0 : wnd),obj_name,x,y,(w>0 ? w : 1),(h>0 ? h : 1),COLOR_FORMAT_ARGB_NORMALIZE))
        //if(!this.m_background.CreateBitmapLabel(id,(wnd<0 ? 0 : wnd),obj_name,x,y,(w>0 ? w : 1),(h>0 ? h : 1), COLOR_FORMAT_XRGB_NOALPHA))
        //if(!this.m_background.CreateBitmapLabel(id,(wnd<0 ? 0 : wnd),obj_name,x,y,(w>0 ? w : 1),(h>0 ? h : 1), COLOR_FORMAT_ARGB_RAW))
        {
            ::PrintFormat("%s: The CreateBitmapLabel() method of the CCanvas class returned an error creating a \"%s\" graphic object",__FUNCTION__,obj_name);
            return false;
        }
    // --- Create a name for the graphic object for the foreground and create a canvas
        obj_name=nm+"FG";
        if(!this.m_foreground.CreateBitmapLabel(id,(wnd<0 ? 0 : wnd),obj_name,x,y,(w>0 ? w : 1),(h>0 ? h : 1),COLOR_FORMAT_ARGB_NORMALIZE))
        //if(!this.m_background.CreateBitmapLabel(id,(wnd<0 ? 0 : wnd),obj_name,x,y,(w>0 ? w : 1),(h>0 ? h : 1), COLOR_FORMAT_XRGB_NOALPHA))
        //if(!this.m_background.CreateBitmapLabel(id,(wnd<0 ? 0 : wnd),obj_name,x,y,(w>0 ? w : 1),(h>0 ? h : 1), COLOR_FORMAT_ARGB_RAW))
        {
            ::PrintFormat("%s: The CreateBitmapLabel() method of the CCanvas class returned an error creating a \"%s\" graphic object",__FUNCTION__,obj_name);
            return false;
        }
    // --- If creation is successful, enter the name of the program into the OBJPROP_TEXT property of the graphic object
        ::ObjectSetString(id,this.NameBG(),OBJPROP_TEXT,this.m_program_name);
        ::ObjectSetString(id,this.NameFG(),OBJPROP_TEXT,this.m_program_name);
        ::ObjectSetString(id,this.NameBG(),OBJPROP_TOOLTIP,"\n");
        ::ObjectSetString(id,this.NameFG(),OBJPROP_TOOLTIP,"\n");
        ::ObjectSetInteger(id,this.NameBG(),OBJPROP_ZORDER,0);
        ::ObjectSetInteger(id,this.NameFG(),OBJPROP_ZORDER,0);
            
    // --- Set the dimensions of the rectangular area and return true
        this.m_bound.SetXY(x,y);
        this.m_bound.Resize(w,h);
        return true;
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Set pointer |
  // | to the parent container object |
  //+------------------------------------------------------------------+
  void CCanvasBase::SetContainerObj(CCanvasBase *obj)
   {
        // --- Set the passed pointer to the object
            this.m_container=obj;
        // --- If the pointer is empty, we leave
            if(this.m_container==NULL)
                return;
        // --- If an invalid pointer is passed, we reset it in the object and leave
            if(::CheckPointer(this.m_container)==POINTER_INVALID)
            {
                this.m_container=NULL;
                return;
            }
        // --- Crop the object along the boundaries of the container assigned to it
            this.ObjectTrim();
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Returns the flag that the object is |
  // | located outside of its container |
  //+------------------------------------------------------------------+
  bool CCanvasBase::IsOutOfContainer(void)
   {
    // --- Return the result of checking that the object completely extends beyond the container
        return(this.Right() <= this.ContainerLimitLeft() || this.X() >= this.ContainerLimitRight() ||
                this.Bottom()<= this.ContainerLimitTop()  || this.Y() >= this.ContainerLimitBottom());
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Crops a graphic object along the contour of the container |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ObjectTrim()
   {
        // --- Check the element's cropping permission flag and,
        // --- if the element should not be trimmed along the container boundaries - return false
            if(!this.m_trim_flag)
                return false;
        // --- Getting the boundaries of the container
            int container_left   = this.ContainerLimitLeft();
            int container_right  = this.ContainerLimitRight();
            int container_top    = this.ContainerLimitTop();
            int container_bottom = this.ContainerLimitBottom();
            
        // --- Get the current boundaries of the object
            int object_left   = this.X();
            int object_right  = this.Right();
            int object_top    = this.Y();
            int object_bottom = this.Bottom();

        // --- We check whether the object completely extends beyond the container and, if so, hide it
            if(this.IsOutOfContainer())
            {
                // --- Set the flag that the object is outside the container
                this.m_cropped=true;
                // --- Hiding the object and restoring its dimensions
                this.Hide(false);
                if(this.ObjectResize(this.Width(),this.Height()))
                this.BoundResize(this.Width(),this.Height());
                return true;
        }
    // --- The object is completely or partially inside the visible area of ​​the container
        else
        {
            // --- Remove the flag for placing the object outside the container
            this.m_cropped=false;
            // --- If the element is completely inside the container
            if(object_right<=container_right && object_left>=container_left &&
                object_bottom<=container_bottom && object_top>=container_top)
            {
                // --- If the width or height of the graphic object does not match the width or height of the element,
                // --- modify the graphic object according to the size of the element and return true
                if(this.ObjectWidth()!=this.Width() || this.ObjectHeight()!=this.Height())
                {
                if(this.ObjectResize(this.Width(),this.Height()))
                    return true;
                }
            }
            // --- If the element is partially in the visible area of ​​the container
            else
            {
                // --- If the vertical element is completely within the visible area of ​​the container
                if(object_bottom<=container_bottom && object_top>=container_top)
                {
                // --- If the height of the graphic object does not match the height of the element,
                // --- modify the graphic object according to the height of the element
                if(this.ObjectHeight()!=this.Height())
                    this.ObjectResizeH(this.Height());
                }
                else
                {
                // --- If the horizontal element is completely within the visible area of ​​the container
                if(object_right<=container_right && object_left>=container_left)
                {
                    // --- If the width of the graphic object does not match the width of the element,
                    // --- modify the graphic object according to the width of the element
                    if(this.ObjectWidth()!=this.Width())
                        this.ObjectResizeW(this.Width());
                }
                }
            }
        }
        
    // --- We check whether the object goes horizontally and vertically outside the container
        bool modified_horizontal=false;     // Horizontal change flag
        bool modified_vertical  =false;     // Vertical change flag
        
    // ---Horizontal cropping
        int new_left = object_left;
        int new_width = this.Width();
    // --- If the object extends beyond the left border of the container
        if(object_left<=container_left)
        {
            int crop_left=container_left-object_left;
            new_left=container_left;
            new_width-=crop_left;
            modified_horizontal=true;
        }
    // --- If the object goes beyond the right border of the container
        if(object_right>=container_right)
        {
            int crop_right=object_right-container_right;
            new_width-=crop_right;
            modified_horizontal=true;
        }
    // --- If there were changes horizontally
        if(modified_horizontal)
        {
            this.ObjectSetX(new_left);
            this.ObjectResizeW(new_width);
        }

    // --- Vertical cropping
        int new_top=object_top;
        int new_height=this.Height();
    // --- If the object goes beyond the top border of the container
        if(object_top<=container_top)
        {
            int crop_top=container_top-object_top;
            new_top=container_top;
            new_height-=crop_top;
            modified_vertical=true;
        }
    // --- If the object extends beyond the bottom border of the container
        if(object_bottom>=container_bottom)
        {
            int crop_bottom=object_bottom-container_bottom;
            new_height-=crop_bottom;
            modified_vertical=true;
        }
    // --- If there were changes vertically
        if(modified_vertical)
        {
            this.ObjectSetY(new_top);
            this.ObjectResizeH(new_height);
        }

    // --- After calculations, the object may be hidden, but is now in the container area - display it
        this.Show(false);
            
    // --- If the object has been changed, redraw it
        if(modified_horizontal || modified_vertical)
        {
            this.Update(false);
            this.Draw(false);
            return true;
        }

        return false;
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Returns the flag that the cursor is inside the object |
  //+------------------------------------------------------------------+
  bool CCanvasBase::Contains(const int x,const int y)
   {
        int left=::fmax(this.X(),this.ObjectX());
        int right=::fmin(this.Right(),this.ObjectRight());
        int top=::fmax(this.Y(),this.ObjectY());
        int bottom=::fmin(this.Bottom(),this.ObjectBottom());
        return(x>=left && x<=right && y>=top && y<=bottom);
   }
  //+--------------------------------------------------------------------+
  //|CCanvasBase::Returns the location of the cursor on the boundaries of the object|
  //+--------------------------------------------------------------------+
  ENUM_CURSOR_REGION CCanvasBase::CheckResizeZone(const int x,const int y)
   {
    // --- Coordinates of element borders
        int top=this.Y();
        int bottom=this.Bottom();
        int left=this.X();
        int right=this.Right();
        
    // --- If outside the object, return CURSOR_REGION_NONE
        if(x<left || x>right || y<top || y>bottom)
            return CURSOR_REGION_NONE;

    // --- Left edge and corners
        if(x>=left && x<=left+DEF_EDGE_THICKNESS)
        {
            // --- Upper left corner
            if(y>=top && y<=top+DEF_EDGE_THICKNESS)
                return CURSOR_REGION_LEFT_TOP;
            // --- Bottom left corner
            if(y>=bottom-DEF_EDGE_THICKNESS && y<=bottom)
                return CURSOR_REGION_LEFT_BOTTOM;
            // --- Left side
            return CURSOR_REGION_LEFT;
        }
        
    // --- Right edge and corners
        if(x>=right-DEF_EDGE_THICKNESS && x<=right)
        {
            // --- Upper right corner
            if(y>=top && y<=top+DEF_EDGE_THICKNESS)
                return CURSOR_REGION_RIGHT_TOP;
            // --- Bottom right corner
            if(y>=bottom-DEF_EDGE_THICKNESS && y<=bottom)
                return CURSOR_REGION_RIGHT_BOTTOM;
            // --- Right side
            return CURSOR_REGION_RIGHT;
        }
        
    // --- Top edge
        if(y>=top && y<=top+DEF_EDGE_THICKNESS)
            return CURSOR_REGION_TOP;

    // ---Bottom edge
        if(y>=bottom-DEF_EDGE_THICKNESS && y<=bottom)
            return CURSOR_REGION_BOTTOM;

    // --- The cursor is not on the edges of the element
        return CURSOR_REGION_NONE;
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Sets the z-order of a graphic object |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ObjectSetZOrder(const int value)
   {
    // --- If an already set value is passed, return true
        if(this.ObjectZOrder()==value)
            return true;
    // --- If it was not possible to set a new value in the background and foreground graphic objects, return false
        if(!::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_ZORDER,value) || !::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_ZORDER,value))
            return false;
    // --- Write the new z-order value to a variable and return true
        this.m_z_order=value;
        return true;
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Sets the X coordinate of a graphic object |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ObjectSetX(const int x)
   {
    // --- If an existing coordinate is passed, return true
        if(this.ObjectX()==x)
            return true;
    // --- If it was not possible to set a new coordinate in the background and foreground graphic objects, return false
        if(!::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_XDISTANCE,x) || !::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_XDISTANCE,x))
            return false;
    // --- Write the new coordinate to a variable and return true
        this.m_obj_x=x;
        return true;
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Sets the Y coordinate of a graphic object           |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ObjectSetY(const int y)
   {
    // --- If an existing coordinate is passed, return true
        if(this.ObjectY()==y)
            return true;
    // --- If it was not possible to set a new coordinate in the background and foreground graphic objects, return false
        if(!::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_YDISTANCE,y) || !::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_YDISTANCE,y))
            return false;
    // --- Write the new coordinate to a variable and return true
        this.m_obj_y=y;
        return true;
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Changes the width of a graphic object               |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ObjectResizeW(const int size)
  {
    // --- If the existing width is passed, return true
        if(this.ObjectWidth()==size)
            return true;
    // --- If a size greater than 0 is passed, we return the result of changing the width of the background and foreground, otherwise - false
        return(size>0 ? (this.m_background.Resize(size,this.ObjectHeight()) && this.m_foreground.Resize(size,this.ObjectHeight())) : false);
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Changes the height of a graphic object             |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ObjectResizeH(const int size)
   {
    // --- If an existing height is passed, return true
        if(this.ObjectHeight()==size)
            return true;
    // --- If a size greater than 0 is passed, we return the result of changing the height of the background and foreground, otherwise - false
        return(size>0 ? (this.m_background.Resize(this.ObjectWidth(),size) && this.m_foreground.Resize(this.ObjectWidth(),size)) : false);
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Resizes a graphic object |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ObjectResize(const int w,const int h)
   {
        if(!this.ObjectResizeW(w))
            return false;
        return this.ObjectResizeH(h);
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Installs simultaneously |
  // | coordinates and dimensions of the graphic object                |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ObjectSetXYWidthResize(const int x,const int y,const int w,const int h)
   {
    // --- If new coordinates are set, return the result of resizing
        if(this.ObjectSetXY(x,y))
            return this.ObjectResize(w,h);
    // --- Failed to set new coordinates - return false
        return false;
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Changes the width of an object                     |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ResizeW(const int w)
   {
        if(!this.ObjectResizeW(w))
            return false;
        this.BoundResizeW(w);
        if(!this.ObjectTrim())
        {
            this.Update(false);
            this.Draw(false);
        }
        return true;
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Changes the height of an object                    |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ResizeH(const int h)
   {
        if(!this.ObjectResizeH(h))
            return false;
        this.BoundResizeH(h);
        if(!this.ObjectTrim())
        {
            this.Update(false);
            this.Draw(false);
        }
        return true;
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Resizes an object                                   |
  //+------------------------------------------------------------------+
  bool CCanvasBase::Resize(const int w,const int h)
   {
        if(!this.ObjectResize(w,h))
            return false;
        this.BoundResize(w,h);
        if(!this.ObjectTrim())
        {
            this.Update(false);
            this.Draw(false);
        }
        return true;
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Sets an object to new X and Y coordinates          |
  //+------------------------------------------------------------------+
  bool CCanvasBase::Move(const int x,const int y)
    {
        if(!this.ObjectMove(x,y))
            return false;
        this.BoundMove(x,y);
        this.ObjectTrim();
        return true;
    }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Sets an object to a new X coordinate                |
  //+------------------------------------------------------------------+
  bool CCanvasBase::MoveX(const int x)
   {
        return this.Move(x,this.AdjY(this.ObjectY()));
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Sets an object to a new Y coordinate                |
  //+------------------------------------------------------------------+
  bool CCanvasBase::MoveY(const int y)
   {
        return this.Move(this.AdjX(this.ObjectX()),y);
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Shifts an object along the X and Y axes by the specified offset |
  //+------------------------------------------------------------------+
  bool CCanvasBase::Shift(const int dx,const int dy)
   {
        if(!this.ObjectShift(dx,dy))
            return false;
        this.BoundShift(dx,dy);
        this.ObjectTrim();
        return true;
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Shifts the object along the X axis by the specified offset |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ShiftX(const int dx)
   {
        return this.Shift(dx,0);
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Shifts the object along the Y axis by the specified offset |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ShiftY(const int dy)
   {
        return this.Shift(0,dy);
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Sets both the coordinates and dimensions of an element |
  //+------------------------------------------------------------------+
  bool CCanvasBase::MoveXYWidthResize(const int x,const int y,const int w,const int h)
   {
        if(!this.ObjectSetXYWidthResize(x,y,w,h))
            return false;
        this.BoundMove(x,y);
        this.BoundResize(w,h);
        if(!this.ObjectTrim())
        {
            this.Update(false);
            this.Draw(false);
        }
        return true;
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Hides the object on all chart periods               |
  //+------------------------------------------------------------------+
  void CCanvasBase::Hide(const bool chart_redraw)
   {
    // --- If the object is already hidden, we leave
        if(this.m_hidden)
            return;
    // --- If the visibility change for background and foreground is successfully set
    // --- to the graphics command queue - set the hidden object flag
        if(::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS) &&
            ::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS)
            ) this.m_hidden=true;
    // --- If indicated, redraw the graph
        if(chart_redraw)
            ::ChartRedraw(this.m_chart_id);
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Displays an object on all chart periods            |
  //+------------------------------------------------------------------+
  void CCanvasBase::Show(const bool chart_redraw)
   {
     // --- If the object is already visible, we leave
        if(!this.m_hidden)
            return;
     // --- If the visibility change for background and foreground is successfully set
     // --- to the graphics command queue - reset the hidden object flag
        if(::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS) &&
            ::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS)
            ) this.m_hidden=false;
     // --- If indicated, redraw the graph
        if(chart_redraw)
            ::ChartRedraw(this.m_chart_id);
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Brings the object to the front                      |
  //+------------------------------------------------------------------+
  void CCanvasBase::BringToTop(const bool chart_redraw)
   {
        if(this.m_cropped)
            return;
        this.Hide(false);
        this.Show(chart_redraw);
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Blocks element                                      |
  //+------------------------------------------------------------------+
  void CCanvasBase::Block(const bool chart_redraw)
   {
    // --- If the element is already blocked, we leave
        if(this.m_blocked)
            return;
    // --- Set the current colors as the colors of the blocked element,
    // --- set the blocking flag and redraw the object
        this.ColorsToBlocked();
        this.m_blocked=true;
        this.Draw(chart_redraw);
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Unlocks element                                     |
  //+------------------------------------------------------------------+
  void CCanvasBase::Unblock(const bool chart_redraw)
   {
    // --- If the element is already unlocked, we leave
        if(!this.m_blocked)
            return;
    // --- Set the current colors to be the colors of the element in its normal state,
    // --- redraw the object and reset the blocking flag
        this.ColorsToDefault();
        this.Draw(chart_redraw);
        this.m_blocked=false;
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Sets the current colors                            |
  // | element to default state                                        |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ColorsToDefault(void)
   {
        bool res=true;
        res &=this.BackColorToDefault();
        res &=this.ForeColorToDefault();
        res &=this.BorderColorToDefault();
        return res;
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Sets the current colors                             |
  //| element into hover state                                         |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ColorsToFocused(void)
   {
        bool res=true;
        res &=this.BackColorToFocused();
        res &=this.ForeColorToFocused();
        res &=this.BorderColorToFocused();
        return res;
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Sets the current colors                            |
  // | element into state when the cursor is pressed                   |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ColorsToPressed(void)
   {
        bool res=true;
        res &=this.BackColorToPressed();
        res &=this.ForeColorToPressed();
        res &=this.BorderColorToPressed();
        return res;
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Sets the current colors                            |
  // | element to a locked state                                       |
  //+------------------------------------------------------------------+
  bool CCanvasBase::ColorsToBlocked(void)
   {
        bool res=true;
        res &=this.BackColorToBlocked();
        res &=this.ForeColorToBlocked();
        res &=this.BorderColorToBlocked();
        return res;
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Fills an object with the specified color           |
  // | with transparency set to m_alpha                                |
  //+------------------------------------------------------------------+
  void CCanvasBase::Fill(const color clr,const bool chart_redraw)
   {
        this.m_background.Erase(::ColorToARGB(clr,this.m_alpha_bg));
        //this.m_background.Erase(::ColorToARGB(clr,255));
        this.m_background.Update(chart_redraw);
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Fills an object with a transparent color           |
  //+------------------------------------------------------------------+
  void CCanvasBase::Clear(const bool chart_redraw)
   {
        this.m_background.Erase(0x00000000); // this.m_background.Erase(clrNULL); Modify clrNULL → 0x00000000
        this.m_foreground.Erase(0x00000000); // this.m_foreground.Erase(clrNULL); Modify clrNULL → 0x00000000
        this.Update(chart_redraw);
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Updates an object to reflect changes               |
  //+------------------------------------------------------------------+
  void CCanvasBase::Update(const bool chart_redraw)
   {
        this.m_background.Update(false);
        this.m_foreground.Update(chart_redraw);
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Draws appearance                                   |
  //+------------------------------------------------------------------+
  void CCanvasBase::Draw(const bool chart_redraw)
   {
        return;
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Destroys an object                                  |
  //+------------------------------------------------------------------+
  void CCanvasBase::Destroy(void)
   {
    if(this.m_canvas_owner)
    {
        this.m_background.Destroy();
        this.m_foreground.Destroy();
        delete this.m_background;
        delete this.m_foreground;
        this.m_background=NULL;
        this.m_foreground=NULL;
    }
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Returns object description                         |
  //+------------------------------------------------------------------+
  string CCanvasBase::Description(void)
    {
        //--- 1. Get basic info from Parent: "Canvas Base: Name (ID 123)"
        string baseDesc = CBaseObj::Description();
        
        //--- 2. Format additional Canvas-specific info
        //--- BG and FG names are unique to Canvas, so we keep them
        string canvasInfo = ::StringFormat("BG: %s, FG: %s", this.NameBG(), this.NameFG());
        
        //--- 3. Format Area (X, Y, W, H)
        string area = ::StringFormat("Area: [X %d, Y %d, W %d, H %d]", 
                                        this.X(), this.Y(), this.Width(), this.Height());
        
        //--- 4. Combine everything
        return ::StringFormat("%s (%s), %s", baseDesc, canvasInfo, area);
        
        // string nm=this.Name();
        // string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
        // string area=::StringFormat("x %d, y %d, w %d, h %d",this.X(),this.Y(),this.Width(),this.Height());
        // return ::StringFormat("%s%s (%s, %s): ID %d, %s",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.NameBG(),this.NameFG(),this.ID(),area);
    }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Saving to file                                      |
  //+------------------------------------------------------------------+
  bool CCanvasBase::Save(const int file_handle)
   {
    // --- Method temporarily disabled
        return false;
        
    // --- Save the data of the parent object
        if(!CBaseObj::Save(file_handle))
            return false;
    /*
    // ---Saving properties
            
    */
    // --- Everything is successful
        return true;
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Loading from file |
  //+------------------------------------------------------------------+
  bool CCanvasBase::Load(const int file_handle)
   {
    // --- Method temporarily disabled
        return false;
        
    // --- Loading the data of the parent object
        if(!CBaseObj::Load(file_handle))
            return false;
    /*
    // --- Loading properties
        
    */
    // --- Everything is successful
        return true;
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Setting restrictions for a chart |
  //| (wheel scrolling, context menu and crosshair) |
  //+------------------------------------------------------------------+
  void CCanvasBase::SetFlags(const bool flag)
   {
    // --- If you need to set flags, and they have already been set earlier, leave
        if(flag && this.m_flags_state)
            return;
    // --- If you need to reset flags, and they have already been reset earlier, leave
        if(!flag && !this.m_flags_state)
            return;
    // --- Set the required flag for the context menu,
    // --- crosshair tool and scrolling the chart with the mouse wheel.
    // --- After installation, remember the value of the set flag
        ::ChartSetInteger(this.m_chart_id, CHART_CONTEXT_MENU,  flag);
        ::ChartSetInteger(this.m_chart_id, CHART_CROSSHAIR_TOOL,flag);
        ::ChartSetInteger(this.m_chart_id, CHART_MOUSE_SCROLL,  flag);
        this.m_flags_state=flag;
    // --- We update the graph to immediately apply the set flags
        ::ChartRedraw(this.m_chart_id);
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Class Initialization                               |
  //+------------------------------------------------------------------+
  void CCanvasBase::Init(void)
   {
    // --- Remember permissions for the mouse and graphics tools
        this.m_chart_mouse_wheel_flag   = ::ChartGetInteger(this.m_chart_id, CHART_EVENT_MOUSE_WHEEL);
        this.m_chart_mouse_move_flag    = ::ChartGetInteger(this.m_chart_id, CHART_EVENT_MOUSE_MOVE);
        this.m_chart_object_create_flag = ::ChartGetInteger(this.m_chart_id, CHART_EVENT_OBJECT_CREATE);
        this.m_chart_mouse_scroll_flag  = ::ChartGetInteger(this.m_chart_id, CHART_MOUSE_SCROLL);
        this.m_chart_context_menu_flag  = ::ChartGetInteger(this.m_chart_id, CHART_CONTEXT_MENU);
        this.m_chart_crosshair_tool_flag= ::ChartGetInteger(this.m_chart_id, CHART_CROSSHAIR_TOOL);
    // --- Set permissions for the mouse and graphics
        ::ChartSetInteger(this.m_chart_id, CHART_EVENT_MOUSE_WHEEL, true);
        ::ChartSetInteger(this.m_chart_id, CHART_EVENT_MOUSE_MOVE, true);
        ::ChartSetInteger(this.m_chart_id, CHART_EVENT_OBJECT_CREATE, true);

    // --- Initialize object colors to default
        this.InitColors();
    // --- Initialize the millisecond timer
        ::EventSetMillisecondTimer(16);
        
    // --- Canvas ownership flag
        this.m_canvas_owner=true;
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Initializing default object colors |
  //+------------------------------------------------------------------+
  void CCanvasBase::InitColors(void)
   {
    // --- Initialize the background colors for normal and activated states and make it the current background color
        this.InitBackColors(clrWhiteSmoke);
        this.InitBackColorsAct(clrWhiteSmoke);
        this.BackColorToDefault();
        
    // --- Initialize the foreground colors for normal and activated states and make it the current text color
        this.InitForeColors(clrBlack);
        this.InitForeColorsAct(clrBlack);
        this.ForeColorToDefault();
        
    // --- Initialize the border colors for the normal and activated states and make it the current border color
        this.InitBorderColors(clrDarkGray);
        this.InitBorderColorsAct(clrDarkGray);
        this.BorderColorToDefault();
        
    // --- Initialize the border color and foreground color for the locked element
        this.InitBorderColorBlocked(clrLightGray);
        this.InitForeColorBlocked(clrSilver);
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Checks the set color against the specified one      |
  //+------------------------------------------------------------------+
  bool CCanvasBase::CheckColor(const ENUM_COLOR_STATE state) const
   {
    bool res=true;
    // ---Depending on the event being checked
        switch(state)
        {
    // --- check that all STANDARD colors of the background, text and frame are equal to the preset values
            case COLOR_STATE_DEFAULT :
            res &=this.BackColor()==this.BackColorDefault();
            res &=this.ForeColor()==this.ForeColorDefault();
            res &=this.BorderColor()==this.BorderColorDefault();
            break;

    // --- check that all FOCUSED colors of the background, text and frame are equal to the preset values
            case COLOR_STATE_FOCUSED :
            res &=this.BackColor()==this.BackColorFocused();
            res &=this.ForeColor()==this.ForeColorFocused();
            res &=this.BorderColor()==this.BorderColorFocused();
            break;
        
    // --- check that all PRESSED colors of the background, text and frame are equal to the preset values
            case COLOR_STATE_PRESSED :
            res &=this.BackColor()==this.BackColorPressed();
            res &=this.ForeColor()==this.ForeColorPressed();
            res &=this.BorderColor()==this.BorderColorPressed();
            break;
        
    // --- check that all BLOCKED colors of the background, text and frame are equal to the preset values
            case COLOR_STATE_BLOCKED :
            res &=this.BackColor()==this.BackColorBlocked();
            res &=this.ForeColor()==this.ForeColorBlocked();
            res &=this.BorderColor()==this.BorderColorBlocked();
            break;
            
            default: res=false;
            break;
        }
        return res;
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Changing the color of object elements by event      |
  //+------------------------------------------------------------------+
  void CCanvasBase::ColorChange(const ENUM_COLOR_STATE state)
   {
    // --- Depending on the event, set the event colors as the main ones
        switch(state)
        {
            case COLOR_STATE_DEFAULT   :  this.ColorsToDefault(); break;
            case COLOR_STATE_FOCUSED   :  this.ColorsToFocused(); break;
            case COLOR_STATE_PRESSED   :  this.ColorsToPressed(); break;
            case COLOR_STATE_BLOCKED   :  this.ColorsToBlocked(); break;
            default                    :  break;
        }
  }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Event Handler                                       |
  //+------------------------------------------------------------------+
  void CCanvasBase::OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
   {
    // --- If at the time of launching the terminal with the indicator the height of the subwindow has not yet been determined,
    // --- adjust the distance between the top frame of the indicator subwindow and the top frame of the main window
        if(this.m_wnd>0 && this.m_wnd_y==0)
            this.m_wnd_y=(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOW_YDISTANCE,this.m_wnd);

    // --- Schedule change event
        if(id==CHARTEVENT_CHART_CHANGE)
        {
            // --- adjust the distance between the upper frame of the indicator subwindow and the upper frame of the main chart window
            this.m_wnd_y=(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOW_YDISTANCE,this.m_wnd);
        }
        
    // --- Graphic object creation event
        if(id==CHARTEVENT_OBJECT_CREATE)
        {
            // --- If this is not a container element, leave
            if(this.Type()<ELEMENT_TYPE_PANEL)
                return;
            // --- Call the graphical object creation handler
            this.OnCreateEvent(id,lparam,dparam,sparam);
        }

    // --- If the element is blocked or hidden, leave
        if(this.IsBlocked() || this.IsHidden())
            return;
            
    // --- Mouse cursor coordinates
        int x=(int)lparam;
        int y=(int)dparam-this.m_wnd_y;  // Adjusting Y according to the height of the indicator window
        
    // --- Cursor movement event
        if(id==CHARTEVENT_MOUSE_MOVE)
        {
            // --- Send the cursor coordinates to the resource manager
            CCommonManager::GetInstance().SetCursorX(x);
            CCommonManager::GetInstance().SetCursorY(y);

            // --- Inactive elements, except the main one, are not processed
            if(!this.IsMain() && (this.Type()<ACTIVE_ELEMENT_MIN || this.Type()>ACTIVE_ELEMENT_MAX))
                return;

            // --- Mouse button held down
            if(sparam=="1")
            {
                // --- Cursor within object
                if(this.Contains(x, y))
                {
                // --- If this is the main object, we disable the chart tools
                if(this.IsMain())
                    this.SetFlags(false);
                
                // --- If the mouse button was pressed on the chart, there is nothing to process, we leave
                if(this.ActiveElementName()=="Chart")
                    return;
                    
                // --- Fix the name of the active element over which the cursor was when the mouse button was pressed
                this.SetActiveElementName(this.ActiveElementName());
                // --- If this is the current active element, we process its movement
                if(this.IsCurrentActiveElement())
                {
                    this.OnMoveEvent(id,lparam,dparam,sparam);
                    
                    // --- If the element has auto-repeat events active, indicate that the button is pressed
                    if(this.m_autorepeat_flag)
                        this.m_autorepeat.OnButtonPress();
                
                    // --- For resizable elements
                    if(this.m_resizable)
                    {
                        // --- If resizing mode is not activated,
                        // --- call the start resizing handler
                        if(!this.ResizeMode())
                            this.OnResizeZoneEvent(RESIZE_ZONE_ACTION_BEGIN,x,y,this.NameFG());
                        // --- otherwise, when resizing mode is active
                        // --- call the edge drag handler to resize
                        else
                            this.OnResizeZoneEvent(RESIZE_ZONE_ACTION_DRAG,x,y,this.NameFG());
                    }
                }
                }
                // --- Cursor outside object
                else
                {
                // --- If this is the active main object, or the mouse button is held down on the chart, and this is not a resizing mode, enable the chart tools
                if(this.IsMain() && (this.ActiveElementName()==this.NameFG() || this.ActiveElementName()=="Chart"))
                    if(!this.ResizeMode())
                        this.SetFlags(true);
                    
                // --- If this is the current active element
                if(this.IsCurrentActiveElement())
                {
                    // --- If the element is not movable
                    if(!this.IsMovable())
                    {
                        // --- call the mouse hover handler
                        this.OnFocusEvent(id,lparam,dparam,sparam);
                        // --- If the element has auto-repeat events active, indicate that the button is released
                        if(this.m_autorepeat_flag)
                            this.m_autorepeat.OnButtonRelease();
                    }
                    // --- If the element is moved, call the move handler
                    else
                        this.OnMoveEvent(id,lparam,dparam,sparam);
                
                    // --- For resizable elements
                    // --- call the edge drag handler to resize
                    if(this.m_resizable)
                        this.OnResizeZoneEvent(RESIZE_ZONE_ACTION_DRAG,x,y,this.NameFG());
                }
                }
            }
            
            // --- Mouse button not pressed
            else
            {
                // --- Cursor within object
                if(this.Contains(x, y))
                {
                // --- If this is the main element, turn off the chart tools
                if(this.IsMain())
                    this.SetFlags(false);
                
                // --- Call the hover handler and
                // --- set the element as currently active
                this.OnFocusEvent(id,lparam,dparam,sparam);
                this.SetActiveElementName(this.NameFG());
                
                // --- For resizable elements
                // --- call the handler for hovering the cursor over the resizing area
                if(this.m_resizable)
                    this.OnResizeZoneEvent(RESIZE_ZONE_ACTION_HOVER,x,y,this.NameFG());
                }
                
                // --- Cursor outside object
                else
                {
                // ---If this is the main object
                if(this.IsMain())
                {
                    // --- Allow chart tools and
                    // --- set the chart as the current active element
                    this.SetFlags(true);
                    this.SetActiveElementName("Chart");
                }
                // --- Call the handler for removing the cursor from focus
                this.OnReleaseEvent(id,lparam,dparam,sparam);
                
                // --- For resizable elements
                // --- call the non-resizing mode handler
                if(this.m_resizable)
                    this.OnResizeZoneEvent(RESIZE_ZONE_ACTION_NONE,x,y,this.NameFG());
                }
            }
        }
        
    // --- Event of a mouse button click on an object (button release)
        if(id==CHARTEVENT_OBJECT_CLICK)
        {
            // --- If the click (releasing the mouse button) was on this object
            if(sparam==this.NameFG())
            {
                // --- Call the mouse click handler and release the current active object
                this.OnPressEvent(id, lparam, dparam, sparam);
                this.SetActiveElementName("");
                    
                // --- If the element has auto-repeat events active, indicate that the button is released
                if(this.m_autorepeat_flag)
                this.m_autorepeat.OnButtonRelease();
                
                // --- For resizable elements
                if(this.m_resizable)
                {
                // --- Disable resizing mode, reset the interaction area,
                // --- call the handler for completing resizing by dragging faces
                this.SetResizeMode(false);
                this.SetResizeRegion(CURSOR_REGION_NONE);
                this.OnResizeZoneEvent(RESIZE_ZONE_ACTION_END,x,y,this.NameFG());
                }
            }
        }
        
    // --- Mouse wheel scroll event
        if(id==CHARTEVENT_MOUSE_WHEEL)
        {
            // --- If this is an active element, call its wheel scroll event handler
            if(this.IsCurrentActiveElement())
                this.OnWheelEvent(id,lparam,dparam,this.ActiveElementName());  // in sparam we pass the name of the active element
        }

    // --- If a custom chart event has arrived
        if(id>CHARTEVENT_CUSTOM)
        {
            // --- We do not process our own events
            if(sparam==this.NameFG())
                return;

            // --- bring the custom event into line with the standard ones
            ENUM_CHART_EVENT chart_event=ENUM_CHART_EVENT(id-CHARTEVENT_CUSTOM);
            // --- If the mouse clicks on an object, we call the custom event handler
            if(chart_event==CHARTEVENT_OBJECT_CLICK)
            {
                this.MousePressHandler(chart_event, lparam, dparam, sparam);
            }
            // --- If the mouse cursor is moving, call the custom event handler
            if(chart_event==CHARTEVENT_MOUSE_MOVE)
            {
                this.MouseMoveHandler(chart_event, lparam, dparam, sparam);
            }
            // --- If the mouse wheel is scrolling, call the custom event handler
            if(chart_event==CHARTEVENT_MOUSE_WHEEL)
            {
                this.MouseWheelHandler(chart_event, lparam, dparam, sparam);
            }
            // --- If the graphic element changes, call the custom event handler
            if(chart_event==CHARTEVENT_OBJECT_CHANGE)
            {
                this.ObjectChangeHandler(chart_event, lparam, dparam, sparam);
            }
        }
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Focus loss handler |
  //+------------------------------------------------------------------+
  void CCanvasBase::OnReleaseEvent(const int id,const long lparam,const double dparam,const string sparam)
   {
    // --- The element is not in focus when moving the cursor away
        this.m_focused=false;
    // --- restore the original colors and redraw the object
        if(!this.CheckColor(COLOR_STATE_DEFAULT))
        {
            this.ColorChange(COLOR_STATE_DEFAULT);
            this.Draw(true);
        }
    // --- Initialize the cursor indent from the upper left corner of the element along the X and Y axes
        this.m_cursor_delta_x=0;
        this.m_cursor_delta_y=0;
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Hover Handler                                       |
  //+------------------------------------------------------------------+
  void CCanvasBase::OnFocusEvent(const int id,const long lparam,const double dparam,const string sparam)
   {
    // ---Element in focus
        this.m_focused=true;
    // --- If the object colors are not for Focused mode
        if(!this.CheckColor(COLOR_STATE_FOCUSED))
        {
            // --- set the colors and the Focused flag and redraw the object
            this.ColorChange(COLOR_STATE_FOCUSED);
            this.Draw(true);
        }
    // --- Initialize the cursor indent from the upper left corner of the element along the X and Y axes
        this.m_cursor_delta_x=0;
        this.m_cursor_delta_y=0;
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Object click handler                                |
  //+------------------------------------------------------------------+
  void CCanvasBase::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
   {
    // --- Element in focus when clicked on it
        this.m_focused=true;
    // --- If the object colors are not for Pressed mode
        if(!this.CheckColor(COLOR_STATE_PRESSED))
        {
            // --- set the colors to Pressed and redraw the object
            this.ColorChange(COLOR_STATE_PRESSED);
            this.Draw(true);
        }
    // --- Initialize the cursor indent from the upper left corner of the element along the X and Y axes
        this.m_cursor_delta_x=0;
        this.m_cursor_delta_y=0;
    // --- send a custom event to the chart with the passed values ​​in lparam, dparam, and the object name in sparam
        ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_OBJECT_CLICK, lparam, dparam, this.NameFG());
   }
  //+------------------------------------------------------------------+
  //| CCanvasBase::Cursor move handler                                 |
  //+------------------------------------------------------------------+
  void CCanvasBase::OnMoveEvent(const int id,const long lparam,const double dparam,const string sparam)
   {
    // --- Element in focus when clicked on it
        this.m_focused=true;
    // --- If the object colors are not for Pressed mode
        if(!this.CheckColor(COLOR_STATE_PRESSED))
        {
            // --- set the colors to Pressed and redraw the object
            this.ColorChange(COLOR_STATE_PRESSED);
            this.Draw(true);
        }
    // --- Calculate the cursor indent from the upper left corner of the element along the X and Y axes
        if(this.m_cursor_delta_x==0)
            this.m_cursor_delta_x=(int)lparam-this.X();
        if(this.m_cursor_delta_y==0)
            this.m_cursor_delta_y=(int)::round(dparam-this.Y());
   }
  //+------------------------------------------------------------------+
  // | CCanvasBase::Event handler for creating a graphic object        |
  //+------------------------------------------------------------------+
   void CCanvasBase::OnCreateEvent(const int id,const long lparam,const double dparam,const string sparam)
    {
     // --- if the created object belongs to this program - leave
        if(this.IsBelongsToThis(sparam))
            return;
     // --- move the object to the foreground
        this.BringToTop(true);
    }
    //+------------------------------------------------------------------+
 #endif // CCANVASBASE_IMPLEMENTATION
#endif // __CANVASBASE_MQH__
