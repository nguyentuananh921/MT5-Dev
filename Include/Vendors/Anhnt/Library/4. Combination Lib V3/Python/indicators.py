import numpy as np
import pandas as pd
import talib
from numpy.lib.stride_tricks import sliding_window_view

def applied_price(df, applied):
    name = applied.replace("PRICE_", "").upper()
    o, h, l, c = (df[k].to_numpy(dtype=float) for k in ("open", "high", "low", "close"))
    if name == "CLOSE":
        return c
    if name == "OPEN":
        return o
    if name == "HIGH":
        return h
    if name == "LOW":
        return l
    if name == "MEDIAN":
        return (h + l) / 2
    if name == "TYPICAL":
        return (h + l + c) / 3
    if name == "WEIGHTED":
        return (h + l + 2 * c) / 4
    raise ValueError(f"unknown applied price {applied}")

def smma(price, period):
    out = np.full(len(price), np.nan)
    if len(price) < period:
        return out
    out[period - 1] = price[:period].mean()
    for i in range(period, len(price)):
        out[i] = (out[i - 1] * (period - 1) + price[i]) / period
    return out

def ema_first_price(price, period):
    out = np.empty(len(price))
    k = 2.0 / (period + 1)
    out[0] = price[0]
    for i in range(1, len(price)):
        out[i] = price[i] * k + out[i - 1] * (1 - k)
    return out

def moving_average(price, period, method):
    name = method.replace("MODE_", "").upper()
    if name == "SMA":
        return talib.SMA(price, period)
    if name == "EMA":
        return talib.EMA(price, period)
    if name == "SMMA":
        return smma(price, period)
    if name == "LWMA":
        return talib.WMA(price, period)
    raise ValueError(f"unknown ma method {method}")

def shifted(values, shift):
    """The indicator shift of MT5: the value shown at bar i was calculated at bar i - shift."""
    shift = int(float(shift))
    values = np.asarray(values, dtype=float)
    if shift <= 0:
        return values
    out = np.full(len(values), np.nan)
    if shift < len(values):
        out[shift:] = values[:-shift]
    return out

def previous(values, count=1):
    out = np.full(len(values), np.nan)
    out[count:] = np.asarray(values, dtype=float)[:-count]
    return out

def rolling(values, period, how):
    return getattr(pd.Series(values).rolling(int(period)), how)().to_numpy(dtype=float)

def sma(values, period):
    return rolling(values, period, "mean")

def on_valid(values, function):
    """function() on the values after the leading NaN: the average of a series that starts late must not start with NaN."""
    values = np.asarray(values, dtype=float)
    valid = np.nonzero(~np.isnan(values))[0]
    out = np.full(len(values), np.nan)
    if len(valid):
        out[valid[0]:] = function(values[valid[0]:])
    return out

def volume_of(df, p):
    return df["real_volume" if p["volume"].upper() == "REAL" else "tick_volume"].to_numpy(dtype=float)

def ohlc(df):
    return tuple(df[k].to_numpy(dtype=float) for k in ("open", "high", "low", "close"))

# Every function returns (buffers, alternatives): buffers follow the MT5 buffer order,
# alternatives = {buffer index: [(label, array)]} are other formulas worth trying when a buffer does not match.

def sar(df, p):
    # MT5 checks the reversal against the extreme point of the previous trend, before the current bar updates it (talib updates first)
    h, l = df["high"].to_numpy(dtype=float), df["low"].to_numpy(dtype=float)
    step, maximum = float(p["step"]), float(p["maximum"])
    out = np.zeros(len(h))
    is_long, af, ep = False, step, l[0]
    out[0] = h[0]
    for i in range(1, len(h)):
        value = out[i - 1] + af * (ep - out[i - 1])
        if is_long:
            value = min(value, l[i - 1], l[i - 2] if i > 1 else l[i - 1])
            if l[i] < value:
                is_long, value, ep, af = False, ep, l[i], step
            elif h[i] > ep:
                ep, af = h[i], min(af + step, maximum)
        else:
            value = max(value, h[i - 1], h[i - 2] if i > 1 else h[i - 1])
            if h[i] > value:
                is_long, value, ep, af = True, ep, h[i], step
            elif l[i] < ep:
                ep, af = l[i], min(af + step, maximum)
        out[i] = value
    return [out], {0: [("talib SAR", talib.SAR(h, l, step, maximum))]}

def ma(df, p):
    price = applied_price(df, p["applied"])
    period = int(p["period"])
    out = shifted(moving_average(price, period, p["method"]), p.get("shift", 0))
    alt = {}
    if p["method"].upper().endswith("EMA"):
        alt[0] = [("EMA seeded with the first price", shifted(ema_first_price(price, period), p.get("shift", 0)))]
    return [out], alt

