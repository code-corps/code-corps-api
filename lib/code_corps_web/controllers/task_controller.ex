defmodule CodeCorpsWeb.TaskController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Task, Policy, User}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with tasks <- Task.Query.list(params) do
      conn |> render("index.json-api", data: tasks)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{} = params) do
    with %Task{} = task <- Task.Query.find(params) do
      conn |> render("show.json-api", data: task)
    end
  end

  @spec create(Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Task{}, params),
         {:ok, %Task{} = task} <- params |> Task.Service.create do
      conn |> put_status(:created) |> render("show.json-api", data: task)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{} = params) do
    with %Task{} = task <- Task.Query.find(params),
         %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:update, task),
         {:ok, %Task{} = task} <- task |> Task.Service.update(params) do
      conn |> render("show.json-api", data: task)
    end
  end
end
