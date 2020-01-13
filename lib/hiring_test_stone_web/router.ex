defmodule HiringTestStoneWeb.Router do
  use HiringTestStoneWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HiringTestStoneWeb do
    pipe_through :api
    resources "/bank_accounts", BankAccountController, only: [:index, :show]
  end
end
