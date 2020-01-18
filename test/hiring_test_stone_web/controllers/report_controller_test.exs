defmodule HiringStoneWeb.ReportControllerTest do
  use HiringTestStoneWeb.ConnCase

  alias HiringTestStone.BankAccount
  alias HiringTestStone.Transaction

  @username Application.get_env(:basic_auth, :admin_auth)[:username]
  @password Application.get_env(:basic_auth, :admin_auth)[:password]

  @test_password "123456"

  defp using_basic_auth(conn, username, password) do
    header_content = "Basic " <> Base.encode64("#{username}:#{password}")
    conn |> put_req_header("authorization", header_content)
  end

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

  describe "show/2" do
    test "Responds with an error with not authorized", %{conn: conn} do
      conn
      |> get(
        Routes.report_path(
          conn,
          :show,
          2020,
          1,
          18
        )
      )
      |> response(401)
    end

    test "Responds with total transaction amount in period", %{conn: conn} do
      source_account = account_fixture()
      destination_account = account_fixture()
      Transaction.transfer_money(source_account.number, destination_account.number, 300)
      Transaction.withdraw_money(source_account.number, 500)
      {:ok, today} = DateTime.now("Etc/UTC")

      response =
        conn
        |> using_basic_auth(@username, @password)
        |> get(
          Routes.report_path(
            conn,
            :show,
            today.year,
            today.month,
            today.day
          )
        )
        |> json_response(200)

      expected = %{
        "data" => %{
          "withdrew" => 500,
          "transfered" => 300,
          "total" => 800
        }
      }

      assert response == expected
    end

    test "Responds with zero when there is no transactions in period", %{conn: conn} do
      source_account = account_fixture()
      destination_account = account_fixture()
      Transaction.transfer_money(source_account.number, destination_account.number, 300)
      Transaction.withdraw_money(source_account.number, 500)
      {:ok, today} = DateTime.now("Etc/UTC")
      a_month_ago = today |> Timex.shift(months: -1)

      response =
        conn
        |> using_basic_auth(@username, @password)
        |> get(
          Routes.report_path(
            conn,
            :show,
            a_month_ago.year,
            a_month_ago.month
          )
        )
        |> json_response(200)

      expected = %{
        "data" => %{
          "withdrew" => 0,
          "transfered" => 0,
          "total" => 0
        }
      }

      assert response == expected
    end

    test "Responds with an error when trying to get a report for an invalid date", %{conn: conn} do
      response =
        conn
        |> using_basic_auth(@username, @password)
        |> get(
          Routes.report_path(
            conn,
            :show,
            2020,
            14,
            1
          )
        )
        |> json_response(422)

      expected = %{
        "errors" => %{
          "report_date" => ["invalid_date"]
        }
      }

      assert expected == response
    end
  end
end
