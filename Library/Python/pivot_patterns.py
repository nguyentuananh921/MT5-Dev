"""pivot_patterns.py: the pivot patterns (Harmonic, Chart Pattern) of Setting_BarInformation. A pattern is N alternating pivots, the pivots are the swings of
swing.py with the parameters of Swing High / Swing Low; two of a kind in a row keep the more extreme (49. 23141 QM, AddPivotToZigZag), a bar with both swings
is a high. Its row is on the bar of the last pivot, known when the swing of that pivot is confirmed (CONFIRM): `since` is compared with that bar. FOUND
(the last pivot a Pivot Point Reversal, live) is the EA's only, it is not saved.
MQL: CBarPattern::Pivots, RuleXABCD, RuleABCD, RuleThreeDrives, RuleFiveDrives, RuleHeadShoulders, RuleDoubleTopBottom, RuleQuasimodo say the same.
Reference: Allan Munene Mutiiria\\Automating Trading Strategies (the rule of each EA)."""
import bisect

import structure
import swing

# the param names of Setting_BarSetup (BarDefines.mqh BAR_PARAM_*)
TOLERANCE, AB_MIN, AB_MAX, BC_MIN, BC_MAX, CD_MIN, CD_MAX = "tolerance", "ab_min", "ab_max", "bc_min", "bc_max", "cd_min", "cd_max"
SHOULDER_TOLERANCE, TROUGH_TOLERANCE = "shoulder_tolerance_points", "trough_tolerance_points"
MIN_BARS, MAX_BARS, BARS_MULTIPLIER, LEG_BALANCE = "min_bars", "max_bars", "bars_multiplier", "leg_balance"


def _xabcd(name, p, hi, params, point):
    """X A B C D, the legs measured the way of X (a high X: Sell at D). Gartley 29, Bat 28, Butterfly 08, Crab 27, Cypher 15, Shark 33."""
    d = 1.0 if hi[0] else -1.0
    x, a, b, c, dd = p
    xa = d * (x - a)
    if xa <= 0:
        return None
    ab, bc, cd, ad, xc = d * (b - a), d * (b - c), d * (dd - c), d * (dd - a), d * (x - c)
    beyond_x, inside_x = d * (dd - x) > 0, d * (dd - x) < 0
    tol = params.get(TOLERANCE, 0.0)
    if name == "Gartley":
        holds = abs(ab - 0.618 * xa) <= tol * xa and ab > 0 and 0.382 * ab <= bc <= 0.886 * ab and abs(ad - 0.786 * xa) <= tol * xa and inside_x
    elif name == "Bat":
        holds = abs(ab - 0.5 * xa) <= tol * xa and ab > 0 and 0.382 * ab <= bc <= 0.886 * ab and abs(ad - 0.886 * xa) <= tol * xa and inside_x
    elif name == "Crab":
        holds = abs(ab - 0.618 * xa) <= tol * xa and ab > 0 and 0.382 * ab <= bc <= 0.886 * ab and abs(ad - 1.618 * xa) <= tol * xa and beyond_x
    elif name == "Butterfly":
        holds = abs(ab - 0.786 * xa) <= tol * xa and 0.382 * xa <= bc <= 0.886 * xa and 1.27 * xa <= cd <= 1.618 * xa and beyond_x
    elif name == "Cypher":
        holds = 0.382 * xa <= ab <= 0.618 * xa and 1.272 * ab <= bc <= 1.414 * ab and xc > 0 and abs(cd - 0.786 * xc) <= tol * xc and beyond_x
    elif name == "Shark":
        holds = (params[AB_MIN] * xa <= ab <= params[AB_MAX] * xa and params[BC_MIN] * ab <= bc <= params[BC_MAX] * ab
                 and params[CD_MIN] * bc <= cd <= params[CD_MAX] * bc and d * (dd - b) > 0)
    else:
        holds = False
    return ("SELL" if hi[4] else "BUY") if holds else None


def _ab_cd(p, hi, params):
    """AB=CD (30. 19442): BC a Fibonacci retracement of AB, CD its reciprocal extension of BC, D beyond B."""
    d = 1.0 if hi[0] else -1.0
    a, b, c, dd = p
    ab, bc, cd = d * (a - b), d * (c - b), d * (c - dd)
    if ab <= 0 or bc <= 0:
        return None
    retrace, extension, tol = bc / ab, cd / bc, params.get(TOLERANCE, 0.0)
    valid = any(abs(retrace - r) <= tol and abs(extension - e) <= tol
                for r, e in zip((0.382, 0.5, 0.618, 0.786, 0.886), (2.618, 2.0, 1.618, 1.272, 1.13)))
    if not valid or not d * (b - dd) > 0:
        return None
    return "SELL" if hi[3] else "BUY"


