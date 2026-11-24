//+------------------------------------------------------------------+
//|                                          GUIPannel_TabTrading.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABTRADING_MQH
#define CGUIPANNEL_TABTRADING_MQH
#include "GUIPannel.mqh" 
 bool CGUIPannel::CreateButtons_OpenPosition(void)
  {
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_btn_manual_open_position);
   return m_btn_manual_open_position.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnManualOpenPosition",M_TRADING_X_OPEN,M_CONTROL_BORDER_GAP,M_BUTTON_OPEN_POSITION_WIDTH,M_CONTROL_HEIGHT);
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
 //--- The button right of Close All: it opens the Trade Manage window
 bool CGUIPannel::CreateButton_TradeManage(void)
  {
   m_btn_tradeManage.SetText("Trade Manage");
   m_btn_tradeManage.IconFile(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_btn_tradeManage);
   return m_btn_tradeManage.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnTradeManage",M_TRADING_X_TRADEMANAGE,M_CONTROL_BORDER_GAP,M_BUTTON_TRADEMANAGE_TAB_WIDTH,M_CONTROL_HEIGHT);
  }
 //--- The button right of Open: every position of the account is closed at once (emergency, no confirmation)
 bool CGUIPannel::CreateButton_CloseAllPosition(void)
  {
   m_btn_manual_close_all_Position.SetText("Close All");
   m_btn_manual_close_all_Position.IconFile(IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_btn_manual_close_all_Position);
   return m_btn_manual_close_all_Position.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnCloseAllPosition",M_TRADING_X_CLOSEALL,M_CONTROL_BORDER_GAP,
                                        M_BUTTON_CLOSEALL_WIDTH,M_CONTROL_HEIGHT);
  }
 //--- m_sections_trade_automation_setting: Auto sets the Automation Entry of the strategies of CStrategyManager (a row per strategy available,
 //--- its switch loaded from DB, SetIdOn("EntryStrategies") of Setting_Risk); Manual (StrategyID 0) is always ON, not in Auto. Lot Size, Stop Loss, Trailing of Setting_Risk
 // Manual Strategy allway on.
 bool CGUIPannel::CreateSections_TradingRisk(void)
  {
   if(!m_sections_trade_automation_setting.Create(this.m_chart_id,M_SUBWINDOW_MAIN,&m_tabs_main,TAB_TAB_MAIN_TRADING,"SectionsTradeAuto"))
      return false;
   m_sections_trade_automation_setting.SetTopOffset(M_TRADE_AUTO_TOP);   // Auto on the row of the buttons (they stand right of its header)
   m_sections_trade_automation_setting.SetWidth(M_TRADE_AUTO_WIDTH);
   int columns[TRADE_AUTO_COLUMN_TOTAL]={0,M_TRADE_AUTO_COLUMN_SWITCH,M_TRADE_AUTO_COLUMN_VALUE};
   m_sections_trade_automation_setting.SetColumns(columns);
   int toggle_x[1]={M_TRADE_AUTO_TOGGLE_X};   // as the toggles of the Indicator tab: on the header
   m_sections_trade_automation_setting.SetToggleColumns(toggle_x);
   const string titles[TRADE_AUTO_SECTION_TOTAL]={"Auto","Lot Size","Stop Loss","Trailing"};
   for(int s=0;s<TRADE_AUTO_SECTION_TOTAL;s++)
     {
      //--- The header toggle: ON when a row is ON; Auto, Stop Loss, Trailing: turns every row ON / OFF; Lot Size: stays ON
      uint icons[1]={0};
      bool states[1]={false};
      if(m_sections_trade_automation_setting.AddSection(titles[s],icons,states,false)==WRONG_VALUE)   // closed at the start: the headers tell what is ON
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
   if(!edit.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,key,0,0,M_TRADE_AUTO_VALUE_WIDTH,M_CONTROL_HEIGHT,M_TRADE_AUTO_VALUE_WIDTH))
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
 //--- The rows: the strategies available (Auto); the modes of RiskMode and the value of each; each template with the role: Stop Loss PSAR (its price)
 //--- and ATR (x ATRMultiplier), Trailing PSAR
 void CGUIPannel::PopulateSections_TradingRisk(void)
  {
   CRiskSetting *risk=(m_TradingControl!=NULL ? m_TradingControl.RiskSetting() : NULL);
   for(int s=0;s<TRADE_AUTO_SECTION_TOTAL;s++)
      m_sections_trade_automation_setting.ClearBody(s);
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
      this.AddRow_TradingRisk(m_tabs_main,TAB_TAB_MAIN_TRADING,m_sections_trade_automation_setting,TRADE_AUTO_SECTION_LOTSIZE,i,i,::RiskModeText((ENUM_RISK_MODE)i),M_TRADE_AUTO_LABEL_WIDTH,
                              0,TRADE_AUTO_COLUMN_SWITCH,"RiskLot"+(string)i,TRADE_AUTO_SECTION_LOTSIZE,"",true);   // the switch only
      const string mode_key=::RiskModeValueKey((ENUM_RISK_MODE)i);   // the amount of the mode ("": Min lot has none, the min lot of the symbol)
      if(risk!=NULL && mode_key!="")
         this.AddValue_TradingRisk(m_tabs_main,TAB_TAB_MAIN_TRADING,m_sections_trade_automation_setting,TRADE_AUTO_SECTION_LOTSIZE,i,TRADE_AUTO_COLUMN_VALUE,i,
                                   mode_key,risk.Value(mode_key),"RiskLotValue"+(string)i);
     }
   if(m_IndicatorTemplateManager!=NULL)
     {
      ENUM_INDICATOR types[];
      string params[],display[];
      bool buy[],sell[],sound[],message[],show[];
      const int total=m_IndicatorTemplateManager.Read_RAM(types,params,display,buy,sell,sound,message,show);
      int row_sl=0,row_trail=0;
      for(int i=0;i<total;i++)
        {
         const long id=this.RowHandle_IndicatorTemplateSetting(types[i],params[i]);
         if(types[i]==IND_SAR || types[i]==IND_ATR)
            this.AddRow_TradingRisk(m_tabs_main,TAB_TAB_MAIN_TRADING,m_sections_trade_automation_setting,TRADE_AUTO_SECTION_STOPLOSS,row_sl++,id,display[i],M_TRADE_AUTO_LABEL_WIDTH,
                                    0,TRADE_AUTO_COLUMN_SWITCH,"RiskSL"+(string)id,TRADE_AUTO_SECTION_STOPLOSS,"",true);   // the switch only
         if(types[i]==IND_SAR)
            this.AddRow_TradingRisk(m_tabs_main,TAB_TAB_MAIN_TRADING,m_sections_trade_automation_setting,TRADE_AUTO_SECTION_TRAILING,row_trail++,id,display[i],M_TRADE_AUTO_LABEL_WIDTH,
                                    0,TRADE_AUTO_COLUMN_SWITCH,"RiskTrail"+(string)id,TRADE_AUTO_SECTION_TRAILING,"",true);   // the switch only
        }
     }
   this.SyncSections_TradingRisk();
   m_sections_trade_automation_setting.Arrange();
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
         const bool on=risk.IsIdOn("EntryStrategies",ids[i]);
         m_sections_trade_automation_setting.SetBodyState(ids[i],TRADE_AUTO_SECTION_AUTO,on);
         any_on=(any_on || on);
        }
     }
   m_sections_trade_automation_setting.SetToggle(TRADE_AUTO_SECTION_AUTO,0,any_on);   // as the toggles of the Indicator tab: ON when one below is ON
   const int mode=(int)risk.RiskMode();
   for(int i=0;i<RISK_MODES_TOTAL;i++)
      m_sections_trade_automation_setting.SetBodyState(i,TRADE_AUTO_SECTION_LOTSIZE,i==mode);
   m_sections_trade_automation_setting.SetToggle(TRADE_AUTO_SECTION_LOTSIZE,0,(mode>=0 && mode<RISK_MODES_TOTAL));   // a mode is always ON
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
         const bool sl_on=risk.IsIdOn("StopLossTemplates",id);
         const bool trail_on=risk.IsIdOn("TrailingTemplates",id);
         m_sections_trade_automation_setting.SetBodyState(id,TRADE_AUTO_SECTION_STOPLOSS,sl_on);
         m_sections_trade_automation_setting.SetBodyState(id,TRADE_AUTO_SECTION_TRAILING,trail_on);
         any_sl=(any_sl || sl_on);
         any_trail=(any_trail || trail_on);
        }
     }
   //--- The toggles of the headers: ON when a base below is ON (the rows tell which)
   m_sections_trade_automation_setting.SetToggle(TRADE_AUTO_SECTION_STOPLOSS,0,any_sl);
   m_sections_trade_automation_setting.SetToggle(TRADE_AUTO_SECTION_TRAILING,0,any_trail);
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
      if(types[i]==IND_SAR || (types[i]==IND_ATR && section==TRADE_AUTO_SECTION_STOPLOSS))
         list+=(list=="" ? "" : ",")+(string)this.RowHandle_IndicatorTemplateSetting(types[i],params[i]);
   return list;
  }
 //--- m_sections_trade_select, right of the settings: the Manual Entry (only the lot is manual). Entry: [the direction], [SL], [TP], [MaxLot]
 //--- (the results of the Automation for that direction), [Lot][the lots up to MaxLot]; Order Type: one ON
 bool CGUIPannel::CreateSections_TradeSelect(void)
  {
   if(!m_sections_trade_select.Create(this.m_chart_id,M_SUBWINDOW_MAIN,&m_tabs_main,TAB_TAB_MAIN_TRADING,"SectionsTradeSelect"))
      return false;
   m_sections_trade_select.SetTopOffset(M_TRADING_SECTIONS_TOP);
   m_sections_trade_select.SetLeftOffset(M_TRADE_SELECT_LEFT);
   m_sections_trade_select.SetWidth(M_TRADE_SELECT_WIDTH);
   int columns[TRADE_SELECT_COLUMN_TOTAL]={0,M_TRADE_SELECT_COLUMN_VALUE};
   m_sections_trade_select.SetColumns(columns);
   int no_toggle[];
   m_sections_trade_select.SetToggleColumns(no_toggle);
   uint icons[];
   bool states[];
   const string titles[TRADE_SELECT_SECTION_TOTAL]={"Manual","Order Type"};
   for(int s=0;s<TRADE_SELECT_SECTION_TOTAL;s++)
      if(m_sections_trade_select.AddSection(titles[s],icons,states,false)==WRONG_VALUE)   // closed at the start
         return false;
   //--- Entry: the names (the direction has none: its button says Buy / Sell)
   const string names[]={"","SL","TP","MaxLot","Lot","Magic"};
   for(int r=1;r<::ArraySize(names);r++)
      if(!this.AddRow_TradingRisk(m_tabs_main,TAB_TAB_MAIN_TRADING,m_sections_trade_select,TRADE_SELECT_SECTION_ENTRY,r,r,names[r],M_TRADE_SELECT_LABEL_WIDTH,0,TRADE_SELECT_COLUMN_VALUE,"ManualEntry"+(string)r,TRADE_SLOT_LABEL))
         return false;
   //--- the direction: pressed Buy, released Sell
   m_btn_triggered_manual_trade_dirrection.IconFile(IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG);
   m_btn_triggered_manual_trade_dirrection.IconFileLocked(IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG);
   m_btn_triggered_manual_trade_dirrection.IconFilePressed(IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG);
   m_btn_triggered_manual_trade_dirrection.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG);
   m_btn_triggered_manual_trade_dirrection.SetState(true);   // Buy first
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_btn_triggered_manual_trade_dirrection);
   if(!m_btn_triggered_manual_trade_dirrection.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnManualTradeDirection",0,0,M_TRADE_SELECT_VALUE_WIDTH,M_CONTROL_HEIGHT))
      return false;
   m_btn_triggered_manual_trade_dirrection.Hide();
   if(!m_sections_trade_select.AddControl(TRADE_SELECT_SECTION_ENTRY,::GetPointer(m_btn_triggered_manual_trade_dirrection),TRADE_SELECT_COLUMN_LABEL,0,0,TRADE_SLOT_DIRECTION))   // left: the row has no name
      return false;
   //--- the results: SL, TP, MaxLot
   for(int i=0;i<3;i++)
     {
      CLabel *label=(i==0 ? ::GetPointer(m_label_manual_sl) : (i==1 ? ::GetPointer(m_label_manual_tp) : ::GetPointer(m_label_manual_maxlot)));
      label.LabelXGap(0);
      m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,label);
      if(!label.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"LblManualResult"+(string)i,0,0,M_TRADE_SELECT_VALUE_WIDTH,M_CONTROL_HEIGHT))
         return false;
      label.Hide();
      if(!m_sections_trade_select.AddControl(TRADE_SELECT_SECTION_ENTRY,label,TRADE_SELECT_COLUMN_VALUE,1+i,1+i,TRADE_SLOT_RESULT))
         return false;
     }
   //--- the lot: MinLot .. MaxLot
   m_combobox_manual_lot.ItemsTotal(1);
   m_combobox_manual_lot.Hide();
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_combobox_manual_lot);
   if(!m_combobox_manual_lot.CreateComboBox(this.m_chart_id,M_SUBWINDOW_MAIN,"CmbManualLot",0,0,M_TRADE_SELECT_VALUE_WIDTH,M_CONTROL_HEIGHT,M_TRADE_SELECT_VALUE_WIDTH,140))
      return false;
   if(!m_sections_trade_select.AddControl(TRADE_SELECT_SECTION_ENTRY,::GetPointer(m_combobox_manual_lot),TRADE_SELECT_COLUMN_VALUE,4,4,TRADE_SLOT_LOT))
      return false;
   //--- the magic: typed, the EA's first (0: none, as the terminal)
   m_edit_manual_magic.Hide();
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_edit_manual_magic);
   if(!m_edit_manual_magic.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditManualMagic",0,0,M_TRADE_SELECT_VALUE_WIDTH,M_CONTROL_HEIGHT,M_TRADE_SELECT_VALUE_WIDTH))
      return false;
   m_edit_manual_magic.SetText("");
   if(!m_sections_trade_select.AddControl(TRADE_SELECT_SECTION_ENTRY,::GetPointer(m_edit_manual_magic),TRADE_SELECT_COLUMN_VALUE,5,5,TRADE_SLOT_MAGIC))
      return false;
   //--- Order Type
   const string orders[]={"Market","Limit","Stop","Stop Limit"};         // the order types of the Manual Entry (Market only for now: TRADE_SETUP_EVENT_SEND)
   for(int i=0;i<::ArraySize(orders);i++)
      if(!this.AddRow_TradingRisk(m_tabs_main,TAB_TAB_MAIN_TRADING,m_sections_trade_select,TRADE_SELECT_SECTION_ORDERTYPE,i,i,orders[i],M_TRADE_SELECT_LABEL_WIDTH,
                                  IMAGE_RESOURCE_BMP16_ORDER_DIR_PNG,TRADE_SELECT_COLUMN_VALUE,"ManualOrder"+(string)i,TRADE_SELECT_SECTION_ORDERTYPE))
         return false;
   this.SyncButton_OpenPosition();
   this.SyncSections_TradeSelect();
   m_sections_trade_select.Arrange();
   return true;
  }
 //--- The results of the Automation for the direction chosen (CTradingControl::ManualPlan: the stop of the bases ON, the lot of the risk capped
 //--- by the margin), the lots from MaxLot down by the volume step to MinLot (CSymbol), the order type ON. The View only shows them
 void CGUIPannel::SyncSections_TradeSelect(void)
  {
   const string orders[]={"Market","Limit","Stop","Stop Limit"};
   for(int i=0;i<::ArraySize(orders);i++)
      m_sections_trade_select.SetBodyState(i,TRADE_SELECT_SECTION_ORDERTYPE,i==m_manual_order_type);
   m_sections_trade_select.SetHeaderText(TRADE_SELECT_SECTION_ORDERTYPE,"Order Type: "+orders[m_manual_order_type]);
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
   //--- CTradingControl::TradeEntry)
   double lots[];
   int total=0;
   if(ok && step>0)
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
   m_sections_trade_select.SetHeaderText(TRADE_SELECT_SECTION_ENTRY,"Manual: "+(ok ? ::DoubleToString(plan.lotSize,lot_digits) : "no risk"));   // the lot (MaxLot), or no plan of the risk
   if(m_edit_manual_magic.GetValue()=="")
      m_edit_manual_magic.SetValue((string)m_TradingControl.MagicIdEA(symbol));   // the EA's until one is typed
   //--- Working on RAM: the list lives in the ListView; it is made again only when it changed (MaxLot, the count), not at each refresh (the open list kept)
   CListView *list=m_combobox_manual_lot.GetListViewPointer();
   const string first=(total>0 ? ::DoubleToString(lots[0],lot_digits) : "-");
   if(list.ItemsTotal()==::MathMax(total,1) && list.GetValue(0)==first)
      return;
   const string chosen=m_combobox_manual_lot.GetValue();   // the lot the user chose stays while it is still <= MaxLot
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
 //+------------------------------------------------------------------+
 //| What the user did in the Trading tab                             |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_Trading(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- The sections: arranged again when the tab opens, scrolls, the window changes its size
   m_sections_trade_automation_setting.OnChartEvent(id,lparam,dparam,sparam);
   m_sections_trade_select.OnChartEvent(id,lparam,dparam,sparam);
   //--- A template came or went: the rows of the bases again
   if(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED || id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE)
     {
      this.PopulateSections_TradingRisk();
      this.SyncSections_TradeSelect();
      return;
     }
   //--- Auto: a strategy became available or not, its row comes or goes
   if(id==CHARTEVENT_CUSTOM+STRATEGY_MANAGER_EVENT_AVAILABLE_CHANGED)
     {
      this.PopulateSections_TradingRisk();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- The results of the Automation again: a new bar of the chart, a key of Setting_Risk changed
   if((id==CHARTEVENT_CUSTOM+SERIES_EVENTS_NEW_BAR && sparam==::Symbol() && (int)dparam==(int)::Period()) || id==CHARTEVENT_CUSTOM+RISK_SETTING_EVENT_CHANGED)
     {
      this.SyncSections_TradeSelect();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   if(id!=CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON && id!=CHARTEVENT_CUSTOM+CHANGE_EVENT_END_EDIT && id!=CHARTEVENT_CUSTOM+CLICK_EVENT_INC && id!=CHARTEVENT_CUSTOM+CLICK_EVENT_DEC)
      return;
   //--- The header toggles; Auto: every strategy below allowed to Open Position or none (dparam = the new state)
   int which=0;
   const int toggle_section=(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON ? m_sections_trade_automation_setting.SectionOfToggle(lparam,which) : WRONG_VALUE);
   //--- The toggle of the header of Lot Size: a mode is always ON, the toggle goes back to ON
   if(toggle_section==TRADE_AUTO_SECTION_LOTSIZE)
     {
      this.SyncSections_TradingRisk();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- The toggle of the header of Stop Loss / Trailing: every base below ON / OFF (dparam = the new state)
   if(m_TradingControl!=NULL && (toggle_section==TRADE_AUTO_SECTION_STOPLOSS || toggle_section==TRADE_AUTO_SECTION_TRAILING))
     {
      m_TradingControl.RiskSetting().SetText((toggle_section==TRADE_AUTO_SECTION_STOPLOSS ? "StopLossTemplates" : "TrailingTemplates"),
                                             (dparam!=0 ? this.BaseIds_TradingRisk(toggle_section) : ""));
      this.SyncSections_TradingRisk();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   if(m_TradingControl!=NULL && toggle_section==TRADE_AUTO_SECTION_AUTO)
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
      m_TradingControl.RiskSetting().SetText("EntryStrategies",list);
      this.SyncSections_TradingRisk();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- The switch of a row of the settings. The View only tells Setting_Risk (CRiskSetting fires RISK_SETTING_EVENT_CHANGED, CTradingControl writes it).
   //--- Lot Size: the modes exclude each other, ON = that row, one always ON; Stop Loss, Trailing: each base ON / OFF on its own
   long row_id;
   int slot;
   string param;
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON && m_TradingControl!=NULL && m_sections_trade_automation_setting.BodyOf(lparam,row_id,slot,param) && slot!=TRADE_SLOT_LABEL)
     {
      CRiskSetting *risk=m_TradingControl.RiskSetting();
      //--- Auto: a strategy allowed to Open Position or not
      if(slot==TRADE_AUTO_SECTION_AUTO)
         risk.SetIdOn("EntryStrategies",row_id,dparam!=0);
      else if(slot==TRADE_AUTO_SECTION_LOTSIZE && dparam!=0)
         risk.SetValue("RiskMode",(double)row_id);
      else if(slot==TRADE_AUTO_SECTION_STOPLOSS)
         risk.SetIdOn("StopLossTemplates",row_id,dparam!=0);
      else if(slot==TRADE_AUTO_SECTION_TRAILING)
         risk.SetIdOn("TrailingTemplates",row_id,dparam!=0);
      this.SyncSections_TradingRisk();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- The value of a mode of Lot Size: typed or stepped, dparam = the value
   if((id==CHARTEVENT_CUSTOM+CHANGE_EVENT_END_EDIT || id==CHARTEVENT_CUSTOM+CLICK_EVENT_INC || id==CHARTEVENT_CUSTOM+CLICK_EVENT_DEC) && m_TradingControl!=NULL &&
      m_sections_trade_automation_setting.BodyOf(lparam,row_id,slot,param) && slot==TRADE_SLOT_KEY_VALUE)
     {
      m_TradingControl.RiskSetting().SetValue(param,dparam);
      return;
     }
   if(id!=CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON)
      return;
   //--- The Manual Entry: the direction (Open follows it), the order type ON (one always ON); the results again
   if(m_sections_trade_select.BodyOf(lparam,row_id,slot,param) && slot!=TRADE_SLOT_LABEL)
     {
      if(slot==TRADE_SELECT_SECTION_ORDERTYPE && dparam!=0)
         m_manual_order_type=(int)row_id;
      if(slot==TRADE_SLOT_DIRECTION)
         this.SyncButton_OpenPosition();
      this.SyncSections_TradeSelect();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- Trade Manage opens the window
   if(lparam==m_btn_tradeManage.ObjectID())
     {
      this.OpenWindow_TradeManage();
      return;
     }
   //--- Close All: the View only tells it, Trade (CTradingControl::OnChartEvent) closes the positions
   if(lparam==m_btn_manual_close_all_Position.ObjectID())
     {
      this.EventSend((ushort)TRADE_SETUP_EVENT_CLOSE_ALL,0,0.0,"");
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
      this.EventSend((ushort)TRADE_SETUP_EVENT_SEND,(m_btn_triggered_manual_trade_dirrection.State() ? SIGNAL_DIRECTION_BUY : SIGNAL_DIRECTION_SELL),
                     ::StringToDouble(m_combobox_manual_lot.GetValue()),::Symbol()+";"+m_edit_manual_magic.GetValue());   // "symbol;magic": the magic typed
      return;
     }
  }
#endif // CGUIPANNEL_TABTRADING_MQH
