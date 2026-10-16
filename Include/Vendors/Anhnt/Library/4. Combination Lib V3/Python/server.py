import glob
import json
import os
import select
import socket
import time
import traceback

from data import TIMEFRAMES
from patterns import CANDLES, DIRECTIONS
from trades import TradeStores

READ_TIMEOUT = 0.016   # same rhythm as the EA timer
SEND_TIMEOUT = 30.0    # the EA reads on its timer, a big batch needs far longer than one read slice
POLL_INTERVAL = 0.2    # seconds between two new-bar checks
LISTEN_BACKLOG = 5
OTHER_TF_BARS = 5000   # bars of the TFs that are not the chart's the EA is given with a watch
COMMON_TFS = ["M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN1"]   # loaded first in the background, the other TFs follow
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


class Server:
    def __init__(self, model, host="127.0.0.1", port=9090):
        self.model = model
        self.host = host
        self.port = port
        self.stop = False
        self.clients = []
        self.last_poll = 0.0
        self.last_live = 0.0
        self.restart = False
        self.started_with = source_stamp()
        self.trade_stores = TradeStores()   # the deals and the orders of each account, in SQLite

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
        self.model.save_all()   # what the next start reads instead of calculating it

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

    def poll(self):
        now = time.monotonic()
        if now - self.last_poll < POLL_INTERVAL:
            return
        self.last_poll = now
        if self.source_changed() or not self.clients:
            return
        try:
            for key, new_swings, new_structures, new_signals, new_patterns, new_lifecycle, new_conditions, new_movements in self.model.check_new_bars():
                for client in list(self.clients):
                    if client.watching is None or key[0] != client.watching[0] or (key != client.watching and key[1] not in client.watch_tfs):
                        continue   # the EA gets the TFs of the symbol it watches that it shows
                    try:
                        conn = client.conn
                        self.send_swings(conn, key, new_swings)
                        if client.watch_structures:
                            self.send_structures(conn, key, new_structures)
                        if client.watch_signals:
                            self.send_signals(conn, key, new_signals)
                        if client.watch_patterns:
                            self.send_patterns(conn, key, new_patterns)
                        if client.watch_lifecycle:
                            self.send_lifecycle(conn, key, new_lifecycle)
                        if client.watch_conditions:
                            self.send_conditions(conn, key, new_conditions)
                        if client.watch_movements:
                            self.send_movements(conn, key, new_movements)
                    except OSError:
                        self.drop(client)
        except Exception as error:
            print(f"poll failed: {error}")
        try:
            self.model.save_dirty()   # a pair with new bars, written to the disk again (one per round)
        except Exception as error:
            print(f"cache not written: {error}")
        try:
            loaded = self.model.load_next()   # nobody asked for anything: the next pair that is calculated but not loaded yet
            if loaded is not None:
                print(f"loaded {loaded['symbol']} {loaded['tf']}" + (f" ({loaded['error']})" if "error" in loaded else "") + f", {len(self.model.queue)} to go")
        except Exception as error:
            print(f"background load failed: {error}")
        if now - self.last_live >= LIVE_INTERVAL:
            self.last_live = now
            try:
                self.model.refresh_live()   # nobody asks: the data is kept up to date, whoever needs it asks and gets it at once
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
            elif cmd == "trades":
                count = self.trade_stores.store(message)   # no answer: the EA sends again whatever it is not sure of, a line is written by its ticket
                print(f"stored {count} trade line(s) of account {message.get('account')}")
            elif cmd == "pre_trade_symbol_monitor":
                self.send_pre_trade_symbol_monitor(conn, self.model.pre_trade_symbol_monitor())   # every loaded pair: the EA keeps what its tables need
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
        swing = message.get("swing", {})
        report = self.model.apply_config(union,
                                         swing.get("strength", 5),
                                         swing.get("use_wick", True),
                                         message.get("count", 0),
                                         on_pair=lambda row: self.send(conn, {"event": "pair", **row}),
                                         indicators=message.get("indicators", []),
                                         trendline=message.get("trendline", {}),
                                         zone=message.get("zone", {}),
                                         momentum=message.get("momentum", {}),
                                         market_condition=message.get("condition", {}),
                                         priority=shown)
        self.write(conn, ("timeframe_info|" + ";".join(TIMEFRAMES) + "\n").encode("utf-8"))   # every timeframe Python can serve, for any Symbol
        self.send(conn, {"event": "done", "total_ms": report["total_ms"], "pairs": len(report["pairs"]), "skipped": report["skipped"]})

    def watch(self, client, message):
        conn = client.conn
        key = (message["symbol"], message["tf"])
        from_time = int(message.get("from_time", 0))
        signals_from = int(message.get("signals_from", from_time))
        if self.model.swings_since(key[0], key[1], from_time) is None:
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
        reply.update(self.send_pair(client, key, from_time, signals_from))
        # The other TFs of the symbol are sent too: the EA draws the chart's TF only, its candle window lists them all.
        # Only the bars the chart shows, and at most OTHER_TF_BARS of their own: a small TF under a big chart is not sent whole
        for other in self.model.keys_of(key[0]):
            if other != key and other[1] in client.watch_tfs:
                since = self.model.time_of_bar(other, OTHER_TF_BARS)
                self.send_pair(client, other, max(from_time, since), max(signals_from, since))
        self.send(conn, reply)

    def send_pair(self, client, key, from_time, signals_from):
        """Send what the client asked for about one pair; returns the counts."""
        conn = client.conn
        swings = self.model.swings_since(key[0], key[1], from_time)
        self.send_swings(conn, key, swings)
        counts = {"items": len(swings)}
        if client.watch_structures:
            structures = self.model.structures_since(key[0], key[1], from_time)
            self.send_structures(conn, key, structures)
            counts["structures"] = len(structures)
        if client.watch_signals:
            signals = self.model.signals_since(key[0], key[1], signals_from)
            self.send_signals(conn, key, signals)
            counts["signals"] = len(signals)
        if client.watch_patterns:
            patterns = self.model.patterns_since(key[0], key[1], signals_from)
            self.send_patterns(conn, key, patterns)
            counts["patterns"] = len(patterns)
        if client.watch_lifecycle:
            lifecycle = self.model.lifecycle_since(key[0], key[1], signals_from)
            self.send_lifecycle(conn, key, lifecycle)
            counts["lifecycle"] = len(lifecycle)
        if client.watch_conditions:
            conditions = self.model.conditions_since(key[0], key[1], from_time)
            self.send_conditions(conn, key, conditions)
            counts["conditions"] = len(conditions)
        if client.watch_movements:
            movements = self.model.movements_since(key[0], key[1], from_time)
            self.send_movements(conn, key, movements)
            counts["movements"] = len(movements)
        return counts

    def send_swings(self, conn, key, swings):
        lines = [f"swing|{key[0]}|{key[1]}|{int(r.time)}|{int(r.confirmed_time)}|{r.type}|{float(r.price)!r}|{r.structure}"
                 for r in swings.itertuples()]
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} swing line(s) for {key[0]} {key[1]}")

    def send_structures(self, conn, key, structures):
        lines = [f"structure|{key[0]}|{key[1]}|{int(r.break_time)}|{int(r.swing_time)}|{r.type}|{r.dir}|{float(r.level)!r}|{r.phase}|{int(r.strong_time)}|{float(r.strong_price)!r}"
                 for r in structures.itertuples()]
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} structure line(s) for {key[0]} {key[1]}")

    def send_signals(self, conn, key, signals):
        lines = [f"signal|{key[0]}|{key[1]}|{int(r.time)}|{r.label}|{r.dir}|{int(r.template)}" for r in signals.itertuples()]
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} signal line(s) for {key[0]} {key[1]}")

    def send_lifecycle(self, conn, key, events):
        # one line per event; every line carries the two anchors, so a line can be drawn from any of its events. The reason is NONE when there is none
        lines = [f"lifecycle|{key[0]}|{key[1]}|{r.kind}|{int(r.origin_time)}|{int(r.time)}|{r.event}|{r.dir}|{int(r.t1)}|{float(r.p1)!r}|{int(r.t2)}|{float(r.p2)!r}|AUTO|{r.reason or 'NONE'}"
                 for r in events.itertuples()]
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} lifecycle line(s) for {key[0]} {key[1]}")

    def send_conditions(self, conn, key, events):
        lines = [f"condition|{key[0]}|{key[1]}|{int(r.time)}|{r.state}|{r.phase}" for r in events.itertuples()]
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} condition line(s) for {key[0]} {key[1]}")

    def send_movements(self, conn, key, legs):
        # movement|symbol|tf|time|start_time|start_price|end_time|end_price|dir|move|length_atr|bars|retracement|depth
        lines = [f"movement|{key[0]}|{key[1]}|{int(r.time)}|{int(r.start_time)}|{float(r.start_price)!r}|{int(r.end_time)}|{float(r.end_price)!r}|"
                 f"{r.dir}|{r.move}|{float(r.length_atr)!r}|{int(r.bars)}|{float(r.retracement)!r}|{r.depth}" for r in legs.itertuples()]
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} movement line(s) for {key[0]} {key[1]}")

    def send_pre_trade_symbol_monitor(self, conn, states):
        lines = [f"pre_trade_symbol_monitor|{key[0]}|{key[1]}|{template}|{float(value)!r}|{float(previous)!r}|{direction}"
                 for key, rows in states for template, value, previous, direction in rows]
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        self.write(conn, (json.dumps({"event": "pre_trade_symbol_monitor", "lines": len(lines)}) + "\n").encode("utf-8"))   # the EA asks again after this one

    def send_patterns(self, conn, key, patterns):
        info = "pattern_info|" + ";".join(f"{name}:{candles}:{DIRECTIONS[name]}" for name, candles in CANDLES.items())   # the catalog: every pattern, its candle count and its sides
        lines = [info] + [f"pattern|{key[0]}|{key[1]}|{int(r.time)}|{r.label}|{r.dir}" for r in patterns.itertuples()]   # Inside Bar comes as BOTH: no marker, only the candle information window shows it
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
