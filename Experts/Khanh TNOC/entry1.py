import time
import requests
import pandas as pd
import numpy as np
import MetaTrader5 as mt5

# ==============================================================================
# CẤU HÌNH HỆ THỐNG
# ==============================================================================
MT5_PATH = r"C:\Program Files\MetaTrader 5\terminal64.exe"

TELEGRAM_TOKEN = "8902260686:AAEr4zT2YYN52a2xcIfuJLsvVvRCKQRBZ_Q"
CHAT_IDS = ["7412847698"]

MAGIC_NUMBER = 2026888
LIMIT_OFFSET_USD = 50.0  # Khoảng cách đặt lệnh Limit cách giá hiện tại (50 USD)
TRADE_LOT = 0.01         # Khối lượng cố định 0.01 lot
FRACTAL_PERIODS = 2      # Tham số n của Williams Fractal (mặc định = 2 giống Pine Script)

# ==============================================================================
# HÀM TIỆN ÍCH & TELEGRAM
# ==============================================================================
def send_telegram(message: str):
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    for chat_id in CHAT_IDS:
        payload = {"chat_id": chat_id, "text": message, "parse_mode": "HTML"}
        try:
            requests.post(url, json=payload, timeout=10)
        except Exception as e:
            print(f"[Lỗi Telegram]: {e}")

def find_gold_symbol() -> str:
    """Tự động dò tìm mã Vàng chính xác trên sàn"""
    candidates = ["XAUUSD", "XAUUSDm", "XAUUSD.c", "GOLD", "XAUUSD_i"]
    all_symbols = mt5.symbols_get()
    if all_symbols is None:
        return None
    symbol_names = [s.name for s in all_symbols]
    for cand in candidates:
        if cand in symbol_names:
            mt5.symbol_select(cand, True)
            return cand
    for name in symbol_names:
        if "XAUUSD" in name.upper() or "GOLD" in name.upper():
            mt5.symbol_select(name, True)
            return name
    return None

