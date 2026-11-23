import glob
import json
import os
import select
import socket
import time
import traceback

import numpy as np

from data import TIMEFRAMES
from patterns import CANDLES, DIRECTIONS
from model import Model
from tradesync import TradeSync
from libdb import LibDatabase

READ_TIMEOUT = 0.016   # same rhythm as the EA timer
SEND_TIMEOUT = 30.0    # the EA reads on its timer, a big batch needs far longer than one read slice
POLL_INTERVAL = 0.2    # seconds between two new-bar checks
LISTEN_BACKLOG = 5
OTHER_TF_BARS = 5000   # bars of the TFs that are not the chart's the EA is given with a watch
COMMON_TFS = ["M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN1"]   # loaded first in the background, the other TFs follow
TRADES_INTERVAL = 0.5  # seconds between two looks at the trades of the terminal
LIVE_INTERVAL = 0.5    # seconds between two refreshes of the live state of the indicators
SOURCE_FILES = os.path.join(os.path.dirname(os.path.abspath(__file__)), "*.py")


def source_stamp():
    """Newest modification time of the Python sources: a change means this process runs old code."""
    return max((os.path.getmtime(path) for path in glob.glob(SOURCE_FILES)), default=0.0)


class Client:
    """One EA: its socket and what it asked for. Several EAs (one per chart) can be connected at once."""
    def __init__(self, conn):
        self.conn = conn
        self.buffer = b""
        self.pairs = []                # the pairs of its last init: the ones it shows
        self.symbols = []              # the symbols of its last init (Market Watch): Python calculates all of them on every TF
        self.watch_tfs = set()         # the TFs of the watched symbol that it shows
        self.watching = None           # (symbol, tf) of the chart: its symbol decides which pairs are sent, its TF is the one drawn
        self.watch_structures = False
        self.watch_signals = False
        self.watch_patterns = False
        self.watch_lifecycle = False
        self.watch_conditions = False
        self.watch_movements = False
        self.new_bar_events = False    # it tells which pairs got a new bar (cmd new_bar): Python does not have to look for them for it
        self.tagged = False            # asked for variants: every line it gets carries the variant after its type; one that did not gets the lines as they always were
        self.variants = [""]          # the ids of the Swing kinds it follows, in the order it asked
        self.variant_params = {"": (5, True)}   # id -> (strength, use_wick)


def variant_id(strength, use_wick):
    """"3b" = Swing of 3 candles on the body, "5w" = of 5 candles on the wicks."""
    return f"{int(strength)}{'w' if use_wick else 'b'}"


def tag_lines(lines, variant):
    """swing|XAUUSD|M5|... becomes swing|5w|XAUUSD|M5|...: the variant goes after the type of the line."""
    return [line.replace("|", "|" + variant + "|", 1) for line in lines] if variant else lines


