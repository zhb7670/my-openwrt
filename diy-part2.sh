#!/bin/bash
#
# diy-part2.sh - 在安装 feeds 之后执行的脚本
#

# 修改默认 IP 地址（可选）
# sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# 修改默认主题（可选）
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 添加自定义软件包版本信息
echo "=== 添加自定义版本信息 ==="
DATE=$(date +"%Y%m%d")
sed -i "s/DISTRIB_DESCRIPTION='.*'/DISTRIB_DESCRIPTION='ImmortalWrt Build ${DATE}'/" \
  package/base-files/files/etc/openwrt_release 2>/dev/null || true

# 打印已安装的 feeds 信息
echo "=== 已安装 feeds ==="
./scripts/feeds list -s

echo "=== diy-part2.sh 执行完成 ==="