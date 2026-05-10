#!/data/data/com.termux/files/usr/bin/bash
#
# 通用工具函数模块
# 用法：source utils.sh
#

# 获取本机局域网 IPv4 地址（排除回环）
get_local_ip() {
    if ! command -v ip &>/dev/null; then
        pkg install -y iproute2
    fi
    ip -4 addr show 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | grep -v 127.0.0.1 | head -1
}
