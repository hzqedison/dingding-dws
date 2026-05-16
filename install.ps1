# dws-skill 安装脚本 for Claude Code & 多平台 AI Agent
# 用法: irm https://raw.githubusercontent.com/hzqedison/dingding-dws/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$repo    = "hzqedison/dingding-dws"
$zipUrl  = "https://github.com/$repo/archive/refs/heads/main.zip"
$zipPath = Join-Path $env:TEMP "dws-skill.zip"
$tmpDir  = Join-Path $env:TEMP "dws-skill-install"

Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        dws-skill — DingTalk for AI Agents     ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── 下载 ─────────────────────────────────────────────────────────────────────
Write-Host ">>> 下载中 ..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
} catch {
    Write-Host "❌ 下载失败，请检查网络连接" -ForegroundColor Red
    exit 1
}

# ── 解压 ─────────────────────────────────────────────────────────────────────
if (Test-Path $tmpDir) { Remove-Item $tmpDir -Recurse -Force }
Expand-Archive -Path $zipPath -DestinationPath $tmpDir -Force
$src = Join-Path $tmpDir "dingding-dws-main"

# ─────────────────────────────────────────────────────────────────────────────
# 函数：安装 Claude Code skill
# ─────────────────────────────────────────────────────────────────────────────
function Install-ClaudeCode {
    $skillDir   = Join-Path $env:USERPROFILE ".claude\skills"
    $commandDir = Join-Path $env:USERPROFILE ".claude\commands"
    foreach ($d in @($skillDir, $commandDir)) {
        if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    }
    foreach ($t in @("dws.md", "dws-refs", "dws-scripts")) {
        $dst = Join-Path $skillDir $t
        if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
        Copy-Item (Join-Path $src "skills\$t") $dst -Recurse -Force
    }
    $dst = Join-Path $commandDir "dws.md"
    if (Test-Path $dst) { Remove-Item $dst -Force }
    Copy-Item (Join-Path $src "commands\dws.md") $dst -Force
    Write-Host "  ✓ Claude Code skill 安装完成 → $skillDir" -ForegroundColor Green
}

# ─────────────────────────────────────────────────────────────────────────────
# 函数：安装 MCP Server（适用于 Cursor / Windsurf / Cline / Trae / Codex）
# ─────────────────────────────────────────────────────────────────────────────
function Install-McpServer {
    # 检查 Node.js
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Host "  ⚠ 未检测到 Node.js，跳过 MCP Server 安装。" -ForegroundColor Yellow
        Write-Host "    安装 Node.js 后可手动运行：" -ForegroundColor Yellow
        Write-Host "    cd $env:USERPROFILE\.mcp\dws && npm install" -ForegroundColor Gray
        return $false
    }
    $mcpDir = Join-Path $env:USERPROFILE ".mcp\dws"
    if (-not (Test-Path $mcpDir)) { New-Item -ItemType Directory -Path $mcpDir -Force | Out-Null }
    Copy-Item (Join-Path $src "mcp\server.js")    (Join-Path $mcpDir "server.js")    -Force
    Copy-Item (Join-Path $src "mcp\package.json") (Join-Path $mcpDir "package.json") -Force
    Write-Host "  >>> npm install ..." -ForegroundColor Yellow
    Push-Location $mcpDir
    npm install --silent 2>&1 | Out-Null
    Pop-Location
    Write-Host "  ✓ MCP Server 安装完成 → $mcpDir" -ForegroundColor Green
    return $true
}

# ─────────────────────────────────────────────────────────────────────────────
# 函数：向指定平台注入 MCP 配置
# ─────────────────────────────────────────────────────────────────────────────
function Inject-McpConfig($configPath, $serverPath) {
    $entry = @{
        command = "node"
        args    = @($serverPath)
    }
    if (Test-Path $configPath) {
        $cfg = Get-Content $configPath -Raw | ConvertFrom-Json
    } else {
        New-Item -ItemType Directory -Path (Split-Path $configPath) -Force | Out-Null
        $cfg = [PSCustomObject]@{ mcpServers = [PSCustomObject]@{} }
    }
    if (-not $cfg.mcpServers) {
        $cfg | Add-Member -MemberType NoteProperty -Name mcpServers -Value ([PSCustomObject]@{})
    }
    $cfg.mcpServers | Add-Member -MemberType NoteProperty -Name "dws" -Value $entry -Force
    $cfg | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding utf8
    Write-Host "    → MCP 已注入: $configPath" -ForegroundColor Gray
}

