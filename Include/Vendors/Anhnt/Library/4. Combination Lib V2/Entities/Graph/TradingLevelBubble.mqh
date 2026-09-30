//+------------------------------------------------------------------+
//|                                           TradingLevelBubble.mqh |
//|Topic link https://www.mql5.com/en/articles/20892                 |
//|Topic link https://www.mql5.com/en/articles/3236                  |
//+------------------------------------------------------------------+
#ifndef __TRADING_LEVEL_BUBBLE_MQH__
#define __TRADING_LEVEL_BUBBLE_MQH__
 #include "..\GBases\GElement.mqh"
 #include "..\..\Collections\MarketCollection.mqh"
 #include "..\..\Trading\TradingExecution\TradingControl.mqh"
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
  #define BUBBLE_X_PAD       4     // extra clickable margin around the X button
 //--- Colors
  #define BUBBLE_CLR_BG         clrWhiteSmoke
  #define BUBBLE_CLR_BUY        clrMediumSeaGreen
  #define BUBBLE_CLR_SELL       clrCrimson
  #define BUBBLE_CLR_PROFIT_POS clrLimeGreen
  #define BUBBLE_CLR_PROFIT_NEG clrTomato
 //--- Press zones on a bubble
  #define BUBBLE_ZONE_NONE   0
  #define BUBBLE_ZONE_LINE   1
  #define BUBBLE_ZONE_CLOSE  2
 class CTradingLevelBubbles;
#ifndef CTRADING_LEVEL_BUBBLE_DECLARATION
#define CTRADING_LEVEL_BUBBLE_DECLARATION
 //+------------------------------------------------------------------+
 //| View: one bubble = level line + body, drag only on the line,     |
 //| X only clicks, the body ignores the mouse                         |
 //+------------------------------------------------------------------+
 class CTradingLevelBubble : public CGElement
  {
   private:
     ENUM_BUBBLE_TYPE     m_bubble_type;
     CTradingLevelBubbles *m_owner;
     int                  m_bx;              // tip X inside the canvas (canvas starts at chart x 0)
     bool                 m_pinned;          // real level is off-screen
     string               m_label;
     string               m_pnl_text;
     bool                 m_pnl_positive;
     bool                 m_covered;         // a higher element covers the cursor (set by the collection)
     int                  m_press_zone;
     int                  m_drag_offset_y;
     int                  ZoneAt(const int x,const int y);
   protected:
     virtual void         OnFocus(void);
     virtual void         OnBlur(void);
     virtual void         OnPress(const int x,const int y);
     virtual void         OnMove(const int x,const int y);
     virtual void         OnRelease(const int x,const int y);
   public:
     bool                 CreateBubble(const long chart_id,const int subwin,const ENUM_BUBBLE_TYPE type,CTradingLevelBubbles *owner);
     void                 SetLevel(const int center_y,const int bx,const bool pinned,const string label,const string pnl_text,const bool pnl_positive);
     ENUM_BUBBLE_TYPE     BubbleType(void)                   const { return this.m_bubble_type;          }
     int                  CenterY(void)                      const { return this.m_y+this.m_y_size/2;    }
     void                 SetCovered(const bool covered)           { this.m_covered=covered;             }
     virtual bool         CheckMouseFocus(const int x,const int y);
     virtual void         Draw(const bool chart_redraw);
                          CTradingLevelBubble(void);
                         ~CTradingLevelBubble(void) {}
  };
 //+------------------------------------------------------------------+
 //| Controller: levels of the chart Symbol's positions, one bubble   |
 //| per SL/TP of each direction, SL/TP overlap, trade actions         |
 //+------------------------------------------------------------------+
 class CTradingLevelBubbles : public CObject
  {
   private:
     long                 m_chart_id;
     CMarketCollection   *m_market_collection;   // CTradingEngine owns
     CTradingControl     *m_trading_control;     // CTradingEngine owns
     CTradingLevelBubble *m_bubble[BUBBLE_TOTAL]; // CGraphElementsCollection owns
     double               m_last[BUBBLE_TOTAL];   // displayed level, sticky pick when positions disagree
     bool                 m_mixed[BUBBLE_TOTAL];
     bool                 m_orig_chart_shift;
     int                  m_last_chart_w;
     int                  m_last_chart_h;
     bool                 m_restack_needed;       // a bubble was just shown: it landed on top of the windows
     //--- Drag state
     int                  m_drag_type;            // WRONG_VALUE = none
     int                  m_drag_center_y;
     int                  m_drag_bx;              // frozen at drag start
     int                  m_drag_anchor_y;
     double               m_drag_price_anchor;
     double               m_price_per_pixel;

     string               ChartSymbol(void)                  const { return ::ChartSymbol(this.m_chart_id); }
     double               ResolveLevel(const ENUM_POSITION_TYPE dir,const bool is_sl,const double prev,bool &mixed);
     double               FloatingProfitAt(const ENUM_POSITION_TYPE dir,const double target_price);
     double               DragPrice(void);
     int                  PriceToY(const double price);
     int                  ClampY(const int y,bool &pinned);
     int                  AnchorBX(void);
     void                 ResolveOverlap(int &ya,int &yb,const bool a_dragged,const bool b_dragged);
     string               BubbleLabel(const ENUM_BUBBLE_TYPE type,const double price);
     void                 PlaceDirection(const ENUM_BUBBLE_TYPE sl_type,const ENUM_BUBBLE_TYPE tp_type,const bool is_buy,const int bx);
   public:
     bool                 Create(const long chart_id,CMarketCollection *market,CTradingControl *trading_control);
     long                 ChartID(void)                      const { return this.m_chart_id;            }
     CTradingLevelBubble *Bubble(const int index)                  { return (index>=0 && index<BUBBLE_TOTAL ? this.m_bubble[index] : NULL); }
     void                 Refresh(void);
     bool                 TakeRestackRequest(void)                 { bool r=this.m_restack_needed; this.m_restack_needed=false; return r; }
     void                 OnBubblePress(const ENUM_BUBBLE_TYPE type);
     void                 OnBubbleMove(const ENUM_BUBBLE_TYPE type,const int center_y);
     void                 OnBubbleRelease(const ENUM_BUBBLE_TYPE type);
     void                 OnBubbleClose(const ENUM_BUBBLE_TYPE type);
     void                 OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     void                 OnTimer(void);
                          CTradingLevelBubbles(void);
                         ~CTradingLevelBubbles(void);
  };
