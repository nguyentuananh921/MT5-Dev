//+------------------------------------------------------------------+
//|                                                  MovementLine.mqh |
//+------------------------------------------------------------------+
#ifndef __MOVEMENTLINE_COMPOSITE_MQH__
#define __MOVEMENTLINE_COMPOSITE_MQH__
 #include "..\..\GBases\GBaseObj.mqh"
 #include "..\Standard\GStdTrendObj.mqh"
#ifndef CMOVEMENT_LINE_COMPOSITE_DECLARATION
#define CMOVEMENT_LINE_COMPOSITE_DECLARATION
 //+------------------------------------------------------------------+
 //| One leg of the market on the chart: a straight line from one     |
 //| Swing to the next, coloured by what Python made of it (Impulse,  |
 //| Pullback, no trend). A native object bound to time and price,    |
 //| drawn in the background, so nothing has to follow scroll or zoom |
 //+------------------------------------------------------------------+
 class CMovementLine : public CGBaseObj
  {
   private:
     CGStdTrendObj             m_trend_line;      // Swing -> Swing
   public:
     bool                      Create(const long chart_id,const int subwin,const string name);
     void                      SetLeg(const datetime start_time,const double start_price,const datetime end_time,const double end_price,
                                      const color colour,const ENUM_LINE_STYLE style,const int width,const string tooltip);
                               CMovementLine(void) {}
  };
#endif // CMOVEMENT_LINE_COMPOSITE_DECLARATION
#ifndef CMOVEMENT_LINE_COMPOSITE_IMPLEMENTATION
#define CMOVEMENT_LINE_COMPOSITE_IMPLEMENTATION
 bool CMovementLine::Create(const long chart_id,const int subwin,const string name)
  {
   if(!this.m_trend_line.Create(chart_id,subwin,name+"_line"))
      return false;
   this.SetName(name);
   this.SetChartID(this.m_trend_line.ChartID());
   this.m_subwindow=this.m_trend_line.SubWindow();
   this.m_trend_line.SetFlagBack(true,false);
   this.m_trend_line.SetFlagSelectable(false,false);
   this.AddChild(&this.m_trend_line);
   return true;
  }
 void CMovementLine::SetLeg(const datetime start_time,const double start_price,const datetime end_time,const double end_price,
                            const color colour,const ENUM_LINE_STYLE style,const int width,const string tooltip)
  {
   this.m_trend_line.SetTime(start_time,0);
   this.m_trend_line.SetPrice(start_price,0);
   this.m_trend_line.SetTime(end_time,1);
   this.m_trend_line.SetPrice(end_price,1);
   this.m_trend_line.SetColor(colour);
   this.m_trend_line.SetStyle(style);
   this.m_trend_line.SetWidth(width);
   this.m_trend_line.SetTooltip(tooltip);
  }
#endif // CMOVEMENT_LINE_COMPOSITE_IMPLEMENTATION
#endif // __MOVEMENTLINE_COMPOSITE_MQH__
