# Trabalho Final da Disciplina de Banco de Dados - 2025/2
# Sistema Corporativo de Gestão para uma Rede de Lojas de Moda

# Ana Beatriz Gualti Scalabrini 
# Andressa Ginevro de Souza 
# Bianca Kimi Kodono Takahashi 
# Isabella Mariana Cardoso Pinto

# PARTE 1 - Criar Tabelas
CREATE database LOJAS_RENDER;
USE lojas_render;

# 1
CREATE TABLE Regiao (
    id_regiao INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

# 2
CREATE TABLE Tipo_Insumo (
    id_tipo_insumo INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

# 3
CREATE TABLE Cargo (
    id_cargo INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    nivel INT NOT NULL
);

# 4
CREATE TABLE Colecao (
    id_colecao INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    status VARCHAR(20) NOT NULL
);

# 5
CREATE TABLE Desconto (
    id_desconto INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) NOT NULL,           
    valor DECIMAL(10,2) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    qtd INT,
    status VARCHAR(20) NOT NULL
);

# 6
CREATE TABLE Filial (
    id_filial INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(100),
    estado CHAR(2),
    data_abertura DATE,
    id_gerente INT,
    id_regiao INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_regiao) REFERENCES Regiao(id_regiao)
);

# 7
CREATE TABLE Funcionario (
    id_funcionario INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    salario DECIMAL(12,2) NOT NULL,
    data_contratacao DATE NOT NULL,
    id_filial INT,
    id_cargo INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_filial) REFERENCES Filial(id_filial),
    FOREIGN KEY (id_cargo) REFERENCES Cargo(id_cargo)
);

# Foi criado essa FK depois de criar a tabela Funcionario, pois as 2 tabelas possuem dependência entre si
ALTER TABLE Filial
ADD CONSTRAINT fk_filial_gerente
FOREIGN KEY (id_gerente) REFERENCES Funcionario(id_funcionario);

# Produtos e Estoque
# 8
CREATE TABLE Produto (
    id_produto INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(50),
    cor VARCHAR(50),
    tamanho VARCHAR(10),
    preco DECIMAL(10,2) NOT NULL,
    id_colecao INT,
    status VARCHAR(20),
    FOREIGN KEY (id_colecao) REFERENCES Colecao(id_colecao)
);

# 9
CREATE TABLE Estoque (
    id_filial INT,
    id_produto INT,
    quantidade INT NOT NULL,
    PRIMARY KEY (id_filial, id_produto),
    FOREIGN KEY (id_filial) REFERENCES Filial(id_filial),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

# 10
# Clientes e Vendas
CREATE TABLE Cliente (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    data_cadastro DATE NOT NULL,
    sexo CHAR(1),
    data_nascimento DATE,
    cpf CHAR(11)
);

# 11
CREATE TABLE Venda (
    id_venda INT PRIMARY KEY,
    id_filial INT NOT NULL,
    id_funcionario INT NOT NULL,
    id_cliente INT NOT NULL,
    id_desconto INT,
    data_venda DATE NOT NULL,
    valor_total DECIMAL(12,2) NOT NULL,
    valor_desconto DECIMAL(12,2) NOT NULL,
    tipo_pagamento VARCHAR(50),
    FOREIGN KEY (id_filial) REFERENCES Filial(id_filial),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_desconto) REFERENCES Desconto(id_desconto)
);

# 12
CREATE TABLE Item_Venda (
    id_venda INT,
    id_produto INT,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    preco_total DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id_venda, id_produto),
    FOREIGN KEY (id_venda) REFERENCES Venda(id_venda),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

# 13
# Fornecedores e Compras
CREATE TABLE Fornecedor (
    id_fornecedor INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(100),
    estado CHAR(2),
    id_tipo_insumo INT NOT NULL,
    cnpj CHAR(14),
    FOREIGN KEY (id_tipo_insumo) REFERENCES Tipo_Insumo(id_tipo_insumo)
);

# 14
CREATE TABLE Compra (
    id_compra INT PRIMARY KEY,
    id_fornecedor INT NOT NULL,
    id_filial INT NOT NULL,
    data_compra DATE NOT NULL,
    valor_total DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor(id_fornecedor),
    FOREIGN KEY (id_filial) REFERENCES Filial(id_filial)
);

