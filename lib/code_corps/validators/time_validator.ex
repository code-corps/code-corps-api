defmodule CodeCorps.Validators.TimeValidator do
  @moduledoc """
  Used for validating timestamp fields in a given changeset.
  """

  alias Ecto.Changeset

  @doc """
  Validates the new time is not before the previous time.

  Works at second-level accuracy by truncating both timestamps to the second.
  """
  def validate_time_not_before(%{data: data} = changeset, field) do
    previous_time = Map.get(data, field)
    new_time = Changeset.get_change(changeset, field)
    case new_time do
      nil -> changeset
      _ -> do_validate_time_not_before(changeset, field, previous_time, new_time)
    end
  end

  defp do_validate_time_not_before(changeset, field, previous_time, new_time) do
    previous_time = previous_time |> truncate(:second)
    new_time = new_time |> truncate(:second)
    case Timex.before?(new_time, previous_time) do
      true -> Changeset.add_error(changeset, field, "cannot be before the last recorded time")
      false -> changeset
    end
  end

  # TODO: Replace this with DateTime.truncate/2 when Elixir 1.6 releases
  @spec truncate(DateTime.t, :microsecond | :millisecond | :second) :: DateTime.t
  def truncate(%DateTime{microsecond: microsecond} = datetime, precision) do
    %{datetime | microsecond: do_truncate(microsecond, precision)}
  end

  defp do_truncate(_, :second), do: {0, 0}
end
