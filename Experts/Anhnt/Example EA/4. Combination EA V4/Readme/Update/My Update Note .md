2026 1102 Update Note
  - CSections (Lib V4, mới ở V4, không có trong History update) viết lại theo Parent Child Structure: CSections : CGBaseObj > CSection (header, toggles)
    > CSectionRow (control của một hàng, control vẫn do tab CTabs sở hữu). Mới RemoveRows(value); OnChartEvent thành virtual void; Arrange chỉ Show / Hide / Move khi đổi.
    Backup bản cũ: scratchpad Sections.mqh.bak.
    + Tab Indicator: ADDED thêm đúng một hàng cuối nhóm, DELETE RemoveRows(template id = dparam): hết dựng lại cả nhóm (header nháy). Add form BringToTop sau khi thêm hàng.
    + Tab Candle: OnChartEvent không trả bool nữa, click header của type bỏ qua trong BodyOf. Compile EA 0 / 0.
    [] Thử: thêm / xoá template (chart và form Add), mở / đóng nhóm và type ở tab Candle.
    + Hai hàng AMA giống hệt (DB chỉ có id 11): OnInit, CIndicatorTemplateManager thêm AMA của chart (ADDED) trước khi tab được dựng từ RAM, event ADDED đến sau
      thêm hàng lần nữa. Sửa: ADDED RemoveRows(id) trước AddRow (thêm mấy lần cũng một hàng).
  - Thêm template là việc lớn của Python: CPythonBridge::OnChartEvent (template / cặp ADDED, DELETE) tạo Python_Jobs.flag (PYTHON_JOBS_FILE, cạnh DB);
    main.py process cha thấy file mỗi nhịp (libdb.jobs_changed, JOBS_FLAG) thì xoá file, dừng Current đang chạy, chạy lại ngay (không chờ WORKER_CHECK_SECONDS).
    EA OnChartEvent chuyển event cho m_PythonBridge. Compile EA 0 / 0, ast OK. [] Thử: thêm template, Python_Parent.txt có "the jobs changed".
  - Python No Duplicate: data.py bỏ TIMEFRAMES chép tay, đọc bảng timeframes (libdb.timeframes(): tên -> tf_enum = TIMEFRAME_* của gói, 21 / 21 khớp).
    Python.md ghi cả hai.
  - Trade marker đè Pannel sau đổi TF: terminal vẽ lại "autotrade" lúc EA deinit/init, không có OBJECT_CREATE (log: 657/947 object trước và sau).
    Sửa: constructor CChartObj gửi CHART_OBJ_EVENT_OBJECTS_CHANGE, CGUIPannel BringToTop như khi có trade mới. Còn nháy ~0.5 s (thời gian OnInit). Đã thử OK, gỡ debug.
  - Python No Duplicate: EA ghi vào Setting_PythonBridge signal_buy/sell/none, object_python, collection_series/signals, swing_price_basis_wick,
    structure_lookback, file_current_*/file_history_done/file_jobs. Python bỏ SIGNAL_DIRECTION, OBJECT_DE_TYPE_PYTHON, COLLECTION_*_ID, SETTING_NAMES,
    MILESTONES, JOBS_FLAG, PRICE_BASIS_WICK, LOOKBACK; comment libdb ngắn lại. Còn chép tay: đường dẫn DB (bootstrap), tên table / param / type (khoá).
  - FRAMA: chart giữ 2 params (period, applied price, không Shift), schema 3 (parity iFrAMA khớp Python ~1e-10). EA gắn 3 params -> ChartIndicatorAdd 4114;
    đọc từ chart 2 params -> template 18 hỏng ('14, 1') -> Python "does not calculate". Sửa như Volumes: CChartObj::ChartParams bỏ Shift (so với chart), ChartIdentity chèn Shift 0.
    IndicatorCreate cần 3 params (2 -> 4002). 4114 trước đây: IsIndicatorShownOnChart so 3 với 2 params, không thấy FRAMA đã có, gắn trùng.
    Thử 08:14 XAUUSD M1: EA tự gắn FRAMA, hiện trên chart, không lỗi.
    AddToDB không ghi template sai số params của schema; ShowIndicatorOnChart báo lỗi (trước im lặng); main.py sửa câu thông báo. [] Thử: Show FRAMA hiện đường.