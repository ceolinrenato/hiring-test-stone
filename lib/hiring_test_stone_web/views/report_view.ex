defmodule HiringTestStoneWeb.ReportView do
  use HiringTestStoneWeb, :view

  def render("show.json", %{withdrew: amount_withdrew, transfered: amount_transfered}) do
    %{
      data: %{
        withdrew: amount_withdrew || 0,
        transfered: amount_transfered || 0,
        total: (amount_transfered || 0) + (amount_withdrew || 0)
      }
    }
  end
end
