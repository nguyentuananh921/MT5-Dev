//+------------------------------------------------------------------+
//|                                               ColorElement.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in                                                     |
//|       Base graphical element                                     |
//|                           https://www.mql5.com/en/articles/17960 |
//| Update in                                                        |
//|       Simple controls                                            |
//|                           https://www.mql5.com/en/articles/18221 |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#ifndef __COLORELEMENT_MQH__
#define __COLORELEMENT_MQH__
#include "Color.mqh"
#include "..\Defines\GraphDefines.mqh"
//+------------------------------------------------------------------+
//| Graphics element color class                                     |
//+------------------------------------------------------------------+
class CColorElement : public CObject
  {
protected:
   CColor            m_current;
   CColor            m_default;
   CColor            m_focused;
   CColor            m_pressed;
   CColor            m_blocked;

   color             RGBToColor(const double r,const double g,const double b) const;
   void              ColorToRGB(const color clr,double &r,double &g,double &b);
   double            GetR(const color clr)                     { return clr&0xFF;                           }
   double            GetG(const color clr)                     { return(clr>>8)&0xFF;                       }
   double            GetB(const color clr)                     { return(clr>>16)&0xFF;                      }

public:
   color             NewColor(color base_color, int shift_red, int shift_green, int shift_blue);
   color             InterpolateColorByCoeff(const color color1, const color color2, const color color3, const double coeff);

   bool              InitDefault(const color clr)              { return this.m_default.SetColor(clr);       }
   bool              InitFocused(const color clr)              { return this.m_focused.SetColor(clr);       }
   bool              InitPressed(const color clr)              { return this.m_pressed.SetColor(clr);       }
   bool              InitBlocked(const color clr)              { return this.m_blocked.SetColor(clr);       }
   void              InitColors(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked);
   void              InitColors(const color clr);

   color             GetCurrent(void)                    const { return this.m_current.Get();               }
   color             GetDefault(void)                    const { return this.m_default.Get();               }
   color             GetFocused(void)                    const { return this.m_focused.Get();               }
   color             GetPressed(void)                    const { return this.m_pressed.Get();               }
   color             GetBlocked(void)                    const { return this.m_blocked.Get();               }

   bool              SetCurrentAs(const ENUM_COLOR_STATE color_state);

                     CColorElement(void);
                     CColorElement(const color clr);
                     CColorElement(const color clr_default,const color clr_focused,const color clr_pressed,const color clr_blocked);
                    ~CColorElement(void) {}
  };
#ifndef CCOLORELEMENT_IMPLEMENTATION
#define CCOLORELEMENT_IMPLEMENTATION
//+------------------------------------------------------------------+
//| CColorElement::Constructor for transparent colors                |
//+------------------------------------------------------------------+
CColorElement::CColorElement(void)
  {
   this.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
   this.SetCurrentAs(COLOR_STATE_DEFAULT);
  }
//+------------------------------------------------------------------+
//| CColorElement::Constructor specifying all state colors           |
//+------------------------------------------------------------------+
CColorElement::CColorElement(const color clr_default,const color clr_focused,const color clr_pressed,const color clr_blocked)
  {
   this.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
   this.SetCurrentAs(COLOR_STATE_DEFAULT);
  }
//+------------------------------------------------------------------+
//| CColorElement::Constructor deriving state colors from one color  |
//+------------------------------------------------------------------+
CColorElement::CColorElement(const color clr)
  {
   this.InitColors(clr);
   this.SetCurrentAs(COLOR_STATE_DEFAULT);
  }
//+------------------------------------------------------------------+
//| CColorElement::Sets colors for all states                        |
//+------------------------------------------------------------------+
void CColorElement::InitColors(const color clr_default,const color clr_focused,const color clr_pressed,const color clr_blocked)
  {
   this.InitDefault(clr_default);
   this.InitFocused(clr_focused);
   this.InitPressed(clr_pressed);
   this.InitBlocked(clr_blocked);
  }
