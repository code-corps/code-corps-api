defmodule CodeCorps.Cloudex.Uploader do

  @cloudex Application.get_env(:code_corps, :cloudex)

  def upload(url) do
    @cloudex.upload(url)
  end
end
