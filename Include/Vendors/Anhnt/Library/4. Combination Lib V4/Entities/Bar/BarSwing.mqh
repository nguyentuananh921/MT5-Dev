//+------------------------------------------------------------------+
//|                                                     BarSwing.mqh |
//+------------------------------------------------------------------+
//--- Change from V2 BarSwingSeries.mqh (CBarSwingSeries : CBaseObj, its own properties and a pointer to its pivot bar): a CBar with a swing now, the pivot bar is itself
//--- and InformationType (Swing High / Swing Low) and InformationSide say what was found on it. The rules of V2 CBarSwingControl are its methods (Python
//--- swing.py says the same). CBarControl holds one as the judge and keeps a CBarSwing for each swing found. CBarBOS and CBarCHoCH use its FindBroken methods
#ifndef __BARSWING_MQH__
#define __BARSWING_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "Bar.mqh"
#ifndef CBARSWING_MQH_DECLARATION
#define CBARSWING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| A swing point (High or Low) found on a bar                        |
 //+------------------------------------------------------------------+
 class CBarSwing : public CBar
  {
   private:
    CArrayObj        *m_list;                // The judge only: the bars judged (CBar, the oldest first), the series holds them
    string            m_param_name[];        // The judge only: the parameters of the type judged now (Setting_BarSetup)
    double            m_param_value[];
   //--- The value of a parameter of the type judged now (0 when there is none)
    double            Param(const string name) const;
   //--- The price a swing is found on at the index: High / TopBody, Low / BottomBody (price_basis)
    double            Price(const int index,const bool high) const;
   //--- The pivot of the swing broken by the close of the bar at the index (-1: none) and the price of the swing before it of the same kind
    int               FindBroken(const int index,const bool high,double &price,double &before) const;
   public:
   //--- Does this class find the type
    static bool       IsFound(const ENUM_BAR_INFOR_TYPE type) { return (type==BAR_INFOR_TYPE_SWING_HIGH || type==BAR_INFOR_TYPE_SWING_LOW); }
   //--- The judge: the bars and the parameters of the type judged now
    void              SetJudge(CArrayObj *list,const string &names[],const double &values[]);
   //--- The method of the type judges the bar at the index of the list of the judge (CBar::Calculate calls it)
    virtual ENUM_SIGNAL_DIRECTION Find(const ENUM_BAR_INFOR_TYPE type,const int index) const;
   //--- The event of a new swing, a row of this class
    virtual ushort    Event(void) const { return (ushort)SERIES_EVENTS_SWING; }
    virtual CBar     *NewRow(CBar *bar,const long type,const long group,const long direction) const { return new CBarSwing(bar,type,group,direction); }
   //--- The side when the bar at the index confirms the swing swing_strength bars before it, SIGNAL_DIRECTION_NO_PATTERN when it does not
    ENUM_SIGNAL_DIRECTION FindSwingHigh(const int index) const;
    ENUM_SIGNAL_DIRECTION FindSwingLow(const int index) const;
   //--- Does the close of the bar at the index break the newest Swing High (Low) no close broke yet (V2 CMarketStructureControl). higher: above the Swing High
   //--- before it (HH, else LH); lower: below the Swing Low before it (LL, else HL). The swing before must be confirmed at most STRUCTURE_LOOKBACK bars back
    bool              FindBrokenHigh(const int index,bool &higher) const;
    bool              FindBrokenLow(const int index,bool &lower) const;
   //--- How many bars before the bar that confirms it the swing is (its row is on the pivot bar)
    virtual int       Shift(void) const { return (int)::fmax(1,this.Param(BAR_PARAM_SWING_STRENGTH)); }
   //--- The judge, and a row: the pivot bar with the type, its group and the side found on it
                      CBarSwing(void) : m_list(NULL) { this.m_object_type=OBJECT_DE_TYPE_SERIES_SWING; }
                      CBarSwing(CBar *bar,const long type,const long group,const long direction);
  };
