-- =============================================================================
-- PROJETO: Modelo de Dados E-Commerce
-- DISCIPLINA: Banco de Dados II - PUC-SP
-- SGBD: MySQL 8.x
-- DESCRIÇÃO: Script de criação do banco de dados e carga de dados de teste
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. CRIAÇÃO DO BANCO DE DADOS
-- -----------------------------------------------------------------------------
DROP DATABASE IF EXISTS db_ecommerce;
CREATE DATABASE db_ecommerce
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE db_ecommerce;

-- =============================================================================
-- 2. CRIAÇÃO DAS TABELAS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- TABELA: tb_categoria
-- DESCRIÇÃO: Categorias de produtos com suporte a hierarquia (subcategorias)
-- -----------------------------------------------------------------------------
CREATE TABLE tb_categoria (
    id_categoria    INT             NOT NULL AUTO_INCREMENT,
    nm_categoria    VARCHAR(100)    NOT NULL COMMENT 'Nome da categoria',
    ds_categoria    VARCHAR(255)        NULL COMMENT 'Descrição da categoria',
    id_categoria_pai INT             NULL COMMENT 'FK para categoria pai (hierarquia)',
    fl_ativo        TINYINT(1)      NOT NULL DEFAULT 1 COMMENT '1=Ativo, 0=Inativo',
    dt_criacao      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_atualizacao  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_categoria     PRIMARY KEY (id_categoria),
    CONSTRAINT fk_cat_pai       FOREIGN KEY (id_categoria_pai) REFERENCES tb_categoria(id_categoria)
) ENGINE=InnoDB COMMENT='Categorias e subcategorias de produtos';

-- -----------------------------------------------------------------------------
-- TABELA: tb_fornecedor
-- DESCRIÇÃO: Fornecedores / fabricantes dos produtos
-- -----------------------------------------------------------------------------
CREATE TABLE tb_fornecedor (
    id_fornecedor   INT             NOT NULL AUTO_INCREMENT,
    nm_fornecedor   VARCHAR(150)    NOT NULL COMMENT 'Razão social',
    nm_fantasia     VARCHAR(150)        NULL COMMENT 'Nome fantasia',
    nr_cnpj         CHAR(14)        NOT NULL COMMENT 'CNPJ sem máscara',
    nr_ie           VARCHAR(20)         NULL COMMENT 'Inscrição Estadual',
    ds_email        VARCHAR(100)        NULL,
    nr_telefone     VARCHAR(20)         NULL,
    nm_contato      VARCHAR(100)        NULL COMMENT 'Nome do contato principal',
    ds_rua          VARCHAR(200)        NULL,
    nr_numero       VARCHAR(10)         NULL,
    ds_complemento  VARCHAR(100)        NULL,
    nm_bairro       VARCHAR(100)        NULL,
    nm_cidade       VARCHAR(100)        NULL,
    sg_uf           CHAR(2)             NULL,
    nr_cep          CHAR(8)             NULL,
    fl_ativo        TINYINT(1)      NOT NULL DEFAULT 1,
    dt_criacao      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_atualizacao  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_fornecedor    PRIMARY KEY (id_fornecedor),
    CONSTRAINT uq_fornecedor_cnpj UNIQUE (nr_cnpj)
) ENGINE=InnoDB COMMENT='Fornecedores e fabricantes de produtos';

-- -----------------------------------------------------------------------------
-- TABELA: tb_produto
-- DESCRIÇÃO: Catálogo de produtos disponíveis para venda
-- -----------------------------------------------------------------------------
CREATE TABLE tb_produto (
    id_produto      INT             NOT NULL AUTO_INCREMENT,
    id_categoria    INT             NOT NULL COMMENT 'FK Categoria',
    id_fornecedor   INT             NOT NULL COMMENT 'FK Fornecedor principal',
    cd_sku          VARCHAR(50)     NOT NULL COMMENT 'Código SKU único do produto',
    cd_barras       VARCHAR(20)         NULL COMMENT 'Código EAN/barras',
    nm_produto      VARCHAR(200)    NOT NULL,
    ds_produto      TEXT                NULL COMMENT 'Descrição detalhada',
    vl_custo        DECIMAL(12,2)   NOT NULL COMMENT 'Preço de custo',
    vl_preco        DECIMAL(12,2)   NOT NULL COMMENT 'Preço de venda',
    vl_preco_atacado DECIMAL(12,2)      NULL COMMENT 'Preço de atacado',
    qt_estoque      INT             NOT NULL DEFAULT 0,
    qt_estoque_minimo INT           NOT NULL DEFAULT 5 COMMENT 'Alerta de estoque mínimo',
    ds_unidade      VARCHAR(20)     NOT NULL DEFAULT 'UN' COMMENT 'UN, KG, L, M, etc.',
    pc_peso_kg      DECIMAL(8,3)        NULL COMMENT 'Peso em kg para frete',
    pc_altura_cm    DECIMAL(8,2)        NULL,
    pc_largura_cm   DECIMAL(8,2)        NULL,
    pc_profundidade_cm DECIMAL(8,2)     NULL,
    ds_imagem_url   VARCHAR(500)        NULL,
    fl_ativo        TINYINT(1)      NOT NULL DEFAULT 1,
    dt_criacao      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_atualizacao  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_produto       PRIMARY KEY (id_produto),
    CONSTRAINT uq_produto_sku   UNIQUE (cd_sku),
    CONSTRAINT fk_prod_categoria FOREIGN KEY (id_categoria) REFERENCES tb_categoria(id_categoria),
    CONSTRAINT fk_prod_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES tb_fornecedor(id_fornecedor)
) ENGINE=InnoDB COMMENT='Catálogo de produtos';

