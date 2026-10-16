//+------------------------------------------------------------------+
//|                                                MarkerSetting.mqh |
//+------------------------------------------------------------------+
#ifndef __MARKERSETTING_MQH__
#define __MARKERSETTING_MQH__
 #include <Vendors\Anhnt\Library\4. Combination Lib V3\Entities\Bases\BaseObj.mqh>
 #include "JSONConfig.mqh"
#ifndef CMARKERSETTING_MQH_DECLARATION
#define CMARKERSETTING_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Colors of the CCandleMarker badges (Buy, Sell, Non-Related =    |
 //| a higher timeframe). Which markers show is decided by the Buy / |
 //| Sell and Show flags of the indicators, candle patterns and Smart|
 //| Money (the Show Marker check boxes are their master switches).  |
 //| Loaded from the "Markers_Setting" key of Config_Setting.json at |
 //| OnInitEvent;|
 //| the setting window edits it and                                 |
 //| CGUIPannel::SaveAllSettingsToJSON writes the file               |
 //+------------------------------------------------------------------+
 class CMarkerSetting : public CBaseObj
  {
   private:
     color             m_buy_color;
     color             m_sell_color;
     color             m_nonrelated_color;
   public:
     bool              OnInitEvent(void);
     color             BuyColor(void)        const { return this.m_buy_color;        }
     color             SellColor(void)       const { return this.m_sell_color;       }
     color             NonRelatedColor(void) const { return this.m_nonrelated_color; }
     void              SetColors(const color buy,const color sell,const color nonrelated)
                         { this.m_buy_color=buy; this.m_sell_color=sell; this.m_nonrelated_color=nonrelated; }
   //--- Fixed palette offered by the color combos; the labels are what the JSON stores
     void              GetColorChoices(color &colors[],string &labels[]) const;
     string            ColorLabelForValue(const color clr) const;
     color             ColorForLabel(const string label,const color default_color) const;
   //--- Value of the "Markers_Setting" key; CGUIPannel::SaveAllSettingsToJSON writes the file
     void              BuildJsonSection(string &out_json) const;
   //--- Writes the "Markers_Setting" key of Config_Setting.json, the other keys stay as they are
     bool              Save(void);
                       CMarkerSetting(void);
  };
#endif // CMARKERSETTING_MQH_DECLARATION
#ifndef CMARKERSETTING_MQH_IMPLEMENTATION
#define CMARKERSETTING_MQH_IMPLEMENTATION
 CMarkerSetting::CMarkerSetting(void) : m_buy_color(clrDodgerBlue),m_sell_color(clrCrimson),m_nonrelated_color(clrGray)
  {
  }
 //--- Defaults first, so a missing file or a partial "Markers_Setting" still leaves a working state
 bool CMarkerSetting::OnInitEvent(void)
  {
   this.m_buy_color       =clrDodgerBlue;
   this.m_sell_color      =clrCrimson;
   this.m_nonrelated_color=clrGray;
   string full_path=this.GetFolderName()+"/Config_Setting.json";
   string content=::JSONConfig_ReadWholeFile(full_path);
   if(content=="")
      return false;
   string sv;
   if(::JSONConfig_StringValue(content,"buy_color",sv))        this.m_buy_color       =this.ColorForLabel(sv,this.m_buy_color);
   if(::JSONConfig_StringValue(content,"sell_color",sv))       this.m_sell_color      =this.ColorForLabel(sv,this.m_sell_color);
   if(::JSONConfig_StringValue(content,"nonrelated_color",sv)) this.m_nonrelated_color=this.ColorForLabel(sv,this.m_nonrelated_color);
   return true;
  }
 // Ready for 
 void CMarkerSetting::GetColorChoices(color &colors[],string &labels[]) const
  {
   color  c[]={clrLime,clrGreen,clrLimeGreen,clrDodgerBlue,clrOrange,clrYellow,clrRed,clrCrimson,clrMagenta,clrGray,clrSilver,clrWhite,clrBlack};
   string l[]={"Lime","Green","LimeGreen","  Blue","Orange","Yellow","Red","Crimson","Magenta","Gray","Silver","White","Black"};
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
 bool CMarkerSetting::Save(void)
  {
   string value;
   this.BuildJsonSection(value);
   string full_path=this.GetFolderName()+"/Config_Setting.json";
   return ::JSONConfig_SaveSection(full_path,"Markers_Setting",value);
  }
 void CMarkerSetting::BuildJsonSection(string &out_json) const
  {
   out_json="{\n"+
            "  \"buy_color\": \""        +this.ColorLabelForValue(this.m_buy_color)+"\",\n"+
            "  \"sell_color\": \""       +this.ColorLabelForValue(this.m_sell_color)+"\",\n"+
            "  \"nonrelated_color\": \"" +this.ColorLabelForValue(this.m_nonrelated_color)+"\"\n"+
            " }";
  }
#endif // CMARKERSETTING_MQH_IMPLEMENTATION
#endif // __MARKERSETTING_MQH__
