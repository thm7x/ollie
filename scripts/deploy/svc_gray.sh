#!/bin/bash

##
## 灰度： 分析分支服务增量部署集合，更新或新增版本服务对应集群deploy yaml，更新或新增版本和userid对应关系文件
##

set -ex

# 检查本地是否有未提交的修改(工作区|暂存区)
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "存在未提交的修改,请提交或stash这些修改,再提交部署commit。"
    exit 1
fi

project=$(basename "$(git rev-parse --show-toplevel)")
branchName=$(git symbolic-ref --short HEAD)
echo "当前分支名:$branchName"
branch_sha=$(git rev-parse --short HEAD)

unique_merged_array=()
unique_apiSvcs=()
unique_changeSvcs=()
dep_svcs=()

build_all=""
envCluster=""
ns=""
branchVersionDir=""
branchVersion=$(echo "$branchName" | cut -d'/' -f2-)

if [[ $branchName =~ release/v[0-9]{2}\.[0-9]{4} || $branchName =~ hotfix/v[0-9]{2}\.[0-9]{4}-[0-9]+ ]]; then
    envCluster="prod-cluster"
    ns="env-prod"
    branchVersionDir="_deploy/prod-cluster/svc-kustomize/$branchVersion"
    echo "环境变量设置为：$env"
fi
if [[ $branchName =~ feature/.* ]];then
   envClusterr="dev-cluster"
   ns="env-test"
   branchVersionDir="_deploy/dev-cluster/svc-kustomize/$branchVersion"
fi

if [ -z "$envCluster" ]; then
    echo "env-cluster 为空,该$branchName 分支不支持灰度或格式不对，退出。"
    exit 1
fi



echo "即将在 $envCluster 集群里灰度 $branchName 分支里变动的服务吗? (y/n)"
read answer
while [ "$answer"!= "y" ] && [ "$answer"!= "n" ]; do
    echo "无效输入. 请输入 y 或 n "
    read answer
done

if [ "$answer" = "y" ]; then
    echo "$branchName 分支变动服务灰度中..."
else
    if [ "$answer" = "n" ]; then
        echo "退出..."
        exit 0
    else
        echo "Waiting for input..."
        # 可以在这里添加等待输入的相关逻辑，或者留空等待用户再次输入
    fi
fi


echo "更新origin main分支信息"
git fetch origin main

# 清空deploy.svc，内容精准表示当前分支增量服务
rm -rf deploy.svc

#分析pb变化
cd protos
git fetch origin main
git submodule update --init  --recursive
pb_branch_sha=$(git rev-parse --short HEAD)
echo "👋-----protos仓库对应sha为：$pb_branch_sha "
# lib目录里proto文件的修改-包含注释，则视为构建全部，直接commit：all
_apichangefile=$(git diff origin/main...$pb_branch_sha --name-only  --diff-filter=ACM  ./**/*.proto || true)
if [ -n "$_apichangefile" ]; then
  # 提取proto 第一个目录，目前：app和lib
  fist_dirs=$(echo "${_apichangefile[@]}" | awk -F'/' '{print $1}')
  # 判断是否存在全局lib改变，则设置 全部构建 标记
  if [[ "${fist_dirs[@]}" =~ lib ]]; then
    # 全部服务贪婪标记
    build_all="true"
  else
    # 增量去重
    unique_apiSvcs=$(echo "${_apichangefile[@]}" | awk -F'/' '{print $2}' | sort -u)
  fi

  # api变更 更新istio ingressgateway网关部署和grpc-json coder配置
  echo "apigateway:$branch_sha" > ../deploy.svc
  sed -i "s/-apigateway:[^:]*$/-apigateway:${branch_sha}/" ../_deploy/$envCluster/svc-kustomize/apigateway/patch.yaml

fi

if [ "$build_all" == "true" ]; then
  # 全部服务数组
  unique_merged_array=($(find ./app -mindepth 1 -maxdepth 1 -type d -printf "%P\n"))
  # 数组复制
  unique_apiSvcs=("${unique_merged_array[@]}")

fi

# 更新grpc-json encoder desc
for api_svc in "${unique_apiSvcs[@]}"; do
  api_svc_found=$(grep -w "${api_svc}.${api_svc^}" ../_deploy/$envCluster/svc-kustomize/apigateway/istio-filter-jsontranscoder.yaml || true)
  ##不存在则追加一项
  if [ -z "$api_svc_found" ]; then
    sed -i "/services:/a\\          - ${api_svc}.${api_svc^}" ../_deploy/$envCluster/svc-kustomize/apigateway/istio-filter-jsontranscoder.yaml
  fi
done

# 回退到项目root目录
cd -

if [ "$build_all" != "true" ]; then
  #分析go源码变化
  git fetch origin main
  _changeServicefile=$(git diff origin/main...$branch_sha --name-only  --diff-filter=ACM app/**/*.go || true)
  if [ -n "$_changeServicefile" ]; then
    unique_changeSvcs=$(echo "${_changeServicefile[@]}" | grep -Po "(?<=\/)[^\/]+(?=\/)" | sort -u)
  fi

  # 增量服务依赖处理
  # 输出截取并去重后的结果unique_apiSvcs ,拿这个里的每项取app里遍历所有 conf/conf.yaml配置里是否有自己，有自己再次输出dep_svcs里即可
  for item in "${unique_apiSvcs[@]}"; do
    for app_dir in "${unique_apiSvcs[@]}"; do
      if [[ $item != $app_dir ]];then
        found=$(grep -o -w "$item" "app/$app_dir/conf/conf.yaml")
        if [ -n "$found" ]; then
            mapfile -t dep_svcs < "$app_dir"
        fi
      fi
    done
  done

  # 最后 三方取并集： unique_changeSvcs + unique_apiSvcs + dep_svcs 结果即是需要为这次发版分支commit变动增量构建的服务了
  unique_merged_array=($(echo "${unique_apiSvcs[@]}" "${dep_svcs[@]}" "${unique_changeSvcs[@]}" | tr ' ' '\n' | sort -u))