# 15
CREATE TABLE Item_Compra (
    id_compra INT,
    id_produto INT,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    preco_total DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id_compra, id_produto),
    FOREIGN KEY (id_compra) REFERENCES Compra(id_compra),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

# Metas e Comissionamento
# 16
CREATE TABLE Meta_Venda (
    id_meta INT PRIMARY KEY,
    id_filial INT NOT NULL,
    ano INT NOT NULL,
    mes INT NOT NULL,
    valor_meta DECIMAL(12,2) NOT NULL,
    id_cargo INT NOT NULL,
    FOREIGN KEY (id_filial) REFERENCES Filial(id_filial),
    FOREIGN KEY (id_cargo) REFERENCES Cargo(id_cargo)
);

# 17
CREATE TABLE Comissionamento (
    id_comissionamento INT PRIMARY KEY,
    id_funcionario INT NOT NULL,
    id_meta INT NOT NULL,
    atingimento_meta DECIMAL(5,2) NOT NULL,
    tipo_comissao VARCHAR(20) NOT NULL, 
    valor DECIMAL(12,2) NOT NULL,
    valor_final DECIMAL(12,2) NOT NULL,
    data_meta_batida DATE,
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_meta) REFERENCES Meta_Venda(id_meta)
);

# Triggers
DELIMITER $$

CREATE TRIGGER trg_entrada_estoque
AFTER INSERT ON Item_Compra
FOR EACH ROW
BEGIN
    DECLARE v_filial INT;

    SELECT id_filial INTO v_filial 
    FROM Compra 
    WHERE id_compra = NEW.id_compra;
    
    IF EXISTS (SELECT 1 FROM Estoque WHERE id_filial = v_filial AND id_produto = NEW.id_produto) THEN
        UPDATE Estoque
        SET quantidade = quantidade + NEW.quantidade
        WHERE id_filial = v_filial AND id_produto = NEW.id_produto;
    ELSE
        INSERT INTO Estoque (id_filial, id_produto, quantidade)
        VALUES (v_filial, NEW.id_produto, NEW.quantidade);
    END IF;

END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_saida_estoque
AFTER INSERT ON Item_Venda
FOR EACH ROW
BEGIN
    DECLARE v_filial INT;

    SELECT id_filial INTO v_filial 
    FROM Venda 
    WHERE id_venda = NEW.id_venda;

    UPDATE Estoque
    SET quantidade = quantidade - NEW.quantidade
    WHERE id_filial = v_filial AND id_produto = NEW.id_produto;

END $$

DELIMITER ;


# PARTE 2 - Inserir Dados

USE lojas_render;

# 1. Inserindo Regiões (Independente)
INSERT INTO Regiao (id_regiao, nome) VALUES
(1, 'Sudeste'), (2, 'Sul'), (3, 'Centro-Oeste'), (4, 'Nordeste'), (5, 'Norte'),
(6, 'Grande São Paulo'), (7, 'Interior SP'), (8, 'Litoral SP'), (9, 'Serra Gaúcha'), (10, 'Vale do Paraíba');

# 2. Inserindo Tipos de Insumo (Independente)
INSERT INTO Tipo_Insumo (id_tipo_insumo, nome) VALUES
(1, 'Tecido Algodão'), (2, 'Tecido Poliéster'), (3, 'Tecido Seda'), (4, 'Couro'), (5, 'Botões'),
(6, 'Zíperes'), (7, 'Linhas'), (8, 'Velcro'), (9, 'Elástico'), (10, 'Embalagens');

# 3. Inserindo Cargos (Independente)
INSERT INTO Cargo (id_cargo, nome, nivel) VALUES
(1, 'Vendedor Júnior', 1), (2, 'Vendedor Pleno', 2), (3, 'Vendedor Sênior', 3),
(4, 'Gerente de Loja', 4), (5, 'Supervisor Regional', 5), (6, 'Caixa', 1),
(7, 'Estoquista', 1), (8, 'Visual Merchandiser', 3), (9, 'Assistente Administrativo', 2), (10, 'Auxiliar de Limpeza', 1);

