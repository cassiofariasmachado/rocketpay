defmodule Rocketpay.Accounts.DepositTest do
  use Rocketpay.DataCase, async: true

  alias Rocketpay.{User, Account}
  alias Rocketpay.Accounts.Deposit

  describe "call/1" do
    setup do
      user = %{
        name: "Cassio",
        password: "123456",
        nickname: "cassio",
        email: "cassio@yahoo.com",
        age: 24
      }

      {:ok, %User{id: user_id, account: %Account{id: account_id}}} = Rocketpay.create_user(user)

      %{user_id: user_id, account_id: account_id}
    end

    test "when value and id is valid, make the deposit", %{
      user_id: user_id,
      account_id: account_id
    } do
      params = %{"id" => account_id, "value" => 50}

      expected_balance = Decimal.new("50.0")

      assert {:ok,
              %Account{
                balance: ^expected_balance,
                id: ^account_id,
                user_id: ^user_id
              }} = Deposit.call(params)
    end

    test "when value is invalid, returns an error", %{
      account_id: account_id
    } do
      params = %{"id" => account_id, "value" => ""}

      expected_result = {:error, "Invalid deposit value"}

      assert expected_result == Deposit.call(params)
    end

    test "when account not exists, returns an error", %{} do
      params = %{"id" => "9ec7f655-4949-4101-ae53-c7adbb9ed7b9", "value" => "100"}

      expected_result = {:error, "Account not found"}

      assert expected_result == Deposit.call(params)
    end
  end
end
