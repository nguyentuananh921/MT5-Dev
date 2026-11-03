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
//+------------------------------------------------------------------+
//--- The chart the EA runs on. Methods come from V3 one by one when a class asks for them
#ifndef __CHARTOBJ_MQH__
#define __CHARTOBJ_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "..\Bases\BaseObj.mqh"
 #include "..\Defines\EventDefines.mqh"
 #include "WndInd.mqh"
 #include "..\..\Services\DELib\IndicatorDELib.mqh"
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
    bool              m_object_created;                            // CHART_OBJ_EVENT_OBJECTS_CHANGE is on its way: the other "autotrade" objects of the same trade are not told again
   //--- Create and send the chart event of an indicator to the control program chart
    void              SendEvent(const ENUM_CHART_OBJ_EVENT event,CWndInd *ind);
   public:
                      CChartObj(const long chart_id);
   //--- Return the list of the indicators of all chart windows
    CArrayObj        *GetList(void)                                   { return &this.m_list_ind;                                          }
   //--- Return (1) the last one added and (2) the changed indicator (its old type and parameters), (3) the indicator by its index in the specified chart window
    CWndInd          *GetLastAddedIndicator(void)                     { return this.m_list_ind.At(this.m_list_ind.Total()-1);             }
    CWndInd          *GetLastChangedIndicator(void)                   { return this.m_list_ind_param.At(this.m_list_ind_param.Total()-1); }
    CWndInd          *GetIndicator(const int win_num,const int ind_index);
   //--- Compare the indicators of every chart window with the list: add, remove or change them, and send the event of each (not at the start, the first read is no news)
    void              Refresh(const bool send_events=true);
   //--- Event Rule: (1) the chart changed (CHARTEVENT_CHART_CHANGE: an indicator added, removed or changed): Refresh, (2) an object of a trade made by the
   //--- terminal (CHARTEVENT_OBJECT_CREATE of "autotrade ...", DoEasy CChartObjectsControl): CHART_OBJ_EVENT_OBJECTS_CHANGE once for the objects of the trade
    void              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Whether an indicator of the chart is a row of its own: the MA drawn over Volumes is a part of it, its Applied Price is not a price
    bool              ChartIdentity(const ENUM_INDICATOR type,MqlParam &params[]) const;
   //--- The parameters of the indicator the chart holds: Volumes keeps only its Applied Volume (its MA period is for the average drawn with it)
    void              ChartParams(const ENUM_INDICATOR type,MqlParam &params[],MqlParam &out[]) const;
   //--- (1) Check, (2) attach and (3) detach an indicator of the chart by its type and parameters
    bool              IsIndicatorShownOnChart(const ENUM_INDICATOR type,MqlParam &params[]);
    void              ShowIndicatorOnChart(const ENUM_INDICATOR type,MqlParam &params[]);
    void              RemoveIndicatorFromChart(const ENUM_INDICATOR type,MqlParam &params[]);
    long              ID(void)                                  const { return this.m_chart_id;                                       }
    string            Symbol(void)                              const { return ::ChartSymbol(this.m_chart_id);                        }
    ENUM_TIMEFRAMES   Timeframe(void)                           const { return (ENUM_TIMEFRAMES)::ChartPeriod(this.m_chart_id);       }
   //--- Set the chart symbol and timeframe
    bool              SetSymbol(const string symbol,const ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT);
  };
