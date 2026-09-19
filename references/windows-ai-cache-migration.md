# AI工具与开发环境缓存迁移参考

目标：把AI工具、开发工具在C盘的缓存/数据目录透明迁移到D盘，从根本上解决"AI工具自动往C盘塞东西"的问题。
核心方法：**目录联接（Junction）迁移法** —— 程序完全无感知，以为数据还在C盘，实际都在D盘。

## 为什么需要这个

AI工具（Gemini、Coze、WorkBuddy、Codex等）和开发工具（npm、conda、playwright等）默认把缓存、模型、数据都放在C盘的用户目录下，而且体积越来越大。手动删了又会重新下载，治标不治本。

Junction迁移法的优势：
- ✅ 程序完全无感知，不需要改任何配置
- ✅ 可逆，删联接不会丢数据
- ✅ 后续新生成的缓存自动写到D盘
- ✅ 不需要管理员权限（Junction不需要，符号链接需要）

## 标准流程

1. **扫描识别**（L0）：找出C盘里AI/开发工具的大目录
2. **确认进程**：确保相关程序没有在运行
3. **迁移**：用 robocopy /MOVE 移动到D盘，然后创建Junction
4. **验证**：确认联接正常，程序能正常访问

## 常见AI/开发工具的C盘位置

### 用户目录下的 dot 目录（AI CLI工具）

| 目录 | 工具 | 典型大小 |
|------|------|---------|
| `~/.gemini` | Gemini CLI / Antigravity IDE | 2-10 GB |
| `~/.codex` | OpenAI Codex CLI | 1-5 GB |
| `~/.coze` | Coze 平台 | 0.5-2 GB |
| `~/.workbuddy` | 腾讯 WorkBuddy | 0.5-3 GB |
| `~/.cache` | 通用缓存（HuggingFace等） | 2-20 GB |
| `~/.conda` | Conda Python环境 | 2-10 GB |
| `~/.rustup` | Rust 工具链 | 0.5-2 GB |
| `~/.docker` | Docker 配置 | 0.2-1 GB |

### AppData 下的开发工具缓存

| 目录 | 工具 | 典型大小 |
|------|------|---------|
| `%LOCALAPPDATA%\npm-cache` | npm 包缓存 | 1-10 GB |
| `%LOCALAPPDATA%\ms-playwright` | Playwright 浏览器 | 1-5 GB |
| `%LOCALAPPDATA%\Programs\Python` | Python 运行时 | 2-10 GB |
| `%LOCALAPPDATA%\wsl` | WSL 发行版 | 5-50 GB |
| `%LOCALAPPDATA%\Docker\wsl` | Docker WSL 数据 | 10-100 GB |

### 应用缓存（微信/飞书等）

| 目录 | 工具 | 典型大小 |
|------|------|---------|
| `%APPDATA%\Tencent\xwechat\radium\web` | 微信网页缓存 | 1-5 GB |
| `%APPDATA%\Tencent\xwechat\XPlugin\Plugins` | 微信插件缓存 | 0.5-2 GB |
| `%APPDATA%\LarkShell\aha` | 飞书用户数据 | 5-20 GB |

## Junction 迁移法操作规范

### 步骤

```powershell
# 1. 检查源目录是否已经是联接
$src = "C:\源目录路径"
$item = Get-Item $src -Force
if ($item.LinkType -eq "Junction") {
    # 已经是联接，跳过
}

# 2. 检查是否有相关进程在运行
$procs = Get-Process | Where-Object { $_.Name -match "关键词" }
if ($procs) {
    # 提示用户关闭相关程序
}

# 3. 移动到D盘
$dst = "D:\CDriveMigrated\目录名"
robocopy $src $dst /E /MOVE /R:1 /W:1 /NFL /NDL /NJH /NJS

# 4. 原目录已空，删除后创建联接
if (-not (Test-Path $src) -or (Get-ChildItem $src -Force).Count -eq 0) {
    if (Test-Path $src) { Remove-Item $src -Force -Recurse }
    cmd /c mklink /J "$src" "$dst"
}
```

