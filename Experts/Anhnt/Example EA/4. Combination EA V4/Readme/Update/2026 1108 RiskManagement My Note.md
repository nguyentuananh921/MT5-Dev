Claude note - Risk Management / Strategy (bổ sung cho Task của Anhnt, không sửa Task)

Tổng thể (tầng: có / mới / phải sửa)
 1 Dữ liệu: có.
 2 Nguồn: Indicator (1 judge -> n kiểu signal: SignalSeriesDE, schema SignalsCollection, Python), Bar information (+Harmonic, Chart pattern), Order Block/Zone sau.
 2d Dẫn xuất (14: mean/stddev của RSI): là Strategy thường; input RSI, MACD template + tham số (statAnalysisPeriod, k); tính trên RAM, output signal. Không làm template trên template.
    Volumes hiện đóng cứng dạng này (CIndVolumes iMA trên handle, CIndicatorSeriesDE m_ind_handle_average/Source/SourceBuffer, CSignalVolumes).
    Khi có Strategy "Value vs Average (± k·σ)": Volumes thành indicator thường, bỏ các ngoại lệ đó.
 2c Zone / pattern: trade chỉ cần cái còn sống gần giá (RAM); dead chỉ cho thống kê + vẽ quá khứ (DB, Python). Row có trạng thái + thời điểm chết; chết thì event, RAM bỏ.
 3 Strategy: mới; CBarMarker thêm nguồn.
 4 Risk: mới. 5 Trade: đọc lineage V1 StopLost/Trailing + V3 trading review trước.
 6 Thống kê: SQL trên kết quả Python.
 Xuyên suốt: Working in RAM, Python save to DB -> làm đầu tiên.

Strategy
 - 1 template dùng chung nhiều Strategy (AO ở 01 và 02): n-n qua Setting_StrategyCondition.
 - Exit yếu hơn Entry ngược chiều (01: chỉ AO cắt 0).
 - Vai trò: Entry, Exit (signal) / SL, TP, Trailing (level: ATR, MA, PSAR) / Risk = lot.
 - Output level: đọc buffer trên RAM (CIndicatorsCollection), không tạo handle riêng.
 - Kiểu condition: signal tại bar, signal gần nhất (01 fractal), trạng thái so ngưỡng (05 RSI), so buffer 2 template (05 MA fast/slow), TF riêng.

 - Strategy 2 tầng như Indicator: catalog trong code (slot + luật, vd MA Cross: Fast/Slow, "Fast cắt Slow") -> Setting_StrategyTemplate trong DB (slot = indicator template theo khoá type+params).
   Template chưa có thì CIndicatorTemplateManager thêm. 14/50 là dữ liệu, không fix trong code.
   Mở: template do strategy thêm có hiện signal riêng không; xoá strategy có xoá template không dùng nữa không.

Hướng mới (đang bàn): table kết quả chỉ Python ghi (lịch sử + bar mới); EA tính trên RAM, không ghi.
 - Bớt: UpdateDataToDB kết quả, m_list_Pending_*, IsPythonDone chặn ghi, mốc EA ghi Setting_Sync.
 - Chốt: Live ghi bar mới (Current nghỉ sau khi khởi động). EA và Python đã so khớp indicator nhiều lần: không phải vấn đề. Luật Readme: Anhnt update sau.
 - Tải EA = số handle; ghép: EA chỉ tạo handle cho strategy đang bật trên pair. Đo tick/bar với 154 handle trước.

