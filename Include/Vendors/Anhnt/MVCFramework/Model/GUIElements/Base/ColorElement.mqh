//+------------------------------------------------------------------+
//|                                                ColorElement.mqh  |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __COLORELEMENT_MQH__
#define __COLORELEMENT_MQH__
//+------------------------------------------------------------------+
//| Graphical element color set class                                |
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "BaseEnums.mqh"
#include "BaseObj.mqh"
#include "Color.mqh"

//+------------------------------------------------------------------+

class CColorElement : public CBaseObj
  {
protected:
   CColor            m_current;                                // Current color. Can be one of the following:
   CColor            m_default;                                // Default state color
   CColor            m_focused;                                // Color when hovered (focused)
   CColor            m_pressed;                                // Color when pressed
   CColor            m_blocked;                                // Color for blocked element
   
//--- Converts RGB to color
   color             RGBToColor(const double r,const double g,const double b) const;
//--- Writes RGB component values into variables
   void              ColorToRGB(const color clr,double &r,double &g,double &b);
//--- Returns color component: (1) Red, (2) Green, (3) Blue
   double            GetR(const color clr)                     { return clr&0xFF;                           }
   double            GetG(const color clr)                     { return(clr>>8)&0xFF;                       }
   double            GetB(const color clr)                     { return(clr>>16)&0xFF;                      }
   
public:
//--- Returns a new color
   color             NewColor(color base_color, int shift_red, int shift_green, int shift_blue);

//--- Class initialization
   void              Init(void);

//--- Initialization of colors for various states
   bool              InitDefault(const color clr)              { return this.m_default.SetColor(clr);       }
   bool              InitFocused(const color clr)              { return this.m_focused.SetColor(clr);       }
   bool              InitPressed(const color clr)              { return this.m_pressed.SetColor(clr);       }
   bool              InitBlocked(const color clr)              { return this.m_blocked.SetColor(clr);       }
   
//--- Setting colors for all states
   void              InitColors(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked);
   void              InitColors(const color clr);
    
//--- Returning colors of various states
   color             GetCurrent(void)                    const { return this.m_current.Get();               }
   color             GetDefault(void)                    const { return this.m_default.Get();               }
   color             GetFocused(void)                    const { return this.m_focused.Get();               }
   color             GetPressed(void)                    const { return this.m_pressed.Get();               }
   color             GetBlocked(void)                    const { return this.m_blocked.Get();               }
   
//--- Sets one of the color lists as current
   bool              SetCurrentAs(const ENUM_COLOR_STATE color_state);

//--- Returns object description
   virtual string    Description(void);
   
//--- Virtual methods: (1) save to file, (2) load from file, (3) object type
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void)                          const { return(ELEMENT_TYPE_COLORS_ELEMENT);       }
   
//--- Constructors/destructor
                     CColorElement(void);
                     CColorElement(const color clr);
                     CColorElement(const color clr_default,const color clr_focused,const color clr_pressed,const color clr_blocked);
                    ~CColorElement(void) {}
  };
//+------------------------------------------------------------------+
//| CColorElement::Constructor with transparent colors setting       |
//+------------------------------------------------------------------+
CColorElement::CColorElement(void)
  {
   this.InitColors(clrNULL,clrNULL,clrNULL,clrNULL);
   this.Init();
  }
//+------------------------------------------------------------------+
//| CColorElement::Constructor with specified colors                 |
//+------------------------------------------------------------------+
CColorElement::CColorElement(const color clr_default,const color clr_focused,const color clr_pressed,const color clr_blocked)
  {
   this.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
   this.Init();
  }
//+------------------------------------------------------------------+
//| CColorElement::Constructor with specified single color           |
//+------------------------------------------------------------------+
CColorElement::CColorElement(const color clr)
  {
   this.InitColors(clr);
   this.Init();
  }
//+------------------------------------------------------------------+
//| CColorElement::Class initialization                              |
//+------------------------------------------------------------------+
void CColorElement::Init(void)
  {
   this.m_default.SetName("Default"); this.m_default.SetID(1);
   this.m_focused.SetName("Focused"); this.m_focused.SetID(2);
   this.m_pressed.SetName("Pressed"); this.m_pressed.SetID(3);
   this.m_blocked.SetName("Blocked"); this.m_blocked.SetID(4);
   this.SetCurrentAs(COLOR_STATE_DEFAULT);
   this.m_current.SetName("Current");
   this.m_current.SetID(0);
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
//| CColorElement::Sets colors for all states based on current       |
//+------------------------------------------------------------------+
void CColorElement::InitColors(const color clr)
  {
   this.InitDefault(clr);
   this.InitFocused(clr!=clrNULL ? this.NewColor(clr,-20,-20,-20) : clrNULL);
   this.InitPressed(clr!=clrNULL ? this.NewColor(clr,-40,-40,-40) : clrNULL);
   this.InitBlocked(clrWhiteSmoke);   
  }
//+-------------------------------------------------------------------+
//|CColorElement::Sets one color from the list as current             |
//+-------------------------------------------------------------------+
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
//| CColorElement::Getting RGB component values                       |
//+------------------------------------------------------------------+
void CColorElement::ColorToRGB(const color clr,double &r,double &g,double &b)
  {
   r=this.GetR(clr);
   g=this.GetG(clr);
   b=this.GetB(clr);
  }
//+------------------------------------------------------------------+
//| CColorElement::Returns color with a new color component offset   |
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
//| CColorElement::Returns object description                        |
//+------------------------------------------------------------------+
string CColorElement::Description(void)
  {
   string res=::StringFormat("%s Colors. %s",this.Name(),this.m_current.Description());
   res+="\n  1: "+this.m_default.Description();
   res+="\n  2: "+this.m_focused.Description();
   res+="\n  3: "+this.m_pressed.Description();
   res+="\n  4: "+this.m_blocked.Description();
   return res;
  }
//+------------------------------------------------------------------+
//| CColorElement::Saving to file                                    |
//+------------------------------------------------------------------+
bool CColorElement::Save(const int file_handle)
  {
//--- Save parent object data
   if(!CBaseObj::Save(file_handle))
      return false;
   
//--- Save current color
   if(!this.m_current.Save(file_handle))
      return false;
//--- Save default state color
   if(!this.m_default.Save(file_handle))
      return false;
//--- Save color when hovered
   if(!this.m_focused.Save(file_handle))
      return false;
//--- Save color when pressed
   if(!this.m_pressed.Save(file_handle))
      return false;
//--- Save blocked element color
   if(!this.m_blocked.Save(file_handle))
      return false;
   
//--- Everything successful
   return true;
  }
//+------------------------------------------------------------------+
//| CColorElement::Loading from file                                 |
//+------------------------------------------------------------------+
bool CColorElement::Load(const int file_handle)
  {
//--- Load parent object data
   if(!CBaseObj::Load(file_handle))
      return false;
      
//--- Load current color
   if(!this.m_current.Load(file_handle))
      return false;
//--- Load default state color
   if(!this.m_default.Load(file_handle))
      return false;
//--- Load color when hovered
   if(!this.m_focused.Load(file_handle))
      return false;
//--- Load color when pressed
   if(!this.m_pressed.Load(file_handle))
      return false;
//--- Load blocked element color
   if(!this.m_blocked.Load(file_handle))
      return false;
   
//--- Everything successful
   return true;
  }
//+------------------------------------------------------------------+
  #endif //__COLORELEMENT_MQH__