### 注意事项

- **不要迁移正在运行的程序目录**：文件被占用会迁移失败，提示用户关闭相关程序
- **不要迁移有注册表特殊配置的目录**：比如某些软件会把路径写死在注册表里，Junction可能不生效
- **Docker WSL 特殊处理**：Docker WSL 的注册路径是直接指向D盘的，不要随便改，先检查注册表 `HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss`
- **WSL 发行版迁移**：不要用Junction，要用官方的导出导入方式（见下文）

## WSL 迁移标准流程

WSL 发行版不能用Junction迁移，必须用官方的导出导入方式：

```powershell
# 1. 停止所有WSL
wsl --shutdown

# 2. 导出发行版
wsl --export Ubuntu "D:\WSL\Ubuntu\ubuntu.tar"

# 3. 注销原发行版
wsl --unregister Ubuntu

# 4. 导入到新位置
wsl --import Ubuntu "D:\WSL\Ubuntu" "D:\WSL\Ubuntu\ubuntu.tar"

# 5. 删除导出的tar文件
Remove-Item "D:\WSL\Ubuntu\ubuntu.tar" -Force
```

### 注意事项

- 导入后默认用户可能变成root，需要手动设置默认用户
- Docker Desktop 的 WSL 数据通常已经在D盘（通过Docker设置配置），不要随便改，先检查注册表路径
- 迁移前确认WSL已完全停止

## 开发工具缓存路径配置（不需要Junction）

有些工具支持直接改配置路径，比Junction更干净：

### npm 缓存
```powershell
npm config set cache "D:\CDriveMigrated\npm-cache" --global
```

### Playwright 浏览器
```powershell
[Environment]::SetEnvironmentVariable("PLAYWRIGHT_BROWSERS_PATH", "D:\CDriveMigrated\ms-playwright", "User")
```

### Conda 环境
修改 `.condarc` 文件，添加：
```
envs_dirs:
  - D:\CDriveMigrated\conda\envs
pkgs_dirs:
  - D:\CDriveMigrated\conda\pkgs
```

## 微信/飞书缓存清理规范

### 微信（xwechat）

**可以安全删除的**：
- `radium\web`：网页缓存，会自动重建
- `XPlugin\Plugins`：插件缓存，重启后会自动下载
- `log`：日志文件
- `crashpad`：崩溃报告

**不能碰的**：
- `radium\users`：用户数据，包含聊天记录

**最佳实践**：让用户在微信设置里点"清理缓存"按钮，微信会智能区分，比手动删安全。

### 飞书（LarkShell）

**最佳实践**：
1. 先在飞书设置里把文件保存位置改到D盘
2. 然后点"清理缓存"按钮
3. 不要手动删 `aha` 目录，会丢聊天记录

## 汇报模板

```
✅ AI工具缓存迁移完成

迁移了 N 个目录：
- .gemini: X.X GB
- .codex: X.X GB
- npm-cache: X.X GB
...

C盘剩余: XX GB → XX GB
D盘剩余: XX GB → XX GB

后续说明：
- 这些目录已经用Junction链接到D盘
- 程序完全无感知，不需要改任何配置
- 以后新生成的缓存都会自动存到D盘
```

## 常见坑

1. **"扫描显示74GB，实际C盘没占这么多"**：这是因为跟随了Junction读取的大小，实际数据已经在D盘了。用 `Get-Item $path | Select-Object LinkType` 检查是否是联接。

2. **"迁移后程序打不开了"**：说明这个目录有注册表写死的路径，Junction不生效。需要恢复原位置，改用其他方式（比如卸载重装到D盘）。

3. **"robocopy /MOVE 后原目录还在"**：说明有文件被占用。提示用户关闭相关程序后重试，或者只迁移没被占用的部分。

4. **"Docker WSL 迁移后Docker找不到数据"**：Docker WSL 的路径是注册在WSL注册表里面的，不是通过C盘联接访问的。改联接没用，需要用Docker Desktop自己的设置来改磁盘镜像位置。
