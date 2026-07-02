//+------------------------------------------------------------------+
//|                                          TestComboBoxGUI.mqh     |
//| Minimal Tang-2-only EA to test CComboBox click/open behavior.    |
//|   CWindow -> CTabs(m_tabs_main) -> [fixed-position TreeView +    |
//|   CTabs(m_tabs_indicator_config)] -> CComboBox                  |
//| CSplitContainer dropped: it kept producing its own resize bugs   |
//| (Panel2 ballooning past CWindow bounds) unrelated to ComboBox -  |
//| fixed positions sidestep that whole class of bug.                |
//| No Tang 1 (PureData) / Tang 3 (chart) calls - Add just Prints a  |
//| TODO placeholder instead of touching CTimeSeriesEngine/chart.    |
//+------------------------------------------------------------------+
#ifndef __TESTCOMBOBOXGUI_MQH__
#define __TESTCOMBOBOXGUI_MQH__
#include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\WndEvents.mqh>
// --- WndEvents.mqh itself references the CSplitContainer type internally
// --- (resize-cascade dynamic_cast), so its definition must stay included even
// --- though this test no longer creates a CSplitContainer instance.
#include <Vendors\Anhnt\Library\4. Combination Lib\GUI Lib\Controls\SplitContainer.mqh>
// --- ENUM_INDICATOR_GROUP / ENUM_INDICATOR lives here - normally pulled in
// --- transitively via IndicatorsCollection.mqh in the real GUIPannel.mqh chain.
#include <Vendors\Anhnt\Library\4. Combination Lib\Defines\TimeseriesDefines.mqh>
// --- Pure Tang-1 metadata only (catalog/schema structs + switch statements,
// --- zero PureData object creation) - safe to reuse for driving the test tree/form.
#include "..\..\Artyom Trishkin\IndicatorCatalog.mqh"

enum ENUM_TEST_TAB_MAIN
  {
   TEST_TAB_SETTINGS = 0,
   TEST_TABS_MAIN_TOTAL
  };
enum ENUM_TEST_TAB_CONFIG
  {
   TEST_TAB_CONFIG_PARAMS = 0,
   TEST_TAB_CONFIG_TOTAL
  };

#define INDICATOR_PARAM_ROWS      4
// --- FIELD_X must clear the longest label that can land in either column
// --- across ALL indicator types (e.g. "Slow EMA Period", "Applied Volume"),
// --- since col is just i%2 - not tied to any specific label per type.
#define INDICATOR_PARAM_LABEL_W   100
#define INDICATOR_PARAM_FIELD_W   80
#define INDICATOR_PARAM_COL_WIDTH (INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W + 12)
#define INDICATOR_TREE_WIDTH      150   // fixed left-column width, replaces SplitX()

// =====================================================================
// --- Tang 2 (GUI) layout descriptor - decided BEFORE CreateParamsTab/
// --- ShowIndicatorParameterForm ever runs, separate from Tang 1's
// --- SIndicatorParam (which only knows name/type/default/choices, not
// --- where on screen it goes or which control renders it).
// =====================================================================
struct SIndicatorLayout
  {
   int               row;            // 0-based row in the form
   int               col;            // 0-based column (0=left, 1=right)
   int               total_width;    // label + field combined - keep this EQUAL
                                      // across a type's rows to make every row's
                                      // value box line up at the same right edge,
                                      // regardless of each row's label text length.
   int               field_width;    // px width of the value control itself (edit/combo)
   ENUM_ELEMENT_TYPE element_type;   // E_TEXT_BOX or E_COMBO_BOX (GUIDefines.mqh)
  };

// --- Shorthand for declaring one slot's layout: L(idx,row,col,total_w,field_w)
// --- The label starts at the row's x and gets (total_w - field_w) px before
// --- the field begins.
#define L(idx,r,c,tw,fw) out[idx].row=r; out[idx].col=c; out[idx].total_width=tw; out[idx].field_width=fw;

// --- Named param-slot indices, only for types curated below. MQL5 has no
// --- named arguments, so this names the one truly error-prone number in
// --- each L(...) call (idx) - row/col/width are already self-evident from
// --- the macro name + the small numbers themselves. Order MUST mirror the
// --- index order declared for that type in GetIndicatorParamSchema().
enum ENUM_MA_PARAM       { MA_PERIOD = 0, MA_SHIFT, MA_METHOD, MA_APPLIED_PRICE };  // shape also shared by IND_STDDEV
enum ENUM_ICHIMOKU_PARAM { ICHIMOKU_TENKAN = 0, ICHIMOKU_KIJUN, ICHIMOKU_SENKOU_B };
enum ENUM_SAR_PARAM      { SAR_STEP = 0, SAR_MAXIMUM };
enum ENUM_BANDS_PARAM    { BANDS_PERIOD = 0, BANDS_SHIFT, BANDS_DEVIATION, BANDS_APPLIED_PRICE };
// --- Jaw/Teeth/Lips period+shift pairs + Method + Applied Price - identical
// --- 8-param shape for both Alligator and Gator Oscillator.
enum ENUM_JAW_TEETH_LIPS_PARAM
  {
   JTL_JAW_PERIOD = 0, JTL_JAW_SHIFT, JTL_TEETH_PERIOD, JTL_TEETH_SHIFT,
   JTL_LIPS_PERIOD, JTL_LIPS_SHIFT, JTL_METHOD, JTL_APPLIED_PRICE
  };
