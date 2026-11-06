//+------------------------------------------------------------------+
//|                                        BarInformationManager.mqh |
//|                                     Copyright 2026, Anhnt        |
//| Single source of truth for the information of a bar:             |
//|  (candlepatterns, momentum candle, swing, BOS, CHoCH):           |
//| CreCRUD table Setting_BarSetup                                    |
//| CRUD table Setting_BarInformation in the database                |
//| Update in V4: Use CDatabaseService                               |
//+------------------------------------------------------------------+
//--- Change from V3 Collections\Settings\PatternManager.mqh: the rows are read from the two tables (V3: the catalog of Python), CBarInformationSetting keeps the parameters
#ifndef CBARINFORMATIONMANAGER_MQH
#define CBARINFORMATIONMANAGER_MQH
 #include "..\..\Services\DELib\DatabaseService.mqh"
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
 //--- A row of each table, as CDatabaseService::Read binds it (the order of the SELECT)
 struct SBarInformationRow
  {
   long   type_infor;
   string name;
   long   group_infor;
   long   candles;
   long   have_buy_signal;
   long   have_sell_signal;
   long   sound_alert;
   long   message_alert;
   long   show_buy_signal;
   long   show_sell_signal;
  };
 struct SBarSetupRow
  {
   long   type_infor;
   string param;
   string display;
   double value;
  };

 //--- Rows of the tables of the account, as CDatabaseService::Read binds them (the order of the SELECT)
 struct SBarResultRow
  {
   long   type_infor;
   long   bar_time;
   long   signal_direction;
  };
 struct SBarCandleRow
  {
   long   tf_enum;
   long   type_infor;
   long   bar_time;
   long   signal_direction;
  };
 struct SBarNewestRow
  {
   long   bar_time;
  };
 class CBarInformationManager : public CBaseObj
  {
    private:
     CDatabaseService  *m_CDatabaseService;   // The EA holds it
     CListObj           m_list;               // the types (CBarInformationSetting, each with its parameters), in the order of type_infor
     //Private Method
     //--- DB to RAM: once, in OnInitEvent
     bool               ReadDataFromDB(void);
     //--- Save on DB, as it is on RAM: one type, every type of a group, one parameter
     bool               UpdateDataToDB(const ENUM_BAR_INFOR_TYPE type);
     bool               UpdateDataToDB(const ENUM_BAR_INFORMATION_GROUP group);
     bool               UpdateDataToDB(const ENUM_BAR_INFOR_TYPE type, const string param);
     //--- A flag of a type: RAM, then UpdateDataToDB; the Show setters tell the listeners
   //--- What every type and every parameter IS: the catalog the tables are filled from in OnInit
     int                IndexSetting(const ENUM_BAR_INFOR_TYPE type) const;
     void               Catalog(SBarInforCatalogItem &out[]) const;
     void               SetupCatalog(SBarSetupCatalogItem &out[]) const;
     string             ParamDisplay(const string param) const;
    public:
                        CBarInformationManager(void) : m_CDatabaseService(NULL) { this.m_list.Type(OBJECT_DE_TYPE_BAR_INFORMATION_SETTING); }
     void               SetDatabaseService(CDatabaseService *databaseService) { this.m_CDatabaseService=databaseService; }
   //--- The index of a type in m_list (WRONG_VALUE: none), the type itself (NULL: none)
     CBarInformationSetting *Read_RAM(const ENUM_BAR_INFOR_TYPE type) const;
                       ~CBarInformationManager(void) {}
   //--- Lifecycle - same convention as the other managers: opens the database, makes the tables when they are not there, fills what every type is
     bool               OnInitEvent(void);
   //--- The text of a group: the caption of its section in the Candle tab
     string             Read_RAM(const ENUM_BAR_INFORMATION_GROUP group) const;
   //--- The group of a type, of the table (the one source of the group: CBar keeps it in RAM only, BAR_PROP_INFOR_GROUP)
   //--- The types (m_list), in the order of type_infor: what a type is (name, group, candles, the sides it can have) and what the user wants for it
     int                Read_RAM(ENUM_BAR_INFOR_TYPE &types[], string &names[], ENUM_BAR_INFORMATION_GROUP &groups[], int &candles[], bool &have_buy[], bool &have_sell[],
                                     bool &sound[], bool &message[], bool &show_buy[], bool &show_sell[]) const;
   //--- The flags of a type: written at once, only for a side (or an alert) the type has. Show Buy / Show Sell tell the listeners
   //--- Show or hide the markers of a side on the chart (the same as Show on chart of an indicator template)
   //--- The switch of a group of the tab: ON when the markers of any type of the group are shown. Setting it shows or hides the markers of every type of the group at once
     bool               Read_RAM(const ENUM_BAR_INFORMATION_GROUP group, const string what) const;   // "show": the markers of any type of the group; "alert": an alert of any type
     int                Read_RAM(long &types[], string &names[], bool &sound[], bool &message[]) const;   // the types that have a sound or a message alert on: type_infor, name and the two flags of each. Returns how many
     int                Read_RAM(long &buy_types[], long &sell_types[]) const;   // the types whose Buy (Sell) markers are shown on the chart, and that have the side: type_infor of each. Returns how many types there are
   //--- The parameters of a type (Setting_BarSetup), in the order of the catalog: written at once, only for a parameter the type has
     int                Read_RAM(const ENUM_BAR_INFOR_TYPE type, string &params[], string &displays[], double &values[]) const;
     bool               Read_RAM(const ENUM_BAR_INFOR_TYPE type, const string param, double &value) const;
     //--- RAM, then UpdateDataToDB, then the event: (1) a flag of a type (sound_alert, message_alert, show_buy_signal, show_sell_signal), (2) a parameter of a type,
     //--- (3) the two flags of every type of a group (sound_alert + message_alert, show_buy_signal + show_sell_signal)
     bool               Update_BarInformation_Setting(const ENUM_BAR_INFOR_TYPE type, const string column, const bool on);
     bool               Update_BarInformation_Setting(const ENUM_BAR_INFOR_TYPE type, const string param, const double value);
     bool               Update_BarInformation_Setting(const ENUM_BAR_INFORMATION_GROUP group, const string first, const string second, const bool on);
   //--- The tables of the account. BarTimeSeriesCollection: (1) the rows of a pair (WRONG_VALUE: not read), (2) the rows of the sides asked, (3) the rows of the TFs asked in a candle. BarSeriesDE: (4) its newest bar
     int                ReadDataFromDB(const string symbol, const ENUM_TIMEFRAMES timeframe, const datetime from_time, const datetime to_time, long &types[], long &times[], long &sides[]);
     int                ReadDataFromDB(const string symbol, const ENUM_TIMEFRAMES timeframe, const datetime from_time, const datetime to_time, const long &buy_types[], const long &sell_types[], long &types[], long &times[], long &sides[]);
     int                ReadDataFromDB(const string symbol, const long &asked_tfs[], const datetime from_time, const datetime to_time, const long &asked_types[], const int limit, long &tfs[], long &types[], long &times[], long &sides[]);
     datetime           ReadDataFromDB(const string symbol, const ENUM_TIMEFRAMES timeframe);
   //--- (1) The rows of a type of a pair go to BarTimeSeriesCollection, (2) the closed bars of a pair go to BarSeriesDE
     bool               UpdateDataToDB(const string symbol, const ENUM_TIMEFRAMES timeframe, const long type, const long &times[], const long &sides[]);
     bool               UpdateDataToDB(const string symbol, const ENUM_TIMEFRAMES timeframe, const MqlRates &rates[], const int digits);
  };
