#!/data/data/com.termux/files/usr/bin/bash
#
# code-server 安装与启动脚本
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/logger.sh"
source "$SCRIPT_DIR/utils.sh"

CS_CONFIG_DIR="$HOME/.config/code-server"
CS_CONFIG="$CS_CONFIG_DIR/config.yaml"
CS_PATCH_DIR="$PREFIX/lib/code-server/patches"
CS_PATCH="$CS_PATCH_DIR/p.js"
CS_SVC_DIR="$PREFIX/var/service/code-server"

log_info "开始安装并配置 code-server"

# ── 1. 添加 TUR 仓库 ──────────────────────────────────
log_info "检查 TUR (Termux User Repository) 仓库..."
if pkg_installed tur-repo; then
    log_warn "TUR 仓库已添加，跳过"
else
    pkg install -y tur-repo
    pkg update
    log_ok "TUR 仓库已添加"
fi

# ── 2. 安装 termux-services + code-server ───────────────
log_info "检查并安装 termux-services 和 code-server..."
pkg_install termux-services code-server
log_ok "termux-services 和 code-server 就绪"

# ── 3. 配置访问密码 ──────────────────────────────────
if [ -f "$CS_CONFIG" ]; then
    log_warn "code-server 配置文件已存在，跳过密码配置"
    CS_PASSWORD=$(grep -E "^password:" "$CS_CONFIG" | awk '{print $2}')
else
    log_info "配置 code-server 访问密码"
    log_warn "请输入 code-server 访问密码："
    read -s CS_PASSWORD
    echo ""
    if [ -z "$CS_PASSWORD" ]; then
        log_error "密码不能为空"
        exit 1
    fi

    mkdir -p "$CS_CONFIG_DIR"
    cat > "$CS_CONFIG" <<EOF
bind-addr: 0.0.0.0:8080
auth: password
password: ${CS_PASSWORD}
cert: false
EOF
    log_ok "配置文件已写入"
fi

# ── 4. 安装补丁（修复 MAC 地址和平台检测）────────────
if [ -f "$CS_PATCH" ]; then
    log_warn "补丁脚本已存在，跳过"
else
    log_info "安装 platform/network 补丁..."
    mkdir -p "$CS_PATCH_DIR"
    cat > "$CS_PATCH" <<'PATCH_EOF'
console.log("Patching os.networkInterfaces and process.platform started.");

Object.defineProperty(process, "platform", { get() { return "linux"; } });

const os = require('os');
var originalNetworkInterfaces = os.networkInterfaces;

function patchedNetworkInterfaces() {
    var interfaces = originalNetworkInterfaces();
    for (var iface in interfaces) {
        for (var i = 0; i < interfaces[iface].length; i++) {
            interfaces[iface][i].mac = '02:00:00:00:00:01';
        }
    }
    return interfaces;
}

os.networkInterfaces = patchedNetworkInterfaces;
console.log("Patching completed.");
PATCH_EOF
    log_ok "补丁脚本已安装"
fi

# ── 5. 配置扩展市场地址 ──────────────────────────────
CS_PRODUCT_JSON="$PREFIX/lib/code-server/lib/vscode/product.json"
if [ -f "$CS_PRODUCT_JSON" ]; then
    CS_HAS_GALLERY=$(node -e "
const p = JSON.parse(require('fs').readFileSync('$CS_PRODUCT_JSON', 'utf8'));
process.exit(p.extensionsGallery ? 0 : 1);
" 2>/dev/null && echo "yes" || echo "no")
    if [ "$CS_HAS_GALLERY" = "yes" ]; then
        log_warn "扩展市场地址已配置，跳过"
    else
        log_info "配置 VS Code 扩展市场地址..."
        node -e "
const fs = require('fs');
const p = JSON.parse(fs.readFileSync('$CS_PRODUCT_JSON', 'utf8'));
p.extensionsGallery = {
    serviceUrl: 'https://marketplace.visualstudio.com/_apis/public/gallery',
    cacheUrl: 'https://vscode.blob.core.windows.net/gallery/index',
    itemUrl: 'https://marketplace.visualstudio.com/items'
};
fs.writeFileSync('$CS_PRODUCT_JSON', JSON.stringify(p, null, 2));
"
        log_ok "扩展市场地址已配置"
    fi
else
    log_error "未找到 product.json: $CS_PRODUCT_JSON"
fi

# ── 6. 注册为 termux-services 服务 ────────────────────
if [ -d "$CS_SVC_DIR" ]; then
    log_warn "code-server 服务已注册，跳过"
else
    log_info "注册 code-server 为 termux-services 服务..."
    mkdir -p "$CS_SVC_DIR/log"
    ln -sf "$PREFIX/share/termux-services/svlogger" "$CS_SVC_DIR/log/run"

    cat > "$CS_SVC_DIR/run" <<SVC_RUN_EOF
#!/data/data/com.termux/files/usr/bin/sh
exec 2>&1
NODE_OPTIONS="--require $CS_PATCH" exec code-server
SVC_RUN_EOF
    chmod +x "$CS_SVC_DIR/run"
    log_ok "code-server 服务脚本已创建"
fi

# ── 7. 启用并启动 code-server 服务 ──────────────────────
log_info "启用 code-server 服务..."
sv-enable code-server
log_ok "code-server 已启用并启动（开机自启）"

# ── 信息面板 ─────────────────────────────────────────
CS_PID=$(pgrep -f "code-server" | head -1)
CS_PORT=$(grep -E "^bind-addr" "$CS_CONFIG" 2>/dev/null | awk -F: '{print $NF}')
CS_PORT="${CS_PORT:-8080}"
LOCAL_IP=$(get_local_ip)
LOCAL_IP="${LOCAL_IP:-<未获取到IP>}"

echo ""
echo "  code-server 服务信息面板"
echo "  ───────────────────────────────────────────"
echo "  PID		${CS_PID}"
echo "  端口		${CS_PORT}"
echo "  访问地址	http://${LOCAL_IP}:${CS_PORT}"
echo "  密码		${CS_PASSWORD}"
echo "  配置文件	${CS_CONFIG}"
echo "  ───────────────────────────────────────────"
echo "  客户端连接步骤："
echo "  1. 在浏览器中打开上方访问地址"
echo "  2. 输入上方密码登录"
echo "  ───────────────────────────────────────────"
echo "  服务管理："
echo "  启用	sv-enable code-server"
echo "  启动	sv up code-server"
echo "  停止	sv down code-server"
echo "  禁用	sv-disable code-server"
echo ""

log_ok "code-server 安装与配置全部完成！"

# ── 写入 bashrc 简短提示 ────────────────────────────────
log_info "配置 bashrc 会话提示..."
if ! grep -q "cs_info" "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'BASHRC_EOF'

cs_info() {
    local port=$(grep -E "^bind-addr" ~/.config/code-server/config.yaml 2>/dev/null | awk -F: '{print $NF}')
    port="${port:-8080}"
    local ip=$(ip -4 addr show 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | grep -v 127.0.0.1 | head -1)
    local pwd=$(grep -E "^password:" ~/.config/code-server/config.yaml 2>/dev/null | awk '{print $2}')
    echo "  code-server: http://${ip:-<无IP>}:${port} | 密码: ${pwd}"
}
cs_info
BASHRC_EOF
    log_ok "bashrc 提示已配置"
fi
