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
	username VARCHAR(40) NOT NULL,
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
    data_reserva DATETIME NOT NULL default GETDATE(), 
    data_limite DATETIME NOT NULL,
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
    limite_renovacoes INT DEFAULT 2,
	status_emprestimo VARCHAR(20) NOT NULL DEFAULT 'emprestado',
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_midia) REFERENCES Midia(id_midia),
    FOREIGN KEY (id_reserva) REFERENCES Reserva(id_reserva),
	CONSTRAINT chk_status_emprestimo CHECK (status_emprestimo IN ('atrasado','emprestado','renovado','devolvido'))
);
GO

CREATE TABLE Mensagem (
    id_mensagem INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
	titulo NVARCHAR(60) NOT NULL,
    conteudo NVARCHAR(255) NOT NULL,
    data_postagem DATETIME NOT NULL,
    visibilidade BIT DEFAULT 1 NOT NULL, -- 1 = publica, 0 = privada
	curtidas INT DEFAULT 0,
	id_pai INT, 
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
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
	data_indicacao DATETIME NOT NULL DEFAULT GETDATE(),
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

INSERT INTO Cliente (nome, username, cpf, email, telefone, senha, status_conta) VALUES 
('Gabriel Gonçalves', 'gabsfofinha', '666.666.666-66', 'gabriel.goncalves@email.com', '11999990006', 'abc123', 'banido'),
('Luiggi Alexandre', 'luiggiale', '777.777.777-77', 'luiggi.alexandre@email.com', '11999990007', 'senha456', 'ativo'),
('Pedro Dias', 'pedrodiass', '888.888.888-88', 'pedro.dias@email.com', '11999990008', 'senha789', 'ativo'),
('Rikelme Souza', 'rik1000grau', '999.999.999-99', 'rikelme.souza@email.com', '11999990009', '123senha', 'ativo'),
('Cauê Gonçalves', 'cauezinGon', '000.000.000-00', 'caue.goncalves@email.com', '11999990010', 'xyz987', 'ativo');

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
(2, 1, '2025-06-14T14:00:00', '2025-06-17T14:00:00', 'ativa'),
(3, 2, '2025-06-15T14:00:00', '2025-06-18T14:00:00', 'ativa'),
(4, 3, '2025-06-13T14:00:00', '2025-06-16T14:00:00', 'expirada'),
(5, 4, '2025-06-16T14:00:00', '2025-06-19T14:00:00', 'ativa'),
(2, 5, '2025-06-17T14:00:00', '2025-06-20T14:00:00', 'cancelada');
GO

INSERT INTO Emprestimo (id_cliente, id_funcionario, id_midia, id_reserva, data_emprestimo, data_devolucao, limite_renovacoes) VALUES 
(2, 1, 1, 1, '2025-06-14', '2025-06-21', 1),
(3, 2, 2, 2, '2025-06-15', '2025-06-22', 0),
(4, 3, 3, 3, '2025-06-13', '2025-06-20', 2),
(5, 4, 5, 5, '2025-06-17', '2025-06-24', 0),
(3, 5, 4, 4, '2025-06-16', '2025-06-23', 1);
GO

INSERT INTO Mensagem (id_cliente, titulo, conteudo, data_postagem) VALUES 
(2, '', 'Seria útimo adicionarem "Dom Casmurro" à coleção.', '2025-06-14T10:00:00'),
(3, '', 'Auto da Compadecida é uma obra-prima!', '2025-06-15T11:30:00'),
(4, '', 'Sugiro incluir "O Quinze" da Rachel de Queiroz.', '2025-06-16T12:45:00'),
(5, '', '"1984" deveria estar disponÃ­vel também em áudio.', '2025-06-17T09:20:00'),
(3, '', 'A edição da Superinteressante de maio estava muito boa.', '2025-06-18T08:00:00');
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

INSERT INTO Parametros (multa_dia, prazo_devolucao_dias, limite_emprestimos) VALUES 
(2.00, 14, 3);
GO
/*
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
UPDATE Cliente
SET imagem_perfil = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\bressan.jpg', SINGLE_BLOB) AS img
)
WHERE id_cliente = 1;
GO
UPDATE Cliente
SET imagem_perfil = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\bressan.jpg', SINGLE_BLOB) AS img
)
WHERE id_cliente = 2;
GO
UPDATE Cliente
SET imagem_perfil = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\bressan.jpg', SINGLE_BLOB) AS img
)
WHERE id_cliente = 3;
GO
UPDATE Cliente
SET imagem_perfil = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\bressan.jpg', SINGLE_BLOB) AS img
)
WHERE id_cliente = 4;
GO
UPDATE Cliente
SET imagem_perfil = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\bressan.jpg', SINGLE_BLOB) AS img
)
WHERE id_cliente = 5;
*/
