# =============================================================================
# sync-from-wukong.ps1  —  Maintainer-only helper
# =============================================================================
# 从本地 Wukong（悟空）安装目录的官方 bundled-skills zip 同步最新的
# references/ 和 scripts/ 到本仓库的 skills/dws-refs/ 和 skills/dws-scripts/。
#
# 用途：每次 Wukong 桌面端升级后跑一次，保持仓库 skill 资源与官方同步。
# 注意：这是给仓库维护者用的脚本，不参与用户安装流程。
#
# 用法：
#   pwsh scripts/sync-from-wukong.ps1            # 在仓库根目录下
#   pwsh scripts/sync-from-wukong.ps1 -DryRun    # 仅展示会做什么，不实际改文件
# =============================================================================

param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# 仓库根 = 脚本所在目录的上一级
$repoRoot = Split-Path $PSScriptRoot -Parent

Write-Host ""
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  dws-skill ↔ Wukong  同步工具（仅维护者使用）   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  仓库根: $repoRoot" -ForegroundColor Gray

# -------------------------------------------------------------------------
# 1. 定位 Wukong 安装根（复用 skill 里同款逻辑）
# -------------------------------------------------------------------------
Write-Host ">>> [1/4] 定位 Wukong 安装目录 ..." -ForegroundColor Yellow

$exe = Get-Process -ErrorAction SilentlyContinue | ForEach-Object {
    try { if ($_.Path -and $_.Path -match '\\Wukong\\\d') { $_.Path } } catch { }
} | Select-Object -First 1

if (-not $exe) {
    Write-Host "  ✗ 未检测到运行中的 Wukong 进程" -ForegroundColor Red
    Write-Host "    请先启动 Wukong 桌面端再运行本脚本" -ForegroundColor Gray
    exit 1
}

$root = $exe
$foundWukongRoot = $false
for ($i = 0; $i -lt 3; $i++) {
    $parent = Split-Path $root -Parent
    if (-not $parent -or $parent -eq $root) { break }
    $root = $parent
    if ((Split-Path $root -Leaf) -eq 'Wukong') { $foundWukongRoot = $true; break }
}
if (-not $foundWukongRoot) {
    Write-Host "  ✗ 无法回溯到 Wukong 安装根目录" -ForegroundColor Red
    Write-Host "    检测到的进程: $exe" -ForegroundColor Gray
    exit 1
}

# 当前版本号（用于 commit message 提示）
$versionDir = Split-Path $exe -Parent | Split-Path -Leaf
Write-Host "  ✓ Wukong 根目录: $root" -ForegroundColor Green
Write-Host "  ✓ 当前版本: $versionDir" -ForegroundColor Green

# -------------------------------------------------------------------------
# 2. 找官方 bundled zip
# -------------------------------------------------------------------------
Write-Host ""
Write-Host ">>> [2/4] 定位 dingtalk-workspace.zip ..." -ForegroundColor Yellow

$zip = Get-ChildItem $root -Recurse -Filter "dingtalk-workspace.zip" `
            -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $zip) {
    Write-Host "  ✗ 未在 Wukong 安装目录下找到 dingtalk-workspace.zip" -ForegroundColor Red
    Write-Host "    可能是 Wukong 版本太旧或文件结构调整了" -ForegroundColor Gray
    exit 1
}
Write-Host "  ✓ $($zip.FullName)" -ForegroundColor Green
Write-Host "    大小: $([math]::Round($zip.Length/1KB, 1)) KB" -ForegroundColor Gray
Write-Host "    修改时间: $($zip.LastWriteTime)" -ForegroundColor Gray

# -------------------------------------------------------------------------
# 3. 解压到临时目录
# -------------------------------------------------------------------------
Write-Host ""
Write-Host ">>> [3/4] 解压到临时目录 ..." -ForegroundColor Yellow

$tmp = Join-Path $env:TEMP "dws-sync-$([guid]::NewGuid().ToString('N'))"
Expand-Archive -Path $zip.FullName -DestinationPath $tmp -Force

$srcRefs    = Join-Path $tmp "references"
$srcScripts = Join-Path $tmp "scripts"
if (-not (Test-Path $srcRefs) -or -not (Test-Path $srcScripts)) {
    Write-Host "  ✗ zip 内容结构异常（缺 references/ 或 scripts/）" -ForegroundColor Red
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

$newRefsCount    = (Get-ChildItem $srcRefs -Recurse -File).Count
$newScriptsCount = (Get-ChildItem $srcScripts -Recurse -File).Count
Write-Host "  ✓ 解压完成: references=$newRefsCount 文件, scripts=$newScriptsCount 文件" -ForegroundColor Green

# 对比现有
$dstRefs    = Join-Path $repoRoot "skills\dws-refs"
$dstScripts = Join-Path $repoRoot "skills\dws-scripts"
$oldRefsCount    = if (Test-Path $dstRefs)    { (Get-ChildItem $dstRefs    -Recurse -File).Count } else { 0 }
$oldScriptsCount = if (Test-Path $dstScripts) { (Get-ChildItem $dstScripts -Recurse -File).Count } else { 0 }

Write-Host ""
Write-Host "  对比：" -ForegroundColor Cyan
Write-Host "    refs:    $oldRefsCount → $newRefsCount  ($(($newRefsCount-$oldRefsCount).ToString('+#;-#;0')))" -ForegroundColor Cyan
Write-Host "    scripts: $oldScriptsCount → $newScriptsCount  ($(($newScriptsCount-$oldScriptsCount).ToString('+#;-#;0')))" -ForegroundColor Cyan

# -------------------------------------------------------------------------
# 4. 执行替换（或 dry-run）
# -------------------------------------------------------------------------
Write-Host ""
if ($DryRun) {
    Write-Host ">>> [4/4] DRY-RUN 模式，未实际修改文件" -ForegroundColor Yellow
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  去掉 -DryRun 参数再运行即可执行实际同步。" -ForegroundColor Gray
    exit 0
}

Write-Host ">>> [4/4] 替换 skills/dws-refs/ 和 skills/dws-scripts/ ..." -ForegroundColor Yellow

if (Test-Path $dstRefs)    { Remove-Item $dstRefs    -Recurse -Force }
if (Test-Path $dstScripts) { Remove-Item $dstScripts -Recurse -Force }
Copy-Item $srcRefs    $dstRefs    -Recurse -Force
Copy-Item $srcScripts $dstScripts -Recurse -Force
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "  ✓ 同步完成" -ForegroundColor Green

# -------------------------------------------------------------------------
# 完成提示
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                  同步完成                       ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "建议的 git commit 命令：" -ForegroundColor Cyan
Write-Host "  cd $repoRoot" -ForegroundColor Gray
Write-Host "  git add skills/dws-refs skills/dws-scripts" -ForegroundColor Gray
Write-Host "  git commit -m `"chore: sync dws-refs/scripts from Wukong $versionDir`"" -ForegroundColor Gray
Write-Host "  git push" -ForegroundColor Gray
Write-Host ""
