defmodule HiringTestStone.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :number, :uuid
      add :password_hash, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:accounts, [:user_id])
  end
end
