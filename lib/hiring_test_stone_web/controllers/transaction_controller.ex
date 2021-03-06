defmodule HiringTestStoneWeb.TransactionController do
  use HiringTestStoneWeb, :controller

  alias HiringTestStone.EmailDispatcher
  alias HiringTestStone.Transaction
  alias HiringTestStoneWeb.ErrorView

  @transaction_withdraw "withdraw"
  @transaction_transfer "transfer"

  def create(conn, %{"transaction_type" => @transaction_withdraw} = params) do
    withdraw_params =
      params |> Enum.into(%{"source_account" => conn.assigns[:authenticated_account].number})

    case Transaction.withdraw_changeset(withdraw_params) do
      %{valid?: false} = changeset ->
        conn
        |> render_unprocessable(changeset)

      _ = changeset ->
        conn
        |> perform_withdraw(changeset)
    end
  end

  def create(conn, %{"transaction_type" => @transaction_transfer} = params) do
    transfer_params =
      params |> Enum.into(%{"source_account" => conn.assigns[:authenticated_account].number})

    case Transaction.transfer_changeset(transfer_params) do
      %{valid?: false} = changeset ->
        conn
        |> render_unprocessable(changeset)

      _ = changeset ->
        conn
        |> perform_transfer(changeset)
    end
  end

  def create(conn, params) do
    conn
    |> render_unprocessable(Transaction.withdraw_changeset(params))
  end

  defp render_unprocessable(conn, changeset) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render("422.json", %{changeset: changeset})
  end

  defp perform_withdraw(conn, %Ecto.Changeset{
         changes: %{source_account: source_account_number, amount: amount}
       }) do
    case Transaction.withdraw_money(source_account_number, amount) do
      {:ok,
       %{
         register_withdraw_transaction_step: transaction,
         retrieve_source_account_step: source_account
       }} ->
        EmailDispatcher.send_withdraw_email(source_account, amount)

        conn
        |> put_status(:created)
        |> render("create.json", transaction: transaction, type: @transaction_withdraw)

      {:error, transaction_step, error, _} ->
        conn
        |> put_status(:bad_request)
        |> render("400.json", %{error: %{transaction_step: transaction_step, error: error}})
    end
  end

  defp perform_transfer(
         conn,
         %Ecto.Changeset{
           changes: %{
             source_account: source_account_number,
             destination_account: destination_account_number,
             amount: amount
           }
         }
       ) do
    case Transaction.transfer_money(source_account_number, destination_account_number, amount) do
      {:ok,
       %{
         register_transfer_transaction_step: transaction,
         retrieve_source_account_step: source_account,
         retrieve_destination_account_step: destination_account
       }} ->
        EmailDispatcher.send_transfer_emails(
          source_account,
          destination_account,
          transaction.amount
        )

        conn
        |> put_status(:created)
        |> render("create.json",
          transaction: transaction,
          type: @transaction_transfer
        )

      {:error, transaction_step, error, _} ->
        conn
        |> put_status(:bad_request)
        |> render("400.json", %{error: %{transaction_step: transaction_step, error: error}})
    end
  end
end
