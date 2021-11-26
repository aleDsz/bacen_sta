defmodule Bacen.STA.XMLMiddleware do
  @moduledoc """
  The XML middleware for Tesla.
  """
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env = %Tesla.Env{}, next, _options) do
    env
    |> maybe_encode()
    |> Tesla.run(next)
    |> decode()
  end

  @doc """
  Encode XML element to String
  """
  def encode(element) do
    element
    |> List.wrap()
    |> :xmerl.export_simple(:xmerl_xml)
    |> List.flatten()
    |> to_string()
  end

  defp maybe_encode(env = %Tesla.Env{body: body}) when is_binary(body) or is_nil(body), do: env

  defp maybe_encode(env = %Tesla.Env{body: body}) do
    %{env | body: encode(body)}
  end

  defp decode({:ok, env = %Tesla.Env{body: body}}) when is_binary(body) and body != "" do
    {:ok, %{env | body: Quinn.parse(body)}}
  end

  defp decode(any), do: any
end
