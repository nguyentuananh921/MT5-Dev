//+------------------------------------------------------------------+
//|                                       SmartMoneySettingManager.mqh |
//+------------------------------------------------------------------+
#ifndef __SMARTMONEYSETTINGMANAGER_MQH__
#define __SMARTMONEYSETTINGMANAGER_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Services\JSONConfig.mqh>
#ifndef CSMARTMONEYSETTINGMANAGER_MQH_DECLARATION
#define CSMARTMONEYSETTINGMANAGER_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| The settings the Smart Money tab changes: they start from the    |
 //| inputs of the EA, the "Smart_Money_Setting" key of                |
 //| Config_Setting.json (written by the Save of the tab) is read      |
 //| over them at the start. The colours and what Python calculates   |
 //| and has no box in the tab stay the inputs of the EA              |
 //+------------------------------------------------------------------+
 class CSmartMoneySettingManager : public CBaseObj
  {
   private:
     CSwingSetting             *m_SwingSetting;              // EA owns
     CStructureSetting         *m_StructureSetting;
     CFvgSetting               *m_FvgSetting;
     CMomentumCandleSetting    *m_MomentumCandleSetting;
     CSupplyDemandSetting      *m_SupplyDemandSetting;
     CTrendlineSetting         *m_TrendlineSetting;
     CSupportResistanceSetting *m_SupportResistanceSetting;
     CMarketConditionSetting   *m_MarketConditionSetting;
     bool                       m_loaded_from_json;
     string                     Text(const bool on) const { return (on ? "true" : "false"); }
     bool                       LoadFromJSON(const string full_path);
   public:
     void                       OnInitEvent(CSwingSetting *swing,CStructureSetting *structure,CFvgSetting *fvg,CMomentumCandleSetting *momentum,
                                            CSupplyDemandSetting *supply_demand,CTrendlineSetting *trendline,CSupportResistanceSetting *support_resistance,CMarketConditionSetting *market_condition);
     void                       BuildJsonSection(string &out_json) const;
   //--- Writes the "Smart_Money_Setting" key of Config_Setting.json, the other keys stay as they are
     bool                       SaveToJSON(void);
                                CSmartMoneySettingManager(void);
  };
