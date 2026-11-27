import time
import json
import requests
import pandas as pd
import numpy as np
import MetaTrader5 as mt5
from pydantic import BaseModel, Field
from typing import Literal
from google import genai
from google.genai import types

# ==============================================================================
# 1. CẤU HÌNH HỆ THỐNG (BÁC CÓ THỂ CHỈNH SỬA TẠI ĐÂY)
# ==============================================================================
MT5_PATH = r"C:\Program Files\MetaTrader 5\terminal64.exe"

GEMINI_API_KEY = "xxxx"
MODEL_NAME = "gemini-3.8-flash" # Nếu báo lỗi không tìm thấy model, hãy đổi thành "gemini-2.5-flash"

TELEGRAM_TOKEN = "xxxx"
CHAT_IDS = ["xxx"]

# Khối lượng thực tế sẽ vào lệnh Market khi AI duyệt (APPROVE)
REAL_TRADE_LOT_SCALP = 0.01  # Khối lượng thực khi kích hoạt bằng lệnh chờ 0.01
REAL_TRADE_LOT_SWING = 0.02  # Khối lượng thực khi kích hoạt bằng lệnh chờ 0.02
MAGIC_NUMBER = 2026888

# Quy tắc chống quét SL & thu gọn TP cho Vàng (XAU/USD)
# Ví dụ: Entry BUY 4560 | SL cũ 4555 (5.0 giá) -> SL mới 4552.5 (7.5 giá = x1.5)
#       TP cũ 4565 (5.0 giá) -> TP mới 4563 (3.0 giá = x0.6)
SL_EXPAND_FACTOR = 1.5     # > 1.0: nới SL xa giá vào hơn để tránh bị quét râu nến
TP_TIGHTEN_FACTOR = 0.6    # < 1.0: kéo TP gần giá vào hơn để chốt sớm khi giá giật ngược
MAX_SL_DISTANCE = 15.0     # Trần khoảng cách SL tối đa (tính theo giá vàng) để tránh SL quá xa

# ==============================================================================
# 2. KHỞI TẠO GEMINI CLIENT & ĐỊNH NGHĨA JSON SCHEMA (CHỐNG ẢO GIÁC)
# ==============================================================================
client = genai.Client(api_key=GEMINI_API_KEY)

class TradeDecision(BaseModel):
    decision: Literal["APPROVE", "REJECT", "NONE"] = Field(
        description="APPROVE nếu đồng ý vào lệnh, REJECT nếu từ chối vì rủi ro/ngược xu hướng, NONE nếu chỉ phân tích (mã 0.03)."
    )
    confidence_score: int = Field(
        description="Điểm tự tin của thiết lập giao dịch từ 0 đến 100."
    )
    suggested_sl: float = Field(
        description="Mức giá Stop Loss đề xuất dựa trên ATR và cấu trúc đỉnh/đáy gần nhất."
    )
    suggested_tp: float = Field(
        description="Mức giá Take Profit đề xuất thực tế theo vùng cản gần."
    )
    reason: str = Field(
        description="Phân tích chuyên sâu bằng tiếng Việt về cấu trúc thị trường đa khung thời gian, EMA, ATR và lý do ra quyết định."
    )

# ==============================================================================
# 3. CÁC HÀM TIỆN ÍCH: TELEGRAM, TÌM SYMBOL VÀ TÍNH CHỈ BÁO
# ==============================================================================
def send_telegram(message: str):
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    for chat_id in CHAT_IDS:
        payload = {
            "chat_id": chat_id,
            "text": message,
            "parse_mode": "HTML"
        }
        try:
            requests.post(url, json=payload, timeout=10)
        except Exception as e:
            print(f"[Lỗi Telegram]: {e}")

def find_gold_symbol() -> str:
    """Tự động dò tìm mã Vàng đang hoạt động trên sàn"""
    candidates = ["XAUUSD", "XAUUSDm", "XAUUSD.c", "GOLD", "XAUUSD_i", "XAUUSD.pro"]
    all_symbols = mt5.symbols_get()
    if all_symbols is None:
        return None
    
    symbol_names = [s.name for s in all_symbols]
    
    # Ưu tiên khớp chính xác danh sách phổ biến
    for cand in candidates:
        if cand in symbol_names:
            mt5.symbol_select(cand, True)
            return cand
            
    # Nếu sàn đặt tên lạ (vd: XAUUSD.raw, GOLDmicro...), tìm theo từ khóa
    for name in symbol_names:
        if "XAUUSD" in name.upper() or "GOLD" in name.upper():
            mt5.symbol_select(name, True)
            return name
            
    return None

