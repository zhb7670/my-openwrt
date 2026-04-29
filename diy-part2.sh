#!/bin/bash
# ============================================================
# diy-part2.sh — 在 feeds install 之后执行
# 工作目录：lede 源码根目录
# ============================================================

# ── 1. 删除 feeds/packages 里与第三方 feed 冲突的旧版本 ──
echo ">>> 删除 feeds/packages 下与 passwall_packages/kenzo/small 冲突的旧包..."

# passwall_packages 提供更新版本的这些包
rm -rf feeds/packages/net/xray-core
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/packages/net/sing-box
rm -rf feeds/packages/net/chinadns-ng
rm -rf feeds/packages/net/dns2socks
rm -rf feeds/packages/net/hysteria
rm -rf feeds/packages/net/ipt2socks
rm -rf feeds/packages/net/microsocks
rm -rf feeds/packages/net/naiveproxy
rm -rf feeds/packages/net/shadowsocks-libev
rm -rf feeds/packages/net/shadowsocks-rust
rm -rf feeds/packages/net/shadowsocksr-libev
rm -rf feeds/packages/net/simple-obfs
rm -rf feeds/packages/net/tcping
rm -rf feeds/packages/net/trojan-plus
rm -rf feeds/packages/net/tuic-client
rm -rf feeds/packages/net/v2ray-plugin
rm -rf feeds/packages/net/xray-plugin
rm -rf feeds/packages/net/geoview
rm -rf feeds/packages/net/shadow-tls

# kenzo/small 提供更新版本的这些包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/adguardhome
rm -rf feeds/packages/net/smartdns
rm -rf feeds/packages/utils/v2dat

# luci feed 里的旧版 passwall（由 passwall_luci feed 提供）
rm -rf feeds/luci/applications/luci-app-passwall

# ── 2. 修复 samba4 与 autosamba 文件冲突 ──
echo ">>> 移除 autosamba（与 samba4 文件冲突）..."
rm -rf feeds/packages/net/autosamba 2>/dev/null || true
rm -rf package/lean/autosamba       2>/dev/null || true
rm -rf package/lean/ddns-scripts_dnspod 2>/dev/null || true

# ── 3. 强制重新安装所有 feeds（让新版本建立软链接）──
echo ">>> 全量重新安装 feeds..."
./scripts/feeds install -a -f

# ── 4. 显式安装关键依赖包（确保软链接建立正确）──
# 这是核心修复：直接指定从哪个 feed 安装，防止安装失败时静默跳过
echo ">>> 显式安装 passwall_packages 依赖..."
./scripts/feeds install -p passwall_packages -f \
    xray-core sing-box hysteria naiveproxy \
    microsocks tcping dns2socks ipt2socks \
    chinadns-ng shadowsocks-rust shadowsocksr-libev \
    trojan-plus tuic-client v2ray-plugin xray-plugin \
    geoview v2ray-geoip v2ray-geosite dns2tcp shadow-tls

echo ">>> 显式安装 kenzo/small 依赖..."
./scripts/feeds install -p kenzo -f \
    luci-app-adguardhome adguardhome \
    luci-app-smartdns smartdns \
    luci-app-ddns-go ddns-go \
    luci-app-argon-config luci-theme-argon \
    luci-app-wechatpush

./scripts/feeds install -p small -f \
    luci-app-mosdns mosdns v2dat \
    luci-app-homeproxy

echo ">>> 显式安装 helloworld 依赖..."
./scripts/feeds install -p helloworld -f \
    luci-app-ssr-plus

echo ">>> 显式安装 passwall_luci 依赖..."
./scripts/feeds install -p passwall_luci -f \
    luci-app-passwall

echo ">>> 显式安装 passwall2 依赖..."
./scripts/feeds install -p passwall2 -f \
    luci-app-passwall2

echo ">>> 显式安装 istore 依赖..."
./scripts/feeds install -p istore -f \
    luci-app-store

# ── 5. 修改固件默认 IP ──
echo ">>> 修改默认 LAN IP 为 192.168.2.1..."
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# ── 6. 修改默认主机名 ──
echo ">>> 修改主机名为 OpenWrt-X86..."
sed -i "s/hostname='OpenWrt'/hostname='OpenWrt-X86'/g" package/base-files/files/bin/config_generate

# ── 7. 修改默认主题为 argon ──
echo ">>> 设置默认主题 argon..."
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile 2>/dev/null || true

# ── 8. 修改时区 ──
echo ">>> 设置时区为 Asia/Shanghai..."
DEFAULT_SETTINGS="package/lean/default-settings/files/zzz-default-settings"
if [ -f "$DEFAULT_SETTINGS" ]; then
    sed -i "/exit 0/i uci set system.@system[0].timezone='CST-8'" $DEFAULT_SETTINGS
    sed -i "/exit 0/i uci set system.@system[0].zonename='Asia/Shanghai'" $DEFAULT_SETTINGS
    sed -i "/exit 0/i uci commit system" $DEFAULT_SETTINGS
fi

echo ">>> diy-part2.sh 执行完毕"