#endif // CSMARTMONEYSETTINGMANAGER_MQH_DECLARATION
#ifndef CSMARTMONEYSETTINGMANAGER_MQH_IMPLEMENTATION
#define CSMARTMONEYSETTINGMANAGER_MQH_IMPLEMENTATION
 CSmartMoneySettingManager::CSmartMoneySettingManager(void) : m_SwingSetting(NULL),m_StructureSetting(NULL),m_FvgSetting(NULL),m_MomentumCandleSetting(NULL),
                                                              m_SupplyDemandSetting(NULL),m_TrendlineSetting(NULL),m_SupportResistanceSetting(NULL),m_MarketConditionSetting(NULL),m_loaded_from_json(false)
  {
  }
 void CSmartMoneySettingManager::OnInitEvent(CSwingSetting *swing,CStructureSetting *structure,CFvgSetting *fvg,CMomentumCandleSetting *momentum,
                                             CSupplyDemandSetting *supply_demand,CTrendlineSetting *trendline,CSupportResistanceSetting *support_resistance,CMarketConditionSetting *market_condition)
  {
   this.m_SwingSetting=swing;
   this.m_StructureSetting=structure;
   this.m_FvgSetting=fvg;
   this.m_MomentumCandleSetting=momentum;
   this.m_SupplyDemandSetting=supply_demand;
   this.m_TrendlineSetting=trendline;
   this.m_SupportResistanceSetting=support_resistance;
   this.m_MarketConditionSetting=market_condition;
   if(this.m_loaded_from_json)
      return;   // a chart-change re-init: the settings keep what the tab changed
   this.LoadFromJSON(this.GetFolderName()+CONFIG_SETTING_FILE);
   this.m_loaded_from_json=true;
  }
 //+------------------------------------------------------------------+
 //| One object for each section of the tab                           |
 //+------------------------------------------------------------------+
 void CSmartMoneySettingManager::BuildJsonSection(string &out_json) const
  {
   out_json="{\n";
   out_json+="  \"swing\": {\"strength\":"+(string)this.m_SwingSetting.Strength()+",\"use_wick\":"+this.Text(this.m_SwingSetting.PriceBasis()==SWING_PRICE_BASIS_WICK)+
             ",\"show_high\":"+this.Text(this.m_SwingSetting.SignalShow(SWING_TYPE_HIGH))+",\"show_low\":"+this.Text(this.m_SwingSetting.SignalShow(SWING_TYPE_LOW))+"},\n";
   out_json+="  \"structure\": {\"show_bos\":"+this.Text(this.m_StructureSetting.SignalShow(MARKET_STRUCTURE_BOS))+",\"show_choch\":"+this.Text(this.m_StructureSetting.SignalShow(MARKET_STRUCTURE_CHOCH))+"},\n";
   out_json+="  \"fvg\": {\"show_bullish\":"+this.Text(this.m_FvgSetting.ShowBullish())+",\"show_bearish\":"+this.Text(this.m_FvgSetting.ShowBearish())+",\"show_dead\":"+this.Text(this.m_FvgSetting.ShowDead())+
             ",\"max_dead\":"+(string)this.m_FvgSetting.MaxDead()+",\"open_bullish\":"+(string)this.m_FvgSetting.OpenNewestBullish()+",\"open_bearish\":"+(string)this.m_FvgSetting.OpenNewestBearish()+"},\n";
   out_json+="  \"momentum\": {\"bars\":"+(string)this.m_MomentumCandleSetting.Bars()+",\"multiplier\":"+::DoubleToString(this.m_MomentumCandleSetting.Multiplier(),4)+",\"show\":"+this.Text(this.m_MomentumCandleSetting.Show())+"},\n";
   out_json+="  \"supply_demand\": {\"show_demand\":"+this.Text(this.m_SupplyDemandSetting.ShowDemand())+",\"show_supply\":"+this.Text(this.m_SupplyDemandSetting.ShowSupply())+",\"show_dead\":"+this.Text(this.m_SupplyDemandSetting.ShowDead())+
             ",\"max_dead\":"+(string)this.m_SupplyDemandSetting.MaxDead()+",\"open_demand\":"+(string)this.m_SupplyDemandSetting.OpenNewestDemand()+",\"open_supply\":"+(string)this.m_SupplyDemandSetting.OpenNewestSupply()+"},\n";
   out_json+="  \"trendline\": {\"show_support\":"+this.Text(this.m_TrendlineSetting.ShowSupport())+",\"show_resistance\":"+this.Text(this.m_TrendlineSetting.ShowResistance())+",\"show_dead\":"+this.Text(this.m_TrendlineSetting.ShowDead())+
             ",\"max_dead\":"+(string)this.m_TrendlineSetting.MaxDead()+",\"nearest\":"+(string)this.m_TrendlineSetting.Nearest()+",\"confirm_atr\":"+::DoubleToString(this.m_TrendlineSetting.ConfirmATR(),4)+",\"confirm_closes\":"+(string)this.m_TrendlineSetting.ConfirmCloses()+
             ",\"min_move_atr\":"+::DoubleToString(this.m_TrendlineSetting.MinMoveATR(),4)+",\"min_swing_atr\":"+::DoubleToString(this.m_TrendlineSetting.MinSwingATR(),4)+",\"swings_tried\":"+(string)this.m_TrendlineSetting.SwingsTried()+"},\n";
   out_json+="  \"movement\": {\"show_moves\":"+this.Text(this.m_MarketConditionSetting.ShowMoves())+",\"show_unclassified\":"+this.Text(this.m_MarketConditionSetting.ShowUnclassified())+"},\n";
   out_json+="  \"support_resistance\": {\"show_support\":"+this.Text(this.m_SupportResistanceSetting.ShowSupport())+",\"show_resistance\":"+this.Text(this.m_SupportResistanceSetting.ShowResistance())+",\"show_dead\":"+this.Text(this.m_SupportResistanceSetting.ShowDead())+
             ",\"max_dead\":"+(string)this.m_SupportResistanceSetting.MaxDead()+",\"open_support\":"+(string)this.m_SupportResistanceSetting.OpenNewestSupport()+",\"open_resistance\":"+(string)this.m_SupportResistanceSetting.OpenNewestResistance()+",\"min_score\":"+(string)this.m_SupportResistanceSetting.MinScore()+",\"confirm_closes\":"+(string)this.m_SupportResistanceSetting.ConfirmCloses()+
             ",\"ghost_bars\":"+(string)this.m_SupportResistanceSetting.GhostBars()+",\"revive\":"+this.Text(this.m_SupportResistanceSetting.Revive())+",\"max_age_bars\":"+(string)this.m_SupportResistanceSetting.MaxAgeBars()+
             ",\"volume_bars\":"+(string)this.m_SupportResistanceSetting.VolumeMABars()+"}\n";
   out_json+=" }";
  }
 bool CSmartMoneySettingManager::SaveToJSON(void)
  {
   string value;
   this.BuildJsonSection(value);
   return ::JSONConfig_SaveSection(this.GetFolderName()+CONFIG_SETTING_FILE,"Smart_Money_Setting",value);
  }
 //+------------------------------------------------------------------+
 //| What the file has is set over the inputs; what it has not stays  |
 //+------------------------------------------------------------------+
 bool CSmartMoneySettingManager::LoadFromJSON(const string full_path)
  {
   string content=::JSONConfig_ReadWholeFile(full_path);
   if(content=="")
      return false;
   string clean=::JSONConfig_StripComments(content);
   string section=::JSONConfig_ExtractRawSection(clean,"Smart_Money_Setting");
   if(section=="")
      return false;
   bool flag;
   int count;
   double value;
   string group=::JSONConfig_ExtractRawSection(section,"swing");
   if(::JSONConfig_IntValue(group,"strength",count))      this.m_SwingSetting.Strength(count);
   if(::JSONConfig_BoolValue(group,"use_wick",flag))      this.m_SwingSetting.UseWick(flag);
   if(::JSONConfig_BoolValue(group,"show_high",flag))     this.m_SwingSetting.SignalShow(SWING_TYPE_HIGH,flag);
   if(::JSONConfig_BoolValue(group,"show_low",flag))      this.m_SwingSetting.SignalShow(SWING_TYPE_LOW,flag);
   group=::JSONConfig_ExtractRawSection(section,"structure");
   if(::JSONConfig_BoolValue(group,"show_bos",flag))      this.m_StructureSetting.SignalShow(MARKET_STRUCTURE_BOS,flag);
   if(::JSONConfig_BoolValue(group,"show_choch",flag))    this.m_StructureSetting.SignalShow(MARKET_STRUCTURE_CHOCH,flag);
   group=::JSONConfig_ExtractRawSection(section,"fvg");
   if(::JSONConfig_BoolValue(group,"show_bullish",flag))  this.m_FvgSetting.ShowBullish(flag);
   if(::JSONConfig_BoolValue(group,"show_bearish",flag))  this.m_FvgSetting.ShowBearish(flag);
   if(::JSONConfig_BoolValue(group,"show_dead",flag))     this.m_FvgSetting.ShowDead(flag);
   if(::JSONConfig_IntValue(group,"max_dead",count))      this.m_FvgSetting.MaxDead(count);
   if(::JSONConfig_IntValue(group,"open_bullish",count))  this.m_FvgSetting.OpenNewestBullish(count);
   if(::JSONConfig_IntValue(group,"open_bearish",count))  this.m_FvgSetting.OpenNewestBearish(count);
   group=::JSONConfig_ExtractRawSection(section,"momentum");
   if(::JSONConfig_IntValue(group,"bars",count))          this.m_MomentumCandleSetting.Bars(count);
   if(::JSONConfig_DoubleValue(group,"multiplier",value)) this.m_MomentumCandleSetting.Multiplier(value);
   if(::JSONConfig_BoolValue(group,"show",flag))          this.m_MomentumCandleSetting.Show(flag);
   group=::JSONConfig_ExtractRawSection(section,"supply_demand");
   if(::JSONConfig_BoolValue(group,"show_demand",flag))   this.m_SupplyDemandSetting.ShowDemand(flag);
   if(::JSONConfig_BoolValue(group,"show_supply",flag))   this.m_SupplyDemandSetting.ShowSupply(flag);
   if(::JSONConfig_BoolValue(group,"show_dead",flag))     this.m_SupplyDemandSetting.ShowDead(flag);
   if(::JSONConfig_IntValue(group,"max_dead",count))      this.m_SupplyDemandSetting.MaxDead(count);
   if(::JSONConfig_IntValue(group,"open_demand",count))   this.m_SupplyDemandSetting.OpenNewestDemand(count);
   if(::JSONConfig_IntValue(group,"open_supply",count))   this.m_SupplyDemandSetting.OpenNewestSupply(count);
   group=::JSONConfig_ExtractRawSection(section,"trendline");
   if(::JSONConfig_BoolValue(group,"show_support",flag))  this.m_TrendlineSetting.ShowSupport(flag);
   if(::JSONConfig_BoolValue(group,"show_resistance",flag)) this.m_TrendlineSetting.ShowResistance(flag);
   if(::JSONConfig_BoolValue(group,"show_dead",flag))     this.m_TrendlineSetting.ShowDead(flag);
   if(::JSONConfig_IntValue(group,"max_dead",count))      this.m_TrendlineSetting.MaxDead(count);
   if(::JSONConfig_IntValue(group,"nearest",count))       this.m_TrendlineSetting.Nearest(count);
   if(::JSONConfig_DoubleValue(group,"confirm_atr",value)) this.m_TrendlineSetting.ConfirmATR(value);
   if(::JSONConfig_IntValue(group,"confirm_closes",count)) this.m_TrendlineSetting.ConfirmCloses(count);
   if(::JSONConfig_DoubleValue(group,"min_move_atr",value)) this.m_TrendlineSetting.MinMoveATR(value);
   if(::JSONConfig_DoubleValue(group,"min_swing_atr",value)) this.m_TrendlineSetting.MinSwingATR(value);
   if(::JSONConfig_IntValue(group,"swings_tried",count))  this.m_TrendlineSetting.SwingsTried(count);
   group=::JSONConfig_ExtractRawSection(section,"movement");
   if(::JSONConfig_BoolValue(group,"show_moves",flag))   this.m_MarketConditionSetting.ShowMoves(flag);
   if(::JSONConfig_BoolValue(group,"show_unclassified",flag)) this.m_MarketConditionSetting.ShowUnclassified(flag);
   group=::JSONConfig_ExtractRawSection(section,"support_resistance");
   if(::JSONConfig_BoolValue(group,"show_support",flag))  this.m_SupportResistanceSetting.ShowSupport(flag);
   if(::JSONConfig_BoolValue(group,"show_resistance",flag)) this.m_SupportResistanceSetting.ShowResistance(flag);
   if(::JSONConfig_BoolValue(group,"show_dead",flag))     this.m_SupportResistanceSetting.ShowDead(flag);
   if(::JSONConfig_IntValue(group,"max_dead",count))      this.m_SupportResistanceSetting.MaxDead(count);
   if(::JSONConfig_IntValue(group,"open_support",count))  this.m_SupportResistanceSetting.OpenNewestSupport(count);
   if(::JSONConfig_IntValue(group,"open_resistance",count)) this.m_SupportResistanceSetting.OpenNewestResistance(count);
   if(::JSONConfig_IntValue(group,"min_score",count))     this.m_SupportResistanceSetting.MinScore(count);
   if(::JSONConfig_IntValue(group,"confirm_closes",count)) this.m_SupportResistanceSetting.ConfirmCloses(count);
   if(::JSONConfig_IntValue(group,"ghost_bars",count))    this.m_SupportResistanceSetting.GhostBars(count);
   if(::JSONConfig_BoolValue(group,"revive",flag))        this.m_SupportResistanceSetting.Revive(flag);
   if(::JSONConfig_IntValue(group,"max_age_bars",count))  this.m_SupportResistanceSetting.MaxAgeBars(count);
   if(::JSONConfig_IntValue(group,"volume_bars",count))   this.m_SupportResistanceSetting.VolumeMABars(count);
   return true;
  }
#endif // CSMARTMONEYSETTINGMANAGER_MQH_IMPLEMENTATION
#endif // __SMARTMONEYSETTINGMANAGER_MQH__
