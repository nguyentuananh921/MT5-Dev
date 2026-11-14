# Parent Child

1. **Con tự fire event:** class đổi data gọi `EventSend` (CBaseObj → `EventChartCustom` lên chart bus); `OnChartEvent` của EA đưa tới mọi listener, anh chị em cùng nghe. Cha quản lý con, không relay. Gọi theo event, không poll bằng timer hay tick.
2. **Event params mang đủ thông tin** để listener không phải hỏi lại. Đóng gói bằng CBaseObj: `EventPack`/`EventUnpack` (lparam: bar time, key, side, is_new), `EventPackText`/`EventUnpackText` (sparam: `symbol;extra`). Id và ý nghĩa key/extra khai báo trong `Entities\Defines\EventDefines.mqh`.
