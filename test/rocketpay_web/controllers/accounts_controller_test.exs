defmodule RocketpayWeb.AccountsControllerTest do
  use RocketpayWeb.ConnCase, async: true

  alias Rocketpay.{Account, User}
  alias Rocketpay.Accounts.Deposit

  def get_basic_auth() do
    basic_auth = Application.get_env(:rocketpay, :basic_auth)

    username = Keyword.get(basic_auth, :username)
    password = Keyword.get(basic_auth, :password)

    Base.encode64("#{username}:#{password}")
  end

  describe "deposit/2" do
    setup %{conn: conn} do
      user = %{
        name: "Cassio",
        password: "123456",
        nickname: "cassio",
        email: "cassio@yahoo.com",
        age: 24
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(user)

      conn = put_req_header(conn, "authorization", "Basic #{get_basic_auth()}")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, make the deposit", %{conn: conn, account_id: account_id} do
      params = %{"value" => "50"}

      response =
        conn
        |> post(Routes.accounts_path(conn, :deposit, account_id, params))
        |> json_response(:ok)

      expected_response = %{
        "account" => %{
          "balance" => "50.0",
          "id" => account_id
        },
        "message" => "Balance changed sucessfully"
      }

      assert expected_response == response
    end

    test "when there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => ""}

      response =
        conn
        |> post(Routes.accounts_path(conn, :deposit, account_id, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid deposit value"}

      assert expected_response == response
    end
  end

  describe "withdraw/2" do
    setup %{conn: conn} do
      user = %{
        name: "Cassio",
        password: "123456",
        nickname: "cassio",
        email: "cassio@yahoo.com",
        age: 24
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(user)

      deposit = %{"id" => account_id, "value" => 50}
      Deposit.call(deposit)

      conn = put_req_header(conn, "authorization", "Basic #{get_basic_auth()}")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, make the withdraw", %{conn: conn, account_id: account_id} do
      params = %{"value" => "20"}

      response =
        conn
        |> post(Routes.accounts_path(conn, :withdraw, account_id, params))
        |> json_response(:ok)

      expected_response = %{
        "account" => %{
          "balance" => "30.0",
          "id" => account_id
        },
        "message" => "Balance changed sucessfully"
      }

      assert expected_response == response
    end

    test "when there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => ""}

      response =
        conn
        |> post(Routes.accounts_path(conn, :withdraw, account_id, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid withdraw value"}

      assert expected_response == response
    end
  end

  describe "transaction/2" do
    setup %{conn: conn} do
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

      conn = put_req_header(conn, "authorization", "Basic #{get_basic_auth()}")

      {:ok, conn: conn, from_account: from_account, to_account: to_account}
    end

    test "when params are valid, transactions is sucessfully", %{
      conn: conn,
      from_account: from_account,
      to_account: to_account
    } do
      params = %{"from" => from_account, "to" => to_account, "value" => 30}

      response =
        conn
        |> post(Routes.accounts_path(conn, :transaction, params))
        |> json_response(:ok)

      expected_response = %{
        "message" => "Transaction done sucessfully",
        "transaction" => %{
          "from_account" => %{"balance" => "20.0", "id" => from_account},
          "to_account" => %{"balance" => "30.0", "id" => to_account}
        }
      }

      assert expected_response == response
    end

    test "when value is invalid, returns an error", %{
      conn: conn,
      from_account: from_account,
      to_account: to_account
    } do
      params = %{"from" => from_account, "to" => to_account, "value" => ""}

      response =
        conn
        |> post(Routes.accounts_path(conn, :transaction, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid withdraw value"}

      assert expected_response == response
    end

    test "when from account not exists, returns an error", %{
      conn: conn,
      from_account: from_account
    } do
      params = %{
        "from" => from_account,
        "to" => "9ec7f655-4949-4101-ae53-c7adbb9ed7b9",
        "value" => "10.0"
      }

      response =
        conn
        |> post(Routes.accounts_path(conn, :transaction, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Account not found"}

      assert expected_response == response
    end

    test "when to account not exists, returns an error", %{
      conn: conn,
      to_account: to_account
    } do
      params = %{
        "from" => "9ec7f655-4949-4101-ae53-c7adbb9ed7b9",
        "to" => to_account,
        "value" => "10.0"
      }

      response =
        conn
        |> post(Routes.accounts_path(conn, :transaction, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Account not found"}

      assert expected_response == response
    end
  end
end
