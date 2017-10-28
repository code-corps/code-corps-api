# Make sure all required plugins start before tests start running
# Needs to be called before ExUnit.start
{:ok, _} = Application.ensure_all_started(:ex_machina)
{:ok, _} = Application.ensure_all_started(:bypass)

ExUnit.configure exclude: [acceptance: true]
ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(CodeCorps.Repo, :manual)
