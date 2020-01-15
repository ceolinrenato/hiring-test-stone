defmodule HiringTestStoneWeb.BankAccountController do
  use HiringTestStoneWeb, :controller

  alias HiringTestStone.BankAccount
  alias HiringTestStone.BankAccount.Account
  alias HiringTestStoneWeb.ErrorView

  def index(conn, _params) do
    render(conn, "index.json", bank_accounts: BankAccount.list_accounts)
  end

  def show(conn, %{"id" => account_number}) do
    case BankAccount.get_account_by_number(account_number) do
      %Account{} = account -> render(conn, "show.json", bank_account: account)
      {:error, :account_not_found} ->
        conn
        |> put_status(:not_found)
        |> put_view(ErrorView)
        |> render("404.json")
    end
  end
end
