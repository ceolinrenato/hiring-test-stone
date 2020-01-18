defmodule HiringTestStone.BankAccount.Account do
  @moduledoc false
  alias HiringTestStone.BankAccount.User
  alias HiringTestStone.Transaction.Transfer
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  schema "accounts" do
    field :number, Ecto.UUID, autogenerate: true
    field :password_hash, :string
    field :balance, :float
    belongs_to :user, User
    has_many :received_transfers, Transfer, foreign_key: :destination_account_id
    has_many :performed_transfers, Transfer, foreign_key: :source_account_id

    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:password, :balance, :user_id])
    |> validate_required([:balance, :user_id])
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:number)
    |> put_pass_hash
  end

  def changeset_with_user(account, attrs) do
    account
    |> cast(attrs, [:password, :balance])
    |> cast_assoc(:user, with: &User.changeset/2)
    |> validate_required([:password, :balance, :user])
    |> validate_confirmation(:password)
    |> unique_constraint(:number)
    |> put_pass_hash
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    changeset
    |> change(Bcrypt.add_hash(password))
  end

  defp put_pass_hash(%Ecto.Changeset{} = changeset) do
    changeset
  end
end
