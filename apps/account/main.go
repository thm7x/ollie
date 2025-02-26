package main

import (
	"net"

	"code.pypygo.com/vertex/devkit/config"
	"code.pypygo.com/vertex/devkit/db"
	"code.pypygo.com/vertex/devkit/logger"
	"code.pypygo.com/vertex/devkit/protos/authorization/kitex_gen/authorization/authorization"
	"code.pypygo.com/vertex/devkit/utils"
	"github.com/cloudwego/kitex/pkg/klog"
	"github.com/cloudwego/kitex/pkg/rpcinfo"
	"github.com/cloudwego/kitex/server"

	"code.pypygo.com/vertex/ollie/apps/account/kitex_gen/account/accountservice"
)

func main() {
	opts := kitexInit()

	// 创建kitex服务
	svr := server.NewServer(opts...)
	accountservice.RegisterService(svr, new(AccountServiceImpl))
	// 更新当前服务grpc method资源
	utils.UpSertServiceApis(svr.GetServiceInfos(), config.ConfViper.GetString("kitex.service"), db.PgDB)
	// 注册envoy authz服务
	authorization.RegisterService(svr, new(AuthorizationImpl))
	// 注册K8S health服务,autz服务不需要这个内置health服务
	// health.RegisterService(svr, new(utils.K8sHealthProbeImpl))

	err := svr.Run()
	if err != nil {
		klog.Error(err.Error())
	}
}

func kitexInit() (opts []server.Option) {
	config.InitViperConfig()
	logger.InitZeroLogger()
	db.InitPostgres()

	// address
	addr, err := net.ResolveTCPAddr("tcp", config.ConfViper.GetString("kitex.address"))
	if err != nil {
		panic(err)
	}
	opts = append(opts, server.WithServiceAddr(addr))

	// service info
	opts = append(opts, server.WithServerBasicInfo(&rpcinfo.EndpointBasicInfo{
		ServiceName: config.ConfViper.GetString("kitex.service"),
	}))

	return
}
