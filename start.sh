#!/data/data/com.termux/files/usr/bin/bash
#
# Termux 环境初始化脚本
# 功能：息屏唤醒 + 授予存储权限 + 使用国内镜像源 + 安装核心工具
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/logger.sh"
source "$SCRIPT_DIR/utils.sh"

log_info "开始初始化 Termux 环境"

log_info "步骤 1/4：息屏后保持唤醒"
termux-wake-lock &
echo 'termux-wake-lock &' >> $PREFIX/etc/termux-login.sh
log_ok "息屏唤醒已启用"

log_info "步骤 2/4：授予存储权限"
log_warn "请在弹出的系统窗口中点击「允许」"
termux-setup-storage
log_ok "存储权限已授权"
sleep 2

log_info "步骤 3/4：切换国内镜像源（清华 TUNA）"

if [ -f "$PREFIX/etc/apt/sources.list" ]; then
    cp "$PREFIX/etc/apt/sources.list" "$PREFIX/etc/apt/sources.list.bak"
    log_ok "已备份原始源文件"
fi

cat > "$PREFIX/etc/apt/sources.list" <<EOF
# 清华大学 TUNA 镜像源
deb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main
EOF

if [ -d "$PREFIX/etc/apt/sources.list.d" ]; then
    for src in "$PREFIX/etc/apt/sources.list.d"/*.list; do
        [ -f "$src" ] && cp "$src" "$src.bak" 2>/dev/null || true
    done
    rm -f "$PREFIX/etc/apt/sources.list.d"/{game, science}.list 2>/dev/null || true
fi

log_info "正在更新软件包列表..."
pkg update -y
log_ok "软件包列表已更新"

log_info "步骤 4/4：安装核心工具 (git, curl, wget, nano, termux-services)"
pkg_install git curl wget nano termux-services
log_ok "核心工具安装完成"
log_warn "重启 Termux 后 termux-services 将自动接管服务启停"

log_ok "Termux 环境初始化完成！"
log_info "存储权限已授予（请检查是否允许）"
log_info "镜像源已更换为清华大学 TUNA 源"
log_info "已安装的工具：git, curl, wget, nano"
