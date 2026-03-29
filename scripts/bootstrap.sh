#!/usr/bin/env bash
# ============================================================
# SDD Microservice - 一键启动脚本
# 用途：检查环境 → 配置 .env → 拉起基础设施 → 等待就绪 → 导入初始配置
# 用法：./scripts/bootstrap.sh [--with-tools]
# ============================================================
set -euo pipefail

# ---- 颜色输出 -----------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m' # No Color

log_info()    { echo -e "${GREEN}[INFO]${NC}  $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_section() { echo -e "\n${BLUE}==============================${NC}"; echo -e "${BLUE} $1${NC}"; echo -e "${BLUE}==============================${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"
WITH_TOOLS=false
[[ "${1:-}" == "--with-tools" ]] && WITH_TOOLS=true

# ============================================================
# Step 1: 检查依赖
# ============================================================
log_section "Step 1: 检查环境依赖"

check_cmd() {
    if ! command -v "$1" &>/dev/null; then
        log_error "缺少依赖：$1 未安装"
        echo "  安装方式：$2"
        exit 1
    fi
    log_info "$1 ✓ ($(${1} --version 2>&1 | head -1))"
}

check_cmd docker   "https://www.docker.com/products/docker-desktop"
check_cmd curl     "brew install curl"

# 检查 Docker 是否已启动
if ! docker info &>/dev/null; then
    log_error "Docker 未启动，请先打开 Docker Desktop"
    exit 1
fi
log_info "Docker daemon ✓"

# ============================================================
# Step 2: 初始化 .env 配置
# ============================================================
log_section "Step 2: 初始化环境配置"

if [[ ! -f "$ENV_FILE" ]]; then
    log_warn ".env 不存在，从 .env.example 复制..."
    cp "$PROJECT_DIR/.env.example" "$ENV_FILE"
    log_info ".env 已创建，请按需修改 $ENV_FILE"
else
    log_info ".env 已存在 ✓"
fi

# 加载环境变量
set -a; source "$ENV_FILE"; set +a

# ============================================================
# Step 3: 启动基础设施
# ============================================================
log_section "Step 3: 启动基础设施容器"

cd "$PROJECT_DIR"

if [[ "$WITH_TOOLS" == "true" ]]; then
    log_info "启动全部服务（含 Swagger/Prism/Zipkin）..."
    docker compose --profile tools up -d
else
    log_info "启动核心基础设施（MySQL + Redis + Nacos）..."
    docker compose up -d mysql redis nacos
fi

# ============================================================
# Step 4: 等待服务就绪
# ============================================================
log_section "Step 4: 等待服务健康检查"

wait_healthy() {
    local container="$1"
    local max_wait="${2:-120}"
    local elapsed=0
    echo -n "  等待 $container 就绪..."
    while true; do
        local status
        status=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "not_found")
        case "$status" in
            healthy)
                echo -e " ${GREEN}✓${NC}"
                return 0
                ;;
            not_found)
                echo -e " ${RED}容器不存在${NC}"
                return 1
                ;;
        esac
        if (( elapsed >= max_wait )); then
            echo -e " ${RED}超时（${max_wait}s）${NC}"
            log_error "请运行 docker compose logs $container 查看日志"
            return 1
        fi
        sleep 3
        (( elapsed += 3 ))
        echo -n "."
    done
}

wait_healthy "sdd-mysql"  120
wait_healthy "sdd-redis"   60
wait_healthy "sdd-nacos"  180

# ============================================================
# Step 5: 导入 Nacos 初始配置
# ============================================================
log_section "Step 5: 导入 Nacos 初始配置"

NACOS_ADDR="${NACOS_SERVER_ADDR:-localhost:8848}"
NACOS_USER="${NACOS_AUTH_IDENTITY_KEY:-nacos}"

import_nacos_config() {
    local data_id="$1"
    local content="$2"
    local group="${3:-DEFAULT_GROUP}"

    curl -sf -X POST "http://${NACOS_ADDR}/nacos/v1/cs/configs" \
        -u "nacos:nacos" \
        --data-urlencode "dataId=${data_id}" \
        --data-urlencode "group=${group}" \
        --data-urlencode "content=${content}" \
        --data-urlencode "type=yaml" > /dev/null

    log_info "导入 Nacos 配置: [${group}] ${data_id} ✓"
}

# 导入用户服务配置
import_nacos_config "sdd-user-service.yaml" "
spring:
  datasource:
    url: jdbc:mysql://sdd-mysql:3306/sdd_user?useUnicode=true&characterEncoding=utf8&allowMultiQueries=true&serverTimezone=Asia/Shanghai
    username: root
    password: \${MYSQL_ROOT_PASSWORD:root123}
  redis:
    host: sdd-redis
    port: 6379
    password: \${REDIS_PASSWORD:sdd123}
"

# 导入认证服务配置
import_nacos_config "sdd-auth.yaml" "
spring:
  redis:
    host: sdd-redis
    port: 6379
    password: \${REDIS_PASSWORD:sdd123}
jwt:
  secret: \${JWT_SECRET:sdd-microservice-jwt-secret-key-change-in-production}
  access-token-ttl: 7200
  refresh-token-ttl: 604800
"

# ============================================================
# Step 6: 输出汇总
# ============================================================
log_section "✅ 基础设施启动完成"

echo ""
echo "  服务地址汇总："
echo -e "  ${GREEN}MySQL${NC}       : localhost:${DB_PORT:-3306}  (root / ${MYSQL_ROOT_PASSWORD:-root123})"
echo -e "  ${GREEN}Redis${NC}       : localhost:${REDIS_PORT:-6379} (密码: ${REDIS_PASSWORD:-sdd123})"
echo -e "  ${GREEN}Nacos${NC}       : http://localhost:${NACOS_PORT:-8848}/nacos  (nacos / nacos)"
if [[ "$WITH_TOOLS" == "true" ]]; then
    echo -e "  ${GREEN}Swagger UI${NC}  : http://localhost:8090"
    echo -e "  ${GREEN}Prism Mock${NC}  : http://localhost:4010"
    echo -e "  ${GREEN}Zipkin${NC}      : http://localhost:9411"
fi
echo ""
echo "  下一步：在 IDEA 中分别启动各服务 Application 类"
echo "    - AuthApplication     -> http://localhost:8081"
echo "    - UserServiceApplication -> http://localhost:8082"
echo "    - GatewayApplication  -> http://localhost:8080"
echo ""
