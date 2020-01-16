defmodule HiringTestStoneWeb.TransactionControllerTest do
  use HiringTestStoneWeb.ConnCase

  alias HiringTestStone.BankAccount

  @test_password "123456"

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{name: "some name", email: Faker.Internet.email()})
      |> BankAccount.create_user()

    user
  end

  def account_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, account} =
      attrs
      |> Enum.into(%{password: @test_password, balance: 1_000})
      |> Enum.into(%{user_id: user.id})
      |> BankAccount.create_account()

    account
  end

  describe "create/2 -> transfer" do
    test "Responds with created and performed transfer when data is valid", %{conn: conn} do
      source_account = account_fixture()
      destination_account = account_fixture()

      response =
        conn
        |> put_req_header(
          "authorization",
          "Basic " <> Base.url_encode64("#{source_account.number}:#{@test_password}")
        )
        |> post(
          Routes.transaction_path(
            conn,
            :create,
            %{
              transaction_type: "transfer",
              destination_account: destination_account.number,
              amount: 1_000
            }
          )
        )
        |> json_response(201)

      expected = %{
        "data" => %{
          "transaction_type" => "transfer",
          "amount" => 1_000.0,
          "source_account" => source_account.number,
          "destination_account" => destination_account.number,
          "remaining_balance" => 0.0
        }
      }

      assert response == expected
    end

    test "Responds with an error when source account balance is unsufficient", %{conn: conn} do
      source_account = account_fixture(%{balance: 500})
      destination_account = account_fixture()

      response =
        conn
        |> put_req_header(
          "authorization",
          "Basic " <> Base.url_encode64("#{source_account.number}:#{@test_password}")
        )
        |> post(
          Routes.transaction_path(
            conn,
            :create,
            %{
              transaction_type: "transfer",
              destination_account: destination_account.number,
              amount: 1_000
            }
          )
        )
        |> json_response(400)

      expected = %{
        "error" => %{
          "transaction_step" => "verify_balance_step",
          "detail" => "balance_too_low"
        }
      }

      assert response == expected
    end

    test "Responds with an error when destination account is not found", %{conn: conn} do
      source_account = account_fixture()

      response =
        conn
        |> put_req_header(
          "authorization",
          "Basic " <> Base.url_encode64("#{source_account.number}:#{@test_password}")
        )
        |> post(
          Routes.transaction_path(
            conn,
            :create,
            %{
              transaction_type: "transfer",
              destination_account: Ecto.UUID.generate(),
              amount: 1_000
            }
          )
        )
        |> json_response(400)

      expected = %{
        "error" => %{
          "transaction_step" => "retrieve_destination_account_step",
          "detail" => "account_not_found"
        }
      }

      assert response == expected
    end

    test "Responds with an error when trying to transfer to the same account", %{conn: conn} do
      source_account = account_fixture()

      response =
        conn
        |> put_req_header(
          "authorization",
          "Basic " <> Base.url_encode64("#{source_account.number}:#{@test_password}")
        )
        |> post(
          Routes.transaction_path(
            conn,
            :create,
            %{
              transaction_type: "transfer",
              destination_account: source_account.number,
              amount: 1_000
            }
          )
        )
        |> json_response(400)

      expected = %{
        "error" => %{
          "transaction_step" => "verify_accounts_step",
          "detail" => "source_equal_to_destination"
        }
      }

      assert response == expected
    end

    test "Responds with an error if any attribute is invalid", %{conn: conn} do
      source_account = account_fixture()

      response =
        conn
        |> put_req_header(
          "authorization",
          "Basic " <> Base.url_encode64("#{source_account.number}:#{@test_password}")
        )
        |> post(
          Routes.transaction_path(
            conn,
            :create,
            %{
              transaction_type: "transfer",
              destination_account: source_account.number,
              amount: -200
            }
          )
        )
        |> json_response(422)

      expected = %{
        "errors" => %{
          "amount" => ["must be greater than 0"]
        }
      }

      assert response == expected
    end
  end

  describe "create/2 -> withdraw" do
    test "Responds with created and performed withdraw when data is valid", %{conn: conn} do
      source_account = account_fixture()

      response =
        conn
        |> put_req_header(
          "authorization",
          "Basic " <> Base.url_encode64("#{source_account.number}:#{@test_password}")
        )
        |> post(
          Routes.transaction_path(
            conn,
            :create,
            %{
              transaction_type: "withdraw",
              amount: 1_000
            }
          )
        )
        |> json_response(201)

      expected = %{
        "data" => %{
          "amount" => 1_000.0,
          "remaining_balance" => 0.0,
          "source_account" => source_account.number,
          "transaction_type" => "withdraw"
        }
      }

      assert response == expected
    end

    test "Responds with an error when source account balance is unsufficient", %{conn: conn} do
      source_account = account_fixture(%{balance: 500})

      response =
        conn
        |> put_req_header(
          "authorization",
          "Basic " <> Base.url_encode64("#{source_account.number}:#{@test_password}")
        )
        |> post(
          Routes.transaction_path(
            conn,
            :create,
            %{
              transaction_type: "withdraw",
              amount: 1_000
            }
          )
        )
        |> json_response(400)

      expected = %{
        "error" => %{
          "transaction_step" => "verify_balance_step",
          "detail" => "balance_too_low"
        }
      }

      assert response == expected
    end

    test "Responds with an error if any attribute is invalid", %{conn: conn} do
      source_account = account_fixture()

      response =
        conn
        |> put_req_header(
          "authorization",
          "Basic " <> Base.url_encode64("#{source_account.number}:#{@test_password}")
        )
        |> post(
          Routes.transaction_path(
            conn,
            :create,
            %{
              transaction_type: "withdraw",
              amount: -200
            }
          )
        )
        |> json_response(422)

      expected = %{
        "errors" => %{
          "amount" => ["must be greater than 0"]
        }
      }

      assert response == expected
    end
  end

  test "create/2 responds with an error when invalid transaction type", %{conn: conn} do
    source_account = account_fixture()

    response =
      conn
      |> put_req_header(
        "authorization",
        "Basic " <> Base.url_encode64("#{source_account.number}:#{@test_password}")
      )
      |> post(
        Routes.transaction_path(
          conn,
          :create,
          %{
            transaction_type: "not_implemented"
          }
        )
      )
      |> json_response(422)

    assert %{"errors" => %{"transaction_type" => ["is invalid"]}} = response
  end

  test "create/2 responds with unauthorized error if failed to provide auth header", %{conn: conn} do
    response =
      conn
      |> post(
        Routes.transaction_path(
          conn,
          :create,
          %{
            transaction_type: "not_implemented"
          }
        )
      )
      |> response(401)

    assert response == "401 Unauthorized"
  end
end
