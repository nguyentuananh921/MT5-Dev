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
#ifndef __COLOR_MQH__
#define __COLOR_MQH__
#include <Object.mqh>
//+------------------------------------------------------------------+
//| Color class                                                      |
//+------------------------------------------------------------------+
class CColor : public CObject
  {
protected:
   color             m_color;
public:
   bool              SetColor(const color clr)
                       {
                        if(this.m_color==clr)
                           return false;
                        this.m_color=clr;
                        return true;
                       }
   color             Get(void)                           const { return this.m_color;              }

                     CColor(void) : m_color(clrNONE)                          {}
                     CColor(const color clr) : m_color(clr)                   {}
                    ~CColor(void) {}
  };
#endif // __COLOR_MQH__
