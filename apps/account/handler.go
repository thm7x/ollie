package main

import (
	account "code.pypygo.com/vertex/ollie/apps/account/kitex_gen/account"
	"context"
	"code.pypygo.com/vertex/ollie/apps/account/service"
)

// AccountServiceImpl implements the last service interface defined in the IDL.
type AccountServiceImpl struct{}

// Login implements the AccountServiceImpl interface.
func (s *AccountServiceImpl) Login(ctx context.Context, req *account.LoginRequest) (resp *account.LoginResponse, err error) {
	resp, err = service.NewLoginService(ctx).Run(req)

	return resp, err
}

// RefreshToken implements the AccountServiceImpl interface.
func (s *AccountServiceImpl) RefreshToken(ctx context.Context, req *account.RefreshTokenRequest) (resp *account.RefreshTokenResponse, err error) {
	resp, err = service.NewRefreshTokenService(ctx).Run(req)

	return resp, err
}

// QueryAccounts implements the AccountServiceImpl interface.
func (s *AccountServiceImpl) QueryAccounts(ctx context.Context, req *account.QueryAccountRequest) (resp *account.QueryAccountResponse, err error) {
	resp, err = service.NewQueryAccountsService(ctx).Run(req)

	return resp, err
}

// CreateAccount implements the AccountServiceImpl interface.
func (s *AccountServiceImpl) CreateAccount(ctx context.Context, req *account.CreateAccountRequest) (resp *account.CreateAccountResponse, err error) {
	resp, err = service.NewCreateAccountService(ctx).Run(req)

	return resp, err
}

// UpdateAccount implements the AccountServiceImpl interface.
func (s *AccountServiceImpl) UpdateAccount(ctx context.Context, req *account.UpdateAccountRequest) (resp *account.UpdateAccountResponse, err error) {
	resp, err = service.NewUpdateAccountService(ctx).Run(req)

	return resp, err
}

// BatchUpdateAccount implements the AccountServiceImpl interface.
func (s *AccountServiceImpl) BatchUpdateAccount(ctx context.Context, req *account.BatchUpdateAccountRequest) (resp *account.BatchUpdateAccountResponse, err error) {
	resp, err = service.NewBatchUpdateAccountService(ctx).Run(req)

	return resp, err
}

// AllUpdateAccount implements the AccountServiceImpl interface.
func (s *AccountServiceImpl) AllUpdateAccount(ctx context.Context, req *account.AllUpdateAccountRequest) (resp *account.AllUpdateAccountResponse, err error) {
	resp, err = service.NewAllUpdateAccountService(ctx).Run(req)

	return resp, err
}