-- -----------------------------------------------------------------------------
-- TABELA: tb_promocao
-- DESCRIÇÃO: Promoções e descontos aplicáveis a produtos ou pedidos
-- -----------------------------------------------------------------------------
CREATE TABLE tb_promocao (
    id_promocao     INT             NOT NULL AUTO_INCREMENT,
    nm_promocao     VARCHAR(100)    NOT NULL,
    ds_promocao     VARCHAR(255)        NULL,
    tp_desconto     ENUM('PERCENTUAL','VALOR_FIXO') NOT NULL DEFAULT 'PERCENTUAL',
    vl_desconto     DECIMAL(10,2)   NOT NULL COMMENT 'Percentual ou valor fixo de desconto',
    dt_inicio       DATETIME        NOT NULL,
    dt_fim          DATETIME        NOT NULL,
    qt_uso_maximo   INT                 NULL COMMENT 'NULL = sem limite',
    qt_uso_atual    INT             NOT NULL DEFAULT 0,
    vl_pedido_minimo DECIMAL(12,2)      NULL COMMENT 'Valor mínimo do pedido para aplicar',
    fl_ativo        TINYINT(1)      NOT NULL DEFAULT 1,
    dt_criacao      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_promocao      PRIMARY KEY (id_promocao)
) ENGINE=InnoDB COMMENT='Promoções e cupons de desconto';

-- -----------------------------------------------------------------------------
-- TABELA: tb_produto_promocao
-- DESCRIÇÃO: Associação N:N entre produtos e promoções
-- -----------------------------------------------------------------------------
CREATE TABLE tb_produto_promocao (
    id_produto      INT             NOT NULL,
    id_promocao     INT             NOT NULL,
    dt_associacao   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_prod_promo    PRIMARY KEY (id_produto, id_promocao),
    CONSTRAINT fk_pp_produto    FOREIGN KEY (id_produto)   REFERENCES tb_produto(id_produto),
    CONSTRAINT fk_pp_promocao   FOREIGN KEY (id_promocao)  REFERENCES tb_promocao(id_promocao)
) ENGINE=InnoDB COMMENT='Produtos vinculados a promoções';

-- -----------------------------------------------------------------------------
-- TABELA: tb_cliente
-- DESCRIÇÃO: Clientes cadastrados na plataforma
-- -----------------------------------------------------------------------------
CREATE TABLE tb_cliente (
    id_cliente      INT             NOT NULL AUTO_INCREMENT,
    nm_cliente      VARCHAR(100)    NOT NULL,
    ds_email        VARCHAR(100)    NOT NULL,
    ds_senha_hash   VARCHAR(255)    NOT NULL COMMENT 'Hash bcrypt da senha',
    nr_cpf          CHAR(11)            NULL COMMENT 'CPF sem máscara (PF)',
    nr_cnpj         CHAR(14)            NULL COMMENT 'CNPJ sem máscara (PJ)',
    tp_pessoa       ENUM('F','J')   NOT NULL DEFAULT 'F' COMMENT 'F=Física, J=Jurídica',
    dt_nascimento   DATE                NULL,
    nr_telefone     VARCHAR(20)         NULL,
    nr_celular      VARCHAR(20)         NULL,
    fl_ativo        TINYINT(1)      NOT NULL DEFAULT 1,
    fl_email_verificado TINYINT(1)  NOT NULL DEFAULT 0,
    dt_criacao      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_atualizacao  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    dt_ultimo_acesso DATETIME           NULL,
    CONSTRAINT pk_cliente       PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_email UNIQUE (ds_email),
    CONSTRAINT uq_cliente_cpf   UNIQUE (nr_cpf),
    CONSTRAINT uq_cliente_cnpj  UNIQUE (nr_cnpj)
) ENGINE=InnoDB COMMENT='Clientes cadastrados na plataforma';

