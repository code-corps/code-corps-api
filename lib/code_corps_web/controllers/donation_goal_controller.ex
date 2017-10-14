defmodule CodeCorpsWeb.DonationGoalController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.Services.DonationGoalsService
  alias CodeCorps.{DonationGoal, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

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
         {:ok, %DonationGoal{} = donation_goal} <- DonationGoalsService.create(params) do
      conn |> put_status(:created) |> render("show.json-api", data: donation_goal)
    end
  end

  @spec delete(Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = _params) do
    with %DonationGoal{} = donation_goal <- DonationGoal |> Repo.get(id),
      %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:delete, donation_goal),
      {:ok, %DonationGoal{} = _donation_goal} <- donation_goal |> Repo.delete
    do
      conn |> Conn.assign(:donation_goal, donation_goal) |> send_resp(:no_content, "")
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %DonationGoal{} = donation_goal <- DonationGoal |> Repo.get(id),
      %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:update, donation_goal),
      {:ok, %DonationGoal{} = updated_donation_goal} <- donation_goal |> DonationGoalsService.update(params) do
        conn |> render("show.json-api", data: updated_donation_goal)
    end
  end
end
