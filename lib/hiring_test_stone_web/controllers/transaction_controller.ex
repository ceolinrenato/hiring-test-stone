defmodule HiringTestStoneWeb.TransactionController do
  use HiringTestStoneWeb, :controller

  alias HiringTestStone.Transaction
  alias HiringTestStoneWeb.ErrorView

  @transaction_withdraw "withdraw"

  def create(conn, %{"transaction_type" => @transaction_withdraw} = params) do
    case Transaction.withdraw_changeset(params) do
      %{valid?: false} = changeset ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("422.json", %{changeset: changeset})
      _ = changeset ->
        conn
        |> perform_withdraw(changeset)
    end
  end

  defp perform_withdraw(conn, %Ecto.Changeset{changes: %{source_account: source_account_number, amount: amount}}) do
    case Transaction.withdraw_money(source_account_number, amount) do
      {:ok, %{register_withdraw_transaction_step: transaction}} ->
        conn
        |> put_status(:created)
        |> render("create.json", transaction: transaction, type: @transaction_withdraw)
      {:error, transaction_step, error, _} ->
        conn
        |> put_status(:bad_request)
        |> render("400.json", %{error: %{transaction_step: transaction_step, error: error}})
    end
  end
end
