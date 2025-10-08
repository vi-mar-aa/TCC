USE master;
GO

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'Littera') 
    DROP DATABASE Littera;

CREATE DATABASE Littera;
GO

EXEC sp_configure 'show advanced options', 1;
GO

RECONFIGURE;
GO

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
GO

RECONFIGURE;
GO

USE Littera;
GO

CREATE TABLE CargoFuncionario (
    id_cargo INT PRIMARY KEY IDENTITY,
    nome_cargo VARCHAR(100) NOT NULL
);
GO

CREATE TABLE Funcionario (
    id_funcionario INT PRIMARY KEY IDENTITY,
    id_cargo INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    senha VARCHAR(255) NOT NULL,
    status_conta VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_cargo) REFERENCES CargoFuncionario(id_cargo),
    CONSTRAINT chk_func_status CHECK (status_conta IN ('ativo', 'banido'))
);
GO

CREATE TABLE Cliente (
    id_cliente INT PRIMARY KEY IDENTITY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    senha VARCHAR(255) NOT NULL,
    status_conta VARCHAR(20) NOT NULL,
	imagem_perfil VARBINARY(MAX),
    CONSTRAINT chk_cli_status CHECK (status_conta IN ('ativo', 'banido'))
);
GO

CREATE TABLE TipoMidia (
    id_tpmidia INT PRIMARY KEY IDENTITY,
    nome_tipo VARCHAR(50) NOT NULL
);
GO

CREATE TABLE Midia (
    id_midia INT PRIMARY KEY IDENTITY,
    id_funcionario INT NOT NULL,
    id_tpmidia INT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    sinopse VARCHAR(255) NOT NULL, 
    autor VARCHAR(100),
    editora VARCHAR(100),
    ano_publicacao INT,
    edicao VARCHAR(50),
    local_publicacao VARCHAR(100),
    numero_paginas INT,
    isbn VARCHAR(20),
    duracao VARCHAR(20),
    estudio VARCHAR(100),
    roteirista VARCHAR(100),
    disponibilidade VARCHAR(20) NOT NULL,
    genero VARCHAR(100),
    imagem VARBINARY(MAX),
	status_midia VARCHAR(20) DEFAULT 'publica',
    codigo_exemplar INT NOT NULL,
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_tpmidia) REFERENCES TipoMidia(id_tpmidia),
    CONSTRAINT chk_disponibilidade CHECK (disponibilidade IN ('disponível', 'emprestado')),
    CONSTRAINT chk_status_midia CHECK (status_midia IN ('publica', 'privada'))
);
GO


CREATE TABLE Reserva (
    id_reserva INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
    id_midia INT NOT NULL,
    data_reserva DATE NOT NULL,
    data_limite DATE NOT NULL,
    status_reserva VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_midia) REFERENCES Midia(id_midia),
    CONSTRAINT chk_status_reserva CHECK (status_reserva IN ('ativa', 'expirada', 'cancelada', 'concluida'))
);
GO

CREATE TABLE Emprestimo (
    id_emprestimo INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
    id_funcionario INT NOT NULL,
    id_midia INT NOT NULL,
    id_reserva INT,
    data_emprestimo DATE NOT NULL,
    data_devolucao DATE NOT NULL,
    limite_renovacoes INT DEFAULT 0,
	status_pagamento VARCHAR(20) NOT NULL DEFAULT 'pendente',
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_midia) REFERENCES Midia(id_midia),
    FOREIGN KEY (id_reserva) REFERENCES Reserva(id_reserva),
	CONSTRAINT chk_status_pagamento CHECK (status_pagamento IN ('pendente','pago'))
);
GO

CREATE TABLE Mensagem (
    id_mensagem INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
    conteudo NVARCHAR(255) NOT NULL,
    data_postagem DATETIME NOT NULL,
    visibilidade VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT chk_visibilidade CHECK (visibilidade IN ('publica', 'privada'))
);
GO

