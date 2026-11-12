//+------------------------------------------------------------------+
//|                                           TradingLevelBubble.mqh |
//+------------------------------------------------------------------+
#ifndef __TRADING_LEVEL_BUBBLE_COMPOSITE_MQH__
#define __TRADING_LEVEL_BUBBLE_COMPOSITE_MQH__
 #include "..\..\GBases\GBaseObj.mqh"
 #include "..\Standard\GStdTrendObj.mqh"
 #include "..\Standard\GStdTriangleObj.mqh"
 #include "..\Standard\GStdRectangleLabelObj.mqh"
 #include "..\..\Controls\Button.mqh"
 #include "..\..\..\Services\Colors.mqh"
 #include "..\..\..\Collections\MarketCollection.mqh"
 //+------------------------------------------------------------------+
 //| Which SL/TP level a bubble represents                            |
 //+------------------------------------------------------------------+
 enum ENUM_BUBBLE_TYPE
  {
    BUBBLE_SL_BUY  = 0,
    BUBBLE_TP_BUY  = 1,
    BUBBLE_SL_SELL = 2,
    BUBBLE_TP_SELL = 3,
    BUBBLE_TOTAL   = 4
  };
 //--- Geometry
  #define BUBBLE_TIP_W       18    // triangle tip width
  #define BUBBLE_BDY_W       155   // body width
  #define BUBBLE_BDY_H       52    // body height
  #define BUBBLE_XSZ         18    // X close button size
  #define BUBBLE_RPAD        52    // right padding from the chart edge to the tip (fallback)
  #define BUBBLE_LOOKAHEAD   30    // gap between the last bar and the tip
  #define BUBBLE_BDR_W       3     // border thickness
  #define BUBBLE_LINE_GRAB   4     // half height of the draggable band around the level line
 //--- Colors
  #define BUBBLE_CLR_BG         clrWhiteSmoke
  #define BUBBLE_CLR_BUY        clrMediumSeaGreen
  #define BUBBLE_CLR_SELL       clrCrimson
  #define BUBBLE_CLR_PROFIT_POS clrLimeGreen
  #define BUBBLE_CLR_PROFIT_NEG clrTomato
