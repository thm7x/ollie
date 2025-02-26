package service

import (
	"context"
	account "code.pypygo.com/vertex/ollie/apps/account/kitex_gen/account"
)

type LoginService struct {
	ctx context.Context
} // NewLoginService new LoginService
func NewLoginService(ctx context.Context) *LoginService {
	return &LoginService{ctx: ctx}
}

// Run create note info
func (s *LoginService) Run(req *account.LoginRequest) (resp *account.LoginResponse, err error) {
	// Finish your business logic.

	return
}