# ==============================================================================
# CHỈ BÁO WILLIAMS FRACTAL (THEO LOGIC PINE SCRIPT v6)
# ==============================================================================
def get_h1_fractal_state(df_h1: pd.DataFrame, current_price: float, n: int = 2):
    """
    Tính Up Fractal và Down Fractal trên DataFrame khung H1 (sắp xếp từ cũ -> mới).
    Trả về: (state, last_up_price, last_down_price, detail_msg)
      - state: "UP_FRACTAL" | "DOWN_FRACTAL" | "BOTH" | "NONE"
    """
    total_bars = len(df_h1)
    # Cần ít nhất n nến bên trái, n nến bên phải và tối đa thêm 4 nến kiểm tra đỉnh/đáy bằng nhau
    min_required = (2 * n) + 5
    if total_bars < min_required:
        return "NONE", None, None, "Không đủ nến H1 để tính Williams Fractal"

    highs = df_h1["high"].to_numpy(dtype=float)
    lows = df_h1["low"].to_numpy(dtype=float)

    up_fractals = []    # list of (bar_index, price)
    down_fractals = []  # list of (bar_index, price)

    # Chỉ xét các nến tâm có đủ dữ liệu phía sau (tối đa n + 4 nến sau tâm)
    max_center_idx = total_bars - 1 - (n + 4)

    for idx in range(n, max_center_idx + 1):
        center_high = highs[idx]
        center_low = lows[idx]

        # --- UpFractal ---
        up_down_frontier = True
        up_0 = True
        up_1 = True
        up_2 = True
        up_3 = True
        up_4 = True

        for i in range(1, n + 1):
            up_down_frontier = up_down_frontier and (highs[idx - i] < center_high)
            up_0 = up_0 and (highs[idx + i] < center_high)
            up_1 = up_1 and (highs[idx + 1] <= center_high and highs[idx + i + 1] < center_high)
            up_2 = up_2 and (highs[idx + 1] <= center_high and highs[idx + 2] <= center_high and highs[idx + i + 2] < center_high)
            up_3 = up_3 and (highs[idx + 1] <= center_high and highs[idx + 2] <= center_high and highs[idx + 3] <= center_high and highs[idx + i + 3] < center_high)
            up_4 = up_4 and (highs[idx + 1] <= center_high and highs[idx + 2] <= center_high and highs[idx + 3] <= center_high and highs[idx + 4] <= center_high and highs[idx + i + 4] < center_high)

        flag_up_frontier = up_0 or up_1 or up_2 or up_3 or up_4
        if up_down_frontier and flag_up_frontier:
            up_fractals.append((idx, center_high))

        # --- DownFractal ---
        down_down_frontier = True
        down_0 = True
        down_1 = True
        down_2 = True
        down_3 = True
        down_4 = True

        for i in range(1, n + 1):
            down_down_frontier = down_down_frontier and (lows[idx - i] > center_low)
            down_0 = down_0 and (lows[idx + i] > center_low)
            down_1 = down_1 and (lows[idx + 1] >= center_low and lows[idx + i + 1] > center_low)
            down_2 = down_2 and (lows[idx + 1] >= center_low and lows[idx + 2] >= center_low and lows[idx + i + 2] > center_low)
            down_3 = down_3 and (lows[idx + 1] >= center_low and lows[idx + 2] >= center_low and lows[idx + 3] >= center_low and lows[idx + i + 3] > center_low)
            down_4 = down_4 and (lows[idx + 1] >= center_low and lows[idx + 2] >= center_low and lows[idx + 3] >= center_low and lows[idx + 4] >= center_low and lows[idx + i + 4] > center_low)

        flag_down_frontier = down_0 or down_1 or down_2 or down_3 or down_4
        if down_down_frontier and flag_down_frontier:
            down_fractals.append((idx, center_low))

    last_up_idx, last_up_price = up_fractals[-1] if up_fractals else (-1, None)
    last_down_idx, last_down_price = down_fractals[-1] if down_fractals else (-1, None)

    # Kiểm tra xem Up Fractal / Down Fractal gần nhất còn tồn tại (chưa bị giá phá vỡ)
    up_active = False
    down_active = False

    if last_up_price is not None:
        # Chưa có nến H1 nào sau fractal đóng cửa vượt qua đỉnh Up Fractal và giá hiện tại chưa vượt hẳn
        subsequent_highs = highs[last_up_idx + 1:]
        broken_up = (len(subsequent_highs) > 0 and np.max(subsequent_highs) > last_up_price) or (current_price > last_up_price)
        up_active = not broken_up

    if last_down_price is not None:
        # Chưa có nến H1 nào sau fractal thủng xuống dưới đáy Down Fractal và giá hiện tại chưa thủng hẳn
        subsequent_lows = lows[last_down_idx + 1:]
        broken_down = (len(subsequent_lows) > 0 and np.min(subsequent_lows) < last_down_price) or (current_price < last_down_price)
        down_active = not broken_down

    # Nếu cả 2 đều còn tồn tại, ưu tiên fractal xuất hiện gần nhất về mặt thời gian
    if up_active and down_active:
        if last_up_idx > last_down_idx:
            return "UP_FRACTAL", last_up_price, last_down_price, f"H1 đang tồn tại Up Fractal gần nhất tại {last_up_price:.2f}"
        else:
            return "DOWN_FRACTAL", last_up_price, last_down_price, f"H1 đang tồn tại Down Fractal gần nhất tại {last_down_price:.2f}"
    elif up_active:
        return "UP_FRACTAL", last_up_price, last_down_price, f"H1 đang tồn tại Up Fractal tại {last_up_price:.2f}"
    elif down_active:
        return "DOWN_FRACTAL", last_up_price, last_down_price, f"H1 đang tồn tại Down Fractal tại {last_down_price:.2f}"
    else:
        return "NONE", last_up_price, last_down_price, "H1 không còn Up/Down Fractal nào chưa bị phá vỡ"

