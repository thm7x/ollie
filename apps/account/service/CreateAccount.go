package service

import (
	"context"
	account "code.pypygo.com/vertex/ollie/apps/account/kitex_gen/account"
)

type CreateAccountService struct {
	ctx context.Context
} // NewCreateAccountService new CreateAccountService
func NewCreateAccountService(ctx context.Context) *CreateAccountService {
	return &CreateAccountService{ctx: ctx}
}

// Run create note info
func (s *CreateAccountService) Run(req *account.CreateAccountRequest) (resp *account.CreateAccountResponse, err error) {
	// Finish your business logic.

	return
}
