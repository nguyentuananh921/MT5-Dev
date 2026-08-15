# Update Config Implementation Plan

## Mục tiêu
Đổi tên section JSON `templates` thành `Indicator_Templates` để mô tả rõ hơn ý nghĩa: đó là template indicator, không phải generic template của cả hệ thống.
Đổi symbols_tf ->Symbols_TFs_List

## Scope cần đồng bộ

### 1) Engine load/save
- [v]CTimeSeriesEngine::LoadConfigurationFromJSON(...)`
   [v] ParseIndicatorConfigFile ->IndicatorConfig_ParseText
     [v] templates ->Indicator_Templates
     [v] symbols_tf ->Symbols_TFs_List
- `[v]CTimeSeriesEngine::SaveConfigurationToJSON(...)
[] CTimeSeriesEngine::RemoveSymbolTFFromConfigJSON
[] IndicatorConfig_ExtractRawSection

### 2) Parser / config loader
- `IndicatorConfigLoader.mqh`
- các phần đọc top-level key JSON

### 3) GUI config save/load
- `GUIPannel_JSONConfig.mqh
 [] GUIPannel::SavePatternAlertConfigToJSON
   [v] templates ->Indicator_Templates
   [v] symbols_tf ->Symbols_TFs_List-
   [] markers->Markers_Setting
   [] pattern_alerts ->Pattern_Alerts_Setting
 [] CGUIPannel::SaveMarkerSettingsToJSON
- các nơi gọi `IndicatorConfig_ExtractRawSection(existing, "templates")`
- cần update nếu file mới dùng `indicator_templates`

### 4) Data file
- `Config_Setting.json`
- đổi key lưu mới thành `indicator_templates`

## Checklist công việc

### A. Parser update
- [ ] Update `IndicatorConfig_ParseText(...)` để nhận `indicator_templates`
- [ ] Update phần `if(key == "templates")` -> hỗ trợ cả `indicator_templates`
- [ ] Giữ đọc file cũ `templates` để không mất compatibility

### B. Engine update
- [ ] Cập nhật `LoadConfigurationFromJSON(...)`
- [ ] Cập nhật `SaveConfigurationToJSON(...)`
- [ ] Cập nhật `RemoveSymbolTFFromConfigJSON(...)`
- [ ] Đảm bảo log/print vẫn rõ ràng

### C. GUI config update
- [ ] Update `GUIPannel_JSONConfig.mqh`
- [ ] Đổi `IndicatorConfig_ExtractRawSection(existing, "templates")` sang key mới
- [ ] Khi save lại file, ghi `indicator_templates`

### D. JSON sample update
- [ ] Chỉnh file `Config_Setting.json`
- [ ] Đổi section từ `"templates": [...]` -> `"indicator_templates": [...]`

---

## Mẫu JSON mới đề xuất

```json
{
  "Symbols_TFs_List": [
    { "symbol": "XAUUSDm", "tf": "M1", "buy": true, "sell": true }
  ],
  "Indicator_Templates": [
    {
      "type": "BBands",
      "buy": true,
      "sell": true,
      "sound": true,
      "message": true,
      "params": [14, 0, 2.00000000, "CLOSE"]
    }
  ]
}
```

---

## Lưu ý kỹ thuật
- `SaveConfigurationToJSON(...)` hiện đang build JSON bằng string concat; nên khi đổi key mới, chỉ sửa section label thôi là đủ
- `LoadConfigurationFromJSON(...)` phụ thuộc vào parser, nên nếu parser đọc đúng, engine không cần viết lại logic thiết yếu
- Mục tiêu là “đổi tên rõ nghĩa” chứ không phải “đổi cấu trúc dữ liệu”

---

## Bước làm tiếp theo
1. Update parser để đọc cả `indicator_templates` và `templates`
2. Update save method để ghi `indicator_templates`
3. Update GUI JSON helper để extract đúng section mới
4. Cập nhật file config mẫu
5. Test với file cũ và file mới

---

## Ghi chú
- Tên `indicator_templates` nên dùng trong JSON để giống với ý nghĩa thực tế: đây là “template indicator”, không phải template tổng quát của cả hệ thống.
- Người code comment bằng tiếng Anh, trao đổi bằng tiếng Việt như quy định hiện tại.
