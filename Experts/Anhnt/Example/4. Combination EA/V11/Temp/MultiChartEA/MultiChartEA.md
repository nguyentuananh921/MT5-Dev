# MultiChartEA — ghi lại yêu cầu (2026-08-21, thảo luận, CHƯA code)

Tách riêng khỏi `ImplementaionClassForSetting.md` — 2 việc khác nhau, tránh trộn lẫn.

## 1. Ý tưởng

Chỉ **1 EA instance duy nhất** tại mọi thời điểm — không phải N instance chạy song song trên N chart.

Hành vi mong muốn:
- Click 1 node Symbol-TF trên `m_treeview_SymbolTF` → **tạo Chart mới** (không còn `ChartSetSymbolPeriod` đổi tại chỗ như V9 nữa).
- Khi chuyển từ Chart cũ sang Chart mới, EA "di chuyển" theo — tự detach khỏi chart cũ, tự attach vào chart mới, **KHÔNG cần user tự tay Attach lại** (2026-08-21: đã thử nghiệm bằng tay - mở Chart mới rồi tự Attach EA bằng tay, xem ảnh minh họa 3 chart BTCUSDm/USOILm/XAUUSDm - đây CHỈ là để xem thử hành vi kết quả, KHÔNG PHẢI đã tìm ra cách tự động. Cơ chế "tự attach" vẫn CHƯA GIẢI QUYẾT - MQL5 không có API "EA tự gắn chính nó vào chart khác" thuần túy; hướng khả dĩ nhất là `ChartApplyTemplate()` với 1 file `.tpl` lưu sẵn EA này, nhưng CHƯA test, cần xác nhận trước khi chốt).
- `CGUIPannel` hiện ra ở đúng Chart mới đó.
- Các table filter/hiển thị đúng theo Symbol của Chart mới đang đứng - **không bắt buộc**: ảnh test tay 3-instance cho thấy table `m_table_indicator_SymbolTFValue` đã tự gộp đủ data đa-Symbol (BTCUSDm+XAUUSDm cùng lúc) dù mỗi instance chỉ home 1 chart riêng - có thể không cần filter thêm gì.

Trường hợp KHÔNG áp dụng: user tự chuột phải MarketWatch → Open Chart (thao tác native MT5, ngoài tầm kiểm soát EA) → chart đó KHÔNG có CGUIPannel, đúng như native MT5 hoạt động, không cần EA can thiệp gì.

## 2. Liên đới tới các quyết định đang bàn ở ImplementaionClassForSetting.md

- Ownership của `m_chart_obj_collection`/Layer 3 control (EA hay class riêng) — quyết định ở đó cần tính luôn đến việc "current chart" giờ ĐỘNG (đổi theo lần chuyển chart), không còn cố định 1 lần lúc OnInit như hiện tại.
- `CIndicatorTemplateManager` (PureData indicator template) — theo bất biến "1 template set áp dụng cho MỌI symbol/TF" (SynIndicatorPlan.md) nên KHÔNG cần filter theo Symbol khi chuyển chart. Chỉ các bảng per-symbol/TF (`m_table_indicator_SymbolTFValue`, Positions...) mới cần filter theo Chart mới.

## 2b. ChartApplyTemplate() - ĐÃ CHECK, GẦN NHƯ BẾ TẮC (2026-08-21)

Theo doc MQL5 chính thức (mql5.com/en/docs/chart_operations/chartapplytemplate):
- Template CÓ THỂ chứa EA + input, apply template CÓ launch được EA trên chart mới.
- NHƯNG: **"Live trading permission cannot be extended for the Expert Advisors launched by applying the template using ChartApplyTemplate() function."** - EA tự auto-attach kiểu này MẤT quyền live trading. Với EA thật sự trade (CTradingEngine, Trading Bubble) thì đây là điểm chặn nghiêm trọng.
- Nếu EA tự gọi hàm này nhắm vào CHÍNH chart nó đang chạy → tự bị unload ngay. Phải nhắm vào chart MỚI, rồi tự `ExpertRemove()` ở chart cũ riêng (không "chuyển" trong 1 lệnh).

→ Hướng này coi như KHÔNG DÙNG ĐƯỢC cho EA cần trade thật. Cần tìm cơ chế khác hoặc chấp nhận vẫn phải attach tay.

## 3. Chưa quyết / chưa bàn kỹ

- Cơ chế kỹ thuật chính xác của "tự detach/attach chart mới" — cần lấy lại từ lần cậu đã test thử, ghi rõ ràng ra đây khi quay lại.
- Chart cũ sau khi "chuyển đi" thì đóng lại hay giữ nguyên (không còn EA nhưng vẫn còn chart mở)?
- Thứ tự OnDeinit (chart cũ) / OnInit (chart mới) - dữ liệu Pure Data (m_indicator_template_setting[] nếu đã tách theo mục ImplementaionClassForSetting.md) có cần persist qua lần chuyển này không, hay load lại từ JSON mỗi lần?

## 4. Trạng thái

Mới dừng ở mức note ý tưởng — CHƯA vào Plan mode, chưa quyết cơ chế kỹ thuật. Quay lại sau khi xong `CIndicatorTemplateManager`.
