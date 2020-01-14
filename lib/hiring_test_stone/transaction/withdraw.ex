defmodule HiringTestStone.Transaction.Withdraw do
  use Ecto.Schema
  import Ecto.Changeset

  alias HiringTestStone.BankAccount.Account

  schema "withdraws" do
    field :amount, :float
    belongs_to :source_account, Account, foreign_key: :source_account_id

    timestamps()
  end

  @doc false
  def changeset(withdraw, attrs) do
    withdraw
    |> cast(attrs, [:amount, :source_account_id])
    |> validate_required([:amount])
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:source_account_id)
  end
end
