//+------------------------------------------------------------------+
//|                                                     ChartObj.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|Topic link:  https://www.mql5.com/en/articles/9213                |
//|Topic link:  https://www.mql5.com/en/articles/9236                |
//|Topic link:  https://www.mql5.com/en/articles/9260                |
//|Topic link:  https://www.mql5.com/en/articles/9293                |
//|Topic link:  https://www.mql5.com/en/articles/9385                |
//|Lib          https://www.mql5.com/en/articles/14710               |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __CHARTOBJ_MQH__
#define __CHARTOBJ_MQH__
 #property strict    // Necessary for mql4
 //+------------------------------------------------------------------+
 //| Include Custom files                                             |
 //+------------------------------------------------------------------+
  #include "..\Bases\BaseObjExt.mqh"
  #include "..\..\Services\DELib\TimeseriesDELib.mqh" 
  #include "..\..\Services\DELib\ChartDELib.mqh"   
  #include "WndInd.mqh"
  #include "..\GBases\GElement.mqh"
#ifndef CCHARTOBJ_MQH_DECLARATION
#define CCHARTOBJ_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Chart object class                                               |
 //+------------------------------------------------------------------+
 class CChartObj : public CBaseObjExt
  {
   private:
       CArrayObj         m_list_ind;                                  // The indicators of all chart windows: name, type and parameters
      CArrayObj         m_list_ind_del;                              // The indicators removed from the chart windows
      CArrayObj         m_list_ind_param;                            // The indicators whose parameters were changed (the old type and parameters)
      long              m_long_prop[CHART_PROP_INTEGER_TOTAL];       // Integer properties
      double            m_double_prop[CHART_PROP_DOUBLE_TOTAL];      // Real properties
      string            m_string_prop[CHART_PROP_STRING_TOTAL];      // String properties
      string            m_symbol_prev;                               // Previous chart symbol
      ENUM_TIMEFRAMES   m_timeframe_prev;                            // Previous timeframe
      int               m_digits;                                    // Symbol's Digits()
      int               m_last_event;                                // The last event
      datetime          m_wnd_time_x;                                // Time for X coordinate on the windowed chart
      double            m_wnd_price_y;                               // Price for Y coordinate on the windowed chart      
      long              m_chart_id;                                  // Chart ID
      CArrayObj         m_list_top_element;                          // Views kept above every other chart object (not owned)
      int               m_objects_total_prev;                        // ObjectsTotal() at the last Refresh
    //--- Return the index of the array the (1) double and (2) string properties are actually located at
      int               IndexProp(ENUM_CHART_PROP_DOUBLE property)   const { return(int)property-CHART_PROP_INTEGER_TOTAL;                         }
      int               IndexProp(ENUM_CHART_PROP_STRING property)   const { return(int)property-CHART_PROP_INTEGER_TOTAL-CHART_PROP_DOUBLE_TOTAL; }

    //--- The methods of setting parameter flags 
      bool              SetShowFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetBringToTopFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetContextMenuFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetCrosshairToolFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetMouseScrollFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetEventMouseWhellFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetEventMouseMoveFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetEventObjectCreateFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetEventObjectDeleteFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetForegroundFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetShiftFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetAutoscrollFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetKeyboardControlFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetQuickNavigationFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetScaleFixFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetScaleFix11Flag(const string source,const bool flag,const bool redraw=false);
      bool              SetScalePTPerBarFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetShowTickerFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetShowOHLCFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetShowBidLineFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetShowAskLineFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetShowLastLineFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetShowPeriodSeparatorsFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetShowGridFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetShowObjectDescriptionsFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetShowTradeLevelsFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetDragTradeLevelsFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetShowDateScaleFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetShowPriceScaleFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetShowOneClickPanelFlag(const string source,const bool flag,const bool redraw=false);
      bool              SetDockedFlag(const string source,const bool flag,const bool redraw=false);
    //--- The methods of setting property values
      bool              SetMode(const string source,const ENUM_CHART_MODE mode,const bool redraw=false);
      bool              SetScale(const string source,const int scale,const bool redraw=false);
      bool              SetModeVolume(const string source,const ENUM_CHART_VOLUME_MODE mode,const bool redraw=false);
      void              SetVisibleBars(void);
      void              SetWindowsTotal(void);
      void              SetFirstVisibleBars(void);
      void              SetWidthInBars(void);
      void              SetWidthInPixels(void);
      void              SetMaximizedFlag(void);
      void              SetMinimizedFlag(void);
      void              SetExpertName(void);
      void              SetScriptName(void);      
    //--- Fill in (1) integer, (2) real and (3) string object properties
      bool              SetIntegerParameters(void);
      void              SetDoubleParameters(void);
      bool              SetStringParameters(void);
    //--- Compare the indicators of every chart window with the list: add, remove or change them and send the event of each
       void              IndicatorsRefresh(void);
    //--- Re-show every registered top element above the other chart objects
      void              BringTopElementsToTop(void);
   public:
    //--- Set object's (1) integer, (2) real and (3) string properties
      void              SetProperty(ENUM_CHART_PROP_INTEGER property,long value)    { this.m_long_prop[property]=value;                      }
      void              SetProperty(ENUM_CHART_PROP_DOUBLE property,double value)   { this.m_double_prop[this.IndexProp(property)]=value;    }
      void              SetProperty(ENUM_CHART_PROP_STRING property,string value)   { this.m_string_prop[this.IndexProp(property)]=value;    }
    //--- Return object’s (1) integer, (2) real and (3) string property from the properties array
      long              GetProperty(ENUM_CHART_PROP_INTEGER property)         const { return this.m_long_prop[property];                     }
      double            GetProperty(ENUM_CHART_PROP_DOUBLE property)          const { return this.m_double_prop[this.IndexProp(property)];   }
      string            GetProperty(ENUM_CHART_PROP_STRING property)          const { return this.m_string_prop[this.IndexProp(property)];   }
    //--- Return (1) itself and (2) the list of the indicators of all chart windows
       CChartObj        *GetObject(void)                                             { return &this;                        }
       CArrayObj        *GetList(void)                                               { return &this.m_list_ind;             }
    //--- Return (1) the last one added, (2) the last one removed and (3) the changed indicator
       CWndInd          *GetLastAddedIndicator(void)                                 { return this.m_list_ind.At(this.m_list_ind.Total()-1);           }
       CWndInd          *GetLastDeletedIndicator(void)                               { return this.m_list_ind_del.At(this.m_list_ind_del.Total()-1);   }
       CWndInd          *GetLastChangedIndicator(void)                               { return this.m_list_ind_param.At(this.m_list_ind_param.Total()-1);}
    //--- Return the indicator by its index in the specified chart window
      CWndInd          *GetIndicator(const int win_num,const int ind_index);      
    //--- (1) Check, (2) attach and (3) detach an indicator of the chart by its type and parameters
      bool              IsIndicatorShownOnChart(const ENUM_INDICATOR type,MqlParam &params[]);
      void              ShowIndicatorOnChart(const ENUM_INDICATOR type,MqlParam &params[]);
      void              RemoveIndicatorFromChart(const ENUM_INDICATOR type,MqlParam &params[]);
    //--- Return the flag of the object supporting this property
      virtual bool      SupportProperty(ENUM_CHART_PROP_INTEGER property)           { return true; }
      virtual bool      SupportProperty(ENUM_CHART_PROP_DOUBLE property)            { return true; }
      virtual bool      SupportProperty(ENUM_CHART_PROP_STRING property)            { return true; }
    //--- Get description of (1) integer, (2) real and (3) string properties
      string            GetPropertyDescription(ENUM_CHART_PROP_INTEGER property);
      string            GetPropertyDescription(ENUM_CHART_PROP_DOUBLE property);
      string            GetPropertyDescription(ENUM_CHART_PROP_STRING property);
    //--- Display the description of the object properties in the journal (full_prop=true - all properties, false - supported ones only - implemented in descendant classes)
      virtual void      Print(const bool full_prop=false,const bool dash=false);
    //--- Display a short description of the object in the journal
      virtual void      PrintShort(const bool dash=false,const bool symbol=false);
    //--- Return the object short name
      virtual string    Header(void);      
    //--- Create and send the chart event to the control program chart
      void              SendEvent(ENUM_CHART_OBJ_EVENT event,CWndInd *ind=NULL);   
    //--- Compare CChartObj objects by a specified property (to sort the list by a specified chart object property)
      virtual int       Compare(const CObject *node,const int mode=0) const;
    //--- Compare CChartObj objects by all properties (to search for equal chart objects)
      bool              IsEqual(CChartObj* compared_obj) const;
    //--- Update the chart object and its list of indicator windows
      void              Refresh(void);      
    //--- Keep a view (e.g. the EA panel window) above every other object of this chart
      bool              AddTopElement(CGElement *element);
    //--- Return (1) the flag event, (2) the last event code and (3) the last event
      bool              IsEvent(void)                                   const { return this.m_is_event;                                      }
      int               GetLastEventsCode(void)                         const { return this.m_event_code;                                    }
      int               GetLastEvent(void)                              const { return this.m_last_event;                                    }      
    //--- Constructors
                        CChartObj(){ this.m_type=OBJECT_DE_TYPE_CHART; this.m_chart_id=::ChartID(); }
      void              SetChartID(const long id)                             { this.m_chart_id=id;     }
      long              GetChartID(void)                                const { return this.m_chart_id; }
                        CChartObj(const long chart_id);
    //+------------------------------------------------------------------+ 
    //| Methods of simplified access to chart object properties          |
    //+------------------------------------------------------------------+
    //--- (1) Return, (2) enable, (3) disable drawing a price chart 
      bool              IsShow(void)                                    const { return (bool)this.GetProperty(CHART_PROP_SHOW);              }
      bool              SetShowON(const bool redraw=false)                    { return this.SetShowFlag(DFUN,true,redraw);                   }
      bool              SetShowOFF(const bool redraw=false)                   { return this.SetShowFlag(DFUN,true,redraw);                   }
      
    //--- (1) Return, (2) enable, (3) disable access to the context menu using the right click
      bool              IsAllowedContextMenu(void)                      const { return (bool)this.GetProperty(CHART_PROP_CONTEXT_MENU);      }
      bool              SetContextMenuON(const bool redraw=false)             { return this.SetContextMenuFlag(DFUN,true,redraw);            }
      bool              SetContextMenuOFF(const bool redraw=false)            { return this.SetContextMenuFlag(DFUN,false,redraw);           }
      
    //--- (1) Return, (2) enable, (3) disable access to the Crosshair using the middle click
      bool              IsCrosshairTool(void)                           const { return (bool)this.GetProperty(CHART_PROP_CROSSHAIR_TOOL);    }
      bool              SetCrosshairToolON(const bool redraw=false);
      bool              SetCrosshairToolOFF(const bool redraw=false);
      
    //--- (1) Return, (2) enable, (3) disable scrolling the chart horizontally using the left click
      bool              IsMouseScroll(void)                             const { return (bool)this.GetProperty(CHART_PROP_MOUSE_SCROLL);      }
      bool              SetMouseScrollON(const bool redraw=false)             { return this.SetMouseScrollFlag(DFUN,true,redraw);            }
      bool              SetMouseScrollOFF(const bool redraw=false)            { return this.SetMouseScrollFlag(DFUN,false,redraw);           }
      
    //--- (1) Return, (2) enable, (3) disable sending messages about mouse wheel events to all MQL5 programs on a chart
      bool              IsEventMouseWhell(void)                         const { return (bool)this.GetProperty(CHART_PROP_EVENT_MOUSE_WHEEL); }
      bool              SetEventMouseWhellON(const bool redraw=false)         { return this.SetEventMouseWhellFlag(DFUN,true,redraw);        }
      bool              SetEventMouseWhellOFF(const bool redraw=false)        { return this.SetEventMouseWhellFlag(DFUN,false,redraw);       }
      
    //--- (1) Return, (2) enable, (3) disable sending messages about mouse button movement and click events to all MQL5 programs on a chart
      bool              IsEventMouseMove(void)                          const { return (bool)this.GetProperty(CHART_PROP_EVENT_MOUSE_MOVE);  }
      bool              SetEventMouseMoveON(const bool redraw=false)          { return this.SetEventMouseMoveFlag(DFUN,true,redraw);         }
      bool              SetEventMouseMoveOFF(const bool redraw=false)         { return this.SetEventMouseMoveFlag(DFUN,false,redraw);        }
      
    //--- (1) Return, (2) enable, (3) disable sending messages about the graphical object creation event to all MQL5 programs on a chart
      bool              IsEventObjectCreate(void)                       const { return (bool)this.GetProperty(CHART_PROP_EVENT_OBJECT_CREATE);}
      bool              SetEventObjectCreateON(const bool redraw=false)       { return this.SetEventObjectCreateFlag(DFUN,true,redraw);      }
      bool              SetEventObjectCreateOFF(const bool redraw=false)      { return this.SetEventObjectCreateFlag(DFUN,false,redraw);     }
      
    //--- (1) Return, (2) enable, (3) disable sending messages about the graphical object destruction event to all MQL5 programs on a chart
      bool              IsEventObjectDelete(void)                       const { return (bool)this.GetProperty(CHART_PROP_EVENT_OBJECT_DELETE);}
      bool              SetEventObjectDeleteON(const bool redraw=false)       { return this.SetEventObjectDeleteFlag(DFUN,true,redraw);      }
      bool              SetEventObjectDeleteOFF(const bool redraw=false)      { return this.SetEventObjectDeleteFlag(DFUN,false,redraw);     }
      
    //--- (1) Return, (2) enable, (3) disable price chart in the foreground
      bool              IsForeground(void)                              const { return (bool)this.GetProperty(CHART_PROP_FOREGROUND);        }
      bool              SetForegroundON(const bool redraw=false)              { return this.SetForegroundFlag(DFUN,true,redraw);             }
      bool              SetForegroundOFF(const bool redraw=false)             { return this.SetForegroundFlag(DFUN,false,redraw);            }
      
    //--- (1) Return, (2) enable, (3) disable shift of the price chart from the right border
      bool              IsShift(void)                                   const { return (bool)this.GetProperty(CHART_PROP_SHIFT);             }
      bool              SetShiftON(const bool redraw=false)                   { return this.SetShiftFlag(DFUN,true,redraw);                  }
      bool              SetShiftOFF(const bool redraw=false)                  { return this.SetShiftFlag(DFUN,false,redraw);                 }
      
    //--- (1) Return, (2) enable, (3) disable auto scroll to the right border of the chart
      bool              IsAutoscroll(void)                              const { return (bool)this.GetProperty(CHART_PROP_AUTOSCROLL);        }
      bool              SetAutoscrollON(const bool redraw=false)              { return this.SetAutoscrollFlag(DFUN,true,redraw);             }
      bool              SetAutoscrollOFF(const bool redraw=false)             { return this.SetAutoscrollFlag(DFUN,false,redraw);            }
      
    //--- (1) Return, (2) enable, (3) disable the permission to manage the chart using a keyboard
      bool              IsKeyboardControl(void)                         const { return (bool)this.GetProperty(CHART_PROP_KEYBOARD_CONTROL);  }
      bool              SetKeyboardControlON(const bool redraw=false)         { return this.SetKeyboardControlFlag(DFUN,true,redraw);        }
      bool              SetKeyboardControlOFF(const bool redraw=false)        { return this.SetKeyboardControlFlag(DFUN,false,redraw);       }
      
    //--- (1) Return, (2) enable, (3) disable the permission for the chart to intercept Space and Enter key strokes to activate the quick navigation bar
      bool              IsQuickNavigation(void)                         const { return (bool)this.GetProperty(CHART_PROP_QUICK_NAVIGATION);  }
      bool              SetQuickNavigationON(const bool redraw=false)         { return this.SetQuickNavigationFlag(DFUN,true,redraw);        }
      bool              SetQuickNavigationOFF(const bool redraw=false)        { return this.SetQuickNavigationFlag(DFUN,false,redraw);       }
      
    //--- (1) Return, (2) enable, (3) disable a fixed scale
      bool              IsScaleFix(void)                                const { return (bool)this.GetProperty(CHART_PROP_SCALEFIX);          }
      bool              SetScaleFixON(const bool redraw=false)                { return this.SetScaleFixFlag(DFUN,true,redraw);               }
      bool              SetScaleFixOFF(const bool redraw=false)               { return this.SetScaleFixFlag(DFUN,false,redraw);              }
      
    //--- (1) Return, (2) enable, (3) disable the 1:1 scale
      bool              IsScaleFix11(void)                              const { return (bool)this.GetProperty(CHART_PROP_SCALEFIX_11);       }
      bool              SetScaleFix11ON(const bool redraw=false)              { return this.SetScaleFix11Flag(DFUN,true,redraw);             }
      bool              SetScaleFix11OFF(const bool redraw=false)             { return this.SetScaleFix11Flag(DFUN,false,redraw);            }
      
    //--- (1) Return, (2) enable, (3) disable the mode of specifying the chart scale in points per bar
      bool              IsScalePTPerBar(void)                           const { return (bool)this.GetProperty(CHART_PROP_SCALE_PT_PER_BAR);  }
      bool              SetScalePTPerBarON(const bool redraw=false)           { return this.SetScalePTPerBarFlag(DFUN,true,redraw);          }
      bool              SetScalePTPerBarOFF(const bool redraw=false)          { return this.SetScalePTPerBarFlag(DFUN,false,redraw);         }
      
    //--- (1) Return, (2) enable, (3) disable a display of a symbol ticker in the upper left corner
      bool              IsShowTicker(void)                              const { return (bool)this.GetProperty(CHART_PROP_SHOW_TICKER);       }
      bool              SetShowTickerON(const bool redraw=false)              { return this.SetShowTickerFlag(DFUN,true,redraw);             }
      bool              SetShowTickerOFF(const bool redraw=false)             { return this.SetShowTickerFlag(DFUN,false,redraw);            }
      
    //--- (1) Return, (2) enable, (3) disable a display of OHLC values in the upper left corner
      bool              IsShowOHLC(void)                                const { return (bool)this.GetProperty(CHART_PROP_SHOW_OHLC);         }
      bool              SetShowOHLCON(const bool redraw=false)                { return this.SetShowOHLCFlag(DFUN,true,redraw);               }
      bool              SetShowOHLCOFF(const bool redraw=false)               { return this.SetShowOHLCFlag(DFUN,false,redraw);              }
      
    //--- (1) Return, (2) enable, (3) disable the display of a Bid value as a horizontal line on the chart
      bool              IsShowBidLine(void)                             const { return (bool)this.GetProperty(CHART_PROP_SHOW_BID_LINE);     }
      bool              SetShowBidLineON(const bool redraw=false)             { return this.SetShowBidLineFlag(DFUN,true,redraw);            }
      bool              SetShowBidLineOFF(const bool redraw=false)            { return this.SetShowBidLineFlag(DFUN,false,redraw);           }
      
    //--- (1) Return, (2) enable, (3) disable the display of a Ask value as a horizontal line on the chart
      bool              IsShowAskLine(void)                             const { return (bool)this.GetProperty(CHART_PROP_SHOW_ASK_LINE);     }
      bool              SetShowAskLineON(const bool redraw=false)             { return this.SetShowAskLineFlag(DFUN,true,redraw);            }
      bool              SetShowAskLineOFF(const bool redraw=false)            { return this.SetShowAskLineFlag(DFUN,false,redraw);           }
      
    //--- (1) Return, (2) enable, (3) disable the display of a Last value as a horizontal line on the chart
      bool              IsShowLastLine(void)                            const { return (bool)this.GetProperty(CHART_PROP_SHOW_LAST_LINE);    }
      bool              SetShowLastLineON(const bool redraw=false)            { return this.SetShowLastLineFlag(DFUN,true,redraw);           }
      bool              SetShowLastLineOFF(const bool redraw=false)           { return this.SetShowLastLineFlag(DFUN,false,redraw);          }
      
    //--- (1) Return, (2) enable, (3) disable the display of vertical separators between adjacent periods
      bool              IsShowPeriodSeparators(void)                    const { return (bool)this.GetProperty(CHART_PROP_SHOW_PERIOD_SEP);   }
      bool              SetShowPeriodSeparatorsON(const bool redraw=false)    { return this.SetShowPeriodSeparatorsFlag(DFUN,true,redraw);   }
      bool              SetShowPeriodSeparatorsOFF(const bool redraw=false)   { return this.SetShowPeriodSeparatorsFlag(DFUN,false,redraw);  }
      
    //--- (1) Return, (2) enable, (3) disable the display of the chart grid
      bool              IsShowGrid(void)                                const { return (bool)this.GetProperty(CHART_PROP_SHOW_GRID);         }
      bool              SetShowGridON(const bool redraw=false)                { return this.SetShowGridFlag(DFUN,true,redraw);               }
      bool              SetShowGridOFF(const bool redraw=false)               { return this.SetShowGridFlag(DFUN,false,redraw);              }
      
    //--- (1) Return, (2) enable, (3) disable the display of text descriptions of objects
      bool              IsShowObjectDescriptions(void)   const { return (bool)this.GetProperty(CHART_PROP_SHOW_OBJECT_DESCR);                }
      bool              SetShowObjectDescriptionsON(const bool redraw=false);
      bool              SetShowObjectDescriptionsOFF(const bool redraw=false);
   
    //--- (1) Return, (2) enable, (3) disable the display of trade levels on the chart (levels of open positions, Stop Loss, Take Profit and pending orders)
      bool              IsShowTradeLevels(void)                         const { return (bool)this.GetProperty(CHART_PROP_SHOW_TRADE_LEVELS); }
      bool              SetShowTradeLevelsON(const bool redraw=false)         { return this.SetShowTradeLevelsFlag(DFUN,true,redraw);        }
      bool              SetShowTradeLevelsOFF(const bool redraw=false)        { return this.SetShowTradeLevelsFlag(DFUN,false,redraw);       }
      
    //--- (1) Return, (2) enable, (3) disable the ability to drag trading levels on a chart using mouse
      bool              IsDragTradeLevels(void)                         const { return (bool)this.GetProperty(CHART_PROP_DRAG_TRADE_LEVELS); }
      bool              SetDragTradeLevelsON(const bool redraw=false)         { return this.SetDragTradeLevelsFlag(DFUN,true,redraw);        }
      bool              SetDragTradeLevelsOFF(const bool redraw=false)        { return this.SetDragTradeLevelsFlag(DFUN,false,redraw);       }
      
    //--- (1) Return, (2) enable, (3) disable the display of the time scale on the chart
      bool              IsShowDateScale(void)                           const { return (bool)this.GetProperty(CHART_PROP_SHOW_DATE_SCALE);   }
      bool              SetShowDateScaleON(const bool redraw=false)           { return this.SetShowDateScaleFlag(DFUN,true,redraw);          }
      bool              SetShowDateScaleOFF(const bool redraw=false)          { return this.SetShowDateScaleFlag(DFUN,false,redraw);         }
      
    //--- (1) Return, (2) enable, (3) disable the display of the price scale on the chart
      bool              IsShowPriceScale(void)                          const { return (bool)this.GetProperty(CHART_PROP_SHOW_PRICE_SCALE);  }
      bool              SetShowPriceScaleON(const bool redraw=false)          { return this.SetShowPriceScaleFlag(DFUN,true,redraw);         }
      bool              SetShowPriceScaleOFF(const bool redraw=false)         { return this.SetShowPriceScaleFlag(DFUN,false,redraw);        }
      
    //--- (1) Return, (2) enable, (3) disable the display of the quick trading panel on the chart
      bool              IsShowOneClickPanel(void)                       const { return (bool)this.GetProperty(CHART_PROP_SHOW_ONE_CLICK);    }
      bool              SetShowOneClickPanelON(const bool redraw=false)       { return this.SetShowOneClickPanelFlag(DFUN,true,redraw);      }
      bool              SetShowOneClickPanelOFF(const bool redraw=false)      { return this.SetShowOneClickPanelFlag(DFUN,false,redraw);     }
      
    //--- (1) Return, (2) enable, (3) disable docking the chart window
      bool              IsDocked(void)                                  const { return (bool)this.GetProperty(CHART_PROP_IS_DOCKED);         }
      bool              SetDockedON(const bool redraw=false)                  { return this.SetDockedFlag(DFUN,true,redraw); }
      bool              SetDockedOFF(const bool redraw=false)                 { return this.SetDockedFlag(DFUN,false,redraw); }
      
    //--- (1) Return, (2) enable and (3) disable the display of the chart above all others
      bool              IsBringTop(void)                                      { return (bool)this.GetProperty(CHART_PROP_BRING_TO_TOP);      }
      bool              SetBringToTopON(const bool redraw=false)              { return this.SetBringToTopFlag(DFUN,true,redraw);             }
      bool              SetBringToTopOFF(const bool redraw=false)             { return this.SetBringToTopFlag(DFUN,false,redraw);            }
      
    //--- (1) Return, set the chart type (2) bars, (3) candles, (4) line 
      ENUM_CHART_MODE   Mode(void)                                      const { return (ENUM_CHART_MODE)this.GetProperty(CHART_PROP_MODE);   }
      bool              SetModeBars(const bool redraw=false)                  { return this.SetMode(DFUN,CHART_BARS,redraw);                 }
      bool              SetModeCandles(const bool redraw=false)               { return this.SetMode(DFUN,CHART_CANDLES,redraw);              }
      bool              SetModeLine(const bool redraw=false)                  { return this.SetMode(DFUN,CHART_LINE,redraw);                 }

    //--- (1) Return, (2 - 7) set the chart scale
      int               Scale(void)                                     const { return (int)this.GetProperty(CHART_PROP_SCALE);              }
      bool              SetScale0(const bool redraw=false)                    { return this.SetScale(DFUN,0,redraw);                         }
      bool              SetScale1(const bool redraw=false)                    { return this.SetScale(DFUN,1,redraw);                         }
      bool              SetScale2(const bool redraw=false)                    { return this.SetScale(DFUN,2,redraw);                         }
      bool              SetScale3(const bool redraw=false)                    { return this.SetScale(DFUN,3,redraw);                         }
      bool              SetScale4(const bool redraw=false)                    { return this.SetScale(DFUN,4,redraw);                         }
      bool              SetScale5(const bool redraw=false)                    { return this.SetScale(DFUN,5,redraw);                         }      
    //--- (1) Return, set the volume display modes (2) disabled, (3) tick volumes, (4) real volumes 
      ENUM_CHART_VOLUME_MODE  ModeVolume(void)                          const { return (ENUM_CHART_VOLUME_MODE)this.GetProperty(CHART_PROP_SHOW_VOLUMES);}
      bool              SetModeVolumeHide(const bool redraw=false)            { return this.SetModeVolume(DFUN,CHART_VOLUME_HIDE,redraw);    }
      bool              SetModeVolumeTick(const bool redraw=false)            { return this.SetModeVolume(DFUN,CHART_VOLUME_TICK,redraw);    }
      bool              SetModeVolumeReal(const bool redraw=false)            { return this.SetModeVolume(DFUN,CHART_VOLUME_REAL,redraw);    }
    //--- Return, (2) set the chart background color
      color             ColorBackground(void)                           const { return (color)this.GetProperty(CHART_PROP_COLOR_BACKGROUND); }
      bool              SetColorBackground(const color colour,const bool redraw=false);
    //--- (1) Return, (2) set the color of axes, scale and OHLC line
      color             ColorForeground(void)                           const { return (color)this.GetProperty(CHART_PROP_COLOR_FOREGROUND); }
      bool              SetColorForeground(const color colour,const bool redraw=false);      
    //--- (1) Return and (2) set the grid color
      color             ColorGrid(void)                                 const { return (color)this.GetProperty(CHART_PROP_COLOR_GRID);       }
      bool              SetColorGrid(const color colour,const bool redraw=false);
    //--- (1) Return and (2) set the volume color and position opening levels
      color             ColorVolume(void)                               const { return (color)this.GetProperty(CHART_PROP_COLOR_VOLUME);     }
      bool              SetColorVolume(const color colour,const bool redraw=false);
      
    //--- (1) Return and (2) set the color of up bar, its shadow and border of bullish candle body
      color             ColorUp(void)                                   const { return (color)this.GetProperty(CHART_PROP_COLOR_CHART_UP);   }
      bool              SetColorUp(const color colour,const bool redraw=false);
      
    //--- (1) Return and (2) set the color of down bar, its shadow and border of bearish candle body
      color             ColorDown(void)                                 const { return (color)this.GetProperty(CHART_PROP_COLOR_CHART_DOWN); }
      bool              SetColorDown(const color colour,const bool redraw=false);
      
    //--- (1) Return and (2) set the color of the chart line and Doji candles
      color             ColorLine(void)                                 const { return (color)this.GetProperty(CHART_PROP_COLOR_CHART_LINE); }
      bool              SetColorLine(const color colour,const bool redraw=false);
      
    //--- (1) Return and (2) set the color of the bullish candle body
      color             ColorCandleBull(void)                           const { return (color)this.GetProperty(CHART_PROP_COLOR_CANDLE_BULL);}
      bool              SetColorCandleBull(const color colour,const bool redraw=false);
      
    //--- (1) Return and (2) set the color of the bearish candle body
      color             ColorCandleBear(void)                           const { return (color)this.GetProperty(CHART_PROP_COLOR_CANDLE_BEAR);}
      bool              SetColorCandleBear(const color colour,const bool redraw=false);
      
    //--- (1) Return and (2) set the Bid price line color
      color             ColorBid(void)                                  const { return (color)this.GetProperty(CHART_PROP_COLOR_BID);        }
      bool              SetColorBid(const color colour,const bool redraw=false);
      
    //--- (1) Return and (2) set the Ask price line color
      color             ColorAsk(void)                                  const { return (color)this.GetProperty(CHART_PROP_COLOR_ASK);        }
      bool              SetColorAsk(const color colour,const bool redraw=false);
      
    //--- (1) Return and (2) set the color of the price line of the last performed deal (Last)
      color             ColorLast(void)                                 const { return (color)this.GetProperty(CHART_PROP_COLOR_LAST);       }
      bool              SetColorLast(const color colour,const bool redraw=false);
      
    //--- (1) Return and (2) set the color of stop order levels (Stop Loss and Take Profit)
      color             ColorStops(void)                                const { return (color)this.GetProperty(CHART_PROP_COLOR_STOP_LEVEL); }
      bool              SetColorStops(const color colour,const bool redraw=false);
      
    //--- (1) Return and (2) set the left coordinate of the undocked chart window relative to the virtual screen
      int               FloatLeft(void)                                 const { return (int)this.GetProperty(CHART_PROP_FLOAT_LEFT);         }
      bool              SetFloatLeft(const int value,const bool redraw=false);
      
    //--- (1) Return and (2) set the top coordinate of the undocked chart window relative to the virtual screen
      int               FloatTop(void)                                  const { return (int)this.GetProperty(CHART_PROP_FLOAT_TOP);          }
      bool              SetFloatTop(const int value,const bool redraw=false);
      
    //--- (1) Return and (2) set the right coordinate of the undocked chart window relative to the virtual screen
      int               FloatRight(void)                                const { return (int)this.GetProperty(CHART_PROP_FLOAT_RIGHT);        }
      bool              SetFloatRight(const int value,const bool redraw=false);
      
    //--- (1) Return and (2) set the bottom coordinate of the undocked chart window relative to the virtual screen
      int               FloatBottom(void)                               const { return (int)this.GetProperty(CHART_PROP_FLOAT_BOTTOM);       }
      bool              SetFloatBottom(const int value,const bool redraw=false);
      
    //--- (1) Return and (2) set the shift size of the zero bar from the right border in %
      double            ShiftSize(void)                                 const { return this.GetProperty(CHART_PROP_SHIFT_SIZE);              }
      bool              SetShiftSize(const double value,const bool redraw=false);
      
    //--- (1) Return and (2) set the chart fixed position from the left border in %
      double            FixedPosition(void)                             const { return this.GetProperty(CHART_PROP_FIXED_POSITION);          }
      bool              SetFixedPosition(const double value,const bool redraw=false);
      
    //--- (1) Return and (2) set the fixed chart maximum
      double            FixedMaximum(void)                              const { return this.GetProperty(CHART_PROP_FIXED_MAX);               }
      bool              SetFixedMaximum(const double value,const bool redraw=false);
      
    //--- (1) Return and (2) set the fixed chart minimum
      double            FixedMinimum(void)                              const { return this.GetProperty(CHART_PROP_FIXED_MIN);               }
      bool              SetFixedMinimum(const double value,const bool redraw=false);
      
    //--- (1) Return and (2) set the value of the scale in points per bar
      double            PointsPerBar(void)                              const { return this.GetProperty(CHART_PROP_POINTS_PER_BAR);          }
      bool              SetPointsPerBar(const double value,const bool redraw=false);
   
    //--- (1) Return and (2) set the comment on the chart
      string            Comment(void)                                   const { return this.GetProperty(CHART_PROP_COMMENT);                 }
      bool              SetComment(const string comment,const bool redraw=false);
      
    //--- (1) Return and (2) set the chart symbol
      string            Symbol(void)                                    const { return this.GetProperty(CHART_PROP_SYMBOL);                  }
      bool              SetSymbol(const string symbol,const ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT);
      
    //--- (1) Return and (2) set the chart period
      ENUM_TIMEFRAMES   Timeframe(void)                                 const { return (ENUM_TIMEFRAMES)this.GetProperty(CHART_PROP_TIMEFRAME); }
      bool              SetTimeframe(const ENUM_TIMEFRAMES timeframe);
      
    //--- (1) Return the Chart object identification attribute
      bool              IsObject(void)                                  const { return (bool)this.GetProperty(CHART_PROP_IS_OBJECT);         }

    //--- Return the chart ID
      long              ID(void)                                        const { return this.GetProperty(CHART_PROP_ID);                      }

    //--- Return the number of bars on a chart that are available for display
      int               VisibleBars(void)                               const { return (int)this.GetProperty(CHART_PROP_VISIBLE_BARS);       }

    //--- Return the total number of chart windows including indicator subwindows
      int               WindowsTotal(void)                              const { return (int)this.GetProperty(CHART_PROP_WINDOWS_TOTAL);      }

    //--- Return the chart window handle
      int               Handle(void)                                    const { return (int)this.GetProperty(CHART_PROP_WINDOW_HANDLE);      } 

    //--- Return the number of the first visible bar on the chart
      int               FirstVisibleBars(void)                          const { return (int)this.GetProperty(CHART_PROP_FIRST_VISIBLE_BAR);  }

    //--- Return the chart width in bars
      int               WidthInBars(void)                               const { return (int)this.GetProperty(CHART_PROP_WIDTH_IN_BARS);      }

    //--- Return the chart width in pixels
      int               WidthInPixels(void)                             const { return (int)this.GetProperty(CHART_PROP_WIDTH_IN_PIXELS);    }
      
    //--- Return the "Chart window maximized" property
      bool              IsMaximized(void)                               const { return (bool)this.GetProperty(CHART_PROP_IS_MAXIMIZED);      }

    //--- Return the "Chart window minimized" property
      bool              IsMinimized(void)                               const { return (bool)this.GetProperty(CHART_PROP_IS_MINIMIZED);      }

    //--- Return the name of an EA launched on the chart
      string            ExpertName(void)                                const { return this.GetProperty(CHART_PROP_EXPERT_NAME);             }

    //--- Return the name of a script launched on the chart
      string            ScriptName(void)                                const { return this.GetProperty(CHART_PROP_SCRIPT_NAME);             }

    //--- Return the distance in Y axis pixels between the upper frame of the indicator subwindow and the upper frame of the chart main window
      int               WindowYDistance(const int sub_window)           const;
      
    //--- (1) Return and (2) set the height of the specified chart in pixels
      int               WindowHeightInPixels(const int sub_window)      const;
      bool              SetWindowHeightInPixels(const int height,const int sub_window,const bool redraw=false);
      
    //--- Return the specified subwindow visibility
      bool              IsVisibleWindow(const int sub_window)           const { return (bool)::ChartGetInteger(this.Handle(),CHART_WINDOW_IS_VISIBLE,sub_window); }
      
    //--- Return the minimum of the specified chart
      double            PriceMinimum(const int sub_window)              const { return ::ChartGetDouble(this.ID(),CHART_PRICE_MIN,sub_window);  }

    //--- Return the maximum of the specified chart
      double            PriceMaximum(const int sub_window)              const { return ::ChartGetDouble(this.ID(),CHART_PRICE_MAX,sub_window);  }

    //--- Emulate a tick (chart updates - similar to the terminal Refresh command)
      void              EmulateTick(void)                                     { ::ChartSetSymbolPeriod(this.ID(),this.Symbol(),this.Timeframe());}

    //--- Return the flag indicating that the chart object belongs to the program chart
      bool              IsMainChart(void)                               const { return(this.m_chart_id==::ChartID());            }
      
    //--- Display data of all indicators of all chart windows in the journal
      void              PrintWndIndicators(void);
    //--- Display the properties of all chart windows in the journal

    //--- Shift the chart by the specified number of bars relative to the specified chart position
      bool              Navigate(const int shift,const ENUM_CHART_POSITION position);
    //--- Shift the chart (1) to the left and (2) to the right by the specified number of bars
      bool              NavigateLeft(const int shift);
      bool              NavigateRight(const int shift);
    //--- Shift the chart (1) to the beginning and (2) to the end of the history data
      bool              NavigateBegin(void);
      bool              NavigateEnd(void);
    //--- Convert X and Y chart window coordinates into time and price
      int               XYToTimePrice(const long x,const double y);
    //--- Open time of the candle under the X and Y chart window coordinates (main window only), 0 if there is none
      datetime          GetBarTimeFromXY(const int x,const int y);
    //--- Return (1) time and (2) price from XY coordinates
      datetime          TimeFromXY(void)                                const { return this.m_wnd_time_x;   }
      double            PriceFromXY(void)                               const { return this.m_wnd_price_y;  }      
    //+------------------------------------------------------------------+
    //| Get and set the parameters of tracked property changes           |
    //+------------------------------------------------------------------+
    //CHART_PROP_ID = 0,                                 // Chart ID      
    //--- Chart timeframe
    //--- setting the chart timeframe (1) increase, (2) decrease controlled value and (3) reference level
    //--- getting (4) the chart timeframe change value,
    //--- getting the chart timeframe change flag increasing the (5) growth and (6) decrease values
      void              SetControlTimeframeInc(const long value)              { this.SetControlledValueINC(CHART_PROP_TIMEFRAME,(long)::fabs(value));          }
      void              SetControlTimeframeDec(const long value)              { this.SetControlledValueDEC(CHART_PROP_TIMEFRAME,(long)::fabs(value));          }
      void              SetControlTimeframeLevel(const long value)            { this.SetControlledValueLEVEL(CHART_PROP_TIMEFRAME,(long)::fabs(value));        }
      long              GetValueChangedTimeframe(void)                  const { return this.GetPropLongChangedValue(CHART_PROP_TIMEFRAME);                     }
      bool              IsIncreasedTimeframe(void)                      const { return (bool)this.GetPropLongFlagINC(CHART_PROP_TIMEFRAME);                    }
      bool              IsDecreasedTimeframe(void)                      const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_TIMEFRAME);                    }
    //CHART_PROP_SHOW                                    // Price chart drawing
    //CHART_PROP_IS_OBJECT,                              // Chart object (OBJ_CHART) identification attribute
    //CHART_PROP_BRING_TO_TOP,                           // Show the chart above all others
    //CHART_PROP_CONTEXT_MENU,                           // Enable/disable access to the context menu using the right click 
    //CHART_PROP_CROSSHAIR_TOOL,                         // Enable/disable access to the Crosshair tool using the middle click
    //CHART_PROP_MOUSE_SCROLL,                           // Scroll the chart horizontally using the left mouse button
    //CHART_PROP_EVENT_MOUSE_WHEEL,                      // Send messages about mouse wheel events (CHARTEVENT_MOUSE_WHEEL) to all MQL5 programs on a chart
    //CHART_PROP_EVENT_MOUSE_MOVE,                       // Send messages about mouse button click and movement events (CHARTEVENT_MOUSE_MOVE) to all MQL5 programs on a chart
    //CHART_PROP_EVENT_OBJECT_CREATE,                    // Send messages about the graphical object creation event (CHARTEVENT_OBJECT_CREATE) to all MQL5 programs on a chart
    //CHART_PROP_EVENT_OBJECT_DELETE,                    // Send messages about the graphical object destruction event (CHARTEVENT_OBJECT_DELETE) to all MQL5 programs on a chart  
    //--- Type of the chart (candlesticks, bars or line (ENUM_CHART_MODE))
    //--- setting the chart type (1) increase, (2) decrease controlled value and (3) reference level
    //--- getting (4) the change value of the chart type,
    //--- getting the chart type change flag increasing the (5) growth and (6) decrease values
      void              SetControlChartModeInc(const long value)              { this.SetControlledValueINC(CHART_PROP_MODE,(long)::fabs(value));               }
      void              SetControlChartModeDec(const long value)              { this.SetControlledValueDEC(CHART_PROP_MODE,(long)::fabs(value));               }
      void              SetControlChartModeLevel(const long value)            { this.SetControlledValueLEVEL(CHART_PROP_MODE,(long)::fabs(value));             }
      long              GetValueChangedChartMode(void)                  const { return this.GetPropLongChangedValue(CHART_PROP_MODE);                          }
      bool              IsIncreasedChartMode(void)                      const { return (bool)this.GetPropLongFlagINC(CHART_PROP_MODE);                         }
      bool              IsDecreasedChartMode(void)                      const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_MODE);                         }
      //CHART_PROP_FOREGROUND,                             // Price chart in the foreground
      //CHART_PROP_SHIFT,                                  // Mode of shift of the price chart from the right border
      //CHART_PROP_AUTOSCROLL,                             // The mode of automatic shift to the right border of the chart
      //CHART_PROP_KEYBOARD_CONTROL,                       // Allow managing the chart using a keyboard
      //CHART_PROP_QUICK_NAVIGATION,                       // Allow the chart to intercept Space and Enter key strokes to activate the quick navigation bar
      
    //--- Chart scale (CHART_PROP_SCALE)
    //--- setting the chart scale (1) increase, (2) decrease controlled value and (3) reference level
    //--- getting (4) the change value of the chart scale,
    //--- getting the chart scale change flag increasing the (5) growth and (6) decrease values
      void              SetControlChartScaleInc(const long value)             { this.SetControlledValueINC(CHART_PROP_SCALE,(long)::fabs(value));              }
      void              SetControlChartScaleDec(const long value)             { this.SetControlledValueDEC(CHART_PROP_SCALE,(long)::fabs(value));              }
      void              SetControlChartScaleLevel(const long value)           { this.SetControlledValueLEVEL(CHART_PROP_SCALE,(long)::fabs(value));            }
      long              GetValueChangedChartScale(void)                 const { return this.GetPropLongChangedValue(CHART_PROP_SCALE);                         }
      bool              IsIncreasedChartScale(void)                     const { return (bool)this.GetPropLongFlagINC(CHART_PROP_SCALE);                        }
      bool              IsDecreasedChartScale(void)                     const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_SCALE);                       }
    //CHART_PROP_SCALEFIX,                               // Fixed scale mode
    //CHART_PROP_SCALEFIX_11,                            // 1:1 scale mode
    //CHART_PROP_SCALE_PT_PER_BAR,                       // The mode of specifying the scale in points per bar
    //CHART_PROP_SHOW_TICKER,                            // Display a symbol ticker in the upper left corner
    //CHART_PROP_SHOW_OHLC,                              // Display OHLC values in the upper left corner
    //CHART_PROP_SHOW_BID_LINE,                          // Display Bid value as a horizontal line on the chart
    //CHART_PROP_SHOW_ASK_LINE,                          // Display Ask value as a horizontal line on a chart
    //CHART_PROP_SHOW_LAST_LINE,                         // Display Last value as a horizontal line on a chart
    //CHART_PROP_SHOW_PERIOD_SEP,                        // Display vertical separators between adjacent periods
    //CHART_PROP_SHOW_GRID,                              // Display a grid on the chart
    //CHART_PROP_SHOW_VOLUMES,                           // Display volumes on a chart
    //CHART_PROP_SHOW_OBJECT_DESCR,                      // Display text descriptions of objects
    //CHART_PROP_VISIBLE_BARS,                           // Number of bars on a chart that are available for display
    //CHART_PROP_WINDOWS_TOTAL,                          // The total number of chart windows including indicator subwindows
    //CHART_PROP_WINDOW_HANDLE,                          // Chart window handle
    //--- Distance in Y axis pixels between the upper frame of the indicator subwindow and the upper frame of the chart main window
    //--- set the controlled (1) growth, (2) decrease, (3) reference distance level in pixels by the vertical Y axis between the window frames
    //--- get (4) the distance change in pixels by the vertical Y axis between the window frames,
    //--- get the distance change flag in pixels by the vertical Y axis between the window frames exceeding the (5) growth and (6) decrease values
    //   void              SetControlWindowYDistanceInc(const long value)        { this.SetControlledValueINC(CHART_PROP_WINDOW_YDISTANCE,(long)::fabs(value));   }
    //   void              SetControlWindowYDistanceDec(const long value)        { this.SetControlledValueDEC(CHART_PROP_WINDOW_YDISTANCE,(long)::fabs(value));   }
    //   void              SetControlWindowYDistanceLevel(const long value)      { this.SetControlledValueLEVEL(CHART_PROP_WINDOW_YDISTANCE,(long)::fabs(value)); }
    //   long              GetValueChangedWindowYDistance(void)            const { return this.GetPropLongChangedValue(CHART_PROP_WINDOW_YDISTANCE);              }
    //   bool              IsIncreasedWindowYDistance(void)                const { return (bool)this.GetPropLongFlagINC(CHART_PROP_WINDOW_YDISTANCE);             }
    //   bool              IsDecreasedWindowYDistance(void)                const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_WINDOW_YDISTANCE);             }
    //CHART_PROP_FIRST_VISIBLE_BAR,                      // Number of the first visible bar on the chart
    //--- Width of the chart in bars
    //--- setting the controlled spread (1) increase, (2) decrease value and (3) reference chart width in bars
    //--- getting (4) the chart width change value in bars,
    //--- get the flag of the chart width change in bars exceeding (5) the growth and (6) decrease values
      void              SetControlWidthInBarsInc(const long value)            { this.SetControlledValueINC(CHART_PROP_WIDTH_IN_BARS,(long)::fabs(value));      }
      void              SetControlWidthInBarsDec(const long value)            { this.SetControlledValueDEC(CHART_PROP_WIDTH_IN_BARS,(long)::fabs(value));      }
      void              SetControlWidthInBarsLevel(const long value)          { this.SetControlledValueLEVEL(CHART_PROP_WIDTH_IN_BARS,(long)::fabs(value));    }
      long              GetValueChangedWidthInBars(void)                const { return this.GetPropLongChangedValue(CHART_PROP_WIDTH_IN_BARS);                 }
      bool              IsIncreasedWidthInBars(void)                    const { return (bool)this.GetPropLongFlagINC(CHART_PROP_WIDTH_IN_BARS);                }
      bool              IsDecreasedWidthInBars(void)                    const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_WIDTH_IN_BARS);                }
      
    //--- Chart width in pixels
    //--- setting the controlled spread (1) increase, (2) decrease value and (3) reference chart width in pixels
    //--- getting (4) the chart width change value in pixels,
    //--- get the flag of the chart width change in pixels exceeding (5) the growth and (6) decrease values
      void              SetControlWidthInPixelsInc(const long value)          { this.SetControlledValueINC(CHART_PROP_WIDTH_IN_PIXELS,(long)::fabs(value));    }
      void              SetControlWidthInPixelsDec(const long value)          { this.SetControlledValueDEC(CHART_PROP_WIDTH_IN_PIXELS,(long)::fabs(value));    }
      void              SetControlWidthInPixelsLevel(const long value)        { this.SetControlledValueLEVEL(CHART_PROP_WIDTH_IN_PIXELS,(long)::fabs(value));  }
      long              GetValueChangedWidthInPixels(void)              const { return this.GetPropLongChangedValue(CHART_PROP_WIDTH_IN_PIXELS);               }
      bool              IsIncreasedWidthInPixels(void)                  const { return (bool)this.GetPropLongFlagINC(CHART_PROP_WIDTH_IN_PIXELS);              }
      bool              IsDecreasedWidthInPixels(void)                  const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_WIDTH_IN_PIXELS);              }
      
    //--- Chart height in pixels
    //--- setting the controlled spread (1) increase, (2) decrease value and (3) reference chart height in pixels
    //--- get (4) the chart height change in pixels,
    //--- get the flag of the chart height change in pixels exceeding (5) the growth and (6) decrease values
      void              SetControlHeightInPixelsInc(const long value)         { this.SetControlledValueINC(CHART_PROP_HEIGHT_IN_PIXELS,(long)::fabs(value));   }
      void              SetControlHeightInPixelsDec(const long value)         { this.SetControlledValueDEC(CHART_PROP_HEIGHT_IN_PIXELS,(long)::fabs(value));   }
      void              SetControlHeightInPixelsLevel(const long value)       { this.SetControlledValueLEVEL(CHART_PROP_HEIGHT_IN_PIXELS,(long)::fabs(value)); }
      long              GetValueChangedHeightInPixels(void)             const { return this.GetPropLongChangedValue(CHART_PROP_HEIGHT_IN_PIXELS);              }
      bool              IsIncreasedHeightInPixels(void)                 const { return (bool)this.GetPropLongFlagINC(CHART_PROP_HEIGHT_IN_PIXELS);             }
      bool              IsDecreasedHeightInPixels(void)                 const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_HEIGHT_IN_PIXELS);             }
      
    //CHART_PROP_COLOR_BACKGROUND,                       // Chart background color
    //CHART_PROP_COLOR_FOREGROUND,                       // Color of axes, scale and OHLC line
    //CHART_PROP_COLOR_GRID,                             // Grid color
    //CHART_PROP_COLOR_VOLUME,                           // Color of volumes and position opening levels
    //CHART_PROP_COLOR_CHART_UP,                         // Color for the up bar, shadows and body borders of bull candlesticks
    //CHART_PROP_COLOR_CHART_DOWN,                       // Color of down bar, its shadow and border of body of the bullish candlestick
    //CHART_PROP_COLOR_CHART_LINE,                       // Color of the chart line and the Doji candlesticks
    //CHART_PROP_COLOR_CANDLE_BULL,                      // Bullish candlestick body color
    //CHART_PROP_COLOR_CANDLE_BEAR,                      // Bearish candlestick body color
    //CHART_PROP_COLOR_BID,                              // Color of the Bid price line
    //CHART_PROP_COLOR_ASK,                              // Color of the Ask price line
    //CHART_PROP_COLOR_LAST,                             // Color of the last performed deal's price line (Last)
    //CHART_PROP_COLOR_STOP_LEVEL,                       // Color of stop order levels (Stop Loss and Take Profit)
    //CHART_PROP_SHOW_TRADE_LEVELS,                      // Display trade levels on the chart (levels of open positions, Stop Loss, Take Profit and pending orders)
    //CHART_PROP_DRAG_TRADE_LEVELS,                      // Enable the ability to drag trading levels on a chart using mouse
    //CHART_PROP_SHOW_DATE_SCALE,                        // Display the time scale on a chart
    //CHART_PROP_SHOW_PRICE_SCALE,                       // Display a price scale on a chart
    //CHART_PROP_SHOW_ONE_CLICK,                         // Display the quick trading panel on the chart
    //CHART_PROP_IS_MAXIMIZED,                           // Chart window maximized
    //CHART_PROP_IS_MINIMIZED,                           // Chart window minimized
    //CHART_PROP_IS_DOCKED,                              // Chart window docked

    //--- The left coordinate of the undocked chart window relative to the virtual screen
    //--- setting the controlled spread (1) increase, (2) decrease value and (3) reference level of the left coordinate of the undocked chart relative to the virtual screen
    //--- getting (4) the change value of the left coordinate of the undocked chart relative to the virtual screen,
    //--- getting the flag of changing the left coordinate of the undocked chart relative to the virtual screen exceeding the (5) increase and (6) decrease values
      void              SetControlFloatLeftInc(const long value)              { this.SetControlledValueINC(CHART_PROP_FLOAT_LEFT,(long)::fabs(value));         }
      void              SetControlFloatLeftDec(const long value)              { this.SetControlledValueDEC(CHART_PROP_FLOAT_LEFT,(long)::fabs(value));         }
      void              SetControlFloatLeftLevel(const long value)            { this.SetControlledValueLEVEL(CHART_PROP_FLOAT_LEFT,(long)::fabs(value));       }
      long              GetValueChangedFloatLeft(void)                  const { return this.GetPropLongChangedValue(CHART_PROP_FLOAT_LEFT);                    }
      bool              IsIncreasedFloatLeft(void)                      const { return (bool)this.GetPropLongFlagINC(CHART_PROP_FLOAT_LEFT);                   }
      bool              IsDecreasedFloatLeft(void)                      const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_FLOAT_LEFT);                   }
      
    //--- Upper coordinate of the undocked chart window relative to the virtual screen
    //--- setting the controlled spread (1) increase, (2) decrease value and (3) reference level of the upper coordinate of the undocked chart relative to the virtual screen
    //--- getting (4) the change value of the upper coordinate of the undocked chart relative to the virtual screen,
    //--- getting the flag of changing the upper coordinate of the undocked chart relative to the virtual screen exceeding the (5) increase and (6) decrease values
      void              SetControlFloatTopInc(const long value)               { this.SetControlledValueINC(CHART_PROP_FLOAT_TOP,(long)::fabs(value));          }
      void              SetControlFloatTopDec(const long value)               { this.SetControlledValueDEC(CHART_PROP_FLOAT_TOP,(long)::fabs(value));          }
      void              SetControlFloatTopLevel(const long value)             { this.SetControlledValueLEVEL(CHART_PROP_FLOAT_TOP,(long)::fabs(value));        }
      long              GetValueChangedFloatTop(void)                   const { return this.GetPropLongChangedValue(CHART_PROP_FLOAT_TOP);                     }
      bool              IsIncreasedFloatTop(void)                       const { return (bool)this.GetPropLongFlagINC(CHART_PROP_FLOAT_TOP);                    }
      bool              IsDecreasedFloatTop(void)                       const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_FLOAT_TOP);                    }
      
    //--- The right coordinate of the undocked chart window relative to the virtual screen
    //--- setting the controlled spread (1) increase, (2) decrease value and (3) reference level of the right coordinate of the undocked chart relative to the virtual screen
    //--- getting (4) the change value of the right coordinate of the undocked chart relative to the virtual screen,
    //--- getting the flag of changing the right coordinate of the undocked chart relative to the virtual screen exceeding the (5) increase and (6) decrease values
      void              SetControlFloatRightInc(const long value)             { this.SetControlledValueINC(CHART_PROP_FLOAT_RIGHT,(long)::fabs(value));        }
      void              SetControlFloatRightDec(const long value)             { this.SetControlledValueDEC(CHART_PROP_FLOAT_RIGHT,(long)::fabs(value));        }
      void              SetControlFloatRightLevel(const long value)           { this.SetControlledValueLEVEL(CHART_PROP_FLOAT_RIGHT,(long)::fabs(value));      }
      long              GetValueChangedFloatRight(void)                 const { return this.GetPropLongChangedValue(CHART_PROP_FLOAT_RIGHT);                   }
      bool              IsIncreasedFloatRight(void)                     const { return (bool)this.GetPropLongFlagINC(CHART_PROP_FLOAT_RIGHT);                  }
      bool              IsDecreasedFloatRight(void)                     const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_FLOAT_RIGHT);                  }
      
    //--- The bottom coordinate of the undocked chart window relative to the virtual screen
    //--- setting the controlled spread (1) increase, (2) decrease value and (3) reference level of the lower coordinate of the undocked chart relative to the virtual screen
    //--- getting (4) the change value of the lower coordinate of the undocked chart relative to the virtual screen,
    //--- getting the flag of changing the lower coordinate of the undocked chart relative to the virtual screen exceeding the (5) increase and (6) decrease values
      void              SetControlFloatBottomInc(const long value)            { this.SetControlledValueINC(CHART_PROP_FLOAT_BOTTOM,(long)::fabs(value));       }
      void              SetControlFloatBottomDec(const long value)            { this.SetControlledValueDEC(CHART_PROP_FLOAT_BOTTOM,(long)::fabs(value));       }
      void              SetControlFloatBottomLevel(const long value)          { this.SetControlledValueLEVEL(CHART_PROP_FLOAT_BOTTOM,(long)::fabs(value));     }
      long              GetValueChangedFloatBottom(void)                const { return this.GetPropLongChangedValue(CHART_PROP_FLOAT_BOTTOM);                  }
      bool              IsIncreasedFloatBottom(void)                    const { return (bool)this.GetPropLongFlagINC(CHART_PROP_FLOAT_BOTTOM);                 }
      bool              IsDecreasedFloatBottom(void)                    const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_FLOAT_BOTTOM);                 }
      
    //--- Shift size of the zero bar from the right border in %
    //--- setting (1) increase, (2) decrease and (3) reference level of the shift size of the zero bar from the right border in %
    //--- getting (4) the change value of the shift of the zero bar from the right border in %,
    //--- getting the flag of the change value of the shift of the zero bar from the right border in % exceeding (5) the growth and (6) decrease values
      void              SetControlShiftSizeInc(const long value)              { this.SetControlledValueINC(CHART_PROP_SHIFT_SIZE,(long)::fabs(value));         }
      void              SetControlShiftSizeDec(const long value)              { this.SetControlledValueDEC(CHART_PROP_SHIFT_SIZE,(long)::fabs(value));         }
      void              SetControlShiftSizeLevel(const long value)            { this.SetControlledValueLEVEL(CHART_PROP_SHIFT_SIZE,(long)::fabs(value));       }
      double            GetValueChangedShiftSize(void)                  const { return this.GetPropDoubleChangedValue(CHART_PROP_SHIFT_SIZE);                  }
      bool              IsIncreasedShiftSize(void)                      const { return (bool)this.GetPropLongFlagINC(CHART_PROP_SHIFT_SIZE);                   }
      bool              IsDecreasedShiftSize(void)                      const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_SHIFT_SIZE);                   }
      
    //--- Chart fixed position from the left border in %
    //--- setting (1) increase, (2) decrease and (3) reference level of the chart fixed position from the left border in %
    //--- getting (4) the change value of the chart fixed position from the left border in %,
    //--- getting the flag of changing the chart fixed position from the left border in % more than by the (5) increase and (6) decrease values
      void              SetControlFixedPositionInc(const long value)          { this.SetControlledValueINC(CHART_PROP_FIXED_POSITION,(long)::fabs(value));     }
      void              SetControlFixedPositionDec(const long value)          { this.SetControlledValueDEC(CHART_PROP_FIXED_POSITION,(long)::fabs(value));     }
      void              SetControlFixedPositionLevel(const long value)        { this.SetControlledValueLEVEL(CHART_PROP_FIXED_POSITION,(long)::fabs(value));   }
      double            GetValueChangedFixedPosition(void)              const { return this.GetPropDoubleChangedValue(CHART_PROP_FIXED_POSITION);              }
      bool              IsIncreasedFixedPosition(void)                  const { return (bool)this.GetPropLongFlagINC(CHART_PROP_FIXED_POSITION);               }
      bool              IsDecreasedFixedPosition(void)                  const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_FIXED_POSITION);               }
      
    //--- Fixed chart maximum
    //--- setting the fixed chart maximum (1) increase, (2) decrease controlled value and (3) reference level
    //--- getting (4) the change value of the fixed chart maximum,
    //--- getting the flag of changing the position of the fixed chart maximum by more than (5) increase and (6) decrease values
      void              SetControlFixedMaxInc(const long value)               { this.SetControlledValueINC(CHART_PROP_FIXED_MAX,(long)::fabs(value));          }
      void              SetControlFixedMaxDec(const long value)               { this.SetControlledValueDEC(CHART_PROP_FIXED_MAX,(long)::fabs(value));          }
      void              SetControlFixedMaxLevel(const long value)             { this.SetControlledValueLEVEL(CHART_PROP_FIXED_MAX,(long)::fabs(value));        }
      double            GetValueChangedFixedMax(void)                   const { return this.GetPropDoubleChangedValue(CHART_PROP_FIXED_MAX);                   }
      bool              IsIncreasedFixedMax(void)                       const { return (bool)this.GetPropLongFlagINC(CHART_PROP_FIXED_MAX);                    }
      bool              IsDecreasedFixedMax(void)                       const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_FIXED_MAX);                    }
      
    //--- Fixed chart minimum
    //--- setting the fixed chart minimum (1) increase, (2) decrease controlled value and (3) reference level
    //--- getting (4) the change value of the fixed chart minimum,
    //--- getting the flag of changing the position of the fixed chart minimum by more than (5) increase and (6) decrease values
      void              SetControlFixedMinInc(const long value)               { this.SetControlledValueINC(CHART_PROP_FIXED_MIN,(long)::fabs(value));          }
      void              SetControlFixedMinDec(const long value)               { this.SetControlledValueDEC(CHART_PROP_FIXED_MIN,(long)::fabs(value));          }
      void              SetControlFixedMinLevel(const long value)             { this.SetControlledValueLEVEL(CHART_PROP_FIXED_MIN,(long)::fabs(value));        }
      double            GetValueChangedFixedMin(void)                   const { return this.GetPropDoubleChangedValue(CHART_PROP_FIXED_MIN);                   }
      bool              IsIncreasedFixedMin(void)                       const { return (bool)this.GetPropLongFlagINC(CHART_PROP_FIXED_MIN);                    }
      bool              IsDecreasedFixedMin(void)                       const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_FIXED_MIN);                    }
      
    //CHART_PROP_POINTS_PER_BAR,                         // Scale in points per bar

    //--- Chart minimum
    //--- setting the chart minimum (1) increase, (2) decrease controlled value and (3) reference level
    //--- getting (4) the change value of the chart minimum,
    //--- getting the flag of changing the position of the chart minimum by more than (5) increase and (6) decrease values
      void              SetControlPriceMinInc(const long value)               { this.SetControlledValueINC(CHART_PROP_PRICE_MIN,(long)::fabs(value));          }
      void              SetControlPriceMinDec(const long value)               { this.SetControlledValueDEC(CHART_PROP_PRICE_MIN,(long)::fabs(value));          }
      void              SetControlPriceMinLevel(const long value)             { this.SetControlledValueLEVEL(CHART_PROP_PRICE_MIN,(long)::fabs(value));        }
      double            GetValueChangedPriceMin(void)                   const { return this.GetPropDoubleChangedValue(CHART_PROP_PRICE_MIN);                   }
      bool              IsIncreasedPriceMin(void)                       const { return (bool)this.GetPropLongFlagINC(CHART_PROP_PRICE_MIN);                    }
      bool              IsDecreasedPriceMin(void)                       const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_PRICE_MIN);                    }
      
    //--- Chart maximum
    //--- setting the chart maximum (1) increase, (2) decrease controlled value and (3) reference level
    //--- getting (4) the change value of the chart maximum,
    //--- getting the flag of changing the position of the chart maximum by more than (5) increase and (6) decrease values
      void              SetControlPriceMaxInc(const long value)               { this.SetControlledValueINC(CHART_PROP_PRICE_MAX,(long)::fabs(value));          }
      void              SetControlPriceMaxDec(const long value)               { this.SetControlledValueDEC(CHART_PROP_PRICE_MAX,(long)::fabs(value));          }
      void              SetControlPriceMaxLevel(const long value)             { this.SetControlledValueLEVEL(CHART_PROP_PRICE_MAX,(long)::fabs(value));        }
      double            GetValueChangedPriceMax(void)                   const { return this.GetPropDoubleChangedValue(CHART_PROP_PRICE_MAX);                   }
      bool              IsIncreasedPriceMax(void)                       const { return (bool)this.GetPropLongFlagINC(CHART_PROP_PRICE_MAX);                    }
      bool              IsDecreasedPriceMax(void)                       const { return (bool)this.GetPropLongFlagDEC(CHART_PROP_PRICE_MAX);                    }
      
  };