fi

# 判断并集数组是否为空，空则不做任何事 异常退出
if [[ ${#unique_merged_array[@]} -eq 0 ]]; then
  echo "😊 和main比对 无任何实质变化..正常退出"
  exit 0
else
  #更新deploy.svc，供ci精致构建images,其中authx这种单版本要特殊处理：保持接口兼容，不参与灰度
  for svc in "${unique_merged_array[@]}"; do
    # svc:tag
    echo "$svc:$branch_sha" >>  deploy.svc
  done
fi


## deploy gen branch
## 新版本则创建kustomization.yaml
if [ ! -d "$branchVersionDir" ]; then
    mkdir -p $branchVersionDir
cat <<EOF > $branchVersionDir/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: $ns
resources:

images:

EOF
fi

##进入版本目录更新服务集合
cd $branchVersionDir
for svc in "${unique_merged_array[@]}"; do
  #取得服务deploy配置项
  svcPort=$(sed -n 's/.*address: "\:\([0-9]\+\)".*/\1/p' ../../../../apps/$svc/conf/conf.yaml)
  nodeSuffix=$(sed -n 's/.*nodesuffix: //p' ../../../../apps/$svc/conf/conf.yaml)
  servicetype=$(sed -n 's/.*servicetype: //p' ../../../../apps/$svc/conf/conf.yaml)
  imagens=$(sed -n 's/.*imagens: //p' ../../../../apps/$svc/conf/conf.yaml)
  # 是否是单版本：即只有全量版本
  onlyPrimaryVersion=$(sed -n 's/.*only_primary_version: //p' ../../../../apps/$svc/conf/conf.yaml)

  if [ "$onlyPrimaryVersion" == "true" ];then
    # 进入primary操作版本目录
    cd ../primary
    if [ "$svc" == "authx" ];then
      # 更新网关authx tag
      sed -i "s/-authx:[^:]*$/-authx:${branch_sha}/" ../apigateway/patch.yaml
    else
      #更新primary目录下服务
      #判断primary版本里是否有 新增服务 -o 或
      result=$(find ../primary -maxdepth 1 -type d -name "grpc-$svc" -o -name "web-$svc")
      if [[ -n $result ]]; then
        # 服务：已存在全量版本，只生成部分crd
        source ../../../_teamplate/gray.sh $project $ns $svc $svcPort $branch_sha $ns-$nodeSuffix primary $servicetype $imagens
      else
        # 服务：集群中不存在，生成全部crd
        source ../../../_teamplate/gray.sh $project $ns $svc $svcPort $branch_sha $ns-$nodeSuffix primary $servicetype $imagens true
      fi
    fi
    # 退出primary操作版本目录，回到分支版本目录
    cd -
  else
    #判断灰度版本里是否有新增服务 -o 或
    result=$(find ../primary -maxdepth 1 -type d -name "grpc-$svc" -o -name "web-$svc")
    if [[ -n $result ]]; then
      # 服务：已存在全量版本，只生成部分crd
      source ../../../_teamplate/gray.sh $project $ns $svc $svcPort $branch_sha $ns-$nodeSuffix $branchVersion $servicetype $imagens
    else
      # 服务：集群中不存在，生成全部crd
      source ../../../_teamplate/gray.sh $project $ns $svc $svcPort $branch_sha $ns-$nodeSuffix $branchVersion $servicetype $imagens true
    fi
  fi
done


## gray uid branch configmap
## 判断是否 新分支版本
version_found=$(grep -w $branchVersion ../_gray_release_cm.yaml || true)
## 不存在则追加一项
if [ -z "$version_found" ]; then
  echo "$branchVersion: ">> ../_gray_release_cm.yaml
fi

IFS=',' read -ra array <<< "${1}"
first=
for uid in "${array[@]}"; do
  uid_found=$(grep -w $uid ../_gray_release_cm.yaml || true)
  if [ -z "$uid_found" ]; then
      #新版本则尾部直接追加uid
    if [ -z "$version_found" ];then
        if [ -z "$first" ];then
          #首部直接追加uid，并标记 first="true"
          sed -i "/${branchVersion}/s/$/${uid}/" ../_gray_release_cm.yaml
          first="true"
        else
          #尾部,号直接追加uid
          sed -i "/${branchVersion}/s/$/,${uid}/" ../_gray_release_cm.yaml
        fi
    else
      #存在则行尾部,号追加uid
      sed -i "/${branchVersion}/s/$/,${uid}/" ../_gray_release_cm.yaml
    fi
  else
    #如果存在重复则异常退出，清除编辑
    echo $found | grep $uid 
    echo "上面uid已经存在灰度版本，即将撤销所有修改，请调整重试。"
    git checkout .
    exit 1
  fi
done

### 追后本地提交即可
git add .
# git commit -am "【$envCluster 灰度】$branch_name: ${unique_merged_array[@]} "
# git push --set-upstream origin $branch_name

# release/<version> | hotfix/<version> 的话，执行更新kustomize/prod-cluster里的服务manifest 文件
# feature/xxx 的话，执行执行更新kustomize/dev-cluster里的服务manifest 文件

# 线上ci runner操作manifest 内容，仅构建当前commit hash code的服务镜像并推送到镜像hub:即为只构建容器image。存档main。打tag