#endif // CBARINFORMATIONMANAGER_MQH_DECLARATION

#ifndef CBARINFORMATIONMANAGER_MQH_IMPLEMENTATION
#define CBARINFORMATIONMANAGER_MQH_IMPLEMENTATION

 //+------------------------------------------------------------------+
 //| The catalog: the text of a group, then what each type and each    |
 //| parameter IS (the order of the enum)                              |
 //+------------------------------------------------------------------+
 string CBarInformationManager::Read_RAM(const ENUM_BAR_INFORMATION_GROUP group) const
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
 //| The two tables to m_list: a type for each row of                 |
 //| Setting_BarInformation, its parameters from Setting_BarSetup.    |
 //| Once: the tables are not asked again                              |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::ReadDataFromDB(void)
  {
   // New In V4 after implemenation CDatabaseService
   this.m_list.Clear();
   if(this.m_CDatabaseService == NULL)
      return false;
   SBarInformationRow types[];
   if(!this.m_CDatabaseService.Read("Common", "SELECT type_infor, name, group_infor, candles, have_buy_signal, have_sell_signal, sound_alert, message_alert, "
                                              "show_buy_signal, show_sell_signal FROM Setting_BarInformation ORDER BY type_infor", types))
      return false;
   for(int i = 0; i < ::ArraySize(types); i++)
    {
     CBarInformationSetting *row = new CBarInformationSetting((ENUM_BAR_INFOR_TYPE)(int)types[i].type_infor, types[i].name, (ENUM_BAR_INFORMATION_GROUP)(int)types[i].group_infor,
                                                              (int)types[i].candles, types[i].have_buy_signal != 0, types[i].have_sell_signal != 0);
     if(row == NULL)
        continue;
     row.SoundAlert(types[i].sound_alert != 0);
     row.MessageAlert(types[i].message_alert != 0);
     row.ShowBuy(types[i].show_buy_signal != 0, false);
     row.ShowSell(types[i].show_sell_signal != 0, false);
     if(!this.m_list.Add(row))
        delete row;
    }
   SBarSetupRow setups[];
   if(!this.m_CDatabaseService.Read("Common", "SELECT type_infor, param, display, value FROM Setting_BarSetup ORDER BY rowid", setups))
      return false;
   int params = 0;
   for(int i = 0; i < ::ArraySize(setups); i++)
    {
     CBarInformationSetting *row = this.Read_RAM((ENUM_BAR_INFOR_TYPE)(int)setups[i].type_infor);
     if(row == NULL)
        continue;
     row.AddParam(setups[i].param, setups[i].display, setups[i].value);
     params++;
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
 CBarInformationSetting *CBarInformationManager::Read_RAM(const ENUM_BAR_INFOR_TYPE type) const
  {
   int index = this.IndexSetting(type);
   return (index > WRONG_VALUE ? this.m_list.At(index) : NULL);
  }
 //+------------------------------------------------------------------+
 //| The parameters of a type, in the order they were given            |
 //+------------------------------------------------------------------+
 int CBarInformationManager::Read_RAM(const ENUM_BAR_INFOR_TYPE type, string &params[], string &displays[], double &values[]) const
  {
   CBarInformationSetting *row = this.Read_RAM(type);
   if(row == NULL)
    {
     ::ArrayResize(params, 0);
     ::ArrayResize(displays, 0);
     ::ArrayResize(values, 0);
     return 0;
    }
   return row.Params(params, displays, values);
  }
 bool CBarInformationManager::Read_RAM(const ENUM_BAR_INFOR_TYPE type, const string param, double &value) const
  {
   CBarInformationSetting *row = this.Read_RAM(type);
   return (row != NULL && row.ParamValue(param, value));
  }
 //--- A parameter: its row at once, then the type in m_list, whose setter tells the listeners (BAR_INFORMATION_MANAGER_EVENT_SETUP_CHANGED)
 bool CBarInformationManager::Update_BarInformation_Setting(const ENUM_BAR_INFOR_TYPE type, const string param, const double value)
  {
   CBarInformationSetting *row = this.Read_RAM(type);
   double old = 0;
   if(row == NULL || !row.ParamValue(param, old))
      return false;
   if(old == value)
      return true;
   if(!row.SetParamValue(param, value))
      return false;
   return this.UpdateDataToDB(type, param);
  }
 //+------------------------------------------------------------------+
 //| The types, in the order of type_infor                             |
 //+------------------------------------------------------------------+
 int CBarInformationManager::Read_RAM(ENUM_BAR_INFOR_TYPE &types[], string &names[], ENUM_BAR_INFORMATION_GROUP &groups[], int &candles[], bool &have_buy[], bool &have_sell[],
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
 bool CBarInformationManager::Update_BarInformation_Setting(const ENUM_BAR_INFOR_TYPE type, const string column, const bool on)
  {
   CBarInformationSetting *row = this.Read_RAM(type);
   if(row == NULL)
      return false;
   bool has = (column == "show_buy_signal" ? row.HasBuy() : column == "show_sell_signal" ? row.HasSell() : (row.HasBuy() || row.HasSell()));
   if(!has)
      return false;
   bool value = (column == "show_buy_signal" ? row.ShowBuy() : column == "show_sell_signal" ? row.ShowSell() : column == "sound_alert" ? row.SoundAlert() : row.MessageAlert());
   if(value == on)
      return true;
   if(column == "show_buy_signal")
      row.ShowBuy(on);
   else if(column == "show_sell_signal")
      row.ShowSell(on);
   else if(column == "sound_alert")
      row.SoundAlert(on);
   else
      row.MessageAlert(on);
   return this.UpdateDataToDB(type);
  }
 //+------------------------------------------------------------------+
 //| One type on DB, the whole row as it is on RAM                     |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::UpdateDataToDB(const ENUM_BAR_INFOR_TYPE type)
  {
   // New In V4 after implemenation CDatabaseService
    CBarInformationSetting *row = this.Read_RAM(type);
    if(this.m_CDatabaseService == NULL || row == NULL)
       return false;
    return this.m_CDatabaseService.Create("Common", "INSERT INTO Setting_BarInformation (type_infor, name, group_infor, candles, have_buy_signal, have_sell_signal, sound_alert, message_alert, show_buy_signal, show_sell_signal) VALUES (" +
           (string)(int)type + ", '" + this.m_CDatabaseService.QuoteSQLText(row.Name()) + "', " + (string)(int)row.Group() + ", " + (string)row.Candles() + ", " +
           (string)(int)row.HasBuy() + ", " + (string)(int)row.HasSell() + ", " + (string)(int)row.SoundAlert() + ", " + (string)(int)row.MessageAlert() + ", " +
           (string)(int)row.ShowBuy() + ", " + (string)(int)row.ShowSell() + ") "
           "ON CONFLICT (type_infor) DO UPDATE SET name = excluded.name, group_infor = excluded.group_infor, candles = excluded.candles, have_buy_signal = excluded.have_buy_signal, "
           "have_sell_signal = excluded.have_sell_signal, sound_alert = excluded.sound_alert, message_alert = excluded.message_alert, "
           "show_buy_signal = excluded.show_buy_signal, show_sell_signal = excluded.show_sell_signal");
  }
 //+------------------------------------------------------------------+
 //| Every type of a group on DB                                       |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::UpdateDataToDB(const ENUM_BAR_INFORMATION_GROUP group)
  {
   // New In V4 after implemenation CDatabaseService
    bool result = true;
    for(int i = 0; i < this.m_list.Total(); i++)
      {
       CBarInformationSetting *row = this.m_list.At(i);
       if(row != NULL && row.Group() == group)
          result &= this.UpdateDataToDB(row.TypeInfor());
      }
    return result;
  }
 //+------------------------------------------------------------------+
 //| One parameter of a type on DB, as it is on RAM                    |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::UpdateDataToDB(const ENUM_BAR_INFOR_TYPE type, const string param)
  {
   // New In V4 after implemenation CDatabaseService
    double value = 0;
    if(this.m_CDatabaseService == NULL || !this.Read_RAM(type, param, value))
       return false;
    return this.m_CDatabaseService.Create("Common", "INSERT INTO Setting_BarSetup (type_infor, param, value, display) VALUES (" + (string)(int)type + ", '" +
           this.m_CDatabaseService.QuoteSQLText(param) + "', " + ::DoubleToString(value, 8) + ", '" + this.m_CDatabaseService.QuoteSQLText(this.ParamDisplay(param)) + "') "
           "ON CONFLICT (type_infor, param) DO UPDATE SET value = excluded.value, display = excluded.display");
  }
 //+------------------------------------------------------------------+
 //| The rows of a pair between two bars                               |
 //+------------------------------------------------------------------+
 int CBarInformationManager::ReadDataFromDB(const string symbol, const ENUM_TIMEFRAMES timeframe, const datetime from_time, const datetime to_time, long &types[], long &times[], long &sides[])
  {
   ::ArrayResize(types, 0);
   ::ArrayResize(times, 0);
   ::ArrayResize(sides, 0);
   SBarResultRow rows[];
   if(this.m_CDatabaseService == NULL ||
      !this.m_CDatabaseService.Read("Account", "SELECT type_infor, bar_time, signal_direction FROM BarTimeSeriesCollection WHERE name = '" + this.m_CDatabaseService.QuoteSQLText(symbol) + "' AND tf_enum = " + (string)(int)timeframe +
                                               " AND bar_time >= " + (string)(long)from_time + " AND bar_time <= " + (string)(long)to_time, rows))
      return WRONG_VALUE;
   int total = ::ArraySize(rows);
   ::ArrayResize(types, total);
   ::ArrayResize(times, total);
   ::ArrayResize(sides, total);
   for(int i = 0; i < total; i++)
     {
      types[i] = rows[i].type_infor;
      times[i] = rows[i].bar_time;
      sides[i] = rows[i].signal_direction;
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| The rows of a pair the markers show: the sides asked              |
 //+------------------------------------------------------------------+
 int CBarInformationManager::ReadDataFromDB(const string symbol, const ENUM_TIMEFRAMES timeframe, const datetime from_time, const datetime to_time, const long &buy_types[], const long &sell_types[], long &types[], long &times[], long &sides[])
  {
   ::ArrayResize(types, 0);
   ::ArrayResize(times, 0);
   ::ArrayResize(sides, 0);
   SBarResultRow rows[];
   if(this.m_CDatabaseService == NULL ||
      !this.m_CDatabaseService.Read("Account", "SELECT type_infor, bar_time, signal_direction FROM BarTimeSeriesCollection WHERE name = '" + this.m_CDatabaseService.QuoteSQLText(symbol) + "' AND tf_enum = " + (string)(int)timeframe +
                                               " AND bar_time >= " + (string)(long)from_time + " AND bar_time <= " + (string)(long)to_time + " AND ((signal_direction = " + (string)(int)SIGNAL_DIRECTION_BUY +
                                               " AND type_infor IN (" + this.m_CDatabaseService.InList(buy_types) + ")) OR (signal_direction = " + (string)(int)SIGNAL_DIRECTION_SELL + " AND type_infor IN (" + this.m_CDatabaseService.InList(sell_types) + ")))", rows))
      return 0;
   int total = ::ArraySize(rows);
   ::ArrayResize(types, total);
   ::ArrayResize(times, total);
   ::ArrayResize(sides, total);
   for(int i = 0; i < total; i++)
     {
      types[i] = rows[i].type_infor;
      times[i] = rows[i].bar_time;
      sides[i] = rows[i].signal_direction;
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| What was found in a candle, the TFs asked                         |
 //+------------------------------------------------------------------+
 int CBarInformationManager::ReadDataFromDB(const string symbol, const long &asked_tfs[], const datetime from_time, const datetime to_time, const long &asked_types[], const int limit, long &tfs[], long &types[], long &times[], long &sides[])
  {
   ::ArrayResize(tfs, 0);
   ::ArrayResize(types, 0);
   ::ArrayResize(times, 0);
   ::ArrayResize(sides, 0);
   SBarCandleRow rows[];
   if(this.m_CDatabaseService == NULL ||
      !this.m_CDatabaseService.Read("Account", "SELECT tf_enum, type_infor, bar_time, signal_direction FROM BarTimeSeriesCollection WHERE name = '" + this.m_CDatabaseService.QuoteSQLText(symbol) + "' AND tf_enum IN (" +
                                               this.m_CDatabaseService.InList(asked_tfs) + ") AND type_infor IN (" + this.m_CDatabaseService.InList(asked_types) + ") AND bar_time >= " + (string)(long)from_time +
                                               " AND bar_time < " + (string)(long)to_time + " ORDER BY tf_enum DESC, bar_time LIMIT " + (string)limit, rows))
      return 0;
   int total = ::ArraySize(rows);
   ::ArrayResize(tfs, total);
   ::ArrayResize(types, total);
   ::ArrayResize(times, total);
   ::ArrayResize(sides, total);
   for(int i = 0; i < total; i++)
     {
      tfs[i]   = rows[i].tf_enum;
      types[i] = rows[i].type_infor;
      times[i] = rows[i].bar_time;
      sides[i] = rows[i].signal_direction;
     }
   return total;
  }
 //+------------------------------------------------------------------+
 //| The newest bar of a pair in BarSeriesDE (0: none)                 |
 //+------------------------------------------------------------------+
 datetime CBarInformationManager::ReadDataFromDB(const string symbol, const ENUM_TIMEFRAMES timeframe)
  {
   SBarNewestRow row;
   if(this.m_CDatabaseService == NULL ||
      !this.m_CDatabaseService.Read("Account", "SELECT COALESCE(MAX(bar_time), 0) FROM BarSeriesDE WHERE name = '" + this.m_CDatabaseService.QuoteSQLText(symbol) + "' AND tf_enum = " + (string)(int)timeframe, row))
      return 0;
   return (datetime)row.bar_time;
  }
 //+------------------------------------------------------------------+
 //| The rows of a type of a pair, one statement: all of them or none  |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::UpdateDataToDB(const string symbol, const ENUM_TIMEFRAMES timeframe, const long type, const long &times[], const long &sides[])
  {
   int total = ::ArraySize(times);
   if(total == 0)
      return true;
   if(this.m_CDatabaseService == NULL)
      return false;
   string sql = "INSERT OR IGNORE INTO BarTimeSeriesCollection (name, tf_enum, type_infor, bar_time, signal_direction) VALUES ";
   for(int i = 0; i < total; i++)
      sql += (i > 0 ? ", ('" : "('") + this.m_CDatabaseService.QuoteSQLText(symbol) + "', " + (string)(int)timeframe + ", " + (string)type + ", " + (string)times[i] + ", " + (string)sides[i] + ")";
   return this.m_CDatabaseService.Create("Account", sql);
  }
 //+------------------------------------------------------------------+
 //| The closed bars of a pair, one statement: all of them or none     |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::UpdateDataToDB(const string symbol, const ENUM_TIMEFRAMES timeframe, const MqlRates &rates[], const int digits)
  {
   int total = ::ArraySize(rates);
   if(total == 0)
      return true;
   if(this.m_CDatabaseService == NULL)
      return false;
   string sql = "INSERT OR IGNORE INTO BarSeriesDE (name, tf_enum, bar_time, open, high, low, close, tick_volume, spread, real_volume) VALUES ";
   for(int i = 0; i < total; i++)
      sql += (i > 0 ? ", ('" : "('") + this.m_CDatabaseService.QuoteSQLText(symbol) + "', " + (string)(int)timeframe + ", " + (string)(long)rates[i].time + ", " + ::DoubleToString(rates[i].open, digits) + ", " +
             ::DoubleToString(rates[i].high, digits) + ", " + ::DoubleToString(rates[i].low, digits) + ", " + ::DoubleToString(rates[i].close, digits) + ", " +
             (string)rates[i].tick_volume + ", " + (string)rates[i].spread + ", " + (string)rates[i].real_volume + ")";
   return this.m_CDatabaseService.Create("Account", sql);
  }
 bool CBarInformationManager::Read_RAM(const ENUM_BAR_INFORMATION_GROUP group, const string what) const
  {
   for(int i = 0; i < this.m_list.Total(); i++)
    {
     CBarInformationSetting *row = this.m_list.At(i);
     if(row == NULL || row.Group() != group)
        continue;
     if(what == "show" && (row.ShowBuy() || row.ShowSell()))
        return true;
     if(what == "alert" && (row.SoundAlert() || row.MessageAlert()))
        return true;
    }
   return false;
  }
 //+------------------------------------------------------------------+
 //| The switch of a group: every type of it, also one without a side  |
 //| the tab does not list (Inside Bar). The markers tell one event    |
 //| (lparam = WRONG_VALUE: several types, dparam = the group)         |
 //+------------------------------------------------------------------+
 bool CBarInformationManager::Update_BarInformation_Setting(const ENUM_BAR_INFORMATION_GROUP group, const string first, const string second, const bool on)
  {
   const bool alert_pair = (first == "sound_alert" && second == "message_alert");
   if(!alert_pair && !(first == "show_buy_signal" && second == "show_sell_signal"))
     {
      ::Print(__FUNCTION__, " > rejected: invalid column pair");
      return false;
     }
   bool changed = false;
   for(int i = 0; i < this.m_list.Total(); i++)
    {
     CBarInformationSetting *row = this.m_list.At(i);
     if(row == NULL || row.Group() != group)
        continue;
     if(alert_pair)
       {
        row.SoundAlert(on);
        row.MessageAlert(on);
        continue;
       }
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
   if(!this.UpdateDataToDB(group))
      return false;
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
   // New In V4 after implemenation CDatabaseService
    if(this.m_CDatabaseService == NULL)
      {
       ::Print(__FUNCTION__, " > DatabaseService is not set");
       return false;
      }
    if(!this.m_first_start)   // a chart change writes nothing
       return true;
    string sql_create_table_Setting_BarInformation = "CREATE TABLE IF NOT EXISTS Setting_BarInformation (type_infor INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL UNIQUE, group_infor INTEGER NOT NULL, "
                                                     "candles INTEGER NOT NULL, have_buy_signal INTEGER NOT NULL, have_sell_signal INTEGER NOT NULL, "
                                                     "sound_alert INTEGER NOT NULL DEFAULT 1, message_alert INTEGER NOT NULL DEFAULT 1, "
                                                     "show_buy_signal INTEGER NOT NULL DEFAULT 1, show_sell_signal INTEGER NOT NULL DEFAULT 1)";
    if(!this.m_CDatabaseService.Create("Common", sql_create_table_Setting_BarInformation))
      {
       ::Print(__FUNCTION__, " > DatabaseService can't create table Setting_BarInformation");
       return false;
      }
    string sql_create_table_Setting_BarSetup = "CREATE TABLE IF NOT EXISTS Setting_BarSetup (type_infor INTEGER NOT NULL REFERENCES Setting_BarInformation (type_infor), param TEXT NOT NULL, "
                                               "value REAL NOT NULL, display TEXT NOT NULL DEFAULT '', PRIMARY KEY (type_infor, param))";
    if(!this.m_CDatabaseService.Create("Common", sql_create_table_Setting_BarSetup))
      {
       ::Print(__FUNCTION__, " > DatabaseService can't create table Setting_BarSetup");
       return false;
      }
    //--- The tables of the account: what was found on the bars, and the closed bars (from CBarTimeSeriesCollection::OnInitEvent, same schema)
    string sql_create_table_BarTimeSeriesCollection = "CREATE TABLE IF NOT EXISTS BarTimeSeriesCollection (name TEXT NOT NULL, tf_enum INTEGER NOT NULL, "
                                                      "type_infor INTEGER NOT NULL, bar_time INTEGER NOT NULL, signal_direction INTEGER NOT NULL, "
                                                      "PRIMARY KEY (name, tf_enum, type_infor, bar_time, signal_direction)) WITHOUT ROWID";
    if(!this.m_CDatabaseService.Create("Account", sql_create_table_BarTimeSeriesCollection))
      {
       ::Print(__FUNCTION__, " > DatabaseService can't create table BarTimeSeriesCollection");
       return false;
      }
    string sql_create_table_BarSeriesDE = "CREATE TABLE IF NOT EXISTS BarSeriesDE (name TEXT NOT NULL, tf_enum INTEGER NOT NULL, "
                                          "bar_time INTEGER NOT NULL, open REAL NOT NULL, high REAL NOT NULL, low REAL NOT NULL, close REAL NOT NULL, tick_volume INTEGER NOT NULL, "
                                          "spread INTEGER NOT NULL, real_volume INTEGER NOT NULL, PRIMARY KEY (name, tf_enum, bar_time)) WITHOUT ROWID";
    if(!this.m_CDatabaseService.Create("Account", sql_create_table_BarSeriesDE))
      {
       ::Print(__FUNCTION__, " > DatabaseService can't create table BarSeriesDE");
       return false;
      }
    //--- What a type IS is written at every start; what the user wants is only given to a type that is new
    SBarInforCatalogItem catalog[];
    this.Catalog(catalog);
    string in_catalog = "";
    for(int i = 0; i < ::ArraySize(catalog); i++)
       in_catalog += (i > 0 ? ", " : "") + (string)(int)catalog[i].type_infor;
    this.m_CDatabaseService.Delete("Common", "DELETE FROM Setting_BarSetup WHERE type_infor NOT IN (" + in_catalog + ")");
    this.m_CDatabaseService.Delete("Common", "DELETE FROM Setting_BarInformation WHERE type_infor NOT IN (" + in_catalog + ")");
    for(int i = 0; i < ::ArraySize(catalog); i++)
      {
       string have_buy  = (catalog[i].have_buy_signal  ? "1" : "0");
       string have_sell = (catalog[i].have_sell_signal ? "1" : "0");
       if(!this.m_CDatabaseService.Create("Common", "INSERT INTO Setting_BarInformation (type_infor, name, group_infor, candles, have_buy_signal, have_sell_signal, show_buy_signal, show_sell_signal) VALUES (" +
                                          (string)(int)catalog[i].type_infor + ", '" + this.m_CDatabaseService.QuoteSQLText(catalog[i].name) + "', " + (string)(int)catalog[i].group_infor + ", " +
                                          (string)catalog[i].candles + ", " + have_buy + ", " + have_sell + ", " + have_buy + ", " + have_sell + ") " +
                                          "ON CONFLICT(type_infor) DO UPDATE SET name = excluded.name, group_infor = excluded.group_infor, candles = excluded.candles, " +
                                          "have_buy_signal = excluded.have_buy_signal, have_sell_signal = excluded.have_sell_signal"))
         {
          ::Print(__FUNCTION__, " > ", catalog[i].name, " not written");
          return false;
         }
      }
    //--- A parameter that is new gets its default, the value the user set is never changed
    SBarSetupCatalogItem setup[];
    this.SetupCatalog(setup);
    string in_setup = "";
    for(int i = 0; i < ::ArraySize(setup); i++)
       in_setup += (i > 0 ? " OR " : "") + "(type_infor = " + (string)(int)setup[i].type_infor + " AND param = '" + this.m_CDatabaseService.QuoteSQLText(setup[i].param) + "')";
    this.m_CDatabaseService.Delete("Common", "DELETE FROM Setting_BarSetup WHERE NOT (" + in_setup + ")");
    for(int i = 0; i < ::ArraySize(setup); i++)
      {
       if(!this.m_CDatabaseService.Create("Common", "INSERT INTO Setting_BarSetup (type_infor, param, value, display) VALUES (" + (string)(int)setup[i].type_infor + ", '" +
                                          this.m_CDatabaseService.QuoteSQLText(setup[i].param) + "', " + ::DoubleToString(setup[i].value, 8) + ", '" +
                                          this.m_CDatabaseService.QuoteSQLText(this.ParamDisplay(setup[i].param)) + "') " +
                                          "ON CONFLICT(type_infor, param) DO UPDATE SET display = excluded.display"))
         {
          ::Print(__FUNCTION__, " > ", setup[i].param, " not written");
          return false;
         }
      }
    if(!this.ReadDataFromDB())
       return false;
    this.m_first_start = false;
    return true;
  }
 //+------------------------------------------------------------------+
 //| The types whose markers are shown on the chart, for each side     |
 //+------------------------------------------------------------------+
 int CBarInformationManager::Read_RAM(long &buy_types[], long &sell_types[]) const
  {
   ::ArrayResize(buy_types, 0);
   ::ArrayResize(sell_types, 0);
   ENUM_BAR_INFOR_TYPE types[];
   string names[];
   ENUM_BAR_INFORMATION_GROUP groups[];
   int candles[];
   bool have_buy[], have_sell[], sound[], message[], show_buy[], show_sell[];
   int total = this.Read_RAM(types, names, groups, candles, have_buy, have_sell, sound, message, show_buy, show_sell);
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
 int CBarInformationManager::Read_RAM(long &types[], string &names[], bool &sound[], bool &message[]) const
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
   int total = this.Read_RAM(all_types, all_names, groups, candles, have_buy, have_sell, all_sound, all_message, show_buy, show_sell);
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