# 4. Inserindo Coleções (Independente)
INSERT INTO Colecao (id_colecao, nome, data_inicio, data_fim, status) VALUES
(1, 'Verão 2024', '2024-01-01', '2024-03-31', 'Inativa'),
(2, 'Outono 2024', '2024-04-01', '2024-06-30', 'Inativa'),
(3, 'Inverno 2024', '2024-07-01', '2024-09-30', 'Inativa'),
(4, 'Primavera 2024', '2024-10-01', '2024-12-31', 'Ativa'),
(5, 'Alto Verão 2025', '2025-01-01', NULL, 'Planejamento'),
(6, 'Coleção Cápsula Jeans', '2024-05-01', NULL, 'Ativa'),
(7, 'Linha Basic', '2023-01-01', NULL, 'Ativa'),
(8, 'Moda Festa', '2023-06-01', NULL, 'Ativa'),
(9, 'Black Friday Ed.', '2024-11-01', '2024-11-30', 'Ativa'),
(10, 'Ano Novo', '2024-12-01', '2025-01-05', 'Planejamento');

# 5. Inserindo Descontos (Independente)
INSERT INTO Desconto (id_desconto, nome, tipo, valor, data_inicio, data_fim, qtd, status) VALUES
(1, 'Sem Desconto', 'Nenhum', 0.00, '2000-01-01', NULL, NULL, 'Ativo'),
(2, 'Cliente Novo', 'Porcentagem', 10.00, '2024-01-01', NULL, 1000, 'Ativo'),
(3, 'Queima de Estoque', 'Porcentagem', 50.00, '2024-02-01', '2024-02-15', 500, 'Inativo'),
(4, 'Cupom 20REAIS', 'Valor Fixo', 20.00, '2024-01-01', '2024-12-31', 200, 'Ativo'),
(5, 'Dia das Mães', 'Porcentagem', 15.00, '2024-05-01', '2024-05-15', NULL, 'Inativo'),
(6, 'Black Friday', 'Porcentagem', 40.00, '2024-11-25', '2024-11-30', NULL, 'Ativo'),
(7, 'Aniversariante', 'Porcentagem', 20.00, '2024-01-01', NULL, NULL, 'Ativo'),
(8, 'Funcionário', 'Porcentagem', 30.00, '2023-01-01', NULL, NULL, 'Ativo'),
(9, 'Peça com Defeito', 'Porcentagem', 60.00, '2023-01-01', NULL, NULL, 'Ativo'),
(10, 'Fidelidade', 'Valor Fixo', 50.00, '2024-01-01', NULL, 100, 'Ativo');

# 6. Inserindo Clientes (Independente)
INSERT INTO Cliente (id_cliente, nome, email, data_cadastro, sexo, data_nascimento, cpf) VALUES
(1, 'Ana Silva', 'ana@email.com', '2023-01-15', 'F', '1990-05-20', '12345678901'),
(2, 'Carlos Souza', 'carlos@email.com', '2023-02-10', 'M', '1985-08-15', '23456789012'),
(3, 'Beatriz Oliveira', 'bia@email.com', '2023-03-05', 'F', '1995-12-10', '34567890123'),
(4, 'João Pereira', 'joao@email.com', '2023-04-20', 'M', '1980-03-25', '45678901234'),
(5, 'Fernanda Costa', 'nanda@email.com', '2023-05-12', 'F', '2000-07-30', '56789012345'),
(6, 'Ricardo Lima', 'rick@email.com', '2023-06-18', 'M', '1992-11-05', '67890123456'),
(7, 'Juliana Santos', 'juju@email.com', '2023-07-22', 'F', '1988-09-14', '78901234567'),
(8, 'Lucas Martins', 'lucas@email.com', '2023-08-30', 'M', '1999-02-28', '89012345678'),
(9, 'Mariana Rocha', 'mari@email.com', '2023-09-14', 'F', '1993-06-12', '90123456789'),
(10, 'Gabriel Alves', 'gabi@email.com', '2023-10-05', 'M', '1997-04-18', '01234567890');

# 7. Inserindo Filiais (Sem gerente inicialmente para evitar erro de FK)
INSERT INTO Filial (id_filial, nome, cidade, estado, data_abertura, id_gerente, id_regiao, status) VALUES
(1, 'Matriz SP', 'São Paulo', 'SP', '2010-01-01', NULL, 1, 'Ativa'),
(2, 'Filial Rio', 'Rio de Janeiro', 'RJ', '2012-05-15', NULL, 1, 'Ativa'),
(3, 'Filial Sul', 'Porto Alegre', 'RS', '2014-08-20', NULL, 2, 'Ativa'),
(4, 'Filial Bahia', 'Salvador', 'BA', '2015-11-10', NULL, 4, 'Ativa'),
(5, 'Filial Centro', 'Brasília', 'DF', '2016-03-05', NULL, 3, 'Ativa'),
(6, 'Filial Minas', 'Belo Horizonte', 'MG', '2017-09-12', NULL, 1, 'Ativa'),
(7, 'Filial Norte', 'Manaus', 'AM', '2018-02-28', NULL, 5, 'Ativa'),
(8, 'Outlet SP', 'São Roque', 'SP', '2019-06-15', NULL, 7, 'Ativa'),
(9, 'Filial Curitiba', 'Curitiba', 'PR', '2020-01-20', NULL, 2, 'Ativa'),
(10, 'Filial Recife', 'Recife', 'PE', '2021-10-10', NULL, 4, 'Ativa');

