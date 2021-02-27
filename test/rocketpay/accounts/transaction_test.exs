defmodule Rocketpay.Accounts.TransactionTest do
  use Rocketpay.DataCase, async: true

  alias Rocketpay.{User, Account}
  alias Rocketpay.Accounts.Deposit
  alias Rocketpay.Accounts.Transaction
  alias Rocketpay.Accounts.Transactions.Response, as: TransactionResponse

  describe "call/1" do
    setup do
      from_user = %{
        name: "Cassio",
        password: "123456",
        nickname: "cassio",
        email: "cassio@yahoo.com",
        age: 24
      }

      to_user = %{
        name: "Nathalia",
        password: "123456",
        nickname: "nathalia",
        email: "nathalia@yahoo.com",
        age: 24
      }

      {:ok, %User{account: %Account{id: from_account}}} = Rocketpay.create_user(from_user)
      {:ok, %User{account: %Account{id: to_account}}} = Rocketpay.create_user(to_user)

      deposit = %{"id" => from_account, "value" => 50}
      Deposit.call(deposit)

      %{from_account: from_account, to_account: to_account}
    end

    test "when params are valid, transactions is sucessfully", %{
      from_account: from_account,
      to_account: to_account
    } do
      params = %{"from" => from_account, "to" => to_account, "value" => 30}

      expected_from_balance = Decimal.new("20.0")
      expected_to_balance = Decimal.new("30.0")

      assert {:ok,
              %TransactionResponse{
                from_account: %Account{
                  id: ^from_account,
                  balance: ^expected_from_balance
                },
                to_account: %Account{
                  id: ^to_account,
                  balance: ^expected_to_balance
                }
              }} = Transaction.call(params)
    end

    test "when value is invalid, returns an error", %{
      from_account: from_account,
      to_account: to_account
    } do
      params = %{"from" => from_account, "to" => to_account, "value" => ""}

      expected_result = {:error, "Invalid withdraw value"}

      assert expected_result == Transaction.call(params)
    end

    test "when from account not exists, returns an error", %{
      to_account: to_account
    } do
      params = %{
        "from" => "9ec7f655-4949-4101-ae53-c7adbb9ed7b9",
        "to" => to_account,
        "value" => "10.0"
      }

      expected_result = {:error, "Account not found"}

      assert expected_result == Transaction.call(params)
    end

    test "when to account not exists, returns an error", %{
      from_account: from_account
    } do
      params = %{
        "from" => from_account,
        "to" => "9ec7f655-4949-4101-ae53-c7adbb9ed7b9",
        "value" => "10.0"
      }

      expected_result = {:error, "Account not found"}

      assert expected_result == Transaction.call(params)
    end
  end
end
