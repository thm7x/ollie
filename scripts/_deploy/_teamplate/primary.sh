#!/bin/bash
# sh _teamplate/primary.sh 分支版本 
# sh _teamplate/primary.sh v23.1005

set -ex

# 检查本地是否有未提交的修改(工作区|暂存区)
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "存在未提交的修改,请提交或stash这些修改,再提交部署commit。"
    exit 1
fi

project=$(basename "$(git rev-parse --show-toplevel)")
ns="env-prod"

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


# 备份当前版本时刻当前primary版本
if [ -d "../primary_log/$version" ]; then
    rm -rf ../primary_log/$version
fi
mkdir -p ../primary_log/$version
cp -R ../primary/* ../primary_log/$version


primary_svcs=()
##读取版本目录下的kustomization.yaml
# 获取已经全量的服务集合
for dir in ../primary/*/; do
    if [ -d "$dir" ]; then
        primary_svc_name=$(basename "$dir")
        mapfile -t primary_svcs < "$primary_svc_name"
    fi
done

# 比较是否有新增
for dir in ./*/; do
    if [ -d "$dir" ]; then
        svc_name=$(basename "$dir")
        if [[ " ${primary_svcs[@]} " =~ " $svc_name " ]]; then
            ##存在则更新tag到primary里kustomization.yaml tag
            primary_update_svc_imagetag $svc_name 
        else
            ##新增服务deploy
            primary_gen_svc $svc_name
        fi
    fi
done


#清除已经全量的灰度版本目录
cd .. && rm -rf ./$version
echo "primary done."



primary_update_svc_imagetag() {
    ##找到整条删除，然后当前版本替换进去
    local _svc_name=$1
    #提取当前版本服务的镜像tag值
    gray_tag=$(sed -n "/-${_svc_name}/{n;s/.*newTag: //p}" kustomization.yaml)
    #替换primary里服务对应的值
    sed -i "/-${_svc_name}/{n;s/newTag:.*$/newTag: ${gray_tag}/}" ../primary/kustomization.yaml
}

primary_gen_svc() {
    ## 追加末尾即可
    local _svc_name=$1
    gray_tag=$(sed -n "/-${_svc_name}/{n;s/.*newTag: //p}" kustomization.yaml)
    ##补齐 TODO
    #服务deploy配置项
    svcPort=$(sed -n 's/.*address: "\:\([0-9]\+\)".*/\1/p' ../../../../app/$_svc_name/conf/conf.yaml)
    nodeSuffix=$(sed -n 's/.*nodesuffix: //p' ../../../../app/$_svc_name/conf/conf.yaml)
    servicetype=$(sed -n 's/.*servicetype: //p' ../../../../app/$_svc_name/conf/conf.yaml)
    imagens=$(sed -n 's/.*imagens: //p' ../../../../app/$_svc_name/conf/conf.yaml)

    ##灰度分支新服务 完整的crd资源
    source ../../../_teamplate/gray.sh $project $ns $_svc_name $svcPort $gray_tag $ns-$nodeSuffix primary $servicetype $imagens

}