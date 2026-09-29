# MoonRFB 验收指南

本文件按 2026 年 9 月验收要求整理，命令在仓库根目录执行。项目使用 MoonBit 作为协议核心的主要实现语言；Node.js 只承担三个 TCP 示例和独立对标脚本，不承担 RFB 协议实现。

## 1. MoonBit 与编译器版本

要求：`moonc >= 0.10.14`。

```sh
python tools/check-moonc-version.py
moon version --all
```

仓库 CI 安装官方最新工具链，并在任何检查前执行版本门槛脚本。脚本会解析 `moon version --all`，低于 0.10.14 直接失败。当前本地复验版本为 `moonc v0.10.14+7d59c7ec9`。

## 2. 公开仓库与提交记录

GitHub：<https://github.com/Zh666-lab/moonrfb>

主分支为 `main`，提交按 wire、像素格式、认证、帧缓冲、编码、会话、示例、差分测试、基准和 CI 等工程切片组织。提交审计见 `docs/competition/commit-audit.md`，不依靠空提交或重复提交凑数量。

## 3. 源码结构与核心能力

- `wire.mbt`：有界字节读取与结构化错误。
- `handshake.mbt`、`des.mbt`：RFB 版本协商、认证与 VNC challenge-response。
- `pixel.mbt`、`framebuffer.mbt`：真彩色格式校验、RGB 归一化、拥有式帧缓冲。
- `trle.mbt`、`server.mbt`：Raw、CopyRect、TRLE、光标、桌面尺寸与剪贴板事件。
- `client.mbt`、`messages.mbt`：无 I/O 会话状态机和键鼠/更新请求序列化。
- `bridge/`、`examples/`：Node TCP 适配，仅作为可运行集成样例。

未声明支持 Zlib/ZRLE/Tight、TLS/VeNCrypt、RRE/Hextile、索引色和 GUI。

## 4. README、安装、使用与示例

README 已包含目标、安装、公开 API 使用方式、边界和复现命令。三个示例均连接自行启动的 `127.0.0.1` 受控服务端：

```sh
moon build --target js --deny-warn
npm ci --ignore-scripts --no-audit --no-fund
npm run examples
```

`capture` 验证 4 个像素并生成 PPM；`input` 验证 5 条输入/剪贴板消息、38 字节；`replay` 按最多 3 字节分片验证 Raw、CopyRect、TRLE 三帧和 12 个像素结果。

## 5. 持续集成

`.github/workflows/ci.yml` 使用 GitHub Actions 矩阵覆盖 `wasm-gc`、`wasm`、`js`、`native`，每个目标都执行 `fmt --check`、版本门槛、`check`、`build`、`test`。JS job 额外执行三个 TCP 示例、noVNC 差分、TRLE 语料、Rust DES 对比和基准，并上传测量产物。

## 6. 核心测试

当前白盒测试共 26 项，覆盖握手每个分片位置、认证已知答案、像素格式、Raw、CopyRect、TRLE 调色板/游程、光标、尺寸变化、队列上限和异常输入。noVNC 对比 1,350 组为零差异，原始 Rust DES 对比 1,000 组为零差异，独立 TRLE 语料 442 组有效加 6 组异常输入全部通过。

本机没有 C 编译器时不要把 native 运行测试记为本地通过；CI Linux job 是 native 运行测试的验收证据。当前仓库的 CI 结果见 GitHub Actions 页面。

## 7. MoonCakes

包名为 `Zh666-lab/moonrfb`，版本 `0.1.0`，MIT，已发布到 MoonCakes：<https://mooncakes.io/docs/Zh666-lab/moonrfb@0.1.0>。

发布后的独立消费者使用 `moon add Zh666-lab/moonrfb@0.1.0` 下载精确版本，并在 `wasm-gc`、`js` 各运行 1 项公共 API 测试。后续源代码改动按用户要求暂不重新同步 MoonCakes；只需继续上传 GitHub，新的版本发布前再重新执行发布和消费者验证。

## 8. 许可证与移植合规

项目使用 MIT，见 `LICENSE`。移植来源为 `HsuJv/vnc-rs` 0.5.3，原项目为 MIT OR Apache-2.0；来源映射、保留声明、改动和未移植范围见 `THIRD_PARTY.md`。noVNC 1.7.0 仅作为开发期差分参考，不进入 MoonBit 运行包。

## 一键复核

```sh
python tools/check-moonc-version.py
moon fmt --check
moon check --target wasm-gc --deny-warn
moon build --target wasm-gc --deny-warn
moon test --target wasm-gc --deny-warn
npm ci --ignore-scripts --no-audit --no-fund
npm run examples
```

完整 JS/Rust 对标和有本地 native 编译器时的完整验证见 `tools/verify.py`；无本地 native 编译器时可使用明确的 `--defer-native --defer-rust`，不能隐瞒这两个限制。
