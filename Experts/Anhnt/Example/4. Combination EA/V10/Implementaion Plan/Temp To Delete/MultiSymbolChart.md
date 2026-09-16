# Multi Symbol Chart - Note tạm dừng (2026-08-25)

## Bối cảnh
`CSymbolTFManager` giờ đã có event chain (`SYMBOLTF_MANAGER_EVENT_ADDED`/`_DELETE`), EA lắng nghe
`SYMBOLTF_MANAGER_EVENT_ADDED` trong `EA Using Combination Lib V10.mq5::OnChartEvent` để tự mở/kích
hoạt đúng chart cho Symbol+TF vừa được track.

## Đã làm xong, đã test OK (không sửa lại nữa trừ khi có bug mới)
- Mỗi **Symbol** chỉ giữ đúng **1 chart** (không phải 1 chart/Symbol+TF) - tìm chart có sẵn qua
  `m_ChartObjCollection` (không dựa vào `ChartOpen()` tự dedup - đã test thấy `ChartOpen()` mở
  trùng 3 chart khi gọi từ chính chart đang chạy EA đó, do timing/race lúc OnInit).
- Nếu đã có chart cho Symbol đó (bất kể TF) → `CChartObj::SetTimeframe()` đổi TF tại chỗ +
  `SetBringToTopON(true)`.
- Nếu chưa có → `m_ChartObjCollection.Open(sym, tf)` mở mới, `Refresh()` ngay tại chỗ (không đợi
  OnTimer 16ms) để đăng ký chart mới vào `m_list`, rồi mới `SetBringToTopON`.
- Xác nhận: chart mới mở là **chart trơn** - không có EA/GUI Panel (mỗi chart 1 EA instance độc
  lập, không share data, MQL5 không cho tự gắn EA sang chart khác qua code - chỉ có cách gián
  tiếp qua `.tpl` template hoặc người dùng tự kéo tay).

## Ý tưởng đang dang dở (dừng ở đây, CHƯA code gì)
User đề xuất: thay vì cố `SetBringToTopON` để nhảy sang chart mới, thì:
- Không cần bring-to-top nữa (hoặc không ưu tiên).
- Sau khi `Open()` chart mới, dùng **BridgeWriter** (`Services\SignalBridgeWriter.mqh`) để chart
  mới đó tự có sẵn SignalMarker vẽ trên nó luôn - không cần EA/GUI Panel chạy trên chart đó.
- Cơ sở khả thi: các hàm `ObjectCreate`/vẽ marker trong MQL5 nhận `chart_id` tường minh, nên 1
  script/EA đang chạy trên chart A hoàn toàn có thể vẽ object thẳng lên chart B (không cần EA
  chạy trên chart B) - khác với GUI Panel (được built bằng control library, gắn chặt vào đúng
  cửa sổ chart đang chạy nó).

## Các file liên quan cần đọc lại khi quay lại việc này
- `Services\SignalBridgeWriter.mqh` - writer ghi Signal Bridge (binary, theo Symbol - xem thêm
  memory cũ `project_v7_signal_bridge_file`).
- `Anatoli Kazharski\GUIPannel_SignalMarkers.mqh` - phía vẽ/đọc marker hiện tại (đang chạy trên
  chính chart của EA - cần xác minh lại nó vẽ bằng `ObjectCreate` thẳng hay qua 1 indicator riêng).
- `Implementaion Plan\SynIndicatorActionPlan.md` - có thể đã có ghi chú liên quan Signal
  Bridge/SignalMarkers từ trước.

## Việc cần làm khi quay lại
1. Đọc `SignalBridgeWriter.mqh` + `GUIPannel_SignalMarkers.mqh` để xác định: SignalMarkers hiện
   tại được vẽ bằng cơ chế nào (native object trực tiếp, hay qua 1 indicator riêng phải attach).
2. Nếu là native object trực tiếp: thiết kế cách EA (đang chạy ở chart A) vẽ SignalMarker thẳng
   lên `chart_id` của chart B vừa mở, dùng data từ Signal Bridge của đúng Symbol đó.
3. Nếu là qua indicator riêng: cần bàn thêm cách attach indicator đó vào chart B (có thể qua
   `IndicatorCreate`/`ChartIndicatorAdd`, tương tự cách Indicator Template đang làm).