def _three_drives(p, hi, params):
    """3 Drives (31. 19449): each drive an extension of the retracement before it, the retracements 0.618 / 0.786."""
    d = 1.0 if hi[0] else -1.0
    a, b, c, dd, e, f = p
    tol = params.get(TOLERANCE, 0.0)
    drive1 = d * (a - b)
    if drive1 <= 0:
        return None
    retrace_a, drive2, retrace_b, drive3 = d * (c - b), d * (c - dd), d * (e - dd), d * (e - f)
    near = lambda value, levels, base: any(abs(value - lv * base) <= tol * base for lv in levels)
    retr, ext = (0.618, 0.786), (1.13, 1.272, 1.618)
    if near(retrace_a, retr, drive1) and near(drive2, ext, retrace_a) and near(retrace_b, retr, drive2) and near(drive3, ext, retrace_b) \
            and d * (dd - f) > 0 and d * (b - dd) > 0:
        return "SELL" if hi[5] else "BUY"
    return None


def _five_drives(p, hi, params):
    """5 Drives (32. 19463): AB 1.13-1.618 of XA, BC 1.618-2.24 of AB, CD 0.5 of BC and equal to AB."""
    d = 1.0 if hi[0] else -1.0
    _, b, c, dd, e, f = p
    tol = params.get(TOLERANCE, 0.0)
    xa, ab, bc, cd = d * (c - b), d * (c - dd), d * (e - dd), d * (e - f)
    if xa <= 0:
        return None
    if 1.13 * xa <= ab <= 1.618 * xa and 1.618 * ab <= bc <= 2.24 * ab and abs(cd - 0.5 * bc) <= tol * bc and abs(cd - ab) <= tol * ab \
            and d * (e - c) > 0 and d * (f - b) > 0:
        return "SELL" if hi[5] else "BUY"
    return None


def _head_shoulders(idx, p, hi, params, point):
    """Head & Shoulders, Inverse (13. 17618): the head beyond both shoulders, shoulders and troughs level within their tolerance (points),
    the sides min_bars-max_bars bars and uniform (bars_multiplier)."""
    d = 1.0 if hi[0] else -1.0
    ls, t1, h, t2, rs = p
    if not (d * (h - ls) > 0 and d * (h - rs) > 0):
        return None
    if not (abs(ls - rs) < params[SHOULDER_TOLERANCE] * point and abs(t1 - t2) < params[TROUGH_TOLERANCE] * point):
        return None
    ls_to_head, head_to_rs = idx[2] - idx[0], idx[4] - idx[2]
    lo, hi_bars = int(params[MIN_BARS]), int(params[MAX_BARS])
    if not (lo <= ls_to_head <= hi_bars and lo <= head_to_rs <= hi_bars):
        return None
    shorter = min(ls_to_head, head_to_rs)
    if ls_to_head > shorter * params[BARS_MULTIPLIER] or head_to_rs > shorter * params[BARS_MULTIPLIER]:
        return None
    return "SELL" if hi[4] else "BUY"


def _double_top_bottom(idx, p, hi, params):
    """Double Top / Bottom (53. 23576): two peaks within tolerance % of the height over the neckline, far enough apart, the legs balanced."""
    d = 1.0 if hi[2] else -1.0
    p1, n, p2 = p
    height = d * ((p1 + p2) / 2.0 - n)
    if height <= 0 or abs(p1 - p2) > params[TOLERANCE] / 100.0 * height:
        return None
    min_bars = int(params[MIN_BARS])
    if min_bars > 0 and idx[2] - idx[0] < min_bars:
        return None
    balance = params[LEG_BALANCE]
    if balance > 0:
        leg_a, leg_b = idx[1] - idx[0], idx[2] - idx[1]
        if leg_a <= 0 or leg_b <= 0 or 100.0 * min(leg_a, leg_b) / max(leg_a, leg_b) < balance:
            return None
    return "SELL" if hi[2] else "BUY"


def _quasimodo(p, hi):
    """Quasimodo (49. 23141): shoulder, leg, head beyond the shoulder, the last pivot beyond the leg. A high shoulder: the bearish QM (Sell)."""
    d = 1.0 if hi[0] else -1.0
    s, l, h, b = p
    if d * (h - s) > 0 and d * (s - l) > 0 and d * (l - b) > 0:
        return "SELL" if hi[0] else "BUY"
    return None


