defmodule CodeCorps.SparkPostTesting.FailureAPI do
  @moduledoc """
  Basic testing module which servers as a mock for the SparkPost api. All
  responses should be some form of a failure response.
  """

  @bad_request %SparkPost.Endpoint.Error{
    errors: [%{message: "Bad request"}],
    status_code: 400
  }

  def create_template(body, headers, options) do
    send(self(), {body, headers, options})
    @bad_request
  end

  def update_template(id, body, headers, options) do
    send(self(), {id, body, headers, options})
    @bad_request
  end

  def preview_template(template_ref, substitution_data) do
    send(self(), {template_ref, substitution_data})
    @bad_request
  end

  def send_transmission(%SparkPost.Transmission{} = transmission) do
    send(self(), transmission)
    @bad_request
  end
end
