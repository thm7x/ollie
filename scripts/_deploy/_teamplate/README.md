_deploy/_teamplate 服务部署yaml模板，可能存在web,grpc,http前缀目录，表意不同协议服务

模板类：
apigateway 单版本proto兼容的网关部署模板
grpc-<svc> grpc 服务部署模板
web-<svc> caddy web服务部署模板

脚本类:
gray.sh 脚本用于 灰度 灰度分支版本
primary.sh 脚本用于 全量 灰度好的分支版本
rollback.sh 脚本用于 回滚 已全量灰度分支版本