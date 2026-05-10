#!/data/data/com.termux/files/usr/bin/bash
#
# 日志模块
# 用法：source logger.sh
# 可选：设置 LOGGER_OUTPUT="file" 和 LOGGER_FILE="/path/to/log" 以输出到文件
#

# 配置
LOGGER_OUTPUT="${LOGGER_OUTPUT:-console}"   # console | file
LOGGER_FILE="${LOGGER_FILE:-${TMPDIR:-$PREFIX/tmp}/app.log}"

# 颜色（现代低饱和度，舒适美观）
readonly _C_RESET='\033[0m'
readonly _C_ERROR='\033[38;2;235;87;87m'   # 柔和红
readonly _C_INFO='\033[38;2;100;149;237m'  # 柔和蓝
readonly _C_OK='\033[38;2;102;187;106m'    # 柔和绿
readonly _C_WARN='\033[38;2;240;188;74m'   # 柔和黄

# 格式化时间戳
_ts() {
    printf '%02d:%02d:%02d-%02d:%02d:%02d.%03d' \
        "$((10#$(date +%y)))" "$((10#$(date +%m)))" "$((10#$(date +%d)))" \
        "$((10#$(date +%H)))" "$((10#$(date +%M)))" "$((10#$(date +%S)))" \
        "$((10#$(date +%N)/1000000))"
}

# 写日志
_log() {
    local level="$1" color="$2" msg="$3"
    local timestamp
    timestamp="$(_ts)"
    local padded
    printf -v padded '%-5s' "$level"
    local line="${timestamp} [${padded}] ${msg}"

    if [[ "$LOGGER_OUTPUT" == "file" ]]; then
        echo -e "$line" >> "$LOGGER_FILE"
    else
        echo -e "${color}${line}${_C_RESET}"
    fi
}

# 公开接口
log_error() { _log "Error" "$_C_ERROR" "$*"; }
log_info()  { _log "Info"  "$_C_INFO"  "$*"; }
log_ok()    { _log "Ok"    "$_C_OK"    "$*"; }
log_warn()  { _log "Warn"  "$_C_WARN"  "$*"; }

# 测试：依次输出所有级别
test_log() {
    log_info  "这是一条 Info 日志"
    log_ok    "这是一条 Ok 日志"
    log_warn  "这是一条 Warn 日志"
    log_error "这是一条 Error 日志"
}
