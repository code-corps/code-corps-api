defmodule CodeCorps.Services.ForgotPasswordService do
  # credo:disable-for-this-file Credo.Check.Refactor.PipeChainStart

  alias CodeCorps.{AuthToken, Emails, Mailer, Repo, User}

  @doc"""
  Generates an AuthToken model and sends to the provided email.
  """
  def forgot_password(email) do
    with %User{} = user <- Repo.get_by(User, email: email),
        { :ok, %AuthToken{} = %{ value: token } } <- AuthToken.changeset(%AuthToken{}, user) |> Repo.insert
    do
      Emails.ForgotPasswordEmail.create(user, token) |> Mailer.deliver_now()
    else
      nil -> nil
    end
  end
end