# 8. Inserindo Funcionários (Agora que Filial existe)
INSERT INTO Funcionario (id_funcionario, nome, salario, data_contratacao, id_filial, id_cargo, status) VALUES
(1, 'Roberto Gerente', 8000.00, '2010-01-01', 1, 4, 'Ativo'), 
(2, 'Lucia Vendedora', 2500.00, '2020-05-15', 1, 1, 'Ativo'),
(3, 'Marcos Gerente RJ', 7500.00, '2012-05-15', 2, 4, 'Ativo'),
(4, 'Julia Vendedora', 2800.00, '2019-02-20', 2, 2, 'Ativo'),
(5, 'Pedro Gerente Sul', 7000.00, '2014-08-20', 3, 4, 'Ativo'),
(6, 'Amanda Caixa', 2200.00, '2021-01-10', 3, 6, 'Ativo'),
(7, 'Sandro Estoque', 2000.00, '2022-03-15', 4, 7, 'Ativo'),
(8, 'Patricia Gerente BA', 7200.00, '2015-11-10', 4, 4, 'Ativo'),
(9, 'Bruno Gerente DF', 7300.00, '2016-03-05', 5, 4, 'Ativo'),
(10, 'Carla Vendedora', 3000.00, '2018-07-01', 5, 3, 'Ativo');

-- ATUALIZANDO AS FILIAIS COM OS GERENTES CRIADOS
UPDATE Filial SET id_gerente = 1 WHERE id_filial = 1;
UPDATE Filial SET id_gerente = 3 WHERE id_filial = 2;
UPDATE Filial SET id_gerente = 5 WHERE id_filial = 3;
UPDATE Filial SET id_gerente = 8 WHERE id_filial = 4;
UPDATE Filial SET id_gerente = 9 WHERE id_filial = 5;

# 9. Inserindo Produtos
INSERT INTO Produto (id_produto, nome, tipo, cor, tamanho, preco, id_colecao, status) VALUES
(1, 'Camiseta Básica', 'Camiseta', 'Branca', 'M', 49.90, 7, 'Ativo'),
(2, 'Calça Jeans Skinny', 'Calça', 'Azul', '38', 129.90, 6, 'Ativo'),
(3, 'Vestido Florido', 'Vestido', 'Vermelho', 'P', 159.90, 1, 'Ativo'),
(4, 'Jaqueta Couro', 'Jaqueta', 'Preta', 'G', 299.90, 3, 'Ativo'),
(5, 'Shorts Praia', 'Shorts', 'Estampado', 'M', 69.90, 1, 'Ativo'),
(6, 'Blusa Tricô', 'Blusa', 'Bege', 'M', 89.90, 3, 'Ativo'),
(7, 'Saia Longa', 'Saia', 'Verde', 'P', 99.90, 4, 'Ativo'),
(8, 'Camisa Social', 'Camisa', 'Azul Claro', 'G', 119.90, 7, 'Ativo'),
(9, 'Blazer', 'Casaco', 'Preto', 'M', 250.00, 7, 'Ativo'),
(10, 'Calça Moletom', 'Calça', 'Cinza', 'GG', 79.90, 2, 'Ativo');

# 10. Inserindo Estoque (Filial x Produto)
INSERT INTO Estoque (id_filial, id_produto, quantidade) VALUES
(1, 1, 100), (1, 2, 50), (1, 3, 30),
(2, 1, 80), (2, 2, 40), (2, 4, 20),
(3, 5, 60), (3, 6, 25), (3, 7, 35),
(4, 1, 150);

