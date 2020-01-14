defmodule HiringTestStone.Transaction.Transfer do
  alias HiringTestStone.BankAccount.Account
  use Ecto.Schema
  import Ecto.Changeset

  schema "transfers" do
    field :amount, :float
    belongs_to :source_account, Account, foreign_key: :source_account_id
    belongs_to :destination_account, Account, foreign_key: :destination_account_id

    timestamps()
  end

  @doc false
  def changeset(transfer, attrs) do
    transfer
    |> cast(attrs, [:amount, :source_account_id, :destination_account_id])
    |> validate_required([:amount])
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:source_account_id)
    |> foreign_key_constraint(:destination_account_id)
  end
end
