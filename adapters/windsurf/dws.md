# DingTalk Operations (dws)

For any DingTalk-related task, execute via `wukong-cli` as shown below.

**Prerequisite:** Wukong (悟空) desktop app must be running and logged in.
If the named pipe `\\.\pipe\real-daemon` is absent, tell the user to launch it.

## Execution

**Check daemon:**
```powershell
[System.IO.Directory]::GetFiles("\\.\pipe\") | Where-Object { $_ -match "real-daemon" }
```
No output → tell user: *"请先启动 Wukong（悟空）桌面端并登录钉钉账号。"*

**Find wukong-cli (once per session):**
```powershell
$wkcli = $null
# 1. From running Wukong process (fastest)
$exe = Get-Process -ErrorAction SilentlyContinue |
       Where-Object { $_.Path -and $_.Path -match '\\Wukong\\' } |
       Select-Object -First 1 -ExpandProperty Path
if ($exe) {
    $root = $exe
    for ($i = 0; $i -lt 3; $i++) {
        $parent = Split-Path $root -Parent
        if (-not $parent -or $parent -eq $root) { break }
        $root = $parent
        if ((Split-Path $root -Leaf) -eq 'Wukong') { break }
    }
    $wkcli = Get-ChildItem $root -Filter "wukong-cli.exe" -Recurse -ErrorAction SilentlyContinue |
             Select-Object -First 1 -ExpandProperty FullName
}
# 2. PATH fallback
if (-not $wkcli -and (Get-Command wukong-cli -ErrorAction SilentlyContinue)) { $wkcli = "wukong-cli" }
# 3. Registry fallback
if (-not $wkcli) {
    $dir = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
                         "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" `
        -ErrorAction SilentlyContinue | Get-ItemProperty |
        Where-Object { $_.DisplayName -like "*Wukong*" -or $_.DisplayName -like "*悟空*" } |
        Select-Object -ExpandProperty InstallLocation -First 1
    if ($dir) {
        $wkcli = Get-ChildItem $dir -Recurse -Filter "wukong-cli.exe" -ErrorAction SilentlyContinue |
                 Select-Object -First 1 -ExpandProperty FullName
    }
}
```

**Execute:**
```powershell
$result = & $wkcli --socket "\\.\pipe\real-daemon" `
    -p "<task description>" `
    --output-format json `
    --max-turns 3 `
    2>&1 | Select-Object -First 20
($result | ConvertFrom-Json).output_text
```

`--max-turns`: 3 = simple · 5 = multi-step · 8 = batch

## Rules
- Confirm before destructive/intrusive actions: delete, dissolve group, DING, OA approve/reject.
- Never fabricate IDs — query first.
- Always include `| Select-Object -First 20`.
