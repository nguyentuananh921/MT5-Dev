import argparse
import os
import subprocess
import sys
import time
import traceback

from data import connect, disconnect
from model import Model
from server import Server

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--terminal", default=None, help="path to terminal64.exe when several terminals are installed")
    parser.add_argument("--port", type=int, default=9090)
    args = parser.parse_args()
    try:
        connect(args.terminal)
        print("connected to MT5")
        server = Server(Model(), port=args.port)
        server.run()
        disconnect()
        if server.restart:   # a source file changed: continue in a fresh process, this window closes
            subprocess.Popen([sys.executable] + sys.argv, creationflags=subprocess.CREATE_NEW_CONSOLE)
        print("stopped")
    except Exception:
        text = traceback.format_exc()
        print(text)
        with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "error.log"), "w", encoding="utf-8") as log:
            log.write(time.strftime("%Y-%m-%d %H:%M:%S") + "\n" + text)
        input("Python stopped by an error (saved to error.log). Press Enter to close")
