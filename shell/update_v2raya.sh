#!/bin/bash

# 默认下载目录
DOWNLOAD_DIR="/root/v2raya_install"

# GitHub 项目地址（替换为目标项目的 API 地址）
GITHUB_API_URL="https://api.github.com/repos/v2rayA/v2rayA/releases/latest"

# 软件本地版本，假设存储在一个文件中（当前软件可直接使用命令检测版本，故不使用版本文件）
#LOCAL_VERSION_FILE="/data/v2rayA_version"

# 下载链接的前缀和后缀（用于拼接版本号）
DOWNLOAD_URL_PREFIX="https://github.com/v2rayA/v2rayA/releases/download/"
DOWNLOAD_URL_SUFFIX="/installer_redhat_x64_"

# 检查下载目录是否存在，不存在则创建
if [ ! -d "$DOWNLOAD_DIR" ]; then
  echo "创建下载目录: $DOWNLOAD_DIR"
  mkdir -p "$DOWNLOAD_DIR"
fi

# 获取本地版本号
# （当前软件可直接使用命令检测版本，故不使用版本文件）
#if [ -f "$LOCAL_VERSION_FILE" ]; then
#  LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE")
#else
#  echo "本地版本文件不存在，假设版本为空"
#  LOCAL_VERSION=""
#fi
LOCAL_VERSION=`v2raya --version`

# 获取 GitHub 最新版本号
echo "检测 GitHub 上的最新版本..."
LATEST_VERSION=$(curl -s "$GITHUB_API_URL" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')

if [ -z "$LATEST_VERSION" ]; then
  echo "无法获取最新版本号，请检查网络或 API 地址"
  exit 1
fi

echo "本地版本: $LOCAL_VERSION"
echo "最新版本: $LATEST_VERSION"

# 比较版本号
if [ "$LOCAL_VERSION" = "$LATEST_VERSION" ]; then
  echo "当前已是最新版本，无需更新"
else
  echo "发现新版本，准备下载..."

  # 拼接下载链接
  DOWNLOAD_URL="${DOWNLOAD_URL_PREFIX}v${LATEST_VERSION}${DOWNLOAD_URL_SUFFIX}${LATEST_VERSION}.rpm"

  # 下载新版本到指定目录
  TARGET_FILE="$DOWNLOAD_DIR/installer_redhat_x64_${LATEST_VERSION}.rpm"

  echo "下载最新安装包: $DOWNLOAD_URL"
  curl -L "$DOWNLOAD_URL" -o "$TARGET_FILE"

  if [ $? -eq 0 ]; then
    echo "下载完成: $TARGET_FILE"
    # 更新本地版本号文件（当前软件可直接使用命令检测版本，故不使用版本文件）
    #echo "$LATEST_VERSION" > "$LOCAL_VERSION_FILE"
    #echo "本地版本号已更新为: $LATEST_VERSION"

    # 安装最新版本
    rpm -ivh --replacefiles --force --nodeps $TARGET_FILE
  else
    echo "下载失败，请检查网络连接或下载链接"
    exit 1
  fi
fi

