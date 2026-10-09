import glob
import json
import os
import select
import socket
import time
import traceback

from patterns import CANDLES, DIRECTIONS

READ_TIMEOUT = 0.016   # same rhythm as the EA timer
SEND_TIMEOUT = 30.0    # the EA reads on its timer, a big batch needs far longer than one read slice
POLL_INTERVAL = 0.2    # seconds between two new-bar checks
LISTEN_BACKLOG = 5
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
        self.pairs = []                # the pairs of its last init
        self.watching = None           # (symbol, tf) of the chart it draws
        self.watch_structures = False
        self.watch_signals = False
        self.watch_patterns = False
        self.pre_trade_symbol = None   # symbol of the PreTradeSymbolMonitor table of that EA


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
            for key, new_swings, new_structures, new_signals, new_patterns in self.model.check_new_bars():
                for client in list(self.clients):
                    if key != client.watching:
                        continue
                    try:
                        conn = client.conn
                        self.send_swings(conn, key, new_swings)
                        if client.watch_structures:
                            self.send_structures(conn, key, new_structures)
                        if client.watch_signals:
                            self.send_signals(conn, key, new_signals)
                        if client.watch_patterns:
                            self.send_patterns(conn, key, new_patterns)
                    except OSError:
                        self.drop(client)
        except Exception as error:
            print(f"poll failed: {error}")
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
            elif cmd == "pre_trade_symbol_monitor":
                client.pre_trade_symbol = message["symbol"]
                self.send_pre_trade_symbol_monitor(conn, self.model.pre_trade_symbol_monitor(client.pre_trade_symbol))
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
        union = []   # what the model holds is the pairs of every connected EA: one must not drop the pairs of another
        for other in self.clients:
            for pair in other.pairs:
                if pair not in union:
                    union.append(pair)
        swing = message.get("swing", {})
        report = self.model.apply_config(union,
                                         swing.get("strength", 5),
                                         swing.get("use_wick", True),
                                         message.get("count", 0),
                                         on_pair=lambda row: self.send(conn, {"event": "pair", **row}),
                                         indicators=message.get("indicators", []))
        self.send(conn, {"event": "done", "total_ms": report["total_ms"], "pairs": len(report["pairs"]), "skipped": report["skipped"]})

    def watch(self, client, message):
        conn = client.conn
        key = (message["symbol"], message["tf"])
        swings = self.model.swings_since(key[0], key[1], int(message.get("from_time", 0)))
        if swings is None:
            self.send(conn, {"event": "error", "message": f"{key[0]} {key[1]} is not loaded"})
            return
        client.watching = key
        client.watch_structures = bool(message.get("structures", False))
        client.watch_signals = bool(message.get("signals", False))
        client.watch_patterns = bool(message.get("patterns", False))
        self.send_swings(conn, key, swings)
        reply = {"event": "watch", "symbol": key[0], "tf": key[1], "items": len(swings)}
        if client.watch_structures:
            structures = self.model.structures_since(key[0], key[1], int(message.get("from_time", 0)))
            self.send_structures(conn, key, structures)
            reply["structures"] = len(structures)
        if client.watch_signals:
            signals = self.model.signals_since(key[0], key[1], int(message.get("signals_from", message.get("from_time", 0))))
            self.send_signals(conn, key, signals)
            reply["signals"] = len(signals)
        if client.watch_patterns:
            patterns = self.model.patterns_since(key[0], key[1], int(message.get("signals_from", message.get("from_time", 0))))
            self.send_patterns(conn, key, patterns)
            reply["patterns"] = len(patterns)
        self.send(conn, reply)

    def send_swings(self, conn, key, swings):
        lines = [f"swing|{key[0]}|{key[1]}|{int(r.time)}|{int(r.confirmed_time)}|{r.type}|{float(r.price)!r}|{r.structure}"
                 for r in swings.itertuples()]
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} swing line(s) for {key[0]} {key[1]}")

    def send_structures(self, conn, key, structures):
        lines = [f"structure|{key[0]}|{key[1]}|{int(r.break_time)}|{int(r.swing_time)}|{r.type}|{r.dir}|{float(r.level)!r}"
                 for r in structures.itertuples()]
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} structure line(s) for {key[0]} {key[1]}")

    def send_signals(self, conn, key, signals):
        lines = [f"signal|{key[0]}|{key[1]}|{int(r.time)}|{r.label}|{r.dir}|{int(r.template)}" for r in signals.itertuples()]
        if lines:
            self.write(conn, ("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} signal line(s) for {key[0]} {key[1]}")

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
