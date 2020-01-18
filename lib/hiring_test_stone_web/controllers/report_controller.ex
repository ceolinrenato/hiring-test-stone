defmodule HiringTestStoneWeb.ReportController do
  use HiringTestStoneWeb, :controller

  alias HiringTestStone.Transaction
  alias HiringTestStoneWeb.ErrorView

  def show(conn, params) do
    case Transaction.report_changeset(params) do
      %{valid?: false} = changeset ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("422.json", %{changeset: changeset})

      _ = changeset ->
        conn
        |> render_report(changeset)
    end
  end

  defp render_report(conn, %Ecto.Changeset{
         changes: report_dt
       }) do
    amount_withdrew = Transaction.get_total_withdrew_amount(report_dt)
    amount_transfered = Transaction.get_total_transfered_amount(report_dt)

    conn
    |> render("show.json", withdrew: amount_withdrew, transfered: amount_transfered)
  end
end