CREATE TABLE Denuncia (
    id_denuncia INT PRIMARY KEY IDENTITY,
    id_funcionario INT,
    id_mensagem INT NOT NULL,
    id_cliente INT NOT NULL,
    data_denuncia DATETIME NOT NULL,
    motivo VARCHAR(255),
    status_denuncia VARCHAR(20) NOT NULL,
    acao_tomada VARCHAR(255),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_mensagem) REFERENCES Mensagem(id_mensagem),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT chk_denuncia_status_denuncia CHECK (status_denuncia IN ('pendente', 'resolvida'))
);
GO

CREATE TABLE ListaDeDesejos (
    id_cliente INT NOT NULL,
    id_midia INT NOT NULL,
    data_adicionada DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (id_cliente, id_midia),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_midia) REFERENCES Midia(id_midia)
);
GO

CREATE TABLE Evento (
    id_evento INT PRIMARY KEY IDENTITY,
    titulo NVARCHAR(200) NOT NULL,
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME NOT NULL,
    local_evento NVARCHAR(200) NOT NULL,
    status_evento VARCHAR(20) NOT NULL DEFAULT 'ativo',
    id_funcionario INT NOT NULL,
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario)
);
GO

CREATE TABLE Indicacao (
    id_indicacao INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
    titulo_ind VARCHAR(255) NOT NULL,
    autor_ind VARCHAR(120),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);
GO

CREATE TABLE Notificacao (
    id_notificacao INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    mensagem VARCHAR(MAX) NOT NULL,
    data_criacao DATETIME NOT NULL DEFAULT GETDATE(),
    lida BIT DEFAULT 0,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);
GO

CREATE TABLE Parametros(
	id_parametros INT IDENTITY PRIMARY KEY,
	multa_dia DECIMAL(10,2)  NOT NULL, 
	prazo_devolucao_dias INT  NOT NULL, 
	limite_emprestimos INT  NOT NULL
);
GO

CREATE TRIGGER trg_Midia_AssignCodigo
ON Midia
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Midia (
        id_funcionario, id_tpmidia, titulo, sinopse, autor, editora, ano_publicacao,
        edicao, local_publicacao, numero_paginas, isbn, duracao, estudio, roteirista,
        disponibilidade, genero, imagem, codigo_exemplar
    )
    SELECT 
        i.id_funcionario, i.id_tpmidia, i.titulo, i.sinopse, i.autor, i.editora, i.ano_publicacao,
        i.edicao, i.local_publicacao, i.numero_paginas, i.isbn, i.duracao, i.estudio, i.roteirista,
        i.disponibilidade, i.genero, i.imagem,
        ISNULL((
            SELECT MAX(m.codigo_exemplar)
            FROM Midia m
            WHERE
              (
                (i.isbn IS NOT NULL AND i.isbn <> '' AND m.isbn = i.isbn) -- com ISBN
              )
              OR
              (
                (i.isbn IS NULL OR i.isbn = '')                           -- sem ISBN
                AND (m.isbn IS NULL OR m.isbn = '')
                AND m.titulo = i.titulo
                AND m.id_tpmidia = i.id_tpmidia
              )
        ),0) + 1 AS novo_codigo
    FROM inserted i;
END
GO


-- INSERTS COMPLETOS

INSERT INTO CargoFuncionario (nome_cargo) VALUES ('bibliotecario'), ('adm');
GO

INSERT INTO Funcionario (id_cargo, nome, cpf, email, telefone, senha, status_conta) VALUES
(1, 'Luiz Ricardo', '111.111.111-11', 'luiz.ricardo@email.com', '11999990001', 'senha123', 'ativo'),
(1, 'Henrique Bressan', '222.222.222-22', 'henrique.bressan@email.com', '11999990002', 'senha123', 'ativo'),
(2, 'Maria Vitoria', '333.333.333-33', 'maria.vitoria@email.com', '11999990003', 'senha123', 'ativo'),
(2, 'Luiz Pinheiro', '444.444.444-44', 'luiz.pinheiro@email.com', '11999990004', 'senha123', 'ativo'),
(1, 'Marcia X', '555.555.555-55', 'marcia.x@email.com', '11999990005', 'senha123', 'ativo');
GO

