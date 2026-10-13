# Pawstash 简体中文语言包 —— 一键安装（Windows PowerShell）
# 用法:  pwsh -File install-zh.ps1 [-Repo <仓库路径>]
param(
    [string]$Repo = "."
)

$ErrorActionPreference = "Stop"
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Repo = (Resolve-Path $Repo).Path
Set-Location $Repo

if (-not (Test-Path "package.json")) { throw "错误: $Repo 不是 pawstash 仓库根目录" }
$i18n = "src/lib/i18n/i18nState.svelte.ts"
$settings = "src/lib/components/settings/SettingsModal.svelte"
if (-not (Test-Path $i18n)) { throw "错误: 找不到 $i18n" }

Write-Host "==> 1/3 写入 zh-CN.json" -ForegroundColor Cyan
Copy-Item "$Here/zh-CN.json" "src/lib/i18n/locales/zh-CN.json" -Force

Write-Host "==> 2/3 应用代码补丁" -ForegroundColor Cyan
$applied = $false
if (Test-Path ".git") {
    git apply --3way "$Here/pawstash-zh.patch" 2>$null
    if ($LASTEXITCODE -eq 0) { $applied = $true }
    else {
        git apply --whitespace=nowarn "$Here/pawstash-zh.patch" 2>$null
        if ($LASTEXITCODE -eq 0) { $applied = $true }
    }
}
if (-not $applied) {
    Write-Host "    补丁应用失败，改用整文件覆盖" -ForegroundColor Yellow
    Copy-Item "$Here/i18nState.svelte.ts" $i18n -Force
}

# 兜底：确保 SettingsModal 里有「简体中文」选项
$s = Get-Content $settings -Raw -Encoding UTF8
if ($s -notmatch "简体中文") {
    Write-Host "    SettingsModal 未打上，逐项补丁" -ForegroundColor Yellow
    $s = $s.Replace(
        "import IconFlagRu from '~icons/circle-flags/ru';",
        "import IconFlagRu from '~icons/circle-flags/ru';`r`n  import IconFlagCn from '~icons/circle-flags/cn';")
    $s = $s.Replace(
        "{ value: 'ru', label: 'Русский', icon: IconFlagRu }",
        "{ value: 'ru', label: 'Русский', icon: IconFlagRu },`r`n              { value: 'zh', label: '简体中文', icon: IconFlagCn }")
    [System.IO.File]::WriteAllText((Resolve-Path $settings), $s, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host "==> 3/3 校验" -ForegroundColor Cyan
node scripts/check-i18n.js

Write-Host ""
Write-Host "完成。运行 npm run dev 启动，然后：设置 → 界面语言 → 简体中文" -ForegroundColor Green
