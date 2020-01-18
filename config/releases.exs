import Config

if System.get_env("APP_NAME") do
  config :hiring_test_stone, HiringTestStoneWeb.Endpoint,
    server: true,
    http: [port: {:system, "PORT"}], # Needed for Phoenix 1.2 and 1.4. Doesn't hurt for 1.3.
    url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443]
end
