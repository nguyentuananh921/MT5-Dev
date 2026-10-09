//+------------------------------------------------------------------+
//|                                 GUIPannel_CandleInfo_Windows.mqh |
//| Shift+hover on a bar or the cursor on a marker: the popup that   |
//| lists what Python found on that candle                           |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_CANDLEINFO_WINDOWS_MQH
#define CGUIPANNEL_CANDLEINFO_WINDOWS_MQH
 #include "GUIPannel.mqh"
 bool CGUIPannel::MouseOverAnyGUIWindow(const int px,const int py)
  {
   CWindow *windows[3];
   windows[0]=::GetPointer(m_window_main);
   windows[1]=::GetPointer(m_window_setting_timeseries);
   windows[2]=::GetPointer(m_window_candle_infomation);
   for(int w=0;w<::ArraySize(windows);w++)
      if(windows[w].IsVisible() && windows[w].CursorInsideElement(px,py))
         return true;
   return false;
  }
 //--- The candle under a chart pixel: its open time, 0 when the pixel is outside the bars (stand-in for V2 CChartObj::GetBarTimeFromXY)
 datetime CGUIPannel::BarTimeFromXY(const int px,const int py)
  {
   datetime time=0;
   double price=0;
   int sub=0;
   if(!::ChartXYToTimePrice(m_chart_id,px,py,sub,time,price) || sub!=0)
      return 0;
   ENUM_TIMEFRAMES tf=(ENUM_TIMEFRAMES)::Period();
   int shift=::iBarShift(::Symbol(),tf,time,false);
   if(shift<0)
      return 0;
   datetime bar_time=::iTime(::Symbol(),tf,shift);
   return (time<bar_time+::PeriodSeconds(tf)) ? bar_time : 0;
  }
 //+------------------------------------------------------------------+
 //| Popup: 3 cols Time | TF (+ source icon) | Information (+ arrow)  |
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
   if(!m_window_candle_infomation.CreateWindow(m_chart_id,m_subwin,"Signals at Bar",0,0,CANDLE_INFO_WINDOW_W,CANDLE_INFO_WINDOW_H))
      return false;
   m_table_candle_information_atBar.TableSize(COLUMNS_CANDLEINFO_TOTAL,0);
   m_table_candle_information_atBar.View().ShowHeaders(true);
   m_table_candle_information_atBar.View().SelectableRow(true);
   m_table_candle_information_atBar.View().LightsHover(true);
   m_table_candle_information_atBar.View().IsSortMode(false);
   m_window_candle_infomation.AddChild(&m_table_candle_information_atBar);
   if(!m_table_candle_information_atBar.CreateTable(m_chart_id,m_subwin,"TableCandleInfo",1,WINDOW_CAPTION_HEIGHT,
                                                    CANDLE_INFO_WINDOW_W-2,CANDLE_INFO_WINDOW_H-WINDOW_CAPTION_HEIGHT-1))
      return false;
   CTableHeaderView *header=m_table_candle_information_atBar.View().GetHeaderViewPointer();
   header.ColumnsWidth(CANDLEINFO_WIDTH);
   header.TextAlign(CANDLEINFO_HEADER_ALIGN);
   header.TextXOffset(CANDLEINFO_TEXT_X_OFFSET);
   header.ImageXOffset(CANDLEINFO_IMAGE_X_OFFSET);
   m_table_candle_information_atBar.View().IsFilterMode(COL_CI_SOURCE,true);
   m_table_candle_information_atBar.SetHeaderText(COL_CI_TIME,"Time");
   m_table_candle_information_atBar.SetHeaderText(COL_CI_SOURCE,"");
   m_table_candle_information_atBar.SetHeaderText(COL_CI_TF,"TF");
   m_table_candle_information_atBar.SetHeaderText(COL_CI_INFO,"Information");
   m_table_candle_information_atBar.View().Rebuild(true);
   return true;
  }
 //+------------------------------------------------------------------+
 //| Popup beside the bar column under the cursor, clear of its badge,|
 //| flipped to the left side when it would leave the chart            |
 //+------------------------------------------------------------------+
 void CGUIPannel::RepositionWindow_CandleInfo(const int cursor_x,const int cursor_y)
  {
   int chart_w=(int)::ChartGetInteger(m_chart_id,CHART_WIDTH_IN_PIXELS);
   int chart_h=(int)::ChartGetInteger(m_chart_id,CHART_HEIGHT_IN_PIXELS);
   int window_w=m_window_candle_infomation.Width();
   int window_h=m_window_candle_infomation.Height();
   int slot_w=(int)(1<<(int)::ChartGetInteger(m_chart_id,CHART_SCALE));
   int left=cursor_x,right=cursor_x,top=cursor_y-CANDLE_INFO_CURSOR_INSET;
   int bar_x=0,bar_y=0;
   if(::ChartTimePriceToXY(m_chart_id,m_subwin,m_candle_info_shown_bar,0,bar_x,bar_y))
     {
      left=bar_x-slot_w/2;
      right=bar_x+slot_w/2;
     }
   int x=right+CANDLE_INFO_CANDLE_GAP;
   if(x+window_w>chart_w)
      x=left-window_w-CANDLE_INFO_CANDLE_GAP;
   if(x<0)
      x=0;
   int max_x=chart_w-window_w;
   if(max_x<0)
      max_x=0;
   if(x>max_x)
      x=max_x;
   int y=top;
   if(y+window_h>chart_h)
      y=chart_h-window_h;
   if(y<0)
      y=0;
   int max_y=chart_h-window_h;
   if(max_y<0)
      max_y=0;
   if(y>max_y)
      y=max_y;
   m_window_candle_infomation.Move(x,y);
  }
 void CGUIPannel::ShowWindow_CandleInfo(const int cursor_x,const int cursor_y,const datetime bar_time,const bool by_marker)
  {
   m_candle_info_shown_bar=bar_time;
   m_candle_info_by_marker=by_marker;
   RepositionWindow_CandleInfo(cursor_x,cursor_y);
   m_window_candle_infomation.Show();
   ::ChartRedraw(m_chart_id);
  }
 void CGUIPannel::HideWindow_CandleInfo(void)
  {
   m_candle_info_shown_bar=0;
   m_candle_info_by_marker=false;
   CCandleMarker::ClearHighlight();
   if(!m_window_candle_infomation.IsVisible())
      return;
   m_window_candle_infomation.Hide();
   ::ChartRedraw(m_chart_id);
  }
 //+------------------------------------------------------------------+
 //| Rows built by CPythonBridge::GetCandleInfo into the table;       |
 //| false (and no rows) when the candle has none                     |
 //+------------------------------------------------------------------+
 bool CGUIPannel::RefreshWindow_CandleInfo(const int count,const string &row_label[],const string &row_tf[],
                                           const ENUM_SIGNAL_DIR &row_dir[],const datetime &row_time[],const int &row_source[])
  {
   if(count==0)
     {
      m_table_candle_information_atBar.DeleteAllRows(false);
      return false;
     }
   uint source_img[]={IMAGE_RESOURCE_BMP16_INDICATOR_BMP,IMAGE_RESOURCE_BMP16_CANDLE_PNG,IMAGE_RESOURCE_BMP16_SIGNAL_PNG,IMAGE_RESOURCE_BMP16_SIGNAL_PNG};
   uint dir_img[]   ={IMAGE_RESOURCE_BMP16_ARROW_UP_PNG,IMAGE_RESOURCE_BMP16_ARROW_DOWN_PNG};
   string source_name[]={"Indicator","Candle Pattern","Swing","Market Structure"};
   m_table_candle_information_atBar.DeleteAllRows(false);
   for(int i=0;i<count;i++)
      m_table_candle_information_atBar.AddRow();
   for(int row=0;row<count;row++)
     {
      m_table_candle_information_atBar.View().RowView(row).TextAlign(CANDLEINFO_CONTENT_ALIGN);
      m_table_candle_information_atBar.CellView(COL_CI_SOURCE,row).SetImages(source_img);
      m_table_candle_information_atBar.CellView(COL_CI_SOURCE,row).ChangeImage(row_source[row]);
      if(row_dir[row]!=SIGNAL_NONE)   // no side (Inside Bar): no arrow
        {
         m_table_candle_information_atBar.CellView(COL_CI_INFO,row).SetImages(dir_img);
         m_table_candle_information_atBar.CellView(COL_CI_INFO,row).ChangeImage(row_dir[row]==SIGNAL_BUY ? 0 : 1);
        }
      m_table_candle_information_atBar.Cell(COL_CI_TIME,row).SetDatetimeFlags(TIME_MINUTES);
      m_table_candle_information_atBar.SetValue(COL_CI_TIME,row,row_time[row]);
      m_table_candle_information_atBar.SetValue(COL_CI_SOURCE,row,source_name[row_source[row]]);
      m_table_candle_information_atBar.SetValue(COL_CI_TF,row,row_tf[row]);
      m_table_candle_information_atBar.SetValue(COL_CI_INFO,row,row_label[row]);
     }
   m_table_candle_information_atBar.Update(false);
   return true;
  }
 //+------------------------------------------------------------------+
 //| The EA opens the popup; here it closes: once the cursor is       |
 //| neither on it, nor on its bar, nor on the marker that opened it  |
 //+------------------------------------------------------------------+
 void CGUIPannel::OnEvent_Window_CandleInfor(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CUSTOM+ON_CANDLE_MARKER_LEAVE)
     {
      m_candle_info_by_marker=false;   // the next mouse move closes the popup unless the cursor is on it or on its bar
      return;
     }
   //--- Scroll/zoom/new bar: the popup follows its candle
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      if(m_candle_info_shown_bar!=0)
        {
         RepositionWindow_CandleInfo(m_window_candle_infomation.X(),m_window_candle_infomation.Y()+CANDLE_INFO_CURSOR_INSET);
         ::ChartRedraw(m_chart_id);
        }
      return;
     }
   if(id!=CHARTEVENT_MOUSE_MOVE || m_candle_info_shown_bar==0)
      return;
   int x=(int)lparam;
   int y=(int)dparam;
   if(m_window_candle_infomation.CursorInsideElement(x,y))
      return;
   if(m_candle_info_by_marker)
      return;
   bool over_gui=MouseOverAnyGUIWindow(x,y);
   bool shift=((((int)::StringToInteger(sparam))&MOUSE_BUTT_KEY_STATE_SHIFT)!=0);
   if(!over_gui && BarTimeFromXY(x,y)==m_candle_info_shown_bar)
      return;
   if(!over_gui && shift)
      return;
   HideWindow_CandleInfo();
  }
#endif // CGUIPANNEL_CANDLEINFO_WINDOWS_MQH
