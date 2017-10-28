defmodule CodeCorps.Validators.TimeValidator do
  @moduledoc """
  Used for validating timestamp fields in a given changeset.
  """

  alias Ecto.Changeset

  @doc """
  Validates a time after a given time.
  """
  def validate_time_after(%{data: data} = changeset, field) do
    previous_time = Map.get(data, field)
    current_time = Changeset.get_change(changeset, field)
    is_after = current_time |> Timex.after?(previous_time)
    is_equal = current_time |> Timex.equal?(previous_time)
    after_or_equal = is_after || is_equal
    case after_or_equal do
      true -> changeset
      false -> Changeset.add_error(changeset, field, "cannot be before the last recorded time")
    end
  end
end
