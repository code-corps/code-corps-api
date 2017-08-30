# Make sure all required plugins start before tests start running
# Needs to be called before ExUnit.start
{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start
Application.ensure_all_started(:bypass)

Ecto.Adapters.SQL.Sandbox.mode(CodeCorps.Repo, :manual)