# ─────────────────────────────────────────────────────────────────────────────
# 函数：安装 native adapter（规则/skill 文件，MCP 的 fallback）
# ─────────────────────────────────────────────────────────────────────────────
function Install-Adapter($platform, $targetPath, $srcFile) {
    $dir = Split-Path $targetPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Copy-Item (Join-Path $src "adapters\$platform\$srcFile") $targetPath -Force
    Write-Host "    → adapter 已安装: $targetPath" -ForegroundColor Gray
}

# ─────────────────────────────────────────────────────────────────────────────
# 交互：选择安装目标
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "请选择要安装的平台（多选用逗号分隔，直接回车 = 全部安装）：" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [1] Claude Code      (~/.claude/skills/)"
Write-Host "  [2] Cursor           (~/.cursor/mcp.json + .cursor/rules/)"
Write-Host "  [3] Windsurf         (~/.codeium/windsurf/mcp_config.json)"
Write-Host "  [4] Cline (VS Code)  (MCP settings + .cline/rules/)"
Write-Host "  [5] Trae             (~/.trae/skills/)"
Write-Host "  [6] OpenAI Codex CLI (~/.codex/AGENTS.md)"
Write-Host "  [7] OpenClaw         (输出到当前目录，手动导入 WorkBuddy 等)"
Write-Host ""
$choice = Read-Host "输入选项"

$all     = [string]::IsNullOrWhiteSpace($choice)
$choices = if ($all) { @("1","2","3","4","5","6","7") } else { $choice -split "[,，\s]+" | ForEach-Object { $_.Trim() } }

Write-Host ""
Write-Host ">>> 开始安装 ..." -ForegroundColor Yellow
Write-Host ""