enum ENUM_ENVELOPES_PARAM { ENVELOPES_PERIOD = 0, ENVELOPES_SHIFT, ENVELOPES_METHOD, ENVELOPES_APPLIED_PRICE, ENVELOPES_DEVIATION_PCT };
// --- Period + Shift + Applied Price - shape shared by FRAMA, DEMA, TEMA.
enum ENUM_PERIOD_SHIFT_PRICE_PARAM { PSP_PERIOD = 0, PSP_SHIFT, PSP_APPLIED_PRICE };
enum ENUM_AMA_PARAM      { AMA_PERIOD = 0, AMA_FAST_EMA_PERIOD, AMA_SLOW_EMA_PERIOD, AMA_SHIFT, AMA_APPLIED_PRICE };
enum ENUM_VIDYA_PARAM    { VIDYA_CMO_PERIOD = 0, VIDYA_EMA_PERIOD, VIDYA_SHIFT, VIDYA_APPLIED_PRICE };
// --- Period + Applied Price - shape shared by RSI, CCI, Momentum.
enum ENUM_PERIOD_PRICE_PARAM { PP_PERIOD = 0, PP_APPLIED_PRICE };
// --- Fast/Slow EMA Period + Signal Period + Applied Price - shape shared by MACD, OsMA.
enum ENUM_EMA_SIGNAL_PRICE_PARAM { ESP_FAST_EMA = 0, ESP_SLOW_EMA, ESP_SIGNAL, ESP_APPLIED_PRICE };
enum ENUM_STOCHASTIC_PARAM { STOCH_K_PERIOD = 0, STOCH_D_PERIOD, STOCH_SLOWING, STOCH_METHOD, STOCH_PRICE_FIELD };
enum ENUM_FORCE_PARAM    { FORCE_PERIOD = 0, FORCE_METHOD, FORCE_APPLIED_VOLUME };
enum ENUM_CHAIKIN_PARAM  { CHAIKIN_FAST_MA_PERIOD = 0, CHAIKIN_SLOW_MA_PERIOD, CHAIKIN_METHOD, CHAIKIN_APPLIED_VOLUME };