# ==============================================================================
# THUẬT TOÁN PHÂN TÍCH KỸ THUẬT & TÍN HIỆU (THAY THẾ AI)
# ==============================================================================
def analyze_technical_signals(symbol: str):
    """
    Phân tích kỹ thuật đa khung thời gian (H1, M30, M15, M5, M3, M1)
    Dựa trên: Xu hướng EMA, Đỉnh/Đáy cục bộ (Swing High/Low), ATR và bộ lọc Williams Fractal H1.
    Trả về: ('BUY' / 'SELL' / 'NONE', entry_price, sl, tp, reason)
    """
    # Lấy dữ liệu khung H1 xác định xu hướng lớn & Williams Fractal
    rates_h1 = mt5.copy_rates_from_pos(symbol, mt5.TIMEFRAME_H1, 0, 80)
    if rates_h1 is None or len(rates_h1) < 30:
        return "NONE", 0, 0, 0, "Không đủ dữ liệu H1"
    
    df_h1 = pd.DataFrame(rates_h1)
    df_h1['EMA20'] = df_h1['close'].ewm(span=20, adjust=False).mean()
    df_h1['EMA50'] = df_h1['close'].ewm(span=50, adjust=False).mean()
    
    h1_trend = "BULLISH" if df_h1.iloc[-1]['EMA20'] > df_h1.iloc[-1]['EMA50'] else "BEARISH"

    # Lấy dữ liệu khung M5 / M15 để tìm điểm vào lệnh chi tiết
    rates_m5 = mt5.copy_rates_from_pos(symbol, mt5.TIMEFRAME_M5, 0, 40)
    if rates_m5 is None or len(rates_m5) < 30:
        return "NONE", 0, 0, 0, "Không đủ dữ liệu M5"

    df_m5 = pd.DataFrame(rates_m5)
    df_m5['EMA20'] = df_m5['close'].ewm(span=20, adjust=False).mean()
    
    # Tính ATR 14 để đo biên độ biến động
    high_low = df_m5['high'] - df_m5['low']
    high_close = np.abs(df_m5['high'] - df_m5['close'].shift())
    low_close = np.abs(df_m5['low'] - df_m5['close'].shift())
    tr = pd.concat([high_low, high_close, low_close], axis=1).max(axis=1)
    atr = tr.rolling(14).mean().iloc[-1]

    # Tìm Swing Low / Swing High gần nhất làm mốc S/R
    df_m5['Swing_High'] = df_m5['high'][(df_m5['high'] > df_m5['high'].shift(1)) & (df_m5['high'] > df_m5['high'].shift(-1))]
    df_m5['Swing_Low'] = df_m5['low'][(df_m5['low'] < df_m5['low'].shift(1)) & (df_m5['low'] < df_m5['low'].shift(-1))]
    
    recent_lows = df_m5['Swing_Low'].dropna().values
    recent_highs = df_m5['Swing_High'].dropna().values

    tick = mt5.symbol_info_tick(symbol)
    current_ask = tick.ask
    current_bid = tick.bid
    mid_price = (current_ask + current_bid) / 2.0

    # Xác định trạng thái Williams Fractal khung H1
    fractal_state, last_up_price, last_down_price, fractal_detail = get_h1_fractal_state(
        df_h1, current_price=mid_price, n=FRACTAL_PERIODS
    )

    raw_signal = "NONE"
    entry = 0.0
    sl = 0.0
    tp = 0.0
    reason = ""

    # Logic chiến lược gốc:
    # Nếu xu hướng H1 tăng (BULLISH) và M5 có tín hiệu hồi về vùng hỗ trợ / cắt lên EMA20 -> Bắt BUY LIMIT cách 50 USD
    if h1_trend == "BULLISH":
        last_close = df_m5.iloc[-1]['close']
        prev_close = df_m5.iloc[-2]['close']
        ema20_m5 = df_m5.iloc[-1]['EMA20']
        
        # Điều kiện kích hoạt Buy Limit: Giá đang nằm trên EMA20 M5 hoặc vừa bật lên từ hỗ trợ
        if last_close > ema20_m5 and prev_close <= ema20_m5:
            raw_signal = "BUY"
            entry = round(current_ask - LIMIT_OFFSET_USD, 2)
            sl = round(entry - (atr * 2.5), 2)  # Stop loss đặt cách entry 2.5 * ATR
            tp = round(entry + (LIMIT_OFFSET_USD * 1.8), 2)  # Take profit đảm bảo R:R tốt
            reason = f"Xu hướng H1 tăng (EMA20 > EMA50). Khung M5 cắt lên EMA20. Tín hiệu BUY."

    # Nếu xu hướng H1 giảm (BEARISH) và M5 hồi lên gặp kháng cự / cắt xuống EMA20 -> Bắt SELL LIMIT cách 50 USD
    elif h1_trend == "BEARISH":
        last_close = df_m5.iloc[-1]['close']
        prev_close = df_m5.iloc[-2]['close']
        ema20_m5 = df_m5.iloc[-1]['EMA20']
        
        if last_close < ema20_m5 and prev_close >= ema20_m5:
            raw_signal = "SELL"
            entry = round(current_bid + LIMIT_OFFSET_USD, 2)
            sl = round(entry + (atr * 2.5), 2)
            tp = round(entry - (LIMIT_OFFSET_USD * 1.8), 2)
            reason = f"Xu hướng H1 giảm (EMA20 < EMA50). Khung M5 cắt xuống EMA20. Tín hiệu SELL."

    if raw_signal == "NONE":
        return "NONE", 0, 0, 0, "Chưa đủ điều kiện cấu trúc kỹ thuật"

    # Áp dụng điều kiện lọc theo Williams Fractal khung H1:
    # - Nếu H1 vẫn tồn tại Up Fractal: chỉ cho phép tín hiệu SELL
    # - Nếu H1 vẫn tồn tại Down Fractal: chỉ cho phép tín hiệu BUY
    if fractal_state == "UP_FRACTAL":
        if raw_signal != "SELL":
            return "NONE", 0, 0, 0, f"Bỏ qua {raw_signal}: {fractal_detail} (H1 tồn tại Up Fractal chỉ cho phép SELL)"
        reason = f"{reason} | Lọc Fractal H1: {fractal_detail} (cho phép SELL)."
    elif fractal_state == "DOWN_FRACTAL":
        if raw_signal != "BUY":
            return "NONE", 0, 0, 0, f"Bỏ qua {raw_signal}: {fractal_detail} (H1 tồn tại Down Fractal chỉ cho phép BUY)"
        reason = f"{reason} | Lọc Fractal H1: {fractal_detail} (cho phép BUY)."
    else:
        return "NONE", 0, 0, 0, f"Bỏ qua {raw_signal}: {fractal_detail}"

    return raw_signal, entry, sl, tp, reason

