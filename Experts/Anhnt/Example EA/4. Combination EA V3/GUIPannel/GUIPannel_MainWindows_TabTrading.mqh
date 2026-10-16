//+------------------------------------------------------------------+
//|                           GUIPannel_MainWindows_TabTrading.mqh |
//| Trading tab of m_window_main: TF switch, the indicator monitor   |
//| (what Python calculated), the New Order form and the position    |
//| tables, the order sending and the stop loss / trailing type      |
//| icons, which read the trading engine                             |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_MAINWINDOWS_TABTRADING_MQH
#define CGUIPANNEL_MAINWINDOWS_TABTRADING_MQH
 #include "GUIPannel.mqh"
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
   if(!m_table_indicator_PreTradeSymbolMonitor.CreateTable(m_ChartObj.GetChartID(),M_SUBWINDOW_MAIN,"TablePreTradeMonitor",x,y,columns_width_total+20,TRADING_FORM_HEIGHT))
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
   ENUM_TIMEFRAMES tf_filter=GetTFSwitchSelection();
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
   m_combobox_order_type.ItemsTotal(4);
   m_combobox_order_type.SetValue(0,"Market");
   m_combobox_order_type.SetValue(1,"Limit");
   m_combobox_order_type.SetValue(2,"Stop");
   m_combobox_order_type.SetValue(3,"Stop Limit");
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_combobox_order_type);
   if(!m_combobox_order_type.CreateComboBox(m_ChartObj.GetChartID(),M_SUBWINDOW_MAIN,"ComboOrderType",x_gap,row2_y,M_SYMBOL_WITHICON_WIDTH,M_CONTROL_HEIGHT,M_SYMBOL_WITHICON_WIDTH-1))
      return false;
   m_combobox_order_type.SelectItem(0);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_edit_order_type_value);
   if(!m_edit_order_type_value.CreateTextEdit(m_ChartObj.GetChartID(),M_SUBWINDOW_MAIN,"EditOrderTypeValue",x_gap,row3_y,M_SYMBOL_WITHICON_WIDTH,M_CONTROL_HEIGHT,M_SYMBOL_WITHICON_WIDTH-1))
      return false;
   m_edit_order_type_value.SetValue("0.0");
   m_edit_order_type_value.Hide();   // Market is the default: no price to give
   m_btn_send_toTrade.SetText("Buy");
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_TRADING,m_btn_send_toTrade);
   if(!m_btn_send_toTrade.Create(m_ChartObj.GetChartID(),M_SUBWINDOW_MAIN,"BtnSendToTrade",x_gap,row4_y,M_SYMBOL_WITHICON_WIDTH,M_CONTROL_HEIGHT))
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
 void CGUIPannel::OnClickSendNewOrder(void)
  {
   if(m_TradingEngine==NULL)
      return;
   string symbol=GetNewOrderSymbol();
   if(symbol=="")
      return;
   double lot=GetNewOrderLot();
   if(lot<=0.0)
      return;   // the Lot cell reads "N/A": nothing valid to send
   ENUM_POSITION_TYPE dir=m_new_order_is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
   int order_type_idx=m_combobox_order_type.GetListViewPointer().SelectedItemIndex();
   if(order_type_idx==3)
      return;   // Stop Limit is not supported yet
   double price=::StringToDouble(m_edit_order_type_value.GetValue());
   m_TradingEngine.SendNewOrder(symbol,dir,lot,order_type_idx,price);
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
   if(!m_table_position_pretrade_view.CreateTable(m_ChartObj.GetChartID(),M_SUBWINDOW_MAIN,"TablePretradeView",x,y,m_table_indicator_PreTradeSymbolMonitor.Width(),PRETRADE_VIEW_TABLE_HEIGHT+2))
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
 //--- The Lot list is rebuilt when its inputs change; SL price, SL profit and Risk $ come from the engine on every call
 bool CGUIPannel::SyncTable_PositionPretradeView(bool force=false)
  {
   static string s_scoped_symbol="";
   static int    s_scoped_dir=-1;
   static bool   s_use_risk_old=false;
   static double s_risk_pct_old=EMPTY_VALUE;
   static double s_free_margin_old=EMPTY_VALUE;   // the Lot list also depends on the Free Margin (CalcMaxLotByRisk margin cap)
   string sym=GetNewOrderSymbol();
   ENUM_POSITION_TYPE type=m_new_order_is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
   if(sym=="")
      return false;
   bool identity_changed=(force || sym!=s_scoped_symbol);
   bool dir_changed=((int)type!=s_scoped_dir);
   s_scoped_symbol=sym;
   s_scoped_dir=(int)type;
   CTradingSetupSetting *row_setting=(m_TradingSetupManager!=NULL) ? m_TradingSetupManager.FindByIdentity(sym) : NULL;
   bool sl_fixed=(row_setting==NULL) || (row_setting.StopLostMode()==SL_MODE_FIXED);
   bool trail_fixed=(row_setting==NULL) || (row_setting.TrailingMode()==SL_MODE_FIXED);
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
     }
   //--- Icon / checkbox cells are set on every call: a cell redraws only when its value really changed
   m_table_position_pretrade_view.SetValue(COL_PTV_SLTYPE,0,(long)(sl_fixed ? CANV_ELEMENT_CHECK_STATE_UNCHECKED : CANV_ELEMENT_CHECK_STATE_CHECKED));
   m_table_position_pretrade_view.SetValue(COL_PTV_TRAILTYPE,0,(long)(trail_fixed ? CANV_ELEMENT_CHECK_STATE_UNCHECKED : CANV_ELEMENT_CHECK_STATE_CHECKED));
   m_table_position_pretrade_view.CellView(COL_PTV_SYMBOL,0).ChangeImage(sym==::Symbol() ? 0 : 1);
   m_table_position_pretrade_view.SetValue(COL_PTV_DIR,0,(long)((type==POSITION_TYPE_BUY) ? CANV_ELEMENT_CHECK_STATE_UNCHECKED : CANV_ELEMENT_CHECK_STATE_CHECKED));
   bool use_risk=(m_TradingSetupManager!=NULL && m_TradingSetupManager.UseRiskPerNewTrade());   // an input of the EA
   //--- A tab or window shown again shows every element again: the visibility is asserted on every call
   int order_type_idx=m_combobox_order_type.GetListViewPointer().SelectedItemIndex();
   if(order_type_idx>0) m_edit_order_type_value.Show(); else m_edit_order_type_value.Hide();
   //--- Unchecked = CalcMaxLotByRisk with 100 %: the most the balance allows
   double risk_pct=use_risk ? m_TradingSetupManager.RiskPerNewTrade() : 100.0;
   //--- Rounded: the Free Margin drifts with the floating P&L, the list is rebuilt on real margin changes only
   double free_margin_rounded=::MathRound(::AccountInfoDouble(ACCOUNT_MARGIN_FREE));
   if(identity_changed || dir_changed || use_risk!=s_use_risk_old || risk_pct!=s_risk_pct_old || free_margin_rounded!=s_free_margin_old)
     {
      s_use_risk_old=use_risk;
      s_risk_pct_old=risk_pct;
      s_free_margin_old=free_margin_rounded;
      CSymbol *lot_sym=(m_SymbolsCollection!=NULL) ? m_SymbolsCollection.GetSymbolObjByName(sym) : NULL;
      double min_lot=(lot_sym!=NULL) ? lot_sym.LotsMin() : 0.0;
      double step_lot=(lot_sym!=NULL) ? lot_sym.LotsStep() : 0.0;
      double max_lot=(m_TradingEngine!=NULL) ? m_TradingEngine.CalcMaxLotByRisk(sym,type,risk_pct) : 0.0;
      bool lot_enabled=(lot_sym!=NULL) && step_lot>0.0 && min_lot>0.0 && max_lot>=min_lot;
      if(lot_enabled)
        {
         int lot_digits=(int)::MathMax(0.0,::MathCeil(-::MathLog10(step_lot)-0.0000001));
         int count=(int)::MathRound((max_lot-min_lot)/step_lot)+1;
         if(count<1)   count=1;
         if(count>200) count=200;   // LotsMin..LotsMax can be a huge range on some Symbols
         string lot_list[];
         ::ArrayResize(lot_list,count);
         for(int i=0;i<count;i++)
           {
            double v=min_lot+i*step_lot;
            if(v>max_lot) v=max_lot;
            lot_list[i]=::DoubleToString(v,lot_digits);
           }
         //--- The minimum lot, or the lot the user picked before
         int default_idx=0;
         if(m_new_order_lot_last>0.0)
           {
            int nearest_idx=(int)::MathRound((m_new_order_lot_last-min_lot)/step_lot);
            if(nearest_idx>=0 && nearest_idx<count) default_idx=nearest_idx;
           }
         m_table_position_pretrade_view.CellView(COL_PTV_LOT,0).CellType(CELL_COMBOBOX);
         m_table_position_pretrade_view.CellView(COL_PTV_LOT,0).SetValueList(lot_list);
         m_table_position_pretrade_view.SetValue(COL_PTV_LOT,0,lot_list[default_idx]);
        }
      else
        {
         m_table_position_pretrade_view.CellView(COL_PTV_LOT,0).CellType(CELL_SIMPLE);
         m_table_position_pretrade_view.SetValue(COL_PTV_LOT,0,"N/A");
        }
     }
   //--- Numbers go in raw: the cell tracks its value and colors the up / down
   bool sl_price_from_trail;
   double sl_price=(m_TradingEngine!=NULL) ? m_TradingEngine.GetPreviewSLTargetPrice(sym,type,sl_price_from_trail) : EMPTY_VALUE;
   CSymbol *sym_obj_for_lot=(m_SymbolsCollection!=NULL) ? m_SymbolsCollection.GetSymbolObjByName(sym) : NULL;
   double default_lot=(sym_obj_for_lot!=NULL) ? sym_obj_for_lot.LotsMin() : 0.0;
   double sl_profit=(m_MarketCollection!=NULL && sl_price!=EMPTY_VALUE && default_lot>0.0) ? m_MarketCollection.SumFloatingProfit(sym,type,sl_price,default_lot) : EMPTY_VALUE;
   double actual_lot=GetNewOrderLot();
   double risk=(m_MarketCollection!=NULL && sl_price!=EMPTY_VALUE && actual_lot>0.0) ? m_MarketCollection.SumFloatingProfit(sym,type,sl_price,actual_lot) : EMPTY_VALUE;
   //--- "N/A": the mode is Indicator and the indicator is not served yet, or no StopLost / Trailing is on
   if(sl_price==EMPTY_VALUE)  m_table_position_pretrade_view.SetValue(COL_PTV_SLPRICE,0,"N/A");  else m_table_position_pretrade_view.SetValue(COL_PTV_SLPRICE,0,sl_price);
   if(sl_profit==EMPTY_VALUE) m_table_position_pretrade_view.SetValue(COL_PTV_SLPROFIT,0,"N/A"); else m_table_position_pretrade_view.SetValue(COL_PTV_SLPROFIT,0,sl_profit);
   if(risk==EMPTY_VALUE)      m_table_position_pretrade_view.SetValue(COL_PTV_RISK,0,"N/A");     else m_table_position_pretrade_view.SetValue(COL_PTV_RISK,0,risk);
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
   m_new_order_is_buy=(m_table_position_pretrade_view.Cell(COL_PTV_DIR,0).ValueL()==CANV_ELEMENT_CHECK_STATE_UNCHECKED);
   UpdateSendButtonAppearance();
   SyncTable_PositionPretradeView();
  }
 //--- Stop loss / trailing icon of the New Order row: the cell already flipped, the setting of the Symbol follows it
 void CGUIPannel::OnClickTogglePretradeSLType(void)
  {
   if(m_TradingSetupManager==NULL)
      return;
   string symbol=GetNewOrderSymbol();
   if(symbol=="")
      return;
   CTradingSetupSetting *row_setting=m_TradingSetupManager.FindByIdentity(symbol);
   if(row_setting==NULL) row_setting=m_TradingSetupManager.Add_TradingSetupSetting(symbol);
   if(row_setting==NULL)
      return;
   bool fixed=(m_table_position_pretrade_view.Cell(COL_PTV_SLTYPE,0).ValueL()==CANV_ELEMENT_CHECK_STATE_UNCHECKED);
   row_setting.StopLostMode(fixed ? SL_MODE_FIXED : SL_MODE_INDICATOR);
   m_TradingSetupManager.NotifySettingChanged(symbol);
   SyncTable_PositionPretradeView(true);
  }
 void CGUIPannel::OnClickTogglePretradeTrailType(void)
  {
   if(m_TradingSetupManager==NULL)
      return;
   string symbol=GetNewOrderSymbol();
   if(symbol=="")
      return;
   CTradingSetupSetting *row_setting=m_TradingSetupManager.FindByIdentity(symbol);
   if(row_setting==NULL) row_setting=m_TradingSetupManager.Add_TradingSetupSetting(symbol);
   if(row_setting==NULL)
      return;
   bool fixed=(m_table_position_pretrade_view.Cell(COL_PTV_TRAILTYPE,0).ValueL()==CANV_ELEMENT_CHECK_STATE_UNCHECKED);
   row_setting.TrailingMode(fixed ? SL_MODE_FIXED : SL_MODE_INDICATOR);
   m_TradingSetupManager.NotifySettingChanged(symbol);
   SyncTable_PositionPretradeView(true);
  }
 //+------------------------------------------------------------------+
 //| Open positions per Symbol and direction with their SL / trailing; |
 //| the rows are the Symbol / direction pairs with an open position   |
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
   if(!m_table_positions_StoplostAndTrailling.CreateTable(m_ChartObj.GetChartID(),M_SUBWINDOW_MAIN,"TablePositionsSLTrail",x,y,table_w))
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
 //--- Rows are the (Symbol, direction) pairs with an open position: built again only when that set changes, otherwise values only
 bool CGUIPannel::SyncTable_PositionsStoplostAndTrailling(void)
  {
   string symbols[];
   ENUM_POSITION_TYPE dirs[];
   int count=(m_MarketCollection!=NULL) ? m_MarketCollection.GetDistinctSymbolsAndDirections(symbols,dirs) : 0;
   static string s_prev_keys[];   // the row structure (Symbol_Direction per row), not a value cache
   string keys[];
   ::ArrayResize(keys,count);
   for(int i=0;i<count;i++)
      keys[i]=symbols[i]+"_"+(string)dirs[i];
   bool identity_changed=(::ArraySize(s_prev_keys)!=count);
   for(int i=0;i<count && !identity_changed;i++)
      identity_changed=(s_prev_keys[i]!=keys[i]);
   if(count==0)
     {
      if(::ArraySize(s_prev_keys)!=0)
        {
         m_table_positions_StoplostAndTrailling.DeleteAllRows(true);
         ::ArrayResize(s_prev_keys,0);
         return true;
        }
      return false;
     }
   if(identity_changed)
     {
      ::Print("MY DEBUG CGUIPannel::SyncTable_PositionsStoplostAndTrailling: rows ",::ArraySize(s_prev_keys)," -> ",count);   //Print Debug
      uint sym_img[]        ={IMAGE_RESOURCE_BMP16_BAR_CHART_BMP,IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
      uint dir_img[]        ={IMAGE_RESOURCE_BMP16_ORDER_BUY_PNG,IMAGE_RESOURCE_BMP16_ORDER_SELL_PNG};
      uint run_status_img[] ={IMAGE_RESOURCE_BMP16_START_BMP,IMAGE_RESOURCE_BMP16_START_GRAY_BMP};   // 0 = running (colored), 1 = not running (gray)
      uint sl_type_img[]    ={IMAGE_RESOURCE_BMP16_STOPLOSTGREY_PNG,IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
      uint trail_type_img[] ={IMAGE_RESOURCE_BMP16_TRAILLING_PNG,IMAGE_RESOURCE_BMP16_INDICATOR_BMP};
      m_table_positions_StoplostAndTrailling.DeleteAllRows();
      for(int i=0;i<count;i++)
         m_table_positions_StoplostAndTrailling.AddRow();
      ::ArrayResize(s_prev_keys,count);
      for(int row=0;row<count;row++)
        {
         s_prev_keys[row]=keys[row];
         m_table_positions_StoplostAndTrailling.View().RowView(row).TextAlign(POSITIONS_SLTRAIL_CONTENT_ALIGN);
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_SYMBOL,row).SetImages(sym_img);
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SYMBOL,row,symbols[row]);
         //--- The Buy / Sell icon alone says the direction
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_DIR,row).SetImages(dir_img);
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_DIR,row).ChangeImage((dirs[row]==POSITION_TYPE_BUY) ? 0 : 1);
         m_table_positions_StoplostAndTrailling.Cell(COL_PST_VOLUME,row).SetDigits(2);
         //--- Click to flip Fixed / Indicator (checkbox value 0 = Fixed, 1 = Indicator)
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_SLTYPE,row).CellType(CELL_CHECKBOX);
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_SLTYPE,row).SetImages(sl_type_img);
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_RUN_SL,row).CellType(CELL_BUTTON);
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_RUN_SL,row).SetImages(run_status_img);
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_TRAILTYPE,row).CellType(CELL_CHECKBOX);
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_TRAILTYPE,row).SetImages(trail_type_img);
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_RUN_TRAIL,row).CellType(CELL_BUTTON);
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_RUN_TRAIL,row).SetImages(run_status_img);
         m_table_positions_StoplostAndTrailling.Cell(COL_PST_SLPRICE,row).SetDigits((int)::SymbolInfoInteger(symbols[row],SYMBOL_DIGITS));
         m_table_positions_StoplostAndTrailling.Cell(COL_PST_SLPROFIT,row).SetDigits(2);
         m_table_positions_StoplostAndTrailling.Cell(COL_PST_PROFIT,row).SetDigits(2);
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_SLPRICE,row).DirectionColors(C'0,160,0',C'200,0,0',clrGray);
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_SLPROFIT,row).DirectionColors(C'0,160,0',C'200,0,0',clrGray);
         m_table_positions_StoplostAndTrailling.CellView(COL_PST_PROFIT,row).DirectionColors(C'0,160,0',C'200,0,0',clrGray);
        }
     }
   //--- Values on every call: a cell redraws only when its value really changed
   for(int row=0;row<count;row++)
     {
      string sym=symbols[row];
      ENUM_POSITION_TYPE type=dirs[row];
      m_table_positions_StoplostAndTrailling.CellView(COL_PST_SYMBOL,row).ChangeImage(sym==::Symbol() ? 0 : 1);
      m_table_positions_StoplostAndTrailling.SetValue(COL_PST_VOLUME,row,m_MarketCollection.SumVolume(sym,type));
      m_table_positions_StoplostAndTrailling.SetValue(COL_PST_NO,row,(long)m_MarketCollection.PositionsCount(sym,type));
      //--- Type and run icons: the single source of truth is CTradingSetupSetting
      CTradingSetupSetting *row_setting=(m_TradingSetupManager!=NULL) ? m_TradingSetupManager.FindByIdentity(sym) : NULL;
      if(row_setting==NULL && m_TradingSetupManager!=NULL)
         row_setting=m_TradingSetupManager.Add_TradingSetupSetting(sym);
      bool sl_fixed=(row_setting==NULL) || (row_setting.StopLostMode()==SL_MODE_FIXED);
      bool sl_active=(row_setting!=NULL) && row_setting.StopLostActive();
      bool trail_fixed=(row_setting==NULL) || (row_setting.TrailingMode()==SL_MODE_FIXED);
      bool trail_active=(row_setting!=NULL) && row_setting.TrailingActive();
      m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLTYPE,row,(long)(sl_fixed ? CANV_ELEMENT_CHECK_STATE_UNCHECKED : CANV_ELEMENT_CHECK_STATE_CHECKED));
      m_table_positions_StoplostAndTrailling.CellView(COL_PST_RUN_SL,row).ChangeImage(sl_active ? 0 : 1);
      m_table_positions_StoplostAndTrailling.SetValue(COL_PST_TRAILTYPE,row,(long)(trail_fixed ? CANV_ELEMENT_CHECK_STATE_UNCHECKED : CANV_ELEMENT_CHECK_STATE_CHECKED));
      m_table_positions_StoplostAndTrailling.CellView(COL_PST_RUN_TRAIL,row).ChangeImage(trail_active ? 0 : 1);
      //--- Real positions here: the SL they hold now, the money on their real volume
      bool sl_price_from_trail;
      double sl_price=(m_TradingEngine!=NULL) ? m_TradingEngine.GetPreviewSLTargetPrice(sym,type,sl_price_from_trail) : EMPTY_VALUE;
      double sl_profit=(sl_price!=EMPTY_VALUE) ? m_MarketCollection.SumFloatingProfit(sym,type,sl_price) : EMPTY_VALUE;
      if(sl_price==EMPTY_VALUE)
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPRICE,row,"N/A");
      else
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPRICE,row,sl_price);
      if(sl_profit==EMPTY_VALUE)
        {
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPROFIT,row,"N/A");
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_PROFIT,row,"N/A");
        }
      else
        {
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_SLPROFIT,row,sl_profit);
         m_table_positions_StoplostAndTrailling.SetValue(COL_PST_PROFIT,row,sl_profit);
        }
     }
   return m_table_positions_StoplostAndTrailling.Update(false);
  }
 //--- Stop loss / trailing type icon of a position row: the table already flipped the cell, the setting follows it
 void CGUIPannel::OnClickTogglePositionSLType(const int row)
  {
   if(m_TradingSetupManager==NULL)
      return;
   string sym=m_table_positions_StoplostAndTrailling.Cell(COL_PST_SYMBOL,row).Value();
   if(sym=="")
      return;
   CTradingSetupSetting *row_setting=m_TradingSetupManager.FindByIdentity(sym);
   if(row_setting==NULL) row_setting=m_TradingSetupManager.Add_TradingSetupSetting(sym);
   if(row_setting==NULL)
      return;
   bool fixed=(m_table_positions_StoplostAndTrailling.Cell(COL_PST_SLTYPE,row).ValueL()==CANV_ELEMENT_CHECK_STATE_UNCHECKED);
   row_setting.StopLostMode(fixed ? SL_MODE_FIXED : SL_MODE_INDICATOR);
   m_TradingSetupManager.NotifySettingChanged(sym);
   SyncTable_PositionsStoplostAndTrailling();
  }
 void CGUIPannel::OnClickTogglePositionTrailType(const int row)
  {
   if(m_TradingSetupManager==NULL)
      return;
   string sym=m_table_positions_StoplostAndTrailling.Cell(COL_PST_SYMBOL,row).Value();
   if(sym=="")
      return;
   CTradingSetupSetting *row_setting=m_TradingSetupManager.FindByIdentity(sym);
   if(row_setting==NULL) row_setting=m_TradingSetupManager.Add_TradingSetupSetting(sym);
   if(row_setting==NULL)
      return;
   bool fixed=(m_table_positions_StoplostAndTrailling.Cell(COL_PST_TRAILTYPE,row).ValueL()==CANV_ELEMENT_CHECK_STATE_UNCHECKED);
   row_setting.TrailingMode(fixed ? SL_MODE_FIXED : SL_MODE_INDICATOR);
   m_TradingSetupManager.NotifySettingChanged(sym);
   SyncTable_PositionsStoplostAndTrailling();
  }
 //--- "Trading" menu: flips StopLostActive / TrailingActive of the New Order Symbol
 void CGUIPannel::OnClickToggleSLOrTrailing(const bool is_sl)
  {
   if(m_TradingSetupManager==NULL)
      return;
   string symbol=GetNewOrderSymbol();
   if(symbol=="")
      return;
   CTradingSetupSetting *row_setting=m_TradingSetupManager.FindByIdentity(symbol);
   if(row_setting==NULL) row_setting=m_TradingSetupManager.Add_TradingSetupSetting(symbol);
   if(row_setting==NULL)
      return;
   if(is_sl)
      row_setting.StopLostActive(!row_setting.StopLostActive());
   else
      row_setting.TrailingActive(!row_setting.TrailingActive());
   m_TradingSetupManager.NotifySettingChanged(symbol);
   SyncRunSLTrailingButtonIcons(row_setting.StopLostActive(),row_setting.TrailingActive());
   SyncTable_PositionsStoplostAndTrailling();
   SyncTable_PositionPretradeView(true);
  }
 //--- Colored icon = on, gray = off; painted again only when the state changed
 void CGUIPannel::SyncRunSLTrailingButtonIcons(const bool sl_active,const bool trail_active)
  {
   static int s_sl_state=-1,s_trail_state=-1;   // -1 = never painted
   if((int)sl_active!=s_sl_state)
     {
      s_sl_state=(int)sl_active;
      CMenuItem *sl_item=m_contextmenu_trading.GetItemPointer(MENU_ITEM_TRADING_STOPLOST);
      if(sl_item!=NULL)
        {
         sl_item.IconFile(sl_active ? IMAGE_RESOURCE_BMP16_STOPLOSTRED_PNG : IMAGE_RESOURCE_BMP16_START_GRAY_BMP);
         sl_item.Draw(true);
        }
     }
   if((int)trail_active!=s_trail_state)
     {
      s_trail_state=(int)trail_active;
      CMenuItem *trail_item=m_contextmenu_trading.GetItemPointer(MENU_ITEM_TRADING_TRAILLING);
      if(trail_item!=NULL)
        {
         trail_item.IconFile(trail_active ? IMAGE_RESOURCE_BMP16_TRAILLING_PNG : IMAGE_RESOURCE_BMP16_START_GRAY_BMP);
         trail_item.Draw(true);
        }
     }
  }
 //--- The colored SL / Trailling cell of the monitor opens the Setting Trading window on its tab
 void CGUIPannel::OnClickOpenTradingSettingTab(const ENUM_TAB_SETTING_TRADING tab)
  {
   OpenWindow_SettingTrading();
   m_tabs_setting_trading.SelectTab(tab);
   HideStopLostForm();
   HideTrailingForm();
   ::ChartRedraw(m_ChartObj.GetChartID());
  }
#endif // CGUIPANNEL_MAINWINDOWS_TABTRADING_MQH
