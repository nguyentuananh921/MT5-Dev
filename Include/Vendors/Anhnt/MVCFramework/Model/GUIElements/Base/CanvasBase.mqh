//+------------------------------------------------------------------+
//|                                                 CanvasBase.mqh   |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __CANVASBASE_MQH__
#define __CANVASBASE_MQH__
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Canvas/Canvas.mqh>
//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "BaseDefines.mqh"
#include "BaseEnums.mqh"

#include "BoundedObj.mqh"
#include "ColorElement.mqh"
#include "AutoRepeat.mqh"
#include "CommonManager.mqh"

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Base canvas class for graphical elements                         |
//+------------------------------------------------------------------+
class CCanvasBase : public CBoundedObj
{

   private: 
      bool              m_chart_mouse_wheel_flag;                 // Flag for sending mouse wheel scroll messages
      bool              m_chart_mouse_move_flag;                  // Flag for sending mouse cursor movement messages
      bool              m_chart_object_create_flag;               // Flag for sending graphical object creation event messages
      bool              m_chart_mouse_scroll_flag;                // Flag for chart scrolling with left button and mouse wheel
      bool              m_chart_context_menu_flag;                // Flag for context menu access via right mouse button click
      bool              m_chart_crosshair_tool_flag;              // Flag for "Crosshair" tool access via middle mouse button click
      bool              m_flags_state;                            // State of chart scroll, context menu, and crosshair flags
      
   //--- Setting restrictions for the chart (mouse wheel scroll, context menu, and crosshair)
      void              SetFlags(const bool flag);
      
   protected:
      CCanvas          *m_background;                             // Canvas for drawing the background
      CCanvas          *m_foreground;                             // Canvas for drawing the foreground
      CCanvasBase      *m_container;                              // Parent container object
      CColorElement     m_color_background;                       // Background color control object
      CColorElement     m_color_foreground;                       // Foreground color control object
      CColorElement     m_color_border;                           // Border color control object
      
      CColorElement     m_color_background_act;                   // Background color control object for the activated element
      CColorElement     m_color_foreground_act;                   // Foreground color control object for the activated element
      CColorElement     m_color_border_act;                       // Border color control object for the activated element
      
      CAutoRepeat       m_autorepeat;                             // Event auto-repeat control object
      
      ENUM_ELEMENT_STATE m_state;                                 // Element state (e.g., button (on/off))
      long              m_chart_id;                               // Chart identifier
      int               m_wnd;                                    // Chart subwindow number
      int               m_wnd_y;                                  // Y-coordinate offset of the cursor in the subwindow
      int               m_obj_x;                                  // X-coordinate of the graphical object
      int               m_obj_y;                                  // Y-coordinate of the graphical object
      uchar             m_alpha_bg;                               // Background transparency
      uchar             m_alpha_fg;                               // Foreground transparency
      uint              m_border_width_lt;                        // Left border width
      uint              m_border_width_rt;                        // Right border width
      uint              m_border_width_up;                        // Top border width
      uint              m_border_width_dn;                        // Bottom border width
      string            m_program_name;                           // Program name
      bool              m_hidden;                                 // Hidden object flag
      bool              m_blocked;                                // Blocked element flag
      bool              m_movable;                                // Movable element flag
      bool              m_resizable;                              // Resize permission flag
      bool              m_focused;                                // Focused element flag
      bool              m_main;                                   // Main object flag
      bool              m_autorepeat_flag;                        // Event auto-repeat flag
      bool              m_scroll_flag;                            // Content scrolling flag using scrollbars
      bool              m_trim_flag;                              // Flag for trimming element by container boundaries
      bool              m_cropped;                                // Flag indicating the object is hidden beyond container boundaries
      int               m_cursor_delta_x;                         // Distance from cursor to the left edge of the element
      int               m_cursor_delta_y;                         // Distance from cursor to the top edge of the element
      int               m_z_order;                                // Z-order of the graphical object                                                 }
   //--- (1) Sets the name, returns (2) the name, (3) the active element flag
      void               SetActiveElementName(const string name)   { CCommonManager::GetInstance().SetElementName(name);                               }
      string             ActiveElementName(void)             const { return CCommonManager::GetInstance().ElementName();                               }
      bool               IsCurrentActiveElement(void)        const { return this.ActiveElementName()==this.NameFG();                                   }
      
   //--- (1) Sets, (2) returns the resize mode flag
      void               SetResizeMode(const bool flag)            { CCommonManager::GetInstance().SetResizeMode(flag);                                }
      bool               ResizeMode(void)                    const { return CCommonManager::GetInstance().ResizeMode();                                }
      
   //--- (1) Sets, (2) returns the element edge by which the size is changed
      void               SetResizeRegion(const ENUM_CURSOR_REGION edge){ CCommonManager::GetInstance().SetResizeRegion(edge);                          }
      ENUM_CURSOR_REGION ResizeRegion(void)                 const { return CCommonManager::GetInstance().ResizeRegion();                               }
      
   //--- Returns the offsets of the initial drawing coordinates on the canvas relative to the canvas and object coordinates
      int                CanvasOffsetX(void)                 const { return(this.ObjectX()-this.X());                                                  }
      int                CanvasOffsetY(void)                 const { return(this.ObjectY()-this.Y());                                                  }
   //--- Returns the adjusted coordinate of a point on the canvas, taking into account the canvas offset relative to the object
      int                AdjX(const int x)                   const { return(x-this.CanvasOffsetX());                                                   }
      int                AdjY(const int y)                   const { return(y-this.CanvasOffsetY());                                                   }
      
   //--- Returns the corrected chart ID
      long               CorrectChartID(const long chart_id) const { return(chart_id!=0 ? chart_id : ::ChartID());                                     }

   public:
   //--- Getting the boundaries of the parent container object
      int                ContainerLimitLeft(void)            const { return(this.m_container==NULL ? this.ObjectX()     : this.m_container.LimitLeft());  }
      int                ContainerLimitRight(void)           const { return(this.m_container==NULL ? this.ObjectRight() : this.m_container.LimitRight()); }
      int                ContainerLimitTop(void)             const { return(this.m_container==NULL ? this.ObjectY()     : this.m_container.LimitTop());   }
      int                ContainerLimitBottom(void)          const { return(this.m_container==NULL ? this.ObjectBottom(): this.m_container.LimitBottom());}
      string             ContainerDescription(void)          const { return(this.m_container==NULL ? "Not specified"    : this.m_container.Description());}
      
   //--- Returns the coordinates, boundaries, and sizes of the graphical object
      int                ObjectX(void)                       const { return this.m_obj_x;                                                              }
      int                ObjectY(void)                       const { return this.m_obj_y;                                                              }
      int                ObjectWidth(void)                   const { return this.m_background.Width();                                                 }
      int                ObjectHeight(void)                  const { return this.m_background.Height();                                                }
      int                ObjectRight(void)                   const { return this.ObjectX()+this.ObjectWidth()-1;                                       }
      int                ObjectBottom(void)                  const { return this.ObjectY()+this.ObjectHeight()-1;                                      }
      
   //--- Changes (1) width, (2) height, (3) size of the graphical object
   protected:
      virtual bool       ObjectResizeW(const int size);
      virtual bool       ObjectResizeH(const int size);
      bool               ObjectResize(const int w,const int h);
      
   //--- Sets (1) X, (2) Y coordinate, (3) both coordinates of the graphical object
      virtual bool       ObjectSetX(const int x);
      virtual bool       ObjectSetY(const int y);
      bool               ObjectSetXY(const int x,const int y)      { return(this.ObjectSetX(x) && this.ObjectSetY(y));                                 }
      
   //--- Sets both coordinates and sizes of the graphical object simultaneously
      virtual bool       ObjectSetXYWidthResize(const int x,const int y,const int w,const int h);
      
   //--- (1) Sets, (2) shifts the graphical object to the specified coordinates/offset size
      bool               ObjectMove(const int x,const int y)       { return this.ObjectSetXY(x,y);                                                     }
      bool               ObjectShift(const int dx,const int dy)    { return this.ObjectSetXY(this.ObjectX()+dx,this.ObjectY()+dy);                     }
      
   //--- Returns a flag indicating if the cursor is inside the object
      bool               Contains(const int x,const int y);
   //--- Returns the cursor position on the object boundaries
      ENUM_CURSOR_REGION CheckResizeZone(const int x,const int y);
      
   //--- Checks if the set color is equal to the specified one
      bool               CheckColor(const ENUM_COLOR_STATE state) const;
   //--- Changes background, text, and border colors depending on the condition
      void               ColorChange(const ENUM_COLOR_STATE state);
      
   //--- Initialization of (1) class object, (2) default object colors 
      void               Init(void);
      void               InitColors(void);

