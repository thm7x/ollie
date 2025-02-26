package service

import (
	"context"
	account "code.pypygo.com/vertex/ollie/apps/account/kitex_gen/account"
)

type RefreshTokenService struct {
	ctx context.Context
} // NewRefreshTokenService new RefreshTokenService
func NewRefreshTokenService(ctx context.Context) *RefreshTokenService {
	return &RefreshTokenService{ctx: ctx}
}

// Run create note info
func (s *RefreshTokenService) Run(req *account.RefreshTokenRequest) (resp *account.RefreshTokenResponse, err error) {
	// Finish your business logic.

	return
}
