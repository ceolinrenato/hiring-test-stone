defmodule HiringTestStone.Repo.Migrations.CreateWithdraws do
  use Ecto.Migration

  def change do
    create table(:withdraws) do
      add :amount, :float
      add :source_account_id, references(:accounts, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:withdraws, [:source_account_id])
    create index(:withdraws, [:inserted_at])
  end
end
