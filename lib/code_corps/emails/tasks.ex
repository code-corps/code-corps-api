defmodule CodeCorps.Emails.Tasks do
  @moduledoc ~S"""
  Subcontext holding all commonly performed Tasks related to SparkPost
  """

  @templates [
    "forgot-password",
    "message-initiated-by-project",
    "organization-invite",
    "project-approval-request",
    "project-approved",
    "project-user-acceptance",
    "project-user-request",
    "receipt",
    "reply-to-conversation"
  ]

  alias CodeCorps.Emails.API

  @doc ~S"""
  Builds a stream, which, when evaluated, makes API requests to create all
  supported SparkPost templates.
  """
  @spec create_templates :: Enumerable.t()
  def create_templates do
    @templates
    |> Enum.map(fn id ->  {id, id |> build_payload} end)
    |> Enum.map(fn {id, payload} -> {id, payload |> Map.put(:id, id)} end)
    |> Stream.map(fn {id, payload} -> {id, payload |> API.create_template()} end)
  end

  @default_params [params: %{update_published: true}]

  @doc ~S"""
  Builds a stream, which, when evaluated, makes API requests to update all
  supported SparkPost templates.
  """
  @spec create_templates :: Enumerable.t()
  def update_templates do
    @templates
    |> Enum.map(fn id -> {id, id |> build_payload} end)
    |> Stream.map(fn {id, payload} -> {id, id |> API.update_template(payload, [], @default_params)} end)
  end

  @spec build_payload(String.t) :: map
  defp build_payload(id) do
    %{
      published: true,
      content: %{
        from: %{email: "{{from_email}}", name: "{{from_name}}"},
        html: id |> load_template() |> insert_styles(),
        subject: "{{subject}}"
      },
      options: %{inline_css: true, transactional: true}
    }
  end

  @spec load_template(String.t) :: String.t
  def load_template(id) do
    File.cwd! |> Path.join("emails") |> Path.join("#{id |> Inflex.underscore}.html") |> File.read!
  end

  @linked_style_element "<link rel=\"stylesheet\" type=\"text/css\" href=\"styles.css\" media=\"screen\" />"

  @spec insert_styles(String.t) :: String.t
  defp insert_styles(template_content) do
    styles = load_css_file()

    style_element = """
      <style type="text/css" rel="stylesheet" media="all">
        #{styles}
      </style>
      """

    template_content |> String.replace(@linked_style_element, style_element)
  end

  @spec load_css_file :: String.t
  defp load_css_file() do
    File.cwd! |> Path.join("emails") |> Path.join("styles.css") |> File.read!
  end
end
