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
    │   └── modelo_preditivo.py <- Arquivo atual
    ├── sql/
    └── conn_db.py <- conexão com o bd
"""

import sys
import logging
import pandas as pd
from sklearn.tree import DecisionTreeRegressor 
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error 
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent.parent
sys.path.append(str(BASE_DIR))
from src.conn_db import get_engine

def load_raw_data(engine):
    print("Extraindo dados do banco de dados...")
    
    products = pd.read_sql('SELECT * FROM products', con=engine)
    variants = pd.read_sql('SELECT * FROM product_variants', con=engine)
    orders = pd.read_sql('SELECT * FROM orders', con=engine)
    order_items = pd.read_sql('SELECT * FROM order_items', con=engine)
    
    return products, variants, orders, order_items

def build_dataset(products, variants, orders, order_items):
    """
    Limpeza, typecasting e merges para construir o dataset usado no modelo.
    """
    print("Iniciando o processamento e cruzamento de dados...")
    hoje = pd.Timestamp.today()
    
    # Filtro e Limpeza: Products
    products['created_at'] = pd.to_datetime(products['created_at'])
    products_clean = products.loc[
        (products["name"] == "Bússola de Bordo 702") & 
        (products['is_active'] == True) & 
        (products['created_at'] <= hoje), 
        ['id']
    ].copy()

    # Filtro e Limpeza: Variants
    variants['created_at'] = pd.to_datetime(variants['created_at'])
    variants_clean = variants[variants['created_at'] <= hoje].copy() 

    # Merge Products + Variants
    df_products = pd.merge(products_clean, variants_clean, left_on='id', right_on='product_id', how='inner')
    df_products['idade_em_dias'] = (hoje - df_products['created_at']).dt.days
    df_products = df_products[['id_y', 'sale_price', 'cost_price', 'weight_kg', 'idade_em_dias']].copy()
    df_products = df_products.rename(columns={'id_y':'variant_id'})

    # Merge com Order Items
    df_orders = pd.merge(df_products, order_items, left_on='variant_id', right_on='product_variant_id', how='inner')
    df_orders = df_orders[['order_id', 'quantity', 'unit_price', 'sale_price', 'cost_price', 'weight_kg', 'idade_em_dias']].copy()

    # Filtro e Limpeza: Orders
    orders['placed_at'] = pd.to_datetime(orders['placed_at'])
    orders_paid = orders[(orders['status'] == 'paid') & (orders['placed_at'] <= hoje)].copy()
    orders_paid['year'] = orders_paid['placed_at'].dt.year
    orders_paid['month'] = orders_paid['placed_at'].dt.month
    orders_paid['trimestre_venda'] = orders_paid['placed_at'].dt.quarter
    
    # Merge Final e Criação de Dummies
    df_final = pd.merge(df_orders, orders_paid, left_on='order_id', right_on='id', how='inner')
    colunas_finais = [
        'location_id', 'channel', 'quantity', 'unit_price', 'sale_price', 
        'cost_price', 'discount_amount', 'weight_kg', 'year', 'month', 
        'trimestre_venda', 'idade_em_dias'
    ]
    df_final = df_final[colunas_finais].copy()
    df_final = pd.get_dummies(df_final, columns=['channel', 'location_id'])
    
    return df_final

def calculate_baseline(df_final):
    """
    Gera a previsão de baseline baseada na média móvel 
    dos últimos 3 meses de 2025.
    """
    print("Calculando a Baseline (Média Móvel)...")
    df_2025 = df_final[df_final['year'] == 2025]
    
    # Agrupa os últimos 6 meses e gera a média móvel
    df_ultimo_periodo = df_2025[df_2025['month'].isin([7, 8, 9, 10, 11, 12])] 
    df_ultimo_periodo = df_ultimo_periodo.groupby('month')['quantity'].sum()
    
    media_movel_2025 = df_ultimo_periodo.rolling(window=3).mean()
    media_movel_2025 = media_movel_2025[media_movel_2025.index >= 10]
    
    m_2025_list = media_movel_2025.tolist()
    meses_previsao = [1, 2, 3]
    previsao_2026 = []

    for mes in meses_previsao:
        ultimos_3_meses = m_2025_list[-3:]
        previsao = sum(ultimos_3_meses) / 3
        m_2025_list.append(previsao)
        previsao_2026.append({
            'mes': mes,
            'previsao': round(previsao)
        })

    return pd.DataFrame(previsao_2026)

def train_and_evaluate_models(df_final, df_baseline):
    """
    Separa os dados em treino e teste, executa o treinamento dos modelos
    (Decision Tree e Random Forest) e exibe as métricas de erro.
    """
    print("Separando dados de treino e teste...")
    
    # Previne data leakage separando temporalmente
    treino = df_final[df_final['year'] <= 2025].copy()
    teste = df_final[(df_final['year'] == 2026) & (df_final['month'].isin([1, 2, 3]))].copy()

    train_y = treino['quantity']
    train_X = treino.drop(columns=['quantity'])

    val_y = teste['quantity']
    val_X = teste.drop(columns=['quantity'])

    print("Treinando os modelos...")
    
    # Instancia e treina
    dtree = DecisionTreeRegressor(random_state=1) 
    dtree.fit(train_X, train_y) 
    
    rforest = RandomForestRegressor(random_state=1)
    rforest.fit(train_X, train_y)

    # Predições
    dtree_prediction = dtree.predict(val_X) 
    rforest_prediction = rforest.predict(val_X)

    # Comparação da MAE dos dois algoritmos
    print("\n Comparação entre os algoritmos Árvore de Decisão/Random Forest (RF possui um desempenho melhor)")
    print(f"Erro Árvore de Decisão (MAE): {mean_absolute_error(val_y, dtree_prediction):.4f}")
    print(f"Erro Random Forest (MAE):     {mean_absolute_error(val_y, rforest_prediction):.4f}")

    # Avaliação Mensal (Conforme regra de negócio)
    tb_rforest = val_X[['month']].copy()
    tb_rforest['vendas_reais'] = val_y
    tb_rforest['previsao'] = rforest_prediction
    tb_rforest_mensal = tb_rforest.groupby('month').sum()

    mae_rf_mensal = mean_absolute_error(tb_rforest_mensal['vendas_reais'], tb_rforest_mensal['previsao'])
    mae_baseline = mean_absolute_error(tb_rforest_mensal['vendas_reais'], df_baseline['previsao'])

    print("\n\nMédias de erro (RF e Baseline) ")
    print(f"MAE Random Forest: {mae_rf_mensal:.4f}")
    print(f"MAE Baseline:      {mae_baseline:.4f}")
    print("\n\nComparativo Mensal (RF)")
    print(tb_rforest_mensal)



def main():
    try:
        print("Iniciando pipeline...")

        engine = get_engine()
        
        products, variants, orders, order_items = load_raw_data(engine)
        
        df_final = build_dataset(products, variants, orders, order_items)
        
        df_baseline = calculate_baseline(df_final)
        
        train_and_evaluate_models(df_final, df_baseline)
        
        print("Pipeline executado com sucesso!")
        
    except Exception as e:
        logging.critical(f"Falha na execução do modelo preditivo: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()