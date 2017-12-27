defmodule CodeCorpsWeb.CommentController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Comment, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with comments <- Comment |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: comments)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %Comment{} = comment <- Comment |> Repo.get(id) do
      conn |> render("show.json-api", data: comment)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Comment{}, params),
         {:ok, %Comment{} = comment} <- Comment.Service.create(params) do
      conn |> put_status(:created) |> render("show.json-api", data: comment)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %Comment{} = comment <- Comment |> Repo.get(id),
         %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:update, comment),
         {:ok, %Comment{} = comment} <- comment |> Comment.Service.update(params) do
      conn |> render("show.json-api", data: comment)
    end
  end
end