$mcpInstalled  = $false
$mcpServerPath = (Join-Path $env:USERPROFILE ".mcp\dws\server.js").Replace("\", "/")

# ── 1. Claude Code ────────────────────────────────────────────────────────────
if ($choices -contains "1") {
    Write-Host "[ Claude Code ]" -ForegroundColor Cyan
    Install-ClaudeCode
    Write-Host ""
}

# ── 2. Cursor ─────────────────────────────────────────────────────────────────
if ($choices -contains "2") {
    Write-Host "[ Cursor ]" -ForegroundColor Cyan
    if (-not $mcpInstalled) { $mcpInstalled = Install-McpServer }
    if ($mcpInstalled) {
        Inject-McpConfig (Join-Path $env:USERPROFILE ".cursor\mcp.json") $mcpServerPath
    }
    Install-Adapter "cursor" (Join-Path $env:USERPROFILE ".cursor\rules\dws.mdc") "dws.mdc"
    Write-Host "  ✓ Cursor 安装完成" -ForegroundColor Green
    Write-Host ""
}

# ── 3. Windsurf ───────────────────────────────────────────────────────────────
if ($choices -contains "3") {
    Write-Host "[ Windsurf ]" -ForegroundColor Cyan
    if (-not $mcpInstalled) { $mcpInstalled = Install-McpServer }
    if ($mcpInstalled) {
        Inject-McpConfig (Join-Path $env:USERPROFILE ".codeium\windsurf\mcp_config.json") $mcpServerPath
    }
    Install-Adapter "windsurf" (Join-Path $env:USERPROFILE ".codeium\windsurf\rules\dws.md") "dws.md"
    Write-Host "  ✓ Windsurf 安装完成" -ForegroundColor Green
    Write-Host ""
}

# ── 4. Cline ──────────────────────────────────────────────────────────────────
if ($choices -contains "4") {
    Write-Host "[ Cline ]" -ForegroundColor Cyan
    if (-not $mcpInstalled) { $mcpInstalled = Install-McpServer }
    if ($mcpInstalled) {
        $clineMcpPath = Join-Path $env:APPDATA "Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json"
        Inject-McpConfig $clineMcpPath $mcpServerPath
    }
    Install-Adapter "cline" (Join-Path $env:USERPROFILE ".cline\rules\dws.md") "dws.md"
    Write-Host "  ✓ Cline 安装完成（重启 VS Code 生效）" -ForegroundColor Green
    Write-Host ""
}

# ── 5. Trae ───────────────────────────────────────────────────────────────────
if ($choices -contains "5") {
    Write-Host "[ Trae ]" -ForegroundColor Cyan
    Install-Adapter "trae" (Join-Path $env:USERPROFILE ".trae\skills\dws.md") "dws.md"
    Write-Host "  ✓ Trae skill 安装完成 → $env:USERPROFILE\.trae\skills\dws.md" -ForegroundColor Green
    Write-Host ""
}

# ── 6. OpenAI Codex CLI ───────────────────────────────────────────────────────
if ($choices -contains "6") {
    Write-Host "[ OpenAI Codex CLI ]" -ForegroundColor Cyan
    $codexAgents = Join-Path $env:USERPROFILE ".codex\AGENTS.md"
    $codexDir    = Split-Path $codexAgents
    if (-not (Test-Path $codexDir)) { New-Item -ItemType Directory -Path $codexDir -Force | Out-Null }
    $adapterContent = Get-Content (Join-Path $src "adapters\codex\AGENTS.md") -Raw
    if (Test-Path $codexAgents) {
        # 追加到已有 AGENTS.md，避免覆盖用户内容
        Add-Content $codexAgents "`n`n$adapterContent" -Encoding utf8
        Write-Host "    → 已追加到已有 AGENTS.md: $codexAgents" -ForegroundColor Gray
    } else {
        Set-Content $codexAgents $adapterContent -Encoding utf8
        Write-Host "    → 已创建: $codexAgents" -ForegroundColor Gray
    }
    if ($mcpInstalled) {
        # Codex MCP via config.toml
        $codexCfg = Join-Path $env:USERPROFILE ".codex\config.toml"
        if (-not (Test-Path $codexCfg)) {
            Set-Content $codexCfg @"
[mcpServers.dws]
command = "node"
args    = ["$($mcpServerPath.Replace('/', '\\'))"]
"@ -Encoding utf8
            Write-Host "    → MCP 已写入: $codexCfg" -ForegroundColor Gray
        } else {
            Write-Host "    ⚠ $codexCfg 已存在，请手动添加 MCP 配置（见 README）" -ForegroundColor Yellow
        }
    }
    Write-Host "  ✓ Codex CLI 安装完成" -ForegroundColor Green
    Write-Host ""
}

# ── 7. OpenClaw ───────────────────────────────────────────────────────────────
if ($choices -contains "7") {
    Write-Host "[ OpenClaw / WorkBuddy ]" -ForegroundColor Cyan
    $outPath = Join-Path (Get-Location) "dws-openclaw.md"
    Copy-Item (Join-Path $src "adapters\openclaw\dws.md") $outPath -Force
    Write-Host "  ✓ OpenClaw skill 已输出 → $outPath" -ForegroundColor Green
    Write-Host "    在 WorkBuddy 等支持 OpenClaw 的应用中导入此文件即可。" -ForegroundColor Gray
    Write-Host ""
}

# ── 清理 ─────────────────────────────────────────────────────────────────────
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue

# ── 完成提示 ──────────────────────────────────────────────────────────────────
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              安装完成！                       ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "前置条件：确保 Wukong（悟空）桌面端已启动并登录" -ForegroundColor Yellow
Write-Host "下载地址：https://wukong.dingtalk.com" -ForegroundColor Yellow
Write-Host ""
Write-Host "使用方式："
Write-Host "  · Claude Code：直接描述钉钉任务，或输入 /dws <任务>"
Write-Host "  · Cursor / Windsurf / Cline / Trae：配置 MCP 后直接对话"
Write-Host "  · Codex CLI：在项目或全局 AGENTS.md 中已写入指令"
Write-Host "  · OpenClaw / WorkBuddy：导入 dws-openclaw.md 文件"
Write-Host ""
