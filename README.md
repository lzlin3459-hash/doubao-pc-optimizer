# doubao-pc-optimizer

> 豆包电脑清理与性能优化 Skill

帮助用户安全地完成电脑清理、磁盘空间释放和性能调优。核心原则：**先识别系统，再评估风险，征得许可后执行，所有系统级修改必须可回滚**。

## 功能特性

### 🧹 磁盘清理
- 临时文件、浏览器缓存、Windows 更新缓存清理
- 系统日志、错误报告、蓝屏转储清理
- 回收站、Windows.old、系统还原点（单独确认）

### 🤖 AI工具缓存迁移（特色功能）
- Gemini / Codex / Coze / WorkBuddy 等AI CLI工具缓存迁移
- npm / Playwright / Conda / Rust 等开发工具缓存迁移
- WSL 发行版迁移
- **Junction 目录联接法**：程序完全无感知，透明迁移到D盘

### 🎮 游戏性能优化
- 帧率优化、HAGS硬件加速
- 电源计划优化
- 启动项、服务管理

### 📊 系统调优
- 开机速度优化
- 内存占用优化
- 后台进程管理

## 目录结构

```
doubao-pc-optimizer/
├── SKILL.md                          # Skill 主文档
├── references/
│   ├── windows-cleanup.md             # Windows 磁盘清理参考
│   └── windows-ai-cache-migration.md # AI工具缓存迁移参考
└── scripts/
    ├── win_scan.ps1                  # 系统扫描脚本（只读）
    ├── win_clean.ps1                 # 安全清理脚本
    └── win_ai_cache_migrate.ps1      # AI工具缓存迁移脚本
```

## 快速开始

### 扫描系统
```powershell
.\scripts\win_scan.ps1
```

### 安全清理
```powershell
# 预演模式（只统计不删除）
.\scripts\win_clean.ps1 -DryRun

# 实际清理
.\scripts\win_clean.ps1
```

### 迁移AI工具缓存
```powershell
# 扫描可迁移目录
.\scripts\win_ai_cache_migrate.ps1 -Scan

# 预演迁移
.\scripts\win_ai_cache_migrate.ps1 -Migrate -DryRun

# 实际迁移
.\scripts\win_ai_cache_migrate.ps1 -Migrate
```

## 风险分级

| 级别 | 说明 | 示例 |
|------|------|------|
| L0 只读 | 不修改任何内容 | 扫描磁盘、查看进程 |
| L1 安全清理 | 只删可再生的缓存/临时文件 | 临时文件、浏览器缓存 |
| L2 系统修改 | 改变系统设置，可回滚 | 电源计划、启动项 |
| L3 禁止 | 可能导致系统损坏 | 删除 System32、禁用关键服务 |

## 核心原则

1. **宁可少清理 1GB，不可多删 1 个文件**
2. **所有操作必须可回滚**
3. **个人文件绝不碰**
4. **不可逆操作必须单独确认**

## 案例：C盘爆满清理实录

本次优化从 10GB 剩余 → 79GB 剩余，共释放约 69GB：

| 项目 | 释放空间 |
|------|---------|
| 安全清理（临时文件/浏览器缓存） | ~10 GB |
| AI工具目录迁移到D盘 | ~20 GB |
| 微信缓存清理 | ~3.5 GB |
| Ubuntu WSL 迁移 | ~3.2 GB |
| Windows.old 删除 | ~25 GB |
| Python 目录迁移 | ~7 GB |

## License

MIT
