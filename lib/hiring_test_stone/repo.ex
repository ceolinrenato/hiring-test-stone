defmodule HiringTestStone.Repo do
  use Ecto.Repo,
    otp_app: :hiring_test_stone,
    adapter: Ecto.Adapters.Postgres
end
