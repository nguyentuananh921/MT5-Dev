//+------------------------------------------------------------------+
//|                                          BarInformationManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Single source of truth for the information of a bar (candle      |
//| patterns, momentum candle, swing, BOS, CHoCH): the tables        |
//| Setting_BarInformation (what a type is, and what the user wants  |
//| for it), Setting_BarSetup (the parameters of a type) of the      |
//| database. It makes the tables and fills what a type IS in OnInit,|
//| then reads them once to m_list (Live on RAM); a change is written|
//| to the table at once (Save on DB: Python reads it). V2           |
//| CBarPatternControl without the calculation, Python finds them    |
//+------------------------------------------------------------------+
//--- Change from V3 Collections\Settings\PatternManager.mqh: the rows are read from the two tables (V3: the catalog of Python), CBarInformationSetting keeps the parameters
#ifndef CBARINFORMATIONMANAGER_MQH
#define CBARINFORMATIONMANAGER_MQH
 #include "..\..\Services\DELib\DatabaseDELib.mqh"
 #include "..\..\Entities\Defines\BarDefines.mqh"
 #include "..\..\Entities\Defines\EventDefines.mqh"
 #include "..\..\Entities\Bases\BaseObj.mqh"
 #include "..\..\Entities\Settings\BarInformationSetting.mqh"
 #include "..\ListObj.mqh"
#ifndef CBARINFORMATIONMANAGER_MQH_DECLARATION
#define CBARINFORMATIONMANAGER_MQH_DECLARATION
 struct SBarInforCatalogItem
  {
   ENUM_BAR_INFOR_TYPE   type_infor;
   string                name;             // the name Python and the user call it
   ENUM_BAR_INFORMATION_GROUP   group_infor;
   int                   candles;          // how many candles make it
   bool                  have_buy_signal;  // it can be Bullish
   bool                  have_sell_signal; // it can be Bearish
  };

 struct SBarSetupCatalogItem
  {
   ENUM_BAR_INFOR_TYPE   type_infor;
   string                param;
   double                value;            // the default, given once to a parameter that is new
  };

 class CBarInformationManager : public CBaseObj
  {
    private:
     int                m_db;                 // the open database: a change is written here
     CListObj           m_list;               // the types (CBarInformationSetting, each with its parameters), in the order of type_infor
     //Private Method
     bool               Open(void);
     bool               MakeInformation(void);
     void               DropColumn(const string table, const string column);   // a column the table of an older EA has and the code does not know any more
     bool               MakeSetup(void);
     bool               SyncDataFromDB(void);
     bool               ChangeFlag(const ENUM_BAR_INFOR_TYPE type, const string column, const bool on);
   //--- What every type and every parameter IS: the catalog the tables are filled from in OnInit
     void               Catalog(SBarInforCatalogItem &out[]) const;
     void               SetupCatalog(SBarSetupCatalogItem &out[]) const;
     string             ParamDisplay(const string param) const;
    public:
                        CBarInformationManager(void) : m_db(INVALID_HANDLE) { this.m_list.Type(OBJECT_DE_TYPE_BAR_INFORMATION_SETTING); }
   //--- The index of a type in m_list (WRONG_VALUE: none), the type itself (NULL: none)
     int                IndexSetting(const ENUM_BAR_INFOR_TYPE type) const;
     CBarInformationSetting *GetSetting(const ENUM_BAR_INFOR_TYPE type) const;
                       ~CBarInformationManager(void) { if(m_db != INVALID_HANDLE) ::DatabaseClose(m_db); }
   //--- Lifecycle - same convention as the other managers: opens the database, makes the tables when they are not there, fills what every type is
     bool               OnInitEvent(void);
   //--- The text of a group: the caption of its section in the Candle tab
     string             GroupDescription(const ENUM_BAR_INFORMATION_GROUP group) const;
   //--- The group of a type, of the table (the one source of the group: CBar keeps it in RAM only, BAR_PROP_INFOR_GROUP)
     ENUM_BAR_INFORMATION_GROUP Group(const ENUM_BAR_INFOR_TYPE type) const;
   //--- The types (m_list), in the order of type_infor: what a type is (name, group, candles, the sides it can have) and what the user wants for it
     int                Informations(ENUM_BAR_INFOR_TYPE &types[], string &names[], ENUM_BAR_INFORMATION_GROUP &groups[], int &candles[], bool &have_buy[], bool &have_sell[],
                                     bool &sound[], bool &message[], bool &show_buy[], bool &show_sell[]) const;
   //--- The flags of a type: written at once, only for a side (or an alert) the type has. Show Buy / Show Sell tell the listeners
     bool               SoundAlert(const ENUM_BAR_INFOR_TYPE type, const bool on)   { return this.ChangeFlag(type, "sound_alert", on);   }
     bool               MessageAlert(const ENUM_BAR_INFOR_TYPE type, const bool on) { return this.ChangeFlag(type, "message_alert", on); }
   //--- Show or hide the markers of a side on the chart (the same as Show on chart of an indicator template)
     bool               ShowBuySignal(const ENUM_BAR_INFOR_TYPE type, const bool on)  { return this.ChangeFlag(type, "show_buy_signal", on);   }
     bool               ShowSellSignal(const ENUM_BAR_INFOR_TYPE type, const bool on) { return this.ChangeFlag(type, "show_sell_signal", on); }
   //--- The switch of a group of the tab: ON when the markers of any type of the group are shown. Setting it shows or hides the markers of every type of the group at once
     bool               AnyShow(const ENUM_BAR_INFORMATION_GROUP group) const;
     bool               AnyAlert(const ENUM_BAR_INFORMATION_GROUP group) const;            // the sound or the message alert of any type of the group is on
     bool               AlertGroup(const ENUM_BAR_INFORMATION_GROUP group, const bool on);   // both alerts of every type of the group that has a side
     int                AlertTypes(long &types[], string &names[], bool &sound[], bool &message[]) const;   // the types that have a sound or a message alert on: type_infor, name and the two flags of each. Returns how many
     int                ShownTypes(long &buy_types[], long &sell_types[]) const;   // the types whose Buy (Sell) markers are shown on the chart, and that have the side: type_infor of each. Returns how many types there are
     bool               ShowGroup(const ENUM_BAR_INFORMATION_GROUP group, const bool on);
   //--- The parameters of a type (Setting_BarSetup), in the order of the catalog: written at once, only for a parameter the type has
     int                Params(const ENUM_BAR_INFOR_TYPE type, string &params[], string &displays[], double &values[]) const;
     bool               ParamValue(const ENUM_BAR_INFOR_TYPE type, const string param, double &value) const;
     bool               Param(const ENUM_BAR_INFOR_TYPE type, const string param, const double value);
  };
