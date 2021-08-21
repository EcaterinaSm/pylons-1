package keeper_test

import (
	"github.com/Pylons-tech/pylons/x/pylons/keeper"

	"github.com/Pylons-tech/pylons/x/pylons/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
)

func (suite *IntegrationTestSuite) TestCreateAccount() {
	k := suite.k
	ctx := suite.ctx
	require := suite.Require()

	srv := keeper.NewMsgServerImpl(k)
	wctx := sdk.WrapSDKContext(ctx)

	addr := validBech32AccAddr

	for _, tc := range []struct {
		desc    string
		request *types.MsgCreateAccount
		err     error
	}{
		{
			desc:    "Valid",
			request: &types.MsgCreateAccount{Creator: addr},
		},
		{
			desc:    "Invalid",
			request: &types.MsgCreateAccount{Creator: "invalid"},
			err:     sdkerrors.ErrInvalidRequest,
		},
	} {
		tc := tc
		suite.Run(tc.desc, func() {


			_, err := srv.CreateAccount(wctx, tc.request)
			if tc.err != nil {
				require.ErrorIs(err, tc.err)
			} else {
				require.NoError(err)
			}
		})
	}
}