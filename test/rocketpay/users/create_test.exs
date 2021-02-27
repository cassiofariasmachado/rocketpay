defmodule Rocketpay.Users.CreateTest do
  use Rocketpay.DataCase, async: true

  alias Rocketpay.User
  alias Rocketpay.Users.Create

  describe "call/1" do
    test "when all params are valid, returs an user" do
      params =  %{
        name: "Cassio",
        password: "123456",
        nickname: "cassio",
        email: "cassio@yahoo.com",
        age: 24
      }

      {:ok, %User{id: user_id}} = Create.call(params)

      user = Repo.get(User, user_id)

      assert %User{
               id: ^user_id,
               name: "Cassio",
               nickname: "cassio",
               email: "cassio@yahoo.com",
               age: 24
             } = user
    end

    test "when some params are invalid, returs errors" do
      params = %{
        nickname: "cassio",
        email: "cassio@yahoo.com",
        age: 15
      }

      {:error, changeset} = Create.call(params)

      expected_errors = %{
        age: ["must be greater than or equal to 18"],
        password: ["can't be blank"],
        name: ["can't be blank"]
      }

      assert expected_errors == errors_on(changeset)
    end
  end
end
