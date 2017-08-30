defmodule CodeCorpsWeb.DonationGoalController do
  use CodeCorpsWeb, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.DonationGoal
  alias CodeCorps.Services.DonationGoalsService

  plug :load_and_authorize_changeset, model: DonationGoal, only: [:create]
  plug :load_and_authorize_resource, model: DonationGoal, only: [:update, :delete]
  plug JaResource

  @spec model :: module
  def model, do: CodeCorps.DonationGoal

  def filter(_conn, query, "id", id_list), do: id_filter(query, id_list)

  def handle_create(_conn, attributes) do
    attributes |> DonationGoalsService.create
  end

  def handle_update(_conn, record, attributes) do
    record |> DonationGoalsService.update(attributes)
  end
end
