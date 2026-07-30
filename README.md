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

## 📋 前置条件速查

> ⚠️ **重要**：在开始安装之前，请确保以下软件已安装。如果你还没有，点击链接下载安装。

| # | 软件 | 必须？ | 下载链接 | 说明 |
|---|------|--------|---------|------|
| 1 | **Windows 11** | ✅ 必须 | — | 版本 22H2 或更高（开始菜单 → 设置 → 系统 → 系统信息 查看） |
| 2 | **WSL2 + Ubuntu** | ✅ 必须 | [WSL 官方安装指南](https://learn.microsoft.com/zh-cn/windows/wsl/install) | ✅ 见下方第一步安装 |
| 3 | **VS Code** | ✅ 推荐 | [下载 VS Code](https://code.visualstudio.com/Download) | 可选但强烈推荐，装完后获得桌面图形界面 |
| 4 | **Remote - WSL 扩展** | ✅ 推荐 | [VS Code 扩展商店 → Remote-WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) | 在 VS Code 扩展商店搜索 "Remote-WSL" 安装 |
| 5 | **Git** | ✅ 必须 | [Git for Windows 下载](https://git-scm.com/download/win) | ✅ setup.sh 可在 WSL 内自动安装，但 Windows 上也需要 |
| 6 | **Node.js 22+** | ✅ 必须 | [Node.js 官网下载](https://nodejs.org/) | ✅ setup.sh 可自动安装，但你也可以提前装好 |

### 💡 没有 API Key？
- **[DeepSeek 官网注册](https://platform.deepseek.com/)** → 新用户送 500 万免费 token，够用很久
- **[硅基流动](https://cloud.siliconflow.cn/)** → 国内镜像，DeepSeek / Qwen 等模型都能用，无需翻墙
- **Ollama 本地模型** → 完全免费，但需要电脑配置够好

---

## 🚀 完整安装流程（照着做就行）

**前置步骤**：先安装 WSL + Ubuntu（如果还没装），在 Windows PowerShell 以管理员身份运行：
```powershell
wsl --install -d Ubuntu
```
> 重启后打开 Ubuntu，设置 Linux 用户名密码。详见 [WSL 官方安装指南](https://learn.microsoft.com/zh-cn/windows/wsl/install)

---

### 准备好了？选一种方式开始安装

在 WSL Ubuntu 终端中执行：

<details>
<summary><b>⭐ 方案 A：一条命令搞定（推荐）</b></summary>

无需克隆仓库，一条命令直接下载并运行安装脚本：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/The-scent/claude-code-wsl-bridge/main/scripts/setup.sh)
```

> 如果网络慢，用国内镜像：
> ```bash
> bash <(curl -fsSL https://ghproxy.net/https://raw.githubusercontent.com/The-scent/claude-code-wsl-bridge/main/scripts/setup.sh)
> ```

安装完成后跳到 **第四步** 配置供应商。

</details>

<details>
<summary><b>方案 B：先克隆再安装</b></summary>

```bash
cd ~ && git clone https://github.com/The-scent/claude-code-wsl-bridge.git && cd claude-code-wsl-bridge && chmod +x scripts/setup.sh && ./scripts/setup.sh
```

或者分步执行：
```bash
cd ~
git clone https://github.com/The-scent/claude-code-wsl-bridge.git
cd claude-code-wsl-bridge
chmod +x scripts/setup.sh
./scripts/setup.sh
```

网络慢用国内加速：
```bash
git clone https://ghproxy.net/https://github.com/The-scent/claude-code-wsl-bridge.git
```
</details>

脚本自动完成：
1. ✅ 检查网络连通性
2. ✅ 安装 Node.js 22+（如果没装）
3. ✅ 安装 git、curl 等系统工具
4. ✅ 全局安装 `@anthropic-ai/claude-code`（Claude Code CLI）
5. ✅ 安装 **NervHub**（协议桥接层）
6. ✅ 创建 `.env` 配置文件
7. ✅ 配置 Claude Code 代理指向 `127.0.0.1:11500`
8. ✅ 添加环境变量到 `~/.bashrc`

> 💡 卡住了？常见原因及解决：
> - 网络问题：`export HTTP_PROXY=http://127.0.0.1:7890 && export HTTPS_PROXY=http://127.0.0.1:7890` 再重试
> - 提示 `command not found`：先装 `sudo apt install -y curl`

脚本会自动完成：

1. ✅ 检查网络连通性
2. ✅ 安装 Node.js 22+（如果没装）
3. ✅ 安装 git、curl 等系统工具
4. ✅ 全局安装 `@anthropic-ai/claude-code`（**Claude Code CLI**）
5. ✅ 安装 **NervHub**（协议桥接层）
6. ✅ 创建 `.env` 配置文件
7. ✅ 配置 Claude Code 代理指向 `127.0.0.1:11500`
8. ✅ 添加环境变量到 `~/.bashrc`

> 💡 如果安装过程中卡住，可能是网络问题，可以设置代理后重试：
> ```bash
> export HTTP_PROXY=http://127.0.0.1:7890
> export HTTPS_PROXY=http://127.0.0.1:7890
> ```

---

### 第四步：配置模型供应商

安装完成后，执行配置向导：

```bash
nervhub init
```

按提示选择供应商（`deepseek` / `zhipu` / `kimi` / `ollama` 等），输入你的 API Key。

> 💡 使用 DeepSeek 的示例：
> ```
> ? Which provider? deepseek
> ? API Key: sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
> ? Base URL: (https://api.deepseek.com/v1) ← 直接回车保持默认
> ```

---

### 第五步：启动桥接层并验证

```bash
# 启动 NervHub（桥接层）
nervhub start

# 测试 Claude Code
claude "你好，请用 Python 写一个冒泡排序"
```

看到返回代码和解释，就成功了！🎉

> 如果 `claude: command not found`，执行：
> ```bash
> source ~/.bashrc
> ```

---

### 第六步（可选）：启动 VS Code 图形界面

```bash
code .
```

VS Code 会自动通过 Remote-WSL 连接到 WSL 环境。按 `` Ctrl+` `` 打开终端，直接使用 `claude` 命令。

> 用 VS Code 的好处：文件树浏览、代码高亮、多标签页操作，就像在用本地 IDE 一样。

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

示例配置（同时配置多个供应商）：

```yaml
providers:
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

重启 NervHub 生效：`nervhub restart`

---

## ❓ 常见问题

### 安装相关

**Q：一定要用 WSL 吗？**

是的。Claude Code CLI 目前原生支持 Linux/macOS，Windows 用户需要通过 WSL 运行。这是官方推荐的方案。

**Q：WSL 安装失败怎么办？**

参考微软官方文档：[手动安装 WSL](https://learn.microsoft.com/zh-cn/windows/wsl/install-manual)

常见问题：
- **BIOS 虚拟化未开启**：重启进 BIOS 开启 Intel VT-x 或 AMD SVM
- **需要 Hyper-V 组件**：控制面板 → 启用或关闭 Windows 功能 → 勾选"Hyper-V"和"虚拟机平台"
- **WSL 2 要求**：Windows 11 默认支持，Windows 10 需要 2004 版本以上

**Q：`git clone` 还是报错？**

```bash
# 试一下国内加速代理
git clone https://ghproxy.net/https://github.com/The-scent/claude-code-wsl-bridge.git
# 或者直接下载 zip 后再解压
wget https://github.com/The-scent/claude-code-wsl-bridge/archive/refs/heads/main.zip
unzip main.zip -d claude-code-wsl-bridge
```

**Q：必须用 NervHub 吗？能不能用更轻量的方案？**

可以。`openclaudecode` 是一个零配置方案，一条命令启动：

```bash
npx @bitkyc08/openclaudecode
# 默认监听 11500 端口
```

### 运行时问题

**Q：`claude: command not found`？**

```bash
# 刷新环境变量
source ~/.bashrc
# 或重新登录 WSL（exit 退出，再重新打开）
```

如果还没装：
```bash
npm install -g @anthropic-ai/claude-code
```

**Q：API 调用失败怎么办？**

1. 检查 API Key 是否正确：`echo $API_KEY`
2. 检查 NervHub 是否运行：`curl http://127.0.0.1:11500/health`
3. 查看 NervHub 日志：`~/.nervhub/logs/`
4. 确认余额充足

**Q：能用本地模型（Ollama）吗？**

可以。在 WSL 中安装 Ollama：

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull qwen3:35b
```

然后在 NervHub 中配置 ollama 供应商。注意本地模型能力远不如云端 API，适合简单任务。

**Q：和 Anthropic 官方 Claude Code 是什么关系？**

Claude Code CLI 是 Anthropic 官方开源的工具。本项目使用官方的 CLI，但通过桥接层将 API 请求路由到你选择的第三方供应商，**不需要 Anthropic 的 API Key 或订阅**。

**Q：可以和其他 AI 工具（如 Cursor、Continue）共用 API Key 吗？**

可以。桥接层不影响其他工具使用同一个 API Key。

### 网络相关

**Q：WSL 里需要开代理吗？**

如果从国内访问 npm / GitHub 很慢，需要在 WSL 中设置代理：

```bash
# 假设你的 Windows 代理在 127.0.0.1:7890
export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
# 也可以加到 ~/.bashrc 永久生效
```

注意：WSL 里访问 Windows 本机用 `127.0.0.1`，不需要改 IP。

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
