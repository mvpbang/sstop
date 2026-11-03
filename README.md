# sstop

终端实时单进程网络带宽监控工具。相当于网络活动的 `htop`。

![demo](docs/screenshots/main.gif)

## 功能特性

- **按进程追踪带宽**：实时显示每个进程的上传/下载速率与带宽走势
- **迷你走势图 (Sparklines)**：直观展现各个进程的流量历史波动
- **彩色带宽指示条**：采用颜色与亮度梯度直观反应流量负载
- **多维度视图**：进程列表、进程详情、远程主机聚合、监听端口、进程树视图、容器/服务分组视图
- **丰富连接详情**：展示 TCP 状态徽章、连接时长、DNS 域名反查、协议及知名端口解析
- **远程主机聚合**：跨进程聚合远端 IP 流量，并支持 GeoIP 国家与国旗显示
- **全局走势微图**：顶部实时显示过去 60 秒的系统整体带宽趋势
- **趋势箭头 (↑↓→)**：快速指示流量处于上升、下降或平稳状态
- **多网卡统计与切换**：支持单网卡流量过滤与一键循环切换
- **强大的搜索与高级过滤**：支持按进程名、命令、PID，以及高级语法（如 `port:443`、`up>1M`、`proto:udp` 等）筛选
- **多种排序模式**：支持按当前速率、下载量、上传量、PID、进程名、连接数排序
- **累计流量模式 (`c`)**：支持实时速率与累计传输字节数随时切换
- **带宽告警 (`A`)**：支持设置流量阈值，超限触发终端蜂鸣与闪烁提醒
- **进程管理 (`K`)**：内置结束进程弹窗，支持选择多种系统信号（SIGTERM、SIGKILL 等）
- **会话录制与回放**：支持 `--record` 抓取网络流量，支持 `--playback` 离线回放与变速
- **非交互流式输出**：支持 `--json` (JSONL) 与 `--csv` 输出，便于脚本处理与数据分析
- **鼠标支持**：支持点击选择、滚轮滚动翻页
- **动态调整刷新率**：支持 100ms 至 10s 运行期间动态调整，支持空格键随时暂停/继续
- **Tokyo Night 主题配色**：精致暗色主题配以交替行斑马纹
- **全平台支持与老内核兼容**：支持 Linux（Netlink + `/proc` + `AF_PACKET`，完美兼容 CentOS 7 / 3.10 内核）与 macOS（netstat + lsof）

## 界面预览

<table>
<tr>
<td><img src="docs/screenshots/process_table.png" alt="进程列表" width="400"/></td>
<td><img src="docs/screenshots/detail_view.png" alt="进程详情" width="400"/></td>
</tr>
<tr>
<td align="center"><em>进程列表 (Process Table)</em></td>
<td align="center"><em>进程详情 (Process Detail)</em></td>
</tr>
<tr>
<td><img src="docs/screenshots/remote_hosts.png" alt="远程主机" width="400"/></td>
<td><img src="docs/screenshots/help.png" alt="帮助弹窗" width="400"/></td>
</tr>
<tr>
<td align="center"><em>远程主机 (Remote Hosts)</em></td>
<td align="center"><em>快捷键帮助 (Help Overlay)</em></td>
</tr>
</table>

## 安装与构建

### 源码编译 (推荐)

本项目提供 `Makefile`，所有构建产物均统一输出至 `dist/` 目录：

```bash
# 构建 CentOS 7 / RHEL 7 专用的纯静态 amd64 二进制文件（输出至 dist/sstop-centos7）
make centos7

# 构建当前系统架构的二进制文件（输出至 dist/sstop，附带 -trimpath 与 -ldflags="-s -w" 优化）
make build

# 构建当前系统的纯静态二进制文件（CGO_ENABLED=0，输出至 dist/sstop）
make build-static

# 交叉编译指定平台架构（输出至 dist/ 目录）
make linux-amd64    # dist/sstop-linux-amd64
make linux-arm64    # dist/sstop-linux-arm64
make darwin-arm64   # dist/sstop-darwin-arm64
make darwin-amd64   # dist/sstop-darwin-amd64

# 多平台发布打包（自动在 dist/ 生成各平台 tar.gz 压缩包及 SHA-256 checksums.txt）
make dist

# 运行测试
make test           # 运行全套单元测试
make test-linux     # 针对 Linux 平台编译并验证平台代码

# 清理构建产物与临时文件（清理 dist/ 及临时产物）
make clean

# 查看 Makefile 支持的所有目标与使用说明
make help
```

### 下载预编译二进制 (Releases)

