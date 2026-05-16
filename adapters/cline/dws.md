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

## Safety Rules
- **Confirm first** for: delete documents/files, dissolve groups, send DING urgent messages, OA approve/reject.
- **Never fabricate** IDs, UUIDs, URLs, or phone numbers — query to get the real value first.
- **Always append** `| Select-Object -First 20` to every wukong-cli call.
