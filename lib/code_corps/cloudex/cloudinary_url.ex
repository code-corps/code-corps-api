defmodule CodeCorps.Cloudex.CloudinaryUrl do

  @cloudex Application.get_env(:code_corps, :cloudex)

  def for(nil, _options, version, default_color, type) do
    "#{Application.get_env(:code_corps, :asset_host)}/icons/#{type}_default_#{version}_#{default_color}.png"
  end
  def for(public_id, options, _version, _default_color, _type) do
    @cloudex.Url.for(public_id, options)
  end
end
