defmodule HiringTestStone.BankAccount.Account do
  alias HiringTestStone.BankAccount.User
  alias HiringTestStone.Transaction.Transfer
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :number, Ecto.UUID
    field :password_hash, :string
    field :balance, :float
    belongs_to :user, User
    has_many :received_transfers, Transfer, foreign_key: :destination_account_id
    has_many :performed_transfers, Transfer, foreign_key: :source_account_id

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:number, :password_hash, :balance, :user_id])
    |> validate_required([:number, :password_hash, :balance, :user_id])
  end
end
