//+------------------------------------------------------------------+
//|                                                 TradeSetupBox.mqh |
//+------------------------------------------------------------------+
#ifndef __TRADESETUPBOX_COMPOSITE_MQH__
#define __TRADESETUPBOX_COMPOSITE_MQH__
 #include "..\..\GBases\GBaseObj.mqh"
 #include "..\Standard\GStdRectangleObj.mqh"
 #include "..\Standard\GStdRectangleLabelObj.mqh"
 #include "..\Standard\GStdTrendObj.mqh"
 #include "..\Standard\GStdTextObj.mqh"
 #include "..\..\Defines\CommonDefines.mqh"
 #include "..\..\Defines\GUIDefines.mqh"
 #include "..\..\Defines\MouseDefines.mqh"
 #include "..\..\Defines\TradingDefines.mqh"   // ENUM_RISK_REWARD_RATIO: the levels of the Target
 #include "..\..\Defines\ImageDataDefine.mqh"
 #include "..\Properties\Colors.mqh"
 #include "..\..\Controls\Label.mqh"
 #include "..\..\Controls\Button.mqh"
 #include "..\..\Controls\CheckBox.mqh"
 #include "..\..\Controls\ComboBox.mqh"
 #define TSB_CAPTION_W      40     // caption RRR
 #define TSB_RPT_W          50     // widths of the bar of controls
 #define TSB_SEND_W         40
 #define TSB_PNL_W          140    // width of the P&L label
 #define TSB_ALPHA_ZONE     60     // opacity of the zones (0-255)
 #define TSB_COLOR_BUY      clrSeaGreen  //clrDodgerBlue
 #define TSB_COLOR_SELL     clrFireBrick //clrTomato
 #define TSB_COLOR_STOP     clrFireBrick
 #define TSB_COLOR_TARGET   clrSeaGreen
#ifndef CTRADESETUPBOX_COMPOSITE_DECLARATION
#define CTRADESETUPBOX_COMPOSITE_DECLARATION
 //+------------------------------------------------------------------+
 //| What is grabbed with the mouse                                   |
 //+------------------------------------------------------------------+
 enum ENUM_TSB_PART
  {
   TSB_NONE=0,
   TSB_STOP,        // the Stop box: the Stop price
   TSB_BODY         // the grip icon at the start of the strip: the whole box
  };
 //+------------------------------------------------------------------+
 //| A planned trade like the Long / Short tool: the parent of its    |
 //| children. The zones, the take profit lines and their names are  |
 //| native objects anchored in time and price (the chart moves them);|
 //| the strip, the Stop and Target boxes are native rectangle        |
 //| labels; the controls (combo boxes, check box, buttons,           |
 //| labels) are canvas elements over them. The box keeps its own     |
 //| state, handles the mouse, and tells the outside with chart events|
 //| (ON_TRADE_SETUP_SEND, ON_TRADE_SETUP_CLOSE)                      |
 //+------------------------------------------------------------------+
 class CTradeSetupBox : public CGBaseObj
  {
   private:
     datetime          m_time_left;       // the bar the box starts at
     string            m_symbol;          // the symbol of the box
     ENUM_TIMEFRAMES   m_period;          // the timeframe m_bars is counted in
     int               m_bars;            // how many bars it is wide
     double            m_entry;
     double            m_stop;
     ENUM_SIGNAL_DIR   m_side;            // Buy or Sell
     double            m_target;          // the last take profit level: made from the Stop and the ratios
     int               m_levels;          // how many take profit levels (1 to RISK_REWARD_RATIOS_TOTAL)
     double            m_lots;            // fixed lots, used when the risk is 0
     double            m_risk_percent;    // given by the EA, in percent of the balance (0 = the fixed lots)
     double            m_lots_shown;      // what the lot combo shows now (-1 manual, -2 unknown)
     bool              m_covered;         // a window covers the cursor
     bool              m_use_risk;        // the lots come from the risk (the check box)
     bool              m_shown;           // the children are on the chart
     int               m_tp_shown;        // how many take profit lines are on the chart
     bool              m_prev_left;
     bool              m_grab;            // the chart does not scroll under the cursor
     bool              m_saved_scroll;
     ENUM_TSB_PART     m_drag;            // what is dragged now
     ENUM_TSB_PART     m_hover;           // what is under the cursor
     int               m_press_x,m_press_y;
     double            m_press_price,m_press_entry,m_press_stop;
     int               m_press_shift;     // shift of the left bar when the body was grabbed
     int               m_changes;         // how many times the user changed it (a test counts them)
     int               m_last_chart_w,m_last_chart_h;
     int               m_text_w[3];       // measured text widths: Stop box, Target box, P&L
     int               m_bars_used;       // bars wide now: the box is never narrower than its texts
   //--- the layout in chart pixels, made by Layout()
     int               m_xl,m_xr;         // left and right edge of the box
     int               m_y_entry,m_y_StopLost,m_y_TakeProfit;
     int               m_Box_StopLost_y,m_Box_TakeProfit_y,m_Box_StopLost_w,m_Box_TakeProfit_w;   // the Stop and the Target box
     int               m_Box_strip_y;
   //--- native children: anchored in time and price
     CGStdRectangleObj m_Rectangle_TakeProfit;
     CGStdRectangleObj m_Rectangle_StopLost;
     CGStdRectangleObj m_Rectangle_StopLostBox;     // the boxes: native rectangles behind the candles, as high as 22 px
     CGStdRectangleObj m_Rectangle_TakeProfitBox;
     CGStdRectangleObj m_Rectangle_strip;
     CGStdTrendObj     m_tp_line[RISK_REWARD_RATIOS_TOTAL];
     CGStdTextObj      m_tp_text[RISK_REWARD_RATIOS_TOTAL];
   //--- native children: in chart pixels
     CGStdTrendObj     m_Line_Guide;      // a line across the chart at the Stop price, only while the Stop is dragged
     bool              m_guide_shown;
   //--- canvas children
     CLabel            m_Label_StopLost;  // the text of the Stop and of the Target box (the box itself is a native rectangle behind the candles)
     CLabel            m_Label_TakeProfit;
     CLabel            m_label_rrr;
     CLabel            m_label_pnl;
     CButton           m_button_type;     // the icon of Buy or Sell: a click flips
     CComboBox         m_combo_ratio;
     CCheckBox         m_check_risk;
     CComboBox         m_combo_lots;
     CButton           m_button_OrderSend;
     CButton           m_button_grip;     // the icon that moves the box
     CButton           m_button_close;
     double            m_lot_choices[];   // what the combo box of the lots offers
   //Method
     bool              CreateChildren(const long chart,const string base);
     void              StyleIcon(CButton &button);
     void              StyleLabel(CLabel &label,const color colour);
     void              PlaceBox(CGStdRectangleObj &box,const int y_top,const datetime t_right);   // a box of 22 px at y_top, as a time and price rectangle
     void              UpdateText(CLabel &label,const string text);
     void              BuildLotChoices(void);
     void              ShowType(void);    // the icon and the button say Buy or Sell
     void              ShowLots(const double lots);   // the lot combo: the computed lots (RPT) or the chosen one
     void              ReadBar(void);     // what the user chose in the ratio combo and the check box
     void              SetShown(const bool shown);
     void              Apply(void);       // everything to its place and its text
     void              PlaceNative(void);
     void              PlaceControls(void);
     void              UpdateTexts(void);
     void              UpdatePnl(const double lots);
     bool              Layout(void);
     void              OnChartChange(void);   // symbol or timeframe changed
     int               SlotWidth(void) const;
     int               TextWidth(const string text) const;   // in the font of the library
     int               BarWidth(void) const { return 2*M_ICON16_WIDTH+TSB_CAPTION_W+M_TF_WITHICON_WIDTH+TSB_RPT_W+M_LOT_WIDTH+TSB_SEND_W+3*M_CONTROL_BORDER_GAP; }
     int               MinBars(void) const;   // the strip holds the bar, the P&L and the two icons
     int               CloseX(void) const;   // the end of the strip, kept inside the chart
     int               GripX(void) const { return this.m_xl; }
     datetime          TimeAtShift(const int shift) const;
     double            Tick(void) const;
     double            TickValue(void) const;
     double            Snap(const double price) const;
     double            LossPerLot(void) const;
     double            LotsToTrade(void) const;
     double            LevelPrice(const int level) const;   // level 0 = the first
     double            LevelRatio(const int level) const;
     void              UpdateTarget(void);
     string            Money(const double value) const;
     string            RatioText(const double ratio) const;
     string            Distance(const double from,const double to) const;
     ENUM_TSB_PART     PartAt(const int x,const int y);
     void              SetGrab(const bool on);
     bool              PriceAt(const int x,const int y,double &price,datetime &time) const;
     void              Drag(const int x,const int y);
     void              Flip(void);
   public:
     bool              Create(const long chart_id,const int subwin,const string name);
   //--- Left bar, bars wide, entry price, Stop (a Stop under the entry is a Buy)
     void              Setup(const datetime time_left,const int bars,const double entry,const double stop);
   //--- How many take profit levels: the first ones of ENUM_RISK_REWARD_RATIO
     void              SetLevels(const int count);
   //--- Given by the EA: the risk in percent of the balance for the lots of the RPT; the fixed lots at the start
     void              SetRiskPercent(const double percent);
     void              SetLots(const double lots);
     void              SetUseRisk(const bool use);
     void              Show(void);
     void              Hide(void);
     double            Entry(void)  const { return this.m_entry;  }
     double            Stop(void)   const { return this.m_stop;   }
     double            Target(void) const { return this.m_target; }
     bool              IsBuy(void)  const { return this.m_side==SIGNAL_BUY; }
     double            Lots(void)   const { return this.LotsToTrade(); }
     int               Levels(void) const { return this.m_levels; }
     double            Level(const int level) const { return this.LevelPrice(level); }
     int               Changes(void) const { return this.m_changes; }
     virtual void      SetCovered(const bool covered);
     virtual void      OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
     virtual void      OnTimerEvent(void);
                       CTradeSetupBox(void);
                      ~CTradeSetupBox(void);
  };