INSERT INTO Cliente (nome, cpf, email, telefone, senha, status_conta) VALUES 
('Gabriel Gonçalves', '666.666.666-66', 'gabriel.goncalves@email.com', '11999990006', 'abc123', 'banido'),
('Luiggi Alexandre', '777.777.777-77', 'luiggi.alexandre@email.com', '11999990007', 'senha456', 'ativo'),
('Pedro Dias', '888.888.888-88', 'pedro.dias@email.com', '11999990008', 'senha789', 'ativo'),
('Rikelme Souza', '999.999.999-99', 'rikelme.souza@email.com', '11999990009', '123senha', 'ativo'),
('Cauê Gonçalves', '000.000.000-00', 'caue.goncalves@email.com', '11999990010', 'xyz987', 'ativo');
GO

INSERT INTO TipoMidia (nome_tipo) VALUES ('livros'), ('filmes'), ('revistas'), ('e-book');
GO

INSERT INTO Midia (id_funcionario, id_tpmidia, titulo, sinopse, autor, editora, ano_publicacao, edicao, local_publicacao, numero_paginas, isbn, duracao, estudio, roteirista, disponibilidade, genero) VALUES 
(1, 1, 'Mar Morto', '', 'Jorge Amado', 'Companhia das Letras', 1936, '1ª', 'Salvador', 250, '9788535902773', NULL, NULL, NULL, 'disponível', 'Romance'),
(2, 1, 'Vidas Secas', '', 'Graciliano Ramos', 'Record', 1938, '3ª', 'Maceió', 200, '9788501042329', NULL, NULL, NULL, 'disponível', 'Drama'),
(3, 2, 'O Auto da Compadecida', '', 'Ariano Suassuna', NULL, 2000, NULL, NULL, NULL, NULL, '1h40min', 'Globo Filmes', 'Guel Arraes', 'emprestado', 'Comédia'),
(4, 3, 'Revista Superinteressante - Edição 402', '', NULL, 'Abril', 2022, NULL, 'São Paulo', 80, NULL, NULL, NULL, NULL, 'disponível', 'Ciência'),
(5, 4, '1984', '', 'George Orwell', 'Penguin', 1949, '2ª', 'Londres', 328, '9780141036144', NULL, NULL, NULL, 'emprestado', 'Ficção Cientí­fica');
GO

INSERT INTO Reserva (id_cliente, id_midia, data_reserva, data_limite, status_reserva) VALUES 
(2, 1, '2025-06-14', '2025-06-17', 'ativa'),
(3, 2, '2025-06-15', '2025-06-18', 'ativa'),
(4, 3, '2025-06-13', '2025-06-16', 'expirada'),
(5, 4, '2025-06-16', '2025-06-19', 'ativa'),
(2, 5, '2025-06-17', '2025-06-20', 'cancelada');
GO

INSERT INTO Emprestimo (id_cliente, id_funcionario, id_midia, id_reserva, data_emprestimo, data_devolucao, limite_renovacoes) VALUES 
(2, 1, 1, 1, '2025-06-14', '2025-06-21', 1),
(3, 2, 2, 2, '2025-06-15', '2025-06-22', 0),
(4, 3, 3, 3, '2025-06-13', '2025-06-20', 2),
(5, 4, 5, 5, '2025-06-17', '2025-06-24', 0),
(3, 5, 4, 4, '2025-06-16', '2025-06-23', 1);
GO

INSERT INTO Mensagem (id_cliente, conteudo, data_postagem, visibilidade) VALUES 
(2, 'Seria útimo adicionarem "Dom Casmurro" à coleção.', '2025-06-14T10:00:00', 'publica'),
(3, 'Auto da Compadecida é uma obra-prima!', '2025-06-15T11:30:00', 'publica'),
(4, 'Sugiro incluir "O Quinze" da Rachel de Queiroz.', '2025-06-16T12:45:00', 'publica'),
(5, '"1984" deveria estar disponÃ­vel também em áudio.', '2025-06-17T09:20:00', 'publica'),
(3, 'A edição da Superinteressante de maio estava muito boa.', '2025-06-18T08:00:00', 'privada');
GO