def rsi(df, p):
    price = applied_price(df, p["applied"])
    return [talib.RSI(price, int(p["period"]))], {}

def macd(df, p):
    price = applied_price(df, p["applied"])
    fast, slow, signal = int(p["fast"]), int(p["slow"]), int(p["signal"])
    main = talib.EMA(price, fast) - talib.EMA(price, slow)
    main_first = ema_first_price(price, fast) - ema_first_price(price, slow)
    sma_signal = talib.SMA(np.nan_to_num(main_first, nan=0.0), signal)
    ema_signal = ema_first_price(main_first, signal)
    return [main_first, sma_signal], {0: [("EMA seeded with SMA (talib)", main)],
                                      1: [("EMA of main", ema_signal)]}

def bands(df, p):
    price = applied_price(df, p["applied"])
    upper, middle, lower = talib.BBANDS(price, int(p["period"]), float(p["deviation"]), float(p["deviation"]), 0)
    return [shifted(middle, p.get("shift", 0)), shifted(upper, p.get("shift", 0)), shifted(lower, p.get("shift", 0))], {}

def adx(df, p):
    h, l, c = (df[k].to_numpy(dtype=float) for k in ("high", "low", "close"))
    # MT5: +DI/-DI of each bar (movement / true range), smoothed with EMA 2/(n+1); ADX = the same EMA of |+DI - -DI| / (+DI + -DI)
    k = 2.0 / (int(p["period"]) + 1)
    n = len(h)
    plus, minus, adx_line = np.zeros(n), np.zeros(n), np.zeros(n)
    for i in range(1, n):
        up, down = max(h[i] - h[i - 1], 0.0), max(l[i - 1] - l[i], 0.0)
        if up > down:
            down = 0.0
        elif up < down:
            up = 0.0
        else:
            up = down = 0.0
        tr = max(abs(h[i] - l[i]), abs(h[i] - c[i - 1]), abs(l[i] - c[i - 1]))
        plus[i] = plus[i - 1] * (1 - k) + (up / tr * 100 if tr else 0.0) * k
        minus[i] = minus[i - 1] * (1 - k) + (down / tr * 100 if tr else 0.0) * k
        total = plus[i] + minus[i]
        dx = 100 * abs((plus[i] - minus[i]) / total) if total else 0.0
        adx_line[i] = adx_line[i - 1] * (1 - k) + dx * k
    return [adx_line, plus, minus], {}

def alligator_lines(df, p):
    price = applied_price(df, p["applied"])
    return [shifted(moving_average(price, int(p[part + "_period"]), p["method"]), p[part + "_shift"]) for part in ("jaw", "teeth", "lips")]

def alligator(df, p):
    return alligator_lines(df, p), {}

def gator(df, p):
    jaw, teeth, lips = alligator_lines(df, p)
    return [np.abs(jaw - teeth), -np.abs(teeth - lips)], {}

def ichimoku(df, p):
    _, h, l, c = ohlc(df)
    tenkan_n, kijun_n, senkou_n = int(p["tenkan"]), int(p["kijun"]), int(p["senkou_b"])

    def middle(period):
        return (rolling(h, period, "max") + rolling(l, period, "min")) / 2

    tenkan, kijun = middle(tenkan_n), middle(kijun_n)
    chikou = np.full(len(c), np.nan)
    if kijun_n < len(c):
        chikou[:-kijun_n] = c[kijun_n:]
    return [tenkan, kijun, shifted((tenkan + kijun) / 2, kijun_n), shifted(middle(senkou_n), kijun_n), chikou], {}

def envelopes(df, p):
    line = moving_average(applied_price(df, p["applied"]), int(p["period"]), p["method"])
    deviation = float(p["deviation"]) / 100
    return [shifted(line * (1 + deviation), p["shift"]), shifted(line * (1 - deviation), p["shift"])], {}

def frama(df, p):
    _, h, l, _c = ohlc(df)
    price = applied_price(df, p["applied"])
    half = int(p["period"])   # MT5: the period is the length of each half, the whole window is twice as long
    full = 2 * half
    out = price.copy()
    for i in range(full, len(price)):
        n1 = (h[i - half + 1:i + 1].max() - l[i - half + 1:i + 1].min()) / half
        n2 = (h[i - full + 1:i - half + 1].max() - l[i - full + 1:i - half + 1].min()) / half
        n3 = (h[i - full + 1:i + 1].max() - l[i - full + 1:i + 1].min()) / full
        dimension = (np.log(n1 + n2) - np.log(n3)) / np.log(2.0) if n1 > 0 and n2 > 0 and n3 > 0 else 1.0
        alpha = max(np.exp(-4.6 * (dimension - 1.0)), 0.01)   # MT5 does not cut it at 1
        out[i] = alpha * price[i] + (1 - alpha) * out[i - 1]
    return [shifted(out, p["shift"])], {}

