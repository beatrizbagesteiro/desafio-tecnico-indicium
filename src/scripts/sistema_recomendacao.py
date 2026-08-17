"""
Observação:
Este projeto assume a seguinte estrutura:

desafio-tecnico/
│
├── config/
│   └── .env           
│
├── data/
│
└── src/
    ├── scripts/
    │   └── sistema_recomendacao.py <- Arquivo atual
    ├── sql/
    └── conn_db.py <- conexão com o bd
"""

import sys
from pathlib import Path
import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

BASE_DIR = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(BASE_DIR))

from src.conn_db import get_engine

def load_raw_data(engine):
    print("Extraindo os dados do banco de dados.")
    
    products = pd.read_sql('SELECT * FROM products', con=engine)
    variants = pd.read_sql('SELECT * FROM product_variants', con=engine)
    orders = pd.read_sql('SELECT * FROM orders', con=engine)
    order_items = pd.read_sql('SELECT * FROM order_items', con=engine)
    
    return products, variants, orders, order_items

def build_matrix(products, variants, orders, order_items):
    """
    Realiza os cruzamentos necessários entre produtos, variantes e pedidos
    para construir a matriz de interação (cliente vs produto).
    """
    print("Processando dados e construindo matriz de interações...")
    hoje = pd.Timestamp.today()
    
    # Filtro de produtos ativos
    products_active = products[products['is_active'] == True].copy()
    
    # Merge de Produtos e Variantes
    df_products = pd.merge(products_active, variants, left_on='id', right_on='product_id', how='inner')
    df_products = df_products[['id_x', 'id_y']].copy()
    df_products = df_products.rename(columns={'id_x': 'product_id', 'id_y': 'variant_id'})
    
    # Merge com Itens do Pedido
    df_orders = pd.merge(df_products, order_items, left_on='variant_id', right_on='product_variant_id')
    df_orders = df_orders[['product_id', 'order_id']].copy()
    
    # Filtro Temporal e de Status dos Pedidos
    orders['placed_at'] = pd.to_datetime(orders['placed_at'])
    orders_paid = orders[(orders['status'] == 'paid') & (orders['placed_at'] <= hoje)].copy()
    
    # Merge Final para obter Cliente e Produto
    df_orders = pd.merge(df_orders, orders_paid, left_on='order_id', right_on='id')
    df_orders = df_orders[['product_id', 'customer_id']].copy()
    
    # Construção da Matriz
    matriz_usuario_produto = pd.crosstab(index=df_orders['customer_id'], columns=df_orders['product_id'])

    return matriz_usuario_produto

def get_recommendations(target_name, products, matriz_usuario_produto):
    """
    Calcula a similaridade do cosseno da matriz e retorna os itens 
    mais similares ao produto alvo.
    """
    print("Calculando similaridade de cosseno...")
    
    # Similaridade de Cosseno precisa transpor a matriz para calcular entre colunas (produtos)
    similaridade_array = cosine_similarity(matriz_usuario_produto.T)
    similaridade_produtos = pd.DataFrame(
        similaridade_array, 
        index=matriz_usuario_produto.columns, 
        columns=matriz_usuario_produto.columns
    )
    
    # Identifica o ID do produto alvo de forma dinâmica
    produto_alvo = products.loc[products["name"] == target_name, ['id']].copy()
    
    if produto_alvo.empty:
        print(f"Erro: Produto '{target_name}' não encontrado na base de dados.")
        return pd.DataFrame()
        
    id_alvo = produto_alvo['id'].item()
    print(f"Buscando as top 5 recomendações para o produto {target_name}.")
    
    # Isola o produto alvo, ordena os mais parecidos e remove o próprio produto do ranking
    top_produtos = similaridade_produtos[id_alvo].sort_values(ascending=False)
    top_produtos = top_produtos.drop(id_alvo)
    top_produtos = top_produtos.head(5).reset_index()
    
    ranking = pd.merge(top_produtos, products[['id', 'name']], left_on='product_id', right_on='id')
    
    ranking = ranking.rename(columns={id_alvo: 'cosine_similarity', 'name': 'product_name'})
    ranking = ranking.drop(columns=['id'])
    ranking = ranking[['product_id', 'product_name', 'cosine_similarity']]
    
    return ranking

def main():
    try:
        print("\nIniciando pipeline...")
        
        engine = get_engine()
        products, variants, orders, order_items = load_raw_data(engine)
        
        matriz = build_matrix(products, variants, orders, order_items)
        
        produto_alvo = "Motor de Popa 1949"
        ranking_df = get_recommendations(produto_alvo, products, matriz)
        
        if not ranking_df.empty:
            print(f"\nTop 5: '{produto_alvo.upper()}'")
            print(ranking_df)
            
        print("\nPipeline executado com sucesso!")
        
    except Exception as e:
        print(f"Falha na execução: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()