defmodule HiringTestStone.BankAccount.Account do
  alias HiringTestStone.BankAccount.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :number, Ecto.UUID
    field :password_hash, :string
    field :balance, :float
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:number, :password_hash, :balance, :user_id])
    |> validate_required([:number, :password_hash, :balance])
  end
end
