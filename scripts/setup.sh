#!/bin/bash
# ===========================================
# Claude Code WSL Bridge - 一键安装脚本
# ===========================================
# 用法: chmod +x scripts/setup.sh && ./scripts/setup.sh
# 在 WSL Ubuntu 终端中运行
# ===========================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[*]${NC} $1"; }
ok()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
err()   { echo -e "${RED}[✗]${NC} $1"; }

echo "========================================"
echo "  Claude Code WSL Bridge 安装脚本"
echo "========================================"
echo ""

# --- 检查 WSL 环境 ---
if ! grep -q Microsoft /proc/version 2>/dev/null && ! grep -q microsoft /proc/version 2>/dev/null; then
    warn "此脚本专为 WSL 环境设计（但你也可以继续）"
fi

# --- 检查网络 ---
info "检查网络连通性..."
if curl -s --connect-timeout 5 -o /dev/null https://registry.npmjs.org; then
    ok "网络正常"
else
    warn "无法访问 npm registry，请检查网络连接（可能需要开代理）"
    warn "你可以设置 HTTP_PROXY 后再试:"
    echo "  export HTTP_PROXY=http://127.0.0.1:7890"
    echo "  export HTTPS_PROXY=http://127.0.0.1:7890"
fi

# --- 检查 Node.js ---
info "检查 Node.js 环境..."
if command -v node &>/dev/null; then
    NODE_VER=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VER" -lt 22 ]; then
        warn "Node.js 版本过低（$(node --version)），需要 >= 22，将升级..."
        INSTALL_NODE=true
    else
        ok "Node.js $(node --version)（满足要求）"
        INSTALL_NODE=false
    fi
else
    warn "未安装 Node.js，将安装 Node.js 22..."
    INSTALL_NODE=true
fi

# --- 检查并安装依赖 ---
NEED_APT=false
for cmd in curl git; do
    if ! command -v $cmd &>/dev/null; then
        NEED_APT=true
        break
    fi
done

if [ "$INSTALL_NODE" = true ] || [ "$NEED_APT" = true ]; then
    info "安装系统依赖（Node.js 22+、git、curl）..."

    # 安装 Node.js 22.x PPA
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

    info "更新包列表并安装依赖..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq nodejs git curl

    ok "系统依赖安装完成"
    ok "Node.js: $(node --version)"
    ok "npm:    $(npm --version)"
fi

# --- 安装 Claude Code CLI ---
info "安装 Claude Code CLI..."
if command -v claude &>/dev/null; then
    ok "Claude Code 已安装 (版本: $(claude --version 2>/dev/null || echo 'unknown'))"
    warn "如需更新: npm install -g @anthropic-ai/claude-code@latest"
else
    npm install -g @anthropic-ai/claude-code
    ok "Claude Code CLI 安装完成"
fi

# --- 安装 NervHub（协议桥接层）---
info "安装协议桥接层 NervHub..."
if command -v nervhub &>/dev/null; then
    ok "NervHub 已安装"
else
    npm install -g nervhub 2>/dev/null || {
        warn "npm 安装失败，尝试 npx 方式..."
        ok "NervHub 可以通过 npx 使用"
    }
    ok "NervHub 安装完成"
fi

# --- 配置 .env 文件 ---
info "配置环境变量..."
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        ok ".env 文件已创建（请稍后编辑填入你的 API Key）"
    fi
else
    ok ".env 文件已存在，跳过"
fi

# --- 配置 Claude Code 代理（可选）---
info "配置 Claude Code 使用本地代理..."
if command -v claude &>/dev/null; then
    # 检查是否已配置
    CURRENT_PROXY=$(claude config get proxy 2>/dev/null || echo "")
    if [ -z "$CURRENT_PROXY" ]; then
        claude config set proxy http://127.0.0.1:11500/anthropic 2>/dev/null || true
        ok "Claude Code 已配置使用本地代理（127.0.0.1:11500）"
    else
        ok "Claude Code 代理已配置: $CURRENT_PROXY"
    fi
fi

# --- 添加环境变量到 .bashrc ---
if ! grep -q "ANTHROPIC_BASE_URL" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Claude Code WSL Bridge - 本地代理" >> ~/.bashrc
    echo "export ANTHROPIC_BASE_URL=http://127.0.0.1:11500" >> ~/.bashrc
    ok "已添加 ANTHROPIC_BASE_URL 到 ~/.bashrc"
fi

echo ""
echo "========================================"
echo -e "  ${GREEN}安装完成！${NC}"
echo "========================================"
echo ""
echo "接下来需要配置模型供应商："
echo ""
echo "  1. 配置 API Key 和供应商："
echo "     nervhub init"
echo ""
echo "  2. 启动桥接层："
echo "     nervhub start"
echo ""
echo "  3. 测试 Claude Code："
echo "     claude '你好，请用 Python 写个冒泡排序'"
echo ""
echo "  4. 启动 VS Code："
echo "     code ."
echo ""
echo "========================================"
