import csv
from pathlib import Path
from datetime import datetime

dir_atual = Path(__file__).parent
dir_csv = dir_atual.parent.parent / 'data' / 'raw'
csv_files = []
for f in dir_csv.glob('*.csv'):
    csv_files.append(f)

def get_column_type(item):

    if item.upper() == 'TRUE' or item.upper() == 'FALSE':
        return 'BOOLEAN'

    try:
        int(item)
        if len(item) >= 14:
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

limite_amostragem = 10000
linhas_lidas = 0

file_path = dir_atual.parent / 'sql' / "create_schema.sql" 

for caminho_csv in csv_files:
    with open(caminho_csv, 'r',  encoding='utf8') as csv_file:
        reader = csv.reader(csv_file)
        header = next(reader)
        columns_type = [''] * len(header)

        for row in reader:
            for indice,item in enumerate(row):
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

