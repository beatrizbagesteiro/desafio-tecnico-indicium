import pandas as pd

from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent.parent

path = BASE_DIR / 'data' / 'raw' 

raw_products_data = pd.read_csv(path / "products.csv")
raw_product_variants_data =  pd.read_csv(path / "product_variants.csv")
raw_orders_data = pd.read_csv(path / "orders.csv")
raw_orders_items_data = pd.read_csv(path / "order_items.csv")

products = raw_products_data.copy(deep=True)
products_variants = raw_product_variants_data.copy(deep=True)
orders = raw_orders_data.copy(deep=True)
order_items = raw_orders_items_data.copy(deep=True)

# ### Filtro e Limpeza do Produto Alvo
# 
# Nesta etapa, isolamos a base para manter apenas o produto desejado com o status **ativo**. Utilizamos o método `.loc[]` para aplicar as seguintes regras:
# 
# *   **TypeCasting:** Modificamos o tipo do atributo `created_at` para datetime, dessa forma podemos fazer as manipulações necessárias do tópico seguinte.
# *   **Correção Temporal:** Filtramos os registros para manter apenas as criações feitas até a data atual, eliminando anomalias de "datas futuras" identificadas na base de origem.
# *   **Drop de colunas:** Como o único propósito desta tabela nesta etapa é servir de ponte para o cruzamento com a tabela `product_variant`, mantemos apenas a coluna de `id`.

products['created_at'] = pd.to_datetime(products['created_at'])

products_clean = products.loc[
    (products["name"] == "Bússola de Bordo 702") & (products['is_active'] == True) & (products['created_at'] <= pd.Timestamp.today()), 
    ['id']
].copy()

# ### Filtro, Limpeza e Tratamento das variantes
# 
# *   **TypeCasting:** Modificamos o tipo do atributo `created_at` para datetime, dessa forma podemos fazer as manipulações necessárias do tópico seguinte.
# *   **Correção Temporal:** Filtramos os registros para manter apenas as criações feitas até a data atual, eliminando anomalias de "datas futuras" identificadas na base de origem.
# *   **Drop de colunas:** Mantemos as colunas que são interessantes para o treinamento final (`sale_price`, `cost_price`, `weight_price`, `idade_em_dias`) e conexão com outras tabelas (id).
# *   **Criação do atributo `idade_em_dias`:** Como os modelos preditivos não lidam corretamente com datas (seria lido como strings), fazemos a transformação para um valor númerico (dias). 

products_variants['created_at'] = pd.to_datetime(products_variants['created_at'])
products_variants = products_variants = products_variants[products_variants['created_at'] <= pd.Timestamp.today()].copy() 

df_products = pd.merge(products_clean, products_variants, left_on='id', right_on='product_id', how='inner')
df_products['idade_em_dias'] = (pd.Timestamp.today() - df_products['created_at']).dt.days

df_products = df_products[['id_y', 'sale_price', 'cost_price', 'weight_kg', 'idade_em_dias']].copy()
df_products = df_products.rename(columns={'id_y':'variant_id'})
df_products

# ### Merge e Seleção das colunas
# 
# Para esse data set não foi necessário fazer muitas mudanças, ele foi utilizado como ponte para podermos juntar as informações obtidas anteriormente com nosso dataset de vendas.

df_orders = pd.merge(df_products, order_items, left_on='variant_id', right_on='product_variant_id', how='inner')
id_variante = df_orders[['variant_id']].copy() # mantemos salvo o id das variantes para poder fazer uma analise detalhada mais tarde
df_orders = df_orders[['order_id','quantity', 'unit_price', 'sale_price', 'cost_price', 'weight_kg', 'idade_em_dias']].copy()

# %% [markdown]
# ### Filtro, Limpeza e Tratamento
# 
# *   **TypeCasting:** Modificamos o tipo do atributo `placed_at` para datetime, dessa forma podemos fazer as manipulações necessárias do tópico seguinte.
# *   **Correção Temporal:** Filtramos os registros para manter apenas os pedidos feitos até a data atual, eliminando anomalias de "datas futuras" identificadas na base de origem.
# *   **Drop de colunas:** Mantemos as colunas que são interessantes para o treinamento final.
# *   **Criação dos atributo `year`, `month` e `trimestre_venda`:** Esses valores serão necessários para o modelo poder fazer a previsão do primeiro trimestre de 2026.
# *   **Criação de Dummies:** Convertemos as colunas channel e location_id em múltiplas colunas numéricas binárias (0 e 1). Essa conversão é necessária pois o algoritmo de machine learning não processa variáveis textuais. Mesmo location_id sendo uma coluna númerica, fazemos a conversão para o algoritmo não interpretar os id's com uma lógica hierárquica (dando um peso inexistente para o id).
# *   **Criação das variáveis x e y:** Separamos os dados para treinamento (modelo_x) e os dados alvo (modelo_y). 

