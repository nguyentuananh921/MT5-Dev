//+------------------------------------------------------------------+
//|                                                LifecycleSync.mqh |
//+------------------------------------------------------------------+
#ifndef __LIFECYCLESYNC_MQH__
#define __LIFECYCLESYNC_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #define LIFECYCLE_OBJECT_NAME      "LC_"
 #define LIFECYCLE_DRAW_BARS        (SMC_DRAW_BARS)    // a dead object older than this is not drawn
 #define LIFECYCLE_KINDS            (7)                // the values of ENUM_LIFECYCLE_OBJECT_KIND
#ifndef CLIFECYCLESYNC_MQH_DECLARATION
#define CLIFECYCLESYNC_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Draws what Python says about the lifecycle of the trendlines and |
 //| the zones: one CTrendlineLine / CZoneTagBox per object. The colour |
 //| is the side (support = Buy colour, resistance = Sell colour). A  |
 //| trendline is alive until price breaks it: solid and 3 px, in the |
 //| colour of its side. A broken line is dead: grey, 1 px, it stops |
 //| where it died. The step and the counts are in its tooltip.      |
 //| A zone: filled = alive, stronger fill = touched, hollow =      |
 //| broken, grey = dead (it stops where it died)                   |
 //| The data is in CLifecycleCollection (pure data); this class only |
 //| reads it                                                         |
 //+------------------------------------------------------------------+
 class CLifecycleSync : public CBaseObj
  {
   private:
     CGraphElementsCollection  *m_GraphElementsCollection;   // EA owns
     CLifecycleCollection      *m_LifecycleCollection;       // EA owns - the records Python sent
   //--- What is drawn, for each kind of object: supports, resistances, dead ones, and how many dead ones (0 = all)
     bool                       m_show_support[LIFECYCLE_KINDS];
     bool                       m_show_resistance[LIFECYCLE_KINDS];
     bool                       m_show_dead[LIFECYCLE_KINDS];
     int                        m_max_dead[LIFECYCLE_KINDS];
     int                        m_open_newest_buy[LIFECYCLE_KINDS];    // how many of the newest living zones of each kind and side (Demand, Supply...) are shown from the start
     int                        m_open_newest_sell[LIFECYCLE_KINDS];
     int                        m_nearest[LIFECYCLE_KINDS];      // how many living lines of a side, the nearest to the price, are drawn solid and long
   //--- The colours, for each kind: clrNONE for a side = the Buy / Sell colour of the Marker tab
     color                      m_support_color[LIFECYCLE_KINDS];
     color                      m_resistance_color[LIFECYCLE_KINDS];
     color                      m_dead_color[LIFECYCLE_KINDS];
     color                      SideColor(const CLifecycleSeries *last) const;
     CTrendlineLine            *FindLine(const string name) const;
     CZoneTagBox               *FindZone(const string name) const;
     CSmartMoneySync           *m_SmartMoney;                // EA owns - it draws the markers of the momentum candles
     void                       RemoveObject(const string name);
     void                       TrimDead(const ENUM_LIFECYCLE_OBJECT_KIND kind);
     bool                       OnChart(const CLifecycleSeries *record) const;   // the TF the chart shows: the others are held, not drawn
     bool                       Wanted(const CLifecycleSeries *last) const;
     string                     StateText(const CLifecycleSeries *last) const;
     string                     InfoText(const CLifecycleSeries *last) const;
     bool                       IsNearest(const CLifecycleSeries *last) const;
     bool                       DrawLine(CLifecycleSeries *last);
     bool                       DrawZone(CLifecycleSeries *last);
     ENUM_LIFECYCLE_OBJECT_KIND ZoneKindOfTag(const string words) const;
     bool                       DrawMomentum(CLifecycleSeries *last);
     bool                       Draw(CLifecycleSeries *last);
     int                        SyncKind(const ENUM_LIFECYCLE_OBJECT_KIND kind);
   public:
     void                       OnInitEvent(CGraphElementsCollection *collection,CLifecycleCollection *lifecycle);
     void                       SetSmartMoney(CSmartMoneySync *sync) { this.m_SmartMoney=sync; }
   //--- What is drawn (the inputs of the EA)
     void                       SetView(const ENUM_LIFECYCLE_OBJECT_KIND kind,const bool support,const bool resistance,const bool dead,const int max_dead,const int nearest=3);
     void                       SetColors(const ENUM_LIFECYCLE_OBJECT_KIND kind,const color support,const color resistance,const color dead);
     void                       SetOpenNewest(const ENUM_LIFECYCLE_OBJECT_KIND kind,const int buy_count,const int sell_count)
                                  {
                                   if((int)kind<0 || (int)kind>=LIFECYCLE_KINDS)
                                      return;
                                   this.m_open_newest_buy[kind]=(buy_count<0 ? 0 : buy_count);
                                   this.m_open_newest_sell[kind]=(sell_count<0 ? 0 : sell_count);
                                  }
   //--- The newest living zones of each kind are shown, the older ones folded; a zone the user opened or folded by hand stays as the user left it
     void                       OpenNewest(void);
   //--- Draw every object of the collection (after the first burst, when nothing was announced)
     void                       Sync(void);
   //--- A lifecycle event was announced: redraw the object it names
     void                       OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Remove every object this class drew
     void                       DeleteAll(void);
                                CLifecycleSync(void);
  };
