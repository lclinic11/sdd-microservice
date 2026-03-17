#!/usr/bin/env bash
# =============================================================
# SDD 契约验证脚本
# 使用 Spectral 检查 OpenAPI 契约是否符合规范
# 前提：npm install -g @stoplight/spectral-cli
# =============================================================

set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔍 [SDD] 开始校验 OpenAPI 契约..."

find "${BASE_DIR}" -name "*.yaml" -path "*/specs/*" | while read -r spec_file; do
  echo ""
  echo "📄 校验: ${spec_file}"
  spectral lint "${spec_file}" --ruleset "${BASE_DIR}/.spectral.yml" || true
done

echo ""
echo "✅ 校验完成"
