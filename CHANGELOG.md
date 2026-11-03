# 更新日志 (Changelog)

本项目的所有显著变更均记录在此文件中。

格式遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/) 规范，版本号遵循 [语义化版本 (Semantic Versioning)](https://semver.org/lang/zh-CN/)。

## [未发布] (Unreleased)

### 新增 (Added)
- **CentOS 7 与低版本 Linux 内核 (< 4.1) 兼容支持**：
  - 自动通过 `/proc/sys/kernel/osrelease` 检测 Linux 内核版本。
  - 在低于 4.1 版本的内核（如 CentOS 7 / RHEL 7 采用的 Linux 3.10 内核，其内核 `struct tcp_info` 缺少 `tcpi_bytes_acked` 与 `tcpi_bytes_received` 字段）上，自动回退到 `AF_PACKET` 原始套接字抓包模式统计连接流量。
  - 支持通过环境变量 `SSTOP_USE_PROC=1` 强制启用 `/proc` 与 `AF_PACKET` 流量采集模式。
  - 完善对内核禁用 IPv6（如系统启动参数 `ipv6.disable=1`）环境的兼容，确保 IPv4 监控正常工作而不报错。
- **构建系统与产物归档**：
  - 新增项目 `Makefile`，所有编译构建成果统一输出至 `dist/` 目录。
  - 支持多平台交叉编译、本机静态构建 (`make build-static`)、CentOS 7 专属静态构建目标 (`make centos7`)、发布归档打包 (`make dist`)、单元测试及使用说明 (`make help`)。
- **10 大 CLI / TUI 核心特性**：
  - 非交互式流式输出：支持 `--json` (JSONL) 与 `--csv` 格式，兼容 `--once`（单次输出）与 `--interval`（采集间隔）参数。
  - 退出时展示会话摘要：显示监控总时长、累计上传/下载流量以及 Top 活跃进程。
  - 累计流量模式切换（快捷键 `c`）：可在实时速率与累计传输字节数之间自由切换。
  - 协议与常用服务识别：自动映射约 50 个常用网络端口服务（HTTP、HTTPS、SSH、DNS、PostgreSQL、Redis 等）。
  - 支持高级过滤表达式（如 `port:443`、`up>1M`、`down>100k`、`proto:udp`、`host:`、`svc:`、`group:` 等）。
  - 进程树视图（快捷键 `t`）：展示父子进程层级关系并递归统计聚合带宽。
  - 远程主机视图支持 GeoIP：解析远端 IP 所在国家并展示国家名称与国旗 Emoji。
  - 带宽告警功能（快捷键 `A`）：支持自定义带宽阈值，超限时触发高亮闪烁与终端蜂鸣提示。
  - 会话录制与回放：支持 `--record <file>` 录制网络会话流量，支持 `--playback <file>` 回放并提供暂停与变速控制。
  - 容器与服务分组视图（快捷键 `D`）：按 Docker/Podman 容器 ID 或 systemd 服务单元自动聚合进程带宽。

### 变更 (Changed)
- **构建输出目录统一**：所有 Makefile 构建目标（`build`、`build-static`、`centos7`、各平台交叉编译等）的产物均统一输出至 `dist/` 目录，保持根目录整洁。
- **CI/CD 发布流程**：`release.yml` 与 `ci.yml` 默认启用 `CGO_ENABLED=0` 与 `-trimpath`，生成完全静态链接、不依赖特定 glibc 版本的独立二进制文件，可在包括 CentOS 7 在内的较旧 Linux 发行版上开箱即用。
- **Netlink 运行时容错回退**：当 Netlink 套接字查询发生运行时异常时，自动平滑回退至 `/proc` 模式。

### 修复 (Fixed)
- 修复 CI 环境下因 channel 非阻塞发送导致的 `TestRecordSession` 偶发测试失败问题。

---

## [0.1.2] - 2026-02-15

### 修复 (Fixed)
- 速率格式化函数 `FormatRateCompact` 新增 TB 级别（`T = 1024 GB`），避免超大吞吐量（>= 10,000 GB/s）时显示格式溢出。

---

## [0.1.1] - 2026-02-15

### 新增 (Added)
- 新增固定宽度 (6 字符) 的速率显示函数 `FormatRateCompact()`，保证各类终端宽度下列对齐整齐一致。
- 增加终端宽度 60–250 列的全视图布局测试，以及速率在 $2^0 \sim 2^{40}$ 范围内的模糊测试。

### 修复 (Fixed)
- 修复进程列表、远程主机、监听端口及进程详情视图中的列宽计算与列间距问题。
- 在顶部状态栏中过滤掉流量为零的无活动网络接口。

---

## [0.1.0] - 2026-02-14

### 新增 (Added)
- 首次发布 `sstop`：终端实时单进程网络带宽监控工具。
- 按进程实时统计上传/下载速率，提供走势微图（sparklines）与 Tokyo Night 风格彩色带宽条。
- 4 个核心交互视图：
  - **进程列表**：概览所有具备网络连接的活跃进程。
  - **进程详情**：查看特定进程的套接字连接、TCP 状态、连接时长及 DNS 解析结果。
  - **远程主机**：按远端 IP 地址跨进程聚合带宽流量。
  - **监听端口**：查看本机开放端口及监听服务。
  - **帮助弹窗** (`?`) 与 **结束进程弹窗** (`K`)。
- 顶部状态栏提供全局 60 秒带宽走势微图。
- 跨平台兼容：
  - Linux：Netlink `SOCK_DIAG` 高性能采集，并提供 `/proc` + `AF_PACKET` 原始套接字回退。
  - macOS：基于 `netstat` 与 `lsof` 的进程网络映射。
- 终端交互支持：支持鼠标点击选中与滚轮滚动翻页，支持动态调整刷新率 (`+` / `-`) 以及界面暂停/继续 (`空格键`)。