#ifndef CTRADING_LEVEL_BUBBLE_COMPOSITE_DECLARATION
#define CTRADING_LEVEL_BUBBLE_COMPOSITE_DECLARATION
 //+------------------------------------------------------------------+
 //| One SL/TP level: dashed line + tip + body drawn with native      |
 //| objects, X button and texts are controls. Moving it = a few      |
 //| property sets, nothing is redrawn. It takes its level from the   |
 //| positions itself, is dragged on the line only and reports press, |
 //| release and close with chart events (the trading side modifies)  |
 //+------------------------------------------------------------------+
 class CTradingLevelBubble : public CGBaseObj
  {
   private:
     ENUM_BUBBLE_TYPE         m_bubble_type;
     CGStdTrendObj            m_trend_line;
     CGStdTriangleObj         m_triangle_tip_border;
     CGStdTriangleObj         m_triangle_tip_fill;
     CGStdRectangleLabelObj   m_rectanglelabel_body_border;
     CGStdRectangleLabelObj   m_rectanglelabel_body_fill;
     CLabel                   m_label_level;
     CLabel                   m_label_pnl;
     CButton                  m_button_close;
     int                      m_bx;              // tip X in chart pixels
     int                      m_cy;              // level Y in chart pixels
     bool                     m_pinned;          // real level is off-screen
     bool                     m_line_shown;
     bool                     m_covered;         // a higher element covers the cursor
     bool                     m_hover;           // cursor on the line band
     bool                     m_dragging;
     bool                     m_prev_left;
     bool                     m_grab;            // chart scroll is off while the cursor is on the line
     bool                     m_saved_scroll;
     int                      m_drag_offset_y;
     bool                     m_pnl_positive;
     CMarketCollection       *m_market_collection;   // CTradingEngine owns
     double                   m_level;               // displayed level, sticky pick when positions disagree
     bool                     m_mixed;               // positions of the direction do not share this level
     int                      m_last_chart_w;
     int                      m_last_chart_h;
     bool                     Anchor(const int x,const int y,datetime &time,double &price);
     void                     PlaceTriangle(CGStdTriangleObj &tri,const int x0,const int y0,const int x1,const int y1,const int x2,const int y2);
     void                     PlaceLine(void);
     bool                     InLineBand(const int x,const int y) const;
     void                     UpdateText(CLabel &label,const string text);
     void                     MoveTo(const int center_y,const int bx,const bool pinned);
     void                     SetTexts(const string label,const string pnl_text,const bool pnl_positive);
     void                     UpdateTexts(const double price,const bool pinned);
     string                   ChartSymbol(void)                  const { return ::ChartSymbol(this.ChartID()); }
     double                   ResolveLevel(void);
     double                   FloatingProfitAt(const double target_price);
     double                   DragPrice(void);
     int                      PriceToY(const double price);
     int                      ClampY(const int y,bool &pinned);
     int                      AnchorBX(void);
     string                   LevelLabel(const double price);
     void                     SetGrab(const bool on);
     void                     Notify(const ushort event_id,const double dparam);
   public:
     bool                     Create(const long chart_id,const int subwin,const ENUM_BUBBLE_TYPE type);
     void                     SetSources(CMarketCollection *market)   { this.m_market_collection=market; }
     void                     Refresh(void);
     void                     Show(void);
     void                     Hide(void);
     ENUM_BUBBLE_TYPE         BubbleType(void)                   const { return this.m_bubble_type;  }
     int                      CenterY(void)                      const { return this.m_cy;           }
     virtual void             SetCovered(const bool covered)           { this.m_covered=covered;     }
     virtual void             OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     virtual void             OnTimerEvent(void);
                              CTradingLevelBubble(void);
                             ~CTradingLevelBubble(void);
  };
