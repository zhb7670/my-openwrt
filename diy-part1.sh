#!/bin/bash
#
# diy-part1.sh - 在更新 feeds 之前执行的脚本
#

# 设置编译工具链路径
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 打印系统信息
echo "=== 系统信息 ==="
uname -a
cat /etc/os-release 2>/dev/null || true

# 安装编译依赖（如果缺失）
echo "=== 安装编译依赖 ==="
sudo apt-get update -y
sudo apt-get install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
  bzip2 ccache clang cmake cpio curl device-tree-compiler ecj fastjar flex gawk gettext gcc-multilib \
  g++-multilib git gnutls-dev gperf haveged help2man intltool lib32gcc-s1 libc6-dev-i386 libelf-dev \
  libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses-dev libpython3-dev \
  libreadline-dev libssl-dev libtool libyaml-dev libz-dev lld llvm lrzsz mkisofs msmtp nano \
  ninja-build p7zip p7zip-full patch pkgconf python3 python3-pip python3-ply python3-docutils \
  python3-pyelftools qemu-utils re2c rsync scons squashfs-tools subversion swig texinfo u-boot-tools \
  unzip util-linux uuid-dev vim wget xsltproc xxd zip zlib1g-dev zstd

# 增加 swap 空间（如果需要）
echo "=== 检查 swap 空间 ==="
if [ "$(free -m | awk '/Swap:/ {print $2}')" -lt 1024 ]; then
  echo "增加 swap 空间..."
  sudo fallocate -l 2G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
fi

# 打印磁盘空间
echo "=== 磁盘空间 ==="
df -h

echo "=== diy-part1.sh 执行完成 ==="