# 11. Inserindo Fornecedores
INSERT INTO Fornecedor (id_fornecedor, nome, cidade, estado, id_tipo_insumo, cnpj) VALUES
(1, 'Têxtil São Jorge', 'Americana', 'SP', 1, '12345678000101'),
(2, 'Couros do Sul', 'Novo Hamburgo', 'RS', 4, '23456789000102'),
(3, 'Botões e Cia', 'São Paulo', 'SP', 5, '34567890000103'),
(4, 'Importadora Silk', 'Itajaí', 'SC', 3, '45678901000104'),
(5, 'Zíper Fast', 'Guarulhos', 'SP', 6, '56789012000105'),
(6, 'Embalagens BR', 'Campinas', 'SP', 10, '67890123000106'),
(7, 'Fios de Ouro', 'Fortaleza', 'CE', 7, '78901234000107'),
(8, 'Tecidos Premium', 'Blumenau', 'SC', 2, '89012345000108'),
(9, 'Aviamentos Total', 'São Paulo', 'SP', 9, '90123456000109'),
(10, 'Velcro Industrial', 'Manaus', 'AM', 8, '01234567000110');

# 12. Inserindo Compras
INSERT INTO Compra (id_compra, id_fornecedor, id_filial, data_compra, valor_total) VALUES
(1, 1, 1, '2024-01-10', 5000.00),
(2, 2, 1, '2024-01-15', 8000.00),
(3, 3, 2, '2024-02-05', 1000.00),
(4, 4, 2, '2024-02-20', 12000.00),
(5, 5, 3, '2024-03-10', 500.00),
(6, 6, 3, '2024-03-25', 2000.00),
(7, 7, 4, '2024-04-05', 1500.00),
(8, 8, 4, '2024-04-15', 6000.00),
(9, 9, 5, '2024-05-10', 800.00),
(10, 10, 5, '2024-05-20', 1200.00);

# 13. Inserindo Itens de Compra
INSERT INTO Item_Compra (id_compra, id_produto, quantidade, preco_unitario, preco_total) VALUES
(1, 1, 100, 20.00, 2000.00), (1, 2, 50, 60.00, 3000.00),
(2, 4, 30, 150.00, 4500.00), (3, 8, 20, 50.00, 1000.00),
(4, 3, 50, 80.00, 4000.00), (5, 9, 10, 50.00, 500.00),
(6, 10, 50, 40.00, 2000.00), (7, 5, 50, 30.00, 1500.00),
(8, 6, 100, 40.00, 4000.00), (9, 7, 20, 40.00, 800.00);

# 14. Inserindo Vendas
INSERT INTO Venda (id_venda, id_filial, id_funcionario, id_cliente, id_desconto, data_venda, valor_total, valor_desconto, tipo_pagamento) VALUES
(1, 1, 2, 1, 1, '2024-10-01', 199.80, 0.00, 'Crédito'),
(2, 1, 2, 2, 2, '2024-10-02', 116.91, 12.99, 'Débito'),
(3, 2, 4, 3, 1, '2024-10-03', 299.90, 0.00, 'Pix'),
(4, 2, 4, 4, 4, '2024-10-04', 139.90, 20.00, 'Dinheiro'),
(5, 3, 6, 5, 1, '2024-10-05', 69.90, 0.00, 'Crédito'),
(6, 3, 6, 6, 1, '2024-10-06', 89.90, 0.00, 'Débito'),
(7, 4, 2, 7, 7, '2024-10-07', 79.92, 19.98, 'Pix'),
(8, 4, 2, 8, 1, '2024-10-08', 250.00, 0.00, 'Crédito'),
(9, 5, 10, 9, 1, '2024-10-09', 79.90, 0.00, 'Dinheiro'),
(10, 5, 10, 10, 1, '2024-10-10', 49.90, 0.00, 'Pix');

# 15. Inserindo Itens de Venda
INSERT INTO Item_Venda (id_venda, id_produto, quantidade, preco_unitario, preco_total) VALUES
(1, 1, 2, 49.90, 99.80), (1, 7, 1, 99.90, 99.90),
(2, 2, 1, 129.90, 129.90), (3, 4, 1, 299.90, 299.90),
(4, 3, 1, 159.90, 159.90), (5, 5, 1, 69.90, 69.90),
(6, 6, 1, 89.90, 89.90), (7, 7, 1, 99.90, 99.90),
(8, 9, 1, 250.00, 250.00), (9, 10, 1, 79.90, 79.90);

