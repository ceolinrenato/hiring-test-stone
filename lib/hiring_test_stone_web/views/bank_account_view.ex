defmodule HiringTestStoneWeb.BankAccountView do
  use HiringTestStoneWeb, :view

  def render("index.json", %{bank_accounts: accounts}) do
    %{data: render_many(accounts, HiringTestStoneWeb.BankAccountView, "account.json")}
  end

  def render("show.json", %{bank_account: account}) do
    %{data: render_one(account, HiringTestStoneWeb.BankAccountView, "account.json")}
  end

  def render("account.json", %{bank_account: account}) do
    %{
      number: account.number,
      user: %{
        name: account.user.name
      }
    }
  end
end
