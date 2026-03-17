#!/usr/bin/env bash
# =============================================================
# SDD 开发脚本：从 OpenAPI 契约生成代码
# 使用方式：./scripts/sdd-generate.sh [service-name]
# 示例：./scripts/sdd-generate.sh sdd-user-service
# =============================================================

set -e

SERVICE=${1:-"sdd-user-service"}
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE_DIR="${BASE_DIR}/services/${SERVICE}"

echo "🔄 [SDD] 开始从 OpenAPI 契约生成代码..."
echo "📦 服务: ${SERVICE}"
echo "📁 路径: ${SERVICE_DIR}"

if [ ! -d "${SERVICE_DIR}" ]; then
  echo "❌ 服务目录不存在: ${SERVICE_DIR}"
  exit 1
fi

cd "${SERVICE_DIR}"

echo ""
echo "⚙️  执行 mvn generate-sources..."
mvn generate-sources -q

echo ""
echo "✅ [SDD] 代码生成完成！"
echo ""
echo "📋 生成的文件位置:"
echo "   ${SERVICE_DIR}/target/generated-sources/openapi/src/main/java/"
echo ""
echo "📝 下一步："
echo "   1. 检查生成的接口定义"
echo "   2. 在 Controller 中实现接口"
echo "   3. 运行 mvn compile 验证编译"