-- -----------------------------------------------------------------------------
-- TABELA: tb_endereco
-- DESCRIÇÃO: Endereços de entrega e cobrança dos clientes
-- -----------------------------------------------------------------------------
CREATE TABLE tb_endereco (
    id_endereco     INT             NOT NULL AUTO_INCREMENT,
    id_cliente      INT             NOT NULL COMMENT 'FK Cliente',
    nm_destinatario VARCHAR(100)    NOT NULL COMMENT 'Nome p/ entrega',
    tp_endereco     ENUM('ENTREGA','COBRANCA','AMBOS') NOT NULL DEFAULT 'AMBOS',
    ds_rua          VARCHAR(200)    NOT NULL,
    nr_numero       VARCHAR(10)     NOT NULL,
    ds_complemento  VARCHAR(100)        NULL,
    nm_bairro       VARCHAR(100)    NOT NULL,
    nm_cidade       VARCHAR(100)    NOT NULL,
    sg_uf           CHAR(2)         NOT NULL,
    nr_cep          CHAR(8)         NOT NULL COMMENT 'CEP sem máscara',
    nm_pais         VARCHAR(50)     NOT NULL DEFAULT 'Brasil',
    fl_principal    TINYINT(1)      NOT NULL DEFAULT 0 COMMENT 'Endereço padrão',
    fl_ativo        TINYINT(1)      NOT NULL DEFAULT 1,
    dt_criacao      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_endereco      PRIMARY KEY (id_endereco),
    CONSTRAINT fk_end_cliente   FOREIGN KEY (id_cliente) REFERENCES tb_cliente(id_cliente)
) ENGINE=InnoDB COMMENT='Endereços de entrega e cobrança dos clientes';

-- -----------------------------------------------------------------------------
-- TABELA: tb_carrinho
-- DESCRIÇÃO: Carrinho de compras (sessão de compra do cliente)
-- -----------------------------------------------------------------------------
CREATE TABLE tb_carrinho (
    id_carrinho     INT             NOT NULL AUTO_INCREMENT,
    id_cliente      INT             NOT NULL COMMENT 'FK Cliente',
    id_promocao     INT                 NULL COMMENT 'Cupom aplicado',
    dt_criacao      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_atualizacao  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fl_ativo        TINYINT(1)      NOT NULL DEFAULT 1 COMMENT '0=Convertido em pedido ou abandonado',
    CONSTRAINT pk_carrinho      PRIMARY KEY (id_carrinho),
    CONSTRAINT fk_carr_cliente  FOREIGN KEY (id_cliente)  REFERENCES tb_cliente(id_cliente),
    CONSTRAINT fk_carr_promocao FOREIGN KEY (id_promocao) REFERENCES tb_promocao(id_promocao)
) ENGINE=InnoDB COMMENT='Carrinho de compras';

-- -----------------------------------------------------------------------------
-- TABELA: tb_item_carrinho
-- DESCRIÇÃO: Itens dentro do carrinho de compras
-- -----------------------------------------------------------------------------
CREATE TABLE tb_item_carrinho (
    id_item_carrinho INT            NOT NULL AUTO_INCREMENT,
    id_carrinho     INT             NOT NULL,
    id_produto      INT             NOT NULL,
    qt_item         INT             NOT NULL DEFAULT 1,
    vl_unitario     DECIMAL(12,2)   NOT NULL COMMENT 'Preço no momento da adição',
    dt_adicionado   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_item_carrinho PRIMARY KEY (id_item_carrinho),
    CONSTRAINT uq_carr_prod     UNIQUE (id_carrinho, id_produto),
    CONSTRAINT fk_ic_carrinho   FOREIGN KEY (id_carrinho) REFERENCES tb_carrinho(id_carrinho),
    CONSTRAINT fk_ic_produto    FOREIGN KEY (id_produto)  REFERENCES tb_produto(id_produto)
) ENGINE=InnoDB COMMENT='Itens do carrinho de compras';

-- -----------------------------------------------------------------------------
-- TABELA: tb_pedido
-- DESCRIÇÃO: Pedidos realizados pelos clientes
-- -----------------------------------------------------------------------------
CREATE TABLE tb_pedido (
    id_pedido       INT             NOT NULL AUTO_INCREMENT,
    id_cliente      INT             NOT NULL COMMENT 'FK Cliente',
    id_endereco_entrega INT         NOT NULL COMMENT 'FK Endereço de entrega',
    id_endereco_cobranca INT        NOT NULL COMMENT 'FK Endereço de cobrança',
    id_promocao     INT                 NULL COMMENT 'Promoção/cupom aplicado',
    nr_pedido       VARCHAR(20)     NOT NULL COMMENT 'Número legível do pedido (ex: PED-2024-00001)',
    st_pedido       ENUM('AGUARDANDO_PAGAMENTO','PAGO','EM_SEPARACAO','ENVIADO',
                         'ENTREGUE','CANCELADO','DEVOLVIDO')
                                    NOT NULL DEFAULT 'AGUARDANDO_PAGAMENTO',
    vl_subtotal     DECIMAL(12,2)   NOT NULL COMMENT 'Soma dos itens sem descontos',
    vl_desconto     DECIMAL(12,2)   NOT NULL DEFAULT 0.00,
    vl_frete        DECIMAL(12,2)   NOT NULL DEFAULT 0.00,
    vl_total        DECIMAL(12,2)   NOT NULL COMMENT 'Total final do pedido',
    ds_observacao   TEXT                NULL COMMENT 'Observações do cliente',
    dt_pedido       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_atualizacao  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_pedido        PRIMARY KEY (id_pedido),
    CONSTRAINT uq_pedido_nr     UNIQUE (nr_pedido),
    CONSTRAINT fk_ped_cliente   FOREIGN KEY (id_cliente)           REFERENCES tb_cliente(id_cliente),
    CONSTRAINT fk_ped_end_ent   FOREIGN KEY (id_endereco_entrega)  REFERENCES tb_endereco(id_endereco),
    CONSTRAINT fk_ped_end_cob   FOREIGN KEY (id_endereco_cobranca) REFERENCES tb_endereco(id_endereco),
    CONSTRAINT fk_ped_promocao  FOREIGN KEY (id_promocao)          REFERENCES tb_promocao(id_promocao)
) ENGINE=InnoDB COMMENT='Pedidos de compra';

