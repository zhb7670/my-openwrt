# OpenWrt x86/64 全功能固件编译配置

基于 coolsnowwolf/lede，所有仓库地址已于 2025-04 验证有效。

---

## 仓库文件结构

```
├── .config                          # 固件配置（插件选择）
├── feeds.conf.default               # 第三方 feeds 源（全部验证可用）
├── diy-part1.sh                     # feeds update 之前执行（升级 golang）
├── diy-part2.sh                     # feeds install 之后执行（清冲突、改默认配置）
├── build-local.sh                   # WSL2/Ubuntu 本地一键编译脚本
└── .github/workflows/build-openwrt.yml  # GitHub Actions 云编译工作流
```

---

## 方式一：GitHub Actions 云编译（推荐先用这个验证）

### 步骤

1. 在 GitHub 新建一个**空仓库**（比如叫 `my-openwrt`）
2. 把本目录所有文件推送到该仓库的 `main` 分支
3. 进入仓库 **Settings → Actions → General**，将 Workflow permissions 改为 **Read and write permissions**
4. 进入 **Actions** 标签页，点击 `Build OpenWrt x86-64`，点 **Run workflow** 手动触发
5. 编译约需 **3-5 小时**
6. 完成后在 **Releases** 或 Actions 页面 **Artifacts** 下载固件

### 触发方式

- 手动：Actions → Run workflow
- 自动：修改 `.config`、`feeds.conf.default`、`diy-part1.sh`、`diy-part2.sh` 任意一个文件并 push

---

## 方式二：WSL2 本地编译

### 前置要求

- Windows 10/11，WSL2，Ubuntu 22.04
- **必须配置全局代理**（编译过程需访问 GitHub、golang.org 等）
- 磁盘空间 ≥ 50GB（推荐 100GB+）
- 内存 ≥ 8GB（16GB 更稳定）

### WSL2 注意事项

WSL2 默认挂载的 NTFS 分区（/mnt/c、/mnt/d 等）不区分大小写，**不能在上面编译**。
必须在 WSL2 的 ext4 分区内编译，即 `$HOME`（`/home/你的用户名/`）下。

### 步骤

```bash
# 1. 把本目录文件放到 WSL2 home 下，比如 ~/openwrt-config/
# 2. 进入该目录
cd ~/openwrt-config

# 3. 一键全流程编译（首次）
chmod +x build-local.sh
./build-local.sh full

# 4. 之后修改 .config 后增量编译
./build-local.sh rebuild

# 5. 更新源码后重编
./build-local.sh update
```

### 编译输出

固件在：`~/lede/bin/targets/x86/64/`

关注这两个文件：
- `*-x86-64-generic-squashfs-combined.img.gz`　→ 传统 BIOS 启动
- `*-x86-64-generic-squashfs-combined-efi.img.gz` → UEFI 启动（推荐）

---

## 固件默认配置

| 项目 | 值 |
|------|-----|
| LAN IP | 192.168.2.1 |
| 主机名 | OpenWrt-X86 |
| 主题 | Argon |
| 时区 | Asia/Shanghai |

---

## 包含的主要插件

### 科学上网
- **PassWall2**（主力）：SS/SSR/V2Ray/VLESS/Trojan/Hysteria2/TUIC/VLESS-Reality/WireGuard
- **PassWall**（备用）：同上
- **SSR-Plus+**：补充
- **OpenClash**：Clash.Meta/Mihomo，订阅规则场景

### DNS
- SmartDNS（国内加速）
- MosDNS v5（国内外分流 + 防 DNS 泄露）
- AdGuard Home（广告过滤）

### DDNS
- **ddns-go**：支持 Cloudflare / GoDaddy / Namecheap / 腾讯 DNSPod / 阿里 / Porkbun 等 60+ 家
- ddns-scripts：传统方案备用

### 其他
- iStore 应用商店
- Docker + Docker Compose
- Frp 内网穿透（客户端 + 服务端）
- ZeroTier
- Samba4 网络共享
- Aria2 + qBittorrent 下载
- AList 网盘挂载
- Netdata 监控
- TTYD Web 终端
- 自动重启

---

## 常见问题

**Q: 编译时 download 失败**
检查代理是否全局生效：`curl -I https://github.com` 能通再编译

**Q: sing-box 编译报 golang 版本错误**
`diy-part1.sh` 里已处理，如果仍报错手动执行：
```bash
cd ~/lede
rm -rf feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang -b 1.26 feeds/packages/lang/golang
```

**Q: iStore 里的应用安装不了**
在路由器 LuCI → iStore → 设置 里，确认 opkg 源指向编译对应架构的镜像源

**Q: 配置好网关/DNS 但还是不通网**
SSH 进入路由检查：
```bash
opkg list-installed | grep "^ip "   # 应该是 ip-full，不是 ip-tiny
opkg list-installed | grep dnsmasq  # 应该是 dnsmasq-full
```
