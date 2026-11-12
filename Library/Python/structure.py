"""structure.py: BOS and CHoCH (the types BOS / CHoCH of Setting_BarInformation), V2 CMarketStructureControl. The close of a bar breaks the newest
confirmed swing that no close broke yet: a Swing High above the one before (HH) or a Swing Low below the one before (LL) is a BOS, a Swing High below
(LH) or a Swing Low above (HL) is a CHoCH. Up is BUY, down is SELL; a bar that breaks both ways is BUY. The swings are the ones of swing.py with the
parameters of Swing High / Swing Low; the swing before the broken one is confirmed at most lookback() bars before the break.
MQL: CBarSwing::FindBrokenHigh / FindBrokenLow, CBarBOS::FindBOS, CBarCHoCH::FindCHoCH say the same."""
import libdb
import swing

NAME_BOS = "BOS"
NAME_CHOCH = "CHoCH"


def lookback():
    """STRUCTURE_LOOKBACK, from the EA."""
    return libdb.setting_int("structure_lookback")


def context(high_params, low_params):
    """The bars a break needs before it: the swing before the broken one and the bars that make it a swing."""
    return lookback() + 2 * max(swing.context(high_params), swing.context(low_params))


def breaks(bars, params, high):
    """The breaks of the swings of a kind: a list of (bar index, beyond), beyond True when the broken swing is beyond the one before it (HH / LL)."""
    strength = swing.context(params)
    sw = swing.find_swings(bars, strength, swing.use_wick(params))
    limit = lookback()
    sw = sw[sw["type"] == ("HIGH" if high else "LOW")]
    index_of = {int(t): i for i, t in enumerate(bars["time"].to_numpy())}
    confirms = [index_of[int(t)] + strength for t in sw["time"]]   # the bar that confirms a swing: the reference from it on
    prices = sw["price"].to_numpy(dtype=float)
    close = bars["close"].to_numpy(dtype=float)
    found = []
    for r in range(1, len(confirms)):   # the first swing has none before it: not labelled, no break
        end = confirms[r + 1] if r + 1 < len(confirms) else len(close)   # a newer swing of the same kind takes its place
        for t in range(confirms[r], min(end, len(close))):
            if (close[t] > prices[r]) if high else (close[t] < prices[r]):
                if t - confirms[r - 1] <= limit:
                    above = prices[r] > prices[r - 1]   # swing.py: HH / HL when above the one before
                    found.append((t, above if high else not above))
                break   # broken once
    return found


def calculate(bos, bars, high_params, low_params, since=0, until=None):
    """The BOS (bos True) or the CHoCH of the bars with since < time (< until when it is given): a list of (bar time, side)."""
    times = bars["time"].to_numpy()
    rows = {}
    for high, params, side in ((True, high_params, "BUY"), (False, low_params, "SELL")):
        for t, beyond in breaks(bars, params, high):
            if beyond == bos and times[t] > since and (until is None or times[t] < until):
                rows.setdefault(int(times[t]), side)   # a bar that breaks both ways: BUY, as FindBOS / FindCHoCH look up first
    return sorted(rows.items())
