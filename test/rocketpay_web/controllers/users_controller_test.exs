defmodule RocketpayWeb.UsersControllerTest do
  use RocketpayWeb.ConnCase, async: true

  alias Rocketpay.User

  describe "create/2" do
    setup %{conn: conn} do
      user = %{
        name: "Cassio",
        password: "123456",
        nickname: "cassio",
        email: "cassio@yahoo.com",
        age: 24
      }

      {:ok, %User{}} = Rocketpay.create_user(user)

      {:ok, conn: conn}
    end

    test "when all params are valid, create the user", %{conn: conn} do
      user = %{
        name: "Nathalia",
        password: "123456",
        nickname: "nathalia",
        email: "nathalia@yahoo.com",
        age: 20
      }

      response =
        conn
        |> post(Routes.users_path(conn, :create, user))
        |> json_response(:created)

      assert %{
               "message" => "User created",
               "user" => %{
                 "account" => %{
                   "balance" => "0.0"
                 },
                 "name" => "Nathalia",
                 "nickname" => "nathalia"
               }
             } = response
    end

    test "when params are invalid, returns an error", %{conn: conn} do
      response =
        conn
        |> post(Routes.users_path(conn, :create, %{}))
        |> json_response(:bad_request)

      expected_response = %{
        "message" => %{
          "age" => ["can't be blank"],
          "email" => ["can't be blank"],
          "name" => ["can't be blank"],
          "nickname" => ["can't be blank"],
          "password" => ["can't be blank"]
        }
      }

      assert expected_response == response
    end

    test "when email is already used, returns an error", %{conn: conn} do
      user = %{
        name: "Cassio",
        password: "123456",
        nickname: "cassio",
        email: "cassio@yahoo.com",
        age: 24
      }

      response =
        conn
        |> post(Routes.users_path(conn, :create, user))
        |> json_response(:bad_request)

      expected_response = %{
        "message" => %{
          "email" => ["has already been taken"]
        }
      }

      assert expected_response == response
    end
  end
end