# 16. Inserindo Metas de Venda
INSERT INTO Meta_Venda (id_meta, id_filial, ano, mes, valor_meta, id_cargo) VALUES
(1, 1, 2024, 10, 1200.00, 4),
(2, 1, 2024, 10, 400.00, 1),
(3, 2, 2024, 10, 1100.00, 4),
(4, 2, 2024, 10, 450.00, 2),
(5, 3, 2024, 10, 1400.00, 4),
(6, 3, 2024, 10, 100.00, 6),
(7, 4, 2024, 10, 1000.00, 4),
(8, 4, 2024, 10, 0.00, 7),
(9, 5, 2024, 10, 1000.00, 4),
(10, 5, 2024, 10, 500.00, 3);

# 17. Inserindo Comissionamento
INSERT INTO Comissionamento (id_comissionamento, id_funcionario, id_meta, atingimento_meta, tipo_comissao, valor, valor_final, data_meta_batida) VALUES
(1, 1, 1, 60.00, 'Gerência', 500.00, 300.00, NULL),
(2, 2, 2, 150.00, 'Venda', 200.00, 250.00, '2024-10-30'),
(3, 3, 3, 40.00, 'Gerência', 400.00, 160.00, NULL),
(4, 4, 4, 100.00, 'Venda', 100.00, 100.00, '2024-10-29'),
(5, 5, 5, 10.00, 'Gerência', 300.00, 30.00, NULL),
(6, 6, 6, 150.00, 'Venda', 50.00, 100.00, '2024-10-28'),
(7, 8, 7, 100.00, 'Gerência', 500.00, 500.00, '2024-10-31'),
(8, 7, 9, 100.00, 'Bônus', 200.00, 200.00, '2024-10-31'),
(9, 10, 10, 60.00, 'Gerência', 200.00, 140.00, NULL),
(10, 6, 2, 100.00, 'Venda', 100.00, 100.00, '2024-10-31');

#PARTE 3 - Consultas

# 3.1. Consultar o nome da Filial e o nome do seu Gerente das lojas localizadas na Região 'Sudeste'.
select f.nome as filial, func.nome as nome_gerente, reg.nome as regiao
from filial f
join funcionario func on f.id_gerente = func.id_funcionario
join regiao reg on f.id_regiao = reg.id_regiao
where reg.nome = 'Sudeste';

# 3.2. Consultar nome e preço dos produtos que pertencem à coleção 'Inverno 2024' e que custam mais de R$ 100,00.
select p.nome as produto, p.preco as preco, c.nome as colecao
from produto p
join colecao c on p.id_colecao = c.id_colecao
where c.nome = 'Inverno 2024' and p.preco > 100.00;

# 3.3. Consultar o código da venda, o nome do cliente, o nome do funcionário e o tipo do desconto utilizado.
select v.id_venda, c.nome as cliente, func.nome as vendedor, d.nome as desconto_Utilizado
from venda v
join cliente c on v.id_cliente = c.id_cliente
join funcionario func on v.id_funcionario = func.id_funcionario
join desconto d on v.id_desconto = d.id_desconto;

# 3.4. Consultar os nomes dos fornecedores do estado de SP que fornecem insumos que contenham a palavra Tecido no nome do tipo.
select forn.nome as fornecedor, forn.cidade, ti.nome as tipo_insumo
from fornecedor forn
join tipo_insumo ti on forn.id_tipo_insumo = ti.id_tipo_insumo
where forn.estado = 'SP' and ti.nome like '%Tecido%';

# 3.5. Consultar a data da compra, o nome do produto comprado e a quantidade, pelo o fornecedor Têxtil São Jorge.
select comp.data_compra, prod.nome as produto_comprado, ic.quantidade
from compra comp
join fornecedor f on comp.id_fornecedor = f.id_fornecedor
join item_compra ic on comp.id_compra = ic.id_compra
join produto prod on ic.id_produto = prod.id_produto
where f.nome = 'Têxtil São Jorge';

# 3.6. Consultar todas as filiais que não possuem nenhum registro na tabela de metas para o ano de 2024.
select f.nome as filial_sem_meta
from filial f
left join meta_venda m on f.id_filial = m.id_filial and m.ano = 2024
where m.id_meta in null;