-- -----------------------------------------------------------------------------
-- TABELA: tb_item_pedido
-- DESCRIÇÃO: Itens que compõem cada pedido
-- -----------------------------------------------------------------------------
CREATE TABLE tb_item_pedido (
    id_item_pedido  INT             NOT NULL AUTO_INCREMENT,
    id_pedido       INT             NOT NULL,
    id_produto      INT             NOT NULL,
    nr_sequencia    INT             NOT NULL COMMENT 'Sequência do item no pedido',
    qt_item         INT             NOT NULL,
    vl_unitario     DECIMAL(12,2)   NOT NULL COMMENT 'Preço no momento da compra',
    pc_desconto_item DECIMAL(5,2)   NOT NULL DEFAULT 0.00 COMMENT 'Desconto % aplicado ao item',
    vl_total_item   DECIMAL(12,2)   NOT NULL COMMENT 'qt * vl_unitario * (1 - desconto)',
    CONSTRAINT pk_item_pedido   PRIMARY KEY (id_item_pedido),
    CONSTRAINT fk_ip_pedido     FOREIGN KEY (id_pedido)  REFERENCES tb_pedido(id_pedido),
    CONSTRAINT fk_ip_produto    FOREIGN KEY (id_produto) REFERENCES tb_produto(id_produto)
) ENGINE=InnoDB COMMENT='Itens de cada pedido';

-- -----------------------------------------------------------------------------
-- TABELA: tb_pagamento
-- DESCRIÇÃO: Registros de pagamentos associados a pedidos
-- -----------------------------------------------------------------------------
CREATE TABLE tb_pagamento (
    id_pagamento    INT             NOT NULL AUTO_INCREMENT,
    id_pedido       INT             NOT NULL,
    tp_pagamento    ENUM('CARTAO_CREDITO','CARTAO_DEBITO','PIX','BOLETO','TRANSFERENCIA')
                                    NOT NULL,
    st_pagamento    ENUM('PENDENTE','APROVADO','RECUSADO','ESTORNADO','CANCELADO')
                                    NOT NULL DEFAULT 'PENDENTE',
    vl_pagamento    DECIMAL(12,2)   NOT NULL,
    qt_parcelas     INT             NOT NULL DEFAULT 1,
    ds_transacao_id VARCHAR(100)        NULL COMMENT 'ID da transação na operadora',
    ds_bandeira     VARCHAR(50)         NULL COMMENT 'Visa, Master, etc.',
    nr_cartao_final CHAR(4)             NULL COMMENT 'Últimos 4 dígitos',
    dt_pagamento    DATETIME            NULL COMMENT 'Data de confirmação',
    dt_criacao      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_atualizacao  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_pagamento     PRIMARY KEY (id_pagamento),
    CONSTRAINT fk_pag_pedido    FOREIGN KEY (id_pedido) REFERENCES tb_pedido(id_pedido)
) ENGINE=InnoDB COMMENT='Pagamentos dos pedidos';

-- -----------------------------------------------------------------------------
-- TABELA: tb_frete
-- DESCRIÇÃO: Informações de envio e rastreamento dos pedidos
-- -----------------------------------------------------------------------------
CREATE TABLE tb_frete (
    id_frete        INT             NOT NULL AUTO_INCREMENT,
    id_pedido       INT             NOT NULL,
    nm_transportadora VARCHAR(100)  NOT NULL,
    tp_servico      VARCHAR(50)         NULL COMMENT 'PAC, SEDEX, Expressa, etc.',
    nr_rastreamento VARCHAR(50)         NULL,
    vl_frete        DECIMAL(12,2)   NOT NULL,
    nr_prazo_dias   INT             NOT NULL DEFAULT 7,
    st_frete        ENUM('AGUARDANDO','COLETADO','EM_TRANSITO','SAIU_ENTREGA','ENTREGUE','EXTRAVIADO')
                                    NOT NULL DEFAULT 'AGUARDANDO',
    dt_postagem     DATETIME            NULL,
    dt_previsao     DATE                NULL,
    dt_entrega      DATETIME            NULL COMMENT 'Data efetiva de entrega',
    ds_observacao   VARCHAR(255)        NULL,
    dt_criacao      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_atualizacao  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_frete         PRIMARY KEY (id_frete),
    CONSTRAINT fk_frete_pedido  FOREIGN KEY (id_pedido) REFERENCES tb_pedido(id_pedido)
) ENGINE=InnoDB COMMENT='Informações de envio e rastreamento';

