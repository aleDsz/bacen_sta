defmodule Bacen.STA.Client do
  @moduledoc """
  The Bacen's STA http client behaviour.
  """
  @typep error :: {:error, String.t() | atom()}
  @typep xml_node :: %{attr: keyword(), name: atom(), value: list(any())}
  @typep xml_nodes :: list(xml_node())

  @type response ::
          :ok
          | {:ok, xml_nodes() | String.t()}
          | error()

  @callback send_protocol(String.t()) :: response()
  @callback send_file_content(String.t(), String.t()) :: response()
end
