# DingTalk Operations (dws)

For any task involving DingTalk — sending messages, reading documents, checking
schedules, handling approvals, managing todos, querying contacts, and more — use
the `dws` procedure below.

## Prerequisites

**Wukong (悟空) desktop app must be running** and logged in to a DingTalk account.
If the named pipe `\\.\pipe\real-daemon` does not exist, tell the user:
> "Please start the Wukong (悟空) desktop app and log in to DingTalk first.
> Download: https://wukong.dingtalk.com"

## Execution Procedure

### Step 1 — Check daemon

```powershell
[System.IO.Directory]::GetFiles("\\.\pipe\") | Where-Object { $_ -match "real-daemon" }
```

No output → daemon not running. Notify the user and stop.

### Step 2 — Locate wukong-cli.exe (run once per session)

```powershell
$wkcli = $null
# PATH
if (Get-Command wukong-cli -ErrorAction SilentlyContinue) { $wkcli = "wukong-cli" }
# Registry
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
# Filesystem fallback
if (-not $wkcli) {
    $wkcli = Get-ChildItem "$env:ProgramFiles","${env:ProgramFiles(x86)}","$env:LOCALAPPDATA" `
        -Recurse -Filter "wukong-cli.exe" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -like "*Wukong*" } |
        Select-Object -First 1 -ExpandProperty FullName
}
```

### Step 3 — Execute

```powershell
$result = & $wkcli --socket "\\.\pipe\real-daemon" `
    -p "<task description>" `
    --output-format json `
    --max-turns 3 `
    2>&1 | Select-Object -First 20
($result | ConvertFrom-Json).output_text
```

**`--max-turns` guide:** 3 = simple query · 5 = multi-step · 8 = complex batch

**Task description tips:**
- Be specific: include names, document IDs/URLs, time ranges, expected output format.
- For IDs you don't have: first query to get the ID, then act — never fabricate IDs.

## Capabilities

| Area | Examples |
|---|---|
| Messaging | Send/read messages, create groups, Webhook |
| Calendar | View schedule, book meetings, check availability |
| Docs | Read/write/search documents, knowledge base |
| Directory | Find colleagues, departments, managers |
| Todos | Create / complete / query tasks |
| Mail | Send emails, read inbox |
| OA Approval | View pending, approve / reject |
| Spreadsheets | Read/write cells, AI tables |
| Attendance | Clock-in records, shift schedules |
| AI Minutes | Meeting summaries, transcription |
| Reports | Daily/weekly report writing |
| DingDrive | Upload / download files |

## Safety Rules

- **Confirm before executing** any destructive or intrusive action:
  delete documents/files, dissolve groups, send DING urgent messages, approve/reject OA.
- **Never fabricate** UUIDs, user IDs, document IDs, URLs, or phone numbers.
- **Always include** `| Select-Object -First 20` to prevent stream blocking.