def get_market_data_and_atr(symbol: str, timeframes: dict) -> tuple[str, float]:
    """Trích xuất dữ liệu nến, tự tính EMA20, EMA50, ATR14 và trả về (báo_cáo, atr_tham_chiếu)"""
    report = []
    tick = mt5.symbol_info_tick(symbol)
    sym_info = mt5.symbol_info(symbol)
    spread_pts = round((tick.ask - tick.bid) / sym_info.point) if sym_info.point > 0 else 0
    report.append(f"GIÁ HIỆN TẠI ({symbol}): Bid = {tick.bid} | Ask = {tick.ask} | Spread = {spread_pts} points\n")

    ref_atr = 3.0
    found_atr = False

    for tf_name, tf_const in timeframes.items():
        rates = mt5.copy_rates_from_pos(symbol, tf_const, 0, 60)
        if rates is None or len(rates) < 50:
            continue
        df = pd.DataFrame(rates)
        df['time'] = pd.to_datetime(df['time'], unit='s')
        
        # Tự tính chỉ báo chống repainting
        df['EMA20'] = df['close'].ewm(span=20, adjust=False).mean()
        df['EMA50'] = df['close'].ewm(span=50, adjust=False).mean()
        
        # Tính ATR 14
        high_low = df['high'] - df['low']
        high_close = np.abs(df['high'] - df['close'].shift())
        low_close = np.abs(df['low'] - df['close'].shift())
        tr = pd.concat([high_low, high_close, low_close], axis=1).max(axis=1)
        df['ATR14'] = tr.rolling(14).mean()

        recent = df.tail(15)
        latest = df.iloc[-1]
        atr_val = float(latest['ATR14']) if pd.notna(latest['ATR14']) else 3.0

        if not found_atr and atr_val > 0:
            ref_atr = atr_val
            found_atr = True
        
        report.append(f"--- KHUNG {tf_name} (ATR14 hiện tại: {atr_val:.2f} | EMA20: {latest['EMA20']:.2f} | EMA50: {latest['EMA50']:.2f}) ---")
        report.append("Time | Open | High | Low | Close | Vol")
        for _, row in recent.iterrows():
            t_str = row['time'].strftime('%H:%M')
            report.append(f"{t_str} | {row['open']:.2f} | {row['high']:.2f} | {row['low']:.2f} | {row['close']:.2f} | {int(row['tick_volume'])}")
        report.append("")
        
    return "\n".join(report), ref_atr

# ==============================================================================
# 4. HÀM XỬ LÝ LỆNH TRÊN MT5 & GỌI GEMINI THẨM ĐỊNH
# ==============================================================================
def delete_pending_order(ticket: int):
    request = {
        "action": mt5.TRADE_ACTION_REMOVE,
        "order": ticket,
    }
    res = mt5.order_send(request)
    if res is None or res.retcode != mt5.TRADE_RETCODE_DONE:
        err = res.comment if res else mt5.last_error()
        print(f"[Lỗi xóa lệnh chờ #{ticket}]: {err}")

