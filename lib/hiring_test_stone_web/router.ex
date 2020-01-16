defmodule HiringTestStoneWeb.Router do
  use HiringTestStoneWeb, :router

  alias HiringTestStone.BankAccount

  pipeline :api do
    plug :accepts, ["json"]

    plug BasicAuth,
      callback: &BankAccount.find_account_by_number_and_password/3,
      realm: "Se fudeu"
  end

  scope "/api", HiringTestStoneWeb do
    pipe_through :api
    resources "/bank_accounts", BankAccountController, only: [:index, :show]
    post "/transactions", TransactionController, :create
  end
end
