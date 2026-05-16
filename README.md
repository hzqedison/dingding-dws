# dws-skill for AI Agents

<p align="center">
  <a href="#中文介绍">中文</a> · <a href="#english">English</a>
</p>

---

## 中文介绍

让各种 AI Agent 直接操作钉钉——读文档、发消息、查日程、审批 OA、管理待办……

### 支持的平台

| 平台 | 安装方式 | 状态 |
|---|---|---|
| **Claude Code** | skill 文件 | ✅ |
| **Cursor** | MCP Server + `.cursor/rules/` | ✅ |
| **Windsurf** | MCP Server + `.windsurf/rules/` | ✅ |
| **Cline** (VS Code) | MCP Server + `.cline/rules/` | ✅ |
| **Trae** (字节) | skill 文件 + MCP | ✅ |
| **OpenAI Codex CLI** | `~/.codex/AGENTS.md` + MCP | ✅ |
| **OpenClaw / WorkBuddy** | skill 文件（界面导入） | ✅ |

### 前置条件

**安装并运行 [Wukong（悟空）桌面端](https://wukong.dingtalk.com)**，登录钉钉账号保持在线即可。认证由 Wukong 自动托管，无需额外配置。

> Wukong 未运行时，AI 会提示你先启动它。

### 一键安装（交互式，自动选择平台）

在 PowerShell 中运行：

```powershell
irm https://raw.githubusercontent.com/hzqedison/dingding-dws/main/install.ps1 | iex
```

脚本会询问你要安装哪些平台，按需选择即可。支持多选（如 `1,2,3`）或直接回车全部安装。

**安装内容：**
- Claude Code：skill 文件 → `~/.claude/skills/`，斜杠命令 → `~/.claude/commands/`
- Cursor / Windsurf / Cline / Trae / Codex：MCP Server → `~/.mcp/dws/` + 各平台配置文件
- OpenClaw：输出 `dws-openclaw.md` 到当前目录，手动导入

> MCP Server 需要 Node.js ≥ 18。

### 工作原理

```
AI Agent
  │
  ├─ Claude Code  →  ~/.claude/skills/dws.md（skill 文件）
  ├─ Cursor       →  MCP Server（stdio）
  ├─ Windsurf     →  MCP Server（stdio）
  ├─ Cline        →  MCP Server（stdio）
  ├─ Trae         →  ~/.trae/skills/dws.md 或 MCP Server
  ├─ Codex CLI    →  ~/.codex/AGENTS.md 或 MCP Server
  └─ OpenClaw     →  skill 文件（界面导入）
        │
        ▼
  wukong-cli ←→ Wukong 守护进程（\\.\pipe\real-daemon）
        │
        ▼
    钉钉 API
```

认证由 Wukong 桌面端全程托管，AI Agent 无需单独登录。

### 使用示例

无论使用哪个平台，直接用自然语言描述钉钉任务即可：

```
帮我搜一下钉钉里的会议纪要
给张三发条消息：明天下午3点开会
查一下我今天的日程安排
读取这个文档 https://alidocs.dingtalk.com/i/nodes/xxx
帮我审批一下待处理的 OA
```

Claude Code 还支持显式 `/dws` 斜杠命令：

```
/dws 查我本周的考勤记录
/dws 列出研发群最近50条消息
```

### 能力覆盖

| 产品 | 功能 |
|---|---|
| 消息/群聊 | 发消息、建群、拉人、机器人群发、Webhook |
| 日历 | 查日程、约会议、订会议室、查闲忙 |
| 文档 | 读文档、写文档、搜文档、知识库管理 |
| 通讯录 | 搜同事、查部门、找负责人、查工号/手机号 |
| 待办 | 创建/查询/完成 TODO |
| 邮件 | 发邮件、查收件箱 |
| OA 审批 | 查待审、同意/拒绝 |
| AI 表格 | 建表、查记录、写数据 |
| 电子表格 | 单元格读写、公式、导出 |
| 考勤 | 查打卡记录、排班 |
| AI 听记 | 查摘要、转写、关键词 |
| 日志 | 写日报/周报、查收件箱 |
| 钉盘 | 上传/下载/浏览文件 |
| 更多 | DING 消息、视频会议、直播、AI 应用… |

### 手动安装

<details>
<summary>点击展开手动安装说明</summary>

**Claude Code：**
```
~/.claude/
├── skills/
│   ├── dws.md
│   ├── dws-refs/
│   └── dws-scripts/
└── commands/
    └── dws.md
```

**MCP Server（Cursor / Windsurf / Cline / Trae）：**
```powershell
# 1. 复制 mcp/ 目录到 ~/.mcp/dws/
# 2. cd ~/.mcp/dws && npm install
# 3. 在各平台 mcp.json 中添加：
{
  "mcpServers": {
    "dws": {
      "command": "node",
      "args": ["C:/Users/<你的用户名>/.mcp/dws/server.js"]
    }
  }
}
```

各平台 MCP 配置文件位置：

| 平台 | 配置文件路径 |
|---|---|
| Cursor（全局） | `%USERPROFILE%\.cursor\mcp.json` |
| Windsurf | `%USERPROFILE%\.codeium\windsurf\mcp_config.json` |
| Cline | `%APPDATA%\Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json` |
| Trae（项目级） | `.trae\mcp.json` |

**Trae（skill 文件）：** 复制 `adapters/trae/dws.md` → `%USERPROFILE%\.trae\skills\dws.md`

**Codex CLI：** 将 `adapters/codex/AGENTS.md` 内容追加到 `%USERPROFILE%\.codex\AGENTS.md`

**OpenClaw / WorkBuddy：** 在界面中导入 `adapters/openclaw/dws.md`

</details>

---

## English

Give your AI agent the ability to operate DingTalk — read documents, send messages,
check schedules, handle OA approvals, manage todos, and much more.

### Supported Platforms

| Platform | Install Method | Status |
|---|---|---|
| **Claude Code** | Skill file | ✅ |
| **Cursor** | MCP Server + `.cursor/rules/` | ✅ |
| **Windsurf** | MCP Server + `.windsurf/rules/` | ✅ |
| **Cline** (VS Code) | MCP Server + `.cline/rules/` | ✅ |
| **Trae** (ByteDance) | Skill file + MCP | ✅ |
| **OpenAI Codex CLI** | `~/.codex/AGENTS.md` + MCP | ✅ |
| **OpenClaw / WorkBuddy** | Skill file (GUI import) | ✅ |

### Prerequisites

**Install and run [Wukong desktop app](https://wukong.dingtalk.com)** and stay logged in to your DingTalk account. Authentication is fully managed by Wukong — no extra setup needed.

> If Wukong is not running, the AI will prompt you to start it first.

### One-Click Install (interactive, platform selector)

Run in PowerShell:

```powershell
irm https://raw.githubusercontent.com/hzqedison/dingding-dws/main/install.ps1 | iex
```

The script asks which platforms to install. Select one or more (e.g. `1,2,3`) or press Enter to install all.

**What gets installed:**
- Claude Code: skill files → `~/.claude/skills/`, slash command → `~/.claude/commands/`
- Cursor / Windsurf / Cline / Trae / Codex: MCP Server → `~/.mcp/dws/` + platform config patches
- OpenClaw: outputs `dws-openclaw.md` to current directory for manual GUI import

> MCP Server requires Node.js ≥ 18.

### How It Works

```
AI Agent
  │
  ├─ Claude Code  →  skill file (~/.claude/skills/dws.md)
  ├─ Cursor       →  MCP Server (stdio)
  ├─ Windsurf     →  MCP Server (stdio)
  ├─ Cline        →  MCP Server (stdio)
  ├─ Trae         →  skill file or MCP Server
  ├─ Codex CLI    →  AGENTS.md or MCP Server
  └─ OpenClaw     →  skill file (GUI import)
        │
        ▼
  wukong-cli  ←→  Wukong daemon  (\\.\pipe\real-daemon)
        │
        ▼
    DingTalk API
```

Authentication is fully handled by the Wukong desktop app. No separate AI agent login required.

### Usage Examples

Just describe what you want in natural language, on any platform:

```
Search for meeting notes in DingTalk
Send Zhang San a message: meeting at 3pm tomorrow
What's on my calendar today?
Read this document https://alidocs.dingtalk.com/i/nodes/xxx
Show my pending OA approvals
```

On Claude Code, the explicit `/dws` command is also available:

```
/dws show my attendance records for this week
/dws list the last 50 messages in the dev group
```

### Capabilities

| Product | Features |
|---|---|
| Messaging / Group Chat | Send messages, create groups, add members, bot broadcast, Webhook |
| Calendar | View schedule, book meetings, reserve rooms, check availability |
| Docs | Read, write, search documents, manage knowledge base |
| Directory | Search colleagues, browse departments, find owners, look up employee info |
| Todos | Create / query / complete TODO items |
| Mail | Send emails, read inbox |
| OA Approval | View pending approvals, approve / reject |
| AI Sheets | Create tables, query records, write data |
| Spreadsheets | Read/write cells, formulas, export |
| Attendance | Check clock-in records, view shift schedules |
| AI Minutes | Summaries, transcription, keyword extraction |
| Reports | Write daily / weekly reports, read report inbox |
| DingDrive | Upload / download / browse files |
| More | DING urgent messages, video meetings, live streams, AI apps… |

### Manual Install

<details>
<summary>Expand for manual install instructions</summary>

**Claude Code:**
```
~/.claude/
├── skills/
│   ├── dws.md
│   ├── dws-refs/
│   └── dws-scripts/
└── commands/
    └── dws.md
```

**MCP Server (Cursor / Windsurf / Cline / Trae):**
```powershell
# 1. Copy mcp/ folder to ~/.mcp/dws/
# 2. cd ~/.mcp/dws && npm install
# 3. Add to each platform's mcp.json:
{
  "mcpServers": {
    "dws": {
      "command": "node",
      "args": ["C:/Users/<username>/.mcp/dws/server.js"]
    }
  }
}
```

MCP config file locations:

| Platform | Config File Path |
|---|---|
| Cursor (global) | `%USERPROFILE%\.cursor\mcp.json` |
| Windsurf | `%USERPROFILE%\.codeium\windsurf\mcp_config.json` |
| Cline | `%APPDATA%\Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json` |
| Trae (project) | `.trae\mcp.json` |

**Trae (skill file):** Copy `adapters/trae/dws.md` → `%USERPROFILE%\.trae\skills\dws.md`

**Codex CLI:** Append content of `adapters/codex/AGENTS.md` to `%USERPROFILE%\.codex\AGENTS.md`

**OpenClaw / WorkBuddy:** Import `adapters/openclaw/dws.md` via the app's GUI

</details>
