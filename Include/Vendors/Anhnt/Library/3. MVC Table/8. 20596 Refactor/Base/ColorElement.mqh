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
//+------------------------------------------------------------------+
//| Graphics element color class |
//+------------------------------------------------------------------+

#ifndef __COLORELEMENT_MQH__
#define __COLORELEMENT_MQH__
   //+------------------------------------------------------------------+
   //| Included Libraries                                               |
   //+------------------------------------------------------------------+
   #include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "Color.mqh"
   #include "..\Defines\BaseEnums.mqh"   
   class CColorElement : public CBaseObj
   {
      protected:
         CColor            m_current;                                // Current color. Can be one of the following
         CColor            m_default;                                // Normal color
         CColor            m_focused;                                // Hover color
         CColor            m_pressed;                                // Touch color
         CColor            m_blocked;                                // Blocked element color
         
      // --- Converts RGB to color
         color             RGBToColor(const double r,const double g,const double b) const;
      // --- Writes RGB component values ​​to variables
         void              ColorToRGB(const color clr,double &r,double &g,double &b);
      // --- Returns the color component (1) Red, (2) Green, (3) Blue
         double            GetR(const color clr)                     { return clr&0xFF;                           }
         double            GetG(const color clr)                     { return(clr>>8)&0xFF;                       }
         double            GetB(const color clr)                     { return(clr>>16)&0xFF;                      }
         
      public:
      // --- Returns the new color
         color             NewColor(color base_color, int shift_red, int shift_green, int shift_blue);

      // --- Returns an interpolated color between three colors depending on the coefficient value (from -1 to +1)
         color             InterpolateColorByCoeff(const color color1, const color color2, const color color3, const double coeff);
      //| Update in                                                        |
      //|       Simple controls                                            |
      //|                           https://www.mql5.com/en/articles/18221 |
        // --- Class initialization
         void              Init(void);
      // --- Initializing the colors of various states
         bool              InitDefault(const color clr)              { return this.m_default.SetColor(clr);       }
         bool              InitFocused(const color clr)              { return this.m_focused.SetColor(clr);       }
         bool              InitPressed(const color clr)              { return this.m_pressed.SetColor(clr);       }
         bool              InitBlocked(const color clr)              { return this.m_blocked.SetColor(clr);       }
         
      // --- Set colors for all states
         void              InitColors(const color clr_default, const color clr_focused, const color clr_pressed, const color clr_blocked);
         void              InitColors(const color clr);
         
      // ---Return colors of different states
         color             GetCurrent(void)                    const { return this.m_current.Get();               }
         color             GetDefault(void)                    const { return this.m_default.Get();               }
         color             GetFocused(void)                    const { return this.m_focused.Get();               }
         color             GetPressed(void)                    const { return this.m_pressed.Get();               }
         color             GetBlocked(void)                    const { return this.m_blocked.Get();               }
         
      // --- Sets one of the list of colors as the current one
         bool              SetCurrentAs(const ENUM_COLOR_STATE color_state);

      // --- Returns a description of the object
         virtual string    Description(void);
         
      // --- Virtual methods (1) save to file, (2) load from file, (3) object type
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_COLORS_ELEMENT);       }
         
      // --- Constructors/destructor
                           CColorElement(void);
                           CColorElement(const color clr);
                           CColorElement(const color clr_default,const color clr_focused,const color clr_pressed,const color clr_blocked);
                           ~CColorElement(void) {}
   };
   #ifndef CCOLORELEMENT_IMPLEMENTATION
   #define CCOLORELEMENT_IMPLEMENTATION
      //+------------------------------------------------------------------+
      // | CColorElement::Constructor for setting transparent object colors|
      //+------------------------------------------------------------------+
      CColorElement::CColorElement(void)
      {
         this.InitColors(clrNULL,clrNULL,clrNULL,clrNULL);
         this.Init();

      }
      //+------------------------------------------------------------------+
      // | CColorElement::Constructor specifying object colors |
      //+------------------------------------------------------------------+
      CColorElement::CColorElement(const color clr_default,const color clr_focused,const color clr_pressed,const color clr_blocked)
      {
       //| Update in                                                        |
       //|       Simple controls                                            |
       //|                           https://www.mql5.com/en/articles/18221 | 
         this.InitColors(clr_default,clr_focused,clr_pressed,clr_blocked);
         this.Init();
      }
      //+------------------------------------------------------------------+
      // | CColorElement::Constructor specifying the color of an object |
      //+------------------------------------------------------------------+
      CColorElement::CColorElement(const color clr)
      {
       //| Update in                                                        |
       //|       Simple controls                                            |
       //|                           https://www.mql5.com/en/articles/18221 |
         this.InitColors(clr);
         this.Init();
      }
      //+------------------------------------------------------------------+
      // | CColorElement::Class Initialization |
      //+------------------------------------------------------------------+
      void CColorElement::Init(void)
      {
       //| Update in                                                        |
       //|       Simple controls                                            |
       //|                           https://www.mql5.com/en/articles/18221 |
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
       //| Update in                                                        |
       //|       Simple controls                                            |
       //|                           https://www.mql5.com/en/articles/18221 |
         this.InitDefault(clr_default);
         this.InitFocused(clr_focused);
         this.InitPressed(clr_pressed);
         this.InitBlocked(clr_blocked);   
      }
      //+------------------------------------------------------------------+
      //| CColorElement::Sets colors for all states based on the current   |
      //+------------------------------------------------------------------+
      void CColorElement::InitColors(const color clr)
      {
       //| Update in                                                        |
       //|       Simple controls                                            |
       //|                           https://www.mql5.com/en/articles/18221 |
         this.InitDefault(clr);
         this.InitFocused(clr!=clrNULL ? this.NewColor(clr,-20,-20,-20) : clrNULL);
         this.InitPressed(clr!=clrNULL ? this.NewColor(clr,-40,-40,-40) : clrNULL);
         this.InitBlocked(clrWhiteSmoke);   
      }
      //+-------------------------------------------------------------------+
      //|CColorElement::Sets one color from the list of colors as the current|
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
      //| CColorElement::Converts RGB to color |
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
      // | CColorElement::Getting RGB component values ​​|
      //+------------------------------------------------------------------+
      void CColorElement::ColorToRGB(const color clr,double &r,double &g,double &b)
      {
         r=this.GetR(clr);
         g=this.GetG(clr);
         b=this.GetB(clr);
      }
      //+------------------------------------------------------------------+
      // | CColorElement::Returns a color with a new color component |
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
      // | Returns the interpolated color between three colors |
      // | depending on the coefficient value (from -1 to +1) |
      //+------------------------------------------------------------------+
      color CColorElement::InterpolateColorByCoeff(const color color1,const color color2,const color color3,const double coeff)
      {
      // --- We limit the value of the coefficient
         double val=::fmax(-1.0,::fmin(1.0,coeff));

      // --- Variables to get the RGB components for each color
         double r1, g1, b1, r2, g2, b2;
         double r, g, b, t;

      // --- Interpolation between initial and average color
         if(val<0.0)
         {
            this.ColorToRGB(color1,r1,g1,b1);
            this.ColorToRGB(color2,r2,g2,b2);
            t=(val+1.0)/1.0;
            r=r1+(r2-r1)*t;
            g=g1+(g2-g1)*t;
            b=b1+(b2-b1)*t;
         }
      // --- Interpolation between middle and end color
         else
         {
            this.ColorToRGB(color3,r1,g1,b1); 
            this.ColorToRGB(color2,r2,g2,b2);
            t=val/1.0;
            r=r2+(r1-r2)*t;
            g=g2+(g1-g2)*t;
            b=b2+(b1-b2)*t;
         }
      // --- Return the calculated color
         return this.RGBToColor(r,g,b);
      }
      //+------------------------------------------------------------------+
      // | CColorElement::Returns the description of the object |
      //+------------------------------------------------------------------+
      string CColorElement::Description(void)
      {
         //--- 1. Get base info: "Color Element: Name (ID 123)"
         string res = CBaseObj::Description() + " States:";
         
         //--- 2. Each m_current, m_default... is a CColor object.
         //--- Their .Description() now returns "Color: Name (ID) Value: clr..."

         res=::StringFormat("%s Colors. %s",this.Name(),this.m_current.Description());
         res+="\n  1: "+this.m_default.Description();
         res+="\n  2: "+this.m_focused.Description();
         res+="\n  3: "+this.m_pressed.Description();
         res+="\n  4: "+this.m_blocked.Description();
         return res;
      }
      //+------------------------------------------------------------------+
      // | CColorElement::Saving to file |
      //+------------------------------------------------------------------+
      bool CColorElement::Save(const int file_handle)
      {
      // --- Save the data of the parent object
         if(!CBaseObj::Save(file_handle))
            return false;
         
      // --- Save the current color
         if(!this.m_current.Save(file_handle))
            return false;
      // --- Maintain the color of the normal state
         if(!this.m_default.Save(file_handle))
            return false;
      // --- Maintain color on hover
         if(!this.m_focused.Save(file_handle))
            return false;
      // --- Save color when clicked
         if(!this.m_pressed.Save(file_handle))
            return false;
      // --- Preserve the color of the blocked element
         if(!this.m_blocked.Save(file_handle))
            return false;
         
      // --- Everything is successful
         return true;
      }
      //+------------------------------------------------------------------+
      // | CColorElement::Loading from file |
      //+------------------------------------------------------------------+
      bool CColorElement::Load(const int file_handle)
      {
      // --- Loading the data of the parent object
         if(!CBaseObj::Load(file_handle))
            return false;
            
      // --- Load the current color
         if(!this.m_current.Load(file_handle))
            return false;
      // --- Loading the color of the normal state
         if(!this.m_default.Load(file_handle))
            return false;
      // --- Load color on hover
         if(!this.m_focused.Load(file_handle))
            return false;
      // --- Load color when clicked
         if(!this.m_pressed.Load(file_handle))
            return false;
      // --- Load the color of the blocked element
         if(!this.m_blocked.Load(file_handle))
            return false;
         
      // --- Everything is successful
         return true;
      }
      //+------------------------------------------------------------------+
   #endif // DECLARATION_IMPLEMENTATION
#endif // __COLORELEMENT_MQH__

