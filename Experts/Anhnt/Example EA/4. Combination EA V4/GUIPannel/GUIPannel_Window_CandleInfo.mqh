//+------------------------------------------------------------------+
//|                                 GUIPannel_Window_CandleInfo.mqh |
//| Shift+hover on a candle or the cursor on a CBarMarker: the popup |
//| that lists what was found in that candle, on its TF and on the   |
//| shorter ones. The rows are asked to CBarTimeSeriesCollection and |
//| CSignalsCollection (the account database): nothing is asked to   |
//| Python and nothing is held here                                   |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_WINDOW_CANDLEINFO_MQH
#define CGUIPANNEL_WINDOW_CANDLEINFO_MQH
#include "GUIPannel.mqh"
 //+------------------------------------------------------------------+
 //| Is the point on a window of the panel                            |
 //+------------------------------------------------------------------+
 bool CGUIPannel::MouseOverAnyWindow(const int px,const int py)
  {
   return (m_window_main.ContainsPoint(px,py) || m_window_addIndicator.ContainsPoint(px,py) || m_window_tradeManage.ContainsPoint(px,py) ||
           m_window_order_detail.ContainsPoint(px,py) || m_window_candle_infomation.ContainsPoint(px,py));
  }
 //+------------------------------------------------------------------+
 //| Popup: 4 columns Time | Source (icon) | TF | Information (+ arrow) |
 //+------------------------------------------------------------------+
 bool CGUIPannel::CreateWindow_CandleInfo(void)
  {
   m_window_candle_infomation.FontSize(DEF_FONT_SIZE);
   m_window_candle_infomation.IsMovable(false);
   m_window_candle_infomation.ResizeMode(false);
   m_window_candle_infomation.CloseButtonIsUsed(false);
   m_window_candle_infomation.CollapseButtonIsUsed(false);
   m_window_candle_infomation.TooltipsButtonIsUsed(false);
   m_window_candle_infomation.FullscreenButtonIsUsed(false);
   if(!m_window_candle_infomation.CreateWindow(this.m_chart_id,M_SUBWINDOW_MAIN,"Signals at Bar",0,0,CANDLE_INFO_WINDOW_W,CANDLE_INFO_WINDOW_H))
      return false;
   m_table_candle_information_atBar.TableSize(COLUMNS_CANDLEINFO_TOTAL,0);
   m_table_candle_information_atBar.View().ShowHeaders(true);
   m_table_candle_information_atBar.View().SelectableRow(true);
   m_table_candle_information_atBar.View().LightsHover(true);
   m_table_candle_information_atBar.View().IsSortMode(false);
   m_window_candle_infomation.AddChild(&m_table_candle_information_atBar);
   if(!m_table_candle_information_atBar.CreateTable(this.m_chart_id,M_SUBWINDOW_MAIN,"TableCandleInfo",1,M_CONTROL_HEIGHT,
                                                    CANDLE_INFO_WINDOW_W-2,CANDLE_INFO_WINDOW_H-M_CONTROL_HEIGHT-1))
      return false;
   CTableHeaderView *header=m_table_candle_information_atBar.View().GetHeaderViewPointer();
   header.ColumnsWidth(CANDLEINFO_WIDTH);
   header.TextAlign(CANDLEINFO_HEADER_ALIGN);
   header.TextXOffset(CANDLEINFO_TEXT_X_OFFSET);
   header.ImageXOffset(CANDLEINFO_IMAGE_X_OFFSET);
   m_table_candle_information_atBar.View().IsFilterMode(COL_CI_SOURCE,true);
   m_table_candle_information_atBar.View().IsFilterMode(COL_CI_TF,true);
   m_table_candle_information_atBar.SetHeaderText(COL_CI_TIME,"Time");
   m_table_candle_information_atBar.SetHeaderText(COL_CI_SOURCE,"");
   m_table_candle_information_atBar.SetHeaderText(COL_CI_TF,"TF");
   m_table_candle_information_atBar.SetHeaderText(COL_CI_INFO,"Information");
   m_table_candle_information_atBar.View().Rebuild(true);
   return true;
  }
 //+------------------------------------------------------------------+
 //| The open time of the candle of the chart under the cursor; 0 when |
 //| it is not on a candle (the room after the newest one too)         |
 //+------------------------------------------------------------------+
 datetime CGUIPannel::BarTimeOfCursor_CandleInfo(const int x,const int y)
  {
   datetime time=0;
   double price=0.0;
   int subwindow=0;
   ENUM_TIMEFRAMES timeframe=(ENUM_TIMEFRAMES)::Period();
   if(!::ChartXYToTimePrice(this.m_chart_id,x,y,subwindow,time,price) || subwindow!=M_SUBWINDOW_MAIN)
      return 0;
   if(time>=::iTime(::Symbol(),timeframe,0)+::PeriodSeconds(timeframe))
      return 0;
   int shift=::iBarShift(::Symbol(),timeframe,time,false);
   return (shift<0 ? 0 : ::iTime(::Symbol(),timeframe,shift));
  }
 //+------------------------------------------------------------------+
 //| The x of the column of the shown candle and the width of its slot |
 //+------------------------------------------------------------------+
 bool CGUIPannel::ShownBarColumn_CandleInfo(int &left,int &right)
  {
   int bar_x=0,bar_y=0;
   if(m_candle_info_shown_bar==0 || !::ChartTimePriceToXY(this.m_chart_id,M_SUBWINDOW_MAIN,m_candle_info_shown_bar,0,bar_x,bar_y))
      return false;
   int slot_w=(int)(1<<(int)::ChartGetInteger(this.m_chart_id,CHART_SCALE));
   left=bar_x-slot_w/2;
   right=bar_x+slot_w/2;
   return true;
  }
 //+------------------------------------------------------------------+
 //| Popup beside the candle column under the cursor, clear of its    |
 //| marker, flipped to the left side when it would leave the chart   |
 //+------------------------------------------------------------------+
 void CGUIPannel::MoveWindow_CandleInfo(const int cursor_x,const int cursor_y)
  {
   int chart_w=(int)::ChartGetInteger(this.m_chart_id,CHART_WIDTH_IN_PIXELS);
   int chart_h=(int)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS);
   int window_w=m_window_candle_infomation.Width();
   int window_h=m_window_candle_infomation.Height();
   int left=cursor_x,right=cursor_x;
   this.ShownBarColumn_CandleInfo(left,right);
   int x=right+CANDLE_INFO_CANDLE_GAP;
   if(x+window_w>chart_w)
      x=left-window_w-CANDLE_INFO_CANDLE_GAP;
   int max_x=::fmax(chart_w-window_w,0);
   x=(int)::fmin(::fmax(x,0),max_x);
   int y=cursor_y-CANDLE_INFO_CURSOR_INSET;
   int max_y=::fmax(chart_h-window_h,0);
   y=(int)::fmin(::fmax(y,0),max_y);
   m_window_candle_infomation.Move(x,y);
  }
 //+------------------------------------------------------------------+
 //| The rows of the candle go into the table: the signals of the     |
 //| indicators, then what was found on the bars. Returns how many    |
 //+------------------------------------------------------------------+
 int CGUIPannel::PopulateTable_CandleInfo(const datetime bar_time)
  {
   m_table_candle_information_atBar.DeleteAllRows(false);
   if(m_BarTimeSeriesCollection==NULL || m_SignalsCollection==NULL || m_BarInformationManager==NULL || m_IndicatorTemplateManager==NULL || m_SymbolTFManager==NULL)
      return 0;
   long symbol_id=m_BarTimeSeriesCollection.SymbolID(::Symbol());
   if(symbol_id==0)
      return 0;
   ENUM_TIMEFRAMES timeframe=(ENUM_TIMEFRAMES)::Period();
   datetime until=bar_time+::PeriodSeconds(timeframe);
   //--- The TFs of the symbol in Setting_SymbolTF as short as the chart's: only those are listed
   ENUM_TIMEFRAMES setting_tfs[];
   int setting_total=m_SymbolTFManager.TimeframesOf(::Symbol(),setting_tfs);
   long asked_tfs[];
   for(int i=0;i<setting_total;i++)
      if(::PeriodSeconds(setting_tfs[i])<=::PeriodSeconds(timeframe))
        {
         int n=::ArraySize(asked_tfs);
         ::ArrayResize(asked_tfs,n+1);
         asked_tfs[n]=(long)setting_tfs[i];
        }
   //--- Everything that was found is listed: the Show Buy / Show Sell switches are for the markers of the chart, not for this window
   ENUM_BAR_INFOR_TYPE type_list[];
   string type_names[];
   ENUM_BAR_INFORMATION_GROUP groups[];
   int candles[];
   bool have_buy[],have_sell[],sound[],message[],show_buy[],show_sell[];
   int types_total=m_BarInformationManager.Informations(type_list,type_names,groups,candles,have_buy,have_sell,sound,message,show_buy,show_sell);
   long template_ids[];
   ENUM_INDICATOR kinds[];
   string texts[];
   bool template_buy[],template_sell[];
   int templates_total=m_IndicatorTemplateManager.TemplateIds(template_ids,kinds,texts,template_buy,template_sell);
   long asked_types[];
   ::ArrayResize(asked_types,types_total);
   for(int i=0;i<types_total;i++)
      asked_types[i]=(long)type_list[i];
   //--- One row for each: the label, the source (the group of the type, or the indicators), the TF, the side and the time
   string row_label[],row_tf[];
   int row_source[],row_side[];
   datetime row_time[];
   long tfs[],keys[],times[],sides[];
   int count=0;
   int rows=m_SignalsCollection.ReadCandle_SignalsCollection(symbol_id,asked_tfs,bar_time,until,template_ids,tfs,keys,times,sides);
   for(int i=0;i<rows;i++)
     {
      int t=WRONG_VALUE;
      for(int k=0;k<templates_total && t==WRONG_VALUE;k++)
         if(template_ids[k]==keys[i])
            t=k;
      if(t==WRONG_VALUE)
         continue;
      this.AddRow_CandleInfo(count,m_IndicatorTemplateManager.DisplayLabel(kinds[t],texts[t]),BAR_INFORMATION_SIGNAL,(ENUM_TIMEFRAMES)tfs[i],(ENUM_SIGNAL_DIRECTION)sides[i],(datetime)times[i],
                             row_label,row_tf,row_source,row_side,row_time);
     }
   CBarTimeSeriesDE *timeseries=m_BarTimeSeriesCollection.GetTimeseries(::Symbol());   // the symbol reads the TFs asked: the table UNION RAM
   rows=(timeseries!=NULL ? timeseries.ReadCandle_BarTimeSeriesDE(asked_tfs,bar_time,until,asked_types,tfs,keys,times,sides) : 0);
   for(int i=0;i<rows;i++)
     {
      int t=WRONG_VALUE;
      for(int k=0;k<types_total && t==WRONG_VALUE;k++)
         if((long)type_list[k]==keys[i])
            t=k;
      if(t==WRONG_VALUE)
         continue;
      this.AddRow_CandleInfo(count,type_names[t],(int)groups[t],(ENUM_TIMEFRAMES)tfs[i],(ENUM_SIGNAL_DIRECTION)sides[i],(datetime)times[i],row_label,row_tf,row_source,row_side,row_time);
     }
   if(count==0)
      return 0;
   //--- The table: the rows first, then what each cell shows
   uint source_img[CANDLE_INFO_SOURCE_TOTAL];
   source_img[BAR_INFORMATION_JAPANESE_CANDLE]=IMAGE_RESOURCE_BMP16_CANDLE_PNG;
   source_img[BAR_INFORMATION_PRICE_ACTION_CANDLE]=IMAGE_RESOURCE_BMP16_CANDLE_PNG;
   source_img[BAR_INFORMATION_SMART_MONEY]=IMAGE_RESOURCE_BMP16_SIGNAL_PNG;
   source_img[BAR_INFORMATION_SIGNAL]=IMAGE_RESOURCE_BMP16_INDICATOR_BMP;
   uint side_img[]={IMAGE_RESOURCE_BMP16_ARROW_UP_PNG,IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG};
   for(int i=0;i<count;i++)
      m_table_candle_information_atBar.AddRow();
   for(int row=0;row<count;row++)
     {
      m_table_candle_information_atBar.View().RowView(row).TextAlign(CANDLEINFO_CONTENT_ALIGN);
      m_table_candle_information_atBar.CellView(COL_CI_SOURCE,row).SetImages(source_img);
      m_table_candle_information_atBar.CellView(COL_CI_SOURCE,row).ChangeImage(row_source[row]);
      m_table_candle_information_atBar.CellView(COL_CI_INFO,row).SetImages(side_img);
      m_table_candle_information_atBar.CellView(COL_CI_INFO,row).ChangeImage(row_side[row]==SIGNAL_DIRECTION_BUY ? 0 : 1);
      m_table_candle_information_atBar.Cell(COL_CI_TIME,row).SetDatetimeFlags(TIME_MINUTES);
      m_table_candle_information_atBar.SetValue(COL_CI_TIME,row,row_time[row]);
      m_table_candle_information_atBar.SetValue(COL_CI_SOURCE,row,this.SourceName_CandleInfo(row_source[row]));
      m_table_candle_information_atBar.SetValue(COL_CI_TF,row,row_tf[row]);
      m_table_candle_information_atBar.SetValue(COL_CI_INFO,row,row_label[row]);
     }
   m_table_candle_information_atBar.View().Rebuild(true);
   return count;
  }
 //+------------------------------------------------------------------+
 //| One row of the table is put in the arrays that hold them         |
 //+------------------------------------------------------------------+
 void CGUIPannel::AddRow_CandleInfo(int &count,const string label,const int source,const ENUM_TIMEFRAMES timeframe,const ENUM_SIGNAL_DIRECTION side,const datetime time,
                                    string &row_label[],string &row_tf[],int &row_source[],int &row_side[],datetime &row_time[])
  {
   ::ArrayResize(row_label,count+1);
   ::ArrayResize(row_tf,count+1);
   ::ArrayResize(row_source,count+1);
   ::ArrayResize(row_side,count+1);
   ::ArrayResize(row_time,count+1);
   row_label[count]=label;
   row_tf[count]=::StringSubstr(::EnumToString(timeframe),7);   // the name of the TF, as the table timeframes has it
   row_source[count]=source;
   row_side[count]=(int)side;
   row_time[count]=time;
   count++;
  }
 //+------------------------------------------------------------------+
 //| What a source is called: the group of a type, or the indicators  |
 //+------------------------------------------------------------------+
 string CGUIPannel::SourceName_CandleInfo(const int source)
  {
   if(source==BAR_INFORMATION_SIGNAL)
      return "Signal";
   return (m_BarInformationManager!=NULL ? m_BarInformationManager.GroupDescription((ENUM_BAR_INFORMATION_GROUP)source) : "");
  }
 //+------------------------------------------------------------------+
 //| The popup opens for a candle: it has nothing to show, it stays   |
 //| closed                                                           |
 //+------------------------------------------------------------------+
 void CGUIPannel::OpenWindow_CandleInfo(const int cursor_x,const int cursor_y,const datetime bar_time,const bool by_marker)
  {
   if(this.PopulateTable_CandleInfo(bar_time)==0)
      return;
   m_candle_info_shown_bar=bar_time;
   m_candle_info_by_marker=by_marker;
   this.MoveWindow_CandleInfo(cursor_x,cursor_y);
   m_window_candle_infomation.Show();
   if(!by_marker)
      CBarMarker::HighlightCandle(m_GraphElementsCollection,bar_time);   // the marker route has its box already
   ::ChartRedraw(this.m_chart_id);
  }
 void CGUIPannel::HideWindow_CandleInfo(void)
  {
   m_candle_info_shown_bar=0;
   m_candle_info_by_marker=false;
   CBarMarker::ClearHighlight();
   if(!m_window_candle_infomation.IsVisible())
      return;
   m_window_candle_infomation.Hide();
   ::ChartRedraw(this.m_chart_id);
  }
 //+------------------------------------------------------------------+
 //| Opens: Shift on a candle, or the cursor on its marker. Closes:    |
 //| the cursor is neither on the popup, nor on its candle, nor on the |
 //| marker that opened it. Follows its candle when the chart moves    |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Window_CandleInfo(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CUSTOM+BAR_MARKER_EVENT_ENTER)
     {
      this.OpenWindow_CandleInfo(0,(int)dparam,(datetime)lparam,true);
      return;
     }
   if(id==CHARTEVENT_CUSTOM+BAR_MARKER_EVENT_LEAVE)
     {
      m_candle_info_by_marker=false;   // the next mouse move closes the popup unless the cursor is on it or on its candle
      return;
     }
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      if(m_candle_info_shown_bar!=0)
        {
         this.MoveWindow_CandleInfo(m_window_candle_infomation.X(),m_window_candle_infomation.Y()+CANDLE_INFO_CURSOR_INSET);
         ::ChartRedraw(this.m_chart_id);
        }
      return;
     }
   if(id!=CHARTEVENT_MOUSE_MOVE)
      return;
   int x=(int)lparam;
   int y=(int)dparam;
   bool shift=((((int)::StringToInteger(sparam))&MOUSE_BUTT_KEY_STATE_SHIFT)!=0);
   if(m_candle_info_shown_bar!=0)
     {
      if(m_window_candle_infomation.ContainsPoint(x,y) || m_candle_info_by_marker)
         return;
      int left=0,right=0;
      bool over_window=this.MouseOverAnyWindow(x,y);
      if(!over_window && this.ShownBarColumn_CandleInfo(left,right))
        {
         if(x>=left && x<=right)
            return;
         //--- On the way from the candle (its marker) to the popup: the room between them, at the height of the popup
         int window_left=m_window_candle_infomation.X();
         int window_right=window_left+m_window_candle_infomation.Width();
         bool on_way_x=(window_left>=right ? (x>right && x<window_left) : (x>window_right && x<left));
         if(on_way_x && y>=m_window_candle_infomation.Y() && y<=m_window_candle_infomation.Y()+m_window_candle_infomation.Height())
            return;
        }
      if(!over_window && shift)
         return;
      this.HideWindow_CandleInfo();
      return;
     }
   if(!shift || this.MouseOverAnyWindow(x,y))
     {
      m_candle_info_last_bar=0;
      return;
     }
   datetime bar_time=this.BarTimeOfCursor_CandleInfo(x,y);
   if(bar_time==0 || bar_time==m_candle_info_last_bar)
      return;
   m_candle_info_last_bar=bar_time;
   this.OpenWindow_CandleInfo(x,y,bar_time,false);
  }
#endif // CGUIPANNEL_WINDOW_CANDLEINFO_MQH
