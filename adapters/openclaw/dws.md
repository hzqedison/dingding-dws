---
name: dws
description: 钉钉全产品操作 — 发消息、读文档、查日程、审批OA、管理待办等
version: 1.0.0
author: hzqedison
tags: [dingtalk, dingding, productivity, messaging, documents]
---

## Description

让 AI 助手直接操作钉钉。能力覆盖：发消息/建群/机器人群发、读写文档/知识库、查日程/订会议室、OA 审批、待办管理、通讯录搜索、考勤查询、邮件、AI 听记、钉盘文件管理等钉钉全产品。

认证由 Wukong（悟空）桌面端自动托管，无需额外登录。

## When to Use

用户请求任何涉及钉钉的操作时使用，包括但不限于：
- 发送或查看钉钉消息、群消息
- 读取、创建、搜索钉钉文档或知识库
- 查询日历日程、预约会议、订会议室
- 处理 OA 审批（查看待审、同意、拒绝）
- 创建或查询待办任务
- 搜索同事信息、部门、负责人
- 查询考勤记录
- 发送或查看邮件
- 查询 AI 听记会议摘要
- 上传或下载钉盘文件

## Instructions

### 第一步：检查前置条件

使用以下 PowerShell 命令检查 Wukong 守护进程是否在运行：

```powershell
[System.IO.Directory]::GetFiles("\\.\pipe\") | Where-Object { $_ -match "real-daemon" }
```

- **有输出** → 继续执行
- **无输出** → 告知用户：「请先启动 Wukong（悟空）桌面端并登录钉钉账号，下载地址：https://wukong.dingtalk.com」，停止操作。

### 第二步：定位 wukong-cli（每次会话首次执行）

```powershell
$wkcli = $null
# 尝试1：PATH 直接调用
if (Get-Command wukong-cli -ErrorAction SilentlyContinue) { $wkcli = "wukong-cli" }
# 尝试2：注册表查找
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
# 尝试3：文件系统扫描
if (-not $wkcli) {
    $wkcli = Get-ChildItem "$env:ProgramFiles","${env:ProgramFiles(x86)}","$env:LOCALAPPDATA" `
        -Recurse -Filter "wukong-cli.exe" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -like "*Wukong*" } |
        Select-Object -First 1 -ExpandProperty FullName
}
# 找不到时提示用户
if (-not $wkcli) { Write-Host "未找到 wukong-cli.exe，请确认已安装 Wukong 桌面端" }
```

### 第三步：执行钉钉操作

```powershell
$result = & $wkcli --socket "\\.\pipe\real-daemon" `
    -p "<详细的任务描述>" `
    --output-format json `
    --max-turns 3 `
    2>&1 | Select-Object -First 20
($result | ConvertFrom-Json).output_text
```

**`--max-turns` 参考值：**
- `3`：单步查询（默认）
- `5`：多步骤或汇总操作
- `8`：复杂批量操作

**任务描述要点：** 包含具体姓名、文档 ID/URL、时间范围、期望的输出格式。

### 第四步：呈现结果

将 `output_text` 的内容整理后展示给用户。

## Safety Rules（安全要求）

以下操作**必须先向用户展示操作摘要并获得确认**，再执行：

| 操作 | 原因 |
|---|---|
| 删除文档、文件夹、钉盘文件 | 不可恢复 |
| 解散群组 | 不可恢复 |
| 发送 DING 紧急消息 | 会打扰对方（电话/短信） |
| OA 审批同意/拒绝 | 影响业务流程 |

**禁止行为：**
- 禁止编造 UUID、用户 ID、文档 ID、URL、手机号
- 禁止省略 `| Select-Object -First 20`（会导致流阻塞）
- 禁止在 Wukong 未运行时尝试调用
