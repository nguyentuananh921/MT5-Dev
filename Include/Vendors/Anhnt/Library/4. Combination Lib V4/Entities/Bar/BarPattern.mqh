//+------------------------------------------------------------------+
//|                                                   BarPattern.mqh |
//|Change from V2 BarPattern.mqh (CBarPattern : CBaseObj,            |
//+------------------------------------------------------------------+
#ifndef __BARPATTERN_MQH__
#define __BARPATTERN_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "Bar.mqh"
#ifndef CBARPATTERN_MQH_DECLARATION
#define CBARPATTERN_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| A candle pattern (or a Momentum Candle) found on a bar            |
 //+------------------------------------------------------------------+
 class CBarPattern : public CBar
  {
   private:
    CArrayObj        *m_list;                // The judge only: the bars judged (CBar, the oldest first), the series holds them
    double            m_point;               // The judge only: the point of the symbol (the tolerance of Tweezer is in points)
    string            m_param_name[];        // The judge only: the parameters of the type judged now (Setting_BarSetup)
    double            m_param_value[];
   //--- The value of a parameter of the type judged now (0 when there is none)
    double            Param(const string name) const;
   //--- The side of the bar at an index of the list when it completes the pattern (its newest candle), SIGNAL_DIRECTION_NO_PATTERN when it does not
    ENUM_SIGNAL_DIRECTION FindHammer(const int index) const;
    ENUM_SIGNAL_DIRECTION FindHangingMan(const int index) const;
    ENUM_SIGNAL_DIRECTION FindInvertedHammer(const int index) const;
    ENUM_SIGNAL_DIRECTION FindShootingStar(const int index) const;
    ENUM_SIGNAL_DIRECTION FindDoji(const int index) const;
    ENUM_SIGNAL_DIRECTION FindDragonflyDoji(const int index) const;
    ENUM_SIGNAL_DIRECTION FindGravestoneDoji(const int index) const;
    ENUM_SIGNAL_DIRECTION FindSpinningTop(const int index) const;
    ENUM_SIGNAL_DIRECTION FindMarubozu(const int index) const;
    ENUM_SIGNAL_DIRECTION FindPinBar(const int index) const;
    ENUM_SIGNAL_DIRECTION FindHarami(const int index) const;
    ENUM_SIGNAL_DIRECTION FindHaramiCross(const int index) const;
    ENUM_SIGNAL_DIRECTION FindEngulfing(const int index) const;
    ENUM_SIGNAL_DIRECTION FindTweezer(const int index) const;
    ENUM_SIGNAL_DIRECTION FindPiercingPattern(const int index) const;
    ENUM_SIGNAL_DIRECTION FindDarkCloudCover(const int index) const;
    ENUM_SIGNAL_DIRECTION FindRails(const int index) const;
    ENUM_SIGNAL_DIRECTION FindOutsideBar(const int index) const;
    ENUM_SIGNAL_DIRECTION FindInsideBar(const int index) const;
    ENUM_SIGNAL_DIRECTION FindMorningStar(const int index) const;
    ENUM_SIGNAL_DIRECTION FindMorningDojiStar(const int index) const;
    ENUM_SIGNAL_DIRECTION FindEveningStar(const int index) const;
    ENUM_SIGNAL_DIRECTION FindEveningDojiStar(const int index) const;
    ENUM_SIGNAL_DIRECTION FindAbandonedBaby(const int index) const;
    ENUM_SIGNAL_DIRECTION FindPivotPointReversal(const int index) const;
    ENUM_SIGNAL_DIRECTION FindThreeWhiteSoldiers(const int index) const;
    ENUM_SIGNAL_DIRECTION FindThreeBlackCrows(const int index) const;
    ENUM_SIGNAL_DIRECTION FindThreeInsideUp(const int index) const;
    ENUM_SIGNAL_DIRECTION FindThreeInsideDown(const int index) const;
    ENUM_SIGNAL_DIRECTION FindThreeStars(const int index) const;
    ENUM_SIGNAL_DIRECTION FindMomentum(const int index) const;
   public:
   //--- Does this class find the type (the swings are CBarSwing')
    static bool       IsFound(const ENUM_BAR_INFOR_TYPE type);
   //--- The judge: the bars, the point of their symbol and the parameters of the type judged now
    void              SetJudge(CArrayObj *list,const double point,const string &names[],const double &values[]);
   //--- The method of the type judges the bar at the index of the list of the judge (CBar::Calculate calls it)
    virtual ENUM_SIGNAL_DIRECTION Find(const ENUM_BAR_INFOR_TYPE type,const int index) const;
   //--- A row of this class (the event is CBar's: SERIES_EVENTS_PATTERN)
    virtual CBar     *NewRow(CBar *bar,const long type,const long group,const long direction) const { return new CBarPattern(bar,type,group,direction); }
   //--- The judge, and a row: the bar with the type, its group and the side found on it
                      CBarPattern(void) : m_list(NULL),m_point(0.0) { this.m_object_type=OBJECT_DE_TYPE_SERIES_PATTERN; }
                      CBarPattern(CBar *bar,const long type,const long group,const long direction);
  };
