//+------------------------------------------------------------------+
//|                           GUIPannel_MainWindows_TabMarketStory.mqh |
//| The Market Story tab of m_window_main: what Python found about   |
//| the market structure of the chart Symbol, one row per tracked TF |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_MAINWINDOWS_TABMARKETSTORY_MQH
#define CGUIPANNEL_MAINWINDOWS_TABMARKETSTORY_MQH
 #include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| TF | Market State | Market Phase | the newest leg between Swings   |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateTable_MarketStory(const int x,const int y)
  {
   int columns_width_total=0;
   for(int c=0;c<COLUMNS_MARKETSTORY_TOTAL;c++)
     {
      columns_width_total+=MARKETSTORY_WIDTH[c];
      m_table_market_story.View().GetHeaderViewPointer().TextAlign(c,MARKETSTORY_HEADER_ALIGN[c]);
     }
   m_table_market_story.TableSize(COLUMNS_MARKETSTORY_TOTAL,0);
   m_table_market_story.View().ShowHeaders(true);
   m_table_market_story.View().ColumnResizeMode(true);   // every column border can be dragged
   m_table_market_story.View().SelectableRow(true);
   m_table_market_story.View().LightsHover(true);
   m_table_market_story.View().IsSortMode(false);
   m_tabs_main.AddToElementsArray(TAB_TAB_MAIN_MARKET_STORY,m_table_market_story);
   if(!m_table_market_story.CreateTable(m_ChartObj.GetChartID(),M_SUBWINDOW_MAIN,"TableMarketStory",x,y,columns_width_total+M_TABLE_SCROLL_WIDTH,TRADING_FORM_HEIGHT))
      return false;
   CTableHeaderView *header=m_table_market_story.View().GetHeaderViewPointer();
   header.ColumnsWidth(MARKETSTORY_WIDTH);
   header.TextXOffset(MARKETSTORY_TEXT_X_OFFSET);
   header.ImageXOffset(MARKETSTORY_IMAGE_X_OFFSET);
   m_table_market_story.SetHeaderText(COL_MS_TF,"TF");
   uint state_header_img[]={IMAGE_RESOURCE_BMP16_SIGNAL_PNG};
   m_table_market_story.SetHeaderText(COL_MS_STATE,"");
   m_table_market_story.SetHeaderImage(COL_MS_STATE,state_header_img);
   m_table_market_story.SetHeaderText(COL_MS_PHASE,"Phase");
   m_table_market_story.SetHeaderText(COL_MS_MOVE,"Last leg");
   m_table_market_story.View().Rebuild(true);
   return true;
  }

 //+------------------------------------------------------------------+
 //| Shows what Python (the Model) calculated: the newest State /     |
 //| Phase and leg of every TF the CSymbolTFManager lists for the     |
 //| chart Symbol. Called when the EA says there is something new, not|
 //| on a timer. The rows are made again only when the TFs of the rows|
 //| change; otherwise SetValue writes the cells, and a cell is drawn |
 //| only when its value really changed: the table does not flash     |
 //+------------------------------------------------------------------+
 bool CGUIPannel::SyncTable_MarketStory(void)
  {
   if(m_SymbolTFManager==NULL || m_story_conditions==NULL || m_story_movements==NULL)
      return false;
   string symbol=::Symbol();
   string row_tf[],row_phase[],row_move[];
   ENUM_MARKET_STATE row_state[];
   ENUM_MARKET_PHASE row_phase_value[];
   int count=0;
   for(int i=0;i<m_SymbolTFManager.Total();i++)
     {
      CSymbolTFSetting *setting=m_SymbolTFManager.At(i);
      if(setting==NULL || setting.Symbol()!=symbol)
         continue;
      ENUM_TIMEFRAMES tf=setting.TFEnum();
      ::ArrayResize(row_tf,count+1);
      ::ArrayResize(row_state,count+1);
      ::ArrayResize(row_phase,count+1);
      ::ArrayResize(row_move,count+1);
      ::ArrayResize(row_phase_value,count+1);
      row_tf[count]=TimeframeDescription(tf);
      row_state[count]=MARKET_STATE_NONE;
      row_phase[count]="-";
      row_phase_value[count]=MARKET_PHASE_NONE;
      row_move[count]="-";
      for(int k=m_story_conditions.Total()-1;k>=0;k--)
        {
         CMarketConditionSeries *condition=m_story_conditions.At(k);
         if(condition==NULL || condition.Timeframe()!=tf)
            continue;
         row_state[count]=condition.State();
         row_phase[count]=MarketPhaseText(condition.Phase());
         row_phase_value[count]=condition.Phase();
         break;
        }
      for(int k=m_story_movements.Total()-1;k>=0;k--)
        {
         CMovementSeries *leg=m_story_movements.At(k);
         if(leg==NULL || leg.Timeframe()!=tf)
            continue;
         row_move[count]=leg.ShortText();
         break;
        }
      count++;
     }
   //--- the rows are the TFs of the CSymbolTFManager: the table is asked what it shows, it keeps no copy
   bool same_rows=((int)m_table_market_story.Model().RowsTotal()==count);
   for(int i=0;i<count && same_rows;i++)
      same_rows=(m_table_market_story.Cell(COL_MS_TF,i).ValueS()==row_tf[i]);
   if(!same_rows)
     {
      ::Print("MY DEBUG CGUIPannel::SyncTable_MarketStory: the rows are made again, ",count," row(s) for ",symbol);   //Print Debug
      m_table_market_story.DeleteAllRows(false);
      for(int i=0;i<count;i++)
         m_table_market_story.AddRow();
     }
   for(int row=0;row<count;row++)
      FillRow_MarketStory(row,row_tf[row],row_state[row],row_phase[row],row_phase_value[row],row_move[row],!same_rows);
   m_table_market_story.Update(false);   // the rows that changed are drawn, not the table
   return true;
  }
 //+------------------------------------------------------------------+
 //| One row of the table. images = true when the row is new: its TF  |
 //| cell gets the icons, later only the icon that shows is changed   |
 //+------------------------------------------------------------------+
 void CGUIPannel::FillRow_MarketStory(const int row,const string tf,const ENUM_MARKET_STATE state,const string phase,const ENUM_MARKET_PHASE phase_value,
                                      const string move,const bool images)
  {
   if(images)
     {
      uint tf_img[]={IMAGE_RESOURCE_BMP16_BAR_CHART_BMP,IMAGE_RESOURCE_BMP16_BAR_CHART_COLORLESS_BMP};
      m_table_market_story.View().RowView(row).TextAlign(MARKETSTORY_CONTENT_ALIGN);
      m_table_market_story.CellView(COL_MS_TF,row).SetImages(tf_img);
      m_table_market_story.SetValue(COL_MS_TF,row,tf);
      uint state_img[]={IMAGE_RESOURCE_BMP16_ARROW_UP_PNG,IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG,IMAGE_RESOURCE_BMP16_START_GRAY_BMP};
      m_table_market_story.CellView(COL_MS_STATE,row).SetImages(state_img);
     }
   m_table_market_story.CellView(COL_MS_TF,row).ChangeImage(tf==TimeframeDescription((ENUM_TIMEFRAMES)::Period()) ? 0 : 1);   // coloured for the TF of the chart
   //--- the colour of the Phase is the one of the BOS / CHoCH lines of that Phase; set first, so that the cell is drawn once
   color phase_colour=(m_story_setting!=NULL ? m_story_setting.PhaseColor(phase_value) : clrNONE);
   m_table_market_story.CellView(COL_MS_PHASE,row).TextColor(phase_colour!=clrNONE ? phase_colour : clrGray);
   //--- the State is an icon: up = Uptrend, down = Downtrend, the gray star = Range (or nothing yet)
   m_table_market_story.CellView(COL_MS_STATE,row).ChangeImage(state==MARKET_STATE_UPTREND ? 0 : state==MARKET_STATE_DOWNTREND ? 1 : 2);
   m_table_market_story.SetValue(COL_MS_PHASE,row,phase);
   m_table_market_story.SetValue(COL_MS_MOVE,row,move);
  }
 //+------------------------------------------------------------------+
 //| The chart changed its TF: only the TF it is on is highlighted,   |
 //| the values wait for the answer of Python                         |
 //+------------------------------------------------------------------+
 void CGUIPannel::HighlightTable_MarketStory(void)
  {
   string chart_tf=TimeframeDescription((ENUM_TIMEFRAMES)::Period());
   for(int row=0;row<(int)m_table_market_story.Model().RowsTotal();row++)
      m_table_market_story.CellView(COL_MS_TF,row).ChangeImage(m_table_market_story.Cell(COL_MS_TF,row).ValueS()==chart_tf ? 0 : 1);
   m_table_market_story.Update(false);
  }
 //+------------------------------------------------------------------+
 //| The short word of a Market Phase                                 |
 //+------------------------------------------------------------------+
 string CGUIPannel::MarketPhaseText(const ENUM_MARKET_PHASE phase) const
  {
   return (phase==MARKET_PHASE_ACCUMULATION ? "Accum" : phase==MARKET_PHASE_MARKUP ? "Markup" :
           phase==MARKET_PHASE_DISTRIBUTION ? "Distrib" : phase==MARKET_PHASE_MARKDOWN ? "Markdown" : "-");
  }
#endif // CGUIPANNEL_MAINWINDOWS_TABMARKETSTORY_MQH
