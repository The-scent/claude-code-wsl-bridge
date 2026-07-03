# 🚀 Claude Code WSL Bridge

> **中文**：一键在 WSL 中部署 Claude Code，并集成 VS Code 图形界面——无需手动配置环境（可以直接在桌面上像 App 那样操作，更清晰更方便），克隆即用，开箱即跑。  
> **English**：One-command deployment of Claude Code inside WSL with VS Code GUI integration – zero manual setup, clone and run.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Windows%2011%20%7C%20macOS%20%7C%20Linux-blue)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

---

## 📖 项目简介 / Introduction

你是不是也遇到过这些情况：
- 想用 Claude Code，但被官方账号注册、订阅、KYC 实名认证卡住？
- 好不容易装上了，却发现只能在黑漆漆的终端里敲命令，操作起来不够顺手？
- 想接入 DeepSeek 或 Kimi，却不知道从哪里改配置？

**这个项目就是为了解决这些痛点而生的。**

它把 **Claude Code（开源版/缝合版）** + **WSL（运行环境）** + **VS Code（图形界面）** 打包成一个完整的解决方案。你只需要克隆仓库、运行一条命令，就能在 Windows 桌面上得到一个"长得像 App"的 AI 编程助手。

---

## ✨ 特性 / Features

- **⚡ 一键部署**：运行一个脚本，自动检测 WSL 环境、安装依赖、配置 Claude Code，无需手动折腾。
- **🖥️ 桌面级交互**：通过 VS Code 的图形界面操作 AI，支持文件树浏览、代码高亮、终端集成，比纯黑窗口舒服十倍。
- **🌐 模型自由**：内置 DeepSeek、OpenAI、Kimi、智谱、OpenRouter 等多种 API 配置模板，填入 Key 即可切换，不被 Anthropic 官方账号绑定。
- **🧩 零环境污染**：所有依赖封装在 WSL 子系统内，不影响 Windows 宿主机环境，卸载即清理。
- **📂 项目模板就绪**：仓库已配置好 `.gitignore` 和目录结构，方便你在此基础上继续开发自己的 Agent 工具链。

---

## 📋 前置条件 / Prerequisites

在开始之前，请确保你的电脑满足以下要求：