Kiến trúc (bàn, chưa code; làm dần trong đợt implementation mới)
 - Entity = CBar (model); business rules = judge (CSignal*, CBarSwing, CBarPattern, BOS, CHoCH); use case/control = CBarControl, CSignalSeriesDE (update CBar, event); lưu chỉ phần kết quả.
 - IJudge: Calculate(list, since, times[], sides[]) chung cho 2 họ judge + CStrategy. Không đổi gốc CBar (giữ CBaseObj).
 - ISource (Value, Signal, LastSignal) cho slot Strategy; CStrategy gốc chung, mỗi strategy chỉ viết Rule(time).
 - Không thống nhất: CSignal::LoadBuffers copy CIndicatorSeriesDE::m_list_data sang SBarBuffer m_buffer[]; judge bar đọc thẳng CArrayObj.
   Hướng: judge giữ con trỏ list của chủ, đọc qua Value(buffer, i) (GetIndDataByTime, NaN nếu thiếu); bỏ SBarBuffer, LoadBuffers. Khớp ISource::Value.
 - Đọc DB chỉ ở Manager/Collection (repository); CBarControl::ReadDataFromDB chuyển ra khi đụng tới.
 - Web = View chỉ đọc, chạy trong tiến trình Python (localhost); model Python dùng lại, schema DB = SSOT.

SL / Trailing
 - Entry trả kèm SL tự nhiên (tùy chọn): zone biên, harmonic X/D, nến pattern đỉnh/đáy; MA Cross không có. Row signal Entry có sl_price (có thể rỗng).
 - Setting SL mỗi strategy: From Strategy | ATR×k | Points | Swing + đệm; From Strategy mà rỗng -> ATR. Risk chỉ nhận khoảng cách để tính lot.
 - Open Position luôn có SL và TP ngay lúc mở: strategy không có thì lấy theo setting (SL/TP mặc định); có thể Off.
 - Khi đã Go Live: phải modify được SL/TP của position đang mở, và Partial Close được.
 - CTradeSetupBox (Lib V4 Graph\Composite, dang dở; chỉ Test_TradeSetupBox V3 Old dùng; SEND/CLOSE chưa ai nghe):
   + LotsToTrade/LossPerLot/RPT trong View -> chuyển cho Risk Management, box chỉ hỏi.
   + Thêm giai đoạn live theo ticket: kéo Stop -> ModifyPosition; TP1..TP3 -> ClosePositionPartially. Box bắn event, Trade gọi Trading.
   + Signal Entry có SL tự nhiên -> box Setup sẵn để xác nhận thủ công.
   + Ternary giữa string (ShowType, RatioText): sửa khi đụng file.
 - Trailing: CButtonTriggered On/Off + ComboBox loại (catalog ATR, Points, MA, PSAR) + khung params theo schema (cơ chế AddIndicator). Setting giữ enabled, type, params riêng. Chờ ví dụ cụ thể.

Self Optimizing / AI (Gamuchirai)
 - Reimagining: Fetch_Data -> notebook train -> ONNX trong EA. Ở mình: Python đọc DB, train, EA chạy ONNX.
 - Self Optimizing: EA tự thu snapshot (OHLC, balance, equity, trạng thái lệnh), fit linear (PInv) online. Ở mình: thống kê strategy là feedback, bàn sau.

Standard indicator
 - Mỗi ENUM_INDICATOR 1 judge (SignalSeriesDE). BBands, Ichimoku cần nhiều kiểu signal -> catalog kiểu signal theo indicator; đo DB trước khi thêm cột SignalsCollection.
 - ATR: nguồn level, không ra signal.
 - Ngưỡng duplicate: #define RSI/CCI/DEMARKER/WPR/MFI/STOCHASTIC/MOMENTUM trong Signal.mqh + chép tay ở Python signals.py.
   Hướng: ngưỡng là thuộc tính indicator -> mặc định trong catalog (indicators), sửa được ở template; judge nhận từ template, Python đọc DB.

Bar information mới (dựng trên Swing)
 - Group Harmonic: 08 Butterfly, 15 Cypher, 27 Crab, 28 Bat, 29 Gartley, 30 AB-CD, 31 3 Drives, 32 5 Drives, 33 Shark. Signal ở điểm D; sai số tỉ lệ vào Setting_BarSetup.
 - Group Chart pattern: 13 Head & Shoulders, 49 Quasimodo, 53 Double Top/Bottom.
 - Cũng là nguồn level (SL quanh X/D, TP theo Fib AD): bàn sau.

Đã xem: 01, 02, 05, 08.
