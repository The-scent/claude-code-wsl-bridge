#!/bin/bash
# ===========================================
# Claude Code WSL Bridge - 一键安装脚本
# ===========================================
# 用法: chmod +x scripts/setup.sh && ./scripts/setup.sh
# 在 WSL Ubuntu 终端中运行
# ===========================================
# 前置条件（由本脚本自动检查/安装）：
#   - git, curl         ← apt 安装
#   - Node.js 22+       ← nodesource 安装
#   - @anthropic-ai/claude-code  ← npm 全局安装
#   - nervhub            ← npm 全局安装
# ===========================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${BLUE}[*]${NC} $1"; }
ok()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
err()   { echo -e "${RED}[✗]${NC} $1"; }
step()  { echo -e "\n${CYAN}━━━ $1 ━━━${NC}"; }

echo "========================================"
echo "  Claude Code WSL Bridge 安装脚本"
echo "  版本 2.0 — 2026-07"
echo "========================================"
echo ""

# ─────────────────────────────────────────
# 阶段 1：环境检查
# ─────────────────────────────────────────
step "1/8 环境检查"

# 检查是否以 root 运行
if [ "$EUID" = 0 ]; then
    warn "检测到以 root 用户运行，建议使用普通用户"
    warn "如果你正在使用 sudo，请改为: ./scripts/setup.sh"
fi

# 检查 WSL 环境
if grep -q microsoft /proc/version 2>/dev/null; then
    ok "WSL 环境检测通过"
    # 检查 WSL 版本
    if grep -qi "microsoft.*WSL2" /proc/version 2>/dev/null || grep -q "WSL2" /proc/version 2>/dev/null; then
        ok "WSL 2 已启用（推荐）"
    else
        warn "建议使用 WSL 2 以获得更好性能"
        warn "升级命令（在 PowerShell 中）：wsl --set-version Ubuntu 2"
    fi
else
    warn "未检测到 WSL 环境，脚本可能无法正常运行"
    warn "请确保在 WSL Ubuntu 终端中运行此脚本"
fi

# 检查磁盘空间（至少需要 500MB）
AVAIL_SPACE=$(df /home --output=avail 2>/dev/null | tail -1 || echo "0")
if [ "$AVAIL_SPACE" -gt 0 ] 2>/dev/null && [ "$AVAIL_SPACE" -lt 500000 ]; then
    warn "磁盘空间不足 500MB，安装可能失败"
    df -h /home
fi

# ─────────────────────────────────────────
# 阶段 2：网络连通性检查
# ─────────────────────────────────────────
step "2/8 网络连通性检查"

test_url() {
    local url=$1 name=$2
    if curl -s --connect-timeout 5 --max-time 8 -o /dev/null "$url"; then
        ok "$name 可达"
        return 0
    else
        warn "$name 不可达"
        return 1
    fi
}

NPM_OK=false
GITHUB_OK=false

test_url "https://registry.npmjs.org"     "npm 官方源"     && NPM_OK=true
test_url "https://registry.npmmirror.com" "npm 国内镜像"   || true
test_url "https://github.com"             "GitHub"          && GITHUB_OK=true
test_url "https://deb.nodesource.com"     "NodeSource 源"  || true

if [ "$NPM_OK" = false ]; then
    echo ""
    warn "⚠ 网络连接似乎有问题，常见原因及解决方法："
    echo ""
    echo "  1. 在 WSL 中设置代理（如果 Windows 上有代理软件）："
    echo "     export HTTP_PROXY=http://127.0.0.1:7890"
    echo "     export HTTPS_PROXY=http://127.0.0.1:7890"
    echo ""
    echo "  2. 如果不需要代理，尝试换 npm 镜像源："
    echo "     npm config set registry https://registry.npmmirror.com"
    echo ""
    echo "  3. 检查 WSL 网络："
    echo "     ping -c 3 8.8.8.8"
    echo ""
    read -p "按回车继续安装，或 Ctrl+C 退出后修复网络再试 ..."
fi

# ─────────────────────────────────────────
# 阶段 3：安装系统依赖
# ─────────────────────────────────────────
step "3/8 系统依赖检查与安装"

NEED_INSTALL=false
for cmd in curl git; do
    if ! command -v $cmd &>/dev/null; then
        warn "缺少 $cmd，将安装..."
        NEED_INSTALL=true
    else
        ok "$cmd 已安装"
    fi
done

# 检查 Node.js
if command -v node &>/dev/null; then
    NODE_MAJOR=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_MAJOR" -lt 22 ]; then
        warn "Node.js 版本 $(node --version)，需要 >= 22，将升级..."
        NEED_INSTALL=true
    else
        ok "Node.js $(node --version)（满足要求）"
    fi
else
    warn "未安装 Node.js，将自动安装 Node.js 22..."
    NEED_INSTALL=true
fi

