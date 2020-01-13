defmodule HiringTestStoneWeb.BankAccountController do
  use HiringTestStoneWeb, :controller

  alias HiringTestStone.BankAccount
  alias HiringTestStone.BankAccount.Account
  alias HiringTestStoneWeb.ErrorView

  def index(conn, _params) do
    render(conn, "index.json", bank_accounts: BankAccount.list_accounts)
  end

  @spec show(Plug.Conn.t(), nil | keyword | map) :: Plug.Conn.t()
  def show(conn, params) do
    case BankAccount.get_account_by_number(params["id"]) do
      %Account{} = account -> render(conn, "show.json", bank_account: account)
      {:error, :account_not_found} ->
        conn
        |> put_status(:not_found)
        |> put_view(ErrorView)
        |> render("404.json")
    end
  end
end
