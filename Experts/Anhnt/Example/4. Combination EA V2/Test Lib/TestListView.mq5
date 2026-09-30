//+------------------------------------------------------------------+
//|                                                 TestListView.mq5 |
//| Market Watch symbols list + checkbox-mode list inside a window   |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Window.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\ListView.mqh>

CWindow   m_window_main;
CListView m_list_symbols;
CListView m_list_check;
CButton   m_btn_add;
CButton   m_btn_delete;

int OnInit(void)
  {
   const long chart_id=::ChartID();
   m_window_main.IsMovable(true);
   m_window_main.CloseButtonIsUsed(true);
   if(!m_window_main.CreateWindow(chart_id,0,"LIST VIEW",60,40,330,260))
      return INIT_FAILED;

   int total=::SymbolsTotal(true);
   m_list_symbols.ListSize(total);
   for(int i=0; i<total; i++)
      m_list_symbols.SetValue(i,::SymbolName(i,true));
   m_list_symbols.LightsHover(true);
   m_window_main.AddChild(&m_list_symbols);
   if(!m_list_symbols.CreateListView(chart_id,0,"TestListSymbols",10,30,150,200))
      return INIT_FAILED;
   m_list_symbols.SelectItem(0,true);

   string tf[]={"M1","M5","M15","M30","H1","H4","D1"};
   m_list_check.ListSize(ArraySize(tf));
   for(int i=0; i<ArraySize(tf); i++)
      m_list_check.SetValue(i,tf[i]);
   m_list_check.CheckBoxMode(true);
   m_list_check.LightsHover(true);
   m_window_main.AddChild(&m_list_check);
   if(!m_list_check.CreateListView(chart_id,0,"TestListCheck",170,30,150,110))
      return INIT_FAILED;

   m_window_main.AddChild(&m_btn_add);
   m_btn_add.SetText("Add item");
   if(!m_btn_add.Create(chart_id,0,"TestListAdd",170,150,150,20))
      return INIT_FAILED;
   m_window_main.AddChild(&m_btn_delete);
   m_btn_delete.SetText("Delete selected");
   if(!m_btn_delete.Create(chart_id,0,"TestListDelete",170,175,150,20))
      return INIT_FAILED;
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
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_add.ObjectID())
      m_list_check.AddItem(WRONG_VALUE,"Item "+(string)m_list_check.ItemsTotal(),true);
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_delete.ObjectID())
      m_list_check.DeleteItem(m_list_check.SelectedItemIndex(),true);
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_LIST_ITEM)
     {
      bool state=(lparam==m_list_check.ObjectID() ? m_list_check.GetState((uint)dparam) : false);
      ::Print("MY DEBUG TestListView::OnChartEvent: list id=",lparam," index=",(int)dparam," text=",sparam," state=",state,
              " (symbols id=",m_list_symbols.ObjectID()," check id=",m_list_check.ObjectID(),")");
     }
  }
