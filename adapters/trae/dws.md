---
name: dws
description: 钉钉全产品操作 — 发消息、读文档、查日程、审批OA、管理待办、搜通讯录等所有钉钉相关操作
---

## Description

让 Trae 直接操作钉钉。凡是涉及钉钉的操作（消息、文档、日程、审批、待办、通讯录、考勤、邮件等）均通过此 skill 完成。

## When to Use

用户提到以下任何场景时触发：
- 发消息 / 建群 / 拉人进群 / 机器人群发
- 读取 / 编写钉钉文档 / 知识库
- 查日程 / 约会议 / 订会议室
- OA 审批（查待审、同意、拒绝）
- 管理待办 / TODO
- 搜同事 / 查部门 / 找负责人
- 查考勤 / 查打卡
- 发邮件 / 查邮件
- 查 AI 听记摘要
- 上传下载钉盘文件
- 写日报 / 周报

## Instructions

### 前置检查

**必须先确认 Wukong（悟空）守护进程在运行：**

```powershell
[System.IO.Directory]::GetFiles("\\.\pipe\") | Where-Object { $_ -match "real-daemon" }
```

无输出 → 告知用户：「请先启动 Wukong（悟空）桌面端并登录钉钉账号。」
下载地址：https://wukong.dingtalk.com

### 定位 wukong-cli（每次会话首次使用前执行一次）

```powershell
$wkcli = $null
# 1. 从运行中的 Wukong 进程定位（最快）
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
# 3. 注册表 fallback
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

### 执行任务（标准模板）

```powershell
$result = & $wkcli --socket "\\.\pipe\real-daemon" `
    -p "<任务描述>" `
    --output-format json `
    --max-turns 3 `
    2>&1 | Select-Object -First 20
($result | ConvertFrom-Json).output_text
```

`--max-turns` 参考：3 = 简单查询 · 5 = 多步骤 · 8 = 复杂批量

### 严格要求

- 危险操作（删除文档/文件、解散群、发 DING、审批同意/拒绝）**必须先向用户确认**
- **禁止编造** ID、UUID、URL、手机号 — 先查询再操作
- wukong-cli 调用**必须加** `| Select-Object -First 20`，防止流阻塞
