//+------------------------------------------------------------------+
//|                                           Order Block EA MT5.mq5 |
//|                                                        Your Name |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Your Name"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property tester_indicator "Order_Block_Indicador_New_Part_2.ex5"
#resource "\\Indicators\\Order_Block_Indicador_New_Part_2.ex5"

enum ENUM_TP_SL_STYLE
 {
  ATR = 0,
  POINT = 1
 };

#include  <Risk_Management.mqh>
CTrade trade;

sinput group "--- Order Block EA settings ---"
input ulong Magic = 545244; //Magic number
input ENUM_TIMEFRAMES timeframe_order_block = PERIOD_M5; //Order block timeframe

sinput group "-- Order Block --"
input int  Rango_universal_busqueda = 500; //search range of order blocks
input int  Witdth_order_block = 1; //Width order block

input bool Back_order_block = true; //Back order block?
input bool Fill_order_block = true; //Fill order block?

input color Color_Order_Block_Bajista = clrRed; //Bearish order block color
input color Color_Order_Block_Alcista = clrGreen; //Bullish order block color

sinput group "-- Strategy --"
input ENUM_TP_SL_STYLE tp_sl_style = POINT;//tp and sl style

sinput group "- ATR "
input double Atr_Multiplier_1 = 1.5;//Atr multiplier 1
input double Atr_Multiplier_2 = 2.0;//Atr multiplier 2

sinput group "- POINT "
input int TP_POINT = 1000; //TP in Points
input int SL_POINT = 1000; //SL in Points


sinput group "--- Risk Management ---"
input ENUM_LOTE_TYPE Lote_Type = Dinamico; //Lote Type
input double lote = 0.1; //lot size (only for fixed lot)
input ENUM_MODE_RISK_MANAGEMENT risk_mode = personal_account;//type of risk management mode
input ENUM_GET_LOT get_mode = GET_LOT_BY_STOPLOSS_AND_RISK_PER_OPERATION; //How to get the lot
input double prop_firm_balance = 1000; //If risk mode is Prop Firm FTMO, then put your ftmo account balance

sinput group "- ML/Maxium loss/Maxima perdida -"
input double percentage_or_money_ml_input = 0; //percentage or money (0 => not used ML)
input ENUM_RISK_CALCULATION_MODE mode_calculation_ml = percentage; //Mode calculation Max Loss
input ENUM_APPLIED_PERCENTAGES applied_percentages_ml = Balance; //ML percentage applies to:

sinput group "- MWL/Maximum weekly loss/Perdida maxima semanal -"
input double percentage_or_money_mwl_input  = 0; //percentage or money (0 => not used MWL)
input ENUM_RISK_CALCULATION_MODE mode_calculation_mwl = percentage; //Mode calculation Max weekly Loss
input ENUM_APPLIED_PERCENTAGES applied_percentages_mwl = Balance;//MWL percentage applies to:

sinput group "- MDL/Maximum  daily loss/Perdida maxima diaria -"
input double percentage_or_money_mdl_input  = 0; //percentage or money (0 => not used MDL)
input ENUM_RISK_CALCULATION_MODE mode_calculation_mdl = percentage; //Mode calculation Max daily loss
input ENUM_APPLIED_PERCENTAGES applied_percentages_mdl = Balance;//MDL percentage applies to:

sinput group "- GMLPO/Gross maximum loss per operation/Porcentaje a arriesgar por operacion -"
input ENUM_OF_DYNAMIC_MODES_OF_GMLPO mode_gmlpo = DYNAMIC_GMLPO_FULL_CUSTOM; //Select GMLPO mode:
input ENUM_REVISION_TYPE revision_type_gmlpo = REVISION_ON_CLOSE_POSITION; //Type revision
input double percentage_or_money_gmlpo_input  = 1.0; //percentage or money (0 => not used GMLPO)
input ENUM_RISK_CALCULATION_MODE mode_calculation_gmlpo = percentage; //Mode calculation Max Loss per operation
input ENUM_APPLIED_PERCENTAGES applied_percentages_gmlpo = Balance;//GMPLO percentage applies to:

