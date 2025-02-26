prod-cluster集群承载 线上环境
- 集中的api网关服务 (env-api-gateway)
- 单一稳定的全量版本 primary (env-prod)
- 多个线上灰度版本 !primary (env-prod)

线上发版脚本：
- 灰度 <uid...> <releaseVersion>: 编辑_gray_release_cm.yaml
- 全量 <releaseVersion> : 编辑primary/kustomization.yaml，新增history
- 回滚 <historyReleaseVersion>：编辑primary/kustomization.yaml