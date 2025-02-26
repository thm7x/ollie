#!/bin/bash
# sh _teamplate/gray.sh 项目名 环境名 grpc服务名 服务端口 服务镜像tag 部署节点 分支版本 类型 镜像hub空间 [灰度版本新服务全量crd标记]
# sh _teamplate/gray.sh pop env-prod order 7003 20c197f env-prod-grpc v23.1018 grpc ccr.ccs.tencentyun.com/vertex 

set -ex

# 获取命令行参数
project="$1"
ns="$2"
svc="$3"
port="$4"
imagetag="$5"
node="$6"
version="$7"
type="$8"
imagens=$(echo "$9" | sed 's/\//\\\//g')
allcrd="$10"

# 检查参数是否为空
if [ -z "$project" ] || [ -z "$ns" ] || [ -z "$svc" ] || [ -z "$version" ] || [ -z "$port" ] || [ -z "$imagetag" ] || [ -z "$node" ] || [ -z "$type" ] || [ -z "$imagens" ]; then
    echo "请提供齐全有效的参数,包含：项目名,环境名,服务名,服务镜像tag,部署节点, 分支版本, 服务类型,镜像hub空间"
    exit 1
fi

if [ "$type" = "grpc" ]; then
    # 创建输出目录
    out_dir="grpc-$svc"
    if [ -d "$out_dir" ]; then
        echo " $version 发布 $svc 服务目录已存在..仅更新kustomization.yaml 版本"
        sed -i "/-${svc}/{n;s/newTag:.*$/newTag: ${imagetag}/}" kustomization.yaml
        ##更新完退出
        exit 0
    fi

    mkdir  "$out_dir"
    dir="../../../_teamplate/grpc-<svc>"
    # 遍历目录下的所有文件，并替换字符串并写入新文件
    for file in "$dir"/*; do
        if [ -f "$file" ]; then  # 确保处理的是文件而不是目录
            output_file="$out_dir/$(basename "$file")"
            ## 全量服务或灰度版本里新增服务的全量资源
            if [[ "$version" == "primary" || "$allcrd" == "true" ]]; then
                # 全量版本全量资源
                sed -e "s/<project>/$project/g" -e "s/<ns>/$ns/g"  -e "s/<svc>/$svc/g" -e "s/<port>/$port/g" -e "s/<tag>/$imagetag/g" -e "s/<node>/$node/g" -e "s/<version>/$version/g" -e "s/<service-type>/$type/g" -e "s/<imagens>/$imagens/g"  "$file" > "$output_file"
            else
                # 灰度版本仅需资源:pod,dr,vs,kus,patch
                if [[ $output_file =~ (deploymen|istio-dr|istio-vs|kustomization|patch|) ]]; then
                    sed -e "s/<project>/$project/g" -e "s/<ns>/$ns/g"  -e "s/<svc>/$svc/g" -e "s/<port>/$port/g" -e "s/<tag>/$imagetag/g" -e "s/<node>/$node/g" -e "s/<version>/$version/g" -e "s/<service-type>/$type/g" -e "s/<imagens>/$imagens/g"  "$file" > "$output_file"
                fi
            fi
        fi
    done
    #新增kustomize资源项
    sed -i "/resources:/a\\  - ./${out_dir}/" kustomization.yaml
    sed -i "/images:/a\\  - name: ${imagens}/${project}-${svc}\n    newTag: ${imagetag}" kustomization.yaml

    ##网关更新$svc
    # ../apigateway/ingressgateway-vs.yaml
grpc_svc_content=$(cat <<EOF
  - match:
    - uri:
        prefix: /api/${svc}
    - uri:
        prefix: /${svc}.${svc^}
    name: ${svc}_${version}
    retries:
      attempts: 5
      retryOn: connect-failure,unavailable,503
    route:
    - destination:
        host: account.env-prod.svc.cluster.local
        subset: ${version}
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
    if  [ "$version" = "primary" ]; then
      ##追加即可
      cat "$grpc_svc_content" >> ../apigateway/ingressgateway-vs.yaml
    else
       sed -i "/http:/ r/dev/stdin" <<< "$grpc_svc_content" ../apigateway/ingressgateway-vs.yaml
    fi
 
elif [ "$type" = "web" ]; then
    # 创建输出目录
    out_dir="web-$svc"
    if [ -d "$out_dir" ]; then
        echo " $version 发布 $svc 服务目录已存在..仅更新kustomization.yaml 版本"
        sed -i "/-${svc}/{n;s/newTag:.*$/newTag: ${imagetag}/}" kustomization.yaml
        ##更新完退出
        exit 0
    fi
    mkdir -p "$out_dir"

    dir="../../../_teamplate/web-<svc>"
    # 遍历目录下的所有文件，并替换字符串并写入新文件
    for file in "$dir"/*; do
        if [ -f "$file" ]; then  # 确保处理的是文件而不是目录
            output_file="$out_dir/$(basename "$file")"
            ## 全量服务或灰度版本里新增服务的全量资源
            if [[ "$version" == "primary" || "$allcrd" == "true" ]]; then
                # 全量版本全量资源
                sed -e "s/<project>/$project/g" -e "s/<ns>/$ns/g"  -e "s/<svc>/$svc/g" -e "s/<port>/$port/g" -e "s/<tag>/$imagetag/g" -e "s/<node>/$node/g" -e "s/<version>/$version/g" -e "s/<service-type>/$type/g" -e "s/<imagens>/$imagens/g"  "$file" > "$output_file"
            else
                # 灰度版本仅需资源:pod,dr,vs,kus,patch
                if [[ $output_file =~ (deploymen|istio-dr|istio-vs|kustomization|patch|) ]]; then
                    sed -e "s/<project>/$project/g" -e "s/<ns>/$ns/g"  -e "s/<svc>/$svc/g" -e "s/<port>/$port/g" -e "s/<tag>/$imagetag/g" -e "s/<node>/$node/g" -e "s/<version>/$version/g" -e "s/<service-type>/$type/g" -e "s/<imagens>/$imagens/g"  "$file" > "$output_file"
                fi
            fi           
        fi
    done
    #新增kustomize资源项
    sed -i "/resources:/a\\  - ./${out_dir}/" kustomization.yaml
    sed -i "/images:/a\\  - name: ${imagens}/${project}-${svc}\n    newTag: ${imagetag}" kustomization.yaml
    ##网关更新$svc
    # ../apigateway/ingressgateway-vs.yaml
web_svc_content=$(cat <<EOF
  - match:
    - uri:
        prefix: /${svc}
    name: ${svc}_${version}
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
    if  [ "$version" = "primary" ]; then
      ##追加即可
      cat "$web_svc_content" >> ../apigateway/ingressgateway-vs.yaml
    else
      sed -i "/http:/ r/dev/stdin" <<< "$web_svc_content" ../apigateway/ingressgateway-vs.yaml
    fi
    
else
    echo "不支持的服务类型，退出。"
    exit 1
fi