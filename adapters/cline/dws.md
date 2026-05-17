# DingTalk Operations (dws)

For any DingTalk-related task, execute via `wukong-cli` as shown below.

**Prerequisite:** Wukong (悟空) desktop app must be running and logged in to DingTalk.
Named pipe: `\\.\pipe\real-daemon` must exist.

## When to Use

Trigger this skill whenever the user asks to:
- Send or read DingTalk messages
- Read or write documents / knowledge base articles
- Check calendar, book meetings, reserve rooms
- Handle OA approvals (view pending, approve, reject)
- Manage todos / tasks
- Search contacts, departments, or org chart
- Check attendance, send emails, query AI meeting minutes
- Upload/download files from DingDrive
- Any other DingTalk operation

## Procedure

### 1. Check daemon
```powershell
[System.IO.Directory]::GetFiles("\\.\pipe\") | Where-Object { $_ -match "real-daemon" }
```
No output → daemon offline. Tell user: *"Please start the Wukong (悟空) desktop app and log in to DingTalk."*

### 2. Find wukong-cli (once per session)
```powershell
$wkcli = $null
# 1. From running Wukong process (fastest)
$exe = Get-Process -ErrorAction SilentlyContinue | ForEach-Object {
    try { if ($_.Path -and $_.Path -match '\\Wukong\\\d') { $_.Path } } catch { }
} | Select-Object -First 1
if ($exe) {
    $root = $exe; $found = $false
    for ($i = 0; $i -lt 3; $i++) {
        $parent = Split-Path $root -Parent
        if (-not $parent -or $parent -eq $root) { break }
        $root = $parent
        if ((Split-Path $root -Leaf) -eq 'Wukong') { $found = $true; break }
    }
    if ($found) {
        $wkcli = Get-ChildItem $root -Filter "wukong-cli.exe" -Recurse -ErrorAction SilentlyContinue |
                 Select-Object -First 1 -ExpandProperty FullName
    }
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

### 3. Execute task
```powershell
$result = & $wkcli --socket "\\.\pipe\real-daemon" `
    -p "<detailed task description>" `
    --output-format json `
    --max-turns 3 `
    2>&1 | Select-Object -First 20
($result | ConvertFrom-Json).output_text
```

`--max-turns`: 3 = simple · 5 = multi-step · 8 = batch

## Wukong UX Hint (proactive, first dws use per session)

Wukong's default chat auth mode is **"手动授权" (manual)** — every dws operation triggers a confirmation popup in the Wukong client. On the user's first dws use this session, tell them:

> 💡 In Wukong's chat box, the **shield-icon dropdown at the bottom-right** lets you switch from "手动授权" to "**自动授权（所有会话）**" to skip these popups for all non-destructive operations. High-risk actions (DING, delete, OA approve) still confirm separately. Local-only and reversible.

Don't repeat if the user has already changed it or declined.

## Safety Rules
- **Confirm first** for: delete documents/files, dissolve groups, send DING urgent messages, OA approve/reject.
- **Never fabricate** IDs, UUIDs, URLs, or phone numbers — query to get the real value first.
- **Always append** `| Select-Object -First 20` to every wukong-cli call.
