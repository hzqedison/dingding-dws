<h1 align="center">dingding-dws</h1>

<p align="center">
  <b>让 AI Agent 直接操作钉钉的开源工具集 · DingTalk MCP Server & Skills for AI Agents</b><br/>
  <i>Claude · Cursor · Windsurf · Cline · Trae · Codex · WorkBuddy · OpenClaw</i>
</p>

<p align="center">
  <a href="https://github.com/hzqedison/dingding-dws/stargazers"><img src="https://img.shields.io/github/stars/hzqedison/dingding-dws?style=flat-square&logo=github" alt="GitHub stars"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg?style=flat-square" alt="License: MIT"></a>
  <a href="THIRD_PARTY_NOTICES.md"><img src="https://img.shields.io/badge/3rd--party-notice-yellow?style=flat-square" alt="Third-party notice"></a>
  <a href="https://wukong.dingtalk.com"><img src="https://img.shields.io/badge/Wukong-required-blue?style=flat-square" alt="Wukong required"></a>
  <a href="https://modelcontextprotocol.io"><img src="https://img.shields.io/badge/MCP-compatible-orange?style=flat-square" alt="MCP"></a>
  <img src="https://img.shields.io/badge/platform-Windows-lightgrey?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/Node.js-%E2%89%A518-339933?style=flat-square&logo=node.js" alt="Node.js">
</p>

<p align="center">
  <a href="#-中文">🇨🇳 中文</a> · <a href="#-english">🇬🇧 English</a> · <a href="#-faq">FAQ</a> · <a href="#-应用场景--use-cases">场景</a>
</p>

---

## 🇨🇳 中文

> **一句话介绍**：dingding-dws 是一个开源的钉钉 AI 中间层，让 **Claude Code、Cursor、Windsurf、Cline、Trae、OpenAI Codex、WorkBuddy** 等主流 AI Agent 通过自然语言直接操作钉钉，实现**钉钉文档读写、群消息收发、日程管理、OA 审批、待办管理、通讯录查询、考勤打卡、AI 听记**等全产品自动化。

### 📖 目录

