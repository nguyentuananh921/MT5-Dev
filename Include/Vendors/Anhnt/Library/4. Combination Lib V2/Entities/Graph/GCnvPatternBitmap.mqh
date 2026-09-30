//+------------------------------------------------------------------+
//|                                           GCnvPatternBitmap.mqh |
//|                                         Copyright 2025, Anhnt   |
//+------------------------------------------------------------------+
#ifndef __GCNVPATTERNBITMAP_MQH__
#define __GCNVPATTERNBITMAP_MQH__
#property strict
#include "..\GBases\GElement.mqh"
#include "..\Defines\TimeseriesDefines.mqh"
#ifndef CGCNVPATTERNBITMAP_MQH_DECLARATION
#define CGCNVPATTERNBITMAP_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Box over a candle pattern, behind the candles, follows the chart |
 //+------------------------------------------------------------------+
 class CGCnvPatternBitmap : public CGElement
  {
    private:
        ENUM_PATTERN_DIRECTION m_dir;            // drives the fill/border colors
        int               m_bars_formation;      // number of bars in the formation
        datetime          m_anchor_time;         // open time of the oldest bar
        double            m_price_high;          // max high across the formation
        double            m_price_low;           // min low across the formation

        color             FillColor(void) const;
        color             BorderColor(void) const;
        void              Reposition(void);
    public:
        bool              CreatePatternBitmap(const long chart_id,const int subwin,const string name);
        void              SetPattern(const datetime anchor_time,const double price_high,const double price_low,
                                     const ENUM_PATTERN_DIRECTION dir,const int bars_formation);
        virtual void      Draw(const bool chart_redraw);
        virtual bool      CheckMouseFocus(const int x,const int y)  { this.m_mouse_focus=false; return(false); }
        virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
        ENUM_PATTERN_DIRECTION Direction(void)            const { return this.m_dir;            }
        int               BarsFormation(void)             const { return this.m_bars_formation; }
        double            PriceHigh(void)                 const { return this.m_price_high;     }
        double            PriceLow(void)                  const { return this.m_price_low;      }
                          CGCnvPatternBitmap(void);
                         ~CGCnvPatternBitmap(void) {}
  };
#endif // CGCNVPATTERNBITMAP_MQH_DECLARATION
#ifndef CGCNVPATTERNBITMAP_MQH_IMPLEMENTATION
#define CGCNVPATTERNBITMAP_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
 CGCnvPatternBitmap::CGCnvPatternBitmap(void) : m_dir(PATTERN_DIRECTION_BOTH),m_bars_formation(1),m_anchor_time(0),
                                                m_price_high(0),m_price_low(0)
  {
  }
 //+------------------------------------------------------------------+
 //| Born hidden, behind the candles, no native tooltip               |
 //+------------------------------------------------------------------+
 bool CGCnvPatternBitmap::CreatePatternBitmap(const long chart_id,const int subwin,const string name)
  {
    this.Hide();
    if(!this.Create(chart_id,subwin,name,0,0,1,1))
       return false;
    ::ObjectSetInteger(this.m_chart_id,this.Name(),OBJPROP_BACK,true);
    ::ObjectSetString(this.m_chart_id,this.Name(),OBJPROP_TOOLTIP,"\n");
    return true;
  }
 //+------------------------------------------------------------------+
 //| Load a pattern and place the box over it                         |
 //+------------------------------------------------------------------+
 void CGCnvPatternBitmap::SetPattern(const datetime anchor_time,const double price_high,const double price_low,
                                     const ENUM_PATTERN_DIRECTION dir,const int bars_formation)
  {
    this.m_anchor_time   =anchor_time;
    this.m_price_high    =price_high;
    this.m_price_low     =price_low;
    this.m_dir           =dir;
    this.m_bars_formation=(bars_formation<1 ? 1 : bars_formation);
    this.Reposition();
    this.Draw(false);
  }
 //+------------------------------------------------------------------+
 //| Pixel box from the oldest bar to the newest, high to low + 4px   |
 //+------------------------------------------------------------------+
 void CGCnvPatternBitmap::Reposition(void)
  {
    int x=0,y_top=0,y_bottom=0;
    if(!::ChartTimePriceToXY(this.m_chart_id,this.m_subwindow,this.m_anchor_time,this.m_price_high,x,y_top) ||
       !::ChartTimePriceToXY(this.m_chart_id,this.m_subwindow,this.m_anchor_time,this.m_price_low,x,y_bottom))
       return;
    int slot_w=(int)(1<<(int)::ChartGetInteger(this.m_chart_id,CHART_SCALE));
    int w=this.m_bars_formation*slot_w+1;
    int h=y_bottom-y_top+8;
    if(h<12)
       h=12;
    this.Resize(w,h);
    this.Move(x-slot_w/2,y_top-4);
  }
 //+------------------------------------------------------------------+
 //|                                                                  |
 //+------------------------------------------------------------------+
 color CGCnvPatternBitmap::FillColor(void) const
  {
    switch(this.m_dir)
      {
       case PATTERN_DIRECTION_BULLISH : return clrCornflowerBlue;
       case PATTERN_DIRECTION_BEARISH : return clrLightSalmon;
       default                        : return clrSilver;
      }
  }
 color CGCnvPatternBitmap::BorderColor(void) const
  {
    switch(this.m_dir)
      {
       case PATTERN_DIRECTION_BULLISH : return clrRoyalBlue;
       case PATTERN_DIRECTION_BEARISH : return clrCrimson;
       default                        : return clrDimGray;
      }
  }
 //+------------------------------------------------------------------+
 //| Transparent canvas, semi-transparent fill, solid border          |
 //+------------------------------------------------------------------+
 void CGCnvPatternBitmap::Draw(const bool chart_redraw)
  {
    this.m_canvas.Erase(0);
    this.m_canvas.FillRectangle(0,0,this.m_x_size-1,this.m_y_size-1,::ColorToARGB(this.FillColor(),100));
    this.m_canvas.Rectangle(0,0,this.m_x_size-1,this.m_y_size-1,::ColorToARGB(this.BorderColor(),255));
    this.m_canvas.Update(chart_redraw);
  }
 //+------------------------------------------------------------------+
 //| Scroll/zoom: follow the candles                                  |
 //+------------------------------------------------------------------+
 void CGCnvPatternBitmap::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
    CGElement::OnChartEvent(id,lparam,dparam,sparam);
    if(id==CHARTEVENT_CHART_CHANGE && this.IsVisible())
      {
       this.Reposition();
       this.Draw(false);
      }
  }
#endif // CGCNVPATTERNBITMAP_MQH_IMPLEMENTATION
#endif // __GCNVPATTERNBITMAP_MQH__
