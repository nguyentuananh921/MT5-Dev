//+------------------------------------------------------------------+
//|                                             PivotPatternShape.mqh |
//+------------------------------------------------------------------+
//--- New in V5: the drawing of a pivot pattern (Harmonic, Chart Pattern) on its pivots, as the EAs of the Reference draw it (Allan Munene Mutiiria\
//--- Automating Trading Strategies): Harmonic (08, 15, 27-33) two filled triangles, the legs and the letters; Head & Shoulders (13) the shoulder and head
//--- triangles on the neckline; Double Top / Bottom (53) the legs and the neckline; Quasimodo (49) the legs, the broken leg and the QM line.
//--- The mark of the pattern stays the badge of CBarMarker on the bar of the last pivot; this is drawn behind the candles, native objects bound to time,
//--- so nothing has to follow scroll or zoom (as CStructureBreakLine)
#ifndef __PIVOTPATTERNSHAPE_COMPOSITE_MQH__
#define __PIVOTPATTERNSHAPE_COMPOSITE_MQH__
 #include "..\..\GBases\GBaseObj.mqh"
 #include "..\Standard\GStdTrendObj.mqh"
 #include "..\Standard\GStdTextObj.mqh"
 #include "..\Standard\GStdTriangleObj.mqh"
 #include "..\..\Defines\BarDefines.mqh"
 #define PIVOT_SHAPE_TRIANGLES  (3)
 #define PIVOT_SHAPE_LINES      (8)
 #define PIVOT_SHAPE_TEXTS      (8)
#ifndef CPIVOTPATTERNSHAPE_COMPOSITE_DECLARATION
#define CPIVOTPATTERNSHAPE_COMPOSITE_DECLARATION
 class CPivotPatternShape : public CGBaseObj
  {
   private:
     long                      m_shape_chart;
     string                    m_base;
     CGStdTriangleObj          m_triangle[PIVOT_SHAPE_TRIANGLES];
     CGStdTrendObj             m_line[PIVOT_SHAPE_LINES];
     CGStdTextObj              m_text[PIVOT_SHAPE_TEXTS];
     int                       m_triangles,m_lines,m_texts;
    //--- One more part of the drawing (false: no room, or the chart did not make it)
     bool                      AddTriangle(const datetime t1,const double p1,const datetime t2,const double p2,const datetime t3,const double p3,const color colour);
     bool                      AddLine(const datetime t1,const double p1,const datetime t2,const double p2,const color colour,const int width,const ENUM_LINE_STYLE style);
     bool                      AddText(const datetime t,const double p,const string text,const color colour,const ENUM_ANCHOR_POINT anchor);
   public:
    //--- The drawing of the pattern of the type on its pivots (the oldest first; highs: a pivot is a high), Buy or Sell, its name in the middle
     bool                      Create(const long chart_id,const string name,const ENUM_BAR_INFOR_TYPE type,const long &times[],const double &prices[],
                                      const bool &highs[],const bool is_buy,const string title);
                               CPivotPatternShape(void) : m_shape_chart(0),m_triangles(0),m_lines(0),m_texts(0) {}
  };
