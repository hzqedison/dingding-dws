# CLAUDE.md

This file gives Claude Code instant context when working in this repo. Keep it concise — only stable, decision-shaping facts.

## 项目定位

**dingding-dws** 是一个开源工具，让主流 AI Agent（Claude Code / Cursor / Windsurf / Cline / Trae / OpenAI Codex / WorkBuddy 等）通过自然语言操作钉钉。底层走 Wukong（悟空）桌面端的守护进程做认证代理，绕开钉钉开放平台的企业 AppKey 配置门槛。

仓库地址：https://github.com/hzqedison/dingding-dws

## 仓库结构

```
dingding-dws/
├── skills/
│   ├── dws.md              ← Claude Code 主 skill 文件（我写的 wrapper）
│   ├── dws-refs/           ← 钉钉产品参考文档（© 阿里，来自 Wukong 官方 zip）
│   └── dws-scripts/        ← Python 辅助脚本（© 阿里，同上）
├── commands/
│   └── dws.md              ← Claude Code 斜杠命令（/dws）
├── mcp/
│   ├── server.js           ← MCP server，给非 Claude Code 平台用
│   └── package.json
├── adapters/               ← 各 AI 平台原生 skill/rules 格式适配
│   ├── codex/AGENTS.md     ← OpenAI Codex CLI
│   ├── cursor/dws.mdc      ← Cursor
│   ├── windsurf/dws.md     ← Windsurf
│   ├── cline/dws.md        ← Cline (VS Code)
│   ├── trae/dws.md         ← Trae (字节跳动)
│   └── openclaw/dws.md     ← OpenClaw / WorkBuddy
├── scripts/
│   └── sync-from-wukong.ps1  ← 维护者工具：从本地 Wukong 同步 refs/scripts
├── install.ps1             ← 一键安装脚本（交互式选平台）
├── LICENSE                 ← MIT（仅覆盖原创代码）
├── THIRD_PARTY_NOTICES.md  ← 第三方内容声明
└── README.md               ← 中英双语 + SEO 优化
```

## 核心架构

```
AI Agent
   │ 自然语言
   ├──→ Claude Code  →  skills/dws.md（直接读 markdown 指令）
   └──→ 其他平台      →  mcp/server.js（MCP stdio 协议）
                              │
                              ▼
                        wukong-cli.exe
                              │ \\.\pipe\real-daemon
                              ▼
                       Wukong 守护进程
                              ▼
                          钉钉 API
```

**关键事实**：dws 的认证由 Wukong 桌面端托管，外部直接调 `dws.exe` 会 `not_authenticated`。必须通过 `wukong-cli` 走管道。

## 常用工作流

### 1. Wukong 升级后同步参考文档

```powershell
.\scripts\sync-from-wukong.ps1     # 可加 -DryRun 先预览
git add skills/dws-refs skills/dws-scripts
git commit -m "chore: sync dws-refs/scripts from Wukong <版本号>"
git push
```

脚本自动：定位 Wukong 进程 → 找 `dingtalk-workspace.zip` → 解压 → 替换仓库内容 → 显示文件数 diff。

### 2. 修改 wukong-cli 定位逻辑

**注意**：定位代码在 **8 个文件** 里都有副本，要全部同步改：
- `skills/dws.md`
- `mcp/server.js`（PowerShell 嵌入在 JS 字符串里）
- `adapters/codex/AGENTS.md`
- `adapters/cursor/dws.mdc`
- `adapters/windsurf/dws.md`
- `adapters/cline/dws.md`
- `adapters/trae/dws.md`
- `adapters/openclaw/dws.md`

当前规则（必须保持）：
1. 从 `Get-Process` 抓路径含 `\\Wukong\\\d` 的进程（正则要 `\d` 兜底，避免误匹配《黑神话：悟空》）
2. `.Path` 访问要 `try/catch`（跨权限场景）
3. Walk-up 3 层找名为 `Wukong` 的目录
4. **`$foundWukongRoot` 守卫** —— 没找到不能做 `Get-ChildItem -Recurse`（否则退化到全盘扫描）
5. Fallback: PATH → 注册表

### 3. 加新平台支持

1. `adapters/<platform>/` 下加 skill/rules 文件（参考 `cursor/dws.mdc` 或 `trae/dws.md`）
2. 在 `install.ps1` 的交互菜单加一项 + 安装分支
3. README 中英文「支持的平台」表格各加一行
4. 如果该平台支持 MCP：用 `Inject-McpConfig` 复用现有 MCP server，不用重写适配

### 4. 本地调试 MCP server

```powershell
cd mcp
npm install
node server.js   # stdio MCP server，需要 MCP client 连上才能交互测试
```

## 关键约束 & 易踩坑

| 项 | 约束 |
|---|---|
| 操作系统 | **仅 Windows**（Wukong 只有 Windows 版） |
| PowerShell | 5.1+，含中文的 `.ps1` 必须存 **UTF-8 BOM**，否则中文乱码报语法错误 |
| Node.js | ≥ 18（仅 MCP 路径需要） |
| wukong-cli 调用 | 必须加 `\| Select-Object -First 20`，否则大量输出会流阻塞 |
| 输出解析 | `output_text` 是自然语言，不能当结构化 JSON parse |
| 危险操作 | 删除/DING/审批 必须先向用户确认 |
| ID 处理 | 严禁编造 UUID/用户 ID/文档 ID，先查询再操作 |
| 多 Wukong 进程 | 取第一个匹配的即可 |

## 版权姿态（策略 B）

- **我（hzqedison）原创代码** → MIT
  - `mcp/`, `adapters/`, `install.ps1`, `scripts/`, `skills/dws.md`, `commands/dws.md`, `README.md`
- **第三方内容** → © 阿里巴巴（钉钉）
  - `skills/dws-refs/`（45 个 MD）
  - `skills/dws-scripts/`（35 个 PY）
- 仓库内 `LICENSE` + `THIRD_PARTY_NOTICES.md` + README disclaimer 三层声明已就位
- 钉钉/阿里若要求下架：7 日内响应承诺已写入 NOTICE

## 已知设计决策

- **为什么选策略 B 而不是 A（运行时引用）**：用户偏好可预测的捆绑模式，手动同步成本可控
- **为什么 8 个文件各存一份定位逻辑而不抽取公共脚本**：每个平台是独立分发产物，用户不一定全装；冗余 < 引入额外文件
- **为什么 install.ps1 用 PowerShell 而不是跨平台脚本**：Wukong 只支持 Windows，单平台没必要折腾
- **为什么暴露 `dingtalk` 这一个 MCP tool 而不是细分**：钉钉子产品太多（27 个），细分会让 LLM 选择困难；交给 wukong-cli 内部路由更好

## 当前版本

- **bundled refs/scripts 来源**：Wukong 0.9.45-26051319
- **MCP SDK**：@modelcontextprotocol/sdk ^1.12.0
- **支持的平台数**：7 (Claude Code, Cursor, Windsurf, Cline, Trae, Codex CLI, OpenClaw/WorkBuddy)

## 仓库外的关联

- 工作区根目录是 `K:\AI\`（双轨：person/ 个人 GitHub，company/ 公司 Gitee）
- 本仓库属于 `K:\AI\person\` 个人项目
- 工作区有 `K:\AI\CLAUDE.md`，记录双轨工作区约定（与本文件不冲突）