#endif // CLIFECYCLESYNC_MQH_DECLARATION
#ifndef CLIFECYCLESYNC_MQH_IMPLEMENTATION
#define CLIFECYCLESYNC_MQH_IMPLEMENTATION
 CLifecycleSync::CLifecycleSync(void) : m_GraphElementsCollection(NULL),m_LifecycleCollection(NULL),m_SmartMoney(NULL)
  {
   for(int k=0;k<LIFECYCLE_KINDS;k++)
     {
      this.m_show_support[k]=true;
      this.m_show_resistance[k]=true;
      this.m_show_dead[k]=true;
      this.m_max_dead[k]=0;
      this.m_nearest[k]=3;
      this.m_open_newest_buy[k]=3;
      this.m_open_newest_sell[k]=3;
      this.m_support_color[k]=clrNONE;
      this.m_resistance_color[k]=clrNONE;
      this.m_dead_color[k]=clrGray;
     }
  }
 void CLifecycleSync::OnInitEvent(CGraphElementsCollection *collection,CLifecycleCollection *lifecycle)
  {
   this.m_GraphElementsCollection=collection;
   this.m_LifecycleCollection=lifecycle;
  }
 void CLifecycleSync::SetView(const ENUM_LIFECYCLE_OBJECT_KIND kind,const bool support,const bool resistance,const bool dead,const int max_dead,const int nearest=3)
  {
   if((int)kind<0 || (int)kind>=LIFECYCLE_KINDS)
      return;
   this.m_show_support[kind]=support;
   this.m_show_resistance[kind]=resistance;
   this.m_show_dead[kind]=dead;
   this.m_max_dead[kind]=max_dead;
   this.m_nearest[kind]=(nearest<1 ? 1 : nearest);
  }
 void CLifecycleSync::SetColors(const ENUM_LIFECYCLE_OBJECT_KIND kind,const color support,const color resistance,const color dead)
  {
   if((int)kind<0 || (int)kind>=LIFECYCLE_KINDS)
      return;
   this.m_support_color[kind]=support;
   this.m_resistance_color[kind]=resistance;
   this.m_dead_color[kind]=dead;
  }
 //--- The colour of the side of an object: its own input (clrNONE: blue for a support, red for a resistance)
 color CLifecycleSync::SideColor(const CLifecycleSeries *last) const
  {
   int kind=(int)last.Kind();
   bool buy=(last.Direction()==SIGNAL_BUY);
   color own=((kind>=0 && kind<LIFECYCLE_KINDS) ? (buy ? this.m_support_color[kind] : this.m_resistance_color[kind]) : clrNONE);
   if(own!=clrNONE)
      return own;
   return (buy ? clrDodgerBlue : clrRed);
  }
 CTrendlineLine *CLifecycleSync::FindLine(const string name) const
  {
   for(int i=this.m_GraphElementsCollection.ChildrenTotal()-1;i>=0;i--)
     {
      CTrendlineLine *line=dynamic_cast<CTrendlineLine *>(this.m_GraphElementsCollection.Child(i));
      if(line!=NULL && line.Name()==name)
         return line;
     }
   return NULL;
  }
 CZoneTagBox *CLifecycleSync::FindZone(const string name) const
  {
   for(int i=this.m_GraphElementsCollection.ChildrenTotal()-1;i>=0;i--)
     {
      CZoneTagBox *box=dynamic_cast<CZoneTagBox *>(this.m_GraphElementsCollection.Child(i));
      if(box!=NULL && box.Name()==name)
         return box;
     }
   return NULL;
  }
 //--- Delete the object of this name, whichever kind it is
 void CLifecycleSync::RemoveObject(const string name)
  {
   CGBaseObj *object=this.FindLine(name);
   if(object==NULL)
      object=this.FindZone(name);
   if(object==NULL)
      return;
   this.m_GraphElementsCollection.DeleteChild(object);
   delete object;
  }
 //+------------------------------------------------------------------+
 //| Keep the newest max_dead dead objects of a kind, delete the older|
 //+------------------------------------------------------------------+
 void CLifecycleSync::TrimDead(const ENUM_LIFECYCLE_OBJECT_KIND kind)
  {
   if((int)kind<0 || (int)kind>=LIFECYCLE_KINDS || this.m_max_dead[kind]<=0)
      return;
   while(true)
     {
      int dead=0;
      CGBaseObj *oldest=NULL;
      datetime oldest_time=0;
      for(int i=this.m_GraphElementsCollection.ChildrenTotal()-1;i>=0;i--)
        {
         CGBaseObj *child=this.m_GraphElementsCollection.Child(i);
         datetime dead_time=0;
         if(kind==LIFECYCLE_OBJECT_TRENDLINE)
           {
            CTrendlineLine *line=dynamic_cast<CTrendlineLine *>(child);
            if(line!=NULL)
               dead_time=line.DeadTime();
           }
         else if(kind==LIFECYCLE_OBJECT_ZONE || kind==LIFECYCLE_OBJECT_SUPPLYDEMAND || kind==LIFECYCLE_OBJECT_FVG)
           {
            CZoneTagBox *box=dynamic_cast<CZoneTagBox *>(child);   // the words on the tag tell which kind of zone it is
            if(box!=NULL)
              {
               ENUM_LIFECYCLE_OBJECT_KIND box_kind=((box.Kind()=="Demand" || box.Kind()=="Supply") ? LIFECYCLE_OBJECT_SUPPLYDEMAND :
                                                    (box.Kind()=="Bull FVG" || box.Kind()=="Bear FVG") ? LIFECYCLE_OBJECT_FVG : LIFECYCLE_OBJECT_ZONE);
               if(box_kind==kind)
                  dead_time=box.DeadTime();
              }
           }
         if(dead_time==0)
            continue;
         dead++;
         if(oldest==NULL || dead_time<oldest_time)
           {
            oldest=child;
            oldest_time=dead_time;
           }
        }
      if(dead<=this.m_max_dead[kind] || oldest==NULL)
         return;
      this.m_GraphElementsCollection.DeleteChild(oldest);
      delete oldest;
     }
  }
 //+------------------------------------------------------------------+
 //| What the inputs do not want, and a dead object older than the    |
 //| drawn bars, is not worth a chart object                          |
 //+------------------------------------------------------------------+
 bool CLifecycleSync::Wanted(const CLifecycleSeries *last) const
  {
   int kind=(int)last.Kind();
   if(kind<0 || kind>=LIFECYCLE_KINDS)
      return false;
   bool wanted=(last.Direction()==SIGNAL_BUY ? this.m_show_support[kind] : this.m_show_resistance[kind]);
   if(last.Event()==LIFECYCLE_EVENT_DEAD && (!this.m_show_dead[kind] || last.Time()<::iTime(::Symbol(),::Period(),LIFECYCLE_DRAW_BARS-1)))
      wanted=false;
   if(last.Event()==LIFECYCLE_EVENT_DEAD && last.DeadReason()==LIFECYCLE_DEAD_REPLACED)
      wanted=false;   // the lines of a newer swing took its place: it is not drawn
   return wanted;
  }
 //+------------------------------------------------------------------+
 //| The words of the tooltip: where the object is at                 |
 //+------------------------------------------------------------------+
 string CLifecycleSync::StateText(const CLifecycleSeries *last) const
  {
   string state="";
   switch(last.Event())
     {
      case LIFECYCLE_EVENT_BORN:        state="born";             break;
      case LIFECYCLE_EVENT_MODIFIED:    state="modified";         break;
      case LIFECYCLE_EVENT_TOUCHED:     state="touched, waiting"; break;
      case LIFECYCLE_EVENT_BOUNCED:     state="bounced";          break;
      case LIFECYCLE_EVENT_BROKEN:      state="broken";           break;
      case LIFECYCLE_EVENT_RESURRECTED: state="resurrected";      break;
      case LIFECYCLE_EVENT_SUPERSEDED:  state="superseded by a newer line"; break;
      case LIFECYCLE_EVENT_CONFIRMED:   state="confirmed by a swing"; break;
      case LIFECYCLE_EVENT_DEAD:        state=(last.DeadReason()==LIFECYCLE_DEAD_BROKEN ? "dead (broken)" : last.DeadReason()==LIFECYCLE_DEAD_REPLACED ? "replaced by a newer swing" : last.DeadReason()==LIFECYCLE_DEAD_EXPIRED ? "dead (expired)" :
                                               last.DeadReason()==LIFECYCLE_DEAD_OBSOLETE ? "dead (out of range)" : "dead"); break;
      default:                          state="";                 break;
     }
   return state;
  }
 string CLifecycleSync::InfoText(const CLifecycleSeries *last) const
  {
   int touches=this.m_LifecycleCollection.CountEvents(last.Kind(),last.Symbol(),last.Timeframe(),last.Direction(),last.OriginTime(),LIFECYCLE_EVENT_TOUCHED);
   int bounces=this.m_LifecycleCollection.CountEvents(last.Kind(),last.Symbol(),last.Timeframe(),last.Direction(),last.OriginTime(),LIFECYCLE_EVENT_BOUNCED);
   string text=this.StateText(last)+" | touched "+(string)touches+", bounced "+(string)bounces;
   return text;
  }
 //+------------------------------------------------------------------+
 //| Is it one of the nearest living lines of its side: the lines whose |
 //| value now is closest to the price are the ones it can break next  |
 //+------------------------------------------------------------------+
 bool CLifecycleSync::IsNearest(const CLifecycleSeries *last) const
  {
   datetime now=::iTime(::Symbol(),::Period(),0);
   double price=::iClose(::Symbol(),::Period(),0);
   CArrayObj current;   // points at the records, owns nothing
   this.m_LifecycleCollection.Current(current,last.Kind());
   double mine=0.0;
   int closer=0;
   for(int pass=0;pass<2;pass++)
     {
      for(int i=0;i<current.Total();i++)
        {
         CLifecycleSeries *record=current.At(i);
         if(record==NULL || !this.OnChart(record) || record.Direction()!=last.Direction() || record.Event()==LIFECYCLE_EVENT_DEAD || record.TimeB()==record.TimeA())
            continue;
         double value=record.PriceA()+(record.PriceB()-record.PriceA())/(double)(record.TimeB()-record.TimeA())*(double)(now-record.TimeA());
         double gap=::MathAbs(value-price);
         if(pass==0)
           {
            if(record.ObjectKey()==last.ObjectKey())
               mine=gap;
           }
         else if(gap<mine || (gap==mine && record.ObjectKey()<last.ObjectKey()))
            closer++;
        }
     }
   return closer<this.m_nearest[last.Kind()];
  }
 //+------------------------------------------------------------------+
 //| Draw (or update) the line of one trendline from its newest event |
 //+------------------------------------------------------------------+
 bool CLifecycleSync::DrawLine(CLifecycleSeries *last)
  {
   if(last==NULL || last.Kind()!=LIFECYCLE_OBJECT_TRENDLINE)
      return false;
   string name=LIFECYCLE_OBJECT_NAME+last.ObjectKey();
   if(!this.Wanted(last))
     {
      this.RemoveObject(name);
      return false;
     }
   bool dead=(last.Event()==LIFECYCLE_EVENT_DEAD);
   CTrendlineLine *line=this.FindLine(name);
   if(line==NULL)
     {
      line=new CTrendlineLine();
      if(line==NULL || !line.Create(::ChartID(),0,name) || !this.m_GraphElementsCollection.AddChild(line))
        {
         delete line;
         return false;
        }
     }
   bool buy=(last.Direction()==SIGNAL_BUY);
   //--- the colour is the side (support = Buy colour, resistance = Sell colour); a line that is alive is solid and thick, a dead one is grey and thin
   color colour=this.SideColor(last);
   ENUM_LINE_STYLE style=STYLE_SOLID;
   int width=3;
   bool ray_right=false;   // a line never goes on for ever: it is drawn to the newest swing + a few bars, and again at the next swing
   if(dead)
     {
      colour=this.m_dead_color[last.Kind()];
      width=1;   // it stops where it died
     }
   datetime time_1=last.TimeA(),time_2=last.TimeB();
   double price_1=last.PriceA(),price_2=last.PriceB();
   //--- a dead line stops where it died: the second point is the line itself at that time
   if(dead)
     {
      double slope=(time_2!=time_1 ? (price_2-price_1)/(double)(time_2-time_1) : 0.0);
      time_2=last.Time();
      price_2=price_1+slope*(double)(time_2-time_1);
     }
   else if(time_2!=time_1)   // alive: the nearest ones go to the current bar, the others are dashed and thin and stop at their own last swing
     {
      bool near=this.IsNearest(last);
      if(!near)
        {
         style=STYLE_DASH;
         width=1;
        }
      datetime end=(near ? ::iTime(::Symbol(),::Period(),0) : time_2);
      if(end>time_2)
        {
         price_2=price_1+(price_2-price_1)/(double)(time_2-time_1)*(double)(end-time_1);
         time_2=end;
        }
     }
   line.SetLine(time_1,price_1,time_2,price_2,colour,style,width,ray_right);
   line.SetDeadTime(dead ? last.Time() : 0);
   line.SetInfo((buy ? "Support" : "Resistance")+" trendline | "+this.InfoText(last));
   return true;
  }
 //--- The words on a tag tell which kind of zone it is
 ENUM_LIFECYCLE_OBJECT_KIND CLifecycleSync::ZoneKindOfTag(const string words) const
  {
   return ((words=="Demand" || words=="Supply") ? LIFECYCLE_OBJECT_SUPPLYDEMAND :
           (words=="Bull FVG" || words=="Bear FVG") ? LIFECYCLE_OBJECT_FVG : LIFECYCLE_OBJECT_ZONE);
  }
 //+------------------------------------------------------------------+
 //| Of the living zones with the same words on their tags (Demand,   |
 //| Supply, Bull FVG...) the newest m_open_newest are opened, the    |
 //| others folded: the newest is the one that starts last            |
 //+------------------------------------------------------------------+
 void CLifecycleSync::OpenNewest(void)
  {
   CZoneTagBox *boxes[];
   int n=0;
   for(int i=0;i<this.m_GraphElementsCollection.ChildrenTotal();i++)
     {
      CZoneTagBox *box=dynamic_cast<CZoneTagBox *>(this.m_GraphElementsCollection.Child(i));
      if(box==NULL)
         continue;
      ::ArrayResize(boxes,n+1);
      boxes[n++]=box;
     }
   for(int i=0;i<n;i++)
     {
      if(boxes[i].DeadTime()>0)
         continue;   // a dead zone is folded: it is opened by hand to look at it
      int newer=0;   // how many living zones of the same words start after this one (the later one in the list when they start together)
      for(int j=0;j<n;j++)
         if(j!=i && boxes[j].DeadTime()==0 && boxes[j].Kind()==boxes[i].Kind() &&
            (boxes[j].TimeStart()>boxes[i].TimeStart() || (boxes[j].TimeStart()==boxes[i].TimeStart() && j>i)))
            newer++;
      ENUM_LIFECYCLE_OBJECT_KIND kind=this.ZoneKindOfTag(boxes[i].Kind());
      boxes[i].OpenAuto(newer<(boxes[i].Direction()==SIGNAL_BUY ? this.m_open_newest_buy[kind] : this.m_open_newest_sell[kind]));
     }
  }
 //+------------------------------------------------------------------+
 //| A momentum candle: the marker on the candle (CSmartMoneySync)    |
 //+------------------------------------------------------------------+
 bool CLifecycleSync::DrawMomentum(CLifecycleSeries *last)
  {
   if(last==NULL || last.Kind()!=LIFECYCLE_OBJECT_MOMENTUM || this.m_SmartMoney==NULL || !this.Wanted(last))
      return false;
   return this.m_SmartMoney.MarkMomentum(last.Time(),last.Direction()==SIGNAL_BUY);
  }
 //+------------------------------------------------------------------+
 //| Draw (or update) the box of one zone from its newest event       |
 //+------------------------------------------------------------------+
 bool CLifecycleSync::DrawZone(CLifecycleSeries *last)
  {
   if(last==NULL || (last.Kind()!=LIFECYCLE_OBJECT_ZONE && last.Kind()!=LIFECYCLE_OBJECT_SUPPLYDEMAND && last.Kind()!=LIFECYCLE_OBJECT_FVG))
      return false;
   string name=LIFECYCLE_OBJECT_NAME+last.ObjectKey();
   if(!this.Wanted(last))
     {
      this.RemoveObject(name);
      return false;
     }
   bool dead=(last.Event()==LIFECYCLE_EVENT_DEAD);
   CZoneTagBox *box=this.FindZone(name);
   if(box==NULL)
     {
      box=new CZoneTagBox();
      if(box==NULL || !box.Create(::ChartID(),0,name) || !this.m_GraphElementsCollection.AddChild(box))
        {
         delete box;
         return false;
        }
     }
   bool buy=(last.Direction()==SIGNAL_BUY);
   color colour=this.SideColor(last);
   uchar alpha=70;
   bool filled=true;
   int width=1;
   switch(last.Event())
     {
      case LIFECYCLE_EVENT_TOUCHED: alpha=140; width=2;                                         break;   // stronger fill, thicker edge: touched, waiting
      case LIFECYCLE_EVENT_BROKEN:  filled=false;                                               break;   // hollow: broken, it may still come back
      case LIFECYCLE_EVENT_DEAD:    colour=this.m_dead_color[last.Kind()];                                             break;   // filled grey, from its birth to where it died
      default:                                                                                  break;   // filled: alive
     }
   //--- the zone starts at its pivot; a living one is open to the right, a dead one ends where it died
   //--- the words on the tag; the zones of one candle (the momentum candle: its demand / supply zone and its FVG) make one box of tags
   string kind=(last.Kind()==LIFECYCLE_OBJECT_SUPPLYDEMAND ? (buy ? "Demand" : "Supply") :
                last.Kind()==LIFECYCLE_OBJECT_FVG ? (buy ? "Bull FVG" : "Bear FVG") : (buy ? "Support" : "Resistance"));
   datetime candle=(last.Kind()==LIFECYCLE_OBJECT_SUPPLYDEMAND ? last.OriginTime() : last.Kind()==LIFECYCLE_OBJECT_FVG ? last.TimeA() : 0);
   box.SetZone(last.Top(),last.Bottom(),last.TimeA(),(dead ? last.Time() : 0),kind,last.Direction());
   box.SetZoneStyle(colour,alpha,filled,width);
   box.SetDeadTime(dead ? last.Time() : 0);
   box.SetGroupTime(candle);
   box.SetInfo(kind+"\n"+this.InfoText(last));   // the native tooltip of the zone when it is shown
   return true;
  }
 bool CLifecycleSync::OnChart(const CLifecycleSeries *record) const
  {
   return (record!=NULL && record.Timeframe()==(ENUM_TIMEFRAMES)::Period() && record.Symbol()==::Symbol());
  }
 bool CLifecycleSync::Draw(CLifecycleSeries *last)
  {
   if(!this.OnChart(last))
      return false;
   switch(last.Kind())
     {
      case LIFECYCLE_OBJECT_TRENDLINE: return this.DrawLine(last);
      case LIFECYCLE_OBJECT_ZONE:      return this.DrawZone(last);
      case LIFECYCLE_OBJECT_SUPPLYDEMAND: return this.DrawZone(last);
      case LIFECYCLE_OBJECT_FVG:       return this.DrawZone(last);
      case LIFECYCLE_OBJECT_MOMENTUM:  return this.DrawMomentum(last);
      default:                         return false;
     }
  }
 //+------------------------------------------------------------------+
 //| Draw every object of one kind: the living ones all, of the dead  |
 //| ones only the newest max_dead. Returns how many are drawn        |
 //+------------------------------------------------------------------+
 int CLifecycleSync::SyncKind(const ENUM_LIFECYCLE_OBJECT_KIND kind)
  {
   CArrayObj current;   // points at the records, owns nothing
   this.m_LifecycleCollection.Current(current,kind);
   CArrayObj dead;      // the dead ones
   dead.FreeMode(false);
   int drawn=0;
   for(int i=0;i<current.Total();i++)
     {
      CLifecycleSeries *record=current.At(i);
      if(!this.OnChart(record))
         continue;   // the collection holds every TF of the symbol, the chart shows its own
      if(record.Event()==LIFECYCLE_EVENT_DEAD)
         dead.Add(record);
      else if(this.Draw(record))
         drawn++;
     }
   dead.Sort(SORT_BY_LIFECYCLE_TIME);   // oldest first: the newest ones are at the end
   int kept=0;
   for(int i=dead.Total()-1;i>=0;i--)
     {
      CLifecycleSeries *record=dead.At(i);
      if(this.m_max_dead[kind]>0 && kept>=this.m_max_dead[kind])
         this.RemoveObject(LIFECYCLE_OBJECT_NAME+record.ObjectKey());
      else if(this.Draw(record))
         kept++;
     }
   return drawn+kept;
  }
 void CLifecycleSync::Sync(void)
  {
   int lines=this.SyncKind(LIFECYCLE_OBJECT_TRENDLINE);
   int zones=this.SyncKind(LIFECYCLE_OBJECT_ZONE)+this.SyncKind(LIFECYCLE_OBJECT_SUPPLYDEMAND)+this.SyncKind(LIFECYCLE_OBJECT_FVG);
   this.OpenNewest();
   CZoneTagBox::Arrange(this.m_GraphElementsCollection);   // the tags of the zones are put
   if(this.SyncKind(LIFECYCLE_OBJECT_MOMENTUM)>0)
      CCandleMarker::Arrange(this.m_GraphElementsCollection);   // the markers of the momentum candles are stacked with the others
   ::ChartRedraw();
   CMessage::ToFile(this.GetFolderName(),"CLifecycleSync","Sync",(string)lines+" trendline(s) and "+(string)zones+" zone(s) drawn of "+
                    (string)this.m_LifecycleCollection.Total()+" event(s) in the collection");
  }
 void CLifecycleSync::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id<CHARTEVENT_CUSTOM)
      return;
   int code=id-CHARTEVENT_CUSTOM;
   if(code<LIFECYCLE_EVENT_BORN || code>LIFECYCLE_EVENT_DEAD)
      return;
   CLifecycleSeries *last=this.m_LifecycleCollection.LastByKey(sparam);
   if(last==NULL)
      return;
   if(this.Draw(last))
     {
      if(last.Kind()==LIFECYCLE_OBJECT_MOMENTUM)
         CCandleMarker::Arrange(this.m_GraphElementsCollection);
      if(last.Kind()==LIFECYCLE_OBJECT_ZONE || last.Kind()==LIFECYCLE_OBJECT_SUPPLYDEMAND || last.Kind()==LIFECYCLE_OBJECT_FVG)
        {
         this.OpenNewest();   // a zone more: the oldest of the newest is folded
         CZoneTagBox::Arrange(this.m_GraphElementsCollection);   // a zone more, or one less: the tags are put again
        }
      if(last.Kind()==LIFECYCLE_OBJECT_TRENDLINE && (code==LIFECYCLE_EVENT_BORN || code==LIFECYCLE_EVENT_DEAD))   // a line more or less: the nearest ones of its side are chosen again
        {
         CArrayObj current;   // points at the records, owns nothing
         this.m_LifecycleCollection.Current(current,last.Kind());
         for(int i=0;i<current.Total();i++)
           {
            CLifecycleSeries *other=current.At(i);
            if(other!=NULL && other.ObjectKey()!=last.ObjectKey() && other.Direction()==last.Direction() && other.Event()!=LIFECYCLE_EVENT_DEAD)
               this.Draw(other);
           }
        }
      if(code==LIFECYCLE_EVENT_DEAD)
         this.TrimDead(last.Kind());
      ::ChartRedraw();
     }
  }
 void CLifecycleSync::DeleteAll(void)
  {
   for(int i=this.m_GraphElementsCollection.ChildrenTotal()-1;i>=0;i--)
     {
      CGBaseObj *child=this.m_GraphElementsCollection.Child(i);
      if(dynamic_cast<CTrendlineLine *>(child)==NULL && dynamic_cast<CZoneTagBox *>(child)==NULL)
         continue;
      this.m_GraphElementsCollection.DeleteChild(child);
      delete child;
     }
   ::ChartRedraw();
  }
#endif // CLIFECYCLESYNC_MQH_IMPLEMENTATION
#endif // __LIFECYCLESYNC_MQH__