#endif // CPIVOTPATTERNSHAPE_COMPOSITE_DECLARATION
#ifndef CPIVOTPATTERNSHAPE_COMPOSITE_IMPLEMENTATION
#define CPIVOTPATTERNSHAPE_COMPOSITE_IMPLEMENTATION
 bool CPivotPatternShape::AddTriangle(const datetime t1,const double p1,const datetime t2,const double p2,const datetime t3,const double p3,const color colour)
  {
   if(this.m_triangles>=PIVOT_SHAPE_TRIANGLES)
      return false;
   CGStdTriangleObj *obj=&this.m_triangle[this.m_triangles];
   if(!obj.Create(this.m_shape_chart,0,this.m_base+"_tri"+(string)this.m_triangles))
      return false;
   this.m_triangles++;
   obj.SetFlagBack(true,false);
   obj.SetFlagSelectable(false,false);
   obj.SetTooltip("\n");
   obj.SetTime(t1,0);
   obj.SetPrice(p1,0);
   obj.SetTime(t2,1);
   obj.SetPrice(p2,1);
   obj.SetTime(t3,2);
   obj.SetPrice(p3,2);
   obj.SetColor(colour);
   obj.SetFlagFill(true);
   this.AddChild(obj);
   return true;
  }
 bool CPivotPatternShape::AddLine(const datetime t1,const double p1,const datetime t2,const double p2,const color colour,const int width,const ENUM_LINE_STYLE style)
  {
   if(this.m_lines>=PIVOT_SHAPE_LINES)
      return false;
   CGStdTrendObj *obj=&this.m_line[this.m_lines];
   if(!obj.Create(this.m_shape_chart,0,this.m_base+"_line"+(string)this.m_lines))
      return false;
   this.m_lines++;
   obj.SetFlagBack(true,false);
   obj.SetFlagSelectable(false,false);
   obj.SetTooltip("\n");
   obj.SetFlagRayRight(false);
   obj.SetTime(t1,0);
   obj.SetPrice(p1,0);
   obj.SetTime(t2,1);
   obj.SetPrice(p2,1);
   obj.SetColor(colour);
   obj.SetWidth(width);
   obj.SetStyle(style);
   this.AddChild(obj);
   return true;
  }
 bool CPivotPatternShape::AddText(const datetime t,const double p,const string text,const color colour,const ENUM_ANCHOR_POINT anchor)
  {
   if(this.m_texts>=PIVOT_SHAPE_TEXTS)
      return false;
   CGStdTextObj *obj=&this.m_text[this.m_texts];
   if(!obj.Create(this.m_shape_chart,0,this.m_base+"_text"+(string)this.m_texts))
      return false;
   this.m_texts++;
   obj.SetFlagBack(true,false);
   obj.SetFlagSelectable(false,false);
   obj.SetTooltip("\n");
   obj.SetFont(DEF_FONT);
   obj.SetFontSize(DEF_FONT_SIZE);
   obj.SetTime(t,0);
   obj.SetPrice(p,0);
   obj.SetText(text);
   obj.SetColor(colour);
   obj.SetAnchor(anchor);
   this.AddChild(obj);
   return true;
  }
 bool CPivotPatternShape::Create(const long chart_id,const string name,const ENUM_BAR_INFOR_TYPE type,const long &times[],const double &prices[],
                                 const bool &highs[],const bool is_buy,const string title)
  {
   const int n=::ArraySize(times);
   if(n<3 || ::ArraySize(prices)!=n || ::ArraySize(highs)!=n)
      return false;
   this.m_shape_chart=chart_id;
   this.m_base=name;
   this.SetName(name);
   this.SetChartID(chart_id);
   const color side_colour=(is_buy ? clrDodgerBlue : clrRed);
   const color level_colour=clrGoldenrod;
   datetime t[];
   ::ArrayResize(t,n);
   for(int k=0;k<n;k++)
      t[k]=(datetime)times[k];
   //--- The letters / names of the pivots: above a high, below a low
   string letters[];
   string text="X,A,B,C,D";
   switch(type)
     {
      case BAR_INFOR_TYPE_AB_CD:              text="A,B,C,D";                    break;
      case BAR_INFOR_TYPE_THREE_DRIVES:
      case BAR_INFOR_TYPE_FIVE_DRIVES:        text="A,B,C,D,E,F";                break;
      case BAR_INFOR_TYPE_HEAD_SHOULDERS:     text="LS,,HEAD,,RS";               break;
      case BAR_INFOR_TYPE_DOUBLE_TOP_BOTTOM:  text="1,,2";                       break;
      case BAR_INFOR_TYPE_QUASIMODO:          text="Left Shoulder,Leg,Head,BOS"; break;
      default:                                break;
     }
   ::StringSplit(text,',',letters);
   switch(type)
     {
      case BAR_INFOR_TYPE_HEAD_SHOULDERS:
        {
         //--- 13. 17618: the neckline through the troughs, a triangle for each shoulder and the head on it, the legs, the names
         const double slope=(t[3]!=t[1] ? (prices[3]-prices[1])/(double)((long)t[3]-(long)t[1]) : 0.0);
         const double neck_ls=prices[1]+slope*(double)((long)t[0]-(long)t[1]);
         const double neck_rs=prices[1]+slope*(double)((long)t[4]-(long)t[1]);
         this.AddTriangle(t[0],prices[0],t[1],prices[1],t[0],neck_ls,side_colour);
         this.AddTriangle(t[2],prices[2],t[1],prices[1],t[3],prices[3],side_colour);
         this.AddTriangle(t[4],prices[4],t[3],prices[3],t[4],neck_rs,side_colour);
         for(int k=0;k<n-1;k++)
            this.AddLine(t[k],prices[k],t[k+1],prices[k+1],side_colour,2,STYLE_SOLID);
         this.AddLine(t[0],neck_ls,t[4],neck_rs,level_colour,2,STYLE_SOLID);
         this.AddText((datetime)((long)t[1]+((long)t[3]-(long)t[1])/2),(prices[1]+prices[3])/2.0,"NECKLINE",level_colour,(highs[0] ? ANCHOR_UPPER : ANCHOR_LOWER));
         break;
        }
      case BAR_INFOR_TYPE_DOUBLE_TOP_BOTTOM:
        {
         //--- 53. 23576: the two legs, the neckline at the pivot between them
         this.AddLine(t[0],prices[0],t[1],prices[1],side_colour,2,STYLE_SOLID);
         this.AddLine(t[1],prices[1],t[2],prices[2],side_colour,2,STYLE_SOLID);
         this.AddLine(t[0],prices[1],t[2],prices[1],level_colour,1,STYLE_DASH);
         this.AddText(t[0],prices[1],"Neckline",level_colour,(highs[2] ? ANCHOR_RIGHT_UPPER : ANCHOR_RIGHT_LOWER));
         break;
        }
      case BAR_INFOR_TYPE_QUASIMODO:
        {
         //--- 49. 23141: the legs, the broken leg (dotted) and the QM line at the shoulder (dashed)
         for(int k=0;k<n-1;k++)
            this.AddLine(t[k],prices[k],t[k+1],prices[k+1],side_colour,2,STYLE_SOLID);
         this.AddLine(t[1],prices[1],t[3],prices[1],side_colour,1,STYLE_DOT);
         this.AddLine(t[0],prices[0],t[3],prices[0],level_colour,1,STYLE_DASH);
         this.AddText(t[3],prices[0]," QM line",level_colour,ANCHOR_LEFT);
         break;
        }
      case BAR_INFOR_TYPE_AB_CD:
        {
         //--- 30. 19442: the triangles A B C and B C D, the legs
         this.AddTriangle(t[0],prices[0],t[1],prices[1],t[2],prices[2],side_colour);
         this.AddTriangle(t[1],prices[1],t[2],prices[2],t[3],prices[3],side_colour);
         for(int k=0;k<n-1;k++)
            this.AddLine(t[k],prices[k],t[k+1],prices[k+1],clrBlack,2,STYLE_SOLID);
         break;
        }
      case BAR_INFOR_TYPE_THREE_DRIVES:
      case BAR_INFOR_TYPE_FIVE_DRIVES:
        {
         //--- 31. 19449, 32. 19463: the triangles B C D and D E F, the legs
         this.AddTriangle(t[1],prices[1],t[2],prices[2],t[3],prices[3],side_colour);
         this.AddTriangle(t[3],prices[3],t[4],prices[4],t[5],prices[5],side_colour);
         for(int k=0;k<n-1;k++)
            this.AddLine(t[k],prices[k],t[k+1],prices[k+1],clrBlack,2,STYLE_SOLID);
         break;
        }
      default:
        {
         //--- X A B C D (08, 15, 27, 28, 29, 33): the triangles X A B and B C D, the legs, X B and B D
         this.AddTriangle(t[0],prices[0],t[1],prices[1],t[2],prices[2],side_colour);
         this.AddTriangle(t[2],prices[2],t[3],prices[3],t[4],prices[4],side_colour);
         for(int k=0;k<n-1;k++)
            this.AddLine(t[k],prices[k],t[k+1],prices[k+1],clrBlack,2,STYLE_SOLID);
         this.AddLine(t[0],prices[0],t[2],prices[2],clrBlack,2,STYLE_SOLID);
         this.AddLine(t[2],prices[2],t[4],prices[4],clrBlack,2,STYLE_SOLID);
         break;
        }
     }
   //--- The letters of the pivots, then the name of the pattern in the middle (15. 17865: between X and B, at the price of the last pivot)
   for(int k=0;k<n && k<::ArraySize(letters);k++)
      if(letters[k]!="")
         this.AddText(t[k],prices[k],letters[k],(type>=BAR_INFOR_TYPE_HEAD_SHOULDERS ? side_colour : clrBlack),(highs[k] ? ANCHOR_LOWER : ANCHOR_UPPER));
   this.AddText((datetime)((long)t[0]+((long)t[n/2]-(long)t[0])/2),prices[n-1],title,clrBlack,ANCHOR_CENTER);
   return (this.m_triangles+this.m_lines+this.m_texts>0);
  }
#endif // CPIVOTPATTERNSHAPE_COMPOSITE_IMPLEMENTATION
#endif // __PIVOTPATTERNSHAPE_COMPOSITE_MQH__
