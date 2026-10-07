import json
import socket
import time

READ_TIMEOUT = 0.016   # same rhythm as the EA timer
POLL_INTERVAL = 0.2    # seconds between two new-bar checks


class Server:
    def __init__(self, model, host="127.0.0.1", port=9090):
        self.model = model
        self.host = host
        self.port = port
        self.stop = False
        self.watching = None
        self.watch_structures = False
        self.last_poll = 0.0

    def run(self):
        listener = socket.socket()
        try:
            listener.bind((self.host, self.port))
        except OSError as error:
            print(f"cannot listen on {self.host}:{self.port} ({error}) - another instance is probably running")
            return
        listener.listen(1)
        listener.settimeout(0.5)
        print(f"listening on {self.host}:{self.port}")
        while not self.stop:
            try:
                conn, _ = listener.accept()
            except socket.timeout:
                continue
            print("EA connected")
            self.serve(conn)
            print("EA disconnected")
        listener.close()

    def serve(self, conn):
        conn.settimeout(READ_TIMEOUT)
        buffer = b""
        self.watching = None
        while not self.stop:
            try:
                chunk = conn.recv(65536)
            except socket.timeout:
                self.poll(conn)
                continue
            except OSError:
                break
            if not chunk:
                break
            buffer += chunk
            while b"\n" in buffer:
                line, buffer = buffer.split(b"\n", 1)
                if line.strip():
                    self.handle(conn, line)
        conn.close()

    def poll(self, conn):
        now = time.monotonic()
        if now - self.last_poll < POLL_INTERVAL:
            return
        self.last_poll = now
        try:
            for key, new_swings, new_structures in self.model.check_new_bars():
                if key == self.watching:
                    self.send_swings(conn, key, new_swings)
                    if self.watch_structures:
                        self.send_structures(conn, key, new_structures)
        except Exception as error:
            print(f"poll failed: {error}")

    def handle(self, conn, line):
        try:
            message = json.loads(line)
            cmd = message.get("cmd")
            if cmd == "quit":
                print("quit requested by the EA")
                self.stop = True
            elif cmd == "init":
                self.init(conn, message)
            elif cmd == "watch":
                self.watch(conn, message)
            else:
                self.send(conn, {"event": "error", "message": f"unknown cmd {cmd}"})
        except Exception as error:
            self.send(conn, {"event": "error", "message": str(error)})

    def init(self, conn, message):
        swing = message.get("swing", {})
        report = self.model.apply_config(message.get("pairs", []),
                                         swing.get("strength", 5),
                                         swing.get("use_wick", True),
                                         message.get("count", 0),
                                         on_pair=lambda row: self.send(conn, {"event": "pair", **row}))
        self.send(conn, {"event": "done", "total_ms": report["total_ms"], "pairs": len(report["pairs"])})

    def watch(self, conn, message):
        key = (message["symbol"], message["tf"])
        swings = self.model.swings_since(key[0], key[1], int(message.get("from_time", 0)))
        if swings is None:
            self.send(conn, {"event": "error", "message": f"{key[0]} {key[1]} is not loaded"})
            return
        self.watching = key
        self.watch_structures = bool(message.get("structures", False))
        self.send_swings(conn, key, swings)
        reply = {"event": "watch", "symbol": key[0], "tf": key[1], "items": len(swings)}
        if self.watch_structures:
            structures = self.model.structures_since(key[0], key[1], int(message.get("from_time", 0)))
            self.send_structures(conn, key, structures)
            reply["structures"] = len(structures)
        self.send(conn, reply)

    def send_swings(self, conn, key, swings):
        lines = [f"swing|{key[0]}|{key[1]}|{int(r.time)}|{int(r.confirmed_time)}|{r.type}|{float(r.price)!r}|{r.structure}"
                 for r in swings.itertuples()]
        if lines:
            conn.sendall(("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} swing line(s) for {key[0]} {key[1]}")

    def send_structures(self, conn, key, structures):
        lines = [f"structure|{key[0]}|{key[1]}|{int(r.break_time)}|{int(r.swing_time)}|{r.type}|{r.dir}|{float(r.level)!r}"
                 for r in structures.itertuples()]
        if lines:
            conn.sendall(("\n".join(lines) + "\n").encode("utf-8"))
        print(f"sent {len(lines)} structure line(s) for {key[0]} {key[1]}")

    def send(self, conn, message):
        text = json.dumps(message)
        print(text)
        conn.sendall((text + "\n").encode("utf-8"))
