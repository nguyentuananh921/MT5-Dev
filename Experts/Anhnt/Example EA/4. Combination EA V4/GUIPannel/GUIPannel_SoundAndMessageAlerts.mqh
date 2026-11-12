//+------------------------------------------------------------------+
//|                              GUIPannel_SoundAndMessageAlerts.mqh |
//| Update in V4 Working with Event follow Event Rule                |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SOUNDANDMESSAGEALERTS_MQH
#define CGUIPANNEL_SOUNDANDMESSAGEALERTS_MQH
#include "GUIPannel.mqh"
 void CGUIPannel::OnEvent_Alert(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   const bool signal=(id==CHARTEVENT_CUSTOM+SERIES_EVENTS_SIGNAL);
   if(!signal && id!=CHARTEVENT_CUSTOM+SERIES_EVENTS_PATTERN && id!=CHARTEVENT_CUSTOM+SERIES_EVENTS_SWING && id!=CHARTEVENT_CUSTOM+SERIES_EVENTS_BOS && id!=CHARTEVENT_CUSTOM+SERIES_EVENTS_CHOCH)
      return;
   if(this.m_SymbolTFManager==NULL || this.m_BarInformationManager==NULL || this.m_IndicatorTemplateManager==NULL)
      return;
   datetime bar;
   long key;
   ENUM_SIGNAL_DIRECTION side;
   bool is_new;
   this.EventUnpack(lparam,bar,key,side,is_new);
   if(!is_new || side==SIGNAL_DIRECTION_NONE)
      return;
   string symbol,params;
   this.EventUnpackText(sparam,symbol,params);
   const ENUM_TIMEFRAMES timeframe=(ENUM_TIMEFRAMES)(long)dparam;
   const bool pair_sound=this.m_SymbolTFManager.Read_RAM(symbol,timeframe,"sound_alert");
   const bool pair_message=this.m_SymbolTFManager.Read_RAM(symbol,timeframe,"message_alert");
   string side_column="sell_signal";   // the flag of the side of the pair
   if(side==SIGNAL_DIRECTION_BUY)
      side_column="buy_signal";
   const bool pair_side=this.m_SymbolTFManager.Read_RAM(symbol,timeframe,side_column);
   if(!pair_side || (!pair_sound && !pair_message))
      return;
   string name="";
   bool sound=false,message=false;
   if(signal)
     {
      CIndicatorSetting *setting=this.m_IndicatorTemplateManager.Read_RAM((ENUM_INDICATOR)key,params);
      if(setting!=NULL)
        {
         name=setting.Display();
         const bool side_on=(side==SIGNAL_DIRECTION_BUY ? setting.BuySignal() : setting.SellSignal());   // an alert is of a side that is shown
         sound=(side_on && setting.SoundAlert());
         message=(side_on && setting.MessageAlert());
        }
     }
   else
     {
      CBarInformationSetting *setting=this.m_BarInformationManager.Read_RAM((ENUM_BAR_INFOR_TYPE)key);
      if(setting!=NULL)
        {
         name=setting.Name();
         const bool side_on=(side==SIGNAL_DIRECTION_BUY ? setting.ShowBuy() : setting.ShowSell());
         sound=(side_on && setting.SoundAlert());
         message=(side_on && setting.MessageAlert());
        }
     }
   if(message && pair_message)
     {
      string text="Close Bar Alert: "+symbol+" "+this.m_SymbolTFManager.Read_RAM(timeframe)+" "+::TimeToString(bar,TIME_MINUTES)+": "+name+(side==SIGNAL_DIRECTION_BUY ? " BUY" : " SELL");
      ::Print(text);
     }
   if(sound && pair_sound)
      this.m_alert_sound=(side==SIGNAL_DIRECTION_BUY ? "SIGNAL_BUY_EN.wav" : "SIGNAL_SELL_EN.wav");
  }
#endif // CGUIPANNEL_SOUNDANDMESSAGEALERTS_MQH
