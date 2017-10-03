defmodule CodeCorpsWeb.SkillController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Skill, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with skills <- Skill
         |> Query.id_filter(params)
         |> Query.title_filter(params)
         |> Query.limit_filter(params)
         |> Repo.all
    do
      conn |> render("index.json-api", data: skills)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %Skill{} = skill <- Skill |> Repo.get(id) do
      conn |> render("show.json-api", data: skill)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Skill{}, params),
         {:ok, %Skill{} = skill} <- %Skill{} |> Skill.changeset(params) |> Repo.insert do
      conn |> put_status(:created) |> render("show.json-api", data: skill)
    end
  end
end
