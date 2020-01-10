defmodule HiringTestStone.BankAccount.User do
  alias HiringTestStone.BankAccount.Account
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    has_one :account, Account

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
