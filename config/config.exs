import Mix.Config

config :tesla, adapter: Tesla.Mock

config :logger, level: :error

config :bacen_sta,
  client: Bacen.STA.ClientMock,
  test: true,
  credentials: [
    username: "test",
    password: "foo"
  ]
