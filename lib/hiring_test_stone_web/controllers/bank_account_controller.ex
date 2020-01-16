defmodule HiringTestStoneWeb.BankAccountController do
  use HiringTestStoneWeb, :controller

  alias HiringTestStone.BankAccount
  alias HiringTestStone.BankAccount.Account
  alias HiringTestStoneWeb.ErrorView

  @initial_balance 1_000

  def index(conn, _params) do
    render(conn, "index.json", bank_accounts: BankAccount.list_accounts())
  end

  def show(conn, %{"id" => account_number}) do
    case BankAccount.get_account_by_number(account_number) do
      %Account{} = account ->
        render(conn, "show.json", bank_account: account)

      {:error, :account_not_found} ->
        conn
        |> put_status(:not_found)
        |> put_view(ErrorView)
        |> render("404.json")
    end
  end

  def create(conn, params) do
    case BankAccount.register_bank_account(params |> Enum.into(%{"balance" => @initial_balance})) do
      {:ok, account} ->
        conn
        |> put_status(:created)
        |> render("create.json", bank_account: account)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("422.json", changeset: changeset)
    end
  end
end