def ama(df, p):
    price = applied_price(df, p["applied"])
    period = int(p["ama_period"])
    fast, slow = 2.0 / (int(p["fast"]) + 1), 2.0 / (int(p["slow"]) + 1)
    out = np.full(len(price), np.nan)
    if len(price) <= period:
        return [out], {}
    noise = rolling(np.abs(np.diff(price, prepend=price[0])), period, "sum")
    out[period - 1] = price[period - 1]
    for i in range(period, len(price)):
        ratio = abs(price[i] - price[i - period]) / noise[i] if noise[i] else 0.0
        c = (ratio * (fast - slow) + slow) ** 2
        out[i] = out[i - 1] + c * (price[i] - out[i - 1])
    return [shifted(out, p["shift"])], {}

def dema(df, p):
    e1 = ema_first_price(applied_price(df, p["applied"]), int(p["period"]))
    e2 = ema_first_price(e1, int(p["period"]))
    return [shifted(2 * e1 - e2, p["shift"])], {}

def tema(df, p):
    n = int(p["period"])
    e1 = ema_first_price(applied_price(df, p["applied"]), n)
    e2 = ema_first_price(e1, n)
    e3 = ema_first_price(e2, n)
    return [shifted(3 * e1 - 3 * e2 + e3, p["shift"])], {}

def vidya(df, p):
    price = applied_price(df, p["applied"])
    cmo_period = int(p["cmo_period"])
    alpha = 2.0 / (int(p["ema_period"]) + 1)
    change = np.diff(price, prepend=price[0])
    up, down = rolling(np.maximum(change, 0.0), cmo_period, "sum"), rolling(np.maximum(-change, 0.0), cmo_period, "sum")
    total = up + down
    with np.errstate(divide="ignore", invalid="ignore"):
        cmo = np.where(total > 0, np.abs(up - down) / total, 0.0)
    out = price.copy()
    for i in range(1, len(price)):
        k = 0.0 if np.isnan(cmo[i]) else alpha * cmo[i]
        out[i] = price[i] * k + out[i - 1] * (1 - k)
    return [shifted(out, p["shift"])], {}

def adx_wilder(df, p):
    _, h, l, c = ohlc(df)
    n = int(p["period"])
    return [talib.ADX(h, l, c, n), talib.PLUS_DI(h, l, c, n), talib.MINUS_DI(h, l, c, n)], {}

def stddev(df, p):
    price = applied_price(df, p["applied"])
    period = int(p["period"])
    line = moving_average(price, period, p["method"])   # the deviation is taken around the average of the bar itself
    out = np.full(len(price), np.nan)
    if len(price) >= period:
        window = sliding_window_view(price, period)
        out[period - 1:] = np.sqrt(((window - line[period - 1:, None]) ** 2).mean(axis=1))
    return [shifted(out, p["shift"])], {}

def stochastic(df, p):
    _, h, l, c = ohlc(df)
    k_period, d_period, slowing = int(p["k"]), int(p["d"]), int(p["slowing"])
    high_source, low_source = (c, c) if p["field"].upper().startswith("CLOSE") else (h, l)
    low = rolling(low_source, k_period, "min")
    high = rolling(high_source, k_period, "max")
    below, range_ = rolling(c - low, slowing, "sum"), rolling(high - low, slowing, "sum")
    with np.errstate(divide="ignore", invalid="ignore"):
        main = np.where(range_ > 0, below / range_ * 100, 100.0)
    main = np.where(np.isnan(range_), np.nan, main)
    return [main, on_valid(main, lambda v: moving_average(v, d_period, p["method"]))], {}

def cci(df, p):
    price = applied_price(df, p["applied"])
    period = int(p["period"])
    out = np.full(len(price), np.nan)
    if len(price) >= period:
        window = sliding_window_view(price, period)
        mean = window.mean(axis=1)
        deviation = np.abs(window - mean[:, None]).mean(axis=1)   # around the average of the bar itself
        with np.errstate(divide="ignore", invalid="ignore"):
            out[period - 1:] = np.where(deviation > 0, (price[period - 1:] - mean) / (0.015 * deviation), 0.0)
    return [out], {}

def momentum(df, p):
    price = applied_price(df, p["applied"])
    return [price / previous(price, int(p["period"])) * 100], {}

