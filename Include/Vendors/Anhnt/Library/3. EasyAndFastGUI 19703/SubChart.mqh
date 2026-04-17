//+------------------------------------------------------------------+
//|                                                   RectCanvas.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//| Library link https://www.mql5.com/en/code/19703                  |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#ifndef __SUBCHART_MQH__
#define __SUBCHART_MQH__
 #include "Enums.mqh"
 #include "Defines.mqh"
 #include "Fonts.mqh"
 #include "Colors.mqh"
 #include <Graphics\Graphic.mqh>
 #include <ChartObjects\ChartObjectSubChart.mqh>
 #include "Resources.mqh"
//+------------------------------------------------------------------+
// | Class with additional properties for the Sub Chart object |
//+------------------------------------------------------------------+
class CSubChart : public CChartObjectSubChart
  {
protected:
   int               m_x;
   int               m_y;
   int               m_x2;
   int               m_y2;
   int               m_x_gap;
   int               m_y_gap;
   int               m_x_size;
   int               m_y_size;
   bool              m_mouse_focus;
   //---
public:
                     CSubChart(void);
                    ~CSubChart(void);
   // ---Coordinates
   int               X(void)                      { return(m_x);           }
   void              X(const int x)               { m_x=x;                 }
   int               Y(void)                      { return(m_y);           }
   void              Y(const int y)               { m_y=y;                 }
   int               X2(void)                     { return(m_x+m_x_size);  }
   int               Y2(void)                     { return(m_y+m_y_size);  }
   // --- Indents from the extreme point (xy)
   int               XGap(void)                   { return(m_x_gap);       }
   void              XGap(const int x_gap)        { m_x_gap=x_gap;         }
   int               YGap(void)                   { return(m_y_gap);       }
   void              YGap(const int y_gap)        { m_y_gap=y_gap;         }
   // --- Dimensions
   int               XSize(void)                  { return(m_x_size);      }
   void              XSize(const int x_size)      { m_x_size=x_size;       }
   int               YSize(void)                  { return(m_y_size);      }
   void              YSize(const int y_size)      { m_y_size=y_size;       }
   // ---Focus
   bool              MouseFocus(void)             { return(m_mouse_focus); }
   void              MouseFocus(const bool focus) { m_mouse_focus=focus;   }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSubChart::CSubChart(void) : m_x(0),
                             m_y(0),
                             m_x2(0),
                             m_y2(0),
                             m_x_gap(0),
                             m_y_gap(0),
                             m_x_size(0),
                             m_y_size(0),
                             m_mouse_focus(false)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSubChart::~CSubChart(void)
  {
  }
//+------------------------------------------------------------------+
#endif // __SUBCHART_MQH__


