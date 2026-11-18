# 📊 E-Commerce Data Analytics & Business Intelligence (Olist Dataset)

![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791.svg)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Analysis-150458.svg)
![Matplotlib](https://img.shields.io/badge/Matplotlib-Visualization-11557c.svg)
![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-ORM%20%26%20Engine-red.svg)
![Status](https://img.shields.io/badge/Status-Em%20Desenvolvimento-success.svg)

Projeto analítico de ponta a ponta voltado para extração de inteligência de negócios, comportamento do consumidor e eficiência operacional a partir do conjunto de dados público de e-commerce da **Olist** (aproximadamente 100 mil pedidos reais realizados no Brasil entre 2016 e 2018).

---

## 🎯 Objetivos de Negócio

- **Comportamento e Retenção**: Segmentar a base de clientes através do modelo **RFM (Recência, Frequência e Valor Monetário)** para identificar clientes promotores, fiéis e em risco de churn.
- **Eficiência Logística & SLA**: Medir o cumprimento de prazos de entrega e mapear gargalos regionais de distribuição.
- **Impacto no Cliente (CSAT/NPS)**: Quantificar o impacto direto dos atrasos de entrega nas notas de avaliação (*review score*).
- **Desempenho Comercial**: Analisar a evolução temporal da receita e identificar o mix de produtos mais rentável.

---

## 🏗️ Estrutura do Repositório

```text
ecommerce-data-analytics/
├── data/                  # Dados brutos (CSV originais - não versionados)
├── notebooks/             # Laboratório de exploração e visualizações
│   └── 01_exploracao.ipynb
├── docs/                  # Documentações auxiliares
├── sql/                   # Queries analíticas estruturadas em PostgreSQL
│   └── insights.sql
├── .env.example           # Template de variáveis de ambiente
├── .gitignore             # Arquivos e diretórios ignorados pelo Git
├── requirements.txt       # Dependências do projeto Python
└── README.md              # Documentação principal do projeto
```

---

## 💡 Principais Insights de Negócio

### 1. Desempenho por Categoria e Mix de Produtos
- As categorias **Beleza & Saúde** e **Relógios & Presentes** lideram o faturamento total da plataforma.
- **Estratégias distintas**: Enquanto *Beleza & Saúde* ganha pelo alto volume de vendas com ticket médio acessível (~R$ 130), *Relógios & Presentes* posiciona-se como produto premium, compensando menor volume com ticket médio elevado (~R$ 201).

### 2. Sazonalidade e Crescimento da Receita
- O pico histórico de faturamento ocorreu em **Novembro de 2017 (Black Friday)**, estabelecendo um novo patamar de vendas que se manteve e expandiu ao longo do primeiro semestre de 2018.

### 3. Segmentação de Clientes (Modelo RFM)
- A taxa de recompra histórica é de apenas **~3,1%**, revelando que o e-commerce operou majoritariamente focado em aquisição de novos clientes, com oportunidade latente de retenção (*LTV*).
- Utilizando **CTEs e Window Functions (`NTILE(4)`)**, os clientes foram classificados em:
  - **Champions**: Clientes recentes com alta frequência e alto gasto.
  - **Loyal**: Compradores assíduos com bom histórico.
  - **Promising**: Compras de alto valor, mas baixa frequência recente.
  - **At Risk**: Clientes de alto valor com muito tempo sem comprar.
  - **Lost**: Clientes inativos de baixa frequência e valor.

### 4. Logística vs. Satisfação do Cliente (Impacto Crítico)
- **SLA Geral**: **93,2%** dos pedidos foram entregues dentro do prazo estimado, e **6,8%** sofreram atraso (~6.800 pedidos).
- **Queda Brutal na Avaliação**:
  - Pedidos entregues **No prazo**: nota média de **4,28★**.
  - Pedidos entregues **Fora do prazo**: nota média despenca para **2,26★**.
  - **Queda de 47,1% (perda de mais de 2 pontos inteiros)**: o atraso logístico é o fator número um de geração de clientes detratores da marca.

### 5. Diagnóstico Geográfico de Entregas
- Os estados das regiões **Norte e Nordeste (ex: AL, MA, AP, SE, CE)** lideram o ranking de taxa de atraso e tempo médio de entrega.
- Esse cenário é decorrente da concentração massiva dos vendedores (*sellers*) e centros de distribuição nas regiões Sul e Sudeste, exigindo malha de transporte de longa distância.

### 6. Marketplace e Curva ABC de Vendedores (Princípio de Pareto)
- **Concentração Geográfica de Origem**: Mais de **91,9%** da receita dos vendedores é originada no Sul e Sudeste (com **São Paulo concentrando 64,4%** do faturamento e 57,2% dos vendedores sozinho), o que fundamenta o gargalo logístico para o Norte/Nordeste.
- **Princípio de Pareto (80/20)**:
  - **Classe A**: Apenas **17,5%** dos vendedores geram **80,0%** de todo o faturamento da plataforma (~R$ 10,87 milhões).
  - **Classe B**: **24,7%** dos vendedores geram **15,0%** da receita.
  - **Classe C (Cauda Longa)**: **57,8%** dos vendedores (mais da metade da base de parceiros) respondem por apenas **5,0%** da receita total.

### 7. Análise de Cohort e Retenção (O Efeito "Balde Furado")
- **Retenção Praticamente Nula**: A taxa média de retorno no Mês 1 (a partir de 2017) é de apenas **0,48%**, com média histórica de recompra de **0,23%**.
- **Pico Máximo de Retenção**: Desconsiderando a anomalia amostral do mês piloto (Dezembro/2016 com apenas 1 cliente), em nenhum momento a retenção superou **0,72%**, comprovando que mais de 99% dos clientes realizam uma única compra.
- **Diagnóstico Estratégico**: A Olist atua como canal transacional em marketplaces terceiros (o consumidor compra no Mercado Livre/B2W e não cria vínculo com a Olist), exigindo aquisição permanente de novos usuários para manter a receita.



---

## 🛠️ Tecnologias e Técnicas Utilizadas

- **Banco de Dados**: PostgreSQL
  - *Técnicas SQL*: Common Table Expressions (CTEs), Window Functions (`NTILE`), Funções de Data (`DATE_TRUNC`, intervalos), Agregações Condicionais (`CASE WHEN`), `JOINs` relacionais complexos.
- **Linguagem & Bibliotecas**:
  - `Python 3.11+`
  - `pandas`: Manipulação, agregação e análise de dados tabulares.
  - `SQLAlchemy` & `psycopg2-binary`: Conexão e execução de consultas diretas ao banco.
  - `matplotlib`: Visualizações de dados profissionais e customizadas.
  - `python-dotenv`: Gestão segura de credenciais via variáveis de ambiente.
- **Ambiente de Desenvolvimento**: Jupyter Notebook & VS Code.

---

## 🚀 Como Executar o Projeto Localmente

### Pré-requisitos
- Python 3.11 ou superior instalado
- PostgreSQL com o banco de dados da Olist restaurado

### Passo a Passo

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/pedrohnh06/ecommerce-data-analytics.git
   cd ecommerce-data-analytics
   ```

2. **Crie e ative o ambiente virtual:**
   ```bash
   python -m venv .venv
   # No Windows:
   .\.venv\Scripts\activate
   # No Linux/Mac:
   source .venv/bin/activate
   ```

3. **Instale as dependências:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure as variáveis de ambiente:**
   - Copie o arquivo de exemplo:
     ```bash
     cp .env.example .env
     ```
   - Edite o arquivo `.env` com os dados de acesso do seu PostgreSQL local:
     ```env
     DATABASE_URL=postgresql+psycopg2://usuario:senha@localhost:5432/olist_ecommerce
     ```

5. **Inicie o Jupyter Notebook:**
   ```bash
   jupyter notebook notebooks/01_exploracao.ipynb
   ```

---

## 📌 Próximos Passos (Roadmap)

- [x] Exploração e mapeamento do esquema relacional
- [x] Análise de receita por categoria e evolução temporal
- [x] Segmentação de clientes com modelo RFM
- [x] Análise logística de SLA e impacto no CSAT
- [x] Diagnóstico geográfico de entregas por estado (UF)
- [x] Análise de Cohort (Retenção ao longo do tempo)
- [x] Análise de Marketplace e Concentração de Vendedores (Curva ABC / Pareto)
- [ ] Desenvolvimento de Dashboard Interativo no Power BI
