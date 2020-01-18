defmodule HiringTestStone.EmailDispatcher do
  @moduledoc """
    Module to hold functionality to send emails to our clients in the future
    Probaly will use Bamboo library
  """
  require Logger
  alias HiringTestStone.BankAccount.Account

  def send_transfer_emails(%Account{} = source_account, %Account{} = destination_account, amount) do
    send_email(
      destination_account.user.email,
      "You received a transfer of $#{amount} from #{source_account.user.name}"
    )

    send_email(
      source_account.user.email,
      "You've transfered $#{amount} to #{destination_account.user.name}"
    )
  end

  def send_withdraw_email(%Account{} = source_account, amount) do
    send_email(
      source_account.user.email,
      "You've withdrawn $#{amount} of your account"
    )
  end

  def send_email(address, text) do
    Logger.info("[EMAIL SENT] TO: #{address} TEXT: #{text}")
  end
end