def demarker(df, p):
    _, h, l, _c = ohlc(df)
    period = int(p["period"])
    up = np.maximum(np.diff(h, prepend=h[0]), 0.0)
    down = np.maximum(-np.diff(l, prepend=l[0]), 0.0)
    up_mean, down_mean = sma(up, period), sma(down, period)
    with np.errstate(divide="ignore", invalid="ignore"):
        return [np.where(up_mean + down_mean > 0, up_mean / (up_mean + down_mean), 0.5)], {}

def rvi(df, p):
    o, h, l, c = ohlc(df)
    period = int(p["period"])

    def smoothed(values):
        out = values.copy()
        for back, weight in ((1, 2.0), (2, 2.0), (3, 1.0)):
            out = out + weight * previous(values, back)
        return out / 6

    main = sma(smoothed(c - o), period) / sma(smoothed(h - l), period)
    return [main, smoothed(main)], {}

def wpr(df, p):
    _, h, l, c = ohlc(df)
    return [talib.WILLR(h, l, c, int(p["period"]))], {}

def osma(df, p):
    (main, signal), _ = macd(df, p)
    return [main - signal], {}

def trix(df, p):
    n = int(p["period"])
    e3 = ema_first_price(ema_first_price(ema_first_price(applied_price(df, "CLOSE"), n), n), n)
    return [(e3 - previous(e3)) / previous(e3)], {}

def atr(df, p):
    _, h, l, c = ohlc(df)
    true_range = np.maximum(h - l, np.maximum(np.abs(h - previous(c)), np.abs(l - previous(c))))
    true_range[0] = h[0] - l[0]
    return [sma(true_range, int(p["period"]))], {}

def force(df, p):
    average = moving_average(applied_price(df, "CLOSE"), int(p["period"]), p["method"])
    return [volume_of(df, p) * (average - previous(average))], {}   # the volume times the change of the average

def awesome(df, p):
    _, h, l, _c = ohlc(df)
    median = (h + l) / 2
    return [sma(median, 5) - sma(median, 34)], {}

def accelerator(df, p):
    (ao,), _ = awesome(df, p)
    return [ao - on_valid(ao, lambda v: sma(v, 5))], {}

def bears(df, p):
    _, _h, l, c = ohlc(df)
    return [l - ema_first_price(c, int(p["period"]))], {}

def bulls(df, p):
    _, h, _l, c = ohlc(df)
    return [h - ema_first_price(c, int(p["period"]))], {}

def accumulation(df, p):
    _, h, l, c = ohlc(df)
    with np.errstate(divide="ignore", invalid="ignore"):
        flow = np.where(h > l, ((c - l) - (h - c)) / (h - l), 0.0)
    return [np.cumsum(flow * volume_of(df, p))], {}

def chaikin(df, p):
    (line,), _ = accumulation(df, p)
    fast, slow = int(p["fast"]), int(p["slow"])
    return [moving_average(line, fast, p["method"]) - moving_average(line, slow, p["method"])], {}

def obv(df, p):
    c = applied_price(df, "CLOSE")
    volume = volume_of(df, p)
    step = np.sign(np.diff(c, prepend=c[0])) * volume
    step[0] = volume[0]
    return [np.cumsum(step)], {}

def mfi(df, p):
    _, h, l, c = ohlc(df)
    return [talib.MFI(h, l, c, df["tick_volume"].to_numpy(dtype=float), int(p["period"]))], {}

def volumes(df, p):
    return [volume_of(df, p)], {}

def bw_mfi(df, p):
    _, h, l, _c = ohlc(df)
    volume = df["tick_volume"].to_numpy(dtype=float)
    point = df.attrs.get("point") or 1.0   # MT5 divides by the point as well
    with np.errstate(divide="ignore", invalid="ignore"):
        return [np.where(volume > 0, (h - l) / (volume * point), np.nan)], {}

def fractals(df, p):
    # a fractal belongs to its middle bar and needs two newer bars; MT5 compares >= with the older side, > with the newer one
    _, h, l, _c = ohlc(df)
    n = len(h)
    upper, lower = np.full(n, np.nan), np.full(n, np.nan)
    for i in range(2, n - 2):
        if h[i] > h[i + 1] and h[i] > h[i + 2] and h[i] >= h[i - 1] and h[i] >= h[i - 2]:
            upper[i] = h[i]
        if l[i] < l[i + 1] and l[i] < l[i + 2] and l[i] <= l[i - 1] and l[i] <= l[i - 2]:
            lower[i] = l[i]
    return [upper, lower], {}

