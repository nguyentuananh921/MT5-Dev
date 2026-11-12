# Python (Model của Lib V3)
## Cài đặt

pip install MetaTrader5         # Official MT5 API for market data and automated trading
pip install pandas-ta           # Technical indicators integrated with Pandas DataFrames
pip install ta-lib              # High-performance technical indicators and candlestick pattern detection
pip install pandas-ta-classic   # Actively maintained community fork of pandas-ta compatible with modern Pandas and NumPy 2.x
pip install candlestick         # Dedicated library for Japanese candlestick pattern recognition
pip install ta                  # Pure Python technical analysis library
pip install pyzmq               # ZeroMQ networking library for fast IPC/TCP communication
pip install pandas              # Data analysis and manipulation library using tabular DataFrames (OHLCV)
pip install numpy               # Core library for high-performance numerical computing and multidimensional arrays
pip install xgboost             # Gradient boosting framework optimized for fast and accurate machine learning models
pip install scipy               # Scientific computing library that provides many mathematical functions and algorithms
pip install numba               # Just-In-Time (JIT) compiler that translates Python code to optimized machine code
pip install scikit-learn        # Comprehensive machine learning library for data preprocessing, classification, and regression
pip install pyarrow             # High-performance in-memory columnar data engine, fast Parquet/Feather I/O
pip install jupyter             # Interactive web-based notebook environment for rapid prototyping and data exploration
pip install matplotlib          # Fundamental plotting library for creating static, interactive, and 2D charts
pip install onnxruntime         # High-performance cross-platform inference engine for running trained ONNX machine learning models
pip install onnxruntime-gpu     # GPU-accelerated (CUDA/TensorRT) inference engine for ONNX models
pip install skl2onnx            # Converter to export trained Scikit-Learn models and pipelines into ONNX format

```

## Chạy

```
python main.py
python main.py --terminal "C:\Program Files\MetaTrader 5\terminal64.exe" --port 9090
```

Thường không cần chạy tay: EA V3 tự chạy `python main.py` trong OnInit nếu chưa có Python lắng nghe cổng 9090 (cần bật "Allow DLL imports" và thêm `http://127.0.0.1` vào danh sách WebRequest của MT5).
