import argparse

from data import connect, disconnect
from model import Model
from server import Server

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--terminal", default=None, help="path to terminal64.exe when several terminals are installed")
    parser.add_argument("--port", type=int, default=9090)
    args = parser.parse_args()
    connect(args.terminal)
    print("connected to MT5")
    Server(Model(), port=args.port).run()
    disconnect()
    print("stopped")
