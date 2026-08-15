# CTradingLevelBubble Improvement Plan
**Date**: 2026-08-14  
**Goal**: Improve bubble drag/drop experience and interaction

---

## Current Issues

### 1. **Dragbox quá nhỏ - Khó "tóm" bubble**
- Hiện tại: `drag_pad_x = 8`, `drag_pad_y = 4`
- Body width = 155px nhưng bị constraint `MathMin(body_x2, btn_x1 - 4 + drag_pad_x)` → ~130px thực tế
- User khó bắt bubble vì hit target quá hẹp
- **Location**: `DrawBubble()` function, lines ~700-710

### 2. **Price-per-pixel calculation yếu khi ChartXYToTimePrice() fail**
- Fallback dùng `SYMBOL_TRADE_TICK_SIZE` (thường 0.00001 cho Forex)
- Kéo rất xa (100+ pixels) chỉ thay đổi 0.001 USD
- User phải kéo quá nhiều để thay đổi SL/TP ý muốn
- **Location**: `OnChartEvent()` function, lines ~340-360 (drag-start block)

### 3. **Không có visual feedback khi hover**
- Dragbox đã được register nhưng không redraw khác
- User không biết bubble "grabable" cho đến khi click
- Mouse cursor không change
- **Location**: `DrawBubble()` - không có hover state render

### 4. **SL/TP validation thiếu**
- `ModifyAll()` không check SL/TP hợp lệ
- Không check min distance từ entry price
- Có thể set SL = TP → lỗi
- **Location**: `ModifyAll()` function, lines ~920-940

---

## Proposed Solutions

### **Solution 1: Expand dragbox padding** ⭐ EASY
**File**: TradingLevelBubble.mqh  
**Function**: `DrawBubble()`  

**Current code**:
```cpp
int drag_pad_x = 8;
int drag_pad_y = 4;
```

**Change to**:
```cpp
int drag_pad_x = 25;  // Expand from 8 to 25px
int drag_pad_y = 12;  // Expand from 4 to 12px
```

**Why**: Tăng dragbox area 3x → dễ bắt hơn, user-friendly hơn

---

### **Solution 2: Better price-per-pixel fallback** ⭐ MEDIUM
**File**: TradingLevelBubble.mqh  
**Function**: `OnChartEvent()` - drag-start block  

**Current fallback**:
```cpp
else
{
    ENUM_POSITION_TYPE dir = is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
    m_drag_price_anchor = is_sl ? GetSL(dir) : GetTP(dir);
    m_price_per_pixel = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
}
```

**Change to** (calculate from visible chart range):
```cpp
else
{
    ENUM_POSITION_TYPE dir = is_buy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
    m_drag_price_anchor = is_sl ? GetSL(dir) : GetTP(dir);
    
    // Calculate from visible chart price range instead of tick size
    double high = ChartGetDouble(0, CHART_PRICE_MAX);
    double low  = ChartGetDouble(0, CHART_PRICE_MIN);
    int chart_h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
    
    if(chart_h > 0 && high > low)
        m_price_per_pixel = (high - low) / chart_h;
    else
        m_price_per_pixel = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
}
```

**Why**: 
- Dùng visible price range → price-per-pixel phù hợp zoom level
- Kéo 50px thay đổi ~50 pips (thay vì 0.001 USD cũ)
- Rõ ràng hơn cho user

---

### **Solution 3: Add hover visual feedback** ⭐ MEDIUM
**File**: TradingLevelBubble.mqh  

**Step 3.1**: Add property trong DECLARATION (private section):
```cpp
int m_hover_dragbox_idx;  // -1 = not hovering, 0-3 = bubble type index
```

**Step 3.2**: Initialize trong constructor:
```cpp
m_hover_dragbox_idx(-1)  // add to initialization list
```

**Step 3.3**: Update hover state trong `OnPoll()`:
```cpp
// Inside the loop where you check over_now:
m_hover_dragbox_idx = -1;  // Reset first
for(int i = 0; i < BUBBLE_TOTAL; i++)
{
    if(!m_dragbox[i].active) continue;
    if(mx >= m_dragbox[i].x1 && mx <= m_dragbox[i].x2 &&
       my >= m_dragbox[i].y1 && my <= m_dragbox[i].y2)
    {
        m_hover_dragbox_idx = i;  // Save which bubble being hovered
        break;
    }
}
```

**Step 3.4**: Modify `DrawBubble()` signature to accept hover state:
```cpp
void DrawBubble(ENUM_BUBBLE_TYPE type, int y_pixel, bool is_hovered = false);
```

**Step 3.5**: Call with hover info từ `Draw()`:
```cpp
// Before: DrawBubble(BUBBLE_SL_BUY, y_sl);
// After:
bool hovered = (m_hover_dragbox_idx == BUBBLE_SL_BUY);
DrawBubble(BUBBLE_SL_BUY, y_sl, hovered);
```

