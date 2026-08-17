# Desafio Técnico - Beatriz Alves

Este diretório contém a resolução do desafio técnico de dados da Indicium.

## Estrutura do Projeto

Abaixo está a organização de diretórios e arquivos enviados:

```text
desafio-tecnico/
│
├── config/
│   └── .env                 <- Arquivo de configuração de variáveis de ambiente
│
├── data/
│   └── raw/                 <- Os arquivos .csv originais devem ser colocados nesta pasta
│
├── notebooks/
│
└── src/
    ├── scripts/
    │   └── load_data.py     <- Script principal para carga dos dados
    ├── sql/
    └── conn_db.py           <- Configuração de conexão com o banco de dados
Observações e Configuração
Variáveis de Ambiente: Para que a conexão com o banco de dados (conn_db.py) funcione corretamente, você deve criar ou editar o arquivo .env dentro da pasta config/ contendo exatamente a seguinte estrutura:

Fragmento do código
DB_USER=beatrizalves
DB_PASSWORD=123
DB_NAME=desafio_tecnico_indicium
DB_HOST=localhost
O script principal responsável por iniciar a modelagem e carregar os dados para o banco é o src/scripts/load_data.py.

Certifique-se de que os dados originais estejam descompactados dentro da pasta data/raw/ antes da execução.
