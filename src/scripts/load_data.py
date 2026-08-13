from sqlalchemy import create_engine, text
from urllib.parse import quote_plus
import os
from pathlib import Path
import pandas as pd
from dotenv import load_dotenv

import logging
logging.basicConfig(    
	level=logging.INFO,    
	format='%(asctime)s - %(levelname)s - %(message)s',    
	datefmt='%Y-%m-%d %H:%M:%S')

# __file__ vai depender inteiramente da forma que o script é executado
# se for digitado apenas script.py, o __file__ será script.py
# o .resolve() garante que __file__ será o caminho absoluto
dir_atual = Path(__file__).parent.resolve()
env_path = dir_atual.parent.parent / 'config' / '.env'
load_dotenv(env_path)

user = os.getenv('DB_USER')
password = os.getenv('DB_PASSWORD')
database = os.getenv('DB_NAME')
host = os.getenv('DB_HOST')

def get_engine():
    logging.info(f"Conectando em {host}:5432/{database}")
    return create_engine(
        f"postgresql+psycopg2://{user}:{quote_plus(password)}@{host}:5432/{database}"
    )

engine = get_engine()

data_path = dir_atual.parent.parent / 'data' / 'raw'

for csv_file in data_path.glob('*.csv'):
    df = pd.read_csv(csv_file)
    table_name = csv_file.stem
    df.to_sql(
        name = table_name,
        con = engine,
        if_exists='append',
        index=False
    )
    logging.info(f"\nDados carregados com sucesso na tabela {table_name}.")

    df_check = pd.read_sql(f'SELECT * FROM {table_name}', con = engine)
    logging.info(f"\nTotal de registros: {len(df_check)}.")