INSERT INTO Denuncia (id_funcionario, id_mensagem, id_cliente, data_denuncia, motivo, status_denuncia, acao_tomada) VALUES 
(1, 5, 2, '2025-06-18T14:00:00', 'Conteúdo inadequado', 'resolvida', 'Mensagem ocultada'),
(2, 4, 3, '2025-06-17T13:00:00', 'Spam', 'pendente', NULL),
(3, 3, 4, '2025-06-16T11:00:00', 'Fora do tópico', 'resolvida', 'Advertência ao usuário'),
(4, 2, 5, '2025-06-15T10:30:00', 'Linguagem ofensiva', 'pendente', NULL),
(5, 1, 3, '2025-06-14T09:45:00', 'Duplicado', 'resolvida', 'Mensagem removida');
GO

INSERT INTO ListaDeDesejos (id_cliente, id_midia) VALUES 
(2, 1),
(3, 2),
(4, 3),
(5, 4),
(3, 5);
GO

INSERT INTO Evento (titulo, data_inicio, data_fim, local_evento, id_funcionario) VALUES
('Clube do Livro - Jorge Amado', '2025-09-10T19:00:00', '2025-09-10T21:00:00', 'Sala de leitura 1', 1),
('Exibição de Filme - O Auto da Compadecida', '2025-09-15T20:00:00', '2025-09-15T22:00:00', 'Auditório Principal', 2),
('Palestra: A Literatura Nordestina', '2025-09-20T18:00:00', '2025-09-20T20:00:00', 'Sala 2', 3),
('Semana de Ciência e Conhecimento', '2025-09-25T09:00:00', '2025-09-25T17:00:00', 'Auditório B', 4),
('Encontro de e-Books - Discussões Modernas', '2025-10-02T17:00:00', '2025-10-02T19:00:00', 'Online', 5);
GO

INSERT INTO Indicacao (id_cliente, titulo_ind, autor_ind) VALUES
(2, 'Dom Casmurro', 'Machado de Assis'),
(3, 'O Quinze', 'Rachel de Queiroz'),
(4, 'Grande Sertão: Veredas', 'João Guimarães Rosa'),
(5, 'Memórias Póstumas de Brás Cubas', 'Machado de Assis'),
(2, 'Capitães da Areia', 'Jorge Amado');
GO

INSERT INTO Notificacao (id_cliente, titulo, mensagem) VALUES
(2, 'Lembrete de Devolução', 'Você tem um livro para devolver até 21/06.'),
(3, 'Reserva Ativa', 'Sua reserva do livro "Vidas Secas" está disponível até 18/06.'),
(1, 'Nova Denúncia', 'Uma denúncia foi atribuída para sua análise.'),
(4, 'Evento Hoje', 'Não esqueça: Palestra sobre Literatura Nordestina às 18h.'),
(5, 'Indicação Recebida', 'Sua indicação de "O Quinze" está em análise.');
GO

-------------------------------
-- CLIENTE (total: 15)
-------------------------------
INSERT INTO Cliente (nome, cpf, email, telefone, senha, status_conta) VALUES
('Ana Clara', '101.101.101-10', 'ana.clara@email.com', '11999990011', 'senha001', 'ativo'),
('João Pedro', '202.202.202-20', 'joao.pedro@email.com', '11999990012', 'senha002', 'ativo'),
('Mariana Alves', '303.303.303-30', 'mariana.alves@email.com', '11999990013', 'senha003', 'ativo'),
('Rafael Lima', '404.404.404-40', 'rafael.lima@email.com', '11999990014', 'senha004', 'banido'),
('Beatriz Rocha', '505.505.505-50', 'beatriz.rocha@email.com', '11999990015', 'senha005', 'ativo'),
('Lucas Ferreira', '606.606.606-60', 'lucas.ferreira@email.com', '11999990016', 'senha006', 'ativo'),
('Fernanda Costa', '707.707.707-70', 'fernanda.costa@email.com', '11999990017', 'senha007', 'ativo'),
('Thiago Oliveira', '808.808.808-80', 'thiago.oliveira@email.com', '11999990018', 'senha008', 'ativo'),
('Juliana Martins', '909.909.909-90', 'juliana.martins@email.com', '11999990019', 'senha009', 'ativo'),
('Carlos Henrique', '121.121.121-21', 'carlos.henrique@email.com', '11999990020', 'senha010', 'ativo');
GO

