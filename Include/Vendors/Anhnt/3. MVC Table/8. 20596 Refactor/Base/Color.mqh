//+------------------------------------------------------------------+
//|                                                      Color.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in                                                     |
//|       Base graphical element                                     |
//|                           https://www.mql5.com/en/articles/17960 |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Color class                                                     |
//+------------------------------------------------------------------+
#ifndef __COLOR_MQH__
#define __COLOR_MQH__
//+------------------------------------------------------------------+
//| Included Standard Libraries                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Included Custome Libraries                                       |
//+------------------------------------------------------------------+
//#include <Arrays\List.mqh>
#include "BaseObj.mqh"   
   class CColor : public CBaseObj
   {
      protected:
         color             m_color;                                  // Color         
      public:
      // --- Sets the color
         bool              SetColor(const color clr)
                           {
                              if(this.m_color==clr)
                                 return false;
                              this.m_color=clr;
                              return true;
                           }
      // --- Returns the color
         color             Get(void)                           const { return this.m_color;              }

      // --- Returns a description of the object
         virtual string    Description(void);
         
      // --- Virtual methods (1) save to file, (2) load from file, (3) object type
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_COLOR);       }
         
      // --- Constructors/destructor
                           CColor(void) : m_color(clrNULL)                          { this.SetName("");  }
                           CColor(const color clr) : m_color(clr)                   { this.SetName("");  }
                           CColor(const color clr,const string name) : m_color(clr) { this.SetName(name);}
                         ~CColor(void) {}
   };
   #ifndef CCOLOR_IMPLEMENTATION
   #define CCOLOR_IMPLEMENTATION
      //+------------------------------------------------------------------+
      //| CColor::Returns the description of an object                     |
      //+------------------------------------------------------------------+
      string CColor::Description(void)
      {
         //--- 1. Get basic info from Parent: "Color: Name (ID 123)"
         //--- Assuming ELEMENT_TYPE_COLOR is defined in your enum
         string baseDesc = CBaseObj::Description();
         
         //--- 2. Process color string
         //--- Use your existing logic for clrNULL
         string color_name = (this.Get() != clrNULL ? ::ColorToString(this.Get(), true) : "clrNULL (0x00FFFFFF)");
         
         //--- 3. Return combined string: "Color: Name (ID 123), Value: clrRed"
         return ::StringFormat("%s, Value: %s", baseDesc, color_name);
         

         // string color_name=(this.Get()!=clrNULL ? ::ColorToString(this.Get(),true) : "clrNULL (0x00FFFFFF)");
         // return(this.Name()+(this.Name()!="" ? " " : "")+"Color: "+color_name);
      }
      //+------------------------------------------------------------------+
      // | CColor::Save to file |
      //+------------------------------------------------------------------+
      bool CColor::Save(const int file_handle)
      {
       //| Update in                                                        |
       //|       Simple controls                                            |
       //|                           https://www.mql5.com/en/articles/18221 |  
         // --- Save the data of the parent object
            if(!CBaseObj::Save(file_handle))
               return false;            
         // --- Preserve color
            if(::FileWriteInteger(file_handle,this.m_color,INT_VALUE)!=INT_VALUE)
               return false;
            
         // --- Everything is successful
            return true;
      }
      //+------------------------------------------------------------------+
      // | CColor::Loading from file |
      //+------------------------------------------------------------------+
      bool CColor::Load(const int file_handle)
      {
       //| Update in                                                        |
       //|       Simple controls                                            |
       //|                           https://www.mql5.com/en/articles/18221 |  
         // --- Loading the data of the parent object
            if(!CBaseObj::Load(file_handle))
               return false;
               
         // --- Loading color
            this.m_color=(color)::FileReadInteger(file_handle,INT_VALUE);
            
         // --- Everything is successful
            return true;
      }
   #endif // DECLARATION_IMPLEMENTATION
   //+------------------------------------------------------------------+
#endif // __COLOR_MQH__

