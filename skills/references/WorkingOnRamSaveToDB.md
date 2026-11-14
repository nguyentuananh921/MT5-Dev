# Working on RAM, save to DB

DB là Single Source of Truth.

| Data | Ai tính | Ai ghi vào DB |
|---|---|---|
| `Setting_*` | — | EA + Library (Manager), kể cả khi live. Web (server.py → libdb) cũng được sửa, rồi báo Python tính lại. |
| Kết quả cần lưu | Python | Chỉ Python. |
| Tính để làm việc live | EA + Library, trên RAM | Không ghi. |

1. **RAM object (CSignal, CBarControl, CStrategyBase, CIndicatorDE…):** nạp từ DB một lần khi khởi tạo. Bar mới: EA tự tính trên RAM; riêng loại nặng (bảng dưới) nhận từ Python qua socket. Class lưu row vào RAM thì fire event.

   | Loại | Bar mới do | Ghi chú |
   |---|---|---|
   | Indicator value | EA (CopyBuffer) | |
   | Signal, Strategy | EA | |
   | Pattern, Swing, BOS, CHoCH | EA | judges đang comment (5.6), bật lại khi rà soát |
   | Chart Pattern, Harmonic Pattern | EA | chưa rõ nặng nhẹ, xem lại khi viết |
   | Kronos forecast | Python (socket) | không ghi DB |

2. **Dữ liệu trên RAM là object trong `CArrayObj`.** Tên list: `m_list_Table_<Table>` (bản sao của table), `m_list_<Con>` (list con). Không dùng `struct S…Row` + `m_rows[]`.
3. **EA và các Manager CREATE mọi table** (kể cả result table). Dữ liệu thô MT5 đã có (tick, bar) chỉ ở RAM, không đưa vào DB.
4. **Không tự build `account_key` ở bất kỳ đâu.** Chỉ EA build một lần trong OnInit (`company + server + "_" + login`), truyền vào `CDatabaseService`, ghi vào DB (`accounts`, `Setting_PythonBridge`). Library chỉ đọc `GetAccountKey()`; Python chỉ đọc `Setting_PythonBridge.account_key` (`libdb.current_account()`).
   - Trên RAM: key là `ACCOUNT_PROP_KEY` của CAccount (`AccountKey()`). So sánh account chỉ theo key (`CAccount::IsEqual`, `CAccountsCollection::Index`), không so từng trường.
   - Chỉ row của account đang login được ghi.