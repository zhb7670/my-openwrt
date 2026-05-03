# ImmortalWrt x86/64 云编译固件

[![Build ImmortalWrt](https://github.com/zhb7670/my-openwrt/actions/workflows/build-openwrt.yml/badge.svg)](https://github.com/zhb7670/my-openwrt/actions/workflows/build-openwrt.yml)

## 📋 固件信息

- **源码**: [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)
- **分支**: openwrt-24.10
- **平台**: x86/64
- **内核**: 6.12.x

## 🌟 功能特点

### 代理插件
- ✅ OpenClash
- ✅ Passwall
- ✅ Passwall2
- ✅ SSR-Plus
- ✅ VSSR

### DNS/广告过滤
- ✅ SmartDNS
- ✅ MosDNS
- ✅ AdGuard Home
- ✅ Adbyby Plus
- ✅ Koolproxy
- ✅ DNSFilter

### 网络存储
- ✅ AList
- ✅ CloudDrive2
- ✅ 阿里云盘 WebDAV
- ✅ Samba4
- ✅ NFS
- ✅ MiniDLNA

### 下载工具
- ✅ Aria2
- ✅ qBittorrent
- ✅ Transmission

### Docker
- ✅ Docker
- ✅ Dockerd
- ✅ Containerd

### VPN/穿透
- ✅ WireGuard
- ✅ OpenVPN
- ✅ ZeroTier
- ✅ N2N
- ✅ Frp
- ✅ Nps

### 主题
- ✅ Argon
- ✅ Design
- ✅ AtMaterial
- ✅ Edge
- ✅ NetGear
- ✅ NeoBird

### 其他
- ✅ Docker 管理
- ✅ 磁盘管理
- ✅ 网络测速
- ✅ 带宽监控
- ✅ 访客网络
- ✅ 唤醒
- ✅ 打印服务器

## 🔧 使用方法

### 下载固件

1. 进入 [Releases](https://github.com/zhb7670/my-openwrt/releases) 页面
2. 下载最新的固件文件

### 固件格式

| 文件格式 | 说明 |
|---------|------|
| `.img.gz` | 硬盘镜像（推荐） |
| `.iso` | CD-ROM 镜像 |
| `.efi` | EFI 启动镜像 |
| `.vdi` | VirtualBox 镜像 |
| `.vmdk` | VMware 镜像 |
| `.qcow2` | QEMU 镜像 |

### 安装方法

#### 1. 物理机安装

```bash
# 解压镜像
gunzip openwrt-*.img.gz

# 写入硬盘（替换 /dev/sdX 为你的硬盘）
dd if=openwrt-*.img of=/dev/sdX bs=1M status=progress
```

#### 2. 虚拟机安装

- **VirtualBox**: 使用 `.vdi` 文件直接创建虚拟机
- **VMware**: 使用 `.vmdk` 文件
- **Proxmox VE**: 使用 `.img` 文件创建 VM

### 默认配置

- **IP 地址**: 192.168.1.1
- **用户名**: root
- **密码**: 无
- **后台地址**: http://192.168.1.1 或 http://immortalwrt.lan

## 📝 编译说明

### 自动编译

推送到 main/master 分支会自动触发编译。

### 手动编译

1. 进入 Actions 页面
2. 选择 "Build ImmortalWrt x86/64"
3. 点击 "Run workflow"

### 自定义配置

1. 修改 `.config` 文件添加/删除软件包
2. 修改 `feeds.conf.default` 添加第三方源
3. 修改 `diy-part1.sh` 和 `diy-part2.sh` 自定义脚本

## ⚠️ 注意事项

1. 编译时间约 2-4 小时
2. GitHub Actions 有 6 小时超时限制
3. 建议定期更新配置以获取最新软件包
4. 部分插件可能存在依赖冲突，请自行调整

## 📜 开源协议

- ImmortalWrt: [GPL-2.0](https://github.com/immortalwrt/immortalwrt/blob/main/LICENSE)
- 第三方插件: 各自的许可证

## 🙏 致谢

- [ImmortalWrt](https://github.com/immortalwrt) 项目
- [OpenWrt](https://github.com/openwrt) 项目
- 所有第三方插件作者
