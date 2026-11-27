# Collections
 Child của [skills\AGENTS.md](../../skills/AGENTS.md); luật chung ở [CodingRule Avoid Bug](../../skills/rules/2.%20CodingRule.md#avoid-bug).
 ## Avoid Bug
  - **Listener lọc ID / symbol trước khi hỏi chart** (`sparam` so với `::Symbol()`): mẫu `CBarMarkerCollection::OnChartEvent`.
  - **Giữ object cũ, chỉ tạo / xoá phần đổi**, không xoá rồi tạo lại cả loạt: mẫu `CBarMarkerCollection::SyncMarkers`, `SyncTrades`, `SyncPivotPatterns`.
  - **Nhiều Event cùng đòi một việc trong một lần drain thì làm một lần cuối drain:** mẫu `CBarMarkerCollection::AddPending` → `SyncPending` (EA gọi cuối `DispatchBusEvents`).
  - Chi tiết ở header class `CBarMarkerCollection`.
