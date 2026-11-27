//+------------------------------------------------------------------+
//|                                                     ChartObj.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|Topic link:  https://www.mql5.com/en/articles/9213                |
//|Topic link:  https://www.mql5.com/en/articles/9236                |
//|Topic link:  https://www.mql5.com/en/articles/9260                |
//|Topic link:  https://www.mql5.com/en/articles/9293                |
//|Topic link:  https://www.mql5.com/en/articles/9360                |
//|Topic link:  https://www.mql5.com/en/articles/9385                |
//|Lib          https://www.mql5.com/en/articles/14710               |
//| Update in V4 after implemenation CDatabaseService                |
//+------------------------------------------------------------------+
#ifndef __CHARTOBJ_MQH__
#define __CHARTOBJ_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Bases\BaseObj.mqh"
 #include "..\Defines\EventDefines.mqh"
 #include "WndInd.mqh"
 #include "..\..\Collections\Settings\IndicatorTemplateManager.mqh"
 class CIndicatorTemplateManager;
#ifndef CCHARTOBJ_MQH_DECLARATION
#define CCHARTOBJ_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Chart object class                                               |
 //+------------------------------------------------------------------+
 class CChartObj : public CBaseObj
  {
   private:
    long              m_chart_id;                                  // Chart ID
    CArrayObj         m_list_ind;                                  // The indicators of all chart windows: name, type and parameters
    CArrayObj         m_list_ind_param;                            // The indicator whose parameters were changed last (the old type and parameters)
    CIndicatorTemplateManager *m_IndicatorTemplateManager;
    bool              m_object_created;                            // CHART_OBJ_EVENT_OBJECTS_CHANGE is on its way: the other "autotrade" objects of the same trade are not told again
    int               m_first_visible_bar;                         // The number of the first visible bar on the chart (V2 CHART_PROP_FIRST_VISIBLE_BAR)
    int               m_visible_bars;                              // The number of bars on the chart available for display (V2 CHART_PROP_VISIBLE_BARS)
    int               m_scale;                                     // The scale of the chart: a bar is 1 << m_scale pixels wide (V2 CHART_PROP_SCALE)
    int               m_width_in_pixels;                           // The width of the chart in pixels (V2 CHART_PROP_WIDTH_IN_PIXELS)
    int               m_height_in_pixels;                          // The main window: its height in pixels, (V2 CChartWnd) its highest and its lowest price
    double            m_price_max;
    double            m_price_min;
   //--- Set the (1) first visible bar, (2) number of visible bars from the chart (V2)
    void              SetFirstVisibleBars(void)                       { this.m_first_visible_bar=(int)::ChartGetInteger(this.m_chart_id,CHART_FIRST_VISIBLE_BAR); }
    void              SetVisibleBars(void)                            { this.m_visible_bars=(int)::ChartGetInteger(this.m_chart_id,CHART_VISIBLE_BARS);           }
   //--- Set the scale, the width in pixels (V2), the height and the prices of the main window (V2 CChartWnd)
    void              SetScale(void)                                  { this.m_scale=(int)::ChartGetInteger(this.m_chart_id,CHART_SCALE);                         }
    void              SetWidthInPixels(void)                          { this.m_width_in_pixels=(int)::ChartGetInteger(this.m_chart_id,CHART_WIDTH_IN_PIXELS);     }
    void              SetHeightInPixels(void)                         { this.m_height_in_pixels=(int)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS,0); }
    void              SetPriceMax(void)                               { this.m_price_max=::ChartGetDouble(this.m_chart_id,CHART_PRICE_MAX,0);                     }
    void              SetPriceMin(void)                               { this.m_price_min=::ChartGetDouble(this.m_chart_id,CHART_PRICE_MIN,0);                     }
   //--- What the chart shows is read again: true when it changed. older: older bars came into view (scrolled back, zoomed out)
    bool              SetView(bool &older);
   //--- Create and send the chart event of an indicator to the control program chart
    void              SendEvent(const ENUM_CHART_OBJ_EVENT event,CWndInd *ind);
   public:
                      CChartObj(const long chart_id);
    void              SetIndicatorTemplateManager(CIndicatorTemplateManager *manager) { this.m_IndicatorTemplateManager=manager; }
    bool              OnInitEvent(void);
   //--- Return the list of the indicators of all chart windows
    CArrayObj        *GetList(void)                                   { return &this.m_list_ind;                                          }
   //--- Return (1) the last one added and (2) the changed indicator (its old type and parameters), (3) the indicator by its index in the specified chart window
    CWndInd          *GetLastAddedIndicator(void)                     { return this.m_list_ind.At(this.m_list_ind.Total()-1);             }
    CWndInd          *GetLastChangedIndicator(void)                   { return this.m_list_ind_param.At(this.m_list_ind_param.Total()-1); }
    CWndInd          *GetIndicator(const int win_num,const int ind_index);
   //--- Scan the chart on init and compare every chart window after changes
    void              Refresh(const bool send_events=true);
   //--- Working with Event: (1) the chart changed (CHARTEVENT_CHART_CHANGE: an indicator added, removed or changed): Refresh, (2) an object of a trade made by the
   //--- terminal (CHARTEVENT_OBJECT_CREATE of "autotrade ...", DoEasy CChartObjectsControl): CHART_OBJ_EVENT_OBJECTS_CHANGE once for the objects of the trade
    void              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- The params of an indicator of the chart as the schema has them (FRAMA: its Shift)
    bool              ChartIdentity(const ENUM_INDICATOR type,MqlParam &params[]) const;
   //--- Change in V5: the type and the params of a line as the ones of its template. In a subwindow, an MA after the first line is made on the first line
   //--- (MT5 "First Indicator's Data": its applied param tells nothing, 1 when dropped by hand, a handle when made by a program): its source, TYPE(params)
    bool              LineIdentity(const CWndInd *ind,ENUM_INDICATOR &type,MqlParam &params[]) const;
   //--- New in V5: the subwindow whose first line is the indicator (WRONG_VALUE: none, or in the main window)
    int               SourceWindow(const ENUM_INDICATOR type,const string params_text);
   //--- The same indicator of the chart: the name, the type and the params as text
    bool              SameOnChart(const CWndInd *first,const CWndInd *second) const;
   //--- (1) Check (the line in the list, NULL: not on the chart), (2) attach and (3) detach an indicator of the chart by its type and parameters (the list is read again after)
    CWndInd          *IsIndicatorShownOnChart(const ENUM_INDICATOR type,const string params_text);
    void              ShowIndicatorOnChart(const ENUM_INDICATOR type,MqlParam &params[]);
    void              RemoveIndicatorFromChart(const ENUM_INDICATOR type,const string params_text);
   //--- The indicator of a template is on the chart when its template shows it (show_on_chart), not when it does not or the template is deleted
    void              SyncIndicatorOnChart(const ENUM_INDICATOR type,const string params_text,const bool deleted);
    long              ID(void)                                  const { return this.m_chart_id;                                       }
    string            Symbol(void)                              const { return ::ChartSymbol(this.m_chart_id);                        }
    ENUM_TIMEFRAMES   Timeframe(void)                           const { return (ENUM_TIMEFRAMES)::ChartPeriod(this.m_chart_id);       }
   //--- The bars the chart shows: (1) the first visible one, (2) how many, (3) the open time of the oldest and the newest (false while the chart has not its bars yet)
    int               FirstVisibleBars(void)                    const { return this.m_first_visible_bar;                              }
    int               VisibleBars(void)                         const { return this.m_visible_bars;                                   }
    int               Scale(void)                               const { return this.m_scale;                                          }
    int               WidthInPixels(void)                       const { return this.m_width_in_pixels;                                }
    int               HeightInPixels(void)                      const { return this.m_height_in_pixels;                               }
    double            PriceMax(void)                            const { return this.m_price_max;                                      }
    double            PriceMin(void)                            const { return this.m_price_min;                                      }
    bool              VisibleRange(datetime &from_time,datetime &to_time) const;
   //--- New in V5: the chart shows the bars from_time .. to_time, as big as they fit (autoscroll off, CHART_SCALE, ChartNavigate): STRATEGY_TRADE_EVENT_CLICK
    bool              ShowRange(const datetime from_time,const datetime to_time);
   //--- Set the chart symbol and timeframe
    bool              SetSymbol(const string symbol,const ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT);
  };
