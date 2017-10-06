defmodule CodeCorpsWeb.DonationGoalController do
  use CodeCorpsWeb, :controller

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.{DonationGoal, User, Helpers.Query}
  alias CodeCorps.Services.DonationGoalsService

  action_fallback CodeCorpsWeb.FallbackController
  plug :load_and_authorize_changeset, model: DonationGoal, only: [:create]
  plug :load_and_authorize_resource, model: DonationGoal, only: [:update, :delete]
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec model :: module
  def model, do: CodeCorps.DonationGoal

  def filter(_conn, query, "id", id_list), do: id_filter(query, id_list)

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with donation_goals <- DonationGoal |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: donation_goals)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %DonationGoal{} = donation_goal <- DonationGoal |> Repo.get(id) do
      conn |> render("show.json-api", data: donation_goal)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %DonationGoal{}, params),
         {:ok, %DonationGoal{} = donation_goal} <- %DonationGoal{} |> DonationGoal.create_changeset(params) |> Repo.insert do
      conn |> put_status(:created) |> render("show.json-api", data: donation_goal)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %DonationGoal{} = donation_goal <- DonationGoal |> Repo.get(id),
         %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:update, donation_goal),
         {:ok, %DonationGoal{} = donation_goal} <- donation_goal |> DonationGoal.changeset(params) |> Repo.update do
      conn |> render("show.json-api", data: donation_goal)
    end
  end

  @spec delete(Plug.Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = params) do
    with %DonationGoal{} = donation_goal <- DonationGoal |> Repo.get(id),
         %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:delete, donation_goal, params),
         {:ok, _donation_goal} <-
           donation_goal
           |> Repo.delete do
      conn |> send_resp(:no_content, "")
    end
  end
end