sinput group "-- Optional GMLPO settings, Dynamic GMLPO"
sinput group "--- Full customizable dynamic GMLPO"
input string note1 = "subtracted from your total balance to establish a threshold.";  //This parameter determines a specific percentage that will be
input string str_percentages_to_be_reviewed = "2,5,7,9"; //percentages separated by commas.
input string note2 = "a new risk level will be triggered on your future trades: "; //When the current balance (equity) falls below this threshold
input string str_percentages_to_apply = "1,0.7,0.5,0.33"; //percentages separated by commas.
input string note3 = "0 in both parameters => do not use dynamic risk in gmlpo"; //Note:

sinput group "--- Fixed dynamic GMLPO with parameters"
sinput group "- 1 -"
input string note1_1 = "subtracted from your total balance to establish a threshold.";  //This parameter determines a specific percentage that will be
input double inp_balance_percentage_to_activate_the_risk_1 = 2.0; //percentage 1 that will be exceeded to modify the risk separated by commas
input string note2_1 = "a new risk level will be triggered on your future trades: "; //When the current balance (equity) falls below this threshold
input double inp_percentage_to_be_modified_1 = 1.0;//new percentage 1 to which the gmlpo is modified
sinput group "- 2 -"
input double inp_balance_percentage_to_activate_the_risk_2 = 5.0;//percentage 2 that will be exceeded to modify the risk separated by commas
input double inp_percentage_to_be_modified_2 = 0.7;//new percentage 2 to which the gmlpo is modified
sinput group "- 3 -"
input double inp_balance_percentage_to_activate_the_risk_3 = 7.0;//percentage 3 that will be exceeded to modify the risk separated by commas
input double inp_percentage_to_be_modified_3 = 0.5;//new percentage 3 to which the gmlpo is modified
sinput group "- 4 -"
input double inp_balance_percentage_to_activate_the_risk_4 = 9.0;//percentage 4 that will be exceeded to modify the risk separated by commas
input double inp_percentage_to_be_modified_4 = 0.33;//new percentage 4  1 to which the gmlpo is modified

sinput group "- MDP/Maximum daily profit/Maxima ganancia diaria -"
input bool mdp_is_strict = true; //MDP is strict?
input double percentage_or_money_mdp_input = 0; //percentage or money (0 => not used MDP)
input ENUM_RISK_CALCULATION_MODE mode_calculation_mdp = percentage; //Mode calculation Max Daily Profit
input ENUM_APPLIED_PERCENTAGES applied_percentages_mdp = Balance;//MDP percentage applies to:

sinput group "--- Session ---"
input         char hora_inicio = 16;//start hour to operate (0-23)
input         char min_inicio = 30;//start minute to operate (0-59)
input         char hora_fin = 18;//end hour to operate (1-23)
input         char min_fin =0;//end minute to operate (0-59)

//+------------------------------------------------------------------+
//|                   Global Variables                               |
//+------------------------------------------------------------------+
CRiskManagemet risk(mdp_is_strict, get_mode, Magic, risk_mode, prop_firm_balance);

//--- Handles
int order_block_indicator_handle;
int hanlde_ma;

//---
double tp1[];
double tp2[];
double sl1[];
double sl2[];

//---
datetime TiempoBarraApertua;
datetime TiempoBarraApertua_1;
datetime prev_vela;
datetime start_sesion;
datetime end_sesion;

