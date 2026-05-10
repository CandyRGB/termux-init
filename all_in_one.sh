#!/data/data/com.termux/files/usr/bin/bash
#
# Termux 一键初始化脚本
# 功能：交互式选择组件 → 基础初始化 → 安装所选组件
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/logger.sh"

log_info "Termux 一键初始化"
echo ""

# ── 交互选择组件 ──────────────────────────────────────────
INSTALL_ZSH=false
INSTALL_SSH=false
INSTALL_CS=false

log_info "请选择需要安装的组件（y/n）"
echo ""
echo "  Oh My Zsh ── 更强大的终端 Shell，支持主题与插件"
read -p "  安装 Oh My Zsh？[y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] && INSTALL_ZSH=true

echo ""
echo "  SSH 服务 ── 远程登录 Termux，支持密钥认证"
read -p "  安装 SSH 服务？[y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] && INSTALL_SSH=true

echo ""
echo "  code-server ── 在浏览器中使用 VS Code，支持扩展市场"
read -p "  安装 code-server？[y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] && INSTALL_CS=true

echo ""
if ! $INSTALL_ZSH && ! $INSTALL_SSH && ! $INSTALL_CS; then
    log_warn "未选择任何组件，仅执行基础初始化"
fi

# ── 步骤总览 ──────────────────────────────────────────────
TOTAL=1
$INSTALL_ZSH && ((TOTAL++))
$INSTALL_SSH && ((TOTAL++))
$INSTALL_CS && ((TOTAL++))

echo ""
echo "  安装计划："
echo "  ───────────────────────────────────────────"
echo "  [1/$TOTAL] 基础环境初始化（必选）"
$INSTALL_ZSH && echo "  [2/$TOTAL] Oh My Zsh"
$INSTALL_SSH && echo "  [3/$TOTAL] SSH 服务"
$INSTALL_CS && echo "  [4/$TOTAL] code-server"
echo "  ───────────────────────────────────────────"
echo ""
read -p "  确认执行？[Y/n] " ans
[[ "$ans" =~ ^[Nn]$ ]] && { log_warn "已取消"; exit 0; }

# ── 执行安装 ──────────────────────────────────────────────
STEP=0

# 1. 基础初始化
((STEP++))
log_info "═══ 步骤 $STEP/$TOTAL：基础环境初始化 ═══"
bash "$SCRIPT_DIR/start.sh"

# 2. Oh My Zsh
if $INSTALL_ZSH; then
    ((STEP++))
    log_info "═══ 步骤 $STEP/$TOTAL：安装 Oh My Zsh ═══"
    bash "$SCRIPT_DIR/zsh_install.sh"
fi

# 3. SSH
if $INSTALL_SSH; then
    ((STEP++))
    log_info "═══ 步骤 $STEP/$TOTAL：安装 SSH 服务 ═══"
    bash "$SCRIPT_DIR/start_ssh.sh"
fi

# 4. code-server
if $INSTALL_CS; then
    ((STEP++))
    log_info "═══ 步骤 $STEP/$TOTAL：安装 code-server ═══"
    bash "$SCRIPT_DIR/start_code_server.sh"
fi

# ── 完成 ──────────────────────────────────────────────────
echo ""
log_ok "═══ 全部安装完成！═══"
echo ""
echo "  已安装组件："
echo "  基础环境	✓"
$INSTALL_ZSH && echo "  Oh My Zsh	✓"
$INSTALL_SSH && echo "  SSH 服务	✓"
$INSTALL_CS && echo "  code-server	✓"
echo ""
