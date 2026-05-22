//+------------------------------------------------------------------+
//|                                          GCnvPatternBitmap.mqh  |
//|                                         Copyright 2025, Anhnt   |
//+------------------------------------------------------------------+
//| CGCnvPatternBitmap extends CGCnvBitmap with pattern-specific:   |
//|   - Direction-based fill/border colors                          |
//|   - Self-calculates width/height from chart scale + price range |
//|   - DrawView() encapsulates DoEasy rectangle rendering logic    |
//|   - Belongs to CBarPattern (one bitmap per pattern instance)    |
//+------------------------------------------------------------------+
#ifndef __GCNVPATTERNBITMAP_MQH__
#define __GCNVPATTERNBITMAP_MQH__
#property strict
#include "GCnvBitmap.mqh"
//#include "..\..\Timeseries\Bars\BarSeriesPatterns\Pattern.mqh"

#ifndef CGCNVPATTERNBITMAP_MQH_DECLARATION
#define CGCNVPATTERNBITMAP_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Pattern bitmap — one per CBarPattern instance                    |
 //+------------------------------------------------------------------+
 class CGCnvPatternBitmap : public CGCnvBitmap 
  {
    private:
        ENUM_PATTERN_DIRECTION m_dir; // Pattern direction (bullish/bearish/bidirect) — drives fill color
        int m_bars_formation;         // Number of bars in formation — mirrors CPattern::m_bars_formation
        long m_chart_id_ref;          // Chart ID reference for scale/price queries
        double m_price_high;          // Pattern high price (max across all n bars) — used for CalcHeight
        double m_price_low;           // Pattern low price  (min across all n bars) — used for CalcHeight

        color FillColor(void) const;   // Fill color based on m_dir
        color BorderColor(void) const; // Border color based on m_dir

        static int CalcWidth(const long chart_id, const int bars_formation);
        static int CalcHeight(const long chart_id,
                            const double price_high, const double price_low);

    public:
        CGCnvPatternBitmap(const long chart_id, const int subwin,
                        const string name, const uint obj_id,
                        const datetime anchor_time,
                        const double price_high, const double price_low,
                        const ENUM_PATTERN_DIRECTION dir,
                        const int bars_formation);
        

        void DrawView(void);
        //--- Visibility: hide/show without deleting the chart object (no flicker on TF switch)
            void Show(void) {::ObjectSetInteger(m_chart_id_ref, this.Name(), OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);}
            void Hide(void) {::ObjectSetInteger(m_chart_id_ref, this.Name(), OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);}
            bool IsVisible(void) const {return ::ObjectGetInteger(m_chart_id_ref, this.Name(), OBJPROP_TIMEFRAMES) != OBJ_NO_PERIODS;}
        //
            void SetDirection(const ENUM_PATTERN_DIRECTION dir) {m_dir = dir;}
            ENUM_PATTERN_DIRECTION Direction(void) const {return m_dir;}
            int BarsFormation(void) const {return m_bars_formation;} // mirrors CPattern::m_bars_formation
            double PriceHigh(void) const {return m_price_high;}
            double PriceLow(void) const {return m_price_low;}
  };
#endif // CGCNVPATTERNBITMAP_MQH_DECLARATION

#ifndef CGCNVPATTERNBITMAP_MQH_IMPLEMENTATION
#define CGCNVPATTERNBITMAP_MQH_IMPLEMENTATION

int CGCnvPatternBitmap::CalcWidth(const long chart_id, const int bars_formation) {
    int slot_w = (int)(1 << (int)::ChartGetInteger(chart_id, CHART_SCALE));
    return (2 * bars_formation - 1) * slot_w + 1;
}
int CGCnvPatternBitmap::CalcHeight(const long chart_id,
                                   const double price_high, const double price_low) {
    double vis_range = ::ChartGetDouble(chart_id, CHART_PRICE_MAX) - ::ChartGetDouble(chart_id, CHART_PRICE_MIN);
    if (vis_range <= 0)
        return 12;
    int chart_h = (int)::ChartGetInteger(chart_id, CHART_HEIGHT_IN_PIXELS);
    int h = (int)::MathCeil(chart_h * (price_high - price_low) / vis_range) + 8;
    return (h < 12 ? 12 : h);
}

CGCnvPatternBitmap::CGCnvPatternBitmap(const long chart_id, const int subwin,
                                       const string name, const uint obj_id,
                                       const datetime anchor_time,
                                       const double price_high, const double price_low,
                                       const ENUM_PATTERN_DIRECTION dir,
                                       const int bars_formation) : CGCnvBitmap(GRAPH_ELEMENT_TYPE_BITMAP, NULL, NULL,
                                                                               obj_id, 0, chart_id, subwin,
                                                                               name, anchor_time, (price_high + price_low) / 2.0,
                                                                               CalcWidth(chart_id, bars_formation),
                                                                               CalcHeight(chart_id, price_high, price_low),
                                                                               clrNONE, 200) {
    m_dir = dir;
    m_bars_formation = bars_formation;
    m_chart_id_ref = chart_id;
    m_price_high = price_high;
    m_price_low = price_low;
}

color CGCnvPatternBitmap::FillColor(void) const {
    switch (m_dir) {
    case PATTERN_DIRECTION_BULLISH:
        return clrCornflowerBlue;
    case PATTERN_DIRECTION_BEARISH:
        return clrLightSalmon;
    default:
        return clrSilver;
    }
}

color CGCnvPatternBitmap::BorderColor(void) const {
    switch (m_dir) {
    case PATTERN_DIRECTION_BULLISH:
        return clrRoyalBlue;
    case PATTERN_DIRECTION_BEARISH:
        return clrCrimson;
    default:
        return clrDimGray;
    }
}

void CGCnvPatternBitmap::DrawView(void) {
    int slot_w = (int)(1 << (int)::ChartGetInteger(m_chart_id_ref, CHART_SCALE));
    int w = this.Width();
    int h = this.Height();
    int x = w / 2 - slot_w / 2; // left edge of oldest bar slot (DoEasy formula)
    this.Erase(CLR_CANV_NULL, 0);
    this.DrawRectangleFill(x, 0, w - 1, h - 1, FillColor(), 100);
    this.DrawRectangle(x, 0, w - 1, h - 1, BorderColor(), 255);
    this.Update(false);
}
#endif // CGCNVPATTERNBITMAP_MQH_IMPLEMENTATION
#endif // __GCNVPATTERNBITMAP_MQH__
