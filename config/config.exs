use Mix.Config

config :ex_statsd,
  namespace: "event_storage_ex"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
