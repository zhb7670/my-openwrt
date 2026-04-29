#!/bin/bash
# ============================================================
# build-local.sh — WSL2 / Ubuntu 22.04 本地编译脚本
# 用法：chmod +x build-local.sh && ./build-local.sh
# 注意：必须用普通用户运行，不能 sudo ./build-local.sh
# ============================================================

set -e

LEDE_DIR="$HOME/lede"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── 颜色输出 ──────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ── 检查不能以 root 运行 ──────────────────────────────────
[ "$(id -u)" = "0" ] && error "请用普通用户运行，不要加 sudo"

# ── WSL2 PATH 修复（避免带空格的 Windows 路径导致编译失败）──
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# ── 步骤 1：安装系统依赖 ──────────────────────────────────
install_deps() {
    info "安装编译依赖..."
    sudo apt-get update -qq
    sudo apt-get install -y \
        ack antlr3 asciidoc autoconf automake autopoint binutils bison \
        build-essential bzip2 ccache cmake cpio curl device-tree-compiler \
        fastjar flex gawk gettext gcc-multilib g++-multilib git gperf haveged \
        help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
        libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev \
        libncursesw5-dev libpython3-dev libreadline-dev libssl-dev libtool \
        lrzsz mkisofs msmtp ninja-build p7zip p7zip-full patch pkgconf \
        python2.7 python3 python3-pyelftools python3-setuptools qemu-utils \
        rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl \
        unzip vim wget xmlto xxd zlib1g-dev 2>&1 | tail -5
    info "依赖安装完成"
}

# ── 步骤 2：克隆或更新 LEDE 源码 ─────────────────────────
clone_or_update() {
    if [ -d "$LEDE_DIR/.git" ]; then
        info "检测到已有源码，执行 git pull..."
        cd "$LEDE_DIR"
        git pull
    else
        info "克隆 LEDE 源码（约 300MB，请耐心等待）..."
        git clone https://github.com/coolsnowwolf/lede "$LEDE_DIR"
    fi
}

# ── 步骤 3：复制配置文件 ──────────────────────────────────
copy_configs() {
    info "复制配置文件..."
    cp "$SCRIPT_DIR/feeds.conf.default" "$LEDE_DIR/feeds.conf.default"
    cp "$SCRIPT_DIR/.config"            "$LEDE_DIR/.config"
    cp "$SCRIPT_DIR/diy-part1.sh"       "$LEDE_DIR/diy-part1.sh"
    cp "$SCRIPT_DIR/diy-part2.sh"       "$LEDE_DIR/diy-part2.sh"
    chmod +x "$LEDE_DIR/diy-part1.sh" "$LEDE_DIR/diy-part2.sh"
}

# ── 步骤 4：执行 diy-part1（升级 golang）────────────────
run_diy1() {
    info "执行 diy-part1.sh（升级 golang）..."
    cd "$LEDE_DIR"
    bash diy-part1.sh
}

# ── 步骤 5：更新 feeds ────────────────────────────────────
update_feeds() {
    info "更新 feeds（可能需要 5-15 分钟）..."
    cd "$LEDE_DIR"
    ./scripts/feeds update -a
    ./scripts/feeds install -a
}

# ── 步骤 6：执行 diy-part2（清除冲突包）─────────────────
run_diy2() {
    info "执行 diy-part2.sh（清除冲突，修改默认配置）..."
    cd "$LEDE_DIR"
    bash diy-part2.sh
}

# ── 步骤 7：补全 .config ──────────────────────────────────
defconfig() {
    info "make defconfig 补全配置..."
    cd "$LEDE_DIR"
    make defconfig
    info "当前配置预览（前 30 行）："
    head -30 .config
}

# ── 步骤 8：下载依赖包 ────────────────────────────────────
download() {
    info "下载编译依赖包..."
    cd "$LEDE_DIR"
    make download -j8
    # 检查并删除下载不完整的文件
    local broken
    broken=$(find dl -size -1024c | wc -l)
    if [ "$broken" -gt "0" ]; then
        warn "发现 $broken 个不完整文件，删除后重新下载..."
        find dl -size -1024c -exec rm -f {} \;
        make download -j8
    fi
    info "下载完成，再次检查..."
    find dl -size -1024c | wc -l | xargs -I{} bash -c '[ "{}" = "0" ] && echo "所有文件完整" || echo "仍有 {} 个文件不完整，请检查网络代理"'
}

# ── 步骤 9：编译 ──────────────────────────────────────────
compile() {
    local threads
    threads=$(nproc)
    info "开始编译，使用 $threads 线程（首次编译约需 3-5 小时）..."
    cd "$LEDE_DIR"

    # 先多线程，失败则降为单线程并输出详细日志
    if make -j"$threads"; then
        info "编译成功！"
    else
        warn "多线程编译失败，切换到单线程模式重试（会输出详细日志）..."
        make -j1 V=s 2>&1 | tee /tmp/openwrt-build.log | grep -E "^(make|ERROR|error)" || true
        error "编译失败，详细日志：/tmp/openwrt-build.log"
    fi

    info "固件输出目录：$LEDE_DIR/bin/targets/x86/64/"
    ls -lh "$LEDE_DIR/bin/targets/x86/64/"*.gz 2>/dev/null || \
    ls -lh "$LEDE_DIR/bin/targets/x86/64/"*.img 2>/dev/null || \
    warn "未找到 .gz/.img 文件，请检查 bin/targets/x86/64/ 目录"
}

# ── 步骤 10：增量编译（修改 .config 后用这个）────────────
rebuild() {
    info "增量编译（仅重新编译变化的包）..."
    cd "$LEDE_DIR"
    cp "$SCRIPT_DIR/.config" .config
    make defconfig
    make -j"$(nproc)" || make -j1 V=s
}

# ── 清理 ──────────────────────────────────────────────────
clean() {
    warn "清理编译产物（保留工具链，下次编译更快）..."
    cd "$LEDE_DIR"
    make clean
}

clean_all() {
    warn "完全清理（删除 build_dir 和工具链，下次需完整重编）..."
    cd "$LEDE_DIR"
    make distclean
}

# ── 主流程 ────────────────────────────────────────────────
main() {
    case "${1:-full}" in
        full)
            install_deps
            clone_or_update
            copy_configs
            run_diy1
            update_feeds
            run_diy2
            defconfig
            download
            compile
            ;;
        update)
            # 已有编译环境，仅更新源码和 feeds 后重编
            clone_or_update
            copy_configs
            run_diy1
            update_feeds
            run_diy2
            defconfig
            download
            compile
            ;;
        rebuild)
            # 仅重新编译（修改 .config 后使用）
            copy_configs
            rebuild
            ;;
        clean)   clean ;;
        distclean) clean_all ;;
        deps)    install_deps ;;
        *)
            echo "用法: $0 [full|update|rebuild|clean|distclean|deps]"
            echo "  full       — 全新完整编译（默认）"
            echo "  update     — 更新源码+feeds 后重编"
            echo "  rebuild    — 仅用当前 .config 增量编译"
            echo "  clean      — 清理编译产物（保留工具链）"
            echo "  distclean  — 完全清理"
            echo "  deps       — 仅安装系统依赖"
            ;;
    esac
}

main "$@"
