package service

import (
	"context"
	account "code.pypygo.com/vertex/ollie/apps/account/kitex_gen/account"
)

type UpdateAccountService struct {
	ctx context.Context
} // NewUpdateAccountService new UpdateAccountService
func NewUpdateAccountService(ctx context.Context) *UpdateAccountService {
	return &UpdateAccountService{ctx: ctx}
}

// Run create note info
func (s *UpdateAccountService) Run(req *account.UpdateAccountRequest) (resp *account.UpdateAccountResponse, err error) {
	// Finish your business logic.

	return
}
