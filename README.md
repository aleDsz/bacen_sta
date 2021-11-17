# Bacen STA

[![test](https://github.com/aleDsz/bacen_sta/actions/workflows/test.yml/badge.svg?branch=main&event=push)](https://github.com/aleDsz/bacen_sta/actions/workflows/test.yml)
[![Hex pm](http://img.shields.io/hexpm/v/bacen_sta.svg?style=flat)](https://hex.pm/packages/bacen_sta)
[![codecov](https://codecov.io/gh/aleDsz/bacen_sta/branch/main/graph/badge.svg?token=FAX3D7YTUT)](https://codecov.io/gh/aleDsz/bacen_sta)

Biblioteca responsável por centralizar e simplificar a comunicação entre
uma aplicação Elixir e o [Sistema de Transferência de Arquivos](https://www.bcb.gov.br/acessoinformacao/sistematransferenciaarquivos) do Bacen.

### Manual

Para acessar o Manual de utilização do STA do Bacen, utilize este [link](https://www.bcb.gov.br/content/acessoinformacao/sisbacen_docs/Manual_STA_Web_Services.pdf)

### Instalação

Para instalar, utilize as seguintes opções:

```elixir
# Direto do github
def deps do
  [
    # ...
    {:bacen_sta, github: "aleDsz/bacen_sta"}
  ]
end

# Direto do hex
def deps do
  [
    # ...
    {:bacen_sta, "~> 0.1.0"}
  ]
end
```

Após isso, altere a função privada `application/0` para utilizar a biblioteca `xmerl` como aplicação extra:

```elixir
def application do
  [
    mod: {MyApp.Application, []},
    extra_applications: [:logger, :runtime_tools, :xmerl]
  ]
end
```

### Configuração

Para acessar o ambiente de homologação, é necessária a configuração:

```elixir
config :bacen_sta, test_mode: true
```

### O que é o STA?

O Sistema de Transferência de Arquivos – STA foi instituído pela Carta-Circular 3.588, divulgada no Diário Oficial da União de 19/03/2013.

Esse sistema tem por objetivo permitir o intercâmbio de arquivos digitais entre o Banco Central do Brasil e outras instituições cadastradas no Sisbacen, de forma padronizada e segura, por meio de conexões na Internet, utilizando o protocolo HTTPS.

O STA disponibiliza funcionalidades Web e Web Services que permitem o recebimento e envio de arquivos digitais de/para o Banco Central do Brasil, além de consultas.

O STA Web tem o objetivo de permitir que os usuários acessem as funcionalidades do sistema de forma manual, por meio de navegadores de Internet (browsers).

Os Web Services permitem o uso automatizado do STA por meio de requisições HTTPS.

### Licença

Esse projeto utiliza a licença MIT, visite o arquivo [LICENSE](./LICENSE) para
mais informações.
