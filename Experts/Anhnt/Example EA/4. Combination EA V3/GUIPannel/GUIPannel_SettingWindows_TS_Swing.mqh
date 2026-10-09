//+------------------------------------------------------------------+
//|                            GUIPannel_SettingWindows_TS_Swing.mqh |
//| Smart Money tab: Strength/Wick controls + Show/Sound/Message     |
//| table, every value lives in m_SmartMoneySetting (EA owns)        |
//+------------------------------------------------------------------+
#ifndef __GUIPANNEL_SETTINGWINDOWS_TS_SWING_MQH__
#define __GUIPANNEL_SETTINGWINDOWS_TS_SWING_MQH__
 #define SETTING_BTN_SAVE_SWING_Y_GAP 20
 #define COLUMNS_SWING_TOTAL          4
 #include "GUIPannel.mqh"
//--- 4 columns: Type / Show / Sound / Message, 4 fixed rows (Swing High, Swing Low, BOS, CHoCH), row == index
bool CGUIPannel::CreateTable_SmartMoneySetting(const int x,const int y)
 {
  m_btn_save_swing_config.SetText("Save");
  m_btn_save_swing_config.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
  m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SMART_MONEY_CONCEPTS,m_btn_save_swing_config);
  if(!m_btn_save_swing_config.Create(m_chart_id,m_subwin,"BtnSaveSwing",x+M_CONTROL_BORDER_GAP,
                                     y+SETTING_BTN_SAVE_SWING_Y_GAP,80,M_CONTROL_HEIGHT))
     return false;
  if(!this.CreateSwingParamControls(x+M_CONTROL_BORDER_GAP+80+20,y+SETTING_BTN_SAVE_SWING_Y_GAP))
     return false;
  int table_y=y+SETTING_BTN_SAVE_SWING_Y_GAP+M_CONTROL_HEIGHT+SETTING_BTN_SAVE_SWING_Y_GAP;
  m_table_SmartMoneySetting.TableSize(COLUMNS_SWING_TOTAL,0);
  m_table_SmartMoneySetting.View().ShowHeaders(true);
  m_table_SmartMoneySetting.View().SelectableRow(true);
  m_table_SmartMoneySetting.View().LightsHover(true);
  m_table_SmartMoneySetting.View().IsSortMode(false);
  m_table_SmartMoneySetting.AutoXResizeMode(true);
  m_table_SmartMoneySetting.AutoXResizeRightOffset(3);
  m_table_SmartMoneySetting.AutoYResizeMode(true);
  m_table_SmartMoneySetting.AutoYResizeBottomOffset(3);
  m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SMART_MONEY_CONCEPTS,m_table_SmartMoneySetting);
  if(!m_table_SmartMoneySetting.CreateTable(m_chart_id,m_subwin,"TableSwing",x,table_y))
     return false;
  int widths[COLUMNS_SWING_TOTAL]            ={155,M_ICON16_WIDTH,M_ICON16_WIDTH,M_ICON16_WIDTH};
  int image_x[COLUMNS_SWING_TOTAL]           ={0,2,2,2};
  ENUM_ALIGN_MODE align[COLUMNS_SWING_TOTAL] ={ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT};
  CTableHeaderView *header=m_table_SmartMoneySetting.View().GetHeaderViewPointer();
  header.ColumnsWidth(widths);
  header.TextAlign(align);
  header.ImageXOffset(image_x);
  m_table_SmartMoneySetting.SetHeaderText(0,"Smart Money");
  uint img_show[]   ={IMAGE_RESOURCE_BMP16_SIGNAL_PNG};
  uint img_sound[]  ={IMAGE_RESOURCE_BMP16_BELL_PNG};
  uint img_message[]={IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
  m_table_SmartMoneySetting.SetHeaderText(1,"");  m_table_SmartMoneySetting.SetHeaderImage(1,img_show);
  m_table_SmartMoneySetting.SetHeaderText(2,"");  m_table_SmartMoneySetting.SetHeaderImage(2,img_sound);
  m_table_SmartMoneySetting.SetHeaderText(3,"");  m_table_SmartMoneySetting.SetHeaderImage(3,img_message);
  m_table_SmartMoneySetting.View().Rebuild(false);
  return true;
 }
void CGUIPannel::InitializeTable_SmartMoneySetting(void)
 {
  m_table_SmartMoneySetting.DeleteAllRows();
  ENUM_SWING_TYPE types[2]={SWING_TYPE_HIGH,SWING_TYPE_LOW};
  ENUM_MARKET_STRUCTURE_TYPE structures[2]={MARKET_STRUCTURE_BOS,MARKET_STRUCTURE_CHOCH};
  for(int i=0;i<4;i++)
     m_table_SmartMoneySetting.AddRow();
  for(int i=0;i<4;i++)
    {
     bool flags[3];
     flags[0]=flags[1]=flags[2]=false;
     if(m_SmartMoneySetting!=NULL)
       {
        flags[0]=(i<2) ? m_SmartMoneySetting.SignalShow(types[i])   : m_SmartMoneySetting.SignalShow(structures[i-2]);
        flags[1]=(i<2) ? m_SmartMoneySetting.SoundAlert(types[i])   : m_SmartMoneySetting.SoundAlert(structures[i-2]);
        flags[2]=(i<2) ? m_SmartMoneySetting.MessageAlert(types[i]) : m_SmartMoneySetting.MessageAlert(structures[i-2]);
       }
     m_table_SmartMoneySetting.SetValue(0,i,(i<2) ? SwingTypeDescription(types[i]) : MarketStructureTypeDescription(structures[i-2]));
     for(int c=0;c<3;c++)
       {
        m_table_SmartMoneySetting.CellView(c+1,i).CellType(CELL_CHECKBOX);
        m_table_SmartMoneySetting.SetValue(c+1,i,(long)(flags[c] ? CANV_ELEMENT_CHEK_STATE_CHECKED : CANV_ELEMENT_CHEK_STATE_UNCHECKED));
       }
    }
  m_table_SmartMoneySetting.View().Rebuild(true);
 }