class Server:
    def __init__(self, model, host="127.0.0.1", port=9090):
        self.models = {"": model}   # variant id -> the model that calculates for it; the first one is the one the data that does not depend on the Swing comes from
        self.host = host
        self.port = port
        self.stop = False
        self.clients = []
        self.last_poll = 0.0
        self.last_live = 0.0
        self.restart = False
        self.started_with = source_stamp()
        self.lib_db = LibDatabase()   # the database of the library: the account the terminal is logged in to has a row in it
        self.trade_sync = TradeSync(self.lib_db)   # the trades of the account, read from the terminal and written to its SQLite file; the EAs only read it
        self.last_trades = 0.0

    def source_changed(self):
        if source_stamp() == self.started_with:
            return False
        print("a source file changed - restarting")
        self.restart = True
        self.stop = True
        return True

    def run(self):
        listener = socket.socket()
        try:
            listener.bind((self.host, self.port))
        except OSError as error:
            print(f"cannot listen on {self.host}:{self.port} ({error}) - another instance is probably running")
            return
        listener.listen(LISTEN_BACKLOG)
        print(f"listening on {self.host}:{self.port}")
        while not self.stop:
            readable, _, _ = select.select([listener] + [client.conn for client in self.clients], [], [], READ_TIMEOUT)
            for sock in readable:
                if sock is listener:
                    conn, _ = listener.accept()
                    conn.settimeout(READ_TIMEOUT)
                    self.clients.append(Client(conn))
                    print(f"EA connected ({len(self.clients)} connected)")
                    continue
                client = next((c for c in self.clients if c.conn is sock), None)
                if client is not None:
                    try:
                        self.read(client)
                    except Exception:
                        traceback.print_exc()   # one bad client must not stop the server
                        self.drop(client)
            self.poll()
        for client in list(self.clients):
            self.drop(client)
        listener.close()
        for model in self.models.values():
            model.save_all()   # what the next start reads instead of calculating it

    def drop(self, client):
        if client in self.clients:
            self.clients.remove(client)
            print(f"EA disconnected ({len(self.clients)} connected)")   # the EA closes the socket on every chart change
        try:
            client.conn.close()
        except OSError:
            pass

    def read(self, client):
        try:
            chunk = client.conn.recv(65536)
        except socket.timeout:
            return
        except OSError as error:
            print(f"connection to the EA lost: {error}")
            self.drop(client)
            return
        if not chunk:
            self.drop(client)
            return
        client.buffer += chunk
        while b"\n" in client.buffer:
            line, client.buffer = client.buffer.split(b"\n", 1)
            if line.strip():
                self.handle(client, line)

    def primary(self):
        """The model that data which does not depend on the Swing (signals, patterns, the live state of the indicators) comes from: the first one."""
        return next(iter(self.models.values()), None)

    def send_new(self, client, variant, key, new_swings, new_structures, new_signals, new_patterns, new_lifecycle, new_conditions, new_movements):
        """What one new bar of a pair brings, for one variant, to one client. What does not depend on the Swing is sent with the first variant of the client only."""
        conn = client.conn
        tag = variant if client.tagged else ""
        shared = ("*" if client.tagged else "") if variant == client.variants[0] else None
        self.send_swings(conn, key, new_swings, tag)
        if client.watch_structures:
            self.send_structures(conn, key, new_structures, tag)
        if client.watch_signals and shared is not None:
            self.send_signals(conn, key, new_signals, shared)
        if client.watch_patterns and shared is not None:
            self.send_patterns(conn, key, new_patterns, shared)
        if client.watch_lifecycle:
            self.send_lifecycle(conn, key, new_lifecycle, tag)
        if client.watch_conditions:
            self.send_conditions(conn, key, new_conditions, tag)
        if client.watch_movements:
            self.send_movements(conn, key, new_movements, tag)

    def push(self, variant, found):
        """The new lines of the pairs that got a new bar go to the EAs that follow them."""
        for key, new_swings, new_structures, new_signals, new_patterns, new_lifecycle, new_conditions, new_movements in found:
            for client in list(self.clients):
                if variant not in client.variants:
                    continue
                if client.watching is None or key[0] != client.watching[0] or (key != client.watching and key[1] not in client.watch_tfs):
                    continue   # the EA gets the TFs of the symbol it watches that it shows
                try:
                    self.send_new(client, variant, key, new_swings, new_structures, new_signals, new_patterns, new_lifecycle, new_conditions, new_movements)
                except OSError:
                    self.drop(client)

    def new_bar(self, client, message):
        """The EA saw a new bar on these TFs of a symbol: those pairs are brought up to date now and the new lines go out."""
        client.new_bar_events = True
        symbol = message["symbol"]
        for variant, model in list(self.models.items()):
            found = []
            for tf in message.get("tfs", []):
                if (symbol, tf) in model.bars:
                    result = model.update_pair((symbol, tf))
                    if result is not None:
                        found.append(result)
            self.push(variant, found)

    def poll(self):
        now = time.monotonic()
        if now - self.last_poll < POLL_INTERVAL:
            return
        self.last_poll = now
        if self.source_changed():
            return
        if now - self.last_trades >= TRADES_INTERVAL:   # the trades are kept up to date whether an EA is connected or not
            self.last_trades = now
            try:
                self.trade_sync.poll()
            except Exception as error:
                print(f"trade sync failed: {error}")
            try:
                self.lib_db.watch_account()
            except Exception as error:
                print(f"library database failed: {error}")
        if not self.clients:
            return
        events_only = all(client.new_bar_events for client in self.clients)   # every EA tells the new bars: nothing to look for
        for variant, model in list(self.models.items()):
            if not events_only:
                try:
                    self.push(variant, model.check_new_bars())
                except Exception as error:
                    print(f"poll failed: {error}")
            try:
                model.save_dirty()   # a pair with new bars, written to the disk again (one per round)
            except Exception as error:
                print(f"cache not written: {error}")
            try:
                loaded = model.load_next()   # nobody asked for anything: the next pair that is calculated but not loaded yet
                if loaded is not None:
                    print(f"loaded {loaded['symbol']} {loaded['tf']}" + (f" ({loaded['error']})" if "error" in loaded else "") + (f" [{variant}]" if variant else "") + f", {len(model.queue)} to go")
            except Exception as error:
                print(f"background load failed: {error}")
        if now - self.last_live >= LIVE_INTERVAL:
            self.last_live = now
            try:
                self.primary().refresh_live()   # nobody asks: the data is kept up to date, whoever needs it asks and gets it at once
            except Exception as error:
                print(f"live refresh failed: {error}")

    def handle(self, client, line):
        conn = client.conn
        try:
            message = json.loads(line)
            cmd = message.get("cmd")
            if cmd == "quit":
                if len(self.clients) > 1:
                    print("quit requested by an EA, the others stay connected: Python keeps running")
                else:
                    print("quit requested by the EA")
                    self.stop = True
            elif cmd == "init":
                self.init(client, message)
            elif cmd == "watch":
                self.watch(client, message)
            elif cmd == "new_bar":
                self.new_bar(client, message)
            elif cmd == "candle_info":
                self.candle_info(client, message)
            elif cmd == "pre_trade_symbol_monitor":
                self.send_pre_trade_symbol_monitor(conn, self.primary().pre_trade_symbol_monitor())   # every loaded pair: the EA keeps what its tables need
            else:
                self.send(conn, {"event": "error", "message": f"unknown cmd {cmd}"})
        except OSError:
            self.drop(client)
        except Exception as error:
            try:
                self.send(conn, {"event": "error", "message": str(error)})
            except OSError:
                self.drop(client)

    def init(self, client, message):
        conn = client.conn
        client.pairs = message.get("pairs", [])
        client.symbols = message.get("symbols", [])
        try:
            self.lib_db.register_symbols(client.symbols)   # the Market Watch of the account: its lines in symbol_account (the EA sends init again when it changes)
        except Exception as error:
            print(f"library database (symbols) failed: {error}")
        shown, symbols = [], []   # what the model holds is the pairs of every connected EA: one must not drop the pairs of another
        for other in self.clients:
            for pair in other.pairs:
                if pair not in shown:
                    shown.append(pair)
            for symbol in other.symbols:
                if symbol not in symbols:
                    symbols.append(symbol)
        # Python calculates every symbol of the EA on every TF it knows; the EA decides what it shows (the pairs of its CSymbolTFManager).
        # About 12 MB a pair: 4 symbols on 21 TFs are about 1 GB. The common TFs are loaded first
        union = list(shown)
        for tf in sorted(TIMEFRAMES, key=lambda text: COMMON_TFS.index(text) if text in COMMON_TFS else len(COMMON_TFS)):
            for symbol in symbols:
                if [symbol, tf] not in union:
                    union.append([symbol, tf])
        # The kinds of Swing: an EA that asks for "variants" gets every kind it asked for, each line tagged; one that does not gets the one kind it always had
        client.variant_params = {}
        asked = message.get("variants")
        if asked:
            client.tagged = True
            client.variants = []
            for row in asked:
                strength, use_wick = int(row.get("strength", 5)), bool(row.get("use_wick", True))
                vid = variant_id(strength, use_wick)
                if vid not in client.variants:
                    client.variants.append(vid)
                    client.variant_params[vid] = (strength, use_wick)
        else:
            swing = message.get("swing", {})
            client.tagged = False
            client.variants = [""]
            client.variant_params[""] = (int(swing.get("strength", 5)), bool(swing.get("use_wick", True)))
        wanted = {}   # what every connected EA follows: the models are the union of it, and a kind nobody follows any more is dropped
        for other in self.clients:
            wanted.update(other.variant_params)
        for vid in list(self.models):
            if vid not in wanted:
                del self.models[vid]
        for vid in wanted:
            if vid not in self.models:
                self.models[vid] = Model(vid)
        total_ms, pairs, skipped = 0.0, 0, []
        for vid, (strength, use_wick) in wanted.items():
            report = self.models[vid].apply_config(union,
                                                   strength,
                                                   use_wick,
                                                   message.get("count", 0),
                                                   on_pair=lambda row, vid=vid: self.send(conn, {"event": "pair", **({"variant": vid} if client.tagged else {}), **row}),
                                                   indicators=message.get("indicators", []),
                                                   trendline=message.get("trendline", {}),
                                                   zone=message.get("zone", {}),
                                                   momentum=message.get("momentum", {}),
                                                   market_condition=message.get("condition", {}),
                                                   priority=shown)
            total_ms += report["total_ms"]
            pairs = max(pairs, len(report["pairs"]))
            skipped = report["skipped"]
        self.write(conn, ("timeframe_info|" + ";".join(TIMEFRAMES) + "\n").encode("utf-8"))   # every timeframe Python can serve, for any Symbol
        self.send(conn, {"event": "done", "total_ms": round(total_ms, 1), "pairs": pairs, "skipped": skipped, **({"variants": client.variants} if client.tagged else {})})

    def watch(self, client, message):
        conn = client.conn
        key = (message["symbol"], message["tf"])
        from_time = int(message.get("from_time", 0))
        signals_from = int(message.get("signals_from", from_time))
        models = [(vid, self.models[vid]) for vid in client.variants if vid in self.models]
        if not models or models[0][1].swings_since(key[0], key[1], from_time) is None:
            self.send(conn, {"event": "error", "message": f"{key[0]} {key[1]} is not loaded"})
            return
        client.watching = key
        client.watch_structures = bool(message.get("structures", False))
        client.watch_signals = bool(message.get("signals", False))
        client.watch_patterns = bool(message.get("patterns", False))
        client.watch_lifecycle = bool(message.get("lifecycle", False))
        client.watch_conditions = bool(message.get("conditions", False))
        client.watch_movements = bool(message.get("movements", False))
        client.watch_tfs = set(message["tfs"]) if "tfs" in message else set(tf for symbol, tf in client.pairs if symbol == key[0])
        reply = {"event": "watch", "symbol": key[0], "tf": key[1]}
        for vid, model in models:
            counts = self.send_pair(client, model, vid, key, from_time, signals_from)
            if vid == models[0][0]:
                reply.update(counts)
            # The other TFs of the symbol are sent too: the EA draws the chart's TF only, its candle window lists them all.
            # Only the bars the chart shows, and at most OTHER_TF_BARS of their own: a small TF under a big chart is not sent whole
            for other in model.keys_of(key[0]):
                if other != key and other[1] in client.watch_tfs:
                    since = model.time_of_bar(other, OTHER_TF_BARS)
                    self.send_pair(client, model, vid, other, max(from_time, since), max(signals_from, since))
        if client.tagged:
            reply["variants"] = client.variants
        self.send(conn, reply)

    def candle_info(self, client, message):
        """Every line that falls on one candle of the watched symbol, on every TF the EA shows: the candle window of the EA asks for it
        when the user picks a candle, whatever its age. The lines are the ones of a watch, the EA keeps them with the rest."""
        symbol, start = message["symbol"], int(message["time"])
        end = start + int(message["seconds"])
        for vid in client.variants:
            model = self.models.get(vid)
            if model is None:
                continue
            for key in model.keys_of(symbol):
                if key[1] in client.watch_tfs:
                    self.send_candle(client, model, vid, key, start, end)
        self.send(client.conn, {"event": "candle_info", "symbol": symbol, "time": start})

    def send_candle(self, client, model, variant, key, start, end):
        """The lines of one pair with their time in [start, end); nothing is sent (or printed) for what is empty."""
        conn = client.conn
        tag = variant if client.tagged else ""
        shared = ("*" if client.tagged else "") if variant == client.variants[0] else None

        def inside(frame, column):
            """The rows with their time in [start, end): the times are sorted, so two searches cut them out (a mask would read every row)."""
            if frame is None:
                return None
            values = frame[column].to_numpy()
            if len(values) and not frame[column].is_monotonic_increasing:
                return frame[(frame[column] >= start) & (frame[column] < end)]
            return frame.iloc[np.searchsorted(values, start, "left"):np.searchsorted(values, end, "left")]

        swings = inside(model.swings.get(key), "time")
        if swings is not None and len(swings):
            self.send_swings(conn, key, swings, tag)
        if client.watch_structures:
            structures = inside(model.structures.get(key), "break_time")
            if structures is not None and len(structures):
                self.send_structures(conn, key, structures, tag)
        if client.watch_signals and shared is not None:
            signals = inside(model.signals.get(key), "time")
            if signals is not None and len(signals):
                self.send_signals(conn, key, signals, shared)
        if client.watch_patterns and shared is not None:
            patterns = inside(model.patterns.get(key), "time")
            if patterns is not None and len(patterns):
                self.send_patterns(conn, key, patterns, shared)
        if client.watch_lifecycle:
            lifecycle = inside(model.lifecycle.get(key), "time")
            if lifecycle is not None and len(lifecycle):
                self.send_lifecycle(conn, key, lifecycle, tag)
        if client.watch_conditions:
            conditions = inside(model.conditions.get(key), "time")
            if conditions is not None and len(conditions):
                self.send_conditions(conn, key, conditions, tag)
        if client.watch_movements:
            movements = inside(model.movements.get(key), "end_time")   # a leg is on the candle where it ends
            if movements is not None and len(movements):
                self.send_movements(conn, key, movements, tag)

    def send_pair(self, client, model, variant, key, from_time, signals_from):
        """Send what the client asked for about one pair, for one variant; returns the counts."""
        conn = client.conn
        tag = variant if client.tagged else ""
        shared = ("*" if client.tagged else "") if variant == client.variants[0] else None   # what does not depend on the Swing is sent once
        swings = model.swings_since(key[0], key[1], from_time)
        self.send_swings(conn, key, swings, tag)
        counts = {"items": len(swings)}
        if client.watch_structures:
            structures = model.structures_since(key[0], key[1], from_time)
            self.send_structures(conn, key, structures, tag)
            counts["structures"] = len(structures)
        if client.watch_signals and shared is not None:
            signals = model.signals_since(key[0], key[1], signals_from)
            self.send_signals(conn, key, signals, shared)
            counts["signals"] = len(signals)
        if client.watch_patterns and shared is not None:
            patterns = model.patterns_since(key[0], key[1], signals_from)
            self.send_patterns(conn, key, patterns, shared)
            counts["patterns"] = len(patterns)
        if client.watch_lifecycle:
            lifecycle = model.lifecycle_since(key[0], key[1], signals_from)
            self.send_lifecycle(conn, key, lifecycle, tag)
            counts["lifecycle"] = len(lifecycle)
        if client.watch_conditions:
            conditions = model.conditions_since(key[0], key[1], from_time)
            self.send_conditions(conn, key, conditions, tag)
            counts["conditions"] = len(conditions)
        if client.watch_movements:
            movements = model.movements_since(key[0], key[1], from_time)
            self.send_movements(conn, key, movements, tag)
            counts["movements"] = len(movements)
        return counts

    def send_swings(self, conn, key, swings, tag=""):
        lines = [f"swing|{key[0]}|{key[1]}|{int(r.time)}|{int(r.confirmed_time)}|{r.type}|{float(r.price)!r}|{r.structure}"
                 for r in swings.itertuples()]
        lines = tag_lines(lines, tag)
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} swing line(s) for {key[0]} {key[1]}" + (f" [{tag}]" if tag else ""))

    def send_structures(self, conn, key, structures, tag=""):
        lines = [f"structure|{key[0]}|{key[1]}|{int(r.break_time)}|{int(r.swing_time)}|{r.type}|{r.dir}|{float(r.level)!r}|{r.phase}|{int(r.strong_time)}|{float(r.strong_price)!r}"
                 for r in structures.itertuples()]
        lines = tag_lines(lines, tag)
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} structure line(s) for {key[0]} {key[1]}" + (f" [{tag}]" if tag else ""))

    def send_signals(self, conn, key, signals, tag=""):
        lines = [f"signal|{key[0]}|{key[1]}|{int(r.time)}|{r.label}|{r.dir}|{int(r.template)}" for r in signals.itertuples()]
        lines = tag_lines(lines, tag)
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} signal line(s) for {key[0]} {key[1]}" + (f" [{tag}]" if tag else ""))

    def send_lifecycle(self, conn, key, events, tag=""):
        # one line per event; every line carries the two anchors, so a line can be drawn from any of its events. The reason is NONE when there is none
        lines = [f"lifecycle|{key[0]}|{key[1]}|{r.kind}|{int(r.origin_time)}|{int(r.time)}|{r.event}|{r.dir}|{int(r.t1)}|{float(r.p1)!r}|{int(r.t2)}|{float(r.p2)!r}|AUTO|{r.reason or 'NONE'}"
                 for r in events.itertuples()]
        lines = tag_lines(lines, tag)
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} lifecycle line(s) for {key[0]} {key[1]}" + (f" [{tag}]" if tag else ""))

    def send_conditions(self, conn, key, events, tag=""):
        lines = [f"condition|{key[0]}|{key[1]}|{int(r.time)}|{r.state}|{r.phase}" for r in events.itertuples()]
        lines = tag_lines(lines, tag)
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} condition line(s) for {key[0]} {key[1]}" + (f" [{tag}]" if tag else ""))

    def send_movements(self, conn, key, legs, tag=""):
        # movement|symbol|tf|time|start_time|start_price|end_time|end_price|dir|move|length_atr|bars|retracement|depth
        lines = [f"movement|{key[0]}|{key[1]}|{int(r.time)}|{int(r.start_time)}|{float(r.start_price)!r}|{int(r.end_time)}|{float(r.end_price)!r}|"
                 f"{r.dir}|{r.move}|{float(r.length_atr)!r}|{int(r.bars)}|{float(r.retracement)!r}|{r.depth}" for r in legs.itertuples()]
        lines = tag_lines(lines, tag)
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} movement line(s) for {key[0]} {key[1]}" + (f" [{tag}]" if tag else ""))

    def send_pre_trade_symbol_monitor(self, conn, states):
        lines = [f"pre_trade_symbol_monitor|{key[0]}|{key[1]}|{template}|{float(value)!r}|{float(previous)!r}|{direction}"
                 for key, rows in states for template, value, previous, direction in rows]
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        self.write(conn, (json.dumps({"event": "pre_trade_symbol_monitor", "lines": len(lines)}) + "\n").encode("utf-8"))   # the EA asks again after this one

    def send_patterns(self, conn, key, patterns, tag=""):
        info = "pattern_info|" + ";".join(f"{name}:{candles}:{DIRECTIONS[name]}" for name, candles in CANDLES.items())   # the catalog: every pattern, its candle count and its sides
        lines = [info] + tag_lines([f"pattern|{key[0]}|{key[1]}|{int(r.time)}|{r.label}|{r.dir}" for r in patterns.itertuples()], tag)   # Inside Bar comes as BOTH: no marker, only the candle information window shows it
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} pattern line(s) for {key[0]} {key[1]}")

    def write(self, conn, data):
        conn.settimeout(SEND_TIMEOUT)
        try:
            conn.sendall(data)
        finally:
            conn.settimeout(READ_TIMEOUT)

    def send(self, conn, message):
        text = json.dumps(message)
        print(text)
        self.write(conn, (text + "\n").encode("utf-8"))
