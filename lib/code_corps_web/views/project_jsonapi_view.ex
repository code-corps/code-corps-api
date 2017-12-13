defmodule CodeCorpsWeb.ProjectJsonapiView do
  @moduledoc false
  alias CodeCorps.StripeService.Validators.ProjectCanEnableDonations
  alias CodeCorps.Presenters.ImagePresenter

  use JSONAPI.View, type: "project"
  use CodeCorpsWeb, :view

  def fields, do: [
  	:approval_requested,
    :approved,
    :can_activate_donations,
    :cloudinary_public_id,
    :description,
    :donations_active,
    :icon_thumb_url,
    :icon_large_url,
    :inserted_at,
    :long_description_body,
    :long_description_markdown,
    :should_link_externally,
    :slug,
    :title,
    :total_monthly_donated,
    :updated_at,
    :website
  ]

  def can_activate_donations(project, _conn) do
    case ProjectCanEnableDonations.validate(project) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  def donations_active(project, _conn) do
    Enum.any?(project.donation_goals) && project.stripe_connect_plan != nil
  end

  def icon_large_url(project, _conn), do: ImagePresenter.large(project)

  def icon_thumb_url(project, _conn), do: ImagePresenter.thumbnail(project)
end