#endif // CTRADING_LEVEL_BUBBLE_COMPOSITE_DECLARATION
#ifndef CTRADING_LEVEL_BUBBLE_COMPOSITE_IMPLEMENTATION
#define CTRADING_LEVEL_BUBBLE_COMPOSITE_IMPLEMENTATION
 CTradingLevelBubble::CTradingLevelBubble(void) : m_bubble_type(BUBBLE_SL_BUY),m_bx(0),m_cy(0),m_pinned(false),
                                                  m_line_shown(false),m_covered(false),m_hover(false),m_dragging(false),m_prev_left(false),m_grab(false),
                                                  m_saved_scroll(true),m_drag_offset_y(0),m_pnl_positive(true),
                                                  m_market_collection(NULL),m_level(0),m_mixed(false),m_last_chart_w(0),m_last_chart_h(0)
  {
  }
 CTradingLevelBubble::~CTradingLevelBubble(void)
  {
   this.SetGrab(false);
  }
 //--- Born hidden: shown by the caller once a position has this level
 bool CTradingLevelBubble::Create(const long chart_id,const int subwin,const ENUM_BUBBLE_TYPE type)
  {
   this.m_bubble_type=type;
   bool is_sl =(type==BUBBLE_SL_BUY || type==BUBBLE_SL_SELL);
   bool is_buy=(type==BUBBLE_SL_BUY || type==BUBBLE_TP_BUY);
   color border_clr=(is_sl  ? BUBBLE_CLR_SELL : BUBBLE_CLR_BUY);
   color label_clr =(is_buy ? BUBBLE_CLR_BUY  : BUBBLE_CLR_SELL);
   color chart_bg  =(color)::ChartGetInteger(chart_id,CHART_COLOR_BACKGROUND);
   string base="TradingBubble_"+(string)(int)type;
   this.SetName(base);
   this.SetChartID(chart_id);
   this.m_subwindow=subwin;
   this.m_visible=false;
   //--- Native shell, created back to front
   if(!this.m_trend_line.Create(chart_id,subwin,base+"_line") ||
      !this.m_triangle_tip_border.Create(chart_id,subwin,base+"_tipb") ||
      !this.m_triangle_tip_fill.Create(chart_id,subwin,base+"_tipf") ||
      !this.m_rectanglelabel_body_border.Create(chart_id,subwin,base+"_bodyb") ||
      !this.m_rectanglelabel_body_fill.Create(chart_id,subwin,base+"_bodyf"))
      return false;
   this.m_trend_line.SetStyle(STYLE_SOLID);
   this.m_trend_line.SetColor(CColors::MixColors(chart_bg,border_clr,180/255.0));
   this.m_triangle_tip_border.SetFlagFill(true);
   this.m_triangle_tip_border.SetColor(border_clr);
   this.m_triangle_tip_fill.SetFlagFill(true);
   this.m_triangle_tip_fill.SetColor(BUBBLE_CLR_BG);
   this.m_rectanglelabel_body_border.SetBorderType(BORDER_FLAT);
   this.m_rectanglelabel_body_border.SetColor(border_clr);
   this.m_rectanglelabel_body_border.SetBGColor(border_clr);
   this.m_rectanglelabel_body_fill.SetBorderType(BORDER_FLAT);
   this.m_rectanglelabel_body_fill.SetColor(BUBBLE_CLR_BG);
   this.m_rectanglelabel_body_fill.SetBGColor(BUBBLE_CLR_BG);
   this.m_trend_line.SetFlagSelectable(false,false);
   this.m_triangle_tip_border.SetFlagSelectable(false,false);
   this.m_triangle_tip_fill.SetFlagSelectable(false,false);
   this.m_rectanglelabel_body_border.SetFlagSelectable(false,false);
   this.m_rectanglelabel_body_fill.SetFlagSelectable(false,false);
   this.m_trend_line.SetTooltip("\n");
   this.m_triangle_tip_border.SetTooltip("\n");
   this.m_triangle_tip_fill.SetTooltip("\n");
   this.m_rectanglelabel_body_border.SetTooltip("\n");
   this.m_rectanglelabel_body_fill.SetTooltip("\n");
   this.m_trend_line.SetVisibleFlag(false,false);
   this.m_triangle_tip_border.SetVisibleFlag(false,false);
   this.m_triangle_tip_fill.SetVisibleFlag(false,false);
   this.m_rectanglelabel_body_border.SetVisibleFlag(false,false);
   this.m_rectanglelabel_body_fill.SetVisibleFlag(false,false);
   //--- Controls above the shell
   this.m_label_level.Hide();
   this.m_label_pnl.Hide();
   this.m_button_close.Hide();
   if(!this.m_label_level.Create(chart_id,subwin,base+"_label",0,0,BUBBLE_BDY_W-8,24) ||
      !this.m_label_pnl.Create(chart_id,subwin,base+"_pnl",0,0,BUBBLE_BDY_W-8,24) ||
      !this.m_button_close.Create(chart_id,subwin,base+"_x",0,0,BUBBLE_XSZ+1,BUBBLE_XSZ+1))
      return false;
   this.m_label_level.IsAvailable(false);
   this.m_label_pnl.IsAvailable(false);
   this.m_label_level.LabelXGap(0);
   this.m_label_pnl.LabelXGap(0);
   this.m_label_level.GetForeColorControl().InitColors(label_clr);
   this.m_label_level.GetForeColorControl().SetCurrentAs(COLOR_STATE_DEFAULT);
   this.m_label_pnl.GetForeColorControl().InitColors(BUBBLE_CLR_PROFIT_POS);
   this.m_label_pnl.GetForeColorControl().SetCurrentAs(COLOR_STATE_DEFAULT);
   this.m_button_close.GetBackColorControl().InitColors(clrFireBrick);
   this.m_button_close.GetBackColorControl().SetCurrentAs(COLOR_STATE_DEFAULT);
   this.m_button_close.GetBorderColorControl().InitColors(clrFireBrick);
   this.m_button_close.GetBorderColorControl().SetCurrentAs(COLOR_STATE_DEFAULT);
   this.m_button_close.GetForeColorControl().InitColors(clrWhite);
   this.m_button_close.GetForeColorControl().SetCurrentAs(COLOR_STATE_DEFAULT);
   this.m_button_close.SetText("X");
   this.m_label_level.Draw(false);
   this.m_label_pnl.Draw(false);
   this.m_button_close.Draw(false);
   this.AddChild(&this.m_trend_line);
   this.AddChild(&this.m_triangle_tip_border);
   this.AddChild(&this.m_triangle_tip_fill);
   this.AddChild(&this.m_rectanglelabel_body_border);
   this.AddChild(&this.m_rectanglelabel_body_fill);
   this.AddChild(&this.m_label_level);
   this.AddChild(&this.m_label_pnl);
   this.AddChild(&this.m_button_close);
   return true;
  }
 bool CTradingLevelBubble::Anchor(const int x,const int y,datetime &time,double &price)
  {
   int sub=0;
   return ::ChartXYToTimePrice(this.ChartID(),x,y,sub,time,price);
  }
 //--- Pixel corners -> time/price of the three points
 void CTradingLevelBubble::PlaceTriangle(CGStdTriangleObj &tri,const int x0,const int y0,const int x1,const int y1,const int x2,const int y2)
  {
   int xs[3],ys[3];
   xs[0]=x0; ys[0]=y0;
   xs[1]=x1; ys[1]=y1;
   xs[2]=x2; ys[2]=y2;
   for(int k=0; k<3; k++)
     {
      datetime t; double p;
      if(!this.Anchor(xs[k],ys[k],t,p))
         continue;
      tri.SetTime(t,k);
      tri.SetPrice(p,k);
     }
  }
 //--- Level line: from the tip to the chart's left edge, re-placed on every chart change
 void CTradingLevelBubble::PlaceLine(void)
  {
   datetime t_tip,t_left; double p,p_left;
   if(!this.Anchor(this.m_bx,this.m_cy,t_tip,p) || !this.Anchor(0,this.m_cy,t_left,p_left))
      return;
   this.m_trend_line.SetTime(t_tip,0);
   this.m_trend_line.SetPrice(p,0);
   this.m_trend_line.SetTime(t_left,1);
   this.m_trend_line.SetPrice(p,1);
  }
 void CTradingLevelBubble::UpdateText(CLabel &label,const string text)
  {
   if(label.Text()==text)
      return;
   label.SetText(text);
   label.Draw(false);
  }
 //--- Shell and controls from pixels: tip x, level y
 void CTradingLevelBubble::MoveTo(const int center_y,const int bx,const bool pinned)
  {
   this.m_bx    =(bx<0 ? 0 : bx);
   this.m_cy    =center_y;
   this.m_pinned=pinned;
   const int half  =BUBBLE_BDY_H/2;
   const int x_body=this.m_bx+BUBBLE_TIP_W;
   const int x_end =x_body+BUBBLE_BDY_W;
   this.PlaceTriangle(this.m_triangle_tip_border,this.m_bx,center_y,x_body,center_y-half,x_body,center_y+half);
   this.PlaceTriangle(this.m_triangle_tip_fill,this.m_bx+BUBBLE_BDR_W,center_y,x_body,center_y-half+BUBBLE_BDR_W,x_body,center_y+half-BUBBLE_BDR_W);
   this.m_rectanglelabel_body_border.SetXDistance(x_body);
   this.m_rectanglelabel_body_border.SetYDistance(center_y-half);
   this.m_rectanglelabel_body_border.SetXSize(BUBBLE_BDY_W+1);
   this.m_rectanglelabel_body_border.SetYSize(BUBBLE_BDY_H+1);
   this.m_rectanglelabel_body_fill.SetXDistance(x_body);
   this.m_rectanglelabel_body_fill.SetYDistance(center_y-half+BUBBLE_BDR_W);
   this.m_rectanglelabel_body_fill.SetXSize(BUBBLE_BDY_W-BUBBLE_BDR_W+1);
   this.m_rectanglelabel_body_fill.SetYSize(BUBBLE_BDY_H-2*BUBBLE_BDR_W+1);
   this.m_button_close.Move(x_end-BUBBLE_XSZ-4,center_y-BUBBLE_XSZ/2);
   this.m_label_level.Move(x_body+8,center_y-24);
   this.m_label_pnl.Move(x_body+8,center_y);
   if(!pinned)
      this.PlaceLine();
   bool show_line=(this.m_visible && !pinned);
   if(show_line!=this.m_line_shown)
     {
      this.m_line_shown=show_line;
      this.m_trend_line.SetVisibleFlag(show_line,false);
     }
  }
 void CTradingLevelBubble::SetTexts(const string label,const string pnl_text,const bool pnl_positive)
  {
   this.UpdateText(this.m_label_level,label);
   if(pnl_positive!=this.m_pnl_positive)
     {
      this.m_pnl_positive=pnl_positive;
      this.m_label_pnl.GetForeColorControl().InitColors(pnl_positive ? BUBBLE_CLR_PROFIT_POS : BUBBLE_CLR_PROFIT_NEG);
      this.m_label_pnl.GetForeColorControl().SetCurrentAs(COLOR_STATE_DEFAULT);
      this.m_label_pnl.SetText("");
     }
   this.UpdateText(this.m_label_pnl,pnl_text);
  }
  //--- One level for the whole direction: sticky when positions disagree, 'mixed' flags it
 double CTradingLevelBubble::ResolveLevel(void)
  {
   this.m_mixed=false;
   if(this.m_market_collection==NULL)
      return 0;
   ENUM_POSITION_TYPE dir=(this.m_bubble_type<=BUBBLE_TP_BUY ? POSITION_TYPE_BUY : POSITION_TYPE_SELL);
   bool is_sl=(this.m_bubble_type==BUBBLE_SL_BUY || this.m_bubble_type==BUBBLE_SL_SELL);
   CArrayObj *list=this.m_market_collection.GetList();   // filtered inline - no Select per mouse move
   int total=(list!=NULL ? list.Total() : 0);
   string sym=this.ChartSymbol();
   double point=::SymbolInfoDouble(sym,SYMBOL_POINT);
   double levels[]; int counts[];
   int distinct=0,without=0;
   for(int i=0; i<total; i++)
     {
      COrder *pos=list.At(i);
      if(pos==NULL || pos.Status()!=ORDER_STATUS_MARKET_POSITION || pos.Symbol()!=sym || pos.TypeOrder()!=(long)dir)
         continue;
      double lv=(is_sl ? pos.StopLoss() : pos.TakeProfit());
      if(lv<=0) { without++; continue; }
      int k=0;
      for(; k<distinct; k++)
         if(::MathAbs(levels[k]-lv)<point/2)
            break;
      if(k==distinct)
        {
         ::ArrayResize(levels,distinct+1);
         ::ArrayResize(counts,distinct+1);
         levels[distinct]=lv;
         counts[distinct]=0;
         distinct++;
        }
      counts[k]++;
     }
   if(distinct==0)
      return 0;
   this.m_mixed=(distinct>1 || without>0);
   if(distinct==1)
      return levels[0];
   for(int k=0; k<distinct; k++)
      if(::MathAbs(levels[k]-this.m_level)<point/2)
         return levels[k];
   int best=0;
   for(int k=1; k<distinct; k++)
      if(counts[k]>counts[best])
         best=k;
   return levels[best];
  }
 //--- Money if every position of the direction closed at target_price
 double CTradingLevelBubble::FloatingProfitAt(const double target_price)
  {
   if(this.m_market_collection==NULL)
      return 0;
   ENUM_POSITION_TYPE dir=(this.m_bubble_type<=BUBBLE_TP_BUY ? POSITION_TYPE_BUY : POSITION_TYPE_SELL);
   CArrayObj *list=this.m_market_collection.GetList();
   int total=(list!=NULL ? list.Total() : 0);
   string sym=this.ChartSymbol();
   double sum=0;
   for(int i=0; i<total; i++)
     {
      COrder *pos=list.At(i);
      if(pos==NULL || pos.Status()!=ORDER_STATUS_MARKET_POSITION || pos.Symbol()!=sym || pos.TypeOrder()!=(long)dir)
         continue;
      double p=0;
      if(::OrderCalcProfit((ENUM_ORDER_TYPE)dir,sym,pos.Volume(),pos.PriceOpen(),target_price,p))
         sum+=p;
     }
   return sum;
  }
 //--- Price under the bubble's own tip, read from the chart now
 double CTradingLevelBubble::DragPrice(void)
  {
   datetime t; double price;
   if(this.Anchor(this.m_bx,this.m_cy,t,price) && price>0)
      return price;
   return this.m_level;
  }
 //--- INT_MIN = mapping failed; a negative y is a valid off-screen level
 int CTradingLevelBubble::PriceToY(const double price)
  {
   int x,y;
   datetime t=::iTime(this.ChartSymbol(),(ENUM_TIMEFRAMES)::ChartPeriod(this.ChartID()),0);
   if(!::ChartTimePriceToXY(this.ChartID(),0,t,price,x,y))
      return INT_MIN;
   return y;
  }
 //--- Off-screen levels are pinned to the top/bottom edge
 int CTradingLevelBubble::ClampY(const int y,bool &pinned)
  {
   int half=BUBBLE_BDY_H/2+2;
   int hi  =(int)::ChartGetInteger(this.ChartID(),CHART_HEIGHT_IN_PIXELS)-half;
   pinned=(y<half || y>hi);
   return (y<half ? half : y>hi ? hi : y);
  }
 //--- The last bar's X + a look-ahead gap, never past the chart's right edge
 int CTradingLevelBubble::AnchorBX(void)
  {
   int chart_w=(int)::ChartGetInteger(this.ChartID(),CHART_WIDTH_IN_PIXELS);
   int max_bx =chart_w-BUBBLE_RPAD-BUBBLE_TIP_W-BUBBLE_BDY_W;
   int last_x,dummy_y;
   datetime t0=::iTime(this.ChartSymbol(),(ENUM_TIMEFRAMES)::ChartPeriod(this.ChartID()),0);
   bool got_x=(t0>0 && ::ChartTimePriceToXY(this.ChartID(),0,t0,1.0,last_x,dummy_y));
   int bx=(got_x ? last_x+BUBBLE_LOOKAHEAD : max_bx);
   return (bx>max_bx ? max_bx : bx);
  }
 string CTradingLevelBubble::LevelLabel(const double price)
  {
   string prefix=(this.m_bubble_type==BUBBLE_SL_BUY ? "SL Buy  " : this.m_bubble_type==BUBBLE_TP_BUY ? "TP Buy  " : this.m_bubble_type==BUBBLE_SL_SELL ? "SL Sell " : "TP Sell ");
   return prefix+::DoubleToString(price,(int)::SymbolInfoInteger(this.ChartSymbol(),SYMBOL_DIGITS));
  }
 //--- Level text (arrow when pinned, star when mixed) and the money at that level
 void CTradingLevelBubble::UpdateTexts(const double price,const bool pinned)
  {
   string arrow=(pinned ? (this.m_cy<=(int)::ChartGetInteger(this.ChartID(),CHART_HEIGHT_IN_PIXELS)/2 ? ::ShortToString(0x25B2)+" " : ::ShortToString(0x25BC)+" ") : "");
   string star =(this.m_mixed && !this.m_dragging ? "* " : "");
   double pnl  =this.FloatingProfitAt(price);
   this.SetTexts(arrow+star+this.LevelLabel(price),(pnl>=0 ? "+" : "")+::DoubleToString(pnl,2)+" $",pnl>=0);
  }
 //--- Level from the positions, then placed/shown/hidden; while dragged the bubble keeps the cursor's place
 void CTradingLevelBubble::Refresh(void)
  {
   if(this.m_market_collection==NULL || this.m_dragging)
      return;
   this.m_level=this.ResolveLevel();
   int y=(this.m_level>0 ? this.PriceToY(this.m_level) : INT_MIN);
   if(y==INT_MIN)
     {
      this.Hide();
      return;
     }
   bool pinned=false;
   y=this.ClampY(y,pinned);
   this.MoveTo(y,this.AnchorBX(),pinned);
   this.UpdateTexts(this.m_level,pinned);
   this.Show();
  }
 //--- The parent reads the type from lparam; the price (release) or the level Y from dparam
 void CTradingLevelBubble::Notify(const ushort event_id,const double dparam)
  {
   ::EventChartCustom(this.ChartID(),event_id,(long)this.m_bubble_type,dparam,"");
  }
 //--- Hovering the line: the chart must not scroll or autoscroll under the cursor
 void CTradingLevelBubble::SetGrab(const bool on)
  {
   if(on==this.m_grab)
      return;
   this.m_grab=on;
   if(on)
     {
      this.m_saved_scroll=(bool)::ChartGetInteger(this.ChartID(),CHART_MOUSE_SCROLL);
      ::ChartSetInteger(this.ChartID(),CHART_MOUSE_SCROLL,false);
      ::ChartSetInteger(this.ChartID(),CHART_AUTOSCROLL,false);
     }
   else
     {
      ::ChartSetInteger(this.ChartID(),CHART_MOUSE_SCROLL,this.m_saved_scroll);
      ::ChartSetInteger(this.ChartID(),CHART_AUTOSCROLL,true);
     }
  }
 void CTradingLevelBubble::Show(void)
  {
   if(this.m_visible)
      return;
   this.m_visible=true;
   this.m_triangle_tip_border.SetVisibleFlag(true,false);
   this.m_triangle_tip_fill.SetVisibleFlag(true,false);
   this.m_rectanglelabel_body_border.SetVisibleFlag(true,false);
   this.m_rectanglelabel_body_fill.SetVisibleFlag(true,false);
   this.m_line_shown=!this.m_pinned;
   this.m_trend_line.SetVisibleFlag(this.m_line_shown,false);
   this.m_label_level.Show();
   this.m_label_pnl.Show();
   this.m_button_close.Show();
   ::EventChartCustom(this.ChartID(),ON_BRING_TO_TOP,0,0,"");   // it landed on top of the windows
  }
 void CTradingLevelBubble::Hide(void)
  {
   if(!this.m_visible)
      return;
   this.m_visible=false;
   this.m_hover=false;
   this.m_dragging=false;
   this.SetGrab(false);
   this.m_line_shown=false;
   this.m_trend_line.SetVisibleFlag(false,false);
   this.m_triangle_tip_border.SetVisibleFlag(false,false);
   this.m_triangle_tip_fill.SetVisibleFlag(false,false);
   this.m_rectanglelabel_body_border.SetVisibleFlag(false,false);
   this.m_rectanglelabel_body_fill.SetVisibleFlag(false,false);
   this.m_label_level.Hide();
   this.m_label_pnl.Hide();
   this.m_button_close.Hide();
  }
 //--- Left of the tip, within the grab band around the level line
 bool CTradingLevelBubble::InLineBand(const int x,const int y) const
  {
   return (this.m_visible && !this.m_pinned && !this.m_covered && x<this.m_bx && ::MathAbs(y-this.m_cy)<=BUBBLE_LINE_GRAB);
  }
 //--- Scroll/zoom/new bar and trade events refresh it; X button -> close event; the line drag moves it
 void CTradingLevelBubble::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   for(int i=0; i<this.ChildrenTotal(); i++)
      this.Child(i).OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      this.Refresh();
      return;
     }
   if(id>=CHARTEVENT_CUSTOM)
     {
      ushort ev=(ushort)(id-CHARTEVENT_CUSTOM);
      if(ev==(ushort)ON_BUBBLE_RESTORE)
        {
         this.Refresh();
         return;
        }
      if(ev==(ushort)TRADE_EVENT_MODIFY_POSITION_SL            || ev==(ushort)TRADE_EVENT_MODIFY_POSITION_TP            ||
         ev==(ushort)TRADE_EVENT_MODIFY_POSITION_SL_TP         || ev==(ushort)TRADE_EVENT_POSITION_OPENED               ||
         ev==(ushort)TRADE_EVENT_POSITION_CLOSED               || ev==(ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL       ||
         ev==(ushort)TRADE_EVENT_POSITION_CLOSED_BY_SL         || ev==(ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL ||
         ev==(ushort)TRADE_EVENT_POSITION_CLOSED_BY_TP         || ev==(ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP ||
         ev==(ushort)TRADE_EVENT_POSITION_CLOSED_BY_POS        || ev==(ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS)
        {
         this.Refresh();
         return;
        }
     }
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      if(this.m_visible && lparam==(long)this.m_button_close.ObjectID())
         this.Notify(ON_BUBBLE_CLOSE,this.m_cy);
      return;
     }
   if(id!=CHARTEVENT_MOUSE_MOVE || !this.m_visible)
      return;
   int  x   =(int)lparam;
   int  y   =(int)dparam;
   bool left=((((int)::StringToInteger(sparam))&MOUSE_BUTT_KEY_STATE_LEFT)!=0);
   if(this.m_dragging)
     {
      if(left)
        {
         int half=BUBBLE_BDY_H/2+2;
         int hi  =(int)::ChartGetInteger(this.ChartID(),CHART_HEIGHT_IN_PIXELS)-half;
         int cy  =y-this.m_drag_offset_y;
         cy=(cy<half ? half : cy>hi ? hi : cy);
         this.MoveTo(cy,this.m_bx,false);
         this.UpdateTexts(this.DragPrice(),false);
         ::ChartRedraw(this.ChartID());
        }
      else
        {
         this.m_dragging=false;
         this.SetGrab(false);
         this.Notify(ON_BUBBLE_RELEASE,this.DragPrice());
        }
     }
   else
     {
      bool in_band=this.InLineBand(x,y);
      this.m_hover=in_band;
      this.SetGrab(in_band);
      if(in_band && left && !this.m_prev_left)
        {
         this.m_dragging=true;
         this.m_drag_offset_y=y-this.m_cy;
         this.Notify(ON_BUBBLE_PRESS,this.m_cy);
        }
     }
   this.m_prev_left=left;
  }
 void CTradingLevelBubble::OnTimerEvent(void)
  {
   for(int i=0; i<this.ChildrenTotal(); i++)
      this.Child(i).OnTimerEvent();
   //--- Chart resize has no event of its own
   int w=(int)::ChartGetInteger(this.ChartID(),CHART_WIDTH_IN_PIXELS);
   int h=(int)::ChartGetInteger(this.ChartID(),CHART_HEIGHT_IN_PIXELS);
   if(w==this.m_last_chart_w && h==this.m_last_chart_h)
      return;
   this.m_last_chart_w=w;
   this.m_last_chart_h=h;
   this.Refresh();
  }
#endif // CTRADING_LEVEL_BUBBLE_COMPOSITE_IMPLEMENTATION
#endif // __TRADING_LEVEL_BUBBLE_COMPOSITE_MQH__
