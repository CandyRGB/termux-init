#!/data/data/com.termux/files/usr/bin/bash
#
# SSH 安装与启动脚本（ed25519 认证）
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/logger.sh"
source "$SCRIPT_DIR/utils.sh"

SSH_DIR="$HOME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
KEY_FILE="$SSH_DIR/id_ed25519"

log_info "开始安装并配置 SSH 服务"

# ── 安装 termux-services + openssh ─────────────────────
log_info "安装 termux-services 和 openssh..."
pkg install -y termux-services openssh
log_ok "termux-services 和 openssh 已安装"

# ── 生成 ed25519 密钥对 ────────────────────────────────
if [ -f "$KEY_FILE" ]; then
    log_warn "ed25519 密钥已存在，跳过生成"
else
    log_info "生成 ed25519 密钥对..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    ssh-keygen -t ed25519 -f "$KEY_FILE" -N "" -C "termux@$(hostname)"
    log_ok "ed25519 密钥对已生成"
fi

# ── 配置 authorized_keys ───────────────────────────────
if grep -q "$(cat "$KEY_FILE.pub")" "$AUTHORIZED_KEYS" 2>/dev/null; then
    log_warn "公钥已存在于 authorized_keys，跳过"
else
    cat "$KEY_FILE.pub" >> "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
    log_ok "公钥已写入 authorized_keys"
fi

# ── 配置 sshd ──────────────────────────────────────────
log_info "配置 sshd..."
SSHD_CONFIG="$PREFIX/etc/ssh/sshd_config"
if grep -q "^PasswordAuthentication" "$SSHD_CONFIG"; then
    sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG"
else
    echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
fi
log_ok "已禁用密码认证，仅允许密钥登录"

# ── 通过 termux-services 启用并启动 sshd ───────────────
log_info "通过 termux-services 启动 sshd..."
sv-enable sshd
sv up sshd
log_ok "sshd 已启动并设为开机自启"

# ── 信息面板 ───────────────────────────────────────────
SSH_PID=$(pgrep -x sshd | head -1)
SSH_PORT=$(grep -E "^Port" "$SSHD_CONFIG" 2>/dev/null | awk '{print $2}')
SSH_PORT="${SSH_PORT:-8022}"
LOCAL_IP=$(get_local_ip)
LOCAL_IP="${LOCAL_IP:-<未获取到IP>}"
USERNAME=$(whoami)

echo ""
echo "  SSH 服务信息面板"
echo "  ───────────────────────────────────────────"
echo "  PID		${SSH_PID}"
echo "  端口		${SSH_PORT}"
echo "  用户		${USERNAME}"
echo "  认证方式	ed25519 密钥"
echo "  私钥		$(cat ${KEY_FILE})"
echo "  ───────────────────────────────────────────"
echo "  客户端连接步骤："
echo "  1. 将上方私钥保存到本地文件"
echo "  2. 设置权限"
echo "     chmod 600 <私钥文件>"
echo "  3. 连接"
echo "     ssh -i <私钥文件> -p ${SSH_PORT} ${USERNAME}@${LOCAL_IP}"
echo "  ───────────────────────────────────────────"
echo "  服务管理："
echo "  启动	sv up sshd"
echo "  停止	sv down sshd"
echo "  启用	sv-enable sshd"
echo "  禁用	sv-disable sshd"
echo ""

log_ok "SSH 安装与配置全部完成！"

# ── 写入 bashrc 简短提示 ────────────────────────────────
log_info "配置 bashrc 会话提示..."
if ! grep -q "ssh_info" "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'BASHRC_EOF'

ssh_info() {
    local port=$(grep -E "^Port" /data/data/com.termux/files/usr/etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
    port="${port:-8022}"
    local ip=$(ip -4 addr show 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | grep -v 127.0.0.1 | head -1)
    local user=$(whoami)
    echo "  SSH: ssh -i ~/.ssh/id_ed25519 -p ${port} ${user}@${ip:-<无IP>}"
}
ssh_info
BASHRC_EOF
    log_ok "bashrc 提示已配置"
fi