//+------------------------------------------------------------------+
//| CColorElement::Sets colors for all states based on one color     |
//+------------------------------------------------------------------+
void CColorElement::InitColors(const color clr)
  {
   this.InitDefault(clr);
   this.InitFocused(clr!=clrNONE ? this.NewColor(clr,-20,-20,-20) : clrNONE);
   this.InitPressed(clr!=clrNONE ? this.NewColor(clr,-40,-40,-40) : clrNONE);
   this.InitBlocked(clrWhiteSmoke);
  }
//+------------------------------------------------------------------+
//| CColorElement::Sets one state color as the current one           |
//+------------------------------------------------------------------+
bool CColorElement::SetCurrentAs(const ENUM_COLOR_STATE color_state)
  {
   switch(color_state)
     {
      case COLOR_STATE_DEFAULT   :  return this.m_current.SetColor(this.m_default.Get());
      case COLOR_STATE_FOCUSED   :  return this.m_current.SetColor(this.m_focused.Get());
      case COLOR_STATE_PRESSED   :  return this.m_current.SetColor(this.m_pressed.Get());
      case COLOR_STATE_BLOCKED   :  return this.m_current.SetColor(this.m_blocked.Get());
      default                    :  return false;
     }
  }
//+------------------------------------------------------------------+
//| CColorElement::Converts RGB to color                             |
//+------------------------------------------------------------------+
color CColorElement::RGBToColor(const double r,const double g,const double b) const
  {
   int int_r=(int)::round(r);
   int int_g=(int)::round(g);
   int int_b=(int)::round(b);
   int clr=0;
   clr=int_b;
   clr<<=8;
   clr|=int_g;
   clr<<=8;
   clr|=int_r;
   return (color)clr;
  }
//+------------------------------------------------------------------+
//| CColorElement::Gets RGB component values                         |
//+------------------------------------------------------------------+
void CColorElement::ColorToRGB(const color clr,double &r,double &g,double &b)
  {
   r=this.GetR(clr);
   g=this.GetG(clr);
   b=this.GetB(clr);
  }
//+------------------------------------------------------------------+
//| CColorElement::Returns a color with shifted components           |
//+------------------------------------------------------------------+
color CColorElement::NewColor(color base_color, int shift_red, int shift_green, int shift_blue)
  {
   double clrR=0, clrG=0, clrB=0;
   this.ColorToRGB(base_color,clrR,clrG,clrB);
   double clrRx=(clrR+shift_red  < 0 ? 0 : clrR+shift_red  > 255 ? 255 : clrR+shift_red);
   double clrGx=(clrG+shift_green< 0 ? 0 : clrG+shift_green> 255 ? 255 : clrG+shift_green);
   double clrBx=(clrB+shift_blue < 0 ? 0 : clrB+shift_blue > 255 ? 255 : clrB+shift_blue);
   return this.RGBToColor(clrRx,clrGx,clrBx);
  }
//+------------------------------------------------------------------+
//| Returns the interpolated color between three colors              |
//| depending on the coefficient value (from -1 to +1)               |
//+------------------------------------------------------------------+
color CColorElement::InterpolateColorByCoeff(const color color1,const color color2,const color color3,const double coeff)
  {
   double val=::fmax(-1.0,::fmin(1.0,coeff));
   double r1, g1, b1, r2, g2, b2;
   double r, g, b, t;
   if(val<0.0)
     {
      this.ColorToRGB(color1,r1,g1,b1);
      this.ColorToRGB(color2,r2,g2,b2);
      t=(val+1.0)/1.0;
      r=r1+(r2-r1)*t;
      g=g1+(g2-g1)*t;
      b=b1+(b2-b1)*t;
     }
   else
     {
      this.ColorToRGB(color3,r1,g1,b1);
      this.ColorToRGB(color2,r2,g2,b2);
      t=val/1.0;
      r=r2+(r1-r2)*t;
      g=g2+(g1-g2)*t;
      b=b2+(b1-b2)*t;
     }
   return this.RGBToColor(r,g,b);
  }
#endif // CCOLORELEMENT_IMPLEMENTATION
#endif // __COLORELEMENT_MQH__
