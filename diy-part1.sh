#!/bin/bash
# ============================================================
# diy-part1.sh — 在 feeds update 之前执行
# 工作目录：lede 源码根目录
# ============================================================

# ── 1. 升级 golang 工具链（sing-box/passwall2/hysteria2 必须 >=1.22）──
echo ">>> 升级 golang 工具链到 1.26..."
rm -rf feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang -b 1.26 feeds/packages/lang/golang

# ── 2. 删除 lede 自带的旧版协议包（必须在 feeds update 之前删）──
# 关键：feeds update 时会把 feeds.conf 里各 feed 的内容 clone 到 feeds/xxx/
# 只有在 feeds update 之前删掉 lede 源码自带的旧包，
# feeds install 时才会优先用 passwall_packages/kenzo/small 里的新版本
echo ">>> 删除 lede package/lean/ 下内置的旧版协议包..."
rm -rf package/lean/xray-core         2>/dev/null || true
rm -rf package/lean/v2ray-core        2>/dev/null || true
rm -rf package/lean/trojan-plus       2>/dev/null || true
rm -rf package/lean/shadowsocksr-libev 2>/dev/null || true
rm -rf package/lean/luci-app-passwall  2>/dev/null || true
rm -rf package/lean/luci-app-ssr-plus  2>/dev/null || true

echo ">>> diy-part1.sh 执行完毕"
