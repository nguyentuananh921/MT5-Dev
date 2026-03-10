//+------------------------------------------------------------------+
//|                                                        Color.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __COLOR_MQH__
#define __COLOR_MQH__

//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "BaseDefines.mqh"
#include "BaseEnums.mqh"
#include "BaseObj.mqh"

//+------------------------------------------------------------------+
//| Color class                                                      |
//+------------------------------------------------------------------+
class CColor : public CBaseObj
  {
protected:
   color             m_color;      // Color
   
public:

//--- Set color
   bool              SetColor(const color clr)
                       {
                        if(this.m_color==clr)
                           return false;

                        this.m_color=clr;
                        return true;
                       }

//--- Return color
   color             Get(void) const { return this.m_color; }

//--- Return object description
   virtual string    Description(void);

//--- Virtual methods
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void) const { return(ELEMENT_TYPE_COLOR); }

//--- Constructors
                     CColor(void) : m_color(clrNULL) { this.SetName(""); }
                     CColor(const color clr) : m_color(clr) { this.SetName(""); }
                     CColor(const color clr,const string name) : m_color(clr) { this.SetName(name); }
                    ~CColor(void) {}
  };

//+------------------------------------------------------------------+
//| CColor::Return object description                                |
//+------------------------------------------------------------------+
string CColor::Description(void)
  {
   string color_name=(this.Get()!=clrNULL ? ::ColorToString(this.Get(),true) : "clrNULL (0x00FFFFFF)");
   return(this.Name()+(this.Name()!="" ? " " : "")+"Color: "+color_name);
  }

//+------------------------------------------------------------------+
//| CColor::Save to file                                             |
//+------------------------------------------------------------------+
bool CColor::Save(const int file_handle)
  {
   if(!CBaseObj::Save(file_handle))
      return false;

   if(::FileWriteInteger(file_handle,this.m_color,INT_VALUE)!=INT_VALUE)
      return false;

   return true;
  }

//+------------------------------------------------------------------+
//| CColor::Load from file                                           |
//+------------------------------------------------------------------+
bool CColor::Load(const int file_handle)
  {
   if(!CBaseObj::Load(file_handle))
      return false;

   this.m_color=(color)::FileReadInteger(file_handle,INT_VALUE);

   return true;
  }

#endif