#endif // CCHARTOBJ_MQH_DECLARATION
#ifndef CCHARTOBJ_MQH_IMPLEMENTATION
#define CCHARTOBJ_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Parametric constructor                                           |
 //+------------------------------------------------------------------+
 CChartObj::CChartObj(const long chart_id) : m_wnd_time_x(0),m_wnd_price_y(0)
  {
      this.m_type=OBJECT_DE_TYPE_CHART;
   //--- Set the chart ID and the chart object type
      this.SetChartID(chart_id);
      this.m_type=COLLECTION_CHARTS_ID;
      
   //--- Initialize base object data arrays
      this.SetControlDataArraySizeLong(CHART_PROP_INTEGER_TOTAL);
      this.SetControlDataArraySizeDouble(CHART_PROP_DOUBLE_TOTAL);
      this.ResetChangesParams();
      this.ResetControlsParams();   
   //--- Chart ID
      this.SetProperty(CHART_PROP_ID,chart_id);
   //--- Set integer properties
      this.SetIntegerParameters();
   //--- Set real properties
      this.SetDoubleParameters();
   //--- Set string properties
      this.SetStringParameters();
   //--- Initialize variables and lists
      this.m_digits=(int)::SymbolInfoInteger(this.Symbol(),SYMBOL_DIGITS);
      this.IndicatorsRefresh();   // the indicators already on the chart come as added ones
      this.m_symbol_prev=this.Symbol();
      this.m_timeframe_prev=this.Timeframe();
      this.m_name=this.Header();
      this.m_list_top_element.FreeMode(false);
      this.m_objects_total_prev=0;
      
      //--- Fill in the current chart data
      for(int i=0;i<CHART_PROP_INTEGER_TOTAL;i++)
         this.m_long_prop_event[i][3]=this.m_long_prop[i];
      for(int i=0;i<CHART_PROP_DOUBLE_TOTAL;i++)
         this.m_double_prop_event[i][3]=this.m_double_prop[i];
      
      //--- Update the base object data and search for changes
      CBaseObjExt::Refresh();
  }
 //+------------------------------------------------------------------+
 //| Fill in integer object properties                                |
 //+------------------------------------------------------------------+
 bool CChartObj::SetIntegerParameters(void)
  {
   ENUM_TIMEFRAMES timeframe=::ChartPeriod(this.ID());
   if(timeframe==0)
      return false;
   this.SetProperty(CHART_PROP_TIMEFRAME,timeframe);                                                     // Chart timeframe
   this.SetProperty(CHART_PROP_SHOW,::ChartGetInteger(this.ID(),CHART_SHOW));                            // Price chart drawing attribute
   this.SetProperty(CHART_PROP_IS_OBJECT,::ChartGetInteger(this.ID(),CHART_IS_OBJECT));                  // Chart object identification attribute
   this.SetProperty(CHART_PROP_BRING_TO_TOP,::ChartGetInteger(this.ID(),CHART_BRING_TO_TOP));            // Show chart above all others
   this.SetProperty(CHART_PROP_CONTEXT_MENU,::ChartGetInteger(this.ID(),CHART_CONTEXT_MENU));            // Access to the context menu using the right click
   this.SetProperty(CHART_PROP_CROSSHAIR_TOOL,::ChartGetInteger(this.ID(),CHART_CROSSHAIR_TOOL));        // Access the Crosshair tool by pressing the middle mouse button
   this.SetProperty(CHART_PROP_MOUSE_SCROLL,::ChartGetInteger(this.ID(),CHART_MOUSE_SCROLL));            // Scroll the chart horizontally using the left mouse button
   this.SetProperty(CHART_PROP_EVENT_MOUSE_WHEEL,::ChartGetInteger(this.ID(),CHART_EVENT_MOUSE_WHEEL));  // Send messages about mouse wheel events to all MQL5 programs on a chart
   this.SetProperty(CHART_PROP_EVENT_MOUSE_MOVE,::ChartGetInteger(this.ID(),CHART_EVENT_MOUSE_MOVE));    // Send messages about mouse button click and movement events to all MQL5 programs on a chart
   this.SetProperty(CHART_PROP_EVENT_OBJECT_CREATE,::ChartGetInteger(this.ID(),CHART_EVENT_OBJECT_CREATE)); // Send messages about the graphical object creation event to all MQL5 programs on a chart
   this.SetProperty(CHART_PROP_EVENT_OBJECT_DELETE,::ChartGetInteger(this.ID(),CHART_EVENT_OBJECT_DELETE)); // Send messages about the graphical object destruction event to all MQL5 programs on a chart
   this.SetProperty(CHART_PROP_MODE,::ChartGetInteger(this.ID(),CHART_MODE));                            // Type of the chart (candlesticks, bars or line)
   this.SetProperty(CHART_PROP_FOREGROUND,::ChartGetInteger(this.ID(),CHART_FOREGROUND));                // Price chart in the foreground
   this.SetProperty(CHART_PROP_SHIFT,::ChartGetInteger(this.ID(),CHART_SHIFT));                          // Mode of shift of the price chart from the right border
   this.SetProperty(CHART_PROP_AUTOSCROLL,::ChartGetInteger(this.ID(),CHART_AUTOSCROLL));                // The mode of automatic shift to the right border of the chart
   this.SetProperty(CHART_PROP_KEYBOARD_CONTROL,::ChartGetInteger(this.ID(),CHART_KEYBOARD_CONTROL));    // Allow managing the chart using a keyboard
   this.SetProperty(CHART_PROP_QUICK_NAVIGATION,::ChartGetInteger(this.ID(),CHART_QUICK_NAVIGATION));    // Allow the chart to intercept Space and Enter key strokes to activate the quick navigation bar
   this.SetProperty(CHART_PROP_SCALE,::ChartGetInteger(this.ID(),CHART_SCALE));                          // Scale
   this.SetProperty(CHART_PROP_SCALEFIX,::ChartGetInteger(this.ID(),CHART_SCALEFIX));                    // Fixed scale mode
   this.SetProperty(CHART_PROP_SCALEFIX_11,::ChartGetInteger(this.ID(),CHART_SCALEFIX_11));              // 1:1 scale mode
   this.SetProperty(CHART_PROP_SCALE_PT_PER_BAR,::ChartGetInteger(this.ID(),CHART_SCALE_PT_PER_BAR));    // Mode for specifying the scale in points per bar
   this.SetProperty(CHART_PROP_SHOW_TICKER,::ChartGetInteger(this.ID(),CHART_SHOW_TICKER));              // Display a symbol ticker in the upper left corner
   this.SetProperty(CHART_PROP_SHOW_OHLC,::ChartGetInteger(this.ID(),CHART_SHOW_OHLC));                  // Display OHLC values in the upper left corner
   this.SetProperty(CHART_PROP_SHOW_BID_LINE,::ChartGetInteger(this.ID(),CHART_SHOW_BID_LINE));          // Display Bid value as a horizontal line on the chart
   this.SetProperty(CHART_PROP_SHOW_ASK_LINE,::ChartGetInteger(this.ID(),CHART_SHOW_ASK_LINE));          // Display Ask value as a horizontal line on the chart
   this.SetProperty(CHART_PROP_SHOW_LAST_LINE,::ChartGetInteger(this.ID(),CHART_SHOW_LAST_LINE));        // Display Last value as a horizontal line on the chart
   this.SetProperty(CHART_PROP_SHOW_PERIOD_SEP,::ChartGetInteger(this.ID(),CHART_SHOW_PERIOD_SEP));      // Display vertical separators between adjacent periods
   this.SetProperty(CHART_PROP_SHOW_GRID,::ChartGetInteger(this.ID(),CHART_SHOW_GRID));                  // Display the chart grid
   this.SetProperty(CHART_PROP_SHOW_VOLUMES,::ChartGetInteger(this.ID(),CHART_SHOW_VOLUMES));            // Display the chart volumes
   this.SetProperty(CHART_PROP_SHOW_OBJECT_DESCR,::ChartGetInteger(this.ID(),CHART_SHOW_OBJECT_DESCR));  // Display text descriptions of the objects
   this.SetProperty(CHART_PROP_VISIBLE_BARS,::ChartGetInteger(this.ID(),CHART_VISIBLE_BARS));            // Number of bars on a chart that are available for display
   this.SetProperty(CHART_PROP_WINDOWS_TOTAL,::ChartGetInteger(this.ID(),CHART_WINDOWS_TOTAL));          // The total number of chart windows including indicator subwindows
   this.SetProperty(CHART_PROP_WINDOW_HANDLE,::ChartGetInteger(this.ID(),CHART_WINDOW_HANDLE));          // Chart window handle
   this.SetProperty(CHART_PROP_FIRST_VISIBLE_BAR,::ChartGetInteger(this.ID(),CHART_FIRST_VISIBLE_BAR));  // Number of the first visible bar on the chart
   this.SetProperty(CHART_PROP_WIDTH_IN_BARS,::ChartGetInteger(this.ID(),CHART_WIDTH_IN_BARS));          // Chart width in bars
   this.SetProperty(CHART_PROP_WIDTH_IN_PIXELS,::ChartGetInteger(this.ID(),CHART_WIDTH_IN_PIXELS));      // Chart width in pixels
   this.SetProperty(CHART_PROP_COLOR_BACKGROUND,::ChartGetInteger(this.ID(),CHART_COLOR_BACKGROUND));    // Chart background color
   this.SetProperty(CHART_PROP_COLOR_FOREGROUND,::ChartGetInteger(this.ID(),CHART_COLOR_FOREGROUND));    // Color of axes, scale and OHLC line
   this.SetProperty(CHART_PROP_COLOR_GRID,::ChartGetInteger(this.ID(),CHART_COLOR_GRID));                // Grid color
   this.SetProperty(CHART_PROP_COLOR_VOLUME,::ChartGetInteger(this.ID(),CHART_COLOR_VOLUME));            // Color of volumes and position opening levels
   this.SetProperty(CHART_PROP_COLOR_CHART_UP,::ChartGetInteger(this.ID(),CHART_COLOR_CHART_UP));        // Color for the up bar, shadows and body borders of bullish candlesticks
   this.SetProperty(CHART_PROP_COLOR_CHART_DOWN,::ChartGetInteger(this.ID(),CHART_COLOR_CHART_DOWN));    // Color for the down bar, shadows and body borders of bearish candlesticks
   this.SetProperty(CHART_PROP_COLOR_CHART_LINE,::ChartGetInteger(this.ID(),CHART_COLOR_CHART_LINE));    // Color of the chart line and the Doji candlesticks
   this.SetProperty(CHART_PROP_COLOR_CANDLE_BULL,::ChartGetInteger(this.ID(),CHART_COLOR_CANDLE_BULL));  // Color of the bullish candle body
   this.SetProperty(CHART_PROP_COLOR_CANDLE_BEAR,::ChartGetInteger(this.ID(),CHART_COLOR_CANDLE_BEAR));  // Color of the bearish candle body
   this.SetProperty(CHART_PROP_COLOR_BID,::ChartGetInteger(this.ID(),CHART_COLOR_BID));                  // Bid price line color
   this.SetProperty(CHART_PROP_COLOR_ASK,::ChartGetInteger(this.ID(),CHART_COLOR_ASK));                  // Ask price line color
   this.SetProperty(CHART_PROP_COLOR_LAST,::ChartGetInteger(this.ID(),CHART_COLOR_LAST));                // Color of the last performed deal's price line (Last)
   this.SetProperty(CHART_PROP_COLOR_STOP_LEVEL,::ChartGetInteger(this.ID(),CHART_COLOR_STOP_LEVEL));    // Color of stop order levels (Stop Loss and Take Profit)
   this.SetProperty(CHART_PROP_SHOW_TRADE_LEVELS,::ChartGetInteger(this.ID(),CHART_SHOW_TRADE_LEVELS));  // Display trade levels on the chart (levels of open positions, Stop Loss, Take Profit and pending orders)
   this.SetProperty(CHART_PROP_DRAG_TRADE_LEVELS,::ChartGetInteger(this.ID(),CHART_DRAG_TRADE_LEVELS));  // Enable the ability to drag trading levels on a chart using mouse
   this.SetProperty(CHART_PROP_SHOW_DATE_SCALE,::ChartGetInteger(this.ID(),CHART_SHOW_DATE_SCALE));      // Display the time scale on the chart
   this.SetProperty(CHART_PROP_SHOW_PRICE_SCALE,::ChartGetInteger(this.ID(),CHART_SHOW_PRICE_SCALE));    // Display the price scale on the chart
   this.SetProperty(CHART_PROP_SHOW_ONE_CLICK,::ChartGetInteger(this.ID(),CHART_SHOW_ONE_CLICK));        // Display the quick trading panel on the chart
   this.SetProperty(CHART_PROP_IS_MAXIMIZED,::ChartGetInteger(this.ID(),CHART_IS_MAXIMIZED));            // Chart window maximized
   this.SetProperty(CHART_PROP_IS_MINIMIZED,::ChartGetInteger(this.ID(),CHART_IS_MINIMIZED));            // Chart window minimized
   this.SetProperty(CHART_PROP_IS_DOCKED,::ChartGetInteger(this.ID(),CHART_IS_DOCKED));                  // Chart window docked
   this.SetProperty(CHART_PROP_FLOAT_LEFT,::ChartGetInteger(this.ID(),CHART_FLOAT_LEFT));                // Left coordinate of the undocked chart window relative to the virtual screen
   this.SetProperty(CHART_PROP_FLOAT_TOP,::ChartGetInteger(this.ID(),CHART_FLOAT_TOP));                  // Top coordinate of the undocked chart window relative to the virtual screen
   this.SetProperty(CHART_PROP_FLOAT_RIGHT,::ChartGetInteger(this.ID(),CHART_FLOAT_RIGHT));              // Right coordinate of the undocked chart window relative to the virtual screen
   this.SetProperty(CHART_PROP_FLOAT_BOTTOM,::ChartGetInteger(this.ID(),CHART_FLOAT_BOTTOM));            // Bottom coordinate of the undocked chart window relative to the virtual screen
   this.SetProperty(CHART_PROP_YDISTANCE,::ChartGetInteger(this.ID(),CHART_WINDOW_YDISTANCE,0));         // Distance in Y axis pixels between the upper frame of the indicator subwindow and the upper frame of the chart main window
   this.SetProperty(CHART_PROP_HEIGHT_IN_PIXELS,::ChartGetInteger(this.ID(),CHART_HEIGHT_IN_PIXELS,0));  // Chart height in pixels
   return true;
  }
 //+------------------------------------------------------------------+
 //| Fill in real object properties                                   |
 //+------------------------------------------------------------------+
 void CChartObj::SetDoubleParameters(void)
  {
   this.SetProperty(CHART_PROP_SHIFT_SIZE,::ChartGetDouble(this.ID(),CHART_SHIFT_SIZE));                 // Shift size of the zero bar from the right border in %
   this.SetProperty(CHART_PROP_FIXED_POSITION,::ChartGetDouble(this.ID(),CHART_FIXED_POSITION));         // Chart fixed position from the left border in %
   this.SetProperty(CHART_PROP_FIXED_MAX,::ChartGetDouble(this.ID(),CHART_FIXED_MAX));                   // Fixed chart maximum
   this.SetProperty(CHART_PROP_FIXED_MIN,::ChartGetDouble(this.ID(),CHART_FIXED_MIN));                   // Fixed chart maximum
   this.SetProperty(CHART_PROP_POINTS_PER_BAR,::ChartGetDouble(this.ID(),CHART_POINTS_PER_BAR));         // Scale in points per bar
   this.SetProperty(CHART_PROP_PRICE_MIN,::ChartGetDouble(this.ID(),CHART_PRICE_MIN));                   // Chart minimum
   this.SetProperty(CHART_PROP_PRICE_MAX,::ChartGetDouble(this.ID(),CHART_PRICE_MAX));                   // Chart maximum
  }
 //+------------------------------------------------------------------+
 //| Fill in string object properties                                 |
 //+------------------------------------------------------------------+
 bool CChartObj::SetStringParameters(void)
  {
   string symbol=::ChartSymbol(this.ID());
   if(symbol==NULL)
      return false;
   this.SetProperty(CHART_PROP_SYMBOL,symbol);                                                           // Chart symbol
   this.SetProperty(CHART_PROP_COMMENT,::ChartGetString(this.ID(),CHART_COMMENT));                       // Comment text on the chart
   this.SetProperty(CHART_PROP_EXPERT_NAME,::ChartGetString(this.ID(),CHART_EXPERT_NAME));               // Name of an EA launched on the chart
   this.SetProperty(CHART_PROP_SCRIPT_NAME,::ChartGetString(this.ID(),CHART_SCRIPT_NAME));               // Name of a script launched on the chart
   return true;
  }
 //+------------------------------------------------------------------+
 //| Compare the CChartObj objects by a specified property            |
 //+------------------------------------------------------------------+
 int CChartObj::Compare(const CObject *node,const int mode=0) const
  {
    const CChartObj *obj_compared=node;
   //--- compare integer properties of two objects
    if(mode<CHART_PROP_INTEGER_TOTAL)
      {
        long value_compared=obj_compared.GetProperty((ENUM_CHART_PROP_INTEGER)mode);
        long value_current=this.GetProperty((ENUM_CHART_PROP_INTEGER)mode);
        return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
   //--- compare real properties of two objects
    else if(mode<CHART_PROP_DOUBLE_TOTAL+CHART_PROP_INTEGER_TOTAL)
      {
        double value_compared=obj_compared.GetProperty((ENUM_CHART_PROP_DOUBLE)mode);
        double value_current=this.GetProperty((ENUM_CHART_PROP_DOUBLE)mode);
        return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
   //--- compare string properties of two objects
    else if(mode<CHART_PROP_DOUBLE_TOTAL+CHART_PROP_INTEGER_TOTAL+CHART_PROP_STRING_TOTAL)
      {
        string value_compared=obj_compared.GetProperty((ENUM_CHART_PROP_STRING)mode);
        string value_current=this.GetProperty((ENUM_CHART_PROP_STRING)mode);
        return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
      }
    return 0;
  }
 //+------------------------------------------------------------------+
 //| Compare the CChartObj objects by all properties                  |
 //+------------------------------------------------------------------+
 bool CChartObj::IsEqual(CChartObj *compared_obj) const
  {
   int begin=0, end=CHART_PROP_INTEGER_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_CHART_PROP_INTEGER prop=(ENUM_CHART_PROP_INTEGER)i;
      if(prop==CHART_PROP_ID || prop==CHART_PROP_WINDOW_HANDLE) continue;
      if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false;
     }
   begin=end; end+=CHART_PROP_DOUBLE_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_CHART_PROP_DOUBLE prop=(ENUM_CHART_PROP_DOUBLE)i;
      if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false; 
     }
   begin=end; end+=CHART_PROP_STRING_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_CHART_PROP_STRING prop=(ENUM_CHART_PROP_STRING)i;
      if(this.GetProperty(prop)!=compared_obj.GetProperty(prop)) return false; 
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Return description of object's integer property                  |
 //+------------------------------------------------------------------+
 string CChartObj::GetPropertyDescription(ENUM_CHART_PROP_INTEGER property)
  {
   return
     (
      property==CHART_PROP_ID     ?  CMessage::Text(MSG_CHART_OBJ_ID)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==CHART_PROP_TIMEFRAME      ?  CMessage::Text(MSG_LIB_TEXT_BAR_PERIOD)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+TimeframeDescription((ENUM_TIMEFRAMES)this.GetProperty(property))
         )  :
      property==CHART_PROP_SHOW   ?  CMessage::Text(MSG_CHART_OBJ_SHOW)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_IS_OBJECT      ?  CMessage::Text(MSG_CHART_OBJ_IS_OBJECT)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_BRING_TO_TOP   ?  CMessage::Text(MSG_CHART_OBJ_BRING_TO_TOP)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_CONTEXT_MENU   ?  CMessage::Text(MSG_CHART_OBJ_CONTEXT_MENU)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_CROSSHAIR_TOOL ?  CMessage::Text(MSG_CHART_OBJ_CROSSHAIR_TOOL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_MOUSE_SCROLL   ?  CMessage::Text(MSG_CHART_OBJ_MOUSE_SCROLL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_EVENT_MOUSE_WHEEL ?  CMessage::Text(MSG_CHART_OBJ_EVENT_MOUSE_WHEEL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_EVENT_MOUSE_MOVE  ?  CMessage::Text(MSG_CHART_OBJ_EVENT_MOUSE_MOVE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_EVENT_OBJECT_CREATE  ?  CMessage::Text(MSG_CHART_OBJ_EVENT_OBJECT_CREATE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_EVENT_OBJECT_DELETE  ?  CMessage::Text(MSG_CHART_OBJ_EVENT_OBJECT_DELETE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_MODE           ?  CMessage::Text(MSG_CHART_OBJ_MODE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ChartModeDescription((ENUM_CHART_MODE)this.GetProperty(property))
         )  :
      property==CHART_PROP_FOREGROUND     ?  CMessage::Text(MSG_CHART_OBJ_FOREGROUND)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SHIFT        ?  CMessage::Text(MSG_CHART_OBJ_SHIFT)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_AUTOSCROLL        ?  CMessage::Text(MSG_CHART_OBJ_AUTOSCROLL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_KEYBOARD_CONTROL        ?  CMessage::Text(MSG_CHART_OBJ_KEYBOARD_CONTROL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_QUICK_NAVIGATION        ?  CMessage::Text(MSG_CHART_OBJ_QUICK_NAVIGATION)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SCALE        ?  CMessage::Text(MSG_CHART_OBJ_SCALE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==CHART_PROP_SCALEFIX        ?  CMessage::Text(MSG_CHART_OBJ_SCALEFIX)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SCALEFIX_11        ?  CMessage::Text(MSG_CHART_OBJ_SCALEFIX_11)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SCALE_PT_PER_BAR  ?  CMessage::Text(MSG_CHART_OBJ_SCALE_PT_PER_BAR)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SHOW_TICKER        ?  CMessage::Text(MSG_CHART_OBJ_SHOW_TICKER)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SHOW_OHLC        ?  CMessage::Text(MSG_CHART_OBJ_SHOW_OHLC)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SHOW_BID_LINE  ?  CMessage::Text(MSG_CHART_OBJ_SHOW_BID_LINE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SHOW_ASK_LINE  ?  CMessage::Text(MSG_CHART_OBJ_SHOW_ASK_LINE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SHOW_LAST_LINE ?  CMessage::Text(MSG_CHART_OBJ_SHOW_LAST_LINE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SHOW_PERIOD_SEP   ?  CMessage::Text(MSG_CHART_OBJ_SHOW_PERIOD_SEP)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SHOW_GRID        ?  CMessage::Text(MSG_CHART_OBJ_SHOW_GRID)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SHOW_VOLUMES   ?  CMessage::Text(MSG_CHART_OBJ_SHOW_VOLUMES)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+ChartModeVolumeDescription((ENUM_CHART_VOLUME_MODE)this.GetProperty(property))
         )  :
      property==CHART_PROP_SHOW_OBJECT_DESCR ?  CMessage::Text(MSG_CHART_OBJ_SHOW_OBJECT_DESCR)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_VISIBLE_BARS   ?  CMessage::Text(MSG_CHART_OBJ_VISIBLE_BARS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==CHART_PROP_WINDOWS_TOTAL  ?  CMessage::Text(MSG_CHART_OBJ_WINDOWS_TOTAL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==CHART_PROP_WINDOW_HANDLE  ?  CMessage::Text(MSG_CHART_OBJ_WINDOW_HANDLE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==CHART_PROP_YDISTANCE  ?  CMessage::Text(MSG_CHART_OBJ_WINDOW_YDISTANCE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)::ChartGetInteger(this.m_chart_id,CHART_WINDOW_YDISTANCE,0)
         )  :
      property==CHART_PROP_FIRST_VISIBLE_BAR ?  CMessage::Text(MSG_CHART_OBJ_FIRST_VISIBLE_BAR)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==CHART_PROP_WIDTH_IN_BARS  ?  CMessage::Text(MSG_CHART_OBJ_WIDTH_IN_BARS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==CHART_PROP_WIDTH_IN_PIXELS   ?  CMessage::Text(MSG_CHART_OBJ_WIDTH_IN_PIXELS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==CHART_PROP_HEIGHT_IN_PIXELS   ?  CMessage::Text(MSG_CHART_OBJ_HEIGHT_IN_PIXELS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS,0)
         )  :
      property==CHART_PROP_COLOR_BACKGROUND        ?  CMessage::Text(MSG_CHART_OBJ_COLOR_BACKGROUND)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::ColorToString((color)this.GetProperty(property),true)
         )  :
      property==CHART_PROP_COLOR_FOREGROUND  ?  CMessage::Text(MSG_CHART_OBJ_COLOR_FOREGROUND)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::ColorToString((color)this.GetProperty(property),true)
         )  :
      property==CHART_PROP_COLOR_GRID     ?  CMessage::Text(MSG_CHART_OBJ_COLOR_GRID)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::ColorToString((color)this.GetProperty(property),true)
         )  :
      property==CHART_PROP_COLOR_VOLUME   ?  CMessage::Text(MSG_CHART_OBJ_COLOR_VOLUME)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::ColorToString((color)this.GetProperty(property),true)
         )  :
      property==CHART_PROP_COLOR_CHART_UP ?  CMessage::Text(MSG_CHART_OBJ_COLOR_CHART_UP)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::ColorToString((color)this.GetProperty(property),true)
         )  :
      property==CHART_PROP_COLOR_CHART_DOWN  ?  CMessage::Text(MSG_CHART_OBJ_COLOR_CHART_DOWN)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::ColorToString((color)this.GetProperty(property),true)
         )  :
      property==CHART_PROP_COLOR_CHART_LINE  ?  CMessage::Text(MSG_CHART_OBJ_COLOR_CHART_LINE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::ColorToString((color)this.GetProperty(property),true)
         )  :
      property==CHART_PROP_COLOR_CANDLE_BULL ?  CMessage::Text(MSG_CHART_OBJ_COLOR_CANDLE_BULL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::ColorToString((color)this.GetProperty(property),true)
         )  :
      property==CHART_PROP_COLOR_CANDLE_BEAR ?  CMessage::Text(MSG_CHART_OBJ_COLOR_CANDLE_BEAR)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::ColorToString((color)this.GetProperty(property),true)
         )  :
      property==CHART_PROP_COLOR_BID        ?  CMessage::Text(MSG_CHART_OBJ_COLOR_BID)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::ColorToString((color)this.GetProperty(property),true)
         )  :
      property==CHART_PROP_COLOR_ASK        ?  CMessage::Text(MSG_CHART_OBJ_COLOR_ASK)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::ColorToString((color)this.GetProperty(property),true)
         )  :
      property==CHART_PROP_COLOR_LAST        ?  CMessage::Text(MSG_CHART_OBJ_COLOR_LAST)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::ColorToString((color)this.GetProperty(property),true)
         )  :
      property==CHART_PROP_COLOR_STOP_LEVEL  ?  CMessage::Text(MSG_CHART_OBJ_COLOR_STOP_LEVEL)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::ColorToString((color)this.GetProperty(property),true)
         )  :
      property==CHART_PROP_SHOW_TRADE_LEVELS ?  CMessage::Text(MSG_CHART_OBJ_SHOW_TRADE_LEVELS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_DRAG_TRADE_LEVELS ?  CMessage::Text(MSG_CHART_OBJ_DRAG_TRADE_LEVELS)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SHOW_DATE_SCALE   ?  CMessage::Text(MSG_CHART_OBJ_SHOW_DATE_SCALE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SHOW_PRICE_SCALE  ?  CMessage::Text(MSG_CHART_OBJ_SHOW_PRICE_SCALE)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_SHOW_ONE_CLICK ?  CMessage::Text(MSG_CHART_OBJ_SHOW_ONE_CLICK)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_IS_MAXIMIZED   ?  CMessage::Text(MSG_CHART_OBJ_IS_MAXIMIZED)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_IS_MINIMIZED   ?  CMessage::Text(MSG_CHART_OBJ_IS_MINIMIZED)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_IS_DOCKED      ?  CMessage::Text(MSG_CHART_OBJ_IS_DOCKED)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(this.GetProperty(property) ? CMessage::Text(MSG_LIB_TEXT_YES) : CMessage::Text(MSG_LIB_TEXT_NO))
         )  :
      property==CHART_PROP_FLOAT_LEFT     ?  CMessage::Text(MSG_CHART_OBJ_FLOAT_LEFT)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==CHART_PROP_FLOAT_TOP      ?  CMessage::Text(MSG_CHART_OBJ_FLOAT_TOP)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==CHART_PROP_FLOAT_RIGHT    ?  CMessage::Text(MSG_CHART_OBJ_FLOAT_RIGHT)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      property==CHART_PROP_FLOAT_BOTTOM   ?  CMessage::Text(MSG_CHART_OBJ_FLOAT_BOTTOM)+
         (!this.SupportProperty(property) ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+(string)this.GetProperty(property)
         )  :
      ""
     );
  }
 //+------------------------------------------------------------------+
 //| Return description of object's real property                     |
 //+------------------------------------------------------------------+
 string CChartObj::GetPropertyDescription(ENUM_CHART_PROP_DOUBLE property)
  {
   return
     (
      property==CHART_PROP_SHIFT_SIZE        ?  CMessage::Text(MSG_CHART_OBJ_SHIFT_SIZE)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==CHART_PROP_FIXED_POSITION    ?  CMessage::Text(MSG_CHART_OBJ_FIXED_POSITION)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==CHART_PROP_FIXED_MAX         ?  CMessage::Text(MSG_CHART_OBJ_FIXED_MAX)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),this.m_digits)
         )  :
      property==CHART_PROP_FIXED_MIN         ?  CMessage::Text(MSG_CHART_OBJ_FIXED_MIN)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),this.m_digits)
         )  :
      property==CHART_PROP_POINTS_PER_BAR    ?  CMessage::Text(MSG_CHART_OBJ_POINTS_PER_BAR)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==CHART_PROP_PRICE_MIN         ?  CMessage::Text(MSG_CHART_OBJ_PRICE_MIN)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),this.m_digits)
         )  :
      property==CHART_PROP_PRICE_MAX         ?  CMessage::Text(MSG_CHART_OBJ_PRICE_MAX)+
         (!this.SupportProperty(property)    ?  ": "+CMessage::Text(MSG_LIB_PROP_NOT_SUPPORTED) :
          ": "+::DoubleToString(this.GetProperty(property),this.m_digits)
         )  :
      ""
     );
  }
 //+------------------------------------------------------------------+
 //| Return description of object's string property                   |
 //+------------------------------------------------------------------+
 string CChartObj::GetPropertyDescription(ENUM_CHART_PROP_STRING property)
  {
   return
     (
      property==CHART_PROP_COMMENT     ?  CMessage::Text(MSG_CHART_OBJ_COMMENT)+": \""+this.GetProperty(property)+"\""     :
      property==CHART_PROP_EXPERT_NAME ?  CMessage::Text(MSG_CHART_OBJ_EXPERT_NAME)+": \""+this.GetProperty(property)+"\"" :
      property==CHART_PROP_SCRIPT_NAME ?  CMessage::Text(MSG_CHART_OBJ_SCRIPT_NAME)+": \""+this.GetProperty(property)+"\"" :
      property==CHART_PROP_SYMBOL      ?  CMessage::Text(MSG_LIB_PROP_SYMBOL)+": \""+this.GetProperty(property)+"\""       :
      ""
     );
  }
 //+------------------------------------------------------------------+
 //| Display object properties in the journal                         |
 //+------------------------------------------------------------------+
 void CChartObj::Print(const bool full_prop=false,const bool dash=false)
  {
   ::Print("============= ",CMessage::Text(MSG_LIB_PARAMS_LIST_BEG)," (",this.Header(),") =============");
   int begin=0, end=CHART_PROP_INTEGER_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_CHART_PROP_INTEGER prop=(ENUM_CHART_PROP_INTEGER)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      if(prop==CHART_PROP_HEIGHT_IN_PIXELS)
        {
         continue;
        }
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   begin=end; end+=CHART_PROP_DOUBLE_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_CHART_PROP_DOUBLE prop=(ENUM_CHART_PROP_DOUBLE)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   begin=end; end+=CHART_PROP_STRING_TOTAL;
   for(int i=begin; i<end; i++)
     {
      ENUM_CHART_PROP_STRING prop=(ENUM_CHART_PROP_STRING)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      if(prop==CHART_PROP_INDICATOR_NAME)
        {
         this.PrintWndIndicators();
         continue;
        }
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("============= ",CMessage::Text(MSG_LIB_PARAMS_LIST_END)," (",this.Header(),") =============\n");
  }
 //+------------------------------------------------------------------+
 //| Display a short description of the object in the journal         |
 //+------------------------------------------------------------------+
 void CChartObj::PrintShort(const bool dash=false,const bool symbol=false)
  {
   ::Print
     (
      (dash ? "- " : ""),this.Header()," ID: ",(string)this.ID(),", HWND: ",(string)this.Handle(),
      ", ",CMessage::Text(MSG_CHART_OBJ_CHART_SUBWINDOWS_NUM),": ",(this.WindowsTotal()>1 ? string(this.WindowsTotal()-1) : CMessage::Text(MSG_LIB_TEXT_NO))
     );
  }
 //+------------------------------------------------------------------+
 //| Return the object short name                                     |
 //+------------------------------------------------------------------+
 string CChartObj::Header(void)
  {
   return(CMessage::Text(MSG_CHART_OBJ_CHART_WINDOW)+" "+this.Symbol()+" "+TimeframeDescription(this.Timeframe()));
  }
 //+-------------------------------------------------------------------+
  //| Display data of all indicators of all chart windows in the journal|
  //+-------------------------------------------------------------------+
  void CChartObj::PrintWndIndicators(void)
   {
    for(int i=0;i<this.m_list_ind.Total();i++)
      {
       CWndInd *ind=this.m_list_ind.At(i);
       if(ind!=NULL)
          ind.Print(true);
      }
   }
  //+------------------------------------------------------------------+
  //| Return the indicator by its index in the specified chart window  |
  //+------------------------------------------------------------------+
  CWndInd *CChartObj::GetIndicator(const int win_num,const int ind_index)
   {
    for(int i=0;i<this.m_list_ind.Total();i++)
      {
       CWndInd *ind=this.m_list_ind.At(i);
       if(ind!=NULL && ind.WindowNum()==win_num && ind.Index()==ind_index)
          return ind;
      }
    return NULL;
   }
  //+------------------------------------------------------------------+
 //| Set the flag of drawing the price chart                          |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShowFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the chart flag above all others                              |
 //+------------------------------------------------------------------+
 bool CChartObj::SetBringToTopFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_BRING_TO_TOP,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_BRING_TO_TOP,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of accessing the context menu                       |
 //| upon pressing the right mouse button                             |
 //+------------------------------------------------------------------+
 bool CChartObj::SetContextMenuFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_CONTEXT_MENU,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_CONTEXT_MENU,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of accessing the Crosshair                          |
 //| upon pressing the middle mouse button                            |
 //+------------------------------------------------------------------+
 bool CChartObj::SetCrosshairToolFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_CROSSHAIR_TOOL,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_CROSSHAIR_TOOL,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the chart scroll flag                                        |
 //| horizontally using the left mouse button                         |
 //+------------------------------------------------------------------+
 bool CChartObj::SetMouseScrollFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_MOUSE_SCROLL,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_MOUSE_SCROLL,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of sending chart object creation event messages     |
 //| to all MQL5 programs on the chart                                |
 //+------------------------------------------------------------------+
 bool CChartObj::SetEventMouseWhellFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_EVENT_MOUSE_WHEEL,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_EVENT_MOUSE_WHEEL,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of sending chart object creation event messages     |
 //| to all MQL5 programs on the chart                                |
 //+------------------------------------------------------------------+
 bool CChartObj::SetEventMouseMoveFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_EVENT_MOUSE_MOVE,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_EVENT_MOUSE_MOVE,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of sending chart object creation event messages     |
 //| to all MQL5 programs on the chart                                |
 //+------------------------------------------------------------------+
 bool CChartObj::SetEventObjectCreateFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_EVENT_OBJECT_CREATE,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_EVENT_OBJECT_CREATE,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of sending chart object creation event messages     |
 //| to all MQL5 programs on the chart                                |
 //+------------------------------------------------------------------+
 bool CChartObj::SetEventObjectDeleteFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_EVENT_OBJECT_DELETE,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_EVENT_OBJECT_DELETE,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the price chart flag in the foreground                       |
 //+------------------------------------------------------------------+
 bool CChartObj::SetForegroundFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_FOREGROUND,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_FOREGROUND,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of the price chart shift from the right border      |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShiftFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHIFT,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHIFT,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //|Set the flag for automatically moving to the right chart border   |
 //+------------------------------------------------------------------+
 bool CChartObj::SetAutoscrollFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_AUTOSCROLL,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_AUTOSCROLL,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of managing the chart using a keyboard              |
 //+------------------------------------------------------------------+
 bool CChartObj::SetKeyboardControlFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_KEYBOARD_CONTROL,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_KEYBOARD_CONTROL,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+----------------------------------------------------------------------+
 //| Set the flag of intercepting Space and Enter keystrokes by the chart |
 //| to activate the fast navigation bar                                  |
 //+----------------------------------------------------------------------+
 bool CChartObj::SetQuickNavigationFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_QUICK_NAVIGATION,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_QUICK_NAVIGATION,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the fixed scale flag                                         |
 //+------------------------------------------------------------------+
 bool CChartObj::SetScaleFixFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SCALEFIX,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SCALEFIX,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the 1:1 scale flag                                           |
 //+------------------------------------------------------------------+
 bool CChartObj::SetScaleFix11Flag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SCALEFIX_11,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SCALEFIX_11,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of specifying a scale in points per bar             |
 //+------------------------------------------------------------------+
 bool CChartObj::SetScalePTPerBarFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SCALE_PT_PER_BAR,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SCALE_PT_PER_BAR,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //|Set the flag displaying a symbol ticker in the upper left corner  |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShowTickerFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW_TICKER,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW_TICKER,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //|Set the flag displaying OHLC values in the upper left corner      |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShowOHLCFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW_OHLC,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW_OHLC,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of displaying the Bid value                         |
 //| using a horizontal line on the chart                             |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShowBidLineFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW_BID_LINE,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW_BID_LINE,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of displaying the Ask value                         |
 //| using a horizontal line on the chart                             |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShowAskLineFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW_ASK_LINE,flag))
     {
      CMessage::ToLog(source,::GetLastError(),flag);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW_ASK_LINE,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of displaying the Last value                        |
 //| using a horizontal line on the chart                             |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShowLastLineFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW_LAST_LINE,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW_LAST_LINE,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of displaying vertical separators                   |
 //| between adjacent periods                                         |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShowPeriodSeparatorsFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW_PERIOD_SEP,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW_PERIOD_SEP,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of displaying a grid on the chart                   |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShowGridFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW_GRID,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW_GRID,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of displaying object text descriptions              |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShowObjectDescriptionsFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW_OBJECT_DESCR,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW_OBJECT_DESCR,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of displaying trading levels on the chart           |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShowTradeLevelsFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW_TRADE_LEVELS,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW_TRADE_LEVELS,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag enabling dragging                                   |
 //| trading levels on a chart using a mouse                          |
 //+------------------------------------------------------------------+
 bool CChartObj::SetDragTradeLevelsFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_DRAG_TRADE_LEVELS,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_DRAG_TRADE_LEVELS,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of displaying the time scale on the chart           |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShowDateScaleFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW_DATE_SCALE,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW_DATE_SCALE,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of displaying the price scale on the chart          |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShowPriceScaleFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW_PRICE_SCALE,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW_PRICE_SCALE,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //|Set the flag of displaying the quick trading panel on the chart   |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShowOneClickPanelFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW_ONE_CLICK,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW_ONE_CLICK,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the flag of docking a chart window                           |
 //+------------------------------------------------------------------+
 bool CChartObj::SetDockedFlag(const string source,const bool flag,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_IS_DOCKED,flag))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_IS_DOCKED,flag);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the chart type                                               |
 //+------------------------------------------------------------------+
 bool CChartObj::SetMode(const string source,const ENUM_CHART_MODE mode,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_MODE,mode))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_MODE,mode);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the chart scale                                              |
 //+------------------------------------------------------------------+
 bool CChartObj::SetScale(const string source,const int scale,const bool redraw=false)
  {
   int value=(scale<0 ? 0 : scale>5 ? 5 : scale);
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SCALE,value))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SCALE,value);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the mode of displaying the volumes on a chart                |
 //+------------------------------------------------------------------+
 bool CChartObj::SetModeVolume(const string source,ENUM_CHART_VOLUME_MODE mode,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_SHOW_VOLUMES,mode))
     {
      CMessage::ToLog(source,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHOW_VOLUMES,mode);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //|  Set the property                                                |
 //| "Number of bars on a chart that are available for display"       |
 //+------------------------------------------------------------------+
 void CChartObj::SetVisibleBars(void)
  {
   this.SetProperty(CHART_PROP_VISIBLE_BARS,::ChartGetInteger(this.ID(),CHART_VISIBLE_BARS));
  }
 //+--------------------------------------------------------------------+
 //|  Set the property                                                  |
 //| "The total number of chart windows including indicator subwindows" |
 //+------------------------------------------------------------------+
 void CChartObj::SetWindowsTotal(void)
  {
   this.SetProperty(CHART_PROP_WINDOWS_TOTAL,::ChartGetInteger(this.ID(),CHART_WINDOWS_TOTAL));
  }
 //+---------------------------------------------------------------------+
 //| Set the property "The number of the first visible bar on the chart" |
 //+---------------------------------------------------------------------+
 void CChartObj::SetFirstVisibleBars(void)
  {
   this.SetProperty(CHART_PROP_FIRST_VISIBLE_BAR,::ChartGetInteger(this.ID(),CHART_FIRST_VISIBLE_BAR));
  }
 //+------------------------------------------------------------------+
 //| Set the property "Width of the chart in bars"                    |
 //+------------------------------------------------------------------+
 void CChartObj::SetWidthInBars(void)
  {
   this.SetProperty(CHART_PROP_WIDTH_IN_BARS,::ChartGetInteger(this.ID(),CHART_WIDTH_IN_BARS));
  }
 //+------------------------------------------------------------------+
 //| Set the property "Width of the chart in pixels"                  |
 //+------------------------------------------------------------------+
 void CChartObj::SetWidthInPixels(void)
  {
   this.SetProperty(CHART_PROP_WIDTH_IN_PIXELS,::ChartGetInteger(this.ID(),CHART_WIDTH_IN_PIXELS));
  }
 //+-----------------------------------------------------------------------------------+
 //| Return the distance in pixels by Y axis between                                   |
 //| the upper frame of the indicator subwindow and the upper frame of the main window |
 //+-----------------------------------------------------------------------------------+
  int CChartObj::WindowYDistance(const int sub_window) const
   {
    return (int)::ChartGetInteger(this.m_chart_id,CHART_WINDOW_YDISTANCE,sub_window);
   }
  //+------------------------------------------------------------------+
  //| Return the height of the specified chart in pixels               |
  //+------------------------------------------------------------------+
  int CChartObj::WindowHeightInPixels(const int sub_window) const
   {
    return (int)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS,sub_window);
   }
  //+------------------------------------------------------------------+
  //| Set the height of the specified chart in pixels                  |
  //+------------------------------------------------------------------+
  bool CChartObj::SetWindowHeightInPixels(const int height,const int sub_window,const bool redraw=false)
   {
    ::ResetLastError();
    if(!::ChartSetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS,sub_window,height))
      {
       CMessage::ToLog(DFUN,::GetLastError(),true);
       return false;
      }
    if(redraw)
       ::ChartRedraw(this.m_chart_id);
    return true;
   }
  //+------------------------------------------------------------------+
 //| Set the property "Chart window maximized"                        |
 //+------------------------------------------------------------------+
 void CChartObj::SetMaximizedFlag(void)
  {
   this.SetProperty(CHART_PROP_IS_MAXIMIZED,::ChartGetInteger(this.ID(),CHART_IS_MAXIMIZED));
  }
 //+------------------------------------------------------------------+
 //| Set the property "Chart window minimized"                        |
 //+------------------------------------------------------------------+
 void CChartObj::SetMinimizedFlag(void)
  {
   this.SetProperty(CHART_PROP_IS_MINIMIZED,::ChartGetInteger(this.ID(),CHART_IS_MINIMIZED));
  }
 //+------------------------------------------------------------------+
 //| Set the property "Name of an EA launched on the chart"           |
 //+------------------------------------------------------------------+
 void CChartObj::SetExpertName(void)
  {
   this.SetProperty(CHART_PROP_EXPERT_NAME,::ChartGetString(this.ID(),CHART_EXPERT_NAME));
  }
 //+------------------------------------------------------------------+
 //| Set the property "Name of a script launched on the chart"        |
 //+------------------------------------------------------------------+
 void CChartObj::SetScriptName(void)
  {
   this.SetProperty(CHART_PROP_SCRIPT_NAME,::ChartGetString(this.ID(),CHART_SCRIPT_NAME));
  }
 //+------------------------------------------------------------------+
 //| Set the chart background color                                   |
 //+------------------------------------------------------------------+
 bool CChartObj::SetColorBackground(const color colour,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_COLOR_BACKGROUND,colour))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COLOR_BACKGROUND,colour);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the color of axes, scale and OHLC line                       |
 //+------------------------------------------------------------------+
 bool CChartObj::SetColorForeground(const color colour,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_COLOR_FOREGROUND,colour))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COLOR_FOREGROUND,colour);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the grid color                                               |
 //+------------------------------------------------------------------+
 bool CChartObj::SetColorGrid(const color colour,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_COLOR_GRID,colour))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COLOR_GRID,colour);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the volume color and position opening levels                 |
 //+------------------------------------------------------------------+
 bool CChartObj::SetColorVolume(const color colour,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_COLOR_VOLUME,colour))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COLOR_VOLUME,colour);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+----------------------------------------------------------------------+
 //|Set the color of up bar, its shadow and border of bullish candle body |
 //+----------------------------------------------------------------------+
 bool CChartObj::SetColorUp(const color colour,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_COLOR_CHART_UP,colour))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COLOR_CHART_UP,colour);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+-----------------------------------------------------------------------+
 //|Set the color of down bar, its shadow and border of bearish candle body|
 //+-----------------------------------------------------------------------+
 bool CChartObj::SetColorDown(const color colour,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_COLOR_CHART_DOWN,colour))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COLOR_CHART_DOWN,colour);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the color of the chart line and Doji candles                 |
 //+------------------------------------------------------------------+
 bool CChartObj::SetColorLine(const color colour,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_COLOR_CHART_LINE,colour))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COLOR_CHART_LINE,colour);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the color of bullish candle body                             |
 //+------------------------------------------------------------------+
 bool CChartObj::SetColorCandleBull(const color colour,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_COLOR_CANDLE_BULL,colour))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COLOR_CANDLE_BULL,colour);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the color of bearish candle body                             |
 //+------------------------------------------------------------------+
 bool CChartObj::SetColorCandleBear(const color colour,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_COLOR_CANDLE_BEAR,colour))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COLOR_CANDLE_BEAR,colour);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the Bid price line color                                     |
 //+------------------------------------------------------------------+
 bool CChartObj::SetColorBid(const color colour,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_COLOR_BID,colour))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COLOR_BID,colour);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the Ask price line color                                     |
 //+------------------------------------------------------------------+
 bool CChartObj::SetColorAsk(const color colour,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_COLOR_ASK,colour))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COLOR_ASK,colour);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //|Set the color of the price line of the last performed deal (Last) |
 //+------------------------------------------------------------------+
 bool CChartObj::SetColorLast(const color colour,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_COLOR_LAST,colour))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COLOR_LAST,colour);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //|Set the color of stop order levels (Stop Loss and Take Profit)    |
 //+------------------------------------------------------------------+
 bool CChartObj::SetColorStops(const color colour,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_COLOR_STOP_LEVEL,colour))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COLOR_STOP_LEVEL,colour);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the left coordinate of the undocked chart                    |
 //| relative to the virtual screen                                   |
 //+------------------------------------------------------------------+
 bool CChartObj::SetFloatLeft(const int value,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_FLOAT_LEFT,value))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_FLOAT_LEFT,value);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the top coordinate of the undocked chart                     |
 //| relative to the virtual screen                                   |
 //+------------------------------------------------------------------+
 bool CChartObj::SetFloatTop(const int value,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_FLOAT_TOP,value))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_FLOAT_TOP,value);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the right coordinate of the undocked chart                   |
 //| relative to the virtual screen                                   |
 //+------------------------------------------------------------------+
 bool CChartObj::SetFloatRight(const int value,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_FLOAT_RIGHT,value))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_FLOAT_RIGHT,value);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the bottom coordinate of the undocked chart                  |
 //| relative to the virtual screen                                   |
 //+------------------------------------------------------------------+
 bool CChartObj::SetFloatBottom(const int value,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetInteger(this.ID(),CHART_FLOAT_BOTTOM,value))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_FLOAT_BOTTOM,value);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the value of zeroth bar shift                                |
 //| from the right edge in %                                         |
 //+------------------------------------------------------------------+
 bool CChartObj::SetShiftSize(const double value,const bool redraw=false)
  {
   double size=(value<10.0 ? 10.0 : value>50.0 ? 50.0 : value);
   ::ResetLastError();
   if(!::ChartSetDouble(this.ID(),CHART_SHIFT_SIZE,size))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SHIFT_SIZE,size);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the location of the chart fixed position                     |
 //| from the left edge in %                                          |
 //+------------------------------------------------------------------+
 bool CChartObj::SetFixedPosition(const double value,const bool redraw=false)
  {
   double pos=(value<0 ? 0 : value>100.0 ? 100.0 : value);
   ::ResetLastError();
   if(!::ChartSetDouble(this.ID(),CHART_FIXED_POSITION,pos))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_FIXED_POSITION,pos);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the fixed chart maximum                                      |
 //+------------------------------------------------------------------+
 bool CChartObj::SetFixedMaximum(const double value,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetDouble(this.ID(),CHART_FIXED_MAX,value))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_FIXED_MAX,value);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the fixed chart minimum                                      |
 //+------------------------------------------------------------------+
 bool CChartObj::SetFixedMinimum(const double value,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetDouble(this.ID(),CHART_FIXED_MIN,value))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_FIXED_MIN,value);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the value of the scale in points per bar                     |
 //+------------------------------------------------------------------+
 bool CChartObj::SetPointsPerBar(const double value,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetDouble(this.ID(),CHART_POINTS_PER_BAR,value))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_POINTS_PER_BAR,value);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the comment on the chart                                     |
 //+------------------------------------------------------------------+
 bool CChartObj::SetComment(const string comment,const bool redraw=false)
  {
   ::ResetLastError();
   if(!::ChartSetString(this.ID(),CHART_COMMENT,comment))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_COMMENT,comment);
   if(redraw)
      ::ChartRedraw(this.ID());
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the chart symbol                                             |
 //+------------------------------------------------------------------+
 bool CChartObj::SetSymbol(const string symbol,const ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   ENUM_TIMEFRAMES tf=(timeframe==PERIOD_CURRENT ? this.Timeframe() : timeframe);
   if(symbol==this.Symbol() && tf==this.Timeframe())
      return true;
   ::ResetLastError();
   if(!::ChartSetSymbolPeriod(this.ID(),symbol,tf))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_SYMBOL,symbol);
   this.SetProperty(CHART_PROP_TIMEFRAME,tf);
   this.m_digits=(int)::SymbolInfoInteger(this.Symbol(),SYMBOL_DIGITS);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Set the chart period                                             |
 //+------------------------------------------------------------------+
 bool CChartObj::SetTimeframe(const ENUM_TIMEFRAMES timeframe)
  {
   ::ResetLastError();
   if(!::ChartSetSymbolPeriod(this.ID(),this.Symbol(),timeframe))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetProperty(CHART_PROP_TIMEFRAME,timeframe);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Update the chart object and its indicators                       |
 //+------------------------------------------------------------------+
 void CChartObj::Refresh(void)
  {
   //--- Initialize event data
   this.m_is_event=false;
   this.m_hash_sum=0;
   this.m_list_events.Clear();
   this.m_list_events.Sort();
   //--- A new object appeared on the chart: raise the top elements above it again
   int objects_total=::ObjectsTotal(this.ID());
   if(objects_total!=this.m_objects_total_prev && this.m_list_top_element.Total()>0)
      this.BringTopElementsToTop();
   this.m_objects_total_prev=objects_total;
    //--- Indicators added, removed or changed since the previous check
    this.IndicatorsRefresh();
    
   //--- Check changes of a symbol and chart period
   int change=(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOWS_TOTAL)-this.WindowsTotal();
   if(change==0)
     {
      //--- Get a chart symbol and period by its ID
      string symbol=::ChartSymbol(this.ID());
      ENUM_TIMEFRAMES timeframe=::ChartPeriod(this.ID());
      //--- If a symbol and period are received,
      if(symbol!=NULL && timeframe!=0)
        {
         //--- create the flags specifying the equality/non-equality of the obtained period symbol with the current ones
         bool symb=symbol!=this.m_symbol_prev;
         bool tf=timeframe!=this.m_timeframe_prev;
         //--- If case of any changes, find out their exact nature:
         if(symb || tf)
           {
            //--- If both a symbol and a timeframe changed
            if(symb && tf)
              {
               //--- Send the CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE event to the control program chart
               this.SendEvent(CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE);
               //--- Set a new symbol and a period for the object, and
               this.SetSymbol(symbol);
               this.SetTimeframe(timeframe);
               //--- write the current symbol/period as the previous ones
               this.m_symbol_prev=this.Symbol();
               this.m_timeframe_prev=this.Timeframe();
              }
            //--- If only a chart symbol is changed
            else if(symb)
              {
               //--- Send the CHART_OBJ_EVENT_CHART_SYMB_CHANGE event to the control program chart
               this.SendEvent(CHART_OBJ_EVENT_CHART_SYMB_CHANGE);
               //--- Set a new symbol for the object and write the current symbol as the previous one
               this.SetSymbol(symbol);
               this.m_symbol_prev=this.Symbol();
              }
            //--- If only a chart period is changed
            else if(tf)
              {
               //--- Send the CHART_OBJ_EVENT_CHART_TF_CHANGE event to the control program chart
               this.SendEvent(CHART_OBJ_EVENT_CHART_TF_CHANGE);
               //--- Set a new timeframe for the object and write the current timeframe as the previous one
               this.SetTimeframe(timeframe);
               this.m_timeframe_prev=this.Timeframe();
              }
           }
        }
      //--- Update chart data
      if(this.SetIntegerParameters())
        {
         this.SetDoubleParameters();
         this.SetStringParameters();
        }
      //--- Fill in the current chart data
      for(int i=0;i<CHART_PROP_INTEGER_TOTAL;i++)
         this.m_long_prop_event[i][3]=this.m_long_prop[i];
      for(int i=0;i<CHART_PROP_DOUBLE_TOTAL;i++)
         this.m_double_prop_event[i][3]=this.m_double_prop[i];
      //--- Update the base object data and search for changes
      CBaseObjExt::Refresh();
      this.CheckEvents();
     }
    else
      {
       this.SetWindowsTotal();   // a subwindow came or went: the next checks take the symbol and the period
      }
  }
 //+------------------------------------------------------------------+
  //| Compare the indicators of every chart window with the list: an   |
  //| indicator with the same name, type and parameters is the same one|
  //| (it only follows its window and index); a new indicator in the   |
  //| window and index of a missing one is a change of parameters; the |
  //| rest is added or removed. Every case sends its event             |
  //+------------------------------------------------------------------+
  void CChartObj::IndicatorsRefresh(void)
   {
    CArrayObj current;   // what the chart holds now; the new ones are taken by the list, the others are freed below
    current.FreeMode(false);
    int windows=(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOWS_TOTAL);
    for(int w=0;w<windows;w++)
      {
       int total=::ChartIndicatorsTotal(this.m_chart_id,w);
       for(int i=0;i<total;i++)
         {
          CWndInd *ind=new CWndInd(this.m_chart_id,w,i);
          if(ind!=NULL && !current.Add(ind))
             delete ind;
         }
      }
    int old_total=this.m_list_ind.Total();
    int now_total=current.Total();
    bool listed[],present[],taken[];
    ::ArrayResize(listed,old_total);
    ::ArrayResize(present,now_total);
    ::ArrayResize(taken,now_total);
    ::ArrayInitialize(listed,false);
    ::ArrayInitialize(present,false);
    ::ArrayInitialize(taken,false);
    //--- the same indicator
    for(int j=0;j<now_total;j++)
      {
       CWndInd *now=current.At(j);
       for(int k=0;k<old_total && !present[j];k++)
         {
          CWndInd *old=this.m_list_ind.At(k);
          if(listed[k] || old==NULL || !old.SameIdentity(now))
             continue;
          old.SetWindowNum(now.WindowNum());
          old.SetIndex(now.Index());
          listed[k]=true;
          present[j]=true;
         }
      }
    //--- parameters changed: the chart indicator in the window and the index of a listed one that is gone
    for(int j=0;j<now_total;j++)
      {
       if(present[j])
          continue;
       CWndInd *now=current.At(j);
       for(int k=0;k<old_total && !present[j];k++)
         {
          CWndInd *old=this.m_list_ind.At(k);
          if(listed[k] || old==NULL || old.WindowNum()!=now.WindowNum() || old.Index()!=now.Index())
             continue;
          CWndInd *before=new CWndInd(old);   // the old type and parameters stay in the list of the changed ones
          if(before==NULL || !this.m_list_ind_param.Add(before))
            {
             delete before;
             continue;
            }
          old.Assign(now);
          listed[k]=true;
          present[j]=true;
          this.SendEvent(CHART_OBJ_EVENT_CHART_WND_IND_CHANGE,old);
         }
      }
    //--- added: the list takes the object of the chart
    for(int j=0;j<now_total;j++)
      {
       if(present[j])
          continue;
       CWndInd *now=current.At(j);
       if(!this.m_list_ind.Add(now))
          continue;
       taken[j]=true;
       this.SendEvent(CHART_OBJ_EVENT_CHART_WND_IND_ADD,now);
      }
    //--- removed
    for(int k=old_total-1;k>WRONG_VALUE;k--)
      {
       CWndInd *old=this.m_list_ind.At(k);
       if(listed[k] || old==NULL)
          continue;
       CWndInd *gone=new CWndInd(old);
       if(gone==NULL || !this.m_list_ind_del.Add(gone))
         {
          delete gone;
          continue;
         }
       this.m_list_ind.Delete(k);
       this.SendEvent(CHART_OBJ_EVENT_CHART_WND_IND_DEL,gone);
      }
    for(int j=0;j<now_total;j++)
       if(!taken[j])
          delete current.At(j);
   }
  //+------------------------------------------------------------------+
 //| Move the chart by the specified number of bars                   |
 //| relative to the specified chart position                         |
 //+------------------------------------------------------------------+
 bool CChartObj::Navigate(const int shift,const ENUM_CHART_POSITION position)
  {
   ::ResetLastError();
   bool res=::ChartNavigate(m_chart_id,position,shift);
   if(!res)
      CMessage::ToLog(DFUN,::GetLastError(),true);
   return res;
  }
 //+------------------------------------------------------------------+
 //| Shift the chart to the left by the specified number of bars      |
 //+------------------------------------------------------------------+
 bool CChartObj::NavigateLeft(const int shift)
  {
   this.SetAutoscrollOFF();
   return this.Navigate(shift,CHART_CURRENT_POS);
  }
 //+------------------------------------------------------------------+
 //| Shift the chart to the right by the specified number of bars     |
 //+------------------------------------------------------------------+
 bool CChartObj::NavigateRight(const int shift)
  {
   this.SetAutoscrollOFF();
   return this.Navigate(-shift,CHART_CURRENT_POS);
  }
 //+------------------------------------------------------------------+
 //| Shift the chart to the beginning of the history data             |
 //+------------------------------------------------------------------+
 bool CChartObj::NavigateBegin(void)
  {
   this.SetAutoscrollOFF();
   return this.Navigate(0,CHART_BEGIN);
  }
 //+------------------------------------------------------------------+
 //| Shift the chart to the end of the history data                   |
 //+------------------------------------------------------------------+
 bool CChartObj::NavigateEnd(void)
  {
   this.SetAutoscrollOFF();
   return this.Navigate(0,CHART_END);
  }
 //+------------------------------------------------------------------------------+
 //|Convert X and Y coordinates of the chart window into the time and price values|
 //+------------------------------------------------------------------------------+
 int CChartObj::XYToTimePrice(const long x,const double y)
  {
   int sub_window=WRONG_VALUE;
   ::ResetLastError();
   if(!::ChartXYToTimePrice(this.m_chart_id,(int)x,(int)y,sub_window,this.m_wnd_time_x,this.m_wnd_price_y))
     {
      //CMessage::ToLog(DFUN,::GetLastError(),true);
      return WRONG_VALUE;
     }
   return sub_window;
  }
 //+------------------------------------------------------------------+
 //| Open time of the candle under the chart X and Y coordinates      |
 //+------------------------------------------------------------------+
 datetime CChartObj::GetBarTimeFromXY(const int x,const int y)
  {
   datetime time=0;
   double   price=0;
   int      sub_window=WRONG_VALUE;
   if(!::ChartXYToTimePrice(this.m_chart_id,x,y,sub_window,time,price) || sub_window!=0)
      return 0;
   int shift=::iBarShift(this.Symbol(),this.Timeframe(),time,false);
   if(shift<0)
      return 0;
   return ::iTime(this.Symbol(),this.Timeframe(),shift);
  }
 //+------------------------------------------------------------------+
 //| Create and send a chart event                                    |
 //| to the control program chart                                     |
 //+------------------------------------------------------------------+
  void CChartObj::SendEvent(ENUM_CHART_OBJ_EVENT event,CWndInd *ind=NULL)
   {
    //--- An indicator of a chart window: added, removed or changed
    if(event==CHART_OBJ_EVENT_CHART_WND_IND_ADD || event==CHART_OBJ_EVENT_CHART_WND_IND_DEL || event==CHART_OBJ_EVENT_CHART_WND_IND_CHANGE)
      {
       if(ind==NULL)
          return;
       //--- pass the indicator index in the chart window to lparam,
       //--- pass the chart window index to dparam,
       //--- pass the short name of the indicator to sparam;
       //--- the receiver asks the chart object for the indicator: its type and parameters are what it needs
       ::EventChartCustom(::ChartID(),(ushort)event,ind.Index(),ind.WindowNum(),ind.Name());
      }
    //--- If symbol and timeframe changed
    else if(event==CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE)
     {
      //--- Send the CHART_OBJ_EVENT_CHART_SYMB_TF_CHANGE event to the control program chart
      //--- pass the chart ID to lparam,
      //--- pass the previous timeframe to dparam,
      //--- pass the previous chart symbol to sparam
      ::EventChartCustom(::ChartID(),(ushort)event,this.m_chart_id,this.m_timeframe_prev,this.m_symbol_prev);
     }
   //--- If a symbol changed
   else if(event==CHART_OBJ_EVENT_CHART_SYMB_CHANGE)
     {
      //--- Send the CHART_OBJ_EVENT_CHART_SYMB_CHANGE event to the control program chart
      //--- pass the chart ID to lparam,
      //--- pass the current timeframe to dparam,
      //--- pass the previous chart symbol to sparam
      ::EventChartCustom(::ChartID(),(ushort)event,this.m_chart_id,this.Timeframe(),this.m_symbol_prev);
     }
   //--- If a timeframe changed,
   else if(event==CHART_OBJ_EVENT_CHART_TF_CHANGE)
     {
      //--- Send the CHART_OBJ_EVENT_CHART_TF_CHANGE event to the control program chart
      //--- pass the chart ID to lparam,
      //--- pass the previous timeframe to dparam,
      //--- pass the current chart symbol to sparam
      ::EventChartCustom(::ChartID(),(ushort)event,this.m_chart_id,this.m_timeframe_prev,this.Symbol());
     }
  }
 //+------------------------------------------------------------------+

 //--- Register a view to stay above the other chart objects
 bool CChartObj::AddTopElement(CGElement *element)
  {
   if(::CheckPointer(element)==POINTER_INVALID)
      return false;
   CObject *obj=element;
   for(int i=0;i<this.m_list_top_element.Total();i++)
      if(this.m_list_top_element.At(i)==obj)
         return true;
   return this.m_list_top_element.Add(obj);
  }
 //--- Re-show the top elements in registration order, then redraw
 void CChartObj::BringTopElementsToTop(void)
  {
   for(int i=this.m_list_top_element.Total()-1;i>=0;i--)
      if(::CheckPointer(this.m_list_top_element.At(i))==POINTER_INVALID)
         this.m_list_top_element.Detach(i);
   for(int i=0;i<this.m_list_top_element.Total();i++)
     {
      CGElement *element=dynamic_cast<CGElement *>(this.m_list_top_element.At(i));
      if(element!=NULL)
         element.BringToTop();
     }
   ::ChartRedraw(this.ID());
  }
//+------------------------------------------------------------------+
//| The identity is read from the chart itself (CWndInd), not from   |
//| the list: no event is sent and nothing is stale                  |
//+------------------------------------------------------------------+
bool CChartObj::IsIndicatorShownOnChart(const ENUM_INDICATOR type,MqlParam &params[])
  {
   int windows=(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOWS_TOTAL);
   for(int win=0;win<windows;win++)
     {
      int total=::ChartIndicatorsTotal(this.m_chart_id,win);
      for(int k=0;k<total;k++)
        {
         CWndInd ind(this.m_chart_id,win,k);
         ENUM_INDICATOR line_type;
         MqlParam line_params[];
         if(ind.GetIdentity(line_type,line_params) && line_type==type && IsEqualMqlParamArrays(line_params,params))
            return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Attach the indicator: trend group to the main window, the rest   |
//| to a new subwindow                                               |
//+------------------------------------------------------------------+
void CChartObj::ShowIndicatorOnChart(const ENUM_INDICATOR type,MqlParam &params[])
  {
   int handle=::IndicatorCreate(this.Symbol(),this.Timeframe(),type,::ArraySize(params),params);
   if(handle==INVALID_HANDLE)
      return;
   int sub_window=(GetIndicatorGroupForType(type)==INDICATOR_GROUP_TREND ? 0 : (int)::ChartGetInteger(this.m_chart_id,CHART_WINDOWS_TOTAL));
   ::ChartIndicatorAdd(this.m_chart_id,sub_window,handle);
  }
//+------------------------------------------------------------------+
//| Detach the first indicator with this type and parameters         |
//+------------------------------------------------------------------+
void CChartObj::RemoveIndicatorFromChart(const ENUM_INDICATOR type,MqlParam &params[])
  {
   int windows=(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOWS_TOTAL);
   for(int win=0;win<windows;win++)
     {
      int total=::ChartIndicatorsTotal(this.m_chart_id,win);
      for(int k=0;k<total;k++)
        {
         CWndInd ind(this.m_chart_id,win,k);
         ENUM_INDICATOR line_type;
         MqlParam line_params[];
         if(ind.GetIdentity(line_type,line_params) && line_type==type && IsEqualMqlParamArrays(line_params,params))
           {
            ::ChartIndicatorDelete(this.m_chart_id,win,ind.Name());
            return;
           }
        }
     }
  }

#endif // CCHARTOBJ_MQH_IMPLEMENTATION
#endif // __CHARTOBJ_MQH__