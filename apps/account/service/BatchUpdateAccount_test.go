package service

import (
	"context"
	"testing"
	account "code.pypygo.com/vertex/ollie/apps/account/kitex_gen/account"
)

func TestBatchUpdateAccount_Run(t *testing.T) {
	ctx := context.Background()
	s := NewBatchUpdateAccountService(ctx)
	// init req and assert value

	req := &account.BatchUpdateAccountRequest{}
	resp, err := s.Run(req)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}
	if resp == nil {
		t.Errorf("unexpected nil response")
	}
	// todo: edit your unit test

}
