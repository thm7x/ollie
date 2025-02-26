#!/bin/bash
# sh _teamplate/svc_primary.sh
# sh _teamplate/svc_primary.sh
# 工程deploy初始化

set -ex

envCluster="prod-cluster"
branchName=$(git symbolic-ref --short HEAD)
branchVersion=$(echo "$branchName" | cut -d'/' -f2-)
branchVersionDir="_deploy/$envCluster/svc-kustomize/$branchVersion"


echo "即将在 $envCluster 集群里全量 $branchName 分支里变动的服务吗? (y/n)"
read answer
while [ "$answer"!= "y" ] && [ "$answer"!= "n" ]; do
    echo "无效输入. 请输入 y 或 n "
    read answer
done

if [ "$answer" = "y" ]; then
    echo "$branchName 分支变动服务全量中..."
else
    if [ "$answer" = "n" ]; then
        echo "退出..."
        exit 0
    else
        echo "Waiting for input..."
        # 可以在这里添加等待输入的相关逻辑，或者留空等待用户再次输入
    fi
fi


cd $branchVersionDir
source ../../../_teamplate/primary.sh $branchVersion

### 追后本地提交即可
git add .
# git commit -am "【$envCluster 全量】$branch_name: ${unique_merged_array[@]} "
# git push --set-upstream origin $branch_name