#endif // CTRADESETUPBOX_COMPOSITE_DECLARATION
#ifndef CTRADESETUPBOX_COMPOSITE_IMPLEMENTATION
#define CTRADESETUPBOX_COMPOSITE_IMPLEMENTATION
 CTradeSetupBox::CTradeSetupBox(void) : m_time_left(0),m_symbol(""),m_period(PERIOD_CURRENT),m_bars(30),m_entry(0),m_stop(0),m_side(SIGNAL_BUY),m_target(0),m_levels(3),m_lots(0.1),m_risk_percent(0),
                                        m_lots_shown(-2.0),m_covered(false),m_use_risk(true),m_shown(false),m_tp_shown(0),m_guide_shown(false),m_prev_left(false),m_grab(false),m_saved_scroll(true),
                                        m_drag(TSB_NONE),m_hover(TSB_NONE),m_press_x(0),m_press_y(0),m_press_price(0),m_press_entry(0),m_press_stop(0),m_press_shift(0),m_changes(0),
                                        m_last_chart_w(0),m_last_chart_h(0),m_bars_used(0),m_xl(0),m_xr(0),m_y_entry(0),m_y_StopLost(0),m_y_TakeProfit(0),m_Box_StopLost_y(0),m_Box_TakeProfit_y(0),m_Box_StopLost_w(0),m_Box_TakeProfit_w(0),m_Box_strip_y(0)
  {
   ::ArrayInitialize(this.m_text_w,0);
  }
 CTradeSetupBox::~CTradeSetupBox(void)
  {
   this.SetGrab(false);
  }
 //+------------------------------------------------------------------+
 //| The children, back to front: native objects, then the controls   |
 //+------------------------------------------------------------------+
 bool CTradeSetupBox::Create(const long chart_id,const int subwin,const string name)
  {
   long chart=(chart_id==0 ? ::ChartID() : chart_id);
   this.SetName(name);
   this.SetChartID(chart);
   this.m_subwindow=subwin;
   this.m_visible=true;
   ::ChartSetInteger(chart,CHART_EVENT_MOUSE_MOVE,true);
   if(!this.CreateChildren(chart,name))
      return false;
   this.AddChild(&this.m_Rectangle_TakeProfit);
   this.AddChild(&this.m_Rectangle_StopLost);
   for(int i=0;i<RISK_REWARD_RATIOS_TOTAL;i++)
     {
      this.AddChild(&this.m_tp_line[i]);
      this.AddChild(&this.m_tp_text[i]);
     }
   this.AddChild(&this.m_Rectangle_StopLostBox);
   this.AddChild(&this.m_Rectangle_TakeProfitBox);
   this.AddChild(&this.m_Rectangle_strip);
   this.AddChild(&this.m_Line_Guide);
   this.AddChild(&this.m_Label_StopLost);
   this.AddChild(&this.m_Label_TakeProfit);
   this.AddChild(&this.m_label_rrr);
   this.AddChild(&this.m_label_pnl);
   this.AddChild(&this.m_button_type);
   this.AddChild(&this.m_combo_ratio);
   this.AddChild(&this.m_check_risk);
   this.AddChild(&this.m_combo_lots);
   this.AddChild(&this.m_button_OrderSend);
   this.AddChild(&this.m_button_grip);
   this.AddChild(&this.m_button_close);
   this.ShowType();
   return true;
  }
 bool CTradeSetupBox::CreateChildren(const long chart,const string base)
  {
   int sub=this.m_subwindow;
   color bg=(color)::ChartGetInteger(chart,CHART_COLOR_BACKGROUND);
   //--- native: zones behind the candles, take profit lines and their names
   if(!this.m_Rectangle_TakeProfit.Create(chart,sub,base+"_zt") || !this.m_Rectangle_StopLost.Create(chart,sub,base+"_zs"))
      return false;
   this.m_Rectangle_TakeProfit.SetColor(CColors::MixColors(bg,TSB_COLOR_TARGET,TSB_ALPHA_ZONE/255.0));
   this.m_Rectangle_StopLost.SetColor(CColors::MixColors(bg,TSB_COLOR_STOP,TSB_ALPHA_ZONE/255.0));
   CGStdRectangleObj *zones[2]={&this.m_Rectangle_TakeProfit,&this.m_Rectangle_StopLost};
   for(int i=0;i<2;i++)
     {
      zones[i].SetFlagFill(true);
      zones[i].SetFlagBack(true,false);
      zones[i].SetFlagSelectable(false,false);
      zones[i].SetTooltip("\n");
      zones[i].SetVisibleFlag(false,false);
     }
   for(int i=0;i<RISK_REWARD_RATIOS_TOTAL;i++)
     {
      if(!this.m_tp_line[i].Create(chart,sub,base+"_tl"+(string)i) || !this.m_tp_text[i].Create(chart,sub,base+"_tt"+(string)i))
         return false;
      this.m_tp_line[i].SetStyle(STYLE_DOT);
      this.m_tp_line[i].SetColor(TSB_COLOR_TARGET);
      this.m_tp_line[i].SetWidth(1);
      this.m_tp_line[i].SetFlagSelectable(false,false);
      this.m_tp_line[i].SetTooltip("\n");
      this.m_tp_line[i].SetVisibleFlag(false,false);
      this.m_tp_text[i].SetFont(DEF_FONT);
      this.m_tp_text[i].SetFontSize(DEF_FONT_SIZE+1);   // a native text looks smaller than the canvas one
      this.m_tp_text[i].SetColor(TSB_COLOR_TARGET);
      this.m_tp_text[i].SetFlagSelectable(false,false);
      this.m_tp_text[i].SetTooltip("\n");
      this.m_tp_text[i].SetVisibleFlag(false,false);
     }
   //--- native: the Stop and Target boxes and the strip, behind the candles
   if(!this.m_Rectangle_StopLostBox.Create(chart,sub,base+"_sb") || !this.m_Rectangle_TakeProfitBox.Create(chart,sub,base+"_tb") ||
      !this.m_Rectangle_strip.Create(chart,sub,base+"_strip"))
      return false;
   CGStdRectangleObj *boxes[3]={&this.m_Rectangle_StopLostBox,&this.m_Rectangle_TakeProfitBox,&this.m_Rectangle_strip};
   color box_colour[3]={TSB_COLOR_STOP,TSB_COLOR_TARGET,clrWhite};
   for(int i=0;i<3;i++)
     {
      boxes[i].SetColor(box_colour[i]);
      boxes[i].SetFlagFill(true);
      boxes[i].SetFlagBack(true,false);
      boxes[i].SetFlagSelectable(false,false);
      boxes[i].SetTooltip("\n");
      boxes[i].SetVisibleFlag(false,false);
     }
   //--- native: the guide line over the chart while the Stop is dragged
   if(!this.m_Line_Guide.Create(chart,sub,base+"_guide"))
      return false;
   this.m_Line_Guide.SetStyle(STYLE_DASH);
   this.m_Line_Guide.SetColor(TSB_COLOR_STOP);
   this.m_Line_Guide.SetWidth(1);
   this.m_Line_Guide.SetFlagRayLeft(true);
   this.m_Line_Guide.SetFlagRayRight(true);
   this.m_Line_Guide.SetFlagSelectable(false,false);
   this.m_Line_Guide.SetTooltip("\n");
   this.m_Line_Guide.SetVisibleFlag(false,false);
   //--- canvas: the texts of the two boxes and the controls of the strip
   if(!this.m_Label_StopLost.Create(chart,sub,base+"_sb",0,0,M_TF_WITHICON_WIDTH,M_CONTROL_HEIGHT) ||
      !this.m_Label_TakeProfit.Create(chart,sub,base+"_tb",0,0,M_TF_WITHICON_WIDTH,M_CONTROL_HEIGHT) ||
      !this.m_label_rrr.Create(chart,sub,base+"_rrr",0,0,TSB_CAPTION_W,M_CONTROL_HEIGHT) ||
      !this.m_label_pnl.Create(chart,sub,base+"_pnl",0,0,TSB_PNL_W,M_CONTROL_HEIGHT))
      return false;
   this.StyleLabel(this.m_Label_StopLost,clrWhite);
   this.StyleLabel(this.m_Label_TakeProfit,clrWhite);
   this.m_Label_StopLost.LabelXGap(M_CONTROL_BORDER_GAP+4);
   this.m_Label_TakeProfit.LabelXGap(M_CONTROL_BORDER_GAP+4);
   this.StyleLabel(this.m_label_rrr,clrBlack);
   this.StyleLabel(this.m_label_pnl,clrBlack);
   this.UpdateText(this.m_label_rrr,"RRR");
   if(!this.m_button_type.Create(chart,sub,base+"_type",0,0,M_ICON16_WIDTH,M_CONTROL_HEIGHT))
      return false;
   this.StyleIcon(this.m_button_type);
   //--- RRR of the Target: the levels up to it are the take profit levels
   this.m_combo_ratio.ItemsTotal(RISK_REWARD_RATIOS_TOTAL);
   for(int i=0;i<RISK_REWARD_RATIOS_TOTAL;i++)
      this.m_combo_ratio.SetValue(i,this.RatioText(this.LevelRatio(i)));
   if(!this.m_combo_ratio.CreateComboBox(chart,sub,base+"_ratio",0,0,M_TF_WITHICON_WIDTH,M_CONTROL_HEIGHT,M_TF_WITHICON_WIDTH-1,RISK_REWARD_RATIOS_TOTAL*M_CONTROL_HEIGHT+4))
      return false;
   this.m_combo_ratio.SelectItem(this.m_levels-1);
   //--- the check box: the lots come from the risk
   this.m_check_risk.SetText("RPT");
   if(!this.m_check_risk.Create(chart,sub,base+"_risk",0,0,TSB_RPT_W,M_CONTROL_HEIGHT))
      return false;
   this.m_check_risk.SetState(this.m_use_risk);
   //--- lots to choose when the RPT is off
   this.BuildLotChoices();
   this.m_combo_lots.ItemsTotal(ArraySize(this.m_lot_choices));
   for(int i=0;i<ArraySize(this.m_lot_choices);i++)
      this.m_combo_lots.SetValue(i,::DoubleToString(this.m_lot_choices[i],2));
   if(!this.m_combo_lots.CreateComboBox(chart,sub,base+"_lots",0,0,M_LOT_WIDTH,M_CONTROL_HEIGHT,M_LOT_WIDTH-1,::MathMin(ArraySize(this.m_lot_choices),8)*M_CONTROL_HEIGHT+4))
      return false;
   this.ShowLots(this.m_lots);
   //--- the button sends the order, the two icons move and close the box
   if(!this.m_button_OrderSend.Create(chart,sub,base+"_send",0,0,TSB_SEND_W,M_CONTROL_HEIGHT) ||
      !this.m_button_grip.Create(chart,sub,base+"_grip",0,0,M_ICON16_WIDTH,M_CONTROL_HEIGHT) ||
      !this.m_button_close.Create(chart,sub,base+"_close",0,0,M_ICON16_WIDTH,M_CONTROL_HEIGHT))
      return false;
   this.StyleIcon(this.m_button_grip);
   this.StyleIcon(this.m_button_close);
   this.m_button_grip.IconFile(IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_BMP);
   this.m_button_close.IconFile(IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG);
   this.m_button_grip.Draw(true);
   this.m_button_close.Draw(true);
   this.m_shown=true;   // hide what was created shown
   this.SetShown(false);
   return true;
  }
 //--- A flat white button that only carries an icon
 void CTradeSetupBox::StyleIcon(CButton &button)
  {
   button.GetBackColorControl().InitColors(clrWhite,clrGainsboro,clrSilver,clrWhite);
   button.GetBorderColorControl().InitColors(clrWhite,clrGainsboro,clrSilver,clrWhite);
   button.ColorChange(COLOR_STATE_DEFAULT);
  }
 void CTradeSetupBox::StyleLabel(CLabel &label,const color colour)
  {
   label.IsAvailable(false);
   label.LabelXGap(M_CONTROL_BORDER_GAP);
   label.GetForeColorControl().InitColors(colour);
   label.GetForeColorControl().SetCurrentAs(COLOR_STATE_DEFAULT);
  }
 void CTradeSetupBox::UpdateText(CLabel &label,const string text)
  {
   if(label.Text()==text)
      return;
   label.SetText(text);
   label.Draw(false);
  }
 void CTradeSetupBox::Setup(const datetime time_left,const int bars,const double entry,const double stop)
  {
   this.m_time_left=time_left;
   this.m_symbol=::ChartSymbol(this.ChartID());
   this.m_period=(ENUM_TIMEFRAMES)::ChartPeriod(this.ChartID());
   this.m_bars=(bars<this.MinBars() ? this.MinBars() : bars);
   this.m_entry=entry;
   this.m_stop=stop;
   this.m_side=(stop<entry ? SIGNAL_BUY : SIGNAL_SELL);
   this.UpdateTarget();
   this.ShowType();
   this.Apply();
  }
 void CTradeSetupBox::SetLevels(const int count)
  {
   this.m_levels=(count<1 ? 1 : count>RISK_REWARD_RATIOS_TOTAL ? RISK_REWARD_RATIOS_TOTAL : count);
   this.UpdateTarget();
   this.m_combo_ratio.SelectItem(this.m_levels-1);
   this.Apply();
  }
 void CTradeSetupBox::SetRiskPercent(const double percent)
  {
   this.m_risk_percent=percent;
   this.Apply();
  }
 void CTradeSetupBox::SetLots(const double lots)
  {
   this.m_lots=lots;
   this.m_lots_shown=-2.0;
   this.Apply();
  }
 void CTradeSetupBox::SetUseRisk(const bool use)
  {
   this.m_use_risk=use;
   this.m_check_risk.SetState(use);
   this.Apply();
  }
 void CTradeSetupBox::Show(void)
  {
   this.m_visible=true;
   this.Apply();
  }
 void CTradeSetupBox::Hide(void)
  {
   this.m_visible=false;
   this.m_drag=TSB_NONE;
   this.m_hover=TSB_NONE;
   this.SetGrab(false);
   this.Apply();
  }
 //--- Lots: min step x 1, 2, 3, 5, 10... up to the free margin
 void CTradeSetupBox::BuildLotChoices(void)
  {
   string symbol=::ChartSymbol(this.ChartID());
   double step=::SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double lo=::SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   double hi=::SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   if(step<=0.0)
      step=0.01;
   if(lo<=0.0)
      lo=step;
   double margin=0.0;
   double max_lots=hi;
   if(::OrderCalcMargin(ORDER_TYPE_BUY,symbol,1.0,::SymbolInfoDouble(symbol,SYMBOL_ASK),margin) && margin>0.0)
      max_lots=::MathMin(hi,::AccountInfoDouble(ACCOUNT_MARGIN_FREE)/margin);
   int multiples[]={1,2,3,5,10,20,30,50,100,200,300,500,1000};
   ::ArrayResize(this.m_lot_choices,0);
   for(int i=0;i<ArraySize(multiples);i++)
     {
      double lots=::NormalizeDouble(lo+(multiples[i]-1)*step,2);
      if(lots>max_lots+1e-9 && ArraySize(this.m_lot_choices)>0)
         break;
      int n=ArraySize(this.m_lot_choices);
      ::ArrayResize(this.m_lot_choices,n+1);
      this.m_lot_choices[n]=lots;
     }
  }
 //--- The icon and the button say Buy or Sell; the button has the colour of the side
 void CTradeSetupBox::ShowType(void)
  {
   bool buy=this.IsBuy();
   color back=(buy ? TSB_COLOR_BUY : TSB_COLOR_SELL);
   this.m_button_type.IconFile(buy ? IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG : IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG);
   this.m_button_type.Draw(true);
   this.m_button_OrderSend.SetText(buy ? "BUY" : "SELL");
   this.m_button_OrderSend.GetBackColorControl().InitColors(back,back,back,clrLightGray);
   this.m_button_OrderSend.GetForeColorControl().InitColors(clrWhite,clrWhite,clrWhite,clrGray);
   this.m_button_OrderSend.ColorChange(COLOR_STATE_DEFAULT);
   this.m_button_OrderSend.Draw(true);
  }
 //--- The lot combo shows the computed lots with RPT, else the nearest choice to the fixed lots
 void CTradeSetupBox::ShowLots(const double lots)
  {
   double key=(this.m_use_risk ? lots : -1.0);
   if(key==this.m_lots_shown)
      return;
   this.m_lots_shown=key;
   if(this.m_use_risk)
     {
      this.m_combo_lots.SetText(::DoubleToString(lots,2));
      return;
     }
   int nearest=0;
   for(int i=0;i<ArraySize(this.m_lot_choices);i++)
      if(::MathAbs(this.m_lot_choices[i]-this.m_lots)<::MathAbs(this.m_lot_choices[nearest]-this.m_lots))
         nearest=i;
   this.m_combo_lots.SelectItem(nearest);
  }
 //--- What the user chose: the Target (levels) and the check box
 void CTradeSetupBox::ReadBar(void)
  {
   int levels=this.m_combo_ratio.GetListViewPointer().SelectedItemIndex()+1;
   if(levels>=1 && levels!=this.m_levels)
     {
      this.m_levels=levels;
      this.UpdateTarget();
      this.m_changes++;
     }
   bool use=this.m_check_risk.State();
   if(use!=this.m_use_risk)
     {
      this.m_use_risk=use;
      this.m_changes++;
     }
   this.Apply();
   ::ChartRedraw(this.ChartID());
  }
 //+------------------------------------------------------------------+
 //| All the children on the chart or off it; a combo box is shown    |
 //| only when it was hidden (Show closes an open list)               |
 //+------------------------------------------------------------------+
 void CTradeSetupBox::SetShown(const bool shown)
  {
   if(shown==this.m_shown)
      return;
   this.m_shown=shown;
   this.m_Rectangle_TakeProfit.SetVisibleFlag(shown,false);
   this.m_Rectangle_StopLost.SetVisibleFlag(shown,false);
   this.m_Rectangle_StopLostBox.SetVisibleFlag(shown,false);
   this.m_Rectangle_TakeProfitBox.SetVisibleFlag(shown,false);
   this.m_Rectangle_strip.SetVisibleFlag(shown,false);
   if(!shown)
     {
      for(int i=0;i<RISK_REWARD_RATIOS_TOTAL;i++)
        {
         this.m_tp_line[i].SetVisibleFlag(false,false);
         this.m_tp_text[i].SetVisibleFlag(false,false);
        }
      this.m_tp_shown=0;
      this.m_Line_Guide.SetVisibleFlag(false,false);
      this.m_guide_shown=false;
     }
   if(shown)
     {
      this.m_Label_StopLost.Show();
      this.m_Label_TakeProfit.Show();
      this.m_label_rrr.Show();
      this.m_label_pnl.Show();
      this.m_button_type.Show();
      this.m_combo_ratio.Show();
      this.m_check_risk.Show();
      this.m_combo_lots.Show();
      this.m_button_OrderSend.Show();
      this.m_button_grip.Show();
      this.m_button_close.Show();
     }
   else
     {
      this.m_Label_StopLost.Hide();
      this.m_Label_TakeProfit.Hide();
      this.m_label_rrr.Hide();
      this.m_label_pnl.Hide();
      this.m_button_type.Hide();
      this.m_combo_ratio.Hide();
      this.m_check_risk.Hide();
      this.m_combo_lots.Hide();
      this.m_button_OrderSend.Hide();
      this.m_button_grip.Hide();
      this.m_button_close.Hide();
     }
  }
 //--- Everything to its place: pixels first, then the texts, the natives, the controls
 void CTradeSetupBox::Apply(void)
  {
   if(!this.m_visible || !this.Layout())
     {
      this.SetShown(false);
      return;
     }
   this.SetShown(true);
   this.UpdateTexts();
   this.PlaceNative();
   this.PlaceControls();
  }
 //+------------------------------------------------------------------+
 //| The take profit levels: the k-th ratio of the enum times the     |
 //| Stop distance, on the other side of the entry price than the Stop|
 //+------------------------------------------------------------------+
 double CTradeSetupBox::LevelRatio(const int level) const
  {
   return RiskRewardRatioValue((ENUM_RISK_REWARD_RATIO)level);
  }
 double CTradeSetupBox::LevelPrice(const int level) const
  {
   double direction=(this.m_stop<this.m_entry ? 1.0 : -1.0);   // a Buy: the levels are above the entry
   return this.Snap(this.m_entry+direction*this.LevelRatio(level)*::MathAbs(this.m_entry-this.m_stop));
  }
 void CTradeSetupBox::UpdateTarget(void)
  {
   this.m_target=this.LevelPrice(this.m_levels-1);
  }
 void CTradeSetupBox::SetCovered(const bool covered)
  {
   this.m_covered=covered;
   if(covered && this.m_drag==TSB_NONE)
     {
      this.m_hover=TSB_NONE;
      this.SetGrab(false);
     }
  }
 //--- The chart must not scroll while the cursor is on a part of the box
 void CTradeSetupBox::SetGrab(const bool on)
  {
   if(on==this.m_grab)
      return;
   this.m_grab=on;
   if(on)
     {
      this.m_saved_scroll=(bool)::ChartGetInteger(this.ChartID(),CHART_MOUSE_SCROLL);
      ::ChartSetInteger(this.ChartID(),CHART_MOUSE_SCROLL,false);
     }
   else
      ::ChartSetInteger(this.ChartID(),CHART_MOUSE_SCROLL,this.m_saved_scroll);
  }
 //+------------------------------------------------------------------+
 //| The symbol: the tick and what a tick of one lot is worth         |
 //+------------------------------------------------------------------+
 double CTradeSetupBox::Tick(void) const
  {
   double tick=::SymbolInfoDouble(::ChartSymbol(this.ChartID()),SYMBOL_TRADE_TICK_SIZE);
   return (tick>0.0 ? tick : ::SymbolInfoDouble(::ChartSymbol(this.ChartID()),SYMBOL_POINT));
  }
 double CTradeSetupBox::TickValue(void) const
  {
   return ::SymbolInfoDouble(::ChartSymbol(this.ChartID()),SYMBOL_TRADE_TICK_VALUE);
  }
 double CTradeSetupBox::Snap(const double price) const
  {
   double tick=this.Tick();
   return (tick>0.0 ? ::NormalizeDouble(::MathRound(price/tick)*tick,(int)::SymbolInfoInteger(::ChartSymbol(this.ChartID()),SYMBOL_DIGITS)) : price);
  }
 double CTradeSetupBox::LossPerLot(void) const
  {
   return (::MathAbs(this.m_entry-this.m_stop)/this.Tick())*this.TickValue();
  }
 //--- Lots: risk of the balance / loss of one lot at the Stop, or the fixed lots; rounded to the step
 double CTradeSetupBox::LotsToTrade(void) const
  {
   string symbol=::ChartSymbol(this.ChartID());
   double lots=this.m_lots;
   double per_lot=this.LossPerLot();
   if(this.m_use_risk && this.m_risk_percent>0.0 && per_lot>0.0)
      lots=::AccountInfoDouble(ACCOUNT_BALANCE)*this.m_risk_percent/100.0/per_lot;
   double step=::SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double lo=::SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   double hi=::SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   if(step>0.0)
      lots=::MathFloor(lots/step+1e-9)*step;
   lots=(lots<lo ? lo : lots>hi && hi>0.0 ? hi : lots);
   return ::NormalizeDouble(lots,2);
  }
 string CTradeSetupBox::Money(const double value) const
  {
   return ::DoubleToString(value,2);
  }
 //--- "1:1", "1:1.5", "1:3"
 string CTradeSetupBox::RatioText(const double ratio) const
  {
   return "1:"+(ratio==::MathFloor(ratio) ? ::DoubleToString(ratio,0) : ::DoubleToString(ratio,1));
  }
 //--- "price distance (percent of the entry) ticks"
 string CTradeSetupBox::Distance(const double from,const double to) const
  {
   int digits=(int)::SymbolInfoInteger(::ChartSymbol(this.ChartID()),SYMBOL_DIGITS);
   double diff=::MathAbs(to-from);
   double percent=(from!=0.0 ? 100.0*diff/::MathAbs(from) : 0.0);
   return ::DoubleToString(diff,digits)+" ("+::DoubleToString(percent,3)+"%) "+::DoubleToString(diff/this.Tick(),0);
  }
 int CTradeSetupBox::CloseX(void) const
  {
   int chart_w=(int)::ChartGetInteger(this.ChartID(),CHART_WIDTH_IN_PIXELS);
   int x=this.m_xr-2-M_ICON16_WIDTH;
   return ::MathMax(this.m_xl+this.BarWidth(),::MathMin(x,chart_w-2-M_ICON16_WIDTH));
  }
 int CTradeSetupBox::TextWidth(const string text) const
  {
   uint w=0,h=0;
   ::TextSetFont(DEF_FONT,-DEF_FONT_SIZE*10);
   ::TextGetSize(text,w,h);
   return (int)w;
  }
 int CTradeSetupBox::SlotWidth(void) const
  {
   return (int)(1<<(int)::ChartGetInteger(this.ChartID(),CHART_SCALE));
  }
 int CTradeSetupBox::MinBars(void) const
  {
   int slot=this.SlotWidth();
   int pad=2*M_CONTROL_BORDER_GAP+8;
   int need=this.BarWidth()+this.m_text_w[2]+3*M_CONTROL_BORDER_GAP+M_ICON16_WIDTH+4;   // the bar, the P&L, the close icon
   need=::MathMax(need,this.m_text_w[0]+pad);                                       // the Stop text
   need=::MathMax(need,this.m_text_w[1]+pad);                                       // the Target text
   return (need+slot-1)/slot;
  }
 //--- The time of a bar by its shift; a negative shift is the future
 datetime CTradeSetupBox::TimeAtShift(const int shift) const
  {
   string symbol=::ChartSymbol(this.ChartID());
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::ChartPeriod(this.ChartID());
   if(shift>=0)
      return ::iTime(symbol,tf,shift);
   return ::iTime(symbol,tf,0)+(datetime)(-shift*::PeriodSeconds(tf));
  }
 //+------------------------------------------------------------------+
 //| Where everything is, in chart pixels; false when the left bar or |
 //| the prices are not on the screen                                 |
 //+------------------------------------------------------------------+
 bool CTradeSetupBox::Layout(void)
  {
   if(this.m_time_left==0 || this.m_entry==0.0 || this.m_symbol!=::ChartSymbol(this.ChartID()))
      return false;   // not set, or the box belongs to another symbol
   int dummy=0;
   if(!::ChartTimePriceToXY(this.ChartID(),this.m_subwindow,this.m_time_left,this.m_entry,this.m_xl,this.m_y_entry))
      return false;
   if(!::ChartTimePriceToXY(this.ChartID(),this.m_subwindow,this.m_time_left,this.m_stop,dummy,this.m_y_StopLost) ||
      !::ChartTimePriceToXY(this.ChartID(),this.m_subwindow,this.m_time_left,this.m_target,dummy,this.m_y_TakeProfit))
      return false;
   this.m_bars_used=(this.m_bars<this.MinBars() ? this.MinBars() : this.m_bars);
   this.m_xr=this.m_xl+this.m_bars_used*this.SlotWidth();
   this.m_Box_strip_y=this.m_y_entry-M_CONTROL_HEIGHT/2;
   this.m_Box_StopLost_w=this.m_xr-this.m_xl;   // the two boxes are as wide as the strip
   this.m_Box_TakeProfit_w=this.m_Box_StopLost_w;
   this.m_Box_StopLost_y=(this.m_y_StopLost>this.m_y_entry ? this.m_y_StopLost : this.m_y_StopLost-M_CONTROL_HEIGHT);       // below its edge for a Buy, above for a Sell
   this.m_Box_TakeProfit_y=(this.m_y_TakeProfit>this.m_y_entry ? this.m_y_TakeProfit : this.m_y_TakeProfit-M_CONTROL_HEIGHT);
   return true;
  }
 //--- The texts of the two boxes, the P&L and the lots
 void CTradeSetupBox::UpdateTexts(void)
  {
   double lots=this.LotsToTrade();
   double tp_ticks=::MathAbs(this.m_target-this.m_entry)/this.Tick();
   double gain=lots*tp_ticks*this.TickValue();
   double loss=lots*this.LossPerLot();
   string stop_text="StopLost: "+this.Distance(this.m_entry,this.m_stop)+", Amount: "+this.Money(loss);
   string target_text="TakeProfit"+(string)this.m_levels+" "+this.RatioText(this.LevelRatio(this.m_levels-1))+": "+this.Distance(this.m_entry,this.m_target)+", Amount: "+this.Money(gain);
   this.m_text_w[0]=this.TextWidth(stop_text);
   this.m_text_w[1]=this.TextWidth(target_text);
   this.UpdateText(this.m_Label_StopLost,stop_text);
   this.UpdateText(this.m_Label_TakeProfit,target_text);
   this.UpdatePnl(lots);
   this.ShowLots(lots);
  }
 //--- The open profit of the planned trade at the price now
 void CTradeSetupBox::UpdatePnl(const double lots)
  {
   bool buy=this.IsBuy();
   double now=::SymbolInfoDouble(::ChartSymbol(this.ChartID()),buy ? SYMBOL_BID : SYMBOL_ASK);
   double pnl=(now-this.m_entry)*(buy ? 1.0 : -1.0)/this.Tick()*this.TickValue()*lots;
   string text="P&L "+this.Money(pnl);
   this.m_text_w[2]=this.TextWidth(text);
   this.UpdateText(this.m_label_pnl,text);
  }
 //+------------------------------------------------------------------+
 //| The native children: the zones and the lines by time and price,  |
 //| the strip and the two boxes by pixel                             |
 //+------------------------------------------------------------------+
 void CTradeSetupBox::PlaceBox(CGStdRectangleObj &box,const int y_top,const datetime t_right)
  {
   double high=::ChartGetDouble(this.ChartID(),CHART_PRICE_MAX,this.m_subwindow);   // price of a pixel row by the scale of the chart: it works off the screen too
   double low=::ChartGetDouble(this.ChartID(),CHART_PRICE_MIN,this.m_subwindow);
   double height=(double)::ChartGetInteger(this.ChartID(),CHART_HEIGHT_IN_PIXELS,this.m_subwindow);
   if(height<=0.0)
      return;
   double top=high-(high-low)*y_top/height;
   double bottom=high-(high-low)*(y_top+M_CONTROL_HEIGHT)/height;
   box.SetTime(this.m_time_left,0);
   box.SetPrice(top,0);
   box.SetTime(t_right,1);
   box.SetPrice(bottom,1);
  }
 void CTradeSetupBox::PlaceNative(void)
  {
   bool buy=this.IsBuy();
   int shift=::iBarShift(this.m_symbol,(ENUM_TIMEFRAMES)::ChartPeriod(this.ChartID()),this.m_time_left,false);
   datetime t_right=this.TimeAtShift(shift-this.m_bars_used);
   this.m_Rectangle_TakeProfit.SetTime(this.m_time_left,0);
   this.m_Rectangle_TakeProfit.SetPrice(this.m_entry,0);
   this.m_Rectangle_TakeProfit.SetTime(t_right,1);
   this.m_Rectangle_TakeProfit.SetPrice(this.m_target,1);
   this.m_Rectangle_StopLost.SetTime(this.m_time_left,0);
   this.m_Rectangle_StopLost.SetPrice(this.m_entry,0);
   this.m_Rectangle_StopLost.SetTime(t_right,1);
   this.m_Rectangle_StopLost.SetPrice(this.m_stop,1);
   //--- a dotted line and its name at each take profit level; the last one is the edge of the zone
   int want=this.m_levels-1;
   for(int k=0;k<RISK_REWARD_RATIOS_TOTAL;k++)
     {
      bool on=(k<want);
      if(on)
        {
         double price=this.LevelPrice(k);
         this.m_tp_line[k].SetTime(this.m_time_left,0);
         this.m_tp_line[k].SetPrice(price,0);
         this.m_tp_line[k].SetTime(t_right,1);
         this.m_tp_line[k].SetPrice(price,1);
         this.m_tp_text[k].SetTime(t_right,0);
         this.m_tp_text[k].SetPrice(price,0);
         this.m_tp_text[k].SetText("TP"+(string)(k+1)+" "+this.RatioText(this.LevelRatio(k)));
         this.m_tp_text[k].SetAnchor(buy ? ANCHOR_RIGHT_UPPER : ANCHOR_RIGHT_LOWER);
        }
      if(on!=(k<this.m_tp_shown))
        {
         this.m_tp_line[k].SetVisibleFlag(on,false);
         this.m_tp_text[k].SetVisibleFlag(on,false);
        }
     }
   this.m_tp_shown=want;
   this.PlaceBox(this.m_Rectangle_StopLostBox,this.m_Box_StopLost_y,t_right);
   this.PlaceBox(this.m_Rectangle_TakeProfitBox,this.m_Box_TakeProfit_y,t_right);
   this.PlaceBox(this.m_Rectangle_strip,this.m_Box_strip_y,t_right);
   //--- the guide line: only while the Stop is dragged
   bool guide=(this.m_drag==TSB_STOP || this.m_drag==TSB_BODY);
   if(guide)
     {
      double level=(this.m_drag==TSB_STOP ? this.m_stop : this.m_entry);   // the Stop, or the entry when the whole box moves
      this.m_Line_Guide.SetColor(this.m_drag==TSB_STOP ? TSB_COLOR_STOP : clrDimGray);
      this.m_Line_Guide.SetTime(this.m_time_left,0);
      this.m_Line_Guide.SetPrice(level,0);
      this.m_Line_Guide.SetTime(t_right,1);
      this.m_Line_Guide.SetPrice(level,1);
     }
   if(guide!=this.m_guide_shown)
     {
      this.m_guide_shown=guide;
      this.m_Line_Guide.SetVisibleFlag(guide,false);
     }
  }
 //--- The controls: the bar in the strip from its left end, the texts on their boxes
 void CTradeSetupBox::PlaceControls(void)
  {
   int x=this.m_xl,y=this.m_Box_strip_y;
   this.m_Label_StopLost.Resize(this.m_Box_StopLost_w,M_CONTROL_HEIGHT);
   this.m_Label_StopLost.Move(this.m_xl,this.m_Box_StopLost_y);
   this.m_Label_TakeProfit.Resize(this.m_Box_TakeProfit_w,M_CONTROL_HEIGHT);
   this.m_Label_TakeProfit.Move(this.m_xl,this.m_Box_TakeProfit_y);
   this.m_button_grip.Move(this.GripX(),y);
   x+=M_ICON16_WIDTH;
   this.m_button_type.Move(x,y);
   x+=M_ICON16_WIDTH;
   this.m_label_rrr.Move(x,y);
   x+=TSB_CAPTION_W;
   this.m_combo_ratio.Move(x,y);
   x+=M_TF_WITHICON_WIDTH+M_CONTROL_BORDER_GAP;
   this.m_check_risk.Move(x,y);
   x+=TSB_RPT_W+M_CONTROL_BORDER_GAP;
   this.m_combo_lots.Move(x,y);
   x+=M_LOT_WIDTH+M_CONTROL_BORDER_GAP;
   this.m_button_OrderSend.Move(x,y);
   x+=TSB_SEND_W+M_CONTROL_BORDER_GAP;
   this.m_label_pnl.Move(x,y);
   this.m_button_close.Move(this.CloseX(),y);
  }
 //+------------------------------------------------------------------+
 //| The part of the box at this pixel: the Stop box, then the grip   |
 //| icon                                                             |
 //+------------------------------------------------------------------+
 ENUM_TSB_PART CTradeSetupBox::PartAt(const int x,const int y)
  {
   if(!this.m_shown)
      return TSB_NONE;
   if(x>=this.m_xl && x<this.m_xl+this.m_Box_StopLost_w && y>=this.m_Box_StopLost_y && y<this.m_Box_StopLost_y+M_CONTROL_HEIGHT)
      return TSB_STOP;
   if(x>=this.GripX() && x<this.GripX()+M_ICON16_WIDTH && y>=this.m_Box_strip_y && y<this.m_Box_strip_y+M_CONTROL_HEIGHT)
      return TSB_BODY;
   return TSB_NONE;
  }
 //--- The price and the time under a pixel
 bool CTradeSetupBox::PriceAt(const int x,const int y,double &price,datetime &time) const
  {
   int sub=this.m_subwindow;
   return ::ChartXYToTimePrice(this.ChartID(),x,y,sub,time,price);
  }
 //--- Buy <-> Sell: the Stop goes to the other side of the entry
 void CTradeSetupBox::Flip(void)
  {
   this.m_stop=this.Snap(2.0*this.m_entry-this.m_stop);
   this.m_side=(this.m_side==SIGNAL_BUY ? SIGNAL_SELL : SIGNAL_BUY);
   this.UpdateTarget();
  }
 //+------------------------------------------------------------------+
 //| The mouse moves while a part is held                             |
 //+------------------------------------------------------------------+
 void CTradeSetupBox::Drag(const int x,const int y)
  {
   double price=0.0;
   datetime time=0;
   if(!this.PriceAt(x,y,price,time))
      return;
   double tick=this.Tick();
   bool buy=(this.m_press_stop<this.m_press_entry);
   switch(this.m_drag)
     {
      case TSB_STOP:   // under the entry for a Buy, over it for a Sell: never through the entry price
         this.m_stop=this.Snap(buy ? ::MathMin(price,this.m_entry-tick) : ::MathMax(price,this.m_entry+tick));
         this.UpdateTarget();
         break;
      case TSB_BODY:
        {
         double moved=price-this.m_press_price;
         this.m_entry=this.Snap(this.m_press_entry+moved);
         this.m_stop=this.Snap(this.m_press_stop+moved);
         this.UpdateTarget();
         int bars=(int)::MathRound((double)(x-this.m_press_x)/this.SlotWidth());   // right = newer bars = smaller shift
         int shift=this.m_press_shift-bars;
         datetime t=::iTime(::ChartSymbol(this.ChartID()),(ENUM_TIMEFRAMES)::ChartPeriod(this.ChartID()),shift<0 ? 0 : shift);
         if(t>0)
            this.m_time_left=t;
         break;
        }
      default:
         break;
     }
   this.m_changes++;
   this.Apply();
   ::ChartRedraw(this.ChartID());
  }
 //--- Timeframe: the box keeps its width in time; another symbol: it waits
 void CTradeSetupBox::OnChartChange(void)
  {
   ENUM_TIMEFRAMES period=(ENUM_TIMEFRAMES)::ChartPeriod(this.ChartID());
   if(::ChartSymbol(this.ChartID())==this.m_symbol && period!=this.m_period)
     {
      this.m_bars=(int)::MathRound((double)this.m_bars*::PeriodSeconds(this.m_period)/::PeriodSeconds(period));
      this.m_bars=(this.m_bars<this.MinBars() ? this.MinBars() : this.m_bars);
      this.m_period=period;
     }
   this.Apply();
  }
 //+------------------------------------------------------------------+
 //| The children hear the events first; then a click of a child, the |
 //| chart change and the mouse: the left button takes a part         |
 //+------------------------------------------------------------------+
 void CTradeSetupBox::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   for(int i=0;i<this.ChildrenTotal();i++)
      this.Child(i).OnChartEvent(id,lparam,dparam,sparam);
   if(id>=CHARTEVENT_CUSTOM && this.m_shown)
     {
      ushort event=(ushort)(id-CHARTEVENT_CUSTOM);
      if(event==(ushort)ON_CLICK_LIST_ITEM && lparam==(long)this.m_combo_lots.GetListViewPointer().ObjectID())
        {
         this.m_lots=::StringToDouble(this.m_combo_lots.GetValue());   // a chosen lot turns the RPT off
         this.m_use_risk=false;
         this.m_check_risk.SetState(false);
         this.m_changes++;
         this.Apply();
         ::ChartRedraw(this.ChartID());
        }
      else if(event==(ushort)ON_CLICK_LIST_ITEM || event==(ushort)ON_CLICK_CHECKBOX)
         this.ReadBar();
      else if(event==(ushort)ON_CLICK_BUTTON)
        {
         if(lparam==(long)this.m_button_type.ObjectID())
           {
            this.Flip();
            this.ShowType();
            this.m_changes++;
            this.Apply();
            ::ChartRedraw(this.ChartID());
           }
         else if(lparam==(long)this.m_button_OrderSend.ObjectID())
            ::EventChartCustom(this.ChartID(),(ushort)ON_TRADE_SETUP_SEND,(long)this.m_side,this.LotsToTrade(),this.m_symbol);
         else if(lparam==(long)this.m_button_close.ObjectID())
           {
            ::EventChartCustom(this.ChartID(),(ushort)ON_TRADE_SETUP_CLOSE,(long)this.m_side,0.0,this.m_symbol);
            this.Hide();
            ::ChartRedraw(this.ChartID());
           }
        }
      return;
     }
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      this.OnChartChange();
      return;
     }
   if(id!=CHARTEVENT_MOUSE_MOVE || !this.m_shown)
      return;
   int x=(int)lparam,y=(int)dparam;
   bool left=((((int)::StringToInteger(sparam))&MOUSE_BUTT_KEY_STATE_LEFT)!=0);
   if(this.m_drag!=TSB_NONE)
     {
      if(left)
         this.Drag(x,y);
      else
        {
         this.m_drag=TSB_NONE;
         this.SetGrab(this.PartAt(x,y)!=TSB_NONE);
         this.Apply();   // the guide line goes
         ::ChartRedraw(this.ChartID());
        }
      this.m_prev_left=left;
      return;
     }
   ENUM_TSB_PART part=(this.m_covered ? TSB_NONE : this.PartAt(x,y));
   this.m_hover=part;
   this.SetGrab(part!=TSB_NONE);
   if(part!=TSB_NONE && left && !this.m_prev_left)
     {
      double price=0.0;
      datetime time=0;
      this.PriceAt(x,y,price,time);
      this.m_press_x=x;
      this.m_press_y=y;
      this.m_press_price=price;
      this.m_press_entry=this.m_entry;
      this.m_press_stop=this.m_stop;
      this.m_press_shift=::iBarShift(::ChartSymbol(this.ChartID()),(ENUM_TIMEFRAMES)::ChartPeriod(this.ChartID()),this.m_time_left,false);
      this.m_drag=part;
     }
   this.m_prev_left=left;
  }
 //--- The P&L follows the price; a resize of the chart has no event of its own
 void CTradeSetupBox::OnTimerEvent(void)
  {
   for(int i=0;i<this.ChildrenTotal();i++)
      this.Child(i).OnTimerEvent();
   if(!this.m_shown)
      return;
   this.UpdatePnl(this.LotsToTrade());
   if(this.m_bars_used!=(this.m_bars<this.MinBars() ? this.MinBars() : this.m_bars))   // a longer text widens the box
      this.Apply();
   int w=(int)::ChartGetInteger(this.ChartID(),CHART_WIDTH_IN_PIXELS);
   int h=(int)::ChartGetInteger(this.ChartID(),CHART_HEIGHT_IN_PIXELS);
   if(w==this.m_last_chart_w && h==this.m_last_chart_h)
      return;
   this.m_last_chart_w=w;
   this.m_last_chart_h=h;
   this.Apply();
  }
#endif // CTRADESETUPBOX_COMPOSITE_IMPLEMENTATION
#endif // __TRADESETUPBOX_COMPOSITE_MQH__
