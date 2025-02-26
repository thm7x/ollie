#!/bin/bash
# sh _teamplate/rollback.sh.sh 分支版本 
# sh _teamplate/rollback.sh.sh v23.1005

set -ex

# 获取命令行参数
version="$1"

if [ "$version" = "primary" ]; then
    echo "priamry版本不能全量，异常退出"
    exit 1
fi

# 检查参数是否为空
if [ -z "$version" ]; then
    echo "分支版本参数 为空,请提供有效的重试"
    exit 1
fi


# 回复当前分支版本时刻当前primary版本
if [ -d "../primary_log/$version" ]; then
  rm -rf ../primary/*
  cp -R ../primary_log/$version/* ../primary/
fi