- **操作系统**：Windows 11（版本 22H2 或更高），已安装 **WSL2**。
  - *如果你还没装 WSL，可以参考 [Microsoft 官方教程](https://learn.microsoft.com/zh-cn/windows/wsl/install) 进行安装。*
- **VS Code**：已安装最新版，并且安装了 **Remote - WSL** 扩展（在 VS Code 扩展商店搜索即可安装）。
- **网络**：能够正常访问 GitHub 和你的 API 供应商接口（如 DeepSeek/OpenAI）。
- **API Key**：至少准备一个兼容 OpenAI 格式的 API Key（DeepSeek、智谱、Kimi 等都支持）。

---

## 🚀 三种安装方式（任选其一）

本项目针对 Windows 系统提供了三种安装方案，你可以根据自己的偏好选择。

### 方案一：使用本地 AI Agent 自动安装（推荐，最省心）

你可以利用已经部署在本地的人工智能助手（如 **OpenCowork**、**国产 Agent**（如 智谱Agent、文心一言Agent 等））来帮你执行安装命令。只需将本仓库的链接或本 README 内容提供给 Agent，它就能自动读取并逐条执行以下命令。

**操作示例（以 OpenCowork 为例）**：
1. 打开你的 OpenCowork 对话窗口。
2. 输入以下指令：
   ```
   请帮我根据 https://github.com/The-scent/claude-code-wsl-bridge 这个仓库的说明，在我的 Windows 11 系统上完成安装。
   ```
3. Agent 会自动检测你的 WSL 状态、安装依赖、配置环境变量，并提示你输入 API Key。
4. 全程无需手动敲命令，等待 Agent 完成即可。

**注意事项**：
- 请确保你的 Agent 具备执行 Shell 命令的权限（如 OpenCowork 默认支持）。
- 如果 Agent 遇到权限问题，请以管理员身份运行它的宿主程序。

---

### 方案二：使用大语言模型（DeepSeek / 豆包）指导安装

如果你没有本地 Agent，也可以使用任何一款免费或付费的大语言模型（如 **DeepSeek**、**豆包**、**Kimi** 等）来获取实时指导。

**操作步骤**：
1. 打开你常用的 LLM 聊天界面（如 DeepSeek 网页版）。
2. 将本仓库的 URL（`https://github.com/The-scent/claude-code-wsl-bridge`）粘贴给模型，并提问：
   > "请按以下步骤指导我在 Windows 11 上安装这个项目，给出详细的命令和解释。"
3. 模型会分步给出指令，你只需逐条复制粘贴到 PowerShell 或 CMD 中执行即可。
4. 如果执行过程中遇到错误，可以直接把错误信息复制给模型，它会帮你分析并提供解决方案。

**优点**：无需额外安装软件，有浏览器就能用。
**缺点**：需要手动复制命令，且无法自动处理依赖冲突（但模型会提示你解决）。

---

### 方案三：纯手动安装（详细步骤）

如果你喜欢完全掌控每一步，可以按照以下步骤手动完成。

#### Step 1：安装 WSL2 和 Ubuntu
- 以管理员身份打开 PowerShell，执行：
  ```powershell
  wsl --install
  ```
- 重启电脑后，从 Microsoft Store 安装 Ubuntu 22.04 LTS。
- 启动 Ubuntu，创建用户名和密码。

#### Step 2：安装 VS Code 及 Remote-WSL 插件
- 下载安装 [VS Code](https://code.visualstudio.com/)。
- 在扩展商店搜索 "Remote - WSL" 并安装。

#### Step 3：克隆本仓库到 WSL
- 在 Ubuntu 终端中执行：
  ```bash
  git clone https://github.com/The-scent/claude-code-wsl-bridge.git
  cd claude-code-wsl-bridge
  ```

#### Step 4：运行一键安装脚本
- 在项目根目录执行：
  ```bash
  chmod +x scripts/setup.sh
  ./scripts/setup.sh
  ```
- 脚本会自动安装 Python、Node.js、以及 Claude Code 所需的依赖。

#### Step 5：配置环境变量
- 复制 `.env.example` 为 `.env`：
  ```bash
  cp .env.example .env
  ```
- 用 `nano` 或 `vim` 编辑 `.env`，填入你的 API Key。

#### Step 6：启动 VS Code 并验证
- 在 WSL 终端中执行 `code .`，VS Code 会自动连接到 WSL 远程。
- 按 `` Ctrl+` `` 打开终端，输入 `claude "你好"`，若返回回复则安装成功。

---

## 🗂️ 项目结构 / Project Structure

```
claude-code-wsl-bridge/
├── scripts/
│   └── setup.sh          # 一键安装脚本
├── configs/
│   └── wsl.conf          # WSL 推荐配置模板
├── .env.example          # 环境变量模板
├── .gitignore            # 忽略规则（已排除 .env）
├── LICENSE               # MIT 协议
└── README.md             # 你现在看到的这个文件
```

---

## 🛠️ 常见问题 / FAQ

**Q：为什么我运行 `claude` 命令提示"找不到"？**  
A：可能是脚本执行后没有刷新环境变量，请尝试关闭 VS Code 终端并重新打开，或重启 WSL（在 PowerShell 中执行 `wsl --shutdown` 后重开）。

**Q：可以用 GPU 加速吗？**  
A：可以。如果你安装了 CUDA 驱动，WSL 默认支持 GPU 直通，Claude Code 内部的模型推理（如本地 Ollama）会自动启用。

**Q：我想换成 Kimi 或者智谱，怎么改？**  
A：修改 `.env` 中的 `MODEL_PROVIDER` 和对应的 `API_KEY` 即可，项目已内置了常见的供应商端点配置。

**Q：这个项目和官方的 Claude Code 有什么关系？**  
A：本项目是基于开源社区逆向/重构的 Claude Code 核心功能进行封装的，**不依赖 Anthropic 官方账号**，所有 API 调用走的是通用 OpenAI 兼容接口。

---

## 🤝 如何贡献 / Contributing

欢迎提交 Issue 和 Pull Request！如果你有更好的配置模板或自动化脚本，请随时分享。

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的改动 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

---

## 📄 许可证 / License

本项目采用 **MIT License** 开源协议。你可以自由使用、修改、分发，但请保留版权声明。详见 [LICENSE](LICENSE) 文件。

---

## 🙏 致谢 / Acknowledgements

- 感谢 Claude Code 开源社区的无私分享。
- 感谢 WSL 和 VS Code 提供了完美的开发体验。
- 特别感谢你——愿意折腾技术的探索者！😎
