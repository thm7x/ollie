package service

import (
	"context"
	account "code.pypygo.com/vertex/ollie/apps/account/kitex_gen/account"
)

type QueryAccountsService struct {
	ctx context.Context
} // NewQueryAccountsService new QueryAccountsService
func NewQueryAccountsService(ctx context.Context) *QueryAccountsService {
	return &QueryAccountsService{ctx: ctx}
}

// Run create note info
func (s *QueryAccountsService) Run(req *account.QueryAccountRequest) (resp *account.QueryAccountResponse, err error) {
	// Finish your business logic.

	return
}
