# Bug: ::PlaySound() không phát ra tiếng thật khi EA tự bắn Alert

> **ĐÃ FIX HẲN (2026-08-13)** — xem mục "KẾT LUẬN ĐÚNG CUỐI CÙNG" ở cuối file. Root cause thật khác với kết luận "ĐÃ DỨT ĐIỂM"/"XÁC NHẬN BẰNG LOG THẬT" ở giữa file (2026-08-12) — 2 mục đó **SAI**, giữ lại chỉ để lưu vết quá trình điều tra, đừng áp dụng theo.

## Symptom
Anhnt (2026-08-10): Sound alert cho Indicator (AMA/BBands) không phát ra tiếng gì khi flip Buy/Sell xảy ra, dù:
- Checkbox Sound của dòng AMA/BBands trong bảng Indicator (tab **Indicator**) đang **BẬT**.
- File `.wav` (`SIGNAL_BUY_EN.wav`/`SIGNAL_SELL_EN.wav`) đã chọn đúng trong tab **Marker**, `m_marker_buy_sound_file`/`m_marker_sell_sound_file` được set ngay khi đổi combobox (không cần bấm Save).
- Message alert (CMessage::Out) vẫn bắn đều đặn — chỉ riêng Sound là im.
- Anhnt tự mở file `.wav` đó ngoài EA (double-click/media player) — xác nhận file **có tiếng thật**, không phải file rỗng/hỏng.

→ Không phải do config sai, không phải do file hỏng. Bug thật nằm ở chỗ EA gọi `::PlaySound()`.

---

