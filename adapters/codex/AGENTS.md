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
# Step 1: Locate from the running Wukong process (fastest — daemon is already required)
$exe = Get-Process -ErrorAction SilentlyContinue | ForEach-Object {
    try { if ($_.Path -and $_.Path -match '\\Wukong\\\d') { $_.Path } } catch { }
} | Select-Object -First 1
if ($exe) {
    $searchRoot = $exe
    $foundWukongRoot = $false
    for ($i = 0; $i -lt 3; $i++) {
        $parent = Split-Path $searchRoot -Parent
        if (-not $parent -or $parent -eq $searchRoot) { break }
        $searchRoot = $parent
        if ((Split-Path $searchRoot -Leaf) -eq 'Wukong') { $foundWukongRoot = $true; break }
    }
    if ($foundWukongRoot) {
        $wkcli = Get-ChildItem $searchRoot -Filter "wukong-cli.exe" -Recurse -ErrorAction SilentlyContinue |
                 Select-Object -First 1 -ExpandProperty FullName
    }
}
# Step 2 fallback: PATH
if (-not $wkcli -and (Get-Command wukong-cli -ErrorAction SilentlyContinue)) { $wkcli = "wukong-cli" }
# Step 3 fallback: Registry
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