   //--- Event handlers: (1) hover (Focus), (2) mouse button clicks (Press),
   //--- (3) cursor movement (Move), (4) focus loss (Release), (5) graphical object creation (Create),
   //--- (6) wheel scroll (Wheel), (7) resizing (Resize). Overridden in descendants.
      virtual void       OnFocusEvent(const int id, const long lparam, const double dparam, const string sparam);
      virtual void       OnPressEvent(const int id, const long lparam, const double dparam, const string sparam);
      virtual void       OnMoveEvent(const int id, const long lparam, const double dparam, const string sparam);
      virtual void       OnReleaseEvent(const int id, const long lparam, const double dparam, const string sparam);
      virtual void       OnCreateEvent(const int id, const long lparam, const double dparam, const string sparam);
      virtual void       OnWheelEvent(const int id, const long lparam, const double dparam, const string sparam)          { return;         }  // handler is disabled here
      virtual void       OnResizeZoneEvent(const int id, const long lparam, const double dparam, const string sparam)     { return;         }  // handler is disabled here
      
   //--- Handlers for resizing the element by sides and corners
      virtual bool       OnResizeZoneLeft(const int x, const int y)                                                      { return false;   }  // handler is disabled here
      virtual bool       OnResizeZoneRight(const int x, const int y)                                                     { return false;   }  // handler is disabled here
      virtual bool       OnResizeZoneTop(const int x, const int y)                                                       { return false;   }  // handler is disabled here
      virtual bool       OnResizeZoneBottom(const int x, const int y)                                                    { return false;   }  // handler is disabled here
      virtual bool       OnResizeZoneLeftTop(const int x, const int y)                                                   { return false;   }  // handler is disabled here
      virtual bool       OnResizeZoneRightTop(const int x, const int y)                                                  { return false;   }  // handler is disabled here
      virtual bool       OnResizeZoneLeftBottom(const int x, const int y)                                                { return false;   }  // handler is disabled here
      virtual bool       OnResizeZoneRightBottom(const int x, const int y)                                               { return false;   }  // handler is disabled here
         
   //--- Custom element event handlers for cursor hover, click, wheel scroll in the object area, and its change
      virtual void       MouseMoveHandler(const int id, const long lparam, const double dparam, const string sparam)     { return;         }  // handler is disabled here
      virtual void       MousePressHandler(const int id, const long lparam, const double dparam, const string sparam)    { return;         }  // handler is disabled here
      virtual void       MouseWheelHandler(const int id, const long lparam, const double dparam, const string sparam)    { return;         }  // handler is disabled here
      virtual void       ObjectChangeHandler(const int id, const long lparam, const double dparam, const string sparam)  { return;         }  // handler is disabled here
      
   public:
   //--- Returns a pointer to (1) container, (2) event auto-repeat class object
      CCanvasBase      *GetContainer(void)                  const { return this.m_container;                                                           } 
      CAutoRepeat      *GetAutorepeatObj(void)                    { return &this.m_autorepeat;                                                         }

   //--- Returns a pointer to (1) background canvas, (2) foreground canvas
      CCanvas          *GetBackground(void)                       { return this.m_background;                                                          }
      CCanvas          *GetForeground(void)                       { return this.m_foreground;                                                          }
      
   //--- Returns a pointer to the color control object for (1) background, (2) foreground, (3) border
      CColorElement    *GetBackColorControl(void)                 { return &this.m_color_background;                                                   }
      CColorElement    *GetForeColorControl(void)                 { return &this.m_color_foreground;                                                   }
      CColorElement    *GetBorderColorControl(void)               { return &this.m_color_border;                                                       }
      
   //--- Returns a pointer to the color control object for (1) background, (2) foreground, (3) border of the activated element
      CColorElement    *GetBackColorActControl(void)              { return &this.m_color_background_act;                                               }
      CColorElement    *GetForeColorActControl(void)              { return &this.m_color_foreground_act;                                               }
      CColorElement    *GetBorderColorActControl(void)            { return &this.m_color_border_act;                                                   }

   //--- Returns current color of (1) background, (2) foreground, (3) border
      color             BackColor(void)         const { return(!this.State() ? this.m_color_background.GetCurrent() : this.m_color_background_act.GetCurrent());  }
      color             ForeColor(void)         const { return(!this.State() ? this.m_color_foreground.GetCurrent() : this.m_color_foreground_act.GetCurrent());  }
      color             BorderColor(void)       const { return(!this.State() ? this.m_color_border.GetCurrent()     : this.m_color_border_act.GetCurrent());      }
      
   //--- Returns preset DEFAULT color for (1) background, (2) foreground, (3) border
      color             BackColorDefault(void)  const { return(!this.State() ? this.m_color_background.GetDefault() : this.m_color_background_act.GetDefault());  }
      color             ForeColorDefault(void)  const { return(!this.State() ? this.m_color_foreground.GetDefault() : this.m_color_foreground_act.GetDefault());  }
      color             BorderColorDefault(void)const { return(!this.State() ? this.m_color_border.GetDefault()     : this.m_color_border_act.GetDefault());      }
      
   //--- Returns preset FOCUSED color for (1) background, (2) foreground, (3) border
      color             BackColorFocused(void)  const { return(!this.State() ? this.m_color_background.GetFocused() : this.m_color_background_act.GetFocused());  }
      color             ForeColorFocused(void)  const { return(!this.State() ? this.m_color_foreground.GetFocused() : this.m_color_foreground_act.GetFocused());  }
      color             BorderColorFocused(void)const { return(!this.State() ? this.m_color_border.GetFocused()     : this.m_color_border_act.GetFocused());      }
      
   //--- Returns preset PRESSED color for (1) background, (2) foreground, (3) border
      color             BackColorPressed(void)  const { return(!this.State() ? this.m_color_background.GetPressed() : this.m_color_background_act.GetPressed());  }
      color             ForeColorPressed(void)  const { return(!this.State() ? this.m_color_foreground.GetPressed() : this.m_color_foreground_act.GetPressed());  }
      color             BorderColorPressed(void)const { return(!this.State() ? this.m_color_border.GetPressed()     : this.m_color_border_act.GetPressed());      }
      
   //--- Returns preset BLOCKED color for (1) background, (2) foreground, (3) border
      color             BackColorBlocked(void)              const { return this.m_color_background.GetBlocked();                                       }
      color             ForeColorBlocked(void)              const { return this.m_color_foreground.GetBlocked();                                       }
      color             BorderColorBlocked(void)            const { return this.m_color_border.GetBlocked();                                           }
      
