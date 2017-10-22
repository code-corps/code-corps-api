defmodule CodeCorpsWeb.Plug.SetTimberUserContext do
  @moduledoc """
  Captures user context.
  """

  @behaviour Plug

  alias CodeCorps.User

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%{assigns: %{current_user: %User{} = user}} = conn, _), do: add_context(conn, user)
  def call(conn, _), do: conn

  @impl false
  def add_context(conn, user) do
    %Timber.Contexts.UserContext{id: user.id, email: user.email, name: full_name(user)}
    |> Timber.add_context()

    conn
  end

  defp full_name(%User{first_name: nil, last_name: nil}), do: ""
  defp full_name(%User{first_name: first_name, last_name: nil}), do: first_name
  defp full_name(%User{first_name: nil, last_name: last_name}), do: last_name
  defp full_name(%User{first_name: first_name, last_name: last_name}), do: first_name <> " " <> last_name
  defp full_name(_), do: ""
end
