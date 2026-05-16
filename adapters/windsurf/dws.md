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
if (Get-Command wukong-cli -ErrorAction SilentlyContinue) { $wkcli = "wukong-cli" }
if (-not $wkcli) {
    $dir = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
                         "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" `
        -ErrorAction SilentlyContinue | Get-ItemProperty |
        Where-Object { $_.DisplayName -like "*Wukong*" -or $_.DisplayName -like "*悟空*" } |
        Select-Object -ExpandProperty InstallLocation -First 1
    if ($dir) {
        $found = Get-ChildItem $dir -Recurse -Filter "wukong-cli.exe" -ErrorAction SilentlyContinue |
                 Select-Object -First 1 -ExpandProperty FullName
        if ($found) { $wkcli = $found }
    }
}
if (-not $wkcli) {
    $wkcli = Get-ChildItem "$env:ProgramFiles","${env:ProgramFiles(x86)}","$env:LOCALAPPDATA" `
        -Recurse -Filter "wukong-cli.exe" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -like "*Wukong*" } |
        Select-Object -First 1 -ExpandProperty FullName
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
