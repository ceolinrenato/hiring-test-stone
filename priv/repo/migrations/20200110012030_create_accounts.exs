defmodule HiringTestStone.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS pgcrypto")
    create table(:accounts) do
      add :number, :uuid, default: fragment("gen_random_uuid()")
      add :password_hash, :string
      add :balance, :float
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:accounts, [:user_id])
  end
end
