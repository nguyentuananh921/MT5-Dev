//+------------------------------------------------------------------+
//|                    GUIPannel_SettingWindows_TS_CandlePattern.mqh |
//| Candle Pattern tab: Buy/Sell/Sound/Message per CPatternSetting   |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_TS_CANDLE_PATTERN_MQH
#define CGUIPANNEL_SETTINGWINDOWS_TS_CANDLE_PATTERN_MQH
 #include "GUIPannel.mqh"
 #define SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP 20
 #define COLUMNS_CANDLE_PATTERN_TOTAL          8
 //--- 8 columns: Pattern, No, Buy, Sell, up-arrow legend, Sound, Message, down-arrow legend
 bool CGUIPannel::CreateTable_CandlePatternSetting(const int x,const int y)
  {
   m_btn_save_pattern_config.SetText("Save");
   m_btn_save_pattern_config.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_CANDLE_PATTERN,m_btn_save_pattern_config);
   if(!m_btn_save_pattern_config.Create(m_chart_id,m_subwin,"BtnSavePattern",x+M_CONTROL_BORDER_GAP,
                                        y+SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP,80,M_CONTROL_HEIGHT))
      return false;
   int table_y=y+SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP+M_CONTROL_HEIGHT+SETTING_BTN_SAVE_CANDLE_PATTERN_Y_GAP;
   m_table_CandlePatternsSetting.TableSize(COLUMNS_CANDLE_PATTERN_TOTAL,0);
   m_table_CandlePatternsSetting.View().ShowHeaders(true);
   m_table_CandlePatternsSetting.View().SelectableRow(true);
   m_table_CandlePatternsSetting.View().LightsHover(true);
   m_table_CandlePatternsSetting.View().IsSortMode(true);
   m_table_CandlePatternsSetting.AutoXResizeMode(true);
   m_table_CandlePatternsSetting.AutoXResizeRightOffset(3);
   m_table_CandlePatternsSetting.AutoYResizeMode(true);
   m_table_CandlePatternsSetting.AutoYResizeBottomOffset(3);
   m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_CANDLE_PATTERN,m_table_CandlePatternsSetting);
   if(!m_table_CandlePatternsSetting.CreateTable(m_chart_id,m_subwin,"TableCandlePattern",x,table_y))
      return false;
   int widths[COLUMNS_CANDLE_PATTERN_TOTAL]            ={155,30,M_ICON16_WIDTH,M_ICON16_WIDTH,M_ICON16_WIDTH,M_ICON16_WIDTH,M_ICON16_WIDTH,M_ICON16_WIDTH};
   int image_x[COLUMNS_CANDLE_PATTERN_TOTAL]           ={0,0,2,2,2,2,2,2};
   ENUM_ALIGN_MODE align[COLUMNS_CANDLE_PATTERN_TOTAL] ={ALIGN_LEFT,ALIGN_CENTER,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT};
   CTableHeaderView *header=m_table_CandlePatternsSetting.View().GetHeaderViewPointer();
   header.ColumnsWidth(widths);
   header.TextAlign(align);
   header.ImageXOffset(image_x);
   m_table_CandlePatternsSetting.View().IsFilterMode(1,true);
   m_table_CandlePatternsSetting.SetHeaderText(0,"Pattern");
   m_table_CandlePatternsSetting.SetHeaderText(1,"No");
   uint img_buy[]    ={IMAGE_RESOURCE_BMP16_SIGNAL_BUY_PNG};
   uint img_sell[]   ={IMAGE_RESOURCE_BMP16_SIGNAL_SELL_PNG};
   uint img_sound[]  ={IMAGE_RESOURCE_BMP16_BELL_PNG};
   uint img_message[]={IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
   m_table_CandlePatternsSetting.SetHeaderText(2,"");  m_table_CandlePatternsSetting.SetHeaderImage(2,img_buy);
   m_table_CandlePatternsSetting.SetHeaderText(3,"");  m_table_CandlePatternsSetting.SetHeaderImage(3,img_sell);
   m_table_CandlePatternsSetting.SetHeaderText(4,"");
   m_table_CandlePatternsSetting.SetHeaderText(5,"");  m_table_CandlePatternsSetting.SetHeaderImage(5,img_sound);
   m_table_CandlePatternsSetting.SetHeaderText(6,"");  m_table_CandlePatternsSetting.SetHeaderImage(6,img_message);
   m_table_CandlePatternsSetting.SetHeaderText(7,"");
   m_table_CandlePatternsSetting.View().Rebuild(false);
   return true;
  }
 //--- Rows mirror CPatternManager; the pattern names and counts come from Python, so the table fills again when its catalog arrives
 void CGUIPannel::InitializeTable_CandlePatternSetting(void)
  {
   if(m_PatternManager==NULL)
      return;
   int n=m_PatternManager.Total();
   m_table_CandlePatternsSetting.DeleteAllRows();
   for(int i=0;i<n;i++)
      m_table_CandlePatternsSetting.AddRow();
   uint arrow_up[]={IMAGE_RESOURCE_BMP16_ARROW_UP_PNG};
   uint arrow_dn[]={IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG};
   for(int i=0;i<n;i++)
     {
      CPatternSetting *c=m_PatternManager.At(i);
      if(c==NULL)
         continue;
      m_table_CandlePatternsSetting.SetValue(0,i,c.Name());
      m_table_CandlePatternsSetting.SetValue(1,i,(c.Candles()>0) ? (string)c.Candles() : "");
      bool flags[4];
      flags[0]=c.BuySignal();
      flags[1]=c.SellSignal();
      flags[2]=c.SoundAlert();
      flags[3]=c.MessageAlert();
      bool has_side=(c.HasBuy() || c.HasSell());   // Inside Bar has none: no marker, so no alert to set
      bool possible[4]={c.HasBuy(),c.HasSell(),has_side,has_side};
      uint box_locked[]={IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG};
      int check_cols[4]={2,3,5,6};
      for(int k=0;k<4;k++)
        {
         //--- A side the pattern never has: only the grey box, no check box to tick
         if(!possible[k])
           {
            m_table_CandlePatternsSetting.CellView(check_cols[k],i).SetImages(box_locked);
            continue;
           }
         m_table_CandlePatternsSetting.CellView(check_cols[k],i).CellType(CELL_CHECKBOX);
         m_table_CandlePatternsSetting.SetValue(check_cols[k],i,(long)(flags[k] ? CANV_ELEMENT_CHEK_STATE_CHECKED : CANV_ELEMENT_CHEK_STATE_UNCHECKED));
        }
      m_table_CandlePatternsSetting.CellView(4,i).SetImages(arrow_up);
      m_table_CandlePatternsSetting.CellView(7,i).SetImages(arrow_dn);
     }
   m_table_CandlePatternsSetting.View().Rebuild(true);
  }
 //--- 'on' is the new checkbox state sent with the event (dparam); a header sort moves the rows, so the pattern is found by its name
 void CGUIPannel::OnCheckTableCandlePatternSetting(const int row,const int col,const bool on)
  {
   if(m_PatternManager==NULL)
      return;
   CTableCell *cell=m_table_CandlePatternsSetting.Cell(0,row);
   CPatternSetting *c=(cell!=NULL) ? m_PatternManager.Find(cell.ValueS()) : NULL;
   if(c==NULL)
      return;
   bool has_side=(c.HasBuy() || c.HasSell());
   if(col==2 && c.HasBuy())
      c.BuySignal(on);
   else if(col==3 && c.HasSell())
      c.SellSignal(on);
   else if(col==5 && has_side)
      c.SoundAlert(on);
   else if(col==6 && has_side)
      c.MessageAlert(on);
  }
 //+------------------------------------------------------------------+
 //| What the user (or the manager) did that this tab shows           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_CandlePattern(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- m_table_CandlePatternsSetting: cols 2,3,5,6 = checkboxes, dparam = the new state
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX && lparam==m_table_CandlePatternsSetting.ObjectID())
     {
      int col,row;
      if(!m_table_CandlePatternsSetting.CellIndexes(sparam,col,row))
         return;
      if(row<0 || row>=(int)m_table_CandlePatternsSetting.Model().RowsTotal())
         return;
      OnCheckTableCandlePatternSetting(row,col,dparam!=0);
      return;
     }
   //--- Python sent its pattern catalog: names, order and candle counts
   if(id==CHARTEVENT_CUSTOM+PATTERN_MANAGER_EVENT_CATALOG_CHANGED)
     {
      if(!m_gui_created)
         return;
      InitializeTable_CandlePatternSetting();
      ::ChartRedraw(m_chart_id);
      return;
     }
  }
#endif // CGUIPANNEL_SETTINGWINDOWS_TS_CANDLE_PATTERN_MQH