# %%
orders['placed_at'] = pd.to_datetime(orders['placed_at'])
orders_paid = orders[(orders['status']=='paid') & (orders['placed_at'] <= pd.Timestamp.today())].copy()
orders_paid['year'] = orders_paid['placed_at'].dt.year
orders_paid['month'] = orders_paid['placed_at'].dt.month
orders_paid['trimestre_venda'] = orders['placed_at'].dt.quarter
df_final = pd.merge(df_orders, orders_paid, left_on='order_id', right_on='id',how='inner')
df_final = df_final[['location_id','channel','quantity', 'unit_price', 'sale_price', 'cost_price','discount_amount','weight_kg','year','month','trimestre_venda','idade_em_dias']].copy()
df_final = pd.get_dummies(df_final, columns=['channel','location_id'])

'''
Baseline: é um ponto de partida simples e sem complexidade usado para comparar e medir o ganho de desempenho de modelos de inteligência artificial ou machine learning mais avançados
'''

df_2025 = df_final[df_final['year'] == 2025]

df_ultimo_periodo = df_2025[df_2025['month'].isin([7,8,9,10,11,12])] 
df_ultimo_periodo = df_ultimo_periodo.groupby('month')['quantity'].sum()
media_movel_2025 = df_ultimo_periodo.rolling(window=3).mean()
media_movel_2025 = media_movel_2025[media_movel_2025.index >= 10]
media_movel_2025

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

df_previsoes = pd.DataFrame(previsao_2026)

# #### Treinamento do modelo com DecisionTreeRegressor e RandomForestRegressor

from sklearn.tree import DecisionTreeRegressor 
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error 

'''
DecisionTreeRegressor(random_state=42) instância o algoritmo. O parametro state_random faz com que o algoritmo sempre começa sua aleatoriedade do mesmo valor (dessa forma é possível analisar
se houve melhora no algoritmo)
'''

def get_DecisionTreeRegressor_model(train_X, train_y):
    dtree = DecisionTreeRegressor(random_state=1) 
    dtree.fit(train_X, train_y) 
    return dtree

def get_RandomForest_model(train_X, train_y):
    forest_model = RandomForestRegressor(random_state=1)
    forest_model.fit(train_X, train_y)
    return forest_model


'''Para evitar o data lakage fazemos a separação dos dados de forma manual ao invés de utilizar o train_test_split da biblioteca'''
treino = df_final[df_final['year'] <= 2025].copy()
teste = df_final[(df_final['year'] == 2026) & (df_final['month'].isin([1, 2, 3]))].copy()

'''Dados de treino (até o final de 2025)'''
train_y = treino['quantity']
train_X = treino.drop(columns=['quantity'])

'''Valores que queremos prever (primeiro trimestre de 2026)'''
val_y = teste['quantity']
val_X = teste.drop(columns=['quantity'])

'''armazena o algoritmo treinado'''
model_dtree = get_DecisionTreeRegressor_model(train_X, train_y) 
model_rforest = get_RandomForest_model(train_X, train_y) 

'''predict() faz com que o algoritmo tente prever os valores do primeiro trimestre de 2026'''
dtree_prediction = model_dtree.predict(val_X) 
rforest_prediction = model_rforest.predict(val_X)

'''
Cálcula a diferença média entre as vendas reais do primeiro trimestre de 2026 (val_y) com o que o algoritmo preveu (dtree_prediction/rforest_prediction).
Dessa forma vemos qual o algoritmo mais inteligente.
'''
print("Erro Árvore de Decisão (MAE):", mean_absolute_error(val_y, dtree_prediction))
print("Erro Random Forest (MAE):", mean_absolute_error(val_y, rforest_prediction))

'''
Cria uma tabela com os valores reais e as previsoes 
| mes | vendas_reais | previsao |
'''
tb_rforest = val_X[['month']].copy()
tb_rforest['vendas_reais'] = val_y
tb_rforest['previsao'] = rforest_prediction

'''
    Faz um resumo mensal (base mensal pedida na regra da questão)
'''
tb_rforest_mensal = tb_rforest.groupby('month').sum()

'''
Tira a média do erro entre as vendas reais e as previsões (média de quantas unidades errou)
'''
mae_rf_mensal = mean_absolute_error(tb_rforest_mensal['vendas_reais'], tb_rforest_mensal['previsao'])
mae_baseline = mean_absolute_error(tb_rforest_mensal['vendas_reais'], df_previsoes['previsao'])

print(f"\nMAE Random Forest: {mae_rf_mensal}")
print(f"MAE baseline: {mae_baseline}")
print("\n")
print(tb_rforest_mensal)
