# 📱 Termux Init

<!-- Badges -->
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Termux](https://img.shields.io/badge/Platform-Termux-brightgreen)](https://termux.org/)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash)](https://www.gnu.org/software/bash/)

> 🚀 一键初始化 Termux 环境，自动安装 Oh My Zsh、SSH、code-server 等常用组件。

<!-- TOC -->
## 📋 目录

- [特性](#-特性)
- [前置要求](#-前置要求)
- [快速开始](#-快速开始)
- [脚本说明](#-脚本说明)
- [目录结构](#-目录结构)
- [常见问题](#-常见问题)
- [贡献](#-贡献)
- [许可证](#-许可证)

---

## ✨ 特性

- 🔧 **基础环境** - 息屏唤醒、存储权限、国内镜像源
- 🐚 **Oh My Zsh** - 强大的终端 Shell，支持主题与插件
- 🔐 **SSH 服务** - ed25519 密钥认证，安全远程登录
- 💻 **code-server** - 浏览器中的 VS Code，随时随地写代码
- 📦 **模块化设计** - 各组件独立，可按需安装
- 🇨🇳 **国内镜像** - 使用清华 TUNA 源，加速下载

---

## 📋 前置要求

- 📱 Android 设备
- 📦 [Termux](https://f-droid.org/zh_Hans/packages/com.termux/) (推荐从 F-Droid 安装)
- 🌐 网络连接

---

## 🚀 快速开始

### 一键安装（推荐）

```bash
bash all_in_one.sh
```

按提示选择要安装的组件：

```
可选组件：
───────────────────────────────────────────
[1] Oh My Zsh   ── 更强大的终端 Shell，支持主题与插件
[2] SSH 服务    ── 远程登录 Termux，支持密钥认证
[3] code-server ── 在浏览器中使用 VS Code
───────────────────────────────────────────
输入编号选择，多个用空格分隔（如 1 3）
输入 a 全选，直接回车不安装
```

### 单独安装

```bash
# 基础环境初始化
bash start.sh

# Oh My Zsh
bash zsh_install.sh

# SSH 服务
bash start_ssh.sh

# code-server
bash start_code_server.sh
```

---

## 📖 脚本说明

### start.sh
基础环境初始化脚本，完成以下配置：
- ✅ 启用息屏唤醒 (`termux-wake-lock`)
- ✅ 授予存储权限 (`termux-setup-storage`)
- ✅ 切换清华大学 TUNA 镜像源
- ✅ 安装核心工具：`git`, `curl`, `wget`, `nano`, `termux-services`

### zsh_install.sh
Oh My Zsh 安装脚本：
- ✅ 使用清华 TUNA 镜像加速克隆
- ✅ 安装 zsh 并设为默认 Shell
- ✅ 自动检测已安装状态

### start_ssh.sh
SSH 服务配置脚本：
- ✅ 生成 ed25519 密钥对
- ✅ 配置公钥认证，禁用密码登录
- ✅ 通过 termux-services 管理，开机自启

**连接示例：**
```bash
ssh -i ~/.ssh/id_ed25519 -p 8022 用户名@IP地址
```

### start_code_server.sh
code-server 安装脚本：
- ✅ 从 TUR 仓库安装
- ✅ 自动安装平台检测补丁
- ✅ 配置 VS Code 扩展市场
- ✅ 密码认证保护

**访问地址：**
```
http://IP地址:8080
```

---

## 📂 目录结构

```
termux-init/
├── all_in_one.sh         # 🚀 主入口，一键安装所有组件
├── start.sh              # ⚙️ 基础环境初始化
├── zsh_install.sh        # 🐚 Oh My Zsh 安装
├── start_ssh.sh          # 🔐 SSH 服务配置
├── start_code_server.sh  # 💻 code-server 安装
├── logger.sh             # 📝 日志模块
├── utils.sh              # 🔧 工具函数
├── README.md             # 📄 项目文档
└── LICENSE               # 📜 MIT 许可证
```

---

## ❓ 常见问题

**Q: 安装失败怎么办？**

```bash
# 确保更新软件包列表
pkg update && pkg upgrade -y
```

**Q: SSH 无法连接？**

```bash
# 检查服务状态
sv status sshd

# 手动启动
sv up sshd
```

**Q: code-server 页面打不开？**

```bash
# 检查服务状态
sv status code-server

# 手动启动
sv up code-server
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建分支 (`git checkout -b feature/amazing`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送分支 (`git push origin feature/amazing`)
5. 创建 Pull Request

---

## 📜 许可证

本项目基于 [MIT License](LICENSE) 许可证开源。

**Copyright (c) 2026 Tagca Hui**

---

<p align="center">
  <sub>Built with ❤️ for Termux users</sub>
</p>