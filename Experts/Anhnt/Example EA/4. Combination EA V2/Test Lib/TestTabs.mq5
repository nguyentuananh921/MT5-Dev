//+------------------------------------------------------------------+
//|                                                     TestTabs.mq5 |
//| Five tabs (header overflows), each tab shows only its controls   |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Window.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Tabs.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\CheckBox.mqh>

CWindow       m_window_main;
CTabs         m_tabs_main;
CButton       m_btn_buy;
CCheckBox     m_check_sl;
CLabel        m_label_symbol;
CButtonsGroup m_group_tf;
CLabel        m_label_history;
CLabel        m_label_setting;

int OnInit(void)
  {
   const long chart_id=::ChartID();
   m_window_main.IsMovable(true);
   m_window_main.ResizeMode(true);
   m_window_main.CloseButtonIsUsed(true);
   m_window_main.CollapseButtonIsUsed(true);
   m_window_main.FullscreenButtonIsUsed(true);
   if(!m_window_main.CreateWindow(chart_id,0,"EXPERT PANEL V2",60,40,380,220))
      return INIT_FAILED;

   string tabs_names[]={"Account infor","Symbol Info","Trading","History","Setting"};
   for(int i=0; i<ArraySize(tabs_names); i++)
      m_tabs_main.AddTab(tabs_names[i],100);
   m_tabs_main.AutoXResizeMode(true);
   m_tabs_main.AutoYResizeMode(true);
   m_tabs_main.AutoXResizeRightOffset(3);
   m_tabs_main.AutoYResizeBottomOffset(3);
   m_window_main.AddChild(&m_tabs_main);
   if(!m_tabs_main.CreateTabs(chart_id,0,"TestTabsMain",3,48))
      return INIT_FAILED;

   m_tabs_main.AddToElementsArray(0,m_btn_buy);
   m_tabs_main.AddToElementsArray(0,m_check_sl);
   m_btn_buy.SetText("Buy");
   m_check_sl.SetText("Use StopLost");
   if(!m_btn_buy.Create(chart_id,0,"TestBtnBuy",10,10,80,20))
      return INIT_FAILED;
   if(!m_check_sl.Create(chart_id,0,"TestCheckSL",10,40,150,20))
      return INIT_FAILED;

   m_tabs_main.AddToElementsArray(1,m_label_symbol);
   m_label_symbol.SetText("Symbol: "+::Symbol());
   if(!m_label_symbol.Create(chart_id,0,"TestLabelSymbol",10,10,200,20))
      return INIT_FAILED;

   string tf[]={"M1","M5","M15","H1","D1"};
   for(int i=0; i<ArraySize(tf); i++)
      m_group_tf.AddButton(i*49,0,tf[i],50);
   m_group_tf.RadioButtonsMode(true);
   m_tabs_main.AddToElementsArray(2,m_group_tf);
   if(!m_group_tf.CreateButtonsGroup(chart_id,0,"TestTabGroupTF",10,10))
      return INIT_FAILED;

   m_tabs_main.AddToElementsArray(3,m_label_history);
   m_label_history.SetText("History tab content");
   if(!m_label_history.Create(chart_id,0,"TestLabelHistory",10,10,200,20))
      return INIT_FAILED;

   m_tabs_main.AddToElementsArray(4,m_label_setting);
   m_label_setting.SetText("Setting tab content");
   if(!m_label_setting.Create(chart_id,0,"TestLabelSetting",10,10,200,20))
      return INIT_FAILED;

   m_tabs_main.SelectTab(0);
   ::ChartRedraw(chart_id);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
  }

void OnTick(void)
  {
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   m_window_main.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_TAB || id==CHARTEVENT_CUSTOM+ON_CLICK_GROUP_BUTTON ||
      id==CHARTEVENT_CUSTOM+ON_WINDOW_CHANGE_XSIZE || id==CHARTEVENT_CUSTOM+ON_WINDOW_CHANGE_YSIZE)
      ::Print("MY DEBUG TestTabs::OnChartEvent: event=",id-CHARTEVENT_CUSTOM," id=",lparam," index=",(int)dparam," text=",sparam);
  }
