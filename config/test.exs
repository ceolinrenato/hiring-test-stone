use Mix.Config

# Configure your database
config :hiring_test_stone, HiringTestStone.Repo,
  username: "postgres",
  password: "postgres",
  database: "hiring_test_stone_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hiring_test_stone, HiringTestStoneWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :argon2_elixir,
  t_cost: 1,
  m_cost: 8

# Admin Area config
config :basic_auth,
  admin_auth: [
    username: "admin",
    password: "admin",
    realm: "Admin Area"
  ]
