defmodule CodeCorps.Services.ForgotPasswordService do

  alias CodeCorps.{AuthToken, Emails, Mailer, Repo, User}

  @doc"""
  forgot_password should take an email and generate an AuthToken model and send an email
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
