#property indicator_chart_window
#property indicator_buffers 4 // Utilizes 4 buffers (2 for data, 2 for colors)
#property indicator_plots   2 // Two plots: one for upward pinbars, one for downward pinbars
// Plot for Upward Pinbar (Upward Arrow)
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrLime
#property indicator_width1  2
#property indicator_label1  "Upward Pinbar"
// Plot for Downward Pinbar (Downward Arrow)
#property indicator_type2   DRAW_COLOR_ARROW
#property indicator_color2  clrRed
#property indicator_width2  2
#property indicator_label2  "Downward Pinbar"

input int  BarCount = 0; // BarCount - number of bars to process, 0 = all bars.
input int  ArrowOffset = 5; // ArrowOffset - larger values increase distance from arrows to candles.
input bool EnableAlerts = true; // Enable Alerts
input bool EnableEmailAlerts = false; // Enable Email Alerts (set up SMTP in Tools->Options->Emails)
input bool EnablePushNotifications = false; // Enable Push Notifications (set up in Tools->Options->Notifications)
input bool UseCustomConfig = false; // Use Custom Configuration - if true, apply parameters below:
input double CustomMaxTailBodyRatio = 0.33; // Max ratio of tail body to candle length
input double CustomTailBodyPlacement = 0.4; // Position of body in tail candle (e.g., top/bottom 40%)
input bool   CustomPrevCandleOpposite = true; // true = Previous candle direction opposes pattern
input bool   CustomTailSameDirection = false; // true = Tail candle direction matches pattern
input bool   CustomTailBodyWithinPrevBody = false; // true = Tail body is within previous candle body
input double CustomPrevCandleMinBodyRatio = 0.1; // Min ratio of previous candle body to its length
input double CustomTailProtrusion = 0.5; // Min protrusion of tail candle relative to its length
input double CustomTailBodyToPrevBody = 1; // Max ratio of tail body to previous candle body
input double CustomTailLengthToPrevLength = 0; // Min ratio of tail candle length to previous candle length
input double CustomPrevCandleDepth = 0.1; // Min depth of previous candle relative to its length
input int    CustomMinTailLength = 1; // Minimum length of tail candle in points

// Indicator buffers
double UpwardPinbar[];
double UpwardColor[];
double DownwardPinbar[];
double DownwardColor[];

// Global variables
int    LastProcessedBars = 0;
double MaxTailBodyRatio = 0.33;
double TailBodyPlacement = 0.4;
bool   PrevCandleOpposite = true;
bool   TailSameDirection = false;
bool   TailBodyWithinPrevBody = false;
double PrevCandleMinBodyRatio = 0.1;
double TailProtrusion = 0.5;
double TailBodyToPrevBody = 1;
double TailLengthToPrevLength = 0;
double PrevCandleDepth = 0.1;
int    MinCandleLength = 1;