- [它能解决什么问题](#-它能解决什么问题)
- [支持的 AI Agent 平台](#-支持的-ai-agent-平台)
- [应用场景 / Use Cases](#-应用场景--use-cases)
- [快速开始](#-快速开始)
- [使用示例](#-使用示例)
- [能力矩阵](#-能力矩阵)
- [工作原理](#-工作原理)
- [对比：为什么不直接用钉钉开放平台 API](#-对比为什么不直接用钉钉开放平台-api)
- [手动安装](#-手动安装)
- [FAQ](#-faq)

### 🎯 它能解决什么问题

如果你正在使用 AI 编程助手或 AI 工作助手，但每次涉及钉钉的操作都要：
- 切回钉钉客户端手动操作 ❌
- 调用钉钉开放平台 API（要申请企业内部应用、配置权限、维护 access_token） ❌
- 写脚本 → 调试鉴权 → 处理 token 过期 → 重试 ❌

**dingding-dws 让你在 AI 对话框里一句话搞定**：

```
帮我把这个 PRD 文档（钉钉文档链接）整理成周报发到「产品组」群
查一下本周技术部所有人的考勤异常，生成报表写到钉钉文档里
把 GitHub 上这个 PR 的 review 结果同步到钉钉待办，分配给张三
```

**核心优势：**
- ✅ **零鉴权配置** — 复用 Wukong 桌面端的登录态，不需要企业 AppKey / AppSecret
- ✅ **个人即可用** — 不需要管理员审批，普通员工就能用
- ✅ **能力全覆盖** — 文档、消息、日程、审批、待办、通讯录、考勤、邮件、AI 听记、钉盘、AI 表格…
- ✅ **多 Agent 通吃** — 一次安装，Claude / Cursor / Windsurf / Cline / Trae / Codex 全支持
- ✅ **MCP 标准协议** — 基于 Model Context Protocol，未来兼容更多 AI 客户端

### 🤖 支持的 AI Agent 平台

| 平台 | 类型 | 接入方式 | 状态 |
|---|---|---|---|
| **[Claude Code](https://claude.com/claude-code)** | Anthropic CLI 编程助手 | Skill 文件 + `/dws` 命令 | ✅ |
| **[Cursor](https://cursor.com)** | AI IDE | MCP Server + `.cursor/rules` | ✅ |
| **[Windsurf](https://windsurf.com)** | Codeium AI IDE | MCP Server + `.windsurf/rules` | ✅ |
| **[Cline](https://cline.bot)** | VS Code 开源 AI 扩展 | MCP Server + `.cline/rules` | ✅ |
| **[Trae](https://trae.ai)** | 字节跳动 AI IDE | Skill 文件 + MCP | ✅ |
| **[OpenAI Codex CLI](https://developers.openai.com/codex)** | OpenAI 官方 CLI | `~/.codex/AGENTS.md` + MCP | ✅ |
| **[WorkBuddy](https://news.aibase.com/news/26048)** | 腾讯 AI 工作助手 | OpenClaw skill 导入 | ✅ |
| **[OpenClaw](https://github.com/OpenClaw)** | 开源 Agent 框架 | 原生 skill 格式 | ✅ |
| 其他 MCP 客户端 | 任何支持 MCP 的工具 | MCP Server | ✅ |

### 💼 应用场景 / Use Cases

> 覆盖典型岗位与业务流程，关键词命中：钉钉自动化、钉钉机器人、钉钉智能助手、AI 办公、AI Agent 钉钉、企业 AI、SaaS 自动化、办公自动化、RPA 替代。

#### 👨‍💻 研发场景

- **CI/CD 通知机器人**：构建失败时自动发钉钉群 + 创建待办给值班同学
- **代码评审提醒**：未处理 PR 超 24 小时自动 DING 提醒
- **bug 流转**：Jira/GitHub Issue 同步到钉钉待办，钉钉里更新状态回流
- **技术文档同步**：把 Markdown 文档批量同步到钉钉知识库
- **晨会自动主持**：扫描昨日 commit + 今日日程，生成站会议程发群里

#### 👔 项目经理 / PMO

- **日报周报自动化**：扫描本周日程 + Jira 任务 + Git commit，一键生成周报写入钉钉日志
- **会议纪要二次加工**：读取 AI 听记摘要，提炼 action items 创建为待办分配给责任人
- **项目状态汇报**：定时抓取多个项目群消息 + OA 审批进度，生成日报
- **风险预警**：扫描所有项目待办，超期任务自动 DING 项目经理

#### 🧑‍💼 HR / 行政

- **考勤异常处理**：每天扫描全员打卡，异常情况发提醒并创建审批
- **请假审批批处理**：批量审批合规请假申请，复杂的转人工
- **入离职流程**：新员工自动建群、加入相关知识库、发欢迎消息
- **会议室管理**：自动预订、冲突检测、空闲查询
- **生日 / 入职周年祝福**：从通讯录抓取信息，定时发祝福消息

#### 💰 销售 / 客户成功

- **CRM 同步**：客户跟进记录从 CRM 同步到钉钉群 / 待办
- **客户分级提醒**：高价值客户消息自动 DING
- **报价单生成**：从 AI 表格读数据，生成钉钉文档报价单
- **销售周会准备**：自动汇总本周成单、漏斗变化，写入钉钉日志

#### 📊 财务 / 法务

- **报销审批助手**：扫描发票图片 → 校验金额 → 提交审批 → 跟踪状态
- **合同流转**：合同文档自动归档到知识库，关键节点提醒
- **预算监控**：超预算项目自动 DING 财务负责人
- **月度对账**：从钉盘读取对账单 → AI 比对 → 异常清单发钉钉

#### 🎓 客服 / 运营

- **客户群自动回复**：客户提问 → AI 查知识库 → 钉钉回复
- **舆情监控**：扫描所有客户群关键词，异常自动 DING
- **活动通知**：批量发送活动通知到指定群组
- **数据日报**：每天定时把运营数据写入钉钉文档 + 关键指标发群

#### 🏫 教育 / 校园（钉钉教育版）

- **班级群管理**：作业批量发布、家长通知、考勤异常
- **教研协作**：教学资料同步到知识库
- **家校沟通**：成绩单生成 + 推送

#### ⚡ 个人效率

- **「问钉钉」**：自然语言查任何信息——"上周三那个会议聊了啥？"、"小王手机号多少？"
- **跨平台搬运**：飞书 / Notion 内容 → 钉钉文档；钉钉消息 → Obsidian
- **日程聚合**：把 Google Calendar / Outlook 日程合并到钉钉日历
- **稍后处理**：群里 @我 的消息超 2 小时未处理 → 自动创建待办

### 🚀 快速开始

#### 前置条件

1. **Windows 系统**（当前仅支持 Windows，Mac/Linux 在规划中）
2. **[Wukong（悟空）桌面端](https://wukong.dingtalk.com)** 已安装并登录钉钉
3. **Node.js ≥ 18**（仅 MCP 安装路径需要，Claude Code skill 文件路径无需）

#### 一键安装

在 PowerShell 中运行：

```powershell
irm https://raw.githubusercontent.com/hzqedison/dingding-dws/main/install.ps1 | iex
```

脚本会交互式询问要安装到哪些平台，按需选择即可：

```
[1] Claude Code      (~/.claude/skills/)
[2] Cursor           (~/.cursor/mcp.json + .cursor/rules/)
[3] Windsurf         (~/.codeium/windsurf/mcp_config.json)
[4] Cline (VS Code)  (MCP settings + .cline/rules/)
[5] Trae             (~/.trae/skills/)
[6] OpenAI Codex CLI (~/.codex/AGENTS.md)
[7] OpenClaw / WorkBuddy
```

直接回车 = 全部安装。

### 💬 使用示例

#### 文档处理

```
读取这个钉钉文档 https://alidocs.dingtalk.com/i/nodes/xxx，总结要点写到一个新文档里
把本周所有的会议纪要合并成一份月度回顾文档
在「产品需求」知识库里搜索包含「v3.0」的所有文档
```

#### 消息 / 群管理

```
给「研发周会」群发条消息：明天 10 点改到下午 3 点
把张三、李四拉进「项目 X」群，并发欢迎消息
查一下「客户对接」群最近 50 条消息，提炼出客户的核心诉求
通过 Webhook 发个机器人消息到「告警群」
```

#### 日程 / 会议

```
查我下周一到周三的日程，找一个 1 小时的空闲时间约和张三的会
预订明天下午 2-4 点 8 楼会议室
查所有部门负责人下周的闲忙状态
```

#### OA 审批 / 待办

```
列出我所有待审批的报销单，按金额排序
帮我审批所有 500 元以下的差旅报销
给我所有未完成的待办按截止时间排序
把这条消息变成一个待办：周五前完成 Q4 OKR
```

#### 考勤 / HR

```
查本月技术部所有人的迟到记录
查我自己上个月的考勤详情，生成日历视图
扫描本周全员未打卡情况，生成异常列表发给 HR
```

#### 通讯录

```
查张三的手机号和工号
列出技术部所有人和他们的直属上级
找出负责「支付系统」的人是谁
```

#### Claude Code 专属：斜杠命令

```
/dws 把这个文档翻译成英文写到新文档里
/dws 查我本周的所有日程发到日记里
```

### 🔧 能力矩阵

| 产品 | 关键能力 | 关键词 |
|---|---|---|
| 钉钉文档 | 读 / 写 / 搜 / 知识库 / 文件夹管理 | DingTalk Doc, 钉钉文档 API |
| 群聊 / 单聊 | 发消息 / 建群 / 拉人 / Webhook / 撤回 / 群机器人 | DingTalk Group, 钉钉机器人 |
| 日历 | 查日程 / 约会议 / 订会议室 / 闲忙查询 | DingTalk Calendar |
| 通讯录 | 搜同事 / 查部门 / 找上下级 / 工号手机号 | DingTalk Contact |
| 待办 TODO | 创建 / 查询 / 完成 / 分配 / 提醒 | DingTalk Todo |
| 邮件 | 发邮件 / 查收件箱 / 抄送 | DingTalk Mail |
| OA 审批 | 查待审 / 同意 / 拒绝 / 流程查询 | DingTalk OA Approval |
| AI 表格 | 多维表 / 字段 / 记录 / 视图 | DingTalk AI Table |
| 电子表格 | 单元格 / 公式 / Sheet / 导出 | DingTalk Sheet |
| 考勤 | 打卡记录 / 排班 / 加班 / 异常 | DingTalk Attendance |
| AI 听记 | 会议录音 / 摘要 / 转写 / 关键词 | DingTalk Minutes |
| 日志 | 日报 / 周报 / 模板 / 收件箱 | DingTalk Report |
| 钉盘 | 上传 / 下载 / 浏览 / 文件夹 | DingTalk Drive |
| 知识库 | Wiki / 空间 / 权限 | DingTalk Wiki |
| DING 消息 | 紧急通知 / 电话 DING / 短信 DING | DingTalk DING |
| 视频会议 | 预约 / 加入 / 录制 | DingTalk Meeting |
| AI 应用 | 创建应用 / 智能助手 / 工作流 | DingTalk AI App |

### 🏗 工作原理

```
   ┌─────────────────────────────────────────────────┐
   │                  AI Agent 层                     │
   │  Claude · Cursor · Windsurf · Cline · Trae ...   │
   └──────────────────────┬──────────────────────────┘
                          │ 自然语言任务
            ┌─────────────┴─────────────┐
            ▼                           ▼
   ┌─────────────────┐       ┌──────────────────┐
   │   MCP Server    │       │   Skill 文件     │
   │   (Node.js)     │       │   (Markdown)     │
   └────────┬────────┘       └────────┬─────────┘
            │                         │
            └──────────┬──────────────┘
                       ▼
            ┌──────────────────────┐
            │     wukong-cli       │
            └──────────┬───────────┘
                       │ \\.\pipe\real-daemon
                       ▼
            ┌──────────────────────┐
            │    Wukong 守护进程   │  ← 桌面端管理认证
            └──────────┬───────────┘
                       ▼
            ┌──────────────────────┐
            │      钉钉 API        │
            └──────────────────────┘
```

**鉴权说明**：dingding-dws 不直接调用钉钉开放平台 API，而是通过 Wukong 桌面端的守护进程间接调用。这意味着：
- 你登录的是个人钉钉账号（不需要企业 AppKey）
- 权限范围 = 你账号能看到的范围
- 不需要管理员审批，普通员工就能用
- 适合**个人效率工具**，不适合做对外服务的 SaaS

### ⚖ 对比：为什么不直接用钉钉开放平台 API

| 方案 | dingding-dws | 钉钉开放平台 API | 自己写 RPA |
|---|---|---|---|
| 启动门槛 | 装 Wukong 客户端即可 | 申请企业内部应用、配置权限、IT 审批 | 录脚本、维护选择器 |
| 鉴权 | 复用桌面端登录 | 维护 AppKey + access_token + 刷新逻辑 | Cookie / 模拟登录 |
| 权限范围 | = 你的个人账号 | 应用授权范围 | 完全依赖账号 |
| 能力覆盖 | 全产品（含 AI 听记/AI 表格等新功能） | 仅开放部分 API | 不稳定，UI 改就崩 |
| 多 AI Agent | ✅ 一份安装跨平台 | ❌ 每个客户端单独适配 | ❌ |
| 适用场景 | 个人 / 团队效率工具 | 企业级 SaaS | 不推荐 |

### 📦 手动安装

<details>
<summary>展开手动安装说明</summary>

#### Claude Code

```
~/.claude/
├── skills/
│   ├── dws.md
│   ├── dws-refs/
│   └── dws-scripts/
└── commands/
    └── dws.md
```

#### MCP Server（Cursor / Windsurf / Cline / Trae / Codex 通用）

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

#### 各平台 MCP 配置文件路径

| 平台 | 配置文件 |
|---|---|
| Cursor（全局） | `%USERPROFILE%\.cursor\mcp.json` |
| Cursor（项目） | `<项目根>\.cursor\mcp.json` |
| Windsurf | `%USERPROFILE%\.codeium\windsurf\mcp_config.json` |
| Cline (VS Code) | `%APPDATA%\Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json` |
| Trae（项目级） | `<项目根>\.trae\mcp.json` |
| Codex CLI | `%USERPROFILE%\.codex\config.toml`（`[mcpServers.dws]` 段） |

#### Trae（skill 文件方式）

复制 `adapters/trae/dws.md` → `%USERPROFILE%\.trae\skills\dws.md`

#### Codex CLI（AGENTS.md 方式）

把 `adapters/codex/AGENTS.md` 内容追加到 `%USERPROFILE%\.codex\AGENTS.md`

#### OpenClaw / WorkBuddy

在 WorkBuddy 等支持 OpenClaw skill 的应用界面中导入 `adapters/openclaw/dws.md`

</details>

### ❓ FAQ

<details>
<summary><b>Q: 这是钉钉官方的吗？</b></summary>
不是。这是一个非官方开源项目，基于钉钉官方的 Wukong（悟空）桌面端的本地能力做的二次封装，让 AI Agent 能用自然语言调用钉钉。
</details>

<details>
<summary><b>Q: 为什么必须装 Wukong？能不能直接用 access_token？</b></summary>
Wukong 守护进程负责钉钉登录态管理，相当于复用了你已有的钉钉账号。如果你想用 access_token 模式，需要自己改造 MCP server 改成直接调用钉钉开放平台 API（要先在钉钉后台申请企业内部应用）。
</details>

<details>
<summary><b>Q: 支持 Mac / Linux 吗？</b></summary>
当前仅 Windows，因为 Wukong 桌面端主要支持 Windows。Mac 版本在规划中。
</details>

<details>
<summary><b>Q: 数据安全吗？AI 会读到我的钉钉消息吗？</b></summary>
所有操作都在你本机执行，数据不会离开你的电脑。AI 只读到你明确让它读的内容（比如「读这条消息」）。LLM 通过 MCP 拿到的也只是任务结果文本。
</details>

<details>
<summary><b>Q: 跟钉钉机器人（Webhook）有什么区别？</b></summary>
钉钉 Webhook 机器人只能<b>发消息</b>，且需要群管理员配置。dingding-dws 是<b>全产品操作能力</b>，能读、能写、能审批、能管文件，且基于个人账号，无需管理员。
</details>

<details>
<summary><b>Q: 跟 n8n / Zapier / 自建 RPA 比有什么优势？</b></summary>
n8n/Zapier 用的是钉钉开放平台 API，需要企业账号 + AppKey 配置；RPA 通过 UI 模拟操作，UI 改了就崩。dingding-dws 用的是 Wukong 守护进程的<b>内部协议</b>，覆盖更广、更稳定。
</details>

<details>
<summary><b>Q: Claude Code 用户该选 skill 文件还是 MCP？</b></summary>
推荐 skill 文件方式（默认安装就是）。Claude Code 的 skill 系统比 MCP 更适合「按需触发 + 自然语言路由」场景。MCP 适合 Cursor/Windsurf 这类 IDE。
</details>

<details>
<summary><b>Q: 公司禁止安装非白名单软件，能用吗？</b></summary>
不能。Wukong 桌面端是必需的。建议你先向 IT 申请加白名单。
</details>

<details>
<summary><b>Q: 能让团队所有人都用上吗？</b></summary>
可以。每个人各自装 Wukong + dingding-dws 即可，AI 操作都用各自账号身份。
</details>

### 🛠 贡献 / 反馈

欢迎提 Issue / PR：[github.com/hzqedison/dingding-dws/issues](https://github.com/hzqedison/dingding-dws/issues)

如果这个项目对你有帮助，**点个 ⭐ Star 支持一下！**

---

## 🇬🇧 English

> **TL;DR**: dingding-dws is an open-source DingTalk AI middleware that lets **Claude Code, Cursor, Windsurf, Cline, Trae, OpenAI Codex, WorkBuddy** and other mainstream AI agents operate DingTalk through natural language — **read/write documents, send/receive messages, manage calendar, handle OA approvals, manage todos, query directory, check attendance, AI meeting minutes**, and the full DingTalk product line.

### 📖 Table of Contents

- [Why dingding-dws](#-why-dingding-dws)
- [Supported AI Agent Platforms](#-supported-ai-agent-platforms)
- [Use Cases](#-use-cases)
- [Quick Start](#-quick-start)
- [Usage Examples](#-usage-examples)
- [Capability Matrix](#-capability-matrix)
- [How It Works](#-how-it-works)
- [Comparison vs DingTalk Open API](#-comparison-vs-dingtalk-open-api)
- [Manual Install](#-manual-install)
- [FAQ (English)](#-faq-english)

### 🎯 Why dingding-dws

If you're using an AI coding assistant or AI work assistant, but every DingTalk task requires:
- Switching back to the DingTalk app and clicking around ❌
- Setting up DingTalk Open Platform API (internal app, scopes, access_token rotation) ❌
- Writing one-off scripts that break on auth changes ❌

**dingding-dws lets you do it in one line of natural language:**

```
Turn this PRD doc (DingTalk link) into a weekly report and post it to the "Product" group
Find all attendance anomalies in the tech team this week and write a report to a DingTalk doc
Sync this GitHub PR review to a DingTalk todo and assign it to Zhang San
```

**Core advantages:**
- ✅ **Zero auth setup** — reuses Wukong desktop login, no AppKey/AppSecret
- ✅ **Personal account** — no admin approval required
- ✅ **Full product coverage** — docs, messages, calendar, approvals, todos, contacts, attendance, mail, AI minutes, drive, AI tables…
- ✅ **Multi-agent** — install once, works across Claude / Cursor / Windsurf / Cline / Trae / Codex
- ✅ **MCP standard** — built on Model Context Protocol, future-proof

### 🤖 Supported AI Agent Platforms

| Platform | Type | Integration | Status |
|---|---|---|---|
| **[Claude Code](https://claude.com/claude-code)** | Anthropic CLI coder | Skill file + `/dws` command | ✅ |
| **[Cursor](https://cursor.com)** | AI IDE | MCP Server + `.cursor/rules` | ✅ |
| **[Windsurf](https://windsurf.com)** | Codeium AI IDE | MCP Server + `.windsurf/rules` | ✅ |
| **[Cline](https://cline.bot)** | Open-source VS Code AI | MCP Server + `.cline/rules` | ✅ |
| **[Trae](https://trae.ai)** | ByteDance AI IDE | Skill file + MCP | ✅ |
| **[OpenAI Codex CLI](https://developers.openai.com/codex)** | OpenAI CLI | `~/.codex/AGENTS.md` + MCP | ✅ |
| **[WorkBuddy](https://news.aibase.com/news/26048)** | Tencent AI work assistant | OpenClaw skill import | ✅ |
| **[OpenClaw](https://github.com/OpenClaw)** | Open agent framework | Native skill format | ✅ |
| Any MCP client | Any MCP-compatible tool | MCP Server | ✅ |

### 💼 Use Cases

> Keywords: DingTalk automation, DingTalk bot, DingTalk AI assistant, AI office automation, enterprise AI agent, SaaS automation, RPA alternative.

#### 👨‍💻 Engineering

- **CI/CD notifications**: build failures → DingTalk group + create todo for on-call
- **PR review reminders**: unhandled PRs > 24h → DING the assignee
- **Bug triage**: sync Jira/GitHub issues to DingTalk todos
- **Docs sync**: batch sync Markdown to DingTalk knowledge base
- **Auto standup**: scan yesterday's commits + today's calendar, generate standup agenda

#### 👔 Project Management

- **Auto weekly reports**: aggregate calendar + Jira + Git commits → write to DingTalk Reports
- **Meeting follow-ups**: parse AI Minutes summaries → extract action items → create todos
- **Status rollups**: scan multiple project chats + OA approvals → daily digest
- **Risk alerts**: scan all todos, overdue ones auto-DING the PM

#### 🧑‍💼 HR / Admin

- **Attendance anomalies**: daily scan, irregularities → reminders + approval drafts
- **Leave approval batching**: auto-approve compliant requests, escalate the rest
- **Onboarding/offboarding**: new hire → create groups, add to wikis, send welcome
- **Meeting room booking**: auto-book, conflict detection, availability search
- **Birthday/anniversary**: pull from directory, schedule wishes

#### 💰 Sales / Customer Success

- **CRM sync**: customer notes from CRM → DingTalk groups/todos
- **VIP alerts**: high-value customer messages auto-DING
- **Quote generation**: read from AI Tables → generate DingTalk quote doc
- **Sales weekly prep**: auto-summarize deals + funnel changes → DingTalk Report

#### 📊 Finance / Legal

- **Expense approval**: scan receipts → validate → submit → track
- **Contract workflow**: auto-archive to knowledge base, milestone reminders
- **Budget monitoring**: over-budget items auto-DING finance
- **Monthly reconciliation**: pull statements from Drive → AI compare → exception list

#### 🎓 Customer Service / Operations

- **Auto-reply in customer groups**: question → knowledge base lookup → reply
- **Sentiment monitoring**: scan all customer groups for keywords, alerts
- **Campaign blasts**: batch notify across target groups
- **Daily metrics report**: scheduled write to DingTalk doc + KPI broadcast

#### ⚡ Personal Productivity

- **"Ask DingTalk"**: natural language queries — "What did we discuss in last Wednesday's meeting?" "What's Xiao Wang's phone number?"
- **Cross-platform sync**: Feishu/Notion → DingTalk docs; DingTalk messages → Obsidian
- **Calendar merge**: Google Calendar/Outlook → DingTalk Calendar
- **Snooze**: @mentions older than 2h → auto-create todo

### 🚀 Quick Start

#### Prerequisites

1. **Windows** (Mac/Linux planned)
2. **[Wukong desktop app](https://wukong.dingtalk.com)** installed & logged in
3. **Node.js ≥ 18** (only required for MCP install path)

#### One-Click Install

Run in PowerShell:

```powershell
irm https://raw.githubusercontent.com/hzqedison/dingding-dws/main/install.ps1 | iex
```

The script prompts you to choose which platforms to install for. Multi-select supported (e.g. `1,2,3`), or press Enter for all.

### 💬 Usage Examples

Just describe your DingTalk task in natural language — works on any installed platform:

```
Read this DingTalk doc <url>, summarize the key points to a new doc
Send the dev weekly group: tomorrow's 10am meeting moves to 3pm
Find an hour next week to meet with Zhang San
Approve all travel expense reports under $100
List all my unfinished todos sorted by due date
What's Zhang San's phone number and employee ID?
```

Claude Code also supports the `/dws` slash command for explicit triggering.

### 🔧 Capability Matrix

| Product | Capabilities | Keywords |
|---|---|---|
| Docs | Read / write / search / wiki | DingTalk Doc API |
| Chat | Send / create group / Webhook / bot | DingTalk Bot |
| Calendar | View / book / room / availability | DingTalk Calendar |
| Directory | Search / department / org chart | DingTalk Contact |
| Todos | Create / query / complete / assign | DingTalk Todo |
| Mail | Send / inbox / CC | DingTalk Mail |
| OA Approval | Pending / approve / reject | DingTalk OA |
| AI Tables | Multi-dim / fields / records | DingTalk AI Table |
| Spreadsheets | Cells / formulas / export | DingTalk Sheet |
| Attendance | Clock-in / shifts / overtime | DingTalk Attendance |
| AI Minutes | Recording / summary / transcript | DingTalk Minutes |
| Reports | Daily/weekly / templates | DingTalk Report |
| Drive | Upload / download / browse | DingTalk Drive |
| Wiki | Spaces / permissions | DingTalk Wiki |
| DING | Urgent / phone / SMS | DingTalk DING |
| Video Meeting | Schedule / join / record | DingTalk Meeting |
| AI Apps | Create / assistants / workflows | DingTalk AI App |

### 🏗 How It Works

```
   AI Agent (Claude / Cursor / Windsurf / Cline / Trae / ...)
                       ↓ natural language
       ┌───────────────┴────────────────┐
       ▼                                ▼
  MCP Server (Node.js)          Skill File (Markdown)
       └───────────────┬────────────────┘
                       ▼
                  wukong-cli
                       ↓ \\.\pipe\real-daemon
                  Wukong daemon  ← manages DingTalk login
                       ↓
                  DingTalk API
```

**Auth**: dingding-dws doesn't call DingTalk Open Platform directly. It goes through Wukong's daemon, which manages your DingTalk login session. This means:
- Personal account login (no enterprise AppKey)
- Scope = whatever your account can see
- No admin approval required
- Best for **personal/team productivity**, not for building public SaaS

### ⚖ Comparison vs DingTalk Open API

| Approach | dingding-dws | DingTalk Open API | DIY RPA |
|---|---|---|---|
| Setup | Install Wukong | Apply enterprise app, scopes, IT approval | Record scripts, maintain selectors |
| Auth | Reuse desktop login | AppKey + access_token rotation | Cookie / login simulation |
| Scope | = your account | Granted scopes only | Account-dependent |
| Coverage | Full product (incl. AI Minutes/Tables) | Limited public APIs | Fragile, breaks on UI changes |
| Multi-agent | ✅ One install everywhere | ❌ Per-client adapter | ❌ |
| Best for | Personal/team productivity | Enterprise SaaS | Not recommended |

### 📦 Manual Install

See the [Chinese manual install section](#-手动安装) above — paths and configs are identical.

### ❓ FAQ (English)

<details>
<summary><b>Q: Is this an official DingTalk product?</b></summary>
No. This is an unofficial open-source project that wraps the local capabilities of DingTalk's Wukong desktop app to expose them to AI agents.
</details>

<details>
<summary><b>Q: Why do I need Wukong? Can't I just use an access_token?</b></summary>
Wukong handles the DingTalk login session — it's the easiest way to reuse your existing account. If you prefer access_token, you'd need to fork the MCP server to call DingTalk Open API directly (which requires enterprise app setup).
</details>

<details>
<summary><b>Q: Mac / Linux support?</b></summary>
Currently Windows only, because Wukong is Windows-first. Mac version is planned.
</details>

<details>
<summary><b>Q: Is my data safe? Will the AI read my DingTalk messages?</b></summary>
All operations run locally; data never leaves your machine. The AI only sees what you explicitly ask it to read.
</details>

<details>
<summary><b>Q: How is this different from DingTalk Webhook bots?</b></summary>
Webhook bots can only <b>send</b> messages and require admin setup. dingding-dws gives you <b>full read/write/approve/manage</b> capabilities under your personal account.
</details>

<details>
<summary><b>Q: How does it compare to n8n / Zapier / DIY RPA?</b></summary>
n8n/Zapier use DingTalk Open API (enterprise setup needed); RPA simulates UI clicks (fragile). dingding-dws uses Wukong's internal protocol — broader coverage, more stable.
</details>

### 🛠 Contributing / Feedback

Issues and PRs welcome: [github.com/hzqedison/dingding-dws/issues](https://github.com/hzqedison/dingding-dws/issues)

If this project helps you, **drop a ⭐ Star!**

---

## 📄 License & Disclaimer / 许可证与免责声明

- The original code of this project (MCP server, adapters, installer, README, wrapper skill) is licensed under the **[MIT License](LICENSE)**.
  本项目原创代码（MCP server、适配器、安装脚本、README、wrapper skill）采用 **[MIT 许可证](LICENSE)** 开源。
- This repository also bundles reference materials originating from the Wukong (悟空) desktop app, which remain the property of **DingTalk / Alibaba Group**. See **[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)** for details.
  仓库内捆绑的 `skills/dws-refs/` 和 `skills/dws-scripts/` 来自钉钉 Wukong（悟空）桌面端，著作权归**阿里巴巴集团**所有，详见 **[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)**。
- **This project is unofficial and is not affiliated with, endorsed by, or sponsored by Alibaba Group, DingTalk, or the Wukong product team.** All product names and trademarks remain the property of their respective owners.
  **本项目为非官方开源工具，与阿里巴巴、钉钉、Wukong 无任何隶属、背书、赞助关系**。所有产品名与商标归各自权利人所有。

---

<p align="center">
  <sub>
    Keywords: DingTalk MCP server · 钉钉 MCP · 钉钉 AI Agent · DingTalk automation · 钉钉自动化 · DingTalk bot · 钉钉机器人 · AI office assistant · AI 办公助手 · Claude Code DingTalk · Cursor DingTalk · Windsurf DingTalk · Cline DingTalk · Trae DingTalk · Codex DingTalk · WorkBuddy DingTalk · OpenClaw DingTalk · 钉钉 API · 钉钉文档 · 钉钉审批 · 钉钉考勤 · 钉钉 AI 听记 · 钉钉智能助手 · enterprise AI · 企业 AI · RPA alternative · RPA 替代
  </sub>
</p>
