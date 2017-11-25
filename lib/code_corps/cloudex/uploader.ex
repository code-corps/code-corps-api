defmodule CodeCorps.Cloudex.Uploader do

  @cloudex Application.get_env(:code_corps, :cloudex)

  @spec upload(list | String.t) :: Cloudex.upload_result()
  def upload(list_or_url) do
    @cloudex.upload(list_or_url)
  end
end
