defmodule CodeCorps.Emails.ReceiptEmail do
  import Bamboo.Email, only: [to: 2]
  import Bamboo.PostmarkHelper

  alias CodeCorps.Emails.BaseEmail
  alias CodeCorps.{DonationGoal, Project, Repo, StripeConnectCharge, StripeConnectSubscription, WebClient, User}

  @spec get_name(User.t) :: String.t
  def get_name(%User{ first_name: nil }), do: "there"

  @spec get_name(User.t) :: String.t
  def get_name(%User{ first_name: name}), do: name

   @spec create(StripeConnectCharge.t, Stripe.Invoice.t) :: Bamboo.Email.t
  def create(%StripeConnectCharge{} = charge, %Stripe.Invoice{} = invoice) do
    with %StripeConnectCharge{} = charge <- Repo.preload(charge, :user),
         %Project{} = project <- get_project(invoice.subscription),
         {:ok, %DonationGoal{} = current_donation_goal} <- get_current_donation_goal(project),
         template_model <- build_model(charge, project, current_donation_goal)
    do
      BaseEmail.create
      |> to(charge.user.email)
      |> template(template_id(), template_model)
    else
      nil -> {:error, :project_not_found}
      other -> other
    end
  end

  @spec get_project(String.t) :: Project.t | {:error, :subscription_not_found}
  defp get_project(subscription_id_from_stripe) do
    with %StripeConnectSubscription{} = subscription <- get_subscription(subscription_id_from_stripe) do
      subscription.stripe_connect_plan.project
    else
      nil -> {:error, :subscription_not_found}
    end
  end

  @spec get_subscription(String.t) :: StripeConnectSubscription.t | nil
  defp get_subscription(subscription_id_from_stripe) do
    StripeConnectSubscription
    |> Repo.get_by(id_from_stripe: subscription_id_from_stripe)
    |> Repo.preload(stripe_connect_plan: [project: :organization])
  end

  @spec get_current_donation_goal(Project.t) :: DonationGoal.t | {:error, :donation_goal_not_found}
  defp get_current_donation_goal(project) do
    case  Repo.get_by(DonationGoal, current: true, project_id: project.id) do
      nil -> {:error, :donation_goal_not_found}
      donation_goal -> {:ok, donation_goal}
    end
  end

  @spec build_model(StripeConnectCharge.t, Project.t, DonationGoal.t) :: map
  defp build_model(charge, project, current_donation_goal) do
    %{
      charge_amount: charge.amount |> format_amount(),
      charge_statement_descriptor: charge.statement_descriptor,
      high_five_image_url: high_five_image_url(),
      name: BaseEmail.get_name(charge.user),
      project_current_donation_goal_description: current_donation_goal.description,
      project_title: project.title,
      project_url: project |> url(),
      subject: project |> build_subject_line(),
      name: get_name(charge.user)
    }
  end

  @spec build_subject_line(Project.t) :: String.t
  defp build_subject_line(project) do
    "Your monthly donation to " <> project.title
  end

  @spec high_five_image_url :: String.t
  defp high_five_image_url, do: Enum.random(high_five_image_urls())

  @spec high_five_image_urls :: list(String.t)
  defp high_five_image_urls, do: [
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3fb@2x.png",
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3fc@2x.png",
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3fd@2x.png",
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3fe@2x.png",
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3ff@2x.png"
  ]

  @spec format_amount(integer) :: binary
  defp format_amount(amount) do
    amount |> Money.new(:USD) |> Money.to_string()
  end

  @spec url(Project.t) :: String.t
  defp url(project) do
    WebClient.url()
    |> URI.merge(project.organization.slug <> "/" <> project.slug)
    |> URI.to_string
  end

  @spec template_id :: String.t
  defp template_id, do: Application.get_env(:code_corps, :postmark_receipt_template)
end
