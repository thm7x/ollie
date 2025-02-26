package main

import (
	"context"
	"fmt"
	"strings"

	"code.pypygo.com/vertex/devkit/config"
	corev3 "github.com/envoyproxy/go-control-plane/envoy/config/core/v3"
	typev3 "github.com/envoyproxy/go-control-plane/envoy/type/v3"

	"code.pypygo.com/vertex/devkit/authz"
	"code.pypygo.com/vertex/devkit/db"

	"code.pypygo.com/vertex/devkit/jwt"
	"code.pypygo.com/vertex/devkit/protos/authorization/kitex_gen/authorization"

	"code.pypygo.com/vertex/ollie/apps/account/kitex_gen/account"
	"google.golang.org/genproto/googleapis/rpc/status"
	"google.golang.org/grpc/codes"
)

const (
	Xauthorization    = "x-authorization"
	checkHeader       = "x-ext-authz"
	versionHeader     = "x-api-version"
	allowedValue      = "allow"
	resultHeader      = "x-ext-authz-check-result"
	receivedHeader    = "x-ext-authz-check-received"
	overrideHeader    = "x-ext-authz-additional-header-override"
	overrideGRPCValue = "grpc-additional-header-override-value"
	resultAllowed     = "allowed"
	resultDenied      = "denied"
)

var denyBody = fmt.Sprintf("denied by ext_authz for not found header `%s: %s` in the request", checkHeader, allowedValue)

// AuthorizationImpl implements the last service interface defined in the IDL.
type AuthorizationImpl struct{}

// Check implements the AuthorizationImpl interface.
func (s *AuthorizationImpl) Check(ctx context.Context, req *authorization.CheckRequest) (resp *authorization.CheckResponse, err error) {
	attrs := req.GetAttributes()
	httpAttrs := attrs.GetRequest().GetHttp()
	var versionVirtualEnvFlag *corev3.HeaderValue

	fmt.Printf("envoy扩展进入he %s...\n", httpAttrs.Path)
	// Determine whether to allow or deny the request.
	allow := false
	tokenValue, contains := httpAttrs.GetHeaders()[Xauthorization]
	if contains {
		// 使用jwt是合法有效
		jwtInfo, err := jwt.ParseToken(tokenValue)
		if err != nil {
			allow = false
		} else {
			var result account.TSysAccount
			// 缓存优化IO TODO
			err = db.PgDB.First(&result, jwtInfo.UID).Error
			if err == nil {
				// 检查拉黑标记和role配置或比较last_login_time使得旧的仍然有效的token主动失效
				// TODO pc 或 app，要提示账号在其他设备登录，是否抢占登录
				if result.IsDeleted || !result.IsEnable {
					allow = false
				} else {
					// sub, obj, act （id/roles , apipath, post）
					allow = jwt.BatchCheck(nil, httpAttrs.Method, httpAttrs.Path, authz.Enforcer)
					if allow {
						// 内存动态读取graymap,重写UID的api版本标记到响应header
						graymap := config.GrayViper.AllSettings()
						for key, value := range graymap {
							strValue, ok := value.(string)
							if ok {
								parts := strings.Split(strValue, ": ")
								if len(parts) == 2 {
									version := parts[0]
									numbersStr := parts[1]
									// jwtInfo.UID 确保是完整的uid位数 TODO
									if strings.Contains(numbersStr, string(jwtInfo.UID)) {
										versionVirtualEnvFlag = &corev3.HeaderValue{
											Key:   versionHeader,
											Value: version,
										}
										_ = result
										break
									}
								} else {
									fmt.Printf("Key: %s, Invalid format\n", key)
								}
							}
						}
					}
				}
			} else {
				allow = false
			}
		}
	}
	if allow {
		return s.allow(req, versionVirtualEnvFlag), nil
	}

	return s.deny(req), nil
}

func (s *AuthorizationImpl) allow(request *authorization.CheckRequest, versionVirtualEnvFlag *corev3.HeaderValue) *authorization.CheckResponse {
	// s.logRequest("allowed", request)
	return &authorization.CheckResponse{
		HttpResponse: &authorization.CheckResponse_OkResponse{
			OkResponse: &authorization.OkHttpResponse{
				Headers: []*corev3.HeaderValueOption{
					{
						Header: &corev3.HeaderValue{
							Key:   resultHeader,
							Value: resultAllowed,
						},
					},
					{
						Header: &corev3.HeaderValue{
							Key:   receivedHeader,
							Value: request.GetAttributes().String(),
						},
					},
					{
						Header: &corev3.HeaderValue{
							Key:   overrideHeader,
							Value: overrideGRPCValue,
						},
					},
					{
						Header: versionVirtualEnvFlag,
					},
				},
			},
		},
		Status: &status.Status{Code: int32(codes.OK)},
	}
}

func (s *AuthorizationImpl) deny(request *authorization.CheckRequest) *authorization.CheckResponse {
	// s.logRequest("denied", request)
	return &authorization.CheckResponse{
		HttpResponse: &authorization.CheckResponse_DeniedResponse{
			DeniedResponse: &authorization.DeniedHttpResponse{
				Status: &typev3.HttpStatus{Code: typev3.StatusCode_Forbidden},
				Body:   denyBody,
				Headers: []*corev3.HeaderValueOption{
					{
						Header: &corev3.HeaderValue{
							Key:   resultHeader,
							Value: resultDenied,
						},
					},
					{
						Header: &corev3.HeaderValue{
							Key:   receivedHeader,
							Value: request.GetAttributes().String(),
						},
					},
					{
						Header: &corev3.HeaderValue{
							Key:   overrideHeader,
							Value: overrideGRPCValue,
						},
					},
				},
			},
		},
		Status: &status.Status{Code: int32(codes.PermissionDenied)},
	}
}
