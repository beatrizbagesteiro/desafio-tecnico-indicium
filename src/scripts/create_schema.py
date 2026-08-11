import csv
from pathlib import Path
from datetime import datetime

dir_atual = Path(__file__).parent
dir_csv = dir_atual.parent.parent / 'data' / 'raw'
caminho_do_arquivo = dir_csv / 'stock_movements.csv'


def get_column_type(item):

    if item.upper() == 'TRUE' or item.upper() == 'FALSE':
        return 'BOOLEAN'

    try:
        int(item)
        return 'INT'
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


limite_amostragem = 10000
linhas_lidas = 0

with open(caminho_do_arquivo, 'r',  encoding='utf8') as csv_file:
    reader = csv.reader(csv_file)
    header = next(reader)
    columns_type = ['-'] * len(header)

    for row in reader:
        for indice,item in enumerate(row):
            columns_type[indice] = get_column_type(item)
            linhas_lidas+=1

        if linhas_lidas >= limite_amostragem:
            break

for indice, column in enumerate(header):
    if 'id' in column:
        columns_type[indice] = 'INT'

print(header)
print(columns_type)
