✅ Closed candles: Xử lý được patterns via Library (Layer 1)
❌ Live - bar 0: Được coi như candle đã đóng với rate mỗi tick
         - bar 1: Thì là bar 1 đóng rồi.
         - Bar 2: Thì là Bar 2 đóng rồi.
   Mỗi NewBar thì phải reset lại các bar này 
    CBarPattern : public CBaseObj
    Các CBarPatternxxx đều inherit từ CBarPattern 
    Và sẽ có CBarPatternControl và các CBarPatternControlxxxx inherit từ   CBarPatternControl
    Và có một CBarPatternsControl (có chữ s) như kiểu quản lý chung các CBarPatternControl (loại không s)

 Một bar (Bar 0 hay closed) → có thể detect nhiều patterns
  SCandle patterns (1 candle)
  DCandle patterns (2 candles)
  TriCandle patterns (3 candles)
  CGUIPannel::CheckCandlePatternAlerts
    Duyệt mỗi bar series (timeframe)
    Lấy tất cả pattern controllers
    Với mỗi pattern type cần check, tìm matching controller
    Get detected patterns từ controller đó
    Lấy candle_count từ pattern object

  Với Bar 0 (live):

    Bar 0 chưa đóng → không có patterns trong GetListAllPatterns() yet
    Tạo bar_0_temp để fake như bar 0 đã đóng
    Call DetectPatternOnBar0() → pattern controllers detect trên fake bar
    Nhưng detected patterns này được store ở đâu? Chỉ trong individual CBarPatternControl objects, không vào global list
    Vậy flow đúng phải là:

    Create bar_0_temp
    Call DetectPatternOnBar0(pattern, tf, bar_0_temp) → return direction ✅
    Nhưng để lấy candle_count, cần access patterns từ individual pattern controller mà đã detect
    Nhưng GetListPatterns() là protected → ❌
    Kiểm tra lại: DetectPatternOnBar0() sau khi gọi ctrl.FindPattern(), nó có populate vào controller's pattern list không? Hay chỉ return direction thôi?


    ENUM_PATTERN_DIRECTION result = ctrl.FindPattern(bar_0_temp.time, (MqlRates&)bar_0_temp);
    return result;  // <-- Chỉ return direction, không return pattern object
- Khi Bar đóng.
   // BarSeriesDE::Refresh() 
    if(series_obj.IsNewBar(time))
     {
      // ...
      this.m_patterns_control.RefreshAll();  // <-- Detect patterns on CLOSED bar
     }
    RefreshAll() sẽ populate patterns vào m_list_all_patterns.
- Cách tiếp cận.
    Create m_list_all_patterns_live_temp (temporary list cho live bar 0)
    Khi detect pattern trên bar_0_temp, add CBarPattern vào temp list
    Extract candle_count từ temp list
    Clear temp list sau mỗi OnTick
-Method CPatternControl::GetListPatterns
        CPatternControl::CreatePattern
- Flow với Bar0
Cách flow cho live bar 0:

 Detect pattern (có direction) ✓
 Create CBarPattern object → nhưng CreatePattern() protected ❌
 Add vào temp list
 Get candle_count từ pattern object
 Hay cậu muốn:

 Create temp CBar object từ bar_0_temp?
 Sau đó call UpdatePatternList() to auto-populate?
 Rồi somehow access patterns from that?
 Flow cho Live bar 0 detection:

Lấy bar -1, bar -2 (real, đã close) từ series
Tạo bar_0_temp (fake, current OHLC)
Process cả 3 candles (bar 0, -1, -2) GIỐNG như khi bar 0 close
Gọi UpdatePatternList() hoặc tương tự để detect patterns
Extract candle_count từ detected patterns
Tức là:

1-candle patterns: chỉ dùng bar_0_temp
2-candle patterns: dùng bar_0_temp + bar -1 (closed)
3-candle patterns: dùng bar_0_temp + bar -1 + bar -2 (closed)
Implementation:


// Lấy 2 bars đã close từ series
CBar *bar_minus_1 = bar_series.GetBar(1);  // bar -1
CBar *bar_minus_2 = bar_series.GetBar(2);  // bar -2

// Giả vờ bar 0 đóng
MqlRates bar_0_temp = {...};

// Call pattern detection như khi bar close
// Extract candle_count từ detected patterns


Kết quả hiện tại:
 -Không show một alert nào từ CGUIPannel::CheckCandlePatternAlerts
 - Chỉ show alert của TF hiện tại từ CGUIPannel::CheckIndicatorAlerts