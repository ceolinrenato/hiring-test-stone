defmodule HiringTestStone.Repo.Migrations.CreateTransfer do
  use Ecto.Migration

  def change do
    create table(:transfers) do
      add :amount, :float
      add :source_account_id, references(:accounts, on_delete: :nothing), null: false
      add :destination_account_id, references(:accounts, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:transfers, [:source_account_id])
    create index(:transfers, [:destination_account_id])
    create index(:transfers, [:inserted_at])
  end
end
