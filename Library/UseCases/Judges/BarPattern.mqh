//+------------------------------------------------------------------+
//|                                                   BarPattern.mqh |
//|Change from V2 BarPattern.mqh (CBarPattern : CBaseObj,            |
//+------------------------------------------------------------------+
//--- Change from V4 Entities\Bar\BarPattern.mqh: moved to UseCases\Judges, CBarPattern : CBar -> CBarPattern : CJudge (no row, no copy of the bar)
#ifndef __BARPATTERN_MQH__
#define __BARPATTERN_MQH__
 #include <Arrays\ArrayObj.mqh>
 #include "Judge.mqh"
 #include "BarSwing.mqh"   // New in V5: the pivot patterns read the swings (their strength and price basis)
#ifndef CBARPATTERN_MQH_DECLARATION
#define CBARPATTERN_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| A candle pattern (or a Momentum Candle) found on a bar            |
 //+------------------------------------------------------------------+
 class CBarPattern : public CJudge
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
   //--- New in V5: the pivot patterns (Harmonic, Chart Pattern). Their pivots are the swings already on the bars (bits of Swing High / Swing Low), not found again.
   //--- Reference: Allan Munene Mutiiria\Automating Trading Strategies (the rule of each EA, cited at its method)
    CBarSwing        *m_swing_high;          // The judge only: CBarControl holds it, set with the parameters of Swing High (strength, price basis)
    CBarSwing        *m_swing_low;           // The judge only: the same for Swing Low
   //--- How many pivots the type has (0: not a pivot pattern)
    int               PivotCount(const ENUM_BAR_INFOR_TYPE type) const;
   //--- The price of a pivot on the bar at the index, by the price basis of its swing
    double            PivotPrice(const int index,const bool high) const;
   //--- The pivots ending at the last one (its bar d_index, a high or a low): `count` alternating pivots, the oldest first (49. QM AddPivotToZigZag: two of
   //--- a kind in a row keep the more extreme). False: not enough swings, or a pivot of the same kind before it is more extreme (it is not a pivot then)
    bool              Pivots(const int d_index,const bool d_high,const int count,int &index[],double &price[],bool &high[]) const;
   //--- The rule of the type on its pivots: the side, SIGNAL_DIRECTION_NO_PATTERN when it does not hold
    ENUM_SIGNAL_DIRECTION RulePivot(const ENUM_BAR_INFOR_TYPE type,const int &index[],const double &price[],const bool &high[]) const;
    ENUM_SIGNAL_DIRECTION RuleXABCD(const ENUM_BAR_INFOR_TYPE type,const double &price[],const bool &high[]) const;
    ENUM_SIGNAL_DIRECTION RuleABCD(const double &price[],const bool &high[]) const;
    ENUM_SIGNAL_DIRECTION RuleThreeDrives(const double &price[],const bool &high[]) const;
    ENUM_SIGNAL_DIRECTION RuleFiveDrives(const double &price[],const bool &high[]) const;
    ENUM_SIGNAL_DIRECTION RuleHeadShoulders(const int &index[],const double &price[],const bool &high[]) const;
    ENUM_SIGNAL_DIRECTION RuleDoubleTopBottom(const int &index[],const double &price[],const bool &high[]) const;
    ENUM_SIGNAL_DIRECTION RuleQuasimodo(const double &price[],const bool &high[]) const;
   //--- CONFIRM: the bar at the index confirms the swing of the last pivot (strength bars before it); d_index: the bar of that pivot
    ENUM_SIGNAL_DIRECTION FindPivot(const ENUM_BAR_INFOR_TYPE type,const int index,int &d_index) const;
   public:
   //--- Does this class find the type (the swings are CBarSwing')
    static bool       IsFound(const ENUM_BAR_INFOR_TYPE type);
   //--- New in V5: is the type a pivot pattern (Harmonic, Chart Pattern)
    static bool       IsPivotPattern(const ENUM_BAR_INFOR_TYPE type) { return ((type>=BAR_INFOR_TYPE_GARTLEY && type<=BAR_INFOR_TYPE_FIVE_DRIVES) || (type>=BAR_INFOR_TYPE_HEAD_SHOULDERS && type<=BAR_INFOR_TYPE_QUASIMODO)); }
   //--- The judge: the bars, the point of their symbol and the parameters of the type judged now
    void              SetJudge(CArrayObj *list,const double point,const string &names[],const double &values[]);
   //--- New in V5: the judges of the swings for the pivot patterns (their bars and parameters are set by CBarControl)
    void              SetSwings(CBarSwing *swing_high,CBarSwing *swing_low) { this.m_swing_high=swing_high; this.m_swing_low=swing_low; }
   //--- The method of the type judges the bar at the index of the list of the judge (CJudge::Calculate calls it)
    virtual ENUM_SIGNAL_DIRECTION Find(const ENUM_BAR_INFOR_TYPE type,const int index) const;
   //--- The row of a candle is on the bar itself, the row of a pivot pattern on its last pivot (CONFIRM: the swing strength bars before)
    virtual int       Shift(const ENUM_BAR_INFOR_TYPE type,const int index) const;
   //--- New in V5: FOUND (live): the bar at the index completes a Pivot Point Reversal (its bit is on it), its middle bar is the last pivot (d_index)
    ENUM_SIGNAL_DIRECTION FindEarly(const ENUM_BAR_INFOR_TYPE type,const int index,int &d_index) const;
   //--- New in V5: the pivots of the pattern whose last pivot is on the bar d_index (a high or a low): times and prices, the oldest first, for the View and
   //--- Trading (SL / TP). Returns how many, 0 when the rule does not hold there
    int               Points(const ENUM_BAR_INFOR_TYPE type,const int d_index,const bool d_high,long &times[],double &prices[],bool &highs[]) const;
   //--- New in V5: is the price on the bar at the index beyond the last pivot (d_index): the swing cannot be there (INVALID)
    bool              IsBeyond(const int index,const int d_index,const bool d_high) const;
   //--- New in V5: the strength of the swing of a kind (CONFIRM: that many bars after the last pivot)
    int               SwingStrength(const bool high) const;
   //--- The judge (the event is CJudge's: SERIES_EVENTS_PATTERN)
                      CBarPattern(void) : m_list(NULL),m_point(0.0),m_swing_high(NULL),m_swing_low(NULL) { this.m_object_type=OBJECT_DE_TYPE_SERIES_PATTERN; }
  };
