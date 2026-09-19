<div align="center">

# doubao-pc-optimizer

**🖥️ 豆包电脑清理与性能优化工具集**

> 安全释放磁盘空间，优化系统性能，AI工具缓存透明迁移

[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-5391CE?logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 📖 项目简介

这是一套基于真实C盘清理案例沉淀的Windows系统优化工具集，核心解决：

- 💾 **C盘爆满** —— 安全清理垃圾文件，释放数十GB空间
- 🤖 **AI工具占C盘** —— 透明迁移缓存到D盘，程序无感知
- ⚡ **系统卡顿** —— 优化启动项、服务、电源计划
- 🎮 **游戏掉帧** —— 硬件加速GPU调度等优化

> 🔒 **核心原则**：宁可少清理 1GB，不可多删 1 个文件

---

## ✨ 功能特性

### 🧹 磁盘清理
| 清理项 | 说明 | 典型释放 |
|--------|------|---------|
| 临时文件 | 用户/系统临时目录 | 1-10 GB |
| 浏览器缓存 | Chrome / Edge 全部配置 | 1-8 GB |
| Windows更新缓存 | SoftwareDistribution\Download | 1-5 GB |
| 系统日志 | 日志/错误报告/蓝屏转储 | 可达数GB |
| 回收站/Windows.old | 单独确认后清理 | 10-50 GB |

### 🤖 AI工具缓存迁移（特色）
采用 **Junction 目录联接法**，程序完全无感知，透明迁移：

| 工具 | 说明 |
|------|------|
| Gemini / Antigravity | `.gemini` 目录 |
| Codex / Coze / WorkBuddy | AI CLI工具 |
| npm / Playwright | 前端开发工具 |
| Conda / Rust / Docker | 开发环境 |
| WSL | Linux子系统 |
| Python | 运行时和包 |

### ⚡ 性能优化
- 🎮 硬件加速GPU计划（HAGS）
- ⚡ 高性能电源计划
- 🚀 启动项/服务管理
- 🧹 注册表/视觉效果优化

---

## 🚀 快速开始

### 环境要求
- Windows 10 / 11
- PowerShell 5.1+
- 管理员权限（部分操作需要）

### 1. 克隆仓库
```powershell
git clone https://github.com/lzlin3459-hash/doubao-pc-optimizer.git
cd doubao-pc-optimizer
```

### 2. 扫描系统（只读，安全）
```powershell
.\scripts\win_scan.ps1
```
> 输出系统信息、磁盘占用、可清理空间预估

### 3. 安全清理
```powershell
# 预演模式（只统计不删除）
.\scripts\win_clean.ps1 -DryRun

# 实际清理
Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File .\scripts\win_clean.ps1"
```

### 4. AI工具缓存迁移
```powershell
# 扫描可迁移目录
.\scripts\win_ai_cache_migrate.ps1 -Scan

# 预演迁移
.\scripts\win_ai_cache_migrate.ps1 -Migrate -DryRun

# 实际迁移
.\scripts\win_ai_cache_migrate.ps1 -Migrate
```

---

## 📁 目录结构

```
doubao-pc-optimizer/
├── 📄 SKILL.md                              # Skill 主文档
├── 📁 references/
│   ├── windows-cleanup.md                    # Windows 磁盘清理参考
│   └── windows-ai-cache-migration.md          # AI工具缓存迁移参考
└── 📁 scripts/
    ├── win_scan.ps1                         # 系统扫描脚本（只读）
    ├── win_clean.ps1                        # 安全清理脚本
    └── win_ai_cache_migrate.ps1             # AI工具缓存迁移脚本
```

---

## 🛡️ 风险分级

| 级别 | 说明 | 操作 |
|------|------|------|
| **L0 只读** | 不修改任何内容 | 扫描磁盘、查看进程 |
| **L1 安全清理** | 只删可再生的缓存 | 临时文件、浏览器缓存 |
| **L2 系统修改** | 改变系统设置，可回滚 | 电源计划、启动项 |
| **L3 禁止** | 可能导致系统损坏 | 删除 System32、禁用关键服务 |

> 📌 **不可逆操作**（回收站、Windows.old、系统还原点）必须单独确认

---

## 📊 真实案例

> **案例：联想 R7-7840HS 笔记本 C盘清理实录**

| 阶段 | C盘剩余 | 释放空间 |
|------|---------|----------|
| 初始状态 | 10 GB (5%) | — |
| 安全清理（临时文件/浏览器缓存） | 19.6 GB | +9.6 GB |
| AI工具目录迁移到D盘 | 39.8 GB | +20.2 GB |
| 微信缓存清理 | 43.3 GB | +3.5 GB |
| Ubuntu WSL 迁移 | 46.5 GB | +3.2 GB |
| Windows.old 删除 | 71.7 GB | +25.2 GB |
| Python 目录迁移 | **79.1 GB** | +7.4 GB |
| **总计释放** | — | **约 69 GB** |

从 **5% 使用率** 优化到 **40% 使用率**，C盘彻底解放！

---

## 🎯 核心技术

### Junction 目录联接法
- ✅ 程序完全无感知，不需要改任何配置
- ✅ 可逆，删联接不会丢数据
- ✅ 后续新生成的缓存自动写到D盘
- ✅ 不需要管理员权限

### WSL 迁移
- 导出 → 注销 → 导入 三步官方流程
- 完整保留所有数据和配置

### 安全保障
- 白名单机制，只清理指定目录
- 删除前统计大小，预演模式
- 个人文件绝不触碰

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 License

[MIT](LICENSE) © lzlin3459-hash

---

<div align="center">

如果这个项目对你有帮助，麻烦点个 ⭐ Star 支持一下！

</div>