#endif // CCHARTOBJ_MQH_DECLARATION
#ifndef CCHARTOBJ_MQH_IMPLEMENTATION
#define CCHARTOBJ_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CChartObj::CChartObj(const long chart_id) : m_chart_id(chart_id==0 ? ::ChartID() : chart_id),m_IndicatorTemplateManager(NULL),m_object_created(false),m_first_visible_bar(0),m_visible_bars(0),m_scale(0),m_width_in_pixels(0),m_height_in_pixels(0),m_price_max(0),m_price_min(0)
  {
   this.m_object_type=OBJECT_DE_TYPE_CHART;
  }
 bool CChartObj::OnInitEvent(void)
  {
   if(this.m_IndicatorTemplateManager==NULL)
     {
      ::Print(__FUNCTION__," > IndicatorTemplateManager is not set");
      return false;
     }
   //--- Every start (a new attach, a TF change: the EA keeps this object): the chart works again, the terminal tells the objects it makes
   this.SetAvailable(true);
   ::ChartSetInteger(this.m_chart_id,CHART_EVENT_OBJECT_CREATE,true);   // the terminal tells the objects it makes (V2 CChartObjectsControl)
   ::ChartSetInteger(this.m_chart_id,CHART_SHOW_TRADE_LEVELS,false);    // New in V5: no SL / TP lines of the terminal for the positions and the orders (the EA shows its trades)
   this.m_object_created=::EventChartCustom(this.m_chart_id,(ushort)CHART_OBJ_EVENT_OBJECTS_CHANGE,::ObjectsTotal(this.m_chart_id),0.0,"");   // a TF change redraws "autotrade" without a create event
   //--- A chart change: the indicators stay on the chart. What the chart shows is read at its first CHARTEVENT_CHART_CHANGE: here it is not drawn for the new TF yet
   //--- (the price scale of the old one), the view is told once, then
   if(!this.m_first_start)
      return true;
   //--- A new attach: the view (told to nobody: the markers draw at PYTHON_BRIDGE_EVENT_SYMBOLTF_DONE); the scan of the chart: a template on it is shown
   //--- (Refresh tells its owner), then a template shown and not on the chart is attached. Nothing of the chart is removed
   bool older=false;
   this.SetView(older);
   this.Refresh();
   ENUM_INDICATOR types[];
   string params[];
   bool buy[],sell[];
   int total=this.m_IndicatorTemplateManager.Read_RAM(types,params,buy,sell);
   for(int row=0;row<total;row++)
      this.SyncIndicatorOnChart(types[row],params[row],false);
   this.m_first_start=false;
   return true;
  }
 //+------------------------------------------------------------------+
 //| Compare the indicators of every chart window with the list: an   |
 //| indicator with the same name, type and parameters is the same one|
 //| (the list takes its new window and index); a new indicator in the|
 //| window and index of a missing one is a change of parameters; the |
 //| rest is added or removed. Every case sends its event             |
 //+------------------------------------------------------------------+
 void CChartObj::Refresh(const bool send_events)
  {
   CArrayObj current;   // what the chart holds now; the new ones are taken by the list, the others are freed below
   current.FreeMode(false);
   int windows=(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOWS_TOTAL);
   for(int w=0;w<windows;w++)
     {
      int total=::ChartIndicatorsTotal(this.m_chart_id,w);
      for(int i=0;i<total;i++)
        {
         CWndInd *ind=new CWndInd(this.m_chart_id,w,i);
         if(ind!=NULL && !current.Add(ind))
            delete ind;
        }
     }
   int old_total=this.m_list_ind.Total();
   int now_total=current.Total();
   bool listed[],present[],taken[];
   ::ArrayResize(listed,old_total);
   ::ArrayResize(present,now_total);
   ::ArrayResize(taken,now_total);
   ::ArrayInitialize(listed,false);
   ::ArrayInitialize(present,false);
   ::ArrayInitialize(taken,false);
   //--- the templates of the listed lines, while the list is the one of the old chart (a line gone: its source may be gone too)
   string old_params[];
   ::ArrayResize(old_params,old_total);
   for(int k=0;k<old_total && send_events;k++)
     {
      ENUM_INDICATOR line_type;
      MqlParam line_params[];
      old_params[k]=(this.LineIdentity(this.m_list_ind.At(k),line_type,line_params) ? this.m_IndicatorTemplateManager.ParamsText(line_type,line_params) : "");
     }
   //--- the same indicator: the list takes the object of the chart, it knows where the indicator is now
   for(int j=0;j<now_total;j++)
     {
      CWndInd *now=current.At(j);
      for(int k=0;k<old_total && !present[j];k++)
        {
         CWndInd *old=this.m_list_ind.At(k);
         if(listed[k] || old==NULL || !this.SameOnChart(old,now))
            continue;
         this.m_list_ind.Update(k,now);
         taken[j]=true;
         listed[k]=true;
         present[j]=true;
        }
     }
   //--- parameters changed: the chart indicator in the window and the index of a listed one that is gone
   for(int j=0;j<now_total;j++)
     {
      if(present[j])
         continue;
      CWndInd *now=current.At(j);
      for(int k=0;k<old_total && !present[j];k++)
        {
         CWndInd *old=this.m_list_ind.At(k);
         if(listed[k] || old==NULL || old.WindowNum()!=now.WindowNum() || old.Index()!=now.Index())
            continue;
         this.m_list_ind_param.Clear();
         this.m_list_ind_param.Add(old);   // the old type and parameters stay for the receiver of the event
         this.m_list_ind.FreeMode(false);
         this.m_list_ind.Update(k,now);
         this.m_list_ind.FreeMode(true);
         taken[j]=true;
         listed[k]=true;
         present[j]=true;
         if(send_events)
            this.SendEvent(CHART_OBJ_EVENT_CHART_WND_IND_CHANGE,now);
        }
     }
   //--- added: the list takes the object of the chart
   CWndInd *added[];
   for(int j=0;j<now_total;j++)
     {
      if(present[j])
         continue;
      CWndInd *now=current.At(j);
      if(!this.m_list_ind.Add(now))
         continue;
      taken[j]=true;
      if(send_events)
        {
         ::ArrayResize(added,::ArraySize(added)+1);
         added[::ArraySize(added)-1]=now;
         this.SendEvent(CHART_OBJ_EVENT_CHART_WND_IND_ADD,now);
        }
     }
   //--- removed
   ENUM_INDICATOR gone_types[];
   string gone_params[];
   for(int k=old_total-1;k>WRONG_VALUE;k--)
     {
      CWndInd *old=this.m_list_ind.At(k);
      if(listed[k] || old==NULL)
         continue;
      if(send_events)
        {
         const int n=::ArraySize(gone_types);
         ::ArrayResize(gone_types,n+1);
         ::ArrayResize(gone_params,n+1);
         gone_types[n]=old.TypeIndicator();
         gone_params[n]=old_params[k];
         this.SendEvent(CHART_OBJ_EVENT_CHART_WND_IND_DEL,old);
        }
      this.m_list_ind.Delete(k);
     }
   //--- the list is the one of the chart now: the owner of a template writes its show_on_chart (a line came, or its last line went)
   for(int n=0;n<::ArraySize(added);n++)
     {
      ENUM_INDICATOR line_type;
      MqlParam line_params[];
      if(this.LineIdentity(added[n],line_type,line_params) && this.m_IndicatorTemplateManager.Read_RAM(line_type,this.m_IndicatorTemplateManager.ParamsText(line_type,line_params))!=NULL)
         this.m_IndicatorTemplateManager.Update_IndicatorTemplate_Setting(line_type,this.m_IndicatorTemplateManager.ParamsText(line_type,line_params),"show_on_chart",true,INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED);
     }
   for(int n=0;n<::ArraySize(gone_types);n++)
      if(gone_params[n]!="" && this.m_IndicatorTemplateManager.Read_RAM(gone_types[n],gone_params[n])!=NULL && this.IsIndicatorShownOnChart(gone_types[n],gone_params[n])==NULL)
         this.m_IndicatorTemplateManager.Update_IndicatorTemplate_Setting(gone_types[n],gone_params[n],"show_on_chart",false,INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED);
   for(int j=0;j<now_total;j++)
      if(!taken[j])
         delete current.At(j);
  }
 //+------------------------------------------------------------------+
 //| The chart changed: its indicators are compared. An object of a   |
 //| trade made by the terminal ("autotrade ..."), not any object:     |
 //| BringToTop shows the windows again and the terminal tells each of |
 //| them as made, which would raise the windows again and again. The  |
 //| first one sends the event, the others wait until it comes back    |
 //+------------------------------------------------------------------+
 void CChartObj::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //--- New in V5: the line of a position was clicked (CStrategyTrade): its entry (EventPack) and its exit (dparam) are shown
   if(id==CHARTEVENT_CUSTOM+STRATEGY_TRADE_EVENT_CLICK && sparam==this.Symbol())
     {
      datetime entry;
      long strategy_id;
      ENUM_SIGNAL_DIRECTION side;
      bool is_new;
      this.EventUnpack(lparam,entry,strategy_id,side,is_new);
      this.ShowRange(entry,(datetime)(long)dparam);
      return;
     }
   SIndicatorsRow catalog;
   if(this.m_IndicatorTemplateManager!=NULL)
     {
      //--- A template changed: attach or detach its indicator on this chart
      bool added=(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_ADDED);
      bool changed=(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_SHOW_CHANGED);
      bool deleted=(id==CHARTEVENT_CUSTOM+INDICATOR_TEMPLATE_MANAGER_EVENT_DELETE);
      if(added || changed || deleted)
        {
         this.SyncIndicatorOnChart((ENUM_INDICATOR)(int)lparam,sparam,deleted);
         ::ChartRedraw(this.m_chart_id);
         return;
        }
      //--- The user changed an indicator's parameters on the chart
      if(id==CHARTEVENT_CUSTOM+CHART_OBJ_EVENT_CHART_WND_IND_CHANGE)
        {
         CWndInd *old_ind=this.GetLastChangedIndicator();
         CWndInd *new_ind=this.GetIndicator((int)dparam,(int)lparam);
         ENUM_INDICATOR old_type,new_type;
         MqlParam old_params[],new_params[];
         if(!this.LineIdentity(old_ind,old_type,old_params) || !this.LineIdentity(new_ind,new_type,new_params))
            return;
         const string old_text=this.m_IndicatorTemplateManager.ParamsText(old_type,old_params);
         if(this.m_IndicatorTemplateManager.Read_RAM(new_type,this.m_IndicatorTemplateManager.ParamsText(new_type,new_params))!=NULL)
            return;
         if(this.m_IndicatorTemplateManager.Read_RAM(old_type,old_text)!=NULL)
            this.m_IndicatorTemplateManager.Update_IndicatorTemplate_Setting(old_type,old_text);
         if(this.m_IndicatorTemplateManager.Read_RAM(new_type,catalog))
            this.m_IndicatorTemplateManager.Update_IndicatorTemplate_Setting(new_type,new_params);
         return;
        }
      //--- A supported standard indicator was added or restored directly on the chart: its template is made (shown, the default)
      if(id==CHARTEVENT_CUSTOM+CHART_OBJ_EVENT_CHART_WND_IND_ADD)
        {
         CWndInd *ind=this.GetIndicator((int)dparam,(int)lparam);
         if(ind==NULL || ind.Name()!=sparam)
            ind=this.GetLastAddedIndicator();
         ENUM_INDICATOR type;
         MqlParam params[];
         if(!this.LineIdentity(ind,type,params) || !this.m_IndicatorTemplateManager.Read_RAM(type,catalog))
            return;
         if(this.m_IndicatorTemplateManager.Read_RAM(type,this.m_IndicatorTemplateManager.ParamsText(type,params))==NULL)
            this.m_IndicatorTemplateManager.Update_IndicatorTemplate_Setting(type,params);
         return;
        }
     }
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      bool older=false;
      if(this.SetView(older))   // scrolled, zoomed or the price scale moved: told with what it shows now
        {
         datetime from_time=0,to_time=0;
         if(this.VisibleRange(from_time,to_time))
            this.EventSend((ushort)CHART_OBJ_EVENT_VISIBLE_CHANGE,this.EventPack(from_time,::MathMin(this.m_visible_bars,0xFFFF),SIGNAL_DIRECTION_NONE,older),(double)this.Timeframe(),this.EventPackText(this.Symbol()));
        }
      this.Refresh();
      return;
     }
   if(id==CHARTEVENT_CUSTOM+CHART_OBJ_EVENT_OBJECTS_CHANGE)
     {
      this.m_object_created=false;
      return;
     }
   if(id==CHARTEVENT_OBJECT_CREATE && !this.m_object_created && ::StringFind(sparam,"autotrade")==0)
      this.m_object_created=::EventChartCustom(this.m_chart_id,(ushort)CHART_OBJ_EVENT_OBJECTS_CHANGE,::ObjectsTotal(this.m_chart_id),0.0,"");
  }
 //+------------------------------------------------------------------+
 //| What the chart shows is read again                              |
 //+------------------------------------------------------------------+
 bool CChartObj::SetView(bool &older)
  {
   const int first=this.m_first_visible_bar,visible=this.m_visible_bars,scale=this.m_scale,width=this.m_width_in_pixels,height=this.m_height_in_pixels;
   const double price_max=this.m_price_max,price_min=this.m_price_min;
   this.SetFirstVisibleBars();
   this.SetVisibleBars();
   this.SetScale();
   this.SetWidthInPixels();
   this.SetHeightInPixels();
   this.SetPriceMax();
   this.SetPriceMin();
   older=(this.m_first_visible_bar>first);   // the first visible bar is further back
   return (first!=this.m_first_visible_bar || visible!=this.m_visible_bars || scale!=this.m_scale || width!=this.m_width_in_pixels ||
           height!=this.m_height_in_pixels || price_max!=this.m_price_max || price_min!=this.m_price_min);
  }
 //+------------------------------------------------------------------+
 //| New in V5: the bars from_time .. to_time with a margin of a third |
 //| of them on each side, at the biggest scale they fit (a bar is     |
 //| 1 << scale pixels), the newest of them a margin from the right    |
 //+------------------------------------------------------------------+
 bool CChartObj::ShowRange(const datetime from_time,const datetime to_time)
  {
   const string sym=this.Symbol();
   const ENUM_TIMEFRAMES tf=this.Timeframe();
   const int from_shift=::iBarShift(sym,tf,from_time,false),to_shift=::iBarShift(sym,tf,to_time,false);
   const int width=(int)::ChartGetInteger(this.m_chart_id,CHART_WIDTH_IN_PIXELS);
   if(from_shift<0 || to_shift<0 || width<=0)
      return false;
   const int bars=::MathAbs(from_shift-to_shift)+1;
   const int margin=::MathMax(bars/3,3);
   int scale=0;
   for(int s=5;s>=0;s--)
      if((bars+2*margin)*(1<<s)<=width)
        {
         scale=s;
         break;
        }
   ::ChartSetInteger(this.m_chart_id,CHART_AUTOSCROLL,false);   // the new ticks do not take the chart back to the newest bar
   ::ChartSetInteger(this.m_chart_id,CHART_SCALE,scale);
   const int newest=::MathMin(from_shift,to_shift);
   ::ChartNavigate(this.m_chart_id,CHART_END,-::MathMax(newest-margin,0));
   ::ChartRedraw(this.m_chart_id);   // CHARTEVENT_CHART_CHANGE: the markers and the lines follow (SyncMarkers, SyncTrades)
   return true;
  }
 //+------------------------------------------------------------------+
 //| The open time of the oldest and the newest bar the chart shows    |
 //+------------------------------------------------------------------+
 bool CChartObj::VisibleRange(datetime &from_time,datetime &to_time) const
  {
   int last=this.m_first_visible_bar-this.m_visible_bars+1;   // the chart can show room after the newest bar
   if(last<0)
      last=0;
   //--- The symbol and the period are asked once (each ChartSymbol / ChartPeriod waits for the chart: Avoid Bug, CodingRule.md)
   const string symbol=this.Symbol();
   const ENUM_TIMEFRAMES timeframe=this.Timeframe();
   from_time=::iTime(symbol,timeframe,this.m_first_visible_bar);
   to_time=::iTime(symbol,timeframe,last);
   return (from_time!=0 && to_time!=0);
  }
 //+------------------------------------------------------------------+
 //| Return the indicator by its index in the specified chart window  |
 //+------------------------------------------------------------------+
 CWndInd *CChartObj::GetIndicator(const int win_num,const int ind_index)
  {
   for(int i=0;i<this.m_list_ind.Total();i++)
     {
      CWndInd *ind=this.m_list_ind.At(i);
      if(ind!=NULL && ind.WindowNum()==win_num && ind.Index()==ind_index)
         return ind;
     }
   return NULL;
  }
 //+------------------------------------------------------------------+
 //| pass the indicator index in the chart window to lparam, the chart|
 //| window index to dparam and the short name to sparam: the receiver|
 //| asks the chart object for the indicator, its type and parameters |
 //+------------------------------------------------------------------+
 void CChartObj::SendEvent(const ENUM_CHART_OBJ_EVENT event,CWndInd *ind)
  {
   if(ind==NULL)
      return;
   this.EventSend((ushort)event,ind.Index(),ind.WindowNum(),ind.Name());
  } //+------------------------------------------------------------------+
 //| Set the chart symbol                                             |
 //+------------------------------------------------------------------+
 bool CChartObj::SetSymbol(const string symbol,const ENUM_TIMEFRAMES timeframe)
  {
   ENUM_TIMEFRAMES tf=(timeframe==PERIOD_CURRENT ? this.Timeframe() : timeframe);
   if(symbol==this.Symbol() && tf==this.Timeframe())
      return true;
   ::ResetLastError();
   if(!::ChartSetSymbolPeriod(this.ID(),symbol,tf))
     {
      CMessage::ToLog(DFUN,::GetLastError(),true);
      return false;
     }
   this.SetAvailable(false);   // the chart is changing: the EA stops until OnDeinit
   return true;
  }
 bool CChartObj::ChartIdentity(const ENUM_INDICATOR type,MqlParam &params[]) const
  {
   //--- FRAMA of the chart has no Shift (period, applied price): the schema has it, 0
   if(type==IND_FRAMA && ::ArraySize(params)==2)
     {
      ::ArrayResize(params,3);
      params[2]=params[1];
      params[1].type=TYPE_INT;
      params[1].integer_value=0;
      params[1].double_value=0;
      params[1].string_value="";
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| Change in V5: the template of a line. An MA after the first line  |
 //| of a subwindow is made on that first line (the applied param of   |
 //| the chart can't tell it, measured); elsewhere an applied param    |
 //| that is not a price is a line of another program: no template     |
 //+------------------------------------------------------------------+
 bool CChartObj::LineIdentity(const CWndInd *ind,ENUM_INDICATOR &type,MqlParam &params[]) const
  {
   if(this.m_IndicatorTemplateManager==NULL || ind==NULL || !ind.GetIdentity(type,params) || !this.ChartIdentity(type,params))
      return false;
   int applied=this.m_IndicatorTemplateManager.AppliedIndex(type);
   if(applied<0 || applied>=::ArraySize(params))
      return true;
   params[applied].string_value="";
   if(ind.WindowNum()>0 && ind.Index()>0)
     {
      if(!this.m_IndicatorTemplateManager.TakesSource(type))
         return false;   // on the first line, but a type that can't be on an indicator (FRAMA): no template rather than a wrong one
      CWndInd *first=NULL;   // the first line of its subwindow, in the list (not read again from the chart)
      for(int i=0;i<this.m_list_ind.Total() && first==NULL;i++)
        {
         CWndInd *line=this.m_list_ind.At(i);
         if(line!=NULL && line.WindowNum()==ind.WindowNum() && line.Index()==0)
            first=line;
        }
      ENUM_INDICATOR source_type;
      MqlParam source_params[];
      if(first==NULL || !first.GetIdentity(source_type,source_params) || !this.ChartIdentity(source_type,source_params))
         return false;
      params[applied].string_value=this.m_IndicatorTemplateManager.SourceText(source_type,this.m_IndicatorTemplateManager.ParamsText(source_type,source_params));
      params[applied].integer_value=0;
      return true;
     }
   return (params[applied].integer_value>=PRICE_CLOSE && params[applied].integer_value<=PRICE_WEIGHTED);
  }
 //+------------------------------------------------------------------+
 //| The line of a template in the list of the chart (Refresh keeps   |
 //| it as the chart is), NULL: not on the chart                      |
 //+------------------------------------------------------------------+
 CWndInd *CChartObj::IsIndicatorShownOnChart(const ENUM_INDICATOR type,const string params_text)
  {
   for(int i=0;i<this.m_list_ind.Total() && this.m_IndicatorTemplateManager!=NULL;i++)
     {
      CWndInd *ind=this.m_list_ind.At(i);
      ENUM_INDICATOR line_type;
      MqlParam line_params[];
      if(ind!=NULL && ind.TypeIndicator()==type && this.LineIdentity(ind,line_type,line_params) && this.m_IndicatorTemplateManager.ParamsText(line_type,line_params)==params_text)
         return ind;
     }
   return NULL;
  }
 int CChartObj::SourceWindow(const ENUM_INDICATOR type,const string params_text)
  {
   CWndInd *ind=this.IsIndicatorShownOnChart(type,params_text);
   return (ind!=NULL && ind.WindowNum()>0 && ind.Index()==0 ? ind.WindowNum() : WRONG_VALUE);
  }
 bool CChartObj::SameOnChart(const CWndInd *first,const CWndInd *second) const
  {
   ENUM_INDICATOR first_type,second_type;
   MqlParam first_params[],second_params[];
   if(this.m_IndicatorTemplateManager==NULL || first==NULL || second==NULL || first.Name()!=second.Name())
      return false;
   first.GetIdentity(first_type,first_params);
   second.GetIdentity(second_type,second_params);
   return (first_type==second_type && this.m_IndicatorTemplateManager.ParamsText(first_type,first_params)==this.m_IndicatorTemplateManager.ParamsText(second_type,second_params));
  }
 //+------------------------------------------------------------------+
 //| Attach the indicator: trend group to the main window, the rest   |
 //| to a new subwindow; an MA on a source to the subwindow of the     |
 //| source, after it (the source is attached first when not shown)    |
 //+------------------------------------------------------------------+
 void CChartObj::ShowIndicatorOnChart(const ENUM_INDICATOR type,MqlParam &params[])
  {
   SIndicatorsRow catalog;
   if(this.m_IndicatorTemplateManager==NULL)
     {
      ::Print(__FUNCTION__," > IndicatorTemplateManager is not set");
      return;
     }
   this.m_IndicatorTemplateManager.Read_RAM(type,catalog);
   string indicator_name=catalog.name;
   if(indicator_name=="")
     {
      ::Print(__FUNCTION__," > indicator is not in the standard catalog: ",EnumToString(type));
      return;
     }
   MqlParam chart_params[];   // the params of the template as they are (FRAMA: IndicatorCreate wants its Shift, 4002 without it)
   ::ArrayResize(chart_params,::ArraySize(params));
   for(int i=0;i<::ArraySize(params);i++)
      chart_params[i]=params[i];
   //--- New in V5: an MA on a source takes the handle of the first line of the subwindow of the source
   int source_window=WRONG_VALUE;
   ENUM_INDICATOR source_type;
   string source_params;
   int applied=WRONG_VALUE;
   if(this.m_IndicatorTemplateManager.SourceOf(type,this.m_IndicatorTemplateManager.ParamsText(type,params),source_type,source_params,applied))
     {
      source_window=this.SourceWindow(source_type,source_params);
      MqlParam source_mql[];
      if(source_window<0 && this.m_IndicatorTemplateManager.ParamsFromText(source_type,source_params,source_mql))
        {
         this.ShowIndicatorOnChart(source_type,source_mql);
         source_window=this.SourceWindow(source_type,source_params);
        }
      if(source_window<0)
        {
         ::Print(DFUN,indicator_name," on ",source_params,": the source is not in a subwindow of its own");
         return;
        }
      chart_params[applied].integer_value=::ChartIndicatorGet(this.m_chart_id,source_window,::ChartIndicatorName(this.m_chart_id,source_window,0));   // never released (one owner: the chart)
     }
   int handle=::IndicatorCreate(this.Symbol(),this.Timeframe(),type,::ArraySize(chart_params),chart_params);
   if(handle==INVALID_HANDLE)
     {
      ::Print(DFUN,indicator_name," with ",::ArraySize(chart_params)," params: IndicatorCreate failed, error ",::GetLastError());
      return;
     }
   bool overlay=this.m_IndicatorTemplateManager.IsOverlay(type);
   int sub_window=(source_window>0 ? source_window : overlay ? 0 : (int)::ChartGetInteger(this.m_chart_id,CHART_WINDOWS_TOTAL));
   if(!::ChartIndicatorAdd(this.m_chart_id,sub_window,handle))
     {
      ::Print(DFUN,indicator_name,": ChartIndicatorAdd failed, error ",::GetLastError());
      return;
     }
   this.Refresh();   // the list has the new line (an MA on it next finds its source)
  }
 //+------------------------------------------------------------------+
 //| Detach the first indicator with this type and parameters         |
 //+------------------------------------------------------------------+
 void CChartObj::SyncIndicatorOnChart(const ENUM_INDICATOR type,const string params_text,const bool deleted)
  {
   MqlParam params[];
   if(!this.m_IndicatorTemplateManager.ParamsFromText(type,params_text,params))
      return;
   const bool shown=(this.IsIndicatorShownOnChart(type,params_text)!=NULL);
   CIndicatorSetting *setting=this.m_IndicatorTemplateManager.Read_RAM(type,params_text);
   const bool wanted=(!deleted && setting!=NULL && setting.ShowOnChart());
   if(wanted && !shown)
      this.ShowIndicatorOnChart(type,params);
   else if(!wanted && shown)
      this.RemoveIndicatorFromChart(type,params_text);
  }
 void CChartObj::RemoveIndicatorFromChart(const ENUM_INDICATOR type,const string params_text)
  {
   CWndInd *ind=this.IsIndicatorShownOnChart(type,params_text);
   if(this.m_IndicatorTemplateManager==NULL || ind==NULL)
      return;
   const int win=ind.WindowNum();
   string names[];   // the list is read again after the deletes: the names are taken first
   //--- Change in V5 (was the average of Volumes): the first line of a subwindow is the source of the MAs after it, they go with it (as MT5)
   if(win>0 && ind.Index()==0)
      for(int i=0;i<this.m_list_ind.Total();i++)
        {
         CWndInd *reader=this.m_list_ind.At(i);
         if(reader!=NULL && reader.WindowNum()==win && reader.Index()>0 && this.m_IndicatorTemplateManager.TakesSource(reader.TypeIndicator()))
           {
            ::ArrayResize(names,::ArraySize(names)+1);
            names[::ArraySize(names)-1]=reader.Name();
           }
        }
   ::ArrayResize(names,::ArraySize(names)+1);
   names[::ArraySize(names)-1]=ind.Name();
   for(int i=0;i<::ArraySize(names);i++)
      ::ChartIndicatorDelete(this.m_chart_id,win,names[i]);
   this.Refresh();   // the lines gone: their templates are told (show_on_chart off)
  }
#endif // CCHARTOBJ_MQH_IMPLEMENTATION
#endif // __CHARTOBJ_MQH__