// Builds the per-param layout for `type`. element_type is always carried
// straight from Tang 1's schema (choices!="" -> E_COMBO_BOX) - Tang 2 does
// not re-decide that fact, only how/where to render it. row/col/field_width
// are explicitly curated per type below (this is the per-indicator layout
// the user asked to control directly, not a blanket formula).
int GetIndicatorGuiLayout(const ENUM_INDICATOR type, SIndicatorLayout &out[])
  {
   SIndicatorParam schema[];
   int total = GetIndicatorParamSchema(type, schema);
   ArrayResize(out, total);
   for(int i = 0; i < total; i++)
     {
      // --- Fallback default (used for any type not explicitly curated below):
      // --- 2-per-row pairing, matches the catalog's Period/Shift-style ordering.
      out[i].row          = i / 2;
      out[i].col          = i % 2;
      out[i].total_width  = INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W;
      out[i].field_width  = INDICATOR_PARAM_FIELD_W;
      out[i].element_type = (schema[i].choices != "") ? E_COMBO_BOX : E_TEXT_BOX;
     }
   switch(type)
     {
      //Format 
        //1. Indicator Parameter.
        //2. Row number.
        //3. Column Number.
        //4. Total Width.
        //5. Input Value for Parameter width
      case IND_MA:
         SetLayoutSlot(MA_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
         SetLayoutSlot(MA_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
         SetLayoutSlot(MA_METHOD,         1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo - wider so the option text isn't clipped
         SetLayoutSlot(MA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo - longest label drives the 180 total
         break;
      case IND_STDDEV:
         // Same shape as MA (Period/Shift/Method/Applied Price) - kept as its
         // own case (not a fallthrough) so each indicator stays independently
         // editable without touching any other type.
          SetLayoutSlot(MA_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(MA_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(MA_METHOD,         1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          SetLayoutSlot(MA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_ICHIMOKU:
         // Tenkan-sen / Kijun-sen / Senkou Span B - 3 unrelated periods,
         // one per row reads cleaner than pairing the 3rd alone on its own row.
          SetLayoutSlot(ICHIMOKU_TENKAN,    0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(ICHIMOKU_KIJUN,     1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(ICHIMOKU_SENKOU_B,  2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_SAR:
         // Step / Maximum - not a Period+Shift pair, one per row reads cleaner.
          SetLayoutSlot(SAR_STEP,    0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(SAR_MAXIMUM, 0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_BANDS:
          SetLayoutSlot(BANDS_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(BANDS_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(BANDS_DEVIATION,      1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(BANDS_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_ALLIGATOR:
         // 8 params would push a single column past the Add button (fixed at
         // 4-row height) - pair them 2-per-row like the catalog's natural
         // Jaw/Teeth/Lips period+shift grouping, same i/2,i%2 the fallback uses.
          SetLayoutSlot(JTL_JAW_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(JTL_JAW_SHIFT,      0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(JTL_TEETH_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(JTL_TEETH_SHIFT,    1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(JTL_LIPS_PERIOD,    2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(JTL_LIPS_SHIFT,     2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(JTL_METHOD,         3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          SetLayoutSlot(JTL_APPLIED_PRICE,  3, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_GATOR:
         // Same 8-param shape as Alligator (Jaw/Teeth/Lips period+shift, Method,
         // Applied Price) - own case so it stays independently editable.
          SetLayoutSlot(JTL_JAW_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(JTL_JAW_SHIFT,      0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(JTL_TEETH_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(JTL_TEETH_SHIFT,    1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(JTL_LIPS_PERIOD,    2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(JTL_LIPS_SHIFT,     2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(JTL_METHOD,         3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          SetLayoutSlot(JTL_APPLIED_PRICE,  3, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_ENVELOPES:
         // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
          SetLayoutSlot(ENVELOPES_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(ENVELOPES_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(ENVELOPES_METHOD,         2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          SetLayoutSlot(ENVELOPES_APPLIED_PRICE,  2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          SetLayoutSlot(ENVELOPES_DEVIATION_PCT,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_FRAMA:
          SetLayoutSlot(PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_DEMA:
         // Same shape as FRAMA/TEMA (Period/Shift/Applied Price) - own case.
          SetLayoutSlot(PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_TEMA:
         // Same shape as FRAMA/DEMA (Period/Shift/Applied Price) - own case.
          SetLayoutSlot(PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_AMA:
         // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
          SetLayoutSlot(AMA_PERIOD,            0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(AMA_FAST_EMA_PERIOD,   0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(AMA_SLOW_EMA_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // longest label ("Slow EMA Period") drives the 220 total
          SetLayoutSlot(AMA_SHIFT,             1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(AMA_APPLIED_PRICE,     2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_VIDYA:
          SetLayoutSlot(VIDYA_CMO_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(VIDYA_EMA_PERIOD,     0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(VIDYA_SHIFT,          1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(VIDYA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      // --- Single plain "Period" numeric field - same 1-param shape across all
      // --- of these, each kept as its own case (not grouped) so any one of
      // --- them can be retuned without touching the others. idx is always 0,
      // --- no named enum needed for a single unambiguous field.
      case IND_ADX:
          SetLayoutSlot(0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_ADXW:
          SetLayoutSlot(0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_DEMARKER:
          SetLayoutSlot(0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_RVI:
          SetLayoutSlot(0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_WPR:
          SetLayoutSlot(0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_TRIX:
          SetLayoutSlot(0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_ATR:
          SetLayoutSlot(0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_BEARS:
          SetLayoutSlot(0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_BULLS:
          SetLayoutSlot(0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_MFI:
          SetLayoutSlot(0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_MOMENTUM:
          SetLayoutSlot(PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_CCI:
         // Same shape as RSI/Momentum (Period + Applied Price) - own case.
          SetLayoutSlot(PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_RSI:
         // Same shape as CCI/Momentum (Period + Applied Price) - own case.
          SetLayoutSlot(PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_MACD:
          SetLayoutSlot(ESP_FAST_EMA,       0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(ESP_SLOW_EMA,       1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(ESP_SIGNAL,         0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(ESP_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_OSMA:
         // Same shape as MACD (Fast/Slow EMA Period, Signal Period, Applied
         // Price) - own case.
          SetLayoutSlot(ESP_FAST_EMA,       0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(ESP_SLOW_EMA,       1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(ESP_SIGNAL,         0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(ESP_APPLIED_PRICE,  2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_STOCHASTIC:
         // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
          SetLayoutSlot(STOCH_K_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(STOCH_D_PERIOD,     1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(STOCH_SLOWING,      2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(STOCH_METHOD,       0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          SetLayoutSlot(STOCH_PRICE_FIELD,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      case IND_FORCE:
          SetLayoutSlot(FORCE_PERIOD,           0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(FORCE_METHOD,           1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          SetLayoutSlot(FORCE_APPLIED_VOLUME,   1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo - "Applied Volume" drives the 210 total
          break;
      case IND_CHAIKIN:
          SetLayoutSlot(CHAIKIN_FAST_MA_PERIOD,  0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(CHAIKIN_SLOW_MA_PERIOD,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          SetLayoutSlot(CHAIKIN_METHOD,          2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          SetLayoutSlot(CHAIKIN_APPLIED_VOLUME,  3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)  // combo
          break;
      // --- Single combo "Applied Volume" field - same 1-param shape across all
      // --- of these, each kept as its own case (not grouped). idx is always 0,
      // --- no named enum needed for a single unambiguous field.
      case IND_OBV:
          SetLayoutSlot(0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_AD:
          SetLayoutSlot(0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      case IND_VOLUMES:
          SetLayoutSlot(0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W)
          break;
      // --- IND_AO, IND_AC, IND_BWMFI, IND_FRACTALS have 0 params (total=0,
      // --- the loop in ShowIndicatorParameterForm never executes) - no case needed.
      default:
         break; // default pairing is fine
     }
   return total;
  }
#undef L

class CTestComboBoxGUI : public CWndEvents
  {
   private:
      CWindow            m_Mainwindow;
      CTabs              m_tabs_main;
      CTreeView          m_treeview_SymbolTF;
      CTreeView          m_treeview_indicator;
      CTabs              m_tabs_indicator_config;

      CTextLabel         m_param_labels[INDICATOR_PARAM_SLOTS_MAX];
      CTextEdit          m_param_edits[INDICATOR_PARAM_SLOTS_MAX];
      CComboBox          m_param_combo[INDICATOR_PARAM_SLOTS_MAX];
      CButton            m_btn_add_indicator;
      ENUM_INDICATOR     m_current_param_type;
      int                m_current_param_type_li;
      int                m_type_node_li[];
      ENUM_INDICATOR     m_type_node_value[];

      bool               m_gui_created;

      int                WindowIdx(CWindow &wnd);
      bool               CreateMainWindow(const string text);
      bool               CreateTabMain(const int x_gap, const int y_gap);
      bool               CreateTreeViewSymbolTF(const int x_gap, const int y_gap);
      bool               CreateTreeViewIndicator(const int x_gap, const int y_gap);
      bool               CreateConfigDetailTabs(const int x_gap, const int y_gap);
      bool               CreateParamsTab(const int x_gap, const int y_gap);
      void               PopulateIndicatorTree(void);
      void               ShowIndicatorParameterForm(const ENUM_INDICATOR type, const int type_li);
      void               OnClickAddIndicator(void);
      bool               CreateGUI(void);

   public:
                         CTestComboBoxGUI(void);
                        ~CTestComboBoxGUI(void);
      bool               OnInitEvent(const int uninit_reason = REASON_PROGRAM);
      void               OnDeinitEvent(const int reason);
      void               OnTimerEvent(void);
      virtual void       OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
  };
#ifndef CTESTCOMBOBOXGUI_MQH_IMPLEMENTATION
#define CTESTCOMBOBOXGUI_MQH_IMPLEMENTATION

CTestComboBoxGUI::CTestComboBoxGUI(void) : m_gui_created(false)
  {
  }
CTestComboBoxGUI::~CTestComboBoxGUI(void)
  {
  }

int CTestComboBoxGUI::WindowIdx(CWindow &wnd)
  {
   for(int i = 0; i < WindowsTotal(); i++)
      if(m_windows[i] == GetPointer(wnd))
         return i;
   return 0;
  }

bool CTestComboBoxGUI::OnInitEvent(const int uninit_reason)
  {
   if(!m_gui_created)
     {
      if(!CreateGUI()) return false;
      m_gui_created = true;
     }
   return true;
  }

void CTestComboBoxGUI::OnDeinitEvent(const int reason)
  {
   if(reason != REASON_CHARTCHANGE)
      CWndEvents::Destroy();
  }

void CTestComboBoxGUI::OnTimerEvent(void)
  {
   if(::MQLInfoInteger(MQL_TESTER) || ::MQLInfoInteger(MQL_FRAME_MODE))
      return;
   CWndEvents::OnTimerEvent();
  }

bool CTestComboBoxGUI::CreateGUI(void)
  {
   if(!CreateMainWindow("Test ComboBox")) { Print(__FUNCTION__, " > CreateMainWindow failed"); return false; }
   if(!CreateTabMain(115, 43))            { Print(__FUNCTION__, " > CreateTabMain failed");    return false; }
   if(!CreateTreeViewSymbolTF(10, 22))    { Print(__FUNCTION__, " > CreateTreeViewSymbolTF failed"); return false; }
   PopulateIndicatorTree();
   if(!CreateTreeViewIndicator(10, 22))   { Print(__FUNCTION__, " > CreateTreeViewIndicator failed"); return false; }
   if(!CreateConfigDetailTabs(10 + INDICATOR_TREE_WIDTH + 4, 22)) { Print(__FUNCTION__, " > CreateConfigDetailTabs failed"); return false; }
   CWndEvents::CompletedGUI();
   // --- Hide all 8 slots ONLY AFTER CompletedGUI() - FormAvailableElementsArray()
   // --- (called inside CompletedGUI) registers only elements VISIBLE at that exact
   // --- moment into m_available_elements[], which CComboBox's click-open mechanism
   // --- depends on (its own MOUSE_MOVE handler polls focus via that array). Hiding
   // --- BEFORE CompletedGUI() would exclude them permanently, even after Show()
   // --- later - confirmed by reading FormAvailableElementsArray()'s IsVisible() filter.
   for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      m_param_labels[i].Hide();
      m_param_edits[i].Hide();
      m_param_combo[i].Hide();
     }
   // --- Debug: print the actual chart object name of slot-0 combo's button,
   // --- so we know exactly what string to expect in the click log below.
   Print("DEBUG CreateGUI > combo[0] button object name = ",
         m_param_combo[0].GetButtonPointer().CanvasPointer().ChartObjectName());
   return true;
  }

bool CTestComboBoxGUI::CreateMainWindow(const string caption_text)
  {
   CWndContainer::AddWindow(m_Mainwindow);
   m_Mainwindow.XSize(700);
   m_Mainwindow.YSize(420);
   m_Mainwindow.FontSize(9);
   m_Mainwindow.IsMovable(true);
   m_Mainwindow.ResizeMode(true);
   m_Mainwindow.CloseButtonIsUsed(true);
   if(!m_Mainwindow.CreateWindow(m_chart_id, m_subwin, caption_text, 1, 1))
      return false;
   return true;
  }

bool CTestComboBoxGUI::CreateTabMain(const int x_gap, const int y_gap)
  {
   m_tabs_main.MainPointer(m_Mainwindow);
   m_tabs_main.IsCenterText(true);
   m_tabs_main.PositionMode(TABS_TOP);
   m_tabs_main.AutoXResizeMode(true);
   m_tabs_main.AutoYResizeMode(true);
   m_tabs_main.AutoXResizeRightOffset(3);
   m_tabs_main.AutoYResizeBottomOffset(25);
   m_tabs_main.AddTab("Settings", 100);
   if(!m_tabs_main.CreateTabs(x_gap, y_gap))
      return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_tabs_main);
   return true;
  }

bool CTestComboBoxGUI::CreateTreeViewSymbolTF(const int x_gap, const int y_gap)
  {
   m_treeview_SymbolTF.MainPointer(m_Mainwindow);
   m_treeview_SymbolTF.AutoXResizeMode(false);
   m_treeview_SymbolTF.XSize(100);
   m_treeview_SymbolTF.AutoYResizeMode(true);
   m_treeview_SymbolTF.VisibleItemsTotal(15);
   m_treeview_SymbolTF.LightsHover(true);
   m_treeview_SymbolTF.AutoYResizeBottomOffset(25);
   // --- AddTreeItem() must run BEFORE CreateTreeView() - it only fills the
   // --- internal m_t_* data arrays; CreateTreeView() is what actually builds
   // --- the CTreeItem objects from whatever was accumulated so far. Calling
   // --- it first (item count still 0) makes CreateTreeView() try to select
   // --- m_items[0] on an empty array -> "array out of range" in TreeView.mqh.
   string dummy_syms[2] = {"DUMMY1", "DUMMY2"};
   for(int i = 0; i < 2; i++)
      m_treeview_SymbolTF.AddTreeItem(i, -1, dummy_syms[i],
                                       IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,
                                       i, 0, 0, 0, 0, true, true);
   if(!m_treeview_SymbolTF.CreateTreeView(x_gap, y_gap)) return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_treeview_SymbolTF);
   return true;
  }

bool CTestComboBoxGUI::CreateTreeViewIndicator(const int x_gap, const int y_gap)
  {
   // --- Fixed-width left column, directly under the Settings tab - no
   // --- CSplitContainer in between, so no resize cascade to go wrong.
   m_treeview_indicator.MainPointer(m_tabs_main);
   m_treeview_indicator.AutoXResizeMode(false);
   m_treeview_indicator.XSize(INDICATOR_TREE_WIDTH);
   m_treeview_indicator.AutoYResizeMode(true);
   m_treeview_indicator.AutoYResizeBottomOffset(25);
   m_treeview_indicator.VisibleItemsTotal(15);
   m_treeview_indicator.LightsHover(true);
   if(!m_treeview_indicator.CreateTreeView(x_gap, y_gap)) return false;
   m_tabs_main.AddToElementsArray(TEST_TAB_SETTINGS, m_treeview_indicator);
   CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_treeview_indicator);   
   return true;
  }

bool CTestComboBoxGUI::CreateConfigDetailTabs(const int x_gap, const int y_gap)
  {
   // --- Fills the remaining width to the right of the fixed-width tree.
    m_tabs_indicator_config.MainPointer(m_tabs_main);
    m_tabs_indicator_config.IsCenterText(true);
    m_tabs_indicator_config.PositionMode(TABS_TOP);
    m_tabs_indicator_config.AutoXResizeMode(true);
    m_tabs_indicator_config.AutoXResizeRightOffset(3);
    m_tabs_indicator_config.AutoYResizeMode(true);
    m_tabs_indicator_config.AutoYResizeBottomOffset(25);
    m_tabs_indicator_config.AddTab("Params", 70);
   if(!m_tabs_indicator_config.CreateTabs(x_gap, y_gap)) return false;
    m_tabs_main.AddToElementsArray(TEST_TAB_SETTINGS, m_tabs_indicator_config);
   CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_tabs_indicator_config);
   if(!CreateParamsTab(5, 5)) return false;
   m_tabs_indicator_config.CElementBase::IsVisible(true);
   m_tabs_indicator_config.ShowTabElements();
   return true;
  }

bool CTestComboBoxGUI::CreateParamsTab(const int x_gap, const int y_gap)
  {
   // --- Row-major pairing (2 params per row) instead of column-major stacking.
   // --- The catalog already orders params as logical pairs (Period,Shift /
   // --- Jaw Period,Jaw Shift,Teeth Period,Teeth Shift,...) so pairing index
   // --- i with i+1 on the same row reproduces MT5's native dialog grouping
   // --- for every indicator automatically - no per-indicator layout needed.
   for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      int row = i / 2;
      int col = i % 2;
      int x   = x_gap + col * INDICATOR_PARAM_COL_WIDTH;
      int y   = y_gap + row * 30;

      m_param_labels[i].MainPointer(m_tabs_indicator_config);
      m_tabs_indicator_config.AddToElementsArray(TEST_TAB_CONFIG_PARAMS, m_param_labels[i]);
      if(!m_param_labels[i].CreateTextLabel("", x, y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_param_labels[i]);

      m_param_edits[i].MainPointer(m_tabs_indicator_config);
      m_tabs_indicator_config.AddToElementsArray(TEST_TAB_CONFIG_PARAMS, m_param_edits[i]);
      m_param_edits[i].XSize(INDICATOR_PARAM_FIELD_W);
      // --- Same trap as CComboBox's button: CTextEdit's inner CTextBox (m_edit)
      // --- defaults its LOCAL x-offset to the outer box's x_size AT CREATION TIME
      // --- (TextEdit.mqh: "x=(m_edit.XGap()<1)? x_size : m_edit.XGap()") unless told
      // --- otherwise BEFORE CreateTextEdit() - confirmed via debug log showing the
      // --- inner textbox's canvas sitting ~90px right of the outer frame after a
      // --- later resize. Pin it to the frame's left edge like the combo button.
      m_param_edits[i].GetTextBoxPointer().XGap(1);
      if(!m_param_edits[i].CreateTextEdit("", x + INDICATOR_PARAM_LABEL_W, y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_param_edits[i]);

      m_param_combo[i].MainPointer(m_tabs_indicator_config);
      m_tabs_indicator_config.AddToElementsArray(TEST_TAB_CONFIG_PARAMS, m_param_combo[i]);
      m_param_combo[i].XSize(INDICATOR_PARAM_FIELD_W);
      m_param_combo[i].YSize(20);
      m_param_combo[i].ItemsTotal(7);
      // --- CButton inside CComboBox defaults to XSize=80 positioned at XGap=80
      // --- (sized/placed for a much wider combo) unless explicitly told otherwise
      // --- BEFORE CreateComboBox() - this is exactly how Table.mqh's own working
      // --- combo usage configures it. Without this, the button/listview end up
      // --- positioned mostly outside our narrow combo's canvas bounds.
      m_param_combo[i].GetButtonPointer().XGap(1);
      m_param_combo[i].GetButtonPointer().XSize(INDICATOR_PARAM_FIELD_W);
      m_param_combo[i].GetButtonPointer().LabelYGap(4);
      m_param_combo[i].GetButtonPointer().IconYGap(3);
      if(!m_param_combo[i].CreateComboBox("", x + INDICATOR_PARAM_LABEL_W, y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_param_combo[i]);
     }
   m_btn_add_indicator.MainPointer(m_tabs_indicator_config);
   m_tabs_indicator_config.AddToElementsArray(TEST_TAB_CONFIG_PARAMS, m_btn_add_indicator);
   m_btn_add_indicator.AutoXResizeMode(false);
   m_btn_add_indicator.XSize(70);
   m_btn_add_indicator.BackColor(clrDodgerBlue);
   m_btn_add_indicator.BackColorHover(clrRoyalBlue);
   m_btn_add_indicator.BackColorPressed(clrBlue);
   m_btn_add_indicator.LabelColor(clrWhite);
   m_btn_add_indicator.BorderColor(clrBlue);
   if(!m_btn_add_indicator.CreateButton("Add", x_gap, y_gap + INDICATOR_PARAM_ROWS * 30 + 10))
      return false;
   CWndContainer::AddToElementsArray(WindowIdx(m_Mainwindow), m_btn_add_indicator);

   for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      m_param_labels[i].Update(true);
      m_param_edits[i].Update(true);
     }
   m_btn_add_indicator.Update(true);
   return true;
  }

void CTestComboBoxGUI::PopulateIndicatorTree(void)
  {
   string group_names[4] = {"Trend", "Oscillator", "Volumes", "Arrows"};
   ENUM_INDICATOR_GROUP group_values[4] = {INDICATOR_GROUP_TREND, INDICATOR_GROUP_OSCILLATOR, INDICATOR_GROUP_VOLUMES, INDICATOR_GROUP_ARROWS};

   SIndicatorCatalogItem catalog[];
   GetIndicatorCatalog(catalog);
   for(int g = 0; g < 4; g++)
     {
      int root_li = m_treeview_indicator.ItemsTotal();
      m_treeview_indicator.AddTreeItem(root_li, -1, group_names[g],
                                        IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,
                                        g, 0, 0, 0, 0, true, true);
      int k = 0;
      for(int i = 0; i < ArraySize(catalog); i++)
        {
         if(catalog[i].group != group_values[g]) continue;
         int child_li = m_treeview_indicator.ItemsTotal();
         m_treeview_indicator.AddTreeItem(child_li, root_li, catalog[i].name,
                                           IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP,
                                           k, 1, g, 0, 0, true, true);
         int sz = ArraySize(m_type_node_li);
         ArrayResize(m_type_node_li, sz + 1);
         ArrayResize(m_type_node_value, sz + 1);
         m_type_node_li[sz]    = child_li;
         m_type_node_value[sz] = catalog[i].type;
         k++;
        }
     }
  }

void CTestComboBoxGUI::ShowIndicatorParameterForm(const ENUM_INDICATOR type, const int type_li)
  {
   m_current_param_type    = type;
   m_current_param_type_li = type_li;

   SIndicatorParam schema[];
   int total = GetIndicatorParamSchema(type, schema);

   // --- Tang 2 layout - decided BEFORE we touch a single control, separate
   // --- from Tang 1's data schema. Drives both position AND which control renders.
   SIndicatorLayout layout[];
   GetIndicatorGuiLayout(type, layout);

   const int x_gap = 5, y_gap = 5;
   for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      if(i < total)
        {
         int x = x_gap + layout[i].col * INDICATOR_PARAM_COL_WIDTH;
         int y = y_gap + layout[i].row * 30;

         // --- Reposition label/edit/combo to this type's layout slot. Moving()
         // --- reads the CANVAS's own XGap/YGap (not just the element's), and
         // --- skips repositioning hidden elements by default - see CElement::Moving().
         m_param_labels[i].XGap(x); m_param_labels[i].CanvasPointer().XGap(x);
         m_param_labels[i].YGap(y); m_param_labels[i].CanvasPointer().YGap(y);
         m_param_labels[i].LabelText(schema[i].name);
         m_param_labels[i].Show();
         m_param_labels[i].Moving();

         // --- Field starts after (total_width - field_width) px of label room.
         // --- Keeping total_width equal across a type's rows is what makes the
         // --- field line up at the same right edge regardless of label length.
         int fx = x + (layout[i].total_width - layout[i].field_width);
         if(layout[i].element_type == E_COMBO_BOX)
           {
            string parts[];
            int n = StringSplit(schema[i].choices, '|', parts);
            m_param_combo[i].GetListViewPointer().Rebuilding(n);
            for(int p = 0; p < n; p++)
               m_param_combo[i].SetValue(p, parts[p]);
            int def_idx = (int)StringToInteger(schema[i].default_value);
            if(def_idx >= 0 && def_idx < n) m_param_combo[i].SelectItem(def_idx);
            // --- SetValue()/Rebuilding() default redraw=false - they only store
            // --- the data, they never paint it. Same trap as CSplitContainer's
            // --- separator: must force an element-level Update(true) (-> Draw())
            // --- or the dropdown list stays visually blank even though it has items.
            m_param_combo[i].GetListViewPointer().Update(true);
            // --- XSize() alone never touches the canvas bitmap (logical field
            // --- only) - same trap as CSplitContainer's panel1. Must also resize
            // --- the canvas + the internal button to actually change width on screen.
            int cw = layout[i].field_width;
            m_param_combo[i].XSize(cw);
            m_param_combo[i].CanvasPointer().XSize(cw);
            m_param_combo[i].CanvasPointer().Resize(cw, m_param_combo[i].CanvasPointer().YSize());
            // --- Use built-in ChangeSize to properly resize the button and its image group gap (dropdown arrow position)
            m_param_combo[i].GetButtonPointer().ChangeSize(cw, m_param_combo[i].GetButtonPointer().YSize());
            // --- ComboBox.mqh's CreateButton() computes IconXGap ONCE at creation
            // --- time as (x_size-18), using whatever x_size the button had THEN
            // --- (90, from INDICATOR_PARAM_FIELD_W) - it never re-tracks later
            // --- resizes. Left stale, the dropdown arrow icon stays pinned at the
            // --- OLD x=72 regardless of how narrow/wide the button becomes now,
            // --- which is what made the box look like it had no closed right edge.
            // --- Recompute it here using the Library's own formula every resize.
            m_param_combo[i].GetButtonPointer().IconXGap(cw - 18);
            // --- Also resize the dropdown list view to match the combo width
            m_param_combo[i].GetListViewPointer().ChangeSize(cw, m_param_combo[i].GetListViewPointer().YSize());
            m_param_combo[i].XGap(fx); m_param_combo[i].CanvasPointer().XGap(fx);
            m_param_combo[i].YGap(y);  m_param_combo[i].CanvasPointer().YGap(y);
            m_param_combo[i].Draw();
            m_param_combo[i].Show();
            m_param_combo[i].Moving();
            // --- DEBUG: dump actual on-screen position of the combo's own canvas
            // --- vs its inner button's canvas (the visible "EMA"/"Close" box is
            // --- the BUTTON's canvas, not the combo's outer one) to see which one
            // --- is not tracking fx correctly.
            Print("DEBUG POS combo i=", i, " fx=", fx, " y=", y,
                  " combo.XGap=", m_param_combo[i].XGap(),
                  " combo.canvas.XGap=", m_param_combo[i].CanvasPointer().XGap(),
                  " combo.canvas.XDISTANCE=", ObjectGetInteger(0, m_param_combo[i].CanvasPointer().ChartObjectName(), OBJPROP_XDISTANCE),
                  " combo.canvas.XSIZE=", ObjectGetInteger(0, m_param_combo[i].CanvasPointer().ChartObjectName(), OBJPROP_XSIZE),
                  " combo.canvas.CORNER=", ObjectGetInteger(0, m_param_combo[i].CanvasPointer().ChartObjectName(), OBJPROP_CORNER),
                  " button.XGap=", m_param_combo[i].GetButtonPointer().XGap(),
                  " button.canvas.XGap=", m_param_combo[i].GetButtonPointer().CanvasPointer().XGap(),
                  " button.canvas.XDISTANCE=", ObjectGetInteger(0, m_param_combo[i].GetButtonPointer().CanvasPointer().ChartObjectName(), OBJPROP_XDISTANCE),
                  " button.canvas.XSIZE=", ObjectGetInteger(0, m_param_combo[i].GetButtonPointer().CanvasPointer().ChartObjectName(), OBJPROP_XSIZE),
                  " button.canvas.CORNER=", ObjectGetInteger(0, m_param_combo[i].GetButtonPointer().CanvasPointer().ChartObjectName(), OBJPROP_CORNER),
                  " button.canvas.NAME=", m_param_combo[i].GetButtonPointer().CanvasPointer().ChartObjectName(),
                  // --- DEBUG: the HIT-TEST region used by CheckMouseFocus() is
                  // --- CElementBase's OWN X()/X2()/Y()/Y2() (m_x/m_x_size fields) -
                  // --- a SEPARATE set of numbers from the canvas chart-object's
                  // --- XDISTANCE/XSIZE checked above. Compare them directly to see
                  // --- if they fell out of sync after the resize (which would
                  // --- explain clicks landing on CWindow instead of CComboBox/CButton).
                  " combo.X=", m_param_combo[i].X(), " combo.X2=", m_param_combo[i].X2(),
                  " combo.Y=", m_param_combo[i].Y(), " combo.Y2=", m_param_combo[i].Y2(),
                  " button.X=", m_param_combo[i].GetButtonPointer().X(), " button.X2=", m_param_combo[i].GetButtonPointer().X2(),
                  " button.Y=", m_param_combo[i].GetButtonPointer().Y(), " button.Y2=", m_param_combo[i].GetButtonPointer().Y2());
            m_param_edits[i].Hide();
           }
         else
           {
            // --- is_size_adjustment=false: SetValue() defaults to TRUE, which
            // --- calls CorrectSize() and shrinks the box to fit the value text
            // --- (a 1-digit default like "8" collapses the box to almost
            // --- nothing, looking like a stray checkbox icon). Keep our explicit
            // --- per-layout field_width instead.
            m_param_edits[i].SetValue(schema[i].default_value, false);
            int ew = layout[i].field_width;
            m_param_edits[i].XSize(ew);
            m_param_edits[i].CanvasPointer().XSize(ew);
            m_param_edits[i].CanvasPointer().Resize(ew, m_param_edits[i].CanvasPointer().YSize());
            // --- Use built-in ChangeSize to properly resize the inner CTextBox canvas, area width, and visible width
            m_param_edits[i].GetTextBoxPointer().ChangeSize(ew, m_param_edits[i].GetTextBoxPointer().YSize());
            m_param_edits[i].XGap(fx); m_param_edits[i].CanvasPointer().XGap(fx);
            m_param_edits[i].YGap(y);  m_param_edits[i].CanvasPointer().YGap(y);
            m_param_edits[i].Draw();
            // --- The visible VALUE text is painted by the inner CTextBox
            // --- (m_edit), which has its own separate canvas - NOT by the outer
            // --- CTextEdit's Draw()/Update(). Normally SetValue()'s default
            // --- CorrectSize() path repaints it as a side effect of resizing;
            // --- since we pass is_size_adjustment=false (to stop the auto-shrink
            // --- bug), we must explicitly force that inner repaint ourselves,
            // --- or the box keeps showing whatever value the PREVIOUSLY selected
            // --- indicator left behind (confirmed: stale "0.02"/"0.2" from PSAR
            // --- still showing after switching to MA).
            m_param_edits[i].GetTextBoxPointer().Update(true);
            m_param_edits[i].Update(true);
            m_param_edits[i].Show();
            m_param_edits[i].Moving();
            // --- DEBUG: same dump as the combo branch above, for direct comparison.
            Print("DEBUG POS edit  i=", i, " fx=", fx, " y=", y,
                  " edit.XGap=", m_param_edits[i].XGap(),
                  " edit.canvas.XGap=", m_param_edits[i].CanvasPointer().XGap(),
                  " edit.canvas.XDISTANCE=", ObjectGetInteger(0, m_param_edits[i].CanvasPointer().ChartObjectName(), OBJPROP_XDISTANCE),
                  " edit.canvas.XSIZE=", ObjectGetInteger(0, m_param_edits[i].CanvasPointer().ChartObjectName(), OBJPROP_XSIZE),
                  " edit.canvas.CORNER=", ObjectGetInteger(0, m_param_edits[i].CanvasPointer().ChartObjectName(), OBJPROP_CORNER),
                  " edit.canvas.NAME=", m_param_edits[i].CanvasPointer().ChartObjectName(),
                  // --- The inner CTextBox (m_edit) paints the VALUE text on its OWN
                  // --- separate canvas - compare its real on-screen position too.
                  " innerbox.canvas.XDISTANCE=", ObjectGetInteger(0, m_param_edits[i].GetTextBoxPointer().CanvasPointer().ChartObjectName(), OBJPROP_XDISTANCE),
                  " innerbox.canvas.XSIZE=", ObjectGetInteger(0, m_param_edits[i].GetTextBoxPointer().CanvasPointer().ChartObjectName(), OBJPROP_XSIZE),
                  " innerbox.canvas.CORNER=", ObjectGetInteger(0, m_param_edits[i].GetTextBoxPointer().CanvasPointer().ChartObjectName(), OBJPROP_CORNER),
                  " innerbox.canvas.NAME=", m_param_edits[i].GetTextBoxPointer().CanvasPointer().ChartObjectName(),
                  // --- DEBUG: CTextBox::DrawBorder() uses OBJPROP_XOFFSET (not 0) as
                  // --- the border's left edge, unlike CButton's simple 0-based border.
                  // --- If XOFFSET is stale from creation time (90px canvas) while the
                  // --- canvas is now narrower, the border's right edge would compute
                  // --- past the canvas's own bounds and get clipped off - check it.
                  " innerbox.canvas.XOFFSET=", ObjectGetInteger(0, m_param_edits[i].GetTextBoxPointer().CanvasPointer().ChartObjectName(), OBJPROP_XOFFSET));
            m_param_combo[i].Hide();
           }
        }
      else
        {
         m_param_labels[i].Hide();
         m_param_edits[i].Hide();
         m_param_combo[i].Hide();
        }
      m_param_labels[i].Update(true);
      m_param_edits[i].Update(true);
      m_param_combo[i].GetButtonPointer().Update(true);
     }
   Print("DEBUG ShowIndicatorParameterForm > type=", EnumToString(type), " total=", total,
         " combo[0..", total - 1, "] button names printed once in CreateGUI above for reference");
  }

void CTestComboBoxGUI::OnClickAddIndicator(void)
  {
   Print("TODO: Add to Tang 1 (CTimeSeriesEngine.ApplyIndicatorToAllSeries) - type=",
         EnumToString(m_current_param_type));
   Print("TODO: show on Tang 3 (ChartIndicatorAdd) once Tang 1 confirms creation");
  }

void CTestComboBoxGUI::OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   // --- Debug: log every non-mouse-move event so we can see EXACTLY what
   // --- fires (or doesn't) when the combo's dropdown-arrow button is clicked.
   if(id != CHARTEVENT_MOUSE_MOVE)
      Print("DEBUG OnEvent > id=", id, " lparam=", lparam, " dparam=", dparam, " sparam=", sparam);

   if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_treeview_indicator.Id())
     {
      int li = (int)dparam;
      if(li < 0 || li >= m_treeview_indicator.ItemsTotal()) return;
      for(int i = 0; i < ArraySize(m_type_node_li); i++)
         if(m_type_node_li[i] == li)
           {
            ShowIndicatorParameterForm(m_type_node_value[i], li);
            break;
           }
      return;
     }

   // --- CONFIRMED via debug log: standalone CComboBox click works fine through
   // --- the framework's normal MOUSE_MOVE-polling mechanism (CButton's own
   // --- focus/press tracking fires ON_CLICK_BUTTON -> CComboBox handles it ->
   // --- ChangeComboBoxListState() -> we see ON_CLICK_COMBOBOX_BUTTON echo back).
   // --- CHARTEVENT_OBJECT_CLICK never fires for canvas-based controls in this
   // --- framework at all, so no workaround is needed here. Real bug was that
   // --- the listview's items were never actually painted - see ShowIndicatorParameterForm().

   if(id == CHARTEVENT_CUSTOM + ON_CLICK_BUTTON && lparam == m_btn_add_indicator.Id())
     {
      OnClickAddIndicator();
      return;
     }
  }

#endif // CTESTCOMBOBOXGUI_MQH_IMPLEMENTATION
#endif // __TESTCOMBOBOXGUI_MQH__