-------------------------------
-- MIDIA (total: 15)
-------------------------------
INSERT INTO Midia (id_funcionario, id_tpmidia, titulo, sinopse, autor, editora, ano_publicacao, edicao, local_publicacao, numero_paginas, isbn, duracao, estudio, roteirista, disponibilidade, genero) VALUES
(1, 1, 'Dom Casmurro', '', 'Machado de Assis', 'Principis', 1899, '1ª', 'Rio de Janeiro', 300, '9788535910662', NULL, NULL, NULL, 'disponível', 'Romance'),
(2, 1, 'O Quinze', '', 'Rachel de Queiroz', 'José Olympio', 1930, '2ª', 'Fortaleza', 180, '9788503008675', NULL, NULL, NULL, 'disponível', 'Romance'),
(3, 1, 'Grande Sertão: Veredas', '', 'João Guimarães Rosa', 'Nova Fronteira', 1956, '1ª', 'Rio de Janeiro', 600, '9788520920737', NULL, NULL, NULL, 'emprestado', 'Romance'),
(4, 1, 'Memórias Póstumas de Brás Cubas', '', 'Machado de Assis', 'Ática', 1881, '4ª', 'Rio de Janeiro', 250, '9788520922588', NULL, NULL, NULL, 'disponível', 'Clássico'),
(5, 2, 'Central do Brasil', '', NULL, NULL, 1998, NULL, NULL, NULL, NULL, '1h50min', 'Videofilmes', 'Walter Salles', 'disponível', 'Drama'),
(1, 2, 'Cidade de Deus', '', NULL, NULL, 2002, NULL, NULL, NULL, NULL, '2h10min', 'O2 Filmes', 'Fernando Meirelles', 'emprestado', 'Crime'),
(2, 3, 'Revista Veja - Edição 3000', '', NULL, 'Abril', 2017, NULL, 'São Paulo', 90, NULL, NULL, NULL, NULL, 'disponível', 'Atualidades'),
(3, 3, 'Revista Galileu - Edição 350', '', NULL, 'Globo', 2021, NULL, 'São Paulo', 100, NULL, NULL, NULL, NULL, 'disponível', 'Ciência'),
(4, 4, 'O Pequeno Príncipe - eBook', '', 'Antoine de Saint-Exupéry', 'HarperCollins', 1943, '1ª', 'Paris', 120, '9788595081512', NULL, NULL, NULL, 'disponível', 'Fábula'),
(5, 4, 'Harry Potter e a Pedra Filosofal - eBook', '', 'J.K. Rowling', 'Rocco', 1997, '1ª', 'Londres', 309, '9788532511015', NULL, NULL, NULL, 'disponível', 'Fantasia');
GO

-------------------------------
-- RESERVA (total: 15)
-------------------------------
INSERT INTO Reserva (id_cliente, id_midia, data_reserva, data_limite, status_reserva) VALUES
(6, 6, '2025-07-01', '2025-07-05', 'ativa'),
(7, 7, '2025-07-02', '2025-07-06', 'cancelada'),
(8, 8, '2025-07-03', '2025-07-07', 'expirada'),
(9, 9, '2025-07-04', '2025-07-08', 'concluida'),
(10, 10, '2025-07-05', '2025-07-09', 'ativa'),
(6, 11, '2025-07-06', '2025-07-10', 'ativa'),
(7, 12, '2025-07-07', '2025-07-11', 'expirada'),
(8, 13, '2025-07-08', '2025-07-12', 'ativa'),
(9, 14, '2025-07-09', '2025-07-13', 'ativa'),
(10, 15, '2025-07-10', '2025-07-14', 'ativa');
GO

