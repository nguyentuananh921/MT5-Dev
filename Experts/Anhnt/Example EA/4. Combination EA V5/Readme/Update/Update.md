History update
 - EA                                      Library                                        Python
                                            2. DoEasy. Service functions Lib
    - 4. Combination EA                     4. Combination Lib 
    - 4. Combination EA V2                  4. Combination Lib V2
    - 4. Combination EA V3 Old              4. Combination Lib V3
    - 4. Combination EA V3                  4. Combination Lib V3 
    - 4. Combination EA V4                  4. Combination Lib V4
    - 4. Combination EA V5                  4. Combination Lib V5
V4 2026 1023 Update 
 - Reason Change Single Source of Truth của Setting, Reading JSON -> Database Sql Lite. 
 - Fix Library 
    - Theo nguyên tắc Parent Child Structure việc bắn Event là của con, việc xử lý Event là của cha và các anh em.
    - Giảm thời gian xử lý những Event không liên quan. 
V4 2026 1102 Create CDatabaseService plan to replace DatabaseDELib.mqh
 [v] Có một điều kiện cần giữ đồng bộ: Python cũng phải đọc cùng folder setting. Hiện libdb.py đang har -code "SQLite", nên nếu chỉ đổi constructor phía EA mà không cập nhật cách Python nhận folder, Python sẽ tìm DB ở chỗ cũ.
 [v] Implementation CDatabaseService: Chúng ta chỉ comment out các code cũ khi make sure code mới chạy tốt.
  - Chúng ta có 2 DB chạy song song.
 [v] Chuẩn hóa tên của các metho theo Pattern của CDatabaseService chỉ có CRUD.
 [v] Rà soát bỏ DatabaseDELib.mqh
 [v] Rà soát việt Send Event: CBarSeriesDE, CBarControl,CSignalSeriesDE
  - Tay Send Event: Nguồn tạo ra Event
  - Cách đóng gói Event: Dùng 
  - BarMarkerSync->chuyển về Library và đổi tên BarMarkerCollection 
  - SyncMarkers
 [] Khi 2 EA cùng chạy.
 [v] Test popup m_window_candle_infomation đọc DB qua Manager khi TF nhỏ hơn không có trên RAM: 
 [] Bật lại Python History: trước mốc DB hiện có (BTCUSD M1 trước 2026.10.24) chưa có row, popup 
V5 2026 1110 Update
 - Reason to change.
  + Rà soát lại V4
  + Chang Rule Working on RAM No Save to DB. EA chỉ đọc DB và tính toán phần tiếp theo ko save xuống DB nữa, Việc save vào DB là của Live Python
  + Implemenation Automating Trading Strategies  
V5 2026 1111 Update
  [] CBar
    - BAR_PROP_INFORMATION_JC có 32 ô, đang dùng 18.
    - BAR_PROP_INFORMATION_PA có 32 ô, đang dùng 5.
    - BAR_PROP_INFORMATION_SMC có 32 ô, đang dùng 4.
    Bít 0: Có hay không?
    Bít 1 và 2: Buy/Sell/Neutral    
   
    bit 3-4      group (JC, PA, SMC, Signal)       2 bit  (đủ 4 group; muốn chừa tới 8 group thì 3 bit)
    25 bít cho JC      
    

 [] Prepare implementation RiskManagement
