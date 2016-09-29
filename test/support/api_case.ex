defmodule CodeCorps.ApiCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection, specificaly,
  those working with the API endpoints.

  It's basically a clone of CodeCorps.ConnCase, with some extras,
  mainly authentication and proper headers, added.
  """

  import CodeCorps.Factories
  use ExUnit.CaseTemplate
  use Phoenix.ConnTest

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias CodeCorps.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import CodeCorps.AuthenticationTestHelpers
      import CodeCorps.Router.Helpers
      import CodeCorps.Factories
      import CodeCorps.TestHelpers

      # The default endpoint for testing
      @endpoint CodeCorps.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CodeCorps.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(CodeCorps.Repo, {:shared, self()})
    end

    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {conn, current_user} = cond do
      tags[:authenticated] ->
        conn |> add_authentication_headers(tags[:authenticated])
      true ->
        {conn, nil}
      end

    {:ok, conn: conn, current_user: current_user}
  end

  defp add_authentication_headers(conn, true) do
    user = insert(:user)
    conn = conn |> CodeCorps.AuthenticationTestHelpers.authenticate(user)
    {conn, user}
  end

  defp add_authentication_headers(conn, :admin) do
    admin = insert(:user, admin: true)
    conn = conn |> CodeCorps.AuthenticationTestHelpers.authenticate(admin)
    {conn, admin}
  end

end
