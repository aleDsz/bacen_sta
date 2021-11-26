defmodule Bacen.STA.HTTP do
  @moduledoc """
  It's a HTTP client that talks to STA's API endpoints.

  ## Configuration

  ```elixir
  config :bacen_sta,
    test: true,
    client: Bacen.STA.HTTP,
    credentials: [
      username: "username",
      password: "password"
    ]
  ```
  """
  @behaviour Bacen.STA.Client

  @success_statuses 200..299

  @doc """
  Send file information to Bacen and retrieve the file protocol to
  upload content
  """
  @impl true
  def send_protocol(xml) do
    post(client(), "/arquivos", xml)
  end

  @doc """
  Send file content from given XML content for given protocol to Bacen
  """
  @impl true
  def send_file_content(protocol, xml) do
    with {:ok, _} <- put(client(), "/arquivos/#{protocol}/conteudo", xml) do
      :ok
    end
  end

  defp client do
    # coveralls-ignore-start
    credentials =
      :bacen_sta
      |> Application.get_env(:credentials)
      |> Enum.into(%{})

    base_url = base_url(Bacen.STA.test?())
    headers = [{"Content-Type", "application/xml"}]

    middlewares = [
      Bacen.STA.XMLMiddleware,
      {Tesla.Middleware.Headers, headers},
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.BasicAuth, credentials},
      Tesla.Middleware.Telemetry
    ]

    Tesla.client(middlewares)
    # coveralls-ignore-stop
  end

  defp base_url(true), do: "https://sta-h.bcb.gov.br/staws"
  defp base_url(false), do: "https://sta.bcb.gov.br/staws"

  defp post(client, path, body) do
    request(client, method: :post, url: path, body: body)
  end

  defp put(client, path, body) do
    request(client, method: :put, url: path, body: body)
  end

  defp request(client, options) do
    case Tesla.request(client, options) do
      {:ok, %Tesla.Env{body: body, status: status}} when status in @success_statuses ->
        {:ok, body}

      {:ok, %Tesla.Env{body: message}} ->
        {:error, message}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