#endif // CTRADING_LEVEL_BUBBLE_DECLARATION
#ifndef CTRADING_LEVEL_BUBBLE_IMPLEMENTATION
#define CTRADING_LEVEL_BUBBLE_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| CTradingLevelBubble                                              |
 //+------------------------------------------------------------------+
 CTradingLevelBubble::CTradingLevelBubble(void) : m_bubble_type(BUBBLE_SL_BUY),m_owner(NULL),m_bx(0),m_pinned(false),
                                                  m_label(""),m_pnl_text(""),m_pnl_positive(true),m_covered(false),
                                                  m_press_zone(BUBBLE_ZONE_NONE),m_drag_offset_y(0)
  {
  }
 //--- Born hidden: shown by the controller once a position has this level
 bool CTradingLevelBubble::CreateBubble(const long chart_id,const int subwin,const ENUM_BUBBLE_TYPE type,CTradingLevelBubbles *owner)
  {
   this.m_bubble_type=type;
   this.m_owner=owner;
   this.Hide();
   if(!this.Create(chart_id,subwin,"TradingBubble_"+(string)(int)type,0,0,BUBBLE_TIP_W+BUBBLE_BDY_W+2,BUBBLE_BDY_H+2))
      return false;
   ::ObjectSetString(this.m_chart_id,this.Name(),OBJPROP_TOOLTIP,"\n");
   this.m_canvas.FontSet("Calibri",18,FW_BOLD);
   return true;
  }
 //--- The canvas spans from the chart's left edge to the end of the body
 void CTradingLevelBubble::SetLevel(const int center_y,const int bx,const bool pinned,const string label,const string pnl_text,const bool pnl_positive)
  {
   this.m_bx          =(bx<0 ? 0 : bx);
   this.m_pinned      =pinned;
   this.m_label       =label;
   this.m_pnl_text    =pnl_text;
   this.m_pnl_positive=pnl_positive;
   int w=this.m_bx+BUBBLE_TIP_W+BUBBLE_BDY_W+2;
   int h=BUBBLE_BDY_H+2;
   if(w!=this.m_x_size || h!=this.m_y_size)
      this.Resize(w,h);
   this.Move(0,center_y-h/2);
   this.Draw(false);
  }
 //--- Local zones: the line band left of the tip, the X button
 int CTradingLevelBubble::ZoneAt(const int x,const int y)
  {
   int lx=x-this.m_x;
   int ly=y-this.m_y;
   int cy=this.m_y_size/2;
   if(lx<0 || ly<0 || lx>=this.m_x_size || ly>=this.m_y_size)
      return BUBBLE_ZONE_NONE;
   if(!this.m_pinned && lx<this.m_bx && ::MathAbs(ly-cy)<=BUBBLE_LINE_GRAB)
      return BUBBLE_ZONE_LINE;
   int btn_x1=this.m_bx+BUBBLE_TIP_W+BUBBLE_BDY_W-BUBBLE_XSZ-4;
   int btn_y1=cy-BUBBLE_XSZ/2;
   if(lx>=btn_x1-BUBBLE_X_PAD && lx<=btn_x1+BUBBLE_XSZ+BUBBLE_X_PAD &&
      ly>=btn_y1-BUBBLE_X_PAD && ly<=btn_y1+BUBBLE_XSZ+BUBBLE_X_PAD)
      return BUBBLE_ZONE_CLOSE;
   return BUBBLE_ZONE_NONE;
  }
 //--- Only the line band and the X button take the mouse; the rest falls through to the chart
 bool CTradingLevelBubble::CheckMouseFocus(const int x,const int y)
  {
   this.m_mouse_focus=(this.IsVisible() && !this.m_covered && this.ZoneAt(x,y)!=BUBBLE_ZONE_NONE);
   return this.m_mouse_focus;
  }
 //--- Hovering a grab zone: new bars must not slide the chart under the cursor
 void CTradingLevelBubble::OnFocus(void)
  {
   ::ChartSetInteger(this.m_chart_id,CHART_AUTOSCROLL,false);
  }
 void CTradingLevelBubble::OnBlur(void)
  {
   if(!this.m_is_pressed)
      ::ChartSetInteger(this.m_chart_id,CHART_AUTOSCROLL,true);
  }
 void CTradingLevelBubble::OnPress(const int x,const int y)
  {
   this.m_press_zone=this.ZoneAt(x,y);
   if(this.m_press_zone!=BUBBLE_ZONE_LINE || this.m_owner==NULL)
      return;
   this.m_drag_offset_y=y-this.CenterY();
   ::ChartSetInteger(this.m_chart_id,CHART_AUTOSCROLL,false);
   this.m_owner.OnBubblePress(this.m_bubble_type);
  }
 void CTradingLevelBubble::OnMove(const int x,const int y)
  {
   if(this.m_press_zone==BUBBLE_ZONE_LINE && this.m_owner!=NULL)
      this.m_owner.OnBubbleMove(this.m_bubble_type,y-this.m_drag_offset_y);
  }
 void CTradingLevelBubble::OnRelease(const int x,const int y)
  {
   int zone=this.m_press_zone;
   this.m_press_zone=BUBBLE_ZONE_NONE;
   ::ChartSetInteger(this.m_chart_id,CHART_AUTOSCROLL,true);
   if(this.m_owner==NULL)
      return;
   if(zone==BUBBLE_ZONE_LINE)
      this.m_owner.OnBubbleRelease(this.m_bubble_type);
   else if(zone==BUBBLE_ZONE_CLOSE && this.ZoneAt(x,y)==BUBBLE_ZONE_CLOSE)
      this.m_owner.OnBubbleClose(this.m_bubble_type);
  }
 //--- Transparent canvas: dashed level line, tip + body, X, level label, P&L
 void CTradingLevelBubble::Draw(const bool chart_redraw)
  {
   this.m_canvas.Erase(0);
   int  by     =this.m_y_size/2;
   int  half   =BUBBLE_BDY_H/2;
   int  bx     =this.m_bx;
   bool is_sl  =(this.m_bubble_type==BUBBLE_SL_BUY || this.m_bubble_type==BUBBLE_SL_SELL);
   bool is_buy =(this.m_bubble_type==BUBBLE_SL_BUY || this.m_bubble_type==BUBBLE_TP_BUY);
   uint border_clr=::ColorToARGB(is_sl  ? BUBBLE_CLR_SELL : BUBBLE_CLR_BUY);
   uint label_clr =::ColorToARGB(is_buy ? BUBBLE_CLR_BUY  : BUBBLE_CLR_SELL);
   uint bg        =::ColorToARGB(BUBBLE_CLR_BG);
   uint line_clr  =::ColorToARGB(is_sl ? BUBBLE_CLR_SELL : BUBBLE_CLR_BUY,180);
   for(int x=0; !this.m_pinned && x<bx; x+=15)
     {
      int x2=::MathMin(x+9,bx-1);
      this.m_canvas.LineHorizontal(x,x2,by-1,line_clr);
      this.m_canvas.LineHorizontal(x,x2,by,  line_clr);
      this.m_canvas.LineHorizontal(x,x2,by+1,line_clr);
     }
   int body_x1=bx+BUBBLE_TIP_W;
   int body_x2=bx+BUBBLE_TIP_W+BUBBLE_BDY_W;
   int body_y1=by-half;
   int body_y2=by+half;
   this.m_canvas.FillTriangle(bx,by,bx+BUBBLE_TIP_W,by-half,bx+BUBBLE_TIP_W,by+half,border_clr);
   this.m_canvas.FillRectangle(body_x1,body_y1,body_x2,body_y2,border_clr);
   this.m_canvas.FillTriangle(bx+BUBBLE_BDR_W,by,bx+BUBBLE_TIP_W,by-half+BUBBLE_BDR_W,bx+BUBBLE_TIP_W,by+half-BUBBLE_BDR_W,bg);
   this.m_canvas.FillRectangle(body_x1,body_y1+BUBBLE_BDR_W,body_x2-BUBBLE_BDR_W,body_y2-BUBBLE_BDR_W,bg);
   int btn_x1=body_x2-BUBBLE_XSZ-4;
   int btn_y1=by-BUBBLE_XSZ/2;
   this.m_canvas.FillRectangle(btn_x1,btn_y1,btn_x1+BUBBLE_XSZ,btn_y1+BUBBLE_XSZ,::ColorToARGB(clrFireBrick));
   this.m_canvas.TextOut(btn_x1+BUBBLE_XSZ/2,by,"X",::ColorToARGB(clrWhite),TA_CENTER|TA_VCENTER);
   this.m_canvas.TextOut(body_x1+8,by-12,this.m_label,label_clr,TA_LEFT|TA_VCENTER);
   this.m_canvas.TextOut(body_x1+8,by+12,this.m_pnl_text,::ColorToARGB(this.m_pnl_positive ? BUBBLE_CLR_PROFIT_POS : BUBBLE_CLR_PROFIT_NEG),TA_LEFT|TA_VCENTER);
   this.m_canvas.Update(chart_redraw);
  }
 //+------------------------------------------------------------------+
 //| CTradingLevelBubbles                                             |
 //+------------------------------------------------------------------+
 CTradingLevelBubbles::CTradingLevelBubbles(void) : m_chart_id(0),m_market_collection(NULL),m_trading_control(NULL),
                                                    m_orig_chart_shift(true),m_last_chart_w(0),m_last_chart_h(0),m_restack_needed(false),
                                                    m_drag_type(WRONG_VALUE),m_drag_center_y(0),m_drag_bx(0),
                                                    m_drag_anchor_y(0),m_drag_price_anchor(0),m_price_per_pixel(0)
  {
   for(int i=0; i<BUBBLE_TOTAL; i++)
     {
      this.m_bubble[i]=NULL;
      this.m_last[i]  =0;
      this.m_mixed[i] =false;
     }
  }
 //--- Give the chart back its native SL/TP lines
 CTradingLevelBubbles::~CTradingLevelBubbles(void)
  {
   if(this.m_chart_id==0)
      return;
   ::ChartSetInteger(this.m_chart_id,CHART_SHOW_TRADE_LEVELS,true);
   ::ChartSetInteger(this.m_chart_id,CHART_SHIFT,this.m_orig_chart_shift);
   ::ChartSetInteger(this.m_chart_id,CHART_AUTOSCROLL,true);
  }
 //--- The 4 bubbles are created here, the caller hands them to CGraphElementsCollection
 bool CTradingLevelBubbles::Create(const long chart_id,CMarketCollection *market,CTradingControl *trading_control)
  {
   if(market==NULL || trading_control==NULL)
      return false;
   this.m_chart_id         =chart_id;
   this.m_market_collection=market;
   this.m_trading_control  =trading_control;
   for(int i=0; i<BUBBLE_TOTAL; i++)
     {
      this.m_bubble[i]=new CTradingLevelBubble();
      if(this.m_bubble[i]==NULL || !this.m_bubble[i].CreateBubble(chart_id,0,(ENUM_BUBBLE_TYPE)i,::GetPointer(this)))
         return false;
     }
   //--- The bubbles replace the native SL/TP lines; the right shift leaves room for them
   ::ChartSetInteger(chart_id,CHART_SHOW_TRADE_LEVELS,false);
   this.m_orig_chart_shift=(bool)::ChartGetInteger(chart_id,CHART_SHIFT);
   ::ChartSetInteger(chart_id,CHART_SHIFT,true);
   return true;
  }
 //--- One level per direction for the whole group: sticky when positions disagree, 'mixed' flags it
 double CTradingLevelBubbles::ResolveLevel(const ENUM_POSITION_TYPE dir,const bool is_sl,const double prev,bool &mixed)
  {
   mixed=false;
   CArrayObj *list=this.m_market_collection.GetList();   // filtered inline below - no Select per mouse move
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
   mixed=(distinct>1 || without>0);
   if(distinct==1)
      return levels[0];
   for(int k=0; k<distinct; k++)
      if(::MathAbs(levels[k]-prev)<point/2)
         return levels[k];
   int best=0;
   for(int k=1; k<distinct; k++)
      if(counts[k]>counts[best])
         best=k;
   return levels[best];
  }
 //--- Money if every position of the direction closed at target_price
 double CTradingLevelBubbles::FloatingProfitAt(const ENUM_POSITION_TYPE dir,const double target_price)
  {
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
 //--- Price under the dragged bubble, read from the chart now; drag-start anchor only as fallback
 double CTradingLevelBubbles::DragPrice(void)
  {
   datetime t; double price; int sub;
   if(::ChartXYToTimePrice(this.m_chart_id,this.m_drag_bx,this.m_drag_center_y,sub,t,price) && sub==0 && price>0)
      return price;
   return this.m_drag_price_anchor+(this.m_drag_center_y-this.m_drag_anchor_y)*this.m_price_per_pixel;
  }
 //--- INT_MIN = mapping failed; a negative y is a valid off-screen level
 int CTradingLevelBubbles::PriceToY(const double price)
  {
   int x,y;
   datetime t=::iTime(this.ChartSymbol(),(ENUM_TIMEFRAMES)::ChartPeriod(this.m_chart_id),0);
   if(!::ChartTimePriceToXY(this.m_chart_id,0,t,price,x,y))
      return INT_MIN;
   return y;
  }
 //--- Off-screen levels are pinned to the top/bottom edge
 int CTradingLevelBubbles::ClampY(const int y,bool &pinned)
  {
   int half=BUBBLE_BDY_H/2+2;
   int hi  =(int)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS)-half;
   pinned=(y<half || y>hi);
   return (y<half ? half : y>hi ? hi : y);
  }
 //--- The last bar's X + a look-ahead gap, never past the chart's right edge
 int CTradingLevelBubbles::AnchorBX(void)
  {
   int chart_w=(int)::ChartGetInteger(this.m_chart_id,CHART_WIDTH_IN_PIXELS);
   int max_bx =chart_w-BUBBLE_RPAD-BUBBLE_TIP_W-BUBBLE_BDY_W;
   int last_x,dummy_y;
   datetime t0=::iTime(this.ChartSymbol(),(ENUM_TIMEFRAMES)::ChartPeriod(this.m_chart_id),0);
   bool got_x=(t0>0 && ::ChartTimePriceToXY(this.m_chart_id,0,t0,1.0,last_x,dummy_y));
   int bx=(got_x ? last_x+BUBBLE_LOOKAHEAD : max_bx);
   return (bx>max_bx ? max_bx : bx);
  }
 //--- SL and TP of one direction never overlap; the dragged one keeps its place
 void CTradingLevelBubbles::ResolveOverlap(int &ya,int &yb,const bool a_dragged,const bool b_dragged)
  {
   if(ya==INT_MIN || yb==INT_MIN || ::MathAbs(ya-yb)>=BUBBLE_BDY_H+2)
      return;
   int gap=BUBBLE_BDY_H+BUBBLE_BDY_W+6;
   if(a_dragged)
      yb=(ya>=yb ? ya-gap : ya+gap);
   else if(b_dragged)
      ya=(yb>=ya ? yb-gap : yb+gap);
   else
     {
      int mid=(ya+yb)/2;
      int half=gap/2;
      if(ya>=yb) { ya=mid+half; yb=mid-half; }
      else       { ya=mid-half; yb=mid+half; }
     }
  }
 string CTradingLevelBubbles::BubbleLabel(const ENUM_BUBBLE_TYPE type,const double price)
  {
   string prefix=(type==BUBBLE_SL_BUY ? "SL Buy  " : type==BUBBLE_TP_BUY ? "TP Buy  " : type==BUBBLE_SL_SELL ? "SL Sell " : "TP Sell ");
   return prefix+::DoubleToString(price,(int)::SymbolInfoInteger(this.ChartSymbol(),SYMBOL_DIGITS));
  }
 //--- SL + TP bubbles of one direction
 void CTradingLevelBubbles::PlaceDirection(const ENUM_BUBBLE_TYPE sl_type,const ENUM_BUBBLE_TYPE tp_type,const bool is_buy,const int bx)
  {
   ENUM_BUBBLE_TYPE types[2];
   types[0]=sl_type;
   types[1]=tp_type;
   int  y[2]={INT_MIN,INT_MIN};
   bool pinned[2]={false,false};
   for(int k=0; k<2; k++)
     {
      int t=types[k];
      if(this.m_last[t]<=0)
         continue;
      y[k]=(this.m_drag_type==t ? this.m_drag_center_y : this.PriceToY(this.m_last[t]));
      if(y[k]!=INT_MIN)
         y[k]=this.ClampY(y[k],pinned[k]);
     }
   this.ResolveOverlap(y[0],y[1],this.m_drag_type==sl_type,this.m_drag_type==tp_type);
   ENUM_POSITION_TYPE dir=(is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL);
   for(int k=0; k<2; k++)
     {
      int t=types[k];
      CTradingLevelBubble *bubble=this.m_bubble[t];
      if(bubble==NULL)
         continue;
      if(y[k]==INT_MIN)
        {
         if(bubble.IsVisible())
            bubble.Hide();
         continue;
        }
      bool   dragged=(this.m_drag_type==t);
      double price  =(dragged ? this.DragPrice() : this.m_last[t]);
      string label  =(pinned[k] ? (y[k]<=(int)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS)/2 ? ::ShortToString(0x25B2)+" " : ::ShortToString(0x25BC)+" ") : "")+
                     (this.m_mixed[t] && !dragged ? "* " : "")+this.BubbleLabel((ENUM_BUBBLE_TYPE)t,price);
      double pnl    =this.FloatingProfitAt(dir,price);
      bubble.SetLevel(y[k],(dragged ? this.m_drag_bx : bx),pinned[k],label,(pnl>=0 ? "+" : "")+::DoubleToString(pnl,2)+" $",pnl>=0);
      if(!bubble.IsVisible())
        {
         bubble.Show();
         this.m_restack_needed=true;
        }
     }
  }
 //--- Levels from the positions, then every bubble placed/shown/hidden
 void CTradingLevelBubbles::Refresh(void)
  {
   if(this.m_market_collection==NULL)
      return;
   this.m_last[BUBBLE_SL_BUY] =this.ResolveLevel(POSITION_TYPE_BUY, true, this.m_last[BUBBLE_SL_BUY], this.m_mixed[BUBBLE_SL_BUY]);
   this.m_last[BUBBLE_TP_BUY] =this.ResolveLevel(POSITION_TYPE_BUY, false,this.m_last[BUBBLE_TP_BUY], this.m_mixed[BUBBLE_TP_BUY]);
   this.m_last[BUBBLE_SL_SELL]=this.ResolveLevel(POSITION_TYPE_SELL,true, this.m_last[BUBBLE_SL_SELL],this.m_mixed[BUBBLE_SL_SELL]);
   this.m_last[BUBBLE_TP_SELL]=this.ResolveLevel(POSITION_TYPE_SELL,false,this.m_last[BUBBLE_TP_SELL],this.m_mixed[BUBBLE_TP_SELL]);
   int bx=this.AnchorBX();
   this.PlaceDirection(BUBBLE_SL_BUY, BUBBLE_TP_BUY, true, bx);
   this.PlaceDirection(BUBBLE_SL_SELL,BUBBLE_TP_SELL,false,bx);
   ::ChartRedraw(this.m_chart_id);
  }
 void CTradingLevelBubbles::OnBubblePress(const ENUM_BUBBLE_TYPE type)
  {
   CTradingLevelBubble *bubble=this.m_bubble[type];
   if(bubble==NULL)
      return;
   this.m_drag_type        =type;
   this.m_drag_center_y    =bubble.CenterY();
   this.m_drag_bx          =this.AnchorBX();
   this.m_drag_anchor_y    =this.m_drag_center_y;
   this.m_drag_price_anchor=this.m_last[type];
   datetime t; double p0=0,p1=0; int sub;
   if(::ChartXYToTimePrice(this.m_chart_id,this.m_drag_bx,this.m_drag_anchor_y,sub,t,p0) &&
      ::ChartXYToTimePrice(this.m_chart_id,this.m_drag_bx,this.m_drag_anchor_y+1,sub,t,p1) && ::MathAbs(p1-p0)>=1e-12)
      this.m_price_per_pixel=p1-p0;
   else
      this.m_price_per_pixel=-::SymbolInfoDouble(this.ChartSymbol(),SYMBOL_TRADE_TICK_SIZE);
  }
 void CTradingLevelBubbles::OnBubbleMove(const ENUM_BUBBLE_TYPE type,const int center_y)
  {
   if(this.m_drag_type!=type)
      return;
   this.m_drag_center_y=center_y;
   this.Refresh();
  }
 //--- Drop: every position of that direction moves its SL (or TP) to the dropped price
 void CTradingLevelBubbles::OnBubbleRelease(const ENUM_BUBBLE_TYPE type)
  {
   if(this.m_drag_type!=type)
      return;
   double new_price=this.DragPrice();
   this.m_drag_type=WRONG_VALUE;
   ENUM_POSITION_TYPE dir=(type<=BUBBLE_TP_BUY ? POSITION_TYPE_BUY : POSITION_TYPE_SELL);
   bool modify_sl=(type==BUBBLE_SL_BUY || type==BUBBLE_SL_SELL);
   this.m_trading_control.ModifyPositions(this.ChartSymbol(),dir,modify_sl,new_price);
   this.Refresh();
  }
 void CTradingLevelBubbles::OnBubbleClose(const ENUM_BUBBLE_TYPE type)
  {
   ENUM_POSITION_TYPE dir=(type<=BUBBLE_TP_BUY ? POSITION_TYPE_BUY : POSITION_TYPE_SELL);
   this.m_trading_control.ClosePositions(this.ChartSymbol(),dir);
   this.Refresh();
  }
 //--- Scroll/zoom/new bar move the bubbles; trade events change the levels
 void CTradingLevelBubbles::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      this.Refresh();
      return;
     }
   if(id<CHARTEVENT_CUSTOM)
      return;
   ushort ev=(ushort)(id-CHARTEVENT_CUSTOM);
   if(ev==(ushort)TRADE_EVENT_MODIFY_POSITION_SL            || ev==(ushort)TRADE_EVENT_MODIFY_POSITION_TP            ||
      ev==(ushort)TRADE_EVENT_MODIFY_POSITION_SL_TP         || ev==(ushort)TRADE_EVENT_POSITION_OPENED               ||
      ev==(ushort)TRADE_EVENT_POSITION_CLOSED               || ev==(ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL       ||
      ev==(ushort)TRADE_EVENT_POSITION_CLOSED_BY_SL         || ev==(ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL ||
      ev==(ushort)TRADE_EVENT_POSITION_CLOSED_BY_TP         || ev==(ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP ||
      ev==(ushort)TRADE_EVENT_POSITION_CLOSED_BY_POS        || ev==(ushort)TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS)
      this.Refresh();
  }
 //--- Chart resize has no event of its own
 void CTradingLevelBubbles::OnTimer(void)
  {
   int w=(int)::ChartGetInteger(this.m_chart_id,CHART_WIDTH_IN_PIXELS);
   int h=(int)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS);
   if(w==this.m_last_chart_w && h==this.m_last_chart_h)
      return;
   this.m_last_chart_w=w;
   this.m_last_chart_h=h;
   this.Refresh();
  }
#endif // CTRADING_LEVEL_BUBBLE_IMPLEMENTATION
#endif // __TRADING_LEVEL_BUBBLE_MQH__