## Đã xác minh trước khi nghi code (loại trừ các nguyên nhân đơn giản)
1. `MQL5\Sounds\SIGNAL_BUY_EN.wav` và `SIGNAL_SELL_EN.wav` — **có tồn tại** (đây là folder `::PlaySound()` thật sự đọc, khác với `MQL5\Files\Sounds\` là nơi combobox quét để chọn).
2. `m_marker_buy_sound_file`/`m_marker_sell_sound_file` cập nhật ngay khi đổi combobox (`GUIPannel_Lifecycle.mqh:584-599`), không phụ thuộc bấm Save.
3. Checkbox Sound per-row (tab Indicator, cột Sound) — Anhnt xác nhận đang BẬT cho AMA/BBands.
4. Đọc lại code gọi `::PlaySound()` (nhánh Live `GUIPannel_SoundAndMessageAlerts.mqh` ~165-179, nhánh CloseBar mới thêm ~139-144) — logic gate `if(sound_on) { ... if(file != "") ::PlaySound(file); }` nhìn đúng, không thấy lỗi rõ ràng qua đọc code tĩnh.

## Giả thuyết chưa xác nhận (cần log thật)
- `::PlaySound()` trả về `true` (Windows chấp nhận request) nhưng không có âm thanh thật ra loa → nghi vấn ở tầng OS/audio device (terminal chạy sai user context, sound device bị chiếm bởi app khác, MT5 mất focus audio...) — nếu đúng vậy thì KHÔNG sửa được bằng code.
- `::PlaySound()` trả về `false` → lỗi thật trong code/đường dẫn, cần đào tiếp (có thể liên quan tới cách MT5 resolve đường dẫn tương đối, hoặc file bị lock bởi process khác).
- Gọi `::PlaySound()` quá dồn dập (nhiều indicator flip liên tiếp trong khoảng cách ngắn) khiến các lệnh phát đè lên nhau — ít khả năng dựa theo khoảng cách log (~1.5-3.5s giữa các flip), nhưng chưa loại trừ hoàn toàn.

---

## XÁC NHẬN root cause (2026-08-11, đọc `MQL5\Logs\20260811.log`)

Đã lấy log thật từ debug Print() đã chèn — **5794 dòng** `MY DEBUG ... CheckIndicatorAlerts`, trải dài từ 20:28:59 đến 20:52:xx (phiên test hôm nay).

**Kết quả loại trừ 2 giả thuyết đầu:**
- `PlaySound() returned=true` ở **toàn bộ 5794 dòng, 0 lần `false`**. Không phải lỗi API/return code.
- `MQL5\Sounds\SIGNAL_BUY_EN.wav` và `SIGNAL_SELL_EN.wav` **có tồn tại** đúng chỗ. Không phải lỗi resolve file.

**Giả thuyết #3 (gọi dồn dập) — CONFIRMED, với timing sát hơn nhiều so với ước tính ban đầu (1.5-3.5s):**

`::PlaySound()` của Windows chỉ có **1 kênh phát dùng chung** cho cả EA — gọi lần mới sẽ **ngắt ngay** âm đang phát dở của lần trước rồi mới phát âm mới (SND_ASYNC). Log cho thấy 2 tình huống bắn PlaySound liên tiếp cách nhau chỉ **10-67ms** (ngắn hơn hẳn thời lượng 1 file .wav báo hiệu) → tai người nghe như im lặng hoặc chỉ 1 tiếng "click" cụt:

1. **Lúc mới attach EA (20:28:59)**: watermark backfill dồn hàng trăm CloseBar event lịch sử cùng lúc trong <1 giây → hàng trăm `PlaySound()` chồng chéo liên tục. Đây đúng là cái tradeoff đã cảnh báo sẵn trong comment ở đầu `GUIPannel_SoundAndMessageAlerts.mqh` (dòng 10-14) khi quyết định bật Sound cho CloseBar (2026-08-10).

2. **Lúc chạy real-time bình thường (20:52:12.580 → .647, 67ms)**: nhiều template khác nhau (BBands, PSAR, AMA) cùng flip trên cùng 1 cây nến đóng → 5 lệnh `PlaySound()` bắn liên tiếp. **Không phải** backfill — chạy live thật cũng bị nuốt tiếng.

→ Kết luận: đây là giới hạn vật lý của API (1 kênh phát dùng chung), không phải bug logic sai. Cần throttle/coalesce các lệnh gọi `::PlaySound()` quá gần nhau về thời gian.

**Câu hỏi mở, chưa chốt hướng fix (2026-08-11)**: khi nhiều indicator/TF cùng lúc cho tín hiệu, Anhnt có cần nghe *từng* tiếng riêng cho từng indicator không, hay chỉ cần biết "có tín hiệu Buy/Sell xảy ra" là đủ (1 tiếng đại diện)? Case backfill lúc mới attach chắc không cần nghe hết cả loạt lịch sử — Message/CSV ghi lại là đủ. Đang chờ Anhnt quyết cụ thể trước khi code.

---

## Debug đã chèn (2026-08-10)
2 chỗ trong `GUIPannel_SoundAndMessageAlerts.mqh`, log `sound_on`, `file`, và return value của `::PlaySound()`:

1. **Nhánh CloseBar** (~dòng 139-146, trong `CheckIndicatorAlerts`):
```cpp
if(sound_on)
 {
  string cb_file = cb_is_buy ? m_marker_buy_sound_file : m_marker_sell_sound_file;
  ::Print("MY DEBUG CGUIPannel::CheckIndicatorAlerts CloseBar - sound_on=", sound_on, " cb_file=", cb_file, " label=", label);
  if(cb_file != "")
   {
    bool played_cb = ::PlaySound(cb_file);
    ::Print("MY DEBUG CGUIPannel::CheckIndicatorAlerts CloseBar - PlaySound returned=", played_cb);
   }
 }
```

2. **Nhánh Live** (~dòng 165-181, cùng hàm):
```cpp
if(sound_on)
 {
  string file = is_buy ? m_marker_buy_sound_file : m_marker_sell_sound_file;
  ::Print("MY DEBUG CGUIPannel::CheckIndicatorAlerts Live - sound_on=", sound_on, " file=", file, " label=", label);
  if(file != "")
   {
    bool played = ::PlaySound(file);
    ::Print("MY DEBUG CGUIPannel::CheckIndicatorAlerts Live - PlaySound returned=", played);
   }
 }
```

**Mục tiêu**: xác nhận `sound_on`/`file` đúng giá trị mong đợi tại đúng thời điểm gọi, và `::PlaySound()` trả về `true` hay `false` — để phân biệt "bug code" vs "vấn đề tầng OS/audio, ngoài khả năng sửa bằng code".

---

## Trao đổi tiếp (2026-08-11, sau khi có log thật) — điều chỉnh hiểu biết + hướng fix

**Sửa 1 hiểu nhầm của assistant**: `CheckIndicatorAlerts()`/`CheckCandlePatternAlerts()` chạy trong `CGUIPannel::OnTickEvent()` ([GUIPannel_Lifecycle.mqh:284](Anatoli%20Kazharski/GUIPannel_Lifecycle.mqh#L284)), gọi từ `OnTick()` của EA chính ([EA Using Combination Lib V8.mq5:83](../EA%20Using%20Combination%20Lib%20V8.mq5#L83)) — **KHÔNG** phải `OnTimerEvent` (timer 16ms) như assistant nhầm lẫn ban đầu. Comment cũ ở đầu `GUIPannel_SoundAndMessageAlerts.mqh` đã sửa lại cho khớp (2026-08-11).

**Bug phụ phát hiện + đã fix (Anhnt, 2026-08-11)**: `CheckCandlePatternAlerts()` từng bị gọi **2 lần** trong cùng 1 `OnTickEvent()` (1 lần đầu hàm cho "new bar detection", 1 lần cuối hàm cùng `CheckIndicatorAlerts()` cho "Sound and message alerts") — sót lại khi move code. Đã xóa lệnh gọi thừa, giờ chỉ còn 1 lần, đi cùng `CheckIndicatorAlerts()` dưới comment "Sound and message alerts".

**Lý do CloseBar hay bị chồng Sound dù mỗi bar chỉ đóng 1 lần/TF (đã trao đổi kỹ với Anhnt)**: `CommitClosedBar()`/`SyncHistory()` trong `SignalBase.mqh` đã có guard `dir == last → không ghi entry` (history chỉ ghi khi THẬT SỰ flip, không phải mọi bar) — nên không phải do code ghi thừa. Nguyên nhân thật: các indicator như BBands/PSAR/AMA là **trend/momentum-following, có tương quan với nhau** — khi giá có 1 cú di chuyển mạnh trên 1 cây nến, nhiều indicator khác nhau CÙNG flip trên đúng cây nến đó là chuyện hợp lý (không phải trùng hợp ngẫu nhiên độc lập), và đúng lúc đó lại là lúc trader cần nghe Sound nhất. Live cũng bị y hệt cơ chế này (log 20:29:14 cho thấy 4 template Live flip trong 9ms), chỉ là ít gặp hơn CloseBar vì Live bị giới hạn bởi số template thật sự đổi `GetCurrentSignal()` ngay lúc đó.

**Hướng fix đã thống nhất phạm vi (Anhnt, 2026-08-11) — CHƯA CODE**:
- Chỉ áp dụng cho **CloseBar** (Indicator + Candle Pattern) — **KHÔNG đụng Live** (Live-Indicator để riêng bàn sau; Live-Candle-Pattern là bug đang tạm dừng, xem `UpdateCandlePattern.md`, không liên quan).
- Cơ chế: trong 1 lượt quét CloseBar phát hiện được (có thể nhiều indicator/pattern cùng flip trên cùng 1 bar), **Message/CSV vẫn ghi đủ từng dòng như cũ** (không mất dữ liệu), nhưng **Sound chỉ phát tối đa 1 lần** thay vì phát lặp cho từng indicator.
- **Đã chốt (Anhnt, 2026-08-11)**: gộp **chung 1 ngân sách** cho cả Indicator lẫn Candle Pattern (không tách riêng theo nguồn) — bất kỳ flip nào (Buy hoặc Sell, đến từ indicator nào hay Candle Pattern) trong 1 lượt CloseBar cũng chỉ gộp thành **tối đa 1 lần phát/lượt**. Message/CSV không đổi gì - mỗi flip vẫn ghi riêng 1 dòng như cũ.
- **Sửa lại lần nữa (Anhnt, 2026-08-11)**: ban đầu định giữ phân biệt Buy/Sell (tối đa 2 sound/lượt), nhưng 1 cây nến CloseBar có thể có RẤT NHIỀU Pattern cùng lúc - phân biệt hướng chỉ tổ thêm state mà không cần thiết, vì mục đích CloseBar Sound chỉ là "có gì đó vừa đóng nến, xem log" (Buy/Sell/chi tiết đã có sẵn trong Message/CSV). Nên **CloseBar Sound gộp về 1 file cố định `NewBar.wav`**, không phân biệt hướng nữa - tối đa đúng **1 lần phát/lượt**.

## Thử sai #1 (2026-08-11) — mark-then-play, ĐÃ REVERT
Từng thử: 2 chỗ CloseBar chỉ **đánh dấu** `m_closebar_sound_played = true`, còn `::PlaySound("NewBar.wav")` thật sự thì dời xuống **cuối `OnTickEvent()`**, sau khi cả `CheckIndicatorAlerts()`/`CheckCandlePatternAlerts()` đã chạy xong. → **Bug**: cách này khiến `NewBar.wav` LUÔN phát SAU CÙNG (Live phát ngay giữa vòng lặp, CloseBar dời xuống cuối) → **luôn ngắt mất tiếng Live** nếu 2 sự kiện trùng tick, do Windows chỉ có 1 kênh phát. Anhnt phát hiện qua test thực tế ("mất sound với Live Signal").

## Thử sai #2 (2026-08-11) — bỏ hẳn Sound cho CloseBar, ĐÃ REVERT
Hiểu nhầm ý Anhnt là "bỏ hẳn Sound", đã xoá sạch mọi Sound-code khỏi CloseBar. Anhnt sửa lại: **không phải bỏ Sound**, mà là **không phân biệt Buy/Sell nữa** — vẫn cần 1 tiếng báo hiệu, chỉ là dùng chung 1 file `NewBar.wav` thay vì chọn theo hướng.

## QUYẾT ĐỊNH CUỐI (Anhnt, 2026-08-11): CloseBar vẫn có Sound, nhưng phát NGAY TẠI CHỖ (không dời cuối), 1 file cố định
- **CloseBar Sound = `NewBar.wav` cố định** (không phân biệt Buy/Sell) — khác Live vẫn phân biệt Buy/Sell qua `PlaySoundForDirection`.
- **Phát NGAY tại chỗ phát hiện** (không dời xuống cuối `OnTickEvent` nữa) — đây là điểm sửa quan trọng nhất so với Thử sai #1, giải quyết đúng vấn đề "CloseBar luôn đè Live" mà không cần bỏ hẳn Sound.
- `m_closebar_sound_played` (bool đơn, không tách Buy/Sell) - check-and-set NGAY tại điểm phát hiện flip đầu tiên trong lượt, reset `false` ở đầu `OnTickEvent()` (trước khi gọi 2 hàm Check), tối đa 1 lần phát/lượt, gộp chung Indicator + CandlePattern.
- `m_candle_pattern_closebar_last_dir[]` - **giữ nguyên/khôi phục lại** (đã bị xoá nhầm ở Thử sai #2) - Candle Pattern CloseBar chỉ tính là sự kiện đáng Sound khi hướng thật sự đổi so với lần CloseBar trước của đúng (pattern type, TF), cùng nguyên tắc Live/Indicator.
- `sound_on_cb` - **giữ nguyên/khôi phục lại** - gate row Candle Pattern CloseBar vẫn `if(!sound_on_cb && !message_on_cb) continue;`.
- `PlaySoundForDirection(is_buy)` - chỉ còn dùng cho Live (chọn file Buy/Sell theo `m_marker_buy_sound_file`/`sell`).

## Root cause thật sự của việc "kêu lúc kêu lúc không" (2026-08-12) - KHÔNG phải OS/Windows Audio
Anhnt test tiếp và phát hiện `NewBar.wav` không kêu dù đã đặt file đúng vào **"Sound Folder"** hiện trong GUI (`MQL5\Files\Sounds\`). Hoá ra đây MỚI LÀ root cause thật của toàn bộ chuyện "lúc kêu lúc không" từ đầu investigation này - không phải OS/Windows Audio như nghi vấn trước đó:

**`::PlaySound()` (native WinMM, EA đang dùng) và `FileFindFirst`/`FileOpen` (dùng bởi `ScanSoundFolder()` để hiện danh sách cho combobox chọn) đọc từ 2 THƯ MỤC KHÁC NHAU**:
- `FileFindFirst`/`FileOpen` chỉ đọc được trong sandbox `MQL5\Files\...` → đây là thư mục GUI hiển thị ("Sound Folder: MQL5\Files\Sounds\"), nơi Anhnt đặt file mới.
- `::PlaySound(bare_filename)` (không path) lại resolve vào `MQL5\Sounds\` - một thư mục HOÀN TOÀN KHÁC, ngoài sandbox.
- `SIGNAL_BUY_EN.wav`/`SIGNAL_SELL_EN.wav` sở dĩ kêu được là vì đã được copy tay vào CẢ 2 nơi (không phải do fix nào ở phần trên) - còn `NewBar.wav` (và trước đó có thể là nguyên nhân của hiện tượng "ngắt quãng" nghi ngờ tầng OS) chỉ có ở 1 nơi.

**Thử fix bằng full absolute path (2026-08-12) — ĐÃ REVERT, SAI**: thử build full path (`TerminalInfoString(TERMINAL_DATA_PATH) + "\MQL5\Files\" + m_marker_sound_folder + "\" + filename`) với giả định `::PlaySound()` là WinMM passthrough thuần, không bị sandbox. **Sai** - Anhnt test thấy im HOÀN TOÀN, kể cả Live vốn đang chạy tốt trước đó (dùng `SIGNAL_BUY_EN.wav` đã có sẵn ở `MQL5\Sounds\`). Theo tài liệu MQL5: `::PlaySound()` **chỉ** tìm file ở đúng 2 chỗ cố định (`terminal_directory\Sounds\` hoặc `terminal_directory\MQL5\Sounds\`) - không nhận path tuyệt đối tùy ý, không có cách nào đọc thẳng `MQL5\Files\...\`. Đây là giới hạn cứng của chính API, không phải sandbox có thể lách qua bằng code.

**Kết luận đúng, không sửa được bằng code**: `PlaySoundFile(filename)` ([GUIPannel_SoundAndMessageAlerts.mqh](../Anatoli%20Kazharski/GUIPannel_SoundAndMessageAlerts.mqh)) giờ chỉ còn là 1 wrapper mỏng gọi `::PlaySound(filename)` với bare filename như cũ - **vẫn giữ 1 điểm gọi duy nhất** cho mọi sound (dễ maintain/đổi sau này nếu cần), nhưng file **bắt buộc phải tồn tại thật trong `MQL5\Sounds\`** — không có cách nào tránh việc này, 2 thư mục (`MQL5\Files\Sounds\` cho combobox chọn, `MQL5\Sounds\` cho phát) là quirk cố định của MQL5, phải copy tay.
- `PlaySoundForDirection` (Live) và cả 2 chỗ `NewBar.wav` (CloseBar Indicator + CandlePattern) đều gọi qua `PlaySoundFile()` - vẫn giữ được phần dọn code "extract bare filename" cũ ở nhánh Live Candle Pattern (không liên quan tới phần bị revert, gọi thẳng `PlaySoundForDirection()` vẫn đúng).
- **Việc cần làm**: Anhnt copy tay `NewBar.wav` từ `MQL5\Files\Sounds\` sang `MQL5\Sounds\` (giữ nguyên tên) rồi test lại.
- **Nghi vấn "OS/PlaySound handle rò rỉ"** (mục "PHÁT HIỆN MỚI" ở trên) - vẫn có khả năng 1 phần hiện tượng "ngắt quãng" trước đó chỉ là do thiếu file ở `MQL5\Sounds\` (giống `NewBar.wav`), không phải OS thật - cần test lại sau khi copy đúng file mới kết luận được có cần `::PlaySound(NULL)` nữa không.

## XÁC NHẬN BẰNG LOG THẬT (2026-08-12) — full path vào Files\Sounds\ bị từ chối, có bằng chứng cứng
Anhnt phản bác: theo kinh nghiệm test nhiều lần trước đây, **chỉ `MQL5\Files\Sounds\` mới từng phát được**, `MQL5\Sounds\` dù CÓ sẵn `SIGNAL_BUY_EN.wav`/`SIGNAL_SELL_EN.wav` (đã tự kiểm tra, xác nhận file thật sự tồn tại ở đó) vẫn im lặng. Mâu thuẫn trực tiếp với comment cũ trong code.

→ Thêm `MY DEBUG` Print vào `PlaySoundFile()` để lấy dữ liệu cứng thay vì suy đoán tiếp. Kết quả log thật:
```
MY DEBUG CGUIPannel::PlaySoundFile - full_path=C:\...\MQL5\Files\Sounds\SIGNAL_SELL_EN.wav PlaySound returned=false
```
**`PlaySound()` trả về `false`** cho full path vào `MQL5\Files\Sounds\` - API từ chối thẳng, không phải "trả true mà không nghe thấy". Xác nhận cứng: `::PlaySound()` không đọc được `MQL5\Files\Sounds\` dưới bất kỳ hình thức nào (kể cả full path tuyệt đối đúng), khớp với comment cũ 2026-07-17.

**ĐÃ DỨT ĐIỂM (2026-08-12)**: Anhnt test lại với bare filename (`::PlaySound(filename)`, file trong `MQL5\Sounds\`) → `PlaySound returned=true` VÀ **nghe thấy tiếng thật**. Kết luận cuối: comment cũ 2026-07-17 đúng hoàn toàn - `::PlaySound()` chỉ đọc được `MQL5\Sounds\`, không có cách nào đọc `MQL5\Files\...\`. "Kinh nghiệm test trước đây chỉ Files\Sounds\ mới phát được" của Anhnt là nhớ nhầm thư mục (khả năng cao lúc đó file cũng đã có sẵn ở `MQL5\Sounds\` mà không để ý). **Toàn bộ saga "im lặng"/"ngắt quãng" từ đầu investigation này (kể cả nghi vấn tầng OS/PlaySound handle) → root cause thật chính là thiếu file ở `MQL5\Sounds\`, không phải OS bug, không cần `::PlaySound(NULL)`.**
- `MY DEBUG` Print trong `PlaySoundFile()` có thể xoá khi Anhnt xác nhận ổn định hoàn toàn.
- Việc cần nhớ vĩnh viễn: **mọi sound file mới thêm sau này đều phải copy tay vào `MQL5\Sounds\`**, không phải chỉ `MQL5\Files\Sounds\` (dù đó là nơi combobox chọn/hiển thị).

## BÍ ẨN MỚI (2026-08-12) — riêng `NewBar.wav` vẫn lỗi dù mọi thứ đã đúng chỗ
Sau kết luận "ĐÃ DỨT ĐIỂM" ở trên (đúng với `SIGNAL_BUY_EN.wav`/`SIGNAL_SELL_EN.wav`), test `NewBar.wav` riêng vẫn fail:
```
MY DEBUG CGUIPannel::PlaySoundFile - filename=NewBar.wav PlaySound returned=false GetLastError=5019
```
5019 = "File does not exist" (tra trong `MessageData.mqh`). Đã loại trừ lần lượt, TẤT CẢ đều ổn:
- File tồn tại thật ở `MQL5\Sounds\NewBar.wav` (đã tự kiểm tra bằng Glob).
- Size khớp, không phải file 0-byte/hỏng (54482 bytes, khớp cả 2 thư mục).
- Header WAV hợp lệ: RIFF/WAVE/PCM, mono, 22050Hz, 16-bit.
- Không bị khóa bởi File Explorer (đã đóng hết rồi test lại, vẫn lỗi).
- Không có cờ Zone.Identifier (Mark of the Web - Windows chặn file tải từ internet) - đã check bằng `Get-Item -Stream`.
- Đúng tên/case file (`NewBar.wav` khớp chính xác).
- String literal `"NewBar.wav"` trong source code sạch, không ký tự ẩn (check bằng `xxd`).
- **Raw `winmm.dll` PlaySound() gọi thẳng từ PowerShell (hoàn toàn ngoài MQL5) phát được bình thường** - cả full path lẫn kiểm tra file - Anhnt tự nghe thấy tiếng thật lúc assistant chạy test này.

→ File hoàn toàn không có vấn đề gì cả. Nghi vấn cuối: có thể liên quan tới **ngữ cảnh/thời điểm gọi trong EA** (CloseBar gọi trong vòng lặp phức tạp hơn Live) khiến riêng "NewBar.wav" bị lỗi, không phải "SIGNAL_BUY/SELL".

**Test cô lập đang thêm (2026-08-12, CHƯA CÓ KẾT QUẢ)**: 1 lệnh gọi `PlaySoundFile("NewBar.wav")` tạm thời trong `OnInitEvent()` ([GUIPannel_Lifecycle.mqh](../Anatoli%20Kazharski/GUIPannel_Lifecycle.mqh), ngay sau `m_gui_created = true;`) - chạy đúng 1 lần lúc EA khởi động, cô lập hoàn toàn khỏi CheckIndicatorAlerts/CheckCandlePatternAlerts. Nếu vẫn fail ở đây → lỗi thật sự riêng của tên file "NewBar.wav" trong MQL5 (chưa rõ vì sao). Nếu thành công → vấn đề nằm ở ngữ cảnh gọi bên trong CloseBar.
- **CẦN XOÁ sau khi có kết quả**: cả lệnh gọi `PlaySoundFile("NewBar.wav");` lẫn comment "TEMP DEBUG" bao quanh nó trong `OnInitEvent()`.

---

## PHÁT HIỆN MỚI (2026-08-11, sau khi test bản đã fix) - vấn đề không nằm ở code

Test thực tế: sau khi build lại, Anhnt báo **"Không hề kêu"** kể cả khi các lệnh Live cách nhau vài giây (không hề chồng chéo - log 22:29:49→22:30:19 cho thấy khoảng cách 2-9s giữa các lần, `PlaySound()` vẫn `true` đều) → **phản bác giả thuyết "chồng chéo" là nguyên nhân duy nhất**.

Chuỗi test cô lập đã làm để loại trừ nguyên nhân:
1. Windows Volume Mixer: app MT5 (`terminal64.exe`) không hề mute, volume 100 - loại trừ.
2. Detach/attach lại EA để trigger `expert.wav` (sound MT5 tự phát, KHÔNG qua code EA) → **im lặng** → chứng minh không phải bug code, mà là tầng terminal/OS.
3. Nghi vấn "chạy MT5 as Administrator → UAC audio session isolation" → loại trừ, vì lúc khởi động MT5 Anhnt CÓ nghe tiếng.
4. **Làm rõ tiếng nghe được lúc khởi động** hoá ra chính là 1 tiếng `"Sell Signal"` (sound của chính EA mình, không phải MT5/Windows) - phát được ĐÚNG 1 LẦN, rồi im.
5. Sau đó Anhnt báo lại "có kêu lại" 1 lần nữa → hành vi **ngắt quãng/không ổn định** (lúc kêu lúc không), không phải "chỉ kêu 1 lần đầu rồi câm vĩnh viễn".

**Giả thuyết đang treo**: `::PlaySound()` gọi lặp lại nhiều lần (dù cách xa nhau về thời gian) có thể bị rò rỉ/treo handle âm thanh trên Windows - fix kinh điển là gọi `::PlaySound(NULL)` (dừng/giải phóng phát trước đó) ngay trước mỗi lần gọi `::PlaySound(file)` mới. **CHƯA áp dụng** - Anhnt đang theo dõi thêm hành vi thực tế trước khi quyết định có cần thêm fix này không.

---

## Trạng thái
- [x] Loại trừ: file hỏng, config sai, checkbox tắt, code-đọc-tĩnh không thấy lỗi rõ.
- [x] Debug Print() đã chèn (2026-08-10), sẵn sàng lấy log.
- [x] **Đã lấy log thật** (2026-08-11, `MQL5\Logs\20260811.log`) — `::PlaySound()` return `true` 100%, file `.wav` tồn tại đúng chỗ.
- [x] Xác định root cause #1: gọi `::PlaySound()` quá dồn dập (10-67ms/lần, do nhiều indicator tương quan cùng flip 1 bar) khiến các lệnh phát đè/ngắt lẫn nhau.
- [x] Sửa hiểu nhầm OnTick vs OnTimerEvent + dọn bug gọi `CheckCandlePatternAlerts()` 2 lần (2026-08-11).
- [x] Thử mark-then-play (deferred đến cuối OnTickEvent) → phát hiện bug mới (CloseBar luôn đè Live) → revert.
- [x] Thử bỏ hẳn Sound CloseBar → Anhnt sửa lại: không phải bỏ, chỉ là dùng chung 1 file `NewBar.wav` → revert lại lần nữa.
- [x] **Chốt cuối**: CloseBar Sound = `NewBar.wav` cố định, phát NGAY tại chỗ phát hiện (không dời cuối), dedup 1 lần/lượt - xem mục "QUYẾT ĐỊNH CUỐI" ở trên.
- [x] ~~Nghi vấn tầng OS/PlaySound handle (mục "PHÁT HIỆN MỚI") → Anhnt test thêm với `NewBar.wav`, phát hiện root cause THẬT: `MQL5\Sounds\` vs `MQL5\Files\Sounds\` là 2 thư mục khác nhau, `::PlaySound(bare_filename)` chỉ đọc thư mục đầu, không phải OS bug.~~ **SAI (xem "KẾT LUẬN ĐÚNG CUỐI CÙNG")** - `MQL5\Sounds\` không phải thư mục `::PlaySound()` đọc, chỉ trùng hợp file test hôm đó có sẵn ở nơi khác.
- [x] Thử fix bằng full absolute path (`PlaySoundFile` build path vào `MQL5\Files\...`) → **SAI, đã revert** - `::PlaySound()` chỉ chấp nhận bare filename tìm trong 1 thư mục cố định (xem kết luận đúng bên dưới), không nhận path tuyệt đối tùy ý (giới hạn cứng của API, không phải sandbox). Đã revert `PlaySoundFile()` về đúng `::PlaySound(filename)` đơn giản.
- [x] **Root cause đúng tìm ra 2026-08-13** (nhờ thêm `TERMINAL_PATH`/`TERMINAL_DATA_PATH` vào debug Print) - xem "KẾT LUẬN ĐÚNG CUỐI CÙNG" bên dưới.
- [x] **Anhnt copy tay `NewBar.wav` sang `C:\Program Files\MetaTrader 5\Sounds\`** (đúng thư mục thật) rồi build/test lại - **xác nhận `PlaySound returned=true GetLastError=0`, nghe tiếng thật.** ĐÃ XONG.
- [ ] Xóa `MY DEBUG` Print() còn lại (nếu có) sau khi mọi thứ ổn định.
- [ ] Chưa quyết: hướng hợp nhất-1-thư-mục lâu dài (DLL import `winmm.dll`) cho combobox Buy/Sell Sound - xem "KẾT LUẬN ĐÚNG CUỐI CÙNG".

---

## KẾT LUẬN ĐÚNG CUỐI CÙNG (2026-08-13) - sửa lại toàn bộ 2 mục "ĐÃ DỨT ĐIỂM"/"XÁC NHẬN BẰNG LOG THẬT" ở trên

Sau khi thêm `PlaySoundCloseBar()` (tách riêng sự kiện "có bar mới" ra khỏi vòng lặp per-flip của `CheckIndicatorAlerts`/`CheckCandlePatternAlerts` - logic gọi giờ đúng, bắn đúng 1 lần/bar) và thêm `TERMINAL_PATH`/`TERMINAL_DATA_PATH` vào debug Print của `PlaySoundFile()`, log thật từ chính EA (không phải test ngoài PowerShell) cho thấy:

```
14:17:37  NewBar.wav                     → false, 5019 | TERMINAL_PATH=C:\Program Files\MetaTrader 5
14:17:39  BUYLIMIT_ORDER_DELETE_EN.wav   → true,  0    | TERMINAL_PATH=C:\Program Files\MetaTrader 5
```

**Cùng `TERMINAL_PATH`, cùng lệnh gọi `::PlaySound(filename)`** - khác biệt duy nhất: file có tồn tại vật lý trong `TERMINAL_PATH\Sounds\` (`C:\Program Files\MetaTrader 5\Sounds\`, thư mục CÀI ĐẶT terminal, dùng chung cho mọi profile/data-folder) hay không:
- `BUYLIMIT_ORDER_DELETE_EN.wav` - có sẵn ở đó (1 trong các sound gốc MetaQuotes ship kèm installer) → phát được.
- `NewBar.wav` - KHÔNG có ở đó, dù đã có sẵn ở cả `MQL5\Sounds\` và `MQL5\Files\Sounds\` (2 thư mục data-folder) → luôn `5019`.

**Root cause thật, thay thế hoàn toàn 2 mục kết luận sai ở trên**: `::PlaySound(bare_filename)` CHỈ đọc `TERMINAL_PATH\Sounds\` (thư mục cài đặt terminal). Nó **KHÔNG** đọc `MQL5\Sounds\` (data folder theo từng terminal ID) như 2 mục "ĐÃ DỨT ĐIỂM 2026-08-12" từng kết luận - kết luận đó "đúng" chỉ vì trùng hợp `SIGNAL_BUY_EN.wav`/`SIGNAL_SELL_EN.wav`/`AUTO_TRADING_ON_RU.wav` là sound GỐC của MetaQuotes, có sẵn ở CẢ 2 nơi (cài đặt lẫn data folder Anhnt tự copy tay) - việc copy tay vào `MQL5\Sounds\` chưa từng là cái làm chúng phát được.

**Đã fix xong (2026-08-13)**: Anhnt copy tay `NewBar.wav` vào `C:\Program Files\MetaTrader 5\Sounds\` → log đổi thành `true`/`GetLastError=0`, nghe tiếng thật. Đóng bug.

**Vấn đề kiến trúc còn treo, chưa quyết định** (bàn riêng ngày 13/08, không phải bug, không chặn gì): combobox Buy/Sell Sound (`GUIPannel_TabSettingMarker.mqh:334`, `ScanSoundFolder()`) chỉ scan được `MQL5\Files\<m_marker_sound_folder>\` (giới hạn của `FileFindFirst`) - không bao giờ trùng được với `TERMINAL_PATH\Sounds\` (giới hạn của `::PlaySound()`) bằng bất kỳ tham số/setting nào - 2 API sandbox theo 2 hướng đối nghịch nhau, không có thư mục chung. Hệ quả: **bất kỳ file `.wav` mới nào user chọn qua combobox sau này đều sẽ dính lại đúng bug 5019 này** cho tới khi có ai nhớ copy tay thêm 1 bản vào `TERMINAL_PATH\Sounds\` (cần quyền Admin vì là Program Files).

Hướng duy nhất tìm được để gộp thật về 1 thư mục: bypass `::PlaySound()` built-in, dùng `#import "winmm.dll"` gọi thẳng `PlaySoundW` (full path hoặc `SND_MEMORY` + bytes đọc qua `FileOpen`) - bỏ qua được giới hạn 2-thư-mục-cố-định vì đây là WinAPI thô, đọc được path bất kỳ kể cả `MQL5\Files\...`. Cần bật "Allow DLL imports" cho EA. **Chưa code, Anhnt đang cân nhắc.**

## ĐƠN GIẢN HOÁ LẠI (2026-08-14) - bỏ hẳn dedup per-flip cho CloseBar, bỏ `PlaySoundFile()`

Sau khi root cause thư mục đã đóng xong (mục "KẾT LUẬN ĐÚNG CUỐI CÙNG" ở trên), rà soát lại thấy toàn bộ cơ chế `m_closebar_sound_played` (dựng ra để dedup Sound giữa nhiều flip Indicator/CandlePattern cùng lúc CloseBar, xem "QUYẾT ĐỊNH CUỐI 2026-08-11") giờ không còn cần thiết - đơn giản hoá lại theo quyết định mới của Anhnt:

- **CloseBar giờ chỉ còn 1 nguồn Sound duy nhất**: `PlaySoundCloseBar()` - phát `NewBar.wav` vô điều kiện mỗi khi `IsNewBar()` true, KHÔNG còn phụ thuộc có flip Indicator/CandlePattern hay không.
- **`CheckIndicatorAlerts()`/`CheckCandlePatternAlerts()` nhánh CloseBar bỏ hẳn phần Sound** - chỉ còn ghi Message/CSV đầy đủ như cũ (không mất thông tin, chỉ mất phần tự phát sound riêng theo từng flip).
- **Xoá `m_closebar_sound_played`** khỏi cả 4 nơi: khai báo (`GUIPannel.mqh`), reset (`GUIPannel_Lifecycle.mqh`), 2 chỗ check-and-set trong `CheckIndicatorAlerts`/`CheckCandlePatternAlerts`.
- **Xoá hẳn `PlaySoundFile()` wrapper** (guard rỗng + debug Print) - debug phase coi như xong, gọi thẳng `::PlaySound()` ở cả 3 chỗ còn lại (`PlaySoundCloseBar`, `PlaySoundForDirection`). Guard rỗng-tên-file dời vào thẳng `PlaySoundForDirection` (nơi duy nhất còn cần, vì `m_marker_buy_sound_file`/`sell` có thể chưa chọn).
- **`m_candle_pattern_closebar_last_dir[]` giữ nguyên** (không xoá lại lần nữa, xem "Thử sai #2" ở trên từng xoá nhầm) - vẫn được cập nhật mỗi CloseBar dù không còn dùng để gate Sound nữa, phòng khi cần lại sau này.

## File liên quan
- `V8/Anatoli Kazharski/GUIPannel_SoundAndMessageAlerts.mqh` — `CheckIndicatorAlerts` (2 nhánh CloseBar + Live), `PlaySoundCloseBar()`, `PlaySoundForDirection()`
- `V8/Anatoli Kazharski/GUIPannel_Lifecycle.mqh:584-599` — wiring combobox chọn sound file
- `V8/Anatoli Kazharski/GUIPannel_TabSettingMarker.mqh:334` — `ScanSoundFolder()`, tab Marker, nơi chọn Buy/Sell Sound (chỉ scan được `MQL5\Files\...`, khác thư mục `::PlaySound()` thật sự đọc)