//--- 'on' is the new checkbox state sent with the event (dparam); Show changes the markers, so the EA is told.
//--- Sound is stored but not wired yet for BOS / CHoCH
void CGUIPannel::OnCheckTableSmartMoneySetting(const int row,const int col,const bool on)
 {
  if(m_SmartMoneySetting==NULL || row<0 || row>3)
     return;
  ENUM_SWING_TYPE type=(row==0) ? SWING_TYPE_HIGH : SWING_TYPE_LOW;
  ENUM_MARKET_STRUCTURE_TYPE structure=(row==2) ? MARKET_STRUCTURE_BOS : MARKET_STRUCTURE_CHOCH;
  if(col==1)
    {
     bool changed=(row<2) ? m_SmartMoneySetting.SignalShow(type,on) : m_SmartMoneySetting.SignalShow(structure,on);
     if(changed)
        ::EventChartCustom(::ChartID(),(ushort)GUIPANNEL_EVENT_SMARTMONEY_SETTING_CHANGED,0,0.0,"");
    }
  else if(col==2)
    {
     if(row<2) m_SmartMoneySetting.SoundAlert(type,on); else m_SmartMoneySetting.SoundAlert(structure,on);
    }
  else if(col==3)
    {
     if(row<2) m_SmartMoneySetting.MessageAlert(type,on); else m_SmartMoneySetting.MessageAlert(structure,on);
    }
 }
//--- Strength spin-edit (caption built in) + Use Wick checkbox on the Save button's row
bool CGUIPannel::CreateSwingParamControls(const int x,const int y)
 {
  int  strength=(m_SmartMoneySetting!=NULL) ? m_SmartMoneySetting.Strength() : 5;
  bool use_wick=(m_SmartMoneySetting==NULL) || (m_SmartMoneySetting.PriceBasis()==SWING_PRICE_BASIS_WICK);
  m_edit_swing_strength.SetText("Strength");
  m_edit_swing_strength.SpinEditMode(true);
  m_edit_swing_strength.MinValue(1);
  m_edit_swing_strength.MaxValue(50);
  m_edit_swing_strength.StepValue(1);
  m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SMART_MONEY_CONCEPTS,m_edit_swing_strength);
  if(!m_edit_swing_strength.CreateTextEdit(m_chart_id,m_subwin,"EditSwingStrength",x,y,120,M_CONTROL_HEIGHT,60))
     return false;
  m_edit_swing_strength.SetValue((string)strength);
  m_checkbox_swing_wick.SetText("Use Wick");
  m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SMART_MONEY_CONCEPTS,m_checkbox_swing_wick);
  if(!m_checkbox_swing_wick.Create(m_chart_id,m_subwin,"CheckSwingWick",x+120+15,y,M_SYMBOL_WITHICON_WIDTH,M_CONTROL_HEIGHT))
     return false;
  m_checkbox_swing_wick.SetState(use_wick);
  return true;
 }
//--- The strength and the price basis go into the setting; Python recalculates when the EA hears the event
void CGUIPannel::OnChangeSwingParams(void)
 {
  if(m_SmartMoneySetting==NULL)
     return;
  int n=(int)::StringToInteger(m_edit_swing_strength.GetValue());
  if(n<1)
    {
     n=1;
     m_edit_swing_strength.SetValue("1");
    }
  ENUM_SWING_PRICE_BASIS basis=(m_checkbox_swing_wick.State() ? SWING_PRICE_BASIS_WICK : SWING_PRICE_BASIS_BODY);
  bool changed=m_SmartMoneySetting.Strength(n);
  if(m_SmartMoneySetting.PriceBasis(basis))
     changed=true;
  if(changed)
     ::EventChartCustom(::ChartID(),(ushort)GUIPANNEL_EVENT_SMARTMONEY_SETTING_CHANGED,0,0.0,"");
 }
//+------------------------------------------------------------------+
//| What the user did that this tab shows                            |
//+------------------------------------------------------------------+
void CGUIPannel::OnEvent_Tab_SmartMoney(const int id,const long &lparam,const double &dparam,const string &sparam)
 {
  if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX && lparam==m_table_SmartMoneySetting.ObjectID())
    {
     int col,row;
     if(!m_table_SmartMoneySetting.CellIndexes(sparam,col,row))
        return;
     if(col>=1 && col<=3)
        this.OnCheckTableSmartMoneySetting(row,col,dparam!=0);
     return;
    }
  //--- Swing Strength spin-edit (Enter or +/-) and Wick checkbox apply live
  if((id==CHARTEVENT_CUSTOM+ON_END_EDIT || id==CHARTEVENT_CUSTOM+ON_CLICK_INC || id==CHARTEVENT_CUSTOM+ON_CLICK_DEC)
     && lparam==m_edit_swing_strength.ObjectID())
    {
     this.OnChangeSwingParams();
     return;
    }
  if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX && lparam==m_checkbox_swing_wick.ObjectID())
    {
     this.OnChangeSwingParams();
     return;
    }
 }
#endif // __GUIPANNEL_SETTINGWINDOWS_TS_SWING_MQH__
