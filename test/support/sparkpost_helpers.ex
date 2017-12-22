defmodule CodeCorps.SparkPostHelpers do
  @moduledoc """
  Holds helpers used for various Sparkpost related tests
  """

  @reserved_keys [:else, :end, :if, :for]
  @global_keys [:subject, :from_name, :from_email]

  @doc ~S"""
  Scans a SparkPost email template and returns all keys used by the template,
  as atoms.

  This includes keys which would have been provided by the recipient.


  Use `remove_recipient_keys/1` to drop those.
  """
  @spec get_keys_used_by_template(String.t) :: list(Atom.t)
  def get_keys_used_by_template(id) do
    File.cwd!
    |> Path.join("emails")
    |> Path.join("#{id |> Inflex.underscore}.html")
    |> File.read!
    |> (fn template -> Regex.scan(~r/{{\s*[\w_]+\s*}}/, template) end).()
    |> List.flatten
    |> Enum.map(&Regex.scan(~r/[\w\.]+/, &1))
    |> List.flatten
    |> Enum.uniq
    |> Enum.map(&String.to_existing_atom/1)
    |> (fn list -> list -- @reserved_keys end).()
    |> Enum.concat(@global_keys)
    |> Enum.sort
  end
end