# ==============================================================================
# THỰC THI LỆNH TRÊN MT5
# ==============================================================================
def place_limit_order(symbol: str, direction: str, entry: float, sl: float, tp: float):
    digits = mt5.symbol_info(symbol).digits
    entry = round(entry, digits)
    sl = round(sl, digits)
    tp = round(tp, digits)

    if direction == "BUY":
        order_type = mt5.ORDER_TYPE_BUY_LIMIT
    else:
        order_type = mt5.ORDER_TYPE_SELL_LIMIT

    request = {
        "action": mt5.TRADE_ACTION_PENDING,
        "symbol": symbol,
        "volume": TRADE_LOT,
        "type": order_type,
        "price": entry,
        "sl": sl,
        "tp": tp,
        "deviation": 30,
        "magic": MAGIC_NUMBER,
        "comment": "Pure_Algo_Limit_50USD",
        "type_time": mt5.ORDER_TIME_GTC,
        "type_filling": mt5.ORDER_FILLING_RETURN,
    }
    res = mt5.order_send(request)
    return res

# ==============================================================================
# VÒNG LẶP CHÍNH
# ==============================================================================
def main():
    if not mt5.initialize(path=MT5_PATH):
        print(f"Không thể kết nối MT5 tại {MT5_PATH}. Lỗi:", mt5.last_error())
        return

    acc_info = mt5.account_info()
    gold_symbol = find_gold_symbol()
    
    if not gold_symbol:
        print("Không tìm thấy mã Vàng trên tài khoản MT5 này!")
        mt5.shutdown()
        return

    startup_msg = (
        f"🤖 <b>BOT THUẬT TOÁN KỸ THUẬT VÀNG (NO API) ĐÃ KHỞI ĐỘNG</b>\n"
        f"🏦 Tài khoản: <code>{acc_info.login}</code> ({acc_info.server})\n"
        f"🪙 Mã Vàng: <b>{gold_symbol}</b>\n"
        f"📡 Tự động quét tín hiệu, đặt lệnh Limit 0.01 lot cách giá 50 USD."
    )
    print(startup_msg.replace("<b>", "").replace("</b>", "").replace("<code>", "").replace("</code>", ""))
    send_telegram(startup_msg)

    try:
        while True:
            # Kiểm tra xem đã có lệnh chờ nào đang mở chưa (tránh spam lệnh liên tục)
            pending_orders = mt5.orders_get(symbol=gold_symbol)
            if pending_orders is None or len(pending_orders) == 0:
                
                # Quét tín hiệu kỹ thuật
                signal, entry, sl, tp, reason = analyze_technical_signals(gold_symbol)
                
                if signal in ["BUY", "SELL"]:
                    tick = mt5.symbol_info_tick(gold_symbol)
                    print(f"\n[!] Phát hiện tín hiệu {signal}! Đang đặt lệnh Limit cách 50 USD...")
                    
                    trade_res = place_limit_order(gold_symbol, signal, entry, sl, tp)
                    if trade_res.retcode == mt5.TRADE_RETCODE_DONE:
                        msg = (
                            f"🎯 <b>ĐÃ ĐẶT LỆNH LIMIT THÀNH CÔNG (ALGO)</b>\n"
                            f"📌 Hướng: <b>{signal}</b> | Mã: <b>{gold_symbol}</b> ({TRADE_LOT} lot)\n"
                            f"📍 Giá Limit đặt: <code>{trade_res.request.price}</code> (Cách giá hiện tại ~50 USD)\n"
                            f"🛑 SL: <code>{sl}</code> | 🎯 TP: <code>{tp}</code>\n\n"
                            f"🧠 <b>Lý do kỹ thuật:</b>\n{reason}"
                        )
                        print(f"-> Đặt thành công lệnh {signal} Limit tại {trade_res.request.price}")
                        send_telegram(msg)
                    else:
                        print(f"-> Lỗi đặt lệnh MT5: {trade_res.comment} (Code: {trade_res.retcode})")

            # Quét định kỳ mỗi 30 giây
            time.sleep(30)

    except KeyboardInterrupt:
        print("\nĐã dừng hệ thống thủ công.")
    finally:
        mt5.shutdown()

if __name__ == "__main__":
    main()