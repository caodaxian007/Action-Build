#!/bin/sh
# SukiSU 4.19 内核集成脚本 适配MTK非GKI内核
set -e

KSU_BRANCH="${1:-main}"
KSU_SOURCE="https://github.com/ReSukiSU/ReSukiSU"

if [ ! -d .git ]; then
    echo "错误：请在你的内核git仓库根目录执行此脚本"
    exit 1
fi

echo "正在拉取SukiSU 4.19分支源码..."
if [ -d "KernelSU" ]; then
    echo "检测到已存在KernelSU目录，正在更新..."
    rm -rf KernelSU
fi

git clone --depth=1 -b k-4.19 "$KSU_SOURCE" KernelSU

echo "正在集成SukiSU到内核..."
# 适配4.19内核的Kconfig配置
if ! grep -q "KernelSU" fs/Kconfig; then
    echo "source \"KernelSU/Kconfig\"" >> fs/Kconfig
fi

# 适配4.19内核的Makefile
if ! grep -q "KernelSU" fs/Makefile; then
    echo "obj-y += KernelSU/" >> fs/Makefile
fi

# 打入MTK内核兼容补丁
echo "正在打入MTK 4.19内核兼容补丁..."
if [ -f "KernelSU/patches/mtk-4.19.patch" ]; then
    patch -p1 < KernelSU/patches/mtk-4.19.patch
fi

echo "✅ SukiSU 4.19集成完成！"
echo "请确保你的内核defconfig开启了CONFIG_KSU=y、CONFIG_KPROBES=y"
