defmodule HiringTestStoneWeb.TransactionView do
  use HiringTestStoneWeb, :view

  alias HiringTestStone.BankAccount

  @transaction_withdraw "withdraw"
  @transaction_transfer "transfer"

  def render("create.json", %{
        transaction: %{amount: amount, source_account_id: source_account_id},
        type: @transaction_withdraw
      }) do
    %{balance: balance, number: source_account_number} =
      BankAccount.get_account!(source_account_id)

    %{
      transaction_type: @transaction_withdraw,
      amount: amount,
      source_account: source_account_number,
      remaining_balance: balance
    }
  end

  def render(
        "create.json",
        %{
          transaction: %{
            amount: amount,
            source_account_id: source_account_id,
            destination_account_id: destination_account_id
          },
          type: @transaction_transfer
        }
      ) do
    %{balance: balance, number: source_account_number} =
      BankAccount.get_account!(source_account_id)

    %{number: destination_account_number} = BankAccount.get_account!(destination_account_id)

    %{
      transaction_type: @transaction_transfer,
      amount: amount,
      source_account: source_account_number,
      destination_account: destination_account_number,
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
