"""server.py: serves the web View (TradeCanvas, EA V5\\Web): the page built (web_folder), the bars of MT5 for its PollingAdapter, and the bars Kronos foretells.
A worker of main.py (role "server"): the EA starts Python, Python starts it, it stops with them. Alone: python server.py --database "<file under MQL5\\Files>".
GET / -> the web View built (npm run build in EA V5\\Web; the web_folder of Setting_PythonBridge)
GET /timeframes -> the names of the table timeframes (M1 .. MN1)
GET /strategies -> libdb.strategies(): Setting_Strategy, each with its slots (Setting_StrategyIndicator + indicators, param_keys of indicators.PARAM_KEYS) and conditions (Setting_StrategyCondition)
GET /bars?symbol=XAUUSD&tf=M15&limit=500[&before=<ms>] -> [{time (ms), open, high, low, close, volume}], oldest first; without before the forming bar is the last.
The forecasts of Kronos (Kronos_forecast.run: every pair in the order of Current, the chart first, about 13 s a pair on the CPU) are pushed, as V3 pushed to the EA:
lines ended by \\n, fields split by |, kept in RAM only (a forecast changes at every new bar: not kept in the database). The same lines go to every client, on one port
(socket_port of Setting_PythonBridge, PYTHON_PORT of the EA); each client takes them out of its own way:
    the EA: the lines as they are (TCP, V3)    the web View: the lines in the text frames of a WebSocket on GET /socket (a browser has no TCP socket)
    client -> Python:  watch|XAUUSD|M15[|EURUSD|H1...]        the pairs it shows (the EA: the chart + Setting_SymbolTF; the web View: one); the kept forecasts at once
    Python -> client:  forecast|XAUUSD|M15|<from_time>|<bar_time>|open|high|low|close|volume   one line a bar, times in seconds (server time, as MT5)
                       forecast_end|XAUUSD|M15|<from_time>|<bars>                              the forecast is whole
    a worker -> hub -> client:  the rows a worker calculated, as events with all their data (hub.py): the columns of the table, then is_new
                       BarTimeSeriesCollection|<name>|<tf_enum>|<type_infor>|<bar_time>|<signal_direction>|<is_new>
                       SignalsCollection|<name>|<tf_enum>|<type_enum>|<params>|<bar_time>|<signal_direction>|<is_new>"""
import argparse
import base64
import hashlib
import json
import mimetypes
import os
import socket
import socketserver
import sqlite3
import struct
import threading
import time
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

import MetaTrader5 as mt5

import data
import hub
import indicators
import libdb
import Kronos_forecast

HOST = hub.HOST
RESULT_TABLES = (libdb.TABLE_RESULT, libdb.TABLE_IND_RESULT, libdb.TABLE_STRATEGY_RESULT)   # the lines a worker sends (hub.result_lines): passed on to the clients of the pair
HTTP_STARTS = (b"GET ", b"HEAD", b"POST", b"PUT ", b"DELE", b"OPTI", b"PATC")   # the first 4 bytes of an HTTP request: the web View; any other: an EA
FIRST_BYTES_SECONDS = 10.0    # a connection that says nothing this long is closed
PARENT_CHECK_SECONDS = 5.0    # a worker of main.py looks at its parent at this pace (WORKER_CHECK_SECONDS of main.py)
TERMINAL = threading.Lock()   # the MetaTrader5 package is not thread safe: one call to the terminal at a time
WEBSOCKET_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"   # RFC 6455: the key of the handshake
_forecasts = {}               # (symbol, tf_text) -> (from_time s, the lines of the forecast): the last forecast of each pair
_clients = set()              # the EAs and web Views connected (Client)
_hub_lock = threading.Lock()  # _forecasts and _clients


def bars_of(rates):
    return [{"time": int(r["time"]) * 1000, "open": float(r["open"]), "high": float(r["high"]),
             "low": float(r["low"]), "close": float(r["close"]), "volume": float(r["tick_volume"])} for r in rates]


