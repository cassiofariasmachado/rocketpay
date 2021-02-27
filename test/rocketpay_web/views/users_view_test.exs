defmodule RocketpayWeb.UsersViewTest do
  use RocketpayWeb.ConnCase, async: true

  import Phoenix.View

  alias Rocketpay.{User, Account}
  alias RocketpayWeb.UsersView

  test "renders create.json" do
    user_params = %{
      name: "Cassio",
      password: "123456",
      nickname: "cassio",
      email: "cassio@yahoo.com",
      age: 24
    }

    {:ok,
     %User{
       id: user_id,
       account: %Account{id: account_id}
     } = user} = Rocketpay.create_user(user_params)

    response = render(UsersView, "create.json", user: user)

    expected_response = %{
      message: "User created",
      user: %{
        account: %{
          balance: Decimal.new("0.0"),
          id: account_id
        },
        id: user_id,
        name: "Cassio",
        nickname: "cassio"
      }
    }

    assert expected_response == response
  end
end