#endif // CBARINFORMATIONMANAGER_MQH_DECLARATION

#ifndef CBARINFORMATIONMANAGER_MQH_IMPLEMENTATION
#define CBARINFORMATIONMANAGER_MQH_IMPLEMENTATION

 //+------------------------------------------------------------------+
 //| The catalog: the text of a group, then what each type and each    |
 //| parameter IS (the order of the enum)                              |
 //+------------------------------------------------------------------+
 string CBarInformationManager::GroupDescription(const ENUM_BAR_INFORMATION_GROUP group) const
  {
   switch(group)
    {
     case BAR_INFORMATION_JAPANESE_CANDLE: return "Candle patterns";
     case BAR_INFORMATION_PRICE_ACTION_CANDLE: return "Price Action";
     case BAR_INFORMATION_SMART_MONEY:         return "Smart Money";
     case BAR_INFORMATION_SIGNAL:              return "Indicator signals";
     default:                return "Other";
    }
  }
 //+------------------------------------------------------------------+
 //| The group of a type, of the table (m_list)                        |
 //+------------------------------------------------------------------+
 ENUM_BAR_INFORMATION_GROUP CBarInformationManager::Group(const ENUM_BAR_INFOR_TYPE type) const
  {
   CBarInformationSetting *row = this.GetSetting(type);
   return (row != NULL ? row.Group() : BAR_INFORMATION_SMART_MONEY);
  }
 void CBarInformationManager::Catalog(SBarInforCatalogItem &out[]) const
  {
   SBarInforCatalogItem catalog[] =
     {
      // --- Candles
        {BAR_INFOR_TYPE_HAMMER,               "Hammer",               BAR_INFORMATION_JAPANESE_CANDLE, 1, true,  false},
        {BAR_INFOR_TYPE_HANGING_MAN,          "Hanging Man",          BAR_INFORMATION_JAPANESE_CANDLE, 1, false, true },
        {BAR_INFOR_TYPE_INVERTED_HAMMER,      "Inverted Hammer",      BAR_INFORMATION_JAPANESE_CANDLE, 1, true,  false},
        {BAR_INFOR_TYPE_SHOOTING_STAR,        "Shooting Star",        BAR_INFORMATION_JAPANESE_CANDLE, 1, false, true },
        {BAR_INFOR_TYPE_DOJI,                 "Doji",                 BAR_INFORMATION_JAPANESE_CANDLE, 1, true,  true },
        {BAR_INFOR_TYPE_DRAGONFLY_DOJI,       "Dragonfly doji",       BAR_INFORMATION_JAPANESE_CANDLE, 1, true,  false},
        {BAR_INFOR_TYPE_GRAVESTONE_DOJI,      "Gravestone Doji",      BAR_INFORMATION_JAPANESE_CANDLE, 1, false, true },
        {BAR_INFOR_TYPE_SPINNING_TOP,         "Spinning Top",         BAR_INFORMATION_JAPANESE_CANDLE, 1, true,  true },
        {BAR_INFOR_TYPE_MARUBOZU,             "Marubozu",             BAR_INFORMATION_JAPANESE_CANDLE, 1, true,  true },
        {BAR_INFOR_TYPE_HARAMI,               "Harami",               BAR_INFORMATION_JAPANESE_CANDLE, 2, true,  true },
        {BAR_INFOR_TYPE_HARAMI_CROSS,         "Harami Cross",         BAR_INFORMATION_JAPANESE_CANDLE, 2, true,  true },
        {BAR_INFOR_TYPE_ENGULFING,            "Engulfing",            BAR_INFORMATION_JAPANESE_CANDLE, 2, true,  true },
        {BAR_INFOR_TYPE_TWEEZER,              "Tweezer",              BAR_INFORMATION_JAPANESE_CANDLE, 2, true,  true },
        {BAR_INFOR_TYPE_PIERCING_PATTERN,     "Piercing pattern",     BAR_INFORMATION_JAPANESE_CANDLE, 2, true,  false},
        {BAR_INFOR_TYPE_DARK_CLOUD_COVER,     "Dark Cloud Cover",     BAR_INFORMATION_JAPANESE_CANDLE, 2, false, true },
        {BAR_INFOR_TYPE_MORNING_STAR,         "Morning Star",         BAR_INFORMATION_JAPANESE_CANDLE, 3, true,  false},
        {BAR_INFOR_TYPE_MORNING_DOJI_STAR,    "Morning Doji Star",    BAR_INFORMATION_JAPANESE_CANDLE, 3, true,  false},
        {BAR_INFOR_TYPE_EVENING_STAR,         "Evening Star",         BAR_INFORMATION_JAPANESE_CANDLE, 3, false, true },
        {BAR_INFOR_TYPE_EVENING_DOJI_STAR,    "Evening Doji Star",    BAR_INFORMATION_JAPANESE_CANDLE, 3, false, true },
        {BAR_INFOR_TYPE_ABANDONED_BABY,       "Abandoned baby",       BAR_INFORMATION_JAPANESE_CANDLE, 3, true,  true },
        {BAR_INFOR_TYPE_THREE_WHITE_SOLDIERS, "Three White Soldiers", BAR_INFORMATION_JAPANESE_CANDLE, 3, true,  false},
        {BAR_INFOR_TYPE_THREE_BLACK_CROWS,    "Three Black Crows",    BAR_INFORMATION_JAPANESE_CANDLE, 3, false, true },
        {BAR_INFOR_TYPE_THREE_INSIDE_UP,      "Three Inside Up",      BAR_INFORMATION_JAPANESE_CANDLE, 3, true,  false},
        {BAR_INFOR_TYPE_THREE_INSIDE_DOWN,    "Three Inside Down",    BAR_INFORMATION_JAPANESE_CANDLE, 3, false, true },
        {BAR_INFOR_TYPE_THREE_STARS,          "Three stars",          BAR_INFORMATION_JAPANESE_CANDLE, 3, true,  true },
      // --- Price Action
        {BAR_INFOR_TYPE_PIN_BAR,              "Pin Bar",              BAR_INFORMATION_PRICE_ACTION_CANDLE, 1, true,  true },
        {BAR_INFOR_TYPE_RAILS,                "Rails",                BAR_INFORMATION_PRICE_ACTION_CANDLE, 2, true,  true },
        {BAR_INFOR_TYPE_OUTSIDE_BAR,          "Outside Bar",          BAR_INFORMATION_PRICE_ACTION_CANDLE, 2, true,  true },
        {BAR_INFOR_TYPE_INSIDE_BAR,           "Inside Bar",           BAR_INFORMATION_PRICE_ACTION_CANDLE, 2, true,  true },
        {BAR_INFOR_TYPE_PIVOT_POINT_REVERSAL, "Pivot Point Reversal", BAR_INFORMATION_PRICE_ACTION_CANDLE, 3, true,  true },
      // --- Smart Money
        {BAR_INFOR_TYPE_MOMENTUM_CANDLE,      "Momentum Candle",      BAR_INFORMATION_SMART_MONEY, 1, true,  true },
        {BAR_INFOR_TYPE_SWING_HIGH,           "Swing High",           BAR_INFORMATION_SMART_MONEY, 1, false, true },
        {BAR_INFOR_TYPE_SWING_LOW,            "Swing Low",            BAR_INFORMATION_SMART_MONEY, 1, true,  false},
        {BAR_INFOR_TYPE_BOS,                  "BOS",                  BAR_INFORMATION_SMART_MONEY, 1, true,  true },
        {BAR_INFOR_TYPE_CHOCH,                "CHoCH",                BAR_INFORMATION_SMART_MONEY, 1, true,  true },
     };
   int total = ArraySize(catalog);
   ArrayResize(out, total);
   for(int i = 0; i < total; i++)
      out[i] = catalog[i];
  }
 string CBarInformationManager::ParamDisplay(const string param) const
  {
   if(param == BAR_PARAM_BODY_MAX)           return "Body max %";
   if(param == BAR_PARAM_BODY_MIN)           return "Body min %";
   if(param == BAR_PARAM_LOWER_SHADOW_MIN)   return "Lower shadow min %";
   if(param == BAR_PARAM_LOWER_SHADOW_MAX)   return "Lower shadow max %";
   if(param == BAR_PARAM_UPPER_SHADOW_MIN)   return "Upper shadow min %";
   if(param == BAR_PARAM_UPPER_SHADOW_MAX)   return "Upper shadow max %";
   if(param == BAR_PARAM_SHADOW_MIN_EACH)    return "Each shadow min %";
   if(param == BAR_PARAM_MOTHER_BODY_MIN)    return "Mother body min %";
   if(param == BAR_PARAM_INNER_BODY_MAX)     return "Inner body max %";
   if(param == BAR_PARAM_TOLERANCE_POINTS)   return "Tolerance (points)";
   if(param == BAR_PARAM_PENETRATION_MIN)    return "Penetration min %";
   if(param == BAR_PARAM_FIRST_BODY_MIN)     return "First body min %";
   if(param == BAR_PARAM_MIDDLE_BODY_MAX)    return "Middle body max %";
   if(param == BAR_PARAM_OUTER_BODY_MIN)     return "Outer body min %";
   if(param == BAR_PARAM_SECOND_BODY_MAX)    return "Second body max %";
   if(param == BAR_PARAM_DOJI_BODY_MAX)      return "Doji body max %";
   if(param == BAR_PARAM_SIMILARITY_MIN)     return "Similarity min %";
   if(param == BAR_PARAM_LARGER_SHADOW_MIN)  return "Larger shadow min %";
   if(param == BAR_PARAM_SMALLER_SHADOW_MAX) return "Smaller shadow max %";
   if(param == BAR_PARAM_CANDLES_RATIO)      return "Candles ratio %";
   if(param == BAR_PARAM_BODY_RATIO)         return "Body ratio %";
   if(param == BAR_PARAM_PROTRUDE_MIN)       return "Protrude min %";
   if(param == BAR_PARAM_BODY_MULTIPLIER)    return "Multiplier";
   if(param == BAR_PARAM_BARS_BEFORE)        return "Bars before";
   if(param == BAR_PARAM_SWING_STRENGTH)     return "Strength";
   if(param == BAR_PARAM_PRICE_BASIS)        return "Price basis";
   return param;
  }

 void CBarInformationManager::SetupCatalog(SBarSetupCatalogItem &out[]) const
  {
   SBarSetupCatalogItem catalog[] =
     {
      // --- Candles
        {BAR_INFOR_TYPE_HAMMER, BAR_PARAM_BODY_MAX, PATTERN_DEF_SMALL_BODY},
        {BAR_INFOR_TYPE_HAMMER, BAR_PARAM_LOWER_SHADOW_MIN, PATTERN_DEF_LONG_SHADOW},
        {BAR_INFOR_TYPE_HAMMER, BAR_PARAM_UPPER_SHADOW_MAX, PATTERN_DEF_SHORT_SHADOW},
        {BAR_INFOR_TYPE_HANGING_MAN, BAR_PARAM_BODY_MAX, PATTERN_DEF_SMALL_BODY},
        {BAR_INFOR_TYPE_HANGING_MAN, BAR_PARAM_LOWER_SHADOW_MIN, PATTERN_DEF_LONG_SHADOW},
        {BAR_INFOR_TYPE_HANGING_MAN, BAR_PARAM_UPPER_SHADOW_MAX, PATTERN_DEF_SHORT_SHADOW},
        {BAR_INFOR_TYPE_INVERTED_HAMMER, BAR_PARAM_BODY_MAX, PATTERN_DEF_SMALL_BODY},
        {BAR_INFOR_TYPE_INVERTED_HAMMER, BAR_PARAM_UPPER_SHADOW_MIN, PATTERN_DEF_LONG_SHADOW},
        {BAR_INFOR_TYPE_INVERTED_HAMMER, BAR_PARAM_LOWER_SHADOW_MAX, PATTERN_DEF_SHORT_SHADOW},
        {BAR_INFOR_TYPE_SHOOTING_STAR, BAR_PARAM_BODY_MAX, PATTERN_DEF_SMALL_BODY},
        {BAR_INFOR_TYPE_SHOOTING_STAR, BAR_PARAM_UPPER_SHADOW_MIN, PATTERN_DEF_LONG_SHADOW},
        {BAR_INFOR_TYPE_SHOOTING_STAR, BAR_PARAM_LOWER_SHADOW_MAX, PATTERN_DEF_SHORT_SHADOW},
        {BAR_INFOR_TYPE_DOJI, BAR_PARAM_BODY_MAX, PATTERN_DEF_DOJI_BODY},
        {BAR_INFOR_TYPE_DRAGONFLY_DOJI, BAR_PARAM_BODY_MAX, PATTERN_DEF_DOJI_BODY},
        {BAR_INFOR_TYPE_DRAGONFLY_DOJI, BAR_PARAM_LOWER_SHADOW_MIN, PATTERN_DEF_DEEP_SHADOW},
        {BAR_INFOR_TYPE_DRAGONFLY_DOJI, BAR_PARAM_UPPER_SHADOW_MAX, PATTERN_DEF_DOJI_BODY},
        {BAR_INFOR_TYPE_GRAVESTONE_DOJI, BAR_PARAM_BODY_MAX, PATTERN_DEF_DOJI_BODY},
        {BAR_INFOR_TYPE_GRAVESTONE_DOJI, BAR_PARAM_UPPER_SHADOW_MIN, PATTERN_DEF_DEEP_SHADOW},
        {BAR_INFOR_TYPE_GRAVESTONE_DOJI, BAR_PARAM_LOWER_SHADOW_MAX, PATTERN_DEF_DOJI_BODY},
        {BAR_INFOR_TYPE_SPINNING_TOP, BAR_PARAM_BODY_MAX, PATTERN_DEF_SMALL_BODY},
        {BAR_INFOR_TYPE_SPINNING_TOP, BAR_PARAM_SHADOW_MIN_EACH, PATTERN_DEF_SPINNING_TOP_SHADOW},
        {BAR_INFOR_TYPE_MARUBOZU, BAR_PARAM_BODY_MIN, PATTERN_DEF_MARUBOZU_BODY},
        {BAR_INFOR_TYPE_HARAMI, BAR_PARAM_MOTHER_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_HARAMI, BAR_PARAM_INNER_BODY_MAX, PATTERN_DEF_INNER_BODY},
        {BAR_INFOR_TYPE_HARAMI_CROSS, BAR_PARAM_MOTHER_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_HARAMI_CROSS, BAR_PARAM_INNER_BODY_MAX, PATTERN_DEF_DOJI_BODY},
        {BAR_INFOR_TYPE_ENGULFING, BAR_PARAM_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_TWEEZER, BAR_PARAM_TOLERANCE_POINTS, PATTERN_DEF_TWEEZER_PTS},
        {BAR_INFOR_TYPE_PIERCING_PATTERN, BAR_PARAM_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_PIERCING_PATTERN, BAR_PARAM_PENETRATION_MIN, PATTERN_DEF_PENETRATION},
        {BAR_INFOR_TYPE_DARK_CLOUD_COVER, BAR_PARAM_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_DARK_CLOUD_COVER, BAR_PARAM_PENETRATION_MIN, PATTERN_DEF_PENETRATION},
        {BAR_INFOR_TYPE_MORNING_STAR, BAR_PARAM_FIRST_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_MORNING_STAR, BAR_PARAM_MIDDLE_BODY_MAX, PATTERN_DEF_INNER_BODY},
        {BAR_INFOR_TYPE_MORNING_STAR, BAR_PARAM_PENETRATION_MIN, PATTERN_DEF_PENETRATION},
        {BAR_INFOR_TYPE_MORNING_DOJI_STAR, BAR_PARAM_FIRST_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_MORNING_DOJI_STAR, BAR_PARAM_MIDDLE_BODY_MAX, PATTERN_DEF_DOJI_BODY},
        {BAR_INFOR_TYPE_MORNING_DOJI_STAR, BAR_PARAM_PENETRATION_MIN, PATTERN_DEF_PENETRATION},
        {BAR_INFOR_TYPE_EVENING_STAR, BAR_PARAM_FIRST_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_EVENING_STAR, BAR_PARAM_MIDDLE_BODY_MAX, PATTERN_DEF_INNER_BODY},
        {BAR_INFOR_TYPE_EVENING_STAR, BAR_PARAM_PENETRATION_MIN, PATTERN_DEF_PENETRATION},
        {BAR_INFOR_TYPE_EVENING_DOJI_STAR, BAR_PARAM_FIRST_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_EVENING_DOJI_STAR, BAR_PARAM_MIDDLE_BODY_MAX, PATTERN_DEF_DOJI_BODY},
        {BAR_INFOR_TYPE_EVENING_DOJI_STAR, BAR_PARAM_PENETRATION_MIN, PATTERN_DEF_PENETRATION},
        {BAR_INFOR_TYPE_ABANDONED_BABY, BAR_PARAM_OUTER_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_ABANDONED_BABY, BAR_PARAM_MIDDLE_BODY_MAX, PATTERN_DEF_DOJI_BODY},
        {BAR_INFOR_TYPE_THREE_WHITE_SOLDIERS, BAR_PARAM_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_THREE_BLACK_CROWS, BAR_PARAM_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_THREE_INSIDE_UP, BAR_PARAM_FIRST_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_THREE_INSIDE_UP, BAR_PARAM_SECOND_BODY_MAX, PATTERN_DEF_INNER_BODY},
        {BAR_INFOR_TYPE_THREE_INSIDE_DOWN, BAR_PARAM_FIRST_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_THREE_INSIDE_DOWN, BAR_PARAM_SECOND_BODY_MAX, PATTERN_DEF_INNER_BODY},
        {BAR_INFOR_TYPE_THREE_STARS, BAR_PARAM_DOJI_BODY_MAX, PATTERN_DEF_THREE_STARS_DOJI_BODY},
      // --- Price Action
        {BAR_INFOR_TYPE_PIN_BAR, BAR_PARAM_BODY_MAX, PATTERN_DEF_PINBAR_RATIO_BODY},
        {BAR_INFOR_TYPE_PIN_BAR, BAR_PARAM_LARGER_SHADOW_MIN, PATTERN_DEF_PINBAR_LARGER_SHADOW},
        {BAR_INFOR_TYPE_PIN_BAR, BAR_PARAM_SMALLER_SHADOW_MAX, PATTERN_DEF_PINBAR_SMALLER_SHADOW},
        {BAR_INFOR_TYPE_RAILS, BAR_PARAM_BODY_MIN, PATTERN_DEF_LARGE_BODY},
        {BAR_INFOR_TYPE_RAILS, BAR_PARAM_SIMILARITY_MIN, PATTERN_DEF_SIMILARITY},
        {BAR_INFOR_TYPE_OUTSIDE_BAR, BAR_PARAM_CANDLES_RATIO, PATTERN_DEF_OUTSIDE_BAR_RATIO_CANDLES},
        {BAR_INFOR_TYPE_OUTSIDE_BAR, BAR_PARAM_BODY_RATIO, PATTERN_DEF_OUTSIDE_BAR_RATIO_BODY},
        {BAR_INFOR_TYPE_PIVOT_POINT_REVERSAL, BAR_PARAM_PROTRUDE_MIN, PATTERN_DEF_PPR_RATIO_CANDLE_SIZE},
      // --- Smart Money
        {BAR_INFOR_TYPE_MOMENTUM_CANDLE,      BAR_PARAM_BODY_MULTIPLIER,    MOMENTUM_DEF_MULTIPLIER},
        {BAR_INFOR_TYPE_MOMENTUM_CANDLE,      BAR_PARAM_BARS_BEFORE,        MOMENTUM_DEF_BARS},
        {BAR_INFOR_TYPE_SWING_HIGH,           BAR_PARAM_SWING_STRENGTH,     SWING_DEF_STRENGTH},
        {BAR_INFOR_TYPE_SWING_HIGH,           BAR_PARAM_PRICE_BASIS,        SWING_DEF_PRICE_BASIS},
        {BAR_INFOR_TYPE_SWING_LOW,            BAR_PARAM_SWING_STRENGTH,     SWING_DEF_STRENGTH},
        {BAR_INFOR_TYPE_SWING_LOW,            BAR_PARAM_PRICE_BASIS,        SWING_DEF_PRICE_BASIS},
     };
   int total = ArraySize(catalog);
   ArrayResize(out, total);
   for(int i = 0; i < total; i++)
      out[i] = catalog[i];
  }
 //+------------------------------------------------------------------+
 //| Open the database once: it stays open while the EA runs, the      |
 //| tables are made when they are not there                           |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::Open(void)
  {
   m_db = LibDatabase_Open(DATABASE_OPEN_READWRITE);
   if(m_db == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > the database ", LIB_DATABASE_FILE, " is not opened, error ", ::GetLastError());
     return false;
    }
   ::DatabaseExecute(m_db, "PRAGMA busy_timeout=5000");
   this.DropColumn("Setting_BarInformation", "buy_signal");    // not a flag of a type any more: what is shown is Show Buy / Show Sell
   this.DropColumn("Setting_BarInformation", "sell_signal");
   if(!this.MakeInformation())
      return false;
   //--- One row = one parameter of a type (the thresholds of a pattern, the strength of a swing...)
   if(!::DatabaseExecute(m_db, "CREATE TABLE IF NOT EXISTS Setting_BarSetup (type_infor INTEGER NOT NULL REFERENCES Setting_BarInformation (type_infor), param TEXT NOT NULL, "
                               "value REAL NOT NULL, display TEXT NOT NULL DEFAULT '', PRIMARY KEY (type_infor, param))"))
    {
     ::Print(__FUNCTION__, " > the table Setting_BarSetup is not made, error ", ::GetLastError());
     return false;
    }
   //--- A database made before the display column has not it yet
   if(!LibDatabase_ColumnExists(m_db, "Setting_BarSetup", "display") && !::DatabaseExecute(m_db, "ALTER TABLE Setting_BarSetup ADD COLUMN display TEXT NOT NULL DEFAULT ''"))
    {
     ::Print(__FUNCTION__, " > the column display is not added, error ", ::GetLastError());
     return false;
    }
   if(!this.MakeSetup())
      return false;
   if(!this.SyncDataFromDB())
      return false;
   ::Print("Complete ", __FUNCTION__, " > ", LIB_DATABASE_FILE, " opened");
   return true;
  }
 //+------------------------------------------------------------------+
 //| The column of an older table goes (nothing happens when there is |
 //| none, or the table is not there yet)                             |
 //+------------------------------------------------------------------+
 void CBarInformationManager::DropColumn(const string table, const string column)
  {
   int request = LibDatabase_Prepare(m_db, "SELECT COUNT(*) FROM pragma_table_info('" + table + "') WHERE name = '" + column + "'");
   if(request == INVALID_HANDLE)
      return;
   long found = 0;
   if(::DatabaseRead(request))
      ::DatabaseColumnLong(request, 0, found);
   ::DatabaseFinalize(request);
   if(found != 0 && !::DatabaseExecute(m_db, "ALTER TABLE " + table + " DROP COLUMN " + column))
      ::Print(__FUNCTION__, " > the column ", column, " of ", table, " is not dropped, error ", ::GetLastError());
  }
 //+------------------------------------------------------------------+
 //| One row = one kind of information of a bar. What a type IS (name, |
 //| group, candles, the sides it can have) is written at every start; |
 //| what the user wants is only given to a type that is new: Show Buy |
 //| and Show Sell are on for a side the type has, never changed after |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::MakeInformation(void)
  {
   if(!::DatabaseExecute(m_db, "CREATE TABLE IF NOT EXISTS Setting_BarInformation (type_infor INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL UNIQUE, group_infor INTEGER NOT NULL, "
                               "candles INTEGER NOT NULL, have_buy_signal INTEGER NOT NULL, have_sell_signal INTEGER NOT NULL, "
                               "sound_alert INTEGER NOT NULL DEFAULT 1, message_alert INTEGER NOT NULL DEFAULT 1, "
                               "show_buy_signal INTEGER NOT NULL DEFAULT 1, show_sell_signal INTEGER NOT NULL DEFAULT 1)"))
    {
     ::Print(__FUNCTION__, " > the table Setting_BarInformation is not made, error ", ::GetLastError());
     return false;
    }
   SBarInforCatalogItem catalog[];
   this.Catalog(catalog);
   string in_catalog = "";
   for(int i = 0; i < ::ArraySize(catalog); i++)
      in_catalog += (i > 0 ? ", " : "") + (string)(int)catalog[i].type_infor;
   //--- A type the catalog has not any more goes from the table (Sync Everywhere): its parameters first (Setting_BarSetup REFERENCES it, the keys are checked)
   if(LibDatabase_TableExists(m_db, "Setting_BarSetup") && !::DatabaseExecute(m_db, "DELETE FROM Setting_BarSetup WHERE type_infor NOT IN (" + in_catalog + ")"))
      ::Print(__FUNCTION__, " > the parameters of the types out of the catalog are not deleted, error ", ::GetLastError());
   if(!::DatabaseExecute(m_db, "DELETE FROM Setting_BarInformation WHERE type_infor NOT IN (" + in_catalog + ")"))
      ::Print(__FUNCTION__, " > the types out of the catalog are not deleted, error ", ::GetLastError());
   for(int i = 0; i < ::ArraySize(catalog); i++)
    {
     string have_buy  = (catalog[i].have_buy_signal  ? "1" : "0");
     string have_sell = (catalog[i].have_sell_signal ? "1" : "0");
     if(!::DatabaseExecute(m_db, "INSERT INTO Setting_BarInformation (type_infor, name, group_infor, candles, have_buy_signal, have_sell_signal, show_buy_signal, show_sell_signal) VALUES (" +
                                 (string)(int)catalog[i].type_infor + ", '" + LibDatabase_Quoted(catalog[i].name) + "', " + (string)(int)catalog[i].group_infor + ", " +
                                 (string)catalog[i].candles + ", " + have_buy + ", " + have_sell + ", " + have_buy + ", " + have_sell + ") " +
                                 "ON CONFLICT(type_infor) DO UPDATE SET name = excluded.name, group_infor = excluded.group_infor, candles = excluded.candles, " +
                                 "have_buy_signal = excluded.have_buy_signal, have_sell_signal = excluded.have_sell_signal"))
      {
       ::Print(__FUNCTION__, " > ", catalog[i].name, " not written, error ", ::GetLastError());
       return false;
      }
    }
   return true;
  }
 //+------------------------------------------------------------------+
 //| The parameters of the catalog: a parameter that is new gets its   |
 //| default, the value the user set is never changed (the display is  |
 //| written at every start)                                           |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::MakeSetup(void)
  {
   SBarSetupCatalogItem catalog[];
   this.SetupCatalog(catalog);
   string in_catalog = "";
   for(int i = 0; i < ::ArraySize(catalog); i++)
      in_catalog += (i > 0 ? " OR " : "") + "(type_infor = " + (string)(int)catalog[i].type_infor + " AND param = '" + LibDatabase_Quoted(catalog[i].param) + "')";
   //--- A parameter the catalog has not any more goes from the table (Sync Everywhere)
   if(!::DatabaseExecute(m_db, "DELETE FROM Setting_BarSetup WHERE NOT (" + in_catalog + ")"))
      ::Print(__FUNCTION__, " > the parameters out of the catalog are not deleted, error ", ::GetLastError());
   for(int i = 0; i < ::ArraySize(catalog); i++)
    {
     if(!::DatabaseExecute(m_db, "INSERT INTO Setting_BarSetup (type_infor, param, value, display) VALUES (" + (string)(int)catalog[i].type_infor + ", '" +
                                 LibDatabase_Quoted(catalog[i].param) + "', " + ::DoubleToString(catalog[i].value, 8) + ", '" + LibDatabase_Quoted(this.ParamDisplay(catalog[i].param)) + "') " +
                                 "ON CONFLICT(type_infor, param) DO UPDATE SET display = excluded.display"))
      {
       ::Print(__FUNCTION__, " > ", catalog[i].param, " not written, error ", ::GetLastError());
       return false;
      }
    }
   return true;
  }
 //+------------------------------------------------------------------+
 //| The two tables to m_list: a type for each row of                 |
 //| Setting_BarInformation, its parameters from Setting_BarSetup.    |
 //| Once: the tables are not asked again                              |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::SyncDataFromDB(void)
  {
   this.m_list.Clear();
   if(m_db == INVALID_HANDLE)
      return false;
   int request = LibDatabase_Prepare(m_db, "SELECT type_infor, name, group_infor, candles, have_buy_signal, have_sell_signal, sound_alert, message_alert, "
                                           "show_buy_signal, show_sell_signal FROM Setting_BarInformation ORDER BY type_infor");
   if(request == INVALID_HANDLE)
    {
     ::Print(__FUNCTION__, " > the query is not accepted, error ", ::GetLastError());
     return false;
    }
   while(::DatabaseRead(request))
    {
     long type, group, count, hb, hs, so, m, sb, ss;
     string name;
     ::DatabaseColumnLong(request, 0, type);
     ::DatabaseColumnText(request, 1, name);
     ::DatabaseColumnLong(request, 2, group);
     ::DatabaseColumnLong(request, 3, count);
     ::DatabaseColumnLong(request, 4, hb);
     ::DatabaseColumnLong(request, 5, hs);
     ::DatabaseColumnLong(request, 6, so);
     ::DatabaseColumnLong(request, 7, m);
     ::DatabaseColumnLong(request, 8, sb);
     ::DatabaseColumnLong(request, 9, ss);
     CBarInformationSetting *row = new CBarInformationSetting((ENUM_BAR_INFOR_TYPE)(int)type, name, (ENUM_BAR_INFORMATION_GROUP)(int)group, (int)count, hb != 0, hs != 0);
     if(row == NULL)
        continue;
     row.SoundAlert(so != 0);
     row.MessageAlert(m != 0);
     row.ShowBuy(sb != 0, false);
     row.ShowSell(ss != 0, false);
     if(!this.m_list.Add(row))
        delete row;
    }
   ::DatabaseFinalize(request);
   int params = 0;
   request = LibDatabase_Prepare(m_db, "SELECT type_infor, param, display, value FROM Setting_BarSetup ORDER BY rowid");
   if(request != INVALID_HANDLE)
    {
     while(::DatabaseRead(request))
      {
       long type;
       string param, display;
       double value;
       ::DatabaseColumnLong(request, 0, type);
       ::DatabaseColumnText(request, 1, param);
       ::DatabaseColumnText(request, 2, display);
       ::DatabaseColumnDouble(request, 3, value);
       CBarInformationSetting *row = this.GetSetting((ENUM_BAR_INFOR_TYPE)(int)type);
       if(row == NULL)
          continue;
       row.AddParam(param, display, value);
       params++;
      }
     ::DatabaseFinalize(request);
    }
   ::Print("Complete ", __FUNCTION__, " > ", this.m_list.Total(), " types of Setting_BarInformation and ", params, " parameters of Setting_BarSetup read to RAM");
   return true;
  }
 int CBarInformationManager::IndexSetting(const ENUM_BAR_INFOR_TYPE type) const
  {
   for(int i = 0; i < this.m_list.Total(); i++)
    {
     CBarInformationSetting *row = this.m_list.At(i);
     if(row != NULL && row.TypeInfor() == type)
        return i;
    }
   return WRONG_VALUE;
  }
 CBarInformationSetting *CBarInformationManager::GetSetting(const ENUM_BAR_INFOR_TYPE type) const
  {
   int index = this.IndexSetting(type);
   return (index > WRONG_VALUE ? this.m_list.At(index) : NULL);
  }
 //+------------------------------------------------------------------+
 //| The parameters of a type, in the order they were given            |
 //+------------------------------------------------------------------+
 int CBarInformationManager::Params(const ENUM_BAR_INFOR_TYPE type, string &params[], string &displays[], double &values[]) const
  {
   CBarInformationSetting *row = this.GetSetting(type);
   if(row == NULL)
    {
     ::ArrayResize(params, 0);
     ::ArrayResize(displays, 0);
     ::ArrayResize(values, 0);
     return 0;
    }
   return row.Params(params, displays, values);
  }
 bool CBarInformationManager::ParamValue(const ENUM_BAR_INFOR_TYPE type, const string param, double &value) const
  {
   CBarInformationSetting *row = this.GetSetting(type);
   return (row != NULL && row.ParamValue(param, value));
  }
 //--- A parameter: its row at once, then the type in m_list, whose setter tells the listeners (BAR_INFORMATION_MANAGER_EVENT_SETUP_CHANGED)
 bool CBarInformationManager::Param(const ENUM_BAR_INFOR_TYPE type, const string param, const double value)
  {
   CBarInformationSetting *row = this.GetSetting(type);
   double old = 0;
   if(m_db == INVALID_HANDLE || row == NULL || !row.ParamValue(param, old))
      return false;
   if(old == value)
      return true;
   if(!::DatabaseExecute(m_db, "UPDATE Setting_BarSetup SET value = " + ::DoubleToString(value, 8) + " WHERE type_infor = " + (string)(int)type + " AND param = '" + LibDatabase_Quoted(param) + "'"))
      return false;
   return row.ParamValue(param, value);
  }
 //+------------------------------------------------------------------+
 //| The types, in the order of type_infor                             |
 //+------------------------------------------------------------------+
 int CBarInformationManager::Informations(ENUM_BAR_INFOR_TYPE &types[], string &names[], ENUM_BAR_INFORMATION_GROUP &groups[], int &candles[], bool &have_buy[], bool &have_sell[],
                                          bool &sound[], bool &message[], bool &show_buy[], bool &show_sell[]) const
  {
   int total = this.m_list.Total();
   ::ArrayResize(types, total);
   ::ArrayResize(names, total);
   ::ArrayResize(groups, total);
   ::ArrayResize(candles, total);
   ::ArrayResize(have_buy, total);
   ::ArrayResize(have_sell, total);
   ::ArrayResize(sound, total);
   ::ArrayResize(message, total);
   ::ArrayResize(show_buy, total);
   ::ArrayResize(show_sell, total);
   for(int i = 0; i < total; i++)
    {
     CBarInformationSetting *row = this.m_list.At(i);
     types[i]     = row.TypeInfor();
     names[i]     = row.Name();
     groups[i]    = row.Group();
     candles[i]   = row.Candles();
     have_buy[i]  = row.HasBuy();
     have_sell[i] = row.HasSell();
     sound[i]     = row.SoundAlert();
     message[i]   = row.MessageAlert();
     show_buy[i]  = row.ShowBuy();
     show_sell[i] = row.ShowSell();
    }
   return total;
  }
 //+------------------------------------------------------------------+
 //| A flag of a type, only when the type has what the flag is about   |
 //| (a side for the alerts, the side for its Show). False when the    |
 //| type is not there or has not it. The column at once, then the     |
 //| type in m_list: the Show setters tell the listeners               |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::ChangeFlag(const ENUM_BAR_INFOR_TYPE type, const string column, const bool on)
  {
   CBarInformationSetting *row = this.GetSetting(type);
   if(m_db == INVALID_HANDLE || row == NULL)
      return false;
   bool has = (column == "show_buy_signal" ? row.HasBuy() : column == "show_sell_signal" ? row.HasSell() : (row.HasBuy() || row.HasSell()));
   if(!has)
      return false;
   bool value = (column == "show_buy_signal" ? row.ShowBuy() : column == "show_sell_signal" ? row.ShowSell() : column == "sound_alert" ? row.SoundAlert() : row.MessageAlert());
   if(value == on)
      return true;
   if(!::DatabaseExecute(m_db, "UPDATE Setting_BarInformation SET " + column + " = " + (on ? "1" : "0") + " WHERE type_infor = " + (string)(int)type))
      return false;
   if(column == "show_buy_signal")
      row.ShowBuy(on);
   else if(column == "show_sell_signal")
      row.ShowSell(on);
   else if(column == "sound_alert")
      row.SoundAlert(on);
   else
      row.MessageAlert(on);
   return true;
  }
 bool CBarInformationManager::AnyShow(const ENUM_BAR_INFORMATION_GROUP group) const
  {
   for(int i = 0; i < this.m_list.Total(); i++)
    {
     CBarInformationSetting *row = this.m_list.At(i);
     if(row != NULL && row.Group() == group && (row.ShowBuy() || row.ShowSell()))
        return true;
    }
   return false;
  }
 bool CBarInformationManager::AnyAlert(const ENUM_BAR_INFORMATION_GROUP group) const
  {
   for(int i = 0; i < this.m_list.Total(); i++)
    {
     CBarInformationSetting *row = this.m_list.At(i);
     if(row != NULL && row.Group() == group && (row.SoundAlert() || row.MessageAlert()))
        return true;
    }
   return false;
  }
 bool CBarInformationManager::AlertGroup(const ENUM_BAR_INFORMATION_GROUP group, const bool on)
  {
   if(m_db == INVALID_HANDLE)
      return false;
   //--- The switch of the group: every type of it, also one without a side the tab does not list (Inside Bar)
   if(!::DatabaseExecute(m_db, "UPDATE Setting_BarInformation SET sound_alert = " + (on ? "1" : "0") + ", message_alert = " + (on ? "1" : "0") +
                               " WHERE group_infor = " + (string)(int)group))
      return false;
   for(int i = 0; i < this.m_list.Total(); i++)
    {
     CBarInformationSetting *row = this.m_list.At(i);
     if(row == NULL || row.Group() != group)
        continue;
     row.SoundAlert(on);
     row.MessageAlert(on);
    }
   return true;
  }
 //+------------------------------------------------------------------+
 //| The markers of every type of a group at once, for the sides each  |
 //| type has, announced with one event (lparam = WRONG_VALUE:         |
 //| several types, dparam = the group)                                |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::ShowGroup(const ENUM_BAR_INFORMATION_GROUP group, const bool on)
  {
   if(m_db == INVALID_HANDLE)
      return false;
   string flag = (on ? "1" : "0");
   string in_group = "group_infor = " + (string)(int)group;
   //--- The switch of the group: every type of it, also one without a side the tab does not list (Inside Bar)
   if(!::DatabaseExecute(m_db, "UPDATE Setting_BarInformation SET show_buy_signal = " + flag + ", show_sell_signal = " + flag + " WHERE " + in_group))
      return false;
   //--- m_list follows, one event for the group (not one for each type)
   bool changed = false;
   for(int i = 0; i < this.m_list.Total(); i++)
    {
     CBarInformationSetting *row = this.m_list.At(i);
     if(row == NULL || row.Group() != group)
        continue;
     if(row.ShowBuy() != on)
       {
        row.ShowBuy(on, false);
        changed = true;
       }
     if(row.ShowSell() != on)
       {
        row.ShowSell(on, false);
        changed = true;
       }
    }
   if(changed)
      ::EventChartCustom(::ChartID(), (ushort)BAR_INFORMATION_MANAGER_EVENT_SHOW_CHANGED, (long)WRONG_VALUE, (double)(int)group, "");
   return true;
  }
 //+------------------------------------------------------------------+
 //| Lifecycle - same convention as the other managers. EA.mq5 calls   |
 //| this from its own OnInit(). The tables are read once: a           |
 //| CHARTCHANGE reinit keeps the database open and m_list as it is    |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::OnInitEvent(void)
  {
   return (m_db != INVALID_HANDLE) || this.Open();
  }
 //+------------------------------------------------------------------+
 //| The types whose markers are shown on the chart, for each side     |
 //+------------------------------------------------------------------+
 int CBarInformationManager::ShownTypes(long &buy_types[], long &sell_types[]) const
  {
   ::ArrayResize(buy_types, 0);
   ::ArrayResize(sell_types, 0);
   ENUM_BAR_INFOR_TYPE types[];
   string names[];
   ENUM_BAR_INFORMATION_GROUP groups[];
   int candles[];
   bool have_buy[], have_sell[], sound[], message[], show_buy[], show_sell[];
   int total = this.Informations(types, names, groups, candles, have_buy, have_sell, sound, message, show_buy, show_sell);
   for(int i = 0; i < total; i++)
     {
      if(have_buy[i] && show_buy[i])
        {
         ::ArrayResize(buy_types, ::ArraySize(buy_types) + 1);
         buy_types[::ArraySize(buy_types) - 1] = (long)types[i];
        }
      if(have_sell[i] && show_sell[i])
        {
         ::ArrayResize(sell_types, ::ArraySize(sell_types) + 1);
         sell_types[::ArraySize(sell_types) - 1] = (long)types[i];
        }
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| The types that have an alert on                                   |
 //+------------------------------------------------------------------+
 int CBarInformationManager::AlertTypes(long &types[], string &names[], bool &sound[], bool &message[]) const
  {
   ::ArrayResize(types, 0);
   ::ArrayResize(names, 0);
   ::ArrayResize(sound, 0);
   ::ArrayResize(message, 0);
   ENUM_BAR_INFOR_TYPE all_types[];
   string all_names[];
   ENUM_BAR_INFORMATION_GROUP groups[];
   int candles[];
   bool have_buy[], have_sell[], all_sound[], all_message[], show_buy[], show_sell[];
   int total = this.Informations(all_types, all_names, groups, candles, have_buy, have_sell, all_sound, all_message, show_buy, show_sell);
   for(int i = 0; i < total; i++)
     {
      if(!all_sound[i] && !all_message[i])
         continue;
      int n = ::ArraySize(types);
      ::ArrayResize(types, n + 1);
      ::ArrayResize(names, n + 1);
      ::ArrayResize(sound, n + 1);
      ::ArrayResize(message, n + 1);
      types[n] = (long)all_types[i];
      names[n] = all_names[i];
      sound[n] = all_sound[i];
      message[n] = all_message[i];
     }
   return ::ArraySize(types);
  }
#endif // CBARINFORMATIONMANAGER_MQH_IMPLEMENTATION
#endif // CBARINFORMATIONMANAGER_MQH
