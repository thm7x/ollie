.PHONY: all
all: help

#imagehub gitea
# https://docs.gitea.com/zh-cn/1.20/usage/packages/container
REGISTRY := code.pypygo.com
#imagehub ns组织名
NS_GROUP := vertex

PROJECT := $(shell basename $(shell git rev-parse --show-toplevel))
GIT_COMMIT := $(shell git rev-parse --short HEAD)

DOCKERFILE :=
ifeq ($(svc), gateway)
	DOCKERFILE := dockerfile-gateway
else
	DOCKERFILE := dockerfile
endif

default: help

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ <target> Option

.PHONY: init
init: ## 初始化开发环境配置 首次只执行一次 example: make init
	@scripts/install_tools.sh
	@git submodule add --force  -b main git@code.pypygo.com:vertex/${PROJECT}-protos.git protos
	@git submodule update --init  --recursive

.PHONY: pb
pb: ## 构建服务的pb自描述文件 example: make pb
	buf build -o ollie-api.binpb --as-file-descriptor-set
	# 查看服务列表
	grpcurl -protoset ollie-api.binpb list

.PHONY: image
image: ## 构建服务的容器镜像 example: make image svc=product
	podman build -f ${DOCKERFILE} --build-arg SERVICE=${svc} --build-arg VERSION=${VERSION}  --build-arg PROJECT=${PROJECT} \
	--build-arg GIT_COMMIT=${GIT_COMMIT} -t ${REGISTRY}/${NS_GROUP}/${PROJECT}-${svc}:${VERSION} .


.PHONY: deploy_init
deploy_init: ## 增量构建本分支版本K8S部署 example: make rollback domain=sz.he.com env=prod
	@scripts/deploy/init_primary.sh ${domain} ${env}

.PHONY: gray
gray: ## 灰度用户到本分支版本部署 example: make gray uid=23,34,344,556
	@scripts/deploy/svc_gray.sh ${uid}

.PHONY: primary
primary: ## 全量本分支版本部署 example: make primary
	@scripts/deploy/svc_primary.sh

.PHONY: rollback
rollback: ## 回滚本分支版本全量部署 example: make rollback
	@scripts/deploy/svc_rollback.sh

.PHONY: tidy
tidy: ## run `go mod tidy` for all go module
	@scripts/tidy.sh

.PHONY: lint
lint: ## run `gofmt` for all go module
	@gofmt -l -w app
	@gofumpt -l -w  app

.PHONY: vet
vet: ## run `go vet` for all go module
	@scripts/vet.sh

.PHONY: lint-fix
lint-fix: ## run `golangci-lint` for all go module
	@scripts/fix.sh

.PHONY: run
run: ## run {svc} server. example: make run svc=product
	@scripts/run.sh ${svc}