-- -----------------------------------------------------------------------------
-- TABELA: tb_avaliacao
-- DESCRIÇÃO: Avaliações e comentários dos clientes sobre produtos
-- -----------------------------------------------------------------------------
CREATE TABLE tb_avaliacao (
    id_avaliacao    INT             NOT NULL AUTO_INCREMENT,
    id_produto      INT             NOT NULL,
    id_cliente      INT             NOT NULL,
    id_pedido       INT             NOT NULL COMMENT 'Apenas quem comprou pode avaliar',
    nr_nota         TINYINT         NOT NULL COMMENT 'Nota de 1 a 5',
    ds_titulo       VARCHAR(100)        NULL,
    ds_comentario   TEXT                NULL,
    fl_verificado   TINYINT(1)      NOT NULL DEFAULT 0 COMMENT 'Compra verificada',
    fl_aprovado     TINYINT(1)      NOT NULL DEFAULT 0 COMMENT 'Aprovado pela moderação',
    dt_avaliacao    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_avaliacao     PRIMARY KEY (id_avaliacao),
    CONSTRAINT uq_aval_cliente_prod UNIQUE (id_produto, id_cliente, id_pedido),
    CONSTRAINT fk_aval_produto  FOREIGN KEY (id_produto) REFERENCES tb_produto(id_produto),
    CONSTRAINT fk_aval_cliente  FOREIGN KEY (id_cliente) REFERENCES tb_cliente(id_cliente),
    CONSTRAINT fk_aval_pedido   FOREIGN KEY (id_pedido)  REFERENCES tb_pedido(id_pedido),
    CONSTRAINT ck_nota          CHECK (nr_nota BETWEEN 1 AND 5)
) ENGINE=InnoDB COMMENT='Avaliações dos clientes sobre produtos';

-- =============================================================================
-- 3. ÍNDICES ADICIONAIS
-- =============================================================================
CREATE INDEX idx_produto_categoria ON tb_produto(id_categoria);
CREATE INDEX idx_produto_sku       ON tb_produto(cd_sku);
CREATE INDEX idx_produto_barras    ON tb_produto(cd_barras);
CREATE INDEX idx_pedido_cliente    ON tb_pedido(id_cliente);
CREATE INDEX idx_pedido_status     ON tb_pedido(st_pedido);
CREATE INDEX idx_pedido_dt         ON tb_pedido(dt_pedido);
CREATE INDEX idx_pagamento_status  ON tb_pagamento(st_pagamento);
CREATE INDEX idx_frete_rastreamento ON tb_frete(nr_rastreamento);
CREATE INDEX idx_cliente_email     ON tb_cliente(ds_email);

-- =============================================================================
-- 4. CARGA DE DADOS DE TESTE
-- =============================================================================

-- Categorias
INSERT INTO tb_categoria (nm_categoria, ds_categoria, id_categoria_pai) VALUES
('Eletrônicos',         'Produtos eletrônicos em geral',       NULL),
('Smartphones',         'Celulares e acessórios',              1),
('Notebooks',           'Notebooks e laptops',                 1),
('Periféricos',         'Mouse, teclado, headset etc.',        1),
('Roupas',              'Vestuário masculino e feminino',      NULL),
('Masculino',           'Roupas masculinas',                   5),
('Feminino',            'Roupas femininas',                    5),
('Casa e Jardim',       'Itens para casa e jardim',            NULL),
('Móveis',              'Móveis para casa',                    8),
('Eletrodomésticos',    'Aparelhos domésticos',                8);

-- Fornecedores
INSERT INTO tb_fornecedor (nm_fornecedor, nm_fantasia, nr_cnpj, nr_ie, ds_email, nr_telefone, nm_contato, ds_rua, nr_numero, nm_cidade, sg_uf, nr_cep) VALUES
('Samsung Electronics Brasil Ltda', 'Samsung',        '02877056000100', '111222333', 'contato@samsung.com.br',    '1130304000', 'Carlos Lima',   'Av. Paulista',     '1000', 'São Paulo',     'SP', '01310100'),
('Apple Inc Representações',        'Apple',          '09168534000169', '222333444', 'contato@apple.com.br',      '1133005000', 'Ana Torres',    'Rua Oscar Freire', '500',  'São Paulo',     'SP', '01426001'),
('Positivo Informática SA',         'Positivo',       '39635006000126', '333444555', 'contato@positivo.com.br',   '4133498000', 'Pedro Alves',   'Rua Senador Sá',   '200',  'Curitiba',      'PR', '80220100'),
('Renner SA',                       'Lojas Renner',   '92754738001304', '096037220', 'contato@renner.com.br',     '5130003000', 'Marcia Souza',  'Av. Assis Brasil', '1010', 'Porto Alegre',  'RS', '91010000'),
('Magazine Luiza SA',               'Magalu',         '47960950000121', '444555666', 'contato@magazineluiza.com', '1933718000', 'Roberto Cruz',  'Rua Voluntários',  '300',  'Franca',        'SP', '14400690');

