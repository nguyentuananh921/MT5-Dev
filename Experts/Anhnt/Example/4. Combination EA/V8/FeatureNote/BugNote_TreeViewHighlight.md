# Bug: CTreeView (Symbol TF, panel trái) highlight sai

## Ghi nhận (Anhnt, 2026-08-12)
Quan sát qua screenshot lúc đang test Sound: `CTreeView` panel trái (danh sách TF: M1, M5, M15, M30, H1, H4) đang highlight/select **không đúng** so với TF thực tế đang active (tab dưới cùng đang mở là `XAUUSDm,M1`).

**Chưa điều tra kỹ** — chỉ note lại để không quên, đang tập trung xử lý vụ Sound trước (xem `SoundBugNote.md`).

## Việc cần làm khi quay lại
- [ ] Chụp lại/tái hiện chính xác tình huống gây sai highlight (đổi TF bằng cách nào, symbol nào).
- [ ] Xác định `CTreeView` này thuộc control nào trong `GUIPannel_TabSettingSymbolTF.mqh` hay panel trái main window.
- [ ] So sánh với cơ chế cập nhật highlight hiện có (nếu có) - có đang đồng bộ với tab/chart active không.
