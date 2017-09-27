defmodule CodeCorps.Cloudex.CloudinaryUrl do

  @cloudex Application.get_env(:code_corps, :cloudex)

  def for(nil, _options, version, default_color, type) do
    "#{Application.get_env(:code_corps, :asset_host)}/icons/#{type}_default_#{version}_#{default_color}.png"
  end
  def for(public_id, options, _version, _default_color, _type) do
    @cloudex.Url.for(public_id, options)
    |> add_uri_scheme
  end

  defp add_uri_scheme(generated_url) do
    base_url =  String.split(generated_url, "//")
    add_https(base_url)
  end

  defp add_https(base_url) when is_list(base_url) and length(base_url) > 0, do: "https://" <> List.last(base_url)
  defp add_https(url), do: url

end
