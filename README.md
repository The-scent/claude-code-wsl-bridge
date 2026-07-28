# 🚀 Claude Code WSL Bridge

> **中文**：在 WSL 中一键部署 Claude Code，并通过协议桥接层将其连接到任意兼容 OpenAI 的 API 供应商（DeepSeek / 智谱 / Kimi / Ollama 等）。附 VS Code 图形界面，克隆即用，开箱即跑。
>
> **English**：One-command deployment of Claude Code inside WSL, routed through a protocol bridge to any OpenAI-compatible API provider (DeepSeek, Zhipu, Kimi, Ollama, etc.) — with VS Code GUI integration. Clone and run.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Windows%2011-blue)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

---

## 📖 为什么需要这个项目？

在 Windows 上使用 AI 编程助手，常见的三个障碍：

| 问题 | 说明 | 本项目的方案 |
|------|------|-------------|
| **账号门槛** | Anthropic 官方需要海外支付方式，很多国内用户无法注册 | 不依赖 Anthropic 账号，通过桥接层接国产 API |
| **终端体验** | 纯 CLI 黑窗口操作不方便，没有文件树、代码高亮 | 集成 VS Code Remote-WSL，像本地 App 一样使用 |
| **模型绑定** | Claude Code 官方只认 Anthropic API，无法直接接 DeepSeek | 本地协议转换代理，把 Anthropic 协议翻译成 OpenAI 协议 |

### 架构总览

```
你的 Windows 桌面（VS Code 图形界面）
        ↕ Remote - WSL 扩展
WSL Ubuntu 子系统
  ├── Claude Code CLI        ← AI 编程代理（官方 CLI）
  │       ↕ 127.0.0.1:11500
  ├── 协议桥接层              ← 协议转换代理（NervHub / openclaudecode）
  │       ↕ HTTPS + API Key
  └── DeepSeek / 智谱 / Kimi / Ollama ...  ← 你选择的供应商
```

---

## ✨ 特性

- **⚡ 一键部署**：运行一个脚本，自动安装 Node.js、Claude Code CLI、协议桥接层。
- **🖥️ 桌面级体验**：VS Code 图形界面，文件树、代码高亮、终端集成一应俱全。
- **🌐 模型自由**：DeepSeek、智谱 GLM、Kimi、Ollama 本地模型，想用哪个用哪个。
- **🔌 真正的桥接**：完整的协议转换（Anthropic Messages API ↔ OpenAI Chat API），流式输出、Tool Use、文件编辑都能正常工作。
- **🧩 零污染**：所有依赖在 WSL 子系统内，不影响 Windows 宿主机。
- **💰 低成本**：DeepSeek 百万 token 只要几块钱，无需 Anthropic 订阅。

---

## 📋 前置条件

