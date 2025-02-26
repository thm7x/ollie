# 使用go work来管理大仓项目

### 1. 开发系统，IDE及推荐IDE插件，容器云集群
- windows(wsl)/mac/linux : go1.23+  
- vscode : go, `git graph`, `git History`, gitless, buf, `Protobuf(Protocol Buffers)`,mirrord 
- 本地kubectl可访问的kubernetes集群


### 2. clone项目默认main存档分支，用于checkout迭代分支的起点
```shell
# 默认main分支最新提交的repo tree
git clone --depth 1 git@code.pypygo.com:vertex/ollie.git
```

### 3. 配置.netrc，用于go mod下载私有库
```shell
cat <<EOF > ~/.netrc
machine code.pypygo.com
login your-login-username
password your-password
EOF
```

#### 4. 一键初始化本地开发环境
```shell
make init
```

### 5. 本地云开发方式运行
使用mirrord + vscode debug工具本地debug方式选择运行指定服务