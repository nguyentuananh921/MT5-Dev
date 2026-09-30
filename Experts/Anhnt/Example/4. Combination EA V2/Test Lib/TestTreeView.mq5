//+------------------------------------------------------------------+
//|                                                 TestTreeView.mq5 |
//| Symbol -> TF tree, items added/deleted after the tree is built   |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Window.mqh>
#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\TreeView.mqh>

CWindow   m_window_main;
CTreeView m_treeview;
CButton   m_btn_add_tf;
CButton   m_btn_delete;
string    g_tf[]={"M1","M5","M15","M30","H1","H4","D1"};

int OnInit(void)
  {
   const long chart_id=::ChartID();
   m_window_main.IsMovable(true);
   m_window_main.CloseButtonIsUsed(true);
   if(!m_window_main.CreateWindow(chart_id,0,"TREE VIEW",60,40,330,300))
      return INIT_FAILED;

   int total=::SymbolsTotal(true);
   for(int i=0; i<total; i++)
     {
      string symbol=::SymbolName(i,true);
      long sym_id=m_treeview.AddTreeItem(WRONG_VALUE,symbol);
      m_treeview.AddTreeItem(sym_id,"M1",IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP);
      m_treeview.AddTreeItem(sym_id,"H1",IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP);
      if(symbol==::Symbol())
        {
         m_treeview.ItemPointer(sym_id).IsActive(true);
         m_treeview.ItemState(sym_id,true);
        }
     }
   m_treeview.LightsHover(true);
   m_window_main.AddChild(&m_treeview);
   if(!m_treeview.CreateTreeView(chart_id,0,"TestTree",10,30,180,260))
      return INIT_FAILED;

   m_window_main.AddChild(&m_btn_add_tf);
   m_btn_add_tf.SetText("Add TF");
   if(!m_btn_add_tf.Create(chart_id,0,"TestTreeAddTF",200,30,120,20))
      return INIT_FAILED;
   m_window_main.AddChild(&m_btn_delete);
   m_btn_delete.SetText("Delete selected");
   if(!m_btn_delete.Create(chart_id,0,"TestTreeDelete",200,55,120,20))
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

void AddMissingTF(void)
  {
   CTreeItem *item=m_treeview.ItemPointer(m_treeview.SelectedItemId());
   if(item==NULL)
      return;
   if(item.NodeLevel()>0)
      item=item.ParentItem();
   for(int i=0; i<ArraySize(g_tf); i++)
     {
      if(m_treeview.FindItem(item.ObjectID(),g_tf[i])!=NULL)
         continue;
      long id=m_treeview.AddTreeItem(item.ObjectID(),g_tf[i],IMAGE_RESOURCE_BMP16_BAR_CHART_BMP);
      m_treeview.ItemState(item.ObjectID(),true);
      m_treeview.SelectTreeItem(id,true);
      return;
     }
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   m_window_main.OnChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_add_tf.ObjectID())
      AddMissingTF();
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_btn_delete.ObjectID())
      m_treeview.DeleteTreeItem(m_treeview.SelectedItemId(),true);
   if(id==CHARTEVENT_CUSTOM+ON_CHANGE_TREE_PATH)
     {
      CTreeItem *item=m_treeview.ItemPointer((long)dparam);
      ::Print("MY DEBUG TestTreeView::OnChartEvent: tree id=",lparam," item id=",(long)dparam," text=",sparam,
              " level=",(item!=NULL ? item.NodeLevel() : -2)," children=",(item!=NULL ? item.ChildrenTotal() : -1));
     }
  }