#endif // CCHARTOBJ_MQH_DECLARATION
#ifndef CCHARTOBJ_MQH_IMPLEMENTATION
#define CCHARTOBJ_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Constructor                                                      |
 //+------------------------------------------------------------------+
 CChartObj::CChartObj(const long chart_id) : m_chart_id(chart_id==0 ? ::ChartID() : chart_id),m_object_created(false)
  {
   this.m_object_type=OBJECT_DE_TYPE_CHART;
   ::ChartSetInteger(this.m_chart_id,CHART_EVENT_OBJECT_CREATE,true);   // the terminal tells the objects it makes (V2 CChartObjectsControl)
   this.Refresh(false);   // the indicators already on the chart
   this.m_object_created=::EventChartCustom(this.m_chart_id,(ushort)CHART_OBJ_EVENT_OBJECTS_CHANGE,::ObjectsTotal(this.m_chart_id),0.0,"");   // a TF change redraws "autotrade" without a create event
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
   //--- the same indicator: the list takes the object of the chart, it knows where the indicator is now
   for(int j=0;j<now_total;j++)
     {
      CWndInd *now=current.At(j);
      for(int k=0;k<old_total && !present[j];k++)
        {
         CWndInd *old=this.m_list_ind.At(k);
         if(listed[k] || old==NULL || !old.SameIdentity(now))
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
   for(int j=0;j<now_total;j++)
     {
      if(present[j])
         continue;
      CWndInd *now=current.At(j);
      if(!this.m_list_ind.Add(now))
         continue;
      taken[j]=true;
      if(send_events)
         this.SendEvent(CHART_OBJ_EVENT_CHART_WND_IND_ADD,now);
     }
   //--- removed
   for(int k=old_total-1;k>WRONG_VALUE;k--)
     {
      CWndInd *old=this.m_list_ind.At(k);
      if(listed[k] || old==NULL)
         continue;
      if(send_events)
         this.SendEvent(CHART_OBJ_EVENT_CHART_WND_IND_DEL,old);
      this.m_list_ind.Delete(k);
     }
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
   if(id==CHARTEVENT_CHART_CHANGE)
     {
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
   ::EventChartCustom(::ChartID(),(ushort)event,ind.Index(),ind.WindowNum(),ind.Name());
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
   return true;
  }
 //+------------------------------------------------------------------+
 //| The MA drawn over Volumes takes its data from the handle of the  |
 //| Volumes: its Applied Price is not a price, it is no row          |
 //+------------------------------------------------------------------+
 bool CChartObj::ChartIdentity(const ENUM_INDICATOR type,MqlParam &params[]) const
  {
   if(type==IND_MA && ::ArraySize(params)>3 && (params[3].integer_value<PRICE_CLOSE || params[3].integer_value>PRICE_WEIGHTED))
      return false;
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
 //| The parameters the chart indicator is made with: Volumes keeps   |
 //| only its Applied Volume (the MA period is for the average),      |
 //| FRAMA drops its Shift (the chart holds period, applied price)    |
 //+------------------------------------------------------------------+
 void CChartObj::ChartParams(const ENUM_INDICATOR type,MqlParam &params[],MqlParam &out[]) const
  {
   int count=(type==IND_VOLUMES ? ::MathMin(1,::ArraySize(params)) : ::ArraySize(params));
   ::ArrayResize(out,count);
   for(int i=0;i<count;i++)
      out[i]=params[i];
   if(type==IND_FRAMA && count==3)
     {
      out[1]=out[2];
      ::ArrayResize(out,2);
     }
  }
 //+------------------------------------------------------------------+
 //| The identity is read from the chart itself (CWndInd), not from   |
 //| the list: nothing is stale                                       |
 //+------------------------------------------------------------------+
 bool CChartObj::IsIndicatorShownOnChart(const ENUM_INDICATOR type,MqlParam &params[])
  {
   MqlParam wanted[];
   this.ChartParams(type,params,wanted);
   int windows=(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOWS_TOTAL);
   for(int win=0;win<windows;win++)
     {
      int total=::ChartIndicatorsTotal(this.m_chart_id,win);
      for(int k=0;k<total;k++)
        {
         CWndInd ind(this.m_chart_id,win,k);
         ENUM_INDICATOR line_type;
         MqlParam line_params[];
         if(ind.GetIdentity(line_type,line_params) && line_type==type && IsEqualMqlParamArrays(line_params,wanted))
            return true;
        }
     }
   return false;
  }
 //+------------------------------------------------------------------+
 //| Attach the indicator: trend group to the main window, the rest   |
 //| to a new subwindow                                               |
 //+------------------------------------------------------------------+
 void CChartObj::ShowIndicatorOnChart(const ENUM_INDICATOR type,MqlParam &params[])
  {
   MqlParam chart_params[];
   this.ChartParams(type,params,chart_params);
   if(type==IND_FRAMA)   // IndicatorCreate wants the Shift (4002 without it), the chart holds FRAMA without it
     {
      ::ArrayResize(chart_params,::ArraySize(params));
      for(int i=0;i<::ArraySize(params);i++)
         chart_params[i]=params[i];
     }
   int handle=::IndicatorCreate(this.Symbol(),this.Timeframe(),type,::ArraySize(chart_params),chart_params);
   if(handle==INVALID_HANDLE)
     {
      ::Print(DFUN,GetIndicatorNameForType(type)," with ",::ArraySize(chart_params)," params: IndicatorCreate failed, error ",::GetLastError());
      return;
     }
   int sub_window=(GetIndicatorGroupForType(type)==INDICATOR_GROUP_TREND ? 0 : (int)::ChartGetInteger(this.m_chart_id,CHART_WINDOWS_TOTAL));
   if(!::ChartIndicatorAdd(this.m_chart_id,sub_window,handle))
      ::Print(DFUN,GetIndicatorNameForType(type),": ChartIndicatorAdd failed, error ",::GetLastError());
   //--- Volumes comes with its moving average: it takes the data of the volumes and goes to the same window
   if(type==IND_VOLUMES && ::ArraySize(params)>2)
     {
      int average=::iMA(this.Symbol(),this.Timeframe(),(int)params[1].integer_value,0,(ENUM_MA_METHOD)params[2].integer_value,handle);
      if(average!=INVALID_HANDLE)
         ::ChartIndicatorAdd(this.m_chart_id,sub_window,average);
     }
  }
 //+------------------------------------------------------------------+
 //| Detach the first indicator with this type and parameters         |
 //+------------------------------------------------------------------+
 void CChartObj::RemoveIndicatorFromChart(const ENUM_INDICATOR type,MqlParam &params[])
  {
   MqlParam wanted[];
   this.ChartParams(type,params,wanted);
   int windows=(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOWS_TOTAL);
   for(int win=0;win<windows;win++)
     {
      int total=::ChartIndicatorsTotal(this.m_chart_id,win);
      for(int k=0;k<total;k++)
        {
         CWndInd ind(this.m_chart_id,win,k);
         ENUM_INDICATOR line_type;
         MqlParam line_params[];
         if(ind.GetIdentity(line_type,line_params) && line_type==type && IsEqualMqlParamArrays(line_params,wanted))
           {
            //--- the moving average of the volumes goes first: it lives in the same window, after the volumes
            if(type==IND_VOLUMES)
               for(int a=::ChartIndicatorsTotal(this.m_chart_id,win)-1;a>k;a--)
                 {
                  string average_name=::ChartIndicatorName(this.m_chart_id,win,a);
                  if(::StringFind(average_name,"MA(")==0)
                     ::ChartIndicatorDelete(this.m_chart_id,win,average_name);
                 }
            ::ChartIndicatorDelete(this.m_chart_id,win,ind.Name());
            return;
           }
        }
     }
  }
#endif // CCHARTOBJ_MQH_IMPLEMENTATION
#endif // __CHARTOBJ_MQH__