可直接从 [Releases](https://github.com/googlesky/sstop/releases) 页面下载对应系统的预编译包：

```bash
# Linux amd64
curl -L https://github.com/googlesky/sstop/releases/latest/download/sstop-linux-amd64.tar.gz | tar xz
sudo mv sstop /usr/local/bin/

# Linux arm64
curl -L https://github.com/googlesky/sstop/releases/latest/download/sstop-linux-arm64.tar.gz | tar xz
sudo mv sstop /usr/local/bin/

# macOS arm64 (Apple Silicon)
curl -L https://github.com/googlesky/sstop/releases/latest/download/sstop-darwin-arm64.tar.gz | tar xz
sudo mv sstop /usr/local/bin/

# macOS amd64 (Intel)
curl -L https://github.com/googlesky/sstop/releases/latest/download/sstop-darwin-amd64.tar.gz | tar xz
sudo mv sstop /usr/local/bin/
```

### 通过 Go 安装

需要 Go 1.21 或更高版本：

```bash
go install github.com/googlesky/sstop@latest
```

或手动编译：

```bash
git clone https://github.com/googlesky/sstop.git
cd sstop
mkdir -p dist && go build -trimpath -ldflags="-s -w" -o dist/sstop .
```

## 使用说明

```bash
# Linux — 需要 root 权限或 CAP_NET_RAW 权能以获取完整带宽与套接字映射
sudo ./dist/sstop

# macOS — 需要 root 权限以通过 lsof 获取进程套接字映射
sudo ./dist/sstop

# Linux 下也可仅授予权能，无需以 root 身份运行：
sudo setcap cap_net_raw+ep ./dist/sstop
./dist/sstop

# 命令行非交互流式输出示例（JSON 或 CSV）：
sudo ./dist/sstop --json --interval 2s
sudo ./dist/sstop --csv --once

# 会话录制与回放：
sudo ./dist/sstop --record traffic.ssrec
./dist/sstop --playback traffic.ssrec
```

## 快捷键说明

### 基础导航 (全部视图通用)

| 按键 | 说明 |
|-----|------|
| `j` / `↓` | 光标向下移动一行 |
| `k` / `↑` | 光标向上移动一行 |
| `PgUp` / `Ctrl+U` | 向上翻半页 |
| `PgDown` / `Ctrl+D` | 向下翻半页 |
| `g` / `Home` | 跳转至顶部第一行 |
| `G` / `End` | 跳转至底部最后一行 |

### 进程列表视图 (Process Table)

| 按键 | 说明 |
|-----|------|
| `Enter` | 打开选中进程的详细信息 |
| `s` | 切换排序列（速率 → 下载 → 上传 → PID → 进程名 → 连接数） |
| `/` | 打开搜索 / 高级过滤输入框 |
| `t` | 切换进程树状视图（展示父子进程层级与聚合带宽） |
| `c` | 切换累计流量模式（实时速率 / 累计传输字节数） |
| `h` | 切换至远程主机视图 |
| `l` | 切换至监听端口视图 |
| `D` | 切换至容器 / 系统服务分组视图 |
| `A` | 设置带宽告警阈值 |
| `K` | 弹出结束进程菜单 |

### 进程详情视图 (Process Detail)

| 按键 | 说明 |
|-----|------|
| `d` | 开启 / 关闭远端 IP 的 DNS 域名反查 |
| `K` | 弹出结束进程菜单 |
| `Esc` | 返回进程列表 |

### 全局快捷键

| 按键 | 说明 |
|-----|------|
| `i` / `Tab` | 循环切换监控的网络接口（全部 → eth0 → ...） |
| `+` / `=` | 加快刷新频率（缩短采集间隔） |
| `-` | 减慢刷新频率（延长采集间隔） |
| `Space` | 暂停 / 继续界面数据刷新 |
| `←` / `→` | 会话回放模式下减速 / 加速播放 |
| `?` | 打开 / 关闭快捷键帮助弹窗 |
| `q` / `Ctrl+C` | 退出程序（退出时展示会话统计摘要） |

## 工作原理

### Linux

`sstop` 采用多层级降级策略，实现最大化的环境兼容性：

1. **Netlink SOCK_DIAG (优先模式，推荐 Linux 4.1+)**：直接与内核通信获取全量 TCP/UDP 套接字信息，并从 `struct tcp_info` 中读取各连接的实时字节计数器。速度最快、精度最高且开销最小。

2. **`/proc/net` + AF_PACKET (兼容降级模式)**：
   - 当内核未启用 `inet_diag` 模块时；
   - 或在老旧内核版本（< 4.1，例如 **CentOS 7 / RHEL 7 的 Linux 3.10 内核**，其 `struct tcp_info` 缺少 `tcpi_bytes_acked` 和 `tcpi_bytes_received` 字段）下，`sstop` 会自动识别并启用降级；
   - 降级模式下通过解析 `/proc/net/{tcp,tcp6,udp,udp6}` 枚举套接字，同时开启 `AF_PACKET` 原始套接字在数据包级别精准统计连接带宽；
   - 亦可通过环境变量 `SSTOP_USE_PROC=1` 强制开启此模式。

进程与套接字的映射通过扫描 `/proc/<pid>/fd/` 下的套接字 inode 完成；网络接口数据来源于 `/proc/net/dev`。

### macOS

通过 `netstat -anb` 获取带有字节计数的套接字列表，使用 `lsof` 实现套接字与进程的关联映射，并通过 `netstat -ibn` 获取网络接口流量。

### 速率平滑算法

所有带宽速率均使用指数移动平均（EMA，$\alpha = 0.3$）进行平滑处理，有效防止数据抖动，提供稳定、易读的实时数值。

## 环境要求

- **Linux**：需要 `root` 权限或授予 `CAP_NET_RAW` 权能；推荐加载 `inet_diag` 内核模块（`modprobe tcp_diag`）。
- **macOS**：需要 `root` 权限以便 `lsof` 扫描进程与套接字对应关系。
- **终端**：推荐使用支持 256 色及交替屏幕缓冲区（Alternate Screen）的现代终端。

## 开源协议

本项目基于 [MIT](LICENSE) 协议开源。
