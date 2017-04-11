defmodule CodeCorps.AuthenticationHelpers do
  use Phoenix.Controller

  import Canary.Plugs, only: [load_resource: 2]
  import Canada.Can, only: [can?: 3]
  import Plug.Conn, only: [halt: 1, put_status: 2, assign: 3]

  alias CodeCorps.Web.{ErrorView, TokenView}
  alias JaSerializer.Params

  def handle_unauthorized(conn = %{assigns: %{authorized: true}}), do: conn
  def handle_unauthorized(conn = %{assigns: %{authorized: false}}) do
    conn
    |> put_status(403)
    |> render(TokenView, "403.json", message: "You are not authorized to perform this action.")
    |> halt
  end

  def handle_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> render(ErrorView, "404.json")
    |> halt
  end

  # Used to authorize a resource we provide on our own
  # We need this to authorize based on changeset, since on some
  # records, some types of changes are valid while others are not
  # This is partially adjusted code, taken from canary
  def load_and_authorize_changeset(conn, options) do
    action = conn.private.phoenix_action
    cond do
      action in options[:only] ->
        conn
        |> load_resource(options)
        |> do_init_and_authorize_changeset(options[:model], action)
      true ->
        conn
    end
  end

  defp do_init_and_authorize_changeset(conn, model, action) do
    changeset = init_changeset(conn, model, action)
    conn
    |> assign(:changeset, changeset)
    |> authorize(changeset, action)
  end

  defp init_changeset(conn, model, action) do
    params = Params.to_attributes(conn.params["data"])
    resource = get_resource(conn, model, action)
    changeset_method = get_changeset_method(action)

    do_init_changeset(model, changeset_method, [resource, params])
  end
  defp do_init_changeset(_model, _method, [nil, _]), do: nil
  defp do_init_changeset(model, method, params), do: apply(model, method, params)

  defp get_resource(conn, model, :update) do
    resource_name =
      model
      |> Module.split
      |> List.last
      |> Macro.underscore
      |> String.to_atom

    conn.assigns |> Map.get(resource_name)
  end
  defp get_resource(_conn, model, :create), do: model.__struct__

  defp get_changeset_method(action), do: "#{action}_changeset" |> String.to_atom

  defp authorize(conn, changeset, action) do
    current_user = conn.assigns |> Map.get(:current_user)
    conn
    |> assign(:authorized, can?(current_user, action, changeset))
    |> handle_unauthorized
  end
end
