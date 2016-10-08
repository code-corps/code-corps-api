defmodule CodeCorps.SkillController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Skill

  plug :load_and_authorize_resource, model: Skill, only: [:create]
  plug JaResource, except: [:index]

  def index(conn, params) do
    skills =
      Skill
      |> Skill.index_filters(params)
      |> Repo.all

    render(conn, "index.json-api", data: skills)
  end
end
