# MoonRFB

将 Rust **vnc-rs 0.5.3** 的 VNC/RFB 客户端协议核心移植到 MoonBit。不是调用 Rust 或系统 VNC 程序的包装：协商、DES 认证、像素解码和输入消息都在 MoonBit 中运行。应用只需提供字节传输与画面显示。

适合给 MoonBit 测试工具、设备管理界面或远程画面采集程序提供 RFB 接入能力。它是协议库，不是完整远控软件。

## 支持范围

- RFB 3.3 / 3.7 / 3.8；VNC challenge-response；无认证连接必须显式允许。
- 8/16/32 位 true-color 像素，统一输出 RGB；Raw、CopyRect、TRLE（16×16 tile）。
- Cursor、DesktopSize、Bell、双向剪贴板消息；键盘、鼠标和更新请求序列化。
- 可分片输入、完整更新事务后提交、长度/坐标/队列限制；错误后会话终止。
- 核心无第三方 MoonCakes 依赖，目标 wasm-gc、wasm、js、native。Node TCP 适配仅用于示例。

**不支持** Zlib/ZRLE/Tight、RRE/Hextile、TLS/VeNCrypt、索引色、文件传输或完整 GUI。传统 VNC 密码认证不加密画面，不能直接当作公网安全方案。

## 安装与接入

发布后运行 `moon add Zh666-lab/moonrfb@0.1.0`，在调用包的 `moon.pkg` 中导入 `"Zh666-lab/moonrfb" @rfb`。

```moonbit
fn new_session() -> @rfb.Client raise @rfb.RfbError {
  @rfb.client(options={ ..@rfb.default_options(), password: Some([115, 101, 99, 114, 101, 116]) })
}
```

每次收到网络数据，转换为 0..255 的 `Array[Int]` 并调用 `session.feed(bytes)`；随后把 `take_output()` 的字节写回连接，消费 `take_events()`。Ready 后发送 `update_request`，UpdateComplete 后用 `snapshot()` 取每个像素为 0xRRGGBB 整数的画面。结束输入时调用 `finish()`，截断协议会报错。不要把密码硬编码在真实程序里。

完整公开签名见 `pkg.generated.mbti`；状态机和适配约定见 `docs/architecture.md`。

## 三个可运行示例

需要 MoonBit 工具链及 Node.js 24；示例仅连接自行启动的 127.0.0.1 随机端口服务端。

```sh
moon build --target js --deny-warn
npm run examples
# 或分别运行
node examples/capture.cjs
node examples/input.cjs
node examples/replay.cjs
```

1. **画面采集**：完成 TCP 握手，读入 2×2 Raw 画面，核对全部 4 个像素，生成 `output/desktop.ppm`。
2. **键鼠回环**：服务端逐字节校验 Enter 按下/释放、鼠标按下/释放和剪贴板，共 5 条消息、38 字节。
3. **连续帧重建**：网络流按 3 字节切片送入，验证 Raw → CopyRect → TRLE 三帧、12 次像素比较。

这些是受控协议服务端测试，不冒充 TigerVNC 桌面互操作测试。

## 质量验证

```sh
moon test --target wasm-gc --deny-warn
npm ci --ignore-scripts
node tools/differential.cjs
node tools/trle-corpus.cjs
node tools/upstream-differential.cjs # 需要 rustc，编译原版 Rust DES
node tools/benchmark.cjs
python tools/verify.py # 完整检查；可显式 --defer-native --defer-rust
```

| 对标或测量 | 已取得的本地结果 |
|---|---|
| MoonBit 单元/边界测试 | 26 项，wasm-gc / wasm / js 通过；native 在 Linux CI 构建与测试通过 |
| noVNC 1.7.0 原版模块 | DES 1,000 组、Raw 250 组/41,505 像素、CopyRect 100 组/400 像素，差异为 0 |
| 独立 RFC 6143 TRLE 编码语料 | 442 组有效样本/32,555 像素；另有 6 组畸形输入，全部通过 |
| 640×480 Raw 解码 | 本地 JS debug，预热 5 次、测量 30 次：中位 6.75 ms，P95 8.01 ms，45.49 Mpix/s |

基准环境：Windows x64、Node 24.14.0、i7-13650HX。包含 RGB 输出分配，不与别的软件做不同环境的速度排名；RSS 只是进程内存，**不是解码峰值内存**。测量快照见 `docs/evidence/`，可复现实验在 `tools/`。CI 已编译原始 Rust DES 比较 1,000 组（零差异），四目标构建及测试全部通过。首个完整绿灯运行：34988527766；最终发布提交请查看 Actions。

## 移植与许可

上游 HsuJv/vnc-rs 0.5.3（MIT OR Apache-2.0，本项目采用 MIT 选项）。从 Tokio 模型改为有界 sans-I/O 状态机；TRLE 按 RFC 6143 修正 tile 尺寸、长度前缀及调色板复用。文件对应关系和未移植内容见 `THIRD_PARTY.md`。开发参考 noVNC 只用于测试，不是运行依赖。

许可证见 `LICENSE`，安全边界见 `SECURITY.md`，AI 辅助开发披露见 `AI_USE.md`。