void OnInit()
{
    // Configure buffers
    SetIndexBuffer(0, UpwardPinbar, INDICATOR_DATA);
    SetIndexBuffer(1, UpwardColor, INDICATOR_COLOR_INDEX);
    SetIndexBuffer(2, DownwardPinbar, INDICATOR_DATA);
    SetIndexBuffer(3, DownwardColor, INDICATOR_COLOR_INDEX);
    
    ArraySetAsSeries(UpwardPinbar, true);
    ArraySetAsSeries(UpwardColor, true);
    ArraySetAsSeries(DownwardPinbar, true);
    ArraySetAsSeries(DownwardColor, true);

    // Set up Upward Pinbar plot (Up Arrow, code 233)
    PlotIndexSetInteger(0, PLOT_ARROW, 233);
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetString(0, PLOT_LABEL, "Upward Pinbar");

    // Set up Downward Pinbar plot (Down Arrow, code 234)
    PlotIndexSetInteger(1, PLOT_ARROW, 234);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetString(1, PLOT_LABEL, "Downward Pinbar");

    if (UseCustomConfig)
    {
        MaxTailBodyRatio = CustomMaxTailBodyRatio;
        TailBodyPlacement = CustomTailBodyPlacement;
        PrevCandleOpposite = CustomPrevCandleOpposite;
        TailSameDirection = CustomTailSameDirection;
        PrevCandleMinBodyRatio = CustomPrevCandleMinBodyRatio;
        TailProtrusion = CustomTailProtrusion;
        TailBodyToPrevBody = CustomTailBodyToPrevBody;
        TailLengthToPrevLength = CustomTailLengthToPrevLength;
        PrevCandleDepth = CustomPrevCandleDepth;
        MinCandleLength = CustomMinTailLength;
    }
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &tickvolume[],
                const long &volume[],
                const int &spread[])
{
    int BarsToProcess;
    double TailLength, TailBody, PrevCandleBody, PrevCandleLength;

    ArraySetAsSeries(Open, true);
    ArraySetAsSeries(High, true);
    ArraySetAsSeries(Low, true);
    ArraySetAsSeries(Close, true);

    if (LastProcessedBars == rates_total) return rates_total;
    BarsToProcess = rates_total - LastProcessedBars;
    if ((BarCount > 0) && (BarsToProcess > BarCount)) BarsToProcess = BarCount;
    LastProcessedBars = rates_total;
    if (BarsToProcess == rates_total) BarsToProcess--;

    // Initialize buffers
    UpwardPinbar[0] = EMPTY_VALUE;
    DownwardPinbar[0] = EMPTY_VALUE;

    for (int i = BarsToProcess; i >= 1; i--)
    {
        // Reset buffers for each bar
        UpwardPinbar[i] = EMPTY_VALUE;
        DownwardPinbar[i] = EMPTY_VALUE;

        // Skip if no previous candle exists for the leftmost bar
        if (i == rates_total - 1) continue;

        // Parameters for tail and previous candles
        TailLength = High[i] - Low[i];
        if (TailLength < MinCandleLength * _Point) continue; // Tail candle too short
        if (TailLength == 0) TailLength = _Point;
        PrevCandleLength = High[i + 1] - Low[i + 1];
        if (PrevCandleLength == 0) PrevCandleLength = _Point;
        TailBody = MathAbs(Open[i] - Close[i]);
        if (TailBody == 0) TailBody = _Point;
        PrevCandleBody = MathAbs(Open[i + 1] - Close[i + 1]);
        if (PrevCandleBody == 0) PrevCandleBody = _Point;

        // Downward Pinbar
        if (High[i] - High[i + 1] >= TailLength * TailProtrusion) // Tail protrusion check
        {
            if (TailBody / TailLength <= MaxTailBodyRatio) // Body-to-candle length ratio
            {
                if (1 - (High[i] - MathMax(Open[i], Close[i])) / TailLength < TailBodyPlacement) // Body in lower part
                {
                    if (!PrevCandleOpposite || Close[i + 1] > Open[i + 1]) // Previous candle bullish if required
                    {
                        if (!TailSameDirection || Close[i] < Open[i]) // Tail bearish if required
                        {
                            if (PrevCandleBody / PrevCandleLength >= PrevCandleMinBodyRatio) // Previous candle body ratio
                            {
                                if ((MathMax(Open[i], Close[i]) <= High[i + 1]) && (MathMin(Open[i], Close[i]) >= Low[i + 1])) // Tail body within previous candle
                                {
                                    if (TailBody / PrevCandleBody <= TailBodyToPrevBody) // Tail body to previous body ratio
                                    {
                                        if (TailLength / PrevCandleLength >= TailLengthToPrevLength) // Tail length to previous length ratio
                                        {
                                            if (Low[i] - Low[i + 1] >= PrevCandleLength * PrevCandleDepth) // Previous candle depth check
                                            {
                                                if (!TailBodyWithinPrevBody || ((MathMax(Open[i], Close[i]) <= MathMax(Open[i + 1], Close[i + 1])) && (MathMin(Open[i], Close[i]) >= MathMin(Open[i + 1], Close[i + 1])))) // Tail body within previous body
                                                {
                                                    DownwardPinbar[i] = High[i] + ArrowOffset * _Point + TailLength / 5;
                                                    DownwardColor[i] = 0; // Use first color (clrRed)
                                                    if (i == 1) SendAlert("Downward"); // Alert for latest complete bar
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Upward Pinbar
        if (Low[i + 1] - Low[i] >= TailLength * TailProtrusion) // Tail protrusion check
        {
            if (TailBody / TailLength <= MaxTailBodyRatio) // Body-to-candle length ratio
            {
                if (1 - (MathMin(Open[i], Close[i]) - Low[i]) / TailLength < TailBodyPlacement) // Body in upper part
                {
                    if (!PrevCandleOpposite || Close[i + 1] < Open[i + 1]) // Previous candle bearish if required
                    {
                        if (!TailSameDirection || Close[i] > Open[i]) // Tail bullish if required
                        {
                            if (PrevCandleBody / PrevCandleLength >= PrevCandleMinBodyRatio) // Previous candle body ratio
                            {
                                if ((MathMax(Open[i], Close[i]) <= High[i + 1]) && (MathMin(Open[i], Close[i]) >= Low[i + 1])) // Tail body within previous candle
                                {
                                    if (TailBody / PrevCandleBody <= TailBodyToPrevBody) // Tail body to previous body ratio
                                    {
                                        if (TailLength / PrevCandleLength >= TailLengthToPrevLength) // Tail length to previous length ratio
                                        {
                                            if (High[i + 1] - High[i] >= PrevCandleLength * PrevCandleDepth) // Previous candle height check
                                            {
                                                if (!TailBodyWithinPrevBody || ((MathMax(Open[i], Close[i]) <= MathMax(Open[i + 1], Close[i + 1])) && (MathMin(Open[i], Close[i]) >= MathMin(Open[i + 1], Close[i + 1])))) // Tail body within previous body
                                                {
                                                    UpwardPinbar[i] = Low[i] - ArrowOffset * _Point - TailLength / 5;
                                                    UpwardColor[i] = 0; // Use first color (clrLime)
                                                    if (i == 1) SendAlert("Upward"); // Alert for latest complete bar
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return rates_total;
}

string TimeframeToString(ENUM_TIMEFRAMES P)
{
    return StringSubstr(EnumToString(P), 7);
}

void SendAlert(string direction)
{
    string period = TimeframeToString(_Period);
    if (EnableAlerts)
    {
        Alert(direction + " Pinbar detected on ", _Symbol, " @ ", period);
        PlaySound("alert.wav");
    }
    if (EnableEmailAlerts)
        SendMail(_Symbol + " @ " + period + " - " + direction + " Pinbar", direction + " Pinbar detected on " + _Symbol + " @ " + period + " as of " + TimeToString(TimeCurrent()));
    if (EnablePushNotifications)
        SendNotification(direction + " Pinbar detected on " + _Symbol + " @ " + period + " as of " + TimeToString(TimeCurrent()));
}
//+------------------------------------------------------------------+