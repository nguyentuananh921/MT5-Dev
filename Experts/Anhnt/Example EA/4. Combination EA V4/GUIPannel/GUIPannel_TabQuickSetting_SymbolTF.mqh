//+------------------------------------------------------------------+
//|                            GUIPannel_TabQuickSetting_SymbolTF.mqh |
//| Symbol TF tab: the tree and the table of the pairs               |
//+------------------------------------------------------------------+
#ifndef __GUIPANNEL_TABQUICKSETTING_SYMBOLTF_MQH__
#define __GUIPANNEL_TABQUICKSETTING_SYMBOLTF_MQH__
#include "GUIPannel.mqh"
 //--- Symbol TF tab: the tree of the symbols (left) and the CSymbolTFManager table (right), both from the database
 bool CGUIPannel::CreateTable_SymbolTFSetting(const int x,const int y)
  {
   //--- Every change is written to the database at once: the tab has no Save button
   m_table_SymbolTFSeting.TableSize(COLUMNS_SYMBOLTF_TOTAL,0);
   m_table_SymbolTFSeting.View().ShowHeaders(true);
   m_table_SymbolTFSeting.View().SelectableRow(true);
   m_table_SymbolTFSeting.View().LightsHover(true);
   m_table_SymbolTFSeting.View().IsSortMode(false);   // CSymbolTFManager keeps its own Symbol/TF order
   m_table_SymbolTFSeting.AutoXResizeMode(true);
   m_table_SymbolTFSeting.AutoXResizeRightOffset(3);
   m_table_SymbolTFSeting.AutoYResizeMode(true);
   m_table_SymbolTFSeting.AutoYResizeBottomOffset(3);
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_SYMBOL_TF,m_table_SymbolTFSeting);
   if(!m_table_SymbolTFSeting.CreateTable(this.m_chart_id,M_SUBWINDOW_MAIN,"TableSymbolTF",x,y+M_CONTROL_BORDER_GAP))
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
   string pair_symbols[];
   ENUM_TIMEFRAMES pair_tfs[];
   int total=m_SymbolTFManager.Read_RAM(pair_symbols,pair_tfs);
   bool in_sync=((int)m_table_SymbolTFSeting.Model().RowsTotal()==total);
   for(int i=0;i<total && in_sync;i++)
     {
      if(m_table_SymbolTFSeting.Cell(0,i).ValueS()!=pair_symbols[i] ||
         m_table_SymbolTFSeting.Model().Row(i).Value()!=(long)pair_tfs[i])
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
   string pair_symbols[];
   ENUM_TIMEFRAMES pair_tfs[];
   bool pair_buy[],pair_sell[],pair_sound[],pair_message[];
   int total=::MathMin(m_SymbolTFManager.Read_RAM(pair_symbols,pair_tfs,pair_buy,pair_sell,pair_sound,pair_message),(int)m_table_SymbolTFSeting.Model().RowsTotal());
   for(int row=0;row<total;row++)
     {
      m_table_SymbolTFSeting.Model().Row(row).Value((long)pair_tfs[row]);   // the row stands for its tf_enum, the cell is only its look
      bool is_current=(pair_symbols[row]==::Symbol() && pair_tfs[row]==(ENUM_TIMEFRAMES)::Period());
      m_table_SymbolTFSeting.CellView(0,row).CellType(CELL_BUTTON);
      if(is_current) m_table_SymbolTFSeting.CellView(0,row).SetImages(start_icon);
      else           m_table_SymbolTFSeting.CellView(0,row).SetImages(delete_icon);
      m_table_SymbolTFSeting.SetValue(0,row,pair_symbols[row]);
      m_table_SymbolTFSeting.SetValue(1,row,m_SymbolTFManager.Read_RAM((ENUM_TIMEFRAMES)pair_tfs[row]));
      bool flags[4];
      flags[0]=pair_buy[row];
      flags[1]=pair_sell[row];
      flags[2]=pair_sound[row];
      flags[3]=pair_message[row];
      for(int c=0;c<4;c++)
        {
         m_table_SymbolTFSeting.CellView(c+2,row).CellType(CELL_CHECKBOX);
         m_table_SymbolTFSeting.SetValue(c+2,row,(long)(flags[c] ? CANV_ELEMENT_CHECK_STATE_CHECKED : CANV_ELEMENT_CHECK_STATE_UNCHECKED));
        }
     }
   m_table_SymbolTFSeting.View().Rebuild(true);
  }
 //--- GUI only: the Manager already removed the row before SYMBOLTF_MANAGER_EVENT_DELETE fired
 void CGUIPannel::DeleteRow_SymbolTFSetting(const string sym,const ENUM_TIMEFRAMES tf)
  {
   int rows=(int)m_table_SymbolTFSeting.Model().RowsTotal();
   for(int row=0;row<rows;row++)
      if(m_table_SymbolTFSeting.Cell(0,row).ValueS()==sym && m_table_SymbolTFSeting.Model().Row(row).Value()==(long)tf)
        {
         m_table_SymbolTFSeting.DeleteRow(row,true);
         return;
        }
  }
 //--- 'on' is the new checkbox state sent with the event (dparam)
 void CGUIPannel::OnCheckTableSymbolTFSetting(const string sym,const ENUM_TIMEFRAMES tf,const int col,const bool on)
  {
   if(m_SymbolTFManager==NULL)
      return;
   if(m_SymbolTFManager.Read_RAM(sym,tf)==NULL)
      return;
   if(col==2)
      m_SymbolTFManager.Update_SymbolTF_Setting(sym,tf,"buy_signal",on);
   else if(col==3)
      m_SymbolTFManager.Update_SymbolTF_Setting(sym,tf,"sell_signal",on);
   else if(col==4)
      m_SymbolTFManager.Update_SymbolTF_Setting(sym,tf,"sound_alert",on);
   else if(col==5)
      m_SymbolTFManager.Update_SymbolTF_Setting(sym,tf,"message_alert",on);
  }
 bool CGUIPannel::CreateTreeView_SymbolTFSetting(const int x_gap,const int y_gap)
  {
   m_treeview_SymbolTF.LightsHover(true);
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_SYMBOL_TF,m_treeview_SymbolTF);
   return m_treeview_SymbolTF.CreateTreeView(this.m_chart_id,M_SUBWINDOW_MAIN,"TreeSymbolTF",x_gap,y_gap,
                                             M_TREEVIEW_WIDTH,m_tabs_quickSetting.Height()-y_gap-3);
  }
 //--- Roots = the symbols of this account (CSymbolsCollection, from the database) + the symbols CSymbolTFManager tracks (sorted), each tracked TF as a leaf
 void CGUIPannel::PopulateTreeView_SymbolTFSetting(void)
  {
   if(m_SymbolTFManager==NULL)
      return;
   string pair_symbols[];
   ENUM_TIMEFRAMES pair_tfs[];
   int total=m_SymbolTFManager.Read_RAM(pair_symbols,pair_tfs);
   string names[];
   CArrayObj *symbols=(m_SymbolsCollection!=NULL) ? m_SymbolsCollection.GetList() : NULL;
   int symbols_total=(symbols!=NULL) ? symbols.Total() : 0;
   for(int i=0;i<symbols_total+total;i++)
     {
      string name="";
      if(i<symbols_total)
        {
         CSymbol *symbol=symbols.At(i);
         name=(symbol!=NULL) ? symbol.Name() : "";
        }
      else
         name=pair_symbols[i-symbols_total];
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
      ENUM_TIMEFRAMES tfs[];
      for(int i=0;i<total;i++)
        {
         if(pair_symbols[i]!=names[s])
            continue;
         int sz=::ArraySize(tfs);
         ::ArrayResize(tfs,sz+1);
         tfs[sz]=pair_tfs[i];
        }
      //--- Leaves already match the Manager (same TFs, same order): nothing to do
      bool same=(sym_item.ChildrenTotal()==::ArraySize(tfs));
      for(int k=0;k<::ArraySize(tfs) && same;k++)
        {
         CTreeItem *child=sym_item.ChildItem(k);
         same=(child!=NULL && child.Value()==(long)tfs[k]);
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
         m_treeview_SymbolTF.AddTreeItem(sym_id,m_SymbolTFManager.Read_RAM((ENUM_TIMEFRAMES)tfs[k]),IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP,false,(long)tfs[k]);
      if(::ArraySize(tfs)>0)
         m_treeview_SymbolTF.ItemState(sym_id,true);
     }
  }
 //--- Highlight the chart's own symbol and, under it, the chart's TF
 void CGUIPannel::SyncTreeView_SymbolTFSetting(void)
  {
   const long chart_tf=(long)::Period();
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
         bool highlight=(active && tf_item.Value()==chart_tf);
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
      if(item.ChildrenTotal()==0 && m_SymbolTFManager.Read_RAM(item.LabelText(),(ENUM_TIMEFRAMES)::Period())==NULL)
         m_SymbolTFManager.Update_SymbolTF_Setting(item.LabelText(),(ENUM_TIMEFRAMES)::Period(),SYMBOLTF_MANAGER_EVENT_ADDED);
      return;
     }
   CTreeItem *parent=item.ParentItem();
   if(parent==NULL)
      return;
   m_SymbolTFManager.Update_SymbolTF_Setting(parent.LabelText(),(ENUM_TIMEFRAMES)item.Value(),SYMBOLTF_MANAGER_EVENT_SETTING_CHANGED);
  }
 //+------------------------------------------------------------------+
 //| What the user (or the manager) did that this tab shows           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_SymbolTF(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- m_table_SymbolTFSeting: col 0 = delete button (not the chart's own pair)
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_BUTTON && lparam==m_table_SymbolTFSeting.ObjectID())
     {
      int col,row;
      if(!m_table_SymbolTFSeting.CellIndexes(sparam,col,row))
         return;
      if(col!=0 || row<0 || row>=(int)m_table_SymbolTFSeting.Model().RowsTotal())
         return;
      string sym=m_table_SymbolTFSeting.Cell(0,row).ValueS();
      ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)m_table_SymbolTFSeting.Model().Row(row).Value();
      if(sym==::Symbol() && tf==(ENUM_TIMEFRAMES)::Period())
         return;
      if(m_SymbolTFManager!=NULL)
         m_SymbolTFManager.Update_SymbolTF_Setting(sym,tf,SYMBOLTF_MANAGER_EVENT_DELETE);
      return;
     }
   //--- m_table_SymbolTFSeting: cols 2..5 = checkboxes, dparam = the new state
   if(id==CHARTEVENT_CUSTOM+CLICK_EVENT_CHECKBOX && lparam==m_table_SymbolTFSeting.ObjectID())
     {
      int col,row;
      if(!m_table_SymbolTFSeting.CellIndexes(sparam,col,row))
         return;
      if(col<2 || col>5 || row<0 || row>=(int)m_table_SymbolTFSeting.Model().RowsTotal())
         return;
      this.OnCheckTableSymbolTFSetting(m_table_SymbolTFSeting.Cell(0,row).ValueS(),(ENUM_TIMEFRAMES)m_table_SymbolTFSeting.Model().Row(row).Value(),col,dparam!=0);
      return;
     }
   //--- CSymbolTFManager changed for real: resync our own view right away
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_ADDED)
     {
      this.PopulateTable_SymbolTFSetting();
      this.PopulateTreeView_SymbolTFSetting();
      this.SyncTreeView_SymbolTFSetting();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   if(id==CHARTEVENT_CUSTOM+SYMBOLTF_MANAGER_EVENT_DELETE)
     {
      //--- The event carries the pair that was removed: sparam = its Symbol, lparam = its TF
      this.DeleteRow_SymbolTFSetting(sparam,(ENUM_TIMEFRAMES)(int)lparam);
      this.PopulateTreeView_SymbolTFSetting();
      this.SyncTreeView_SymbolTFSetting();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- A symbol added to / removed from Market Watch (CSymbolsCollection, V3): the tree lists them
   if(id==CHARTEVENT_CUSTOM+MARKET_WATCH_EVENT_SYMBOL_ADD || id==CHARTEVENT_CUSTOM+MARKET_WATCH_EVENT_SYMBOL_DEL ||
      id==CHARTEVENT_CUSTOM+MARKET_WATCH_EVENT_SYMBOL_SORT)
     {
      this.PopulateTreeView_SymbolTFSetting();
      this.SyncTreeView_SymbolTFSetting();
      ::ChartRedraw(this.m_chart_id);
      return;
     }
   //--- Symbol TF tree: a symbol leaf starts tracking it, a TF leaf asks to navigate there
   if(id==CHARTEVENT_CUSTOM+CHANGE_EVENT_TREE_PATH && lparam==m_treeview_SymbolTF.ObjectID())
     {
      this.OnClickTreeView_SymbolTFSetting((long)dparam);
      return;
     }
  }
#endif // __GUIPANNEL_TABQUICKSETTING_SYMBOLTF_MQH__
