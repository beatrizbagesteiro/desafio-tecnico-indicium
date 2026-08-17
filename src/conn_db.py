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
    ├── scripts/
    ├── sql/
    └── conn_db.py <- arquivo atual
"""

from sqlalchemy import create_engine
from urllib.parse import quote_plus
from dotenv import load_dotenv
from pathlib import Path
import os


def get_engine():
    BASE_DIR = Path(__file__).resolve().parent.parent
    
    env_file = BASE_DIR / 'config' / '.env' 
    
    if env_file.exists():
        load_dotenv(env_file)
    else:
        raise FileNotFoundError(f"Arquivo .env não encontrado.")
    
    user = os.getenv('DB_USER')
    password = os.getenv('DB_PASSWORD')
    database = os.getenv('DB_NAME')
    host = os.getenv('DB_HOST')
    print(f"Conectando em {host}:5432/{database}")
    return create_engine(
        f"postgresql+psycopg2://{user}:{quote_plus(password)}@{host}:5432/{database}"
    )