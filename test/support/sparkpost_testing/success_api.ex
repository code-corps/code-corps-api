defmodule CodeCorps.SparkPostTesting.SuccessAPI do
  @moduledoc """
  Basic testing module which servers as a mock for the SparkPost api. All
  responses should be default success responses.
  """
  def create_template(body, headers, options) do
    send(self(), {body, headers, options})
    {:ok, %HTTPoison.Response{status_code: 200}}
  end

  def update_template(id, body, headers, options) do
    send(self(), {id, body, headers, options})
    {:ok, %HTTPoison.Response{status_code: 200}}
  end

  def preview_template(template_ref, substitution_data) do
    send(self(), {template_ref, substitution_data})
    %SparkPost.Content.Inline{html: ""}
  end

  def send_transmission(%SparkPost.Transmission{recipients: recipients} = transmission) do
    send(self(), transmission)

    %SparkPost.Transmission.Response{
      id: 1,
      total_accepted_recipients: recipients |> Enum.count,
      total_rejected_recipients: 0
    }
  end
end
