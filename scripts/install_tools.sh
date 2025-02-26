#!/bin/bash
set -ex

# 检查gitHooksPath配置 
if ! git config --get core.hooksPath >/dev/null; then
    git config core.hooksPath scripts/githooks
    echo "Set hooksPath to.githooks."
    git config --global url."git@code.pypygo.com".insteadof "https://code.pypygo.com"
    go env -w GOPRIVATE=code.pypygo.com/vertex/*
fi

# 检查cmd工具
if ! command -v buf &> /dev/null
then
    go install github.com/bufbuild/buf/cmd/buf@v1.17.0
fi

if ! command -v protoc-gen-go &> /dev/null
then
    go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.30.0
fi

if ! command -v kitex &> /dev/null
then
    go install github.com/cloudwego/kitex/tool/cmd/kitex@latest
fi

if ! command -v grpcurl &> /dev/null
then
    go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
fi

if ! command -v cwgo &> /dev/null
then
    go install github.com/cloudwego/cwgo@latest
fi


if ! command -v gofumpt &> /dev/null
then
    go install mvdan.cc/gofumpt@latest
fi

if ! command -v golangci-lint &> /dev/null
then
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.60.1
fi

if ! command -v air &> /dev/null
then
    go install github.com/air-verse/air@latest
fi
