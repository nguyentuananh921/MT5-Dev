//+------------------------------------------------------------------+
//|                           GUIPannel_MainWindows_TabTrading.mqh |
//| Trading tab of m_window_main: TF switch, the indicator monitor   |
//| (what Python calculated), the New Order form and the position    |
//| tables. Sending an order and the stop loss / trailing wait for   |
//| the trading engine: their handlers print for now                 |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_MAINWINDOWS_TABTRADING_MQH
#define CGUIPANNEL_MAINWINDOWS_TABTRADING_MQH
 #include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| "All" (only with 2+ TFs) + the TFs of the chart Symbol            |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTFSwitchButtons(const int x_gap,const int y_gap)
  {
   m_btngroup_tf_switch.RadioButtonsMode(true);
   m_btngroup_tf_switch.ButtonYSize(M_CONTROL_HEIGHT);
   m_btngroup_tf_switch.AddButton(0,0,"All",M_TF_WITHOUT_ICON_WIDTH);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_btngroup_tf_switch);
   return m_btngroup_tf_switch.CreateButtonsGroup(m_chart_id,m_subwin,"TFSwitch",x_gap,y_gap);
  }
 void CGUIPannel::Sync_CButtonsGroup_TFSwitchButtons(void)
  {
   bool was_all_selected=(m_btngroup_tf_switch.SelectedButtonText()=="All");
   string symbol=::Symbol();
   string tf_texts[];
   int tf_count=0;
   int total=(m_SymbolTFManager!=NULL) ? m_SymbolTFManager.Total() : 0;
   for(int i=0;i<total;i++)
     {
      CSymbolTFSetting *row=m_SymbolTFManager.At(i);
      if(row==NULL || row.Symbol()!=symbol)
         continue;
      ::ArrayResize(tf_texts,tf_count+1);
      tf_texts[tf_count]=TimeframeDescription(row.TFEnum());
      tf_count++;
     }
   int first_tf_button=(tf_count>1) ? 1 : 0;
   bool buttons_match=(m_btngroup_tf_switch.ButtonsTotal()==tf_count+first_tf_button);
   if(buttons_match && first_tf_button==1)
      buttons_match=(m_btngroup_tf_switch.GetButtonPointer(0).Text()=="All");
   for(int i=0;i<tf_count && buttons_match;i++)
      buttons_match=(m_btngroup_tf_switch.GetButtonPointer(i+first_tf_button).Text()==tf_texts[i]);
   if(!buttons_match)
     {
      ::Print("MY DEBUG CGUIPannel::Sync_CButtonsGroup_TFSwitchButtons: the buttons are built again, ",tf_count," TF(s), main window locked=",m_window_main.IsLocked());   //Print Debug
      m_btngroup_tf_switch.DeleteButtons();
      if(first_tf_button==1)
         m_btngroup_tf_switch.AddButton(0,0,"All",M_TF_WITHOUT_ICON_WIDTH);
      for(int i=0;i<tf_count;i++)
         m_btngroup_tf_switch.AddButton((i+first_tf_button)*(M_TF_WITHOUT_ICON_WIDTH+M_CONTROL_BORDER_GAP),0,tf_texts[i],M_TF_WITHOUT_ICON_WIDTH);
     }
   int select_index=WRONG_VALUE;
   if(was_all_selected && first_tf_button==1)
      select_index=0;
   else
     {
      string chart_tf=TimeframeDescription((ENUM_TIMEFRAMES)::Period());
      for(int i=0;i<tf_count;i++)
         if(tf_texts[i]==chart_tf)
           {
            select_index=i+first_tf_button;
            break;
           }
     }
   if(select_index==WRONG_VALUE && m_btngroup_tf_switch.ButtonsTotal()>0)
      select_index=0;
   if(select_index!=WRONG_VALUE && m_btngroup_tf_switch.GetButtonPointer(select_index).Text()!=m_btngroup_tf_switch.SelectedButtonText())
      m_btngroup_tf_switch.SelectButton(select_index);
   SyncTable_PreTradeSymbolMonitor(symbol);
  }
 //--- Filter the monitor; a TF button also moves the chart there
 void CGUIPannel::OnClick_CButtonsGroup_TFSwitchButton(void)
  {
   string symbol=::Symbol();
   ENUM_TIMEFRAMES tf=TimestampByDescription(m_btngroup_tf_switch.SelectedButtonText());   // "All" = PERIOD_CURRENT
   if(tf==PERIOD_CURRENT || symbol=="" || m_SymbolTFManager==NULL || tf==(ENUM_TIMEFRAMES)::Period())
     {
      SyncTable_PreTradeSymbolMonitor(symbol,true);
      return;
     }
   m_SymbolTFManager.NotifySettingChanged(symbol,tf);
  }
 //+------------------------------------------------------------------+
 //| Indicator monitor: every template of every tracked TF of the     |
 //| chart Symbol - TF | signal | indicator | value | SL | trailing    |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_PreTradeSymbolMonitor(const int x,const int y)
  {
   int columns_width_total=0;
   for(int c=0;c<COLUMNS_PRETRADEMON_TOTAL;c++)
     {
      columns_width_total+=PRETRADEMON_WIDTH[c];
      m_table_indicator_PreTradeSymbolMonitor.View().GetHeaderViewPointer().TextAlign(c,PRETRADEMON_HEADER_ALIGN[c]);
     }
   m_table_indicator_PreTradeSymbolMonitor.TableSize(COLUMNS_PRETRADEMON_TOTAL,0);
   m_table_indicator_PreTradeSymbolMonitor.View().ShowHeaders(true);
   m_table_indicator_PreTradeSymbolMonitor.View().SelectableRow(true);
   m_table_indicator_PreTradeSymbolMonitor.View().LightsHover(true);
   m_table_indicator_PreTradeSymbolMonitor.View().IsSortMode(false);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_table_indicator_PreTradeSymbolMonitor);
   if(!m_table_indicator_PreTradeSymbolMonitor.CreateTable(m_chart_id,m_subwin,"TablePreTradeMonitor",x,y,columns_width_total+20,TRADING_FORM_HEIGHT))
      return false;
   CTableHeaderView *header=m_table_indicator_PreTradeSymbolMonitor.View().GetHeaderViewPointer();
   header.ColumnsWidth(PRETRADEMON_WIDTH);
   header.TextXOffset(PRETRADEMON_TEXT_X_OFFSET);
   header.ImageXOffset(PRETRADEMON_IMAGE_X_OFFSET);
   m_table_indicator_PreTradeSymbolMonitor.View().IsFilterMode(2,true);
   uint signal_col_img[]={IMAGE_RESOURCE_BMP16_SIGNAL_PNG};
   uint sl_col_img[]={IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG};
   uint trailling_col_img[]={IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(0,"TF");
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(1,"");
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderImage(1,signal_col_img);
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(2,"Indicator");
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(3,"Value");
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(4,"");
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderImage(4,sl_col_img);
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderText(5,"");
   m_table_indicator_PreTradeSymbolMonitor.SetHeaderImage(5,trailling_col_img);
   m_table_indicator_PreTradeSymbolMonitor.View().Rebuild(true);
   return true;
  }
 //--- Python calculates on closed bars: the value is the one of the newest closed bar, the signal the last one it found
 bool CGUIPannel::SyncTable_PreTradeSymbolMonitor(const string symbol,bool force=false)
  {
   if(m_SymbolTFManager==NULL || m_IndicatorTemplateManager==NULL || m_IndicatorsCollection==NULL)
      return false;
   static string s_symbol="";
   static string s_row_key[];
   if(symbol!=s_symbol)
     {
      s_symbol=symbol;
      force=true;
     }
   ENUM_TIMEFRAMES tf_filter=TimestampByDescription(m_btngroup_tf_switch.SelectedButtonText());   // "All" = PERIOD_CURRENT
   //--- The rows: each tracked TF of the Symbol x each template whose indicator Python reported
   string row_tf[];
   int row_template[];
   CIndicatorDE *row_indicator[];
   int count=0;
   for(int si=0;si<m_SymbolTFManager.Total();si++)
     {
      CSymbolTFSetting *symtf=m_SymbolTFManager.At(si);
      if(symtf==NULL || symtf.Symbol()!=symbol || (tf_filter!=PERIOD_CURRENT && symtf.TFEnum()!=tf_filter))
         continue;
      for(int ti=0;ti<m_IndicatorTemplateManager.Total();ti++)
        {
         CIndicatorSetting *entry=m_IndicatorTemplateManager.At(ti);
         if(entry==NULL)
            continue;
         MqlParam params[];
         entry.GetRawParams(params);
         CIndicatorDE *indicator=m_IndicatorsCollection.GetIndicator(entry.TypeEnum(),params,symbol,symtf.TFEnum());
         if(indicator==NULL)
            continue;
         ::ArrayResize(row_tf,count+1);
         ::ArrayResize(row_template,count+1);
         ::ArrayResize(row_indicator,count+1);
         row_tf[count]=TimeframeDescription(symtf.TFEnum());
         row_template[count]=ti;
         row_indicator[count]=indicator;
         count++;
        }
     }
   //--- The structure of the table (rows, images) is built when the number of rows changes; a force or another indicator on a row only rewrites its label
   int old_count=::ArraySize(s_row_key);
   bool rebuild=(count!=old_count);
   if(rebuild)
     {
      ::Print("MY DEBUG CGUIPannel::SyncTable_PreTradeSymbolMonitor: TableSize rows ",old_count," -> ",count," main window locked=",m_window_main.IsLocked());   //Print Debug
      ::ArrayResize(s_row_key,count);
      m_table_indicator_PreTradeSymbolMonitor.TableSize(COLUMNS_PRETRADEMON_TOTAL,count);
      if(count==0)
         return true;
      uint tf_img[]  ={IMAGE_RESOURCE_BMP16_BAR_CHART_BMP,IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
      uint sig_img[] ={IMAGE_RESOURCE_BMP16_ARROW_UP_PNG,IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG,IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
      uint val_img[] ={IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG,IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG,IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP};
      uint sl_marker_img[]   ={IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG,IMAGE_RESOURCE_BMP16_STOP_GRAY_BMP};
      uint trail_marker_img[]={IMAGE_RESOURCE_BMP16_TRAILLING_PNG,IMAGE_RESOURCE_BMP16_STOP_GRAY_BMP};
      for(int row=0;row<count;row++)
        {
         m_table_indicator_PreTradeSymbolMonitor.View().RowView(row).TextAlign(PRETRADEMON_CONTENT_ALIGN);
         m_table_indicator_PreTradeSymbolMonitor.CellView(0,row).SetImages(tf_img);
         m_table_indicator_PreTradeSymbolMonitor.CellView(1,row).SetImages(sig_img);
         m_table_indicator_PreTradeSymbolMonitor.CellView(2,row).SetImages(val_img);
         m_table_indicator_PreTradeSymbolMonitor.Cell(3,row).SetDigits(2);
         m_table_indicator_PreTradeSymbolMonitor.CellView(3,row).DirectionColors(C'0,160,0',C'200,0,0',clrGray);
         m_table_indicator_PreTradeSymbolMonitor.CellView(4,row).SetImages(sl_marker_img);
         m_table_indicator_PreTradeSymbolMonitor.CellView(5,row).SetImages(trail_marker_img);
        }
     }
   //--- Values every call - a cell redraws only when its value really changed
   for(int row=0;row<count;row++)
     {
      CIndicatorSetting *entry=m_IndicatorTemplateManager.At(row_template[row]);
      string row_key=row_tf[row]+"|"+(string)row_template[row];
      bool row_changed=(force || rebuild || row_key!=s_row_key[row]);
      s_row_key[row]=row_key;
      double value=row_indicator[row].Value();
      double previous=row_indicator[row].Previous();
      ENUM_SIGNAL_DIR dir=row_indicator[row].Dir();
      if(entry==NULL)
         continue;
      bool tf_active=(symbol==::Symbol() && row_tf[row]==TimeframeDescription((ENUM_TIMEFRAMES)::Period()));
      m_table_indicator_PreTradeSymbolMonitor.SetValue(0,row,row_tf[row]);
      m_table_indicator_PreTradeSymbolMonitor.CellView(0,row).ChangeImage(tf_active ? 0 : 1);
      if(row_changed)
         m_table_indicator_PreTradeSymbolMonitor.SetValue(2,row,entry.DisplayLabel());
      if(value==EMPTY_VALUE)
         m_table_indicator_PreTradeSymbolMonitor.SetValue(3,row,"-");
      else
         m_table_indicator_PreTradeSymbolMonitor.SetValue(3,row,value);
      int slope=(value==EMPTY_VALUE || previous==EMPTY_VALUE || value==previous) ? 2 : (value>previous ? 0 : 1);
      m_table_indicator_PreTradeSymbolMonitor.CellView(2,row).ChangeImage(slope);
      m_table_indicator_PreTradeSymbolMonitor.CellView(1,row).ChangeImage(dir==SIGNAL_BUY ? 0 : dir==SIGNAL_SELL ? 1 : slope);
      m_table_indicator_PreTradeSymbolMonitor.CellView(4,row).ChangeImage(1);   // gray until the stop loss setting is ported
      m_table_indicator_PreTradeSymbolMonitor.CellView(5,row).ChangeImage(1);   // gray until the trailing setting is ported
     }
   return m_table_indicator_PreTradeSymbolMonitor.Update(false);
  }
 //+------------------------------------------------------------------+
 //| New Order form                                                    |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTradingForm(const int x_gap,const int y_gap)
  {
   int row0_y=y_gap;
   int row1_y=y_gap+M_CONTROL_YDISTANCE;
   int row2_y=y_gap+2*M_CONTROL_YDISTANCE+M_CONTROL_BORDER_GAP;
   int row3_y=y_gap+3*M_CONTROL_YDISTANCE+M_CONTROL_BORDER_GAP;
   int row4_y=y_gap+4*M_CONTROL_YDISTANCE+M_CONTROL_BORDER_GAP;
   int check_w=M_SYMBOL_WITHICON_WIDTH+10;
   m_new_order_is_buy=true;
   m_checkbox_use_RiskPerNewTrade.SetText("Use RPT %");
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_checkbox_use_RiskPerNewTrade);
   if(!m_checkbox_use_RiskPerNewTrade.Create(m_chart_id,m_subwin,"CheckUseRiskPerTrade",x_gap,row0_y,check_w,M_CONTROL_HEIGHT))
      return false;
   m_checkbox_use_RiskPerNewTrade.SetState(false);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_edit_RiskPerNewTrade);
   if(!m_edit_RiskPerNewTrade.CreateTextEdit(m_chart_id,m_subwin,"EditRiskPerTrade",x_gap,row1_y,M_SYMBOL_WITHICON_WIDTH,M_CONTROL_HEIGHT,M_SYMBOL_WITHICON_WIDTH-1))
      return false;
   m_edit_RiskPerNewTrade.SetValue("1.0");
   m_edit_RiskPerNewTrade.Hide();   // shown while "Use RPT %" is checked
   m_combobox_order_type.ItemsTotal(4);
   m_combobox_order_type.SetValue(0,"Market");
   m_combobox_order_type.SetValue(1,"Limit");
   m_combobox_order_type.SetValue(2,"Stop");
   m_combobox_order_type.SetValue(3,"Stop Limit");
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_combobox_order_type);
   if(!m_combobox_order_type.CreateComboBox(m_chart_id,m_subwin,"ComboOrderType",x_gap,row2_y,M_SYMBOL_WITHICON_WIDTH,M_CONTROL_HEIGHT,M_SYMBOL_WITHICON_WIDTH-1))
      return false;
   m_combobox_order_type.SelectItem(0);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_edit_order_type_value);
   if(!m_edit_order_type_value.CreateTextEdit(m_chart_id,m_subwin,"EditOrderTypeValue",x_gap,row3_y,M_SYMBOL_WITHICON_WIDTH,M_CONTROL_HEIGHT,M_SYMBOL_WITHICON_WIDTH-1))
      return false;
   m_edit_order_type_value.SetValue("0.0");
   m_edit_order_type_value.Hide();   // Market is the default: no price to give
   m_btn_send_toTrade.SetText("Buy");
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_btn_send_toTrade);
   if(!m_btn_send_toTrade.Create(m_chart_id,m_subwin,"BtnSendToTrade",x_gap,row4_y,M_SYMBOL_WITHICON_WIDTH,M_CONTROL_HEIGHT))
      return false;
   UpdateSendButtonAppearance();
   return true;
  }
 void CGUIPannel::UpdateSendButtonAppearance(void)
  {
   int type_idx=m_combobox_order_type.GetListViewPointer().SelectedItemIndex();
   string type_suffix="";
   switch(type_idx)
     {
      case 1: type_suffix=" Limit";      break;
      case 2: type_suffix=" Stop";       break;
      case 3: type_suffix=" Stop Limit"; break;
      default: break;
     }
   color back=m_new_order_is_buy ? C'0,160,0' : C'200,0,0';
   m_btn_send_toTrade.SetText((m_new_order_is_buy ? "Buy" : "Sell")+type_suffix);
   m_btn_send_toTrade.GetBackColorControl().InitColors(back,back,back,clrLightGray);
   m_btn_send_toTrade.GetForeColorControl().InitColors(clrWhite,clrWhite,clrWhite,clrGray);
   m_btn_send_toTrade.ColorChange(COLOR_STATE_DEFAULT);
   m_btn_send_toTrade.Draw(true);
   if(type_idx>0)
      m_edit_order_type_value.Show();
   else
      m_edit_order_type_value.Hide();
  }
 void CGUIPannel::OnClickUseRiskPerNewTradeCheckbox(void)
  {
   if(m_checkbox_use_RiskPerNewTrade.State())
      m_edit_RiskPerNewTrade.Show();
   else
      m_edit_RiskPerNewTrade.Hide();
  }
 //--- The trading engine is not ported yet: print what would be sent
 void CGUIPannel::OnClickSendNewOrder(void)
  {
   int order_type_idx=m_combobox_order_type.GetListViewPointer().SelectedItemIndex();
   ::Print("MY DEBUG CGUIPannel::OnClickSendNewOrder: symbol=",GetNewOrderSymbol()," ",(m_new_order_is_buy ? "BUY" : "SELL"),
           " lot=",GetNewOrderLot()," order_type=",order_type_idx," price=",m_edit_order_type_value.GetValue(),
           " use_risk=",m_checkbox_use_RiskPerNewTrade.State()," risk%=",m_edit_RiskPerNewTrade.GetValue());   //Print Debug
  }
 //+------------------------------------------------------------------+
 //| New Order Symbol / Direction / Lot and what the trade would risk  |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_PositionPretradeView(const int x,const int y)
  {
   m_table_position_pretrade_view.TableSize(COLUMNS_PRETRADE_VIEW_TOTAL,1);
   m_table_position_pretrade_view.View().ShowHeaders(true);
   m_table_position_pretrade_view.View().SelectableRow(false);
   m_table_position_pretrade_view.View().IsSortMode(false);
   m_table_position_pretrade_view.View().ColumnResizeMode(false);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_table_position_pretrade_view);
   if(!m_table_position_pretrade_view.CreateTable(m_chart_id,m_subwin,"TablePretradeView",x,y,m_table_indicator_PreTradeSymbolMonitor.Width(),PRETRADE_VIEW_TABLE_HEIGHT+2))
      return false;
   CTableHeaderView *header=m_table_position_pretrade_view.View().GetHeaderViewPointer();
   header.ColumnsWidth(PRETRADE_VIEW_WIDTH);
   header.TextAlign(PRETRADE_VIEW_HEADER_ALIGN);
   header.TextXOffset(PRETRADE_VIEW_TEXT_X_OFFSET);
   header.ImageXOffset(PRETRADE_VIEW_IMAGE_X_OFFSET);
   m_table_position_pretrade_view.View().ColumnResizeMode(true,COL_PTV_LOT);
   m_table_position_pretrade_view.View().ColumnResizeMode(true,COL_PTV_SLPRICE);
   m_table_position_pretrade_view.View().ColumnResizeMode(true,COL_PTV_SLPROFIT);
   m_table_position_pretrade_view.View().ColumnResizeMode(true,COL_PTV_RISK);
   m_table_position_pretrade_view.View().RowView(0).TextAlign(PRETRADE_VIEW_CONTENT_ALIGN);
   m_table_position_pretrade_view.CellView(COL_PTV_SYMBOL,0).CellType(CELL_COMBOBOX);
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_SYMBOL,"Symbol");
   SyncComboBox_NewOrderSymbol();
   string lot_list[1]={"0.01"};
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_LOT,"Lot");
   m_table_position_pretrade_view.CellView(COL_PTV_LOT,0).CellType(CELL_COMBOBOX);
   m_table_position_pretrade_view.CellView(COL_PTV_LOT,0).SetValueList(lot_list);
   m_table_position_pretrade_view.SetValue(COL_PTV_LOT,0,lot_list[0]);
   uint dir_header_img[]={IMAGE_RESOURCE_BMP16_ORDER_DIR_PNG};
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_DIR,"");
   m_table_position_pretrade_view.SetHeaderImage(COL_PTV_DIR,dir_header_img);
   m_table_position_pretrade_view.CellView(COL_PTV_DIR,0).CellType(CELL_CHECKBOX);
   uint sltype_header_img[]={IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG};
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_SLTYPE,"");
   m_table_position_pretrade_view.SetHeaderImage(COL_PTV_SLTYPE,sltype_header_img);
   m_table_position_pretrade_view.CellView(COL_PTV_SLTYPE,0).CellType(CELL_CHECKBOX);
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_SLPRICE,"SL Price");
   m_table_position_pretrade_view.CellView(COL_PTV_SLPRICE,0).DirectionColors(C'0,160,0',C'200,0,0',clrGray);
   uint slprofit_header_img[]={IMAGE_RESOURCE_BMP16_PROFIT_RED_PNG};
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_SLPROFIT,"");
   m_table_position_pretrade_view.SetHeaderImage(COL_PTV_SLPROFIT,slprofit_header_img);
   m_table_position_pretrade_view.CellView(COL_PTV_SLPROFIT,0).DirectionColors(C'200,0,0',C'0,160,0',clrGray);
   m_table_position_pretrade_view.Cell(COL_PTV_SLPROFIT,0).SetDigits(2);
   uint trailtype_header_img[]={IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_TRAILTYPE,"");
   m_table_position_pretrade_view.SetHeaderImage(COL_PTV_TRAILTYPE,trailtype_header_img);
   m_table_position_pretrade_view.CellView(COL_PTV_TRAILTYPE,0).CellType(CELL_CHECKBOX);
   m_table_position_pretrade_view.SetHeaderText(COL_PTV_RISK,"Risk $");
   m_table_position_pretrade_view.CellView(COL_PTV_RISK,0).DirectionColors(C'200,0,0',C'0,160,0',clrGray);
   m_table_position_pretrade_view.Cell(COL_PTV_RISK,0).SetDigits(2);
   m_table_position_pretrade_view.View().Rebuild(true);
   return true;
  }
 //--- The Symbols of the Market Watch; one no longer listed falls back to the chart Symbol. true when the selected Symbol changed
 bool CGUIPannel::SyncComboBox_NewOrderSymbol(void)
  {
   string sym_list[];
   int count=0;
   CArrayObj *sym_objs=(m_SymbolsCollection!=NULL) ? m_SymbolsCollection.GetList() : NULL;
   int total=(sym_objs!=NULL) ? sym_objs.Total() : 0;
   for(int i=0;i<total;i++)
     {
      CSymbol *sym_obj=sym_objs.At(i);
      if(sym_obj==NULL)
         continue;
      ::ArrayResize(sym_list,count+1);
      sym_list[count++]=sym_obj.Name();
     }
   if(count==0)
     {
      ::ArrayResize(sym_list,1);
      sym_list[count++]=::Symbol();
     }
   string selected=GetNewOrderSymbol();
   bool still_listed=false;
   for(int k=0;k<count && !still_listed;k++)
      still_listed=(sym_list[k]==selected);
   string new_selected=still_listed ? selected : ::Symbol();
   m_table_position_pretrade_view.CellView(COL_PTV_SYMBOL,0).SetValueList(sym_list);
   m_table_position_pretrade_view.SetValue(COL_PTV_SYMBOL,0,new_selected);
   return (new_selected!=selected);
  }
 //--- Without the trading engine: the Lot list is the minimum lot, price and money cells read N/A
 bool CGUIPannel::SyncTable_PositionPretradeView(bool force=false)
  {
   static string s_symbol="";
   static int    s_dir=-1;
   string sym=GetNewOrderSymbol();
   if(sym=="")
      return false;
   bool identity_changed=(force || sym!=s_symbol);
   bool dir_changed=((int)m_new_order_is_buy!=s_dir);
   s_symbol=sym;
   s_dir=(int)m_new_order_is_buy;
   if(identity_changed)
     {
      uint sl_type_img[]   ={IMAGE_RESOURCE_BMP16_STOPLOSTGREY_PNG,IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
      uint trail_type_img[]={IMAGE_RESOURCE_BMP16_TRAILLING_PNG,IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
      uint sym_img[]       ={IMAGE_RESOURCE_BMP16_BAR_CHART_BMP,IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
      uint dir_img[]       ={IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG,IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG};
      m_table_position_pretrade_view.CellView(COL_PTV_SLTYPE,0).SetImages(sl_type_img);
      m_table_position_pretrade_view.CellView(COL_PTV_TRAILTYPE,0).SetImages(trail_type_img);
      m_table_position_pretrade_view.CellView(COL_PTV_SYMBOL,0).SetImages(sym_img);
      m_table_position_pretrade_view.CellView(COL_PTV_DIR,0).SetImages(dir_img);
      m_table_position_pretrade_view.Cell(COL_PTV_SLPRICE,0).SetDigits((int)::SymbolInfoInteger(sym,SYMBOL_DIGITS));
      m_table_position_pretrade_view.SetValue(COL_PTV_SLTYPE,0,(long)CANV_ELEMENT_CHEK_STATE_UNCHECKED);
      m_table_position_pretrade_view.SetValue(COL_PTV_TRAILTYPE,0,(long)CANV_ELEMENT_CHEK_STATE_UNCHECKED);
      m_table_position_pretrade_view.SetValue(COL_PTV_SLPRICE,0,"N/A");
      m_table_position_pretrade_view.SetValue(COL_PTV_SLPROFIT,0,"N/A");
      m_table_position_pretrade_view.SetValue(COL_PTV_RISK,0,"N/A");
      CSymbol *lot_sym=(m_SymbolsCollection!=NULL) ? m_SymbolsCollection.GetSymbolObjByName(sym) : NULL;
      double min_lot=(lot_sym!=NULL) ? lot_sym.LotsMin() : 0.0;
      double step_lot=(lot_sym!=NULL) ? lot_sym.LotsStep() : 0.0;
      if(min_lot>0.0 && step_lot>0.0)
        {
         int lot_digits=(int)::MathMax(0.0,::MathCeil(-::MathLog10(step_lot)-0.0000001));
         string lot_list[1];
         lot_list[0]=::DoubleToString(min_lot,lot_digits);
         m_table_position_pretrade_view.CellView(COL_PTV_LOT,0).CellType(CELL_COMBOBOX);
         m_table_position_pretrade_view.CellView(COL_PTV_LOT,0).SetValueList(lot_list);
         m_table_position_pretrade_view.SetValue(COL_PTV_LOT,0,lot_list[0]);
        }
      else
        {
         m_table_position_pretrade_view.CellView(COL_PTV_LOT,0).CellType(CELL_SIMPLE);
         m_table_position_pretrade_view.SetValue(COL_PTV_LOT,0,"N/A");
        }
     }
   if(identity_changed || dir_changed)
     {
      m_table_position_pretrade_view.CellView(COL_PTV_SYMBOL,0).ChangeImage(sym==::Symbol() ? 0 : 1);
      m_table_position_pretrade_view.SetValue(COL_PTV_DIR,0,(long)(m_new_order_is_buy ? CANV_ELEMENT_CHEK_STATE_UNCHECKED : CANV_ELEMENT_CHEK_STATE_CHECKED));
     }
   return m_table_position_pretrade_view.Update(false);
  }
 //--- Picking another Symbol in the combobox: the chart goes there (the monitor follows the chart Symbol)
 void CGUIPannel::OnSymbolToTradeChanged(const bool move_chart=true)
  {
   static bool   s_initialized=false;
   static string s_last_symbol="";
   string symbol=GetNewOrderSymbol();
   if(symbol=="")
      return;
   bool symbol_changed=!s_initialized || symbol!=s_last_symbol;
   s_initialized=true;
   s_last_symbol=symbol;
   if(!symbol_changed)
     {
      double picked_lot=GetNewOrderLot();
      if(picked_lot>0.0)
         m_new_order_lot_last=picked_lot;
      SyncTable_PositionPretradeView();
      return;
     }
   if(move_chart && m_SymbolTFManager!=NULL)
      m_SymbolTFManager.NotifySettingChanged(symbol,(ENUM_TIMEFRAMES)::Period());
   SyncTable_PositionPretradeView(true);
  }
 void CGUIPannel::OnClickTogglePretradeDirection(void)
  {
   m_new_order_is_buy=(m_table_position_pretrade_view.Cell(COL_PTV_DIR,0).ValueL()==CANV_ELEMENT_CHEK_STATE_UNCHECKED);
   UpdateSendButtonAppearance();
   SyncTable_PositionPretradeView();
  }
 //--- Stop loss and trailing of the trade to come: the setting is not ported yet
 void CGUIPannel::OnClickTogglePretradeSLType(void)
  {
   ::Print("MY DEBUG CGUIPannel::OnClickTogglePretradeSLType: symbol=",GetNewOrderSymbol());   //Print Debug
  }
 void CGUIPannel::OnClickTogglePretradeTrailType(void)
  {
   ::Print("MY DEBUG CGUIPannel::OnClickTogglePretradeTrailType: symbol=",GetNewOrderSymbol());   //Print Debug
  }
 //+------------------------------------------------------------------+
 //| Open positions per Symbol and direction with their SL / trailing; |
 //| the rows come with the trading engine                             |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_PositionsStoplostAndTrailling(const int x,const int y)
  {
   int table_w=2+16;   // border + vertical scrollbar
   for(int c=0;c<COLUMNS_POS_SL_TRAIL_TOTAL;c++)
      table_w+=POSITIONS_SLTRAIL_WIDTH[c];
   m_table_positions_StoplostAndTrailling.TableSize(COLUMNS_POS_SL_TRAIL_TOTAL,0);
   m_table_positions_StoplostAndTrailling.View().ShowHeaders(true);
   m_table_positions_StoplostAndTrailling.View().SelectableRow(true);
   m_table_positions_StoplostAndTrailling.View().LightsHover(true);
   m_table_positions_StoplostAndTrailling.View().IsSortMode(false);
   m_table_positions_StoplostAndTrailling.View().ColumnResizeMode(true);
   m_table_positions_StoplostAndTrailling.AutoYResizeMode(true);
   m_table_positions_StoplostAndTrailling.AutoYResizeBottomOffset(M_CONTROL_BORDER_GAP);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_table_positions_StoplostAndTrailling);
   if(!m_table_positions_StoplostAndTrailling.CreateTable(m_chart_id,m_subwin,"TablePositionsSLTrail",x,y,table_w))
      return false;
   CTableHeaderView *header=m_table_positions_StoplostAndTrailling.View().GetHeaderViewPointer();
   header.ColumnsWidth(POSITIONS_SLTRAIL_WIDTH);
   header.TextAlign(POSITIONS_SLTRAIL_HEADER_ALIGN);
   header.TextXOffset(POSITIONS_SLTRAIL_TEXT_X_OFFSET);
   header.ImageXOffset(POSITIONS_SLTRAIL_IMAGE_X_OFFSET);
   uint dir_header_img[]      ={IMAGE_RESOURCE_BMP16_ORDER_DIR_PNG};
   uint sltype_header_img[]   ={IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG};
   uint slprofit_header_img[] ={IMAGE_RESOURCE_BMP16_PROFIT_RED_PNG};
   uint run_img[]             ={IMAGE_RESOURCE_BMP16_RUN_PNG};
   uint trailtype_header_img[]={IMAGE_RESOURCE_BMP16_TRAILLING_PNG};
   uint profit_header_img[]   ={IMAGE_RESOURCE_BMP16_PROFIT_GREY_PNG};
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_SYMBOL,"Symbol");
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_DIR,"");
   m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_DIR,dir_header_img);
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_VOLUME,"Vol");
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_NO,"No");
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_SLTYPE,"");
   m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_SLTYPE,sltype_header_img);
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_SLPRICE,"SL Price");
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_SLPROFIT,"");
   m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_SLPROFIT,slprofit_header_img);
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_RUN_SL,"");
   m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_RUN_SL,run_img);
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_TRAILTYPE,"");
   m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_TRAILTYPE,trailtype_header_img);
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_RUN_TRAIL,"");
   m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_RUN_TRAIL,run_img);
   m_table_positions_StoplostAndTrailling.SetHeaderText(COL_PST_PROFIT,"");
   m_table_positions_StoplostAndTrailling.SetHeaderImage(COL_PST_PROFIT,profit_header_img);
   m_table_positions_StoplostAndTrailling.View().Rebuild(true);
   return true;
  }
#endif // CGUIPANNEL_MAINWINDOWS_TABTRADING_MQH
