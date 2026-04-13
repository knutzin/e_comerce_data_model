#Modelo de Dados — E-Commerce
**PUC-SP · Faculdade de Ciências Exatas e Tecnologia · Ciências da Computação**  
**Disciplina:** Banco de Dados II · **Projeto 1** · v2  
**Equipe:** Nicolas Mariano da Silva, Pedro Henrique Isamu Fagundes de Souza Tsukahara Yoshissaro

---

## Descrição do Projeto

Modelagem completa de um sistema de **E-Commerce** em MySQL 8.x, cobrindo o ciclo de vida de uma compra online: catálogo de produtos, carrinho, pedidos, pagamentos, logística e avaliações pós-compra.

**13 tabelas · InnoDB · UTF-8 · 3ª Forma Normal**

---

## Entregáveis

| # | Arquivo | Descrição |
|---|---------|-----------|
| 1 | [`01_sumario_executivo_dfd.pdf`](./01_sumario_executivo_dfd.pdf) | Sumário Executivo + DFD Nível 0 |
| 2 | [`02_modelo_conceitual.pdf`](./02_modelo_conceitual.pdf) | Modelo Conceitual — entidades e relacionamentos |
| 3 | [`06_mer_ecommerce.html`](./06_mer_ecommerce.html) | Modelo Físico — MER (Diagrama Entidade-Relacionamento) |
| 4 | [`03_dicionario_dados.pdf`](./03_dicionario_dados.pdf) | Dicionário de Dados — tabelas, campos, PK, FK |
| 5 | [`05_ecommerce_script.sql`](./05_ecommerce_script.sql) | Script SQL — criação do banco + carga de dados de teste |
| 6 | [`04_qa_queries.pdf`](./04_qa_queries.pdf) | QA — 10 questões de negócio com queries e resultados |

---

## Estrutura do Banco de Dados

```
db_ecommerce
├── tb_categoria          — Hierarquia de categorias (auto-relacionamento)
├── tb_fornecedor         — Fornecedores e fabricantes
├── tb_produto            — Catálogo de produtos
├── tb_promocao           — Campanhas e cupons de desconto
├── tb_produto_promocao   — Associação N:N produtos x promoções
├── tb_cliente            — Clientes (PF e PJ)
├── tb_endereco           — Endereços de entrega e cobrança
├── tb_carrinho           — Carrinho de compras
├── tb_item_carrinho      — Itens do carrinho
├── tb_pedido             — Pedidos realizados
├── tb_item_pedido        — Itens do pedido (snapshot de preço)
├── tb_pagamento          — Pagamentos (cartão, PIX, boleto...)
├── tb_frete              — Envio e rastreamento
└── tb_avaliacao          — Avaliações verificadas de produtos
```

---

## Como executar

### Pré-requisitos
- MySQL 8.x instalado
- MySQL Workbench 8.0.46

### Passos

```bash
# 1. No MySQL Workbench: File → Run SQL Script
#    Selecione o arquivo: 05_ecommerce_script.sql

# 2. Ou via terminal:
mysql -u root -p < 05_ecommerce_script.sql
```

### Gerar o MER no Workbench
```
1. Execute o script SQL (passo acima)
2. Database → Reverse Engineer (Ctrl+Alt+R)
3. Conecte no servidor local → selecione db_ecommerce
4. Workbench gera o diagrama MER automaticamente
5. File → Export → Export as Single Page HTML → salva o .html
6. File → Save Model → salva o .mwb
```

---

## Exemplos de Queries

```sql
-- Top 5 produtos mais vendidos
SELECT p.nm_produto, SUM(ip.qt_item) AS qt_vendida
FROM tb_item_pedido ip
JOIN tb_produto p ON p.id_produto = ip.id_produto
JOIN tb_pedido  pd ON pd.id_pedido = ip.id_pedido
WHERE pd.st_pedido NOT IN ('CANCELADO','DEVOLVIDO')
GROUP BY p.id_produto ORDER BY qt_vendida DESC LIMIT 5;

-- Faturamento mensal
SELECT DATE_FORMAT(dt_pedido,'%Y-%m') AS mes,
       COUNT(*) AS pedidos, SUM(vl_total) AS faturamento
FROM tb_pedido
WHERE st_pedido NOT IN ('CANCELADO','DEVOLVIDO')
GROUP BY mes ORDER BY mes;
```

---

## Referências

- [IBM — Data Modeling](https://www.ibm.com/br-pt/think/topics/data-modeling)
- [MySQL Workbench](https://www.mysql.com/products/workbench/design/)
- [1keydata — Data Modeling Levels](https://www.1keydata.com/datawarehousing/data-modeling-levels.html)
- [Timbr.ai — Why your data model needs semantics](https://timbr.ai/blog/why-your-data-model-needs-semantics-and-relationships/)
