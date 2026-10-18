//+------------------------------------------------------------------+
//|                                        MarketConditionSetting.mqh |
//+------------------------------------------------------------------+
#ifndef __MARKETCONDITIONSETTING_MQH__
#define __MARKETCONDITIONSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Defines\MarketStructureDefines.mqh>
 //Inputs of the EA: in EA Configuration.mqh (section: Market State and Phase)
#ifndef CMARKETCONDITIONSETTING_MQH_DECLARATION
#define CMARKETCONDITIONSETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The Market State / Phase settings of the EA. They are the inputs |
 //| of the EA, so they are read-only here and change with the Inputs |
 //| table: the calculation ones go to Python (Json, in the init      |
 //| message), the colours of the Phases are read by the Market Story |
 //| table                                                            |
 //+------------------------------------------------------------------+
 class CMarketConditionSetting : public CBaseObj
  {
   public:
   //--- The colour of a Market Phase in the Market Story table; clrNONE when the phase is not known
     color             PhaseColor(const ENUM_MARKET_PHASE phase) const
       {
        switch(phase)
          {
           case MARKET_PHASE_ACCUMULATION: return InpPhaseAccumulationColor;
           case MARKET_PHASE_MARKUP:       return InpPhaseMarkupColor;
           case MARKET_PHASE_DISTRIBUTION: return InpPhaseDistributionColor;
           case MARKET_PHASE_MARKDOWN:     return InpPhaseMarkdownColor;
           default:                        return clrNONE;
          }
       }
   //--- The legs between the Swings: drawn at all, and the colour of each kind
     bool              ShowMoves(void)        const { return InpMoveShow; }
     bool              ShowUnclassified(void) const { return InpMoveShowUnclassified; }
     color             MoveColor(const ENUM_MOVE_TYPE move) const
       {
        return (move==MOVE_TYPE_IMPULSE ? InpMoveImpulseColor : move==MOVE_TYPE_PULLBACK ? InpMovePullbackColor : InpMoveNoneColor);
       }
   //--- What Python calculates, as a JSON object
     string            Json(void) const;
                       CMarketConditionSetting(void) {}
  };
#endif // CMARKETCONDITIONSETTING_MQH_DECLARATION
#ifndef CMARKETCONDITIONSETTING_MQH_IMPLEMENTATION
#define CMARKETCONDITIONSETTING_MQH_IMPLEMENTATION
 string CMarketConditionSetting::Json(void) const
  {
   return ::StringFormat("{\"min_step_atr\":%.4f}",
                         (InpMarketMinStepATR<0.0 ? 0.0 : InpMarketMinStepATR));
  }
#endif // CMARKETCONDITIONSETTING_MQH_IMPLEMENTATION
#endif // __MARKETCONDITIONSETTING_MQH__
