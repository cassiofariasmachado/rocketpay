defmodule RocketpayWeb.AccountsControllerTest do
  use RocketpayWeb.ConnCase, async: true

  alias Rocketpay.{Account, User}

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

      conn = put_req_header(conn, "authorization", "Basic #{Base.encode64("banana:nanica123")}")

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
end