-------------------------------
-- EMPRESTIMO (total: 15)
-------------------------------
INSERT INTO Emprestimo (id_cliente, id_funcionario, id_midia, id_reserva, data_emprestimo, data_devolucao, limite_renovacoes, status_pagamento) VALUES
(6, 1, 6, 6, '2025-07-01', '2025-07-08', 1, 'pendente'),
(7, 2, 7, 7, '2025-07-02', '2025-07-09', 0, 'pago'),
(8, 3, 8, 8, '2025-07-03', '2025-07-10', 2, 'pendente'),
(9, 4, 9, 9, '2025-07-04', '2025-07-11', 1, 'pendente'),
(10, 5, 10, 10, '2025-07-05', '2025-07-12', 0, 'pago'),
(6, 1, 11, NULL, '2025-07-06', '2025-07-13', 1, 'pago'),
(7, 2, 12, NULL, '2025-07-07', '2025-07-14', 1, 'pendente'),
(8, 3, 13, NULL, '2025-07-08', '2025-07-15', 0, 'pago'),
(9, 4, 14, NULL, '2025-07-09', '2025-07-16', 0, 'pendente'),
(10, 5, 15, NULL, '2025-07-10', '2025-07-17', 2, 'pago');
GO

-------------------------------
-- MENSAGEM (total: 15)
-------------------------------
INSERT INTO Mensagem (id_cliente, conteudo, data_postagem, visibilidade) VALUES
(6, 'Adoraria ver mais clássicos disponíveis.', '2025-07-01T09:00:00', 'publica'),
(7, 'Seria bom incluir mais revistas científicas.', '2025-07-02T10:30:00', 'publica'),
(8, 'Cidade de Deus é impactante.', '2025-07-03T11:45:00', 'publica'),
(9, 'Gostaria de mais ebooks infantis.', '2025-07-04T12:00:00', 'privada'),
(10, 'A sessão de HQs poderia ser maior.', '2025-07-05T13:15:00', 'publica'),
(6, 'Por favor adicionem audiobooks!', '2025-07-06T14:20:00', 'privada'),
(7, 'Boa qualidade das edições digitais.', '2025-07-07T15:40:00', 'publica'),
(8, 'Revistas antigas também seriam interessantes.', '2025-07-08T16:50:00', 'publica'),
(9, 'O catálogo de filmes poderia ter mais nacionais.', '2025-07-09T17:30:00', 'publica'),
(10, 'Sugestão: seção de filosofia.', '2025-07-10T18:10:00', 'privada');
GO

-------------------------------
-- DENUNCIA (total: 15)
-------------------------------
INSERT INTO Denuncia (id_funcionario, id_mensagem, id_cliente, data_denuncia, motivo, status_denuncia, acao_tomada) VALUES
(1, 6, 6, '2025-07-01T19:00:00', 'Spam', 'pendente', NULL),
(2, 7, 7, '2025-07-02T19:15:00', 'Conteúdo ofensivo', 'resolvida', 'Mensagem removida'),
(3, 8, 8, '2025-07-03T19:30:00', 'Fora de tópico', 'pendente', NULL),
(4, 9, 9, '2025-07-04T19:45:00', 'Duplicado', 'resolvida', 'Mensagem ocultada'),
(5, 10, 10, '2025-07-05T20:00:00', 'Inadequado', 'pendente', NULL);
GO

-------------------------------
-- LISTA DE DESEJOS (total: 15)
-------------------------------
INSERT INTO ListaDeDesejos (id_cliente, id_midia) VALUES
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10),
(6, 11), (7, 12), (8, 13), (9, 14), (10, 15);
GO