#endif // CBARPATTERN_MQH_DECLARATION
#ifndef CBARPATTERN_MQH_IMPLEMENTATION
#define CBARPATTERN_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| A row: the bar joined with the type and the side found on it      |
 //+------------------------------------------------------------------+
 CBarPattern::CBarPattern(CBar *bar,const long type,const long group,const long direction) : m_list(NULL),m_point(0.0)
  {
   this.SetBar(bar);
   this.m_object_type=OBJECT_DE_TYPE_SERIES_PATTERN;
   this.SetProperty(BAR_PROP_INFOR_GROUP,group);
   this.SetProperty(BAR_PROP_INFOR_TYPE,type);
   this.SetProperty(BAR_PROP_SIGNAL_DIRECTION,direction);
  }
 //+------------------------------------------------------------------+
 //| The types this class finds                                       |
 //+------------------------------------------------------------------+
 bool CBarPattern::IsFound(const ENUM_BAR_INFOR_TYPE type)
  {
   return ((type>=BAR_INFOR_TYPE_HAMMER && type<=BAR_INFOR_TYPE_THREE_STARS) ||
           (type>=BAR_INFOR_TYPE_PIN_BAR && type<=BAR_INFOR_TYPE_PIVOT_POINT_REVERSAL) ||
           type==BAR_INFOR_TYPE_MOMENTUM_CANDLE);
  }
 void CBarPattern::SetJudge(CArrayObj *list,const double point,const string &names[],const double &values[])
  {
   this.m_list=list;
   this.m_point=point;
   ::ArrayCopy(this.m_param_name,names);
   ::ArrayCopy(this.m_param_value,values);
  }
 //+------------------------------------------------------------------+
 //| The value of a parameter of the type judged now                  |
 //+------------------------------------------------------------------+
 double CBarPattern::Param(const string name) const
  {
   for(int i=0;i<::ArraySize(this.m_param_name);i++)
      if(this.m_param_name[i]==name)
         return this.m_param_value[i];
   ::Print("MY DEBUG    CBarPattern::Param the parameter ",name," is not in Setting_BarSetup");
   return 0.0;
  }
 //+------------------------------------------------------------------+
 //| The method of the type judges the bar at the index               |
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::Find(const ENUM_BAR_INFOR_TYPE type,const int index) const
  {
   if(this.m_list==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   switch(type)
     {
      case BAR_INFOR_TYPE_HAMMER:                      return this.FindHammer(index);
      case BAR_INFOR_TYPE_HANGING_MAN:                 return this.FindHangingMan(index);
      case BAR_INFOR_TYPE_INVERTED_HAMMER:             return this.FindInvertedHammer(index);
      case BAR_INFOR_TYPE_SHOOTING_STAR:               return this.FindShootingStar(index);
      case BAR_INFOR_TYPE_DOJI:                        return this.FindDoji(index);
      case BAR_INFOR_TYPE_DRAGONFLY_DOJI:              return this.FindDragonflyDoji(index);
      case BAR_INFOR_TYPE_GRAVESTONE_DOJI:             return this.FindGravestoneDoji(index);
      case BAR_INFOR_TYPE_SPINNING_TOP:                return this.FindSpinningTop(index);
      case BAR_INFOR_TYPE_MARUBOZU:                    return this.FindMarubozu(index);
      case BAR_INFOR_TYPE_PIN_BAR:                     return this.FindPinBar(index);
      case BAR_INFOR_TYPE_HARAMI:                      return this.FindHarami(index);
      case BAR_INFOR_TYPE_HARAMI_CROSS:                return this.FindHaramiCross(index);
      case BAR_INFOR_TYPE_ENGULFING:                   return this.FindEngulfing(index);
      case BAR_INFOR_TYPE_TWEEZER:                     return this.FindTweezer(index);
      case BAR_INFOR_TYPE_PIERCING_PATTERN:            return this.FindPiercingPattern(index);
      case BAR_INFOR_TYPE_DARK_CLOUD_COVER:            return this.FindDarkCloudCover(index);
      case BAR_INFOR_TYPE_RAILS:                       return this.FindRails(index);
      case BAR_INFOR_TYPE_OUTSIDE_BAR:                 return this.FindOutsideBar(index);
      case BAR_INFOR_TYPE_INSIDE_BAR:                  return this.FindInsideBar(index);
      case BAR_INFOR_TYPE_MORNING_STAR:                return this.FindMorningStar(index);
      case BAR_INFOR_TYPE_MORNING_DOJI_STAR:           return this.FindMorningDojiStar(index);
      case BAR_INFOR_TYPE_EVENING_STAR:                return this.FindEveningStar(index);
      case BAR_INFOR_TYPE_EVENING_DOJI_STAR:           return this.FindEveningDojiStar(index);
      case BAR_INFOR_TYPE_ABANDONED_BABY:              return this.FindAbandonedBaby(index);
      case BAR_INFOR_TYPE_PIVOT_POINT_REVERSAL:        return this.FindPivotPointReversal(index);
      case BAR_INFOR_TYPE_THREE_WHITE_SOLDIERS:        return this.FindThreeWhiteSoldiers(index);
      case BAR_INFOR_TYPE_THREE_BLACK_CROWS:           return this.FindThreeBlackCrows(index);
      case BAR_INFOR_TYPE_THREE_INSIDE_UP:             return this.FindThreeInsideUp(index);
      case BAR_INFOR_TYPE_THREE_INSIDE_DOWN:           return this.FindThreeInsideDown(index);
      case BAR_INFOR_TYPE_THREE_STARS:                 return this.FindThreeStars(index);
      case BAR_INFOR_TYPE_MOMENTUM_CANDLE:             return this.FindMomentum(index);
      default:                               return SIGNAL_DIRECTION_NO_PATTERN;
     }
  }
 //+------------------------------------------------------------------+
 //| Hammer (Buy): small body, long lower shadow, short upper shadow
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindHammer(const int index) const
  {
   CBar *bar=this.m_list.At(index);
   if(bar==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(!(bar.RatioBodyToCandleSize()<=this.Param(BAR_PARAM_BODY_MAX) && bar.RatioLowerShadowToCandleSize()>=this.Param(BAR_PARAM_LOWER_SHADOW_MIN) && bar.RatioUpperShadowToCandleSize()<=this.Param(BAR_PARAM_UPPER_SHADOW_MAX)))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_BUY;
  }
 //+------------------------------------------------------------------+
 //| Hanging Man (Sell): the shape of the Hammer, its own parameters
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindHangingMan(const int index) const
  {
   CBar *bar=this.m_list.At(index);
   if(bar==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(!(bar.RatioBodyToCandleSize()<=this.Param(BAR_PARAM_BODY_MAX) && bar.RatioLowerShadowToCandleSize()>=this.Param(BAR_PARAM_LOWER_SHADOW_MIN) && bar.RatioUpperShadowToCandleSize()<=this.Param(BAR_PARAM_UPPER_SHADOW_MAX)))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_SELL;
  }
 //+------------------------------------------------------------------+
 //| Inverted Hammer (Buy): small body, long upper shadow, short lower shadow
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindInvertedHammer(const int index) const
  {
   CBar *bar=this.m_list.At(index);
   if(bar==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(!(bar.RatioBodyToCandleSize()<=this.Param(BAR_PARAM_BODY_MAX) && bar.RatioUpperShadowToCandleSize()>=this.Param(BAR_PARAM_UPPER_SHADOW_MIN) && bar.RatioLowerShadowToCandleSize()<=this.Param(BAR_PARAM_LOWER_SHADOW_MAX)))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_BUY;
  }
 //+------------------------------------------------------------------+
 //| Shooting Star (Sell): the shape of the Inverted Hammer, its own parameters
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindShootingStar(const int index) const
  {
   CBar *bar=this.m_list.At(index);
   if(bar==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(!(bar.RatioBodyToCandleSize()<=this.Param(BAR_PARAM_BODY_MAX) && bar.RatioUpperShadowToCandleSize()>=this.Param(BAR_PARAM_UPPER_SHADOW_MIN) && bar.RatioLowerShadowToCandleSize()<=this.Param(BAR_PARAM_LOWER_SHADOW_MAX)))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_SELL;
  }
 //+------------------------------------------------------------------+
 //| Doji: small body, the longer shadow breaks the tie (the lower one: Buy)
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindDoji(const int index) const
  {
   CBar *bar=this.m_list.At(index);
   if(bar==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.RatioBodyToCandleSize()>this.Param(BAR_PARAM_BODY_MAX))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return (bar.RatioLowerShadowToCandleSize()>=bar.RatioUpperShadowToCandleSize() ? SIGNAL_DIRECTION_BUY : SIGNAL_DIRECTION_SELL);
  }
 //+------------------------------------------------------------------+
 //| Dragonfly Doji (Buy): a doji with a long lower shadow
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindDragonflyDoji(const int index) const
  {
   CBar *bar=this.m_list.At(index);
   if(bar==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(!(bar.RatioBodyToCandleSize()<=this.Param(BAR_PARAM_BODY_MAX) && bar.RatioLowerShadowToCandleSize()>=this.Param(BAR_PARAM_LOWER_SHADOW_MIN) && bar.RatioUpperShadowToCandleSize()<=this.Param(BAR_PARAM_UPPER_SHADOW_MAX)))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_BUY;
  }
 //+------------------------------------------------------------------+
 //| Gravestone Doji (Sell): a doji with a long upper shadow
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindGravestoneDoji(const int index) const
  {
   CBar *bar=this.m_list.At(index);
   if(bar==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(!(bar.RatioBodyToCandleSize()<=this.Param(BAR_PARAM_BODY_MAX) && bar.RatioUpperShadowToCandleSize()>=this.Param(BAR_PARAM_UPPER_SHADOW_MIN) && bar.RatioLowerShadowToCandleSize()<=this.Param(BAR_PARAM_LOWER_SHADOW_MAX)))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_SELL;
  }
 //+------------------------------------------------------------------+
 //| Spinning Top: small body, both shadows long (the lower one longer: Buy)
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindSpinningTop(const int index) const
  {
   CBar *bar=this.m_list.At(index);
   if(bar==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(!(bar.RatioBodyToCandleSize()<=this.Param(BAR_PARAM_BODY_MAX) && bar.RatioLowerShadowToCandleSize()>=this.Param(BAR_PARAM_SHADOW_MIN_EACH) && bar.RatioUpperShadowToCandleSize()>=this.Param(BAR_PARAM_SHADOW_MIN_EACH)))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return (bar.RatioLowerShadowToCandleSize()>=bar.RatioUpperShadowToCandleSize() ? SIGNAL_DIRECTION_BUY : SIGNAL_DIRECTION_SELL);
  }
 //+------------------------------------------------------------------+
 //| Marubozu: a large body, the candle up is Buy, down is Sell
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindMarubozu(const int index) const
  {
   CBar *bar=this.m_list.At(index);
   if(bar==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.RatioBodyToCandleSize()<this.Param(BAR_PARAM_BODY_MIN))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.TypeBody()==BAR_BODY_TYPE_BULLISH)
      return SIGNAL_DIRECTION_BUY;
   if(bar.TypeBody()==BAR_BODY_TYPE_BEARISH)
      return SIGNAL_DIRECTION_SELL;
   return SIGNAL_DIRECTION_NO_PATTERN;
  }
 //+------------------------------------------------------------------+
 //| Pin Bar: small body, a long shadow and a short one; the lower long shadow is checked first (Buy)
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindPinBar(const int index) const
  {
   CBar *bar=this.m_list.At(index);
   if(bar==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.RatioBodyToCandleSize()>this.Param(BAR_PARAM_BODY_MAX))
      return SIGNAL_DIRECTION_NO_PATTERN;
   double larger=this.Param(BAR_PARAM_LARGER_SHADOW_MIN);
   double smaller=this.Param(BAR_PARAM_SMALLER_SHADOW_MAX);
   if(bar.RatioLowerShadowToCandleSize()>=larger && bar.RatioUpperShadowToCandleSize()<=smaller)
      return SIGNAL_DIRECTION_BUY;
   if(bar.RatioUpperShadowToCandleSize()>=larger && bar.RatioLowerShadowToCandleSize()<=smaller)
      return SIGNAL_DIRECTION_SELL;
   return SIGNAL_DIRECTION_NO_PATTERN;
  }
 //+------------------------------------------------------------------+
 //| Harami: a large mother candle and a small one inside its body, of the opposite colour
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindHarami(const int index) const
  {
   if(index<1)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *prev=this.m_list.At(index-1);
   if(bar==NULL || prev==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(prev.RatioBodyToCandleSize()<this.Param(BAR_PARAM_MOTHER_BODY_MIN) || bar.RatioBodyToCandleSize()>this.Param(BAR_PARAM_INNER_BODY_MAX))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.BottomBody()<prev.BottomBody() || bar.TopBody()>prev.TopBody())
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(prev.TypeBody()==BAR_BODY_TYPE_BEARISH && bar.TypeBody()==BAR_BODY_TYPE_BULLISH)
      return SIGNAL_DIRECTION_BUY;
   if(prev.TypeBody()==BAR_BODY_TYPE_BULLISH && bar.TypeBody()==BAR_BODY_TYPE_BEARISH)
      return SIGNAL_DIRECTION_SELL;
   return SIGNAL_DIRECTION_NO_PATTERN;
  }
 //+------------------------------------------------------------------+
 //| Harami Cross: the Harami with a doji inside (its own inner_body_max)
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindHaramiCross(const int index) const
  {
   if(index<1)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *prev=this.m_list.At(index-1);
   if(bar==NULL || prev==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(prev.RatioBodyToCandleSize()<this.Param(BAR_PARAM_MOTHER_BODY_MIN) || bar.RatioBodyToCandleSize()>this.Param(BAR_PARAM_INNER_BODY_MAX))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.BottomBody()<prev.BottomBody() || bar.TopBody()>prev.TopBody())
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(prev.TypeBody()==BAR_BODY_TYPE_BEARISH && bar.TypeBody()==BAR_BODY_TYPE_BULLISH)
      return SIGNAL_DIRECTION_BUY;
   if(prev.TypeBody()==BAR_BODY_TYPE_BULLISH && bar.TypeBody()==BAR_BODY_TYPE_BEARISH)
      return SIGNAL_DIRECTION_SELL;
   return SIGNAL_DIRECTION_NO_PATTERN;
  }
 //+------------------------------------------------------------------+
 //| Engulfing: a large candle whose body covers the body before it, of the opposite colour
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindEngulfing(const int index) const
  {
   if(index<1)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *prev=this.m_list.At(index-1);
   if(bar==NULL || prev==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.RatioBodyToCandleSize()<this.Param(BAR_PARAM_BODY_MIN))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.BottomBody()>prev.BottomBody() || bar.TopBody()<prev.TopBody())
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(prev.TypeBody()==BAR_BODY_TYPE_BEARISH && bar.TypeBody()==BAR_BODY_TYPE_BULLISH)
      return SIGNAL_DIRECTION_BUY;
   if(prev.TypeBody()==BAR_BODY_TYPE_BULLISH && bar.TypeBody()==BAR_BODY_TYPE_BEARISH)
      return SIGNAL_DIRECTION_SELL;
   return SIGNAL_DIRECTION_NO_PATTERN;
  }
 //+------------------------------------------------------------------+
 //| Tweezer: the same low (Buy) or the same high (Sell) within the tolerance in points
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindTweezer(const int index) const
  {
   if(index<1)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *prev=this.m_list.At(index-1);
   if(bar==NULL || prev==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   double tolerance=this.m_point*this.Param(BAR_PARAM_TOLERANCE_POINTS);
   if(prev.TypeBody()==BAR_BODY_TYPE_BEARISH && bar.TypeBody()==BAR_BODY_TYPE_BULLISH && ::fabs(prev.Low()-bar.Low())<=tolerance)
      return SIGNAL_DIRECTION_BUY;
   if(prev.TypeBody()==BAR_BODY_TYPE_BULLISH && bar.TypeBody()==BAR_BODY_TYPE_BEARISH && ::fabs(prev.High()-bar.High())<=tolerance)
      return SIGNAL_DIRECTION_SELL;
   return SIGNAL_DIRECTION_NO_PATTERN;
  }
 //+------------------------------------------------------------------+
 //| Piercing pattern (Buy): after a large bear candle, a bull candle that closes deep in its body
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindPiercingPattern(const int index) const
  {
   if(index<1)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *prev=this.m_list.At(index-1);
   if(bar==NULL || prev==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(prev.TypeBody()!=BAR_BODY_TYPE_BEARISH || prev.RatioBodyToCandleSize()<this.Param(BAR_PARAM_BODY_MIN) || bar.TypeBody()!=BAR_BODY_TYPE_BULLISH)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.Open()>prev.Close())
      return SIGNAL_DIRECTION_NO_PATTERN;
   double body_range=prev.TopBody()-prev.BottomBody();
   if(bar.Close()<prev.BottomBody()+body_range*this.Param(BAR_PARAM_PENETRATION_MIN)/100.0)
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_BUY;
  }
 //+------------------------------------------------------------------+
 //| Dark Cloud Cover (Sell): the mirror of the Piercing pattern
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindDarkCloudCover(const int index) const
  {
   if(index<1)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *prev=this.m_list.At(index-1);
   if(bar==NULL || prev==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(prev.TypeBody()!=BAR_BODY_TYPE_BULLISH || prev.RatioBodyToCandleSize()<this.Param(BAR_PARAM_BODY_MIN) || bar.TypeBody()!=BAR_BODY_TYPE_BEARISH)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.Open()<prev.Close())
      return SIGNAL_DIRECTION_NO_PATTERN;
   double body_range=prev.TopBody()-prev.BottomBody();
   if(bar.Close()>prev.TopBody()-body_range*this.Param(BAR_PARAM_PENETRATION_MIN)/100.0)
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_SELL;
  }
 //+------------------------------------------------------------------+
 //| Rails: two large candles of the opposite colour with the same body size; the newest candle decides the side
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindRails(const int index) const
  {
   if(index<1)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *prev=this.m_list.At(index-1);
   if(bar==NULL || prev==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   double body_min=this.Param(BAR_PARAM_BODY_MIN);
   if(prev.RatioBodyToCandleSize()<body_min || bar.RatioBodyToCandleSize()<body_min || prev.TypeBody()==bar.TypeBody())
      return SIGNAL_DIRECTION_NO_PATTERN;
   double body_before=::fabs(prev.Open()-prev.Close());
   double body_now=::fabs(bar.Open()-bar.Close());
   if(body_before<=0 || body_now<=0)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(::fmin(body_before,body_now)/::fmax(body_before,body_now)<this.Param(BAR_PARAM_SIMILARITY_MIN)/100.0)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.TypeBody()==BAR_BODY_TYPE_BULLISH)
      return SIGNAL_DIRECTION_BUY;
   if(bar.TypeBody()==BAR_BODY_TYPE_BEARISH)
      return SIGNAL_DIRECTION_SELL;
   return SIGNAL_DIRECTION_NO_PATTERN;
  }
 //+------------------------------------------------------------------+
 //| Outside Bar: a candle that covers the one before it, both large and of the opposite colour
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindOutsideBar(const int index) const
  {
   if(index<1)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *prev=this.m_list.At(index-1);
   if(bar==NULL || prev==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   double body_ratio=this.Param(BAR_PARAM_BODY_RATIO);
   if(bar.RatioBodyToCandleSize()<body_ratio || prev.RatioBodyToCandleSize()<body_ratio)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.TypeBody()==prev.TypeBody() || (bar.TypeBody()!=BAR_BODY_TYPE_BULLISH && bar.TypeBody()!=BAR_BODY_TYPE_BEARISH) || (prev.TypeBody()!=BAR_BODY_TYPE_BULLISH && prev.TypeBody()!=BAR_BODY_TYPE_BEARISH))
      return SIGNAL_DIRECTION_NO_PATTERN;
   double ratio=(bar.Size()>0 ? prev.Size()*100.0/bar.Size() : 0.0);
   if(ratio<this.Param(BAR_PARAM_CANDLES_RATIO))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(!(prev.High()<=bar.High() && prev.Low()>=bar.Low() && prev.TopBody()<bar.TopBody() && prev.BottomBody()>bar.BottomBody()))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return (bar.TypeBody()==BAR_BODY_TYPE_BULLISH ? SIGNAL_DIRECTION_BUY : SIGNAL_DIRECTION_SELL);
  }
 //+------------------------------------------------------------------+
 //| Inside Bar: the high and the low are inside the candle before; neutral as Doji, the longer shadow breaks the tie (the lower one: Buy)
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindInsideBar(const int index) const
  {
   if(index<1)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *prev=this.m_list.At(index-1);
   if(bar==NULL || prev==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.High()<prev.High() && bar.Low()>prev.Low())
      return (bar.RatioLowerShadowToCandleSize()>=bar.RatioUpperShadowToCandleSize() ? SIGNAL_DIRECTION_BUY : SIGNAL_DIRECTION_SELL);
   return SIGNAL_DIRECTION_NO_PATTERN;
  }
 //+------------------------------------------------------------------+
 //| Morning Star (Buy): a large bear candle, a small one, a bull candle that closes deep in the first body
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindMorningStar(const int index) const
  {
   if(index<2)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *mid=this.m_list.At(index-1);
   CBar *first=this.m_list.At(index-2);
   if(bar==NULL || mid==NULL || first==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(first.TypeBody()!=BAR_BODY_TYPE_BEARISH || first.RatioBodyToCandleSize()<this.Param(BAR_PARAM_FIRST_BODY_MIN))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(mid.RatioBodyToCandleSize()>this.Param(BAR_PARAM_MIDDLE_BODY_MAX))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.TypeBody()!=BAR_BODY_TYPE_BULLISH)
      return SIGNAL_DIRECTION_NO_PATTERN;
   double body_range=first.TopBody()-first.BottomBody();
   if(bar.Close()<first.BottomBody()+body_range*this.Param(BAR_PARAM_PENETRATION_MIN)/100.0)
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_BUY;
  }
 //+------------------------------------------------------------------+
 //| Morning Doji Star (Buy): the Morning Star with a doji in the middle (its own middle_body_max)
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindMorningDojiStar(const int index) const
  {
   if(index<2)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *mid=this.m_list.At(index-1);
   CBar *first=this.m_list.At(index-2);
   if(bar==NULL || mid==NULL || first==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(first.TypeBody()!=BAR_BODY_TYPE_BEARISH || first.RatioBodyToCandleSize()<this.Param(BAR_PARAM_FIRST_BODY_MIN))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(mid.RatioBodyToCandleSize()>this.Param(BAR_PARAM_MIDDLE_BODY_MAX))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.TypeBody()!=BAR_BODY_TYPE_BULLISH)
      return SIGNAL_DIRECTION_NO_PATTERN;
   double body_range=first.TopBody()-first.BottomBody();
   if(bar.Close()<first.BottomBody()+body_range*this.Param(BAR_PARAM_PENETRATION_MIN)/100.0)
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_BUY;
  }
 //+------------------------------------------------------------------+
 //| Evening Star (Sell): a large bull candle, a small one, a bear candle that closes deep in the first body
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindEveningStar(const int index) const
  {
   if(index<2)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *mid=this.m_list.At(index-1);
   CBar *first=this.m_list.At(index-2);
   if(bar==NULL || mid==NULL || first==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(first.TypeBody()!=BAR_BODY_TYPE_BULLISH || first.RatioBodyToCandleSize()<this.Param(BAR_PARAM_FIRST_BODY_MIN))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(mid.RatioBodyToCandleSize()>this.Param(BAR_PARAM_MIDDLE_BODY_MAX))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.TypeBody()!=BAR_BODY_TYPE_BEARISH)
      return SIGNAL_DIRECTION_NO_PATTERN;
   double body_range=first.TopBody()-first.BottomBody();
   if(bar.Close()>first.TopBody()-body_range*this.Param(BAR_PARAM_PENETRATION_MIN)/100.0)
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_SELL;
  }
 //+------------------------------------------------------------------+
 //| Evening Doji Star (Sell): the Evening Star with a doji in the middle (its own middle_body_max)
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindEveningDojiStar(const int index) const
  {
   if(index<2)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *mid=this.m_list.At(index-1);
   CBar *first=this.m_list.At(index-2);
   if(bar==NULL || mid==NULL || first==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(first.TypeBody()!=BAR_BODY_TYPE_BULLISH || first.RatioBodyToCandleSize()<this.Param(BAR_PARAM_FIRST_BODY_MIN))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(mid.RatioBodyToCandleSize()>this.Param(BAR_PARAM_MIDDLE_BODY_MAX))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.TypeBody()!=BAR_BODY_TYPE_BEARISH)
      return SIGNAL_DIRECTION_NO_PATTERN;
   double body_range=first.TopBody()-first.BottomBody();
   if(bar.Close()>first.TopBody()-body_range*this.Param(BAR_PARAM_PENETRATION_MIN)/100.0)
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_SELL;
  }
 //+------------------------------------------------------------------+
 //| Abandoned baby: a doji that gaps away from two large candles of the opposite colour
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindAbandonedBaby(const int index) const
  {
   if(index<2)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *mid=this.m_list.At(index-1);
   CBar *first=this.m_list.At(index-2);
   if(bar==NULL || mid==NULL || first==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(mid.RatioBodyToCandleSize()>this.Param(BAR_PARAM_MIDDLE_BODY_MAX))
      return SIGNAL_DIRECTION_NO_PATTERN;
   double outer_min=this.Param(BAR_PARAM_OUTER_BODY_MIN);
   if(first.RatioBodyToCandleSize()<outer_min || bar.RatioBodyToCandleSize()<outer_min)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(first.TypeBody()==BAR_BODY_TYPE_BEARISH && bar.TypeBody()==BAR_BODY_TYPE_BULLISH && mid.High()<first.Low() && bar.Low()>mid.High())
      return SIGNAL_DIRECTION_BUY;
   if(first.TypeBody()==BAR_BODY_TYPE_BULLISH && bar.TypeBody()==BAR_BODY_TYPE_BEARISH && mid.Low()>first.High() && bar.High()<mid.Low())
      return SIGNAL_DIRECTION_SELL;
   return SIGNAL_DIRECTION_NO_PATTERN;
  }
 //+------------------------------------------------------------------+
 //| Pivot Point Reversal: the middle candle sticks out of both its neighbours by protrude_min percent of its own range
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindPivotPointReversal(const int index) const
  {
   if(index<2)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *mid=this.m_list.At(index-1);
   CBar *first=this.m_list.At(index-2);
   if(bar==NULL || mid==NULL || first==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   double middle_size=mid.High()-mid.Low();
   if(middle_size<=0)
      return SIGNAL_DIRECTION_NO_PATTERN;
   double protrude_min=this.Param(BAR_PARAM_PROTRUDE_MIN);
   if((first.Low()-mid.Low())/middle_size*100.0>=protrude_min && (bar.Low()-mid.Low())/middle_size*100.0>=protrude_min)
      return SIGNAL_DIRECTION_BUY;
   if((mid.High()-first.High())/middle_size*100.0>=protrude_min && (mid.High()-bar.High())/middle_size*100.0>=protrude_min)
      return SIGNAL_DIRECTION_SELL;
   return SIGNAL_DIRECTION_NO_PATTERN;
  }
 //+------------------------------------------------------------------+
 //| Three White Soldiers (Buy): three large bull candles, each opens inside the body before it and closes higher
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindThreeWhiteSoldiers(const int index) const
  {
   if(index<2)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *mid=this.m_list.At(index-1);
   CBar *first=this.m_list.At(index-2);
   if(bar==NULL || mid==NULL || first==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   double body_min=this.Param(BAR_PARAM_BODY_MIN);
   if(first.TypeBody()!=BAR_BODY_TYPE_BULLISH || mid.TypeBody()!=BAR_BODY_TYPE_BULLISH || bar.TypeBody()!=BAR_BODY_TYPE_BULLISH)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(first.RatioBodyToCandleSize()<body_min || mid.RatioBodyToCandleSize()<body_min || bar.RatioBodyToCandleSize()<body_min)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(mid.Open()<first.BottomBody() || mid.Open()>first.TopBody() || mid.Close()<= first.Close())
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.Open()<mid.BottomBody() || bar.Open()>mid.TopBody() || bar.Close()<= mid.Close())
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_BUY;
  }
 //+------------------------------------------------------------------+
 //| Three Black Crows (Sell): three large bear candles, each opens inside the body before it and closes lower
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindThreeBlackCrows(const int index) const
  {
   if(index<2)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *mid=this.m_list.At(index-1);
   CBar *first=this.m_list.At(index-2);
   if(bar==NULL || mid==NULL || first==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   double body_min=this.Param(BAR_PARAM_BODY_MIN);
   if(first.TypeBody()!=BAR_BODY_TYPE_BEARISH || mid.TypeBody()!=BAR_BODY_TYPE_BEARISH || bar.TypeBody()!=BAR_BODY_TYPE_BEARISH)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(first.RatioBodyToCandleSize()<body_min || mid.RatioBodyToCandleSize()<body_min || bar.RatioBodyToCandleSize()<body_min)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(mid.Open()<first.BottomBody() || mid.Open()>first.TopBody() || mid.Close()>= first.Close())
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.Open()<mid.BottomBody() || bar.Open()>mid.TopBody() || bar.Close()>= mid.Close())
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_SELL;
  }
 //+------------------------------------------------------------------+
 //| Three Inside Up (Buy): a bullish Harami confirmed by a bull candle that closes above the second one
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindThreeInsideUp(const int index) const
  {
   if(index<2)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *mid=this.m_list.At(index-1);
   CBar *first=this.m_list.At(index-2);
   if(bar==NULL || mid==NULL || first==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(first.TypeBody()!=BAR_BODY_TYPE_BEARISH || first.RatioBodyToCandleSize()<this.Param(BAR_PARAM_FIRST_BODY_MIN))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(mid.TypeBody()!=BAR_BODY_TYPE_BULLISH || mid.RatioBodyToCandleSize()>this.Param(BAR_PARAM_SECOND_BODY_MAX))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(mid.BottomBody()<first.BottomBody() || mid.TopBody()>first.TopBody())
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.TypeBody()!=BAR_BODY_TYPE_BULLISH || bar.Close()<= mid.Close())
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_BUY;
  }
 //+------------------------------------------------------------------+
 //| Three Inside Down (Sell): a bearish Harami confirmed by a bear candle that closes below the second one
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindThreeInsideDown(const int index) const
  {
   if(index<2)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *mid=this.m_list.At(index-1);
   CBar *first=this.m_list.At(index-2);
   if(bar==NULL || mid==NULL || first==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(first.TypeBody()!=BAR_BODY_TYPE_BULLISH || first.RatioBodyToCandleSize()<this.Param(BAR_PARAM_FIRST_BODY_MIN))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(mid.TypeBody()!=BAR_BODY_TYPE_BEARISH || mid.RatioBodyToCandleSize()>this.Param(BAR_PARAM_SECOND_BODY_MAX))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(mid.BottomBody()<first.BottomBody() || mid.TopBody()>first.TopBody())
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(bar.TypeBody()!=BAR_BODY_TYPE_BEARISH || bar.Close()>= mid.Close())
      return SIGNAL_DIRECTION_NO_PATTERN;
   return SIGNAL_DIRECTION_SELL;
  }
 //+------------------------------------------------------------------+
 //| Three stars: three dojis, the newest closes at or above the close of the first (Buy) or below it (Sell)
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindThreeStars(const int index) const
  {
   if(index<2)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   CBar *mid=this.m_list.At(index-1);
   CBar *first=this.m_list.At(index-2);
   if(bar==NULL || mid==NULL || first==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   double limit=this.Param(BAR_PARAM_DOJI_BODY_MAX);
   if(first.RatioBodyToCandleSize()>limit || mid.RatioBodyToCandleSize()>limit || bar.RatioBodyToCandleSize()>limit)
      return SIGNAL_DIRECTION_NO_PATTERN;
   return (bar.Close()>=first.Close() ? SIGNAL_DIRECTION_BUY : SIGNAL_DIRECTION_SELL);
  }
 //+------------------------------------------------------------------+
 //| Momentum Candle: the body is bigger than body_multiplier times the biggest body of the bars_before candles before it (momentum.py)
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindMomentum(const int index) const
  {
   int count=(int)::fmax(1,this.Param(BAR_PARAM_BARS_BEFORE));
   if(index<count)
      return SIGNAL_DIRECTION_NO_PATTERN;
   CBar *bar=this.m_list.At(index);
   if(bar==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   double biggest=0.0;
   for(int i=index-count;i<index;i++)
     {
      CBar *before=this.m_list.At(i);
      if(before==NULL)
         return SIGNAL_DIRECTION_NO_PATTERN;
      biggest=::fmax(biggest,::fabs(before.Close()-before.Open()));
     }
   if(!(::fabs(bar.Close()-bar.Open())>this.Param(BAR_PARAM_BODY_MULTIPLIER)*biggest))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return (bar.Close()>bar.Open() ? SIGNAL_DIRECTION_BUY : SIGNAL_DIRECTION_SELL);
  }
#endif // CBARPATTERN_MQH_IMPLEMENTATION
#endif // __BARPATTERN_MQH__
