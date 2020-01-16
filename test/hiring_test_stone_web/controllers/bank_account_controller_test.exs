defmodule HiringTestStoneWeb.BankAccountControllerTest do
  use HiringTestStoneWeb.ConnCase

  alias HiringTestStone.BankAccount

  describe "create/2" do
    test "Responds with created and account data when valid input", %{conn: conn} do
      attrs = %{
        password: "123456",
        user: %{
          name: "John Doe",
          email: "johndoe@example.com"
        }
      }

      response =
        conn
        |> post(
          Routes.bank_account_path(
            conn,
            :create,
            attrs
          )
        )
        |> json_response(201)

      assert %{"data" => _} = response
    end

    test "Responds with an error when invalid input", %{conn: conn} do
      attrs = %{
        user: %{
          name: "John Doe",
          email: "johndoe@example.com"
        }
      }

      response =
        conn
        |> post(
          Routes.bank_account_path(
            conn,
            :create,
            attrs
          )
        )
        |> json_response(422)

      assert %{"errors" => %{"password" => _}} = response
    end

    test "Accounts get created with 1k initial balance", %{conn: conn} do
      attrs = %{
        password: "123456",
        user: %{
          name: "John Doe",
          email: "johndoe@example.com"
        }
      }

      response =
        conn
        |> post(
          Routes.bank_account_path(
            conn,
            :create,
            attrs
          )
        )
        |> json_response(201)

      assert BankAccount.get_account_by_number(response["data"]["number"]).balance == 1_000
    end
  end
end
