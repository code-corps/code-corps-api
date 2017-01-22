defmodule CodeCorpsWeb.SkillController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Skill, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with skills <- params |> load_skills() |> preload do
      conn |> render("index.json-api", data: skills)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %Skill{} = skill <- Skill |> Repo.get(id) |> preload do
      conn |> render("show.json-api", data: skill)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Skill{}, params),
         {:ok, %Skill{} = skill} <- %Skill{} |> Skill.changeset(params) |> Repo.insert,
         skill <- preload(skill)
      do
      conn |> put_status(:created) |> render("show.json-api", data: skill)
    end
  end

  @elasticsearch_index "skills"
  @elasticsearch_type "title"
  @elasticsearch_url  Application.get_env(:code_corps, :elasticsearch_url)

  def search(_conn, params) do
    CodeCorps.ElasticSearchHelper.search(@elasticsearch_url, @elasticsearch_index, @elasticsearch_type, query)
  end

  @spec load_skills(map) :: list(Skill.t)
  defp load_skills(%{} = params) do
    Skill
    |> Query.id_filter(params)
    |> Query.title_filter(params)
    |> Query.limit_filter(params)
    |> Repo.all
  end

  @preloads [:role_skills]

  def preload(data) do
    Repo.preload(data, @preloads)
  end
end
