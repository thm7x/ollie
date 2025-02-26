#!/bin/bash
# sh _teamplate/init_primary.sh <domain> <env>
# sh _teamplate/init_primary.sh domain=sz.he.com env=prod
# 工程_deploy环境初始化

set -ex
# 检查本地是否有未提交的修改(工作区|暂存区)
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "存在未提交的修改,请提交或stash这些修改,再提交部署commit。"
    exit 1
fi

project=$(basename "$(git rev-parse --show-toplevel)")

branchName=$(git symbolic-ref --short HEAD)
branch_sha=$(git rev-parse --short HEAD)
if [ "$branchName" != "main" ]; then
    echo "初始化操作必须在main分支上进行,当前"$branchName"分支不支持，退出"
    echo 1
fi

# 获取命令行参数
domain="$1"
env="$2"
# 检查参数是否合法
if [ -z "$domain" ] || [ -z "$env" ] || [[! "$env" =~ ^(dev|prod)$ ]]; then
    echo "请提供有效的完整网关域名或目标环境为 dev 或 prod。"
    exit 1
fi

##初始化默认为prod集群环境primary版本
envCluster=$env-cluster
ns="env-"$env
branchVersionDir="_deploy/$envCluster/svc-kustomize/primary"
if [ -d "$branchVersionDir" ]; then
    echo " primary集群已经初始化过..不做任何事退出"
    exit 0
fi

## 创建初始化目录
mkdir -p $branchVersionDir

## deploy gen primary /mian
## 创建primary版本kustomization
if [! -d "$branchVersionDir" ]; then
    mkdir -p $branchVersionDir
cat <<EOF > $branchVersionDir/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: $ns
# service mesh模式 批量更新sidecar容器版本
# patches:
#   # all biz sidecar imageupdate
#   - patch: |-
#       - op: replace
#         path: /spec/template/metadata/annotations/sidecar.istio.io~1proxyImage
#         value: ccr.ccs.tencentyun.com/vertex/ollie-istio-proxy:c58c7b3
#     target:
#       group: apps
#       version: v1
#       kind: Deployment
#       namespace: env-prod
#       labelSelector: "version=primary"

resources:
  - ../imagepull_secrets.yaml
  - ../casbin-rbac-model-cm.yaml

images:

EOF
fi

sidcarimagens=$(sed -n 's/.*imagens: //p' app/authx/conf/conf.yaml)

##切到svc-kustomize目录
cd "_deploy/$envCluster/svc-kustomize"

##网关处理，其中authx是内置在istio gateway pod里
cp -R ../../_teamplate/apigateway .
find apigateway -maxdepth 2 -type f -exec sed -i 's/<domain>/'$host'/g; s/<imagens>/'$sidcarimagens'/g; s/<project>/'$project'/g' {} \;
sed -i "s/-apigateway:[^:]*$/apigateway:${branch_sha}/; s/-authx:[^:]*$/authx:${branch_sha}/" ./apigateway/patch.yaml

## 共用的yaml
dir="../../_teamplate/comm-yaml"
# 遍历目录下的所有文件，并替换字符串并写入新文件
for file in "$dir"/*; do
    if [ -f "$file" ]; then  # 确保处理的是文件而不是目录
        output_file="./$(basename "$file")"
        # 替换输出
        sed -e "s/<project>/$project/g" -e "s/<ns>/$ns/g"  "$file" > "$output_file"
    fi
done

## primary版本及路由处理
##进入版本目录 更新服务集合
cd - && cd $branchVersionDir
#处理go/web服务,排除sidecar authx服务
# authx目前不开放api，
# 按字母顺序排序
for file in $(find "../../../../app" -type f -name "conf.yaml" | sort); do
    if [[ "$file" != *"authx"* ]]; then
        #取得服务deploy配置项
        svc=$(sed -n 's/.*service: //p' "$file")
        svcPort=$(sed -n 's/.*address: "\:\([0-9]\+\)".*/\1/p' "$file")
        nodeSuffix=$(sed -n 's/.*nodesuffix: //p' "$file")
        servicetype=$(sed -n 's/.*servicetype: //p' "$file")
        imagens=$(sed -n 's/.*imagens: //p' "$file")

        source ../../../_teamplate/primary.sh $project $ns $svc $svcPort $branch_sha $ns-$nodeSuffix primary $servicetype $imagens
        
        ##网关更新$svc
        # ../apigateway/ingressgateway-vs.yaml
        # grpc
        if [ "$servicetype" = "grpc" ]; then
grpc_svc_content=$(cat <<EOF
	- match:
			- uri:
					prefix: /api/${svc}
			- uri:
					prefix: /${svc}.${svc^}
			name: ${svc}_primary
			retries:
			attempts: 5
			retryOn: connect-failure,unavailable,503
			route:
			- destination:
					host: account.env-prod.svc.cluster.local
					subset: primary
			corsPolicy:
			allowOrigin:
			- "*"
			allowMethods:
			- POST
			- GET
			allowHeaders:
			- "*"
			maxAge: "24h"
EOF
)
        echo "$grpc_svc_content" >> ../apigateway/ingressgateway-vs.yaml
        fi

        # web
        if [ "$servicetype" = "web" ]; then
web_svc_content=$(cat <<EOF
	- match:
		- uri:
				prefix: /
		name: ${svc}_primary
		route:
		- destination:
				host: ${svc}.env-prod.svc.cluster.local
				port:
					number: 80
		corsPolicy:
			allowOrigin:
			- "*"
			allowMethods:
			- POST
			- GET
			allowHeaders:
			- "*"
			maxAge: "24h"
EOF
)
        echo "$web_svc_content" >> ../apigateway/ingressgateway-vs.yaml
        fi

        # http
    fi
done

### 追后本地提交即可
git add .
# git commit -am "【$envCluster 集群初始化】$branch_name: ${unique_merged_array[@]} "
# git push --set-upstream origin $branch_name