# name (Setting_BarInformation) -> pivots of the pattern, its rule(idx, prices, highs, params, point)
RULES = {
    "Gartley": (5, lambda i, p, h, pr, pt: _xabcd("Gartley", p, h, pr, pt)),
    "Bat": (5, lambda i, p, h, pr, pt: _xabcd("Bat", p, h, pr, pt)),
    "Butterfly": (5, lambda i, p, h, pr, pt: _xabcd("Butterfly", p, h, pr, pt)),
    "Crab": (5, lambda i, p, h, pr, pt: _xabcd("Crab", p, h, pr, pt)),
    "Cypher": (5, lambda i, p, h, pr, pt: _xabcd("Cypher", p, h, pr, pt)),
    "Shark": (5, lambda i, p, h, pr, pt: _xabcd("Shark", p, h, pr, pt)),
    "AB=CD": (4, lambda i, p, h, pr, pt: _ab_cd(p, h, pr)),
    "3 Drives": (6, lambda i, p, h, pr, pt: _three_drives(p, h, pr)),
    "5 Drives": (6, lambda i, p, h, pr, pt: _five_drives(p, h, pr)),
    "Head & Shoulders": (5, lambda i, p, h, pr, pt: _head_shoulders(i, p, h, pr, pt)),
    "Double Top / Bottom": (3, lambda i, p, h, pr, pt: _double_top_bottom(i, p, h, pr)),
    "Quasimodo": (4, lambda i, p, h, pr, pt: _quasimodo(p, h)),
}


def context(high_params, low_params):
    """The bars a pattern needs before its last pivot: the pivots back to STRUCTURE_LOOKBACK and the bars that make them swings."""
    return structure.context(high_params, low_params)


def right(high_params, low_params):
    """The bars after the last pivot that confirm it (its swing)."""
    return max(swing.context(high_params), swing.context(low_params))


def _swings(bars, high_params, low_params):
    """The pivots by bar index: {index: (is_high, price)}, a bar with both swings is a high; the strength of each kind."""
    index_of = {int(t): i for i, t in enumerate(bars["time"].to_numpy())}
    strength_high, strength_low = swing.context(high_params), swing.context(low_params)
    highs = swing.find_swings(bars, strength_high, swing.use_wick(high_params))
    lows = swing.find_swings(bars, strength_low, swing.use_wick(low_params))
    high_at = {index_of[int(t)]: float(p) for t, p in zip(highs.loc[highs["type"] == "HIGH", "time"], highs.loc[highs["type"] == "HIGH", "price"])}
    low_at = {index_of[int(t)]: float(p) for t, p in zip(lows.loc[lows["type"] == "LOW", "time"], lows.loc[lows["type"] == "LOW", "price"])}
    return high_at, low_at, strength_high, strength_low


def _pivots(d_index, d_high, d_price, count, order, kinds, prices, lookback):
    """The `count` alternating pivots ending at the last one (the oldest first), as CBarPattern::Pivots: None when there are not enough, or a pivot
    of the same kind right before it is more extreme."""
    r_idx, r_price, r_high = [d_index], [d_price], [d_high]
    pos = bisect.bisect_left(order, d_index) - 1
    oldest = d_index - lookback
    while pos >= 0 and order[pos] >= oldest and len(r_idx) <= count:
        i = order[pos]
        kind, value = kinds[i], prices[i]
        pos -= 1
        if kind == r_high[-1]:
            if (value > r_price[-1]) if kind else (value < r_price[-1]):
                if len(r_idx) == 1:
                    return None
                r_idx[-1], r_price[-1] = i, value
            continue
        r_idx.append(i)
        r_price.append(value)
        r_high.append(kind)
    if len(r_idx) < count:
        return None
    r_idx, r_price, r_high = r_idx[:count][::-1], r_price[:count][::-1], r_high[:count][::-1]
    return r_idx, r_price, r_high


def calculate(name, bars, params, high_params, low_params, since=0, until=None):
    """The CONFIRM rows of a pivot pattern: a list of (bar time of the last pivot, side), the bar that confirms it after since (its pivot before
    until when it is given). At a confirming bar a high last pivot is tried first, as CBarPattern::FindPivot."""
    count, rule = RULES[name]
    times = bars["time"].to_numpy()
    point = float(bars.attrs.get("point") or 0.0)
    high_at, low_at, strength_high, strength_low = _swings(bars, high_params, low_params)
    kinds, prices = {}, {}
    for i, p in low_at.items():
        kinds[i], prices[i] = False, p
    for i, p in high_at.items():   # a bar with both: the high
        kinds[i], prices[i] = True, p
    order = sorted(kinds)
    lookback = structure.lookback()
    confirms = sorted({d + strength_high for d in high_at} | {d + strength_low for d in low_at})
    rows = {}
    for c in confirms:
        if c >= len(times) or int(times[c]) <= since:
            continue
        for high in (True, False):
            d = c - (strength_high if high else strength_low)
            at = high_at if high else low_at
            if d not in at:
                continue
            chain = _pivots(d, high, at[d], count, order, kinds, prices, lookback)
            if chain is None:
                continue
            side = rule(chain[0], chain[1], chain[2], params, point)
            if side is None:
                continue
            if until is None or int(times[d]) < until:
                rows.setdefault(int(times[d]), side)
            break
    return sorted(rows.items())
