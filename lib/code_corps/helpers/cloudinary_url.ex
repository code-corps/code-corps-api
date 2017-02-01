defmodule CodeCorps.Helpers.CloudinaryUrl do

  @host Application.get_env(:arc, :asset_host)

  def for(nil, _options, version, default_color, type) do
    "#{@host}/icons/#{type}_default_#{version}_#{default_color}.png"
  end
  def for(public_id, options, _version, _default_color, _type) do
    Cloudex.Url.for(public_id, options)
  end
end
