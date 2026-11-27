# Command Note

Note lại các command để chạy cho nhanh.

## EA Module
 - **Lệnh compile:**
  ```powershell
  # /log must be a scratchpad path; a bare /log drops the log next to the source.
  Start-Process "C:\Program Files\MetaTrader 5\MetaEditor64.exe" -Wait -ArgumentList '/compile:"<file.mq5>"','/log:"<scratchpad>\compile.log"'
  Get-Content "<scratchpad>\compile.log" -Encoding Unicode
  ```

## EA Web

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
## Python Library


## Database



## Skills
 ### [Addon Skills]
  Vendor skill ở `skills\Addon\.claude\skills\` (gitignore), cài bằng skills CLI theo `skills\Addon\skills-lock.json`; plugin `mt5-tools` load qua [marketplace.json](../../.claude-plugin/marketplace.json).
  ```powershell
  Set-Location 'D:\MT5-Dev\skills\Addon'
  npx skills@latest experimental_install   # restore từ skills-lock.json (máy mới / sau khi clone)
  npx skills@latest update -p              # cập nhật bản mới, ghi lại skills-lock.json
  npx skills@latest list

  # Addon bị gitignore nên marketplace phải là source local, không phải GitHub
  claude plugin marketplace remove mt5-marketplace
  claude plugin marketplace add D:\MT5-Dev
  claude plugin install mt5-tools@mt5-marketplace
  claude plugin marketplace update mt5-marketplace   # sau mỗi lần update skill, rồi mở session mới
  ```
 ### [Khác]
 ```powershell
  claude plugin marketplace add nguyentuananh921/MT5-Dev
  claude plugin install mt5-tools@mt5-marketplace

  git add skills/
  git commit -m "Update skills files"
  git push
  claude plugin marketplace update mt5-marketplace
  claude plugin list
  claude --version
  node -v
  //MCP server
   claude mcp add <ten-server> -- <lenh-chay> <tham-so-1> <tham-so-2>
   claude mcp add my-mcp -- npx -y @modelcontextprotocol/server-filesystem D:\MT5-Dev
  // Check mcp server
   claude mcp list
  //Create mcp server
   pip install mcp
   claude mcp add -s user mt5-tools -- python D:\MT5-Dev\scripts\mt5_mcp_server.py
  //Skill
   npx skills@latest add emilkowalski/skills --skill emil-design-eng -a claude-code -g
   npx skills@latest add pbakaus/impeccable --skill impeccable -a claude-code -g
  //Xóa bản cũ
   npx skills remove --global emil-design-eng
  //
   Set-Location 'D:\MT5-Dev\skills\Addon'
   cd /d D:\MT5-Dev\skills\Addon
   npx skills@latest add emilkowalski/skills --skill emil-design-eng -a claude-code
   npx skills@latest add pbakaus/impeccable --skill impeccable -a claude-code
   claude --add-dir 'D:\MT5-Dev\skills\Addon'
 ```powershell

/plugin marketplace add nguyentuananh921/MT5-Dev
/plugin install nguyentuananh921@tradecanvasMT5-Dev

/emil-design-eng Review the animation and interaction on this page.
/impeccable Critique and polish this page for production.