#!/bin/bash
set -e  # 在脚本中，如果任意命令失败则退出脚本

PACKAGE_NAME="remove_object"
OUTPUT_DIR="output/$PACKAGE_NAME"
TEMPLATE_DIR="template"

rm -rf "$OUTPUT_DIR"/*

mkdir -p "$OUTPUT_DIR"

cp -r "$TEMPLATE_DIR"/* "$OUTPUT_DIR/"

make "$PACKAGE_NAME"

cd "$OUTPUT_DIR"

echo "Current directory: $(pwd)"

# 执行 pnpm install
if ! pnpm install; then
  echo "pnpm install failed"
  exit 1
fi

if ! pnpm build; then
  echo "pnpm build failed"
  exit 1
fi

if ! npm publish; then
  echo "npm publish failed"
  exit 1
fi

echo "Build and setup completed successfully."
