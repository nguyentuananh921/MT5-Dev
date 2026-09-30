//+------------------------------------------------------------------+
//|                                                     TestMenu.mq5 |
//| Menu bar with 2-level context menus, status bar following resize |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Window.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Menu\MenuBar.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Menu\ContextMenu.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\StatusBar.mqh>

CWindow      m_window_main;
CMenuBar     m_menu_bar;
CContextMenu m_contextmenu_file;
CContextMenu m_contextmenu_recent;
CContextMenu m_contextmenu_settings;
CContextMenu m_contextmenu_view;
CButton      m_btn_under;
CStatusBar   m_status_bar;

int OnInit(void)
  {
   const long chart_id=::ChartID();
   m_window_main.IsMovable(true);
   m_window_main.ResizeMode(true);
   m_window_main.CloseButtonIsUsed(true);
   if(!m_window_main.CreateWindow(chart_id,0,"MENU",60,40,400,250))
      return INIT_FAILED;

   m_menu_bar.AddItem(50,"File");
   m_menu_bar.AddItem(80,"Settings");
   m_menu_bar.AddItem(50,"View");
   m_menu_bar.AddItem(50,"Help");
   m_window_main.AddChild(&m_menu_bar);
   if(!m_menu_bar.CreateMenuBar(chart_id,0,"TestMenuBar",1,WINDOW_CAPTION_HEIGHT,398))
      return INIT_FAILED;
   CMenuItem *settings_item=m_menu_bar.GetItemPointer(1);
   settings_item.IconFile(IMAGE_RESOURCE_BMP16_SETTING_PNG);
   settings_item.LabelXGap(22);
   settings_item.Draw(false);

   m_contextmenu_file.FixSide(FIX_BOTTOM);
   m_contextmenu_file.AddItem("New",(uint)INT_MAX,(uint)INT_MAX,MI_SIMPLE);
   m_contextmenu_file.AddItem("Open",(uint)INT_MAX,(uint)INT_MAX,MI_SIMPLE);
   m_contextmenu_file.AddItem("Recent",(uint)INT_MAX,(uint)INT_MAX,MI_HAS_CONTEXT_MENU);
   m_contextmenu_file.AddItem("Exit",(uint)INT_MAX,(uint)INT_MAX,MI_SIMPLE);
   m_contextmenu_file.AddSeparateLine(1);
   m_contextmenu_file.AddSeparateLine(2);
   m_menu_bar.GetItemPointer(0).AddChild(&m_contextmenu_file);
   if(!m_contextmenu_file.CreateContextMenu(chart_id,0,"TestMenuFile",120))
      return INIT_FAILED;

   m_contextmenu_recent.AddItem("XAUUSD.set",(uint)INT_MAX,(uint)INT_MAX,MI_SIMPLE);
   m_contextmenu_recent.AddItem("BTCUSD.set",(uint)INT_MAX,(uint)INT_MAX,MI_SIMPLE);
   m_contextmenu_file.GetItemPointer(2).AddChild(&m_contextmenu_recent);
   if(!m_contextmenu_recent.CreateContextMenu(chart_id,0,"TestMenuRecent",110))
      return INIT_FAILED;

   m_contextmenu_settings.FixSide(FIX_BOTTOM);
   m_contextmenu_settings.AddItem("TimeSeries",IMAGE_RESOURCE_BMP16_INDICATOR_ON_PNG,IMAGE_RESOURCE_BMP16_INDICATOR_OFF_PNG,MI_SIMPLE);
   m_contextmenu_settings.AddItem("Trading",IMAGE_RESOURCE_BMP16_TRADE_ON_PNG,IMAGE_RESOURCE_BMP16_TRADING_OFF_PNG,MI_SIMPLE);
   m_contextmenu_settings.AddItem("Alert",IMAGE_RESOURCE_BMP16_ALERT_ON_PNG,IMAGE_RESOURCE_BMP16_ALERT_OFF_PNG,MI_SIMPLE);
   settings_item.AddChild(&m_contextmenu_settings);
   if(!m_contextmenu_settings.CreateContextMenu(chart_id,0,"TestMenuSettings",110))
      return INIT_FAILED;

   m_contextmenu_view.FixSide(FIX_BOTTOM);
   m_contextmenu_view.AddItem("Show markers",(uint)INT_MAX,(uint)INT_MAX,MI_CHECKBOX);
   m_contextmenu_view.AddItem("Show bubble",(uint)INT_MAX,(uint)INT_MAX,MI_CHECKBOX);
   m_menu_bar.GetItemPointer(2).AddChild(&m_contextmenu_view);
   if(!m_contextmenu_view.CreateContextMenu(chart_id,0,"TestMenuView",120))
      return INIT_FAILED;

   m_window_main.AddChild(&m_btn_under);
   m_btn_under.SetText("Under the menus");
   if(!m_btn_under.Create(chart_id,0,"TestMenuUnder",10,60,150,20))
      return INIT_FAILED;

   m_status_bar.AddItem("For Help, press F1",0);
   m_status_bar.AddItem("",160);
   m_status_bar.AddItem("",60);
   m_window_main.AddChild(&m_status_bar);
   if(!m_status_bar.CreateStatusBar(chart_id,0,"TestStatusBar",1,250-23,398))
      return INIT_FAILED;
   m_status_bar.SetValue(2,::Symbol());

   ::EventSetMillisecondTimer(TIMER_STEP_MSC);
   ::ChartRedraw(chart_id);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   ::EventKillTimer();
  }

void OnTick(void)
  {
  }

void OnTimer(void)
  {
   m_window_main.OnTimerEvent();
   static datetime last=0;
   datetime now=::TimeTradeServer();
   if(now==last)
      return;
   last=now;
   m_status_bar.SetValue(1,::TimeToString(now,TIME_DATE|TIME_SECONDS));
   ::ChartRedraw();
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   m_window_main.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CONTEXTMENU_ITEM || id==CHARTEVENT_CUSTOM+ON_CLICK_MENU_ITEM ||
      id==CHARTEVENT_CUSTOM+ON_SET_AVAILABLE || (id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_under.ObjectID()))
     {
      string state="";
      if(lparam==m_contextmenu_view.ObjectID())
         state=" checked="+(string)m_contextmenu_view.GetItemPointer((uint)dparam).CheckBoxState();
      ::Print("MY DEBUG TestMenu::OnChartEvent: event=",id-CHARTEVENT_CUSTOM," id=",lparam," index=",(int)dparam," text=",sparam,state,
              " (bar=",m_menu_bar.ObjectID()," file=",m_contextmenu_file.ObjectID()," recent=",m_contextmenu_recent.ObjectID(),
              " settings=",m_contextmenu_settings.ObjectID()," view=",m_contextmenu_view.ObjectID(),
              " under available=",m_btn_under.IsAvailable(),")");
     }
  }
