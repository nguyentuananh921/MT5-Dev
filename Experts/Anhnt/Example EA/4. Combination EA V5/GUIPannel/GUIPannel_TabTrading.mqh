//+------------------------------------------------------------------+
//|                                          GUIPannel_TabTrading.mqh |
//| The Trading tab (Concepts.md, Trading). The top row: Auto and     |
//| Manual, the two ways of the Entry; Risk, Setting_Risk for every   |
//| position (the Automation Entry and the Manual Entry alike); Trade |
//| Manage. Each of the three is the pinned header of its CSections:  |
//| one open at a time, its body over the width of the tab.           |
//| m_sections_trade_automation_setting = Auto (the strategies of     |
//| Setting_Risk.EntryStrategies); m_sections_trade_manual_settup =   |
//| Manual (the Entry by hand) and Action in it (the positions        |
//| closed); m_sections_trade_risk = Risk (Lot Size, Stop Loss,       |
//| Trailing, the groups of the author), working on RAM (Setting_Risk |
//| written at OnDeinit)                                              |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABTRADING_MQH
#define CGUIPANNEL_TABTRADING_MQH
#include "GUIPannel.mqh"
 //--- A button of a section of m_sections_trade_manual_settup (Open of Manual, the buttons of Action): made at 0,0 hidden, a child of the row (Arrange
 //--- shows it at its place); icon 0: the text only
 bool CGUIPannel::AddButton_TradeManualSetup(const int section,CButton &button,const string text,const uint icon,const string key,const int column,const int row,const int width)
  {
   button.SetText(text);
   if(icon!=0)
      button.IconFile(icon);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,button);
   if(!button.Create(this.m_chart_id,M_SUBWINDOW_MAIN,key,0,0,width,M_CONTROL_HEIGHT))
      return false;
   button.Hide();
   return m_sections_trade_manual_settup.AddControl(section,::GetPointer(button),column,row,row,TRADE_SLOT_ACTION);
  }
 //--- The direction tells the text; Open takes the text and the picture of the direction
 void CGUIPannel::SyncButton_OpenPosition(void)
  {
   const bool buy=m_btn_triggered_manual_trade_dirrection.State();
   m_btn_triggered_manual_trade_dirrection.SetText(buy ? "Buy" : "Sell");
   m_btn_manual_open_position.SetText(buy ? "Open Buy" : "Open Sell");
   m_btn_manual_open_position.IconFile(buy ? IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG : IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG);
   m_btn_triggered_manual_trade_dirrection.Draw(false);
   m_btn_manual_open_position.Draw(false);
  }
 //--- The button of Action of m_label_action_value[index]: Buy, Sell, Lose, Profit, All
 CButton *CGUIPannel::ActionButton(const int index)
  {
   switch(index)
     {
      case 0:  return ::GetPointer(m_btn_manual_close_buy);
      case 1:  return ::GetPointer(m_btn_manual_close_sell);
      case 2:  return ::GetPointer(m_btn_close_lose);
      case 3:  return ::GetPointer(m_btn_close_profit);
      case 4:  return ::GetPointer(m_btn_manual_close_all_Position);
     }
   return NULL;
  }
 //--- The floating profit of what each button of Action closes (green / red by its sign), from RAM (CTradingControl::FloatingProfit: the same positions as
 //--- the close), in the child label of the button (m_label_action_value): only a label whose text changed and is visible is drawn, the button stays.
 //--- The group and its colour are set once at the creation. The View only shows it; called with the caption (ACCOUNT_PROP_PROFIT, a trade)
 //--- MY DEBUG (2026-11-27): SyncButtons_Action 40-70 ms an event with 18 positions and Action open (the whole button drawn); the time of the profits and of
 //--- the Draw, told every 10 s
 ulong g_debug_action_calls=0,g_debug_action_profit_us=0,g_debug_action_draw_us=0,g_debug_action_draws=0,g_debug_action_ms=0;
 ulong g_debug_action_steps[4]={0,0,0,0};   // CGElement::Draw: DrawFrame, DrawImage, DrawContent, m_canvas.Update
 void CGUIPannel::SyncButtons_Action(void)
  {
   if(m_TradingControl==NULL)
      return;
   const ulong debug_t0=::GetMicrosecondCount();
   const string symbol=::Symbol();
   double profits[5];
   profits[0]=m_TradingControl.FloatingProfit(symbol,ORDER_TYPE_BUY);
   profits[1]=m_TradingControl.FloatingProfit(symbol,ORDER_TYPE_SELL);
   profits[2]=m_TradingControl.FloatingProfit(symbol,(ENUM_ORDER_TYPE)WRONG_VALUE,-1);
   profits[3]=m_TradingControl.FloatingProfit(symbol,(ENUM_ORDER_TYPE)WRONG_VALUE,1);
   profits[4]=m_TradingControl.FloatingProfit("",(ENUM_ORDER_TYPE)WRONG_VALUE);
   const ulong debug_t1=::GetMicrosecondCount();
   ulong debug_draw_us=0;
   for(int i=0;i<5;i++)
     {
      //--- the profit in the colour of its sign; a hidden label is drawn at the first call once it is visible (its text cached only when drawn)
      CLabel *label=::GetPointer(m_label_action_value[i]);
      if(!label.IsVisible())
         continue;
      string value=(profits[i]>0 ? "+" : "");
      value+=::DoubleToString(profits[i],2);
      if(m_action_value_drawn[i]==value)
         continue;   // only what changed is drawn again (the profit moves at each tick)
      const color value_color=(profits[i]>0 ? M_COLOR_PROFIT : (profits[i]<0 ? M_COLOR_LOSS : clrBlack));
      label.SetText(value);
      label.GetForeColorControl().InitColors(value_color,value_color,value_color,value_color);
      label.ColorChange(COLOR_STATE_DEFAULT);
      ulong debug_steps[4];
      for(int k=0;k<4;k++)
         debug_steps[k]=CGElement::s_debug_draw_us[k];
      const ulong debug_d=::GetMicrosecondCount();
      label.Draw(false);
      debug_draw_us+=::GetMicrosecondCount()-debug_d;
      for(int k=0;k<4;k++)
         g_debug_action_steps[k]+=CGElement::s_debug_draw_us[k]-debug_steps[k];
      g_debug_action_draws++;
      m_action_value_drawn[i]=value;
     }
   //--- MY DEBUG
   g_debug_action_calls++;
   g_debug_action_profit_us+=debug_t1-debug_t0;
   g_debug_action_draw_us+=debug_draw_us;
   const ulong now=::GetTickCount64();
   if(g_debug_action_ms==0)
      g_debug_action_ms=now;
   if(now-g_debug_action_ms>=10000)
     {
      ::Print("MY DEBUG CGUIPannel::SyncButtons_Action: ",g_debug_action_calls," calls, positions ",::PositionsTotal(),": FloatingProfit x5 ",
              ::DoubleToString(g_debug_action_profit_us/1000.0,1)," ms, Draw x",g_debug_action_draws," ",::DoubleToString(g_debug_action_draw_us/1000.0,1),
              " ms (DrawFrame ",::DoubleToString(g_debug_action_steps[0]/1000.0,1)," ms, DrawImage ",::DoubleToString(g_debug_action_steps[1]/1000.0,1),
              " ms, DrawContent ",::DoubleToString(g_debug_action_steps[2]/1000.0,1)," ms, Update ",::DoubleToString(g_debug_action_steps[3]/1000.0,1),
              " ms), label All ",m_label_action_value[4].XSize(),"x",m_label_action_value[4].YSize());
      ::ArrayInitialize(g_debug_action_steps,0);
      g_debug_action_ms=now;
      g_debug_action_calls=0;
      g_debug_action_profit_us=0;
      g_debug_action_draw_us=0;
      g_debug_action_draws=0;
     }
  }
 //--- The button at the end of the top row: it opens the Trade Manage window
 bool CGUIPannel::CreateButton_TradeManage(void)
  {
   m_btn_tradeManage.SetText("Trade Manage");
   m_btn_tradeManage.IconFile(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_btn_tradeManage);
   return m_btn_tradeManage.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnTradeManage",M_TRADING_X_TRADEMANAGE,M_CONTROL_BORDER_GAP,M_BUTTON_TRADEMANAGE_TAB_WIDTH,M_CONTROL_HEIGHT);
  }
 //--- Auto (m_sections_trade_automation_setting): the Automation Entry is only ON / OFF, a row per strategy available (its switch loaded from DB,
 //--- SetIdOn(EntryStrategies) of Setting_Risk); Manual (StrategyID 0) is always ON, not in Auto. Risk (m_sections_trade_risk): Lot Size, Stop Loss,
 //--- Trailing, then a section for each input group of Setting_Risk whose keys have no section above (not V5, Risk Model, Stops and Targets), one open
 //--- at a time. Made after m_sections_trade_manual_settup: PopulateSections_TradingRisk fills both
 bool CGUIPannel::CreateSections_TradingRisk(void)
  {
   if(!m_sections_trade_automation_setting.Create(this.m_chart_id,M_SUBWINDOW_MAIN,&m_tabs_main,TAB_TAB_MAIN_TRADING,"SectionsTradeAuto"))
      return false;
   m_sections_trade_automation_setting.SetTopOffset(M_TRADE_AUTO_TOP);
   m_sections_trade_automation_setting.SetWidth(0);
   m_sections_trade_automation_setting.SetPinnedHeader(0);   // first on the top row
   int auto_columns[TRADE_AUTO_COLUMN_TOTAL]={0,M_TRADE_AUTO_COLUMN_SWITCH};
   m_sections_trade_automation_setting.SetColumns(auto_columns);
   int auto_toggle_x[1]={M_TRADE_AUTO_TOGGLE_X};   // as the toggles of the Indicator tab: on the header
   m_sections_trade_automation_setting.SetToggleColumns(auto_toggle_x);
   //--- The header toggle: ON when a row is ON, turns every row ON / OFF
   uint auto_icons[1]={0};
   bool auto_states[1]={false};
   if(m_sections_trade_automation_setting.AddSection("Auto",auto_icons,auto_states,false)==WRONG_VALUE)   // closed at the start: the header tells what is ON
      return false;
   //--- Risk
   if(!m_sections_trade_risk.Create(this.m_chart_id,M_SUBWINDOW_MAIN,&m_tabs_main,TAB_TAB_MAIN_TRADING,"SectionsTradeRisk"))
      return false;
   m_sections_trade_risk.SetTopOffset(M_TRADE_AUTO_TOP);
   m_sections_trade_risk.SetWidth(0);
   m_sections_trade_risk.SetPinnedHeader(M_TRADE_RISK_PIN_X);
   m_sections_trade_risk.SetNested(true);      // Risk holds Lot Size .. Portfolio Risk
   m_sections_trade_risk.SetAccordion(true);   // one of them open at a time
   int columns[TRADE_MANUAL_COLUMN_TOTAL]={0,M_TRADE_MANUAL_COLUMN_SWITCH,M_TRADE_MANUAL_COLUMN_VALUE,M_TRADE_MANUAL_COLUMN_KEY};
   m_sections_trade_risk.SetColumns(columns);
   int toggle_x[1]={M_TRADE_RISK_TOGGLE_X};
   m_sections_trade_risk.SetToggleColumns(toggle_x);
   const string titles[TRADE_RISK_SECTION_TOTAL]={"Risk","Lot Size","Stop Loss","Trailing"};
   for(int s=0;s<TRADE_RISK_SECTION_TOTAL;s++)
     {
      m_sections_trade_risk.SetHeaderWidth(s==TRADE_RISK_SECTION_RISK ? M_TRADE_RISK_HEADER_WIDTH : 0);   // Risk: short, on the top row
      //--- Lot Size (stays ON), Stop Loss, Trailing (every row ON / OFF): a toggle on the header; Risk: none
      uint icons[];
      bool states[];
      if(s!=TRADE_RISK_SECTION_RISK)
        {
         ::ArrayResize(icons,1);
         ::ArrayResize(states,1);
         icons[0]=0;
         states[0]=false;
        }
      if(m_sections_trade_risk.AddSection(titles[s],icons,states,false)==WRONG_VALUE)   // closed at the start: the headers tell what is ON
         return false;
     }
   ::ArrayResize(m_trade_risk_groups,0);
   CRiskSetting *risk=(m_TradingControl!=NULL ? m_TradingControl.RiskSetting() : NULL);
   for(int k=0;risk!=NULL && k<risk.PropertiesTotal();k++)
     {
      const string group=risk.PropertyGroup(risk.PropertyOfRow(k));
      const int total=::ArraySize(m_trade_risk_groups);
      if(group=="V5" || group=="Risk Model" || group=="Stops and Targets" || (total>0 && m_trade_risk_groups[total-1]==group))
         continue;
      ::ArrayResize(m_trade_risk_groups,total+1);
      m_trade_risk_groups[total]=group;
      //--- The name of the group without its "(...)" (the header is short); Adaptive Risk, Basket Risk, Portfolio Risk: the switch of its Enable key on the header, as Stop Loss
      const bool has_switch=(this.SwitchOfSection_TradeRisk(risk,TRADE_RISK_SECTION_TOTAL+total)!=WRONG_VALUE);
      const int cut=::StringFind(group," (");
      uint icons[];   // empty: no toggle
      bool states[];
      if(has_switch)
        {
         ::ArrayResize(icons,1);
         ::ArrayResize(states,1);
         icons[0]=0;
         states[0]=false;
        }
      if(m_sections_trade_risk.AddSection((cut>0 ? ::StringSubstr(group,0,cut) : group),icons,states,false)==WRONG_VALUE)
         return false;
     }
   this.PopulateSections_TradingRisk();
   return true;
  }
 //--- A row of a section of a tab: [name][switch]; the label has its own slot, the switch the slot given (BodyOf / SetBodyState find it). flag_icon 0: the name only.
 //--- switch_only: the switch alone, no flag (the strategies of Auto)
 bool CGUIPannel::AddRow_TradingRisk(CTabs &tabs,const int tab,CSections &sections,const int section,const int row,const long value,const string text,const int label_width,
                                     const uint flag_icon,const int switch_column,const string key,const int slot,const string param="",const bool switch_only=false)
  {
   CLabel *name=new CLabel();
   if(name==NULL)
      return false;
   name.SetText(text);
   name.LabelXGap(0);
   tabs.AddToElementsArray(tab,name);
   if(!name.Create(this.m_chart_id,M_SUBWINDOW_MAIN,key+"_Name",0,0,label_width,M_CONTROL_HEIGHT))
      return false;
   name.Hide();   // made at 0,0: Arrange shows it at its place
   if(!sections.AddControl(section,name,0,row,value,TRADE_SLOT_LABEL))
      return false;
   if(flag_icon==0 && !switch_only)
      return true;
   CButtonTriggered *toggle=new CButtonTriggered();
   if(toggle==NULL)
      return false;
   if(switch_only)
     {
      //--- Made here, a child of the row as any control (ParentChild.md): the switch only
      toggle.IconFile(IMAGE_RESOURCE_BMP16_SWITCH_OFF_RED_PNG);
      toggle.IconFileLocked(IMAGE_RESOURCE_BMP16_SWITCH_OFF_RED_PNG);
      toggle.IconFilePressed(IMAGE_RESOURCE_BMP16_SWITCH_ON_GREEN_PNG);
      toggle.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_SWITCH_ON_GREEN_PNG);
     }
   else
      sections.FlagSwitch(toggle,flag_icon);
   toggle.SetState(false);   // as the switches of the Indicator tab: the state before Create, the Sync turns the chosen one ON
   tabs.AddToElementsArray(tab,toggle);
   if(!toggle.Create(this.m_chart_id,M_SUBWINDOW_MAIN,key,0,0,(switch_only ? M_TRADE_SWITCH_ONLY_WIDTH : M_FLAG_SWITCH_WIDTH),M_CONTROL_HEIGHT))
      return false;
   toggle.Hide();
   sections.StyleSwitch(toggle);
   return sections.AddControl(section,toggle,switch_column,row,value,slot,param);
  }
 //--- The value of a key of Setting_Risk in the row of a section of a tab: a spin box (as the parameters of the Candle tab); param = the name of the key
 bool CGUIPannel::AddValue_TradingRisk(CTabs &tabs,const int tab,CSections &sections,const int section,const int row,const int column,const long value,const string param,const double number,const string key,
                                       const int digits=2,const double step=0.1)
  {
   CTextEdit *edit=new CTextEdit();
   if(edit==NULL)
      return false;
   edit.SpinEditMode(true);
   edit.Digits(digits);
   edit.StepValue(step);
   edit.MinValue(0);
   edit.MaxValue(1000000);
   edit.Hide();
   tabs.AddToElementsArray(tab,edit);
   if(!edit.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,key,0,0,M_TRADE_KEY_VALUE_WIDTH,M_CONTROL_HEIGHT,M_TRADE_KEY_VALUE_WIDTH))
      return false;
   edit.SetText("");
   edit.SetValue(::DoubleToString(number,digits));
   return sections.AddControl(section,edit,column,row,value,TRADE_SLOT_KEY_VALUE,param);
  }
 //--- An enum key of Setting_Risk in the row of a section of a tab: a combobox of the texts of the author, the item index = the value; param = the name of the key
 bool CGUIPannel::AddEnum_TradingRisk(CTabs &tabs,const int tab,CSections &sections,const int section,const int row,const int column,const long value,const string param,
                                      const string &items[],const int selected,const string key)
  {
   CComboBox *combo=new CComboBox();
   if(combo==NULL)
      return false;
   const int total=::ArraySize(items);
   combo.ItemsTotal(total);
   combo.Hide();
   tabs.AddToElementsArray(tab,combo);
   if(!combo.CreateComboBox(this.m_chart_id,M_SUBWINDOW_MAIN,key,0,0,M_RISK_ENUM_WIDTH,M_CONTROL_HEIGHT,M_RISK_ENUM_WIDTH,M_CONTROL_HEIGHT*total+4))
      return false;
   combo.GetListViewPointer().Rebuilding(total);
   for(int i=0;i<total;i++)
      combo.SetValue(i,items[i]);
   combo.SelectItem(selected>=0 && selected<total ? selected : 0);
   combo.GetListViewPointer().Draw(false);
   return sections.AddControl(section,combo,column,row,value,TRADE_SLOT_KEY_ENUM,param);
  }
 //--- The Enable key whose switch is on the header of a section after Trailing (Adaptive Risk, Basket Risk, Portfolio Risk); WRONG_VALUE: the header has none
 int CGUIPannel::SwitchOfSection_TradeRisk(CRiskSetting *risk,const int section)
  {
   const int g=section-TRADE_RISK_SECTION_TOTAL;
   if(risk==NULL || g<0 || g>=::ArraySize(m_trade_risk_groups))
      return WRONG_VALUE;
   if(m_trade_risk_groups[g]==risk.PropertyGroup(RISK_PROP_ENABLE_ADAPTIVE_RISK))
      return RISK_PROP_ENABLE_ADAPTIVE_RISK;
   if(m_trade_risk_groups[g]==risk.PropertyGroup(RISK_PROP_ENABLE_BASKET_RISK))
      return RISK_PROP_ENABLE_BASKET_RISK;
   if(m_trade_risk_groups[g]==risk.PropertyGroup(RISK_PROP_ENABLE_PORTFOLIO_RISK))
      return RISK_PROP_ENABLE_PORTFOLIO_RISK;
   return WRONG_VALUE;
  }
 //--- The section of m_sections_trade_risk of a key of Setting_Risk, by its meaning: the lists of V5 are the switches of Auto / Stop Loss / Trailing,
 //--- RiskMode and the amount of each mode the rows of Lot Size, the Enable of Adaptive / Basket / Portfolio the switch of its header (WRONG_VALUE: not
 //--- again); the rest of Risk Model in Lot Size, the numbers of Stops and Targets (ATRMultiplier, TakeProfitRatio) in Stop Loss, AllowHedging in Broker
 //--- & Margin Safety, any other key in the section of its group
 int CGUIPannel::SectionOfKey_TradeRisk(CRiskSetting *risk,const int property)
  {
   string group=risk.PropertyGroup(property);
   if(group=="V5" || property==RISK_PROP_RISK_MODE || property==RISK_PROP_ENABLE_ADAPTIVE_RISK || property==RISK_PROP_ENABLE_BASKET_RISK || property==RISK_PROP_ENABLE_PORTFOLIO_RISK)
      return WRONG_VALUE;
   for(int m=0;m<RISK_MODES_TOTAL;m++)
      if(property==::RiskModeValueProperty((ENUM_RISK_MODE)m))
         return WRONG_VALUE;
   if(group=="Risk Model")
      return TRADE_RISK_SECTION_LOTSIZE;
   if(property==RISK_PROP_ATR_MULTIPLIER || property==RISK_PROP_TAKE_PROFIT_RATIO)
      return TRADE_RISK_SECTION_STOPLOSS;
   if(property==RISK_PROP_ALLOW_HEDGING)
      group=risk.PropertyGroup(RISK_PROP_MAX_MARGIN_USAGE_PERCENT);   // Broker & Margin Safety
   for(int g=0;g<::ArraySize(m_trade_risk_groups);g++)
      if(m_trade_risk_groups[g]==group)
         return TRADE_RISK_SECTION_TOTAL+g;
   return WRONG_VALUE;
  }
 //--- The rows: the strategies available (Auto); in Risk the modes of RiskMode and the value of each, each template with the role: Stop Loss PSAR
 //--- (its price) and ATR (x ATRMultiplier), Trailing PSAR; then the other keys of Setting_Risk
 void CGUIPannel::PopulateSections_TradingRisk(void)
  {
   CRiskSetting *risk=(m_TradingControl!=NULL ? m_TradingControl.RiskSetting() : NULL);
   m_sections_trade_automation_setting.ClearBody(TRADE_AUTO_SECTION_AUTO);
   m_sections_trade_risk.ClearBody(TRADE_RISK_SECTION_LOTSIZE);
   m_sections_trade_risk.ClearBody(TRADE_RISK_SECTION_STOPLOSS);
   m_sections_trade_risk.ClearBody(TRADE_RISK_SECTION_TRAILING);
   //--- Auto: a row for each strategy available, its switch = allowed to Open Position (EntryStrategies), the value of the row = strategy_id
   if(m_StrategyManager!=NULL)
     {
      long ids[];
      const int strategies=m_StrategyManager.Read_RAM(ids);
      int row_auto=0;
      for(int i=0;i<strategies;i++)
        {
         CStrategySetting *strategy=m_StrategyManager.Read_RAM(ids[i]);
         if(strategy!=NULL && strategy.SlotsAvailable())
            this.AddRow_TradingRisk(m_tabs_main,TAB_TAB_MAIN_TRADING,m_sections_trade_automation_setting,TRADE_AUTO_SECTION_AUTO,row_auto++,ids[i],strategy.Name(),M_TRADE_AUTO_LABEL_WIDTH,
                                    0,TRADE_AUTO_COLUMN_SWITCH,"AutoEntry"+(string)ids[i],TRADE_AUTO_SECTION_AUTO,"",true);   // the switch only
        }
     }
   for(int i=0;i<RISK_MODES_TOTAL;i++)
     {
      this.AddRow_TradingRisk(m_tabs_main,TAB_TAB_MAIN_TRADING,m_sections_trade_risk,TRADE_RISK_SECTION_LOTSIZE,i,i,::RiskModeText((ENUM_RISK_MODE)i),M_TRADE_MANUAL_LABEL_WIDTH,
                              0,TRADE_MANUAL_COLUMN_SWITCH,"RiskLot"+(string)i,TRADE_RISK_SECTION_LOTSIZE,"",true);   // the switch only
      const int mode_property=::RiskModeValueProperty((ENUM_RISK_MODE)i);   // the amount of the mode (WRONG_VALUE: Fixed lot has none, its lot is chosen in the Manual Entry)
      if(risk!=NULL && mode_property!=WRONG_VALUE)
         this.AddValue_TradingRisk(m_tabs_main,TAB_TAB_MAIN_TRADING,m_sections_trade_risk,TRADE_RISK_SECTION_LOTSIZE,i,TRADE_MANUAL_COLUMN_VALUE,i,
                                   risk.PropertyName(mode_property),risk.Value(mode_property),"RiskLotValue"+(string)i);
     }
   int row_sl=0,row_trail=0;
   if(m_IndicatorTemplateManager!=NULL)
     {
      ENUM_INDICATOR types[];
      string params[],display[];
      bool buy[],sell[],sound[],message[],show[];
      const int total=m_IndicatorTemplateManager.Read_RAM(types,params,display,buy,sell,sound,message,show);
      for(int i=0;i<total;i++)
        {
         const long id=this.RowHandle_IndicatorTemplateSetting(types[i],params[i]);
         if(types[i]==IND_SAR || types[i]==IND_ATR)
            this.AddRow_TradingRisk(m_tabs_main,TAB_TAB_MAIN_TRADING,m_sections_trade_risk,TRADE_RISK_SECTION_STOPLOSS,row_sl++,id,display[i],M_TRADE_MANUAL_LABEL_WIDTH,
                                    0,TRADE_MANUAL_COLUMN_SWITCH,"RiskSL"+(string)id,TRADE_RISK_SECTION_STOPLOSS,"",true);   // the switch only
         if(types[i]==IND_SAR)
            this.AddRow_TradingRisk(m_tabs_main,TAB_TAB_MAIN_TRADING,m_sections_trade_risk,TRADE_RISK_SECTION_TRAILING,row_trail++,id,display[i],M_TRADE_MANUAL_LABEL_WIDTH,
                                    0,TRADE_MANUAL_COLUMN_SWITCH,"RiskTrail"+(string)id,TRADE_RISK_SECTION_TRAILING,"",true);   // the switch only
        }
     }
   //--- Every other key of Setting_Risk (on RAM): under the rows above in Lot Size / Stop Loss, or in the section of its group
   const int groups=::ArraySize(m_trade_risk_groups);
   for(int g=0;g<groups;g++)
      m_sections_trade_risk.ClearBody(TRADE_RISK_SECTION_TOTAL+g);
   int rows[];
   ::ArrayResize(rows,TRADE_RISK_SECTION_TOTAL+groups);
   ::ArrayInitialize(rows,0);
   rows[TRADE_RISK_SECTION_LOTSIZE]=RISK_MODES_TOTAL;
   rows[TRADE_RISK_SECTION_STOPLOSS]=row_sl;
   for(int k=0;risk!=NULL && k<risk.PropertiesTotal();k++)
     {
      const int p=risk.PropertyOfRow(k);
      const int section=this.SectionOfKey_TradeRisk(risk,p);
      if(section!=WRONG_VALUE)
         this.AddKeyRow_RiskSetting(m_tabs_main,TAB_TAB_MAIN_TRADING,m_sections_trade_risk,section,rows[section]++,p,M_TRADE_KEY_LABEL_WIDTH,TRADE_MANUAL_COLUMN_KEY,"TradeKey");
     }
   this.SyncSections_TradingRisk();
   m_sections_trade_automation_setting.Arrange();
   m_sections_trade_risk.Arrange();
  }
 //--- The switches from Setting_Risk: Auto any number ON; Lot Size one ON; Stop Loss, Trailing any number ON (the best price wins)
 void CGUIPannel::SyncSections_TradingRisk(void)
  {
   if(m_TradingControl==NULL)
      return;
   CRiskSetting *risk=m_TradingControl.RiskSetting();
   bool any_on=false;
   if(m_StrategyManager!=NULL)
     {
      long ids[];
      const int strategies=m_StrategyManager.Read_RAM(ids);
      for(int i=0;i<strategies;i++)
        {
         CStrategySetting *strategy=m_StrategyManager.Read_RAM(ids[i]);
         if(strategy==NULL || !strategy.SlotsAvailable())
            continue;
         const bool on=risk.IsIdOn(RISK_PROP_ENTRY_STRATEGIES,ids[i]);
         m_sections_trade_automation_setting.SetBodyState(ids[i],TRADE_AUTO_SECTION_AUTO,on);
         any_on=(any_on || on);
        }
     }
   m_sections_trade_automation_setting.SetToggle(TRADE_AUTO_SECTION_AUTO,0,any_on);   // as the toggles of the Indicator tab: ON when one below is ON
   const int mode=(int)risk.RiskMode();
   for(int i=0;i<RISK_MODES_TOTAL;i++)
      m_sections_trade_risk.SetBodyState(i,TRADE_RISK_SECTION_LOTSIZE,i==mode);
   m_sections_trade_risk.SetToggle(TRADE_RISK_SECTION_LOTSIZE,0,(mode>=0 && mode<RISK_MODES_TOTAL));   // a mode is always ON
   bool any_sl=false,any_trail=false;
   if(m_IndicatorTemplateManager!=NULL)
     {
      ENUM_INDICATOR types[];
      string params[],display[];
      bool buy[],sell[],sound[],message[],show[];
      const int total=m_IndicatorTemplateManager.Read_RAM(types,params,display,buy,sell,sound,message,show);
      for(int i=0;i<total;i++)
        {
         const long id=this.RowHandle_IndicatorTemplateSetting(types[i],params[i]);
         const bool sl_on=risk.IsIdOn(RISK_PROP_STOP_LOSS_TEMPLATES,id);
         const bool trail_on=risk.IsIdOn(RISK_PROP_TRAILING_TEMPLATES,id);
         m_sections_trade_risk.SetBodyState(id,TRADE_RISK_SECTION_STOPLOSS,sl_on);
         m_sections_trade_risk.SetBodyState(id,TRADE_RISK_SECTION_TRAILING,trail_on);
         any_sl=(any_sl || sl_on);
         any_trail=(any_trail || trail_on);
        }
     }
   //--- The toggles of the headers: ON when a base below is ON (the rows tell which)
   m_sections_trade_risk.SetToggle(TRADE_RISK_SECTION_STOPLOSS,0,any_sl);
   m_sections_trade_risk.SetToggle(TRADE_RISK_SECTION_TRAILING,0,any_trail);
   //--- Adaptive Risk, Basket Risk, Portfolio Risk: the switch of the header = its Enable key
   for(int g=0;g<::ArraySize(m_trade_risk_groups);g++)
     {
      const int property=this.SwitchOfSection_TradeRisk(risk,TRADE_RISK_SECTION_TOTAL+g);
      if(property!=WRONG_VALUE)
         m_sections_trade_risk.SetToggle(TRADE_RISK_SECTION_TOTAL+g,0,risk.Value(property)!=0);
     }
   this.SyncValues_TradingRisk(m_sections_trade_risk);
  }
 //--- The switches, the spin boxes, the comboboxes, the text boxes of the keys of Setting_Risk in the sections of a tab (param = the name) take the value on RAM:
 //--- the same key on the Trading tab and on the Risk Management tab shows one value
 void CGUIPannel::SyncValues_TradingRisk(CSections &sections)
  {
   CRiskSetting *risk=(m_TradingControl!=NULL ? m_TradingControl.RiskSetting() : NULL);
   if(risk==NULL)
      return;
   for(int k=0;k<risk.PropertiesTotal();k++)
     {
      const int p=risk.PropertyOfRow(k);
      const string name=risk.PropertyName(p);
      if(risk.IsString(p))
        {
         CTextEdit *text=dynamic_cast<CTextEdit *>(sections.BodyControl(TRADE_SLOT_KEY_TEXT,name));
         if(text!=NULL && text.GetValue()!=risk.Text(p))
            text.SetValue(risk.Text(p));
         continue;
        }
      const double value=risk.Value(p);
      if(risk.PropertyType(p)=="bool")
         sections.SetBodyState(p,TRADE_SLOT_KEY_SWITCH,value!=0);
      CTextEdit *edit=dynamic_cast<CTextEdit *>(sections.BodyControl(TRADE_SLOT_KEY_VALUE,name));
      if(edit!=NULL && ::StringToDouble(edit.GetValue())!=value)
         edit.SetValue(::DoubleToString(value,8));
      CComboBox *combo=dynamic_cast<CComboBox *>(sections.BodyControl(TRADE_SLOT_KEY_ENUM,name));
      if(combo!=NULL)
         combo.SelectItem((int)value);
     }
  }
 //--- The ids (comma-separated) of the bases of a role: Stop Loss PSAR and ATR, Trailing PSAR (as the rows of PopulateSections_TradingRisk)
 string CGUIPannel::BaseIds_TradingRisk(const int section)
  {
   string list="";
   if(m_IndicatorTemplateManager==NULL)
      return list;
   ENUM_INDICATOR types[];
   string params[],display[];
   bool buy[],sell[],sound[],message[],show[];
   const int total=m_IndicatorTemplateManager.Read_RAM(types,params,display,buy,sell,sound,message,show);
   for(int i=0;i<total;i++)
      if(types[i]==IND_SAR || (types[i]==IND_ATR && section==TRADE_RISK_SECTION_STOPLOSS))
         list+=(list=="" ? "" : ",")+(string)this.RowHandle_IndicatorTemplateSetting(types[i],params[i]);
   return list;
  }
 //--- m_sections_trade_manual_settup, the Entry by hand: Manual: [the direction][Open], [Order Type], [SL], [TP], [MaxLot] (the results of the risk for
 //--- that direction), [Lot][the lots up to MaxLot], [Magic]; Action in it: [Buy][Sell], [Lose][Profit], [All], each with the profit of what it closes
 bool CGUIPannel::CreateSections_TradeManualSetup(void)
  {
   if(!m_sections_trade_manual_settup.Create(this.m_chart_id,M_SUBWINDOW_MAIN,&m_tabs_main,TAB_TAB_MAIN_TRADING,"SectionsTradeManualSetup"))
      return false;
   m_sections_trade_manual_settup.SetTopOffset(M_TRADE_AUTO_TOP);
   m_sections_trade_manual_settup.SetWidth(0);
   m_sections_trade_manual_settup.SetPinnedHeader(M_TRADE_MANUAL_PIN_X);   // right of the toggle of Auto, on the top row
   m_sections_trade_manual_settup.SetNested(true);   // Manual holds Action
   int columns[TRADE_MANUAL_COLUMN_TOTAL]={0,M_TRADE_MANUAL_COLUMN_SWITCH,M_TRADE_MANUAL_COLUMN_VALUE,M_TRADE_MANUAL_COLUMN_KEY};
   m_sections_trade_manual_settup.SetColumns(columns);
   int no_toggle[];
   m_sections_trade_manual_settup.SetToggleColumns(no_toggle);
   const string titles[TRADE_MANUAL_SECTION_TOTAL]={"Manual","Action"};
   uint icons[];
   bool states[];
   for(int s=0;s<TRADE_MANUAL_SECTION_TOTAL;s++)
     {
      m_sections_trade_manual_settup.SetHeaderWidth(s==TRADE_MANUAL_SECTION_ENTRY ? M_TRADE_MANUAL_HEADER_WIDTH : 0);   // Manual: short, on the top row
      if(m_sections_trade_manual_settup.AddSection(titles[s],icons,states,false)==WRONG_VALUE)
         return false;
     }
   //--- Entry: the names (the direction has none: its button says Buy / Sell)
   const string names[]={"","Order Type","SL","TP","MaxLot","Lot","Magic"};
   for(int r=1;r<::ArraySize(names);r++)
      if(!this.AddRow_TradingRisk(m_tabs_main,TAB_TAB_MAIN_TRADING,m_sections_trade_manual_settup,TRADE_MANUAL_SECTION_ENTRY,r,r,names[r],M_TRADE_MANUAL_LABEL_WIDTH,0,TRADE_MANUAL_COLUMN_SWITCH,"ManualEntry"+(string)r,TRADE_SLOT_LABEL))
         return false;
   //--- the direction: pressed Buy, released Sell
   m_btn_triggered_manual_trade_dirrection.IconFile(IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG);
   m_btn_triggered_manual_trade_dirrection.IconFileLocked(IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG);
   m_btn_triggered_manual_trade_dirrection.IconFilePressed(IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG);
   m_btn_triggered_manual_trade_dirrection.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG);
   m_btn_triggered_manual_trade_dirrection.SetState(true);   // Buy first
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_btn_triggered_manual_trade_dirrection);
   if(!m_btn_triggered_manual_trade_dirrection.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnManualTradeDirection",0,0,M_TRADE_MANUAL_ENTRY_WIDTH,M_CONTROL_HEIGHT))
      return false;
   m_btn_triggered_manual_trade_dirrection.Hide();
   if(!m_sections_trade_manual_settup.AddControl(TRADE_MANUAL_SECTION_ENTRY,::GetPointer(m_btn_triggered_manual_trade_dirrection),TRADE_MANUAL_COLUMN_LABEL,0,0,TRADE_SLOT_DIRECTION))   // left: the row has no name
      return false;
   //--- Open, next to the direction (its text and icon: SyncButton_OpenPosition)
   if(!this.AddButton_TradeManualSetup(TRADE_MANUAL_SECTION_ENTRY,m_btn_manual_open_position,"",0,"BtnManualOpenPosition",TRADE_MANUAL_COLUMN_SWITCH,0,M_TRADE_MANUAL_ENTRY_WIDTH))
      return false;
   //--- the order type: Market only is sent for now (TRADE_SETUP_EVENT_SEND)
   const string orders[]={"Market","Limit","Stop","Stop Limit"};
   m_combobox_manual_order_type.ItemsTotal(::ArraySize(orders));
   m_combobox_manual_order_type.Hide();
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_combobox_manual_order_type);
   if(!m_combobox_manual_order_type.CreateComboBox(this.m_chart_id,M_SUBWINDOW_MAIN,"CmbManualOrderType",0,0,M_TRADE_MANUAL_ENTRY_WIDTH,M_CONTROL_HEIGHT,M_TRADE_MANUAL_ENTRY_WIDTH,
                                                   M_CONTROL_HEIGHT*::ArraySize(orders)+4))
      return false;
   m_combobox_manual_order_type.GetListViewPointer().Rebuilding(::ArraySize(orders));
   for(int i=0;i<::ArraySize(orders);i++)
      m_combobox_manual_order_type.SetValue(i,orders[i]);
   m_combobox_manual_order_type.SelectItem(m_manual_order_type);
   if(!m_sections_trade_manual_settup.AddControl(TRADE_MANUAL_SECTION_ENTRY,::GetPointer(m_combobox_manual_order_type),TRADE_MANUAL_COLUMN_SWITCH,TRADE_MANUAL_ROW_ORDERTYPE,TRADE_MANUAL_ROW_ORDERTYPE,TRADE_SLOT_ORDERTYPE))
      return false;
   //--- the results: SL, TP, MaxLot
   for(int i=0;i<3;i++)
     {
      CLabel *label=(i==0 ? ::GetPointer(m_label_manual_sl) : (i==1 ? ::GetPointer(m_label_manual_tp) : ::GetPointer(m_label_manual_maxlot)));
      label.LabelXGap(0);
      m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,label);
      if(!label.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"LblManualResult"+(string)i,0,0,M_TRADE_MANUAL_ENTRY_WIDTH,M_CONTROL_HEIGHT))
         return false;
      label.Hide();
      if(!m_sections_trade_manual_settup.AddControl(TRADE_MANUAL_SECTION_ENTRY,label,TRADE_MANUAL_COLUMN_SWITCH,TRADE_MANUAL_ROW_SL+i,TRADE_MANUAL_ROW_SL+i,TRADE_SLOT_RESULT))
         return false;
     }
   //--- the lot: MinLot .. MaxLot
   m_combobox_manual_lot.ItemsTotal(1);
   m_combobox_manual_lot.Hide();
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_combobox_manual_lot);
   if(!m_combobox_manual_lot.CreateComboBox(this.m_chart_id,M_SUBWINDOW_MAIN,"CmbManualLot",0,0,M_TRADE_MANUAL_ENTRY_WIDTH,M_CONTROL_HEIGHT,M_TRADE_MANUAL_ENTRY_WIDTH,140))
      return false;
   if(!m_sections_trade_manual_settup.AddControl(TRADE_MANUAL_SECTION_ENTRY,::GetPointer(m_combobox_manual_lot),TRADE_MANUAL_COLUMN_SWITCH,TRADE_MANUAL_ROW_LOT,TRADE_MANUAL_ROW_LOT,TRADE_SLOT_LOT))
      return false;
   //--- the magic: typed, the EA's first (0: none, as the terminal)
   m_edit_manual_magic.Hide();
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_edit_manual_magic);
   if(!m_edit_manual_magic.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditManualMagic",0,0,M_TRADE_MANUAL_ENTRY_WIDTH,M_CONTROL_HEIGHT,M_TRADE_MANUAL_ENTRY_WIDTH))
      return false;
   m_edit_manual_magic.SetText("");
   if(!m_sections_trade_manual_settup.AddControl(TRADE_MANUAL_SECTION_ENTRY,::GetPointer(m_edit_manual_magic),TRADE_MANUAL_COLUMN_SWITCH,TRADE_MANUAL_ROW_MAGIC,TRADE_MANUAL_ROW_MAGIC,TRADE_SLOT_MAGIC))
      return false;
   //--- Action: Buy / Sell / Lose / Profit the positions of the EA on the chart symbol, All every position of the account; the text: SyncButtons_Action
   if(!this.AddButton_TradeManualSetup(TRADE_MANUAL_SECTION_ACTION,m_btn_manual_close_buy,"Buy",IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG,"BtnManualCloseBuy",TRADE_MANUAL_COLUMN_LABEL,0,M_TRADE_ACTION_WIDTH) ||
      !this.AddButton_TradeManualSetup(TRADE_MANUAL_SECTION_ACTION,m_btn_manual_close_sell,"Sell",IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG,"BtnManualCloseSell",TRADE_MANUAL_COLUMN_SWITCH,0,M_TRADE_ACTION_WIDTH) ||
      !this.AddButton_TradeManualSetup(TRADE_MANUAL_SECTION_ACTION,m_btn_close_lose,"Lose",IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG,"BtnManualCloseLose",TRADE_MANUAL_COLUMN_LABEL,1,M_TRADE_ACTION_WIDTH) ||
      !this.AddButton_TradeManualSetup(TRADE_MANUAL_SECTION_ACTION,m_btn_close_profit,"Profit",IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG,"BtnManualCloseProfit",TRADE_MANUAL_COLUMN_SWITCH,1,M_TRADE_ACTION_WIDTH) ||
      !this.AddButton_TradeManualSetup(TRADE_MANUAL_SECTION_ACTION,m_btn_manual_close_all_Position,"All",IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG,"BtnCloseAllPosition",TRADE_MANUAL_COLUMN_LABEL,2,M_TRADE_ACTION_WIDTH))
      return false;
   //--- Change 2026-11-27 (skills\DRY\DRY_CButton.md): the group in its colour (Buy / Profit green, Sell / Lose red, All black), once; the floating profit in a
   //--- child label at the right half of each button (it moves, shows, hides with the button; no mouse: a click on it is the button's)
   const color colors[5]={M_COLOR_PROFIT,M_COLOR_LOSS,M_COLOR_LOSS,M_COLOR_PROFIT,clrBlack};
   for(int i=0;i<5;i++)
     {
      CButton *button=this.ActionButton(i);
      button.GetForeColorControl().InitColors(colors[i],colors[i],colors[i],colors[i]);
      button.ColorChange(COLOR_STATE_DEFAULT);
      m_action_value_drawn[i]="";
      m_label_action_value[i].LabelRightGap(M_TRADE_ACTION_VALUE_GAP);
      button.AddChild(::GetPointer(m_label_action_value[i]));
      if(!m_label_action_value[i].Create(this.m_chart_id,M_SUBWINDOW_MAIN,"ActionValue"+(string)i,M_TRADE_ACTION_WIDTH/2,2,M_TRADE_ACTION_WIDTH/2-2,M_CONTROL_HEIGHT-4))
         return false;
      m_label_action_value[i].IsAvailable(false);
     }
   this.SyncButton_OpenPosition();
   this.SyncButtons_Action();
   this.SyncSections_TradeManualSetup();
   m_sections_trade_manual_settup.Arrange();
   return true;
  }
 //--- The results of the Automation for the direction chosen (CTradingControl::ManualPlan: the stop of the bases ON, the lot of the risk capped
 //--- by the margin), the lots from MaxLot down by the volume step to MinLot (CSymbol). The View only shows them
 void CGUIPannel::SyncSections_TradeManualSetup(void)
  {
   if(m_TradingControl==NULL || m_SymbolsCollection==NULL)
      return;
   const bool buy=m_btn_triggered_manual_trade_dirrection.State();
   const string symbol=::Symbol();
   CSymbol *symbol_obj=m_SymbolsCollection.GetSymbolObjByName(symbol);
   STradePlan plan;
   const bool ok=m_TradingControl.ManualPlan(symbol,(buy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL),plan);
   const int digits=(symbol_obj!=NULL ? symbol_obj.Digits() : _Digits);
   const double step=(symbol_obj!=NULL ? symbol_obj.LotsStep() : 0.01);
   const double min_lot=(symbol_obj!=NULL ? symbol_obj.LotsMin() : 0.01);
   const int lot_digits=(step>=1.0 ? 0 : (step>=0.1 ? 1 : 2));
   m_label_manual_sl.SetText(ok && plan.stopLoss>0 ? ::DoubleToString(plan.stopLoss,digits) : "none");
   m_label_manual_tp.SetText(ok && plan.takeProfit>0 ? ::DoubleToString(plan.takeProfit,digits) : "none");
   m_label_manual_maxlot.SetText(ok ? ::DoubleToString(plan.lotSize,lot_digits) : "-");
   if(m_label_manual_sl.IsVisible())
      m_label_manual_sl.Draw(false);
   if(m_label_manual_tp.IsVisible())
      m_label_manual_tp.Draw(false);
   if(m_label_manual_maxlot.IsVisible())
      m_label_manual_maxlot.Draw(false);
   //--- the lots: the risk made a plan: MaxLot first, down to MinLot; it did not: MinLot first, up (the lot goes alone, no Strategy role, no Risk:
   //--- CTradingControl::TradeEntry). Fixed lot mode: MinLot first, up to MaxLot (what the margin carries), the lot of the symbol on RAM chosen
   const bool fixed_lot=(m_TradingControl.RiskSetting().RiskMode()==RISK_FIXED_LOT);
   double lots[];
   int total=0;
   if(ok && step>0 && fixed_lot)
      for(double lot=min_lot;lot<=plan.lotSize+step*0.5 && total<M_TRADE_LOT_ITEMS_MAX;lot+=step)
        {
         ::ArrayResize(lots,total+1);
         lots[total++]=lot;
        }
   else if(ok && step>0)
      for(double lot=plan.lotSize;lot>=min_lot-step*0.5 && total<M_TRADE_LOT_ITEMS_MAX;lot-=step)
        {
         ::ArrayResize(lots,total+1);
         lots[total++]=lot;
        }
   else if(step>0)
     {
      const double max_lot=(symbol_obj!=NULL ? symbol_obj.LotsMax() : 0.0);
      for(double lot=min_lot;(max_lot<=0 || lot<=max_lot+step*0.5) && total<M_TRADE_LOT_ITEMS_MAX;lot+=step)
        {
         ::ArrayResize(lots,total+1);
         lots[total++]=lot;
        }
     }
   if(m_edit_manual_magic.GetValue()=="")
      m_edit_manual_magic.SetValue((string)m_TradingControl.MagicIdEA(symbol));   // the EA's until one is typed
   //--- Working on RAM: the list lives in the ListView; it is made again only when it changed (MaxLot, the count), not at each refresh (the open list kept)
   CListView *list=m_combobox_manual_lot.GetListViewPointer();
   const string first=(total>0 ? ::DoubleToString(lots[0],lot_digits) : "-");
   if(list.ItemsTotal()==::MathMax(total,1) && list.GetValue(0)==first)
      return;
   //--- the lot the user chose stays while it is still <= MaxLot; Fixed lot mode: the lot of the symbol on RAM (CTradingControl::FixedLot)
   const string chosen=(fixed_lot ? ::DoubleToString(m_TradingControl.FixedLot(symbol),lot_digits) : m_combobox_manual_lot.GetValue());
   list.Rebuilding(::MathMax(total,1));
   if(total==0)
      m_combobox_manual_lot.SetValue(0,"-");
   int selected=0;
   for(int i=0;i<total;i++)
     {
      const string text=::DoubleToString(lots[i],lot_digits);
      m_combobox_manual_lot.SetValue(i,text);
      if(text==chosen)
         selected=i;
     }
   m_combobox_manual_lot.SelectItem(selected);
   list.Draw(false);
  }
 //--- The top row: Auto, Manual, Risk share the room under it; the one whose pinned header was clicked open closes the other two
 void CGUIPannel::OpenOne_Trading(const long header_id)
  {
   CSections *all[3];
   all[0]=::GetPointer(m_sections_trade_automation_setting);
   all[1]=::GetPointer(m_sections_trade_manual_settup);
   all[2]=::GetPointer(m_sections_trade_risk);
   int opened=WRONG_VALUE;
   for(int i=0;i<3 && opened==WRONG_VALUE;i++)
      if(all[i].SectionOfHeader(header_id)==0 && all[i].IsOpened(0))
         opened=i;
   if(opened==WRONG_VALUE)
      return;
   for(int i=0;i<3;i++)
      if(i!=opened && all[i].IsOpened(0))
        {
         all[i].SetOpened(0,false);
         all[i].Arrange();
        }
   if(opened==1)
      this.SyncButtons_Action();   // Manual shows Action: its numbers of now
  }
 //+------------------------------------------------------------------+
 //| What the user did in the Trading tab                             |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_Trading(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- The sections: arranged again when the tab opens, scrolls, the window changes its size
   m_sections_trade_automation_setting.OnChartEvent(id,lparam,dparam,sparam);
   m_sections_trade_manual_settup.OnChartEvent(id,lparam,dparam,sparam);
   m_sections_trade_risk.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON)
      this.OpenOne_Trading(lparam);
   //--- A template came or went: the rows of the bases again
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED || id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
     {
      this.PopulateSections_TradingRisk();
      this.SyncSections_TradeManualSetup();
      return;
     }
   //--- Auto: a strategy became available or not, its row comes or goes
   if(id==CHARTEVENT_CUSTOM+STRATEGY_MANAGER_EVENT_AVAILABLE_CHANGED)
     {
      this.PopulateSections_TradingRisk();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- The results of the Automation again: a new bar of the chart, a key of Setting_Risk changed (on this tab or the Risk Management tab: the switches
   //--- and the values here follow it)
   if((id==CHARTEVENT_CUSTOM+SERIES_EVENTS_NEW_BAR && sparam==::Symbol() && (int)dparam==(int)::Period()) || id==CHARTEVENT_CUSTOM+RISK_SETTING_EVENT_CHANGED)
     {
      if(id==CHARTEVENT_CUSTOM+RISK_SETTING_EVENT_CHANGED)
         this.SyncSections_TradingRisk();
      this.SyncSections_TradeManualSetup();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- A lot chosen (sparam = the text of the item): the View only tells it (TRADE_SETUP_EVENT_LOT), CTradingControl keeps it on RAM as the lot of
   //--- RISK_FIXED_LOT on the symbol
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_COMBOBOX_ITEM && lparam==m_combobox_manual_lot.ObjectID())
     {
      const double lot=::StringToDouble(sparam);
      if(lot>0.0)
         this.EventSend((ushort)TRADE_SETUP_EVENT_LOT,0,lot,::Symbol());
      return;
     }
   //--- The order type chosen (dparam = the index of the item); Market only is sent for now
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_COMBOBOX_ITEM && lparam==m_combobox_manual_order_type.ObjectID())
     {
      m_manual_order_type=(int)dparam;
      return;
     }
   long row_id;
   int slot;
   string param;
   //--- An ENUM_ key of Setting_Risk (on RAM): dparam = the index of the item = the value of the enum
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_COMBOBOX_ITEM && m_TradingControl!=NULL && m_sections_trade_risk.BodyOf(lparam,row_id,slot,param) && slot==TRADE_SLOT_KEY_ENUM)
     {
      m_TradingControl.RiskSetting().SetValue(m_TradingControl.RiskSetting().Property(param),(double)(int)dparam);
      return;
     }
   if(id!=CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON && id!=CHARTEVENT_CUSTOM+CHANGE_EVENT_END_EDIT && id!=CHARTEVENT_CUSTOM+CLICK_EVENT_INC && id!=CHARTEVENT_CUSTOM+CLICK_EVENT_DEC)
      return;
   //--- The header toggles (dparam = the new state). Auto: every strategy below allowed to Open Position or none
   int which=0;
   const bool click=(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON);
   const int auto_toggle=(click ? m_sections_trade_automation_setting.SectionOfToggle(lparam,which) : WRONG_VALUE);
   const int risk_toggle=(click ? m_sections_trade_risk.SectionOfToggle(lparam,which) : WRONG_VALUE);
   //--- The toggle of the header of Adaptive Risk / Basket Risk / Portfolio Risk: its Enable key (on RAM). Its keys below count only while it is ON (CTradingControl
   //--- skips the tier when OFF): ON opens the section to set them, OFF closes it
   const int enable_property=(risk_toggle!=WRONG_VALUE && m_TradingControl!=NULL ? this.SwitchOfSection_TradeRisk(m_TradingControl.RiskSetting(),risk_toggle) : WRONG_VALUE);
   if(enable_property!=WRONG_VALUE)
     {
      m_TradingControl.RiskSetting().SetValue(enable_property,(dparam!=0 ? 1.0 : 0.0));
      if(dparam!=0)
         for(int s=1;s<m_sections_trade_risk.SectionsTotal();s++)
            m_sections_trade_risk.SetOpened(s,s==risk_toggle);   // one open at a time
      else
         m_sections_trade_risk.SetOpened(risk_toggle,false);
      m_sections_trade_risk.Arrange();
      this.SyncSections_TradingRisk();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- The toggle of the header of Lot Size: a mode is always ON, the toggle goes back to ON
   if(risk_toggle==TRADE_RISK_SECTION_LOTSIZE)
     {
      this.SyncSections_TradingRisk();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- The toggle of the header of Stop Loss / Trailing: every base below ON / OFF
   if(m_TradingControl!=NULL && (risk_toggle==TRADE_RISK_SECTION_STOPLOSS || risk_toggle==TRADE_RISK_SECTION_TRAILING))
     {
      m_TradingControl.RiskSetting().SetProperty((risk_toggle==TRADE_RISK_SECTION_STOPLOSS ? RISK_PROP_STOP_LOSS_TEMPLATES : RISK_PROP_TRAILING_TEMPLATES),
                                                 (dparam!=0 ? this.BaseIds_TradingRisk(risk_toggle) : ""));
      this.SyncSections_TradingRisk();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   if(m_TradingControl!=NULL && auto_toggle==TRADE_AUTO_SECTION_AUTO)
     {
      string list="";
      if(dparam!=0 && m_StrategyManager!=NULL)
        {
         long ids[];
         const int strategies=m_StrategyManager.Read_RAM(ids);
         for(int i=0;i<strategies;i++)
           {
            CStrategySetting *strategy=m_StrategyManager.Read_RAM(ids[i]);
            if(strategy!=NULL && strategy.SlotsAvailable())
               list+=(list=="" ? "" : ",")+(string)ids[i];
           }
        }
      m_TradingControl.RiskSetting().SetProperty(RISK_PROP_ENTRY_STRATEGIES,list);
      this.SyncSections_TradingRisk();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- The switch of a row. The View only tells Setting_Risk (CRiskSetting fires RISK_SETTING_EVENT_CHANGED, CTradingControl keeps it on RAM).
   //--- Auto: a strategy allowed to Open Position or not; Lot Size: the modes exclude each other, ON = that row, one always ON; Stop Loss, Trailing:
   //--- each base ON / OFF on its own
   if(click && m_TradingControl!=NULL && m_sections_trade_automation_setting.BodyOf(lparam,row_id,slot,param) && slot==TRADE_AUTO_SECTION_AUTO)
     {
      m_TradingControl.RiskSetting().SetIdOn(RISK_PROP_ENTRY_STRATEGIES,row_id,dparam!=0);
      this.SyncSections_TradingRisk();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   if(click && m_TradingControl!=NULL && m_sections_trade_risk.BodyOf(lparam,row_id,slot,param) &&
      (slot==TRADE_RISK_SECTION_LOTSIZE || slot==TRADE_RISK_SECTION_STOPLOSS || slot==TRADE_RISK_SECTION_TRAILING))
     {
      CRiskSetting *risk=m_TradingControl.RiskSetting();
      if(slot==TRADE_RISK_SECTION_LOTSIZE && dparam!=0)
         risk.SetProperty(RISK_PROP_RISK_MODE,row_id);
      else if(slot==TRADE_RISK_SECTION_STOPLOSS)
         risk.SetIdOn(RISK_PROP_STOP_LOSS_TEMPLATES,row_id,dparam!=0);
      else if(slot==TRADE_RISK_SECTION_TRAILING)
         risk.SetIdOn(RISK_PROP_TRAILING_TEMPLATES,row_id,dparam!=0);
      this.SyncSections_TradingRisk();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- A bool key of Setting_Risk (on RAM): its switch
   if(click && m_TradingControl!=NULL && m_sections_trade_risk.BodyOf(lparam,row_id,slot,param) && slot==TRADE_SLOT_KEY_SWITCH)
     {
      m_TradingControl.RiskSetting().SetValue(m_TradingControl.RiskSetting().Property(param),(dparam!=0 ? 1.0 : 0.0));
      this.SyncSections_TradingRisk();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- The value of an int / double key (a mode of Lot Size or any other): typed or stepped, dparam = the value
   if((id==CHARTEVENT_CUSTOM+CHANGE_EVENT_END_EDIT || id==CHARTEVENT_CUSTOM+CLICK_EVENT_INC || id==CHARTEVENT_CUSTOM+CLICK_EVENT_DEC) && m_TradingControl!=NULL &&
      m_sections_trade_risk.BodyOf(lparam,row_id,slot,param) && slot==TRADE_SLOT_KEY_VALUE)
     {
      m_TradingControl.RiskSetting().SetValue(m_TradingControl.RiskSetting().Property(param),dparam);
      return;
     }
   //--- A string key (ExtraPortfolioMagics): the text typed
   if(id==CHARTEVENT_CUSTOM+CHANGE_EVENT_END_EDIT && m_TradingControl!=NULL && m_sections_trade_risk.BodyOf(lparam,row_id,slot,param) && slot==TRADE_SLOT_KEY_TEXT)
     {
      CTextEdit *text=dynamic_cast<CTextEdit *>(m_sections_trade_risk.BodyControl(TRADE_SLOT_KEY_TEXT,param));
      if(text!=NULL)
         m_TradingControl.RiskSetting().SetText(m_TradingControl.RiskSetting().Property(param),text.GetValue());
      return;
     }
   if(id!=CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON)
      return;
   //--- The Manual Entry: the direction (Open follows it); the results again
   if(m_sections_trade_manual_settup.BodyOf(lparam,row_id,slot,param) && slot==TRADE_SLOT_DIRECTION)
     {
      this.SyncButton_OpenPosition();
      this.SyncSections_TradeManualSetup();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- Trade Manage opens the window
   if(lparam==m_btn_tradeManage.ObjectID())
     {
      this.OpenWindow_TradeManage();
      return;
     }
   //--- All: the View only tells it, Trade (CTradingControl::OnChartEvent) closes every position of the account
   if(lparam==m_btn_manual_close_all_Position.ObjectID())
     {
      this.EventSend((ushort)TRADE_SETUP_EVENT_CLOSE_ALL,0,0.0,"");
      return;
     }
   //--- Action: the View only tells the side (NONE: both) and the sign of the profit (0: any) on the chart symbol, Trade closes the positions of the EA on it
   if(lparam==m_btn_manual_close_buy.ObjectID() || lparam==m_btn_manual_close_sell.ObjectID() || lparam==m_btn_close_lose.ObjectID() || lparam==m_btn_close_profit.ObjectID())
     {
      const long side=(lparam==m_btn_manual_close_buy.ObjectID() ? SIGNAL_DIRECTION_BUY : (lparam==m_btn_manual_close_sell.ObjectID() ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_NONE));
      const double profit_sign=(lparam==m_btn_close_profit.ObjectID() ? 1.0 : (lparam==m_btn_close_lose.ObjectID() ? -1.0 : 0.0));
      this.EventSend((ushort)TRADE_SETUP_EVENT_CLOSE,side,profit_sign,::Symbol());
      return;
     }
   //--- Open (by hand, StrategyID 0, to test the risk): the View only tells it with the lot chosen (<= MaxLot), Trade (CTradingControl::OnChartEvent)
   //--- checks and sends; Market only for now
   if(lparam==m_btn_manual_open_position.ObjectID())
     {
      if(m_manual_order_type!=0)
        {
         ::Print(__FUNCTION__," > only Market is sent for now");
         return;
        }
      const long   side=(m_btn_triggered_manual_trade_dirrection.State() ? SIGNAL_DIRECTION_BUY : SIGNAL_DIRECTION_SELL);
      const double lots=::StringToDouble(m_combobox_manual_lot.GetValue());
      string       target=::Symbol();   // "symbol;magic": the magic typed
      target+=";";
      target+=m_edit_manual_magic.GetValue();
      this.EventSend((ushort)TRADE_SETUP_EVENT_SEND,side,lots,target);
      return;
     }
  }
#endif // CGUIPANNEL_TABTRADING_MQH