-- Produtos
INSERT INTO tb_produto (id_categoria, id_fornecedor, cd_sku, cd_barras, nm_produto, ds_produto, vl_custo, vl_preco, qt_estoque, ds_unidade, pc_peso_kg) VALUES
(2, 1, 'SAM-A54-128-PT',  '7891234560001', 'Samsung Galaxy A54 128GB Preto',     'Smartphone Samsung Galaxy A54 128GB Preto, câmera 50MP, tela 6.4"',     1200.00, 1899.90, 50, 'UN', 0.202),
(2, 2, 'APL-IP15-256-BL', '7891234560002', 'iPhone 15 256GB Azul',               'iPhone 15 256GB Azul, chip A16 Bionic, tela Super Retina 6.1"',         4500.00, 6999.00, 30, 'UN', 0.171),
(3, 3, 'POS-MB-I5-16-512','7891234560003', 'Notebook Positivo Motion i5 16GB',   'Notebook Positivo Motion Pro Intel i5 16GB RAM 512GB SSD Windows 11',   1800.00, 2799.90, 20, 'UN', 1.850),
(3, 2, 'APL-MBP-M3-14',   '7891234560004', 'MacBook Pro M3 14" 512GB',           'MacBook Pro 14" chip M3, 8GB RAM 512GB SSD, tela Liquid Retina XDR',   8000.00,12999.00, 10, 'UN', 1.555),
(4, 1, 'SAM-MO-PRO-PTZ',  '7891234560005', 'Mouse Samsung Pro Wireless Preto',   'Mouse sem fio Samsung Pro, 1600 DPI, bateria 12 meses, ambidestro',       80.00,  149.90,100, 'UN', 0.095),
(6, 4, 'REN-CAM-M-AZL',   '7891234560006', 'Camiseta Renner Slim Fit Azul M',    'Camiseta masculina Slim Fit 100% algodão azul tamanho M',                 30.00,   79.90,200, 'UN', 0.200),
(7, 4, 'REN-VES-F-P-PRT',  '7891234560007', 'Vestido Renner Floral Preto P',     'Vestido feminino estampa floral, tecido crepe, tamanho P',                45.00,  119.90,150, 'UN', 0.280),
(9, 5, 'MAG-SOF-3LUG-CZ', '7891234560008', 'Sofá 3 Lugares Cinza Magalu',        'Sofá 3 lugares em tecido suede cinza, pés em madeira, estrutura MDF',   600.00, 1299.00, 15, 'UN', 35.000),
(10,5, 'MAG-GEL-FROST-DUP','7891234560009','Geladeira Frost Free Duplex 410L',   'Geladeira Frost Free Duplex 410L, degelo automático, painel eletrônico',1200.00, 2499.00, 25, 'UN', 62.000),
(4, 3, 'POS-TEC-MECA-PT', '7891234560010', 'Teclado Mecânico Positivo Gaming',   'Teclado mecânico gaming, switches blue, RGB, ABNT2, cabo USB trançado',  120.00,  249.90, 80, 'UN', 0.920);

-- Promoções
INSERT INTO tb_promocao (nm_promocao, ds_promocao, tp_desconto, vl_desconto, dt_inicio, dt_fim, qt_uso_maximo, vl_pedido_minimo) VALUES
('Black Friday 2024',  'Desconto especial Black Friday em produtos selecionados', 'PERCENTUAL', 20.00, '2024-11-29 00:00:00', '2024-11-29 23:59:59', 500,  NULL),
('Frete Grátis 299',   'Frete grátis para compras acima de R$ 299',              'VALOR_FIXO',  0.00, '2024-01-01 00:00:00', '2024-12-31 23:59:59', NULL, 299.00),
('Cupom PRIMEIRACOMPRA','10% de desconto para novos clientes',                   'PERCENTUAL', 10.00, '2024-01-01 00:00:00', '2024-12-31 23:59:59', 1000, NULL),
('Liquidação Eletrônicos','15% off em toda linha de eletrônicos',                'PERCENTUAL', 15.00, '2024-10-01 00:00:00', '2024-10-31 23:59:59',  200, 500.00);

-- Produto x Promoção
INSERT INTO tb_produto_promocao (id_produto, id_promocao) VALUES
(1, 1),(2, 1),(3, 1),(4, 1),(5, 1),
(1, 4),(2, 4),(3, 4),(4, 4),(5, 4),(10, 4);

-- Clientes
INSERT INTO tb_cliente (nm_cliente, ds_email, ds_senha_hash, nr_cpf, tp_pessoa, dt_nascimento, nr_celular) VALUES
('Ana Paula Ferreira',    'ana.ferreira@email.com',   '$2b$12$xhash001', '12345678901', 'F', '1990-03-15', '11987650001'),
('Bruno Costa Silva',     'bruno.silva@email.com',    '$2b$12$xhash002', '23456789012', 'F', '1985-07-22', '21987650002'),
('Carla Mendes Ribeiro',  'carla.ribeiro@email.com',  '$2b$12$xhash003', '34567890123', 'F', '1995-11-08', '31987650003'),
('Daniel Souza Lima',     'daniel.lima@email.com',    '$2b$12$xhash004', '45678901234', 'F', '1988-01-30', '41987650004'),
('Eduardo Alves Neto',    'eduardo.neto@email.com',   '$2b$12$xhash005', '56789012345', 'F', '1992-06-12', '51987650005'),
('Fernanda Gomes Costa',  'fernanda.costa@email.com', '$2b$12$xhash006', '67890123456', 'F', '1987-09-25', '61987650006'),
('Gabriel Santos Filho',  'gabriel.filho@email.com',  '$2b$12$xhash007', '78901234567', 'F', '1993-04-17', '71987650007'),
('Helena Martins Cruz',   'helena.cruz@email.com',    '$2b$12$xhash008', '89012345678', 'F', '1996-12-03', '81987650008');