# "Indicator_Templates" of Config_Setting.json: m_indicator_type + positional MT5 parameters (the order of the EA form)
TEMPLATE_TYPES = {
    "PSAR": ("SAR", ("step", "maximum")),
    "MA": ("MA", ("period", "shift", "method", "applied")),
    "BBands": ("BANDS", ("period", "shift", "deviation", "applied")),
    "Alligator": ("ALLIGATOR", ("jaw_period", "jaw_shift", "teeth_period", "teeth_shift", "lips_period", "lips_shift", "method", "applied")),
    "Ichimoku": ("ICHIMOKU", ("tenkan", "kijun", "senkou_b")),
    "Envelopes": ("ENVELOPES", ("period", "shift", "method", "applied", "deviation")),
    "FRAMA": ("FRAMA", ("period", "shift", "applied")),
    "AMA": ("AMA", ("ama_period", "fast", "slow", "shift", "applied")),
    "DEMA": ("DEMA", ("period", "shift", "applied")),
    "TEMA": ("TEMA", ("period", "shift", "applied")),
    "VIDYA": ("VIDYA", ("cmo_period", "ema_period", "shift", "applied")),
    "ADX": ("ADX", ("period",)),
    "ADX Wilder": ("ADXW", ("period",)),
    "StdDev": ("STDDEV", ("period", "shift", "method", "applied")),
    "RSI": ("RSI", ("period", "applied")),
    "MACD": ("MACD", ("fast", "slow", "signal", "applied")),
    "Stochastic Oscillator": ("STOCHASTIC", ("k", "d", "slowing", "method", "field")),
    "CCI": ("CCI", ("period", "applied")),
    "Momentum": ("MOMENTUM", ("period", "applied")),
    "DeMarker": ("DEMARKER", ("period",)),
    "Relative Vigor Index": ("RVI", ("period",)),
    "Williams' Percent Range": ("WPR", ("period",)),
    "OsMA": ("OSMA", ("fast", "slow", "signal", "applied")),
    "Triple Exponential Average": ("TRIX", ("period",)),
    "ATR": ("ATR", ("period",)),
    "Force Index": ("FORCE", ("period", "method", "volume")),
    "Awesome Oscillator": ("AO", ()),
    "Accelerator Oscillator": ("AC", ()),
    "Gator Oscillator": ("GATOR", ("jaw_period", "jaw_shift", "teeth_period", "teeth_shift", "lips_period", "lips_shift", "method", "applied")),
    "Bears Power": ("BEARS", ("period",)),
    "Bulls Power": ("BULLS", ("period",)),
    "Chaikin Oscillator": ("CHAIKIN", ("fast", "slow", "method", "volume")),
    "On Balance Volume": ("OBV", ("volume",)),
    "Accumulation/Distribution": ("AD", ("volume",)),
    "Money Flow Index": ("MFI", ("period",)),
    "Volumes": ("VOLUMES", ("volume",)),
    "Market Facilitation Index": ("BWMFI", ()),
    "Fractals": ("FRACTALS", ()),
}

def from_template(row):
    """(label, name, params) of one template row, None when Python does not calculate it (yet)."""
    kind = row.get("m_indicator_type")
    if kind not in TEMPLATE_TYPES:
        return None
    name, keys = TEMPLATE_TYPES[kind]
    values = row.get("m_indicator_params", [])
    if len(values) != len(keys):
        return None
    params = {key: str(value) for key, value in zip(keys, values)}
    return f"{kind}({','.join(str(v) for v in values)})", name, params

COMPUTE = {"SAR": sar, "MA": ma, "BANDS": bands, "ALLIGATOR": alligator, "ICHIMOKU": ichimoku, "ENVELOPES": envelopes,
           "FRAMA": frama, "AMA": ama, "DEMA": dema, "TEMA": tema, "VIDYA": vidya, "ADX": adx, "ADXW": adx_wilder,
           "STDDEV": stddev, "RSI": rsi, "MACD": macd, "STOCHASTIC": stochastic, "CCI": cci, "MOMENTUM": momentum,
           "DEMARKER": demarker, "RVI": rvi, "WPR": wpr, "OSMA": osma, "TRIX": trix, "ATR": atr, "FORCE": force,
           "AO": awesome, "AC": accelerator, "GATOR": gator, "BEARS": bears, "BULLS": bulls, "CHAIKIN": chaikin,
           "OBV": obv, "AD": accumulation, "MFI": mfi, "VOLUMES": volumes, "BWMFI": bw_mfi, "FRACTALS": fractals}

def compute(name, df, params):
    if name not in COMPUTE:
        raise ValueError(f"indicator {name} is not implemented in Python yet")
    return COMPUTE[name](df, params)
