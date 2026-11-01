//+------------------------------------------------------------------+
//|                                        GUIPannel_Window_Main.mqh |
//|           Implementation of function Main Windows m_window_main  |
//+------------------------------------------------------------------+
#ifndef __GUIPANNEL_WINDOW_MAIN_MQH__
#define __GUIPANNEL_WINDOW_MAIN_MQH__
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
   //--- On the caption bar as the labels of the positions: a light background, black text and arrow, light gray on hover and press
   CButtonTriggered *button=m_combobox_SymbolTF.GetButtonPointer();
   button.GetBackColorControl().InitColors(M_COLOR_CAPTION_LABEL_BACK,C'229,241,251',C'204,228,247',M_COLOR_CAPTION_LABEL_BACK);
   button.GetBackColorActControl().InitColors(C'204,228,247',C'204,228,247',C'204,228,247',M_COLOR_CAPTION_LABEL_BACK);
   button.GetBorderColorControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
   button.GetBorderColorActControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
   button.GetForeColorControl().InitColors(clrBlack,clrBlack,clrBlack,clrGray);
   button.GetForeColorActControl().InitColors(clrBlack,clrBlack,clrBlack,clrGray);
   button.IconFile(IMAGE_RESOURCE_BMP16_DOWN_THIN_BLACK_BMP);
   button.IconFileLocked(IMAGE_RESOURCE_BMP16_DOWN_THIN_BLACK_BMP);
   button.IconFilePressed(IMAGE_RESOURCE_BMP16_UP_THIN_BLACK_BMP);
   button.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_UP_THIN_BLACK_BMP);
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
   this.UpdateCaption_Position();   // the labels stay left of the combobox
  }
 //+------------------------------------------------------------------+
 //| The labels of the positions and of the profit on the caption bar |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateLabel_Caption(void)
  {
   CLabel *labels[3];
   labels[0]=::GetPointer(m_label_PositionBuy);
   labels[1]=::GetPointer(m_label_PositionSell);
   labels[2]=::GetPointer(m_label_Profit);
   string names[3]={"CaptionPositionBuy","CaptionPositionSell","CaptionProfit"};
   for(int i=0;i<3;i++)
     {
      m_window_main.GetCaptionPointer().AddChild(labels[i]);
      labels[i].LabelXGap(M_CAPTION_LABEL_PADDING);
      labels[i].FontWeight(FW_BOLD);
      if(!labels[i].Create(this.m_chart_id,M_SUBWINDOW_MAIN,names[i],0,M_CAPTION_LABEL_Y,M_CAPTION_LABEL_PADDING*2,M_CONTROL_HEIGHT-M_CAPTION_LABEL_Y*2))
         return(false);
      //--- A light background: the text stands out on the blue caption
      labels[i].GetBackColorControl().InitColors(M_COLOR_CAPTION_LABEL_BACK,M_COLOR_CAPTION_LABEL_BACK,M_COLOR_CAPTION_LABEL_BACK,M_COLOR_CAPTION_LABEL_BACK);
      labels[i].Hide();
     }
   this.UpdateCaption_Position();
   return(true);
  }
 //+------------------------------------------------------------------+
 //| Right to left from the combobox: the profit, the Sell number, the|
 //| Buy number ("Sell 5", "Profit 12.30"; collapsed: only the values)|
 //| a side without a position is hidden. The positions are the ones  |
 //| of CMarketCollection (RAM), the profit the one of CAccount        |
 //| (ACCOUNT_PROP_PROFIT event). A label is as wide as its text       |
 //+------------------------------------------------------------------+
 void CGUIPannel::UpdateCaption_Position(void)
  {
   int buys=(m_MarketCollection!=NULL ? m_MarketCollection.PositionsCount("",POSITION_TYPE_BUY) : 0);
   int sells=(m_MarketCollection!=NULL ? m_MarketCollection.PositionsCount("",POSITION_TYPE_SELL) : 0);
   CAccount *account=(m_AccountsCollection!=NULL ? m_AccountsCollection.GetCurrentAccount() : NULL);
   double profit=(account!=NULL ? account.Profit() : 0);
   bool collapsed=m_window_main.IsMinimized();
   CLabel *labels[3];
   labels[0]=::GetPointer(m_label_Profit);
   labels[1]=::GetPointer(m_label_PositionSell);
   labels[2]=::GetPointer(m_label_PositionBuy);
   bool   shown[3] ={buys+sells>0,sells>0,buys>0};
   string texts[3] ={(collapsed ? "" : "Profit ")+::DoubleToString(profit,2),(collapsed ? "" : "Sell ")+(string)sells,(collapsed ? "" : "Buy ")+(string)buys};
   color  colors[3]={(profit>0 ? M_COLOR_PROFIT : profit<0 ? M_COLOR_LOSS : clrBlack),M_COLOR_LOSS,M_COLOR_PROFIT};
   ::TextSetFont(DEF_FONT,-DEF_FONT_SIZE*10,FW_BOLD);   // the font of the labels (CLabel: DEF_FONT, FW_BOLD): the width of each text
   int x=m_window_main.X()+m_window_main.Width()-m_window_main.CaptionRightLimit()-M_SYMBOLTF_COMBO_WIDTH;
   int y=m_window_main.Y()+M_CAPTION_LABEL_Y;
   for(int i=0;i<3;i++)
     {
      if(!shown[i])
        {
         labels[i].Hide();
         continue;
        }
      uint text_w=0,text_h=0;
      ::TextGetSize(texts[i],text_w,text_h);
      int w=(int)text_w+M_CAPTION_LABEL_PADDING*2+M_CAPTION_LABEL_SLACK;   // CLabel keeps 2 px more at the right (TextMaxWidth): the last digit is not cut
      x-=w+M_CAPTION_LABEL_GAP;
      bool same=(labels[i].IsVisible() && labels[i].X()==x && labels[i].Y()==y && labels[i].Width()==w && labels[i].Text()==texts[i]);   // the color goes with the text
      if(same)
         continue;   // only what changed is drawn again (the profit moves at each tick)
      labels[i].Resize(w,labels[i].Height());
      labels[i].Move(x,y);
      labels[i].GetForeColorControl().InitColors(colors[i],colors[i],colors[i],colors[i]);
      labels[i].ColorChange(COLOR_STATE_DEFAULT);
      labels[i].SetText(texts[i]);
      labels[i].Show();
      labels[i].Draw(false);
     }
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
   if(m_SymbolTFManager==NULL)
      return true;
   const string symbol=::Symbol();
   const ENUM_TIMEFRAMES chart_tf=(ENUM_TIMEFRAMES)::Period();
   ENUM_TIMEFRAMES tfs[];
   int tf_count=m_SymbolTFManager.TimeframesOf(symbol,tfs);
   bool chart_listed=false;
   for(int i=0;i<tf_count;i++)
      chart_listed|=(tfs[i]==chart_tf);
   if(!chart_listed)
     {
      ::ArrayResize(tfs,tf_count+1);
      int at=tf_count++;
      while(at>0 && tfs[at-1]>chart_tf)   // tf_enum grows with the duration
        {
         tfs[at]=tfs[at-1];
         at--;
        }
      tfs[at]=chart_tf;
     }
   int first_tf_button=(tf_count!=1) ? 1 : 0;   // "All" when there are 2+ TFs
   bool created=(m_btngroup_tf_switch.ButtonsTotal()>0);
   bool was_all_selected=(created && m_btngroup_tf_switch.SelectedButtonText()=="All");
   bool buttons_match=(created && m_btngroup_tf_switch.ButtonsTotal()==tf_count+first_tf_button);
   if(buttons_match && first_tf_button==1)
      buttons_match=(m_btngroup_tf_switch.GetButtonPointer(0).Text()=="All");
   for(int i=0;i<tf_count && buttons_match;i++)
      buttons_match=(m_btngroup_tf_switch.ButtonValue(i+first_tf_button)==(long)tfs[i]);
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
        {
         m_btngroup_tf_switch.AddButton((i+first_tf_button)*(M_TF_WITHOUT_ICON_WIDTH+M_CONTROL_BORDER_GAP),0,m_SymbolTFManager.TimeframeName(tfs[i]),M_TF_WITHOUT_ICON_WIDTH);
         m_btngroup_tf_switch.ButtonValue(i+first_tf_button,(long)tfs[i]);   // the button stands for its tf_enum, "All" stands for PERIOD_CURRENT (0)
        }
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
      if(tfs[i]==chart_tf && m_btngroup_tf_switch.SelectedButtonIndex()!=i+first_tf_button)
         m_btngroup_tf_switch.SelectButton(i+first_tf_button);
   return true;
  }
 //+------------------------------------------------------------------+
 //| The TF picked in the TF switch, "All" = PERIOD_CURRENT           |
 //+------------------------------------------------------------------+
 ENUM_TIMEFRAMES CGUIPannel::GetTFSwitchSelection(void)
  {
   return (ENUM_TIMEFRAMES)m_btngroup_tf_switch.SelectedButtonValue();
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
   //--- Equity icons: arrow up, arrow down, gray
   CLabel *equity_item=m_status_bar.GetItemPointer(STATUS_BAR_EQUITY);
   equity_item.AddImagesGroup(2,3);
   equity_item.AddImage(0,IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_UP_PNG);
   equity_item.AddImage(0,IMAGE_RESOURCE_BMP16_ICONS8_RIGHT_DOWN_PNG);
   equity_item.AddImage(0,IMAGE_RESOURCE_BMP16_CIRCLE_GRAY_BMP);
   equity_item.ChangeImage(0,2);
   equity_item.LabelXGap(22);   // the text after the 16 px icon at x=2
   return(true);
  }
 //+------------------------------------------------------------------+
 //| Symbol of the chart and its spread in points, set when it changed|
 //+------------------------------------------------------------------+
 //--- Change from V3 GUIPannel_MainWindows.mqh: the spread is Ask - Bid of the tick of now (SymbolInfoTick) until CSymbol is ported (one spread)
 void CGUIPannel::UpdateStatusBar_SymbolSpread(void)
  {
   MqlTick tick;
   double point=::SymbolInfoDouble(::Symbol(),SYMBOL_POINT);
   if(!::SymbolInfoTick(::Symbol(),tick) || point<=0)
      return;
   string text=::Symbol()+" spread: "+(string)(int)::MathRound((tick.ask-tick.bid)/point)+" pts";
   if(m_status_bar.GetItemPointer(STATUS_BAR_SYMBOL_SPREAD).Text()!=text)
      m_status_bar.SetValue(STATUS_BAR_SYMBOL_SPREAD,text);
  }
 //+------------------------------------------------------------------+
 //| The equity of the current account, set when it changed           |
 //+------------------------------------------------------------------+
 //--- Change from V3: the arrow follows the reason of the event of the equity (Balance + Profit: it moves with the positions) (ENUM_BASE_EVENT_REASON), not the flags of the last refresh
 void CGUIPannel::UpdateStatusBar_Equity(const int reason=WRONG_VALUE)
  {
   if(m_AccountsCollection==NULL)
      return;
   CAccount *account=m_AccountsCollection.GetCurrentAccount();
   if(account==NULL)
      return;
   string text="Equity: "+::DoubleToString(account.Equity(),(int)account.CurrencyDigits())+" "+account.Currency();
   CLabel *item=m_status_bar.GetItemPointer(STATUS_BAR_EQUITY);
   //--- Up, down, gray: gray (black text) when the equity is the balance (no floating profit), the last move of a closed position stays nowhere
   bool flat=(::NormalizeDouble(account.Equity()-account.Balance(),2)==0);
   if(item.Text()==text && !flat)
      return;
   int image=(flat ? 2 : reason==BASE_EVENT_REASON_INC ? 0 : reason==BASE_EVENT_REASON_DEC ? 1 : 2);
   item.ChangeImage(0,image);
   //--- The text takes the color of the arrow: green up, red down, black for the first text and when flat
   color clr=(image==0 ? M_COLOR_PROFIT : image==1 ? M_COLOR_LOSS : clrBlack);
   item.GetForeColorControl().InitColors(clr,clr,clr,clr);
   item.ColorChange(COLOR_STATE_DEFAULT);
   m_status_bar.SetValue(STATUS_BAR_EQUITY,text);
  }
 // For Main Tabs m_tabs_main below the TF switch of Main Window m_window_main
 //+------------------------------------------------------------------+
 //| The tabs of the window: an icon each, no text                    |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTab_Main(const int x_gap,const int y_gap)
  {
   //--- Properties
   m_tabs_main.PositionMode(TABS_TOP);
   m_tabs_main.TabsYSize(M_TAB_MAIN_HEIGHT);
   m_tabs_main.TabsGap(M_CONTROL_BORDER_GAP);   // the icons are a gap apart,
   m_tabs_main.TabsAlign(ALIGN_CENTER);        // in the middle of the window
   m_tabs_main.AutoXResizeMode(true);
   m_tabs_main.AutoYResizeMode(true);
   m_tabs_main.AutoXResizeRightOffset(3);
   m_tabs_main.AutoYResizeBottomOffset(25);
   //--- Add tabs with the specified properties: an icon each, no text
   for(int i=0;i<TAB_TAB_MAIN_TOTAL;i++)
      m_tabs_main.AddTab("",M_ICON32_WIDTH);
   //--- Create Tab before create other control element inside
   m_window_main.AddChild(&m_tabs_main);
   if(!m_tabs_main.CreateTabs(this.m_chart_id,M_SUBWINDOW_MAIN,"TabsMain",x_gap,y_gap))
      return(false);
   //--- The icon of each tab, in the order of ENUM_TAB_MAIN
   uint tab_icons[TAB_TAB_MAIN_TOTAL]={IMAGE_RESOURCE_BMP32_MAINPANNEL_PNG,IMAGE_RESOURCE_BMP32_SETTING_PNG};
   for(int i=0;i<TAB_TAB_MAIN_TOTAL;i++)
     {
      CButtonTriggered *button=m_tabs_main.GetButtonsGroupPointer().GetButtonPointer(i);
      button.IconFile(tab_icons[i]);
      button.IconFileLocked(tab_icons[i]);
      button.IconFilePressed(tab_icons[i]);
      button.IconFilePressedLocked(tab_icons[i]);
      button.Draw(false);
     }
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
#endif // __GUIPANNEL_WINDOW_MAIN_MQH__