   //--- Setting background colors for all states
      void               InitBackColors(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                        {
                           this.m_color_background.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                        }
      void               InitBackColors(const color clr)           { this.m_color_background.InitColors(clr);                                          }

   //--- Setting foreground colors for all states
      void               InitForeColors(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                        {
                           this.m_color_foreground.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                        }
      void               InitForeColors(const color clr)           { this.m_color_foreground.InitColors(clr);                                          }

   //--- Setting border colors for all states
      void               InitBorderColors(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                        {
                           this.m_color_border.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                        }
      void               InitBorderColors(const color clr)         { this.m_color_border.InitColors(clr);                                              }

   //--- Initializing (1) background, (2) foreground, (3) border color with initial values
      void               InitBackColorDefault(const color clr)     { this.m_color_background.InitDefault(clr);                                         }
      void               InitForeColorDefault(const color clr)     { this.m_color_foreground.InitDefault(clr);                                         }
      void               InitBorderColorDefault(const color clr)   { this.m_color_border.InitDefault(clr);                                             }
      
   //--- Initializing (1) background, (2) foreground, (3) border color on hover with initial values
      void               InitBackColorFocused(const color clr)     { this.m_color_background.InitFocused(clr);                                         }
      void               InitForeColorFocused(const color clr)     { this.m_color_foreground.InitFocused(clr);                                         }
      void               InitBorderColorFocused(const color clr)   { this.m_color_border.InitFocused(clr);                                             }
      
   //--- Initializing (1) background, (2) foreground, (3) border color on click with initial values
      void               InitBackColorPressed(const color clr)     { this.m_color_background.InitPressed(clr);                                         }
      void               InitForeColorPressed(const color clr)     { this.m_color_foreground.InitPressed(clr);                                         }
      void               InitBorderColorPressed(const color clr)   { this.m_color_border.InitPressed(clr);                                             }
      
   //--- Initializing (1) background, (2) foreground, (3) border color for blocked object with initial values
      void               InitBackColorBlocked(const color clr)     { this.m_color_background.InitBlocked(clr);                                         }
      void               InitForeColorBlocked(const color clr)     { this.m_color_foreground.InitBlocked(clr);                                         }
      void               InitBorderColorBlocked(const color clr)   { this.m_color_border.InitBlocked(clr);                                             }
      
   //--- Setting background colors for all states (Activated)
      void               InitBackColorsAct(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                        {
                           this.m_color_background_act.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                        }
      void               InitBackColorsAct(const color clr)        { this.m_color_background_act.InitColors(clr);                                      }

   //--- Setting foreground colors for all states (Activated)
      void               InitForeColorsAct(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                        {
                           this.m_color_foreground_act.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                        }
      void               InitForeColorsAct(const color clr)        { this.m_color_foreground_act.InitColors(clr);                                      }

   //--- Setting border colors for all states (Activated)
      void               InitBorderColorsAct(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked)
                        {
                           this.m_color_border_act.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
                        }
      void               InitBorderColorsAct(const color clr)      { this.m_color_border_act.InitColors(clr);                                          }

   //--- Initializing (1) background, (2) foreground, (3) border color with initial values (Activated)
      void               InitBackColorActDefault(const color clr)  { this.m_color_background_act.InitDefault(clr);                                     }
      void               InitForeColorActDefault(const color clr)  { this.m_color_foreground_act.InitDefault(clr);                                     }
      void               InitBorderColorActDefault(const color clr){ this.m_color_border_act.InitDefault(clr);                                         }
      
   //--- Initializing (1) background, (2) foreground, (3) border color on hover with initial values (Activated)
      void               InitBackColorActFocused(const color clr)  { this.m_color_background_act.InitFocused(clr);                                     }
      void               InitForeColorActFocused(const color clr)  { this.m_color_foreground_act.InitFocused(clr);                                     }
      void               InitBorderColorActFocused(const color clr){ this.m_color_border_act.InitFocused(clr);                                         }
      
   //--- Initializing (1) background, (2) foreground, (3) border color on click with initial values (Activated)
      void               InitBackColorActPressed(const color clr)  { this.m_color_background_act.InitPressed(clr);                                     }
      void               InitForeColorActPressed(const color clr)  { this.m_color_foreground_act.InitPressed(clr);                                     }
      void               InitBorderColorActPressed(const color clr){ this.m_color_border_act.InitPressed(clr);                                         }
   //--- Setting the current background color to various states
      bool               BackColorToDefault(void)
                           {
                           return(!this.State() ? this.m_color_background.SetCurrentAs(COLOR_STATE_DEFAULT) :
                                                   this.m_color_background_act.SetCurrentAs(COLOR_STATE_DEFAULT));
                           }
      bool               BackColorToFocused(void)
                           {
                           return(!this.State() ? this.m_color_background.SetCurrentAs(COLOR_STATE_FOCUSED) :
                                                   this.m_color_background_act.SetCurrentAs(COLOR_STATE_FOCUSED));
                           }
      bool               BackColorToPressed(void)
                           {
                           return(!this.State() ? this.m_color_background.SetCurrentAs(COLOR_STATE_PRESSED) :
                                                   this.m_color_background_act.SetCurrentAs(COLOR_STATE_PRESSED));
                           }
      bool               BackColorToBlocked(void)   { return this.m_color_background.SetCurrentAs(COLOR_STATE_BLOCKED);  }
      
   //--- Setting the current foreground color to various states
      bool               ForeColorToDefault(void)
                           { return(!this.State() ? this.m_color_foreground.SetCurrentAs(COLOR_STATE_DEFAULT) :
                                                   this.m_color_foreground_act.SetCurrentAs(COLOR_STATE_DEFAULT));
                           }
      bool               ForeColorToFocused(void)
                           { return(!this.State() ? this.m_color_foreground.SetCurrentAs(COLOR_STATE_FOCUSED) :
                                                   this.m_color_foreground_act.SetCurrentAs(COLOR_STATE_FOCUSED));
                           }
      bool               ForeColorToPressed(void)
                           { return(!this.State() ? this.m_color_foreground.SetCurrentAs(COLOR_STATE_PRESSED) :
                                                   this.m_color_foreground_act.SetCurrentAs(COLOR_STATE_PRESSED));
                           }
      bool               ForeColorToBlocked(void)   { return this.m_color_foreground.SetCurrentAs(COLOR_STATE_BLOCKED);  }
      
   //--- Setting the current border color to various states
      bool               BorderColorToDefault(void)
                           { return(!this.State() ? this.m_color_border.SetCurrentAs(COLOR_STATE_DEFAULT) :
                                                   this.m_color_border_act.SetCurrentAs(COLOR_STATE_DEFAULT));
                           }
      bool               BorderColorToFocused(void)
                           { return(!this.State() ? this.m_color_border.SetCurrentAs(COLOR_STATE_FOCUSED) :
                                                   this.m_color_border_act.SetCurrentAs(COLOR_STATE_FOCUSED));
                           }
      bool               BorderColorToPressed(void)
                           { return(!this.State() ? this.m_color_border.SetCurrentAs(COLOR_STATE_PRESSED) :
                                                   this.m_color_border_act.SetCurrentAs(COLOR_STATE_PRESSED));
                           }
      bool               BorderColorToBlocked(void) { return this.m_color_border.SetCurrentAs(COLOR_STATE_BLOCKED);      }
      
   //--- Setting the current element colors to various states
      bool               ColorsToDefault(void);
      bool               ColorsToFocused(void);
      bool               ColorsToPressed(void);
      bool               ColorsToBlocked(void);
      
   //--- Sets the pointer to the parent container object
      void               SetContainerObj(CCanvasBase *obj);
      
   protected:
   //--- Creates background and foreground canvases
      bool               CreateCanvasObjects(void);
   //--- Creates OBJ_BITMAP_LABEL
      bool               Create(const long chart_id,const int wnd,const string object_name,const int x,const int y,const int w,const int h); 
   public:
   //--- (1) Sets, (2) returns the state
      void               SetState(ENUM_ELEMENT_STATE state)        { this.m_state=state; this.ColorsToDefault();                                      }
      ENUM_ELEMENT_STATE State(void)                         const { return this.m_state;                                                              }

   //--- (1) Sets, (2) returns the z-order
      bool               ObjectSetZOrder(const int value);
      int                ObjectZOrder(void)                  const { return this.m_z_order;                                                            }
      
   //--- Returns (1) object belonging to the program, flag for (2) hidden, (3) blocked,
   //--- (4) movable, (5) resizable, (6) main element, (7) in focus, (8, 9) graphic object name (background, text)
      bool               IsBelongsToThis(const string name)  const { return(::ObjectGetString(this.m_chart_id,name,OBJPROP_TEXT)==this.m_program_name);}
      bool               IsHidden(void)                      const { return this.m_hidden;                                                             }
      bool               IsBlocked(void)                     const { return this.m_blocked;                                                            }
      bool               IsMovable(void)                     const { return this.m_movable;                                                            }
      bool               IsResizable(void)                   const { return this.m_resizable;                                                          }
      bool               IsMain(void)                        const { return this.m_main;                                                               }
      bool               IsFocused(void)                     const { return this.m_focused;                                                            }
      bool               IsAutorepeat(void)                  const { return this.m_autorepeat_flag;                                                    }
      bool               IsScrollable(void)                  const { return this.m_scroll_flag;                                                        }
      bool               IsTrimmed(void)                     const { return this.m_trim_flag;                                                          }
      bool               IsCropped(void)                     const { return this.m_cropped;                                                            }
      string             NameBG(void)                        const { return this.m_background.ChartObjectName();                                       }
      string             NameFG(void)                        const { return this.m_foreground.ChartObjectName();                                       }
      
   //--- (1) Returns, (2) sets background transparency
      uchar              AlphaBG(void)                       const { return this.m_alpha_bg;                                                           }
      void               SetAlphaBG(const uchar value)             { this.m_alpha_bg=value;                                                            }
   //--- (1) Returns, (2) sets foreground transparency
      uchar              AlphaFG(void)                       const { return this.m_alpha_fg;                                                           }
      void               SetAlphaFG(const uchar value)             { this.m_alpha_fg=value;                                                            }

   //--- Sets transparency for both background and foreground
      void               SetAlpha(const uchar value)               { this.m_alpha_fg=this.m_alpha_bg=value;                                            }
      
   //--- (1) Returns, (2) sets the left border width
      uint             BorderWidthLeft(void)               const { return this.m_border_width_lt;                                                    } 
      void             SetBorderWidthLeft(const uint width)      { this.m_border_width_lt=width;                                                     }
      
   //--- (1) Returns, (2) sets the right border width
      uint             BorderWidthRight(void)              const { return this.m_border_width_rt;                                                    } 
      void             SetBorderWidthRight(const uint width)     { this.m_border_width_rt=width;                                                     }
                        
   //--- (1) Returns, (2) sets the top border width
      uint             BorderWidthTop(void)                const { return this.m_border_width_up;                                                    } 
      void             SetBorderWidthTop(const uint width)       { this.m_border_width_up=width;                                                     }
                        
   //--- (1) Returns, (2) sets the bottom border width
      uint             BorderWidthBottom(void)             const { return this.m_border_width_dn;                                                    } 
      void             SetBorderWidthBottom(const uint width)    { this.m_border_width_dn=width;                                                     }
                        
   //--- Sets the same border width for all sides
      void             SetBorderWidth(const uint width)
                        {
                           this.m_border_width_lt=this.m_border_width_rt=this.m_border_width_up=this.m_border_width_dn=width;
                        }
                        
   //--- Sets the border width individually
      void             SetBorderWidth(const uint left,const uint right,const uint top,const uint bottom)
                        {
                           this.m_border_width_lt=left;
                           this.m_border_width_rt=right;
                           this.m_border_width_up=top;
                           this.m_border_width_dn=bottom;
                        }
      
   //--- Returns object boundaries including the border
      int               LimitLeft(void)                     const { return this.ObjectX()+(int)this.m_border_width_lt;                                }
      int               LimitRight(void)                    const { return this.ObjectRight()-(int)this.m_border_width_rt;                            }
      int               LimitTop(void)                      const { return this.ObjectY()+(int)this.m_border_width_up;                                }
      int               LimitBottom(void)                   const { return this.ObjectBottom()-(int)this.m_border_width_dn;                           }
      
   //--- Sets flags for (1) movability, (2) main object, (3) resizability,
   //--- (4) event auto-repeat, (5) scrolling inside container, (6) trimming by container boundaries
      void               SetMovable(const bool flag)               { this.m_movable=flag;                                                              }
      void               SetAsMain(void)                           { this.m_main=true;                                                                 }
      virtual void       SetResizable(const bool flag)             { this.m_resizable=flag;                                                            }
      void               SetAutorepeat(const bool flag)            { this.m_autorepeat_flag=flag;                                                      }
      void               SetScrollable(const bool flag)            { this.m_scroll_flag=flag;                                                          }
      virtual void       SetTrimmered(const bool flag)             { this.m_trim_flag=flag;                                                            }
      void               SetCropped(const bool flag)               { this.m_cropped=flag;                                                              }
      
   //--- Returns a flag indicating if the object is located outside its container
      virtual bool       IsOutOfContainer(void);
   //--- Trims the graphical object according to container sizes
      virtual bool       ObjectTrim(void);
      
   //--- Resizes the object
      virtual bool       ResizeW(const int w);
      virtual bool       ResizeH(const int h);
      virtual bool       Resize(const int w,const int h);

   //--- Sets a new (1) X, (2) Y, (3) XY coordinate for the object
      virtual bool       MoveX(const int x);
      virtual bool       MoveY(const int y);
      virtual bool       Move(const int x,const int y);
      
   //--- Sets coordinates and sizes of the element simultaneously
      virtual bool       MoveXYWidthResize(const int x,const int y,const int w,const int h);
      
   //--- Shifts the object along (1) X, (2) Y, (3) XY axis by the specified offset
      virtual bool       ShiftX(const int dx);
      virtual bool       ShiftY(const int dy);
      virtual bool       Shift(const int dx,const int dy);
      
   //--- (1) Hides (2) displays the object on all chart periods,
   //--- (3) brings the object to the foreground, (4) blocks, (5) unblocks the element,
   //--- (6) fills the object with the specified color and set transparency
      virtual void       Hide(const bool chart_redraw);
      virtual void       Show(const bool chart_redraw);
      virtual void       BringToTop(const bool chart_redraw);
      virtual void       Block(const bool chart_redraw);
      virtual void       Unblock(const bool chart_redraw);
      void               Fill(const color clr,const bool chart_redraw);
      
   //--- (1) Fills the object with a transparent color, (2) updates the object to display changes,
   //--- (3) draws the appearance, (4) destroys the object
      virtual void       Clear(const bool chart_redraw);
      virtual void       Update(const bool chart_redraw);
      virtual void       Draw(const bool chart_redraw);
      virtual void       Destroy(void);
      
   //--- Returns the object description
      virtual string     Description(void);
      
   //--- Virtual methods for (1) comparison, (2) saving to file, (3) loading from file, (4) object type
      virtual int        Compare(const CObject *node,const int mode=0) const;
      virtual bool       Save(const int file_handle);
      virtual bool       Load(const int file_handle);
      virtual int        Type(void)                          const { return(ELEMENT_TYPE_CANVAS_BASE); }
      
   //--- Event handler
      virtual void       OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam);
      
   //--- (1) Timer, (2) timer event handler
      virtual void       OnTimer()                                 { this.TimerEventHandler();         }
      virtual void       TimerEventHandler(void)                   { return;                           }
      
   //--- Constructors/destructor
                        CCanvasBase(void); 
                        CCanvasBase(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h);
                        ~CCanvasBase(void);

};
//+------------------------------------------------------------------+
//| CCanvasBase::Constructor                                         |
//+------------------------------------------------------------------+
CCanvasBase::CCanvasBase(const string object_name,
                         const long chart_id,
                         const int wnd,
                         const int x,
                         const int y,
                         const int w,
                         const int h)
                     :
                     m_program_name(::MQLInfoString(MQL_PROGRAM_NAME)),
                     m_wnd(wnd<0 ? 0 : wnd),
                     m_alpha_bg(0),
                     m_alpha_fg(255),
                     m_hidden(false),
                     m_blocked(false),
                     m_focused(false),
                     m_movable(false),
                     m_resizable(false),
                     m_main(false),
                     m_autorepeat_flag(false),
                     m_trim_flag(true),
                     m_cropped(false),
                     m_scroll_flag(false),
                     m_border_width_lt(0),
                     m_border_width_rt(0),
                     m_border_width_up(0),
                     m_border_width_dn(0),
                     m_z_order(0),
                     m_state(0),
                     m_cursor_delta_x(0),
                     m_cursor_delta_y(0)
                     {
                        this.m_chart_id = this.CorrectChartID(chart_id);

                        if(!this.CreateCanvasObjects())
                           return;
                     }

// // CCanvasBase::CCanvasBase(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
// //    m_program_name(::MQLInfoString(MQL_PROGRAM_NAME)), m_wnd(wnd<0 ? 0 : wnd), m_alpha_bg(0), m_alpha_fg(255),
// //    m_hidden(false), m_blocked(false), m_focused(false), m_movable(false), m_resizable(false), m_main(false), 
// //    m_autorepeat_flag(false), m_trim_flag(true), m_cropped(false), m_scroll_flag(false),
// //    m_border_width_lt(0), m_border_width_rt(0), m_border_width_up(0), m_border_width_dn(0), m_z_order(0),
// //    m_state(0), m_cursor_delta_x(0), m_cursor_delta_y(0)

// CCanvasBase::CCanvasBase(const string object_name,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) 
// {
//    //--- Get the corrected chart ID and vertical Y-axis distance in pixels
//    //--- between the indicator subwindow top border and the main chart window top border
//       this.m_chart_id=this.CorrectChartID(chart_id);
      
//    //--- If canvas objects failed to be created, exit
//       if(!this.CreateCanvasObjects())
//          return;
         
//    //--- If the graphic resource and graphic object are created
//       if(this.Create(this.m_chart_id,this.m_wnd,object_name,x,y,w,h))
//       {
//          //--- Clear background and foreground canvases and set initial coordinate values,
//          //--- graphic object names, and text properties drawn on the foreground
//          this.Clear(false);
//          this.m_obj_x=x;
//          this.m_obj_y=y;
//          this.m_color_background.SetName("Background");
//          this.m_color_foreground.SetName("Foreground");
//          this.m_color_border.SetName("Border");
//          this.m_foreground.FontSet(DEF_FONTNAME,-DEF_FONTSIZE*10,FW_MEDIUM);
//          this.m_bound.SetName("Perimeter");
         
//          //--- Store permissions for mouse and chart tools
//          this.Init();
//       }
// }
//+------------------------------------------------------------------+
//| CCanvasBase::Destructor                                          |
//+------------------------------------------------------------------+
CCanvasBase::~CCanvasBase(void)
{
   //--- Destroy the object
      this.Destroy();
   //--- Restore permissions for mouse and chart tools
      ::ChartSetInteger(this.m_chart_id, CHART_EVENT_MOUSE_WHEEL, this.m_chart_mouse_wheel_flag);
      ::ChartSetInteger(this.m_chart_id, CHART_EVENT_MOUSE_MOVE, this.m_chart_mouse_move_flag);
      ::ChartSetInteger(this.m_chart_id, CHART_EVENT_OBJECT_CREATE, this.m_chart_object_create_flag);
      ::ChartSetInteger(this.m_chart_id, CHART_MOUSE_SCROLL, this.m_chart_mouse_scroll_flag);
      ::ChartSetInteger(this.m_chart_id, CHART_CONTEXT_MENU, this.m_chart_context_menu_flag);
      ::ChartSetInteger(this.m_chart_id, CHART_CROSSHAIR_TOOL, this.m_chart_crosshair_tool_flag);
   }
   //+------------------------------------------------------------------+
   //| CCanvasBase::Compare two objects                                 |
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
//| CCanvasBase::Creates background and foreground canvases          |
//+------------------------------------------------------------------+
bool CCanvasBase::CreateCanvasObjects(void)
{
   //--- If both canvases are already created, or the class does not manage canvases, return true
      if((this.m_background!=NULL && this.m_foreground!=NULL) || !this.m_canvas_owner)
         return true;
   //--- Create background canvas
      this.m_background=new CCanvas();
      if(this.m_background==NULL)
      {
         ::PrintFormat("%s: Error! Failed to create background canvas",__FUNCTION__);
         return false;
      }
   //--- Create foreground canvas
      this.m_foreground=new CCanvas();
      if(this.m_foreground==NULL)
      {
         ::PrintFormat("%s: Error! Failed to create foreground canvas",__FUNCTION__);
         return false;
      }
   //--- Everything successful
      return true;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Creates background and foreground graphic objects   |
//+------------------------------------------------------------------+
bool CCanvasBase::Create(const long chart_id,const int wnd,const string object_name,const int x,const int y,const int w,const int h)
{
   //--- Get corrected chart ID
      long id=this.CorrectChartID(chart_id);
   //--- Correct the passed object name
      string nm=object_name;
      ::StringReplace(nm," ","");
   //--- Create graphic object name for background and create canvas
      string obj_name=nm+"BG";
      if(!this.m_background.CreateBitmapLabel(id,(wnd<0 ? 0 : wnd),obj_name,x,y,(w>0 ? w : 1),(h>0 ? h : 1),COLOR_FORMAT_ARGB_NORMALIZE))
      {
         ::PrintFormat("%s: The CreateBitmapLabel() method of the CCanvas class returned an error creating a \"%s\" graphic object",__FUNCTION__,obj_name);
         return false;
      }
   //--- Create graphic object name for foreground and create canvas
      obj_name=nm+"FG";
      if(!this.m_foreground.CreateBitmapLabel(id,(wnd<0 ? 0 : wnd),obj_name,x,y,(w>0 ? w : 1),(h>0 ? h : 1),COLOR_FORMAT_ARGB_NORMALIZE))
      {
         ::PrintFormat("%s: The CreateBitmapLabel() method of the CCanvas class returned an error creating a \"%s\" graphic object",__FUNCTION__,obj_name);
         return false;
      }
   //--- On success, write the program name into the OBJPROP_TEXT property of the graphic object
      ::ObjectSetString(id,this.NameBG(),OBJPROP_TEXT,this.m_program_name);
      ::ObjectSetString(id,this.NameFG(),OBJPROP_TEXT,this.m_program_name);
      ::ObjectSetString(id,this.NameBG(),OBJPROP_TOOLTIP,"\n");
      ::ObjectSetString(id,this.NameFG(),OBJPROP_TOOLTIP,"\n");
      ::ObjectSetInteger(id,this.NameBG(),OBJPROP_ZORDER,0);
      ::ObjectSetInteger(id,this.NameFG(),OBJPROP_ZORDER,0);
         
   //--- Set rectangular area boundaries and return true
      this.m_bound.SetXY(x,y);
      this.m_bound.Resize(w,h);
      return true;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Sets pointer to the parent container object         |
//+------------------------------------------------------------------+
void CCanvasBase::SetContainerObj(CCanvasBase *obj)
{
   //--- Set the passed pointer to the object
      this.m_container=obj;
   //--- If the pointer is null, exit
      if(this.m_container==NULL)
         return;
   //--- If an invalid pointer is passed, nullify it in the object and exit
      if(::CheckPointer(this.m_container)==POINTER_INVALID)
      {
         this.m_container=NULL;
         return;
      }
   //--- Trim the object by the boundaries of its assigned container
      this.ObjectTrim();
}
//+------------------------------------------------------------------+
//| CCanvasBase::Returns flag indicating if the object is located    |
//| outside its container                                            |
//+------------------------------------------------------------------+
bool CCanvasBase::IsOutOfContainer(void)
{
   //--- Return the result of checking if the object is completely outside the container
      return(this.Right() <= this.ContainerLimitLeft() || this.X() >= this.ContainerLimitRight() ||
            this.Bottom()<= this.ContainerLimitTop()  || this.Y() >= this.ContainerLimitBottom());
   }
   //+------------------------------------------------------------------+
   //| CCanvasBase::Trims the graphic object by the container contour   |
   //+------------------------------------------------------------------+
   bool CCanvasBase::ObjectTrim()
   {
   //--- Check the trim permission flag; 
   //--- if the element should not be trimmed by container borders, return false
      if(!this.m_trim_flag)
         return false;
   //--- Get container boundaries
      int container_left   = this.ContainerLimitLeft();
      int container_right  = this.ContainerLimitRight();
      int container_top    = this.ContainerLimitTop();
      int container_bottom = this.ContainerLimitBottom();
      
   //--- Get current object boundaries
      int object_left   = this.X();
      int object_right  = this.Right();
      int object_top    = this.Y();
      int object_bottom = this.Bottom();

   //--- Check if the object is completely outside the container; if so, hide it
      if(this.IsOutOfContainer())
      {
         //--- Set the flag that the object is outside the container
         this.m_cropped=true;
         //--- Hide the object and restore its sizes
         this.Hide(false);
         if(this.ObjectResize(this.Width(),this.Height()))
            this.BoundResize(this.Width(),this.Height());
         return true;
      }
   //--- Object is fully or partially within the visible area of the container
      else
      {
         //--- Reset the flag that the object is outside the container
         this.m_cropped=false;
         //--- If the element is completely inside the container
         if(object_right<=container_right && object_left>=container_left &&
            object_bottom<=container_bottom && object_top>=container_top)
         {
            //--- If width or height of graphic object doesn't match the element dimensions,
            //--- modify the graphic object to match element sizes and return true
            if(this.ObjectWidth()!=this.Width() || this.ObjectHeight()!=this.Height())
            {
               if(this.ObjectResize(this.Width(),this.Height()))
                  return true;
            }
         }
         //--- If the element is partially within the visible area of the container
         else
         {
            //--- If the element is vertically fully within the visible area of the container
            if(object_bottom<=container_bottom && object_top>=container_top)
            {
               //--- If graphic object height doesn't match element height,
               //--- modify graphic object by element height
               if(this.ObjectHeight()!=this.Height())
                  this.ObjectResizeH(this.Height());
            }
            else
            {
               //--- If the element is horizontally fully within the visible area of the container
               if(object_right<=container_right && object_left>=container_left)
               {
                  //--- If graphic object width doesn't match element width,
                  //--- modify graphic object by element width
                  if(this.ObjectWidth()!=this.Width())
                     this.ObjectResizeW(this.Width());
               }
            }
         }
      }
      
   //--- Check if the object exceeds horizontal and vertical container boundaries
      bool modified_horizontal=false;     // Horizontal change flag
      bool modified_vertical  =false;     // Vertical change flag
      
   //--- Horizontal trimming
      int new_left = object_left;
      int new_width = this.Width();
   //--- If the object exceeds the left container boundary
      if(object_left<=container_left)
      {
         int crop_left=container_left-object_left;
         new_left=container_left;
         new_width-=crop_left;
         modified_horizontal=true;
      }
   //--- If the object exceeds the right container boundary
      if(object_right>=container_right)
      {
         int crop_right=object_right-container_right;
         new_width-=crop_right;
         modified_horizontal=true;
      }
   //--- If there were horizontal changes
      if(modified_horizontal)
      {
         this.ObjectSetX(new_left);
         this.ObjectResizeW(new_width);
      }

   //--- Vertical trimming
      int new_top=object_top;
      int new_height=this.Height();
   //--- If the object exceeds the top container boundary
      if(object_top<=container_top)
      {
         int crop_top=container_top-object_top;
         new_top=container_top;
         new_height-=crop_top;
         modified_vertical=true;
      }
   //--- If the object exceeds the bottom container boundary 
      if(object_bottom>=container_bottom)
      {
         int crop_bottom=object_bottom-container_bottom;
         new_height-=crop_bottom;
         modified_vertical=true;
      }
   //--- If there were vertical changes
      if(modified_vertical)
      {
         this.ObjectSetY(new_top);
         this.ObjectResizeH(new_height);
      }

   //--- After calculations, the object might have been hidden, but is now in the container area - show it
      this.Show(false);
         
   //--- If the object was modified, redraw it
      if(modified_horizontal || modified_vertical)
      {
         this.Update(false);
         this.Draw(false);
         return true;
      }

      return false;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Returns flag if the cursor is inside the object     |
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
   //|CCanvasBase::Returns cursor position on the object boundaries      |
   //+--------------------------------------------------------------------+
   ENUM_CURSOR_REGION CCanvasBase::CheckResizeZone(const int x,const int y)
   {
   //--- Element boundary coordinates
      int top=this.Y();
      int bottom=this.Bottom();
      int left=this.X();
      int right=this.Right();
      
   //--- If outside the object, return CURSOR_REGION_NONE
      if(x<left || x>right || y<top || y>bottom)
         return CURSOR_REGION_NONE;

   //--- Left edge and corners
      if(x>=left && x<=left+DEF_EDGE_THICKNESS)
      {
         //--- Top-left corner
         if(y>=top && y<=top+DEF_EDGE_THICKNESS)
            return CURSOR_REGION_LEFT_TOP;
         //--- Bottom-left corner
         if(y>=bottom-DEF_EDGE_THICKNESS && y<=bottom)
            return CURSOR_REGION_LEFT_BOTTOM;
         //--- Left edge
         return CURSOR_REGION_LEFT;
      }
      
   //--- Right edge and corners
      if(x>=right-DEF_EDGE_THICKNESS && x<=right)
      {
         //--- Top-right corner
         if(y>=top && y<=top+DEF_EDGE_THICKNESS)
            return CURSOR_REGION_RIGHT_TOP;
         //--- Bottom-right corner
         if(y>=bottom-DEF_EDGE_THICKNESS && y<=bottom)
            return CURSOR_REGION_RIGHT_BOTTOM;
         //--- Right edge
         return CURSOR_REGION_RIGHT;
      }
      
   //--- Top edge
      if(y>=top && y<=top+DEF_EDGE_THICKNESS)
         return CURSOR_REGION_TOP;

   //--- Bottom edge
      if(y>=bottom-DEF_EDGE_THICKNESS && y<=bottom)
         return CURSOR_REGION_BOTTOM;

   //--- Cursor is not on the element edges
      return CURSOR_REGION_NONE;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Sets z-order of the graphic object                  |
//+------------------------------------------------------------------+
bool CCanvasBase::ObjectSetZOrder(const int value)
{
   //--- If the value is already set, return true
      if(this.ObjectZOrder()==value)
         return true;
   //--- If failed to set new value in background and foreground graphic objects, return false
      if(!::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_ZORDER,value) || !::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_ZORDER,value))
         return false;
   //--- Write new z-order value into the variable and return true
      this.m_z_order=value;
      return true;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Sets X coordinate of the graphic object             |
//+------------------------------------------------------------------+
bool CCanvasBase::ObjectSetX(const int x)
{
   //--- If coordinate is already set, return true 
      if(this.ObjectX()==x)
         return true;
   //--- If failed to set new coordinate in background and foreground graphic objects, return false
      if(!::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_XDISTANCE,x) || !::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_XDISTANCE,x))
         return false;
   //--- Write new coordinate into the variable and return true
      this.m_obj_x=x;
      return true;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Sets Y coordinate of the graphic object             |
//+------------------------------------------------------------------+
bool CCanvasBase::ObjectSetY(const int y)
{
   //--- If coordinate is already set, return true
      if(this.ObjectY()==y)
         return true;
   //--- If failed to set new coordinate in background and foreground graphic objects, return false
      if(!::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_YDISTANCE,y) || !::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_YDISTANCE,y))
         return false;
   //--- Write new coordinate into the variable and return true
      this.m_obj_y=y;
      return true;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Resizes graphic object width                        |
//+------------------------------------------------------------------+
bool CCanvasBase::ObjectResizeW(const int size)
{
   //--- If width is already set, return true
      if(this.ObjectWidth()==size)
         return true;
   //--- If size > 0, return result of resizing background and foreground, otherwise return false
      return(size>0 ? (this.m_background.Resize(size,this.ObjectHeight()) && this.m_foreground.Resize(size,this.ObjectHeight())) : false);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Resizes graphic object height                       |
//+------------------------------------------------------------------+
bool CCanvasBase::ObjectResizeH(const int size)
{
   //--- If height is already set, return true
      if(this.ObjectHeight()==size)
         return true;
   //--- If size > 0, return result of resizing background and foreground, otherwise return false
      return(size>0 ? (this.m_background.Resize(this.ObjectWidth(),size) && this.m_foreground.Resize(this.ObjectWidth(),size)) : false);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Resizes graphic object                              |
//+------------------------------------------------------------------+
bool CCanvasBase::ObjectResize(const int w,const int h)
{
   if(!this.ObjectResizeW(w))
      return false;
   return this.ObjectResizeH(h);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Sets coordinates and sizes                          |
//| of the graphic object simultaneously                             |
//+------------------------------------------------------------------+
bool CCanvasBase::ObjectSetXYWidthResize(const int x,const int y,const int w,const int h)
{
   //--- If new coordinates are set, return the result of resizing
      if(this.ObjectSetXY(x,y))
         return this.ObjectResize(w,h);
   //--- Failed to set new coordinates, return false
      return false;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Resizes the object                                  |
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
//| CCanvasBase::Resizes the object height                           |
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
//| CCanvasBase::Resizes the object                                  |
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
//| CCanvasBase::Sets new X and Y coordinates for the object         |
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
//| CCanvasBase::Sets new X coordinate for the object                |
//+------------------------------------------------------------------+
bool CCanvasBase::MoveX(const int x)
{
   return this.Move(x,this.AdjY(this.ObjectY()));
}
//+------------------------------------------------------------------+
//| CCanvasBase::Sets new Y coordinate for the object                |
//+------------------------------------------------------------------+
bool CCanvasBase::MoveY(const int y)
{
   return this.Move(this.AdjX(this.ObjectX()),y);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Shifts the object by specified X and Y offsets      |
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
//| CCanvasBase::Shifts the object along the X axis                  |
//+------------------------------------------------------------------+
bool CCanvasBase::ShiftX(const int dx)
{
   return this.Shift(dx,0);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Shifts the object along the Y axis                  |
//+------------------------------------------------------------------+
bool CCanvasBase::ShiftY(const int dy)
{
   return this.Shift(0,dy);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Sets both coordinates and dimensions of the element |
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
//| CCanvasBase::Hides the object on all chart timeframes            |
//+------------------------------------------------------------------+
void CCanvasBase::Hide(const bool chart_redraw)
{
   //--- If the object is already hidden, exit
      if(this.m_hidden)
         return;
   //--- If visibility change for background and foreground is successfully 
   //--- queued in the chart command queue, set the hidden object flag
      if(::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS) &&
         ::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS)
         ) this.m_hidden=true;
   //--- Redraw chart if specified
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Shows the object on all chart timeframes            |
//+------------------------------------------------------------------+
void CCanvasBase::Show(const bool chart_redraw)
{
   //--- If the object is already visible, exit
      if(!this.m_hidden)
         return;
   //--- If visibility change for background and foreground is successfully 
   //--- queued in the chart command queue, reset the hidden object flag
      if(::ObjectSetInteger(this.m_chart_id,this.NameBG(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS) &&
         ::ObjectSetInteger(this.m_chart_id,this.NameFG(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS)
         ) this.m_hidden=false;
   //--- Redraw chart if specified
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Brings the object to the foreground                 |
//+------------------------------------------------------------------+
void CCanvasBase::BringToTop(const bool chart_redraw)
{
   if(this.m_cropped)
      return;
   this.Hide(false);
   this.Show(chart_redraw);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Blocks the element                                  |
//+------------------------------------------------------------------+
void CCanvasBase::Block(const bool chart_redraw)
{
   //--- If the element is already blocked, exit
      if(this.m_blocked)
         return;
   //--- Set current colors to blocked state colors, 
   //--- set the blocked flag and redraw the object
      this.ColorsToBlocked();
      this.m_blocked=true;
      this.Draw(chart_redraw);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Unblocks the element                                |
//+------------------------------------------------------------------+
void CCanvasBase::Unblock(const bool chart_redraw)
{
   //--- If the element is already unblocked, exit
      if(!this.m_blocked)
         return;
   //--- Set current colors to default state colors, 
   //--- redraw the object and reset the blocked flag
      this.ColorsToDefault();
      this.Draw(chart_redraw);
      this.m_blocked=false;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Sets current element colors to default state        |
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
//| CCanvasBase::Sets current element colors to focused state        |
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
//| CCanvasBase::Sets current element colors to pressed state        |
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
//| CCanvasBase::Sets current element colors to blocked state        |
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
//| CCanvasBase::Fills the object with specified color               |
//| using the transparency set in m_alpha_bg                         |
//+------------------------------------------------------------------+
void CCanvasBase::Fill(const color clr,const bool chart_redraw)
{
   this.m_background.Erase(::ColorToARGB(clr,this.m_alpha_bg));
   this.m_background.Update(chart_redraw);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Fills the object with a transparent color           |
//+------------------------------------------------------------------+
void CCanvasBase::Clear(const bool chart_redraw)
{
   this.m_background.Erase(clrNULL);
   this.m_foreground.Erase(clrNULL);
   this.Update(chart_redraw);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Updates the object to display changes               |
//+------------------------------------------------------------------+
void CCanvasBase::Update(const bool chart_redraw)
{
   this.m_background.Update(false);
   this.m_foreground.Update(chart_redraw);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Draws the visual appearance                         |
//+------------------------------------------------------------------+
void CCanvasBase::Draw(const bool chart_redraw)
{
   return;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Destroys the object                                 |
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
//| CCanvasBase::Returns object description                          |
//+------------------------------------------------------------------+
string CCanvasBase::Description(void)
{
   string nm=this.Name();
   string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   string area=::StringFormat("x %d, y %d, w %d, h %d",this.X(),this.Y(),this.Width(),this.Height());
   return ::StringFormat("%s%s (%s, %s): ID %d, %s",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.NameBG(),this.NameFG(),this.ID(),area);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Saving to file                                      |
//+------------------------------------------------------------------+
bool CCanvasBase::Save(const int file_handle)
{
   //--- Method is temporarily disabled
      return false;
      
   //--- Save parent object data
      if(!CBaseObj::Save(file_handle))
         return false;
   /*
   //--- Save properties
         
   */
   //--- Successful
      return true;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Loading from file                                   |
//+------------------------------------------------------------------+
bool CCanvasBase::Load(const int file_handle)
{
   //--- Method is temporarily disabled
      return false;
      
   //--- Load parent object data
      if(!CBaseObj::Load(file_handle))
         return false;
   /*
   //--- Load properties
      
   */
   //--- Successful
      return true;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Sets chart restrictions                             |
//| (mouse wheel scroll, context menu, and crosshair tool)           |
//+------------------------------------------------------------------+
void CCanvasBase::SetFlags(const bool flag)
{
   //--- If flags need to be set and they were already set, exit
      if(flag && this.m_flags_state)
         return;
   //--- If flags need to be reset and they were already reset, exit
      if(!flag && !this.m_flags_state)
         return;
   //--- Set the required flag for context menu, 
   //--- crosshair tool, and chart mouse wheel scrolling.
   //--- After setting, store the current flag state.
      ::ChartSetInteger(this.m_chart_id, CHART_CONTEXT_MENU,  flag);
      ::ChartSetInteger(this.m_chart_id, CHART_CROSSHAIR_TOOL,flag);
      ::ChartSetInteger(this.m_chart_id, CHART_MOUSE_SCROLL,  flag);
      this.m_flags_state=flag;
   //--- Update the chart to apply set flags immediately
      ::ChartRedraw(this.m_chart_id);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Class initialization                                |
//+------------------------------------------------------------------+
void CCanvasBase::Init(void)
{
   //--- Store current permissions for mouse and chart tools
      this.m_chart_mouse_wheel_flag   = ::ChartGetInteger(this.m_chart_id, CHART_EVENT_MOUSE_WHEEL);
      this.m_chart_mouse_move_flag    = ::ChartGetInteger(this.m_chart_id, CHART_EVENT_MOUSE_MOVE);
      this.m_chart_object_create_flag = ::ChartGetInteger(this.m_chart_id, CHART_EVENT_OBJECT_CREATE);
      this.m_chart_mouse_scroll_flag  = ::ChartGetInteger(this.m_chart_id, CHART_MOUSE_SCROLL);
      this.m_chart_context_menu_flag  = ::ChartGetInteger(this.m_chart_id, CHART_CONTEXT_MENU);
      this.m_chart_crosshair_tool_flag= ::ChartGetInteger(this.m_chart_id, CHART_CROSSHAIR_TOOL);
   //--- Enable mouse and chart events
      ::ChartSetInteger(this.m_chart_id, CHART_EVENT_MOUSE_WHEEL, true);
      ::ChartSetInteger(this.m_chart_id, CHART_EVENT_MOUSE_MOVE, true);
      ::ChartSetInteger(this.m_chart_id, CHART_EVENT_OBJECT_CREATE, true);

   //--- Initialize default object colors
      this.InitColors();
   //--- Initialize millisecond timer
      ::EventSetMillisecondTimer(16);
      
   //--- Canvas ownership flag
      this.m_canvas_owner=true;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Initialize default object colors                    |
//+------------------------------------------------------------------+
void CCanvasBase::InitColors(void)
{
   //--- Initialize background colors for default and active states and set as current background color
      this.InitBackColors(clrWhiteSmoke);
      this.InitBackColorsAct(clrWhiteSmoke);
      this.BackColorToDefault();
      
   //--- Initialize foreground colors for default and active states and set as current text color
      this.InitForeColors(clrBlack);
      this.InitForeColorsAct(clrBlack);
      this.ForeColorToDefault();
      
   //--- Initialize border colors for default and active states and set as current border color
      this.InitBorderColors(clrDarkGray);
      this.InitBorderColorsAct(clrDarkGray);
      this.BorderColorToDefault();
      
   //--- Initialize border and foreground colors for the blocked element state
      this.InitBorderColorBlocked(clrLightGray);
      this.InitForeColorBlocked(clrSilver);
}
//+------------------------------------------------------------------+
//| CCanvasBase::Checks if set color equals the specified one        |
//+------------------------------------------------------------------+
bool CCanvasBase::CheckColor(const ENUM_COLOR_STATE state) const
{
      bool res=true;
   //--- Depending on the state being checked
      switch(state)
      {
   //--- Check if all DEFAULT background, text, and border colors match preset values
         case COLOR_STATE_DEFAULT :
         res &=this.BackColor()==this.BackColorDefault();
         res &=this.ForeColor()==this.ForeColorDefault();
         res &=this.BorderColor()==this.BorderColorDefault();
         break;

   //--- Check if all FOCUSED background, text, and border colors match preset values
         case COLOR_STATE_FOCUSED :
         res &=this.BackColor()==this.BackColorFocused();
         res &=this.ForeColor()==this.ForeColorFocused();
         res &=this.BorderColor()==this.BorderColorFocused();
         break;
         
   //--- Check if all PRESSED background, text, and border colors match preset values
         case COLOR_STATE_PRESSED :
         res &=this.BackColor()==this.BackColorPressed();
         res &=this.ForeColor()==this.ForeColorPressed();
         res &=this.BorderColor()==this.BorderColorPressed();
         break;
         
   //--- Check if all BLOCKED background, text, and border colors match preset values
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
//| CCanvasBase::Change object element colors by event              |
//+------------------------------------------------------------------+
void CCanvasBase::ColorChange(const ENUM_COLOR_STATE state)
{
   //--- Set event colors as primary depending on the state
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
//| CCanvasBase::Event handler                                       |
//+------------------------------------------------------------------+
void CCanvasBase::OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
{
   //--- Chart change event
      if(id==CHARTEVENT_CHART_CHANGE)
      {
         //--- Correct the distance between the indicator subwindow top border and main chart window top border
         this.m_wnd_y=(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOW_YDISTANCE,this.m_wnd);
      }
         
   //--- Graphic object creation event
      if(id==CHARTEVENT_OBJECT_CREATE)
      {
         //--- If it's not a container element, exit
         if(this.Type()<ELEMENT_TYPE_PANEL)
            return;
         //--- Call the graphic object creation handler
         this.OnCreateEvent(id,lparam,dparam,sparam);
      }

   //--- If the element is blocked or hidden, exit
      if(this.IsBlocked() || this.IsHidden())
         return;
         
      //--- Mouse cursor coordinates
      int x=(int)lparam;
      int y=(int)dparam-this.m_wnd_y;  // Adjust Y by subwindow height
      
   //--- Mouse move event
      if(id==CHARTEVENT_MOUSE_MOVE)
      {
         //--- Send cursor coordinates to the resource manager instance
         CCommonManager::GetInstance().SetCursorX(x);
         CCommonManager::GetInstance().SetCursorY(y);

         //--- Do not process inactive elements, except for the main one
         if(!this.IsMain() && (this.Type()<ACTIVE_ELEMENT_MIN || this.Type()>ACTIVE_ELEMENT_MAX))
            return;

         //--- Mouse button is held down
         if(sparam=="1")
         {
            //--- Cursor is within object boundaries
            if(this.Contains(x, y))
            {
               //--- If it's the main object, disable chart tools
               if(this.IsMain())
                  this.SetFlags(false);
               
               //--- If the mouse button was pressed on the chart background, nothing to process, exit
               if(this.ActiveElementName()=="Chart")
                  return;
                  
               //--- Fix the name of the active element that was under the cursor when the button was pressed
               this.SetActiveElementName(this.ActiveElementName());
               //--- If it's the current active element, process its movement
               if(this.IsCurrentActiveElement())
               {
                  this.OnMoveEvent(id,lparam,dparam,sparam);
                  
                  //--- If auto-repeat is enabled for the element, signal that the button is pressed
                  if(this.m_autorepeat_flag)
                     this.m_autorepeat.OnButtonPress();
               
                  //--- For resizable elements
                  if(this.m_resizable)
                  {
                     //--- If resize mode is not active, call the resize beginning handler
                     if(!this.ResizeMode())
                        this.OnResizeZoneEvent(RESIZE_ZONE_ACTION_BEGIN,x,y,this.NameFG());
                     //--- Otherwise, if resize mode is active, call the edge dragging handler
                     else
                        this.OnResizeZoneEvent(RESIZE_ZONE_ACTION_DRAG,x,y,this.NameFG());
                  }
               }
            }
            //--- Cursor is outside object boundaries
            else
            {
               //--- If it's the active main object, or mouse was pressed on chart and not in resize mode - enable chart tools
               if(this.IsMain() && (this.ActiveElementName()==this.NameFG() || this.ActiveElementName()=="Chart"))
                  if(!this.ResizeMode())
                     this.SetFlags(true);
                  
               //--- If it's the current active element
               if(this.IsCurrentActiveElement())
               {
                  //--- If the element is not movable
                  if(!this.IsMovable())
                  {
                     //--- call the mouse hover handler
                     this.OnFocusEvent(id,lparam,dparam,sparam);
                     //--- If auto-repeat is active, signal button release
                     if(this.m_autorepeat_flag)
                        this.m_autorepeat.OnButtonRelease();
                  }
                  //--- If the element is movable, call the movement handler
                  else
                     this.OnMoveEvent(id,lparam,dparam,sparam);
               
                  //--- For resizable elements, call the edge dragging handler
                  if(this.m_resizable)
                     this.OnResizeZoneEvent(RESIZE_ZONE_ACTION_DRAG,x,y,this.NameFG());
               }
            }
         }
         
         //--- Mouse button is not pressed
         else
         {
            //--- Cursor is within object boundaries
            if(this.Contains(x, y))
            {
               //--- If it's the main element, disable chart tools
               if(this.IsMain())
                  this.SetFlags(false);
               
               //--- Call the hover handler and set element as current active
               this.OnFocusEvent(id,lparam,dparam,sparam);
               this.SetActiveElementName(this.NameFG());
            
               //--- For resizable elements, call the resize zone hover handler
               if(this.m_resizable)
                  this.OnResizeZoneEvent(RESIZE_ZONE_ACTION_HOVER,x,y,this.NameFG());
            }
            
            //--- Cursor is outside object boundaries
            else
            {
               //--- If it's the main object
               if(this.IsMain())
               {
                  //--- Enable chart tools and set chart as active element
                  this.SetFlags(true);
                  this.SetActiveElementName("Chart");
               }
               //--- Call the release/focus-lost handler 
               this.OnReleaseEvent(id,lparam,dparam,sparam);
               
               //--- For resizable elements, call the "no resize" state handler
               if(this.m_resizable)
                  this.OnResizeZoneEvent(RESIZE_ZONE_ACTION_NONE,x,y,this.NameFG());
            }
         }
      }
         
   //--- Graphic object click event (mouse button release)
      if(id==CHARTEVENT_OBJECT_CLICK)
      {
         //--- If the click (release) was on this object
         if(sparam==this.NameFG())
         {
            //--- Call the click handler and release current active object
            this.OnPressEvent(id, lparam, dparam, sparam);
            this.SetActiveElementName("");
                  
            //--- If auto-repeat is active, signal button release
            if(this.m_autorepeat_flag)
               this.m_autorepeat.OnButtonRelease();
               
            //--- For resizable elements
            if(this.m_resizable)
            {
               //--- Disable resize mode, reset interaction region,
               //--- and call the resize completion handler
               this.SetResizeMode(false);
               this.SetResizeRegion(CURSOR_REGION_NONE);
               this.OnResizeZoneEvent(RESIZE_ZONE_ACTION_END,x,y,this.NameFG());
            }
         }
      }
      
   //--- Mouse wheel scroll event
      if(id==CHARTEVENT_MOUSE_WHEEL)
      {
         //--- If it's the active element, call its scroll handler
         if(this.IsCurrentActiveElement())
            this.OnWheelEvent(id,lparam,dparam,this.ActiveElementName()); // Passing active element name in sparam
      }

   //--- Processing custom chart events
      if(id>CHARTEVENT_CUSTOM)
     {
      //--- Do not process our own events
      if(sparam==this.NameFG())
          return;

      //--- Convert custom event ID to standard chart event type
      ENUM_CHART_EVENT chart_event=ENUM_CHART_EVENT(id-CHARTEVENT_CUSTOM);
      
      //--- If object click, call custom event handler
      if(chart_event==CHARTEVENT_OBJECT_CLICK)
        {
         this.MousePressHandler(chart_event, lparam, dparam, sparam);
        }
      //--- If mouse move, call custom event handler
      if(chart_event==CHARTEVENT_MOUSE_MOVE)
        {
         this.MouseMoveHandler(chart_event, lparam, dparam, sparam);
        }
      //--- If mouse wheel, call custom event handler
      if(chart_event==CHARTEVENT_MOUSE_WHEEL)
        {
         this.MouseWheelHandler(chart_event, lparam, dparam, sparam);
        }
      //--- If object property change, call custom event handler
      if(chart_event==CHARTEVENT_OBJECT_CHANGE)
        {
         this.ObjectChangeHandler(chart_event, lparam, dparam, sparam);
        }
     }
}
  //+------------------------------------------------------------------+
//| CCanvasBase::Focus release handler                               |
//+------------------------------------------------------------------+
void CCanvasBase::OnReleaseEvent(const int id,const long lparam,const double dparam,const string sparam)
{
   //--- Element is not in focus when the cursor leaves
      this.m_focused=false;
   //--- Restore original colors and redraw the object
      if(!this.CheckColor(COLOR_STATE_DEFAULT))
      {
         this.ColorChange(COLOR_STATE_DEFAULT);
         this.Draw(true);
      }
   //--- Reset the cursor offset from the top-left corner of the element
      this.m_cursor_delta_x=0;
      this.m_cursor_delta_y=0;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Mouse hover handler                                 |
//+------------------------------------------------------------------+
void CCanvasBase::OnFocusEvent(const int id,const long lparam,const double dparam,const string sparam)
{
   //--- Element is in focus
      this.m_focused=true;
   //--- If object colors are not set for Focused state
      if(!this.CheckColor(COLOR_STATE_FOCUSED))
      {
         //--- Set Focused colors and flag, then redraw the object
         this.ColorChange(COLOR_STATE_FOCUSED);
         this.Draw(true);
      }
   //--- Reset the cursor offset from the top-left corner of the element
      this.m_cursor_delta_x=0;
      this.m_cursor_delta_y=0;
}
//+------------------------------------------------------------------+
//| CCanvasBase::Object click handler                                |
//+------------------------------------------------------------------+
void CCanvasBase::OnPressEvent(const int id,const long lparam,const double dparam,const string sparam)
  {
//--- Element is in focus when clicked
   this.m_focused=true;
//--- If object colors are not set for Pressed state
   if(!this.CheckColor(COLOR_STATE_PRESSED))
     {
      //--- Set Pressed colors and redraw the object
      this.ColorChange(COLOR_STATE_PRESSED);
      this.Draw(true);
     }
//--- Reset the cursor offset from the top-left corner of the element
   this.m_cursor_delta_x=0;
   this.m_cursor_delta_y=0;
//--- Send a custom chart event with passed lparam, dparam values and the object name in sparam
   ::EventChartCustom(this.m_chart_id, (ushort)CHARTEVENT_OBJECT_CLICK, lparam, dparam, this.NameFG());
  }
//+------------------------------------------------------------------+
//| CCanvasBase::Cursor movement handler                             |
//+------------------------------------------------------------------+
void CCanvasBase::OnMoveEvent(const int id,const long lparam,const double dparam,const string sparam)
{
   //--- Element is in focus when clicked
      this.m_focused=true;
   //--- If object colors are not set for Pressed state
      if(!this.CheckColor(COLOR_STATE_PRESSED))
      {
         //--- Set Pressed colors and redraw the object
         this.ColorChange(COLOR_STATE_PRESSED);
         this.Draw(true);
      }
   //--- Calculate the cursor offset from the top-left corner of the element along X and Y axes
      if(this.m_cursor_delta_x==0)
         this.m_cursor_delta_x=(int)lparam-this.X();
      if(this.m_cursor_delta_y==0)
         this.m_cursor_delta_y=(int)::round(dparam-this.Y());
}
//+------------------------------------------------------------------+
//| CCanvasBase::Graphic object creation event handler               |
//+------------------------------------------------------------------+
void CCanvasBase::OnCreateEvent(const int id,const long lparam,const double dparam,const string sparam)
{
   //--- If the created object belongs to this program, exit
      if(this.IsBelongsToThis(sparam))
         return;
   //--- Bring the object to the foreground
      this.BringToTop(true);
}
//+------------------------------------------------------------------+
#endif