if [ "$NEED_INSTALL" = true ]; then
    echo ""
    info "正在安装 Node.js 22+、git、curl..."

    # 确保 apt 可用
    if ! command -v apt &>/dev/null; then
        err "未检测到 apt 包管理器，请手动安装依赖"
        echo ""
        echo "  手动安装 Node.js 22+："
        echo "    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -"
        echo "    sudo apt-get install -y nodejs git curl"
        echo ""
        exit 1
    fi

    # 添加 NodeSource 仓库
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

    # 安装
    info "更新包列表..."
    sudo apt-get update -qq
    info "安装 nodejs git curl..."
    sudo apt-get install -y -qq nodejs git curl

    ok "系统依赖安装完成"
    ok "Node.js: $(node --version)"
    ok "npm:     $(npm --version)"
    ok "git:     $(git --version)"
fi

# ─────────────────────────────────────────
# 阶段 4：安装 Claude Code CLI
# ─────────────────────────────────────────
step "4/8 安装 Claude Code CLI"

if command -v claude &>/dev/null; then
    ok "Claude Code 已安装 ($(claude --version 2>/dev/null || echo '版本未知'))"
    info "如需更新: npm install -g @anthropic-ai/claude-code@latest"
else
    info "正在安装 Claude Code CLI（全局安装 @anthropic-ai/claude-code）..."
    echo ""
    echo "  这一步需要从 npm 下载，文件约 50MB，取决于网络速度"
    echo "  如果卡住不动，请检查网络或设置代理"
    echo ""
    npm install -g @anthropic-ai/claude-code
    ok "Claude Code CLI 安装完成"
    claude --version 2>/dev/null && ok "版本: $(claude --version 2>/dev/null)" || true
fi

# ─────────────────────────────────────────
# 阶段 5：安装 NervHub（协议桥接层）
# ─────────────────────────────────────────
step "5/8 安装协议桥接层 NervHub"

if command -v nervhub &>/dev/null; then
    ok "NervHub 已安装"
else
    info "正在安装 NervHub..."
    if npm install -g nervhub 2>/dev/null; then
        ok "NervHub 安装完成"
        nervhub --version 2>/dev/null && ok "版本: $(nervhub --version 2>/dev/null)" || true
    else
        warn "npm 全局安装失败，npx 方式同样可用"
        info "后续使用 nervhub init 时会自动下载"
    fi
fi

# ─────────────────────────────────────────
# 阶段 6：创建配置文件
# ─────────────────────────────────────────
step "6/8 配置文件"

# 创建 .env
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        ok ".env 文件已创建"
        info "稍后请运行 nervhub init 配置 API Key"
    else
        warn "未找到 .env.example 文件，跳过创建 .env"
    fi
else
    ok ".env 文件已存在"
fi

# ─────────────────────────────────────────
# 阶段 7：配置 Claude Code 代理
# ─────────────────────────────────────────
step "7/8 配置 Claude Code 代理"

if command -v claude &>/dev/null; then
    CURRENT_PROXY=$(claude config get proxy 2>/dev/null || echo "")
    if [ -z "$CURRENT_PROXY" ]; then
        claude config set proxy http://127.0.0.1:11500/anthropic 2>/dev/null || true
        ok "Claude Code 代理已配置 → http://127.0.0.1:11500/anthropic"
    else
        ok "Claude Code 代理已配置: $CURRENT_PROXY"
    fi
else
    warn "Claude Code 未安装，跳过代理配置"
    info "安装后执行: claude config set proxy http://127.0.0.1:11500/anthropic"
fi

# 添加环境变量到 .bashrc
if ! grep -q "ANTHROPIC_BASE_URL" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'EOF'

# Claude Code WSL Bridge - 本地代理
export ANTHROPIC_BASE_URL=http://127.0.0.1:11500
EOF
    ok "已添加 ANTHROPIC_BASE_URL 到 ~/.bashrc"
else
    ok "~/.bashrc 环境变量已配置"
fi

# ─────────────────────────────────────────
# 阶段 8：安装完成输出
# ─────────────────────────────────────────
step "8/8 安装完成！"

echo ""
echo -e "  ${GREEN}所有组件安装成功！${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📝 接下来需要配置模型供应商"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  第 1 步：配置 API Key"
echo "    nervhub init"
echo "    按提示选择供应商 (deepseek / zhipu / ollama ...)"
echo "    输入你的 API Key"
echo ""
echo "  第 2 步：启动桥接层"
echo "    nervhub start"
echo "    启动后 NervHub 监听 http://127.0.0.1:11500"
echo ""
echo "  第 3 步：测试 Claude Code"
echo "    claude '你好，请用 Python 写个冒泡排序'"
echo ""
echo "  第 4 步（可选）：启动 VS Code 图形界面"
echo "    code ."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📌 如果遇到问题"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  - claude: command not found → source ~/.bashrc"
echo "  - 网络慢 → 设置代理后再试"
echo "  - 其他问题 → 查看 README.md 的 FAQ 部分"
echo ""
echo "========================================"
