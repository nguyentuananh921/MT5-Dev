# Chart
 Child của [skills\AGENTS.md](../../../skills/AGENTS.md); luật chung ở [CodingRule Avoid Bug](../../../skills/rules/2.%20CodingRule.md#avoid-bug).
 ## Avoid Bug
  - **Chart change (`REASON_CHARTCHANGE` / `REASON_PARAMETERS`):** `CChartObj::SetSymbol` đổi chart thì EA chạy lại `OnDeinit` → `OnInit` nhưng giữ nguyên mọi Object (global).
   + Không ghi gì và không tạo lại gì: class dùng guard `m_first_start`.
   + Đọc luôn `new` / `delete` trong `OnInit` / `OnDeinit` của EA cho Object đó trong cùng lượt.
