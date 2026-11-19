# Command Note

Các command cần thiết theo từng thành phần/phạm vi trong [Working scope và Sync Everywhere](../AGENTS.md#working-scope-và-sync-everywhere).

Mỗi command ghi rõ mục đích, thư mục chạy, lệnh và kết quả mong đợi. Chỉ ghi command đã xác nhận.

## EA Module

**Phạm vi:** `D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V5\`, ngoại trừ `Web\`.

### [Mục đích command]

- **Chạy tại:** `<thư mục>`
- **Command:**
  ```powershell
  <command>
  ```
- **Kết quả mong đợi:** `<kết quả>`

## EA Web

**Phạm vi:** `D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V5\Web\`.

### [Mục đích command]

- **Chạy tại:** `<thư mục>`
- **Command:**
  ```powershell
  <command>
  ```
- **Kết quả mong đợi:** `<kết quả>`

## Library

 ### [Pull All]

  ```powershell
  $vendors = @(
      "D:\MT5-Dev\Library\Kronos",
      "D:\MT5-Dev\Library\tradecanvas",
      "D:\MT5-Dev\Library\xgboost"
  )

  foreach ($repo in $vendors) {
      Write-Host "Pulling $repo"
      git -C $repo pull
      if ($LASTEXITCODE -ne 0) { break }
  }
  ```
 ### [Git Ignore]
  ```powershell
  Add-Content -Path 'D:\MT5-Dev\.gitignore' -Value '/Library/xgboost/'
  ```
 ### [Git CheckIgnore]
  ```powershell
  git -C 'D:\MT5-Dev' status --short --ignored=matching
  git -C 'D:\MT5-Dev' ls-files --others --ignored --exclude-standard |
    git -C 'D:\MT5-Dev' check-ignore -v --stdin
  ```
## Library\Python

**Phạm vi:** `D:\MT5-Dev\Library\Python\`.

### [Mục đích command]

- **Chạy tại:** `<thư mục>`
- **Command:**
  ```powershell
  <command>
  ```
- **Kết quả mong đợi:** `<kết quả>`

## Database

**Phạm vi:** `<MT5_EA_DATABASE>\`

- **Alias:** `<MT5_TERMINAL_DATA>\MQL5\Files\EA V5 SQLLite\Database`
- **Terminal đang dùng:** `C:\Users\nguye\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075`

### [Mục đích command]

- **Chạy tại:** `<thư mục>`
- **Command:**
  ```powershell
  <command>
  ```
- **Kết quả mong đợi:** `<kết quả>`

## Skills

**Phạm vi:** `D:\MT5-Dev\skills\` (chỉ sửa khi có yêu cầu rõ trong lượt hiện tại).

### [Mục đích command]

- **Chạy tại:** `<thư mục>`
- **Command:**
  ```powershell
  <command>
  ```
- **Kết quả mong đợi:** `<kết quả>`