def adjust_sl_tp_anti_sweep(symbol: str, direction: str, entry_price: float, ai_sl: float, ai_tp: float, atr: float) -> tuple[float, float]:
    """
    Nới rộng khoảng cách SL (giảm nguy cơ bị quét râu) và thu hẹp khoảng cách TP (chốt sớm hơn)
    tính từ giá vào lệnh thực tế, có kiểm tra giới hạn sàn MT5.
    """
    sym_info = mt5.symbol_info(symbol)
    digits = sym_info.digits
    point = sym_info.point if sym_info.point > 0 else 0.01
    broker_min_dist = (sym_info.trade_stops_level + 2) * point
    min_safe_dist = max(broker_min_dist, atr * 0.4, 0.5)

    fallback_sl_dist = max(atr * 1.2, 5.0)
    fallback_tp_dist = max(atr * 1.5, 5.0)

    if direction == "BUY":
        raw_sl_dist = (entry_price - ai_sl) if (ai_sl is not None and ai_sl > 0 and ai_sl < entry_price) else fallback_sl_dist
        raw_tp_dist = (ai_tp - entry_price) if (ai_tp is not None and ai_tp > entry_price) else fallback_tp_dist

        new_sl_dist = min(raw_sl_dist * SL_EXPAND_FACTOR, MAX_SL_DISTANCE)
        new_sl_dist = max(new_sl_dist, min_safe_dist)

        new_tp_dist = max(raw_tp_dist * TP_TIGHTEN_FACTOR, min_safe_dist)

        final_sl = round(entry_price - new_sl_dist, digits)
        final_tp = round(entry_price + new_tp_dist, digits)

        # Đảm bảo tuyệt đối BUY có SL < entry_price < TP
        if final_sl >= entry_price:
            final_sl = round(entry_price - min_safe_dist, digits)
        if final_tp <= entry_price:
            final_tp = round(entry_price + min_safe_dist, digits)

    else:  # SELL
        raw_sl_dist = (ai_sl - entry_price) if (ai_sl is not None and ai_sl > entry_price) else fallback_sl_dist
        raw_tp_dist = (entry_price - ai_tp) if (ai_tp is not None and ai_tp > 0 and ai_tp < entry_price) else fallback_tp_dist

        new_sl_dist = min(raw_sl_dist * SL_EXPAND_FACTOR, MAX_SL_DISTANCE)
        new_sl_dist = max(new_sl_dist, min_safe_dist)

        new_tp_dist = max(raw_tp_dist * TP_TIGHTEN_FACTOR, min_safe_dist)

        final_sl = round(entry_price + new_sl_dist, digits)
        final_tp = round(entry_price - new_tp_dist, digits)

        # Đảm bảo tuyệt đối SELL có TP < entry_price < SL
        if final_sl <= entry_price:
            final_sl = round(entry_price + min_safe_dist, digits)
        if final_tp >= entry_price:
            final_tp = round(entry_price - min_safe_dist, digits)

    return final_sl, final_tp

def execute_market_order(symbol: str, direction: str, lot: float, ai_sl: float, ai_tp: float, atr: float):
    tick = mt5.symbol_info_tick(symbol)
    order_type = mt5.ORDER_TYPE_BUY if direction == "BUY" else mt5.ORDER_TYPE_SELL
    exec_price = tick.ask if direction == "BUY" else tick.bid

    final_sl, final_tp = adjust_sl_tp_anti_sweep(symbol, direction, exec_price, ai_sl, ai_tp, atr)

    request = {
        "action": mt5.TRADE_ACTION_DEAL,
        "symbol": symbol,
        "volume": lot,
        "type": order_type,
        "price": exec_price,
        "sl": final_sl,
        "tp": final_tp,
        "deviation": 30,
        "magic": MAGIC_NUMBER,
        "comment": "Gemini_AI_AntiSweep",
        "type_time": mt5.ORDER_TIME_GTC,
        "type_filling": mt5.ORDER_FILLING_IOC,
    }
    res = mt5.order_send(request)
    return res, exec_price, final_sl, final_tp