- **系统**：Windows 11（22H2 或更高），已安装 [WSL2](https://learn.microsoft.com/zh-cn/windows/wsl/install)
- **VS Code**：已安装最新版 + **Remote - WSL** 扩展（扩展商店搜索安装）
- **API Key**：至少一个兼容 OpenAI 格式的 API Key

> 💡 没有 API Key？去 [DeepSeek 官网](https://platform.deepseek.com/) 注册，新用户通常有免费额度。
> 或者如果你想用本地模型，安装 [Ollama](https://ollama.com/) 也可以，完全免费。

---

## 🚀 快速安装

### 第一步：安装 WSL 和 Ubuntu

```powershell
# Windows PowerShell（以管理员身份运行）
wsl --install -d Ubuntu
```

安装后重启电脑，启动 Ubuntu，设置用户名和密码。

### 第二步：一键安装

在 **WSL Ubuntu 终端** 中执行：

```bash
# 克隆仓库
cd ~
git clone https://github.com/The-scent/claude-code-wsl-bridge.git
cd claude-code-wsl-bridge

# 运行一键安装脚本
chmod +x scripts/setup.sh
./scripts/setup.sh
```

脚本会自动完成：
1. ✅ 安装 Node.js 22+ 和必备工具
2. ✅ 全局安装 Claude Code CLI
3. ✅ 安装协议桥接层 NervHub
4. ✅ 创建配置文件

### 第三步：配置模型供应商

运行桥接层初始化向导：

```bash
nervhub init
# 按提示选择供应商（deepseek / openai / ollama ...）
# 输入你的 API Key
# 其余保持默认即可
```

启动桥接层：

```bash
nervhub start
# 启动后 NervHub 监听在 http://127.0.0.1:11500
```

### 第四步：配置 Claude Code 并验证

```bash
# 设置 Claude Code 使用本地代理
claude config set proxy http://127.0.0.1:11500/anthropic

# 测试
claude "你好，请用 Python 写一个冒泡排序"
```

看到返回代码和解释，就成功了！🎉

### 第五步（可选）：启动 VS Code GUI

```bash
code .
```

VS Code 会自动通过 Remote-WSL 连接到 WSL 环境。按 `` Ctrl+` `` 打开终端，直接使用 `claude` 命令。

---

## 🔧 替换桥接层

除了 NervHub，你也可以使用以下方案之一：

| 方案 | 一句话描述 | 安装命令 |
|------|-----------|---------|
| **NervHub** ⭐ | 功能最全，支持多模型路由、负载均衡、可视化面板 | `npm install -g nervhub && nervhub init` |
| **openclaudecode** | 零配置，启动即用，适合快速尝鲜 | `npx @bitkyc08/openclaudecode` |
| **Claude Code Router** | 按任务类型路由（耗时任务走便宜模型） | `npx @musistudio/claude-code-router init` |
| **CCPG** | 有桌面图形界面，点几下鼠标就配好 | [GitHub 下载](https://github.com/danielalves96/claude-code-provider-gateway) |

无论用哪个，原理都是：**启动一个本地代理监听 11500 端口，然后把 Claude Code 指向它**。

---

## 🌐 配置其他模型

NervHub 启动后，编辑配置文件添加更多供应商：

```bash
nano ~/.nervhub/config.yaml
```

示例配置：

```yaml
providers:
  # 默认供应商
  default: deepseek

  deepseek:
    api_key: sk-your-deepseek-key
    base_url: https://api.deepseek.com/v1
    models:
      - deepseek-chat       # 通用对话
      - deepseek-reasoner   # 推理模型

  zhipu:
    api_key: your-zhipu-key
    base_url: https://open.bigmodel.cn/api/paas/v4
    models:
      - glm-4-plus

  ollama:
    base_url: http://localhost:11434/v1
    models:
      - qwen3:35b
      - llama3:70b
```

重启 NervHub 生效：

```bash
nervhub restart
```

---

## ❓ 常见问题

**Q：一定要用 WSL 吗？**

是的。Claude Code CLI 目前原生支持 Linux/macOS，Windows 用户需要通过 WSL 运行。这是官方推荐的方案。

**Q：必须用 NervHub 吗？能不能用更轻量的方案？**

当然可以。`openclaudecode` 是一个零配置的 npm 包，一条命令启动：

```bash
npx @bitkyc08/openclaudecode
# 默认监听 11500 端口，Claude Code 直接指向它即可
```

**Q：能用本地模型（Ollama）吗？**

可以。在 WSL 中安装 Ollama：

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull qwen3:35b
```

然后在 NervHub 或 openclaudecode 中配置 ollama 供应商。注意本地模型的能力远不如云端 API，适合简单任务。

**Q：报错 `claude: command not found`？**

```bash
# 刷新环境变量
source ~/.bashrc
# 或重新登录 WSL
```

如果还没装：
```bash
npm install -g @anthropic-ai/claude-code
```

**Q：和 Anthropic 官方 Claude Code 是什么关系？**

Claude Code CLI 是 Anthropic 官方开源的工具。本项目使用官方的 CLI，但通过桥接层将 API 请求路由到你选择的第三方供应商，**不需要 Anthropic 的 API Key 或订阅**。

**Q：API 调用失败怎么办？**

1. 检查 API Key 是否正确：`echo $API_KEY`
2. 检查 NervHub 是否运行：`curl http://127.0.0.1:11500/health`
3. 查看 NervHub 日志：`~/.nervhub/logs/`
4. 确认余额充足

**Q：可以和其他 AI 工具（如 Cursor、Continue）共用 API Key 吗？**

可以。桥接层不影响其他工具使用同一个 API Key。

---

## 🗂️ 项目结构

```
claude-code-wsl-bridge/
├── scripts/
│   ├── setup.sh            # 一键安装脚本（推荐）
│   └── install-bridge.sh   # 独立安装桥接层（可选）
├── configs/
│   └── wsl.conf            # WSL 推荐配置模板
├── .env.example            # 环境变量模板
├── .gitignore
├── LICENSE                 # MIT
└── README.md               # 就是本文件
```

---

## 🤝 贡献

欢迎 Issue 和 PR！

1. Fork 本仓库
2. `git checkout -b feature/your-feature`
3. `git commit -m 'Add your feature'`
4. `git push origin feature/your-feature`
5. 打开 Pull Request

---

## 📄 许可证

MIT License。详见 [LICENSE](LICENSE)。

---

## 🙏 致谢

- [NervHub](https://github.com/LostAbaddon/NervHub) — 智能 LLM API 网关
- [openclaudecode](https://www.npmjs.com/package/@bitkyc08/openclaudecode) — 轻量协议转换代理
- [Claude Code](https://github.com/anthropics/claude-code) — Anthropic 开源的 AI 编程代理
- WSL 和 VS Code 团队 — 完美的开发体验
