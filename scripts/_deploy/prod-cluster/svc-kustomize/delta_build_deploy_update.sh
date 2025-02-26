#!/bin/bash
set -ex
# 1.分析当前提交变动的服务
# 2.基于获得的服务列表生成各自kustomize yaml文件并更新到对应集群目录结构中
# 3. commit  deploy备注 && push


# 检查本地是否有未提交的修改(工作区|暂存区)
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "存在未提交的修改,请提交或stash这些修改,再提交部署commit。"
    exit 1
fi

# main全量部署存档的 commit hash 和 当前分支未构建的 commit hash 
MAIN_HEAD_COMMIT="origin/main"
CURRENT_COMMIT="HEAD"

# 更新一次远端main 存档分支最新提交信息
git fetch origin main

# api变动：比较分支protos目录里最新全量构建和最新提交之间服务接口的变动 TODO
api_changed_files=$(git diff "$MAIN_HEAD_COMMIT"..."$CURRENT_COMMIT" --name-only --diff-filter=ACM  -- protos/app/**/*.proto)


# go服务实现变动：比较分支protos目录里最新全量构建和最新提交之间服务内部实现的变动 TODO
svcImp_changed_files=$(git diff "$MAIN_HEAD_COMMIT"..."$CURRENT_COMMIT"  --name-only  --diff-filter=ACM  -- app/**/*.go )
if [ -n "$_changeServicefile" ]; then
  unique_changeSvcs=$(echo "${_changeServicefile[@]}" | grep -Po "(?<=\/)[^\/]+(?=\/)" | sort -u)
fi

# 最后 三方去并集： unique_changeSvcs + unique_apiSvcs + dep_svcs 结果即是需要为这次发版分支commit变动增量构建的服务了
build_svc_merged=($(echo "${unique_apiSvcs[@]}" "${dep_svcs[@]}" "${unique_changeSvcs[@]}" | tr ' ' '\n' | sort -u))

# TODO 镜像构建分析
# build_svc_merged 循环这个服务名，并按个数<svc>:<CURRENT_COMMIT> >> delta_build.yaml里.供提交后ci精准构建源码镜像并上传imageshub里，供K8S重试部署时pull


## TODO 版本服务增改yaml生成，删除手动删除版本目录里服务目录即可
## 获取当前分支名里"/"后的版本语义信息
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
VERSION_DESC=$(echo "$CURRENT_BRANCH" | cut -d'/' -f2-)

# 识别分支类型(hotfix|release|feature)且更新kustomize目录对应集群里增量版本目录部署声明信息
### feature类型则对应dev-cluster集群部署，否则为prod-cluster集群部署
if [[ "$current_branch" == feature/* ]]; then
  # 操作dev-cluster集群kustomize
  echo "The current branch '$current_branch' starts with 'feature/'."
  # TODO
  # 1. 基于shell模板生成版本服务
else
  # 操作prod-cluster集群kustomize
  echo "The current branch '$current_branch' does not start with 'feature/'."
  # TODO
  # 1. 基于shell模板生成版本服务或bash更新服务
  # 1.1 如果版本目录已存在，服务不存在则生成。如果目录都不存在，则新建目录且生成服务
  # 1.2 如果版本目录已存在，服务也存在，则更新版本目录里kustomization.yaml images对应服务的tag为CURRENT_COMMIT
fi