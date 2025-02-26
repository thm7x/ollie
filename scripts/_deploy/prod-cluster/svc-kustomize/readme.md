网关入口 单版本 接口时刻要兼容

部署更新: 采用K8S的pod滚动更新


入口网关的路由 没有默认路由
处理http-->grpc的路由

网关http不需要匹配header

内部解析后内部再染色,出去的时候grpc匹配即可

把primary 和 其他灰度版本 vs分离,primary固定不变,除非有增减需求

其中 ingressgateway-vs-primary-http-grpc.yaml 和 ingressgateway-vs-version-http-grpc.yaml 不参与apply，而是作为ingressgateway-vs-http-grpc.yaml的http match的完整规则内容的顺序填充，apply的是ingressgateway-vs-http-grpc.yaml
这段逻辑有go操作


去阿里云创建TLS免费证书3个月 下载nginx那个压缩包到本地桌面tls目录,终端开启一个http静态服务供K8S机器wget下载对应文件即可
C:\Users\fire\Desktop\tls>python3 -m http.server

wget http://192.168.3.39:8000/cd.szbinze.cc.key
wget http://192.168.3.39:8000/cd.szbinze.cc.pem

然后执行脚本./update-tls.sh即可完成cd.szbinze.cc域名TLS更新


#### 网关不需要istio mesh sidecar



### 开发使用mirrord工具来镜像dev集群里的灰度版本来调试本地代码，仅支持dev集群
- dev-cluster目录里创建属于自己的灰度版本目录:<svc>-<gitUserName>
- 本地连接dev集群使用mirrord来选择自己灰度版本pod即可