-------------------------------
-- EVENTO (total: 15)
-------------------------------
INSERT INTO Evento (titulo, data_inicio, data_fim, local_evento, id_funcionario) VALUES
('Ciclo de Leituras - Machado de Assis', '2025-10-10T19:00:00', '2025-10-10T21:00:00', 'Sala 3', 1),
('Exibição de Filme - Central do Brasil', '2025-10-12T20:00:00', '2025-10-12T22:00:00', 'Auditório Principal', 2),
('Oficina: Escrita Criativa', '2025-10-14T18:00:00', '2025-10-14T20:00:00', 'Sala 4', 3),
('Semana do Romance Brasileiro', '2025-10-16T09:00:00', '2025-10-16T17:00:00', 'Auditório A', 4),
('Encontro Digital - Literatura e Tecnologia', '2025-10-20T17:00:00', '2025-10-20T19:00:00', 'Online', 5);
GO

-------------------------------
-- INDICACAO (total: 15)
-------------------------------
INSERT INTO Indicacao (id_cliente, titulo_ind, autor_ind) VALUES
(6, 'A Hora da Estrela', 'Clarice Lispector'),
(7, 'Iracema', 'José de Alencar'),
(8, 'Senhora', 'José de Alencar'),
(9, 'Capitães da Areia', 'Jorge Amado'),
(10, 'A Moreninha', 'Joaquim Manuel de Macedo');
GO

-------------------------------
-- NOTIFICACAO (total: 15)
-------------------------------
INSERT INTO Notificacao (id_cliente, titulo, mensagem) VALUES
(6, 'Reserva Concluída', 'Sua reserva de Cidade de Deus foi concluída.'),
(7, 'Emprestimo Registrado', 'Seu empréstimo da revista Veja está ativo.'),
(8, 'Prazo de Devolução', 'Lembre-se de devolver até 10/07.'),
(9, 'Evento Confirmado', 'Você está inscrito em Semana do Romance Brasileiro.'),
(10, 'Indicação Publicada', 'Sua indicação de A Hora da Estrela foi aceita.');
GO


INSERT INTO Parametros (multa_dia, prazo_devolucao_dias, limite_emprestimos) VALUES 
(2.00, 14, 3);
GO

UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\MarMorto-JorgeAmado.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 1;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\VidasSecas-GracilianoRamos.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 2;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\AutoDaCompadecida-ArianoSuassuna.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 3;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\\SuperInteressante_402.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 4;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\1984-GeorgeOrwell.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 5;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\placeholder.png', SINGLE_BLOB) AS img
)
WHERE id_midia = 6;
GO

UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\placeholder.png', SINGLE_BLOB) AS img
)
WHERE id_midia = 7;
GO

UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\placeholder.png', SINGLE_BLOB) AS img
)
WHERE id_midia = 8;
GO

UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\placeholder.png', SINGLE_BLOB) AS img
)
WHERE id_midia = 9;
GO

UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\placeholder.png', SINGLE_BLOB) AS img
)
WHERE id_midia = 10;
GO

UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\placeholder.png', SINGLE_BLOB) AS img
)
WHERE id_midia = 11;
GO

UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\placeholder.png', SINGLE_BLOB) AS img
)
WHERE id_midia = 12;
GO

UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\placeholder.png', SINGLE_BLOB) AS img
)
WHERE id_midia = 13;
GO

UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\placeholder.png', SINGLE_BLOB) AS img
)
WHERE id_midia = 14;
GO

UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\placeholder.png', SINGLE_BLOB) AS img
)
WHERE id_midia = 15;
GO



/*
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\MarMorto-JorgeAmado.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 1;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\VidasSecas-GracilianoRamos.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 2;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\AutoDaCompadecida-ArianoSuassuna.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 3;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\SuperInteressante_402.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 4;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\1984-GeorgeOrwell.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 5;
*/

/*Select * from Midia

SELECT id_midia, DATALENGTH(imagem) AS tamanho_em_bytes
FROM Midia
WHERE id_midia = 2;

SELECT imagem FROM Midia WHERE id_midia = 1*/