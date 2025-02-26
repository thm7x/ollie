package service

import (
	"context"
	account "code.pypygo.com/vertex/ollie/apps/account/kitex_gen/account"
)

type BatchUpdateAccountService struct {
	ctx context.Context
} // NewBatchUpdateAccountService new BatchUpdateAccountService
func NewBatchUpdateAccountService(ctx context.Context) *BatchUpdateAccountService {
	return &BatchUpdateAccountService{ctx: ctx}
}

// Run create note info
func (s *BatchUpdateAccountService) Run(req *account.BatchUpdateAccountRequest) (resp *account.BatchUpdateAccountResponse, err error) {
	// Finish your business logic.

	return
}