**Step 3.6**: Render highlight trong `DrawBubble()` nếu hovered:
```cpp
// After drawing the bubble body:
if(is_hovered)
{
    uint hover_clr = ColorToARGB(clrYellow, 100);  // Semi-transparent yellow
    m_canvas.FillRectangle(body_x1, body_y1, body_x2, body_y2, hover_clr);
    // Or thicken border:
    m_canvas.Rectangle(body_x1-2, body_y1-2, body_x2+2, body_y2+2, 
                       ColorToARGB(clrYellow));
}
```

**Why**: User thấy visual cue khi bubble "grabbable"

---

### **Solution 4: Add SL/TP validation** ⭐ HARD
**File**: TradingLevelBubble.mqh  

**Step 4.1**: Add helper method trong DECLARATION (private section):
```cpp
bool IsValidModifyPrice(ENUM_BUBBLE_TYPE type, double new_price);
```

**Step 4.2**: Implement method trước `ModifyAll()`:
```cpp
bool CTradingLevelBubble::IsValidModifyPrice(ENUM_BUBBLE_TYPE type, double new_price)
{
    if(m_market == NULL) return false;
    
    ENUM_POSITION_TYPE dir = (type <= BUBBLE_TP_BUY) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
    bool is_sl = (type == BUBBLE_SL_BUY || type == BUBBLE_SL_SELL);
    bool is_buy = (type == BUBBLE_SL_BUY || type == BUBBLE_TP_BUY);
    
    double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double min_distance = tick_size * 10;  // At least 10 ticks away from entry
    
    CArrayObj *list = m_market.GetList();
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_STATUS, ORDER_STATUS_MARKET_POSITION, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_SYMBOL, _Symbol, EQUAL);
    list = CTradingSelect::ByOrderProperty(list, ORDER_PROP_TYPE, (long)dir, EQUAL);
    
    if(list == NULL || list.Total() == 0) return false;
    
    // Check ALL positions in this direction
    for(int i = 0; i < list.Total(); i++)
    {
        CMarketPosition *pos = (CMarketPosition*)list.At(i);
        if(pos == NULL) continue;
        
        double entry = pos.PriceOpen();
        
        // Check distance from entry
        if(MathAbs(new_price - entry) < min_distance)
            return false;  // Too close to entry
        
        // Check SL/TP relationship
        if(is_sl)
        {
            double tp = pos.TakeProfit();
            if(tp > 0)
            {
                // For BUY: SL < Entry < TP
                // For SELL: SL > Entry > TP
                if(is_buy && new_price >= tp)
                    return false;  // SL must be < TP for BUY
                if(!is_buy && new_price <= tp)
                    return false;  // SL must be > TP for SELL
            }
        }
        else  // is_tp
        {
            double sl = pos.StopLoss();
            if(sl > 0)
            {
                if(is_buy && new_price <= sl)
                    return false;  // TP must be > SL for BUY
                if(!is_buy && new_price >= sl)
                    return false;  // TP must be < SL for SELL
            }
        }
    }
    
    return true;
}
```

**Step 4.3**: Call validation trong `ModifyAll()`:
```cpp
void CTradingLevelBubble::ModifyAll(ENUM_BUBBLE_TYPE type, double new_price)
{
    if(!IsValidModifyPrice(type, new_price))
    {
        ::Print(__FUNCTION__, " > Invalid price: ", new_price, " for type ", type);
        return;  // Silent fail or add alert
    }
    
    // ... rest of existing ModifyAll code
}
```

**Why**: Prevent invalid SL/TP combinations

---

## Implementation Steps

| # | Task | Difficulty | Est. Time | Status |
|---|------|-----------|-----------|--------|
| 1 | Expand dragbox padding (Solution 1) | Easy | 5 min | ⏳ TODO |
| 2 | Better price-per-pixel (Solution 2) | Medium | 15 min | ⏳ TODO |
| 3 | Add hover feedback (Solution 3) | Medium | 30 min | ⏳ TODO |
| 4 | Add SL/TP validation (Solution 4) | Hard | 45 min | ⏳ TODO |
| 5 | Test all bubbles (Buy/Sell, SL/TP) | Medium | 20 min | ⏳ TODO |
| 6 | Test edge cases (overlap, zoom, scroll) | Medium | 30 min | ⏳ TODO |

**Total Estimated**: ~2.5 hours

---

## Testing Checklist

- [ ] Can grab bubble easily (Solution 1)
- [ ] Drag sensitivity feels natural (Solution 2)
- [ ] Bubble highlights on hover (Solution 3)
- [ ] SL/TP modifications rejected if invalid (Solution 4)
- [ ] No overlap issues after drag
- [ ] Works after chart zoom/scroll
- [ ] P&L calculation still accurate during drag
- [ ] Works with multiple positions same direction
- [ ] Edge case: only SL set (no TP) → SL bubble works
- [ ] Edge case: only TP set (no SL) → TP bubble works

---

## Notes

- **Solution 1** có thể làm ngay, low risk
- **Solution 2** nên test kỹ vì có thể ảnh hưởng trải nghiệm kéo
- **Solution 3** visual chỉ, low risk, tăng UX đáng kể
- **Solution 4** nên làm cẩn thận, có thể reject user action → cần thông báo tốt

**Next step**: Chọn solution nào sửa trước?