//---
bool opera = true;
//Extra variables
bool extra = true; //Boolean variable to activate the trade, in case it is deactivated due to exceeding the maximum weekly loss
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
 { 
//---
  MqlParam param[17];

  param[0].type = TYPE_STRING;
  param[0].string_value = "::Indicators\\Order_Block_Indicador_New_Part_2";

  param[1].type = TYPE_STRING;
  param[1].string_value = "--- Order Block Indicator settings ---";

  param[2].type = TYPE_STRING;
  param[2].string_value = "-- Order Block --";

  param[3].type = TYPE_INT;
  param[3].integer_value = Rango_universal_busqueda;

  param[4].type = TYPE_INT;
  param[4].integer_value = Witdth_order_block;

  param[5].type = TYPE_BOOL;
  param[5].integer_value = Back_order_block;

  param[6].type = TYPE_BOOL;
  param[6].integer_value = Fill_order_block;

  param[7].type = TYPE_COLOR;
  param[7].integer_value = Color_Order_Block_Bajista;

  param[8].type = TYPE_COLOR;
  param[8].integer_value = Color_Order_Block_Alcista;

  param[9].type = TYPE_STRING;
  param[9].string_value = "-- Strategy --";

  param[10].type = TYPE_INT;
  param[10].integer_value = tp_sl_style;

  param[11].type = TYPE_STRING;
  param[11].string_value = "- ATR";

  param[12].type = TYPE_DOUBLE;
  param[12].double_value = Atr_Multiplier_1;

  param[13].type = TYPE_DOUBLE;
  param[13].double_value = Atr_Multiplier_2;

  param[14].type = TYPE_STRING;
  param[14].string_value = "- POINT";

  param[15].type = TYPE_INT;
  param[15].integer_value = TP_POINT;

  param[16].type = TYPE_INT;
  param[16].integer_value = SL_POINT;

//---
  order_block_indicator_handle = IndicatorCreate(_Symbol, timeframe_order_block, IND_CUSTOM, ArraySize(param), param);
  hanlde_ma = iMA(_Symbol, timeframe_order_block, 30, 0, MODE_EMA, PRICE_CLOSE);
  trade.SetExpertMagicNumber(Magic);

  if(order_block_indicator_handle == INVALID_HANDLE)
   {
    Print("The order blocks indicator is not available last error: ", _LastError);
    return INIT_FAILED;
   }

  if(hanlde_ma == INVALID_HANDLE)
   {
    Print("The ema indicator is not available latest error: ", _LastError);
    return INIT_FAILED;
   }

//---
  ChartIndicatorAdd(0, 0, order_block_indicator_handle);
  ChartIndicatorAdd(0, 0, hanlde_ma);

//---
  risk.SetPorcentages(percentage_or_money_mdl_input, percentage_or_money_mwl_input, percentage_or_money_gmlpo_input
                      , percentage_or_money_ml_input, percentage_or_money_mdp_input);
  risk.SetEnums(mode_calculation_mdl, mode_calculation_mwl, mode_calculation_gmlpo, mode_calculation_ml, mode_calculation_mdp);
  risk.SetApplieds(applied_percentages_mdl, applied_percentages_mwl, applied_percentages_gmlpo, applied_percentages_ml, applied_percentages_mdp);

  if(mode_gmlpo == DYNAMIC_GMLPO_FIXED_PARAMETERS)
   {
    string percentages_to_activate, risks_to_be_applied;
    SetDynamicGMLPOUsingFixedParameters(inp_balance_percentage_to_activate_the_risk_1, inp_balance_percentage_to_activate_the_risk_2, inp_balance_percentage_to_activate_the_risk_3
                                        , inp_balance_percentage_to_activate_the_risk_4, inp_percentage_to_be_modified_1, inp_percentage_to_be_modified_2, inp_percentage_to_be_modified_3, inp_percentage_to_be_modified_4
                                        , percentages_to_activate, risks_to_be_applied);
    risk.SetDynamicGMLPO(percentages_to_activate, risks_to_be_applied, revision_type_gmlpo);
   }
  else
    if(mode_gmlpo == DYNAMIC_GMLPO_FULL_CUSTOM)
      risk.SetDynamicGMLPO(str_percentages_to_be_reviewed, str_percentages_to_apply, revision_type_gmlpo);

//---

  ArraySetAsSeries(tp1, true);
  ArraySetAsSeries(tp2, true);
  ArraySetAsSeries(sl1, true);
  ArraySetAsSeries(sl2, true);

  return(INIT_SUCCEEDED);
 }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
