# MoonRFB 换题查重记录

日期：2026-09-15。状态：新推荐候选；未开始实现、未预留参赛身份、未发布，不代表组委会审核通过。

## 筛选标准

用户明确排除 MoonSunCalc，也排除上一轮 NIfTI。此次不仅寻找缺少同名移植的库，还排除已有明显同用途能力的方向。不以“换格式”“换算法”规避生态重叠。查重证据独立保存，不放进中文申报书。

## 不同领域候选比较

| 方向 | 已查到的相关能力 | 决定 |
|---|---|---|
| 医学影像 NIfTI | CCllff-jpg/moondicom、001-Elsa/medseal、ShunjunGu/moon-npy 等相邻能力；上一轮已保存实际接口资料 | 用户排除，不再选 |
| 国际电话号码 libphonenumber-js | didiLjf/moon-record-linkage@0.1.5 的 normalization 子包已有电话号码归一化；虽不等于完整号码元数据库，仍然相关 | 排除 |
| 开发工具 source map | Derk2006/sourcemap、shop1111/moon_sourcemap、xiaoxiao1211/moonbit-sourcemap | 排除 |
| VNC/RFB 远程桌面协议引擎 | 本次公开检索未发现同用途协议实现；宽泛命中需区分桌面框架和绘图基础设施 | 本轮推荐 |

## MoonCakes 检索

原始响应保存在本目录上两级。modules.json 为本轮下载的 2,489 条模块元数据。对名称、描述、仓库、关键词进行 VNC、RFB、noVNC、libvnc、remote desktop、remote framebuffer、screen sharing 检索，未命中。元数据空白不能证明源码不存在，因此另外进行了包/子包摘要搜索。

- vnc、rfb、libvnc、hextile、zrle、FrameBufferUpdate：API 返回空数组。
- novnc 的模糊搜索返回密码学、签名等结果，不能把返回数量直接当作 noVNC 库数量。
- remote desktop 返回 lepus、proton_tray、tray、moondesk、proton_ext、moontown 等；返回描述/摘要是桌面框架、托盘、桌面环境等，未见 RFB 连接、远程画面传输或 VNC 编码接口。
- 远程桌面返回 mizchi/npm_typed@0.1.15：描述为 npm 类型绑定。进一步下载其 GitHub main 分支递归树，未见 vnc/rfb/remote/desktop 对应模块；screen 命中的是 puppeteer 截图示例及 testing_library/screen。
- 屏幕共享返回 tonyfettes/ghostty；framebuffer 返回终端缓冲、canvas、raylib、渲染器等。这些结果不等于屏幕共享协议库，但未对其所有源码做逐行审计。
- spice 返回 pzq893/moonbit-spice、hsy-bit/moonbit-circuit-solver，其子包摘要明确是电路仿真，不是远程桌面 SPICE 协议。
- remote framebuffer / screen sharing 等还模糊命中 bobzhang/games；搜索结果未提供对应 RFB 子包，不能把大型多游戏集合全部源码声称为已审计。

完整查询、URL、响应摘要和首轮内容 SHA-256 见 fetch-log.json。首轮误用 master 分支失败已保留；已根据仓库实际默认分支 main 重新获取 upstream-tree-main.json，不将失败请求算作检查通过。

## GitHub 交叉检索

以下 repository search 均返回 total_count=0、incomplete_results=false，原始 JSON 分别保存在 github-*.txt：

- vnc language:MoonBit
- rfb language:MoonBit
- "remote desktop" language:MoonBit
- novnc moonbit
- "远程桌面" MoonBit
- "remote framebuffer" moonbit

这是公开仓库检索，不是全球源码全文检索，也不覆盖私人仓库、未索引项目和未公开参赛选题。

## 本地登记边界

完整登记快照见 registry-snapshot.md。逐项题目/领域对照，没有已登记的 VNC/RFB 客户端。重点排除了以下看似相邻但不同用途的项目：

- MoonWire：自定义应用二进制帧；曾被驳回，不能复用其核心更名。MoonRFB 必须从指定上游移植真实协议状态机、帧缓冲更新解码和输入事件，不能退化为通用拆包示例。
- MoonTSInspect：离线 MPEG-2 TS 时间和节目结构分析，不是交互式远程桌面。
- MoonTopo：地图/拓扑方向，不是远程控制台。
- MoonSunCalc 与 NIfTI：本轮明确不再选。

## 可追溯上游

- 原项目：HsuJv/vnc-rs，Rust VNC 客户端协议引擎。
- 仓库：https://github.com/HsuJv/vnc-rs
- 固定发布包：vnc-rs 0.5.3，通过 crates.io 下载实际源码包，不使用浮动 main 作为移植基准。
- 发布包 SHA-256：5607299ce93dc285571540ee93de681a1be7a5765c35dfb2e1f049b493652145。
- 发布包 .cargo_vcs_info.json 中源提交：ab684d009d767c968af2f7559576334038623124。
- Cargo.toml 许可：MIT OR Apache-2.0；已读取发布包 LICENSE-MIT。移植按 MIT 保留版权/许可，并建立文件映射。
- 下载包内 18 个 Rust 源文件，物理行数 3,325（包含注释和空行，不是实现有效行数，也不是 MoonBit 成果）。
- 实际源码包含 connector/auth/messages、DES、Raw/TRLE/Zlib/ZRLE/Tight/cursor 等。上游 README 明确 Hextile/RRE 未实现，TRLE 实机验证不足，不能照搬网络摘要宣称全部支持或已充分验证。

## 建议实现和验收边界

移植客户端协议引擎，不做 Rust FFI 包装，不写完整远控桌面产品。明确核心库和 TCP/前端适配的边界。优先完成版本协商、认证、像素格式、Raw/CopyRect、输入事件、增量更新，再逐项移植压缩编码并补足畸形输入/分片输入测试。是否发布某种编码以实际通过测试为准。

三个计划示例：受控服务端画面读取；本地受控服务端键鼠事件回环验证；局部画面更新及复制矩形的连续帧重建。不连接未授权机器。

计划量化：与固定上游比较协议输出字节、事件序列、无损编码最终像素逐点一致性；不同分片位置解码一致性；异常长度/越界矩形/截断压缩流拒绝情况；固定环境的吞吐和峰值内存。以上尚未运行，不是成绩。互操作软件拟采用 TigerVNC，具体版本和运行结果在实施时验证。

传统 VNC 密码认证不等于现代安全传输；不宣称开箱即用公网安全，不把完整 TLS/SSH、RDP/SPICE 服务端纳入第一版。

## 结论与剩余风险

在本轮 MoonCakes 元数据、包/子包检索、本地登记及 GitHub 公开仓库检索范围内，未发现同用途 VNC/RFB 实现。比前两轮候选更符合“几乎没有相关选题”的要求。仍有通用网络、桌面、绘图依赖，不能声称整个网络/图形领域空白；也无法证明所有未公开参赛项目不存在。实现前及申报前应再次检索，组委会判断不可替代。

## 2026-09-15 实施状态更新
用户已确认选题并授权验证身份后发布；核心、三个 TCP 示例及本地对标已实现。最终范围为 Raw/CopyRect/TRLE，不含 ZRLE。对标实际采用 noVNC 1.7.0 原版模块、原始 Rust DES 和独立 RFC 编码器，未开展 TigerVNC GUI 互操作测试；不申报峰值内存或完整压缩编码支持。前述计划不是完成结果，具体实测见 docs/evidence。
