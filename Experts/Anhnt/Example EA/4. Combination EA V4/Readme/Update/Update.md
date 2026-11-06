History update
 - EA                                      Library                                        Python
                                            2. DoEasy. Service functions Lib
    - 4. Combination EA                     4. Combination Lib 
    - 4. Combination EA V2                  4. Combination Lib V2
    - 4. Combination EA V3 Old              4. Combination Lib V3
    - 4. Combination EA V3                  4. Combination Lib V3 
V4 2026 1023 Update 
 - Reason Change Single Source of Truth của Setting, Reading JSON -> Database Sql Lite. 
 - Fix Library 
    - Theo nguyên tắc Parent Child Structure việc bắn Event là của con, việc xử lý Event là của cha và các anh em.
    - Giảm thời gian xử lý những Event không liên quan. 
V4 2026 1102 Create CDatabaseService plan to replace DatabaseDELib.mqh
 [] Có một điều kiện cần giữ đồng bộ: Python cũng phải đọc cùng folder setting. Hiện libdb.py đang har -code "SQLite", nên nếu chỉ đổi constructor phía EA mà không cập nhật cách Python nhận folder, Python sẽ tìm DB ở chỗ cũ.
 [] Implementation CDatabaseService: Chúng ta chỉ comment out các code cũ khi make sure code mới chạy tốt.
  - Chúng ta có 2 DB chạy song song.
 [] Chuẩn hóa tên của các metho theo Pattern của CDatabaseService chỉ có CRUD.
 [] Rà soát bỏ DatabaseDELib.mqh
 [] Prepare implementation RiskManagement