//---
  ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, GetMovingAverageIndex()));
  ChartIndicatorDelete(0, 0, "Order Block Indicator");

  if(hanlde_ma != INVALID_HANDLE)
    IndicatorRelease(hanlde_ma);

  if(order_block_indicator_handle != INVALID_HANDLE)
    IndicatorRelease(order_block_indicator_handle);

 }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
 {
//---
  if(TiempoBarraApertua != iTime(_Symbol, PERIOD_D1, 0))
   {
    /*if(extra)*/ opera = true;
    risk.OnNewDay();
    start_sesion = HoraYMinutoADatetime(hora_inicio,min_inicio);
    end_sesion = HoraYMinutoADatetime(hora_fin,min_fin);

    if(TiempoBarraApertua_1 != iTime(_Symbol, PERIOD_W1, 0))
     {
      //extra = true;
      risk.OnNewWeek();
      TiempoBarraApertua_1 = iTime(_Symbol, PERIOD_W1, 0);
     }

    TiempoBarraApertua = iTime(_Symbol, PERIOD_D1, 0);
   }


  if(opera == false)
    return;

 if(TimeCurrent() > start_sesion && TimeCurrent() < end_sesion)
 {
  if(prev_vela != iTime(_Symbol, timeframe_order_block, 0))
   {
    CopyBuffer(order_block_indicator_handle, 2, 0, 5, tp1);
    CopyBuffer(order_block_indicator_handle, 3, 0, 5, tp2);
    CopyBuffer(order_block_indicator_handle, 4, 0, 5, sl1);
    CopyBuffer(order_block_indicator_handle, 5, 0, 5, sl2);

    if(tp1[0] > 0 && tp2[0]  > 0 && sl1[0] > 0 &&  sl2[0] > 0)
     {
      if(tp2[0] > sl2[0] && risk.GetPositionsTotal() == 0)  //compras
       {
        double ASK = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
        risk.SetStopLoss(ASK - sl1[0]);
        double lot = (Lote_Type == Dinamico ? risk.GetLote(ORDER_TYPE_BUY) : lote);

        if(lot > 0.0)
          trade.Buy(lot, _Symbol, ASK, sl1[0], tp1[0], "Order Block EA Buy");
       }
      else
        if(sl2[0] > tp2[0] && risk.GetPositionsTotal() == 0)  //venta
         {
          double BID = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
          risk.SetStopLoss(sl1[0] - BID);
          double lot = (Lote_Type == Dinamico ? risk.GetLote(ORDER_TYPE_SELL) : lote);

          if(lot > 0.0)
            trade.Sell(lot, _Symbol, BID, sl1[0], tp1[0], "Order Block EA Sell");
         }
     }

    prev_vela = iTime(_Symbol, timeframe_order_block, 0);
   }
 }
  
  
  risk.OnTickEvent();

  if(risk.ML_IsSuperated(CLOSE_POSITION_AND_EQUITY)  == true)
   {
    if(risk_mode == propfirm_ftmo)
     {
      Print("The expert advisor lost the funding test");
      ExpertRemove();
     }
    else
     {
      risk.CloseAllPositions();
      Print("Maximum loss exceeded now");
      opera = false;
     }
   }

  if(risk.MDL_IsSuperated(CLOSE_POSITION_AND_EQUITY) == true)
   {
    risk.CloseAllPositions();
    Print("Maximum daily loss exceeded now");
    opera = false;
   }

  if(risk.MDP_IsSuperated(CLOSE_POSITION_AND_EQUITY) == true)
   {
    risk.CloseAllPositions();
    Print("Excellent Maximum daily profit achieved");
    opera = false;
   }
   

 //Right here you can set more limitations such as the maximum weekly loss:
  /*
   if(risk.MWL_IsSuperated(CLOSE_POSITION_AND_EQUITY) == true)
   {
    risk.CloseAllPositions();
    Print("The maximum weekly loss has been exceeded");
    opera = false;
    extra = false;
   }
  */


 }

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
 {
  risk.OnTradeTransactionEvent(trans);
 }

//+------------------------------------------------------------------+
//| Extra Functions                                                  |
//+------------------------------------------------------------------+
int GetMovingAverageIndex(long chart_id = 0)
 {
  int total_indicators = ChartIndicatorsTotal(chart_id, 0);
  for(int i = 0; i < total_indicators; i++)
   {
    string indicator_name = ChartIndicatorName(chart_id, 0, i);
    if(StringFind(indicator_name, "MA") >= 0)  return i;
   }
  return -1;
 }
//+------------------------------------------------------------------+
datetime HoraYMinutoADatetime(int hora, int minuto) {
  MqlDateTime tm;
  TimeCurrent(tm);
// Asigna la hora y el minuto deseado
  tm.hour = hora;
  tm.min = minuto;
  tm.sec = 0; // Puedes ajustar los segundos si es necesario
  return StructToTime(tm);;
}



