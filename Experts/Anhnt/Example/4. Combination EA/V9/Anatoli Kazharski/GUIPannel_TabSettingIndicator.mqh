//+------------------------------------------------------------------+
//|                                GUIPannel_TabSettingIndicator.mqh |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_TABSETTINGINDICATOR_MQH
#define CGUIPANNEL_TABSETTINGINDICATOR_MQH
#include "GUIPannel.mqh"
  //To Add Indicator
  void CGUIPannel::SetLayoutSlot(SIndicatorLayout &out[], int idx, int r, int c, int tw, int fw)
   {
    out[idx].row         = r;
    out[idx].col         = c;
    out[idx].total_width = tw;
    out[idx].field_width = fw;
   } 
  // Builds the per-param layout for `type`. element_type is always carried
  // straight from Tang 1's schema (choices!="" -> E_COMBO_BOX) - Tang 2 does
  // not re-decide that fact, only how/where to render it. row/col/field_width
  // are explicitly curated per type below (this is the per-indicator layout
  // the user asked to control directly, not a blanket formula).
  int CGUIPannel::GetIndicatorGuiLayout(const ENUM_INDICATOR type, SIndicatorLayout &out[])
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
       SetLayoutSlot(out,MA_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,MA_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,MA_METHOD,         1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo - wider so the option text isn't clipped
       SetLayoutSlot(out,MA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo - longest label drives the 180 total
       break;
      case IND_STDDEV:
      // Same shape as MA (Period/Shift/Method/Applied Price) - kept as its
      // own case (not a fallthrough) so each indicator stays independently
      // editable without touching any other type.
        SetLayoutSlot(out,MA_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,MA_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,MA_METHOD,         1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,MA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_ICHIMOKU:
      // Tenkan-sen / Kijun-sen / Senkou Span B - 3 unrelated periods,
      // one per row reads cleaner than pairing the 3rd alone on its own row.
       SetLayoutSlot(out,ICHIMOKU_TENKAN,    0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,ICHIMOKU_KIJUN,     1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,ICHIMOKU_SENKOU_B,  2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       break;
      case IND_SAR:
      // Step / Maximum - not a Period+Shift pair, one per row reads cleaner.
        SetLayoutSlot(out,SAR_STEP,    0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,SAR_MAXIMUM, 0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_BANDS:
        SetLayoutSlot(out,BANDS_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,BANDS_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,BANDS_DEVIATION,      1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,BANDS_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_ALLIGATOR:
      // 8 params would push a single column past the Add button (fixed at
      // 4-row height) - pair them 2-per-row like the catalog's natural
      // Jaw/Teeth/Lips period+shift grouping, same i/2,i%2 the fallback uses.
        SetLayoutSlot(out,JTL_JAW_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_JAW_SHIFT,      0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_TEETH_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_TEETH_SHIFT,    1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_LIPS_PERIOD,    2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_LIPS_SHIFT,     2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_METHOD,         3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,JTL_APPLIED_PRICE,  3, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_GATOR:
      // Same 8-param shape as Alligator (Jaw/Teeth/Lips period+shift, Method,
      // Applied Price) - own case so it stays independently editable.
        SetLayoutSlot(out,JTL_JAW_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_JAW_SHIFT,      0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_TEETH_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_TEETH_SHIFT,    1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_LIPS_PERIOD,    2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_LIPS_SHIFT,     2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,JTL_METHOD,         3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,JTL_APPLIED_PRICE,  3, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_ENVELOPES:
      // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
        SetLayoutSlot(out,ENVELOPES_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,ENVELOPES_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,ENVELOPES_METHOD,         2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,ENVELOPES_APPLIED_PRICE,  2, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,ENVELOPES_DEVIATION_PCT,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  
        break;
      case IND_FRAMA:
        SetLayoutSlot(out,PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_DEMA:
      // Same shape as FRAMA/TEMA (Period/Shift/Applied Price) - own case.
        SetLayoutSlot(out,PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_TEMA:
      // Same shape as FRAMA/DEMA (Period/Shift/Applied Price) - own case.
        SetLayoutSlot(out,PSP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PSP_SHIFT,          0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PSP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_AMA:
      // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
        SetLayoutSlot(out,AMA_PERIOD,            0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,AMA_FAST_EMA_PERIOD,   0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,AMA_SLOW_EMA_PERIOD,   1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // longest label ("Slow EMA Period") drives the 220 total
        SetLayoutSlot(out,AMA_SHIFT,             1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,AMA_APPLIED_PRICE,     2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_VIDYA:
        SetLayoutSlot(out,VIDYA_CMO_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,VIDYA_EMA_PERIOD,     0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,VIDYA_SHIFT,          1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,VIDYA_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      // --- Single plain "Period" numeric field - same 1-param shape across all
      // --- of these, each kept as its own case (not grouped) so any one of
      // --- them can be retuned without touching the others. idx is always 0,
      // --- no named enum needed for a single unambiguous field.
      case IND_ADX:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_ADXW:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_DEMARKER:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_RVI:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_WPR:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_TRIX:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_ATR:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_BEARS:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_BULLS:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_MFI:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_MOMENTUM:
        SetLayoutSlot(out,PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_CCI:
      // Same shape as RSI/Momentum (Period + Applied Price) - own case.
        SetLayoutSlot(out,PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_RSI:
      // Same shape as CCI/Momentum (Period + Applied Price) - own case.
        SetLayoutSlot(out,PP_PERIOD,         0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,PP_APPLIED_PRICE,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_MACD:
       SetLayoutSlot(out,ESP_FAST_EMA,       0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,ESP_SLOW_EMA,       1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,ESP_SIGNAL,         0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
       SetLayoutSlot(out,ESP_APPLIED_PRICE,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
       break;
      case IND_OSMA:
      // Same shape as MACD (Fast/Slow EMA Period, Signal Period, Applied
      // Price) - own case.
        SetLayoutSlot(out,ESP_FAST_EMA,       0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,ESP_SLOW_EMA,       1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,ESP_SIGNAL,         0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,ESP_APPLIED_PRICE,  2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_STOCHASTIC:
      // 5 params - 2-per-row keeps the form within the 4-row Add-button budget.
        SetLayoutSlot(out,STOCH_K_PERIOD,     0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,STOCH_D_PERIOD,     1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,STOCH_SLOWING,      2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,STOCH_METHOD,       0, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,STOCH_PRICE_FIELD,  1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      case IND_FORCE:
        SetLayoutSlot(out,FORCE_PERIOD,           0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,FORCE_METHOD,           1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,FORCE_APPLIED_VOLUME,   1, 1, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo - "Applied Volume" drives the 210 total
        break;
      case IND_CHAIKIN:
        SetLayoutSlot(out,CHAIKIN_FAST_MA_PERIOD,  0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,CHAIKIN_SLOW_MA_PERIOD,  1, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        SetLayoutSlot(out,CHAIKIN_METHOD,          2, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        SetLayoutSlot(out,CHAIKIN_APPLIED_VOLUME,  3, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);  // combo
        break;
      // --- Single combo "Applied Volume" field - same 1-param shape across all
      // --- of these, each kept as its own case (not grouped). idx is always 0,
      // --- no named enum needed for a single unambiguous field.
      case IND_OBV:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_AD:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      case IND_VOLUMES:
        SetLayoutSlot(out,0, 0, 0, INDICATOR_PARAM_LABEL_W + INDICATOR_PARAM_FIELD_W, INDICATOR_PARAM_FIELD_W);
        break;
      // --- IND_AO, IND_AC, IND_BWMFI, IND_FRACTALS have 0 params (total=0,
      // --- the loop in ShowIndicatorParameterForm never executes) - no case needed.
      default:
        break; // default pairing is fine
     }
    return total;
   }

  // =====================================================================
  // --- Called from OnEvent when a Type-level tree node is clicked
  // =====================================================================
  void CGUIPannel::ShowIndicatorParameterForm(const ENUM_INDICATOR type, const int type_li)
   {
    m_current_param_type    = type;
    m_current_param_type_li = type_li;
    SIndicatorParam schema[];
    int total = GetIndicatorParamSchema(type, schema);
    // --- Layer 2 layout - decided BEFORE we touch a single control, separate
    // --- from Layer 1's data schema. Drives both position AND which control renders.
     SIndicatorLayout layout[];
     GetIndicatorGuiLayout(type, layout);
    // --- x_gap offsets right of the 150px indicator tree; y_gap from the tab's top.
     const int x_gap = PARAM_FORM_X, y_gap = PARAM_FORM_Y;
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
   }
  // Hides all param-form slots. Called after any ShowTabElements() that overrides our Hide().
  void CGUIPannel::HideParamSlots(void)
   {
    for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      m_param_labels[i].Hide();
      m_param_edits[i].Hide();
      m_param_combo[i].Hide();
     }     
   } 
  // =====================================================================
  // --- "Add" button click handler — converts text fields to MqlParam[]
  // =====================================================================
  void CGUIPannel::OnClickAddIndicator(void)
   {      
    SIndicatorParam schema[];
    int total = GetIndicatorParamSchema(m_current_param_type, schema);      
    if(total == 0) return;
    MqlParam params[];
    ArrayResize(params, total);
    for(int i = 0; i < total; i++)
     {
      params[i].type = schema[i].data_type;
      if(schema[i].choices != "")
       {
        // --- Enum param: read back the SELECTED TEXT, then let the Library's own
        // --- Xxx-ByDescription() (CommonDELib.mqh) resolve it to the real MQL5
        // --- enum value - no combo-row/native-value arithmetic anywhere.
         string parts[];
         int n = ::StringSplit(schema[i].choices, '|', parts);
         int sel = (int)m_param_combo[i].GetListViewPointer().SelectedItemIndex();
         string sel_text = (sel >= 0 && sel < n) ? parts[sel] : "";
         if(schema[i].choices == PRICE_CHOICES)
            params[i].integer_value = (long)AppliedPriceByDescription(sel_text);
         else if(schema[i].choices == CALCULATION_METHOD_CHOICES)
            params[i].integer_value = (long)AveragingMethodByDescription(sel_text);
         else if(schema[i].choices == VOLUME_CHOICES)
            params[i].integer_value = (long)AppliedVolumeByDescription(sel_text);
         else if(schema[i].choices == STOCH_PRICE_CHOICES)
            params[i].integer_value = (long)StochPriceByDescription(sel_text);
       }
      else if(schema[i].data_type == TYPE_DOUBLE)
       {
        params[i].double_value = StringToDouble(m_param_edits[i].GetValue());
       }
      else
       {
        params[i].integer_value = (long)StringToInteger(m_param_edits[i].GetValue());
       }      
     }
    // --- SynIndicatorPlan.md, "3 Layer Task breakdown", 2026-08-18 (Anhnt): call Layer 1 directly -
    // --- type+params are already fully built above, and Layer 1 already has TemplateExists()/
    // --- AddNewIndicatorToAllSeries() - no AddIndicatorInstance() middle-man needed. Row creation
    // --- reuses RefreshTableIndicator() (the SAME Sync mechanism CHARTCHANGE/Init already call)
    // --- instead of a bespoke single-row-append.
     if(m_time_series_engine == NULL) return;
     SIndicatorCatalogItem catalog[];
     GetIndicatorCatalog(catalog);
     string type_key, params_key;
     BuildTemplateMatchKey(m_current_param_type, params, catalog, type_key, params_key);
     if(m_time_series_engine.TemplateExists(type_key, params_key))
      {
       ::Print(__FUNCTION__, " > rejected: this template already exists");
       return;
      }
     if(!m_time_series_engine.AddNewIndicatorToAllSeries(m_current_param_type, params)) return;
     SyncIndicatorTreeViewIcons();   // full sweep + Update(true)
     RefreshTableIndicator();
   }
  // =====================================================================
  // --- Params tab: up to INDICATOR_PARAM_SLOTS_MAX (8) label+field pairs,
  // --- laid out as 2 columns x 4 rows. Each slot has BOTH a CTextEdit (plain
  // --- numeric params) and a CComboBox (enum-like params) at the same spot -
  // --- ShowIndicatorParameterForm() shows exactly one of the two per slot,
  // --- based on whether that param has choices in the schema.
  // =====================================================================  
  bool CGUIPannel::CreateAddIndicatorParaInfor(const int x_gap, const int y_gap)
   {
    const int default_x = x_gap;
    const int default_y = y_gap;
    for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
     {
      m_param_labels[i].MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_param_labels[i]);
      if(!m_param_labels[i].CreateTextLabel("", default_x, default_y)) return false;
      CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_labels[i]);

      m_param_edits[i].MainPointer(m_tabs_main_setting_config);
      m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_param_edits[i]);
      m_param_edits[i].XSize(INDICATOR_PARAM_FIELD_W);
      // --- Inner CTextBox defaults its LOCAL x-offset to the outer box's x_size at
      // --- creation time unless told otherwise BEFORE CreateTextEdit() - confirmed via
      // --- debug log (inner canvas sitting ~90px right of the outer frame after resize).
       m_param_edits[i].GetTextBoxPointer().XGap(1);
       if(!m_param_edits[i].CreateTextEdit("", default_x + INDICATOR_PARAM_LABEL_W, default_y)) return false;
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_edits[i]);

       m_param_combo[i].MainPointer(m_tabs_main_setting_config);
       m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_param_combo[i]);
       m_param_combo[i].XSize(INDICATOR_PARAM_FIELD_W);
       m_param_combo[i].YSize(20);
       m_param_combo[i].ItemsTotal(7);          // room for the largest choice list (PRICE_CHOICES)
      // --- CButton inside CComboBox defaults to XSize=80 at XGap=80 unless explicitly
      // --- told otherwise BEFORE CreateComboBox() - mirrors how CTable's own combo usage
      // --- configures it. Without this the button/listview end up outside the narrow canvas.
       m_param_combo[i].GetButtonPointer().XGap(1);
       m_param_combo[i].GetButtonPointer().XSize(INDICATOR_PARAM_FIELD_W);
       m_param_combo[i].GetButtonPointer().LabelYGap(4);
       m_param_combo[i].GetButtonPointer().IconYGap(3);
       if(!m_param_combo[i].CreateComboBox("", default_x + INDICATOR_PARAM_LABEL_W, default_y)) return false;
       CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_param_combo[i]);
      // --- Do NOT call Hide() here - CompletedGUI() (called after this function)
      // --- runs FormAvailableElementsArray() which only includes VISIBLE elements
      // --- in m_available_elements[]. Hiding early means MOUSE_MOVE events never
      // --- reach the combo button later (even after Show()), so the dropdown arrow
      // --- click silently does nothing. ShowIndicatorParameterForm() manages
      // --- show/hide correctly AFTER CompletedGUI has already registered everything.
     }
    //For Button Add
     m_btn_add_indicator.MainPointer(m_tabs_main_setting_config);
     m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_btn_add_indicator);
     m_btn_add_indicator.AutoXResizeMode(false);
     m_btn_add_indicator.XSize(80);
     m_btn_add_indicator.IconFile(IMAGE_RESOURCE_BMP16_ADD_GREEN_PNG);            
     bool created = m_btn_add_indicator.CreateButton("Add", x_gap, y_gap + INDICATOR_PARAM_ROWS * 30 + 10);
     if(!created) return false;
     CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_add_indicator);
    //For Button Save
     m_btn_save_indicator.MainPointer(m_tabs_main_setting_config);
     m_tabs_main_setting_config.AddToElementsArray(TAB_TAB_MAIN_SETTINGS_CONFIG_INDICATOR, m_btn_save_indicator);
     m_btn_save_indicator.AutoXResizeMode(false);
     m_btn_save_indicator.XSize(80);
     m_btn_save_indicator.IconFile(IMAGE_RESOURCE_BMP16_SAVE_PNG);          
     bool created_save = m_btn_save_indicator.CreateButton("Save", x_gap + 85, y_gap + INDICATOR_PARAM_ROWS * 30 + 10);
     if(!created_save) return false;
     CWndContainer::AddToElementsArray(WindowIdx(m_window_main), m_btn_save_indicator);
     for(int i = 0; i < INDICATOR_PARAM_SLOTS_MAX; i++)
      {
       m_param_labels[i].Update(true);
       m_param_edits[i].Update(true);
      }
     m_btn_add_indicator.Update(true);
     m_btn_save_indicator.Update(true);
    return true;
   }
  // --- DEAD (SynIndicatorPlan.md, "3 Layer Task breakdown", 2026-08-18): commented out, not
  // --- deleted yet (Anhnt's safety convention). All 3 former callers (OnClickAddIndicator,
  // --- ImportForeignChartIndicators, SynIndicatorOnChart's CHANGE branch) now call Layer 1
  // --- directly (TemplateExists + AddNewIndicatorToAllSeries) and reuse RefreshTableIndicator()
  // --- for row creation instead of this bespoke single-row-append - grep confirms 0 call sites left.
  /*
  void CGUIPannel::AddIndicatorInstance(const int type_li, const ENUM_INDICATOR type, MqlParam &params[])
   {
    if(m_time_series_engine == NULL || m_IndicatorsCollection == NULL) return;
     SIndicatorCatalogItem dedup_catalog[];
     GetIndicatorCatalog(dedup_catalog);
     string dedup_type_key, dedup_params_key;
     BuildTemplateMatchKey(type, params, dedup_catalog, dedup_type_key, dedup_params_key);
     if(m_time_series_engine.TemplateExists(dedup_type_key, dedup_params_key))
      {
       ::Print(__FUNCTION__, " > rejected: this template already exists");
       return;
      }
     if(!m_time_series_engine.AddNewIndicatorToAllSeries(type, params)) return;
     SyncIndicatorTreeViewIcons();   // full sweep + Update(true)
     string sym = ::Symbol();
     ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)::ChartPeriod(0);
     CArrayObj *list = m_IndicatorsCollection.GetListIndBySymbol(sym);
     list = CTimeseriesSelect::ByIndicatorProperty(list, INDICATOR_PROP_TIMEFRAME, tf, EQUAL);
     if(list == NULL || list.Total() == 0) return;
     CIndicatorDE *indicator = list.At(list.Total() - 1);
     int row = ArraySize(m_indicator_template_setting);
     if(row > 0)
       m_table_indicator_template.AddRow(row, true);
     ArrayResize(m_table_indicator_names, row + 1);
     ArrayResize(m_table_indicator_ptrs,  row + 1);
     ArrayResize(m_settings_cache_state,  row + 1);
     ArrayResize(m_indicator_template_setting, row + 1);
      SJsonIndicatorEntry empty_setting[];
      SetIndicatorTableRow(row, indicator, empty_setting);
     m_table_indicator_template.Update(true);
   }
  */
  // =====================================================================
  // --- Col 4 checkbox: Tang 2 controls Tang 3 only - never touches PureData.
  // --- The table already auto-toggled the icon before sending this event, so
  // --- SelectedImageIndex(4,row) tells us the state to APPLY (0=show, 1=hide).
  // --- Matched by ind.Handle(), not by name - two instances of the same type
  // --- with different params can share the same native chart-assigned name.
  // --- Detaches every chart line currently representing this indicator (Layer 3 mirror,
  // --- handle = join key). Shared by the per-row Hide toggle, per-row Remove, and
  // --- OnDeinitEvent's full sweep (BugNote 2026-07-18: Layer 1 indicators left shown
  // --- on chart - BBands/PSAR/AMA/hand-added MAs - were never detached on final EA
  // --- removal, only the SignalMarkers overlay was; this closes that gap for every row).
  void CGUIPannel::DetachIndicatorFromChart(CIndicatorDE *indicator)
   {
    if(indicator == NULL) return;
    CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
    if(chart == NULL) return;
    for(int win = chart.WindowsTotal() - 1; win >= 0; win--)
     {
      CChartWnd *wnd = chart.GetWindowByNum(win);
      if(wnd == NULL) continue;
      for(int i = wnd.IndicatorsTotal() - 1; i >= 0; i--)
       {
        CWndInd *wnd_ind = wnd.GetIndicatorByIndex(i);
        if(wnd_ind != NULL && LineRepresentsIndicator(wnd_ind.Handle(), indicator))
            ChartIndicatorDelete(0, win, wnd_ind.Name());
       }
     }
   }
  // --- Does this Layer 3 line represent this Layer 1 instance?
  // --- Fast path: shared slot - only lines WE attached (ChartIndicatorAdd with our own
  // --- handle). A HAND-ADDED line is a SEPARATE terminal instance with its own slot
  // --- (proven 18:58 log: line handle=17 vs owned=18 for identical SAR(0.05,0.20)),
  // --- so fall back to the template identity: type+params via IndicatorParameters.
  // --- The line's slot stays readable forever because nobody ever releases it.
  bool CGUIPannel::LineRepresentsIndicator(const int line_handle, CIndicatorDE *indicator)
   {
    if(line_handle == INVALID_HANDLE || indicator == NULL) return false;
    if(line_handle == indicator.Handle())
     {
      // --- DEBUG LineRepresentsIndicator FAST-MATCH - removed 2026-07-14, fired every row every tick
      //::Print("DEBUG CGUIPannel::LineRepresentsIndicator FAST-MATCH line_handle=", line_handle,
      //        " own_handle=", indicator.Handle());
       return true;
     }
    ENUM_INDICATOR type;
    MqlParam params[];
    if(IndicatorParameters(line_handle, type, params) < 0) return false;
    if(type != indicator.TypeIndicator()) return false;
    MqlParam own_params[];
    indicator.GetMqlParams(own_params);
    bool eq = IsEqualMqlParamArrays(own_params, params);
    return eq;
   }
  // --- True when the CURRENT chart displays this indicator instance. The Layer 3 mirror
  // --- (CChartObjCollection -> CWndInd) stores the real slot handle, and MQL5 slots are
  // --- program-wide: the line of an instance Layer 1 owns carries Layer 1's own handle
  // --- number - the handle is the exact join key (names have different formats:
  // --- chart line "SAR(0.05,0.2)" vs CIndicatorDE::ShortName "SAR(BTCUSDm,M1)").
  bool CGUIPannel::IsIndicatorShownOnChart(CIndicatorDE *indicator)
   {
    if(indicator == NULL) return false;
    CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
    if(chart == NULL) return false;
    for(int win = 0; win < chart.WindowsTotal(); win++)
    {
      CChartWnd *wnd = chart.GetWindowByNum(win);
      if(wnd == NULL) continue;
      for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
        {
        CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
        if(wnd_ind != NULL && LineRepresentsIndicator(wnd_ind.Handle(), indicator))
          {
            // --- DEBUG IsIndicatorShownOnChart - removed 2026-07-14, fired every row every tick
            //::Print("DEBUG IsIndicatorShownOnChart indicator_handle=", indicator.Handle(),
            //        " -> MATCHED line '", wnd_ind.Name(), "' handle=", wnd_ind.Handle());
            return true;
          }
        }
    }
    return false;
   } 
  // --- Layer 3 -> Layer 1/2 sync, single entry point (Anhnt, 2026-08-18, see SynIndicatorPlan.md
  // --- "3 UseCase" discussion) for the 3 ways a chart-side edit can reach here:
  // --- UseCase 1 (re-Insert an existing/possibly-hidden template by hand): ImportForeignChartIndicators()
  // --- already no-ops for this (handle already owned, or TemplateExists() true) - nothing written
  // --- to Layer 1/2; RefreshIndicatorTableShowColumn() below re-truths the Show checkbox live off
  // --- the chart scan regardless (IsIndicatorShownOnChart/LineRepresentsIndicator fall back to
  // --- type+params match, so it flips ON even if MT5 assigned the re-inserted line a new handle).
  // --- UseCase 2 (style/color only): never reaches this function's CHANGE branch at all - Library's
  // --- CChartWnd::IndicatorsChangeCheck only fires IND_CHANGE when the tracked indicator's NAME
  // --- actually disappears from the window (i.e. a real param edit assigned a new handle) - a pure
  // --- style edit is a non-event by construction, nothing to special-case here.
  // --- UseCase 3 (real param edit on chart): replace the whole old template with the new one -
  // --- former standalone HandleChartIndicatorChange() body, inlined here since this dispatch was
  // --- its only caller. Trishkin's change-check kept a COPY of the old mirror entry (old
  // --- name+handle) in m_list_ind_param and updated the live mirror entry in place with the new
  // --- name+handle at the same window/index. So: old handle -> the exact Layer 1 template to
  // --- replace; the live mirror entry at the same index -> the new params.
  void CGUIPannel::SynIndicatorOnChart(const long id)
   {
    if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_ADD)
       ImportForeignChartIndicators();
    else if(id == CHARTEVENT_CUSTOM + CHART_OBJ_EVENT_CHART_WND_IND_CHANGE && m_time_series_engine != NULL)
     {
      // --- do/while(false): break plays the role of the original method's early-return guard
      // --- clauses, so this inlined body keeps the exact same shape it had as its own function.
      do
       {
        CWndInd *old_ind = m_chart_obj_collection.GetLastChangedIndicator();
        //--- Every exit path reports itself: chart edits are rare, user-driven events and
        //--- each outcome (replace/skip/fail) is worth an audit line in the log
         if(old_ind == NULL) { ::Print(__FUNCTION__, " > no changed-indicator record"); break; }
         ::Print(__FUNCTION__, " > chart edit detected: old '", old_ind.Name(), "' handle=", old_ind.Handle(),
                  " win=", old_ind.WindowNum(), " index=", old_ind.Index());
        // A hand-added line is a SEPARATE terminal instance - OwnedInstanceOfLine falls back
        // to type+params matching. Truly foreign lines (no matching template) are skipped:
        // the ADD/import path picks the new line up by itself.
         CIndicatorDE *owned = OwnedInstanceOfLine(old_ind.Handle());
         if(owned == NULL) { ::Print(__FUNCTION__, " > line matches no Layer 1 template - skip"); break; }
         CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
         if(chart == NULL) { ::Print(__FUNCTION__, " > no CChartObj for this chart"); break; }
         CChartWnd *wnd = chart.GetWindowByNum(old_ind.WindowNum());
         if(wnd == NULL) { ::Print(__FUNCTION__, " > no CChartWnd num=", old_ind.WindowNum()); break; }
         CWndInd *new_ind = NULL;
         for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
          {
           CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
           if(wnd_ind != NULL && wnd_ind.Index() == old_ind.Index()) { new_ind = wnd_ind; break; }
          }
         if(new_ind == NULL || new_ind.Handle() == INVALID_HANDLE)
          { ::Print(__FUNCTION__, " > no mirror entry at window index ", old_ind.Index()); break; }
         ENUM_INDICATOR new_type;
         MqlParam new_params[];
         if(IndicatorParameters(new_ind.Handle(), new_type, new_params) < 0)
          { ::Print(__FUNCTION__, " > IndicatorParameters failed, err ", GetLastError()); break; }
         // --- Capture the OLD identity into plain values NOW, before RemoveIndicatorInstance
         // --- below deletes 'owned' (it matches its own template) - never dereference it after.
          ENUM_INDICATOR old_type = owned.TypeIndicator();
          MqlParam old_params[];
          owned.GetMqlParams(old_params);
          ::Print(__FUNCTION__, " > chart edit: replacing template '", old_ind.Name(),
                "' with '", new_ind.Name(), "'");
         // --- Replace = remove the old template across ALL series + add the new one across ALL
         // --- series (CIndicatorDE cannot change params in place - its handle is bound to the
         // --- old instance). SynIndicatorPlan.md, "3 Layer Task breakdown", 2026-08-18: both
         // --- sides now identity-based (RemoveIndicatorInstance/AddNewIndicatorToAllSeries take
         // --- type+params directly) - no row lookup needed at all anymore.
          RemoveIndicatorInstance(old_type, old_params);
          SIndicatorCatalogItem catalog[];
          GetIndicatorCatalog(catalog);
          string new_type_key, new_params_key;
          BuildTemplateMatchKey(new_type, new_params, catalog, new_type_key, new_params_key);
          if(m_time_series_engine.TemplateExists(new_type_key, new_params_key))
           {
            // --- New params collide with an already-existing template - the changed line just
            // --- merges into it (old row already removed above, nothing to re-add).
            ::Print(__FUNCTION__, " > new params collide with an existing template - merged, not re-added");
            break;
           }
          if(m_time_series_engine.AddNewIndicatorToAllSeries(new_type, new_params))
           {
            SyncIndicatorTreeViewIcons();
            RefreshTableIndicator();
           }
       }
      while(false);
     }
    // IND_DEL (Hide via the chart's own right-click Remove) needs no extra step above - just
    // re-truth the Show column below, same as every other branch.
    RefreshIndicatorTableShowColumn();
   }
  // --- Layer 3 -> Layer 1 import (README: 3-layer sync): an indicator is present on the MAIN
  // --- chart that Layer 1 does not know yet (added BY HAND on the chart). Rebuild its
  // --- type+params via IndicatorParameters() and feed it straight to Layer 1
  // --- (SynIndicatorPlan.md, "3 Layer Task breakdown", 2026-08-18: no AddIndicatorInstance()
  // --- middle-man - TemplateExists()/AddNewIndicatorToAllSeries() are called directly, same as
  // --- OnClickAddIndicator now does). RefreshTableIndicator() runs ONCE after the whole scan
  // --- (not per-indicator) - cheaper than N separate single-row appends, and self-corrects the
  // --- table row set from the live collection regardless of how many were imported. Idempotent:
  // --- our own ChartIndicatorAdd (Show checkbox) also fires IND_ADD, but TemplateExists() filters
  // --- it out here without log spam.
  void CGUIPannel::ImportForeignChartIndicators(void)
   {
    if(m_time_series_engine == NULL) return;
    SIndicatorCatalogItem catalog[];
    GetIndicatorCatalog(catalog);
    // Layer 3 topology comes from CChartObjCollection (the one chart observer),
    // not from raw built-in scans - README: 3-layer sync.
    CChartObj *chart = m_chart_obj_collection.GetChart(::ChartID());
    if(chart == NULL) return;
    bool imported_any = false;
    for(int win = 0; win < chart.WindowsTotal(); win++)
     {
      CChartWnd *wnd = chart.GetWindowByNum(win);
      if(wnd == NULL) continue;
      for(int k = wnd.IndicatorsTotal() - 1; k >= 0; k--)
       {
         CWndInd *wnd_ind = wnd.GetIndicatorByIndex(k);
         if(wnd_ind == NULL) continue;
         string name = wnd_ind.Name();
         // The mirror's handle is the join key: same program-wide slot number as the
         // owned instance when the line belongs to Layer 1. Never released anywhere
         // in the GUI - the sole IndicatorRelease site is ~CIndicatorDE.
          int handle = wnd_ind.Handle();
          if(handle == INVALID_HANDLE) continue;
          if(m_time_series_engine.GetIndicatorByHandle(handle) != NULL)
             continue;   // Layer 1 owns it already: nothing to import
          ENUM_INDICATOR type;
          MqlParam params[];
          int params_total = IndicatorParameters(handle, type, params);
         // Only types Layer 1 knows how to create (present in the catalog)
          bool supported = false;
          for(int c = 0; c < ArraySize(catalog); c++)
          if(catalog[c].ind_type == type) { supported = true; break; }
          if(params_total < 0 || !supported) continue;
         // --- Check against the live identity-only m_indicator_template[] mirror instead of
         // --- looping every symbol/TF instance.
          string import_type_key, import_params_key;
          BuildTemplateMatchKey(type, params, catalog, import_type_key, import_params_key);
          if(m_time_series_engine.TemplateExists(import_type_key, import_params_key))
             continue;
          ::Print(__FUNCTION__, " > importing hand-added indicator '", name, "' into Layer 1");
          // Adopt: IndicatorCreate (inside AddNewIndicatorToAllSeries) returns this very slot and
          // Layer 1 becomes its owner (released exactly once, in ~CIndicatorDE).
          if(m_time_series_engine.AddNewIndicatorToAllSeries(type, params))
             imported_any = true;
       }
     }
    if(imported_any)
     {
      SyncIndicatorTreeViewIcons();
      RefreshTableIndicator();
     }
   }
#endif // CGUIPANNEL_TABSETTINGINDICATOR_MQH
