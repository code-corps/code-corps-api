defmodule CodeCorps.SparkPost.Emails.Receipt do

  alias SparkPost.{Content, Transmission}
  alias CodeCorps.{
    DonationGoal,
    Project,
    Repo,
    SparkPost.Emails.Recipient,
    StripeConnectCharge,
    StripeConnectSubscription,
    User,
    WebClient
  }

  @high_five_image_urls [
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3fb@2x.png",
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3fc@2x.png",
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3fd@2x.png",
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3fe@2x.png",
    "https://d3pgew4wbk2vb1.cloudfront.net/emails/images/emoji-1f64c-1f3ff@2x.png"
  ]

  @spec build(StripeConnectCharge.t, Stripe.Invoice.t) :: %Transmission{}
  def build(%StripeConnectCharge{} = charge, %Stripe.Invoice{} = invoice) do
    with %StripeConnectCharge{user: %User{} = user} = charge <- Repo.preload(charge, :user),
         %Project{} = project <- invoice.subscription |> get_project(),
         {:ok, %DonationGoal{} = current_donation_goal} <- project |> get_current_donation_goal()
    do
      %Transmission{
        content: %Content.TemplateRef{template_id: template_id()},
        options: %Transmission.Options{inline_css: true},
        recipients: [user |> Recipient.build],
        substitution_data: %{
          charge_amount: charge.amount |> Money.new(:USD) |> Money.to_string(),
          charge_statement_descriptor: charge.statement_descriptor,
          from_name: "Code Corps",
          from_email: "team@codecorps.org",
          high_five_image_url: Enum.random(@high_five_image_urls),
          name: charge.user |> get_name(),
          project_current_donation_goal_description: current_donation_goal.description,
          project_title: project.title,
          project_url: project |> url(),
          subject: "Your monthly donation to #{project.title}"
        }
      }
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

  @spec url(Project.t) :: String.t
  defp url(project) do
    WebClient.url()
    |> URI.merge(project.organization.slug <> "/" <> project.slug)
    |> URI.to_string
  end

  @spec get_name(User.t) :: String.t
  defp get_name(%User{first_name: nil}), do: "there"
  defp get_name(%User{first_name: name}), do: name

  @doc ~S"""
  Returns configured template ID for this email
  """
  @spec template_id :: String.t
  def template_id do
    Application.get_env(:code_corps, :sparkpost_receipt_template)
  end
end
