defmodule HiringTestStoneWeb.BankAccountControllerTest do
  use HiringTestStoneWeb.ConnCase

  alias HiringTestStone.BankAccount

  @username Application.get_env(:basic_auth, :admin_auth)[:username]
  @password Application.get_env(:basic_auth, :admin_auth)[:password]

  @fixture_account_password "123456"

  defp using_basic_auth(conn, username, password) do
    header_content = "Basic " <> Base.encode64("#{username}:#{password}")
    conn |> put_req_header("authorization", header_content)
  end

  defp account_fixture(attrs \\ %{}) do
    valid_attributes = %{
      balance: 1_000,
      password: @fixture_account_password,
      password_confirmation: @fixture_account_password,
      user: %{
        name: "John Doe",
        email: "johndoe@example.com"
      }
    }

    {:ok, account} = BankAccount.register_bank_account(valid_attributes |> Enum.into(attrs))

    account
  end

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

  describe "index/1" do
    test "Responds with all accounts if authenticated as admin", %{conn: conn} do
      account = account_fixture()

      response =
        conn
        |> using_basic_auth(@username, @password)
        |> get(
          Routes.bank_account_path(
            conn,
            :index
          )
        )
        |> json_response(200)

      expected = %{
        "data" => [
          %{
            "number" => account.number,
            "user" => %{
              "name" => account.user.name,
              "email" => account.user.email
            }
          }
        ]
      }

      assert response == expected
    end

    test "Responds with an error if not autheticated as admin", %{conn: conn} do
      conn
      |> get(
        Routes.bank_account_path(
          conn,
          :index
        )
      )
      |> response(401)
    end
  end

  describe "show/2" do
    test "Responds with account if account is exits", %{conn: conn} do
      account = account_fixture()

      response =
        conn
        |> using_basic_auth(account.number, @fixture_account_password)
        |> get(
          Routes.bank_account_path(
            conn,
            :show,
            account.number
          )
        )
        |> json_response(200)

      expected = %{
        "data" => %{
          "number" => account.number,
          "user" => %{
            "name" => account.user.name,
            "email" => account.user.email
          }
        }
      }

      assert response == expected
    end

    test "Responds with not found error if account does not exist", %{conn: conn} do
      account = account_fixture()

      conn
      |> using_basic_auth(account.number, @fixture_account_password)
      |> get(
        Routes.bank_account_path(
          conn,
          :show,
          "not_an_account_number"
        )
      )
      |> json_response(404)
    end

    test "Responds with unathorized if not authenticated as an user account", %{conn: conn} do
      conn
      |> get(
        Routes.bank_account_path(
          conn,
          :show,
          "not_an_account_number"
        )
      )
      |> response(401)
    end
  end
end
