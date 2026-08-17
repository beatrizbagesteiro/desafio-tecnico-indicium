"""
Observação:
Este projeto assume a seguinte estrutura:

desafio-tecnico/
│
├── config/
│   └── .env           
│
├── data/
│   └── raw/ <- arquivos csv's estão presentes nessa pasta      
│
├── notebooks/
│
└── src/
    └── scripts/
        └── create_schema.py <- Arquivo atual
    └── sql/
"""

import csv
from pathlib import Path
from datetime import datetime

def get_column_type(item):

    if item.upper() == 'TRUE' or item.upper() == 'FALSE':
        return 'BOOLEAN'

    try:
        int(item)
        if len(item) >= 11:
            return 'VARCHAR(255)'
        else:
            return 'BIGINT'
    except ValueError:
        pass

    try:
        float(item)
        return 'DECIMAL'
    except ValueError:
        pass

    try:
        datetime.fromisoformat(item)
        return 'TIMESTAMP'
    except ValueError:
        pass
    
    if item.strip() != '' or item.strip() == '':
        return 'VARCHAR(255)'

def create_tables(table_name, columns, types):
    columns_types = []
    for column,type in zip(columns,types):
        if column == 'id':
            type = 'SERIAL PRIMARY KEY'
        columns_types.append(column + " " + type)

    separador = ",\n    "
    columns_types_formatado = separador.join(columns_types)
    return f"CREATE TABLE IF NOT EXISTS {table_name} (\n    {columns_types_formatado}\n);"

def generate_schema(csv_files, file_path):
    limite_amostragem = 10000
    linhas_lidas = 0

    for caminho_csv in csv_files:
        
        with open(caminho_csv, 'r',  encoding='utf8') as csv_file:
            reader = csv.reader(csv_file)
            header = next(reader)
            columns_type = [''] * len(header)

            for row in reader:
                for indice, item in enumerate(row):
                    value = get_column_type(item)

                    if columns_type[indice] == 'DECIMAL' and value == 'BIGINT': # Decimal pode ser um int
                        pass
                    elif columns_type[indice] == '' and value.strip() == '': # se for vazio, definimos com varchar
                        columns_type[indice] = 'VARCHAR(255)'
                    elif columns_type[indice] == 'VARCHAR(255)': # se era varchar, continua como varchar
                        pass
                    elif columns_type[indice] == 'BIGINT' or columns_type[indice] == 'DECIMAL': #se era numerico e agora é varchar, define como varchar
                        if value == 'VARCHAR(255)':
                            columns_type[indice] = 'VARCHAR(255)'
                    else:
                        if columns_type[indice] == '':
                            columns_type[indice] = value

            linhas_lidas+=1

            if linhas_lidas >= limite_amostragem:
                break

            sql_query = create_tables(caminho_csv.stem, header, columns_type)
            
            with file_path.open(mode='a', encoding='utf-8') as f:
                f.write(sql_query + "\n\n")
                
            print(f"Tabela '{caminho_csv.stem}' mapeada com sucesso.")

def main():
    try:
        dir_atual = Path(__file__).parent.resolve()
        dir_csv = dir_atual.parent.parent / 'data' / 'raw'

        if not dir_csv.exists():
            raise FileNotFoundError("Diretório de dados não encontrado. Verifique a estrutura informada.")

        dir_sql = dir_atual.parent / 'sql'
        dir_sql.mkdir(parents=True, exist_ok=True)
        file_path = dir_sql / "schema.sql"

        csv_files = list(dir_csv.glob('*.csv'))
        
        if not csv_files:
            raise FileNotFoundError("Nenhum arquivo .csv encontrado.")

        print(f"Iniciando criação do schema...")
        generate_schema(csv_files, file_path)
        print(f"Schema gerado com sucesso! Arquivo salvo em: {file_path}")

    except Exception as e:
        print(f"Erro na geração do schema: {e}")

if __name__ == '__main__':
    main()