"""hub.py: a worker sends what it calculated to the hub of server.py (one port: socket_port of Setting_PythonBridge), as events with all their data (Readme Event Rule):
the columns of the result table and is_new, one line each (the protocol at the top of server.py). The EA stores them in RAM and fires its events; the web View shows them.
It never waits: no hub (server.py not up yet, gone), the lines are dropped; the database has them (Save Calculation), a listener loads what it misses (Load on demand)."""
import socket
import time

import libdb

HOST = "127.0.0.1"              # server.py listens here (PYTHON_HOST of the EA)
CONNECT_SECONDS = 0.2           # a connection to the hub is tried this long at most
RETRY_SECONDS = 5.0             # no hub: tried again this much later, not at every line
_socket = None
_last_try = 0.0


def _hub():
    """The connection to the hub, None while there is none (tried again RETRY_SECONDS later)."""
    global _socket, _last_try
    if _socket is not None or time.monotonic() - _last_try < RETRY_SECONDS:
        return _socket
    _last_try = time.monotonic()
    try:
        _socket = socket.create_connection((HOST, libdb.setting_int("socket_port")), timeout=CONNECT_SECONDS)
    except (OSError, KeyError, ValueError):
        _socket = None
    return _socket


def send(lines):
    """The lines go to the hub, or nowhere: the worker goes on at once."""
    global _socket
    hub = _hub() if lines else None
    if hub is None:
        return
    try:
        hub.sendall("".join(line + "\n" for line in lines).encode("utf-8"))
    except OSError:
        hub.close()
        _socket = None


def result_lines(source, symbol, tf_enum, found, is_new):
    """The rows of a result table as lines: <table>|<name>|<tf_enum>|<key values>|<bar_time>|<signal_direction>|<is_new> (the columns of write_result)."""
    keys = "|".join(str(value) for value in source.key_values)
    return [f"{source.result_table}|{symbol}|{tf_enum}|{keys}|{int(bar_time)}|{libdb.signal_direction(side)}|{int(is_new)}" for bar_time, side in found]
