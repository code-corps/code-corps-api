defmodule CodeCorpsWeb.Plug.SetTimberUserContext do
  @moduledoc """
  Captures user context.
  """

  @behaviour Plug

  alias CodeCorps.User

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%{assigns: %{current_user: user}} = conn, _), do: add_context(conn, user)
  def call(conn, _), do: conn

  @impl false
  def add_context(conn, %User{} = user) do
    %Timber.Contexts.UserContext{id: user.id, email: user.email, name: User.full_name(user)}
    |> Timber.add_context()

    conn
  end
  def add_context(conn, _), do: conn
end
