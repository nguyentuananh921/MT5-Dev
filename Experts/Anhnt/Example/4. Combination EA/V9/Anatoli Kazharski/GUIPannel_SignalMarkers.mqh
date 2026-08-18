//+------------------------------------------------------------------+
//|                                      GUIPannel_SignalMarkers.mqh |
//| The library for the signal markers on chart                      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SIGNALMARKERS_MQH
#define CGUIPANNEL_SIGNALMARKERS_MQH
#include "GUIPannel.mqh"
 // --- Attaches SignalMarkers.mq5 to this chart if not already running (checked by short
 // --- name, set via IndicatorSetString(INDICATOR_SHORTNAME,...) in the indicator's own
 // --- OnInit) - idempotent, safe to call defensively on every OnInitEvent branch, same
 // --- style as CTradingLevelBubble::EnsureCreated() being polled unconditionally.
 void CGUIPannel::EnsureMarkerIndicatorAttached(void)
  {
   int total = ::ChartIndicatorsTotal(m_chart_id, 0);
   for(int i = 0; i < total; i++)
      if(::StringFind(::ChartIndicatorName(m_chart_id, 0, i), "SignalMarkers") == 0)
         return; // already attached   
   int h = ::iCustom(NULL, 0, "Vendors\\Anhnt\\Custom Buildin\\SignalMarkers",
                      m_marker_single_indicator_buy_code, m_marker_single_indicator_sell_code,
                      m_marker_multi_indicator_buy_code, m_marker_multi_indicator_sell_code,
                      m_marker_pattern_buy_code, m_marker_pattern_sell_code,
                      m_marker_combo_buy_code, m_marker_combo_sell_code,
                      m_marker_buy_color, m_marker_sell_color, m_marker_nonrelated_color,
                    g_ea_folder);
      if(h == INVALID_HANDLE)
        {
         ::Print(__FUNCTION__, " > iCustom(SignalMarkers) failed, error ", ::GetLastError());
         return;
        }
      if(!::ChartIndicatorAdd(m_chart_id, 0, h))
         ::Print(__FUNCTION__, " > ChartIndicatorAdd(SignalMarkers) failed, error ", ::GetLastError());
  }
 // --- Detaches SignalMarkers.mq5 if attached - ChartIndicatorAdd() makes it an independent
 // --- chart program, so removing THIS EA does NOT auto-detach it. Called from
 // --- ReattachSignalMarkersIndicator() (style change) AND from OnDeinitEvent on final removal.
 // --- BugNote 2026-07-18: "SignalMarkers survives Remove EA" - the old scan-by-
 // --- ChartIndicatorsTotal()/ChartIndicatorName() approach reads 0/garbage when called from
 // --- OnDeinit() while THIS chart's own program is mid-removal (confirmed empirically: the
 // --- native Indicators List dialog showed SignalMarkers very much still attached at the
 // --- exact moment our own scan reported total=0). SignalMarkers.mq5 sets its own short name
 // --- deterministically ("SignalMarkers(" + Symbol() + ")", see SignalMarkers.mq5 line ~102) -
 // --- delete by that known name directly instead of trusting the unreliable enumeration.
 // --- ChartIndicatorDelete() itself also reports a false/error return here (confirmed
 // --- error 4022) even though the deletion genuinely takes effect - another OnDeinit-timing
 // --- artifact, not a real failure, so the return value is intentionally not checked.
 void CGUIPannel::RemoveMarkerIndicator(void)
  {
   ::ChartIndicatorDelete(m_chart_id, 0, "SignalMarkers(" + ::Symbol() + ")");
  }
 // --- Detach + re-attach with the CURRENT m_marker_* values - MT5 has no live-input-update
 // --- API for a running indicator, so a style change means recreate it.
 void CGUIPannel::ReattachSignalMarkersIndicator(void)
  {
   RemoveMarkerIndicator();
   EnsureMarkerIndicatorAttached();
  }
// --- Delete every legacy signal-arrow chart object of (sym, tf) - leftovers from the old
 // --- graphic-object drawing path (CreateSignalBuy/Sell/CreateThumbUp/Down), before the
 // --- SignalMarkers.mq5 indicator + bridge file replaced it entirely (BugNote 2026-07-16).
 // --- Kept only for migration/cleanup purposes - the new path never creates these objects.
 void CGUIPannel::PurgeSignalArrowObjects(const string sym, const string tf_string)
  {
   string prefix = ::MQLInfoString(MQL_PROGRAM_NAME) + "_sig_" + sym + "_" + tf_string + "_";
   for(int i = ::ObjectsTotal(m_chart_id) - 1; i >= 0; i--)
    {
     string obj_name = ::ObjectName(m_chart_id, i);
     if(::StringFind(obj_name, prefix) == 0)
        ::ObjectDelete(m_chart_id, obj_name);
    }
  }    
 // --- SynIndicatorPlan.md, Dot 3d, 2026-08-18: ptr source switched from m_table_indicator_ptrs[]
 // --- (SẼ XOÁ, Dot 3e) to GetIndicatorForRow(row); buy/sell read from the live
 // --- m_indicator_template_setting[row] (kept current by OnClickToggleBuy/SellSignal) instead of
 // --- the CTable icon directly - same data, one source of truth. The Bridge's own ArrayCopy'd
 // --- copy (m_template_ptrs[]/buy[]/sell[]) is untouched here - that architecture change is Dot 4.
 void CGUIPannel::SyncIndicatorTemplateSettingToBridge(void)
  {
    int tmpl_total = ArraySize(m_indicator_template_setting);
    CIndicatorDE *tmpl_ptrs[];
    bool tmpl_buy[], tmpl_sell[];

    ArrayResize(tmpl_ptrs, tmpl_total);
    ArrayResize(tmpl_buy,  tmpl_total);
    ArrayResize(tmpl_sell, tmpl_total);

    for(int row = 0; row < tmpl_total; row++)
     {
      tmpl_ptrs[row] = GetIndicatorForRow(row);
      tmpl_buy[row]  = m_indicator_template_setting[row].buy;
      tmpl_sell[row] = m_indicator_template_setting[row].sell;
     }
    m_bridge_writer.SetTemplateBuySell(tmpl_ptrs, tmpl_buy, tmpl_sell);
  }
#endif // CGUIPANNEL_SIGNALMARKERS_MQH

