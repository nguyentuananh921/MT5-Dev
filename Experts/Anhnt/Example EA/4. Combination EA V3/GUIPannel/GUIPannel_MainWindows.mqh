//+------------------------------------------------------------------+
//|                                        GUIPannel_MainWindows.mqh |
//|           Implementation of function Main Windows m_window_main  |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_MAINWINDOWS_MQH
#define CGUIPANNEL_MAINWINDOWS_MQH
#include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| Create Main Window                                               |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateWindow_Main(const string caption_text,const int x_gap,const int y_gap)
  {
   //--- Properties
   m_window_main.FontSize(DEF_FONT_SIZE);
   m_window_main.IsMovable(true);
   m_window_main.ResizeMode(true);
   m_window_main.CloseButtonIsUsed(true);
   m_window_main.CollapseButtonIsUsed(true);
   m_window_main.TooltipsButtonIsUsed(true);
   m_window_main.FullscreenButtonIsUsed(true);
   // Allow shrinking horizontally down to 300px and vertically down to 200px
   m_window_main.MinimumXSize(M_WINDOW_MIN_WIDTH);
   m_window_main.MinimumYSize(M_WINDOW_MIN_HEIGHT);
   //--- Create the form default ENUM_WINDOW_TYPE W_MAIN
   if(!m_window_main.CreateWindow(this.m_chart_id,M_SUBWINDOW_MAIN,caption_text,x_gap,y_gap,M_WINDOW_MAIN_WIDTH,M_WINDOW_MAIN_HEIGHT))
      return(false);
   return(true);
  }
 //+------------------------------------------------------------------+
 //| The Symbols of the CSymbolsCollection in a combobox of the caption bar |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateComboBox_SymbolTF(const int x_gap,const int y_gap)
  {
   int total=(m_SymbolsCollection!=NULL) ? m_SymbolsCollection.GetList().Total() : 0;
   m_combobox_SymbolTF.ItemsTotal(::MathMax(total,1));
   m_window_main.GetCaptionPointer().AddChild(&m_combobox_SymbolTF);
   if(!m_combobox_SymbolTF.CreateComboBox(this.m_chart_id,M_SUBWINDOW_MAIN,"ComboSymbolTF",x_gap,y_gap,M_SYMBOLTF_COMBO_WIDTH,M_CONTROL_HEIGHT,M_SYMBOLTF_COMBO_WIDTH,M_SYMBOLTF_COMBO_LIST_HEIGHT))
      return(false);
   //--- Transparent on the caption bar: white text and arrow, the colors of the caption buttons on hover and press
   CButtonTriggered *button=m_combobox_SymbolTF.GetButtonPointer();
   button.GetBackColorControl().InitColors(clrNONE,C'90,139,232',C'67,103,173',clrNONE);
   button.GetBackColorActControl().InitColors(C'67,103,173',C'67,103,173',C'67,103,173',clrNONE);
   button.GetBorderColorControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
   button.GetBorderColorActControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
   button.GetForeColorControl().InitColors(clrWhite,clrWhite,clrWhite,clrSilver);
   button.GetForeColorActControl().InitColors(clrWhite,clrWhite,clrWhite,clrSilver);
   button.IconFile(IMAGE_RESOURCE_BMP16_DOWN_THIN_WHITE_BMP);
   button.IconFileLocked(IMAGE_RESOURCE_BMP16_DOWN_THIN_WHITE_BMP);
   button.IconFilePressed(IMAGE_RESOURCE_BMP16_UP_THIN_WHITE_BMP);
   button.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_UP_THIN_WHITE_BMP);
   button.ColorChange(COLOR_STATE_DEFAULT);
   button.Draw(false);
   this.SyncComboBox_SymbolTF();
   return(true);
  }
 //+------------------------------------------------------------------+
 //| Next to the caption buttons, at the right edge of the window     |
 //+------------------------------------------------------------------+
 void CGUIPannel::ArrangeComboBox_SymbolTF(void)
  {
   int x=m_window_main.X()+m_window_main.Width()-m_window_main.CaptionRightLimit()-M_SYMBOLTF_COMBO_WIDTH;
   m_combobox_SymbolTF.Move(x,m_window_main.Y());
  }
 //+------------------------------------------------------------------+
 //| The list follows the Symbols of the collection, the chart's      |
 //| Symbol is the selected one                                       |
 //+------------------------------------------------------------------+
 void CGUIPannel::SyncComboBox_SymbolTF(void)
  {
   CArrayObj *list=(m_SymbolsCollection!=NULL) ? m_SymbolsCollection.GetList() : NULL;
   int total=(list!=NULL) ? list.Total() : 0;
   m_combobox_SymbolTF.GetListViewPointer().Rebuilding(::MathMax(total,1));
   int select_index=0;
   for(int i=0;i<total;i++)
     {
      CSymbol *symbol=list.At(i);
      m_combobox_SymbolTF.SetValue(i,symbol.Name());
      if(symbol.Name()==::Symbol())
         select_index=i;
     }
   if(total==0)
      m_combobox_SymbolTF.SetValue(0,::Symbol());
   m_combobox_SymbolTF.SelectItem(select_index);
   m_combobox_SymbolTF.GetListViewPointer().Draw(false);   // SetValue/SelectItem only store, repaint the list
  }
 //+------------------------------------------------------------------+
 //| "All" (with 2+ TFs) and the TFs tracked for the chart Symbol and |
 //| the TF of the chart, one button each, the smallest first. The first call creates the  |
 //| group at x_gap,y_gap (in m_window_main, above m_tabs_main), every|
 //| later call builds the buttons again when the TFs changed and     |
 //| selects the TF the chart is on                                   |
 //+------------------------------------------------------------------+
 bool CGUIPannel::BuildTFSwitchButtons(const int x_gap,const int y_gap)
  {
   const string symbol=::Symbol();
   const ENUM_TIMEFRAMES chart_tf=(ENUM_TIMEFRAMES)::Period();
   ENUM_TIMEFRAMES tfs[];
   int tf_count=0;
   bool chart_listed=false;
   int total=(m_SymbolTFManager!=NULL) ? m_SymbolTFManager.Total() : 0;
   for(int i=0;i<total;i++)
     {
      CSymbolTFSetting *row=m_SymbolTFManager.At(i);
      if(row==NULL || row.Symbol()!=symbol)
         continue;
      ::ArrayResize(tfs,tf_count+1);
      tfs[tf_count++]=row.TFEnum();
      if(row.TFEnum()==chart_tf)
         chart_listed=true;
     }
   if(!chart_listed)
     {
      ::ArrayResize(tfs,tf_count+1);
      tfs[tf_count++]=chart_tf;
     }
   for(int a=0;a<tf_count-1;a++)
      for(int b=a+1;b<tf_count;b++)
         if(::PeriodSeconds(tfs[b])<::PeriodSeconds(tfs[a]))
           {
            ENUM_TIMEFRAMES swap=tfs[a];
            tfs[a]=tfs[b];
            tfs[b]=swap;
           }
   int first_tf_button=(tf_count!=1) ? 1 : 0;   // "All" when there are 2+ TFs
   bool created=(m_btngroup_tf_switch.ButtonsTotal()>0);
   bool was_all_selected=(created && m_btngroup_tf_switch.SelectedButtonText()=="All");
   bool buttons_match=(created && m_btngroup_tf_switch.ButtonsTotal()==tf_count+first_tf_button);
   if(buttons_match && first_tf_button==1)
      buttons_match=(m_btngroup_tf_switch.GetButtonPointer(0).Text()=="All");
   for(int i=0;i<tf_count && buttons_match;i++)
      buttons_match=(m_btngroup_tf_switch.GetButtonPointer(i+first_tf_button).Text()==TimeframeDescription(tfs[i]));
   if(!buttons_match)
     {
      if(created)
         m_btngroup_tf_switch.DeleteButtons();
      else
        {
         m_btngroup_tf_switch.RadioButtonsMode(true);
         m_btngroup_tf_switch.ButtonYSize(M_CONTROL_HEIGHT);
        }
      if(first_tf_button==1)
         m_btngroup_tf_switch.AddButton(0,0,"All",M_TF_WITHOUT_ICON_WIDTH);
      for(int i=0;i<tf_count;i++)
         m_btngroup_tf_switch.AddButton((i+first_tf_button)*(M_TF_WITHOUT_ICON_WIDTH+M_CONTROL_BORDER_GAP),0,TimeframeDescription(tfs[i]),M_TF_WITHOUT_ICON_WIDTH);
      if(!created)
        {
         m_window_main.AddChild(&m_btngroup_tf_switch);   // of the window, above the tabs: it stays whichever tab is open
         if(!m_btngroup_tf_switch.CreateButtonsGroup(this.m_chart_id,M_SUBWINDOW_MAIN,"TFSwitch",x_gap,y_gap))
            return false;
        }
     }
   //--- "All" stays selected while the chart stays; otherwise the TF of the chart
   if(was_all_selected && first_tf_button==1)
     {
      m_btngroup_tf_switch.SelectButton(0);
      return true;
     }
   for(int i=0;i<tf_count;i++)
      if(tfs[i]==chart_tf && m_btngroup_tf_switch.GetButtonPointer(i+first_tf_button).Text()!=m_btngroup_tf_switch.SelectedButtonText())
         m_btngroup_tf_switch.SelectButton(i+first_tf_button);
   if(created)
      this.SyncTable_PreTradeSymbolMonitor(symbol);   // the rows follow the TFs
   return true;
  }
 // For Status Bar at bottom of m_window_main
 //+------------------------------------------------------------------+
 //| Creates the status bar                                           |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateStatusBar(const int x_gap,const int y_gap)
  {
   //--- Specify the number of parts and set their properties
   for(int i=0;i<STATUS_LABELS_TOTAL;i++)
      m_status_bar.AddItem("",STATUS_BAR_WIDTH[i]);
   //--- Create a control element (follows the window's right and bottom edges)
   m_window_main.AddChild(&m_status_bar);
   if(!m_status_bar.CreateStatusBar(this.m_chart_id,M_SUBWINDOW_MAIN,"StatusBar",x_gap,y_gap,M_WINDOW_MAIN_WIDTH-2))
      return(false);
   //--- Balance icons: arrow up, arrow down, gray
   CLabel *balance_item=m_status_bar.GetItemPointer(STATUS_BAR_BALANCE);
   balance_item.AddImagesGroup(2,3);
   balance_item.AddImage(0,IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG);
   balance_item.AddImage(0,IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG);
   balance_item.AddImage(0,IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP);
   balance_item.ChangeImage(0,2);
   balance_item.LabelXGap(22);   // the text after the 16 px icon at x=2
   return(true);
  }
 //+------------------------------------------------------------------+
 //| Symbol of the chart and its spread in points, set when it changed|
 //+------------------------------------------------------------------+
 void CGUIPannel::UpdateStatusBar_SymbolSpread(void)
  {
   if(m_SymbolsCollection==NULL)
      return;
   CSymbol *symbol=m_SymbolsCollection.GetSymbolObjByName(::Symbol());
   if(symbol==NULL)
      return;
   symbol.Refresh();
   string text=symbol.Name()+" spread: "+(string)symbol.Spread()+" pts";
   if(m_status_bar.GetItemPointer(STATUS_BAR_SYMBOL_SPREAD).Text()!=text)
      m_status_bar.SetValue(STATUS_BAR_SYMBOL_SPREAD,text);
  }
 //+------------------------------------------------------------------+
 //| The balance of the current account, set when it changed          |
 //+------------------------------------------------------------------+
 void CGUIPannel::UpdateStatusBar_Balance(void)
  {
   if(m_AccountsCollection==NULL)
      return;
   CAccount *account=m_AccountsCollection.GetCurrentAccount();
   if(account==NULL)
      return;
   string text="Balance: "+::DoubleToString(account.Balance(),(int)account.CurrencyDigits())+" "+account.Currency();
   CLabel *item=m_status_bar.GetItemPointer(STATUS_BAR_BALANCE);
   if(item.Text()==text)
      return;
   //--- The account says what changed in its last Refresh: the arrow follows it, gray for the first text
   int image=(item.Text()=="") ? 2 : account.IsIncreasedBalance() ? 0 : account.IsDecreasedBalance() ? 1 : 2;
   item.ChangeImage(0,image);
   m_status_bar.SetValue(STATUS_BAR_BALANCE,text);
  }
 // For Main Tabs m_tabs_main below the menu bar of Main Window m_window_main
 bool CGUIPannel::CreateTab_Main(const int x_gap,const int y_gap)
  {
   string tabs_names[TAB_TAB_MAIN_TOTAL]={"Trading","Quick Setting"};   // the order of ENUM_TAB_MAIN
   //--- Properties
   m_tabs_main.PositionMode(TABS_TOP);
   m_tabs_main.AutoXResizeMode(true);
   m_tabs_main.AutoYResizeMode(true);
   m_tabs_main.AutoXResizeRightOffset(3);
   m_tabs_main.AutoYResizeBottomOffset(25);
   //--- Add tabs with the specified properties
   for(int i=0;i<TAB_TAB_MAIN_TOTAL;i++)
      m_tabs_main.AddTab(tabs_names[i],100);
   //--- Create Tab before create other control element inside
   m_window_main.AddChild(&m_tabs_main);
   if(!m_tabs_main.CreateTabs(this.m_chart_id,M_SUBWINDOW_MAIN,"TabsMain",x_gap,y_gap))
      return(false);
   return(true);
  }
 // For Menu Bar
 //+------------------------------------------------------------------+
 //| Creates the menu bar                                             |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateMenuBar(const int x_gap,const int y_gap)
  {
   //--- Add items (placeholder text/width
   m_menu_bar.AddItem(ENUM_MENU_ITEM_WIDTH,"Help");
   //--- Create a control element
   m_window_main.AddChild(&m_menu_bar);
   if(!m_menu_bar.CreateMenuBar(this.m_chart_id,M_SUBWINDOW_MAIN,"MenuBar",x_gap,y_gap,M_WINDOW_MAIN_WIDTH-2))
      return(false);
   //--- Icon for the Help item, text after it
   CMenuItem *help_item=m_menu_bar.GetItemPointer(MENU_ITEM_HELP);
   help_item.IconFile(IMAGE_RESOURCE_BMP16_HELP_DARK_BMP);
   help_item.LabelXGap(22);
   help_item.Draw(false);
   return(true);
  }
#endif // CGUIPANNEL_MAINWINDOWS_MQH