# 3.7. Consultar o nome dos funcionários com cargo de Vendedor que não aparecem em nenhuma venda registrada.
select distinct f.nome as funcionario, c.nome as cargo
from funcionario f
join cargo c on f.id_cargo = c.id_cargo
left join venda v on f.id_funcionario = v.id_funcionario
where c.nome like 'Vendedor%' and v.id_venda >= 2;

# 3.8. Consultar os nomes dos descontos cadastrados no sistema que nunca foram vinculados a nenhuma venda.
select d.nome as desc_naousado
from desconto d
left join venda v on d.id_desconto = v.id_desconto
where v.id_venda is null;

# 3.9. Consultar os fornecedores cadastrados dos quais a empresa nunca comprou nada.
select f.nome as fornecedor_sem_compra
from fornecedor f
left join compra c on f.id_fornecedor = c.id_fornecedor
where c.id_compra is null;

# 3.10. Consultar as coleções que existem no sistema, mas que não têm nenhum produto vinculado a elas.
select c.nome as colecao_vazia, c.status
from colecao c
left join produto p on c.id_colecao = p.id_colecao
where p.id_produto is null;


# 3.11. Filiais que atingiram faturamento acima de 150 no mês de outubro
select fi.nome, avg(v.valor_total) as faturamento_medio from filial as fi
left join venda as v on v.id_filial = fi.id_filial
where month(v.data_venda) = 10
group by fi.nome
having avg(v.valor_total) > 150

# 3.12. Vendedor que mais vendeu
select f.nome as funcionario, count(v.id_venda) as qtd_vendas, sum(v.valor_total) as total_vendido from venda v
join funcionario f on f.id_funcionario = v.id_funcionario
join cargo c on c.id_cargo = f.id_cargo
where c.nome like 'Vendedor%'
group by f.id_funcionario
order by total_vendido desc
limit 1;

# 3.13. Média salarial por cargo
select c.nome as cargo, avg(f.salario) as media_salarial from funcionario f
join cargo c on c.id_cargo = f.id_cargo
group by c.id_cargo
order by media_salarial desc;

# 3.14. Total valor recebido e total valor pago por produto
select p.nome, sum(ic.preco_total) as total_pago, sum(iv.preco_total) as total_recebido
from produto as p 
left join item_compra as ic on ic.id_produto = p.id_produto
left join item_venda as iv on iv.id_produto = p.id_produto
group by p.nome;

# 3.15. Quantidade mínima de venda para ter lucro de cada produto
select p.nome, round(sum(ic.preco_total) / p.preco) as qtd_minima
from produto as p 
left join item_compra as ic on ic.id_produto = p.id_produto
group by p.nome;

# 3.16. Quantidade de pessoas que atingiram pelo menos 100% da meta e o maior valor de comissionamento por cargo
select ca.nome, count(co.id_funcionario) as qtd_pessoas, max(valor_final) as maior_valor from comissionamento as co
join funcionario as f on f.id_funcionario = co.id_funcionario
join cargo as ca on ca.id_cargo = f.id_cargo
where co.atingimento_meta > 100
group by ca.nome;

# 3.17. Funcionário que não é vendedor e mesmo assim realizou vendas e o total_vendido
select f.nome, sum(v.valor_total) as total_vendido from venda as v 
join funcionario f on f.id_funcionario = v.id_funcionario
join cargo c on c.id_cargo = f.id_cargo
where c.nome not like 'Vendedor%'
group by f.nome;

# 3.18. Quantidade de utilização de cada desconto (incluindo descontos não usados)
select d.nome, count(v.id_venda) as qtd_desconto from desconto as d
left join venda as v on d.id_desconto = v.id_desconto
group by d.nome
order by qtd_desconto desc;

# 3.19. TOP 3 Produtos mais lucrativos
select 
    p.nome AS produto,
   	sum(iv.preco_total) AS total_recebido,
    sum(ic.preco_total) AS total_pago,
    sum(iv.preco_total) - sum(ic.preco_total) AS lucro_total
from produto p
join item_venda iv ON iv.id_produto = p.id_produto
join item_compra ic ON ic.id_produto = p.id_produto
group by p.id_produto, p.nome
order by lucro_total desc
limit 3;

# 3.20. Cliente que mais que gastou nas filiais do estado de SP 
select c.nome, sum(v.valor_total) as total_gasto from cliente as c
join venda as v on v.id_cliente = c.id_cliente 
join filial as f on f.id_filial = v.id_filial
where f.estado = 'SP'
group by c.nome
order by total_gasto desc
limit 1;
