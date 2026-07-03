#!/bin/bash
# ===========================================
# Claude Code WSL Bridge - 一键安装脚本
# ===========================================
set -e

echo "========================================"
echo "  Claude Code WSL Bridge 安装脚本"
echo "========================================"

# 检查 WSL 环境
if ! grep -q Microsoft /proc/version 2>/dev/null; then
    echo "[!] 警告：此脚本专为 WSL 环境设计"
fi

echo "[*] 更新包列表..."
sudo apt-get update -qq

echo "[*] 安装依赖 (Python3, Node.js, git)..."
sudo apt-get install -y -qq python3 python3-pip nodejs npm git curl

echo "[*] 安装 Claude Code (npm)..."
npm install -g @anthropic-ai/claude-code 2>/dev/null || npm install -g claude-code-cli 2>/dev/null || {
    echo "[!] Claude Code npm 包未找到，尝试 pip 安装..."
    pip3 install claude-code 2>/dev/null || echo "[*] 跳过 Claude Code 安装，请参考 README 手动安装"
}

echo "[*] 创建 .env 文件（如果不存在）..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "[!] 请编辑 .env 文件填入你的 API Key"
else
    echo "[*] .env 已存在，跳过"
fi

echo "========================================"
echo "  安装完成！"
echo "  执行 'code .' 打开 VS Code"
echo "  或执行 'claude \"你好\"' 测试"
echo "========================================"
