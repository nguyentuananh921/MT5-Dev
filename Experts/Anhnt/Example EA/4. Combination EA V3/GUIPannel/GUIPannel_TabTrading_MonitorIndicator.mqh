//+------------------------------------------------------------------+
//|                         GUIPannel_TabTrading_MonitorIndicator.mqh |
//| Indicator tab of the monitor: every template of every tracked TF |
//| of the chart Symbol, what Python calculated                      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABTRADING_MONITORINDICATOR_MQH
#define CGUIPANNEL_TABTRADING_MONITORINDICATOR_MQH
#include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| TF | signal | indicator | value | SL | trailing                   |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_PreTradeSymbolMonitor(const int x,const int y)
  {
   for(int c=0;c<COLUMNS_PRETRADEMON_TOTAL;c++)
      m_table_indicator_PreTradeSymbolMonitor.View().GetHeaderViewPointer().TextAlign(c,PRETRADEMON_HEADER_ALIGN[c]);
   m_table_indicator_PreTradeSymbolMonitor.TableSize(COLUMNS_PRETRADEMON_TOTAL,0);
   m_table_indicator_PreTradeSymbolMonitor.View().ShowHeaders(true);
   m_table_indicator_PreTradeSymbolMonitor.View().SelectableRow(true);
   m_table_indicator_PreTradeSymbolMonitor.View().LightsHover(true);
   m_table_indicator_PreTradeSymbolMonitor.View().IsSortMode(false);
   //--- The table takes the width of the tab; its height is fixed
   m_table_indicator_PreTradeSymbolMonitor.AutoXResizeMode(true);
   m_table_indicator_PreTradeSymbolMonitor.AutoXResizeRightOffset(0);
   m_tabs_monitor.AddToElementsArray(TAB_MONITOR_INDICATOR,m_table_indicator_PreTradeSymbolMonitor);
   if(!m_table_indicator_PreTradeSymbolMonitor.CreateTable(this.m_chart_id,M_SUBWINDOW_MAIN,"TablePreTradeMonitor",x,y,
                                                           m_tabs_monitor.Width()-x,TRADING_FORM_HEIGHT))
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
   //--- The indicator the Stop Loss and the Trailing are set to (the same for every Symbol): its row has the icon in colour
   CTradingSetupSetting *setting=(m_TradingSetupManager!=NULL) ? m_TradingSetupManager.Setting() : NULL;
   MqlParam sl_params[],trail_params[];
   if(setting!=NULL)
     {
      setting.GetStopLostIndParams(sl_params);
      setting.GetTrailingIndParams(trail_params);
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
      MqlParam ind_params[];
      row_indicator[row].GetMqlParams(ind_params);
      bool is_sl=(setting!=NULL && setting.StopLostMode()==SL_MODE_INDICATOR && setting.StopLostIndType()==row_indicator[row].TypeIndicator() &&
                  setting.StopLostIndTF()==row_indicator[row].Timeframe() &&
                  ::ArraySize(sl_params)>0 && ::ArraySize(ind_params)>0 && sl_params[0].integer_value==ind_params[0].integer_value);   // the ATR: the period only, the saved parameter is an int whatever the template holds
      bool is_trail=(setting!=NULL && setting.TrailingMode()==SL_MODE_INDICATOR && setting.TrailingIndType()==row_indicator[row].TypeIndicator() &&
                     setting.TrailingIndTF()==row_indicator[row].Timeframe() && IsEqualMqlParamArrays(trail_params,ind_params));
      m_table_indicator_PreTradeSymbolMonitor.CellView(4,row).ChangeImage(is_sl ? 0 : 1);      // in colour: the Stop Loss is set to this indicator
      m_table_indicator_PreTradeSymbolMonitor.CellView(5,row).ChangeImage(is_trail ? 0 : 1);   // in colour: the Trailing is set to this indicator
     }
   return m_table_indicator_PreTradeSymbolMonitor.Update(false);
  }
#endif // CGUIPANNEL_TABTRADING_MONITORINDICATOR_MQH
