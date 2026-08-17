"""
Observação:
Este projeto assume a seguinte estrutura:

desafio-tecnico/
│
├── config/
│   └── .env          
│
├── data/
│   └── raw/           
│
├── notebooks/
│
└── src/
    └── scripts/
        └── load_data.py <- Arquivo atual
    └── sql/
    └── conn_db.py <- conexão com o bd
"""
import sys
from pathlib import Path
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent.parent.parent
sys.path.append(str(BASE_DIR))
from src.conn_db import get_engine

def load_csv_to_db(data_path, engine):
    if not data_path.exists():
        print(f"Diretório de dados não encontrado no caminho: {data_path}. Verifique a estrutura informada.")
        return

    for csv_file in data_path.glob('*.csv'):
        try:
            print(f"Processando arquivo: {csv_file.name}...")
            df = pd.read_csv(csv_file)
            table_name = csv_file.stem
            
            df.to_sql(
                name=table_name,
                con=engine,
                if_exists='append',
                index=False
            )
            print(f"Dados carregados com sucesso na tabela {table_name}.")

            df_check = pd.read_sql(f'SELECT count(*) FROM {table_name}', con=engine)
            total_registros = df_check.iloc[0, 0]
            print(f"Total de registros na tabela {table_name}: {total_registros}.")
            
        except Exception as e:
            print(f"Erro ao processar a tabela {csv_file.stem}: {e}")


def main():
    try:
        data_path = BASE_DIR / 'data' / 'raw'
        
        engine = get_engine()
        
        print("Iniciando o carregamento dos arquivos CSV...")
        load_csv_to_db(data_path, engine)
        print("Ingestão de dados finalizado com sucesso!")
    except Exception as e:
        print(f"Falha na ingestão de dados: {e}")


if __name__ == "__main__":
    main()