#endif // CBARPATTERN_MQH_DECLARATION
#ifndef CBARPATTERN_MQH_IMPLEMENTATION
#define CBARPATTERN_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| The types this class finds                                       |
 //+------------------------------------------------------------------+
 bool CBarPattern::IsFound(const ENUM_BAR_INFOR_TYPE type)
  {
   return ((type>=BAR_INFOR_TYPE_HAMMER && type<=BAR_INFOR_TYPE_THREE_STARS) ||
           (type>=BAR_INFOR_TYPE_PIN_BAR && type<=BAR_INFOR_TYPE_PIVOT_POINT_REVERSAL) ||
           type==BAR_INFOR_TYPE_MOMENTUM_CANDLE || IsPivotPattern(type));
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
   ::Print(__FUNCTION__," > the parameter ",name," is not in Setting_BarSetup");
   return 0.0;
  }
 //+------------------------------------------------------------------+
 //| The method of the type judges the bar at the index               |
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::Find(const ENUM_BAR_INFOR_TYPE type,const int index) const
  {
   if(this.m_list==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(IsPivotPattern(type))
     {
      int d_index=-1;
      return this.FindPivot(type,index,d_index);
     }
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
 //====================================================================
 //=== New in V5: the pivot patterns (Harmonic, Chart Pattern)        ===
 //====================================================================
 //+------------------------------------------------------------------+
 //| How many pivots the type has                                     |
 //+------------------------------------------------------------------+
 int CBarPattern::PivotCount(const ENUM_BAR_INFOR_TYPE type) const
  {
   switch(type)
     {
      case BAR_INFOR_TYPE_GARTLEY:
      case BAR_INFOR_TYPE_BAT:
      case BAR_INFOR_TYPE_BUTTERFLY:
      case BAR_INFOR_TYPE_CRAB:
      case BAR_INFOR_TYPE_CYPHER:
      case BAR_INFOR_TYPE_SHARK:
      case BAR_INFOR_TYPE_HEAD_SHOULDERS:     return 5;
      case BAR_INFOR_TYPE_AB_CD:
      case BAR_INFOR_TYPE_QUASIMODO:          return 4;
      case BAR_INFOR_TYPE_THREE_DRIVES:
      case BAR_INFOR_TYPE_FIVE_DRIVES:        return 6;
      case BAR_INFOR_TYPE_DOUBLE_TOP_BOTTOM:  return 3;
      default:                                return 0;
     }
  }
 //+------------------------------------------------------------------+
 //| The strength of the swing of a kind                              |
 //+------------------------------------------------------------------+
 int CBarPattern::SwingStrength(const bool high) const
  {
   const CBarSwing *swing=(high ? this.m_swing_high : this.m_swing_low);
   return (swing!=NULL ? swing.Strength() : (int)SWING_DEF_STRENGTH);
  }
 //+------------------------------------------------------------------+
 //| The price of a pivot, by the price basis of its swing             |
 //+------------------------------------------------------------------+
 double CBarPattern::PivotPrice(const int index,const bool high) const
  {
   CBar *bar=(this.m_list!=NULL ? this.m_list.At(index) : NULL);
   if(bar==NULL)
      return 0.0;
   const CBarSwing *swing=(high ? this.m_swing_high : this.m_swing_low);
   const bool wick=(swing==NULL || swing.IsWick());
   if(high)
      return (wick ? bar.High() : bar.TopBody());
   return (wick ? bar.Low() : bar.BottomBody());
  }
 //+------------------------------------------------------------------+
 //| Is the price on a bar beyond the last pivot                       |
 //+------------------------------------------------------------------+
 bool CBarPattern::IsBeyond(const int index,const int d_index,const bool d_high) const
  {
   const double last=this.PivotPrice(d_index,d_high);
   const double price=this.PivotPrice(index,d_high);
   if(last==0.0 || price==0.0)
      return false;
   return (d_high ? price>=last : price<=last);   // the swing is strictly beyond its neighbours (CBarSwing)
  }
 //+------------------------------------------------------------------+
 //| The alternating pivots ending at the last one, the oldest first.  |
 //| Two of a kind in a row keep the more extreme (49. 23141 QM,       |
 //| AddPivotToZigZag); a bar with both swings is a high (the EAs)     |
 //+------------------------------------------------------------------+
 bool CBarPattern::Pivots(const int d_index,const bool d_high,const int count,int &index[],double &price[],bool &high[]) const
  {
   if(this.m_list==NULL || count<1 || d_index<0 || d_index>=this.m_list.Total())
      return false;
   int    r_index[];
   double r_price[];
   bool   r_high[];
   ::ArrayResize(r_index,count+1);
   ::ArrayResize(r_price,count+1);
   ::ArrayResize(r_high,count+1);
   r_index[0]=d_index;
   r_price[0]=this.PivotPrice(d_index,d_high);
   r_high[0]=d_high;
   int n=1;
   const int oldest=(int)::fmax(0,d_index-STRUCTURE_LOOKBACK);
   //--- Back from the last pivot until one more pivot than needed: the oldest one needed cannot be merged any more
   for(int i=d_index-1;i>=oldest && n<=count;i--)
     {
      CBar *bar=this.m_list.At(i);
      if(bar==NULL)
         continue;
      const bool is_high=(bar.InformationSide(BAR_INFOR_TYPE_SWING_HIGH)!=SIGNAL_DIRECTION_NO_PATTERN);
      const bool is_low=(bar.InformationSide(BAR_INFOR_TYPE_SWING_LOW)!=SIGNAL_DIRECTION_NO_PATTERN);
      if(!is_high && !is_low)
         continue;
      const bool kind=is_high;
      const double value=this.PivotPrice(i,kind);
      if(kind==r_high[n-1])
        {
         const bool more=(kind ? value>r_price[n-1] : value<r_price[n-1]);
         if(more)
           {
            if(n==1)
               return false;   // the last pivot is not the extreme of its leg: not a pivot
            r_index[n-1]=i;
            r_price[n-1]=value;
           }
         continue;
        }
      r_index[n]=i;
      r_price[n]=value;
      r_high[n]=kind;
      n++;
     }
   if(n<count)
      return false;
   ::ArrayResize(index,count);
   ::ArrayResize(price,count);
   ::ArrayResize(high,count);
   for(int k=0;k<count;k++)
     {
      index[k]=r_index[count-1-k];
      price[k]=r_price[count-1-k];
      high[k]=r_high[count-1-k];
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| The rule of the type on its pivots                                |
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::RulePivot(const ENUM_BAR_INFOR_TYPE type,const int &index[],const double &price[],const bool &high[]) const
  {
   switch(type)
     {
      case BAR_INFOR_TYPE_GARTLEY:
      case BAR_INFOR_TYPE_BAT:
      case BAR_INFOR_TYPE_BUTTERFLY:
      case BAR_INFOR_TYPE_CRAB:
      case BAR_INFOR_TYPE_CYPHER:
      case BAR_INFOR_TYPE_SHARK:              return this.RuleXABCD(type,price,high);
      case BAR_INFOR_TYPE_AB_CD:              return this.RuleABCD(price,high);
      case BAR_INFOR_TYPE_THREE_DRIVES:       return this.RuleThreeDrives(price,high);
      case BAR_INFOR_TYPE_FIVE_DRIVES:        return this.RuleFiveDrives(price,high);
      case BAR_INFOR_TYPE_HEAD_SHOULDERS:     return this.RuleHeadShoulders(index,price,high);
      case BAR_INFOR_TYPE_DOUBLE_TOP_BOTTOM:  return this.RuleDoubleTopBottom(index,price,high);
      case BAR_INFOR_TYPE_QUASIMODO:          return this.RuleQuasimodo(price,high);
      default:                                return SIGNAL_DIRECTION_NO_PATTERN;
     }
  }
 //+------------------------------------------------------------------+
 //| X A B C D: the legs measured the way of X (a high X: the bearish  |
 //| pattern of the EA, Sell at D). Gartley 29. 19111, Bat 28. 19105,  |
 //| Butterfly 08. 17223, Crab 27. 19099, Cypher 15. 17865, Shark      |
 //| 33. 19479                                                         |
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::RuleXABCD(const ENUM_BAR_INFOR_TYPE type,const double &price[],const bool &high[]) const
  {
   const double dir=(high[0] ? 1.0 : -1.0);
   const double X=price[0],A=price[1],B=price[2],C=price[3],D=price[4];
   const double xa=dir*(X-A);
   if(xa<=0)
      return SIGNAL_DIRECTION_NO_PATTERN;
   const double ab=dir*(B-A),bc=dir*(B-C),cd=dir*(D-C),ad=dir*(D-A),xc=dir*(X-C);
   const bool beyond_x=(dir*(D-X)>0),inside_x=(dir*(D-X)<0);
   const double tol=this.Param(BAR_PARAM_TOLERANCE);
   bool holds=false;
   switch(type)
     {
      case BAR_INFOR_TYPE_GARTLEY:     // B 0.618 of XA, BC 0.382-0.886 of AB, D 0.786 of XA from A, D inside X
         holds=(::fabs(ab-0.618*xa)<=tol*xa && ab>0 && bc>=0.382*ab && bc<=0.886*ab && ::fabs(ad-0.786*xa)<=tol*xa && inside_x);
         break;
      case BAR_INFOR_TYPE_BAT:         // B 0.5, BC 0.382-0.886 of AB, D 0.886, inside X
         holds=(::fabs(ab-0.5*xa)<=tol*xa && ab>0 && bc>=0.382*ab && bc<=0.886*ab && ::fabs(ad-0.886*xa)<=tol*xa && inside_x);
         break;
      case BAR_INFOR_TYPE_CRAB:        // B 0.618, BC 0.382-0.886 of AB, D 1.618, beyond X
         holds=(::fabs(ab-0.618*xa)<=tol*xa && ab>0 && bc>=0.382*ab && bc<=0.886*ab && ::fabs(ad-1.618*xa)<=tol*xa && beyond_x);
         break;
      case BAR_INFOR_TYPE_BUTTERFLY:   // B 0.786, BC 0.382-0.886 of XA, CD 1.27-1.618 of XA, beyond X
         holds=(::fabs(ab-0.786*xa)<=tol*xa && bc>=0.382*xa && bc<=0.886*xa && cd>=1.27*xa && cd<=1.618*xa && beyond_x);
         break;
      case BAR_INFOR_TYPE_CYPHER:      // AB 0.382-0.618 of XA, BC 1.272-1.414 of AB, CD 0.786 of XC, beyond X
         holds=(ab>=0.382*xa && ab<=0.618*xa && bc>=1.272*ab && bc<=1.414*ab && xc>0 && ::fabs(cd-0.786*xc)<=tol*xc && beyond_x);
         break;
      case BAR_INFOR_TYPE_SHARK:       // AB of XA, BC of AB, CD of BC in their ranges, D beyond B
         holds=(ab>=this.Param(BAR_PARAM_AB_MIN)*xa && ab<=this.Param(BAR_PARAM_AB_MAX)*xa &&
                bc>=this.Param(BAR_PARAM_BC_MIN)*ab && bc<=this.Param(BAR_PARAM_BC_MAX)*ab &&
                cd>=this.Param(BAR_PARAM_CD_MIN)*bc && cd<=this.Param(BAR_PARAM_CD_MAX)*bc && dir*(D-B)>0);
         break;
      default:
         break;
     }
   if(!holds)
      return SIGNAL_DIRECTION_NO_PATTERN;
   return (high[4] ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_BUY);
  }
 //+------------------------------------------------------------------+
 //| AB=CD (30. 19442): BC a Fibonacci retracement of AB and CD its    |
 //| reciprocal extension of BC (a pair of the table), D beyond B      |
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::RuleABCD(const double &price[],const bool &high[]) const
  {
   const double dir=(high[0] ? 1.0 : -1.0);
   const double A=price[0],B=price[1],C=price[2],D=price[3];
   const double ab=dir*(A-B),bc=dir*(C-B),cd=dir*(C-D);
   if(ab<=0 || bc<=0)
      return SIGNAL_DIRECTION_NO_PATTERN;
   const double retrace=bc/ab,extension=cd/bc;
   const double tol=this.Param(BAR_PARAM_TOLERANCE);
   double fib_retr[]={0.382,0.5,0.618,0.786,0.886};
   double fib_ext[]={2.618,2.0,1.618,1.272,1.13};
   bool valid=false;
   for(int k=0;k<::ArraySize(fib_retr) && !valid;k++)
      valid=(::fabs(retrace-fib_retr[k])<=tol && ::fabs(extension-fib_ext[k])<=tol);
   if(!valid || !(dir*(B-D)>0))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return (high[3] ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_BUY);
  }
 //+------------------------------------------------------------------+
 //| 3 Drives (31. 19449): three drives, each one an extension of the  |
 //| retracement before it, the retracements 0.618 / 0.786             |
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::RuleThreeDrives(const double &price[],const bool &high[]) const
  {
   const double dir=(high[0] ? 1.0 : -1.0);
   const double A=price[0],B=price[1],C=price[2],D=price[3],E=price[4],F=price[5];
   const double tol=this.Param(BAR_PARAM_TOLERANCE);
   double retr_levels[]={0.618,0.786};
   double ext_levels[]={1.13,1.272,1.618};
   const double drive1=dir*(A-B);
   if(drive1<=0)
      return SIGNAL_DIRECTION_NO_PATTERN;
   const double retrace_a=dir*(C-B),drive2=dir*(C-D),retrace_b=dir*(E-D),drive3=dir*(E-F);
   bool ok_retrace_a=false,ok_drive2=false,ok_retrace_b=false,ok_drive3=false;
   for(int k=0;k<::ArraySize(retr_levels);k++)
     {
      ok_retrace_a=(ok_retrace_a || ::fabs(retrace_a-retr_levels[k]*drive1)<=tol*drive1);
      ok_retrace_b=(ok_retrace_b || ::fabs(retrace_b-retr_levels[k]*drive2)<=tol*drive2);
     }
   for(int k=0;k<::ArraySize(ext_levels);k++)
     {
      ok_drive2=(ok_drive2 || ::fabs(drive2-ext_levels[k]*retrace_a)<=tol*retrace_a);
      ok_drive3=(ok_drive3 || ::fabs(drive3-ext_levels[k]*retrace_b)<=tol*retrace_b);
     }
   if(!(ok_retrace_a && ok_drive2 && ok_retrace_b && ok_drive3 && dir*(D-F)>0 && dir*(B-D)>0))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return (high[5] ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_BUY);
  }
 //+------------------------------------------------------------------+
 //| 5 Drives (32. 19463): AB 1.13-1.618 of XA, BC 1.618-2.24 of AB,   |
 //| CD 0.5 of BC and equal to AB                                      |
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::RuleFiveDrives(const double &price[],const bool &high[]) const
  {
   const double dir=(high[0] ? 1.0 : -1.0);
   const double B=price[1],C=price[2],D=price[3],E=price[4],F=price[5];
   const double tol=this.Param(BAR_PARAM_TOLERANCE);
   const double xa=dir*(C-B),ab=dir*(C-D),bc=dir*(E-D),cd=dir*(E-F);
   if(xa<=0)
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(!(ab>=1.13*xa && ab<=1.618*xa && bc>=1.618*ab && bc<=2.24*ab && ::fabs(cd-0.5*bc)<=tol*bc && ::fabs(cd-ab)<=tol*ab && dir*(E-C)>0 && dir*(F-B)>0))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return (high[5] ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_BUY);
  }
 //+------------------------------------------------------------------+
 //| Head & Shoulders, Inverse (13. 17618): the head beyond both       |
 //| shoulders, the shoulders and the troughs level within their       |
 //| tolerance (points), the sides MinBarRange-MaxBarRange bars and    |
 //| uniform (BarRangeMultiplier)                                      |
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::RuleHeadShoulders(const int &index[],const double &price[],const bool &high[]) const
  {
   const double dir=(high[0] ? 1.0 : -1.0);
   const double LS=price[0],T1=price[1],H=price[2],T2=price[3],RS=price[4];
   if(!(dir*(H-LS)>0 && dir*(H-RS)>0))
      return SIGNAL_DIRECTION_NO_PATTERN;
   if(!(::fabs(LS-RS)<this.Param(BAR_PARAM_SHOULDER_TOLERANCE)*this.m_point && ::fabs(T1-T2)<this.Param(BAR_PARAM_TROUGH_TOLERANCE)*this.m_point))
      return SIGNAL_DIRECTION_NO_PATTERN;
   const int ls_to_head=index[2]-index[0],head_to_rs=index[4]-index[2];
   const int min_bars=(int)this.Param(BAR_PARAM_MIN_BARS),max_bars=(int)this.Param(BAR_PARAM_MAX_BARS);
   if(ls_to_head<min_bars || ls_to_head>max_bars || head_to_rs<min_bars || head_to_rs>max_bars)
      return SIGNAL_DIRECTION_NO_PATTERN;
   const double shorter=::fmin(ls_to_head,head_to_rs),multiplier=this.Param(BAR_PARAM_BARS_MULTIPLIER);
   if(ls_to_head>shorter*multiplier || head_to_rs>shorter*multiplier)
      return SIGNAL_DIRECTION_NO_PATTERN;
   return (high[4] ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_BUY);
  }
 //+------------------------------------------------------------------+
 //| Double Top / Bottom (53. 23576): two peaks within tolerance % of  |
 //| the height over the neckline (the pivot between), far enough      |
 //| apart (InpMinPatternBars), the legs balanced (InpLegBalancePercent)|
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::RuleDoubleTopBottom(const int &index[],const double &price[],const bool &high[]) const
  {
   const double dir=(high[2] ? 1.0 : -1.0);
   const double P1=price[0],N=price[1],P2=price[2];
   const double height=dir*((P1+P2)/2.0-N);
   if(height<=0 || ::fabs(P1-P2)>this.Param(BAR_PARAM_TOLERANCE)/100.0*height)
      return SIGNAL_DIRECTION_NO_PATTERN;
   const int min_bars=(int)this.Param(BAR_PARAM_MIN_BARS);
   if(min_bars>0 && index[2]-index[0]<min_bars)
      return SIGNAL_DIRECTION_NO_PATTERN;
   const double balance=this.Param(BAR_PARAM_LEG_BALANCE);
   if(balance>0)
     {
      const double leg_a=index[1]-index[0],leg_b=index[2]-index[1];
      if(leg_a<=0 || leg_b<=0 || 100.0*::fmin(leg_a,leg_b)/::fmax(leg_a,leg_b)<balance)
         return SIGNAL_DIRECTION_NO_PATTERN;
     }
   return (high[2] ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_BUY);
  }
 //+------------------------------------------------------------------+
 //| Quasimodo (49. 23141): shoulder, leg, head beyond the shoulder,   |
 //| the last pivot beyond the leg (a break of structure). A high      |
 //| shoulder is the bearish QM (Sell)                                 |
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::RuleQuasimodo(const double &price[],const bool &high[]) const
  {
   const double dir=(high[0] ? 1.0 : -1.0);
   const double S=price[0],L=price[1],H=price[2],B=price[3];
   if(!(dir*(H-S)>0 && dir*(S-L)>0 && dir*(L-B)>0))
      return SIGNAL_DIRECTION_NO_PATTERN;
   return (high[0] ? SIGNAL_DIRECTION_SELL : SIGNAL_DIRECTION_BUY);
  }
 //+------------------------------------------------------------------+
 //| CONFIRM: the bar at the index confirms the swing of the last pivot|
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindPivot(const ENUM_BAR_INFOR_TYPE type,const int index,int &d_index) const
  {
   d_index=-1;
   const int count=this.PivotCount(type);
   if(count==0 || this.m_list==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   for(int k=0;k<2;k++)
     {
      const bool high=(k==0);
      const int d=index-this.SwingStrength(high);
      CBar *bar=(d>=0 ? this.m_list.At(d) : NULL);
      if(bar==NULL || bar.InformationSide(high ? BAR_INFOR_TYPE_SWING_HIGH : BAR_INFOR_TYPE_SWING_LOW)==SIGNAL_DIRECTION_NO_PATTERN)
         continue;
      int    pivot_index[];
      double pivot_price[];
      bool   pivot_high[];
      if(!this.Pivots(d,high,count,pivot_index,pivot_price,pivot_high))
         continue;
      const ENUM_SIGNAL_DIRECTION side=this.RulePivot(type,pivot_index,pivot_price,pivot_high);
      if(side!=SIGNAL_DIRECTION_NO_PATTERN)
        {
         d_index=d;
         return side;
        }
     }
   return SIGNAL_DIRECTION_NO_PATTERN;
  }
 //+------------------------------------------------------------------+
 //| FOUND: the middle bar of a Pivot Point Reversal is the last pivot |
 //+------------------------------------------------------------------+
 ENUM_SIGNAL_DIRECTION CBarPattern::FindEarly(const ENUM_BAR_INFOR_TYPE type,const int index,int &d_index) const
  {
   d_index=-1;
   const int count=this.PivotCount(type);
   CBar *bar=(this.m_list!=NULL && index>=1 ? this.m_list.At(index) : NULL);
   if(count==0 || bar==NULL)
      return SIGNAL_DIRECTION_NO_PATTERN;
   const ENUM_SIGNAL_DIRECTION ppr=bar.InformationSide(BAR_INFOR_TYPE_PIVOT_POINT_REVERSAL);
   if(ppr==SIGNAL_DIRECTION_NO_PATTERN)
      return SIGNAL_DIRECTION_NO_PATTERN;
   const bool high=(ppr==SIGNAL_DIRECTION_SELL);   // the middle bar sticks out up: a high
   int    pivot_index[];
   double pivot_price[];
   bool   pivot_high[];
   if(!this.Pivots(index-1,high,count,pivot_index,pivot_price,pivot_high))
      return SIGNAL_DIRECTION_NO_PATTERN;
   const ENUM_SIGNAL_DIRECTION side=this.RulePivot(type,pivot_index,pivot_price,pivot_high);
   if(side!=SIGNAL_DIRECTION_NO_PATTERN)
      d_index=index-1;
   return side;
  }
 //+------------------------------------------------------------------+
 //| The row of a pivot pattern is on its last pivot                   |
 //+------------------------------------------------------------------+
 int CBarPattern::Shift(const ENUM_BAR_INFOR_TYPE type,const int index) const
  {
   if(!IsPivotPattern(type))
      return 0;
   int d_index=-1;
   if(this.FindPivot(type,index,d_index)==SIGNAL_DIRECTION_NO_PATTERN || d_index<0)
      return 0;
   return index-d_index;
  }
 //+------------------------------------------------------------------+
 //| The pivots of the pattern, for the View and Trading               |
 //+------------------------------------------------------------------+
 int CBarPattern::Points(const ENUM_BAR_INFOR_TYPE type,const int d_index,const bool d_high,long &times[],double &prices[],bool &highs[]) const
  {
   ::ArrayResize(times,0);
   ::ArrayResize(prices,0);
   ::ArrayResize(highs,0);
   const int count=this.PivotCount(type);
   int    pivot_index[];
   double pivot_price[];
   bool   pivot_high[];
   if(count==0 || !this.Pivots(d_index,d_high,count,pivot_index,pivot_price,pivot_high) ||
      this.RulePivot(type,pivot_index,pivot_price,pivot_high)==SIGNAL_DIRECTION_NO_PATTERN)
      return 0;
   ::ArrayResize(times,count);
   ::ArrayResize(prices,count);
   ::ArrayResize(highs,count);
   for(int k=0;k<count;k++)
     {
      CBar *bar=this.m_list.At(pivot_index[k]);
      times[k]=(bar!=NULL ? (long)bar.Time() : 0);
      prices[k]=pivot_price[k];
      highs[k]=pivot_high[k];
     }
   return count;
  }
#endif // CBARPATTERN_MQH_IMPLEMENTATION
#endif // __BARPATTERN_MQH__