def process_trigger_order(order, symbol: str):
    if order.type in [mt5.ORDER_TYPE_BUY_LIMIT, mt5.ORDER_TYPE_BUY_STOP]:
        direction = "BUY"
    elif order.type in [mt5.ORDER_TYPE_SELL_LIMIT, mt5.ORDER_TYPE_SELL_STOP]:
        direction = "SELL"
    else:
        return

    vol = round(order.volume_initial, 2)
    
    if vol == 0.01:
        mode = "SCALP (Lướt sóng ngắn)"
        timeframes = {"M15": mt5.TIMEFRAME_M15, "M5": mt5.TIMEFRAME_M5, "M1": mt5.TIMEFRAME_M1}
        real_lot = REAL_TRADE_LOT_SCALP
    elif vol == 0.02:
        mode = "SWING (Giao dịch trong ngày)"
        timeframes = {"H4": mt5.TIMEFRAME_H4, "H1": mt5.TIMEFRAME_H1, "M15": mt5.TIMEFRAME_M15}
        real_lot = REAL_TRADE_LOT_SWING
    elif vol == 0.03:
        mode = "ANALYSIS ONLY (Chỉ phân tích báo cáo, không vào lệnh)"
        timeframes = {"H4": mt5.TIMEFRAME_H4, "H1": mt5.TIMEFRAME_H1, "M15": mt5.TIMEFRAME_M15, "M5": mt5.TIMEFRAME_M5}
        real_lot = 0.0
    else:
        return

    print(f"\n[!] Phát hiện tín hiệu kích hoạt: {direction} | Mã Lot: {vol} ({mode})")
    
    # Bước 1: Xóa ngay lệnh chờ kích hoạt để tránh bị khớp nhầm
    delete_pending_order(order.ticket)

    # Bước 2: Thu thập dữ liệu thị trường & ATR tham chiếu
    market_data, ref_atr = get_market_data_and_atr(symbol, timeframes)

    # Bước 3: Gửi sang Gemini thẩm định
    system_instruction = (
        "Bạn là một Giám đốc Quản trị Rủi ro và Chuyên gia Phân tích Kỹ thuật Vàng (XAU/USD) thực chiến. "
        "Nhiệm vụ của bạn là thẩm định thiết lập giao dịch mà Trader yêu cầu dựa trên dữ liệu đa khung thời gian (Price Action, cấu trúc đỉnh/đáy, EMA20/EMA50, ATR14). "
        "Vàng thường xuyên quét râu nến/thanh khoản trước khi chạy: hãy ưu tiên SL đủ thoáng để tránh nhiễu quét râu ngắn hạn, và đặt TP thực tế ở vùng cản gần để chốt lời sớm. "
        "Nguyên tắc: Chỉ APPROVE khi cấu trúc giá ủng hộ rõ ràng, không mua đuổi ở đỉnh kháng cự hoặc bán đuổi ở đáy hỗ trợ. "
        "Nếu chế độ là ANALYSIS ONLY (0.03), hãy đặt decision là 'NONE' và phân tích chi tiết cơ hội Buy/Sell hiện tại."
    )

    prompt = (
        f"Trader đang muốn thực hiện lệnh: **{direction}** trên cặp **{symbol}**.\n"
        f"Chế độ giao dịch: **{mode}**.\n\n"
        f"Dữ liệu thị trường thực tế:\n{market_data}\n\n"
        "Hãy thẩm định lệnh này và trả về kết quả theo đúng cấu trúc JSON."
    )

    try:
        start_t = time.time()
        response = client.models.generate_content(
            model=MODEL_NAME,
            contents=prompt,
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                response_mime_type="application/json",
                response_schema=TradeDecision,
                temperature=0.2,
            ),
        )
        latency = round(time.time() - start_t, 2)
        result = json.loads(response.text)
        
        decision = result["decision"]
        score = result["confidence_score"]
        ai_sl = float(result["suggested_sl"])
        ai_tp = float(result["suggested_tp"])
        reason = result["reason"]

        # Bước 4: Thực thi & Báo cáo Telegram
        if vol == 0.03 or decision == "NONE":
            tick = mt5.symbol_info_tick(symbol)
            ref_price = tick.ask if direction == "BUY" else tick.bid
            adj_sl, adj_tp = adjust_sl_tp_anti_sweep(symbol, direction, ref_price, ai_sl, ai_tp, ref_atr)
            msg = (
                f"📊 <b>BÁO CÁO PHÂN TÍCH VÀNG ({symbol})</b>\n"
                f"⏱ Thời gian AI xử lý: {latency}s\n"
                f"🎯 SL tham khảo (anti-sweep): <code>{adj_sl}</code> | TP thu gọn: <code>{adj_tp}</code>\n\n"
                f"🧠 <b>Nhận định chuyên sâu:</b>\n{reason}"
            )
            send_telegram(msg)
            print("-> Đã gửi báo cáo phân tích về Telegram.")

        elif decision == "APPROVE":
            trade_res, exec_price, final_sl, final_tp = execute_market_order(
                symbol, direction, real_lot, ai_sl, ai_tp, ref_atr
            )
            if trade_res is not None and trade_res.retcode == mt5.TRADE_RETCODE_DONE:
                fill_price = trade_res.price if trade_res.price > 0 else exec_price
                msg = (
                    f"✅ <b>AI DUYỆT LỆNH: {direction} {symbol} ({real_lot} lot)</b>\n"
                    f"📌 Chế độ: {mode}\n"
                    f"🔥 Độ tự tin: <b>{score}/100</b> | Xử lý: {latency}s\n"
                    f"💵 Giá khớp: <code>{fill_price}</code>\n"
                    f"🛑 SL (đã nới x{SL_EXPAND_FACTOR}): <code>{final_sl}</code>\n"
                    f"🎯 TP (đã thu x{TP_TIGHTEN_FACTOR}): <code>{final_tp}</code>\n\n"
                    f"🧠 <b>Phân tích chuyên sâu:</b>\n{reason}"
                )
                print(f"-> Đã khớp lệnh {direction} tại {fill_price} | SL: {final_sl} | TP: {final_tp}")
            else:
                err_txt = trade_res.comment if trade_res else str(mt5.last_error())
                err_code = trade_res.retcode if trade_res else "N/A"
                msg = (
                    f"⚠️ <b>AI DUYỆT NHƯNG LỖI KHỚP LỆNH MT5</b>\n"
                    f"Lỗi: {err_txt} (Code: {err_code})\n"
                    f"Lý do AI duyệt: {reason}"
                )
                print(f"-> Lỗi vào lệnh MT5: {err_txt}")
            send_telegram(msg)

        else: # REJECT
            msg = (
                f"❌ <b>AI TỪ CHỐI LỆNH: {direction} {symbol}</b>\n"
                f"📌 Chế độ: {mode}\n"
                f"⚠️ Độ tự tin: <b>{score}/100</b> | Xử lý: {latency}s\n\n"
                f"🧠 <b>Lý do từ chối:</b>\n{reason}"
            )
            send_telegram(msg)
            print("-> AI từ chối lệnh. Đã báo Telegram.")

    except Exception as e:
        err_msg = f"🚨 <b>Lỗi gọi Gemini API:</b> {str(e)}"
        print(err_msg)
        send_telegram(err_msg)

