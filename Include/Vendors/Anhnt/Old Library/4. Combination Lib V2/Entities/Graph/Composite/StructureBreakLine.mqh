//+------------------------------------------------------------------+
//|                                            StructureBreakLine.mqh |
//+------------------------------------------------------------------+
#ifndef __STRUCTUREBREAKLINE_COMPOSITE_MQH__
#define __STRUCTUREBREAKLINE_COMPOSITE_MQH__
 #include "..\..\GBases\GBaseObj.mqh"
 #include "..\Standard\GStdTrendObj.mqh"
 #include "..\Standard\GStdTextObj.mqh"
#ifndef CSTRUCTURE_BREAK_LINE_COMPOSITE_DECLARATION
#define CSTRUCTURE_BREAK_LINE_COMPOSITE_DECLARATION
 //+------------------------------------------------------------------+
 //| A BOS / CHoCH on the chart: a horizontal line at the broken      |
 //| Swing level from the Swing candle to the candle that broke it,   |
 //| with its name in the middle (above the line for a break up,      |
 //| below it for a break down). Both are native objects bound to time|
 //| and price, drawn in the background (behind the candles and the   |
 //| panel windows), so nothing has to follow scroll or zoom          |
 //+------------------------------------------------------------------+
 class CStructureBreakLine : public CGBaseObj
  {
   private:
     CGStdTrendObj             m_trend_line;      // the level, Swing candle -> break candle
     CGStdTextObj              m_text_label;      // "BOS" / "CHoCH" at the middle of the line
   public:
     bool                      Create(const long chart_id,const int subwin,const string name);
     void                      SetBreak(const datetime swing_time,const datetime break_time,const double level,
                                        const string text,const bool is_up,const color colour);
                               CStructureBreakLine(void) {}
  };
#endif // CSTRUCTURE_BREAK_LINE_COMPOSITE_DECLARATION
#ifndef CSTRUCTURE_BREAK_LINE_COMPOSITE_IMPLEMENTATION
#define CSTRUCTURE_BREAK_LINE_COMPOSITE_IMPLEMENTATION
 bool CStructureBreakLine::Create(const long chart_id,const int subwin,const string name)
  {
   if(!this.m_trend_line.Create(chart_id,subwin,name+"_line"))
      return false;
   if(!this.m_text_label.Create(chart_id,subwin,name+"_text"))
      return false;
   this.SetName(name);
   this.SetChartID(this.m_trend_line.ChartID());
   this.m_subwindow=this.m_trend_line.SubWindow();
   this.m_trend_line.SetFlagBack(true,false);
   this.m_trend_line.SetFlagSelectable(false,false);
   this.m_trend_line.SetTooltip("\n");
   this.m_text_label.SetFlagBack(true,false);
   this.m_text_label.SetFlagSelectable(false,false);
   this.m_text_label.SetTooltip("\n");
   this.m_text_label.SetFont(DEF_FONT);
   this.m_text_label.SetFontSize(DEF_FONT_SIZE);
   this.AddChild(&this.m_trend_line);
   this.AddChild(&this.m_text_label);
   return true;
  }
 void CStructureBreakLine::SetBreak(const datetime swing_time,const datetime break_time,const double level,
                                    const string text,const bool is_up,const color colour)
  {
   this.m_trend_line.SetTime(swing_time,0);
   this.m_trend_line.SetPrice(level,0);
   this.m_trend_line.SetTime(break_time,1);
   this.m_trend_line.SetPrice(level,1);
   this.m_trend_line.SetColor(colour);
   this.m_text_label.SetTime((datetime)((long)swing_time+((long)break_time-(long)swing_time)/2),0);
   this.m_text_label.SetPrice(level,0);
   this.m_text_label.SetText(text);
   this.m_text_label.SetColor(colour);
   this.m_text_label.SetAnchor(is_up ? ANCHOR_LOWER : ANCHOR_UPPER);
  }
#endif // CSTRUCTURE_BREAK_LINE_COMPOSITE_IMPLEMENTATION
#endif // __STRUCTUREBREAKLINE_COMPOSITE_MQH__