-- Endereços
INSERT INTO tb_endereco (id_cliente, nm_destinatario, tp_endereco, ds_rua, nr_numero, nm_bairro, nm_cidade, sg_uf, nr_cep, fl_principal) VALUES
(1, 'Ana Paula Ferreira',   'AMBOS', 'Rua das Flores',      '100', 'Jardim América', 'São Paulo',      'SP', '01430001', 1),
(2, 'Bruno Costa Silva',    'AMBOS', 'Av. Atlântica',       '200', 'Copacabana',     'Rio de Janeiro', 'RJ', '22070011', 1),
(3, 'Carla Mendes Ribeiro', 'AMBOS', 'Rua XV de Novembro',  '300', 'Centro',         'Curitiba',       'PR', '80020310', 1),
(4, 'Daniel Souza Lima',    'AMBOS', 'Av. Afonso Pena',     '400', 'Centro',         'Belo Horizonte', 'MG', '30130921', 1),
(5, 'Eduardo Alves Neto',   'AMBOS', 'Rua Boa Viagem',      '500', 'Boa Viagem',     'Recife',         'PE', '51011000', 1),
(6, 'Fernanda Gomes Costa', 'AMBOS', 'Rua Chile',           '600', 'Centro',         'Salvador',       'BA', '40020240', 1),
(7, 'Gabriel Santos Filho', 'AMBOS', 'Av. Beira Mar',       '700', 'Meireles',       'Fortaleza',      'CE', '60165121', 1),
(8, 'Helena Martins Cruz',  'AMBOS', 'Rua dos Andradas',    '800', 'Centro',         'Porto Alegre',   'RS', '90020005', 1);

-- Carrinhos
INSERT INTO tb_carrinho (id_cliente, id_promocao, fl_ativo) VALUES
(1, NULL, 0), (2, 3, 0), (3, NULL, 0), (4, 1, 0),
(5, NULL, 0), (6, NULL, 1), (7, NULL, 1), (8, NULL, 0);

-- Pedidos
INSERT INTO tb_pedido (id_cliente, id_endereco_entrega, id_endereco_cobranca, id_promocao, nr_pedido, st_pedido, vl_subtotal, vl_desconto, vl_frete, vl_total, dt_pedido) VALUES
(1, 1, 1, NULL, 'PED-2024-00001', 'ENTREGUE',             1899.90,    0.00,  19.90, 1919.80, '2024-09-10 10:30:00'),
(2, 2, 2,    3, 'PED-2024-00002', 'ENTREGUE',             6999.00,  699.90,   0.00, 6299.10, '2024-09-15 14:20:00'),
(3, 3, 3, NULL, 'PED-2024-00003', 'ENTREGUE',             2799.90,    0.00,  25.00, 2824.90, '2024-10-01 09:00:00'),
(4, 4, 4,    1, 'PED-2024-00004', 'ENVIADO',             12999.00, 2599.80,   0.00,10399.20, '2024-11-29 08:15:00'),
(5, 5, 5, NULL, 'PED-2024-00005', 'PAGO',                  199.80,    0.00,  15.00,  214.80, '2024-11-29 11:45:00'),
(6, 6, 6, NULL, 'PED-2024-00006', 'EM_SEPARACAO',         1299.00,    0.00,  45.00, 1344.00, '2024-11-30 16:00:00'),
(7, 7, 7, NULL, 'PED-2024-00007', 'AGUARDANDO_PAGAMENTO', 2499.00,    0.00,  35.00, 2534.00, '2024-12-01 13:30:00'),
(8, 8, 8, NULL, 'PED-2024-00008', 'ENTREGUE',               79.90,    0.00,  10.00,   89.90, '2024-12-02 10:00:00'),
(1, 1, 1,    4, 'PED-2024-00009', 'ENTREGUE',              149.90,   22.49,   0.00,  127.41, '2024-10-15 09:30:00'),
(2, 2, 2, NULL, 'PED-2024-00010', 'CANCELADO',             249.90,    0.00,  12.00,  261.90, '2024-10-20 15:00:00');

-- Itens dos Pedidos
INSERT INTO tb_item_pedido (id_pedido, id_produto, nr_sequencia, qt_item, vl_unitario, pc_desconto_item, vl_total_item) VALUES
(1,  1, 1, 1, 1899.90,  0.00, 1899.90),
(2,  2, 1, 1, 6999.00, 10.00, 6299.10),
(3,  3, 1, 1, 2799.90,  0.00, 2799.90),
(4,  4, 1, 1,12999.00, 20.00,10399.20),
(5,  5, 1, 1,  149.90,  0.00,  149.90),
(5,  6, 2, 1,   79.90,  0.00,   79.90),  -- 2 itens no mesmo pedido
(6,  8, 1, 1, 1299.00,  0.00, 1299.00),
(7,  9, 1, 1, 2499.00,  0.00, 2499.00),
(8,  6, 1, 1,   79.90,  0.00,   79.90),
(9,  5, 1, 1,  149.90, 15.00,  127.41),
(10,10, 1, 1,  249.90,  0.00,  249.90);

