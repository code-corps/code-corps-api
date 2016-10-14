defmodule CodeCorps.CategoryController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Category

  plug JaResource
  plug :verify_authorized, only: [:create, :update]

  def handle_create(conn, attributes) do
    %Category{}
    |> Category.create_changeset(attributes)
    |> authorize_new(conn, policy: Category.Policy)
  end

  def handle_update(conn, record, attributes) do
    record
    |> Category.changeset(attributes)
    |> authorize_existing(record, conn, policy: Category.Policy)
  end

  # This would go into a separate module
  # Delete would also be weird, not sure how it would work

  def authorize_new(changeset, %Plug.Conn{} = conn, opts) do
    conn
    |> authorize(changeset, opts)
    |> handle_result(changeset, conn)
  end

  def authorize_existing(changeset, resource, conn, opts) do
    conn
    |> authorize(resource, opts)
    |> handle_result(changeset, conn)
  end

  def handle_result({:ok, _conn}, term, _old_conn), do: term
  def handle_result({:error, :unauthorized}, _term, conn), do: conn |> CodeCorps.AuthenticationHelpers.handle_not_authorized
end
