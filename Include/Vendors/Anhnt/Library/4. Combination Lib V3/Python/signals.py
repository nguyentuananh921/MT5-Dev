"""Signal rules of the V2 indicator wrappers (CSignalSAR, CSignalMA, CSignalOscillator, CSignalTwoLineCross,
CSignalZeroCross, CSignalBollinger, CSignalEnvelopes, CSignalADX, CSignalFractals) on the buffers of one indicator.
ATR and Volumes have no direction: no rule, never a signal.

directions(): one value per bar - BUY (1), SELL (-1) or NONE (0), the rule of ComputeAt().
flips():      the entries of the history - a bar whose direction is not NONE and differs from the previous bar's.
"""
import numpy as np

BUY, SELL, NONE = 1, -1, 0

RSI_OVERBOUGHT = 70.0
RSI_OVERSOLD = 30.0
ADX_MIN_STRENGTH = 0.0   # 0 = no gate


def _previous(values):
    out = np.empty_like(values, dtype=float)
    out[0] = np.nan
    out[1:] = values[:-1]
    return out

def _direction(buy, sell):
    return np.where(buy, BUY, np.where(sell, SELL, NONE)).astype(np.int8)

def sar(buffers, bars, params):
    value, close = np.asarray(buffers[0], dtype=float), bars["close"].to_numpy(dtype=float)
    return _direction(value < close, value > close)   # SAR below the close = BUY (uptrend)

def ma(buffers, bars, params):
    value = np.asarray(buffers[0], dtype=float)
    previous = _previous(value)
    return _direction(value > previous, value < previous)   # rising line = BUY

def rsi(buffers, bars, params):
    value = np.asarray(buffers[0], dtype=float)
    previous = _previous(value)
    return _direction((previous <= RSI_OVERSOLD) & (value > RSI_OVERSOLD),       # left the oversold zone upward
                      (previous >= RSI_OVERBOUGHT) & (value < RSI_OVERBOUGHT))   # left the overbought zone downward

def macd(buffers, bars, params):
    main, signal = np.asarray(buffers[0], dtype=float), np.asarray(buffers[1], dtype=float)
    main_previous, signal_previous = _previous(main), _previous(signal)
    return _direction((main > signal) & (main_previous <= signal_previous),
                      (main < signal) & (main_previous >= signal_previous))

def bands(buffers, bars, params):
    middle, close = np.asarray(buffers[0], dtype=float), bars["close"].to_numpy(dtype=float)
    return _direction(close > middle, close < middle)   # the MidBand cross is the primary signal

def adx(buffers, bars, params):
    strength = np.asarray(buffers[0], dtype=float)
    plus, minus = np.asarray(buffers[1], dtype=float), np.asarray(buffers[2], dtype=float)
    plus_previous, minus_previous = _previous(plus), _previous(minus)
    buy = (plus > minus) & (plus_previous <= minus_previous)
    sell = (plus < minus) & (plus_previous >= minus_previous)
    if ADX_MIN_STRENGTH > 0.0:
        gate = strength >= ADX_MIN_STRENGTH
        buy, sell = buy & gate, sell & gate
    return _direction(buy, sell)

def oscillator(overbought, oversold):
    def rule(buffers, bars, params):
        value = np.asarray(buffers[0], dtype=float)
        before = _previous(value)
        return _direction((before <= oversold) & (value > oversold), (before >= overbought) & (value < overbought))
    return rule

def zero_cross(level=0.0):
    def rule(buffers, bars, params):
        value = np.asarray(buffers[0], dtype=float)
        before = _previous(value)
        return _direction((value > level) & (before <= level), (value < level) & (before >= level))
    return rule

def two_line_cross(main_buffer, signal_buffer, overbought=0.0, oversold=0.0):
    def rule(buffers, bars, params):
        main, signal = np.asarray(buffers[main_buffer], dtype=float), np.asarray(buffers[signal_buffer], dtype=float)
        main_before, signal_before = _previous(main), _previous(signal)
        buy = (main > signal) & (main_before <= signal_before)
        sell = (main < signal) & (main_before >= signal_before)
        if overbought > 0.0 or oversold > 0.0:   # a buy only from the oversold side, a sell only from the overbought side
            buy, sell = buy & (main <= oversold), sell & (main >= overbought)
        return _direction(buy, sell)
    return rule

def envelopes(buffers, bars, params):
    upper, lower, close = np.asarray(buffers[0], dtype=float), np.asarray(buffers[1], dtype=float), bars["close"].to_numpy(dtype=float)
    return _direction(close < lower, close > upper)   # closed below the lower band = BUY, above the upper band = SELL

def fractals(buffers, bars, params):
    # a fractal is known two bars after its middle bar: the signal is placed on that confirming bar
    upper, lower = ~np.isnan(np.asarray(buffers[0], dtype=float)), ~np.isnan(np.asarray(buffers[1], dtype=float))
    upper_known, lower_known = np.zeros(len(upper), dtype=bool), np.zeros(len(lower), dtype=bool)
    upper_known[2:], lower_known[2:] = upper[:-2], lower[:-2]
    return _direction(lower_known & ~upper_known, upper_known)   # an up fractal = swing high = SELL, a down fractal = BUY

RULES = {"SAR": sar, "MA": ma, "RSI": rsi, "MACD": macd, "BANDS": bands, "ADX": adx,
         "ADXW": adx,
         "AMA": ma, "FRAMA": ma, "DEMA": ma, "TEMA": ma, "VIDYA": ma,
         "STDDEV": ma, "AD": ma, "BWMFI": ma,   # no natural direction: the slope stands in, as in V2
         "ENVELOPES": envelopes,
         "ALLIGATOR": two_line_cross(0, 2), "STOCHASTIC": two_line_cross(0, 1, 80.0, 20.0), "RVI": two_line_cross(0, 1),
         "ICHIMOKU": two_line_cross(0, 1),
         "CCI": oscillator(100.0, -100.0), "DEMARKER": oscillator(0.7, 0.3), "WPR": oscillator(-20.0, -80.0), "MFI": oscillator(80.0, 20.0),
         "AO": zero_cross(), "AC": zero_cross(), "FORCE": zero_cross(), "OSMA": zero_cross(), "TRIX": zero_cross(),
         "CHAIKIN": zero_cross(), "OBV": zero_cross(), "BEARS": zero_cross(), "BULLS": zero_cross(), "GATOR": zero_cross(),
         "MOMENTUM": zero_cross(100.0),
         "FRACTALS": fractals}

def directions(name, buffers, bars, params):
    if name not in RULES:
        return np.zeros(len(bars), dtype=np.int8)   # ATR, Volumes: no direction
    with np.errstate(invalid="ignore"):   # NaN compares as False = NONE
        return RULES[name](buffers, bars, params)

def flips(direction):
    previous = np.empty_like(direction)
    previous[0] = direction[0]   # the first bar has no previous bar: never a flip
    previous[1:] = direction[:-1]
    return np.where((direction != NONE) & (direction != previous), direction, NONE).astype(np.int8)