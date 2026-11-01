//+------------------------------------------------------------------+
//|                          GUIPannel_TabQuickSetting_SmartMoney.mqh |
//| Smart Money tab of m_tabs_quickSetting                           |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABQUICKSETTING_SMARTMONEY_MQH
#define CGUIPANNEL_TABQUICKSETTING_SMARTMONEY_MQH
#include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| A section: a header (the arrow, the name, the toggle). The  |
 //| controls of its body come with AddSectionBody; the arrow closes   |
 //| and opens the body and the sections under it move                 |
 //+------------------------------------------------------------------+
 //--- The header (the arrow and the name) and, when toggle is not NULL, the toggle (ON / OFF) of a section of a tab of the tabs
 bool CGUIPannel::CreateSectionHeader(CButtonTriggered &header,CButtonTriggered *toggle,const string name,const bool on,const bool opened,
                                      CTabs &tabs,const int tab,const string key)
  {
   header.SetText(name);
   header.IconFile(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);
   header.IconFileLocked(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP);
   header.IconFilePressed(IMAGE_RESOURCE_BMP16_ARROWDOWN_BLUE_BMP);
   header.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_ARROWDOWN_BLUE_BMP);
   header.SetState(opened);
   tabs.AddToElementsArray(tab,header);
   if(!header.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnSectionHeader"+key,0,0,M_SECTION_HEADER_WIDTH,M_CONTROL_HEIGHT))
      return false;
   if(toggle!=NULL)
     {
      toggle.SetText(on ? "ON" : "OFF");
      toggle.IconFile(IMAGE_RESOURCE_BMP16_SWITCH_OFF_RED_PNG);
      toggle.IconFileLocked(IMAGE_RESOURCE_BMP16_SWITCH_OFF_RED_PNG);
      toggle.IconFilePressed(IMAGE_RESOURCE_BMP16_SWITCH_ON_GREEN_PNG);
      toggle.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_SWITCH_ON_GREEN_PNG);
      toggle.SetState(on);
      tabs.AddToElementsArray(tab,toggle);
      if(!toggle.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnSectionToggle"+key,0,0,M_SECTION_TOGGLE_WIDTH,M_CONTROL_HEIGHT))
         return false;
     }
   //--- No border, only the colour of the hover and of the press (the colours are set after Create: it gives the default ones)
   CButtonTriggered *buttons[2];
   buttons[0]=GetPointer(header);
   buttons[1]=toggle;
   for(int i=0;i<2;i++)
     {
      if(buttons[i]==NULL)
         continue;
      buttons[i].GetBackColorControl().InitColors(clrNONE,C'229,241,251',C'204,228,247',clrNONE);
      buttons[i].GetBackColorActControl().InitColors(clrNONE,C'229,241,251',C'204,228,247',clrNONE);
      buttons[i].GetBorderColorControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
      buttons[i].GetBorderColorActControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
      buttons[i].ColorChange(COLOR_STATE_DEFAULT);
      buttons[i].Draw(false);
     }
   return true;
  }
 //--- A switch (ON / OFF, the icons of the toggles of the sections) in a parent: x, y are in the parent
 bool CGUIPannel::CreateSwitch(CButtonTriggered &toggle,const bool on,CGElement &parent,const string name,const int x,const int y)
  {
   toggle.SetText(on ? "ON" : "OFF");
   toggle.IconFile(IMAGE_RESOURCE_BMP16_SWITCH_OFF_RED_PNG);
   toggle.IconFileLocked(IMAGE_RESOURCE_BMP16_SWITCH_OFF_RED_PNG);
   toggle.IconFilePressed(IMAGE_RESOURCE_BMP16_SWITCH_ON_GREEN_PNG);
   toggle.IconFilePressedLocked(IMAGE_RESOURCE_BMP16_SWITCH_ON_GREEN_PNG);
   toggle.SetState(on);
   parent.AddChild(&toggle);
   if(!toggle.Create(this.m_chart_id,M_SUBWINDOW_MAIN,name,x,y,M_SECTION_TOGGLE_WIDTH,M_CONTROL_HEIGHT))
      return false;
   toggle.GetBackColorControl().InitColors(clrNONE,C'229,241,251',C'204,228,247',clrNONE);
   toggle.GetBackColorActControl().InitColors(clrNONE,C'229,241,251',C'204,228,247',clrNONE);
   toggle.GetBorderColorControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
   toggle.GetBorderColorActControl().InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
   toggle.ColorChange(COLOR_STATE_DEFAULT);
   toggle.Draw(false);
   return true;
  }
 bool CGUIPannel::CreateSection(const ENUM_SMART_MONEY_SECTION section,const string name,const bool on,const bool opened)
  {
   if(!CreateSectionHeader(m_btn_section_header[section],GetPointer(m_btn_section_toggle[section]),name,on,opened,m_tabs_quickSetting,TAB_QUICK_SETTING_SMART_MONEY,(string)section))
      return false;
   m_section_body_total[section]=0;
   m_section_rows[section]=0;
   return true;
  }
 //--- A control of the body: its place is a column (0 or 1) and a row; the tab shows and hides it with its other children
 void CGUIPannel::AddSectionBody(const ENUM_SMART_MONEY_SECTION section,CGElement &control,const int column,const int row)
  {
   int n=m_section_body_total[section];
   if(n>=SMART_MONEY_BODY_MAX)
      return;
   int i=section*SMART_MONEY_BODY_MAX+n;
   m_section_body[i]=GetPointer(control);
   m_section_body_x[i]=column*M_SECTION_COLUMN_WIDTH;
   m_section_body_row[i]=row;
   m_section_body_total[section]=n+1;
   if(row+1>m_section_rows[section])
      m_section_rows[section]=row+1;
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_SMART_MONEY,control);
  }
 //--- The sections one under the other, from the top of the tab, moved up by the scroll: a closed one takes its header only, what is out of the tab is hidden
 void CGUIPannel::ArrangeSections_SmartMoney(void)
  {
   if(m_first_start || m_tabs_quickSetting.SelectedTab()!=TAB_QUICK_SETTING_SMART_MONEY)
      return;
   const int x=m_tabs_quickSetting.X()+M_CONTROL_BORDER_GAP;
   const int tab_top=m_tabs_quickSetting.Y();
   const int top=tab_top+M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;   // the sections are under the Save button
   const int bottom=tab_top+m_tabs_quickSetting.Height()-M_CONTROL_BORDER_GAP;
   m_btn_save_smartmoney.Move(m_tabs_quickSetting.X()+m_tabs_quickSetting.Width()-M_BUTTON_SAVE_WIDTH-M_CONTROL_BORDER_GAP,tab_top+M_CONTROL_BORDER_GAP);
   m_btn_save_smartmoney.Show();
   //--- The height of all the sections: the scroll gets it in rows
   int total_h=M_CONTROL_BORDER_GAP;
   for(int s=0;s<SMART_MONEY_SECTION_TOTAL;s++)
     {
      total_h+=M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
      if(m_btn_section_header[s].State())
         total_h+=m_section_rows[s]*M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
     }
   m_scroll_smart_money.ChangeYSize(::MathMax(bottom-top-M_CONTROL_BORDER_GAP,1));
   m_scroll_smart_money.Move(m_tabs_quickSetting.X()+m_tabs_quickSetting.Width()-m_scroll_smart_money.ScrollWidth()-1,top+1);
   m_scroll_smart_money.ChangeThumbSize((total_h+M_CONTROL_HEIGHT-1)/M_CONTROL_HEIGHT,::MathMax((bottom-top)/M_CONTROL_HEIGHT,1));
   if(m_scroll_smart_money.IsScroll())
      m_scroll_smart_money.Show();
   else
      m_scroll_smart_money.Hide();
   int y=top+M_CONTROL_BORDER_GAP-m_scroll_smart_money.CurrentPos()*M_CONTROL_HEIGHT;
   for(int s=0;s<SMART_MONEY_SECTION_TOTAL;s++)
     {
      bool in_view=(y>=top && y+M_CONTROL_HEIGHT<=bottom);
      m_btn_section_header[s].Move(x,y);
      m_btn_section_toggle[s].Move(x+M_SECTION_HEADER_WIDTH+M_CONTROL_BORDER_GAP,y);
      if(in_view)
        {
         m_btn_section_header[s].Show();
         m_btn_section_toggle[s].Show();
        }
      else
        {
         m_btn_section_header[s].Hide();
         m_btn_section_toggle[s].Hide();
        }
      y+=M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
      bool opened=m_btn_section_header[s].State();
      for(int k=0;k<m_section_body_total[s];k++)
        {
         int i=s*SMART_MONEY_BODY_MAX+k;
         int yc=y+m_section_body_row[i]*M_CONTROL_HEIGHT;
         if(opened && yc>=top && yc+M_CONTROL_HEIGHT<=bottom)
           {
            m_section_body[i].Move(x+M_SECTION_BODY_INDENT+m_section_body_x[i],yc);
            m_section_body[i].Show();
           }
         else
            m_section_body[i].Hide();
        }
      if(opened)
         y+=m_section_rows[s]*M_CONTROL_HEIGHT+M_CONTROL_BORDER_GAP;
     }
   ::ChartRedraw(this.m_chart_id);
  }
 //--- The toggle of a section: ON when any Show of the section is on
 bool CGUIPannel::SectionOn(const ENUM_SMART_MONEY_SECTION section) const
  {
   switch(section)
     {
      case SMART_MONEY_SECTION_SWING:           return(m_SwingSetting!=NULL && (m_SwingSetting.SignalShow(SWING_TYPE_HIGH) || m_SwingSetting.SignalShow(SWING_TYPE_LOW)));
      case SMART_MONEY_SECTION_STRUCTURE:       return(m_StructureSetting!=NULL && (m_StructureSetting.SignalShow(MARKET_STRUCTURE_BOS) || m_StructureSetting.SignalShow(MARKET_STRUCTURE_CHOCH)));
      case SMART_MONEY_SECTION_FVG:             return(m_FvgSetting!=NULL && (m_FvgSetting.ShowBullish() || m_FvgSetting.ShowBearish() || m_FvgSetting.ShowDead()));
      case SMART_MONEY_SECTION_MOMENTUM_CANDLE: return(m_MomentumCandleSetting!=NULL && m_MomentumCandleSetting.Show());
      case SMART_MONEY_SECTION_SUPPLY_DEMAND:   return(m_SupplyDemandSetting!=NULL && (m_SupplyDemandSetting.ShowDemand() || m_SupplyDemandSetting.ShowSupply() || m_SupplyDemandSetting.ShowDead()));
      case SMART_MONEY_SECTION_TRENDLINE:       return(m_TrendlineSetting!=NULL && (m_TrendlineSetting.ShowSupport() || m_TrendlineSetting.ShowResistance() || m_TrendlineSetting.ShowDead()));
      case SMART_MONEY_SECTION_SUPPORT_RESISTANCE: return(m_SupportResistanceSetting!=NULL && (m_SupportResistanceSetting.ShowSupport() || m_SupportResistanceSetting.ShowResistance() || m_SupportResistanceSetting.ShowDead()));
      case SMART_MONEY_SECTION_MOVEMENT:        return(m_story_setting!=NULL && (m_story_setting.ShowMoves() || m_story_setting.ShowUnclassified()));
      default: return(false);
     }
  }
 //--- The toggle sets every Show of its section and the boxes follow
 void CGUIPannel::SectionSet(const ENUM_SMART_MONEY_SECTION section,const bool on)
  {
   switch(section)
     {
      case SMART_MONEY_SECTION_SWING:
         if(m_SwingSetting!=NULL)
           {
            m_SwingSetting.SignalShow(SWING_TYPE_HIGH,on);
            m_SwingSetting.SignalShow(SWING_TYPE_LOW,on);
           }
         m_check_swing_high.SetState(on);
         m_check_swing_low.SetState(on);
         break;
      case SMART_MONEY_SECTION_STRUCTURE:
         if(m_StructureSetting!=NULL)
           {
            m_StructureSetting.SignalShow(MARKET_STRUCTURE_BOS,on);
            m_StructureSetting.SignalShow(MARKET_STRUCTURE_CHOCH,on);
           }
         m_check_structure_bos.SetState(on);
         m_check_structure_choch.SetState(on);
         break;
      case SMART_MONEY_SECTION_FVG:
         if(m_FvgSetting!=NULL)
           {
            m_FvgSetting.ShowBullish(on);
            m_FvgSetting.ShowBearish(on);
            m_FvgSetting.ShowDead(on);
           }
         m_check_fvg_bullish.SetState(on);
         m_check_fvg_bearish.SetState(on);
         m_check_fvg_dead.SetState(on);
         break;
      case SMART_MONEY_SECTION_MOMENTUM_CANDLE:
         if(m_MomentumCandleSetting!=NULL)
            m_MomentumCandleSetting.Show(on);
         break;
      case SMART_MONEY_SECTION_SUPPLY_DEMAND:
         if(m_SupplyDemandSetting!=NULL)
           {
            m_SupplyDemandSetting.ShowDemand(on);
            m_SupplyDemandSetting.ShowSupply(on);
            m_SupplyDemandSetting.ShowDead(on);
           }
         m_check_sd_demand.SetState(on);
         m_check_sd_supply.SetState(on);
         m_check_sd_dead.SetState(on);
         break;
      case SMART_MONEY_SECTION_TRENDLINE:
         if(m_TrendlineSetting!=NULL)
           {
            m_TrendlineSetting.ShowSupport(on);
            m_TrendlineSetting.ShowResistance(on);
            m_TrendlineSetting.ShowDead(on);
           }
         m_check_tl_support.SetState(on);
         m_check_tl_resistance.SetState(on);
         m_check_tl_dead.SetState(on);
         break;
      case SMART_MONEY_SECTION_SUPPORT_RESISTANCE:
         if(m_SupportResistanceSetting!=NULL)
           {
            m_SupportResistanceSetting.ShowSupport(on);
            m_SupportResistanceSetting.ShowResistance(on);
            m_SupportResistanceSetting.ShowDead(on);
           }
         m_check_sr_support.SetState(on);
         m_check_sr_resistance.SetState(on);
         m_check_sr_dead.SetState(on);
         break;
      case SMART_MONEY_SECTION_MOVEMENT:
         if(m_story_setting!=NULL)
           {
            m_story_setting.ShowMoves(on);
            m_story_setting.ShowUnclassified(on);
           }
         m_check_move_show.SetState(on);
         m_check_move_unclassified.SetState(on);
         break;
      default: break;
     }
  }
 //--- A box was ticked: the toggle of its section shows ON when any Show is on
 void CGUIPannel::UpdateSectionToggles(void)
  {
   for(int s=0;s<SMART_MONEY_SECTION_TOTAL;s++)
     {
      bool on=this.SectionOn((ENUM_SMART_MONEY_SECTION)s);
      if(m_btn_section_toggle[s].State()==on)
         continue;
      m_btn_section_toggle[s].SetState(on);
      m_btn_section_toggle[s].SetText(on ? "ON" : "OFF");
      m_btn_section_toggle[s].Draw(true);
     }
  }
 //+------------------------------------------------------------------+
 //| The sections of the Smart Money tab and the controls of each body |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateSections_SmartMoney(const int x,const int y)
  {
   const int box_w=M_SECTION_COLUMN_WIDTH-M_CONTROL_BORDER_GAP;   // a check box and a number box are as wide, the text of both starts at the same x
   //--- Swing: the bars and the wicks in a row, the highs and the lows in a row
   if(!CreateSection(SMART_MONEY_SECTION_SWING,"Swing",SectionOn(SMART_MONEY_SECTION_SWING),false))
      return false;
   m_edit_swing_strength.SetText("Strength (bars)");
   m_edit_swing_strength.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_SWING,m_edit_swing_strength,0,0);
   if(!m_edit_swing_strength.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditSwingStrength",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_swing_strength.SetValue((string)((m_SwingSetting!=NULL) ? m_SwingSetting.Strength() : 5));
   m_check_swing_wick.SetText("Use wicks");
   m_check_swing_wick.SetState(m_SwingSetting!=NULL && m_SwingSetting.PriceBasis()==SWING_PRICE_BASIS_WICK);
   AddSectionBody(SMART_MONEY_SECTION_SWING,m_check_swing_wick,1,0);
   if(!m_check_swing_wick.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckSwingWick",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_check_swing_high.SetText("Show Swing Highs");
   m_check_swing_high.SetState(m_SwingSetting!=NULL && m_SwingSetting.SignalShow(SWING_TYPE_HIGH));
   AddSectionBody(SMART_MONEY_SECTION_SWING,m_check_swing_high,0,1);
   if(!m_check_swing_high.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckSwingHigh",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_check_swing_low.SetText("Show Swing Lows");
   m_check_swing_low.SetState(m_SwingSetting!=NULL && m_SwingSetting.SignalShow(SWING_TYPE_LOW));
   AddSectionBody(SMART_MONEY_SECTION_SWING,m_check_swing_low,1,1);
   if(!m_check_swing_low.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckSwingLow",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   //--- Market Structure: the BOS and the CHoCH in a row
   if(!CreateSection(SMART_MONEY_SECTION_STRUCTURE,"BOS / CHoCH",SectionOn(SMART_MONEY_SECTION_STRUCTURE)))
      return false;
   m_check_structure_bos.SetText("Show BOS");
   m_check_structure_bos.SetState(m_StructureSetting!=NULL && m_StructureSetting.SignalShow(MARKET_STRUCTURE_BOS));
   AddSectionBody(SMART_MONEY_SECTION_STRUCTURE,m_check_structure_bos,0,0);
   if(!m_check_structure_bos.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckStructureBos",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_check_structure_choch.SetText("Show CHoCH");
   m_check_structure_choch.SetState(m_StructureSetting!=NULL && m_StructureSetting.SignalShow(MARKET_STRUCTURE_CHOCH));
   AddSectionBody(SMART_MONEY_SECTION_STRUCTURE,m_check_structure_choch,1,0);
   if(!m_check_structure_choch.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckStructureChoch",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   //--- Fair value gap: the bullish and the bearish in a row, the filled ones and how many are kept in a row
   if(!CreateSection(SMART_MONEY_SECTION_FVG,"FVG",SectionOn(SMART_MONEY_SECTION_FVG)))
      return false;
   m_check_fvg_bullish.SetText("Show bullish FVG");
   m_check_fvg_bullish.SetState(m_FvgSetting!=NULL && m_FvgSetting.ShowBullish());
   AddSectionBody(SMART_MONEY_SECTION_FVG,m_check_fvg_bullish,0,0);
   if(!m_check_fvg_bullish.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckFvgBullish",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_check_fvg_bearish.SetText("Show bearish FVG");
   m_check_fvg_bearish.SetState(m_FvgSetting!=NULL && m_FvgSetting.ShowBearish());
   AddSectionBody(SMART_MONEY_SECTION_FVG,m_check_fvg_bearish,1,0);
   if(!m_check_fvg_bearish.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckFvgBearish",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_check_fvg_dead.SetText("Show dead FVG");
   m_check_fvg_dead.SetState(m_FvgSetting!=NULL && m_FvgSetting.ShowDead());
   AddSectionBody(SMART_MONEY_SECTION_FVG,m_check_fvg_dead,0,1);
   if(!m_check_fvg_dead.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckFvgDead",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_edit_fvg_maxdead.SetText("Max dead");
   m_edit_fvg_maxdead.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_FVG,m_edit_fvg_maxdead,1,1);
   if(!m_edit_fvg_maxdead.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditFvgMaxDead",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_fvg_maxdead.SetValue((string)((m_FvgSetting!=NULL) ? m_FvgSetting.MaxDead() : 5));
   m_edit_fvg_open_bullish.SetText("Open bullish");
   m_edit_fvg_open_bullish.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_FVG,m_edit_fvg_open_bullish,0,2);
   if(!m_edit_fvg_open_bullish.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditFvgOpenBullish",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_fvg_open_bullish.SetValue((string)((m_FvgSetting!=NULL) ? m_FvgSetting.OpenNewestBullish() : 3));
   m_edit_fvg_open_bearish.SetText("Open bearish");
   m_edit_fvg_open_bearish.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_FVG,m_edit_fvg_open_bearish,1,2);
   if(!m_edit_fvg_open_bearish.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditFvgOpenBearish",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_fvg_open_bearish.SetValue((string)((m_FvgSetting!=NULL) ? m_FvgSetting.OpenNewestBearish() : 3));
   //--- Momentum candle: the candles before it and the multiplier in a row; the toggle of the header shows and hides the markers
   if(!CreateSection(SMART_MONEY_SECTION_MOMENTUM_CANDLE,"Momentum candle",SectionOn(SMART_MONEY_SECTION_MOMENTUM_CANDLE)))
      return false;
   m_edit_momentum_bars.SetText("Candles before");
   m_edit_momentum_bars.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_MOMENTUM_CANDLE,m_edit_momentum_bars,0,0);
   if(!m_edit_momentum_bars.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditMomentumBars",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_momentum_bars.SetValue((string)((m_MomentumCandleSetting!=NULL) ? m_MomentumCandleSetting.Bars() : 3));
   m_edit_momentum_multiplier.SetText("Body bigger x");
   m_edit_momentum_multiplier.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_MOMENTUM_CANDLE,m_edit_momentum_multiplier,1,0);
   if(!m_edit_momentum_multiplier.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditMomentumMultiplier",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_momentum_multiplier.SetValue(::DoubleToString((m_MomentumCandleSetting!=NULL) ? m_MomentumCandleSetting.Multiplier() : 2.0,2));
   //--- Supply and demand: the demand and the supply in a row, the filled ones and how many are kept in a row
   if(!CreateSection(SMART_MONEY_SECTION_SUPPLY_DEMAND,"Supply / Demand",SectionOn(SMART_MONEY_SECTION_SUPPLY_DEMAND)))
      return false;
   m_check_sd_demand.SetText("Show demand zones");
   m_check_sd_demand.SetState(m_SupplyDemandSetting!=NULL && m_SupplyDemandSetting.ShowDemand());
   AddSectionBody(SMART_MONEY_SECTION_SUPPLY_DEMAND,m_check_sd_demand,0,0);
   if(!m_check_sd_demand.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckSdDemand",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_check_sd_supply.SetText("Show supply zones");
   m_check_sd_supply.SetState(m_SupplyDemandSetting!=NULL && m_SupplyDemandSetting.ShowSupply());
   AddSectionBody(SMART_MONEY_SECTION_SUPPLY_DEMAND,m_check_sd_supply,1,0);
   if(!m_check_sd_supply.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckSdSupply",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_check_sd_dead.SetText("Show dead zones");
   m_check_sd_dead.SetState(m_SupplyDemandSetting!=NULL && m_SupplyDemandSetting.ShowDead());
   AddSectionBody(SMART_MONEY_SECTION_SUPPLY_DEMAND,m_check_sd_dead,0,1);
   if(!m_check_sd_dead.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckSdDead",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_edit_sd_maxdead.SetText("Max dead");
   m_edit_sd_maxdead.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_SUPPLY_DEMAND,m_edit_sd_maxdead,1,1);
   if(!m_edit_sd_maxdead.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditSdMaxDead",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_sd_maxdead.SetValue((string)((m_SupplyDemandSetting!=NULL) ? m_SupplyDemandSetting.MaxDead() : 20));
   m_edit_sd_open_demand.SetText("Open demand");
   m_edit_sd_open_demand.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_SUPPLY_DEMAND,m_edit_sd_open_demand,0,2);
   if(!m_edit_sd_open_demand.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditSdOpenDemand",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_sd_open_demand.SetValue((string)((m_SupplyDemandSetting!=NULL) ? m_SupplyDemandSetting.OpenNewestDemand() : 3));
   m_edit_sd_open_supply.SetText("Open supply");
   m_edit_sd_open_supply.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_SUPPLY_DEMAND,m_edit_sd_open_supply,1,2);
   if(!m_edit_sd_open_supply.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditSdOpenSupply",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_sd_open_supply.SetValue((string)((m_SupplyDemandSetting!=NULL) ? m_SupplyDemandSetting.OpenNewestSupply() : 3));
   //--- Trendline: the supports and the resistances in a row, the dead ones and how many are kept in a row, the nearest lines drawn solid
   if(!CreateSection(SMART_MONEY_SECTION_TRENDLINE,"Trendline",SectionOn(SMART_MONEY_SECTION_TRENDLINE),false))
      return false;
   m_check_tl_support.SetText("Show support");
   m_check_tl_support.SetState(m_TrendlineSetting!=NULL && m_TrendlineSetting.ShowSupport());
   AddSectionBody(SMART_MONEY_SECTION_TRENDLINE,m_check_tl_support,0,0);
   if(!m_check_tl_support.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckTlSupport",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_check_tl_resistance.SetText("Show resistance");
   m_check_tl_resistance.SetState(m_TrendlineSetting!=NULL && m_TrendlineSetting.ShowResistance());
   AddSectionBody(SMART_MONEY_SECTION_TRENDLINE,m_check_tl_resistance,1,0);
   if(!m_check_tl_resistance.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckTlResistance",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_check_tl_dead.SetText("Show dead lines");
   m_check_tl_dead.SetState(m_TrendlineSetting!=NULL && m_TrendlineSetting.ShowDead());
   AddSectionBody(SMART_MONEY_SECTION_TRENDLINE,m_check_tl_dead,0,1);
   if(!m_check_tl_dead.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckTlDead",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_edit_tl_maxdead.SetText("Max dead");
   m_edit_tl_maxdead.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_TRENDLINE,m_edit_tl_maxdead,1,1);
   if(!m_edit_tl_maxdead.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditTlMaxDead",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_tl_maxdead.SetValue((string)((m_TrendlineSetting!=NULL) ? m_TrendlineSetting.MaxDead() : 20));
   m_edit_tl_nearest.SetText("Nearest solid");
   m_edit_tl_nearest.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_TRENDLINE,m_edit_tl_nearest,0,2);
   if(!m_edit_tl_nearest.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditTlNearest",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_tl_nearest.SetValue((string)((m_TrendlineSetting!=NULL) ? m_TrendlineSetting.Nearest() : 3));
   m_edit_tl_swings_tried.SetText("Swings tried");
   m_edit_tl_swings_tried.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_TRENDLINE,m_edit_tl_swings_tried,1,2);
   if(!m_edit_tl_swings_tried.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditTlSwingsTried",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_tl_swings_tried.SetValue((string)((m_TrendlineSetting!=NULL) ? m_TrendlineSetting.SwingsTried() : 0));
   m_edit_tl_confirm_atr.SetText("Break (ATR)");
   m_edit_tl_confirm_atr.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_TRENDLINE,m_edit_tl_confirm_atr,0,3);
   if(!m_edit_tl_confirm_atr.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditTlConfirmAtr",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_tl_confirm_atr.SetValue(::DoubleToString((m_TrendlineSetting!=NULL) ? m_TrendlineSetting.ConfirmATR() : 1.0,2));
   m_edit_tl_confirm_closes.SetText("Closes to confirm");
   m_edit_tl_confirm_closes.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_TRENDLINE,m_edit_tl_confirm_closes,1,3);
   if(!m_edit_tl_confirm_closes.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditTlConfirmCloses",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_tl_confirm_closes.SetValue((string)((m_TrendlineSetting!=NULL) ? m_TrendlineSetting.ConfirmCloses() : 0));
   m_edit_tl_min_move.SetText("Min move (ATR)");
   m_edit_tl_min_move.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_TRENDLINE,m_edit_tl_min_move,0,4);
   if(!m_edit_tl_min_move.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditTlMinMove",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_tl_min_move.SetValue(::DoubleToString((m_TrendlineSetting!=NULL) ? m_TrendlineSetting.MinMoveATR() : 0.2,2));
   m_edit_tl_min_swing.SetText("Min swing (ATR)");
   m_edit_tl_min_swing.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_TRENDLINE,m_edit_tl_min_swing,1,4);
   if(!m_edit_tl_min_swing.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditTlMinSwing",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_tl_min_swing.SetValue(::DoubleToString((m_TrendlineSetting!=NULL) ? m_TrendlineSetting.MinSwingATR() : 0.8,2));
   //--- Support / Resistance zone: the supports and the resistances in a row, the dead ones and how many are kept in a row, the newest ones shown in a row
   if(!CreateSection(SMART_MONEY_SECTION_SUPPORT_RESISTANCE,"Support / Resistance",SectionOn(SMART_MONEY_SECTION_SUPPORT_RESISTANCE),false))
      return false;
   m_check_sr_support.SetText("Show support");
   m_check_sr_support.SetState(m_SupportResistanceSetting!=NULL && m_SupportResistanceSetting.ShowSupport());
   AddSectionBody(SMART_MONEY_SECTION_SUPPORT_RESISTANCE,m_check_sr_support,0,0);
   if(!m_check_sr_support.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckSrSupport",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_check_sr_resistance.SetText("Show resistance");
   m_check_sr_resistance.SetState(m_SupportResistanceSetting!=NULL && m_SupportResistanceSetting.ShowResistance());
   AddSectionBody(SMART_MONEY_SECTION_SUPPORT_RESISTANCE,m_check_sr_resistance,1,0);
   if(!m_check_sr_resistance.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckSrResistance",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_check_sr_dead.SetText("Show dead zones");
   m_check_sr_dead.SetState(m_SupportResistanceSetting!=NULL && m_SupportResistanceSetting.ShowDead());
   AddSectionBody(SMART_MONEY_SECTION_SUPPORT_RESISTANCE,m_check_sr_dead,0,1);
   if(!m_check_sr_dead.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckSrDead",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_edit_sr_maxdead.SetText("Max dead");
   m_edit_sr_maxdead.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_SUPPORT_RESISTANCE,m_edit_sr_maxdead,1,1);
   if(!m_edit_sr_maxdead.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditSrMaxDead",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_sr_maxdead.SetValue((string)((m_SupportResistanceSetting!=NULL) ? m_SupportResistanceSetting.MaxDead() : 20));
   m_edit_sr_open_support.SetText("Open support");
   m_edit_sr_open_support.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_SUPPORT_RESISTANCE,m_edit_sr_open_support,0,2);
   if(!m_edit_sr_open_support.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditSrOpenSupport",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_sr_open_support.SetValue((string)((m_SupportResistanceSetting!=NULL) ? m_SupportResistanceSetting.OpenNewestSupport() : 3));
   m_edit_sr_open_resistance.SetText("Open resistance");
   m_edit_sr_open_resistance.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_SUPPORT_RESISTANCE,m_edit_sr_open_resistance,1,2);
   if(!m_edit_sr_open_resistance.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditSrOpenResistance",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_sr_open_resistance.SetValue((string)((m_SupportResistanceSetting!=NULL) ? m_SupportResistanceSetting.OpenNewestResistance() : 3));
   m_edit_sr_min_score.SetText("Min score");
   m_edit_sr_min_score.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_SUPPORT_RESISTANCE,m_edit_sr_min_score,0,3);
   if(!m_edit_sr_min_score.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditSrMinScore",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_sr_min_score.SetValue((string)((m_SupportResistanceSetting!=NULL) ? m_SupportResistanceSetting.MinScore() : 0));
   m_edit_sr_confirm_closes.SetText("Closes to confirm");
   m_edit_sr_confirm_closes.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_SUPPORT_RESISTANCE,m_edit_sr_confirm_closes,1,3);
   if(!m_edit_sr_confirm_closes.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditSrConfirmCloses",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_sr_confirm_closes.SetValue((string)((m_SupportResistanceSetting!=NULL) ? m_SupportResistanceSetting.ConfirmCloses() : 0));
   m_edit_sr_ghost_bars.SetText("Ghost bars");
   m_edit_sr_ghost_bars.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_SUPPORT_RESISTANCE,m_edit_sr_ghost_bars,0,4);
   if(!m_edit_sr_ghost_bars.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditSrGhostBars",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_sr_ghost_bars.SetValue((string)((m_SupportResistanceSetting!=NULL) ? m_SupportResistanceSetting.GhostBars() : 0));
   m_edit_sr_max_age.SetText("Max age (bars)");
   m_edit_sr_max_age.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_SUPPORT_RESISTANCE,m_edit_sr_max_age,1,4);
   if(!m_edit_sr_max_age.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditSrMaxAge",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_sr_max_age.SetValue((string)((m_SupportResistanceSetting!=NULL) ? m_SupportResistanceSetting.MaxAgeBars() : 0));
   m_edit_sr_volume_ma.SetText("Volume MA bars");
   m_edit_sr_volume_ma.LabelXGap(M_SECTION_TEXT_X);
   AddSectionBody(SMART_MONEY_SECTION_SUPPORT_RESISTANCE,m_edit_sr_volume_ma,0,5);
   if(!m_edit_sr_volume_ma.CreateTextEdit(this.m_chart_id,M_SUBWINDOW_MAIN,"EditSrVolumeMa",0,0,box_w,M_CONTROL_HEIGHT,M_SECTION_EDIT_FIELD_WIDTH))
      return false;
   m_edit_sr_volume_ma.SetValue((string)((m_SupportResistanceSetting!=NULL) ? m_SupportResistanceSetting.VolumeMABars() : 0));
   m_check_sr_revive.SetText("Revive broken");
   m_check_sr_revive.SetState(m_SupportResistanceSetting!=NULL && m_SupportResistanceSetting.Revive());
   AddSectionBody(SMART_MONEY_SECTION_SUPPORT_RESISTANCE,m_check_sr_revive,1,5);
   if(!m_check_sr_revive.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckSrRevive",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   //--- The legs between the Swings: the Impulses and the Pullbacks, and the legs of a Market Range too
   if(!CreateSection(SMART_MONEY_SECTION_MOVEMENT,"Impulse / Pullback",SectionOn(SMART_MONEY_SECTION_MOVEMENT)))
      return false;
   m_check_move_show.SetText("Show Impulse / Pullback legs");
   m_check_move_show.SetState(m_story_setting!=NULL && m_story_setting.ShowMoves());
   AddSectionBody(SMART_MONEY_SECTION_MOVEMENT,m_check_move_show,0,0);
   if(!m_check_move_show.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckMoveShow",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   m_check_move_unclassified.SetText("Show legs in Market Range too");
   m_check_move_unclassified.SetState(m_story_setting!=NULL && m_story_setting.ShowUnclassified());
   AddSectionBody(SMART_MONEY_SECTION_MOVEMENT,m_check_move_unclassified,1,0);
   if(!m_check_move_unclassified.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"CheckMoveUnclassified",0,0,box_w,M_CONTROL_HEIGHT))
      return false;
   //--- Save: the settings are applied and saved on its click
   m_btn_save_smartmoney.SetText("Save");
   m_btn_save_smartmoney.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_SMART_MONEY,m_btn_save_smartmoney);
   if(!m_btn_save_smartmoney.Create(this.m_chart_id,M_SUBWINDOW_MAIN,"BtnSaveSmartMoney",0,0,M_BUTTON_SAVE_WIDTH,M_CONTROL_HEIGHT))
      return false;
   //--- The scroll: a child of the tab, its size and place come with the sections
   m_tabs_quickSetting.AddToElementsArray(TAB_QUICK_SETTING_SMART_MONEY,m_scroll_smart_money);
   if(!m_scroll_smart_money.CreateScroll(this.m_chart_id,M_SUBWINDOW_MAIN,"ScrollSmartMoney",0,0,15,100,1,1))
      return false;
   return true;
  }
 //+------------------------------------------------------------------+
 //| What the user did in the Smart Money tab                         |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Tab_SmartMoney(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- The tab was opened: it showed its children, the closed sections hide their bodies again
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_TAB && lparam==m_tabs_quickSetting.ObjectID())
     {
      this.ArrangeSections_SmartMoney();
      return;
     }
   //--- The scroll moved, or the window changed its size: the sections follow
   if((id==CHARTEVENT_CUSTOM+ON_SCROLL_CHANGE && lparam==m_scroll_smart_money.ObjectID()) ||
      ((id==CHARTEVENT_CUSTOM+ON_WINDOW_CHANGE_XSIZE || id==CHARTEVENT_CUSTOM+ON_WINDOW_CHANGE_YSIZE) && lparam==m_window_main.ObjectID()))
     {
      this.ArrangeSections_SmartMoney();
      return;
     }
   if(id!=CHARTEVENT_CUSTOM+ON_CLICK_BUTTON && id!=CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX && id!=CHARTEVENT_CUSTOM+ON_END_EDIT)
      return;
   //--- A header: its body opens or closes and the sections under it move. A toggle: every Show of the section on or off, dparam = the new state
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      if(lparam==m_btn_save_smartmoney.ObjectID())
        {
         ::EventChartCustom(this.m_chart_id,(ushort)ON_SMARTMONEY_SETTING_SAVE,0,0.0,"");   // the EA saves and draws again
         return;
        }
      for(int s=0;s<SMART_MONEY_SECTION_TOTAL;s++)
        {
         if(lparam==m_btn_section_header[s].ObjectID())
           {
            this.ArrangeSections_SmartMoney();
            return;
           }
         if(lparam==m_btn_section_toggle[s].ObjectID())
           {
            this.SectionSet((ENUM_SMART_MONEY_SECTION)s,dparam!=0);
            m_btn_section_toggle[s].SetText(dparam!=0 ? "ON" : "OFF");
            m_btn_section_toggle[s].Draw(true);
            return;
           }
        }
      return;
     }
   //--- The check boxes, dparam = the new state
   bool on=(dparam!=0);
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX)
     {
      if(m_SwingSetting!=NULL)
        {
         if(lparam==m_check_swing_wick.ObjectID())
            m_SwingSetting.UseWick(on);
         else if(lparam==m_check_swing_high.ObjectID())
            m_SwingSetting.SignalShow(SWING_TYPE_HIGH,on);
         else if(lparam==m_check_swing_low.ObjectID())
            m_SwingSetting.SignalShow(SWING_TYPE_LOW,on);
        }
      if(m_StructureSetting!=NULL)
        {
         if(lparam==m_check_structure_bos.ObjectID())
            m_StructureSetting.SignalShow(MARKET_STRUCTURE_BOS,on);
         else if(lparam==m_check_structure_choch.ObjectID())
            m_StructureSetting.SignalShow(MARKET_STRUCTURE_CHOCH,on);
        }
      if(m_FvgSetting!=NULL)
        {
         if(lparam==m_check_fvg_bullish.ObjectID())
            m_FvgSetting.ShowBullish(on);
         else if(lparam==m_check_fvg_bearish.ObjectID())
            m_FvgSetting.ShowBearish(on);
         else if(lparam==m_check_fvg_dead.ObjectID())
            m_FvgSetting.ShowDead(on);
        }
      if(m_SupplyDemandSetting!=NULL)
        {
         if(lparam==m_check_sd_demand.ObjectID())
            m_SupplyDemandSetting.ShowDemand(on);
         else if(lparam==m_check_sd_supply.ObjectID())
            m_SupplyDemandSetting.ShowSupply(on);
         else if(lparam==m_check_sd_dead.ObjectID())
            m_SupplyDemandSetting.ShowDead(on);
        }
      if(m_TrendlineSetting!=NULL)
        {
         if(lparam==m_check_tl_support.ObjectID())
            m_TrendlineSetting.ShowSupport(on);
         else if(lparam==m_check_tl_resistance.ObjectID())
            m_TrendlineSetting.ShowResistance(on);
         else if(lparam==m_check_tl_dead.ObjectID())
            m_TrendlineSetting.ShowDead(on);
        }
      if(m_SupportResistanceSetting!=NULL)
        {
         if(lparam==m_check_sr_support.ObjectID())
            m_SupportResistanceSetting.ShowSupport(on);
         else if(lparam==m_check_sr_resistance.ObjectID())
            m_SupportResistanceSetting.ShowResistance(on);
         else if(lparam==m_check_sr_dead.ObjectID())
            m_SupportResistanceSetting.ShowDead(on);
         else if(lparam==m_check_sr_revive.ObjectID())
            m_SupportResistanceSetting.Revive(on);
        }
      if(m_story_setting!=NULL)
        {
         if(lparam==m_check_move_show.ObjectID())
            m_story_setting.ShowMoves(on);
         else if(lparam==m_check_move_unclassified.ObjectID())
            m_story_setting.ShowUnclassified(on);
        }
      this.UpdateSectionToggles();
      return;
     }
   //--- The boxes with a number: the setting keeps what counts, the box shows it
   if(m_SwingSetting!=NULL && lparam==m_edit_swing_strength.ObjectID())
     {
      m_SwingSetting.Strength((int)dparam);
      m_edit_swing_strength.SetValue((string)m_SwingSetting.Strength());
     }
   else if(m_FvgSetting!=NULL && lparam==m_edit_fvg_maxdead.ObjectID())
     {
      m_FvgSetting.MaxDead((int)dparam);
      m_edit_fvg_maxdead.SetValue((string)m_FvgSetting.MaxDead());
     }
   else if(m_FvgSetting!=NULL && lparam==m_edit_fvg_open_bullish.ObjectID())
     {
      m_FvgSetting.OpenNewestBullish((int)dparam);
      m_edit_fvg_open_bullish.SetValue((string)m_FvgSetting.OpenNewestBullish());
     }
   else if(m_FvgSetting!=NULL && lparam==m_edit_fvg_open_bearish.ObjectID())
     {
      m_FvgSetting.OpenNewestBearish((int)dparam);
      m_edit_fvg_open_bearish.SetValue((string)m_FvgSetting.OpenNewestBearish());
     }
   else if(m_MomentumCandleSetting!=NULL && lparam==m_edit_momentum_bars.ObjectID())
     {
      m_MomentumCandleSetting.Bars((int)dparam);
      m_edit_momentum_bars.SetValue((string)m_MomentumCandleSetting.Bars());
     }
   else if(m_MomentumCandleSetting!=NULL && lparam==m_edit_momentum_multiplier.ObjectID())
     {
      m_MomentumCandleSetting.Multiplier(dparam);
      m_edit_momentum_multiplier.SetValue(::DoubleToString(m_MomentumCandleSetting.Multiplier(),2));
     }
   else if(m_SupplyDemandSetting!=NULL && lparam==m_edit_sd_maxdead.ObjectID())
     {
      m_SupplyDemandSetting.MaxDead((int)dparam);
      m_edit_sd_maxdead.SetValue((string)m_SupplyDemandSetting.MaxDead());
     }
   else if(m_SupplyDemandSetting!=NULL && lparam==m_edit_sd_open_demand.ObjectID())
     {
      m_SupplyDemandSetting.OpenNewestDemand((int)dparam);
      m_edit_sd_open_demand.SetValue((string)m_SupplyDemandSetting.OpenNewestDemand());
     }
   else if(m_SupplyDemandSetting!=NULL && lparam==m_edit_sd_open_supply.ObjectID())
     {
      m_SupplyDemandSetting.OpenNewestSupply((int)dparam);
      m_edit_sd_open_supply.SetValue((string)m_SupplyDemandSetting.OpenNewestSupply());
     }
   else if(m_TrendlineSetting!=NULL && lparam==m_edit_tl_maxdead.ObjectID())
     {
      m_TrendlineSetting.MaxDead((int)dparam);
      m_edit_tl_maxdead.SetValue((string)m_TrendlineSetting.MaxDead());
     }
   else if(m_TrendlineSetting!=NULL && lparam==m_edit_tl_nearest.ObjectID())
     {
      m_TrendlineSetting.Nearest((int)dparam);
      m_edit_tl_nearest.SetValue((string)m_TrendlineSetting.Nearest());
     }
   else if(m_SupportResistanceSetting!=NULL && lparam==m_edit_sr_maxdead.ObjectID())
     {
      m_SupportResistanceSetting.MaxDead((int)dparam);
      m_edit_sr_maxdead.SetValue((string)m_SupportResistanceSetting.MaxDead());
     }
   else if(m_SupportResistanceSetting!=NULL && lparam==m_edit_sr_open_support.ObjectID())
     {
      m_SupportResistanceSetting.OpenNewestSupport((int)dparam);
      m_edit_sr_open_support.SetValue((string)m_SupportResistanceSetting.OpenNewestSupport());
     }
   else if(m_SupportResistanceSetting!=NULL && lparam==m_edit_sr_open_resistance.ObjectID())
     {
      m_SupportResistanceSetting.OpenNewestResistance((int)dparam);
      m_edit_sr_open_resistance.SetValue((string)m_SupportResistanceSetting.OpenNewestResistance());
     }
   else if(m_TrendlineSetting!=NULL && lparam==m_edit_tl_swings_tried.ObjectID())
     {
      m_TrendlineSetting.SwingsTried((int)dparam);
      m_edit_tl_swings_tried.SetValue((string)m_TrendlineSetting.SwingsTried());
     }
   else if(m_TrendlineSetting!=NULL && lparam==m_edit_tl_confirm_atr.ObjectID())
     {
      m_TrendlineSetting.ConfirmATR(dparam);
      m_edit_tl_confirm_atr.SetValue(::DoubleToString(m_TrendlineSetting.ConfirmATR(),2));
     }
   else if(m_TrendlineSetting!=NULL && lparam==m_edit_tl_confirm_closes.ObjectID())
     {
      m_TrendlineSetting.ConfirmCloses((int)dparam);
      m_edit_tl_confirm_closes.SetValue((string)m_TrendlineSetting.ConfirmCloses());
     }
   else if(m_TrendlineSetting!=NULL && lparam==m_edit_tl_min_move.ObjectID())
     {
      m_TrendlineSetting.MinMoveATR(dparam);
      m_edit_tl_min_move.SetValue(::DoubleToString(m_TrendlineSetting.MinMoveATR(),2));
     }
   else if(m_TrendlineSetting!=NULL && lparam==m_edit_tl_min_swing.ObjectID())
     {
      m_TrendlineSetting.MinSwingATR(dparam);
      m_edit_tl_min_swing.SetValue(::DoubleToString(m_TrendlineSetting.MinSwingATR(),2));
     }
   else if(m_SupportResistanceSetting!=NULL && lparam==m_edit_sr_min_score.ObjectID())
     {
      m_SupportResistanceSetting.MinScore((int)dparam);
      m_edit_sr_min_score.SetValue((string)m_SupportResistanceSetting.MinScore());
     }
   else if(m_SupportResistanceSetting!=NULL && lparam==m_edit_sr_confirm_closes.ObjectID())
     {
      m_SupportResistanceSetting.ConfirmCloses((int)dparam);
      m_edit_sr_confirm_closes.SetValue((string)m_SupportResistanceSetting.ConfirmCloses());
     }
   else if(m_SupportResistanceSetting!=NULL && lparam==m_edit_sr_ghost_bars.ObjectID())
     {
      m_SupportResistanceSetting.GhostBars((int)dparam);
      m_edit_sr_ghost_bars.SetValue((string)m_SupportResistanceSetting.GhostBars());
     }
   else if(m_SupportResistanceSetting!=NULL && lparam==m_edit_sr_max_age.ObjectID())
     {
      m_SupportResistanceSetting.MaxAgeBars((int)dparam);
      m_edit_sr_max_age.SetValue((string)m_SupportResistanceSetting.MaxAgeBars());
     }
   else if(m_SupportResistanceSetting!=NULL && lparam==m_edit_sr_volume_ma.ObjectID())
     {
      m_SupportResistanceSetting.VolumeMABars((int)dparam);
      m_edit_sr_volume_ma.SetValue((string)m_SupportResistanceSetting.VolumeMABars());
     }
  }
#endif // CGUIPANNEL_TABQUICKSETTING_SMARTMONEY_MQH
