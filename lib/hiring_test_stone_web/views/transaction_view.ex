defmodule HiringTestStoneWeb.TransactionView do
  use HiringTestStoneWeb, :view

  alias HiringTestStone.BankAccount

  def render("create.json", %{transaction: %{amount: amount, source_account_id: source_account_id}, type: "withdraw"}) do
    %{balance: balance, number: source_account_number} = BankAccount.get_account!(source_account_id)
    %{
      transaction_type: "withdraw",
      amount: amount,
      source_account: source_account_number,
      remaining_balance: balance
    }
  end

  def render("400.json", %{error: %{transaction_step: transaction_step, error: error}}) do
    %{
      error: %{
        transaction_step: transaction_step,
        detail: error
      }
    }
  end
end
