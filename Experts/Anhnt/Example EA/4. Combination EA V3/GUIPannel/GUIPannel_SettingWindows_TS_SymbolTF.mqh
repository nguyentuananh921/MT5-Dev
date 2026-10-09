//+------------------------------------------------------------------+
//|                         GUIPannel_SettingWindows_TS_SymbolTF.mqh |
//| Symbol TF tab: Market Watch tree (left) + CSymbolTFManager table |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SETTINGWINDOWS_TS_SYMBOLTF_MQH_IMPLEMENTATION
#define CGUIPANNEL_SETTINGWINDOWS_TS_SYMBOLTF_MQH_IMPLEMENTATION
 #include "GUIPannel.mqh"
 #define COLUMNS_SYMBOLTF_TOTAL 6
 bool CGUIPannel::CreateTable_SymbolTFSetting(const int x,const int y)
  {
   m_btn_save_SymbolTF.SetText("Save");
   m_btn_save_SymbolTF.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SYMBOL_TF,m_btn_save_SymbolTF);
   if(!m_btn_save_SymbolTF.Create(m_chart_id,m_subwin,"BtnSaveSymbolTF",x,y+SYMBOLTF_BTN_Y,80,M_CONTROL_HEIGHT))
      return false;
   m_table_SymbolTFSeting.TableSize(COLUMNS_SYMBOLTF_TOTAL,0);
   m_table_SymbolTFSeting.View().ShowHeaders(true);
   m_table_SymbolTFSeting.View().SelectableRow(true);
   m_table_SymbolTFSeting.View().LightsHover(true);
   m_table_SymbolTFSeting.View().IsSortMode(false);   // CSymbolTFManager keeps its own Symbol/TF order
   m_table_SymbolTFSeting.AutoXResizeMode(true);
   m_table_SymbolTFSeting.AutoXResizeRightOffset(3);
   m_table_SymbolTFSeting.AutoYResizeMode(true);
   m_table_SymbolTFSeting.AutoYResizeBottomOffset(3);
   m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SYMBOL_TF,m_table_SymbolTFSeting);
   if(!m_table_SymbolTFSeting.CreateTable(m_chart_id,m_subwin,"TableSymbolTF",x,y+SYMBOLTF_TABLE_Y))
      return false;
   int widths[COLUMNS_SYMBOLTF_TOTAL]            ={M_SYMBOL_WITHICON_WIDTH,M_TF_WITHICON_WIDTH,M_ICON16_WIDTH,M_ICON16_WIDTH,M_ICON16_WIDTH,M_ICON16_WIDTH};
   int image_x[COLUMNS_SYMBOLTF_TOTAL]           ={3,3,2,2,2,2};
   ENUM_ALIGN_MODE align[COLUMNS_SYMBOLTF_TOTAL] ={ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT,ALIGN_LEFT};
   CTableHeaderView *header=m_table_SymbolTFSeting.View().GetHeaderViewPointer();
   header.ColumnsWidth(widths);
   header.TextAlign(align);
   header.ImageXOffset(image_x);
   m_table_SymbolTFSeting.SetHeaderText(0,"Symbol");
   m_table_SymbolTFSeting.SetHeaderText(1,"TF");
   uint img_buy[]    ={IMAGE_RESOURCE_BMP16_SIGNAL_BUY_PNG};
   uint img_sell[]   ={IMAGE_RESOURCE_BMP16_SIGNAL_SELL_PNG};
   uint img_sound[]  ={IMAGE_RESOURCE_BMP16_BELL_PNG};
   uint img_message[]={IMAGE_RESOURCE_BMP16_MESSAGE_PNG};
   m_table_SymbolTFSeting.SetHeaderText(2,"");  m_table_SymbolTFSeting.SetHeaderImage(2,img_buy);
   m_table_SymbolTFSeting.SetHeaderText(3,"");  m_table_SymbolTFSeting.SetHeaderImage(3,img_sell);
   m_table_SymbolTFSeting.SetHeaderText(4,"");  m_table_SymbolTFSeting.SetHeaderImage(4,img_sound);
   m_table_SymbolTFSeting.SetHeaderText(5,"");  m_table_SymbolTFSeting.SetHeaderImage(5,img_message);
   m_table_SymbolTFSeting.View().Rebuild(false);
   return true;
  }
 //--- Rows mirror CSymbolTFManager 1:1 in its order; rebuilt only when that stops being true
 void CGUIPannel::PopulateTable_SymbolTFSetting(void)
  {
   if(m_SymbolTFManager==NULL)
      return;
   int total=m_SymbolTFManager.Total();
   bool in_sync=((int)m_table_SymbolTFSeting.Model().RowsTotal()==total);
   for(int i=0;i<total && in_sync;i++)
     {
      CSymbolTFSetting *entry=m_SymbolTFManager.At(i);
      if(entry==NULL)
         continue;
      if(m_table_SymbolTFSeting.Cell(0,i).ValueS()!=entry.Symbol() ||
         m_table_SymbolTFSeting.Cell(1,i).ValueS()!=entry.TFText())
         in_sync=false;
     }
   if(!in_sync)
     {
      m_table_SymbolTFSeting.DeleteAllRows();
      for(int i=0;i<total;i++)
         m_table_SymbolTFSeting.AddRow();
     }
   this.SyncTable_SymbolTFSetting();
  }
 void CGUIPannel::SyncTable_SymbolTFSetting(void)
  {
   if(m_SymbolTFManager==NULL)
      return;
   uint delete_icon[]={IMAGE_RESOURCE_BMP16_CLOSE_RED_PNG};
   uint start_icon[] ={IMAGE_RESOURCE_BMP16_START_BMP};
   int total=::MathMin(m_SymbolTFManager.Total(),(int)m_table_SymbolTFSeting.Model().RowsTotal());
   for(int row=0;row<total;row++)
     {
      CSymbolTFSetting *entry=m_SymbolTFManager.At(row);
      if(entry==NULL)
         continue;
      bool is_current=(entry.Symbol()==::Symbol() && entry.TFText()==TimeframeDescription((ENUM_TIMEFRAMES)::Period()));
      m_table_SymbolTFSeting.CellView(0,row).CellType(CELL_BUTTON);
      if(is_current) m_table_SymbolTFSeting.CellView(0,row).SetImages(start_icon);
      else           m_table_SymbolTFSeting.CellView(0,row).SetImages(delete_icon);
      m_table_SymbolTFSeting.SetValue(0,row,entry.Symbol());
      m_table_SymbolTFSeting.SetValue(1,row,entry.TFText());
      bool flags[4];
      flags[0]=entry.BuySignal();
      flags[1]=entry.SellSignal();
      flags[2]=entry.SoundAlert();
      flags[3]=entry.MessageAlert();
      for(int c=0;c<4;c++)
        {
         m_table_SymbolTFSeting.CellView(c+2,row).CellType(CELL_CHECKBOX);
         m_table_SymbolTFSeting.SetValue(c+2,row,(long)(flags[c] ? CANV_ELEMENT_CHEK_STATE_CHECKED : CANV_ELEMENT_CHEK_STATE_UNCHECKED));
        }
     }
   m_table_SymbolTFSeting.View().Rebuild(true);
  }
 //--- GUI only: the Manager already removed the row before SYMBOLTF_MANAGER_EVENT_DELETE fired
 void CGUIPannel::DeleteRow_SymbolTFSetting(const string sym,const string tf_text)
  {
   int rows=(int)m_table_SymbolTFSeting.Model().RowsTotal();
   for(int row=0;row<rows;row++)
      if(m_table_SymbolTFSeting.Cell(0,row).ValueS()==sym && m_table_SymbolTFSeting.Cell(1,row).ValueS()==tf_text)
        {
         m_table_SymbolTFSeting.DeleteRow(row,true);
         return;
        }
  }
 //--- 'on' is the new checkbox state sent with the event (dparam)
 void CGUIPannel::OnCheckTableSymbolTFSetting(const string sym,const string tf_text,const int col,const bool on)
  {
   if(m_SymbolTFManager==NULL)
      return;
   CSymbolTFSetting *entry=m_SymbolTFManager.FindByIdentity(sym,TimestampByDescription(tf_text));
   if(entry==NULL)
      return;
   if(col==2)
     {
      entry.BuySignal(on);
      ::EventChartCustom(::ChartID(),(ushort)SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED,0,0.0,"");
     }
   else if(col==3)
     {
      entry.SellSignal(on);
      ::EventChartCustom(::ChartID(),(ushort)SYMBOLTF_MANAGER_EVENT_BUYSELL_CHANGED,0,0.0,"");
     }
   else if(col==4)
      entry.SoundAlert(on);
   else if(col==5)
      entry.MessageAlert(on);
  }
 bool CGUIPannel::CreateTreeView_SymbolTFSetting(const int x_gap,const int y_gap)
  {
   m_treeview_SymbolTF.LightsHover(true);
   m_tabs_setting_timeseries.AddToElementsArray(TAB_TAB_SETTING_TIMESERIES_SYMBOL_TF,m_treeview_SymbolTF);
   return m_treeview_SymbolTF.CreateTreeView(m_chart_id,m_subwin,"TreeSymbolTF",x_gap,y_gap,
                                             M_TREEVIEW_WIDTH,m_tabs_setting_timeseries.Height()-y_gap-3);
  }
 //--- Roots = Market Watch symbols + symbols CSymbolTFManager tracks (sorted), each tracked TF as a leaf
 void CGUIPannel::PopulateTreeView_SymbolTFSetting(void)
  {
   if(m_SymbolTFManager==NULL)
      return;
   int total=m_SymbolTFManager.Total();
   string names[];
   int mw_total=::SymbolsTotal(true);
   for(int i=0;i<mw_total+total;i++)
     {
      string name="";
      if(i<mw_total)
         name=::SymbolName(i,true);
      else
        {
         CSymbolTFSetting *entry=m_SymbolTFManager.At(i-mw_total);
         if(entry!=NULL)
            name=entry.Symbol();
        }
      if(name=="")
         continue;
      bool dup=false;
      for(int k=0;k<::ArraySize(names) && !dup;k++)
         dup=(names[k]==name);
      if(dup)
         continue;
      int sz=::ArraySize(names);
      ::ArrayResize(names,sz+1);
      names[sz]=name;
     }
   int n=::ArraySize(names);
   for(int a=0;a<n-1;a++)
      for(int b=a+1;b<n;b++)
         if(names[b]<names[a])
           {
            string tmp=names[a];
            names[a]=names[b];
            names[b]=tmp;
           }
   //--- Top level out of step (Market Watch add/remove): rebuild it in sorted order
   CTreeItem *root=NULL;
   for(int s=0;s<n && root==NULL;s++)
     {
      CTreeItem *found=m_treeview_SymbolTF.FindItem(WRONG_VALUE,names[s]);
      if(found!=NULL)
         root=found.ParentItem();
     }
   bool roots_same=(root!=NULL && root.ChildrenTotal()==n);
   for(int k=0;k<n && roots_same;k++)
     {
      CTreeItem *child=root.ChildItem(k);
      roots_same=(child!=NULL && child.LabelText()==names[k]);
     }
   if(!roots_same)
     {
      if(root!=NULL)
         for(int k=root.ChildrenTotal()-1;k>=0;k--)
           {
            CTreeItem *child=root.ChildItem(k);
            if(child!=NULL)
               m_treeview_SymbolTF.DeleteTreeItem(child.ObjectID());
           }
      for(int s=0;s<n;s++)
         m_treeview_SymbolTF.AddTreeItem(WRONG_VALUE,names[s]);
     }
   for(int s=0;s<n;s++)
     {
      CTreeItem *sym_item=m_treeview_SymbolTF.FindItem(WRONG_VALUE,names[s]);
      if(sym_item==NULL)
         continue;
      long sym_id=sym_item.ObjectID();
      string tfs[];
      for(int i=0;i<total;i++)
        {
         CSymbolTFSetting *entry=m_SymbolTFManager.At(i);
         if(entry==NULL || entry.Symbol()!=names[s])
            continue;
         int sz=::ArraySize(tfs);
         ::ArrayResize(tfs,sz+1);
         tfs[sz]=entry.TFText();
        }
      //--- Leaves already match the Manager (same TFs, same order): nothing to do
      bool same=(sym_item.ChildrenTotal()==::ArraySize(tfs));
      for(int k=0;k<::ArraySize(tfs) && same;k++)
        {
         CTreeItem *child=sym_item.ChildItem(k);
         same=(child!=NULL && child.LabelText()==tfs[k]);
        }
      if(same)
         continue;
      for(int k=sym_item.ChildrenTotal()-1;k>=0;k--)
        {
         CTreeItem *child=sym_item.ChildItem(k);
         if(child!=NULL)
            m_treeview_SymbolTF.DeleteTreeItem(child.ObjectID());
        }
      for(int k=0;k<::ArraySize(tfs);k++)
         m_treeview_SymbolTF.AddTreeItem(sym_id,tfs[k],IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP);
      if(::ArraySize(tfs)>0)
         m_treeview_SymbolTF.ItemState(sym_id,true);
     }
  }
 //--- Highlight the chart's own symbol and, under it, the chart's TF
 void CGUIPannel::SyncTreeView_SymbolTFSetting(void)
  {
   string chart_tf=TimeframeDescription((ENUM_TIMEFRAMES)::Period());
   //--- The chart's own symbol is always a root: its parent is the tree's top level
   CTreeItem *chart_item=m_treeview_SymbolTF.FindItem(WRONG_VALUE,::Symbol());
   CTreeItem *root=(chart_item!=NULL) ? chart_item.ParentItem() : NULL;
   int roots_total=(root!=NULL) ? root.ChildrenTotal() : 0;
   for(int s=0;s<roots_total;s++)
     {
      CTreeItem *sym_item=root.ChildItem(s);
      if(sym_item==NULL)
         continue;
      //--- Symbol without TFs: gray arrow icon in the expand-arrow slot
      bool active=(sym_item.LabelText()==::Symbol());
      sym_item.IconFile(sym_item.ChildrenTotal()>0 ? INT_MAX : IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
      sym_item.IsActive(active);
      for(int k=0;k<sym_item.ChildrenTotal();k++)
        {
         CTreeItem *tf_item=sym_item.ChildItem(k);
         if(tf_item==NULL)
            continue;
         bool highlight=(active && tf_item.LabelText()==chart_tf);
         tf_item.IconFile(highlight ? IMAGE_RESOURCE_BMP16_BAR_CHART_BMP : IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP);
        }
     }
   m_treeview_SymbolTF.UpdateTreeList(true);
  }
 //--- Symbol without TFs: start tracking it on the chart TF; TF leaf: ask to navigate there
 void CGUIPannel::OnClickTreeView_SymbolTFSetting(const long item_id)
  {
   if(m_SymbolTFManager==NULL)
      return;
   CTreeItem *item=m_treeview_SymbolTF.ItemPointer(item_id);
   if(item==NULL)
      return;
   if(item.NodeLevel()==0)
     {
      if(item.ChildrenTotal()==0 && !m_SymbolTFManager.Exists(item.LabelText(),(ENUM_TIMEFRAMES)::Period()))
         m_SymbolTFManager.Add_SymbolTFSetting(item.LabelText(),(ENUM_TIMEFRAMES)::Period());
      return;
     }
   CTreeItem *parent=item.ParentItem();
   if(parent==NULL)
      return;
   m_SymbolTFManager.NotifySettingChanged(parent.LabelText(),TimestampByDescription(item.LabelText()));
  }
 //+------------------------------------------------------------------+
 //| What the user (or the manager) did that this tab shows           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_SymbolTF(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- m_table_SymbolTFSeting: col 0 = delete button (not the chart's own pair)
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && lparam==m_table_SymbolTFSeting.ObjectID())
     {
      int col,row;
      if(!m_table_SymbolTFSeting.CellIndexes(sparam,col,row))
         return;
      if(col!=0 || row<0 || row>=(int)m_table_SymbolTFSeting.Model().RowsTotal())
         return;
      string sym=m_table_SymbolTFSeting.Cell(0,row).ValueS();
      string tf =m_table_SymbolTFSeting.Cell(1,row).ValueS();
      if(sym==::Symbol() && tf==TimeframeDescription((ENUM_TIMEFRAMES)::Period()))
         return;
      if(m_SymbolTFManager!=NULL)
         m_SymbolTFManager.Delete_SymbolTFSetting(sym,TimestampByDescription(tf));
      return;
     }
   //--- m_table_SymbolTFSeting: cols 2..5 = checkboxes, dparam = the new state
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX && lparam==m_table_SymbolTFSeting.ObjectID())
     {
      int col,row;
      if(!m_table_SymbolTFSeting.CellIndexes(sparam,col,row))
         return;
      if(col<2 || col>5 || row<0 || row>=(int)m_table_SymbolTFSeting.Model().RowsTotal())
         return;
      this.OnCheckTableSymbolTFSetting(m_table_SymbolTFSeting.Cell(0,row).ValueS(),m_table_SymbolTFSeting.Cell(1,row).ValueS(),col,dparam!=0);
      return;
     }
   //--- CSymbolTFManager changed for real: resync our own view right away
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED)
     {
      this.PopulateTable_SymbolTFSetting();
      this.PopulateTreeView_SymbolTFSetting();
      this.SyncTreeView_SymbolTFSetting();
      ::ChartRedraw(m_chart_id);
      return;
     }
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE)
     {
      string removed_sym="";
      ENUM_TIMEFRAMES removed_tf=PERIOD_CURRENT;
      if(m_SymbolTFManager!=NULL)
         m_SymbolTFManager.GetLastRemoved(removed_sym,removed_tf);
      this.DeleteRow_SymbolTFSetting(removed_sym,TimeframeDescription(removed_tf));
      this.PopulateTreeView_SymbolTFSetting();
      this.SyncTreeView_SymbolTFSetting();
      ::ChartRedraw(m_chart_id);
      return;
     }
   //--- A symbol added to / removed from Market Watch: the tree lists them
   if(id==CHARTEVENT_CUSTOM+MARKET_WATCH_EVENT_SYMBOL_ADD || id==CHARTEVENT_CUSTOM+MARKET_WATCH_EVENT_SYMBOL_DEL ||
      id==CHARTEVENT_CUSTOM+MARKET_WATCH_EVENT_SYMBOL_SORT)
     {
      this.PopulateTreeView_SymbolTFSetting();
      this.SyncTreeView_SymbolTFSetting();
      ::ChartRedraw(m_chart_id);
      return;
     }
   //--- Symbol TF tree: a symbol leaf starts tracking it, a TF leaf asks to navigate there
   if(id==CHARTEVENT_CUSTOM+ON_CHANGE_TREE_PATH && lparam==m_treeview_SymbolTF.ObjectID())
     {
      this.OnClickTreeView_SymbolTFSetting((long)dparam);
      return;
     }
  }
#endif //CGUIPANNEL_SETTINGWINDOWS_TS_SYMBOLTF_MQH_IMPLEMENTATION
