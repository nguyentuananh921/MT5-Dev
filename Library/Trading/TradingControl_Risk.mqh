//+------------------------------------------------------------------+
//|                                          TradingControl_Risk.mqh |
//|                                     Copyright 2026, Anhnt        |
//| New in V5: the risk of an Entry and of the open positions, a     |
//| module of CTradingControl (the controller decides; the data is   |
//| read from its owners: CSymbol::ValuePerLot / StopLevelMin,       |
//| CAccount::DrawdownPercent, CMarketCollection::BasketState; the   |
//| limits from CRiskSetting = Setting_Risk).                        |
//| Reference (concept only, the classes are not kept):              |
//| D:\MT5-Dev\Experts\Solomon Anietie Sunday\Risk Management\       |
//| 7. 24477 Consolidating the Risk Framework\Include\               |
//|   TradeRisk.mqh     CTradeRisk     -> the trade tier             |
//|   BasketRisk.mqh    CBasketRisk    -> the basket tier            |
//|   PortfolioRisk.mqh CPortfolioRisk -> the portfolio tier         |
//| Each tier that refuses an Entry fires RISK_EVENT_ENTRY_BLOCKED   |
//| (dparam 0 trade, 1 basket, 2 portfolio)                          |
//+------------------------------------------------------------------+
#ifndef __TRADINGCONTROL_RISK_MQH__
#define __TRADINGCONTROL_RISK_MQH__
 //====================================================================
 //=== The trade tier. Reference: Include\TradeRisk.mqh (CTradeRisk) ===
 //====================================================================
 //+------------------------------------------------------------------+
 //| Drawdown-based risk factor [1.0 = no reduction]                  |
 //| Reference: CTradeRisk::DrawdownFactor (the peak: CAccount)        |
 //+------------------------------------------------------------------+
 double CTradingControl::RiskDrawdownFactor(void)
  {
   if(!this.m_risk_setting.EnableDrawdownScaling())
      return 1.0;
   const double drawdown_percent=this.m_account.DrawdownPercent();
   if(drawdown_percent>=this.m_risk_setting.DrawdownTrigger())
     {
      if(!this.m_risk_silent)
         ::PrintFormat("%s > Drawdown %.2f%% >= %.2f%%: risk scaled by %.2f",__FUNCTION__,drawdown_percent,this.m_risk_setting.DrawdownTrigger(),this.m_risk_setting.DrawdownFactor());
      return this.m_risk_setting.DrawdownFactor();
     }
   return 1.0;
  }
 //+------------------------------------------------------------------+
 //| The money to risk, in account currency                           |
 //| Reference: CTradeRisk::RiskAmount                                 |
 //+------------------------------------------------------------------+
 double CTradingControl::RiskAmount(void)
  {
   double amount=0.0;
   if(this.m_risk_setting.RiskMode()==RISK_FIXED_CASH)
      amount=this.m_risk_setting.FixedCashRisk();
   else
      amount=(this.m_risk_setting.RiskBase()==RISK_BASE_EQUITY ? this.m_account.Equity() : this.m_account.Balance())*(this.m_risk_setting.RiskPercent()/100.0);
   return amount*this.RiskDrawdownFactor();
  }
 //+------------------------------------------------------------------+
 //| A money amount and a price distance into a tradable volume       |
 //| Reference: CTradeRisk::VolumeForMoneyAndDistance                  |
 //+------------------------------------------------------------------+
 double CTradingControl::VolumeForMoneyAndDistance(const CSymbol *symbol,const double money,const double price_distance)
  {
   const double min_lot=symbol.LotsMin(),max_lot=symbol.LotsMax(),lot_step=symbol.LotsStep();
   if(price_distance<=0 || money<=0)
      return 0.0;
   const double value_per_lot=symbol.ValuePerLot(price_distance);
   if(value_per_lot<=0)
     {
      if(!this.m_risk_silent)
         ::PrintFormat("%s > %s: cannot value the price distance, cannot size a position",__FUNCTION__,symbol.Name());
      return 0.0;
     }
   const double raw_lot=money/value_per_lot;
   double lot=FloorToVolumeStep(raw_lot,lot_step);
   if(lot>max_lot)
      lot=FloorToVolumeStep(max_lot,lot_step);
   if(lot<min_lot)
     {
      if(!this.m_risk_setting.AllowMinLotOverRisk())
        {
         if(!this.m_risk_silent)
            ::PrintFormat("%s > correct volume (%.4f) is below the minimum lot (%.2f): trade skipped",__FUNCTION__,raw_lot,min_lot);
         return 0.0;
        }
      if(!this.m_risk_silent)
         ::PrintFormat("%s > caution: correct volume (%.4f) is below the minimum lot (%.2f): trading %.2f, the risk EXCEEDS %.2f",__FUNCTION__,raw_lot,min_lot,min_lot,money);
      lot=min_lot;
     }
   return lot;
  }
 //+------------------------------------------------------------------+
 //| A risk amount and a stop distance into a tradable volume         |
 //| Reference: CTradeRisk::CalculateLotSize                           |
 //+------------------------------------------------------------------+
 double CTradingControl::CalculateLotSize(const CSymbol *symbol,const double stop_distance,const double risk_amount)
  {
   const double min_lot=symbol.LotsMin(),max_lot=symbol.LotsMax(),lot_step=symbol.LotsStep();
   if(min_lot<=0 || lot_step<=0 || max_lot<min_lot)
     {
      if(!this.m_risk_silent)
         ::PrintFormat("%s > %s: invalid volume specification, cannot calculate the lot",__FUNCTION__,symbol.Name());
      return 0.0;
     }
   //--- Fixed-lot mode never consults the risk budget
   if(this.m_risk_setting.RiskMode()==RISK_FIXED_LOT)
     {
      //--- Change in V5: one key for every symbol, the volumes are of each symbol: 0 = the min lot of the symbol
      double raw_lot=(this.m_risk_setting.FixedLotSize()>0.0 ? this.m_risk_setting.FixedLotSize() : min_lot);
      if(this.m_risk_setting.EnableDrawdownScaling() && this.m_risk_setting.ApplyDrawdownToFixedLot())
        {
         const double factor=this.RiskDrawdownFactor();
         if(factor<1.0)
            raw_lot*=factor;
        }
      double lot=FloorToVolumeStep(raw_lot,lot_step);
      if(lot>max_lot)
         lot=FloorToVolumeStep(max_lot,lot_step);
      if(lot<min_lot)
        {
         if(!this.m_risk_setting.AllowMinLotOverRisk())
           {
            if(!this.m_risk_silent)
               ::PrintFormat("%s > fixed lot (%.4f) is below the minimum lot (%.2f): trade skipped",__FUNCTION__,raw_lot,min_lot);
            return 0.0;
           }
         lot=min_lot;
        }
      return lot;
     }
   //--- Every other mode needs the stop
   if(stop_distance<=0)
     {
      if(!this.m_risk_silent)
         ::PrintFormat("%s > no stop (no base ON in Stop Loss, or no value on this side): cannot size by risk (RiskMode %s); turn a base ON or use Fixed Lot",__FUNCTION__,
                       RiskModeText(this.m_risk_setting.RiskMode()));
      return 0.0;
     }
   return this.VolumeForMoneyAndDistance(symbol,risk_amount,stop_distance);
  }
 //+------------------------------------------------------------------+
 //| How much of the free margin one trade may take, %                |
 //| Reference: CTradeRisk::MarginUsageCap                             |
 //+------------------------------------------------------------------+
 double CTradingControl::MarginUsageCap(void)
  {
   if(!this.m_risk_setting.EnableAdaptiveMarginCap() || this.m_account.Margin()<=0.0)
      return this.m_risk_setting.MaxMarginUsagePercent();
   const double margin_level=this.m_account.MarginLevel();
   if(margin_level<=this.m_risk_setting.MarginLevelDanger())
     {
      if(!this.m_risk_silent)
         ::PrintFormat("%s > margin level %.1f%% at/below danger (%.1f%%): new trades blocked",__FUNCTION__,margin_level,this.m_risk_setting.MarginLevelDanger());
      return 0.0;
     }
   if(margin_level>=this.m_risk_setting.MarginLevelSafe())
      return this.m_risk_setting.MaxMarginUsagePercent();
   const double ratio=(margin_level-this.m_risk_setting.MarginLevelDanger())/(this.m_risk_setting.MarginLevelSafe()-this.m_risk_setting.MarginLevelDanger());
   return this.m_risk_setting.MaxMarginUsagePercent()*ratio;
  }
 //+------------------------------------------------------------------+
 //| Cap a volume to what the free margin can safely support          |
 //| Reference: CTradeRisk::CapLotToMargin                             |
 //+------------------------------------------------------------------+
 double CTradingControl::CapLotToMargin(const CSymbol *symbol,const ENUM_ORDER_TYPE order_type,const double lot,const double price)
  {
   const double margin_per_lot=this.m_account.MarginForAction(order_type,symbol.Name(),1.0,price);
   if(margin_per_lot==EMPTY_VALUE || margin_per_lot<=0.0)
     {
      if(!this.m_risk_silent)
         ::PrintFormat("%s > %s: the margin of one lot is unknown",__FUNCTION__,symbol.Name());
      return 0.0;
     }
   const double cap_percent=this.MarginUsageCap();
   if(cap_percent<=0.0)
      return 0.0;
   const double allowed_margin=this.m_account.MarginFree()*(cap_percent/100.0);
   const double max_affordable=FloorToVolumeStep(allowed_margin/margin_per_lot,symbol.LotsStep());
   if(max_affordable<symbol.LotsMin())
     {
      if(!this.m_risk_silent)
         ::PrintFormat("%s > cannot safely support the minimum lot (%.2f): free %.2f, used %.2f",__FUNCTION__,symbol.LotsMin(),this.m_account.MarginFree(),this.m_account.Margin());
      return 0.0;
     }
   if(lot>max_affordable)
     {
      if(!this.m_risk_silent)
         ::PrintFormat("%s > lot %.2f exceeds the %.1f%% margin cap: reduced to %.2f",__FUNCTION__,lot,cap_percent,max_affordable);
      return max_affordable;
     }
   return lot;
  }
 //+------------------------------------------------------------------+
 //| Build a complete trade plan                                      |
 //| Reference: CTradeRisk::BuildPlan. Change in V5: the stop is given |
 //| (the bases ON, 0: none); its broker minimum is the one CTrading   |
 //| corrects to (CSymbol::StopLevelMin, from the close price) plus the|
 //| spread (from the entry price)                                     |
 //+------------------------------------------------------------------+
 bool CTradingControl::BuildPlan(CSymbol *symbol,const long strategy_id,const int direction,const double stop_loss,STradePlan &plan)
  {
   ::ZeroMemory(plan);
   if(this.m_account==NULL || symbol==NULL || !symbol.RefreshRates())
      return false;
   plan.strategy_id=strategy_id;
   plan.symbol=symbol.Name();
   plan.direction=direction;
   plan.orderType=(direction==1 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   const int digits=symbol.Digits();
   plan.entryPrice=::NormalizeDouble(direction==1 ? symbol.Ask() : symbol.Bid(),digits);
   if(plan.entryPrice<=0)
      return false;
   //--- The stop, widened to the broker minimum; the target from it
   if(stop_loss>0)
     {
      double stop_distance=::MathAbs(plan.entryPrice-stop_loss);
      const double min_stop=(symbol.StopLevelMin()+symbol.Spread())*symbol.Point();
      if(stop_distance<min_stop)
        {
         if(!this.m_risk_silent)
            ::PrintFormat("%s > stop distance %.1f points is below the broker minimum %.1f: widened",__FUNCTION__,stop_distance/symbol.Point(),min_stop/symbol.Point());
         stop_distance=min_stop;
        }
      plan.stopLoss  =::NormalizeDouble(plan.entryPrice-direction*stop_distance,digits);
      plan.takeProfit=::NormalizeDouble(plan.entryPrice+direction*stop_distance*this.m_risk_setting.TPRatio(),digits);
      plan.stopDistance=::MathAbs(plan.entryPrice-plan.stopLoss);
     }
   plan.riskAmount=(this.m_risk_setting.RiskMode()==RISK_FIXED_LOT ? 0.0 : this.RiskAmount());
   plan.lotSize=this.CalculateLotSize(symbol,plan.stopDistance,plan.riskAmount);
   return (plan.lotSize>0);
  }
 //+------------------------------------------------------------------+
 //| Trade-level check against the margin (the lot can shrink)        |
 //| Reference: CTradeRisk::ValidatePlan. Change in V5: no count of    |
 //| the open positions (canOpenTrade of Part 1 guards the OnTick of   |
 //| one strategy from opening again; here an Entry is one Event)      |
 //+------------------------------------------------------------------+
 bool CTradingControl::ValidatePlan(const CSymbol *symbol,STradePlan &plan)
  {
   const double capped=this.CapLotToMargin(symbol,plan.orderType,plan.lotSize,plan.entryPrice);
   if(capped<=0)
      return false;
   plan.lotSize=capped;
   return true;
  }
 //+------------------------------------------------------------------+
 //| BuildPlan, ValidatePlan; a failed plan is told (dparam 0)         |
 //| Reference: CTradeRisk::Check                                      |
 //+------------------------------------------------------------------+
 bool CTradingControl::CheckTradeRisk(CSymbol *symbol,const long strategy_id,const datetime bar_time,const int direction,const double stop_loss,STradePlan &plan)
  {
   if(this.BuildPlan(symbol,strategy_id,direction,stop_loss,plan) && this.ValidatePlan(symbol,plan))
      return true;
   const ENUM_SIGNAL_DIRECTION side=(direction==1 ? SIGNAL_DIRECTION_BUY : SIGNAL_DIRECTION_SELL);
   ::PrintFormat("%s > %s strategy %I64d %s: Entry not traded (trade tier)",__FUNCTION__,(symbol!=NULL ? symbol.Name() : ""),strategy_id,(direction==1 ? "BUY" : "SELL"));
   this.EventSend((ushort)RISK_EVENT_ENTRY_BLOCKED,this.EventPack(bar_time,strategy_id,side,true),0.0,(symbol!=NULL ? symbol.Name() : ""));
   return false;
  }
 //====================================================================
 //=== The basket tier. Reference: Include\BasketRisk.mqh (CBasketRisk)
 //=== the positions of the EA (MagicID) on one symbol, every strategy  =
 //====================================================================
 //+------------------------------------------------------------------+
 //| The statistics of the basket of a symbol (made the first time),  |
 //| RAM only as the author (a restart resets them)                    |
 //| Reference: CBasketRisk::IndexOf                                   |
 //+------------------------------------------------------------------+
 int CTradingControl::BasketIndexOf(const string symbol)
  {
   const int n=::ArraySize(this.m_basket_symbols);
   for(int i=0;i<n;i++)
      if(this.m_basket_symbols[i]==symbol)
         return i;
   ::ArrayResize(this.m_basket_symbols,n+1);
   ::ArrayResize(this.m_basket_max_adverse,n+1);
   ::ArrayResize(this.m_basket_max_favourable,n+1);
   ::ArrayResize(this.m_basket_peak_count,n+1);
   this.m_basket_symbols[n]=symbol;
   this.m_basket_max_adverse[n]=0.0;
   this.m_basket_max_favourable[n]=0.0;
   this.m_basket_peak_count[n]=0;
   return n;
  }
 //+------------------------------------------------------------------+
 //| How far the basket travels against and in favour of us           |
 //| Reference: CBasketRisk::UpdateExcursion                           |
 //+------------------------------------------------------------------+
 void CTradingControl::BasketUpdateExcursion(const string symbol,const SBasketState &basket_state)
  {
   if(!this.m_risk_setting.BasketTrackExcursion())
      return;
   const int i=this.BasketIndexOf(symbol);
   if(basket_state.positionCount>this.m_basket_peak_count[i])
      this.m_basket_peak_count[i]=basket_state.positionCount;
   if(basket_state.floatingPL<0 && ::MathAbs(basket_state.floatingPL)>this.m_basket_max_adverse[i])
      this.m_basket_max_adverse[i]=::MathAbs(basket_state.floatingPL);
   if(basket_state.floatingPL>this.m_basket_max_favourable[i])
      this.m_basket_max_favourable[i]=basket_state.floatingPL;
  }
 //+------------------------------------------------------------------+
 //| Report what the closed basket did, then start clean              |
 //| Reference: CBasketRisk::ResetTracking                             |
 //+------------------------------------------------------------------+
 void CTradingControl::BasketResetTracking(const string symbol)
  {
   const int i=this.BasketIndexOf(symbol);
   if(this.m_basket_peak_count[i]>0)
      ::PrintFormat("%s > %s basket closed | peak positions: %d | max adverse excursion: %.2f | max favourable: %.2f",
                    __FUNCTION__,symbol,this.m_basket_peak_count[i],this.m_basket_max_adverse[i],this.m_basket_max_favourable[i]);
   this.m_basket_max_adverse[i]=0.0;
   this.m_basket_max_favourable[i]=0.0;
   this.m_basket_peak_count[i]=0;
  }
 //+------------------------------------------------------------------+
 //| Basket-level protection, once per bar of the chart TF (instead of|
 //| the OnTick bar check of the author): the cut closes the positions |
 //| of the EA on the symbol (source Basket)                           |
 //| Reference: CBasketRisk::Manage, CBasketRisk::CloseAll             |
 //+------------------------------------------------------------------+
 void CTradingControl::BasketManage(const string symbol,const long magic_id,const ENUM_TIMEFRAMES timeframe)
  {
   if(!this.m_risk_setting.BasketEnabled())
      return;
   SBasketState basket_state;
   if(!this.m_market.BasketState(symbol,magic_id,this.m_account,basket_state))
     {
      this.BasketResetTracking(symbol);
      return;
     }
   this.BasketUpdateExcursion(symbol,basket_state);
   string reason="";
   //--- Aggregate loss cut
   if(this.m_risk_setting.BasketMaxLossPercent()>0)
     {
      const double max_loss=(this.m_risk_setting.BasketLossBase()==RISK_BASE_EQUITY ? this.m_account.Equity() : this.m_account.Balance())*(this.m_risk_setting.BasketMaxLossPercent()/100.0);
      if(basket_state.floatingPL<=-max_loss)
         reason=::StringFormat("aggregate loss %.2f breached the %.1f%% limit (%.2f) across %d position(s)",
                               basket_state.floatingPL,this.m_risk_setting.BasketMaxLossPercent(),max_loss,basket_state.positionCount);
     }
   //--- Time stop: a basket underwater for too long
   if(reason=="" && this.m_risk_setting.BasketMaxHoldBars()>0 && basket_state.floatingPL<0 && basket_state.oldestOpenTime>0)
     {
      const int bar_seconds=::PeriodSeconds(timeframe);
      const int bars_held=(bar_seconds>0 ? (int)((::TimeCurrent()-basket_state.oldestOpenTime)/bar_seconds) : 0);
      if(bar_seconds>0 && bars_held>=this.m_risk_setting.BasketMaxHoldBars())
         reason=::StringFormat("held %d bars while losing %.2f (limit %d bars)",bars_held,basket_state.floatingPL,this.m_risk_setting.BasketMaxHoldBars());
     }
   if(reason=="")
      return;
   ::PrintFormat("%s > %s BASKET CLOSE | %s: %d position(s) closed",__FUNCTION__,symbol,reason,this.ClosePositions(symbol,0,0,"Basket"));
   this.BasketResetTracking(symbol);
  }
 //+------------------------------------------------------------------+
 //| Would adding this trade push the basket past its limits?         |
 //| Reference: CBasketRisk::AcceptsNewTrade. Change in V5: no position|
 //| ceiling (MaxBasketPositions: one strategy, no stacking; here many |
 //| strategies add to the basket, its risk is the loss, the margin,   |
 //| the hold bars); AllowHedging (canOpenTrade of Part 1) is a rule of|
 //| the basket: off, no leg against the open ones                     |
 //+------------------------------------------------------------------+
 bool CTradingControl::BasketAcceptsNewTrade(const STradePlan &plan,const long magic_id)
  {
   if(!this.m_risk_setting.BasketEnabled())
      return true;
   SBasketState basket_state;
   const bool has_basket=this.m_market.BasketState(plan.symbol,magic_id,this.m_account,basket_state);
   if(has_basket && !this.m_risk_setting.AllowHedging() &&
      this.m_market.PositionsCount(plan.symbol,(plan.direction==1 ? POSITION_TYPE_SELL : POSITION_TYPE_BUY),magic_id)>0)
     {
      ::PrintFormat("%s > %s %s: the basket has the opposite side and AllowHedging is off",__FUNCTION__,plan.symbol,(plan.direction==1 ? "BUY" : "SELL"));
      return false;
     }
   //--- Aggregate margin ceiling of the basket
   if(this.m_risk_setting.BasketMaxMarginPercent()>0)
     {
      const double new_leg_margin=this.m_account.MarginForAction(plan.orderType,plan.symbol,plan.lotSize,plan.entryPrice);
      if(new_leg_margin==EMPTY_VALUE)
         return false;
      const double projected=(has_basket ? basket_state.usedMargin : 0.0)+new_leg_margin;
      const double ceiling=this.m_account.Equity()*(this.m_risk_setting.BasketMaxMarginPercent()/100.0);
      if(this.m_account.Equity()>0 && projected>ceiling)
        {
         ::PrintFormat("%s > %s basket margin ceiling: %.2f of %.2f allowed (%.1f%% of equity)",__FUNCTION__,plan.symbol,projected,ceiling,this.m_risk_setting.BasketMaxMarginPercent());
         return false;
        }
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| BasketAcceptsNewTrade; a refused plan is told (dparam 1)          |
 //| Reference: CBasketRisk::Check                                     |
 //+------------------------------------------------------------------+
 bool CTradingControl::CheckBasketRisk(const STradePlan &plan,const long magic_id,const datetime bar_time)
  {
   if(this.BasketAcceptsNewTrade(plan,magic_id))
      return true;
   this.EventSend((ushort)RISK_EVENT_ENTRY_BLOCKED,this.EventPack(bar_time,plan.strategy_id,(plan.direction==1 ? SIGNAL_DIRECTION_BUY : SIGNAL_DIRECTION_SELL),true),1.0,plan.symbol);
   return false;
  }
 //====================================================================
 //=== The portfolio tier. Reference: Include\PortfolioRisk.mqh        =
 //=== (CPortfolioRisk): every position of the account, or of the EA   =
 //=== (its MagicID) and the ExtraPortfolioMagics. As the author it     =
 //=== only blocks new trades: it closes nothing                        =
 //====================================================================
 //+------------------------------------------------------------------+
 //| Does this order/position belong to the portfolio being measured? |
 //| Reference: CPortfolioRisk::IsTracked (RegisterMagic: the MagicID  |
 //| of the EA, MagicIdEA)                                             |
 //+------------------------------------------------------------------+
 bool CTradingControl::PortfolioIsTracked(const COrder *order)
  {
   if(this.m_risk_setting.PortfolioScope()==PORTFOLIO_ACCOUNT_WIDE)
      return true;
   const long magic_id=this.MagicIdEA(order.Symbol());
   if(magic_id!=0 && order.MagicID()==magic_id)
      return true;
   string parts[];
   const int count=::StringSplit(this.m_risk_setting.PortfolioExtraMagics(),',',parts);
   for(int i=0;i<count;i++)
     {
      ::StringTrimLeft(parts[i]);
      ::StringTrimRight(parts[i]);
      if(parts[i]!="" && ::StringToInteger(parts[i])==order.Magic())
         return true;
     }
   return false;
  }
 //+------------------------------------------------------------------+
 //| A currency in the exposure list (made the first time)            |
 //| Reference: CPortfolioRisk::FindCurrency, AccumulateCurrency       |
 //+------------------------------------------------------------------+
 int CTradingControl::CurrencyIndex(const SCurrencyExposure &list[],const string currency) const
  {
   for(int i=0;i<::ArraySize(list);i++)
      if(list[i].currency==currency)
         return i;
   return -1;
  }
 void CTradingControl::AccumulateCurrency(SCurrencyExposure &list[],const string currency,const double signed_lots,const bool count_position)
  {
   if(currency=="")
      return;
   int index=this.CurrencyIndex(list,currency);
   if(index<0)
     {
      index=::ArraySize(list);
      ::ArrayResize(list,index+1);
      list[index].currency=currency;
      list[index].netLots=0.0;
      list[index].grossLots=0.0;
      list[index].positionCount=0;
     }
   list[index].netLots+=signed_lots;
   list[index].grossLots+=::MathAbs(signed_lots);
   if(count_position)
      list[index].positionCount++;
  }
 //+------------------------------------------------------------------+
 //| The base / profit currency of a symbol from CSymbol (a symbol not |
 //| in the collection: from the terminal)                             |
 //+------------------------------------------------------------------+
 void CTradingControl::SymbolCurrencies(const string symbol,string &base,string &quote)
  {
   CSymbol *symbol_obj=(this.m_symbol_collection!=NULL ? this.m_symbol_collection.GetSymbolObjByName(symbol) : NULL);
   base =(symbol_obj!=NULL ? symbol_obj.CurrencyBase()   : ::SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE));
   quote=(symbol_obj!=NULL ? symbol_obj.CurrencyProfit() : ::SymbolInfoString(symbol,SYMBOL_CURRENCY_PROFIT));
  }
 //+------------------------------------------------------------------+
 //| A snapshot of the total exposure (false: nothing open)           |
 //| Reference: CPortfolioRisk::Scan                                   |
 //+------------------------------------------------------------------+
 bool CTradingControl::PortfolioScan(SPortfolioState &state)
  {
   ::ZeroMemory(state);
   state.equity=this.m_account.Equity();
   state.balance=this.m_account.Balance();
   state.freeMargin=this.m_account.MarginFree();
   state.marginLevel=this.m_account.MarginLevel();
   string seen_symbols[];
   CArrayObj *list=this.m_market.GetList();
   for(int i=0;list!=NULL && i<list.Total();i++)
     {
      COrder *order=list.At(i);
      if(order==NULL || !this.PortfolioIsTracked(order))
         continue;
      if(order.Status()==ORDER_STATUS_MARKET_PENDING)
        {
         state.pendingCount++;
         continue;
        }
      if(!this.m_market.HasPosition(order))
         continue;
      const string symbol=order.Symbol();
      const double volume=order.Volume();
      state.positionCount++;
      state.totalVolume+=volume;
      state.floatingPL+=order.Profit()+order.Swap();
      bool known=false;
      for(int s=0;s<::ArraySize(seen_symbols) && !known;s++)
         known=(seen_symbols[s]==symbol);
      if(!known)
        {
         const int n=::ArraySize(seen_symbols);
         ::ArrayResize(seen_symbols,n+1);
         seen_symbols[n]=symbol;
        }
      //--- Only needed when the account-wide figure does not apply
      if(this.m_risk_setting.PortfolioScope()==PORTFOLIO_MAGIC_FILTERED)
        {
         const double leg_margin=this.m_account.MarginForAction((order.TypeOrder()==(long)POSITION_TYPE_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL),symbol,volume,order.PriceOpen());
         if(leg_margin!=EMPTY_VALUE)
            state.usedMargin+=leg_margin;
        }
     }
   state.symbolCount=::ArraySize(seen_symbols);
   if(this.m_risk_setting.PortfolioScope()==PORTFOLIO_ACCOUNT_WIDE)
      state.usedMargin=this.m_account.Margin();
   return (state.positionCount>0 || state.pendingCount>0);
  }
 //+------------------------------------------------------------------+
 //| Exposure by currency: long the pair = long the base, short the   |
 //| quote. Reference: CPortfolioRisk::GetCurrencyExposure             |
 //+------------------------------------------------------------------+
 int CTradingControl::PortfolioCurrencyExposure(SCurrencyExposure &exposure[])
  {
   ::ArrayResize(exposure,0);
   CArrayObj *list=this.m_market.GetList();
   for(int i=0;list!=NULL && i<list.Total();i++)
     {
      COrder *order=list.At(i);
      if(!this.m_market.HasPosition(order) || !this.PortfolioIsTracked(order))
         continue;
      string base,quote;
      this.SymbolCurrencies(order.Symbol(),base,quote);
      const double signed_lots=(order.TypeOrder()==(long)POSITION_TYPE_BUY ? order.Volume() : -order.Volume());
      this.AccumulateCurrency(exposure,base,signed_lots,true);
      this.AccumulateCurrency(exposure,quote,-signed_lots,false);
     }
   return ::ArraySize(exposure);
  }
 //+------------------------------------------------------------------+
 //| Log the current portfolio picture                                |
 //| Reference: CPortfolioRisk::PrintSnapshot                          |
 //+------------------------------------------------------------------+
 void CTradingControl::PortfolioPrintSnapshot(void)
  {
   SPortfolioState state;
   this.PortfolioScan(state);
   ::PrintFormat("PORTFOLIO | Positions: %d across %d symbol(s) | Pending: %d | Volume: %.2f | Floating: %.2f | Margin used: %.2f | Margin level: %.1f%%",
                 state.positionCount,state.symbolCount,state.pendingCount,state.totalVolume,state.floatingPL,state.usedMargin,state.marginLevel);
   SCurrencyExposure exposure[];
   const int count=this.PortfolioCurrencyExposure(exposure);
   for(int i=0;i<count;i++)
      if(::MathAbs(exposure[i].netLots)>0.0)
         ::PrintFormat("   %s | Net: %+.2f lots | Gross: %.2f lots",exposure[i].currency,exposure[i].netLots,exposure[i].grossLots);
  }
 //+------------------------------------------------------------------+
 //| The gate: can this trade be added to the portfolio?              |
 //| Reference: CPortfolioRisk::CanOpenPosition                        |
 //+------------------------------------------------------------------+
 bool CTradingControl::PortfolioCanOpenPosition(const string symbol,const ENUM_ORDER_TYPE order_type,const double volume,const double price,string &reason)
  {
   reason="";
   SPortfolioState state;
   this.PortfolioScan(state);
   //--- Total position count
   const int max_total=this.m_risk_setting.PortfolioMaxTotalPositions();
   if(max_total>0 && state.positionCount+state.pendingCount>=max_total)
     {
      reason=::StringFormat("portfolio already holds %d position(s)/order(s), limit is %d",state.positionCount+state.pendingCount,max_total);
      return false;
     }
   //--- Concentration in one symbol; is the symbol already traded
   int symbol_count=0;
   CArrayObj *list=this.m_market.GetList();
   for(int i=0;list!=NULL && i<list.Total();i++)
     {
      COrder *order=list.At(i);
      if(this.m_market.HasPosition(order,symbol) && this.PortfolioIsTracked(order))
         symbol_count++;
     }
   const int max_per_symbol=this.m_risk_setting.PortfolioMaxPositionsPerSymbol();
   if(max_per_symbol>0 && symbol_count>=max_per_symbol)
     {
      reason=::StringFormat("%s already holds %d position(s), limit is %d",symbol,symbol_count,max_per_symbol);
      return false;
     }
   //--- Number of distinct symbols in play: only a new symbol would widen the portfolio
   const int max_symbols=this.m_risk_setting.PortfolioMaxSymbols();
   if(max_symbols>0 && state.symbolCount>=max_symbols && symbol_count==0)
     {
      reason=::StringFormat("portfolio already spans %d symbol(s), limit is %d",state.symbolCount,max_symbols);
      return false;
     }
   //--- Total margin consumption, projected
   const double max_margin=this.m_risk_setting.PortfolioMaxMarginPercent();
   if(max_margin>0 && state.equity>0)
     {
      const double new_leg_margin=this.m_account.MarginForAction(order_type,symbol,volume,price);
      if(new_leg_margin==EMPTY_VALUE)
        {
         reason=::StringFormat("the margin of %s is unknown",symbol);
         return false;
        }
      const double projected=state.usedMargin+new_leg_margin;
      const double ceiling=state.equity*(max_margin/100.0);
      if(projected>ceiling)
        {
         reason=::StringFormat("margin would reach %.2f of %.2f allowed (%.1f%% of equity)",projected,ceiling,max_margin);
         return false;
        }
     }
   //--- Aggregate floating loss
   const double max_loss_percent=this.m_risk_setting.PortfolioMaxLossPercent();
   if(max_loss_percent>0 && state.balance>0)
     {
      const double max_loss=state.balance*(max_loss_percent/100.0);
      if(state.floatingPL<=-max_loss)
        {
         reason=::StringFormat("portfolio is already down %.2f, limit is %.2f (%.1f%%)",state.floatingPL,max_loss,max_loss_percent);
         return false;
        }
     }
   //--- Currency concentration, projected
   const double max_net_lots=this.m_risk_setting.PortfolioMaxNetCurrencyLots();
   if(max_net_lots>0)
     {
      SCurrencyExposure exposure[];
      this.PortfolioCurrencyExposure(exposure);
      string base,quote;
      this.SymbolCurrencies(symbol,base,quote);
      const double signed_lots=volume*(order_type==ORDER_TYPE_BUY ? 1 : -1);
      this.AccumulateCurrency(exposure,base,signed_lots,false);
      this.AccumulateCurrency(exposure,quote,-signed_lots,false);
      const int base_index=this.CurrencyIndex(exposure,base);
      const int quote_index=this.CurrencyIndex(exposure,quote);
      if(base_index>=0 && ::MathAbs(exposure[base_index].netLots)>max_net_lots)
        {
         reason=::StringFormat("net %s exposure would reach %+.2f lots, limit is %.2f",base,exposure[base_index].netLots,max_net_lots);
         return false;
        }
      if(quote_index>=0 && ::MathAbs(exposure[quote_index].netLots)>max_net_lots)
        {
         reason=::StringFormat("net %s exposure would reach %+.2f lots, limit is %.2f",quote,exposure[quote_index].netLots,max_net_lots);
         return false;
        }
     }
   return true;
  }
 //+------------------------------------------------------------------+
 //| EnablePortfolioRisk, PortfolioCanOpenPosition; a refused plan is  |
 //| told (dparam 2). Reference: CPortfolioRisk::Check                 |
 //+------------------------------------------------------------------+
 bool CTradingControl::CheckPortfolioRisk(const STradePlan &plan,const datetime bar_time)
  {
   if(!this.m_risk_setting.PortfolioEnabled())
      return true;
   string reason="";
   if(this.PortfolioCanOpenPosition(plan.symbol,plan.orderType,plan.lotSize,plan.entryPrice,reason))
      return true;
   ::PrintFormat("%s > portfolio limit: %s. Trade skipped",__FUNCTION__,reason);
   this.EventSend((ushort)RISK_EVENT_ENTRY_BLOCKED,this.EventPack(bar_time,plan.strategy_id,(plan.direction==1 ? SIGNAL_DIRECTION_BUY : SIGNAL_DIRECTION_SELL),true),2.0,plan.symbol);
   return false;
  }
#endif // __TRADINGCONTROL_RISK_MQH__
