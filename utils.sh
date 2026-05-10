#!/data/data/com.termux/files/usr/bin/bash
#
# 通用工具函数模块
# 用法：source utils.sh
#

# 检查软件包是否已安装
pkg_installed() {
    dpkg -s "$1" &>/dev/null
}

# 批量安装软件包（自动跳过已安装的包）
pkg_install() {
    local pkgs=()
    for p in "$@"; do
        if pkg_installed "$p"; then
            log_warn "$p 已安装，跳过"
        else
            pkgs+=("$p")
        fi
    done
    if [ ${#pkgs[@]} -gt 0 ]; then
        pkg install -y "${pkgs[@]}"
    fi
}

# 获取本机局域网 IPv4 地址（排除回环）
get_local_ip() {
    if ! command -v ip &>/dev/null; then
        pkg_install iproute2
    fi
    ip -4 addr show 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | grep -v 127.0.0.1 | head -1
}
