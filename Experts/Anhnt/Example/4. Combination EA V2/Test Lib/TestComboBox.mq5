//+------------------------------------------------------------------+
//|                                                 TestComboBox.mq5 |
//| Open list blocks the controls under it via the parent CWindow    |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Window.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\ComboBox.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\CheckBox.mqh>

CWindow   m_window_main;
CComboBox m_combo_symbol;
CButton   m_btn_under;
CCheckBox m_check_under;
CComboBox m_combo_tf;

int OnInit(void)
  {
   const long chart_id=::ChartID();
   m_window_main.IsMovable(true);
   m_window_main.CloseButtonIsUsed(true);
   if(!m_window_main.CreateWindow(chart_id,0,"COMBO BOX",60,40,300,220))
      return INIT_FAILED;

   int total=::SymbolsTotal(true);
   m_combo_symbol.ItemsTotal(total);
   for(int i=0; i<total; i++)
      m_combo_symbol.SetValue(i,::SymbolName(i,true));
   m_combo_symbol.GetListViewPointer().LightsHover(true);
   m_combo_symbol.SetText("Symbol:");
   m_window_main.AddChild(&m_combo_symbol);
   if(!m_combo_symbol.CreateComboBox(chart_id,0,"TestComboSymbol",10,30,280,20,120,150))
      return INIT_FAILED;
   m_combo_symbol.SelectItem(0);

   m_window_main.AddChild(&m_btn_under);
   m_btn_under.SetText("Under list");
   if(!m_btn_under.Create(chart_id,0,"TestComboUnder",170,70,120,20))
      return INIT_FAILED;
   m_window_main.AddChild(&m_check_under);
   m_check_under.SetText("Under list too");
   if(!m_check_under.Create(chart_id,0,"TestComboCheckUnder",170,100,120,20))
      return INIT_FAILED;

   string tf[]={"M1","M5","M15","M30","H1","H4","D1"};
   m_combo_tf.ItemsTotal(ArraySize(tf));
   for(int i=0; i<ArraySize(tf); i++)
      m_combo_tf.SetValue(i,tf[i]);
   m_combo_tf.GetListViewPointer().LightsHover(true);
   m_combo_tf.CheckBoxMode(true);
   m_combo_tf.SetText("Timeframe");
   m_window_main.AddChild(&m_combo_tf);
   if(!m_combo_tf.CreateComboBox(chart_id,0,"TestComboTF",10,130,280))
      return INIT_FAILED;
   m_combo_tf.SelectItem(4);
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
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_COMBOBOX_ITEM || id==CHARTEVENT_CUSTOM+ON_CLICK_COMBOBOX_BUTTON ||
      id==CHARTEVENT_CUSTOM+ON_SET_AVAILABLE || id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX ||
      (id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_under.ObjectID()))
      ::Print("MY DEBUG TestComboBox::OnChartEvent: event=",id-CHARTEVENT_CUSTOM," id=",lparam," dparam=",dparam," sparam=",sparam,
              " (symbol id=",m_combo_symbol.ObjectID()," tf id=",m_combo_tf.ObjectID()," under id=",m_btn_under.ObjectID(),
              " under available=",m_btn_under.IsAvailable(),")");
  }
