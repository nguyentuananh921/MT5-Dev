Series 1: For Trading PureData by Artyom Trishkin
 - Part 1: Concept, data management and first results 
    https://www.mql5.com/en/articles/5654
 - Part 2: Collection of historical orders and deals
    https://www.mql5.com/en/articles/5669
 - Part 3: Collection of market orders and positions, search and sorting
    https://www.mql5.com/en/articles/5687
    + Tờ giấy nháp: ListStorage đã bỏ.
 - Part 4: Trading events
    https://www.mql5.com/en/articles/5724
 - Part 5: Classes and collection of trading events, sending events to the program
    https://www.mql5.com/en/articles/6211
 - Part 6: Netting account events
    https://www.mql5.com/en/articles/6383
 - Part 7: StopLimit order activation events, preparing the functionality for order and position modification events
    https://www.mql5.com/en/articles/6482
 - Part 8: Order and position modification events
    https://www.mql5.com/en/articles/6595
 - Part 9: Compatibility with MQL4 - Preparing data
    https://www.mql5.com/en/articles/6651
 - Part 10 Compatibility with MQL4 - Events of opening a position and activating pending orders
    https://www.mql5.com/en/articles/6767
 - Part 11: Compatibility with MQL4 - Preparing data
    https://www.mql5.com/en/articles/6651
 - Part 12: Account object class and collection of account objects
    https://www.mql5.com/en/articles/6952
 - Part 13: Account object events
    https://www.mql5.com/en/articles/6995
 - Part 14: Symbol object
    https://www.mql5.com/en/articles/7014
 - Part 15: Collection of symbol objects
    https://www.mql5.com/en/articles/7041
    Khi có nhiều Account khác nhau thì các symbol khác nhau cùng là XAUUSD,XAUUSDm,XAUUSDc cân nhắc bỏ ORDER_PROP_SYMBOL
    V3 của mình (SymbolsCollection.mqh, tớ kiểm tra): vẫn như tác giả, danh sách m_list_all_symbols sắp theo SYMBOL_PROP_INDEX_MW và có GetSymbolObjByName(name). Chưa có symbol_id, chưa có ánh xạ tài khoản.
    Hai chỗ đặt bảng id ↔ tên:
    (A) CSymbolsCollection. Nạp từ symbols + symbol_account lúc khởi động. Đây đã là danh sách duy nhất các symbol của mình và đã tìm theo tên được. Khi dựng COrder, hỏi collection ra id; cần tên thì hỏi ngược lại. Hợp với hướng tổ chức lại "collection > symbol > TF" và nguyên tắc "hỏi nguồn có sẵn".
    (B) Chỉ để trong DB. COrder giữ tên của tài khoản như tác giả thiết kế, DB tự đổi sang id khi ghi. Không sửa class của tác giả, nhưng thì symbol_id vẫn là cột DB không có thuộc tính tương ứng.
 - Part 16: Symbol collection events
    https://www.mql5.com/en/articles/7071
 - Part 17: Interactivity of library objects
    https://www.mql5.com/en/articles/7124
 - Part 18: Interactivity of account and any other library objects
    https://www.mql5.com/en/articles/7149
 - Part 19: Class of library messages
    https://www.mql5.com/en/articles/7176
    Nếu upate MSG_ORD_SYMBOL_ID thì nhớ thêm vào CMessage
 - Part 20: Creating and storing program resources
    https://www.mql5.com/en/articles/7195
    -ImageDataDefine.mqh -> Store
 - Part 21: Trading classes - Base cross-platform trading object
    https://www.mql5.com/en/articles/7229  
 - Part 22: Trading classes - Base trading class, verification of limitations
    https://www.mql5.com/en/articles/7258
 - Part 23: Base trading class - verification of valid parameters
    https://www.mql5.com/en/articles/7286
 - Part 24: Base trading class - auto correction of invalid parameters
     https://www.mql5.com/en/articles/7326
  - Part 25: Handling errors returned by the trade server
     https://www.mql5.com/en/articles/7365
  - Part 26: Working with pending trading requests - first implementation (opening positions)
     https://www.mql5.com/en/articles/7394
  - Part 27: Working with trading requests - placing pending orders
     https://www.mql5.com/en/articles/7418
  - Part 28: Closure, removal and modification of pending trading requests
     https://www.mql5.com/en/articles/7438
  - Part 29: Pending trading requests - request object classes
     https://www.mql5.com/en/articles/7454
  - Part 30: Pending trading requests - managing request objects
     https://www.mql5.com/en/articles/7481
  - Part 31: Pending trading requests - opening positions under certain conditions
     https://www.mql5.com/en/articles/7521
  - Part 32: Pending trading requests - placing orders under certain conditions
     https://www.mql5.com/en/articles/7536
  - Part 33: Pending trading requests - closing positions under certain conditions
     https://www.mql5.com/en/articles/7554
  - Part 34: Pending trading requests - removing and modifying orders and positions under certain conditions
     https://www.mql5.com/en/articles/7569
 [] 25 Macgic number 
 [] khóa của TradeEvent  
 [] CPendRequest có mảng m_activated_control[][5]
  Strading Stratege
   https://www.mql5.com/en/articles/14710  
    