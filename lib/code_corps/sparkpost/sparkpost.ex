defmodule CodeCorps.SparkPost do
  alias CodeCorps.SparkPost.Tasks

  defdelegate create_templates, to: Tasks
  defdelegate update_templates, to: Tasks
end
