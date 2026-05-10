#!/data/data/com.termux/files/usr/bin/bash
#
# Oh My Zsh 安装脚本（使用清华 TUNA 镜像源）
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/logger.sh"

ZSH_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git"
CLONE_DIR="${TMPDIR:-/tmp}/ohmyzsh"

log_info "开始安装 Oh My Zsh（清华 TUNA 镜像源）"

# 安装 zsh
log_info "安装 zsh..."
pkg install -y zsh
log_ok "zsh 已安装"

# 克隆仓库到临时目录
log_info "克隆 Oh My Zsh 仓库..."
rm -rf "$CLONE_DIR"
git clone --depth=1 "$ZSH_REMOTE" "$CLONE_DIR"
log_ok "仓库克隆完成"

# 执行安装
log_info "执行 Oh My Zsh 安装..."
REMOTE="$ZSH_REMOTE" sh "$CLONE_DIR/tools/install.sh"
log_ok "Oh My Zsh 安装完成"

# 清理临时文件
log_info "清理临时文件..."
rm -rf "$CLONE_DIR"
log_ok "临时文件已清理"

# 设置默认 shell
log_info "设置 zsh 为默认 shell..."
chsh -s zsh
log_ok "默认 shell 已切换为 zsh"

log_ok "Oh My Zsh 全部安装完成！"