# ==============================================================================
# 5. VÒNG LẶP CHÍNH CHẠY 24/7
# ==============================================================================
def main():
    if not mt5.initialize(path=MT5_PATH):
        print(f"Không thể kết nối MT5 tại {MT5_PATH}. Lỗi:", mt5.last_error())
        return

    acc_info = mt5.account_info()
    gold_symbol = find_gold_symbol()
    
    if not gold_symbol:
        print("Không tìm thấy mã Vàng (XAUUSD/GOLD) trên tài khoản MT5 này!")
        mt5.shutdown()
        return

    startup_msg = (
        f"🤖 <b>HỆ THỐNG AI GOLD TRIGGER ĐÃ KHỞI ĐỘNG</b>\n"
        f"🏦 Tài khoản: <code>{acc_info.login}</code> ({acc_info.server})\n"
        f"🪙 Mã Vàng nhận diện: <b>{gold_symbol}</b>\n"
        f"🛡 SL x{SL_EXPAND_FACTOR} | 🎯 TP x{TP_TIGHTEN_FACTOR}\n"
        f"📡 Sẵn sàng nhận hiệu lệnh chờ (0.01 Scalp | 0.02 Swing | 0.03 Phân tích)."
    )
    print(startup_msg.replace("<b>", "").replace("</b>", "").replace("<code>", "").replace("</code>", ""))
    send_telegram(startup_msg)

    processed_tickets = set()

    try:
        while True:
            orders = mt5.orders_get(symbol=gold_symbol)
            if orders:
                for order in orders:
                    if order.ticket not in processed_tickets:
                        processed_tickets.add(order.ticket)
                        process_trigger_order(order, gold_symbol)
            
            time.sleep(0.5)

    except KeyboardInterrupt:
        print("\nĐã dừng hệ thống thủ công.")
    finally:
        mt5.shutdown()

if __name__ == "__main__":
    main()