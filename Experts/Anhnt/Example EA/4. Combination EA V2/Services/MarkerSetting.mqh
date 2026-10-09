//+------------------------------------------------------------------+
//|                                                MarkerSetting.mqh |
//+------------------------------------------------------------------+
#ifndef __MARKERSETTING_MQH__
#define __MARKERSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Bases\BaseObj.mqh>
 #include "JSONConfig.mqh"
#ifndef CMARKERSETTING_MQH_DECLARATION
#define CMARKERSETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Colors of the CCandleMarker badges (Buy, Sell, Non-Related =    |
 //| a higher timeframe) and which of the 3 sources (Indicator,      |
 //| Candle pattern, Smart Money) make a marker show: a marker with  |
 //| any enabled source is shown, combinations included. Loaded from |
 //| the "Markers_Setting" key of Config_Setting.json at OnInitEvent;|
 //| the setting window edits it and                                 |
 //| CGUIPannel::SaveAllSettingsToJSON writes the file               |
 //+------------------------------------------------------------------+
 class CMarkerSetting : public CBaseObj
  {
   private:
     color             m_buy_color;
     color             m_sell_color;
     color             m_nonrelated_color;
     bool              m_show_indicator;
     bool              m_show_candle;
     bool              m_show_smartmoney;
   public:
     bool              OnInitEvent(void);
     color             BuyColor(void)        const { return this.m_buy_color;        }
     color             SellColor(void)       const { return this.m_sell_color;       }
     color             NonRelatedColor(void) const { return this.m_nonrelated_color; }
     void              SetColors(const color buy,const color sell,const color nonrelated)
                         { this.m_buy_color=buy; this.m_sell_color=sell; this.m_nonrelated_color=nonrelated; }
     bool              ShowIndicator(void)   const { return this.m_show_indicator;   }
     bool              ShowCandle(void)      const { return this.m_show_candle;      }
     bool              ShowSmartMoney(void)  const { return this.m_show_smartmoney;  }
     void              SetShowMarkers(const bool indicator,const bool candle,const bool smartmoney)
                         { this.m_show_indicator=indicator; this.m_show_candle=candle; this.m_show_smartmoney=smartmoney; }
   //--- Fixed palette offered by the color combos; the labels are what the JSON stores
     void              GetColorChoices(color &colors[],string &labels[]) const;
     string            ColorLabelForValue(const color clr) const;
     color             ColorForLabel(const string label,const color default_color) const;
   //--- Value of the "Markers_Setting" key; CGUIPannel::SaveAllSettingsToJSON writes the file
     void              BuildJsonSection(string &out_json) const;
                       CMarkerSetting(void);
  };
#endif // CMARKERSETTING_MQH_DECLARATION
#ifndef CMARKERSETTING_MQH_IMPLEMENTATION
#define CMARKERSETTING_MQH_IMPLEMENTATION
 CMarkerSetting::CMarkerSetting(void) : m_buy_color(clrDodgerBlue),m_sell_color(clrCrimson),m_nonrelated_color(clrGray),
                                       m_show_indicator(true),m_show_candle(true),m_show_smartmoney(true)
  {
  }
 //--- Defaults first, so a missing file or a partial "Markers_Setting" still leaves a working state
 bool CMarkerSetting::OnInitEvent(void)
  {
   this.m_buy_color       =clrDodgerBlue;
   this.m_sell_color      =clrCrimson;
   this.m_nonrelated_color=clrGray;
   this.m_show_indicator  =true;
   this.m_show_candle     =true;
   this.m_show_smartmoney =true;
   string full_path=this.GetFolderName()+"/Config_Setting.json";
   string content=::JSONConfig_ReadWholeFile(full_path);
   if(content=="")
      return false;
   string sv;
   if(::JSONConfig_StringValue(content,"buy_color",sv))        this.m_buy_color       =this.ColorForLabel(sv,this.m_buy_color);
   if(::JSONConfig_StringValue(content,"sell_color",sv))       this.m_sell_color      =this.ColorForLabel(sv,this.m_sell_color);
   if(::JSONConfig_StringValue(content,"nonrelated_color",sv)) this.m_nonrelated_color=this.ColorForLabel(sv,this.m_nonrelated_color);
   bool bv;
   if(::JSONConfig_BoolValue(content,"show_indicator_markers",bv))   this.m_show_indicator  =bv;
   if(::JSONConfig_BoolValue(content,"show_candle_markers",bv))      this.m_show_candle     =bv;
   if(::JSONConfig_BoolValue(content,"show_smartmoney_markers",bv))  this.m_show_smartmoney =bv;
   return true;
  }
 void CMarkerSetting::GetColorChoices(color &colors[],string &labels[]) const
  {
   color  c[]={clrLime,clrGreen,clrDodgerBlue,clrOrange,clrYellow,clrRed,clrCrimson,clrMagenta,clrGray,clrSilver,clrWhite,clrBlack};
   string l[]={"Lime","Green","Dodger Blue","Orange","Yellow","Red","Crimson","Magenta","Gray","Silver","White","Black"};
   ::ArrayCopy(colors,c);
   ::ArrayCopy(labels,l);
  }
 //--- JSON round trip through the same palette; an unknown value falls back to the raw number / the default
 string CMarkerSetting::ColorLabelForValue(const color clr) const
  {
   color colors[]; string labels[];
   this.GetColorChoices(colors,labels);
   for(int i=0; i<::ArraySize(colors); i++)
      if(colors[i]==clr)
         return labels[i];
   return (string)(int)clr;
  }
 color CMarkerSetting::ColorForLabel(const string label,const color default_color) const
  {
   color colors[]; string labels[];
   this.GetColorChoices(colors,labels);
   for(int i=0; i<::ArraySize(labels); i++)
      if(labels[i]==label)
         return colors[i];
   return default_color;
  }
 void CMarkerSetting::BuildJsonSection(string &out_json) const
  {
   out_json="{\n"+
            "  \"buy_color\": \""        +this.ColorLabelForValue(this.m_buy_color)+"\",\n"+
            "  \"sell_color\": \""       +this.ColorLabelForValue(this.m_sell_color)+"\",\n"+
            "  \"nonrelated_color\": \"" +this.ColorLabelForValue(this.m_nonrelated_color)+"\",\n"+
            "  \"show_indicator_markers\": "   +(this.m_show_indicator   ? "true" : "false")+",\n"+
            "  \"show_candle_markers\": "      +(this.m_show_candle      ? "true" : "false")+",\n"+
            "  \"show_smartmoney_markers\": "  +(this.m_show_smartmoney  ? "true" : "false")+"\n"+
            " }";
  }
#endif // CMARKERSETTING_MQH_IMPLEMENTATION
#endif // __MARKERSETTING_MQH__
