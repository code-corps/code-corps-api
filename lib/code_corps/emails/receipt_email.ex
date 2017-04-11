defmodule CodeCorps.Emails.ReceiptEmail do
  import Bamboo.Email
  import Bamboo.PostmarkHelper

  alias CodeCorps.Emails.BaseEmail
  alias CodeCorps.Repo
  alias CodeCorps.Web.{
    DonationGoal, Project, StripeConnectCharge, StripeConnectSubscription
  }

  def create(%StripeConnectCharge{} = charge, %Stripe.Invoice{} = invoice) do
    with %StripeConnectCharge{} = charge <- preload(charge),
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

  defp preload(%StripeConnectCharge{} = charge) do
    Repo.preload(charge, :user)
  end

  defp get_project(subscription_id_from_stripe) do
    with %StripeConnectSubscription{} = subscription <- get_subscription(subscription_id_from_stripe) do
      subscription.stripe_connect_plan.project
    else
      nil -> {:error, :subscription_not_found}
    end
  end

  defp get_subscription(subscription_id_from_stripe) do
    StripeConnectSubscription
    |> Repo.get_by(id_from_stripe: subscription_id_from_stripe)
    |> Repo.preload(stripe_connect_plan: [project: :organization])
  end

  defp get_current_donation_goal(project) do
    case  Repo.get_by(DonationGoal, current: true, project_id: project.id) do
      nil -> {:error, :donation_goal_not_found}
      donation_goal -> {:ok, donation_goal}
    end
  end

  defp build_model(charge, project, current_donation_goal) do
    %{
      charge_amount: charge.amount |> format_amount(),
      charge_statement_descriptor: charge.statement_descriptor,
      high_five_image_url: high_five_image_url(),
      project_current_donation_goal_description: current_donation_goal.description,
      project_title: project.title,
      project_url: project |> url(),
      subject: project |> build_subject_line(),
      user_first_name: charge.user.first_name
    }
  end

  defp build_subject_line(project) do
    "Your monthly donation to " <> project.title
  end

  defp high_five_image_url, do: Enum.random(high_five_image_urls())

  defp high_five_image_urls, do: [
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3fb@2x.png",
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3fc@2x.png",
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3fd@2x.png",
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3fe@2x.png",
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3ff@2x.png"
  ]

  defp format_amount(amount) do
    Money.to_string(Money.new(amount, :USD))
  end

  defp url(project) do
    Application.get_env(:code_corps, :site_url)
    |> URI.merge(project.organization.slug <> "/" <> project.slug)
    |> URI.to_string
  end

  defp template_id, do: Application.get_env(:code_corps, :postmark_receipt_template)
end
