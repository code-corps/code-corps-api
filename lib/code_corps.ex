defmodule CodeCorps do
  @moduledoc false

  use Application

  alias CodeCorps.Web.Endpoint

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(CodeCorps.Repo, []),
      # Start the endpoint when the application starts
      supervisor(CodeCorps.Web.Endpoint, []),
      # Start your own worker by calling: CodeCorps.Worker.start_link(arg1, arg2, arg3)
      # worker(CodeCorps.Worker, [arg1, arg2, arg3]),
      supervisor(Task.Supervisor, [[name: :webhook_processor, restart: :transient]]),
      worker(Segment, [Application.get_env(:segment, :write_key)])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CodeCorps.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
