//+------------------------------------------------------------------+
   //| Base graphic element canvas class |
   //+------------------------------------------------------------------+
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
         
         CColorElement     m_color_background_act;                   // Object to control the background color of the activated element
         CColorElement     m_color_foreground_act;                   // The activated element's foreground color control object
         CColorElement     m_color_border_act;                       // Object for controlling the border color of an activated element
        //| Update in                                                        |
        //|       Integrating the Model Component into the View Component    |
        //|                           https://www.mql5.com/en/articles/19288 | 
         CAutoRepeat       m_autorepeat;                             // Event auto-repeat control object
         
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
         
      // --- (1) Sets, (2) returns the resizing mode flag
         void              SetResizeMode(const bool flag)            { CCommonManager::GetInstance().SetResizeMode(flag);                                }
         bool              ResizeMode(void)                    const { return CCommonManager::GetInstance().ResizeMode();                                }
         
      // --- (1) Sets, (2) returns the edge of the element to be resized.
         void              SetResizeRegion(const ENUM_CURSOR_REGION edge){ CCommonManager::GetInstance().SetResizeRegion(edge);                          }
         ENUM_CURSOR_REGION ResizeRegion(void)                 const { return CCommonManager::GetInstance().ResizeRegion();                              }
         
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
                           CCanvasBase(void) :
                              m_program_name(::MQLInfoString(MQL_PROGRAM_NAME)), m_chart_id(::ChartID()), m_wnd(0), m_alpha_bg(0), m_alpha_fg(255), 
                              m_hidden(false), m_blocked(false), m_focused(false), m_movable(false), m_resizable(false), m_main(false), 
                              m_autorepeat_flag(false), m_trim_flag(true), m_cropped(false), m_scroll_flag(false),
                              m_border_width_lt(0), m_border_width_rt(0), m_border_width_up(0), m_border_width_dn(0), m_z_order(0),
                              m_state(0), m_wnd_y(0), m_cursor_delta_x(0), m_cursor_delta_y(0) { this.CreateCanvasObjects(); this.Init(); }
                           CCanvasBase(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
                        ~CCanvasBase(void);
   };