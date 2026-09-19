# win_ai_cache_migrate.ps1 — AI工具缓存迁移工具
# 用法:
#   扫描: powershell -ExecutionPolicy Bypass -File win_ai_cache_migrate.ps1 -Scan
#   迁移: powershell -ExecutionPolicy Bypass -File win_ai_cache_migrate.ps1 -Migrate -DryRun
#   实际迁移: powershell -ExecutionPolicy Bypass -File win_ai_cache_migrate.ps1 -Migrate
# 参数: -Scan 只扫描不迁移 | -Migrate 执行迁移 | -DryRun 预演模式
#       -TargetDir 目标目录，默认 D:\CDriveMigrated

param(
    [switch]$Scan,
    [switch]$Migrate,
    [switch]$DryRun,
    [string]$TargetDir = "D:\CDriveMigrated"
)

$ErrorActionPreference = "SilentlyContinue"

# 定义常见AI/开发工具的C盘位置
$migrateTargets = @(
    # 用户目录下的 dot 目录
    @{ Name = ".gemini"; Path = "$env:USERPROFILE\.gemini"; Category = "AI CLI工具" },
    @{ Name = ".codex"; Path = "$env:USERPROFILE\.codex"; Category = "AI CLI工具" },
    @{ Name = ".coze"; Path = "$env:USERPROFILE\.coze"; Category = "AI CLI工具" },
    @{ Name = ".workbuddy"; Path = "$env:USERPROFILE\.workbuddy"; Category = "AI CLI工具" },
    @{ Name = ".cache"; Path = "$env:USERPROFILE\.cache"; Category = "通用缓存" },
    @{ Name = ".conda"; Path = "$env:USERPROFILE\.conda"; Category = "开发环境" },
    @{ Name = ".rustup"; Path = "$env:USERPROFILE\.rustup"; Category = "开发环境" },
    @{ Name = ".docker"; Path = "$env:USERPROFILE\.docker"; Category = "开发环境" },
    # AppData 下的开发工具缓存
    @{ Name = "npm-cache"; Path = "$env:LOCALAPPDATA\npm-cache"; Category = "开发工具缓存" },
    @{ Name = "ms-playwright"; Path = "$env:LOCALAPPDATA\ms-playwright"; Category = "开发工具缓存" },
    @{ Name = "Programs\Python"; Path = "$env:LOCALAPPDATA\Programs\Python"; Category = "开发工具缓存" },
    @{ Name = "CreateTool\data"; Path = "$env:LOCALAPPDATA\CreateTool\data"; Category = "AI工具数据" }
)

function Get-DirSize($path) {
    if (-not (Test-Path $path)) { return 0 }
    # 如果是联接，不计算大小（实际数据在目标位置）
    $item = Get-Item $path -Force
    if ($item.LinkType -eq "Junction") { return 0 }
    (Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
}

function Test-IsJunction($path) {
    if (-not (Test-Path $path)) { return $false }
    $item = Get-Item $path -Force
    return ($item.LinkType -eq "Junction")
}

function Scan-Targets {
    Write-Output "=== AI/开发工具缓存扫描 ==="
    Write-Output ""
    
    $results = @()
    foreach ($t in $migrateTargets) {
        $path = $t.Path
        if (-not (Test-Path $path)) { continue }
        
        $isJunction = Test-IsJunction $path
        $size = Get-DirSize $path
        $sizeMB = [math]::Round($size/1MB)
        $sizeGB = [math]::Round($size/1GB, 2)
        
        $status = if ($isJunction) { "✅ 已是联接" } else { "📦 可迁移" }
        
        Write-Output ("[{0}] {1}" -f $status, $t.Name)
        Write-Output ("  路径: {0}" -f $path)
        Write-Output ("  大小: {0} GB ({1} MB)" -f $sizeGB, $sizeMB)
        Write-Output ("  分类: {0}" -f $t.Category)
        Write-Output ""
        
        if (-not $isJunction -and $size -gt 100MB) {
            $results += [PSCustomObject]@{
                Name = $t.Name
                Path = $path
                SizeGB = $sizeGB
                Category = $t.Category
            }
        }
    }
    
    $totalGB = [math]::Round(($results | Measure-Object SizeGB -Sum).Sum, 1)
    Write-Output ("=== 合计可迁移: {0} GB ({1} 个目录) ===" -f $totalGB, $results.Count)
    Write-Output ""
    Write-Output "提示: 运行 -Migrate 参数开始迁移，先加 -DryRun 预演"
}

function Migrate-Targets {
    param([string]$TargetDir)
    
    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }
    
    $migrated = 0
    $totalFreed = 0
    
    Write-Output "=== 开始迁移" 
    if ($DryRun) { Write-Output "(预演模式，不实际执行)" }
    Write-Output ""
    
    foreach ($t in $migrateTargets) {
        $src = $t.Path
        $name = $t.Name -replace '\\', '-'
        $dst = Join-Path $TargetDir $name
        
        if (-not (Test-Path $src)) { continue }
        if (Test-IsJunction $src) { continue }
        
        $size = Get-DirSize $src
        if ($size -lt 100MB) { continue }
        
        $sizeGB = [math]::Round($size/1GB, 2)
        Write-Output ("--- 迁移 {0} ({1} GB) ---" -f $t.Name, $sizeGB)
        Write-Output ("  源: {0}" -f $src)
        Write-Output ("  目标: {0}" -f $dst)
        
        if ($DryRun) {
            Write-Output "  [预演] 将移动文件并创建联接"
            Write-Output ""
            continue
        }
        
        # 检查是否有相关进程在运行
        # （这里简单检查，实际使用时需要根据具体工具调整）
        
        # 创建目标目录
        New-Item -ItemType Directory -Path $dst -Force | Out-Null
        
        # 用 robocopy 移动
        Write-Output "  正在移动文件..."
        robocopy $src $dst /E /MOVE /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
        
        # 检查原目录是否已空
        if (-not (Test-Path $src) -or (Get-ChildItem $src -Force -ErrorAction SilentlyContinue).Count -eq 0) {
            if (Test-Path $src) { Remove-Item $src -Force -Recurse -ErrorAction SilentlyContinue }
            cmd /c mklink /J "$src" "$dst" | Out-Null
            Write-Output "  ✅ 迁移完成，联接已创建"
            $migrated++
            $totalFreed += $size
        } else {
            $remaining = Get-DirSize $src
            $remainingMB = [math]::Round($remaining/1MB)
            Write-Output "  ⚠️ 部分文件被占用，剩余 $remainingMB MB"
        }
        Write-Output ""
    }
    
    $freedGB = [math]::Round($totalFreed/1GB, 1)
    Write-Output ("=== 迁移完成: {0} 个目录，释放约 {1} GB ===" -f $migrated, $freedGB)
}

# 主逻辑
if ($Scan) {
    Scan-Targets
} elseif ($Migrate) {
    Migrate-Targets -TargetDir $TargetDir
} else {
    Write-Output "用法:"
    Write-Output "  扫描: .\win_ai_cache_migrate.ps1 -Scan"
    Write-Output "  预演: .\win_ai_cache_migrate.ps1 -Migrate -DryRun"
    Write-Output "  迁移: .\win_ai_cache_migrate.ps1 -Migrate"
}
