import Mox

defmock Bacen.STA.ClientMock, for: Bacen.STA.Client

defmodule FakeBacenSTA do
  @moduledoc false
  @behaviour Bacen.STA.Client

  @impl true
  def send_protocol(
        "<?xml version=\"1.0\"?><Parametros><IdentificadorDocumento>ACCS001</IdentificadorDocumento><Hash>053c29ae8b823df65f5bff084f410ca70530c30112bc7590518fe421f4421443</Hash><Tamanho>1234</Tamanho><NomeArquivo>foo</NomeArquivo><Observacao/><Destinatarios/></Parametros>"
      ) do
    {:ok,
     [
       %{
         attr: [],
         name: :Resultado,
         value: [%{attr: [], name: :Protocolo, value: ["123456789"]}]
       }
     ]}
  end

  def send_protocol(
        "<?xml version=\"1.0\"?><Parametros><IdentificadorDocumento>ACCS001</IdentificadorDocumento><Hash>053c29ae8b823df65f5bff084f410ca70530c30112bc7590518fe421f4421443</Hash><Tamanho>1234</Tamanho><NomeArquivo>invalid_xml</NomeArquivo><Observacao/><Destinatarios/></Parametros>"
      ) do
    {:ok, []}
  end

  def send_protocol(
        "<?xml version=\"1.0\"?><Parametros><IdentificadorDocumento>ACCS001</IdentificadorDocumento><Hash>053c29ae8b823df65f5bff084f410ca70530c30112bc7590518fe421f4421443</Hash><Tamanho>1234</Tamanho><NomeArquivo>error</NomeArquivo><Observacao/><Destinatarios/></Parametros>"
      ) do
    {:error,
     [
       %{
         attr: [],
         name: :Resultado,
         value: [%{attr: [], name: :Erro, value: ["bad request"]}]
       }
     ]}
  end

  @impl true
  def send_file_content("123456789", "some long file content") do
    :ok
  end

  def send_file_content("123456789", "wrong file content") do
    {:error,
     [
       %{
         attr: [],
         name: :Resultado,
         value: [%{attr: [], name: :Erro, value: ["bad request"]}]
       }
     ]}
  end
end
