defmodule HiringTestStoneWeb.Router do
  use HiringTestStoneWeb, :router

  alias HiringTestStone.BankAccount

  pipeline :protected_api do
    plug :accepts, ["json"]

    plug BasicAuth,
      callback: &BankAccount.find_account_by_number_and_password/3,
      realm: "Se fudeu"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin_api do
    plug :accepts, ["json"]

    plug BasicAuth,
      use_config: {:basic_auth, :admin_auth}
  end

  scope "/api", HiringTestStoneWeb do
    pipe_through :protected_api
    resources "/bank_accounts", BankAccountController, only: [:show]
    resources "/transactions", TransactionController, only: [:create]
  end

  scope "/api", HiringTestStoneWeb do
    pipe_through :api
    resources "/bank_accounts", BankAccountController, only: [:create]
  end

  scope "/api", HiringTestStoneWeb do
    pipe_through :admin_api
    resources "/bank_accounts", BankAccountController, only: [:index]
  end
end