-- Pagamentos
INSERT INTO tb_pagamento (id_pedido, tp_pagamento, st_pagamento, vl_pagamento, qt_parcelas, ds_bandeira, nr_cartao_final, dt_pagamento) VALUES
(1, 'CARTAO_CREDITO', 'APROVADO',  1919.80, 3, 'Visa',       '4321', '2024-09-10 10:31:00'),
(2, 'PIX',            'APROVADO',  6299.10, 1,  NULL,          NULL, '2024-09-15 14:22:00'),
(3, 'CARTAO_DEBITO',  'APROVADO',  2824.90, 1, 'Mastercard', '8765', '2024-10-01 09:02:00'),
(4, 'CARTAO_CREDITO', 'APROVADO', 10399.20,12, 'Visa',       '1234', '2024-11-29 08:16:00'),
(5, 'PIX',            'APROVADO',   214.80, 1,  NULL,          NULL, '2024-11-29 11:46:00'),
(6, 'BOLETO',         'APROVADO',  1344.00, 1,  NULL,          NULL, '2024-12-02 10:00:00'),
(7, 'CARTAO_CREDITO', 'PENDENTE',  2534.00, 6, 'Elo',        '5678',  NULL),
(8, 'PIX',            'APROVADO',    89.90, 1,  NULL,          NULL, '2024-12-02 10:01:00'),
(9, 'CARTAO_CREDITO', 'APROVADO',   127.41, 1, 'Mastercard', '9999', '2024-10-15 09:31:00'),
(10,'BOLETO',         'CANCELADO',  261.90, 1,  NULL,          NULL,  NULL);

-- Fretes
INSERT INTO tb_frete (id_pedido, nm_transportadora, tp_servico, nr_rastreamento, vl_frete, nr_prazo_dias, st_frete, dt_postagem, dt_previsao, dt_entrega) VALUES
(1, 'Correios', 'PAC',   'BR123456789BR', 19.90,  8, 'ENTREGUE',  '2024-09-11', '2024-09-19', '2024-09-18 14:30:00'),
(2, 'Correios', 'SEDEX',  NULL,            0.00,  1, 'ENTREGUE',  '2024-09-16', '2024-09-17', '2024-09-17 10:00:00'),
(3, 'Jadlog',  'Package','JD987654321BR', 25.00,  5, 'ENTREGUE',  '2024-10-02', '2024-10-07', '2024-10-06 16:00:00'),
(4, 'Correios', 'SEDEX', 'BR234567890BR',  0.00,  3, 'EM_TRANSITO','2024-11-30', '2024-12-03',  NULL),
(5, 'Correios', 'PAC',   'BR345678901BR', 15.00,  7, 'COLETADO',  '2024-11-30', '2024-12-06',  NULL),
(6, 'Transportadora TotalExpress', 'Expresso', NULL, 45.00, 3, 'EM_SEPARACAO', NULL, '2024-12-04', NULL),
(7, 'Correios', 'PAC',    NULL,           35.00,  8, 'AGUARDANDO',  NULL, '2024-12-10',  NULL),
(8, 'Correios', 'PAC',   'BR456789012BR', 10.00,  5, 'ENTREGUE',  '2024-12-03', '2024-12-07', '2024-12-07 09:30:00'),
(9, 'Correios', 'SEDEX',  NULL,            0.00,  1, 'ENTREGUE',  '2024-10-16', '2024-10-17', '2024-10-17 11:00:00');

-- Avaliações
INSERT INTO tb_avaliacao (id_produto, id_cliente, id_pedido, nr_nota, ds_titulo, ds_comentario, fl_verificado, fl_aprovado) VALUES
(1, 1, 1, 5, 'Excelente produto!',   'Chegou rápido, embalagem perfeita, produto exatamente como descrito. Recomendo!', 1, 1),
(2, 2, 2, 4, 'Ótimo celular',         'Produto incrível, câmera fantástica. Tirei 1 estrela pelo preço elevado.',        1, 1),
(3, 3, 3, 5, 'Notebook perfeito',    'Rápido, leve e com ótima bateria. Melhor compra que fiz!',                        1, 1),
(6, 8, 8, 3, 'Camiseta ok',           'Tecido bom mas o tamanho M veio um pouco largo. Qualidade razoável pelo preço.',  1, 1),
(5, 1, 9, 5, 'Mouse ótimo!',          'Conexão perfeita, cursor preciso, bateria durou mais de 6 meses!',                1, 1);

-- =============================================================================
-- FIM DO SCRIPT
-- =============================================================================
SELECT 'Banco de dados db_ecommerce criado e populado com sucesso!' AS STATUS;
