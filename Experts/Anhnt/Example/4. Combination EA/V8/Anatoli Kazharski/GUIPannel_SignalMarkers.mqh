//+------------------------------------------------------------------+
//|                                      GUIPannel_SignalMarkers.mqh |
//| The library for the signal markers on chart                      |
//+------------------------------------------------------------------+
#ifndef CGUIPANNEL_SIGNALMARKERS_MQH
#define CGUIPANNEL_SIGNALMARKERS_MQH
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

#endif // CGUIPANNEL_SIGNALMARKERS_MQH