@data.with_link
def recent_rates(symbol, tf_text, limit):
    """The newest `limit` bars, the forming one last (PollingAdapter follows it)."""
    data.select_symbol(symbol, tf_text)
    return data.ask_history(lambda: mt5.copy_rates_from_pos(symbol, libdb.timeframes()[tf_text], 0, limit))


def fetch_bars(symbol, tf_text, limit, before_ms):
    with TERMINAL:
        if before_ms:
            df = data.fetch_bars_before(symbol, tf_text, before_ms // 1000, limit)
            return [] if df is None else bars_of(df.to_dict("records"))
        rates = recent_rates(symbol, tf_text, limit)
    return [] if rates is None else bars_of(rates)


class Client:
    """One EA (TCP), one web View (WebSocket) or one worker that sends (hub.py): the pairs it shows, (symbol, tf name), and how a text goes to it (one writer at a
    time: Kronos, the workers and its own thread all send)."""
    def __init__(self, send_text):
        self.send_text, self.watching, self.lock = send_text, set(), threading.Lock()

    def send(self, lines):
        with self.lock:
            self.send_text("".join(line + "\n" for line in lines))


def forecast_lines(symbol, tf_text, from_time, pred):
    """The lines of a forecast (the protocol at the top of the file). Only the future: the first bar foretold opens with the forming bar, the chart has the real one."""
    forming = from_time + data.tf_seconds(tf_text)
    lines = [f"forecast|{symbol}|{tf_text}|{from_time}|{int(r['time'])}|{r['open']}|{r['high']}|{r['low']}|{r['close']}|{r['volume']}"
             for r in pred.to_dict("records") if int(r["time"]) > forming]
    return lines + [f"forecast_end|{symbol}|{tf_text}|{from_time}|{len(lines)}"]


def connect(client):
    with _hub_lock:
        _clients.add(client)


def disconnect(client):
    with _hub_lock:
        _clients.discard(client)


def receive(client, line):
    """A line of a client. watch|<symbol>|<tf>... : the pairs it shows now, their kept forecasts go at once. A row of a worker (RESULT_TABLES): passed on as it is."""
    line = line.strip()
    part = line.split("|")
    if part[0] in RESULT_TABLES and len(part) > 3:
        names = {tf_enum: name for name, tf_enum in libdb.timeframes().items()}
        publish((part[1], names.get(int(part[2]), "")), [line])
        return
    if part[0] != "watch" or len(part) < 3 or len(part) % 2 == 0:
        return
    with _hub_lock:
        client.watching = {(part[i], part[i + 1]) for i in range(1, len(part), 2)}
        kept = [_forecasts[pair][1] for pair in client.watching if pair in _forecasts]
    for lines in kept:
        client.send(lines)


def publish(pair, lines):
    """The lines go to every client that shows the pair (symbol, tf name)."""
    with _hub_lock:
        watchers = [client for client in _clients if pair in client.watching]
    for client in watchers:
        try:
            client.send(lines)
        except OSError:
            disconnect(client)   # gone: its thread ends on its next read


def kept_from(symbol, tf_text):
    """Kronos_forecast.run asks: the closed bar (s) of the kept forecast of the pair, None for none."""
    with _hub_lock:
        kept = _forecasts.get((symbol, tf_text))
    return kept[0] if kept else None


def store(symbol, tf_text, from_time, pred):
    """Kronos_forecast.run gives a forecast: kept in RAM and pushed to the clients that show the pair."""
    lines = forecast_lines(symbol, tf_text, from_time, pred)
    with _hub_lock:
        _forecasts[(symbol, tf_text)] = (from_time, lines)
    publish((symbol, tf_text), lines)


class EAHandler(socketserver.StreamRequestHandler):
    """One EA (V3: CPythonBridge::TryConnect) or one worker that sends (hub.py) on the TCP socket: lines in, lines out."""
    def handle(self):
        client = Client(lambda text: self.wfile.write(text.encode("utf-8")))
        connect(client)
        print(f"server.py: a client of lines connected ({len(_clients)} clients)", flush=True)
        try:
            for raw in self.rfile:
                receive(client, raw.decode("utf-8", "replace"))
        except OSError:
            pass
        finally:
            disconnect(client)
            print(f"server.py: a client of lines left ({len(_clients)} clients)", flush=True)


class Server(ThreadingHTTPServer):
    """One port for every client: a connection that starts with an HTTP request is the web View (its page, /bars, the WebSocket), any other is an EA (lines, V3)."""
    daemon_threads = True         # a WebSocket or an EA does not hold the end of the process
    allow_reuse_address = False   # a second server.py must fail on the port, not share it (Windows lets two listen on it)

    def finish_request(self, request, client_address):
        request.settimeout(FIRST_BYTES_SECONDS)
        try:
            head = request.recv(4, socket.MSG_PEEK)   # looked at, left in the socket for the handler
        except OSError:
            return   # nothing said: not a client of ours
        request.settimeout(None)
        (Handler if head in HTTP_STARTS else EAHandler)(request, client_address, self)


def run_kronos():
    """Kronos foretells every pair in the order of Current (Kronos_forecast.run), with a database of its own: a sqlite connection stays in its thread."""
    try:
        Kronos_forecast.predictor()   # the model loads (about 16 s) while the bars are already served
        Kronos_forecast.run(libdb.LibDatabase(), TERMINAL, kept_from, store)
    except Exception as error:   # the thread would end silently: the bars are still served, the forecasts stop
        print(f"server.py: Kronos stopped: {error!r}", flush=True)


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"   # the 101 of a WebSocket handshake must be HTTP/1.1

    def do_GET(self):
        url = urlparse(self.path)
        query = {k: v[0] for k, v in parse_qs(url.query).items()}
        try:
            if url.path == "/socket":
                return self.web_socket()
            if url.path == "/timeframes":
                return self.answer(200, list(libdb.timeframes()))
            if url.path == "/strategies":   # each slot with the names of its params (the inputs of the strategy on the web chart)
                return self.answer(200, [dict(s, slots=[dict(slot, param_keys=list(indicators.PARAM_KEYS.get(slot["type_name"], ()))) for slot in s["slots"]])
                                         for s in libdb.strategies()])
            if url.path != "/bars":
                return self.send_web_file(url.path)
            bars = fetch_bars(query["symbol"], query["tf"], int(query.get("limit", 500)), int(query.get("before", 0)))
            self.answer(200, bars)
        except (KeyError, ValueError) as error:
            self.answer(400, {"error": str(error)})
        except RuntimeError as error:
            self.answer(500, {"error": str(error)})

    def answer(self, status, body):
        payload = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")   # the web runs on another port (Vite)
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def web_socket(self):
        """The web View on a WebSocket (RFC 6455): the same lines as the EA, a text frame for each send."""
        key = self.headers.get("Sec-WebSocket-Key")
        if not key:
            return self.answer(400, {"error": "a WebSocket is asked here"})
        accept = base64.b64encode(hashlib.sha1((key + WEBSOCKET_GUID).encode()).digest()).decode()
        self.send_response(101)
        self.send_header("Upgrade", "websocket")
        self.send_header("Connection", "Upgrade")
        self.send_header("Sec-WebSocket-Accept", accept)
        self.end_headers()
        self.wfile.flush()
        client = Client(lambda text: self.write_frame(0x1, text.encode("utf-8")))
        connect(client)
        try:
            while True:
                opcode, payload = self.read_frame()
                if opcode == 0x8:   # close
                    break
                if opcode == 0x9:   # ping
                    with client.lock:
                        self.write_frame(0xA, payload)
                elif opcode == 0x1:
                    for line in payload.decode("utf-8", "replace").splitlines():
                        receive(client, line)
        except (OSError, ConnectionError, struct.error):
            pass
        finally:
            disconnect(client)
            self.close_connection = True

    def read_frame(self):
        """One frame of the browser (always masked): (opcode, payload)."""
        head = self.rfile.read(2)
        if len(head) < 2:
            raise ConnectionError("closed")
        opcode, length = head[0] & 0x0F, head[1] & 0x7F
        if length == 126:
            length = struct.unpack(">H", self.rfile.read(2))[0]
        elif length == 127:
            length = struct.unpack(">Q", self.rfile.read(8))[0]
        mask = self.rfile.read(4) if head[1] & 0x80 else b"\0\0\0\0"
        data_ = self.rfile.read(length)
        return opcode, bytes(b ^ mask[i % 4] for i, b in enumerate(data_))

    def write_frame(self, opcode, payload):
        """One frame to the browser (never masked)."""
        length = len(payload)
        head = bytes([0x80 | opcode]) + (bytes([length]) if length < 126 else bytes([126]) + struct.pack(">H", length) if length < 65536 else bytes([127]) + struct.pack(">Q", length))
        self.wfile.write(head + payload)
        self.wfile.flush()

    def send_web_file(self, path):
        """A file of the web View built (web_folder of Setting_PythonBridge, the EA writes it): / is its index.html. Nothing outside the folder is served."""
        folder = web_folder()
        if folder is None:
            return self.answer(404, {"error": "no web View built: npm run build in EA V5\\Web"})
        file = (folder / (path.lstrip("/") or "index.html")).resolve()
        if folder not in file.parents or not file.is_file():
            return self.answer(404, {"error": f"no route {path}"})
        payload = file.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", mimetypes.guess_type(file.name)[0] or "application/octet-stream")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format, *args):
        pass   # one line per poll would flood the console


def web_folder():
    """The web View built (web_folder of Setting_PythonBridge), None when the EA has not written it or it is not built yet."""
    try:
        folder = Path(libdb.setting("web_folder")).resolve()
    except (KeyError, sqlite3.OperationalError):
        return None
    return folder if (folder / "index.html").is_file() else None


def watch_parent(parent_pid):
    """A worker of main.py (--parent-pid): the server stops when the parent is gone, like the other workers (the EA is closed, its Python with it)."""
    db = libdb.LibDatabase()
    db.ensure()
    while True:
        time.sleep(PARENT_CHECK_SECONDS)
        if not db.parent_alive_python_bridge(parent_pid):
            print("server.py: the Python that started this one is gone: it stops", flush=True)
            os._exit(0)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--terminal", default=None, help="path to terminal64.exe when several terminals are installed")
    parser.add_argument("--database", default=None, help="the file the accounts share, under MQL5\\Files (as main.py): its table timeframes")
    parser.add_argument("--port", type=int, default=0, help="alone: the port; with the EA it is socket_port of Setting_PythonBridge (PYTHON_PORT)")
    parser.add_argument("--parent-pid", type=int, default=0, help="a worker of main.py: the process of the parent Python (the server stops when it is gone)")
    args = parser.parse_args()
    if args.database:
        os.environ["LIBDB_FILE"] = args.database
    data.connect(args.terminal)   # first: the database is found through the terminal (MQL5\Files)
    try:
        port = args.port
        if not port:
            try:
                port = libdb.setting_int("socket_port")   # the EA decides it (PYTHON_PORT): no copy of it here
            except (KeyError, ValueError, sqlite3.OperationalError):
                print("server.py: no socket_port in Setting_PythonBridge (run the EA first, or give --port): it stops", flush=True)
                return
        server = Server((HOST, port), Handler)   # the port taken: it fails here, before Kronos loads
        if args.parent_pid:
            threading.Thread(target=watch_parent, args=(args.parent_pid,), daemon=True).start()
        threading.Thread(target=run_kronos, daemon=True).start()
        url = f"http://{HOST}:{port}"
        print(f"server.py: one port for the web View ({url}, WebSocket {url}/socket) and the EA ({HOST}:{port}): the bars of MT5 and the forecasts of Kronos, "
              f"{len(libdb.timeframes())} timeframes of the table timeframes" + ("" if web_folder() else " (no web View built: npm run build in EA V5\\Web)"), flush=True)
        if web_folder():
            webbrowser.open(url)   # once, when the server starts (with the EA): the web View is shown
        server.serve_forever()
    finally:
        data.disconnect()


if __name__ == "__main__":
    main()
