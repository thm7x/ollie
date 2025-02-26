package service

import (
	"context"

	account "code.pypygo.com/vertex/ollie/apps/account/kitex_gen/account"
)

type AllUpdateAccountService struct {
	ctx context.Context
} // NewAllUpdateAccountService new AllUpdateAccountService
func NewAllUpdateAccountService(ctx context.Context) *AllUpdateAccountService {
	return &AllUpdateAccountService{ctx: ctx}
}

// Run create note info
func (s *AllUpdateAccountService) Run(req *account.AllUpdateAccountRequest) (resp *account.AllUpdateAccountResponse, err error) {
	// Finish your business logic.

	return
}
