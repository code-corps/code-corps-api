defmodule CodeCorpsWeb.PreviewController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Preview, User}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Preview{}, params),
         {:ok, %Preview{} = preview} <- %Preview{} |> Preview.create_changeset(params) |> Repo.insert do
      conn |> put_status(:created) |> render("show.json-api", data: preview)
    end
  end
end