#endif // CBARSWING_MQH_DECLARATION
#ifndef CBARSWING_MQH_IMPLEMENTATION
#define CBARSWING_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| A row: the pivot bar joined with the type and the side            |
 //+------------------------------------------------------------------+
 CBarSwing::CBarSwing(CBar *bar,const long type,const long group,const long direction) : m_list(NULL)
  {
   this.SetBar(bar);
   this.m_object_type=OBJECT_DE_TYPE_SERIES_SWING;
   this.SetProperty(BAR_PROP_INFOR_GROUP,group);
   this.SetProperty(BAR_PROP_INFOR_TYPE,type);
   this.SetProperty(BAR_PROP_SIGNAL_DIRECTION,direction);
  }
 void CBarSwing::SetJudge(CArrayObj *list,const string &names[],const double &values[])
  {
   this.m_list=list;
   ::ArrayCopy(this.m_param_name,names);
   ::ArrayCopy(this.m_param_value,values);
  }
 //+------------------------------------------------------------------+
 //| The value of a parameter of the type judged now                  |
 //+------------------------------------------------------------------+
 double CBarSwing::Param(const string name) const
  {
   for(int i=0;i<::ArraySize(this.m_param_name);i++)
      if(this.m_param_name[i]==name)
         return this.m_param_value[i];
   ::Print("MY DEBUG    CBarSwing::Param the parameter ",name," is not in Setting_BarSetup");
   return 0.0;
  }
 //+------------------------------------------------------------------+
 //| The price a swing is found on (swing.py swing_prices)             |
 //+------------------------------------------------------------------+
 double CBarSwing::Price(const int index,const bool high) const
  {
   CBar *bar=this.m_list.At(index);
   if(bar==NULL)
      return 0.0;
   bool use_wick=((int)this.Param(BAR_PARAM_PRICE_BASIS)==SWING_PRICE_BASIS_WICK);
   if(high)
      return (use_wick ? bar.High() : bar.TopBody());
   return (use_wick ? bar.Low() : bar.BottomBody());
  }
 ENUM_SIGNAL_DIRECTION CBarSwing::Find(const ENUM_BAR_INFOR_TYPE type,const int index) const
  {
   if(this.m_list==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   switch(type)
     {
      case BAR_INFOR_TYPE_SWING_HIGH:                  return this.FindSwingHigh(index);
      case BAR_INFOR_TYPE_SWING_LOW:                   return this.FindSwingLow(index);
      default:                               return SIGNAL_DIRECTION_NO_PATTERN;
     }
  }
 //+------------------------------------------------------------------+
 //| Swing High (Sell): the bar swing_strength before this one is higher than the bars on each side; this bar confirms it (swing.py)
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarSwing::FindSwingHigh(const int index) const
  {
   int strength=this.Shift();
   int pivot=index-strength;
   if(this.m_list==NULL || pivot<strength || index>=this.m_list.Total())
      return SIGNAL_DIRECTION_NO_PATTERN;
   double price=this.Price(pivot,true);
   for(int i=pivot-strength;i<=index;i++)
     {
      if(i==pivot)
         continue;
      if(this.m_list.At(i)==NULL || !(price>this.Price(i,true)))
         return SIGNAL_DIRECTION_NO_PATTERN;
     }
   return SIGNAL_DIRECTION_SELL;
  }
 //+------------------------------------------------------------------+
 //| Swing Low (Buy): the bar swing_strength before this one is lower than the bars on each side; this bar confirms it (swing.py)
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarSwing::FindSwingLow(const int index) const
  {
   int strength=this.Shift();
   int pivot=index-strength;
   if(this.m_list==NULL || pivot<strength || index>=this.m_list.Total())
      return SIGNAL_DIRECTION_NO_PATTERN;
   double price=this.Price(pivot,false);
   for(int i=pivot-strength;i<=index;i++)
     {
      if(i==pivot)
         continue;
      if(this.m_list.At(i)==NULL || !(price<this.Price(i,false)))
         return SIGNAL_DIRECTION_NO_PATTERN;
     }
   return SIGNAL_DIRECTION_BUY;
  }
 //+------------------------------------------------------------------+
 //| The swing broken by the close of the bar at the index: the newest |
 //| one confirmed at or before it, no close since its confirmation    |
 //| beyond it, the swing before it confirmed STRUCTURE_LOOKBACK bars  |
 //| back at most (structure.py breaks)                                |
 //+------------------------------------------------------------------+
 int CBarSwing::FindBroken(const int index,const bool high,double &price,double &before) const
  {
   if(this.m_list==NULL || index<0 || index>=this.m_list.Total())
      return -1;
   const int strength=this.Shift();
   const int oldest=(int)::fmax(0,index-STRUCTURE_LOOKBACK);
   int confirm=-1,confirm_before=-1;
   for(int k=index;k>=oldest && confirm_before<0;k--)
     {
      ENUM_SIGNAL_DIRECTION side=(high ? this.FindSwingHigh(k) : this.FindSwingLow(k));
      if(side==SIGNAL_DIRECTION_NO_PATTERN)
         continue;
      if(confirm<0)
         confirm=k;
      else
         confirm_before=k;
     }
   if(confirm_before<0)
      return -1;   // no swing before it in the lookback: not labelled, no break (V2: a Swing without a label gives no event)
   price=this.Price(confirm-strength,high);
   before=this.Price(confirm_before-strength,high);
   for(int j=confirm;j<=index;j++)
     {
      CBar *bar=this.m_list.At(j);
      if(bar==NULL)
         return -1;
      bool beyond=(high ? bar.Close()>price : bar.Close()<price);
      if(beyond)
         return (j==index ? confirm-strength : -1);   // a close before this bar broke it already
     }
   return -1;
  }
 bool CBarSwing::FindBrokenHigh(const int index,bool &higher) const
  {
   double price=0.0,before=0.0;
   if(this.FindBroken(index,true,price,before)<0)
      return false;
   higher=(price>before);   // swing.py: HH when above the one before, else LH
   return true;
  }
 bool CBarSwing::FindBrokenLow(const int index,bool &lower) const
  {
   double price=0.0,before=0.0;
   if(this.FindBroken(index,false,price,before)<0)
      return false;
   lower=!(price>before);   // swing.py: HL when above the one before, else LL
   return true;
  }
#endif // CBARSWING_MQH_IMPLEMENTATION
#endif // __BARSWING_MQH__
