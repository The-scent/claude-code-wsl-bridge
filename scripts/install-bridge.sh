#!/bin/bash
# ===========================================
# Claude Code WSL Bridge - 桥接层独立安装脚本
# ===========================================
# 用法: chmod +x scripts/install-bridge.sh && ./scripts/install-bridge.sh
# 如果你已经安装了 Claude Code CLI，可以单独运行此脚本安装桥接层
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
echo "  Claude Code 桥接层安装"
echo "========================================"
echo ""
info "这个脚本将帮你安装协议桥接层，用于把 Claude Code"
info "的请求转发到第三方 API 供应商（DeepSeek、智谱等）。"
echo ""

# --- 选择桥接方案 ---
echo "请选择桥接方案："
echo ""
echo "  1) NervHub（推荐）— 功能完整，支持多模型路由、监控面板"
echo "  2) openclaudecode — 零配置，一条命令启动"
echo "  3) Claude Code Router — 按任务类型路由不同模型"
echo "  4) 跳过，稍后手动安装"
echo ""

read -p "请输入编号 [1-4] (默认 1): " BRIDGE_CHOICE
BRIDGE_CHOICE=${BRIDGE_CHOICE:-1}

case $BRIDGE_CHOICE in
    2)
        info "安装 openclaudecode..."
        npm install -g @bitkyc08/openclaudecode || true
        ok "安装完成！启动方式:"
        echo ""
        echo "  npx @bitkyc08/openclaudecode"
        echo ""
        echo "启动后监听在 http://127.0.0.1:11500"
        ;;

    3)
        info "安装 Claude Code Router..."
        npx @musistudio/claude-code-router init
        ok "安装完成！启动方式:"
        echo ""
        echo "  ccr start"
        echo ""
        echo "启动后监听在 http://127.0.0.1:11500"
        ;;

    4)
        info "已跳过桥接层安装"
        echo "你可以稍后选择以下任一方案："
        echo "  nervhub init                        # NervHub"
        echo "  npx @bitkyc08/openclaudecode        # openclaudecode"
        echo "  npx @musistudio/claude-code-router init  # CCR"
        ;;

    1|*)
        info "安装 NervHub..."
        npm install -g nervhub 2>/dev/null || {
            warn "npm 安装失败，npx 方式可用"
        }
        ok "NervHub 安装完成！"
        echo ""
        echo "首次使用请运行配置向导:"
        echo "  nervhub init"
        echo ""
        echo "启动桥接层:"
        echo "  nervhub start"
        echo ""
        echo "NervHub 默认监听 http://127.0.0.1:11500"
        ;;
esac

# --- 配置 Claude Code 使用代理 ---
echo ""
info "配置 Claude Code 使用本地代理..."

if command -v claude &>/dev/null; then
    claude config set proxy http://127.0.0.1:11500/anthropic 2>/dev/null || true
    ok "Claude Code 代理已配置"

    # 也写入 .bashrc 作为持久化
    if ! grep -q "ANTHROPIC_BASE_URL" ~/.bashrc 2>/dev/null; then
        echo "" >> ~/.bashrc
        echo "# Claude Code WSL Bridge - 本地代理" >> ~/.bashrc
        echo "export ANTHROPIC_BASE_URL=http://127.0.0.1:11500" >> ~/.bashrc
    fi
else
    warn "未检测到 Claude Code，跳过代理配置"
    echo "安装 Claude Code: npm install -g @anthropic-ai/claude-code"
fi

echo ""
echo "========================================"
echo -e "  ${GREEN}桥接层安装完成！${NC}"
echo "========================================"
echo ""
echo "快速验证:"
echo "  1. 启动桥接层（按你选择的方案启动）"
echo "  2. claude '你好'"
echo ""
echo "========================================"
