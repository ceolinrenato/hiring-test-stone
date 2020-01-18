defmodule HiringTestStoneWeb.BankAccountView do
  use HiringTestStoneWeb, :view

  def render("index.json", %{bank_accounts: accounts}) do
    %{data: render_many(accounts, HiringTestStoneWeb.BankAccountView, "account.json")}
  end

  def render("show.json", %{bank_account: account, with_balance: true}) do
    %{data: render_one(account, HiringTestStoneWeb.BankAccountView, "account_with_balance.json")}
  end

  def render("show.json", %{bank_account: account}) do
    %{data: render_one(account, HiringTestStoneWeb.BankAccountView, "account.json")}
  end

  def render("create.json", %{bank_account: account}) do
    %{data: render_one(account, HiringTestStoneWeb.BankAccountView, "account.json")}
  end

  def render("account.json", %{bank_account: account}) do
    %{
      number: account.number,
      user: %{
        name: account.user.name,
        email: account.user.email
      }
    }
  end

  def render("account_with_balance.json", %{bank_account: account}) do
    %{
      number: account.number,
      balance: account.balance,
      user: %{
        name: account.user.name,
        email: account.user.email
      }
    }
  end
end
